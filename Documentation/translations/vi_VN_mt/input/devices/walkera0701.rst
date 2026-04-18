.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/input/devices/walkera0701.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Máy phát Walkera WK-0701
==============================

Máy phát Walkera WK-0701 được cung cấp kèm theo Walkera sẵn sàng bay
máy bay trực thăng như HM36, HM37, HM60. Mô-đun walkera0701 cho phép sử dụng
máy phát này như cần điều khiển

Phát triển trang chủ và tải về:
ZZ0000ZZ

hoặc sử dụng cogito:
cg-bản sao ZZ0000ZZ


Kết nối với PC
================

Ở mặt sau của đầu nối S-video của máy phát có thể được tìm thấy. điều chế
các xung từ bộ xử lý đến phần HF có thể được tìm thấy ở chân 2 của đầu nối này,
chân 3 là GND. Có thể tìm thấy điện trở 5k6 giữa chân 3 và CPU. Để có được
xung điều chế tới PC, xung tín hiệu phải được khuếch đại.

Cáp: (walkera TX tới sân bay)

Đầu nối Walkera WK-0701 TX S-VIDEO::

(mặt sau của TX)
     __ __ S-video: canon25
    / ZZ0000ZZ\pin 2 (tín hiệu) cổng NPN
   / O 4 3 O \ chốt 3 (GND) LED ________________ 10 ACK
  ( Ô 2 1 Ô ) | C
   \ ___ / 2 ________________________ZZ0001ZZ_____|/
    ZZ0002ZZ ZZ0003ZZ B |\
     ------- 3 __________________________________|________________ 25 GND
                                                          E

Tôi sử dụng bóng bán dẫn LED và BC109 NPN màu xanh lá cây.

Phần mềm
========

Xây dựng kernel với mô-đun walkera0701. Mô-đun walkera0701 cần độc quyền
truy cập vào parport, các mô-đun như lp phải được tải xuống trước khi tải
mô-đun walkera0701, kiểm tra dmesg để biết thông báo lỗi. Kết nối TX với PC bằng
cable và chạy jstest /dev/input/js0 để xem các giá trị từ TX. Nếu không có giá trị nào có thể
được thay đổi bằng "cần điều khiển" TX, kiểm tra đầu ra từ /proc/interrupt. Giá trị cho
(thường là irq7) parport phải tăng nếu TX được bật.



Chi tiết kỹ thuật
=================

Trình điều khiển sử dụng ngắt từ bit đầu vào ACK của parport để đo độ dài xung
sử dụng đồng hồ đo giờ.

Định dạng khung:
Dựa trên mô tả định dạng walkera WK-0701 PCM của Shaul Eizikovich.
(tải xuống từ ZZ0000ZZ

Xung tín hiệu
-------------

::

(ANALOG)
      SYNC BIN OCT
    +----------+ +------+
    ZZ0000ZZ ZZ0001ZZ
  ---+ +------+ +---

Khung
-----

::

SYNC , BIN1, OCT1, BIN2, OCT2 ... BIN24, OCT24, BIN25, khung tiếp theo SYNC ..

độ dài xung
------------

::

Giá trị nhị phân: Giá trị bát phân tương tự:

288 uS Nhị phân 0 318 uS 000
   438 uS Nhị phân 1 398 uS 001
				478 uS 010
				558 Mỹ 011
				638 đô la Mỹ 100
  1306 Mỹ SYNC 718 Mỹ 101
				798 Mỹ 110
				878 Mỹ 111

24 giá trị bin+oct + 1 giá trị bin = 24*4+1 bit = 97 bit

(Cảnh báo, xung trên ACK bị đảo ngược bởi bóng bán dẫn, irq được nâng lên đồng bộ
để thay đổi bin hoặc giá trị bát phân để thay đổi bin).

Biểu diễn dữ liệu nhị phân
---------------------------

Một giá trị nhị phân và bát phân có thể được nhóm lại thành nibble. 24 nibble + một nhị phân
các giá trị có thể được lấy mẫu giữa các xung đồng bộ.

Giá trị cho bốn kênh đầu tiên (giá trị cần điều khiển tương tự) có thể được tìm thấy trong
10 miếng đầu tiên. Giá trị tương tự được biểu thị bằng một bit dấu và 9 bit
giá trị nhị phân tuyệt đối. (10 bit cho mỗi kênh). Nibble tiếp theo là tổng kiểm tra cho
mười miếng đầu tiên.

Tiếp theo nibbles 12 .. 21 đại diện cho bốn kênh (không phải tất cả các kênh đều có thể
điều khiển trực tiếp từ TX). Biểu diễn nhị phân giống như trong lần đầu tiên
bốn kênh. Ở nibbles 22 và 23 là một con số kỳ diệu đặc biệt. Nibble 24 là
tổng kiểm tra cho nibble 12..23.

Sau giá trị bát phân cuối cùng cho nibble 24 và xung đồng bộ tiếp theo bổ sung thêm một
giá trị nhị phân có thể được lấy mẫu. Bit và số ma thuật này không được sử dụng trong
trình điều khiển phần mềm. Một số chi tiết về con số kỳ diệu này có thể được tìm thấy trong
Walkera_Wk-0701_PCM.pdf.

Tính toán tổng kiểm tra
--------------------

Tóm tắt giá trị bát phân trong nibble phải giống với giá trị bát phân trong tổng kiểm tra
nibble (chỉ sử dụng 3 bit đầu tiên). Giá trị nhị phân cho tổng kiểm tra là
được tính bằng tổng các giá trị nhị phân trong các phần đã kiểm tra + tổng các giá trị bát phân
trong các nibble đã kiểm tra chia cho 8. Chỉ bit 0 của tổng này được sử dụng.
