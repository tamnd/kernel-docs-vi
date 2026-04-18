.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/fe_property_parameters.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _fe_property_parameters:

**********************************
Thông số thuộc tính TV kỹ thuật số
**********************************

Có một số thông số TV kỹ thuật số khác nhau có thể được sử dụng bởi
ZZ0000ZZ.
Phần này mô tả từng người trong số họ. Tuy nhiên, xin lưu ý rằng chỉ
một tập hợp con trong số chúng là cần thiết để thiết lập giao diện người dùng.


.. _DTV-UNDEFINED:

DTV_UNDEFINED
=============

Được sử dụng nội bộ. Hoạt động GET/SET sẽ không thay đổi hoặc trả lại
bất cứ điều gì.


.. _DTV-TUNE:

DTV_TUNE
========

Giải thích bộ đệm dữ liệu, xây dựng giao diện người dùng truyền thống
tunerequest để chúng tôi có thể chuyển xác thực trong ZZ0000ZZ ioctl.


.. _DTV-CLEAR:

DTV_CLEAR
=========

Đặt lại bộ đệm dữ liệu cụ thể cho giao diện người dùng tại đây. Điều này không
phần cứng hiệu ứng.


.. _DTV-FREQUENCY:

DTV_FREQUENCY
=============

Tần số của bộ phát đáp/kênh truyền hình kỹ thuật số.

.. note::

  #. For satellite delivery systems, the frequency is in kHz.

  #. For cable and terrestrial delivery systems, the frequency is in
     Hz.

  #. On most delivery systems, the frequency is the center frequency
     of the transponder/channel. The exception is for ISDB-T, where
     the main carrier has a 1/7 offset from the center.

  #. For ISDB-T, the channels are usually transmitted with an offset of
     about 143kHz. E.g. a valid frequency could be 474,143 kHz. The
     stepping is  bound to the bandwidth of the channel which is
     typically 6MHz.

  #. In ISDB-Tsb, the channel consists of only one or three segments the
     frequency step is 429kHz, 3*429 respectively.


.. _DTV-MODULATION:

DTV_MODULATION
==============

Chỉ định loại điều chế giao diện người dùng cho các hệ thống phân phối
hỗ trợ nhiều điều chế.

Điều chế có thể là một trong những loại được xác định bởi enum ZZ0000ZZ.

Hầu hết các tiêu chuẩn truyền hình kỹ thuật số cung cấp nhiều hơn một khả năng
kiểu điều chế.

Bảng dưới đây trình bày tóm tắt về các loại kiểu điều chế
được hỗ trợ bởi mỗi hệ thống phân phối, như được xác định bởi thông số kỹ thuật hiện tại.

====================================================================================
Các loại điều chế tiêu chuẩn
====================================================================================
ATSC (phiên bản 1) 8-VSB và 16-VSB.
DMTB 4-QAM, 16-QAM, 32-QAM, 64-QAM và 4-QAM-NR.
DVB-C Phụ lục A/C 16-QAM, 32-QAM, 64-QAM và 256-QAM.
DVB-C Phụ lục B 64-QAM.
DVB-C2 QPSK, 16-QAM, 64-QAM, 256-QAM, 1024-QAM và 4096-QAM.
DVB-T QPSK, 16-QAM và 64-QAM.
DVB-T2 QPSK, 16-QAM, 64-QAM và 256-QAM.
DVB-S Không cần thiết lập. Nó chỉ hỗ trợ QPSK.
DVB-S2 QPSK, 8-PSK, 16-APSK và 32-APSK.
DVB-S2X 8-APSK-L, 16-APSK-L, 32-APSK-L, 64-APSK và 64-APSK-L.
ISDB-T QPSK, DQPSK, 16-QAM và 64-QAM.
ISDB-S 8-PSK, QPSK và BPSK.
====================================================================================

.. note::

   As DVB-S2X specifies extensions to the DVB-S2 standard, the same
   delivery system enum value is used (SYS_DVBS2).

   Please notice that some of the above modulation types may not be
   defined currently at the Kernel. The reason is simple: no driver
   needed such definition yet.


.. _DTV-BANDWIDTH-HZ:

DTV_BANDWIDTH_HZ
================

Băng thông cho kênh, tính bằng HZ.

Chỉ nên đặt cho các hệ thống phân phối trên mặt đất.

Các giá trị có thể có: ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ,
ZZ0004ZZ, ZZ0005ZZ.

====================================================================================
Tiêu chuẩn mặt đất Các giá trị có thể có của băng thông
====================================================================================
ATSC (phiên bản 1) Không cần thiết lập. Nó luôn luôn là 6 MHz.
DMTB Không cần thiết lập. Nó luôn luôn là 8 MHz.
DVB-T 6 MHz, 7 MHz và 8 MHz.
DVB-T2 1.172 MHz, 5 MHz, 6 MHz, 7 MHz, 8 MHz và 10 MHz
ISDB-T 5 MHz, 6 MHz, 7 MHz và 8 MHz, mặc dù hầu hết các nơi
			sử dụng 6 MHz.
====================================================================================


.. note::


  #. For ISDB-Tsb, the bandwidth can vary depending on the number of
     connected segments.

     It can be easily derived from other parameters
     (DTV_ISDBT_SB_SEGMENT_IDX, DTV_ISDBT_SB_SEGMENT_COUNT).

  #. On Satellite and Cable delivery systems, the bandwidth depends on
     the symbol rate. The kernel will silently ignore any :ref:`DTV-BANDWIDTH-HZ`
     setting and overwrites it with bandwidth estimation.

     Such bandwidth estimation takes into account the symbol rate set with
     :ref:`DTV-SYMBOL-RATE`, and the rolloff factor, with is fixed for
     DVB-C and DVB-S.

     For DVB-S2, the rolloff should also be set via :ref:`DTV-ROLLOFF`.


.. _DTV-INVERSION:

DTV_INVERSION
=============

Chỉ định xem giao diện người dùng có nên thực hiện đảo ngược quang phổ hay không.

Các giá trị chấp nhận được được xác định bởi ZZ0000ZZ.


.. _DTV-DISEQC-MASTER:

DTV_DISEQC_MASTER
=================

Hiện nay chưa được thực hiện.


.. _DTV-SYMBOL-RATE:

DTV_SYMBOL_RATE
===============

Được sử dụng trên hệ thống phân phối cáp và vệ tinh.

Tốc độ ký hiệu TV kỹ thuật số, tính bằng baud (ký hiệu/giây).


.. _DTV-INNER-FEC:

DTV_INNER_FEC
=============

Được sử dụng trên hệ thống phân phối cáp và vệ tinh.

Các giá trị chấp nhận được được xác định bởi ZZ0000ZZ.


.. _DTV-VOLTAGE:

DTV_VOLTAGE
===========

Được sử dụng trên các hệ thống phân phối vệ tinh.

Điện áp thường được sử dụng với các LNB không hỗ trợ DiSEqC để chuyển mạch
phân cực (ngang/dọc). Khi sử dụng thiết bị DiSEqC, điều này
điện áp phải được chuyển đổi nhất quán sang các lệnh DiSEqC như
được mô tả trong thông số DiSEqC.

Các giá trị chấp nhận được được xác định bởi ZZ0000ZZ.


.. _DTV-TONE:

DTV_TONE
========

Hiện tại không được sử dụng.


.. _DTV-PILOT:

DTV_PILOT
=========

Được sử dụng trên DVB-S2.

Đặt phi công DVB-S2.

Các giá trị chấp nhận được được xác định bởi ZZ0000ZZ.


.. _DTV-ROLLOFF:

DTV_ROLLOFF
===========

Được sử dụng trên DVB-S2.

Đặt giới hạn DVB-S2.

Các giá trị chấp nhận được được xác định bởi ZZ0000ZZ.


.. _DTV-DISEQC-SLAVE-REPLY:

DTV_DISEQC_SLAVE_REPLY
======================

Hiện nay chưa được thực hiện.


.. _DTV-FE-CAPABILITY-COUNT:

DTV_FE_CAPABILITY_COUNT
=======================

Hiện nay chưa được thực hiện.


.. _DTV-FE-CAPABILITY:

DTV_FE_CAPABILITY
=================

Hiện nay chưa được thực hiện.


.. _DTV-DELIVERY-SYSTEM:

DTV_DELIVERY_SYSTEM
===================

Chỉ định loại hệ thống phân phối.

Các giá trị chấp nhận được được xác định bởi ZZ0000ZZ.


.. _DTV-ISDBT-PARTIAL-RECEPTION:

DTV_ISDBT_PARTIAL_RECEPTION
===========================

Chỉ được sử dụng trên ISDB.

Nếu ZZ0000ZZ là '0' thì trường bit này đại diện cho
kênh có ở chế độ thu một phần hay không.

Nếu giá trị '1' ZZ0000ZZ được gán cho đoạn trung tâm
và ZZ0001ZZ phải là '1'.

Ngoài ra, nếu ZZ0000ZZ là '1'
ZZ0001ZZ thể hiện kênh ISDB-Tsb này
bao gồm một phân đoạn và lớp hoặc ba phân đoạn và hai lớp.

Các giá trị có thể có: 0, 1, -1 (AUTO)


.. _DTV-ISDBT-SOUND-BROADCASTING:

DTV_ISDBT_SOUND_BROADCASTING
============================

Chỉ được sử dụng trên ISDB.

Trường này thể hiện liệu các thông số DTV_ISDBT_* khác có
đề cập đến kênh ISDB-T và kênh ISDB-Tsb. (Xem thêm
ZZ0000ZZ).

Các giá trị có thể có: 0, 1, -1 (AUTO)


.. _DTV-ISDBT-SB-SUBCHANNEL-ID:

DTV_ISDBT_SB_SUBCHANNEL_ID
==========================

Chỉ được sử dụng trên ISDB.

Trường này chỉ áp dụng nếu ZZ0000ZZ là '1'.

(Lưu ý của tác giả: Đây có thể không phải là mô tả chính xác về
ZZ0000ZZ trong tất cả các chi tiết, nhưng đó là sự hiểu biết của tôi về
nền tảng kỹ thuật cần thiết để lập trình một thiết bị)

Kênh ISDB-Tsb (1 hoặc 3 phân đoạn) có thể được phát sóng một mình hoặc trong một
tập hợp các kênh ISDB-Tsb được kết nối. Trong tập hợp các kênh này mỗi
kênh có thể được nhận độc lập. Số lượng kết nối ISDB-Tsb
phân khúc có thể khác nhau, ví dụ: tùy thuộc vào băng thông phổ tần số
có sẵn.

Ví dụ: Giả sử 8 phân đoạn được kết nối ISDB-Tsb được phát sóng. các
đài truyền hình có một số khả năng để đưa các kênh đó lên sóng:
Giả sử phổ ISDB-T 13 đoạn bình thường, anh ta có thể căn chỉnh 8 đoạn
từ vị trí 1-8 đến 5-13 hoặc bất kỳ vị trí nào ở giữa.

Lớp cơ bản của các phân đoạn là các kênh con: mỗi phân đoạn là
bao gồm một số kênh phụ có ID được xác định trước. Một kênh phụ
được sử dụng để giúp bộ giải điều chế đồng bộ hóa trên kênh.

Kênh ISDB-T luôn được đặt ở giữa tất cả các kênh phụ. Đối với
ví dụ ở trên, trong ISDB-Tsb mọi chuyện không còn đơn giản như vậy nữa.

Tham số ZZ0000ZZ được sử dụng để cung cấp
ID kênh con của đoạn được giải điều chế.

Các giá trị có thể có: 0 .. 41, -1 (AUTO)


.. _DTV-ISDBT-SB-SEGMENT-IDX:

DTV_ISDBT_SB_SEGMENT_IDX
========================

Chỉ được sử dụng trên ISDB.

Trường này chỉ áp dụng nếu ZZ0000ZZ là '1'.

ZZ0000ZZ cung cấp chỉ mục của phân đoạn được
được giải điều chế cho kênh ISDB-Tsb trong đó một số kênh được
được truyền đi theo cách kết nối.

Các giá trị có thể có: 0 .. ZZ0000ZZ - 1

Lưu ý: Không thể xác định giá trị này bằng tìm kiếm kênh tự động.


.. _DTV-ISDBT-SB-SEGMENT-COUNT:

DTV_ISDBT_SB_SEGMENT_COUNT
==========================

Chỉ được sử dụng trên ISDB.

Trường này chỉ áp dụng nếu ZZ0000ZZ là '1'.

ZZ0000ZZ cung cấp tổng số kết nối
Kênh ISDB-Tsb.

Các giá trị có thể có: 1 .. 13

Lưu ý: Không thể xác định giá trị này bằng tìm kiếm kênh tự động.


.. _isdb-hierq-layers:

Thông số DTV-ISDBT-LAYER[A-C]
===============================

Chỉ được sử dụng trên ISDB.

Các kênh ISDB-T có thể được mã hóa theo thứ bậc. Ngược lại với DVB-T ở
Các lớp phân cấp ISDB-T có thể được giải mã đồng thời. Vì điều đó
lý do bộ giải mã ISDB-T có 3 bộ giải mã Viterbi và 3 bộ giải mã Reed-Solomon.

ISDB-T có 3 lớp phân cấp mà mỗi lớp có thể sử dụng một phần của
các phân đoạn có sẵn. Tổng số phân đoạn trên tất cả các lớp phải
13 trong ISDB-T.

Có 3 bộ tham số cho Lớp A, B và C.


.. _DTV-ISDBT-LAYER-ENABLED:

DTV_ISDBT_LAYER_ENABLED
-----------------------

Chỉ được sử dụng trên ISDB.

Việc tiếp nhận phân cấp trong ISDB-T đạt được bằng cách bật hoặc tắt
các lớp trong quá trình giải mã. Thiết lập tất cả các bit của
ZZ0000ZZ thành '1' buộc tất cả các lớp (nếu có) phải
được giải điều chế. Đây là mặc định.

Nếu kênh ở chế độ thu một phần
(ZZ0000ZZ = 1) đoạn trung tâm có thể được giải mã
độc lập với 12 đoạn còn lại. Trong chế độ đó lớp A phải có
ZZ0001ZZ là 1.

Trong ISDB-Tsb chỉ sử dụng lớp A, nó có thể là 1 hoặc 3 trong ISDB-Tsb tùy theo
tới ZZ0000ZZ. ZZ0001ZZ phải được điền
tương ứng.

Chỉ có giá trị của 3 bit đầu tiên được sử dụng. Các bit khác sẽ bị âm thầm bỏ qua:

ZZ0000ZZ bit 0: bật lớp A

ZZ0000ZZ bit 1: bật lớp B

ZZ0000ZZ bit 2: bật lớp C

Các bit ZZ0000ZZ 3-31: không sử dụng


.. _DTV-ISDBT-LAYER-FEC:

DTV_ISDBT_LAYER[A-C]_FEC
------------------------

Chỉ được sử dụng trên ISDB.

Cơ chế sửa lỗi chuyển tiếp được sử dụng bởi Lớp ISDB nhất định, như
được xác định bởi ZZ0000ZZ.


Các giá trị có thể là: ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ,
ZZ0004ZZ, ZZ0005ZZ


.. _DTV-ISDBT-LAYER-MODULATION:

DTV_ISDBT_LAYER[A-C]_MODULATION
-------------------------------

Chỉ được sử dụng trên ISDB.

Điều chế được sử dụng bởi Lớp ISDB nhất định, như được xác định bởi
ZZ0000ZZ.

Các giá trị có thể có là: ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ

.. note::

   #. If layer C is ``DQPSK``, then layer B has to be ``DQPSK``.

   #. If layer B is ``DQPSK`` and ``DTV_ISDBT_PARTIAL_RECEPTION``\ = 0,
      then layer has to be ``DQPSK``.


.. _DTV-ISDBT-LAYER-SEGMENT-COUNT:

DTV_ISDBT_LAYER[A-C]_SEGMENT_COUNT
----------------------------------

Chỉ được sử dụng trên ISDB.

Các giá trị có thể có: 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, -1 (AUTO)

Lưu ý: Bảng chân lý cho ZZ0000ZZ và
ZZ0001ZZ và ZZ0002ZZ

.. _isdbt-layer_seg-cnt-table:

.. flat-table:: Truth table for ISDB-T Sound Broadcasting
    :header-rows:  1
    :stub-columns: 0


    -  .. row 1

       -  Partial Reception

       -  Sound Broadcasting

       -  Layer A width

       -  Layer B width

       -  Layer C width

       -  total width

    -  .. row 2

       -  0

       -  0

       -  1 .. 13

       -  1 .. 13

       -  1 .. 13

       -  13

    -  .. row 3

       -  1

       -  0

       -  1

       -  1 .. 13

       -  1 .. 13

       -  13

    -  .. row 4

       -  0

       -  1

       -  1

       -  0

       -  0

       -  1

    -  .. row 5

       -  1

       -  1

       -  1

       -  2

       -  0

       -  13



.. _DTV-ISDBT-LAYER-TIME-INTERLEAVING:

DTV_ISDBT_LAYER[A-C]_TIME_INTERLEAVING
--------------------------------------

Chỉ được sử dụng trên ISDB.

Giá trị hợp lệ: 0, 1, 2, 4, -1 (AUTO)

khi DTV_ISDBT_SOUND_BROADCASTING hoạt động, giá trị 8 cũng hợp lệ.

Lưu ý: Độ dài xen kẽ thời gian thực phụ thuộc vào chế độ (kích thước fft).
Các giá trị ở đây đề cập đến những gì có thể tìm thấy trong
Cấu trúc TMCC, như thể hiện trong bảng bên dưới.


.. c:type:: isdbt_layer_interleaving_table

.. flat-table:: ISDB-T time interleaving modes
    :header-rows:  1
    :stub-columns: 0


    -  .. row 1

       -  ``DTV_ISDBT_LAYER[A-C]_TIME_INTERLEAVING``

       -  Mode 1 (2K FFT)

       -  Mode 2 (4K FFT)

       -  Mode 3 (8K FFT)

    -  .. row 2

       -  0

       -  0

       -  0

       -  0

    -  .. row 3

       -  1

       -  4

       -  2

       -  1

    -  .. row 4

       -  2

       -  8

       -  4

       -  2

    -  .. row 5

       -  4

       -  16

       -  8

       -  4



.. _DTV-ATSCMH-FIC-VER:

DTV_ATSCMH_FIC_VER
------------------

Chỉ được sử dụng trên ATSC-MH.

Số phiên bản của dữ liệu báo hiệu FIC (Kênh thông tin nhanh).

FIC được sử dụng để chuyển tiếp thông tin nhằm cho phép thu thập dịch vụ nhanh chóng
bởi người nhận.

Các giá trị có thể có: 0, 1, 2, 3, ..., 30, 31


.. _DTV-ATSCMH-PARADE-ID:

DTV_ATSCMH_PARADE_ID
--------------------

Chỉ được sử dụng trên ATSC-MH.

Mã số diễu hành

Cuộc diễu hành là sự tập hợp của tám nhóm MH, vận chuyển một hoặc hai
hòa tấu.

Các giá trị có thể có: 0, 1, 2, 3, ..., 126, 127


.. _DTV-ATSCMH-NOG:

DTV_ATSCMH_NOG
--------------

Chỉ được sử dụng trên ATSC-MH.

Số lượng nhóm MH trên mỗi khung con MH cho một cuộc diễu hành được chỉ định.

Các giá trị có thể có: 1, 2, 3, 4, 5, 6, 7, 8


.. _DTV-ATSCMH-TNOG:

DTV_ATSCMH_TNOG
---------------

Chỉ được sử dụng trên ATSC-MH.

Tổng số nhóm MH bao gồm tất cả các nhóm MH thuộc tất cả MH
diễu hành trong một khung phụ MH.

Các giá trị có thể có: 0, 1, 2, 3, ..., 30, 31


.. _DTV-ATSCMH-SGN:

DTV_ATSCMH_SGN
--------------

Chỉ được sử dụng trên ATSC-MH.

Bắt đầu số nhóm.

Các giá trị có thể có: 0, 1, 2, 3, ..., 14, 15


.. _DTV-ATSCMH-PRC:

DTV_ATSCMH_PRC
--------------

Chỉ được sử dụng trên ATSC-MH.

Chu kỳ lặp lại cuộc diễu hành.

Các giá trị có thể có: 1, 2, 3, 4, 5, 6, 7, 8


.. _DTV-ATSCMH-RS-FRAME-MODE:

DTV_ATSCMH_RS_FRAME_MODE
------------------------

Chỉ được sử dụng trên ATSC-MH.

Chế độ khung hình Reed Solomon (RS).

Các giá trị chấp nhận được được xác định bởi ZZ0000ZZ.


.. _DTV-ATSCMH-RS-FRAME-ENSEMBLE:

DTV_ATSCMH_RS_FRAME_ENSEMBLE
----------------------------

Chỉ được sử dụng trên ATSC-MH.

Bộ khung Reed Solomon (RS).

Các giá trị chấp nhận được được xác định bởi ZZ0000ZZ.


.. _DTV-ATSCMH-RS-CODE-MODE-PRI:

DTV_ATSCMH_RS_CODE_MODE_PRI
---------------------------

Chỉ được sử dụng trên ATSC-MH.

Chế độ mã Reed Solomon (RS) (chính).

Các giá trị chấp nhận được được xác định bởi ZZ0000ZZ.


.. _DTV-ATSCMH-RS-CODE-MODE-SEC:

DTV_ATSCMH_RS_CODE_MODE_SEC
---------------------------

Chỉ được sử dụng trên ATSC-MH.

Chế độ mã Reed Solomon (RS) (thứ cấp).

Các giá trị chấp nhận được được xác định bởi ZZ0000ZZ.


.. _DTV-ATSCMH-SCCC-BLOCK-MODE:

DTV_ATSCMH_SCCC_BLOCK_MODE
--------------------------

Chỉ được sử dụng trên ATSC-MH.

Chế độ khối mã xoắn nối tiếp chuỗi.

Các giá trị chấp nhận được được xác định bởi ZZ0000ZZ.


.. _DTV-ATSCMH-SCCC-CODE-MODE-A:

DTV_ATSCMH_SCCC_CODE_MODE_A
---------------------------

Chỉ được sử dụng trên ATSC-MH.

Tỷ lệ mã chập nối chuỗi.

Các giá trị chấp nhận được được xác định bởi ZZ0000ZZ.

.. _DTV-ATSCMH-SCCC-CODE-MODE-B:

DTV_ATSCMH_SCCC_CODE_MODE_B
---------------------------

Chỉ được sử dụng trên ATSC-MH.

Tỷ lệ mã chập nối chuỗi.

Các giá trị có thể giống như tài liệu trên enum
ZZ0000ZZ.


.. _DTV-ATSCMH-SCCC-CODE-MODE-C:

DTV_ATSCMH_SCCC_CODE_MODE_C
---------------------------

Chỉ được sử dụng trên ATSC-MH.

Tỷ lệ mã chập nối chuỗi.

Các giá trị có thể giống như tài liệu trên enum
ZZ0000ZZ.


.. _DTV-ATSCMH-SCCC-CODE-MODE-D:

DTV_ATSCMH_SCCC_CODE_MODE_D
---------------------------

Chỉ được sử dụng trên ATSC-MH.

Tỷ lệ mã chập nối chuỗi.

Các giá trị có thể giống như tài liệu trên enum
ZZ0000ZZ.


.. _DTV-API-VERSION:

DTV_API_VERSION
===============

Trả về phiên bản chính/phụ của TV kỹ thuật số API


.. _DTV-CODE-RATE-HP:

DTV_CODE_RATE_HP
================

Được sử dụng trên truyền dẫn mặt đất.

Các giá trị chấp nhận được được xác định bởi ZZ0000ZZ.


.. _DTV-CODE-RATE-LP:

DTV_CODE_RATE_LP
================

Được sử dụng trên truyền dẫn mặt đất.

Các giá trị chấp nhận được được xác định bởi ZZ0000ZZ.


.. _DTV-GUARD-INTERVAL:

DTV_GUARD_INTERVAL
==================

Các giá trị chấp nhận được được xác định bởi ZZ0000ZZ.

.. note::

   #. If ``DTV_GUARD_INTERVAL`` is set the ``GUARD_INTERVAL_AUTO`` the
      hardware will try to find the correct guard interval (if capable) and
      will use TMCC to fill in the missing parameters.
   #. Interval ``GUARD_INTERVAL_1_64`` is used only for DVB-C2.
   #. Interval ``GUARD_INTERVAL_1_128`` is used for both DVB-C2 and DVB_T2.
   #. Intervals ``GUARD_INTERVAL_19_128`` and ``GUARD_INTERVAL_19_256`` are
      used only for DVB-T2.
   #. Intervals ``GUARD_INTERVAL_PN420``, ``GUARD_INTERVAL_PN595`` and
      ``GUARD_INTERVAL_PN945`` are used only for DMTB at the present.
      On such standard, only those intervals and ``GUARD_INTERVAL_AUTO``
      are valid.

.. _DTV-TRANSMISSION-MODE:

DTV_TRANSMISSION_MODE
=====================


Chỉ được sử dụng trên các tiêu chuẩn dựa trên OFTM, e. g. DVB-T/T2, ISDB-T, DTMB.

Chỉ định kích thước FFT (tương ứng với số lượng gần đúng của
sóng mang) được sử dụng theo tiêu chuẩn.

Các giá trị chấp nhận được được xác định bởi ZZ0000ZZ.

.. note::

   #. ISDB-T supports three carrier/symbol-size: 8K, 4K, 2K. It is called
      **mode** on such standard, and are numbered from 1 to 3:

      ====	========	========================
      Mode	FFT size	Transmission mode
      ====	========	========================
      1		2K		``TRANSMISSION_MODE_2K``
      2		4K		``TRANSMISSION_MODE_4K``
      3		8K		``TRANSMISSION_MODE_8K``
      ====	========	========================

   #. If ``DTV_TRANSMISSION_MODE`` is set the ``TRANSMISSION_MODE_AUTO``
      the hardware will try to find the correct FFT-size (if capable) and
      will use TMCC to fill in the missing parameters.

   #. DVB-T specifies 2K and 8K as valid sizes.

   #. DVB-T2 specifies 1K, 2K, 4K, 8K, 16K and 32K.

   #. DTMB specifies C1 and C3780.


.. _DTV-HIERARCHY:

DTV_HIERARCHY
=============

Chỉ được sử dụng trên DVB-T và DVB-T2.

Hệ thống phân cấp giao diện người dùng.

Các giá trị chấp nhận được được xác định bởi ZZ0000ZZ.


.. _DTV-STREAM-ID:

DTV_STREAM_ID
=============

Được sử dụng trên DVB-C2, DVB-S2, DVB-T2 và ISDB-S.

DVB-C2, DVB-S2, DVB-T2 và ISDB-S hỗ trợ truyền một số
các luồng trên một luồng truyền tải đơn. Thuộc tính này cho phép kỹ thuật số
Trình điều khiển TV để xử lý việc lọc luồng phụ khi được phần cứng hỗ trợ.
Theo mặc định, tính năng lọc luồng con bị tắt.

Đối với DVB-C2, DVB-S2 và DVB-T2, phạm vi id luồng con hợp lệ là từ 0 đến
255.

Đối với ISDB, phạm vi id luồng con hợp lệ là từ 1 đến 65535.

Để tắt nó, bạn nên sử dụng macro đặc biệt NO_STREAM_ID_FILTER.

Lưu ý: bất kỳ giá trị nào ngoài phạm vi id cũng sẽ vô hiệu hóa tính năng lọc.


.. _DTV-DVBT2-PLP-ID-LEGACY:

DTV_DVBT2_PLP_ID_LEGACY
=======================

Đã lỗi thời, được thay thế bằng DTV_STREAM_ID.


.. _DTV-ENUM-DELSYS:

DTV_ENUM_DELSYS
===============

Giao diện người dùng đa tiêu chuẩn cần quảng cáo hệ thống phân phối
được cung cấp. Các ứng dụng cần liệt kê các hệ thống phân phối được cung cấp,
trước khi sử dụng bất kỳ thao tác nào khác với giao diện người dùng. Trước nó
giới thiệu, FE_GET_INFO đã được sử dụng để xác định loại giao diện người dùng. A
giao diện người dùng cung cấp nhiều hơn một hệ thống phân phối duy nhất,
FE_GET_INFO không giúp được gì nhiều. Các ứng dụng có ý định sử dụng một
giao diện người dùng đa tiêu chuẩn phải liệt kê các hệ thống phân phối liên quan
với nó, thay vì cố gắng sử dụng FE_GET_INFO. Trong trường hợp của một
giao diện người dùng cũ, kết quả cũng giống như với FE_GET_INFO, nhưng
ở dạng có cấu trúc hơn.

Các giá trị chấp nhận được được xác định bởi ZZ0000ZZ.


.. _DTV-INTERLEAVING:

DTV_INTERLEAVING
================

Thời gian xen kẽ sẽ được sử dụng.

Các giá trị chấp nhận được được xác định bởi ZZ0000ZZ.


.. _DTV-LNA:

DTV_LNA
=======

Bộ khuếch đại tiếng ồn thấp.

Phần cứng có thể cung cấp LNA có thể điều khiển được, có thể được đặt thủ công bằng cách sử dụng
tham số đó. Thông thường LNA chỉ có thể được tìm thấy từ các thiết bị trên mặt đất
nếu có.

Các giá trị có thể có: 0, 1, LNA_AUTO

0, LNA tắt

1, LNA bật

sử dụng macro đặc biệt LNA_AUTO để đặt tự động LNA


.. _DTV-SCRAMBLING-SEQUENCE-INDEX:

DTV_SCRAMBLING_SEQUENCE_INDEX
=============================

Được sử dụng trên DVB-S2.

Trường 18 bit này, khi xuất hiện, sẽ mang chỉ mục của DVB-S2 vật lý
trình tự xáo trộn lớp như được định nghĩa trong điều 5.5.4 của EN 302 307.
Không có phương pháp báo hiệu rõ ràng để truyền chỉ số tuần tự xáo trộn
tới người nhận. Nếu có sẵn bộ mô tả hệ thống phân phối vệ tinh S2
nó có thể được sử dụng để đọc chỉ số trình tự xáo trộn (EN 300 468 bảng 41).

Theo mặc định, chỉ số chuỗi tranh giành vàng 0 được sử dụng.

Phạm vi chỉ số chuỗi xáo trộn hợp lệ là từ 0 đến 262142.