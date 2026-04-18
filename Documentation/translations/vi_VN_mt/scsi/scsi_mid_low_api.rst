.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/scsi_mid_low_api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================================================
SCSI mid_level - giao diện trình điều khiển low_level
=============================================

Giới thiệu
============
Tài liệu này phác thảo giao diện giữa cấp trung Linux SCSI và
Trình điều khiển cấp thấp hơn SCSI. Trình điều khiển cấp thấp hơn (LLD) được gọi khác nhau
trình điều khiển bộ điều hợp bus máy chủ (HBA) và trình điều khiển máy chủ (HD). Một "chủ nhà" trong này
ngữ cảnh là cầu nối giữa bus IO của máy tính (ví dụ PCI hoặc ISA) và
cổng khởi tạo SCSI duy nhất trên phương tiện vận chuyển SCSI. Cổng "khởi tạo"
(Thuật ngữ SCSI, xem SAM-3 tại ZZ0000ZZ gửi lệnh SCSI
để "nhắm mục tiêu" các cổng SCSI (ví dụ: đĩa). Có thể có nhiều LLD đang hoạt động
hệ thống, nhưng chỉ có một cho mỗi loại phần cứng. Hầu hết LLD có thể kiểm soát một hoặc nhiều
SCSI HBA. Một số HBA chứa nhiều máy chủ.

Trong một số trường hợp, việc vận chuyển SCSI là một bus bên ngoài đã có
hệ thống con của riêng nó trong Linux (ví dụ USB và ieee1394). Trong những trường hợp như vậy
Hệ thống con SCSI LLD là cầu nối phần mềm với hệ thống con trình điều khiển khác.
Ví dụ như trình điều khiển lưu trữ usb (có trong driver/usb/storage
thư mục) và trình điều khiển ieee1394/sbp2 (có trong driver/ieee1394
thư mục).

Ví dụ: aic7xxx LLD điều khiển giao diện song song Adaptec SCSI
(SPI) dựa trên dòng chip 7xxx của công ty đó. aic7xxx
LLD có thể được tích hợp vào kernel hoặc được tải dưới dạng mô-đun. Chỉ có thể có
một aic7xxx LLD chạy trong hệ thống Linux nhưng nó có thể đang kiểm soát nhiều
HBA. Các HBA này có thể nằm trên bo mạch con PCI hoặc được tích hợp sẵn trong
bo mạch chủ (hoặc cả hai). Một số HBA dựa trên aic7xxx là bộ điều khiển kép
và do đó đại diện cho hai máy chủ. Giống như hầu hết các HBA hiện đại, mỗi máy chủ aic7xxx
có địa chỉ thiết bị PCI riêng. [Sự tương ứng một-một giữa
máy chủ SCSI và thiết bị PCI là phổ biến nhưng không bắt buộc (ví dụ: với
Bộ điều hợp ISA).]

Cấp trung SCSI cách ly LLD khỏi các lớp khác như SCSI
trình điều khiển lớp trên và lớp khối.

Phiên bản tài liệu này gần giống với phiên bản nhân Linux 2.6.8 .

Tài liệu
=============
Có một thư mục tài liệu SCSI trong cây nguồn kernel,
điển hình là Documentation/scsi . Hầu hết các tài liệu đều ở dạng reStructuredText
định dạng. Tệp này có tên là scsi_mid_low_api.rst và có thể
được tìm thấy trong thư mục đó. Có thể tìm thấy bản sao mới hơn của tài liệu này
tại ZZ0000ZZ Nhiều LLD được
được ghi lại trong Tài liệu/scsi (ví dụ: aic7xxx.rst). Cấp trung SCSI là
được mô tả ngắn gọn trong scsi.rst chứa URL cho tài liệu mô tả
hệ thống con SCSI trong dòng nhân Linux 2.4. Hai cấp trên
trình điều khiển có tài liệu trong thư mục đó: st.rst (trình điều khiển băng SCSI) và
scsi-generic.rst (dành cho trình điều khiển sg).

Một số tài liệu (hoặc URL) cho LLD có thể được tìm thấy trong mã nguồn C
hoặc trong cùng thư mục với mã nguồn C. Ví dụ để tìm URL
về trình điều khiển bộ lưu trữ dung lượng lớn USB, hãy xem
/usr/src/linux/drivers/usb/thư mục lưu trữ.

Cấu trúc trình điều khiển
================
Theo truyền thống, một LLD cho hệ thống con SCSI có ít nhất hai tệp trong
thư mục driver/scsi. Ví dụ: trình điều khiển có tên "xyz" có tiêu đề
tệp "xyz.h" và tệp nguồn "xyz.c". [Thật ra không có lý do chính đáng
tại sao tất cả những thứ này không thể có trong một tập tin; tệp tiêu đề là không cần thiết.] Một số
trình điều khiển đã được chuyển sang một số hệ điều hành có nhiều hơn
hai tập tin. Ví dụ: trình điều khiển aic7xxx có các tệp riêng biệt cho chung
và mã dành riêng cho hệ điều hành (ví dụ: FreeBSD và Linux). Những người lái xe như vậy có xu hướng có
thư mục riêng của họ trong thư mục driver/scsi.

Khi LLD mới được thêm vào Linux, các tệp sau (được tìm thấy trong
thư mục driver/scsi) sẽ cần được chú ý: Makefile và Kconfig .
Có lẽ tốt nhất là nghiên cứu cách tổ chức các LLD hiện tại.

Khi các hạt nhân phát triển dòng 2.5 phát triển thành dòng 2.6
loạt sản xuất, những thay đổi đang được đưa vào giao diện này. Một
ví dụ về điều này là mã khởi tạo trình điều khiển hiện có 2 mô hình
có sẵn. Phiên bản cũ hơn, tương tự như phiên bản Linux 2.4,
dựa trên các máy chủ được phát hiện tại thời điểm tải trình điều khiển HBA. Đây sẽ là
đề cập đến mô hình khởi tạo "thụ động". Mô hình mới hơn cho phép HBA
được cắm nóng (và rút phích cắm) trong suốt thời gian sử dụng của LLD và sẽ
được gọi là mô hình khởi tạo "hotplug". Mẫu mới hơn là
được ưa thích vì nó có thể xử lý cả thiết bị SCSI truyền thống
được kết nối vĩnh viễn cũng như các thiết bị "SCSI" hiện đại (ví dụ: USB hoặc
Máy ảnh kỹ thuật số được kết nối IEEE 1394) được cắm nóng. Cả hai
các mô hình khởi tạo được thảo luận trong các phần sau.

LLD giao tiếp với hệ thống con SCSI theo nhiều cách:

a) gọi trực tiếp các hàm do cấp trung cung cấp
  b) chuyển một tập hợp các con trỏ hàm tới hàm đăng ký
     được cung cấp bởi cấp trung. Mức trung bình sau đó sẽ gọi những
     hoạt động tại một thời điểm nào đó trong tương lai. LLD sẽ cung cấp
     việc thực hiện các chức năng này.
  c) truy cập trực tiếp vào các phiên bản của cấu trúc dữ liệu nổi tiếng được duy trì
     ở cấp độ trung bình

Các chức năng trong nhóm a) được liệt kê trong phần “Trung cấp
các chức năng được cung cấp" bên dưới.

Các chức năng trong nhóm b) được liệt kê trong phần có tiêu đề "Giao diện
chức năng" bên dưới. Con trỏ hàm của chúng được đặt trong các thành viên của
"struct scsi_host_template", một phiên bản của nó được chuyển tới
scsi_host_alloc().  Những chức năng giao diện mà LLD không có
muốn cung cấp nên đặt NULL trong thành viên tương ứng của
cấu trúc scsi_host_template.  Xác định một thể hiện của struct
scsi_host_template ở phạm vi tệp sẽ khiến NULL được đưa vào chức năng
thành viên con trỏ không được khởi tạo rõ ràng.

Những cách sử dụng trong nhóm c) cần được xử lý cẩn thận, đặc biệt là trong
môi trường "hotplug". LLD nên biết về thời gian tồn tại của các phiên bản
được chia sẻ với tầng giữa và các tầng khác.

Tất cả các chức năng được xác định trong LLD và tất cả dữ liệu được xác định ở phạm vi tệp
nên tĩnh. Ví dụ: hàm sdev_init() trong LLD
được gọi là "xxx" có thể được định nghĩa là
ZZ0000ZZ


Mô hình khởi tạo Hotplug
============================
Trong mô hình này, LLD điều khiển khi máy chủ SCSI được giới thiệu và xóa
từ hệ thống con SCSI. Máy chủ có thể được giới thiệu sớm nhất là tài xế
khởi tạo và gỡ bỏ muộn nhất là khi tắt trình điều khiển. Điển hình là tài xế
sẽ phản hồi lệnh gọi lại sysfs thăm dò() cho biết HBA đã được
được phát hiện. Sau khi xác nhận rằng thiết bị mới là thiết bị mà LLD mong muốn
để điều khiển, LLD sẽ khởi tạo HBA và sau đó đăng ký máy chủ mới
với mức trung bình của SCSI.

Trong quá trình khởi tạo LLD, trình điều khiển phải tự đăng ký với
bus IO thích hợp mà nó dự kiến sẽ tìm thấy (các) HBA (ví dụ: bus PCI).
Điều này có thể được thực hiện thông qua sysfs. Bất kỳ thông số trình điều khiển nào (đặc biệt là
những thứ có thể ghi được sau khi tải trình điều khiển) cũng có thể là
đã đăng ký với sysfs vào thời điểm này. Cấp trung SCSI lần đầu tiên trở thành
biết về LLD khi LLD đó đăng ký HBA đầu tiên của nó.

Một thời gian sau, LLD nhận biết được HBA và những gì tiếp theo
là một chuỗi cuộc gọi điển hình giữa LLD và cấp trung.
Ví dụ này cho thấy chức năng quét ở mức độ trung bình của HBA mới được giới thiệu trong 3
thiết bị scsi trong đó chỉ có 2 thiết bị đầu tiên phản hồi::

HBA PROBE: giả sử tìm thấy 2 thiết bị SCSI trong quá trình quét
    LLD cấp trung LLD
    ===———===========-------------------====------
    scsi_host_alloc() -->
    scsi_add_host() ---->
    scsi_scan_host() -------+
			    |
			sdev_init()
			sdev_configure() --> scsi_change_queue_deep()
			    |
			sdev_init()
			sdev_configure()
			    |
			sdev_init() ***
			sdev_destroy() ***


*** Đối với các thiết bị scsi cấp trung cố quét nhưng không được
	phản hồi, một cặp sdev_init(), sdev_destroy() sẽ được gọi.

Nếu LLD muốn điều chỉnh cài đặt hàng đợi mặc định, nó có thể gọi
scsi_change_queue_deep() trong quy trình sdev_configure() của nó.

Khi HBA bị xóa, đó có thể là một phần của quá trình tắt máy có trật tự
được liên kết với mô-đun LLD đang được dỡ tải (ví dụ: với "rmmod"
lệnh) hoặc để đáp lại "rút phích cắm nóng" được chỉ định bởi sysfs()'s
lệnh gọi lại Remove() đang được gọi. Trong cả hai trường hợp, trình tự là
giống nhau::

HBA REMOVE: giả sử có 2 thiết bị SCSI được đính kèm
    LLD cấp trung LLD
    ===—————===================------
    scsi_remove_host() ---------+
				|
			sdev_destroy()
			sdev_destroy()
    scsi_host_put()

Việc LLD theo dõi các phiên bản struct Scsi_Host có thể hữu ích
(một con trỏ được trả về bởi scsi_host_alloc()). Những trường hợp như vậy là "sở hữu"
đến mức trung bình.  Các phiên bản struct Scsi_Host được giải phóng khỏi
scsi_host_put() khi số tham chiếu bằng 0.

Rút phích cắm nóng HBA điều khiển đĩa đang xử lý SCSI
các lệnh trên hệ thống tập tin được gắn kết là một tình huống thú vị. Tài liệu tham khảo
logic đếm đang được đưa vào cấp trung để đối phó với nhiều vấn đề
của các vấn đề có liên quan. Xem phần về cách tính tham chiếu bên dưới.


Khái niệm cắm nóng có thể được mở rộng cho các thiết bị SCSI. Hiện nay, khi một
HBA được thêm vào, chức năng scsi_scan_host() thực hiện quét các thiết bị SCSI
được gắn vào bộ vận chuyển SCSI của HBA. Trên SCSI mới hơn vận chuyển HBA
có thể biết về thiết bị SCSI mới _sau khi quá trình quét hoàn tất.
LLD có thể sử dụng trình tự này để giúp cấp trung nhận biết thiết bị SCSI::

Phích cắm nóng SCSI DEVICE
    LLD cấp trung LLD
    ===———===========-------------------====------
    scsi_add_device() ------+
			    |
			sdev_init()
			sdev_configure() [--> scsi_change_queue_deep()]

Theo cách tương tự, LLD có thể biết rằng thiết bị SCSI đã bị
đã bị xóa (rút phích cắm) hoặc kết nối với nó đã bị gián đoạn. Một số
các phương tiện truyền tải SCSI hiện tại (ví dụ SPI) có thể không biết rằng SCSI
thiết bị đã bị xóa cho đến khi lệnh SCSI tiếp theo không thành công, điều này sẽ
có thể khiến thiết bị đó được đặt ngoại tuyến ở mức trung bình. Một chiếc LLD đó
phát hiện việc xóa thiết bị SCSI có thể kích hoạt việc xóa thiết bị đó khỏi
các lớp trên với trình tự này::

Ổ cắm nóng SCSI DEVICE
    LLD cấp trung LLD
    ===—————===================------
    scsi_remove_device() -------+
				|
			sdev_destroy()

Việc LLD theo dõi các phiên bản struct scsi_device có thể hữu ích
(một con trỏ được truyền dưới dạng tham số cho sdev_init() và
lệnh gọi lại sdev_configure()). Những trường hợp như vậy được "sở hữu" bởi cấp trung.
Các phiên bản struct scsi_device được giải phóng sau sdev_destroy().


Đếm tham chiếu
==================
Cấu trúc Scsi_Host đã được bổ sung cơ sở hạ tầng đếm tham chiếu.
Điều này giúp lan truyền quyền sở hữu các phiên bản struct Scsi_Host một cách hiệu quả
trên các lớp SCSI khác nhau sử dụng chúng. Trước đây những trường hợp như vậy
được sở hữu độc quyền bởi cấp trung. LLD thường không cần phải
trực tiếp thao tác các số tham chiếu này nhưng có thể có một số trường hợp
họ làm ở đâu.

Có 3 chức năng đếm tham chiếu được quan tâm liên quan đến
cấu trúc Scsi_Host:

- scsi_host_alloc():
	trả về một con trỏ tới phiên bản mới của struct
        Scsi_Host có số tham chiếu ^^ được đặt thành 1

- scsi_host_get():
	thêm 1 vào số tham chiếu của phiên bản đã cho

- scsi_host_put():
	giảm 1 so với số tham chiếu của giá trị đã cho
        ví dụ. Nếu số tham chiếu đạt tới 0 thì phiên bản đã cho
        được giải phóng

Cấu trúc scsi_device đã được bổ sung cơ sở hạ tầng đếm tham chiếu.
Điều này lan truyền hiệu quả quyền sở hữu của các phiên bản struct scsi_device
trên các lớp SCSI khác nhau sử dụng chúng. Trước đây những trường hợp như vậy
được sở hữu độc quyền bởi cấp trung. Xem các hàm truy cập được khai báo
về phía cuối include/scsi/scsi_device.h . Nếu LLD muốn giữ
một bản sao của con trỏ tới phiên bản scsi_device cần sử dụng scsi_device_get()
để tăng số lượng tham chiếu của nó. Khi hoàn thành với con trỏ, nó có thể
sử dụng scsi_device_put() để giảm số lượng tham chiếu của nó (và có thể
xóa nó đi).

.. Note::

   struct Scsi_Host actually has 2 reference counts which are manipulated
   in parallel by these functions.


Công ước
===========
Đầu tiên, suy nghĩ của Linus Torvalds về phong cách viết mã C có thể được tìm thấy trong
Tệp tài liệu/quy trình/coding-style.rst.

Ngoài ra, hầu hết các cải tiến của C99 đều được khuyến khích trong phạm vi chúng được hỗ trợ.
bởi các trình biên dịch gcc có liên quan. Vậy cấu trúc và mảng kiểu C99
công cụ khởi tạo được khuyến khích khi thích hợp. Đừng đi quá xa,
VLA chưa được hỗ trợ đúng cách.  Một ngoại lệ cho điều này là việc sử dụng
Nhận xét về phong cách ZZ0000ZZ; Nhận xét ZZ0001ZZ vẫn được ưu tiên trong Linux.

Mã được viết, kiểm tra và ghi lại tốt, không cần phải định dạng lại để
tuân thủ các quy ước trên. Ví dụ: trình điều khiển aic7xxx
đến với Linux từ phòng thí nghiệm riêng của FreeBSD và Adaptec. Không còn nghi ngờ gì nữa FreeBSD
và Adaptec có quy ước mã hóa riêng.


Các chức năng được cung cấp ở cấp độ trung bình
============================
Các chức năng này được cung cấp bởi SCSI cấp trung để LLD sử dụng.
Tên (tức là điểm vào) của các hàm này được xuất
vì vậy LLD là một mô-đun có thể truy cập chúng. Hạt nhân sẽ
sắp xếp để tải và khởi tạo SCSI cấp trung trước bất kỳ LLD nào
được khởi tạo. Các chức năng dưới đây được liệt kê theo thứ tự bảng chữ cái và
tên đều bắt đầu bằng ZZ0000ZZ.

Bản tóm tắt:

- scsi_add_device - tạo phiên bản thiết bị scsi (lu) mới
  - scsi_add_host - thực hiện đăng ký sysfs và thiết lập lớp vận chuyển
  - scsi_change_queue_deep - thay đổi độ sâu hàng đợi trên thiết bị SCSI
  - scsi_bios_ptable - trả về bản sao bảng phân vùng của thiết bị khối
  - scsi_block_requests - ngăn các lệnh tiếp theo được xếp hàng đợi đến máy chủ nhất định
  - scsi_host_alloc - trả về một phiên bản scsi_host mới có số lần đếm==1
  - scsi_host_get - tăng số lần đếm lại của phiên bản Scsi_Host
  - scsi_host_put - giảm số lần giới thiệu của phiên bản Scsi_Host (miễn phí nếu 0)
  - scsi_remove_device - tách và tháo thiết bị SCSI
  - scsi_remove_host - tách và xóa tất cả các thiết bị SCSI do máy chủ sở hữu
  - scsi_report_bus_reset - báo cáo đã quan sát thấy thiết lập lại scsi _bus_
  - scsi_scan_host - quét xe buýt SCSI
  - scsi_track_queue_full - theo dõi các sự kiện QUEUE_FULL liên tiếp
  - scsi_unblock_requests - cho phép các lệnh khác được xếp hàng đợi vào máy chủ nhất định


Chi tiết::

/**
    * scsi_add_device - tạo phiên bản thiết bị scsi (lu) mới
    * @shost: con trỏ tới phiên bản máy chủ scsi
    * @channel: số kênh (hiếm khi khác 0)
    * @id: số id mục tiêu
    * @lun: số đơn vị logic
    *
    * Trả về con trỏ tới phiên bản struct scsi_device mới hoặc
    * ERR_PTR(-ENODEV) (hoặc một số con trỏ cong khác) nếu có gì đó không ổn
    * sai (ví dụ: không có lu trả lời tại địa chỉ đã cho)
    *
    * Có thể chặn: có
    *
    * Lưu ý: Cuộc gọi này thường được thực hiện nội bộ trong quá trình scsi
    * quét bus khi HBA được thêm vào (tức là scsi_scan_host()). Vì vậy nó
    * chỉ nên được gọi nếu HBA nhận biết được scsi mới
    * thiết bị (lu) sau khi scsi_scan_host() hoàn thành. Nếu thành công
    * lệnh gọi này có thể dẫn đến lệnh gọi lại sdev_init() và sdev_configure()
    * vào LLD.
    *
    * Được định nghĩa trong: driver/scsi/scsi_scan.c
    **/
    struct scsi_device * scsi_add_device(struct Scsi_Host *shost,
					kênh int không dấu,
					id int không dấu, int không dấu lun)


/**
    * scsi_add_host - thực hiện đăng ký sysfs và thiết lập lớp vận chuyển
    * @shost: con trỏ tới phiên bản máy chủ scsi
    * @dev: con trỏ tới thiết bị struct thuộc loại lớp scsi
    *
    * Trả về 0 khi thành công, lỗi âm nếu thất bại (ví dụ -ENOMEM)
    *
    * Có thể chặn: không
    *
    * Lưu ý: Chỉ được yêu cầu trong "mô hình khởi tạo hotplug" sau
    * gọi thành công tới scsi_host_alloc().  Chức năng này không
    * quét xe buýt; điều này có thể được thực hiện bằng cách gọi scsi_scan_host() hoặc
    * theo một số cách vận chuyển cụ thể khác.  LLD phải được thiết lập
    * mẫu vận chuyển trước khi gọi hàm này và chỉ có thể
    * truy cập dữ liệu lớp vận chuyển sau khi hàm này được gọi.
    *
    * Được định nghĩa trong: driver/scsi/hosts.c
    **/
    int scsi_add_host(struct Scsi_Host ZZ0000ZZ dev)


/**
    * scsi_change_queue_deep - cho phép LLD thay đổi độ sâu hàng đợi trên thiết bị SCSI
    * @sdev: con trỏ tới thiết bị SCSI để thay đổi độ sâu hàng đợi trên
    * @tags Số lượng thẻ được phép nếu bật xếp hàng được gắn thẻ,
    * hoặc số lượng lệnh mà LLD có thể xếp hàng
    * ở chế độ không được gắn thẻ (theo cmd_per_lun).
    *
    * Không trả lại gì
    *
    * Có thể chặn: không
    *
    * Lưu ý: Có thể gọi bất cứ lúc nào trên thiết bị SCSI được điều khiển bởi thiết bị này
    *LLD. [Cụ thể trong và sau sdev_configure() và trước
    * sdev_destroy().] Có thể được gọi một cách an toàn từ mã ngắt.
    *
    * Được định nghĩa trong: driver/scsi/scsi.c [xem mã nguồn để biết thêm ghi chú]
    *
    **/
    int scsi_change_queue_deep(struct scsi_device *sdev, thẻ int)


/**
    * scsi_bios_ptable - trả về bản sao bảng phân vùng của thiết bị khối
    * @dev: con trỏ tới gendisk
    *
    * Trả về con trỏ tới bảng phân vùng hoặc NULL nếu bị lỗi
    *
    * Có thể chặn: có
    *
    * Lưu ý: Người gọi sở hữu bộ nhớ được trả về (miễn phí với kfree() )
    *
    * Được định nghĩa trong: driver/scsi/scsicam.c
    **/
    ký tự không dấu *scsi_bios_ptable(struct gendisk *dev)


/**
    * scsi_block_requests - ngăn các lệnh tiếp theo được xếp hàng đợi đến máy chủ nhất định
    *
    * @shost: con trỏ tới máy chủ để chặn lệnh trên
    *
    * Không trả lại gì
    *
    * Có thể chặn: không
    *
    * Lưu ý: Không có bộ đếm thời gian cũng như bất kỳ phương tiện nào khác để yêu cầu
    * được bỏ chặn ngoài LLD đang gọi scsi_unblock_requests().
    *
    * Được định nghĩa trong: driver/scsi/scsi_lib.c
    **/
    void scsi_block_requests(struct Scsi_Host * shost)


/**
    * scsi_host_alloc - tạo phiên bản bộ điều hợp máy chủ scsi và thực hiện các thao tác cơ bản
    * khởi tạo.
    * @sht: con trỏ tới mẫu máy chủ scsi
    * @privsize: byte bổ sung để phân bổ trong mảng dữ liệu máy chủ (là
    * thành viên cuối cùng của phiên bản Scsi_Host được trả về)
    *
    * Trả về con trỏ tới phiên bản Scsi_Host mới hoặc NULL khi bị lỗi
    *
    * Có thể chặn: có
    *
    * Lưu ý: Khi cuộc gọi này quay trở lại LLD, việc quét bus SCSI sẽ bật
    * máy chủ này chưa _not_ được thực hiện.
    * Mảng dữ liệu máy chủ (theo mặc định có độ dài bằng 0) là một vết xước trên mỗi máy chủ
    * khu vực dành riêng cho LLD.
    * Cả hai đối tượng đếm lại liên quan đều có số lần đếm lại được đặt thành 1.
    * Đăng ký đầy đủ (trong sysfs) và quét xe buýt được thực hiện sau khi
    * scsi_add_host() và scsi_scan_host() được gọi.
    *
    * Được định nghĩa trong: driver/scsi/hosts.c .
    **/
    struct Scsi_Host * scsi_host_alloc(const struct scsi_host_template * sht,
				    int riêng tư)


/**
    * scsi_host_get - tăng số lần đếm phiên bản Scsi_Host
    * @shost: con trỏ tới cá thể struct Scsi_Host
    *
    * Không trả lại gì
    *
    * Có thể chặn: hiện tại có thể chặn nhưng có thể đổi thành không chặn
    *
    * Lưu ý: Thực tế là tăng số lượng trong hai đối tượng con
    *
    * Được định nghĩa trong: driver/scsi/hosts.c
    **/
    void scsi_host_get(struct Scsi_Host *shost)


/**
    * scsi_host_put - giảm số lần giới thiệu phiên bản Scsi_Host, miễn phí nếu 0
    * @shost: con trỏ tới cá thể struct Scsi_Host
    *
    * Không trả lại gì
    *
    * Có thể chặn: hiện tại có thể chặn nhưng có thể đổi thành không chặn
    *
    * Lưu ý: Thực tế là giảm số lượng trong hai đối tượng con. Nếu
    * số lần đếm sau đạt đến 0, phiên bản Scsi_Host được giải phóng.
    * LLD không cần phải lo lắng chính xác khi có phiên bản Scsi_Host
    * được giải phóng, nó chỉ không nên truy cập vào phiên bản sau khi đã cân bằng
    * hết việc sử dụng tiền hoàn lại của nó.
    *
    * Được định nghĩa trong: driver/scsi/hosts.c
    **/
    void scsi_host_put(struct Scsi_Host *shost)


/**
    * scsi_remove_device - tách và xóa thiết bị SCSI
    * @sdev: con trỏ tới phiên bản thiết bị scsi
    *
    * Trả về giá trị: 0 nếu thành công, -EINVAL nếu thiết bị không được đính kèm
    *
    * Có thể chặn: có
    *
    * Lưu ý: Nếu LLD biết rằng thiết bị scsi (lu) có
    * đã bị xóa nhưng máy chủ của nó vẫn tồn tại thì nó có thể yêu cầu
    * việc loại bỏ thiết bị scsi đó. Nếu thành công cuộc gọi này sẽ
    * dẫn đến lệnh gọi lại sdev_destroy() được gọi. sdev là một
    * con trỏ không hợp lệ sau cuộc gọi này.
    *
    * Được xác định trong: driver/scsi/scsi_sysfs.c .
    **/
    int scsi_remove_device(struct scsi_device *sdev)


/**
    * scsi_remove_host - tách và xóa tất cả các thiết bị SCSI do máy chủ sở hữu
    * @shost: con trỏ tới phiên bản máy chủ scsi
    *
    * Trả về giá trị: 0 nếu thành công, 1 nếu thất bại (ví dụ: LLD bận ??)
    *
    * Có thể chặn: có
    *
    * Lưu ý: Chỉ nên gọi nếu quá trình "khởi tạo hotplug
    * mô hình" đang được sử dụng. Nó nên được gọi là _prior_
    * gọi scsi_host_put().
    *
    * Được định nghĩa trong: driver/scsi/hosts.c .
    **/
    int scsi_remove_host(struct Scsi_Host *shost)


/**
    * scsi_report_bus_reset - báo cáo đã quan sát thấy thiết lập lại scsi _bus_
    * @shost: con trỏ tới máy chủ scsi có liên quan
    * @channel: máy chủ kênh (bên trong) nơi xảy ra hiện tượng thiết lập lại bus scsi
    *
    * Không trả lại gì
    *
    * Có thể chặn: không
    *
    * Lưu ý: Điều này chỉ cần được gọi nếu thiết lập lại là một
    * bắt nguồn từ một địa điểm không xác định.  Việc đặt lại có nguồn gốc từ
    * Bản thân cấp trung không cần gọi thế này, nhưng nên có
    * không có hại.  Mục đích chính của việc này là để đảm bảo rằng một
    * CHECK_CONDITION được xử lý đúng cách.
    *
    * Được xác định trong: driver/scsi/scsi_error.c .
    **/
    void scsi_report_bus_reset(struct Scsi_Host * shost, int kênh)


/**
    * scsi_scan_host - quét xe buýt SCSI
    * @shost: con trỏ tới phiên bản máy chủ scsi
    *
    * Có thể chặn: có
    *
    * Lưu ý: Nên gọi sau scsi_add_host()
    *
    * Được định nghĩa trong: driver/scsi/scsi_scan.c
    **/
    void scsi_scan_host(struct Scsi_Host *shost)


/**
    * scsi_track_queue_full - theo dõi các sự kiện QUEUE_FULL liên tiếp đã cho
    * thiết bị để xác định xem và khi nào có nhu cầu
    * để điều chỉnh độ sâu hàng đợi trên thiết bị.
    * @sdev: con trỏ tới phiên bản thiết bị SCSI
    * @deep: Số lượng lệnh SCSI nổi bật hiện tại trên thiết bị này,
    * không tính cái được trả về là QUEUE_FULL.
    *
    * Trả về 0 - không cần thay đổi
    * >0 - điều chỉnh độ sâu hàng đợi theo độ sâu mới này
    * -1 - quay lại hoạt động không được gắn thẻ bằng cách sử dụng máy chủ-> cmd_per_lun
    * là độ sâu lệnh không được gắn thẻ
    *
    * Có thể chặn: không
    *
    * Lưu ý: LLD có thể gọi đây là bất cứ lúc nào và chúng tôi sẽ thực hiện "Quyền
    * Điều"; ngắt bối cảnh an toàn.
    *
    * Được định nghĩa trong: driver/scsi/scsi.c .
    **/
    int scsi_track_queue_full(struct scsi_device *sdev, int deep)


/**
    * scsi_unblock_requests - cho phép các lệnh tiếp theo được xếp hàng đợi vào máy chủ nhất định
    *
    * @shost: con trỏ tới máy chủ để bỏ chặn lệnh trên
    *
    * Không trả lại gì
    *
    * Có thể chặn: không
    *
    * Được xác định trong: driver/scsi/scsi_lib.c .
    **/
    void scsi_unblock_requests(struct Scsi_Host * shost)



Chức năng giao diện
===================
Các chức năng giao diện được cung cấp (được xác định) bởi LLD và chức năng của chúng
con trỏ được đặt trong một thể hiện của struct scsi_host_template
được chuyển tới scsi_host_alloc().
Một số là bắt buộc. Các chức năng giao diện phải được khai báo tĩnh. các
quy ước được chấp nhận là trình điều khiển "xyz" sẽ khai báo sdev_configure() của nó
hoạt động như::

int tĩnh xyz_sdev_configure(struct scsi_device * sdev);

v.v. cho tất cả các chức năng giao diện được liệt kê bên dưới.

Một con trỏ tới hàm này phải được đặt trong thành viên 'sdev_configure'
của phiên bản "struct scsi_host_template". Một con trỏ tới một thể hiện như vậy
phải được chuyển tới scsi_host_alloc() của cấp trung.
.

Các chức năng giao diện cũng được mô tả trong include/scsi/scsi_host.h
tệp ngay phía trên điểm định nghĩa của chúng trong "struct scsi_host_template".
Trong một số trường hợp, scsi_host.h sẽ cung cấp nhiều chi tiết hơn bên dưới.

Các chức năng giao diện được liệt kê dưới đây theo thứ tự bảng chữ cái.

Bản tóm tắt:

- bios_param - tìm nạp thông tin về đầu, khu vực, hình trụ cho đĩa
  - eh_timed_out - thông báo cho máy chủ rằng bộ đếm thời gian lệnh đã hết hạn
  - eh_abort_handler - hủy lệnh đã cho
  - eh_bus_reset_handler - vấn đề thiết lập lại bus SCSI
  - eh_device_reset_handler - vấn đề thiết lập lại thiết bị SCSI
  - eh_host_reset_handler - đặt lại máy chủ (bộ điều hợp bus máy chủ)
  - thông tin - cung cấp thông tin về máy chủ nhất định
  - ioctl - trình điều khiển có thể phản hồi ioctls
  - proc_info - hỗ trợ /proc/scsi/{driver_name}/{host_no}
  - queuecommand - lệnh xếp hàng scsi, gọi 'xong' khi hoàn thành
  - sdev_init - trước khi bất kỳ lệnh nào được gửi đến thiết bị mới
  - sdev_configure - tinh chỉnh trình điều khiển cho thiết bị nhất định sau khi đính kèm
  - sdev_destroy - thiết bị sắp ngừng hoạt động


Chi tiết::

/**
    * bios_param - tìm nạp thông tin đầu, cung, trụ cho đĩa
    * @sdev: con trỏ tới bối cảnh thiết bị scsi (được định nghĩa trong
    * bao gồm/scsi/scsi_device.h)
    * @disk: con trỏ tới gendisk (được định nghĩa trong blkdev.h)
    * @capacity: kích thước thiết bị (trong các cung 512 byte)
    * @params: mảng ba phần tử để đặt đầu ra:
    * params[0] số lượng đầu (tối đa 255)
    * params[1] số lượng lĩnh vực (tối đa 63)
    * params[2] số lượng xi lanh
    *
    * Giá trị trả về bị bỏ qua
    *
    * Ổ khóa: không có
    *
    * Ngữ cảnh gọi: tiến trình (sd)
    *
    * Lưu ý: sử dụng hình học tùy ý (dựa trên READ CAPACITY)
    * nếu chức năng này không được cung cấp. Mảng thông số là
    * được khởi tạo trước với các giá trị đã tạo chỉ trong trường hợp hàm này
    * không xuất ra bất cứ thứ gì.
    *
    * Tùy chọn được xác định trong: LLD
    **/
	int bios_param(struct scsi_device * sdev, struct gendisk *disk,
		    dung lượng của ngành_t, thông số int [3])


/**
    * eh_timed_out - Bộ đếm thời gian cho lệnh vừa kích hoạt
    * @scp: xác định thời gian chờ lệnh
    *
    * Trả về:
    *
    * EH_HANDLED: Tôi đã sửa lỗi, vui lòng hoàn thành lệnh
    * EH_RESET_TIMER: Tôi cần thêm thời gian, đặt lại bộ hẹn giờ và
    * bắt đầu đếm lại
    * EH_NOT_HANDLED Bắt đầu khôi phục lỗi thông thường
    *
    *
    * Ổ khóa: Không giữ được
    *
    * Ngữ cảnh gọi: ngắt
    *
    * Lưu ý: Điều này nhằm tạo cơ hội cho LLD thực hiện khôi phục cục bộ.
    * Việc khôi phục này được giới hạn trong việc xác định xem lệnh còn tồn đọng có
    * sẽ không bao giờ hoàn thành.  Bạn không thể hủy bỏ và khởi động lại lệnh từ
    * cuộc gọi lại này.
    *
    * Tùy chọn được xác định trong: LLD
    **/
	int eh_timed_out(struct scsi_cmnd * scp)


/**
    * eh_abort_handler - lệnh hủy liên kết với scp
    * @scp: xác định lệnh bị hủy
    *
    * Trả về SUCCESS nếu lệnh bị hủy bỏ FAILED
    *
    * Ổ khóa: Không giữ được
    *
    * Ngữ cảnh gọi: kernel thread
    *
    * Lưu ý: Lệnh này chỉ được gọi cho lệnh đã hết thời gian chờ.
    *
    * Tùy chọn được xác định trong: LLD
    **/
	int eh_abort_handler(struct scsi_cmnd * scp)


/**
    * eh_bus_reset_handler - vấn đề thiết lập lại bus SCSI
    * @scp: Bus SCSI chứa thiết bị này nên được đặt lại
    *
    * Trả về SUCCESS nếu lệnh bị hủy bỏ FAILED
    *
    * Ổ khóa: Không giữ được
    *
    * Ngữ cảnh gọi: kernel thread
    *
    * Lưu ý: Được gọi từ thread scsi_eh. Sẽ không có lệnh nào khác
    * xếp hàng trên máy chủ hiện tại trong thời gian eh.
    *
    * Tùy chọn được xác định trong: LLD
    **/
	int eh_bus_reset_handler(struct scsi_cmnd * scp)


/**
    * eh_device_reset_handler - vấn đề thiết lập lại thiết bị SCSI
    * @scp: xác định thiết bị SCSI cần reset
    *
    * Trả về SUCCESS nếu lệnh bị hủy bỏ FAILED
    *
    * Ổ khóa: Không giữ được
    *
    * Ngữ cảnh gọi: kernel thread
    *
    * Lưu ý: Được gọi từ thread scsi_eh. Sẽ không có lệnh nào khác
    * xếp hàng trên máy chủ hiện tại trong thời gian eh.
    *
    * Tùy chọn được xác định trong: LLD
    **/
	int eh_device_reset_handler(struct scsi_cmnd * scp)


/**
    * eh_host_reset_handler - đặt lại máy chủ (bộ điều hợp bus máy chủ)
    * @scp: Máy chủ SCSI chứa thiết bị này cần được đặt lại
    *
    * Trả về SUCCESS nếu lệnh bị hủy bỏ FAILED
    *
    * Ổ khóa: Không giữ được
    *
    * Ngữ cảnh gọi: kernel thread
    *
    * Lưu ý: Được gọi từ thread scsi_eh. Sẽ không có lệnh nào khác
    * xếp hàng trên máy chủ hiện tại trong thời gian eh.
    * Với eh_strategy mặc định đã có sẵn, nếu không có _abort_ nào,
    * _device_reset_, _bus_reset_ hoặc hàm xử lý eh này là
    * được xác định (hoặc tất cả đều trả về FAILED) thì thiết bị được đề cập
    * sẽ được đặt ngoại tuyến bất cứ khi nào eh được gọi.
    *
    * Tùy chọn được xác định trong: LLD
    **/
	int eh_host_reset_handler(struct scsi_cmnd * scp)


/**
    * thông tin - cung cấp thông tin về máy chủ đã cho: tên trình điều khiển cộng với dữ liệu
    * để phân biệt máy chủ đã cho
    * @shp: máy chủ cung cấp thông tin về
    *
    * Trả về chuỗi kết thúc null ASCII. [Trình điều khiển này được cho là
    * quản lý bộ nhớ được trỏ tới và duy trì nó, thường là cho
    * thời gian tồn tại của máy chủ này.]
    *
    * Ổ khóa: không có
    *
    * Ngữ cảnh gọi: tiến trình
    *
    * Lưu ý: Thường cung cấp thông tin PCI hoặc ISA như địa chỉ IO
    * và số ngắt. Nếu không được cung cấp, struct Scsi_Host::name đã được sử dụng
    * thay vào đó. Giả sử thông tin trả về nằm gọn trên một dòng
    * (tức là không bao gồm các dòng mới được nhúng).
    * SCSI_IOCTL_PROBE_HOST ioctl mang lại chuỗi được trả về bởi điều này
    * function (hoặc struct Scsi_Host::name nếu chức năng này không có
    * có sẵn).
    *
    * Tùy chọn được xác định trong: LLD
    **/
	const char * info(struct Scsi_Host * shp)


/**
    * ioctl - trình điều khiển có thể phản hồi ioctls
    * @sdp: thiết bị mà ioctl được cấp cho
    * @cmd: số ioctl
    * @arg: con trỏ để đọc hoặc ghi dữ liệu. Vì nó trỏ đến
    * không gian người dùng, nên sử dụng các chức năng kernel thích hợp
    * (ví dụ: copy_from_user() ). Theo phong cách Unix, đối số này
    * cũng có thể được xem dưới dạng dài không dấu.
    *
    * Trả về giá trị âm "errno" khi có vấn đề. 0 hoặc một
    * giá trị dương biểu thị thành công và được trả về không gian người dùng.
    *
    * Ổ khóa: không có
    *
    * Ngữ cảnh gọi: tiến trình
    *
    * Lưu ý: Hệ thống con SCSI sử dụng mô hình ioctl "nhỏ giọt".
    * Người dùng đưa ra ioctl() đối với trình điều khiển cấp cao hơn
    * (ví dụ: /dev/sdc) và nếu trình điều khiển cấp cao hơn không nhận ra
    * 'cmd' sau đó nó được chuyển đến cấp trung SCSI. Nếu SCSI
    * cấp trung không nhận thì LLD điều khiển
    * thiết bị nhận được ioctl. Theo tiêu chuẩn Unix gần đây
    * Các số 'cmd' ioctl() không được hỗ trợ sẽ trả về -ENOTTY.
    *
    * Tùy chọn được xác định trong: LLD
    **/
	int ioctl(struct scsi_device *sdp, int cmd, void *arg)


/**
    * proc_info - hỗ trợ /proc/scsi/{driver_name}/{host_no}
    * @buffer: điểm neo để xuất ra (0==writeto1_read0) hoặc tìm nạp từ
    * (1==writeto1_read0).
    * @start: nơi dữ liệu "thú vị" được ghi vào. Bỏ qua khi
    * 1==ghi vào1_read0.
    * @offset: phần bù trong bộ đệm 0==writeto1_read0 thực tế là
    * quan tâm. Bỏ qua khi 1==writeto1_read0 .
    * @length: phạm vi tối đa (hoặc thực tế) của bộ đệm
    * @host_no: số lượng máy chủ quan tâm (struct Scsi_Host::host_no)
    * @writeto1_read0: 1 -> dữ liệu đến từ không gian người dùng tới trình điều khiển
    * (ví dụ: "echo some_string > /proc/scsi/xyz/2")
    * 0 -> người dùng dữ liệu gì từ trình điều khiển này
    * (ví dụ: "cat /proc/scsi/xyz/2")
    *
    * Trả về độ dài khi 1==writeto1_read0. Nếu không thì số ký tự
    * xuất ra vùng đệm quá khứ.
    *
    * Ổ khóa: không có ổ khóa nào được giữ
    *
    * Ngữ cảnh gọi: tiến trình
    *
    * Lưu ý: Được điều khiển từ scsi_proc.c giao diện với proc_fs. proc_fs
    * hỗ trợ bây giờ có thể được cấu hình từ hệ thống con scsi.
    *
    * Tùy chọn được xác định trong: LLD
    **/
	int proc_info(char * buffer, char ** start, off_t offset,
		    độ dài int, int Host_no, int writeto1_read0)


/**
    * queuecommand - lệnh xếp hàng scsi, gọi scp->scsi_done khi hoàn thành
    * @shost: con trỏ tới đối tượng máy chủ scsi
    * @scp: con trỏ tới đối tượng lệnh scsi
    *
    * Trả về 0 khi thành công.
    *
    * Nếu có lỗi thì trả về:
    *
    * SCSI_MLQUEUE_DEVICE_BUSY nếu hàng đợi thiết bị đầy hoặc
    * SCSI_MLQUEUE_HOST_BUSY nếu toàn bộ hàng đợi máy chủ đã đầy
    *
    * Trên cả hai lần trả về này, lớp giữa sẽ yêu cầu I/O xếp hàng đợi
    *
    * - nếu kết quả trả về là SCSI_MLQUEUE_DEVICE_BUSY, chỉ cụ thể đó
    * thiết bị sẽ bị tạm dừng và nó sẽ không bị tạm dừng khi có lệnh
    * thiết bị sẽ quay trở lại (hoặc sau một khoảng thời gian trễ ngắn nếu không còn thiết bị nào nữa
    * các lệnh nổi bật đối với nó).  Lệnh đến các thiết bị khác tiếp tục
    * được xử lý bình thường.
    *
    * - nếu kết quả trả về là SCSI_MLQUEUE_HOST_BUSY, tất cả I/O tới máy chủ
    * bị tạm dừng và sẽ không bị tạm dừng khi có bất kỳ lệnh nào quay trở lại từ
    * máy chủ (hoặc sau một thời gian trì hoãn ngắn nếu không có khoản nợ nào còn tồn đọng)
    * lệnh đến máy chủ).
    *
    * Để tương thích với các phiên bản cũ hơn của queuecommand, bất kỳ
    * giá trị trả về khác được xử lý giống như
    *SCSI_MLQUEUE_HOST_BUSY.
    *
    * Các loại lỗi khác được phát hiện ngay lập tức có thể là
    * được gắn cờ bằng cách đặt scp->result thành một giá trị phù hợp,
    * gọi lệnh gọi lại scp->scsi_done và sau đó trả về 0
    * từ chức năng này. Nếu lệnh không được thực hiện
    * ngay lập tức (và LLD đang bắt đầu (hoặc sẽ bắt đầu) chế độ đã cho
    * lệnh) thì hàm này sẽ đặt 0 trong scp->result và
    * trả về 0.
    *
    * Quyền sở hữu lệnh.  Nếu trình điều khiển trả về 0, nó sở hữu
    * Chỉ huy và phải chịu trách nhiệm đảm bảo
    * lệnh gọi lại scp->scsi_done được thực thi.  Lưu ý: người lái xe có thể
    * gọi scp->scsi_done trước khi trả về 0, nhưng sau khi nó trả về 0
    * được gọi là scp->scsi_done, nó không được trả về bất kỳ giá trị nào ngoài
    * không.  Nếu người lái xe trả về khác 0 thì không được
    * thực hiện lệnh gọi lại scsi_done của lệnh bất cứ lúc nào.
    *
    * Khóa: tối đa và bao gồm 2.6.36, struct Scsi_Host::host_lock
    * được giữ lại khi nhập cảnh (với "irqsave") và dự kiến sẽ được
    * được giữ khi trả lại. Từ 2.6.37 trở đi, queuecommand là
    * được gọi mà không có bất kỳ khóa nào được giữ.
    *
    * Ngữ cảnh gọi: trong ngữ cảnh ngắt (irq mềm) hoặc ngữ cảnh xử lý
    *
    * Lưu ý: Chức năng này phải tương đối nhanh. Thông thường nó
    * sẽ không đợi IO hoàn thành. Do đó scp->scsi_done
    * gọi lại được gọi (thường trực tiếp từ dịch vụ ngắt
    * thường trình) một thời gian sau khi chức năng này quay trở lại. Ở một số
    * các trường hợp (ví dụ: trình điều khiển bộ chuyển đổi giả tạo ra
    * phản hồi với SCSI INQUIRY), lệnh gọi lại scp->scsi_done có thể là
    * được gọi trước khi hàm này trả về.  Nếu scp->scsi_done
    * cuộc gọi lại không được gọi trong một khoảng thời gian nhất định giữa SCSI
    * Mức độ sẽ bắt đầu xử lý lỗi.  Nếu trạng thái CHECK
    * CONDITION được đặt trong "kết quả" khi scp->scsi_done
    * lệnh gọi lại được gọi, thì trình điều khiển LLD sẽ thực hiện
    * autosense và điền vào struct scsi_cmnd::sense_buffer
    * mảng. Mảng scsi_cmnd::sense_buffer có giá trị 0 trước
    * cấp trung xếp hàng lệnh tới LLD.
    *
    * Được xác định trong: LLD
    **/
	enum scsi_qc_status queuecommand(struct Scsi_Host *shost,
					 cấu trúc scsi_cmnd *scp)


/**
    * sdev_init - trước khi bất kỳ lệnh nào được gửi đến thiết bị mới
    * (tức là ngay trước khi quét) cuộc gọi này được thực hiện
    * @sdp: con trỏ tới thiết bị mới (sắp quét)
    *
    * Trả về 0 nếu được. Bất kỳ sự trở lại nào khác được coi là một lỗi và
    * thiết bị bị bỏ qua.
    *
    * Ổ khóa: không có
    *
    * Ngữ cảnh gọi: tiến trình
    *
    * Lưu ý: Cho phép trình điều khiển phân bổ bất kỳ tài nguyên nào cho thiết bị
    * trước lần quét đầu tiên. Thiết bị scsi tương ứng có thể không
    * tồn tại nhưng mức trung bình sắp quét nó (tức là gửi
    * và lệnh INQUIRY cộng ...). Nếu một thiết bị được tìm thấy thì
    * sdev_configure() sẽ được gọi nếu không tìm thấy thiết bị
    * sdev_destroy() được gọi.
    * Để biết thêm chi tiết, hãy xem tệp include/scsi/scsi_host.h.
    *
    * Tùy chọn được xác định trong: LLD
    **/
	int sdev_init(struct scsi_device *sdp)


/**
    * sdev_configure - tinh chỉnh trình điều khiển cho thiết bị nhất định ngay sau thiết bị đó
    * đã được quét lần đầu tiên (tức là nó đã phản hồi một
    *INQUIRY)
    * @sdp: thiết bị vừa được gắn vào
    *
    * Trả về 0 nếu được. Bất kỳ sự trở lại nào khác được coi là một lỗi và
    * thiết bị được đưa ngoại tuyến. [các thiết bị ngoại tuyến sẽ _không_ có
    * sdev_destroy() đã kêu gọi họ dọn dẹp tài nguyên.]
    *
    * Ổ khóa: không có
    *
    * Ngữ cảnh gọi: tiến trình
    *
    * Lưu ý: Cho phép người lái xe kiểm tra phản ứng ban đầu
    * INQUIRY được thực hiện bằng cách quét mã và có hành động thích hợp.
    * Để biết thêm chi tiết, hãy xem tệp include/scsi/scsi_host.h.
    *
    * Tùy chọn được xác định trong: LLD
    **/
	int sdev_configure(struct scsi_device *sdp)


/**
    * sdev_destroy - thiết bị sắp ngừng hoạt động. Tất cả
    * hoạt động đã ngừng trên thiết bị này.
    * @sdp: thiết bị sắp bị tắt
    *
    * Không trả lại gì
    *
    * Ổ khóa: không có
    *
    * Ngữ cảnh gọi: tiến trình
    *
    * Lưu ý: Cấu trúc cấp trung cho thiết bị nhất định vẫn được áp dụng
    * nhưng sắp bị phá bỏ. Bất kỳ tài nguyên nào trên mỗi thiết bị được phân bổ
    * bởi trình điều khiển này cho thiết bị nhất định sẽ được giải phóng ngay bây giờ. Không xa hơn
    * các lệnh sẽ được gửi cho phiên bản sdp này. [Tuy nhiên thiết bị
    * có thể được đính kèm lại trong tương lai, trong trường hợp đó là một phiên bản mới
    * của struct scsi_device sẽ được cung cấp bởi sdev_init() trong tương lai
    * và các lệnh gọi sdev_configure().]
    *
    * Tùy chọn được xác định trong: LLD
    **/
	void sdev_destroy(struct scsi_device *sdp)



Cấu trúc dữ liệu
===============
cấu trúc scsi_host_template
-------------------------
Có một phiên bản "struct scsi_host_template" cho mỗi LLD [#]_. Đó là
thường được khởi tạo dưới dạng phạm vi tệp tĩnh trong tệp tiêu đề của trình điều khiển. Đó
cách các thành viên không được khởi tạo rõ ràng sẽ được đặt thành 0 hoặc NULL.
Thành viên quan tâm:

tên
		 - tên của trình điều khiển (có thể chứa khoảng trắng, vui lòng giới hạn ở
                   ít hơn 80 ký tự)

proc_name
		 - tên được sử dụng trong "/proc/scsi/<proc_name>/<host_no>" và
                   bởi sysfs trong một trong các thư mục "trình điều khiển" của nó. Do đó
                   "proc_name" chỉ được phép chứa các ký tự được chấp nhận
                   thành tên tệp Unix.

ZZ0000ZZ
		 - cuộc gọi lại chính mà cấp trung sử dụng để tiêm
                   SCSI ra lệnh vào LLD.

nhà cung cấp_id
		 - một giá trị duy nhất xác định nhà cung cấp cung cấp
                   LLD dành cho Scsi_Host.  Được sử dụng thường xuyên nhất trong việc xác nhận
                   yêu cầu tin nhắn cụ thể của nhà cung cấp.  Giá trị bao gồm một
                   loại định danh và giá trị dành riêng cho nhà cung cấp.
                   Xem scsi_netlink.h để biết mô tả về các định dạng hợp lệ.

Cấu trúc được xác định và nhận xét trong include/scsi/scsi_host.h

.. [#] In extreme situations a single driver may have several instances
       if it controls several different classes of hardware (e.g. an LLD
       that handles both ISA and PCI cards and has a separate instance of
       struct scsi_host_template for each class).

cấu trúc Scsi_Host
----------------
Có một phiên bản Scsi_Host struct trên mỗi máy chủ (HBA) mà LLD
điều khiển. Cấu trúc struct Scsi_Host có nhiều thành viên chung
với "struct scsi_host_template". Khi có một phiên bản struct Scsi_Host mới
được tạo (trong scsi_host_alloc() tronghost.c) những thành viên chung đó là
được khởi tạo từ phiên bản struct scsi_host_template của trình điều khiển. Thành viên
quan tâm:

máy chủ_không
		 - số duy nhất trên toàn hệ thống được sử dụng để xác định
                   chủ nhà này. Được ban hành theo thứ tự tăng dần từ 0.
    can_queue
		 - phải lớn hơn 0; không gửi nhiều hơn can_queue
                   lệnh tới bộ điều hợp.
    this_id
		 - scsi id của máy chủ (scsi initiator) hoặc -1 nếu không biết
    sg_tablesize
		 - các phần tử thu thập phân tán tối đa được máy chủ cho phép.
                   Đặt giá trị này thành SG_ALL hoặc ít hơn để tránh danh sách SG bị xâu chuỗi.
                   Phải có ít nhất 1.
    max_sector
		 - số lượng cung tối đa (thường là 512 byte) được phép
                   trong một lệnh SCSI duy nhất. Giá trị mặc định là 0 khách hàng tiềm năng
                   đến cài đặt SCSI_DEFAULT_MAX_SECTORS (được xác định trong
                   scsi_host.h) hiện được đặt thành 1024. Vì vậy, đối với
                   disk kích thước truyền tối đa là 512 KB khi max_sectors
                   không được xác định. Lưu ý rằng kích thước này có thể không đủ
                   để tải lên chương trình cơ sở đĩa.
    cmd_per_lun
		 - số lượng lệnh tối đa có thể được xếp hàng đợi trên thiết bị
                   được chủ nhà điều khiển. Bị ghi đè bởi các lệnh gọi LLD tới
                   scsi_change_queue_deep().
    chủ nhà
		 - con trỏ tới cấu trúc scsi_host_template của trình điều khiển từ đó
                   phiên bản struct Scsi_Host này đã được sinh ra
    máy chủ->proc_name
		 - tên của LLD. Đây là tên trình điều khiển mà sysfs sử dụng.
    vận chuyển
		 - con trỏ tới phiên bản struct scsi_transport_template của trình điều khiển
                   (nếu có). Vận chuyển FC và SPI hiện được hỗ trợ.
    dữ liệu máy chủ [0]
		 - khu vực dành riêng cho LLD ở cuối cấu trúc Scsi_Host. Kích thước
                   được đặt bởi đối số thứ hai (có tên là 'privsize') thành
                   scsi_host_alloc().

Cấu trúc scsi_host được xác định trong include/scsi/scsi_host.h

cấu trúc scsi_device
------------------
Nói chung, có một phiên bản của cấu trúc này cho mỗi đơn vị logic SCSI
trên một máy chủ. Các thiết bị SCSI được kết nối với máy chủ được xác định duy nhất bởi một
số kênh, id mục tiêu và số đơn vị logic (lun).
Cấu trúc được xác định trong include/scsi/scsi_device.h

cấu trúc scsi_cmnd
----------------
Các phiên bản của cấu trúc này truyền các lệnh SCSI tới LLD và các phản hồi
trở lại mức trung bình. SCSI tầm trung sẽ đảm bảo không còn SCSI nữa
các lệnh được xếp hàng đợi đối với LLD hơn được chỉ định bởi
scsi_change_queue_deep() (hoặc struct Scsi_Host::cmd_per_lun). Sẽ có
phải có ít nhất một phiên bản struct scsi_cmnd cho mỗi thiết bị SCSI.
Thành viên quan tâm:

cmnd
		 - mảng chứa lệnh SCSI
    cmd_len
		 - độ dài (tính bằng byte) của lệnh SCSI
    sc_data_direction
		 - hướng truyền dữ liệu trong pha dữ liệu. Xem
                   "enum dma_data_direction" trong include/linux/dma-mapping.h
    kết quả
		 - nên được đặt bởi LLD trước khi gọi 'xong'. Một giá trị
                   bằng 0 ngụ ý lệnh đã hoàn thành thành công (và tất cả
                   dữ liệu (nếu có) đã được chuyển đến hoặc từ SCSI
                   thiết bị đích). 'kết quả' là số nguyên không dấu 32 bit
                   có thể được xem là 2 byte liên quan. Giá trị trạng thái SCSI là
                   trong LSB. Xem include/scsi/scsi.h status_byte() và
                   macro Host_byte() và các hằng số liên quan.
    sense_buffer
		 - một mảng (kích thước tối đa: byte SCSI_SENSE_BUFFERSIZE)
                   nên được viết khi trạng thái SCSI (LSB của 'kết quả')
                   được đặt thành CHECK_CONDITION (2). Khi CHECK_CONDITION là
                   được đặt, nếu phần trên cùng của sense_buffer[0] có giá trị 7
                   thì cấp trung sẽ đảm nhận mảng sense_buffer
                   chứa bộ đệm cảm giác SCSI hợp lệ; nếu không thì giữa
                   cấp sẽ đưa ra lệnh REQUEST_SENSE SCSI để
                   lấy lại bộ đệm cảm giác. Chiến lược sau là sai lầm
                   dễ bị ảnh hưởng bởi hàng đợi lệnh nên LLD sẽ
                   luôn luôn "tự giác".
    thiết bị
		 - con trỏ tới đối tượng scsi_device chứa lệnh này
                   liên kết với.
    resid_len (truy cập bằng cách gọi scsi_set_resid() / scsi_get_resid())
		 - LLD phải đặt số nguyên không dấu này thành số nguyên được yêu cầu
                   độ dài truyền (tức là 'request_bullen') trừ đi số lượng
                   số byte thực sự được chuyển giao. 'resid_len' là
                   được đặt trước về 0 để LLD có thể bỏ qua nếu không thể phát hiện
                   vượt mức (không nên báo cáo vượt mức). Một chiếc LLD
                   nên đặt 'resid_len' trước khi gọi 'xong'. nhất
                   trường hợp thú vị là truyền dữ liệu từ mục tiêu SCSI
                   thiết bị (ví dụ: READ) chạy kém.
    tràn xuống
		 - LLD nên đặt (DID_ERROR << 16) vào 'kết quả' nếu
                   số byte thực tế được truyền ít hơn số byte này
                   hình. Không có nhiều LLD thực hiện kiểm tra này và một số
                   chỉ xuất thông báo lỗi vào nhật ký thay vì
                   báo cáo một DID_ERROR. Tốt hơn là nên triển khai LLD
                   'cư trú_len'.

Chúng tôi khuyên LLD nên đặt 'resid_len' khi truyền dữ liệu từ SCSI
thiết bị đích (ví dụ: READ). Điều đặc biệt quan trọng là 'resid_len' được đặt
khi việc truyền dữ liệu như vậy có các khóa cảm giác MEDIUM ERROR và HARDWARE ERROR
(và có thể cả RECOVERED ERROR). Trong những trường hợp này, nếu nghi ngờ LLD thì bao nhiêu
dữ liệu đã được nhận thì cách tiếp cận an toàn nhất là chỉ ra rằng không có byte nào
đã được nhận. Ví dụ: để chỉ ra rằng không có dữ liệu hợp lệ nào được nhận
LLD có thể sử dụng những trợ giúp sau::

scsi_set_resid(SCpnt, scsi_bufflen(SCpnt));

trong đó 'SCpnt' là con trỏ tới đối tượng scsi_cmnd. Để chỉ ra ba 512
khối byte đã được nhận 'resid_len' có thể được đặt như thế này ::

scsi_set_resid(SCpnt, scsi_bufflen(SCpnt) - (3 * 512));

Cấu trúc scsi_cmnd được định nghĩa trong include/scsi/scsi_cmnd.h


Ổ khóa
=====
Mỗi phiên bản struct Scsi_Host có một spin_lock được gọi là struct
Scsi_Host::default_lock được khởi tạo trong scsi_host_alloc() [tìm thấy trong
máy chủ.c]. Trong cùng một hàm, con trỏ struct Scsi_Host::host_lock
được khởi tạo để trỏ tới default_lock.  Sau đó khóa và mở khóa
các hoạt động được thực hiện bởi cấp trung sử dụng struct Scsi_Host::host_lock
con trỏ.  Trình điều khiển trước đây có thể ghi đè con trỏ Host_lock nhưng
điều này không được phép nữa.


Tự động nhận biết
=========
Autosense (hoặc auto-sense) được định nghĩa trong tài liệu SAM-2 là "
tự động trả lại dữ liệu giác quan cho ứng dụng khách trùng khớp
khi hoàn thành lệnh SCSI" khi trạng thái CHECK CONDITION
xảy ra. LLD nên thực hiện autosense. Điều này nên được thực hiện khi LLD
phát hiện trạng thái CHECK CONDITION bằng cách:

a) hướng dẫn giao thức SCSI (ví dụ: Giao diện song song SCSI (SPI))
       để thực hiện dữ liệu bổ sung theo từng giai đoạn đối với các phản hồi như vậy
    b) hoặc LLD tự phát lệnh REQUEST SENSE

Dù bằng cách nào, khi phát hiện trạng thái CHECK CONDITION, mức trung bình
quyết định xem LLD có thực hiện autosense hay không bằng cách kiểm tra struct
scsi_cmnd::sense_buffer[0] . Nếu byte này có nibble trên là 7 (hoặc 0xf)
thì autosense được cho là đã diễn ra. Nếu nó có giá trị khác (và
byte này được khởi tạo bằng 0 trước mỗi lệnh) thì mức giữa sẽ
đưa ra lệnh REQUEST SENSE.

Với sự hiện diện của các lệnh xếp hàng, "mối liên hệ" duy trì ý nghĩa
đệm dữ liệu từ lệnh không thành công cho đến REQUEST SENSE sau
có thể bị mất đồng bộ. Đây là lý do tại sao nó là tốt nhất cho LLD
để thực hiện autosense.


Những thay đổi kể từ dòng nhân Linux 2.4
=====================================
io_request_lock đã được thay thế bằng một số khóa chi tiết hơn. cái khóa
liên quan đến LLD là struct Scsi_Host::host_lock và có
một cho mỗi máy chủ SCSI.

Cơ chế xử lý lỗi cũ hơn đã bị loại bỏ. Điều này có nghĩa là
Các chức năng giao diện LLD abort() và reset() đã bị xóa.
Cờ struct scsi_host_template::use_new_eh_code đã bị xóa.

Trong loạt 2.4, mô tả cấu hình hệ thống con SCSI là
được tổng hợp với các mô tả cấu hình từ tất cả các Linux khác
các hệ thống con trong tệp Documentation/Configure.help. Trong loạt 2.6,
hệ thống con SCSI hiện có trình điều khiển/scsi/Kconfig riêng (nhỏ hơn nhiều)
tập tin chứa cả thông tin cấu hình và trợ giúp.

struct SHT đã được đổi tên thành struct scsi_host_template.

Bổ sung "mô hình khởi tạo hotplug" và nhiều chức năng bổ sung
để hỗ trợ nó.


Tín dụng
=======
Những người sau đây đã đóng góp cho tài liệu này:

- Mike Anderson <andmike tại chúng tôi dot ibm dot com>
	- James Bottomley <James dot Bottomley tại hansenpartnership dot com>
	- Patrick Mansfield <patmans at us dot ibm dot com>
	- Christoph Hellwig <hch tại infradead dot org>
	- Doug Ledford <dledford tại redhat dot com>
	- Andries Brouwer <Andries dot Brouwer và cwi dot nl>
	- Randy Dunlap <rdunlap tại xenotime dot net>
	- Alan Stern <stern tại rowland dot harvard dot edu>


Douglas Gilbert
dgilbert tại interlog dot com

ngày 21 tháng 9 năm 2004