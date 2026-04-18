.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/tee/amd-tee.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================================
AMD-TEE (Môi trường thực thi đáng tin cậy của AMD)
==================================================

Trình điều khiển AMD-TEE xử lý giao tiếp với môi trường TEE của AMD. các
Môi trường TEE được cung cấp bởi Bộ xử lý bảo mật AMD.

Bộ xử lý bảo mật AMD (trước đây gọi là Bộ xử lý bảo mật nền tảng hoặc PSP)
là bộ xử lý chuyên dụng có công nghệ ARM TrustZone, cùng với
Môi trường thực thi tin cậy dựa trên phần mềm (TEE) được thiết kế để cho phép
Ứng dụng đáng tin cậy của bên thứ ba. Tính năng này hiện chỉ được kích hoạt cho
APU.

Hình ảnh sau đây hiển thị tổng quan cấp cao về AMD-TEE::

|
    x86 |
                                             |
 Không gian người dùng (Kernel space) |    Bộ xử lý bảo mật AMD (PSP)
 ~~~~~~~~~~ ~~~~~~~~~~~~~~~~ |    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                                             |
 +--------+ |       +-------------+
 ZZ0000ZZ ZZ0001ZZ đáng tin cậy |
 +--------+ Ứng dụng ZZ0002ZZ |
     /\ |       +-------------+
     |ZZ0003ZZ /\
     |ZZ0004ZZ ||
     |ZZ0005ZZ \/
     |ZZ0006ZZ +----------+
     |ZZ0007ZZ ZZ0008ZZ
     |ZZ0009ZZ ZZ0010ZZ
     \/ ZZ0011ZZ API |
 +----------+ +-----------+---------+ +----------+
 ZZ0012ZZ ZZ0013ZZ AMD-TEE ZZ0014ZZ AMD-TEE |
 Trình điều khiển ZZ0015ZZ ZZ0016ZZ ZZ0017ZZ đáng tin cậy |
 Hệ điều hành ZZ0018ZZ ZZ0019ZZ ZZ0020ZZ |
 +----------+----------+------+------+----------+----------+----------+
 Hộp thư ZZ0021ZZ ZZ0022ZZ |
 ZZ0023ZZ ZZ0024ZZ Đăng ký giao thức |
 +--------------------------+ +----------+--------------------+

Ở mức thấp nhất (trong x86), trình điều khiển Bộ xử lý bảo mật AMD (ASP) sử dụng
Đăng ký hộp thư CPU tới PSP để gửi lệnh tới PSP. Định dạng của
bộ đệm lệnh không rõ ràng đối với trình điều khiển ASP. Vai trò của nó là gửi lệnh tới
bộ xử lý an toàn và trả kết quả về trình điều khiển AMD-TEE. Giao diện
Bạn có thể tìm thấy giữa trình điều khiển AMD-TEE và trình điều khiển Bộ xử lý bảo mật AMD trong [1].

Trình điều khiển AMD-TEE đóng gói tải trọng bộ đệm lệnh để xử lý trong TEE.
Định dạng bộ đệm lệnh cho các lệnh TEE khác nhau có thể được tìm thấy trong [2].

Các lệnh TEE được hệ điều hành đáng tin cậy AMD-TEE hỗ trợ là:

* TEE_CMD_ID_LOAD_TA - tải tệp nhị phân Ứng dụng đáng tin cậy (TA) vào
                                Môi trường TEE.
* TEE_CMD_ID_UNLOAD_TA - dỡ nhị phân TA khỏi môi trường TEE.
* TEE_CMD_ID_OPEN_SESSION - mở phiên có TA được tải.
* TEE_CMD_ID_CLOSE_SESSION - đóng phiên với TA đã tải
* TEE_CMD_ID_INVOKE_CMD - gọi lệnh có TA được tải
* TEE_CMD_ID_MAP_SHARED_MEM - bản đồ bộ nhớ dùng chung
* TEE_CMD_ID_UNMAP_SHARED_MEM - giải phóng bộ nhớ dùng chung

Hệ điều hành đáng tin cậy AMD-TEE là chương trình cơ sở chạy trên Bộ xử lý bảo mật AMD.

Trình điều khiển AMD-TEE tự đăng ký với hệ thống con TEE và thực hiện
gọi lại chức năng trình điều khiển sau đây:

* get_version - trả về id và khả năng triển khai trình điều khiển.
* open - thiết lập cấu trúc dữ liệu ngữ cảnh trình điều khiển.
* phát hành - giải phóng tài nguyên trình điều khiển.
* open_session - tải tệp nhị phân TA và mở phiên có TA đã tải.
* close_session - đóng phiên với TA đã tải và dỡ nó ra.
*gọi_func - gọi lệnh có TA được tải.

Lệnh gọi lại trình điều khiển cancel_req không được AMD-TEE hỗ trợ.

GlobalPlatform TEE Client API [3] có thể được sử dụng bởi không gian người dùng (máy khách) để
nói chuyện với TEE của AMD. TEE của AMD cung cấp một môi trường an toàn để tải, mở
một phiên, gọi lệnh và kết thúc phiên bằng TA.

Tài liệu tham khảo
==========

[1] bao gồm/linux/psp-tee.h

[2] trình điều khiển/tee/amdtee/amdtee_if.h

[3] ZZ0000ZZ tìm kiếm
    "TEE Client API Thông số kỹ thuật v1.0" và nhấp vào tải xuống.