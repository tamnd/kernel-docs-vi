.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/phy/samsung-usb2.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================================
Lớp thích ứng Samsung USB 2.0 PHY
====================================

1. Mô tả
--------------

Kiến trúc của mô-đun USB 2.0 PHY trong SoC của Samsung cũng tương tự
trong số nhiều SoC. Mặc dù có những điểm tương đồng nhưng thật khó để
tạo một trình điều khiển phù hợp với tất cả các bộ điều khiển PHY này. Thường xuyên
sự khác biệt là nhỏ và được tìm thấy trong các phần cụ thể của
thanh ghi của PHY. Trong một số trường hợp hiếm hoi, thứ tự đăng ký ghi hoặc
quá trình cấp nguồn cho PHY đã phải được thay đổi. Lớp thích ứng này được
sự thỏa hiệp giữa việc có trình điều khiển riêng và có một trình điều khiển duy nhất
với sự hỗ trợ bổ sung cho nhiều trường hợp đặc biệt.

2. Mô tả tập tin
--------------------

- phy-samsung-usb2.c
   Đây là tập tin chính của lớp thích ứng. Tập tin này chứa
   chức năng thăm dò và cung cấp hai lệnh gọi lại cho PHY chung
   Khung. Hai lệnh gọi lại này được sử dụng để bật và tắt nguồn
   phy. Họ thực hiện công việc chung phải làm trên tất cả các phiên bản
   của mô-đun PHY. Tùy thuộc vào SoC nào được chọn mà họ thực thi SoC
   cuộc gọi lại cụ thể. Phiên bản SoC cụ thể được chọn bằng cách chọn
   chuỗi tương thích thích hợp. Ngoài ra, tập tin này còn chứa
   định nghĩa struct of_device_id cho các SoC cụ thể.

- phy-samsung-usb2.h
   Đây là tập tin bao gồm. Nó khai báo các cấu trúc được sử dụng bởi điều này
   người lái xe. Ngoài ra, nó phải chứa các khai báo bên ngoài cho
   cấu trúc mô tả các SoC cụ thể.

3. Hỗ trợ SoC
------------------

Để hỗ trợ SoC mới, cần thêm một tệp mới vào trình điều khiển/phy.
thư mục. Cấu hình của mỗi SoC được lưu trữ trong một phiên bản của
cấu trúc samsung_usb2_phy_config::

cấu trúc samsung_usb2_phy_config {
	const struct samsung_usb2_common_phy *phys;
	int (ZZ0000ZZ);
	int unsign num_phys;
	bool has_mode_switch;
  };

num_phys là số lượng vật lý được trình điều khiển xử lý. ZZ0000ZZ là một
mảng chứa cấu hình cho từng phy. has_mode_switch
thuộc tính là cờ boolean xác định xem SoC có máy chủ USB hay không
và thiết bị trên một cặp chân duy nhất. Nếu vậy, phải có một sổ đăng ký đặc biệt
được sửa đổi để thay đổi định tuyến nội bộ của các chân này giữa USB
mô-đun thiết bị hoặc máy chủ.

Ví dụ cấu hình cho Exynos 4210 như sau::

const struct samsung_usb2_phy_config exynos4210_usb2_phy_config = {
	.has_mode_switch = 0,
	.num_phys = EXYNOS4210_NUM_PHYS,
	.phys = exynos4210_phys,
	.rate_to_clk = exynos4210_rate_to_clk,
  }

-ZZ0000ZZ

Cuộc gọi lại rate_to_clk là để chuyển đổi tốc độ của đồng hồ
	được sử dụng làm đồng hồ tham chiếu cho mô-đun PHY với giá trị
	điều đó sẽ được ghi vào sổ đăng ký phần cứng.

Mảng cấu hình exynos4210_phys như sau ::

cấu trúc const tĩnh samsung_usb2_common_phy exynos4210_phys[] = {
	{
		.label = "thiết bị",
		.id = EXYNOS4210_DEVICE,
		.power_on = exynos4210_power_on,
		.power_off = exynos4210_power_off,
	},
	{
		.label = "máy chủ",
		.id = EXYNOS4210_HOST,
		.power_on = exynos4210_power_on,
		.power_off = exynos4210_power_off,
	},
	{
		.label = "hsic0",
		.id = EXYNOS4210_HSIC0,
		.power_on = exynos4210_power_on,
		.power_off = exynos4210_power_off,
	},
	{
		.label = "hsic1",
		.id = EXYNOS4210_HSIC1,
		.power_on = exynos4210_power_on,
		.power_off = exynos4210_power_off,
	},
	{},
  };

-ZZ0000ZZ
  ZZ0001ZZ

Hai lệnh gọi lại này được sử dụng để bật và tắt nguồn phy.
	bằng cách sửa đổi các thanh ghi thích hợp.

Thay đổi cuối cùng đối với trình điều khiển là thêm giá trị tương thích thích hợp vào
tập tin phy-samsung-usb2.c. Trong trường hợp Exynos 4210, các dòng sau là
đã thêm vào mảng cấu trúc of_device_id samsung_usb2_phy_of_match[] ::

#ifdef CONFIG_PHY_EXYNOS4210_USB2
	{
		.tương thích = "samsung,exynos4210-usb2-phy",
		.data = &exynos4210_usb2_phy_config,
	},
  #endif

Để tăng thêm tính linh hoạt cho trình điều khiển, tệp Kconfig cho phép
bao gồm hỗ trợ cho các SoC đã chọn trong trình điều khiển được biên dịch. Kconfig
mục nhập cho Exynos 4210 như sau ::

cấu hình PHY_EXYNOS4210_USB2
	bool "Hỗ trợ cho Exynos 4210"
	phụ thuộc vào PHY_SAMSUNG_USB2
	phụ thuộc vào CPU_EXYNOS4210
	giúp đỡ
	  Kích hoạt hỗ trợ USB PHY cho Exynos 4210. Tùy chọn này yêu cầu điều đó
	  Trình điều khiển Samsung USB 2.0 PHY đã được bật và có nghĩa là hỗ trợ cho việc này
	  SoC cụ thể được biên dịch trong trình điều khiển. Trong trường hợp Exynos 4210 bốn
	  phys có sẵn - thiết bị, máy chủ, HSCI0 và HSCI1.

Tệp mới được tạo hỗ trợ SoC mới cũng phải được thêm vào
Makefile. Trong trường hợp Exynos 4210, dòng được thêm vào như sau ::

obj-$(CONFIG_PHY_EXYNOS4210_USB2) += phy-exynos4210-usb2.o

Sau khi hoàn thành các bước này, bộ phận hỗ trợ cho SoC mới sẽ sẵn sàng.
