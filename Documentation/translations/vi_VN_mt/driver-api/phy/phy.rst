.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/phy/phy.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============
Hệ thống con PHY
=============

:Tác giả: Kishon Vijay Abraham I <kishon@ti.com>

Tài liệu này giải thích Khung PHY chung cùng với các API được cung cấp,
và cách sử dụng.

Giới thiệu
============

ZZ0000ZZ là tên viết tắt của lớp vật lý. Nó được sử dụng để kết nối một thiết bị
sang môi trường vật lý, ví dụ: bộ điều khiển USB có PHY để cung cấp các chức năng
chẳng hạn như tuần tự hóa, giải tuần tự hóa, mã hóa, giải mã và chịu trách nhiệm
để đạt được tốc độ truyền dữ liệu cần thiết. Lưu ý rằng một số USB
bộ điều khiển có chức năng PHY được nhúng vào nó và các bộ điều khiển khác sử dụng bộ điều khiển bên ngoài
PHY. Các thiết bị ngoại vi khác sử dụng PHY bao gồm Wireless LAN, Ethernet,
SATA, v.v.

Mục đích của việc tạo ra framework này là để phổ biến trình điều khiển PHY
từ nhân Linux đến trình điều khiển/phy để tăng khả năng sử dụng lại mã và
khả năng bảo trì mã tốt hơn.

Khung này sẽ chỉ được sử dụng cho các thiết bị sử dụng PHY bên ngoài (PHY
chức năng không được nhúng trong bộ điều khiển).

Đăng ký/Hủy đăng ký nhà cung cấp PHY
==========================================

Nhà cung cấp PHY đề cập đến một thực thể triển khai một hoặc nhiều phiên bản PHY.
Đối với trường hợp đơn giản khi nhà cung cấp PHY chỉ triển khai một phiên bản duy nhất của
PHY, khung này cung cấp cách triển khai of_xlate của riêng nó trong
của_phy_simple_xlate. Nếu nhà cung cấp PHY triển khai nhiều phiên bản, nó
nên cung cấp cách triển khai of_xlate của riêng mình. of_xlate chỉ được sử dụng cho
trường hợp khởi động dt.

::

#define của_phy_provider_register(dev, xlate) \
		__of_phy_provider_register((dev), NULL, THIS_MODULE, (xlate))

#define devm_of_phy_provider_register(dev, xlate) \
		__devm_of_phy_provider_register((dev), NULL, THIS_MODULE,
						(xlate))

Các macro of_phy_provider_register và devm_of_phy_provider_register có thể được sử dụng để
đăng ký phy_provider và nó lấy thiết bị và of_xlate làm
lý lẽ. Đối với trường hợp khởi động dt, tất cả các nhà cung cấp PHY nên sử dụng một trong các trường hợp trên
2 macro để đăng ký nhà cung cấp PHY.

Thông thường các nút cây thiết bị được liên kết với nhà cung cấp PHY sẽ chứa một tập hợp
số trẻ em mà mỗi trẻ đại diện cho một PHY. Một số ràng buộc có thể làm tổ đứa trẻ
các nút trong các cấp độ bổ sung cho bối cảnh và khả năng mở rộng, trong trường hợp đó mức thấp
cấp độ_phy_provider_register_full() và devm_of_phy_provider_register_full()
macro có thể được sử dụng để ghi đè nút chứa nút con.

::

#define of_phy_provider_register_full(dev, trẻ em, xlate) \
		__of_phy_provider_register(nhà phát triển, trẻ em, THIS_MODULE, xlate)

#define devm_of_phy_provider_register_full(dev, trẻ em, xlate) \
		__devm_of_phy_provider_register_full(dev, trẻ em,
						     THIS_MODULE, xlate)

void devm_of_phy_provider_unregister(thiết bị cấu trúc *dev,
		cấu trúc phy_provider *phy_provider);
	void of_phy_provider_unregister(struct phy_provider *phy_provider);

devm_of_phy_provider_unregister và of_phy_provider_unregister có thể được sử dụng để
hủy đăng ký PHY.

Tạo PHY
================

Trình điều khiển PHY sẽ tạo PHY để cho các bộ điều khiển ngoại vi khác
để sử dụng nó. Khung PHY cung cấp 2 API để tạo PHY.

::

cấu trúc phy *phy_create(struct device *dev, cấu trúc device_node *nút,
			       const struct phy_ops *ops);
	cấu trúc phy *devm_phy_create(struct device *dev,
				    cấu trúc device_node *nút,
				    const struct phy_ops *ops);

Trình điều khiển PHY có thể sử dụng một trong 2 API trên để tạo PHY bằng cách chuyển
con trỏ thiết bị và các hoạt động phy.
phy_ops là một tập hợp các con trỏ hàm để thực hiện các thao tác PHY như
init, exit, power_on và power_off.

Để hủy đăng ký dữ liệu riêng tư (trong phy_ops), trình điều khiển nhà cung cấp phy
có thể sử dụng phy_set_drvdata() sau khi tạo PHY và sử dụng phy_get_drvdata() trong
phy_ops để lấy lại dữ liệu riêng tư.

Tham khảo PHY
==============================

Trước khi bộ điều khiển có thể sử dụng PHY, nó phải tham chiếu đến
nó. Khung này cung cấp các API sau để tham chiếu đến PHY.

::

cấu trúc phy *phy_get(struct device *dev, const char *string);
	cấu trúc phy *devm_phy_get(struct device *dev, const char *string);
	cấu trúc phy *devm_phy_optional_get(struct device *dev,
					  const char *chuỗi);
	cấu trúc phy *devm_of_phy_get(struct device *dev, cấu trúc device_node *np,
				    const char *con_id);
	cấu trúc phy *devm_of_phy_optional_get(struct device *dev,
					     cấu trúc device_node *np,
					     const char *con_id);
	cấu trúc phy *devm_of_phy_get_by_index(struct device *dev,
					     cấu trúc device_node *np,
					     chỉ số int);

phy_get, devm_phy_get và devm_phy_Option_get có thể được sử dụng để nhận PHY.
Trong trường hợp dt boot, các đối số chuỗi
phải chứa tên phy như được đưa ra trong dữ liệu dt và trong trường hợp
khởi động không phải dt, nó phải chứa nhãn của PHY.  hai
devm_phy_get liên kết thiết bị với PHY bằng cách sử dụng devres trên
nhận được PHY thành công. Khi tách trình điều khiển, chức năng giải phóng được gọi trên
dữ liệu devres và dữ liệu devres được giải phóng.
Nên sử dụng các biến thể _Optional_get khi phy là tùy chọn. Những cái này
các hàm sẽ không bao giờ trả về -ENODEV mà thay vào đó trả về NULL khi
không thể tìm thấy phy.
Một số trình điều khiển chung, chẳng hạn như ehci, có thể sử dụng nhiều phys. Trong trường hợp này,
devm_of_phy_get hoặc devm_of_phy_get_by_index có thể được sử dụng để lấy phy
tham chiếu dựa trên tên hoặc chỉ mục.

Cần lưu ý rằng NULL là tài liệu tham khảo phy hợp lệ. Tất cả phy
các cuộc gọi của người tiêu dùng trên NULL phy sẽ trở thành NOP. Đó là lời kêu gọi phát hành,
các lệnh gọi phy_init() và phy_exit() và phy_power_on() và
Tất cả các lệnh gọi phy_power_off() đều là NOP khi được áp dụng cho NULL phy. NULL
phy rất hữu ích trong các thiết bị xử lý các thiết bị phy tùy chọn.

Thứ tự cuộc gọi API
==================

Thứ tự chung của các cuộc gọi phải là::

[devm_][of_]phy_get()
    phy_init()
    phy_power_on()
    [phy_set_mode[_ext]()]
    ...
phy_power_off()
    phy_exit()
    [[of_]phy_put()]

Một số trình điều khiển PHY có thể không triển khai ZZ0000ZZ hoặc ZZ0001ZZ,
nhưng bộ điều khiển phải luôn gọi các chức năng này để tương thích với các chức năng khác
PHY. Một số PHY có thể yêu cầu ZZ0002ZZ, trong khi
những người khác có thể sử dụng chế độ mặc định (thường được định cấu hình qua devicetree hoặc chế độ khác
phần sụn). Để tương thích, bạn nên luôn gọi hàm này nếu bạn biết
bạn sẽ sử dụng chế độ nào. Nói chung, chức năng này nên được gọi sau
ZZ0003ZZ, mặc dù một số trình điều khiển PHY có thể cho phép nó bất cứ lúc nào.

Phát hành một tham chiếu đến PHY
================================

Khi bộ điều khiển không còn cần PHY nữa, nó phải giải phóng tham chiếu
đến PHY mà nó có được bằng cách sử dụng các API được đề cập ở phần trên. các
Khung PHY cung cấp 2 API để phát hành tham chiếu đến PHY.

::

void phy_put(struct phy *phy);
	void devm_phy_put(thiết bị cấu trúc *dev, struct phy *phy);

Cả hai API này đều được sử dụng để phát hành một tham chiếu đến PHY và devm_phy_put
phá hủy các devre liên quan đến PHY này.

Phá hủy PHY
==================

Khi trình điều khiển tạo PHY được dỡ xuống, nó sẽ hủy PHY.
được tạo bằng một trong 2 API sau::

void phy_destroy(struct phy *phy);
	void devm_phy_destroy(thiết bị cấu trúc *dev, struct phy *phy);

Cả hai API này đều phá hủy PHY và devm_phy_destroy phá hủy các nhà phát triển
được liên kết với PHY này.

Thời gian chạy PM
==========

Hệ thống con này được kích hoạt thời gian chạy chiều. Vì vậy, trong khi tạo PHY,
pm_runtime_enable của thiết bị phy được tạo bởi hệ thống con này được gọi và
trong khi phá hủy PHY, pm_runtime_disable được gọi. Lưu ý rằng phy
thiết bị được tạo bởi hệ thống con này sẽ là con của thiết bị gọi
phy_create (thiết bị của nhà cung cấp PHY).

Vì vậy pm_runtime_get_sync của phy_device được tạo bởi hệ thống con này sẽ gọi
pm_runtime_get_sync của thiết bị nhà cung cấp PHY vì mối quan hệ cha-con.
Cũng cần lưu ý rằng phy_power_on và phy_power_off thực hiện
phy_pm_runtime_get_sync và phy_pm_runtime_put tương ứng.
Có các API được xuất như phy_pm_runtime_get, phy_pm_runtime_get_sync,
phy_pm_runtime_put và phy_pm_runtime_put_sync để thực hiện các hoạt động PM.

Ánh xạ PHY
============

Để có được tham chiếu đến PHY mà không cần sự trợ giúp từ DeviceTree, khung
cung cấp các tra cứu có thể so sánh với clkdev cho phép cấu trúc clk
ràng buộc với các thiết bị. Việc tra cứu có thể được thực hiện trong thời gian chạy khi một điều khiển tới
cấu trúc phy đã tồn tại.

Khung này cung cấp API sau để đăng ký và hủy đăng ký
tra cứu::

int phy_create_lookup(cấu trúc phy *phy, const char *con_id,
			      const char *dev_id);
	void phy_remove_lookup(cấu trúc phy *phy, const char *con_id,
			       const char *dev_id);

Liên kết cây thiết bị
==================

Có thể tìm thấy tài liệu về ràng buộc dt PHY @
Tài liệu/devicetree/binds/phy/phy-binds.txt
