.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/parport-lowlevel.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================
Tài liệu giao diện PARPORT
===============================

:Dấu thời gian: <2000-02-24 13:30:20 twaugh>

Được mô tả ở đây là các chức năng sau:

Chức năng toàn cầu::

parport_register_driver
  parport_unregister_driver
  parport_enumerate
  parport_register_device
  parport_unregister_device
  parport_claim
  parport_claim_or_block
  parport_release
  parport_yield
  parport_yield_blocking
  parport_wait_peripheral
  parport_poll_peripheral
  parport_wait_event
  parport_negotiate
  parport_read
  parport_write
  parport_open
  parport_close
  parport_device_id
  parport_device_coords
  parport_find_class
  parport_find_device
  parport_set_timeout

Chức năng cổng (có thể bị ghi đè bởi trình điều khiển cấp thấp):

SPP::

cổng->ops->read_data
    cổng->ops->write_data
    cổng->ops->read_status
    cổng->ops->read_control
    cổng->ops->write_control
    cổng->ops->frob_control
    cổng->ops->enable_irq
    cổng->ops->disable_irq
    cổng->ops->data_forward
    cổng->ops->data_reverse

EPP::

cổng->ops->epp_write_data
    cổng->ops->epp_read_data
    cổng->ops->epp_write_addr
    cổng->ops->epp_read_addr

ECP::

cổng->ops->ecp_write_data
    cổng->ops->ecp_read_data
    cổng->ops->ecp_write_addr

Khác::

cổng->ops->nibble_read_data
    cổng->ops->byte_read_data
    cổng->ops->compat_write_data

Hệ thống con parport bao gồm ZZ0000ZZ (hệ thống chia sẻ cổng cốt lõi
mã) và nhiều trình điều khiển cấp thấp thực sự thực hiện chuyển đổi
truy cập.  Mỗi trình điều khiển cấp thấp xử lý một kiểu cổng cụ thể
(PC, Amiga, v.v.).

Giao diện parport cho tác giả trình điều khiển thiết bị có thể được chia nhỏ
vào các chức năng toàn cầu và chức năng cổng.

Các chức năng chung chủ yếu là để liên lạc giữa thiết bị
trình điều khiển và hệ thống con parport: lấy danh sách các cổng có sẵn,
yêu cầu một cổng để sử dụng độc quyền, v.v.  Họ cũng bao gồm
ZZ0000ZZ có chức năng thực hiện những công việc tiêu chuẩn sẽ hoạt động trên mọi thiết bị.
Kiến trúc có khả năng IEEE 1284.

Các chức năng cổng được cung cấp bởi trình điều khiển cấp thấp, mặc dù
mô-đun parport cốt lõi cung cấp ZZ0000ZZ chung cho một số quy trình.
Các chức năng cổng có thể được chia thành ba nhóm: SPP, EPP và ECP.

Các chức năng SPP (Cổng song song tiêu chuẩn) sửa đổi cái gọi là ZZ0000ZZ
thanh ghi: dữ liệu, trạng thái và điều khiển.  Phần cứng có thể không thực sự
có các thanh ghi chính xác như vậy, nhưng PC thì có và giao diện này
được mô phỏng theo cách triển khai PC thông thường.  Các trình điều khiển cấp thấp khác có thể
có thể mô phỏng hầu hết các chức năng.

Các chức năng EPP (Cổng song song nâng cao) được cung cấp để đọc và
viết ở chế độ IEEE 1284 EPP và ECP (Cổng khả năng mở rộng)
các chức năng được sử dụng cho chế độ IEEE 1284 ECP. (Còn BECP thì sao?
có ai quan tâm không?)

Hỗ trợ phần cứng cho việc chuyển EPP và/hoặc ECP có thể có hoặc không
có sẵn và nếu có thì có thể sử dụng hoặc không.  Nếu
phần cứng không được sử dụng, quá trình truyền sẽ được thực hiện bằng phần mềm.  theo thứ tự
để đối phó với các thiết bị ngoại vi chỉ hỗ trợ IEEE 1284 một cách mỏng manh,
chức năng cụ thể của trình điều khiển cấp thấp được cung cấp để thay đổi 'fudge'
các yếu tố'.


Chức năng toàn cầu
================

parport_register_driver - đăng ký trình điều khiển thiết bị với parport
---------------------------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

cấu trúc parport_driver {
		const char *tên;
		khoảng trống (ZZ0000ZZ);
		khoảng trống (ZZ0001ZZ);
		struct parport_driver *next;
	};
	int parport_register_driver (struct parport_driver *driver);

DESCRIPTION
^^^^^^^^^^^

Để được thông báo về các cổng song song khi chúng được phát hiện,
parport_register_driver nên được gọi.  Tài xế của bạn sẽ
ngay lập tức được thông báo về tất cả các cổng đã được phát hiện,
và của mỗi cổng mới khi trình điều khiển cấp thấp được tải.

ZZ0000ZZ chứa tên văn bản của trình điều khiển của bạn,
một con trỏ tới một hàm để xử lý các cổng mới và một con trỏ tới một
chức năng xử lý các cổng bị mất do trình điều khiển cấp thấp
đang dỡ hàng.  Các cổng sẽ chỉ được tách ra nếu chúng không được sử dụng
(tức là không có thiết bị nào được đăng ký trên chúng).

Các phần hiển thị của đối số ZZ0000ZZ được cung cấp cho
đính kèm/tháo là::

cấu trúc sân bay
	{
		struct parport ZZ0000ZZ parport tiếp theo trong danh sách */
		const char Tên cổng ZZ0001ZZ */
		chế độ int không dấu;   /* bitfield của chế độ phần cứng */
		cấu trúc parport_device_info thăm dò_info;
				/* Thông tin IEEE1284 */
		số int;           /*chỉ số hành lý */
		struct parport_Operation *ops;
		...
	};

Có những thành viên khác của cấu trúc, nhưng họ không nên
chạm vào.

Thành viên ZZ0000ZZ tóm tắt các khả năng của cơ sở
phần cứng.  Nó bao gồm các cờ có thể được kết hợp theo bit với nhau:

==================================================================================
  Các thanh ghi PC PARPORT_MODE_PCSPP IBM có sẵn,
				tức là các chức năng hoạt động trên dữ liệu,
				các thanh ghi điều khiển và trạng thái được
				có lẽ viết trực tiếp cho
				phần cứng.
  PARPORT_MODE_TRISTATE Trình điều khiển dữ liệu có thể bị tắt.
				Điều này cho phép các dòng dữ liệu được sử dụng
				để đảo ngược (ngoại vi với máy chủ)
				chuyển khoản.
  PARPORT_MODE_COMPAT Phần cứng có thể hỗ trợ
				chế độ tương thích (máy in)
				chuyển, tức là compat_write_block.
  PARPORT_MODE_EPP Phần cứng có thể hỗ trợ EPP
				chuyển khoản.
  PARPORT_MODE_ECP Phần cứng có thể hỗ trợ ECP
				chuyển khoản.
  PARPORT_MODE_DMA Phần cứng có thể sử dụng DMA, vì vậy bạn có thể
				muốn vượt qua bộ nhớ có thể sử dụng ISA DMA
				(tức là bộ nhớ được phân bổ bằng cách sử dụng
				Cờ GFP_DMA với kmalloc) tới
				trình điều khiển cấp thấp để thực hiện
				lợi thế của nó.
  ==================================================================================

Có thể còn có các cờ khác trong ZZ0000ZZ.

Nội dung của ZZ0000ZZ chỉ mang tính chất tư vấn.  Ví dụ, nếu
phần cứng có khả năng DMA và PARPORT_MODE_DMA có khả năng ZZ0001ZZ, nó
không nhất thiết có nghĩa là DMA sẽ luôn được sử dụng khi có thể.
Tương tự, phần cứng có khả năng hỗ trợ chuyển ECP sẽ không
nhất thiết phải được sử dụng.

RETURN VALUE
^^^^^^^^^^^^

Không thành công, nếu không thì sẽ có mã lỗi.

ERRORS
^^^^^^

Không có. (Nó có thể thất bại không? Tại sao lại trả về int?)

EXAMPLE
^^^^^^^

::

static void lp_attach (struct parport *port)
	{
		...
riêng tư = kmalloc (...);
		dev[count++] = parport_register_device (...);
		...
	}

static void lp_detach (struct parport *port)
	{
		...
	}

cấu trúc tĩnh parport_driver lp_driver = {
		"lp",
		lp_đính kèm,
		lp_detach,
		NULL /* luôn đặt NULL ở đây */
	};

int lp_init (void)
	{
		...
if (parport_register_driver (&lp_driver)) {
			/* Thất bại; chúng tôi không thể làm gì được. */
			trả về -EIO;
		}
		...
	}


SEE ALSO
^^^^^^^^

parport_unregister_driver, parport_register_device, parport_enumerate



parport_unregister_driver - yêu cầu parport quên trình điều khiển này
--------------------------------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

cấu trúc parport_driver {
		const char *tên;
		khoảng trống (ZZ0000ZZ);
		khoảng trống (ZZ0001ZZ);
		struct parport_driver *next;
	};
	void parport_unregister_driver (struct parport_driver *driver);

DESCRIPTION
^^^^^^^^^^^

Điều này yêu cầu parport không thông báo cho trình điều khiển thiết bị về các cổng mới hoặc về
các cổng sẽ biến mất.  Các thiết bị đã đăng ký thuộc trình điều khiển đó là NOT
chưa đăng ký: parport_unregister_device phải được sử dụng cho mỗi thiết bị.

EXAMPLE
^^^^^^^

::

void cleanup_module (void)
	{
		...
/* Dừng thông báo. */
		parport_unregister_driver (&lp_driver);

/* Hủy đăng ký thiết bị. */
		với (i = 0; tôi < NUM_DEVS; i++)
			parport_unregister_device (dev[i]);
		...
	}

SEE ALSO
^^^^^^^^

parport_register_driver, parport_enumerate



parport_enumerate - lấy danh sách các cổng song song (DEPRECATED)
------------------------------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

struct parport *parport_enumerate (void);

DESCRIPTION
^^^^^^^^^^^

Truy xuất cổng đầu tiên trong danh sách các cổng song song hợp lệ cho máy này.
Các cổng song song kế tiếp có thể được tìm thấy bằng cách sử dụng phần tử ZZ0000ZZ của ZZ0001ZZ được trả về.  Nếu ZZ0002ZZ
là NULL, không còn cổng song song nào trong danh sách nữa.  Số lượng
các cổng trong danh sách sẽ không vượt quá PARPORT_MAX.

RETURN VALUE
^^^^^^^^^^^^

ZZ0000ZZ mô tả cổng song song hợp lệ cho máy,
hoặc NULL nếu không có.

ERRORS
^^^^^^

Hàm này có thể trả về NULL để chỉ ra rằng không có sự song song
cổng để sử dụng.

EXAMPLE
^^^^^^^

::

int detect_device (void)
	{
		struct parport *port;

cho (port = parport_enumerate ();
		cổng != NULL;
		cổng = cổng-> tiếp theo) {
			/* Cố gắng phát hiện thiết bị trên cổng... */
			...
		}
		}

		...
	}

NOTES
^^^^^

parport_enumerate không được dùng nữa; parport_register_driver phải là
được sử dụng thay thế.

SEE ALSO
^^^^^^^^

parport_register_driver, parport_unregister_driver



parport_register_device - đăng ký để sử dụng một cổng
------------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

typedef int (*preempt_func) (void *handle);
	khoảng trống typedef (*wakeup_func) (void *handle);
	typedef int (*irq_func) (int irq, void *handle, struct pt_regs *);

cấu trúc pardevice *parport_register_device(struct parport *port,
						  const char * tên,
						  ưu tiên_func ưu tiên,
						  Wakeup_func thức dậy,
						  irq_func irq,
						  cờ int,
						  void *xử lý);

DESCRIPTION
^^^^^^^^^^^

Sử dụng chức năng này để đăng ký trình điều khiển thiết bị của bạn trên cổng song song
(ZZ0000ZZ).  Một khi bạn đã làm điều đó, bạn sẽ có thể sử dụng
parport_claim và parport_release để sử dụng cổng.

Đối số (ZZ0000ZZ) là tên của thiết bị xuất hiện trong /proc
hệ thống tập tin. Chuỗi phải hợp lệ trong suốt thời gian tồn tại của chuỗi
thiết bị (cho đến khi parport_unregister_device được gọi).

Hàm này sẽ đăng ký ba lệnh gọi lại vào trình điều khiển của bạn:
ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ.  Mỗi trong số này có thể là NULL để
cho biết rằng bạn không muốn gọi lại.

Khi chức năng ZZ0000ZZ được gọi, đó là do trình điều khiển khác
mong muốn sử dụng cổng song song.  Hàm ZZ0001ZZ sẽ trả về
khác 0 nếu cổng song song chưa thể được giải phóng -- nếu bằng 0
được trả lại, cổng sẽ bị mất vào tay trình điều khiển khác và cổng đó phải được
được yêu cầu lại trước khi sử dụng.

Chức năng ZZ0000ZZ được gọi khi trình điều khiển khác đã giải phóng
port và chưa có tài xế nào khác xác nhận.  Bạn có thể yêu cầu
cổng song song từ bên trong chức năng ZZ0001ZZ (trong trường hợp đó
yêu cầu được đảm bảo thành công) hoặc chọn không thực hiện nếu bạn không cần
bây giờ.

Nếu xảy ra gián đoạn trên cổng song song mà trình điều khiển của bạn đã yêu cầu,
hàm ZZ0000ZZ sẽ được gọi. (Viết đôi điều về chia sẻ
ngắt ở đây.)

ZZ0000ZZ là một con trỏ tới dữ liệu dành riêng cho trình điều khiển và được chuyển tới
các chức năng gọi lại.

ZZ0000ZZ có thể là sự kết hợp bitwise của các cờ sau:

============================================================================
        Ý nghĩa cờ
  ============================================================================
  PARPORT_DEV_EXCL Thiết bị hoàn toàn không thể chia sẻ cổng song song.
			Chỉ sử dụng điều này khi thực sự cần thiết.
  ============================================================================

Các typedef không thực sự được xác định - chúng chỉ được hiển thị theo thứ tự
để làm cho nguyên mẫu hàm dễ đọc hơn.

Các phần có thể nhìn thấy của ZZ0000ZZ được trả về là::

cấu trúc pardevice {
		struct parport ZZ0000ZZ Cổng liên kết */
		void ZZ0001ZZ 'tay cầm' của trình điều khiển thiết bị */
		...
	};

RETURN VALUE
^^^^^^^^^^^^

A ZZ0000ZZ: tay cầm cho cổng song song đã đăng ký
thiết bị có thể được sử dụng cho parport_claim, parport_release, v.v.

ERRORS
^^^^^^

Giá trị trả về của NULL cho biết đã xảy ra sự cố khi đăng ký
một thiết bị trên cổng đó.

EXAMPLE
^^^^^^^

::

ưu tiên int tĩnh (void *xử lý)
	{
		nếu (busy_right_now)
			trả về 1;

must_reclaim_port = 1;
		trả về 0;
	}

đánh thức void tĩnh (void *xử lý)
	{
		struct nướng bánh mì *private = xử lý;
		struct pardevice *dev = Private->dev;
		if (!dev) trả về; /* tránh các cuộc đua */

nếu (muốn_port)
			parport_claim (dev);
	}

static int toaster_ detect (struct toaster *private, struct parport *port)
	{
		riêng tư->dev = parport_register_device (cổng, "máy nướng bánh mỳ", ưu tiên,
							thức dậy, NULL, 0,
							riêng tư);
		if (!private->dev)
			/* Không thể đăng ký với parport. */
			trả về -EIO;

must_reclaim_port = 0;
		bận_right_now = 1;
		parport_claim_or_block (riêng tư->nhà phát triển);
		...
/* Không cần cổng khi máy nướng bánh mì nóng lên. */
		bận_right_now = 0;
		...
bận_right_now = 1;
		nếu (must_reclaim_port) {
			parport_claim_or_block (riêng tư->nhà phát triển);
			must_reclaim_port = 0;
		}
		...
	}

SEE ALSO
^^^^^^^^

parport_unregister_device, parport_claim




parport_unregister_device - kết thúc bằng cách sử dụng một cổng
-----------------------------------------------

SYNPOPSIS

::

#include <linux/parport.h>

void parport_unregister_device (struct pardevice *dev);

DESCRIPTION
^^^^^^^^^^^

Hàm này ngược lại với parport_register_device.  Sau khi sử dụng
parport_unregister_device, ZZ0000ZZ không còn là bộ điều khiển thiết bị hợp lệ.

Bạn không nên hủy đăng ký thiết bị hiện đã được xác nhận quyền sở hữu, mặc dù
nếu bạn làm vậy nó sẽ được phát hành tự động.

EXAMPLE
^^^^^^^

::

	...
kfree (dev->riêng tư); /* trước khi mất con trỏ */
	parport_unregister_device (dev);
	...

SEE ALSO
^^^^^^^^


parport_unregister_driver


parport_claim, parport_claim_or_block - yêu cầu cổng song song cho thiết bị
----------------------------------------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

int parport_claim (struct pardevice *dev);
	int parport_claim_or_block (struct pardevice *dev);

DESCRIPTION
^^^^^^^^^^^

Các chức năng này cố gắng giành quyền kiểm soát cổng song song mà trên đó
ZZ0000ZZ đã được đăng ký.  ZZ0001ZZ không chặn, nhưng
ZZ0002ZZ có thể làm được. (Đặt điều gì đó ở đây về việc chặn
gián đoạn hoặc không gián đoạn.)

Bạn không nên cố gắng yêu cầu một cổng mà bạn đã yêu cầu.

RETURN VALUE
^^^^^^^^^^^^

Giá trị trả về bằng 0 cho biết cổng đã thành công
được yêu cầu và người gọi hiện có quyền sở hữu cổng song song.

Nếu ZZ0000ZZ chặn trước khi quay lại thành công,
giá trị trả về là dương.

ERRORS
^^^^^^

=========================================================================
  -EAGAIN Cổng này hiện không khả dụng nhưng hãy thử lại
           để khẳng định nó có thể thành công.
=========================================================================

SEE ALSO
^^^^^^^^


parport_release


parport_release - giải phóng cổng song song
-------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

void parport_release (struct pardevice *dev);

DESCRIPTION
^^^^^^^^^^^

Khi một thiết bị cổng song song đã được xác nhận, nó có thể được giải phóng bằng cách sử dụng
ZZ0000ZZ.  Nó không thể thất bại, nhưng bạn không nên phát hành một
thiết bị mà bạn không sở hữu.

EXAMPLE
^^^^^^^

::

ghi size_t tĩnh (struct pardevice *dev, const void *buf,
			size_t len)
	{
		...
viết = dev->port->ops->write_ecp_data (dev->port, buf,
							len);
		parport_release (dev);
		...
	}


SEE ALSO
^^^^^^^^

Change_mode, parport_claim, parport_claim_or_block, parport_yield



parport_yield, parport_yield_blocking - tạm thời giải phóng một cổng song song
---------------------------------------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

int parport_yield (struct pardevice *dev)
	int parport_yield_blocking (struct pardevice *dev);

DESCRIPTION
^^^^^^^^^^^

Khi trình điều khiển có quyền kiểm soát một cổng song song, nó có thể cho phép một cổng khác
driver tạm thời vào ZZ0000ZZ nó.  ZZ0001ZZ không chặn;
ZZ0002ZZ có thể làm được.

RETURN VALUE
^^^^^^^^^^^^

Giá trị trả về bằng 0 cho biết người gọi vẫn sở hữu cổng
và cuộc gọi không bị chặn.

Giá trị trả về dương từ ZZ0000ZZ chỉ ra rằng
người gọi vẫn sở hữu cổng và cuộc gọi bị chặn.

Giá trị trả về -EAGAIN cho biết người gọi không còn sở hữu
cổng và nó phải được xác nhận lại trước khi sử dụng.

ERRORS
^^^^^^

========================================================================
  -EAGAIN Quyền sở hữu cổng song song đã được trao đi.
========================================================================

SEE ALSO
^^^^^^^^

parport_release




parport_wait_peripheral - chờ dòng trạng thái, tối đa 35ms
-----------------------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

int parport_wait_peripheral (struct parport *port,
				     mặt nạ char không dấu,
				     giá trị char không dấu);

DESCRIPTION
^^^^^^^^^^^

Đợi các dòng trạng thái trong mặt nạ khớp với các giá trị trong val.

RETURN VALUE
^^^^^^^^^^^^

========================================================================
 -EINTR một tín hiệu đang chờ xử lý
      0 các dòng trạng thái trong mặt nạ có giá trị bằng val
      Đã hết thời gian 1 lần trong khi chờ đợi (đã hết 35 mili giây)
========================================================================

SEE ALSO
^^^^^^^^

parport_poll_peripheral




parport_poll_peripheral - chờ dòng trạng thái, trong usec
--------------------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

int parport_poll_peripheral (struct parport *port,
				     mặt nạ char không dấu,
				     giá trị char không dấu,
				     int usec);

DESCRIPTION
^^^^^^^^^^^

Đợi các dòng trạng thái trong mặt nạ khớp với các giá trị trong val.

RETURN VALUE
^^^^^^^^^^^^

========================================================================
 -EINTR một tín hiệu đang chờ xử lý
      0 các dòng trạng thái trong mặt nạ có giá trị bằng val
      Đã hết thời gian 1 lần trong khi chờ đợi (usec micro giây đã trôi qua)
========================================================================

SEE ALSO
^^^^^^^^

parport_wait_peripheral



parport_wait_event - chờ sự kiện trên một cổng
------------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

int parport_wait_event (struct parport *port, đã ký thời gian chờ dài)

DESCRIPTION
^^^^^^^^^^^

Đợi một sự kiện (ví dụ: ngắt) trên một cổng.  Đã hết thời gian chờ
nháy mắt.

RETURN VALUE
^^^^^^^^^^^^

======= ===============================================================
      0 thành công
     <0 lỗi (thoát càng sớm càng tốt)
     >0 đã hết thời gian chờ
======= ===============================================================

parport_negotiate - thực hiện đàm phán IEEE 1284
-------------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

int parport_negotiate (struct parport *, chế độ int);

DESCRIPTION
^^^^^^^^^^^

Thực hiện đàm phán IEEE 1284.

RETURN VALUE
^^^^^^^^^^^^

======= ===============================================================
     0 cái bắt tay OK; IEEE 1284 ngoại vi và chế độ có sẵn
    -1 lần bắt tay không thành công; thiết bị ngoại vi không tuân thủ (hoặc không có)
     1 cái bắt tay là được; IEEE 1284 có ngoại vi nhưng không có chế độ
        có sẵn
======= ===============================================================

SEE ALSO
^^^^^^^^

parport_read, parport_write



parport_read - đọc dữ liệu từ thiết bị
------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

ssize_t parport_read (struct parport *, void *buf, size_t len);

DESCRIPTION
^^^^^^^^^^^

Đọc dữ liệu từ thiết bị ở chế độ truyền IEEE 1284 hiện tại.  Chỉ điều này
hoạt động ở các chế độ hỗ trợ truyền dữ liệu ngược.

RETURN VALUE
^^^^^^^^^^^^

Nếu âm tính thì mã lỗi; nếu không thì số byte được truyền.

SEE ALSO
^^^^^^^^

parport_write, parport_negotiate



parport_write - ghi dữ liệu vào thiết bị
------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

ssize_t parport_write (struct parport *, const void *buf, size_t len);

DESCRIPTION
^^^^^^^^^^^

Ghi dữ liệu vào thiết bị ở chế độ truyền IEEE 1284 hiện tại.  Chỉ điều này
hoạt động cho các chế độ hỗ trợ truyền dữ liệu chuyển tiếp.

RETURN VALUE
^^^^^^^^^^^^

Nếu âm tính thì mã lỗi; nếu không thì số byte được truyền.

SEE ALSO
^^^^^^^^

parport_read, parport_negotiate




parport_open - đăng ký thiết bị cho số thiết bị cụ thể
-----------------------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

cấu trúc pardevice *parport_open (int devnum, const char *name,
				        int (ZZ0001ZZ),
					khoảng trống (ZZ0002ZZ),
					khoảng trống (ZZ0003ZZ,
						      cấu trúc pt_regs *),
					cờ int, void *xử lý);

DESCRIPTION
^^^^^^^^^^^

Điều này giống như parport_register_device nhưng thay vào đó lấy số thiết bị
của một con trỏ tới một cổng struct.

RETURN VALUE
^^^^^^^^^^^^

Xem parport_register_device.  Nếu không có thiết bị nào được liên kết với devnum,
NULL được trả lại.

SEE ALSO
^^^^^^^^

parport_register_device



parport_close - hủy đăng ký thiết bị cho số thiết bị cụ thể
--------------------------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

void parport_close (struct pardevice *dev);

DESCRIPTION
^^^^^^^^^^^

Điều này tương đương với parport_unregister_device cho parport_open.

SEE ALSO
^^^^^^^^

parport_unregister_device, parport_open



parport_device_id - lấy ID thiết bị IEEE 1284
----------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

ssize_t parport_device_id (int devnum, char *buffer, size_t len);

DESCRIPTION
^^^^^^^^^^^

Lấy ID thiết bị IEEE 1284 được liên kết với một thiết bị nhất định.

RETURN VALUE
^^^^^^^^^^^^

Nếu âm tính thì mã lỗi; mặt khác, số byte bộ đệm
có chứa ID thiết bị.  Định dạng của ID thiết bị là
sau::

[độ dài][ID]

Hai byte đầu tiên biểu thị độ dài bao gồm của toàn bộ Thiết bị
ID và theo thứ tự lớn.  ID là một chuỗi các cặp
hình thức::

khóa:giá trị;

NOTES
^^^^^

Nhiều thiết bị có ID thiết bị IEEE 1284 không đúng định dạng.

SEE ALSO
^^^^^^^^

parport_find_class, parport_find_device



parport_device_coords - chuyển đổi số thiết bị sang tọa độ thiết bị
-------------------------------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

int parport_device_coords (int devnum, int *parport, int *mux,
				   int *cúc);

DESCRIPTION
^^^^^^^^^^^

Chuyển đổi giữa số thiết bị (dựa trên số 0) và tọa độ thiết bị
(cổng, bộ ghép kênh, địa chỉ chuỗi nối tiếp).

RETURN VALUE
^^^^^^^^^^^^

Không thành công, trong trường hợp đó tọa độ là (ZZ0000ZZ, ZZ0001ZZ,
ZZ0002ZZ).

SEE ALSO
^^^^^^^^

parport_open, parport_device_id



parport_find_class - tìm thiết bị theo lớp của nó
-----------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

typedef enum {
		PARPORT_CLASS_LEGACY = 0, /* Thiết bị không phải IEEE1284 */
		PARPORT_CLASS_PRINTER,
		PARPORT_CLASS_MODEM,
		PARPORT_CLASS_NET,
		PARPORT_CLASS_HDC, /* Bộ điều khiển đĩa cứng */
		PARPORT_CLASS_PCMCIA,
		PARPORT_CLASS_MEDIA, /* Thiết bị đa phương tiện */
		PARPORT_CLASS_FDC, /* Bộ điều khiển đĩa mềm */
		PARPORT_CLASS_PORTS,
		PARPORT_CLASS_SCANNER,
		PARPORT_CLASS_DIGCAM,
		PARPORT_CLASS_OTHER, /* Còn gì nữa */
		PARPORT_CLASS_UNSPEC, /* Không có trường CLS trong ID */
		PARPORT_CLASS_SCSIADAPTER
	} parport_device_class;

int parport_find_class (parport_device_class cls, int từ);

DESCRIPTION
^^^^^^^^^^^

Tìm thiết bị theo lớp.  Việc tìm kiếm bắt đầu từ số thiết bị từ +1.

RETURN VALUE
^^^^^^^^^^^^

Số thiết bị của thiết bị tiếp theo trong lớp đó hoặc -1 nếu không có
thiết bị tồn tại.

NOTES
^^^^^

Ví dụ sử dụng::

int devnum = -1;
	while ((devnum = parport_find_class (PARPORT_CLASS_DIGCAM, devnum)) != -1) {
		struct pardevice *dev = parport_open(devnum, ...);
		...
	}

SEE ALSO
^^^^^^^^

parport_find_device, parport_open, parport_device_id



parport_find_device - tìm thiết bị theo lớp của nó
------------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

int parport_find_device (const char *mfg, const char *mdl, int từ);

DESCRIPTION
^^^^^^^^^^^

Tìm thiết bị theo nhà cung cấp và kiểu máy.  Việc tìm kiếm bắt đầu từ thiết bị
số từ +1.

RETURN VALUE
^^^^^^^^^^^^

Số thiết bị của thiết bị tiếp theo phù hợp với thông số kỹ thuật hoặc
-1 nếu không có thiết bị như vậy tồn tại.

NOTES
^^^^^

Ví dụ sử dụng::

int devnum = -1;
	while ((devnum = parport_find_device ("IOMEGA", "ZIP+", devnum)) != -1) {
		struct pardevice *dev = parport_open(devnum, ...);
		...
	}

SEE ALSO
^^^^^^^^

parport_find_class, parport_open, parport_device_id




parport_set_timeout - đặt thời gian chờ không hoạt động
------------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

parport_set_timeout dài (struct pardevice *dev, không hoạt động trong thời gian dài);

DESCRIPTION
^^^^^^^^^^^

Đặt thời gian chờ không hoạt động trong nháy mắt cho thiết bị đã đăng ký.  các
thời gian chờ trước đó được trả lại.

RETURN VALUE
^^^^^^^^^^^^

Thời gian chờ trước đó, trong nháy mắt.

NOTES
^^^^^

Một số chức năng port->ops cho một parport có thể mất thời gian do
độ trễ ở ngoại vi.  Sau khi thiết bị ngoại vi không phản hồi
ZZ0000ZZ trong nháy mắt, thời gian chờ sẽ xảy ra và chức năng chặn
sẽ trở lại.

Thời gian chờ là 0 giây là trường hợp đặc biệt: hàm phải thực hiện nhiều việc
vì nó có thể mà không chặn hoặc để phần cứng ở một nơi không xác định
trạng thái.  Nếu các hoạt động của cổng được thực hiện từ bên trong một ngắt
chẳng hạn, nên sử dụng thời gian chờ là 0 giây.

Sau khi được đặt cho thiết bị đã đăng ký, thời gian chờ sẽ vẫn ở mức đã đặt
giá trị cho đến khi được thiết lập lại.

SEE ALSO
^^^^^^^^

cổng->ops->xxx_read/write_yyy




PORT FUNCTIONS
==============

Các hàm trong cấu trúc port->ops (struct parport_Operations)
được cung cấp bởi trình điều khiển cấp thấp chịu trách nhiệm về cổng đó.

port->ops->read_data - đọc thanh ghi dữ liệu
---------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

cấu trúc parport_Operation {
		...
ký tự không dấu (*read_data) (struct parport *port);
		...
	};

DESCRIPTION
^^^^^^^^^^^

Nếu chế độ cổng-> chứa cờ PARPORT_MODE_TRISTATE và
Bit PARPORT_CONTROL_DIRECTION trong thanh ghi điều khiển được thiết lập, điều này
trả về giá trị trên các chân dữ liệu.  Nếu cổng-> chế độ chứa
Cờ PARPORT_MODE_TRISTATE và bit PARPORT_CONTROL_DIRECTION là
không được đặt, giá trị trả về _có thể_ là giá trị cuối cùng được ghi vào dữ liệu
đăng ký.  Nếu không thì giá trị trả về không được xác định.

SEE ALSO
^^^^^^^^

ghi_dữ liệu, trạng thái đọc, điều khiển ghi




port->ops->write_data - ghi vào thanh ghi dữ liệu
-----------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

cấu trúc parport_Operation {
		...
void (*write_data) (struct parport *port, ký tự không dấu d);
		...
	};

DESCRIPTION
^^^^^^^^^^^

Ghi vào thanh ghi dữ liệu.  Có thể có tác dụng phụ (xung STROBE,
chẳng hạn).

SEE ALSO
^^^^^^^^

đọc_dữ liệu, trạng thái đọc, điều khiển ghi




port->ops->read_status - đọc thanh ghi trạng thái
-------------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

cấu trúc parport_Operation {
		...
ký tự không dấu (*read_status) (struct parport *port);
		...
	};

DESCRIPTION
^^^^^^^^^^^

Đọc từ thanh ghi trạng thái.  Đây là một mặt nạ bit:

- PARPORT_STATUS_ERROR (lỗi máy in, "nFault")
- PARPORT_STATUS_SELECT (trực tuyến, "Chọn")
- PARPORT_STATUS_PAPEROUT (không có giấy, "PError")
- PARPORT_STATUS_ACK (bắt tay, "nAck")
- PARPORT_STATUS_BUSY (bận, "Bận")

Có thể có các bit khác được đặt.

SEE ALSO
^^^^^^^^

đọc_dữ liệu, ghi_dữ liệu, ghi_control




port->ops->read_control - đọc thanh ghi điều khiển
---------------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

cấu trúc parport_Operation {
		...
ký tự không dấu (*read_control) (struct parport *port);
		...
	};

DESCRIPTION
^^^^^^^^^^^

Trả về giá trị cuối cùng được ghi vào thanh ghi điều khiển (hoặc từ
write_control hoặc Frob_control).  Không có quyền truy cập cổng được thực hiện.

SEE ALSO
^^^^^^^^

đọc_dữ liệu, ghi_dữ liệu, read_status, write_control




port->ops->write_control - ghi thanh ghi điều khiển
-----------------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

cấu trúc parport_Operation {
		...
void (*write_control) (struct parport *port, unsigned char s);
		...
	};

DESCRIPTION
^^^^^^^^^^^

Ghi vào thanh ghi điều khiển. Đây là một mặt nạ bit::

_______
	- PARPORT_CONTROL_STROBE (nNhấp nháy)
				  _______
	- PARPORT_CONTROL_AUTOFD (nAutoFd)
				_____
	- PARPORT_CONTROL_INIT (nInit)
				  _________
	-PARPORT_CONTROL_SELECT (nSelectIn)

SEE ALSO
^^^^^^^^

dữ liệu đọc, dữ liệu ghi, trạng thái đọc, điều khiển từ xa




port->ops->frob_control - ghi các bit thanh ghi điều khiển
-----------------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

cấu trúc parport_Operation {
		...
ký tự không dấu (*frob_control) (struct parport *port,
					mặt nạ char không dấu,
					giá trị char không dấu);
		...
	};

DESCRIPTION
^^^^^^^^^^^

Điều này tương đương với việc đọc từ thanh ghi điều khiển, loại bỏ
các bit trong mặt nạ, độc quyền hoặc với các bit trong val và ghi
kết quả vào thanh ghi điều khiển.

Vì một số cổng không cho phép đọc từ cổng điều khiển nên bản sao phần mềm
nội dung của nó được duy trì, do đó, trên thực tế, Frob_control chỉ là một
truy cập cổng.

SEE ALSO
^^^^^^^^

đọc_dữ liệu, ghi_dữ liệu, read_status, write_control




port->ops->enable_irq - cho phép tạo ngắt
---------------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

cấu trúc parport_Operation {
		...
khoảng trống (*enable_irq) (struct parport *port);
		...
	};

DESCRIPTION
^^^^^^^^^^^

Phần cứng cổng song song được hướng dẫn tạo ra các ngắt tại
những khoảnh khắc thích hợp, mặc dù những khoảnh khắc đó là
kiến trúc cụ thể.  Đối với kiến trúc PC, các ngắt được
thường được tạo ra ở cạnh lên của nAck.

SEE ALSO
^^^^^^^^

vô hiệu hóa_irq




port->ops->disable_irq - vô hiệu hóa việc tạo ngắt
-----------------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

cấu trúc parport_Operation {
		...
khoảng trống (*disable_irq) (struct parport *port);
		...
	};

DESCRIPTION
^^^^^^^^^^^

Phần cứng cổng song song được hướng dẫn không tạo ra các ngắt.
Bản thân sự gián đoạn không bị che dấu.

SEE ALSO
^^^^^^^^

kích hoạt_irq




port->ops->data_forward - bật trình điều khiển dữ liệu
---------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

cấu trúc parport_Operation {
		...
khoảng trống (*data_forward) (struct parport *port);
		...
	};

DESCRIPTION
^^^^^^^^^^^

Kích hoạt trình điều khiển dòng dữ liệu, dành cho máy chủ đến thiết bị ngoại vi 8 bit
thông tin liên lạc.

SEE ALSO
^^^^^^^^

dữ liệu_reverse




port->ops->data_reverse - xử lý bộ đệm
---------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

cấu trúc parport_Operation {
		...
khoảng trống (*data_reverse) (struct parport *port);
		...
	};

DESCRIPTION
^^^^^^^^^^^

Đặt bus dữ liệu ở trạng thái trở kháng cao, nếu chế độ cổng-> có
Bộ bit PARPORT_MODE_TRISTATE.

SEE ALSO
^^^^^^^^

dữ liệu_forward



port->ops->epp_write_data - ghi dữ liệu EPP
------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

cấu trúc parport_Operation {
		...
size_t (*epp_write_data) (struct parport *port, const void *buf,
					size_t len, cờ int);
		...
	};

DESCRIPTION
^^^^^^^^^^^

Ghi dữ liệu ở chế độ EPP và trả về số byte đã ghi.

Tham số ZZ0000ZZ có thể là một hoặc nhiều tham số sau,
bitwise-hoặc'ed với nhau:

=============================================================================
PARPORT_EPP_FAST Sử dụng chuyển khoản nhanh. Một số chip cung cấp 16-bit và
			Các thanh ghi 32 bit.  Tuy nhiên, nếu chuyển
			hết thời gian, giá trị trả về có thể không đáng tin cậy.
=============================================================================

SEE ALSO
^^^^^^^^

epp_read_data, epp_write_addr, epp_read_addr




port->ops->epp_read_data - đọc dữ liệu EPP
----------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

cấu trúc parport_Operation {
		...
size_t (*epp_read_data) (struct parport *port, void *buf,
					size_t len, cờ int);
		...
	};

DESCRIPTION
^^^^^^^^^^^

Đọc dữ liệu ở chế độ EPP và trả về số byte đã đọc.

Tham số ZZ0000ZZ có thể là một hoặc nhiều tham số sau,
bitwise-hoặc'ed với nhau:

=============================================================================
PARPORT_EPP_FAST Sử dụng chuyển khoản nhanh. Một số chip cung cấp 16-bit và
			Các thanh ghi 32 bit.  Tuy nhiên, nếu chuyển
			hết thời gian, giá trị trả về có thể không đáng tin cậy.
=============================================================================

SEE ALSO
^^^^^^^^

epp_write_data, epp_write_addr, epp_read_addr



port->ops->epp_write_addr - ghi địa chỉ EPP
---------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

cấu trúc parport_Operation {
		...
size_t (*epp_write_addr) (struct parport *port,
					const void *buf, size_t len, cờ int);
		...
	};

DESCRIPTION
^^^^^^^^^^^

Ghi địa chỉ EPP (mỗi địa chỉ 8 bit) và trả về số đã ghi.

Tham số ZZ0000ZZ có thể là một hoặc nhiều tham số sau,
bitwise-hoặc'ed với nhau:

=============================================================================
PARPORT_EPP_FAST Sử dụng chuyển khoản nhanh. Một số chip cung cấp 16-bit và
			Các thanh ghi 32 bit.  Tuy nhiên, nếu chuyển
			hết thời gian, giá trị trả về có thể không đáng tin cậy.
=============================================================================

(PARPORT_EPP_FAST có phù hợp với chức năng này không?)

SEE ALSO
^^^^^^^^

epp_write_data, epp_read_data, epp_read_addr




port->ops->epp_read_addr - đọc địa chỉ EPP
-------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

cấu trúc parport_Operation {
		...
size_t (*epp_read_addr) (struct parport *port, void *buf,
					size_t len, cờ int);
		...
	};

DESCRIPTION
^^^^^^^^^^^

Đọc địa chỉ EPP (mỗi địa chỉ 8 bit) và trả về số đã đọc.

Tham số ZZ0000ZZ có thể là một hoặc nhiều tham số sau,
bitwise-hoặc'ed với nhau:

=============================================================================
PARPORT_EPP_FAST Sử dụng chuyển khoản nhanh. Một số chip cung cấp 16-bit và
			Các thanh ghi 32 bit.  Tuy nhiên, nếu chuyển
			hết thời gian, giá trị trả về có thể không đáng tin cậy.
=============================================================================

(PARPORT_EPP_FAST có phù hợp với chức năng này không?)

SEE ALSO
^^^^^^^^

epp_write_data, epp_read_data, epp_write_addr




port->ops->ecp_write_data - ghi một khối dữ liệu ECP
-----------------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

cấu trúc parport_Operation {
		...
size_t (*ecp_write_data) (struct parport *port,
					const void *buf, size_t len, cờ int);
		...
	};

DESCRIPTION
^^^^^^^^^^^

Ghi một khối dữ liệu ECP.  Tham số ZZ0000ZZ bị bỏ qua.

RETURN VALUE
^^^^^^^^^^^^

Số byte được ghi.

SEE ALSO
^^^^^^^^

ecp_read_data, ecp_write_addr




port->ops->ecp_read_data - đọc một khối dữ liệu ECP
---------------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

cấu trúc parport_Operation {
		...
size_t (*ecp_read_data) (struct parport *port,
					void *buf, size_t len, cờ int);
		...
	};

DESCRIPTION
^^^^^^^^^^^

Đọc một khối dữ liệu ECP.  Tham số ZZ0000ZZ bị bỏ qua.

RETURN VALUE
^^^^^^^^^^^^

Số byte đã đọc.  NB. Có thể có nhiều dữ liệu chưa đọc hơn trong
FIFO.  Có cách nào làm choáng FIFO để ngăn chặn điều này không?

SEE ALSO
^^^^^^^^

ecp_write_block, ecp_write_addr



port->ops->ecp_write_addr - ghi một khối địa chỉ ECP
----------------------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

cấu trúc parport_Operation {
		...
size_t (*ecp_write_addr) (struct parport *port,
					const void *buf, size_t len, cờ int);
		...
	};

DESCRIPTION
^^^^^^^^^^^

Ghi một khối địa chỉ ECP.  Tham số ZZ0000ZZ bị bỏ qua.

RETURN VALUE
^^^^^^^^^^^^

Số byte được ghi.

NOTES
^^^^^

Điều này có thể sử dụng FIFO và nếu vậy sẽ không quay trở lại cho đến khi FIFO trống.

SEE ALSO
^^^^^^^^

ecp_read_data, ecp_write_data



port->ops->nibble_read_data - đọc một khối dữ liệu ở chế độ nibble
-----------------------------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

cấu trúc parport_Operation {
		...
size_t (*nibble_read_data) (struct parport *port,
					void *buf, size_t len, cờ int);
		...
	};

DESCRIPTION
^^^^^^^^^^^

Đọc một khối dữ liệu ở chế độ nibble.  Tham số ZZ0000ZZ bị bỏ qua.

RETURN VALUE
^^^^^^^^^^^^

Số lượng toàn bộ byte được đọc.

SEE ALSO
^^^^^^^^

byte_read_data, compat_write_data




port->ops->byte_read_data - đọc một khối dữ liệu ở chế độ byte
-------------------------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

cấu trúc parport_Operation {
		...
size_t (*byte_read_data) (struct parport *port,
					void *buf, size_t len, cờ int);
		...
	};

DESCRIPTION
^^^^^^^^^^^

Đọc một khối dữ liệu ở chế độ byte.  Tham số ZZ0000ZZ bị bỏ qua.

RETURN VALUE
^^^^^^^^^^^^

Số byte đã đọc.

SEE ALSO
^^^^^^^^

nibble_read_data, compat_write_data




port->ops->compat_write_data - ghi một khối dữ liệu ở chế độ tương thích
--------------------------------------------------------------------------

SYNOPSIS
^^^^^^^^

::

#include <linux/parport.h>

cấu trúc parport_Operation {
		...
size_t (*compat_write_data) (struct parport *port,
					const void *buf, size_t len, cờ int);
		...
	};

DESCRIPTION
^^^^^^^^^^^

Ghi một khối dữ liệu ở chế độ tương thích.  Thông số ZZ0000ZZ
bị bỏ qua.

RETURN VALUE
^^^^^^^^^^^^

Số byte được ghi.

SEE ALSO
^^^^^^^^

nibble_read_data, byte_read_data
