.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/ioctl/hdio.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================
Tổng hợp các cuộc gọi ZZ0000ZZ ioctl
==============================

- Edward A. Falk <efalk@google.com>

Tháng 11 năm 2004

Tài liệu này cố gắng mô tả các lệnh gọi ioctl(2) được hỗ trợ bởi
lớp HD/IDE.  Chúng được triển khai rộng rãi (kể từ Linux 5.11)
trình điều khiển/ata/libata-scsi.c.

các giá trị ioctl được liệt kê trong <linux/hdreg.h>.  Khi viết bài này, họ
như sau:

ioctls chuyển con trỏ đối số tới không gian người dùng:

===================================================================
	HDIO_GETGEO lấy hình dạng thiết bị
	HDIO_GET_32BIT nhận cài đặt io_32bit hiện tại
	HDIO_GET_IDENTITY lấy thông tin nhận dạng IDE
	HDIO_DRIVE_TASKFILE thực thi tệp tác vụ thô
	HDIO_DRIVE_TASK thực thi nhiệm vụ và lệnh điều khiển đặc biệt
	HDIO_DRIVE_CMD thực hiện lệnh ổ đĩa đặc biệt
	===================================================================

ioctls chuyển các giá trị không phải con trỏ:

===================================================================
	HDIO_SET_32BIT thay đổi cờ io_32bit
	===================================================================


Thông tin sau đây được xác định từ việc đọc nguồn kernel
mã.  Có khả năng một số điều chỉnh sẽ được thực hiện theo thời gian.

------------------------------------------------------------------------------

Tổng quan:

Trừ khi có quy định khác, tất cả các lệnh gọi ioctl đều trả về 0 nếu thành công
	và -1 với errno được đặt thành giá trị thích hợp khi có lỗi.

Trừ khi có quy định khác, tất cả lệnh gọi ioctl đều trả về -1 và được đặt
	lỗi với EFAULT khi sao chép dữ liệu đến hoặc từ người dùng không thành công
	không gian địa chỉ.

Trừ khi có quy định khác, tất cả các cấu trúc dữ liệu và hằng số
	được định nghĩa trong <linux/hdreg.h>

------------------------------------------------------------------------------

HDIO_GETGEO
	lấy hình học thiết bị


cách sử dụng::

cấu trúc hình học hd_geometry;

ioctl(fd, HDIO_GETGEO, &geom);


đầu vào:
		không có



đầu ra:
		cấu trúc hd_geometry chứa:


========= ======================================
	    đầu số lượng đầu
	    ngành số lượng ngành/rãnh
	    số xi lanh số xi lanh, mod 65536
	    bắt đầu bắt đầu khu vực của phân vùng này.
	    ========= ======================================


lỗi trả về:
	  -EINVAL

nếu thiết bị không phải là ổ đĩa hoặc ổ đĩa mềm,
			hoặc nếu người dùng chuyển một con trỏ null


ghi chú:
		Không đặc biệt hữu ích với các ổ đĩa hiện đại, có hình dạng
		dù sao cũng là một hư cấu lịch sự.  Ổ đĩa hiện đại được giải quyết
		hoàn toàn theo số khu vực ngày nay (địa chỉ lba) và
		hình học ổ đĩa là một sự trừu tượng thực sự là chủ đề
		để thay đổi.  Hiện tại (tính đến tháng 11 năm 2004), các giá trị hình học
		là các giá trị "bios" - có lẽ là các giá trị mà ổ đĩa có
		khi Linux khởi động lần đầu tiên.

Ngoài ra, trường hình trụ của hd_geometry là một
		unsigned short, nghĩa là trên hầu hết các kiến trúc, điều này
		ioctl sẽ không trả về giá trị có ý nghĩa trên các ổ đĩa có nhiều hơn
		hơn 65535 bài hát.

Trường bắt đầu không có dấu dài, nghĩa là nó sẽ không
		chứa một giá trị có ý nghĩa cho các đĩa có kích thước trên 219 Gb.



HDIO_GET_IDENTITY
	lấy thông tin nhận dạng IDE


cách sử dụng::

danh tính char không dấu [512];

ioctl(fd, HDIO_GET_IDENTITY, danh tính);

đầu vào:
		không có



đầu ra:
		Thông tin nhận dạng ổ đĩa ATA.  Để biết mô tả đầy đủ, xem
		các lệnh IDENTIFY DEVICE và IDENTIFY PACKET DEVICE trong
		đặc điểm kỹ thuật ATA.

lỗi trả về:
	  - EINVAL Được gọi trên một phân vùng thay vì toàn bộ thiết bị đĩa
	  - Thông tin ENOMSG IDENTIFY DEVICE không có sẵn

ghi chú:
		Trả về thông tin thu được khi ổ đĩa được
		đã thăm dò.  Một số thông tin này có thể thay đổi và
		ioctl này không thăm dò lại ổ đĩa để cập nhật
		thông tin.

Thông tin này cũng có sẵn từ /proc/ide/hdX/identify



HDIO_GET_32BIT
	nhận cài đặt io_32bit hiện tại


cách sử dụng::

giá trị dài;

ioctl(fd, HDIO_GET_32BIT, &val);

đầu vào:
		không có



đầu ra:
		Giá trị của cài đặt io_32bit hiện tại



ghi chú:
		0=16-bit, 1=32-bit, 2,3 = 32bit+đồng bộ



HDIO_DRIVE_TASKFILE
	thực thi tệp tác vụ thô


Lưu ý:
		Nếu bạn không có bản sao thông số kỹ thuật ANSI ATA
		tiện dụng, có lẽ bạn nên bỏ qua ioctl này.

- Thực thi trực tiếp lệnh đĩa ATA bằng cách ghi "tệp tác vụ"
	  các thanh ghi của ổ đĩa.  Yêu cầu quyền truy cập ADMIN và RAWIO
	  đặc quyền.

cách sử dụng::

cấu trúc {

ide_task_request_t req_task;
	    u8 outbuf[OUTPUT_SIZE];
	    u8 inbuf[INPUT_SIZE];
	  } nhiệm vụ;
	  memset(&task.req_task, 0, sizeof(task.req_task));
	  task.req_task.out_size = sizeof(task.outbuf);
	  task.req_task.in_size = sizeof(task.inbuf);
	  ...
ioctl(fd, HDIO_DRIVE_TASKFILE, &task);
	  ...

đầu vào:

(Xem bên dưới để biết chi tiết về vùng bộ nhớ được chuyển tới ioctl.)

====================================================================
	  các giá trị io_ports[8] được ghi vào các thanh ghi taskfile
	  hob_ports[8] byte bậc cao, dành cho các lệnh mở rộng.
	  cờ out_flags cho biết thanh ghi nào hợp lệ
	  cờ in_flags cho biết thanh ghi nào sẽ được trả lại
	  data_phase xem bên dưới
	  loại lệnh req_cmd sẽ được thực thi
	  out_size kích thước của bộ đệm đầu ra
	  bộ đệm outbuf của dữ liệu được truyền vào đĩa
	  bộ đệm inbuf của dữ liệu được nhận từ đĩa (xem [1])
	  ====================================================================

đầu ra:

=====================================================================
	  giá trị io_ports[] được trả về trong thanh ghi tệp tác vụ
	  hob_ports[] byte thứ tự cao, dành cho các lệnh mở rộng.
	  cờ out_flags cho biết thanh ghi nào hợp lệ (xem [2])
	  cờ in_flags cho biết thanh ghi nào sẽ được trả lại
	  bộ đệm outbuf của dữ liệu được truyền vào đĩa (xem [1])
	  bộ đệm inbuf của dữ liệu sẽ được nhận từ đĩa
	  =====================================================================

lỗi trả về:
	  - Đặc quyền EACCES CAP_SYS_ADMIN hoặc CAP_SYS_RAWIO chưa được đặt.
	  - Thiết bị ENOMSG không phải là ổ đĩa.
	  - ENOMEM Không thể phân bổ bộ nhớ cho tác vụ
	  - EFAULT req_cmd == TASKFILE_IN_OUT (không được triển khai kể từ 2.6.8)
	  -EPERM

req_cmd == TASKFILE_MULTI_OUT và ổ đĩa
			nhiều số chưa được thiết lập.
	  - EIO Drive không thực hiện được lệnh.

ghi chú:

[1] READ THE FOLLOWING NOTES ZZ0000ZZ.  THIS IOCTL LÀ
	  FULL CỦA GOTCHAS.  Cần hết sức thận trọng khi sử dụng
	  ioctl này.  Một sai sót có thể dễ dàng làm hỏng dữ liệu hoặc treo máy
	  hệ thống.

[2] Cả bộ đệm đầu vào và đầu ra đều được sao chép từ
	  người dùng và được viết lại cho người dùng, ngay cả khi không được sử dụng.

[3] Nếu một hoặc nhiều bit được đặt trong out_flags và in_flags là
	  0, các giá trị sau được sử dụng cho in_flags.all và
	  được viết lại thành in_flags khi hoàn thành.

* IDE_TASKFILE_STD_IN_FLAGS | (IDE_HOB_STD_IN_FLAGS << 8)
	     nếu địa chỉ LBA48 được bật cho ổ đĩa
	   * IDE_TASKFILE_STD_IN_FLAGS
	     nếu CHS/LBA28

Sự liên kết giữa in_flags.all và mỗi kích hoạt
	  bitfield lật tùy thuộc vào độ bền; may mắn thay, TASKFILE
	  chỉ sử dụng bit inflags.b.data và bỏ qua tất cả các bit khác.
	  Kết quả cuối cùng là, trên bất kỳ máy endian nào, nó không có
	  có tác dụng khác ngoài việc sửa đổi in_flags khi hoàn thành.

[4] Giá trị mặc định của SELECT là (0xa0|DEV_bit|LBA_bit)
	  ngoại trừ bốn ổ đĩa trên mỗi chipset cổng.  Cho bốn ổ đĩa
	  trên mỗi chipset cổng, giá trị đầu tiên là (0xa0|DEV_bit|LBA_bit)
	  cặp và (0x80|DEV_bit|LBA_bit) cho cặp thứ hai.

[5] Đối số của ioctl là một con trỏ tới một vùng của
	  bộ nhớ chứa cấu trúc ide_task_request_t, theo sau
	  bởi một bộ đệm dữ liệu tùy chọn để truyền tới
	  ổ đĩa, theo sau là bộ đệm tùy chọn để nhận dữ liệu từ
	  ổ đĩa.

Lệnh được truyền tới ổ đĩa thông qua ide_task_request_t
	  cấu trúc, chứa các trường này:

===============================================================
	    giá trị io_ports[8] cho các thanh ghi tệp tác vụ
	    hob_ports[8] byte bậc cao, cho các lệnh mở rộng
	    cờ out_flags cho biết mục nào trong
				mảng io_ports[] và hob_ports[]
				chứa các giá trị hợp lệ.  Nhập ide_reg_valid_t.
	    cờ in_flags cho biết mục nào trong
				mảng io_ports[] và hob_ports[]
				dự kiến ​​sẽ chứa các giá trị hợp lệ
				khi trở về.
	    data_phase Xem bên dưới
	    req_cmd Loại lệnh, xem bên dưới
	    out_size kích thước bộ đệm đầu ra (người dùng-> ổ đĩa), byte
	    kích thước bộ đệm đầu vào in_size (ổ đĩa-> người dùng), byte
	    ===============================================================

Khi out_flags bằng 0, các thanh ghi sau sẽ được tải.

===============================================================
	    HOB_FEATURE Nếu ổ đĩa hỗ trợ LBA48
	    HOB_NSECTOR Nếu ổ đĩa hỗ trợ LBA48
	    HOB_SECTOR Nếu ổ đĩa hỗ trợ LBA48
	    HOB_LCYL Nếu ổ đĩa hỗ trợ LBA48
	    HOB_HCYL Nếu ổ đĩa hỗ trợ LBA48
	    FEATURE
	    NSECTOR
	    SECTOR
	    LCYL
	    HCYL
	    SELECT Đầu tiên, được che bằng 0xE0 nếu LBA48, 0xEF
				mặt khác; sau đó, hoặc theo mặc định
				giá trị của SELECT.
	    ===============================================================

Nếu bất kỳ bit nào trong out_flags được đặt, các thanh ghi sau sẽ được tải.

===============================================================
	    HOB_DATA Nếu out_flags.b.data được đặt.  HOB_DATA sẽ
				di chuyển trên DD8-DD15 trên các máy endian nhỏ
				và trên DD0-DD7 trên các máy endian lớn.
	    DATA Nếu out_flags.b.data được đặt.  DATA sẽ
				di chuyển trên DD0-DD7 trên các máy endian nhỏ
				và trên DD8-DD15 trên các máy endian lớn.
	    HOB_NSECTOR Nếu out_flags.b.nsector_hob được đặt
	    HOB_SECTOR Nếu out_flags.b.sector_hob được đặt
	    HOB_LCYL Nếu out_flags.b.lcyl_hob được đặt
	    HOB_HCYL Nếu out_flags.b.hcyl_hob được đặt
	    FEATURE Nếu out_flags.b.feature được đặt
	    NSECTOR Nếu out_flags.b.nsector được đặt
	    SECTOR Nếu out_flags.b.sector được đặt
	    LCYL Nếu out_flags.b.lcyl được đặt
	    HCYL Nếu out_flags.b.hcyl được đặt
	    SELECT Hoặc có giá trị mặc định là SELECT và
				được tải bất kể out_flags.b.select.
	    ===============================================================

Các thanh ghi taskfile được đọc lại từ ổ đĩa vào
	  {io|hob__ports[] sau khi lệnh hoàn thành nếu một trong các
	  các điều kiện sau được đáp ứng; mặt khác, các giá trị ban đầu
	  sẽ được viết lại, không thay đổi.

1. Ổ đĩa không thực hiện được lệnh (EIO).
	    2. Một hoặc nhiều bit được đặt trong out_flags.
	    3. Data_phase được yêu cầu là TASKFILE_NO_DATA.

===============================================================
	    HOB_DATA Nếu in_flags.b.data được đặt.  Nó sẽ chứa
				DD8-DD15 trên các máy endian nhỏ và
				DD0-DD7 trên các máy endian lớn.
	    DATA Nếu in_flags.b.data được đặt.  Nó sẽ chứa
				DD0-DD7 trên các máy endian nhỏ và
				DD8-DD15 trên các máy endian lớn.
	    HOB_FEATURE Nếu ổ đĩa hỗ trợ LBA48
	    HOB_NSECTOR Nếu ổ đĩa hỗ trợ LBA48
	    HOB_SECTOR Nếu ổ đĩa hỗ trợ LBA48
	    HOB_LCYL Nếu ổ đĩa hỗ trợ LBA48
	    HOB_HCYL Nếu ổ đĩa hỗ trợ LBA48
	    NSECTOR
	    SECTOR
	    LCYL
	    HCYL
	    ===============================================================

Trường data_phase mô tả quá trình truyền dữ liệu
	  được thực hiện.  Giá trị là một trong:

===============================================================
	    TASKFILE_IN
	    TASKFILE_MULTI_IN
	    TASKFILE_OUT
	    TASKFILE_MULTI_OUT
	    TASKFILE_IN_OUT
	    TASKFILE_IN_DMA
	    TASKFILE_IN_DMAQ == IN_DMA (không hỗ trợ xếp hàng)
	    TASKFILE_OUT_DMA
	    TASKFILE_OUT_DMAQ == OUT_DMA (không hỗ trợ xếp hàng)
	    TASKFILE_P_IN chưa được triển khai
	    TASKFILE_P_IN_DMA chưa được triển khai
	    TASKFILE_P_IN_DMAQ chưa được triển khai
	    TASKFILE_P_OUT chưa được triển khai
	    TASKFILE_P_OUT_DMA chưa được triển khai
	    TASKFILE_P_OUT_DMAQ chưa được triển khai
	    ===============================================================

Trường req_cmd phân loại loại lệnh.  Nó có thể là
	  một trong:

=====================================================================
	    IDE_DRIVE_TASK_NO_DATA
	    IDE_DRIVE_TASK_SET_XFER chưa được triển khai
	    IDE_DRIVE_TASK_IN
	    IDE_DRIVE_TASK_OUT chưa được triển khai
	    IDE_DRIVE_TASK_RAW_WRITE
	    =====================================================================

[6] Không truy cập vào {in|out__flags->tất cả ngoại trừ việc đặt lại
	  tất cả các bit.  Luôn truy cập các trường bit riêng lẻ.  ->tất cả
	  giá trị sẽ thay đổi tùy thuộc vào độ bền.  Đối với cùng một
	  lý do, không sử dụng IDE_{TASKFILEZZ0000ZZIN}_FLAGS
	  các hằng số được xác định trong hdreg.h.



HDIO_DRIVE_CMD
	thực hiện một lệnh ổ đĩa đặc biệt


Lưu ý: Nếu bạn không có bản sao thông số kỹ thuật ANSI ATA
	tiện dụng, có lẽ bạn nên bỏ qua ioctl này.

cách sử dụng::

u8 args[4+XFER_SIZE];

	  ...
ioctl(fd, HDIO_DRIVE_CMD, args);

đầu vào:
	    Các lệnh khác WIN_SMART:

======= =======
	    lập luận[0] COMMAND
	    tranh luận[1] NSECTOR
	    lập luận [2] FEATURE
	    tranh luận[3] NSECTOR
	    ======= =======

WIN_SMART:

======= =======
	    lập luận[0] COMMAND
	    tranh luận[1] SECTOR
	    lập luận [2] FEATURE
	    tranh luận[3] NSECTOR
	    ======= =======

đầu ra:
		Bộ đệm args[] chứa đầy các giá trị thanh ghi theo sau là bất kỳ giá trị nào


dữ liệu được đĩa trả về.

=================================================================
	    trạng thái args[0]
	    lỗi args[1]
	    tranh luận[2] NSECTOR
	    đối số [3] không xác định
	    args[4+] NSECTOR * 512 byte dữ liệu được lệnh trả về.
	    =================================================================

lỗi trả về:
	  - Truy cập EACCES bị từ chối: yêu cầu CAP_SYS_RAWIO
	  - ENOMEM Không thể phân bổ bộ nhớ cho tác vụ
	  - EIO Drive báo lỗi

ghi chú:

[1] Đối với các lệnh không phải WIN_SMART, args[1] phải bằng
	  tranh luận [3].  SECTOR, LCYL và HCYL không được xác định.  cho
	  WIN_SMART, 0x4f và 0xc2 được tải vào LCYL và HCYL
	  tương ứng.  Trong cả hai trường hợp SELECT sẽ chứa mặc định
	  giá trị cho ổ đĩa.  Vui lòng tham khảo HDIO_DRIVE_TASKFILE
	  ghi chú về giá trị mặc định của SELECT.

[2] Nếu giá trị NSECTOR lớn hơn 0 và bộ biến tần
	  DRQ khi ngắt lệnh, NSECTOR * 512 byte
	  được đọc từ thiết bị vào khu vực sau NSECTOR.
	  Trong ví dụ trên, diện tích sẽ là
	  args[4..4+XFER_SIZE].  16bit PIO được sử dụng bất kể
	  Cài đặt HDIO_SET_32BIT.

[3] Nếu COMMAND == WIN_SETFEATURES && FEATURE == SETFEATURES_XFER
	  && NSECTOR >= XFER_SW_DMA_0 && ổ đĩa hỗ trợ mọi loại DMA
	  chế độ, trình điều khiển IDE sẽ cố gắng điều chỉnh chế độ truyền của
	  lái xe cho phù hợp.



HDIO_DRIVE_TASK
	thực hiện nhiệm vụ và lệnh ổ đĩa đặc biệt


Lưu ý: Nếu bạn không có bản sao thông số kỹ thuật ANSI ATA
	tiện dụng, có lẽ bạn nên bỏ qua ioctl này.

cách sử dụng::

u8 lập luận[7];

	  ...
ioctl(fd, HDIO_DRIVE_TASK, args);

đầu vào:
	    Giá trị đăng ký tệp tác vụ:

======= =======
	    lập luận[0] COMMAND
	    tranh luận[1] FEATURE
	    lập luận [2] NSECTOR
	    tranh luận[3] SECTOR
	    tranh luận[4] LCYL
	    tranh luận[5] HCYL
	    tranh luận[6] SELECT
	    ======= =======

đầu ra:
	    Giá trị đăng ký tệp tác vụ:


======= =======
	    trạng thái args[0]
	    lỗi args[1]
	    tranh luận[2] NSECTOR
	    tranh luận[3] SECTOR
	    tranh luận[4] LCYL
	    tranh luận[5] HCYL
	    tranh luận[6] SELECT
	    ======= =======

lỗi trả về:
	  - Truy cập EACCES bị từ chối: yêu cầu CAP_SYS_RAWIO
	  - ENOMEM Không thể phân bổ bộ nhớ cho tác vụ
	  - Thiết bị ENOMSG không phải là ổ đĩa.
	  - EIO Drive không thực hiện được lệnh.

ghi chú:

[1] Bit DEV (0x10) của thanh ghi SELECT bị bỏ qua và
	  giá trị thích hợp cho ổ đĩa được sử dụng.  Tất cả các bit khác
	  được sử dụng không thay đổi.



HDIO_SET_32BIT
	thay đổi cờ io_32bit


cách sử dụng::

int giá trị;

ioctl(fd, HDIO_SET_32BIT, val);

đầu vào:
		Giá trị mới cho cờ io_32bit



đầu ra:
		không có



trả về lỗi:
	  - EINVAL Được gọi trên một phân vùng thay vì toàn bộ thiết bị đĩa
	  - EACCES Truy cập bị từ chối: yêu cầu CAP_SYS_ADMIN
	  - Giá trị EINVAL nằm ngoài phạm vi [0 3]
	  - Bộ điều khiển EBUSY bận
