.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/designs/seq-oss.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================
Mô phỏng trình tự OSS trên ALSA
===============================

Bản quyền (c) 1998,1999 của Takashi Iwai

ver.0.1.8; Ngày 16 tháng 11 năm 1999

Sự miêu tả
===========

Thư mục này chứa trình điều khiển mô phỏng trình sắp xếp OSS trên ALSA. Lưu ý
rằng chương trình này vẫn đang trong giai đoạn phát triển.

Điều này có tác dụng gì - nó cung cấp sự mô phỏng của trình sắp xếp thứ tự OSS, truy cập
thông qua các thiết bị ZZ0000ZZ và ZZ0001ZZ.
Hầu hết các ứng dụng sử dụng OSS đều có thể chạy được nếu ALSA phù hợp
trình sắp xếp đã được chuẩn bị.

Các tính năng sau được mô phỏng bởi trình điều khiển này:

* Trình sắp xếp thông thường và các sự kiện MIDI:

Chúng được chuyển đổi thành các sự kiện tuần tự ALSA và được gửi đến
    cổng tương ứng.

* Sự kiện hẹn giờ:

Không thể chọn bộ hẹn giờ bằng ioctl. Tỷ lệ kiểm soát được cố định
    100 bất kể HZ. Nghĩa là, ngay cả trên hệ thống Alpha, luôn luôn có một dấu tích
    1/100 giây. Tốc độ cơ bản và nhịp độ có thể được thay đổi trong ZZ0000ZZ.

* Tải bản vá:

Nó hoàn toàn phụ thuộc vào trình điều khiển tổng hợp liệu nó có được hỗ trợ hay không
    việc tải bản vá được thực hiện bằng cách gọi lại trình điều khiển tổng hợp.

* Điều khiển vào/ra:

Hầu hết các điều khiển được chấp nhận. Một số điều khiển
    phụ thuộc vào trình điều khiển tổng hợp, cũng như thậm chí vào OSS gốc.

Hơn nữa, bạn có thể tìm thấy các tính năng nâng cao sau:

* Cơ chế xếp hàng tốt hơn:

Các sự kiện được xếp hàng đợi trước khi xử lý chúng.

* Nhiều ứng dụng:

Bạn có thể chạy hai hoặc nhiều ứng dụng cùng lúc (ngay cả đối với OSS
    trình sắp xếp thứ tự)!
    Tuy nhiên, mỗi thiết bị MIDI là độc quyền - nghĩa là nếu thiết bị MIDI
    ứng dụng nào đó mở được 1 lần, ứng dụng khác không dùng được
    nó. Không có hạn chế như vậy trong các thiết bị tổng hợp.

* Xử lý sự kiện theo thời gian thực:

Các sự kiện có thể được xử lý trong thời gian thực mà không cần sử dụng outbound
    ioctl. Để chuyển sang chế độ thời gian thực, hãy gửi sự kiện ABSTIME 0. Tiếp theo
    các sự kiện sẽ được xử lý theo thời gian thực mà không cần xếp hàng đợi. Để tắt
    chế độ thời gian thực, gửi sự kiện RELTIME 0.

* Giao diện ZZ0000ZZ:

Trạng thái của ứng dụng và thiết bị có thể được hiển thị thông qua
    ZZ0000ZZ bất cứ lúc nào. Trong phiên bản sau,
    cấu hình cũng sẽ được thay đổi thông qua giao diện ZZ0001ZZ.


Cài đặt
============

Chạy tập lệnh định cấu hình với cả hỗ trợ trình sắp xếp thứ tự (ZZ0000ZZ)
và các tùy chọn mô phỏng OSS (ZZ0001ZZ). Một mô-đun ZZ0002ZZ
sẽ được tạo ra. Nếu mô-đun tổng hợp của card âm thanh của bạn hỗ trợ OSS
mô phỏng (cho đến nay chỉ có trình điều khiển Emu8000), mô-đun này sẽ được tải
tự động.
Nếu không, bạn cần tải mô-đun này theo cách thủ công.

Lúc đầu, mô-đun này thăm dò tất cả các cổng MIDI đã được
đã được kết nối với trình sắp xếp thứ tự. Sau đó, việc tạo và xóa
số cổng được theo dõi bằng cơ chế thông báo của trình sắp xếp ALSA.

Có thể tìm thấy các thiết bị synth và MIDI có sẵn trong giao diện Proc.
Chạy ZZ0000ZZ và kiểm tra các thiết bị. Ví dụ,
nếu bạn sử dụng thẻ AWE64, bạn sẽ thấy như sau:
::

Phiên bản mô phỏng trình tự tuần tự OSS 0.1.8
    Số khách hàng ALSA 63
    Cổng thu ALSA 0

Số lượng đơn đăng ký: 0

Số lượng thiết bị tổng hợp: 1
    tổng hợp 0: [EMU8000]
      gõ 0x1 : kiểu con 0x20 : giọng nói 32
      khả năng: đã bật ioctl/bật Load_patch

Số lượng thiết bị MIDI: 3
    midi 0: [Cổng Emu8000-0] Cổng ALSA 65:0
      khả năng ghi/mở không có

midi 1: [Cổng Emu8000-1] Cổng ALSA 65:1
      khả năng ghi/mở không có

midi 2: [0: MPU-401 (UART)] Cổng ALSA 64:0
      khả năng đọc/ghi/mở không có

Lưu ý rằng số thiết bị có thể khác với thông tin của
ZZ0000ZZ hoặc trình điều khiển OSS gốc.
Sử dụng số thiết bị được liệt kê trong ZZ0001ZZ
để chơi thông qua mô phỏng trình sắp xếp OSS.

Sử dụng thiết bị tổng hợp
=========================

Chạy chương trình yêu thích của bạn. Tôi đã thử nghiệm playmidi-2.4, awemidi-0.4.3, gmod-3.1
và xmp-1.1.5. Bạn có thể tải mẫu qua ZZ0000ZZ như sfxload,
quá.

Nếu trình điều khiển cấp thấp hỗ trợ nhiều quyền truy cập vào các thiết bị tổng hợp (như
Trình điều khiển Emu8000), hai hoặc nhiều ứng dụng được phép chạy cùng một lúc
thời gian.

Sử dụng thiết bị MIDI
==================

Cho đến nay, chỉ có đầu ra MIDI được thử nghiệm. Đầu vào MIDI hoàn toàn không được kiểm tra,
nhưng hy vọng nó sẽ hoạt động. Sử dụng số thiết bị được liệt kê trong
ZZ0000ZZ.
Xin lưu ý rằng những con số này hầu hết khác với danh sách trong
ZZ0001ZZ.

Tùy chọn mô-đun
==============

Có sẵn các tùy chọn mô-đun sau:

maxqlen
  chỉ định độ dài hàng đợi đọc/ghi tối đa. Hàng đợi này là riêng tư
  đối với trình sắp xếp thứ tự OSS, sao cho nó độc lập với độ dài hàng đợi của ALSA
  trình sắp xếp thứ tự. Giá trị mặc định là 1024.

seq_oss_debug
  chỉ định mức gỡ lỗi và chấp nhận 0 (= không có thông báo gỡ lỗi) hoặc
  số nguyên dương. Giá trị mặc định là 0.

Cơ chế xếp hàng
===============

Mô phỏng trình sắp xếp OSS sử dụng hàng đợi ưu tiên ALSA. các
các sự kiện từ ZZ0000ZZ được xử lý và đưa vào hàng đợi
được chỉ định bởi tùy chọn mô-đun.

Tất cả các sự kiện từ ZZ0000ZZ đều được phân tích cú pháp ngay từ đầu.
Các sự kiện về thời gian cũng được phân tích tại thời điểm này, do đó các sự kiện có thể
được xử lý theo thời gian thực. Gửi một sự kiện ABSTIME 0 chuyển đổi hoạt động
sang chế độ thời gian thực và gửi sự kiện RELTIME 0 sẽ tắt chế độ này.
Ở chế độ thời gian thực, tất cả các sự kiện sẽ được gửi đi ngay lập tức.

Các sự kiện được xếp hàng đợi được gửi đến trình sắp xếp ALSA tương ứng
cổng sau thời gian đã lên lịch bởi bộ điều phối trình sắp xếp ALSA.

Nếu hàng đợi ghi đầy, ứng dụng sẽ ngủ cho đến một mức nhất định
(mặc định là một nửa) trở nên trống trong chế độ chặn. Sự đồng bộ hóa
để viết thời gian cũng được thực hiện.

Đầu vào từ các thiết bị MIDI hoặc các sự kiện phản hồi được lưu trữ trên FIFO đã đọc
xếp hàng. Nếu ứng dụng đọc ZZ0000ZZ ở chế độ chặn,
quá trình sẽ được đánh thức.

Giao diện với thiết bị tổng hợp
===============================

Sự đăng ký
------------

Để đăng ký thiết bị tổng hợp OSS, hãy sử dụng snd_seq_oss_synth_register()
chức năng:
::

int snd_seq_oss_synth_register(char *tên, kiểu int, kiểu con int, int nvoices,
          snd_seq_oss_callback_t *oper, void *private_data)

Các đối số ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ và ZZ0003ZZ
được sử dụng để tạo cấu trúc synth_info thích hợp cho ioctl. các
giá trị trả về là số chỉ mục của thiết bị này. Chỉ số này phải được ghi nhớ
để hủy đăng ký. Nếu đăng ký không thành công, -errno sẽ được trả về.

Để giải phóng thiết bị này, hãy gọi hàm snd_seq_oss_synth_unregister():
::

int snd_seq_oss_synth_unregister(chỉ số int)

trong đó ZZ0000ZZ là số chỉ mục được hàm thanh ghi trả về.

Cuộc gọi lại
---------

Thiết bị tổng hợp OSS có khả năng tải xuống mẫu và ioctls
giống như thiết lập lại mẫu. Trong mô phỏng OSS, các tính năng đặc biệt này được hiện thực hóa
bằng cách sử dụng lệnh gọi lại. Đối số đăng ký oper được sử dụng để chỉ định những
cuộc gọi lại. Các hàm gọi lại sau đây phải được xác định:
::

snd_seq_oss_callback_t:
   int (*open)(snd_seq_oss_arg_t *p, void *đóng);
   int (*close)(snd_seq_oss_arg_t *p);
   int (*ioctl)(snd_seq_oss_arg_t *p, cmd int không dấu, arg dài không dấu);
   int (*load_patch)(snd_seq_oss_arg_t *p, định dạng int, const char *buf, int off, int count);
   int (*reset)(snd_seq_oss_arg_t *p);

Ngoại trừ các lệnh gọi lại ZZ0000ZZ và ZZ0001ZZ, chúng được phép là NULL.

Mỗi hàm gọi lại lấy loại đối số ZZ0000ZZ làm
lập luận đầu tiên.
::

cấu trúc snd_seq_oss_arg_t {
      int ứng dụng_index;
      int file_mode;
      int seq_mode;
      snd_seq_addr_t địa chỉ;
      void *private_data;
      int sự kiện_passing;
  };

Ba trường đầu tiên, ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ
được khởi tạo bởi trình sắp xếp OSS. ZZ0003ZZ là ứng dụng
chỉ mục duy nhất cho mỗi ứng dụng mở trình sắp xếp OSS. các
ZZ0004ZZ là cờ bit cho biết chế độ hoạt động của tệp. Xem
ZZ0005ZZ vì ý nghĩa của nó. ZZ0006ZZ là hoạt động tuần tự
chế độ. Trong phiên bản hiện tại, chỉ ZZ0007ZZ được sử dụng.

Hai trường tiếp theo, ZZ0000ZZ và ZZ0001ZZ, phải
được lấp đầy bởi trình điều khiển tổng hợp khi gọi lại mở. ZZ0002ZZ chứa
địa chỉ của cổng trình sắp xếp ALSA được gán cho thiết bị này. Nếu
trình điều khiển phân bổ bộ nhớ cho ZZ0003ZZ, nó phải được giải phóng
trong cuộc gọi lại gần của chính nó.

Trường cuối cùng, ZZ0000ZZ, cho biết cách dịch ghi chú
/ tắt sự kiện. Ở chế độ ZZ0001ZZ, ghi chú 255 được coi là
khi vận tốc thay đổi và sự kiện áp suất chính được chuyển đến cổng. trong
Chế độ ZZ0002ZZ, tất cả các sự kiện bật/tắt ghi chú đều được chuyển đến cổng
không sửa đổi. Chế độ ZZ0003ZZ kiểm tra nốt trên 128
và coi đây là sự kiện áp lực quan trọng (chủ yếu đối với trình điều khiển Emu8000).

Mở cuộc gọi lại
-------------

ZZ0000ZZ được gọi mỗi lần thiết bị này được mở bằng một ứng dụng
sử dụng trình sắp xếp OSS. Đây không phải là NULL. Thông thường, lệnh gọi lại mở
thực hiện quy trình sau:

#. Phân bổ bản ghi dữ liệu riêng tư.
#. Tạo một cổng tuần tự ALSA.
#. Đặt địa chỉ cổng mới trên ZZ0000ZZ.
#. Đặt con trỏ bản ghi dữ liệu riêng tư trên ZZ0001ZZ.

Lưu ý rằng cờ bit loại trong port_info của cổng tổng hợp này phải chứa NOT
ZZ0000ZZ
chút. Thay vào đó nên sử dụng ZZ0001ZZ. Ngoài ra, ZZ0002ZZ
bit NOT cũng nên được đưa vào. Điều này là cần thiết để nói với nó từ người khác
thiết bị MIDI bình thường. Nếu thủ tục mở thành công, trả về 0. Nếu không,
quay lại -errno.

Gọi lại Ioctl
--------------

Cuộc gọi lại ZZ0000ZZ được gọi khi trình sắp xếp thứ tự nhận được thông tin dành riêng cho thiết bị
ioctls. Hai ioctls sau sẽ được xử lý bằng lệnh gọi lại này:

IOCTL_SEQ_RESET_SAMPLES
    đặt lại tất cả các mẫu trên bộ nhớ - trả về 0

IOCTL_SYNTH_MEMAVL
    trả về kích thước bộ nhớ có sẵn

FM_4OP_ENABLE
    thường có thể được bỏ qua

Các ioctl khác được xử lý bên trong trình sắp xếp chuỗi mà không chuyển tới
trình điều khiển cấp thấp.

Gọi lại Load_Patch
-------------------

Lệnh gọi lại ZZ0000ZZ được sử dụng để tải xuống mẫu. Cuộc gọi lại này
phải đọc dữ liệu trên không gian người dùng và truyền đến từng thiết bị. Trả về 0
nếu thành công và -errno nếu thất bại. Đối số định dạng là khóa vá
trong bản ghi patch_info. buf là con trỏ không gian người dùng nơi bản ghi patch_info
được lưu trữ. Các tắt có thể được bỏ qua. Số lượng là tổng kích thước dữ liệu của cái này
dữ liệu mẫu.

Đóng gọi lại
--------------

Lệnh gọi lại ZZ0000ZZ được gọi khi thiết bị này bị đóng bởi
ứng dụng. Nếu bất kỳ dữ liệu riêng tư nào được phân bổ trong cuộc gọi lại mở, nó phải
được phát hành trong cuộc gọi lại đóng. Việc xóa cổng ALSA sẽ được thực hiện
ở đây cũng xong. Cuộc gọi lại này không được là NULL.

Đặt lại cuộc gọi lại
--------------

Cuộc gọi lại ZZ0000ZZ được gọi khi thiết bị sắp xếp thứ tự được đặt lại hoặc
đóng bởi các ứng dụng. Cuộc gọi lại sẽ tắt âm thanh trên
cổng liên quan ngay lập tức và khởi tạo trạng thái của cổng. Nếu điều này
cuộc gọi lại không được xác định, OSS seq gửi sự kiện ZZ0001ZZ tới
cổng.

Sự kiện
======

Hầu hết các sự kiện được xử lý bằng trình sắp xếp thứ tự và được dịch sang dạng thích hợp
Các sự kiện sắp xếp thứ tự ALSA, để mỗi thiết bị tổng hợp có thể nhận được bằng input_event
gọi lại cổng trình sắp xếp ALSA. Các sự kiện ALSA sau đây sẽ được
được thực hiện bởi người lái xe:

===================================
Sự kiện ALSA Sự kiện OSS gốc
===================================
NOTEON SEQ_NOTEON, MIDI_NOTEON
NOTE SEQ_NOTEOFF, MIDI_NOTEOFF
KEYPRESS MIDI_KEY_PRESSURE
CHANPRESS SEQ_AFTERTOUCH, MIDI_CHN_PRESSURE
PGMCHANGE SEQ_PGMCHANGE, MIDI_PGM_CHANGE
PITCHBEND SEQ_CONTROLLER(CTRL_PITCH_BENDER),
		MIDI_PITCH_BEND
CONTROLLER MIDI_CTL_CHANGE,
		SEQ_BALANCE (với CTL_PAN)
CONTROL14 SEQ_CONTROLLER
REGPARAM SEQ_CONTROLLER(CTRL_PITCH_BENDER_RANGE)
SYSEX SEQ_SYSEX
===================================

Hầu hết các hành vi này có thể được thực hiện bằng trình điều khiển mô phỏng MIDI
được bao gồm trong trình điều khiển cấp thấp Emu8000. Trong phiên bản tương lai, mô-đun này
sẽ độc lập.

Một số sự kiện OSS (sự kiện ZZ0000ZZ và ZZ0001ZZ) được chuyển thành sự kiện
loại SND_SEQ_OSS_PRIVATE.  Trình sắp xếp thứ tự OSS chuyển các sự kiện này 8 byte
gói tin mà không có bất kỳ sửa đổi nào. Trình điều khiển cấp thấp sẽ xử lý những
sự kiện một cách thích hợp.

Giao diện với thiết bị MIDI
========================

Vì mô phỏng OSS thăm dò việc tạo và xóa ALSA MIDI
cổng sắp xếp tự động bằng cách nhận thông báo từ ALSA
trình sắp xếp thứ tự, các thiết bị MIDI không cần phải đăng ký rõ ràng
giống như các thiết bị tổng hợp.
Tuy nhiên, port_info MIDI được đăng ký cho trình sắp xếp ALSA phải bao gồm
tên nhóm ZZ0000ZZ và bit khả năng
ZZ0001ZZ hoặc ZZ0002ZZ. Ngoài ra, khả năng đăng ký,
ZZ0003ZZ hoặc ZZ0004ZZ cũng phải được xác định. Nếu
những điều kiện này không được thỏa mãn, cổng không được đăng ký là OSS
thiết bị tuần tự MIDI.

Các sự kiện thông qua thiết bị MIDI được phân tích cú pháp trong trình sắp xếp OSS và được chuyển đổi
đến các sự kiện trình tự sắp xếp ALSA tương ứng. Đầu vào từ trình sắp xếp MIDI
cũng được chuyển đổi thành các sự kiện byte MIDI bởi trình sắp xếp OSS. Điều này chỉ hoạt động
một cách ngược lại của mô-đun seq_midi.

Sự cố đã biết / TODO
=======================

* Tải bản vá qua lớp công cụ ALSA chưa được triển khai.

