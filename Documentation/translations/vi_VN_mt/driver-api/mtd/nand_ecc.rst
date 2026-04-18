.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/mtd/nand_ecc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================
Mã sửa lỗi NAND
==========================

Giới thiệu
============

Sau khi xem xét phần mềm linux mtd/nand Hamming trình điều khiển động cơ ECC
Tôi cảm thấy có chỗ cho sự tối ưu hóa. Tôi đã bash mã trong vài giờ
thực hiện các thủ thuật như tra cứu bảng, loại bỏ mã thừa, v.v.
Sau đó tốc độ được tăng lên 35-40%.
Tuy nhiên, tôi vẫn không vui lắm vì tôi cảm thấy còn nhiều điều cần cải thiện.

Xấu! Tôi đã bị cuốn hút.
Tôi quyết định chú thích các bước của mình trong tập tin này. Có lẽ nó hữu ích cho ai đó
hoặc ai đó học được điều gì đó từ nó.


vấn đề
===========

Đèn flash NAND (ít nhất là một chiếc SLC) thường có các cung 256 byte.
Tuy nhiên, đèn flash NAND không đáng tin cậy lắm nên phát hiện một số lỗi
(và đôi khi phải chỉnh sửa) là cần thiết.

Việc này được thực hiện bằng mã Hamming. Tôi sẽ cố gắng giải thích nó trong
các điều khoản của giáo dân (và xin gửi lời xin lỗi tới tất cả các chuyên gia trong lĩnh vực này trong trường hợp tôi làm vậy
không sử dụng đúng thuật ngữ, lớp lý thuyết mã hóa của tôi đã gần 30
nhiều năm trước, và tôi phải thừa nhận đó không phải là một trong những bộ phim tôi yêu thích).

Như tôi đã nói trước khi tính toán ecc được thực hiện trên các cung 256
byte. Điều này được thực hiện bằng cách tính toán một số bit chẵn lẻ trên các hàng và
cột. Tính chẵn lẻ được sử dụng là tính chẵn lẻ, nghĩa là bit chẵn lẻ = 1
nếu dữ liệu tính chẵn lẻ là 1 và bit chẵn lẻ = 0
nếu dữ liệu dùng để tính chẵn lẻ là 0. Vậy tổng
số bit trên dữ liệu mà tính chẵn lẻ được tính toán +
bit chẵn lẻ là số chẵn. (xem wikipedia nếu bạn không thể theo dõi được điều này).
Tính chẵn lẻ thường được tính bằng phương pháp độc quyền hoặc hoạt động,
đôi khi còn được gọi là xor. Trong C toán tử cho xor là ^

Quay lại ecc.
Hãy đưa ra một con số nhỏ:

============= ==== ==== ==== ==== ==== ==== ==== === === === === ====
byte 0: bit7 bit6 bit5 bit4 bit3 bit2 bit1 bit0 rp0 rp2 rp4 ... rp14
byte 1: bit7 bit6 bit5 bit4 bit3 bit2 bit1 bit0 rp1 rp2 rp4 ... rp14
byte 2: bit7 bit6 bit5 bit4 bit3 bit2 bit1 bit0 rp0 rp3 rp4 ... rp14
byte 3: bit7 bit6 bit5 bit4 bit3 bit2 bit1 bit0 rp1 rp3 rp4 ... rp14
byte 4: bit7 bit6 bit5 bit4 bit3 bit2 bit1 bit0 rp0 rp2 rp5 ... rp14
...
byte 254: bit7 bit6 bit5 bit4 bit3 bit2 bit1 bit0 rp0 rp3 rp5 ... rp15
byte 255: bit7 bit6 bit5 bit4 bit3 bit2 bit1 bit0 rp1 rp3 rp5 ... rp15
           cp1 cp0 cp1 cp0 cp1 cp0 cp1 cp0
           cp3 cp3 cp2 cp2 cp3 cp3 cp2 cp2
           cp5 cp5 cp5 cp5 cp4 cp4 cp4 cp4
============= ==== ==== ==== ==== ==== ==== ==== === === === === ====

Con số này đại diện cho một khu vực có 256 byte.
cp là viết tắt của tôi cho tính chẵn lẻ của cột, rp cho tính chẵn lẻ của hàng.

Hãy bắt đầu giải thích tính chẵn lẻ của cột.

- cp0 là parity thuộc về tất cả bit0, bit2, bit4, bit6.

vì vậy tổng của tất cả các giá trị bit0, bit2, bit4 và bit6 + cp0 là số chẵn.

Tương tự cp1 là tổng của tất cả bit1, bit3, bit5 và bit7.

- cp2 là tính chẵn lẻ trên bit0, bit1, bit4 và bit5
- cp3 là tính chẵn lẻ trên bit2, bit3, bit6 và bit7.
- cp4 là tính chẵn lẻ trên bit0, bit1, bit2 và bit3.
- cp5 là tính chẵn lẻ trên bit4, bit5, bit6 và bit7.

Lưu ý rằng mỗi cp0 .. cp5 chính xác là một bit.

Tính chẵn lẻ của hàng thực sự hoạt động gần như giống nhau.

- rp0 là parity của tất cả các byte chẵn (0, 2, 4, 6,... 252, 254)
- rp1 là tính chẵn lẻ của tất cả các byte lẻ (1, 3, 5, 7, ..., 253, 255)
- rp2 là tính chẵn lẻ của tất cả các byte 0, 1, 4, 5, 8, 9, ...
  (vì vậy hãy xử lý hai byte, sau đó bỏ qua 2 byte).
- rp3 che một nửa rp2 không che (byte 2, 3, 6, 7, 10, 11, ...)
- đối với rp4 quy tắc là che 4 byte, bỏ qua 4 byte, che 4 byte, bỏ qua 4, v.v.

vì vậy rp4 tính chẵn lẻ trên các byte 0, 1, 2, 3, 8, 9, 10, 11, 16, ...)
- và rp5 che nửa còn lại nên byte 4, 5, 6, 7, 12, 13, 14, 15, 20, ..

Câu chuyện bây giờ trở nên khá nhàm chán. Tôi đoán bạn hiểu ý rồi.

- rp6 bao gồm 8 byte rồi bỏ qua 8 byte, v.v.
- rp7 bỏ qua 8 byte rồi che 8 byte, v.v.
- rp8 bao gồm 16 byte rồi bỏ qua 16, v.v.
- rp9 bỏ qua 16 byte rồi che 16 byte, v.v.
- rp10 bao gồm 32 byte rồi bỏ qua 32, v.v.
- rp11 bỏ qua 32 byte rồi che 32 byte, v.v.
- rp12 bao gồm 64 byte rồi bỏ qua 64, v.v.
- rp13 bỏ qua 64 byte rồi che 64 byte, v.v.
- rp14 bao gồm 128 byte rồi bỏ qua 128
- rp15 bỏ qua 128 byte rồi che 128

Cuối cùng, các bit chẵn lẻ được nhóm lại với nhau thành ba byte như
sau:

===== ===== ===== ===== ===== ===== ===== ===== =====
ECC Bit 7 Bit 6 Bit 5 Bit 4 Bit 3 Bit 2 Bit 1 Bit 0
===== ===== ===== ===== ===== ===== ===== ===== =====
ECC 0 rp07 rp06 rp05 rp04 rp03 rp02 rp01 rp00
ECC 1 rp15 rp14 rp13 rp12 rp11 rp10 rp09 rp08
ECC 2 cp5 cp4 cp3 cp2 cp1 cp0 1 1
===== ===== ===== ===== ===== ===== ===== ===== =====

Tôi đã phát hiện sau khi viết bài này rằng ghi chú ứng dụng ST AN1823
(ZZ0000ZZ mang lại nhiều
hình ảnh đẹp hơn. (nhưng họ sử dụng tính chẵn lẻ dòng như thuật ngữ mà tôi sử dụng tính chẵn lẻ hàng)
Ồ, tôi gặp khó khăn về mặt đồ họa, vì vậy hãy cùng tôi chịu đựng một lát :-)

Và dù sao thì tôi cũng không thể sử dụng lại ảnh ST vì lý do bản quyền.


Cố gắng 0
=========

Việc thực hiện tính toán chẵn lẻ khá đơn giản.
Trong mã giả C::

vì (i = 0; i < 256; i++)
  {
    nếu (tôi & 0x01)
       rp1 = bit7^bit6^bit5^bit4^bit3^bit2^bit1^bit0^rp1;
    khác
       rp0 = bit7^bit6^bit5^bit4^bit3^bit2^bit1^bit0^rp0;
    nếu (tôi & 0x02)
       rp3 = bit7^bit6^bit5^bit4^bit3^bit2^bit1^bit0^rp3;
    khác
       rp2 = bit7^bit6^bit5^bit4^bit3^bit2^bit1^bit0^rp2;
    nếu (tôi & 0x04)
      rp5 = bit7^bit6^bit5^bit4^bit3^bit2^bit1^bit0^rp5;
    khác
      rp4 = bit7^bit6^bit5^bit4^bit3^bit2^bit1^bit0^rp4;
    nếu (tôi & 0x08)
      rp7 = bit7^bit6^bit5^bit4^bit3^bit2^bit1^bit0^rp7;
    khác
      rp6 = bit7^bit6^bit5^bit4^bit3^bit2^bit1^bit0^rp6;
    nếu (tôi & 0x10)
      rp9 = bit7^bit6^bit5^bit4^bit3^bit2^bit1^bit0^rp9;
    khác
      rp8 = bit7^bit6^bit5^bit4^bit3^bit2^bit1^bit0^rp8;
    nếu (tôi & 0x20)
      rp11 = bit7^bit6^bit5^bit4^bit3^bit2^bit1^bit0^rp11;
    khác
      rp10 = bit7^bit6^bit5^bit4^bit3^bit2^bit1^bit0^rp10;
    nếu (tôi & 0x40)
      rp13 = bit7^bit6^bit5^bit4^bit3^bit2^bit1^bit0^rp13;
    khác
      rp12 = bit7^bit6^bit5^bit4^bit3^bit2^bit1^bit0^rp12;
    nếu (tôi & 0x80)
      rp15 = bit7^bit6^bit5^bit4^bit3^bit2^bit1^bit0^rp15;
    khác
      rp14 = bit7^bit6^bit5^bit4^bit3^bit2^bit1^bit0^rp14;
    cp0 = bit6^bit4^bit2^bit0^cp0;
    cp1 = bit7^bit5^bit3^bit1^cp1;
    cp2 = bit5^bit4^bit1^bit0^cp2;
    cp3 = bit7^bit6^bit3^bit2^cp3
    cp4 = bit3^bit2^bit1^bit0^cp4
    cp5 = bit7^bit6^bit5^bit4^cp5
  }


Phân tích 0
==========

C có các toán tử bitwise nhưng không thực sự có các toán tử để thực hiện những việc trên
hiệu quả (và hầu hết phần cứng cũng không có hướng dẫn như vậy).
Do đó, nếu không thực hiện điều này thì rõ ràng đoạn mã trên đã bị
sẽ không mang lại cho tôi giải thưởng Nobel :-)

May mắn thay phép toán độc quyền hoặc là giao hoán nên chúng ta có thể kết hợp
các giá trị theo bất kỳ thứ tự nào. Vì vậy, thay vì tính toán tất cả các bit
riêng lẻ, chúng ta hãy cố gắng sắp xếp lại mọi thứ.
Đối với tính chẵn lẻ của cột, điều này thật dễ dàng. Chúng ta chỉ có thể xor các byte và trong
cuối lọc ra các bit có liên quan. Điều này khá hay vì nó sẽ mang lại
tất cả tính toán cp ngoài vòng lặp for.

Tương tự, trước tiên chúng ta có thể xor các byte cho các hàng khác nhau.
Điều này dẫn đến:


Cố gắng 1
=========

::

const char chẵn lẻ [256] = {
      0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0,
      1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1,
      1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1,
      0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0,
      1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1,
      0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0,
      0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0,
      1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1,
      1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1,
      0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0,
      0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0,
      1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1,
      0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0,
      1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1,
      1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1,
      0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0
  };

void ecc1(const unsigned char *buf, unsigned char *code)
  {
      int tôi;
      const unsigned char *bp = buf;
      cur không dấu;
      ký tự không dấu rp0, rp1, rp2, rp3, rp4, rp5, rp6, rp7;
      char không dấu rp8, rp9, rp10, rp11, rp12, rp13, rp14, rp15;
      mệnh giá char không dấu;

mệnh giá = 0;
      rp0 = 0; rp1 = 0; rp2 = 0; rp3 = 0;
      rp4 = 0; rp5 = 0; rp6 = 0; rp7 = 0;
      rp8 = 0; rp9 = 0; rp10 = 0; rp11 = 0;
      rp12 = 0; rp13 = 0; rp14 = 0; rp15 = 0;

vì (i = 0; i < 256; i++)
      {
          cur = *bp++;
          par ^= cur;
          if (i & 0x01) rp1 ^= cur; khác rp0 ^= cur;
          if (i & 0x02) rp3 ^= cur; khác rp2 ^= cur;
          if (i & 0x04) rp5 ^= cur; khác rp4 ^= cur;
          if (i & 0x08) rp7 ^= cur; khác rp6 ^= cur;
          if (i & 0x10) rp9 ^= cur; khác rp8 ^= cur;
          if (i & 0x20) rp11 ^= cur; khác rp10 ^= cur;
          if (i & 0x40) rp13 ^= cur; khác rp12 ^= cur;
          if (i & 0x80) rp15 ^= cur; khác rp14 ^= cur;
      }
      mã[0] =
          (chẵn lẻ[rp7] << 7) |
          (chẵn lẻ[rp6] << 6) |
          (chẵn lẻ[rp5] << 5) |
          (chẵn lẻ[rp4] << 4) |
          (chẵn lẻ[rp3] << 3) |
          (chẵn lẻ[rp2] << 2) |
          (chẵn lẻ[rp1] << 1) |
          (chẵn lẻ [rp0]);
      mã [1] =
          (chẵn lẻ[rp15] << 7) |
          (chẵn lẻ[rp14] << 6) |
          (chẵn lẻ[rp13] << 5) |
          (chẵn lẻ[rp12] << 4) |
          (chẵn lẻ[rp11] << 3) |
          (chẵn lẻ[rp10] << 2) |
          (chẵn lẻ[rp9] << 1) |
          (chẵn lẻ [rp8]);
      mã [2] =
          (chẵn lẻ[par & 0xf0] << 7) |
          (chẵn lẻ[par & 0x0f] << 6) |
          (chẵn lẻ[par & 0xcc] << 5) |
          (chẵn lẻ[par & 0x33] << 4) |
          (chẵn lẻ[par & 0xaa] << 3) |
          (chẵn lẻ [par & 0x55] << 2);
      mã[0] = ~mã[0];
      mã[1] = ~mã[1];
      mã[2] = ~mã[2];
  }

Vẫn khá đơn giản. Ba câu lệnh đảo ngược cuối cùng là để
đưa ra tổng kiểm tra 0xff 0xff 0xff cho đèn flash trống. Trong nháy mắt trống rỗng
tất cả dữ liệu là 0xff, do đó tổng kiểm tra sẽ khớp.

Tôi cũng đã giới thiệu việc tra cứu tính chẵn lẻ. Tôi mong đợi điều này là nhanh nhất
cách tính chẵn lẻ, nhưng tôi sẽ nghiên cứu các lựa chọn thay thế sau
trên.


Phân tích 1
==========

Mã này hoạt động nhưng không hiệu quả lắm. Trên hệ thống của tôi phải mất
gần gấp 4 lần thời gian so với mã trình điều khiển linux. Nhưng này, nếu như vậy
ZZ0000ZZ dễ dàng việc này đã được thực hiện từ lâu rồi.
Không đau. không có lợi.

May mắn thay có rất nhiều chỗ để cải thiện.

Ở bước 1, chúng ta đã chuyển từ tính toán theo bit sang tính toán theo byte.
Tuy nhiên trong C chúng ta cũng có thể sử dụng kiểu dữ liệu dài không dấu và hầu như
mọi bộ vi xử lý hiện đại đều hỗ trợ hoạt động 32 bit, vậy tại sao bạn không thử
để viết mã theo cách chúng tôi xử lý dữ liệu theo từng khối 32 bit.

Tất nhiên điều này có nghĩa là một số sửa đổi vì tính chẵn lẻ của hàng là byte theo
byte. Một phân tích nhanh:
đối với tính chẵn lẻ của cột, chúng tôi sử dụng biến par. Khi mở rộng lên 32 bit
cuối cùng chúng ta có thể dễ dàng tính toán rp0 và rp1 từ nó.
(vì par bây giờ gồm 4 byte, góp phần tạo ra rp1, rp0, rp1, rp0
tương ứng, từ MSB đến LSB)
Ngoài ra, rp2 và rp3 có thể được lấy ra dễ dàng từ mệnh giá vì rp3 bao trùm
hai MSB đầu tiên và rp2 bao gồm hai LSB cuối cùng.

Lưu ý rằng tất nhiên bây giờ vòng lặp chỉ được thực hiện 64 lần (256/4).
Và lưu ý rằng phải cẩn thận khi sắp xếp thứ tự byte. Cách thức của byte
đặt hàng trong thời gian dài phụ thuộc vào máy và có thể ảnh hưởng đến chúng tôi.
Dù sao đi nữa, nếu có vấn đề: mã này được phát triển trên x86 (sẽ được
chính xác: PC DELL với D920 Intel CPU)

Và tất nhiên hiệu suất có thể phụ thuộc vào sự liên kết, nhưng tôi mong đợi
rằng bộ đệm I/O trong trình điều khiển nand được căn chỉnh chính xác (và
nếu không thì cần sửa để có hiệu suất tối đa).

Hãy thử xem...


Nỗ lực 2
=========

::

extern const char chẵn lẻ [256];

void ecc2(const char không dấu *buf, unsigned char *code)
  {
      int tôi;
      const dài không dấu ZZ0001ZZ)buf;
      dòng dài không dấu;
      dài không dấu rp0, rp1, rp2, rp3, rp4, rp5, rp6, rp7;
      dài không dấu rp8, rp9, rp10, rp11, rp12, rp13, rp14, rp15;
      mệnh giá dài không dấu;

mệnh giá = 0;
      rp0 = 0; rp1 = 0; rp2 = 0; rp3 = 0;
      rp4 = 0; rp5 = 0; rp6 = 0; rp7 = 0;
      rp8 = 0; rp9 = 0; rp10 = 0; rp11 = 0;
      rp12 = 0; rp13 = 0; rp14 = 0; rp15 = 0;

vì (i = 0; i < 64; i++)
      {
          cur = *bp++;
          par ^= cur;
          if (i & 0x01) rp5 ^= cur; khác rp4 ^= cur;
          if (i & 0x02) rp7 ^= cur; khác rp6 ^= cur;
          if (i & 0x04) rp9 ^= cur; khác rp8 ^= cur;
          if (i & 0x08) rp11 ^= cur; khác rp10 ^= cur;
          if (i & 0x10) rp13 ^= cur; khác rp12 ^= cur;
          if (i & 0x20) rp15 ^= cur; khác rp14 ^= cur;
      }
      /*
         chúng ta cần điều chỉnh việc tạo mã vì thực tế là các vars rp hiện nay
         dài; cũng cần phải thay đổi tính toán chẵn lẻ của cột.
         chúng tôi sẽ đưa rp4 về 15 trở lại các thực thể byte đơn bằng cách dịch chuyển và
         xoring
      */
      rp4 ^= (rp4 >> 16); rp4 ^= (rp4 >> 8); rp4 &= 0xff;
      rp5 ^= (rp5 >> 16); rp5 ^= (rp5 >> 8); rp5 &= 0xff;
      rp6 ^= (rp6 >> 16); rp6 ^= (rp6 >> 8); rp6 &= 0xff;
      rp7 ^= (rp7 >> 16); rp7 ^= (rp7 >> 8); rp7 &= 0xff;
      rp8 ^= (rp8 >> 16); rp8 ^= (rp8 >> 8); rp8 &= 0xff;
      rp9 ^= (rp9 >> 16); rp9 ^= (rp9 >> 8); rp9 &= 0xff;
      rp10 ^= (rp10 >> 16); rp10 ^= (rp10 >> 8); rp10 &= 0xff;
      rp11 ^= (rp11 >> 16); rp11 ^= (rp11 >> 8); rp11 &= 0xff;
      rp12 ^= (rp12 >> 16); rp12 ^= (rp12 >> 8); rp12 &= 0xff;
      rp13 ^= (rp13 >> 16); rp13 ^= (rp13 >> 8); rp13 &= 0xff;
      rp14 ^= (rp14 >> 16); rp14 ^= (rp14 >> 8); rp14 &= 0xff;
      rp15 ^= (rp15 >> 16); rp15 ^= (rp15 >> 8); rp15 &= 0xff;
      rp3 = (par >> 16); rp3 ^= (rp3 >> 8); rp3 &= 0xff;
      rp2 = mệnh giá & 0xffff; rp2 ^= (rp2 >> 8); rp2 &= 0xff;
      mệnh ^= (par >> 16);
      rp1 = (par >> 8); rp1 &= 0xff;
      rp0 = (par & 0xff);
      mệnh ^= (par >> 8); mệnh giá &= 0xff;

mã[0] =
          (chẵn lẻ[rp7] << 7) |
          (chẵn lẻ[rp6] << 6) |
          (chẵn lẻ[rp5] << 5) |
          (chẵn lẻ[rp4] << 4) |
          (chẵn lẻ[rp3] << 3) |
          (chẵn lẻ[rp2] << 2) |
          (chẵn lẻ[rp1] << 1) |
          (chẵn lẻ [rp0]);
      mã [1] =
          (chẵn lẻ[rp15] << 7) |
          (chẵn lẻ[rp14] << 6) |
          (chẵn lẻ[rp13] << 5) |
          (chẵn lẻ[rp12] << 4) |
          (chẵn lẻ[rp11] << 3) |
          (chẵn lẻ[rp10] << 2) |
          (chẵn lẻ[rp9] << 1) |
          (chẵn lẻ [rp8]);
      mã [2] =
          (chẵn lẻ[par & 0xf0] << 7) |
          (chẵn lẻ[par & 0x0f] << 6) |
          (chẵn lẻ[par & 0xcc] << 5) |
          (chẵn lẻ[par & 0x33] << 4) |
          (chẵn lẻ[par & 0xaa] << 3) |
          (chẵn lẻ [par & 0x55] << 2);
      mã[0] = ~mã[0];
      mã[1] = ~mã[1];
      mã[2] = ~mã[2];
  }

Mảng chẵn lẻ không được hiển thị nữa. Cũng lưu ý rằng đối với những
ví dụ tôi hơi khác với phong cách lập trình thông thường của mình bằng cách cho phép
nhiều câu lệnh trên một dòng, không sử dụng { } trong các khối then và else
chỉ với một câu lệnh duy nhất và bằng cách sử dụng các toán tử như ^=


Phân tích 2
==========

Mã (tất nhiên) hoạt động và hoan hô: chúng tôi nhanh hơn một chút so với
mã trình điều khiển linux (khoảng 15%). Nhưng chờ đã, đừng vui mừng quá nhanh.
Có nhiều hơn nữa để đạt được.
Nếu chúng ta nhìn vào ví dụ. rp14 và rp15, chúng tôi thấy rằng chúng tôi xor dữ liệu của mình với
rp14 hoặc với rp15. Tuy nhiên, chúng tôi cũng có mệnh giá bao trùm tất cả dữ liệu.
Điều này có nghĩa là không cần phải tính rp14 vì nó có thể được tính từ
rp15 đến rp14 = par ^ rp15, vì par = rp14 ^ rp15;
(hoặc nếu muốn chúng ta có thể tránh tính rp15 và tính nó từ
rp14).  Đó là lý do tại sao một số nơi đề cập đến tính chẵn lẻ nghịch đảo.
Tất nhiên điều tương tự cũng xảy ra với rp4/5, rp6/7, rp8/9, rp10/11 và rp12/13.
Thực tế, điều này có nghĩa là chúng ta có thể loại bỏ mệnh đề else khỏi if
các tuyên bố. Ngoài ra chúng ta có thể tối ưu hóa phép tính cuối cùng một chút
bằng cách chuyển từ dài sang byte trước. Thực ra chúng ta thậm chí có thể tránh được cái bàn
tra cứu

Nỗ lực 3
=========

Số lẻ thay thế::

if (i & 0x01) rp5 ^= cur; khác rp4 ^= cur;
          if (i & 0x02) rp7 ^= cur; khác rp6 ^= cur;
          if (i & 0x04) rp9 ^= cur; khác rp8 ^= cur;
          if (i & 0x08) rp11 ^= cur; khác rp10 ^= cur;
          if (i & 0x10) rp13 ^= cur; khác rp12 ^= cur;
          if (i & 0x20) rp15 ^= cur; khác rp14 ^= cur;

với::

if (i & 0x01) rp5 ^= cur;
          if (i & 0x02) rp7 ^= cur;
          if (i & 0x04) rp9 ^= cur;
          if (i & 0x08) rp11 ^= cur;
          if (i & 0x10) rp13 ^= cur;
          if (i & 0x20) rp15 ^= cur;

và bên ngoài vòng lặp đã thêm ::

rp4 = mệnh giá ^ rp5;
          rp6 = mệnh giá ^ rp7;
          rp8 = mệnh giá ^ rp9;
          rp10 = mệnh giá ^ rp11;
          rp12 = mệnh giá ^ rp13;
          rp14 = mệnh giá ^ rp15;

Và sau đó mã mất thêm khoảng 30% thời gian, mặc dù số lượng
các phát biểu bị giảm đi. Điều này cũng được phản ánh trong mã lắp ráp.


Phân tích 3
==========

Rất kỳ lạ. Đoán nó có liên quan đến bộ nhớ đệm hoặc hướng dẫn song song
hoặc như vậy. Tôi cũng đã thử trên eeePC (Celeron, tốc độ 900 Mhz). Thú vị
quan sát là cái này chỉ chậm hơn 30% (theo thời gian)
thực thi mã như bộ xử lý D920 3GHz của tôi.

Chà, dự kiến là sẽ không dễ dàng nên thay vào đó có thể chuyển sang một
bài hát khác: hãy quay lại mã từ nỗ lực2 và thực hiện một số
hủy vòng lặp. Điều này sẽ loại bỏ một số câu lệnh if. tôi sẽ cố gắng
số lượng hủy đăng ký khác nhau để xem cái nào hoạt động tốt nhất.


Nỗ lực 4
=========

Mở vòng lặp 1, 2, 3 và 4 lần.
Đối với 4 mã bắt đầu bằng::

vì (i = 0; i < 4; i++)
    {
        cur = *bp++;
        par ^= cur;
        rp4 ^= cur;
        rp6 ^= cur;
        rp8 ^= cur;
        rp10 ^= cur;
        if (i & 0x1) rp13 ^= cur; khác rp12 ^= cur;
        if (i & 0x2) rp15 ^= cur; khác rp14 ^= cur;
        cur = *bp++;
        par ^= cur;
        rp5 ^= cur;
        rp6 ^= cur;
        ...


Phân tích 4
==========

Bỏ đăng ký một lần tăng khoảng 15%

Việc hủy đăng ký hai lần giữ mức tăng ở mức khoảng 15%

Bỏ đăng ký ba lần sẽ tăng 30% so với lần thử 2.

Việc hủy cuộn bốn lần mang lại sự cải thiện nhỏ so với việc hủy cuộn
ba lần.

Dù sao thì tôi cũng quyết định tiếp tục với một vòng lặp không được kiểm soát bốn lần. Đó là ruột của tôi
cảm thấy rằng trong các bước tiếp theo tôi sẽ thu được thêm lợi ích từ nó.

Bước tiếp theo được kích hoạt bởi thực tế là mệnh giá chứa xor của tất cả
mỗi byte và rp4 và rp5 chứa xor của một nửa số byte.
Vì vậy, có hiệu lực par = rp4 ^ rp5. Nhưng vì xor có tính giao hoán nên chúng ta cũng có thể nói
đó rp5 = mệnh ^ rp4. Vì vậy, không cần phải giữ cả rp4 và rp5. Chúng tôi có thể
loại bỏ rp5 (hoặc rp4, nhưng tôi đã thấy trước một cách tối ưu hóa khác).
Điều tương tự cũng xảy ra với rp6/7, rp8/9, rp10/11 rp12/13 và rp14/15.


Cố gắng 5
=========

Có hiệu quả là tất cả các phép gán rp chữ số lẻ trong vòng lặp đều bị xóa.
Điều này bao gồm mệnh đề else của câu lệnh if.
Tất nhiên sau vòng lặp, chúng ta cần sửa lại mọi thứ bằng cách thêm mã như ::

rp5 = mệnh giá ^ rp4;

Ngoài ra, các bài tập ban đầu (rp5 = 0; v.v.) có thể bị xóa.
Đồng thời, tôi cũng đã xóa phần khởi tạo rp0/1/2/3.


Phân tích 5
==========

Các phép đo cho thấy đây là một động thái tốt. Thời gian chạy gần như giảm đi một nửa
so với lần thử 4 với 4 lần không được kiểm soát và chúng tôi chỉ yêu cầu 1/3
về thời gian của bộ xử lý so với mã hiện tại trong nhân linux.

Tuy nhiên, tôi vẫn nghĩ còn nhiều hơn thế. Tôi không thích tất cả nếu
các tuyên bố. Tại sao không giữ một số chẵn lẻ đang chạy và chỉ giữ số cuối cùng nếu
tuyên bố. Thời gian cho một phiên bản khác!


Cố gắng 6
=========

Mã trong vòng lặp for đã được đổi thành::

vì (i = 0; i < 4; i++)
    {
        cur = *bp++; tmppar = cur; rp4 ^= cur;
        cur = *bp++; tmppar ^= cur; rp6 ^= tmppar;
        cur = *bp++; tmppar ^= cur; rp4 ^= cur;
        cur = *bp++; tmppar ^= cur; rp8 ^= tmppar;

cur = *bp++; tmppar ^= cur; rp4 ^= cur; rp6 ^= cur;
        cur = *bp++; tmppar ^= cur; rp6 ^= cur;
        cur = *bp++; tmppar ^= cur; rp4 ^= cur;
        cur = *bp++; tmppar ^= cur; rp10 ^= tmppar;

cur = *bp++; tmppar ^= cur; rp4 ^= cur; rp6 ^= cur; rp8 ^= cur;
        cur = *bp++; tmppar ^= cur; rp6 ^= cur; rp8 ^= cur;
        cur = *bp++; tmppar ^= cur; rp4 ^= cur; rp8 ^= cur;
        cur = *bp++; tmppar ^= cur; rp8 ^= cur;

cur = *bp++; tmppar ^= cur; rp4 ^= cur; rp6 ^= cur;
        cur = *bp++; tmppar ^= cur; rp6 ^= cur;
        cur = *bp++; tmppar ^= cur; rp4 ^= cur;
        cur = *bp++; tmppar ^= cur;

par ^= tmppar;
        if ((i & 0x1) == 0) rp12 ^= tmppar;
        if ((i & 0x2) == 0) rp14 ^= tmppar;
    }

Như bạn có thể thấy tmppar được sử dụng để tích lũy tính chẵn lẻ trong một for
sự lặp lại. Trong 3 câu lệnh cuối cùng được thêm vào mệnh giá và nếu cần,
đến rp12 và rp14.

Trong khi thực hiện các thay đổi, tôi cũng nhận thấy rằng tôi có thể khai thác tmppar đó
chứa tính chẵn lẻ đang chạy cho lần lặp này. Vì vậy, thay vì có:
rp4 ^= cur; rp6 ^= cur;
Tôi đã xóa rp6 ^= cur; tuyên bố và đã làm rp6 ^= tmppar; tiếp theo
tuyên bố. Một thay đổi tương tự đã được thực hiện cho rp8 và rp10


Phân tích 6
==========

Đo mã này một lần nữa cho thấy mức tăng lớn. Khi thực hiện bản gốc
mã linux 1 triệu lần, việc này mất khoảng 1 giây trên hệ thống của tôi.
(dùng thời gian để đo lường hiệu suất). Sau lần lặp lại này tôi đã trở lại
đến 0,075 giây. Thực ra tôi đã phải quyết định bắt đầu đo trên 10
triệu lần lặp để không mất quá nhiều độ chính xác. Cái này
chắc chắn dường như là giải độc đắc!

Tuy nhiên, vẫn còn một chút chỗ để cải thiện. Có ba
những nơi có câu lệnh::

rp4 ^= cur; rp6 ^= cur;

Có vẻ hiệu quả hơn khi duy trì một biến rp4_6 trong thời gian đó
vòng lặp; Điều này giúp loại bỏ 3 câu lệnh trên mỗi vòng lặp. Tất nhiên sau vòng lặp chúng ta
cần sửa bằng cách thêm::

rp4 ^= rp4_6;
	rp6 ^= rp4_6

Hơn nữa, có 4 nhiệm vụ tuần tự cho rp8. Đây có thể là
được mã hóa hiệu quả hơn một chút bằng cách lưu tmppar trước 4 dòng đó
và sau này làm rp8 = rp8^tmppar^notrp8;
(trong đó notrp8 là giá trị của rp8 trước 4 dòng đó).
Một lần nữa sử dụng tính chất giao hoán của xor.
Thời gian cho một thử nghiệm mới!


Cố gắng 7
=========

Mã mới bây giờ trông giống như::

vì (i = 0; i < 4; i++)
    {
        cur = *bp++; tmppar = cur; rp4 ^= cur;
        cur = *bp++; tmppar ^= cur; rp6 ^= tmppar;
        cur = *bp++; tmppar ^= cur; rp4 ^= cur;
        cur = *bp++; tmppar ^= cur; rp8 ^= tmppar;

cur = *bp++; tmppar ^= cur; rp4_6 ^= cur;
        cur = *bp++; tmppar ^= cur; rp6 ^= cur;
        cur = *bp++; tmppar ^= cur; rp4 ^= cur;
        cur = *bp++; tmppar ^= cur; rp10 ^= tmppar;

notrp8 = tmppar;
        cur = *bp++; tmppar ^= cur; rp4_6 ^= cur;
        cur = *bp++; tmppar ^= cur; rp6 ^= cur;
        cur = *bp++; tmppar ^= cur; rp4 ^= cur;
        cur = *bp++; tmppar ^= cur;
        rp8 = rp8^tmppar^notrp8;

cur = *bp++; tmppar ^= cur; rp4_6 ^= cur;
        cur = *bp++; tmppar ^= cur; rp6 ^= cur;
        cur = *bp++; tmppar ^= cur; rp4 ^= cur;
        cur = *bp++; tmppar ^= cur;

par ^= tmppar;
        if ((i & 0x1) == 0) rp12 ^= tmppar;
        if ((i & 0x2) == 0) rp14 ^= tmppar;
    }
    rp4 ^= rp4_6;
    rp6 ^= rp4_6;


Không phải là một thay đổi lớn, nhưng mỗi xu đều có giá trị :-)


Phân tích 7
==========

Thực ra điều này còn khiến mọi việc trở nên tồi tệ hơn. Không nhiều lắm, nhưng tôi không muốn di chuyển
đi sai hướng. Có lẽ có gì đó để điều tra sau. có thể
phải làm lại với bộ nhớ đệm.

Đoán đó là những gì cần có để giành chiến thắng trong vòng lặp. Có thể là bỏ một cái
thêm thời gian sẽ giúp ích. Bây giờ tôi sẽ giữ mức tối ưu hóa từ 7.


Cố gắng 8
=========

Đã mở vòng lặp một lần nữa.


Phân tích 8
==========

Điều này làm cho mọi thứ tồi tệ hơn. Hãy tiếp tục nỗ lực thứ 6 và tiếp tục từ đó.
Mặc dù có vẻ như mã trong vòng lặp không thể được tối ưu hóa
hơn nữa vẫn còn chỗ để tối ưu hóa việc tạo mã ecc.
Chúng ta có thể tính toán tổng số chẵn lẻ một cách đơn giản. Nếu đây là 0 thì rp4 = rp5
v.v. Nếu chẵn lẻ là 1 thì rp4 = !rp5;

Nhưng nếu rp4 = rp5 thì chúng ta không cần rp5, v.v. Chúng ta chỉ có thể viết các bit chẵn
trong byte kết quả và sau đó thực hiện một cái gì đó như ::

mã[0] |= (mã[0] << 1);

Hãy kiểm tra điều này.


Cố gắng 9
=========

Đã thay đổi mã nhưng một lần nữa điều này làm giảm hiệu suất một chút. Đã thử tất cả
những thứ khác, chẳng hạn như có các mảng chẵn lẻ chuyên dụng để tránh
dịch chuyển sau tính chẵn lẻ[rp7] << 7; Không đạt được.
Thay đổi tra cứu bằng cách sử dụng mảng chẵn lẻ bằng cách sử dụng toán tử dịch chuyển (ví dụ:
thay thế chẵn lẻ [rp7] << 7 bằng::

rp7 ^= (rp7 << 4);
	rp7 ^= (rp7 << 2);
	rp7 ^= (rp7 << 1);
	rp7 &= 0x80;

Không đạt được.

Thay đổi nhỏ duy nhất là đảo ngược các bit chẵn lẻ để chúng ta có thể loại bỏ
ba câu lệnh đảo ngược cuối cùng.

À, tiếc là điều này không mang lại nhiều hơn thế. Rồi lại 10 triệu
số lần lặp sử dụng mã trình điều khiển linux mất từ ​​13 đến 13,5
giây, trong khi mã của tôi hiện mất khoảng 0,73 giây cho 10 giây đó
triệu lần lặp. Vì vậy, về cơ bản tôi đã cải thiện hiệu suất bằng một
yếu tố 18 trên hệ thống của tôi. Không tệ đến thế. Tất nhiên trên phần cứng khác nhau
bạn sẽ nhận được kết quả khác nhau. Không có bảo đảm!

Nhưng tất nhiên không có bữa trưa nào miễn phí cả. Kích thước mã gần như
tăng gấp ba lần (từ 562 byte lên 1434 byte). Sau đó, một lần nữa, nó không phải là nhiều.


Sửa lỗi
=================

Để sửa lỗi, tôi lại sử dụng ghi chú ứng dụng ST làm phần mở đầu,
nhưng tôi cũng đã xem qua mã hiện có.

Bản thân thuật toán khá đơn giản. Chỉ cần xor cái đã cho và
ecc được tính toán. Nếu tất cả byte bằng 0 thì không có vấn đề gì. Nếu 11 bit
là 1 chúng tôi có một lỗi bit có thể sửa được. Nếu có 1 bit 1 thì chúng ta có
lỗi trong mã ecc đã cho.

Nó được chứng minh là nhanh nhất để thực hiện một số tra cứu bảng. Tăng hiệu suất
được giới thiệu bởi điều này là về yếu tố 2 trên hệ thống của tôi khi phải sửa chữa
được thực hiện và khoảng 1% nếu không cần phải sửa chữa.

Kích thước mã tăng từ 330 byte lên 686 byte cho hàm này.
(gcc 4.2, -O3)


Phần kết luận
==========

Lợi ích khi tính toán ecc là rất lớn. Ôi phần cứng phát triển của tôi
đã đạt được sự tăng tốc hệ số 18 cho tính toán ecc. Trong một bài kiểm tra trên
hệ thống nhúng với lõi MIPS đã đạt được hệ số 7.

Trong thử nghiệm với Linksys NSLU2 (bộ xử lý ARMv5TE), tốc độ tăng tốc là một yếu tố
5 (chế độ endian lớn, gcc 4.1.2, -O3)

Để điều chỉnh, không thể thu được nhiều lợi ích (vì bitflip rất hiếm). Sau đó
một lần nữa cũng có ít chu kỳ hơn ở đó.

Có vẻ như không thể đạt được nhiều lợi ích hơn nữa trong việc này, ít nhất là khi
được lập trình bằng C. Tất nhiên có thể ép được thứ gì đó nhiều hơn
thoát khỏi nó bằng chương trình biên dịch mã, nhưng do hoạt động của đường ống, v.v.
điều này rất phức tạp (ít nhất là đối với intel hw).

Tác giả: Frans Meulenbroeks

Bản quyền (C) 2008 Koninklijke Philips Electronics NV.
