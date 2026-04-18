.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/libsas.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========
Lớp SAS
==========

Lớp SAS là cơ sở hạ tầng quản lý quản lý
LLDD SAS.  Nó nằm giữa SCSI Core và SAS LLDD.  các
bố cục như sau: trong khi SCSI Core liên quan đến
Các vấn đề về SAM/SPC và bộ tuần tự SAS LLDD+ có liên quan đến
phy/OOB/quản lý liên kết, lớp SAS liên quan đến:

* Quản lý sự kiện SAS Phy/Port/HA (LLDD tạo ra,
        Các quy trình lớp SAS),
      * Quản lý cổng SAS (tạo/hủy),
      * SAS Phát hiện và xác nhận lại tên miền,
      * SAS Quản lý thiết bị miền,
      * SCSI Đăng ký/hủy đăng ký máy chủ,
      * Đăng ký thiết bị với SCSI Core (SAS) hoặc libata
        (SATA) và
      * Quản lý thiết bị mở rộng và kiểm soát thiết bị mở rộng xuất khẩu
        tới không gian người dùng.

SAS LLDD là trình điều khiển thiết bị PCI.  Nó quan tâm đến
quản lý phy/OOB cũng như các nhiệm vụ cụ thể của nhà cung cấp và tạo ra
các sự kiện đến lớp SAS.

Lớp SAS thực hiện hầu hết các tác vụ SAS như được nêu trong SAS 1.1
thông số kỹ thuật.

sas_ha_struct mô tả SAS LLDD cho lớp SAS.
Hầu hết nó được sử dụng bởi Lớp SAS nhưng một số trường cần phải
được khởi tạo bởi LLDD.

Sau khi khởi tạo phần cứng của bạn, từ hàm thăm dò()
bạn gọi sas_register_ha(). Nó sẽ đăng ký LLDD của bạn với
hệ thống con SCSI, tạo một máy chủ SCSI và nó sẽ
đăng ký trình điều khiển SAS của bạn với cây SAS sysfs mà nó tạo ra.
Sau đó nó sẽ quay trở lại.  Sau đó, bạn kích hoạt vật lý của mình để thực sự
khởi động OOB (lúc này trình điều khiển của bạn sẽ bắt đầu gọi
thông báo_* gọi lại sự kiện).

Mô tả cấu trúc
======================

ZZ0000ZZ
------------------

Thông thường, điều này được nhúng tĩnh vào trình điều khiển của bạn
cấu trúc vật lý::

cấu trúc my_phy {
	    bla;
	    struct sas_phy sas_phy;
	    bleh;
    };

Và sau đó tất cả các phys là một mảng my_phy trong HA của bạn
cấu trúc (hiển thị bên dưới).

Sau đó, khi bạn tiếp tục và khởi tạo vật lý của mình, bạn cũng
khởi tạo cấu trúc sas_phy, cùng với cấu trúc của riêng bạn
cấu trúc vật lý.

Nói chung, vật lý được quản lý bởi LLDD và các cổng
được quản lý bởi lớp SAS.  Vì vậy, vật lý được khởi tạo
và được cập nhật bởi LLDD và các cổng được khởi tạo và
được cập nhật bởi lớp SAS.

Có một sơ đồ trong đó LLDD có thể RW một số trường nhất định,
và lớp SAS chỉ có thể đọc những lớp như vậy và ngược lại.
Ý tưởng là để tránh việc khóa không cần thiết.

đã bật
    - phải được đặt (0/1)

danh tính
    - phải được đặt [0,MAX_PHYS)]

lớp, nguyên mẫu, loại, vai trò, oob_mode, tốc độ liên kết
    - phải được thiết lập

oob_mode
    - bạn thiết lập cái này khi OOB làm xong rồi thông báo
      Lớp SAS.

sas_addr
    - điều này thường trỏ đến một mảng chứa sas
      địa chỉ của phy, có thể ở đâu đó trong my_phy của bạn
      struct.

đính kèm_sas_addr
    - thiết lập điều này khi bạn (LLDD) nhận được một
      Khung IDENTIFY hoặc khung FIS, _trước_ thông báo cho SAS
      lớp.  Ý tưởng là đôi khi LLDD có thể muốn giả mạo
      hoặc cung cấp địa chỉ SAS khác trên phy/port đó và địa chỉ này
      cho phép nó làm điều này.  Tốt nhất bạn nên sao chép sa
      địa chỉ từ khung IDENTIFY hoặc có thể tạo SAS
      địa chỉ cho các thiết bị được gắn trực tiếp SATA.  Khám phá
      quá trình sau này có thể thay đổi điều này.

khung_rcvd
    - đây là nơi bạn sao chép khung IDENTIFY/FIS
      khi bạn nhận được nó; bạn khóa, sao chép, đặt frame_rcvd_size và
      mở khóa, sau đó gọi sự kiện.  Nó là một con trỏ
      vì không có cách nào để biết chính xác kích thước khung hình hw của bạn,
      vì vậy bạn xác định mảng thực tế trong cấu trúc phy của mình và để
      con trỏ này trỏ tới nó.  Bạn sao chép khung từ
      Bộ nhớ DMAable tới khu vực đó đang giữ khóa.

sas_prim
    - đây là nơi người nguyên thủy đến khi họ ở
      đã nhận được.  Xem sas.h. Lấy khóa, đặt nguyên thủy,
      nhả khóa, thông báo.

hải cảng
    - cái này trỏ tới sas_port nếu phy thuộc về
      tới một cổng -- LLDD chỉ đọc cái này. Nó trỏ tới
      sas_port phy này là một phần của.  Được thiết lập bởi Lớp SAS.

ha
    - có thể được thiết lập; lớp SAS vẫn thiết lập nó.

lldd_phy
    - bạn nên đặt cái này để trỏ đến phy của bạn để bạn
      có thể tìm đường nhanh hơn khi lớp SAS gọi một
      về các cuộc gọi lại của bạn và chuyển cho bạn một phy.  Nếu sas_phy là
      được nhúng bạn cũng có thể sử dụng container_of -- bất cứ điều gì bạn
      thích hơn.


ZZ0000ZZ
-------------------

LLDD không đặt bất kỳ trường nào của cấu trúc này - nó chỉ
đọc chúng.  Họ nên tự giải thích.

phy_mask là 32 bit, bây giờ thế là đủ rồi, vì tôi
chưa từng nghe nói HA nào có nhiều hơn 8 phys.

lldd_port
    - Tôi chưa tìm thấy công dụng của cái đó -- có thể là cái khác
      LLDD muốn có đại diện cổng nội bộ có thể thực hiện
      sử dụng cái này.

ZZ0000ZZ
------------------------

Nó thường được khai báo tĩnh trong LLDD của riêng bạn
cấu trúc mô tả bộ điều hợp của bạn::

cấu trúc my_sas_ha {
	bla;
	cấu trúc sas_ha_struct sas_ha;
	cấu trúc my_phy phys[MAX_PHYS];
	cấu trúc sas_port sas_ports[MAX_PHYS]; /* (1) */
	bleh;
    };

(1) Nếu LLDD của bạn không có cổng đại diện riêng.

Những gì cần được khởi tạo (hàm mẫu được đưa ra bên dưới).

pcidev
^^^^^^

sas_addr
       - vì lớp SAS không muốn gây rối
	 cấp phát bộ nhớ, v.v., điều này trỏ đến tĩnh
	 mảng được phân bổ ở đâu đó (giả sử trong bộ điều hợp máy chủ của bạn
	 trúc) và giữ địa chỉ SAS của máy chủ
	 bộ chuyển đổi do bạn hoặc nhà sản xuất cung cấp, v.v.

sas_port
^^^^^^^^

sas_phy
      - một mảng các con trỏ tới các cấu trúc. (xem
	lưu ý ở trên trên sas_addr).
	Những điều này phải được thiết lập.  Xem thêm ghi chú bên dưới.

số_phys
       - số lượng vật lý có trong mảng sas_phy,
	 và số lượng cổng có trong sas_port
	 mảng.  Có thể có tối đa num_phys cổng (mỗi cổng một
	 port) nên chúng tôi bỏ num_ports và chỉ sử dụng
	 num_phys.

Giao diện sự kiện::

/* LLDD gọi những lệnh này để thông báo cho lớp về một sự kiện. */
	void sas_notify_port_event(struct sas_phy *, enum port_event, gfp_t);
	void sas_notify_phy_event(struct sas_phy *, enum phy_event, gfp_t);

Thông báo cổng::

/* Lớp gọi những thứ này để thông báo cho LLDD về một sự kiện. */
	khoảng trống (ZZ0000ZZ);
	khoảng trống (ZZ0001ZZ);

Nếu LLDD muốn thông báo khi một cổng được hình thành
hoặc bị biến dạng, nó đặt chúng thành một hàm thỏa mãn loại.

SAS LLDD cũng phải triển khai ít nhất một trong các Nhiệm vụ
Chức năng quản lý (TMF) được mô tả trong SAM::

/* Chức năng quản lý tác vụ. Phải được gọi từ bối cảnh quá trình. */
	int (ZZ0000ZZ);
	int (ZZ0001ZZ, u8 *lun);
	int (ZZ0002ZZ, u8 *lun);
	int (ZZ0003ZZ);
	int (ZZ0004ZZ, u8 *lun);
	int (ZZ0005ZZ);

Để biết thêm thông tin, vui lòng đọc SAM từ T10.org.

Quản lý cổng và bộ chuyển đổi::

/* Quản lý cổng và bộ chuyển đổi */
	int (ZZ0000ZZ);
	int (ZZ0001ZZ);

SAS LLDD nên triển khai ít nhất một trong số đó.

Quản lý vật lý::

/* Quản lý vật lý */
	int (ZZ0000ZZ, enum phy_func);

lldd_ha
    - đặt cái này để trỏ đến cấu trúc HA của bạn. Bạn cũng có thể
      sử dụng container_of nếu bạn nhúng nó như hiển thị ở trên.

Một chức năng khởi tạo và đăng ký mẫu
có thể trông như thế này (được gọi là điều cuối cùng từ thăm dò())
ZZ0000ZZ trước khi bạn kích hoạt phys để thực hiện OOB::

int tĩnh register_sas_ha(struct my_sas_ha *my_ha)
    {
	    int tôi;
	    cấu trúc tĩnh sas_phy *sas_phys[MAX_PHYS];
	    cấu trúc tĩnh sas_port *sas_ports[MAX_PHYS];

my_ha->sas_ha.sas_addr = &my_ha->sas_addr[0];

cho (i = 0; tôi < MAX_PHYS; i++) {
		    sas_phys[i] = &my_ha->phys[i].sas_phy;
		    sas_ports[i] = &my_ha->sas_ports[i];
	    }

my_ha->sas_ha.sas_phy = sas_phys;
	    my_ha->sas_ha.sas_port = sas_ports;
	    my_ha->sas_ha.num_phys = MAX_PHYS;

my_ha->sas_ha.lldd_port_formed = my_port_formed;

my_ha->sas_ha.lldd_dev_found = my_dev_found;
	    my_ha->sas_ha.lldd_dev_gone = my_dev_gone;

my_ha->sas_ha.lldd_execute_task = my_execute_task;

my_ha->sas_ha.lldd_abort_task = my_abort_task;
	    my_ha->sas_ha.lldd_abort_task_set = my_abort_task_set;
	    my_ha->sas_ha.lldd_clear_task_set = my_clear_task_set;
	    my_ha->sas_ha.lldd_I_T_nexus_reset= NULL; (2)
	    my_ha->sas_ha.lldd_lu_reset = my_lu_reset;
	    my_ha->sas_ha.lldd_query_task = my_query_task;

my_ha->sas_ha.lldd_clear_nexus_port = my_clear_nexus_port;
	    my_ha->sas_ha.lldd_clear_nexus_ha = my_clear_nexus_ha;

my_ha->sas_ha.lldd_control_phy = my_control_phy;

return sas_register_ha(&my_ha->sas_ha);
    }

(2) SAS 1.1 không xác định I_T Nexus Reset TMF.

Sự kiện
======

Các sự kiện là ZZ0000ZZ a SAS LLDD thông báo cho lớp SAS
của bất cứ điều gì.  LLDD không có phương pháp hay cách nào khác để nói
lớp SAS của bất kỳ điều gì xảy ra bên trong hoặc trong SAS
miền.

Sự kiện vật lý::

PHYE_LOSS_OF_SIGNAL, (C)
	PHYE_OOB_DONE,
	PHYE_OOB_ERROR, (C)
	PHYE_SPINUP_HOLD.

Cổng sự kiện, được chuyển qua _phy_::

PORTE_BYTES_DMAED, (M)
	PORTE_BROADCAST_RCVD, (E)
	PORTE_LINK_RESET_ERR, (C)
	PORTE_TIMER_EVENT, (C)
	PORTE_HARD_RESET.

Sự kiện Bộ điều hợp máy chủ:
	HAE_RESET

SAS LLDD sẽ có thể tạo

- ít nhất một sự kiện từ nhóm C (lựa chọn),
	- các sự kiện được đánh dấu M (bắt buộc) là bắt buộc (chỉ một),
	- các sự kiện được đánh dấu E (mở rộng) nếu nó muốn lớp SAS
	  để xử lý việc xác nhận lại tên miền (chỉ một trường hợp như vậy).
	- Sự kiện không được đánh dấu là tùy chọn.

Nghĩa:

HAE_RESET
    - khi HA của bạn gặp lỗi nội bộ và được đặt lại.

PORTE_BYTES_DMAED
    - khi nhận được khung IDENTIFY/FIS

PORTE_BROADCAST_RCVD
    - khi nhận được một nguyên thủy

PORTE_LINK_RESET_ERR
    - hết giờ hẹn giờ, mất tín hiệu, mất DWS, v.v. [1]_

PORTE_TIMER_EVENT
    - Đã hết thời gian chờ đặt lại DWS [1]_

PORTE_HARD_RESET
    - Đã nhận được Hard Reset gốc.

PHYE_LOSS_OF_SIGNAL
    - thiết bị đã biến mất [1]_

PHYE_OOB_DONE
    - OOB hoạt động tốt và oob_mode hợp lệ

PHYE_OOB_ERROR
    - Lỗi khi làm OOB, có thể do máy
      đã bị ngắt kết nối. [1]_

PHYE_SPINUP_HOLD
    - SATA có mặt, COMWAKE không được gửi.

.. [1] should set/clear the appropriate fields in the phy,
       or alternatively call the inlined sas_phy_disconnected()
       which is just a helper, from their tasklet.

Lệnh thực thi SCSI RPC::

int (ZZ0000ZZ, gfp_t gfp_flags);

Được sử dụng để xếp hàng tác vụ tới SAS LLDD.  @task là nhiệm vụ cần thực hiện.
@gfp_mask là gfp_mask xác định ngữ cảnh của người gọi.

Chức năng này sẽ triển khai Lệnh thực thi SCSI RPC,

Nghĩa là, khi lldd_execute_task() được gọi, lệnh
đi ra ngoài bằng phương tiện vận tải ZZ0000ZZ.  Có ZZ0001ZZ
xếp hàng dưới mọi hình thức và ở mọi cấp độ trong SAS LLDD.

Trả về:

* -SAS_QUEUE_FULL, -ENOMEM, không có gì được xếp hàng đợi;
   * 0, (các) tác vụ đã được xếp hàng đợi.

::

cấu trúc sas_task {
	    dev -- thiết bị mà nhiệm vụ này được hướng tới
	    task_proto -- _one_ của enum sas_proto
	    phân tán -- con trỏ để phân tán thu thập mảng danh sách
	    num_scatter - số phần tử trong phân tán
	    Total_xfer_len -- tổng số byte dự kiến sẽ được chuyển
	    dữ liệu_dir -- PCI_DMA_...
	    task_done - gọi lại khi tác vụ đã thực hiện xong
    };

Khám phá
=========

Cây sysfs có các mục đích sau:

a) Nó hiển thị cho bạn bố cục vật lý của miền SAS tại
       thời điểm hiện tại, tức là tên miền trông như thế nào trong
       thế giới vật chất ngay bây giờ.
    b) Hiển thị một số thông số thiết bị _at_discovery_time_.

Đây là đường dẫn tới chương trình cây(1), rất hữu ích trong
xem miền SAS:
ftp://mama.indstate.edu/linux/tree/

Tôi hy vọng các ứng dụng không gian người dùng sẽ thực sự tạo ra một
giao diện đồ họa này.

Nghĩa là, cây miền sysfs không hiển thị hoặc giữ trạng thái nếu
ví dụ: bạn thay đổi ý nghĩa của READY LED MEANING
cài đặt, nhưng nó hiển thị cho bạn trạng thái kết nối hiện tại
của thiết bị miền.

Giữ các thay đổi trạng thái thiết bị nội bộ là trách nhiệm của
các lớp trên (Trình điều khiển bộ lệnh) và không gian người dùng.

Khi một hoặc nhiều thiết bị được rút ra khỏi miền, điều này
được phản ánh ngay lập tức trong cây sysfs và (các) thiết bị
bị loại bỏ khỏi hệ thống.

Cấu trúc domain_device mô tả bất kỳ thiết bị nào trong SAS
miền.  Nó được quản lý hoàn toàn bởi lớp SAS.  một nhiệm vụ
trỏ đến một thiết bị miền, đây là cách SAS LLDD biết
nơi để gửi (các) nhiệm vụ đến.  SAS LLDD chỉ đọc
nội dung của cấu trúc domain_device, nhưng nó không bao giờ tạo
hoặc phá hủy một.

Quản lý mở rộng từ Không gian người dùng
===================================

Trong mỗi thư mục mở rộng trong sysfs, có một tệp có tên
"smp_portal".  Nó là một tệp thuộc tính sysfs nhị phân,
triển khai cổng SMP (Lưu ý: đây là ZZ0000ZZ và cổng SMP),
ứng dụng không gian người dùng nào có thể gửi yêu cầu SMP và
nhận được phản hồi SMP.

Chức năng rất đơn giản:

1. Xây dựng khung SMP mà bạn muốn gửi. Định dạng và bố cục
   được mô tả trong thông số SAS.  Để trường CRC bằng 0.

mở(2)

2. Mở tệp sysfs cổng SMP của thiết bị mở rộng ở chế độ RW.

viết(2)

3. Viết khung bạn đã xây dựng trong 1.

đọc(2)

4. Đọc lượng dữ liệu bạn mong đợi nhận được cho khung bạn đã tạo.
   Nếu bạn nhận được lượng dữ liệu khác nhau mà bạn mong đợi,
   sau đó đã xảy ra một số loại lỗi.

đóng(2)

Tất cả quá trình này được hiển thị chi tiết trong hàm do_smp_func()
và người gọi nó, trong tệp "expander_conf.c".

Chức năng kernel được triển khai trong tệp
"sas_expander.c".

Chương trình "expander_conf.c" thực hiện điều này. Phải mất một
đối số, tên tệp sysfs của cổng SMP tới
thiết bị mở rộng và cung cấp thông tin về thiết bị mở rộng, bao gồm cả việc định tuyến
các bảng.

Cổng SMP cung cấp cho bạn toàn quyền kiểm soát thiết bị mở rộng,
vì vậy xin hãy cẩn thận.