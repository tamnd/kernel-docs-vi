.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/devicetree/usage-model.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Linux và cây thiết bị
===========================

Mô hình sử dụng Linux cho dữ liệu cây thiết bị

:Tác giả: Grant Likely <grant.like@secretlab.ca>

Bài viết này mô tả cách Linux sử dụng cây thiết bị.  Tổng quan về
định dạng dữ liệu cây thiết bị có thể được tìm thấy trên trang sử dụng cây thiết bị
tại devicetree.org\ [1]_.

.. [1] https://www.devicetree.org/specifications/

"Cây thiết bị phần sụn mở" hay đơn giản là Devicetree (DT), là một dữ liệu
cấu trúc và ngôn ngữ để mô tả phần cứng.  Cụ thể hơn, nó
là mô tả về phần cứng mà hệ điều hành có thể đọc được
để hệ điều hành không cần phải mã cứng các chi tiết của
máy.

Về mặt cấu trúc, DT là một cây hoặc biểu đồ tuần hoàn với các nút được đặt tên và
các nút có thể có số lượng thuộc tính được đặt tên tùy ý được đóng gói
dữ liệu tùy ý.  Một cơ chế cũng tồn tại để tạo ra tùy ý
liên kết từ nút này đến nút khác bên ngoài cấu trúc cây tự nhiên.

Về mặt khái niệm, một tập hợp các quy ước sử dụng chung, được gọi là 'ràng buộc',
được xác định về cách dữ liệu sẽ xuất hiện trong cây để mô tả điển hình
đặc điểm phần cứng bao gồm bus dữ liệu, đường ngắt, GPIO
kết nối và các thiết bị ngoại vi.

Càng nhiều càng tốt, phần cứng được mô tả bằng cách sử dụng các ràng buộc hiện có để
tối đa hóa việc sử dụng mã hỗ trợ hiện có, nhưng vì thuộc tính và nút
tên chỉ đơn giản là các chuỗi văn bản, rất dễ dàng để mở rộng các ràng buộc hiện có
hoặc tạo cái mới bằng cách xác định các nút và thuộc tính mới.  Hãy cảnh giác,
tuy nhiên, việc tạo một bìa sách mới mà không cần làm bài tập về nhà trước tiên
về những gì đã tồn tại.  Hiện nay có hai loại khác nhau
không tương thích, các ràng buộc dành cho bus i2c xuất hiện do phiên bản mới
liên kết đã được tạo mà không cần điều tra trước xem các thiết bị i2c hoạt động như thế nào
đã được liệt kê trong các hệ thống hiện có.

1. Lịch sử
----------
DT ban đầu được Open Firmware tạo ra như một phần của
phương thức liên lạc để truyền dữ liệu từ Open Firmware đến máy khách
chương trình (giống như một hệ điều hành).  Một hệ điều hành đã sử dụng
Cây thiết bị để khám phá cấu trúc liên kết của phần cứng khi chạy và
do đó hỗ trợ phần lớn phần cứng có sẵn mà không cần mã hóa cứng
thông tin (giả sử trình điều khiển đã có sẵn cho tất cả các thiết bị).

Vì Open Firmware thường được sử dụng trên nền tảng PowerPC và SPARC,
Sự hỗ trợ của Linux cho những kiến trúc đó từ lâu đã sử dụng
Cây thiết bị.

Vào năm 2005, khi PowerPC Linux bắt đầu một cuộc dọn dẹp lớn và hợp nhất 32-bit
và hỗ trợ 64-bit, quyết định được đưa ra là yêu cầu hỗ trợ DT trên tất cả
nền tảng powerpc, bất kể họ có sử dụng Open hay không
Phần sụn.  Để thực hiện điều này, một biểu diễn DT được gọi là Flattened Device
Cây (FDT) đã được tạo và có thể được chuyển tới kernel dưới dạng nhị phân
blob mà không yêu cầu triển khai Open Firmware thực sự.  U-Boot,
kexec và các bộ tải khởi động khác đã được sửa đổi để hỗ trợ cả việc truyền
Cây nhị phân cây thiết bị (dtb) và sửa đổi dtb khi khởi động.  DT là
cũng được thêm vào trình bao bọc khởi động PowerPC (ZZ0000ZZ) để
một dtb có thể được gói gọn trong ảnh kernel để hỗ trợ khả năng khởi động
chương trình cơ sở không nhận biết DT hiện có.

Một thời gian sau, cơ sở hạ tầng FDT đã được phổ biến rộng rãi để có thể sử dụng được
mọi kiến trúc.  Tại thời điểm viết bài này, có 6 nội dung chính
kiến trúc (arm, microblaze, mips, powerpc, sparc và x86) và 1
ngoài dòng chính (nios) có một số mức hỗ trợ DT.

2. Mô hình dữ liệu
------------------
Nếu bạn chưa đọc trang Sử dụng cây thiết bị\ [1]_,
thì hãy đọc nó ngay bây giờ.  Không sao đâu, tôi sẽ đợi....

2.1 Chế độ xem cấp cao
----------------------
Điều quan trọng nhất cần hiểu là DT chỉ đơn giản là một dữ liệu
cấu trúc mô tả phần cứng.  Không có gì kỳ diệu về
nó, và nó không gây ra tất cả các vấn đề về cấu hình phần cứng một cách kỳ diệu.
đi đi.  Những gì nó làm là cung cấp một ngôn ngữ để tách rời
cấu hình phần cứng từ bo mạch và hỗ trợ trình điều khiển thiết bị trong
Nhân Linux (hoặc bất kỳ hệ điều hành nào khác cho vấn đề đó).  sử dụng
nó cho phép hỗ trợ bo mạch và thiết bị được điều khiển bằng dữ liệu; làm
quyết định thiết lập dựa trên dữ liệu được truyền vào kernel thay vì trên
các lựa chọn được mã hóa cứng trên mỗi máy.

Lý tưởng nhất là thiết lập nền tảng điều khiển dữ liệu sẽ tạo ra ít mã hơn
sao chép và làm cho việc hỗ trợ nhiều loại phần cứng trở nên dễ dàng hơn
với một hình ảnh hạt nhân duy nhất.

Linux sử dụng dữ liệu DT cho ba mục đích chính:

1) nhận dạng nền tảng,
2) cấu hình thời gian chạy và
3) số lượng thiết bị.

2.2 Nhận dạng nền tảng
---------------------------
Đầu tiên và quan trọng nhất, kernel sẽ sử dụng dữ liệu trong DT để xác định
máy cụ thể.  Trong một thế giới hoàn hảo, nền tảng cụ thể không nên
quan trọng đối với kernel vì tất cả các chi tiết nền tảng sẽ được mô tả
hoàn hảo bởi cây thiết bị một cách nhất quán và đáng tin cậy.
Tuy nhiên, phần cứng không hoàn hảo và do đó hạt nhân phải xác định
máy trong quá trình khởi động sớm để nó có cơ hội chạy
sửa lỗi dành riêng cho máy.

Trong phần lớn các trường hợp, nhận dạng máy là không liên quan và
thay vào đó kernel sẽ chọn mã thiết lập dựa trên lõi của máy
CPU hoặc SoC.  Ví dụ: trên ARM, setup_arch() trong
Arch/arm/kernel/setup.c sẽ gọi setup_machine_fdt() trong
Arch/arm/kernel/devtree.c tìm kiếm thông qua machine_desc
bảng và chọn machine_desc phù hợp nhất với cây thiết bị
dữ liệu.  Nó xác định kết quả phù hợp nhất bằng cách xem xét 'tương thích'
thuộc tính trong nút cây thiết bị gốc và so sánh nó với
danh sách dt_compat trong struct machine_desc (được xác định trong
Arch/arm/include/asm/mach/arch.h nếu bạn tò mò).

Thuộc tính 'tương thích' chứa danh sách các chuỗi được sắp xếp bắt đầu
với tên chính xác của máy, theo sau là danh sách tùy chọn
các bo mạch tương thích được sắp xếp từ tương thích nhất đến ít nhất.  cho
ví dụ: các thuộc tính tương thích gốc cho TI BeagleBoard và các thuộc tính của nó
người kế nhiệm, bảng BeagleBoard xM có thể trông tương ứng như sau::

tương thích = "ti,omap3-beagleboard", "ti,omap3450", "ti,omap3";
	tương thích = "ti,omap3-beagleboard-xm", "ti,omap3450", "ti,omap3";

Trong đó "ti,omap3-beagleboard-xm" chỉ định mô hình chính xác, nó cũng
tuyên bố rằng nó tương thích với OMAP 3450 SoC và dòng omap3
của SoC nói chung.  Bạn sẽ nhận thấy rằng danh sách được sắp xếp từ hầu hết
cụ thể (bảng chính xác) đến ít cụ thể nhất (họ SoC).

Những độc giả tinh tế có thể chỉ ra rằng Beagle xM cũng có thể khẳng định
khả năng tương thích với bảng Beagle ban đầu.  Tuy nhiên, người ta nên
cảnh báo về việc làm như vậy ở cấp độ hội đồng quản trị vì thường có
mức độ thay đổi cao từ bảng này sang bảng khác, ngay cả trong cùng một
dòng sản phẩm, và thật khó để hiểu chính xác ý nghĩa của một
hội đồng quản trị tuyên bố là tương thích với một hội đồng khác.  Đối với cấp cao nhất, đó là
tốt hơn là nên thận trọng và không yêu cầu một bảng là
tương thích với cái khác.  Ngoại lệ đáng chú ý là khi một
bo mạch là vật mang cho một bo mạch khác, chẳng hạn như mô-đun CPU được gắn vào
bảng vận chuyển.

Thêm một lưu ý nữa về các giá trị tương thích.  Bất kỳ chuỗi nào được sử dụng trong một chuỗi tương thích
tài sản phải được ghi lại như những gì nó chỉ ra.  Thêm
tài liệu về các chuỗi tương thích trong Documentation/devicetree/binds.

Một lần nữa trên ARM, với mỗi machine_desc, kernel sẽ xem liệu
bất kỳ mục nhập danh sách dt_compat nào cũng xuất hiện trong thuộc tính tương thích.
Nếu đúng như vậy thì machine_desc đó là một ứng cử viên để điều khiển
máy.  Sau khi tìm kiếm toàn bộ bảng machine_descs,
setup_machine_fdt() trả về machine_desc 'tương thích nhất'
mỗi machine_desc khớp với mục nào trong thuộc tính tương thích
chống lại.  Nếu không tìm thấy machine_desc phù hợp thì nó sẽ trả về NULL.

Lý do đằng sau kế hoạch này là quan sát thấy rằng trong phần lớn
trong các trường hợp, một machine_desc có thể hỗ trợ một số lượng lớn bảng
nếu tất cả chúng đều sử dụng cùng một SoC hoặc cùng một họ SoC.  Tuy nhiên,
luôn luôn có một số trường hợp ngoại lệ trong đó một hội đồng cụ thể sẽ
yêu cầu mã thiết lập đặc biệt không hữu ích trong trường hợp chung.
Các trường hợp đặc biệt có thể được xử lý bằng cách kiểm tra rõ ràng
(các) bảng rắc rối trong mã thiết lập chung, nhưng thực hiện rất nhanh
trở nên xấu xí và/hoặc không thể bảo trì được nếu nó không chỉ là một vài
trường hợp.

Thay vào đó, danh sách tương thích cho phép một machine_desc chung cung cấp
hỗ trợ cho một bộ bảng phổ biến rộng rãi bằng cách chỉ định "ít hơn
tương thích" trong danh sách dt_compat.  Trong ví dụ trên,
bộ phận hỗ trợ bảng chung có thể yêu cầu khả năng tương thích với "ti, omap3" hoặc
"ti, omap3450".  Nếu một lỗi được phát hiện trên beagleboard ban đầu
yêu cầu mã giải pháp đặc biệt trong quá trình khởi động sớm, sau đó một mã mới
machine_desc có thể được thêm vào để thực hiện các giải pháp thay thế và chỉ
khớp với "ti,omap3-beagleboard".

PowerPC sử dụng sơ đồ hơi khác một chút khi gọi .probe()
hook từ mỗi machine_desc và cái đầu tiên trả về TRUE được sử dụng.
Tuy nhiên, phương pháp này không tính đến mức độ ưu tiên của
danh sách tương thích và có lẽ nên tránh đối với kiến trúc mới
hỗ trợ.

2.3 Cấu hình thời gian chạy
---------------------------
Trong hầu hết các trường hợp, DT sẽ là phương pháp duy nhất để truyền dữ liệu từ
phần sụn vào kernel, do đó cũng được sử dụng để chuyển trong thời gian chạy và
dữ liệu cấu hình như chuỗi tham số kernel và vị trí
của một hình ảnh initrd.

Hầu hết dữ liệu này được chứa trong nút /chosen và khi khởi động
Linux nó sẽ trông giống như thế này::

đã chọn {
		bootargs = "console=ttyS0,115200 loglevel=8";
		initrd-start = <0xc8000000>;
		initrd-end = <0xc8200000>;
	};

Thuộc tính bootargs chứa các đối số kernel và initrd-*
các thuộc tính xác định địa chỉ và kích thước của blob initrd.  Lưu ý rằng
initrd-end là địa chỉ đầu tiên sau hình ảnh initrd, vì vậy địa chỉ này không
phù hợp với ngữ nghĩa thông thường của tài nguyên cấu trúc.  Nút được chọn cũng có thể
tùy ý chứa một số thuộc tính bổ sung tùy ý cho
dữ liệu cấu hình dành riêng cho nền tảng.

Trong quá trình khởi động sớm, mã thiết lập kiến trúc gọi of_scan_flat_dt()
nhiều lần với các lệnh gọi lại trợ giúp khác nhau để phân tích cây thiết bị
dữ liệu trước khi phân trang được thiết lập.  Mã of_scan_flat_dt() quét qua
cây thiết bị và sử dụng các trợ giúp để trích xuất thông tin cần thiết
trong quá trình khởi động sớm.  Điển hình là người trợ giúp Early_init_dt_scan_chosen()
được sử dụng để phân tích nút đã chọn bao gồm các tham số kernel,
Early_init_dt_scan_root() để khởi tạo mô hình không gian địa chỉ DT,
và Early_init_dt_scan_memory() để xác định kích thước và
vị trí của RAM có thể sử dụng được.

Trên ARM, hàm setup_machine_fdt() chịu trách nhiệm sớm
quét cây thiết bị sau khi chọn đúng machine_desc
hỗ trợ bảng.

2.4 Số lượng thiết bị
---------------------
Sau khi bo mạch đã được xác định và sau dữ liệu cấu hình ban đầu
đã được phân tích cú pháp, thì quá trình khởi tạo kernel có thể tiến hành bình thường
cách.  Tại một số thời điểm trong quá trình này, unflatten_device_tree() được gọi
để chuyển đổi dữ liệu thành một biểu diễn thời gian chạy hiệu quả hơn.
Đây cũng là lúc các hook thiết lập dành riêng cho máy sẽ được gọi, như
các hook machine_desc .init_early(), .init_irq() và .init_machine()
trên ARM.  Phần còn lại của phần này sử dụng các ví dụ từ ARM
triển khai, nhưng tất cả các kiến trúc sẽ thực hiện khá giống nhau
điều khi sử dụng DT.

Như có thể đoán qua tên, .init_early() được sử dụng cho bất kỳ máy nào-
thiết lập cụ thể cần được thực hiện sớm trong quá trình khởi động,
và .init_irq() được sử dụng để thiết lập xử lý ngắt.  Sử dụng DT
không thay đổi đáng kể hành vi của một trong hai chức năng này.
Nếu một DT được cung cấp thì cả .init_early() và .init_irq() đều có thể
để gọi bất kỳ hàm truy vấn DT nào (of_* trong include/linux/of*.h) tới
nhận thêm dữ liệu về nền tảng.

Cái móc thú vị nhất trong ngữ cảnh DT là .init_machine() cái này
chịu trách nhiệm chính trong việc đưa vào mô hình thiết bị Linux các
dữ liệu về nền tảng.  Trong lịch sử điều này đã được thực hiện trên
nền tảng nhúng bằng cách xác định một tập hợp các cấu trúc đồng hồ tĩnh,
platform_devices và các dữ liệu khác trong tệp .c hỗ trợ bảng và
đăng ký nó hàng loạt trong .init_machine().  Khi DT được sử dụng thì
thay vì mã hóa cứng các thiết bị tĩnh cho từng nền tảng, danh sách
thiết bị có thể thu được bằng cách phân tích DT và phân bổ thiết bị
các cấu trúc một cách năng động.

Trường hợp đơn giản nhất là khi .init_machine() chỉ chịu trách nhiệm về
đăng ký một khối platform_devices.  platform_device là một khái niệm
được Linux sử dụng cho bộ nhớ hoặc các thiết bị ánh xạ I/O không thể phát hiện được
theo phần cứng và cho các thiết bị 'tổng hợp' hoặc 'ảo' (thêm về các thiết bị đó
sau này).  Mặc dù không có thuật ngữ 'thiết bị nền tảng' cho DT,
các thiết bị nền tảng gần tương ứng với các nút thiết bị ở gốc của
cây và con của các nút bus được ánh xạ bộ nhớ đơn giản.

Bây giờ là thời điểm tốt để đưa ra một ví dụ.  Đây là một phần của
cây thiết bị cho bo mạch NVIDIA Tegra::

/{
	tương thích = "nvidia,harmony", "nvidia,tegra20";
	#address-cells = <1>;
	#size-cells = <1>;
	ngắt-parent = <&intc>;

đã chọn { };
	bí danh { };

bộ nhớ {
		device_type = "bộ nhớ";
		reg = <0x00000000 0x40000000>;
	};

xã hội {
		tương thích = "nvidia,tegra20-soc", "bus đơn giản";
		#address-cells = <1>;
		#size-cells = <1>;
		phạm vi;

intc: bộ điều khiển ngắt@50041000 {
			tương thích = "nvidia,tegra20-gic";
			bộ điều khiển ngắt;
			#interrupt-cells = <1>;
			reg = <0x50041000 0x1000>, < 0x50040100 0x0100>;
		};

nối tiếp@70006300 {
			tương thích = "nvidia,tegra20-uart";
			reg = <0x70006300 0x100>;
			ngắt = <122>;
		};

i2s1: i2s@70002800 {
			tương thích = "nvidia,tegra20-i2s";
			reg = <0x70002800 0x100>;
			ngắt = <77>;
			codec = <&wm8903>;
		};

i2c@7000c000 {
			tương thích = "nvidia,tegra20-i2c";
			#address-cells = <1>;
			#size-cells = <0>;
			reg = <0x7000c000 0x100>;
			ngắt = <70>;

wm8903: codec@1a {
				tương thích = "wlf,wm8903";
				reg = �;
				ngắt = <347>;
			};
		};
	};

âm thanh {
		tương thích = "nvidia,âm thanh hài hòa";
		bộ điều khiển i2s = <&i2s1>;
		i2s-codec = <&wm8903>;
	};
  };

Tại thời điểm .init_machine(), mã hỗ trợ bảng Tegra sẽ cần được xem xét
DT này và quyết định nút nào sẽ tạo platform_devices.
Tuy nhiên, nhìn vào cái cây, không thể thấy ngay đó là loại cây gì.
của thiết bị mà mỗi nút đại diện hoặc thậm chí nếu một nút đại diện cho một thiết bị
không hề.  Các nút/được chọn,/bí danh và/bộ nhớ mang tính thông tin
các nút không mô tả thiết bị (mặc dù bộ nhớ có thể được cho là
được coi là một thiết bị).  Các nút con của nút/soc được ánh xạ bộ nhớ
thiết bị, nhưng codec@1a là thiết bị i2c và nút âm thanh
không phải là một thiết bị mà là cách các thiết bị khác được kết nối
cùng nhau để tạo ra hệ thống con âm thanh.  Tôi biết từng thiết bị là gì
vì tôi đã quen với thiết kế bo mạch, nhưng kernel thì làm thế nào
biết phải làm gì với mỗi nút?

Bí quyết là kernel bắt đầu từ gốc của cây và trông
đối với các nút có thuộc tính 'tương thích'.  Đầu tiên, nói chung là
giả định rằng bất kỳ nút nào có thuộc tính 'tương thích' đều đại diện cho một thiết bị
thuộc loại nào đó, và thứ hai, có thể giả định rằng bất kỳ nút nào ở gốc
của cây được gắn trực tiếp vào bus bộ xử lý hoặc là một
thiết bị hệ thống linh tinh không thể mô tả bằng cách nào khác.
Đối với mỗi nút này, Linux phân bổ và đăng ký một
platform_device, do đó có thể bị ràng buộc với platform_driver.

Tại sao việc sử dụng platform_device cho các nút này lại là một giả định an toàn?
Chà, theo cách mà Linux lập mô hình thiết bị, gần như tất cả các bus_types
giả sử rằng các thiết bị của nó là con của bộ điều khiển xe buýt.  cho
ví dụ: mỗi i2c_client là con của i2c_master.  Mỗi thiết bị spi
là con của xe buýt SPI.  Tương tự cho USB, PCI, MDIO, v.v.
Hệ thống phân cấp tương tự cũng được tìm thấy trong DT, nơi chỉ có các nút thiết bị I2C
từng xuất hiện dưới dạng nút con của nút xe buýt I2C.  Tương tự cho SPI, MDIO, USB,
v.v. Các thiết bị duy nhất không yêu cầu loại cha mẹ cụ thể
thiết bị là platform_devices (và amba_devices, nhưng còn nhiều hơn thế nữa
sau này), nó sẽ sống vui vẻ ở nền tảng của Linux /sys/devices
cây.  Do đó, nếu nút DT ở gốc cây thì nó
thực sự có lẽ tốt nhất nên đăng ký dưới dạng platform_device.

Lệnh gọi mã hỗ trợ bảng Linux of_platform_populate(NULL, NULL, NULL, NULL)
để bắt đầu khám phá các thiết bị ở gốc cây.  các
các tham số đều là NULL vì khi bắt đầu từ gốc của
cây, không cần cung cấp nút khởi đầu (NULL đầu tiên), một
thiết bị cấu trúc gốc (NULL cuối cùng) và chúng tôi không sử dụng kết quả khớp
bàn (chưa).  Đối với một bảng chỉ cần đăng ký thiết bị,
.init_machine() có thể trống hoàn toàn ngoại trừ
cuộc gọi of_platform_populate().

Trong ví dụ về Tegra, điều này giải thích cho các nút /soc và /sound, nhưng
còn các nút con của nút SoC thì sao?  Họ có nên đăng ký không
cũng như các thiết bị nền tảng?  Để hỗ trợ Linux DT, hành vi chung
dành cho các thiết bị con được đăng ký bởi trình điều khiển thiết bị của phụ huynh tại
thời gian của trình điều khiển .probe().  Vì vậy, trình điều khiển thiết bị bus i2c sẽ đăng ký một
i2c_client cho mỗi nút con, trình điều khiển bus SPI sẽ đăng ký
spi_device con của nó và tương tự cho các bus_type khác.
Theo mô hình đó, một trình điều khiển có thể được viết để liên kết với
nút SoC và chỉ cần đăng ký platform_devices cho mỗi nút của nó
trẻ em.  Mã hỗ trợ của bo mạch sẽ phân bổ và đăng ký SoC
thiết bị, trình điều khiển thiết bị SoC (lý thuyết) có thể liên kết với thiết bị SoC,
và đăng ký platform_devices cho/soc/bộ điều khiển ngắt,/soc/serial,
/soc/i2s và /soc/i2c trong hook .probe() của nó.  Dễ dàng phải không?

Trên thực tế, hóa ra việc đăng ký cho con của một số
platform_devices vì nhiều platform_devices hơn là một mẫu phổ biến và
mã hỗ trợ cây thiết bị phản ánh điều đó và đưa ra ví dụ trên
đơn giản hơn.  Đối số thứ hai của of_platform_populate() là một
bảng of_device_id và bất kỳ nút nào khớp với mục nhập trong bảng đó
cũng sẽ đăng ký các nút con của nó.  Trong trường hợp Tegra, mã
có thể trông giống như thế này::

khoảng trống tĩnh __init Harmony_init_machine(void)
  {
	/* ... */
	of_platform_populate(NULL, of_default_bus_match_table, NULL, NULL);
  }

"bus đơn giản" được định nghĩa trong Đặc tả Devicetree như một thuộc tính
nghĩa là một bus được ánh xạ bộ nhớ đơn giản, vì vậy mã of_platform_populate()
có thể được viết để chỉ giả sử các nút tương thích với xe buýt đơn giản sẽ
luôn được vượt qua.  Tuy nhiên, chúng tôi chuyển nó vào như một đối số để
mã hỗ trợ bảng luôn có thể ghi đè hành vi mặc định.

[Cần thêm thảo luận về việc thêm thiết bị con i2c/spi/etc]

Phụ lục A: Thiết bị AMBA
------------------------

ARM Primecells là một loại thiết bị nhất định được gắn vào ARM AMBA
bus bao gồm một số hỗ trợ cho việc phát hiện phần cứng và cấp nguồn
quản lý.  Trong Linux, cấu trúc amba_device và amba_bus_type là
được sử dụng để đại diện cho các thiết bị Primecell.  Tuy nhiên, điều khó hiểu là
không phải tất cả các thiết bị trên bus AMBA đều là Primecell và đối với Linux thì điều đó là
điển hình cho cả phiên bản amba_device và platform_device
anh chị em cùng phân khúc xe buýt.

Khi sử dụng DT, điều này tạo ra vấn đề cho of_platform_populate()
bởi vì nó phải quyết định có đăng ký mỗi nút như một
platform_device hoặc amba_device.  Thật không may, điều này làm phức tạp
mô hình tạo thiết bị một chút, nhưng giải pháp hóa ra lại không
trở nên quá xâm lấn.  Nếu một nút tương thích với "arm,primecell", thì
of_platform_populate() sẽ đăng ký nó dưới dạng amba_device thay vì
platform_device.