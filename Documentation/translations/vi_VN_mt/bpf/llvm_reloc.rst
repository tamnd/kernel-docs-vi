.. SPDX-License-Identifier: (LGPL-2.1 OR BSD-2-Clause)

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/llvm_reloc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================
Di dời BPF LLVM
====================

Tài liệu này mô tả các loại di dời phụ trợ LLVM BPF.

Hồ sơ di dời
=================

Phần phụ trợ LLVM BPF ghi lại mỗi lần di chuyển với 16 byte sau
Cấu trúc ELF::

cấu trúc typedef
  {
    Elf64_Addr r_offset;  // Offset so với đầu phần.
    Elf64_Xword r_info;    // Kiểu di dời và chỉ mục ký hiệu.
  } Yêu tinh64_Rel;

Ví dụ: đối với đoạn mã sau::

int g1 __attribute__((section("sec")));
  int g2 __attribute__((section("sec")));
  tĩnh dễ bay hơi int l1 __attribute__((section("sec")));
  tĩnh dễ bay hơi int l2 __attribute__((section("sec")));
  kiểm tra int() {
    trả về g1 + g2 + l1 + l2;
  }

Được biên soạn bằng ZZ0000ZZ, sau đây là
mã với ZZ0001ZZ::

0: 18 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 r1 = 0 ll
                0000000000000000: R_BPF_64_64 g1
       2: 61 11 00 00 00 00 00 00 r1 = ZZ0000ZZ)(r1 + 0)
       3: 18 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 r2 = 0 ll
                0000000000000018: R_BPF_64_64 g2
       5: 61 20 00 00 00 00 00 00 r0 = ZZ0001ZZ)(r2 + 0)
       6: 0f 10 00 00 00 00 00 00 r0 += r1
       7: 18 01 00 00 08 00 00 00 00 00 00 00 00 00 00 00 r1 = 8 ll
                0000000000000038: R_BPF_64_64 giây
       9: 61 11 00 00 00 00 00 00 r1 = ZZ0002ZZ)(r1 + 0)
      10: 0f 10 00 00 00 00 00 00 r0 += r1
      11: 18 01 00 00 0c 00 00 00 00 00 00 00 00 00 00 00 r1 = 12 ll
                0000000000000058: R_BPF_64_64 giây
      13: 61 11 00 00 00 00 00 00 r1 = ZZ0003ZZ)(r1 + 0)
      14: 0f 10 00 00 00 00 00 00 r0 += r1
      15: 95 00 00 00 00 00 00 00 thoát

Có bốn vị trí ở trên cho bốn lệnh ZZ0000ZZ.
ZZ0001ZZ sau đây hiển thị các giá trị nhị phân của bốn
tái định cư::

Phần di dời '.rel.text' ở offset 0x190 chứa 4 mục:
      Offset Loại thông tin Ký hiệu Giá trị Tên ký hiệu
  0000000000000000 0000000600000001 R_BPF_64_64 0000000000000000 g1
  0000000000000018 0000000700000001 R_BPF_64_64 0000000000000004 g2
  00000000000000038 0000000400000001 R_BPF_64_64 0000000000000000 giây
  0000000000000058 0000000400000001 R_BPF_64_64 0000000000000000 giây

Mỗi lần di chuyển được biểu thị bằng ZZ0000ZZ (8 byte) và ZZ0001ZZ (8 byte).
Ví dụ, lần di chuyển đầu tiên tương ứng với lệnh đầu tiên
(Offset 0x0) và ZZ0002ZZ tương ứng cho biết loại di dời
của ZZ0003ZZ (loại 1) và mục trong bảng ký hiệu (mục 6).
Sau đây là bảng ký hiệu với ZZ0004ZZ::

Bảng ký hiệu “.symtab” chứa 8 mục:
     Num: Giá trị Kích thước Loại Liên kết Tên Ndx
       0: 0000000000000000 0 NOTYPE LOCAL DEFAULT UND
       1: 0000000000000000 0 FILE LOCAL DEFAULT ABS thử nghiệm.c
       2: 0000000000000008 4 OBJECT LOCAL DEFAULT 4 l1
       3: 000000000000000c 4 OBJECT LOCAL DEFAULT 4 l2
       4: 0000000000000000 0 SECTION LOCAL DEFAULT 4 giây
       5: 0000000000000000 128 FUNC GLOBAL DEFAULT 2 thử nghiệm
       6: 0000000000000000 4 OBJECT GLOBAL DEFAULT 4 g1
       7: 0000000000000004 4 OBJECT GLOBAL DEFAULT 4 g2

Mục thứ 6 là biến toàn cục ZZ0000ZZ có giá trị 0.

Tương tự, lần di chuyển thứ hai là ở ZZ0000ZZ offset ZZ0001ZZ, lệnh 3,
có loại ZZ0002ZZ và đề cập đến mục 7 trong bảng ký hiệu.
Lần di chuyển thứ hai giải quyết thành biến toàn cục ZZ0003ZZ có ký hiệu
giá trị 4. Giá trị ký hiệu biểu thị phần bù từ đầu ZZ0004ZZ
phần nơi lưu trữ giá trị ban đầu của biến toàn cục ZZ0005ZZ.

Lần tái định vị thứ ba và thứ tư đề cập đến các biến tĩnh ZZ0000ZZ
và ZZ0001ZZ. Từ phần ZZ0002ZZ ở trên thì chưa rõ
những biểu tượng nào họ thực sự đề cập đến khi cả hai đều đề cập đến
bảng ký hiệu mục 4, ký hiệu ZZ0003ZZ, có loại ZZ0004ZZ
và đại diện cho một phần. Vì vậy, đối với một biến hoặc hàm tĩnh,
phần bù được ghi vào insn gốc
bộ đệm, được gọi là ZZ0005ZZ (phần bổ sung). Nhìn vào
ở trên ZZ0006ZZ và ZZ0007ZZ, chúng có phần bù ZZ0008ZZ và ZZ0009ZZ.
Từ bảng ký hiệu, chúng ta có thể thấy rằng chúng tương ứng với các mục ZZ0010ZZ
và ZZ0011ZZ cho ZZ0012ZZ và ZZ0013ZZ.

Nói chung, ZZ0000ZZ là 0 đối với các biến và hàm toàn cục,
và là phần bù hoặc một số kết quả tính toán dựa trên
phần bù cho các biến/hàm tĩnh. Phần không bù đắp
trường hợp đề cập đến các cuộc gọi chức năng. Xem bên dưới để biết thêm chi tiết.

Các loại tái định cư khác nhau
==========================

Sáu loại di dời được hỗ trợ. Sau đây là tổng quan và
ZZ0000ZZ đại diện cho giá trị của ký hiệu trong bảng ký hiệu::

Enum ELF Loại Reloc Mô tả Tính toán bù đắp BitSize
  0 R_BPF_NONE Không có
  1 R_BPF_64_64 ld_imm64 insn 32 r_offset + 4 S + A
  2 R_BPF_64_ABS64 dữ liệu bình thường 64 r_offset S + A
  3 R_BPF_64_ABS32 dữ liệu bình thường 32 r_offset S + A
  4 dữ liệu R_BPF_64_NODYLD32 .BTF[.ext] 32 r_offset S + A
  10 R_BPF_64_32 gọi nội bộ 32 r_offset + 4 (S + A) / 8 - 1

Ví dụ: loại tái định vị ZZ0000ZZ được sử dụng cho lệnh ZZ0001ZZ.
Dữ liệu thực tế được di dời (0 hoặc phần bù)
được lưu trữ tại ZZ0002ZZ và chức năng đọc/ghi
kích thước bit dữ liệu là 32 (4 byte). Việc di dời có thể được giải quyết bằng
giá trị ký hiệu cộng với phần bổ sung ngầm định. Lưu ý rằng ZZ0003ZZ là 32
có nghĩa là phần bù phần phải nhỏ hơn hoặc bằng ZZ0004ZZ và điều này
được thực thi bởi chương trình phụ trợ LLVM BPF.

Trong trường hợp khác, loại tái định vị ZZ0000ZZ được sử dụng cho dữ liệu 64-bit thông thường.
Dữ liệu thực tế sắp được di dời được lưu trữ tại ZZ0001ZZ và dữ liệu đọc/ghi
kích thước bit là 64 (8 byte). Việc di dời có thể được giải quyết bằng
giá trị ký hiệu cộng với phần bổ sung ngầm định.

Cả hai loại ZZ0000ZZ và ZZ0001ZZ đều dành cho dữ liệu 32 bit.
Nhưng ZZ0002ZZ đề cập cụ thể đến việc di dời trong ZZ0003ZZ và
Phần ZZ0004ZZ. Đối với các trường hợp như bcc trong đó llvm ZZ0005ZZ
có liên quan, các loại di dời ZZ0006ZZ sẽ không được giải quyết
đến hàm/địa chỉ biến thực tế. Mặt khác, ZZ0007ZZ và ZZ0008ZZ
trở nên không thể sử dụng được bởi bcc và kernel.

Loại ZZ0000ZZ được sử dụng cho lệnh gọi. Phần mục tiêu cuộc gọi
phần bù được lưu trữ tại ZZ0001ZZ (32bit) và được tính như
ZZ0002ZZ.

Ví dụ
========

Loại ZZ0000ZZ và ZZ0001ZZ được sử dụng để giải quyết ZZ0002ZZ
và hướng dẫn ZZ0003ZZ. Ví dụ::

__attribute__((noinline)) __attribute__((section("sec1")))
  int gfunc(int a, int b) {
    trả về a * b;
  }
  tĩnh __attribute__((noinline)) __attribute__((section("sec1")))
  int lfunc(int a, int b) {
    trả lại a + b;
  }
  int toàn cầu __attribute__((section("sec2")));
  kiểm tra int(int a, int b) {
    return gfunc(a, b) + lfunc(a, b) + toàn cầu;
  }

Biên dịch với ZZ0000ZZ, chúng ta sẽ có
đoạn mã sau với ZZ0001ZZ`::

Tháo rời phần .text:

0000000000000000 <kiểm tra>:
         0: bf 26 00 00 00 00 00 00 r6 = r2
         1: bf 17 00 00 00 00 00 00 r7 = r1
         2: 85 10 00 00 ff ff ff ff gọi -1
                  0000000000000010: R_BPF_64_32 gfunc
         3: bạn 08 00 00 00 00 00 00 r8 = r0
         4: bf 71 00 00 00 00 00 00 r1 = r7
         5: bf 62 00 00 00 00 00 00 r2 = r6
         6: 85 10 00 00 02 00 00 00 gọi 2
                  0000000000000030: R_BPF_64_32 giây1
         7: 0f 80 00 00 00 00 00 00 r0 += r8
         8: 18 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 r1 = 0 ll
                  0000000000000040: R_BPF_64_64 toàn cầu
        10: 61 11 00 00 00 00 00 00 r1 = ZZ0000ZZ)(r1 + 0)
        11: 0f 10 00 00 00 00 00 00 r0 += r1
        12: 95 00 00 00 00 00 00 00 thoát

Tháo dỡ phần sec1:

0000000000000000 <gfunc>:
         0: bf 20 00 00 00 00 00 00 r0 = r2
         1: 2f 10 00 00 00 00 00 00 r0 *= r1
         2: 95 00 00 00 00 00 00 00 thoát

0000000000000018 <lfunc>:
         3: bf 20 00 00 00 00 00 00 r0 = r2
         4: 0f 10 00 00 00 00 00 00 r0 += r1
         5: 95 00 00 00 00 00 00 00 thoát

Lần di chuyển đầu tiên tương ứng với ZZ0000ZZ trong đó ZZ0001ZZ có giá trị 0,
vì vậy độ lệch lệnh ZZ0002ZZ là ZZ0003ZZ.
Lần di chuyển thứ hai tương ứng với ZZ0004ZZ trong đó ZZ0005ZZ có một phần
offset ZZ0006ZZ, do đó offset lệnh ZZ0007ZZ là ZZ0008ZZ.
Lần di chuyển thứ ba tương ứng với ld_imm64 của ZZ0009ZZ, có phần
bù đắp ZZ0010ZZ.

Sau đây là ví dụ cho thấy cách tạo R_BPF_64_ABS64::

int toàn cầu() { trả về 0; }
  cấu trúc t { void *g; } gbl = { toàn cầu };

Được biên dịch bằng ZZ0000ZZ, chúng ta sẽ thấy một
di chuyển bên dưới trong phần ZZ0001ZZ bằng lệnh
ZZ0002ZZ::

Phần di dời '.rel.data' ở offset 0x458 chứa 1 mục:
      Offset Loại thông tin Ký hiệu Giá trị Tên ký hiệu
  0000000000000000 0000000700000002 R_BPF_64_ABS64 0000000000000000 toàn cầu

Việc di dời cho biết 8 byte đầu tiên của phần ZZ0000ZZ phải là
chứa đầy địa chỉ của biến ZZ0001ZZ.

Với đầu ra ZZ0000ZZ, chúng ta có thể thấy rằng các phần lùn có rất nhiều
Chuyển vị trí ZZ0001ZZ và ZZ0002ZZ::

Phần di dời '.rel.debug_info' ở offset 0x468 chứa 13 mục:
      Offset Loại thông tin Ký hiệu Giá trị Tên ký hiệu
  00000000000000006 0000000300000003 R_BPF_64_ABS32 0000000000000000 .debug_abbrev
  0000000000000000c 0000000400000003 R_BPF_64_ABS32 0000000000000000 .debug_str
  00000000000000012 0000000400000003 R_BPF_64_ABS32 0000000000000000 .debug_str
  00000000000000016 0000000600000003 R_BPF_64_ABS32 0000000000000000 .debug_line
  0000000000000001a 0000000400000003 R_BPF_64_ABS32 0000000000000000 .debug_str
  0000000000000001e 0000000200000002 R_BPF_64_ABS64 0000000000000000 .text
  0000000000000002b 0000000400000003 R_BPF_64_ABS32 0000000000000000 .debug_str
  00000000000000037 0000000800000002 R_BPF_64_ABS64 0000000000000000 gbl
  00000000000000040 0000000400000003 R_BPF_64_ABS32 0000000000000000 .debug_str
  ......

Các phần .BTF/.BTF.ext có các vị trí chuyển R_BPF_64_NODYLD32::

Phần di dời '.rel.BTF' ở offset 0x538 chứa 1 mục:
      Offset Loại thông tin Ký hiệu Giá trị Tên ký hiệu
  00000000000000084 0000000800000004 R_BPF_64_NODYLD32 0000000000000000 gbl

Phần di dời '.rel.BTF.ext' ở offset 0x548 chứa 2 mục:
      Offset Loại thông tin Ký hiệu Giá trị Tên ký hiệu
  0000000000000002c 0000000200000004 R_BPF_64_NODYLD32 0000000000000000 .text
  00000000000000040 0000000200000004 R_BPF_64_NODYLD32 0000000000000000 .text

.. _btf-co-re-relocations:

===================
Di dời CO-RE
=================

Từ quan điểm của tệp đối tượng, cơ chế CO-RE được triển khai dưới dạng một tập hợp
của hồ sơ di dời cụ thể CO-RE. Những hồ sơ di dời này không
liên quan đến việc di chuyển ELF và được mã hóa trong phần .BTF.ext.
Xem ZZ0000ZZ để biết thêm
thông tin về cấu trúc .BTF.ext.

Việc định vị lại CO-RE được áp dụng cho các lệnh BPF để cập nhật ngay lập tức
hoặc bù đắp các trường của lệnh tại thời điểm tải bằng thông tin
có liên quan đến hạt nhân đích.

Trường để vá được chọn dựa trên lớp hướng dẫn:

* Đối với trường BPF_ALU, BPF_ALU64, BPF_LD ZZ0000ZZ đã được vá;
* Đối với trường BPF_LDX, BPF_STX, BPF_ST ZZ0001ZZ đã được vá;
* Hướng dẫn BPF_JMP, BPF_JMP32 ZZ0002ZZ được vá.

Các loại tái định cư
================

Có một số loại di dời CO-RE có thể được chia thành
ba nhóm:

* Dựa trên trường - hướng dẫn vá lỗi với thông tin liên quan đến trường, ví dụ:
  thay đổi trường offset của lệnh BPF_LDX để phản ánh offset
  của một trường cấu trúc cụ thể trong kernel đích.

* Dựa trên loại - hướng dẫn vá lỗi với thông tin liên quan đến loại, ví dụ:
  thay đổi trường ngay lập tức của lệnh di chuyển BPF_ALU thành 0 hoặc 1 thành
  phản ánh nếu loại cụ thể có trong kernel đích.

* Dựa trên Enum - hướng dẫn vá lỗi với thông tin liên quan đến enum, ví dụ:
  thay đổi trường ngay lập tức của lệnh BPF_LD_IMM64 để phản ánh
  giá trị của một chữ enum cụ thể trong kernel đích.

Danh sách đầy đủ các loại di dời được thể hiện bằng enum sau:

.. code-block:: c

 enum bpf_core_relo_kind {
	BPF_CORE_FIELD_BYTE_OFFSET = 0,  /* field byte offset */
	BPF_CORE_FIELD_BYTE_SIZE   = 1,  /* field size in bytes */
	BPF_CORE_FIELD_EXISTS      = 2,  /* field existence in target kernel */
	BPF_CORE_FIELD_SIGNED      = 3,  /* field signedness (0 - unsigned, 1 - signed) */
	BPF_CORE_FIELD_LSHIFT_U64  = 4,  /* bitfield-specific left bitshift */
	BPF_CORE_FIELD_RSHIFT_U64  = 5,  /* bitfield-specific right bitshift */
	BPF_CORE_TYPE_ID_LOCAL     = 6,  /* type ID in local BPF object */
	BPF_CORE_TYPE_ID_TARGET    = 7,  /* type ID in target kernel */
	BPF_CORE_TYPE_EXISTS       = 8,  /* type existence in target kernel */
	BPF_CORE_TYPE_SIZE         = 9,  /* type size in bytes */
	BPF_CORE_ENUMVAL_EXISTS    = 10, /* enum value existence in target kernel */
	BPF_CORE_ENUMVAL_VALUE     = 11, /* enum value integer value */
	BPF_CORE_TYPE_MATCHES      = 12, /* type match in target kernel */
 };

Ghi chú:

* ZZ0000ZZ và ZZ0001ZZ là
  được cho là được sử dụng để đọc các giá trị bitfield bằng cách sử dụng như sau
  thuật toán:

  .. code-block:: c

     // To read bitfield ``f`` from ``struct s``
     is_signed = relo(s->f, BPF_CORE_FIELD_SIGNED)
     off = relo(s->f, BPF_CORE_FIELD_BYTE_OFFSET)
     sz  = relo(s->f, BPF_CORE_FIELD_BYTE_SIZE)
     l   = relo(s->f, BPF_CORE_FIELD_LSHIFT_U64)
     r   = relo(s->f, BPF_CORE_FIELD_RSHIFT_U64)
     // define ``v`` as signed or unsigned integer of size ``sz``
     v = *({s|u}<sz> *)((void *)s + off)
     v <<= l
     v >>= r

* Mối quan hệ khớp với các truy vấn ZZ0000ZZ, được định nghĩa là
  sau:

* đối với số nguyên: loại khớp nếu kích thước và chữ ký khớp nhau;
  * đối với mảng và con trỏ: kiểu mục tiêu được so khớp đệ quy;
  * đối với cấu trúc và công đoàn:

* các thành viên địa phương cần tồn tại trong mục tiêu có cùng tên;

* đối với mỗi thành viên, chúng tôi kiểm tra đệ quy sự trùng khớp trừ khi nó đã ở sau một
      con trỏ, trong trường hợp đó chúng tôi chỉ kiểm tra tên phù hợp và loại tương thích;

* đối với enum:

* các biến thể cục bộ phải khớp với mục tiêu theo tên tượng trưng (nhưng không phải
      giá trị số);

* kích thước phải khớp (nhưng enum có thể khớp với enum64 và ngược lại);

* đối với con trỏ hàm:

* số lượng và vị trí của các đối số trong kiểu cục bộ phải khớp với mục tiêu;
    * đối với mỗi đối số và giá trị trả về, chúng tôi kiểm tra sự trùng khớp một cách đệ quy.

Hồ sơ di dời CO-RE
=======================

Bản ghi tái định vị được mã hóa theo cấu trúc sau:

.. code-block:: c

 struct bpf_core_relo {
	__u32 insn_off;
	__u32 type_id;
	__u32 access_str_off;
	enum bpf_core_relo_kind kind;
 };

* ZZ0000ZZ - độ lệch lệnh (tính bằng byte) trong một phần mã
  liên quan đến việc di dời này;

* ZZ0000ZZ - ID loại BTF của thực thể "gốc" (chứa) của một
  loại hoặc trường có thể định vị lại;

* ZZ0000ZZ - offset vào phần chuỗi .BTF tương ứng.
  Giải thích chuỗi phụ thuộc vào loại di chuyển cụ thể:

* đối với việc tái định vị dựa trên trường, chuỗi mã hóa trường được truy cập bằng cách sử dụng
    một chuỗi các chỉ số trường và mảng, được phân tách bằng dấu hai chấm (:). Đó là
    về mặt khái niệm rất gần với hướng dẫn ZZ0000ZZ của LLVM
    đối số để xác định phần bù cho một trường. Ví dụ, hãy xem xét
    mã C sau:

    .. code-block:: c

       struct sample {
           int a;
           int b;
           struct { int c[10]; };
       } __attribute__((preserve_access_index));
       struct sample *s;

* Quyền truy cập vào ZZ0000ZZ sẽ được mã hóa thành ZZ0001ZZ:

* ZZ0000ZZ: phần tử đầu tiên của ZZ0001ZZ (như thể ZZ0002ZZ là một mảng);
      * ZZ0003ZZ: chỉ mục của trường ZZ0004ZZ trong ZZ0005ZZ.

* Quyền truy cập vào ZZ0000ZZ cũng sẽ được mã hóa thành ZZ0001ZZ.
    * Quyền truy cập vào ZZ0002ZZ sẽ được mã hóa thành ZZ0003ZZ:

* ZZ0000ZZ: phần tử đầu tiên của ZZ0001ZZ;
      * ZZ0002ZZ: chỉ mục của trường ZZ0003ZZ trong ZZ0004ZZ.

* Quyền truy cập vào ZZ0000ZZ sẽ được mã hóa thành ZZ0001ZZ:

* ZZ0000ZZ: phần tử thứ hai của ZZ0001ZZ;
      * ZZ0002ZZ: chỉ mục trường cấu trúc ẩn danh trong ZZ0003ZZ;
      * ZZ0004ZZ: chỉ mục của trường ZZ0005ZZ ở dạng ẩn danh;
      * ZZ0006ZZ: truy cập vào phần tử mảng #5.

* đối với việc di chuyển dựa trên loại, chuỗi dự kiến ​​sẽ chỉ là "0";

* đối với việc tái định vị dựa trên giá trị enum, chuỗi chứa chỉ mục của enum
     giá trị trong loại enum của nó;

* ZZ0000ZZ - một trong ZZ0001ZZ.

.. _GEP: https://llvm.org/docs/LangRef.html#getelementptr-instruction

.. _btf_co_re_relocation_examples:

Ví dụ về di dời CO-RE
=========================

Đối với mã C sau:

.. code-block:: c

 struct foo {
   int a;
   int b;
   unsigned c:15;
 } __attribute__((preserve_access_index));

 enum bar { U, V };

Với các định nghĩa BTF sau:

.. code-block::

 ...
 [2] STRUCT 'foo' size=8 vlen=2
        'a' type_id=3 bits_offset=0
        'b' type_id=3 bits_offset=32
        'c' type_id=4 bits_offset=64 bitfield_size=15
 [3] INT 'int' size=4 bits_offset=0 nr_bits=32 encoding=SIGNED
 [4] INT 'unsigned int' size=4 bits_offset=0 nr_bits=32 encoding=(none)
 ...
 [16] ENUM 'bar' encoding=UNSIGNED size=4 vlen=2
        'U' val=0
        'V' val=1

Việc tái định vị offset trường được tạo tự động khi
ZZ0000ZZ được sử dụng, ví dụ:

.. code-block:: c

  void alpha(struct foo *s, volatile unsigned long *g) {
    *g = s->a;
    s->a = 1;
  }

  00 <alpha>:
    0:  r3 = *(s32 *)(r1 + 0x0)
           00:  CO-RE <byte_off> [2] struct foo::a (0:0)
    1:  *(u64 *)(r2 + 0x0) = r3
    2:  *(u32 *)(r1 + 0x0) = 0x1
           10:  CO-RE <byte_off> [2] struct foo::a (0:0)
    3:  exit


Tất cả các loại di dời có thể được yêu cầu thông qua các chức năng tích hợp sẵn.
Ví dụ. di dời theo thực địa:

.. code-block:: c

  void bravo(struct foo *s, volatile unsigned long *g) {
    *g = __builtin_preserve_field_info(s->b, 0 /* field byte offset */);
    *g = __builtin_preserve_field_info(s->b, 1 /* field byte size */);
    *g = __builtin_preserve_field_info(s->b, 2 /* field existence */);
    *g = __builtin_preserve_field_info(s->b, 3 /* field signedness */);
    *g = __builtin_preserve_field_info(s->c, 4 /* bitfield left shift */);
    *g = __builtin_preserve_field_info(s->c, 5 /* bitfield right shift */);
  }

  20 <bravo>:
     4:     r1 = 0x4
            20:  CO-RE <byte_off> [2] struct foo::b (0:1)
     5:     *(u64 *)(r2 + 0x0) = r1
     6:     r1 = 0x4
            30:  CO-RE <byte_sz> [2] struct foo::b (0:1)
     7:     *(u64 *)(r2 + 0x0) = r1
     8:     r1 = 0x1
            40:  CO-RE <field_exists> [2] struct foo::b (0:1)
     9:     *(u64 *)(r2 + 0x0) = r1
    10:     r1 = 0x1
            50:  CO-RE <signed> [2] struct foo::b (0:1)
    11:     *(u64 *)(r2 + 0x0) = r1
    12:     r1 = 0x31
            60:  CO-RE <lshift_u64> [2] struct foo::c (0:2)
    13:     *(u64 *)(r2 + 0x0) = r1
    14:     r1 = 0x31
            70:  CO-RE <rshift_u64> [2] struct foo::c (0:2)
    15:     *(u64 *)(r2 + 0x0) = r1
    16:     exit


Di dời dựa trên loại:

.. code-block:: c

  void charlie(struct foo *s, volatile unsigned long *g) {
    *g = __builtin_preserve_type_info(*s, 0 /* type existence */);
    *g = __builtin_preserve_type_info(*s, 1 /* type size */);
    *g = __builtin_preserve_type_info(*s, 2 /* type matches */);
    *g = __builtin_btf_type_id(*s, 0 /* type id in this object file */);
    *g = __builtin_btf_type_id(*s, 1 /* type id in target kernel */);
  }

  88 <charlie>:
    17:     r1 = 0x1
            88:  CO-RE <type_exists> [2] struct foo
    18:     *(u64 *)(r2 + 0x0) = r1
    19:     r1 = 0xc
            98:  CO-RE <type_size> [2] struct foo
    20:     *(u64 *)(r2 + 0x0) = r1
    21:     r1 = 0x1
            a8:  CO-RE <type_matches> [2] struct foo
    22:     *(u64 *)(r2 + 0x0) = r1
    23:     r1 = 0x2 ll
            b8:  CO-RE <local_type_id> [2] struct foo
    25:     *(u64 *)(r2 + 0x0) = r1
    26:     r1 = 0x2 ll
            d0:  CO-RE <target_type_id> [2] struct foo
    28:     *(u64 *)(r2 + 0x0) = r1
    29:     exit

Di dời dựa trên Enum:

.. code-block:: c

  void delta(struct foo *s, volatile unsigned long *g) {
    *g = __builtin_preserve_enum_value(*(enum bar *)U, 0 /* enum literal existence */);
    *g = __builtin_preserve_enum_value(*(enum bar *)V, 1 /* enum literal value */);
  }

  f0 <delta>:
    30:     r1 = 0x1 ll
            f0:  CO-RE <enumval_exists> [16] enum bar::U = 0
    32:     *(u64 *)(r2 + 0x0) = r1
    33:     r1 = 0x1 ll
            108:  CO-RE <enumval_value> [16] enum bar::V = 1
    35:     *(u64 *)(r2 + 0x0) = r1
    36:     exit