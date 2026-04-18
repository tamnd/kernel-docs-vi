.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/cards/joystick.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================================
Hỗ trợ cần điều khiển tương tự trên trình điều khiển ALSA
=======================================

Ngày 14 tháng 10 năm 2003

Takashi Iwai <tiwai@suse.de>

Tổng quan
-------

Trước hết, bạn cần kích hoạt hỗ trợ GAMEPORT trên nhân Linux cho
sử dụng cần điều khiển với trình điều khiển ALSA.  Để biết chi tiết về gameport
hỗ trợ, hãy tham khảo Tài liệu/đầu vào/joydev/joystick.rst.

Hỗ trợ cần điều khiển của trình điều khiển ALSA là khác nhau giữa ISA và PCI
thẻ.  Trong trường hợp thẻ ISA (PnP), nó thường được xử lý bởi
mô-đun độc lập (ns558).  Trong khi đó, trình điều khiển ALSA PCI có
hỗ trợ gameport tích hợp.  Do đó, khi trình điều khiển ALSA PCI được xây dựng
trong kernel, CONFIG_GAMEPORT cũng phải là 'y'.  Nếu không,
hỗ trợ gameport trên thẻ đó sẽ bị tắt (âm thầm).

Một số mô-đun bộ điều hợp thăm dò kết nối vật lý của thiết bị tại
thời gian tải.  Sẽ an toàn hơn nếu cắm thiết bị cần điều khiển trước
đang tải mô-đun.


Thẻ PCI
---------

Đối với thẻ PCI, cần điều khiển được bật khi mô-đun thích hợp
tùy chọn được chỉ định.  Một số trình điều khiển không cần tùy chọn và
hỗ trợ cần điều khiển luôn được bật.  Trong phiên bản ALSA trước đây, có
là một API điều khiển động để kích hoạt cần điều khiển.  Đó là
tuy nhiên, đã thay đổi thành các tùy chọn mô-đun tĩnh do hệ thống
ổn định và quản lý tài nguyên.

Trình điều khiển PCI sau đây hỗ trợ cần điều khiển nguyên bản.

=============== ==============================================================
Tùy chọn mô-đun trình điều khiển Các giá trị khả dụng
=============== ==============================================================
als4000 joystick_port 0 = tắt (mặc định), 1 = tự động phát hiện,
	                        hướng dẫn sử dụng: bất kỳ địa chỉ nào (ví dụ: 0x200)
au88x0 N/A N/A
cần điều khiển azf3328 0 = tắt, 1 = bật, -1 = tự động (mặc định)
cần điều khiển ens1370 0 = tắt (mặc định), 1 = bật
ens1371 joystick_port 0 = tắt (mặc định), 1 = tự động phát hiện,
	                        hướng dẫn sử dụng: 0x200, 0x208, 0x210, 0x218
cmipci joystick_port 0 = tắt (mặc định), 1 = tự động phát hiện,
	                        hướng dẫn sử dụng: bất kỳ địa chỉ nào (ví dụ: 0x200)
cs4281 N/A N/A
cs46xx N/A N/A
es1938 N/A N/A
phím điều khiển es1968 0 = tắt (mặc định), 1 = bật
sonicvibes N/A N/A
cây đinh ba N/A N/A
via82xx [#f1]_ joystick 0 = tắt (mặc định), 1 = bật
ymfpci joystick_port 0 = tắt (mặc định), 1 = tự động phát hiện,
	                        hướng dẫn sử dụng: 0x201, 0x202, 0x204, 0x205 [#f2]_
=============== ==============================================================

.. [#f1] VIA686A/B only
.. [#f2] With YMF744/754 chips, the port address can be chosen arbitrarily

Các trình điều khiển sau đây không hỗ trợ gameport nguyên bản, nhưng có
mô-đun bổ sung.  Tải mô-đun tương ứng để thêm gameport
hỗ trợ.

======= ===================
Mô-đun bổ sung trình điều khiển
======= ===================
emu10k1 emu10k1-gp
fm801 fm801-gp
======= ===================

Lưu ý: mô-đun "pcigame" và "cs461x" chỉ dành cho trình điều khiển OSS.
Các trình điều khiển ALSA này (cs46xx, đinh ba và au88x0) có
hỗ trợ gameport tích hợp.

Như đã đề cập ở trên, trình điều khiển ALSA PCI có gameport tích hợp
hỗ trợ, do đó bạn không phải tải mô-đun ns558.  Chỉ cần tải "joydev"
và mô-đun bộ điều hợp thích hợp (ví dụ: "analog").


Thẻ ISA
---------

Trình điều khiển ALSA ISA không có hỗ trợ gameport tích hợp.
Thay vào đó, bạn cần tải mô-đun "ns558" ngoài "joydev" và
mô-đun bộ điều hợp (ví dụ: "analog").
