.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/netdevices.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
Thiết bị mạng, hạt nhân và bạn!
========================================


Giới thiệu
============
Sau đây là một bộ sưu tập ngẫu nhiên các tài liệu liên quan đến
các thiết bị mạng. Nó dành cho các nhà phát triển trình điều khiển.

quy tắc trọn đời của cấu trúc net_device
========================================
Cấu trúc thiết bị mạng cần được duy trì ngay cả sau khi mô-đun được dỡ tải và
phải được phân bổ bằng alloc_netdev_mqs() và bạn bè.
Nếu thiết bị đã đăng ký thành công, nó sẽ được giải phóng ở lần sử dụng cuối cùng
bởi free_netdev(). Điều này là cần thiết để xử lý ca bệnh lý một cách sạch sẽ
(ví dụ: ZZ0000ZZ)

alloc_netdev_mqs() / alloc_netdev() dành thêm dung lượng cho trình điều khiển
dữ liệu riêng tư sẽ được giải phóng khi thiết bị mạng được giải phóng. Nếu
dữ liệu được phân bổ riêng biệt được gắn vào thiết bị mạng
(netdev_priv()) thì việc giải phóng điều đó tùy thuộc vào trình xử lý thoát mô-đun.

Có hai nhóm API để đăng ký struct net_device.
Nhóm đầu tiên có thể được sử dụng trong các bối cảnh thông thường chưa có ZZ0000ZZ
được tổ chức: register_netdev(), unregister_netdev().
Nhóm thứ hai có thể được sử dụng khi ZZ0001ZZ đã được giữ:
register_netdevice(), unregister_netdevice(), free_netdevice().

Trình điều khiển đơn giản
-------------------------

Hầu hết các trình điều khiển (đặc biệt là trình điều khiển thiết bị) đều xử lý vòng đời của struct net_device
trong bối cảnh không giữ ZZ0000ZZ (ví dụ: thăm dò trình điều khiển và xóa đường dẫn).

Trong trường hợp đó, việc đăng ký struct net_device được thực hiện bằng cách sử dụng
các hàm register_netdev() và unregister_netdev():

.. code-block:: c

  int probe()
  {
    struct my_device_priv *priv;
    int err;

    dev = alloc_netdev_mqs(...);
    if (!dev)
      return -ENOMEM;
    priv = netdev_priv(dev);

    /* ... do all device setup before calling register_netdev() ...
     */

    err = register_netdev(dev);
    if (err)
      goto err_undo;

    /* net_device is visible to the user! */

  err_undo:
    /* ... undo the device setup ... */
    free_netdev(dev);
    return err;
  }

  void remove()
  {
    unregister_netdev(dev);
    free_netdev(dev);
  }

Lưu ý rằng sau khi gọi register_netdev() thiết bị sẽ hiển thị trong hệ thống.
Người dùng có thể mở nó và bắt đầu gửi / nhận lưu lượng truy cập ngay lập tức,
hoặc chạy bất kỳ cuộc gọi lại nào khác, vì vậy tất cả việc khởi tạo phải được thực hiện trước
đăng ký.

unregister_netdev() đóng thiết bị và đợi tất cả người dùng hoàn tất
với nó. Bộ nhớ của struct net_device vẫn có thể được tham chiếu
bởi sysfs nhưng mọi thao tác trên thiết bị đó sẽ thất bại.

free_netdev() có thể được gọi sau khi unregister_netdev() trả về hoặc khi
register_netdev() không thành công.

Quản lý thiết bị theo RTNL
----------------------------

Đăng ký struct net_device trong bối cảnh đã được giữ
ZZ0000ZZ cần được chăm sóc thêm. Trong những tình huống đó hầu hết các trình điều khiển
sẽ muốn sử dụng ZZ0001ZZ của struct net_device
và các thành viên ZZ0002ZZ để giải phóng trạng thái.

Luồng ví dụ về xử lý netdev trong ZZ0000ZZ:

.. code-block:: c

  static void my_setup(struct net_device *dev)
  {
    dev->needs_free_netdev = true;
  }

  static void my_destructor(struct net_device *dev)
  {
    some_obj_destroy(priv->obj);
    some_uninit(priv);
  }

  int create_link()
  {
    struct my_device_priv *priv;
    int err;

    ASSERT_RTNL();

    dev = alloc_netdev(sizeof(*priv), "net%d", NET_NAME_UNKNOWN, my_setup);
    if (!dev)
      return -ENOMEM;
    priv = netdev_priv(dev);

    /* Implicit constructor */
    err = some_init(priv);
    if (err)
      goto err_free_dev;

    priv->obj = some_obj_create();
    if (!priv->obj) {
      err = -ENOMEM;
      goto err_some_uninit;
    }
    /* End of constructor, set the destructor: */
    dev->priv_destructor = my_destructor;

    err = register_netdevice(dev);
    if (err)
      /* register_netdevice() calls destructor on failure */
      goto err_free_dev;

    /* If anything fails now unregister_netdevice() (or unregister_netdev())
     * will take care of calling my_destructor and free_netdev().
     */

    return 0;

  err_some_uninit:
    some_uninit(priv);
  err_free_dev:
    free_netdev(dev);
    return err;
  }

Nếu struct net_device.priv_structor được đặt, nó sẽ được gọi bởi lõi
một thời gian sau unregister_netdevice(), nó cũng sẽ được gọi nếu
register_netdevice() không thành công. Cuộc gọi lại có thể được gọi có hoặc không có
ZZ0000ZZ được giữ.

Không có lệnh gọi lại hàm tạo rõ ràng, trình điều khiển "xây dựng" riêng tư
trạng thái netdev sau khi phân bổ và trước khi đăng ký.

Đặt cấu trúc net_device.needs_free_netdev thực hiện cuộc gọi lõi free_netdevice()
tự động sau unregister_netdevice() khi tất cả các tham chiếu đến thiết bị
đã biến mất. Nó chỉ có hiệu lực sau khi gọi thành công tới register_netdevice()
vì vậy nếu register_netdevice() bị lỗi, trình điều khiển có trách nhiệm gọi
free_netdev().

free_netdev() an toàn khi gọi trên các đường dẫn lỗi ngay sau unregister_netdevice()
hoặc khi register_netdevice() không thành công. Các phần của quá trình đăng ký netdev (de)
xảy ra sau khi ZZ0000ZZ được phát hành, do đó trong những trường hợp đó free_netdev()
sẽ trì hoãn một số quá trình xử lý cho đến khi ZZ0001ZZ được phát hành.

Các thiết bị được sinh ra từ struct rtnl_link_ops sẽ không bao giờ giải phóng
cấu trúc net_device trực tiếp.

.ndo_init và .ndo_uninit
~~~~~~~~~~~~~~~~~~~~~~~~~

Lệnh gọi lại ZZ0000ZZ và ZZ0001ZZ được gọi trong net_device
đăng ký và hủy đăng ký, theo ZZ0002ZZ. Trình điều khiển có thể sử dụng
những ví dụ đó khi các phần của quy trình init của họ cần chạy dưới ZZ0003ZZ.

ZZ0000ZZ chạy trước khi thiết bị hiển thị trong hệ thống, ZZ0001ZZ
chạy trong quá trình hủy đăng ký sau khi đóng thiết bị nhưng các hệ thống con khác
có thể vẫn có những tài liệu tham khảo nổi bật về netdevice.

MTU
===
Mỗi thiết bị mạng có một Đơn vị truyền tải tối đa. MTU không
bao gồm bất kỳ chi phí giao thức lớp liên kết nào. Các giao thức lớp trên phải
không chuyển bộ đệm ổ cắm (skb) tới thiết bị để truyền nhiều dữ liệu hơn
hơn mtu. MTU không bao gồm chi phí tiêu đề lớp liên kết, vì vậy
ví dụ trên Ethernet nếu MTU tiêu chuẩn được sử dụng là 1500 byte thì
skb thực tế sẽ chứa tối đa 1514 byte do Ethernet
tiêu đề. Các thiết bị cũng phải cho phép tiêu đề VLAN 4 byte.

Giảm tải phân đoạn (GSO, TSO) là một ngoại lệ đối với quy tắc này.  các
Giao thức lớp trên có thể chuyển một bộ đệm ổ cắm lớn tới thiết bị
truyền thói quen và thiết bị sẽ chia nó thành các phần riêng biệt
các gói dựa trên MTU hiện tại.

MTU đối xứng và áp dụng cho cả nhận và truyền. Một thiết bị
phải có khả năng nhận được ít nhất gói kích thước tối đa được cho phép bởi
MTU. Một thiết bị mạng có thể sử dụng MTU làm cơ chế nhận kích thước
bộ đệm, nhưng thiết bị phải cho phép các gói có tiêu đề VLAN. Với
Ethernet mtu tiêu chuẩn 1500 byte, thiết bị sẽ cho phép tối đa
Gói 1518 byte (1500 + 14 tiêu đề + 4 thẻ).  Thiết bị có thể:
bỏ, cắt bớt hoặc bỏ qua các gói quá khổ, nhưng loại bỏ các gói quá khổ
gói được ưu tiên.


quy tắc đồng bộ hóa cấu trúc net_device
=======================================
ndo_open:
	Đồng bộ hóa: semaphore rtnl_lock(). Ngoài ra, phiên bản netdev
	khóa nếu trình điều khiển triển khai quản lý hàng đợi hoặc bộ định hình API.
	Bối cảnh: quá trình

ndo_stop:
	Đồng bộ hóa: semaphore rtnl_lock(). Ngoài ra, phiên bản netdev
	khóa nếu trình điều khiển triển khai quản lý hàng đợi hoặc bộ định hình API.
	Bối cảnh: quá trình
	Lưu ý: netif_running() được đảm bảo sai

ndo_do_ioctl:
	Đồng bộ hóa: semaphore rtnl_lock().

Điều này chỉ được gọi bởi các hệ thống con mạng nội bộ,
	không phải bởi không gian người dùng gọi ioctl như trước đây
	linux-5.14.

ndo_siocbond:
	Đồng bộ hóa: semaphore rtnl_lock(). Ngoài ra, phiên bản netdev
	khóa nếu trình điều khiển triển khai quản lý hàng đợi hoặc bộ định hình API.
        Bối cảnh: quá trình

Được sử dụng bởi trình điều khiển liên kết cho dòng SIOCBOND
	lệnh ioctl.

ndo_siocwandev:
	Đồng bộ hóa: semaphore rtnl_lock(). Ngoài ra, phiên bản netdev
	khóa nếu trình điều khiển triển khai quản lý hàng đợi hoặc bộ định hình API.
	Bối cảnh: quá trình

Được sử dụng bởi driver/net/wan framework để xử lý
	ioctl SIOCWANDEV với cấu trúc if_settings.

ndo_siocdevprivate:
	Đồng bộ hóa: semaphore rtnl_lock(). Ngoài ra, phiên bản netdev
	khóa nếu trình điều khiển triển khai quản lý hàng đợi hoặc bộ định hình API.
	Bối cảnh: quá trình

Điều này được sử dụng để triển khai trình trợ giúp ioctl SIOCDEVPRIVATE.
	Những thứ này không nên được thêm vào trình điều khiển mới, vì vậy đừng sử dụng.

ndo_eth_ioctl:
	Đồng bộ hóa: semaphore rtnl_lock(). Ngoài ra, phiên bản netdev
	khóa nếu trình điều khiển triển khai quản lý hàng đợi hoặc bộ định hình API.
	Bối cảnh: quá trình

ndo_get_stats:
	Đồng bộ hóa: RCU (có thể được gọi đồng thời với số liệu thống kê
	đường dẫn cập nhật).
	Bối cảnh: nguyên tử (không thể ngủ dưới RCU)

ndo_start_xmit:
	Đồng bộ hóa: __netif_tx_lock spinlock.

Khi trình điều khiển đặt dev->lltx thì đây sẽ là
	được gọi mà không cần giữ netif_tx_lock. Trong trường hợp này người lái xe
	phải tự khóa khi cần thiết.
	Việc khóa ở đó cũng phải bảo vệ đúng cách chống lại
	set_rx_mode. WARNING: việc sử dụng dev->lltx không được dùng nữa.
	Đừng sử dụng nó cho người lái xe mới.

Bối cảnh: Quá trình với BH bị vô hiệu hóa hoặc BH (bộ hẹn giờ),
		 sẽ được gọi với các ngắt bị vô hiệu hóa bởi netconsole.

Mã trả lại:

* NETDEV_TX_OK mọi thứ đều ổn.
	* NETDEV_TX_BUSY Không thể truyền gói tin, hãy thử lại sau
	  Thông thường là một lỗi, có nghĩa là điều khiển luồng bắt đầu/dừng hàng đợi bị hỏng trong
	  người lái xe. Lưu ý: người lái xe phải đặt NOT vào vòng DMA của nó.

ndo_tx_timeout:
	Đồng bộ hóa: netif_tx_lock spinlock; tất cả hàng đợi TX bị đóng băng.
	Bối cảnh: BH bị vô hiệu hóa
	Lưu ý: netif_queue_stopped() được đảm bảo đúng

ndo_set_rx_mode:
	Đồng bộ hóa: netif_addr_lock spinlock.
	Bối cảnh: BH bị vô hiệu hóa

ndo_setup_tc:
	ZZ0000ZZ và ZZ0001ZZ đang chạy dưới khóa NFT
	(tức là không có ZZ0002ZZ và không có khóa phiên bản thiết bị). Phần còn lại của
	Các loại ZZ0003ZZ chạy dưới khóa phiên bản netdev nếu trình điều khiển
	triển khai quản lý hàng đợi hoặc bộ định hình API.

Hầu hết các cuộc gọi lại ndo không được chỉ định trong danh sách trên đều đang chạy
dưới ZZ0000ZZ. Ngoài ra, khóa phiên bản netdev cũng được thực hiện nếu
trình điều khiển thực hiện quản lý hàng đợi hoặc bộ định hình API.

quy tắc đồng bộ hóa struct napi_struct
========================================
napi->thăm dò ý kiến:
	Đồng bộ hóa:
		Bit NAPI_STATE_SCHED ở trạng thái napi->.  Thiết bị
		phương thức ndo_stop của trình điều khiển sẽ gọi napi_disable() trên
		tất cả các phiên bản NAPI sẽ thực hiện cuộc thăm dò ý kiến đang ngủ trên
		NAPI_STATE_SCHED napi->bit trạng thái, đang chờ tất cả đang chờ xử lý
		Hoạt động NAPI chấm dứt.

Bối cảnh:
		 phần mềm
		 sẽ được gọi với các ngắt bị vô hiệu hóa bởi netconsole.

khóa phiên bản netdev
=====================

Trong lịch sử, tất cả các hoạt động kiểm soát mạng được bảo vệ bởi một
khóa toàn cầu được gọi là ZZ0000ZZ. Có một nỗ lực liên tục để thay thế điều này
khóa toàn cầu với các khóa riêng biệt cho từng không gian tên mạng. Ngoài ra,
các thuộc tính của từng netdev ngày càng được bảo vệ bởi các khóa trên mỗi netdev.

Đối với trình điều khiển thiết bị triển khai API quản lý hàng đợi hoặc định hình, tất cả các điều khiển
các hoạt động sẽ được thực hiện dưới khóa phiên bản netdev.
Trình điều khiển cũng có thể yêu cầu khóa phiên bản một cách rõ ràng trong quá trình hoạt động
bằng cách đặt ZZ0000ZZ thành true. Nhận xét mã và tài liệu tham khảo
đối với các trình điều khiển có các hoạt động được gọi trong khóa phiên bản là "ops đã khóa".
Xem thêm tài liệu của thành viên ZZ0001ZZ của struct net_device.

Ngoài ra còn có trường hợp lấy hai khóa trên mỗi netdev theo thứ tự khi netdev
hàng đợi được thuê, nghĩa là khóa phạm vi netdev được lấy cho cả
thiết bị ảo và vật lý. Để tránh tình trạng bế tắc, thiết bị ảo
khóa phải luôn được lấy trước thiết bị vật lý (xem
ZZ0000ZZ).

Trong tương lai sẽ có lựa chọn dành cho cá nhân
trình điều khiển từ chối sử dụng ZZ0000ZZ và thay vào đó thực hiện kiểm soát của họ
hoạt động trực tiếp dưới khóa phiên bản netdev.

Trình điều khiển thiết bị được khuyến khích dựa vào khóa phiên bản nếu có thể.

Đối với các trình điều khiển (chủ yếu là phần mềm) cần tương tác với ngăn xếp lõi,
có hai bộ giao diện: ZZ0000ZZ/ZZ0001ZZ và ZZ0002ZZ
(ví dụ: ZZ0003ZZ và ZZ0004ZZ). ZZ0005ZZ/ZZ0006ZZ
các hàm tự xử lý việc lấy khóa phiên bản, trong khi
Các hàm ZZ0007ZZ giả định rằng trình điều khiển đã có được
khóa phiên bản.

cấu trúc net_device_ops
-----------------------

ZZ0000ZZ được gọi mà không giữ khóa phiên bản đối với hầu hết các trình điều khiển.

Trình điều khiển "Đã khóa" sẽ có hầu hết ZZ0000ZZ được gọi theo
khóa phiên bản.

cấu trúc ethtool_ops
--------------------

Tương tự như ZZ0000ZZ, khóa phiên bản chỉ được giữ cho một số trình điều khiển được chọn.
Đối với trình điều khiển "ops đã khóa", tất cả các op ethtool không có ngoại lệ đều phải
được gọi dưới khóa phiên bản.

cấu trúc netdev_stat_ops
------------------------

Các hoạt động "qstat" được gọi dưới khóa phiên bản dành cho trình điều khiển "ops bị khóa",
và dưới rtnl_lock cho tất cả các trình điều khiển khác.

cấu trúc net_shaper_ops
-----------------------

Tất cả các lệnh gọi lại net Shaper đều được gọi trong khi giữ phiên bản netdev
khóa. ZZ0000ZZ có thể được giữ hoặc không.

Lưu ý rằng việc hỗ trợ trình tạo lưới sẽ tự động bật tính năng "khóa hoạt động".

cấu trúc netdev_queue_mgmt_ops
------------------------------

Tất cả lệnh gọi lại quản lý hàng đợi đều được gọi trong khi giữ phiên bản netdev
khóa. ZZ0000ZZ có thể được giữ hoặc không.

Lưu ý rằng việc hỗ trợ struct netdev_queue_mgmt_ops sẽ tự động kích hoạt
"opp khóa".

Trình thông báo và khóa phiên bản netdev
----------------------------------------

Đối với trình điều khiển thiết bị triển khai API quản lý hàng đợi hoặc định hình,
một số trình thông báo (ZZ0000ZZ) đang chạy dưới netdev
khóa phiên bản.

Các trình thông báo netdev sau đây luôn chạy dưới khóa phiên bản:
* ZZ0000ZZ

Đối với các thiết bị có hoạt động bị khóa, hiện tại chỉ có các thông báo sau
chạy dưới khóa:
* ZZ0000ZZ
* ZZ0001ZZ
* ZZ0002ZZ

Các trình thông báo sau đang chạy mà không có khóa:
* ZZ0000ZZ

Không có kỳ vọng rõ ràng cho những người thông báo còn lại. Trình thông báo không bật
danh sách có thể chạy có hoặc không có khóa phiên bản, thậm chí có thể gọi
cùng một loại trình thông báo có và không có khóa từ các đường dẫn mã khác nhau.
Mục tiêu cuối cùng là đảm bảo rằng tất cả (hoặc hầu hết, với một vài tài liệu
ngoại lệ) trình thông báo chạy dưới khóa phiên bản. Vui lòng mở rộng điều này
tài liệu bất cứ khi nào bạn đưa ra giả định rõ ràng về việc khóa được giữ
từ một người thông báo.

Không gian tên biểu tượng NETDEV_INTERNAL
=========================================

Các biểu tượng được xuất dưới dạng NETDEV_INTERNAL chỉ có thể được sử dụng trong mạng
lõi và trình điều khiển chỉ chạy qua danh sách mạng chính và cây.
Lưu ý rằng điều ngược lại không đúng, hầu hết các ký hiệu nằm ngoài NETDEV_INTERNAL
cũng không được sử dụng bởi mã ngẫu nhiên bên ngoài netdev.
Các ký hiệu có thể thiếu chỉ định vì chúng có trước các không gian tên,
hoặc đơn giản là do sơ suất.