.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/drivers/ccs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

.. _media-ccs-uapi:

Trình điều khiển cảm biến máy ảnh MIPI CCS
=============================

Trình điều khiển cảm biến máy ảnh MIPI CCS là trình điều khiển chung dành cho tuân thủ ZZ0000ZZ
cảm biến máy ảnh. Nó hiển thị ba thiết bị phụ đại diện cho mảng pixel,
thùng rác và máy đo tỷ lệ.

Khi khả năng của từng thiết bị khác nhau, trình điều khiển sẽ bộc lộ
giao diện dựa trên các khả năng tồn tại trong phần cứng.

Xem thêm ZZ0000ZZ.

Thiết bị phụ Pixel Array
----------------------

Thiết bị phụ mảng pixel cũng đại diện cho ma trận pixel của cảm biến máy ảnh
như chức năng cắt tương tự có trong nhiều thiết bị tương thích. Tương tự
crop được định cấu hình bằng ZZ0000ZZ trên bảng nguồn (0) của
thực thể. Kích thước của ma trận pixel có thể thu được bằng cách lấy
Mục tiêu ZZ0001ZZ.

thùng đựng rác
------

Thiết bị phụ binner đại diện cho chức năng tạo thùng trên cảm biến. cho
mục đích đó, mục tiêu lựa chọn ZZ0000ZZ được hỗ trợ trên
miếng đệm chìm (0).

Ngoài ra, nếu một thiết bị không có chức năng chia tỷ lệ hoặc cắt xén kỹ thuật số, thì
bảng nguồn (1) hiển thị một hình chữ nhật chọn vùng cắt kỹ thuật số khác chỉ có thể
cắt ở cuối dòng và khung.

Bộ chia tỷ lệ
------

Thiết bị phụ của bộ chia tỷ lệ đại diện cho chức năng cắt xén và chia tỷ lệ kỹ thuật số của
cảm biến. Mục tiêu lựa chọn V4L2 ZZ0000ZZ được sử dụng để
định cấu hình cắt xén kỹ thuật số trên bảng chìm (0) khi cắt xén kỹ thuật số được hỗ trợ.
Chia tỷ lệ được định cấu hình bằng cách sử dụng mục tiêu lựa chọn ZZ0001ZZ trên
miếng đệm chìm (0) là tốt.

Ngoài ra, nếu thiết bị phụ của bộ chia tỷ lệ tồn tại, bảng nguồn (1) của nó sẽ hiển thị
một hình chữ nhật lựa chọn cắt xén kỹ thuật số khác chỉ có thể cắt ở cuối
đường và khung.

Cắt kỹ thuật số và tương tự
-------------------------

Chức năng cắt xén kỹ thuật số được gọi là cắt xén hoạt động hiệu quả bằng cách
đánh rơi một số dữ liệu trên sàn nhà. Mặt khác, cắt xén tương tự có nghĩa là
thông tin đã cắt không bao giờ được lấy lại. Trong trường hợp cảm biến máy ảnh,
dữ liệu tương tự không bao giờ được đọc từ ma trận pixel nằm ngoài
hình chữ nhật lựa chọn được cấu hình để chỉ định cắt xén. Sự khác biệt có một
ảnh hưởng đến thời gian của thiết bị và có thể cả về mức tiêu thụ điện năng.

Kiểm soát riêng tư
----------------

Trình điều khiển MIPI CCS thực hiện một số điều khiển riêng dưới
ZZ0000ZZ để điều khiển cảm biến máy ảnh tương thích MIPI CCS.

Mô hình khuếch đại tương tự
~~~~~~~~~~~~~~~~~~~

CCS xác định mô hình khuếch đại tương tự trong đó mức tăng có thể được tính bằng cách sử dụng
công thức sau:

tăng = m0 * x + c0 / (m1 * x + c1)

Hoặc m0 hoặc c0 sẽ bằng 0. Các hằng số dành riêng cho thiết bị, có thể là
thu được từ các điều khiển sau:

V4L2_CID_CCS_ANALOGUE_GAIN_M0
	V4L2_CID_CCS_ANALOGUE_GAIN_M1
	V4L2_CID_CCS_ANALOGUE_GAIN_C0
	V4L2_CID_CCS_ANALOGUE_GAIN_C1

Mức tăng tương tự (ZZ0000ZZ trong công thức) được điều khiển thông qua
ZZ0001ZZ trong trường hợp này.

Mô hình khuếch đại tương tự thay thế
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CCS xác định một mô hình khuếch đại tương tự khác gọi là khuếch đại tương tự thay thế. trong
trường hợp này, công thức tính mức tăng thực tế bao gồm tuyến tính và
phần mũ:

tăng = tuyến tính * 2 ^ số mũ

Các hệ số ZZ0000ZZ và ZZ0001ZZ có thể được đặt bằng cách sử dụng
ZZ0002ZZ và
Điều khiển ZZ0003ZZ tương ứng

Chỉnh sửa bóng
~~~~~~~~~~~~~~~~~~

Chuẩn CCS hỗ trợ hiệu chỉnh bóng đổ của ống kính. Tính năng này có thể được kiểm soát
sử dụng ZZ0000ZZ. Ngoài ra, độ sáng
mức độ hiệu chỉnh có thể được thay đổi bằng cách sử dụng
ZZ0001ZZ, trong đó giá trị 0 biểu thị không
hiệu chỉnh và 128 biểu thị việc điều chỉnh độ chói ở các góc xuống ít hơn 10%
hơn ở trung tâm.

Cần phải bật tính năng hiệu chỉnh bóng để mức hiệu chỉnh độ sáng có
hiệu ứng.

ZZ0000ZZ ZZ0001ZZ 2020 Tập đoàn Intel