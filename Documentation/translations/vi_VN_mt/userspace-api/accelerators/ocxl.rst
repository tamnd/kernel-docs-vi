.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/accelerators/ocxl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================================
OpenCAPI (Giao diện bộ xử lý tăng tốc kết hợp mở)
=============================================================

OpenCAPI là giao diện giữa bộ xử lý và bộ tăng tốc. Nó nhằm mục đích
ở độ trễ thấp và băng thông cao.

Đặc tả này được phát triển bởi OpenCAPI Consortium và hiện nay
có sẵn từ ZZ0000ZZ.

Nó cho phép một máy gia tốc (có thể là FPGA, ASIC, ...) truy cập
bộ nhớ máy chủ một cách mạch lạc, sử dụng địa chỉ ảo. OpenCAPI
thiết bị cũng có thể lưu trữ bộ nhớ riêng của nó, có thể được truy cập từ
chủ nhà.

OpenCAPI được biết đến trong linux với cái tên 'ocxl', là một hệ thống mở, không phụ thuộc vào bộ xử lý.
sự phát triển của 'cxl' (trình điều khiển cho giao diện IBM CAPI dành cho
powerpc), được đặt tên như vậy để tránh nhầm lẫn với ISDN
Hệ thống con CAPI.


Chế độ xem cấp cao
==================

OpenCAPI xác định Lớp liên kết dữ liệu (DL) và Lớp giao dịch (TL), để
được thực hiện trên một liên kết vật lý. Bất kỳ bộ xử lý hoặc thiết bị nào
việc triển khai DL và TL có thể bắt đầu chia sẻ bộ nhớ.

::

+----------+ +-------------+
  ZZ0000ZZ ZZ0001ZZ
  ZZ0002ZZ ZZ0003ZZ
  ZZ0004ZZ ZZ0005ZZ
  ZZ0006ZZ +--------+ ZZ0007ZZ +--------+
  ZZ0008ZZ--ZZ0009ZZ ZZ0010ZZ--ZZ0011ZZ
  ZZ0012ZZ +--------+ ZZ0013ZZ +--------+
  +----------+ +-------------+
       ZZ0014ZZ
  +----------+ +-------------+
  ZZ0015ZZ ZZ0016ZZ
  +----------+ +-------------+
       ZZ0017ZZ
  +----------+ +-------------+
  ZZ0018ZZ ZZ0019ZZ
  +----------+ +-------------+
       ZZ0020ZZ
       ZZ0021ZZ
       +---------------------------------------+



Khám phá thiết bị
=================

OpenCAPI dựa trên không gian cấu hình giống PCI, được triển khai trên
thiết bị. Vì vậy, máy chủ có thể khám phá AFU bằng cách truy vấn không gian cấu hình.

Các thiết bị OpenCAPI trong Linux được xử lý giống như các thiết bị PCI (với một số
hãy cẩn thận). Phần sụn dự kiến sẽ trừu tượng hóa phần cứng như thể nó
là một liên kết PCI. Rất nhiều cơ sở hạ tầng PCI hiện có được tái sử dụng:
các thiết bị được quét và BAR được chỉ định trong PCI tiêu chuẩn
sự liệt kê. Do đó, các lệnh như 'lspci' có thể được sử dụng để xem những gì
các thiết bị có sẵn.

Không gian cấu hình xác định (các) AFU có thể tìm thấy trên
bộ điều hợp vật lý, chẳng hạn như tên của nó, nó có thể có bao nhiêu bối cảnh bộ nhớ
làm việc với, kích thước của các khu vực MMIO của nó, ...



MMIO
====

OpenCAPI xác định hai vùng MMIO cho mỗi AFU:

* khu vực MMIO toàn cầu, với các thanh ghi phù hợp với toàn bộ AFU.
* vùng MMIO trên mỗi quy trình, có kích thước cố định cho từng ngữ cảnh.



AFU ngắt
==============

OpenCAPI bao gồm khả năng AFU gửi ngắt tới
quá trình chủ. Nó được thực hiện thông qua 'intrp_req' được xác định trong
Lớp giao dịch, chỉ định một đối tượng xử lý 64-bit xác định
ngắt lời.

Trình điều khiển cho phép một tiến trình phân bổ một ngắt và nhận được nó
Xử lý đối tượng 64-bit, có thể được chuyển tới AFU.



thiết bị char
=============

Trình điều khiển tạo một thiết bị char cho mỗi AFU được tìm thấy trên thiết bị vật lý
thiết bị. Một thiết bị vật lý có thể có nhiều chức năng và mỗi chức năng
chức năng có thể có nhiều AFU. Tuy nhiên, tại thời điểm viết bài này,
nó chỉ được thử nghiệm với các thiết bị chỉ xuất một AFU.

Các thiết bị Char có thể được tìm thấy trong /dev/ocxl/ và được đặt tên là:
/dev/ocxl/<AFU name>.<location>.<index>

trong đó <AFU name> là tên dài tối đa 20 ký tự, như được tìm thấy trong
không gian cấu hình của AFU.
<location> được trình điều khiển thêm vào và có thể giúp phân biệt các thiết bị
khi một hệ thống có nhiều phiên bản của cùng một thiết bị OpenCAPI.
<index> cũng giúp phân biệt các AFU trong trường hợp khó xảy ra khi một
thiết bị mang nhiều bản sao của cùng một AFU.



Lớp hệ thống
============

Một lớp ocxl được thêm vào cho các thiết bị đại diện cho AFU. Xem
/sys/class/ocxl. Bố cục được mô tả trong
Tài liệu/ABI/thử nghiệm/sysfs-class-ocxl



Người dùng API
==============

mở
----

Dựa trên định nghĩa AFU được tìm thấy trong không gian cấu hình, AFU có thể
hỗ trợ làm việc với nhiều bối cảnh bộ nhớ, trong trường hợp đó
thiết bị char liên quan có thể được mở nhiều lần bằng nhiều cách khác nhau
quá trình.


ioctl
-----

OCXL_IOCTL_ATTACH:

Đính kèm bối cảnh bộ nhớ của quá trình gọi vào AFU để
  AFU có thể truy cập bộ nhớ của nó.

OCXL_IOCTL_IRQ_ALLOC:

Phân bổ một ngắt AFU và trả về một mã định danh.

OCXL_IOCTL_IRQ_FREE:

Giải phóng ngắt AFU được phân bổ trước đó.

OCXL_IOCTL_IRQ_SET_FD:

Liên kết một sự kiện fd với một ngắt AFU để người dùng xử lý
  có thể được thông báo khi AFU gửi ngắt.

OCXL_IOCTL_GET_METADATA:

Lấy thông tin cấu hình từ thẻ, chẳng hạn như kích thước của
  Các khu vực MMIO, phiên bản AFU và PASID cho bối cảnh hiện tại.

OCXL_IOCTL_ENABLE_P9_WAIT:

Cho phép AFU đánh thức luồng không gian người dùng đang thực thi 'chờ'. Trả lại
  thông tin tới không gian người dùng để cho phép nó định cấu hình AFU. Lưu ý rằng
  tính năng này chỉ có trên POWER9.

OCXL_IOCTL_GET_FEATURES:

Các báo cáo về tính năng CPU ảnh hưởng đến OpenCAPI có thể sử dụng được từ
  không gian người dùng.


mmap
----

Một quy trình có thể mmap vùng MMIO trên mỗi quy trình để tương tác với
AFU.
