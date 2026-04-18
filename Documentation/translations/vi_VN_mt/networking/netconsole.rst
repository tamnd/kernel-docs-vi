.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/netconsole.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========
Netconsole
==========


bắt đầu bởi Ingo Molnar <mingo@redhat.com>, 2001.09.17

Cổng 2.6 và api netpoll của Matt Mackall <mpm@selenic.com>, ngày 9 tháng 9 năm 2003

Hỗ trợ IPv6 bởi Cong Wang <xiyou.wangcong@gmail.com>, ngày 1 tháng 1 năm 2013

Hỗ trợ bảng điều khiển mở rộng của Tejun Heo <tj@kernel.org>, ngày 1 tháng 5 năm 2015

Phát hành hỗ trợ trả trước của Breno Leitao <leitao@debian.org>, ngày 7 tháng 7 năm 2023

Hỗ trợ thêm dữ liệu người dùng của Matthew Wood <thepacketgeek@gmail.com>, ngày 22 tháng 1 năm 2024

Hỗ trợ thêm Sysdata của Breno Leitao <leitao@debian.org>, ngày 15 tháng 1 năm 2025

Giới thiệu:
=============

Mô-đun này ghi lại các thông báo printk kernel trên UDP cho phép gỡ lỗi
vấn đề trong đó việc ghi đĩa không thành công và bảng điều khiển nối tiếp không thực tế.

Nó có thể được sử dụng tích hợp hoặc như một mô-đun. Là một tính năng tích hợp sẵn,
netconsole khởi chạy ngay sau thẻ NIC và sẽ hiển thị
giao diện được chỉ định càng sớm càng tốt. Trong khi điều này không cho phép
nắm bắt được sự hoảng loạn của kernel ban đầu, nó chiếm được phần lớn quá trình khởi động
quá trình.

Cấu hình người gửi và người nhận:
==================================

Nó nhận tham số cấu hình chuỗi "netconsole" trong
định dạng sau::

netconsole=[+][r][src-port]@[src-ip]/[<dev>],[tgt-port]@<tgt-ip>/[tgt-macaddr]

ở đâu
	+ nếu có, hãy bật hỗ trợ bảng điều khiển mở rộng
	r nếu có, hãy thêm phiên bản kernel (bản phát hành) vào tin nhắn
	nguồn cổng src cho các gói UDP (mặc định là 6665)
	IP nguồn src-ip để sử dụng (địa chỉ giao diện)
	tên giao diện mạng dev (eth0) hoặc địa chỉ MAC
	cổng tgt-port cho tác nhân ghi nhật ký (6666)
	Địa chỉ IP tgt-ip cho tác nhân ghi nhật ký
	tgt-macaddr ethernet MAC địa chỉ cho tác nhân ghi nhật ký (phát sóng)

Ví dụ::

linux netconsole=4444@10.0.0.1/eth1,9353@10.0.0.2/12:34:56:78:9a:bc

hoặc::

insmod netconsole netconsole=@/,@10.0.0.2/

hoặc sử dụng IPv6::

insmod netconsole netconsole=@/,@fd00:1:2:3::1/

hoặc sử dụng địa chỉ MAC để chọn giao diện đầu ra::

linux netconsole=4444@10.0.0.1/22:33:44:55:66:77,9353@10.0.0.2/12:34:56:78:9a:bc

Nó cũng hỗ trợ đăng nhập vào nhiều tác nhân từ xa bằng cách chỉ định
các tham số cho nhiều tác nhân được phân tách bằng dấu chấm phẩy và
chuỗi hoàn chỉnh được đặt trong "dấu ngoặc kép", do đó ::

modprobe netconsole netconsole="@/,@10.0.0.2/;@/eth1,6892@10.0.0.3/"

Netconsole tích hợp sẽ khởi động ngay sau khi ngăn xếp TCP
được khởi tạo và cố gắng hiển thị nhà phát triển được cung cấp ở vị trí được cung cấp
địa chỉ.

Máy chủ từ xa có một số tùy chọn để nhận thông báo kernel,
ví dụ:

1) nhật ký hệ thống

2) mạng lưới

Trên các bản phân phối sử dụng phiên bản netcat dựa trên BSD (ví dụ: Fedora,
   openSUSE và Ubuntu), cổng nghe phải được chỉ định mà không có
   công tắc -p::

nc -u -l -p <port>' / 'nc -u -l <port>

hoặc::

netcat -u -l -p <port>' / 'netcat -u -l <port>

3) xã hội

::

socat udp-recv:<port> -

Cấu hình lại động:
========================

Khả năng cấu hình lại động là một bổ sung hữu ích cho netconsole cho phép
các mục tiêu ghi nhật ký từ xa sẽ được thêm, xóa hoặc có một cách linh hoạt
các tham số được cấu hình lại trong thời gian chạy từ giao diện không gian người dùng dựa trên configfs.

Để bao gồm tính năng này, hãy chọn CONFIG_NETCONSOLE_DYNAMIC khi xây dựng
mô-đun netconsole (hoặc kernel, nếu netconsole được tích hợp sẵn).

Một số ví dụ sau (trong đó configfs được gắn vào /sys/kernel/config
điểm gắn kết).

Để thêm mục tiêu ghi nhật ký từ xa (tên mục tiêu có thể tùy ý)::

cd /sys/kernel/config/netconsole/
 mục tiêu mkdir1

Lưu ý rằng các mục tiêu mới được tạo có giá trị tham số mặc định (như đã đề cập
ở trên) và bị tắt theo mặc định -- trước tiên chúng phải được bật bằng cách viết
"1" thành thuộc tính "đã bật" (thường là sau khi cài đặt tham số tương ứng)
như được mô tả dưới đây.

Để xóa mục tiêu::

rmdir /sys/kernel/config/netconsole/othertarget/

Giao diện hiển thị các tham số này của mục tiêu netconsole cho không gian người dùng:

=================================================================
	đã bật Mục tiêu này hiện có được bật không?	(đọc-ghi)
	đã bật chế độ mở rộng (đọc-ghi)
	phát hành Thêm bản phát hành kernel vào tin nhắn (đọc-ghi)
	dev_name Tên giao diện mạng cục bộ (đọc-ghi)
	local_port Cổng UDP nguồn để sử dụng (đọc-ghi)
	remote_port Cổng UDP của tác nhân từ xa (đọc-ghi)
	local_ip Địa chỉ IP nguồn sẽ sử dụng (đọc-ghi)
	remote_ip Địa chỉ IP của tác nhân từ xa (đọc-ghi)
	local_mac Địa chỉ MAC của giao diện cục bộ (chỉ đọc)
	remote_mac Địa chỉ MAC của tác nhân từ xa (đọc-ghi)
	transfer_errors Số lượng lỗi gửi gói (chỉ đọc)
	=================================================================

Thuộc tính "enabled" cũng được sử dụng để kiểm soát xem các tham số của
mục tiêu có thể được cập nhật hoặc không - bạn chỉ có thể sửa đổi các tham số của
mục tiêu bị vô hiệu hóa (tức là nếu "đã bật" là 0).

Để cập nhật các tham số của mục tiêu::

cat đã bật # check nếu bật là 1
 echo 0 > kích hoạt # disable mục tiêu (nếu cần)
 echo eth2 > dev_name # set giao diện cục bộ
 echo 10.0.0.4 > remote_ip # update một số tham số
 echo cb:a9:87:65:43:21 > remote_mac # update thêm thông số
 echo 1 > bật lại mục tiêu # enable

Bạn cũng có thể cập nhật giao diện cục bộ một cách linh hoạt. Điều này đặc biệt
hữu ích nếu bạn muốn sử dụng các giao diện mới xuất hiện (và có thể không
đã tồn tại khi netconsole được tải/khởi tạo).

Các mục tiêu Netconsole được xác định tại thời điểm khởi động (hoặc thời gian tải mô-đun) bằng
Thông số ZZ0000ZZ được gán tên ZZ0001ZZ.  Ví dụ,
mục tiêu đầu tiên trong tham số có tên là ZZ0002ZZ.  Bạn có thể kiểm soát và sửa đổi
các mục tiêu này bằng cách tạo các thư mục configfs có tên phù hợp.

Giả sử bạn có hai mục tiêu netconsole được xác định khi khởi động ::

netconsole=4444@10.0.0.1/eth1,9353@10.0.0.2/12:34:56:78:9a:bc;4444@10.0.0.1/eth1,9353@10.0.0.3/12:34:56:78:9a:bc

Bạn có thể sửa đổi các mục tiêu này trong thời gian chạy bằng cách tạo các mục tiêu sau::

mkdir cmdline0
 mèo cmdline0/remote_ip
 10.0.0.2

mkdir cmdline1
 mèo cmdline1/remote_ip
 10.0.0.3

Nối thêm dữ liệu người dùng
----------------

Dữ liệu người dùng tùy chỉnh có thể được thêm vào cuối tin nhắn bằng netconsole
cấu hình động được kích hoạt. Các mục nhập dữ liệu người dùng có thể được sửa đổi mà không cần
thay đổi thuộc tính "đã bật" của mục tiêu.

Các thư mục (khóa) trong ZZ0000ZZ được giới hạn ở độ dài 53 ký tự và
dữ liệu trong ZZ0001ZZ được giới hạn ở 200 byte::

cd /sys/kernel/config/netconsole && mkdir cmdline0
 cd cmdline0
 dữ liệu người dùng mkdir/foo
 thanh echo > dữ liệu người dùng/foo/giá trị
 dữ liệu người dùng mkdir/qux
 echo baz > dữ liệu người dùng/qux/giá trị

Tin nhắn bây giờ sẽ bao gồm dữ liệu người dùng bổ sung này::

echo "Đây là tin nhắn" > /dev/kmsg

Gửi::

12,607,22085407756,-;Đây là tin nhắn
  foo=thanh
  qux=baz

Xem trước dữ liệu người dùng sẽ được thêm vào::

cd /sys/kernel/config/netconsole/cmdline0/userdata
 cho f trong ZZ0000ZZ; làm echo $f=$(cat userdata/$f/value); xong

Nếu mục nhập ZZ0000ZZ được tạo nhưng không có dữ liệu nào được ghi vào tệp ZZ0001ZZ,
mục nhập sẽ bị bỏ qua khỏi tin nhắn netconsole::

cd /sys/kernel/config/netconsole && mkdir cmdline0
 cd cmdline0
 dữ liệu người dùng mkdir/foo
 thanh echo > dữ liệu người dùng/foo/giá trị
 dữ liệu người dùng mkdir/qux

Khóa ZZ0000ZZ bị bỏ qua vì nó không có giá trị::

echo "Đây là tin nhắn" > /dev/kmsg
 12,607,22085407756,-;Đây là tin nhắn
  foo=thanh

Xóa các mục ZZ0000ZZ bằng ZZ0001ZZ::

rmdir /sys/kernel/config/netconsole/cmdline0/userdata/qux

.. warning::
   When writing strings to user data values, input is broken up per line in
   configfs store calls and this can cause confusing behavior::

     mkdir userdata/testing
     printf "val1\nval2" > userdata/testing/value
     # userdata store value is called twice, first with "val1\n" then "val2"
     # so "val2" is stored, being the last value stored
     cat userdata/testing/value
     val2

   It is recommended to not write user data values with newlines.

Tự động điền tên tác vụ trong dữ liệu người dùng
-------------------------------------

Bên trong hệ thống phân cấp cấu hình netconsole, có một tệp có tên
ZZ0000ZZ trong thư mục ZZ0001ZZ. Tập tin này được sử dụng để kích hoạt
hoặc vô hiệu hóa tính năng điền tên nhiệm vụ tự động. Tính năng này
tự động điền tên tác vụ hiện tại được lên lịch trong CPU
đang rình mò tin nhắn.

Để bật tính năng tự động điền tên tác vụ::

echo 1 > /sys/kernel/config/netconsole/target1/userdata/taskname_enabled

Khi tùy chọn này được bật, các thông báo netconsole sẽ bao gồm một phần bổ sung
dòng trong trường dữ liệu người dùng với định dạng ZZ0000ZZ. Điều này cho phép
người nhận tin nhắn netconsole để dễ dàng tìm thấy ứng dụng nào
hiện được lên lịch khi tin nhắn đó được tạo, cung cấp thêm ngữ cảnh
cho các thông điệp kernel và giúp phân loại chúng.

Ví dụ::

echo "Đây là tin nhắn" > /dev/kmsg
  12,607,22085407756,-;Đây là tin nhắn
   tên nhiệm vụ=tiếng vang

Trong ví dụ này, thông báo được tạo trong khi "echo" là hiện tại
quá trình theo lịch trình.

Tự động phát hành hạt nhân trong dữ liệu người dùng
------------------------------------------

Trong hệ thống phân cấp cấu hình netconsole, có một tệp có tên ZZ0000ZZ
nằm trong thư mục ZZ0001ZZ. Tập tin này kiểm soát việc phát hành kernel
(phiên bản) tính năng tự động điền, bổ sung thông tin phát hành kernel
vào từ điển dữ liệu người dùng trong mỗi tin nhắn được gửi.

Để bật tính năng tự động điền bản phát hành::

echo 1 > /sys/kernel/config/netconsole/target1/userdata/release_enabled

Ví dụ::

echo "Đây là tin nhắn" > /dev/kmsg
  12,607,22085407756,-;Đây là tin nhắn
   phát hành=6.14.0-rc6-01219-g3c027fbd941d

.. note::

   This feature provides the same data as the "release prepend" feature.
   However, in this case, the release information is appended to the userdata
   dictionary rather than being included in the message header.


Tự động điền số CPU trong dữ liệu người dùng
--------------------------------------

Bên trong hệ thống phân cấp cấu hình netconsole, có một tệp có tên
ZZ0000ZZ trong thư mục ZZ0001ZZ. Tập tin này được sử dụng để kích hoạt hoặc vô hiệu hóa
tính năng điền số CPU tự động. Tính năng này tự động
điền số CPU đang gửi tin nhắn.

Để bật tính năng tự động điền số CPU::

echo 1 > /sys/kernel/config/netconsole/target1/userdata/cpu_nr

Khi tùy chọn này được bật, các thông báo netconsole sẽ bao gồm một phần bổ sung
dòng trong trường dữ liệu người dùng với định dạng ZZ0000ZZ. Điều này cho phép
người nhận tin nhắn netconsole để dễ dàng phân biệt và phân kênh
các thông báo có nguồn gốc từ các CPU khác nhau, điều này đặc biệt hữu ích khi
xử lý đầu ra nhật ký song song.

Ví dụ::

echo "Đây là tin nhắn" > /dev/kmsg
  12,607,22085407756,-;Đây là tin nhắn
   CPU=42

Trong ví dụ này, tin nhắn được gửi bởi CPU 42.

.. note::

   If the user has set a conflicting `cpu` key in the userdata dictionary,
   both keys will be reported, with the kernel-populated entry appearing after
   the user one. For example::

     # User-defined CPU entry
     mkdir -p /sys/kernel/config/netconsole/target1/userdata/cpu
     echo "1" > /sys/kernel/config/netconsole/target1/userdata/cpu/value

   Output might look like::

     12,607,22085407756,-;This is a message
      cpu=1
      cpu=42    # kernel-populated value


Tự động điền ID tin nhắn trong dữ liệu người dùng
--------------------------------------

Trong hệ thống phân cấp cấu hình netconsole, có một tệp có tên ZZ0000ZZ
nằm trong thư mục ZZ0001ZZ. Tệp này kiểm soát ID tin nhắn
tính năng tự động điền, gán id số cho mỗi tin nhắn được gửi đến một
mục tiêu nhất định và gắn ID vào từ điển dữ liệu người dùng trong mỗi tin nhắn được gửi.

ID tin nhắn được tạo bằng bộ đếm 32 bit cho mỗi mục tiêu
tăng lên cho mỗi tin nhắn được gửi đến mục tiêu. Lưu ý rằng bộ đếm này sẽ
cuối cùng sẽ kết thúc sau khi đạt giá trị tối đa uint32_t, vì vậy ID thông báo là
không phải là duy nhất trên toàn cầu theo thời gian. Tuy nhiên, mục tiêu vẫn có thể sử dụng nó để
phát hiện xem tin nhắn có bị rớt trước khi đến được mục tiêu hay không bằng cách xác định các khoảng trống
theo thứ tự ID.

Điều quan trọng là phải phân biệt ID tin nhắn với trường tin nhắn <sequnum>.
Một số thông báo kernel có thể không bao giờ đến được netconsole (ví dụ: do printk
giới hạn tỷ lệ). Do đó, khoảng trống trong <sequnum> không thể chỉ dựa vào
chỉ ra rằng một tin nhắn đã bị loại bỏ trong quá trình truyền, vì nó có thể không bao giờ có
đã được gửi qua netconsole. Mặt khác, ID tin nhắn chỉ được gán
tới các tin nhắn thực sự được truyền qua netconsole.

Ví dụ::

echo "Đây là tin nhắn #1" > /dev/kmsg
  echo "Đây là tin nhắn #2" > /dev/kmsg
  13,434,54928466,-;Đây là tin nhắn #1
   msgid=1
  13,435,54934019,-;Đây là tin nhắn #2
   msgid=2


Bảng điều khiển mở rộng:
=================

Nếu '+' được đặt trước dòng cấu hình hoặc tệp cấu hình "mở rộng"
được đặt thành 1, hỗ trợ bảng điều khiển mở rộng sẽ được bật. Một ví dụ khởi động
thông số sau::

linux netconsole=+4444@10.0.0.1/eth1,9353@10.0.0.2/12:34:56:78:9a:bc

Thông điệp tường trình được truyền đi với tiêu đề siêu dữ liệu mở rộng trong
định dạng sau giống như /dev/kmsg::

<cấp độ>,<sequnum>,<dấu thời gian>,<contflag>;<văn bản tin nhắn>

Nếu tính năng 'r' (bản phát hành) được bật, phiên bản phát hành kernel là
được thêm vào đầu tin nhắn. Ví dụ::

6.4.0,6,444,501151268,-;netconsole: bắt đầu ghi nhật ký mạng

Các ký tự không in được trong <văn bản tin nhắn> được thoát bằng cách sử dụng "\xff"
ký hiệu. Nếu tin nhắn chứa từ điển tùy chọn, nguyên văn
dòng mới được sử dụng làm dấu phân cách.

Nếu một tin nhắn không vừa với số byte nhất định (hiện tại là 1000),
tin nhắn được chia thành nhiều đoạn bởi netconsole. Những cái này
các đoạn được truyền đi với trường tiêu đề "ncfrag" được thêm vào::

ncfrag=<byte-offset>/<tổng byte>

Ví dụ: giả sử kích thước khối nhỏ hơn nhiều, thông báo "đầu tiên
đoạn, đoạn thứ 2." có thể được chia như sau::

6,416,1758426,-,ncfrag=0/31;đoạn đầu tiên,
 6,416,1758426,-,ncfrag=16/31; đoạn thứ 2.

Các ghi chú khác:
====================

.. Warning::

   the default target ethernet setting uses the broadcast
   ethernet address to send packets, which can cause increased load on
   other systems on the same ethernet segment.

.. Tip::

   some LAN switches may be configured to suppress ethernet broadcasts
   so it is advised to explicitly specify the remote agents' MAC addresses
   from the config parameters passed to netconsole.

.. Tip::

   to find out the MAC address of, say, 10.0.0.2, you may try using::

	ping -c 1 10.0.0.2 ; /sbin/arp -n | grep 10.0.0.2

.. Tip::

   in case the remote logging agent is on a separate LAN subnet than
   the sender, it is suggested to try specifying the MAC address of the
   default gateway (you may use /sbin/route -n to find it out) as the
   remote MAC address instead.

.. note::

   the network device (eth1 in the above case) can run any kind
   of other network traffic, netconsole is not intrusive. Netconsole
   might cause slight delays in other traffic if the volume of kernel
   messages is high, but should have no other impact.

.. note::

   if you find that the remote logging agent is not receiving or
   printing all messages from the sender, it is likely that you have set
   the "console_loglevel" parameter (on the sender) to only send high
   priority messages to the console. You can change this at runtime using::

	dmesg -n 8

   or by specifying "debug" on the kernel command line at boot, to send
   all kernel messages to the console. A specific value for this parameter
   can also be set using the "loglevel" kernel boot option. See the
   dmesg(8) man page and Documentation/admin-guide/kernel-parameters.rst
   for details.

Netconsole được thiết kế để hoạt động tức thời nhất có thể, nhằm
cho phép ghi nhật ký ngay cả những lỗi kernel nghiêm trọng nhất. Nó hoạt động
từ ngữ cảnh IRQ và không cho phép ngắt trong khi
gửi các gói tin. Do những nhu cầu đặc biệt này, cấu hình không thể
tự động hơn và một số hạn chế cơ bản sẽ vẫn còn:
chỉ hỗ trợ mạng IP, gói UDP và thiết bị ethernet.