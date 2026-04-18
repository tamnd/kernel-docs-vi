.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/virt/uml/user_mode_linux_howto_v2.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

#########
ZZ0000ZZ Cách thực hiện
#########

.. contents:: :local:

************
Giới thiệu
************

Chào mừng đến với Chế độ người dùng Linux

Chế độ người dùng Linux là nền tảng ảo hóa nguồn mở đầu tiên (đầu tiên
ngày phát hành 1991) và nền tảng ảo hóa thứ hai cho PC x86.

UML khác với máy ảo sử dụng gói ảo hóa X như thế nào?
==============================================================

Chúng tôi đã giả định rằng ảo hóa cũng có nghĩa là một số mức độ
mô phỏng phần cứng. Trong thực tế, nó không. Miễn là ảo hóa
gói cung cấp cho HĐH các thiết bị mà HĐH có thể nhận dạng và
có trình điều khiển, thiết bị không cần mô phỏng phần cứng thực.
Hầu hết các hệ điều hành hiện nay đều tích hợp sẵn tính năng hỗ trợ cho một số "giả"
các thiết bị chỉ được sử dụng trong ảo hóa.
Chế độ người dùng Linux đưa khái niệm này lên đến đỉnh cao - đó
không phải là một thiết bị thực sự duy nhất trong tầm mắt. Nó là 100% nhân tạo hoặc nếu
chúng tôi sử dụng thuật ngữ chính xác 100% ảo. Tất cả các thiết bị UML đều trừu tượng
các khái niệm ánh xạ tới thứ gì đó do máy chủ cung cấp - tệp, ổ cắm,
đường ống, v.v.

Sự khác biệt lớn khác giữa UML và các công nghệ ảo hóa khác nhau
gói là có sự khác biệt rõ ràng giữa cách UML
kernel và các chương trình UML hoạt động.
Kernel UML chỉ là một tiến trình chạy trên Linux - giống như mọi tiến trình khác
chương trình. Nó có thể được điều hành bởi người dùng không có đặc quyền và không yêu cầu
bất cứ điều gì về các tính năng đặc biệt của CPU.
Tuy nhiên, không gian người dùng UML hơi khác một chút. Nhân Linux trên
máy chủ hỗ trợ UML chặn mọi thứ chương trình đang chạy
trên phiên bản UML đang cố gắng thực hiện và khiến kernel UML xử lý tất cả
các yêu cầu của nó.
Điều này khác với các gói ảo hóa khác vốn không tạo ra bất kỳ
sự khác biệt giữa kernel khách và chương trình khách. Sự khác biệt này
giả sử dẫn đến một số ưu điểm và nhược điểm của UML
QEMU mà chúng tôi sẽ đề cập sau trong tài liệu này.


Tại sao tôi muốn có Chế độ người dùng Linux?
=================================


* Nếu kernel Linux ở Chế độ người dùng gặp sự cố, kernel máy chủ của bạn vẫn ổn. Nó
  không được tăng tốc theo bất kỳ cách nào (vhost, kvm, v.v.) và nó không cố gắng
  truy cập trực tiếp vào bất kỳ thiết bị nào.  Trên thực tế, đó là một quá trình giống như bất kỳ quá trình nào khác.

* Bạn có thể chạy kernel usermode với tư cách là người dùng không phải root (bạn có thể cần phải
  sắp xếp các quyền thích hợp cho một số thiết bị).

* Bạn có thể chạy một máy ảo rất nhỏ với dung lượng tối thiểu cho một mục đích cụ thể
  nhiệm vụ (ví dụ 32M hoặc ít hơn).

* Bạn có thể đạt được hiệu suất cực cao cho bất kỳ thứ gì là "hạt nhân"
  nhiệm vụ cụ thể" chẳng hạn như chuyển tiếp, tường lửa, v.v. trong khi vẫn đang
  bị cô lập khỏi hạt nhân máy chủ.

* Bạn có thể chơi với các khái niệm kernel mà không làm hỏng mọi thứ.

* Bạn không bị ràng buộc bởi phần cứng "mô phỏng", vì vậy bạn có thể thử những điều kỳ lạ và
  những khái niệm tuyệt vời rất khó hỗ trợ khi mô phỏng
  phần cứng thực sự như du hành thời gian và tạo đồng hồ hệ thống của bạn
  phụ thuộc vào những gì UML làm (rất hữu ích cho những việc như kiểm tra).

* Thật là vui.

Tại sao không chạy UML
==================

* Kỹ thuật chặn cuộc gọi tòa nhà được UML sử dụng khiến nó vốn đã
  chậm hơn đối với mọi ứng dụng không gian người dùng. Mặc dù nó có thể thực hiện các tác vụ kernel
  ngang bằng với hầu hết các gói ảo hóa khác, không gian người dùng của nó
  ZZ0000ZZ. Nguyên nhân cốt lõi là UML có chi phí tạo ra rất cao
  các tiến trình và luồng mới (điều mà hầu hết các ứng dụng Unix/Linux
  coi đó là điều hiển nhiên).

* UML hiện tại hoàn toàn là bộ xử lý đơn. Nếu bạn muốn chạy một
  ứng dụng cần nhiều CPU để hoạt động, rõ ràng đó là
  lựa chọn sai lầm.

***********************
Xây dựng phiên bản UML
***********************

Không có trình cài đặt UML trong bất kỳ bản phân phối nào. Trong khi bạn có thể sử dụng
phương tiện cài đặt giá để cài đặt vào một máy ảo trống bằng cách sử dụng ảo hóa
gói, không có gói UML tương đương. Bạn phải sử dụng các công cụ thích hợp trên
máy chủ của bạn để xây dựng một hình ảnh hệ thống tập tin khả thi.

Việc này cực kỳ dễ dàng trên Debian - bạn có thể thực hiện bằng debootstrap. Đó là
cũng dễ dàng trên OpenWRT - quá trình xây dựng có thể xây dựng hình ảnh UML. Tất cả khác
bản phân phối - YMMV.

Tạo một hình ảnh
=================

Tạo hình ảnh đĩa thô thưa thớt::

# dd if=/dev/zero of=disk_image_name bs=1 count=1 seek=16G

Điều này sẽ tạo ra một hình ảnh đĩa 16G. Hệ điều hành ban đầu sẽ chỉ phân bổ một
chặn và sẽ phân bổ nhiều hơn khi chúng được viết bởi UML. Về hạt nhân
phiên bản 4.19 UML hỗ trợ đầy đủ TRIM (thường được sử dụng bởi ổ đĩa flash).
Sử dụng TRIM bên trong hình ảnh UML bằng cách chỉ định loại bỏ làm tùy chọn gắn kết
hoặc bằng cách chạy ZZ0000ZZ sẽ yêu cầu UML
trả lại bất kỳ khối không sử dụng nào cho hệ điều hành.

Tạo một hệ thống tập tin trên ảnh đĩa và gắn kết nó ::

# mkfs.ext4 ./disk_image_name && mount ./disk_image_name /mnt

Ví dụ này sử dụng ext4, bất kỳ hệ thống tập tin nào khác như ext3, btrfs, xfs,
jfs, v.v. cũng sẽ hoạt động.

Tạo cài đặt hệ điều hành tối thiểu trên hệ thống tệp được gắn kết::

# debootstrap phá hủy /mnt ZZ0000ZZ

debootstrap không thiết lập mật khẩu gốc, fstab, tên máy chủ hoặc
bất cứ điều gì liên quan đến mạng. Tùy thuộc vào người dùng để làm điều đó.

Đặt mật khẩu root - cách dễ nhất để làm điều đó là chroot vào
hình ảnh được gắn kết::

# chroot /mnt
   # passwd
   # exit

Chỉnh sửa tập tin hệ thống quan trọng
=====================

Các thiết bị khối UML được gọi là ubds. Fstab được tạo bởi debootstrap
sẽ trống và nó cần một mục nhập cho hệ thống tập tin gốc::

/dev/ubd0 ext4 loại bỏ,errors=remount-ro 0 1

Tên máy chủ hình ảnh sẽ được đặt giống với tên máy chủ mà bạn sử dụng
đang tạo ra hình ảnh của nó. Đó là một ý tưởng tốt để thay đổi điều đó để tránh
"Ồ, tiếc quá, tôi đã khởi động lại nhầm máy".

UML hỗ trợ các thiết bị mạng hiệu suất cao I/O vector có
hỗ trợ cho một số đóng gói mạng ảo tiêu chuẩn như
Ethernet qua GRE và Ethernet qua L2TPv3. Chúng được gọi là vecX.

Khi sử dụng các thiết bị mạng vector, ZZ0000ZZ
sẽ cần các mục như::

Thiết bị mạng # vector UML
   tự động vec0
   iface vec0 inet dhcp

Bây giờ chúng ta có hình ảnh UML gần như đã sẵn sàng để chạy, tất cả những gì chúng ta cần là một
Hạt nhân UML và các mô-đun cho nó.

Hầu hết các bản phân phối đều có gói UML. Ngay cả khi bạn có ý định sử dụng của riêng bạn
kernel, việc kiểm tra image bằng stock luôn là một khởi đầu tốt. Những cái này
các gói đi kèm với một bộ mô-đun cần được sao chép vào mục tiêu
hệ thống tập tin. Vị trí phụ thuộc vào phân phối. Đối với Debian những cái này
nằm trong /usr/lib/uml/modules. Sao chép đệ quy nội dung này
thư mục vào hệ thống tập tin UML được gắn kết::

# cp -rax/usr/lib/uml/mô-đun/mnt/lib/mô-đun

Nếu bạn đã biên dịch kernel của riêng mình, bạn cần sử dụng lệnh "install" thông thường
mô-đun đến một vị trí" bằng cách chạy::

# make INSTALL_MOD_PATH=/mnt/lib/mô-đun mô-đun_install

Điều này sẽ cài đặt các mô-đun vào /mnt/lib/modules/$(KERNELRELEASE).
Để chỉ định đường dẫn cài đặt mô-đun đầy đủ, hãy sử dụng::

# make MODLIB=/mnt/lib/mô-đun mô-đun_install

Tại thời điểm này, hình ảnh đã sẵn sàng để được đưa lên.

*************************
Thiết lập mạng UML
*************************

Mạng UML được thiết kế để mô phỏng kết nối Ethernet. Cái này
kết nối có thể là điểm-điểm (tương tự như kết nối
giữa các máy sử dụng cáp nối tiếp nhau) hoặc kết nối với một
chuyển đổi. UML hỗ trợ nhiều phương tiện khác nhau để xây dựng những thứ này
kết nối với tất cả: máy cục bộ, máy từ xa, máy cục bộ và
UML từ xa và các phiên bản VM khác.


+----------+--------+--------------------------------------+-------------+
ZZ0000ZZ Loại ZZ0001ZZ Thông lượng |
+============+=========+===============================================================================================================
ZZ0002ZZ vectơ ZZ0003ZZ > 8Gbit |
+----------+--------+--------------------------------------+-------------+
ZZ0004ZZ vector ZZ0005ZZ > 6GBit |
+----------+--------+--------------------------------------+-------------+
ZZ0006ZZ vector ZZ0007ZZ > 6GBit |
+----------+--------+--------------------------------------+-------------+
ZZ0008ZZ vectơ ZZ0009ZZ > 3Gbit |
+----------+--------+--------------------------------------+-------------+
ZZ0010ZZ vectơ ZZ0011ZZ > 3Gbit |
+----------+--------+--------------------------------------+-------------+
ZZ0012ZZ vectơ ZZ0013ZZ > 3Gbit |
+----------+--------+--------------------------------------+-------------+
ZZ0014ZZ vectơ ZZ0015ZZ khác nhau |
+----------+--------+--------------------------------------+-------------+
ZZ0016ZZ vectơ ZZ0017ZZ khác nhau |
+----------+--------+--------------------------------------+-------------+

* Tất cả các phương tiện vận chuyển có giảm tải tso và tổng kiểm tra đều có thể mang lại tốc độ
  tiếp cận 10G trên các luồng TCP.

* Tất cả các phương tiện truyền tải có rx và/hoặc tx nhiều gói đều có thể phân phối pps
  tốc độ lên tới 1Mps hoặc hơn.

* GRE và L2TPv3 cho phép kết nối với tất cả: máy cục bộ, máy từ xa
  máy, thiết bị mạng từ xa và phiên bản UML từ xa.


Đặc quyền cấu hình mạng
================================

Phần lớn các chế độ mạng được hỗ trợ cần có đặc quyền ZZ0000ZZ.
Ví dụ: đối với việc truyền tải vectơ, cần có đặc quyền ZZ0001ZZ để kích hoạt
một ioctl để thiết lập giao diện điều chỉnh và/hoặc sử dụng ổ cắm thô khi cần.

Điều này có thể đạt được bằng cách cấp cho người dùng một khả năng cụ thể thay vì
chạy UML với quyền root.  Trong trường hợp vận chuyển vector, người dùng có thể thêm
khả năng ZZ0000ZZ hoặc ZZ0001ZZ sang nhị phân uml.
Từ nay trở đi, UML có thể được chạy với quyền riêng tư của người dùng thông thường, cùng với
mạng đầy đủ.

Ví dụ::

# sudo setcap cap_net_raw,cap_net_admin+ep linux

Cấu hình vận chuyển vector
===============================

Tất cả các phương thức truyền tải vector đều hỗ trợ một cú pháp tương tự:

Nếu X là số giao diện như trong vec0, vec1, vec2, v.v. thì tổng quát
cú pháp cho các tùy chọn là::

vecX:transport="Tên vận chuyển",option=value,option=value,...,option=value

Tùy chọn chung
--------------

Các tùy chọn này là phổ biến cho tất cả các phương tiện vận chuyển:

* ZZ0000ZZ - đặt độ sâu hàng đợi cho vectơ IO. Đây là
  số lượng gói UML sẽ cố gắng đọc hoặc ghi trong một lần
  cuộc gọi hệ thống. Số mặc định là 64 và nói chung là đủ
  cho hầu hết các ứng dụng cần thông lượng trong phạm vi 2-4 Gbit.
  Tốc độ cao hơn có thể yêu cầu giá trị lớn hơn.

* ZZ0000ZZ - đặt giá trị địa chỉ giao diện MAC.

* ZZ0000ZZ - tắt hoặc bật GRO. Cho phép nhận/truyền tải giảm tải.
  Hiệu quả của tùy chọn này phụ thuộc vào sự hỗ trợ của phía máy chủ trong quá trình vận chuyển
  đang được cấu hình. Trong hầu hết các trường hợp, nó sẽ kích hoạt phân đoạn TCP và
  Giảm tải tổng kiểm tra RX/TX. Cài đặt phải giống hệt nhau ở phía máy chủ
  và phía UML. Hạt nhân UML sẽ đưa ra cảnh báo nếu không.
  Ví dụ: GRO được bật theo mặc định trên giao diện máy cục bộ
  (ví dụ: cặp veth, cầu nối, v.v.), do đó, nó phải được bật trong UML trong
  truyền tải UML tương ứng (thô, tap, hybrid) để kết nối mạng với
  hoạt động chính xác.

* ZZ0000ZZ - đặt giao diện MTU

* ZZ0000ZZ - điều chỉnh khoảng không mặc định (32 byte) dành riêng
  nếu một gói cần được đóng gói lại vào ví dụ VXLAN.

* ZZ0000ZZ - vô hiệu hóa IO nhiều gói và quay trở lại gói tại một thời điểm
  chế độ thời gian

Tùy chọn chia sẻ
--------------

* ZZ0000ZZ Transports liên kết với giao diện mạng cục bộ
  có một tùy chọn chia sẻ - tên của giao diện để liên kết.

* ZZ0000ZZ - tất cả các phương tiện vận chuyển sử dụng ổ cắm
  có khái niệm về nguồn và đích và/hoặc cổng nguồn
  và cổng đích sử dụng chúng để chỉ định chúng.

* ZZ0000ZZ để chỉ định xem có muốn kết nối v6 cho tất cả không
  truyền tải hoạt động trên IP. Ngoài ra, đối với các phương tiện vận tải
  có một số khác biệt trong cách chúng hoạt động trên v4 và v6 (ví dụ
  EoL2TPv3), đặt chế độ hoạt động chính xác. Trong trường hợp không có điều này
  tùy chọn, loại ổ cắm được xác định dựa trên những gì src và dst thực hiện
  đối số giải quyết/phân tích thành.

vòi vận chuyển
-------------

Ví dụ::

vecX:transport=tap,ifname=tap0,độ sâu=128,gro=1

Điều này sẽ kết nối vec0 với tap0 trên máy chủ. Tap0 phải đã tồn tại (ví dụ
được tạo bằng tunctl) và UP.

tap0 có thể được cấu hình như một giao diện điểm-điểm và được cấp IP
địa chỉ để UML có thể nói chuyện với máy chủ. Ngoài ra, có thể
để kết nối UML với giao diện nhấn được kết nối với một cây cầu.

Mặc dù tap dựa vào cơ sở hạ tầng vectơ nhưng nó không phải là vectơ thực sự
vận chuyển vào thời điểm này, vì Linux không hỗ trợ nhiều gói
IO trên bộ mô tả tệp nhấn cho các ứng dụng không gian người dùng thông thường như UML. Cái này
là một đặc quyền chỉ được trao cho thứ gì đó có thể kết nối
đến nó ở cấp độ kernel thông qua các giao diện chuyên dụng như vhost-net. A
Trình trợ giúp giống như vhost-net cho UML được lên kế hoạch vào một thời điểm nào đó trong tương lai.

Các đặc quyền cần có: vận chuyển bằng vòi yêu cầu:

* chạm vào giao diện để tồn tại và được tạo liên tục và thuộc sở hữu của
  Người dùng UML sử dụng tunctl. Ví dụ ZZ0000ZZ

* nhị phân để có đặc quyền ZZ0000ZZ

vận tải lai
----------------

Ví dụ::

vecX:transport=hybrid,ifname=tap0,deep=128,gro=1

Đây là một phương tiện vận chuyển thử nghiệm/demo mà các cặp đôi chạm vào để truyền tải
và một ổ cắm thô để nhận. Ổ cắm thô cho phép nhiều gói
nhận được dẫn đến tốc độ gói cao hơn đáng kể so với lần chạm thông thường.

Yêu cầu đặc quyền: hybrid yêu cầu khả năng ZZ0000ZZ bằng
người dùng UML cũng như các yêu cầu đối với việc vận chuyển vòi.

vận chuyển ổ cắm thô
--------------------

Ví dụ::

vecX:transport=raw,ifname=p-veth0,độ sâu=128,gro=1


Việc vận chuyển này sử dụng vector IO trên các socket thô. Mặc dù bạn có thể liên kết với bất kỳ
giao diện bao gồm giao diện vật lý, cách sử dụng phổ biến nhất là liên kết với
phía "ngang hàng" của cặp veth với phía bên kia được định cấu hình trên
chủ nhà.

Cấu hình máy chủ ví dụ cho Debian:

ZZ0000ZZ::

xe veth0
   iface veth0 inet tĩnh
	địa chỉ 192.168.4.1
	mặt nạ mạng 255.255.255.252
	phát sóng 192.168.4.3
	liên kết ip trước khi thêm veth0 gõ veth tên ngang hàng p-veth0 && \
          ifconfig p-veth0 lên

UML hiện có thể liên kết với p-veth0 như thế này ::

vec0:transport=raw,ifname=p-veth0,độ sâu=128,gro=1


Nếu máy khách UML được định cấu hình với 192.168.4.2 và netmask 255.255.255.0
nó có thể nói chuyện với máy chủ trên 192.168.4.1

Việc vận chuyển thô cũng cung cấp một số hỗ trợ cho việc dỡ hàng một số hàng hóa.
lọc đến máy chủ. Hai tùy chọn để kiểm soát nó là:

* Tên tệp ZZ0000ZZ của mã bpf thô sẽ được tải dưới dạng bộ lọc ổ cắm

* ZZ0000ZZ 0/1 cho phép tải bpf từ bên trong Chế độ người dùng Linux.
  Tùy chọn này cho phép sử dụng lệnh ethtool loading firmware để
  tải mã bpf.

Trong cả hai trường hợp, mã bpf đều được tải vào nhân máy chủ. Trong khi đây là
hiện bị giới hạn ở cú pháp bpf kế thừa (không phải ebpf), nó vẫn là một bảo mật
rủi ro. Không nên cho phép điều này trừ khi Chế độ người dùng Linux
dụ được coi là đáng tin cậy.

Yêu cầu đặc quyền: vận chuyển ổ cắm thô yêu cầu ZZ0000ZZ
khả năng.

Vận chuyển ổ cắm GRE
--------------------

Ví dụ::

vecX:transport=gre,src=$src_host,dst=$dst_host


Điều này sẽ định cấu hình Ethernet qua ZZ0000ZZ (còn gọi là ZZ0001ZZ hoặc
ZZ0002ZZ) sẽ kết nối phiên bản UML với ZZ0003ZZ
điểm cuối tại máy chủ dst_host. ZZ0004ZZ hỗ trợ bổ sung sau
tùy chọn:

* ZZ0000ZZ - GRE Khóa số nguyên 32 bit cho gói rx, nếu được đặt,
  ZZ0001ZZ cũng phải được đặt

* ZZ0000ZZ - GRE Khóa số nguyên 32 bit cho các gói tx, nếu được đặt
  ZZ0001ZZ cũng phải được đặt

* ZZ0000ZZ - kích hoạt chuỗi GRE

* ZZ0000ZZ - giả vờ rằng trình tự luôn được đặt lại
  trên mỗi gói (cần thiết để tương tác với một số gói thực sự bị hỏng
  triển khai)

* ZZ0000ZZ - buộc các ổ cắm IPv4 hoặc IPv6 tương ứng

* Tổng kiểm tra GRE hiện không được hỗ trợ

GRE có một số lưu ý:

* Bạn chỉ có thể sử dụng một kết nối GRE cho mỗi địa chỉ IP. Không có cách nào để
  kết nối ghép kênh khi mỗi đường hầm GRE được kết thúc trực tiếp trên
  phiên bản UML.

* Chìa khóa không thực sự là một tính năng bảo mật. Trong khi nó được dự định như vậy
  "bảo mật" của nó là buồn cười. Tuy nhiên, đây là một tính năng hữu ích để
  đảm bảo rằng đường hầm không bị cấu hình sai.

Một cấu hình ví dụ cho máy chủ Linux có địa chỉ cục bộ là
192.168.128.1 để kết nối với phiên bản UML tại 192.168.129.1

ZZ0000ZZ::

tự động gt0
   iface gt0 inet tĩnh
    địa chỉ 10.0.0.1
    mặt nạ mạng 255.255.255.0
    phát sóng 10.0.0.255
    mtu 1500
    liên kết ip trước khi thêm gt0 gõ gretap local 192.168.128.1 \
           từ xa 192.168.129.1 || đúng
    link ip xuống del gt0 || ĐÚNG VẬY

Ngoài ra, GRE đã được thử nghiệm với nhiều thiết bị mạng khác nhau.

Yêu cầu đặc quyền: GRE yêu cầu ZZ0000ZZ

vận chuyển ổ cắm l2tpv3
-----------------------

_Cảnh báo_. L2TPv3 có một "lỗi". Đó là "lỗi" được gọi là "có nhiều hơn
tùy chọn hơn GNU ls". Mặc dù nó có một số lợi thế nhưng thường có
các cách dễ dàng hơn (và ít dài dòng hơn) để kết nối phiên bản UML với thứ gì đó.
Ví dụ: hầu hết các thiết bị hỗ trợ L2TPv3 cũng hỗ trợ GRE.

Ví dụ::

vec0:transport=l2tpv3,udp=1,src=$src_host,dst=$dst_host,srcport=$src_port,dstport=$dst_port,deep=128,rx_session=0xffffffff,tx_session=0xffff

Điều này sẽ cấu hình một đường hầm cố định Ethernet qua L2TPv3.
kết nối phiên bản UML với điểm cuối L2TPv3 tại máy chủ $dst_host bằng cách sử dụng
phiên bản L2TPv3 UDP và cổng đích UDP $dst_port.

L2TPv3 luôn yêu cầu các tùy chọn bổ sung sau:

* ZZ0000ZZ - l2tpv3 Phiên số nguyên 32 bit cho gói rx

* ZZ0000ZZ - l2tpv3 Phiên số nguyên 32 bit cho các gói tx

Khi đường hầm được cố định, những điều này không được thương lượng và chúng
được cấu hình sẵn ở cả hai đầu.

Ngoài ra, L2TPv3 hỗ trợ các tham số tùy chọn sau.

* ZZ0000ZZ - l2tpv3 Cookie số nguyên 32 bit cho gói rx - tương tự
  chức năng như khóa GRE, nhằm ngăn ngừa cấu hình sai hơn là cung cấp
  an ninh thực tế

* ZZ0000ZZ - l2tpv3 Cookie số nguyên 32 bit cho các gói tx

* ZZ0000ZZ - sử dụng cookie 64-bit thay vì 32-bit.

* ZZ0000ZZ - kích hoạt bộ đếm l2tpv3

* ZZ0000ZZ - giả vờ rằng bộ đếm luôn được đặt lại
  mỗi gói (cần thiết để tương tác với một số gói thực sự bị hỏng
  triển khai)

* ZZ0000ZZ - ổ cắm v6 bắt buộc

* ZZ0000ZZ - sử dụng phiên bản ổ cắm thô (0) hoặc UDP (1) của giao thức

L2TPv3 có một số lưu ý:

* bạn chỉ có thể sử dụng một kết nối cho mỗi địa chỉ IP ở chế độ thô. có
  không có cách nào để ghép kênh kết nối khi mỗi đường hầm L2TPv3 bị chấm dứt
  trực tiếp trên phiên bản UML. Chế độ UDP có thể sử dụng các cổng khác nhau cho
  mục đích này.

Dưới đây là ví dụ về cách định cấu hình máy chủ Linux để kết nối với UML
thông qua L2TPv3:

ZZ0000ZZ::

tự động l2tp1
   iface l2tp1 inet tĩnh
    địa chỉ 192.168.126.1
    mặt nạ mạng 255.255.255.0
    phát sóng 192.168.126.255
    mtu 1500
    cài đặt sẵn ip l2tp thêm đường hầm từ xa 127.0.0.1 \
           127.0.0.1 cục bộ đóng gói udp Tunnel_id 2 \
           ngang hàng_tunnel_id 2 udp_sport 1706 udp_dport 1707 && \
           ip l2tp thêm tên phiên l2tp1 Tunnel_id 2 \
           session_id 0xffffffff ngang hàng_session_id 0xffffffff
    xuống ip l2tp del phiên Tunnel_id 2 session_id 0xffffffff && \
           ip l2tp del đường hầm Tunnel_id 2


Yêu cầu đặc quyền: L2TPv3 yêu cầu ZZ0000ZZ cho chế độ IP thô và
không có đặc quyền đặc biệt nào cho chế độ UDP.

Vận chuyển ổ cắm BESS
---------------------

BESS là bộ chuyển mạch mạng mô-đun hiệu suất cao.

ZZ0000ZZ

Nó hỗ trợ chế độ ổ cắm gói tuần tự đơn giản trong
các phiên bản gần đây hơn đang sử dụng vector IO để có hiệu suất cao.

Ví dụ::

vecX:transport=bess,src=$unix_src,dst=$unix_dst

Điều này sẽ định cấu hình truyền tải BESS bằng cách sử dụng miền Unix unix_src
địa chỉ ổ cắm làm nguồn và địa chỉ ổ cắm unix_dst làm đích.

Để biết cấu hình BESS và cách phân bổ cổng ổ cắm tên miền Unix BESS
vui lòng xem tài liệu BESS.

ZZ0000ZZ

Việc vận chuyển BESS không yêu cầu bất kỳ đặc quyền nào.

Vận chuyển vector VDE
--------------------

Ethernet phân phối ảo (VDE) là một dự án có mục tiêu chính là cung cấp
hỗ trợ rất linh hoạt cho mạng ảo.

ZZ0000ZZ

Các cách sử dụng phổ biến của VDE bao gồm tạo mẫu nhanh và giảng dạy.

Ví dụ:

ZZ0000ZZ

sử dụng tap0

ZZ0000ZZ

sử dụng mảnh

ZZ0000ZZ

kết nối với một công tắc vde

ZZ0000ZZ

kết nối với một slirp từ xa (VPN tức thời: chuyển đổi ssh thành VPN, nó sử dụng sshlirp)
ZZ0000ZZ

ZZ0000ZZ

kết nối với đám mây cục bộ (tất cả các nút UML sử dụng cùng một
địa chỉ multicast chạy trên các máy chủ trong cùng một miền multicast (LAN)
sẽ được tự động kết nối với nhau với LAN ảo.

*************
Chạy UML
***********

Phần này giả định rằng gói user-mode-linux từ
phân phối hoặc kernel được xây dựng tùy chỉnh đã được cài đặt trên máy chủ.

Chúng thêm một tệp thực thi có tên linux vào hệ thống. Đây là UML
hạt nhân. Nó có thể được chạy giống như bất kỳ tệp thực thi nào khác.
Nó sẽ lấy hầu hết các đối số kernel linux bình thường làm dòng lệnh
lý lẽ.  Ngoài ra, nó sẽ cần một số đối số dành riêng cho UML
để làm điều gì đó hữu ích.

Đối số
=========

Đối số bắt buộc:
--------------------

* ZZ0000ZZ - dung lượng bộ nhớ. Theo mặc định tính bằng byte. Nó sẽ
  cũng chấp nhận vòng loại K, M hoặc G.

* Đặc điểm đĩa ảo ZZ0000ZZ. Đây không thực sự là
  bắt buộc, nhưng nó có thể cần thiết trong hầu hết các trường hợp để chúng ta có thể
  chỉ định một hệ thống tập tin gốc.
  Đặc tả hình ảnh đơn giản nhất có thể là tên của hình ảnh
  tệp cho hệ thống tệp (được tạo bằng một trong các phương pháp được mô tả
  trong ZZ0001ZZ).

* Thiết bị UBD hỗ trợ sao chép khi ghi (COW). Những thay đổi được lưu giữ trong
    một tệp riêng biệt có thể bị loại bỏ cho phép quay trở lại
    hình ảnh nguyên sơ nguyên bản.  Nếu muốn có COW, hình ảnh UBD sẽ được
    được chỉ định là: ZZ0000ZZ.
    Ví dụ:ZZ0001ZZ

* Các thiết bị UBD có thể được đặt để sử dụng IO đồng bộ. Mọi bài viết đều được
    ngay lập tức được xả vào đĩa. Điều này được thực hiện bằng cách thêm ZZ0000ZZ sau
    đặc điểm kỹ thuật ZZ0001ZZ.

* UBD thực hiện một số chẩn đoán trên các thiết bị được chỉ định dưới dạng một
    tên tệp để đảm bảo rằng tệp COW chưa được chỉ định là
    hình ảnh. Để tắt chúng, hãy sử dụng cờ ZZ0000ZZ sau ZZ0001ZZ.

* UBD hỗ trợ TRIM - yêu cầu Hệ điều hành máy chủ lấy lại mọi thứ chưa sử dụng
    các khối trong ảnh. Để tắt nó, hãy chỉ định cờ ZZ0000ZZ sau
    ZZ0001ZZ.

* Thiết bị root ZZ0000ZZ - rất có thể là ZZ0001ZZ (đây là Linux
  hình ảnh hệ thống tập tin)

Đối số tùy chọn quan trọng
----------------------------

Nếu UML được chạy dưới dạng "linux" không có đối số bổ sung, nó sẽ cố gắng khởi động một
xterm cho mọi bảng điều khiển được định cấu hình bên trong hình ảnh (tối đa 6 trong hầu hết
bản phân phối Linux). Mỗi bảng điều khiển được khởi động bên trong một
xterm. Điều này làm cho việc sử dụng UML trên máy chủ có GUI trở nên thú vị và dễ dàng. Đó là,
tuy nhiên, cách tiếp cận sai nếu UML được sử dụng làm dây nịt thử nghiệm hoặc chạy
trong môi trường chỉ có văn bản.

Để thay đổi hành vi này, chúng tôi cần chỉ định một bảng điều khiển thay thế
và nối nó với một trong các kênh "đường truyền" được hỗ trợ. Để làm điều này, chúng ta cần lập bản đồ
console để sử dụng cái gì đó khác với xterm mặc định.

Ví dụ sẽ chuyển hướng bảng điều khiển số 1 sang stdin/stdout::

con1=fd:0,fd:1

UML hỗ trợ nhiều kênh dòng nối tiếp được chỉ định bằng cách sử dụng
cú pháp sau

conX=channel_type:options[,channel_type:options]


Nếu đặc tả kênh chứa hai phần được phân tách bằng dấu phẩy thì phần đầu tiên
một là đầu vào, một là đầu ra.

* Kênh null - Loại bỏ tất cả đầu vào hoặc đầu ra. Ví dụ ZZ0000ZZ sẽ đặt
  tất cả các bảng điều khiển thành null theo mặc định.

* Kênh fd - sử dụng số mô tả tệp cho đầu vào/đầu ra. Ví dụ:
  ZZ0000ZZ

* Kênh cổng - khởi động máy chủ telnet trên số cổng TCP. Ví dụ:
  ZZ0000ZZ.  Máy chủ phải có /usr/sbin/in.telnetd (thường là một phần của
  gói telnetd) và trình trợ giúp cổng từ các tiện ích UML (xem phần
  thông tin cho kênh xterm bên dưới).  UML sẽ không khởi động cho đến khi có máy khách
  kết nối.

* Các kênh pty và pts - sử dụng pty/pts hệ thống.

* Kênh tty - liên kết với tty hệ thống hiện có. Ví dụ: ZZ0000ZZ
  sẽ khiến UML sử dụng bảng điều khiển thứ 8 của máy chủ (thường không được sử dụng).

* Kênh xterm - đây là mặc định - hiển thị xterm trên kênh này
  và hướng IO tới nó. Lưu ý rằng để xterm hoạt động, máy chủ phải
  đã cài đặt gói phân phối UML. Điều này thường chứa
  port-helper và các tiện ích khác cần thiết để UML giao tiếp với xterm.
  Ngoài ra, những điều này cần phải được tuân thủ và cài đặt từ nguồn. Tất cả
  các tùy chọn áp dụng cho bảng điều khiển cũng áp dụng cho các dòng nối tiếp UML
  được trình bày dưới dạng ttyS bên trong UML.

Khởi động UML
============

Bây giờ chúng ta có thể chạy UML.
::

# linux mem=2048M umid=TEST \
    ubd0=Hệ thống tập tin.img \
    vec0:transport=tap,ifname=tap0,deep=128,gro=1 \
    root=/dev/ubda con=null con0=null,fd:2 con1=fd:0,fd:1

Điều này sẽ chạy một phiên bản với ZZ0000ZZ và thử sử dụng tệp hình ảnh
được gọi là ZZ0001ZZ với quyền root. Nó sẽ kết nối với máy chủ bằng tap0.
Tất cả các bảng điều khiển ngoại trừ ZZ0002ZZ sẽ bị tắt và bảng điều khiển 1 sẽ
sử dụng đầu vào/đầu ra tiêu chuẩn để làm cho nó xuất hiện trong cùng một thiết bị đầu cuối mà nó đã được khởi động.

Đăng nhập
============

Nếu bạn chưa thiết lập mật khẩu khi tạo hình ảnh, bạn sẽ phải
tắt phiên bản UML, gắn hình ảnh, chroot vào nó và đặt nó - như
được mô tả trong phần Tạo hình ảnh.  Nếu mật khẩu đã được đặt,
bạn chỉ có thể đăng nhập.

Bảng điều khiển quản lý UML
============================

Ngoài việc quản lý image từ “bên trong” bằng các công cụ sysadmin thông thường,
có thể thực hiện một số thao tác cấp thấp bằng UML
bảng điều khiển quản lý. Bảng điều khiển quản lý UML là giao diện cấp thấp cho
kernel trên phiên bản UML đang chạy, hơi giống giao diện i386 SysRq. Kể từ khi
có một hệ điều hành đầy đủ dưới UML, có nhiều tính năng tuyệt vời hơn
có thể linh hoạt hơn so với cơ chế SysRq.

Có một số điều bạn có thể làm với giao diện mconsole:

* lấy phiên bản hạt nhân
* thêm và xóa thiết bị
* tạm dừng hoặc khởi động lại máy
* Gửi lệnh SysRq
* Tạm dừng và tiếp tục UML
* Kiểm tra các tiến trình đang chạy bên trong UML
* Kiểm tra trạng thái nội bộ / proc của UML

Bạn cần ứng dụng khách mconsole (uml\_mconsole) là một phần của UML
gói công cụ có sẵn ở hầu hết các bản phân phối Linux.

Bạn cũng cần kích hoạt ZZ0000ZZ (trong 'Cài đặt chung') trong UML
hạt nhân.  Khi khởi động UML, bạn sẽ thấy một dòng như::

mconsole được khởi tạo trên /home/jdike/.uml/umlNJ32yL/mconsole

Nếu bạn chỉ định một id máy duy nhất trên dòng lệnh UML, tức là.
ZZ0000ZZ, bạn sẽ thấy điều này::

mconsole được khởi tạo trên /home/jdike/.uml/debian/mconsole


Tệp đó là ổ cắm mà uml_mconsole sẽ sử dụng để liên lạc với
UML.  Chạy nó với đường dẫn umid hoặc đầy đủ làm đối số của nó ::

debian # uml_mconsole

hoặc

# uml_mconsole /home/jdike/.uml/debian/mconsole


Bạn sẽ nhận được lời nhắc, tại đó bạn có thể chạy một trong các lệnh sau:

* phiên bản
* giúp đỡ
* dừng lại
* khởi động lại
* cấu hình
* xóa
* sysrq
* giúp đỡ
* cad
* dừng lại
* đi
* quá trình
* ngăn xếp

phiên bản
-------

Lệnh này không có đối số.  Nó in phiên bản UML::

phiên bản (mconsole)
   OK Linux OpenWrt 4.14.106 #0 Thứ ba ngày 19 tháng 3 08:19:41 2019 x86_64


Có một vài cách sử dụng thực tế cho việc này.  Đó là một lệnh không hoạt động đơn giản
có thể được sử dụng để kiểm tra xem UML có đang chạy hay không.  Đó cũng là một cách
gửi một ngắt thiết bị đến UML. UML mconsole được xử lý nội bộ như
một thiết bị UML.

giúp đỡ
----

Lệnh này không có đối số. Nó in một màn hình trợ giúp ngắn với
các lệnh mconsole được hỗ trợ.


tạm dừng và khởi động lại
---------------

Các lệnh này không có đối số.  Họ tắt máy ngay lập tức, với
không đồng bộ hóa đĩa và không tắt sạch không gian người dùng.  Vì vậy, họ là
suýt nữa thì hỏng máy ::

(mconsole) dừng lại
   được rồi

cấu hình
------

"config" thêm thiết bị mới vào máy ảo. Điều này được hỗ trợ
bởi hầu hết các trình điều khiển thiết bị UML. Phải mất một đối số, đó là
thiết bị cần thêm, với cú pháp tương tự như dòng lệnh kernel ::

(mconsole) cấu hình ubd3=/home/jdike/incoming/roots/root_fs_debian22

di dời
------

"remove" sẽ xóa một thiết bị khỏi hệ thống.  Lập luận của nó chỉ là
tên của thiết bị cần loại bỏ. Thiết bị phải ở chế độ rảnh trong mọi trường hợp
giác mà người lái xe cho là cần thiết.  Trong trường hợp trình điều khiển ubd,
thiết bị khối đã loại bỏ không được gắn, hoán đổi hoặc nói cách khác
mở và trong trường hợp driver mạng thì thiết bị phải ngừng hoạt động::

(mconsole) xóa ubd3

sysrq
-----

Lệnh này nhận một đối số là một chữ cái.  Nó gọi
trình điều khiển SysRq của kernel chung, thực hiện bất cứ điều gì được yêu cầu bởi
lập luận đó.  Xem tài liệu SysRq trong
Documentation/admin-guide/sysrq.rst trong cây hạt nhân yêu thích của bạn để
xem những chữ cái nào là hợp lệ và chúng làm gì.

cad
---

Điều này gọi hành động ZZ0000ZZ trong hình ảnh đang chạy.  Chính xác thì cái gì
việc này kết thúc tùy thuộc vào init, systemd, v.v. Thông thường, nó khởi động lại
máy.

dừng lại
----

Điều này đặt UML vào một vòng lặp đọc các yêu cầu mconsole cho đến khi 'đi'
lệnh mconsole được nhận. Điều này rất hữu ích như một
công cụ gỡ lỗi/chụp nhanh.

đi
--

Thao tác này sẽ tiếp tục UML sau khi bị tạm dừng bởi lệnh 'stop'. Lưu ý rằng
khi UML hoạt động trở lại, các kết nối TCP có thể đã hết thời gian chờ và nếu
UML bị tạm dừng trong một thời gian dài, crond có thể hoạt động hơi chậm
điên rồ, chạy tất cả các công việc nó không làm trước đó.

quá trình
----

Điều này nhận một đối số - tên của tệp trong /proc được in
đến đầu ra tiêu chuẩn mconsole

chồng
-----

Điều này có một đối số - số pid của một quá trình. Ngăn xếp của nó là
được in thành đầu ra tiêu chuẩn.

*******************
Chủ đề UML nâng cao
*******************

Chia sẻ hệ thống tập tin giữa các máy ảo
============================================

Đừng cố gắng chia sẻ hệ thống tập tin chỉ bằng cách khởi động hai UML từ
cùng một tập tin.  Việc đó cũng giống như việc khởi động hai máy vật lý
từ một đĩa được chia sẻ.  Nó sẽ dẫn đến tham nhũng hệ thống tập tin.

Sử dụng các thiết bị khối lớp
---------------------------

Cách chia sẻ hệ thống tập tin giữa hai máy ảo là sử dụng
khả năng phân lớp sao chép khi ghi (COW) của trình điều khiển khối ubd.
Mọi khối đã thay đổi đều được lưu trữ trong tệp COW riêng tư, trong khi các lần đọc được thực hiện
từ một trong hai thiết bị - thiết bị riêng nếu khối được yêu cầu hợp lệ trong
nó, cái được chia sẻ nếu không.  Sử dụng sơ đồ này, phần lớn dữ liệu
không thay đổi được chia sẻ giữa một số lượng ảo tùy ý
các máy, mỗi máy có một tệp nhỏ hơn nhiều chứa các thay đổi
mà nó đã tạo ra.  Với số lượng lớn UML khởi động từ gốc lớn
hệ thống tập tin, điều này dẫn đến tiết kiệm không gian đĩa rất lớn.

Chia sẻ dữ liệu hệ thống tập tin cũng sẽ giúp cải thiện hiệu suất vì máy chủ sẽ
có thể lưu trữ dữ liệu được chia sẻ bằng cách sử dụng lượng bộ nhớ nhỏ hơn nhiều,
vì vậy các yêu cầu đĩa UML sẽ được phục vụ từ bộ nhớ của máy chủ thay vì
các đĩa của nó.  Có một lưu ý lớn khi thực hiện việc này trên multisocket NUMA
máy móc.  Trên phần cứng như vậy, việc chạy nhiều phiên bản UML có điểm chia sẻ
hình ảnh chính và những thay đổi của COW có thể gây ra các vấn đề như NMI do vượt quá
lưu lượng giữa các socket.

Nếu bạn đang chạy UML trên phần cứng cao cấp như thế này, hãy đảm bảo
liên kết UML với một bộ CPU logic nằm trên cùng một ổ cắm bằng cách sử dụng
Lệnh ZZ0000ZZ hoặc xem phần "điều chỉnh".

Để thêm lớp sao chép khi ghi vào tệp thiết bị khối hiện có, chỉ cần
thêm tên của tệp COW vào công tắc ubd thích hợp ::

ubd0=root_fs_cow,root_fs_debian_22

trong đó ZZ0000ZZ là tệp COW riêng tư và ZZ0001ZZ là
hệ thống tập tin chia sẻ hiện có.  Tệp COW không cần tồn tại.  Nếu nó
không, trình điều khiển sẽ tạo và khởi tạo nó.

Sử dụng đĩa
----------

UML có hỗ trợ TRIM sẽ giải phóng mọi không gian chưa sử dụng trong đĩa của nó
tập tin hình ảnh vào hệ điều hành cơ bản. Điều quan trọng là sử dụng ls -ls
hoặc du để xác minh kích thước tệp thực tế.

Hiệu lực của COW.
-------------

Mọi thay đổi đối với hình ảnh chính sẽ làm mất hiệu lực tất cả các tệp COW. Nếu điều này
xảy ra, UML sẽ ZZ0000ZZ tự động xóa bất kỳ tệp COW nào và
sẽ từ chối khởi động. Trong trường hợp này giải pháp duy nhất là
khôi phục hình ảnh cũ (bao gồm cả dấu thời gian được sửa đổi lần cuối) hoặc xóa
tất cả các tệp COW sẽ dẫn đến việc giải trí chúng. Mọi thay đổi trong
các tập tin COW sẽ bị mất.

Bò có thể moo - uml_moo : Hợp nhất tệp COW với tệp sao lưu của nó
-----------------------------------------------------------------

Tùy thuộc vào cách bạn sử dụng các thiết bị UML và COW, bạn có thể nên
hợp nhất các thay đổi trong tệp COW vào tệp sao lưu mỗi lần
một lúc.

Tiện ích thực hiện việc này là uml_moo.  Cách sử dụng của nó là::

uml_moo COW_file new_backing_file


Không cần chỉ định tệp sao lưu vì thông tin đó được
đã có trong tiêu đề tệp COW.  Nếu bạn hoang tưởng, hãy khởi động cái mới
tập tin đã hợp nhất và nếu bạn hài lòng với nó, hãy di chuyển nó qua bản sao lưu cũ
tập tin.

ZZ0000ZZ tạo một tệp sao lưu mới theo mặc định như một biện pháp an toàn.
Nó cũng có tùy chọn hợp nhất phá hủy sẽ hợp nhất tệp COW
trực tiếp vào tập tin sao lưu hiện tại của nó.  Cái này thực sự chỉ có thể sử dụng được
khi tệp sao lưu chỉ có một tệp COW được liên kết với nó.  Nếu
có nhiều COW được liên kết với một tệp sao lưu, sự hợp nhất -d của
một trong số chúng sẽ vô hiệu hóa tất cả những cái khác.  Tuy nhiên, nó là
thuận tiện nếu bạn thiếu dung lượng ổ đĩa và nó cũng sẽ
nhanh hơn đáng kể so với hợp nhất không phá hủy.

ZZ0000ZZ được cài đặt cùng với gói phân phối UML và được
có sẵn như là một phần của tiện ích UML.

Truy cập tập tin máy chủ
==================

Nếu bạn muốn truy cập các tập tin trên máy chủ từ bên trong UML, bạn
có thể coi nó như một máy riêng biệt và các thư mục gắn kết nfs
từ máy chủ hoặc sao chép tệp vào máy ảo bằng scp.
Tuy nhiên, vì UML đang chạy trên máy chủ nên nó có thể truy cập những
các tập tin giống như bất kỳ quy trình nào khác và làm cho chúng có sẵn bên trong
máy ảo mà không cần sử dụng mạng.
Điều này có thể thực hiện được với hệ thống tập tin ảo Hostfs.  Với nó, bạn
có thể gắn thư mục máy chủ vào hệ thống tệp UML và truy cập
các tập tin chứa trong đó giống như bạn làm trên máy chủ.

ZZ0000ZZ

Hostfs không có bất kỳ tham số nào đối với UML Image sẽ cho phép hình ảnh
để gắn kết bất kỳ phần nào của hệ thống tập tin máy chủ và ghi vào đó. Luôn luôn
giới hạn các Hostfs vào một thư mục "vô hại" cụ thể (ví dụ ZZ0000ZZ)
nếu chạy UML. Điều này đặc biệt quan trọng nếu UML đang được chạy bằng root.

Sử dụng Hostfs
------------

Để bắt đầu, hãy đảm bảo rằng các máy chủ có sẵn bên trong máy ảo
máy có::

# cat /proc/hệ thống tập tin

ZZ0000ZZ nên được liệt kê.  Nếu không, hãy xây dựng lại kernel
với các Hostf được cấu hình trong đó hoặc đảm bảo rằng các Hostf được xây dựng dưới dạng
mô-đun và có sẵn bên trong máy ảo và cài đặt nó.


Bây giờ tất cả những gì bạn cần làm là chạy mount::

# mount không có /mnt/host -t Hostfs

sẽ gắn ZZ0000ZZ của máy chủ lên ZZ0001ZZ của máy ảo.
Nếu bạn không muốn gắn thư mục gốc của máy chủ, thì bạn có thể
chỉ định thư mục con để gắn kết bằng công tắc -o để gắn kết::

# mount none /mnt/home -t Hostfs -o /home

sẽ gắn /home của máy chủ lên /mnt/home của máy ảo.

Hostfs làm hệ thống tập tin gốc
-----------------------------

Có thể khởi động từ hệ thống phân cấp thư mục trên máy chủ bằng cách sử dụng
Hostfs thay vì sử dụng hệ thống tệp tiêu chuẩn trong một tệp.
Để bắt đầu, bạn cần có hệ thống phân cấp đó.  Cách dễ nhất là gắn vòng lặp
tệp root_fs hiện có::

#  mount root_fs uml_root_dir -o vòng lặp


Bạn cần thay đổi loại hệ thống tập tin của ZZ0000ZZ trong ZZ0001ZZ thành
'hostfs', nên dòng đó trông như thế này::

/dev/ubd/0/hostfs mặc định 1 1

Sau đó, bạn cần phải chọn cho mình tất cả các tập tin trong thư mục đó
được sở hữu bởi root.  Điều này hiệu quả với tôi ::

#  find. -uid 0 -exec chown jdike {} \;

Tiếp theo, hãy đảm bảo rằng hạt nhân UML của bạn đã được biên dịch các Hostf, không phải dưới dạng
mô-đun.  Sau đó chạy UML với thiết bị khởi động trỏ vào thư mục đó::

ubd0=/path/to/uml/root/thư mục

UML sau đó sẽ khởi động như bình thường.

Lưu ý của Hostfs
--------------

Hostfs không hỗ trợ theo dõi các thay đổi của hệ thống tập tin máy chủ trên
máy chủ (bên ngoài UML). Kết quả là, nếu một tập tin được thay đổi mà không có UML
kiến thức, UML sẽ không biết về nó và bộ nhớ đệm trong bộ nhớ của chính nó.
tập tin có thể bị hỏng. Mặc dù có thể khắc phục được điều này nhưng không phải
một cái gì đó đang được thực hiện hiện nay

Điều chỉnh UML
============

UML hiện tại hoàn toàn là bộ xử lý đơn. Tuy nhiên, nó sẽ quay lên một
số luồng để xử lý các chức năng khác nhau.

Trình điều khiển UBD, SIGIO và mô phỏng MMU thực hiện điều đó. Nếu hệ thống là
không hoạt động, các luồng này sẽ được di chuyển sang các bộ xử lý khác trên máy chủ SMP.
Thật không may, điều này thường sẽ dẫn đến hiệu suất LOWER do
tất cả lưu lượng đồng bộ hóa bộ đệm/bộ nhớ giữa các lõi. Như một
kết quả là UML thường sẽ được hưởng lợi từ việc được ghim trên một CPU duy nhất,
đặc biệt là trên một hệ thống lớn. Điều này có thể dẫn đến sự khác biệt về hiệu suất
gấp 5 lần hoặc cao hơn ở một số điểm chuẩn.

Tương tự, trên các hệ thống NUMA nhiều nút lớn, UML sẽ được hưởng lợi nếu tất cả
bộ nhớ của nó được phân bổ từ cùng một nút NUMA mà nó sẽ chạy trên đó. các
Hệ điều hành ZZ0005ZZ sẽ làm điều đó theo mặc định. Để làm được điều đó, quản trị viên hệ thống
cần tạo một đĩa ram tmpfs phù hợp được liên kết với một nút cụ thể
và sử dụng nó làm nguồn phân bổ UML RAM bằng cách chỉ định nó
trong các biến môi trường TMP hoặc TEMP. UML sẽ xem xét các giá trị
của ZZ0000ZZ, ZZ0001ZZ hoặc ZZ0002ZZ cho điều đó. Nếu thất bại, nó sẽ
tìm kiếm các shmf được gắn dưới ZZ0003ZZ. Nếu mọi thứ khác không thành công, hãy sử dụng
ZZ0004ZZ bất kể loại hệ thống tập tin được sử dụng cho nó ::

mount -t tmpfs -ompol=bind:X none /mnt/tmpfs-nodeX
   TEMP=/mnt/tmpfs-nodeX tasket -cX tùy chọn tùy chọn linux tùy chọn tùy chọn..

*******************************************
Đóng góp cho UML và phát triển cùng UML
*******************************************

UML là một nền tảng tuyệt vời để phát triển các khái niệm nhân Linux mới -
hệ thống tập tin, thiết bị, ảo hóa, v.v. Nó cung cấp khả năng vượt trội
cơ hội để tạo và thử nghiệm chúng mà không bị hạn chế
mô phỏng phần cứng cụ thể.

Ví dụ - muốn thử cách Linux hoạt động với mạng "phù hợp" 4096
thiết bị?

Không phải là vấn đề với UML. Đồng thời, đây là điều
khó khăn với các gói ảo hóa khác - chúng
bị ràng buộc bởi số lượng thiết bị được phép trên bus phần cứng
họ đang cố gắng mô phỏng (ví dụ 16 trên xe buýt PCI ở qemu).

Nếu bạn có điều gì đó muốn đóng góp chẳng hạn như một bản vá, một bản sửa lỗi, một
tính năng mới, vui lòng gửi nó tới ZZ0000ZZ.

Vui lòng làm theo tất cả các nguyên tắc vá lỗi Linux tiêu chuẩn như cc-ing
người bảo trì có liên quan và chạy ZZ0000ZZ trên bản vá của bạn.
Để biết thêm chi tiết, xem ZZ0001ZZ

Lưu ý - danh sách không chấp nhận HTML hoặc tệp đính kèm, tất cả các email phải
được định dạng dưới dạng văn bản thuần túy.

Phát triển luôn đi đôi với việc gỡ lỗi. Trước hết,
bạn luôn có thể chạy UML trong gdb và sẽ có cả một phần
sau này làm thế nào để làm điều đó. Tuy nhiên, đó không phải là cách duy nhất để
gỡ lỗi nhân Linux. Khá thường xuyên thêm các câu lệnh truy tìm và/hoặc
sử dụng các phương pháp tiếp cận cụ thể của UML chẳng hạn như truy tìm quy trình kernel UML
có nhiều thông tin hơn đáng kể.

Truy tìm UML
=============

Khi chạy, UML bao gồm một luồng nhân chính và một số
chủ đề trợ giúp. Những thứ được quan tâm để truy tìm là NOT
đã được UML kiểm tra như một phần của mô phỏng MMU.

Đây thường là ba luồng đầu tiên hiển thị trong màn hình ps.
Người có số PID thấp nhất và sử dụng CPU nhiều nhất thường là
chủ đề hạt nhân. Các chủ đề khác là đĩa
(ubd) luồng trợ giúp thiết bị và luồng trợ giúp SIGIO.
Chạy ptrace trên chủ đề này thường dẫn đến hình ảnh sau::

máy chủ $ strace -p 16566
   --- SIGIO {si_signo=SIGIO, si_code=POLL_IN, si_band=65} ---
   epoll_wait(4, [{EPOLLIN, {u32=3721159424, u64=3721159424}}], 64, 0) = 1
   epoll_wait(4, [], 64, 0) = 0
   rt_sigreturn({mask=[PIPE]}) = 16967
   ptrace(PTRACE_GETREGS, 16967, NULL, 0xd5f34f38) = 0
   ptrace(PTRACE_GETREGSET, 16967, NT_X86_XSTATE, [{iov_base=0xd5f35010, iov_len=832}]) = 0
   ptrace(PTRACE_GETSIGINFO, 16967, NULL, {si_signo=SIGTRAP, si_code=0x85, si_pid=16967, si_uid=0}) = 0
   ptrace(PTRACE_SETREGS, 16967, NULL, 0xd5f34f38) = 0
   ptrace(PTRACE_SETREGSET, 16967, NT_X86_XSTATE, [{iov_base=0xd5f35010, iov_len=2696}]) = 0
   ptrace(PTRACE_SYSEMU, 16967, NULL, 0) = 0
   --- SIGCHLD {si_signo=SIGCHLD, si_code=CLD_TRAPPED, si_pid=16967, si_uid=0, si_status=SIGTRAP, si_utime=65, si_stime=89} ---
   wait4(16967, [{WIFSTOPPED(s) && WSTOPSIG(s) == SIGTRAP ZZ0000ZZ__WALL, NULL) = 16967
   ptrace(PTRACE_GETREGS, 16967, NULL, 0xd5f34f38) = 0
   ptrace(PTRACE_GETREGSET, 16967, NT_X86_XSTATE, [{iov_base=0xd5f35010, iov_len=832}]) = 0
   ptrace(PTRACE_GETSIGINFO, 16967, NULL, {si_signo=SIGTRAP, si_code=0x85, si_pid=16967, si_uid=0}) = 0
   hẹn giờ_settime(0, 0, {it_interval={tv_sec=0, tv_nsec=0}, it_value={tv_sec=0, tv_nsec=2830912}}, NULL) = 0
   getpid() = 16566
   clock_nanosleep(CLOCK_MONOTONIC, 0, {tv_sec=1, tv_nsec=0}, NULL) = ? ERESTART_RESTARTBLOCK (Bị gián đoạn bởi tín hiệu)
   --- SIGALRM {si_signo=SIGALRM, si_code=SI_TIMER, si_timerid=0, si_overrun=0, si_value={int=1631716592, ptr=0x614204f0}} ---
   rt_sigreturn({mask=[PIPE]}) = -1 EINTR (Cuộc gọi hệ thống bị gián đoạn)

Đây là hình ảnh điển hình từ phiên bản UML gần như không hoạt động.

* Bộ điều khiển ngắt UML sử dụng epoll - đây là UML đang chờ IO
  ngắt:

epoll_wait(4, [{EPOLLIN, {u32=3721159424, u64=3721159424}}], 64, 0) = 1

* Chuỗi lệnh gọi ptrace là một phần của mô phỏng MMU và chạy
  Không gian người dùng UML.
* ZZ0000ZZ là một phần của ánh xạ hệ thống con bộ đếm thời gian độ phân giải cao UML
  yêu cầu hẹn giờ từ bên trong UML lên bộ hẹn giờ có độ phân giải cao của máy chủ.
* ZZ0001ZZ là UML đang ở chế độ chờ (tương tự như cách PC
  sẽ thực thi ACPI không hoạt động).

Như bạn có thể thấy UML sẽ tạo ra khá nhiều đầu ra ngay cả khi không hoạt động. Đầu ra
có thể rất nhiều thông tin khi quan sát IO. Nó hiển thị các cuộc gọi IO thực tế,
đối số và trả về giá trị.

Gỡ lỗi hạt nhân
================

Bây giờ bạn có thể chạy UML trong gdb, mặc dù nó không nhất thiết phải đồng ý với
được bắt đầu theo nó. Nếu bạn đang cố gắng theo dõi một lỗi thời gian chạy, thì đó là
tốt hơn hết là đính kèm gdb vào một phiên bản UML đang chạy và để UML chạy.

Giả sử cùng số PID như trong ví dụ trước, đây sẽ là::

# gdb-p 16566

Đây sẽ là STOP phiên bản UML, vì vậy bạn phải nhập ZZ0000ZZ tại GDB
dòng lệnh để yêu cầu nó tiếp tục. Nó có thể là một ý tưởng tốt để thực hiện
cái này thành tập lệnh gdb và chuyển nó tới gdb làm đối số.

Phát triển trình điều khiển thiết bị
=========================

Gần như tất cả các trình điều khiển UML đều nguyên khối. Mặc dù có thể xây dựng một
Trình điều khiển UML dưới dạng mô-đun hạt nhân, giới hạn chức năng có thể có
chỉ trong kernel và không dành riêng cho UML.  Lý do cho điều này là
để thực sự tận dụng UML, người ta cần viết một đoạn
mã không gian người dùng ánh xạ các khái niệm trình điều khiển vào máy chủ không gian người dùng thực tế
cuộc gọi.

Điều này tạo thành cái gọi là phần "người dùng" của trình điều khiển. Trong khi nó có thể
sử dụng lại rất nhiều khái niệm kernel, nói chung nó chỉ là một phần khác của
mã không gian người dùng. Phần này cần một số mã "kernel" phù hợp
nằm bên trong hình ảnh UML và thực hiện phần nhân Linux.

ZZ0000ZZ.

UML không có API kernel-to-host được xác định nghiêm ngặt. Nó không
cố gắng mô phỏng một kiến trúc hoặc xe buýt cụ thể. "hạt nhân" của UML và
"người dùng" có thể chia sẻ bộ nhớ, mã và tương tác khi cần thiết để triển khai
bất kỳ thiết kế nào mà nhà phát triển phần mềm có trong đầu. duy nhất
những hạn chế hoàn toàn là kỹ thuật. Do có nhiều chức năng và
các biến có cùng tên, nhà phát triển nên cẩn thận
bao gồm và các thư viện mà họ đang cố gắng tham khảo.

Kết quả là rất nhiều mã không gian người dùng bao gồm các trình bao bọc đơn giản.
Ví dụ. ZZ0000ZZ chỉ là phần bao bọc xung quanh ZZ0001ZZ
đảm bảo rằng chức năng không gian người dùng đóng không xung đột
với (các) hàm có tên tương tự trong phần kernel.

Sử dụng UML làm nền tảng thử nghiệm
============================

UML là một nền tảng thử nghiệm tuyệt vời để phát triển trình điều khiển thiết bị. Như
với hầu hết mọi thứ UML, "có thể cần một số thao tác lắp ráp của người dùng". Đó là
tùy thuộc vào người dùng để xây dựng môi trường mô phỏng của họ. UML hiện tại
chỉ cung cấp cơ sở hạ tầng hạt nhân.

Một phần của cơ sở hạ tầng này là khả năng tải và phân tích fdt
các đốm màu cây thiết bị như được sử dụng trong nền tảng Arm hoặc Open Firmware. Những cái này
được cung cấp dưới dạng đối số bổ sung tùy chọn cho lệnh kernel
dòng::

dtb=tên tệp

Cây thiết bị được tải và phân tích lúc khởi động và có thể truy cập được bằng
trình điều khiển truy vấn nó. Tại thời điểm này cơ sở này là
chỉ nhằm mục đích phát triển. Các thiết bị riêng của UML không
truy vấn cây thiết bị.

Cân nhắc về bảo mật
-----------------------

Trình điều khiển hoặc bất kỳ chức năng mới nào sẽ được mặc định là không
chấp nhận tên tệp tùy ý, mã bpf hoặc các tham số khác
có thể ảnh hưởng đến máy chủ từ bên trong phiên bản UML.
Ví dụ: chỉ định ổ cắm được sử dụng cho giao tiếp IPC
giữa trình điều khiển và máy chủ tại dòng lệnh UML là OK
bảo mật khôn ngoan. Cho phép nó như một tham số mô-đun có thể tải
không phải.

Nếu chức năng đó là mong muốn cho một ứng dụng cụ thể
(ví dụ: tải "chương trình cơ sở" BPF để vận chuyển mạng ổ cắm thô),
nó phải được tắt theo mặc định và phải được bật một cách rõ ràng
như một tham số dòng lệnh khi khởi động.

Ngay cả với suy nghĩ này, mức độ cô lập giữa UML
và máy chủ tương đối yếu. Nếu không gian người dùng UML là
được phép tải trình điều khiển hạt nhân tùy ý, kẻ tấn công có thể
sử dụng điều này để thoát ra khỏi UML. Vì vậy, nếu UML được sử dụng trong
một ứng dụng sản xuất, chúng tôi khuyến nghị rằng tất cả các mô-đun
được tải khi khởi động và tải mô-đun hạt nhân bị tắt
sau đó.