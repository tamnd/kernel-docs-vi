.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/s390/cds.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Linux cho S/390 và zSeries
===========================

Hỗ trợ thiết bị chung (CDS)
Các thói quen hỗ trợ I/O của trình điều khiển thiết bị

tác giả:
	- Ingo Adlung
	- Cornelia Huck

Bản quyền, IBM Corp. 1999-2002

Giới thiệu
============

Tài liệu này mô tả các quy trình hỗ trợ thiết bị phổ biến dành cho Linux/390.
Khác với các kiến trúc phần cứng khác, ESA/390 đã xác định một hệ thống thống nhất
Phương pháp truy cập I/O. Điều này mang lại sự nhẹ nhõm cho các trình điều khiển thiết bị khi họ không
phải đối phó với các loại xe buýt khác nhau, bỏ phiếu và ngắt
xử lý, xử lý ngắt được chia sẻ và không chia sẻ, DMA so với cổng
I/O (PIO) và các tính năng phần cứng khác. Tuy nhiên, điều này ngụ ý rằng
hoặc mọi trình điều khiển thiết bị đều cần triển khai I/O phần cứng
chính chức năng đính kèm hoặc hệ điều hành cung cấp một
phương pháp thống nhất để truy cập vào phần cứng, cung cấp tất cả các chức năng
mỗi trình điều khiển thiết bị sẽ phải tự cung cấp.

Tài liệu này không có ý định giải thích kiến trúc phần cứng ESA/390 trong
mọi chi tiết. Thông tin này có thể được lấy từ Nguyên tắc ESA/390
Hướng dẫn vận hành (Mẫu IBM. Số SA22-7201).

Để xây dựng hỗ trợ thiết bị chung cho giao diện I/O ESA/390,
lớp chức năng được giới thiệu cung cấp các phương thức truy cập I/O chung cho
phần cứng.

Lớp hỗ trợ thiết bị chung bao gồm các thủ tục hỗ trợ I/O được xác định
bên dưới. Một số trong số chúng triển khai các giao diện trình điều khiển thiết bị Linux phổ biến, trong khi
một số trong số đó dành riêng cho nền tảng ESA/390.

Lưu ý:
  Để viết driver cho S/390, bạn cũng cần nhìn vào giao diện
  được mô tả trong Documentation/arch/s390/driver-model.rst.

Lưu ý khi chuyển trình điều khiển từ 2.4:

Những thay đổi chính là:

* Các chức năng sử dụng ccw_device thay vì irq (kênh phụ).
* Tất cả các trình điều khiển phải xác định ccw_driver (xem driver-model.txt) và liên kết
  chức năng.
* request_irq() và free_irq() không còn được trình điều khiển thực hiện nữa.
* oper_handler (loại) được thay thế bằng các hàm thăm dò() và set_online()
  của ccw_driver.
* Not_oper_handler được (loại) thay thế bằng Remove() và set_offline()
  chức năng của ccw_driver.
* Lớp thiết bị kênh đã biến mất.
* Trình xử lý ngắt phải được điều chỉnh để sử dụng ccw_device làm đối số.
  Hơn nữa, họ không trả về devstat mà là irb.
* Trước khi bắt đầu io, các tùy chọn phải được đặt qua ccw_device_set_options().
* Thay vì gọi read_dev_chars()/read_conf_data(), trình điều khiển gặp sự cố
  chương trình kênh và tự xử lý ngắt.

ccw_device_get_ciw()
   nhận lệnh từ dữ liệu giác quan mở rộng.

ccw_device_start(), ccw_device_start_timeout(), ccw_device_start_key(), ccw_device_start_key_timeout()
   bắt đầu một yêu cầu I/O.

ccw_device_resume()
   tiếp tục thực hiện chương trình kênh.

ccw_device_halt()
   chấm dứt yêu cầu I/O hiện tại được xử lý trên thiết bị.

do_IRQ()
   thói quen ngắt chung. Hàm này được gọi bởi mục nhập ngắt
   thường lệ bất cứ khi nào một ngắt I/O được đưa vào hệ thống. do_IRQ()
   thường trình xác định trạng thái ngắt và gọi thiết bị cụ thể
   trình xử lý ngắt theo các quy tắc (cờ) được xác định trong yêu cầu I/O
   bắt đầu bằng do_IO().

Các chương tiếp theo mô tả các hàm khác ngoài do_IRQ() chi tiết hơn.
Giao diện do_IRQ() không được mô tả vì nó được gọi từ Linux/390
chỉ xử lý ngắt cấp độ đầu tiên và không bao gồm trình điều khiển thiết bị
giao diện có thể gọi được. Thay vào đó, mô tả chức năng của do_IO() cũng
mô tả đầu vào cho trình xử lý ngắt cụ thể của thiết bị.

Lưu ý:
	Tất cả các giải thích cũng áp dụng cho kiến trúc 64 bit s390x.


Hỗ trợ thiết bị chung (CDS) cho trình điều khiển thiết bị Linux/390
========================================================

Thông tin chung
-------------------

Các chương sau mô tả các thủ tục giao diện liên quan đến I/O
Hỗ trợ thiết bị phổ biến Linux/390 (CDS) cung cấp để cho phép thiết bị cụ thể
triển khai trình điều khiển trên nền tảng phần cứng IBM ESA/390. Những giao diện đó
có ý định cung cấp chức năng theo yêu cầu của mọi trình điều khiển thiết bị
triển khai để cho phép điều khiển một thiết bị phần cứng cụ thể trên ESA/390
nền tảng. Một số quy trình giao diện dành riêng cho Linux/390 và một số
trong số chúng cũng có thể được tìm thấy trên các triển khai nền tảng Linux khác.
Các nguyên mẫu hàm khác, khai báo dữ liệu và định nghĩa macro
có thể được tìm thấy trong tệp tiêu đề C cụ thể của kiến ​​trúc
linux/arch/s390/include/asm/irq.h.

Tổng quan về các khái niệm giao diện CDS
----------------------------------

Khác với các nền tảng phần cứng khác, kiến trúc ESA/390 không xác định
các đường ngắt được quản lý bởi bộ điều khiển ngắt và hệ thống bus cụ thể
điều đó có thể hoặc không thể cho phép các ngắt được chia sẻ, xử lý DMA, v.v. Thay vào đó,
Kiến trúc ESA/390 đã triển khai cái gọi là hệ thống con kênh, hệ thống đó
cung cấp một cái nhìn thống nhất về các thiết bị được gắn vật lý vào hệ thống.
Mặc dù nền tảng phần cứng ESA/390 biết về rất nhiều loại khác nhau
các tệp đính kèm ngoại vi như thiết bị đĩa (hay còn gọi là DASD), băng từ, thông tin liên lạc
bộ điều khiển, v.v. tất cả chúng đều có thể được truy cập bằng một phương thức truy cập được xác định rõ ràng và
họ đang trình bày việc hoàn thành I/O theo một cách thống nhất: sự gián đoạn I/O. Mỗi
một thiết bị duy nhất được xác định duy nhất trong hệ thống bằng một kênh con,
trong đó kiến trúc ESA/390 cho phép gắn các thiết bị 64k.

Tuy nhiên, Linux lần đầu tiên được xây dựng trên kiến trúc PC Intel, với hai
xếp tầng 8259 bộ điều khiển ngắt khả trình (PIC), cho phép thực hiện
tối đa 15 dòng ngắt khác nhau. Tất cả các thiết bị gắn liền với một hệ thống như vậy
chia sẻ 15 mức ngắt đó. Các thiết bị được gắn vào hệ thống bus ISA phải
không chia sẻ các mức ngắt (còn gọi là IRQ), vì bus ISA dựa trên cạnh được kích hoạt
ngắt quãng. MCA, EISA, PCI và các hệ thống bus khác dựa trên mức độ được kích hoạt
ngắt và do đó cho phép chia sẻ IRQ. Tuy nhiên, nếu nhiều thiết bị
trình bày trạng thái phần cứng của họ bằng cùng một IRQ (được chia sẻ), hệ điều hành
phải gọi mọi trình điều khiển thiết bị đã đăng ký trên IRQ này để
xác định trình điều khiển thiết bị sở hữu thiết bị gây ra ngắt.

Lên tới kernel 2.4, Linux/390 được sử dụng để cung cấp giao diện thông qua IRQ (kênh con).
Để sử dụng nội bộ lớp I/O chung, những lớp này vẫn còn đó. Tuy nhiên,
trình điều khiển thiết bị chỉ nên sử dụng giao diện gọi điện mới thông qua ccw_device.

Trong quá trình khởi động, hệ thống Linux/390 sẽ kiểm tra các thiết bị ngoại vi. Mỗi
trong số các thiết bị đó được xác định duy nhất bởi một kênh con được gọi là ESA/390
hệ thống con kênh. Mặc dù số kênh con là do hệ thống tạo ra, mỗi số
kênh con cũng có thuộc tính do người dùng xác định, được gọi là số thiết bị.
Cả số kênh con và số thiết bị đều không thể vượt quá 65535. Trong sysfs
khởi tạo, thông tin về loại thiết bị điều khiển và loại thiết bị
ngụ ý các lệnh I/O cụ thể (các từ lệnh kênh - CCW) để vận hành
thiết bị được tập hợp. Trình điều khiển thiết bị có thể truy xuất bộ phần cứng này
thông tin trong bước khởi tạo để nhận dạng các thiết bị mà chúng
hỗ trợ sử dụng thông tin được lưu trong struct ccw_device được cung cấp cho họ.
Phương pháp này ngụ ý rằng Linux/390 không yêu cầu thăm dò miễn phí (không phải
được trang bị) các dòng yêu cầu ngắt (IRQ) để điều khiển các thiết bị của nó. Ở đâu
nếu có, trình điều khiển thiết bị có thể sử dụng vấn đề READ DEVICE CHARACTERISTICS
ccw để truy xuất các đặc điểm của thiết bị trong quy trình trực tuyến của nó.

Để cho phép khởi tạo I/O dễ dàng, lớp CDS cung cấp một
Giao diện ccw_device_start() sử dụng chương trình kênh cụ thể của thiết bị (một
hoặc nhiều CCW) khi đầu vào thiết lập các khối điều khiển cụ thể theo kiến trúc được yêu cầu
và khởi tạo một yêu cầu I/O thay mặt cho trình điều khiển thiết bị. các
Quy trình ccw_device_start() cho phép chỉ định xem nó có mong đợi lớp CDS hay không
để thông báo cho trình điều khiển thiết bị về mọi gián đoạn mà nó quan sát được hoặc trạng thái cuối cùng
chỉ. Xem ccw_device_start() để biết thêm chi tiết. Trình điều khiển thiết bị không bao giờ được phát hành
ESA/390 I/O tự ra lệnh nhưng thay vào đó phải sử dụng giao diện Linux/390 CDS.

Để hủy yêu cầu I/O đang chạy trong thời gian dài, lớp CDS cung cấp
hàm ccw_device_halt(). Một số thiết bị yêu cầu ban đầu phải cấp HALT
Lệnh SUBCHANNEL (HSCH) mà không có yêu cầu I/O đang chờ xử lý. Chức năng này là
cũng được bao phủ bởi ccw_device_halt().


get_ciw() - lấy thông tin lệnh từ

Cuộc gọi này cho phép trình điều khiển thiết bị nhận thông tin về các lệnh được hỗ trợ
từ dữ liệu SenseID mở rộng.

::

cấu trúc ciw *
  ccw_device_get_ciw(struct ccw_device *cdev, __u32 cmd);

==== =============================================================
cdev CCw_device mà lệnh sẽ được truy xuất.
cmd Loại lệnh cần lấy.
==== =============================================================

ccw_device_get_ciw() trả về:

===== =====================================================================
 NULL Không có dữ liệu mở rộng, không tìm thấy thiết bị hoặc lệnh không hợp lệ.
!NULL Lệnh được yêu cầu.
===== =====================================================================

::

ccw_device_start() - Bắt đầu yêu cầu I/O

Các quy trình ccw_device_start() là bộ xử lý ngoại vi yêu cầu I/O. Tất cả
Yêu cầu I/O của trình điều khiển thiết bị phải được đưa ra bằng cách sử dụng quy trình này. Trình điều khiển thiết bị
không được tự mình đưa ra các lệnh I/O ESA/390. Thay vào đó là ccw_device_start()
thường lệ cung cấp tất cả các giao diện cần thiết để điều khiển các thiết bị tùy ý.

Mô tả này cũng bao gồm thông tin trạng thái được truyền tới thiết bị
trình xử lý ngắt của trình điều khiển vì điều này liên quan đến các quy tắc (cờ) được xác định
với yêu cầu I/O liên quan khi gọi ccw_device_start().

::

int ccw_device_start(struct ccw_device *cdev,
		       cấu trúc ccw1 *cpa,
		       intparm dài không dấu,
		       __u8 lpm,
		       cờ dài không dấu);
  int ccw_device_start_timeout(struct ccw_device *cdev,
			       cấu trúc ccw1 *cpa,
			       intparm dài không dấu,
			       __u8 lpm,
			       cờ dài không dấu,
			       int hết hạn);
  int ccw_device_start_key(struct ccw_device *cdev,
			   cấu trúc ccw1 *cpa,
			   intparm dài không dấu,
			   __u8 lpm,
			   __u8 phím,
			   cờ dài không dấu);
  int ccw_device_start_key_timeout(struct ccw_device *cdev,
				   cấu trúc ccw1 *cpa,
				   intparm dài không dấu,
				   __u8 lpm,
				   __u8 phím,
				   cờ dài không dấu,
				   int hết hạn);

============== ==================================================================
cdev ccw_device I/O được dành cho
địa chỉ bắt đầu logic cpa của chương trình kênh
thông tin ngắt cụ thể của người dùng user_intparm; sẽ được trình bày
	      quay lại trình xử lý ngắt của trình điều khiển thiết bị. Cho phép một
	      trình điều khiển thiết bị để liên kết ngắt với một
	      yêu cầu I/O cụ thể.
lpm xác định đường dẫn kênh được sử dụng cho I/O cụ thể
	      yêu cầu. Giá trị 0 sẽ khiến cio sử dụng opm.
khóa khóa lưu trữ để sử dụng cho I/O (hữu ích khi thao tác trên
	      lưu trữ bằng khóa lưu trữ != khóa mặc định)
cờ xác định hành động được thực hiện để xử lý I/O
hết giá trị thời gian chờ trong nháy mắt. Lớp I/O chung sẽ chấm dứt
	      chương trình đang chạy sau đó và gọi trình xử lý ngắt
	      với ERR_PTR(-ETIMEDOUT) là irb.
============== ==================================================================

Các giá trị cờ có thể có là:

============================================================================
Chương trình kênh DOIO_ALLOW_SUSPEND có thể bị tạm dừng
DOIO_DENY_PREFETCH không cho phép tìm nạp trước CCW; thường
			  điều này ngụ ý chương trình kênh có thể
			  trở nên sửa đổi
DOIO_SUPPRESS_INTER không gọi trình xử lý ở trạng thái trung gian
============================================================================

Tham số cpa trỏ đến định dạng đầu tiên 1 CCW của chương trình kênh::

cấu trúc ccw1 {
	__u8 cmd_code;/* mã lệnh */
	__u8 cờ;   /* cờ, như địa chỉ IDA, v.v. */
	__u16 tính;   /* số byte */
	__u32 cda;     /*địa chỉ dữ liệu */
  } __attribute__ ((đóng gói,căn chỉnh(8)));

với các giá trị cờ CCW sau được xác định:

===============================================
Chuỗi dữ liệu CCW_FLAG_DC
Chuỗi lệnh CCW_FLAG_CC
CCW_FLAG_SLI ngăn chặn độ dài không chính xác
CCW_FLAG_SKIP bỏ qua
CCW_FLAG_PCI PCI
Địa chỉ gián tiếp CCW_FLAG_IDA
CCW_FLAG_SUSPEND đình chỉ
===============================================


Thông qua ccw_device_set_options(), trình điều khiển thiết bị có thể chỉ định những điều sau
tùy chọn cho thiết bị:

====================================================================
DOIO_EARLY_NOTIFICATION cho phép thông báo ngắt sớm
DOIO_REPORT_ALL báo cáo tất cả các điều kiện ngắt
====================================================================


Hàm ccw_device_start() trả về:

=====================================================================================
      0 hoàn thành thành công hoặc yêu cầu được khởi tạo thành công
 -EBUSY Thiết bị hiện đang xử lý yêu cầu I/O trước đó hoặc có
	 một trạng thái đang chờ xử lý trên thiết bị.
-ENODEV cdev không hợp lệ, thiết bị không hoạt động hoặc ccw_device bị hỏng
	 không trực tuyến.
=====================================================================================

Khi yêu cầu I/O hoàn tất, bộ xử lý ngắt cấp đầu tiên CDS sẽ
tích lũy trạng thái trong cấu trúc irb và sau đó gọi trình xử lý ngắt thiết bị.
Trường intparm sẽ chứa giá trị mà trình điều khiển thiết bị đã liên kết với một
yêu cầu I/O cụ thể. Nếu trạng thái thiết bị đang chờ xử lý được nhận dạng,
intparm sẽ được đặt thành 0 (không). Điều này có thể xảy ra trong quá trình khởi tạo I/O hoặc bị trì hoãn
bằng một thông báo trạng thái cảnh báo. Trong mọi trường hợp, trạng thái này không liên quan đến
yêu cầu I/O hiện tại (cuối cùng). Trong trường hợp thông báo trạng thái bị trì hoãn thì không có gì đặc biệt
ngắt sẽ xuất hiện để cho biết việc hoàn thành I/O khi yêu cầu I/O được thực hiện
chưa bao giờ bắt đầu, mặc dù ccw_device_start() đã trả về khi hoàn tất thành công.

Irb có thể chứa giá trị lỗi và trình điều khiển thiết bị nên kiểm tra điều này
đầu tiên:

=================================================================================
-ETIMEDOUT lớp I/O chung đã chấm dứt yêu cầu sau khi được chỉ định
	   giá trị thời gian chờ
-EIO lớp I/O chung đã chấm dứt yêu cầu do trạng thái lỗi
=================================================================================

Nếu cờ cảm giác đồng thời trong từ trạng thái mở rộng (esw) trong irb là
set, trường erw.scnt trong esw mô tả số lượng thiết bị cụ thể
byte cảm nhận có sẵn trong từ điều khiển mở rộng irb->scsw.ecw[]. Không có thiết bị
cần phải có cảm biến của chính trình điều khiển thiết bị.

Trình xử lý ngắt thiết bị có thể sử dụng các định nghĩa sau để điều tra
nguồn kiểm tra đơn vị chính được mã hóa theo byte 0:

========================= ====
SNS0_CMD_REJECT 0x80
SNS0_INTERVENTION_REQ 0x40
SNS0_BUS_OUT_CHECK 0x20
SNS0_EQUIPMENT_CHECK 0x10
SNS0_DATA_CHECK 0x08
SNS0_OVERRUN 0x04
SNS0_INCOMPL_DOMAIN 0x01
========================= ====

Tùy thuộc vào trạng thái thiết bị, nhiều giá trị trong số đó có thể được đặt cùng nhau.
Vui lòng tham khảo tài liệu cụ thể của thiết bị để biết chi tiết.

Trường irb->scsw.cstat cung cấp trạng thái kênh con (tích lũy):

==========================================================
Ngắt điều khiển chương trình SCHN_STAT_PCI
SCHN_STAT_INCORR_LEN chiều dài không chính xác
Kiểm tra chương trình SCHN_STAT_PROG_CHECK
Kiểm tra bảo vệ SCHN_STAT_PROT_CHECK
Kiểm tra dữ liệu kênh SCHN_STAT_CHN_DATA_CHK
Kiểm tra điều khiển kênh SCHN_STAT_CHN_CTRL_CHK
Kiểm tra điều khiển giao diện SCHN_STAT_INTF_CTRL_CHK
Kiểm tra xích SCHN_STAT_CHAIN_CHECK
==========================================================

Trường irb->scsw.dstat cung cấp trạng thái thiết bị (tích lũy):

========================================
DEV_STAT_ATTENTION chú ý
Công cụ sửa đổi trạng thái DEV_STAT_STAT_MOD
Đầu bộ điều khiển DEV_STAT_CU_END
DEV_STAT_BUSY bận
Đầu kênh DEV_STAT_CHN_END
Đầu thiết bị DEV_STAT_DEV_END
Kiểm tra đơn vị DEV_STAT_UNIT_CHECK
Ngoại lệ đơn vị DEV_STAT_UNIT_EXCEP
========================================

Vui lòng xem sách hướng dẫn Nguyên tắc vận hành ESA/390 để biết chi tiết về
ý nghĩa cờ riêng lẻ.

Ghi chú sử dụng:

ccw_device_start() phải được gọi là bị vô hiệu hóa và khóa thiết bị ccw được giữ.

Trình điều khiển thiết bị được phép thực hiện cuộc gọi ccw_device_start() tiếp theo từ
trong trình xử lý ngắt của nó rồi. Không cần thiết phải lên lịch
nửa dưới, trừ khi quy trình khôi phục lỗi chạy dài không xác định
hoặc những nhu cầu tương tự cần được lên lịch. Trong quá trình xử lý I/O, Linux/390 chung
Hỗ trợ trình điều khiển thiết bị I/O đã có được khóa IRQ, tức là trình xử lý
không được cố lấy lại nó khi gọi ccw_device_start() nếu không chúng ta sẽ kết thúc bằng
tình thế bế tắc!

Nếu trình điều khiển thiết bị dựa vào yêu cầu I/O để hoàn thành trước khi bắt đầu
tiếp theo, nó có thể giảm chi phí xử lý I/O bằng cách xâu chuỗi lệnh I/O NoOp
CCW_CMD_NOOP đến cuối chuỗi CCW đã gửi. Điều này sẽ buộc Channel-End
và trạng thái Kết thúc thiết bị sẽ được hiển thị cùng nhau, với một lần ngắt.
Tuy nhiên, điều này nên được sử dụng cẩn thận vì nó ngụ ý rằng kênh sẽ vẫn được duy trì.
bận, không thể xử lý yêu cầu I/O cho các thiết bị khác trên cùng một thiết bị
kênh. Vì vậy, ví dụ: lệnh đọc không bao giờ nên sử dụng kỹ thuật này, vì
dù sao thì kết quả cũng sẽ được trình bày bằng một ngắt duy nhất.

Để giảm thiểu chi phí I/O, trình điều khiển thiết bị nên sử dụng
DOIO_REPORT_ALL chỉ khi thiết bị có thể báo cáo ngắt trung gian
thông tin trước khi kết thúc thiết bị mà trình điều khiển thiết bị cần khẩn trương dựa vào. Trong này
trường hợp tất cả các gián đoạn I/O được trình bày cho trình điều khiển thiết bị cho đến khi hoàn thành
trạng thái được công nhận.

Nếu một thiết bị có thể phục hồi từ các lỗi I/O xuất hiện không đồng bộ, nó có thể
thực hiện I/O chồng chéo bằng cờ DOIO_EARLY_NOTIFICATION. Trong khi một số
các thiết bị luôn báo cáo đầu kênh và đầu thiết bị cùng nhau, bằng một
bị ngắt, một số khác thể hiện trạng thái chính (cuối kênh) khi kênh bị ngắt.
sẵn sàng cho yêu cầu I/O tiếp theo và trạng thái thứ cấp (cuối thiết bị) khi dữ liệu
việc truyền tải đã được hoàn thành tại thiết bị.

Cờ trên cho phép khai thác tính năng này, ví dụ: cho các thiết bị liên lạc
có thể xử lý dữ liệu bị mất trên mạng để cho phép xử lý I/O nâng cao.

Trừ khi hệ thống con kênh bất kỳ lúc nào có trạng thái gián đoạn thứ cấp,
khai thác tính năng này sẽ chỉ gây ra các ngắt trạng thái chính.
được trình bày cho trình điều khiển thiết bị trong khi I/O chồng chéo được thực hiện. Khi một
trạng thái thứ cấp không có lỗi (trạng thái cảnh báo) được hiển thị, điều này cho biết
hoàn thành thành công cho tất cả các yêu cầu ccw_device_start() chồng chéo có
được ban hành kể từ trạng thái thứ cấp (cuối cùng) cuối cùng.

Các chương trình kênh có ý định đặt cờ tạm dừng trên từ lệnh kênh
(CCW) phải bắt đầu thao tác I/O với tùy chọn DOIO_ALLOW_SUSPEND hoặc
cờ tạm dừng sẽ gây ra việc kiểm tra chương trình kênh. Vào thời điểm chương trình kênh
bị treo, một ngắt trung gian sẽ được tạo ra bởi kênh
hệ thống con.

ccw_device_resume() - Tiếp tục thực hiện chương trình kênh

Nếu trình điều khiển thiết bị chọn tạm dừng việc thực hiện chương trình kênh hiện tại bằng cách
thiết lập cờ tạm dừng CCW trên một CCW cụ thể, việc thực thi chương trình kênh
bị đình chỉ. Để tiếp tục thực hiện chương trình kênh, lớp CIO
cung cấp quy trình ccw_device_resume().

::

int ccw_device_resume(struct ccw_device *cdev);

==== =====================================================
cdev ccw_device hoạt động tiếp tục được yêu cầu cho
==== =====================================================

Hàm ccw_device_resume() trả về:

============================================================
	0 chương trình kênh bị đình chỉ được tiếp tục
   -EBUSY trạng thái đang chờ xử lý
  -ENODEV cdev kênh con không hợp lệ hoặc không hoạt động
  -EINVAL chức năng tiếp tục không áp dụng
-ENOTCONN không có yêu cầu I/O nào đang chờ hoàn thành
============================================================

Ghi chú sử dụng:

Vui lòng xem ghi chú sử dụng ccw_device_start() để biết thêm chi tiết về
chương trình kênh bị đình chỉ.

ccw_device_halt() - Dừng xử lý yêu cầu I/O

Đôi khi trình điều khiển thiết bị có thể cần khả năng dừng quá trình xử lý
một chương trình kênh chạy dài hoặc thiết bị có thể yêu cầu phát hành lần đầu
lệnh I/O dừng kênh con (HSCH). Vì những mục đích đó, ccw_device_halt()
lệnh được cung cấp.

ccw_device_halt() phải được gọi là bị vô hiệu hóa và khóa thiết bị ccw được giữ.

::

int ccw_device_halt(struct ccw_device *cdev,
		      intparm dài không dấu);

======= ==========================================================
cdev ccw_device, thao tác tạm dừng được yêu cầu cho
tham số gián đoạn intparm; giá trị chỉ được sử dụng nếu không có I/O
	 là nổi bật, nếu không thì intparm được liên kết với
	 yêu cầu I/O được trả về
======= ==========================================================

Hàm ccw_device_halt() trả về:

======= ===================================================================
      0 yêu cầu được khởi tạo thành công
-EBUSY thiết bị hiện đang bận hoặc đang chờ xử lý.
-ENODEV cdev không hợp lệ.
-EINVAL Thiết bị không hoạt động hoặc thiết bị ccw không trực tuyến.
======= ===================================================================

Ghi chú sử dụng:

Trình điều khiển thiết bị có thể viết chương trình kênh không bao giờ kết thúc bằng cách viết kênh
chương trình mà ở phần cuối của nó sẽ lặp lại phần đầu của nó bằng cách chuyển vào
lệnh kênh (TIC) (CCW_CMD_TIC). Thông thường việc này được thực hiện bởi mạng
trình điều khiển thiết bị bằng cách đặt cờ PCI CCW (CCW_FLAG_PCI). Một khi CCW này được
đã thực thi một ngắt được điều khiển bằng chương trình (PCI) được tạo ra. Trình điều khiển thiết bị
sau đó có thể thực hiện một hành động thích hợp. Trước khi gián đoạn một khoản nợ đọng
đọc cho thiết bị mạng (có hoặc không có cờ PCI) a ccw_device_halt()
được yêu cầu để kết thúc hoạt động đang chờ xử lý.

::

ccw_device_clear() - Chấm dứt xử lý yêu cầu I/O

Để chấm dứt tất cả quá trình xử lý I/O tại kênh con, kênh con rõ ràng
Lệnh (CSCH) được sử dụng. Nó có thể được phát hành thông qua ccw_device_clear().

ccw_device_clear() phải được gọi là bị vô hiệu hóa và khóa thiết bị ccw được giữ.

::

int ccw_device_clear(struct ccw_device *cdev, intparm dài chưa dấu);

======= ====================================================
cdev ccw_device, thao tác rõ ràng được yêu cầu cho
tham số gián đoạn intparm (xem ccw_device_halt())
======= ====================================================

Hàm ccw_device_clear() trả về:

======= ===================================================================
      0 yêu cầu được khởi tạo thành công
-ENODEV cdev không hợp lệ
-EINVAL Thiết bị không hoạt động hoặc thiết bị ccw không trực tuyến.
======= ===================================================================

Các thói quen hỗ trợ khác
------------------------------

Chương này mô tả các thủ tục khác nhau được sử dụng trong thiết bị Linux/390
môi trường lập trình điều khiển.

get_ccwdev_lock()

Lấy địa chỉ của khóa cụ thể của thiết bị. Điều này sau đó được sử dụng trong
lệnh gọi spin_lock() / spin_unlock().

::

__u8 ccw_device_get_path_mask(struct ccw_device *cdev);

Lấy mặt nạ của đường dẫn hiện có cho cdev.
