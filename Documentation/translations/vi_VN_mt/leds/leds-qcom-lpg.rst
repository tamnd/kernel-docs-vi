.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/leds/leds-qcom-lpg.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================================
Trình điều khiển hạt nhân cho Qualcomm LPG
==========================================

Sự miêu tả
-----------

Qualcomm LPG có thể được tìm thấy trong nhiều PMIC của Qualcomm và bao gồm một
số kênh PWM, bảng tra cứu mẫu có thể lập trình và RGB LED
bồn rửa hiện nay.

Để tạo điều kiện thuận lợi cho các trường hợp sử dụng khác nhau, các kênh LPG có thể được hiển thị dưới dạng
các đèn LED riêng lẻ, được nhóm lại với nhau dưới dạng đèn LED RGB hoặc được truy cập dưới dạng PWM
các kênh. Đầu ra của mỗi kênh PWM được chuyển đến phần cứng khác
các khối, chẳng hạn như bồn rửa hiện tại RGB, chân GPIO, v.v.

Mỗi kênh PWM có thể hoạt động với khoảng thời gian từ 27us đến 384 giây và
có độ phân giải 9 bit của chu kỳ nhiệm vụ.

Để cung cấp hỗ trợ thông báo trạng thái với hệ thống con CPU trong
trạng thái nhàn rỗi sâu hơn LPG cung cấp hỗ trợ mẫu. Điều này bao gồm một chia sẻ
bảng tra cứu các giá trị độ sáng và thuộc tính mỗi kênh để chọn
phạm vi trong bảng sẽ sử dụng, tỷ lệ và liệu mẫu có lặp lại hay không.

Mẫu cho một kênh có thể được lập trình bằng cách sử dụng trình kích hoạt "mẫu", sử dụng
thuộc tính hw_pattern.

/sys/class/leds/<led>/hw_pattern
--------------------------------

Chỉ định mẫu phần cứng cho Qualcomm LPG LED.

Mẫu này là một chuỗi các cặp độ sáng và thời gian giữ, với thời gian giữ
được biểu thị bằng mili giây. Thời gian lưu giữ là một thuộc tính của mẫu và phải
do đó, giống hệt nhau đối với từng thành phần trong mẫu (ngoại trừ các điểm tạm dừng
được mô tả dưới đây). Vì phần cứng LPG không thể thực hiện tuyến tính
các chuyển đổi được mong đợi bởi định dạng mẫu kích hoạt đèn led, mỗi mục trong
phải tuân theo mẫu có độ dài bằng 0 có cùng độ sáng.

Mẫu đơn giản::

"255 500 255 0 0 500 0 0"

^
        |
    255 +----+ +----+
        ZZ0000ZZ ZZ0001ZZ ...
      0 |    +----+ +----
        +---------------------->
        0 5 10 15 lần (100ms)

LPG hỗ trợ chỉ định thời gian giữ lâu hơn cho phần tử đầu tiên và cuối cùng
trong mẫu, cái gọi là "tạm dừng thấp" và "tạm dừng cao".

Mẫu tạm dừng thấp::

"255 1000 255 0 0 500 0 0 255 500 255 0 0 500 0 0"

^
        |
    255 +--------+ +----+ +----+ +--------+
        ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ ...
      0 |        +----+ +----+ +----+ +----
        +------------------------------------------>
        0 5 10 15 20 25 lần (100ms)

Tương tự, mục cuối cùng có thể được kéo dài bằng cách sử dụng thời gian giữ cao hơn trên
mục nhập cuối cùng.

Để tiết kiệm không gian trong bảng tra cứu chung, LPG hỗ trợ "bóng bàn"
chế độ, trong trường hợp đó mỗi lần chạy qua mẫu được thực hiện bằng lần chạy đầu tiên
mô hình tiến lên, rồi lùi lại. Chế độ này được tự động sử dụng bởi
trình điều khiển khi mẫu đã cho là một bảng màu. Trong trường hợp này, "tạm dừng cao"
biểu thị thời gian chờ trước khi mẫu được chạy ngược lại và do đó
thời gian giữ được chỉ định của mục ở giữa trong mẫu được phép có
thời gian giữ khác nhau.