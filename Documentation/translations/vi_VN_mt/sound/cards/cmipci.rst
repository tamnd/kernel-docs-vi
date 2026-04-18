.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/cards/cmipci.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================================================
Ghi chú ngắn gọn về Trình điều khiển C-Media 8338/8738/8768/8770
=================================================

Takashi Iwai <tiwai@suse.de>


Phát lại đa kênh trước/sau
---------------------------------

Chip CM8x38 có thể sử dụng ADC làm DAC thứ hai để có hai âm thanh nổi khác nhau
các kênh có thể được sử dụng để phát lại trước/sau.  Vì có hai
DAC, cả hai luồng đều được xử lý độc lập không giống như đa kênh 4/6ch.
phát lại kênh trong phần bên dưới.

Theo mặc định, trình điều khiển ALSA chỉ định thiết bị PCM đầu tiên (tức là hw:0,0 cho
card#0) để phát lại phía trước và 4/6ch, trong khi thiết bị PCM thứ hai
(hw:0,1) được gán cho DAC thứ hai để phát lại phía sau.

Có một số khác biệt nhỏ giữa hai DAC:

- DAC đầu tiên hỗ trợ các định dạng U8 và S16LE, trong khi DAC thứ hai
  chỉ hỗ trợ S16LE.
- DAC thứ hai chỉ hỗ trợ âm thanh nổi hai kênh.

Xin lưu ý rằng CM8x38 DAC không hỗ trợ phát lại liên tục
tỷ giá nhưng chỉ có tỷ giá cố định: 5512, 8000, 11025, 16000, 22050, 32000,
44100 và 48000 Hz.

Chỉ có thể nghe thấy đầu ra phía sau khi bật công tắc "Chế độ bốn kênh"
bị vô hiệu hóa.  Nếu không thì sẽ không có tín hiệu nào được chuyển đến loa phía sau.
Theo mặc định nó được bật.

.. WARNING::
  When "Four Channel Mode" switch is off, the output from rear speakers
  will be FULL VOLUME regardless of Master and PCM volumes [#]_.
  This might damage your audio equipment.  Please disconnect speakers
  before your turn off this switch.


.. [#]
  Well.. I once got the output with correct volume (i.e. same with the
  front one) and was so excited.  It was even with "Four Channel" bit
  on and "double DAC" mode.  Actually I could hear separate 4 channels
  from front and rear speakers!  But.. after reboot, all was gone.
  It's a very pity that I didn't save the register dump at that
  time..  Maybe there is an unknown register to achieve this...

Nếu thẻ của bạn có một giắc cắm đầu ra bổ sung cho đầu ra phía sau, thì phía sau
việc phát lại sẽ được định tuyến ở đó theo mặc định.  Nếu không, có một
công tắc điều khiển trong trình điều khiển "Line-In As Rear" mà bạn có thể thay đổi
thông qua alsamixer hoặc cách nào khác.  Khi công tắc này bật, giắc cắm đầu vào
được sử dụng làm đầu ra phía sau.

Có thêm hai điều khiển liên quan đến đầu ra phía sau.
Công tắc "Exchange DAC" được sử dụng để trao đổi phát lại phía trước và phía sau
các tuyến đường, tức là DAC thứ 2 là đầu ra từ đầu ra phía trước.


Phát lại đa kênh 4/6
--------------------------

Các chip CM8738 gần đây hỗ trợ phát lại đa kênh 4/6
chức năng.  Điều này đặc biệt hữu ích cho việc giải mã AC3.

Khi đa kênh được hỗ trợ, tên trình điều khiển có hậu tố
"-MC" chẳng hạn như "CMI8738-MC6".  Bạn có thể kiểm tra tên này từ
/proc/asound/cards.

Khi đầu ra 4/6-ch được bật, DAC thứ hai chấp nhận tối đa 6 (hoặc
4) kênh.  Trong khi DAC kép hỗ trợ hai tốc độ khác nhau hoặc
định dạng, phát lại 4/6-ch chỉ hỗ trợ cùng một điều kiện cho tất cả
các kênh.  Vì chế độ phát lại đa kênh sử dụng cả hai DAC nên bạn
không thể hoạt động ở chế độ full-duplex.

Các chế độ 4.0 và 5.1 được định nghĩa là pcm "sround40" và "sround51"
trong alsa-lib.  Ví dụ: bạn có thể phát tệp WAV với 6 kênh như
::

% aplay -Dsurround51 sixchannels.wav

Để lập trình phát lại kênh 4/6, bạn cần chỉ định PCM
kênh tùy thích và đặt định dạng S16LE.  Ví dụ, để phát lại
với 4 kênh,
::

snd_pcm_hw_params_set_access(pcm, hw, SND_PCM_ACCESS_RW_INTERLEAVED);
	    // hoặc mmap nếu bạn thích
	snd_pcm_hw_params_set_format(pcm, hw, SND_PCM_FORMAT_S16_LE);
	snd_pcm_hw_params_set_channels(pcm, hw, 4);

và sử dụng dữ liệu 4 kênh xen kẽ.

Có một số công tắc điều khiển ảnh hưởng đến kết nối loa:

Chế độ đầu vào
	một điều khiển enum để thay đổi hành vi của dòng vào
	jack.  Có thể "Line-In", "Rear Output" hoặc "Bass Output"
	được chọn.  Sản phẩm cuối cùng chỉ có ở mẫu 039
	hoặc mới hơn. 
	Khi "Đầu ra phía sau" được chọn, các kênh âm thanh vòm 3 và 4
	được xuất ra giắc cắm đầu vào.
Chế độ Mic-In
	một điều khiển enum để thay đổi hành vi của mic-in
	jack.  Có thể là "Mic-In" hoặc "Center/LFE Output"
	đã chọn. 
	Khi chọn "Center/LFE Output", âm trung và âm trầm sẽ
	các kênh (kênh 5 và 6) được xuất ra giắc cắm mic-in.

I/O kỹ thuật số
-----------

CM8x38 cung cấp khả năng SPDIF tuyệt vời với chi phí rất rẻ
giá (vâng, đó là lý do tôi mua thẻ :)

Việc phát và ghi SPDIF được thực hiện thông qua thiết bị PCM thứ ba
(h:0,2).  Thông thường, điều này được gán cho "spdif" của thiết bị PCM.
Tốc độ có sẵn là 44100 và 48000 Hz.
Để phát lại bằng aplay, bạn có thể chạy như dưới đây:
::

% aplay -Dhw:0,2 foo.wav

hoặc

::

% aplay -Dspdif foo.wav

Định dạng 24bit cũng được hỗ trợ thử nghiệm.

Việc phát lại và chụp trên SPDIF sử dụng DAC và ADC bình thường,
tương ứng, do đó bạn không thể phát lại cả luồng analog và kỹ thuật số
đồng thời.

Để bật đầu ra SPDIF, bạn cần bật "Công tắc đầu ra IEC958"
điều khiển thông qua bộ trộn hoặc alsactl ("IEC958" là tên chính thức của
cái gọi là S/PDIF).  Sau đó bạn sẽ thấy đèn đỏ trên thẻ
bạn biết điều đó rõ ràng đang hoạt động :)
Đầu vào SPDIF luôn được bật để bạn có thể nghe thấy dữ liệu đầu vào SPDIF
từ đầu ra bằng công tắc "IEC958 In Monitor" bất cứ lúc nào (xem
bên dưới).

Bạn có thể chơi qua SPDIF ngay cả với thiết bị đầu tiên (hw:0,0),
nhưng SPDIF chỉ được bật khi định dạng phù hợp (S16LE), tốc độ mẫu
(441100 hoặc 48000) và kênh (2) được sử dụng.  Nếu không thì nó đã biến
tắt.  (Cũng đừng quên bật "Công tắc đầu ra IEC958".)


Ngoài ra còn có các công tắc điều khiển liên quan:

Tương tự hỗn hợp IEC958
	Trộn các luồng phát lại PCM tương tự và FM-OPL/3 và
	đầu ra thông qua SPDIF.  Công tắc này chỉ xuất hiện trên chip cũ
	mô hình (CM8738 033 và 037).

Lưu ý: không có điều khiển này, bạn có thể xuất PCM thành SPDIF.
	Đây là "trộn" các luồng, vì vậy, ví dụ: nó không dành cho đầu ra AC3
	(xem phần tiếp theo).

IEC958 đang chọn
	Chọn đầu vào SPDIF, đầu vào CD bên trong (sai)
	và đầu vào bên ngoài (đúng).

Vòng lặp IEC958
	Dữ liệu đầu vào SPDIF được lặp lại vào SPDIF
	đầu ra (còn gọi là bỏ qua)

Bản quyền IEC958
	Đặt bit bản quyền.

IEC958 5V
	Chọn giao diện 0,5V (dỗ) hoặc 5V (quang).
	Trên một số thẻ, tính năng này không hoạt động và bạn cần thay đổi
	cấu hình với công tắc nhúng phần cứng.

IEC958 Trong màn hình
	Đầu vào SPDIF được định tuyến tới DAC.

IEC958 nghịch pha
	Đặt định dạng đầu vào SPDIF là nghịch đảo.
	[FIXME: tính năng này không hoạt động trên tất cả các chip..]

IEC958 hợp lệ
	Đặt phát hiện cờ hợp lệ đầu vào.

Lưu ý: Khi "Công tắc phát lại PCM" được bật, bạn sẽ nghe thấy đầu ra kỹ thuật số
truyền phát qua đầu ra analog.


AC3 (RAW DIGITAL) OUTPUT
----------------------------

Trình điều khiển hỗ trợ i/o kỹ thuật số thô (thường là AC3) trên SPDIF.  Cái này
có thể được chuyển đổi thông qua điều khiển phát lại IEC958, nhưng thông thường bạn cần phải
truy cập nó thông qua alsa-lib.  Xem tài liệu alsa-lib để biết thêm chi tiết.

Ở chế độ kỹ thuật số thô, "Công tắc phát lại PCM" sẽ tự động
được tắt để có thể nghe thấy dữ liệu không phải âm thanh từ đầu ra analog.
Tương tự, các công tắc sau đây đều tắt: "IEC958 Mix Analog" và
"Vòng lặp IEC958".  Các công tắc được tiếp tục lại sau khi đóng SPDIF PCM
thiết bị tự động về trạng thái trước đó.

Trên model 033, AC3 được triển khai bằng cách chuyển đổi phần mềm trong
alsa-lib.  Nếu bạn cần bỏ qua việc chuyển đổi phần mềm của IEC958
các khung con, hãy chuyển tùy chọn mô-đun "soft_ac3=0".  Điều này không quan trọng
trên các mẫu mới hơn.


ANALOG MIXER INTERFACE
----------------------

Giao diện mixer trên CM8x38 tương tự như SB16.
Có phát Master, PCM, Synth, CD, Line, Mic và Loa PC
khối lượng.  Synth, CD, Line và Mic có công tắc phát lại và thu âm,
cũng như SB16.

Ngoài bộ trộn SB tiêu chuẩn, CM8x38 còn cung cấp nhiều chức năng hơn.
- Công tắc phát lại PCM
- Công tắc chụp PCM (để chụp dữ liệu gửi đến DAC)
- Công tắc tăng cường Mic
- Âm lượng thu mic
- Công tắc / âm lượng phát lại và công tắc chụp Aux
- Công tắc điều khiển 3D


MIDI CONTROLLER
---------------

Với chip CMI8338, giao diện MPU401-UART bị tắt theo mặc định.
Bạn cần đặt tùy chọn mô-đun "mpu_port" thành địa chỉ cổng I/O hợp lệ
để kích hoạt hỗ trợ MIDI.  Các cổng I/O hợp lệ là 0x300, 0x310, 0x320 và
0x330.  Chọn một giá trị không xung đột với các thẻ khác.

Với CMI8738 và các chip mới hơn, giao diện MIDI được bật theo mặc định
và trình điều khiển sẽ tự động chọn địa chỉ cổng.

Có chức năng wavetable phần cứng ZZ0000ZZ trên chip này (ngoại trừ
OPL3 tổng hợp bên dưới).
Những gì được gọi là MIDI synth trên Windows là một trình tổng hợp phần mềm
thi đua.  Trên Linux, hãy sử dụng TiMidity hoặc chương trình softsynth khác để
chơi nhạc MIDI.


Tổng hợp FM OPL/3
--------------

FM OPL/3 cũng được bật làm mặc định chỉ cho thẻ đầu tiên.
Đặt tùy chọn mô-đun "fm_port" cho nhiều thẻ hơn.

Tuy nhiên, chất lượng đầu ra của FM OPL/3 rất kỳ lạ.
Tôi không biết tại sao ..

CMI8768 và các chip mới hơn không có bộ tổng hợp FM.


Cần điều khiển và Modem
------------------

Cần điều khiển kế thừa được hỗ trợ.  Để bật hỗ trợ cần điều khiển, hãy chuyển
tùy chọn joystick_port=1 mô-đun.  Giá trị 1 có nghĩa là tự động phát hiện.
Nếu việc tự động phát hiện không thành công, hãy thử chuyển địa chỉ I/O chính xác.

Modem được kích hoạt động thông qua công tắc điều khiển thẻ "Modem".


Thông tin gỡ lỗi
---------------------

Các thanh ghi được hiển thị trong /proc/asound/cardX/cmipci.  Nếu bạn có bất kỳ
vấn đề (đặc biệt là hành vi không mong muốn của máy trộn), vui lòng đính kèm
đầu ra của tệp Proc này cùng với báo cáo lỗi.
