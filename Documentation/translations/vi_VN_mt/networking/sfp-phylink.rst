.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/sfp-phylink.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=======
liên kết phylink
=======

Tổng quan
========

phyllink là một cơ chế hỗ trợ các mô-đun mạng có thể cắm nóng
được kết nối trực tiếp với MAC mà không cần phải khởi tạo lại
bộ điều hợp trong các sự kiện cắm nóng.

phyllink hỗ trợ các thiết lập dựa trên phylib thông thường, thiết lập liên kết cố định
và các mô-đun SFP (Small Formfactor Pluggable) hiện nay.

Phương thức hoạt động
==================

phylink có một số chế độ hoạt động, tùy thuộc vào phần sụn
cài đặt.

1. Chế độ PHY

Ở chế độ PHY, chúng tôi sử dụng phylib để đọc cài đặt liên kết hiện tại từ
   PHY và chuyển chúng cho trình điều khiển MAC.  Chúng tôi mong đợi trình điều khiển MAC
   để cấu hình chính xác các chế độ được chỉ định mà không cần bất kỳ
   đàm phán đang được kích hoạt trên liên kết.

2. Chế độ cố định

Chế độ cố định giống như chế độ PHY về trình điều khiển MAC
   quan tâm.

3. Chế độ trong băng tần

Chế độ trong băng tần được sử dụng với 802.3z, SGMII và các chế độ giao diện tương tự,
   và chúng tôi mong đợi sử dụng và tôn trọng việc đàm phán trong nhóm hoặc
   từ điều khiển được gửi qua kênh serdes.

Ví dụ, điều này có nghĩa là:

.. code-block:: none

  &eth {
    phy = <&phy>;
    phy-mode = "sgmii";
  };

không sử dụng tín hiệu SGMII trong băng tần.  PHY dự kiến sẽ tiếp nối
chính xác các cài đặt được cung cấp cho nó trong chức năng ZZ0000ZZ của nó.
Liên kết phải được buộc lên hoặc xuống một cách thích hợp trong
Chức năng ZZ0001ZZ và ZZ0002ZZ.

.. code-block:: none

  &eth {
    managed = "in-band-status";
    phy = <&phy>;
    phy-mode = "sgmii";
  };

sử dụng chế độ trong băng tần, trong đó kết quả từ quá trình đàm phán của PHY được thông qua
tới MAC thông qua từ điều khiển SGMII và MAC dự kiến sẽ
thừa nhận từ điều khiển.  ZZ0000ZZ và
Các chức năng ZZ0001ZZ không được ép buộc liên kết bên MAC
lên và xuống.

Hướng dẫn sơ bộ để chuyển đổi trình điều khiển mạng sang sfp/phylink
=========================================================

Hướng dẫn này mô tả ngắn gọn cách chuyển đổi trình điều khiển mạng từ
phylib sang hỗ trợ sfp/phylink.  Vui lòng gửi bản vá để cải thiện
tài liệu này.

1. Tùy chọn chia chức năng cập nhật phylib của trình điều khiển mạng thành
   hai phần liên quan đến liên kết xuống và liên kết lên. Điều này có thể được thực hiện như
   một cam kết chuẩn bị riêng biệt.

Một ví dụ cũ hơn về sự chuẩn bị này có thể được tìm thấy trong git commit
   fc548b991fb0, mặc dù phần này được chia thành ba phần; cái
   phần liên kết hiện bao gồm việc định cấu hình MAC cho cài đặt liên kết.
   Vui lòng xem ZZ0000ZZ để biết thêm thông tin về điều này.

2. Thay thế::

chọn FIXED_PHY
	chọn PHYLIB

với::

chọn PHYLINK

trong khổ thơ Kconfig của người lái xe.

3. Thêm::

#include <linux/phylink.h>

vào danh sách các tập tin tiêu đề của trình điều khiển.

4. Thêm::

cấu trúc phyllink *phylink;
	cấu trúc phylink_config phylink_config;

tới cấu trúc dữ liệu riêng tư của người lái xe.  Chúng ta sẽ tham khảo các
   con trỏ dữ liệu riêng tư của trình điều khiển như ZZ0000ZZ bên dưới và của trình điều khiển
   cấu trúc dữ liệu riêng tư như ZZ0001ZZ.

5. Thay thế các chức năng sau:

   .. flat-table::
    :header-rows: 1
    :widths: 1 1
    :stub-columns: 0

    * - Original function
      - Replacement function
    * - phy_start(phydev)
      - phylink_start(priv->phylink)
    * - phy_stop(phydev)
      - phylink_stop(priv->phylink)
    * - phy_mii_ioctl(phydev, ifr, cmd)
      - phylink_mii_ioctl(priv->phylink, ifr, cmd)
    * - phy_ethtool_get_wol(phydev, wol)
      - phylink_ethtool_get_wol(priv->phylink, wol)
    * - phy_ethtool_set_wol(phydev, wol)
      - phylink_ethtool_set_wol(priv->phylink, wol)
    * - phy_disconnect(phydev)
      - phylink_disconnect_phy(priv->phylink)

Xin lưu ý rằng một số chức năng này phải được gọi theo
   rtnl lock và sẽ cảnh báo nếu không. Thông thường sẽ như vậy,
   ngoại trừ nếu chúng được gọi từ đường dẫn tạm dừng/tiếp tục của trình điều khiển.

6. Thêm/thay thế các phương thức ksettings get/set bằng:

   .. code-block:: c

int tĩnh foo_ethtool_set_link_ksettings(struct net_device *dev,
						  const struct ethtool_link_ksettings *cmd)
	{
		struct foo_priv *priv = netdev_priv(dev);
	
trả về phylink_ethtool_ksettings_set(priv->phylink, cmd);
	}

int tĩnh foo_ethtool_get_link_ksettings(struct net_device *dev,
						  cấu trúc ethtool_link_ksettings *cmd)
	{
		struct foo_priv *priv = netdev_priv(dev);
	
trả về phylink_ethtool_ksettings_get(priv->phylink, cmd);
	}

7. Thay thế cuộc gọi tới::

phy_dev = of_phy_connect(dev, node, link_func, flags, phy_interface);

và mã được liên kết với lệnh gọi tới ::

err = phylink_of_phy_connect(priv->phylink, nút, cờ);

Trong hầu hết các trường hợp, ZZ0000ZZ có thể bằng 0; những lá cờ này được chuyển đến
   phy_attach_direct() bên trong lệnh gọi hàm này nếu PHY được chỉ định
   trong nút DT ZZ0001ZZ.

ZZ0000ZZ phải là nút DT chứa thuộc tính phy mạng,
   thuộc tính liên kết cố định và cũng sẽ chứa thuộc tính sfp.

Việc thiết lập các liên kết cố định cũng cần được loại bỏ; những thứ này được xử lý
   nội bộ bởi phyllink.

of_phy_connect() cũng được chuyển qua một con trỏ hàm để cập nhật liên kết.
   Chức năng này được thay thế bằng một hình thức cập nhật MAC khác
   được mô tả dưới đây trong (8).

Việc thao túng hỗ trợ/quảng cáo của PHY xảy ra trong phyllink
   dựa trên lệnh gọi lại xác thực, xem bên dưới trong (8).

Lưu ý rằng trình điều khiển không cần lưu trữ ZZ0000ZZ nữa,
   và cũng lưu ý rằng ZZ0001ZZ trở thành thuộc tính động,
   giống như cài đặt tốc độ, song công, v.v.

Cuối cùng, lưu ý rằng trình điều khiển MAC không có quyền truy cập trực tiếp vào PHY
   nữa; đó là bởi vì trong mô hình phyllink, PHY có thể
   năng động.

8. Thêm phiên bản ZZ0000ZZ vào
   trình điều khiển, là một bảng các con trỏ hàm và thực hiện
   những chức năng này. Chức năng cập nhật link cũ cho
   ZZ0001ZZ trở thành ba phương thức: ZZ0002ZZ,
   ZZ0003ZZ và ZZ0004ZZ. Nếu bước 1 là
   được thực hiện thì chức năng sẽ được phân chia ở đó.

Điều quan trọng là nếu sử dụng đàm phán trong băng tần,
   ZZ0000ZZ và ZZ0001ZZ không ngăn chặn
   đàm phán trong băng từ khi hoàn thành, vì các chức năng này được gọi là
   khi trạng thái liên kết trong băng tần thay đổi - nếu không liên kết sẽ không bao giờ
   đi lên.

Phương pháp ZZ0000ZZ là tùy chọn và nếu được cung cấp thì phải
   trả lại các khả năng phyllink MAC được hỗ trợ cho thông qua
   Chế độ ZZ0001ZZ. Nói chung, không cần phải thực hiện phương pháp này.
   Phylink sẽ sử dụng các khả năng này kết hợp với các khả năng được phép
   khả năng để ZZ0002ZZ xác định liên kết ethtool được phép
   chế độ.

Phương pháp ZZ0000ZZ được sử dụng để đọc trạng thái liên kết
   từ MAC và báo cáo lại các cài đặt mà MAC hiện đang sử dụng
   sử dụng. Điều này đặc biệt quan trọng đối với việc đàm phán trong nhóm
   các phương pháp như 1000base-X và SGMII.

Phương pháp ZZ0000ZZ được sử dụng để thông báo cho MAC rằng
   liên kết đã xuất hiện. Cuộc gọi bao gồm chế độ đàm phán và giao diện
   chỉ để tham khảo. Các tham số liên kết cuối cùng cũng được cung cấp
   (cài đặt hỗ trợ tốc độ, song công và kiểm soát luồng/tạm dừng)
   nên được sử dụng để định cấu hình MAC khi MAC và PCS không
   được tích hợp chặt chẽ hoặc khi cài đặt không đến từ trong băng tần
   đàm phán.

Phương pháp ZZ0000ZZ được sử dụng để cập nhật MAC với
   trạng thái được yêu cầu và phải tránh gỡ liên kết xuống một cách không cần thiết
   khi thực hiện thay đổi cấu hình MAC.  Điều này có nghĩa là
   chức năng nên sửa đổi trạng thái và chỉ gỡ liên kết xuống khi
   thực sự cần thiết để thay đổi cấu hình MAC.  Một ví dụ
   bạn có thể tìm thấy cách thực hiện việc này trong ZZ0001ZZ ở
   ZZ0002ZZ.

Để biết thêm thông tin về các phương pháp này, vui lòng xem nội tuyến
   tài liệu trong ZZ0000ZZ.

9. Điền vào các trường ZZ0000ZZ bằng
   tham chiếu đến ZZ0001ZZ được liên kết với
   ZZ0002ZZ:

   .. code-block:: c

riêng tư->phylink_config.dev = &dev.dev;
	riêng tư->phylink_config.type = PHYLINK_NETDEV;

Điền vào các chế độ tốc độ, tạm dừng và song công khác nhau mà MAC của bạn có thể xử lý:

   .. code-block:: c

        priv->phylink_config.mac_capabilities = MAC_SYM_PAUSE | MAC_10 | MAC_100 | MAC_1000FD;

10. Một số bộ điều khiển Ethernet hoạt động cặp với PCS (Lớp con mã hóa vật lý)
    khối, có thể xử lý mã hóa/giải mã, liên kết
    phát hiện cơ sở và tự động thương lượng. Trong khi một số MAC có nội bộ
    PCS có hoạt động trong suốt, một số khác yêu cầu PCS chuyên dụng
    cấu hình để liên kết hoạt động. Trong trường hợp đó, phyllink
    cung cấp sự trừu tượng hóa PCS thông qua ZZ0000ZZ.

Xác định xem trình điều khiển của bạn có một hoặc nhiều khối PCS bên trong hay không và/hoặc nếu
    bộ điều khiển của bạn có thể sử dụng khối PCS bên ngoài có thể ở bên trong
    được kết nối với bộ điều khiển của bạn.

Nếu bộ điều khiển của bạn không có PCS bên trong, bạn có thể chuyển sang bước 11.

Nếu bộ điều khiển Ethernet của bạn chứa một hoặc nhiều khối PCS, hãy tạo
    một phiên bản ZZ0000ZZ trên mỗi khối PCS trong
    cấu trúc dữ liệu riêng tư của trình điều khiển của bạn:

    .. code-block:: c

        struct phylink_pcs pcs;

Điền ZZ0000ZZ có liên quan vào
    định cấu hình PCS của bạn. Tạo hàm ZZ0001ZZ báo cáo
    trạng thái liên kết trong băng tần, chức năng ZZ0002ZZ để định cấu hình
    PCS theo các thông số do phylink cung cấp và ZZ0003ZZ
    chức năng báo cáo cho phyllink tất cả các tham số cấu hình được chấp nhận cho
    PCS của bạn:

    .. code-block:: c

        struct phylink_pcs_ops foo_pcs_ops = {
                .pcs_validate = foo_pcs_validate,
                .pcs_get_state = foo_pcs_get_state,
                .pcs_config = foo_pcs_config,
        };

Sắp xếp để chuyển tiếp các ngắt trạng thái liên kết PCS vào
    phylink, thông qua:

    .. code-block:: c

        phylink_pcs_change(pcs, link_is_up);

trong đó ZZ0000ZZ là đúng nếu liên kết hiện đang hoạt động hoặc sai
    mặt khác. Nếu PCS không thể cung cấp các ngắt này thì
    cần đặt ZZ0001ZZ khi tạo PCS.

11. Nếu bộ điều khiển của bạn dựa vào hoặc chấp nhận sự hiện diện của PCS bên ngoài
    được điều khiển thông qua trình điều khiển của chính nó, thêm một con trỏ vào phiên bản phylink_pcs
    trong cấu trúc dữ liệu riêng tư của trình điều khiển của bạn:

    .. code-block:: c

        struct phylink_pcs *pcs;

Cách lấy phiên bản PCS thực tế phụ thuộc vào nền tảng,
    một số PCS ngồi trên xe buýt MDIO và bị tóm bằng cách chuyển một con trỏ tới
    địa chỉ ZZ0000ZZ tương ứng và PCS trên
    xe buýt đó. Trong ví dụ này, chúng tôi giả sử bộ điều khiển gắn vào Lynx PCS
    ví dụ:

    .. code-block:: c

        priv->pcs = lynx_pcs_create_mdiodev(bus, 0);

Một số PCS có thể được khôi phục dựa trên thông tin phần sụn:

    .. code-block:: c

        priv->pcs = lynx_pcs_create_fwnode(of_fwnode_handle(node));

12. Điền lệnh gọi lại ZZ0000ZZ và thêm nó vào
    Bộ hoạt động ZZ0001ZZ. Chức năng này
    phải trả về một con trỏ tới ZZ0002ZZ có liên quan
    sẽ được sử dụng cho cấu hình liên kết được yêu cầu:

    .. code-block:: c

        static struct phylink_pcs *foo_select_pcs(struct phylink_config *config,
                                                  phy_interface_t interface)
        {
                struct foo_priv *priv = container_of(config, struct foo_priv,
                                                     phylink_config);

                if ( /* 'interface' needs a PCS to function */ )
                        return priv->pcs;

                return NULL;
        }

Xem ZZ0000ZZ để biết ví dụ về trình điều khiển có nhiều
    PCS nội bộ.

13. Điền tất cả ZZ0000ZZ (tức là tất cả MAC đến
    Chế độ liên kết PHY) mà MAC của bạn có thể xuất ra. Ví dụ sau đây cho thấy một
    cấu hình cho MAC có thể xử lý tất cả các chế độ RGMII, SGMII và 1000BaseX.
    Bạn phải điều chỉnh những điều này theo những gì MAC của bạn và tất cả PCS được liên kết
    với MAC này có khả năng, không chỉ giao diện bạn muốn sử dụng:

    .. code-block:: c

       phy_interface_set_rgmii(priv->phylink_config.supported_interfaces);
        __set_bit(PHY_INTERFACE_MODE_SGMII,
                  priv->phylink_config.supported_interfaces);
        __set_bit(PHY_INTERFACE_MODE_1000BASEX,
                  priv->phylink_config.supported_interfaces);

14. Xóa lệnh gọi tới of_parse_phandle() cho PHY,
    of_phy_register_fixed_link() cho các liên kết cố định, v.v. từ đầu dò
    chức năng và thay thế bằng:

    .. code-block:: c

cấu trúc phyllink *phylink;

phyllink = phylink_create(&priv->phylink_config, nút, phy_mode, &phylink_ops);
	nếu (IS_ERR(phylink)) {
		err = PTR_ERR(phylink);
		thăm dò thất bại;
	}

riêng tư->phylink = phyllink;

và sắp xếp để phá hủy phyllink trong đường dẫn lỗi của đầu dò như
    thích hợp và đường dẫn loại bỏ bằng cách gọi:

    .. code-block:: c

phyllink_destroy(priv->phylink);

15. Sắp xếp để chuyển tiếp các ngắt trạng thái liên kết MAC vào
    phylink, thông qua:

    .. code-block:: c

phylink_mac_change(priv->phylink, link_is_up);

trong đó ZZ0000ZZ là đúng nếu liên kết hiện đang hoạt động hoặc sai
    mặt khác.

16. Xác minh rằng trình điều khiển không gọi::

netif_carrier_on()
	netif_carrier_off()

vì những điều này sẽ cản trở việc theo dõi trạng thái liên kết của phylink,
    và khiến phylink bỏ qua cuộc gọi qua ZZ0000ZZ và
    Phương pháp ZZ0001ZZ.

Trình điều khiển mạng nên gọi phylink_stop() và phylink_start() thông qua
các đường dẫn tạm dừng/tiếp tục, điều này đảm bảo rằng các đường dẫn phù hợp
Các phương thức ZZ0000ZZ được gọi
khi cần thiết.

Để biết thông tin mô tả lồng SFP trong DT, vui lòng xem ràng buộc
tài liệu trong cây nguồn kernel
ZZ0000ZZ.