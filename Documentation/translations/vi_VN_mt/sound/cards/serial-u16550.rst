.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/cards/serial-u16550.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================================
Trình điều khiển nối tiếp UART 16450/16550 MIDI
===================================

Tham số mô-đun bộ điều hợp cho phép bạn chọn:

* 0 - Hỗ trợ Roland Soundcanvas (mặc định)
* 1 - Hỗ trợ Midiator MS-124T (1)
* 2 - Chế độ S/A của Midiator MS-124W (2)
* 3 - Hỗ trợ chế độ M/B MS-124W (3)
* 4 - Thiết bị chung có hỗ trợ nhiều đầu vào (4)

Đối với Midiator MS-124W, bạn phải đặt M-S và A-B vật lý
bật Midiator để phù hợp với chế độ lái xe bạn chọn.

Trong chế độ Roland Soundcanvas, nhiều luồng con MIDI thô ALSA được hỗ trợ
(midiCnD0-midiCnD15).  Bất cứ khi nào bạn ghi vào một dòng con khác, trình điều khiển
gửi chuỗi lệnh MIDI không chuẩn F5 NN, trong đó NN là luồng con
số cộng 1. Các mô-đun Roland sử dụng lệnh này để chuyển đổi giữa các mô-đun khác nhau
"các bộ phận", vì vậy tính năng này cho phép bạn coi mỗi bộ phận là một MIDI thô riêng biệt
dòng phụ. Trình điều khiển không cung cấp cách nào để gửi F5 00 (không có lựa chọn) hoặc không
gửi toàn bộ chuỗi lệnh F5 NN; có lẽ nó nên như vậy.

Ví dụ sử dụng cho bộ chuyển đổi nối tiếp đơn giản:
::

/sbin/setserial /dev/ttyS0 uart không có
	/sbin/modprobe snd-serial-u16550 cổng=0x3f8 irq=4 tốc độ=115200

Ví dụ sử dụng Roland SoundCanvas với 4 cổng MIDI:
::

/sbin/setserial /dev/ttyS0 uart không có
	/sbin/modprobe snd-serial-u16550 port=0x3f8 irq=4 outs=4

Ở chế độ MS-124T, một luồng con MIDI thô được hỗ trợ (midiCnD0); bên ngoài
tham số mô-đun được tự động đặt thành 1. Trình điều khiển gửi dữ liệu tương tự tới
tất cả bốn đầu nối MIDI Out.  Đặt công tắc A-B và mô-đun tốc độ
tham số cần khớp (A=19200, B=9600).

Ví dụ sử dụng cho MS-124T, với công tắc A-B ở vị trí A:
::

/sbin/setserial /dev/ttyS0 uart không có
	/sbin/modprobe snd-serial-u16550 port=0x3f8 irq=4 adapter=1 \
			tốc độ=19200

Ở chế độ MS-124W S/A, một luồng con MIDI thô được hỗ trợ (midiCnD0);
tham số mô-đun outs được tự động đặt thành 1. Trình điều khiển sẽ gửi
cùng một dữ liệu cho tất cả bốn đầu nối MIDI Out ở tốc độ MIDI tối đa.

Ví dụ sử dụng cho chế độ S/A:
::

/sbin/setserial /dev/ttyS0 uart không có
	/sbin/modprobe snd-serial-u16550 port=0x3f8 irq=4 bộ chuyển đổi=2

Ở chế độ MS-124W M/B, trình điều khiển hỗ trợ 16 luồng con ALSA thô MIDI;
tham số mô-đun outs được tự động đặt thành 16. Dòng phụ
số cung cấp một bitmask trong đó dữ liệu sẽ có đầu nối MIDI Out
gửi tới, với midiCnD1 gửi tới Out 1, midiCnD2 đến Out 2, midiCnD4 tới
Out 3, và midiCnD8 đến Out 4. Như vậy midiCnD15 gửi dữ liệu đến cả 4 cổng.
Trong trường hợp đặc biệt, midiCnD0 cũng gửi tới tất cả các cổng vì nó không hữu ích
để gửi dữ liệu đến không có cổng.  Chế độ M/B có thêm chi phí để chọn MIDI
Out cho mỗi byte, do đó tốc độ dữ liệu tổng hợp trên tất cả bốn đầu ra MIDI là
nhiều nhất là một byte cứ sau 520 us, so với tốc độ dữ liệu MIDI đầy đủ của
một byte cứ sau 320 us trên mỗi cổng.

Ví dụ sử dụng cho chế độ M/B:
::

/sbin/setserial /dev/ttyS0 uart không có
	/sbin/modprobe snd-serial-u16550 port=0x3f8 irq=4 bộ chuyển đổi=3

Chế độ M/A của phần cứng MS-124W hiện không được hỗ trợ. Chế độ này cho phép
MIDI Outs hoạt động độc lập với tổng thông lượng gấp đôi M/B,
nhưng không cho phép gửi đồng thời cùng một byte tới nhiều Đầu ra MIDI. 
Giao thức M/A yêu cầu trình điều khiển xoay vòng các đường điều khiển modem theo
hạn chế về thời gian, do đó việc thực hiện sẽ phức tạp hơn một chút so với
các chế độ khác.

Các mẫu máy trung gian ngoài MS-124W và MS-124T hiện không được hỗ trợ. 
Lưu ý rằng chữ cái hậu tố có ý nghĩa quan trọng; MS-124 và MS-124B thì không
tương thích, các mẫu MS-101, MS-101B, MS-103 và MS-114 khác cũng không tương thích.
Tôi có tài liệu (tim.mann@compaq.com) bao gồm một phần các mô hình này,
nhưng không có đơn vị để thử nghiệm.  Hỗ trợ MS-124W được thử nghiệm với thiết bị thực.
Hỗ trợ MS-124T chưa được kiểm tra nhưng sẽ hoạt động.

Trình điều khiển chung hỗ trợ nhiều luồng con đầu vào và đầu ra trên một
cổng nối tiếp.  Tương tự như chế độ Roland Soundcanvas, F5 NN được sử dụng để chọn
luồng đầu vào hoặc đầu ra thích hợp (tùy thuộc vào hướng dữ liệu).
Ngoài ra, tín hiệu CTS được sử dụng để điều chỉnh luồng dữ liệu.  Số lượng
đầu vào được chỉ định bởi tham số ins.
