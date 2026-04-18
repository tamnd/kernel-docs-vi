.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/i2c/i2c-topology.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Mux I2C và cấu trúc liên kết phức tạp
================================

Có một số lý do để xây dựng cấu trúc liên kết I2C phức tạp hơn
hơn bus I2C đơn giản với một bộ chuyển đổi và một hoặc nhiều thiết bị.

Một số trường hợp sử dụng ví dụ là:

1. Có thể cần một mux trên xe buýt để ngăn chặn xung đột địa chỉ.

2. Xe buýt có thể được truy cập từ một số chủ xe buýt bên ngoài và trọng tài
   có thể cần thiết để xác định xem có thể tiếp cận xe buýt hay không.

3. Một thiết bị (đặc biệt là bộ thu sóng RF) có thể muốn tránh nhiễu kỹ thuật số
   ít nhất là từ xe buýt I2C, ít nhất là trong hầu hết thời gian và ngồi sau cổng
   phải được vận hành trước khi có thể truy cập thiết bị.

Một số loại thành phần phần cứng như mux I2C, cổng I2C và I2C
trọng tài cho phép giải quyết những nhu cầu đó.

Các thành phần này được Linux biểu diễn dưới dạng cây bộ điều hợp I2C, trong đó
mỗi bộ điều hợp có một bộ điều hợp gốc (ngoại trừ bộ điều hợp gốc) và không hoặc
nhiều bộ điều hợp con hơn. Bộ điều hợp gốc là bộ điều hợp thực tế có vấn đề
Chuyển I2C và tất cả các bộ điều hợp có nguồn gốc đều là một phần của "i2c-mux"
đối tượng (được trích dẫn, vì nó cũng có thể là trọng tài hoặc cổng).

Tùy thuộc vào trình điều khiển mux cụ thể, điều gì đó sẽ xảy ra khi có
chuyển I2C trên một trong các bộ điều hợp con của nó. Trình điều khiển mux có thể
rõ ràng là vận hành một mux, nhưng nó cũng có thể thực hiện phân xử bằng một thiết bị bên ngoài
chủ xe buýt hoặc mở cổng. Trình điều khiển mux có hai thao tác cho việc này,
chọn và bỏ chọn. select được gọi trước khi chuyển và (
tùy chọn) bỏ chọn được gọi sau khi chuyển.


Khóa
=======

Có hai biến thể khóa dành cho mux I2C, chúng có thể là
mux bị khóa mux hoặc bị khóa cha mẹ.


Mux bị khóa Mux
----------------

Mux-locked mux không khóa toàn bộ bộ điều hợp chính trong quá trình
giao dịch chọn-chuyển-bỏ chọn đầy đủ, chỉ các mux trên cha mẹ
bộ chuyển đổi bị khóa. Các mux bị khóa Mux hầu hết đều thú vị nếu
các thao tác chọn và/hoặc bỏ chọn phải sử dụng chuyển I2C để hoàn thành
nhiệm vụ của họ. Vì bộ điều hợp chính không được khóa hoàn toàn trong quá trình
giao dịch đầy đủ, các giao dịch chuyển I2C không liên quan có thể xen kẽ các giao dịch khác nhau
các giai đoạn của giao dịch. Điều này có lợi ích là trình điều khiển mux
có thể thực hiện dễ dàng và sạch sẽ hơn nhưng nó có một số lưu ý.

Ví dụ bị khóa Mux
~~~~~~~~~~~~~~~~~~

::

.----------.     .-------.
    .-------.     ZZ0000ZZ------ZZ0001ZZ
    ZZ0002ZZ--+--ZZ0003ZZ '--------'
    '--------' ZZ0004ZZ mux M1 |--.  .-------.
                ZZ0005ZZ dev D2 |
                |  .-------.       '--------'
                '--ZZ0006ZZ
                   '--------'

Khi có quyền truy cập vào D1, điều này xảy ra:

1. Ai đó thực hiện chuyển I2C sang D1.
 2. M1 khóa mux trên cha mẹ của nó (bộ điều hợp gốc trong trường hợp này).
 3. Cuộc gọi M1 -> chọn để sẵn sàng mux.
 4. M1 (có lẽ) thực hiện một số chuyển I2C như một phần trong lựa chọn của nó.
    Các lần chuyển này là các lần chuyển I2C thông thường có khóa dữ liệu gốc
    bộ chuyển đổi.
 5. M1 cung cấp quá trình chuyển I2C từ bước 1 sang bộ điều hợp chính của nó dưới dạng
    chuyển I2C bình thường sẽ khóa bộ điều hợp chính.
 6. Cuộc gọi M1 ->bỏ chọn, nếu có.
 7. Quy tắc tương tự như ở bước 4, nhưng đối với ->bỏ chọn.
 8. M1 mở khóa mux trên cha mẹ của nó.

Điều này có nghĩa là quyền truy cập vào D2 sẽ bị khóa trong toàn bộ thời gian
của toàn bộ hoạt động. Nhưng quyền truy cập vào D3 có thể được xen kẽ
tại bất kỳ điểm nào.

Hãy cẩn thận với Mux-locked
~~~~~~~~~~~~~~~~~~

Khi sử dụng mux bị khóa mux, hãy lưu ý các hạn chế sau:

[ML1]
  Nếu bạn xây dựng một cấu trúc liên kết với mux bị khóa mux là cha mẹ
  của một mux bị khóa cha mẹ, điều này có thể phá vỡ sự mong đợi từ
  mux được khóa chính mà bộ điều hợp gốc bị khóa trong quá trình
  giao dịch.

[ML2]
  Sẽ không an toàn khi xây dựng các cấu trúc liên kết tùy ý với hai (hoặc nhiều hơn)
  các mux bị khóa mux không phải là anh chị em, khi có địa chỉ
  xung đột giữa các thiết bị trên bộ điều hợp con của các thiết bị này
  mux không phải anh chị em.

tức là nhắm mục tiêu giao dịch chọn-chuyển-bỏ chọn, ví dụ: thiết bị
  địa chỉ 0x42 đằng sau mux-one có thể được xen kẽ với địa chỉ tương tự
  địa chỉ thiết bị nhắm mục tiêu hoạt động 0x42 phía sau mux-two. các
  mục đích với cấu trúc liên kết như vậy trong ví dụ giả định này
  không nên chọn mux-one và mux-two đồng thời,
  nhưng mux bị khóa mux không đảm bảo điều đó trong tất cả các cấu trúc liên kết.

[ML3]
  Trình điều khiển không thể sử dụng mux bị khóa mux để tự động đóng
  cổng/muxes, tức là thứ gì đó tự động đóng sau một khoảng thời gian nhất định
  số (một, trong hầu hết các trường hợp) chuyển I2C. Chuyển khoản I2C không liên quan
  có thể len lỏi vào và đóng lại sớm.

[ML4]
  Nếu bất kỳ thao tác không phải I2C nào trong trình điều khiển mux thay đổi trạng thái mux I2C,
  trình điều khiển phải khóa bộ điều hợp gốc trong quá trình thao tác đó.
  Nếu không, rác có thể xuất hiện trên xe buýt khi nhìn từ thiết bị
  đằng sau mux, khi quá trình chuyển I2C không liên quan đang diễn ra trong khi
  hoạt động thay đổi mux không phải I2C.


Mux bị khóa bởi cha mẹ
-------------------

Các mux khóa gốc sẽ khóa bộ điều hợp gốc trong quá trình chọn hoàn toàn-
giao dịch chuyển-bỏ chọn. Ý nghĩa là trình điều khiển mux
phải đảm bảo rằng bất kỳ và tất cả các giao dịch chuyển I2C thông qua công ty mẹ đó
bộ điều hợp trong quá trình giao dịch được mở khóa chuyển I2C (sử dụng ví dụ:
__i2c_transfer), nếu không sẽ xảy ra bế tắc.

Ví dụ do cha mẹ khóa
~~~~~~~~~~~~~~~~~~~~~

::

.----------.     .-------.
    .-------.     ZZ0000ZZ------ZZ0001ZZ
    ZZ0002ZZ--+--ZZ0003ZZ '--------'
    '--------' ZZ0004ZZ mux M1 |--.  .-------.
                ZZ0005ZZ dev D2 |
                |  .-------.       '--------'
                '--ZZ0006ZZ
                   '--------'

Khi có quyền truy cập vào D1, điều này xảy ra:

1. Ai đó thực hiện chuyển I2C sang D1.
 2. M1 khóa mux trên cha mẹ của nó (bộ điều hợp gốc trong trường hợp này).
 3. M1 khóa bộ điều hợp chính của nó.
 4. Cuộc gọi M1 -> chọn để sẵn sàng mux.
 5. Nếu M1 thực hiện bất kỳ chuyển giao I2C nào (trên bộ điều hợp gốc này) như một phần của
     lựa chọn của nó, những lần chuyển tiền đó phải được mở khóa chuyển khoản I2C để
     rằng chúng không gây bế tắc cho bộ điều hợp gốc.
 6. M1 cung cấp quá trình chuyển I2C từ bước 1 sang bộ điều hợp gốc dưới dạng
     đã mở khóa chuyển I2C để nó không làm bế tắc cha mẹ
     bộ chuyển đổi.
 7. Cuộc gọi M1 ->bỏ chọn, nếu có.
 8. Quy tắc tương tự như ở bước 5, nhưng đối với ->bỏ chọn.
 9. M1 mở khóa bộ điều hợp chính của nó.
 10. M1 mở khóa mux trên cha mẹ của nó.

Điều này có nghĩa là quyền truy cập vào cả D2 và D3 đều bị khóa hoàn toàn
thời gian của toàn bộ hoạt động.

Hãy cẩn thận do cha mẹ khóa
~~~~~~~~~~~~~~~~~~~~~

Khi sử dụng mux có khóa gốc, hãy lưu ý các hạn chế sau:

[PL1]
  Nếu bạn xây dựng một cấu trúc liên kết với mux khóa cha là con
  của một mux khác, điều này có thể phá vỡ một giả định có thể có từ
  mux con rằng bộ điều hợp gốc không được sử dụng giữa hoạt động chọn của nó
  và chuyển giao thực tế (ví dụ: nếu mux con tự động đóng
  và mux gốc phát hành chuyển I2C như một phần của lựa chọn của nó).
  Điều này đặc biệt xảy ra nếu mux gốc bị khóa mux, nhưng
  điều này cũng có thể xảy ra nếu mux cha mẹ bị khóa.

[PL2]
  Nếu chọn/bỏ chọn gọi tới các hệ thống con khác như gpio,
  pinctrl, regmap hoặc iio, điều cần thiết là mọi chuyển I2C đều
  gây ra bởi các hệ thống con này đã được mở khóa. Điều này có thể phức tạp thành
  hoàn thành, thậm chí có thể là không thể nếu một giải pháp sạch có thể chấp nhận được
  được tìm kiếm.


Ví dụ phức tạp
================

Mux bị khóa cha mẹ là cha mẹ của mux bị khóa cha mẹ
------------------------------------------------

Đây là một cấu trúc liên kết hữu ích, nhưng nó có thể xấu::

.----------.     .----------.     .-------.
    .-------.     ZZ0000ZZ------ZZ0001ZZ----ZZ0002ZZ
    ZZ0003ZZ--+--ZZ0004ZZ ZZ0005ZZ '--------'
    '--------' ZZ0006ZZ mux M1 ZZ0007ZZ mux M2 |--.  .-------.
                ZZ0008ZZ '----------' '--ZZ0009ZZ
                ZZ0010ZZ .--------.       '--------'
                '--ZZ0011ZZ'--ZZ0012ZZ
                   '--------''--------'

Khi bất kỳ thiết bị nào được truy cập, tất cả các thiết bị khác sẽ bị khóa trong
toàn bộ thời gian hoạt động (cả hai mux đều khóa cha mẹ của chúng,
và đặc biệt khi M2 yêu cầu khóa cha của nó, M1 sẽ vượt qua
tiền cho bộ điều hợp gốc).

Cấu trúc liên kết này không tốt nếu M2 là mux tự động đóng và M1->select
phát hành bất kỳ chuyển I2C đã mở khóa nào trên bộ điều hợp gốc có thể bị rò rỉ
xuyên qua và được bộ chuyển đổi M2 nhìn thấy, do đó đóng M2 sớm.


Mux bị khóa mux là cha mẹ của mux bị khóa mux
------------------------------------------

Đây là một cấu trúc liên kết tốt::

.----------.     .----------.     .-------.
    .-------.     ZZ0000ZZ------ZZ0001ZZ----ZZ0002ZZ
    ZZ0003ZZ--+--ZZ0004ZZ ZZ0005ZZ '--------'
    '--------' ZZ0006ZZ mux M1 ZZ0007ZZ mux M2 |--.  .-------.
                ZZ0008ZZ '----------' '--ZZ0009ZZ
                ZZ0010ZZ .--------.       '--------'
                '--ZZ0011ZZ'--ZZ0012ZZ
                   '--------''--------'

Khi thiết bị D1 được truy cập, quyền truy cập vào D2 sẽ bị khóa đối với
toàn bộ thời gian hoạt động (mux trên bộ điều hợp con trên cùng của M1
đang bị khóa). Nhưng quyền truy cập vào D3 và D4 có thể được xen kẽ tại
bất kỳ điểm nào.

Truy cập vào D3 sẽ khóa D1 và D2, nhưng vẫn có thể truy cập vào D4
xen kẽ.


Mux bị khóa Mux là cha mẹ của mux bị khóa cha mẹ
---------------------------------------------

Đây có lẽ là một cấu trúc liên kết xấu::

.----------.     .----------.     .-------.
    .-------.     ZZ0000ZZ------ZZ0001ZZ----ZZ0002ZZ
    ZZ0003ZZ--+--ZZ0004ZZ ZZ0005ZZ '--------'
    '--------' ZZ0006ZZ mux M1 ZZ0007ZZ mux M2 |--.  .-------.
                ZZ0008ZZ '----------' '--ZZ0009ZZ
                ZZ0010ZZ .--------.       '--------'
                '--ZZ0011ZZ'--ZZ0012ZZ
                   '--------''--------'

Khi thiết bị D1 được truy cập, quyền truy cập vào D2 và D3 sẽ bị khóa
trong toàn bộ thời gian hoạt động (M1 khóa các mux con trên
bộ điều hợp gốc). Nhưng quyền truy cập vào D4 có thể được xen kẽ bất cứ lúc nào
điểm.

Loại cấu trúc liên kết này thường không phù hợp và có lẽ nên
tránh được. Lý do là M2 có thể giả định rằng sẽ có
không được chuyển I2C trong các lệnh gọi ->chọn và ->bỏ chọn, và
nếu có, mọi giao dịch chuyển tiền như vậy có thể xuất hiện ở phía nô lệ của M2
như chuyển I2C một phần, tức là rác hoặc tệ hơn. Điều này có thể gây ra
khóa thiết bị và/hoặc các vấn đề khác.

Cấu trúc liên kết đặc biệt rắc rối nếu M2 là một cơ chế tự động đóng
mux. Trong trường hợp đó, mọi truy cập xen kẽ vào D4 đều có thể đóng M2
sớm, vì bất kỳ I2C nào cũng có thể chuyển một phần của M1->select.

Nhưng nếu M2 không đưa ra giả định nêu trên và nếu M2 không đưa ra
tự động đóng, cấu trúc liên kết vẫn ổn.


Mux bị khóa cha mẹ là cha mẹ của mux bị khóa mux
---------------------------------------------

Đây là một cấu trúc liên kết tốt::

.----------.     .----------.     .-------.
    .-------.     ZZ0000ZZ------ZZ0001ZZ----ZZ0002ZZ
    ZZ0003ZZ--+--ZZ0004ZZ ZZ0005ZZ '--------'
    '--------' ZZ0006ZZ mux M1 ZZ0007ZZ mux M2 |--.  .-------.
                ZZ0008ZZ '----------' '--ZZ0009ZZ
                ZZ0010ZZ .--------.       '--------'
                '--ZZ0011ZZ'--ZZ0012ZZ
                   '--------''--------'

Khi D1 được truy cập, quyền truy cập vào D2 sẽ bị khóa hoàn toàn
thời gian hoạt động (mux trên bộ điều hợp con trên cùng của M1
đang bị khóa). Quyền truy cập vào D3 và D4 có thể được xen kẽ tại
bất kỳ điểm nào, đúng như mong đợi đối với các mux bị khóa mux.

Khi D3 hoặc D4 được truy cập, mọi thứ khác sẽ bị khóa. Đối với D3
truy cập, M1 khóa bộ điều hợp gốc. Đối với quyền truy cập D4, thư mục gốc
bộ chuyển đổi bị khóa trực tiếp.


Hai mux anh chị em bị khóa mux
----------------------------

Đây là một cấu trúc liên kết tốt::

.-------.
                   .----------.  .--ZZ0000ZZ
                   ZZ0001ZZ--' '-------'
                .--ZZ0002ZZ .---------.
                ZZ0003ZZ mux M1 ZZ0004ZZ dev D2 |
                |  '----------' '--------'
                |  .----------.     .-------.
    .-------.  ZZ0005ZZ mux- ZZ0006ZZ dev D3 |
    ZZ0007ZZ--+--ZZ0008ZZ '--------'
    '--------' ZZ0009ZZ mux M2 |--.  .-------.
                ZZ0010ZZ dev D4 |
                |  .-------.       '--------'
                '--ZZ0011ZZ
                   '--------'

Khi truy cập D1, quyền truy cập vào D2, D3 và D4 sẽ bị khóa. Nhưng
quyền truy cập vào D5 có thể được xen kẽ bất cứ lúc nào.


Hai mux anh chị em bị khóa bởi cha mẹ
-------------------------------

Đây là một cấu trúc liên kết tốt::

.-------.
                   .----------.  .--ZZ0000ZZ
                   ZZ0001ZZ--' '-------'
                .--ZZ0002ZZ .---------.
                ZZ0003ZZ mux M1 ZZ0004ZZ dev D2 |
                |  '----------' '--------'
                |  .----------.     .-------.
    .-------.  ZZ0005ZZ cha mẹ- ZZ0006ZZ dev D3 |
    ZZ0007ZZ--+--ZZ0008ZZ '--------'
    '--------' ZZ0009ZZ mux M2 |--.  .-------.
                ZZ0010ZZ dev D4 |
                |  .-------.       '--------'
                '--ZZ0011ZZ
                   '--------'

Khi bất kỳ thiết bị nào được truy cập, quyền truy cập vào tất cả các thiết bị khác sẽ bị khóa
ra ngoài.


Mux anh chị em bị khóa Mux và khóa cha mẹ
------------------------------------------

Đây là một cấu trúc liên kết tốt::

.-------.
                   .----------.  .--ZZ0000ZZ
                   ZZ0001ZZ--' '-------'
                .--ZZ0002ZZ .---------.
                ZZ0003ZZ mux M1 ZZ0004ZZ dev D2 |
                |  '----------' '--------'
                |  .----------.     .-------.
    .-------.  ZZ0005ZZ cha mẹ- ZZ0006ZZ dev D3 |
    ZZ0007ZZ--+--ZZ0008ZZ '--------'
    '--------' ZZ0009ZZ mux M2 |--.  .-------.
                ZZ0010ZZ dev D4 |
                |  .-------.       '--------'
                '--ZZ0011ZZ
                   '--------'

Khi D1 hoặc D2 được truy cập, quyền truy cập vào D3 và D4 sẽ bị khóa trong khi
quyền truy cập vào D5 có thể xen kẽ. Khi D3 hoặc D4 được truy cập, truy cập vào
tất cả các thiết bị khác đều bị khóa.


Loại Mux của trình điều khiển thiết bị hiện có
===================================

Việc thiết bị bị khóa mux hay khóa cha mẹ tùy thuộc vào thiết bị đó
thực hiện. Danh sách sau đây là chính xác tại thời điểm viết bài:

Trong trình điều khiển/i2c/muxes/:

======================= ==================================================
i2c-arb-gpio-challenge Đã khóa cha mẹ
i2c-mux-gpio Thông thường iff bị khóa cha, bị khóa mux
                          tất cả các chân gpio liên quan đều được điều khiển bởi
                          cùng một bộ điều hợp gốc I2C mà họ kết hợp.
i2c-mux-gpmux Thông thường iff bị khóa cha, bị khóa mux
                          được chỉ định trong cây thiết bị.
i2c-mux-ltc4306 Đã khóa Mux
i2c-mux-mlxcpld Đã khóa cha mẹ
i2c-mux-pca9541 Đã khóa cha mẹ
i2c-mux-pca954x Đã khóa cha mẹ
i2c-mux-pinctrl Thông thường, iff bị khóa cha, bị khóa mux
                          tất cả các thiết bị pinctrl liên quan đều được kiểm soát
                          bởi cùng một bộ điều hợp gốc I2C mà họ kết hợp.
i2c-mux-reg Đã khóa cha mẹ
======================= ==================================================

Trong trình điều khiển/iio/:

======================= ==================================================
con quay hồi chuyển/mpu3050 Mux-bị khóa
imu/inv_mpu6050/ Đã khóa Mux
======================= ==================================================

Trong trình điều khiển/phương tiện/:

=========================================================================
dvb-frontends/lgdt3306a Đã khóa Mux
dvb-frontends/m88ds3103 Bị khóa chính
dvb-frontends/rtl2830 Đã khóa chính
dvb-frontends/rtl2832 Mux-locked
dvb-frontends/si2168 Mux-locked
usb/cx231xx/ Bị khóa gốc
=========================================================================
