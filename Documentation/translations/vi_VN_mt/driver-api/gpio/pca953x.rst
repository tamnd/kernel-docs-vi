.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/gpio/pca953x.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================================
Danh sách tương thích với thiết bị mở rộng PCA953x I²C GPIO
============================================

:Tác giả: Levente Révész <levente.revesz@eilabs.com>

Tôi đã xem qua tất cả các bảng dữ liệu và tạo danh sách ghi chú này
chức năng chip và bố trí đăng ký.

Tổng quan về chip
=================

Chip có 4 thanh ghi cơ bản
--------------------------------

Các chip này có 4 dãy thanh ghi: đầu vào, đầu ra, đảo ngược và hướng.
Mỗi ngân hàng này chứa (dòng/8) thanh ghi, một thanh ghi cho mỗi cổng GPIO.

Phần bù của ngân hàng luôn là lũy thừa của 2:

- 4 dòng -> offset ngân hàng là 1
- 8 dòng -> offset ngân hàng là 1
- 16 dòng -> offset ngân hàng là 2
- 24 dòng -> offset ngân hàng là 4
- 32 dòng -> offset ngân hàng là 4
- 40 dòng -> offset ngân hàng là 8

Ví dụ: bố cục đăng ký của thiết bị mở rộng GPIO với 24 dòng:

+------+--------+--------+
Chức năng ZZ0000ZZ ZZ0001ZZ
+=======+==============================+
Cổng đầu vào ZZ0002ZZ0 ZZ0003ZZ
+------+-----+ |
Cổng đầu vào ZZ0004ZZ1 ZZ0005ZZ
+------+-----+ |
Cổng đầu vào ZZ0006ZZ2 ZZ0007ZZ
+------+--------+--------+
ZZ0008ZZ không có ZZ0009ZZ
+------+--------+--------+
Cổng đầu ra ZZ0010ZZ0 ZZ0011ZZ
+------+-----+ |
Cổng đầu ra ZZ0012ZZ1 ZZ0013ZZ
+------+-----+ |
Cổng đầu ra ZZ0014ZZ2 ZZ0015ZZ
+------+--------+--------+
ZZ0016ZZ không có ZZ0017ZZ
+------+--------+--------+
ZZ0018ZZ đảo ngược cổng0 ZZ0019ZZ
+------+-----+ |
ZZ0020ZZ đảo ngược cổng1 ZZ0021ZZ
+------+-----+ |
ZZ0022ZZ đảo ngược cổng2 ZZ0023ZZ
+------+--------+--------+
ZZ0024ZZ không có ZZ0025ZZ
+------+--------+--------+
Cổng định hướng ZZ0026ZZ0 ZZ0027ZZ
+------+-----+ |
Cổng định hướng ZZ0028ZZ1 ZZ0029ZZ
+------+-----+ |
Cổng định hướng ZZ0030ZZ2 ZZ0031ZZ
+------+--------+--------+
ZZ0032ZZ không có ZZ0033ZZ
+------+--------+--------+

.. note::
     This is followed by all supported chips, except by pcal6534.

Bảng bên dưới hiển thị độ lệch cho từng chip tương thích:

=============== ========== ===== ====== ====== ==========
dòng tương thích ngắt đầu vào đầu ra hướng đảo ngược
=============== ========== ===== ====== ====== ==========
pca9536 4 không 00 01 02 03
pca9537 4 có 00 01 02 03
pca6408 8 vâng 00 01 02 03
tca6408 8 vâng 00 01 02 03
pca9534 8 vâng 00 01 02 03
pca9538 8 vâng 00 01 02 03
pca9554 8 vâng 00 01 02 03
tca9554 8 vâng 00 01 02 03
pca9556 8 không 00 01 02 03
pca9557 8 không 00 01 02 03
pca6107 8 vâng 00 01 02 03
pca6416 16 có 00 02 04 06
tca6416 16 vâng 00 02 04 06
pca9535 16 có 00 02 04 06
pca9539 16 có 00 02 04 06
tca9539 16 vâng 00 02 04 06
pca9555 16 có 00 02 04 06
max7318 16 có 00 02 04 06
tca6424 24 có 00 04 08 0C
=============== ========== ===== ====== ====== ==========

Chip có thêm thời gian chờ_en đăng ký
-----------------------------------------

Các chip Maxim này có chức năng hết thời gian chờ bus có thể được kích hoạt trong
thanh ghi timeout_en. Điều này chỉ hiện diện trong hai chip. Mặc định là
hết thời gian chờ bị vô hiệu hóa.

=========== ===== ========= ===== ====== ====== ========= ===========
dòng tương thích ngắt đầu vào đầu ra đảo ngược hướng timeout_en
=========== ===== ========= ===== ====== ====== ========= ===========
max7310 8 không 00 01 02 03 04
max7312 16 có 00 02 04 06 08
=========== ===== ========= ===== ====== ====== ========= ===========

Chip có thanh ghi int_mask bổ sung
---------------------------------------

Những chip này có một thanh ghi mặt nạ ngắt ngoài 4 thanh ghi cơ bản
sổ đăng ký. Mặt nạ ngắt mặc định là tất cả các ngắt bị vô hiệu hóa. Đến
sử dụng các ngắt với các chip này, trình điều khiển phải đặt int_mask
đăng ký.

================ ========= ===== ====== =============== =========
dòng tương thích ngắt đầu vào đầu ra hướng đảo ngược int_mask
================ ========= ===== ====== =============== =========
pca9505 40 có 00 08 10 18 20
pca9506 40 có 00 08 10 18 20
================ ========= ===== ====== =============== =========

Chip có thêm thanh ghi int_mask và out_conf
-----------------------------------------------------

Con chip này có một thanh ghi mặt nạ ngắt và một cổng đầu ra
thanh ghi cấu hình, có thể chọn giữa đẩy-kéo và
chế độ thoát nước mở. Mỗi bit điều khiển hai dòng. Cả hai thanh ghi này
cũng có mặt trong chip PCAL, mặc dù out_conf vẫn hoạt động
khác nhau.

=========== ===== ========= ===== ====== ====== ========= ======== =========
các dòng tương thích ngắt đầu vào đầu ra đảo ngược hướng int_mask out_conf
=========== ===== ========= ===== ====== ====== ========= ======== =========
pca9698 40 có 00 08 10 18 20 28
=========== ===== ========= ===== ====== ====== ========= ======== =========

pca9698 cũng có một thanh ghi "đầu ra chính" để thiết lập tất cả các đầu ra cho mỗi
đồng thời tới cùng một giá trị và một thanh ghi chế độ cụ thể của chip
cho các cài đặt chip bổ sung khác nhau.

========== ============== ====
chế độ master_output tương thích
========== ============== ====
pca9698 29 2A
========== ============== ====

Chip có LED nhấp nháy và kiểm soát cường độ
------------------------------------------

Những chip Maxim này không có thanh ghi đảo ngược.

Chúng có hai bộ thanh ghi đầu ra (output0 và out1). Một nội bộ
bộ đếm thời gian luân phiên đầu ra hiệu quả giữa các giá trị được đặt trong các giá trị này
thanh ghi, nếu chế độ nhấp nháy được bật trong thanh ghi nhấp nháy. các
thanh ghi master_intensity và thanh ghi cường độ cùng xác định
giá trị cường độ PWM cho mỗi cặp đầu ra.

Những chip này có thể được sử dụng làm bộ mở rộng GPIO đơn giản nếu trình điều khiển xử lý
các thanh ghi đầu vào, đầu ra0 và hướng.

=========== ===== ========= ===== ======= ========= ======= ================= ===== ==========
các dòng tương thích ngắt đầu vào đầu ra0 hướng đầu ra1 master_intensity cường độ nhấp nháy
=========== ===== ========= ===== ======= ========= ======= ================= ===== ==========
max7315 8 có 00 01 03 09 0E 0F 10
max7313 16 có 00 02 06 0A 0E 0F 10
=========== ===== ========= ===== ======= ========= ======= ================= ===== ==========

Chip PCAL cơ bản
----------------

=============== ========== ===== ====== ====== ==========
dòng tương thích ngắt đầu vào đầu ra hướng đảo ngược
=============== ========== ===== ====== ====== ==========
pcal6408 8 vâng 00 01 02 03
pcal9554b 8 có 00 01 02 03
pcal6416 16 có 00 02 04 06
pcal9535 16 có 00 02 04 06
pcal9555a 16 có 00 02 04 06
tcal6408 8 vâng 00 01 02 03
tcal6416 16 vâng 00 02 04 06
=============== ========== ===== ====== ====== ==========

Những con chip này có một số tính năng bổ sung:

1. cài đặt cường độ ổ đĩa đầu ra (out_ Strength)
    2. chốt đầu vào (in_latch)
    3. kéo lên/kéo xuống (pull_in, pull_sel)
    4. đầu ra đẩy-kéo/mở-thoát (out_conf)
    5. Mặt nạ ngắt và trạng thái ngắt (int_mask, int_status)

============================================= ======== ========== =========
tương thích out_ Strength in_latch pull_en pull_sel int_mask int_status out_conf
============================================= ======== ========== =========
pcal6408 40 42 43 44 45 46 4F
pcal9554b 40 42 43 44 45 46 4F
pcal6416 40 44 46 48 4A 4C 4F
pcal9535 40 44 46 48 4A 4C 4F
pcal9555a 40 44 46 48 4A 4C 4F
tcal6408 40 42 43 44 45 46 4F
tcal6416 40 44 46 48 4A 4C 4F
============================================= ======== ========== =========

Hiện tại driver đã hỗ trợ chốt đầu vào, kéo lên/kéo xuống
và sử dụng int_mask và int_status cho các ngắt.

Chip PCAL có chức năng cấu hình đầu ra và ngắt mở rộng
---------------------------------------------------------------------

=============== ========== ===== ====== ====== ==========
dòng tương thích ngắt đầu vào đầu ra hướng đảo ngược
=============== ========== ===== ====== ====== ==========
pcal6524 24 có 00 04 08 0C
pcal6534 34 có 00 05 0A 0F
=============== ========== ===== ====== ====== ==========

Các chip này có bộ thanh ghi PCAL đầy đủ, cùng với các chức năng sau:

1. lựa chọn sự kiện ngắt: cấp độ, tăng, giảm, bất kỳ cạnh nào
    2. xóa trạng thái ngắt trên mỗi dòng
    3. đọc đầu vào mà không xóa trạng thái ngắt
    4. Cấu hình đầu ra riêng lẻ (đẩy-kéo/mở-thoát) trên mỗi dòng đầu ra
    5. gỡ lỗi đầu vào

============================================= ======== ========== =========
tương thích out_ Strength in_latch pull_en pull_sel int_mask int_status out_conf
============================================= ======== ========== =========
pcal6524 40 48 4C 50 54 58 5C
pcal6534 30 3A 3F 44 49 4E 53
============================================= ======== ========== =========

======================================================= ======== ================
tương thích int_edge int_clear input_status indiv_out_conf gỡ lỗi debounce_count
======================================================= ======== ================
pcal6524 60 68 6C 70 74 76
pcal6534 54 5E 63 68 6D 6F
======================================================= ======== ================

Như có thể thấy trong bảng trên, pcal6534 không tuân theo quy tắc thông thường
quy tắc khoảng cách ngân hàng. Thay vào đó, các ngân hàng của nó được đóng gói chặt chẽ.

Chip PCA957X có bố cục thanh ghi hoàn toàn khác
---------------------------------------------------------

Những con chip này có 4 thanh ghi cơ bản nhưng ở những địa chỉ khác thường.

Ngoài ra, họ có:

1. kéo lên/kéo xuống (pull_sel)
    2. kích hoạt kéo toàn cầu, mặc định là tắt (cấu hình)
    3. mặt nạ ngắt, trạng thái ngắt (int_mask, int_status)

=========== ===== ========= ===== ====== ============== ========= ====== ======== ===========
các dòng tương thích ngắt đầu vào đảo ngược cấu hình pull_sel hướng đầu ra int_mask int_status
=========== ===== ========= ===== ====== ============== ========= ====== ======== ===========
pca9574 8 vâng 00 01 02 03 04 05 06 07
pca9575 16 có 00 02 04 06 08 0A 0C 0E
=========== ===== ========= ===== ====== ============== ========= ====== ======== ===========

Hiện tại trình điều khiển không hỗ trợ tính năng nâng cao nào.

XRA1202
-------

4 thanh ghi cơ bản, cộng với các tính năng nâng cao:

1. mặt nạ ngắt, mặc định ngắt bị vô hiệu hóa
    2. trạng thái ngắt
    3. lựa chọn sự kiện ngắt, cấp độ, tăng, giảm, bất kỳ cạnh nào
       (int_mask, tăng_mask, giảm_mask)
    4. kéo lên (không kéo xuống)
    5. ba trạng thái
    6. gỡ lỗi

=========== ===== ========= ===== ====== ====== ========= ==========
dòng tương thích ngắt đầu vào đầu ra đảo ngược hướng pullup_en
=========== ===== ========= ===== ====== ====== ========= ==========
xra1202 8 vâng 00 01 02 03 04
=========== ===== ========= ===== ====== ====== ========= ==========

==================================== ========================= =========
tương thích int_mask tristate int_status Rising_mask falls_mask gỡ lỗi
==================================== ========================= =========
xra1202 05 06 07 08 09 0A
==================================== ========================= =========

Tổng quan về chức năng
=====================

Phần này liệt kê các chức năng chip được trình điều khiển hỗ trợ
đã có hoặc ít nhất là phổ biến trong nhiều chip.

Đầu vào, đầu ra, đảo ngược, hướng
--------------------------------

4 chức năng GPIO cơ bản có ở tất cả trừ một loại chip, tức là.
ZZ0000ZZ thiếu chức năng đảo ngược
đăng ký.

3 bố cục khác nhau được sử dụng cho các thanh ghi này:

1. ngân hàng 0, 1, 2, 3 với độ lệch ngân hàng là 2^n
        - tất cả các chip khác

2. Ngân hàng 0, 1, 2, 3 với ngân hàng được đóng gói chặt chẽ
        - pcal6534

3. ngân hàng 0, 5, 1, 4 với độ lệch ngân hàng là 2^n
        - pca9574
        - pca9575

Ngắt
----------

Chỉ có một thanh ghi mặt nạ ngắt
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Bố cục tương tự được sử dụng cho tất cả những điều này:

1. ngân hàng 5 với độ lệch ngân hàng là 2^n
        - pca9505
        - pca9506
        - pca9698

Mặt nạ ngắt và thanh ghi trạng thái ngắt
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Chúng hoạt động theo cách tương tự trong tất cả các chip: mặt nạ và trạng thái có
một bit trên mỗi dòng, 1 trong mặt nạ có nghĩa là kích hoạt ngắt.

Bố cục:

1. độ lệch cơ sở 0x40, ngân hàng 5 và ngân hàng 6, độ lệch ngân hàng là 2^n
        - pcal6408
        - pcal6416
        - pcal9535
        - pcal9554b
        - pcal9555a
        - pcal6524
        -tcal6408
        -tcal6416

2. offset cơ sở 0x30, ngân hàng 5 và 6, ngân hàng được đóng gói chặt chẽ
        - pcal6534

3. ngân hàng 6 và 7, bù đắp ngân hàng 2^n
        - pca9574
        - pca9575

4. ngân hàng 5 và 7, bù đắp ngân hàng 2^n
        - xra1202

Ngắt trên các cạnh cụ thể
~~~~~~~~~~~~~~~~~~~~~~~~~~~
ZZ0000ZZ
có một thanh ghi int_edge. Điều này chứa 2 bit trên mỗi dòng, một trong 4 sự kiện
có thể được chọn cho mỗi dòng:

0: mức, 1: cạnh tăng, 2: cạnh giảm, 3: cạnh bất kỳ

Bố cục:

1. độ lệch cơ sở 0x40, ngân hàng 7, độ lệch ngân hàng 2^n

- pcal6524

2. offset cơ sở 0x30, ngân hàng 7 + offset 0x01, ngân hàng được đóng gói chặt chẽ
       (out_conf là 1 byte, không phải (dòng/8) byte, do đó có độ lệch 0x01)

- pcal6534

Các chip ZZ0000ZZ có cơ chế khác cho cùng một mục đích: chúng có
mặt nạ tăng và mặt nạ rơi, mỗi dòng một bit.

Cách trình bày:

1. ngân hàng 5, bù đắp ngân hàng 2^n

Chốt đầu vào
-----------

Chỉ ZZ0000ZZ và
ZZ0001ZZ
có chức năng này. Khi chốt được kích hoạt, ngắt không bị xóa
cho đến khi cổng đầu vào được đọc. Khi chốt bị vô hiệu hóa, ngắt
bị xóa ngay cả khi thanh ghi đầu vào không được đọc, nếu chân đầu vào trả về
với giá trị logic mà nó có trước khi tạo ra ngắt. Mặc định để chốt
bị vô hiệu hóa.

Hiện tại trình điều khiển kích hoạt chốt cho từng dòng bị gián đoạn
đã bật.

Thanh ghi trạng thái ngắt ghi lại các chân nào đã kích hoạt ngắt.
Tuy nhiên, thanh ghi trạng thái và thanh ghi cổng đầu vào phải được đọc
riêng biệt; không có cơ chế nguyên tử nào để đọc cả hai cùng một lúc, vì vậy các chủng tộc
là có thể. Tham khảo chương ZZ0000ZZ để hiểu
ý nghĩa của việc này và cách người lái xe vẫn sử dụng chốt
tính năng.

1. độ lệch cơ sở 0x40, ngân hàng 2, độ lệch ngân hàng 2^n
        - pcal6408
        - pcal6416
        - pcal9535
        - pcal9554b
        - pcal9555a
        - pcal6524
        -tcal6408
        -tcal6416

2. offset cơ sở 0x30, ngân hàng 2, ngân hàng được đóng gói chặt chẽ
        - pcal6534

Kéo lên và kéo xuống
---------------------

ZZ0000ZZ và
ZZ0001ZZ
sử dụng cơ chế tương tự: thanh ghi pull_en của chúng cho phép kéo lên hoặc kéo xuống
và thanh ghi pull_sel của chúng sẽ chọn hướng. Tất cả họ đều sử dụng một
bit trên mỗi dòng.

0: kéo xuống, 1: kéo lên

Bố cục:

1. độ lệch cơ sở 0x40, ngân hàng 3 (en) và 4 (sel), độ lệch ngân hàng là 2^n
        - pcal6408
        - pcal6416
        - pcal9535
        - pcal9554b
        - pcal9555a
        - pcal6524

2. offset cơ sở 0x30, ngân hàng 3 (en) và 4 (sel), ngân hàng được đóng gói chặt chẽ
        - pcal6534

ZZ0000ZZ có pull_sel
đăng ký với một bit trên mỗi dòng và bit pull_en chung trong cấu hình của chúng
đăng ký.

Cách trình bày:

1. ngân hàng 2 (cấu hình), ngân hàng 3 (sel), bù đắp ngân hàng 2^n
        - pca9574
        - pca9575

Chip ZZ0000ZZ chỉ có thể kéo lên. Họ có một thanh ghi pullup_en.

Cách trình bày:

1. ngân hàng 4, bù đắp ngân hàng 2^n
        - xra1202

Kéo đẩy và thoát nước mở
------------------------

ZZ0000ZZ có chức năng này,
nhưng chỉ dành cho các cổng IO được chọn. Thanh ghi có 1 bit trên 2 dòng. Trong pca9698,
chỉ port0 và port1 có chức năng này.

0: thoát nước mở, 1: kéo đẩy

Cách trình bày:

1. bù đắp cơ sở 5 *bù đắp ngân hàng
        - pca9698

ZZ0000ZZ có 1 bit trên mỗi cổng trong một thanh ghi out_conf duy nhất.
Chỉ có thể cấu hình toàn bộ cổng.

0: kéo đẩy, 1: thoát nước mở

Cách trình bày:

1. độ lệch cơ sở 0x4F
        - pcal6408
        - pcal6416
        - pcal9535
        - pcal9554b
        - pcal9555a
        -tcal6408
        -tcal6416

ZZ0000ZZ
có thể thiết lập điều này cho từng dòng riêng lẻ. Chúng có cùng một cổng out_conf
đăng ký là ZZ0001ZZ, nhưng họ cũng có đăng ký indiv_out_conf
với một bit trên mỗi dòng, đảo ngược hiệu ứng của cài đặt cổng thông minh.

0: kéo đẩy, 1: thoát nước mở

Bố cục:

1. bù cơ sở 0x40 + 7*bankoffset (out_conf),
       độ lệch cơ sở 0x60, ngân hàng 4 (indiv_out_conf) với độ lệch ngân hàng là 2^n

- pcal6524

2. độ lệch cơ sở 0x30 + 7*banksize (out_conf),
       offset cơ sở 0x54, ngân hàng 4 (indiv_out_conf), ngân hàng được đóng gói chặt chẽ

- pcal6534

Chức năng này hiện không được trình điều khiển hỗ trợ.

Sức mạnh ổ đĩa đầu ra
---------------------

Chỉ chip PCAL mới có chức năng này. 2 bit trên mỗi dòng.

==== ================
sức mạnh ổ đĩa bit
==== ================
  00 0,25x
  01 0,50x
  10 0,75x
  11 1,00x
==== ================

1. độ lệch cơ sở 0x40, ngân hàng 0 và 1, độ lệch ngân hàng là 2^n
        - pcal6408
        - pcal6416
        - pcal9535
        - pcal9554b
        - pcal9555a
        - pcal6524
        -tcal6408
        -tcal6416

2. offset cơ sở 0x30, ngân hàng 0 và 1, ngân hàng được đóng gói chặt chẽ
        - pcal6534

Hiện nay không được hỗ trợ bởi trình điều khiển.

Phát hiện nguồn ngắt
==========================

Khi được kích hoạt bởi ngắt của thiết bị mở rộng GPIO, trình điều khiển sẽ xác định
IRQ đang chờ xử lý bằng cách đọc thanh ghi cổng đầu vào.

Để có thể lọc các sự kiện ngắt cụ thể cho tất cả các thiết bị tương thích,
trình điều khiển theo dõi trạng thái đầu vào trước đó của các dòng và phát ra một
IRQ chỉ dành cho cạnh hoặc mức chính xác. Hệ thống này hoạt động bất kể
số lượng ngắt được kích hoạt. Các sự kiện sẽ không bị bỏ lỡ ngay cả khi chúng xảy ra
giữa ngắt của bộ mở rộng GPIO và số đọc I2C thực tế. Các cạnh có thể của
khóa học sẽ bị bỏ lỡ nếu mức tín hiệu liên quan thay đổi trở lại giá trị
được trình điều khiển lưu trước đó trước khi đọc I2C. Các biến thể PCAL cung cấp đầu vào
chốt vì lý do đó.

Chốt đầu vào PCAL
-------------------

Các biến thể PCAL có chốt đầu vào và trình điều khiển kích hoạt tính năng này cho tất cả các biến thể
dòng cho phép ngắt. Ngắt sau đó chỉ bị xóa khi cổng đầu vào
được đọc ra. Các biến thể này cung cấp một thanh ghi trạng thái ngắt để ghi lại
chân nào đã kích hoạt ngắt, nhưng các thanh ghi trạng thái và đầu vào không thể được
đọc một cách nguyên tử. Nếu một ngắt khác xảy ra trên một dòng khác sau lệnh
thanh ghi trạng thái đã được đọc nhưng trước khi thanh ghi cổng đầu vào được lấy mẫu,
sự kiện đó sẽ không được phản ánh trong ảnh chụp nhanh trạng thái trước đó, do đó, việc dựa vào
chỉ trên thanh ghi trạng thái ngắt là không đủ.

Do đó, các biến thể PCAL cũng phải sử dụng logic thay đổi cấp độ hiện có.

Đối với các xung ngắn, cạnh đầu tiên được ghi lại khi thanh ghi đầu vào được đọc,
nhưng nếu tín hiệu trở về mức trước đó trước lần đọc này thì tín hiệu thứ hai
cạnh không được quan sát. Kết quả là các xung liên tiếp có thể tạo ra các xung giống nhau
giá trị đầu vào tại thời điểm đọc và không phát hiện thấy sự thay đổi mức độ, gây ra gián đoạn
bị bỏ lỡ. Sơ đồ thời gian dưới đây cho thấy tình huống này trong đó tín hiệu hàng đầu được
mức chân đầu vào và tín hiệu dưới cùng cho biết giá trị được chốt ::

─────┐ ┌──ZZ0000ZZ─────────────────┐ ┌──*───
       │ │ .               │ │ .                 │ │ .
       │ │ │ │ │ │ │ │ │
       └──ZZ0001ZZ──┘ │ └──*──┘ │
  Đầu vào │ │ │ │ │ │
          ▼ │ ▼ │ ▼ │
         IRQ │ IRQ │ IRQ │
                .                        .                          .
  ─────┐ .┌──────────────┐ .┌────────────────┐ .┌──
       │ │ │ │ │ │
       │ │ │ │ │ │
       └────────ZZ0002ZZ┘ └────────*┘
  Đã chốt │ │ │
                ▼ ▼ ▼
              READ 0 READ 0 READ 0
                                     KHÔNG CHANGE KHÔNG CHANGE

Để giải quyết vấn đề này, các sự kiện được chỉ định bởi thanh ghi trạng thái ngắt sẽ được hợp nhất
với các sự kiện được phát hiện thông qua logic thay đổi cấp độ hiện có. Kết quả là:

- các xung ngắn, có cạnh thứ hai không nhìn thấy được, được phát hiện thông qua
  thanh ghi trạng thái ngắt, và
- các ngắt xảy ra giữa trạng thái và lần đọc đầu vào vẫn còn
  bị bắt bởi logic thay đổi cấp độ chung.

Lưu ý rằng đây vẫn là nỗ lực tốt nhất: các thanh ghi trạng thái và đầu vào được đọc
riêng biệt và các xung ngắn trên các dòng khác có thể xảy ra giữa các lần đọc đó.
Các xung như vậy vẫn có thể được chốt như một ngắt mà không để lại tín hiệu có thể quan sát được.
mức độ thay đổi tại thời điểm đọc và có thể không do một cạnh cụ thể. Cái này
không làm giảm khả năng phát hiện so với đường dẫn chung, nhưng phản ánh vốn có
giới hạn tính nguyên tử.

Bảng dữ liệu
==========

-MAX7310: ZZ0000ZZ
-MAX7312: ZZ0001ZZ
-MAX7313: ZZ0002ZZ
-MAX7315: ZZ0003ZZ
-MAX7318: ZZ0004ZZ
-PCA6107: ZZ0005ZZ
-PCA6408A: ZZ0006ZZ
-PCA6416A: ZZ0007ZZ
-PCA9505: ZZ0008ZZ
-PCA9505: ZZ0009ZZ
- PCA9534: ZZ0010ZZ
-PCA9535: ZZ0011ZZ
-PCA9536: ZZ0012ZZ
-PCA9537: ZZ0013ZZ
-PCA9538: ZZ0014ZZ
-PCA9539: ZZ0015ZZ
-PCA9554: ZZ0016ZZ
-PCA9555: ZZ0017ZZ
-PCA9556: ZZ0018ZZ
-PCA9557: ZZ0019ZZ
-PCA9574: ZZ0020ZZ
-PCA9575: ZZ0021ZZ
-PCA9698: ZZ0022ZZ
-PCAL6408A: ZZ0023ZZ
-PCAL6416A: ZZ0024ZZ
-PCAL6524: ZZ0025ZZ
- PCAL6534: ZZ0026ZZ
-PCAL9535A: ZZ0027ZZ
-PCAL9554B: ZZ0028ZZ
-PCAL9555A: ZZ0029ZZ
- TCA6408A: ZZ0030ZZ
-TCA6416: ZZ0031ZZ
-TCA6424: ZZ0032ZZ
-TCA9539: ZZ0033ZZ
-TCA9554: ZZ0034ZZ
-XRA1202: ZZ0035ZZ
