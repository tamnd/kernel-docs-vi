.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/v4l2-isp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _v4l2-isp:

*************************
Các định dạng V4L2 ISP chung
************************

Các định dạng ISP chung là các định dạng siêu dữ liệu xác định cơ chế để vượt qua ISP
các tham số và thống kê giữa không gian người dùng và trình điều khiển trong bộ đệm V4L2. Họ
được thiết kế để cho phép mở rộng chúng theo cách tương thích ngược.

Thông số ISP
==============

Định dạng tham số cấu hình ISP chung được thực hiện bằng cách xác định một
cấu trúc C đơn có chứa tiêu đề, theo sau là bộ đệm nhị phân trong đó
không gian người dùng lập trình một số lượng khác nhau của khối dữ liệu cấu hình ISP, một cho
mỗi tính năng ISP được hỗ trợ.

Cấu trúc ZZ0000ZZ xác định tiêu đề bộ đệm
theo sau là bộ đệm nhị phân của dữ liệu cấu hình ISP. Không gian người dùng sẽ
điền chính xác tiêu đề bộ đệm với phiên bản định dạng tham số chung
và với kích thước (tính bằng byte) của bộ đệm dữ liệu nhị phân nơi nó sẽ lưu trữ
Cấu hình khối ISP.

Mỗi ZZ0001ZZ được bắt đầu bằng một tiêu đề được thực hiện bởi
Cấu trúc ZZ0000ZZ, tiếp theo là cấu hình
các tham số cho khối cụ thể đó, được xác định bởi dữ liệu cụ thể của trình điều khiển ISP
các loại.

Các ứng dụng không gian người dùng chịu trách nhiệm điền chính xác từng khối
các trường tiêu đề (loại, cờ và kích thước) và các tham số dành riêng cho khối.

Kích hoạt, vô hiệu hóa và cấu hình khối ISP
-----------------------------------------------

Khi không gian người dùng muốn định cấu hình và kích hoạt khối ISP, nó phải hoàn toàn
điền cấu hình khối và đặt V4L2_ISP_PARAMS_FL_BLOCK_ENABLE
bit trong trường ZZ0000ZZ của tiêu đề khối.

Khi không gian người dùng chỉ muốn vô hiệu hóa khối ISP,
Bit V4L2_ISP_PARAMS_FL_BLOCK_DISABLE phải được đặt trong ZZ0000ZZ của tiêu đề khối
lĩnh vực. Trình điều khiển chấp nhận khối tham số cấu hình mà không cần bổ sung thêm
dữ liệu sau tiêu đề trong trường hợp này.

Nếu cần phải cập nhật cấu hình của khối ISP đã hoạt động,
không gian người dùng sẽ điền đầy đủ các tham số khối ISP và bỏ qua việc thiết lập
Các bit V4L2_ISP_PARAMS_FL_BLOCK_ENABLE và V4L2_ISP_PARAMS_FL_BLOCK_DISABLE trong
trường ZZ0000ZZ của tiêu đề.

Đặt cả V4L2_ISP_PARAMS_FL_BLOCK_ENABLE và
Các bit V4L2_ISP_PARAMS_FL_BLOCK_DISABLE trong trường cờ không được phép và
trả về một lỗi.

Có thể triển khai mở rộng định dạng tham số bằng cách thêm các khối mới
định nghĩa mà không làm mất hiệu lực những cái hiện có.

Thống kê ISP
==============

Hỗ trợ định dạng thống kê chung chưa được triển khai trong Video4Linux2.

Các loại dữ liệu uAPI V4L2 ISP
========================

.. kernel-doc:: include/uapi/linux/media/v4l2-isp.h