.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/s390/vfio-ccw.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================
vfio-ccw: cơ sở hạ tầng cơ bản
==================================

Giới thiệu
------------

Ở đây chúng tôi mô tả sự hỗ trợ vfio cho các thiết bị kênh con I/O cho
Linux/s390. Động lực của vfio-ccw là chuyển các kênh con tới một
máy ảo, trong khi vfio là phương tiện.

Khác với các kiến trúc phần cứng khác, s390 đã xác định một hệ thống thống nhất
Phương thức truy cập I/O, được gọi là I/O kênh. Nó có quyền truy cập riêng
mẫu:

- Các chương trình kênh chạy không đồng bộ trên một bộ xử lý (đồng) riêng biệt.
- Hệ thống con kênh sẽ truy cập bất kỳ bộ nhớ nào do người gọi chỉ định
  trực tiếp trong chương trình kênh, tức là không có iommu nào liên quan.

Vì vậy, khi chúng tôi giới thiệu hỗ trợ vfio cho các thiết bị này, chúng tôi nhận thấy điều đó
với việc triển khai thiết bị trung gian (mdev). vfio mdev sẽ là
được thêm vào nhóm iommu, để có thể được quản lý bởi
khung vfio. Và chúng tôi thêm các lệnh gọi lại đọc/ghi cho I/O vfio đặc biệt
các vùng để truyền các chương trình kênh từ mdev tới thiết bị mẹ của nó
(thiết bị kênh con I/O thực) để thực hiện thêm việc dịch địa chỉ và
để thực hiện các lệnh I/O.

Tài liệu này không có ý định giải thích kiến trúc I/O s390 trong
mọi chi tiết. Thông tin thêm/tài liệu tham khảo có thể được tìm thấy ở đây:

- Một khởi đầu tốt để biết Channel I/O nói chung:
  ZZ0000ZZ
- Kiến trúc s390:
  s390 Hướng dẫn nguyên tắc hoạt động (Mẫu IBM. Số SA22-7832)
- Mã QEMU hiện có thực hiện kênh mô phỏng đơn giản
  hệ thống con cũng có thể là một tài liệu tham khảo tốt. Nó làm cho việc theo dõi dễ dàng hơn
  dòng chảy.
  qemu/hw/s390x/css.c

Đối với khung thiết bị qua trung gian vfio:
- Tài liệu/driver-api/vfio-medede-device.rst

Động lực của vfio-ccw
----------------------

Thông thường, khách được ảo hóa qua QEMU/KVM trên s390 chỉ nhìn thấy
các thiết bị ảo hóa song song thông qua "Virtio Over Channel I/O
(virtio-ccw)" vận chuyển. Điều này làm cho các thiết bị virtio có thể được phát hiện thông qua
thuật toán hệ điều hành tiêu chuẩn để xử lý các thiết bị kênh.

Tuy nhiên điều này là chưa đủ. Trên s390 cho phần lớn các thiết bị,
sử dụng cơ chế dựa trên Kênh I/O tiêu chuẩn, chúng tôi cũng cần cung cấp
chức năng chuyển chúng tới máy ảo QEMU.
Điều này bao gồm các thiết bị không có bản sao virtio (ví dụ: băng
ổ đĩa) hoặc có đặc điểm cụ thể mà khách muốn
khai thác.

Để chuyển thiết bị cho khách, chúng tôi muốn sử dụng giao diện giống như
mọi người khác, cụ thể là vfio. Chúng tôi triển khai hỗ trợ vfio này cho kênh
thiết bị thông qua khung thiết bị trung gian vfio và thiết bị kênh con
trình điều khiển "vfio_ccw".

Các mẫu truy cập của thiết bị CCW
------------------------------

Kiến trúc s390 đã triển khai cái gọi là hệ thống con kênh,
cung cấp một cái nhìn thống nhất về các thiết bị được gắn vật lý vào
hệ thống. Mặc dù nền tảng phần cứng s390 biết về rất nhiều loại
các tệp đính kèm ngoại vi khác nhau như thiết bị đĩa (còn gọi là DASD), băng,
bộ điều khiển truyền thông, v.v. Tất cả chúng đều có thể được truy cập bằng giếng
phương thức truy cập được xác định và họ đang trình bày việc hoàn thành I/O một cách thống nhất
cách: gián đoạn I/O.

Tất cả I/O đều yêu cầu sử dụng các từ lệnh kênh (CCW). CCW là một
hướng dẫn tới bộ xử lý kênh I/O chuyên dụng. Một chương trình kênh là
một chuỗi các CCW được thực thi bởi hệ thống con kênh I/O.  Đến
phát một chương trình kênh tới hệ thống con của kênh thì cần phải
xây dựng khối yêu cầu hoạt động (ORB), có thể được sử dụng để chỉ ra
định dạng của CCW và thông tin điều khiển khác cho hệ thống. các
hệ điều hành báo hiệu hệ thống con kênh I/O để bắt đầu thực thi
chương trình kênh bằng lệnh SSCH (bắt đầu kênh phụ). các
bộ xử lý trung tâm sau đó được tự do thực hiện các lệnh không phải I/O
cho đến khi bị gián đoạn. Kết quả hoàn thành I/O được nhận bởi
trình xử lý ngắt ở dạng khối phản hồi ngắt (IRB).

Quay lại vfio-ccw, tóm lại:

- ORB và các chương trình kênh được xây dựng trong nhân khách (với khách
  địa chỉ vật lý).
- ORB và các chương trình kênh được chuyển tới nhân máy chủ.
- Hạt nhân máy chủ dịch địa chỉ vật lý của khách thành địa chỉ thực
  và bắt đầu I/O bằng cách đưa ra lệnh I/O kênh đặc quyền
  (ví dụ SSCH).
- các chương trình kênh chạy không đồng bộ trên một bộ xử lý riêng biệt.
- Việc hoàn thành I/O sẽ được báo hiệu tới máy chủ khi I/O bị gián đoạn.
  Và nó sẽ được sao chép dưới dạng IRB vào không gian người dùng để chuyển lại cho
  khách.

Thiết bị vfio ccw vật lý và mdev con của nó
-------------------------------------------

Như đã đề cập ở trên, chúng tôi nhận ra vfio-ccw bằng cách triển khai mdev.

Kênh I/O không có hỗ trợ phần cứng IOMMU, do đó kênh vật lý
Thiết bị vfio-ccw không có bản dịch hoặc cách ly cấp độ IOMMU.

Các lệnh I/O kênh con đều là các lệnh đặc quyền. Khi nào
xử lý việc chặn lệnh I/O, vfio-ccw có phần mềm
kiểm soát và dịch thuật chương trình kênh được lập trình như thế nào trước
nó được gửi đến phần cứng.

Trong quá trình triển khai này, chúng tôi có hai trình điều khiển cho hai loại
thiết bị:

- Trình điều khiển vfio_ccw cho thiết bị kênh con vật lý.
  Đây là trình điều khiển kênh con I/O cho thiết bị kênh con thực.  Nó
  nhận ra một nhóm các lệnh gọi lại và đăng ký vào khung mdev dưới dạng
  thiết bị gốc (vật lý). Kết quả là mdev cung cấp cho vfio_ccw một
  giao diện chung (sysfs) để tạo các thiết bị mdev. Một vfio mdev có thể là
  sau đó được tạo bởi vfio_ccw và được thêm vào bus qua trung gian. Đó là vfio
  thiết bị đã thêm vào nhóm IOMMU và nhóm vfio.
  vfio_ccw cũng cung cấp vùng I/O để chấp nhận chương trình kênh
  yêu cầu từ không gian người dùng và lưu trữ kết quả ngắt I/O cho người dùng
  không gian để lấy lại. Để thông báo cho không gian người dùng về việc hoàn thành I/O, nó cung cấp
  một giao diện để thiết lập một fd sự kiện cho tín hiệu không đồng bộ.

- Driver vfio_mdev cho thiết bị vfio ccw qua trung gian.
  Điều này được cung cấp bởi khung mdev. Nó là trình điều khiển thiết bị vfio cho
  mdev được tạo bởi vfio_ccw.
  Nó nhận ra một nhóm các lệnh gọi lại trình điều khiển thiết bị vfio, tự thêm vào một
  nhóm vfio và tự đăng ký vào khung mdev dưới dạng mdev
  người lái xe.
  Nó sử dụng phần phụ trợ vfio iommu sử dụng bản đồ hiện có và hủy bản đồ
  ioctls, mà thay vì lập trình chúng thành IOMMU cho một thiết bị,
  nó chỉ lưu trữ các bản dịch để sử dụng cho các yêu cầu sau này. Cái này
  có nghĩa là một thiết bị được lập trình trong VM có địa chỉ vật lý của khách
  có thể yêu cầu hạt nhân vfio chuyển đổi địa chỉ đó để xử lý ảo
  địa chỉ, ghim trang và lập trình phần cứng với máy chủ vật lý
  địa chỉ trong một bước.
  Đối với mdev, phần phụ trợ vfio iommu sẽ không ghim các trang trong quá trình
  VFIO_IOMMU_MAP_DMA ioctl. Khung Mdev sẽ chỉ duy trì cơ sở dữ liệu
  của ánh xạ iova<->vaddr trong thao tác này. Và họ xuất khẩu một
  Giao diện vfio_pin_pages và vfio_unpin_pages từ vfio iommu
  phụ trợ để các thiết bị vật lý ghim và bỏ ghim các trang theo yêu cầu.

Dưới đây là sơ đồ khối cấp cao::

+-------------+
 ZZ0000ZZ
 ZZ0001ZZ mdev_register_driver() +--------------+
 ZZ0002ZZ Mdev ZZ0003ZZ
 Xe buýt ZZ0004ZZ ZZ0005ZZ ZZ0006ZZ
 Trình điều khiển ZZ0007ZZ ZZ0008ZZ<-> Người dùng VFIO
 ZZ0009ZZ thăm dò()/remove() +--------------+ API
 ZZ0010ZZ
 ZZ0011ZZ
 ZZ0012ZZ
 ZZ0013ZZ
 ZZ0014ZZ mdev_register_parent() +--------------+
 | |Vật lý ZZ0016ZZ
 Thiết bị ZZ0017ZZ ZZ0018ZZ ZZ0019ZZ<-> kênh phụ
 Thiết bị | |interface| +----------------------->+              |
 Gọi lại ZZ0022ZZ +--------------+
 +-------------+

Quá trình làm thế nào những điều này làm việc cùng nhau.

1. vfio_ccw.ko điều khiển kênh con I/O vật lý và đăng ký
   thiết bị vật lý (có lệnh gọi lại) vào khung mdev.
   Khi vfio_ccw thăm dò thiết bị kênh con, nó sẽ đăng ký thiết bị
   con trỏ và lệnh gọi lại tới khung mdev. Các nút tập tin liên quan đến Mdev
   bên dưới nút thiết bị trong sysfs sẽ được tạo cho kênh con
   thiết bị, cụ thể là 'mdev_create', 'mdev_destroy' và
   'mdev_supported_types'.
2. Tạo một thiết bị vfio ccw qua trung gian.
   Sử dụng tệp sysfs 'mdev_create', chúng ta cần tạo một tệp (và
   chỉ có một cho trường hợp của chúng tôi) thiết bị qua trung gian.
3. vfio_mdev.ko điều khiển thiết bị ccw qua trung gian.
   vfio_mdev cũng là trình điều khiển thiết bị vfio. Nó sẽ thăm dò mdev và
   thêm nó vào iommu_group và vfio_group. Sau đó chúng ta có thể đi qua
   mdev cho khách.


Vùng VFIO-CCW
----------------

Trình điều khiển vfio-ccw hiển thị các vùng MMIO để chấp nhận yêu cầu từ và trả lại
kết quả vào không gian người dùng.

Vùng I/O vfio-ccw
-------------------

Vùng I/O được sử dụng để chấp nhận yêu cầu chương trình kênh từ người dùng
không gian và lưu trữ kết quả ngắt I/O để người dùng truy xuất không gian. các
định nghĩa của khu vực là::

cấu trúc ccw_io_khu vực {
  #define ORB_AREA_SIZE 12
	  __u8 orb_area[ORB_AREA_SIZE];
  #define SCSW_AREA_SIZE 12
	  __u8 scsw_area[SCSW_AREA_SIZE];
  #define IRB_AREA_SIZE 96
	  __u8 irb_area[IRB_AREA_SIZE];
	  __u32 ret_code;
  } __đóng gói;

Khu vực này luôn có sẵn.

Trong khi bắt đầu một yêu cầu I/O, orb_area phải được điền bằng
khách ORB và scsw_area phải được điền bằng SCSW của Virtual
Kênh phụ.

irb_area lưu trữ kết quả I/O.

ret_code lưu trữ mã trả về cho mỗi lần truy cập vào khu vực. Sau đây
giá trị có thể xảy ra:

ZZ0000ZZ
  Ca phẫu thuật đã thành công.

ZZ0000ZZ
  Chế độ vận chuyển được chỉ định ORB hoặc
  SCSW đã chỉ định một chức năng khác với chức năng bắt đầu.

ZZ0000ZZ
  Một yêu cầu được đưa ra trong khi thiết bị chưa ở trạng thái sẵn sàng chấp nhận
  yêu cầu hoặc xảy ra lỗi nội bộ.

ZZ0000ZZ
  Kênh con ở trạng thái đang chờ xử lý hoặc bận hoặc một yêu cầu đã hoạt động.

ZZ0000ZZ
  Một yêu cầu đang được xử lý và người gọi nên thử lại.

ZZ0000ZZ
  (Các) đường dẫn kênh được sử dụng cho I/O được phát hiện là không hoạt động.

ZZ0000ZZ
  Thiết bị được phát hiện là không hoạt động.

ZZ0000ZZ
  Quả cầu đã chỉ định một chuỗi dài hơn 255 ccw hoặc có lỗi nội bộ
  đã xảy ra.


vùng cmd vfio-ccw
-------------------

Vùng cmd vfio-ccw được sử dụng để chấp nhận các hướng dẫn không đồng bộ
từ không gian người dùng::

#define VFIO_CCW_ASYNC_CMD_HSCH (1 << 0)
  #define VFIO_CCW_ASYNC_CMD_CSCH (1 << 1)
  cấu trúc ccw_cmd_khu vực {
         Lệnh __u32;
         __u32 ret_code;
  } __đóng gói;

Vùng này được hiển thị thông qua loại vùng VFIO_REGION_SUBTYPE_CCW_ASYNC_CMD.

Hiện tại, CLEAR SUBCHANNEL và HALT SUBCHANNEL sử dụng vùng này.

lệnh chỉ định lệnh sẽ được ban hành; ret_code lưu mã trả lại
cho mỗi truy cập của khu vực. Các giá trị sau có thể xảy ra:

ZZ0000ZZ
  Ca phẫu thuật đã thành công.

ZZ0000ZZ
  Thiết bị được phát hiện là không hoạt động.

ZZ0000ZZ
  Một lệnh khác với lệnh tạm dừng hoặc xóa đã được chỉ định.

ZZ0000ZZ
  Một yêu cầu được đưa ra trong khi thiết bị chưa ở trạng thái sẵn sàng chấp nhận
  yêu cầu.

ZZ0000ZZ
  Một yêu cầu đang được xử lý và người gọi nên thử lại.

ZZ0000ZZ
  Kênh con ở trạng thái chờ xử lý hoặc bận trong khi xử lý yêu cầu tạm dừng.

vùng schib vfio-ccw
---------------------

Vùng schib vfio-ccw được sử dụng để trả về Thông tin kênh con
Chặn dữ liệu (SCHIB) vào không gian người dùng::

cấu trúc ccw_schib_khu vực {
  #define SCHIB_AREA_SIZE 52
         __u8 schib_area[SCHIB_AREA_SIZE];
  } __đóng gói;

Vùng này được hiển thị thông qua loại vùng VFIO_REGION_SUBTYPE_CCW_SCHIB.

Việc đọc vùng này sẽ kích hoạt STORE SUBCHANNEL được cấp cho
phần cứng liên quan.

vùng vfio-ccw crw
---------------------

Vùng vfio-ccw crw được sử dụng để trả về Channel Report Word (CRW)
dữ liệu vào không gian người dùng::

cấu trúc ccw_crw_khu vực {
         __u32 crw;
         __u32 đệm;
  } __đóng gói;

Vùng này được hiển thị thông qua loại vùng VFIO_REGION_SUBTYPE_CCW_CRW.

Đọc vùng này sẽ trả về CRW nếu vùng đó phù hợp với điều này
kênh con (ví dụ: một báo cáo thay đổi về trạng thái đường dẫn kênh) là
đang chờ xử lý hoặc tất cả các số 0 nếu không. Nếu nhiều CRW đang chờ xử lý (bao gồm cả
có thể là các CRW bị xâu chuỗi), việc đọc lại vùng này sẽ trả về vùng tiếp theo
một, cho đến khi không còn CRW nào đang chờ xử lý và số 0 được trả về. Đây là
tương tự như cách hoạt động của STORE CHANNEL REPORT WORD.

chi tiết hoạt động vfio-ccw
--------------------------

vfio-ccw tuân theo những gì vfio-pci đã làm trên nền tảng s390 và sử dụng
vfio-iommu-type1 làm phụ trợ vfio iommu.

* API dịch thuật CCW
  Một nhóm API (bắt đầu bằng ZZ0000ZZ) để thực hiện dịch CCW. các CCW
  được truyền vào bởi một chương trình không gian người dùng được tổ chức với khách của họ
  địa chỉ bộ nhớ vật lý. Các API này sẽ sao chép CCW vào kernel
  không gian và tập hợp chương trình kênh hạt nhân có thể chạy được bằng cách cập nhật
  địa chỉ vật lý của khách với địa chỉ vật lý của máy chủ tương ứng.
  Lưu ý rằng chúng tôi phải sử dụng IDAL ngay cả đối với CCW truy cập trực tiếp, vì
  bộ nhớ tham chiếu có thể được đặt ở bất cứ đâu, kể cả trên 2G.

* Trình điều khiển thiết bị vfio_ccw
  Trình điều khiển này sử dụng API dịch CCW và giới thiệu
  vfio_ccw, là trình điều khiển cho các thiết bị kênh con I/O mà bạn muốn
  để đi qua.
  vfio_ccw triển khai vfio ioctls sau::

VFIO_DEVICE_GET_INFO
    VFIO_DEVICE_GET_IRQ_INFO
    VFIO_DEVICE_GET_REGION_INFO
    VFIO_DEVICE_RESET
    VFIO_DEVICE_SET_IRQS

Điều này cung cấp một vùng I/O để chương trình không gian người dùng có thể vượt qua một
  chương trình kênh vào kernel, để thực hiện thêm bản dịch CCW trước
  cấp chúng cho một thiết bị thực sự.
  Điều này cũng cung cấp SET_IRQ ioctl để thiết lập trình thông báo sự kiện cho
  thông báo cho chương trình không gian người dùng việc hoàn thành I/O ở chế độ không đồng bộ
  cách.

Việc sử dụng vfio-ccw không chỉ giới hạn ở QEMU, trong khi QEMU chắc chắn là một
ví dụ điển hình để hiểu cách hoạt động của các bản vá này. Đây là một chút
chi tiết hơn một chút về cách yêu cầu I/O được kích hoạt bởi khách QEMU sẽ như thế nào
được xử lý (không xử lý lỗi).

Giải thích:

- Q1-Q7: Quá trình phụ QEMU.
- K1-K5: Tiến trình bên kernel.

Q1.
    Nhận thông tin vùng I/O trong quá trình khởi tạo.

Q2.
    Thiết lập trình thông báo và xử lý sự kiện để xử lý việc hoàn thành I/O.

... ...

Q3.
    Chặn lệnh ssch.
Q4.
    Ghi chương trình kênh khách và ORB vào vùng I/O.

K1.
	Sao chép từ khách sang kernel.
    K2.
	Dịch chương trình kênh khách sang không gian kernel máy chủ
	chương trình kênh, chương trình này có thể chạy được trên thiết bị thực.
    K3.
	Với những thông tin cần thiết có trong quả cầu được chuyển vào
	bởi QEMU, cấp ccwchain cho thiết bị.
    K4.
	Trả về mã ssch CC.
Q5.
    Trả lại mã CC cho khách.

... ...

    K5.
	Interrupt handler gets the I/O result and write the result to
	the I/O region.
    K6.
	Signal QEMU to retrieve the result.

Q6.
    Nhận tín hiệu và trình xử lý sự kiện đọc kết quả từ I/O
    khu vực.
Q7.
    Cập nhật irb cho khách.

Hạn chế
-----------

Việc triển khai vfio-ccw hiện tại tập trung vào việc hỗ trợ các lệnh cơ bản
cần thiết để triển khai chức năng thiết bị khối (đọc/ghi) của DASD/ECKD
chỉ thiết bị. Một số lệnh có thể cần xử lý đặc biệt trong tương lai, vì
ví dụ, bất cứ điều gì liên quan đến nhóm đường dẫn.

DASD là một loại thiết bị lưu trữ. Trong khi ECKD là định dạng ghi dữ liệu.
Bạn có thể tìm thêm thông tin về DASD và ECKD tại đây:
ZZ0000ZZ
ZZ0001ZZ

Cùng với công việc tương ứng trong QEMU, chúng tôi có thể mang lại kết quả đã qua
thông qua thiết bị DASD/ECKD trực tuyến với tư cách khách ngay bây giờ và sử dụng nó như một khối
thiết bị.

Mã hiện tại cho phép khách bắt đầu các chương trình kênh thông qua
START SUBCHANNEL, và phát hành HALT SUBCHANNEL, CLEAR SUBCHANNEL,
và STORE SUBCHANNEL.

Hiện tại tất cả các chương trình kênh đều được tìm nạp trước, bất kể
cài đặt p-bit trong ORB.  Kết quả là kênh tự sửa đổi
các chương trình không được hỗ trợ.  Vì lý do này, IPL phải được xử lý như
một trường hợp đặc biệt bởi một chương trình không gian người dùng/khách; điều này đã được thực hiện
trong bios s390-ccw của QEMU kể từ QEMU 4.1.

vfio-ccw chỉ hỗ trợ I/O kênh cổ điển (chế độ lệnh). Vận chuyển
chế độ (HPF) không được hỗ trợ.

Các kênh con QDIO hiện không được hỗ trợ. Các thiết bị cổ điển khác ngoài
DASD/ECKD có thể hoạt động nhưng chưa được thử nghiệm.

Thẩm quyền giải quyết
---------
1. Hướng dẫn sử dụng nguyên tắc hoạt động của ESA/s390 (Mẫu IBM. Số SA22-7832)
2. Hướng dẫn sử dụng lệnh thiết bị I/O chung ESA/390 (Mẫu IBM. Số SA22-7204)
3. ZZ0000ZZ
4. Tài liệu/arch/s390/cds.rst
5. Tài liệu/driver-api/vfio.rst
6. Tài liệu/driver-api/vfio-medede-device.rst
