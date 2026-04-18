.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hid/intel-thc-hid.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================================
Bộ điều khiển máy chủ cảm ứng Intel (THC)
=========================================

Bộ điều khiển máy chủ cảm ứng là tên của khối IP trong PCH có giao diện với Thiết bị cảm ứng (ví dụ:
màn hình cảm ứng, bàn di chuột, v.v.). Nó bao gồm 3 khối chức năng chính:

- SPI Master có khả năng I/O Quad I/O bán song công nguyên bản
- Giao diện I2C có độ trễ thấp để hỗ trợ các thiết bị tương thích HIDI2C
- Trình sắp xếp CTNH có khả năng RW DMA vào bộ nhớ hệ thống

Nó có một không gian gốc IOSF Giao diện chính hỗ trợ các giao dịch đến/từ các thiết bị cảm ứng.
Trình điều khiển máy chủ định cấu hình và điều khiển các thiết bị cảm ứng qua giao diện THC. THC cung cấp cao
cung cấp băng thông DMA tới trình điều khiển cảm ứng và chuyển báo cáo HID sang bộ nhớ chính của hệ thống máy chủ.

Trình sắp xếp phần cứng trong THC chịu trách nhiệm truyền dữ liệu (thông qua DMA) từ các thiết bị cảm ứng
vào bộ nhớ hệ thống. Bộ đệm vòng được sử dụng để tránh mất dữ liệu do tính chất không đồng bộ của dữ liệu
mức tiêu thụ (theo máy chủ) liên quan đến việc sản xuất dữ liệu (bằng thiết bị cảm ứng qua DMA).

Không giống như các bộ điều khiển SPI/I2C thông thường khác, THC xử lý việc ngắt và đặt lại dữ liệu của thiết bị HID
tín hiệu trực tiếp.

1. Tổng quan
============

1.1 Ngăn xếp phần mềm/phần cứng THC
-----------------------------------

Sơ đồ bên dưới minh họa kiến trúc cấp cao của ngăn xếp phần mềm/phần cứng THC, hoàn toàn
có khả năng hỗ trợ giao thức HIDSPI/HIDI2C trong hệ điều hành Linux.

::

----------------------------------------------
 ZZ0000ZZ
 ZZ0001ZZ Thiết bị đầu vào ZZ0002ZZ
 ZZ0003ZZ
 ZZ0004ZZ
 ZZ0005ZZ HID Trình điều khiển cảm ứng đa điểm ZZ0006ZZ
 ZZ0007ZZ
 ZZ0008ZZ
 ZZ0009ZZ HID Lõi ZZ0010ZZ
 ZZ0011ZZ
 ZZ0012ZZ
 Trình điều khiển ZZ0013ZZ THC QuickSPI/QuickI2C ZZ0014ZZ
 ZZ0015ZZ
 ZZ0016ZZ
 Trình điều khiển phần cứng ZZ0017ZZ THC ZZ0018ZZ
 ZZ0019ZZ
 ZZ0020ZZ
 Trình điều khiển xe buýt ZZ0021ZZ PCI ZZ0022ZZ ACPI Tài nguyên ZZ0023ZZ
 ZZ0024ZZ
  ----------------------------------------------
  ----------------------------------------------
 ZZ0025ZZ
 ZZ0026ZZ PCI Xe buýt ZZ0027ZZ
 ZZ0028ZZ
 ZZ0029ZZ
 Bộ điều khiển ZZ0030ZZ THC ZZ0031ZZ
 ZZ0032ZZ
 ZZ0033ZZ
 IC cảm ứng ZZ0034ZZ ZZ0035ZZ
 ZZ0036ZZ
  ----------------------------------------------

Touch IC (TIC) hay còn gọi là thiết bị Touch (màn hình cảm ứng hoặc bàn di chuột). Analog rời rạc
các thành phần cảm nhận và truyền dữ liệu cảm ứng rời rạc hoặc dữ liệu bản đồ nhiệt ở dạng HID
báo cáo qua bus SPI/I2C tới Bộ điều khiển THC trên máy chủ.

Bộ điều khiển máy chủ THC, là thiết bị PCI HBA (bộ điều hợp bus máy chủ), được tích hợp vào PCH,
đóng vai trò là cầu nối giữa Touch IC và máy chủ.

Trình điều khiển phần cứng THC, cung cấp API vận hành phần cứng THC cho trình điều khiển QuickSPI/QuickI2C ở trên, nó
truy cập các thanh ghi THC MMIO để định cấu hình và điều khiển phần cứng THC.

Trình điều khiển THC QuickSPI/QuickI2C, còn được gọi là trình điều khiển HIDSPI/HIDI2C, được đăng ký là HID
trình điều khiển cấp thấp quản lý Bộ điều khiển THC và thực hiện giao thức HIDSPI/HIDI2C.


1.2 Sơ đồ phần cứng THC
------------------------
Sơ đồ bên dưới hiển thị các thành phần phần cứng THC ::

----------------------------------
                     ZZ0000ZZ
                     ZZ0001ZZ
                     ZZ0002ZZ PCI Không gian cấu hình ZZ0003ZZ
                     ZZ0004ZZ
                     ZZ0005ZZ
                     ZZ0006ZZ |
                     ZZ0007ZZ
 +--------------+ ZZ0008ZZ
 ZZ0009ZZ ZZ0010ZZ |
 +--------------+ ZZ0011ZZ
                     ZZ0012ZZ
                     Bộ tuần tự HW ZZ0013ZZ ZZ0014ZZ
                     ZZ0015ZZ
                     ZZ0016ZZ
                     ZZ0017ZZ SPI/I2C ZZ0018ZZ GPIO ZZ0019ZZ
                     Bộ điều khiển ZZ0020ZZ Bộ điều khiển ZZ0021ZZ Bộ điều khiển ZZ0022ZZ
                     ZZ0023ZZ
                      ----------------------------------

Vì THC được hiển thị dưới dạng thiết bị PCI nên nó có các thanh ghi không gian cấu hình PCI tiêu chuẩn cho PCI
liệt kê và cấu hình.

Các thanh ghi MMIO, cung cấp quyền truy cập các thanh ghi cho trình điều khiển để định cấu hình và điều khiển phần cứng THC,
các thanh ghi bao gồm một số danh mục: Trạng thái và điều khiển ngắt, cấu hình DMA,
Trạng thái và điều khiển PIO (I/O được lập trình, được xác định trong phần 3.2), cấu hình bus SPI, I2C subIP
trạng thái và điều khiển, đặt lại trạng thái và điều khiển...

THC cung cấp hai cách để trình điều khiển giao tiếp với IC cảm ứng bên ngoài: PIO và DMA.
PIO có thể cho phép trình điều khiển ghi/đọc dữ liệu đến/từ Touch IC theo cách thủ công, thay vào đó, THC DMA có thể
tự động ghi/đọc dữ liệu mà không cần đến driver.

Bộ tuần tự HW bao gồm logic chính THC, nó nhận lệnh từ các thanh ghi MMIO để điều khiển
Bus SPI và bus I2C để hoàn tất giao dịch dữ liệu bus, nó cũng có thể tự động xử lý
IC cảm ứng ngắt và khởi động DMA nhận/gửi dữ liệu từ/đến IC cảm ứng theo ngắt
loại. Điều đó có nghĩa là THC HW Sequencer hiểu giao thức truyền HIDSPI/HIDI2C và xử lý
giao tiếp không cần có trình điều khiển, điều mà trình điều khiển cần làm chỉ là cấu hình THC
đúng cách và chuẩn bị gói dữ liệu được định dạng hoặc xử lý gói dữ liệu nhận được.

Vì THC hỗ trợ các giao thức HIDSPI/HIDI2C nên nó có bộ điều khiển SPI và I2C subIP trong đó để hiển thị
Xe buýt SPI và xe buýt I2C. THC cũng tích hợp bộ điều khiển GPIO để cung cấp hỗ trợ đường dây ngắt
và thiết lập lại hỗ trợ dòng.

2. Giao diện phần cứng THC
==========================

2.1 Giao diện máy chủ
---------------------

THC được hiển thị dưới dạng "thiết bị số hóa PCI" đối với máy chủ. ID thiết bị và sản phẩm PCI là
thay đổi từ các thế hệ bộ xử lý khác nhau. Vì vậy, mã nguồn liệt kê các trình điều khiển
cần cập nhật từ thế hệ này sang thế hệ khác.


2.2 Giao diện thiết bị
----------------------

THC hỗ trợ hai loại bus cho kết nối Touch IC: Bus SPI nâng cao và bus I2C.

2.2.1 Cổng SPI
~~~~~~~~~~~~~~

Khi PORT_TYPE = 00b trong thanh ghi MMIO, THC sử dụng giao diện SPI để giao tiếp với bên ngoài
Chạm vào IC. THC Bus SPI nâng cao hỗ trợ các chế độ SPI khác nhau: chế độ IO đơn tiêu chuẩn,
Chế độ IO kép và chế độ Quad IO.

Ở chế độ IO đơn, THC điều khiển dòng MOSI gửi dữ liệu đến Touch IC và nhận dữ liệu từ Touch
Dữ liệu IC từ dòng MISO. Ở chế độ IO kép, THC điều khiển cả MOSI và MISO để gửi dữ liệu và
cũng nhận được dữ liệu trên cả hai dòng. Ở chế độ Quad IO, có hai dòng khác (IO2 và IO3)
được thêm vào, THC điều khiển MOSI (IO0), MISO (IO1), IO2 và IO3 cùng lúc để gửi dữ liệu và
cũng nhận được dữ liệu trên 4 dòng đó. Trình điều khiển cần định cấu hình THC ở chế độ khác bằng cách
thiết lập opcode khác nhau.

Bên cạnh chế độ IO, trình điều khiển cũng cần định cấu hình tốc độ bus SPI. THC hỗ trợ xung nhịp SPI lên tới 42 MHz
trên nền tảng Intel Lunar Lake.

Đối với THC gửi dữ liệu tới Touch IC, luồng dữ liệu trên bus SPI::

ZZ0000ZZ
 <8Bits OPCode><24Bits Slave Địa chỉ><Dữ liệu><Dữ liệu><Dữ liệu>.............

Đối với THC nhận dữ liệu từ Touch IC, luồng dữ liệu trên bus SPI::

ZZ0000ZZZZ0001ZZ
 <8Bits OPCode><24Bits Slave Địa chỉ><Dữ liệu><Dữ liệu><Dữ liệu>.............

2.2.2 Cổng I2C
~~~~~~~~~~~~~~

THC cũng tích hợp bộ điều khiển I2C trong đó, nó được gọi là I2C SubSystem. Khi PORT_TYPE = 01, THC
được cấu hình ở chế độ I2C. So sánh với chế độ SPI có thể được cấu hình thông qua các thanh ghi MMIO
trực tiếp, THC cần sử dụng chức năng đọc PIO (bằng cách đặt opcode đọc SubIP) thành các thanh ghi I2C subIP APB'
giá trị và sử dụng ghi PIO (bằng cách đặt opcode ghi SubIP) để thực hiện thao tác ghi.

2.2.3 Giao diện GPIO
~~~~~~~~~~~~~~~~~~~~

THC cũng bao gồm hai chân GPIO, một chân để ngắt và chân còn lại để điều khiển thiết lập lại thiết bị.

Đường ngắt có thể được cấu hình để kích hoạt mức hoặc kích hoạt cạnh bằng cách cài đặt MMIO
Thanh ghi điều khiển.

Dòng reset được điều khiển bởi BIOS (hoặc EFI) thông qua phương thức ACPI _RST, trình điều khiển cần gọi đây
phương pháp thiết bị ACPI _RST để đặt lại IC cảm ứng trong quá trình khởi tạo.

2.3 Kiểm soát kích thước đầu vào tối đa
---------------------------------------

Đây là tính năng mới được giới thiệu trên nền tảng Panther Lake, phần cứng THC cho phép trình điều khiển thiết lập
kích thước đầu vào tối đa cho RxDMA. Sau khi kích thước tối đa này được đặt và bật cho mỗi báo cáo đầu vào
đọc gói, trình sắp xếp phần cứng THC trước tiên sẽ đọc kích thước gói đầu vào, sau đó so sánh
kích thước gói đầu vào với kích thước tối đa nhất định:

- nếu kích thước gói đầu vào <= kích thước tối đa, THC tiếp tục sử dụng kích thước gói đầu vào để hoàn tất việc đọc
- nếu kích thước gói đầu vào > kích thước tối đa thì có nguy cơ xảy ra sự cố dữ liệu đầu vào trong quá trình
  khi truyền, THC sẽ sử dụng kích thước tối đa thay vì kích thước gói đầu vào để đọc

Tính năng này được sử dụng để tránh hỏng dữ liệu sẽ gây ra sự cố tràn bộ đệm RxDMA cho
Bus I2C và tăng cường độ ổn định của toàn hệ thống.

2.4 Độ trễ ngắt
-------------------

Do giới hạn hiệu suất của MCU, một số thiết bị cảm ứng không thể xác nhận lại chân ngắt
ngay sau khi dữ liệu đầu vào được truyền đi, điều này gây ra độ trễ chuyển đổi ngắt. Nhưng THC
luôn phát hiện ngắt tiếp theo ngay sau khi ngắt đầu vào cuối cùng được xử lý. Trong này
trong trường hợp, việc hủy xác nhận ngắt bị trì hoãn sẽ được THC công nhận là tín hiệu ngắt mới,
và khiến THC bắt đầu đọc báo cáo đầu vào một cách giả mạo.

Để tránh tình trạng này, THC đã giới thiệu tính năng mới trì hoãn ngắt trong Panther Lake
nền tảng, trong đó THC cho phép trình điều khiển đặt độ trễ ngắt. Sau khi tính năng này được kích hoạt,
THC sẽ trì hoãn thời gian nhất định này để phát hiện ngắt tiếp theo.

3. Khái niệm cấp cao
=====================

3.1 Mã sản phẩm
---------------

Opcode (mã hoạt động) được sử dụng để cho THC hoặc Touch IC biết hoạt động sẽ là gì, chẳng hạn như PIO
đọc hoặc PIO viết.

Khi THC được cấu hình ở chế độ SPI, các opcode được sử dụng để xác định chế độ IO đọc/ghi.
Có một số ví dụ về OPCode cho chế độ IO SPI:

========================================
opcode Lệnh SPI tương ứng
========================================
0x0B Đọc I/O đơn
0x02 Ghi I/O đơn
0xBB Đọc I/O kép
0xB2 Ghi I/O kép
0xEB Đọc I/O bốn
0xE2 Viết I/O bốn
========================================

Nhìn chung, các IC cảm ứng khác nhau sẽ có định nghĩa OPCode khác nhau. Theo HIDSPI
sách trắng về giao thức, các OPCode đó được xác định trong bảng ACPI của thiết bị và trình điều khiển cần phải
truy vấn những thông tin đó thông qua API OS ACPI trong quá trình khởi tạo trình điều khiển, sau đó định cấu hình
THC MMIO OPCode đăng ký với cài đặt chính xác.

Khi THC hoạt động ở chế độ I2C, các opcode được sử dụng để cho THC biết loại PIO tiếp theo là gì:
Đọc đăng ký I2C SubIP APB, ghi đăng ký I2C SubIP APB, đọc thiết bị IC cảm ứng I2C,
Thiết bị IC cảm ứng I2C ghi, thiết bị IC cảm ứng I2C ghi sau đó đọc.

Dưới đây là các opcode THC được xác định trước cho chế độ I2C:

======= ====================================================== ============
opcode Lệnh I2C tương ứng Địa chỉ
======= ====================================================== ============
0x12 Đọc thanh ghi nội bộ I2C SubIP APB 0h - FFh
0x13 Ghi I2C SubIP APB vào các thanh ghi nội bộ 0h - FFh
0x14 Đọc IC cảm ứng bên ngoài thông qua bus I2C Không áp dụng
0x18 Viết IC cảm ứng bên ngoài thông qua bus I2C Không áp dụng
0x1C Viết rồi đọc IC cảm ứng bên ngoài thông qua bus I2C Không áp dụng
======= ====================================================== ============

3.2 PIO
-------

THC cung cấp giao diện truy cập I/O (PIO) được lập trình để trình điều khiển truy cập IC cảm ứng
các thanh ghi cấu hình hoặc truy cập các thanh ghi cấu hình của I2C subIP. Để sử dụng PIO để thực hiện
Hoạt động I/O, trình điều khiển nên lập trình trước các thanh ghi điều khiển PIO và các thanh ghi dữ liệu PIO và khởi động
tắt chu trình giải trình tự. THC sử dụng các mã PIO khác nhau để phân biệt các PIO khác nhau
hoạt động (PIO đọc/ghi/ghi sau đó là đọc).

Nếu có một Chu trình tuần tự đang diễn ra và một nỗ lực được thực hiện để lập trình bất kỳ điều khiển nào,
địa chỉ hoặc thanh ghi dữ liệu, chu trình bị chặn và sẽ gặp lỗi trình tự.

Bit trạng thái cho biết khi nào chu trình đã hoàn thành, cho phép người lái xe biết khi nào đọc kết quả
có thể được kiểm tra và/hoặc khi nào bắt đầu một lệnh mới. Nếu được bật, xác nhận đã hoàn tất chu trình có thể
ngắt trình điều khiển với một ngắt.

Vì THC chỉ có 16 thanh ghi FIFO cho PIO nên tất cả việc truyền dữ liệu qua PIO sẽ không được thực hiện
vượt quá 64 byte.

Vì DMA cần kích thước gói tối đa để truyền cấu hình và thông tin kích thước gói tối đa
luôn ở trong bộ mô tả thiết bị HID cần trình điều khiển THC để đọc nó từ Thiết bị HID (Touch IC).
Vì vậy, trường hợp sử dụng điển hình của PIO là, trước khi khởi tạo DMA, hãy viết lệnh RESET (ghi PIO), đọc
Phản hồi RESET (đọc PIO hoặc ghi PIO sau đó đọc), viết lệnh BẬT nguồn (ghi PIO), đọc
mô tả thiết bị (đọc PIO).

Để biết cách phát hành thao tác PIO, đây là các bước mà trình điều khiển cần tuân theo:

- Chương trình đọc/ghi kích thước dữ liệu trong THC_SS_BC.
- Địa chỉ mục tiêu I/O của chương trình trong THC_SW_SEQ_DATA0_ADDR.
- Nếu ghi thì lập trình dữ liệu ghi trong THC_SW_SEQ_DATA0..THC_SW_SEQ_DATAn.
- Lập trình opcode PIO trong THC_SS_CMD.
- Đặt TSSGO = 1 để bắt đầu chuỗi ghi PIO.
- Nếu THC_SS_CD_IE = 1, SW sẽ nhận được MSI khi PIO hoàn thành.
- Nếu đọc thì đọc ra dữ liệu trong THC_SW_SEQ_DATA0..THC_SW_SEQ_DATAn.

3.3 DMA
-------

THC có 4 kênh DMA: Đọc DMA1, Đọc DMA2, Viết DMA và Phần mềm DMA.

3.3.1 Đọc kênh DMA
~~~~~~~~~~~~~~~~~~~~~~

THC có hai động cơ Đọc DMA: RxDMA thứ nhất (RxDMA1) và RxDMA thứ 2 (RxDMA2). RxDMA1 được dành riêng cho
chế độ dữ liệu thô RxDMA2 được sử dụng cho chế độ dữ liệu HID và đây là công cụ RxDMA hiện được trình điều khiển sử dụng
để truy xuất dữ liệu báo cáo đầu vào HID.

Trường hợp sử dụng điển hình của RxDMA là tự động nhận dữ liệu từ Touch IC. Khi RxDMA được kích hoạt bởi
phần mềm, THC sẽ bắt đầu tự động xử lý logic nhận.

Đối với chế độ SPI, trình tự THC RxDMA là: khi Touch IC kích hoạt ngắt đối với THC, THC sẽ đọc ra
tiêu đề báo cáo để xác định loại báo cáo và độ dài báo cáo là bao nhiêu, tùy theo
thông tin trên, THC đọc nội dung báo cáo vào FIFO nội bộ và bắt đầu RxDMA xử lý dữ liệu
tới bộ nhớ hệ thống. Sau đó, việc cập nhật THC bị gián đoạn do đăng ký với loại báo cáo và cập nhật
Con trỏ đọc bảng RxDMA PRD, sau đó kích hoạt ngắt MSI để thông báo cho trình điều khiển RxDMA đang hoàn tất
nhận dữ liệu.

Đối với chế độ I2C, hoạt động của THC RxDMA hơi khác một chút do sự khác biệt về giao thức HIDI2C
với giao thức HIDSPI, RxDMA chỉ được sử dụng để nhận báo cáo đầu vào. Trình tự là khi Touch IC
kích hoạt ngắt tới THC, trước tiên THC đọc ra 2 byte từ địa chỉ báo cáo đầu vào để xác định
dài gói, sau đó sử dụng độ dài gói này để bắt đầu đọc DMA từ địa chỉ báo cáo đầu vào cho
dữ liệu báo cáo đầu vào. Sau đó, THC cập nhật con trỏ đọc bảng RxDMA PRD, sau đó kích hoạt ngắt MSI
để thông báo dữ liệu báo cáo đầu vào của trình điều khiển đã sẵn sàng trong bộ nhớ hệ thống.

Tất cả trình tự trên được phần cứng xử lý tự động, tất cả những gì trình điều khiển cần làm là cấu hình RxDMA và
chờ ngắt sẵn sàng rồi đọc dữ liệu từ bộ nhớ hệ thống.

3.3.2 Phần mềm kênh DMA
~~~~~~~~~~~~~~~~~~~~~~~~~~

THC hỗ trợ chế độ RxDMA được kích hoạt bằng phần mềm để đọc dữ liệu cảm ứng từ IC cảm ứng. SW RxDMA này
là động cơ THC RxDMA thứ 3 có chức năng tương tự như hai RxDMA hiện có, động cơ duy nhất
điểm khác biệt là SW RxDMA này được kích hoạt bởi phần mềm và RxDMA2 được kích hoạt bởi IC cảm ứng bên ngoài
ngắt lời. Nó mang lại sự linh hoạt cho trình điều khiển phần mềm để sử dụng RxDMA đọc dữ liệu Touch IC bất cứ lúc nào.

Trước khi phần mềm khởi động SW RxDMA, phần mềm phải dừng RxDMA thứ 1 và thứ 2, xóa con trỏ đọc/ghi PRD
và ngừng ngắt thiết bị (THC_DEVINT_QUIESCE_HW_STS = 1), các hoạt động khác tương tự với
RxDMA.

3.3.3 Ghi kênh DMA
~~~~~~~~~~~~~~~~~~~~~~~

THC có một công cụ ghi DMA, có thể được sử dụng để gửi dữ liệu tới Touch IC một cách tự động.
Theo giao thức HIDSPI và HIDI2C, mỗi lần chỉ có thể gửi một lệnh tới IC cảm ứng và
trước khi lệnh cuối cùng được xử lý hoàn toàn, lệnh tiếp theo không thể được gửi, THC chỉ ghi công cụ DMA
hỗ trợ bảng PRD đơn.

Những gì trình điều khiển cần làm là chuẩn bị bảng PRD và bộ đệm DMA, sau đó sao chép dữ liệu vào bộ đệm DMA và
cập nhật bảng PRD với địa chỉ bộ đệm và độ dài bộ đệm, sau đó bắt đầu ghi DMA. THC sẽ
tự động gửi dữ liệu tới IC cảm ứng và kích hoạt ngắt hoàn thành DMA sau khi truyền
đã xong.

3.4 PRD
-------

Bộ mô tả vùng vật lý (PRD) cung cấp mô tả ánh xạ bộ nhớ cho DMA THC.

3.4.1 Bảng và mục nhập PRD
~~~~~~~~~~~~~~~~~~~~~~~~~~

Để cải thiện việc sử dụng bộ nhớ DMA vật lý, các trình điều khiển hiện đại có xu hướng phân bổ hầu như
bộ nhớ đệm liền kề nhưng bị phân mảnh vật lý cho mỗi bộ đệm dữ liệu. Hệ điều hành Linux cũng
cung cấp API SGL (danh sách thu thập phân tán) để hỗ trợ việc sử dụng này.

THC sử dụng bảng PRD (bộ mô tả vùng vật lý) để hỗ trợ nhân hệ điều hành tương ứng
SGL mô tả ánh xạ bộ đệm ảo sang vật lý.

::

--------------- -------------- --------------
 ZZ0000ZZ
  --------------- -------------- --------------
                                                     --------------
                                                    ZZ0001ZZ
                                                     --------------
                                                     --------------
                                                    ZZ0002ZZ
                                                     --------------

Công cụ DMA đọc hỗ trợ nhiều bảng PRD được giữ trong bộ đệm tròn cho phép THC
để hỗ trợ nhiều bộ đệm dữ liệu từ Touch IC. Điều này cho phép máy chủ SW trang bị công cụ Read DMA
với nhiều bộ đệm, cho phép Touch IC gửi nhiều khung dữ liệu đến THC mà không cần SW
tương tác. Khả năng này là cần thiết khi CPU xử lý các khung hình cảm ứng chậm hơn
IC cảm ứng có thể gửi chúng.

Để đơn giản hóa thiết kế, SW giả định sự phân mảnh bộ nhớ trong trường hợp xấu nhất. Do đó, mỗi bảng PRD sẽ
chứa cùng số lượng mục PRD, cho phép một thanh ghi chung (mỗi Touch IC) giữ
số lượng mục nhập PRD trên mỗi bảng PRD.

SW phân bổ tối đa 128 bảng PRD cho mỗi công cụ Đọc DMA như được chỉ định trong THC_M_PRT_RPRD_CNTRL.PCD
trường đăng ký. Số lượng bảng PRD phải bằng số lượng bộ đệm dữ liệu.

Phân mảnh bộ nhớ hệ điều hành tối đa sẽ ở giới hạn 4KB, do đó có thể xử lý 1 MB bộ nhớ gần như liền kề
bộ nhớ 256 mục nhập PRD được yêu cầu cho một Bảng PRD. SW ghi số lượng mục PRD
cho mỗi bảng PRD trong trường đăng ký THC_M_PRT_RPRD_CNTRL.PTEC. Độ dài của mục nhập PRD phải là
bội số của 4KB ngoại trừ mục cuối cùng trong bảng PRD.

SW chỉ phân bổ tất cả bộ đệm dữ liệu và bảng PRD một lần khi khởi tạo máy chủ.

3.4.2 PRD Con trỏ ghi và con trỏ đọc
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Vì các bảng PRD được tổ chức dưới dạng Bộ đệm tròn (CB), một con trỏ đọc và một con trỏ ghi cho CB
là cần thiết.

DMA HW sử dụng các bảng PRD trong CB, mỗi lần một mục nhập PRD cho đến khi tìm thấy bit EOP
trong mục nhập PRD. Tại thời điểm này, HW tăng con trỏ đọc PRD. Vì vậy, con trỏ đọc trỏ tới
tới PRD mà công cụ DMA hiện đang xử lý. Con trỏ này cuộn qua một lần hình tròn
độ sâu của bộ đệm đã được duyệt bằng bit[7] bit Rollover. Ví dụ. nếu độ sâu DMA CB bằng nhau
đến 4 mục (0011b), thì con trỏ đọc sẽ tuân theo mẫu này (HW được yêu cầu phải tôn trọng
hành vi này): 00h 01h 02h 03h 80h 81h 82h 83h 00h 01h ...

Con trỏ ghi được cập nhật bởi SW. Con trỏ ghi trỏ đến vị trí trong DMA CB, nơi
bảng PRD tiếp theo sẽ được lưu trữ. SW cần đảm bảo rằng con trỏ này sẽ cuộn qua khi
độ sâu của bộ đệm tròn đã được duyệt bằng Bit[7] làm bit cuộn qua. Ví dụ. nếu DMA CB
độ sâu bằng 5 mục (0100b), thì con trỏ ghi sẽ tuân theo mẫu này (SW là
bắt buộc phải tôn trọng hành vi này): 00h 01h 02h 03h 04h 80h 81h 82h 83h 84h 00h 01h ..

3.4.3 Cấu trúc mô tả PRD
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Intel THC sử dụng bộ mô tả mục nhập PRD cho mỗi mục nhập PRD. Mỗi bộ mô tả mục nhập PRD chiếm
Bộ nhớ 128 bit:

=========================== ====================================================
Mô tả (các) bit trường cấu trúc
=========================== ====================================================
dest_addr 53..0 địa chỉ bộ nhớ đích, như mọi mục nhập
                                 là 4KB, bỏ qua 10 bit địa chỉ thấp nhất.
dành riêng1 54..62 dành riêng
int_on_completion 63 bit cho phép ngắt hoàn thành, nếu bit này
                                 đặt nó có nghĩa là THC sẽ kích hoạt hoàn thành
                                 ngắt lời. Bit này được thiết lập bởi trình điều khiển SW.
len 87..64 có bao nhiêu byte dữ liệu trong mục này.
end_of_prd 88 đầu của bit bảng PRD, nếu bit này được đặt,
                                 nó có nghĩa là mục này là mục cuối cùng trong PRD này
                                 cái bàn. Bit này được thiết lập bởi trình điều khiển SW.
hw_status 90..89 bit trạng thái CTNH
dành riêng2 127..91 dành riêng
=========================== ====================================================

Và một bảng PRD có thể bao gồm tối đa 256 mục nhập PRD, vì mỗi mục nhập là 4K byte, vì vậy mỗi mục
Bảng PRD có thể mô tả bộ nhớ 1M byte.

.. code-block:: c

   struct thc_prd_table {
        struct thc_prd_entry entries[PRD_ENTRIES_NUM];
   };

Nói chung, mỗi bảng PRD có nghĩa là một gói dữ liệu cảm ứng HID. Mọi động cơ DMA đều có thể hỗ trợ
lên tới 128 bảng PRD (ngoại trừ ghi DMA, ghi DMA chỉ có một bảng PRD). Lái xe SW phải chịu trách nhiệm
để nhận độ dài gói tối đa từ IC cảm ứng và sử dụng độ dài gói tối đa này để tạo các mục PRD cho
mỗi bảng PRD.

4. Hỗ trợ HIDSPI (QuickSPI)
============================

Intel THC hoàn toàn tương thích với giao thức HIDSPI, bộ tuần tự THC HW có thể tăng tốc HIDSPI
chuyển giao thức.

4.1 Quy trình đặt lại
---------------------

- Gọi phương thức ACPI _RST để reset thiết bị Touch IC.
- Đọc phản hồi reset từ TIC đến đọc PIO.
- Ra lệnh truy xuất bộ mô tả thiết bị từ Touch IC thông qua ghi PIO.
- Đọc mô tả thiết bị từ Touch IC qua đọc PIO.
- Nếu bộ mô tả thiết bị hợp lệ, hãy phân bổ bộ đệm DMA và định cấu hình tất cả các kênh DMA.
- Ra lệnh truy xuất bộ mô tả báo cáo từ Touch IC thông qua DMA.

4.2 Luồng dữ liệu báo cáo đầu vào
---------------------------------

Luồng cơ bản:

- IC cảm ứng ngắt Bộ điều khiển THC bằng cách sử dụng ngắt THC trong băng tần.
- THC Sequencer đọc tiêu đề báo cáo đầu vào bằng cách truyền phê duyệt đọc dưới dạng tín hiệu
  tới Touch IC để chuẩn bị cho máy chủ đọc từ thiết bị.
- THC Sequencer thực hiện thao tác Đọc nội dung báo cáo đầu vào tương ứng với giá trị
  được phản ánh trong trường “Độ dài báo cáo đầu vào” của Tiêu đề báo cáo đầu vào.
- Công cụ THC DMA bắt đầu tìm nạp dữ liệu từ Bộ tuần tự THC và ghi vào bộ nhớ máy chủ
  tại PRD mục nhập 0 cho mục nhập bảng CB PRD hiện tại. Quá trình này tiếp tục cho đến khi
  Bộ tuần tự THC báo hiệu tất cả dữ liệu đã được đọc hoặc Công cụ đọc THC DMA đạt đến
  ở cuối mục PRD cuối cùng (hoặc cả hai).
- Bộ tuần tự THC kiểm tra bit “Cờ phân đoạn cuối cùng” trong Tiêu đề báo cáo đầu vào.
  Nếu nó rõ ràng, Bộ sắp xếp THC sẽ chuyển sang trạng thái không hoạt động.
- Nếu bit “Cờ phân đoạn cuối cùng” được bật thì Bộ tuần tự THC sẽ chuyển sang Xử lý cuối khung.

Bộ xử lý kết thúc khung hình THC:

- Động cơ THC DMA tăng con trỏ đọc của CB Read PRD, đặt trạng thái ngắt EOF
  trong thanh ghi RxDMA2 (THC_M_PRT_READ_DMA_INT_STS_2).
- Nếu trình điều khiển kích hoạt ngắt THC EOF trong thanh ghi điều khiển (THC_M_PRT_READ_DMA_CNTRL_2),
  tạo ra sự gián đoạn cho phần mềm.

Trình tự các bước đọc dữ liệu từ bộ đệm RX DMA:

- Trình điều khiển QuickSPI của THC kiểm tra CB ghi Ptr và CB đọc Ptr để xác định xem có khung dữ liệu nào trong DMA không
  bộ đệm tròn.
- Trình điều khiển THC QuickSPI nhận được bảng PRD chưa được xử lý đầu tiên.
- Trình điều khiển THC QuickSPI quét tất cả các mục PRD trong bảng PRD này để tính tổng kích thước khung hình.
- THC Trình điều khiển QuickSPI sao chép tất cả dữ liệu khung ra.
- Trình điều khiển THC QuickSPI kiểm tra kiểu dữ liệu theo nội dung báo cáo đầu vào và các cuộc gọi liên quan
  gọi lại để xử lý dữ liệu.
- THC Cập nhật driver QuickSPI ghi Ptr.

4.3 Luồng dữ liệu báo cáo đầu ra
--------------------------------

Luồng báo cáo đầu ra chung:

- Lõi HID gọi lại lệnh gọi lại raw_request với yêu cầu tới trình điều khiển QuickSPI THC.
- THC QuickSPI Driver chuyển đổi dữ liệu yêu cầu được cung cấp thành gói báo cáo đầu ra và sao chép nó
  vào bộ đệm ghi DMA của THC.
- Khởi động TxDMA để hoàn tất thao tác ghi.

5. Hỗ trợ HIDI2C (QuickI2C)
============================

5.1 Quy trình đặt lại
---------------------

- Đọc bộ mô tả thiết bị từ thiết bị Touch IC thông qua ghi PIO rồi đọc.
- Nếu bộ mô tả thiết bị hợp lệ, hãy phân bổ bộ đệm DMA và định cấu hình tất cả các kênh DMA.
- Sử dụng PIO hoặc TxDMA để ghi yêu cầu SET_POWER vào thanh ghi lệnh của TIC và kiểm tra xem
  thao tác ghi được hoàn tất thành công.
- Sử dụng PIO hoặc TxDMA để ghi yêu cầu RESET vào thanh ghi lệnh của TIC. Nếu thao tác ghi
  được hoàn thành thành công, hãy đợi phản hồi đặt lại từ TIC.
- Sử dụng SWDMA để đọc bộ mô tả báo cáo thông qua thanh ghi bộ mô tả báo cáo của TIC.

5.2 Luồng dữ liệu báo cáo đầu vào
---------------------------------

Luồng cơ bản:

- IC cảm ứng xác nhận ngắt cho biết rằng nó có ngắt để gửi tới HOST.
  Trình tuần tự THC đưa ra yêu cầu READ qua bus I2C. Thiết bị HIDI2C trả về
  2 byte đầu tiên từ thiết bị HIDI2C chứa độ dài của dữ liệu nhận được.
- Bộ tuần tự THC tiếp tục thao tác Đọc theo kích thước của dữ liệu được chỉ định trong
  trường chiều dài.
- Công cụ THC DMA bắt đầu tìm nạp dữ liệu từ Bộ tuần tự THC và ghi vào bộ nhớ máy chủ
  tại PRD mục nhập 0 cho mục nhập bảng CB PRD hiện tại. THC ghi 2Byte cho trường độ dài
  cộng với dữ liệu còn lại vào bộ đệm RxDMA. Quá trình này tiếp tục cho đến khi Bộ sắp xếp thứ tự THC
  báo hiệu tất cả dữ liệu đã được đọc hoặc Công cụ đọc THC DMA đạt đến điểm cuối cùng
  Mục nhập PRD (hoặc cả hai).
- Trình sắp xếp THC tiến vào Xử lý báo cáo cuối đầu vào.
- Nếu thiết bị không còn báo cáo đầu vào nào để gửi đến máy chủ, thiết bị sẽ hủy xác nhận ngắt
  dòng. Đối với bất kỳ báo cáo đầu vào bổ sung nào, thiết bị sẽ luôn xác nhận dòng ngắt và
  các bước từ 1 đến 4 trong quy trình được lặp lại.

Trình sắp xếp THC Kết thúc quá trình xử lý báo cáo đầu vào:

- Động cơ THC DMA tăng con trỏ đọc của CB Read PRD, đặt trạng thái ngắt EOF
  trong thanh ghi RxDMA 2 (THC_M_PRT_READ_DMA_INT_STS_2).
- Nếu ngắt THC EOF được kích hoạt bởi trình điều khiển trong thanh ghi điều khiển
  (THC_M_PRT_READ_DMA_CNTRL_2), tạo ra ngắt cho phần mềm.

Trình tự các bước đọc dữ liệu từ bộ đệm RX DMA:

- Trình điều khiển THC QuickI2C kiểm tra CB ghi Ptr và CB đọc Ptr để xác định xem có khung dữ liệu nào trong DMA không
  bộ đệm tròn.
- Trình điều khiển THC QuickI2C nhận bảng PRD chưa được xử lý đầu tiên.
- Trình điều khiển THC QuickI2C quét tất cả các mục PRD trong bảng PRD này để tính tổng kích thước khung hình.
- Trình điều khiển THC QuickI2C sao chép tất cả dữ liệu khung ra.
- Trình điều khiển THC QuickI2C gọi hid_input_report để gửi nội dung báo cáo đầu vào đến lõi HID,
  bao gồm ID báo cáo + Nội dung dữ liệu báo cáo (xóa trường độ dài khỏi báo cáo gốc
  dữ liệu).
- Cập nhật driver THC QuickI2C ghi Ptr.

5.3 Luồng dữ liệu báo cáo đầu ra
--------------------------------

Luồng báo cáo đầu ra chung:

- Gọi lại lõi HID THC QuickI2C raw_request gọi lại.
- THC QuickI2C sử dụng PIO hoặc TXDMA để ghi yêu cầu SET_REPORT vào thanh ghi lệnh của TIC. Báo cáo
  nhập SET_REPORT phải được đặt thành Đầu ra.
- THC QuickI2C lập trình bộ đệm TxDMA với Dữ liệu TX để ghi vào thanh ghi dữ liệu của TIC. đầu tiên
  2 byte phải cho biết độ dài của báo cáo, theo sau là nội dung báo cáo bao gồm
  ID báo cáo.

6. Gỡ lỗi THC
================

Để gỡ lỗi THC, cơ chế theo dõi sự kiện được sử dụng. Để bật nhật ký gỡ lỗi::

echo 1 > /sys/kernel/debug/tracing/events/intel_thc/enable
  mèo/sys/kernel/gỡ lỗi/truy tìm/dấu vết

7. Tài liệu tham khảo
=====================
-HIDSPI: ZZ0000ZZ
-HIDI2C: ZZ0001ZZ