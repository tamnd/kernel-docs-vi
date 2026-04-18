.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/designs/jack-injection.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
Phần mềm Jack ALSA Jack
===============================

Giới thiệu đơn giản về Jack tiêm
=====================================

Ở đây jack cắm có nghĩa là người dùng có thể chèn các sự kiện plugin hoặc plugout
đến giắc âm thanh thông qua giao diện debugfs, sẽ rất hữu ích khi
xác thực các thay đổi không gian người dùng ALSA. Ví dụ: chúng tôi thay đổi âm thanh
mã chuyển đổi cấu hình trong Pulseaudio và chúng tôi muốn xác minh xem
thay đổi hoạt động như mong đợi và nếu thay đổi gây ra hồi quy,
trong trường hợp này, chúng tôi có thể đưa các sự kiện plugin hoặc plugin vào âm thanh
hoặc một số giắc âm thanh, chúng ta không cần truy cập vật lý vào
máy và cắm/rút phích cắm các thiết bị vật lý vào giắc âm thanh.

Trong thiết kế này, giắc âm thanh không bằng giắc âm thanh vật lý.
Đôi khi giắc âm thanh vật lý có nhiều chức năng và
Trình điều khiển ALSA tạo nhiều ZZ0000ZZ cho ZZ0001ZZ, đây là
ZZ0002ZZ đại diện cho giắc âm thanh vật lý và ZZ0003ZZ
đại diện cho một chức năng, ví dụ một jack vật lý có hai chức năng:
tai nghe và mic_in, driver ALSA ASoC sẽ build 2 ZZ0004ZZ
cho giắc cắm này. Việc chèn jack được thực hiện dựa trên
ZZ0005ZZ thay vì ZZ0006ZZ.

Để đưa các sự kiện vào giắc âm thanh, chúng ta cần kích hoạt tính năng chèn giắc cắm
thông qua ZZ0000ZZ trước, sau khi được bật, giắc cắm này sẽ không
thay đổi trạng thái bằng các sự kiện phần cứng nữa, chúng ta có thể thêm plugin hoặc
sự kiện cắm qua ZZ0001ZZ và kiểm tra trạng thái giắc cắm qua
ZZ0002ZZ, sau khi hoàn thành quá trình kiểm tra, chúng ta cần tắt giắc cắm
cũng được tiêm qua ZZ0003ZZ, khi nó bị vô hiệu hóa, giắc cắm
trạng thái sẽ được khôi phục theo các sự kiện phần cứng được báo cáo gần đây nhất
và sẽ thay đổi bởi các sự kiện phần cứng trong tương lai.

Bố cục của giao diện Jack tiêm
======================================

Nếu người dùng kích hoạt SND_JACK_INJECTION_DEBUG trong kernel, âm thanh
Giao diện chèn jack sẽ được tạo như sau:
::

$debugfs_mount_dir/âm thanh
   |-- thẻ0
   ZZ0000ZZ-- HDMI_DP_pcm_10_Jack
   ZZ0001ZZ-- |-- jackin_inject
   ZZ0002ZZ-- |-- kctl_id
   ZZ0003ZZ-- |-- Mask_bits
   ZZ0004ZZ-- |-- trạng thái
   ZZ0005ZZ-- |-- sw_inject_enable
   ZZ0006ZZ-- |-- loại
   ...
ZZ0000ZZ-- HDMI_DP_pcm_9_Jack
   ZZ0001ZZ-- jackin_inject
   ZZ0002ZZ-- kctl_id
   ZZ0003ZZ-- mặt nạ_bits
   ZZ0004ZZ-- trạng thái
   ZZ0005ZZ-- sw_inject_enable
   ZZ0006ZZ-- loại
   |-- thẻ1
       |-- HDMI_DP_pcm_5_Jack
       ZZ0007ZZ-- jackin_inject
       ZZ0008ZZ-- kctl_id
       ZZ0009ZZ-- mặt nạ_bits
       ZZ0010ZZ-- trạng thái
       ZZ0011ZZ-- sw_inject_enable
       ZZ0012ZZ-- loại
       ...
|-- Jack cắm tai nghe
       ZZ0000ZZ-- jackin_inject
       ZZ0001ZZ-- kctl_id
       ZZ0002ZZ-- mặt nạ_bits
       ZZ0003ZZ-- trạng thái
       ZZ0004ZZ-- sw_inject_enable
       ZZ0005ZZ-- loại
       |-- Tai nghe_Mic_Jack
           |-- jackin_inject
           |-- kctl_id
           |-- mặt nạ_bits
           |-- trạng thái
           |-- sw_inject_enable
           |-- gõ

Giải thích về các nút
======================================

kctl_id
  chỉ đọc, lấy id của jack_kctl->kctl
  ::

âm thanh/card1/Tai nghe_Jack# cat kctl_id
     Giắc cắm tai nghe

mặt nạ_bit
  chỉ đọc, nhận các sự kiện được hỗ trợ của jack_kctl Mask_bits
  ::

âm thanh/card1/Tai nghe_Jack# cat mặt nạ_bits
     0x0001 HEADPHONE(0x0001)

trạng thái
  chỉ đọc, nhận trạng thái hiện tại của jack_kctl

- tai nghe đã được rút ra:

  ::

trạng thái âm thanh/card1/Tai nghe_Jack# cat
     Đã rút phích cắm

- cắm tai nghe:

  ::

trạng thái âm thanh/card1/Tai nghe_Jack# cat
     Đã cắm

loại
  chỉ đọc, nhận các sự kiện được hỗ trợ của snd_jack từ loại (tất cả các sự kiện được hỗ trợ trên giắc âm thanh vật lý)
  ::

âm thanh/card1/Headphone_Jack# cat loại
     0x7803 HEADPHONE(0x0001) MICROPHONE(0x0002) BTN_3(0x0800) BTN_2(0x1000) BTN_1(0x2000) BTN_0(0x4000)

sw_inject_enable
  đọc-ghi, bật hoặc tắt tính năng tiêm

- tính năng tiêm bị vô hiệu hóa:

  ::

âm thanh/card1/Tai nghe_Jack# cat sw_inject_enable
     Jack: Jack cắm tai nghe đã bật: 0

- kích hoạt tiêm:

  ::

âm thanh/card1/Tai nghe_Jack# cat sw_inject_enable
     Giắc cắm: Giắc cắm tai nghe Đã bật: 1

- để kích hoạt tính năng chèn jack:

  ::

âm thanh/card1/Headphone_Jack# echo 1 > sw_inject_enable

- để vô hiệu hóa việc tiêm jack:

  ::

âm thanh/card1/Headphone_Jack# echo 0 > sw_inject_enable

jackin_inject
  chỉ ghi, thêm plugin hoặc plug-in

- để tiêm plugin:

  ::

âm thanh/card1/Headphone_Jack# echo 1 > jackin_inject

- để chèn phích cắm:

  ::

âm thanh/card1/Headphone_Jack# echo 0 > jackin_inject
