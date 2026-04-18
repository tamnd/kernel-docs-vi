.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/PCI/pci-error-recovery.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================
Phục hồi lỗi PCI
==================


:Tác giả: - Linas Vepstas <linasvepstas@gmail.com>
          - Richard Lary <rlary@us.ibm.com>
          - Mike Mason <mmlnx@us.ibm.com>


Nhiều bộ điều khiển bus PCI có thể phát hiện nhiều loại phần cứng
Lỗi PCI trên bus, chẳng hạn như lỗi chẵn lẻ trên dữ liệu và địa chỉ
xe buýt, cũng như lỗi SERR và PERR.  Một số nâng cao hơn
chipset có thể xử lý những lỗi này; chúng bao gồm các chipset PCIe,
và các cầu nối máy chủ PCI được tìm thấy trên IBM Power4, Power5 và Power6 dựa trên
hộp pSeries. Một hành động điển hình được thực hiện là ngắt kết nối thiết bị bị ảnh hưởng,
tạm dừng tất cả I/O cho nó.  Mục đích của việc ngắt kết nối là để tránh hệ thống
tham nhũng; ví dụ: để ngăn chặn tình trạng hỏng bộ nhớ hệ thống do DMA
đến các địa chỉ "hoang dã". Thông thường, cơ chế kết nối lại cũng được
được cung cấp để (các) thiết bị PCI bị ảnh hưởng được đặt lại và đặt trở lại
vào tình trạng làm việc. Giai đoạn thiết lập lại cần có sự phối hợp
giữa trình điều khiển thiết bị bị ảnh hưởng và chip điều khiển PCI.
Tài liệu này mô tả API chung để thông báo cho trình điều khiển thiết bị
ngắt kết nối bus và sau đó thực hiện khôi phục lỗi.
API này hiện được triển khai trong hạt nhân 2.6.16 trở lên.

Việc báo cáo và phục hồi được thực hiện theo một số bước. Đầu tiên, khi
lỗi phần cứng PCI đã dẫn đến ngắt kết nối bus, sự kiện đó
được báo cáo sớm nhất có thể cho tất cả trình điều khiển thiết bị bị ảnh hưởng,
bao gồm nhiều phiên bản của trình điều khiển thiết bị đa chức năng
thẻ. Điều này cho phép trình điều khiển thiết bị tránh được tình trạng bế tắc trong các vòng quay,
chờ đợi một số thanh ghi i/o-space thay đổi, nhưng điều đó sẽ không bao giờ xảy ra.
Nó cũng mang lại cho người lái xe cơ hội trì hoãn I/O đến như
cần thiết.

Tiếp theo, quá trình phục hồi được thực hiện theo nhiều giai đoạn. Hầu hết sự phức tạp
bị ép buộc bởi nhu cầu xử lý các thiết bị đa chức năng, nghĩa là
các thiết bị có nhiều trình điều khiển thiết bị được liên kết với chúng.
Trong giai đoạn đầu tiên, mỗi người lái xe được phép chỉ ra loại
về việc thiết lập lại nó mong muốn, các lựa chọn đơn giản là kích hoạt lại I/O
hoặc yêu cầu đặt lại vị trí.

Nếu bất kỳ trình điều khiển nào yêu cầu đặt lại khe cắm thì đó là điều sẽ được thực hiện.

Sau khi thiết lập lại và/hoặc kích hoạt lại I/O, tất cả các trình điều khiển đều được
được thông báo lại để sau đó họ có thể thực hiện bất kỳ thiết lập/cấu hình thiết bị nào
điều đó có thể được yêu cầu.  Sau khi tất cả những điều này đã hoàn thành, một bản cuối cùng
sự kiện "tiếp tục hoạt động bình thường" được gửi đi.

Lý do lớn nhất để chọn triển khai dựa trên kernel thay vì
hơn việc triển khai không gian người dùng là nhu cầu xử lý bus
ngắt kết nối các thiết bị PCI được gắn vào phương tiện lưu trữ và đặc biệt là
ngắt kết nối khỏi các thiết bị đang giữ hệ thống tập tin gốc.  Nếu gốc
hệ thống tập tin bị ngắt kết nối, cơ chế không gian người dùng sẽ phải hoạt động
thông qua một số lượng lớn các chuyển động để phục hồi hoàn toàn. Hầu như tất cả
của các hệ thống tệp Linux hiện tại không cho phép ngắt kết nối
từ/kết nối lại đến thiết bị khối cơ bản của họ. Ngược lại,
lỗi bus rất dễ quản lý trong trình điều khiển thiết bị. Quả thực, hầu hết
trình điều khiển thiết bị đã xử lý các quy trình khôi phục rất giống nhau;
ví dụ: lớp chung SCSI đã cung cấp đáng kể
cơ chế xử lý lỗi bus SCSI và reset bus SCSI.


Thiết kế chi tiết
===============

Chi tiết thiết kế và triển khai bên dưới, dựa trên chuỗi
thảo luận qua email công khai với Ben Herrenschmidt, khoảng ngày 5 tháng 4 năm 2005.

Hỗ trợ khôi phục lỗi API được hiển thị cho trình điều khiển dưới dạng
cấu trúc của các con trỏ hàm được trỏ bởi một trường mới trong struct
pci_driver. Trình điều khiển không cung cấp cấu trúc là "không nhận biết",
và các bước khôi phục thực tế được thực hiện phụ thuộc vào nền tảng.  các
Việc triển khai Arch/powerpc sẽ mô phỏng thao tác xóa/thêm phích cắm nóng PCI.

Cấu trúc này có dạng::

cấu trúc pci_error_handlers
	{
		int (*error_detected)(struct pci_dev *dev, pci_channel_state_t);
		int (*mmio_enabled)(struct pci_dev *dev);
		int (*slot_reset)(struct pci_dev *dev);
		khoảng trống (*resume)(struct pci_dev *dev);
		khoảng trống (*cor_error_detected)(struct pci_dev *dev);
	};

Các trạng thái kênh có thể có là::

typedef enum {
		pci_channel_io_normal, /* Kênh I/O ở trạng thái bình thường */
		pci_channel_io_frozen, /* I/O tới kênh bị chặn */
		pci_channel_io_perm_failure, /* Thẻ PCI đã chết */
	} pci_channel_state_t;

Các giá trị trả về có thể có là::

enum pci_ers_result {
		PCI_ERS_RESULT_NONE, /* không có kết quả/không có/không được hỗ trợ trong trình điều khiển thiết bị */
		PCI_ERS_RESULT_CAN_RECOVER, /* Trình điều khiển thiết bị có thể khôi phục mà không cần đặt lại khe */
		PCI_ERS_RESULT_NEED_RESET, /* Trình điều khiển thiết bị muốn đặt lại khe cắm. */
		PCI_ERS_RESULT_DISCONNECT, /* Thiết bị đã hỏng hoàn toàn, không thể khôi phục được */
		PCI_ERS_RESULT_RECOVERED, /* Trình điều khiển thiết bị đã được khôi phục hoàn toàn và hoạt động */
	};

Trình điều khiển không phải triển khai tất cả các lệnh gọi lại này; tuy nhiên,
nếu nó thực hiện bất kỳ điều gì thì nó phải triển khai error_ detected(). Nếu một cuộc gọi lại
không được triển khai, tính năng tương ứng được coi là không được hỗ trợ.
Ví dụ: nếu mmio_enabled() và sơ yếu lý lịch() không có ở đó thì nó
được giả định rằng trình điều khiển không cần những cuộc gọi lại này
để phục hồi.  Thông thường người lái xe sẽ muốn biết về
một slot_reset().

Các bước thực tế mà nền tảng thực hiện để khôi phục sau lỗi PCI
sự kiện sẽ phụ thuộc vào nền tảng, nhưng sẽ tuân theo quy tắc chung
trình tự được mô tả dưới đây.

STEP 0: Sự kiện lỗi
-------------------
Lỗi bus PCI được phần cứng PCI phát hiện.  Trên powerpc, khe cắm
bị cô lập, trong đó tất cả I/O đều bị chặn: tất cả các lần đọc đều trả về 0xffffffff,
tất cả các bài viết đều bị bỏ qua.

Tương tự, trên các nền tảng hỗ trợ Ngăn chặn cổng hạ lưu
(PCIe r7.0 giây 6.2.11), liên kết tới hệ thống phân cấp phụ với
thiết bị lỗi bị vô hiệu hóa. Bất kỳ thiết bị nào trong hệ thống phân cấp phụ
trở nên không thể tiếp cận được.

STEP 1: Thông báo
--------------------
Nền tảng gọi lệnh gọi lại error_ detected() trên mọi phiên bản của
mọi trình điều khiển bị ảnh hưởng bởi lỗi.

Tại thời điểm này, thiết bị có thể không truy cập được nữa, tùy thuộc vào
nền tảng (khe cắm sẽ được cách ly trên powerpc). Người lái xe có thể
đã "nhận thấy" lỗi do I/O bị lỗi, nhưng điều này
là "điểm đồng bộ" thích hợp, nghĩa là nó mang lại cho người lái xe
cơ hội để dọn dẹp, chờ đợi những thứ đang chờ xử lý (bộ hẹn giờ, bất cứ thứ gì, v.v.)
để hoàn thành; nó có thể chứa các ngữ nghĩa, lịch trình, v.v... mọi thứ trừ
chạm vào thiết bị. Trong hàm này và sau khi nó trả về, trình điều khiển
không nên thực hiện bất kỳ IO mới nào. Được gọi trong ngữ cảnh nhiệm vụ. Đây là một loại
điểm “im lặng”. Xem lưu ý về các ngắt ở cuối tài liệu này.

Tất cả các tài xế tham gia hệ thống này phải thực hiện lệnh gọi này.
Người lái xe phải trả về một trong các mã kết quả sau:

-PCI_ERS_RESULT_RECOVERED
      Trình điều khiển trả về thông tin này nếu nó cho rằng thiết bị vẫn có thể sử dụng được mặc dù
      lỗi và không cần can thiệp thêm.
  -PCI_ERS_RESULT_CAN_RECOVER
      Trình điều khiển trả về cái này nếu nó cho rằng nó có thể phục hồi được
      CTNH bằng cách chỉ cần gõ IO hoặc nếu nó muốn được cấp
      một cơ hội để trích xuất một số thông tin chẩn đoán (xem
      mmio_enable, bên dưới).
  -PCI_ERS_RESULT_NEED_RESET
      Trình điều khiển trả về cái này nếu nó không thể phục hồi mà không có
      thiết lập lại khe cắm.
  -PCI_ERS_RESULT_DISCONNECT
      Trình điều khiển trả về cái này nếu nó không muốn khôi phục chút nào.

Bước tiếp theo được thực hiện sẽ phụ thuộc vào mã kết quả được trả về bởi
trình điều khiển.

Nếu tất cả trình điều khiển trên phân đoạn/khe trả về PCI_ERS_RESULT_CAN_RECOVER,
thì nền tảng sẽ kích hoạt lại IO trên khe cắm (hoặc không làm gì trong
cụ thể, nếu nền tảng không cách ly các vị trí) và việc khôi phục
tiến tới STEP 2 (Bật MMIO).

Nếu bất kỳ trình điều khiển nào yêu cầu đặt lại khe cắm (bằng cách trả về PCI_ERS_RESULT_NEED_RESET),
sau đó quá trình khôi phục tiến tới STEP 4 (Đặt lại khe cắm).

Nếu nền tảng không thể khôi phục vị trí, bước tiếp theo
là STEP 6 (Lỗi vĩnh viễn).

.. note::

   The current powerpc implementation assumes that a device driver will
   *not* schedule or semaphore in this routine; the current powerpc
   implementation uses one kernel thread to notify all devices;
   thus, if one device sleeps/schedules, all devices are affected.
   Doing better requires complex multi-threaded logic in the error
   recovery implementation (e.g. waiting for all notification threads
   to "join" before proceeding with recovery.)  This seems excessively
   complex and not worth implementing.

   The current powerpc implementation doesn't much care if the device
   attempts I/O at this point, or not.  I/Os will fail, returning
   a value of 0xff on read, and writes will be dropped. If more than
   EEH_MAX_FAILS I/Os are attempted to a frozen adapter, EEH
   assumes that the device driver has gone into an infinite loop
   and prints an error to syslog.  A reboot is then required to
   get the device working again.

STEP 2: Đã bật MMIO
--------------------
Nền tảng kích hoạt lại MMIO cho thiết bị (nhưng thường không phải
DMA), sau đó gọi lệnh gọi lại mmio_enabled() trên tất cả các thiết bị bị ảnh hưởng
trình điều khiển thiết bị.

Đây là lời kêu gọi "khôi phục sớm". IO được cho phép trở lại, nhưng DMA thì
không, với một số hạn chế. Đây là NOT một cuộc gọi lại để người lái xe
bắt đầu lại hoạt động, chỉ để nhìn trộm/chọc vào thiết bị, trích xuất chẩn đoán
thông tin, nếu có, và cuối cùng thực hiện những việc như kích hoạt thiết bị cục bộ
đặt lại hoặc một số thao tác tương tự, nhưng không khởi động lại hoạt động. Cuộc gọi lại này được thực hiện nếu
tất cả người lái xe trên một đoạn đường đều đồng ý rằng họ có thể cố gắng khôi phục và nếu không tự động
việc thiết lập lại liên kết đã được thực hiện bởi HW. Nếu nền tảng không thể kích hoạt lại IO
không thiết lập lại vị trí hoặc thiết lập lại liên kết, nó sẽ không gọi lại lệnh gọi lại này và
thay vào đó sẽ chuyển thẳng đến STEP 3 (Đặt lại liên kết) hoặc STEP 4 (Đặt lại khe cắm).

.. note::

   On platforms supporting Advanced Error Reporting (PCIe r7.0 sec 6.2),
   the faulting device may already be accessible in STEP 1 (Notification).
   Drivers should nevertheless defer accesses to STEP 2 (MMIO Enabled)
   to be compatible with EEH on powerpc and with s390 (where devices are
   inaccessible until STEP 2).

   On platforms supporting Downstream Port Containment, the link to the
   sub-hierarchy with the faulting device is re-enabled in STEP 3 (Link
   Reset). Hence devices in the sub-hierarchy are inaccessible until
   STEP 4 (Slot Reset).

   For errors such as Surprise Down (PCIe r7.0 sec 6.2.7), the device
   may not even be accessible in STEP 4 (Slot Reset). Drivers can detect
   accessibility by checking whether reads from the device return all 1's
   (PCI_POSSIBLE_ERROR()).

.. note::

   The following is proposed; no platform implements this yet:
   Proposal: All I/Os should be done _synchronously_ from within
   this callback, errors triggered by them will be returned via
   the normal pci_check_whatever() API, no new error_detected()
   callback will be issued due to an error happening here. However,
   such an error might cause IOs to be re-blocked for the whole
   segment, and thus invalidate the recovery that other devices
   on the same segment might have done, forcing the whole segment
   into one of the next states, that is, link reset or slot reset.

Trình điều khiển phải trả về một trong các mã kết quả sau:
  -PCI_ERS_RESULT_RECOVERED
      Trình điều khiển trả về thông tin này nếu cho rằng thiết bị đã được cài đặt đầy đủ
      hoạt động và nghĩ rằng nó đã sẵn sàng để bắt đầu
      trình điều khiển hoạt động bình thường trở lại. không có
      đảm bảo rằng người lái xe thực sự sẽ
      được phép tiếp tục, với tư cách là một người lái xe khác trên
      cùng một phân khúc có thể đã thất bại và do đó gây ra
      đặt lại vị trí trên các nền tảng hỗ trợ nó.

-PCI_ERS_RESULT_NEED_RESET
      Trình điều khiển trả về cái này nếu nó cho rằng thiết bị không hoạt động
      có thể phục hồi ở trạng thái hiện tại và nó cần một khe cắm
      đặt lại để tiếp tục.

-PCI_ERS_RESULT_DISCONNECT
      Tương tự như trên. Thất bại hoàn toàn, không thể phục hồi ngay cả sau đó
      thiết lập lại trình điều khiển đã chết. (sẽ được định nghĩa chính xác hơn)

Bước tiếp theo được thực hiện phụ thuộc vào kết quả do trình điều khiển trả về.
Nếu tất cả trình điều khiển trả về PCI_ERS_RESULT_RECOVERED thì nền tảng
tiến tới STEP 3 (Đặt lại liên kết) hoặc STEP 5 (Tiếp tục hoạt động).

Nếu bất kỳ trình điều khiển nào trả về PCI_ERS_RESULT_NEED_RESET thì nền tảng
tiến tới STEP 4 (Đặt lại khe cắm)

STEP 3: Đặt lại liên kết
------------------
Nền tảng đặt lại liên kết.  Đây là một bước cụ thể của PCIe
và được thực hiện bất cứ khi nào một lỗi nghiêm trọng được phát hiện có thể
"giải quyết" bằng cách đặt lại liên kết.

STEP 4: Đặt lại khe cắm
------------------

Để đáp ứng giá trị trả về của PCI_ERS_RESULT_NEED_RESET,
nền tảng sẽ thực hiện thiết lập lại vị trí trên (các) thiết bị PCI được yêu cầu.
Các bước thực tế mà nền tảng thực hiện để thực hiện đặt lại vị trí
sẽ phụ thuộc vào nền tảng. Sau khi hoàn tất việc đặt lại vị trí,
nền tảng sẽ gọi lại cuộc gọi lại thiết bị slot_reset().

Nền tảng Powerpc triển khai hai cấp độ đặt lại vị trí:
thiết lập lại mềm (mặc định) và thiết lập lại cơ bản (tùy chọn).

Thiết lập lại mềm Powerpc bao gồm việc xác nhận dòng #ZZ0000ZZ của bộ chuyển đổi và sau đó
khôi phục các thanh PCI và tiêu đề cấu hình PCI về trạng thái
điều đó tương đương với những gì sẽ xảy ra sau một hệ thống mới
bật nguồn, sau đó bật nguồn BIOS/khởi tạo chương trình cơ sở hệ thống.
Thiết lập lại mềm còn được gọi là thiết lập lại nóng.

Thiết lập lại cơ bản Powerpc chỉ được hỗ trợ bởi thẻ PCIe
và kết quả là trạng thái máy, logic phần cứng, trạng thái cổng và
các thanh ghi cấu hình để khởi tạo các điều kiện mặc định của chúng.

Đối với hầu hết các thiết bị PCI, thiết lập lại mềm sẽ đủ để khôi phục.
Thiết lập lại cơ bản tùy chọn được cung cấp để hỗ trợ một số lượng hạn chế
số thiết bị PCIe mà việc thiết lập lại mềm là không đủ
để phục hồi.

Nếu nền tảng hỗ trợ hotplug PCI thì việc thiết lập lại có thể là
được thực hiện bằng cách bật/tắt nguồn điện của khe cắm.

Điều quan trọng đối với nền tảng là khôi phục không gian cấu hình PCI
sang trạng thái "bật nguồn mới", thay vì "trạng thái cuối cùng". Sau
đặt lại khe cắm, trình điều khiển thiết bị hầu như sẽ luôn sử dụng tiêu chuẩn của nó
quy trình khởi tạo thiết bị và thiết lập không gian cấu hình bất thường
có thể dẫn đến thiết bị bị treo, lỗi kernel hoặc hỏng dữ liệu im lặng.

Cuộc gọi này mang lại cho trình điều khiển cơ hội khởi tạo lại phần cứng
(tải lại firmware, v.v.).  Lúc này, người lái xe có thể giả định
rằng thẻ ở trạng thái mới và có đầy đủ chức năng. Khe cắm
không bị đóng băng và trình điều khiển có toàn quyền truy cập vào không gian cấu hình PCI,
bộ nhớ ánh xạ không gian I/O và DMA. Ngắt (Di sản, MSI hoặc MSI-X)
cũng sẽ có sẵn.

Trình điều khiển không được khởi động lại các hoạt động xử lý I/O bình thường
vào thời điểm này.  Nếu tất cả trình điều khiển thiết bị báo cáo thành công về điều này
gọi lại, nền tảng sẽ gọi sơ yếu lý lịch() để hoàn thành chuỗi,
và để trình điều khiển khởi động lại quá trình xử lý I/O bình thường.

Trình điều khiển vẫn có thể trả về lỗi nghiêm trọng cho chức năng này nếu
nó không thể làm cho thiết bị hoạt động sau khi thiết lập lại.  Nếu nền tảng
trước đây đã thử thiết lập lại mềm, bây giờ có thể thử thiết lập lại cứng (nguồn
Cycle) và sau đó gọi lại slot_reset().  Nếu thiết bị vẫn không thể
được phục hồi thì không thể làm gì được nữa;  nền tảng
thường sẽ báo cáo "lỗi vĩnh viễn" trong trường hợp như vậy.  các
thiết bị sẽ được coi là "chết" trong trường hợp này.

Trình điều khiển thường cần gọi pci_restore_state() sau khi đặt lại thành
khởi tạo lại các thanh ghi không gian cấu hình của thiết bị và do đó
đưa nó từ trạng thái D0\ ZZ0000ZZ sang trạng thái D0\ ZZ0001ZZ
(PCIe r7.0 giây 5.3.1.1).  Lõi PCI gọi pci_save_state()
về liệt kê sau khi khởi tạo không gian cấu hình để đảm bảo rằng
trạng thái đã lưu có sẵn để phục hồi lỗi tiếp theo.
Trình điều khiển sửa đổi không gian cấu hình trên đầu dò có thể cần gọi
pci_save_state() sau đó để ghi lại những thay đổi đó cho lần sau
phục hồi lỗi.  Khi chuyển sang hệ thống tạm dừng, pci_save_state()
được gọi cho mọi thiết bị PCI và trạng thái đó sẽ được khôi phục
không chỉ trong sơ yếu lý lịch mà còn trong bất kỳ quá trình khắc phục lỗi nào sau đó.
Trong trường hợp hiếm hoi là trạng thái đã lưu được ghi lại khi tạm dừng
không phù hợp để khắc phục lỗi, tài xế nên gọi
pci_save_state() trên sơ yếu lý lịch.

Trình điều khiển cho thẻ đa chức năng sẽ cần phải phối hợp giữa
về việc phiên bản trình điều khiển nào sẽ thực hiện bất kỳ "một lần" nào
hoặc khởi tạo thiết bị toàn cầu. Ví dụ: Symbios sym53cxx2
trình điều khiển chỉ thực hiện khởi tạo thiết bị từ chức năng PCI 0::

+ nếu (PCI_FUNC(pdev->devfn) == 0)
	+ sym_reset_scsi_bus(np, 0);

Mã kết quả:
	-PCI_ERS_RESULT_DISCONNECT
	  Tương tự như trên.

Trình điều khiển cho thẻ PCIe yêu cầu thiết lập lại cơ bản phải
đặt bit Need_freset trong cấu trúc pci_dev trong hàm thăm dò của chúng.
Ví dụ: trình điều khiển QLogic qla2xxx đặt bit Need_freset cho một số
Các loại thẻ PCI::

+ /* Đặt loại đặt lại EEH thành cơ bản nếu hba yêu cầu */
	+ nếu (IS_QLA24XX(ha) |ZZ0000ZZ| IS_QLA81XX(ha))
	+ pdev->needs_freset = 1;
	+

Nền tảng tiến tới STEP 5 (Tiếp tục hoạt động) hoặc STEP 6 (Vĩnh viễn
Thất bại).

.. note::

   The current powerpc implementation does not try a power-cycle
   reset if the driver returned PCI_ERS_RESULT_DISCONNECT.
   However, it probably should.


STEP 5: Tiếp tục hoạt động
-------------------------
Nền tảng sẽ gọi lại hàm gọi lại Resume() trên tất cả các thiết bị bị ảnh hưởng
tài xế nếu tất cả tài xế trên đoạn đường đã quay trở lại
PCI_ERS_RESULT_RECOVERED từ một trong 3 lần gọi lại trước đó.
Mục tiêu của cuộc gọi lại này là yêu cầu người lái xe khởi động lại hoạt động,
rằng mọi thứ đã hoạt động trở lại. Cuộc gọi lại này không trả lại
một mã kết quả.

Tại thời điểm này, nếu xảy ra lỗi mới, nền tảng sẽ khởi động lại
một trình tự phục hồi lỗi mới.

STEP 6: Lỗi vĩnh viễn
-------------------------
Đã xảy ra "lỗi vĩnh viễn" và nền tảng không thể phục hồi
thiết bị.  Nền tảng sẽ gọi error_ detected() bằng một
giá trị pci_channel_state_t của pci_channel_io_perm_failure.

Tại thời điểm này, trình điều khiển thiết bị nên giả định điều tồi tệ nhất. Nó nên
hủy tất cả I/O đang chờ xử lý, từ chối tất cả I/O mới, trả lại -EIO cho
các lớp cao hơn. Trình điều khiển thiết bị sau đó sẽ dọn sạch tất cả
bộ nhớ và loại bỏ chính nó khỏi các hoạt động của kernel, giống như cách nó làm
trong quá trình tắt hệ thống.

Nền tảng thường sẽ thông báo cho nhà điều hành hệ thống về
thất bại vĩnh viễn theo một cách nào đó.  Nếu thiết bị có khả năng cắm nóng,
người vận hành có thể sẽ muốn tháo và thay thế thiết bị.
Tuy nhiên, hãy lưu ý rằng không phải mọi thất bại đều thực sự "vĩnh viễn". Một số là
do quá nóng, một số do card được đặt không đúng vị trí. Nhiều
Các sự kiện lỗi PCI là do lỗi phần mềm, ví dụ: DMA tới
địa chỉ hoang dã hoặc giao dịch phân chia không có thật do lập trình
lỗi. Xem phần thảo luận trong Documentation/arch/powerpc/eeh-pci-error-recovery.rst
để biết thêm chi tiết về kinh nghiệm thực tế về nguyên nhân của
lỗi phần mềm.


Phần kết luận; Nhận xét chung
---------------------------
Cách gọi lại là chính sách nền tảng. Một nền tảng với
không có khả năng đặt lại khe cắm có thể chỉ muốn "bỏ qua" các trình điều khiển không thể
khôi phục (ngắt kết nối chúng) và cố gắng để các thẻ khác trên cùng phân khúc
phục hồi. Tuy nhiên, hãy nhớ rằng trong hầu hết các trường hợp thực tế, sẽ có
chỉ có một trình điều khiển cho mỗi phân khúc.

Bây giờ, một lưu ý về sự gián đoạn. Nếu bạn bị gián đoạn và
thiết bị đã chết hoặc đã bị cô lập, có vấn đề :)
Chính sách hiện tại là biến điều này thành chính sách nền tảng.
Nghĩa là, việc khôi phục API chỉ yêu cầu:

- Không có gì đảm bảo rằng việc phân phối gián đoạn có thể được tiến hành từ bất kỳ
   thiết bị trên đoạn bắt đầu từ khi phát hiện lỗi và cho đến khi
   Cuộc gọi lại slot_reset được gọi, tại thời điểm đó dự kiến sẽ có sự gián đoạn
   để có thể hoạt động đầy đủ.

- Không có gì đảm bảo rằng việc phân phối gián đoạn sẽ bị dừng, nghĩa là,
   trình điều khiển bị gián đoạn sau khi phát hiện lỗi hoặc phát hiện
   một lỗi trong trình xử lý ngắt khiến nó cản trở việc thực hiện đúng
   Việc xác nhận ngắt (và do đó loại bỏ nguồn) chỉ nên
   trả lại IRQ_NOTHANDLED. Tùy thuộc vào nền tảng để giải quyết vấn đề đó
   điều kiện, thường là bằng cách che nguồn IRQ trong suốt thời gian
   việc xử lý lỗi. Người ta kỳ vọng rằng nền tảng "biết" cái nào
   các ngắt được định tuyến đến các khe có khả năng quản lý lỗi và có thể xử lý
   với việc tạm thời vô hiệu hóa số IRQ đó trong quá trình xử lý lỗi (điều này
   không quá phức tạp). Điều đó có nghĩa là độ trễ IRQ đối với các thiết bị khác
   chia sẻ ngắt, nhưng đơn giản là không có cách nào khác. Cao cấp
   nền tảng không được phép chia sẻ ngắt giữa nhiều thiết bị
   dù sao đi nữa :)

.. note::

   Implementation details for the powerpc platform are discussed in
   the file Documentation/arch/powerpc/eeh-pci-error-recovery.rst

   As of this writing, there is a growing list of device drivers with
   patches implementing error recovery. Not all of these patches are in
   mainline yet. These may be used as "examples":

   - drivers/scsi/ipr
   - drivers/scsi/sym53c8xx_2
   - drivers/scsi/qla2xxx
   - drivers/scsi/lpfc
   - drivers/next/bnx2.c
   - drivers/next/e100.c
   - drivers/net/e1000
   - drivers/net/e1000e
   - drivers/net/ixgbe
   - drivers/net/cxgb3

   The cor_error_detected() callback is invoked in handle_error_source() when
   the error severity is "correctable". The callback is optional and allows
   additional logging to be done if desired. See example:

   - drivers/cxl/pci.c

Sự kết thúc
-------