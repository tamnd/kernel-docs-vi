.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/linux/access-coordinates.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

=====================================
Tính toán tọa độ truy cập CXL
=====================================

Tính toán độ trễ và băng thông
=================================
Tọa độ hiệu suất vùng bộ nhớ (độ trễ và băng thông) thường là
được cung cấp qua các bảng ACPI ZZ0000ZZ và
ZZ0001ZZ. Tuy nhiên, phần sụn nền tảng (BIOS) là
không thể chú thích những thông tin đó cho các thiết bị CXL được cắm nóng vì chúng làm như vậy
không tồn tại trong quá trình khởi tạo phần mềm nền tảng. Trình điều khiển CXL có thể tính toán
tọa độ hiệu suất bằng cách lấy dữ liệu từ một số thành phần.

ZZ0000ZZ cung cấp mối quan hệ cổng chung
bảng phụ liên kết một miền lân cận với một bộ điều khiển thiết bị, trong trường hợp này
sẽ là cầu nối máy chủ CXL. Sử dụng liên kết này, hiệu suất
tọa độ cho Cổng chung có thể được lấy từ
Bảng phụ ZZ0001ZZ. Phần này đại diện cho
tọa độ hiệu suất giữa CPU và Cổng chung (cầu nối máy chủ CXL).

ZZ0000ZZ cung cấp tọa độ hiệu suất cho
chính thiết bị CXL. Đó là băng thông và độ trễ để truy cập vào thiết bị đó
vùng bộ nhớ. Bảng phụ DSMAS cung cấp một DSMADHandle được gắn với một
Phạm vi địa chỉ vật lý của thiết bị (DPA). Bảng phụ DSLBIS cung cấp
tọa độ hiệu suất được gắn với một DSMADhandle và điều này liên kết cả hai
các mục trong bảng cùng nhau để cung cấp tọa độ hiệu suất cho mỗi DPA
khu vực. Ví dụ: nếu một thiết bị xuất vùng DRAM và vùng PMEM,
thì sẽ có những đặc điểm hiệu suất khác nhau cho mỗi đặc tính đó
các vùng.

Nếu có một công tắc CXL trong cấu trúc liên kết thì tọa độ hiệu suất cho
switch được cung cấp bởi bảng phụ SSLBIS. Điều này cung cấp băng thông và độ trễ
để đi qua công tắc giữa cổng ngược dòng của công tắc và công tắc
cổng xuôi dòng trỏ đến thiết bị đầu cuối.

Ví dụ cấu trúc liên kết đơn giản::

GP0/HB0/ACPI0016-0
        RP0
         |
         | L0
         |
     SW 0 / USP0
     SW 0 / DSP0
         |
         | L1
         |
        EP0

Trong ví dụ này, có một chuyển đổi CXL giữa điểm cuối và cổng gốc.
Độ trễ trong ví dụ này được tính như sau:
L(EP0) - Độ trễ từ EP0 CDAT DSMAS+DSLBIS
L(L1) - Độ trễ liên kết giữa EP0 và SW0DSP0
L(SW0) - Độ trễ cho chuyển đổi từ SW0 CDAT SSLBIS.
L(L0) - Độ trễ liên kết giữa SW0 và RP0
L(RP0) - Độ trễ từ cổng gốc đến CPU qua SRAT và HMAT (Cổng chung).
Tổng độ trễ đọc và ghi là tổng của tất cả các phần này.

Băng thông trong ví dụ này được tính như sau:
B(EP0) - Băng thông từ EP0 CDAT DSMAS+DSLBIS
B(L1) - Băng thông liên kết giữa EP0 và SW0DSP0
B(SW0) - Băng thông cho bộ chuyển mạch từ SW0 CDAT SSLBIS.
B(L0) - Băng thông liên kết giữa SW0 và RP0
B(RP0) - Băng thông từ cổng gốc đến CPU qua SRAT và HMAT (Cổng chung).
Tổng băng thông đọc và ghi là min() của tất cả các phần này.

Để tính toán băng thông liên kết:
LinkOperatingFrequency (GT/s) là tốc độ liên kết được thương lượng hiện tại.
DataRatePerLink (MB/s) = LinkOperatingFrequency / 8
Băng thông (MB/s) = PCIeCurrentLinkWidth * DataRatePerLink
Trong đó PCIeCurrentLinkWidth là số làn trong liên kết.

Để tính độ trễ liên kết:
Độ trễ liên kết (pico giây) = FlitSize / Băng thông liên kết (MB/s)

Xem ZZ0000ZZ,
phần 2.11.3 và 2.11.4 để biết chi tiết.

Cuối cùng, tọa độ truy cập cho vùng bộ nhớ được xây dựng được tính từ một
hoặc nhiều phân vùng bộ nhớ từ mỗi thiết bị CXL.

Tính toán liên kết ngược dòng được chia sẻ
==========================================
Đối với việc xây dựng vùng CXL nhất định với các điểm cuối phía sau bộ chuyển mạch CXL (SW) hoặc
Cổng gốc (RP), có khả năng tổng băng thông cho tất cả
các điểm cuối đằng sau một công tắc lớn hơn liên kết ngược dòng của công tắc.
Tình huống tương tự có thể xảy ra bên trong máy chủ, ngược dòng của cổng gốc.
Trình điều khiển CXL thực hiện một lượt bổ sung sau khi tất cả các mục tiêu đã
đến một vùng để tính toán lại băng thông có thể
liên kết ngược dòng là một yếu tố hạn chế trong tâm trí.

Thuật toán giả định cấu hình là một cấu trúc liên kết đối xứng vì
tối đa hóa hiệu suất. Khi phát hiện cấu trúc liên kết bất đối xứng, việc tính toán
bị hủy bỏ. Một cấu trúc liên kết không đối xứng được phát hiện trong quá trình đi bộ cấu trúc liên kết trong đó
số lượng RP được phát hiện với tư cách là ông bà không bằng số lượng thiết bị
lặp trong cùng một vòng lặp. Giả định được thực hiện một cách tinh tế
sự bất đối xứng về các thuộc tính không xảy ra và tất cả các đường dẫn đến EP đều bằng nhau.

Có thể có nhiều switch trong một RP. Có thể có nhiều RP dưới
Cầu chủ CXL (HB). Có thể có nhiều HB trong Bộ nhớ cố định CXL
Cấu trúc cửa sổ (CFMWS) trong ZZ0000ZZ.

Một hệ thống phân cấp ví dụ::

CFMWS 0
                  |
         _________|_________
        ZZ0000ZZ
    ACPI0017-0 ACPI0017-1
 GP0/HB0/ACPI0016-0 GP1/HB1/ACPI0016-1
    ZZ0001ZZ ZZ0002ZZ
   RP0 RP1 RP2 RP3
    ZZ0003ZZ ZZ0004ZZ
  SW 0 SW 1 SW 2 SW 3
  ZZ0005ZZ ZZ0006ZZ ZZ0007ZZ ZZ0008ZZ
 EP0 EP1 EP2 EP3 EP4 EP5 EP6 EP7

Tính toán cho hệ thống phân cấp ví dụ:

Tối thiểu (GP0 đến CPU BW,
     Tối thiểu (SW 0 Liên kết ngược dòng tới RP0 BW,
         Tối thiểu (SW0SSLBIS cho SW0DSP0 (EP0), EP0 DSLBIS, EP0 Liên kết ngược dòng) +
         Tối thiểu(SW0SSLBIS cho SW0DSP1 (EP1), EP1 DSLBIS, EP1 Liên kết ngược dòng)) +
     Min(SW 1 Liên kết ngược dòng tới RP1 BW,
         Tối thiểu (SW1SSLBIS cho SW1DSP0 (EP2), EP2 DSLBIS, EP2 Liên kết ngược dòng) +
         Tối thiểu(SW1SSLBIS cho SW1DSP1 (EP3), EP3 DSLBIS, EP3 Liên kết ngược dòng))) +
Tối thiểu (GP1 đến CPU BW,
     Min(SW 2 Liên kết ngược dòng tới RP2 BW,
         Tối thiểu (SW2SSLBIS cho SW2DSP0 (EP4), EP4 DSLBIS, EP4 Liên kết ngược dòng) +
         Tối thiểu(SW2SSLBIS cho SW2DSP1 (EP5), EP5 DSLBIS, EP5 Liên kết ngược dòng)) +
     Min(SW 3 Liên kết ngược dòng tới RP3 BW,
         Tối thiểu (SW3SSLBIS cho SW3DSP0 (EP6), EP6 DSLBIS, EP6 Liên kết ngược dòng) +
         Tối thiểu(SW3SSLBIS cho SW3DSP1 (EP7), EP7 DSLBIS, EP7 Liên kết ngược dòng))))

Quá trình tính toán bắt đầu tại cxl_khu vực_shared_upstream_perf_update(). Một mảng xarray
được tạo để thu thập tất cả băng thông điểm cuối thông qua
hàm cxl_endpoint_gather_bandwidth(). Min() của băng thông từ
điểm cuối CDAT và băng thông liên kết ngược dòng được tính toán. Nếu điểm cuối
có bộ chuyển đổi CXL làm cha mẹ, sau đó là băng thông được tính toán tối thiểu và
băng thông từ SSLBIS cho cổng hạ lưu của bộ chuyển mạch được liên kết
với điểm cuối được tính toán. Băng thông cuối cùng được lưu trữ trong một
'struct cxl_perf_ctx' trong xarray được con trỏ thiết bị lập chỉ mục. Nếu
điểm cuối được gắn trực tiếp vào cổng gốc (RP), con trỏ thiết bị sẽ là một
thiết bị RP. Nếu điểm cuối nằm phía sau một switch, con trỏ thiết bị sẽ là
thiết bị ngược dòng của switch chính.

Ở giai đoạn tiếp theo, mã sẽ đi qua một hoặc nhiều công tắc nếu chúng tồn tại
trong cấu trúc liên kết. Đối với các điểm cuối được gắn trực tiếp vào RP, bước này bị bỏ qua.
Nếu có một công tắc ngược dòng khác, mã sẽ lấy min() của dòng điện
băng thông tập hợp và băng thông liên kết ngược dòng. Nếu có một công tắc
ngược dòng, sau đó là SSLBIS của bộ chuyển mạch ngược dòng.

Khi bước đi trong cấu trúc liên kết đến RP, cho dù đó là điểm cuối được gắn trực tiếp hay không
hoặc đi qua (các) công tắc, cxl_rp_gather_bandwidth() sẽ được gọi. Tại
tại thời điểm này, tất cả băng thông được tổng hợp trên mỗi cầu nối máy chủ, tức là
cũng là chỉ mục cho xarray kết quả.

Bước tiếp theo là lấy giá trị min() của băng thông trên mỗi cầu nối máy chủ và
băng thông từ Cổng chung (GP). Băng thông cho GP được lấy
thông qua các bảng ACPI (ZZ0000ZZ và
ZZ0001ZZ). Băng thông tối thiểu được tổng hợp
trong cùng một thiết bị ACPI0017 để tạo thành một xarray mới.

Cuối cùng, cxl_khu vực_update_bandwidth() được gọi và tổng hợp
băng thông từ tất cả các thành viên của xarray cuối cùng được cập nhật cho
tọa độ truy cập nằm trong ngữ cảnh vùng cxl (cxlr).

ID QTG
======
Mỗi ZZ0000ZZ có trường ID QTG. Trường này cung cấp
ID liên kết với Nhóm điều chỉnh QoS (QTG) cho cửa sổ CFMWS.
Khi tọa độ truy cập được tính toán, Phương pháp dành riêng cho thiết bị ACPI có thể
được cấp cho thiết bị ACPI0016 để lấy ID QTG tùy thuộc vào quyền truy cập
tọa độ được cung cấp. ID QTG cho thiết bị có thể được sử dụng làm hướng dẫn để khớp
vào CFMWS để thiết lập bộ giải mã gốc Linux tốt nhất cho hiệu suất của thiết bị.