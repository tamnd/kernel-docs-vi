.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/iio/iio_adc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Tóm tắt IIO cho ADC
=========================

1. Tổng quan
===========

Hệ thống con IIO hỗ trợ nhiều Bộ chuyển đổi Tương tự sang Kỹ thuật số (ADC). Một số ADC
có các tính năng và đặc điểm được IIO hỗ trợ theo những cách cụ thể
trình điều khiển thiết bị. Tài liệu này mô tả các tính năng phổ biến của ADC và giải thích
cách chúng được hỗ trợ bởi hệ thống con IIO.

1. Các loại kênh ADC
====================

ADC có thể có các loại đầu vào riêng biệt, mỗi loại đều đo điện áp tương tự
theo một cách hơi khác. ADC số hóa điện áp đầu vào tương tự qua
khoảng thường được đưa ra bởi tham chiếu điện áp được cung cấp, loại đầu vào và
cực đầu vào. Cần có phạm vi đầu vào được phép cho kênh ADC để
xác định hệ số tỷ lệ và độ lệch cần thiết để thu được giá trị đo được trong
đơn vị thực tế (mV để đo điện áp, miliampe để đo dòng điện
đo lường, v.v.).

Các thiết kế phức tạp có thể có các đặc tính phi tuyến hoặc các thành phần tích hợp
(chẳng hạn như bộ khuếch đại và bộ đệm tham chiếu) cũng có thể phải được xem xét
để lấy phạm vi đầu vào được phép cho ADC. Để rõ ràng, các phần dưới đây
giả sử phạm vi đầu vào chỉ phụ thuộc vào tham chiếu điện áp được cung cấp, đầu vào
loại và cực đầu vào.

Có ba loại đầu vào ADC chung (một đầu, vi sai,
giả vi phân) và hai cực có thể có (đơn cực, lưỡng cực). đầu vào
loại (một đầu, vi sai, giả vi phân) là một kênh
đặc trưng và hoàn toàn độc lập với cực (đơn cực,
khía cạnh lưỡng cực). Một bài viết toàn diện về các loại đầu vào ADC (trong đó bài viết này
doc dựa chủ yếu vào) có thể được tìm thấy tại
ZZ0000ZZ

1.1 Kênh một đầu
-------------------------

Các kênh một đầu số hóa điện áp đầu vào tương tự so với mặt đất và
có thể là đơn cực hoặc lưỡng cực.

1.1.1 Kênh đơn cực một đầu
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

---------- VREF -------------
      ` ZZ0000ZZ _____________
    / \ / \ / |
   / \ / \ --- < TRONG ADC |
            \ / \ / \ |
             ZZ0001ZZ-' \ VREF |
  -------- GND (0V) ------------- +----------+
                                                  ^
                                                  |
                                             VREF bên ngoài

Điện áp đầu vào của kênh ZZ0000ZZ được phép dao động
từ GND đến VREF (trong đó VREF là điện áp tham chiếu có điện thế
cao hơn mặt đất hệ thống). Điện áp đầu vào tối đa còn được gọi là VFS
(Điện áp đầu vào toàn thang đo), với VFS được xác định bởi VREF. Điện áp
tham chiếu có thể được cung cấp từ nguồn bên ngoài hoặc lấy từ nguồn chip
nguồn.

Kênh đơn cực một đầu có thể được mô tả trong cây thiết bị giống như
ví dụ sau::

adc@0 {
        ...
#address-cells = <1>;
        #size-cells = <0>;

kênh@0 {
            reg = <0>;
        };
    };

Người ta luôn được phép bao gồm các nút kênh ADC trong cây thiết bị. Mặc dù vậy,
nếu thiết bị có một bộ đầu vào thống nhất (ví dụ: tất cả các đầu vào đều là một đầu),
thì việc khai báo các nút kênh là tùy chọn.

Một lưu ý dành cho các thiết bị hỗ trợ các kênh vi sai và một đầu kết hợp
là các nút kênh một đầu cũng cần cung cấp ZZ0000ZZ
thuộc tính khi ZZ0001ZZ là số tùy ý không khớp với mã pin đầu vào
số.

Xem ZZ0000ZZ để biết đầy đủ
tài liệu về các thuộc tính cây thiết bị cụ thể của ADC.


1.1.2 Kênh lưỡng cực một đầu
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

---------- +VREF ------------
      ` ZZ0000ZZ _____________________
    / \ / \ / |
   / \ / \ --- < TRONG ADC |
            \ / \ / \ |
             ZZ0001ZZ-' \ +VREF -VREF |
  ---------- -VREF ------------ +-------------------+
                                                  ^ ^
                                                  ZZ0002ZZ
                             Bên ngoài +VREF ------+ Bên ngoài -VREF

Đối với kênh ZZ0000ZZ, đầu vào điện áp analog có thể đi từ
-VREF đến +VREF (trong đó -VREF là tham chiếu điện áp có giá trị thấp hơn
điện thế trong khi +VREF là giá trị tham chiếu có giá trị cao hơn). Một số ADC
các chip lấy tham chiếu thấp hơn từ +VREF, các chip khác lấy nó từ một tham chiếu riêng biệt
đầu vào. Thông thường, +VREF và -VREF đối xứng nhưng chúng không cần phải như vậy. Khi nào
-VREF thấp hơn mặt đất hệ thống, các đầu vào này còn được gọi là đầu cuối đơn
lưỡng cực thực sự. Ngoài ra, mặc dù có sự khác biệt liên quan giữa lưỡng cực và
lưỡng cực thực sự từ góc độ điện, IIO không có sự phân biệt rõ ràng
giữa họ.

Dưới đây là mô tả cây thiết bị mẫu của kênh lưỡng cực một đầu::

adc@0 {
        ...
#address-cells = <1>;
        #size-cells = <0>;

kênh@0 {
            reg = <0>;
            lưỡng cực;
        };
    };

1.2 Kênh vi phân
-------------------------

Phép đo điện áp vi sai số hóa mức điện áp ở cực dương
đầu vào (IN+) so với đầu vào âm (IN-) trong khoảng -VREF đến +VREF.
Nói cách khác, kênh vi sai đo lường sự khác biệt tiềm năng giữa
IN+ và IN-, thường được ký hiệu bằng công thức IN+ - IN-.

1.2.1 Kênh lưỡng cực vi sai
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

-------- +VREF ------ +-------------------+
    ` ZZ0000ZZ / |
  / \ / \ / --- < IN+ |
         ZZ0001ZZ-'ZZ0004ZZ
  -------- -VREF ------ ZZ0005ZZ
                               ZZ0006ZZ
  -------- +VREF ------ ZZ0007ZZ
        ` ZZ0002ZZ ZZ0008ZZ
  \ / \ / \ --- < IN- |
   ZZ0003ZZ-' \ +VREF -VREF |
  -------- -VREF ------ +-------------------+
                                         ^ ^
                                         |       +---- Bên ngoài -VREF
                                  Bên ngoài +VREF

Các tín hiệu tương tự đến đầu vào ZZ0000ZZ cũng được phép xoay
từ -VREF đến +VREF. Phần lưỡng cực của tên có nghĩa là giá trị kết quả
của chênh lệch (IN+ - IN-) có thể dương hoặc âm. Nếu -VREF ở dưới
hệ thống GND, chúng còn được gọi là đầu vào lưỡng cực thực vi sai.

Ví dụ về cây thiết bị của kênh lưỡng cực vi sai::

adc@0 {
        ...
#address-cells = <1>;
        #size-cells = <0>;

kênh@0 {
            reg = <0>;
            lưỡng cực;
            kênh khác = <0 1>;
        };
    };

Trong trình điều khiển ADC, ZZ0000ZZ được đặt thành ZZ0001ZZ cho
kênh này. Mặc dù có ba loại đầu vào chung, ZZ0002ZZ
chỉ được sử dụng để phân biệt giữa vi phân và không vi phân (hoặc
loại đầu vào một đầu hoặc giả vi phân). Xem
ZZ0003ZZ để biết thêm thông tin.

1.2.2 Kênh đơn cực vi sai
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Đối với các kênh ZZ0000ZZ, điện áp analog ở đầu vào dương
cũng phải cao hơn điện áp ở đầu vào âm. Như vậy, thực tế
phạm vi đầu vào được phép đối với kênh đơn cực vi sai là IN- đến +VREF. Bởi vì
IN+ được phép dao động theo tín hiệu analog đo được và thiết lập đầu vào phải
đảm bảo IN+ sẽ không xuống dưới IN- (cũng như IN- sẽ không tăng trên IN+), hầu hết
thiết lập kênh đơn cực vi sai có IN- cố định với một điện áp đã biết
không nằm trong phạm vi điện áp dự kiến cho tín hiệu đo được. Điều đó dẫn
đến một thiết lập tương đương với một kênh giả vi sai. Như vậy,
các thiết lập đơn cực vi sai thường có thể được hỗ trợ dưới dạng giả vi phân
kênh đơn cực.

1.3 Kênh giả vi phân
--------------------------------

Có loại đầu vào ADC thứ ba được gọi là giả vi phân hoặc
kết thúc đơn đến cấu hình vi sai. Một kênh giả vi phân là
tương tự như kênh vi sai ở chỗ nó cũng đo IN+ so với IN-.
Tuy nhiên, không giống như các kênh vi sai lưỡng cực, đầu vào âm bị giới hạn ở
dải điện áp hẹp (được coi là điện áp không đổi) trong khi chỉ cho phép IN+
để đu đưa. Một kênh giả vi sai có thể được tạo ra từ một cặp vi sai
của đầu vào bằng cách hạn chế đầu vào âm ở một điện áp đã biết trong khi vẫn cho phép
chỉ có đầu vào tích cực để xoay. Đôi khi, đầu vào được cung cấp cho IN- được gọi là
điện áp chế độ chung. Ngoài ra, một số bộ phận còn có chân COM cho phép kết nối một đầu
đầu vào được tham chiếu đến điện áp chế độ chung, làm cho chúng
kênh giả vi phân. Thông thường, điện áp đầu vào chế độ chung có thể là
được mô tả trong cây thiết bị như một bộ điều chỉnh điện áp (ví dụ ZZ0000ZZ) vì
về cơ bản nó là một nguồn điện áp không đổi.

1.3.1 Kênh đơn cực giả vi phân
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

-------- +VREF ------ +-------------------+
    ` ZZ0000ZZ / |
  / \ / \ / --- < IN+ |
         ZZ0001ZZ-' ZZ0002ZZ
  --------- TRONG- ------- ZZ0003ZZ
                                ZZ0004ZZ
  Điện áp chế độ chung --> --- < IN- |
                                \ +VREF -VREF |
                                 +-------------------+
                                         ^ ^
                                         |       +---- Bên ngoài -VREF
                                  Bên ngoài +VREF

Đầu vào ZZ0000ZZ có những hạn chế về vi sai
kênh đơn cực sẽ có, nghĩa là điện áp tương tự với đầu vào dương
IN+ phải nằm trong phạm vi IN- đến +VREF. Điện áp cố định vào IN- thường được gọi là
điện áp ở chế độ chung và nó phải nằm trong khoảng -VREF đến +VREF như mong đợi
từ tín hiệu đến bất kỳ đầu vào âm kênh vi sai nào.

Điện áp đo được từ IN+ có liên quan đến IN- nhưng, không giống như điện áp vi sai
các kênh, thiết lập giả vi sai nhằm mục đích đánh giá đầu vào một đầu
tín hiệu. Để cho phép các ứng dụng tính toán điện áp IN+ đối với hệ thống
mặt đất, kênh IIO có thể cung cấp thuộc tính sysfs ZZ0000ZZ để thêm vào
sang đầu ra ADC khi chuyển đổi dữ liệu thô sang đơn vị điện áp. Trong nhiều thiết lập,
đầu vào điện áp chế độ chung ở mức GND và thuộc tính ZZ0001ZZ là
bị bỏ qua do luôn bằng 0.

Ví dụ về cây thiết bị cho kênh đơn cực giả vi sai::

adc@0 {
        ...
#address-cells = <1>;
        #size-cells = <0>;

kênh@0 {
            reg = <0>;
            kênh đơn = <0>;
            kênh chế độ chung = <1>;
        };
    };

Không đặt ZZ0000ZZ trong cấu trúc kênh ZZ0001ZZ của
kênh giả vi phân.

1.3.2 Kênh lưỡng cực giả vi phân
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

-------- +VREF ------ +-------------------+
    ` ZZ0000ZZ / |
  / \ / \ / --- < IN+ |
         ZZ0001ZZ-' ZZ0002ZZ
  -------- -VREF ------ ZZ0003ZZ
                                ZZ0004ZZ
  Điện áp chế độ chung --> --- < IN- |
                                \ +VREF -VREF |
                                 +-------------------+
                                          ^ ^
                                          |       +---- Bên ngoài -VREF
                                   Bên ngoài +VREF

Đầu vào ZZ0002ZZ không bị giới hạn bởi mức IN- nhưng
nó sẽ bị giới hạn ở -VREF hoặc GND ở đầu dưới của phạm vi đầu vào
tùy thuộc vào ADC cụ thể. Tương tự như các bộ phận phản ứng đơn cực của chúng,
các kênh lưỡng cực giả vi sai phải khai báo thuộc tính ZZ0000ZZ
để cho phép chuyển đổi dữ liệu ADC thô sang đơn vị điện áp. Để thiết lập với
IN- được kết nối với GND, ZZ0001ZZ thường bị bỏ qua.

Ví dụ về cây thiết bị cho kênh lưỡng cực giả vi sai::

adc@0 {
        ...
#address-cells = <1>;
        #size-cells = <0>;

kênh@0 {
            reg = <0>;
            lưỡng cực;
            kênh đơn = <0>;
            kênh chế độ chung = <1>;
        };
    };