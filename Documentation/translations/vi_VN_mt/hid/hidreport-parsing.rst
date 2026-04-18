.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hid/hidreport-parsing.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============================================
Phân tích cú pháp thủ công của bộ mô tả báo cáo HID
========================================

Hãy xem xét lại bộ mô tả báo cáo chuột HID
được giới thiệu trong Documentation/hid/hidintro.rst::

$ hexdump -C /sys/bus/hid/devices/0003\:093A\:2510.0002/report_descriptor
  00000000 05 01 09 02 a1 01 09 01 a1 00 05 09 19 01 29 03 ZZ0000ZZ
  00000010 15 00 25 01 75 01 95 03 81 02 75 05 95 01 81 01 ZZ0001ZZ
  00000020 05 01 09 30 09 31 09 38 15 81 25 7f 75 08 95 03 ZZ0002ZZ
  00000030 81 06 c0 c0 ZZ0003ZZ
  00000034

và cố gắng phân tích nó bằng tay.

Bắt đầu với số đầu tiên, 0x05: nó mang 2 bit cho
dài của mục, 2 bit cho loại mục và 4 bit cho
chức năng::

+----------+
  ZZ0000ZZ
  +----------+
          ^^
          ---- Độ dài của dữ liệu (xem thông số HID 6.2.2.2)
        ^^
        ------ Loại vật phẩm (xem thông số HID 6.2.2.2, sau đó chuyển sang 6.2.2.7)
    ^^ ^^
    --------- Chức năng của vật phẩm (xem HID spec 6.2.2.7, sau đó là HUT Sec 3)

Trong trường hợp của chúng tôi, độ dài là 1 byte, loại là ZZ0000ZZ và
hàm là ZZ0001ZZ, do đó để phân tích giá trị 0x01 trong byte thứ hai
chúng ta cần tham khảo HUT Phần 3.

Số thứ hai là dữ liệu thực tế và ý nghĩa của nó có thể được tìm thấy trong
HUT. Chúng ta có ZZ0000ZZ nên cần tham khảo HUT
Giây. 3, "Trang sử dụng"; từ đó, người ta thấy rằng ZZ0001ZZ là viết tắt của
ZZ0002ZZ.

Bây giờ chuyển sang hai byte thứ hai và theo cùng một sơ đồ,
ZZ0000ZZ (tức là ZZ0001ZZ) sẽ được theo sau bởi một byte (ZZ0002ZZ)
và là vật phẩm ZZ0003ZZ (ZZ0004ZZ). Vì vậy, ý nghĩa của bốn bit còn lại
(ZZ0005ZZ) được đưa ra trong thông số HID Sec. 6.2.2.8 "Mục cục bộ", do đó
chúng tôi có một chiếc ZZ0006ZZ. Từ HUT, Giây. 4, "Trang máy tính để bàn chung", chúng tôi thấy rằng
0x02 là viết tắt của ZZ0007ZZ.

Các số sau có thể được phân tích theo cách tương tự.