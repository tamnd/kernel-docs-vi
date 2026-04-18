.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/misc-devices/xilinx_sdfec.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================
Trình điều khiển Xilinx SD-FEC
====================

Tổng quan
========

Trình điều khiển này hỗ trợ Khối tích hợp SD-FEC cho Zynq ZZ0000ZZ RFSoC.

.. |Ultrascale+ (TM)| unicode:: Ultrascale+ U+2122
   .. with trademark sign

Để biết mô tả đầy đủ về các tính năng cốt lõi của SD-FEC, hãy xem ZZ0000ZZ

Trình điều khiển này hỗ trợ các tính năng sau:

- Truy xuất thông tin trạng thái và cấu hình Khối tích hợp
  - Cấu hình mã LDPC
  - Cấu hình giải mã Turbo
  - Giám sát lỗi

Các tính năng bị thiếu, sự cố đã biết và hạn chế của trình điều khiển SD-FEC cũng như
sau:

- Chỉ cho phép một trình xử lý tệp mở duy nhất đối với bất kỳ phiên bản trình điều khiển nào vào bất kỳ lúc nào
  - Thiết lập lại Khối tích hợp SD-FEC không được điều khiển bởi trình điều khiển này
  - Không hỗ trợ tính năng bao bọc bảng mã LDPC được chia sẻ

Mục nhập cây thiết bị được mô tả trong:
ZZ0000ZZ


Phương thức hoạt động
------------------

Trình điều khiển hoạt động với lõi SD-FEC ở hai chế độ hoạt động:

- Cấu hình thời gian chạy
  - Khởi tạo logic lập trình (PL)


Cấu hình thời gian chạy
~~~~~~~~~~~~~~~~~~~~~~

Đối với cấu hình thời gian chạy, vai trò của trình điều khiển là cho phép ứng dụng phần mềm thực hiện những việc sau:

- Tải các tham số cấu hình để giải mã Turbo hoặc mã hóa hoặc giải mã LDPC
	- Kích hoạt lõi SD-FEC
	- Theo dõi lỗi lõi SD-FEC
	- Truy xuất trạng thái và cấu hình của lõi SD-FEC

Khởi tạo logic lập trình (PL)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Để khởi tạo PL, việc hỗ trợ tải các tham số cấu hình logic cho một trong hai
giải mã Turbo hoặc mã hóa hoặc giải mã LDPC.  Vai trò của người lái xe là cho phép
ứng dụng phần mềm để thực hiện những việc sau:

- Kích hoạt lõi SD-FEC
	- Theo dõi lỗi lõi SD-FEC
	- Truy xuất trạng thái và cấu hình của lõi SD-FEC


Cấu trúc trình điều khiển
================

Trình điều khiển cung cấp một thiết bị nền tảng trong đó ZZ0000ZZ và ZZ0001ZZ
hoạt động được cung cấp.

- thăm dò: Cập nhật thanh ghi cấu hình với các mục trong cây thiết bị cộng với việc xác định trạng thái kích hoạt hiện tại của lõi, ví dụ: lõi đã được bỏ qua hay lõi đã được khởi động.


Trình điều khiển xác định các thao tác tệp trình điều khiển sau để cung cấp cho người dùng
giao diện ứng dụng:

- mở: Thực hiện hạn chế rằng chỉ có thể mở một bộ mô tả tệp duy nhất cho mỗi phiên bản SD-FEC bất kỳ lúc nào
  - phát hành: Cho phép mở bộ mô tả tệp khác, nghĩa là sau khi bộ mô tả tệp hiện tại được đóng
  - thăm dò ý kiến: Cung cấp phương pháp giám sát các sự kiện Lỗi SD-FEC
  - unlock_ioctl: Cung cấp các lệnh ioctl sau cho phép ứng dụng định cấu hình lõi SD-FEC:

-ZZ0000ZZ
		-ZZ0001ZZ
		-ZZ0002ZZ
		-ZZ0003ZZ
		-ZZ0004ZZ
		-ZZ0005ZZ
		-ZZ0006ZZ
		-ZZ0007ZZ
		-ZZ0008ZZ
		-ZZ0009ZZ
		-ZZ0010ZZ
		-ZZ0011ZZ


Sử dụng trình điều khiển
============


Tổng quan
--------

Sau khi mở driver, người dùng cần tìm hiểu những thao tác cần thực hiện
được thực hiện để định cấu hình và kích hoạt lõi SD-FEC cũng như xác định
cấu hình của trình điều khiển.
Phần sau đây phác thảo quy trình người dùng nên thực hiện:

- Xác định cấu hình
  - Đặt thứ tự nếu chưa cấu hình như mong muốn
  - Đặt thông số giải mã Turbo, LPDC hoặc giải mã tùy theo cách thức
    Lõi SD-FEC được cấu hình cộng nếu SD-FEC chưa được cấu hình cho PL
    khởi tạo
  - Kích hoạt ngắt, nếu chưa được kích hoạt
  - Bỏ qua lõi SD-FEC, nếu cần
  - Khởi động lõi SD-FEC nếu chưa khởi động
  - Nhận trạng thái lõi SD-FEC
  - Giám sát ngắt
  - Dừng lõi SD-FEC


Lưu ý: Khi giám sát các ngắt nếu phát hiện thấy lỗi nghiêm trọng khi cần thiết lập lại, trình điều khiển sẽ được yêu cầu tải cấu hình mặc định.


Xác định cấu hình
-----------------------

Xác định cấu hình của lõi SD-FEC bằng cách sử dụng ioctl
ZZ0000ZZ.

Đặt thứ tự
-------------

Việc đặt thứ tự sẽ xác định thứ tự của Khối có thể thay đổi từ đầu vào đến đầu ra như thế nào.

Việc đặt thứ tự được thực hiện bằng cách sử dụng ioctl ZZ0000ZZ

Việc đặt thứ tự chỉ có thể được thực hiện nếu đáp ứng các hạn chế sau:

- Thành viên ZZ0002ZZ của struct ZZ0000ZZ được điền bởi ioctl ZZ0001ZZ cho biết lõi SD-FEC không có STARTED


Thêm mã LDPC
--------------

Các bước sau đây chỉ ra cách thêm mã LDPC vào lõi SD-FEC:

- Sử dụng các tham số được tạo tự động để điền ZZ0000ZZ cho mã LDPC mong muốn.
	- Thiết lập offset bảng SC, QA, LA cho tham số LPDC và các tham số trong cấu trúc ZZ0001ZZ
	- Đặt giá trị Code Id mong muốn trong cấu trúc ZZ0002ZZ
	- Thêm tham số mã LPDC bằng ioctl ZZ0003ZZ
	- Đối với Tham số Mã LPDC được áp dụng, hãy sử dụng hàm ZZ0004ZZ để tính toán kích thước của các bảng mã LPDC được chia sẻ. Điều này cho phép người dùng xác định cách sử dụng bảng chia sẻ để khi chọn độ lệch bảng cho các tham số mã LDPC tiếp theo, có thể chọn các vùng bảng không sử dụng.
	- Lặp lại cho từng thông số mã LDPC.

Việc thêm mã LDPC chỉ có thể được thực hiện nếu đáp ứng các hạn chế sau:

- Thành viên ZZ0006ZZ của ZZ0000ZZ được điền bởi ioctl ZZ0001ZZ cho biết lõi SD-FEC được cấu hình là LDPC
	- ZZ0007ZZ của ZZ0002ZZ được điền bởi ioctl ZZ0003ZZ cho biết tính năng bảo vệ ghi không được bật
	- Thành viên ZZ0008ZZ của struct ZZ0004ZZ được điền bởi ioctl ZZ0005ZZ cho biết lõi SD-FEC chưa khởi động

Đặt giải mã Turbo
----------------

Việc định cấu hình các tham số giải mã Turbo được thực hiện bằng cách sử dụng ioctl ZZ0000ZZ sử dụng các tham số được tạo tự động để điền ZZ0001ZZ cho mã Turbo mong muốn.

Việc thêm giải mã Turbo chỉ có thể được thực hiện nếu đáp ứng các hạn chế sau:

- Thành viên ZZ0004ZZ của ZZ0000ZZ được điền bởi ioctl ZZ0001ZZ cho biết lõi SD-FEC được cấu hình là TURBO
	- Thành viên ZZ0005ZZ của struct ZZ0002ZZ được điền bởi ioctl ZZ0003ZZ cho biết lõi SD-FEC không có STARTED

Kích hoạt ngắt
-----------------

Việc kích hoạt hoặc vô hiệu hóa các ngắt được thực hiện bằng cách sử dụng ioctl ZZ0000ZZ. Các thành viên của tham số được truyền, ZZ0001ZZ, tới ioctl được sử dụng để thiết lập và xóa các loại ngắt khác nhau. Loại ngắt được điều khiển như sau:

- ZZ0000ZZ điều khiển các ngắt ZZ0001ZZ
  - ZZ0002ZZ điều khiển các ngắt ECC

Nếu thành viên ZZ0002ZZ của ZZ0000ZZ được điền bởi ioctl ZZ0001ZZ cho biết lõi SD-FEC được định cấu hình là TURBO thì không cần phải bật lỗi ECC.

Bỏ qua SD-FEC
-----------------

Việc bỏ qua SD-FEC được thực hiện bằng cách sử dụng ioctl ZZ0000ZZ

Việc bỏ qua SD-FEC chỉ có thể được thực hiện nếu đáp ứng các hạn chế sau:

- Thành viên ZZ0002ZZ của ZZ0000ZZ được điền bởi ioctl ZZ0001ZZ cho biết lõi SD-FEC không có STARTED

Khởi động lõi SD-FEC
---------------------

Khởi động lõi SD-FEC bằng cách sử dụng ioctl ZZ0000ZZ

Nhận trạng thái SD-FEC
-----------------

Nhận trạng thái SD-FEC của thiết bị bằng cách sử dụng ioctl ZZ0000ZZ, thao tác này sẽ điền vào ZZ0001ZZ

Giám sát ngắt
----------------------

- Sử dụng cuộc gọi hệ thống thăm dò để theo dõi sự gián đoạn. Cuộc gọi hệ thống thăm dò chờ đợi một ngắt để đánh thức nó hoặc hết thời gian chờ nếu không có gián đoạn nào xảy ra.
	- Khi quay lại Thăm dò ý kiến ZZ0009ZZ sẽ cho biết liệu số liệu thống kê và/hoặc trạng thái đã được cập nhật hay chưa
		- ZZ0010ZZ báo lỗi nghiêm trọng và người dùng nên sử dụng ZZ0000ZZ và ZZ0001ZZ để xác nhận
		- ZZ0011ZZ cho biết đã xảy ra lỗi không nghiêm trọng và người dùng nên sử dụng ZZ0002ZZ để xác nhận
	- Nhận số liệu thống kê bằng cách sử dụng ioctl ZZ0003ZZ
		- Đối với lỗi nghiêm trọng, thành viên ZZ0012ZZ hoặc ZZ0013ZZ của ZZ0004ZZ khác 0
		- Đối với các lỗi không nghiêm trọng, thành viên ZZ0014ZZ của ZZ0005ZZ khác 0
	- Nhận trạng thái bằng cách sử dụng ioctl ZZ0006ZZ
		- Đối với lỗi nghiêm trọng, ZZ0015ZZ của ZZ0007ZZ sẽ cho biết Cần phải đặt lại
	- Xóa số liệu thống kê bằng cách sử dụng ioctl ZZ0008ZZ

Nếu phát hiện thấy lỗi nghiêm trọng thì cần phải thiết lập lại. Ứng dụng được yêu cầu gọi ioctl ZZ0000ZZ, sau khi thiết lập lại và không bắt buộc phải gọi ioctl ZZ0001ZZ

Lưu ý: Việc sử dụng lệnh gọi hệ thống thăm dò sẽ ngăn vòng lặp bận bằng ZZ0000ZZ và ZZ0001ZZ

Dừng lõi SD-FEC
---------------------

Dừng thiết bị bằng cách sử dụng ioctl ZZ0000ZZ

Đặt cấu hình mặc định
-----------------------------

Tải cấu hình mặc định bằng cách sử dụng ioctl ZZ0000ZZ để khôi phục trình điều khiển.

Hạn chế
-----------

Người dùng không nên sao chép trình xử lý tệp thiết bị SD-FEC, ví dụ: fork() hoặc dup() một quy trình đã tạo trình xử lý tệp SD-FEC.

Trình điều khiển IOCTL
==============

.. c:macro:: XSDFEC_START_DEV
.. kernel-doc:: include/uapi/misc/xilinx_sdfec.h
   :doc: XSDFEC_START_DEV

.. c:macro:: XSDFEC_STOP_DEV
.. kernel-doc:: include/uapi/misc/xilinx_sdfec.h
   :doc: XSDFEC_STOP_DEV

.. c:macro:: XSDFEC_GET_STATUS
.. kernel-doc:: include/uapi/misc/xilinx_sdfec.h
   :doc: XSDFEC_GET_STATUS

.. c:macro:: XSDFEC_SET_IRQ
.. kernel-doc:: include/uapi/misc/xilinx_sdfec.h
   :doc: XSDFEC_SET_IRQ

.. c:macro:: XSDFEC_SET_TURBO
.. kernel-doc:: include/uapi/misc/xilinx_sdfec.h
   :doc: XSDFEC_SET_TURBO

.. c:macro:: XSDFEC_ADD_LDPC_CODE_PARAMS
.. kernel-doc:: include/uapi/misc/xilinx_sdfec.h
   :doc: XSDFEC_ADD_LDPC_CODE_PARAMS

.. c:macro:: XSDFEC_GET_CONFIG
.. kernel-doc:: include/uapi/misc/xilinx_sdfec.h
   :doc: XSDFEC_GET_CONFIG

.. c:macro:: XSDFEC_SET_ORDER
.. kernel-doc:: include/uapi/misc/xilinx_sdfec.h
   :doc: XSDFEC_SET_ORDER

.. c:macro:: XSDFEC_SET_BYPASS
.. kernel-doc:: include/uapi/misc/xilinx_sdfec.h
   :doc: XSDFEC_SET_BYPASS

.. c:macro:: XSDFEC_IS_ACTIVE
.. kernel-doc:: include/uapi/misc/xilinx_sdfec.h
   :doc: XSDFEC_IS_ACTIVE

.. c:macro:: XSDFEC_CLEAR_STATS
.. kernel-doc:: include/uapi/misc/xilinx_sdfec.h
   :doc: XSDFEC_CLEAR_STATS

.. c:macro:: XSDFEC_GET_STATS
.. kernel-doc:: include/uapi/misc/xilinx_sdfec.h
   :doc: XSDFEC_GET_STATS

.. c:macro:: XSDFEC_SET_DEFAULT_CONFIG
.. kernel-doc:: include/uapi/misc/xilinx_sdfec.h
   :doc: XSDFEC_SET_DEFAULT_CONFIG

Định nghĩa loại trình điều khiển
=======================

.. kernel-doc:: include/uapi/misc/xilinx_sdfec.h
   :internal: