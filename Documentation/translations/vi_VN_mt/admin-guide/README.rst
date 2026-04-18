.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/README.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _readme:

Bản phát hành nhân Linux 6.x <ZZ0000ZZ
=============================================

Đây là các ghi chú phát hành cho Linux phiên bản 6. Hãy đọc kỹ chúng,
khi họ cho bạn biết nội dung của điều này, hãy giải thích cách cài đặt
kernel và phải làm gì nếu có sự cố.

Linux là gì?
--------------

Linux là một bản sao của hệ điều hành Unix, được viết từ đầu bởi
  Linus Torvalds với sự hỗ trợ từ một nhóm hacker liên kết chặt chẽ trên khắp
  Mạng. Nó hướng tới việc tuân thủ Thông số kỹ thuật POSIX và UNIX đơn.

Nó có tất cả các tính năng mà bạn mong đợi ở một Unix hoàn chỉnh hiện đại,
  bao gồm đa nhiệm thực sự, bộ nhớ ảo, thư viện dùng chung, nhu cầu
  tải, chia sẻ các tệp thực thi sao chép khi ghi, quản lý bộ nhớ thích hợp,
  và mạng đa tầng bao gồm IPv4 và IPv6.

Nó được phân phối theo Giấy phép Công cộng GNU v2 - xem phần
  tệp COPYING đi kèm để biết thêm chi tiết.

Nó chạy trên phần cứng nào?
-----------------------------

Mặc dù ban đầu được phát triển đầu tiên cho PC dựa trên x86 32-bit (386 hoặc cao hơn),
  ngày nay Linux cũng chạy trên (ít nhất) Compaq Alpha AXP, Sun SPARC và
  UltraSPARC, Motorola 68000, PowerPC, PowerPC64, ARM, Hitachi SuperH, Tế bào,
  IBM S/390, MIPS, HP PA-RISC, Intel IA-64, DEC VAX, AMD x86-64 Xtensa và
  Kiến trúc ARC.

Linux có thể dễ dàng di chuyển sang hầu hết các kiến trúc 32 hoặc 64-bit có mục đích chung
  miễn là chúng có bộ quản lý bộ nhớ phân trang (PMMU) và một cổng của
  Trình biên dịch GNU C (gcc) (một phần của Bộ sưu tập trình biên dịch GNU, GCC). Linux có
  cũng đã được chuyển sang một số kiến trúc không có PMMU, mặc dù
  chức năng sau đó rõ ràng là có phần hạn chế.
  Linux cũng đã được chuyển sang chính nó. Bây giờ bạn có thể chạy kernel dưới dạng
  ứng dụng không gian người dùng - ứng dụng này được gọi là UserMode Linux (UML).

Tài liệu
-------------

- Có rất nhiều tài liệu có sẵn cả ở dạng điện tử trên
   Internet và trong sách, cả về Linux và liên quan đến
   câu hỏi chung về UNIX.  Tôi khuyên bạn nên xem xét tài liệu
   thư mục con trên bất kỳ trang Linux FTP nào dành cho LDP (Tài liệu Linux
   Dự án) sách.  README này không phải là tài liệu về
   hệ thống: có nhiều nguồn tốt hơn có sẵn.

- Có nhiều file README khác nhau trong Documentation/thư mục con:
   chúng thường chứa các ghi chú cài đặt dành riêng cho kernel cho một số
   trình điều khiển chẳng hạn. Xin vui lòng đọc
   Tệp ZZ0000ZZ, vì nó
   chứa thông tin về các vấn đề có thể xảy ra do nâng cấp
   hạt nhân của bạn.

Cài đặt nguồn kernel
----------------------------

- Nếu cài full source thì cho kernel tarball vào
   thư mục nơi bạn có quyền (ví dụ: thư mục chính của bạn) và
   giải nén nó::

xz -cd linux-6.x.tar.xz | tar xvf -

Thay thế "X" bằng số phiên bản của kernel mới nhất.

NOT có sử dụng vùng /usr/src/linux không! Khu vực này có (thường
   chưa hoàn chỉnh) tập hợp các tiêu đề kernel được tiêu đề thư viện sử dụng
   tập tin.  Chúng phải phù hợp với thư viện và không bị rối tung bởi
   bất kể kernel-du-jour xảy ra như thế nào.

- Bạn cũng có thể nâng cấp giữa các bản phát hành 6.x bằng cách vá lỗi.  Các bản vá là
   được phân phối ở định dạng xz.  Để cài đặt bằng cách vá lỗi, hãy lấy tất cả
   các tệp bản vá mới hơn, hãy nhập thư mục cấp cao nhất của nguồn kernel
   (linux-6.x) và thực thi ::

xz -cd ../patch-6.x.xz | vá -p1

Thay thế "x" cho tất cả các phiên bản lớn hơn phiên bản "x" hiện tại của bạn
   cây nguồn, ZZ0000ZZ, và bạn sẽ ổn thôi.  Bạn có thể muốn loại bỏ
   các tập tin sao lưu (some-file-name~ hoặc some-file-name.orig) và đảm bảo
   rằng không có bản vá lỗi nào (some-file-name# or some-file-name.rej).
   Nếu có thì bạn hoặc tôi đã phạm sai lầm.

Không giống như các bản vá dành cho hạt nhân 6.x, các bản vá dành cho hạt nhân 6.x.y
   (còn được gọi là hạt nhân ổn định) không tăng dần mà thay vào đó áp dụng
   trực tiếp đến kernel 6.x cơ sở.  Ví dụ: nếu kernel cơ sở của bạn là 6.0
   và bạn muốn áp dụng bản vá 6.0.3, trước tiên bạn không được áp dụng bản 6.0.1
   và các bản vá lỗi 6.0.2. Tương tự, nếu bạn đang chạy kernel phiên bản 6.0.2 và
   muốn nhảy lên 6.0.3, trước tiên bạn phải đảo ngược bản vá 6.0.2 (nghĩa là
   patch -R) ZZ0001ZZ áp dụng bản vá 6.0.3. Bạn có thể đọc thêm về điều này trong
   ZZ0000ZZ.

Ngoài ra, hạt nhân bản vá tập lệnh có thể được sử dụng để tự động hóa việc này
   quá trình.  Nó xác định phiên bản kernel hiện tại và áp dụng bất kỳ phiên bản nào
   các bản vá được tìm thấy::

linux/scripts/patch-kernel linux

Đối số đầu tiên trong lệnh trên là vị trí của
   nguồn hạt nhân.  Các bản vá được áp dụng từ thư mục hiện tại, nhưng
   một thư mục thay thế có thể được chỉ định làm đối số thứ hai.

- Đảm bảo rằng bạn không có tệp .o cũ và phần phụ thuộc nào nằm xung quanh::

cd linux
     làm cho ông đúng đắn

Bây giờ bạn sẽ có các nguồn được cài đặt chính xác.

Yêu cầu phần mềm
---------------------

Biên dịch và chạy hạt nhân 6.x yêu cầu phải cập nhật
   phiên bản của các gói phần mềm khác nhau.  tư vấn
   ZZ0000ZZ để biết số phiên bản tối thiểu
   được yêu cầu và cách nhận bản cập nhật cho các gói này.  Hãy coi chừng việc sử dụng
   phiên bản quá cũ của các gói này có thể gây ra gián tiếp
   những lỗi rất khó theo dõi, vì vậy đừng cho rằng
   bạn chỉ có thể cập nhật các gói khi có vấn đề rõ ràng phát sinh trong quá trình
   xây dựng hoặc vận hành.

Xây dựng thư mục cho kernel
------------------------------

Khi biên dịch kernel, tất cả các file đầu ra theo mặc định sẽ là
   được lưu trữ cùng với mã nguồn kernel.
   Sử dụng tùy chọn ZZ0000ZZ cho phép bạn chỉ định một phương án thay thế
   nơi dành cho các tệp đầu ra (bao gồm .config).
   Ví dụ::

mã nguồn hạt nhân: /usr/src/linux-6.x
     thư mục xây dựng:/home/name/build/kernel

Để cấu hình và xây dựng kernel, hãy sử dụng::

cd /usr/src/linux-6.x
     tạo menuconfig O=/home/name/build/kernel
     tạo O=/home/name/build/kernel
     sudo make O=/home/name/build/kernel module_install cài đặt

Xin lưu ý: Nếu tùy chọn ZZ0000ZZ được sử dụng thì nó phải
   được sử dụng cho tất cả các lệnh gọi make.

Cấu hình hạt nhân
----------------------

Do not skip this step even if you are only upgrading one minor
   phiên bản.  Các tùy chọn cấu hình mới được thêm vào trong mỗi bản phát hành và
   các vấn đề kỳ lạ sẽ xuất hiện nếu các tập tin cấu hình không được thiết lập
   như mong đợi.  Nếu bạn muốn chuyển cấu hình hiện có của mình sang một
   phiên bản mới với công việc tối thiểu, hãy sử dụng ZZ0000ZZ, nó sẽ
   chỉ yêu cầu bạn trả lời những câu hỏi mới.

- Các lệnh cấu hình thay thế là::

"tạo cấu hình" Giao diện văn bản thuần túy.

"make menuconfig" Menu màu, danh sách radio và hộp thoại dựa trên văn bản.

"make nconfig" Menu màu dựa trên văn bản nâng cao.

Công cụ cấu hình dựa trên Qt "make xconfig".

Công cụ cấu hình dựa trên "make gconfig" GTK.

"make oldconfig" Mặc định tất cả các câu hỏi dựa trên nội dung của
                        tập tin ./.config hiện có của bạn và hỏi về
                        biểu tượng cấu hình mới.

"tạo olddefconfig"
                        Giống như trên, nhưng đặt các ký hiệu mới về mặc định
                        giá trị mà không cần nhắc nhở.

"make defconfig" Tạo tệp ..config bằng cách sử dụng mặc định
                        giá trị ký hiệu từ Arch/$ARCH/configs/defconfig
                        hoặc Arch/$ARCH/configs/${PLATFORM_defconfig,
                        tùy theo kiến trúc.

"tạo ${PLATFORM__defconfig"
                        Tạo tệp ./.config bằng cách sử dụng mặc định
                        giá trị ký hiệu từ
                        Arch/$ARCH/configs/${PLATFORM__defconfig.
                        Sử dụng "giúp đỡ" để có danh sách tất cả những gì có sẵn
                        nền tảng kiến trúc của bạn.

"tạo allyesconfig"
                        Tạo tệp ..config bằng cách đặt ký hiệu
                        giá trị 'y' càng nhiều càng tốt.

"tạo allmodconfig"
                        Tạo tệp ..config bằng cách đặt ký hiệu
                        giá trị 'm' càng nhiều càng tốt.

"make allnoconfig" Tạo tệp ..config bằng cách đặt ký hiệu
                        giá trị 'n' càng nhiều càng tốt.

"make Randconfig" Tạo tệp ..config bằng cách đặt ký hiệu
                        giá trị thành giá trị ngẫu nhiên.

"make localmodconfig" Tạo cấu hình dựa trên cấu hình hiện tại và
                           các mô-đun đã tải (lsmod). Vô hiệu hóa bất kỳ mô-đun nào
                           tùy chọn không cần thiết cho các mô-đun được tải.

Để tạo localmodconfig cho máy khác,
                           lưu trữ lsmod của máy đó vào một tập tin
                           và chuyển nó vào dưới dạng tham số LSMOD.

Ngoài ra, bạn có thể bảo quản các mô-đun trong một số thư mục nhất định
                           hoặc tệp kconfig bằng cách chỉ định đường dẫn của chúng trong
                           tham số LMC_KEEP.

target$ lsmod > /tmp/mylsmod
                   target$ scp /tmp/mylsmod máy chủ:/tmp

máy chủ $ tạo LSMOD=/tmp/mylsmod \
                           LMC_KEEP="drivers/usb:drivers/gpu:fs" \
                           localmodconfig

Ở trên cũng hoạt động khi biên dịch chéo.

"make localyesconfig" Tương tự như localmodconfig, ngoại trừ việc nó sẽ chuyển đổi
                           tất cả các tùy chọn mô-đun cho đến các tùy chọn (=y) tích hợp. bạn có thể
                           cũng bảo quản các mô-đun bằng LMC_KEEP.

"make kvm_guest.config" Kích hoạt các tùy chọn bổ sung cho kernel khách kvm
                               hỗ trợ.

"make xen.config" Kích hoạt các tùy chọn bổ sung cho kernel khách xen dom0
                         hỗ trợ.

"make tinyconfig" Định cấu hình kernel nhỏ nhất có thể.

Bạn có thể tìm thêm thông tin về cách sử dụng các công cụ cấu hình nhân Linux
   trong Tài liệu/kbuild/kconfig.rst.

- NOTES trên ZZ0000ZZ:

- Việc có những driver không cần thiết sẽ làm cho kernel lớn hơn và có thể
      trong một số trường hợp dẫn đến các vấn đề: thăm dò một
      thẻ điều khiển không tồn tại có thể gây nhầm lẫn cho các bộ điều khiển khác của bạn.

- Một hạt nhân có mô phỏng toán học được biên dịch vẫn sẽ sử dụng
      bộ đồng xử lý nếu có: việc mô phỏng toán học sẽ chỉ
      không bao giờ được sử dụng trong trường hợp đó.  Hạt nhân sẽ lớn hơn một chút,
      nhưng sẽ hoạt động trên các máy khác nhau bất kể chúng có
      có bộ đồng xử lý toán học hay không.

- Chi tiết cấu hình "kernel hack" thường dẫn đến
      kernel lớn hơn hoặc chậm hơn (hoặc cả hai) và thậm chí có thể tạo kernel
      kém ổn định hơn bằng cách cấu hình một số thói quen để cố gắng tích cực
      phá mã xấu để tìm vấn đề về kernel (kmalloc()).  Vì vậy bạn
      có lẽ nên trả lời 'n' cho các câu hỏi về "phát triển",
      tính năng "thử nghiệm" hoặc "gỡ lỗi".

Biên dịch hạt nhân
--------------------

- Đảm bảo bạn có sẵn ít nhất gcc 8.1.
   Để biết thêm thông tin, hãy tham khảo ZZ0000ZZ.

- Thực hiện ZZ0000ZZ để tạo kernel image nén. Cũng có thể làm được
   ZZ0001ZZ nếu bạn đã cài đặt lilo hoặc nếu bản phân phối của bạn có
   tập lệnh cài đặt được trình cài đặt của kernel nhận ra. Phổ biến nhất
   bản phân phối sẽ có tập lệnh cài đặt được công nhận. Bạn có thể muốn
   trước tiên hãy kiểm tra thiết lập phân phối của bạn.

Để thực hiện cài đặt thực tế, bạn phải root, nhưng không có cách nào thông thường
   build nên yêu cầu điều đó. Đừng lấy tên gốc một cách vô ích.

- Nếu bạn đã định cấu hình bất kỳ phần nào của kernel là ZZ0000ZZ, bạn
   cũng sẽ phải làm ZZ0001ZZ.

- Đầu ra biên dịch/xây dựng kernel chi tiết:

Thông thường, hệ thống xây dựng kernel chạy ở chế độ khá yên tĩnh (nhưng không
   hoàn toàn im lặng).  Tuy nhiên, đôi khi bạn hoặc các nhà phát triển kernel khác cần
   để xem các lệnh biên dịch, liên kết hoặc các lệnh khác chính xác như chúng được thực thi.
   Đối với điều này, hãy sử dụng chế độ xây dựng "tiết tiết".  Điều này được thực hiện bằng cách chuyển
   ZZ0000ZZ sang lệnh ZZ0001ZZ, ví dụ::

làm cho V=1 tất cả

Để có hệ thống xây dựng cũng cho biết lý do xây dựng lại từng
   mục tiêu, hãy sử dụng ZZ0000ZZ.  Mặc định là ZZ0001ZZ.

- Chuẩn bị sẵn một kernel dự phòng đề phòng trường hợp có sự cố xảy ra.  Đây là
   đặc biệt đúng với các bản phát hành phát triển, vì mỗi bản phát hành mới
   chứa mã mới chưa được gỡ lỗi.  Hãy chắc chắn rằng bạn giữ một
   cũng sao lưu các mô-đun tương ứng với hạt nhân đó.  Nếu bạn
   đang cài đặt kernel mới có cùng số phiên bản với
   kernel đang hoạt động, hãy sao lưu thư mục mô-đun của bạn trước khi bạn
   làm ZZ0000ZZ.

Ngoài ra, trước khi biên dịch, hãy sử dụng tùy chọn cấu hình kernel
   "LOCALVERSION" để thêm hậu tố duy nhất vào phiên bản kernel thông thường.
   LOCALVERSION có thể được đặt trong menu "Cài đặt chung".

- Để khởi động kernel mới, bạn cần sao chép kernel
   hình ảnh (ví dụ: .../linux/arch/x86/boot/bzImage sau khi biên dịch)
   đến nơi tìm thấy kernel có khả năng khởi động thông thường của bạn.

- Khởi động kernel trực tiếp từ thiết bị lưu trữ mà không cần sự trợ giúp
   của bộ tải khởi động như LILO hoặc GRUB, không còn được hỗ trợ trong BIOS nữa
   (các hệ thống không phải EFI). Tuy nhiên, trên các hệ thống UEFI/EFI, bạn có thể sử dụng EFISTUB
   cho phép bo mạch chủ khởi động trực tiếp vào kernel.
   Trên các máy trạm và máy tính để bàn hiện đại, thông thường nên sử dụng
   bootloader vì khó khăn có thể phát sinh với nhiều kernel và khả năng khởi động an toàn.
   Để biết thêm chi tiết về EFISTUB,
   xem "Tài liệu/admin-guide/efi-stub.rst".

- Điều quan trọng cần lưu ý là kể từ năm 2016 LILO (LInux LOader) không còn trong
   phát triển tích cực, mặc dù nó cực kỳ phổ biến nên nó thường xuất hiện
   trong tài liệu. Các lựa chọn thay thế phổ biến bao gồm GRUB2, rEFInd, Syslinux,
   systemd-boot hoặc EFISTUB. Vì nhiều lý do khác nhau, không nên sử dụng
   phần mềm không còn được phát triển tích cực nữa.

- Rất có thể bản phân phối của bạn có chứa tập lệnh cài đặt và đang chạy
   ZZ0000ZZ sẽ là tất cả những gì bạn cần. Có phải như vậy không
   bạn sẽ phải xác định bộ nạp khởi động của mình và tham khảo tài liệu của nó hoặc
   định cấu hình EFI của bạn.

Hướng dẫn kế thừa LILO
------------------------


- Nếu bạn sử dụng LILO thì hình ảnh hạt nhân sẽ được chỉ định trong tệp /etc/lilo.conf.
   Tệp hình ảnh hạt nhân thường là /vmlinuz, /boot/vmlinuz, /bzImage hoặc
   /boot/bzImage. Để sử dụng kernel mới, hãy lưu một bản sao của hình ảnh cũ và sao chép
   hình ảnh mới đè lên hình ảnh cũ. Sau đó, bạn MUST RERUN LILO để cập nhật
   đang tải bản đồ! Nếu không, bạn sẽ không thể khởi động ảnh hạt nhân mới.

- Cài đặt lại LILO thường là chạy /sbin/lilo. Bạn có thể ước
   chỉnh sửa /etc/lilo.conf để chỉ định một mục nhập cho hình ảnh hạt nhân cũ của bạn
   (giả sử /vmlinux.old) trong trường hợp cái mới không hoạt động. Xem tài liệu LILO
   để biết thêm thông tin.

- Sau khi cài đặt lại LILO, bạn sẽ hoàn tất. Tắt hệ thống,
   khởi động lại và tận hưởng!

- Nếu bạn cần thay đổi thiết bị gốc mặc định, chế độ video, v.v. trong
   hình ảnh hạt nhân, hãy sử dụng các tùy chọn khởi động của bộ nạp khởi động nếu thích hợp. không cần
   biên dịch lại kernel để thay đổi các tham số này.

- Khởi động lại với kernel mới và tận hưởng.


Nếu có gì sai sót
-----------------------

Nếu bạn gặp vấn đề có vẻ là do lỗi kernel, hãy làm theo hướng dẫn sau.
hướng dẫn tại 'Documentation/admin-guide/reporting-issues.rst'.

Gợi ý về việc hiểu các báo cáo lỗi kernel có trong
'Tài liệu/admin-guide/bug-hunting.rst'. Thông tin thêm về gỡ lỗi kernel
với gdb nằm trong 'Tài liệu/quy trình/gỡ lỗi/gdb-kernel-debugging.rst' và
'Tài liệu/quy trình/gỡ lỗi/kgdb.rst'.
