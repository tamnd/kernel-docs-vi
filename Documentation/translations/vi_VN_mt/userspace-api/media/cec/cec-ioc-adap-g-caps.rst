.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/cec/cec-ioc-adap-g-caps.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: CEC

.. _CEC_ADAP_G_CAPS:

**********************
ioctl CEC_ADAP_G_CAPS
**********************

Tên
====

CEC_ADAP_G_CAPS - Khả năng của thiết bị truy vấn

Tóm tắt
========

.. c:macro:: CEC_ADAP_G_CAPS

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ

Sự miêu tả
===========

Tất cả các thiết bị cec phải hỗ trợ ZZ0000ZZ. Để truy vấn
thông tin thiết bị, các ứng dụng gọi ioctl bằng một con trỏ tới
cấu trúc ZZ0001ZZ. Trình điều khiển lấp đầy cấu trúc và
trả lại thông tin cho ứng dụng. Ioctl không bao giờ thất bại.

.. tabularcolumns:: |p{1.2cm}|p{2.5cm}|p{13.6cm}|

.. c:type:: cec_caps

.. flat-table:: struct cec_caps
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 16

    * - char
      - ``driver[32]``
      - The name of the cec adapter driver.
    * - char
      - ``name[32]``
      - The name of this CEC adapter. The combination ``driver`` and
	``name`` must be unique.
    * - __u32
      - ``available_log_addrs``
      - The maximum number of logical addresses that can be configured.
    * - __u32
      - ``capabilities``
      - The capabilities of the CEC adapter, see
	:ref:`cec-capabilities`.
    * - __u32
      - ``version``
      - CEC Framework API version, formatted with the ``KERNEL_VERSION()``
	macro.

.. tabularcolumns:: |p{4.4cm}|p{2.5cm}|p{10.4cm}|

.. _cec-capabilities:

.. flat-table:: CEC Capabilities Flags
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 8

    * .. _`CEC-CAP-PHYS-ADDR`:

      - ``CEC_CAP_PHYS_ADDR``
      - 0x00000001
      - Userspace has to configure the physical address by calling
	:ref:`ioctl CEC_ADAP_S_PHYS_ADDR <CEC_ADAP_S_PHYS_ADDR>`. If
	this capability isn't set, then setting the physical address is
	handled by the kernel whenever the EDID is set (for an HDMI
	receiver) or read (for an HDMI transmitter).
    * .. _`CEC-CAP-LOG-ADDRS`:

      - ``CEC_CAP_LOG_ADDRS``
      - 0x00000002
      - Userspace has to configure the logical addresses by calling
	:ref:`ioctl CEC_ADAP_S_LOG_ADDRS <CEC_ADAP_S_LOG_ADDRS>`. If
	this capability isn't set, then the kernel will have configured
	this.
    * .. _`CEC-CAP-TRANSMIT`:

      - ``CEC_CAP_TRANSMIT``
      - 0x00000004
      - Userspace can transmit CEC messages by calling
	:ref:`ioctl CEC_TRANSMIT <CEC_TRANSMIT>`. This implies that
	userspace can be a follower as well, since being able to transmit
	messages is a prerequisite of becoming a follower. If this
	capability isn't set, then the kernel will handle all CEC
	transmits and process all CEC messages it receives.
    * .. _`CEC-CAP-PASSTHROUGH`:

      - ``CEC_CAP_PASSTHROUGH``
      - 0x00000008
      - Userspace can use the passthrough mode by calling
	:ref:`ioctl CEC_S_MODE <CEC_S_MODE>`.
    * .. _`CEC-CAP-RC`:

      - ``CEC_CAP_RC``
      - 0x00000010
      - This adapter supports the remote control protocol.
    * .. _`CEC-CAP-MONITOR-ALL`:

      - ``CEC_CAP_MONITOR_ALL``
      - 0x00000020
      - The CEC hardware can monitor all messages, not just directed and
	broadcast messages.
    * .. _`CEC-CAP-NEEDS-HPD`:

      - ``CEC_CAP_NEEDS_HPD``
      - 0x00000040
      - The CEC hardware is only active if the HDMI Hotplug Detect pin is
        high. This makes it impossible to use CEC to wake up displays that
	set the HPD pin low when in standby mode, but keep the CEC bus
	alive.
    * .. _`CEC-CAP-MONITOR-PIN`:

      - ``CEC_CAP_MONITOR_PIN``
      - 0x00000080
      - The CEC hardware can monitor CEC pin changes from low to high voltage
        and vice versa. When in pin monitoring mode the application will
	receive ``CEC_EVENT_PIN_CEC_LOW`` and ``CEC_EVENT_PIN_CEC_HIGH`` events.
    * .. _`CEC-CAP-CONNECTOR-INFO`:

      - ``CEC_CAP_CONNECTOR_INFO``
      - 0x00000100
      - If this capability is set, then :ref:`CEC_ADAP_G_CONNECTOR_INFO` can
        be used.
    * .. _`CEC-CAP-REPLY-VENDOR-ID`:

      - ``CEC_CAP_REPLY_VENDOR_ID``
      - 0x00000200
      - If this capability is set, then
        :ref:`CEC_MSG_FL_REPLY_VENDOR_ID <cec-msg-flags>` can be used.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.