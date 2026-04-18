.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/avermedia.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============================================
Ghi chú phát hành Avermedia DVB-T trên BT878
============================================

Ngày 14 tháng 2 năm 2006

.. note::

   Several other Avermedia devices are supported. For a more
   broader and updated content about that, please check:

   https://linuxtv.org/wiki/index.php/AVerMedia

Avermedia DVB-T
~~~~~~~~~~~~~~~~~~~

Avermedia DVB-T là thẻ PCI DVB bình dân. Nó có 3 đầu vào:

* Đầu vào bộ dò sóng RF
* Đầu vào video tổng hợp (Giắc RCA)
* Đầu vào SVIDEO (Mini-DIN)

Đầu vào bộ điều chỉnh RF là đầu vào cho mô-đun bộ điều chỉnh của
thẻ.  Tuner còn được gọi là "Frontend". các
Giao diện người dùng của Avermedia DVB-T là Microtune 7202D. Một cách kịp thời
đăng lên danh sách gửi thư linux-dvb đã xác định chắc chắn rằng
Microtune 7202D được hỗ trợ bởi trình điều khiển sp887x
được tìm thấy trong mô-đun dvb-hw CVS.

Thẻ DVB-T dựa trên chip BT878, một chip rất
cầu đa phương tiện phổ biến và thường thấy trên các card Analog TV.
Không có bộ giải mã MPEG2 trên bo mạch, có nghĩa là tất cả MPEG2
việc giải mã phải được thực hiện bằng phần mềm, hoặc nếu có, trên một
Thẻ hoặc chipset giải mã phần cứng MPEG2.


Bắt thẻ đi
~~~~~~~~~~~~~~~~~~~~~~

Ở giai đoạn này, người ta chưa thể xác định được
chức năng của các nút thiết bị còn lại liên quan đến
Avemedia DVBT.  Tuy nhiên, đầy đủ chức năng liên quan đến
điều chỉnh, nhận và cung cấp luồng dữ liệu MPEG2 là
có thể thực hiện được với các phiên bản trình điều khiển hiện có.
Có thể có chức năng bổ sung có sẵn
từ thẻ (tức là xem các đầu vào tương tự bổ sung
mà thẻ trình bày), nhưng điều này vẫn chưa được thử nghiệm. Nếu
Tôi giải quyết vấn đề này, tôi sẽ cập nhật tài liệu với bất cứ điều gì tôi
tìm.

Để cấp nguồn cho thẻ, hãy nạp các mô-đun sau vào
thứ tự sau:

* modprobe bttv (thường được tải tự động)
* modprobe dvb-bt8xx (hoặc đặt dvb-bt8xx vào /etc/modules)

Việc chèn các mô-đun này vào kernel đang chạy sẽ
kích hoạt các nút thiết bị DVB thích hợp. Khi đó có thể
để bắt đầu truy cập vào thẻ với các tiện ích như scan, tzap,
dvbstream v.v.

Mô-đun giao diện người dùng sp887x.o, yêu cầu phần sụn bên ngoài.
Vui lòng sử dụng lệnh "get_dvb_firmware sp887x" để tải xuống
nó. Sau đó sao chép nó vào /usr/lib/hotplug/firmware hoặc /lib/firmware/
(tùy thuộc vào cấu hình của hotplug firmware).

Những hạn chế đã biết
~~~~~~~~~~~~~~~~~

Hiện tại tôi có thể tự tin nói rằng giai điệu giao diện người dùng
thông qua /dev/dvb/adapter{x}/frontend0 và cung cấp luồng MPEG2
qua /dev/dvb/adapter{x}/dvr0.   Tôi chưa thử nghiệm
chức năng của bất kỳ phần nào khác của thẻ. tôi sẽ làm như vậy
theo thời gian và cập nhật tài liệu này.

Có một số hạn chế trong lớp i2c do trả về
thông báo lỗi không nhất quán. Mặc dù điều này tạo ra sai sót trong
dmesg và nhật ký hệ thống, nó dường như không ảnh hưởng đến
khả năng của giao diện người dùng hoạt động chính xác.

Cập nhật thêm
~~~~~~~~~~~~~~

dvbstream và VideoLAN Client trên windows hoạt động tốt với
DVB, trên thực tế, đây hiện đang là phương pháp chính của tôi
đang xem DVB-T vào lúc này.  Ngoài ra, VLC rất vui
giải mã tín hiệu HDTV, mặc dù PC đang bỏ đi tín hiệu kỳ lạ
khung ở đây và ở đó - tôi cho là do khả năng xử lý -
vì tất cả quá trình giải mã đang được thực hiện dưới cửa sổ phần mềm.

Cảm ơn Nigel Pearson rất nhiều vì đã cập nhật tài liệu này
kể từ lần sửa đổi gần đây của trình điều khiển.