.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/cec/cec-ioc-g-mode.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: CEC

.. _CEC_MODE:
.. _CEC_G_MODE:
.. _CEC_S_MODE:

********************************
ioctls CEC_G_MODE và CEC_S_MODE
********************************

CEC_G_MODE, CEC_S_MODE - Nhận hoặc đặt quyền sử dụng độc quyền bộ chuyển đổi CEC

Tóm tắt
========

.. c:macro:: CEC_G_MODE

ZZ0000ZZ

.. c:macro:: CEC_S_MODE

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ
    Con trỏ tới chế độ CEC.

Sự miêu tả
===========

Theo mặc định, bất kỳ tước hiệu tệp nào cũng có thể sử dụng ZZ0000ZZ, nhưng để ngăn chặn
các ứng dụng khỏi việc dẫm lên ngón chân của nhau thì phải có thể
có quyền truy cập độc quyền vào bộ chuyển đổi CEC. Ioctl này thiết lập
filehandle sang chế độ khởi tạo và/hoặc chế độ theo dõi có thể độc quyền
tùy theo chế độ đã chọn. Bộ khởi tạo là filehandle
được sử dụng để bắt đầu tin nhắn, tức là nó ra lệnh cho các thiết bị CEC khác. các
người theo dõi là filehandle nhận tin nhắn được gửi đến CEC
adapter và xử lý chúng. Cùng một tước hiệu tệp có thể vừa là người khởi tạo
và người theo dõi, hoặc vai trò này có thể được đảm nhận bởi hai tước hiệu tệp khác nhau.

Khi nhận được tin nhắn CEC, khung CEC sẽ quyết định cách thức
nó sẽ được xử lý. Nếu tin nhắn là câu trả lời trước đó
tin nhắn được truyền đi, sau đó phản hồi sẽ được gửi trở lại filehandle
đang chờ đợi nó. Ngoài ra, khung CEC sẽ xử lý nó.

Nếu tin nhắn không phải là phản hồi thì khung CEC sẽ xử lý nó
đầu tiên. Nếu không có người theo dõi thì tin nhắn sẽ bị loại bỏ và
việc hủy bỏ tính năng sẽ được gửi lại cho người khởi tạo nếu khung không thể
xử lý nó. Nếu có người theo dõi thì tin nhắn sẽ được chuyển đến
người theo dõi sẽ sử dụng ZZ0000ZZ để dequeue
tin nhắn mới. Khuôn khổ kỳ vọng người theo sau sẽ làm đúng
các quyết định.

Khung CEC sẽ xử lý các tin nhắn cốt lõi trừ khi có yêu cầu khác
bởi người theo dõi. Người theo dõi có thể kích hoạt chế độ chuyển tiếp. Trong đó
trường hợp, khung CEC sẽ truyền hầu hết các thông điệp cốt lõi mà không cần
xử lý chúng và người theo dõi sẽ phải thực hiện những thông báo đó.
Có một số thông báo mà lõi sẽ luôn xử lý, bất kể
chế độ xuyên suốt. Xem ZZ0000ZZ để biết chi tiết.

Nếu không có trình khởi tạo thì bất kỳ tước hiệu tệp CEC nào cũng có thể sử dụng
ZZ0000ZZ. Nếu có độc quyền
người khởi xướng thì chỉ người khởi xướng đó mới có thể gọi
ZZ0001ZZ. Tất nhiên người theo dõi có thể
luôn gọi ZZ0002ZZ.

Các chế độ khởi tạo có sẵn là:

.. tabularcolumns:: |p{5.6cm}|p{0.9cm}|p{10.8cm}|

.. _cec-mode-initiator_e:

.. flat-table:: Initiator Modes
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 16

    * .. _`CEC-MODE-NO-INITIATOR`:

      - ``CEC_MODE_NO_INITIATOR``
      - 0x0
      - This is not an initiator, i.e. it cannot transmit CEC messages or
	make any other changes to the CEC adapter.
    * .. _`CEC-MODE-INITIATOR`:

      - ``CEC_MODE_INITIATOR``
      - 0x1
      - This is an initiator (the default when the device is opened) and
	it can transmit CEC messages and make changes to the CEC adapter,
	unless there is an exclusive initiator.
    * .. _`CEC-MODE-EXCL-INITIATOR`:

      - ``CEC_MODE_EXCL_INITIATOR``
      - 0x2
      - This is an exclusive initiator and this file descriptor is the
	only one that can transmit CEC messages and make changes to the
	CEC adapter. If someone else is already the exclusive initiator
	then an attempt to become one will return the ``EBUSY`` error code
	error.

Các chế độ theo dõi có sẵn là:

.. tabularcolumns:: |p{6.6cm}|p{0.9cm}|p{9.8cm}|

.. _cec-mode-follower_e:

.. cssclass:: longtable

.. flat-table:: Follower Modes
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 16

    * .. _`CEC-MODE-NO-FOLLOWER`:

      - ``CEC_MODE_NO_FOLLOWER``
      - 0x00
      - This is not a follower (the default when the device is opened).
    * .. _`CEC-MODE-FOLLOWER`:

      - ``CEC_MODE_FOLLOWER``
      - 0x10
      - This is a follower and it will receive CEC messages unless there
	is an exclusive follower. You cannot become a follower if
	:ref:`CEC_CAP_TRANSMIT <CEC-CAP-TRANSMIT>` is not set or if :ref:`CEC_MODE_NO_INITIATOR <CEC-MODE-NO-INITIATOR>`
	was specified, the ``EINVAL`` error code is returned in that case.
    * .. _`CEC-MODE-EXCL-FOLLOWER`:

      - ``CEC_MODE_EXCL_FOLLOWER``
      - 0x20
      - This is an exclusive follower and only this file descriptor will
	receive CEC messages for processing. If someone else is already
	the exclusive follower then an attempt to become one will return
	the ``EBUSY`` error code. You cannot become a follower if
	:ref:`CEC_CAP_TRANSMIT <CEC-CAP-TRANSMIT>` is not set or if :ref:`CEC_MODE_NO_INITIATOR <CEC-MODE-NO-INITIATOR>`
	was specified, the ``EINVAL`` error code is returned in that case.
    * .. _`CEC-MODE-EXCL-FOLLOWER-PASSTHRU`:

      - ``CEC_MODE_EXCL_FOLLOWER_PASSTHRU``
      - 0x30
      - This is an exclusive follower and only this file descriptor will
	receive CEC messages for processing. In addition it will put the
	CEC device into passthrough mode, allowing the exclusive follower
	to handle most core messages instead of relying on the CEC
	framework for that. If someone else is already the exclusive
	follower then an attempt to become one will return the ``EBUSY`` error
	code. You cannot become a follower if :ref:`CEC_CAP_TRANSMIT <CEC-CAP-TRANSMIT>`
	is not set or if :ref:`CEC_MODE_NO_INITIATOR <CEC-MODE-NO-INITIATOR>` was specified,
	the ``EINVAL`` error code is returned in that case.
    * .. _`CEC-MODE-MONITOR-PIN`:

      - ``CEC_MODE_MONITOR_PIN``
      - 0xd0
      - Put the file descriptor into pin monitoring mode. Can only be used in
	combination with :ref:`CEC_MODE_NO_INITIATOR <CEC-MODE-NO-INITIATOR>`,
	otherwise the ``EINVAL`` error code will be returned.
	This mode requires that the :ref:`CEC_CAP_MONITOR_PIN <CEC-CAP-MONITOR-PIN>`
	capability is set, otherwise the ``EINVAL`` error code is returned.
	While in pin monitoring mode this file descriptor can receive the
	``CEC_EVENT_PIN_CEC_LOW`` and ``CEC_EVENT_PIN_CEC_HIGH`` events to see the
	low-level CEC pin transitions. This is very useful for debugging.
	This mode is only allowed if the process has the ``CAP_NET_ADMIN``
	capability. If that is not set, then the ``EPERM`` error code is returned.
    * .. _`CEC-MODE-MONITOR`:

      - ``CEC_MODE_MONITOR``
      - 0xe0
      - Put the file descriptor into monitor mode. Can only be used in
	combination with :ref:`CEC_MODE_NO_INITIATOR <CEC-MODE-NO-INITIATOR>`,
	otherwise the ``EINVAL`` error code will be returned.
	In monitor mode all messages this CEC
	device transmits and all messages it receives (both broadcast
	messages and directed messages for one its logical addresses) will
	be reported. This is very useful for debugging. This is only
	allowed if the process has the ``CAP_NET_ADMIN`` capability. If
	that is not set, then the ``EPERM`` error code is returned.
    * .. _`CEC-MODE-MONITOR-ALL`:

      - ``CEC_MODE_MONITOR_ALL``
      - 0xf0
      - Put the file descriptor into 'monitor all' mode. Can only be used
	in combination with :ref:`CEC_MODE_NO_INITIATOR <CEC-MODE-NO-INITIATOR>`, otherwise
	the ``EINVAL`` error code will be returned. In 'monitor all' mode all messages
	this CEC device transmits and all messages it receives, including
	directed messages for other CEC devices, will be reported. This is
	very useful for debugging, but not all devices support this. This
	mode requires that the :ref:`CEC_CAP_MONITOR_ALL <CEC-CAP-MONITOR-ALL>` capability is set,
	otherwise the ``EINVAL`` error code is returned. This is only allowed if
	the process has the ``CAP_NET_ADMIN`` capability. If that is not
	set, then the ``EPERM`` error code is returned.

Chi tiết xử lý thông điệp cốt lõi:

.. tabularcolumns:: |p{6.6cm}|p{10.9cm}|

.. _cec-core-processing:

.. flat-table:: Core Message Processing
    :header-rows:  0
    :stub-columns: 0
    :widths: 1 8

    * .. _`CEC-MSG-GET-CEC-VERSION`:

      - ``CEC_MSG_GET_CEC_VERSION``
      - The core will return the CEC version that was set with
	:ref:`ioctl CEC_ADAP_S_LOG_ADDRS <CEC_ADAP_S_LOG_ADDRS>`,
	except when in passthrough mode. In passthrough mode the core
	does nothing and this message has to be handled by a follower
	instead.
    * .. _`CEC-MSG-GIVE-DEVICE-VENDOR-ID`:

      - ``CEC_MSG_GIVE_DEVICE_VENDOR_ID``
      - The core will return the vendor ID that was set with
	:ref:`ioctl CEC_ADAP_S_LOG_ADDRS <CEC_ADAP_S_LOG_ADDRS>`,
	except when in passthrough mode. In passthrough mode the core
	does nothing and this message has to be handled by a follower
	instead.
    * .. _`CEC-MSG-ABORT`:

      - ``CEC_MSG_ABORT``
      - The core will return a Feature Abort message with reason
        'Feature Refused' as per the specification, except when in
	passthrough mode. In passthrough mode the core does nothing
	and this message has to be handled by a follower instead.
    * .. _`CEC-MSG-GIVE-PHYSICAL-ADDR`:

      - ``CEC_MSG_GIVE_PHYSICAL_ADDR``
      - The core will report the current physical address, except when
        in passthrough mode. In passthrough mode the core does nothing
	and this message has to be handled by a follower instead.
    * .. _`CEC-MSG-GIVE-OSD-NAME`:

      - ``CEC_MSG_GIVE_OSD_NAME``
      - The core will report the current OSD name that was set with
	:ref:`ioctl CEC_ADAP_S_LOG_ADDRS <CEC_ADAP_S_LOG_ADDRS>`,
	except when in passthrough mode. In passthrough mode the core
	does nothing and this message has to be handled by a follower
	instead.
    * .. _`CEC-MSG-GIVE-FEATURES`:

      - ``CEC_MSG_GIVE_FEATURES``
      - The core will do nothing if the CEC version is older than 2.0,
        otherwise it will report the current features that were set with
	:ref:`ioctl CEC_ADAP_S_LOG_ADDRS <CEC_ADAP_S_LOG_ADDRS>`,
	except when in passthrough mode. In passthrough mode the core
	does nothing (for any CEC version) and this message has to be handled
	by a follower instead.
    * .. _`CEC-MSG-USER-CONTROL-PRESSED`:

      - ``CEC_MSG_USER_CONTROL_PRESSED``
      - If :ref:`CEC_CAP_RC <CEC-CAP-RC>` is set and if
        :ref:`CEC_LOG_ADDRS_FL_ALLOW_RC_PASSTHRU <CEC-LOG-ADDRS-FL-ALLOW-RC-PASSTHRU>`
	is set, then generate a remote control key
	press. This message is always passed on to the follower(s).
    * .. _`CEC-MSG-USER-CONTROL-RELEASED`:

      - ``CEC_MSG_USER_CONTROL_RELEASED``
      - If :ref:`CEC_CAP_RC <CEC-CAP-RC>` is set and if
        :ref:`CEC_LOG_ADDRS_FL_ALLOW_RC_PASSTHRU <CEC-LOG-ADDRS-FL-ALLOW-RC-PASSTHRU>`
        is set, then generate a remote control key
	release. This message is always passed on to the follower(s).
    * .. _`CEC-MSG-REPORT-PHYSICAL-ADDR`:

      - ``CEC_MSG_REPORT_PHYSICAL_ADDR``
      - The CEC framework will make note of the reported physical address
	and then just pass the message on to the follower(s).


Giá trị trả về
==============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

ZZ0000ZZ có thể trả về như sau
mã lỗi:

EINVAL
    Chế độ được yêu cầu không hợp lệ.

EPERM
    Chế độ giám sát được yêu cầu nhưng quy trình có ZZ0000ZZ
    khả năng.

EBUSY
    Người khác đã là người theo dõi hoặc người khởi xướng độc quyền.