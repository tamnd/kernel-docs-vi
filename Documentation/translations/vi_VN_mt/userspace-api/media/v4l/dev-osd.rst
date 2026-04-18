.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/dev-osd.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _osd:

*******************************
Giao diện lớp phủ đầu ra video
******************************

ZZ0000ZZ

Một số thiết bị đầu ra video có thể phủ hình ảnh bộ đệm khung lên trên
tín hiệu video đi ra. Các ứng dụng có thể thiết lập lớp phủ như vậy bằng cách sử dụng
giao diện này mượn các cấu trúc và ioctls của
Giao diện ZZ0000ZZ.

Chức năng OSD có thể truy cập được thông qua cùng một tệp ký tự đặc biệt
như chức năng ZZ0000ZZ.

.. note::

   The default function of such a ``/dev/video`` device is video
   capturing or output. The OSD function is only available after calling
   the :ref:`VIDIOC_S_FMT <VIDIOC_G_FMT>` ioctl.


Khả năng truy vấn
=====================

Các thiết bị hỗ trợ giao diện ZZ0004ZZ thiết lập
Cờ ZZ0002ZZ trong trường ZZ0003ZZ của
struct ZZ0000ZZ được trả về bởi
ZZ0001ZZ ioctl.


Bộ đệm khung
===========

Ngược lại với giao diện ZZ0010ZZ, bộ đệm khung thường
được thực hiện trên card TV chứ không phải card đồ họa. Trên Linux thì là vậy
có thể truy cập dưới dạng thiết bị bộ đệm khung (ZZ0004ZZ). Cho một thiết bị V4L2,
các ứng dụng có thể tìm thấy thiết bị bộ đệm khung tương ứng bằng cách gọi
ZZ0000ZZ ioctl. Nó trở lại, trong số
thông tin khác, địa chỉ vật lý của bộ đệm khung trong
Trường ZZ0005ZZ của cấu trúc ZZ0001ZZ.
Thiết bị bộ đệm khung ioctl ZZ0006ZZ trả về tương tự
địa chỉ trong trường ZZ0007ZZ của cấu trúc
ZZ0002ZZ. ZZ0008ZZ
ioctl và struct ZZ0003ZZ được định nghĩa trong
tệp tiêu đề ZZ0009ZZ.

Chiều rộng và chiều cao của bộ đệm khung phụ thuộc vào video hiện tại
tiêu chuẩn. Trình điều khiển V4L2 có thể từ chối các nỗ lực thay đổi tiêu chuẩn video
(hoặc bất kỳ ioctl nào khác có nghĩa là thay đổi kích thước bộ đệm khung) với
Mã lỗi ZZ0000ZZ cho đến khi tất cả các ứng dụng đóng thiết bị bộ đệm khung.

Ví dụ: Tìm thiết bị bộ đệm khung cho OSD
---------------------------------------------

.. code-block:: c

    #include <linux/fb.h>

    struct v4l2_framebuffer fbuf;
    unsigned int i;
    int fb_fd;

    if (-1 == ioctl(fd, VIDIOC_G_FBUF, &fbuf)) {
	perror("VIDIOC_G_FBUF");
	exit(EXIT_FAILURE);
    }

    for (i = 0; i < 30; i++) {
	char dev_name[16];
	struct fb_fix_screeninfo si;

	snprintf(dev_name, sizeof(dev_name), "/dev/fb%u", i);

	fb_fd = open(dev_name, O_RDWR);
	if (-1 == fb_fd) {
	    switch (errno) {
	    case ENOENT: /* no such file */
	    case ENXIO:  /* no driver */
		continue;

	    default:
		perror("open");
		exit(EXIT_FAILURE);
	    }
	}

	if (0 == ioctl(fb_fd, FBIOGET_FSCREENINFO, &si)) {
	    if (si.smem_start == (unsigned long)fbuf.base)
		break;
	} else {
	    /* Apparently not a framebuffer device. */
	}

	close(fb_fd);
	fb_fd = -1;
    }

    /* fb_fd is the file descriptor of the framebuffer device
       for the video output overlay, or -1 if no device was found. */


Cửa sổ lớp phủ và chia tỷ lệ
==========================

Lớp phủ được kiểm soát bởi các hình chữ nhật nguồn và đích. nguồn
hình chữ nhật chọn một phần phụ của hình ảnh bộ đệm khung để phủ lên,
hình chữ nhật mục tiêu một khu vực trong tín hiệu video đi ra nơi
hình ảnh sẽ xuất hiện. Trình điều khiển có thể hỗ trợ hoặc không hỗ trợ mở rộng quy mô và tùy ý
kích thước và vị trí của các hình chữ nhật này. Trình điều khiển khác có thể hỗ trợ bất kỳ
(hoặc không có) phương pháp cắt/pha trộn được xác định cho
Giao diện ZZ0000ZZ.

Cấu trúc ZZ0000ZZ xác định kích thước của
hình chữ nhật nguồn, vị trí của nó trong bộ đệm khung và
phương pháp cắt/pha trộn được sử dụng cho lớp phủ. Để có được hiện tại
các ứng dụng tham số thiết lập trường ZZ0004ZZ của cấu trúc
ZZ0001ZZ tới
ZZ0005ZZ và gọi
ZZ0002ZZ ioctl. Người lái xe điền vào
cấu trúc con ZZ0003ZZ có tên ZZ0006ZZ. Nó không phải
có thể truy xuất danh sách cắt hoặc bitmap đã được lập trình trước đó.

Để lập trình các ứng dụng hình chữ nhật nguồn, hãy đặt trường ZZ0006ZZ của một
cấu trúc ZZ0000ZZ thành
ZZ0007ZZ, khởi tạo ZZ0008ZZ
cấu trúc con và gọi ZZ0001ZZ ioctl.
Trình điều khiển điều chỉnh các thông số theo giới hạn phần cứng và trả về
các thông số thực tế như ZZ0002ZZ. Giống như ZZ0003ZZ,
ZZ0004ZZ ioctl có thể được sử dụng để học
về khả năng của trình điều khiển mà không thực sự thay đổi trạng thái trình điều khiển. Không giống
ZZ0005ZZ tính năng này cũng hoạt động sau khi lớp phủ được bật.

Cấu trúc ZZ0000ZZ xác định kích thước và vị trí
của hình chữ nhật mục tiêu. Hệ số tỷ lệ của lớp phủ được ngụ ý bởi
chiều rộng và chiều cao được cho trong cấu trúc ZZ0001ZZ
và cấu trúc ZZ0002ZZ. API cắt xén áp dụng cho
Các thiết bị ZZ0004ZZ và ZZ0005ZZ theo cách tương tự như
Các thiết bị ZZ0006ZZ và ZZ0007ZZ, chỉ đảo ngược
hướng của luồng dữ liệu. Để biết thêm thông tin, hãy xem ZZ0003ZZ.


Kích hoạt lớp phủ
================

Không có V4L2 ioctl để bật hoặc tắt lớp phủ, tuy nhiên
giao diện bộ đệm khung của trình điều khiển có thể hỗ trợ ZZ0000ZZ ioctl.