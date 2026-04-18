.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/chelsio/cxgb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

=================================================
Bộ điều khiển mạng Ethernet Chelsio N210 10Gb
=================================================

Ghi chú phát hành trình điều khiển cho Linux

Phiên bản 2.1.1

Ngày 20 tháng 6 năm 2005

.. Contents

 INTRODUCTION
 FEATURES
 PERFORMANCE
 DRIVER MESSAGES
 KNOWN ISSUES
 SUPPORT


Giới thiệu
============

Tài liệu này mô tả trình điều khiển Linux cho Mạng Ethernet Chelsio 10Gb
 Người điều khiển. Trình điều khiển này hỗ trợ Chelsio N210 NIC và lạc hậu
 tương thích với NIC 10Gb kiểu Chelsio N110.


Đặc trưng
========

Ngắt thích ứng (adaptive-rx)
---------------------------------

Tính năng này cung cấp một thuật toán thích ứng để điều chỉnh ngắt
  kết hợp các tham số, cho phép trình điều khiển tự động điều chỉnh độ trễ
  cài đặt để đạt được hiệu suất cao nhất trong các loại mạng khác nhau
  tải.

Giao diện được sử dụng để kiểm soát tính năng này là ethtool. Xin vui lòng xem
  trang chủ ethtool để biết thêm thông tin sử dụng.

Theo mặc định, Adaptive-rx bị tắt.
  Để bật Adaptive-rx::

ethtool -C <interface> thích ứng-rx bật

Để tắt Adaptive-rx, hãy sử dụng ethtool::

ethtool -C <interface> thích ứng-rx tắt

Sau khi tắt Adaptive-rx, giá trị độ trễ của bộ hẹn giờ sẽ được đặt thành 50us.
  Bạn có thể đặt độ trễ hẹn giờ sau khi tắt Adaptive-rx::

ethtool -C <giao diện> rx-usecs <micro giây>

Một ví dụ để đặt giá trị độ trễ hẹn giờ thành 100us trên eth0 ::

ethtool -C eth0 rx-usecs 100

Bạn cũng có thể cung cấp giá trị độ trễ hẹn giờ trong khi tắt Adaptive-rx::

ethtool -C <giao diện> thích ứng-rx tắt rx-usecs <micro giây>

Nếu Adaptive-rx bị tắt và giá trị độ trễ của bộ định thời được chỉ định, bộ định thời
  sẽ được đặt thành giá trị được chỉ định cho đến khi người dùng thay đổi hoặc cho đến khi
  Adaptive-rx được kích hoạt.

Để xem trạng thái của các giá trị độ trễ thích ứng-rx và bộ hẹn giờ::

ethtool -c <giao diện>


Hỗ trợ giảm tải phân đoạn TCP (TSO)
-----------------------------------------

Tính năng này, còn được gọi là "gửi lớn", cho phép xếp chồng giao thức của hệ thống
  để giảm tải các phần xử lý TCP gửi đi sang thẻ giao diện mạng
  do đó làm giảm việc sử dụng hệ thống CPU và nâng cao hiệu suất.

Giao diện dùng để điều khiển tính năng này là ethtool phiên bản 1.8 trở lên.
  Vui lòng xem trang chủ ethtool để biết thêm thông tin sử dụng.

Theo mặc định, TSO được bật.
  Để tắt TSO::

ethtool -K <giao diện> tắt

Để bật TSO::

ethtool -K <interface> tso on

Để xem trạng thái của TSO::

ethtool -k <giao diện>


Hiệu suất
===========

Thông tin sau đây được cung cấp như một ví dụ về cách thay đổi hệ thống
 các tham số để "điều chỉnh hiệu suất" và giá trị nào sẽ sử dụng. Bạn có thể hoặc không
 muốn thay đổi các tham số hệ thống này, tùy thuộc vào máy chủ/máy trạm của bạn
 ứng dụng. Chelsio Communications không bảo đảm việc này dưới bất kỳ hình thức nào,
 và được thực hiện tại "YOUR OWN RISK". Chelsio sẽ không chịu trách nhiệm về tổn thất
 dữ liệu hoặc hư hỏng thiết bị.

Bản phân phối của bạn có thể có cách thực hiện khác hoặc bạn có thể thích
 một phương pháp khác. Các lệnh này được hiển thị chỉ để cung cấp một ví dụ về
 phải làm gì và không có nghĩa là dứt khoát.

Việc thực hiện bất kỳ thay đổi hệ thống nào sau đây sẽ chỉ kéo dài cho đến khi bạn khởi động lại
 hệ thống của bạn. Bạn có thể muốn viết một đoạn script chạy khi khởi động.
 bao gồm các cài đặt tối ưu cho hệ thống của bạn.

Cài đặt bộ đếm thời gian trễ PCI::

setpci -d 1425::

* 0x0c.l=0x0000F800

Vô hiệu hóa dấu thời gian TCP::

sysctl -w net.ipv4.tcp_timestamps=0

Vô hiệu hóa SACK::

sysctl -w net.ipv4.tcp_sack=0

Đặt số lượng lớn yêu cầu kết nối đến::

sysctl -w net.ipv4.tcp_max_syn_backlog=3000

Đặt kích thước bộ đệm ổ cắm nhận tối đa::

sysctl -w net.core.rmem_max=1024000

Đặt kích thước bộ đệm ổ cắm gửi tối đa::

sysctl -w net.core.wmem_max=1024000

Đặt smp_affinity (trên hệ thống đa bộ xử lý) thành một CPU ::

echo 1 > /proc/irq/<interrupt_number>/smp_affinity

Đặt kích thước bộ đệm ổ cắm nhận mặc định::

sysctl -w net.core.rmem_default=524287

Đặt kích thước bộ đệm ổ cắm gửi mặc định::

sysctl -w net.core.wmem_default=524287

Đặt bộ đệm bộ nhớ tùy chọn tối đa::

sysctl -w net.core.optmem_max=524287

Đặt tồn đọng tối đa (các gói chưa được xử lý # of trước khi hạt nhân bị loại bỏ)::

sysctl -w net.core.netdev_max_backlog=300000

Đặt bộ đệm đọc TCP (tối thiểu/mặc định/tối đa)::

sysctl -w net.ipv4.tcp_rmem="10000000 10000000 10000000"

Cài đặt bộ đệm ghi TCP (tối thiểu/áp suất/tối đa)::

sysctl -w net.ipv4.tcp_wmem="10000000 10000000 10000000"

Cài đặt không gian đệm TCP (tối thiểu/áp suất/tối đa)::

sysctl -w net.ipv4.tcp_mem="10000000 10000000 10000000"

Kích thước cửa sổ TCP cho các kết nối đơn:

Kích thước bộ đệm nhận (RX_WINDOW) ít nhất phải lớn bằng
   Độ trễ băng thông Sản phẩm của liên kết truyền thông giữa người gửi và
   người nhận. Do các biến thể của RTT, bạn có thể muốn tăng bộ đệm
   kích thước lên tới 2 lần Sản phẩm độ trễ băng thông. Trang tham khảo 289 của
   "TCP/IP được minh họa, Tập 1, Các giao thức" của W. Richard Stevens.

Ở tốc độ 10Gb, hãy sử dụng công thức sau::

RX_WINDOW >= 1,25 MB * RTT (tính bằng mili giây)
       Ví dụ cho RTT với 100us: RX_WINDOW = (1.250.000 * 0,1) = 125.000

Kích thước RX_WINDOW từ 256KB - 512KB là đủ.

Đặt kích thước bộ đệm nhận tối thiểu, tối đa và mặc định (RX_WINDOW)::

sysctl -w net.ipv4.tcp_rmem="<min> <default> <max>"

Kích thước cửa sổ TCP cho nhiều kết nối:
   Kích thước bộ đệm nhận (RX_WINDOW) có thể được tính giống như kích thước bộ đệm nhận
   kết nối, nhưng nên được chia cho số lượng kết nối. các
   cửa sổ nhỏ hơn ngăn ngừa tắc nghẽn và tạo điều kiện cho nhịp độ tốt hơn,
   đặc biệt nếu/khi điều khiển luồng mức MAC không hoạt động tốt hoặc khi nó bị lỗi
   không được hỗ trợ trên máy. Thí nghiệm có thể cần thiết để đạt được
   giá trị đúng. Phương pháp này được cung cấp như một điểm khởi đầu cho
   kích thước bộ đệm nhận chính xác.

Đặt kích thước bộ đệm nhận tối thiểu, tối đa và mặc định (RX_WINDOW) là
   được thực hiện theo cách tương tự như kết nối đơn.


Tin nhắn trình điều khiển
===============

Các thông báo sau đây là những thông báo phổ biến nhất được nhật ký hệ thống ghi lại. Những cái này
 có thể được tìm thấy trong /var/log/messages.

Lái xe lên::

Trình điều khiển mạng Chelsio - phiên bản 2.1.1

Đã phát hiện NIC::

eth#: Chelsio N210 1x10GBaseX NIC (vòng #), PCIX 133 MHz/64-bit

Liên kết::

eth#: liên kết đạt tốc độ 10 Gbps, song công hoàn toàn

Liên kết xuống::

eth#: liên kết bị hỏng


Sự cố đã biết
============

Những vấn đề này đã được xác định trong quá trình thử nghiệm. Thông tin sau
 được cung cấp như một cách giải quyết vấn đề. Trong một số trường hợp, vấn đề này
 vốn có của Linux hoặc của một bản phân phối và/hoặc phần cứng Linux cụ thể
 nền tảng.

1. Số lượng lớn TCP truyền lại trên hệ thống đa bộ xử lý (SMP).

Trên hệ thống có nhiều CPU, ngắt (IRQ) cho mạng
      bộ điều khiển có thể được liên kết với nhiều CPU. Điều này sẽ gây ra TCP
      truyền lại nếu dữ liệu gói được phân chia trên các CPU khác nhau
      và được lắp ráp lại theo một thứ tự khác với dự kiến.

Để loại bỏ việc truyền lại TCP, hãy đặt smp_affinity trên thiết bị cụ thể
      ngắt tới một CPU duy nhất. Bạn có thể xác định vị trí ngắt (IRQ) được sử dụng trên
      N110/N210 bằng cách sử dụng ifconfig::

ifconfig <dev_name> | ngắt grep

Đặt smp_affinity thành một CPU::

echo 1 > /proc/irq/<interrupt_number>/smp_affinity

Chúng tôi khuyên bạn không nên chạy trình nền mất cân bằng trên máy tính của mình.
      hệ thống, vì điều này sẽ thay đổi mọi cài đặt smp_affinity mà bạn đã áp dụng.
      Daemon mất cân bằng chạy trong khoảng thời gian 10 giây và liên kết các ngắt
      đến CPU được tải ít nhất được xác định bởi daemon. Để tắt daemon này::

chkconfig --level 2345 mất cân bằng tắt

Theo mặc định, một số bản phân phối Linux kích hoạt tính năng kernel,
      mất cân bằng, thực hiện chức năng tương tự như daemon. Để vô hiệu hóa
      tính năng này, hãy thêm dòng sau vào bộ nạp khởi động của bạn ::

noirqbalance

Ví dụ sử dụng bộ tải khởi động Grub::

tiêu đề Red Hat Enterprise Linux AS (2.4.21-27.ELsmp)
	      gốc (hd0,0)
	      kernel /vmlinuz-2.4.21-27.ELsmp ro root=/dev/hda3 noirqbalance
	      initrd /initrd-2.4.21-27.ELsmp.img

2. Sau khi chạy insmod, driver được tải và mạng không chính xác
     giao diện được đưa lên mà không cần chạy ifup.

Khi sử dụng nhân 2.4.x, bao gồm nhân RHEL, nhân Linux
      gọi một tập lệnh có tên "hotplug". Kịch bản này chủ yếu được sử dụng để
      Tuy nhiên, tự động hiển thị các thiết bị USB khi chúng được cắm vào
      tập lệnh cũng cố gắng tự động hiển thị giao diện mạng
      sau khi tải mô-đun hạt nhân. Tập lệnh hotplug thực hiện việc này bằng cách quét
      các tệp ifcfg-eth# config trong /etc/sysconfig/network-scripts, đang tìm kiếm
      cho HWADDR=<mac_address>.

Nếu tập lệnh hotplug không tìm thấy HWADDRR trong bất kỳ
      ifcfg-eth# files, nó sẽ hiển thị thiết bị có sẵn tiếp theo
      tên giao diện. Nếu giao diện này đã được cấu hình cho một giao diện khác
      card mạng, giao diện mới của bạn sẽ có địa chỉ IP không chính xác và
      cài đặt mạng.

Để giải quyết vấn đề này, bạn có thể thêm khóa HWADDR=<mac_address> vào
      tập tin cấu hình giao diện của bộ điều khiển mạng của bạn.

Để tắt tính năng "hotplug" này, bạn có thể thêm trình điều khiển (tên mô-đun)
      vào tệp "danh sách đen" nằm trong /etc/hotplug. Nó đã được lưu ý rằng
      điều này không hoạt động đối với các thiết bị mạng vì tập lệnh net.agent
      không sử dụng tập tin danh sách đen. Chỉ cần xóa hoặc đổi tên net.agent
      tập lệnh nằm trong /etc/hotplug để tắt tính năng này.

3. Giao thức vận chuyển (TP) bị treo khi chạy lưu lượng đa kết nối lớn
     trên hệ thống Opteron AMD với chipset Đường hầm HyperTransport PCI-X.

Nếu hệ thống Opteron AMD của bạn sử dụng Đường hầm AMD-8131 HyperTransport PCI-X
      chipset, bạn có thể gặp phải "Dữ liệu hoàn thành phân chia chế độ 133-Mhz
      Corruption" được xác định bởi AMD khi sử dụng thẻ PCI-X 133Mhz trên
      xe buýt PCI-X xe buýt.

AMD tuyên bố, "Trong các điều kiện đặc biệt cao, Đường hầm AMD-8131 PCI-X
      có thể cung cấp dữ liệu cũ thông qua chu kỳ hoàn thành phân chia tới thẻ PCI-X
      đang hoạt động ở tần số 133 Mhz", gây ra hỏng dữ liệu.

Tuy nhiên, AMD cung cấp ba cách giải quyết cho vấn đề này, Chelsio
      đề xuất tùy chọn đầu tiên để có hiệu suất tốt nhất với lỗi này:

Đối với hoạt động của bus thứ cấp 133Mhz, hãy giới hạn độ dài giao dịch và
	số lượng giao dịch chưa thanh toán, thông qua cấu hình BIOS
	lập trình thẻ PCI-X như sau:

Độ dài dữ liệu (byte): 1k

Tổng số giao dịch tồn đọng được phép: 2

Vui lòng tham khảo AMD 8131-HT/PCI-X Errata 26310 Rev 3.08 tháng 8 năm 2004,
      phần 56, "Hỏng dữ liệu hoàn thành phân chia chế độ 133 MHz" để biết thêm
      chi tiết về lỗi này và cách giải quyết được đề xuất bởi AMD.

Có thể hoạt động bên ngoài cài đặt PCI-X được đề xuất của AMD, hãy thử
      tăng Độ dài dữ liệu lên 2k byte để tăng hiệu suất. Nếu bạn
      gặp sự cố với các cài đặt này, vui lòng quay lại cài đặt "an toàn"
      và lặp lại vấn đề trước khi gửi lỗi hoặc yêu cầu hỗ trợ.

      .. note::

Cài đặt mặc định trên hầu hết các hệ thống là 8 giao dịch chưa xử lý
	    và độ dài dữ liệu 2k byte.

4. Trên các hệ thống đa bộ xử lý, cần lưu ý rằng một ứng dụng
     đang xử lý mạng 10Gb có thể chuyển đổi giữa các CPU gây ra tình trạng xuống cấp
     và/hoặc hiệu suất không ổn định.

Nếu chạy trên hệ thống SMP và thực hiện các phép đo hiệu suất, nó
      chúng tôi khuyên bạn nên chạy netperf-2.4.0+ mới nhất hoặc sử dụng liên kết
      công cụ như tiện ích procstate của Tim Hockin (runon)
      <ZZ0000ZZ

Liên kết netserver và netperf (hoặc các ứng dụng khác) với cụ thể
      CPU sẽ có sự khác biệt đáng kể trong phép đo hiệu năng.
      Bạn có thể cần thử nghiệm CPU nào để liên kết ứng dụng trong
      để đạt được hiệu suất tốt nhất cho hệ thống của bạn.

Nếu bạn đang phát triển một ứng dụng được thiết kế cho mạng 10Gb,
      xin lưu ý rằng bạn có thể muốn xem xét các chức năng của kernel
      sched_setaffinity & sched_getaffinity để liên kết ứng dụng của bạn.

Nếu bạn chỉ chạy các ứng dụng trong không gian người dùng như ftp, telnet,
      v.v., bạn có thể muốn dùng thử công cụ runon do Tim Hockin's cung cấp
      tiện ích Procstate. Bạn cũng có thể thử liên kết giao diện với một
      CPU cụ thể: runon 0 ifup eth0


Ủng hộ
=======

Nếu bạn gặp vấn đề với phần mềm hoặc phần cứng, vui lòng liên hệ với chúng tôi
 nhóm hỗ trợ khách hàng qua email tại support@chelsio.com hoặc kiểm tra trang web của chúng tôi
 tại ZZ0000ZZ

-------------------------------------------------------------------------------

::

Truyền thông Chelsio
 370 Đại lộ San Aleso.
 Phòng 100
 Sunnyvale, CA 94085
 ZZ0000ZZ

Chương trình này là phần mềm miễn phí; bạn có thể phân phối lại nó và/hoặc sửa đổi
nó theo các điều khoản của Giấy phép Công cộng GNU, phiên bản 2, như
được xuất bản bởi Tổ chức Phần mềm Tự do.

Bạn hẳn đã nhận được bản sao Giấy phép Công cộng GNU cùng với
với chương trình này; nếu không, hãy viết thư cho Free Software Foundation, Inc.,
59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

THIS SOFTWARE LÀ PROVIDED ZZ0000ZZ AND WITHOUT ANY EXPRESS HOẶC IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES CỦA
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.

Bản quyền ZZ0000ZZ 2003-2005 Chelsio Communications. Mọi quyền được bảo lưu.