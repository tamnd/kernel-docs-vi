.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/mtrr.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================================
Điều khiển MTRR (Thanh ghi phạm vi loại bộ nhớ)
===============================================

:Tác giả: - Richard Gooch <rgooch@atnf.csiro.au> - 3 tháng 6 năm 1999
          - Luis R. Rodriguez <mcgrof@do-not-panic.com> - Ngày 9 tháng 4 năm 2015


Loại bỏ dần việc sử dụng MTRR
=============================

Việc sử dụng MTRR được thay thế trên phần cứng x86 hiện đại bằng PAT. Sử dụng trực tiếp MTRR bởi
trình điều khiển trên Linux hiện đã bị loại bỏ hoàn toàn, trình điều khiển thiết bị nên sử dụng
Arch_phys_wc_add() kết hợp với ioremap_wc() để tạo hiệu quả cho MTRR trên
các hệ thống không phải PAT trong khi không hoạt động nhưng hiệu quả không kém trên các hệ thống hỗ trợ PAT.

Ngay cả khi Linux không sử dụng MTRR trực tiếp, một số chương trình cơ sở nền tảng x86 vẫn có thể
thiết lập MTRR sớm trước khi khởi động HĐH. Họ làm điều này như một nền tảng
chương trình cơ sở có thể vẫn đã triển khai quyền truy cập vào MTRR sẽ được kiểm soát
và được xử lý trực tiếp bởi phần mềm nền tảng. Một ví dụ về việc sử dụng nền tảng của
MTRR thông qua việc sử dụng bộ xử lý SMI, một trường hợp có thể dùng để điều khiển quạt,
mã nền tảng sẽ cần quyền truy cập không thể lưu vào bộ nhớ đệm vào một số tính năng điều khiển quạt của nó
sổ đăng ký. Việc truy cập nền tảng như vậy không cần bất kỳ mã MTRR của Hệ điều hành nào trong
địa điểm khác ngoài mtrr_type_lookup() để đảm bảo mọi yêu cầu ánh xạ cụ thể của hệ điều hành
được căn chỉnh với thiết lập nền tảng MTRR. Nếu MTRR chỉ được thiết lập bởi nền tảng
mã chương trình cơ sở và hệ điều hành không tạo bất kỳ ánh xạ MTRR cụ thể nào
yêu cầu mtrr_type_lookup() phải luôn trả về MTRR_TYPE_INVALID.

Để biết chi tiết, hãy tham khảo Tài liệu/arch/x86/pat.rst.

.. tip::
  On Intel P6 family processors (Pentium Pro, Pentium II and later)
  the Memory Type Range Registers (MTRRs) may be used to control
  processor access to memory ranges. This is most useful when you have
  a video (VGA) card on a PCI or AGP bus. Enabling write-combining
  allows bus write transfers to be combined into a larger transfer
  before bursting over the PCI/AGP bus. This can increase performance
  of image write operations 2.5 times or more.

  The Cyrix 6x86, 6x86MX and M II processors have Address Range
  Registers (ARRs) which provide a similar functionality to MTRRs. For
  these, the ARRs are used to emulate the MTRRs.

  The AMD K6-2 (stepping 8 and above) and K6-3 processors have two
  MTRRs. These are supported.  The AMD Athlon family provide 8 Intel
  style MTRRs.

  The Centaur C6 (WinChip) has 8 MCRs, allowing write-combining. These
  are supported.

  The VIA Cyrix III and VIA C3 CPUs offer 8 Intel style MTRRs.

  The CONFIG_MTRR option creates a /proc/mtrr file which may be used
  to manipulate your MTRRs. Typically the X server should use
  this. This should have a reasonably generic interface so that
  similar control registers on other processors can be easily
  supported.

Có hai giao diện cho /proc/mtrr: một là giao diện ASCII
cho phép bạn đọc và viết. Cái còn lại là ioctl()
giao diện. Giao diện ASCII dành cho quản trị. các
Giao diện ioctl() dành cho các chương trình C (tức là máy chủ X). các
giao diện được mô tả dưới đây, với các lệnh mẫu và mã C.


Đọc MTRR từ shell
============================
::

% mèo /proc/mtrr
  reg00: base=0x00000000 ( 0MB), size= 128MB: ghi lại, đếm=1
  reg01: base=0x08000000 ( 128MB), size= 64MB: ghi lại, đếm=1

Tạo MTRR từ C-shell::

# echo "cơ sở=0xf8000000 kích thước=0x400000 loại=kết hợp ghi" >! /proc/mtrr

hoặc nếu bạn sử dụng bash ::

# echo "cơ sở=0xf8000000 kích thước=0x400000 loại=kết hợp ghi" >| /proc/mtrr

Và kết quả của nó::

% mèo /proc/mtrr
  reg00: base=0x00000000 ( 0MB), size= 128MB: ghi lại, đếm=1
  reg01: base=0x08000000 ( 128MB), size= 64MB: ghi lại, đếm=1
  reg02: base=0xf8000000 (3968MB), size= 4MB: ghi kết hợp, đếm=1

Cái này dành cho video RAM ở địa chỉ cơ sở 0xf8000000 và kích thước 4 megabyte. Đến
tìm ra địa chỉ cơ sở của bạn, bạn cần xem đầu ra của X
máy chủ, cho bạn biết địa chỉ bộ đệm khung tuyến tính ở đâu. A
dòng điển hình mà bạn có thể nhận được là::

(--) S3: PCI: 968 vòng 0, FB tuyến tính @ 0xf8000000

Lưu ý rằng bạn chỉ nên sử dụng giá trị từ máy chủ X, vì nó có thể
di chuyển địa chỉ cơ sở của bộ đệm khung, vì vậy giá trị duy nhất bạn có thể tin cậy là
được báo cáo bởi máy chủ X.

Để tìm ra kích thước của bộ đệm khung của bạn (bạn thực sự không
biết không?), dòng sau sẽ cho bạn biết::

(--) S3: videoram: 4096k

Đó là 4 megabyte, tức là 0x400000 byte (theo hệ thập lục phân).
Một bản vá đang được viết cho XFree86 sẽ thực hiện việc này tự động:
nói cách khác, máy chủ X sẽ thao tác /proc/mtrr bằng cách sử dụng
ioctl() nên người dùng sẽ không phải làm gì cả. Nếu bạn sử dụng một
máy chủ X thương mại, hãy vận động nhà cung cấp của bạn thêm hỗ trợ cho MTRR.


Tạo MTRR chồng chéo
==========================
::

%echo "base=0xfb000000 size=0x1000000 type=write-kết hợp" >/proc/mtrr
  %echo "base=0xfb000000 size=0x1000 type=uncachable" >/proc/mtrr

Và kết quả::

% mèo /proc/mtrr
  reg00: base=0x00000000 ( 0MB), size= 64MB: ghi lại, đếm=1
  reg01: base=0xfb000000 (4016MB), size= 16MB: ghi kết hợp, đếm=1
  reg02: base=0xfb000000 (4016MB), size= 4kB: không thể lưu vào bộ nhớ đệm, count=1

Một số card (đặc biệt là bo mạch đồ họa Voodoo) cần vùng 4 kB này
bị loại trừ khỏi phần đầu của khu vực vì nó được sử dụng cho
sổ đăng ký.

NOTE: Bạn chỉ có thể tạo vùng loại=không thể lưu vào bộ nhớ đệm, nếu vùng đầu tiên
vùng mà bạn đã tạo là type=write-kết hợp.


Loại bỏ MTRR khỏi C-shel
==============================
::

% echo "vô hiệu hóa=2" >! /proc/mtrr

hoặc sử dụng bash::

% echo "vô hiệu hóa=2" >| /proc/mtrr


Đọc MTRR từ chương trình C bằng ioctl()'s
==============================================
::

/* mtrr-show.c

Tệp nguồn cho mtrr-show (chương trình ví dụ để hiển thị MTRR bằng cách sử dụng ioctl()'s)

Bản quyền (C) 1997-1998 Richard Gooch

Chương trình này là phần mềm miễn phí; bạn có thể phân phối lại nó và/hoặc sửa đổi
      nó theo các điều khoản của Giấy phép Công cộng GNU được xuất bản bởi
      Tổ chức Phần mềm Tự do; phiên bản 2 của Giấy phép, hoặc
      (theo lựa chọn của bạn) bất kỳ phiên bản mới hơn.

Chương trình này được phân phối với hy vọng rằng nó sẽ hữu ích,
      nhưng WITHOUT ANY WARRANTY; thậm chí không có sự bảo đảm ngụ ý của
      MERCHANTABILITY hoặc FITNESS FOR A PARTICULAR PURPOSE.  Xem
      Giấy phép Công cộng GNU để biết thêm chi tiết.

Bạn hẳn đã nhận được một bản sao Giấy phép Công cộng GNU
      cùng với chương trình này; nếu không, hãy viết thư cho Phần mềm miễn phí
      Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

Có thể liên hệ với Richard Gooch qua email tại rgooch@atnf.csiro.au
      Địa chỉ bưu chính là:
        Richard Gooch, c/o ATNF, P. O. Box 76, Epping, N.S.W., 2121, Australia.
  */

/*
      Chương trình này sẽ sử dụng ioctl() trên /proc/mtrr để hiển thị MTRR hiện tại
      cài đặt. Đây là một cách thay thế cho việc đọc /proc/mtrr.


Viết bởi Richard Gooch 17-DEC-1997

Cập nhật lần cuối bởi Richard Gooch 2-MAY-1998


*/
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <sys/types.h>
  #include <sys/stat.h>
  #include <fcntl.h>
  #include <sys/ioctl.h>
  #include <errno.h>
  #include <asm/mtrr.h>

#define TRUE 1
  #define FALSE 0
  Lỗi #define ERRSTRING (errno)

char tĩnh *mtrr_strings[MTRR_NUM_TYPES] =
  {
      "không thể lưu vào bộ nhớ đệm", /* 0 */
      "kết hợp ghi", /* 1 */
      "?", /* 2 */
      "?", /* 3 */
      "ghi qua", /* 4 */
      "bảo vệ ghi", /* 5 */
      "ghi lại", /* 6 */
  };

int chính ()
  {
      int fd;
      struct mtrr_gentry quý ông;

if ( ( fd = open ("/proc/mtrr", O_RDONLY, 0) ) == -1 )
      {
    nếu (errno == ENOENT)
    {
        fputs ("không tìm thấy/proc/mtrr: không được hỗ trợ hoặc bạn không có PPro?\n",
        stderr);
        thoát (1);
    }
    fprintf (stderr, "Lỗi mở /proc/mtrr\t%s\n", ERRSTRING);
    thoát (2);
      }
      for (gentry.regnum = 0; ioctl (fd, MTRRIOC_GET_ENTRY, &gentry) == 0;
    ++gentry.regnum)
      {
    nếu (gentry.size < 1)
    {
        fprintf (stderr, "Đăng ký: %u bị vô hiệu\n", gentry.regnum);
        Tiếp tục;
    }
    fprintf (stderr, "Đăng ký: %u cơ sở: 0x%lx kích thước: 0x%lx loại: %s\n",
      gentry.regnum, gentry.base, gentry.size,
      mtrr_strings[gentry.type]);
      }
      if (errno == EINVAL) thoát (0);
      fprintf (stderr, "Lỗi khi thực hiện ioctl(2) trên /dev/mtrr\t%s\n", ERRSTRING);
      lối ra (3);
  } /* Kết thúc hàm chính */


Tạo MTRR từ chương trình C bằng cách sử dụng ioctl()'s
======================================================
::

/* mtrr-add.c

Tệp nguồn cho mtrr-add (chương trình ví dụ để thêm MTRR bằng ioctl())

Bản quyền (C) 1997-1998 Richard Gooch

Chương trình này là phần mềm miễn phí; bạn có thể phân phối lại nó và/hoặc sửa đổi
      nó theo các điều khoản của Giấy phép Công cộng GNU được xuất bản bởi
      Tổ chức Phần mềm Tự do; phiên bản 2 của Giấy phép, hoặc
      (theo lựa chọn của bạn) bất kỳ phiên bản mới hơn.

Chương trình này được phân phối với hy vọng rằng nó sẽ hữu ích,
      nhưng WITHOUT ANY WARRANTY; thậm chí không có sự bảo đảm ngụ ý của
      MERCHANTABILITY hoặc FITNESS FOR A PARTICULAR PURPOSE.  Xem
      Giấy phép Công cộng GNU để biết thêm chi tiết.

Bạn hẳn đã nhận được một bản sao Giấy phép Công cộng GNU
      cùng với chương trình này; nếu không, hãy viết thư cho Phần mềm miễn phí
      Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

Có thể liên hệ với Richard Gooch qua email tại rgooch@atnf.csiro.au
      Địa chỉ bưu chính là:
        Richard Gooch, c/o ATNF, P. O. Box 76, Epping, N.S.W., 2121, Australia.
  */

/*
      Chương trình này sẽ sử dụng ioctl() trên /proc/mtrr để thêm mục nhập. đầu tiên
      mtrr có sẵn được sử dụng. Đây là một cách thay thế cho việc viết /proc/mtrr.


Viết bởi Richard Gooch 17-DEC-1997

Cập nhật lần cuối bởi Richard Gooch 2-MAY-1998


*/
  #include <stdio.h>
  #include <string.h>
  #include <stdlib.h>
  #include <unistd.h>
  #include <sys/types.h>
  #include <sys/stat.h>
  #include <fcntl.h>
  #include <sys/ioctl.h>
  #include <errno.h>
  #include <asm/mtrr.h>

#define TRUE 1
  #define FALSE 0
  Lỗi #define ERRSTRING (errno)

char tĩnh *mtrr_strings[MTRR_NUM_TYPES] =
  {
      "không thể lưu vào bộ nhớ đệm", /* 0 */
      "kết hợp ghi", /* 1 */
      "?", /* 2 */
      "?", /* 3 */
      "ghi qua", /* 4 */
      "bảo vệ ghi", /* 5 */
      "ghi lại", /* 6 */
  };

int chính (int argc, char **argv)
  {
      int fd;
      struct mtrr_sentry canh gác;

nếu (argc != 4)
      {
    fprintf (stderr, "Cách sử dụng:\tmtrr-thêm loại kích thước cơ sở\n");
    thoát (1);
      }
      canh gác.base = strtoul (argv[1], NULL, 0);
      canh gác.size = strtoul (argv[2], NULL, 0);
      cho (sentry.type = 0; Sentry.type < MTRR_NUM_TYPES; ++sentry.type)
      {
    if (strcmp (argv[3], mtrr_strings[sentry.type]) == 0) break;
      }
      nếu (sentry.type >= MTRR_NUM_TYPES)
      {
    fprintf (stderr, "Loại bất hợp pháp: \"%s\"\n", argv[3]);
    thoát (2);
      }
      if ( ( fd = open ("/proc/mtrr", O_WRONLY, 0) ) == -1 )
      {
    nếu (lỗi == ENOENT)
    {
        fputs ("không tìm thấy/proc/mtrr: không được hỗ trợ hoặc bạn không có PPro?\n",
        stderr);
        lối ra (3);
    }
    fprintf (stderr, "Lỗi mở /proc/mtrr\t%s\n", ERRSTRING);
    lối ra (4);
      }
      if (ioctl (fd, MTRRIOC_ADD_ENTRY, &sentry) == -1)
      {
    fprintf (stderr, "Lỗi khi thực hiện ioctl(2) trên /dev/mtrr\t%s\n", ERRSTRING);
    lối ra (5);
      }
      fprintf (stderr, "Ngủ trong 5 giây để bạn có thể thấy mục nhập mới\n");
      ngủ (5);
      đóng (fd);
      fputs ("Tôi vừa đóng /proc/mtrr nên bây giờ mục mới sẽ biến mất\n",
      stderr);
  } /* Kết thúc hàm chính */