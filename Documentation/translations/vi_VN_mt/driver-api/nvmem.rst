.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/nvmem.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================
Hệ thống con NVMEM
===============

Srinivas Kandagatla <srinivas.kandagatla@linaro.org>

Tài liệu này giải thích Khung NVMEM cùng với các API được cung cấp,
và cách sử dụng nó.

1. Giới thiệu
===============
ZZ0000ZZ là tên viết tắt của lớp Bộ nhớ không bay hơi. Nó được sử dụng để
truy xuất cấu hình của dữ liệu cụ thể của SOC hoặc Thiết bị từ dữ liệu không ổn định
những kỷ niệm như eeprom, efuses, v.v.

Trước khi khung này tồn tại, các trình điều khiển NVMEM như eeprom đã được lưu trữ trong
trình điều khiển/linh tinh, trong đó tất cả đều phải sao chép khá nhiều mã giống nhau để
đăng ký một tệp sysfs, cho phép người dùng trong kernel truy cập nội dung của
thiết bị họ đang lái xe, v.v.

Đây cũng là một vấn đề liên quan đến những người dùng trong kernel khác, vì
các giải pháp được sử dụng khá khác nhau tùy theo từng trình điều khiển, ở đó
là một rò rỉ trừu tượng khá lớn.

Khung này nhằm mục đích giải quyết những vấn đề này. Nó cũng giới thiệu DT
đại diện cho các thiết bị tiêu dùng để lấy dữ liệu họ yêu cầu (MAC
Địa chỉ, SoC/ID sửa đổi, số bộ phận, v.v.) từ NVMEM.

Nhà cung cấp NVMEM
+++++++++++++++

Nhà cung cấp NVMEM đề cập đến một thực thể thực hiện các phương thức để khởi tạo, đọc
và ghi vào bộ nhớ bất biến.

2. Đăng ký/Hủy đăng ký nhà cung cấp NVMEM
===============================================

Nhà cung cấp NVMEM có thể đăng ký với lõi NVMEM bằng cách cung cấp các thông tin liên quan
cấu hình nvmem thành nvmem_register(), trên lõi thành công sẽ trả về giá trị hợp lệ
con trỏ nvmem_device.

nvmem_unregister() được sử dụng để hủy đăng ký nhà cung cấp đã đăng ký trước đó.

Ví dụ: trường hợp nvram đơn giản ::

int tĩnh brcm_nvram_probe(struct platform_device *pdev)
  {
	cấu hình nvmem_config = {
		.name = "brcm-nvram",
		.reg_read = brcm_nvram_read,
	};
	...
config.dev = &pdev->dev;
	config.priv = riêng tư;
	config.size = Resource_size(res);

devm_nvmem_register(&config);
  }

Trình điều khiển thiết bị có thể xác định và đăng ký một ô nvmem bằng cách sử dụng nvmem_cell_info
cấu trúc::

cấu trúc const tĩnh nvmem_cell_info foo_nvmem_cell = {
	{
		.name = "macaddr",
		.offset = 0x7f00,
		.byte = ETH_ALEN,
	}
  };

int nvmem_add_one_cell(nvmem, &foo_nvmem_cell);

Ngoài ra, có thể tạo các mục tra cứu ô nvmem và đăng ký
chúng với khung nvmem từ mã máy như trong ví dụ bên dưới::

cấu trúc tĩnh nvmem_cell_lookup foo_nvmem_lookup = {
	.nvmem_name = "i2c-eeprom",
	.cell_name = "macaddr",
	.dev_id = "foo_mac.0",
	.con_id = "địa chỉ mac",
  };

nvmem_add_cell_lookups(&foo_nvmem_lookup, 1);

Người tiêu dùng NVMEM
+++++++++++++++

Người tiêu dùng NVMEM là những thực thể sử dụng nhà cung cấp NVMEM để
đọc từ và tới NVMEM.

3. API tiêu dùng dựa trên tế bào NVMEM
=================================

Các ô NVMEM là các mục/trường dữ liệu trong NVMEM.
Khung NVMEM cung cấp 3 API để đọc/ghi các ô NVMEM::

struct nvmem_cell *nvmem_cell_get(struct device *dev, const char *name);
  struct nvmem_cell *devm_nvmem_cell_get(struct device *dev, const char *name);

void nvmem_cell_put(struct nvmem_cell *cell);
  void devm_nvmem_cell_put(thiết bị cấu trúc *dev, struct nvmem_cell *cell);

void *nvmem_cell_read(struct nvmem_cell *cell, ssize_t *len);
  int nvmem_cell_write(struct nvmem_cell *cell, void *buf, ssize_t len);

API ZZ0000ZZ sẽ nhận được tham chiếu đến ô nvmem cho một id nhất định,
và nvmem_cell_read/write() sau đó có thể đọc hoặc ghi vào ô.
Sau khi sử dụng xong cell, người tiêu dùng nên gọi
ZZ0001ZZ để giải phóng tất cả bộ nhớ cấp phát cho ô.

4. API tiêu dùng dựa trên thiết bị NVMEM trực tiếp
==========================================

Trong một số trường hợp, cần phải đọc/ghi trực tiếp NVMEM.
Để tạo điều kiện thuận lợi cho những người tiêu dùng như vậy, khung NVMEM cung cấp các API bên dưới::

struct nvmem_device *nvmem_device_get(struct device *dev, const char *name);
  cấu trúc nvmem_device *devm_nvmem_device_get(struct device *dev,
					   const char *tên);
  cấu trúc nvmem_device *nvmem_device_find(void *data,
			int (*match)(struct device *dev, const void *data));
  void nvmem_device_put(struct nvmem_device *nvmem);
  int nvmem_device_read(struct nvmem_device *nvmem, unsigned int offset,
		      size_t byte, void *buf);
  int nvmem_device_write(struct nvmem_device *nvmem, unsigned int offset,
		       size_t byte, void *buf);
  int nvmem_device_cell_read(struct nvmem_device *nvmem,
			   cấu trúc nvmem_cell_info *info, void *buf);
  int nvmem_device_cell_write(struct nvmem_device *nvmem,
			    cấu trúc nvmem_cell_info *info, void *buf);

Trước khi người tiêu dùng có thể đọc/ghi trực tiếp NVMEM, nó phải được giữ lại
của nvmem_controller từ một trong các api ZZ0000ZZ.

Sự khác biệt giữa các api này và các api dựa trên tế bào là các api này luôn
lấy nvmem_device làm tham số.

5. Đưa ra tham chiếu đến NVMEM
=====================================

Khi người tiêu dùng không còn cần NVMEM nữa, họ phải đưa ra tham chiếu
đến NVMEM mà nó có được bằng cách sử dụng các API được đề cập ở phần trên.
Khung NVMEM cung cấp 2 API để phát hành tham chiếu đến NVMEM ::

void nvmem_cell_put(struct nvmem_cell *cell);
  void devm_nvmem_cell_put(thiết bị cấu trúc *dev, struct nvmem_cell *cell);
  void nvmem_device_put(struct nvmem_device *nvmem);
  void devm_nvmem_device_put(thiết bị cấu trúc *dev, struct nvmem_device *nvmem);

Cả hai API này đều được sử dụng để phát hành một tham chiếu đến NVMEM và
devm_nvmem_cell_put và devm_nvmem_device_put phá hủy các devre liên quan
với chiếc NVMEM này.

Không gian người dùng
+++++++++

6. Giao diện nhị phân không gian người dùng
==============================

Không gian người dùng có thể đọc/ghi tệp NVMEM thô có tại::

/sys/bus/nvmem/thiết bị/*/nvmem

bán tại::

hexdump /sys/bus/nvmem/devices/qfprom0/nvmem

0000000 0000 0000 0000 0000 0000 0000 0000 0000
  *
  00000a0 db10 2240 0000 e000 0c00 0c00 0000 0c00
  0000000 0000 0000 0000 0000 0000 0000 0000 0000
  ...
*
  0001000

7. Liên kết cây thiết bị
=====================

Xem Tài liệu/devicetree/binds/nvmem/nvmem.txt

8. Bố cục NVMEM
================

Bố cục NVMEM là một cơ chế khác để tạo ô. Với thiết bị
liên kết cây có thể chỉ định các ô đơn giản bằng cách sử dụng offset
và một chiều dài. Đôi khi, các ô không có độ lệch tĩnh, nhưng
nội dung vẫn được xác định rõ ràng, ví dụ: giá trị độ dài thẻ. Trong trường hợp này,
nội dung thiết bị NVMEM phải được phân tích cú pháp trước tiên và các ô cần phải
được bổ sung tương ứng. Bố cục cho phép bạn đọc nội dung của thiết bị NVMEM
và cho phép bạn thêm ô một cách linh hoạt.

Một trường hợp sử dụng khác của bố cục là xử lý hậu kỳ các ô. Với bố cục,
có thể liên kết móc xử lý bài đăng tùy chỉnh với một ô. Nó
thậm chí có thể thêm móc này vào các ô không được tạo bởi chính bố cục.

9. Hạt nhân nội bộ API
======================

.. kernel-doc:: drivers/nvmem/core.c
   :export: