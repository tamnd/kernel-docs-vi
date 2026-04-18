.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/s390/vfio-ap.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================
Cơ sở xử lý phụ trợ (AP)
===============================


Giới thiệu
============
Cơ sở Bộ xử lý phụ trợ (AP) là cơ sở mật mã IBM Z bao gồm
gồm ba lệnh AP và từ 1 đến 256 thẻ bộ điều hợp mật mã PCIe.
Các thiết bị AP cung cấp chức năng mã hóa cho tất cả các CPU được gán cho một
hệ thống linux chạy trong hệ thống IBM Z LPAR.

Các thẻ bộ chuyển đổi AP được hiển thị thông qua bus AP. Động lực cho vfio-ap
là cung cấp thẻ AP cho khách KVM bằng thiết bị trung gian VFIO
khuôn khổ. Việc triển khai này phụ thuộc đáng kể vào ảo hóa s390
các cơ sở thực hiện hầu hết công việc khó khăn trong việc cung cấp quyền truy cập trực tiếp vào AP
thiết bị.

Tổng quan về kiến ​​trúc AP
=========================
Để dễ dàng hiểu được thiết kế, hãy bắt đầu với một số
định nghĩa:

* Bộ chuyển đổi AP

Bộ điều hợp AP là thẻ bộ điều hợp IBM Z có thể thực hiện mật mã
  chức năng. Có thể có từ 0 đến 256 bộ điều hợp được gán cho LPAR. Bộ điều hợp
  được gán cho LPAR trong đó máy chủ linux đang chạy sẽ có sẵn cho
  máy chủ linux. Mỗi bộ chuyển đổi được xác định bằng một số từ 0 đến 255; tuy nhiên,
  số bộ điều hợp tối đa được xác định theo kiểu máy và/hoặc loại bộ điều hợp.
  Khi được cài đặt, bộ chuyển đổi AP được truy cập bằng các lệnh AP được thực thi bởi bất kỳ
  CPU.

Thẻ bộ điều hợp AP được gán cho LPAR nhất định thông qua Kích hoạt của hệ thống
  Hồ sơ có thể được chỉnh sửa thông qua HMC. Khi hệ thống máy chủ linux là IPL'd
  trong LPAR, bus AP phát hiện các thẻ bộ điều hợp AP được gán cho LPAR và
  tạo một thiết bị sysfs cho mỗi bộ điều hợp được chỉ định. Ví dụ: nếu bộ điều hợp AP
  4 và 10 (0x0a) được gán cho LPAR, bus AP sẽ tạo như sau
  mục nhập thiết bị sysfs::

/sys/thiết bị/ap/card04
    /sys/thiết bị/ap/card0a

Các liên kết tượng trưng đến các thiết bị này cũng sẽ được tạo trong các thiết bị bus AP
  thư mục con::

/sys/bus/ap/thiết bị/[card04]
    /sys/bus/ap/thiết bị/[card04]

* Miền AP

Một bộ điều hợp được phân vùng thành các miền. Một bộ chuyển đổi có thể chứa tới 256 tên miền
  tùy thuộc vào loại bộ chuyển đổi và cấu hình phần cứng. Một miền là
  được xác định bằng số từ 0 đến 255; tuy nhiên, số miền tối đa là
  được xác định theo kiểu máy và/hoặc loại bộ điều hợp.. Có thể nghĩ đến một miền
  như một tập hợp các thanh ghi phần cứng và bộ nhớ được sử dụng để xử lý các lệnh AP. A
  tên miền có thể được cấu hình bằng khóa riêng an toàn được sử dụng cho khóa rõ ràng
  mã hóa. Một tên miền được phân loại theo một trong hai cách tùy thuộc vào cách nó
  có thể được truy cập:

* Miền sử dụng là miền được hướng dẫn bởi AP nhắm tới
      xử lý lệnh AP.

* Miền kiểm soát là miền được thay đổi bởi lệnh AP được gửi tới
      miền sử dụng; ví dụ: để đặt khóa riêng an toàn cho điều khiển
      miền.

Miền kiểm soát và sử dụng AP được gán cho LPAR nhất định thông qua hệ thống
  Hồ sơ kích hoạt có thể được chỉnh sửa thông qua HMC. Khi một hệ thống máy chủ linux
  là IPL'd trong LPAR, mô-đun bus AP phát hiện việc sử dụng và kiểm soát AP
  các miền được gán cho LPAR. Số miền của từng miền sử dụng và
  số bộ điều hợp của mỗi bộ điều hợp AP được kết hợp để tạo ra các thiết bị xếp hàng AP
  (xem phần Hàng đợi AP bên dưới). Số miền của mỗi miền điều khiển sẽ là
  được biểu diễn dưới dạng bitmask và được lưu trữ trong tệp sysfs
  /sys/bus/ap/ap_control_domain_mask. Các bit trong mặt nạ, từ nhiều nhất đến ít nhất
  bit có ý nghĩa, tương ứng với các miền 0-255.

* Hàng đợi AP

Hàng đợi AP là phương tiện để gửi lệnh AP đến miền sử dụng
  bên trong một bộ chuyển đổi cụ thể. Hàng đợi AP được xác định bởi một bộ dữ liệu
  bao gồm ID bộ điều hợp AP (APID) và chỉ mục hàng đợi AP (APQI). các
  APQI tương ứng với số miền sử dụng nhất định trong bộ điều hợp. Bộ dữ liệu này
  tạo thành Số hàng đợi AP (APQN) xác định duy nhất hàng đợi AP. AP
  hướng dẫn bao gồm một trường chứa APQN để xác định hàng đợi AP để
  lệnh AP nào sẽ được gửi để xử lý.

Bus AP sẽ tạo một thiết bị sysfs cho mỗi APQN có thể được lấy từ
  sản phẩm chéo của bộ điều hợp AP và số miền sử dụng được phát hiện khi
  Mô-đun bus AP đã được tải. Ví dụ: nếu bộ điều hợp 4 và 10 (0x0a) và mức sử dụng
  miền 6 và 71 (0x47) được gán cho LPAR, bus AP sẽ tạo
  các mục sysfs sau::

/sys/thiết bị/ap/card04/04.0006
    /sys/thiết bị/ap/card04/04.0047
    /sys/devices/ap/card0a/0a.0006
    /sys/devices/ap/card0a/0a.0047

Các liên kết tượng trưng sau đây đến các thiết bị này sẽ được tạo trong bus AP
  thư mục con của thiết bị::

/sys/bus/ap/thiết bị/[04.0006]
    /sys/bus/ap/thiết bị/[04.0047]
    /sys/bus/ap/devices/[0a.0006]
    /sys/bus/ap/thiết bị/[0a.0047]

* Hướng dẫn AP:

Có ba hướng dẫn AP:

* NQAP: để xếp một thông báo yêu cầu lệnh AP vào hàng đợi
  * DQAP: để loại bỏ tin nhắn trả lời lệnh AP khỏi hàng đợi
  * PQAP: để quản lý hàng đợi

Hướng dẫn AP xác định miền được nhắm mục tiêu để xử lý AP
  lệnh; đây phải là một trong những miền sử dụng. Lệnh AP có thể sửa đổi một
  miền không phải là một trong các miền sử dụng mà là miền được sửa đổi
  phải là một trong các miền điều khiển.

AP và SIE
==========
Bây giờ chúng ta hãy xem cách diễn giải các lệnh AP được thực hiện trên máy khách
bởi phần cứng.

Một khối điều khiển vệ tinh được gọi là Khối điều khiển mật mã (CRYCB) được gắn vào
khối điều khiển ảo hóa phần cứng chính của chúng tôi. CRYCB chứa Điều khiển AP
Khối (APCB) có ba trường để xác định bộ điều hợp, miền sử dụng và
kiểm soát các miền được gán cho khách KVM:

* Trường Mặt nạ AP (APM) là mặt nạ bit xác định các bộ điều hợp AP được chỉ định
  gửi tới khách KVM. Mỗi bit trong mặt nạ, từ trái sang phải, tương ứng với
  một APID từ 0-255. Nếu một bit được đặt, bộ chuyển đổi tương ứng sẽ hợp lệ cho
  sử dụng bởi khách KVM.

* Trường Mặt nạ hàng đợi AP (AQM) là mặt nạ bit xác định miền sử dụng AP
  được gán cho khách KVM. Mỗi bit trong mặt nạ, từ trái sang phải,
  tương ứng với chỉ số hàng đợi AP (APQI) từ 0-255. Nếu một bit được thiết lập,
  hàng đợi tương ứng có giá trị để khách KVM sử dụng.

* Trường Mặt nạ miền AP là mặt nạ bit xác định miền kiểm soát AP
  được gán cho khách KVM. Mặt nạ bit ADM kiểm soát những miền nào có thể được
  được thay đổi bởi một thông báo yêu cầu lệnh AP được gửi đến miền sử dụng từ
  khách. Mỗi bit trong mặt nạ, từ trái sang phải, tương ứng với một miền từ
  0-255. Nếu một bit được đặt, miền tương ứng có thể được sửa đổi bởi AP
  thông báo yêu cầu lệnh được gửi tới miền sử dụng.

Nếu bạn nhớ lại mô tả về Hàng đợi AP, các hướng dẫn AP bao gồm
một APQN để xác định hàng đợi AP mà thông báo yêu cầu lệnh AP sẽ được gửi tới
được gửi (lệnh NQAP và PQAP), hoặc từ đó một thông báo trả lời lệnh được gửi tới
được nhận (lệnh DQAP). Hiệu lực của APQN được xác định bởi ma trận
được tính từ APM và AQM; nó là tích Descartes của tất cả những gì được giao
số bộ điều hợp (APM) với tất cả các chỉ mục hàng đợi được chỉ định (AQM). Ví dụ, nếu
bộ điều hợp 1 và 2 cũng như miền sử dụng 5 và 6 được gán cho khách, APQN
(1,5), (1,6), (2,5) và (2,6) sẽ có giá trị đối với khách.

APQN có thể cung cấp chức năng khóa bảo mật - tức là khóa riêng được lưu trữ
trên thẻ bộ điều hợp cho từng miền của nó - vì vậy mỗi APQN phải được gán cho
tối đa một khách hoặc tới máy chủ linux ::

Ví dụ 1: Cấu hình hợp lệ:
   ------------------------------
   Guest1: bộ điều hợp 1,2 tên miền 5,6
   Guest2: bộ chuyển đổi 1,2 tên miền 7

Điều này hợp lệ vì cả hai khách đều có một bộ APQN duy nhất:
      Guest1 có APQN (1,5), (1,6), (2,5), (2,6);
      Guest2 có APQN (1,7), (2,7)

Ví dụ 2: Cấu hình hợp lệ:
   ------------------------------
   Guest1: bộ điều hợp 1,2 tên miền 5,6
   Guest2: bộ điều hợp 3,4 tên miền 5,6

Điều này cũng hợp lệ vì cả hai khách đều có một bộ APQN duy nhất:
      Guest1 có APQN (1,5), (1,6), (2,5), (2,6);
      Guest2 có APQN (3,5), (3,6), (4,5), (4,6)

Ví dụ 3: Cấu hình không hợp lệ:
   --------------------------------
   Guest1: bộ điều hợp 1,2 tên miền 5,6
   Guest2: adapter 1 tên miền 6,7

Đây là cấu hình không hợp lệ vì cả hai khách đều có quyền truy cập vào
   APQN (1,6).

Thiết kế
==========
Thiết kế giới thiệu ba đối tượng mới:

1. Thiết bị ma trận AP
2. Trình điều khiển thiết bị AP VFIO (vfio_ap.ko)
3. Thiết bị truyền qua trung gian VFIO AP

Trình điều khiển thiết bị VFIO AP
-------------------------
Trình điều khiển thiết bị VFIO AP (vfio_ap) phục vụ các mục đích sau:

1. Cung cấp các giao diện để bảo mật APQN dành riêng cho khách KVM.

2. Thiết lập giao diện thiết bị qua trung gian VFIO để quản lý vfio_ap qua trung gian
   thiết bị và tạo các giao diện sysfs để gán các bộ điều hợp, cách sử dụng
   miền và miền điều khiển bao gồm ma trận dành cho khách KVM.

3. Định cấu hình APM, AQM và ADM trong APCB có trong CRYCB được tham chiếu
   bởi một khách KVM Mô tả trạng thái SIE của khách để cấp cho khách quyền truy cập vào ma trận
   của thiết bị AP

Dự trữ APQN để sử dụng độc quyền cho khách KVM
---------------------------------------------
Sơ đồ khối sau đây minh họa cơ chế mà APQN được sử dụng
dành riêng::

+-------------------+
		 7 loại bỏ ZZ0000ZZ
	   +--------------------> trình điều khiển cex4queue |
	   ZZ0001ZZ |
	   |                    +-------------------+
	   |
	   |
	   |                    +-------------------+ +----------------+
	   ZZ0002ZZ ZZ0003ZZ |
	   ZZ0004ZZ
	   ZZ0005ZZ ZZ0006ZZ ZZ0007ZZ
	   ZZ0008ZZ +--------^----------+ +----------------+
	   ZZ0009ZZ |
	   ZZ0010ZZ +-------------------+
	   ZZ0011ZZ +-----------------------------------+ |
	   ZZ0012ZZ ZZ0013ZZ | 2 thiết bị đăng ký
	   ZZ0014ZZ ZZ0015ZZ |
  +--------+---+-v---+ +--------+-------+-+
  ZZ0016ZZ ZZ0017ZZ
  ZZ0018ZZ
  ZZ0019ZZ 8 đầu dò ZZ0020ZZ
  +--------^----------+ +--^--^-------------+
  6 chỉnh sửa ZZ0021ZZ |
    apmask ZZ0022ZZ 11 mdev tạo
    aqmask ZZ0023ZZ 1 modprobe |
  +--------+------+---+ +----------------+-+ +----------------+
  ZZ0024ZZ ZZ0025ZZ10 tạo|     mediated   |
  ZZ0027ZZ ZZ0028ZZ-------> ma trận |
  Thiết bị ZZ0029ZZ ZZ0030ZZ |
  +------+-+----------+ +--------^--------------+ +--------------^-------+
	 ZZ0031ZZ ZZ0032ZZ
	 ZZ0033ZZ 9 tạo vfio_ap-passthrough ZZ0034ZZ
	 ZZ0035ZZ
	 +-------------------------------------------------------------------------- +
		     12 gán bộ điều hợp/miền/miền điều khiển

Quá trình đặt trước hàng đợi AP để khách KVM sử dụng là:

1. Quản trị viên tải driver thiết bị vfio_ap
2. Trình điều khiển vfio-ap trong quá trình khởi tạo sẽ đăng ký một 'ma trận' duy nhất
   thiết bị với lõi thiết bị. Đây sẽ đóng vai trò là thiết bị mẹ cho
   tất cả các thiết bị trung gian vfio_ap được sử dụng để định cấu hình ma trận AP cho khách.
3. Thiết bị /sys/devices/vfio_ap/matrix được tạo bởi lõi thiết bị
4. Trình điều khiển thiết bị vfio_ap sẽ đăng ký với bus AP cho các thiết bị xếp hàng AP
   thuộc loại 10 trở lên (CEX4 và mới hơn). Trình điều khiển sẽ cung cấp vfio_ap
   thăm dò của trình điều khiển và loại bỏ giao diện gọi lại. Các thiết bị cũ hơn hàng đợi CEX4
   không được hỗ trợ để đơn giản hóa việc thực hiện bằng cách không cần thiết
   làm phức tạp thiết kế bằng cách hỗ trợ các thiết bị cũ sẽ hết hạn sử dụng
   dịch vụ trong tương lai tương đối gần và có rất ít dịch vụ cũ hơn
   hệ thống xung quanh để kiểm tra.
5. Bus AP đăng ký trình điều khiển thiết bị vfio_ap với lõi thiết bị
6. Quản trị viên chỉnh sửa bộ điều hợp AP và mặt nạ hàng đợi để đặt trước hàng đợi AP
   để trình điều khiển thiết bị vfio_ap sử dụng.
7. Bus AP loại bỏ hàng đợi AP dành riêng cho trình điều khiển vfio_ap khỏi
   trình điều khiển zcrypt cex4queue mặc định.
8. Bus AP thăm dò trình điều khiển thiết bị vfio_ap để liên kết các hàng đợi dành riêng cho
   nó.
9. Quản trị viên tạo một thiết bị qua trung gian loại vfio_ap để
   được khách sử dụng
10. Quản trị viên chỉ định các bộ điều hợp, miền sử dụng và miền điều khiển
    để được sử dụng độc quyền bởi một khách.

Thiết lập giao diện thiết bị qua trung gian VFIO
------------------------------------------
Trình điều khiển thiết bị AP VFIO sử dụng các giao diện chung của trung gian VFIO
trình điều khiển lõi thiết bị để:

* Đăng ký trình điều khiển xe buýt qua trung gian AP để thêm thiết bị qua trung gian vfio_ap vào và
  xóa nó khỏi nhóm VFIO.
* Tạo và hủy thiết bị qua trung gian vfio_ap
* Thêm thiết bị qua trung gian vfio_ap vào và xóa thiết bị đó khỏi trình điều khiển xe buýt qua trung gian AP
* Thêm thiết bị qua trung gian vfio_ap vào và xóa thiết bị đó khỏi nhóm IOMMU

Sơ đồ khối cấp cao sau đây thể hiện các thành phần và giao diện chính
của trình điều khiển thiết bị qua trung gian AP VFIO::

+-------------+
   ZZ0000ZZ
   ZZ0001ZZ mdev_register_driver() +--------------+
   ZZ0002ZZ Mdev ZZ0003ZZ
   Xe buýt ZZ0004ZZ ZZ0005ZZ ZZ0006ZZ
   Trình điều khiển ZZ0007ZZ ZZ0008ZZ<-> Người dùng VFIO
   ZZ0009ZZ thăm dò()/remove() +--------------+ API
   ZZ0010ZZ
   ZZ0011ZZ
   ZZ0012ZZ
   ZZ0013ZZ
   ZZ0014ZZ mdev_register_parent() +--------------+
   | |Vật lý ZZ0016ZZ
   Thiết bị ZZ0017ZZ ZZ0018ZZ ZZ0019ZZ<-> ma trận
   Thiết bị | |interface| +----------------------->+              |
   Gọi lại ZZ0022ZZ +--------------+
   +-------------+

Trong quá trình khởi tạo mô-đun vfio_ap, thiết bị ma trận được đăng ký
với cấu trúc 'mdev_parent_ops' cung cấp thuộc tính sysfs
cấu trúc, hàm mdev và giao diện gọi lại để quản lý môi trường trung gian
thiết bị ma trận.

* Cấu trúc thuộc tính sysfs:

được hỗ trợ_type_groups
    Khung thiết bị trung gian VFIO hỗ trợ tạo các ứng dụng do người dùng xác định
    các loại thiết bị trung gian. Các loại thiết bị trung gian này được chỉ định
    thông qua cấu trúc 'supported_type_groups' khi thiết bị được đăng ký
    với khung thiết bị trung gian. Quá trình đăng ký tạo ra
    cấu trúc sysfs cho từng loại thiết bị trung gian được chỉ định trong
    thư mục con 'mdev_supported_types' của thiết bị đang được đăng ký. Cùng
    với loại thiết bị, thuộc tính sysfs của loại thiết bị được trung gian là
    được cung cấp.

Trình điều khiển thiết bị AP VFIO sẽ đăng ký một loại thiết bị trung gian cho
    thiết bị thông qua:

/sys/devices/vfio_ap/matrix/mdev_supported_types/vfio_ap-passthrough

Chỉ các thuộc tính chỉ đọc được yêu cầu bởi khung mdev VFIO mới
    được cung cấp::

	... name
	... device_api
	... available_instances
	... device_api

    Where:

*tên:
	    chỉ định tên của loại thiết bị trung gian
	* thiết bị_api:
	    loại thiết bị trung gian là API
	* có sẵn_instance:
	    số lượng thiết bị chuyển tiếp qua trung gian vfio_ap
	    cái đó có thể được tạo ra
	* thiết bị_api:
	    chỉ định VFIO API
  mdev_attr_groups
    Nhóm thuộc tính này xác định các thuộc tính sysfs do người dùng định nghĩa của
    thiết bị trung gian. Khi một thiết bị được đăng ký với thiết bị trung gian VFIO
    framework, các tệp thuộc tính sysfs được xác định trong 'mdev_attr_groups'
    cấu trúc sẽ được tạo trong thư mục của thiết bị qua trung gian vfio_ap. các
    Các thuộc tính sysfs cho thiết bị qua trung gian vfio_ap là:

gán_adapter/bỏ gán_adapter:
      Thuộc tính chỉ ghi để gán/bỏ gán bộ chuyển đổi AP tới/từ
      thiết bị trung gian vfio_ap. Để gán/bỏ gán bộ chuyển đổi, APID của
      adapter được lặp lại vào tệp thuộc tính tương ứng.
    gán_domain/bỏ gán_domain:
      Thuộc tính chỉ ghi để gán/bỏ gán miền sử dụng AP cho/từ
      thiết bị trung gian vfio_ap. Để gán/bỏ gán một tên miền, tên miền
      số miền sử dụng được lặp lại vào thuộc tính tương ứng
      tập tin.
    ma trận:
      Tệp chỉ đọc để hiển thị APQN có nguồn gốc từ Descartes
      sản phẩm của bộ chuyển đổi và số miền được gán cho vfio_ap qua trung gian
      thiết bị.
    khách_matrix:
      Tệp chỉ đọc để hiển thị APQN có nguồn gốc từ Descartes
      sản phẩm của bộ điều hợp và số miền được gán cho APM và AQM
      các trường tương ứng của CRYCB của khách KVM. Điều này có thể khác với
      các APQN được gán cho thiết bị trung gian vfio_ap nếu có APQN nào không
      tham chiếu một thiết bị xếp hàng được liên kết với trình điều khiển thiết bị vfio_ap (tức là
      hàng đợi không có trong cấu hình AP của máy chủ).
    gán_control_domain/unsign_control_domain:
      Thuộc tính chỉ ghi để gán/bỏ gán miền kiểm soát AP
      đến/từ thiết bị trung gian vfio_ap. Để gán/bỏ gán miền kiểm soát,
      ID của miền được gán/bỏ gán sẽ được phản hồi vào
      tập tin thuộc tính tương ứng.
    control_domain:
      Một tệp chỉ đọc để hiển thị số miền điều khiển được gán cho
      thiết bị trung gian vfio_ap.
    ap_config:
      Một tập tin đọc/ghi mà khi được ghi vào sẽ cho phép cả ba
      Mặt nạ ma trận ap của thiết bị qua trung gian vfio_ap sẽ được thay thế trong một lần chụp.
      Ba mặt nạ được cung cấp, một cho bộ điều hợp, một cho miền và một cho
      các miền kiểm soát. Nếu trạng thái đã cho không thể được đặt thì không có thay đổi nào được thực hiện
      được thực hiện cho thiết bị qua trung gian vfio-ap.

Định dạng của dữ liệu được ghi vào ap_config như sau:
      {amask},{dmask},{cmask}\n

\n là một ký tự dòng mới.

amask, dmask và cmas là các mặt nạ xác định bộ điều hợp, miền,
      và miền điều khiển phải được gán cho thiết bị trung gian.

Cấu trúc của mặt nạ như sau:
      0xNN..NN

Trong đó NN..NN là 64 ký tự thập lục phân biểu thị giá trị 256 bit.
      Bit ngoài cùng bên trái (thứ tự cao nhất) đại diện cho bộ điều hợp/miền 0.

Để biết một bộ mặt nạ mẫu đại diện cho mdev hiện tại của bạn
      cấu hình, chỉ cần cat ap_config.

Đặt bộ điều hợp hoặc số miền lớn hơn mức tối đa được phép cho
      hệ thống sẽ gây ra lỗi.

Thuộc tính này được dự định sẽ được sử dụng bởi tự động hóa. Người dùng cuối sẽ là
      phục vụ tốt hơn bằng cách sử dụng các thuộc tính gán/bỏ gán tương ứng cho
      bộ điều hợp, miền và miền điều khiển.

*chức năng:

tạo:
    phân bổ cấu trúc ap_matrix_mdev được trình điều khiển vfio_ap sử dụng cho:

* Lưu trữ tham chiếu đến cấu trúc KVM cho khách bằng mdev
    * Lưu trữ cấu hình ma trận AP cho bộ điều hợp, miền và điều khiển
      tên miền được chỉ định thông qua các tệp thuộc tính sysfs tương ứng
    * Lưu trữ cấu hình ma trận AP cho bộ điều hợp, miền và điều khiển
      tên miền có sẵn cho khách. Khách có thể không được cấp quyền truy cập vào APQN
      tham chiếu các thiết bị hàng đợi không tồn tại hoặc không bị ràng buộc với
      Trình điều khiển thiết bị vfio_ap.

xóa:
    hủy phân bổ cấu trúc ap_matrix_mdev của thiết bị qua trung gian vfio_ap.
    Điều này sẽ chỉ được phép nếu khách đang chạy không sử dụng mdev.

* giao diện gọi lại

open_device:
    lệnh gọi lại open_device được gọi bởi không gian người dùng để kết nối
    Nhóm iommu VFIO dành cho thiết bị mdev ma trận tới bus MDEV.  các
    gọi lại truy xuất cấu trúc KVM được sử dụng để định cấu hình máy khách KVM
    và định cấu hình quyền truy cập của khách vào ma trận AP được xác định thông qua
    Tệp thuộc tính sysfs của thiết bị qua trung gian vfio_ap.

close_device:
    cuộc gọi lại này giải cấu hình ma trận AP của khách.

ioctl:
    cuộc gọi lại này xử lý ioctls VFIO_DEVICE_GET_INFO và VFIO_DEVICE_RESET
    được xác định bởi khung vfio.

Định cấu hình tài nguyên AP của khách
----------------------------------
Việc định cấu hình tài nguyên AP cho máy khách KVM sẽ được thực hiện tại
thời gian của ZZ0000ZZ và ZZ0001ZZ. Tài nguyên AP của khách là
được cấu hình thông qua APCB của nó bằng cách:

* Đặt các bit trong APM tương ứng với các APID được gán cho
  thiết bị trung gian vfio_ap thông qua giao diện 'sign_adapter' của nó.
* Đặt các bit trong AQM tương ứng với các miền được gán cho
  thiết bị trung gian vfio_ap thông qua giao diện 'sign_domain' của nó.
* Thiết lập các bit trong ADM tương ứng với các dID miền được gán cho
  thiết bị trung gian vfio_ap thông qua giao diện 'sign_control_domains' của nó.

Kiểu thiết bị linux ngăn cản việc chuyển thiết bị tới máy khách KVM
không bị ràng buộc với trình điều khiển thiết bị tạo điều kiện cho nó đi qua. Do đó,
APQN không tham chiếu thiết bị xếp hàng được liên kết với thiết bị vfio_ap
trình điều khiển sẽ không được gán cho ma trận khách KVM. Kiến trúc AP
tuy nhiên, không cung cấp phương tiện để lọc các APQN riêng lẻ từ khách
ma trận, do đó các bộ điều hợp, miền và miền điều khiển được gán cho vfio_ap
thiết bị được trung gian thông qua sysfs 'gán_adapter', 'gán_domain' và
Giao diện 'sign_control_domain' sẽ được lọc trước khi cung cấp AP
cấu hình cho khách:

* APID của bộ điều hợp, APQI của tên miền và số tên miền của
  các miền điều khiển được gán cho ma trận mdev mà cũng không được gán cho
  cấu hình AP của máy chủ sẽ được lọc.

* Mỗi APQN có nguồn gốc từ tích Descartes của APID và APQI được chỉ định
  vào vfio_ap mdev sẽ được kiểm tra và nếu bất kỳ một trong số chúng không tham chiếu đến
  thiết bị xếp hàng được liên kết với trình điều khiển thiết bị vfio_ap, bộ chuyển đổi sẽ không được
  được cắm vào máy khách (tức là bit tương ứng với APID của nó sẽ không được
  được đặt trong APM của APCB của khách).

Các tính năng của mẫu CPU dành cho AP
-----------------------------
Ngăn xếp AP dựa vào sự hiện diện của các lệnh AP cũng như ba
cơ sở vật chất: Cơ sở Kiểm tra Cơ sở vật chất AP (APFT); truy vấn AP
Cơ sở thông tin cấu hình (QCI); và Kiểm soát gián đoạn hàng đợi AP
cơ sở vật chất. Những tính năng/tiện ích này được cung cấp cho khách KVM thông qua
các tính năng của mẫu CPU sau:

1. ap: Cho biết liệu các hướng dẫn AP có được cài đặt trên máy khách hay không. Cái này
   tính năng sẽ chỉ được kích hoạt bởi KVM nếu hướng dẫn AP được cài đặt
   trên máy chủ.

2. apft: Cho biết tiện ích APFT có sẵn cho khách. Cơ sở này
   chỉ có thể được cung cấp cho khách nếu nó có sẵn trên máy chủ (tức là
   bit cơ sở 15 được thiết lập).

3. apqci: ​​Cho biết tiện ích AP QCI có sẵn trên máy khách. Cơ sở này
   chỉ có thể được cung cấp cho khách nếu nó có sẵn trên máy chủ (tức là
   bit cơ sở 12 được thiết lập).

4. apqi: Cho biết thiết bị Kiểm soát gián đoạn hàng đợi AP có sẵn trên
   khách. Cơ sở này chỉ có thể được cung cấp cho khách nếu nó được
   có sẵn trên máy chủ (tức là bit cơ sở 65 được đặt).

Lưu ý: Nếu người dùng chọn chỉ định kiểu máy CPU khác với 'máy chủ'
mô hình sang QEMU, các tính năng và tiện ích của mô hình CPU cần được bật
rõ ràng; Ví dụ::

/usr/bin/qemu-system-s390x ... -cpu z13,ap=on,apqci=on,apft=on,apqi=on

Khách có thể bị ngăn không cho sử dụng các tính năng/tiện ích AP bằng cách tắt chúng đi
rõ ràng; Ví dụ::

/usr/bin/qemu-system-s390x ... -cpu máy chủ,ap=off,apqci=off,apft=off,apqi=off

Lưu ý: Nếu tiện ích APFT bị tắt (apft=off) đối với khách, khách sẽ
sẽ không thấy bất kỳ thiết bị AP nào. Trình điều khiển thiết bị zcrypt trên máy khách
đăng ký các thiết bị AP loại 10 và mới hơn - tức là cex4card và cex4queue
trình điều khiển thiết bị - cần tiện ích APFT để xác định các tiện ích được cài đặt trên
một thiết bị AP nhất định. Nếu tiện ích APFT không được cài đặt trên máy khách thì không
bộ điều hợp hoặc thiết bị miền sẽ được tạo bởi bus AP chạy trên
khách vì chỉ có thể định cấu hình các thiết bị loại 10 và mới hơn để khách sử dụng.

Ví dụ
=======
Bây giờ chúng ta hãy cung cấp một ví dụ để minh họa cách có thể cung cấp khách KVM
truy cập vào các cơ sở AP. Đối với ví dụ này, chúng tôi sẽ chỉ ra cách cấu hình
ba khách sao cho việc thực thi lệnh lszcrypt trên khách sẽ
trông như thế này:

Khách1
------
=========== ==================
CARD.DOMAIN TYPE MODE
=========== ==================
05 CEX5C CCA-Coproc
05.0004 CEX5C CCA-Coproc
05.00ab CEX5C CCA-Coproc
06 Máy gia tốc CEX5A
Máy gia tốc 06.0004 CEX5A
Máy gia tốc 06.00ab CEX5A
=========== ==================

khách2
------
=========== ==================
CARD.DOMAIN TYPE MODE
=========== ==================
05 CEX5C CCA-Coproc
05.0047 CEX5C CCA-Coproc
05.00ff CEX5C CCA-Coproc
=========== ==================

Khách3
------
=========== ==================
CARD.DOMAIN TYPE MODE
=========== ==================
06 Máy gia tốc CEX5A
Máy gia tốc 06.0047 CEX5A
06.00ff Máy gia tốc CEX5A
=========== ==================

Đây là các bước:

1. Cài đặt mô-đun vfio_ap trên máy chủ linux. Chuỗi phụ thuộc của
   mô-đun vfio_ap là:
   * ôi trời
   * s390
   * mã hóa
   * vfio
   * vfio_mdev
   * vfio_mdev_device
   * KVM

Để xây dựng mô-đun vfio_ap, bản dựng kernel phải được cấu hình bằng
   các phần tử Kconfig sau được chọn:
   * IOMMU_SUPPORT
   * S390
   * AP
   * VFIO
   * KVM

Nếu sử dụng make menuconfig, hãy chọn mục sau để xây dựng mô-đun vfio_ap ::

-> Trình điều khiển thiết bị
	-> Hỗ trợ phần cứng IOMMU
	   chọn S390 AP IOMMU Hỗ trợ
	-> Khung trình điều khiển không gian người dùng không có đặc quyền VFIO
	   -> Khung trình điều khiển thiết bị qua trung gian
	      -> Trình điều khiển VFIO cho các thiết bị Mediad
     -> Hệ thống con I/O
	-> VFIO hỗ trợ cho các thiết bị AP

2. Đảm bảo hàng đợi AP được ba khách sử dụng để chủ nhà không thể
   truy cập chúng. Để bảo mật chúng, có hai tệp sysfs chỉ định
   mặt nạ bit đánh dấu một tập hợp con của phạm vi APQN là chỉ có AP mặc định mới có thể sử dụng được
   trình điều khiển thiết bị xếp hàng. Tất cả các APQN còn lại đều có sẵn để sử dụng bởi
   bất kỳ trình điều khiển thiết bị nào khác. Trình điều khiển thiết bị vfio_ap hiện là trình điều khiển duy nhất
   trình điều khiển thiết bị không mặc định. Vị trí của các tập tin sysfs chứa
   mặt nạ là::

/sys/bus/ap/apmask
     /sys/bus/ap/aqmask

'apmask' là mặt nạ 256 bit xác định một bộ ID bộ điều hợp AP
   (APID). Mỗi bit trong mặt nạ, từ trái sang phải, tương ứng với APID từ
   0-255. Nếu một bit được đặt, APID thuộc tập hợp con của APQN được đánh dấu là
   chỉ khả dụng cho trình điều khiển thiết bị hàng đợi AP mặc định.

'aqmask' là mặt nạ 256 bit xác định một tập hợp các chỉ mục hàng đợi AP
   (APQI). Mỗi bit trong mặt nạ, từ trái sang phải, tương ứng với APQI từ
   0-255. Nếu một bit được đặt, APQI thuộc tập hợp con của APQN được đánh dấu là
   chỉ khả dụng cho trình điều khiển thiết bị hàng đợi AP mặc định.

Tích Descartes của các APID tương ứng với các bit được đặt trong
   apmask và APQI tương ứng với các bit được đặt trong aqmask bao gồm
   tập hợp con của APQN chỉ có thể được sử dụng bởi trình điều khiển thiết bị mặc định của máy chủ.
   Tất cả các APQN khác đều có sẵn cho các trình điều khiển thiết bị không mặc định như
   trình điều khiển vfio_ap.

Lấy ví dụ, các mặt nạ sau::

apmask:
      0x7d00000000000000000000000000000000000000000000000000000000000000000000

aqmask:
      0x800000000000000000000000000000000000000000000000000000000000000000000

Các mặt nạ chỉ ra:

* Bộ điều hợp 1, 2, 3, 4, 5 và 7 có sẵn để sử dụng theo mặc định của máy chủ
     trình điều khiển thiết bị.

* Miền 0 có sẵn để trình điều khiển thiết bị mặc định của máy chủ sử dụng

* Tập hợp con của APQN chỉ có sẵn để sử dụng bởi thiết bị chủ mặc định
     trình điều khiển là:

(1.0), (2.0), (3.0), (4.0), (5.0) và (7.0)

* Tất cả các APQN khác đều có sẵn để sử dụng bởi trình điều khiển thiết bị không mặc định.

APQN của mỗi thiết bị hàng đợi AP được gán cho máy chủ linux được kiểm tra bởi
   Bus AP so với tập hợp APQN có nguồn gốc từ tích Descartes của APID
   và APQI được đánh dấu là có sẵn cho trình điều khiển thiết bị hàng đợi AP mặc định. Nếu một
   được phát hiện khớp, chỉ các trình điều khiển thiết bị hàng đợi AP mặc định sẽ được thăm dò;
   nếu không, trình điều khiển thiết bị vfio_ap sẽ bị thăm dò.

Theo mặc định, hai mặt nạ được đặt để dự trữ tất cả APQN để sử dụng theo mặc định
   Trình điều khiển thiết bị xếp hàng AP. Có hai cách có thể thay đổi mặt nạ mặc định:

1. Các tập tin mặt nạ sysfs có thể được chỉnh sửa bằng cách lặp lại một chuỗi vào
      tệp mặt nạ sysfs tương ứng ở một trong hai định dạng:

* Chuỗi hex tuyệt đối bắt đầu bằng 0x - như "0x12345678" - bộ
	mặt nạ. Nếu chuỗi đã cho ngắn hơn mặt nạ, nó sẽ được đệm
	với số 0 ở bên phải; ví dụ: chỉ định giá trị mặt nạ là 0x41 là
	giống như việc chỉ định::

0x410000000000000000000000000000000000000000000000000000000000000000000

Hãy nhớ rằng mặt nạ đọc từ trái sang phải, vì vậy mặt nạ
	ở trên xác định số thiết bị 1 và 7 (01000001).

Nếu chuỗi dài hơn mặt nạ, thao tác sẽ kết thúc bằng
	một lỗi (EINVAL).

* Các bit riêng lẻ trong mặt nạ có thể được bật và tắt bằng cách chỉ định
	mỗi số bit được chuyển đổi trong một danh sách được phân tách bằng dấu phẩy. Mỗi bit
	chuỗi số phải được thêm vào trước dấu ('+') hoặc dấu trừ ('-') để biểu thị
	bit tương ứng sẽ được bật ('+') hoặc tắt ('-'). Một số
	các giá trị hợp lệ là:

- "+0" bật bit 0
	   - "-13" tắt bit 13
	   - "+0x41" bật bit 65
	   - "-0xff" tắt bit 255

Ví dụ sau:

+0,-6,+0x47,-0xf0

Bật bit 0 và 71 (0x47)

Tắt bit 6 và 240 (0xf0)

Lưu ý rằng các bit không được chỉ định trong danh sách vẫn như cũ
	hoạt động.

2. Các mặt nạ cũng có thể được thay đổi khi khởi động thông qua các tham số trên kernel
      dòng lệnh như thế này:

ap.apmask=0xffff ap.aqmask=0x40

Điều này sẽ tạo ra các mặt nạ sau::

apmask:
	    0xffff00000000000000000000000000000000000000000000000000000000000000000

aqmask:
	    0x400000000000000000000000000000000000000000000000000000000000000000000

Kết quả là hai nhóm này ::

Nhóm trình điều khiển mặc định: bộ chuyển đổi 0-15, miền 1
	    Nhóm trình điều khiển thay thế: bộ chuyển đổi 16-255, tên miền 0, 2-255

ZZ0000ZZ
   Thay đổi mặt nạ sao cho một hoặc nhiều APQN sẽ được lấy từ vfio_ap
   thiết bị trung gian (xem bên dưới) sẽ bị lỗi với lỗi (EBUSY). Một tin nhắn
   được ghi vào bộ đệm vòng kernel có thể được xem bằng 'dmesg'
   lệnh. Đầu ra xác định từng APQN được gắn cờ là 'đang sử dụng' và xác định
   thiết bị trung gian vfio_ap được gán; Ví dụ:

Không gian người dùng không thể chỉ định lại hàng đợi 05.0054 đã được chỉ định cho 62177883-f1bb-47f0-914d-32a22e3a8804
   Không gian người dùng không được chỉ định lại hàng đợi 04.0054 đã được chỉ định cho cef03c3c-903d-4ecc-9a83-40694cb8aee4

Bảo mật APQN cho ví dụ của chúng tôi
----------------------------------
Để bảo mật hàng đợi AP 05.0004, 05.0047, 05.00ab, 05.00ff, 06.0004, 06.0047,
   06.00ab và 06.00ff để trình điều khiển thiết bị vfio_ap sử dụng, tương ứng
   APQN có thể được xóa khỏi mặt nạ mặc định bằng một trong các cách sau
   lệnh::

echo -5,-6 > /sys/bus/ap/apmask

echo -4,-0x47,-0xab,-0xff > /sys/bus/ap/aqmask

Hoặc các mặt nạ có thể được đặt như sau::

echo 0xf9ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff \
      > mặt nạ

echo 0xf7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe \
      > mặt nạ aq

Điều này sẽ dẫn đến hàng đợi AP 05.0004, 05.0047, 05.00ab, 05.00ff, 06.0004,
   06.0047, 06.00ab và 06.00ff bị ràng buộc với trình điều khiển thiết bị vfio_ap. các
   Thư mục sysfs cho trình điều khiển thiết bị vfio_ap giờ đây sẽ chứa các liên kết tượng trưng
   tới các thiết bị xếp hàng AP được liên kết với nó::

/sys/bus/ap
     ... [drivers]
     ...... [vfio_ap]
     ......... [05.0004]
     ......... [05.0047]
     ......... [05.00ab]
     ......... [05.00ff]
     ......... [06.0004]
     ......... [06.0047]
     ......... [06.00ab]
     ......... [06.00ff]

Hãy nhớ rằng chỉ các bộ điều hợp loại 10 và mới hơn (tức là CEX4 trở lên)
   có thể được liên kết với trình điều khiển thiết bị vfio_ap. Lý do cho việc này là để
   đơn giản hóa việc thực hiện bằng cách không làm phức tạp thiết kế một cách không cần thiết bằng cách
   hỗ trợ các thiết bị cũ hơn sẽ ngừng hoạt động trong thời gian tương đối gần
   tương lai và có rất ít hệ thống cũ hơn để thử nghiệm.

Do đó, quản trị viên phải chú ý chỉ bảo mật các hàng đợi AP
   có thể được liên kết với trình điều khiển thiết bị vfio_ap. Loại thiết bị cho một AP nhất định
   thiết bị xếp hàng có thể được đọc từ thư mục sysfs của thẻ gốc. Ví dụ,
   để xem loại phần cứng của hàng đợi 05.0004:

mèo /sys/bus/ap/devices/card05/hwtype

Loại hwtype phải từ 10 trở lên (CEX4 hoặc mới hơn) để được liên kết với
   Trình điều khiển thiết bị vfio_ap.

3. Tạo các thiết bị trung gian cần thiết để cấu hình ma trận AP cho
   ba khách và cung cấp giao diện cho trình điều khiển vfio_ap cho
   khách hàng sử dụng::

/sys/thiết bị/vfio_ap/ma trận/
     --- [mdev_supported_types]
     ------ [vfio_ap-passthrough] (loại thiết bị trung gian passthrough vfio_ap)
     --------- tạo
     --------- [thiết bị]

Để tạo thiết bị trung gian cho ba khách::

uuidgen > tạo
	uuidgen > tạo
	uuidgen > tạo

hoặc

echo $uuid1 > tạo
	echo $uuid2 > tạo
	echo $uuid3 > tạo

Điều này sẽ tạo ba thiết bị trung gian trong thư mục con [devices] có tên
   sau khi UUID được ghi vào tệp thuộc tính tạo. Chúng tôi gọi chúng là $uuid1,
   $uuid2 và $uuid3 và đây là cấu trúc thư mục sysfs sau khi tạo::

/sys/thiết bị/vfio_ap/ma trận/
     --- [mdev_supported_types]
     ------ [vfio_ap-passthrough]
     --------- [thiết bị]
     ------------ [$uuid1]
     --------------- gán_adapter
     --------------- gán_control_domain
     --------------- gán_domain
     --------------- ma trận
     --------------- bỏ gán_adapter
     --------------- bỏ gán_control_domain
     --------------- bỏ gán_domain

------------ [$uuid2]
     --------------- gán_adapter
     --------------- gán_control_domain
     --------------- gán_domain
     --------------- ma trận
     --------------- bỏ gán_adapter
     ----------------bỏ gán_control_domain
     ----------------bỏ gán_domain

------------ [$uuid3]
     --------------- gán_adapter
     --------------- gán_control_domain
     --------------- gán_domain
     --------------- ma trận
     --------------- bỏ gán_adapter
     ----------------bỏ gán_control_domain
     ----------------bỏ gán_domain

Lưu ý *****: Các mdev vfio_ap không tồn tại trong suốt quá trình khởi động lại trừ khi
               Công cụ mdevctl được sử dụng để tạo và lưu giữ chúng.

4. Bây giờ quản trị viên cần định cấu hình ma trận cho trung gian
   thiết bị $uuid1 (dành cho Guest1), $uuid2 (dành cho Guest2) và $uuid3 (dành cho Guest3).

Đây là cách ma trận được định cấu hình cho Guest1::

echo 5 > gán_adapter
      echo 6 > gán_adapter
      echo 4 > gán_domain
      echo 0xab > gán_domain

Các miền kiểm soát có thể được chỉ định tương tự bằng cách sử dụng transfer_control_domain
   tập tin sysfs.

Nếu xảy ra lỗi khi định cấu hình bộ điều hợp, miền hoặc miền điều khiển,
   bạn có thể sử dụng các tệp unsign_xxx để bỏ gán bộ điều hợp, tên miền hoặc
   miền điều khiển.

Để hiển thị cấu hình ma trận cho Guest1::

ma trận mèo

Để hiển thị ma trận đã hoặc sẽ được gán cho Guest1::

mèo khách_matrix

Đây là cách ma trận được cấu hình cho Guest2::

echo 5 > gán_adapter
      echo 0x47 > gán_domain
      echo 0xff > gán_domain

Đây là cách cấu hình ma trận cho Guest3::

echo 6 > gán_adapter
      echo 0x47 > gán_domain
      echo 0xff > gán_domain

Để gán thành công bộ chuyển đổi:

* Số bộ điều hợp được chỉ định phải đại diện cho một giá trị từ 0 đến
     số bộ điều hợp tối đa được cấu hình cho hệ thống. Nếu số bộ chuyển đổi
     cao hơn mức tối đa được chỉ định, hoạt động sẽ kết thúc với
     một lỗi (ENODEV).

Lưu ý: Có thể lấy số bộ điều hợp tối đa thông qua sysfs
	   Tệp thuộc tính /sys/bus/ap/ap_max_adapter_id.

* Mỗi APQN có nguồn gốc từ tích Descartes của APID của bộ chuyển đổi
     đang được chỉ định và APQI của các miền được chỉ định trước đó:

- Chỉ có sẵn cho trình điều khiển thiết bị vfio_ap như được chỉ định trong
       sysfs /sys/bus/ap/apmask và các tệp thuộc tính /sys/bus/ap/aqmask. Nếu thậm chí
       một APQN được dành riêng cho trình điều khiển thiết bị chủ sử dụng, hoạt động
       sẽ kết thúc với một lỗi (EADDRNOTAVAIL).

- Phải gán NOT cho một thiết bị trung gian vfio_ap khác. Nếu thậm chí một APQN
       được gán cho một thiết bị trung gian vfio_ap khác, thao tác sẽ
       chấm dứt với một lỗi (EBUSY).

- Phải gán NOT trong khi sysfs /sys/bus/ap/apmask và
       Các tệp thuộc tính sys/bus/ap/aqmask đang được chỉnh sửa hoặc thao tác có thể
       chấm dứt với một lỗi (EBUSY).

Để gán tên miền thành công:

* Số miền được chỉ định phải đại diện cho một giá trị từ 0 đến
     số miền tối đa được cấu hình cho hệ thống. Nếu số miền
     cao hơn mức tối đa được chỉ định, hoạt động sẽ kết thúc với
     một lỗi (ENODEV).

Lưu ý: Số miền tối đa có thể lấy được thông qua sysfs
	   /sys/bus/ap/ap_max_domain_id tệp thuộc tính.

* Mỗi APQN bắt nguồn từ tích Descartes của APQI của miền
      được chỉ định và APID của bộ điều hợp được chỉ định trước đó:

- Chỉ có sẵn cho trình điều khiển thiết bị vfio_ap như được chỉ định trong
       sysfs /sys/bus/ap/apmask và các tệp thuộc tính /sys/bus/ap/aqmask. Nếu thậm chí
       một APQN được dành riêng cho trình điều khiển thiết bị chủ sử dụng, hoạt động
       sẽ kết thúc với một lỗi (EADDRNOTAVAIL).

- Phải gán NOT cho một thiết bị trung gian vfio_ap khác. Nếu thậm chí một APQN
       được gán cho một thiết bị trung gian vfio_ap khác, thao tác sẽ
       chấm dứt với một lỗi (EBUSY).

- Phải gán NOT trong khi sysfs /sys/bus/ap/apmask và
       Các tệp thuộc tính sys/bus/ap/aqmask đang được chỉnh sửa hoặc thao tác có thể
       chấm dứt với một lỗi (EBUSY).

Để gán thành công miền điều khiển:

* Số miền được chỉ định phải đại diện cho giá trị từ 0 đến tối đa
     số miền được cấu hình cho hệ thống. Nếu số miền kiểm soát cao hơn
     hơn mức tối đa được chỉ định, hoạt động sẽ kết thúc với
     lỗi (ENODEV).

5. Bắt đầu Guest1::

/usr/bin/qemu-system-s390x ... -cpu Host,ap=on,apqci=on,apft=on,apqi=on \
	-device vfio-ap,sysfsdev=/sys/devices/vfio_ap/matrix/$uuid1 ...

7. Bắt đầu Guest2::

/usr/bin/qemu-system-s390x ... -cpu Host,ap=on,apqci=on,apft=on,apqi=on \
	-device vfio-ap,sysfsdev=/sys/devices/vfio_ap/matrix/$uuid2 ...

7. Khởi động Guest3::

/usr/bin/qemu-system-s390x ... -cpu Host,ap=on,apqci=on,apft=on,apqi=on \
	-device vfio-ap,sysfsdev=/sys/devices/vfio_ap/matrix/$uuid3 ...

Khi khách tắt, các thiết bị qua trung gian vfio_ap có thể bị xóa.

Sử dụng lại ví dụ của chúng tôi để xóa thiết bị trung gian vfio_ap $uuid1::

/sys/thiết bị/vfio_ap/ma trận/
      --- [mdev_supported_types]
      ------ [vfio_ap-passthrough]
      --------- [thiết bị]
      ------------ [$uuid1]
      --------------- gỡ bỏ

::

tiếng vang 1 > loại bỏ

Điều này sẽ loại bỏ tất cả các cấu trúc sysfs của thiết bị ma trận mdev bao gồm
chính thiết bị mdev. Để tạo lại và cấu hình lại thiết bị ma trận mdev,
tất cả các bước bắt đầu từ bước 3 sẽ phải được thực hiện lại. Lưu ý
rằng việc xóa sẽ không thành công nếu khách sử dụng vfio_ap mdev vẫn đang chạy.

Không cần thiết phải xóa vfio_ap mdev, nhưng người ta có thể muốn
xóa nó nếu không có khách nào sử dụng nó trong suốt thời gian còn lại của linux
chủ nhà. Nếu vfio_ap mdev bị xóa, người ta cũng có thể muốn cấu hình lại
nhóm bộ điều hợp và hàng đợi dành riêng cho trình điều khiển mặc định sử dụng.

Hỗ trợ cắm/rút phích cắm nóng:
========================
Bộ điều hợp, miền hoặc miền điều khiển có thể được cắm nóng vào KVM đang chạy
khách bằng cách gán nó cho thiết bị trung gian vfio_ap đang được khách sử dụng nếu
các điều kiện sau đây được đáp ứng:

* Bộ điều hợp, miền hoặc miền điều khiển cũng phải được gán cho máy chủ
  Cấu hình AP.

* Mỗi APQN có nguồn gốc từ tích Descartes bao gồm APID của
  bộ điều hợp đang được chỉ định và APQI của miền được chỉ định phải tham chiếu một
  thiết bị xếp hàng được liên kết với trình điều khiển thiết bị vfio_ap.

* Để cắm nóng một miền, mỗi APQN có nguồn gốc từ sản phẩm Descartes
  bao gồm APQI của miền được chỉ định và các APID của
  bộ điều hợp được chỉ định phải tham chiếu một thiết bị xếp hàng được liên kết với thiết bị vfio_ap
  người lái xe.

Bộ điều hợp, miền hoặc miền điều khiển có thể bị rút phích cắm nóng khỏi KVM đang chạy
khách bằng cách bỏ gán nó khỏi thiết bị trung gian vfio_ap đang được sử dụng bởi
khách.

Cung cấp quá nhiều hàng đợi AP cho khách KVM:
===============================================
Việc cung cấp quá mức ở đây được định nghĩa là việc gán các bộ điều hợp hoặc miền cho
thiết bị trung gian vfio_ap không tham chiếu các thiết bị AP trong AP của máy chủ
cấu hình. Ý tưởng ở đây là khi bộ điều hợp hoặc miền trở thành
sẵn có, nó sẽ tự động được cắm nóng vào máy khách KVM bằng cách sử dụng
thiết bị trung gian vfio_ap mà nó được chỉ định miễn là mỗi APQN mới
kết quả từ việc cắm nó vào tham chiếu một thiết bị xếp hàng được liên kết với vfio_ap
trình điều khiển thiết bị.

Tính năng trình điều khiển
===============
Trình điều khiển vfio_ap hiển thị tệp sysfs chứa các tính năng được hỗ trợ.
Điều này tồn tại nên các công cụ của bên thứ ba (như Libvirt và mdevctl) có thể truy vấn
sự sẵn có của các tính năng cụ thể.

Danh sách tính năng có thể được tìm thấy ở đây: /sys/bus/matrix/devices/matrix/features

Các mục được phân cách bằng dấu cách. Mỗi mục bao gồm sự kết hợp của
ký tự chữ và số và dấu gạch dưới.

Ví dụ:
mèo /sys/bus/ma trận/thiết bị/ma trận/tính năng
guest_matrix dyn ap_config

các tính năng sau đây được quảng cáo:

---------------+----------------------------------------------------------------------- +
ZZ0000ZZ Mô tả |
+==============================================================================================================================
ZZ0001ZZ thuộc tính guest_matrix tồn tại. Nó báo cáo ma trận của |
Bộ điều hợp và miền ZZ0002ZZ đang hoặc sẽ được chuyển qua |
ZZ0003ZZ khách khi mdev được gắn vào nó.                        |
+--------------+-------------------------------------------------------------- +
ZZ0004ZZ Cho biết phích cắm/rút phích cắm nóng của bộ điều hợp AP, miền và điều khiển |
Miền ZZ0005ZZ dành cho khách có gắn mdev.            |
+-------------+-----------------------------------------------------------------+
Giao diện ZZ0006ZZ ap_config để sửa đổi một lần cho cấu hình mdev |
+--------------+-------------------------------------------------------------- +

Hạn chế
===========
Di chuyển khách trực tiếp không được hỗ trợ cho khách sử dụng thiết bị AP mà không có
sự can thiệp của người quản trị hệ thống. Trước khi có thể di chuyển khách KVM,
thiết bị trung gian vfio_ap phải được loại bỏ. Thật không may, nó không thể được
được xóa theo cách thủ công (tức là echo 1 > /sys/devices/vfio_ap/matrix/$UUID/remove) trong khi
mdev đang được khách KVM sử dụng. Nếu khách đang được mô phỏng bởi QEMU,
mdev của nó có thể được rút nóng khỏi máy khách theo một trong hai cách:

1. Nếu máy khách KVM được khởi động bằng libvirt, bạn có thể rút phích cắm nóng mdev qua
   các lệnh sau:

virsh tách thiết bị <tên khách> <đường dẫn đến thiết bị-xml>

Ví dụ: để rút phích cắm nóng mdev 62177883-f1bb-47f0-914d-32a22e3a8804 khỏi
      vị khách tên là 'my-guest':

virsh tách thiết bị my-guest ~/config/my-guest-hostdev.xml

Nội dung của my-guest-hostdev.xml:

.. code-block:: xml

            <hostdev mode='subsystem' type='mdev' managed='no' model='vfio-ap'>
              <source>
                <address uuid='62177883-f1bb-47f0-914d-32a22e3a8804'/>
              </source>
            </hostdev>


      virsh qemu-monitor-command <guest-name> --hmp "device-del <device-id>"

      For example, to hot unplug the vfio_ap mediated device identified on the
      qemu command line with 'id=hostdev0' from the guest named 'my-guest':

.. code-block:: sh

         virsh qemu-monitor-command my-guest --hmp "device_del hostdev0"

2. Có thể rút phích cắm nóng thiết bị qua trung gian vfio_ap bằng cách gắn màn hình qemu
   cho khách và sử dụng lệnh giám sát qemu sau:

(QEMU) id-del thiết bị=<device-id>

Ví dụ: để rút phích cắm nóng thiết bị qua trung gian vfio_ap đã được chỉ định
      trên dòng lệnh qemu với 'id=hostdev0' khi khách được khởi động:

(QEMU) thiết bị-del id=hostdev0

Sau khi quá trình di chuyển trực tiếp của khách KVM hoàn tất, cấu hình AP có thể được thực hiện
được khôi phục cho máy khách KVM bằng cách cắm nóng thiết bị qua trung gian vfio_ap vào mục tiêu
hệ thống vào khách theo một trong hai cách:

1. Nếu máy khách KVM được khởi động bằng libvirt, bạn có thể cắm nóng một ma trận qua trung gian
   thiết bị vào máy khách thông qua các lệnh virsh sau:

thiết bị đính kèm virsh <tên khách> <đường dẫn đến thiết bị-xml>

Ví dụ: cắm nóng mdev 62177883-f1bb-47f0-914d-32a22e3a8804 vào
      vị khách tên là 'my-guest':

virsh Attach-device my-guest ~/config/my-guest-hostdev.xml

Nội dung của my-guest-hostdev.xml:

.. code-block:: xml

            <hostdev mode='subsystem' type='mdev' managed='no' model='vfio-ap'>
              <source>
                <address uuid='62177883-f1bb-47f0-914d-32a22e3a8804'/>
              </source>
            </hostdev>


   virsh qemu-monitor-command <guest-name> --hmp \
   "device_add vfio-ap,sysfsdev=<path-to-mdev>,id=<device-id>"

      For example, to hot plug the vfio_ap mediated device
      62177883-f1bb-47f0-914d-32a22e3a8804 into the guest named 'my-guest' with
      device-id hostdev0:

      virsh qemu-monitor-command my-guest --hmp \
      "device_add vfio-ap,\
      sysfsdev=/sys/devices/vfio_ap/matrix/62177883-f1bb-47f0-914d-32a22e3a8804,\
      id=hostdev0"

2. Có thể cắm nóng thiết bị trung gian vfio_ap bằng cách gắn màn hình qemu
   cho khách và sử dụng lệnh giám sát qemu sau:

(qemu) device_add "vfio-ap,sysfsdev=<path-to-mdev>,id=<device-id>"

Ví dụ: để cắm thiết bị trung gian vfio_ap
      62177883-f1bb-47f0-914d-32a22e3a8804 vào khách với id thiết bị
      máy chủdev0:

(QEMU) thêm thiết bị "vfio-ap,\
         sysfsdev=/sys/devices/vfio_ap/matrix/62177883-f1bb-47f0-914d-32a22e3a8804,\
         id=hostdev0"
