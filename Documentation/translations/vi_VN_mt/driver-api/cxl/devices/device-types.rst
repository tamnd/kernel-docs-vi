.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/devices/device-types.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Thiết bị và giao thức
=====================

Loại thiết bị CXL (Bộ nhớ, Bộ tăng tốc, v.v.) quy định nhiều bước cấu hình. Phần này
bao gồm một số thông tin cơ bản về loại thiết bị và tài nguyên trên thiết bị được nền tảng và hệ điều hành sử dụng
cấu hình tác động nào.

Giao thức
=========

Có ba giao thức cốt lõi cho CXL.  Vì mục đích của tài liệu này,
chúng ta sẽ chỉ thảo luận về các định nghĩa ở mức rất cao vì phần cứng cụ thể
các chi tiết phần lớn được trừu tượng hóa khỏi Linux.  Xem thông số kỹ thuật CXL
để biết thêm chi tiết.

CXL.io
------
Giao thức tương tác cơ bản, tương tự như cơ chế cấu hình PCIe.
Thường được sử dụng để khởi tạo, cấu hình và truy cập I/O cho mọi thứ
ngoại trừ các hoạt động của bộ nhớ (CXL.mem) hoặc bộ đệm (CXL.cache).

Trình điều khiển Linux CXL cung cấp quyền truy cập vào chức năng .io thông qua các sysfs khác nhau
giao diện và thiết bị /dev/cxl/ (cho thấy quyền truy cập trực tiếp vào thiết bị
hộp thư).

CXL.cache
---------
Cơ chế mà một thiết bị có thể truy cập và lưu trữ bộ nhớ máy chủ một cách mạch lạc.

Phần lớn trong suốt đối với Linux sau khi được định cấu hình.

CXL.mem
---------
Cơ chế mà CPU có thể truy cập và lưu trữ bộ nhớ thiết bị một cách mạch lạc.

Phần lớn trong suốt đối với Linux sau khi được định cấu hình.


Loại thiết bị
============

Loại-1
------

Thiết bị CXL loại 1:

* Hỗ trợ các giao thức cxl.io và cxl.cache
* Triển khai bộ đệm hoàn toàn mạch lạc
* Cho phép kết hợp giữa Thiết bị với Máy chủ và theo dõi từ Máy chủ đến Thiết bị.
* NOT có bộ nhớ thiết bị do máy chủ quản lý không (HDM)

Ví dụ điển hình của thiết bị loại 1 là Smart NIC - có thể muốn
hoạt động trực tiếp trên bộ nhớ máy chủ (DMA) để lưu trữ các gói đến. Những cái này
các thiết bị chủ yếu dựa vào bộ nhớ gắn CPU.

Loại-2
------

Thiết bị CXL loại 2:

* Hỗ trợ các giao thức cxl.io, cxl.cache và cxl.mem
* Tùy chọn triển khai bộ đệm nhất quán và Bộ nhớ thiết bị do máy chủ quản lý
* Thường là một thiết bị tăng tốc có bộ nhớ băng thông cao.

Sự khác biệt chính giữa thiết bị loại 1 và loại 2 là sự hiện diện
bộ nhớ thiết bị do máy chủ quản lý, cho phép thiết bị hoạt động trên một
ngân hàng bộ nhớ cục bộ - trong khi CPU vẫn có DMA nhất quán với cùng một bộ nhớ.

Điều này cho phép những thứ như GPU hiển thị bộ nhớ của chúng thông qua các thiết bị hoặc tệp DAX
mô tả, cho phép trình điều khiển và chương trình truy cập trực tiếp vào bộ nhớ thiết bị
thay vì sử dụng ngữ nghĩa chuyển khối.

Loại-3
------

Thiết bị CXL loại 3

* Hỗ trợ cxl.io và cxl.mem
* Triển khai bộ nhớ thiết bị do máy chủ quản lý
* Có thể cung cấp dung lượng bộ nhớ Dễ bay hơi hoặc Liên tục (hoặc cả hai).

Một ví dụ cơ bản của thiết bị loại 3 là một bộ mở rộng bộ nhớ đơn giản, có
dung lượng bộ nhớ cục bộ được cung cấp cho CPU để truy cập trực tiếp qua
DMA mạch lạc cơ bản.

Công tắc
------

Bộ chuyển mạch CXL là thiết bị có khả năng định tuyến bất kỳ CXL nào (và theo phần mở rộng là PCIe)
giao thức giữa các thiết bị ngược dòng, hạ lưu hoặc ngang hàng.  Nhiều thiết bị như vậy
là Thiết bị đa logic, ngụ ý sự hiện diện của chuyển đổi theo một cách nào đó.

Thiết bị logic và đầu
-------------------------

Thiết bị CXL có thể hiển thị một hoặc nhiều "Thiết bị logic" cho một hoặc nhiều máy chủ
(thông qua "Đầu" vật lý).

Thiết bị logic đơn (SLD) là thiết bị trình bày một thiết bị duy nhất cho
một hoặc nhiều đầu.

Thiết bị đa logic (MLD) là thiết bị có thể hiển thị nhiều thiết bị
đến một hoặc nhiều thiết bị ngược dòng.

Thiết bị một đầu chỉ hiển thị một kết nối vật lý duy nhất.

Thiết bị nhiều đầu hiển thị nhiều kết nối vật lý.

MHSLD
~~~~~
Thiết bị logic đơn nhiều đầu (MHSLD) hiển thị một logic đơn
thiết bị có nhiều đầu có thể được kết nối với một hoặc nhiều đầu riêng biệt
chủ nhà.  Một ví dụ về điều này sẽ là một nhóm bộ nhớ đơn giản có thể
được cấu hình tĩnh (trước khi khởi động) để hiển thị các phần bộ nhớ của nó
sang Linux thông qua ZZ0000ZZ.

MHMLD
~~~~~
Thiết bị đa logic nhiều đầu (MHMLD) hiển thị nhiều logic
thiết bị tới nhiều đầu có thể được kết nối với một hoặc nhiều đầu rời rạc
chủ nhà.  Một ví dụ về điều này sẽ là Thiết bị công suất động hoặc thiết bị nào
có thể được cấu hình trong thời gian chạy để hiển thị các phần bộ nhớ của nó cho Linux.

Thiết bị mẫu
===============

Bộ mở rộng bộ nhớ
---------------
Dạng đơn giản nhất của thiết bị Loại 3 là thiết bị mở rộng bộ nhớ.  Bộ mở rộng bộ nhớ
hiển thị Bộ nhớ thiết bị do máy chủ quản lý (HDM) cho Linux.  Bộ nhớ này có thể
Dễ bay hơi hoặc không bay hơi (Liên tục).

Bộ mở rộng bộ nhớ thường được coi là một dạng của Bộ mở rộng một đầu,
Thiết bị logic đơn - vì dạng thức của nó thường sẽ là một thẻ bổ trợ
(AIC) hoặc một số dạng thức tương tự khác.

Trình điều khiển Linux CXL cung cấp hỗ trợ cho cấu hình tĩnh hoặc động của
mở rộng bộ nhớ cơ bản.  Nền tảng có thể lập trình bộ giải mã trước khi khởi động hệ điều hành
(ví dụ: bộ giải mã tự động) hoặc người dùng có thể lập trình kết cấu nếu nền tảng
trì hoãn các hoạt động này cho hệ điều hành.

Nhiều Bộ mở rộng Bộ nhớ có thể được thêm vào khung bên ngoài và tiếp xúc với
máy chủ thông qua một đầu được gắn vào bộ chuyển mạch CXL.  Đây là một "bộ nhớ" và
sẽ được coi là MHSLD hoặc MHMLD tùy thuộc vào khả năng quản lý
được cung cấp bởi nền tảng chuyển đổi.

Kể từ v6.14, Linux không cung cấp giao diện chính thức để quản lý không phải DCD
Thiết bị MHSLD hoặc MHMLD.

Thiết bị công suất động (DCD)
-----------------------------

Thiết bị công suất động là thiết bị Loại 3 cung cấp khả năng quản lý động
về dung lượng bộ nhớ. Tiền đề cơ bản của DCD để cung cấp một cơ chế phân bổ giống như
giao diện cho dung lượng bộ nhớ vật lý với "Trình quản lý vải" (một trình quản lý bên ngoài,
máy chủ đặc quyền có đặc quyền thay đổi cấu hình cho các máy chủ khác).

DCD quản lý "Mức độ bộ nhớ", có thể không ổn định hoặc liên tục. Mức độ
cũng có thể dành riêng cho một máy chủ hoặc được chia sẻ trên nhiều máy chủ.

Kể từ v6.14, Linux không cung cấp giao diện chính thức để quản lý DCD
các thiết bị, tuy nhiên, LKML đang nhắm mục tiêu phát hành trong tương lai.