.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/mtdnand.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================
Giao diện lập trình trình điều khiển MTD NAND
=============================================

:Tác giả: Thomas Gleixner

Giới thiệu
============

Trình điều khiển NAND chung hỗ trợ hầu hết tất cả các chip dựa trên NAND và AG-AND
và kết nối chúng với hệ thống con Thiết bị công nghệ bộ nhớ (MTD) của
hạt nhân Linux.

Tài liệu này được cung cấp cho các nhà phát triển muốn triển khai
trình điều khiển bo mạch hoặc trình điều khiển hệ thống tập tin phù hợp với các thiết bị NAND.

Lỗi đã biết và giả định
==========================

Không có.

Gợi ý tài liệu
===================

Các tài liệu về chức năng và cấu trúc được tạo tự động. Mỗi chức năng và
thành viên cấu trúc có một mô tả ngắn được đánh dấu bằng [XXX]
định danh. Các chương sau giải thích ý nghĩa của những
số nhận dạng.

Mã định danh chức năng [XXX]
--------------------------

Các chức năng được đánh dấu bằng mã định danh [XXX] trong nhận xét ngắn.
Các mã định danh giải thích cách sử dụng và phạm vi của các chức năng. Đang theo dõi
định danh được sử dụng:

- [Giao diện MTD]

Các chức năng này cung cấp giao diện cho kernel MTD API. Họ là
   không thể thay thế và cung cấp chức năng hoàn chỉnh cho phần cứng
   độc lập.

- [Giao diện NAND]

Các chức năng này được xuất và cung cấp giao diện cho NAND
   hạt nhân API.

- [GENERIC]

Các chức năng chung không thể thay thế được và cung cấp chức năng
   hoàn toàn độc lập với phần cứng.

- [DEFAULT]

Các chức năng mặc định cung cấp chức năng liên quan đến phần cứng
   thích hợp cho hầu hết các triển khai. Các chức năng này có thể
   được thay thế bởi trình điều khiển bảng nếu cần thiết. Những chức năng đó được gọi
   thông qua các con trỏ trong cấu trúc mô tả chip NAND. Người lái tàu
   có thể thiết lập các chức năng cần được thay thế bởi bảng phụ thuộc
   hoạt động trước khi gọi nand_scan(). Nếu con trỏ hàm là
   NULL khi vào nand_scan() thì con trỏ được đặt về mặc định
   chức năng phù hợp với loại chip được phát hiện.

Mã định danh thành viên cấu trúc [XXX]
-------------------------------

Các thành viên cấu trúc được đánh dấu bằng mã định danh [XXX] trong nhận xét. các
định danh giải thích cách sử dụng và phạm vi của các thành viên. Đang theo dõi
định danh được sử dụng:

- [INTERN]

Các thành viên này chỉ dành cho mục đích sử dụng nội bộ của trình điều khiển NAND và không được phép sử dụng
   đã sửa đổi. Hầu hết các giá trị này được tính toán từ hình dạng chip
   thông tin được đánh giá trong quá trình nand_scan().

- [REPLACEABLE]

Các thành viên có thể thay thế được nắm giữ các chức năng liên quan đến phần cứng có thể được
   được cung cấp bởi người điều khiển bảng. Trình điều khiển bảng có thể thiết lập các chức năng
   cần được thay thế bằng các chức năng phụ thuộc vào bảng trước khi gọi
   nand_scan(). Nếu con trỏ hàm là NULL khi vào
   nand_scan() thì con trỏ được đặt thành hàm mặc định
   phù hợp với loại chip được phát hiện.

- [BOARDSPECIFIC]

Các thành viên cụ thể của Hội đồng nắm giữ thông tin liên quan đến phần cứng phải
   được cung cấp bởi người lái xe. Người điều khiển bo mạch phải thiết lập
   con trỏ hàm và trường dữ liệu trước khi gọi nand_scan().

- [OPTIONAL]

Các thành viên tùy chọn có thể nắm giữ thông tin liên quan đến người điều khiển hội đồng quản trị.
   Mã trình điều khiển NAND chung không sử dụng thông tin này.

Trình điều khiển bảng cơ bản
==================

Đối với hầu hết các bảng, chỉ cần cung cấp những thông tin cơ bản là đủ
hoạt động và điền vào một số thành viên thực sự phụ thuộc vào hội đồng quản trị trong nand
cấu trúc mô tả chip

Định nghĩa cơ bản
-------------

Ít nhất bạn phải cung cấp cấu trúc nand_chip và bộ lưu trữ cho
địa chỉ chip được ánh xạ. Bạn có thể phân bổ cấu trúc nand_chip
sử dụng kmalloc hoặc bạn có thể phân bổ nó một cách tĩnh. Cấu trúc chip NAND
nhúng cấu trúc mtd sẽ được đăng ký vào hệ thống con MTD.
Bạn có thể trích xuất một con trỏ tới cấu trúc mtd từ con trỏ nand_chip
sử dụng trình trợ giúp nand_to_mtd().

Ví dụ dựa trên Kmalloc

::

cấu trúc tĩnh mtd_info *board_mtd;
    khoảng trống tĩnh __iomem *baseaddr;


Ví dụ tĩnh

::

cấu trúc tĩnh nand_chip board_chip;
    khoảng trống tĩnh __iomem *baseaddr;


Phân vùng xác định
-----------------

Nếu bạn muốn chia thiết bị của mình thành các phân vùng, hãy xác định một
sơ đồ phân vùng phù hợp với bảng của bạn.

::

#define NUM_PARTITIONS 2
    cấu trúc tĩnh mtd_partition phân vùng_info[] = {
        { .name = "Phân vùng flash 1",
          .offset = 0,
          .size = 8 * 1024 * 1024 },
        { .name = "Phân vùng flash 2",
          .offset = MTDPART_OFS_NEXT,
          .size = MTDPART_SIZ_FULL },
    };


Chức năng điều khiển phần cứng
-------------------------

Chức năng điều khiển phần cứng cung cấp quyền truy cập vào các chân điều khiển của
(Các) chip NAND. Việc truy cập có thể được thực hiện bằng các chân GPIO hoặc bằng các dòng địa chỉ.
Nếu bạn sử dụng dòng địa chỉ, hãy đảm bảo rằng các yêu cầu về thời gian là
đã gặp.

ZZ0000ZZ

::

static void board_hwcontrol(struct mtd_info *mtd, int cmd)
    {
        chuyển đổi (cmd) {
            trường hợp NAND_CTL_SETCLE: /* Đặt chân CLE ở mức cao */ ngắt;
            trường hợp NAND_CTL_CLRCLE: /* Đặt chân CLE ở mức thấp */ ngắt;
            trường hợp NAND_CTL_SETALE: /* Đặt chân ALE ở mức cao */ ngắt;
            trường hợp NAND_CTL_CLRALE: /* Đặt chân ALE ở mức thấp */ ngắt;
            trường hợp NAND_CTL_SETNCE: /* Đặt chân nCE ở mức thấp */ ngắt;
            trường hợp NAND_CTL_CLRNCE: /* Đặt chân nCE ở mức cao */ ngắt;
        }
    }


ZZ0000ZZ Giả sử rằng chân nCE được điều khiển
bởi một bộ giải mã chọn chip.

::

static void board_hwcontrol(struct mtd_info *mtd, int cmd)
    {
        struct nand_chip *this = mtd_to_nand(mtd);
        chuyển đổi (cmd) {
            trường hợp NAND_CTL_SETCLE: this->legacy.IO_ADDR_W |= CLE_ADRR_BIT;  phá vỡ;
            trường hợp NAND_CTL_CLRCLE: this->legacy.IO_ADDR_W &= ~CLE_ADRR_BIT; phá vỡ;
            trường hợp NAND_CTL_SETALE: this->legacy.IO_ADDR_W |= ALE_ADRR_BIT;  phá vỡ;
            trường hợp NAND_CTL_CLRALE: this->legacy.IO_ADDR_W &= ~ALE_ADRR_BIT; phá vỡ;
        }
    }


Chức năng sẵn sàng của thiết bị
---------------------

Nếu giao diện phần cứng có sẵn chân bận của chip NAND
được kết nối với GPIO hoặc chân I/O có thể truy cập khác, chức năng này được sử dụng
để đọc lại trạng thái của pin. Hàm không có đối số và
sẽ trả về 0 nếu thiết bị bận (chân R/B ở mức thấp) và 1 nếu
thiết bị đã sẵn sàng (chân R/B ở mức cao). Nếu giao diện phần cứng không
cấp quyền truy cập vào pin bận sẵn sàng, thì chức năng này không được xác định
và con trỏ hàm this->legacy.dev_ready được đặt thành NULL.

Hàm khởi tạo
-------------

Hàm init cấp phát bộ nhớ và thiết lập tất cả các board cụ thể
tham số và con trỏ hàm. Khi mọi thứ đã được thiết lập xong nand_scan()
được gọi. Chức năng này cố gắng phát hiện và xác định chip. Nếu một
chip được tìm thấy, tất cả các trường dữ liệu nội bộ đều được khởi tạo tương ứng.
(Các) cấu trúc phải được xóa bỏ trước và sau đó được lấp đầy bằng
thông tin cần thiết về thiết bị.

::

int tĩnh __init board_init (void)
    {
        cấu trúc nand_chip *this;
        int lỗi = 0;

/* Cấp phát bộ nhớ cho cấu trúc thiết bị MTD và dữ liệu riêng tư */
        this = kzalloc(sizeof(struct nand_chip), GFP_KERNEL);
        nếu (!cái này) {
            printk ("Không thể phân bổ cấu trúc thiết bị NAND MTD.\n");
            lỗi = -ENOMEM;
            đi ra ngoài;
        }

board_mtd = nand_to_mtd(cái này);

/* ánh xạ địa chỉ vật lý */
        baseaddr = ioremap(CHIP_PHYSICAL_ADDRESS, 1024);
        if (!baseaddr) {
            printk("Ioremap để truy cập chip NAND không thành công\n");
            lỗi = -EIO;
            đi ra ngoài_mtd;
        }

/* Đặt địa chỉ của dòng IO NAND */
        this->legacy.IO_ADDR_R = baseaddr;
        this->legacy.IO_ADDR_W = baseaddr;
        /* Chức năng điều khiển phần cứng tham khảo */
        cái này->hwcontrol = board_hwcontrol;
        /* Đặt thời gian trễ lệnh, xem bảng dữ liệu để biết giá trị chính xác */
        cái này->legacy.chip_delay = CHIP_DEPENDEND_COMMAND_DELAY;
        /* Gán chức năng sẵn sàng cho thiết bị, nếu có */
        cái này->legacy.dev_ready = board_dev_ready;
        cái này->eccmode = NAND_ECC_SOFT;

/*Quét để tìm sự tồn tại của thiết bị */
        if (nand_scan (cái này, 1)) {
            lỗi = -ENXIO;
            đi ra ngoài_ior;
        }

add_mtd_partitions(board_mtd, phân vùng_info, NUM_PARTITIONS);
        đi ra ngoài;

out_ior:
        iounmap(baseaddr);
    out_mtd:
        kfree (cái này);
    ra:
        trả lại lỗi;
    }
    module_init(board_init);


Chức năng thoát
-------------

Chức năng thoát chỉ cần thiết nếu trình điều khiển được biên dịch dưới dạng
mô-đun. Nó giải phóng tất cả các tài nguyên được giữ bởi trình điều khiển chip và
hủy đăng ký các phân vùng trong lớp MTD.

::

#ifdef MODULE
    khoảng trống tĩnh __exit board_cleanup (void)
    {
        /*Hủy đăng ký thiết bị */
        WARN_ON(mtd_device_unregister(board_mtd));
        /* Giải phóng tài nguyên */
        nand_cleanup(mtd_to_nand(board_mtd));

/* hủy bản đồ địa chỉ vật lý */
        iounmap(baseaddr);

/* Giải phóng cấu trúc thiết bị MTD */
        kfree (mtd_to_nand(board_mtd));
    }
    module_exit(board_cleanup);
    #endif


Chức năng điều khiển bảng nâng cao
===============================

Chương này mô tả chức năng nâng cao của trình điều khiển NAND.
Để biết danh sách các chức năng có thể bị ghi đè bởi trình điều khiển bo mạch, hãy xem
tài liệu về cấu trúc nand_chip.

Điều khiển nhiều chip
---------------------

Trình điều khiển nand có thể điều khiển mảng chip. Vì vậy người lái tàu phải
cung cấp chức năng select_chip riêng. Chức năng này phải (bỏ) chọn
chip được yêu cầu. Con trỏ hàm trong cấu trúc nand_chip phải là
đặt trước khi gọi nand_scan(). Tham số maxchip của nand_scan()
xác định số lượng chip tối đa cần quét. Hãy chắc chắn rằng
Hàm select_chip có thể xử lý số lượng chip được yêu cầu.

Trình điều khiển nand nối các chip thành một chip ảo và cung cấp
chip ảo này đến lớp MTD.

*Lưu ý: Trình điều khiển chỉ có thể xử lý các mảng chip tuyến tính có kích thước bằng nhau
chip. Không có hỗ trợ cho các mảng song song giúp mở rộng phạm vi
băng thông rộng.*

ZZ0000ZZ

::

tĩnh void board_select_chip (struct mtd_info *mtd, int chip)
    {
        /* Bỏ chọn tất cả các chip, đặt tất cả các chân nCE ở mức cao */
        GPIO(BOARD_NAND_NCE) |= 0xff;
        nếu (chip >= 0)
            GPIO(BOARD_NAND_NCE) &= ~ (1 << chip);
    }


ZZ0000ZZ Giả sử rằng các chân nCE là
được kết nối với bộ giải mã địa chỉ.

::

tĩnh void board_select_chip (struct mtd_info *mtd, int chip)
    {
        struct nand_chip *this = mtd_to_nand(mtd);

/* Bỏ chọn tất cả các chip */
        cái này->legacy.IO_ADDR_R &= ~BOARD_NAND_ADDR_MASK;
        cái này->legacy.IO_ADDR_W &= ~BOARD_NAND_ADDR_MASK;
        công tắc (chip) {
        trường hợp 0:
            cái này->di sản.IO_ADDR_R |= BOARD_NAND_ADDR_CHIP0;
            cái này->di sản.IO_ADDR_W |= BOARD_NAND_ADDR_CHIP0;
            phá vỡ;
        ....
trường hợp n:
            cái này->di sản.IO_ADDR_R |= BOARD_NAND_ADDR_CHIPn;
            cái này->di sản.IO_ADDR_W |= BOARD_NAND_ADDR_CHIPn;
            phá vỡ;
        }
    }


Hỗ trợ phần cứng ECC
--------------------

Hàm và hằng số
~~~~~~~~~~~~~~~~~~~~~~~

Trình điều khiển nand hỗ trợ ba loại phần cứng ECC khác nhau.

-NAND_ECC_HW3_256

Trình tạo ECC phần cứng cung cấp 3 byte ECC trên 256 byte.

-NAND_ECC_HW3_512

Trình tạo ECC phần cứng cung cấp 3 byte ECC trên 512 byte.

-NAND_ECC_HW6_512

Trình tạo ECC phần cứng cung cấp 6 byte ECC trên 512 byte.

-NAND_ECC_HW8_512

Trình tạo ECC phần cứng cung cấp 8 byte ECC trên 512 byte.

Nếu trình tạo phần cứng của bạn có chức năng khác, hãy thêm nó vào
vị trí thích hợp trong nand_base.c

Trình điều khiển bo mạch phải cung cấp các chức năng sau:

- kích hoạt_hwecc

Hàm này được gọi trước khi đọc/ghi vào chip. Đặt lại
   hoặc khởi tạo trình tạo phần cứng trong chức năng này. chức năng
   được gọi với một đối số cho phép bạn phân biệt giữa đọc và
   thao tác ghi.

- tính toán_ecc

Hàm này được gọi sau khi đọc/ghi từ/vào chip.
   Chuyển ECC từ phần cứng sang bộ đệm. Nếu tùy chọn
   NAND_HWECC_SYNDROME được đặt thì chức năng chỉ được gọi
   viết. Xem bên dưới.

- đúng_data

Trong trường hợp có lỗi ECC, chức năng này được gọi để phát hiện lỗi
   và sửa chữa. Trả về 1 tương ứng 2 trong trường hợp lỗi có thể xảy ra
   đã sửa. Nếu lỗi không thể sửa được thì trả về -1. Nếu bạn
   trình tạo phần cứng khớp với thuật toán mặc định của nand_ecc
   trình tạo phần mềm sau đó sử dụng chức năng chỉnh sửa được cung cấp bởi
   nand_ecc thay vì triển khai mã trùng lặp.

Phần cứng ECC với tính toán hội chứng
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Nhiều triển khai ECC phần cứng cung cấp mã Reed-Solomon và
tính toán hội chứng lỗi khi đọc. Hội chứng phải được chuyển đổi thành một
hội chứng Reed-Solomon chuẩn trước khi gọi mã sửa lỗi
trong thư viện Reed-Solomon chung.

Các byte ECC phải được đặt ngay sau các byte dữ liệu theo thứ tự
để làm cho máy tạo hội chứng hoạt động. Điều này trái ngược với thông thường
bố cục được sử dụng bởi phần mềm ECC. Việc tách dữ liệu và ra khỏi vùng băng tần
không còn có thể nữa. Mã trình điều khiển nand xử lý bố cục này và
Các byte trống còn lại trong vùng oob được quản lý bởi tính năng tự động sắp xếp
mã. Cung cấp bố cục oob phù hợp trong trường hợp này. Xem rts_from4.c và
diskonchip.c để tham khảo triển khai. Trong những trường hợp đó chúng ta cũng phải
sử dụng các bảng khối xấu trên FLASH, vì bố cục ECC đang gây trở ngại
với các vị trí đánh dấu khối xấu. Xem hỗ trợ bảng khối xấu cho
chi tiết.

Hỗ trợ bảng khối xấu
-----------------------

Hầu hết các chip NAND đều đánh dấu các khối xấu tại một vị trí xác định trong khối dự phòng
khu vực. Những khối đó không được xóa trong bất kỳ trường hợp nào vì điều xấu
thông tin khối sẽ bị mất. Có thể kiểm tra khối xấu
đánh dấu mỗi lần truy cập các khối bằng cách đọc diện tích dự phòng của
trang đầu tiên trong khối. Việc này tốn thời gian nên bảng khối xấu
được sử dụng.

Trình điều khiển nand hỗ trợ nhiều loại bảng khối xấu khác nhau.

- Mỗi thiết bị

Bảng bad block chứa toàn bộ thông tin bad block của thiết bị
   có thể bao gồm nhiều chip.

- Mỗi chip

Bảng khối xấu được sử dụng trên mỗi chip và chứa khối xấu
   thông tin cho con chip đặc biệt này.

- Bù đắp cố định

Bảng bad block nằm ở vị trí offset cố định trong chip
   (thiết bị). Điều này áp dụng cho các thiết bị DiskOnChip khác nhau.

- Tự động đặt

Bảng khối xấu được tự động đặt và phát hiện tại
   ở cuối hoặc ở đầu chip (thiết bị)

- Bàn có gương

Bảng khối xấu được phản chiếu trên chip (thiết bị) để cho phép cập nhật
   của bảng khối xấu mà không mất dữ liệu.

nand_scan() gọi hàm nand_default_bbt().
nand_default_bbt() chọn bảng khối xấu mặc định thích hợp
mô tả tùy thuộc vào thông tin chip được truy xuất bởi
nand_scan().

Chính sách tiêu chuẩn là quét thiết bị để tìm các khối xấu và xây dựng một
bảng khối xấu dựa trên ram cho phép truy cập nhanh hơn mọi khi
kiểm tra thông tin khối xấu trên chính chip flash.

Bảng dựa trên flash
~~~~~~~~~~~~~~~~~~

Có thể mong muốn hoặc cần thiết phải giữ một bảng khối xấu trong FLASH. cho
Chip AG-AND điều này là bắt buộc vì chúng không có dấu hiệu xấu của nhà máy
khối. Họ có nhà máy đánh dấu các khối tốt. Mẫu đánh dấu là
bị xóa khi khối bị xóa để sử dụng lại. Vì vậy trong trường hợp mất điện
trước khi ghi mẫu trở lại chip, khối này sẽ bị mất và
được thêm vào các khối xấu. Vì vậy, chúng tôi quét (các) chip khi phát hiện
chúng lần đầu tiên đối với các khối tốt và lưu trữ thông tin này ở trạng thái xấu
bảng khối trước khi xóa bất kỳ khối nào.

Các khối trong đó các bảng được lưu trữ được bảo vệ chống lại
truy cập ngẫu nhiên bằng cách đánh dấu chúng là xấu trong bảng khối bộ nhớ xấu. các
chức năng quản lý bảng khối xấu được phép phá vỡ điều này
bảo vệ.

Cách đơn giản nhất để kích hoạt hỗ trợ bảng khối xấu dựa trên FLASH là
để đặt tùy chọn NAND_BBT_USE_FLASH trong trường bbt_option của
cấu trúc chip nand trước khi gọi nand_scan(). Đối với chip AG-AND là
điều này được thực hiện theo mặc định. Điều này kích hoạt khối xấu dựa trên FLASH mặc định
chức năng bảng của trình điều khiển NAND. Bảng khối xấu mặc định
tùy chọn là

- Lưu trữ bảng khối xấu trên mỗi chip

- Sử dụng 2 bit cho mỗi khối

- Tự động đặt ở cuối chip

- Sử dụng các bảng được nhân đôi với số phiên bản

- Dự trữ 4 khối ở cuối chip

Bảng do người dùng xác định
~~~~~~~~~~~~~~~~~~~

Các bảng do người dùng xác định được tạo bằng cách điền vào nand_bbt_descr
cấu trúc và lưu trữ con trỏ trong thành viên cấu trúc nand_chip
bbt_td trước khi gọi nand_scan(). Nếu cần một chiếc bàn gương
Cấu trúc thứ hai phải được tạo và một con trỏ tới cấu trúc này phải được
được lưu trữ trong bbt_md bên trong cấu trúc nand_chip. Nếu thành viên bbt_md
được đặt thành NULL thì chỉ bảng chính được sử dụng và không quét tìm
bảng nhân đôi được thực hiện.

Trường quan trọng nhất trong cấu trúc nand_bbt_descr là
trường tùy chọn. Các tùy chọn xác định hầu hết các thuộc tính của bảng. Sử dụng
các hằng số được xác định trước từ rawnand.h để xác định các tùy chọn.

- Số bit trên mỗi khối

Số bit được hỗ trợ là 1, 2, 4, 8.

- Bảng trên mỗi chip

Đặt hằng số NAND_BBT_PERCHIP sẽ chọn khối xấu
   bảng được quản lý cho từng chip trong mảng chip. Nếu tùy chọn này không
   được thiết lập thì bảng khối xấu cho mỗi thiết bị sẽ được sử dụng.

- Vị trí bảng là tuyệt đối

Sử dụng hằng số tùy chọn NAND_BBT_ABSPAGE và xác định giá trị tuyệt đối
   số trang nơi bảng khối xấu bắt đầu trong các trang trường. Nếu
   bạn đã chọn các bảng khối xấu trên mỗi chip và bạn có nhiều chip
   mảng thì trang bắt đầu phải được cung cấp cho mỗi chip trong chip
   mảng. Lưu ý: không có quá trình quét mẫu nhận dạng bảng nào được thực hiện, vì vậy
   mẫu trường, veroffs, offs, len có thể không được khởi tạo

- Vị trí bảng được tự động phát hiện

Bảng có thể được đặt ở khối tốt đầu tiên hoặc khối tốt cuối cùng
   của chip (thiết bị). Đặt NAND_BBT_LASTBLOCK để đặt khối xấu
   bảng ở cuối chip (thiết bị). Các bảng khối xấu là
   được đánh dấu và xác định bằng mẫu được lưu trữ trong khu vực dự phòng
   của trang đầu tiên trong khối chứa bảng khối xấu. cửa hàng
   một con trỏ tới mẫu trong trường mẫu. Hơn nữa chiều dài của
   mẫu phải được lưu trong len và phần bù trong vùng dự phòng
   phải được đưa vào thành phần offs của cấu trúc nand_bbt_descr.
   Đối với các bảng khối xấu được phản chiếu, các mẫu khác nhau là bắt buộc.

- Tạo bảng

Đặt tùy chọn NAND_BBT_CREATE để cho phép tạo bảng nếu không
   bảng có thể được tìm thấy trong quá trình quét. Thông thường việc này chỉ được thực hiện một lần nếu
   một con chip mới được tìm thấy.

- Hỗ trợ ghi bảng

Đặt tùy chọn NAND_BBT_WRITE để bật hỗ trợ ghi bảng.
   Điều này cho phép cập nhật (các) bảng khối xấu trong trường hợp một khối có
   bị đánh dấu là xấu do bị mòn. Chức năng giao diện MTD
   block_markbad đang gọi hàm cập nhật của bảng khối xấu.
   Nếu hỗ trợ ghi được bật thì bảng sẽ được cập nhật trên FLASH.

Lưu ý: Chỉ nên bật hỗ trợ ghi cho các bảng được phản chiếu với
   kiểm soát phiên bản.

- Kiểm soát phiên bản bảng

Đặt tùy chọn NAND_BBT_VERSION để bật phiên bản bảng
   kiểm soát. Bạn nên kích hoạt tính năng này cho các bảng được phản chiếu
   với sự hỗ trợ viết. Nó đảm bảo rằng nguy cơ mất đi cái xấu
   thông tin bảng khối bị giảm đến mức mất thông tin
   về một khối bị mòn cần được đánh dấu là xấu. Phiên bản
   được lưu trữ trong 4 byte liên tiếp trong vùng dự phòng của thiết bị. các
   vị trí của số phiên bản được xác định bởi các thành viên xác minh trong
   bộ mô tả bảng khối xấu.

- Lưu nội dung khối khi ghi

Trong trường hợp khối chứa bảng khối xấu có chứa
   thông tin hữu ích khác, hãy đặt tùy chọn NAND_BBT_SAVECONTENT. Khi nào
   bảng khối xấu được viết sau đó toàn bộ khối được đọc xấu
   bảng khối được cập nhật và khối bị xóa và mọi thứ đều ổn
   được viết lại. Nếu tùy chọn này không được thiết lập thì chỉ có bảng khối xấu bị
   được viết và mọi thứ khác trong khối sẽ bị bỏ qua và xóa.

- Số khối dành riêng

Đối với vị trí tự động, một số khối phải được dành riêng cho khối xấu
   lưu trữ bảng. Số lượng khối dành riêng được xác định trong
   thành viên maxblocks của cấu trúc mô tả bảng khối xấu.
   Đặt 4 khối cho các bảng được nhân đôi phải là một con số hợp lý.
   Điều này cũng giới hạn số lượng khối được quét để phát hiện lỗi xấu.
   mẫu nhận dạng bảng khối.

Vị trí khu vực dự phòng (tự động)
--------------------------

Trình điều khiển nand thực hiện các khả năng khác nhau để đặt vị trí của
dữ liệu hệ thống tập tin trong khu vực dự phòng,

- Vị trí được xác định bởi trình điều khiển fs

- Vị trí tự động

Chức năng vị trí mặc định là vị trí tự động. Trình điều khiển nand
đã xây dựng các sơ đồ vị trí mặc định cho các loại chip khác nhau. Nếu đến hạn
đối với chức năng ECC của phần cứng thì vị trí mặc định không phù hợp
người điều khiển bảng có thể cung cấp một sơ đồ vị trí riêng.

Trình điều khiển hệ thống tệp có thể cung cấp sơ đồ vị trí riêng được sử dụng
thay vì sơ đồ vị trí mặc định.

Sơ đồ vị trí được xác định bởi cấu trúc nand_oobinfo

::

cấu trúc nand_oobinfo {
        int useecc;
        int eccbyte;
        int eccpos[24];
        int oobfree[8][2];
    };


- useecc

Thành viên useecc kiểm soát chức năng ecc và vị trí. Tiêu đề
   tệp include/mtd/mtd-abi.h chứa các hằng số để chọn ecc và
   vị trí. MTD_NANDECC_OFF tắt ecc hoàn tất. Đây là
   không được khuyến khích và chỉ có sẵn để thử nghiệm và chẩn đoán.
   MTD_NANDECC_PLACE chọn vị trí do người gọi xác định,
   MTD_NANDECC_AUTOPLACE chọn vị trí tự động.

- eccbyte

Thành viên eccbytes xác định số byte ecc trên mỗi trang.

- eccpos

Mảng eccpos giữ các byte offset trong vùng dự phòng nơi
   mã ecc được đặt.

- ồ miễn phí

Mảng oobfree xác định các khu vực trong khu vực dự phòng có thể được
   được sử dụng để sắp xếp tự động. Thông tin được đưa ra dưới dạng
   {bù đắp, kích thước}. offset xác định điểm bắt đầu của vùng có thể sử dụng, kích thước của
   độ dài tính bằng byte. Nhiều hơn một khu vực có thể được xác định. Danh sách là
   được kết thúc bằng mục nhập {0, 0}.

Vị trí được xác định bởi trình điều khiển fs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Hàm gọi cung cấp một con trỏ tới cấu trúc nand_oobinfo
trong đó xác định vị trí ecc. Để ghi, người gọi phải cung cấp một
vùng đệm dự phòng cùng với vùng đệm dữ liệu. Kích thước vùng đệm dự phòng
là (số trang) \* (kích thước của vùng dự phòng). Để đọc kích thước bộ đệm
là (số trang) \* ((kích thước của vùng dự phòng) + (số bước ecc trên mỗi
trang) \* sizeof (int)). Trình điều khiển lưu kết quả kiểm tra ecc
cho mỗi bộ dữ liệu trong bộ đệm dự phòng. Trình tự lưu trữ là::

<trang dữ liệu dự phòng 0><kết quả ecc 0>...<kết quả ecc n>

	...

<trang dữ liệu dự phòng n><ecc kết quả 0>...<ecc kết quả n>

Đây là chế độ cũ được YAFFS1 sử dụng.

Nếu vùng đệm dự phòng là NULL thì chỉ việc đặt ECC được thực hiện
theo sơ đồ đã cho trong cấu trúc nand_oobinfo.

Vị trí tự động
~~~~~~~~~~~~~~~~~~~

Vị trí tự động sử dụng các giá trị mặc định được tích hợp sẵn để đặt các byte ecc vào
khu vực dự phòng. Nếu dữ liệu hệ thống tập tin phải được lưu trữ/đọc vào
khu vực dự phòng thì chức năng gọi phải cung cấp bộ đệm. Bộ đệm
kích thước trên mỗi trang được xác định bởi mảng oobfree trong nand_oobinfo
cấu trúc.

Nếu vùng đệm dự phòng là NULL thì chỉ việc đặt ECC được thực hiện
theo sơ đồ dựng sẵn mặc định.

Các sơ đồ mặc định về vị trí tự động của khu vực dự phòng
----------------------------------------

Kích thước trang 256 byte
~~~~~~~~~~~~~~~~~

===================================================================================
Bình luận nội dung bù đắp
===================================================================================
0x00 ECC byte 0 Mã sửa lỗi byte 0
0x01 ECC byte 1 Mã sửa lỗi byte 1
0x02 ECC byte 2 Mã sửa lỗi byte 2
0x03 Tự động đặt 0
0x04 Tự động 1
0x05 Điểm đánh dấu khối xấu Nếu bất kỳ bit nào trong byte này bằng 0 thì điều này
			    khối là xấu. Điều này chỉ áp dụng cho lần đầu tiên
			    trang trong một khối. Trong các trang còn lại, điều này
			    byte được bảo lưu
0x06 Tự động 2
0x07 Tự động 3
===================================================================================

Kích thước trang 512 byte
~~~~~~~~~~~~~~~~~


============== =====================================================================
Bình luận nội dung bù đắp
============== =====================================================================
0x00 ECC byte 0 Mã sửa lỗi byte 0 của giá trị thấp hơn
				 Dữ liệu 256 byte trong trang này
0x01 ECC byte 1 Mã sửa lỗi byte 1 của byte thấp hơn
				 256 byte dữ liệu trong trang này
0x02 ECC byte 2 Mã sửa lỗi byte 2 của mức thấp hơn
				 256 byte dữ liệu trong trang này
0x03 ECC byte 3 Mã sửa lỗi byte 0 của phần trên
				 256 byte dữ liệu trong trang này
0x04 dành riêng dành riêng
0x05 Điểm đánh dấu khối xấu Nếu bất kỳ bit nào trong byte này bằng 0 thì điều này
				 khối là xấu. Điều này chỉ áp dụng cho lần đầu tiên
				 trang trong một khối. Trong các trang còn lại, điều này
				 byte được bảo lưu
0x06 ECC byte 4 Mã sửa lỗi byte 1 của phần trên
				 256 byte dữ liệu trong trang này
0x07 ECC byte 5 Mã sửa lỗi byte 2 của phần trên
				 256 byte dữ liệu trong trang này
0x08 - 0x0F Tự động đặt 0 - 7
============== =====================================================================

Kích thước trang 2048 byte
~~~~~~~~~~~~~~~~~~

============ ========================================================================
Bình luận nội dung bù đắp
============ ========================================================================
0x00 Điểm đánh dấu khối xấu Nếu bất kỳ bit nào trong byte này bằng 0 thì khối này
			       là xấu. Điều này chỉ áp dụng cho trang đầu tiên trong một
			       khối. Trong các trang còn lại byte này là
			       dành riêng
0x01 Dành riêng Dành riêng
0x02-0x27 Tự động đặt 0 - 37
0x28 ECC byte 0 Mã sửa lỗi byte 0 của byte đầu tiên
			       Dữ liệu 256 byte trong trang này
0x29 ECC byte 1 Mã sửa lỗi byte 1 của byte đầu tiên
			       256 byte dữ liệu trong trang này
0x2A ECC byte 2 Mã sửa lỗi byte 2 của byte đầu tiên
			       Dữ liệu 256 byte trong trang này
0x2B ECC byte 3 Mã sửa lỗi byte 0 của giây
			       256 byte dữ liệu trong trang này
0x2C ECC byte 4 Mã sửa lỗi byte 1 của giây
			       256 byte dữ liệu trong trang này
0x2D ECC byte 5 Mã sửa lỗi byte 2 của giây
			       256 byte dữ liệu trong trang này
0x2E ECC byte 6 Mã sửa lỗi byte 0 của byte thứ ba
			       256 byte dữ liệu trong trang này
0x2F ECC byte 7 Mã sửa lỗi byte 1 của thứ ba
			       256 byte dữ liệu trong trang này
0x30 ECC byte 8 Mã sửa lỗi byte 2 của thứ ba
			       256 byte dữ liệu trong trang này
0x31 ECC byte 9 Mã sửa lỗi byte 0 của thứ tư
			       256 byte dữ liệu trong trang này
0x32 ECC byte 10 Mã sửa lỗi byte 1 của thứ tư
			       256 byte dữ liệu trong trang này
0x33 ECC byte 11 Mã sửa lỗi byte 2 của thứ tư
			       256 byte dữ liệu trong trang này
0x34 ECC byte 12 Mã sửa lỗi byte 0 của thứ năm
			       256 byte dữ liệu trong trang này
0x35 ECC byte 13 Mã sửa lỗi byte 1 của thứ năm
			       256 byte dữ liệu trong trang này
0x36 ECC byte 14 Mã sửa lỗi byte 2 của thứ năm
			       256 byte dữ liệu trong trang này
0x37 ECC byte 15 Mã sửa lỗi byte 0 của thứ sáu
			       256 byte dữ liệu trong trang này
0x38 ECC byte 16 Mã sửa lỗi byte 1 của thứ sáu
			       256 byte dữ liệu trong trang này
0x39 ECC byte 17 Mã sửa lỗi byte 2 của thứ sáu
			       256 byte dữ liệu trong trang này
0x3A ECC byte 18 Mã sửa lỗi byte 0 của thứ bảy
			       256 byte dữ liệu trong trang này
0x3B ECC byte 19 Mã sửa lỗi byte 1 của thứ bảy
			       256 byte dữ liệu trong trang này
0x3C ECC byte 20 Mã sửa lỗi byte 2 của thứ bảy
			       256 byte dữ liệu trong trang này
0x3D ECC byte 21 Mã sửa lỗi byte 0 của phần tám
			       256 byte dữ liệu trong trang này
0x3E ECC byte 22 Mã sửa lỗi byte 1 của phần tám
			       256 byte dữ liệu trong trang này
0x3F ECC byte 23 Mã sửa lỗi byte 2 của phần tám
			       256 byte dữ liệu trong trang này
============ ========================================================================

Hỗ trợ hệ thống tập tin
==================

Trình điều khiển NAND cung cấp tất cả các chức năng cần thiết cho hệ thống tệp thông qua
giao diện MTD.

Các hệ thống tập tin phải nhận thức được các đặc thù và hạn chế của NAND.
Một hạn chế lớn của NAND Flash là bạn không thể viết thường xuyên
như bạn muốn vào một trang. Viết liên tiếp vào một trang, trước khi xóa
một lần nữa, bị giới hạn ở mức 1-3 lần ghi, tùy thuộc vào nhà sản xuất
thông số kỹ thuật. Điều này áp dụng tương tự với diện tích dự phòng.

Do đó, các hệ thống tệp nhận biết NAND phải ghi theo từng đoạn kích thước trang
hoặc giữ một bộ đệm ghi để thu thập các lần ghi nhỏ hơn cho đến khi chúng tổng hợp thành
pageize. Các hệ thống tập tin nhận biết NAND có sẵn: JFFS2, YAFFS.

Việc sử dụng vùng dự phòng để lưu trữ dữ liệu hệ thống tập tin được kiểm soát bởi vùng dự phòng
chức năng bố trí khu vực được mô tả ở một trong những phần trước đó
chương.

Công cụ
=====

Dự án MTD cung cấp một số công cụ hữu ích để xử lý NAND Flash.

- flasherase, flasheraseall: Xóa và định dạng phân vùng FLASH

- nandwrite: ghi hình ảnh hệ thống tập tin vào NAND FLASH

- nanddump: kết xuất nội dung của phân vùng NAND FLASH

Những công cụ này nhận thức được các hạn chế của NAND. Hãy sử dụng những công cụ đó
thay vì phàn nàn về những lỗi do người không biết về NAND gây ra
các phương pháp truy cập.

Hằng số
=========

Chương này mô tả các hằng số có thể liên quan đến một
nhà phát triển trình điều khiển.

Hằng số tùy chọn chip
---------------------

Các hằng số cho bảng id chip
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Các hằng số này được định nghĩa trong rawand.h. Chúng được OR-ed cùng nhau để
mô tả chức năng của chip::

/* Buswitdh là 16 bit */
    #define NAND_BUSWIDTH_16 0x00000002
    /* Thiết bị hỗ trợ lập trình một phần mà không cần đệm */
    #define NAND_NO_PADDING 0x00000004
    /* Chip có chức năng lập trình cache */
    #define NAND_CACHEPRG 0x00000008
    /* Chip có chức năng sao chép lại */
    #define NAND_COPYBACK 0x00000010
    /* Chip AND có 4 ngân hàng và trang / khối khó hiểu
     * nhiệm vụ. Xem bảng dữ liệu Renesas để biết thêm thông tin */
    #define NAND_IS_AND 0x00000020
    /* Chip có một mảng gồm 4 trang có thể đọc được mà không cần
     * sẵn sàng bổ sung / chờ bận */
    #define NAND_4PAGE_ARRAY 0x00000040


Các hằng số cho các tùy chọn thời gian chạy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Các hằng số này được định nghĩa trong rawand.h. Chúng được OR-ed cùng nhau để
mô tả chức năng::

/* Trình tạo hw ecc cung cấp một hội chứng thay vì giá trị ecc khi đọc
     * Điều này chỉ có thể hoạt động nếu chúng ta có các byte ecc ngay phía sau
     * byte dữ liệu. Áp dụng cho máy phát điện DOC và AG-AND Renesas HW Reed Solomon */
    #define NAND_HWECC_SYNDROME 0x00020000


Hằng số lựa chọn ECC
-----------------------

Sử dụng các hằng số này để chọn thuật toán ECC::

/* Không có ECC. Việc sử dụng không được khuyến khích! */
    #define NAND_ECC_NONE 0
    /* Phần mềm ECC 3 byte ECC trên mỗi dữ liệu 256 Byte */
    #define NAND_ECC_SOFT 1
    /* Phần cứng ECC 3 byte ECC trên mỗi dữ liệu 256 Byte */
    #define NAND_ECC_HW3_256 2
    /* Phần cứng ECC 3 byte ECC trên mỗi dữ liệu 512 Byte */
    #define NAND_ECC_HW3_512 3
    /* Phần cứng ECC 6 byte ECC trên mỗi dữ liệu 512 Byte */
    #define NAND_ECC_HW6_512 4
    /* Phần cứng ECC 8 byte ECC trên mỗi dữ liệu 512 Byte */
    #define NAND_ECC_HW8_512 6


Các hằng số liên quan đến điều khiển phần cứng
----------------------------------

Các hằng số này mô tả chức năng truy cập phần cứng được yêu cầu khi
Chức năng điều khiển phần cứng cụ thể của bo mạch được gọi là::

/* Chọn chip bằng cách đặt nCE ở mức thấp */
    #define NAND_CTL_SETNCE 1
    /* Bỏ chọn chip bằng cách đặt nCE ở mức cao */
    #define NAND_CTL_CLRNCE 2
    /* Chọn chốt lệnh bằng cách đặt CLE ở mức cao */
    #define NAND_CTL_SETCLE 3
    /* Bỏ chọn chốt lệnh bằng cách đặt CLE ở mức thấp */
    #define NAND_CTL_CLRCLE 4
    /* Chọn chốt địa chỉ bằng cách đặt ALE ở mức cao */
    #define NAND_CTL_SETALE 5
    /* Bỏ chọn chốt địa chỉ bằng cách đặt ALE ở mức thấp */
    #define NAND_CTL_CLRALE 6
    /* Đặt bảo vệ ghi bằng cách đặt WP ở mức cao. Không được sử dụng! */
    #define NAND_CTL_SETWP 7
    /* Xóa chức năng bảo vệ ghi bằng cách đặt WP ở mức thấp. Không được sử dụng! */
    #define NAND_CTL_CLRWP 8


Các hằng số liên quan đến bảng khối xấu
---------------------------------

Các hằng số này mô tả các tùy chọn được sử dụng cho bảng khối xấu
mô tả::

/* Tùy chọn cho bộ mô tả bảng khối xấu */

/* Số bit được sử dụng trên mỗi khối trong bbt trên thiết bị */
    #define NAND_BBT_NRBITS_MSK 0x0000000F
    #define NAND_BBT_1BIT 0x00000001
    #define NAND_BBT_2BIT 0x00000002
    #define NAND_BBT_4BIT 0x00000004
    #define NAND_BBT_8BIT 0x00000008
    /* Bảng khối xấu nằm trong khối tốt cuối cùng của thiết bị */
    #define NAND_BBT_LASTBLOCK 0x00000010
    /* bbt nằm ở trang đã cho, nếu không chúng ta phải quét tìm bbt */
    #define NAND_BBT_ABSPAGE 0x00000020
    /* bbt được lưu trữ trên mỗi chip trên các thiết bị nhiều chip */
    #define NAND_BBT_PERCHIP 0x00000080
    /* bbt có bộ đếm phiên bản tại offset veroffs */
    #define NAND_BBT_VERSION 0x00000100
    /* Tạo một bbt nếu không có trục nào */
    #define NAND_BBT_CREATE 0x00000200
    /*Viết bbt nếu cần */
    #define NAND_BBT_WRITE 0x00001000
    /* Đọc và ghi lại nội dung khối khi viết bbt */
    #define NAND_BBT_SAVECONTENT 0x00002000


Cấu trúc
==========

Chương này chứa tài liệu được tạo tự động của các cấu trúc
được sử dụng trong trình điều khiển NAND và có thể phù hợp với trình điều khiển
nhà phát triển. Mỗi thành viên cấu trúc có một mô tả ngắn được đánh dấu
với mã định danh [XXX]. Xem chương "Gợi ý tài liệu" để biết
lời giải thích.

.. kernel-doc:: include/linux/mtd/rawnand.h
   :internal:

Chức năng công cộng được cung cấp
=========================

Chương này chứa tài liệu được tạo tự động của kernel NAND
Các hàm API được xuất. Mỗi chức năng có một mô tả ngắn
được đánh dấu bằng mã định danh [XXX]. Xem chương “Tài liệu
gợi ý" để được giải thích.

.. kernel-doc:: drivers/mtd/nand/raw/nand_base.c
   :export:

Chức năng nội bộ được cung cấp
===========================

Chương này chứa tài liệu được tạo tự động của trình điều khiển NAND
các chức năng nội tại. Mỗi chức năng có một mô tả ngắn gọn
được đánh dấu bằng mã định danh [XXX]. Xem chương "Gợi ý tài liệu"
để có lời giải thích. Các chức năng được đánh dấu bằng [DEFAULT] có thể
có liên quan cho một nhà phát triển trình điều khiển bảng.

.. kernel-doc:: drivers/mtd/nand/raw/nand_base.c
   :internal:

.. kernel-doc:: drivers/mtd/nand/raw/nand_bbt.c
   :internal:

Tín dụng
=======

Những người sau đây đã đóng góp cho trình điều khiển NAND:

1. Steven J. Hill\ sjhill@realitydiluted.com

2. David Woodhouse\ dwmw2@infradead.org

3. Thomas Gleixner\ tglx@kernel.org

Rất nhiều người dùng đã cung cấp các bản sửa lỗi, cải tiến và giúp đỡ
để thử nghiệm. Cảm ơn rất nhiều.

Những người sau đây đã đóng góp cho tài liệu này:

1. Thomas Gleixner\ tglx@kernel.org
