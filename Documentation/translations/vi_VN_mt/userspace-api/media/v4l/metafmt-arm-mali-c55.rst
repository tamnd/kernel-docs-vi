.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/metafmt-arm-mali-c55.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _v4l2-meta-fmt-mali-c55-params:
.. _v4l2-meta-fmt-mali-c55-stats:

**********************************************************************************
V4L2_META_FMT_MALI_C55_STATS ('C55S'), V4L2_META_FMT_MALI_C55_PARAMS ('C55P')
*****************************************************************************

Thống kê 3A
=============

Thiết bị ISP thu thập số liệu thống kê khác nhau trên khung bayer đầu vào. Những cái đó
số liệu thống kê có thể được lấy bởi không gian người dùng từ
Nút video ghi siêu dữ liệu ZZ0000ZZ, sử dụng
giao diện ZZ0001ZZ. Bộ đệm chứa một phiên bản duy nhất
của cấu trúc C ZZ0002ZZ được xác định trong
ZZ0003ZZ, do đó cấu trúc có thể được lấy từ bộ đệm bằng cách:

.. code-block:: C

	struct mali_c55_stats_buffer *stats =
		(struct mali_c55_stats_buffer *)buf;

Để biết chi tiết về số liệu thống kê, hãy xem ZZ0000ZZ.

Thông số cấu hình
========================

Các tham số cấu hình được chuyển đến nút video đầu ra siêu dữ liệu ZZ0000ZZ bằng cách sử dụng
Giao diện ZZ0001ZZ. Thay vì một cấu trúc duy nhất chứa
cấu trúc phụ cho từng khu vực có thể định cấu hình của ISP, các tham số cho Mali-C55
sử dụng hệ thống tham số v4l2-isp, qua đó các nhóm tham số được
được định nghĩa là các cấu trúc hoặc "khối" riêng biệt có thể được thêm vào thành viên dữ liệu của
ZZ0002ZZ. Không gian người dùng chịu trách nhiệm điền vào
thành viên dữ liệu với các khối cần được cấu hình bởi trình điều khiển.  Mỗi
cấu trúc dành riêng cho khối nhúng ZZ0003ZZ làm đầu tiên
thành viên và không gian người dùng phải điền vào loại thành viên một giá trị từ
ZZ0004ZZ.

.. code-block:: c

	struct v4l2_isp_params_buffer *params =
		(struct v4l2_isp_params_buffer *)buffer;

	params->version = V4L2_ISP_PARAMS_VERSION_V1;
	params->data_size = 0;

	void *data = (void *)params->data;

	struct mali_c55_params_awb_gains *gains =
		(struct mali_c55_params_awb_gains *)data;

	gains->header.type = MALI_C55_PARAM_BLOCK_AWB_GAINS;
	gains->header.flags |= V4L2_ISP_PARAMS_FL_BLOCK_ENABLE;
	gains->header.size = sizeof(struct mali_c55_params_awb_gains);

	gains->gain00 = 256;
	gains->gain00 = 256;
	gains->gain00 = 256;
	gains->gain00 = 256;

	data += sizeof(struct mali_c55_params_awb_gains);
	params->data_size += sizeof(struct mali_c55_params_awb_gains);

	struct mali_c55_params_sensor_off_preshading *blc =
		(struct mali_c55_params_sensor_off_preshading *)data;

	blc->header.type = MALI_C55_PARAM_BLOCK_SENSOR_OFFS;
	blc->header.flags |= V4L2_ISP_PARAMS_FL_BLOCK_ENABLE;
	blc->header.size = sizeof(struct mali_c55_params_sensor_off_preshading);

	blc->chan00 = 51200;
	blc->chan01 = 51200;
	blc->chan10 = 51200;
	blc->chan11 = 51200;

	params->data_size += sizeof(struct mali_c55_params_sensor_off_preshading);

Loại dữ liệu uAPI của Mali-C55
============================

.. kernel-doc:: include/uapi/linux/media/arm/mali-c55-config.h