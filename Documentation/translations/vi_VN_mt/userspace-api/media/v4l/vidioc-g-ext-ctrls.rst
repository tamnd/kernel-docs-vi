.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-g-ext-ctrls.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_G_EXT_CTRLS:

**********************************************************************
ioctl VIDIOC_G_EXT_CTRLS, VIDIOC_S_EXT_CTRLS, VIDIOC_TRY_EXT_CTRLS
**********************************************************************

Tên
====

VIDIOC_G_EXT_CTRLS - VIDIOC_S_EXT_CTRLS - VIDIOC_TRY_EXT_CTRLS - Nhận hoặc đặt giá trị của một số điều khiển, thử các giá trị điều khiển

Tóm tắt
========

.. c:macro:: VIDIOC_G_EXT_CTRLS

ZZ0000ZZ

.. c:macro:: VIDIOC_S_EXT_CTRLS

ZZ0000ZZ

.. c:macro:: VIDIOC_TRY_EXT_CTRLS

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Các ioctls này cho phép người gọi nhận hoặc đặt nhiều điều khiển
về mặt nguyên tử. ID điều khiển được nhóm thành các lớp điều khiển (xem
ZZ0000ZZ) và tất cả các điều khiển trong mảng điều khiển phải thuộc về
vào cùng một lớp điều khiển.

Các ứng dụng phải luôn điền vào ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ
và các trường ZZ0005ZZ của cấu trúc
ZZ0000ZZ và khởi tạo
mảng cấu trúc ZZ0001ZZ được trỏ tới
bởi các trường ZZ0006ZZ.

To get the current value of a set of controls applications initialize
các trường ZZ0002ZZ, ZZ0003ZZ và ZZ0004ZZ của mỗi cấu trúc
ZZ0000ZZ và gọi
ZZ0001ZZ ioctl. Điều khiển chuỗi cũng phải đặt
Trường ZZ0005ZZ. Kiểm soát các loại hợp chất
(ZZ0006ZZ được đặt) phải đặt trường ZZ0007ZZ.

Nếu ZZ0001ZZ quá nhỏ để nhận được kết quả kiểm soát (chỉ
liên quan đến các điều khiển kiểu con trỏ như chuỗi), thì trình điều khiển sẽ
đặt ZZ0002ZZ thành giá trị hợp lệ và trả về mã lỗi ZZ0003ZZ. bạn
nên phân bổ lại bộ nhớ cho kích thước mới này và thử lại. Đối với
loại chuỗi, có thể vấn đề tương tự lại xảy ra nếu
chuỗi đã phát triển trong khi chờ đợi. Nên gọi
ZZ0000ZZ đầu tiên và sử dụng
ZZ0004ZZ\ +1 làm giá trị ZZ0005ZZ mới. Nó được đảm bảo rằng đó là
đủ bộ nhớ.

Mảng N chiều được thiết lập và truy xuất theo từng hàng. Bạn không thể thiết lập một
mảng một phần, tất cả các phần tử phải được đặt hoặc truy xuất. Tổng kích thước
được tính là ZZ0001ZZ * ZZ0002ZZ. Những giá trị này có thể thu được
bằng cách gọi ZZ0000ZZ.

Để thay đổi giá trị của một tập hợp các ứng dụng điều khiển, hãy khởi tạo
Các trường ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ và ZZ0005ZZ
của mỗi cấu trúc ZZ0000ZZ và gọi
ZZ0001ZZ ioctl. Các điều khiển sẽ chỉ được đặt nếu ZZ0006ZZ
giá trị kiểm soát là hợp lệ.

Để kiểm tra xem một bộ điều khiển có giá trị chính xác hay không
khởi tạo ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ và
Các trường ZZ0005ZZ của mỗi cấu trúc
ZZ0000ZZ và gọi
ZZ0001ZZ ioctl. Sai hay sai là ở người lái xe
các giá trị được tự động điều chỉnh thành giá trị hợp lệ hoặc nếu có lỗi
đã quay trở lại.

Khi ZZ0001ZZ hoặc ZZ0002ZZ không hợp lệ, trình điều khiển sẽ trả về lỗi ZZ0003ZZ
mã. Khi giá trị vượt quá giới hạn, người lái xe có thể chọn thực hiện
giá trị hợp lệ gần nhất hoặc trả về mã lỗi ZZ0004ZZ, bất cứ điều gì có vẻ nhiều hơn
thích hợp. Trong trường hợp đầu tiên, giá trị mới được đặt trong struct
ZZ0000ZZ. Nếu giá trị điều khiển mới
không phù hợp (ví dụ: chỉ mục menu đã cho không được menu hỗ trợ
control), thì điều này cũng sẽ dẫn đến lỗi mã lỗi ZZ0005ZZ.

Nếu ZZ0002ZZ được đặt thành ZZ0000ZZ chưa được xếp hàng
bộ mô tả tập tin và ZZ0003ZZ được đặt thành ZZ0004ZZ,
thì các điều khiển không được áp dụng ngay khi gọi
ZZ0001ZZ, nhưng thay vào đó được áp dụng bởi
trình điều khiển cho bộ đệm được liên kết với cùng một yêu cầu.
Nếu thiết bị không hỗ trợ yêu cầu thì ZZ0005ZZ sẽ được trả về.
Nếu yêu cầu được hỗ trợ nhưng mô tả tệp yêu cầu không hợp lệ được cung cấp,
sau đó ZZ0006ZZ sẽ được trả lại.

Nỗ lực gọi ZZ0000ZZ để lấy
yêu cầu đã được xếp hàng đợi sẽ dẫn đến lỗi ZZ0001ZZ.

Nếu ZZ0001ZZ được chỉ định và ZZ0002ZZ được đặt thành
ZZ0003ZZ trong khi gọi tới
ZZ0000ZZ, sau đó nó sẽ trả về
giá trị của các điều khiển tại thời điểm hoàn thành yêu cầu.
Nếu yêu cầu chưa được hoàn thành thì điều này sẽ dẫn đến
Lỗi ZZ0004ZZ.

Trình điều khiển sẽ chỉ đặt/nhận các điều khiển này nếu tất cả các giá trị điều khiển đều được
đúng. Điều này ngăn ngừa tình trạng chỉ có một số điều khiển
đã được thiết lập/nhận. Chỉ các lỗi ở mức độ thấp (ví dụ: lệnh i2c bị lỗi) mới có thể
vẫn gây ra tình trạng này.

.. tabularcolumns:: |p{6.8cm}|p{4.0cm}|p{6.5cm}|

.. c:type:: v4l2_ext_control

.. raw:: latex

   \footnotesize

.. cssclass:: longtable

.. flat-table:: struct v4l2_ext_control
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``id``
      - Identifies the control, set by the application.
    * - __u32
      - ``size``
      - The total size in bytes of the payload of this control.
    * - :cspan:`2` The ``size`` field is normally 0, but for pointer
	controls this should be set to the size of the memory that contains
	the payload or that will receive the payload.
	If :ref:`VIDIOC_G_EXT_CTRLS <VIDIOC_G_EXT_CTRLS>` finds that this value
	is less than is required to store the payload result, then it is set
	to a value large enough to store the payload result and ``ENOSPC`` is
	returned.

	.. note::

	   For string controls, this ``size`` field should
	   not be confused with the length of the string. This field refers
	   to the size of the memory that contains the string. The actual
	   *length* of the string may well be much smaller.
    * - __u32
      - ``reserved2``\ [1]
      - Reserved for future extensions. Drivers and applications must set
	the array to zero.
    * - union {
      - (anonymous)
    * - __s32
      - ``value``
      - New value or current value. Valid if this control is not of type
	``V4L2_CTRL_TYPE_INTEGER64`` and ``V4L2_CTRL_FLAG_HAS_PAYLOAD`` is
	not set.
    * - __s64
      - ``value64``
      - New value or current value. Valid if this control is of type
	``V4L2_CTRL_TYPE_INTEGER64`` and ``V4L2_CTRL_FLAG_HAS_PAYLOAD`` is
	not set.
    * - char *
      - ``string``
      - A pointer to a string. Valid if this control is of type
	``V4L2_CTRL_TYPE_STRING``.
    * - __u8 *
      - ``p_u8``
      - A pointer to a matrix control of unsigned 8-bit values. Valid if
	this control is of type ``V4L2_CTRL_TYPE_U8``.
    * - __u16 *
      - ``p_u16``
      - A pointer to a matrix control of unsigned 16-bit values. Valid if
	this control is of type ``V4L2_CTRL_TYPE_U16``.
    * - __u32 *
      - ``p_u32``
      - A pointer to a matrix control of unsigned 32-bit values. Valid if
	this control is of type ``V4L2_CTRL_TYPE_U32``.
    * - __s32 *
      - ``p_s32``
      - A pointer to a matrix control of signed 32-bit values. Valid if
        this control is of type ``V4L2_CTRL_TYPE_INTEGER`` and
        ``V4L2_CTRL_FLAG_HAS_PAYLOAD`` is set.
    * - __s64 *
      - ``p_s64``
      - A pointer to a matrix control of signed 64-bit values. Valid if
        this control is of type ``V4L2_CTRL_TYPE_INTEGER64`` and
        ``V4L2_CTRL_FLAG_HAS_PAYLOAD`` is set.
    * - struct :c:type:`v4l2_area` *
      - ``p_area``
      - A pointer to a struct :c:type:`v4l2_area`. Valid if this control is
        of type ``V4L2_CTRL_TYPE_AREA``.
    * - struct :c:type:`v4l2_rect` *
      - ``p_rect``
      - A pointer to a struct :c:type:`v4l2_rect`. Valid if this control is
        of type ``V4L2_CTRL_TYPE_RECT``.
    * - struct :c:type:`v4l2_ctrl_h264_sps` *
      - ``p_h264_sps``
      - A pointer to a struct :c:type:`v4l2_ctrl_h264_sps`. Valid if this control is
        of type ``V4L2_CTRL_TYPE_H264_SPS``.
    * - struct :c:type:`v4l2_ctrl_h264_pps` *
      - ``p_h264_pps``
      - A pointer to a struct :c:type:`v4l2_ctrl_h264_pps`. Valid if this control is
        of type ``V4L2_CTRL_TYPE_H264_PPS``.
    * - struct :c:type:`v4l2_ctrl_h264_scaling_matrix` *
      - ``p_h264_scaling_matrix``
      - A pointer to a struct :c:type:`v4l2_ctrl_h264_scaling_matrix`. Valid if this control is
        of type ``V4L2_CTRL_TYPE_H264_SCALING_MATRIX``.
    * - struct :c:type:`v4l2_ctrl_h264_pred_weights` *
      - ``p_h264_pred_weights``
      - A pointer to a struct :c:type:`v4l2_ctrl_h264_pred_weights`. Valid if this control is
        of type ``V4L2_CTRL_TYPE_H264_PRED_WEIGHTS``.
    * - struct :c:type:`v4l2_ctrl_h264_slice_params` *
      - ``p_h264_slice_params``
      - A pointer to a struct :c:type:`v4l2_ctrl_h264_slice_params`. Valid if this control is
        of type ``V4L2_CTRL_TYPE_H264_SLICE_PARAMS``.
    * - struct :c:type:`v4l2_ctrl_h264_decode_params` *
      - ``p_h264_decode_params``
      - A pointer to a struct :c:type:`v4l2_ctrl_h264_decode_params`. Valid if this control is
        of type ``V4L2_CTRL_TYPE_H264_DECODE_PARAMS``.
    * - struct :c:type:`v4l2_ctrl_fwht_params` *
      - ``p_fwht_params``
      - A pointer to a struct :c:type:`v4l2_ctrl_fwht_params`. Valid if this control is
        of type ``V4L2_CTRL_TYPE_FWHT_PARAMS``.
    * - struct :c:type:`v4l2_ctrl_vp8_frame` *
      - ``p_vp8_frame``
      - A pointer to a struct :c:type:`v4l2_ctrl_vp8_frame`. Valid if this control is
        of type ``V4L2_CTRL_TYPE_VP8_FRAME``.
    * - struct :c:type:`v4l2_ctrl_mpeg2_sequence` *
      - ``p_mpeg2_sequence``
      - A pointer to a struct :c:type:`v4l2_ctrl_mpeg2_sequence`. Valid if this control is
        of type ``V4L2_CTRL_TYPE_MPEG2_SEQUENCE``.
    * - struct :c:type:`v4l2_ctrl_mpeg2_picture` *
      - ``p_mpeg2_picture``
      - A pointer to a struct :c:type:`v4l2_ctrl_mpeg2_picture`. Valid if this control is
        of type ``V4L2_CTRL_TYPE_MPEG2_PICTURE``.
    * - struct :c:type:`v4l2_ctrl_mpeg2_quantisation` *
      - ``p_mpeg2_quantisation``
      - A pointer to a struct :c:type:`v4l2_ctrl_mpeg2_quantisation`. Valid if this control is
        of type ``V4L2_CTRL_TYPE_MPEG2_QUANTISATION``.
    * - struct :c:type:`v4l2_ctrl_vp9_compressed_hdr` *
      - ``p_vp9_compressed_hdr_probs``
      - A pointer to a struct :c:type:`v4l2_ctrl_vp9_compressed_hdr`. Valid if this
        control is of type ``V4L2_CTRL_TYPE_VP9_COMPRESSED_HDR``.
    * - struct :c:type:`v4l2_ctrl_vp9_frame` *
      - ``p_vp9_frame``
      - A pointer to a struct :c:type:`v4l2_ctrl_vp9_frame`. Valid if this
        control is of type ``V4L2_CTRL_TYPE_VP9_FRAME``.
    * - struct :c:type:`v4l2_ctrl_hdr10_cll_info` *
      - ``p_hdr10_cll``
      - A pointer to a struct :c:type:`v4l2_ctrl_hdr10_cll_info`. Valid if this control is
        of type ``V4L2_CTRL_TYPE_HDR10_CLL_INFO``.
    * - struct :c:type:`v4l2_ctrl_hdr10_mastering_display` *
      - ``p_hdr10_mastering``
      - A pointer to a struct :c:type:`v4l2_ctrl_hdr10_mastering_display`. Valid if this control is
        of type ``V4L2_CTRL_TYPE_HDR10_MASTERING_DISPLAY``.
    * - struct :c:type:`v4l2_ctrl_hevc_sps` *
      - ``p_hevc_sps``
      - A pointer to a struct :c:type:`v4l2_ctrl_hevc_sps`. Valid if this
        control is of type ``V4L2_CTRL_TYPE_HEVC_SPS``.
    * - struct :c:type:`v4l2_ctrl_hevc_pps` *
      - ``p_hevc_pps``
      - A pointer to a struct :c:type:`v4l2_ctrl_hevc_pps`. Valid if this
        control is of type ``V4L2_CTRL_TYPE_HEVC_PPS``.
    * - struct :c:type:`v4l2_ctrl_hevc_slice_params` *
      - ``p_hevc_slice_params``
      - A pointer to a struct :c:type:`v4l2_ctrl_hevc_slice_params`. Valid if this
        control is of type ``V4L2_CTRL_TYPE_HEVC_SLICE_PARAMS``.
    * - struct :c:type:`v4l2_ctrl_hevc_scaling_matrix` *
      - ``p_hevc_scaling_matrix``
      - A pointer to a struct :c:type:`v4l2_ctrl_hevc_scaling_matrix`. Valid if this
        control is of type ``V4L2_CTRL_TYPE_HEVC_SCALING_MATRIX``.
    * - struct :c:type:`v4l2_ctrl_hevc_decode_params` *
      - ``p_hevc_decode_params``
      - A pointer to a struct :c:type:`v4l2_ctrl_hevc_decode_params`. Valid if this
        control is of type ``V4L2_CTRL_TYPE_HEVC_DECODE_PARAMS``.
    * - struct :c:type:`v4l2_ctrl_av1_sequence` *
      - ``p_av1_sequence``
      - A pointer to a struct :c:type:`v4l2_ctrl_av1_sequence`. Valid if this control is
        of type ``V4L2_CTRL_TYPE_AV1_SEQUENCE``.
    * - struct :c:type:`v4l2_ctrl_av1_tile_group_entry` *
      - ``p_av1_tile_group_entry``
      - A pointer to a struct :c:type:`v4l2_ctrl_av1_tile_group_entry`. Valid if this control is
        of type ``V4L2_CTRL_TYPE_AV1_TILE_GROUP_ENTRY``.
    * - struct :c:type:`v4l2_ctrl_av1_frame` *
      - ``p_av1_frame``
      - A pointer to a struct :c:type:`v4l2_ctrl_av1_frame`. Valid if this control is
        of type ``V4L2_CTRL_TYPE_AV1_FRAME``.
    * - struct :c:type:`v4l2_ctrl_av1_film_grain` *
      - ``p_av1_film_grain``
      - A pointer to a struct :c:type:`v4l2_ctrl_av1_film_grain`. Valid if this control is
        of type ``V4L2_CTRL_TYPE_AV1_FILM_GRAIN``.
    * - struct :c:type:`v4l2_ctrl_hdr10_cll_info` *
      - ``p_hdr10_cll_info``
      - A pointer to a struct :c:type:`v4l2_ctrl_hdr10_cll_info`. Valid if this control is
        of type ``V4L2_CTRL_TYPE_HDR10_CLL_INFO``.
    * - struct :c:type:`v4l2_ctrl_hdr10_mastering_display` *
      - ``p_hdr10_mastering_display``
      - A pointer to a struct :c:type:`v4l2_ctrl_hdr10_mastering_display`. Valid if this control is
        of type ``V4L2_CTRL_TYPE_HDR10_MASTERING_DISPLAY``.
    * - void *
      - ``ptr``
      - A pointer to a compound type which can be an N-dimensional array
	and/or a compound type (the control's type is >=
	``V4L2_CTRL_COMPOUND_TYPES``). Valid if
	``V4L2_CTRL_FLAG_HAS_PAYLOAD`` is set for this control.
    * - }
      -

.. raw:: latex

   \normalsize

.. tabularcolumns:: |p{4.0cm}|p{2.5cm}|p{10.8cm}|

.. c:type:: v4l2_ext_controls

.. cssclass:: longtable

.. flat-table:: struct v4l2_ext_controls
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - union {
      - (anonymous)
    * - __u32
      - ``which``
      - Which value of the control to get/set/try.
    * - :cspan:`2` ``V4L2_CTRL_WHICH_CUR_VAL`` will return the current value of
	the control, ``V4L2_CTRL_WHICH_DEF_VAL`` will return the default
	value of the control, ``V4L2_CTRL_WHICH_MIN_VAL`` will return the minimum
	value of the control, and ``V4L2_CTRL_WHICH_MAX_VAL`` will return the maximum
	value of the control. ``V4L2_CTRL_WHICH_REQUEST_VAL`` indicates that
	the control value has to be retrieved from a request or tried/set for
	a request. In that case the ``request_fd`` field contains the
	file descriptor of the request that should be used. If the device
	does not support requests, then ``EACCES`` will be returned.

	When using ``V4L2_CTRL_WHICH_DEF_VAL``, ``V4L2_CTRL_WHICH_MIN_VAL``
	or ``V4L2_CTRL_WHICH_MAX_VAL`` be aware that you can only get the
	default/minimum/maximum value of the control, you cannot set or try it.

	Whether a control supports querying the minimum and maximum values using
	``V4L2_CTRL_WHICH_MIN_VAL`` and ``V4L2_CTRL_WHICH_MAX_VAL`` is indicated
	by the ``V4L2_CTRL_FLAG_HAS_WHICH_MIN_MAX`` flag. Most non-compound
	control types support this. For controls with compound types, the
	definition of minimum/maximum values are provided by
	the control documentation. If a compound control does not document the
	meaning of minimum/maximum value, then querying the minimum or maximum
	value will result in the error code -EINVAL.

	For backwards compatibility you can also use a control class here
	(see :ref:`ctrl-class`). In that case all controls have to
	belong to that control class. This usage is deprecated, instead
	just use ``V4L2_CTRL_WHICH_CUR_VAL``. There are some very old
	drivers that do not yet support ``V4L2_CTRL_WHICH_CUR_VAL`` and
	that require a control class here. You can test for such drivers
	by setting ``which`` to ``V4L2_CTRL_WHICH_CUR_VAL`` and calling
	:ref:`VIDIOC_TRY_EXT_CTRLS <VIDIOC_G_EXT_CTRLS>` with a count of 0.
	If that fails, then the driver does not support ``V4L2_CTRL_WHICH_CUR_VAL``.
    * - __u32
      - ``ctrl_class``
      - Deprecated name kept for backwards compatibility. Use ``which`` instead.
    * - }
      -
    * - __u32
      - ``count``
      - The number of controls in the controls array. May also be zero.
    * - __u32
      - ``error_idx``
      - Index of the failing control. Set by the driver in case of an error.
    * - :cspan:`2` If the error is associated
	with a particular control, then ``error_idx`` is set to the index
	of that control. If the error is not related to a specific
	control, or the validation step failed (see below), then
	``error_idx`` is set to ``count``. The value is undefined if the
	ioctl returned 0 (success).

	Before controls are read from/written to hardware a validation
	step takes place: this checks if all controls in the list are
	valid controls, if no attempt is made to write to a read-only
	control or read from a write-only control, and any other up-front
	checks that can be done without accessing the hardware. The exact
	validations done during this step are driver dependent since some
	checks might require hardware access for some devices, thus making
	it impossible to do those checks up-front. However, drivers should
	make a best-effort to do as many up-front checks as possible.

	This check is done to avoid leaving the hardware in an
	inconsistent state due to easy-to-avoid problems. But it leads to
	another problem: the application needs to know whether an error
	came from the validation step (meaning that the hardware was not
	touched) or from an error during the actual reading from/writing
	to hardware.

	The, in hindsight quite poor, solution for that is to set
	``error_idx`` to ``count`` if the validation failed. This has the
	unfortunate side-effect that it is not possible to see which
	control failed the validation. If the validation was successful
	and the error happened while accessing the hardware, then
	``error_idx`` is less than ``count`` and only the controls up to
	``error_idx-1`` were read or written correctly, and the state of
	the remaining controls is undefined.

	Since :ref:`VIDIOC_TRY_EXT_CTRLS <VIDIOC_G_EXT_CTRLS>` does not access hardware there is
	also no need to handle the validation step in this special way, so
	``error_idx`` will just be set to the control that failed the
	validation step instead of to ``count``. This means that if
	:ref:`VIDIOC_S_EXT_CTRLS <VIDIOC_G_EXT_CTRLS>` fails with ``error_idx`` set to ``count``,
	then you can call :ref:`VIDIOC_TRY_EXT_CTRLS <VIDIOC_G_EXT_CTRLS>` to try to discover the
	actual control that failed the validation step. Unfortunately,
	there is no ``TRY`` equivalent for :ref:`VIDIOC_G_EXT_CTRLS <VIDIOC_G_EXT_CTRLS>`.
    * - __s32
      - ``request_fd``
      - File descriptor of the request to be used by this operation. Only
	valid if ``which`` is set to ``V4L2_CTRL_WHICH_REQUEST_VAL``.
	If the device does not support requests, then ``EACCES`` will be returned.
	If requests are supported but an invalid request file descriptor is
	given, then ``EINVAL`` will be returned.
    * - __u32
      - ``reserved``\ [1]
      - Reserved for future extensions.

	Drivers and applications must set the array to zero.
    * - struct :c:type:`v4l2_ext_control` *
      - ``controls``
      - Pointer to an array of ``count`` v4l2_ext_control structures.

	Ignored if ``count`` equals zero.

.. tabularcolumns:: |p{7.3cm}|p{2.0cm}|p{8.0cm}|

.. cssclass:: longtable

.. _ctrl-class:

.. flat-table:: Control classes
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * - ``V4L2_CTRL_CLASS_USER``
      - 0x980000
      - The class containing user controls. These controls are described
	in :ref:`control`. All controls that can be set using the
	:ref:`VIDIOC_S_CTRL <VIDIOC_G_CTRL>` and
	:ref:`VIDIOC_G_CTRL <VIDIOC_G_CTRL>` ioctl belong to this
	class.
    * - ``V4L2_CTRL_CLASS_CODEC``
      - 0x990000
      - The class containing stateful codec controls. These controls are
	described in :ref:`codec-controls`.
    * - ``V4L2_CTRL_CLASS_CAMERA``
      - 0x9a0000
      - The class containing camera controls. These controls are described
	in :ref:`camera-controls`.
    * - ``V4L2_CTRL_CLASS_FM_TX``
      - 0x9b0000
      - The class containing FM Transmitter (FM TX) controls. These
	controls are described in :ref:`fm-tx-controls`.
    * - ``V4L2_CTRL_CLASS_FLASH``
      - 0x9c0000
      - The class containing flash device controls. These controls are
	described in :ref:`flash-controls`.
    * - ``V4L2_CTRL_CLASS_JPEG``
      - 0x9d0000
      - The class containing JPEG compression controls. These controls are
	described in :ref:`jpeg-controls`.
    * - ``V4L2_CTRL_CLASS_IMAGE_SOURCE``
      - 0x9e0000
      - The class containing image source controls. These controls are
	described in :ref:`image-source-controls`.
    * - ``V4L2_CTRL_CLASS_IMAGE_PROC``
      - 0x9f0000
      - The class containing image processing controls. These controls are
	described in :ref:`image-process-controls`.
    * - ``V4L2_CTRL_CLASS_FM_RX``
      - 0xa10000
      - The class containing FM Receiver (FM RX) controls. These controls
	are described in :ref:`fm-rx-controls`.
    * - ``V4L2_CTRL_CLASS_RF_TUNER``
      - 0xa20000
      - The class containing RF tuner controls. These controls are
	described in :ref:`rf-tuner-controls`.
    * - ``V4L2_CTRL_CLASS_DETECT``
      - 0xa30000
      - The class containing motion or object detection controls. These controls
        are described in :ref:`detect-controls`.
    * - ``V4L2_CTRL_CLASS_CODEC_STATELESS``
      - 0xa40000
      - The class containing stateless codec controls. These controls are
	described in :ref:`codec-stateless-controls`.
    * - ``V4L2_CTRL_CLASS_COLORIMETRY``
      - 0xa50000
      - The class containing colorimetry controls. These controls are
	described in :ref:`colorimetry-controls`.

Giá trị trả về
==============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Cấu trúc ZZ0000ZZ ZZ0005ZZ là
    không hợp lệ hoặc cấu trúc ZZ0001ZZ
    ZZ0006ZZ không hợp lệ hoặc cấu trúc
    ZZ0002ZZ ZZ0007ZZ là
    không phù hợp (ví dụ: chỉ mục menu đã cho không được hỗ trợ bởi
    trình điều khiển) hoặc trường ZZ0008ZZ được đặt thành ZZ0009ZZ
    nhưng ZZ0010ZZ đã cho không hợp lệ hoặc ZZ0011ZZ
    không được hỗ trợ bởi kernel.
    Mã lỗi này cũng được trả về bởi
    ZZ0003ZZ và ZZ0004ZZ ioctls nếu hai hoặc
    nhiều giá trị điều khiển đang xung đột.

ERANGE
    Cấu trúc ZZ0000ZZ ZZ0001ZZ
    đã vượt quá giới hạn.

EBUSY
    Việc điều khiển tạm thời không thể thay đổi được, có thể do nguyên nhân khác
    các ứng dụng đã chiếm quyền kiểm soát chức năng của thiết bị điều khiển này
    thuộc về hoặc (nếu trường ZZ0000ZZ được đặt thành
    ZZ0001ZZ) yêu cầu đã được xếp hàng đợi nhưng chưa
    hoàn thành.

ENOSPC
    Không gian dành riêng cho tải trọng của điều khiển không đủ. các
    trường ZZ0000ZZ được đặt thành giá trị đủ để lưu trữ tải trọng
    và mã lỗi này được trả về.

EACCES
    Cố gắng thử hoặc đặt điều khiển chỉ đọc hoặc để có được điều khiển chỉ ghi
    kiểm soát hoặc để có được quyền kiểm soát từ một yêu cầu chưa được
    hoàn thành.

Hoặc trường ZZ0000ZZ được đặt thành ZZ0001ZZ nhưng
    thiết bị không hỗ trợ yêu cầu.

Hoặc nếu có nỗ lực thiết lập một điều khiển không hoạt động và trình điều khiển
    không có khả năng lưu vào bộ đệm giá trị mới cho đến khi điều khiển được kích hoạt trở lại.