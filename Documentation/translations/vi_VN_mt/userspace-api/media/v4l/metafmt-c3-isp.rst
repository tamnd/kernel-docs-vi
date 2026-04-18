.. SPDX-License-Identifier: (GPL-2.0-only OR MIT)

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/metafmt-c3-isp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _v4l2-meta-fmt-c3isp-stats:
.. _v4l2-meta-fmt-c3isp-params:

*************************************************************************
V4L2_META_FMT_C3ISP_STATS ('C3ST'), V4L2_META_FMT_C3ISP_PARAMS ('C3PM')
*************************************************************************

.. c3_isp_stats_info

Thống kê 3A
=============

C3 ISP có thể thu thập các số liệu thống kê khác nhau trên khung Bayer đầu vào.
Những số liệu thống kê đó được lấy từ các nút video ghi lại siêu dữ liệu "c3-isp-stats",
sử dụng giao diện ZZ0000ZZ.
Chúng được định dạng như được mô tả bởi cấu trúc ZZ0001ZZ.

Số liệu thống kê được thu thập là Cân bằng trắng tự động,
Thông tin tự động phơi sáng và tự động lấy nét.

.. c3_isp_params_cfg

Thông số cấu hình
========================

Các tham số cấu hình được chuyển đến nút video đầu ra siêu dữ liệu c3-isp-params,
sử dụng giao diện ZZ0000ZZ. Thay vì một cấu trúc duy nhất chứa
cấu trúc phụ cho từng khu vực có thể định cấu hình của ISP, các tham số cho C3-ISP
được định nghĩa là các cấu trúc hoặc "khối" riêng biệt có thể được thêm vào dữ liệu
thành viên của ZZ0001ZZ. Không gian người dùng chịu trách nhiệm về
điền vào thành viên dữ liệu các khối cần được trình điều khiển cấu hình, nhưng
không cần phải điền vào nó các khối ZZ0005ZZ, hoặc thực sự là với bất kỳ khối nào nếu có
không có thay đổi cấu hình nào để thực hiện. Các khối dân cư ZZ0006ZZ phải liên tiếp
trong bộ đệm. Để hỗ trợ cả không gian người dùng và trình điều khiển trong việc xác định
chặn từng cấu trúc nhúng theo khối cụ thể
ZZ0002ZZ là thành viên và không gian người dùng đầu tiên
phải điền vào loại thành viên một giá trị từ
ZZ0003ZZ. Khi các khối đã được điền
vào bộ đệm dữ liệu, kích thước kết hợp của tất cả các khối được điền sẽ được đặt trong
thành viên data_size của ZZ0004ZZ. Ví dụ:

.. code-block:: c

	struct c3_isp_params_cfg *params =
		(struct c3_isp_params_cfg *)buffer;

	params->version = C3_ISP_PARAM_BUFFER_V0;
	params->data_size = 0;

	void *data = (void *)params->data;

	struct c3_isp_params_awb_gains *gains =
		(struct c3_isp_params_awb_gains *)data;

	gains->header.type = C3_ISP_PARAMS_BLOCK_AWB_GAINS;
	gains->header.flags = C3_ISP_PARAMS_BLOCK_FL_ENABLE;
	gains->header.size = sizeof(struct c3_isp_params_awb_gains);

	gains->gr_gain = 256;
	gains->r_gain = 256;
	gains->b_gain = 256;
	gains->gb_gain = 256;

	data += sizeof(struct c3_isp__params_awb_gains);
	params->data_size += sizeof(struct c3_isp_params_awb_gains);

	struct c3_isp_params_awb_config *awb_cfg =
		(struct c3_isp_params_awb_config *)data;

	awb_cfg->header.type = C3_ISP_PARAMS_BLOCK_AWB_CONFIG;
	awb_cfg->header.flags = C3_ISP_PARAMS_BLOCK_FL_ENABLE;
	awb_cfg->header.size = sizeof(struct c3_isp_params_awb_config);

	awb_cfg->tap_point = C3_ISP_AWB_STATS_TAP_BEFORE_WB;
	awb_cfg->satur = 1;
	awb_cfg->horiz_zones_num = 32;
	awb_cfg->vert_zones_num = 24;

	params->data_size += sizeof(struct c3_isp_params_awb_config);

Các loại dữ liệu uAPI của Amlogic C3 ISP
===============================

.. kernel-doc:: include/uapi/linux/media/amlogic/c3-isp-config.h