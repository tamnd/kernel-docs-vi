.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/dev-sdr.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _sdr:

*************************************
Giao diện vô tuyến được xác định bằng phần mềm (SDR)
**************************************

SDR là tên viết tắt của Đài phát thanh được xác định bằng phần mềm, thiết bị vô tuyến
sử dụng phần mềm ứng dụng để điều chế hoặc giải điều chế. Giao diện này
được thiết kế để kiểm soát và truyền dữ liệu của các thiết bị đó.

Các thiết bị SDR được truy cập thông qua các tệp đặc biệt của thiết bị ký tự có tên
ZZ0000ZZ đến ZZ0001ZZ với số chính 81 và
được phân bổ động các số nhỏ từ 0 đến 255.


Khả năng truy vấn
=====================

Các thiết bị hỗ trợ giao diện bộ thu SDR thiết lập
Cờ ZZ0002ZZ và ZZ0003ZZ trong
Trường cấu trúc ZZ0004ZZ
ZZ0000ZZ được trả lại bởi
ZZ0001ZZ ioctl. Lá cờ đó có nghĩa là
thiết bị có Bộ chuyển đổi Analog sang Digital (ADC), đây là bộ chuyển đổi bắt buộc
phần tử cho máy thu SDR.

Các thiết bị hỗ trợ giao diện máy phát SDR thiết lập
Cờ ZZ0002ZZ và ZZ0003ZZ trong
Trường cấu trúc ZZ0004ZZ
ZZ0000ZZ được trả lại bởi
ZZ0001ZZ ioctl. Lá cờ đó có nghĩa là
thiết bị có Bộ chuyển đổi kỹ thuật số sang tương tự (DAC), đây là thiết bị bắt buộc
phần tử cho máy phát SDR.

Ít nhất một trong các phương thức đọc/ghi hoặc truyền phát I/O
phải được hỗ trợ.


Chức năng bổ sung
======================

Các thiết bị SDR có thể hỗ trợ ZZ0000ZZ và phải hỗ trợ
ioctls ZZ0001ZZ. Bộ điều chỉnh ioctls được sử dụng để thiết lập
Tốc độ lấy mẫu ADC/DAC (tần số lấy mẫu) và sóng vô tuyến có thể
tần số (RF).

Loại bộ điều chỉnh ZZ0000ZZ được sử dụng để cài đặt thiết bị SDR ADC/DAC
tần số và loại bộ điều chỉnh ZZ0001ZZ được sử dụng để cài đặt
tần số vô tuyến. Chỉ số bộ điều chỉnh của bộ điều chỉnh RF (nếu có) phải luôn
tuân theo chỉ số bộ điều chỉnh SDR. Thông thường bộ điều chỉnh SDR là #0 và RF
bộ chỉnh là #1.

ZZ0000ZZ ioctl là
không được hỗ trợ.


Đàm phán định dạng dữ liệu
=======================

Thiết bị SDR sử dụng ioctls ZZ0000ZZ để chọn
định dạng chụp và đầu ra. Cả độ phân giải lấy mẫu và dữ liệu
định dạng phát trực tuyến bị ràng buộc với định dạng có thể lựa chọn đó. Ngoài việc
ioctls ZZ0001ZZ cơ bản,
ZZ0002ZZ ioctl phải được hỗ trợ dưới dạng
tốt.

Để sử dụng các ứng dụng ioctls ZZ0000ZZ, hãy đặt ZZ0004ZZ
trường của cấu trúc ZZ0001ZZ để
ZZ0005ZZ hoặc ZZ0006ZZ và sử dụng
thành viên cấu trúc ZZ0002ZZ ZZ0007ZZ
của liên minh ZZ0008ZZ khi cần thiết cho hoạt động mong muốn. Hiện tại
có hai trường, ZZ0009ZZ và ZZ0010ZZ, của
struct ZZ0003ZZ được sử dụng.
Nội dung của ZZ0011ZZ là mã FourCC V4L2 của định dạng dữ liệu.
Trường ZZ0012ZZ là kích thước bộ đệm tối đa tính bằng byte cần thiết cho
truyền dữ liệu, do người lái xe thiết lập để thông báo cho ứng dụng.


.. c:type:: v4l2_sdr_format

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. flat-table:: struct v4l2_sdr_format
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``pixelformat``
      - The data format or type of compression, set by the application.
	This is a little endian
	:ref:`four character code <v4l2-fourcc>`. V4L2 defines SDR
	formats in :ref:`sdr-formats`.
    * - __u32
      - ``buffersize``
      - Maximum size in bytes required for data. Value is set by the
	driver.
    * - __u8
      - ``reserved[24]``
      - This array is reserved for future extensions. Drivers and
	applications must set it to zero.


Thiết bị SDR có thể hỗ trợ ZZ0000ZZ và/hoặc phát trực tuyến
(ZZ0001ZZ hoặc ZZ0002ZZ) I/O.