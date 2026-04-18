.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/fpga/fpga-programming.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

API trong hạt nhân để lập trình FPGA
==================================

Tổng quan
--------

API trong nhân dành cho lập trình FPGA là sự kết hợp của các API từ
Trình quản lý, cầu nối và khu vực FPGA.  Chức năng thực tế được sử dụng để
kích hoạt lập trình FPGA là fpga_khu vực_program_fpga().

fpga_khu vực_program_fpga() sử dụng chức năng được cung cấp bởi
trình quản lý và cầu nối FPGA.  Nó sẽ:

* khóa mutex của khu vực
 * khóa mutex của người quản lý FPGA của khu vực
 * xây dựng danh sách các cầu nối FPGA nếu một phương thức đã được chỉ định để làm như vậy
 * vô hiệu hóa các cây cầu
 * lập trình FPGA sử dụng thông tin được truyền trong ZZ0000ZZ.
 * kích hoạt lại các cây cầu
 * mở khóa

Cấu trúc fpga_image_info chỉ định hình ảnh FPGA nào sẽ được lập trình.  Đó là
được phân bổ/giải phóng bởi fpga_image_info_alloc() và được giải phóng bằng
fpga_image_info_free()

Cách lập trình FPGA bằng cách sử dụng vùng
-------------------------------------

Khi trình điều khiển vùng FPGA thăm dò, nó đã được đưa một con trỏ tới trình quản lý FPGA
driver để nó biết nên sử dụng trình quản lý nào.  Khu vực này cũng có một danh sách
cầu nối để điều khiển trong quá trình lập trình hoặc nó có một con trỏ tới một hàm
sẽ tạo ra danh sách đó.  Đây là một số mã mẫu về những việc cần làm tiếp theo::

#include <linux/fpga/fpga-mgr.h>
	#include <linux/fpga/fpga-khu vực.h>

cấu trúc fpga_image_info *thông tin;
	int ret;

/*
	 * Đầu tiên, phân bổ cấu trúc có thông tin về hình ảnh FPGA cho
	 * chương trình.
	 */
	thông tin = fpga_image_info_alloc(dev);
	nếu (!thông tin)
		trả về -ENOMEM;

/* Đặt cờ nếu cần, chẳng hạn như: */
	thông tin->cờ = FPGA_MGR_PARTIAL_RECONFIG;

/*
	 * Cho biết hình ảnh FPGA ở đâu. Đây là mã giả; bạn là
	 * sẽ sử dụng một trong ba.
	 */
	if (hình ảnh nằm trong bảng thu thập phân tán) {

info->sgt = [bảng thu thập phân tán của bạn]

} else if (hình ảnh nằm trong bộ đệm) {

info->buf = [bộ đệm hình ảnh của bạn]
		info->count = [kích thước bộ đệm hình ảnh]

} else if (hình ảnh nằm trong tệp chương trình cơ sở) {

thông tin->firmware_name = devm_kstrdup(dev, firmware_name,
						   GFP_KERNEL);

	}

/* Thêm thông tin vào vùng và lập trình */
	khu vực->thông tin = thông tin;
	ret = fpga_khu vực_program_fpga(khu vực);

/* Phân bổ thông tin hình ảnh nếu bạn đã hoàn tất nó */
	vùng->thông tin = NULL;
	fpga_image_info_free(thông tin);

nếu (ret)
		trở lại ret;

/* Bây giờ hãy liệt kê mọi phần cứng đã xuất hiện trong FPGA. */

API để lập trình FPGA
---------------------------

* fpga_khu vực_program_fpga() - Lập trình FPGA
* fpga_image_info() - Chỉ định hình ảnh FPGA nào để lập trình
* fpga_image_info_alloc() - Phân bổ cấu trúc thông tin hình ảnh FPGA
* fpga_image_info_free() - Miễn phí cấu trúc thông tin hình ảnh FPGA

.. kernel-doc:: drivers/fpga/fpga-region.c
   :functions: fpga_region_program_fpga

Cờ quản lý FPGA

.. kernel-doc:: include/linux/fpga/fpga-mgr.h
   :doc: FPGA Manager flags

.. kernel-doc:: include/linux/fpga/fpga-mgr.h
   :functions: fpga_image_info

.. kernel-doc:: drivers/fpga/fpga-mgr.c
   :functions: fpga_image_info_alloc

.. kernel-doc:: drivers/fpga/fpga-mgr.c
   :functions: fpga_image_info_free
