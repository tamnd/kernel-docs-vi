.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/dvbproperty.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _frontend-properties:

**************
Loại tài sản
**************

Dò kênh vật lý của TV kỹ thuật số và bắt đầu giải mã nó
yêu cầu thay đổi một tập hợp các tham số để điều khiển bộ điều chỉnh,
bộ giải điều chế, Bộ khuếch đại nhiễu thấp tuyến tính (LNA) và để đặt
hệ thống con ăng-ten thông qua Điều khiển Thiết bị Vệ tinh - SEC (trên vệ tinh
hệ thống). Các thông số thực tế dành riêng cho từng digital cụ thể
Các tiêu chuẩn TV và có thể thay đổi khi thông số kỹ thuật của TV kỹ thuật số phát triển.

Trước đây (lên đến DVB API phiên bản 3 - DVBv3), chiến lược được sử dụng là có một
kết hợp với các tham số cần thiết để điều chỉnh cho DVB-S, DVB-C, DVB-T và
Hệ thống phân phối ATSC được nhóm ở đó. Vấn đề là ở chỗ, như lần thứ hai
tiêu chuẩn thế hệ đã xuất hiện, quy mô của các liên minh đó không lớn
đủ để nhóm các cấu trúc cần thiết cho những cấu trúc mới đó
tiêu chuẩn. Ngoài ra, việc mở rộng nó sẽ phá vỡ không gian người dùng.

Vì vậy, cách tiếp cận dựa trên liên minh/cấu trúc kế thừa không được dùng nữa, thay vào đó là
của cách tiếp cận tập thuộc tính. Trên cách tiếp cận như vậy,
ZZ0000ZZ được sử dụng
để thiết lập giao diện người dùng và đọc trạng thái của nó.

Hành động thực tế được xác định bởi một tập hợp các cặp cmd/dữ liệu dtv_property.
Với một ioctl duy nhất, có thể nhận/thiết lập tối đa 64 thuộc tính.

Phần này mô tả cách mới và được đề xuất để thiết lập giao diện người dùng,
với sự hỗ trợ tất cả các hệ thống phân phối truyền hình kỹ thuật số.

.. note::

   1. On Linux DVB API version 3, setting a frontend was done via
      struct :c:type:`dvb_frontend_parameters`.

   2. Don't use DVB API version 3 calls on hardware with supports
      newer standards. Such API provides no support or a very limited
      support to new standards and/or new hardware.

   3. Nowadays, most frontends support multiple delivery systems.
      Only with DVB API version 5 calls it is possible to switch between
      the multiple delivery systems supported by a frontend.

   4. DVB API version 5 is also called *S2API*, as the first
      new standard added to it was DVB-S2.

ZZ0001ZZ: để đặt phần cứng dò sang kênh DVB-C
ở 651 kHz, được điều chế bằng 256-QAM, FEC 3/4 và tốc độ ký hiệu là 5,217
Mbauds, những tài sản đó nên được gửi tới
ZZ0000ZZ ioctl:

ZZ0000ZZ = SYS_DVBC_ANNEX_A

ZZ0000ZZ = 651000000

ZZ0000ZZ = QAM_256

ZZ0000ZZ = INVERSION_AUTO

ZZ0000ZZ = 5217000

ZZ0000ZZ = FEC_3_4

ZZ0000ZZ

Đoạn mã thực hiện điều trên được hiển thị trong
ZZ0000ZZ.

.. code-block:: c
    :caption: Example: Setting digital TV frontend properties
    :name: dtv-prop-example

    #include <stdio.h>
    #include <fcntl.h>
    #include <sys/ioctl.h>
    #include <linux/dvb/frontend.h>

    static struct dtv_property props[] = {
	{ .cmd = DTV_DELIVERY_SYSTEM, .u.data = SYS_DVBC_ANNEX_A },
	{ .cmd = DTV_FREQUENCY,       .u.data = 651000000 },
	{ .cmd = DTV_MODULATION,      .u.data = QAM_256 },
	{ .cmd = DTV_INVERSION,       .u.data = INVERSION_AUTO },
	{ .cmd = DTV_SYMBOL_RATE,     .u.data = 5217000 },
	{ .cmd = DTV_INNER_FEC,       .u.data = FEC_3_4 },
	{ .cmd = DTV_TUNE }
    };

    static struct dtv_properties dtv_prop = {
	.num = 6, .props = props
    };

    int main(void)
    {
	int fd = open("/dev/dvb/adapter0/frontend0", O_RDWR);

	if (!fd) {
	    perror ("open");
	    return -1;
	}
	if (ioctl(fd, FE_SET_PROPERTY, &dtv_prop) == -1) {
	    perror("ioctl");
	    return -1;
	}
	printf("Frontend set\\n");
	return 0;
    }

.. attention:: While it is possible to directly call the Kernel code like the
   above example, it is strongly recommended to use
   `libdvbv5 <https://linuxtv.org/docs/libdvbv5/index.html>`__, as it
   provides abstraction to work with the supported digital TV standards and
   provides methods for usual operations like program scanning and to
   read/write channel descriptor files.

.. toctree::
    :maxdepth: 1

    fe_property_parameters
    frontend-stat-properties
    frontend-property-terrestrial-systems
    frontend-property-cable-systems
    frontend-property-satellite-systems
    frontend-header