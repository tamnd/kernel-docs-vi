.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/metafmt-rkisp1.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _v4l2-meta-fmt-rk-isp1-stat-3a:

********************************************************************************************************************************
V4L2_META_FMT_RK_ISP1_PARAMS ('rk1p'), V4L2_META_FMT_RK_ISP1_STAT_3A ('rk1s'), V4L2_META_FMT_RK_ISP1_EXT_PARAMS ('rk1e')
************************************************************************************************************************

===========================
Thông số cấu hình
========================

Cấu hình của RkISP1 ISP được thực hiện bởi không gian người dùng bằng cách cung cấp
thông số của ISP tới driver sử dụng ZZ0000ZZ
giao diện.

Có hai phương pháp cho phép định cấu hình ISP, ZZ0000ZZ
định dạng cấu hình và cấu hình ZZ0001ZZ
định dạng.

.. _v4l2-meta-fmt-rk-isp1-params:

Định dạng cấu hình tham số cố định
=====================================

Khi sử dụng định dạng cấu hình cố định, các tham số sẽ được chuyển tới
Nút video đầu ra siêu dữ liệu ZZ0000ZZ, sử dụng
định dạng meta ZZ0001ZZ.

Bộ đệm chứa một phiên bản duy nhất của cấu trúc C
ZZ0000ZZ được định nghĩa trong ZZ0001ZZ. Vì vậy kết cấu có thể
được lấy từ bộ đệm bằng cách:

.. code-block:: c

	struct rkisp1_params_cfg *params = (struct rkisp1_params_cfg*) buffer;

Phương pháp này chỉ hỗ trợ một tập hợp con các tính năng của ISP, các ứng dụng mới sẽ
sử dụng phương pháp tham số mở rộng.

.. _v4l2-meta-fmt-rk-isp1-ext-params:

Định dạng cấu hình tham số mở rộng
==========================================

Khi sử dụng định dạng cấu hình mở rộng, các tham số sẽ được chuyển tới
Nút video đầu ra siêu dữ liệu ZZ0000ZZ, sử dụng
định dạng meta ZZ0001ZZ.

Bộ đệm chứa một phiên bản duy nhất của cấu trúc C
ZZ0000ZZ được định nghĩa trong ZZ0002ZZ. các
Cấu trúc ZZ0001ZZ được thiết kế để cho phép không gian người dùng
điền vào bộ đệm dữ liệu chỉ dữ liệu cấu hình cho ISP chặn nó
có ý định cấu hình. Thiết kế định dạng tham số mở rộng cho phép các nhà phát triển
để xác định các loại khối mới nhằm hỗ trợ các tham số cấu hình mới và xác định một
lược đồ phiên bản để nó có thể được mở rộng và phiên bản mà không bị hỏng
khả năng tương thích với các ứng dụng hiện có.

Vì những lý do này, phương pháp cấu hình này được ưu tiên hơn phương pháp thay thế định dạng ZZ0000ZZ.

.. rkisp1_stat_buffer

==============================
Thống kê 3A và biểu đồ
===========================

Thiết bị ISP1 thu thập số liệu thống kê khác nhau trên khung Bayer đầu vào.
Những số liệu thống kê đó được lấy từ ZZ0000ZZ
nút video ghi siêu dữ liệu,
sử dụng giao diện ZZ0001ZZ. Bộ đệm chứa một
phiên bản của cấu trúc C ZZ0002ZZ được xác định trong
ZZ0003ZZ. Vì vậy, cấu trúc có thể được lấy từ bộ đệm bằng cách:

.. code-block:: c

	struct rkisp1_stat_buffer *stats = (struct rkisp1_stat_buffer*) buffer;

Số liệu thống kê được thu thập là Phơi sáng, AWB (Cân bằng trắng tự động), Biểu đồ và
AF (Tự động lấy nét). Xem ZZ0000ZZ để biết chi tiết về số liệu thống kê.

Các thông số thống kê và cấu hình 3A được mô tả ở đây thường là
được sử dụng và sản xuất bởi các thư viện không gian người dùng chuyên dụng bao gồm
công cụ điều chỉnh quan trọng bằng cách sử dụng vòng điều khiển phần mềm.

kiểu dữ liệu uAPI rkisp1
======================

.. kernel-doc:: include/uapi/linux/rkisp1-config.h