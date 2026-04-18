.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/input/devices/yealink.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================================
Tài liệu driver cho điện thoại Yealink USB-p1k
===============================================

Trạng thái
======

P1k là điện thoại USB 1.1 tương đối rẻ với:

- hỗ trợ đầy đủ bàn phím, yealink.ko / sự kiện đầu vào API
  - LCD hỗ trợ đầy đủ, yealink.ko / sysfs API
  - LED hỗ trợ đầy đủ, yealink.ko / sysfs API
  - hỗ trợ đầy đủ quay số, yealink.ko / sysfs API
  - nhạc chuông hỗ trợ đầy đủ, yealink.ko / sysfs API
  - hỗ trợ phát lại âm thanh đầy đủ, snd_usb_audio.ko / alsa API
  - hỗ trợ ghi âm đầy đủ, snd_usb_audio.ko / alsa API

Để biết tài liệu của nhà cung cấp, hãy xem ZZ0000ZZ


tính năng bàn phím
=================

Ánh xạ hiện tại trong kernel được cung cấp bởi map_p1k_to_key
chức năng::

Sự kiện nhập bố cục nút USB-P1K vật lý


lên lên
        TRONG OUT trái, phải
             xuống xuống

đón C gác máy nhập, lùi lại, thoát
        1 2 3 1, 2, 3
        4 5 6 4, 5, 6,
        7 8 9 7, 8, 9,
        * 0 # *, 0, #,

Phím "lên" và "xuống" được biểu tượng bằng mũi tên trên nút.
Phím “nhấc máy” và “gác máy” được ký hiệu bằng chiếc điện thoại màu xanh và đỏ
trên nút.


Tính năng LCD
============

LCD được chia và sắp xếp dưới dạng màn hình 3 dòng::

ZZ0000ZZ[]
    ZZ0001ZZ[]
                              cửa hàng

NEW REP SU MÔ TỬ WE TH FR SA

    [] [] [] [] [] [] [] [] [] [] [] []
    [] [] [] [] [] [] [] [] [] [] [] []


Định dạng dòng 1 (xem bên dưới): 18.e8.M8.88...188
	  Tên biểu tượng : M D : IN OUT STORE
  Dạng dòng 2: .........
	  Tên biểu tượng : NEW REP SU MO TU WE TH FR SA
  Định dạng dòng 3: 888888888888


Mô tả định dạng:
  Từ góc độ không gian người dùng, thế giới được chia thành "chữ số" và "biểu tượng".
  Một chữ số có thể có bộ ký tự, biểu tượng chỉ có thể BẬT hoặc OFF.

Trình xác định định dạng::

'8' : Chữ số 7 đoạn chung với các phân đoạn có thể định địa chỉ riêng lẻ

Giảm khả năng 7 chữ số đoạn, khi các đoạn được nối cứng với nhau.
    '1' : Chữ số có 2 đoạn chỉ có thể tạo ra số 1.
    'e': Chữ số ngày quan trọng nhất trong tháng,
          có thể tạo ra ít nhất 1 2 3.
    'M' : Chữ số phút có ý nghĩa nhất,
          có thể sản xuất ít nhất 0 1 2 3 4 5.

Biểu tượng hoặc chữ tượng hình:
    '.' : Ví dụ như AM, PM, SU, một 'dot' .. hoặc đoạn đơn khác
	  các phần tử.


Sử dụng trình điều khiển
============

Đối với vùng người dùng, các giao diện sau có sẵn bằng giao diện sysfs ::

/sys/.../
           line1 Đọc/Ghi, LCD line1
           line2 Đọc/Ghi, LCD line2
           line3 Đọc/Ghi, LCD line3

get_icons Read, trả về một tập hợp các biểu tượng có sẵn.
	   Hide_icon Viết, ẩn phần tử bằng cách viết tên biểu tượng.
	   show_icon Viết, hiển thị phần tử bằng cách viết tên biểu tượng.

map_seg7 Đọc/Ghi, bộ ký tự 7 đoạn, chung cho tất cả
			điện thoại yealink. (xem map_to_7segment.h)

nhạc chuông Viết, tải lên biểu diễn nhị phân của nhạc chuông,
			xem yealink.c. trạng thái EXPERIMENTAL do tiềm năng
			cuộc đua giữa async. và đồng bộ hóa cuộc gọi usb.


dòngX
~~~~~

Đọc /sys/../lineX sẽ trả về chuỗi định dạng với giá trị hiện tại của nó.

Ví dụ::

con mèo ./line3
    888888888888
    Đá Linux!

Việc ghi vào /sys/../lineX sẽ đặt dòng LCD tương ứng.

- Những ký tự thừa sẽ bị bỏ qua.
 - Nếu ghi ít ký tự hơn mức cho phép thì các chữ số còn lại là
   không thay đổi.
 - Tab '\t'và '\n' char không ghi đè lên nội dung gốc.
 - Viết một khoảng trắng vào một biểu tượng sẽ luôn ẩn nội dung của nó.

Ví dụ::

ngày +"%m.%e.%k:%M" | sed 's/^0/ /' > ./line1

Sẽ cập nhật LCD với ngày và giờ hiện tại.


get_icons
~~~~~~~~~

Việc đọc sẽ trả về tất cả các tên biểu tượng có sẵn và cài đặt hiện tại của nó ::

mèo ./get_icons
  trên M
  trên D
  trên:
     TRONG
     OUT
     STORE
     NEW
     REP
     SU
     MO
     Tú
     CHÚNG TÔI
     TH
     Pháp
     SA
     LED
     DIALTONE
     RINGTONE


hiện/ẩn biểu tượng
~~~~~~~~~~~~~~~

Việc ghi vào các tệp này sẽ cập nhật trạng thái của biểu tượng.
Mỗi lần chỉ có thể cập nhật một biểu tượng.

Nếu một biểu tượng cũng nằm trên ./lineX thì giá trị tương ứng là
được cập nhật bằng chữ cái đầu tiên của biểu tượng.

Ví dụ - thắp sáng biểu tượng cửa hàng::

echo -n "STORE" > ./show_icon

con mèo ./line1
    18.e8.M8.88...188
		  S

Ví dụ - phát nhạc chuông trong 10 giây::

echo -n RINGTONE > /sys/..../show_icon
    ngủ 10
    echo -n RINGTONE > /sys/..../hide_icon


Tính năng âm thanh
==============

Âm thanh được hỗ trợ bởi trình điều khiển ALSA: snd_usb_audio

Một kênh 16 bit có tốc độ lấy mẫu và phát lại là 8000 Hz là kênh thực tế
giới hạn của thiết bị.

Ví dụ - kiểm tra ghi âm::

arecord -v -d 10 -r 8000 -f S16_LE -t wav foobar.wav

Ví dụ - kiểm tra phát lại::

aplay foobar.wav


Khắc phục sự cố
===============

:Q: Mô-đun yealink được biên dịch và cài đặt mà không gặp vấn đề gì ngoại trừ điện thoại
    không được khởi tạo và không phản ứng với bất kỳ hành động nào.
:A: Nếu bạn thấy một cái gì đó như:
    hiddev0: Thiết bị USB HID v1.00 [Điện thoại Yealink Network Technology Ltd. VOIP USB
    trong dmesg, điều đó có nghĩa là trình điều khiển ẩn đã lấy thiết bị trước. Cố gắng
    tải mô-đun yealink trước bất kỳ trình điều khiển ẩn usb nào khác. Xin vui lòng xem
    hướng dẫn do bản phân phối của bạn cung cấp về cấu hình mô-đun.

:Q: Điện thoại hiện đang hoạt động (hiển thị phiên bản và chấp nhận đầu vào bàn phím) nhưng tôi không thể
    tìm các tập tin sysfs.
:A: Các tệp sysfs được đặt trên điểm cuối usb cụ thể. Trên hầu hết
    các bản phân phối bạn có thể thực hiện: "find /sys/ -name get_icons" để biết gợi ý.


Tín dụng & Lời cảm ơn
=========================

- Olivier Vandorpe, vì đã khởi động dự án usbb2k-api và thực hiện được nhiều việc
    kỹ thuật đảo ngược.
  - Martin Diehl, vì đã chỉ ra cách xử lý việc cấp phát bộ nhớ USB.
  - Dmitry Torokhov, vì nhiều đánh giá và đề xuất về mã.
