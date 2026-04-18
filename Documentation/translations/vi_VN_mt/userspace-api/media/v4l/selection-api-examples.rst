.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/selection-api-examples.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

********
Ví dụ
********

(Giả sử là một thiết bị quay video; thay đổi
ZZ0000ZZ cho các thiết bị khác; thay đổi mục tiêu thành
Họ ZZ0001ZZ để định cấu hình vùng soạn thảo)

Ví dụ: Đặt lại thông số cắt ảnh
==========================================

.. code-block:: c

	struct v4l2_selection sel = {
	    .type = V4L2_BUF_TYPE_VIDEO_CAPTURE,
	    .target = V4L2_SEL_TGT_CROP_DEFAULT,
	};
	ret = ioctl(fd, VIDIOC_G_SELECTION, &sel);
	if (ret)
	    exit(-1);
	sel.target = V4L2_SEL_TGT_CROP;
	ret = ioctl(fd, VIDIOC_S_SELECTION, &sel);
	if (ret)
	    exit(-1);

Đặt vùng soạn thảo trên đầu ra có kích thước nửa giới hạn ZZ0000ZZ
được đặt ở trung tâm của màn hình.

Ví dụ: Thu nhỏ đơn giản
===========================

.. code-block:: c

	struct v4l2_selection sel = {
	    .type = V4L2_BUF_TYPE_VIDEO_OUTPUT,
	    .target = V4L2_SEL_TGT_COMPOSE_BOUNDS,
	};
	struct v4l2_rect r;

	ret = ioctl(fd, VIDIOC_G_SELECTION, &sel);
	if (ret)
	    exit(-1);
	/* setting smaller compose rectangle */
	r.width = sel.r.width / 2;
	r.height = sel.r.height / 2;
	r.left = sel.r.width / 4;
	r.top = sel.r.height / 4;
	sel.r = r;
	sel.target = V4L2_SEL_TGT_COMPOSE;
	sel.flags = V4L2_SEL_FLAG_LE;
	ret = ioctl(fd, VIDIOC_S_SELECTION, &sel);
	if (ret)
	    exit(-1);

Giả sử có một thiết bị đầu ra video; thay đổi ZZ0000ZZ
cho các thiết bị khác

Ví dụ: Truy vấn các hệ số tỷ lệ
=====================================

.. code-block:: c

	struct v4l2_selection compose = {
	    .type = V4L2_BUF_TYPE_VIDEO_OUTPUT,
	    .target = V4L2_SEL_TGT_COMPOSE,
	};
	struct v4l2_selection crop = {
	    .type = V4L2_BUF_TYPE_VIDEO_OUTPUT,
	    .target = V4L2_SEL_TGT_CROP,
	};
	double hscale, vscale;

	ret = ioctl(fd, VIDIOC_G_SELECTION, &compose);
	if (ret)
	    exit(-1);
	ret = ioctl(fd, VIDIOC_G_SELECTION, &crop);
	if (ret)
	    exit(-1);

	/* computing scaling factors */
	hscale = (double)compose.r.width / crop.r.width;
	vscale = (double)compose.r.height / crop.r.height;