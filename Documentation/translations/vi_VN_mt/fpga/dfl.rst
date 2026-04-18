.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fpga/dfl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================================================
Tổng quan về khung danh sách tính năng thiết bị FPGA (DFL)
=================================================

tác giả:

- Enno Luebbers <enno.luebbers@intel.com>
- Tiểu Quảng Dung <guangrong.xiao@linux.intel.com>
- Ngô Hạo <hao.wu@intel.com>
- Xu Yilun <yilun.xu@intel.com>

Danh sách tính năng thiết bị (DFL) Khung FPGA (và trình điều khiển theo
khung này) ẩn các chi tiết của phần cứng lớp thấp và cung cấp
giao diện thống nhất cho không gian người dùng. Các ứng dụng có thể sử dụng các giao diện này để
định cấu hình, liệt kê, mở và truy cập bộ tăng tốc FPGA trên các nền tảng
triển khai DFL trong bộ nhớ thiết bị. Bên cạnh đó, khung DFL
cho phép các chức năng quản lý cấp hệ thống như cấu hình lại FPGA.


Tổng quan về danh sách tính năng thiết bị (DFL)
==================================
Danh sách tính năng thiết bị (DFL) xác định danh sách liên kết các tiêu đề tính năng trong
thiết bị MMIO không gian để cung cấp một cách mở rộng thêm các tính năng. Phần mềm có thể
xem qua các cấu trúc dữ liệu được xác định trước này để liệt kê các tính năng của FPGA:
Đơn vị giao diện FPGA (FIU), Đơn vị chức năng tăng tốc (AFU) và các tính năng riêng tư,
như minh họa dưới đây::

Tiêu đề Tiêu đề Tiêu đề Tiêu đề
 +----------+ +-->+----------+ +-->+----------+ +-->+----------+
 ZZ0000ZZ ZZ0001ZZ Loại ZZ0002ZZ ZZ0003ZZ ZZ0004ZZ Loại |
 ZZ0005ZZ ZZ0006ZZ Riêng tư ZZ0007ZZ ZZ0008ZZ ZZ0009ZZ Riêng tư |
 +----------+ Tính năng ZZ0010ZZ ZZ0011ZZ ZZ0012ZZ ZZ0013ZZ Tính năng |
 ZZ0014ZZ--+ +----------+ ZZ0015ZZ +----------+
 +----------+ ZZ0016ZZ--+ ZZ0017ZZ--+ ZZ0018ZZ---> NULL
 ZZ0019ZZ +----------+ +----------+ +----------+
 +----------+ ZZ0020ZZ ZZ0021ZZ ZZ0022ZZ
 ZZ0023ZZ--+ +----------+ +----------+ +----------+
 +----------+ Tính năng ZZ0024ZZ Tính năng ZZ0025ZZ Tính năng ZZ0026ZZ |
 ZZ0027ZZ ZZ0028ZZ Đăng ký ZZ0029ZZ Đăng ký ZZ0030ZZ Đăng ký |
 Bộ ZZ0031ZZ ZZ0032ZZ Bộ ZZ0033ZZ Bộ ZZ0034ZZ |
 ZZ0035ZZ |   +----------+ +----------+ +----------+
 +----------+ |      tiêu đề
               +-->+----------+
                   ZZ0036ZZ
                   ZZ0037ZZ
                   +----------+
                   ZZ0038ZZ->NULL
                   +----------+
                   ZZ0039ZZ
                   +----------+
                   ZZ0040ZZ
                   ZZ0041ZZ
                   ZZ0042ZZ
                   +----------+

Đơn vị giao diện FPGA (FIU) đại diện cho một đơn vị chức năng độc lập cho
giao diện với FPGA, ví dụ: Công cụ quản lý FPGA (FME) và Cổng (thêm
mô tả về FME và Cổng ở các phần sau).

Đơn vị chức năng tăng tốc (AFU) đại diện cho vùng lập trình FPGA và
luôn kết nối với FIU (ví dụ: Cổng) với tư cách là con của nó như minh họa ở trên.

Tính năng riêng đại diện cho các tính năng phụ của FIU và AFU. Họ có thể là
các khối chức năng khác nhau với các ID khác nhau, nhưng tất cả các tính năng riêng tư đều
thuộc cùng một FIU hoặc AFU, phải được liên kết với một danh sách thông qua Thiết bị tiếp theo
Con trỏ Tiêu đề Tính năng (Next_DFH).

Mỗi FIU, AFU và Tính năng riêng tư có thể triển khai các thanh ghi chức năng riêng.
Bộ thanh ghi chức năng cho FIU và AFU, được đặt tên là Bộ thanh ghi tiêu đề,
ví dụ: Bộ đăng ký tiêu đề FME và bộ đăng ký dành cho tính năng riêng tư, được đặt tên là
Bộ đăng ký tính năng, ví dụ: Bộ thanh ghi tính năng cấu hình lại một phần FME.

Danh sách tính năng thiết bị này cung cấp cách liên kết các tính năng với nhau, đó là
thuận tiện cho phần mềm định vị từng tính năng bằng cách duyệt qua danh sách này,
và có thể được triển khai trong vùng đăng ký của bất kỳ thiết bị FPGA nào.


Tiêu đề tính năng thiết bị - Phiên bản 0
=================================
Phiên bản 0 (DFHv0) là phiên bản gốc của Tiêu đề tính năng thiết bị.
Tất cả số lượng nhiều byte trong DFHv0 đều là endian nhỏ.
Định dạng của DFHv0 được hiển thị bên dưới::

+--------------------------------------------------------------------------------------- +
    ZZ0000ZZ59 DFH VER 52|51 Rsvd 41|40 EOLZZ0002ZZ15 REV 12|11 ID 0| 0x00
    +--------------------------------------------------------------------------------------- +
    ZZ0004ZZ 0x08
    +--------------------------------------------------------------------------------------- +
    ZZ0005ZZ 0x10
    +--------------------------------------------------------------------------------------- +

- Bù đắp 0x00

* Loại - Loại DFH (ví dụ: FME, AFU hoặc tính năng riêng tư).
  * DFH VER - Phiên bản của DFH.
  * Rsvd - Hiện chưa sử dụng.
  * EOL - Đặt nếu DFH là phần cuối của Danh sách tính năng thiết bị (DFL).
  * Tiếp theo - Phần bù tính bằng byte của DFH tiếp theo trong DFL từ đầu DFH,
    và điểm bắt đầu của DFH phải được căn chỉnh theo ranh giới 8 byte.
    Nếu EOL được đặt, Tiếp theo là kích thước MMIO của tính năng cuối cùng trong danh sách.
  * REV - Bản sửa đổi tính năng được liên kết với tiêu đề này.
  * ID - ID tính năng nếu Loại là tính năng riêng tư.

- Bù đắp 0x08

* GUID_L - 64 bit ít quan trọng nhất của Mã định danh duy nhất toàn cầu 128 bit
    (chỉ hiện diện nếu Loại là FME hoặc AFU).

- Bù đắp 0x10

* GUID_H - 64 bit quan trọng nhất của Mã định danh duy nhất toàn cầu 128 bit
    (chỉ hiện diện nếu Loại là FME hoặc AFU).


Tiêu đề tính năng thiết bị - Phiên bản 1
=================================
Phiên bản 1 (DFHv1) của Tiêu đề tính năng thiết bị bổ sung thêm chức năng sau:

* Cung cấp một cơ chế chuẩn hóa cho các đặc điểm để mô tả
  các thông số/khả năng của phần mềm.
* Tiêu chuẩn hóa việc sử dụng GUID cho tất cả các loại DFHv1.
* Tách vị trí DFH khỏi không gian đăng ký của chính tính năng đó.

Tất cả số lượng nhiều byte trong DFHv1 đều là endian nhỏ.
Định dạng của Phiên bản 1 của Tiêu đề tính năng thiết bị (DFH) được hiển thị bên dưới::

+--------------------------------------------------------------------------------------- +
    ZZ0000ZZ59 DFH VER 52|51 Rsvd 41|40 EOLZZ0002ZZ15 REV 12|11 ID 0| 0x00
    +--------------------------------------------------------------------------------------- +
    ZZ0004ZZ 0x08
    +--------------------------------------------------------------------------------------- +
    ZZ0005ZZ 0x10
    +--------------------------------------------------------------------------------------- +
    ZZ0006ZZ Rel 0| 0x18
    +--------------------------------------------------------------------------------------- +
    |63        Reg Size       32|Params 31|30 Group    16|15 Phiên bản 0| 0x20
    +--------------------------------------------------------------------------------------- +
    Phiên bản thông số ZZ0009ZZ34RSV33ZZ0010ZZ31 16|15 Param ID           0| 0x28
    +--------------------------------------------------------------------------------------- +
    ZZ0012ZZ 0x30
    +--------------------------------------------------------------------------------------- +

                                  ...

+--------------------------------------------------------------------------------------- +
    Phiên bản thông số ZZ0000ZZ34RSV33ZZ0001ZZ31 16|15 Param ID           0|
    +--------------------------------------------------------------------------------------- +
    ZZ0003ZZ
    +--------------------------------------------------------------------------------------- +

- Bù đắp 0x00

* Loại - Loại DFH (ví dụ: FME, AFU hoặc tính năng riêng tư).
  * DFH VER - Phiên bản của DFH.
  * Rsvd - Hiện chưa sử dụng.
  * EOL - Đặt nếu DFH là phần cuối của Danh sách tính năng thiết bị (DFL).
  * Tiếp theo - Phần bù tính bằng byte của DFH tiếp theo trong DFL từ đầu DFH,
    và điểm bắt đầu của DFH phải được căn chỉnh theo ranh giới 8 byte.
    Nếu EOL được đặt, Tiếp theo là kích thước MMIO của tính năng cuối cùng trong danh sách.
  * REV - Bản sửa đổi tính năng được liên kết với tiêu đề này.
  * ID - ID tính năng nếu Loại là tính năng riêng tư.

- Bù đắp 0x08

* GUID_L - 64 bit ít quan trọng nhất của Mã định danh duy nhất toàn cầu 128 bit.

- Bù đắp 0x10

* GUID_H - 64 bit quan trọng nhất của Mã định danh duy nhất toàn cầu 128 bit.

- Bù đắp 0x18

* Địa chỉ Reg/Offset - Nếu bit Rel được đặt thì giá trị là 63 bit cao
    địa chỉ tuyệt đối được căn chỉnh 16 bit của các thanh ghi đối tượng. Nếu không
    giá trị là phần bù từ đầu DFH trong các thanh ghi của đối tượng địa lý.

- Bù đắp 0x20

* Kích thước Reg - Kích thước thanh ghi của tính năng được đặt theo byte.
  * Thông số - Đặt nếu DFH có danh sách các khối tham số.
  * Nhóm - Id của nhóm nếu đối tượng là một phần của nhóm.
  * Instance - Id của instance tính năng trong một nhóm.

- Offset 0x28 nếu đối tượng có tham số

* Tiếp theo - Bù sang khối tham số tiếp theo bằng các từ 8 byte. Nếu EOP được đặt,
    kích thước bằng 8 byte từ của tham số cuối cùng.
  * Phiên bản Param - Phiên bản của ID Param.
  * Param ID - ID của tham số.

- Bù đắp 0x30

* Dữ liệu tham số - Dữ liệu tham số có kích thước và định dạng được xác định bởi
    phiên bản và ID của tham số.


FIU - FME (Công cụ quản lý FPGA)
==================================
Công cụ quản lý FPGA thực hiện cấu hình lại và cơ sở hạ tầng khác
chức năng. Mỗi thiết bị FPGA chỉ có một FME.

Các ứng dụng trong không gian người dùng có thể có quyền truy cập độc quyền vào FME bằng cách sử dụng open(),
và giải phóng nó bằng cách sử dụng close().

Các chức năng sau được hiển thị thông qua ioctls:

- Nhận driver phiên bản API (DFL_FPGA_GET_API_VERSION)
- Kiểm tra tiện ích mở rộng (DFL_FPGA_CHECK_EXTENSION)
- Dòng bit chương trình (DFL_FPGA_FME_PORT_PR)
- Gán cổng cho PF (DFL_FPGA_FME_PORT_ASSIGN)
- Nhả cổng từ PF (DFL_FPGA_FME_PORT_RELEASE)
- Lấy số irqs của lỗi toàn cục FME (DFL_FPGA_FME_ERR_GET_IRQ_NUM)
- Đặt kích hoạt ngắt cho lỗi FME (DFL_FPGA_FME_ERR_SET_IRQ)

Nhiều chức năng hơn được hiển thị thông qua sysfs
(/sys/class/fpga_khu vực/khu vựcX/dfl-fme.n/):

Đọc ID dòng bit (bitstream_id)
     bitstream_id cho biết phiên bản của vùng FPGA tĩnh.

Đọc siêu dữ liệu dòng bit (bitstream_metadata)
     bitstream_metadata bao gồm thông tin chi tiết về vùng FPGA tĩnh,
     ví dụ: ngày tổng hợp và hạt giống.

Đọc số cổng (ports_num)
     một thiết bị FPGA có thể có nhiều cổng, giao diện sysfs này cho biết
     thiết bị FPGA có bao nhiêu cổng.

Quản lý báo cáo lỗi toàn cầu (errors/)
     Giao diện sysfs báo cáo lỗi cho phép người dùng đọc các lỗi được phát hiện bởi
     phần cứng và xóa các lỗi đã ghi.

Quản lý năng lượng (dfl_fme_power hwmon)
     quản lý năng lượng Giao diện hwmon sysfs cho phép người dùng đọc quản lý năng lượng
     thông tin (mức tiêu thụ điện năng, ngưỡng, trạng thái ngưỡng, giới hạn, v.v.)
     và định cấu hình ngưỡng công suất cho các mức điều chỉnh khác nhau.

Quản lý nhiệt (dfl_fme_thermal hwmon)
     Giao diện hwmon sysfs quản lý nhiệt cho phép người dùng đọc nhiệt
     thông tin quản lý (nhiệt độ hiện tại, ngưỡng, trạng thái ngưỡng,
     v.v.).

Báo cáo hiệu suất
     bộ đếm hiệu suất được hiển thị thông qua API PMU hoàn hảo. Công cụ hoàn thiện tiêu chuẩn
     có thể được sử dụng để theo dõi tất cả các sự kiện hoàn hảo có sẵn. Vui lòng xem hiệu suất
     phần truy cập bên dưới để biết thêm thông tin chi tiết.


FIU - PORT
==========
Một cổng đại diện cho giao diện giữa kết cấu FPGA tĩnh và một phần
vùng có thể cấu hình lại chứa AFU. Nó điều khiển việc truyền thông từ SW
tới bộ tăng tốc và hiển thị các tính năng như đặt lại và gỡ lỗi. Mỗi FPGA
thiết bị có thể có nhiều cổng nhưng luôn có một AFU trên mỗi cổng.


AFU
===
Một AFU được gắn vào cổng FIU và hiển thị một vùng MMIO có độ dài cố định.
được sử dụng cho các thanh ghi điều khiển dành riêng cho máy gia tốc.

Các ứng dụng trong không gian người dùng có thể có quyền truy cập độc quyền vào AFU được gắn vào
port bằng cách sử dụng open() trên nút thiết bị cổng và giải phóng nó bằng close().

Các chức năng sau được hiển thị thông qua ioctls:

- Nhận driver phiên bản API (DFL_FPGA_GET_API_VERSION)
- Kiểm tra tiện ích mở rộng (DFL_FPGA_CHECK_EXTENSION)
- Nhận thông tin cổng (DFL_FPGA_PORT_GET_INFO)
- Nhận thông tin khu vực MMIO (DFL_FPGA_PORT_GET_REGION_INFO)
- Bản đồ bộ đệm DMA (DFL_FPGA_PORT_DMA_MAP)
- Unmap bộ đệm DMA (DFL_FPGA_PORT_DMA_UNMAP)
- Đặt lại AFU (DFL_FPGA_PORT_RESET)
- Nhận số lỗi cổng irqs (DFL_FPGA_PORT_ERR_GET_IRQ_NUM)
- Đặt kích hoạt ngắt cho lỗi cổng (DFL_FPGA_PORT_ERR_SET_IRQ)
- Lấy số irq của UINT (DFL_FPGA_PORT_UINT_GET_IRQ_NUM)
- Đặt trigger ngắt cho UINT (DFL_FPGA_PORT_UINT_SET_IRQ)

DFL_FPGA_PORT_RESET:
  đặt lại Cổng FPGA và AFU của nó. Không gian người dùng có thể làm Cổng
  đặt lại bất kỳ lúc nào, ví dụ: trong DMA hoặc Cấu hình lại một phần. Nhưng nó nên
  không bao giờ gây ra bất kỳ sự cố nào ở cấp độ hệ thống, chỉ gây ra lỗi chức năng (ví dụ: DMA hoặc PR
  lỗi vận hành) và có thể phục hồi được sau lỗi.

Các ứng dụng trong không gian người dùng cũng có thể sử dụng các vùng MMIO của bộ tăng tốc mmap().

Nhiều chức năng hơn được hiển thị thông qua sysfs:
(/sys/class/fpga_khu vực/<khu vựcX>/<dfl-port.m>/):

Đọc máy gia tốc GUID (afu_id)
     afu_id cho biết dòng bit PR nào được lập trình cho AFU này.

Báo cáo lỗi (lỗi/)
     Giao diện sysfs báo cáo lỗi cho phép người dùng đọc lỗi cổng/afu
     được phần cứng phát hiện và xóa các lỗi đã ghi.


Tổng quan về khung DFL
======================

::

+----------+ +--------+ +--------+ +--------+
         ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ
         ZZ0004ZZ ZZ0005ZZ ZZ0006ZZ ZZ0007ZZ
         +----------+ +--------+ +--------+ +--------+
                 +--------------+
                 Danh sách tính năng thiết bị ZZ0008ZZ
                 Khung ZZ0009ZZ
                 +--------------+
  ------------------------------------------------------------------
               +-----------------------------+
               ZZ0010ZZ
               ZZ0011ZZ
               +-----------------------------+
                 +---------------+
                 ZZ0012ZZ
                 +---------------+

DFL framework trong kernel cung cấp các giao diện chung để tạo thiết bị container
(Vùng cơ sở FPGA), khám phá các thiết bị tính năng và các tính năng riêng tư của chúng từ
đưa ra Danh sách tính năng thiết bị và tạo các thiết bị nền tảng cho các thiết bị tính năng
(ví dụ: FME, Port và AFU) với các tài nguyên liên quan trong thiết bị chứa. Nó
cũng trừu tượng hóa các hoạt động cho các tính năng riêng tư và hiển thị các hoạt động chung cho
trình điều khiển thiết bị tính năng.

Thiết bị FPGA DFL có thể là phần cứng khác, ví dụ: Thiết bị, nền tảng PCIe
thiết bị, v.v. Mô-đun trình điều khiển của nó luôn được tải đầu tiên sau khi thiết bị được khởi động
do hệ thống tạo ra. Trình điều khiển này đóng một vai trò cơ sở hạ tầng trong
kiến trúc trình điều khiển. Nó định vị các DFL trong bộ nhớ thiết bị, xử lý chúng
và các tài nguyên liên quan đến các giao diện chung từ khung liệt kê DFL.
(Vui lòng tham khảo driver/fpga/dfl.c để biết các API liệt kê chi tiết).

Trình điều khiển Công cụ quản lý FPGA (FME) là trình điều khiển nền tảng được tải
tự động sau khi tạo thiết bị nền tảng FME từ mô-đun thiết bị DFL. Nó
cung cấp các tính năng chính để quản lý FPGA, bao gồm:

a) Hiển thị thông tin vùng FPGA tĩnh, ví dụ: phiên bản và siêu dữ liệu.
	   Người dùng có thể đọc thông tin liên quan thông qua giao diện sysfs được hiển thị
	   bởi trình điều khiển FME.

b) Cấu hình lại một phần. Trình điều khiển FME tạo trình quản lý FPGA, FPGA
	   cầu nối và vùng FPGA trong quá trình khởi tạo tính năng phụ PR. Một lần
	   nó nhận được ioctl DFL_FPGA_FME_PORT_PR từ người dùng, nó gọi
	   chức năng giao diện chung từ Vùng FPGA để hoàn thành một phần
	   cấu hình lại dòng bit PR tới cổng đã cho.

Tương tự như trình điều khiển FME, trình điều khiển Bộ chức năng tăng tốc FPGA (AFU) là
được thăm dò sau khi thiết bị nền tảng AFU được tạo. Chức năng chính của mô-đun này
là cung cấp một giao diện cho các ứng dụng không gian người dùng để truy cập vào từng cá nhân
bộ tăng tốc, bao gồm điều khiển thiết lập lại cơ bản trên cổng, xuất vùng AFU MMIO, dma
chức năng dịch vụ ánh xạ bộ đệm.

Sau khi tạo các thiết bị nền tảng tính năng, trình điều khiển nền tảng phù hợp sẽ được tải
tự động xử lý các chức năng khác nhau. Vui lòng tham khảo các phần tiếp theo
để biết thông tin chi tiết về các đơn vị chức năng đã được triển khai
trong khuôn khổ DFL này.


Cấu hình lại một phần
=======================
Như đã đề cập ở trên, máy gia tốc có thể được cấu hình lại thông qua một phần
cấu hình lại tập tin dòng bit PR. Tệp dòng bit PR phải được
được tạo cho vùng FPGA tĩnh chính xác và vùng có thể cấu hình lại được nhắm mục tiêu
(cổng) của FPGA, nếu không, thao tác cấu hình lại sẽ thất bại và
có thể gây mất ổn định hệ thống. Khả năng tương thích này có thể được kiểm tra bằng
so sánh ID tương thích được ghi trong tiêu đề của tệp dòng bit PR với
compat_id được hiển thị bởi vùng FPGA mục tiêu. Việc kiểm tra này thường được thực hiện bởi
không gian người dùng trước khi gọi cấu hình lại IOCTL.


Ảo hóa FPGA - PCIe SRIOV
================================
Phần này mô tả hỗ trợ ảo hóa trên thiết bị FPGA dựa trên DFL để
cho phép truy cập bộ tăng tốc từ các ứng dụng chạy trong máy ảo
(VM). Phần này chỉ mô tả thiết bị FPGA dựa trên PCIe có hỗ trợ SRIOV.

Các tính năng được thiết bị FPGA cụ thể hỗ trợ sẽ được hiển thị thông qua Thiết bị
Danh sách tính năng, như minh họa dưới đây:

::

+------------------------------+ +-------------+
    ZZ0000ZZ ZZ0001ZZ
    +------------------------------+ +-------------+
        ^ ^ ^ ^
        ZZ0002ZZ ZZ0003ZZ
  +------ZZ0004ZZ----------ZZ0005ZZ-------+
  ZZ0006ZZ ZZ0007ZZ ZZ0008ZZ
  ZZ0009ZZ
  ZZ0010ZZ FME ZZ0011ZZ Cổng0 ZZ0012ZZ Cổng1 ZZ0013ZZ Cổng2 ZZ0014ZZ
  ZZ0015ZZ
  ZZ0016ZZ
  ZZ0017ZZ ZZ0018ZZ |
  ZZ0019ZZ
  ZZ0020ZZ AFU ZZ0021ZZ AFU ZZ0022ZZ AFU ZZ0023ZZ
  ZZ0024ZZ
  ZZ0025ZZ
  ZZ0026ZZ
  +---------------------------------------------------+

FME luôn được truy cập thông qua chức năng vật lý (PF).

Các cổng (và các AFU liên quan) được truy cập thông qua PF theo mặc định, nhưng có thể bị lộ
thông qua các thiết bị chức năng ảo (VF) qua PCIe SRIOV. Mỗi VF chỉ chứa
1 cổng và 1 AFU để cách ly. Người dùng có thể chỉ định các VF riêng lẻ (bộ tăng tốc)
được tạo thông qua giao diện PCIe SRIOV tới các máy ảo.

Tổ chức trình điều khiển trong trường hợp ảo hóa được minh họa dưới đây:
::

+-------++------++------+ |
    ZZ0000ZZZZ0001ZZZZ0002ZZ |
    ZZ0003ZZZZ0004ZZZZ0005ZZ |
    ZZ0006ZZZZ0007ZZZZ0008ZZ |
    +-------++------++------+ |
    +--------------+ +--------+ |             +--------+
    ZZ0009ZZ ZZ0010ZZ ZZ0011ZZ AFU |
    Mô-đun ZZ0012ZZ ZZ0013ZZ ZZ0014ZZ |
    +--------------+ +--------+ |             +--------+
          +-----------------------+ |       +--------------+
          ZZ0015ZZ ZZ0016ZZ FPGA Thiết bị chứa |
          ZZ0017ZZ ZZ0018ZZ (Vùng cơ sở FPGA) |
          +-----------------------+ |       +--------------+
            +-------------------+ |         +-------------------+
            Mô-đun ZZ0019ZZ ZZ0020ZZ FPGA PCIE |
            +-------------------+ Máy chủ | Máy +-------------------+
   -------------------------------------- | ------------------------------
             +--------------+ |          +--------------+
             Thiết bị ZZ0021ZZ ZZ0022ZZ PCI VF |
             +--------------+ |          +--------------+

Trình điều khiển thiết bị PCIe FPGA luôn được tải đầu tiên sau khi thiết bị FPGA PCIe PF hoặc VF
được phát hiện. Nó:

* Hoàn tất việc liệt kê trên cả thiết bị FPGA PCIe PF và VF bằng cách sử dụng chung
  giao diện từ khung DFL.
* Hỗ trợ SRIOV.

Trình điều khiển thiết bị FME đóng vai trò quản lý trong kiến trúc trình điều khiển này, nó
cung cấp ioctls để giải phóng Cổng khỏi PF và gán Cổng cho PF. Sau khi phát hành
một cổng từ PF thì việc hiển thị cổng này thông qua VF qua PCIe SRIOV là an toàn
giao diện sysfs.

Để cho phép truy cập bộ tăng tốc từ các ứng dụng chạy trong VM,
cổng của AFU tương ứng cần được gán cho VF bằng các bước sau:

#. PF sở hữu tất cả các cổng AFU theo mặc định. Bất kỳ cổng nào cần có
   được gán lại cho VF trước tiên phải được giải phóng thông qua
   DFL_FPGA_FME_PORT_RELEASE ioctl trên thiết bị FME.

#. Khi N cổng được giải phóng khỏi PF, người dùng có thể sử dụng lệnh bên dưới
   để kích hoạt SRIOV và VF. Mỗi VF chỉ sở hữu một Cổng có AFU.

   ::

echo N > $PCI_DEVICE_PATH/sriov_numvfs

#. Chuyển từ VF sang VM

#. AFU trong VF có thể truy cập được từ các ứng dụng trong VM (sử dụng
   cùng một trình điều khiển bên trong VF).

Lưu ý rằng không thể gán FME cho VF, do đó PR và quản lý khác
các chức năng chỉ có sẵn thông qua PF.

liệt kê thiết bị
==================
Phần này giới thiệu cách các ứng dụng liệt kê thiết bị fpga từ
hệ thống phân cấp sysfs trong/sys/class/fpga_zone.

Trong ví dụ bên dưới, hai thiết bị FPGA dựa trên DFL được cài đặt trong máy chủ. Mỗi
thiết bị fpga có một FME và hai cổng (AFU).

Các vùng FPGA được tạo trong /sys/class/fpga_zone/::

/sys/class/fpga_khu vực/khu vực0
	/sys/class/fpga_khu vực/khu vực1
	/sys/class/fpga_khu vực/khu vực2
	...

Ứng dụng cần tìm kiếm từng thư mục RegionX, nếu tìm thấy thiết bị tính năng,
(ví dụ: tìm thấy "dfl-port.n" hoặc "dfl-fme.m"), thì đó là cơ sở
vùng fpga đại diện cho thiết bị FPGA.

Mỗi vùng cơ sở có một FME và hai cổng (AFU) làm thiết bị con::

/sys/class/fpga_khu vực/khu vực0/dfl-fme.0
	/sys/class/fpga_khu vực/khu vực0/dfl-port.0
	/sys/class/fpga_khu vực/khu vực0/dfl-port.1
	...

/sys/class/fpga_khu vực/khu vực3/dfl-fme.1
	/sys/class/fpga_khu vực/khu vực3/dfl-port.2
	/sys/class/fpga_khu vực/khu vực3/dfl-port.3
	...

Nhìn chung, các giao diện hệ thống FME/AFU được đặt tên như sau::

/sys/class/fpga_khu vực/<khu vựcX>/<dfl-fme.n>/
	/sys/class/fpga_khu vực/<khu vựcX>/<dfl-port.m>/

với 'n' đánh số liên tục tất cả các FME và 'm' đánh số liên tục tất cả
cổng.

Các nút thiết bị được sử dụng cho ioctl() hoặc mmap() có thể được tham chiếu thông qua ::

/sys/class/fpga_khu vực/<khu vựcX>/<dfl-fme.n>/dev
	/sys/class/fpga_khu vực/<khu vựcX>/<dfl-port.n>/dev


Bộ đếm hiệu suất
====================
Báo cáo hiệu suất là một tính năng riêng tư được triển khai trong FME. Nó có thể
hỗ trợ một số bộ đếm thiết bị độc lập, trên toàn hệ thống trong phần cứng để
theo dõi và đếm các sự kiện hiệu suất, bao gồm "cơ bản", "bộ nhớ đệm", "kết cấu",
Bộ đếm "vtd" và "vtd_sip". Người dùng có thể sử dụng công cụ hoàn thiện tiêu chuẩn để theo dõi
Tỷ lệ trúng/lỡ bộ đệm FPGA, số giao dịch, bộ đếm đồng hồ giao diện của AFU
và các sự kiện biểu diễn FPGA khác.

Các thiết bị FPGA khác nhau có thể có bộ đếm khác nhau, tùy thuộc vào phần cứng
thực hiện. Ví dụ: một số thẻ FPGA rời rạc không có bất kỳ bộ nhớ đệm nào. Người dùng có thể
sử dụng "danh sách hoàn hảo" để kiểm tra sự kiện hoàn hảo nào được phần cứng đích hỗ trợ.

Để cho phép người dùng sử dụng API hoàn hảo tiêu chuẩn để truy cập các hiệu suất này
bộ đếm, trình điều khiển tạo một PMU hoàn hảo và các giao diện sysfs liên quan trong
/sys/bus/event_source/devices/dfl_fme* để mô tả các sự kiện hoàn hảo có sẵn và
các tùy chọn cấu hình.

Thư mục "format" mô tả định dạng của trường cấu hình của struct
hoàn hảo_event_attr. Có 3 trường bit cho cấu hình: "evtype" xác định loại nào
sự kiện hoàn hảo thuộc về; "sự kiện" là danh tính của sự kiện trong đó
thể loại; "portid" được giới thiệu để quyết định các bộ đếm được thiết lập để giám sát trên FPGA
dữ liệu tổng thể hoặc một cổng cụ thể.

Thư mục "sự kiện" mô tả các mẫu cấu hình cho tất cả các
các sự kiện có thể được sử dụng trực tiếp với công cụ hoàn hảo. Ví dụ: fab_mmio_read
có cấu hình "event=0x06,evtype=0x02,portid=0xff", hiển thị điều này
sự kiện thuộc loại vải (0x02), id sự kiện cục bộ là 0x06 và nó dành cho
giám sát tổng thể (portid=0xff).

Ví dụ sử dụng perf::

Danh sách $# perf |grep dfl_fme

dfl_fme0/fab_mmio_read/ [Sự kiện hạt nhân PMU]
  <...>
  dfl_fme0/fab_port_mmio_read,portid=?/ [Sự kiện hạt nhân PMU]
  <...>

$# perf thống kê -a -e dfl_fme0/fab_mmio_read/ <lệnh>
  hoặc
  $# perf stat -a -e dfl_fme0/event=0x06,evtype=0x02,portid=0xff/ <lệnh>
  hoặc
  $# perf stat -a -e dfl_fme0/config=0xff2006/ <lệnh>

Một ví dụ khác, fab_port_mmio_read giám sát việc đọc mmio của một cổng cụ thể. Vì vậy
mẫu cấu hình của nó là "event=0x06,evtype=0x01,portid=?". portid
nên được thiết lập rõ ràng.

Cách sử dụng perf::

$# perf stat -a -e dfl_fme0/fab_port_mmio_read,portid=0x0/ <lệnh>
  hoặc
  $# perf stat -a -e dfl_fme0/event=0x06,evtype=0x02,portid=0x0/ <lệnh>
  hoặc
  $# perf stat -a -e dfl_fme0/config=0x2006/ <lệnh>

Xin lưu ý đối với quầy vải, sự kiện hoàn thiện tổng thể (fab_*) và hiệu suất cổng
các sự kiện (fab_port_*) thực sự chia sẻ một bộ bộ đếm trong phần cứng, vì vậy nó không thể
theo dõi cả hai cùng một lúc. Nếu bộ đếm này được cấu hình để giám sát
dữ liệu tổng thể thì dữ liệu hiệu suất trên mỗi cổng không được hỗ trợ. Xem ví dụ dưới đây::

$# perf thống kê -e dfl_fme0/fab_mmio_read/,dfl_fme0/fab_port_mmio_write,\
                                                    portid=0/ ngủ 1

Thống kê bộ đếm hiệu suất cho 'toàn hệ thống':

3 dfl_fme0/fab_mmio_read/
   <không được hỗ trợ> dfl_fme0/fab_port_mmio_write,portid=0x0/

Thời gian đã trôi qua 1,001750904 giây

Trình điều khiển cũng cung cấp thuộc tính sysfs "cpumask", chỉ chứa một
Id CPU được sử dụng để truy cập các sự kiện hoàn hảo này. Không được phép đếm trên nhiều CPU
vì chúng là bộ đếm toàn hệ thống trên thiết bị FPGA.

Trình điều khiển hiện tại không hỗ trợ lấy mẫu. Vì vậy "bản ghi hoàn hảo" không được hỗ trợ.


Hỗ trợ ngắt
=================
Một số tính năng riêng của FME và AFU có thể tạo ra các ngắt. Như đã đề cập
ở trên, người dùng có thể gọi ioctl (DFL_FPGA_*_GET_IRQ_NUM) để biết liệu hoặc bằng cách nào
nhiều ngắt được hỗ trợ cho tính năng riêng tư này. Trình điều khiển cũng thực hiện
cơ chế xử lý ngắt dựa trên sự kiệnfd để người dùng nhận được thông báo khi
gián đoạn xảy ra. Người dùng có thể đặt sự kiện thành trình điều khiển thông qua
ioctl (DFL_FPGA_*_SET_IRQ), sau đó thăm dò/chọn các sự kiện này đang chờ
thông báo.
Trong DFL hiện tại, 3 tính năng phụ (Lỗi cổng, lỗi toàn cầu FME và ngắt AFU)
hỗ trợ ngắt.


Thêm hỗ trợ FIU mới
====================
Có thể các nhà phát triển đã tạo ra một số khối chức năng mới (FIU) theo
DFL framework, thì trình điều khiển thiết bị nền tảng mới cần được phát triển cho
nhà phát triển tính năng mới (FIU) theo cách tương tự như trình điều khiển nhà phát triển tính năng hiện có
(ví dụ: trình điều khiển thiết bị nền tảng FME và Port/AFU). Bên cạnh đó, nó đòi hỏi
cũng sửa đổi mã liệt kê khung DFL để phát hiện loại FIU mới
và tạo ra các thiết bị nền tảng liên quan.


Thêm hỗ trợ tính năng riêng tư mới
================================
Trong một số trường hợp, chúng tôi có thể cần thêm một số tính năng riêng tư mới vào FIU hiện có
(ví dụ: FME hoặc Cổng). Nhà phát triển không cần chạm vào mã liệt kê trong DFL
framework, vì mỗi tính năng riêng tư sẽ được phân tích cú pháp tự động và có liên quan
Tài nguyên mmio có thể được tìm thấy trong thiết bị nền tảng FIU được tạo bởi khung DFL.
Nhà phát triển chỉ cần cung cấp trình điều khiển tính năng phụ có id tính năng phù hợp.
Trình điều khiển tính năng phụ cấu hình lại một phần FME (xem trình điều khiển/fpga/dfl-fme-pr.c)
có thể là một tài liệu tham khảo

Vui lòng tham khảo liên kết bên dưới tới bảng id tính năng hiện có và hướng dẫn về tính năng mới
ứng dụng id
ZZ0000ZZ


Vị trí của DFL trên thiết bị PCI
================================
Phương pháp ban đầu để tìm DFL trên thiết bị PCI giả định sự bắt đầu của
DFL đầu tiên bù 0 của thanh 0. Nếu nút đầu tiên của DFL là FME,
sau đó các DFL tiếp theo trong (các) cổng được chỉ định trong các thanh ghi tiêu đề FME.
Ngoài ra, cấu trúc khả năng cụ thể của nhà cung cấp PCIe có thể được sử dụng để
chỉ định vị trí của tất cả DFL trên thiết bị, mang lại sự linh hoạt
đối với loại nút bắt đầu trong DFL.  Intel đã bảo lưu
VSEC ID 0x43 cho mục đích này.  Nhà cung cấp cụ thể
dữ liệu bắt đầu bằng một thanh ghi cụ thể của nhà cung cấp 4 byte cho số lượng DFL theo sau 4 byte
Các thanh ghi dành riêng cho nhà cung cấp Offset/BIR cho từng DFL. Bit 2:0 của thanh ghi Offset/BIR
biểu thị BAR và các bit 31:3 tạo thành phần bù được căn chỉnh 8 byte trong đó các bit 2:0 là
không.
::

+-----------------------------+
        ZZ0000ZZ
        +-----------------------------+
        ZZ0001ZZ2 BIR 0|
        +-----------------------------+
                      . . .
        +-----------------------------+
        ZZ0002ZZ2 BIR 0|
        +-----------------------------+

Khả năng chỉ định nhiều hơn một DFL cho mỗi BAR đã được xem xét, nhưng nó
đã được xác định trường hợp sử dụng không cung cấp giá trị.  Chỉ định một DFL duy nhất
mỗi BAR đơn giản hóa việc triển khai và cho phép kiểm tra lỗi bổ sung.


Hỗ trợ trình điều khiển không gian người dùng cho các thiết bị DFL
========================================
Mục đích của FPGA là được lập trình lại với phần cứng mới được phát triển
thành phần. Phần cứng mới có thể khởi tạo một tính năng riêng tư mới trong DFL và
sau đó đưa thiết bị DFL vào hệ thống. Trong một số trường hợp người dùng có thể cần một
trình điều khiển không gian người dùng cho thiết bị DFL:

* Người dùng có thể cần chạy một số thử nghiệm chẩn đoán cho phần cứng của mình.
* Người dùng có thể tạo nguyên mẫu trình điều khiển kernel trong không gian người dùng.
* Một số phần cứng được thiết kế cho các mục đích cụ thể và không phù hợp với một trong các phần cứng đó.
  các hệ thống con hạt nhân tiêu chuẩn.

Điều này yêu cầu truy cập trực tiếp vào không gian MMIO và xử lý gián đoạn từ
không gian người dùng. Mô-đun uio_dfl hiển thị giao diện thiết bị UIO cho việc này
mục đích.

Hiện tại trình điều khiển uio_dfl chỉ hỗ trợ tính năng phụ Ether Group, tính năng này
không có iq trong phần cứng. Vì vậy việc xử lý ngắt không được thêm vào trình điều khiển này.

Nên chọn UIO_DFL để kích hoạt trình điều khiển mô-đun uio_dfl. Để hỗ trợ một
tính năng DFL mới thông qua truy cập trực tiếp UIO, id tính năng của nó phải được thêm vào
id_table của trình điều khiển.


Thảo luận mở
===============
Trình điều khiển FME xuất một ioctl (DFL_FPGA_FME_PORT_PR) để cấu hình lại một phần
tới người dùng ngay bây giờ. Trong tương lai, nếu giao diện người dùng hợp nhất để cấu hình lại
đã thêm, trình điều khiển FME nên chuyển sang chúng từ giao diện ioctl.
