.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/ramfs-rootfs-initramfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==============================
Ramfs, rootfs và initramfs
===========================

Ngày 17 tháng 10 năm 2005

:Tác giả: Rob Landley <rob@landley.net>

ramf là gì?
--------------

Ramfs là một hệ thống tệp rất đơn giản giúp xuất bộ nhớ đệm đĩa của Linux
cơ chế (bộ đệm trang và bộ đệm nha khoa) dưới dạng có thể thay đổi kích thước động
Hệ thống tập tin dựa trên RAM.

Thông thường tất cả các tệp đều được Linux lưu vào bộ nhớ.  Các trang dữ liệu được đọc từ
cửa hàng sao lưu (thường là thiết bị khối mà hệ thống tập tin được gắn vào) được lưu giữ
xung quanh trong trường hợp cần lại, nhưng được đánh dấu là sạch (có thể giải phóng) trong trường hợp
Hệ thống bộ nhớ ảo cần bộ nhớ cho việc khác.  Tương tự, dữ liệu
được ghi vào tập tin được đánh dấu là sạch ngay khi nó được ghi vào bản sao lưu
lưu trữ nhưng được giữ lại cho mục đích lưu vào bộ nhớ đệm cho đến khi VM phân bổ lại
trí nhớ.  Một cơ chế tương tự (bộ đệm nha khoa) tăng tốc đáng kể khả năng truy cập vào
thư mục.

Với ramf, không có cửa hàng hỗ trợ.  Các tập tin được ghi vào phân bổ ramfs
bộ nhớ đệm và bộ đệm trang như thường lệ, nhưng không có nơi nào để ghi chúng vào.
Điều này có nghĩa là các trang không bao giờ được đánh dấu là sạch nên chúng không thể được giải phóng bởi
VM khi nó đang tìm cách tái chế bộ nhớ.

Số lượng mã cần thiết để triển khai ramf là rất nhỏ, bởi vì tất cả
công việc được thực hiện bởi cơ sở hạ tầng bộ nhớ đệm Linux hiện có.  Về cơ bản,
bạn đang gắn bộ đệm đĩa dưới dạng hệ thống tập tin.  Vì điều này, ramfs không
một thành phần tùy chọn có thể tháo rời thông qua menuconfig, vì sẽ có không đáng kể
tiết kiệm không gian.

ramf và ramdisk:
------------------

Cơ chế "đĩa ram" cũ hơn đã tạo ra một thiết bị khối tổng hợp từ
một vùng RAM và sử dụng nó làm kho lưu trữ dự phòng cho hệ thống tệp.  Khối này
thiết bị có kích thước cố định, do đó hệ thống tập tin được gắn trên nó có kích thước cố định
kích thước.  Việc sử dụng đĩa ram cũng yêu cầu sao chép bộ nhớ một cách không cần thiết từ
thiết bị chặn giả mạo vào bộ đệm của trang (và sao chép các thay đổi trở lại)
như tạo và phá hủy răng giả.  Ngoài ra, nó cần một trình điều khiển hệ thống tập tin
(chẳng hạn như ext2) để định dạng và diễn giải dữ liệu này.

So với ramf, điều này gây lãng phí bộ nhớ (và băng thông bus bộ nhớ), tạo ra
công việc không cần thiết đối với CPU và làm ô nhiễm bộ đệm CPU.  (Có thủ thuật
để tránh việc sao chép này bằng cách chơi với các bảng trang, nhưng chúng thật khó chịu
dù sao cũng phức tạp và hóa ra cũng đắt ngang với việc sao chép.)
Quan trọng hơn, tất cả các khối công việc đang thực hiện đều phải xảy ra _dù sao đi nữa_,
vì tất cả quyền truy cập tệp đều đi qua trang và bộ nhớ đệm.  RAM
đĩa đơn giản là không cần thiết; ramfs nội bộ đơn giản hơn nhiều.

Một lý do khác khiến đĩa RAM gần như lỗi thời là do sự ra đời của
các thiết bị loopback cung cấp một cách linh hoạt và thuận tiện hơn để tạo
các thiết bị khối tổng hợp, bây giờ từ các tập tin thay vì từ các khối bộ nhớ.
Xem losttup (8) để biết chi tiết.

ramf và tmpfs:
----------------

Một nhược điểm của ramfs là bạn có thể tiếp tục ghi dữ liệu vào đó cho đến khi bạn điền vào
hết bộ nhớ và VM không thể giải phóng nó vì VM cho rằng các tệp
sẽ được ghi vào kho dự phòng (chứ không phải không gian trao đổi), nhưng ramfs thì không
có bất kỳ cửa hàng hỗ trợ nào.  Vì điều này, chỉ có root (hoặc người dùng đáng tin cậy) mới nên
được phép truy cập ghi vào một ramfs mount.

Một dẫn xuất ramfs có tên là tmpfs đã được tạo ra để thêm giới hạn kích thước và khả năng
để ghi dữ liệu để hoán đổi không gian.  Người dùng bình thường có thể được phép truy cập ghi vào
gắn kết tmpfs.  Xem Tài liệu/hệ thống tập tin/tmpfs.rst để biết thêm thông tin.

rootfs là gì?
---------------

Rootfs là một phiên bản đặc biệt của ramfs (hoặc tmpfs, nếu tính năng này được bật), tức là
luôn hiện diện trong các hệ thống Linux.  Hạt nhân sử dụng một hệ thống tập tin trống bất biến
được gọi là nullfs là gốc thực sự của hệ thống phân cấp VFS, với các gốc có thể thay đổi
(tmpfs/ramfs) được gắn trên nó.  Điều này cho phép Pivot_root() và ngắt kết nối
của initramfs hoạt động bình thường.

Hầu hết các hệ thống chỉ gắn hệ thống tập tin khác lên rootfs và bỏ qua nó.  các
lượng không gian mà một phiên bản trống của ramf chiếm là rất nhỏ.

Nếu CONFIG_TMPFS được bật, rootfs sẽ sử dụng tmpfs thay vì ramfs bằng cách
mặc định.  Để buộc ramf, hãy thêm "rootfstype=ramfs" vào lệnh kernel
dòng.

initramfs là gì?
------------------

Tất cả các nhân Linux 2.6 đều chứa kho lưu trữ định dạng "cpio" được nén bằng gzipped.
được trích xuất vào rootfs khi kernel khởi động.  Sau khi giải nén, kernel
kiểm tra xem rootfs có chứa tệp "init" hay không và nếu có thì nó sẽ thực thi nó dưới dạng PID
1. Nếu tìm thấy, tiến trình init này sẽ chịu trách nhiệm đưa hệ thống
cho đến hết chặng đường còn lại, bao gồm việc định vị và gắn thiết bị gốc thực sự (nếu
bất kỳ).  Nếu rootfs không chứa chương trình init sau cpio được nhúng
kho lưu trữ được trích xuất vào đó, kernel sẽ chuyển sang mã cũ hơn
để xác định vị trí và gắn kết một phân vùng gốc, sau đó thực thi một số biến thể của /sbin/init
ra khỏi đó.

Tất cả điều này khác với initrd cũ ở một số điểm:

- Initrd cũ luôn là một tệp riêng biệt, trong khi kho lưu trữ initramfs là
    được liên kết vào hình ảnh hạt nhân linux.  (Thư mục ZZ0000ZZ là
    dành riêng cho việc tạo kho lưu trữ này trong quá trình xây dựng.)

- Tệp initrd cũ là hình ảnh hệ thống tệp được nén (ở một số định dạng tệp,
    chẳng hạn như ext2, cần có trình điều khiển được tích hợp trong kernel), trong khi phiên bản mới
    kho lưu trữ initramfs là một kho lưu trữ cpio được nén bằng gzid (như tar chỉ đơn giản hơn,
    xem cpio(1) và Tài liệu/driver-api/early-userspace/buffer-format.rst).
    Mã trích xuất cpio của kernel không chỉ cực kỳ nhỏ mà còn
    __init văn bản và dữ liệu có thể bị loại bỏ trong quá trình khởi động.

- Chương trình chạy bằng initrd cũ (gọi là /initrd chứ không phải /init) đã làm
    một số thiết lập và sau đó quay trở lại kernel, trong khi chương trình init từ
    initramfs dự kiến sẽ không quay trở lại kernel.  (Nếu /init cần trao tay
    mất kiểm soát, nó có thể vượt qua/bằng thiết bị root mới và thực thi init khác
    chương trình.  Xem tiện ích switch_root bên dưới.)

- Khi chuyển sang thiết bị root khác, initrd sẽ là Pivot_root và sau đó
    umount đĩa RAM.  Với nullfs là gốc thực sự, Pivot_root() hoạt động
    thông thường từ initramfs.  Không gian người dùng có thể chỉ cần làm::

chdir(new_root);
      Pivot_root(".", ".");
      umount2(".", MNT_DETACH);

Đây là phương pháp ưa thích để chuyển đổi hệ thống tập tin gốc.

Điền initramfs:
---------------------

Quá trình xây dựng kernel 2.6 luôn tạo initramfs định dạng cpio được nén
lưu trữ và liên kết nó vào hệ nhị phân hạt nhân thu được.  Theo mặc định, điều này
kho lưu trữ trống (tiêu thụ 134 byte trên x86).

Tùy chọn cấu hình CONFIG_INITRAMFS_SOURCE (trong Cài đặt chung trong menuconfig,
và sống trong usr/Kconfig) có thể được sử dụng để chỉ định nguồn cho
kho lưu trữ initramfs, sẽ tự động được tích hợp vào
kết quả nhị phân.  Tùy chọn này có thể trỏ tới một cpio được nén bằng gzid hiện có
archive, một thư mục chứa các tập tin cần lưu trữ hoặc một tập tin văn bản
đặc điểm kỹ thuật như ví dụ sau::

thư mục /dev 755 0 0
  gật đầu /dev/console 644 0 0 c 5 1
  gật đầu /dev/loop0 644 0 0 b 7 0
  thư mục /bin 755 1000 1000
  slink /bin/sh busybox 777 0 0
  tập tin /bin/busybox initramfs/busybox 755 0 0
  thư mục /proc 755 0 0
  thư mục /sys 755 0 0
  thư mục /mnt 755 0 0
  tập tin /init initramfs/init.sh 755 0 0

Chạy "usr/gen_init_cpio" (sau khi xây dựng kernel) để nhận thông báo sử dụng
ghi lại định dạng tập tin trên.

Một ưu điểm của tệp cấu hình là không cần quyền truy cập root để
đặt quyền hoặc tạo các nút thiết bị trong kho lưu trữ mới.  (Lưu ý rằng những
hai mục nhập "tệp" mẫu sẽ tìm thấy các tệp có tên "init.sh" và "busybox" trong
một thư mục có tên "initramfs", trong thư mục linux-2.6.*.  Xem
Documentation/driver-api/early-userspace/early_userspace_support.rst để biết thêm chi tiết.)

Kernel không phụ thuộc vào các công cụ cpio bên ngoài.  Nếu bạn chỉ định một
thư mục thay vì tệp cấu hình, cơ sở hạ tầng xây dựng của kernel
tạo một tập tin cấu hình từ thư mục đó (gọi usr/Makefile
usr/gen_initramfs.sh) và tiến hành đóng gói thư mục đó
bằng cách sử dụng tệp cấu hình (bằng cách cung cấp nó cho usr/gen_init_cpio, được tạo
từ usr/gen_init_cpio.c).  Mã tạo cpio thời gian xây dựng của kernel là
hoàn toàn khép kín và trình giải nén thời gian khởi động của kernel cũng
(rõ ràng) khép kín.

Một điều bạn có thể cần cài đặt các tiện ích cpio bên ngoài là tạo
hoặc trích xuất các tệp cpio đã chuẩn bị trước của riêng bạn để cung cấp cho bản dựng kernel
(thay vì tệp cấu hình hoặc thư mục).

Dòng lệnh sau có thể trích xuất hình ảnh cpio (bằng đoạn script trên
hoặc bằng cách xây dựng kernel) trở lại các tệp thành phần của nó ::

cpio -i -d -H newc -F initramfs_data.cpio --no-absolute-filenames

Tập lệnh shell sau đây có thể tạo một kho lưu trữ cpio dựng sẵn mà bạn có thể
sử dụng thay cho tệp cấu hình trên ::

#!/bin/sh

# Copyright 2006 Rob Landley <rob@landley.net> và Tập đoàn TimeSys.
  # Licensed dưới GPL phiên bản 2

nếu [ $# -ne 2]
  sau đó
    echo "cách sử dụng: thư mục mkinitramfs imagename.cpio.gz"
    lối ra 1
  fi

nếu [ -d "$1" ]
  sau đó
    echo "tạo $2 từ $1"
    (cd "$1"; tìm . ZZ0000ZZ gzip) > "$2"
  khác
    echo "Đối số đầu tiên phải là một thư mục"
    lối ra 1
  fi

.. Note::

   The cpio man page contains some bad advice that will break your initramfs
   archive if you follow it.  It says "A typical way to generate the list
   of filenames is with the find command; you should give find the -depth
   option to minimize problems with permissions on directories that are
   unwritable or not searchable."  Don't do this when creating
   initramfs.cpio.gz images, it won't work.  The Linux kernel cpio extractor
   won't create files in a directory that doesn't exist, so the directory
   entries must go before the files that go in those directories.
   The above script gets them in the right order.

Hình ảnh initramfs bên ngoài:
--------------------------

Nếu kernel đã bật hỗ trợ initrd thì kho lưu trữ cpio.gz bên ngoài cũng có thể
được chuyển vào kernel 2.6 thay cho initrd.  Trong trường hợp này, hạt nhân
sẽ tự động phát hiện loại (initramfs, không phải initrd) và trích xuất cpio bên ngoài
lưu trữ vào rootfs trước khi thử chạy /init.

Điều này có lợi thế về hiệu suất bộ nhớ của initramfs (không có khối đĩa ram
thiết bị) nhưng có bao bì riêng của initrd (thật tuyệt nếu bạn có
mã không phải GPL mà bạn muốn chạy từ initramfs mà không kết hợp nó với
nhị phân hạt nhân Linux được cấp phép GPL).

Nó cũng có thể được sử dụng để bổ sung cho hình ảnh initramfs tích hợp của kernel.  các
các tập tin trong kho lưu trữ bên ngoài sẽ ghi đè lên bất kỳ tập tin xung đột nào trong
kho lưu trữ initramfs tích hợp sẵn.  Một số nhà phân phối cũng thích tùy chỉnh
một hình ảnh hạt nhân với các hình ảnh initramfs dành riêng cho nhiệm vụ mà không cần biên dịch lại.

Nội dung của initramfs:
----------------------

Kho lưu trữ initramfs là một hệ thống tập tin gốc độc lập hoàn chỉnh dành cho Linux.
Nếu bạn chưa hiểu thư viện, thiết bị và đường dẫn dùng chung
bạn cần thiết lập và chạy một hệ thống tập tin gốc tối thiểu, đây là một số
tài liệu tham khảo:

-ZZ0000ZZ
-ZZ0001ZZ
-ZZ0002ZZ

Gói "klibc" (ZZ0000ZZ là
được thiết kế để trở thành một thư viện C nhỏ để liên kết tĩnh không gian người dùng ban đầu
mã chống lại, cùng với một số tiện ích liên quan.  Nó được cấp phép BSD.

Tôi sử dụng uClibc (ZZ0000ZZ và busybox (ZZ0001ZZ
bản thân tôi.  Đây lần lượt là LGPL và GPL.  (Một initramfs khép kín
gói được lên kế hoạch cho bản phát hành busybox 1.3.)

Về lý thuyết, bạn có thể sử dụng glibc, nhưng điều đó không phù hợp với các ứng dụng nhúng nhỏ
công dụng như thế này.  (Chương trình "hello world" được liên kết tĩnh với glibc là
hơn 400k.  Với uClibc là 7k.  Cũng lưu ý rằng glibc giảm libnss để làm
tra cứu tên, ngay cả khi được liên kết tĩnh.)

Bước đầu tiên tốt nhất là tải initramfs để chạy "xin chào thế giới" được liên kết tĩnh
lập trình dưới dạng init và kiểm tra nó bằng trình giả lập như qemu (www.qemu.org) hoặc
Chế độ người dùng Linux, như vậy::

mèo > xin chào.c << EOF
  #include <stdio.h>
  #include <unistd.h>

int main(int argc, char *argv[])
  {
    printf("Xin chào thế giới!\n");
    ngủ(999999999);
  }
  EOF
  gcc -static hello.c -o init
  echo init ZZ0000ZZ gzip > test.cpio.gz
  Các initramf bên ngoài # Testing sử dụng cơ chế tải initrd.
  qemu -kernel /boot/vmlinuz -initrd test.cpio.gz /dev/zero

Khi gỡ lỗi hệ thống tập tin gốc thông thường, thật tuyệt khi có thể khởi động bằng
"init=/bin/sh".  Tương đương initramfs là "rdinit=/bin/sh" và nó là
vừa hữu ích.

Tại sao cpio chứ không phải tar?
-------------------------

Quyết định này được đưa ra vào tháng 12 năm 2001. Cuộc thảo luận bắt đầu ở đây:

-ZZ0000ZZ

Và sinh ra một luồng thứ hai (cụ thể là trên tar vs cpio), bắt đầu từ đây:

-ZZ0000ZZ

Phiên bản tóm tắt nhanh chóng và bẩn thỉu (không thể thay thế cho việc đọc
các chủ đề trên) là:

1) cpio là một tiêu chuẩn.  Nó đã có tuổi đời hàng thập kỷ (kể từ thời AT&T) và đã
   được sử dụng rộng rãi trên Linux (bên trong RPM, đĩa trình điều khiển thiết bị của Red Hat).  Đây là
   một bài viết trên Tạp chí Linux về nó từ năm 1996:

ZZ0000ZZ

Nó không phổ biến như tar vì các công cụ dòng lệnh cpio truyền thống
   yêu cầu đối số dòng lệnh _truly_hideous_.  Nhưng điều đó không nói lên điều gì
   dù thế nào đi nữa về định dạng lưu trữ và có các công cụ thay thế,
   chẳng hạn như:

ZZ0000ZZ

2) Định dạng lưu trữ cpio được kernel chọn đơn giản và sạch hơn (và
   do đó dễ tạo và phân tích cú pháp hơn bất kỳ (nghĩa đen là hàng chục)
   các định dạng lưu trữ tar khác nhau.  Định dạng lưu trữ initramfs hoàn chỉnh là
   được giải thích trong buffer-format.rst, được tạo trong usr/gen_init_cpio.c và
   được trích xuất trong init/initramfs.c.  Cả 3 cộng lại chưa đến 26k
   tổng số văn bản con người có thể đọc được.

3) Việc tiêu chuẩn hóa dự án GNU về tar gần như phù hợp như
   Tiêu chuẩn hóa Windows trên zip.  Linux không phải là một phần của cả hai và hoàn toàn miễn phí
   đưa ra các quyết định kỹ thuật của riêng mình.

4) Vì đây là định dạng nội bộ của kernel nên nó có thể dễ dàng bị
   một cái gì đó hoàn toàn mới.  Hạt nhân cung cấp các công cụ riêng để tạo và
   vẫn giải nén định dạng này.  Ưu tiên sử dụng tiêu chuẩn hiện có,
   nhưng không cần thiết.

5) Al Viro đã đưa ra quyết định (trích dẫn: "tar xấu như địa ngục và sẽ không như vậy
   được hỗ trợ ở phía kernel"):

-ZZ0000ZZ

giải thích lý do của mình:

-ZZ0000ZZ
    -ZZ0001ZZ

và quan trọng nhất là thiết kế và triển khai mã initramfs.

Định hướng tương lai:
------------------

Ngày nay (2.6.16), initramfs luôn được biên dịch nhưng không phải lúc nào cũng được sử dụng.  các
kernel quay trở lại mã khởi động kế thừa chỉ đạt được nếu initramfs thực hiện
không chứa chương trình /init.  Dự phòng là mã kế thừa, ở đó để đảm bảo
chuyển tiếp suôn sẻ và cho phép chức năng khởi động sớm chuyển dần sang
"không gian người dùng sớm" (I.E. initramfs).

Việc chuyển sang không gian người dùng sớm là cần thiết vì việc tìm kiếm và gắn kết thực
thiết bị root rất phức tạp.  Phân vùng gốc có thể mở rộng trên nhiều thiết bị (đột kích hoặc
nhật ký riêng).  Chúng có thể ở ngoài mạng (yêu cầu dhcp, cài đặt
địa chỉ MAC cụ thể, đăng nhập vào máy chủ, v.v.).  Họ có thể sống trên di động
phương tiện truyền thông, với các số chính/phụ được phân bổ động và đặt tên liên tục
các vấn đề yêu cầu triển khai udev đầy đủ để giải quyết.  Họ có thể
được nén, mã hóa, sao chép khi ghi, gắn vòng lặp, phân vùng lạ,
và vân vân.

Loại phức tạp này (chắc chắn bao gồm chính sách) được xử lý đúng cách
trong không gian người dùng.  Cả klibc và busybox/uClibc đều đang hoạt động trên các initramfs đơn giản
các gói để thả vào bản dựng kernel.

Gói klibc hiện đã được chấp nhận vào cây 2,6,17 mm của Andrew Morton.
Mã khởi động sớm hiện tại của kernel (phát hiện phân vùng, v.v.) có thể sẽ
được di chuyển sang initramfs mặc định, được tạo và sử dụng tự động bởi
xây dựng hạt nhân.