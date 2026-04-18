.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/cards/mixart.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================================================================
Trình điều khiển Alsa cho card âm thanh Digigram miXart8 và miXart8AES/EBU
==========================================================================

Chữ số <alsa@digigram.com>


GENERAL
=======

MiXart8 là soundcard xử lý và trộn âm thanh đa kênh
có 4 đầu vào âm thanh nổi và 4 đầu ra âm thanh nổi.
MiXart8AES/EBU tương tự với thẻ bổ trợ cung cấp thêm
4 đầu vào và đầu ra âm thanh nổi kỹ thuật số.
Hơn nữa, thẻ bổ trợ cung cấp khả năng đồng bộ hóa đồng hồ bên ngoài
(AES/EBU, Đồng hồ từ, Mã thời gian và Đồng bộ video)

Bo mạch chính có PowerPC cung cấp mã hóa mpeg tích hợp và
giải mã, chuyển đổi lấy mẫu và các hiệu ứng khác nhau.

Trình điều khiển hoàn toàn không hoạt động bình thường cho đến khi có một số phần mềm nhất định
đã được tải, tức là không có thiết bị PCM hay bộ trộn nào xuất hiện.
Sử dụng mixartloader có thể tìm thấy trong gói alsa-tools.


VERSION 0.1.0
=============

Một bảng miXart8 sẽ được thể hiện dưới dạng 4 thẻ alsa, mỗi thẻ có 1
thu âm thanh nổi tương tự 'pcm0c' và 1 thiết bị phát lại âm thanh nổi tương tự 'pcm0p'.
Với miXart8AES/EBU còn có thêm 1 đầu vào kỹ thuật số âm thanh nổi
'pcm1c' và 1 đầu ra kỹ thuật số âm thanh nổi 'pcm1p' trên mỗi thẻ.

Định dạng
---------
U8, S16_LE, S16_BE, S24_3LE, S24_3BE, FLOAT_LE, FLOAT_BE
Tốc độ mẫu: 8000 - 48000 Hz liên tục

Phát lại
--------
Ví dụ: các thiết bị phát lại được cấu hình để có tối đa. 4
dòng con thực hiện trộn phần cứng. Điều này có thể được thay đổi thành một
tối đa 24 dòng con nếu muốn.
Các tập tin mono sẽ được phát trên kênh trái và phải. Mỗi kênh
có thể tắt tiếng cho mỗi luồng để sử dụng riêng 8 đầu ra analog/kỹ thuật số.

Chiếm lấy
---------
Có một luồng con trên mỗi thiết bị chụp. Ví dụ chỉ có âm thanh nổi
các định dạng được hỗ trợ.

Máy trộn
--------
<Chính> và <Chụp Chính>
	điều khiển âm lượng tương tự của phát lại và chụp PCM.
<PCM 0-3> và <Chụp PCM>
	điều khiển âm lượng kỹ thuật số của từng dòng phụ tương tự.
<AES 0-3> và <Chụp AES>
	điều khiển âm lượng kỹ thuật số của từng luồng con AES/EBU.
<Giám sát>
	Lặp lại từ 'pcm0c' đến 'pcm0p' với âm lượng kỹ thuật số
	và điều khiển tắt tiếng.

Rem: để có chất lượng âm thanh tốt nhất, hãy cố gắng duy trì mức suy giảm 0 trên PCM
và điều khiển âm lượng AES được đặt bằng 219 trong phạm vi từ 0 đến 255
(khoảng 86% với alsamixer)


NOT YET IMPLEMENTED
===================

- hỗ trợ đồng hồ bên ngoài (AES/EBU, Word Clock, Time Code, Video Sync)
- Định dạng âm thanh MPEG
- bản ghi đơn âm
- hiệu ứng trên tàu và chuyển đổi lấy mẫu
- các luồng liên kết


FIRMWARE
========

[Kể từ phiên bản 2.6.11, chương trình cơ sở có thể được tải tự động bằng hotplug
 khi CONFIG_FW_LOADER được đặt.  Mixartloader chỉ cần thiết
 cho các phiên bản cũ hơn hoặc khi bạn xây dựng trình điều khiển vào kernel.]
 
Để tải chương trình cơ sở tự động sau khi tải mô-đun, hãy sử dụng
lệnh cài đặt.  Ví dụ: thêm mục sau vào
/etc/modprobe.d/mixart.conf cho trình điều khiển miXart:
::::::::::::::::::::::::::::::::::::::::::::::::::::::::

cài đặt snd-mixart /sbin/modprobe --lần đầu tiên -i snd-mixart && \
			   /usr/bin/mixartloader


(đối với hạt nhân 2.2/2.4, thêm "post-install snd-mixart /usr/bin/vxloader" vào
thay vào đó là /etc/modules.conf.)

Các tệp nhị phân phần sụn được cài đặt trên /usr/share/alsa/firmware
(hoặc /usr/local/share/alsa/firmware, tùy thuộc vào tùy chọn tiền tố của
cấu hình).  Sẽ có một tệp miXart.conf xác định hình ảnh dsp
tập tin.

Các file firmware thuộc bản quyền của Digigram SA


COPYRIGHT
=========

Bản quyền (c) 2003 Digigram SA <alsa@digigram.com>
Có thể phân phối theo GPL.
