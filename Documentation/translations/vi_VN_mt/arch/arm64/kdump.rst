.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm64/kdump.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========================================
đặt trước bộ nhớ Crashkernel trên arm64
=======================================

Tác giả: Baoquan He <bhe@redhat.com>

Cơ chế Kdump được sử dụng để bắt giữ vmcore kernel bị hỏng để
nó có thể được phân tích sau đó. Để làm được điều này, bước đầu
cần có bộ nhớ dành riêng để tải trước kernel kdump và khởi động như vậy
kernel nếu tham nhũng xảy ra.

Bộ nhớ dành riêng cho kdump được điều chỉnh để có thể giảm thiểu
chứa hạt nhân kdump và các chương trình không gian người dùng cần thiết cho
bộ sưu tập vmcore.

Tham số hạt nhân
================

Thông qua các tham số kernel bên dưới, bộ nhớ có thể được dự trữ tương ứng
trong giai đoạn đầu của lần khởi động kernel đầu tiên để liên tục
khối lượng lớn bộ nhớ có thể được tìm thấy. Việc dự trữ bộ nhớ thấp cần phải
được xem xét nếu hạt nhân sự cố được dành riêng từ vùng bộ nhớ cao.

- Crashkernel=size@offset
- hạt nhân bị hỏng = kích thước
- kernelkernel=kích thước,kernel cao=kích thước,thấp

Bộ nhớ thấp và bộ nhớ cao
==========================

Đối với các dự trữ kdump, bộ nhớ thấp là vùng bộ nhớ dưới một vùng nhớ cụ thể
giới hạn, thường được quyết định bởi các bit địa chỉ có thể truy cập của DMA có khả năng
các thiết bị mà kernel kdump cần để chạy. Những thiết bị đó không liên quan đến
Việc bán phá giá vmcore có thể được bỏ qua. Trên arm64, giới hạn trên của bộ nhớ thấp là
không cố định: đó là 1G trên nền tảng RPi4 nhưng là 4G trên hầu hết các hệ thống khác.
Trên các hạt nhân đặc biệt được xây dựng với CONFIG_ZONE_(DMA|DMA32) bị vô hiệu hóa,
toàn bộ hệ thống RAM có bộ nhớ thấp. Ngoài bộ nhớ thấp được mô tả
ở trên, phần còn lại của hệ thống RAM được coi là bộ nhớ cao.

Thực hiện
==============

1) Crashkernel=size@offset
--------------------------

Bộ nhớ hạt nhân sự cố phải được đặt trước ở vùng do người dùng chỉ định hoặc
thất bại nếu đã bị chiếm đóng.


2) hạt nhân=kích thước
-------------------

Vùng bộ nhớ Crashkernel sẽ được dành riêng ở bất kỳ vị trí nào có sẵn
theo thứ tự tìm kiếm:

Đầu tiên, kernel tìm kiếm vùng bộ nhớ thấp để tìm vùng khả dụng
với kích thước quy định.

Nếu tìm kiếm bộ nhớ thấp không thành công, kernel sẽ quay lại tìm kiếm
vùng bộ nhớ cao cho vùng có sẵn có kích thước được chỉ định. Nếu
việc đặt chỗ ở bộ nhớ cao thành công, việc đặt chỗ ở kích thước mặc định ở
bộ nhớ thấp sẽ được thực hiện. Hiện tại kích thước mặc định là 128M,
đủ cho nhu cầu bộ nhớ thấp của kernel kdump.

Lưu ý: Crashkernel=size là tùy chọn được đề xuất cho kernel Crashkernel
đặt phòng. Người dùng sẽ không cần biết cách bố trí bộ nhớ hệ thống
cho một nền tảng cụ thể.

3) kernelkernel=kích thước,kernel cao=kích thước,thấp
---------------------------------------------

Crashkernel=size,(high|low) là phần bổ sung quan trọng cho
Crashkernel=kích thước. Chúng cho phép người dùng chỉ định lượng bộ nhớ cần
được phân bổ lần lượt từ bộ nhớ cao và bộ nhớ thấp. Bật
nhiều hệ thống, bộ nhớ thấp rất quý giá và việc đặt trước kernel bị hỏng
từ khu vực này nên được giữ ở mức tối thiểu.

Để dành bộ nhớ cho Crashkernel=size,high, việc tìm kiếm là ưu tiên hàng đầu
được thử từ vùng bộ nhớ cao. Nếu việc đặt chỗ thành công,
việc đặt trước bộ nhớ thấp sẽ được thực hiện sau đó.

Nếu việc đặt trước từ bộ nhớ cao không thành công, kernel sẽ quay trở lại
tìm kiếm bộ nhớ thấp với kích thước được chỉ định trong Crashkernel=,high.
Nếu thành công thì không cần đặt trước thêm cho bộ nhớ thấp.

Ghi chú:

- Nếu Crashkernel=,low không được chỉ định, bộ nhớ thấp mặc định
  việc đặt chỗ sẽ được thực hiện tự động.

- nếu Crashkernel=0,low được chỉ định, điều đó có nghĩa là bộ nhớ thấp
  đặt phòng bị bỏ qua có chủ ý.
