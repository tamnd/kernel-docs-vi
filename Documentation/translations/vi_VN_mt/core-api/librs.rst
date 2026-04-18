.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/librs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==============================================
Giao diện lập trình thư viện Reed-Solomon
==========================================

:Tác giả: Thomas Gleixner

Giới thiệu
============

Thư viện Reed-Solomon chung cung cấp mã hóa, giải mã và lỗi
các chức năng hiệu chỉnh.

Mã Reed-Solomon được sử dụng trong các ứng dụng truyền thông và lưu trữ để
đảm bảo tính toàn vẹn dữ liệu.

Tài liệu này được cung cấp cho các nhà phát triển muốn sử dụng
chức năng do thư viện cung cấp.

Lỗi đã biết và giả định
==========================

Không có.

Cách sử dụng
=====

Chương này cung cấp các ví dụ về cách sử dụng thư viện.

Đang khởi tạo
------------

Hàm init init_rs trả về một con trỏ tới cấu trúc bộ giải mã rs,
chứa thông tin cần thiết cho việc mã hóa, giải mã và sửa lỗi
hiệu chỉnh với đa thức đã cho. Nó hoặc sử dụng một hiện có
bộ giải mã phù hợp hoặc tạo một bộ giải mã mới. Khi tạo tất cả các bảng tra cứu
để mã hóa/giải mã nhanh được tạo ra. Chức năng này có thể mất một lúc, vì vậy hãy thực hiện
chắc chắn không gọi nó trong các đường dẫn mã quan trọng.

::

/*Cấu trúc điều khiển Reed Solomon */
    cấu trúc tĩnh rs_control *rs_decode;

/* Kích thước ký hiệu là 10 (bit)
     * Đa thức nguyên thủy là x^10+x^3+1
     * căn bậc nhất liên tiếp là 0
     * phần tử nguyên thủy để tạo ra các gốc = 1
     * bậc đa thức của trình tạo (số nghiệm) = 6
     */
    rs_decode = init_rs(10, 0x409, 0, 1, 6);


Mã hóa
--------

Bộ mã hóa tính toán mã Reed-Solomon theo độ dài dữ liệu đã cho
và lưu kết quả vào bộ đệm chẵn lẻ. Lưu ý rằng bộ đệm chẵn lẻ
phải được khởi tạo trước khi gọi bộ mã hóa.

Dữ liệu mở rộng có thể được đảo ngược nhanh chóng bằng cách cung cấp giá trị khác 0
mặt nạ đảo ngược Dữ liệu mở rộng được XOR'ed với mặt nạ. Cái này được sử dụng
ví dụ: đối với FLASH ECC, trong đó tất cả 0xFF được đảo ngược thành tất cả 0x00. các
Mã Reed-Solomon cho tất cả 0x00 đều là 0x00. Mã được đảo ngược trước
lưu trữ vào FLASH nên nó cũng là 0xFF. Điều này ngăn cản việc đọc từ một
FLASH bị xóa dẫn đến lỗi ECC.

Các byte dữ liệu được mở rộng đến kích thước ký hiệu nhất định một cách nhanh chóng. có
không hỗ trợ mã hóa dòng bit liên tục với kích thước ký hiệu != 8 tại
khoảnh khắc. Nếu cần thiết thì việc thực hiện không phải là vấn đề lớn
chức năng như vậy.

::

/* Bộ đệm chẵn lẻ. Kích thước = số rễ */
    uint16_t par[6];
    /* Khởi tạo bộ đệm chẵn lẻ */
    bộ nhớ(par, 0, sizeof(par));
    /* Mã hóa 512 byte trong data8. Lưu trữ tính chẵn lẻ trong bộ đệm par */
    mã hóa_rs8 (rs_decoding, data8, 512, par, 0);


Giải mã
--------

Bộ giải mã tính toán hội chứng trên độ dài dữ liệu đã cho và
nhận các ký hiệu chẵn lẻ và sửa lỗi trong dữ liệu.

Nếu một hội chứng có sẵn từ bộ giải mã phần cứng thì hội chứng đó
tính toán bị bỏ qua.

Việc hiệu chỉnh bộ đệm dữ liệu có thể được ngăn chặn bằng cách cung cấp một
bộ đệm mẫu sửa và bộ đệm vị trí lỗi cho bộ giải mã.
Bộ giải mã lưu trữ vị trí lỗi đã tính toán và phần sửa lỗi
bitmask trong bộ đệm nhất định. Điều này rất hữu ích cho các bộ giải mã phần cứng
sử dụng một sơ đồ đặt hàng bit kỳ lạ.

Các byte dữ liệu được mở rộng đến kích thước ký hiệu nhất định một cách nhanh chóng. có
không hỗ trợ giải mã dòng bit liên tục với ký hiệu != 8 tại
khoảnh khắc. Nếu cần thiết thì việc thực hiện không phải là vấn đề lớn
chức năng như vậy.

Giải mã bằng tính toán hội chứng, hiệu chỉnh dữ liệu trực tiếp
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

/* Bộ đệm chẵn lẻ. Kích thước = số rễ */
    uint16_t par[6];
    dữ liệu uint8_t[512];
    int numr;
    /*Nhận dữ liệu*/
    .....
/*Nhận tính chẵn lẻ*/
    .....
/* Giải mã 512 byte trong data8.*/
    numerr = giải mã_rs8 (rs_decode, data8, par, 512, NULL, 0, NULL, 0, NULL);


Giải mã với hội chứng do bộ giải mã phần cứng đưa ra, hiệu chỉnh dữ liệu trực tiếp
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

/* Bộ đệm chẵn lẻ. Kích thước = số rễ */
    uint16_t par[6], syn[6];
    dữ liệu uint8_t[512];
    int numr;
    /*Nhận dữ liệu*/
    .....
/*Nhận tính chẵn lẻ*/
    .....
/* Nhận hội chứng từ bộ giải mã phần cứng */
    .....
/* Giải mã 512 byte trong data8.*/
    numerr = giải mã_rs8 (rs_decode, data8, par, 512, syn, 0, NULL, 0, NULL);


Giải mã theo hội chứng do bộ giải mã phần cứng đưa ra, không chỉnh sửa dữ liệu trực tiếp.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Lưu ý: Không cần thiết phải cung cấp dữ liệu và tính chẵn lẻ nhận được cho
bộ giải mã.

::

/* Bộ đệm chẵn lẻ. Kích thước = số rễ */
    uint16_t par[6], syn[6], corr[8];
    dữ liệu uint8_t[512];
    int numr, errpos[8];
    /*Nhận dữ liệu*/
    .....
/*Nhận tính chẵn lẻ*/
    .....
/* Nhận hội chứng từ bộ giải mã phần cứng */
    .....
/* Giải mã 512 byte trong data8.*/
    numerr = giải mã_rs8 (rs_decode, NULL, NULL, 512, syn, 0, errpos, 0, sửa);
    for (i = 0; i < numerr; i++) {
        do_error_ Correction_in_your_buffer(errpos[i], corr[i]);
    }


Dọn dẹp
-------

Hàm free_rs giải phóng các tài nguyên được phân bổ, nếu người gọi
người dùng cuối cùng của bộ giải mã.

::

/* Giải phóng tài nguyên */
    free_rs(rs_decoding);


Cấu trúc
==========

Chương này chứa tài liệu được tạo tự động của các cấu trúc
được sử dụng trong Thư viện Reed-Solomon và có liên quan đến
nhà phát triển.

.. kernel-doc:: include/linux/rslib.h
   :internal:

Chức năng công cộng được cung cấp
=========================

Chương này chứa tài liệu được tạo tự động của
Các hàm Reed-Solomon được xuất.

.. kernel-doc:: lib/reed_solomon/reed_solomon.c
   :export:

Tín dụng
=======

Mã thư viện để mã hóa và giải mã được viết bởi Phil Karn.

::

Bản quyền 2002, Phil Karn, KA9Q
            Có thể được sử dụng theo các điều khoản của Giấy phép Công cộng GNU (GPL)


Các chức năng và giao diện trình bao bọc được viết bởi Thomas Gleixner.

Nhiều người dùng đã cung cấp các bản sửa lỗi, cải tiến và giúp đỡ
thử nghiệm. Cảm ơn rất nhiều.

Những người sau đây đã đóng góp cho tài liệu này:

Thomas Gleixner\ tglx@kernel.org
