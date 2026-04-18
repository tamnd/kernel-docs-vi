.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/spi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Giao diện ngoại vi nối tiếp (SPI)
=================================

SPI là "Giao diện ngoại vi nối tiếp", được sử dụng rộng rãi với các thiết bị nhúng
hệ thống vì nó có giao diện đơn giản và hiệu quả: về cơ bản là một
thanh ghi dịch chuyển đa kênh. Ba dây tín hiệu của nó chứa một đồng hồ (SCK,
thường trong phạm vi 1-20 MHz), dữ liệu "Master Out, Slave In" (MOSI)
và một dòng dữ liệu "Master In, Slave Out" (MISO). SPI là đầy đủ
giao thức song công; đối với mỗi bit được dịch chuyển ra dòng MOSI (một bit trên mỗi đồng hồ)
một cái khác được chuyển vào dòng MISO. Những bit đó được tập hợp lại thành
các từ có kích cỡ khác nhau trên đường đến và đi từ bộ nhớ hệ thống. Một
dòng chipselect bổ sung thường ở mức hoạt động thấp (nCS); bốn tín hiệu là
thường được sử dụng cho từng thiết bị ngoại vi, đôi khi còn có một ngắt.

Các cơ sở xe buýt SPI được liệt kê ở đây cung cấp giao diện tổng quát cho
khai báo các xe buýt và thiết bị SPI, quản lý chúng theo tiêu chuẩn
Mô hình trình điều khiển Linux và thực hiện các thao tác đầu vào/đầu ra. Vào lúc này,
chỉ hỗ trợ các giao diện bên "chính", trong đó Linux nói chuyện với SPI
thiết bị ngoại vi và không thực hiện chính thiết bị ngoại vi đó. (Giao diện
để hỗ trợ triển khai các nô lệ SPI nhất thiết phải trông khác.)

Giao diện lập trình được cấu trúc xung quanh hai loại trình điều khiển và
hai loại thiết bị. "Trình điều khiển bộ điều khiển" trừu tượng hóa bộ điều khiển
phần cứng, có thể đơn giản như một bộ chân GPIO hoặc phức tạp như
một cặp FIFO được kết nối với động cơ DMA kép ở phía bên kia của
Thanh ghi dịch chuyển SPI (tối đa hóa thông lượng). Những trình điều khiển như vậy là cầu nối giữa
bất kể họ ngồi trên xe buýt nào (thường là xe buýt sân ga) và SPI, đồng thời phơi bày
phía SPI của thiết bị của họ dưới dạng ZZ0000ZZ. Các thiết bị SPI là con của chủ nhân đó,
được biểu diễn dưới dạng ZZ0001ZZ và
được sản xuất từ ​​các bộ mô tả ZZ0002ZZ thường được cung cấp bởi
mã khởi tạo dành riêng cho bảng. ZZ0003ZZ được gọi là "Trình điều khiển giao thức" và được liên kết với một
spi_device bằng cách sử dụng lệnh gọi mô hình trình điều khiển thông thường.

Mô hình I/O là một tập hợp các thông điệp được xếp hàng đợi. Trình điều khiển giao thức gửi một
hoặc nhiều đối tượng ZZ0000ZZ,
được xử lý và hoàn thành không đồng bộ. (Có đồng bộ
Tuy nhiên, các trình bao bọc.) Tin nhắn được xây dựng từ một hoặc nhiều
Đối tượng ZZ0001ZZ, mỗi đối tượng
bao gồm quá trình chuyển SPI song công hoàn toàn. Một loạt các tinh chỉnh giao thức
cần có các tùy chọn vì các chip khác nhau áp dụng các
chính sách về cách họ sử dụng các bit được truyền bằng SPI.

.. kernel-doc:: include/linux/spi/spi.h
   :internal:

.. kernel-doc:: drivers/spi/spi.c
   :functions: spi_register_board_info

.. kernel-doc:: drivers/spi/spi.c
   :export:
