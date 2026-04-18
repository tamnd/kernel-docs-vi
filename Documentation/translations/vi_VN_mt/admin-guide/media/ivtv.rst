.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/ivtv.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển ivtv
===============

Tác giả: Hans Verkuil <hverkuil@kernel.org>

Đây là trình điều khiển thiết bị v4l2 dành cho bộ mã hóa/giải mã Conexant cx23415/6 MPEG.
Cx23415 có thể thực hiện cả mã hóa và giải mã, cx23416 chỉ có thể thực hiện MPEG
mã hóa. Hiện tại thẻ duy nhất có hỗ trợ giải mã đầy đủ là
Hauppauge PVR-350.

.. note::

   #) This driver requires the latest encoder firmware (version 2.06.039, size
      376836 bytes). Get the firmware from here:

      https://linuxtv.org/downloads/firmware/#conexant

   #) 'normal' TV applications do not work with this driver, you need
      an application that can handle MPEG input such as mplayer, xine, MythTV,
      etc.

Mục tiêu chính của dự án IVTV là cung cấp một Linux "phòng sạch"
Triển khai trình điều khiển nguồn mở cho thẻ ghi video dựa trên
iCompression iTVC15 hoặc Conexant CX23415/CX23416 MPEG Codec.

Đặc trưng
--------

* Ghi lại mpeg2 phần cứng của video phát sóng (và âm thanh) thông qua bộ dò hoặc
   Đầu vào S-Video/Composite và âm thanh.
 * Ghi âm mpeg2 phần cứng của đài FM nơi có hỗ trợ phần cứng
 * Hỗ trợ NTSC, PAL, SECAM với âm thanh nổi
 * Hỗ trợ SAP và truyền song ngữ.
 * Hỗ trợ VBI thô (chú thích chi tiết và teletext).
 * Hỗ trợ VBI được cắt lát (chú thích chi tiết và teletext) và có thể chèn
   cái này vào luồng MPEG đã ghi lại.
 * Hỗ trợ đầu vào YUV và PCM thô.

Các tính năng bổ sung cho PVR-350 (dựa trên CX23415)
---------------------------------------------------

* Cung cấp khả năng phát lại mpeg2 phần cứng
 * Cung cấp OSD toàn diện (Hiển thị trên màn hình: tức là đồ họa phủ lên
   tín hiệu video)
 * Cung cấp bộ đệm khung (cho phép các ứng dụng X xuất hiện trên video
   thiết bị)
 * Hỗ trợ đầu ra YUV thô.

IMPORTANT: Trong trường hợp có vấn đề, trước tiên hãy đọc trang này:
	ZZ0000ZZ

Xem thêm
--------

ZZ0000ZZ

IRC
---

irc://irc.freenode.net/#v4l

----------------------------------------------------------

Thiết bị
-------

Hiện tại, tối đa 12 bảng ivtv được cho phép.

Thẻ không có khả năng xuất video (tức là thẻ không phải PVR350)
thiếu thiết bị vbi8, vbi16, video16 và video48. Họ cũng không
hỗ trợ thiết bị bộ đệm khung /dev/fbx cho OSD.

Thiết bị radio0 có thể có hoặc không, tùy thuộc vào việc
thẻ có bộ thu sóng radio hay không.

Dưới đây là danh sách các thiết bị v4l cơ bản:

.. code-block:: none

	crw-rw----    1 root     video     81,   0 Jun 19 22:22 /dev/video0
	crw-rw----    1 root     video     81,  16 Jun 19 22:22 /dev/video16
	crw-rw----    1 root     video     81,  24 Jun 19 22:22 /dev/video24
	crw-rw----    1 root     video     81,  32 Jun 19 22:22 /dev/video32
	crw-rw----    1 root     video     81,  48 Jun 19 22:22 /dev/video48
	crw-rw----    1 root     video     81,  64 Jun 19 22:22 /dev/radio0
	crw-rw----    1 root     video     81, 224 Jun 19 22:22 /dev/vbi0
	crw-rw----    1 root     video     81, 228 Jun 19 22:22 /dev/vbi8
	crw-rw----    1 root     video     81, 232 Jun 19 22:22 /dev/vbi16

Thiết bị cơ sở
------------

Đối với mỗi thẻ phụ, bạn có số lượng tăng thêm một. Ví dụ,
/dev/video0 được liệt kê là thiết bị ghi mã hóa 'cơ sở' nên chúng tôi có:

- /dev/video0 là thiết bị chụp mã hóa cho thẻ đầu tiên (thẻ 0)
- /dev/video1 là thiết bị ghi mã hóa cho thẻ thứ hai (thẻ 1)
- /dev/video2 là thiết bị thu mã hóa cho thẻ thứ 3 (thẻ 2)

Lưu ý nếu thẻ đầu tiên không có tính năng (ví dụ không có bộ giải mã nên không có
video16, thẻ thứ 2 vẫn dùng video17. Quy tắc đơn giản là 'thêm
số thẻ thành số thiết bị cơ sở'. Nếu bạn có cách chụp khác
thẻ (ví dụ: WinTV PCI) được phát hiện trước tiên, sau đó bạn phải thông báo
mô-đun ivtv về nó để nó bắt đầu đếm từ 1 (hoặc 2, hoặc
sao cũng được). Nếu không, số thiết bị có thể gây nhầm lẫn. ivtv
Tùy chọn mô-đun 'ivtv_first_minor' có thể được sử dụng cho việc đó.


- /dev/video0

(Các) thiết bị chụp mã hóa.

Chỉ đọc.

Việc đọc từ thiết bị này sẽ giúp bạn có được luồng chương trình MPEG1/2.
  Ví dụ:

  .. code-block:: none

cat /dev/video0 > my.mpg (bạn cần nhấn ctrl-c để thoát)


- /dev/video16

(Các) thiết bị đầu ra bộ giải mã

Chỉ viết. Chỉ xuất hiện nếu bộ giải mã MPEG (tức là CX23415) tồn tại.

Luồng mpeg2 được gửi tới thiết bị này sẽ xuất hiện trên video đã chọn
  hiển thị, âm thanh sẽ xuất hiện trên đầu ra/đầu ra âm thanh.  Nó chỉ
  có sẵn cho các thẻ hỗ trợ đầu ra video. Ví dụ:

  .. code-block:: none

cat my.mpg >/dev/video16


- /dev/video24

(Các) thiết bị thu âm thanh thô.

Chỉ đọc

Luồng âm thanh nổi PCM âm thanh thô từ luồng hiện được chọn
  bộ chỉnh âm hoặc đầu vào âm thanh.  Việc đọc từ thiết bị này dẫn đến kết quả thô
  (ký tên 16 bit Little Endian, 48000 Hz, âm thanh nổi pcm).
  Thiết bị này chỉ ghi lại âm thanh. Cái này nên được thay thế bằng ALSA
  thiết bị trong tương lai.
  Lưu ý rằng không có thiết bị đầu ra âm thanh thô tương ứng, đây là
  không được hỗ trợ trong phần mềm giải mã.


- /dev/video32

(Các) thiết bị quay video thô

Chỉ đọc

Đầu ra video YUV thô từ đầu vào video hiện tại. Định dạng YUV
  là định dạng NV12 xếp theo tuyến tính 16x16 (V4L2_PIX_FMT_NV12_16L16)

Lưu ý rằng các luồng YUV và PCM không được đồng bộ hóa, vì vậy chúng thuộc loại
  hạn chế sử dụng.


- /dev/video48

(Các) thiết bị hiển thị video thô

Chỉ viết. Chỉ xuất hiện nếu bộ giải mã MPEG (tức là CX23415) tồn tại.

Ghi luồng YUV vào bộ giải mã của thẻ.


- /dev/radio0

(Các) thiết bị dò đài

Không thể đọc hoặc viết.

Được sử dụng để kích hoạt bộ dò sóng radio và điều chỉnh theo tần số. Bạn không thể
  đọc hoặc ghi các luồng âm thanh bằng thiết bị này.  Một khi bạn sử dụng cái này
  thiết bị để điều chỉnh radio, sử dụng/dev/video24 để đọc luồng pcm thô
  hoặc /dev/video0 để nhận luồng mpeg2 có video màu đen.


- /dev/vbi0

(Các) thiết bị chụp 'khoảng trống dọc' (Teletext, CC, WSS, v.v.)

Chỉ đọc

Ghi lại dữ liệu video thô (hoặc cắt lát) được gửi trong chế độ Trống dọc
  Khoảng thời gian. Dữ liệu này được sử dụng để mã hóa teletext, phụ đề chi tiết, VPS,
  tín hiệu màn hình rộng, thông tin hướng dẫn chương trình điện tử và các thông tin khác
  dịch vụ.


- /dev/vbi8

(Các) thiết bị phản hồi vbi đã xử lý

Chỉ đọc. Chỉ xuất hiện nếu bộ giải mã MPEG (tức là CX23415) tồn tại.

Dữ liệu VBI được cắt lát được nhúng trong luồng MPEG được sao chép trên này
  thiết bị. Vì vậy, khi phát lại bản ghi trên /dev/video16, bạn có thể
  đọc dữ liệu VBI được nhúng từ /dev/vbi8.


- /dev/vbi16

(Các) thiết bị 'hiển thị' vbi

Chỉ viết. Chỉ xuất hiện nếu bộ giải mã MPEG (tức là CX23415) tồn tại.

Có thể được sử dụng để gửi dữ liệu VBI được cắt lát tới đầu nối đầu ra video.