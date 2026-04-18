.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/metafmt-intel-ipu3.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _v4l2-meta-fmt-params:
.. _v4l2-meta-fmt-stat-3a:

**********************************************************************
V4L2_META_FMT_IPU3_PARAMS ('ip3p'), V4L2_META_FMT_IPU3_3A ('ip3s')
******************************************************************

.. ipu3_uapi_stats_3a

thống kê 3A
=============

Bộ tăng tốc thống kê IPU3 ImgU 3A thu thập các số liệu thống kê khác nhau trên
khung Bayer đầu vào. Những số liệu thống kê đó được lấy từ "ipu3-imgu [01] 3a
stat" ghi lại các nút video siêu dữ liệu, sử dụng ZZ0000ZZ
giao diện. Chúng được định dạng như mô tả của ZZ0001ZZ
cấu trúc.

Số liệu thống kê được thu thập là AWB (Cân bằng trắng tự động) RGBS (Đỏ, Xanh lục, Xanh lam và
đo độ bão hòa), phản hồi bộ lọc AWB, phản hồi bộ lọc AF (Tự động lấy nét),
và biểu đồ AE (Tự động phơi sáng).

Cấu trúc ZZ0000ZZ lưu tất cả các tham số có thể định cấu hình.

.. code-block:: c

	struct ipu3_uapi_stats_3a {
		struct ipu3_uapi_awb_raw_buffer awb_raw_buffer;
		struct ipu3_uapi_ae_raw_buffer_aligned ae_raw_buffer[IPU3_UAPI_MAX_STRIPES];
		struct ipu3_uapi_af_raw_buffer af_raw_buffer;
		struct ipu3_uapi_awb_fr_raw_buffer awb_fr_raw_buffer;
		struct ipu3_uapi_4a_config stats_4a_config;
		__u32 ae_join_buffers;
		__u8 padding[28];
		struct ipu3_uapi_stats_3a_bubble_info_per_stripe stats_3a_bubble_per_stripe;
		struct ipu3_uapi_ff_status stats_3a_status;
	};

.. ipu3_uapi_params

Thông số đường ống
===================

Các tham số đường ống được chuyển tới siêu dữ liệu "tham số ipu3-imgu [01]"
các nút video đầu ra, sử dụng giao diện ZZ0000ZZ. Họ là
được định dạng như được mô tả bởi cấu trúc ZZ0001ZZ.

Cả số liệu thống kê 3A và thông số quy trình được mô tả ở đây đều gắn chặt với
API của hệ thống con máy ảnh cơ bản (CSS). Chúng thường được tiêu thụ và
được tạo ra bởi các thư viện không gian người dùng chuyên dụng bao gồm các điều chỉnh quan trọng
công cụ, do đó giải phóng các nhà phát triển khỏi bị làm phiền với mức độ thấp
chi tiết về phần cứng và thuật toán.

.. code-block:: c

	struct ipu3_uapi_params {
		/* Flags which of the settings below are to be applied */
		struct ipu3_uapi_flags use;

		/* Accelerator cluster parameters */
		struct ipu3_uapi_acc_param acc_param;

		/* ISP vector address space parameters */
		struct ipu3_uapi_isp_lin_vmem_params lin_vmem_params;
		struct ipu3_uapi_isp_tnr3_vmem_params tnr3_vmem_params;
		struct ipu3_uapi_isp_xnr3_vmem_params xnr3_vmem_params;

		/* ISP data memory (DMEM) parameters */
		struct ipu3_uapi_isp_tnr3_params tnr3_dmem_params;
		struct ipu3_uapi_isp_xnr3_params xnr3_dmem_params;

		/* Optical black level compensation */
		struct ipu3_uapi_obgrid_param obgrid_param;
	};

Các loại dữ liệu uAPI Intel IPU3 ImgU
===============================

.. kernel-doc:: drivers/staging/media/ipu3/include/uapi/intel-ipu3.h