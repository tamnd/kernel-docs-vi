.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/virt/acrn/io-request.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Xử lý yêu cầu I/O
====================

Yêu cầu I/O của User VM, được xây dựng bởi hypervisor, là
được phân phối bởi Mô-đun dịch vụ ảo hóa ACRN cho máy khách I/O
tương ứng với phạm vi địa chỉ của yêu cầu I/O. Chi tiết về yêu cầu I/O
xử lý được mô tả trong các phần sau.

1. Yêu cầu vào/ra
--------------

Đối với mỗi VM người dùng, có một vùng bộ nhớ 4-KByte dùng chung được sử dụng cho các yêu cầu I/O
giao tiếp giữa hypervisor và Service VM. Một yêu cầu I/O là một
Bộ đệm cấu trúc 256 byte, là 'struct acrn_io_request', được lấp đầy bởi
trình xử lý I/O của trình ảo hóa khi xảy ra truy cập I/O bị mắc kẹt trong Người dùng
VM. Không gian người dùng ACRN trong VM dịch vụ trước tiên phân bổ trang 4-KByte và chuyển
GPA (Địa chỉ vật lý khách) của bộ đệm tới bộ ảo hóa. Bộ đệm là
được sử dụng như một mảng gồm 16 khe yêu cầu I/O với mỗi khe yêu cầu I/O là 256
byte. Mảng này được lập chỉ mục bởi vCPU ID.

2. Máy khách I/O
--------------

Một máy khách I/O chịu trách nhiệm xử lý các yêu cầu I/O VM của người dùng có quyền truy cập
GPA rơi vào một phạm vi nhất định. Nhiều máy khách I/O có thể được liên kết với mỗi máy khách
Người dùng VM. Có một ứng dụng khách đặc biệt được liên kết với mỗi VM người dùng, được gọi là
máy khách mặc định, xử lý tất cả các yêu cầu I/O không phù hợp với phạm vi
bất kỳ khách hàng nào khác. Không gian người dùng ACRN đóng vai trò là ứng dụng khách mặc định cho mỗi Người dùng
VM.

Hình minh họa dưới đây cho thấy mối quan hệ giữa bộ đệm chia sẻ yêu cầu I/O,
Các yêu cầu I/O và các máy khách I/O.

::

+-------------------------------------------------------------------+
     ZZ0000ZZ
     ZZ0001ZZ
     |ZZ0002ZZ |
     |ZZ0003ZZ trang chia sẻ ACRN không gian người dùng ZZ0004ZZ |
     |ZZ0005ZZ +-----------------+ +-------------+ ZZ0006ZZ |
     |ZZ0007ZZ acrn_io_request ZZ0008ZZ ZZ0009ZZ |
     |ZZ0010ZZ ZZ0011ZZ +-----------------+ ZZ0012ZZ ZZ0013ZZ |
     |ZZ0014ZZ ZZ0015ZZ ZZ0016ZZ +-------------+ ZZ0017ZZ |
     |ZZ0018ZZ ZZ0019ZZ +-----------------+ ZZ0020ZZ |
     |ZZ0021ZZ +-ZZ0022ZZ |
     |ZZ0023ZZ----ZZ0024ZZ |
     |ZZ0025ZZ ZZ0026ZZ |
     |ZZ0027ZZ ZZ0028ZZ |
     |ZZ0029ZZ ZZ0030ZZ +-------------+ HSM ZZ0031ZZ |
     |ZZ0032ZZ +--------------+ ZZ0033ZZ ZZ0034ZZ
     |ZZ0035ZZ ZZ0036ZZ Máy khách I/O ZZ0037ZZ ZZ0038ZZ
     |ZZ0039ZZ ZZ0040ZZ ZZ0041ZZ ZZ0042ZZ
     |ZZ0043ZZ ZZ0044ZZ ZZ0045ZZ
     |ZZ0046ZZ +----------------------+ ZZ0047ZZ
     ZZ0048ZZ----------------------------------------------+ |
     +------|-------------------------------------------------+
          |
     +------|-------------------------------------------------+
     ZZ0049ZZ
     Bộ xử lý I/O ZZ0050ZZ ZZ0051ZZ
     ZZ0052ZZ
     +-------------------------------------------------------------------+

3. Chuyển đổi trạng thái yêu cầu I/O
-------------------------------

Quá trình chuyển đổi trạng thái của yêu cầu I/O ACRN như sau.

::

FREE -> PENDING -> PROCESSING -> COMPLETE -> FREE -> ...

- FREE: Khe yêu cầu I/O này trống
- PENDING: yêu cầu I/O hợp lệ đang chờ xử lý trong khe này
- PROCESSING: yêu cầu I/O đang được xử lý
- COMPLETE: yêu cầu I/O đã được xử lý

Yêu cầu I/O ở trạng thái COMPLETE hoặc FREE thuộc sở hữu của bộ ảo hóa. HSM và
Không gian người dùng ACRN chịu trách nhiệm xử lý các không gian khác.

4. Xử lý luồng yêu cầu I/O
----------------------------------

Một. Trình xử lý I/O của hypervisor sẽ thực hiện yêu cầu I/O bằng PENDING
   trạng thái khi xảy ra truy cập I/O bị kẹt trong VM người dùng.
b. Trình ảo hóa thực hiện lệnh gọi lên, tức là ngắt thông báo, tới
   máy ảo dịch vụ.
c. Trình xử lý upcall lên lịch cho một nhân viên gửi các yêu cầu I/O.
d. Nhân viên tìm kiếm các yêu cầu I/O PENDING, gán chúng cho các yêu cầu khác nhau
   khách hàng đã đăng ký dựa trên địa chỉ truy cập I/O, cập nhật
   trạng thái của chúng thành PROCESSING và thông báo cho máy khách tương ứng để xử lý.
đ. Máy khách được thông báo sẽ xử lý các yêu cầu I/O được chỉ định.
f. HSM cập nhật các trạng thái yêu cầu I/O thành COMPLETE và thông báo cho bộ ảo hóa
   về việc hoàn thành thông qua siêu lệnh gọi.