.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/bpf/standardization/instruction-set.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. contents::
.. sectnum::

=========================================
Kiến trúc tập lệnh BPF (ISA)
======================================

eBPF, cũng thường
được gọi là BPF, là một công nghệ có nguồn gốc từ nhân Linux
có thể chạy các chương trình không đáng tin cậy trong bối cảnh đặc quyền chẳng hạn như
hạt nhân của hệ điều hành. Tài liệu này chỉ định lệnh BPF
kiến trúc tập hợp (ISA).

Như một ghi chú lịch sử, BPF ban đầu là viết tắt của Bộ lọc gói Berkeley,
nhưng giờ đây nó có thể làm được nhiều việc hơn là lọc gói, từ viết tắt
không còn ý nghĩa nữa. BPF hiện được coi là một thuật ngữ độc lập
không đại diện cho bất cứ điều gì.  BPF ban đầu đôi khi được gọi
dưới dạng cBPF (BPF cổ điển) để phân biệt với phiên bản hiện được triển khai rộng rãi
eBPF (BPF mở rộng).

Quy ước tài liệu
=========================

Các từ khóa "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY" và
"OPTIONAL" trong tài liệu này được hiểu như được mô tả trong
BCP 14 ZZ0000ZZ
ZZ0001ZZ
khi nào và chỉ khi nào chúng xuất hiện ở tất cả các chữ hoa, như được hiển thị ở đây.

Để ngắn gọn và nhất quán, tài liệu này đề cập đến các họ
các loại sử dụng cú pháp tốc ký và đề cập đến một số cách giải thích,
chức năng ghi nhớ khi mô tả ngữ nghĩa của hướng dẫn.
Phạm vi giá trị hợp lệ cho các loại đó và ngữ nghĩa của chúng
các chức năng được định nghĩa trong các tiểu mục sau.

Các loại
-----
Tài liệu này đề cập đến các loại số nguyên có ký hiệu ZZ0000ZZ để chỉ định
ký hiệu của loại (ZZ0001ZZ) và độ rộng bit (ZZ0002ZZ), tương ứng.

.. table:: Meaning of signedness notation

  ==== =========
  S    Meaning
  ==== =========
  u    unsigned
  s    signed
  ==== =========

.. table:: Meaning of bit-width notation

  ===== =========
  N     Bit width
  ===== =========
  8     8 bits
  16    16 bits
  32    32 bits
  64    64 bits
  128   128 bits
  ===== =========

Ví dụ: ZZ0000ZZ là loại có giá trị hợp lệ là tất cả 32 bit không dấu
số và ZZ0001ZZ là loại có giá trị hợp lệ là tất cả các ký hiệu 16 bit
những con số.

Chức năng
---------

Các hàm hoán đổi byte sau đây không xác định được hướng.  Đó là,
chức năng tương tự được sử dụng để chuyển đổi theo một trong hai hướng đã thảo luận
bên dưới.

* be16: Lấy một số 16-bit không dấu và chuyển đổi nó giữa
  thứ tự byte máy chủ và big-endian
  (ZZ0000ZZ) thứ tự byte.
* be32: Lấy một số 32-bit không dấu và chuyển đổi nó giữa
  thứ tự byte máy chủ và thứ tự byte cuối lớn.
* be64: Lấy một số 64-bit không dấu và chuyển đổi nó giữa
  thứ tự byte máy chủ và thứ tự byte cuối lớn.
* bswap16: Lấy số 16-bit không dấu ở dạng endian lớn hoặc endian nhỏ
  định dạng và trả về số tương đương có cùng độ rộng bit nhưng
  độ bền trái ngược nhau.
* bswap32: Lấy số 32-bit không dấu ở dạng endian lớn hoặc endian nhỏ
  định dạng và trả về số tương đương có cùng độ rộng bit nhưng
  độ bền trái ngược nhau.
* bswap64: Lấy số 64-bit không dấu ở dạng endian lớn hoặc endian nhỏ
  định dạng và trả về số tương đương có cùng độ rộng bit nhưng
  độ bền trái ngược nhau.
* le16: Lấy một số 16-bit không dấu và chuyển đổi nó giữa
  thứ tự byte máy chủ và thứ tự byte endian nhỏ.
* le32: Lấy một số 32-bit không dấu và chuyển đổi nó giữa
  thứ tự byte máy chủ và thứ tự byte endian nhỏ.
* le64: Lấy một số 64-bit không dấu và chuyển đổi nó giữa
  thứ tự byte máy chủ và thứ tự byte endian nhỏ.

định nghĩa
-----------

.. glossary::

  Sign Extend
    To `sign extend an` ``X`` `-bit number, A, to a` ``Y`` `-bit number, B  ,` means to

    #. Copy all ``X`` bits from `A` to the lower ``X`` bits of `B`.
    #. Set the value of the remaining ``Y`` - ``X`` bits of `B` to the value of
       the  most-significant bit of `A`.

.. admonition:: Example

  Sign extend an 8-bit number ``A`` to a 16-bit number ``B`` on a big-endian platform:
  ::

    A:          10000110
    B: 11111111 10000110

Nhóm tuân thủ
------------------

Việc triển khai không cần hỗ trợ tất cả các hướng dẫn được chỉ định trong tài liệu này
tài liệu (ví dụ: hướng dẫn không được dùng nữa).  Thay vào đó, một số sự phù hợp
các nhóm được chỉ định.  Việc triển khai MUST hỗ trợ tuân thủ base32
nhóm và MAY hỗ trợ các nhóm tuân thủ bổ sung, trong đó hỗ trợ một
nhóm tuân thủ có nghĩa là MUST hỗ trợ tất cả các hướng dẫn trong sự tuân thủ đó
nhóm.

Việc sử dụng các nhóm tuân thủ được đặt tên cho phép khả năng tương tác giữa thời gian chạy
thực thi các hướng dẫn và các công cụ như trình biên dịch tạo ra
hướng dẫn cho thời gian chạy.  Vì vậy, việc phát hiện năng lực về mặt
các nhóm tuân thủ có thể được người dùng thực hiện thủ công hoặc tự động bằng các công cụ.

Mỗi nhóm tuân thủ có một nhãn ASCII ngắn (ví dụ: "base32")
tương ứng với một tập hợp các hướng dẫn bắt buộc.  Nghĩa là, mỗi
hướng dẫn có một hoặc nhiều nhóm tuân thủ mà nó là thành viên.

Tài liệu này xác định các nhóm tuân thủ sau:

* base32: bao gồm tất cả các hướng dẫn được xác định trong này
  đặc điểm kỹ thuật trừ khi có ghi chú khác.
* base64: bao gồm base32, cộng với các hướng dẫn được ghi chú rõ ràng
  như nằm trong nhóm tuân thủ base64.
* Atomic32: bao gồm hướng dẫn vận hành nguyên tử 32-bit (xem ZZ0000ZZ).
* Atomic64: bao gồm Atomic32, cộng với hướng dẫn vận hành Atomic 64-bit.
* divmul32: bao gồm các lệnh chia, nhân và modulo 32-bit.
* divmul64: bao gồm divmul32, cộng với phép chia, phép nhân 64-bit,
  và hướng dẫn modulo.
* gói: hướng dẫn truy cập gói không được dùng nữa.

Mã hóa lệnh
====================

BPF có hai mã hóa lệnh:

* mã hóa lệnh cơ bản, sử dụng 64 bit để mã hóa lệnh
* mã hóa lệnh rộng, gắn thêm 64 bit thứ hai
  sau lệnh cơ bản với tổng số 128 bit.

Mã hóa lệnh cơ bản
--------------------------

Một lệnh cơ bản được mã hóa như sau::

+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  ZZ0000ZZ đăng ký ZZ0001ZZ
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  ZZ0002ZZ
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

ZZ0000ZZ
  thao tác cần thực hiện, được mã hóa như sau::

+-+-+-+-+-+-+-+-+
    Lớp |specific ||
    +-+-+-+-+-+-+-+-+

ZZ0000ZZ
    Định dạng của các bit này thay đổi tùy theo lớp lệnh

ZZ0001ZZ
    Lớp hướng dẫn (xem ZZ0000ZZ)

ZZ0000ZZ
  Số thanh ghi nguồn và đích, được mã hóa như sau
  trên một máy chủ endian nhỏ::

+-+-+-+-+-+-+-+-+
    |src_reg|dst_reg|
    +-+-+-+-+-+-+-+-+

và như sau trên máy chủ lớn::

+-+-+-+-+-+-+-+-+
    |dst_reg|src_reg|
    +-+-+-+-+-+-+-+-+

ZZ0001ZZ
    số thanh ghi nguồn (0-10), trừ khi có quy định khác
    (ZZ0000ZZ tái sử dụng trường này cho các mục đích khác)

ZZ0000ZZ
    số thanh ghi đích (0-10), trừ khi có quy định khác
    (các hướng dẫn trong tương lai có thể sử dụng lại trường này cho các mục đích khác)

ZZ0000ZZ
  Độ lệch số nguyên có dấu được sử dụng với số học con trỏ, ngoại trừ khi
  được chỉ định khác (một số lệnh số học sử dụng lại trường này
  cho các mục đích khác)

ZZ0000ZZ
  giá trị tức thời của số nguyên đã ký

Lưu ý rằng nội dung của các trường nhiều byte ('offset' và 'imm') là
được lưu trữ bằng cách sử dụng thứ tự byte lớn trên các máy chủ lớn và
Thứ tự byte little-endian trên các máy chủ endian nhỏ.

Ví dụ::

opcode bù đắp imm lắp ráp
         src_reg dst_reg
  07 0 1 00 00 44 33 22 11 r1 += 0x11223344 // nhỏ
         dst_reg src_reg
  07 1 0 00 00 11 22 33 44 r1 += 0x11223344 // lớn

Lưu ý rằng hầu hết các hướng dẫn không sử dụng tất cả các trường.
Các trường không sử dụng SHALL sẽ bị xóa về 0.

Mã hóa lệnh rộng
--------------------------

Một số lệnh được xác định để sử dụng mã hóa lệnh rộng,
sử dụng hai giá trị tức thời 32 bit.  64 bit sau
định dạng lệnh cơ bản chứa một lệnh giả
với 'opcode', 'dst_reg', 'src_reg' và 'offset' đều được đặt thành 0.

Điều này được mô tả trong hình sau::

+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  ZZ0000ZZ đăng ký ZZ0001ZZ
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  ZZ0002ZZ
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  ZZ0003ZZ
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
  ZZ0004ZZ
  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

ZZ0000ZZ
  thao tác cần thực hiện, được mã hóa như đã giải thích ở trên

ZZ0000ZZ
  Số thanh ghi nguồn và đích (trừ khi có quy định khác)
  được chỉ định), được mã hóa như đã giải thích ở trên

ZZ0000ZZ
  offset số nguyên có dấu được sử dụng với số học con trỏ, trừ khi
  quy định khác

ZZ0000ZZ
  giá trị tức thời của số nguyên đã ký

ZZ0000ZZ
  không sử dụng, đặt về 0

ZZ0000ZZ
  giá trị ngay lập tức của số nguyên có dấu thứ hai

Lớp hướng dẫn
-------------------

Ba bit có trọng số thấp nhất của trường 'opcode' lưu trữ lớp lệnh:

.. table:: Instruction class

  =====  =====  ===============================  ===================================
  class  value  description                      reference
  =====  =====  ===============================  ===================================
  LD     0x0    non-standard load operations     `Load and store instructions`_
  LDX    0x1    load into register operations    `Load and store instructions`_
  ST     0x2    store from immediate operations  `Load and store instructions`_
  STX    0x3    store from register operations   `Load and store instructions`_
  ALU    0x4    32-bit arithmetic operations     `Arithmetic and jump instructions`_
  JMP    0x5    64-bit jump operations           `Arithmetic and jump instructions`_
  JMP32  0x6    32-bit jump operations           `Arithmetic and jump instructions`_
  ALU64  0x7    64-bit arithmetic operations     `Arithmetic and jump instructions`_
  =====  =====  ===============================  ===================================

Hướng dẫn tính toán và nhảy
================================

Đối với các lệnh số học và nhảy (ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ và
ZZ0003ZZ), trường 'opcode' 8 bit được chia thành ba phần::

+-+-+-+-+-+-+-+-+
  |  code |s|class|
  +-+-+-+-+-+-+-+-+

ZZ0000ZZ
  mã hoạt động, có ý nghĩa thay đổi tùy theo lớp lệnh

ZZ0000ZZ
  vị trí toán hạng nguồn, trừ khi có quy định khác, là một trong:

  .. table:: Source operand location

    ======  =====  ==============================================
    source  value  description
    ======  =====  ==============================================
    K       0      use 32-bit 'imm' value as source operand
    X       1      use 'src_reg' register value as source operand
    ======  =====  ==============================================

ZZ0001ZZ
  lớp hướng dẫn (xem ZZ0000ZZ)

Hướng dẫn số học
-----------------------

ZZ0000ZZ sử dụng toán hạng rộng 32 bit trong khi ZZ0001ZZ sử dụng toán hạng rộng 64 bit cho
mặt khác hoạt động giống hệt nhau. Lệnh ZZ0002ZZ thuộc về
nhóm tuân thủ base64 trừ khi có ghi chú khác.
Trường 'code' mã hóa hoạt động như bên dưới, trong đó 'src' đề cập đến
toán hạng nguồn và 'dst' đề cập đến giá trị của đích
đăng ký.

.. table:: Arithmetic instructions

  =====  =====  =======  ===================================================================================
  name   code   offset   description
  =====  =====  =======  ===================================================================================
  ADD    0x0    0        dst += src
  SUB    0x1    0        dst -= src
  MUL    0x2    0        dst \*= src
  DIV    0x3    0        dst = (src != 0) ? (dst / src) : 0
  SDIV   0x3    1        dst = (src == 0) ? 0 : ((src == -1 && dst == LLONG_MIN) ? LLONG_MIN : (dst s/ src))
  OR     0x4    0        dst \|= src
  AND    0x5    0        dst &= src
  LSH    0x6    0        dst <<= (src & mask)
  RSH    0x7    0        dst >>= (src & mask)
  NEG    0x8    0        dst = -dst
  MOD    0x9    0        dst = (src != 0) ? (dst % src) : dst
  SMOD   0x9    1        dst = (src == 0) ? dst : ((src == -1 && dst == LLONG_MIN) ? 0: (dst s% src))
  XOR    0xa    0        dst ^= src
  MOV    0xb    0        dst = src
  MOVSX  0xb    8/16/32  dst = (s8,s16,s32)src
  ARSH   0xc    0        :term:`sign extending<Sign Extend>` dst >>= (src & mask)
  END    0xd    0        byte swap operations (see `Byte swap instructions`_ below)
  =====  =====  =======  ===================================================================================

Cho phép tràn và tràn trong các phép tính số học, nghĩa là
giá trị 64 bit hoặc 32 bit sẽ bao bọc. Nếu việc thực hiện chương trình BPF sẽ
dẫn đến chia cho 0, thay vào đó, thanh ghi đích được đặt thành 0.
Mặt khác, đối với ZZ0000ZZ, nếu việc thực thi sẽ dẫn đến ZZ0001ZZ
chia cho -1, thay vào đó, thanh ghi đích được đặt thành ZZ0002ZZ. cho
ZZ0003ZZ, nếu việc thực thi sẽ dẫn đến ZZ0004ZZ chia cho -1, thì
thay vào đó, thanh ghi đích được đặt thành ZZ0005ZZ.

Nếu việc thực thi dẫn đến modulo bằng 0, đối với ZZ0000ZZ, giá trị của
thanh ghi đích không thay đổi trong khi đối với ZZ0001ZZ thì giá trị trên
32 bit của thanh ghi đích bằng 0. Mặt khác, đối với ZZ0002ZZ,
nếu việc thực thi sẽ tiếp tục ở ZZ0003ZZ modulo -1, thì đích
thay vào đó, thanh ghi được đặt thành 0. Đối với ZZ0004ZZ, nếu việc thực thi sẽ dẫn đến
ZZ0005ZZ modulo -1, thay vào đó, thanh ghi đích được đặt thành 0.

ZZ0000ZZ, trong đó 'mã' = ZZ0001ZZ, 'nguồn' = ZZ0002ZZ và 'class' = ZZ0003ZZ, có nghĩa là::

dst = (u32) ((u32) dst + (u32) src)

trong đó '(u32)' chỉ ra rằng 32 bit trên bằng 0.

ZZ0000ZZ có nghĩa là::

dst = dst + src

ZZ0000ZZ có nghĩa là::

dst = (u32) dst ^ (u32) imm

ZZ0000ZZ có nghĩa là::

dst = dst ^ im

Lưu ý rằng hầu hết các lệnh số học đều có 'offset' được đặt thành 0. Chỉ có ba lệnh
(ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ) có 'độ lệch' khác 0.

Các phép chia, nhân và modulo cho ZZ0000ZZ là một phần
của nhóm tuân thủ "divmul32" và phép chia, phép nhân và
các hoạt động modulo cho ZZ0001ZZ là một phần của tuân thủ "divmul64"
nhóm.
Các phép toán chia và modulo hỗ trợ cả hai loại có dấu và không dấu.

Đối với các hoạt động không dấu (ZZ0001ZZ và ZZ0002ZZ), đối với ZZ0003ZZ,
'imm' được hiểu là giá trị không dấu 32 bit. Đối với ZZ0004ZZ,
'imm' đầu tiên là ZZ0000ZZ từ 32 đến 64 bit, sau đó
được hiểu là giá trị không dấu 64 bit.

Đối với các hoạt động đã ký (ZZ0001ZZ và ZZ0002ZZ), đối với ZZ0003ZZ,
'imm' được hiểu là giá trị có chữ ký 32 bit. Đối với ZZ0004ZZ, 'tôi'
đầu tiên là ZZ0000ZZ từ 32 đến 64 bit, sau đó
được hiểu là giá trị có chữ ký 64 bit.

Lưu ý rằng có nhiều định nghĩa khác nhau về phép toán modulo đã ký
khi số bị chia hoặc số chia là số âm, khi việc thực hiện thường
khác nhau tùy theo ngôn ngữ như Python, Ruby, v.v. khác với C, Go, Java,
v.v. Thông số kỹ thuật này yêu cầu modulo MUST đã ký sử dụng phép chia cắt ngắn
(trong đó -13 % 3 == -1) như được triển khai trong C, Go, v.v.::

a % n = a - n * trunc(a / n)

Lệnh ZZ0002ZZ thực hiện thao tác di chuyển với phần mở rộng dấu.
ZZ0003ZZ ZZ0000ZZ Toán hạng 8 bit và 16 bit thành
Toán hạng 32 bit và đưa về 0 cho 32 bit trên còn lại.
ZZ0004ZZ ZZ0001ZZ 8 bit, 16 bit và 32 bit
toán hạng thành toán hạng 64-bit.  Không giống như các hướng dẫn số học khác,
ZZ0005ZZ chỉ được xác định cho toán hạng nguồn đăng ký (ZZ0006ZZ).

ZZ0000ZZ có nghĩa là::

dst = (s64)tôimm

ZZ0000ZZ có nghĩa là::

dst = (u32)src

ZZ0000ZZ với 'offset' 8 có nghĩa là::

dst = (u32)(s32)(s8)src


Lệnh ZZ0000ZZ chỉ được xác định khi bit nguồn rõ ràng
(ZZ0001ZZ).

Các thao tác thay đổi sử dụng mặt nạ 0x3F (63) cho các thao tác 64 bit và 0x1F (31)
cho các hoạt động 32-bit.

Hướng dẫn hoán đổi byte
----------------------

Lệnh hoán đổi byte sử dụng các lớp lệnh ZZ0000ZZ và ZZ0001ZZ
và trường 'mã' 4 bit của ZZ0002ZZ.

Lệnh hoán đổi byte hoạt động trên thanh ghi đích
chỉ và không sử dụng thanh ghi nguồn riêng biệt hoặc giá trị tức thời.

Đối với ZZ0000ZZ, trường toán hạng nguồn 1 bit trong opcode được sử dụng để
chọn thứ tự byte mà thao tác chuyển đổi từ hoặc sang. cho
ZZ0001ZZ, trường toán hạng nguồn 1 bit trong opcode được bảo lưu
và MUST được đặt thành 0.

.. table:: Byte swap instructions

  =====  ========  =====  =================================================
  class  source    value  description
  =====  ========  =====  =================================================
  ALU    LE        0      convert between host byte order and little endian
  ALU    BE        1      convert between host byte order and big endian
  ALU64  Reserved  0      do byte swap unconditionally
  =====  ========  =====  =================================================

Trường 'imm' mã hóa độ rộng của hoạt động hoán đổi.  Các chiều rộng sau
được hỗ trợ: 16, 32 và 64. Các phép toán có chiều rộng 64 thuộc về base64
nhóm tuân thủ và các hoạt động hoán đổi khác thuộc về base32
nhóm tuân thủ.

Ví dụ:

ZZ0000ZZ với 'imm' = 16/32/64 có nghĩa là::

dst = le16(dst)
  dst = le32(dst)
  dst = le64(dst)

ZZ0000ZZ với 'imm' = 16/32/64 có nghĩa là::

dst = be16(dst)
  dst = be32(dst)
  dst = be64(dst)

ZZ0000ZZ với 'imm' = 16/32/64 có nghĩa là::

dst = bswap16(dst)
  dst = bswap32(dst)
  dst = bswap64(dst)

Hướng dẫn nhảy
-----------------

ZZ0000ZZ sử dụng toán hạng rộng 32 bit và biểu thị base32
nhóm tuân thủ, trong khi ZZ0001ZZ sử dụng toán hạng rộng 64-bit cho
nếu không thì các hoạt động giống hệt nhau và cho biết sự tuân thủ base64
nhóm trừ khi có quy định khác.
Trường 'code' mã hóa hoạt động như sau:

.. table:: Jump instructions

  ========  =====  =======  =================================  ===================================================
  code      value  src_reg  description                        notes
  ========  =====  =======  =================================  ===================================================
  JA        0x0    0x0      PC += offset                       {JA, K, JMP} only
  JA        0x0    0x0      PC += imm                          {JA, K, JMP32} only
  JEQ       0x1    any      PC += offset if dst == src
  JGT       0x2    any      PC += offset if dst > src          unsigned
  JGE       0x3    any      PC += offset if dst >= src         unsigned
  JSET      0x4    any      PC += offset if dst & src
  JNE       0x5    any      PC += offset if dst != src
  JSGT      0x6    any      PC += offset if dst > src          signed
  JSGE      0x7    any      PC += offset if dst >= src         signed
  CALL      0x8    0x0      call helper function by static ID  {CALL, K, JMP} only, see `Helper functions`_
  CALL      0x8    0x1      call PC += imm                     {CALL, K, JMP} only, see `Program-local functions`_
  CALL      0x8    0x2      call helper function by BTF ID     {CALL, K, JMP} only, see `Helper functions`_
  EXIT      0x9    0x0      return                             {CALL, K, JMP} only
  JLT       0xa    any      PC += offset if dst < src          unsigned
  JLE       0xb    any      PC += offset if dst <= src         unsigned
  JSLT      0xc    any      PC += offset if dst < src          signed
  JSLE      0xd    any      PC += offset if dst <= src         signed
  ========  =====  =======  =================================  ===================================================

trong đó 'PC' biểu thị bộ đếm chương trình và độ lệch tăng dần theo
được tính theo đơn vị của lệnh 64-bit tương ứng với lệnh sau
lệnh nhảy.  Do đó 'PC += 1' bỏ qua việc thực hiện lệnh tiếp theo
hướng dẫn nếu đó là hướng dẫn cơ bản hoặc dẫn đến hành vi không xác định
nếu lệnh tiếp theo là lệnh rộng 128 bit.

Ví dụ:

ZZ0000ZZ có nghĩa là::

if (s32)dst s>= (s32)src goto +offset

trong đó 's>=' biểu thị so sánh có dấu '>='.

ZZ0000ZZ có nghĩa là::

if dst <= (u64)(s64)imm goto +offset

ZZ0000ZZ có nghĩa là::

gotol +imm

trong đó 'imm' có nghĩa là phần bù nhánh xuất phát từ trường 'imm'.

Lưu ý rằng có hai loại lệnh ZZ0000ZZ. các
Lớp ZZ0001ZZ cho phép độ lệch bước nhảy 16 bit được chỉ định bởi 'độ lệch'
trường, trong khi lớp ZZ0002ZZ cho phép bù bước nhảy 32 bit
được chỉ định bởi trường 'imm'. Có thể có bước nhảy có điều kiện > 16-bit
được chuyển đổi thành bước nhảy có điều kiện < 16 bit cộng với bước nhảy vô điều kiện 32 bit
nhảy.

Tất cả các lệnh ZZ0000ZZ và ZZ0001ZZ đều thuộc về
nhóm tuân thủ base32.

Chức năng trợ giúp
~~~~~~~~~~~~~~~~

Các hàm trợ giúp là một khái niệm trong đó các chương trình BPF có thể gọi vào một
tập hợp các lệnh gọi hàm được nền tảng cơ bản hiển thị.

Trước đây, mỗi chức năng trợ giúp được xác định bằng một ID tĩnh
được mã hóa trong trường 'imm'.  Tài liệu bổ sung về các chức năng trợ giúp
nằm ngoài phạm vi của tài liệu này và việc tiêu chuẩn hóa được dành cho
công việc trong tương lai, nhưng việc sử dụng được triển khai rộng rãi và có thể cung cấp thêm thông tin
được tìm thấy trong tài liệu dành riêng cho nền tảng (ví dụ: tài liệu về nhân Linux).

Các nền tảng hỗ trợ Định dạng loại BPF (BTF) hỗ trợ nhận dạng
chức năng trợ giúp bằng ID BTF được mã hóa trong trường 'imm', trong đó ID BTF
xác định tên và loại trợ giúp.  Tài liệu bổ sung về BTF
nằm ngoài phạm vi của tài liệu này và việc tiêu chuẩn hóa được dành cho
công việc trong tương lai, nhưng việc sử dụng được triển khai rộng rãi và có thể cung cấp thêm thông tin
được tìm thấy trong tài liệu dành riêng cho nền tảng (ví dụ: tài liệu về nhân Linux).

Các hàm cục bộ của chương trình
~~~~~~~~~~~~~~~~~~~~~~~
Các hàm cục bộ của chương trình là các hàm được hiển thị bởi cùng một chương trình BPF như
người gọi và được tham chiếu bằng offset từ lệnh sau lệnh gọi
hướng dẫn, tương tự như ZZ0000ZZ.  Phần bù được mã hóa trong trường 'imm' của
lệnh gọi. ZZ0001ZZ trong hàm chương trình cục bộ sẽ
quay lại với người gọi.

Hướng dẫn tải và lưu trữ
===========================

Để biết hướng dẫn tải và lưu trữ (ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ và ZZ0003ZZ),
Trường 'opcode' 8 bit được chia như sau::

+-+-+-+-+-+-+-+-+
  |mode |sz ZZ0001ZZ
  +-+-+-+-+-+-+-+-+

ZZ0000ZZ
  Công cụ sửa đổi chế độ là một trong:

  .. table:: Mode modifier

    =============  =====  ====================================  =============
    mode modifier  value  description                           reference
    =============  =====  ====================================  =============
    IMM            0      64-bit immediate instructions         `64-bit immediate instructions`_
    ABS            1      legacy BPF packet access (absolute)   `Legacy BPF Packet access instructions`_
    IND            2      legacy BPF packet access (indirect)   `Legacy BPF Packet access instructions`_
    MEM            3      regular load and store operations     `Regular load and store operations`_
    MEMSX          4      sign-extension load operations        `Sign-extension load operations`_
    ATOMIC         6      atomic operations                     `Atomic operations`_
    =============  =====  ====================================  =============

ZZ0000ZZ
  Công cụ sửa đổi kích thước là một trong:

  .. table:: Size modifier

    ====  =====  =====================
    size  value  description
    ====  =====  =====================
    W     0      word        (4 bytes)
    H     1      half word   (2 bytes)
    B     2      byte
    DW    3      double word (8 bytes)
    ====  =====  =====================

Hướng dẫn sử dụng ZZ0000ZZ thuộc nhóm tuân thủ base64.

ZZ0001ZZ
  Lớp hướng dẫn (xem ZZ0000ZZ)

Hoạt động tải và lưu trữ thường xuyên
---------------------------------

Bộ sửa đổi chế độ ZZ0000ZZ được sử dụng để mã hóa tải và lưu trữ thông thường
lệnh truyền dữ liệu giữa thanh ghi và bộ nhớ.

ZZ0000ZZ có nghĩa là::

ZZ0000ZZ) (dst + offset) = src

ZZ0000ZZ có nghĩa là::

ZZ0000ZZ) (dst + offset) = imm

ZZ0000ZZ có nghĩa là::

dst = ZZ0000ZZ) (src + offset)

Trong đó '<size>' là một trong: ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ hoặc ZZ0003ZZ và
'kích thước không dấu' là một trong: u8, u16, u32 hoặc u64.

Hoạt động tải tiện ích mở rộng đăng nhập
------------------------------

Bộ sửa đổi chế độ ZZ0001ZZ được sử dụng để mã hóa tải ZZ0000ZZ
lệnh truyền dữ liệu giữa thanh ghi và bộ nhớ.

ZZ0000ZZ có nghĩa là::

dst = ZZ0000ZZ) (src + offset)

Trong đó '<size>' là một trong: ZZ0000ZZ, ZZ0001ZZ hoặc ZZ0002ZZ và
'kích thước đã ký' là một trong: s8, s16 hoặc s32.

Hoạt động nguyên tử
-----------------

Các thao tác nguyên tử là các thao tác thực hiện trên bộ nhớ và không thể
bị gián đoạn hoặc bị hỏng bởi quyền truy cập khác vào cùng vùng bộ nhớ
bởi các chương trình BPF khác hoặc các phương tiện nằm ngoài thông số kỹ thuật này.

Tất cả các hoạt động nguyên tử được BPF hỗ trợ đều được mã hóa dưới dạng các hoạt động lưu trữ
sử dụng công cụ sửa đổi chế độ ZZ0000ZZ như sau:

* ZZ0000ZZ cho các hoạt động 32-bit,
  một phần của nhóm tuân thủ "atomic32".
* ZZ0001ZZ cho hoạt động 64-bit,
  một phần của nhóm tuân thủ "atomic64".
* Không hỗ trợ các hoạt động nguyên tử rộng 8 bit và 16 bit.

Trường 'imm' được sử dụng để mã hóa hoạt động nguyên tử thực tế.
Hoạt động nguyên tử đơn giản sử dụng một tập hợp con các giá trị được xác định để mã hóa
các phép toán số học trong trường 'imm' để mã hóa phép toán nguyên tử:

.. table:: Simple atomic operations

  ========  =====  ===========
  imm       value  description
  ========  =====  ===========
  ADD       0x00   atomic add
  OR        0x40   atomic or
  AND       0x50   atomic and
  XOR       0xa0   atomic xor
  ========  =====  ===========


ZZ0000ZZ với 'imm' = ADD có nghĩa là::

ZZ0000ZZ)(dst + offset) += src

ZZ0000ZZ với 'imm' = ADD có nghĩa là::

ZZ0000ZZ)(dst + offset) += src

Ngoài các phép toán nguyên tử đơn giản, còn có một phép sửa đổi và
hai hoạt động nguyên tử phức tạp:

.. table:: Complex atomic operations

  ===========  ================  ===========================
  imm          value             description
  ===========  ================  ===========================
  FETCH        0x01              modifier: return old value
  XCHG         0xe0 | FETCH      atomic exchange
  CMPXCHG      0xf0 | FETCH      atomic compare and exchange
  ===========  ================  ===========================

Công cụ sửa đổi ZZ0000ZZ là tùy chọn cho các hoạt động nguyên tử đơn giản và
luôn được thiết lập cho các hoạt động nguyên tử phức tạp.  Nếu cờ ZZ0001ZZ
được thiết lập thì thao tác cũng sẽ ghi đè lên ZZ0002ZZ với giá trị
đã có trong bộ nhớ trước khi nó được sửa đổi.

Hoạt động ZZ0000ZZ trao đổi nguyên tử ZZ0001ZZ với giá trị
được giải quyết bởi ZZ0002ZZ.

Hoạt động ZZ0000ZZ so sánh nguyên tử giá trị được xử lý bởi
ZZ0001ZZ với ZZ0002ZZ. Nếu chúng khớp nhau, giá trị được xử lý bởi
ZZ0003ZZ được thay thế bằng ZZ0004ZZ. Trong cả hai trường hợp,
giá trị ở ZZ0005ZZ trước khi hoạt động được mở rộng bằng 0
và tải trở lại ZZ0006ZZ.

Hướng dẫn tức thời 64-bit
-----------------------------

Các lệnh với công cụ sửa đổi 'chế độ' ZZ0000ZZ sử dụng lệnh rộng
mã hóa được xác định trong ZZ0001ZZ và sử dụng trường 'src_reg' của
hướng dẫn cơ bản để giữ một kiểu con opcode.

Bảng sau định nghĩa một tập lệnh ZZ0000ZZ
với các kiểu con opcode trong trường 'src_reg', sử dụng các thuật ngữ mới như "map"
được xác định thêm dưới đây:

.. table:: 64-bit immediate instructions

  =======  =========================================  ===========  ==============
  src_reg  pseudocode                                 imm type     dst type
  =======  =========================================  ===========  ==============
  0x0      dst = (next_imm << 32) | imm               integer      integer
  0x1      dst = map_by_fd(imm)                       map fd       map
  0x2      dst = map_val(map_by_fd(imm)) + next_imm   map fd       data address
  0x3      dst = var_addr(imm)                        variable id  data address
  0x4      dst = code_addr(imm)                       integer      code address
  0x5      dst = map_by_idx(imm)                      map index    map
  0x6      dst = map_val(map_by_idx(imm)) + next_imm  map index    data address
  =======  =========================================  ===========  ==============

Ở đâu

* map_by_fd(imm) có nghĩa là chuyển đổi bộ mô tả tệp 32 bit thành địa chỉ của bản đồ (xem ZZ0000ZZ)
* map_by_idx(imm) có nghĩa là chuyển đổi chỉ mục 32 bit thành địa chỉ của bản đồ
* map_val(map) lấy địa chỉ của giá trị đầu tiên trong bản đồ nhất định
* var_addr(imm) lấy địa chỉ của biến nền tảng (xem ZZ0001ZZ) với id đã cho
* code_addr(imm) lấy địa chỉ của lệnh tại một độ lệch tương đối được chỉ định về số lượng lệnh (64-bit)
* 'loại imm' có thể được sử dụng bởi bộ phân tách để hiển thị
* 'loại dst' có thể được sử dụng cho mục đích xác minh và biên dịch JIT

Bản đồ
~~~~

Bản đồ là vùng bộ nhớ dùng chung mà các chương trình BPF có thể truy cập trên một số nền tảng.
Một bản đồ có thể có nhiều ngữ nghĩa khác nhau như được định nghĩa trong một tài liệu riêng biệt và có thể hoặc
có thể không có một vùng bộ nhớ liền kề, nhưng 'map_val(map)' thì
hiện chỉ được xác định cho các bản đồ có một vùng bộ nhớ liền kề.

Mỗi bản đồ có thể có một bộ mô tả tệp (fd) nếu được nền tảng hỗ trợ, trong đó
'map_by_fd(imm)' có nghĩa là lấy bản đồ với bộ mô tả tệp được chỉ định. Mỗi
Chương trình BPF cũng có thể được xác định để sử dụng một bộ bản đồ liên kết với
chương trình tại thời điểm tải và 'map_by_idx(imm)' có nghĩa là lấy bản đồ với thông số đã cho
chỉ mục trong tập hợp được liên kết với chương trình BPF chứa lệnh.

Biến nền tảng
~~~~~~~~~~~~~~~~~~

Biến nền tảng là các vùng bộ nhớ, được xác định bởi id số nguyên, được hiển thị bởi
thời gian chạy và có thể truy cập được bởi các chương trình BPF trên một số nền tảng.  các
Hoạt động 'var_addr(imm)' có nghĩa là lấy địa chỉ của vùng bộ nhớ
được xác định bởi id đã cho.

Hướng dẫn truy cập gói BPF kế thừa
-------------------------------------

BPF trước đây đã giới thiệu các hướng dẫn đặc biệt để truy cập vào dữ liệu gói
được chuyển từ BPF cổ điển. Các hướng dẫn này sử dụng một hướng dẫn
lớp ZZ0000ZZ, bộ sửa đổi kích thước của ZZ0001ZZ, ZZ0002ZZ hoặc ZZ0003ZZ và
công cụ sửa đổi chế độ của ZZ0004ZZ hoặc ZZ0005ZZ.  Các trường 'dst_reg' và 'offset' là
được đặt thành 0 và 'src_reg' được đặt thành 0 cho ZZ0006ZZ.  Tuy nhiên, những điều này
hướng dẫn không được dùng nữa và SHOULD không còn được sử dụng nữa.  Tất cả các gói kế thừa
hướng dẫn truy cập thuộc nhóm tuân thủ "gói".
