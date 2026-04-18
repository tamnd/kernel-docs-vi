.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/frontend-stat-properties.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _frontend-stat-properties:

*******************************
Chỉ số thống kê Frontend
******************************

Các giá trị được trả về thông qua ZZ0000ZZ. Nếu tài sản là
được hỗ trợ, ZZ0001ZZ lớn hơn 0.

Đối với hầu hết các hệ thống phân phối, ZZ0000ZZ sẽ là 1 nếu
số liệu thống kê được hỗ trợ và các thuộc tính sẽ trả về một giá trị duy nhất cho
từng tham số.

Tuy nhiên, cần lưu ý rằng các hệ thống phân phối OFDM mới như ISDB
có thể sử dụng các kiểu điều chế khác nhau cho từng nhóm sóng mang. Trên đó
tiêu chuẩn, có thể cung cấp tối đa 3 nhóm số liệu thống kê và
ZZ0000ZZ được cập nhật để phản ánh các số liệu "toàn cầu",
cộng với một số liệu cho mỗi nhóm sóng mang (được gọi là "lớp" trên ISDB).

Vì vậy, để nhất quán với các hệ thống phân phối khác, điều đầu tiên
giá trị tại mảng ZZ0000ZZ đề cập đến
đến số liệu toàn cầu. Các phần tử khác của mảng đại diện cho mỗi
lớp, bắt đầu từ lớp A (chỉ mục 1), lớp B (chỉ mục 2), v.v.

Số lượng phần tử đã điền được lưu trữ tại ZZ0000ZZ.

Mỗi phần tử của mảng ZZ0000ZZ bao gồm
hai yếu tố:

- ZZ0000ZZ hoặc ZZ0001ZZ, trong đó ZZ0002ZZ dành cho các giá trị có dấu của
   thước đo (đo dB) và ZZ0003ZZ dành cho các giá trị không dấu
   (bộ đếm, tỷ lệ tương đối)

- ZZ0000ZZ - Chia tỷ lệ cho giá trị. Nó có thể là:

- ZZ0000ZZ - Tham số được hỗ trợ bởi
      giao diện người dùng, nhưng không thể thu thập nó (có thể là một
      trạng thái tạm thời hoặc vĩnh viễn)

- ZZ0000ZZ - tham số là giá trị có dấu, được đo bằng
      1/1000dB

- ZZ0000ZZ - tham số là giá trị không dấu, trong đó 0
      có nghĩa là 0% và 65535 có nghĩa là 100%.

- ZZ0000ZZ - tham số là giá trị không dấu được tính
      sự xuất hiện của một sự kiện, như lỗi bit, lỗi khối hoặc lỗi
      thời gian.


.. _DTV-STAT-SIGNAL-STRENGTH:

DTV_STAT_SIGNAL_STRENGTH
========================

Cho biết mức cường độ tín hiệu ở phần analog của bộ dò sóng hoặc
của bản demo.

Thang đo có thể có cho số liệu này là:

- ZZ0000ZZ - không đo được hoặc
   phép đo vẫn chưa hoàn thành.

- ZZ0000ZZ - cường độ tín hiệu tính bằng đơn vị 0,001 dBm, công suất
   được đo bằng miliwatt. Giá trị này thường âm.

- ZZ0000ZZ - Giao diện người dùng cung cấp 0% đến 100%
   đo công suất (thực tế là 0 đến 65535).


.. _DTV-STAT-CNR:

DTV_STAT_CNR
============

Cho biết tỷ lệ Tín hiệu trên Nhiễu của sóng mang chính.

Thang đo có thể có cho số liệu này là:

- ZZ0000ZZ - không đo được hoặc
   phép đo vẫn chưa hoàn thành.

- ZZ0000ZZ - Tỷ lệ tín hiệu/nhiễu tính bằng đơn vị 0,001 dB.

- ZZ0000ZZ - Giao diện người dùng cung cấp 0% đến 100%
   đo Tín hiệu/Nhiễu (thực tế là 0 đến 65535).


.. _DTV-STAT-PRE-ERROR-BIT-COUNT:

DTV_STAT_PRE_ERROR_BIT_COUNT
============================

Đo số lượng lỗi bit trước khi sửa lỗi chuyển tiếp
(FEC) trên khối mã hóa bên trong (trước Viterbi, LDPC hoặc khối bên trong khác
mã).

Biện pháp này được thực hiện trong cùng khoảng thời gian với
ZZ0000ZZ.

Để có được phép đo BER (Tỷ lệ lỗi bit), cần phải
chia cho
ZZ0000ZZ.

Phép đo này được tăng lên một cách đơn điệu, khi giao diện người dùng nhận được nhiều hơn
phép đo số bit. Giao diện người dùng có thể đặt lại nó khi
kênh/bộ phát đáp được điều chỉnh.

Thang đo có thể có cho số liệu này là:

- ZZ0000ZZ - không đo được hoặc
   phép đo vẫn chưa hoàn thành.

- ZZ0000ZZ - Số bit lỗi được tính trước phần bên trong
   mã hóa.


.. _DTV-STAT-PRE-TOTAL-BIT-COUNT:

DTV_STAT_PRE_TOTAL_BIT_COUNT
============================

Đo lượng bit nhận được trước khối mã bên trong, trong khi
cùng thời gian với
ZZ0000ZZ
phép đo đã được thực hiện.

Cần lưu ý rằng phép đo này có thể nhỏ hơn tổng
số lượng bit trên luồng truyền tải, vì giao diện người dùng có thể cần
khởi động lại phép đo theo cách thủ công, mất một số dữ liệu giữa mỗi lần đo
khoảng đo.

Phép đo này được tăng lên một cách đơn điệu, khi giao diện người dùng nhận được nhiều hơn
phép đo số bit. Giao diện người dùng có thể đặt lại nó khi
kênh/bộ phát đáp được điều chỉnh.

Thang đo có thể có cho số liệu này là:

- ZZ0000ZZ - không đo được hoặc
   phép đo vẫn chưa hoàn thành.

- ZZ0001ZZ - Số bit được đếm trong khi đo
   ZZ0000ZZ.


.. _DTV-STAT-POST-ERROR-BIT-COUNT:

DTV_STAT_POST_ERROR_BIT_COUNT
=============================

Đo số lượng lỗi bit sau khi sửa lỗi chuyển tiếp
(FEC) được thực hiện bởi khối mã bên trong (sau Viterbi, LDPC hoặc bên trong khác
mã).

Biện pháp này được thực hiện trong cùng khoảng thời gian với
ZZ0000ZZ.

Để có được phép đo BER (Tỷ lệ lỗi bit), cần phải
chia cho
ZZ0000ZZ.

Phép đo này được tăng lên một cách đơn điệu, khi giao diện người dùng nhận được nhiều hơn
phép đo số bit. Giao diện người dùng có thể đặt lại nó khi
kênh/bộ phát đáp được điều chỉnh.

Thang đo có thể có cho số liệu này là:

- ZZ0000ZZ - không đo được hoặc
   phép đo vẫn chưa hoàn thành.

- ZZ0000ZZ - Số bit lỗi được tính sau bên trong
   mã hóa.


.. _DTV-STAT-POST-TOTAL-BIT-COUNT:

DTV_STAT_POST_TOTAL_BIT_COUNT
=============================

Đo lượng bit nhận được sau mã hóa bên trong, trong quá trình
cùng thời gian với
ZZ0000ZZ
phép đo đã được thực hiện.

Cần lưu ý rằng phép đo này có thể nhỏ hơn tổng
số lượng bit trên luồng truyền tải, vì giao diện người dùng có thể cần
khởi động lại phép đo theo cách thủ công, mất một số dữ liệu giữa mỗi lần đo
khoảng đo.

Phép đo này được tăng lên một cách đơn điệu, khi giao diện người dùng nhận được nhiều hơn
phép đo số bit. Giao diện người dùng có thể đặt lại nó khi
kênh/bộ phát đáp được điều chỉnh.

Thang đo có thể có cho số liệu này là:

- ZZ0000ZZ - không đo được hoặc
   phép đo vẫn chưa hoàn thành.

- ZZ0001ZZ - Số bit được đếm trong khi đo
   ZZ0000ZZ.


.. _DTV-STAT-ERROR-BLOCK-COUNT:

DTV_STAT_ERROR_BLOCK_COUNT
==========================

Đo số lỗi khối sau lỗi chuyển tiếp bên ngoài
mã hóa sửa lỗi (sau Reed-Solomon hoặc mã bên ngoài khác).

Phép đo này được tăng lên một cách đơn điệu, khi giao diện người dùng nhận được nhiều hơn
phép đo số bit. Giao diện người dùng có thể đặt lại nó khi
kênh/bộ phát đáp được điều chỉnh.

Thang đo có thể có cho số liệu này là:

- ZZ0000ZZ - không đo được hoặc
   phép đo vẫn chưa hoàn thành.

- ZZ0000ZZ - Số khối lỗi tính sau khối ngoài
   mã hóa.


.. _DTV-STAT-TOTAL-BLOCK-COUNT:

DTV-STAT_TOTAL_BLOCK_COUNT
==========================

Đo tổng số khối nhận được trong cùng thời gian với
ZZ0000ZZ
phép đo đã được thực hiện.

Nó có thể được sử dụng để tính chỉ báo PER, bằng cách chia
ZZ0000ZZ bởi
ZZ0001ZZ.

Thang đo có thể có cho số liệu này là:

- ZZ0000ZZ - không đo được hoặc
   phép đo vẫn chưa hoàn thành.

- ZZ0001ZZ - Số khối được đếm trong khi đo
   ZZ0000ZZ.