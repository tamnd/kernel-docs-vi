.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/cec/cec-ioc-receive.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: CEC

.. _CEC_TRANSMIT:
.. _CEC_RECEIVE:

**********************************
ioctls CEC_RECEIVE và CEC_TRANSMIT
***********************************

Tên
====

CEC_RECEIVE, CEC_TRANSMIT - Nhận hoặc truyền tin nhắn CEC

Tóm tắt
========

.. c:macro:: CEC_RECEIVE

ZZ0000ZZ

.. c:macro:: CEC_TRANSMIT

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ
    Con trỏ tới struct cec_msg.

Sự miêu tả
===========

Để nhận được tin nhắn CEC, ứng dụng phải điền vào
Trường ZZ0002ZZ của cấu trúc ZZ0000ZZ và chuyển nó tới
ZZ0001ZZ.
Nếu bộ mô tả tập tin ở chế độ không chặn và không nhận được
tin nhắn đang chờ xử lý, sau đó nó sẽ trả về -1 và đặt errno thành ZZ0003ZZ
mã lỗi. Nếu bộ mô tả tệp ở chế độ chặn và ZZ0004ZZ
khác 0 và không có tin nhắn nào được gửi đến trong vòng mili giây ZZ0005ZZ, thì
nó sẽ trả về -1 và đặt errno thành mã lỗi ZZ0006ZZ.

Một tin nhắn nhận được có thể là:

1. một tin nhắn nhận được từ một thiết bị CEC khác (trường ZZ0000ZZ sẽ
   là 0, ZZ0001ZZ sẽ là 0 và ZZ0002ZZ sẽ khác 0).
2. kết quả truyền của lần truyền không chặn trước đó (ZZ0003ZZ
   trường sẽ khác 0, ZZ0004ZZ sẽ khác 0 và ZZ0005ZZ
   sẽ là 0).
3. Trả lời cho lần truyền không chặn trước đó (trường ZZ0006ZZ sẽ
   khác 0, ZZ0007ZZ sẽ là 0 và ZZ0008ZZ sẽ khác 0).

Để gửi tin nhắn CEC, ứng dụng phải điền vào cấu trúc
ZZ0000ZZ và chuyển nó cho ZZ0001ZZ.
ZZ0002ZZ chỉ khả dụng nếu
ZZ0004ZZ được thiết lập. Nếu không còn chỗ trống trong đường truyền
queue, sau đó nó sẽ trả về -1 và đặt errno thành mã lỗi ZZ0005ZZ.
Hàng đợi truyền có đủ chỗ cho 18 tin nhắn (có giá trị khoảng 1 giây).
của tin nhắn 2 byte). Lưu ý rằng khung kernel CEC cũng sẽ trả lời
đến các thông điệp cốt lõi (xem ZZ0003ZZ), vì vậy đây không phải là một cách tốt
ý tưởng lấp đầy hàng đợi truyền tải.

Nếu bộ mô tả tập tin ở chế độ không chặn thì quá trình truyền sẽ
trả về 0 và kết quả truyền sẽ có sẵn thông qua
ZZ0000ZZ sau khi truyền xong.
Nếu quá trình truyền không chặn cũng được chỉ định chờ phản hồi thì
câu trả lời sẽ đến trong một tin nhắn sau. Trường ZZ0001ZZ có thể
được sử dụng để liên kết cả kết quả truyền và phản hồi với bản gốc
truyền tải.

Thông thường gọi ZZ0000ZZ khi vật lý
địa chỉ không hợp lệ (do ví dụ như ngắt kết nối) sẽ trả về ZZ0001ZZ.

Tuy nhiên, đặc tả CEC cho phép gửi tin nhắn từ 'Chưa đăng ký' tới
'TV' khi địa chỉ vật lý không hợp lệ do một số TV kéo tính năng phát hiện phích cắm nóng
chân của đầu nối HDMI ở mức thấp khi chúng chuyển sang chế độ chờ hoặc khi chuyển sang
đầu vào khác.

Khi chân phát hiện phích cắm nóng xuống thấp, EDID sẽ biến mất và do đó
địa chỉ vật lý, nhưng cáp vẫn được kết nối và CEC vẫn hoạt động.
Để phát hiện/đánh thức thiết bị, nó được phép gửi cuộc thăm dò ý kiến và 'Hình ảnh/Văn bản
Tin nhắn View On' từ bộ khởi tạo 0xf ('Chưa đăng ký') đến đích 0 ('TV').

.. tabularcolumns:: |p{1.0cm}|p{3.5cm}|p{12.8cm}|

.. c:type:: cec_msg

.. cssclass:: longtable

.. flat-table:: struct cec_msg
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 16

    * - __u64
      - ``tx_ts``
      - Timestamp in ns of when the last byte of the message was transmitted.
	The timestamp has been taken from the ``CLOCK_MONOTONIC`` clock. To access
	the same clock from userspace use :c:func:`clock_gettime`.
    * - __u64
      - ``rx_ts``
      - Timestamp in ns of when the last byte of the message was received.
	The timestamp has been taken from the ``CLOCK_MONOTONIC`` clock. To access
	the same clock from userspace use :c:func:`clock_gettime`.
    * - __u32
      - ``len``
      - The length of the message. For :ref:`ioctl CEC_TRANSMIT <CEC_TRANSMIT>` this is filled in
	by the application. The driver will fill this in for
	:ref:`ioctl CEC_RECEIVE <CEC_RECEIVE>`. For :ref:`ioctl CEC_TRANSMIT <CEC_TRANSMIT>` it will be
	filled in by the driver with the length of the reply message if ``reply`` was set.
    * - __u32
      - ``timeout``
      - The timeout in milliseconds. This is the time the device will wait
	for a message to be received before timing out. If it is set to 0,
	then it will wait indefinitely when it is called by :ref:`ioctl CEC_RECEIVE <CEC_RECEIVE>`.
	If it is 0 and it is called by :ref:`ioctl CEC_TRANSMIT <CEC_TRANSMIT>`,
	then it will be replaced by 1000 if the ``reply`` is non-zero or
	ignored if ``reply`` is 0.
    * - __u32
      - ``sequence``
      - A non-zero sequence number is automatically assigned by the CEC framework
	for all transmitted messages. It is used by the CEC framework when it queues
	the transmit result for a non-blocking transmit. This allows the application
	to associate the received message with the original transmit.

	In addition, if a non-blocking transmit will wait for a reply (ii.e. ``timeout``
	was not 0), then the ``sequence`` field of the reply will be set to the sequence
	value of the original transmit. This allows the application to associate the
	received message with the original transmit.
    * - __u32
      - ``flags``
      - Flags. See :ref:`cec-msg-flags` for a list of available flags.
    * - __u8
      - ``msg[16]``
      - The message payload. For :ref:`ioctl CEC_TRANSMIT <CEC_TRANSMIT>` this is filled in by the
	application. The driver will fill this in for :ref:`ioctl CEC_RECEIVE <CEC_RECEIVE>`.
	For :ref:`ioctl CEC_TRANSMIT <CEC_TRANSMIT>` it will be filled in by the driver with
	the payload of the reply message if ``timeout`` was set.
    * - __u8
      - ``reply``
      - Wait until this message is replied. If ``reply`` is 0 and the
	``timeout`` is 0, then don't wait for a reply but return after
	transmitting the message. Ignored by :ref:`ioctl CEC_RECEIVE <CEC_RECEIVE>`.
	The case where ``reply`` is 0 (this is the opcode for the Feature Abort
	message) and ``timeout`` is non-zero is specifically allowed to make it
	possible to send a message and wait up to ``timeout`` milliseconds for a
	Feature Abort reply. In this case ``rx_status`` will either be set
	to :ref:`CEC_RX_STATUS_TIMEOUT <CEC-RX-STATUS-TIMEOUT>` or
	:ref:`CEC_RX_STATUS_FEATURE_ABORT <CEC-RX-STATUS-FEATURE-ABORT>`.

	If the transmitter message is ``CEC_MSG_INITIATE_ARC`` then the ``reply``
	values ``CEC_MSG_REPORT_ARC_INITIATED`` and ``CEC_MSG_REPORT_ARC_TERMINATED``
	are processed differently: either value will match both possible replies.
	The reason is that the ``CEC_MSG_INITIATE_ARC`` message is the only CEC
	message that has two possible replies other than Feature Abort. The
	``reply`` field will be updated with the actual reply so that it is
	synchronized with the contents of the received message.
    * - __u8
      - ``rx_status``
      - The status bits of the received message. See
	:ref:`cec-rx-status` for the possible status values.
    * - __u8
      - ``tx_status``
      - The status bits of the transmitted message. See
	:ref:`cec-tx-status` for the possible status values.
	When calling :ref:`ioctl CEC_TRANSMIT <CEC_TRANSMIT>` in non-blocking mode,
	this field will be 0 if the transmit started, or non-0 if the transmit
	result is known immediately. The latter would be the case when attempting
	to transmit a Poll message to yourself. That results in a
	:ref:`CEC_TX_STATUS_NACK <CEC-TX-STATUS-NACK>` without ever actually
	transmitting the Poll message.
    * - __u8
      - ``tx_arb_lost_cnt``
      - A counter of the number of transmit attempts that resulted in the
	Arbitration Lost error. This is only set if the hardware supports
	this, otherwise it is always 0. This counter is only valid if the
	:ref:`CEC_TX_STATUS_ARB_LOST <CEC-TX-STATUS-ARB-LOST>` status bit is set.
    * - __u8
      - ``tx_nack_cnt``
      - A counter of the number of transmit attempts that resulted in the
	Not Acknowledged error. This is only set if the hardware supports
	this, otherwise it is always 0. This counter is only valid if the
	:ref:`CEC_TX_STATUS_NACK <CEC-TX-STATUS-NACK>` status bit is set.
    * - __u8
      - ``tx_low_drive_cnt``
      - A counter of the number of transmit attempts that resulted in the
	Arbitration Lost error. This is only set if the hardware supports
	this, otherwise it is always 0. This counter is only valid if the
	:ref:`CEC_TX_STATUS_LOW_DRIVE <CEC-TX-STATUS-LOW-DRIVE>` status bit is set.
    * - __u8
      - ``tx_error_cnt``
      - A counter of the number of transmit errors other than Arbitration
	Lost or Not Acknowledged. This is only set if the hardware
	supports this, otherwise it is always 0. This counter is only
	valid if the :ref:`CEC_TX_STATUS_ERROR <CEC-TX-STATUS-ERROR>` status bit is set.

.. tabularcolumns:: |p{6.2cm}|p{1.0cm}|p{10.1cm}|

.. _cec-msg-flags:

.. flat-table:: Flags for struct cec_msg
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * .. _`CEC-MSG-FL-REPLY-TO-FOLLOWERS`:

      - ``CEC_MSG_FL_REPLY_TO_FOLLOWERS``
      - 1
      - If a CEC transmit expects a reply, then by default that reply is only sent to
	the filehandle that called :ref:`ioctl CEC_TRANSMIT <CEC_TRANSMIT>`. If this
	flag is set, then the reply is also sent to all followers, if any. If the
	filehandle that called :ref:`ioctl CEC_TRANSMIT <CEC_TRANSMIT>` is also a
	follower, then that filehandle will receive the reply twice: once as the
	result of the :ref:`ioctl CEC_TRANSMIT <CEC_TRANSMIT>`, and once via
	:ref:`ioctl CEC_RECEIVE <CEC_RECEIVE>`.

    * .. _`CEC-MSG-FL-RAW`:

      - ``CEC_MSG_FL_RAW``
      - 2
      - Normally CEC messages are validated before transmitting them. If this
        flag is set when :ref:`ioctl CEC_TRANSMIT <CEC_TRANSMIT>` is called,
	then no validation takes place and the message is transmitted as-is.
	This is useful when debugging CEC issues.
	This flag is only allowed if the process has the ``CAP_SYS_RAWIO``
	capability. If that is not set, then the ``EPERM`` error code is
	returned.

    * .. _`CEC-MSG-FL-REPLY-VENDOR-ID`:

      - ``CEC_MSG_FL_REPLY_VENDOR_ID``
      - 4
      - This flag is only available if the ``CEC_CAP_REPLY_VENDOR_ID`` capability
	is set. If this flag is set, then the reply is expected to consist of
	the ``CEC_MSG_VENDOR_COMMAND_WITH_ID`` opcode followed by the Vendor ID
	(in bytes 1-4 of the message), followed by the ``struct cec_msg``
	``reply`` field.

	Note that this assumes that the byte after the Vendor ID is a
	vendor-specific opcode.

	This flag makes it easier to wait for replies to vendor commands.

.. tabularcolumns:: |p{5.6cm}|p{0.9cm}|p{10.8cm}|

.. _cec-tx-status:

.. flat-table:: CEC Transmit Status
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 16

    * .. _`CEC-TX-STATUS-OK`:

      - ``CEC_TX_STATUS_OK``
      - 0x01
      - The message was transmitted successfully. This is mutually
	exclusive with :ref:`CEC_TX_STATUS_MAX_RETRIES <CEC-TX-STATUS-MAX-RETRIES>`.
	Other bits can still be set if earlier attempts met with failure before
	the transmit was eventually successful.
    * .. _`CEC-TX-STATUS-ARB-LOST`:

      - ``CEC_TX_STATUS_ARB_LOST``
      - 0x02
      - CEC line arbitration was lost, i.e. another transmit started at the
        same time with a higher priority. Optional status, not all hardware
	can detect this error condition.
    * .. _`CEC-TX-STATUS-NACK`:

      - ``CEC_TX_STATUS_NACK``
      - 0x04
      - Message was not acknowledged. Note that some hardware cannot tell apart
        a 'Not Acknowledged' status from other error conditions, i.e. the result
	of a transmit is just OK or FAIL. In that case this status will be
	returned when the transmit failed.
    * .. _`CEC-TX-STATUS-LOW-DRIVE`:

      - ``CEC_TX_STATUS_LOW_DRIVE``
      - 0x08
      - Low drive was detected on the CEC bus. This indicates that a
	follower detected an error on the bus and requests a
	retransmission. Optional status, not all hardware can detect this
	error condition.
    * .. _`CEC-TX-STATUS-ERROR`:

      - ``CEC_TX_STATUS_ERROR``
      - 0x10
      - Some error occurred. This is used for any errors that do not fit
	``CEC_TX_STATUS_ARB_LOST`` or ``CEC_TX_STATUS_LOW_DRIVE``, either because
	the hardware could not tell which error occurred, or because the hardware
	tested for other conditions besides those two. Optional status.
    * .. _`CEC-TX-STATUS-MAX-RETRIES`:

      - ``CEC_TX_STATUS_MAX_RETRIES``
      - 0x20
      - The transmit failed after one or more retries. This status bit is
	mutually exclusive with :ref:`CEC_TX_STATUS_OK <CEC-TX-STATUS-OK>`.
	Other bits can still be set to explain which failures were seen.
    * .. _`CEC-TX-STATUS-ABORTED`:

      - ``CEC_TX_STATUS_ABORTED``
      - 0x40
      - The transmit was aborted due to an HDMI disconnect, or the adapter
        was unconfigured, or a transmit was interrupted, or the driver
	returned an error when attempting to start a transmit.
    * .. _`CEC-TX-STATUS-TIMEOUT`:

      - ``CEC_TX_STATUS_TIMEOUT``
      - 0x80
      - The transmit timed out. This should not normally happen and this
	indicates a driver problem.

.. tabularcolumns:: |p{5.6cm}|p{0.9cm}|p{10.8cm}|

.. _cec-rx-status:

.. flat-table:: CEC Receive Status
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 16

    * .. _`CEC-RX-STATUS-OK`:

      - ``CEC_RX_STATUS_OK``
      - 0x01
      - The message was received successfully.
    * .. _`CEC-RX-STATUS-TIMEOUT`:

      - ``CEC_RX_STATUS_TIMEOUT``
      - 0x02
      - The reply to an earlier transmitted message timed out.
    * .. _`CEC-RX-STATUS-FEATURE-ABORT`:

      - ``CEC_RX_STATUS_FEATURE_ABORT``
      - 0x04
      - The message was received successfully but the reply was
	``CEC_MSG_FEATURE_ABORT``. This status is only set if this message
	was the reply to an earlier transmitted message.
    * .. _`CEC-RX-STATUS-ABORTED`:

      - ``CEC_RX_STATUS_ABORTED``
      - 0x08
      - The wait for a reply to an earlier transmitted message was aborted
        because the HDMI cable was disconnected, the adapter was unconfigured
	or the :ref:`CEC_TRANSMIT <CEC_RECEIVE>` that waited for a
	reply was interrupted.


Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

ZZ0000ZZ có thể trả về như sau
mã lỗi:

EAGAIN
    Không có tin nhắn nào trong hàng đợi nhận và tay cầm tệp ở chế độ không chặn.

ETIMEDOUT
    Đã liên lạc được ZZ0000ZZ trong khi chờ tin nhắn.

ERESTARTSYS
    Quá trình chờ tin nhắn bị gián đoạn (ví dụ: bởi Ctrl-C).

ZZ0000ZZ có thể trả về như sau
mã lỗi:

ENOTTY
    Khả năng ZZ0000ZZ chưa được đặt nên ioctl này không được hỗ trợ.

EPERM
    Bộ điều hợp CEC chưa được định cấu hình, tức là ZZ0000ZZ
    chưa bao giờ được gọi hoặc ZZ0001ZZ đã được sử dụng từ một quy trình
    không có khả năng ZZ0002ZZ.

ENONET
    Bộ điều hợp CEC chưa được định cấu hình, tức là ZZ0000ZZ
    đã được gọi, nhưng địa chỉ vật lý không hợp lệ nên không có địa chỉ logic nào được xác nhận.
    Một ngoại lệ được thực hiện trong trường hợp này đối với việc truyền từ bộ khởi tạo 0xf ('Chưa đăng ký')
    đến đích 0 ('TV'). Trong trường hợp đó việc truyền sẽ tiến hành như bình thường.

EBUSY
    Một tước hiệu tệp khác ở chế độ theo dõi hoặc khởi tạo độc quyền, hoặc tước hiệu tệp
    đang ở chế độ ZZ0000ZZ. Điều này cũng được trả về nếu việc truyền
    hàng đợi đã đầy.

EINVAL
    Nội dung của struct ZZ0000ZZ không hợp lệ.

ERESTARTSYS
    Việc chờ truyền thành công đã bị gián đoạn (ví dụ: bởi Ctrl-C).