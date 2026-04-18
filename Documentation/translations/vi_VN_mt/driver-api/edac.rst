.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/edac.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Thiết bị phát hiện và sửa lỗi (EDAC)
=============================================

Các khái niệm chính được sử dụng tại hệ thống con EDAC
----------------------------------------

Có một số điều cần lưu ý mà không hề rõ ràng chút nào, như
*sockets, *bộ ổ cắm*, *banks*, *rows*, *hàng chọn chip*, *kênh*,
v.v...

Đây là một số trong nhiều thuật ngữ được đưa ra mà không phải lúc nào cũng
có nghĩa là những gì mọi người nghĩ họ muốn nói (Không thể tưởng tượng nổi!).  Vì lợi ích của
tạo ra một nền tảng chung để thảo luận, các thuật ngữ và định nghĩa của chúng
sẽ được thành lập.

* Thiết bị bộ nhớ

Các chip DRAM riêng lẻ trên thẻ nhớ.  Các thiết bị này thường
mỗi đầu ra 4 và 8 bit (x4, x8). Nhóm một số trong số này song song
cung cấp số bit mà bộ điều khiển bộ nhớ mong đợi:
thường là 72 bit, để cung cấp 64 bit + 8 bit dữ liệu ECC.

* Thẻ nhớ

Một bảng mạch in tổng hợp nhiều thiết bị bộ nhớ trong
song song.  Nói chung, đây là Thiết bị có thể thay thế tại hiện trường (FRU)
được thay thế trong trường hợp có lỗi quá mức. Thông thường nó cũng là
được gọi là DIMM (Mô-đun bộ nhớ nội tuyến kép).

* Ổ cắm bộ nhớ

Một đầu nối vật lý trên bo mạch chủ chấp nhận một bộ nhớ
dính. Còn được gọi là "khe" trên một số bảng dữ liệu.

* Kênh

Một kênh điều khiển bộ nhớ, chịu trách nhiệm liên lạc với một nhóm
DIMM. Mỗi kênh có điều khiển (lệnh) và dữ liệu độc lập riêng
bus và có thể được sử dụng độc lập hoặc được nhóm với các kênh khác.

* Chi nhánh

Nó thường là hệ thống phân cấp cao nhất trên bộ nhớ DIMM được đệm đầy đủ
bộ điều khiển. Thông thường, nó chứa hai kênh. Hai kênh ở
cùng một nhánh có thể được sử dụng ở chế độ đơn hoặc ở chế độ bước khóa. Khi nào
lockstep được bật, dòng bộ đệm được tăng gấp đôi, nhưng nó thường mang lại
một số hình phạt hiệu suất. Ngoài ra, nói chung là không thể chỉ ra
chỉ một thẻ nhớ khi xảy ra lỗi, làm mã sửa lỗi
được tính toán bằng cách sử dụng hai DIMM thay vì một. Nhờ đó, nó có khả năng
sửa nhiều lỗi hơn so với chế độ đơn.

* Kênh đơn

Dữ liệu được bộ điều khiển bộ nhớ truy cập được chứa trong một dimm
chỉ. Ví dụ. nếu dữ liệu rộng 64 bit, dữ liệu sẽ chuyển tới CPU bằng cách sử dụng
một truy cập song song 64 bit. Thường được sử dụng với SDR, DDR, DDR2 và DDR3
kỷ niệm. FB-DIMM và RAMBUS sử dụng khái niệm khác nhau cho kênh, vì vậy
khái niệm này không áp dụng ở đó.

* Kênh đôi

Kích thước dữ liệu được bộ điều khiển bộ nhớ truy cập được xen kẽ thành hai
dimms, được truy cập cùng một lúc. Ví dụ. nếu DIMM rộng 64 bit (72
bit với ECC), dữ liệu sẽ truyền đến CPU bằng cách sử dụng song song 128 bit
truy cập.

* Hàng chọn chip

Đây là tên của tín hiệu DRAM được sử dụng để chọn thứ hạng DRAM làm
đã truy cập. Các hàng chọn chip phổ biến cho kênh đơn là 64 bit, ví dụ:
kênh đôi 128 bit. Bộ điều khiển bộ nhớ có thể không nhìn thấy nó,
vì một số loại DIMM có bộ nhớ đệm có thể ẩn quyền truy cập trực tiếp vào
nó từ Bộ điều khiển bộ nhớ.

* Cây gậy xếp hạng đơn

Một thanh xếp hạng đơn có 1 hàng bộ nhớ chọn chip. Bo mạch chủ
thường dẫn hai chân chọn chip vào thẻ nhớ. Xếp hạng đơn
dính, sẽ chỉ chiếm một trong những hàng đó. Cái còn lại sẽ không được sử dụng.

.. _doubleranked:

* Cây gậy xếp hạng đôi

Một thanh xếp hạng kép có hai hàng chọn chip truy cập vào các hàng khác nhau
tập hợp các thiết bị bộ nhớ.  Hai hàng không thể được truy cập đồng thời.

* Thanh hai mặt

ZZ0001ZZ, xem ZZ0000ZZ.

Một thanh hai mặt có hai hàng chọn chip để truy cập các bộ khác nhau
của các thiết bị bộ nhớ. Hai hàng không thể được truy cập đồng thời.
"Hai mặt" không phân biệt thiết bị bộ nhớ được gắn trên
cả hai mặt của thẻ nhớ.

* Bộ ổ cắm

Tất cả các thẻ nhớ được yêu cầu cho một lần truy cập bộ nhớ hoặc
tất cả các thẻ nhớ nằm trong một hàng chọn chip.  Một ổ cắm duy nhất
bộ có hai hàng chọn chip và nếu sử dụng gậy hai mặt
sẽ chiếm các hàng chọn chip đó.

* Ngân hàng

Thuật ngữ này được tránh sử dụng vì không rõ ràng khi cần phân biệt
giữa các hàng chọn chip và bộ ổ cắm.

* Bộ nhớ băng thông cao (HBM)

HBM là loại bộ nhớ mới với mức tiêu thụ điện năng thấp và siêu rộng
các làn đường liên lạc. Nó sử dụng các chip nhớ xếp chồng lên nhau theo chiều dọc (khuôn DRAM)
được kết nối với nhau bằng các dây siêu nhỏ gọi là "vias xuyên silicon" hoặc
TSV.

Một số ngăn xếp chip HBM kết nối với CPU hoặc GPU thông qua tốc độ cực nhanh
kết nối được gọi là "interposer". Vì vậy, đặc điểm của HBM
gần như không thể phân biệt được với RAM tích hợp trên chip.

Bộ điều khiển bộ nhớ
------------------

Hầu hết lõi EDAC đều tập trung vào việc phát hiện lỗi Bộ điều khiển bộ nhớ.
ZZ0000ZZ. Nó sử dụng nội bộ cấu trúc ZZ0001ZZ
để mô tả các bộ điều khiển bộ nhớ, với một cấu trúc mờ cho EDAC
trình điều khiển. Chỉ lõi EDAC mới được phép chạm vào nó.

.. kernel-doc:: include/linux/edac.h

.. kernel-doc:: drivers/edac/edac_mc.h

Bộ điều khiển PCI
---------------

Hệ thống con EDAC cung cấp cơ chế xử lý bộ điều khiển PCI bằng cách gọi
ZZ0000ZZ. Nó sẽ sử dụng cấu trúc
ZZ0001ZZ để mô tả bộ điều khiển PCI.

.. kernel-doc:: drivers/edac/edac_pci.h

Khối EDAC
-----------

Hệ thống con EDAC cũng cung cấp một cơ chế chung để báo cáo lỗi trên
các bộ phận khác của phần cứng thông qua chức năng ZZ0000ZZ.

Các cấu trúc ZZ0000ZZ,
ZZ0001ZZ, ZZ0002ZZ và
ZZ0003ZZ cung cấp 'edac_device' chung chung hoặc trừu tượng
đại diện tại sysfs.

Bộ cấu trúc và mã triển khai các API tương tự này cung cấp khả năng đăng ký các thiết bị loại EDAC là bộ nhớ tiêu chuẩn NOT hoặc
PCI, như:

- Bộ nhớ đệm CPU (L1 và L2)
- Động cơ DMA
- Công tắc lõi CPU
- Bộ chuyển đổi vải
- Bộ điều khiển giao diện PCIe
- các thiết bị loại EDAC/ECC khác có thể được giám sát
  lỗi, v.v.

Nó cho phép thiết lập hệ thống phân cấp 2 cấp.

Ví dụ: bộ đệm có thể bao gồm các cấp độ bộ đệm L1, L2 và L3.
Mỗi lõi CPU sẽ có bộ đệm L1 riêng, đồng thời chia sẻ L2 và có thể là L3
bộ nhớ đệm. Trong trường hợp như vậy, chúng có thể được biểu diễn thông qua các sysfs sau
nút::

/sys/thiết bị/hệ thống/edac/..

pci/ <thư mục pci hiện có (nếu có)>
	mc/ <thư mục thiết bị bộ nhớ hiện có>
	cpu/cpu0/.. <thư mục khối L1 và L2>
		/L1-cache/ce_count
			 /ue_count
		/L2-cache/ce_count
			 /ue_count
	cpu/cpu1/.. <thư mục khối L1 và L2>
		/L1-cache/ce_count
			 /ue_count
		/L2-cache/ce_count
			 /ue_count
	...

thư mục L1 và L2 sẽ là "edac_device_block's"

.. kernel-doc:: drivers/edac/edac_device.h


Hỗ trợ hệ thống không đồng nhất
----------------------------

Một hệ thống không đồng nhất AMD được xây dựng bằng cách kết nối các kết cấu dữ liệu của
cả CPU và GPU thông qua các liên kết xGMI tùy chỉnh. Vì vậy, kết cấu dữ liệu trên
Các nút GPU có thể được truy cập theo cách tương tự như kết cấu dữ liệu trên các nút CPU.

Bộ tăng tốc MI200 là GPU của trung tâm dữ liệu. Họ có 2 loại vải dữ liệu,
và mỗi kết cấu dữ liệu GPU chứa bốn Bộ điều khiển bộ nhớ hợp nhất (UMC).
Mỗi UMC chứa tám kênh. Mỗi kênh UMC điều khiển một kênh 128 bit
Kênh HBM2e (2GB) (tương đương 8 cấp X 2GB).  Điều này tạo ra tổng
trong số 4096-bit của bus dữ liệu DRAM.

Trong khi UMC đang kết nối với ngăn xếp HBM 16GB (8cao X 2GB), mỗi ngăn xếp UMC
kênh đang giao tiếp 2GB DRAM (được biểu thị dưới dạng xếp hạng).

Do đó, bộ điều khiển bộ nhớ trên các nút AMD GPU có thể được biểu diễn trong EDAC:

Nút GPU DF / GPU -> EDAC MC
	GPU UMC -> EDAC CSROW
	Kênh GPU UMC -> EDAC CHANNEL

Ví dụ: một hệ thống không đồng nhất có 1 AMD CPU được kết nối với
4 GPU MI200 (Aldebaran) sử dụng xGMI.

Một số chi tiết phần cứng không đồng nhất hơn:

- CPU UMC (Bộ điều khiển bộ nhớ hợp nhất) hầu hết giống với GPU UMC.
  Họ có các lựa chọn chip (csrows) và các kênh. Tuy nhiên, bố cục có khác nhau
  vì hiệu suất, bố cục vật lý hoặc lý do khác.
- CPU UMC sử dụng 1 kênh, Trong trường hợp này UMC = kênh EDAC. Điều này tuân theo
  tiếp thị nói. CPU có các kênh bộ nhớ X, v.v.
- CPU UMC sử dụng tối đa 4 chip chọn, Vậy UMC chip select = EDAC CSROW.
- UMC GPU sử dụng 1 chip chọn, Vậy UMC = EDAC CSROW.
- UMC GPU sử dụng 8 kênh, Vậy kênh UMC = kênh EDAC.

Hệ thống con EDAC cung cấp cơ chế xử lý AMD không đồng nhất
hệ thống bằng cách gọi các hoạt động cụ thể của hệ thống cho cả CPU và GPU.

Các nút AMD GPU được liệt kê theo thứ tự tuần tự dựa trên PCI
phân cấp và nút GPU đầu tiên được giả sử có giá trị ID nút
theo sau các nút CPU sau đó được điền đầy đủ ::

$ ls /sys/devices/system/edac/mc/
		mc0 - Nút CPU MC 0
		mc1 |
		mc2 |- Thẻ GPU[0] => nút 0(mc1), nút 1(mc2)
		mc3 |
		mc4 |- Thẻ GPU[1] => nút 0(mc3), nút 1(mc4)
		mc5 |
		mc6 |- Thẻ GPU[2] => nút 0(mc5), nút 1(mc6)
		mc7 |
		mc8 |- Thẻ GPU[3] => nút 0(mc7), nút 1(mc8)

Ví dụ: một hệ thống không đồng nhất có một AMD CPU được kết nối với
bốn GPU MI200 (Aldebaran) sử dụng xGMI. Cấu trúc liên kết này có thể được biểu diễn
thông qua các mục sysfs sau::

/sys/devices/system/edac/mc/..

Nút CPU # ZZ0001ZZ
	├── mc 0

Các nút GPU được liệt kê tuần tự sau khi các nút CPU được điền
	Thẻ GPU 1 # Each MI200 GPU có 2 nút/mcs
	├── mc 1 nút # ZZ0005ZZ 0 == mc1, Mỗi nút MC có 4 UMC/CSROW
	│   ├── csrow 0 # ZZ0006ZZ 0
	│   │   ├── kênh 0 # Each UMC có 8 kênh
	│   │   ├── kênh 1 # size mỗi kênh là 2 GB nên mỗi kênh UMC có 16 GB
	│   │   ├── kênh 2
	│   │   ├── kênh 3
	│   │   ├── kênh 4
	│   │   ├── kênh 5
	│   │   ├── kênh 6
	│   │   ├── kênh 7
	│   ├── csrow 1 # ZZ0009ZZ 1
	│   │   ├── kênh 0
	│   │   ├── ..
	│   │   ├── kênh 7
	│   ├── .. ..
	│   ├── csrow 3 # ZZ0010ZZ 3
	│   │   ├── kênh 0
	│   │   ├── ..
	│   │   ├── kênh 7
	│   ├── hạng 0
	│   ├── .. ..
	│   ├── xếp hạng 31 # total 32 cấp/dimm từ 4 UMC
	├
	├── mc 2 # ZZ0011ZZ nút 1 == mc2
	│   ├── .. # each GPU có tổng cộng 64 GB

Thẻ GPU 2
	├── mc 3
	│   ├── ..
	├── mc 4
	│   ├── ..

Thẻ GPU 3
	├── mc 5
	│   ├── ..
	├── mc 6
	│   ├── ..

Thẻ GPU 4
	├── mc 7
	│   ├── ..
	├── mc 8
	│   ├── ..
