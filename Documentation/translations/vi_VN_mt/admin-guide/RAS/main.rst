.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/RAS/main.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

======================================================
Độ tin cậy, tính sẵn có và khả năng phục vụ (RAS)
======================================================

Tài liệu này ghi lại các khía cạnh khác nhau của chức năng RAS có trong
hạt nhân.

Khái niệm RAS
*************

Độ tin cậy, tính sẵn sàng và khả năng phục vụ (RAS) là một khái niệm được sử dụng trên
máy chủ nhằm đo lường độ mạnh mẽ của chúng.

Độ tin cậy
  là xác suất mà một hệ thống sẽ tạo ra kết quả đầu ra chính xác.

* Thường được đo bằng Thời gian trung bình giữa các lần thất bại (MTBF)
  * Được tăng cường bởi các tính năng giúp tránh, phát hiện và sửa chữa các lỗi phần cứng

sẵn có
  là xác suất mà một hệ thống đang hoạt động tại một thời điểm nhất định

* Thường được đo bằng phần trăm thời gian ngừng hoạt động trong một khoảng thời gian
  * Thường sử dụng các cơ chế phát hiện và sửa lỗi phần cứng trong
    thời gian chạy;

Khả năng phục vụ (hoặc khả năng bảo trì)
  là sự đơn giản và tốc độ mà hệ thống có thể được sửa chữa hoặc
  duy trì

* Thường được đo theo thời gian trung bình giữa các lần sửa chữa (MTBR)

Cải thiện RAS
-------------

Để giảm thời gian ngừng hoạt động của hệ thống, hệ thống phải có khả năng phát hiện
lỗi phần cứng và sửa chúng khi có thể trong thời gian chạy. Nó nên
cũng cung cấp các cơ chế để phát hiện sự xuống cấp của phần cứng, nhằm cảnh báo
quản trị viên hệ thống thực hiện hành động thay thế một thành phần trước
nó gây mất dữ liệu hoặc ngừng hoạt động hệ thống.

Trong số các biện pháp giám sát, những biện pháp thông thường nhất bao gồm:

* CPU – phát hiện lỗi khi thực hiện lệnh và tại bộ đệm L1/L2/L3;
* Bộ nhớ – thêm logic sửa lỗi (ECC) để phát hiện và sửa lỗi;
* I/O – thêm tổng kiểm tra CRC cho dữ liệu được truyền;
* Lưu trữ – RAID, hệ thống tệp tạp chí, tổng kiểm tra,
  Công nghệ tự giám sát, phân tích và báo cáo (SMART).

Bằng cách theo dõi số lần phát hiện lỗi, có thể
để xác định xem xác suất xảy ra lỗi phần cứng có tăng lên hay không và trên cơ sở đó
trường hợp, hãy thực hiện bảo trì phòng ngừa để thay thế một bộ phận đã xuống cấp trong khi
những lỗi đó có thể sửa được.

Các loại lỗi
---------------

Hầu hết các cơ chế được sử dụng trên các hệ thống hiện đại đều sử dụng các công nghệ như Hamming
Các mã cho phép sửa lỗi khi số lượng lỗi trên một gói bit
đang ở dưới một ngưỡng. Nếu số lượng lỗi ở trên, các cơ chế đó
có thể chỉ ra với độ tin cậy cao rằng đã xảy ra lỗi, nhưng
họ không thể sửa được.

Ngoài ra, đôi khi xảy ra lỗi trên một thành phần không được sử dụng. cho
ví dụ, một phần bộ nhớ hiện không được phân bổ.

Điều đó xác định một số loại lỗi:

* ZZ0000ZZ - cơ chế phát hiện lỗi và
  đã sửa lỗi. Những lỗi như vậy thường không nghiêm trọng, mặc dù một số
  Cơ chế hạt nhân cho phép quản trị viên hệ thống coi chúng là nguy hiểm.

* ZZ0000ZZ - số lượng lỗi xảy ra phía trên lỗi
  ngưỡng sửa và hệ thống không thể tự động sửa.

* ZZ0000ZZ - khi xảy ra lỗi UE trên một thành phần quan trọng của
  hệ thống (ví dụ: một phần của Kernel bị UE làm hỏng), hệ thống
  cách đáng tin cậy duy nhất để tránh hỏng dữ liệu là treo hoặc khởi động lại máy.

* ZZ0000ZZ - khi xảy ra lỗi UE trên một thành phần không được sử dụng,
  như CPU ở trạng thái tắt nguồn hoặc bộ nhớ không sử dụng, hệ thống có thể
  vẫn chạy, cuối cùng thay thế phần cứng bị ảnh hưởng bằng một phần cứng dự phòng còn nóng,
  nếu có sẵn.

Ngoài ra, khi xảy ra lỗi trên quy trình không gian người dùng, cũng có thể
  giết quá trình đó và để không gian người dùng khởi động lại nó.

Cơ chế xử lý các lỗi không nghiêm trọng thường phức tạp và có thể
cần sự trợ giúp của một số ứng dụng không gian người dùng để áp dụng
chính sách mà người quản trị hệ thống mong muốn.

Xác định một thành phần phần cứng xấu
-------------------------------------

Chỉ phát hiện một lỗ hổng phần cứng thường là không đủ vì hệ thống cần
để xác định thiết bị có thể thay thế tối thiểu (MRU) cần được trao đổi
để làm cho phần cứng trở nên đáng tin cậy trở lại.

Vì vậy, nó không chỉ yêu cầu các phương tiện ghi lỗi mà còn cả các cơ chế
sẽ dịch thông báo lỗi sang màn hình lụa hoặc nhãn thành phần cho
MRU.

Thông thường, nó rất phức tạp đối với bộ nhớ, vì các CPU hiện đại đan xen bộ nhớ
từ các mô-đun bộ nhớ khác nhau để mang lại hiệu suất tốt hơn. các
DMI BIOS thường có danh sách các nhãn mô-đun bộ nhớ, có thể lấy được
bằng công cụ ZZ0000ZZ. Ví dụ: trên máy tính để bàn, nó hiển thị::

Thiết bị bộ nhớ
		Tổng chiều rộng: 64 bit
		Độ rộng dữ liệu: 64 bit
		Kích thước: 16384 MB
		Yếu tố hình thức: SODIMM
		Bộ: Không có
		Bộ định vị: ChannelA-DIMM0
		Định vị ngân hàng: BANK 0
		Loại: DDR4
		Loại chi tiết: Đồng bộ
		Tốc độ: 2133 MHz
		Xếp hạng: 2
		Tốc độ xung nhịp được cấu hình: 2133 MHz

Trong ví dụ trên, mô-đun bộ nhớ DDR4 SO-DIMM được đặt ở
bộ nhớ của hệ thống được gắn nhãn là "BANK 0", như được cung cấp bởi trường ZZ0000ZZ.
Xin lưu ý rằng, trên hệ thống như vậy, ZZ0001ZZ bằng với
ZZ0002ZZ. Có nghĩa là mô-đun bộ nhớ đó không có lỗi
cơ chế phát hiện/sửa chữa.

Thật không may, không phải tất cả các hệ thống đều sử dụng cùng một trường để chỉ định bộ nhớ
ngân hàng. Trong ví dụ này, từ máy chủ cũ hơn, ZZ0000ZZ hiển thị::

Thiết bị bộ nhớ
		Xử lý mảng: 0x1000
		Xử lý thông tin lỗi: Không được cung cấp
		Tổng chiều rộng: 72 bit
		Độ rộng dữ liệu: 64 bit
		Kích thước: 8192 MB
		Yếu tố hình thức: DIMM
		Bộ: 1
		Định vị: DIMM_A1
		Định vị ngân hàng: Không được chỉ định
		Loại: DDR3
		Chi tiết loại: Đã đăng ký đồng bộ (Được đệm)
		Tốc độ: 1600 MHz
		Xếp hạng: 2
		Tốc độ xung nhịp được cấu hình: 1600 MHz

Ở đó, mô-đun bộ nhớ DDR3 RDIMM được đặt tại bộ nhớ của hệ thống có nhãn
là "DIMM_A1", được cung cấp bởi trường ZZ0000ZZ. Xin lưu ý rằng điều này
mô-đun bộ nhớ có 64 bit ZZ0001ZZ và 72 bit ZZ0002ZZ. Vì vậy,
nó có 8 bit bổ sung được sử dụng bởi các cơ chế phát hiện và sửa lỗi.
Loại bộ nhớ như vậy được gọi là bộ nhớ mã sửa lỗi (bộ nhớ ECC).

Tệ hơn nữa, không có gì lạ khi các hệ thống có các chế độ khác nhau
nhãn trên bo mạch hệ thống của họ để sử dụng chính xác BIOS, nghĩa là
nhãn do BIOS cung cấp sẽ không khớp với nhãn thật.

Bộ nhớ ECC
----------

Như đã đề cập ở phần trước, bộ nhớ ECC có các bit bổ sung cần được lưu trữ.
dùng để sửa lỗi. Trong ví dụ trên, một mô-đun bộ nhớ có
64 bit ZZ0000ZZ và 72 bit ZZ0001ZZ.  Thêm 8
các bit được sử dụng cho cơ chế phát hiện và sửa lỗi
được gọi là ZZ0002ZZ\ [#f1]_\ [#f2]_.

Vì vậy, khi CPU yêu cầu bộ điều khiển bộ nhớ viết một từ có
ZZ0000ZZ, bộ điều khiển bộ nhớ tính toán ZZ0001ZZ theo thời gian thực,
sử dụng mã Hamming hoặc một số mã sửa lỗi khác, như SECDED+,
tạo mã có kích thước ZZ0002ZZ. Mã như vậy sau đó được viết
trên các mô-đun bộ nhớ.

Khi đọc, mã bit ZZ0000ZZ được chuyển đổi trở lại, sử dụng cùng một
Mã ECC được sử dụng khi viết, tạo ra một từ có ZZ0001ZZ và ZZ0002ZZ.
Từ có ZZ0003ZZ được gửi tới CPU, ngay cả khi xảy ra lỗi.

Bộ điều khiển bộ nhớ cũng xem xét ZZ0000ZZ để kiểm tra xem
đã xảy ra lỗi và liệu mã ECC có thể khắc phục được lỗi đó hay không.
Nếu lỗi đã được sửa, Lỗi đã sửa (CE) đã xảy ra. Nếu không, một
Đã xảy ra lỗi chưa được sửa chữa (UE).

Thông tin về lỗi CE/UE được lưu trữ trên một số thanh ghi đặc biệt
tại bộ điều khiển bộ nhớ và có thể được truy cập bằng cách đọc các thanh ghi đó,
bởi BIOS, bởi một số CPU đặc biệt hoặc bởi trình điều khiển Linux EDAC. Trên x86 64
CPU bit, những lỗi như vậy cũng có thể được truy xuất thông qua Kiểm tra máy
Kiến trúc (MCA)\ [#f3]_.

.. [#f1] Please notice that several memory controllers allow operation on a
  mode called "Lock-Step", where it groups two memory modules together,
  doing 128-bit reads/writes. That gives 16 bits for error correction, with
  significantly improves the error correction mechanism, at the expense
  that, when an error happens, there's no way to know what memory module is
  to blame. So, it has to blame both memory modules.

.. [#f2] Some memory controllers also allow using memory in mirror mode.
  On such mode, the same data is written to two memory modules. At read,
  the system checks both memory modules, in order to check if both provide
  identical data. On such configuration, when an error happens, there's no
  way to know what memory module is to blame. So, it has to blame both
  memory modules (or 4 memory modules, if the system is also on Lock-step
  mode).

.. [#f3] For more details about the Machine Check Architecture (MCA),
  please read Documentation/arch/x86/x86_64/machinecheck.rst at the Kernel tree.

EDAC - Phát hiện và sửa lỗi
*************************************

.. note::

   "bluesmoke" was the name for this device driver subsystem when it
   was "out-of-tree" and maintained at http://bluesmoke.sourceforge.net.
   That site is mostly archaic now and can be used only for historical
   purposes.

   When the subsystem was pushed upstream for the first time, on
   Kernel 2.6.16, it was renamed to ``EDAC``.

Mục đích
--------

Mục tiêu của mô-đun hạt nhân ZZ0000ZZ là phát hiện và báo cáo lỗi phần cứng
xảy ra trong hệ thống máy tính chạy Linux.

Ký ức
------

Lỗi có thể sửa được bộ nhớ (CE) và Lỗi không thể sửa được (UE) là
lỗi chính đang được thu thập. Những loại lỗi này được thu thập bởi
thiết bị ZZ0000ZZ.

Phát hiện các sự kiện CE, sau đó thu thập các sự kiện đó và báo cáo chúng,
ZZ0000ZZ nhưng không nhất thiết phải là yếu tố dự đoán các sự kiện UE trong tương lai. Với
Chỉ các sự kiện CE, hệ thống có thể và sẽ tiếp tục hoạt động khi không có dữ liệu
đã bị hư hỏng chưa.

Tuy nhiên, việc bảo trì phòng ngừa và thay thế bộ nhớ chủ động
các mô-đun trưng bày CE có thể làm giảm khả năng xảy ra các sự kiện UE đáng sợ
và sự hoảng loạn của hệ thống.

Các yếu tố phần cứng khác
-------------------------

Một tính năng mới cho EDAC, loại thiết bị ZZ0000ZZ, đã được thêm vào
phiên bản 2.6.23 của hạt nhân.

Loại thiết bị mới này cho phép loại máy dò phần cứng ECC không có bộ nhớ
để thu thập trạng thái của họ và hiển thị cho không gian người dùng thông qua sysfs
giao diện.

Một số kiến trúc có trình phát hiện ECC cho bộ đệm L1, L2 và L3,
cùng với động cơ DMA, công tắc vải, công tắc đường dẫn dữ liệu chính,
kết nối và các đường dẫn dữ liệu phần cứng khác nhau. Nếu phần cứng
báo cáo nó, thì một thiết bị edac_device có thể được xây dựng để
thu thập và trình bày nó cho không gian người dùng.


Quét xe buýt PCI
----------------

Ngoài ra, các thiết bị PCI được quét để tìm lỗi PCI Bus Parity và SERR.
để xác định xem có lỗi xảy ra trong quá trình truyền dữ liệu hay không.

Sự hiện diện của lỗi Chẵn lẻ PCI phải được kiểm tra kỹ càng.
Có một số bộ điều hợp bổ trợ thực hiện ZZ0000ZZ tuân theo thông số PCI
liên quan đến việc tạo và báo cáo chẵn lẻ. Thông số kỹ thuật nói
nhà cung cấp nên buộc các bit trạng thái chẵn lẻ về 0 nếu họ không có ý định
để tạo ra sự ngang bằng.  Một số nhà cung cấp không làm điều này và do đó bit chẵn lẻ
có thể "thả nổi" cho kết quả dương tính giả.

Có một thuộc tính thiết bị PCI nằm trong sysfs được kiểm tra bởi
mã quét EDAC PCI. Nếu thuộc tính đó được đặt, lỗi/chẵn lẻ PCI
quá trình quét bị bỏ qua đối với thiết bị đó. Thuộc tính là::

bị hỏng_parity_status

và nằm trong thư mục ZZ0000ZZ cho
Thiết bị PCI.


Phiên bản
----------

EDAC bao gồm một mô-đun "lõi" (ZZ0000ZZ) và một số bộ nhớ
Mô-đun trình điều khiển (MC). Trên một hệ thống nhất định, CORE được tải
và một trình điều khiển MC sẽ được tải. Cả CORE và trình điều khiển MC (hoặc
Trình điều khiển ZZ0001ZZ) có các phiên bản riêng lẻ phản ánh hiện tại
mức độ phát hành của các mô-đun tương ứng của họ.

Vì vậy, để "báo cáo" hệ thống đang chạy phiên bản nào, người ta phải báo cáo
cả phiên bản của trình điều khiển CORE và MC.


Đang tải
--------

Nếu ZZ0000ZZ được liên kết tĩnh với kernel thì không tải
là cần thiết. Nếu ZZ0001ZZ được xây dựng dưới dạng mô-đun thì chỉ cần modprobe
các mảnh ZZ0002ZZ mà bạn cần. Bạn sẽ có thể modprobe
các mô-đun dành riêng cho phần cứng và tải các phần phụ thuộc cần thiết
mô-đun cốt lõi.

Ví dụ::

$ modprobe amd76x_edac

tải cả mô-đun bộ điều khiển bộ nhớ ZZ0000ZZ và
Mô-đun lõi ZZ0001ZZ.


Giao diện hệ thống
------------------

EDAC trình bày giao diện ZZ0000ZZ cho mục đích kiểm soát và báo cáo. Nó
nằm trong thư mục /sys/devices/system/edac.

Trong thư mục này hiện có 2 thành phần:

========================================
	hệ thống điều khiển bộ nhớ mc
	hệ thống điều khiển và trạng thái pci PCI
	========================================



Model Bộ điều khiển bộ nhớ (mc)
-------------------------------

Mỗi thiết bị ZZ0000ZZ điều khiển một bộ mô-đun bộ nhớ [#f4]_. Các mô-đun này
được trình bày trong bảng Chip-Select Row (ZZ0001ZZ) và bảng Channel (ZZ0002ZZ).
Có thể có nhiều csrow và nhiều kênh.

.. [#f4] Nowadays, the term DIMM (Dual In-line Memory Module) is widely
  used to refer to a memory module, although there are other memory
  packaging alternatives, like SO-DIMM, SIMM, etc. The UEFI
  specification (Version 2.7) defines a memory module in the Common
  Platform Error Record (CPER) section to be an SMBIOS Memory Device
  (Type 17). Along this document, and inside the EDAC subsystem, the term
  "dimm" is used for all memory modules, even when they use a
  different kind of packaging.

Bộ điều khiển bộ nhớ cho phép nhiều csrow, với 8 csrow là một
giá trị điển hình. Tuy nhiên, số lượng csrow thực tế phụ thuộc vào cách bố trí của
bo mạch chủ, bộ điều khiển bộ nhớ và đặc điểm mô-đun bộ nhớ nhất định.

Kênh đôi cho phép độ dài dữ liệu kép (ví dụ: 128 bit, trên hệ thống 64 bit)
truyền dữ liệu đến/từ CPU từ/đến bộ nhớ. Một số chipset mới hơn cho phép
cho nhiều hơn 2 kênh, chẳng hạn như bộ nhớ DIMM được đệm đầy đủ (FB-DIMM)
bộ điều khiển. Ví dụ sau sẽ giả sử 2 kênh:

+-------------+--------------+
	Kênh ZZ0010ZZ |
	+-------------+----------+----------+
	ZZ0011ZZ ZZ0000ZZ ZZ0012ZZ
	+=============+=======================================================================================
	ZZ0013ZZZZ0006ZZZZ0014ZZ
	+-------------+----------+----------+
	ZZ0015ZZ xếp hạng0 ZZ0016ZZ
	+-------------+----------+----------+
	ZZ0017ZZ hạng1 ZZ0018ZZ
	+-------------+----------+----------+
	ZZ0019ZZZZ0008ZZZZ0020ZZ
	+-------------+----------+----------+
	ZZ0021ZZ xếp hạng0 ZZ0022ZZ
	+-------------+----------+----------+
	ZZ0023ZZ hạng1 ZZ0024ZZ
	+-------------+----------+----------+

Trong ví dụ trên, có 4 khe cắm vật lý trên bo mạch chủ
đối với DIMM bộ nhớ:

+----------+----------+
	ZZ0000ZZ DIMM_B0 |
	+----------+----------+
	ZZ0001ZZ DIMM_B1 |
	+----------+----------+

Nhãn cho các khe này thường được in lụa trên bo mạch chủ.
Các khe có nhãn ZZ0000ZZ là kênh 0 trong ví dụ này. Các khe có nhãn ZZ0001ZZ là
kênh 1. Lưu ý rằng có thể có hai csrow trên DIMM vật lý.
Các csrow này được phân bổ nhiệm vụ csrow dựa trên vị trí vào
nơi đặt bộ nhớ DIMM. Do đó, khi đặt 1 DIMM vào mỗi
Kênh, các csrow đi qua cả hai DIMM.

Bộ nhớ DIMM có dạng "xếp hạng" đơn hoặc kép. Thứ hạng là một csrow đông dân.
Trong ví dụ trên, 2 DIMM xếp hạng kép được đặt tương tự nhau. Như vậy,
cả csrow0 và csrow1 đều được điền. Mặt khác, khi 2 đĩa đơn
DIMM được xếp hạng được đặt trong các khe DIMM_A0 và DIMM_B0, sau đó chúng sẽ
chỉ có một csrow (csrow0) và csrow1 sẽ trống. mẫu
lặp lại chính nó cho csrow2 và csrow3. Cũng lưu ý rằng một số bộ nhớ
bộ điều khiển không có bất kỳ logic nào để xác định mô-đun bộ nhớ, hãy xem
Các thư mục ZZ0000ZZ bên dưới.

Sự thể hiện ở trên được phản ánh trong thư mục
cây trong giao diện sysfs của EDAC. Bắt đầu trong thư mục
ZZ0000ZZ, mỗi bộ điều khiển bộ nhớ sẽ
được đại diện bởi thư mục ZZ0001ZZ của chính nó, trong đó ZZ0002ZZ là
chỉ số của MC::

	..../edac/mc/
		   |
		   |->mc0
		   |->mc1
		   |->mc2
		   ....

Trong mỗi thư mục ZZ0000ZZ có một số điều khiển EDAC và
các tập tin thuộc tính.

Thư mục ZZ0000ZZ
-------------------

Trong thư mục ZZ0000ZZ là các tệp thuộc tính và điều khiển EDAC cho
phiên bản ZZ0001ZZ này của bộ điều khiển bộ nhớ.

Để biết mô tả về sysfs API, vui lòng xem:

Tài liệu/ABI/thử nghiệm/sysfs-devices-edac


Thư mục ZZ0000ZZ hoặc ZZ0001ZZ
----------------------------------

Cách được khuyến nghị để sử dụng hệ thống con EDAC là xem thông tin
được cung cấp bởi thư mục ZZ0000ZZ hoặc ZZ0001ZZ [#f5]_.

Một hệ thống EDAC điển hình có cấu trúc sau
ZZ0000ZZ\ [#f6]_::

/sys/thiết bị/hệ thống/edac/
	├──mc
	│   ├── mc0
	│   │   ├── ce_count
	│   │   ├── ce_noinfo_count
	│   │   ├── dimm0
	│   │   │   ├── dimm_ce_count
	│   │   │   ├── dimm_dev_type
	│   │   │   ├── dimm_edac_mode
	│   │   │   ├── dimm_label
	│   │   │   ├── dimm_location
	│   │   │   ├── dimm_mem_type
	│   │   │   ├── dimm_ue_count
	│   │   │   ├── kích thước
	│   │   │   └── sự kiện
	│   │   ├── max_location
	│   │   ├── mc_name
	│   │   ├── reset_counters
	│   │   ├── giây_since_reset
	│   │   ├── size_mb
	│   │   ├── ue_count
	│   │   ├── ue_noinfo_count
	│   │   └── sự kiện
	│   ├── mc1
	│   │   ├── ce_count
	│   │   ├── ce_noinfo_count
	│   │   ├── dimm0
	│   │   │   ├── dimm_ce_count
	│   │   │   ├── dimm_dev_type
	│   │   │   ├── dimm_edac_mode
	│   │   │   ├── dimm_label
	│   │   │   ├── dimm_location
	│   │   │   ├── dimm_mem_type
	│   │   │   ├── dimm_ue_count
	│   │   │   ├── kích thước
	│   │   │   └── sự kiện
	│   │   ├── max_location
	│   │   ├── mc_name
	│   │   ├── reset_counters
	│   │   ├── giây_since_reset
	│   │   ├── size_mb
	│   │   ├── ue_count
	│   │   ├── ue_noinfo_count
	│   │   └── sự kiện
	│   └── sự kiện
	└── sự kiện

Trong thư mục ZZ0000ZZ là các tệp thuộc tính và điều khiển EDAC cho
mô-đun bộ nhớ ZZ0001ZZ này:

- ZZ0000ZZ - Tổng bộ nhớ được quản lý bởi tệp thuộc tính csrow này

Tệp thuộc tính này hiển thị, theo số megabyte, bộ nhớ
	mà csrow này chứa.

- ZZ0000ZZ - Tệp thuộc tính đếm lỗi không thể sửa được

Tệp thuộc tính này hiển thị tổng số lỗi không thể sửa được
	các lỗi đã xảy ra trên DIMM này. Nếu hoảng loạn_on_ue được đặt
	bộ đếm này sẽ không có cơ hội tăng vì EDAC
	sẽ làm hệ thống hoảng sợ.

- ZZ0000ZZ - Tệp thuộc tính đếm lỗi có thể sửa được

Tệp thuộc tính này hiển thị tổng số có thể sửa được
	các lỗi đã xảy ra trên DIMM này. Con số này rất
	quan trọng để kiểm tra. CE cung cấp những dấu hiệu sớm cho thấy một
	DIMM đang bắt đầu thất bại. Trường đếm này phải là
	được theo dõi các giá trị khác 0 và báo cáo thông tin đó
	tới người quản trị hệ thống.

- ZZ0000ZZ - Tệp thuộc tính loại thiết bị

Tệp thuộc tính này sẽ hiển thị loại thiết bị DRAM là gì
	đang được sử dụng trên DIMM này.
	Ví dụ:

- x1
		- x2
		- x4
		- x8

- ZZ0000ZZ - EDAC Tệp thuộc tính chế độ hoạt động

Tệp thuộc tính này sẽ hiển thị loại Phát hiện lỗi nào
	và sự điều chỉnh đang được sử dụng.

- ZZ0000ZZ - tập tin kiểm soát nhãn mô-đun bộ nhớ

Tệp điều khiển này cho phép DIMM này được gán nhãn
	đến nó. Với nhãn này trong mô-đun, khi xảy ra lỗi
	đầu ra có thể cung cấp nhãn DIMM trong nhật ký hệ thống.
	Điều này trở nên quan trọng đối với các sự kiện hoảng loạn để cô lập
	nguyên nhân của sự kiện UE.

Nhãn DIMM phải được gán sau khi khởi động, kèm theo thông tin
	xác định chính xác khe cắm vật lý với
	nhãn lụa. Thông tin này hiện rất
	bo mạch chủ cụ thể và xác định thông tin này
	phải xảy ra trong vùng người dùng vào thời điểm này.

- ZZ0000ZZ - vị trí của mô-đun bộ nhớ

Vị trí có thể có tối đa 3 cấp độ và mô tả cách thức
	bộ điều khiển bộ nhớ xác định vị trí của mô-đun bộ nhớ.
	Tùy thuộc vào loại bộ nhớ và bộ điều khiển bộ nhớ, nó
	có thể là:

- ZZ0001ZZ và ZZ0002ZZ - được sử dụng khi bộ điều khiển bộ nhớ
		  không xác định một DIMM - e. g. trong thư mục ZZ0000ZZ;
		- ZZ0003ZZ, ZZ0004ZZ, ZZ0005ZZ - thường được sử dụng trên bộ nhớ FB-DIMM
		  bộ điều khiển;
		- ZZ0006ZZ, ZZ0007ZZ - được sử dụng trên Nehalem và trình điều khiển Intel mới hơn.

- ZZ0000ZZ - Tệp thuộc tính loại bộ nhớ

Tệp thuộc tính này sẽ hiển thị loại bộ nhớ hiện tại
	trên csrow này. Thông thường, bộ nhớ được đệm hoặc không có bộ đệm.
	Ví dụ:

- Đã đăng ký-DDR
		- Không có bộ đệm-DDR

.. [#f5] On some systems, the memory controller doesn't have any logic
  to identify the memory module. On such systems, the directory is called ``rankX``.
  On modern Intel memory controllers, the memory controller identifies the
  memory modules directly. On such systems, the directory is called ``dimmX``.

.. [#f6] There are also some ``power`` directories and ``subsystem``
  symlinks inside the sysfs mapping that are automatically created by
  the sysfs subsystem. Currently, they serve no purpose.


Ghi nhật ký hệ thống
--------------------

Nếu tính năng ghi nhật ký cho UE và CE được bật thì nhật ký hệ thống sẽ chứa
thông tin cho biết lỗi đã được phát hiện::

EDAC MC0: Trang CE 0x283, offset 0xce0, hạt 8, hội chứng 0x6ec3, hàng 0, kênh 1 "DIMM_B1": amd76x_edac
  EDAC MC0: Trang CE 0x1e5, offset 0xfb0, hạt 8, hội chứng 0xb741, hàng 0, kênh 1 "DIMM_B1": amd76x_edac


Cấu trúc của tin nhắn là:

+---------------------------------------+-------------+
	Ví dụ ZZ0000ZZ |
	+============================================================+
	ZZ0001ZZ MC0 |
	+---------------------------------------+-------------+
	ZZ0002ZZ CE |
	+---------------------------------------+-------------+
	ZZ0003ZZ 0x283 |
	+---------------------------------------+-------------+
	ZZ0004ZZ 0xce0 |
	+---------------------------------------+-------------+
	ZZ0005ZZ hạt 8 |
	ZZ0006ZZ |
	+---------------------------------------+-------------+
	ZZ0007ZZ 0xb741 |
	+---------------------------------------+-------------+
	ZZ0008ZZ hàng 0 |
	+---------------------------------------+-------------+
	ZZ0009ZZ kênh 1 |
	+---------------------------------------+-------------+
	ZZ0010ZZ DIMM B1 |
	+---------------------------------------+-------------+
	ZZ0011ZZ |
	ZZ0012ZZ |
	ZZ0013ZZ |
	+---------------------------------------+-------------+

Cả UE và CE không có thông tin sẽ thiếu tất cả ngoại trừ bộ điều khiển bộ nhớ, lỗi
loại, thông báo "không có thông tin" và sau đó là lỗi tùy chọn, dành riêng cho trình điều khiển
tin nhắn.


Phát hiện chẵn lẻ bus PCI
-------------------------

Trên các thiết bị Loại tiêu đề 00, trạng thái chính được xem xét cho bất kỳ
lỗi chẵn lẻ bất kể tính chẵn lẻ có được bật trên thiết bị hay không
không. (Thông số kỹ thuật cho biết tính chẵn lẻ được tạo ra trong một số trường hợp). Trên tiêu đề
Cầu loại 01, thanh ghi trạng thái thứ cấp cũng được nhìn vào để xem
nếu sự chẵn lẻ xảy ra trên xe buýt ở phía bên kia cầu.


Cấu hình hệ thống
-------------------

Trong ZZ0000ZZ là các tệp điều khiển và thuộc tính như
sau:


- ZZ0000ZZ - Bật/Tắt PCI Tệp kiểm soát kiểm tra chẵn lẻ

Tệp điều khiển này kích hoạt hoặc vô hiệu hóa chức năng quét chẵn lẻ bus PCI
	hoạt động. Viết số 1 vào tệp này sẽ cho phép quét. Viết
	số 0 cho tệp này sẽ vô hiệu hóa quá trình quét.

Cho phép::

echo "1" >/sys/devices/system/edac/pci/check_pci_parity

Vô hiệu hóa::

echo "0" >/sys/devices/system/edac/pci/check_pci_parity


- ZZ0000ZZ - Đếm chẵn lẻ

Tệp thuộc tính này sẽ hiển thị số lỗi chẵn lẻ
	đã được phát hiện.


Thông số mô-đun
-----------------

- ZZ0000ZZ - Hoảng loạn trên file điều khiển UE

Một lỗi không thể sửa được sẽ khiến máy hoảng loạn.  Đây thường là
	mong muốn.  Sẽ là một ý tưởng tồi nếu tiếp tục khi có một lỗi không thể sửa được
	xảy ra - không xác định được điều gì chưa được sửa chữa và hoạt động
	bối cảnh hệ thống có thể bị xáo trộn đến mức việc tiếp tục sẽ dẫn đến nhiều hậu quả hơn nữa.
	tham nhũng. Nếu kernel có cấu hình MCE thì EDAC sẽ không bao giờ
	để ý UE.

LOAD TIME::

tham số mô-đun/hạt nhân: edac_mc_panic_on_ue=[0|1]

RUN TIME::

echo "1" > /sys/module/edac_core/parameters/edac_mc_panic_on_ue


- ZZ0000ZZ - Đăng nhập file điều khiển UE


Tạo thông báo kernel mô tả các lỗi không thể sửa được.  Những lỗi này
	được báo cáo thông qua hệ thống nhật ký tin nhắn hệ thống.  thống kê UE
	sẽ được tích lũy ngay cả khi việc ghi nhật ký UE bị vô hiệu hóa.

LOAD TIME::

tham số mô-đun/hạt nhân: edac_mc_log_ue=[0|1]

RUN TIME::

echo "1" > /sys/module/edac_core/parameters/edac_mc_log_ue


- ZZ0000ZZ - Log file control CE


Tạo thông báo kernel mô tả các lỗi có thể sửa được.  Những cái này
	lỗi được báo cáo thông qua hệ thống nhật ký tin nhắn hệ thống.
	Số liệu thống kê CE sẽ được tích lũy ngay cả khi tính năng ghi nhật ký CE bị tắt.

LOAD TIME::

tham số mô-đun/hạt nhân: edac_mc_log_ce=[0|1]

RUN TIME::

echo "1" > /sys/module/edac_core/parameters/edac_mc_log_ce


- ZZ0000ZZ - Tệp kiểm soát thời gian bỏ phiếu


Khoảng thời gian tính bằng mili giây để thăm dò thông tin lỗi.
	Giá trị quá nhỏ sẽ gây lãng phí tài nguyên.  Giá trị quá lớn có thể bị trì hoãn
	xử lý các lỗi cần thiết và có thể làm mất thông tin có giá trị cho
	định vị lỗi.  1000 mili giây (mỗi giây một lần) là hiện tại
	mặc định. Các hệ thống yêu cầu tất cả băng thông có thể có được, có thể
	tăng điều này.

LOAD TIME::

tham số mô-đun/hạt nhân: edac_mc_poll_msec=[0|1]

RUN TIME::

echo "1000" > /sys/module/edac_core/parameters/edac_mc_poll_msec


- ZZ0000ZZ - Lỗi PCI PARITY


Tệp điều khiển này cho phép hoặc vô hiệu hóa sự hoảng loạn khi tính chẵn lẻ
	lỗi đã được phát hiện.


tham số mô-đun/hạt nhân::

edac_panic_on_pci_pe=[0|1]

Cho phép::

echo "1" > /sys/module/edac_core/parameters/edac_panic_on_pci_pe

Vô hiệu hóa::

echo "0" > /sys/module/edac_core/parameters/edac_panic_on_pci_pe



Loại thiết bị EDAC
------------------

Trong tệp tiêu đề, edac_pci.h, có một loạt cấu trúc edac_device
và API cho EDAC_DEVICE.

Quyền truy cập không gian người dùng vào edac_device thông qua giao diện sysfs.

Tại vị trí ZZ0000ZZ (sysfs) thiết bị edac_device mới
sẽ xuất hiện.

Có một cây ba cấp bên dưới thư mục ZZ0000ZZ ở trên. Ví dụ,
thiết bị ZZ0001ZZ (được tìm thấy tại ZZ0002ZZ
website) tự cài đặt dưới dạng::

/sys/devices/system/edac/test-instance

trong thư mục này có nhiều điều khiển khác nhau, một liên kết tượng trưng và một hoặc nhiều ZZ0000ZZ
thư mục.

Các điều khiển mặc định tiêu chuẩn là:

===========================================================================
	log_ce boolean để ghi lại các sự kiện CE
	log_ue boolean để ghi lại các sự kiện UE
	Panic_on_ue boolean thành ZZ0000ZZ hệ thống nếu gặp UE
			(mặc định tắt, có thể được đặt thành true thông qua tập lệnh khởi động)
	khoảng thời gian poll_msec giữa các chu kỳ POLL cho các sự kiện
	===========================================================================

Thiết bị test_device_edac thêm ít nhất một điều khiển tùy chỉnh của riêng nó:

======================================================================
	test_bits mà trong trình điều khiển kiểm tra hiện tại không làm gì khác ngoài
			chỉ ra cách nó được cài đặt. Một trình điều khiển được chuyển có thể
			thêm một hoặc nhiều điều khiển và/hoặc thuộc tính như vậy
			cho những mục đích sử dụng cụ thể.
			Một trình điều khiển ngoài cây sử dụng các điều khiển ở đây để cho phép
			cho các hoạt động ERROR INJECTION cho phần cứng
			đăng ký tiêm
	======================================================================

Liên kết tượng trưng trỏ đến 'struct dev' được đăng ký cho edac_device này.

trường hợp
----------

Có một hoặc nhiều thư mục phiên bản. Dành cho ZZ0000ZZ
trường hợp:

+----------------+
	ZZ0000ZZ
	+----------------+


Trong thư mục này có hai thuộc tính bộ đếm mặc định, là tổng của
counter trong các thư mục con sâu hơn.

======================================================
	ce_count tổng số sự kiện CE của thư mục con
	ue_count tổng số sự kiện UE của thư mục con
	======================================================

Khối
------

Ở cấp thư mục thấp nhất là thư mục ZZ0000ZZ. Có thể có 0, 1
hoặc nhiều khối được chỉ định trong mỗi trường hợp:

+-------------+
	ZZ0000ZZ
	+-------------+

Trong thư mục này các thuộc tính mặc định là:

====================================================================
	ce_count là bộ đếm các sự kiện CE cho ZZ0000ZZ này
			phần cứng đang được giám sát
	ue_count là bộ đếm các sự kiện UE cho ZZ0001ZZ này
			phần cứng đang được giám sát
	====================================================================


Thiết bị ZZ0000ZZ bổ sung thêm 4 thuộc tính và 1 điều khiển:

============================================================================
	test-block-bits-0 cho mỗi chu kỳ POLL bộ đếm này
				được tăng lên
	test-block-bits-1 cứ sau 10 chu kỳ, bộ đếm này bị va chạm một lần,
				và test-block-bits-0 được đặt thành 0
	test-block-bit-2 cứ sau 100 chu kỳ, bộ đếm này bị va chạm một lần,
				và test-block-bit-1 được đặt thành 0
	test-block-bits-3 cứ sau 1000 chu kỳ, bộ đếm này bị va chạm một lần,
				và test-block-bit-2 được đặt thành 0
	============================================================================


============================================================================
	bộ đếm đặt lại ghi nội dung ANY vào điều khiển này sẽ
				thiết lập lại tất cả các bộ đếm trên.
	============================================================================


Việc sử dụng trình điều khiển ZZ0000ZZ sẽ cho phép bất kỳ người nào khác tạo trình điều khiển của riêng họ
trình điều khiển duy nhất cho hệ thống phần cứng của họ.

Trình điều khiển mẫu ZZ0000ZZ được đặt tại
Trang web dự án ZZ0001ZZ cho EDAC.


Việc sử dụng API EDAC trên Nehalem và các CPU Intel mới hơn
-----------------------------------------------------------

Trên các kiến trúc Intel cũ hơn, bộ điều khiển bộ nhớ là một phần của North
Chipset cầu. Nehalem, Cầu Sandy, Cầu Ivy, Haswell, Sky Lake và
kiến trúc Intel mới hơn tích hợp phiên bản bộ nhớ nâng cao
bộ điều khiển (MC) bên trong CPU.

Chương này sẽ đề cập đến sự khác biệt của bộ điều khiển bộ nhớ nâng cao
được tìm thấy trên các CPU Intel mới hơn, chẳng hạn như ZZ0000ZZ, ZZ0001ZZ và
Trình điều khiển ZZ0002ZZ.

.. note::

   The Xeon E7 processor families use a separate chip for the memory
   controller, called Intel Scalable Memory Buffer. This section doesn't
   apply for such families.

1) Có một Bộ điều khiển bộ nhớ cho mỗi Kết nối bản vá nhanh
   (QPI). Ở trình điều khiển, thuật ngữ "ổ cắm" có nghĩa là một QPI. Đây là
   được liên kết với ổ cắm CPU vật lý.

Mỗi MC có 3 kênh đọc vật lý, 3 kênh ghi vật lý và
   3 kênh logic. Trình điều khiển hiện chỉ xem nó là 3 kênh.
   Mỗi kênh có thể có tối đa 3 DIMM.

Sự thống nhất tối thiểu được biết đến là DIMM. Không có thông tin về csrows.
   Khi EDAC API ánh xạ đơn vị tối thiểu là csrows, trình điều khiển tuần tự
   ánh xạ kênh/DIMM vào các csrow khác nhau.

Ví dụ: giả sử bố cục sau::

Ch0 phy rd0, wr0 (0x063f4031): 2 cấp, UDIMM
	  dimm 0 1024 Mb offset: 0, ngân hàng: 8, cấp bậc: 1, hàng: 0x4000, col: 0x400
	  dimm 1 1024 Mb offset: 4, ngân hàng: 8, cấp bậc: 1, hàng: 0x4000, col: 0x400
        Ch1 phy rd1, wr1 (0x063f4031): 2 cấp, UDIMM
	  dimm 0 1024 Mb offset: 0, ngân hàng: 8, cấp bậc: 1, hàng: 0x4000, col: 0x400
	Ch2 phy rd3, wr3 (0x063f4031): 2 cấp, UDIMM
	  dimm 0 1024 Mb offset: 0, ngân hàng: 8, cấp bậc: 1, hàng: 0x4000, col: 0x400

Trình điều khiển sẽ ánh xạ nó dưới dạng ::

csrow0: kênh 0, dimm0
	csrow1: kênh 0, dimm1
	csrow2: kênh 1, dimm0
	csrow3: kênh 2, dimm0

xuất một DIMM mỗi csrow.

Mỗi QPI được xuất dưới dạng bộ điều khiển bộ nhớ khác nhau.

2) MC có khả năng đưa ra lỗi cho người lái thử. Các tài xế
   thực hiện chức năng này thông qua một số nút tiêm lỗi:

Để đưa vào một lỗi bộ nhớ, có một số nút sysfs, bên dưới
   ZZ0000ZZ:

-ZZ0000ZZ:
      Kiểm soát thanh ghi mặt nạ tiêm lỗi. Có thể chỉ định
      một số đặc điểm của địa chỉ để khớp với mã lỗi::

dimm = dimm bị ảnh hưởng. Các con số có liên quan đến một kênh;
         thứ hạng = thứ hạng bộ nhớ;
         kênh = kênh sẽ phát sinh lỗi;
         ngân hàng = ngân hàng bị ảnh hưởng;
         trang = địa chỉ trang;
         cột (hoặc col) = cột địa chỉ.

mỗi giá trị trên có thể được đặt thành "bất kỳ" để khớp với bất kỳ giá trị hợp lệ nào.

Tại trình điều khiển init, tất cả các giá trị được đặt thành bất kỳ.

Ví dụ: để tạo ra lỗi ở cấp 1 của dimm 2 cho bất kỳ kênh nào,
      bất kỳ ngân hàng nào, bất kỳ trang nào, bất kỳ cột nào::

echo 2 >/sys/devices/system/edac/mc/mc0/inject_addrmatch/dimm
		echo 1 >/sys/devices/system/edac/mc/mc0/inject_addrmatch/rank

Để quay lại hành vi mặc định khớp với bất kỳ, bạn có thể thực hiện ::

lặp lại bất kỳ >/sys/devices/system/edac/mc/mc0/inject_addrmatch/dimm
		lặp lại bất kỳ >/sys/devices/system/edac/mc/mc0/inject_addrmatch/rank

-ZZ0000ZZ:
          chỉ định những bit nào sẽ gặp rắc rối,

-ZZ0000ZZ:
       chỉ định phần bộ đệm ECC nào sẽ gặp lỗi ::

3 cho cả hai
		2 cho mức cao nhất
		1 cho mức thấp nhất

-ZZ0000ZZ:
       chỉ định loại lỗi, là sự kết hợp của các bit sau::

bit 0 - lặp lại
		bit 1 - ecc
		bit 2 - tính chẵn lẻ

-ZZ0000ZZ:
       bắt đầu tạo lỗi khi có giá trị khác 0 được ghi.

Tất cả các vars tiêm có thể được đọc. cần có quyền root để viết.

Bảng dữ liệu cho biết rằng lỗi sẽ chỉ được tạo ra sau khi ghi vào một
   địa chỉ khớp với tiêm_addrmatch. Tuy nhiên, có vẻ như việc đọc sẽ
   cũng gây ra lỗi.

Ví dụ: đoạn mã sau sẽ tạo ra lỗi đối với bất kỳ quyền truy cập ghi nào
   tại socket 0, trên bất kỳ DIMM/địa chỉ nào trên kênh 2::

echo 2 >/sys/devices/system/edac/mc/mc0/inject_addrmatch/channel
	echo 2 >/sys/devices/system/edac/mc/mc0/inject_type
	echo 64 >/sys/devices/system/edac/mc/mc0/inject_eccmask
	echo 3 >/sys/devices/system/edac/mc/mc0/inject_section
	echo 1 >/sys/devices/system/edac/mc/mc0/inject_enable
	dd if=/dev/mem of=/dev/null seek=16k bs=4k count=1 >& /dev/null

Đối với socket 1 cần thay “mc0” bằng “mc1” ở trên
   lệnh.

Thông báo lỗi được tạo sẽ có dạng::

EDAC MC0: Hàng UE 0, kênh-a= 0 kênh-b= 0 nhãn "-": NON_FATAL (addr = 0x0075b980, ổ cắm=0, Dimm=0, Kênh=2, hội chứng=0x00000040, count=1, Err=8c0000400001009f:4000080482 (lỗi đọc: lỗi đọc ECC))

3) Đã sửa lỗi bộ đếm thanh ghi bộ nhớ

Những MC mới hơn có một số thanh ghi để đếm lỗi bộ nhớ. Người lái xe
   sử dụng các sổ đăng ký đó để báo cáo Lỗi đã sửa trên các thiết bị có Đã đăng ký
   DIMM.

Tuy nhiên, những bộ đếm đó không hoạt động với DIMM chưa đăng ký. Là chipset
   cung cấp một số bộ đếm cũng hoạt động với UDIMM (nhưng với mức độ kém hơn
   chi tiết hơn các giá trị mặc định), trình điều khiển sẽ hiển thị các thanh ghi đó cho
   Bộ nhớ UDIMM.

Chúng có thể được đọc bằng cách xem nội dung của ZZ0000ZZ::

$ cho tôi trong /sys/devices/system/edac/mc/mc0/all_channel_counts/*; làm tiếng vang $i; mèo $i; xong
	/sys/devices/system/edac/mc/mc0/all_channel_counts/udimm0
	0
	/sys/devices/system/edac/mc/mc0/all_channel_counts/udimm1
	0
	/sys/devices/system/edac/mc/mc0/all_channel_counts/udimm2
	0

Điều xảy ra ở đây là lỗi trên các csrow khác nhau, nhưng cùng một lúc
   số dimm sẽ tăng cùng một bộ đếm.
   Vì vậy, trong ánh xạ bộ nhớ này::

csrow0: kênh 0, dimm0
	csrow1: kênh 0, dimm1
	csrow2: kênh 1, dimm0
	csrow3: kênh 2, dimm0

Phần cứng sẽ tăng udimm0 nếu có lỗi ở mức độ mờ đầu tiên
   csrow0, csrow2 hoặc csrow3;

Phần cứng sẽ tăng udimm1 nếu có lỗi ở mức độ mờ thứ hai
   csrow0, csrow2 hoặc csrow3;

Phần cứng sẽ tăng udimm2 khi có lỗi ở mức độ mờ thứ ba
   csrow0, csrow2 hoặc csrow3;

4) Bộ đếm lỗi tiêu chuẩn

Bộ đếm lỗi tiêu chuẩn được tạo khi nhận được lỗi mcelog
   bởi người lái xe. Vì với UDIMM, điều này được tính bằng phần mềm nên
   có thể một số lỗi có thể bị mất. Với RDIMM, chúng hiển thị
   nội dung của các sổ đăng ký

Tài liệu tham khảo sử dụng trên ZZ0000ZZ
------------------------------------------

Mô-đun ZZ0000ZZ dựa trên các tài liệu sau
(có sẵn từ ZZ0001ZZ

1. :Tiêu đề: BIOS và Hướng dẫn dành cho nhà phát triển hạt nhân dành cho AMD Athlon 64 và AMD
	   Bộ xử lý Opteron
   :AMD ấn phẩm #: 26094
   :Bản sửa đổi: 3.26
   :Liên kết: ZZ0000ZZ

2. :Tiêu đề: BIOS và Hướng dẫn dành cho nhà phát triển hạt nhân dành cho dòng AMD NPT 0Fh
	   Bộ xử lý
   :AMD ấn bản #: 32559
   :Bản sửa đổi: 3.00
   :Ngày phát hành: Tháng 5 năm 2006
   :Liên kết: ZZ0000ZZ

3. :Tiêu đề: BIOS và Hướng dẫn dành cho nhà phát triển hạt nhân (BKDG) dành cho dòng AMD 10h
	   Bộ xử lý
   :AMD ấn phẩm #: 31116
   :Bản sửa đổi: 3.00
   :Ngày phát hành: 07 tháng 9 năm 2007
   :Liên kết: ZZ0000ZZ

4. :Tiêu đề: BIOS và Hướng dẫn dành cho nhà phát triển hạt nhân (BKDG) dành cho dòng AMD 15h
	  Model Bộ xử lý 30h-3Fh
   :AMD ấn phẩm #: 49125
   :Bản sửa đổi: 3.06
   :Ngày phát hành: 12/2/2015 (bản phát hành mới nhất)
   :Liên kết: ZZ0000ZZ

5. :Tiêu đề: BIOS và Hướng dẫn dành cho nhà phát triển hạt nhân (BKDG) dành cho dòng AMD 15h
	  Bộ xử lý 60h-6Fh
   :AMD ấn phẩm #: 50742
   :Bản sửa đổi: 3.01
   :Ngày phát hành: 23/7/2015 (bản phát hành mới nhất)
   :Liên kết: ZZ0000ZZ

6. :Tiêu đề: BIOS và Hướng dẫn dành cho nhà phát triển hạt nhân (BKDG) dành cho dòng AMD 16h
	  Model Bộ xử lý 00h-0Fh
   :AMD ấn phẩm #: 48751
   :Bản sửa đổi: 3.03
   :Ngày phát hành: 23/2/2015 (bản phát hành mới nhất)
   :Liên kết: ZZ0000ZZ

Tín dụng
========

* Viết bởi Doug Thompson <dougthompson@xmission.com>

- 7 tháng 12 năm 2005
  - Ngày 17 tháng 7 năm 2007 Đã cập nhật

* ZZ0000ZZ Mauro Carvalho Chehab

- Ngày 05 tháng 8 năm 2009 Giao diện Nehalem
  - 26 tháng 10 năm 2016 Chuyển đổi sang ReST và dọn dẹp tại khu vực Nehalem

* Tác giả/người bảo trì EDAC:

- Doug Thompson, Dave Jiang, Dave Peterson và cộng sự,
  - Mauro Carvalho Chehab
  - Borislav Petkov
  - tác giả gốc: Thayne Harbaugh