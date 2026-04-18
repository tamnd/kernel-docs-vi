.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/oa-tc6-framework.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================================================================
Hỗ trợ khung giao diện nối tiếp OPEN Alliance 10BASE-T1x MAC-PHY (TC6)
=========================================================================

Giới thiệu
------------

Dự án IEEE 802.3cg xác định hai PHY 10 Mbit/s hoạt động trên một
một cặp dây dẫn. 10BASE-T1L (Khoản 146) có phạm vi hoạt động lâu dài
PHY hỗ trợ hoạt động song công hoàn toàn điểm-điểm trên 1 km mạng đơn
cặp dây dẫn cân bằng. 10BASE-T1S (Khoản 147) có phạm vi tiếp cận ngắn
PHY hỗ trợ hoạt động điểm-điểm song công hoàn toàn/bán song công trên phạm vi 15 m
một cặp dây dẫn cân bằng đơn hoặc bus đa hướng bán song công
hoạt động trên 25 m của một cặp dây dẫn cân bằng.

Hơn nữa, dự án IEEE 802.3cg xác định Lớp vật lý mới
Lớp con hòa giải tránh va chạm (PLCA) (Điều 148) có nghĩa là
cung cấp tính xác định được cải thiện cho phương pháp truy cập phương tiện CSMA/CD. PLCA
hoạt động cùng với 10BASE-T1S PHY hoạt động ở chế độ đa điểm.

Các PHY nói trên nhằm mục đích đáp ứng nhu cầu tốc độ thấp/chi phí thấp
ứng dụng trong môi trường công nghiệp và ô tô. Số lượng lớn
số chân (16) được yêu cầu bởi giao diện MII, được chỉ định bởi
IEEE 802.3 trong Điều 22, là một trong những yếu tố chi phí chính cần được
giải quyết để hoàn thành mục tiêu này.

Giải pháp MAC-PHY tích hợp IEEE Điều 4 MAC và 10BASE-T1x PHY
hiển thị số lượng pin thấp Giao diện ngoại vi nối tiếp (SPI) cho máy chủ
vi điều khiển. Điều này cũng cho phép bổ sung chức năng Ethernet
cho các bộ vi điều khiển cấp thấp hiện có không tích hợp MAC
bộ điều khiển.

Tổng quan
--------

MAC-PHY được chỉ định để mang cả dữ liệu (khung Ethernet) và điều khiển
(đăng ký quyền truy cập) giao dịch qua một thiết bị ngoại vi nối tiếp song công hoàn toàn
giao diện.

Tổng quan về giao thức
-----------------

Hai loại giao dịch được xác định trong giao thức: giao dịch dữ liệu
để truyền khung Ethernet và giao dịch điều khiển để đăng ký
chuyển đọc/ghi. Một đoạn là thành phần cơ bản của giao dịch dữ liệu
và bao gồm 4 byte chi phí cộng với 64 byte kích thước tải trọng cho
từng đoạn. Các khung Ethernet được truyền qua một hoặc nhiều khối dữ liệu.
Giao dịch điều khiển bao gồm một hoặc nhiều điều khiển đọc/ghi đăng ký
lệnh.

Các giao dịch SPI được khởi tạo bởi máy chủ SPI với sự xác nhận của CSn
ở mức thấp đến MAC-PHY và kết thúc bằng việc xác nhận lại mức CSn ở mức cao. Ở giữa
mỗi giao dịch SPI, máy chủ SPI có thể cần thời gian để bổ sung
xử lý và thiết lập dữ liệu SPI tiếp theo hoặc giao dịch kiểm soát.

Giao dịch dữ liệu SPI bao gồm số lần truyền (TX) bằng nhau và
nhận các khối (RX). Các đoạn trong cả hai hướng truyền và nhận có thể
hoặc có thể không chứa dữ liệu khung hợp lệ độc lập với nhau, cho phép
để truyền và nhận đồng thời có độ dài khác nhau
khung.

Mỗi đoạn dữ liệu truyền bắt đầu bằng tiêu đề dữ liệu 32 bit, theo sau là
tải trọng dữ liệu trên MOSI. Tiêu đề dữ liệu cho biết liệu truyền
dữ liệu khung có mặt và cung cấp thông tin để xác định
byte của tải trọng chứa dữ liệu khung hợp lệ.

Song song, các khối dữ liệu nhận được nhận trên MISO. Mỗi người nhận dữ liệu
chunk bao gồm tải trọng chunk dữ liệu kết thúc bằng chân trang dữ liệu 32 bit.
Chân trang dữ liệu cho biết liệu có dữ liệu khung nhận trong
tải trọng hay không và cung cấp thông tin để xác định byte nào
của tải trọng chứa dữ liệu khung hợp lệ.

Thẩm quyền giải quyết
---------

Thông số kỹ thuật giao diện nối tiếp 10BASE-T1x MAC-PHY,

Liên kết: ZZ0000ZZ

Kiến trúc phần cứng
---------------------

.. code-block:: none

  +----------+      +-------------------------------------+
  |          |      |                MAC-PHY              |
  |          |<---->| +-----------+  +-------+  +-------+ |
  | SPI Host |      | | SPI Slave |  |  MAC  |  |  PHY  | |
  |          |      | +-----------+  +-------+  +-------+ |
  +----------+      +-------------------------------------+

Kiến trúc phần mềm
---------------------

.. code-block:: none

  +----------------------------------------------------------+
  |                 Networking Subsystem                     |
  +----------------------------------------------------------+
            / \                             / \
             |                               |
             |                               |
            \ /                              |
  +----------------------+     +-----------------------------+
  |     MAC Driver       |<--->| OPEN Alliance TC6 Framework |
  +----------------------+     +-----------------------------+
            / \                             / \
             |                               |
             |                               |
             |                              \ /
  +----------------------------------------------------------+
  |                    SPI Subsystem                         |
  +----------------------------------------------------------+
                          / \
                           |
                           |
                          \ /
  +----------------------------------------------------------+
  |                10BASE-T1x MAC-PHY Device                 |
  +----------------------------------------------------------+

Thực hiện
--------------

Trình điều khiển MAC
~~~~~~~~~~

- Được thăm dò bởi hệ thống con SPI.

- Khởi tạo khung OA TC6 cho MAC-PHY.

- Đăng ký và cấu hình thiết bị mạng.

- Gửi các khung ethernet tx từ hệ thống con n/w tới khung OA TC6.

OPEN Liên minh TC6 Khung
~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Khởi tạo giao diện PHYLIB.

- Đăng ký ngắt mac-phy.

- Thực hiện thao tác đọc/ghi đăng ký mac-phy bằng điều khiển
  giao thức giao dịch được chỉ định trong OPEN Alliance 10BASE-T1x MAC-PHY
  Đặc tả giao diện nối tiếp.

- Thực hiện giao dịch khung Ethernet bằng giao thức giao dịch dữ liệu
  cho các khung Ethernet được chỉ định trong OPEN Alliance 10BASE-T1x MAC-PHY
  Đặc tả giao diện nối tiếp.

- Chuyển tiếp khung Ethernet đã nhận từ 10Base-T1x MAC-PHY sang n/w
  hệ thống con.

Giao dịch dữ liệu
~~~~~~~~~~~~~~~~

Các khung Ethernet thường được truyền từ máy chủ SPI sang
MAC-PHY sẽ được chuyển đổi thành nhiều khối dữ liệu truyền. Mỗi
đoạn dữ liệu truyền sẽ có tiêu đề 4 byte chứa
thông tin cần thiết để xác định tính hợp lệ và vị trí của
truyền dữ liệu khung trong tải trọng khối dữ liệu 64 byte.

.. code-block:: none

  +---------------------------------------------------+
  |                     Tx Chunk                      |
  | +---------------------------+  +----------------+ |   MOSI
  | | 64 bytes chunk payload    |  | 4 bytes header | |------------>
  | +---------------------------+  +----------------+ |
  +---------------------------------------------------+

Tiêu đề 4 byte chứa các trường bên dưới,

DNC (Bit 31) - Cờ không kiểm soát dữ liệu. Cờ này chỉ định loại SPI
               giao dịch. Đối với khối dữ liệu TX, bit này sẽ là '1'.
               0 - Lệnh điều khiển
               1 - Đoạn dữ liệu

SEQ (Bit 30) - Chuỗi khối dữ liệu. Bit này được sử dụng để chỉ ra một
               Chuỗi khối dữ liệu truyền chẵn/lẻ tới MAC-PHY.

NORX (Bit 29) - Không có cờ nhận. Máy chủ SPI có thể đặt bit này để ngăn chặn
                MAC-PHY truyền dữ liệu RX trên MISO cho
                đoạn hiện tại (DV = 0 ở phần chân trang), chỉ ra rằng
                máy chủ sẽ không xử lý nó. Thông thường, máy chủ SPI sẽ
                đặt NORX = 0 cho biết nó sẽ chấp nhận và xử lý
                bất kỳ dữ liệu khung nhận nào trong đoạn hiện tại.

RSVD (Bit 28..24) - Dự trữ: Tất cả các bit dự trữ sẽ là '0'.

VS (Bit 23..22) - Nhà cung cấp cụ thể. Các bit này được thực hiện cụ thể.
                  Nếu MAC-PHY không triển khai các bit này, máy chủ
                  sẽ đặt chúng thành '0'.

DV (Bit 21) - Cờ hợp lệ dữ liệu. Máy chủ SPI sử dụng bit này để biểu thị
              liệu đoạn hiện tại có chứa dữ liệu khung truyền hợp lệ hay không
              (DV = 1) hoặc không (DV = 0). Khi '0', MAC-PHY bỏ qua
              tải trọng chunk. Lưu ý rằng đường dẫn nhận không bị ảnh hưởng bởi
              cài đặt của bit DV trong tiêu đề dữ liệu.

SV (Bit 20) - Bắt đầu cờ hợp lệ. Máy chủ SPI sẽ thiết lập bit này khi
              phần đầu của khung Ethernet hiện diện trong
              truyền tải trọng khối dữ liệu. Ngược lại, bit này sẽ được
              không. Bit này không được nhầm lẫn với Start-of-Frame
              Byte phân cách (SFD) được mô tả trong IEEE 802.3 [2].

SWO (Bit 19..16) - Bù từ bắt đầu. Khi SV = 1, trường này sẽ
                   chứa phần bù từ 32 bit vào dữ liệu truyền
                   tải trọng chunk trỏ đến điểm bắt đầu của một phần mới
                   Khung Ethernet được truyền đi. Người chủ trì sẽ viết
                   trường này bằng 0 khi SV = 0.

RSVD (Bit 15) - Dự trữ: Tất cả các bit dự trữ sẽ là '0'.

EV (Bit 14) - Cờ kết thúc hợp lệ. Máy chủ SPI sẽ thiết lập bit này khi kết thúc
              của khung Ethernet có trong dữ liệu truyền hiện tại
              tải trọng chunk. Ngược lại, bit này sẽ bằng 0.

EBO (Bit 13..8) - Bù byte cuối. Khi EV = 1, trường này sẽ chứa
                  phần bù byte vào tải trọng khối dữ liệu truyền
                  trỏ đến byte cuối cùng của khung Ethernet để
                  truyền tải. Trường này sẽ bằng 0 khi EV = 0.

TSC (Bit 7..6) - Chụp dấu thời gian. Yêu cầu chụp dấu thời gian khi
                 khung được truyền lên mạng.
                 00 - Không chụp dấu thời gian
                 01 - Ghi dấu thời gian vào thanh ghi ghi dấu thời gian A
                 10 - Ghi dấu thời gian vào thanh ghi ghi dấu thời gian B
                 11 - Ghi dấu thời gian vào thanh ghi ghi dấu thời gian C

RSVD (Bit 5..1) - Dự trữ: Tất cả các bit dự trữ sẽ là '0'.

P (Bit 0) - Tính chẵn lẻ. Bit chẵn lẻ được tính trên tiêu đề dữ liệu truyền.
            Phương pháp được sử dụng là phương pháp chẵn lẻ lẻ.

Số lượng bộ đệm có sẵn trong MAC-PHY để lưu trữ dữ liệu đến
tải trọng khối dữ liệu truyền được biểu diễn dưới dạng tín dụng truyền. các
tín dụng truyền có sẵn trong MAC-PHY có thể được đọc từ
Đăng ký trạng thái bộ đệm hoặc chân trang (Tham khảo bên dưới để biết thông tin chân trang)
nhận được từ MAC-PHY. Máy chủ SPI không nên ghi thêm khối dữ liệu
hơn tín dụng truyền có sẵn vì điều này sẽ dẫn đến bộ đệm truyền
lỗi tràn.

Trong trường hợp chân trang dữ liệu trước đó không có sẵn tín dụng truyền tải và
khi tín dụng truyền có sẵn để truyền dữ liệu truyền
chunk, ngắt MAC-PHY được xác nhận với máy chủ SPI. Về việc tiếp nhận
tiêu đề dữ liệu đầu tiên, ngắt này sẽ được xác nhận lại và nhận được
chân trang cho đoạn dữ liệu đầu tiên sẽ có sẵn phần ghi công truyền tải
thông tin.

Các khung Ethernet thường được truyền từ MAC-PHY sang SPI
máy chủ sẽ được gửi dưới dạng nhiều khối dữ liệu nhận. Mỗi người nhận dữ liệu
chunk sẽ có 64 byte tải trọng chunk dữ liệu, theo sau là phần chân trang 4 byte
chứa thông tin cần thiết để xác định tính hợp lệ và
vị trí của dữ liệu khung nhận trong tải trọng khối dữ liệu 64 byte.

.. code-block:: none

  +---------------------------------------------------+
  |                     Rx Chunk                      |
  | +----------------+  +---------------------------+ |   MISO
  | | 4 bytes footer |  | 64 bytes chunk payload    | |------------>
  | +----------------+  +---------------------------+ |
  +---------------------------------------------------+

Chân trang 4 byte chứa các trường bên dưới,

EXST (Bit 31) - Trạng thái mở rộng. Bit này được thiết lập khi bất kỳ bit nào trong
                Các thanh ghi STATUS0 hoặc STATUS1 được đặt và không bị che.

HDRB (Bit 30) - Đã nhận được tiêu đề không hợp lệ. Khi được đặt, cho biết rằng MAC-PHY
                nhận được một tiêu đề điều khiển hoặc dữ liệu có lỗi chẵn lẻ.

SYNC (Bit 29) - Cờ đồng bộ hóa cấu hình. Bit này phản ánh
                trạng thái của bit SYNC trong cấu hình CONFIG0
                đăng ký (xem Bảng 12). Số 0 cho biết MAC-PHY
                cấu hình có thể không như mong đợi của máy chủ SPI.
                Sau khi cấu hình, máy chủ SPI thiết lập
                bit tương ứng trong thanh ghi cấu hình
                phản ánh trong lĩnh vực này.

RCA (Bit 28..24) - Nhận các đoạn có sẵn. Trường RCA biểu thị
                   máy chủ SPI số lần nhận bổ sung tối thiểu
                   khối dữ liệu của dữ liệu khung có sẵn cho
                   đọc vượt quá đoạn dữ liệu nhận hiện tại. Cái này
                   trường bằng 0 khi không có dữ liệu khung nhận
                   đang chờ xử lý trong bộ đệm của MAC-PHY để đọc.

VS (Bit 23..22) - Nhà cung cấp cụ thể. Các bit này được thực hiện cụ thể.
                  Nếu không được triển khai, MAC-PHY sẽ đặt các bit này thành
                  '0'.

DV (Bit 21) - Cờ hợp lệ dữ liệu. MAC-PHY sử dụng bit này để biểu thị
              liệu đoạn dữ liệu nhận hiện tại có hợp lệ hay không
              nhận dữ liệu khung (DV = 1) hay không (DV = 0). Khi ‘0’,
              Máy chủ SPI sẽ bỏ qua tải trọng chunk.

SV (Bit 20) - Bắt đầu cờ hợp lệ. MAC-PHY thiết lập bit này khi dòng điện
              tải trọng chunk chứa phần bắt đầu của khung Ethernet.
              Ngược lại, bit này bằng 0. Bit SV không được phép
              bị nhầm lẫn với byte Dấu phân cách bắt đầu khung (SFD)
              được mô tả trong IEEE 802.3 [2].

SWO (Bit 19..16) - Bù từ bắt đầu. Khi SV = 1, trường này chứa
                   Độ lệch từ 32 bit vào tải trọng khối dữ liệu nhận
                   chứa byte đầu tiên của Ethernet mới nhận được
                   khung. Khi dấu thời gian nhận đã được thêm vào
                   đầu khung Ethernet nhận được (RTSA = 1)
                   thì SWO trỏ đến byte quan trọng nhất của
                   dấu thời gian. Trường này sẽ bằng 0 khi SV = 0.

FD (Bit 15) - Giảm khung hình. Khi được đặt, bit này cho biết MAC có
              đã phát hiện một tình trạng mà máy chủ SPI sẽ hủy
              nhận được khung Ethernet. Bit này chỉ có giá trị ở cuối
              của khung Ethernet nhận được (EV = 1) và sẽ bằng 0 tại
              tất cả các thời điểm khác.

EV (Bit 14) - Cờ kết thúc hợp lệ. MAC-PHY thiết lập bit này khi kết thúc một
              khung Ethernet đã nhận có trong dữ liệu nhận này
              tải trọng chunk.

EBO (Bit 13..8) - End Byte Offset: Khi EV = 1, trường này chứa
                  phần bù byte vào tải trọng khối dữ liệu nhận được
                  định vị byte cuối cùng của khung Ethernet đã nhận.
                  Trường này bằng 0 khi EV = 0.

RTSA (Bit 7) - Đã thêm dấu thời gian nhận. Bit này được thiết lập khi 32-bit hoặc
               Dấu thời gian 64-bit đã được thêm vào phần đầu của
               nhận được khung Ethernet. MAC-PHY sẽ đặt bit này thành
               bằng 0 khi SV = 0.

RTSP (Bit 6) - Nhận tính chẵn lẻ của dấu thời gian. Bit chẵn lẻ được tính toán trên
               Dấu thời gian 32-bit/64-bit được thêm vào phần đầu của
               nhận được khung Ethernet. Phương pháp được sử dụng là phương pháp chẵn lẻ lẻ. các
               MAC-PHY sẽ đặt bit này về 0 khi RTSA = 0.

TXC (Bit 5..1) - Truyền tín dụng. Trường này chứa số lượng tối thiểu
                 truyền các khối dữ liệu của khung dữ liệu mà máy chủ SPI
                 có thể viết trong một giao dịch duy nhất mà không phát sinh
                 truyền lỗi tràn bộ đệm.

P (Bit 0) - Tính chẵn lẻ. Bit chẵn lẻ được tính trên chân trang dữ liệu nhận.
            Phương pháp được sử dụng là phương pháp chẵn lẻ lẻ.

Máy chủ SPI sẽ bắt đầu giao dịch nhận dữ liệu dựa trên việc nhận
các khối có sẵn trong MAC-PHY được cung cấp trong khối nhận
chân trang (RCA - Nhận các đoạn có sẵn). Máy chủ SPI sẽ tạo dữ liệu không hợp lệ
truyền các khối dữ liệu (khối trống) hoặc dữ liệu hợp lệ truyền các khối dữ liệu trong
trường hợp có khung Ethernet hợp lệ để truyền tới MAC-PHY. các
nhận các khối có sẵn trong MAC-PHY có thể được đọc từ Bộ đệm
Đăng ký trạng thái hoặc chân trang.

Trong trường hợp chân trang dữ liệu trước đó không có sẵn khối dữ liệu nhận và
khi các khối dữ liệu nhận được sẵn sàng để đọc trở lại,
Ngắt MAC-PHY được xác nhận cho máy chủ SPI. Khi nhận được dữ liệu đầu tiên
tiêu đề ngắt này sẽ được xác nhận lại và chân trang nhận được cho
Đoạn dữ liệu đầu tiên sẽ có các đoạn thông tin nhận được.

Ngắt MAC-PHY
~~~~~~~~~~~~~~~~~

Ngắt MAC-PHY được xác nhận khi đáp ứng các điều kiện sau.

Nhận các khối có sẵn - Ngắt này được xác nhận khi ngắt trước đó
chân trang dữ liệu không có sẵn khối dữ liệu nhận nào và sau khi nhận được
khối dữ liệu có sẵn để đọc. Khi nhận được dữ liệu đầu tiên
tiêu đề ngắt này sẽ được xác nhận lại.

Truyền các khoản tín dụng có sẵn - Sự gián đoạn này được xác nhận khi
chân trang dữ liệu trước đó cho biết không có tín dụng truyền tải nào và sau khi
tín dụng truyền có sẵn để truyền các khối dữ liệu truyền.
Khi nhận được tiêu đề dữ liệu đầu tiên, ngắt này sẽ được xác nhận lại.

Sự kiện trạng thái mở rộng - Ngắt này được xác nhận khi dữ liệu trước đó
chân trang cho biết không có trạng thái mở rộng và khi sự kiện mở rộng trở thành
có sẵn. Trong trường hợp này Host nên đọc trạng thái #0 register để biết
lỗi/sự kiện tương ứng. Khi nhận được tiêu đề dữ liệu đầu tiên, điều này
ngắt sẽ được xác nhận lại.

Kiểm soát giao dịch
~~~~~~~~~~~~~~~~~~~

Tiêu đề điều khiển 4 byte chứa các trường bên dưới,

DNC (Bit 31) - Cờ không kiểm soát dữ liệu. Cờ này chỉ định loại SPI
               giao dịch. Đối với các lệnh điều khiển, bit này phải là ‘0’.
               0 - Lệnh điều khiển
               1 - Đoạn dữ liệu

HDRB (Bit 30) - Đã nhận được tiêu đề không hợp lệ. Khi được thiết lập bởi MAC-PHY, biểu thị
                rằng một tiêu đề đã được nhận có lỗi chẵn lẻ. SPI
                máy chủ phải luôn xóa bit này. MAC-PHY bỏ qua
                Giá trị HDRB được gửi bởi máy chủ SPI trên MOSI.

WNR (Bit 29) - Viết-Không-Đọc. Bit này cho biết dữ liệu có được ghi hay không
               vào các thanh ghi (khi được đặt) hoặc đọc từ các thanh ghi
               (khi rõ ràng).

AID (Bit 28) - Vô hiệu hóa tăng địa chỉ. Khi rõ ràng, địa chỉ sẽ là
               tự động tăng sau mỗi cái
               đăng ký đọc hoặc viết. Khi được đặt, địa chỉ tự động tăng lên là
               bị vô hiệu hóa cho phép đọc và ghi liên tiếp xảy ra tại
               cùng một địa chỉ đăng ký.

MMS (Bit 27..24) - Bộ chọn bản đồ bộ nhớ. Trường này chọn cụ thể
                   đăng ký bản đồ bộ nhớ để truy cập.

ADDR (Bit 23..8) - Địa chỉ. Địa chỉ của người đăng ký đầu tiên trong
                   bản đồ bộ nhớ đã chọn để truy cập.

LEN (Bit 7..1) - Chiều dài. Chỉ định số lượng thanh ghi để đọc/ghi.
                 Trường này được hiểu là số lượng thanh ghi
                 trừ 1 cho phép đọc tối đa 128 thanh ghi liên tiếp
                 hoặc được viết bắt đầu từ địa chỉ được chỉ định trong ADDR. A
                 độ dài bằng 0 sẽ đọc hoặc ghi một thanh ghi.

P (Bit 0) - Tính chẵn lẻ. Bit chẵn lẻ được tính toán trên tiêu đề lệnh điều khiển.
            Phương pháp được sử dụng là phương pháp chẵn lẻ lẻ.

Giao dịch điều khiển bao gồm một hoặc nhiều lệnh điều khiển. Kiểm soát
các lệnh được máy chủ SPI sử dụng để đọc và ghi các thanh ghi trong
MAC-PHY. Mỗi lệnh điều khiển bao gồm một lệnh điều khiển 4 byte
tiêu đề theo sau là dữ liệu ghi đăng ký trong trường hợp lệnh ghi điều khiển.

MAC-PHY bỏ qua 4 byte dữ liệu cuối cùng từ máy chủ SPI ở cuối
của lệnh ghi điều khiển. Lệnh ghi điều khiển cũng được lặp lại
từ MAC-PHY quay lại máy chủ SPI để xác định đăng ký nào ghi
thất bại trong trường hợp có bất kỳ lỗi xe buýt. Lệnh ghi điều khiển được lặp lại sẽ
có 4 byte giá trị đầu tiên không được sử dụng bị máy chủ SPI bỏ qua
theo sau là tiêu đề điều khiển phản hồi 4 byte, theo sau là thanh ghi phản hồi
ghi dữ liệu. Lệnh ghi điều khiển có thể ghi vào một thanh ghi đơn hoặc
nhiều thanh ghi liên tiếp. Khi có nhiều thanh ghi liên tiếp
được viết, địa chỉ sẽ tự động được tăng sau bởi MAC-PHY.
Việc ghi vào bất kỳ thanh ghi nào chưa được thực hiện hoặc chưa được xác định sẽ bị bỏ qua và
không mang lại hiệu quả.

MAC-PHY bỏ qua tất cả dữ liệu từ máy chủ SPI theo điều khiển
tiêu đề cho phần còn lại của lệnh đọc điều khiển. Điều khiển đọc
lệnh cũng được lặp lại từ MAC-PHY trở lại máy chủ SPI để xác định
việc đọc đăng ký không thành công trong trường hợp có bất kỳ lỗi bus nào. Tiếng vang vọng
Lệnh đọc điều khiển sẽ có 4 byte giá trị chưa sử dụng đầu tiên được
bị máy chủ SPI bỏ qua, theo sau là tiêu đề điều khiển phản hồi 4 byte
bằng cách đăng ký đọc dữ liệu. Lệnh đọc điều khiển có thể đọc một
thanh ghi hoặc nhiều thanh ghi liên tiếp. Khi nhiều liên tiếp
các thanh ghi được đọc, địa chỉ sẽ tự động được tăng lên sau bởi
MAC-PHY. Đọc bất kỳ thanh ghi chưa được thực hiện hoặc không xác định sẽ trả về
không.

Trình điều khiển thiết bị API
==================

include/linux/oa_tc6.h xác định các hàm sau:

.. c:function:: struct oa_tc6 *oa_tc6_init(struct spi_device *spi, \
                                           struct net_device *netdev)

Khởi tạo lib OA TC6.

.. c:function:: void oa_tc6_exit(struct oa_tc6 *tc6)

Thư viện OA TC6 được phân bổ miễn phí.

.. c:function:: int oa_tc6_write_register(struct oa_tc6 *tc6, u32 address, \
                                          u32 value)

Viết một thanh ghi duy nhất trong MAC-PHY.

.. c:function:: int oa_tc6_write_registers(struct oa_tc6 *tc6, u32 address, \
                                           u32 value[], u8 length)

Viết nhiều thanh ghi liên tiếp bắt đầu từ @address trong MAC-PHY.
Tối đa 128 thanh ghi liên tiếp có thể được ghi bắt đầu từ @address.

.. c:function:: int oa_tc6_read_register(struct oa_tc6 *tc6, u32 address, \
                                         u32 *value)

Đọc một thanh ghi duy nhất trong MAC-PHY.

.. c:function:: int oa_tc6_read_registers(struct oa_tc6 *tc6, u32 address, \
                                          u32 value[], u8 length)

Đọc nhiều thanh ghi liên tiếp bắt đầu từ @address trong MAC-PHY.
Tối đa 128 thanh ghi liên tiếp có thể được đọc bắt đầu từ @address.

.. c:function:: netdev_tx_t oa_tc6_start_xmit(struct oa_tc6 *tc6, \
                                              struct sk_buff *skb);

Khung Ethernet truyền trong skb đang hoặc sẽ được truyền qua
MAC-PHY.

.. c:function:: int oa_tc6_zero_align_receive_frame_enable(struct oa_tc6 *tc6);

Tính năng khung nhận không căn chỉnh có thể được bật để căn chỉnh tất cả ethernet nhận
đóng khung dữ liệu để bắt đầu khi bắt đầu bất kỳ tải trọng dữ liệu nhận nào với một
độ lệch từ bắt đầu (SWO) bằng 0.