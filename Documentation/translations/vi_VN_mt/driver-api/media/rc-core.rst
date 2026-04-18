.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/rc-core.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Thiết bị điều khiển từ xa
-------------------------

Lõi điều khiển từ xa
~~~~~~~~~~~~~~~~~~~~~~

Lõi điều khiển từ xa triển khai cơ sở hạ tầng để nhận và gửi
tổ hợp phím và sự kiện chuột trên bàn phím điều khiển từ xa.

Mỗi lần nhấn một phím trên bộ điều khiển từ xa, mã quét sẽ được tạo ra.
Ngoài ra, trên hầu hết phần cứng, việc nhấn một phím trong hơn vài chục lần
mili giây tạo ra một sự kiện quan trọng lặp lại. Điều đó hơi giống với những gì
bàn phím hoặc chuột thông thường được xử lý nội bộ trên Linux\ [#f1]_. Vì vậy,
lõi điều khiển từ xa được triển khai trên đầu vào linux/evdev
giao diện.

.. [#f1]

   The main difference is that, on keyboard events, the keyboard controller
   produces one event for a key press and another one for key release. On
   infrared-based remote controllers, there's no key release event. Instead,
   an extra code is produced to indicate key repeats.

Tuy nhiên, hầu hết các bộ điều khiển từ xa đều sử dụng tia hồng ngoại (IR) để truyền tín hiệu.
Vì có một số giao thức được sử dụng để điều chế tín hiệu hồng ngoại, một
phần quan trọng của lõi được dành riêng để điều chỉnh trình điều khiển và lõi
hệ thống hỗ trợ giao thức hồng ngoại được sử dụng bởi bộ phát.

Việc truyền hồng ngoại được thực hiện bằng cách nhấp nháy bộ phát hồng ngoại bằng
người vận chuyển. Sóng mang có thể được bật hoặc tắt bằng bộ phát hồng ngoại
phần cứng. Khi sóng mang được bật, nó được gọi là ZZ0000ZZ.
Khi sóng mang bị tắt, nó được gọi là ZZ0001ZZ.

Nói cách khác, một quá trình truyền IR điển hình có thể được xem như một chuỗi các
Sự kiện ZZ0000ZZ và ZZ0001ZZ, mỗi sự kiện có thời lượng nhất định.

Các tham số sóng mang (tần số, chu kỳ nhiệm vụ) và các khoảng thời gian cho
Các sự kiện ZZ0000ZZ và ZZ0001ZZ phụ thuộc vào giao thức.
Ví dụ: giao thức NEC sử dụng sóng mang 38kHz và truyền
bắt đầu với ZZ0002ZZ 9ms và SPACE 4,5ms. Sau đó nó truyền 16 bit
mã quét, có 8 bit cho địa chỉ (thường là số cố định cho
bộ điều khiển từ xa), theo sau là 8 bit mã. Một chút "1" được điều chế
với 560µs ZZ0003ZZ, tiếp theo là 1690µs ZZ0004ZZ và một chút "0" được điều chế
với 560µs ZZ0005ZZ, tiếp theo là 560µs ZZ0006ZZ.

Tại máy thu, một bộ lọc thông thấp đơn giản có thể được sử dụng để chuyển đổi tín hiệu nhận được
tín hiệu theo chuỗi các sự kiện ZZ0003ZZ, lọc sóng mang
tần số. Do đó, người nhận không quan tâm đến nhà vận chuyển
thông số tần số thực tế: tất cả những gì nó phải làm là đo lượng
thời gian nó nhận được sự kiện ZZ0004ZZ.
Vì vậy, phần cứng máy thu IR đơn giản sẽ chỉ cung cấp một chuỗi thời gian
cho những sự kiện đó vào Kernel. Các trình điều khiển cho phần cứng có dạng như vậy
máy thu được xác định bởi ZZ0001ZZ, như được xác định bởi
ZZ0000ZZ\ [#f2]_. Phần cứng khác đi kèm với một
bộ vi điều khiển giải mã chuỗi ZZ0005ZZ và quét trả về
mã vào hạt nhân. Những loại máy thu như vậy được xác định
bởi ZZ0002ZZ.

.. [#f2]

   The RC core also supports devices that have just IR emitters,
   without any receivers. Right now, all such devices work only in
   raw TX mode. Such kind of hardware is identified as
   ``RC_DRIVER_IR_RAW_TX``.

Khi lõi RC nhận được các sự kiện do ZZ0001ZZ IR tạo ra
máy thu, nó cần giải mã giao thức IR để có được
mã quét tương ứng. Các giao thức được hỗ trợ bởi lõi RC là
được xác định tại enum ZZ0000ZZ.

Khi mã RC nhận được mã quét (trực tiếp, bởi trình điều khiển
thuộc loại ZZ0000ZZ hoặc thông qua bộ giải mã IR của nó), nó cần
để chuyển đổi thành mã sự kiện đầu vào Linux. Điều này được thực hiện thông qua bản đồ
cái bàn.

Kernel có hỗ trợ lập bản đồ các bảng có sẵn trên hầu hết các phương tiện
thiết bị. Nó cũng hỗ trợ tải một bảng trong thời gian chạy, thông qua một số
các nút sysfs. Xem ZZ0000ZZ
để biết thêm chi tiết.

Cấu trúc và chức năng dữ liệu của bộ điều khiển từ xa
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. kernel-doc:: include/media/rc-core.h

.. kernel-doc:: include/media/rc-map.h