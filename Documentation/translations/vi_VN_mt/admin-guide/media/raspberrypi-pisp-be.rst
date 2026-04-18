.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/raspberrypi-pisp-be.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================================================
Raspberry Pi PiSP Back End Memory-to-Memory ISP (pisp-be)
==============================================================

Phần cuối của PiSP
==================

PiSP Back End là Bộ xử lý tín hiệu hình ảnh từ bộ nhớ đến bộ nhớ (ISP) có chức năng đọc
dữ liệu hình ảnh từ bộ nhớ DRAM và thực hiện xử lý hình ảnh theo chỉ định của
ứng dụng thông qua các tham số trong bộ đệm cấu hình, trước khi ghi
dữ liệu pixel trở lại bộ nhớ thông qua hai kênh đầu ra riêng biệt.

Các thanh ghi ISP và mô hình lập trình được ghi lại trong ZZ0000ZZ

PiSP Back End ISP xử lý hình ảnh theo các ô xếp. Việc xử lý hình ảnh
tessellation và tính toán các tham số cấu hình cấp thấp là
được thực hiện bởi thư viện phần mềm miễn phí có tên ZZ0000ZZ.

Quy trình xử lý hình ảnh đầy đủ, bao gồm việc thu thập dữ liệu RAW của Bayer từ
một cảm biến hình ảnh thông qua giao diện chụp tương thích MIPI CSI-2, lưu trữ chúng
trong bộ nhớ DRAM và xử lý chúng trong PiSP Back End để thu được hình ảnh có thể sử dụng được
bởi một ứng dụng được triển khai trong ZZ0000ZZ như
một phần của hỗ trợ nền tảng Raspberry Pi.

Người lái xe pisp-be
====================

Trình điều khiển Raspberry Pi PiSP Back End (pisp-be) nằm bên dưới
trình điều khiển/phương tiện/nền tảng/raspberrypi/pisp-be. Nó sử dụng ZZ0000ZZ để đăng ký
một số thiết bị quay và xuất video, ZZ0001ZZ để đăng ký
một thiết bị con dành cho ISP kết nối các thiết bị video trong một biểu đồ phương tiện duy nhất
được thực hiện bằng cách sử dụng ZZ0002ZZ.

Cấu trúc liên kết phương tiện được trình điều khiển ZZ0000ZZ đăng ký được trình bày bên dưới:

.. _pips-be-topology:

.. kernel-figure:: raspberrypi-pisp-be.dot
    :alt:   Diagram of the default media pipeline topology
    :align: center


Biểu đồ phương tiện đăng ký các nút thiết bị video sau:

- pispbe-input: thiết bị đầu ra để gửi hình ảnh tới ISP cho
  xử lý.
- pispbe-tdn_input: thiết bị đầu ra khử nhiễu tạm thời.
- pispbe-stitch_input: thiết bị đầu ra để ghép ảnh (HDR).
- pispbe-output0: thiết bị chụp đầu tiên dành cho ảnh đã qua xử lý.
- pispbe-output1: thiết bị chụp ảnh thứ hai dành cho ảnh đã qua xử lý.
- pispbe-tdn_output: thiết bị chụp để khử nhiễu tạm thời.
- pispbe-stitch_output: thiết bị chụp ảnh để ghép ảnh (HDR).
- pispbe-config: thiết bị đầu ra cho các thông số cấu hình ISP.

đầu vào pispbe
--------------

Hình ảnh được ISP xử lý sẽ được xếp hàng đợi đến thiết bị đầu ra ZZ0001ZZ
nút. Để biết danh sách các định dạng hình ảnh được hỗ trợ làm đầu vào cho ISP, hãy tham khảo
ZZ0000ZZ.

pispbe-tdn_input, pispbe-tdn_output
-----------------------------------

Thiết bị video đầu ra ZZ0000ZZ nhận hình ảnh được xử lý bằng
khối khử nhiễu tạm thời được lấy từ ZZ0001ZZ
quay thiết bị video. Không gian người dùng chịu trách nhiệm duy trì hàng đợi trên cả hai
thiết bị và đảm bảo rằng bộ đệm hoàn thành ở đầu ra được xếp hàng đợi vào
đầu vào.

pispbe-stitch_input, pispbe-stitch_output
-----------------------------------------

Để nhận ra việc xử lý hình ảnh HDR (dải động cao), việc ghép hình ảnh và
khối tonemapping được sử dụng. ZZ0000ZZ ghi hình ảnh vào bộ nhớ
và ZZ0001ZZ nhận khung được ghi trước đó để xử lý
nó cùng với hình ảnh đầu vào hiện tại. Không gian người dùng chịu trách nhiệm duy trì
hàng đợi trên cả hai thiết bị và đảm bảo rằng bộ đệm được hoàn thành ở đầu ra
xếp hàng vào đầu vào.

pispbe-output0, pispbe-output1
------------------------------

Hai thiết bị chụp ghi vào bộ nhớ dữ liệu pixel do ISP xử lý.

pispbe-config
-------------

Thiết bị video đầu ra ZZ0000ZZ nhận được bộ đệm cấu hình
các tham số xác định quá trình xử lý hình ảnh mong muốn được thực hiện bởi ISP.

Định dạng của tham số cấu hình ISP được xác định bởi
Cấu trúc ZZ0000ZZ C và ý nghĩa từng tham số là
được mô tả trong ZZ0001ZZ.

Cấu hình ISP
=================

Cấu hình ISP chỉ được mô tả bằng nội dung thông số
bộ đệm. Tham số duy nhất mà không gian người dùng cần định cấu hình bằng V4L2 API
là định dạng hình ảnh trên thiết bị đầu ra và quay video để xác thực
nội dung của bộ đệm tham số.

.. _Raspberry Pi Image Signal Processor (PiSP) Specification document: https://datasheets.raspberrypi.com/camera/raspberry-pi-image-signal-processor-specification.pdf