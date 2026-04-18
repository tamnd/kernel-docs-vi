.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/initrd.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Sử dụng đĩa RAM ban đầu (initrd)
===================================

Được viết năm 1996,2000 bởi Werner Almesberger <werner.almesberger@epfl.ch> và
Hans Lermen <lermen@fgan.de>


initrd cung cấp khả năng tải đĩa RAM bằng bộ tải khởi động.
Đĩa RAM này sau đó có thể được gắn làm chương trình và hệ thống tệp gốc
có thể chạy khỏi nó. Sau đó, một hệ thống tập tin gốc mới có thể được gắn kết
từ một thiết bị khác. Root trước đó (từ initrd) sau đó được di chuyển
vào một thư mục và sau đó có thể được ngắt kết nối.

initrd được thiết kế chủ yếu để cho phép khởi động hệ thống diễn ra theo hai giai đoạn,
trong đó kernel xuất hiện một bộ trình điều khiển được biên dịch sẵn tối thiểu và
nơi các mô-đun bổ sung được tải từ initrd.

Tài liệu này cung cấp một cái nhìn tổng quan ngắn gọn về việc sử dụng initrd. Chi tiết hơn
thảo luận về quá trình khởi động có thể được tìm thấy trong [#f1]_.


Hoạt động
---------

Khi sử dụng initrd, hệ thống thường khởi động như sau:

1) bộ tải khởi động tải kernel và đĩa RAM ban đầu
  2) kernel chuyển đổi initrd thành đĩa RAM "bình thường" và
     giải phóng bộ nhớ được sử dụng bởi initrd
  3) nếu thiết bị gốc không phải là ZZ0000ZZ thì thiết bị cũ (không được dùng nữa)
     thủ tục Change_root được tuân theo. xem "Thay đổi gốc lỗi thời
     phần cơ chế" bên dưới.
  4) thiết bị gốc đã được gắn kết. nếu là ZZ0001ZZ, hình ảnh ban đầu là
     sau đó gắn kết với quyền root
  5) /sbin/init được thực thi (điều này có thể là bất kỳ tệp thực thi hợp lệ nào, bao gồm
     tập lệnh shell; nó được chạy với uid 0 và về cơ bản có thể làm mọi thứ
     init có thể làm được).
  6) init gắn kết hệ thống tập tin gốc "thực"
  7) init đặt hệ thống tập tin gốc vào thư mục gốc bằng cách sử dụng lệnh
     lệnh gọi hệ thống Pivot_root
  8) init thực thi ZZ0002ZZ trên hệ thống tập tin gốc mới, thực hiện
     trình tự khởi động thông thường
  9) hệ thống tập tin initrd bị xóa

Lưu ý rằng việc thay đổi thư mục gốc không liên quan đến việc ngắt kết nối nó.
Do đó có thể để các tiến trình chạy trên initrd trong thời gian đó.
thủ tục. Cũng lưu ý rằng các hệ thống tập tin được gắn trong initrd tiếp tục
có thể truy cập được.


Tùy chọn dòng lệnh khởi động
-------------------------

initrd thêm các tùy chọn mới sau::

initrd=<path> (ví dụ LOADLIN)

Tải tệp được chỉ định dưới dạng đĩa RAM ban đầu. Khi sử dụng LILO, bạn
    phải chỉ định tệp ảnh đĩa RAM trong /etc/lilo.conf, bằng cách sử dụng
    Biến cấu hình INITRD.

noinitrd

dữ liệu initrd được giữ nguyên nhưng nó không được chuyển đổi sang đĩa RAM và
    hệ thống tập tin gốc "bình thường" được gắn kết. dữ liệu initrd có thể được đọc
    từ /dev/initrd. Lưu ý rằng dữ liệu trong initrd có thể có bất kỳ cấu trúc nào
    trong trường hợp này và không nhất thiết phải là hình ảnh hệ thống tệp.
    Tùy chọn này được sử dụng chủ yếu để gỡ lỗi.

Lưu ý: /dev/initrd ở chế độ chỉ đọc và chỉ có thể sử dụng một lần. càng sớm càng tốt
    vì quá trình cuối cùng đã đóng nó, tất cả dữ liệu sẽ được giải phóng và /dev/initrd
    không thể mở được nữa.

root=/dev/ram0

initrd được gắn dưới dạng root và tuân theo quy trình khởi động bình thường,
    với đĩa RAM được gắn dưới dạng root.

Hình ảnh cpio nén
----------------------

Các hạt nhân gần đây có hỗ trợ điền vào đĩa RAM từ cpio đã nén
archive. Trên các hệ thống như vậy, việc tạo hình ảnh đĩa RAM không cần
liên quan đến các thiết bị khối đặc biệt hoặc vòng lặp; bạn chỉ cần tạo một thư mục trên
đĩa có nội dung initrd mong muốn, cd vào thư mục đó và chạy (dưới dạng
ví dụ)::

tìm thấy . ZZ0000ZZ gzip -9 -n > /boot/imagefile.img

Việc kiểm tra nội dung của tệp hình ảnh hiện có cũng đơn giản như vậy ::

mkdir /tmp/tệp hình ảnh
	cd /tmp/tệp hình ảnh
	gzip -cd /boot/imagefile.img | cpio -imd --quiet

Cài đặt
------------

Đầu tiên, một thư mục cho hệ thống tập tin initrd phải được tạo trên
hệ thống tập tin gốc "bình thường", ví dụ::

# mkdir /initrd

Cái tên không liên quan. Thông tin chi tiết có thể được tìm thấy trên
Trang người đàn ông ZZ0000ZZ.

Nếu hệ thống tập tin gốc được tạo trong quá trình khởi động (tức là nếu
bạn đang xây dựng một đĩa mềm cài đặt), việc tạo hệ thống tập tin gốc
thủ tục sẽ tạo thư mục ZZ0000ZZ.

Nếu initrd không được gắn kết trong một số trường hợp thì nội dung của nó vẫn
có thể truy cập nếu thiết bị sau đã được tạo::

# mknod /dev/initrd b 1 250
	# chmod 400 /dev/initrd

Thứ hai, kernel phải được biên dịch với sự hỗ trợ của đĩa RAM và với
hỗ trợ cho đĩa RAM ban đầu được kích hoạt. Ngoài ra, ít nhất tất cả các thành phần
cần thiết để thực thi các chương trình từ initrd (ví dụ: định dạng thực thi và tệp
system) phải được biên dịch vào kernel.

Thứ ba, bạn phải tạo image đĩa RAM. Điều này được thực hiện bằng cách tạo ra một
hệ thống tập tin trên một thiết bị khối, sao chép các tập tin vào đó nếu cần, sau đó
sao chép nội dung của thiết bị khối vào tệp initrd. Với gần đây
hạt nhân, ít nhất ba loại thiết bị phù hợp cho việc đó:

- một đĩa mềm (hoạt động ở mọi nơi nhưng rất chậm)
 - đĩa RAM (nhanh, nhưng phân bổ bộ nhớ vật lý)
 - một thiết bị loopback (giải pháp tao nhã nhất)

Chúng tôi sẽ mô tả phương pháp thiết bị loopback:

1) đảm bảo các thiết bị khối loopback được cấu hình trong kernel
 2) tạo một hệ thống tệp trống có kích thước phù hợp, ví dụ::

# dd if=/dev/zero of=initrd bs=300k count=1
	# mke2fs -F -m0 initrd

(nếu dung lượng rất quan trọng, bạn có thể muốn sử dụng Minix FS thay vì Ext2)
 3) gắn kết hệ thống tập tin, ví dụ::

# mount -t ext2 -o vòng lặp initrd /mnt

4) tạo thiết bị bảng điều khiển::

# mkdir /mnt/dev
    # mknod /mnt/dev/console c 5 1

5) sao chép tất cả các tệp cần thiết để sử dụng initrd đúng cách
    môi trường. Đừng quên tệp quan trọng nhất, ZZ0000ZZ

    .. note:: ``/sbin/init`` permissions must include "x" (execute).

6) hoạt động chính xác, môi trường initrd có thể được kiểm tra thường xuyên
    ngay cả khi không khởi động lại bằng lệnh ::

# chroot /mnt /sbin/init

Tất nhiên điều này chỉ giới hạn ở những lệnh initrd không can thiệp vào
    trạng thái hệ thống chung (ví dụ: bằng cách cấu hình lại các giao diện mạng,
    ghi đè các thiết bị được gắn, cố gắng bắt đầu chạy quỷ,
    v.v. Tuy nhiên, xin lưu ý rằng thường có thể sử dụng Pivot_root trong
    một môi trường initrd chroot như vậy.)
 7) ngắt kết nối hệ thống tập tin::

# umount /mnt

8) initrd hiện có trong tệp "initrd". Tùy chọn, bây giờ nó có thể được
    nén::

# gzip -9 initrd

Để thử nghiệm với initrd, bạn có thể muốn lấy một đĩa mềm cứu hộ và
chỉ thêm một liên kết tượng trưng từ ZZ0000ZZ đến ZZ0001ZZ. Ngoài ra, bạn
có thể thử môi trường newlib thử nghiệm [#f2]_ để tạo một môi trường nhỏ
initrd.

Cuối cùng, bạn phải khởi động kernel và tải initrd. Hầu như tất cả Linux
bộ tải khởi động hỗ trợ initrd. Vì quá trình khởi động vẫn tương thích
với cơ chế cũ hơn, các tham số dòng lệnh khởi động sau
phải được đưa ra::

root=/dev/ram0 rw

(rw chỉ cần thiết nếu ghi vào hệ thống tệp initrd.)

Với LOADLIN, bạn chỉ cần thực hiện::

LOADLIN <kernel> initrd=<disk_image>

ví dụ.::

LOADLIN C:\LINUX\BZIMAGE initrd=C:\LINUX\INITRD.GZ root=/dev/ram0 rw

Với LILO, bạn thêm tùy chọn ZZ0000ZZ vào phần chung
hoặc đến phần kernel tương ứng trong ZZ0001ZZ và chuyển
các tùy chọn sử dụng APPEND, ví dụ::

hình ảnh = /bzImage
    initrd = /boot/initrd.gz
    nối thêm = "root=/dev/ram0 rw"

và chạy ZZ0000ZZ

Đối với các bộ tải khởi động khác, vui lòng tham khảo tài liệu tương ứng.

Bây giờ bạn có thể khởi động và tận hưởng việc sử dụng initrd.


Thay đổi thiết bị gốc
------------------------

Khi hoàn thành nhiệm vụ của mình, init thường thay đổi thiết bị gốc
và tiến hành khởi động hệ thống Linux trên thiết bị gốc "thực".

Quy trình này bao gồm các bước sau:
 - gắn hệ thống tập tin gốc mới
 - biến nó thành hệ thống tập tin gốc
 - xóa tất cả quyền truy cập vào hệ thống tập tin gốc (initrd) cũ
 - ngắt kết nối hệ thống tệp initrd và phân bổ lại đĩa RAM

Việc gắn hệ thống tập tin gốc mới thật dễ dàng: nó chỉ cần được gắn vào
một thư mục dưới thư mục gốc hiện tại. Ví dụ::

# mkdir /root mới
	# mount -o ro /dev/hda1 /new-root

Thay đổi gốc được thực hiện bằng lệnh gọi hệ thống Pivot_root, lệnh này
cũng có sẵn thông qua tiện ích ZZ0001ZZ (xem ZZ0000ZZ
trang người đàn ông; ZZ0002ZZ được phân phối với phiên bản util-linux 2.10h trở lên
[#f3]_). ZZ0003ZZ di chuyển thư mục gốc hiện tại vào một thư mục bên dưới thư mục mới
root và đặt root mới vào vị trí của nó. Thư mục gốc cũ
phải tồn tại trước khi gọi ZZ0004ZZ. Ví dụ::

# cd /root mới
	# mkdir ban đầu
	# pivot_root. initrd

Bây giờ, tiến trình init vẫn có thể truy cập vào root cũ thông qua nó.
thực thi, thư viện dùng chung, đầu vào/đầu ra/lỗi tiêu chuẩn và
thư mục gốc hiện hành. Tất cả các tài liệu tham khảo này được loại bỏ bởi
lệnh sau::

Chroot # exec . những gì tiếp theo <dev/console >dev/console 2>&1

Trong đó phần tiếp theo là một chương trình có gốc mới, ví dụ: ZZ0000ZZ
Nếu hệ thống tập tin gốc mới sẽ được sử dụng với udev và không có giá trị hợp lệ
Thư mục ZZ0001ZZ, udev phải được khởi tạo trước khi gọi chroot theo thứ tự
để cung cấp ZZ0002ZZ.

Lưu ý: chi tiết triển khai của Pivot_root có thể thay đổi theo thời gian. theo thứ tự
để đảm bảo tính tương thích, cần lưu ý những điểm sau:

- trước khi gọi Pivot_root, thư mục hiện tại của lệnh gọi
   quá trình nên trỏ đến thư mục gốc mới
 - sử dụng . làm đối số đầu tiên và đường dẫn _relative_ của thư mục
   lấy gốc cũ làm đối số thứ hai
 - chương trình chroot phải có sẵn dưới root cũ và mới
 - sau đó chroot sang root mới
 - sử dụng đường dẫn tương đối cho dev/console trong lệnh exec

Bây giờ, initrd có thể được ngắt kết nối và bộ nhớ được RAM phân bổ
đĩa có thể được giải phóng::

# umount /initrd
	# blockdev --flushbufs/dev/ram0

Cũng có thể sử dụng initrd với root gắn trên NFS, xem phần
Trang người dùng ZZ0000ZZ để biết chi tiết.


kịch bản sử dụng
---------------

Động lực chính để triển khai initrd là cho phép mô-đun
cấu hình kernel khi cài đặt hệ thống. Quy trình sẽ hoạt động
như sau:

1) hệ thống khởi động từ đĩa mềm hoặc phương tiện khác có hạt nhân tối thiểu
     (ví dụ: hỗ trợ cho các đĩa RAM, initrd, a.out và Ext2 FS) và
     tải initrd
  2) ZZ0000ZZ xác định những gì cần thiết để (1) gắn kết FS gốc "thực"
     (tức là loại thiết bị, trình điều khiển thiết bị, hệ thống tệp) và (2)
     phương tiện phân phối (ví dụ: CD-ROM, mạng, băng từ, ...). Đây có thể là
     được thực hiện bằng cách hỏi người dùng, bằng cách tự động thăm dò hoặc bằng cách sử dụng kết hợp
     cách tiếp cận.
  3) ZZ0001ZZ tải các mô-đun hạt nhân cần thiết
  4) ZZ0002ZZ tạo và điền vào hệ thống tập tin gốc (điều này không
     phải là một hệ thống rất có thể sử dụng được)
  5) ZZ0003ZZ gọi ZZ0004ZZ để thay đổi hệ thống tập tin gốc và
     execs - thông qua chroot - một chương trình tiếp tục cài đặt
  6) bộ tải khởi động đã được cài đặt
  7) bộ tải khởi động được cấu hình để tải initrd với tập hợp
     các mô-đun đã được sử dụng để hiển thị hệ thống (ví dụ: ZZ0005ZZ có thể
     được sửa đổi, sau đó ngắt kết nối và cuối cùng, hình ảnh được ghi từ
     ZZ0006ZZ hoặc ZZ0007ZZ vào một tệp)
  8) bây giờ hệ thống đã có khả năng khởi động và các tác vụ cài đặt bổ sung có thể được thực hiện
     thực hiện

Vai trò chính của initrd ở đây là sử dụng lại dữ liệu cấu hình trong quá trình
hoạt động bình thường của hệ thống mà không yêu cầu sử dụng "chung" cồng kềnh
kernel hoặc biên dịch lại hoặc liên kết lại kernel.

Kịch bản thứ hai dành cho các bản cài đặt trong đó Linux chạy trên các hệ thống có
cấu hình phần cứng khác nhau trong một miền quản trị. trong
những trường hợp như vậy, mong muốn chỉ tạo ra một tập hợp nhỏ các hạt nhân
(lý tưởng nhất là chỉ một) và để giữ phần cấu hình dành riêng cho hệ thống
thông tin càng nhỏ càng tốt. Trong trường hợp này, một initrd chung có thể là
được tạo ra với tất cả các mô-đun cần thiết. Sau đó, chỉ ZZ0000ZZ hoặc một tập tin
đọc bởi nó sẽ phải khác nhau.

Kịch bản thứ ba là đĩa khôi phục thuận tiện hơn vì thông tin
giống như vị trí của phân vùng FS gốc không cần phải được cung cấp tại
thời gian khởi động, nhưng hệ thống được tải từ initrd có thể gọi một giao diện thân thiện với người dùng
hộp thoại và nó cũng có thể thực hiện một số kiểm tra độ chính xác (hoặc thậm chí một số dạng
tự động phát hiện).

Cuối cùng, các nhà phân phối CD-ROM có thể sử dụng nó để cài đặt tốt hơn
từ CD, ví dụ: bằng cách sử dụng đĩa mềm khởi động và khởi động một đĩa RAM lớn hơn
thông qua initrd từ CD; hoặc bằng cách khởi động qua trình tải như ZZ0000ZZ hoặc trực tiếp
từ CD-ROM và tải đĩa RAM từ CD mà không cần
đĩa mềm.


Cơ chế thay đổi gốc lỗi thời
------------------------------

Cơ chế sau đây đã được sử dụng trước khi giới thiệu Pivot_root.
Các hạt nhân hiện tại vẫn hỗ trợ nó, nhưng bạn _không_ nên dựa vào nó
tiếp tục có sẵn.

Nó hoạt động bằng cách gắn thiết bị gốc "thực" (tức là thiết bị có rdev
trong ảnh kernel hoặc với root=... ở dòng lệnh khởi động) làm
hệ thống tập tin gốc khi linuxrc thoát. Hệ thống tập tin initrd sau đó là
chưa được kết nối hoặc nếu nó vẫn bận, hãy chuyển đến thư mục ZZ0000ZZ, nếu
thư mục như vậy tồn tại trên hệ thống tập tin gốc mới.

Để sử dụng cơ chế này, bạn không cần phải chỉ định địa chỉ khởi động.
tùy chọn lệnh root, init hoặc rw. (Nếu được chỉ định, chúng sẽ ảnh hưởng
hệ thống tập tin gốc thực sự, không phải môi trường initrd.)

Nếu /proc được gắn kết, thiết bị gốc "thực" có thể được thay đổi từ bên trong
linuxrc bằng cách ghi số thiết bị FS gốc mới vào trường đặc biệt
tập tin /proc/sys/kernel/real-root-dev, ví dụ::

# echo 0x301 >/proc/sys/kernel/real-root-dev

Lưu ý rằng cơ chế này không tương thích với NFS và tệp tương tự
hệ thống.

Cơ chế cũ, không được dùng nữa này thường được gọi là ZZ0000ZZ, trong khi
cơ chế mới được hỗ trợ có tên là ZZ0001ZZ.


Cơ chế hỗn hợp Change_root và Pivot_root
------------------------------------------

Trong trường hợp bạn không muốn sử dụng ZZ0000ZZ để kích hoạt Pivot_root
cơ chế, bạn có thể tạo cả ZZ0001ZZ và ZZ0002ZZ trong initrd của mình
hình ảnh.

ZZ0000ZZ sẽ chỉ chứa những nội dung sau::

#! /bin/sh
	mount -n -t proc /proc
	echo 0x0100 >/proc/sys/kernel/real-root-dev
	umount -n /proc

Khi linuxrc thoát, kernel sẽ gắn lại initrd của bạn với quyền root,
lần này thực hiện ZZ0000ZZ. Một lần nữa, nhiệm vụ của init này là
để xây dựng môi trường phù hợp (có thể sử dụng ZZ0001ZZ được truyền lại
cmdline) trước khi thực thi cuối cùng ZZ0002ZZ thực.


Tài nguyên
---------

.. [#f1] Almesberger, Werner; "Booting Linux: The History and the Future"
    https://www.almesberger.net/cv/papers/ols2k-9.ps.gz
.. [#f2] newlib package (experimental), with initrd example
    https://www.sourceware.org/newlib/
.. [#f3] util-linux: Miscellaneous utilities for Linux
    https://www.kernel.org/pub/linux/utils/util-linux/
