.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/mmu_notifier.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Khi nào bạn cần thông báo khóa bảng trang bên trong?
===================================================

Khi xóa pte/pmd, chúng tôi được lựa chọn thông báo sự kiện thông qua
(thông báo phiên bản của \*_clear_flush gọi mmu_notifier_invalidate_range) trong
khóa bảng trang. Nhưng thông báo đó không cần thiết trong mọi trường hợp.

Đối với TLB thứ cấp (không phải CPU TLB) như IOMMU TLB hoặc thiết bị TLB (khi sử dụng thiết bị
những thứ như ATS/PASID để đưa IOMMU đi qua bảng trang CPU để truy cập một
xử lý không gian địa chỉ ảo). Chỉ có 2 trường hợp cần thông báo
những TLB phụ đó trong khi giữ khóa bảng trang khi xóa pte/pmd:

A) địa chỉ sao lưu trang miễn phí trước mmu_notifier_invalidate_range_end()
  B) một mục trong bảng trang được cập nhật để trỏ đến một trang mới (COW, lỗi ghi
     trên trang 0, __replace_page(), ...)

Trường hợp A hiển nhiên là bạn không muốn mạo hiểm để thiết bị ghi vào
một trang hiện có thể được sử dụng cho một số nhiệm vụ hoàn toàn khác.

Trường hợp B tinh tế hơn. Để chính xác, nó đòi hỏi trình tự sau đây để
xảy ra:

- lấy khóa bảng trang
  - xóa mục nhập bảng trang và thông báo ([pmd/pte]p_huge_clear_flush_notify())
  - đặt mục nhập bảng trang để trỏ đến trang mới

Nếu việc xóa mục nhập bảng trang không kèm theo thông báo trước khi cài đặt
giá trị pte/pmd mới thì bạn có thể phá vỡ mô hình bộ nhớ như C11 hoặc C++11 cho
thiết bị.

Hãy xem xét tình huống sau (thiết bị sử dụng tính năng tương tự ATS/PASID):

Hai địa chỉ addrA và addrB sao cho \ZZ0000ZZ >= PAGE_SIZE chúng ta giả sử
chúng được bảo vệ chống ghi cho COW (trường hợp B khác cũng được áp dụng).

::

[Thời điểm N] ----------------------------------------------------------------------
 CPU-thread-0 {cố gắng ghi vào addrA}
 CPU-thread-1 {cố gắng ghi vào addrB}
 CPU-thread-2 {}
 CPU-luồng-3 {}
 DEV-thread-0 {đọc addrA và điền vào thiết bị TLB}
 DEV-thread-2 {đọc addrB và điền vào thiết bị TLB}
 [Thời điểm N+1] ------------------------------------------------------------------
 CPU-thread-0 {COW_step0: {mmu_notifier_invalidate_range_start(addrA)}}
 CPU-thread-1 {COW_step0: {mmu_notifier_invalidate_range_start(addrB)}}
 CPU-thread-2 {}
 CPU-luồng-3 {}
 DEV-thread-0 {}
 DEV-luồng-2 {}
 [Thời gian N+2] ------------------------------------------------------------------
 CPU-thread-0 {COW_step1: {cập nhật bảng trang để trỏ tới trang mới cho addrA}}
 CPU-thread-1 {COW_step1: {cập nhật bảng trang để trỏ tới trang mới cho addrB}}
 CPU-luồng-2 {}
 CPU-luồng-3 {}
 DEV-thread-0 {}
 DEV-thread-2 {}
 [Thời gian N+3] ------------------------------------------------------------------
 CPU-thread-0 {được ưu tiên}
 CPU-thread-1 {được ưu tiên}
 CPU-thread-2 {ghi vào addrA là ghi vào trang mới}
 CPU-luồng-3 {}
 DEV-thread-0 {}
 DEV-thread-2 {}
 [Thời gian N+3] ------------------------------------------------------------------
 CPU-thread-0 {được ưu tiên}
 CPU-thread-1 {được ưu tiên}
 CPU-thread-2 {}
 CPU-thread-3 {ghi vào addrB là ghi vào trang mới}
 DEV-thread-0 {}
 DEV-thread-2 {}
 [Thời gian N+4] ------------------------------------------------------------------
 CPU-thread-0 {được ưu tiên}
 CPU-thread-1 {COW_step3: {mmu_notifier_invalidate_range_end(addrB)}}
 CPU-thread-2 {}
 CPU-luồng-3 {}
 DEV-thread-0 {}
 DEV-thread-2 {}
 [Thời gian N+5] ------------------------------------------------------------------
 CPU-thread-0 {được ưu tiên}
 CPU-luồng-1 {}
 CPU-thread-2 {}
 CPU-luồng-3 {}
 DEV-thread-0 {đọc addrA từ trang cũ}
 DEV-thread-2 {đọc addrB từ trang mới}

Vì vậy, ở đây vì tại thời điểm N+2 mục trong bảng trang rõ ràng không được ghép nối với một
thông báo vô hiệu hóa TLB thứ cấp, thiết bị sẽ thấy giá trị mới cho
addrB trước khi nhìn thấy giá trị mới của addrA. Điều này phá vỡ tổng thứ tự bộ nhớ
cho thiết bị.

Khi thay đổi một pte thành bảo vệ chống ghi hoặc trỏ đến một trang được bảo vệ chống ghi mới
có cùng nội dung (KSM), bạn có thể trì hoãn mmu_notifier_invalidate_range
gọi mmu_notifier_invalidate_range_end() bên ngoài khóa bảng trang. Cái này
đúng ngay cả khi luồng thực hiện cập nhật bảng trang được ưu tiên ngay sau đó
giải phóng khóa bảng trang nhưng trước khi gọi mmu_notifier_invalidate_range_end().
