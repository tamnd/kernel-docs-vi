.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/cards/bt87x.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Trình điều khiển ALSA BT87x
===========================

giới thiệu
==========

Bạn có thể nhận thấy rằng thẻ Grabber bt878 thực sự có
Chức năng ZZ0000ZZ PCI:
:::::::::::::::::::::::

$ lspci
  [ ... ]
  00:0a.0 Bộ điều khiển video đa phương tiện: Brooktree Corporation Bt878 (rev 02)
  00:0a.1 Bộ điều khiển đa phương tiện: Brooktree Corporation Bt878 (rev 02)
  [ ... ]

Đầu tiên có video, nó tương thích ngược với bt848.  thứ hai
làm âm thanh.  snd-bt87x là trình điều khiển cho chức năng thứ hai.  Đó là một âm thanh
trình điều khiển có thể được sử dụng để ghi âm (và ghi ZZ0000ZZ, không
phát lại).  Vì hầu hết các card TV đều có một dây cáp ngắn có thể được cắm vào
vào đầu vào card âm thanh của bạn, có thể bạn không cần trình điều khiển này nếu tất cả
điều bạn muốn làm chỉ là xem TV...

Một số thẻ không bận tâm đến việc kết nối bất cứ thứ gì với các chân đầu vào âm thanh của
chip và một số thẻ khác sử dụng chức năng âm thanh để truyền MPEG
dữ liệu video, do đó rất có thể việc ghi âm có thể không hoạt động
với thẻ của bạn.


Trạng thái trình điều khiển
===========================

Hiện tài xế đã ổn định.  Tuy nhiên, nó không biết về nhiều card TV,
và nó từ chối nạp những thẻ mà nó không biết.

Nếu trình điều khiển phàn nàn ("Đã tìm thấy thẻ TV không xác định, trình điều khiển âm thanh sẽ
không tải"), bạn có thể chỉ định tùy chọn ZZ0000ZZ để buộc trình điều khiển
hãy thử sử dụng chức năng ghi âm của thẻ của bạn.  Nếu tần số của
dữ liệu được ghi không đúng, hãy thử chỉ định tùy chọn ZZ0001ZZ bằng
các giá trị khác ngoài 32000 mặc định (thường là 44100 hoặc 64000).

Nếu bạn có thẻ không xác định, vui lòng gửi ID và tên bảng tới
<alsa-devel@alsa-project.org>, bất kể tính năng ghi âm có hoạt động hay không
hoặc không, để các phiên bản tương lai của trình điều khiển này biết về thẻ của bạn.


Chế độ âm thanh
===============

Con chip biết hai chế độ khác nhau (kỹ thuật số/analog).  snd-bt87x
đăng ký hai thiết bị PCM, một thiết bị cho mỗi chế độ.  Chúng không thể được sử dụng tại
cùng một lúc.


Chế độ âm thanh kỹ thuật số
===========================

Thiết bị đầu tiên (hw:X,0) cung cấp cho bạn âm thanh nổi 16 bit.  mẫu
tỷ lệ phụ thuộc vào nguồn bên ngoài cung cấp Bt87x bằng kỹ thuật số
âm thanh qua giao diện I2S.


Chế độ âm thanh analog (A/D)
============================

Thiết bị thứ hai (hw:X,1) cung cấp cho bạn âm thanh đơn âm 8 hoặc 16 bit.  Được hỗ trợ
tốc độ mẫu nằm trong khoảng từ 119466 đến 448000 Hz (vâng, những con số này là
cao thế).  Nếu bạn đã đặt tùy chọn CONFIG_SND_BT87X_OVERCLOCK,
tốc độ mẫu tối đa là 1792000 Hz, nhưng dữ liệu âm thanh không thể sử dụng được
vượt quá 896000 Hz trên thẻ của tôi.

Con chip này có ba đầu vào tương tự.  Do đó, bạn sẽ có được một máy trộn
thiết bị để kiểm soát những điều này.


Chúc vui vẻ,

Clemens


Viết bởi Clemens Ladisch <clemens@ladisch.de>
phần lớn được sao chép từ btaudio.txt bởi Gerd Knorr <kraxel@bytesex.org>
