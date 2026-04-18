.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/acpi/linuxized-acpica.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

=================================================================
Linuxized ACPICA - Giới thiệu về Tự động hóa phát hành ACPICA
============================================================

:Bản quyền: ZZ0000ZZ 2013-2016, Tập đoàn Intel

:Tác giả: Lv Zheng <lv.zheng@intel.com>


Tóm tắt
========
Tài liệu này mô tả dự án ACPICA và mối quan hệ giữa
ACPICA và Linux.  Nó cũng mô tả cách mã ACPICA trong trình điều khiển/acpi/acpica,
include/acpi and tools/power/acpi is automatically updated to follow the
thượng nguồn.

Dự án ACPICA
==============

Dự án Kiến trúc thành phần ACPI (ACPICA) cung cấp một hệ điều hành
triển khai tham chiếu độc lập với hệ thống (HĐH) của Advanced
Thông số kỹ thuật về cấu hình và giao diện nguồn (ACPI).  Nó đã được
được điều chỉnh bởi các hệ điều hành máy chủ khác nhau.  Bằng cách tích hợp trực tiếp ACPICA, Linux có thể
cũng được hưởng lợi từ trải nghiệm ứng dụng của ACPICA từ máy chủ khác
Hệ điều hành.

Trang chủ của dự án ACPICA là: www.acpica.org, nó được duy trì và
được hỗ trợ bởi Tập đoàn Intel.

Hình dưới đây mô tả hệ thống con Linux ACPI trong đó ACPICA
sự thích ứng được bao gồm::

+----------------------------------------------------------+
      ZZ0000ZZ
      ZZ0001ZZ
      ZZ0002ZZ +-------------------+ ZZ0003ZZ
      ZZ0004ZZ ZZ0005ZZ ZZ0006ZZ
      ZZ0007ZZ +-------------------+ ZZ0008ZZ
      ZZ0009ZZ +----------------------+ ZZ0010ZZ
      ZZ0011ZZ ZZ0012ZZ ZZ0013ZZ
      ZZ0014ZZ +----------------------+ ZZ0015ZZ
      ZZ0016ZZ +-------------------+ ACPICA Linh kiện ZZ0017ZZ
      ZZ0018ZZ ZZ0019ZZ ZZ0020ZZ
      ZZ0021ZZ +-------------------+ ZZ0022ZZ
      ZZ0023ZZ +----------------------+ ZZ0024ZZ
      ZZ0025ZZ ZZ0026ZZ ZZ0027ZZ
      ZZ0028ZZ +----------------------+ ZZ0029ZZ
      ZZ0030ZZ +----------------------+ ZZ0031ZZ
      ZZ0032ZZ ZZ0033ZZ ZZ0034ZZ
      ZZ0035ZZ +----------------------+ ZZ0036ZZ
      ZZ0037ZZ |
      ZZ0038ZZ ZZ0039ZZ ZZ0040ZZ
      ZZ0041ZZ ZZ0042ZZ Lớp dịch vụ hệ điều hành ZZ0043ZZ ZZ0044ZZ
      ZZ0045ZZ ZZ0046ZZ ZZ0047ZZ
      ZZ0048ZZ +-------------------------------------------------ZZ0049ZZ
      ZZ0050ZZ +----------------------+ ZZ0051ZZ
      ZZ0052ZZ ZZ0053ZZ ZZ0054ZZ
      ZZ0055ZZ +----------------------+ ZZ0056ZZ
      ZZ0057ZZ +-------------------+ ZZ0058ZZ
      ZZ0059ZZ ZZ0060ZZ ZZ0061ZZ
      ZZ0062ZZ +-------------------+ Thành phần Linux/ACPI ZZ0063ZZ
      ZZ0064ZZ +----------------------+ ZZ0065ZZ
      ZZ0066ZZ ZZ0067ZZ ZZ0068ZZ
      ZZ0069ZZ +----------------------+ ZZ0070ZZ
      ZZ0071ZZ +--------------------------+ ZZ0072ZZ
      ZZ0073ZZ ZZ0074ZZ ZZ0075ZZ
      ZZ0076ZZ +--------------------------+ ZZ0077ZZ
      ZZ0078ZZ +--------+ ZZ0079ZZ
      ZZ0080ZZ ZZ0081ZZ ZZ0082ZZ
      ZZ0083ZZ +--------+ ZZ0084ZZ
      ZZ0085ZZ
      ZZ0086ZZ
      +----------------------------------------------------------+

Hình 1. Các thành phần phần mềm Linux ACPI

.. note::
    A. OS Service Layer - Provided by Linux to offer OS dependent
       implementation of the predefined ACPICA interfaces (acpi_os_*).
       ::

         include/acpi/acpiosxf.h
         drivers/acpi/osl.c
         include/acpi/platform
         include/asm/acenv.h
    B. ACPICA Functionality - Released from ACPICA code base to offer
       OS independent implementation of the ACPICA interfaces (acpi_*).
       ::

         drivers/acpi/acpica
         include/acpi/ac*.h
         tools/power/acpi
    C. Linux/ACPI Functionality - Providing Linux specific ACPI
       functionality to the other Linux kernel subsystems and user space
       programs.
       ::

         drivers/acpi
         include/linux/acpi.h
         include/linux/acpi*.h
         include/acpi
         tools/power/acpi
    D. Architecture Specific ACPICA/ACPI Functionalities - Provided by the
       ACPI subsystem to offer architecture specific implementation of the
       ACPI interfaces.  They are Linux specific components and are out of
       the scope of this document.
       ::

         include/asm/acpi.h
         include/asm/acpi*.h
         arch/*/acpi

Phát hành ACPICA
==============

Dự án ACPICA duy trì cơ sở mã của nó tại kho lưu trữ URL sau:
ZZ0000ZZ Theo quy định, việc phát hành được thực hiện mỗi
tháng.

Vì phong cách mã hóa được dự án ACPICA áp dụng không được chấp nhận bởi
Linux, có một quy trình phát hành để chuyển đổi cam kết git ACPICA thành
Các bản vá Linux.  Các bản vá được tạo ra bởi quá trình này được gọi là
"Bản vá ACPICA được linux hóa".  Quá trình phát hành được thực hiện trên máy cục bộ
sao chép kho git ACPICA.  Mỗi cam kết trong bản phát hành hàng tháng là
được chuyển đổi thành bản vá ACPICA được linux hóa.  Cùng nhau, họ tạo thành tờ báo hàng tháng
Bộ bản vá phát hành ACPICA cho cộng đồng Linux ACPI.  Quá trình này là
được minh họa trong hình sau::

+-----------------------------+
    ZZ0000ZZ
    +-----------------------------+
       /ZZ0001ZZ
        ZZ0002ZZ/
        |  /-------------\ +----------------------+
        ZZ0003ZZ acpica linuxized cũ |--+
        ZZ0004ZZ
        ZZ0005ZZ
     /----------\ |
    < đặt lại git > \
     \----------/ \
       /|\ /+-+
        ZZ0006ZZ
    +-----------------------------+ ZZ0007ZZ
    ZZ0008ZZ ZZ0009ZZ
    +-----------------------------+ ZZ0010ZZ
                   ZZ0011ZZ |
                  \ZZ0012ZZ |
         /--------------\ +----------------------+ ZZ0013ZZ
        < Tiện ích repo Linuxize >-->ZZ0014ZZ--+ |
         \--------------/ +----------------------+ |
                                                                    \|/
    +--------------------------+ /----------------------\
    ZZ0015ZZ<----------------- Tiện ích bản vá Linuxize >
    +--------------------------+ \----------------------/
                   |
                  \|/
     /--------------------------\
    < Đánh giá của cộng đồng Linux ACPI >
     \--------------------------/
                   |
                  \|/
    +-----------------------+ /-------------------\ +----------------+
    ZZ0016ZZ-->< Cửa sổ hợp nhất Linux >-->ZZ0017ZZ
    +-----------------------+ \-------------------/ +----------------+

Hình 2. ACPICA -> Quy trình ngược dòng Linux

.. note::
    A. Linuxize Utilities - Provided by the ACPICA repository, including a
       utility located in source/tools/acpisrc folder and a number of
       scripts located in generate/linux folder.
    B. acpica / master - "master" branch of the git repository at
       <https://github.com/acpica/acpica.git>.
    C. linux-pm / linux-next - "linux-next" branch of the git repository at
       <https://git.kernel.org/pub/scm/linux/kernel/git/rafael/linux-pm.git>.
    D. linux / master - "master" branch of the git repository at
       <https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git>.

   Before the linuxized ACPICA patches are sent to the Linux ACPI community
   for review, there is a quality assurance build test process to reduce
   porting issues.  Currently this build process only takes care of the
   following kernel configuration options:
   CONFIG_ACPI/CONFIG_ACPI_DEBUG/CONFIG_ACPI_DEBUGGER

Sự phân kỳ ACPICA
==================

Lý tưởng nhất là tất cả các cam kết ACPICA nên được chuyển đổi thành các bản vá Linux
tự động mà không cần sửa đổi thủ công, cây "linux / master" sẽ
chứa mã ACPICA tương ứng chính xác với mã ACPICA
chứa trong cây " acpica linuxized mới" và nó có thể chạy
quá trình phát hành hoàn toàn tự động.

Tuy nhiên, trên thực tế, có sự khác biệt về mã nguồn giữa
mã ACPICA trong Linux và mã ACPICA ngược dòng, được gọi là
"Sự phân kỳ ACPICA".

Các nguồn phân kỳ ACPICA khác nhau bao gồm:
   1. Sự phân kỳ kế thừa - Trước khi quá trình phát hành ACPICA hiện tại được thực hiện
      được thiết lập, đã có sự khác biệt giữa Linux và
      ACPICA. Trong nhiều năm qua, những khác biệt đó đã tăng lên rất nhiều
      đã giảm nhưng vẫn còn vài cái và cần có thời gian để tìm hiểu
      ra những lý do cơ bản cho sự tồn tại của chúng.
   2. Sửa đổi thủ công - Mọi sửa đổi thủ công (ví dụ: sửa lỗi kiểu mã hóa)
      được thực hiện trực tiếp trong các nguồn Linux rõ ràng gây tổn hại cho bản phát hành ACPICA
      tự động hóa.  Vì vậy, nên khắc phục các sự cố như vậy trong ACPICA
      mã nguồn ngược dòng và tạo bản sửa lỗi được linuxized bằng ACPICA
      tiện ích phát hành (vui lòng tham khảo Phần 4 bên dưới để biết chi tiết).
   3. Các tính năng cụ thể của Linux - Đôi khi không thể sử dụng
      API ACPICA hiện tại để triển khai các tính năng mà nhân Linux yêu cầu,
      vì vậy các nhà phát triển Linux thỉnh thoảng phải thay đổi trực tiếp mã ACPICA.
      Những thay đổi đó có thể không được ACPICA ngược dòng chấp nhận và trong những trường hợp như vậy
      chúng được để lại dưới dạng phân kỳ ACPICA đã cam kết trừ khi phía ACPICA có thể
      thực hiện các cơ chế mới để thay thế chúng.
   4. Bản sửa lỗi phát hành ACPICA - ACPICA chỉ kiểm tra các cam kết bằng cách sử dụng một bộ
      tiện ích mô phỏng không gian người dùng, do đó các bản vá ACPICA được linux hóa có thể
      phá vỡ nhân Linux, khiến chúng ta gặp lỗi khi xây dựng/khởi động.  để
      tránh phá vỡ sự chia đôi của Linux, các bản sửa lỗi được áp dụng trực tiếp vào
      các bản vá ACPICA được linuxized trong quá trình phát hành.  Khi phát hành
      các bản sửa lỗi được chuyển ngược vào các nguồn ACPICA ngược dòng, chúng phải tuân theo
      các quy tắc ACPICA ngược dòng và do đó các sửa đổi bổ sung có thể xuất hiện.
      Điều đó có thể dẫn đến sự xuất hiện của các phân kỳ mới.
   5. Theo dõi nhanh các cam kết ACPICA - Một số cam kết ACPICA là hồi quy
      các bản sửa lỗi hoặc tài liệu ứng cử viên ổn định, vì vậy chúng được áp dụng trước với
      tôn trọng quy trình phát hành ACPICA.  Nếu những cam kết đó được hoàn nguyên hoặc
      được dựa trên phía ACPICA để cung cấp các giải pháp tốt hơn, ACPICA mới
      sự phân kỳ được tạo ra.

Phát triển ACPICA
==================

Đoạn này hướng dẫn các nhà phát triển Linux sử dụng bản phát hành ngược dòng ACPICA
tiện ích để nhận các bản vá Linux tương ứng với các cam kết ACPICA ngược dòng
trước khi chúng có sẵn trong quá trình phát hành ACPICA.

1. Cherry-pick cam kết ACPICA

Đầu tiên bạn cần git clone kho ACPICA và thay đổi ACPICA
   bạn muốn chọn anh đào phải được cam kết vào kho lưu trữ cục bộ.

Sau đó, lệnh gen-patch.sh có thể giúp chọn một cam kết ACPICA
   từ kho lưu trữ cục bộ ACPICA ::

$ git bản sao ZZ0000ZZ
   $ cd acpica
   $ tạo/linux/gen-patch.sh -u [ID cam kết]

Ở đây ID cam kết là ID cam kết kho lưu trữ cục bộ ACPICA mà bạn muốn
   hái anh đào.  Nó có thể được bỏ qua nếu cam kết là "HEAD".

2. Cherry-pick cam kết ACPICA gần đây

Đôi khi bạn cần phải khởi động lại mã của mình trên ACPICA gần đây nhất
   những thay đổi chưa được áp dụng cho Linux.

Bạn có thể tự tạo chuỗi phát hành ACPICA và khởi động lại mã của mình trên
   đầu các bản vá phát hành ACPICA được tạo::

$ git bản sao ZZ0000ZZ
   $ cd acpica
   $ generate/linux/make-patches.sh -u [ID cam kết]

ID cam kết phải là cam kết ACPICA cuối cùng được Linux chấp nhận.  Thông thường,
   đó là cam kết sửa đổi ACPI_CA_VERSION.  Nó có thể được tìm thấy bằng cách thực hiện
   "git đổ lỗi nguồn/bao gồm/acpixf.h" và tham chiếu dòng có chứa
   "ACPI_CA_VERSION".

3. Kiểm tra sự phân kỳ hiện tại

Nếu bạn có các bản sao cục bộ của cả Linux và ACPICA ngược dòng, bạn có thể tạo
   một tệp khác biệt cho biết trạng thái của sự phân kỳ hiện tại::

Bản sao # git ZZ0000ZZ
   # git bản sao ZZ0001ZZ
   # cd acpica
   # generate/linux/divergence.sh -s ../linux