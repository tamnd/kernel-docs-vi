.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/drivers/cx88-devel.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển cx88
===============

Tác giả: Gerd Hoffmann

Thiếu tài liệu tại bảng dữ liệu cx88
-------------------------------------------

MO_OUTPUT_FORMAT (0x310164)

.. code-block:: none

  Previous default from DScaler: 0x1c1f0008
  Digit 8: 31-28
  28: PREVREMOD = 1

  Digit 7: 27-24 (0xc = 12 = b1100 )
  27: COMBALT = 1
  26: PAL_INV_PHASE
    (DScaler apparently set this to 1, resulted in sucky picture)

  Digits 6,5: 23-16
  25-16: COMB_RANGE = 0x1f [default] (9 bits -> max 512)

  Digit 4: 15-12
  15: DISIFX = 0
  14: INVCBF = 0
  13: DISADAPT = 0
  12: NARROWADAPT = 0

  Digit 3: 11-8
  11: FORCE2H
  10: FORCEREMD
  9: NCHROMAEN
  8: NREMODEN

  Digit 2: 7-4
  7-6: YCORE
  5-4: CCORE

  Digit 1: 3-0
  3: RANGE = 1
  2: HACTEXT
  1: HSFMT

0x47 là byte đồng bộ cho các gói luồng truyền tải MPEG-2.
Bảng dữ liệu nêu không chính xác khi sử dụng 47 số thập phân. 188 là chiều dài.
Tất cả các gói đầu ra tuân thủ DVB đều có mã bắt đầu này.

Thông tin Hauppauge WinTV cx88 IR
-----------------------------------

Các điều khiển cho mux là GPIO [0,1] cho nguồn và GPIO 2 để tắt tiếng.

============== ======================================================
GPIO0 GPIO1
============== ======================================================
  0 0 Âm thanh Tivi
  1 0 đài FM
  0 1 đầu vào
  1 1 Bỏ qua bộ chỉnh âm đơn hoặc CD passthru (bộ chỉnh cụ thể)
============== ======================================================

GPIO 16(tôi tin) được gắn với cổng IR (nếu có).


Từ bảng dữ liệu:

- Đăng ký trạng thái ngắt 24'h20004 PCI

- bit [18] IR_SMP_INT Đặt khi 32 mẫu đầu vào đã được thu thập qua
 - ghim gpio[16] vào thanh ghi GP_SAMPLE.

Những gì còn thiếu trong bảng dữ liệu:

- Thiết lập tốc độ lấy mẫu 4KHz (gấp khoảng 2 lần; đủ tốt cho RC5 của chúng tôi
  tương thích từ xa)
- đặt thanh ghi 0x35C050 thành 0xa80a80
- cho phép lấy mẫu
- đặt thanh ghi 0x35C054 thành 0x5
- kích hoạt bit IRQ 18 trong thanh ghi mặt nạ ngắt (và
  cung cấp cho một người xử lý)

Thanh ghi GP_SAMPLE ở mức 0x35C058

Các bit sau đó được dịch chuyển sang phải vào thanh ghi GP_SAMPLE tại thời điểm được chỉ định
tỷ lệ; bạn sẽ bị gián đoạn khi nhận được DWORD đầy đủ.
Bạn cần khôi phục các bit RC5 thực tế từ cảm biến hồng ngoại (được lấy mẫu quá mức)
bit. (Gợi ý: tìm điểm giao nhau 0/1 và 1/0 của dữ liệu hai pha RC5) An
Mã RC5 thô thực tế sẽ trải dài từ 2-3 DWORDS, tùy thuộc vào căn chỉnh thực tế.

Tôi khá chắc chắn rằng khi không có tín hiệu IR, bộ thu luôn ở trạng thái
trạng thái đánh dấu(1); nhưng ánh sáng đi lạc, v.v. có thể gây ra các giá trị nhiễu không liên tục
cũng vậy.  Hãy nhớ rằng, đây là mẫu chạy miễn phí của trạng thái máy thu IR
theo thời gian, vì vậy đừng cho rằng bất kỳ mẫu nào đều bắt đầu ở bất kỳ địa điểm cụ thể nào.

Thông tin bổ sung
~~~~~~~~~~~~~~~

Bảng dữ liệu này (tìm kiếm trên google) dường như có một mô tả đáng yêu về
Thông tin cơ bản về RC5:
ZZ0000ZZ

Tài liệu này có nhiều dữ liệu hơn:
ZZ0000ZZ

Tài liệu này có cách giải mã luồng dữ liệu hai pha:
ZZ0000ZZ

Tài liệu này vẫn còn nhiều thông tin hơn:
ZZ0000ZZ