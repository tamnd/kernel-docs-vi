.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/arm/pkvm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
KVM được bảo vệ (pKVM)
======================

ZZ0000ZZ: pKVM hiện là một tính năng thử nghiệm, phát triển và
có thể có những thay đổi đột phá khi các tính năng cách ly mới được triển khai.
Vui lòng liên hệ với các nhà phát triển tại kvmarm@lists.linux.dev nếu bạn có
bất kỳ câu hỏi nào.

Tổng quan
=========

Khởi động kernel máy chủ bằng 'ZZ0000ZZ' cho phép
"KVM được bảo vệ" (pKVM). Trong quá trình khởi động, pKVM cài đặt nhận dạng giai đoạn 2
ánh xạ bảng trang cho máy chủ và sử dụng nó để cô lập bộ ảo hóa
chạy ở EL2 từ phần còn lại của máy chủ đang chạy ở EL1/0.

pKVM cho phép tạo các máy ảo được bảo vệ (pVM) bằng cách chuyển
mã định danh loại máy ZZ0000ZZ cho
ZZ0001ZZ ioctl(). Trình ảo hóa sẽ cô lập các pVM khỏi máy chủ bằng cách
hủy ánh xạ các trang khỏi bản đồ nhận dạng giai đoạn 2 khi chúng được truy cập bởi một
pVM. Hypercalls được cung cấp cho một pVM để chia sẻ các vùng cụ thể của nó
IPA lùi lại không gian với máy chủ, cho phép liên lạc với VMM.
Một máy khách Linux phải được cấu hình với ZZ0002ZZ trong
để phát hành các siêu cuộc gọi này.

Xem hypercalls.rst để biết thêm chi tiết.

Cơ chế cách ly
====================

pKVM dựa vào một số cơ chế để cách ly PVM khỏi máy chủ:

Cách ly bộ nhớ CPU
--------------------

Trạng thái: Cô lập các trang siêu dữ liệu và bộ nhớ ẩn danh.

Các trang siêu dữ liệu (ví dụ: các trang bảng trang và trang 'ZZ0000ZZ')
được tặng từ máy chủ cho bộ ảo hóa trong quá trình tạo pVM và
do đó không được ánh xạ khỏi bản đồ nhận dạng giai đoạn 2 cho đến khi pVM được
bị phá hủy.

Tương tự như KVM thông thường, các trang được ánh xạ một cách lười biếng vào khách trong
phản hồi các lỗi trang giai đoạn 2 do máy chủ xử lý. Tuy nhiên, khi
đang chạy pVM, những trang này trước tiên sẽ được ghim và sau đó được hủy ánh xạ khỏi
bản đồ nhận dạng giai đoạn 2 như một phần của thủ tục quyên góp. Điều này làm nảy sinh
đến một số khác biệt mà người dùng có thể nhận thấy khi so sánh với các máy ảo không được bảo vệ,
phần lớn là do thiếu trình thông báo MMU:

* Không thể di chuyển hoặc xóa Memslot khi pVM đã bắt đầu chạy.
* Các khe ghi nhớ chỉ đọc và ghi nhật ký bẩn không được hỗ trợ.
* Ngoại trừ trao đổi, các trang được sao lưu bằng tệp không thể được ánh xạ vào một
  pVM.
* Các trang quyên góp được tính vào ZZ0000ZZ và VMM
  phải có đủ giới hạn tài nguyên hoặc được cấp ZZ0001ZZ.
  Việc thiếu cơ chế lấy lại thời gian chạy có nghĩa là bộ nhớ bị khóa trong
  pVM sẽ vẫn bị khóa cho đến khi pVM bị hủy.
* Thay đổi không gian địa chỉ VMM (ví dụ: ZZ0002ZZ mmap() trên
  ánh xạ liên kết với một memslot) không được phản ánh trong máy khách và
  có thể dẫn đến mất đi sự thống nhất.
* Truy cập bộ nhớ pVM chưa được chia sẻ lại sẽ dẫn đến
  giao SIGSEGV.
* Nếu cuộc gọi hệ thống truy cập bộ nhớ pVM chưa được chia sẻ lại
  sau đó nó sẽ trả về ZZ0003ZZ hoặc cưỡng bức đòi lại
  trang ký ức. Bộ nhớ được thu hồi sẽ bị xóa bởi hypervisor và một
  lần thử truy cập tiếp theo trong pVM sẽ trả về ZZ0004ZZ
  từ ZZ0005ZZ ioctl().

Cách ly trạng thái CPU
----------------------

Trạng thái: ZZ0000ZZ

Cách ly DMA bằng IOMMU
----------------------------

Trạng thái: ZZ0000ZZ

Ủy quyền các dịch vụ Trustzone
------------------------------

Trạng thái: Các cuộc gọi FF-A và PSCI từ máy chủ được pKVM ủy quyền
siêu giám sát.

Proxy FF-A đảm bảo rằng máy chủ không thể chia sẻ pVM hoặc bộ ảo hóa
bộ nhớ với Trustzone như một phần của cuộc tấn công "cấp phó bối rối".

Proxy PSCI đảm bảo CPU luôn có bản đồ nhận dạng giai đoạn 2
được cài đặt khi chúng đang thực thi trên máy chủ.

Phần mềm máy ảo được bảo vệ (pvmfw)
-----------------------------------

Trạng thái: ZZ0000ZZ

Tài nguyên
==========

Buổi nói chuyện trên Diễn đàn KVM năm 2022 của Quentin Perret có tựa đề "KVM được bảo vệ trên arm64: A
chuyên sâu về kỹ thuật" vẫn là một nguồn tài nguyên tốt để tìm hiểu thêm về
pKVM, mặc dù một số chi tiết đã thay đổi trong thời gian này:

ZZ0000ZZ