.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/packing.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================================
Chức năng đóng gói và giải nén bitfield chung
====================================================

Tuyên bố vấn đề
-----------------

Khi làm việc với phần cứng, người ta phải lựa chọn giữa một số cách tiếp cận
giao tiếp với nó.
Người ta có thể ánh xạ bộ nhớ một con trỏ tới một cấu trúc được chế tạo cẩn thận trên phần cứng
vùng bộ nhớ của thiết bị và truy cập các trường của nó dưới dạng thành viên cấu trúc (có khả năng
được khai báo là bitfield). Nhưng viết mã theo cách này sẽ khiến nó khó di chuyển hơn,
do tiềm ẩn sự không khớp về độ bền giữa CPU và thiết bị phần cứng.
Ngoài ra, người ta phải hết sức chú ý khi dịch sổ đăng ký.
định nghĩa từ tài liệu phần cứng thành các chỉ số trường bit cho
cấu trúc. Ngoài ra, một số phần cứng (thường là thiết bị mạng) có xu hướng nhóm
các trường đăng ký của nó theo cách vi phạm mọi ranh giới từ hợp lý
(đôi khi thậm chí là 64 bit). Điều này gây ra sự bất tiện khi phải
xác định phần "cao" và "thấp" của trường thanh ghi trong cấu trúc.
Một giải pháp thay thế mạnh mẽ hơn cho các định nghĩa trường cấu trúc sẽ là trích xuất
các trường bắt buộc bằng cách dịch chuyển số bit thích hợp. Nhưng điều này sẽ
vẫn không bảo vệ khỏi sự không khớp về độ bền, trừ khi tất cả bộ nhớ truy cập
được thực hiện từng byte một. Ngoài ra, mã có thể dễ dàng bị lộn xộn và
ý tưởng cấp cao có thể bị lạc giữa nhiều thay đổi bit cần thiết.
Nhiều trình điều khiển thực hiện phương pháp dịch chuyển bit và sau đó cố gắng giảm
lộn xộn với các macro được tùy chỉnh, nhưng thường thì các macro này chiếm
các phím tắt vẫn ngăn không cho mã thực sự có thể di chuyển được.

Giải pháp
------------

API này xử lý 2 thao tác cơ bản:

- Đóng gói số CPU có thể sử dụng được vào bộ nhớ đệm (có phần cứng
    hạn chế/điều kỳ quặc)
  - Giải nén bộ đệm bộ nhớ (có các hạn chế/quirks về phần cứng)
    thành số CPU có thể sử dụng được.

API cung cấp một cái nhìn trừu tượng về các hạn chế và yêu cầu phần cứng đã nói ở trên,
hơn độ bền của CPU và do đó có thể có sự không khớp giữa
hai.

Đơn vị cơ bản của các hàm API này là u64. Từ CPU
phối cảnh, bit 63 luôn có nghĩa là bit bù 7 của byte 7, mặc dù chỉ
một cách logic. Câu hỏi là: chúng ta đặt bit này ở đâu trong bộ nhớ?

Các ví dụ sau bao gồm cách bố trí bộ nhớ của trường u64 được đóng gói.
Độ lệch byte trong bộ đệm đóng gói luôn ngầm định là 0, 1, ... 7.
Những gì các ví dụ cho thấy là vị trí của các byte và bit logic.

1. Thông thường (không có gì đặc biệt), chúng ta sẽ làm như thế này:

::

63 62 61 60 59 58 57 56 55 54 53 52 51 50 49 48 47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32
  7 6 5 4
  31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
  3 2 1 0

Nghĩa là, MSByte (7) của u64 có thể sử dụng được CPU nằm ở độ lệch bộ nhớ 0 và
LSByte (0) của u64 nằm ở vị trí bù bộ nhớ 7.
Điều này tương ứng với điều mà hầu hết mọi người gọi là "big endian", trong đó
bit i tương ứng với số 2^i. Điều này cũng được đề cập trong mã
nhận xét dưới dạng ký hiệu "logic".


2. Nếu QUIRK_MSB_ON_THE_RIGHT được đặt, chúng tôi thực hiện như thế này:

::

56 57 58 59 60 61 62 63 48 49 50 51 52 53 54 55 40 41 42 43 44 45 46 47 32 33 34 35 36 37 38 39
  7 6 5 4
  24 25 26 27 28 29 30 31 16 17 18 19 20 21 22 23 8 9 10 11 12 13 14 15 0 1 2 3 4 5 6 7
  3 2 1 0

Nghĩa là, QUIRK_MSB_ON_THE_RIGHT không ảnh hưởng đến việc định vị byte, nhưng
đảo ngược độ lệch bit bên trong một byte.


3. Nếu QUIRK_LITTLE_ENDIAN được đặt, chúng tôi thực hiện như thế này:

::

39 38 37 36 35 34 33 32 47 46 45 44 43 42 41 40 55 54 53 52 51 50 49 48 63 62 61 60 59 58 57 56
  4 5 6 7
  7 6 5 4 3 2 1 0 15 14 13 12 11 10 9 8 23 22 21 20 19 18 17 16 31 30 29 28 27 26 25 24
  0 1 2 3

Do đó, QUIRK_LITTLE_ENDIAN có nghĩa là bên trong vùng bộ nhớ, mọi
byte từ mỗi từ 4 byte được đặt ở vị trí đối xứng của nó so với
ranh giới của từ đó.

4. Nếu QUIRK_MSB_ON_THE_RIGHT và QUIRK_LITTLE_ENDIAN đều được đặt, chúng tôi sẽ thực hiện
   như thế này:

::

32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63
  4 5 6 7
  0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
  0 1 2 3


5. Nếu chỉ đặt QUIRK_LSW32_IS_FIRST, chúng ta sẽ làm như thế này:

::

31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
  3 2 1 0
  63 62 61 60 59 58 57 56 55 54 53 52 51 50 49 48 47 46 45 44 43 42 41 40 39 38 37 36 35 34 33 32
  7 6 5 4

Trong trường hợp này vùng bộ nhớ 8 byte được hiểu như sau: đầu tiên
4 byte tương ứng với từ có 4 byte ít quan trọng nhất, 4 byte tiếp theo tương ứng với từ
từ 4 byte quan trọng hơn.


6. Nếu QUIRK_LSW32_IS_FIRST và QUIRK_MSB_ON_THE_RIGHT được đặt, chúng tôi sẽ thực hiện như sau
   cái này:

::

24 25 26 27 28 29 30 31 16 17 18 19 20 21 22 23 8 9 10 11 12 13 14 15 0 1 2 3 4 5 6 7
  3 2 1 0
  56 57 58 59 60 61 62 63 48 49 50 51 52 53 54 55 40 41 42 43 44 45 46 47 32 33 34 35 36 37 38 39
  7 6 5 4


7. Nếu QUIRK_LSW32_IS_FIRST và QUIRK_LITTLE_ENDIAN được đặt, có vẻ như
   cái này:

::

7 6 5 4 3 2 1 0 15 14 13 12 11 10 9 8 23 22 21 20 19 18 17 16 31 30 29 28 27 26 25 24
  0 1 2 3
  39 38 37 36 35 34 33 32 47 46 45 44 43 42 41 40 55 54 53 52 51 50 49 48 63 62 61 60 59 58 57 56
  4 5 6 7


8. Nếu QUIRK_LSW32_IS_FIRST, QUIRK_LITTLE_ENDIAN và QUIRK_MSB_ON_THE_RIGHT
   được thiết lập, nó trông như thế này:

::

0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31
  0 1 2 3
  32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63
  4 5 6 7


Chúng tôi luôn nghĩ về sự bù đắp của mình như thể không có gì sai trái, và chúng tôi dịch
chúng sau đó, trước khi truy cập vào vùng bộ nhớ.

Lưu ý về độ dài bộ đệm không phải là bội số của 4
-------------------------------------------------

Để giải quyết các vấn đề về bố cục bộ nhớ trong đó các nhóm 4 byte được sắp xếp "nhỏ".
endian" so với nhau, nhưng là "big endian" trong chính nhóm đó,
khái niệm về nhóm 4 byte là nội tại của việc đóng gói API (không được
bị nhầm lẫn với việc truy cập bộ nhớ, tuy nhiên, được thực hiện theo từng byte).

Với độ dài bộ đệm không phải là bội số của 4, điều này có nghĩa là một nhóm sẽ không đầy đủ.
Tùy thuộc vào các đặc điểm, điều này có thể dẫn đến sự gián đoạn trong các trường bit
có thể truy cập thông qua bộ đệm. Việc đóng gói API giả định sự gián đoạn là không
mục đích của việc bố trí bộ nhớ, do đó nó tránh được chúng bằng cách hợp lý một cách hiệu quả
rút ngắn nhóm 4 octet quan trọng nhất thành số octet
thực sự có sẵn.

Ví dụ với bộ đệm có kích thước 31 byte được đưa ra bên dưới. Độ lệch bộ đệm vật lý là
ẩn và tăng dần từ trái sang phải trong một nhóm và từ trên xuống
dưới cùng trong một cột.

Không có điều kỳ quặc:

::

31 29 28 |   Nhóm 7 (đáng kể nhất)
 27 26 25 24 |   Nhóm 6
 23 22 21 20 |   Nhóm 5
 19 18 17 16 |   Nhóm 4
 15 14 13 12 |   Nhóm 3
 11 10 9 8 |   Nhóm 2
  7 6 5 4 |   Nhóm 1
  3 2 1 0 |   Nhóm 0 (ít ý nghĩa nhất)

QUIRK_LSW32_IS_FIRST:

::

3 2 1 0 |   Nhóm 0 (ít ý nghĩa nhất)
  7 6 5 4 |   Nhóm 1
 11 10 9 8 |   Nhóm 2
 15 14 13 12 |   Nhóm 3
 19 18 17 16 |   Nhóm 4
 23 22 21 20 |   Nhóm 5
 27 26 25 24 |   Nhóm 6
 30 29 28 |   Nhóm 7 (đáng kể nhất)

QUIRK_LITTLE_ENDIAN:

::

30 28 29 |   Nhóm 7 (đáng kể nhất)
 24 25 26 27 |   Nhóm 6
 20 21 22 23 |   Nhóm 5
 16 17 18 19 |   Nhóm 4
 12 13 14 15 |   Nhóm 3
  8 9 10 11 |   Nhóm 2
  4 5 6 7 |   Nhóm 1
  0 1 2 3 |   Nhóm 0 (ít ý nghĩa nhất)

QUIRK_LITTLE_ENDIAN | QUIRK_LSW32_IS_FIRST:

::

0 1 2 3 |   Nhóm 0 (ít ý nghĩa nhất)
  4 5 6 7 |   Nhóm 1
  8 9 10 11 |   Nhóm 2
 12 13 14 15 |   Nhóm 3
 16 17 18 19 |   Nhóm 4
 20 21 22 23 |   Nhóm 5
 24 25 26 27 |   Nhóm 6
 28 29 30 |   Nhóm 7 (đáng kể nhất)

Mục đích sử dụng
----------------

Trình điều khiển chọn sử dụng API này trước tiên cần xác định cái nào trong 3 cái trên
các kết hợp ngẫu nhiên (tổng cộng là 8) khớp với tài liệu phần cứng
mô tả.

Có 3 kiểu sử dụng được hỗ trợ, được trình bày chi tiết bên dưới.

đóng gói()
^^^^^^^^^^

Chức năng API này không được dùng nữa.

Hàm đóng gói () trả về mã lỗi được mã hóa int, để bảo vệ
lập trình viên chống lại việc sử dụng API không chính xác.  Những lỗi không được mong đợi sẽ xảy ra
trong thời gian chạy, do đó, việc bọc gói() vào một tùy chỉnh là hợp lý
hàm trả về void và nuốt những lỗi đó. Tùy chọn nó có thể
đổ ngăn xếp hoặc in mô tả lỗi.

.. code-block:: c

  void my_packing(void *buf, u64 *val, int startbit, int endbit,
                  size_t len, enum packing_op op)
  {
          int err;

          /* Adjust quirks accordingly */
          err = packing(buf, val, startbit, endbit, len, op, QUIRK_LSW32_IS_FIRST);
          if (likely(!err))
                  return;

          if (err == -EINVAL) {
                  pr_err("Start bit (%d) expected to be larger than end (%d)\n",
                         startbit, endbit);
          } else if (err == -ERANGE) {
                  if ((startbit - endbit + 1) > 64)
                          pr_err("Field %d-%d too large for 64 bits!\n",
                                 startbit, endbit);
                  else
                          pr_err("Cannot store %llx inside bits %d-%d (would truncate)\n",
                                 *val, startbit, endbit);
          }
          dump_stack();
  }

gói() và giải nén()
^^^^^^^^^^^^^^^^^^^

Đây là các biến thể đóng gói () đúng hằng số và loại bỏ "enum" cuối cùng
đối số đóng gói_op op".

Gọi pack(...) tương đương và được ưu tiên hơn là gọi pack(..., PACK).

Gọi giải nén(...) tương đương và được ưu tiên hơn là gọi đóng gói(..., UNPACK).

pack_fields() và unpack_fields()
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Thư viện hiển thị các hàm được tối ưu hóa cho kịch bản có nhiều
các trường được biểu thị trong bộ đệm và nó khuyến khích người tiêu dùng tránh
các cuộc gọi lặp đi lặp lại tới pack() và unpack() cho từng trường, nhưng thay vào đó hãy sử dụng
pack_fields() và unpack_fields(), giúp giảm dấu chân mã.

Các API này sử dụng định nghĩa trường trong mảng ZZ0000ZZ hoặc
ZZ0001ZZ, cho phép trình điều khiển tiêu dùng giảm thiểu kích thước
của các mảng này theo yêu cầu tùy chỉnh của họ.

Các hàm pack_fields() và unpack_fields() API thực chất là các macro
tự động chọn chức năng thích hợp tại thời điểm biên dịch, dựa trên
loại mảng trường được truyền vào.

Một lợi ích bổ sung so với pack() và unpack() là việc kiểm tra độ tỉnh táo trên
định nghĩa trường được xử lý tại thời điểm biên dịch với ZZ0000ZZ thay vì
hơn là chỉ khi mã vi phạm được thực thi. Các hàm này trả về void và
gói chúng để xử lý các lỗi không mong muốn là không cần thiết.

Bạn nên bọc bộ đệm đã đóng gói của mình vào một túi đựng, nhưng không bắt buộc, nhưng không bắt buộc.
loại có cấu trúc với kích thước cố định. Điều này thường tạo điều kiện dễ dàng hơn cho
trình biên dịch để thực thi rằng bộ đệm có kích thước chính xác được sử dụng.

Dưới đây là ví dụ về cách sử dụng API trường:

.. code-block:: c

   /* Ordering inside the unpacked structure is flexible and can be different
    * from the packed buffer. Here, it is optimized to reduce padding.
    */
   struct data {
        u64 field3;
        u32 field4;
        u16 field1;
        u8 field2;
   };

   #define SIZE 13

   typedef struct __packed { u8 buf[SIZE]; } packed_buf_t;

   static const struct packed_field_u8 fields[] = {
           PACKED_FIELD(100, 90, struct data, field1),
           PACKED_FIELD(90, 87, struct data, field2),
           PACKED_FIELD(86, 30, struct data, field3),
           PACKED_FIELD(29, 0, struct data, field4),
   };

   void unpack_your_data(const packed_buf_t *buf, struct data *unpacked)
   {
           BUILD_BUG_ON(sizeof(*buf) != SIZE;

           unpack_fields(buf, sizeof(*buf), unpacked, fields,
                         QUIRK_LITTLE_ENDIAN);
   }

   void pack_your_data(const struct data *unpacked, packed_buf_t *buf)
   {
           BUILD_BUG_ON(sizeof(*buf) != SIZE;

           pack_fields(buf, sizeof(*buf), unpacked, fields,
                       QUIRK_LITTLE_ENDIAN);
   }
