.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/designs/oss-emulation.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Lưu ý về mô phỏng Kernel OSS
================================

Ngày 22 tháng 1 năm 2004 Takashi Iwai <tiwai@suse.de>


Mô-đun
=======

ALSA cung cấp mô phỏng OSS mạnh mẽ trên kernel.
Việc mô phỏng OSS cho các thiết bị PCM, bộ trộn và trình sắp xếp thứ tự được triển khai
như các mô-đun hạt nhân bổ sung, snd-pcm-oss, snd-mixer-oss và snd-seq-oss.
Khi bạn cần truy cập OSS PCM, thiết bị trộn hoặc trình sắp xếp thứ tự,
mô-đun tương ứng phải được tải.

Các mô-đun này được tải tự động khi dịch vụ tương ứng
được gọi.  Bí danh được xác định là ZZ0000ZZ, trong đó x và y là
số thẻ và số đơn vị phụ.  Thông thường bạn không cần phải
tự mình xác định các bí danh này.

Bước cần thiết duy nhất để tự động tải các mô-đun OSS là xác định
bí danh thẻ trong ZZ0000ZZ, chẳng hạn như::

bí danh sound-slot-0 snd-emu10k1

Là thẻ thứ hai, hãy xác định ZZ0000ZZ.
Lưu ý rằng bạn không thể sử dụng tên bí danh làm tên mục tiêu (tức là
ZZ0001ZZ không còn hoạt động như cũ nữa
modutils).

Cấu hình OSS hiện có sẵn được hiển thị trong
/proc/asound/oss/sndstat.  Điều này thể hiện theo cú pháp tương tự của
/dev/sndstat, có sẵn trên trình điều khiển OSS thương mại.
Trên ALSA, bạn có thể liên kết tượng trưng /dev/sndstat với tệp Proc này.

Xin lưu ý rằng các thiết bị được liệt kê trong tệp Proc này chỉ xuất hiện
sau khi mô-đun mô phỏng OSS tương ứng được tải.  Đừng lo lắng
ngay cả khi "NOT ENABLED IN CONFIG" được hiển thị trong đó.


Ánh xạ thiết bị
==============

ALSA hỗ trợ các tệp thiết bị OSS sau:
::

PCM:
		/dev/dspX
		/dev/adspX

Máy trộn:
		/dev/mixerX

MIDI:
		/dev/midi0X
		/dev/amidi0X

Trình sắp xếp thứ tự:
		/dev/trình tự sắp xếp
		/dev/sequencer2 (hay còn gọi là /dev/music)

trong đó X là số thẻ từ 0 đến 7.

(NOTE: Một số bản phân phối có các tệp thiết bị như /dev/midi0 và
/dev/midi1.  Chúng là NOT dành cho OSS nhưng dành cho tclmidi, tức là
một điều hoàn toàn khác.)

Không giống như OSS thật, ALSA không thể sử dụng các tệp thiết bị nhiều hơn
những người được giao.  Ví dụ: thẻ đầu tiên không thể sử dụng /dev/dsp1 hoặc
/dev/dsp2, nhưng chỉ /dev/dsp0 và /dev/adsp0.

Như đã thấy ở trên, PCM và MIDI có thể có hai thiết bị.  Thông thường, lần đầu tiên
Thiết bị PCM (ZZ0000ZZ trong ALSA) được ánh xạ tới/dev/dsp và thiết bị phụ
thiết bị (ZZ0001ZZ) tới /dev/adsp (nếu có).  Đối với MIDI, /dev/midi và
/dev/amidi tương ứng.

Bạn có thể thay đổi ánh xạ thiết bị này thông qua các tùy chọn mô-đun của
snd-pcm-oss và snd-rawmidi.  Trong trường hợp PCM, như sau
các tùy chọn có sẵn cho snd-pcm-oss:

dsp_map
	Số thiết bị PCM được gán cho /dev/dspX
	(mặc định = 0)
bản đồ quảng cáo
	Số thiết bị PCM được chỉ định cho /dev/adspX
	(mặc định = 1)

Ví dụ: để ánh xạ thiết bị PCM thứ ba (ZZ0000ZZ) tới /dev/adsp0,
xác định như thế này:
::

tùy chọn snd-pcm-oss adsp_map=2

Các tùy chọn có mảng.  Để định cấu hình thẻ thứ hai, hãy chỉ định
hai mục cách nhau bằng dấu phẩy.  Ví dụ: để ánh xạ PCM thứ ba
thiết bị trên thẻ thứ hai tới /dev/adsp1, xác định như bên dưới:
::

tùy chọn snd-pcm-oss adsp_map=0,2

Để thay đổi ánh xạ của thiết bị MIDI, các tùy chọn sau là
có sẵn cho snd-rawmidi:

midi_map
	Số thiết bị MIDI được gán cho /dev/midi0X
	(mặc định = 0)
amidi_map
	Số thiết bị MIDI được gán cho /dev/amidi0X
	(mặc định = 1)

Ví dụ: để gán thiết bị MIDI thứ ba trên thẻ đầu tiên cho
/dev/midi00, xác định như sau:
::

tùy chọn snd-rawmidi midi_map=2


Chế độ PCM
========

Theo mặc định, ALSA mô phỏng OSS PCM với cái gọi là lớp plugin,
tức là cố gắng chuyển đổi định dạng, tốc độ hoặc kênh mẫu
tự động khi thẻ không hỗ trợ nó.
Điều này sẽ dẫn đến một số vấn đề đối với một số ứng dụng như động đất hoặc
rượu vang, đặc biệt nếu họ chỉ sử dụng thẻ ở chế độ MMAP.

Trong trường hợp như vậy, bạn có thể thay đổi hành vi của PCM cho mỗi ứng dụng bằng cách
viết lệnh vào tập tin Proc.  Có một tệp Proc cho mỗi PCM
luồng, ZZ0000ZZ, trong đó X là số thẻ
(dựa trên 0), Y số thiết bị PCM (dựa trên 0) và ZZ0001ZZ dành cho
phát lại và ZZ0002ZZ để chụp tương ứng.  Lưu ý rằng tập tin Proc này
chỉ tồn tại sau khi mô-đun snd-pcm-oss được tải.

Chuỗi lệnh có cú pháp sau:
::

mảnh app_name mảnh_size [tùy chọn]

ZZ0000ZZ là tên của ứng dụng có (mức độ ưu tiên cao hơn) hoặc không có
con đường.
ZZ0001ZZ chỉ định số lượng đoạn hoặc bằng 0 nếu không có thông số cụ thể
số được đưa ra.
ZZ0002ZZ là kích thước của đoạn tính bằng byte hoặc bằng 0 nếu không được cung cấp.
ZZ0003ZZ là tham số tùy chọn.  Các tùy chọn sau đây là
có sẵn:

vô hiệu hóa
	ứng dụng cố gắng mở một thiết bị pcm để
	kênh này nhưng không muốn sử dụng nó.
trực tiếp
	không sử dụng plugin
khối
	buộc chế độ mở khối
không chặn
	buộc chế độ mở không chặn
một phần mảnh
	cũng ghi các đoạn một phần (chỉ ảnh hưởng đến việc phát lại)
không im lặng
	đừng lấp đầy sự im lặng phía trước để tránh nhấp chuột

Tùy chọn ZZ0000ZZ hữu ích khi một hướng luồng (phát lại hoặc
capture) không được ứng dụng xử lý chính xác mặc dù
bản thân phần cứng hỗ trợ cả hai hướng.
Tùy chọn ZZ0001ZZ được sử dụng, như đã đề cập ở trên, để bỏ qua quá trình tự động
chuyển đổi và hữu ích cho các ứng dụng MMAP.
Ví dụ: để phát lại thiết bị PCM đầu tiên không có plugin cho
quake, gửi lệnh qua echo như sau:
::

% echo "quake 0 0 direct" > /proc/asound/card0/pcm0p/oss

Trong khi quake chỉ muốn phát lại, bạn có thể thêm lệnh thứ hai
để thông báo cho tài xế sắp được phân bổ chỉ hướng này:
::

% echo "vô hiệu hóa trận động đất 0 0" > /proc/asound/card0/pcm0c/oss

Quyền của tệp Proc phụ thuộc vào tùy chọn mô-đun của snd.
Theo mặc định, nó được đặt là root, vì vậy bạn có thể cần phải là siêu người dùng để
gửi lệnh trên.

Các tùy chọn chặn và không chặn được sử dụng để thay đổi hành vi của
mở tập tin thiết bị.

Theo mặc định, ALSA hoạt động như trình điều khiển OSS gốc, tức là không chặn
tập tin khi nó bận. Lỗi -EBUSY được trả về trong trường hợp này.

Hành vi chặn này có thể được thay đổi trên toàn cầu thông qua nonblock_open
tùy chọn mô-đun của snd-pcm-oss.  Để sử dụng chế độ chặn làm mặc định
đối với thiết bị OSS, hãy xác định như sau:
::

tùy chọn snd-pcm-oss nonblock_open=0

Các lệnh ZZ0000ZZ và ZZ0001ZZ đã được thêm gần đây.
Cả hai lệnh chỉ nhằm mục đích tối ưu hóa.  Lệnh cũ
chỉ định chỉ thực hiện chuyển giao ghi khi toàn bộ đoạn được
đầy.  Cái sau dừng ghi dữ liệu im lặng phía trước
tự động.  Cả hai đều bị tắt theo mặc định.

Bạn có thể kiểm tra cấu hình hiện được xác định bằng cách đọc quy trình
tập tin.  Hình ảnh đã đọc có thể được gửi lại đến tệp Proc, do đó bạn
có thể lưu cấu hình hiện tại
::

% cat /proc/asound/card0/pcm0p/oss > /somewhere/oss-cfg

và khôi phục nó như thế nào
::

% cat /somewhere/oss-cfg > /proc/asound/card0/pcm0p/oss

Ngoài ra, để xóa tất cả cấu hình hiện tại, hãy gửi lệnh ZZ0000ZZ
như dưới đây:
::

% echo "xóa" > /proc/asound/card0/pcm0p/oss


Yếu tố trộn
==============

Vì ALSA có giao diện bộ trộn hoàn toàn khác nên việc mô phỏng
Máy trộn OSS tương đối phức tạp.  ALSA xây dựng phần tử trộn
từ một số điều khiển ALSA (bộ trộn) khác nhau dựa trên tên
chuỗi.  Ví dụ: phần tử âm lượng SOUND_MIXER_PCM được tạo thành
từ các nút điều khiển "Âm lượng phát lại PCM" và "Công tắc phát lại PCM" cho
hướng phát lại và từ "PCM Capture Volume" và "PCM Capture
Switch" cho thư mục chụp (nếu có).  Khi âm lượng PCM của
OSS được thay đổi, tất cả các nút điều chỉnh âm lượng và công tắc ở trên đều được điều chỉnh
tự động.

Theo mặc định, ALSA sử dụng điều khiển sau cho các ổ đĩa OSS:

=========================================== =====
Chỉ số điều khiển âm lượng OSS ALSA
=========================================== =====
SOUND_MIXER_VOLUME Chủ 0
Điều khiển âm thanh SOUND_MIXER_BASS - Bass 0
Điều khiển âm thanh SOUND_MIXER_TREBLE - Treble 0
SOUND_MIXER_SYNTH Tổng hợp 0
SOUND_MIXER_PCM PCM 0
Loa PC SOUND_MIXER_SPEAKER 0
SOUND_MIXER_LINE Dòng 0
SOUND_MIXER_MIC Mic 0
SOUND_MIXER_CD CD 0
SOUND_MIXER_IMIX Hỗn hợp màn hình 0
SOUND_MIXER_ALTPCM PCM 1
SOUND_MIXER_RECLEV (chưa được chỉ định)
SOUND_MIXER_IGAIN Chụp 0
SOUND_MIXER_OGAIN Phát lại 0
SOUND_MIXER_LINE1 Aux 0
SOUND_MIXER_LINE2 Aux 1
SOUND_MIXER_LINE3 Aux 2
SOUND_MIXER_DIGITAL1 kỹ thuật số 0
SOUND_MIXER_DIGITAL2 kỹ thuật số 1
SOUND_MIXER_DIGITAL3 kỹ thuật số 2
SOUND_MIXER_PHONEIN Điện thoại 0
SOUND_MIXER_PHONEOUT Điện thoại 1
SOUND_MIXER_VIDEO Video 0
Đài phát thanh SOUND_MIXER_RADIO 0
Màn hình SOUND_MIXER_MONITOR 0
=========================================== =====

Cột thứ hai là chuỗi cơ sở của ALSA tương ứng
kiểm soát.  Trên thực tế, các điều khiển với ZZ0000ZZ cũng sẽ được kiểm tra.

Việc phân công hiện tại của các phần tử bộ trộn này được liệt kê trong quy trình
tệp, /proc/asound/cardX/oss_mixer, tệp này sẽ giống như sau
::

VOLUME "Bậc thầy" 0
	BASS "" 0
	TREBLE "" 0
	SYNTH "" 0
	PCM "PCM" 0
	...

trong đó cột đầu tiên là phần tử khối OSS, cột thứ hai
chuỗi cơ sở của điều khiển ALSA tương ứng và chuỗi thứ ba là
chỉ số kiểm soát  Khi chuỗi trống, điều đó có nghĩa là
điều khiển OSS tương ứng không có sẵn.

Để thay đổi bài tập, bạn có thể viết cấu hình vào đây
tập tin proc.  Ví dụ: để ánh xạ "Wave Playback" tới âm lượng PCM,
gửi lệnh như sau:
::

% echo 'VOLUME "Phát lại sóng" 0' > /proc/asound/card0/oss_mixer

Lệnh này hoàn toàn giống với lệnh được liệt kê trong tệp Proc.  bạn có thể
thay đổi một hoặc nhiều thành phần, một tập trên mỗi dòng.  Cuối cùng
ví dụ: cả "Âm lượng phát lại sóng" và "Chuyển phát lại sóng" sẽ
bị ảnh hưởng khi âm lượng PCM bị thay đổi.

Giống như trường hợp của tệp proc PCM, quyền của tệp proc phụ thuộc vào
các tùy chọn mô-đun của snd.  bạn có thể sẽ cần phải là siêu người dùng cho
gửi lệnh trên.

Cũng như trong trường hợp tệp Proc PCM, bạn có thể lưu và khôi phục
cấu hình bộ trộn hiện tại bằng cách đọc và ghi toàn bộ tệp
hình ảnh.


Luồng song công
==============

Lưu ý rằng khi cố gắng sử dụng một tập tin thiết bị duy nhất để phát lại và
chụp, OSS API không cung cấp cách nào để đặt định dạng, tốc độ mẫu hoặc
số lượng kênh khác nhau theo từng hướng.  Như vậy
::

io_handle = open("thiết bị", O_RDWR)

sẽ chỉ hoạt động chính xác nếu các giá trị giống nhau ở mỗi hướng.

Để sử dụng các giá trị khác nhau theo hai hướng, hãy sử dụng cả hai
::

input_handle = open("thiết bị", O_RDONLY)
	đầu ra_handle = open("thiết bị", O_WRONLY)

và đặt các giá trị cho tay cầm tương ứng.


Các tính năng không được hỗ trợ
====================

MMAP trên trình điều khiển ICE1712
----------------------
ICE1712 chỉ hỗ trợ định dạng độc đáo, xen kẽ
Định dạng 10 kênh 24bit (được đóng gói ở dạng 32bit).  Vì vậy bạn không thể mmap
bộ đệm ở định dạng thông thường (mono hoặc 2 kênh, 8 hoặc 16bit)
trên OSS.
