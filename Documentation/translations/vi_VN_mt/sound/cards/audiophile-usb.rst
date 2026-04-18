.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/cards/audiophile-usb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================================================
Hướng dẫn sử dụng M-Audio Audiophile USB kèm ALSA và Jack
========================================================

v1.5

Thibault Le Meur <Thibault.LeMeur@supelec.fr>

Tài liệu này là tài liệu hướng dẫn sử dụng thiết bị M-Audio Audiophile USB(tm) với 
ALSA và JACK.

Lịch sử
=======

* v1.4 - Thibault Le Meur (2007-07-11)

- Đã thêm tính chất Low Endianness của chế độ 16 bit
    được tìm thấy bởi Hakan Lennestal <Hakan.Lennestal@brfsodrahamn.se>
  - Sửa đổi cấu trúc tài liệu

* v1.5 - Thibault Le Meur (2007-07-12)
  - Đã thêm thông tin mật khẩu AC3/DTS


Thông số kỹ thuật Audiophile USB và cách sử dụng đúng
======================================

Phần này là lời nhắc nhở về các thông tin quan trọng về chức năng và hạn chế 
của thiết bị.

Thiết bị có 4 giao diện âm thanh và 2 cổng MIDI:

* Đầu vào âm thanh nổi tương tự (Ai)

- Cổng này hỗ trợ 2 cặp đầu vào âm thanh cấp dòng (1/4" TS và RCA) 
   - Khi kết nối đầu nối 1/4" TS (giắc cắm), đầu nối RCA
     bị vô hiệu hóa

* Đầu ra âm thanh nổi tương tự (Ao)
 * Đầu vào âm thanh nổi kỹ thuật số (Di)
 * Đầu ra âm thanh nổi kỹ thuật số (Do)
 * Midi Trong (Mi)
 * Midi Out (Mo)

DAC/ADC bên trong có các đặc điểm sau:

* độ sâu mẫu 16 hoặc 24 bit
* tốc độ mẫu từ 8kHz đến 96kHz
* Hai giao diện không thể sử dụng các độ sâu mẫu khác nhau cùng một lúc.

Hơn nữa, tài liệu Audiophile USB đưa ra Cảnh báo sau:
  Vui lòng thoát mọi ứng dụng âm thanh đang chạy trước khi chuyển đổi giữa các độ sâu bit

Do giới hạn băng thông USB 1.1, có thể có một số giao diện hạn chế 
được kích hoạt cùng lúc tùy thuộc vào chế độ âm thanh được chọn:

* 16-bit/48kHz ==> 4 kênh vào + 4 kênh ra

- Ai+Ao+Di+Do

* 24-bit/48kHz ==> 4 kênh vào + 2 kênh ra, 
   hoặc 2 kênh vào + 4 kênh ra

- Ai+Ao+Do hoặc Ai+Di+Ao hoặc Ai+Di+Do hoặc Di+Ao+Do

* 24-bit/96kHz ==> 2 kênh vào _hoặc_ 2 kênh ra (chỉ bán song công)

- Ai hoặc Ao hoặc Di hoặc Do

Thông tin quan trọng về giao diện Kỹ thuật số:
--------------------------------------------

* Cổng Do còn hỗ trợ thêm tính năng truyền qua AC-3 và DTS được mã hóa xung quanh, 
   mặc dù tôi chưa thử nó trên Linux

- Lưu ý trong thiết lập này chỉ có thể kích hoạt giao diện Do

* Ngoài việc ghi lại luồng âm thanh kỹ thuật số, việc bật cổng Di là một cách 
   để đồng bộ hóa thiết bị với đồng hồ mẫu bên ngoài

- Do đó, cổng Di chỉ được kích hoạt nếu một Digital đang hoạt động. 
     nguồn được kết nối
   - Bật Di khi không có nguồn kỹ thuật số nào được kết nối có thể dẫn đến 
     lỗi đồng bộ hóa (ví dụ: âm thanh được phát ở tốc độ mẫu lẻ)


Hỗ trợ Audiophile USB MIDI trong ALSA
===================================

Các cổng Audiophile USB MIDI sẽ được hỗ trợ tự động sau khi
các mô-đun sau đã được tải:

* snd-usb-âm thanh
 * snd-seq-midi

Không cần cài đặt bổ sung.


Audiophile USB Hỗ trợ âm thanh trong ALSA
====================================

Chức năng âm thanh của thiết bị Audiophile USB được xử lý bởi snd-usb-audio 
mô-đun. Mô-đun này có thể hoạt động ở chế độ mặc định (không có bất kỳ thiết bị cụ thể nào 
tham số) hoặc ở chế độ "nâng cao" với tham số dành riêng cho thiết bị được gọi là 
ZZ0000ZZ.

Chế độ trình điều khiển Alsa mặc định
------------------------

Hành vi mặc định của trình điều khiển âm thanh snd-usb là liệt kê thiết bị 
khả năng khi khởi động và kích hoạt chế độ cần thiết khi được yêu cầu 
bởi các ứng dụng: ví dụ nếu người dùng đang ghi âm trong một 
Chế độ độ sâu 24 bit và ngay sau đó muốn chuyển sang chế độ độ sâu 16 bit,
mô-đun snd-usb-audio sẽ cấu hình lại thiết bị một cách nhanh chóng.

Cách tiếp cận này có ưu điểm là cho phép trình điều khiển tự động chuyển từ mẫu 
tốc độ/độ sâu tự động theo nhu cầu của người dùng. Tuy nhiên, những người 
đang sử dụng thiết bị trong Windows biết rằng đây không phải là cách thiết bị hoạt động
công việc: các ứng dụng trong Windows phải được đóng trước khi sử dụng điều khiển m-audio
bảng điều khiển để chuyển chế độ làm việc của thiết bị. Vì vậy, như chúng ta sẽ thấy trong phần tiếp theo, điều này 
Chế độ trình điều khiển Alsa mặc định có thể dẫn đến cấu hình sai thiết bị.

Bây giờ chúng ta hãy quay lại chế độ trình điều khiển Alsa mặc định.  Trong trường hợp này 
Giao diện Audiophile được ánh xạ tới các thiết bị alsa pcm sau đây 
cách (tôi cho rằng chỉ số của thiết bị là 1):

* hw:1,0 là Ao đang phát lại và Di đang chụp
 * hw:1,1 là Do khi phát lại và Ai đang chụp
 * hw:1,2 là Thực hiện ở chế độ chuyển qua AC3/DTS

Ở chế độ này, thiết bị sử dụng mã hóa byte Big Endian để 
định dạng âm thanh được hỗ trợ là S16_BE cho chế độ độ sâu 16 bit và S24_3BE cho 
Chế độ độ sâu 24 bit.

Một ngoại lệ là cổng hw:1,2 được báo cáo là Little Endian 
tuân thủ (được cho là hỗ trợ S16_LE) nhưng trên thực tế chỉ xử lý các luồng S16_BE.
Điều này đã được sửa trong kernel 2.6.23 trở lên và bây giờ là giao diện hw:1,2 
được báo cáo là big endian trong chế độ trình điều khiển mặc định này.

Ví dụ:

* phát tệp thô được mã hóa S24_3BE tới cổng Ao::

% aplay -D hw:1,0 -c2 -t raw -r48000 -fS24_3BE test.raw

* ghi lại tệp thô được mã hóa S24_3BE từ cổng Ai::

% arecord -D hw:1,1 -c2 -t raw -r48000 -fS24_3BE test.raw

* phát tệp thô được mã hóa S16_BE sang cổng Do::

% aplay -D hw:1,1 -c2 -t raw -r48000 -fS16_BE test.raw

* phát file mẫu ac3 sang cổng Do::

% aplay -D hw:1,2 --channels=6 ac3_S16_BE_encoded_file.raw

Nếu bạn hài lòng với chế độ trình điều khiển Alsa mặc định và không gặp bất kỳ 
vấn đề với chế độ này thì bạn có thể bỏ qua chương sau.

Thiết lập mô-đun nâng cao
---------------------

Do những hạn chế về phần cứng được mô tả ở trên, việc khởi tạo thiết bị được thực hiện 
bởi trình điều khiển Alsa ở chế độ mặc định có thể dẫn đến trạng thái bị hỏng của 
thiết bị. Ví dụ, một vấn đề đặc biệt khó chịu là âm thanh thu được 
từ giao diện Ai âm thanh bị méo (như thể được tăng cường ở mức cao quá mức
tăng khối lượng).

Đối với những người gặp vấn đề này, mô-đun snd-usb-audio có một mô-đun mới 
tham số được gọi là ZZ0000ZZ (tham số này đã được giới thiệu trong kernel
phát hành 2.6.17)

Khởi tạo chế độ làm việc của Audiophile USB
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Đối với thiết bị Audiophile USB, giá trị này cho phép người dùng 
chỉ định:

* độ sâu mẫu
 *tỷ lệ mẫu
 * cổng Di có được sử dụng hay không

Khi khởi tạo với ZZ0000ZZ, mô-đun âm thanh snd-usb có
hành vi tương tự như khi tham số bị bỏ qua (xem đoạn "Mặc định 
Chế độ trình điều khiển Alsa" ở trên)

Các chế độ khác được mô tả trong các tiểu mục sau.

Chế độ 16 bit
~~~~~~~~~~~~

Hai chế độ được hỗ trợ là:

* ZZ0000ZZ

- Chế độ 16bits 48kHz với Di bị tắt
   - Ai, Ao, Do có thể sử dụng cùng lúc
   - hw:1,0 không khả dụng ở chế độ chụp
   - hw:1,2 không có sẵn

* ZZ0000ZZ

- Chế độ 16bit 48kHz có bật Di
   - Ai,Ao,Di,Do có thể sử dụng cùng lúc
   - hw:1,0 có sẵn ở chế độ chụp
   - hw:1,2 không có sẵn

Ở chế độ này, thiết bị chỉ hoạt động ở chế độ 16 bit. Trước hạt nhân 2.6.23,
các thiết bị được báo cáo là Big-Endian trong khi thực tế chúng là Little-Endian
do đó việc phát một tệp là vấn đề sử dụng:
::

% aplay -D hw:1,1 -c2 -t raw -r48000 -fS16_BE test_S16_LE.raw

trong đó "test_S16_LE.raw" trên thực tế là một tệp mẫu nhỏ.

Cảm ơn Hakan Lennestal (người đã phát hiện ra Little-Endiannes của thiết bị trong
các chế độ này) một bản sửa lỗi đã được thực hiện (dự kiến ​​trong kernel 2.6.23) và
Alsa hiện báo cáo các giao diện Little-Endian. Do đó, việc phát một tập tin bây giờ cũng đơn giản như
sử dụng:
::

% aplay -D hw:1,1 -c2 -t raw -r48000 -fS16_LE test_S16_LE.raw


Chế độ 24-bit
~~~~~~~~~~~~

Ba chế độ được hỗ trợ là:

* ZZ0000ZZ

- Chế độ 24bit 48kHz với Di bị tắt
   - Ai, Ao, Do có thể sử dụng cùng lúc
   - hw:1,0 không khả dụng ở chế độ chụp
   - hw:1,2 không có sẵn

* ZZ0000ZZ

- Chế độ 24bit 48kHz có bật Di
   - Có thể sử dụng cùng lúc 3 cổng từ {Ai,Ao,Di,Do}
   - hw:1,0 khả dụng ở chế độ chụp và phải có nguồn kỹ thuật số đang hoạt động 
     kết nối với Di
   - hw:1,2 không có sẵn

* ZZ0000ZZ hoặc ZZ0001ZZ

- Chế độ 24bit 96kHz
   - Di được bật mặc định cho chế độ này nhưng không cần kết nối 
     tới nguồn hoạt động
   - Chỉ có thể sử dụng cùng lúc 1 cổng từ {Ai,Ao,Di,Do}
   - hw:1,0 có sẵn ở chế độ chụp
   - hw:1,2 không có sẵn

Trong các chế độ này, thiết bị chỉ tuân thủ Big-Endian (xem "Trình điều khiển Alsa mặc định 
mode" ở trên để biết ví dụ về lệnh aplay)

AC3 có chế độ truyền qua DTS
~~~~~~~~~~~~~~~~~~~~~~~~

Nhờ có Hakan Lennestal mà giờ tôi có báo cáo nói rằng chế độ này hoạt động.

* ZZ0000ZZ

- Chế độ 16bits 48kHz chỉ kích hoạt cổng Do 
   - AC3 với mật khẩu DTS
   - Chú ý với thiết lập này, cổng Do được ánh xạ tới thiết bị pcm hw:1,0

Dòng lệnh được sử dụng để phát lại các tệp .wav được mã hóa AC3/DTS ở chế độ này:
::

% aplay -D hw:1,0 --channels=6 ac3_S16_LE_encoded_file.raw

Cách sử dụng tham số ZZ0000ZZ
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tham số có thể được đưa ra:

* Bằng cách thăm dò thiết bị theo cách thủ công (với quyền root):::

# modprobe -r snd-usb-âm thanh
   # modprobe chỉ mục snd-usb-audio=1 device_setup=0x09

* Hoặc trong khi định cấu hình các tùy chọn mô-đun trong tệp cấu hình mô-đun của bạn
   (thường là tệp .conf trong thư mục /etc/modprobe.d/:::

bí danh snd-card-1 snd-usb-audio
       tùy chọn snd-usb-audio chỉ mục=1 device_setup=0x09

CAUTION khi khởi tạo thiết bị
-------------------------------------

* Việc khởi tạo đúng trên thiết bị yêu cầu device_setup được cấp cho
   mô-đun BEFORE thiết bị được bật. Vì vậy, nếu bạn sử dụng "thăm dò thủ công"
   phương pháp được mô tả ở trên, hãy chú ý bật nguồn thiết bị AFTER trong quá trình khởi tạo này.

* Không tôn trọng điều này sẽ dẫn đến cấu hình sai thiết bị. Trong trường hợp này
   tắt thiết bị, tháo mô-đun âm thanh snd-usb-audio, sau đó thăm dò lại bằng
   sửa tham số device_setup rồi (và chỉ sau đó) bật lại thiết bị.

* Nếu bạn đã khởi tạo chính xác thiết bị ở chế độ hợp lệ và sau đó muốn chuyển đổi
   sang chế độ khác (có thể với độ sâu mẫu khác), vui lòng sử dụng chế độ sau 
   thủ tục:

- đầu tiên tắt máy
   - hủy đăng ký mô-đun âm thanh snd-usb (modprobe -r)
   - thay đổi tham số device_setup bằng cách thay đổi device_setup
     tùy chọn trong ZZ0000ZZ
   - bật thiết bị

* Một giải pháp cho vấn đề cuối cùng này đã được áp dụng cho kernel 2.6.23, nhưng có thể không
   đủ để đảm bảo “sự ổn định” của quá trình khởi tạo thiết bị.

Chi tiết kỹ thuật dành cho tin tặc
-----------------------------

Phần này dành cho hacker, muốn tìm hiểu chi tiết về máy
nội bộ và cách Alsa hỗ trợ nó.

Cấu trúc ZZ0000ZZ của Audiophile USB
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Nếu bạn muốn hiểu những con số kỳ diệu về device_setup dành cho Audiophile 
USB, bạn cần có hiểu biết rất cơ bản về tính toán nhị phân. Tuy nhiên, 
điều này không bắt buộc phải sử dụng tham số và bạn có thể bỏ qua phần này.

device_setup dài một byte và cấu trúc của nó như sau:
::

+---+---+---+---+---+---+---+---+
       ZZ0000ZZ b6| b5| b4| b3| b2| b1| b0|
       +---+---+---+---+---+---+---+---+
       ZZ0004ZZ 0 ZZ0005ZZ Di|24B|96K|DTS|SET|
       +---+---+---+---+---+---+---+---+

Ở đâu:

* b0 là bit ZZ0000ZZ

- MUST được đặt nếu device_setup được khởi tạo

* b1 là bit ZZ0000ZZ

- nó chỉ được đặt cho đầu ra Kỹ thuật số với DTS/AC3
   - thiết lập này chưa được thử nghiệm

* b2 là cờ chọn Tỷ lệ

- Khi được đặt thành ZZ0000ZZ, dải tốc độ là 48,1-96kHz
   - Nếu không thì phạm vi tốc độ mẫu là 8-48kHz

* b3 là cờ chọn độ sâu bit

- Khi đặt thành ZZ0000ZZ, các mẫu có độ dài 24 bit
   - Nếu không thì chúng dài 16 bit
   - Lưu ý rằng b2 ngụ ý b3 vì chế độ 96kHz chỉ được hỗ trợ cho 24 bit 
     mẫu vật

* b4 là cờ đầu vào Kỹ thuật số

- Khi được đặt thành ZZ0000ZZ, thiết bị giả định rằng nguồn kỹ thuật số đang hoạt động là 
     đã kết nối 
   - Bạn không nên kích hoạt Di nếu không thấy nguồn trên cổng (điều này dẫn đến 
     vấn đề đồng bộ hóa)
   - b4 được ngụ ý bởi b2 (vì mỗi lần chỉ có một cổng được bật nên không có đồng bộ hóa 
     có thể xảy ra lỗi)

* b5 đến b7 được dành riêng cho việc sử dụng trong tương lai và phải được đặt thành ZZ0000ZZ

- có thể trở thành Ao, Do, Ai, tương ứng với b7, b6, b4

Thận trọng:

* không có sự kiểm tra nào về giá trị bạn sẽ cung cấp cho device_setup

- ví dụ: chọn 0x05 (16 bit 96kHz) sẽ không quay lại 0x09 vì 
     b2 ngụ ý b3. Nhưng _there_will_be_no_warning_ trong /var/log/messages

* Chưa kiểm tra các hạn chế về phần cứng do giới hạn bus USB

- chọn b2 sẽ chuẩn bị tất cả các giao diện cho 24bits/96kHz nhưng bạn sẽ
     chỉ có thể sử dụng một cái cùng một lúc

Chi tiết triển khai USB cho thiết bị này
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Bạn có thể yên tâm bỏ qua phần này nếu bạn không quan tâm đến driver 
hack.

Phần này mô tả một số khía cạnh bên trong của thiết bị và tóm tắt 
dữ liệu tôi nhận được bằng cách rình mò usb các trình điều khiển windows và Linux.

M-Audio Audiophile USB có 7 giao diện USB:
"Giao diện USB":

* Giao diện USB nb.0
 * Giao diện USB nb.1

- Chức năng điều khiển âm thanh

* Giao diện USB nb.2

- Đầu ra tương tự

* Giao diện USB nb.3

- Đầu ra kỹ thuật số

* Giao diện USB nb.4

- Đầu vào tương tự

* Giao diện USB nb.5

- Đầu vào kỹ thuật số

* Giao diện USB nb.6

- Giao diện MIDI tương thích với tiêu chuẩn MIDIMAN

Mỗi giao diện có 5 cài đặt thay thế (AltSet 1,2,3,4,5) ngoại trừ:

* Giao diện 3 (Digital Out) có thêm Alset nb.6 
 * Giao diện 5 (Digital In) không có Alset nb.3 và 5

Dưới đây là mô tả ngắn gọn về các khả năng của AltSettings:

* AltSettings 1 tương ứng với

- Độ sâu 24 bit, chế độ mẫu 48,1-96kHz
  - Phát lại thích ứng (Ao và Do), Chụp đồng bộ (Ai) hoặc Chụp không đồng bộ (Di)

* AltSettings 2 tương ứng với

- Độ sâu 24-bit, chế độ mẫu 8-48kHz
  - Chụp và phát lại không đồng bộ (Ao,Ai,Do,Di)

* AltSettings 3 tương ứng với

- Độ sâu 24-bit, chế độ mẫu 8-48kHz
  - Chụp đồng bộ (Ai) và Phát lại thích ứng (Ao,Do)

* AltSettings 4 tương ứng với

- Độ sâu 16 bit, chế độ mẫu 8-48kHz
  - Chụp và phát lại không đồng bộ (Ao,Ai,Do,Di)

* AltSettings 5 ​​tương ứng với

- Độ sâu 16 bit, chế độ mẫu 8-48kHz
  - Chụp đồng bộ (Ai) và Phát lại thích ứng (Ao,Do)

* AltSettings 6 tương ứng với

- Độ sâu 16 bit, chế độ mẫu 8-48kHz
  - Phát lại đồng bộ (Do), loại định dạng âm thanh III IEC1937_AC-3

Để đảm bảo khởi tạo thiết bị chính xác, trình điều khiển 
ZZ0000ZZ ZZ0001ZZ thiết bị sẽ được sử dụng như thế nào:

* nếu DTS được chọn, chỉ phải có Giao diện 2 với AltSet nb.6
   đã đăng ký
 * nếu chỉ 96KHz thì phải chọn AltSets nb.1 của mỗi giao diện
 * nếu các mẫu đang sử dụng 24bits/48KHz thì tôi phải sử dụng AltSet 2 nếu
   Đầu vào kỹ thuật số được kết nối và chỉ AltSet nb.3 nếu đầu vào Kỹ thuật số
   không được kết nối
 * nếu các mẫu đang sử dụng 16bits/48KHz thì tôi phải sử dụng AltSet 4 nếu
   Đầu vào kỹ thuật số được kết nối và chỉ AltSet nb.5 nếu đầu vào Kỹ thuật số
   không được kết nối

Khi device_setup được cung cấp làm tham số cho mô-đun âm thanh snd-usb, 
Hàm phân tích cú pháp_audio_endpoints sử dụng một thuật ngữ gọi là 
ZZ0000ZZ để ngăn AltSettings không 
tương ứng với device_setup được đăng ký trong trình điều khiển.

Hỗ trợ Audiophile USB và Jack
===============================

Phần này đề cập đến sự hỗ trợ của thiết bị Audiophile USB trong Jack.

Có 2 vấn đề tiềm ẩn chính khi sử dụng Jackd với thiết bị:

* hỗ trợ cho các thiết bị Big-Endian ở chế độ 24-bit
* hỗ trợ các kênh 4 vào / 4 ra

Hỗ trợ trực tiếp tại Jackd
-----------------------

Jack chỉ hỗ trợ các thiết bị endian lớn trong các phiên bản gần đây (nhờ
Andreas Steinmetz cho bản vá lỗi lớn đầu tiên của anh ấy). Tôi không thể nhớ 
chính xác là khi hỗ trợ này được phát hành vào jackd, hãy nói rằng
với jackd version 0.103.0 thì gần như ổn (chỉ một lỗi nhỏ là ảnh hưởng 
Các thiết bị Big-Endian 16 bit, nhưng vì bạn đã đọc kỹ phần trên
các đoạn văn, hiện bạn đang sử dụng kernel >= 2.6.23 và các thiết bị 16bit của mình 
bây giờ là Little Endians ;-) ).

Bạn có thể chạy jackd bằng lệnh sau để phát lại với Ao và
ghi âm với Ai:
::

% jackd -R -dalsa -Phw:1,0 -r48000 -p128 -n2 -D -Chw:1,1

Sử dụng Alsa plughw
-----------------

Nếu bạn chưa cài đặt Jackd gần đây, bạn có thể hạ cấp xuống sử dụng
bộ chuyển đổi Alsa ZZ0000ZZ.

Ví dụ: đây là một cách để chạy Jack với 2 kênh phát lại trên Ao và 2 
bắt kênh từ Ai:
::

% jackd -R -dalsa -dplughw:1 -r48000 -p256 -n2 -D -Cplughw:1,1

Tuy nhiên, bạn có thể thấy thông báo cảnh báo sau:
  Có vẻ như bạn đang sử dụng lớp "plug" phần mềm ALSA, có thể là do 
  sử dụng thiết bị ALSA "mặc định". Điều này kém hiệu quả hơn mức có thể. 
  Hãy cân nhắc việc sử dụng một thiết bị phần cứng thay vì sử dụng lớp phích cắm.

Bắt 2 giao diện đầu vào và/hoặc đầu ra trong Jack
------------------------------------------------

Như bạn có thể thấy, khởi động máy chủ Jack theo cách này sẽ chỉ kích hoạt 1 âm thanh nổi
đầu vào (Di hoặc Ai) và 1 đầu ra âm thanh nổi (Ao hoặc Do).

Điều này là do những hạn chế sau:

* Jack chỉ có thể mở một thiết bị chụp và một thiết bị phát lại cùng một lúc
* Audiophile USB được coi là 2 (hoặc ba) thiết bị Alsa: hw:1,0, hw:1,1
  (và tùy chọn hw:1,2)

Nếu bạn muốn nhận được hỗ trợ Ai+Di và/hoặc Ao+Do với Jack, bạn cần phải
kết hợp các thiết bị Alsa thành một thiết bị logic "phức tạp".

Nếu bạn muốn thử, tôi khuyên bạn nên đọc thông tin từ
trang này: ZZ0000ZZ
Nó liên quan đến một thiết bị khác (ice1712) nhưng có thể được điều chỉnh cho phù hợp
Audiophile USB.

Việc kích hoạt nhiều giao diện Audiophile USB cho Jackd chắc chắn sẽ yêu cầu:

* Đảm bảo phiên bản Jackd của bạn có bản vá MMAP_COMPLEX (xem trang Ice1712)
* (có thể) vá tệp alsa-lib/src/pcm/pcm_multi.c (xem trang Ice1712)
* xác định nhiều thiết bị (kết hợp hw:1,0 và hw:1,1) trong .asoundrc của bạn
  tập tin 
* bắt đầu jackd với thiết bị này

Hiện tại tôi chưa thành công trong việc thử nghiệm loại này, nếu bạn thành công với loại này 
của quá trình thiết lập, vui lòng gửi email cho tôi.
