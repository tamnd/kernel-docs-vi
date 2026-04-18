.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/omap/omap_pm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Giao diện OMAP PM
=======================

Tài liệu này mô tả giao diện OMAP PM tạm thời.  Người lái xe
tác giả sử dụng các chức năng này để truyền đạt độ trễ tối thiểu hoặc
các ràng buộc thông lượng đối với mã quản lý năng lượng hạt nhân.
Theo thời gian, mục đích là hợp nhất các tính năng từ OMAP PM
giao diện vào mã QoS của Linux PM.

Trình điều khiển cần thể hiện các thông số PM:

- hỗ trợ nhiều thông số quản lý nguồn có trong TI SRF;

- tách các trình điều khiển khỏi tham số PM cơ bản
  triển khai, cho dù đó là TI SRF hay Linux PM QoS hay Linux
  khuôn khổ độ trễ hoặc cái gì khác;

- chỉ định các tham số PM theo các đơn vị cơ bản, chẳng hạn như
  độ trễ và thông lượng, thay vì các đơn vị dành riêng cho OMAP
  hoặc các biến thể OMAP cụ thể;

- cho phép các trình điều khiển được chia sẻ với các kiến trúc khác (ví dụ:
  DaVinci) để thêm các ràng buộc này theo cách không ảnh hưởng đến không phải OMAP
  hệ thống,

- có thể được thực hiện ngay lập tức với sự gián đoạn tối thiểu của các hoạt động khác
  kiến trúc.


Tài liệu này đề xuất giao diện OMAP PM, bao gồm các giao diện sau
năm chức năng quản lý năng lượng cho mã trình điều khiển:

1. Đặt độ trễ đánh thức MPU tối đa::

(*pdata->set_max_mpu_wakeup_lat)(struct device *dev, dài không dấu)

2. Đặt độ trễ đánh thức thiết bị tối đa::

(*pdata->set_max_dev_wakeup_lat)(struct device *dev, dài không dấu)

3. Đặt độ trễ bắt đầu truyền DMA tối đa của hệ thống (CORE pwrdm)::

(*pdata->set_max_sdma_lat)(struct device *dev, dài)

4. Đặt thông lượng bus tối thiểu mà thiết bị cần::

(*pdata->set_min_bus_tput)(struct device *dev, u8 Agent_id, r dài không dấu)

5. Trả về số lần máy bị mất ngữ cảnh::

(*pdata->get_dev_context_loss_count)(struct device *dev)


Tài liệu bổ sung cho tất cả các chức năng giao diện OMAP PM có thể
được tìm thấy trong Arch/arm/plat-omap/include/mach/omap-pm.h.


Lớp OMAP PM được thiết kế tạm thời
---------------------------------------------

Mục đích là cuối cùng lớp QoS của Linux sẽ hỗ trợ
một loạt các tính năng quản lý năng lượng có trong OMAP3.  Như thế này
xảy ra, trình điều khiển hiện có sử dụng giao diện OMAP PM có thể được sửa đổi
để sử dụng mã QoS của PM Linux; và giao diện OMAP PM có thể biến mất.


Cách sử dụng trình điều khiển của các chức năng OMAP PM
-------------------------------------

Như 'pdata' trong các ví dụ trên cho thấy, các hàm này là
tiếp xúc với trình điều khiển thông qua các con trỏ hàm trong trình điều khiển .platform_data
các cấu trúc.  Các con trỏ hàm được khởi tạo bởi ZZ0000ZZ
các tệp để trỏ đến các hàm OMAP PM tương ứng:

- set_max_dev_wakeup_lat sẽ trỏ tới
  omap_pm_set_max_dev_wakeup_lat(), v.v. Các kiến trúc khác làm được điều đó
  không hỗ trợ các hàm này nên để nguyên các con trỏ hàm này
  tới NULL.  Người lái xe nên sử dụng thành ngữ sau::

nếu (pdata->set_max_dev_wakeup_lat)
            (*pdata->set_max_dev_wakeup_lat)(dev, t);

Cách sử dụng phổ biến nhất của các hàm này có lẽ là để chỉ định
thời gian tối đa kể từ khi xảy ra ngắt cho đến khi thiết bị
trở nên có thể truy cập được.  Để thực hiện điều này, người viết trình điều khiển nên sử dụng
hàm set_max_mpu_wakeup_lat() để hạn chế việc đánh thức MPU
độ trễ và hàm set_max_dev_wakeup_lat() để hạn chế
độ trễ đánh thức thiết bị (từ clk_enable() đến khả năng truy cập).  Ví dụ::

/* Giới hạn độ trễ đánh thức MPU */
        nếu (pdata->set_max_mpu_wakeup_lat)
            (*pdata->set_max_mpu_wakeup_lat)(dev, tc);

/* Giới hạn độ trễ đánh thức miền điện của thiết bị */
        nếu (pdata->set_max_dev_wakeup_lat)
            (*pdata->set_max_dev_wakeup_lat)(dev, td);

/* tổng độ trễ đánh thức trong ví dụ này: (tc + td) */

Các tham số PM có thể được ghi đè bằng cách gọi lại hàm
với giá trị mới.  Có thể xóa cài đặt bằng cách gọi
hàm có đối số t là -1 (ngoại trừ trường hợp
set_max_bus_tput(), nên được gọi với đối số r bằng 0).

Hàm thứ năm ở trên, omap_pm_get_dev_context_loss_count(),
nhằm mục đích tối ưu hóa để cho phép người lái xe xác định liệu
thiết bị đã mất bối cảnh bên trong của nó.  Nếu ngữ cảnh bị mất,
trình điều khiển phải khôi phục bối cảnh bên trong của nó trước khi tiếp tục.


Các chức năng giao diện chuyên biệt khác
-------------------------------------

Năm chức năng được liệt kê ở trên nhằm mục đích có thể sử dụng được bởi bất kỳ ai
trình điều khiển thiết bị.  DSPBridge và CPUFreq có một số yêu cầu đặc biệt.
DSPBridge thể hiện mức hiệu suất DSP mục tiêu dưới dạng ID OPP.
CPUFreq thể hiện mức hiệu suất MPU mục tiêu theo MPU
tần số.  Giao diện OMAP PM chứa các chức năng cho những
trường hợp chuyên biệt để chuyển đổi thông tin đầu vào đó (OPPs/MPU
tần số) thành dạng quản lý năng lượng cơ bản
nhu cầu triển khai:

6. ZZ0000ZZ

7. ZZ0000ZZ

8. ZZ0000ZZ

9. ZZ0000ZZ

10. ZZ0000ZZ

11. ZZ0000ZZ

Tùy chỉnh OPP cho nền tảng
============================
Xác định CONFIG_PM sẽ kích hoạt lớp OPP cho silicon
và việc đăng ký bảng OPP sẽ diễn ra tự động.
Tuy nhiên, trong những trường hợp đặc biệt, bảng OPP mặc định có thể cần phải được
được điều chỉnh, ví dụ:

* bật OPP mặc định bị tắt theo mặc định nhưng
   có thể được kích hoạt trên nền tảng
 * Vô hiệu hóa OPP không được hỗ trợ trên nền tảng
 * Xác định và thêm một mục bảng opp tùy chỉnh
   trong những trường hợp này, file board cần thực hiện thêm các bước như sau:

Arch/arm/mach-omapx/board-xyz.c::

#include "pm.h"
	....
khoảng trống tĩnh __init omap_xyz_init_irq(void)
	{
		....
/*Khởi tạo bảng mặc định */
		omapx_opp_init();
		/* Thực hiện tùy chỉnh về mặc định */
		....
	}

NOTE:
  omapx_opp_init sẽ là omap3_opp_init hoặc theo yêu cầu
  dựa trên họ omap.
