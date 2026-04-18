.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/btf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Định dạng loại BPF (BTF)
=====================

1. Giới thiệu
===============

BTF (Định dạng loại BPF) là định dạng siêu dữ liệu mã hóa thông tin gỡ lỗi
liên quan đến chương trình/bản đồ BPF. Tên BTF ban đầu được sử dụng để mô tả dữ liệu
các loại. BTF sau đó đã được mở rộng để bao gồm thông tin chức năng cho các
chương trình con và thông tin dòng để biết thông tin nguồn/dòng.

Thông tin gỡ lỗi được sử dụng để in bản đồ đẹp, chữ ký hàm, v.v.
chữ ký hàm cho phép ký hiệu hạt nhân chương trình/chức năng bpf tốt hơn. dòng
thông tin giúp tạo mã byte được dịch có chú thích nguồn, mã jited và
nhật ký xác minh.

Thông số kỹ thuật BTF bao gồm hai phần,
  * Hạt nhân BTF API
  * Định dạng tệp BTF ELF

Kernel API là hợp đồng giữa không gian người dùng và kernel. Hạt nhân
xác minh thông tin BTF trước khi sử dụng. Định dạng tệp ELF là không gian người dùng
hợp đồng giữa tệp ELF và trình tải libbpf.

Các phần loại và chuỗi là một phần của hạt nhân BTF API, mô tả
thông tin gỡ lỗi (chủ yếu là các loại liên quan) được tham chiếu bởi chương trình bpf. Hai cái này
các phần được thảo luận chi tiết trong ZZ0000ZZ.

.. _BTF_Type_String:

2. Mã hóa loại và chuỗi BTF
===============================

Tệp ZZ0000ZZ cung cấp định nghĩa cấp cao về cách
loại/chuỗi được mã hóa.

Phần đầu của blob dữ liệu phải là::

cấu trúc btf_header {
        __u16 phép thuật;
        __u8 phiên bản;
        __u8 cờ;
        __u32 hdr_len;

/* Tất cả các offset đều tính bằng byte so với phần cuối của tiêu đề này */
        __u32 gõ_off;       /* offset của phần loại */
        __u32 type_len;       /*độ dài của phần loại */
        __u32 str_off;        /* offset của phần chuỗi */
        __u32 str_len;        /*độ dài của phần chuỗi */
    };

Điều kỳ diệu là ZZ0000ZZ, có mã hóa khác nhau cho lớn và nhỏ
hệ thống endian và có thể được sử dụng để kiểm tra xem BTF có được tạo cho lớn hay không
mục tiêu endian nhỏ. ZZ0001ZZ được thiết kế để có thể mở rộng với
ZZ0002ZZ bằng ZZ0003ZZ khi một blob dữ liệu được
được tạo ra.

2.1 Mã hóa chuỗi
-------------------

Chuỗi đầu tiên trong phần chuỗi phải là chuỗi rỗng. Phần còn lại của
bảng chuỗi là sự kết hợp của các chuỗi kết thúc null khác.

2.2 Mã hóa loại
-----------------

Id loại ZZ0000ZZ được dành riêng cho loại ZZ0001ZZ. Phần loại được phân tích cú pháp
tuần tự và loại id được gán cho từng loại được nhận dạng bắt đầu từ id
ZZ0002ZZ. Hiện tại, các loại sau được hỗ trợ::

#define BTF_KIND_INT 1 /* Số nguyên */
    #define BTF_KIND_PTR 2 /* Con trỏ */
    #define BTF_KIND_ARRAY 3 /* Mảng */
    #define BTF_KIND_STRUCT 4 /* Cấu trúc */
    #define BTF_KIND_UNION 5 /* Liên minh */
    #define BTF_KIND_ENUM 6 /* Đếm các giá trị lên tới 32-bit */
    #define BTF_KIND_FWD 7 /* Chuyển tiếp */
    #define BTF_KIND_TYPEDEF 8 /* Typedef */
    #define BTF_KIND_VOLATILE 9 /* Dễ bay hơi */
    #define BTF_KIND_CONST 10 /* Hằng số */
    #define BTF_KIND_RESTRICT 11 /* Hạn chế */
    #define BTF_KIND_FUNC 12 /* Chức năng */
    #define BTF_KIND_FUNC_PROTO 13 /* Nguyên mẫu hàm */
    #define BTF_KIND_VAR 14 /* Biến */
    #define BTF_KIND_DATASEC 15 /* Phần */
    #define BTF_KIND_FLOAT 16 /* Dấu phẩy động */
    #define BTF_KIND_DECL_TAG 17 /* Thẻ từ chối */
    #define BTF_KIND_TYPE_TAG 18 /* Loại thẻ */
    #define BTF_KIND_ENUM64 19 /* Đếm các giá trị lên tới 64-bit */

Lưu ý rằng phần loại mã hóa thông tin gỡ lỗi, không chỉ các loại thuần túy.
ZZ0000ZZ không phải là một loại và nó đại diện cho một chương trình con được xác định.

Mỗi loại chứa dữ liệu chung sau::

cấu trúc btf_type {
        __u32 tên_off;
        /* Sắp xếp các bit "thông tin"
         * bit 0-15: vlen (ví dụ: các thành viên của cấu trúc # of)
         * bit 16-23: không sử dụng
         * bit 24-28: loại (ví dụ: int, ptr, mảng...vv)
         * bit 29-30: không sử dụng
         * bit 31: kind_flag, hiện đang được sử dụng bởi
         * struct, union, enum, fwd, enum64,
         * decl_tag và type_tag
         */
        __u32 thông tin;
        /* "kích thước" được sử dụng bởi INT, ENUM, STRUCT, UNION và ENUM64.
         * "size" cho biết kích thước của loại nó đang mô tả.
         *
         * "loại" được sử dụng bởi PTR, TYPEDEF, VOLATILE, CONST, RESTRICT,
         * FUNC, FUNC_PROTO, DECL_TAG và TYPE_TAG.
         * "loại" là type_id đề cập đến loại khác.
         */
        công đoàn {
                __u32 kích thước;
                __u32 loại;
        };
    };

Đối với một số loại nhất định, dữ liệu chung được theo sau bởi dữ liệu cụ thể theo loại. các
ZZ0000ZZ trong ZZ0001ZZ chỉ định phần bù trong bảng chuỗi.
Các phần sau đây sẽ giải mã chi tiết từng loại.

2.2.1 BTF_KIND_INT
~~~~~~~~~~~~~~~~~~

Yêu cầu mã hóa ZZ0000ZZ:
 * ZZ0001ZZ: bất kỳ phần bù hợp lệ nào
 *ZZ0002ZZ: 0
 *ZZ0003ZZ: BTF_KIND_INT
 *ZZ0004ZZ: 0
 * ZZ0005ZZ: kích thước của kiểu int tính bằng byte.

ZZ0000ZZ được theo sau bởi ZZ0001ZZ với cách sắp xếp các bit sau::

#define BTF_INT_ENCODING(VAL) (((VAL) & 0x0f000000) >> 24)
  #define BTF_INT_OFFSET(VAL) (((VAL) & 0x00ff0000) >> 16)
  #define BTF_INT_BITS(VAL) ((VAL) & 0x000000ff)

ZZ0000ZZ có các thuộc tính sau::

#define BTF_INT_SIGNED (1 << 0)
  #define BTF_INT_CHAR (1 << 1)
  #define BTF_INT_BOOL (1 << 2)

ZZ0000ZZ cung cấp thêm thông tin: chữ ký, ký tự hoặc
bool, dành cho kiểu int. Mã hóa char và bool chủ yếu hữu ích cho
in đẹp. Có thể chỉ định nhiều nhất một mã hóa cho kiểu int.

ZZ0000ZZ chỉ định số bit thực tế được giữ bởi int này
loại. Ví dụ: trường bit 4 bit mã hóa ZZ0001ZZ bằng 4.
ZZ0002ZZ phải bằng hoặc lớn hơn ZZ0003ZZ
cho loại này. Giá trị tối đa của ZZ0004ZZ là 128.

ZZ0000ZZ chỉ định độ lệch bit bắt đầu để tính giá trị
cho int này. Ví dụ: thành viên cấu trúc bitfield có:

* bit thành viên btf bù 100 từ đầu cấu trúc,
 * thành viên btf trỏ đến kiểu int,
 * kiểu int có ZZ0000ZZ và ZZ0001ZZ

Sau đó, trong bố cục bộ nhớ cấu trúc, thành viên này sẽ chiếm các bit ZZ0000ZZ bắt đầu từ
từ bit ZZ0001ZZ.

Ngoài ra, thành viên cấu trúc bitfield có thể là người sau đây để truy cập
các bit tương tự như trên:

* bit thành viên btf bù 102,
 * thành viên btf trỏ đến kiểu int,
 * kiểu int có ZZ0000ZZ và ZZ0001ZZ

Mục đích ban đầu của ZZ0000ZZ là cung cấp tính linh hoạt của
mã hóa trường bit. Hiện tại, cả llvm và pahole đều tạo
ZZ0001ZZ cho tất cả các loại int.

2.2.2 BTF_KIND_PTR
~~~~~~~~~~~~~~~~~~

Yêu cầu mã hóa ZZ0000ZZ:
  *ZZ0001ZZ: 0
  *ZZ0002ZZ: 0
  *ZZ0003ZZ: BTF_KIND_PTR
  *ZZ0004ZZ: 0
  * ZZ0005ZZ: kiểu pointee của con trỏ

Không có dữ liệu loại bổ sung theo ZZ0000ZZ.

2.2.3 BTF_KIND_ARRAY
~~~~~~~~~~~~~~~~~~~~

Yêu cầu mã hóa ZZ0000ZZ:
  *ZZ0001ZZ: 0
  *ZZ0002ZZ: 0
  *ZZ0003ZZ: BTF_KIND_ARRAY
  *ZZ0004ZZ: 0
  * ZZ0005ZZ: 0, không sử dụng

ZZ0000ZZ được theo sau bởi một ZZ0001ZZ::

cấu trúc btf_array {
        __u32 loại;
        __u32 chỉ mục_type;
        __u32 cây nelem;
    };

Mã hóa ZZ0000ZZ:
  * ZZ0001ZZ: loại phần tử
  * ZZ0002ZZ: loại chỉ mục
  * ZZ0003ZZ: số phần tử của mảng này (ZZ0004ZZ cũng được phép).

ZZ0000ZZ có thể là bất kỳ loại int thông thường nào (ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ,
ZZ0004ZZ, ZZ0005ZZ). Thiết kế ban đầu bao gồm
ZZ0006ZZ theo sau DWARF, có ZZ0007ZZ cho kiểu mảng của nó.
Hiện tại trong BTF, ngoài việc xác minh loại, ZZ0008ZZ không được sử dụng.

ZZ0000ZZ cho phép xâu chuỗi thông qua loại phần tử để biểu diễn
mảng đa chiều. Ví dụ: đối với ZZ0001ZZ, loại sau
thông tin minh họa chuỗi:

* [1]: int
  * [2]: mảng, ZZ0000ZZ, ZZ0001ZZ
  * [3]: mảng, ZZ0002ZZ, ZZ0003ZZ

Hiện tại, cả pahole và llvm đều thu gọn mảng đa chiều thành
mảng một chiều, ví dụ: đối với ZZ0000ZZ, ZZ0001ZZ là
bằng ZZ0002ZZ. Điều này là do trường hợp sử dụng ban đầu là bản đồ in đẹp
trong đó toàn bộ mảng được loại bỏ nên mảng một chiều là đủ. Như
khám phá thêm cách sử dụng BTF, pahole và llvm có thể được thay đổi để tạo ra
biểu diễn chuỗi cho mảng nhiều chiều.

2.2.4 BTF_KIND_STRUCT
~~~~~~~~~~~~~~~~~~~~~
2.2.5 BTF_KIND_UNION
~~~~~~~~~~~~~~~~~~~~

Yêu cầu mã hóa ZZ0000ZZ:
  * ZZ0001ZZ: 0 hoặc bù vào mã định danh C hợp lệ
  * ZZ0002ZZ: 0 hoặc 1
  * ZZ0003ZZ: BTF_KIND_STRUCT hoặc BTF_KIND_UNION
  * ZZ0004ZZ: số lượng thành viên struct/union
  * ZZ0005ZZ: kích thước của struct/union tính bằng byte

Theo sau ZZ0000ZZ là ZZ0001ZZ số ZZ0002ZZ.::

cấu trúc btf_member {
        __u32 tên_off;
        __u32 loại;
        __u32 bù đắp;
    };

Mã hóa ZZ0000ZZ:
  * ZZ0001ZZ: bù vào mã định danh C hợp lệ
  * ZZ0002ZZ: loại thành viên
  * ZZ0003ZZ: <xem bên dưới>

Nếu thông tin loại ZZ0000ZZ không được đặt, phần bù chỉ chứa phần bù bit
của thành viên. Lưu ý rằng loại cơ sở của bitfield chỉ có thể là int hoặc enum
loại. Nếu kích thước trường bit là 32 thì loại cơ sở có thể là int hoặc enum
loại. Nếu kích thước trường bit không phải là 32 thì loại cơ sở phải là int và loại int
ZZ0001ZZ mã hóa kích thước trường bit.

Nếu ZZ0000ZZ được đặt, ZZ0001ZZ chứa cả hai thành viên
kích thước trường bit và độ lệch bit. Kích thước trường bit và độ lệch bit được tính toán
như dưới đây.::

#define BTF_MEMBER_BITFIELD_SIZE(giá trị) ((giá trị) >> 24)
  #define BTF_MEMBER_BIT_OFFSET(giá trị) ((giá trị) & 0xffffff)

Trong trường hợp này, nếu kiểu cơ sở là kiểu int thì nó phải là kiểu int thông thường:

* ZZ0000ZZ phải bằng 0.
  * ZZ0001ZZ phải bằng ZZ0002ZZ.

Cam kết 9d5f9f701b18 đã giới thiệu ZZ0000ZZ và giải thích lý do tại sao cả hai chế độ
tồn tại.

2.2.6 BTF_KIND_ENUM
~~~~~~~~~~~~~~~~~~~

Yêu cầu mã hóa ZZ0000ZZ:
  * ZZ0001ZZ: 0 hoặc bù vào mã định danh C hợp lệ
  * ZZ0002ZZ: 0 cho không dấu, 1 cho đã ký
  *ZZ0003ZZ: BTF_KIND_ENUM
  * ZZ0004ZZ: số lượng giá trị enum
  * ZZ0005ZZ: 1/2/4/8

Theo sau ZZ0000ZZ là ZZ0001ZZ số ZZ0002ZZ.::

cấu trúc btf_enum {
        __u32 tên_off;
        __s32 giá trị;
    };

Mã hóa ZZ0000ZZ:
  * ZZ0001ZZ: bù vào mã định danh C hợp lệ
  * ZZ0002ZZ: bất kỳ giá trị nào

Nếu giá trị enum ban đầu được ký và kích thước nhỏ hơn 4,
giá trị đó sẽ được mở rộng thành 4 byte. Nếu kích thước là 8,
giá trị sẽ được cắt ngắn thành 4 byte.

2.2.7 BTF_KIND_FWD
~~~~~~~~~~~~~~~~~~

Yêu cầu mã hóa ZZ0000ZZ:
  * ZZ0001ZZ: bù vào mã định danh C hợp lệ
  * ZZ0002ZZ: 0 cho cấu trúc, 1 cho kết hợp
  *ZZ0003ZZ: BTF_KIND_FWD
  *ZZ0004ZZ: 0
  *ZZ0005ZZ: 0

Không có dữ liệu loại bổ sung theo ZZ0000ZZ.

2.2.8 BTF_KIND_TYPEDEF
~~~~~~~~~~~~~~~~~~~~~~

Yêu cầu mã hóa ZZ0000ZZ:
  * ZZ0001ZZ: bù vào mã định danh C hợp lệ
  *ZZ0002ZZ: 0
  *ZZ0003ZZ: BTF_KIND_TYPEDEF
  *ZZ0004ZZ: 0
  * ZZ0005ZZ: loại có thể gọi bằng tên tại ZZ0006ZZ

Không có dữ liệu loại bổ sung theo ZZ0000ZZ.

2.2.9 BTF_KIND_VOLATILE
~~~~~~~~~~~~~~~~~~~~~~~

Yêu cầu mã hóa ZZ0000ZZ:
  *ZZ0001ZZ: 0
  *ZZ0002ZZ: 0
  *ZZ0003ZZ: BTF_KIND_VOLATILE
  *ZZ0004ZZ: 0
  * ZZ0005ZZ: loại có vòng loại ZZ0006ZZ

Không có dữ liệu loại bổ sung theo ZZ0000ZZ.

2.2.10 BTF_KIND_CONST
~~~~~~~~~~~~~~~~~~~~~

Yêu cầu mã hóa ZZ0000ZZ:
  *ZZ0001ZZ: 0
  *ZZ0002ZZ: 0
  *ZZ0003ZZ: BTF_KIND_CONST
  *ZZ0004ZZ: 0
  * ZZ0005ZZ: loại có vòng loại ZZ0006ZZ

Không có dữ liệu loại bổ sung theo ZZ0000ZZ.

2.2.11 BTF_KIND_RESTRICT
~~~~~~~~~~~~~~~~~~~~~~~~

Yêu cầu mã hóa ZZ0000ZZ:
  *ZZ0001ZZ: 0
  *ZZ0002ZZ: 0
  *ZZ0003ZZ: BTF_KIND_RESTRICT
  *ZZ0004ZZ: 0
  * ZZ0005ZZ: loại có vòng loại ZZ0006ZZ

Không có dữ liệu loại bổ sung theo ZZ0000ZZ.

2.2.12 BTF_KIND_FUNC
~~~~~~~~~~~~~~~~~~~~

Yêu cầu mã hóa ZZ0001ZZ:
  * ZZ0002ZZ: bù vào mã định danh C hợp lệ
  *ZZ0003ZZ: 0
  *ZZ0004ZZ: BTF_KIND_FUNC
  * ZZ0005ZZ: thông tin liên kết (BTF_FUNC_STATIC, BTF_FUNC_GLOBAL
                   hoặc BTF_FUNC_EXTERN - xem ZZ0000ZZ)
  * ZZ0006ZZ: loại BTF_KIND_FUNC_PROTO

Không có dữ liệu loại bổ sung theo ZZ0000ZZ.

BTF_KIND_FUNC định nghĩa không phải một loại mà là một chương trình con (hàm) có
chữ ký được xác định bởi ZZ0002ZZ. Do đó, chương trình con là một thể hiện của điều đó
loại. BTF_KIND_FUNC có thể lần lượt được tham chiếu bởi func_info trong
ZZ0000ZZ (ELF) hoặc trong các đối số của ZZ0001ZZ
(ABI).

Hiện tại, chỉ có các giá trị liên kết của BTF_FUNC_STATIC và BTF_FUNC_GLOBAL là
được hỗ trợ trong kernel.

2.2.13 BTF_KIND_FUNC_PROTO
~~~~~~~~~~~~~~~~~~~~~~~~~~

Yêu cầu mã hóa ZZ0000ZZ:
  *ZZ0001ZZ: 0
  *ZZ0002ZZ: 0
  *ZZ0003ZZ: BTF_KIND_FUNC_PROTO
  * ZZ0004ZZ: Thông số # of
  * ZZ0005ZZ: kiểu trả về

Theo sau ZZ0000ZZ là ZZ0001ZZ số ZZ0002ZZ.::

cấu trúc btf_param {
        __u32 tên_off;
        __u32 loại;
    };

Nếu loại BTF_KIND_FUNC_PROTO được gọi bằng loại BTF_KIND_FUNC thì
ZZ0000ZZ phải trỏ đến mã định danh C hợp lệ ngoại trừ
đối số cuối cùng có thể đại diện cho đối số biến. btf_param.type
đề cập đến loại tham số.

Nếu hàm có đối số thay đổi thì tham số cuối cùng được mã hóa bằng
ZZ0000ZZ và ZZ0001ZZ.

2.2.14 BTF_KIND_VAR
~~~~~~~~~~~~~~~~~~~

Yêu cầu mã hóa ZZ0000ZZ:
  * ZZ0001ZZ: bù vào mã định danh C hợp lệ
  *ZZ0002ZZ: 0
  *ZZ0003ZZ: BTF_KIND_VAR
  *ZZ0004ZZ: 0
  * ZZ0005ZZ: kiểu của biến

ZZ0000ZZ được theo sau bởi một ZZ0001ZZ duy nhất với
dữ liệu sau::

cấu trúc btf_var {
        __u32 liên kết;
    };

ZZ0001ZZ có thể lấy các giá trị: BTF_VAR_STATIC, BTF_VAR_GLOBAL_ALLOCATED hoặc BTF_VAR_GLOBAL_EXTERN -
xem ZZ0000ZZ.

Tại thời điểm này, không phải tất cả các loại biến toàn cục đều được LLVM hỗ trợ.
Những điều sau đây hiện có sẵn:

* biến tĩnh có hoặc không có thuộc tính phần
  * biến toàn cục với thuộc tính phần

Cái sau dùng để trích xuất id loại khóa/giá trị bản đồ trong tương lai từ một
định nghĩa bản đồ

2.2.15 BTF_KIND_DATASEC
~~~~~~~~~~~~~~~~~~~~~~~

Yêu cầu mã hóa ZZ0000ZZ:
  * ZZ0001ZZ: bù vào tên hợp lệ được liên kết với một biến hoặc
                  một trong .data/.bss/.rodata
  *ZZ0002ZZ: 0
  *ZZ0003ZZ: BTF_KIND_DATASEC
  * ZZ0004ZZ: Biến # of
  * ZZ0005ZZ: tổng kích thước phần tính bằng byte (0 tại thời điểm biên dịch, đã vá
              theo kích thước thực tế bằng các trình tải BPF như libbpf)

Theo sau ZZ0000ZZ là ZZ0001ZZ số ZZ0002ZZ.::

cấu trúc btf_var_secinfo {
        __u32 loại;
        __u32 bù đắp;
        __u32 kích thước;
    };

Mã hóa ZZ0000ZZ:
  * ZZ0001ZZ: kiểu biến BTF_KIND_VAR
  * ZZ0002ZZ: phần bù trong phần của biến
  * ZZ0003ZZ: kích thước của biến tính bằng byte

2.2.16 BTF_KIND_FLOAT
~~~~~~~~~~~~~~~~~~~~~

Yêu cầu mã hóa ZZ0000ZZ:
 * ZZ0001ZZ: bất kỳ phần bù hợp lệ nào
 *ZZ0002ZZ: 0
 *ZZ0003ZZ: BTF_KIND_FLOAT
 *ZZ0004ZZ: 0
 * ZZ0005ZZ: kích thước của kiểu float tính bằng byte: 2, 4, 8, 12 hoặc 16.

Không có dữ liệu loại bổ sung theo ZZ0000ZZ.

2.2.17 BTF_KIND_DECL_TAG
~~~~~~~~~~~~~~~~~~~~~~~~

Yêu cầu mã hóa ZZ0000ZZ:
 * ZZ0001ZZ: offset thành chuỗi không rỗng
 * ZZ0002ZZ: 0 hoặc 1
 *ZZ0003ZZ: BTF_KIND_DECL_TAG
 *ZZ0004ZZ: 0
 * ZZ0005ZZ: ZZ0006ZZ, ZZ0007ZZ, ZZ0008ZZ, ZZ0009ZZ hoặc ZZ0010ZZ

Theo sau ZZ0000ZZ là ZZ0001ZZ.::

cấu trúc btf_decl_tag {
        __u32 thành phần_idx;
    };

ZZ0000ZZ phải là ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ hoặc ZZ0005ZZ.
Đối với loại ZZ0006ZZ hoặc ZZ0007ZZ, ZZ0008ZZ phải là ZZ0009ZZ.
Đối với ba loại còn lại, nếu thuộc tính btf_decl_tag là
áp dụng cho chính ZZ0010ZZ, ZZ0011ZZ hoặc ZZ0012ZZ,
ZZ0013ZZ phải là ZZ0014ZZ. Nếu không,
thuộc tính được áp dụng cho thành viên ZZ0015ZZ/ZZ0016ZZ hoặc
một đối số ZZ0017ZZ và ZZ0018ZZ phải là một đối số
chỉ mục hợp lệ (bắt đầu từ 0) trỏ đến thành viên hoặc đối số.

Nếu ZZ0000ZZ bằng 0 thì đây là thẻ giải mã bình thường và
ZZ0001ZZ mã hóa chuỗi thuộc tính btf_decl_tag.

Nếu ZZ0000ZZ là 1 thì thẻ dec đại diện cho một giá trị tùy ý
__thuộc tính__. Trong trường hợp này, ZZ0001ZZ mã hóa một chuỗi
đại diện cho danh sách thuộc tính của bộ xác định thuộc tính. cho
ví dụ: đối với ZZ0002ZZ, nội dung của chuỗi
là ZZ0003ZZ.

2.2.18 BTF_KIND_TYPE_TAG
~~~~~~~~~~~~~~~~~~~~~~~~

Yêu cầu mã hóa ZZ0000ZZ:
 * ZZ0001ZZ: offset thành chuỗi không rỗng
 * ZZ0002ZZ: 0 hoặc 1
 *ZZ0003ZZ: BTF_KIND_TYPE_TAG
 *ZZ0004ZZ: 0
 * ZZ0005ZZ: loại có thuộc tính ZZ0006ZZ

Hiện tại, ZZ0000ZZ chỉ được phát ra cho các loại con trỏ.
Nó có chuỗi loại btf sau:
::

ptr -> [type_tag]*
      -> [const ZZ0000ZZ hạn chế | typedef]*
      -> loại_cơ sở

Về cơ bản, một kiểu con trỏ trỏ tới 0 hoặc nhiều hơn
type_tag, sau đó bằng 0 hoặc nhiều const/dễ bay hơi/hạn chế/typedef
và cuối cùng là loại cơ sở. Loại cơ sở là một trong
các kiểu int, ptr, array, struct, union, enum, func_proto và float.

Tương tự như thẻ giải mã, nếu ZZ0000ZZ bằng 0 thì đây là
thẻ loại bình thường và ZZ0001ZZ mã hóa thuộc tính btf_type_tag
chuỗi.

Nếu ZZ0000ZZ là 1 thì thẻ loại đại diện cho một tùy ý
__attribute__ và ZZ0001ZZ mã hóa một chuỗi đại diện cho
danh sách thuộc tính của bộ xác định thuộc tính.

2.2.19 BTF_KIND_ENUM64
~~~~~~~~~~~~~~~~~~~~~~

Yêu cầu mã hóa ZZ0000ZZ:
  * ZZ0001ZZ: 0 hoặc bù vào mã định danh C hợp lệ
  * ZZ0002ZZ: 0 cho không dấu, 1 cho đã ký
  *ZZ0003ZZ: BTF_KIND_ENUM64
  * ZZ0004ZZ: số lượng giá trị enum
  * ZZ0005ZZ: 1/2/4/8

Theo sau ZZ0000ZZ là ZZ0001ZZ số ZZ0002ZZ.::

cấu trúc btf_enum64 {
        __u32 tên_off;
        __u32 val_lo32;
        __u32 val_hi32;
    };

Mã hóa ZZ0000ZZ:
  * ZZ0001ZZ: bù vào mã định danh C hợp lệ
  * ZZ0002ZZ: giá trị 32 bit thấp hơn cho giá trị 64 bit
  * ZZ0003ZZ: giá trị 32-bit cao cho giá trị 64-bit

Nếu giá trị enum ban đầu được ký và kích thước nhỏ hơn 8,
giá trị đó sẽ được mở rộng thành 8 byte.

2.3 Giá trị không đổi
-------------------

.. _BTF_Function_Linkage_Constants:

2.3.1 Giá trị hằng số liên kết chức năng
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.. table:: Function Linkage Values and Meanings

  ===================  =====  ===========
  kind                 value  description
  ===================  =====  ===========
  ``BTF_FUNC_STATIC``  0x0    definition of subprogram not visible outside containing compilation unit
  ``BTF_FUNC_GLOBAL``  0x1    definition of subprogram visible outside containing compilation unit
  ``BTF_FUNC_EXTERN``  0x2    declaration of a subprogram whose definition is outside the containing compilation unit
  ===================  =====  ===========


.. _BTF_Var_Linkage_Constants:

2.3.2 Giá trị hằng số liên kết biến đổi
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.. table:: Variable Linkage Values and Meanings

  ============================  =====  ===========
  kind                          value  description
  ============================  =====  ===========
  ``BTF_VAR_STATIC``            0x0    definition of global variable not visible outside containing compilation unit
  ``BTF_VAR_GLOBAL_ALLOCATED``  0x1    definition of global variable visible outside containing compilation unit
  ``BTF_VAR_GLOBAL_EXTERN``     0x2    declaration of global variable whose definition is outside the containing compilation unit
  ============================  =====  ===========

3. Hạt nhân BTF API
=================

Lệnh bpf syscall sau đây liên quan đến BTF:
   * BPF_BTF_LOAD: tải một khối dữ liệu BTF vào kernel
   * BPF_MAP_CREATE: tạo bản đồ với thông tin loại giá trị và khóa btf.
   * BPF_PROG_LOAD: tải prog với chức năng btf và thông tin dòng.
   * BPF_BTF_GET_FD_BY_ID: nhận btf fd
   * BPF_OBJ_GET_INFO_BY_FD: btf, func_info, line_info
     và các thông tin liên quan đến btf khác được trả lại.

Quy trình làm việc thường trông như sau:
::

ứng dụng:
      BPF_BTF_LOAD
          |
          v
      BPF_MAP_CREATE và BPF_PROG_LOAD
          |
          V.
      ......

Công cụ nội suy:
      ......
BPF_{PROG,MAP}_GET_NEXT_ID (lấy id prog/map)
          |
          V.
      BPF_{PROG,MAP}_GET_FD_BY_ID (nhận chương trình/bản đồ fd)
          |
          V.
      BPF_OBJ_GET_INFO_BY_FD (nhận bpf_prog_info/bpf_map_info với btf_id)
          ZZ0000ZZ
          V |
      BPF_BTF_GET_FD_BY_ID (nhận btf_fd) |
          ZZ0001ZZ
          V |
      BPF_OBJ_GET_INFO_BY_FD (nhận btf) |
          ZZ0002ZZ
          V V
      các kiểu in đẹp, chữ ký func kết xuất và thông tin dòng, v.v.


3.1 BPF_BTF_LOAD
----------------

Tải một khối dữ liệu BTF vào kernel. Một khối dữ liệu, được mô tả trong
ZZ0000ZZ, có thể được tải trực tiếp vào kernel. MỘT ZZ0001ZZ
được trả về không gian người dùng.

3.2 BPF_MAP_CREATE
------------------

Một bản đồ có thể được tạo bằng ZZ0000ZZ và id loại khóa/giá trị được chỉ định.::

__u32 btf_fd;         /* fd trỏ tới dữ liệu kiểu BTF */
    __u32 btf_key_type_id;        /* BTF type_id của khóa */
    __u32 btf_value_type_id;      /* BTF type_id của giá trị */

Trong libbpf, bản đồ có thể được xác định bằng chú thích bổ sung như bên dưới:
::

cấu trúc {
        __uint(loại, BPF_MAP_TYPE_ARRAY);
        __type(khóa, int);
        __type(giá trị, struct ipv_counts);
        __uint(max_entries, 4);
    } btf_map SEC(".maps");

Trong quá trình phân tích cú pháp ELF, libbpf có thể trích xuất khóa/giá trị type_id và gán
chúng thành các thuộc tính BPF_MAP_CREATE một cách tự động.

.. _BPF_Prog_Load:

3.3 BPF_PROG_LOAD
-----------------

Trong quá trình prog_load, func_info và line_info có thể được chuyển tới kernel bằng cách thích hợp
giá trị cho các thuộc tính sau:
::

__u32 insn_cnt;
    __aligned_u64 nội dung;
    ......
__u32 prog_btf_fd;    /* fd trỏ tới dữ liệu kiểu BTF */
    __u32 func_info_rec_size;     /* kích thước không gian người dùng bpf_func_info */
    __aligned_u64 func_info;      /*thông tin chức năng*/
    __u32 func_info_cnt;  /* số lượng bản ghi bpf_func_info */
    __u32 dòng_info_rec_size;     /* kích thước không gian người dùng bpf_line_info */
    __aligned_u64 line_info;      /*thông tin dòng */
    __u32 dòng_info_cnt;  /* số lượng bản ghi bpf_line_info */

Func_info và line_info lần lượt là một mảng bên dưới.::

cấu trúc bpf_func_info {
        __u32 insn_off; /* [0, insn_cnt - 1] */
        __u32 loại_id;  /* trỏ đến loại BTF_KIND_FUNC */
    };
    cấu trúc bpf_line_info {
        __u32 insn_off; /* [0, insn_cnt - 1] */
        __u32 file_name_off; /* offset vào bảng chuỗi cho tên tệp */
        __u32 dòng_off; /* offset vào bảng chuỗi cho dòng nguồn */
        __u32 dòng_col; /*số dòng và số cột */
    };

func_info_rec_size là kích thước của mỗi bản ghi func_info và
line_info_rec_size là kích thước của mỗi bản ghi line_info. Vượt qua kỷ lục
size thành kernel giúp có thể mở rộng bản ghi trong tương lai.

Dưới đây là các yêu cầu đối với func_info:
  * func_info[0].insn_off phải bằng 0.
  * func_info insn_off có thứ tự tăng dần và khớp
    ranh giới bpf func.

Dưới đây là các yêu cầu đối với line_info:
  * insn đầu tiên trong mỗi func phải có bản ghi line_info trỏ tới nó.
  * line_info insn_off theo thứ tự tăng dần.

Đối với line_info, số dòng và số cột được xác định như sau:
::

#define BPF_LINE_INFO_LINE_NUM(line_col) ((line_col) >> 10)
    #define BPF_LINE_INFO_LINE_COL(line_col) ((line_col) & 0x3ff)

3.4 BPF_{PROG,MAP}_GET_NEXT_ID
------------------------------

Trong kernel, mọi chương trình, bản đồ hoặc btf được tải đều có một id duy nhất. Id sẽ không
thay đổi trong suốt thời gian tồn tại của chương trình, bản đồ hoặc btf.

Lệnh bpf syscall BPF_{PROG,MAP}_GET_NEXT_ID trả về tất cả id, một cho
mỗi lệnh, tới không gian người dùng, cho chương trình hoặc bản đồ bpf, tương ứng, do đó,
công cụ kiểm tra có thể kiểm tra tất cả các chương trình và bản đồ.

3.5 BPF_{PROG,MAP}_GET_FD_BY_ID
-------------------------------

Công cụ xem xét nội tâm không thể sử dụng id để lấy thông tin chi tiết về chương trình hoặc bản đồ.
Đầu tiên cần phải lấy một bộ mô tả tệp cho mục đích đếm tham chiếu.

3.6 BPF_OBJ_GET_INFO_BY_FD
--------------------------

Sau khi có được fd chương trình/bản đồ, một công cụ xem xét nội tâm có thể nhận được thông tin chi tiết
thông tin từ kernel về fd này, một số trong đó có liên quan đến BTF. cho
ví dụ: ZZ0000ZZ trả về ZZ0001ZZ và id loại khóa/giá trị.
ZZ0002ZZ trả về thông tin ZZ0003ZZ, func_info và dòng để dịch
mã byte bpf và jited_line_info.

3.7 BPF_BTF_GET_FD_BY_ID
------------------------

Với ZZ0000ZZ thu được trong ZZ0001ZZ và ZZ0002ZZ, bpf
lệnh syscall BPF_BTF_GET_FD_BY_ID có thể truy xuất btf fd. Sau đó, với
lệnh BPF_OBJ_GET_INFO_BY_FD, btf blob, ban đầu được tải vào
kernel với BPF_BTF_LOAD, có thể được lấy ra.

Với btf blob, ZZ0000ZZ và ZZ0001ZZ, một sự xem xét nội tâm
công cụ này có đầy đủ kiến thức về btf và có thể in đẹp các khóa/giá trị bản đồ, kết xuất
chữ ký func và thông tin dòng, cùng với mã byte/jit.

4. Giao diện định dạng tệp ELF
============================

4.1 Phần .BTF
----------------

Phần .BTF chứa dữ liệu loại và chuỗi. Định dạng của phần này là
giống như mô tả trong ZZ0000ZZ.

.. _BTF_Ext_Section:

4.2 Phần .BTF.ext
--------------------

Phần .BTF.ext mã hóa các chuyển vị trí func_info, line_info và CO-RE
cần thao tác với trình tải trước khi tải vào kernel.

Thông số kỹ thuật cho phần .BTF.ext được xác định tại ZZ0000ZZ
và ZZ0001ZZ.

Tiêu đề hiện tại của phần .BTF.ext::

cấu trúc btf_ext_header {
        __u16 phép thuật;
        __u8 phiên bản;
        __u8 cờ;
        __u32 hdr_len;

/* Tất cả các offset đều tính bằng byte so với phần cuối của tiêu đề này */
        __u32 func_info_off;
        __u32 func_info_len;
        __u32 dòng_info_off;
        __u32 dòng_info_len;

/* phần tùy chọn của tiêu đề .BTF.ext */
        __u32 core_relo_off;
        __u32 core_relo_len;
    };

Nó rất giống với phần .BTF. Thay vì phần loại/chuỗi, nó
chứa các phần phụ func_info, line_info và core_relo.
Xem ZZ0000ZZ để biết chi tiết về func_info và line_info
định dạng ghi âm.

Func_info được tổ chức như sau.::

func_info_rec_size /* giá trị __u32 */
     btf_ext_info_sec cho phần #1 /* func_info cho phần #1 */
     btf_ext_info_sec cho phần #2 /* func_info cho phần #2 */
     ...

ZZ0000ZZ chỉ định kích thước của cấu trúc ZZ0001ZZ khi
.BTF.ext được tạo. ZZ0002ZZ, được định nghĩa dưới đây, là tập hợp các
func_info cho từng phần ELF cụ thể.::

cấu trúc btf_ext_info_sec {
        __u32 giây_name_off; /* offset vào tên phần */
        __u32 num_info;
        /* Theo sau là num_info * record_size số byte */
        __u8 dữ liệu[0];
     };

Ở đây, num_info phải lớn hơn 0.

line_info được tổ chức như bên dưới.::

line_info_rec_size /* giá trị __u32 */
     btf_ext_info_sec cho phần #1 /* line_info cho phần #1 */
     btf_ext_info_sec cho phần #2 /* line_info cho phần #2 */
     ...

ZZ0000ZZ chỉ định kích thước của cấu trúc ZZ0001ZZ khi
.BTF.ext được tạo.

Việc giải thích ZZ0000ZZ và
ZZ0001ZZ khác nhau giữa kernel API và ELF API. cho
kernel API, ZZ0002ZZ là phần bù lệnh trong đơn vị của ZZ0003ZZ. Đối với ELF API, ZZ0004ZZ là byte bù từ
đầu phần (ZZ0005ZZ).

core_relo được tổ chức như sau.::

core_relo_rec_size /* giá trị __u32 */
     btf_ext_info_sec cho phần #1 /* core_relo cho phần #1 */
     btf_ext_info_sec cho phần #2 /* core_relo cho phần #2 */

ZZ0000ZZ chỉ định kích thước của ZZ0001ZZ
cấu trúc khi .BTF.ext được tạo. Tất cả các cấu trúc ZZ0002ZZ
trong một ZZ0003ZZ mô tả việc tái định vị được áp dụng cho
phần được đặt tên bởi ZZ0004ZZ.

Xem ZZ0000ZZ
để biết thêm thông tin về việc di dời CO-RE.

4.3 Phần .BTF_ids
--------------------

Phần .BTF_ids mã hóa các giá trị ID BTF được sử dụng trong kernel.

Phần này được tạo trong quá trình biên dịch kernel với sự trợ giúp của
macro được xác định trong tệp tiêu đề ZZ0000ZZ. Mã hạt nhân có thể
sử dụng chúng để tạo danh sách và bộ (danh sách được sắp xếp) các giá trị ID BTF.

Các macro ZZ0000ZZ và ZZ0001ZZ xác định danh sách các giá trị ID BTF chưa được sắp xếp,
với cú pháp sau::

BTF_ID_LIST(danh sách)
  BTF_ID(loại1, tên1)
  BTF_ID(loại2, tên2)

dẫn đến bố cục sau trong phần .BTF_ids ::

__BTF_ID__type1__name1__1:
  .không 4
  __BTF_ID__type2__name2__2:
  .không 4

Biến ZZ0000ZZ được xác định để truy cập danh sách.

Macro ZZ0000ZZ xác định 4 byte 0. Nó được sử dụng khi chúng ta
muốn xác định mục không được sử dụng trong BTF_ID_LIST, như::

BTF_ID_LIST(bpf_skb_output_btf_ids)
      BTF_ID(cấu trúc, sk_buff)
      BTF_ID_UNUSED
      BTF_ID(cấu trúc, task_struct)

Cặp macro ZZ0000ZZ xác định danh sách được sắp xếp các giá trị ID BTF
và số lượng của chúng, với cú pháp sau::

BTF_SET_START(bộ)
  BTF_ID(loại1, tên1)
  BTF_ID(loại2, tên2)
  BTF_SET_END(bộ)

dẫn đến bố cục sau trong phần .BTF_ids ::

__BTF_ID__bộ__bộ:
  .không 4
  __BTF_ID__type1__name1__3:
  .không 4
  __BTF_ID__type2__name2__4:
  .không 4

Biến ZZ0000ZZ được xác định để truy cập danh sách.

Tên ZZ0000ZZ có thể là một trong những tên sau::

cấu trúc, liên kết, typedef, func

và được sử dụng làm bộ lọc khi phân giải giá trị ID BTF.

Tất cả danh sách và bộ ID BTF được biên soạn trong phần .BTF_ids và
được giải quyết trong giai đoạn liên kết xây dựng kernel bằng công cụ ZZ0000ZZ.

4.4 Phần .BTF.base
---------------------
Tách BTF - trong đó phần .BTF chỉ chứa các loại không có trong phần được liên kết
phần cơ sở .BTF - là một cách cực kỳ hiệu quả để mã hóa thông tin loại
đối với các mô-đun hạt nhân, vì chúng thường bao gồm một số mô-đun dành riêng cho mô-đun
các loại cùng với một tập hợp lớn các loại hạt nhân được chia sẻ. Cái trước được mã hóa
trong BTF phân chia, trong khi cái sau được mã hóa trong BTF cơ sở, dẫn đến nhiều hơn
biểu diễn nhỏ gọn. Một loại trong phân chia BTF đề cập đến một loại trong
BTF cơ sở đề cập đến nó bằng cách sử dụng ID BTF cơ sở của nó và bắt đầu phân chia ID BTF
cuối cùng_base_BTF_ID + 1.

Tuy nhiên, nhược điểm của phương pháp này là điều này làm cho BTF bị chia rẽ
hơi giòn - khi BTF cơ sở thay đổi, các tham chiếu ID BTF cơ sở sẽ
không còn hiệu lực và bản thân BTF bị chia tách trở nên vô dụng. Vai trò của
Phần .BTF.base giúp cho việc phân chia BTF trở nên linh hoạt hơn trong các trường hợp
BTF cơ sở có thể thay đổi, như trường hợp các mô-đun hạt nhân không được xây dựng mỗi
thời gian hạt nhân là ví dụ. .BTF.base chứa các loại cơ sở được đặt tên; INT,
FLOAT, CẤU TRÚC, UNION, ENUM[64]s và FWD. INT và FLOAT hoàn toàn
được mô tả trong phần .BTF.base, trong khi các loại tổng hợp như cấu trúc
và các hiệp hội không được xác định đầy đủ - loại .BTF.base chỉ đóng vai trò là
mô tả về kiểu phân chia mà BTF đề cập đến, vì vậy các cấu trúc/kết hợp
có 0 thành viên trong phần .BTF.base. Các ENUM[64] cũng được ghi tương tự
với 0 thành viên. Bất kỳ loại nào khác đều được thêm vào BTF được chia. Cái này
quá trình chưng cất sau đó để lại cho chúng tôi phần .BTF.base với
những mô tả tối thiểu như vậy về các loại cơ sở và phần phân chia .BTF đề cập đến
đối với các loại cơ sở đó. Sau đó, chúng ta có thể định vị lại phần BTF đã chia bằng cách sử dụng cả
thông tin được lưu trữ trong phần .BTF.base và cơ sở .BTF mới; loại
thông tin trong phần .BTF.base cho phép chúng tôi cập nhật phần chia BTF
tham chiếu để trỏ đến ID BTF cơ sở mới tương ứng.

Việc di chuyển BTF xảy ra khi tải mô-đun hạt nhân khi mô-đun hạt nhân có
Phần .BTF.base và libbpf cũng cung cấp btf__relocate() API cho
thực hiện được điều này.

Để làm ví dụ, hãy xem xét cơ sở BTF sau::

[1] Kích thước 'int' INT=4 bit_offset=0 nr_bits=32 mã hóa=SIGNED
      [2] STRUCT kích thước 'foo'=8 vlen=2
              'f1' type_id=1 bit_offset=0
              'f2' type_id=1 bit_offset=32

...and associated split BTF::

      [3] PTR '(anon)' type_id=2

tức là chia BTF mô tả một con trỏ tới struct foo { int f1; int f2 };

.BTF.base sẽ bao gồm::

[1] Kích thước 'int' INT=4 bit_offset=0 nr_bits=32 mã hóa=SIGNED
      [2] STRUCT kích thước 'foo'=8 vlen=0

Nếu sau này chúng ta di dời BTF đã phân chia bằng cách sử dụng cơ sở mới BTF::

[1] Kích thước 'dài không dấu int' của INT=8 bit_offset=0 nr_bits=64 mã hóa=(không có)
      [2] Kích thước 'int' INT=4 bit_offset=0 nr_bits=32 mã hóa=SIGNED
      [3] STRUCT kích thước 'foo'=8 vlen=2
              'f1' type_id=2 bit_offset=0
              'f2' type_id=2 bit_offset=32

...we can use our .BTF.base description to know that the split BTF reference
là cấu trúc foo và việc di chuyển dẫn đến sự phân chia mới BTF::

[4] PTR '(anon)' type_id=3

Lưu ý rằng chúng tôi phải cập nhật ID BTF và khởi động ID BTF cho phần BTF được tách.

Vì vậy, chúng ta thấy .BTF.base đóng vai trò như thế nào trong việc hỗ trợ việc di dời sau này,
dẫn đến sự phân chia BTF linh hoạt hơn.

Các phần .BTF.base sẽ được tạo tự động cho mô-đun hạt nhân ngoài cây
bản dựng - tức là nơi KBUILD_EXTMOD được đặt (giống như dành cho "make M=path/2/mod"
trường hợp). Việc tạo .BTF.base yêu cầu hỗ trợ pahole cho "distilled_base"
Tính năng BTF; cái này có sẵn trong pahole v1.28 trở lên.

5. Sử dụng BTF
============

5.1 bpftool bản đồ in đẹp
----------------------------

Với BTF, khóa/giá trị bản đồ có thể được in dựa trên các trường thay vì chỉ đơn giản là
byte thô. Điều này đặc biệt có giá trị đối với cấu trúc lớn hoặc nếu dữ liệu của bạn
cấu trúc có bitfield. Ví dụ: đối với bản đồ sau,::

enum A { A1, A2, A3, A4, A5 };
      typedef enum A ___A;
      cấu trúc tmp_t {
           ký tự a1:4;
           int a2:4;
           int :4;
           __u32 a3:4;
           int b;
           ___A b1:4;
           enum A b2:4;
      };
      cấu trúc {
           __uint(loại, BPF_MAP_TYPE_ARRAY);
           __type(khóa, int);
           __type(giá trị, cấu trúc tmp_t);
           __uint(max_entries, 1);
      } tmpmap SEC(".maps");

bpftool có thể in đẹp như dưới đây:
::

[{
            "chìa khóa": 0,
            "giá trị": {
                "a1": 0x2,
                "a2": 0x4,
                "a3": 0x6,
                "b": 7,
                "b1": 0x8,
                "b2": 0xa
            }
        }
      ]

Kết xuất chương trình 5,2 bpftool
---------------------

Sau đây là ví dụ cho thấy func_info và line_info có thể giúp ích cho chương trình như thế nào
kết xuất với tên biểu tượng hạt nhân, nguyên mẫu hàm và dòng tốt hơn
thông tin.::

$ bpftool prog dump được ghim /sys/fs/bpf/test_btf_haskv
    […]
    int test_long_fname_2(struct dummy_tracepoint_args * arg):
    bpf_prog_44a040bf25481309_test_long_fname_2:
    ; int tĩnh test_long_fname_2(struct dummy_tracepoint_args *arg)
       0: đẩy %rbp
       1: di chuyển %rsp,%rbp
       4: phụ $0x30,%rsp
       b: phụ $0x28,%rbp
       f: di chuyển %rbx,0x0(%rbp)
      13: di chuyển %r13,0x8(%rbp)
      17: di chuyển %r14,0x10(%rbp)
      1b: di chuyển %r15,0x18(%rbp)
      1f: xor %eax,%eax
      21: di chuyển %rax,0x20(%rbp)
      25: xor %esi,%esi
    ; khóa int = 0;
      27: di chuyển %esi,-0x4(%rbp)
    ; nếu (!arg->sock)
      2a: di chuyển 0x8(%rdi),%rdi
    ; nếu (!arg->sock)
      2e: cmp $0x0,%rdi
      32: je 0x00000000000000070
      34: di chuyển %rbp,%rsi
    ; đếm = bpf_map_lookup_elem(&btf_map, &key);
    […]

5.3 Nhật ký xác minh
----------------

Sau đây là ví dụ về cách line_info có thể giúp gỡ lỗi xác minh
thất bại.::

/* Mã tại tools/testing/selftests/bpf/test_xdp_noinline.c
        * được sửa đổi như dưới đây.
        */
       dữ liệu = (void *)(dài)xdp->data;
       data_end = (void *)(long)xdp->data_end;
       /*
       nếu (dữ liệu + 4 > dữ liệu_end)
               trả lại XDP_DROP;
       */
       Dữ liệu ZZ0000ZZ) = dst->dst;

$ bpftool tải chương trình ./test_xdp_noinline.o /sys/fs/bpf/test_xdp_noinline gõ xdp
        ; dữ liệu = (void *)(dài)xdp->data;
        224: (79) r2 = ZZ0000ZZ)(r10 -112)
        225: (61) r2 = ZZ0001ZZ)(r2 +0)
        ; Dữ liệu ZZ0002ZZ) = dst->dst;
        226: (63) ZZ0003ZZ)(r2 +0) = r1
        truy cập không hợp lệ vào gói, off=0 size=4, R2(id=0,off=0,r=0)
        Phần bù R2 nằm ngoài gói

6. Thế hệ BTF
=================

Bạn cần pahole mới nhất

ZZ0000ZZ

hoặc llvm (8.0 trở lên). Pahole hoạt động như một công cụ chuyển đổi lùn2btf. Nó không
hỗ trợ loại .BTF.ext và btf BTF_KIND_FUNC. Ví dụ,::

-bash-4,4$ mèo t.c
      cấu trúc t {
        int a:2;
        int b:3;
        int c:2;
      }g;
      -bash-4.4$ gcc -c -O2 -g t.c
      -bash-4,4$ pahole -JV t.o
      Tập tin tới:
      [1] STRUCT t kind_flag=1 size=4 vlen=3
              một type_id=2 bitfield_size=2 bit_offset=0
              b type_id=2 bitfield_size=3 bit_offset=2
              c type_id=2 bitfield_size=2 bit_offset=5
      [2] INT kích thước int=4 bit_offset=0 nr_bits=32 mã hóa=SIGNED

llvm có thể tạo trực tiếp .BTF và .BTF.ext với -g cho mục tiêu bpf
chỉ. Mã lắp ráp (-S) có thể hiển thị mã hóa BTF trong lắp ráp
định dạng.::

-bash-4,4$ mèo t2.c
    typedef int __int32;
    cấu trúc t2 {
      int a2;
      int (*f2)(char q1, __int32 q2, ...);
      int (*f3)();
    } g2;
    int main() { trả về 0; }
    int test() { trả về 0; }
    -bash-4.4$ clang -c -g -O2 --target=bpf t2.c
    -bash-4.4$ readelf -S t2.o
      ......
[ 8] .BTF PROGBITS 0000000000000000 00000247
           000000000000016e 00000000000000000 0 0 1
      [ 9] .BTF.ext PROGBITS 0000000000000000 000003b5
           0000000000000060 00000000000000000 0 0 1
      [10] .rel.BTF.ext REL 0000000000000000 000007e0
           0000000000000040 00000000000000010 16 9 8
      ......
-bash-4.4$ kêu vang -S -g -O2 --target=bpf t2.c
    -bash-4,4$ mèo t2.s
      ......
            .section        .BTF,"",@progbits
            .short  60319                   # 0xeb9f
            .byte   1
            .byte   0
            .long   24
            .long   0
            .long   220
            .long   220
            .long   122
            .long   0                       # BTF_KIND_FUNC_PROTO(id = 1)
            .long   218103808               # 0xd000000
            .long   2
            .long   83                      # BTF_KIND_INT(id = 2)
            .long   16777216                # 0x1000000
            .long   4
            .long   16777248                # 0x1000020
      ......
            .byte   0                       # string offset=0
            .ascii  ".text"                 # string offset=1
            .byte   0
            .ascii  "/home/yhs/tmp-pahole/t2.c" # string offset=7
            .byte   0
            .ascii  "int main() { return 0; }" # string offset=33
            .byte   0
            .ascii  "int test() { return 0; }" # string offset=58
            .byte   0
            .ascii  "int"                   # string offset=83
      ......
            .section        .BTF.ext,"",@progbits
            .short  60319                   # 0xeb9f
            .byte   1
            .byte   0
            .long   24
            .long   0
            .long   28
            .long   28
            .long   44
            .long   8                       # FuncInfo
            .long   1                       # FuncInfo section string offset=1
            .long   2
            .long   .Lfunc_begin0
            .long   3
            .long   .Lfunc_begin1
            .long   5
            .long   16                      # LineInfo
            .long   1                       # LineInfo section string offset=1
            .long   2
            .long   .Ltmp0
            .long   7
            .long   33
            .long   7182                    # Line 7 Col 14
            .long   .Ltmp3
            .long   7
            .long   58
            .long   8206                    # Line 8 Col 14

7. Kiểm tra
==========

Kernel BPF tự kiểm tra ZZ0000ZZ
cung cấp một loạt các bài kiểm tra liên quan đến BTF.

.. Links
.. _tools/testing/selftests/bpf/prog_tests/btf.c:
   https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/tools/testing/selftests/bpf/prog_tests/btf.c
