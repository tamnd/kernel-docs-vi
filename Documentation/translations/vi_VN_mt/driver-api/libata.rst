.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/libata.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
Hướng dẫn dành cho nhà phát triển libATA
========================================

:Tác giả: Jeff Garzik

Giới thiệu
============

libATA là thư viện được sử dụng bên trong nhân Linux để hỗ trợ máy chủ ATA
bộ điều khiển và thiết bị. libATA cung cấp trình điều khiển ATA API, lớp
vận chuyển cho các thiết bị ATA và ATAPI, và bản dịch SCSI<->ATA cho ATA
các thiết bị theo thông số kỹ thuật T10 SAT.

Hướng dẫn này ghi lại trình điều khiển libATA API, chức năng thư viện, thư viện
bộ phận bên trong và một vài trình điều khiển cấp thấp mẫu ATA.

Trình điều khiển libata API
=================

ZZ0000ZZ
được xác định cho mọi libata cấp thấp
trình điều khiển phần cứng và nó kiểm soát cách giao diện của trình điều khiển cấp thấp
với các lớp ATA và SCSI.

Trình điều khiển dựa trên FIS sẽ kết nối vào hệ thống với ZZ0000ZZ và
Móc treo cao cấp ZZ0001ZZ. Phần cứng hoạt động theo cách
tương tự như PCI Phần cứng IDE có thể sử dụng một số trợ giúp chung,
xác định ở mức tối thiểu các địa chỉ I/O bus của bóng ATA
đăng ký khối.

ZZ0000ZZ
----------------------------------------------------------

Cấu hình thiết bị sau IDENTIFY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

khoảng trống (ZZ0000ZZ, struct ata_device *);


Được gọi sau IDENTIFY [PACKET] DEVICE được cấp cho mỗi thiết bị được tìm thấy.
Thường được sử dụng để áp dụng các bản sửa lỗi dành riêng cho thiết bị trước khi phát hành SET
FEATURES - XFER MODE và trước khi hoạt động.

Mục nhập này có thể được chỉ định là NULL trong ata_port_Operations.

Đặt chế độ PIO/DMA
~~~~~~~~~~~~~~~~

::

khoảng trống (ZZ0000ZZ, struct ata_device *);
    khoảng trống (ZZ0001ZZ, struct ata_device *);
    khoảng trống (ZZ0002ZZ);
    int không dấu (ZZ0003ZZ, struct ata_device *, int không dấu);


Hook được gọi trước khi phát hành lệnh SET FEATURES - XFER MODE. các
Móc ZZ0000ZZ tùy chọn được gọi khi libata đã tạo mặt nạ
các chế độ có thể. Điều này được chuyển đến hàm ZZ0001ZZ
sẽ trả về mặt nạ của các chế độ hợp lệ sau khi lọc các chế độ đó
không phù hợp do giới hạn phần cứng. Nó không hợp lệ để sử dụng giao diện này
để thêm các chế độ.

ZZ0000ZZ và ZZ0001ZZ được đảm bảo hợp lệ khi
ZZ0002ZZ và khi ZZ0003ZZ được gọi. Thời gian dành cho
bất kỳ ổ đĩa nào khác chia sẻ cáp cũng sẽ hợp lệ tại thời điểm này. Đó
thư viện có ghi lại các quyết định về chế độ của từng ổ đĩa trên một
kênh trước khi nó cố gắng thiết lập bất kỳ kênh nào trong số chúng.

ZZ0000ZZ được gọi vô điều kiện, sau SET FEATURES -
Lệnh XFER MODE hoàn tất thành công.

ZZ0000ZZ luôn được gọi (nếu có), nhưng ZZ0001ZZ
chỉ được gọi nếu DMA có thể.

Đọc/ghi tệp tác vụ
~~~~~~~~~~~~~~~~~~~

::

khoảng trống (*sff_tf_load) (struct ata_port *ap, struct ata_taskfile *tf);
    khoảng trống (*sff_tf_read) (struct ata_port *ap, struct ata_taskfile *tf);


ZZ0002ZZ được gọi để tải tệp tác vụ đã cho vào phần cứng
thanh ghi/bộ đệm DMA. ZZ0003ZZ được gọi để đọc phần cứng
thanh ghi / bộ đệm DMA, để có được bộ thanh ghi tệp tác vụ hiện tại
các giá trị. Hầu hết các trình điều khiển cho phần cứng dựa trên taskfile (PIO hoặc MMIO) đều sử dụng
ZZ0000ZZ và ZZ0001ZZ cho các móc này.

Đọc/ghi dữ liệu PIO
~~~~~~~~~~~~~~~~~~~

::

void (ZZ0000ZZ, unsigned char *, unsigned int, int);


Tất cả các trình điều khiển kiểu bmdma phải triển khai hook này. Đây là mức độ thấp
hoạt động thực sự sao chép các byte dữ liệu trong dữ liệu PIO
chuyển nhượng. Thông thường người lái xe sẽ chọn một trong
ZZ0000ZZ, hoặc ZZ0001ZZ.

Thực thi lệnh ATA
~~~~~~~~~~~~~~~~~~~

::

khoảng trống (*sff_exec_command)(struct ata_port *ap, struct ata_taskfile *tf);


làm cho lệnh ATA, được tải trước đó bằng ZZ0001ZZ, bị
bắt đầu trong phần cứng. Hầu hết các trình điều khiển để sử dụng phần cứng dựa trên taskfile
ZZ0000ZZ cho cái móc này.

Bộ lọc khả năng ATAPI DMA trên mỗi cmd
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

int (*check_atapi_dma) (struct ata_queued_cmd *qc);


Cho phép trình điều khiển cấp thấp lọc các lệnh ATA PACKET, trả về trạng thái
cho biết liệu có thể sử dụng DMA cho PACKET được cung cấp hay không
lệnh.

Móc này có thể được chỉ định là NULL, trong trường hợp đó libata sẽ giả sử
atapi dma đó có thể được hỗ trợ.

Đọc các thanh ghi bóng ATA cụ thể
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

u8 (*sff_check_status)(struct ata_port *ap);
    u8 (*sff_check_altstatus)(struct ata_port *ap);


Đọc thanh ghi bóng Status/AltStatus ATA từ phần cứng. Trên một số
phần cứng, việc đọc thanh ghi Trạng thái có tác dụng phụ là xóa
điều kiện ngắt. Hầu hết các trình điều khiển để sử dụng phần cứng dựa trên taskfile
ZZ0000ZZ cho cái móc này.

Viết thanh ghi bóng ATA cụ thể
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

khoảng trống (*sff_set_devctl)(struct ata_port *ap, u8 ctl);


Ghi thanh ghi bóng ATA điều khiển thiết bị vào phần cứng. Hầu hết
trình điều khiển không cần phải xác định điều này.

Chọn thiết bị ATA trên xe buýt
~~~~~~~~~~~~~~~~~~~~~~~~

::

void (*sff_dev_select)(struct ata_port *ap, thiết bị unsigned int);


Đưa ra (các) lệnh phần cứng cấp thấp gây ra một trong N phần cứng
các thiết bị được coi là 'được chọn' (đang hoạt động và sẵn sàng để sử dụng) trên
xe buýt ATA. Điều này thường không có ý nghĩa trên các thiết bị dựa trên FIS.

Hầu hết các trình điều khiển cho phần cứng dựa trên taskfile đều sử dụng ZZ0000ZZ cho
cái móc này.

Phương pháp điều chỉnh riêng
~~~~~~~~~~~~~~~~~~~~~

::

khoảng trống (*set_mode) (struct ata_port *ap);


Theo mặc định, libata thực hiện điều chỉnh ổ đĩa và bộ điều khiển theo
với các quy tắc thời gian ATA, đồng thời áp dụng danh sách đen và giới hạn cáp.
Một số bộ điều khiển cần xử lý đặc biệt và có quy tắc điều chỉnh tùy chỉnh,
thường đột kích các bộ điều khiển sử dụng lệnh ATA nhưng thực tế không làm như vậy
thời gian lái xe.

ZZ0000ZZ

Móc này không nên được sử dụng để thay thế bộ điều khiển tiêu chuẩn
    điều chỉnh logic khi bộ điều khiển có vấn đề. Thay thế mặc định
    logic điều chỉnh trong trường hợp đó sẽ bỏ qua việc xử lý ổ đĩa và cầu nối
    những điều kỳ quặc có thể quan trọng đối với độ tin cậy của dữ liệu. Nếu một bộ điều khiển
    cần lọc lựa chọn chế độ nên sử dụng mode_filter
    móc thay vào đó.

Điều khiển động cơ PCI IDE BMDMA
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

khoảng trống (*bmdma_setup) (struct ata_queued_cmd *qc);
    khoảng trống (*bmdma_start) (struct ata_queued_cmd *qc);
    khoảng trống (*bmdma_stop) (struct ata_port *ap);
    u8 (*bmdma_status) (struct ata_port *ap);


Khi thiết lập giao dịch IDE BMDMA, các nhánh móc này
(ZZ0000ZZ), bắn (ZZ0001ZZ) và dừng (ZZ0002ZZ)
động cơ DMA của phần cứng. ZZ0003ZZ được sử dụng để đọc PCI tiêu chuẩn
IDE DMA Thanh ghi trạng thái.

Những hook này thường không hoạt động hoặc đơn giản là không được triển khai trong
Trình điều khiển dựa trên FIS.

Hầu hết các trình điều khiển IDE cũ đều sử dụng ZZ0000ZZ cho
Móc ZZ0001ZZ. ZZ0002ZZ sẽ ghi con trỏ
tới bảng PRD tới thanh ghi Địa chỉ bảng IDE PRD, bật DMA trong DMA
Đăng ký lệnh và gọi ZZ0003ZZ để bắt đầu truyền.

Hầu hết các trình điều khiển IDE cũ đều sử dụng ZZ0000ZZ cho
Móc ZZ0001ZZ. ZZ0002ZZ sẽ viết
Cờ ATA_DMA_START vào thanh ghi Lệnh DMA.

Nhiều trình điều khiển IDE cũ sử dụng ZZ0000ZZ cho
Móc ZZ0001ZZ. ZZ0002ZZ xóa ATA_DMA_START
cờ trong thanh ghi lệnh DMA.

Nhiều trình điều khiển IDE cũ sử dụng ZZ0000ZZ làm
Móc ZZ0001ZZ.

Móc tệp tác vụ cấp cao
~~~~~~~~~~~~~~~~~~~~~~~~~

::

enum ata_completion_errors (*qc_prep) (struct ata_queued_cmd *qc);
    int (*qc_issue) (struct ata_queued_cmd *qc);


Móc cấp cao hơn, hai móc này có khả năng thay thế một số móc
tệp tác vụ/móc động cơ DMA ở trên. ZZ0002ZZ được gọi theo
bộ đệm đã được ánh xạ DMA và thường được sử dụng để điền vào
bảng thu thập phân tán DMA của phần cứng. Một số trình điều khiển sử dụng tiêu chuẩn
Người trợ giúp ZZ0000ZZ và ZZ0001ZZ
các chức năng, nhưng các trình điều khiển nâng cao hơn sẽ tự hoạt động.

ZZ0001ZZ được sử dụng để kích hoạt lệnh khi phần cứng và S/G
các bảng đã được chuẩn bị sẵn. Trình điều khiển IDE BMDMA sử dụng chức năng trợ giúp
ZZ0000ZZ để gửi dựa trên giao thức tệp tác vụ. Thêm
trình điều khiển nâng cao triển khai ZZ0002ZZ của riêng họ.

ZZ0000ZZ gọi ZZ0001ZZ, ZZ0002ZZ và
ZZ0003ZZ khi cần thiết để bắt đầu chuyển giao.

Xử lý ngoại lệ và thăm dò (EH)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

khoảng trống (*freeze) (struct ata_port *ap);
    khoảng trống (*thaw) (struct ata_port *ap);


ZZ0000ZZ được gọi khi vi phạm HSM hoặc một số lỗi khác
tình trạng này làm gián đoạn hoạt động bình thường của cảng. Một cảng bị đóng băng thì không
được phép thực hiện bất kỳ thao tác nào cho đến khi cổng tan băng, điều này thường
sau khi thiết lập lại thành công.

Có thể sử dụng lệnh gọi lại ZZ0000ZZ tùy chọn để đóng băng cổng
thông minh về phần cứng (ví dụ: ngắt mặt nạ và dừng động cơ DMA). Nếu một cổng
không thể bị đóng băng về mặt phần cứng, trình xử lý ngắt phải xác nhận và xóa
ngắt vô điều kiện trong khi cổng bị đóng băng.

Cuộc gọi lại ZZ0000ZZ tùy chọn được gọi để thực hiện ngược lại
ZZ0001ZZ: chuẩn bị cổng hoạt động bình thường trở lại. Vạch mặt
ngắt, khởi động động cơ DMA, v.v.

::

khoảng trống (*error_handler) (struct ata_port *ap);


ZZ0001ZZ là một trình điều khiển gắn vào đầu dò, cắm nóng và phục hồi
và các điều kiện đặc biệt khác. Trách nhiệm chính của một
thực hiện là gọi ZZ0000ZZ.

ZZ0000ZZ sẽ thực hiện trình tự xử lý lỗi tiêu chuẩn
phục hồi các thiết bị bị lỗi, tháo thiết bị bị mất và thêm thiết bị mới (nếu có).
Hàm này sẽ gọi các hoạt động thiết lập lại khác nhau cho một cổng nếu cần.
Các hoạt động này như sau.

* Hoạt động 'đặt lại trước' (có thể là NULL) được gọi trong quá trình đặt lại EH,
  trước khi thực hiện bất kỳ hành động nào khác.

* Hook 'postreset' (có thể là NULL) được gọi sau khi quá trình thiết lập lại EH được thực hiện
  được thực hiện. Dựa trên các điều kiện hiện có, mức độ nghiêm trọng của sự cố và phần cứng
  khả năng,

* Thao tác 'softreset' hoặc thao tác 'hardreset' sẽ được gọi
  để thực hiện thiết lập lại EH mức thấp. Nếu cả hai hoạt động được xác định,
  'hardreset' được ưa thích và sử dụng. Nếu cả hai không được xác định, không có thiết lập lại ở mức độ thấp
  được thực hiện và EH giả định rằng thiết bị lớp ATA được kết nối thông qua
  liên kết.

::

khoảng trống (*post_internal_cmd) (struct ata_queued_cmd *qc);


Thực hiện mọi hành động dành riêng cho phần cứng cần thiết để hoàn tất quá trình xử lý
sau khi thực hiện lệnh thời gian thăm dò hoặc thời gian EH thông qua
ZZ0000ZZ.

Xử lý ngắt phần cứng
~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

irqreturn_t (ZZ0000ZZ, struct pt_regs *);
    khoảng trống (ZZ0001ZZ);


ZZ0000ZZ là quy trình xử lý ngắt được đăng ký với
hệ thống, bởi libata. ZZ0001ZZ được gọi trong quá trình thăm dò ngay trước
trình xử lý ngắt đã được đăng ký để đảm bảo phần cứng yên tĩnh.

Đối số thứ hai, dev_instance, phải được chuyển thành một con trỏ tới
ZZ0000ZZ.

Hầu hết các trình điều khiển IDE cũ đều sử dụng ZZ0000ZZ cho irq_handler
hook, quét tất cả các cổng trong Host_set, xác định cổng nào được xếp hàng đợi
lệnh đã hoạt động (nếu có) và gọi ata_sff_host_intr(ap,qc).

Hầu hết các trình điều khiển IDE cũ đều sử dụng ZZ0000ZZ cho
Móc ZZ0001ZZ, chỉ đơn giản là xóa các cờ ngắt và lỗi
trong thanh ghi trạng thái DMA.

SATA phy đọc/ghi
~~~~~~~~~~~~~~~~~~~

::

int (*scr_read) (struct ata_port *ap, unsign int sc_reg,
             u32 *val);
    int (*scr_write) (struct ata_port *ap, unsigned int sc_reg,
                       giá trị u32);


Đọc và ghi các thanh ghi phy SATA tiêu chuẩn.
sc_reg là một trong các SCR_STATUS, SCR_CONTROL, SCR_ERROR hoặc SCR_ACTIVE.

Khởi tạo và tắt máy
~~~~~~~~~~~~~~~~~

::

int (*port_start) (struct ata_port *ap);
    khoảng trống (*port_stop) (struct ata_port *ap);
    khoảng trống (*host_stop) (struct ata_host_set *host_set);


ZZ0000ZZ được gọi ngay sau cấu trúc dữ liệu cho mỗi cổng
được khởi tạo. Thông thường, điều này được sử dụng để phân bổ bộ đệm DMA trên mỗi cổng /
bảng / vòng, kích hoạt động cơ DMA và các tác vụ tương tự. Một số tài xế cũng
sử dụng điểm vào này như một cơ hội để phân bổ bộ nhớ riêng của trình điều khiển cho
ZZ0001ZZ.

Nhiều tài xế sử dụng ZZ0000ZZ làm cái móc này hoặc gọi nó theo tên của họ
móc ZZ0001ZZ riêng. ZZ0002ZZ phân bổ không gian cho
một bảng IDE PRD kế thừa và trả về.

ZZ0000ZZ được gọi theo ZZ0001ZZ. Chức năng duy nhất của nó là
giải phóng tài nguyên bộ nhớ/DMA, bây giờ chúng không còn hoạt động tích cực nữa
đã sử dụng. Nhiều trình điều khiển cũng giải phóng dữ liệu riêng tư của trình điều khiển khỏi cổng vào thời điểm này.

ZZ0000ZZ được gọi sau khi tất cả các cuộc gọi ZZ0001ZZ đã hoàn thành.
Móc phải hoàn tất việc tắt phần cứng, giải phóng DMA và các thiết bị khác
tài nguyên, v.v. Hook này có thể được chỉ định là NULL, trong trường hợp đó nó là
not called.

Xử lý lỗi
==============

Chương này mô tả cách xử lý lỗi theo libata. Người đọc là
khuyên nên đọc SCSI EH (Documentation/scsi/scsi_eh.rst) và ATA
tài liệu ngoại lệ đầu tiên.

Nguồn gốc của lệnh
-------------------

Trong libata, một lệnh được biểu diễn bằng
ZZ0000ZZ hoặc qc.
qc được phân bổ trước trong quá trình khởi tạo cổng và được sử dụng lặp đi lặp lại
cho việc thực thi lệnh. Hiện tại chỉ có một qc được phân bổ cho mỗi cổng nhưng
Nhánh NCQ chưa được hợp nhất phân bổ một cái cho mỗi thẻ và ánh xạ từng qc
tới thẻ NCQ 1-1.

Các lệnh libata có thể bắt nguồn từ hai nguồn - chính libata và SCSI
lớp giữa. Các lệnh nội bộ libata được sử dụng để khởi tạo và báo lỗi
xử lý. Tất cả các yêu cầu và lệnh blk thông thường để mô phỏng SCSI đều
được chuyển dưới dạng lệnh SCSI thông qua lệnh gọi lại queuecommand của máy chủ SCSI
mẫu.

Lệnh được ban hành như thế nào
-----------------------

Lệnh nội bộ
    Khi tệp tác vụ của qc được phân bổ được khởi tạo để lệnh được thực hiện
    bị xử tử. qc hiện có hai cơ chế thông báo hoàn thành. một
    là thông qua cuộc gọi lại ZZ0000ZZ và cách còn lại là hoàn thành
    ZZ0001ZZ. Gọi lại ZZ0002ZZ là đường dẫn không đồng bộ
    được sử dụng bởi các lệnh dịch SCSI thông thường và ZZ0003ZZ là
    đường dẫn đồng bộ (nhà phát hành ngủ trong ngữ cảnh quy trình) được sử dụng bởi nội bộ
    lệnh.

Khi quá trình khởi tạo hoàn tất, khóa Host_set sẽ được lấy và
    qc được phát hành.

Các lệnh SCSI
    Tất cả các trình điều khiển libata đều sử dụng ZZ0000ZZ làm
    Gọi lại ZZ0001ZZ. scmds có thể được mô phỏng hoặc
    đã dịch. Không có qc nào liên quan đến việc xử lý scmd mô phỏng. các
    kết quả được tính ngay và scmd được hoàn thành.

Gọi lại ZZ0003ZZ được sử dụng để thông báo hoàn thành. ATA
    lệnh sử dụng ZZ0000ZZ trong khi lệnh ATAPI sử dụng
    ZZ0001ZZ. Cả hai chức năng đều gọi ZZ0004ZZ
    để thông báo cho lớp trên khi quá trình qc kết thúc. Sau khi dịch là
    hoàn thành, qc được cấp ZZ0002ZZ.

Lưu ý rằng lớp giữa SCSI gọi Hostt->queuecommand trong khi giữ
    khóa Host_set, vì vậy tất cả những điều trên xảy ra khi giữ khóa Host_set.

Cách xử lý các lệnh
--------------------------

Tùy thuộc vào giao thức nào và bộ điều khiển nào được sử dụng, các lệnh được
được xử lý khác nhau. Với mục đích thảo luận, một bộ điều khiển
sử dụng giao diện taskfile và tất cả các cuộc gọi lại tiêu chuẩn được giả định.

Hiện tại có 6 giao thức lệnh ATA được sử dụng. Chúng có thể được sắp xếp vào
theo bốn loại sau đây tùy theo cách chúng được xử lý.

ATA KHÔNG DATA hoặc DMA
    ATA_PROT_NODATA và ATA_PROT_DMA thuộc loại này. Những cái này
    các loại lệnh không yêu cầu bất kỳ sự can thiệp nào của phần mềm một lần
    ban hành. Thiết bị sẽ tăng ngắt khi hoàn thành.

ATA PIO
    ATA_PROT_PIO nằm trong danh mục này. libata hiện đang triển khai PIO
    với việc bỏ phiếu. Bit ATA_NIEN được thiết lập để tắt ngắt và
    pio_task trên ata_wq thực hiện bỏ phiếu và IO.

ATAPI NODATA hoặc DMA
    ATA_PROT_ATAPI_NODATA và ATA_PROT_ATAPI_DMA nằm trong đây
    thể loại. packet_task được sử dụng để thăm dò bit BSY sau khi phát hành PACKET
    lệnh. Sau khi thiết bị tắt BSY, packet_task
    chuyển CDB và chuyển việc xử lý sang trình xử lý ngắt.

ATAPI PIO
    ATA_PROT_ATAPI nằm trong danh mục này. Bit ATA_NIEN được thiết lập và, như
    trong ATAPI NODATA hoặc DMA, packet_task gửi cdb. Tuy nhiên, sau
    gửi cdb, việc xử lý tiếp theo (truyền dữ liệu) sẽ được chuyển cho
    pio_task.

Cách hoàn thành các lệnh
--------------------------

Sau khi được ban hành, tất cả qc đều được hoàn thành bằng ZZ0000ZZ hoặc
hết giờ rồi. Đối với các lệnh được xử lý bằng ngắt,
ZZ0001ZZ gọi ZZ0002ZZ và đối với các tác vụ PIO,
pio_task gọi ZZ0003ZZ. Trong trường hợp có lỗi, packet_task có thể
cũng hoàn thành các lệnh.

ZZ0000ZZ thực hiện như sau.

1. Bộ nhớ DMA chưa được ánh xạ.

2. ATA_QCFLAG_ACTIVE bị xóa khỏi qc->flag.

3. Gọi lại ZZ0000ZZ được gọi. Nếu giá trị trả về của
   gọi lại không phải là số không. Quá trình hoàn thành bị ngắn mạch và
   ZZ0001ZZ trở lại.

4. ZZ0000ZZ được gọi, nghĩa là

1. ZZ0000ZZ bị xóa về 0.

2. ZZ0000ZZ và ZZ0001ZZ bị nhiễm độc.

3. ZZ0000ZZ được xóa và hoàn thành (theo thứ tự đó).

4. qc được giải phóng bằng cách xóa bit thích hợp trong ZZ0000ZZ.

Vì vậy, về cơ bản nó sẽ thông báo cho lớp trên và phân bổ qc. Một ngoại lệ
là đường dẫn ngắn mạch trong #3 được ZZ0000ZZ sử dụng.

Đối với tất cả các lệnh không phải ATAPI, dù có thất bại hay không thì gần như giống nhau
đường dẫn mã được thực hiện và rất ít việc xử lý lỗi xảy ra. Một qc là
hoàn thành với trạng thái thành công nếu thành công, với trạng thái thất bại
mặt khác.

Tuy nhiên, các lệnh ATAPI không thành công yêu cầu xử lý nhiều hơn như REQUEST SENSE
cần thiết để có được dữ liệu giác quan. Nếu lệnh ATAPI không thành công,
ZZ0000ZZ được gọi với trạng thái lỗi, từ đó gọi ra
ZZ0001ZZ thông qua gọi lại ZZ0002ZZ.

Điều này làm cho ZZ0000ZZ được đặt ZZ0003ZZ thành
SAM_STAT_CHECK_CONDITION, hoàn thành scmd và trả về 1. Như
dữ liệu cảm nhận trống nhưng ZZ0004ZZ là CHECK CONDITION, lớp giữa SCSI
sẽ gọi EH cho scmd và trả về 1 tạo thành ZZ0001ZZ
để quay lại mà không giải phóng qc. Điều này dẫn chúng ta đến
ZZ0002ZZ với qc đã hoàn thành một phần.

ZZ0000ZZ
------------------------

ZZ0000ZZ là ZZ0002ZZ hiện tại
cho libata. Như đã thảo luận ở trên, điều này sẽ được nhập vào hai trường hợp -
hết thời gian chờ và hoàn thành lỗi ATAPI. Chức năng này sẽ kiểm tra xem qc có hoạt động không
và vẫn chưa thất bại. Một qc như vậy sẽ được đánh dấu bằng AC_ERR_TIMEOUT sao cho
EH sẽ biết cách xử lý sau. Sau đó, nó gọi trình điều khiển libata cấp thấp
Gọi lại ZZ0001ZZ.

Khi lệnh gọi lại ZZ0000ZZ được gọi, nó sẽ dừng BMDMA và
hoàn thành qc. Lưu ý rằng vì chúng tôi hiện đang ở EH nên chúng tôi không thể gọi
scsi_done. Như được mô tả trong tài liệu SCSI EH, một scmd đã được khôi phục phải là
hoặc thử lại với ZZ0001ZZ hoặc kết thúc với
ZZ0002ZZ. Ở đây, chúng tôi ghi đè ZZ0005ZZ bằng
ZZ0003ZZ và gọi ZZ0004ZZ.

Nếu EH được gọi do qc ATAPI bị lỗi thì qc ở đây đã hoàn thành nhưng
không được giải phóng. Mục đích của việc hoàn thành một nửa này là sử dụng qc làm
người giữ chỗ để mã EH đến được nơi này. Điều này hơi hackish,
nhưng nó hoạt động.

Khi quyền điều khiển đến đây, qc sẽ được giải phóng bằng cách gọi
ZZ0000ZZ một cách rõ ràng. Sau đó, qc nội bộ cho REQUEST SENSE
được ban hành. Khi dữ liệu giác quan được thu thập, scmd được hoàn thành trực tiếp
gọi ZZ0001ZZ trên scmd. Lưu ý rằng như chúng ta đã
đã hoàn thành và giải phóng qc được liên kết với
scmd, chúng tôi không cần/không thể gọi lại ZZ0002ZZ.

Các vấn đề với EH hiện tại
----------------------------

- Trình bày lỗi quá thô thiển. Hiện tại bất kỳ và tất cả các lỗi
   các điều kiện được biểu diễn bằng các thanh ghi ATA STATUS và ERROR.
   Các lỗi không phải là lỗi thiết bị ATA sẽ được coi là thiết bị ATA
   lỗi bằng cách thiết lập bit ATA_ERR. Bộ mô tả lỗi tốt hơn có thể
   cần thể hiện đúng ATA và các lỗi/ngoại lệ khác.

- Khi xử lý thời gian chờ, không có hành động nào được thực hiện để khiến thiết bị quên
   về lệnh hết thời gian chờ và sẵn sàng cho lệnh mới.

- Xử lý EH qua ZZ0000ZZ không được bảo vệ đúng cách khỏi
   xử lý lệnh thông thường. Trên lối vào EH, thiết bị không ở trong
   trạng thái tĩnh lặng. Lệnh hết thời gian có thể thành công hoặc thất bại bất cứ lúc nào.
   pio_task và atapi_task có thể vẫn đang chạy.

- Khả năng phục hồi lỗi quá yếu. Thiết bị/bộ điều khiển khiến HSM không khớp
   lỗi và các lỗi khác thường yêu cầu thiết lập lại để trở về trạng thái đã biết
   trạng thái. Ngoài ra, việc xử lý lỗi nâng cao cũng cần thiết để hỗ trợ các tính năng
   như NCQ và hotplug.

- Lỗi ATA được xử lý trực tiếp trong bộ xử lý ngắt và PIO
   lỗi trong pio_task. Đây là vấn đề đối với việc xử lý lỗi nâng cao
   vì những lý do sau.

Đầu tiên, xử lý lỗi nâng cao thường yêu cầu ngữ cảnh và qc nội bộ
   thi hành.

Thứ hai, ngay cả một lỗi đơn giản (chẳng hạn như lỗi CRC) cũng cần có thông tin
   thu thập và có thể kích hoạt việc xử lý lỗi phức tạp (chẳng hạn như đặt lại &
   cấu hình lại). Có nhiều đường dẫn mã để thu thập thông tin,
   nhập EH và kích hoạt các hành động khiến cuộc sống trở nên đau đớn.

Thứ ba, mã EH phân tán khiến việc triển khai trình điều khiển cấp thấp
   khó khăn. Trình điều khiển cấp thấp ghi đè lệnh gọi lại libata. Nếu EH là
   nằm rải rác ở một số nơi, mỗi lệnh gọi lại bị ảnh hưởng sẽ thực hiện
   đó là một phần của việc xử lý lỗi. Điều này có thể dễ bị lỗi và đau đớn.

thư viện libata
==============

.. kernel-doc:: drivers/ata/libata-core.c
   :export:

libata Nội bộ cốt lõi
=====================

.. kernel-doc:: drivers/ata/libata-core.c
   :internal:

.. kernel-doc:: drivers/ata/libata-eh.c

libata SCSI dịch/mô phỏng
=================================

.. kernel-doc:: drivers/ata/libata-scsi.c
   :export:

.. kernel-doc:: drivers/ata/libata-scsi.c
   :internal:

Lỗi và ngoại lệ của ATA
=========================

Chương này cố gắng xác định những điều kiện lỗi/ngoại lệ nào tồn tại đối với
Các thiết bị ATA/ATAPI và mô tả cách xử lý chúng trong
cách trung lập thực hiện.

Thuật ngữ 'lỗi' được sử dụng để mô tả các điều kiện trong đó một lỗi rõ ràng
tình trạng lỗi được báo cáo từ thiết bị hoặc lệnh đã hết thời gian chờ.

Thuật ngữ 'ngoại lệ' được sử dụng để mô tả các điều kiện đặc biệt
không phải là lỗi (chẳng hạn như sự kiện nguồn hoặc cắm nóng) hoặc để mô tả cả hai
lỗi và các điều kiện ngoại lệ không có lỗi. Nơi phân biệt rõ ràng
giữa lỗi và ngoại lệ là cần thiết, thuật ngữ 'ngoại lệ không có lỗi'
được sử dụng.

Danh mục ngoại lệ
--------------------

Các ngoại lệ được mô tả chủ yếu liên quan đến taskfile + bus kế thừa
giao diện IDE chính. Nếu bộ điều khiển cung cấp cơ chế khác tốt hơn
để báo cáo lỗi, ánh xạ chúng vào các danh mục được mô tả bên dưới
không nên khó khăn.

Trong các phần sau, hai hành động khôi phục - đặt lại và
cấu hình lại vận chuyển - được đề cập. Những điều này được mô tả thêm trong
ZZ0000ZZ.

Vi phạm HSM
~~~~~~~~~~~~~

Lỗi này được biểu thị khi giá trị STATUS không khớp với yêu cầu HSM
trong khi phát hành hoặc thực hiện bất kỳ lệnh ATA/ATAPI nào.

- ATA_STATUS không chứa !BSY && DRDY && !DRQ khi cố gắng
   ra lệnh.

- !BSY && !DRQ trong quá trình truyền dữ liệu PIO.

- DRQ khi hoàn thành lệnh.

- !BSY && ERR sau khi quá trình truyền CDB bắt đầu nhưng trước byte cuối cùng của CDB
   được chuyển giao. Tiêu chuẩn ATA/ATAPI nêu rõ rằng "Thiết bị không được
   kết thúc lệnh PACKET với một lỗi trước byte cuối cùng của
   gói lệnh đã được ghi" trong phần mô tả đầu ra lỗi
   của lệnh PACKET và sơ đồ trạng thái không bao gồm lệnh đó
   chuyển tiếp.

Trong những trường hợp này, HSM bị vi phạm và không có nhiều thông tin liên quan đến
lỗi có thể xảy ra từ thanh ghi STATUS hoặc ERROR. IOW, lỗi này có thể
bất cứ điều gì - lỗi trình điều khiển, thiết bị bị lỗi, bộ điều khiển và/hoặc cáp.

Vì HSM bị vi phạm nên cần thiết lập lại để khôi phục trạng thái đã biết.
Cấu hình lại phương tiện vận chuyển để có tốc độ thấp hơn cũng có thể hữu ích vì
lỗi truyền tải đôi khi gây ra loại lỗi này.

Lỗi thiết bị ATA/ATAPI (không phải NCQ / không phải CHECK CONDITION)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Đây là những lỗi được phát hiện và báo cáo bởi các thiết bị ATA/ATAPI cho biết
vấn đề về thiết bị. Đối với loại lỗi này, hãy đăng ký STATUS và ERROR
các giá trị hợp lệ và mô tả tình trạng lỗi. Lưu ý rằng một số xe buýt ATA
lỗi được phát hiện bởi các thiết bị ATA/ATAPI và được báo cáo bằng cách sử dụng cùng một
cơ chế như lỗi thiết bị. Những trường hợp đó sẽ được mô tả sau trong phần này
phần.

Đối với các lệnh ATA, loại lỗi này được biểu thị bằng !BSY && ERR
trong quá trình thực hiện lệnh và khi hoàn thành.

Đối với các lệnh ATAPI,

- !BSY && ERR && ABRT ngay sau khi phát hành PACKET cho biết rằng PACKET
   lệnh không được hỗ trợ và rơi vào danh mục này.

- !BSY && ERR(==CHK) && !ABRT sau khi byte cuối cùng của CDB được chuyển
   biểu thị CHECK CONDITION và không thuộc danh mục này.

- !BSY && ERR(==CHK) && ABRT sau khi byte cuối cùng của CDB được chuyển
   \ZZ0000ZZ biểu thị CHECK CONDITION và không thuộc trường hợp này
   thể loại.

Trong số các lỗi được phát hiện như trên, các lỗi sau không phải là thiết bị ATA/ATAPI
nhưng lỗi bus ATA và cần được xử lý theo
ZZ0000ZZ.

Lỗi CRC trong quá trình truyền dữ liệu
    Điều này được biểu thị bằng bit ICRC trong thanh ghi ERROR và có nghĩa là
    hỏng hóc xảy ra trong quá trình truyền dữ liệu. Lên đến ATA/ATAPI-7,
    tiêu chuẩn quy định rằng bit này chỉ áp dụng cho UDMA
    chuyển nhưng bản sửa đổi dự thảo ATA/ATAPI-8 1f nói rằng bit có thể
    áp dụng cho nhiều từ DMA và PIO.

Lỗi ABRT trong quá trình truyền dữ liệu hoặc khi hoàn thành
    Lên đến ATA/ATAPI-7, tiêu chuẩn chỉ định rằng ABRT có thể được đặt trên
    Lỗi ICRC và trong trường hợp thiết bị không thể hoàn thành
    lệnh. Kết hợp với việc lỗi chuyển MWDMA và PIO
    không được phép sử dụng bit ICRC lên tới ATA/ATAPI-7, điều đó dường như ngụ ý
    riêng bit ABRT đó có thể chỉ ra lỗi truyền.

Tuy nhiên, bản dự thảo sửa đổi 1f của ATA/ATAPI-8 đã loại bỏ phần ICRC
    lỗi có thể bật ABRT. Vì vậy, đây là loại vùng màu xám. Một số
    heuristics là cần thiết ở đây.

Lỗi thiết bị ATA/ATAPI có thể được phân loại thêm như sau.

Lỗi phương tiện
    Điều này được biểu thị bằng bit UNC trong thanh ghi ERROR. Thiết bị ATA
    chỉ báo lỗi UNC sau một số lần thử lại nhất định không thể
    khôi phục dữ liệu, vì vậy không có gì khác để làm ngoài việc
    thông báo lớp trên.

Các lệnh READ và WRITE báo cáo CHS hoặc LBA của khu vực bị lỗi đầu tiên
    nhưng tiêu chuẩn ATA/ATAPI chỉ định rằng lượng dữ liệu được truyền
    khi hoàn thành lỗi là không xác định được, vì vậy chúng tôi không thể cho rằng
    các lĩnh vực trước lĩnh vực thất bại đã được chuyển giao và do đó
    không thể hoàn thành các lĩnh vực đó thành công như SCSI.

Lỗi thay đổi phương tiện/lỗi yêu cầu thay đổi phương tiện
    <<TODO: điền vào đây>>

Lỗi địa chỉ
    Điều này được biểu thị bằng bit IDNF trong thanh ghi ERROR. Báo cáo lên cấp trên
    lớp.

Các lỗi khác
    Đây có thể là lệnh hoặc tham số không hợp lệ được biểu thị bằng bit ABRT ERROR
    hoặc một số tình trạng lỗi khác. Lưu ý rằng bit ABRT có thể biểu thị rất nhiều
    của những thứ bao gồm lỗi ICRC và Địa chỉ. Heuristic cần thiết.

Tùy thuộc vào lệnh, không phải tất cả các bit STATUS/ERROR đều có thể áp dụng được. Những cái này
các bit không áp dụng được đánh dấu bằng "na" trong mô tả đầu ra nhưng
cho đến ATA/ATAPI-7 không thể tìm thấy định nghĩa về "na". Tuy nhiên,
ATA/ATAPI-8 dự thảo sửa đổi 1f mô tả "Không áp dụng" như sau.

3.2.3.3a Không áp dụng
        Từ khóa the chỉ ra một trường không có giá trị được xác định trong trường này
        tiêu chuẩn và không nên được kiểm tra bởi máy chủ hoặc thiết bị. không áp dụng
        các trường phải được xóa về 0.

Vì vậy, có vẻ hợp lý khi giả định rằng các bit "na" bị xóa về 0 bằng cách
các thiết bị và do đó không cần mặt nạ rõ ràng.

Thiết bị ATAPI CHECK CONDITION
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Thiết bị ATAPI Lỗi CHECK CONDITION được biểu thị bằng cách đặt bit CHK (bit ERR)
trong thanh ghi STATUS sau khi byte cuối cùng của CDB được chuyển cho một
Lệnh PACKET. Đối với loại lỗi này, cần thu thập dữ liệu cảm nhận
để thu thập thông tin liên quan đến lỗi. Lệnh gói REQUEST SENSE
nên được sử dụng để thu được dữ liệu giác quan.

Sau khi thu được dữ liệu giác quan, loại lỗi này có thể được xử lý
tương tự như các lỗi SCSI khác. Lưu ý rằng dữ liệu giác quan có thể chỉ ra ATA
lỗi bus (ví dụ: Sense Key 04h HARDWARE ERROR && ASC/ASCQ 47h/00h SCSI
PARITY ERROR). Trong những trường hợp như vậy, lỗi phải được coi là ATA
lỗi bus và xử lý theo ZZ0000ZZ.

Lỗi thiết bị ATA (NCQ)
~~~~~~~~~~~~~~~~~~~~~~

Lỗi lệnh NCQ được biểu thị bằng cách xóa BSY và đặt bit ERR trong NCQ
giai đoạn lệnh (một hoặc nhiều lệnh NCQ còn tồn tại). Mặc dù STATUS
và các thanh ghi ERROR sẽ chứa các giá trị hợp lệ mô tả lỗi, READ
Cần có LOG EXT để xóa tình trạng lỗi, xác định lỗi nào
lệnh đã thất bại và thu được thêm thông tin.

READ LOG EXT Nhật ký Trang 10h báo cáo thẻ nào bị lỗi và tệp tác vụ
đăng ký giá trị mô tả lỗi. Với thông tin này thất bại
lệnh có thể được xử lý như một lỗi lệnh ATA bình thường như trong
ZZ0000ZZ
và tất cả các lệnh khác trong chuyến bay phải được thử lại. Lưu ý rằng lần thử lại này
không được tính - có khả năng các lệnh được thử lại theo cách này sẽ
đã hoàn thành bình thường nếu không có lệnh bị lỗi.

Lưu ý rằng lỗi bus ATA có thể được báo cáo là lỗi ATA của thiết bị NCQ. Cái này
nên được xử lý như mô tả trong ZZ0000ZZ.

Nếu READ LOG EXT Nhật ký Trang 10h không thành công hoặc báo cáo NQ, chúng tôi sẽ xử lý triệt để
vặn vẹo. Tình trạng này cần được điều trị theo
ZZ0000ZZ.

Lỗi xe buýt ATA
~~~~~~~~~~~~~

Lỗi bus ATA có nghĩa là dữ liệu bị hỏng trong quá trình truyền
trên xe buýt ATA (SATA hoặc PATA). Loại lỗi này có thể được biểu thị bằng

- Lỗi ICRC hoặc ABRT như mô tả ở mục
   ZZ0000ZZ.

- Hoàn thành lỗi dành riêng cho bộ điều khiển với thông tin lỗi
   báo lỗi đường truyền.

- Trên một số bộ điều khiển, lệnh hết thời gian chờ. Trong trường hợp này, có thể có một
   cơ chế xác định thời gian chờ là do lỗi truyền.

- Lỗi không xác định/ngẫu nhiên, thời gian chờ và đủ loại điều kỳ lạ.

Như đã mô tả ở trên, lỗi truyền tải có thể gây ra nhiều loại lỗi
các triệu chứng khác nhau, từ lỗi ICRC của thiết bị đến khóa thiết bị ngẫu nhiên và,
trong nhiều trường hợp, không có cách nào để biết liệu tình trạng lỗi có phải do
lỗi đường truyền hay không; vì vậy cần phải sử dụng một số loại
của heuristic khi xử lý lỗi và thời gian chờ. Ví dụ,
gặp phải lỗi ABRT lặp đi lặp lại đối với lệnh được hỗ trợ đã biết là
có khả năng chỉ ra lỗi bus ATA.

Sau khi xác định rằng có thể đã xảy ra lỗi bus ATA,
giảm tốc độ truyền bus ATA là một trong những hành động có thể
làm dịu bớt vấn đề. Xem ZZ0000ZZ để biết
thêm thông tin.

Lỗi xe buýt PCI
~~~~~~~~~~~~~

Dữ liệu bị hỏng hoặc các lỗi khác trong quá trình truyền qua PCI (hoặc các lỗi khác
xe buýt hệ thống). Đối với BMDMA tiêu chuẩn, điều này được biểu thị bằng bit Lỗi trong
BMDMA Thanh ghi trạng thái. Loại lỗi này phải được ghi lại vì nó
cho biết có điều gì đó rất không ổn với hệ thống. Đặt lại máy chủ
bộ điều khiển được khuyến khích.

Hoàn thành muộn
~~~~~~~~~~~~~~~

Điều này xảy ra khi hết thời gian chờ và trình xử lý thời gian chờ phát hiện ra rằng
lệnh hết thời gian đã hoàn thành thành công hoặc có lỗi. Đây là
thường gây ra bởi mất ngắt. Loại lỗi này phải được ghi lại.
Nên đặt lại bộ điều khiển máy chủ.

Lỗi không xác định (hết thời gian)
~~~~~~~~~~~~~~~~~~~~~~~

Đây là khi hết thời gian chờ và lệnh vẫn đang được xử lý hoặc
máy chủ và thiết bị ở trạng thái không xác định. Khi điều này xảy ra, HSM có thể ở
bất kỳ trạng thái hợp lệ hoặc không hợp lệ. Để đưa thiết bị về trạng thái đã biết và thực hiện
nó quên lệnh hết thời gian chờ, việc đặt lại là cần thiết. Thời gian
lệnh out có thể được thử lại.

Thời gian chờ cũng có thể do lỗi truyền dẫn. tham khảo
ZZ0000ZZ để biết thêm chi tiết.

Ngoại lệ cắm nóng và quản lý nguồn
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

<<TODO: điền vào đây>>

Hành động phục hồi EH
-------------------

Phần này thảo luận về một số hành động phục hồi quan trọng.

Xóa tình trạng lỗi
~~~~~~~~~~~~~~~~~~~~~~~~

Nhiều bộ điều khiển yêu cầu các thanh ghi lỗi của nó phải được xóa do lỗi
người xử lý. Bộ điều khiển khác nhau có thể có các yêu cầu khác nhau.

Đối với SATA, chúng tôi khuyên bạn nên xóa ít nhất thanh ghi SError
trong quá trình xử lý lỗi.

Cài lại
~~~~~

Trong EH, việc đặt lại là cần thiết trong các trường hợp sau.

- HSM ở trạng thái không xác định hoặc không hợp lệ

- HBA ở trạng thái không xác định hoặc không hợp lệ

- EH cần làm cho HBA/thiết bị quên đi các lệnh trên chuyến bay

- HBA/thiết bị hoạt động kỳ lạ

Đặt lại trong EH có thể là một ý tưởng hay bất kể tình trạng lỗi
để cải thiện độ bền của EH. Đặt lại cả hai hay một trong HBA và
thiết bị tùy thuộc vào tình huống nhưng nên sử dụng sơ đồ sau.

- Khi biết HBA đang ở trạng thái sẵn sàng nhưng thiết bị ATA/ATAPI đang ở trạng thái sẵn sàng
   trạng thái không xác định, chỉ đặt lại thiết bị.

- Nếu HBA ở trạng thái không xác định, hãy đặt lại cả HBA và thiết bị.

Việc đặt lại HBA là việc thực hiện cụ thể. Đối với bộ điều khiển tuân thủ
taskfile/BMDMA PCI IDE, việc dừng giao dịch DMA đang hoạt động có thể là
đủ nếu trạng thái BMDMA là bối cảnh HBA duy nhất. Nhưng thậm chí hầu hết
taskfile/BMDMA PCI IDE bộ điều khiển tuân thủ có thể được triển khai
yêu cầu cụ thể và cơ chế tự thiết lập lại. Đây phải là
được giải quyết bởi các trình điều khiển cụ thể.

Tiêu chuẩn OTOH, ATA/ATAPI mô tả chi tiết các cách reset ATA/ATAPI
thiết bị.

Thiết lập lại phần cứng PATA
    Đây là thiết lập lại thiết bị được khởi tạo bằng phần cứng được báo hiệu bằng PATA đã được xác nhận
    Tín hiệu RESET-. Không có cách tiêu chuẩn nào để bắt đầu thiết lập lại phần cứng
    từ phần mềm mặc dù một số phần cứng cung cấp các thanh ghi cho phép
    trình điều khiển để điều chỉnh trực tiếp tín hiệu RESET-.

Thiết lập lại phần mềm
    Điều này đạt được bằng cách bật bit CONTROL SRST trong ít nhất 5us.
    Cả PATA và SATA đều hỗ trợ nó, nhưng trong trường hợp SATA, điều này có thể yêu cầu
    hỗ trợ dành riêng cho bộ điều khiển làm Đăng ký FIS thứ hai để xóa SRST
    nên được truyền trong khi bit BSY vẫn được đặt. Lưu ý rằng trên PATA,
    thao tác này sẽ đặt lại cả thiết bị chính và thiết bị phụ trên một kênh.

Lệnh EXECUTE DEVICE DIAGNOSTIC
    Mặc dù tiêu chuẩn ATA/ATAPI không mô tả chính xác nhưng EDD ngụ ý
    một số mức độ đặt lại, có thể là mức độ tương tự với việc đặt lại phần mềm.
    Giao thức EDD phía máy chủ có thể được xử lý bằng cách xử lý lệnh thông thường
    và hầu hết các bộ điều khiển SATA đều có thể xử lý EDD giống như
    các lệnh khác. Giống như khi thiết lập lại phần mềm, EDD ảnh hưởng đến cả hai thiết bị trên một
    Xe buýt PATA.

Mặc dù EDD có thiết lập lại thiết bị nhưng điều này không phù hợp với việc xử lý lỗi vì
    EDD không thể được phát hành trong khi BSY được thiết lập và không rõ nó sẽ như thế nào
    hành động khi thiết bị ở trạng thái không xác định/lạ.

Lệnh ATAPI DEVICE RESET
    Điều này rất giống với việc thiết lập lại phần mềm ngoại trừ việc thiết lập lại có thể
    giới hạn ở thiết bị đã chọn mà không ảnh hưởng đến thiết bị kia
    chia sẻ cáp.

Thiết lập lại phy SATA
    Đây là cách ưu tiên để đặt lại thiết bị SATA. Trên thực tế,
    nó giống hệt với thiết lập lại phần cứng PATA. Lưu ý rằng điều này có thể được thực hiện
    với thanh ghi điều khiển SCR tiêu chuẩn. Như vậy, nó thường dễ dàng hơn
    để thực hiện hơn là thiết lập lại phần mềm.

Một điều nữa cần cân nhắc khi đặt lại thiết bị là việc đặt lại
xóa các tham số cấu hình nhất định và chúng cần được đặt thành
giá trị trước đó hoặc mới được điều chỉnh sau khi đặt lại.

Các thông số bị ảnh hưởng là.

- CHS được thiết lập với INITIALIZE DEVICE PARAMETERS (ít sử dụng)

- Các thông số cài đặt với SET FEATURES bao gồm cài đặt chế độ truyền

- Bộ đếm khối với SET MULTIPLE MODE

- Các thông số khác (SET MAX, MEDIA LOCK...)

Tiêu chuẩn ATA/ATAPI quy định rằng một số thông số phải được duy trì
qua việc thiết lập lại phần cứng hoặc phần mềm, nhưng không chỉ định nghiêm ngặt tất cả
họ. Luôn phải cấu hình lại các thông số cần thiết sau khi thiết lập lại cho
sự vững chãi. Lưu ý rằng điều này cũng áp dụng khi tiếp tục từ giấc ngủ sâu
(tắt nguồn).

Ngoài ra, tiêu chuẩn ATA/ATAPI yêu cầu IDENTIFY DEVICE / IDENTIFY PACKET
DEVICE được cấp sau khi bất kỳ tham số cấu hình nào được cập nhật hoặc
thiết lập lại phần cứng và kết quả được sử dụng cho hoạt động tiếp theo. Trình điều khiển hệ điều hành là
cần phải thực hiện cơ chế xác nhận lại để hỗ trợ việc này.

Cấu hình lại phương tiện vận chuyển
~~~~~~~~~~~~~~~~~~~~~

Đối với cả PATA và SATA, rất nhiều góc được cắt giảm cho các đầu nối giá rẻ,
cáp hoặc bộ điều khiển và khá phổ biến khi thấy đường truyền cao
tỷ lệ lỗi. Điều này có thể được giảm thiểu bằng cách giảm tốc độ truyền.

Sau đây là một sơ đồ khả thi mà Jeff Garzik đề xuất.

Nếu xảy ra nhiều hơn $N (3?) lỗi truyền trong 15 phút,

- nếu là SATA, hãy giảm tốc độ SATA PHY. nếu tốc độ không thể giảm,

- giảm tốc độ xfer UDMA. nếu ở UDMA0 thì chuyển sang PIO4,

- giảm tốc độ xfer PIO. nếu ở PIO3, hãy phàn nàn nhưng hãy tiếp tục

ata_piix Nội bộ
===================

.. kernel-doc:: drivers/ata/ata_piix.c
   :internal:

nội bộ sata_sil
===================

.. kernel-doc:: drivers/ata/sata_sil.c
   :internal:

Cảm ơn
======

Phần lớn kiến thức về ATA có được nhờ những cuộc trò chuyện dài với
Andre Hedrick (www.linux-ide.org), và nhiều giờ suy nghĩ về ATA và
Thông số kỹ thuật SCSI.

Cảm ơn Alan Cox đã chỉ ra những điểm tương đồng giữa SATA và SCSI,
và nói chung là có động lực để hack libata.

phương pháp phát hiện thiết bị của libata, ata_pio_devchk và nói chung là tất cả
cuộc thăm dò ban đầu dựa trên nghiên cứu sâu rộng về Hale Landis
mã thăm dò/đặt lại trong trình điều khiển ATADRVR của anh ấy (www.ata-atapi.com).
