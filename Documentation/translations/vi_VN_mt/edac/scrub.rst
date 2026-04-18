.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.2-no-invariants-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/edac/scrub.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==============
Kiểm soát chà
=============

Bản quyền (c) 2024-2025 HiSilicon Limited.

:Tác giả: Shiju Jose <shiju.jose@huawei.com>
:Giấy phép: Giấy phép Tài liệu Miễn phí GNU, Phiên bản 1.2 không có
           Các phần bất biến, Văn bản bìa trước cũng như Văn bản bìa sau.
           (được cấp phép kép theo GPL v2)

- Viết cho: 6.15

Giới thiệu
------------

Việc tăng kích thước và chi phí của DRAM đã làm cho độ tin cậy của hệ thống con bộ nhớ trở nên khó khăn hơn.
mối quan tâm quan trọng. Các mô-đun này được sử dụng khi dữ liệu có khả năng bị hỏng
có thể gây ra các vấn đề tốn kém hoặc gây tử vong. Lỗi bộ nhớ thuộc hàng đầu
lỗi phần cứng gây ra sự cố máy chủ và khối lượng công việc.

Lọc bộ nhớ là một tính năng trong đó công cụ ECC (Mã sửa lỗi)
đọc dữ liệu từ mỗi vị trí phương tiện bộ nhớ, sửa nếu cần thiết và ghi
dữ liệu đã sửa trở lại cùng một vị trí phương tiện bộ nhớ.

DIMM có thể được lọc ở tốc độ có thể định cấu hình để phát hiện bộ nhớ chưa được sửa
lỗi và cố gắng khôi phục từ các lỗi được phát hiện, cung cấp thông tin sau
lợi ích:

1. Chủ động dọn dẹp DIMM giúp giảm khả năng xảy ra lỗi có thể sửa được
   trở nên không thể sửa chữa được.

2. Khi được phát hiện, các lỗi chưa được sửa trong các trang bộ nhớ chưa được phân bổ sẽ được
   bị cô lập và ngăn chặn việc phân bổ cho một ứng dụng hoặc hệ điều hành.

3. Điều này làm giảm khả năng các sản phẩm phần mềm hoặc phần cứng gặp phải
   lỗi bộ nhớ.

4. Dữ liệu bổ sung về lỗi bộ nhớ có thể được sử dụng để xây dựng
   số liệu thống kê sau này được sử dụng để quyết định có nên sử dụng sửa chữa bộ nhớ hay không
   các công nghệ như Post Package Repair hoặc Sparing.

Có 2 kiểu xóa bộ nhớ:

1. Quét nền (tuần tra) trong khi DRAM không hoạt động.

2. Lọc theo yêu cầu đối với một dải địa chỉ hoặc vùng bộ nhớ cụ thể.

Một số loại giao diện cho bộ lọc bộ nhớ phần cứng đã được
đã xác định, chẳng hạn như tuần tra thiết bị bộ nhớ CXL, CXL DDR5 ECS, ACPI
Xóa bộ nhớ RAS2 và ACPI NVDIMM ARS (Xóa phạm vi địa chỉ).

Các cơ chế kiểm soát khác nhau tùy theo các bộ lọc bộ nhớ khác nhau. Để kích hoạt
công cụ không gian người dùng được tiêu chuẩn hóa, cần phải trình bày các điều khiển này
thông qua ABI được tiêu chuẩn hóa.

Bộ điều khiển xóa bộ nhớ chung EDAC cho phép người dùng quản lý cơ bản
bộ lọc trong hệ thống thông qua giao diện điều khiển sysfs được tiêu chuẩn hóa.  Nó
trừu tượng hóa việc quản lý các chức năng lọc khác nhau thành một thống nhất
tập hợp các chức năng.

Các trường hợp sử dụng tính năng kiểm soát chà phổ biến
-----------------------------------------

1. Một số loại giao diện dành cho bộ lọc bộ nhớ phần cứng đã được
   đã được xác định, bao gồm cả quá trình tuần tra thiết bị bộ nhớ CXL, CXL DDR5 ECS,
   Các tính năng xóa bộ nhớ ACPI RAS2, ACPI NVDIMM ARS (Xóa phạm vi địa chỉ),
   và bộ lọc bộ nhớ dựa trên phần mềm.

Trong số các giao diện được xác định cho bộ lọc bộ nhớ phần cứng, một số hỗ trợ
   kiểm soát việc lọc tuần tra (nền) (ví dụ: ACPI RAS2, CXL) và/hoặc
   chà theo yêu cầu (ví dụ: ACPI RAS2, ACPI ARS). Tuy nhiên, việc kiểm soát chà
   giao diện khác nhau giữa các bộ lọc bộ nhớ, làm nổi bật sự cần thiết của
   một giao diện điều khiển quét sysfs chung, được tiêu chuẩn hóa mà có thể truy cập được
   không gian người dùng để quản trị và sử dụng bởi các tập lệnh/công cụ.

2. Kiểm soát xóa không gian người dùng cho phép người dùng vô hiệu hóa việc xóa nếu cần thiết,
   ví dụ: để tắt tính năng lọc tuần tra nền hoặc điều chỉnh tính năng lọc
   tỷ lệ cho các hoạt động nhận thức hiệu suất trong đó các hoạt động nền cần
   được giảm thiểu hoặc vô hiệu hóa.

3. Các công cụ trong không gian người dùng cho phép lọc theo yêu cầu đối với các dải địa chỉ cụ thể,
   với điều kiện là máy chà sàn hỗ trợ chức năng này.

4. Các công cụ trong không gian người dùng cũng có thể kiểm soát việc dọn dẹp bộ nhớ DIMM ở mức có thể định cấu hình
   tốc độ chà thông qua các điều khiển chà sysfs. Cách tiếp cận này mang lại một số lợi ích:

4.1. Phát hiện sớm các lỗi bộ nhớ không thể sửa được trước khi người dùng truy cập vào các phần bị ảnh hưởng
        trí nhớ, giúp dễ dàng phục hồi.

4.2. Giảm khả năng các lỗi có thể sửa được phát triển thành các lỗi không thể sửa được
        lỗi.

5. Kiểm soát chính sách cho bộ nhớ được cắm nóng là cần thiết vì có thể không có
   là BIOS trên toàn hệ thống hoặc điều khiển tương tự để quản lý cài đặt chà cho CXL
   thiết bị được thêm vào sau khi khởi động. Việc xác định các cài đặt này là một quyết định chính sách,
   cân bằng độ tin cậy với hiệu suất, vì vậy không gian người dùng nên kiểm soát nó.
   Vì vậy, nên sử dụng một giao diện thống nhất để xử lý chức năng này trong
   một cách phù hợp với các giao diện tương tự khác, thay vì tạo ra một
   riêng biệt một cái.

Tính năng chà xát
------------------

Tính năng xóa bộ nhớ CXL
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CXL spec r3.1 [1]_ phần 8.2.9.9.11.1 mô tả việc tuần tra thiết bị bộ nhớ
tính năng kiểm soát chà. Bộ phận tuần tra thiết bị chủ động xác định vị trí và thực hiện
sửa chữa các lỗi trong chu kỳ thường xuyên. Việc kiểm soát chà tuần tra cho phép
yêu cầu không gian người dùng để thay đổi cấu hình của máy lọc tuần tra CXL.

Kiểm soát chà tuần tra cho phép người yêu cầu chỉ định số lượng
số giờ mà chu kỳ tuần tra phải được hoàn thành, với điều kiện là
tốc độ lọc được yêu cầu phải nằm trong phạm vi được hỗ trợ của
tốc độ chà mà thiết bị có thể thực hiện được. Trong trình điều khiển CXL,
số giây cho mỗi chu kỳ lọc mà người dùng yêu cầu thông qua sysfs là
được điều chỉnh lại thành số giờ cho mỗi chu kỳ chà.

Ngoài ra, chúng còn cho phép chủ nhà tắt tính năng này trong trường hợp nó cản trở
với các hoạt động nhận biết hiệu suất yêu cầu các hoạt động nền để
được tắt.

Kiểm tra lỗi chà (ECS)
~~~~~~~~~~~~~~~~~~~~~~~

CXL spec r3.1 [1]_ phần 8.2.9.9.11.2 mô tả Kiểm tra lỗi (ECS)
- một tính năng được xác định trong Thông số kỹ thuật JEDEC DDR5 SDRAM (JESD79-5) và
cho phép DRAM đọc nội bộ, sửa các lỗi bit đơn và ghi lại
đã sửa các bit dữ liệu thành mảng DRAM đồng thời cung cấp tính minh bạch cho lỗi
tính.

Thiết bị DDR5 chứa số lượng Đơn vị có thể thay thế trường phương tiện bộ nhớ (FRU)
mỗi thiết bị. Tính năng DDR5 ECS và do đó trình điều khiển ECS hỗ trợ
định cấu hình các tham số ECS cho mỗi FRU.

ACPI RAS2 Xóa bộ nhớ dựa trên phần cứng
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ACPI spec 6.5 [2]_ phần 5.2.21 ACPI RAS2 mô tả bảng ACPI RAS2
cung cấp giao diện cho các tính năng của nền tảng RAS và hỗ trợ độc lập
Các điều khiển và khả năng của RAS cho một tính năng RAS nhất định cho nhiều phiên bản
của cùng một thành phần trong một hệ thống nhất định.

Các tính năng của bộ nhớ RAS áp dụng cho các khả năng, điều khiển và hoạt động của RAS
đặc trưng cho trí nhớ. Không gian con RAS2 PCC dành cho các tính năng RAS dành riêng cho bộ nhớ
có Loại tính năng là 0x00 (Bộ nhớ).

Nền tảng này có thể sử dụng tính năng lọc bộ nhớ dựa trên phần cứng để hiển thị
các điều khiển và khả năng liên quan đến việc xóa bộ nhớ dựa trên phần cứng
động cơ. Tính năng lọc bộ nhớ RAS2 hỗ trợ theo thông số kỹ thuật,

1. Các điều khiển lọc bộ nhớ độc lập cho từng miền NUMA, được xác định
   sử dụng miền lân cận của nó.

2. Cung cấp khả năng quét nền (tuần tra) toàn bộ hệ thống bộ nhớ,
   cũng như xóa theo yêu cầu cho một vùng bộ nhớ cụ thể.

Xóa phạm vi địa chỉ ACPI (ARS)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Thông số ACPI 6.5 [2]_ phần 9.19.7.2 mô tả Xóa phạm vi địa chỉ (ARS).
ARS cho phép nền tảng truyền đạt lỗi bộ nhớ tới phần mềm hệ thống.
Khả năng này cho phép phần mềm hệ thống ngăn chặn việc truy cập vào các địa chỉ bằng
những lỗi không thể sửa được trong bộ nhớ. Các chức năng ARS quản lý tất cả các NVDIMM có trong
hệ thống. Chỉ có một lần chà có thể được thực hiện trên toàn hệ thống tại bất kỳ thời điểm nào.

Các chức năng sau được hỗ trợ theo thông số kỹ thuật:

1. Khả năng truy vấn ARS cho một dải địa chỉ nhất định, cho biết nền tảng
   hỗ trợ Thông báo lỗi không sử dụng được của thiết bị gốc ACPI NVDIMM.

2. Khởi động ARS kích hoạt Xóa phạm vi địa chỉ cho phạm vi bộ nhớ nhất định.
   Việc xóa địa chỉ có thể được thực hiện đối với bộ nhớ dễ thay đổi hoặc liên tục hoặc cả hai.

3. Lệnh Truy vấn trạng thái ARS cho phép phần mềm lấy trạng thái ARS,
   bao gồm cả tiến trình ghi lại lỗi ARS và ARS.

4. Xóa lỗi không thể sửa được.

5. Dịch SPA

6. Chèn lỗi ARS, v.v.

Hạt nhân hỗ trợ điều khiển hiện có cho ARS và ARS hiện không hỗ trợ
được hỗ trợ trong EDAC.

.. [1] https://computeexpresslink.org/cxl-specification/

.. [2] https://uefi.org/specs/ACPI/6.5/

So sánh các tính năng chà khác nhau
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

+--------------+----------+----------+----------+----------+
 ZZ0000ZZ ACPI ZZ0001ZZ CXL ECS ZZ0002ZZ
 ZZ0003ZZ RAS2 ZZ0004ZZ ZZ0005ZZ
 +--------------+----------+----------+----------+----------+
 ZZ0006ZZ ZZ0007ZZ ZZ0008ZZ
 ZZ0009ZZ Được hỗ trợ ZZ0010ZZ Không có ZZ0011ZZ
 ZZ0012ZZ ZZ0013ZZ ZZ0014ZZ
 ZZ0015ZZ ZZ0016ZZ ZZ0017ZZ
 +--------------+----------+----------+----------+----------+
 ZZ0018ZZ ZZ0019ZZ ZZ0020ZZ
 ZZ0021ZZ được hỗ trợ ZZ0022ZZ được hỗ trợ ZZ0023ZZ
 ZZ0024ZZ ZZ0025ZZ ZZ0026ZZ
 ZZ0027ZZ ZZ0028ZZ ZZ0029ZZ
 +--------------+----------+----------+----------+----------+
 ZZ0030ZZ ZZ0031ZZ ZZ0032ZZ
 ZZ0033ZZ Chà ctrl| per device| trên mỗi bộ nhớ|  Unknown  |
 ZZ0036ZZ trên NUMA ZZ0037ZZ phương tiện truyền thông ZZ0038ZZ
 Tên miền ZZ0039ZZ.   ZZ0040ZZ ZZ0041ZZ
 +--------------+----------+----------+----------+----------+
 ZZ0042ZZ ZZ0043ZZ ZZ0044ZZ
 ZZ0045ZZ được hỗ trợ ZZ0046ZZ được hỗ trợ ZZ0047ZZ
 ZZ0048ZZ ZZ0049ZZ ZZ0050ZZ
 ZZ0051ZZ ZZ0052ZZ ZZ0053ZZ
 +--------------+----------+----------+----------+----------+
 ZZ0054ZZ ZZ0055ZZ ZZ0056ZZ
 ZZ0057ZZ Được hỗ trợ ZZ0058ZZ Không có ZZ0059ZZ
 ZZ0060ZZ ZZ0061ZZ ZZ0062ZZ
 ZZ0063ZZ ZZ0064ZZ ZZ0065ZZ
 +--------------+----------+----------+----------+----------+
 ZZ0066ZZ ZZ0067ZZ ZZ0068ZZ
 ZZ0069ZZ Được hỗ trợ ZZ0070ZZ Không có ZZ0071ZZ
 ZZ0072ZZ ZZ0073ZZ ZZ0074ZZ
 ZZ0075ZZ ZZ0076ZZ ZZ0077ZZ
 +--------------+----------+----------+----------+----------+
 ZZ0078ZZ ZZ0079ZZ ZZ0080ZZ
 ZZ0081ZZ Không phải ZZ0082ZZ Không ZZ0083ZZ
 ZZ0084ZZ Được xác định ZZ0085ZZ ZZ0086ZZ
 ZZ0087ZZ ZZ0088ZZ ZZ0089ZZ
 +--------------+----------+----------+----------+----------+
 ZZ0090ZZ Được hỗ trợ ZZ0091ZZ ZZ0092ZZ
 ZZ0093ZZ theo yêu cầu ZZ0094ZZ Không ZZ0095ZZ
 ZZ0096ZZ chà ZZ0097ZZ ZZ0098ZZ
 ZZ0099ZZ chỉ ZZ0100ZZ ZZ0101ZZ
 +--------------+----------+----------+----------+----------+
 ZZ0102ZZ ZZ0103ZZCXL chung| ACPI UCE  |
 ZZ0105ZZ Ngoại lệ |media/DRAM |media/DRAM ZZ0107ZZ
 ZZ0108ZZ |event/media|event/media| query     |
 ZZ0111ZZ |scan?      |scan?      ZZ0113ZZ
 +--------------+----------+----------+----------+----------+
 ZZ0114ZZ ZZ0115ZZ ZZ0116ZZ
 ZZ0117ZZ được hỗ trợ ZZ0118ZZ được hỗ trợ ZZ0119ZZ
 ZZ0120ZZ ZZ0121ZZ ZZ0122ZZ
 ZZ0123ZZ ZZ0124ZZ ZZ0125ZZ
 +--------------+----------+----------+----------+----------+

Hệ thống tập tin
---------------

Các thuộc tính điều khiển của một phiên bản bộ lọc đã đăng ký có thể là
truy cập vào:

/sys/bus/edac/devices/<dev-name>/scrubX/

sysfs
-----

Các tập tin Sysfs được ghi lại trong
ZZ0000ZZ

ZZ0000ZZ

Ví dụ
--------

Việc sử dụng có dạng như trong các ví dụ sau:

1. Tuần tra bộ nhớ CXL

Sau đây là các trường hợp sử dụng được xác định tại sao chúng tôi có thể tăng tốc độ loại bỏ.

- Cần phải lọc ở mức độ chi tiết của thiết bị vì thiết bị đang hiển thị
  lỗi cao bất ngờ.

- Việc xóa có thể áp dụng cho bộ nhớ chưa trực tuyến. Có khả năng là thế này
  là cài đặt mặc định trên toàn hệ thống khi khởi động.

- Chà với tốc độ cao hơn do phần mềm giám sát đã xác định rằng
  độ tin cậy cao hơn là cần thiết cho một tập dữ liệu cụ thể. Đây được gọi là
  Độ tin cậy khác biệt.

1.1. Quét dựa trên thiết bị

Bộ nhớ CXL được tiếp xúc với hệ thống con quản lý bộ nhớ và cuối cùng là không gian người dùng
thông qua các thiết bị CXL. Lọc dựa trên thiết bị được sử dụng cho trường hợp sử dụng đầu tiên
được mô tả trong "Phần 1 Quét tuần tra bộ nhớ CXL".

Khi kết hợp điều khiển thông qua giao diện thiết bị và giao diện vùng,
"xem Phần 1.2 Lọc theo khu vực".

Các tệp Sysfs để quét được ghi lại trong
ZZ0000ZZ

1.2. Lọc theo khu vực

Bộ nhớ CXL được tiếp xúc với hệ thống con quản lý bộ nhớ và cuối cùng là không gian người dùng
thông qua các vùng CXL. Vùng CXL thể hiện dung lượng bộ nhớ được ánh xạ trong hệ thống
không gian địa chỉ vật lý. Chúng có thể kết hợp một hoặc nhiều phần của nhiều CXL
thiết bị bộ nhớ có lưu lượng truy cập xen kẽ trên chúng. Người dùng có thể muốn kiểm soát
tốc độ loại bỏ thông qua vùng trừu tượng hơn này thay vì phải tìm ra
thiết bị cấu thành và lập trình chúng một cách riêng biệt. Tốc độ chà cho từng thiết bị
bao phủ toàn bộ thiết bị. Do đó, nếu nhiều vùng sử dụng các bộ phận của thiết bị đó thì
yêu cầu xóa các khu vực khác có thể dẫn đến tỷ lệ lọc cao hơn
được yêu cầu cho khu vực cụ thể này.

Việc lọc theo vùng được sử dụng cho trường hợp sử dụng thứ ba được mô tả trong
"Phần 1 Bộ lọc tuần tra bộ nhớ CXL".

Không gian người dùng phải tuân theo bộ quy tắc bên dưới về cách đặt tốc độ loại bỏ cho bất kỳ
hỗn hợp các yêu cầu.

1. Lần lượt lấy từng vùng từ tốc độ chà mong muốn thấp nhất đến cao nhất và đặt
   tỷ lệ chà của họ. Các vùng sau này có thể ghi đè tốc độ lọc trên từng vùng riêng lẻ
   thiết bị (và do đó có thể là toàn bộ khu vực).

2. Lấy từng thiết bị cần chà rửa nâng cao (tốc độ cao hơn) và
   thiết lập các tỷ lệ chà. Điều này sẽ ghi đè tốc độ lọc của từng thiết bị,
   đặt chúng ở mức tối đa cần thiết cho bất kỳ khu vực nào mà chúng trợ giúp,
   trừ khi một tỷ lệ cụ thể đã được xác định.

Các tệp Sysfs để quét được ghi lại trong
ZZ0000ZZ

2. Kiểm tra lỗi bộ nhớ CXL (ECS)

Tính năng Error Check Scrub (ECS) cho phép thiết bị bộ nhớ thực hiện lỗi
kiểm tra và sửa lỗi (ECC) và đếm các lỗi bit đơn. Liên quan
bộ điều khiển bộ nhớ đặt chế độ ECS với bộ kích hoạt được gửi đến bộ nhớ
thiết bị. Điều khiển CXL ECS cho phép máy chủ, tức là không gian người dùng, thay đổi
thuộc tính cho chế độ đếm lỗi, số ngưỡng lỗi trên mỗi phân đoạn
(cho biết có bao nhiêu phân đoạn có ít nhất số lỗi đó) cho
báo cáo lỗi và đặt lại bộ đếm ECS. Như vậy trách nhiệm đối với
bắt đầu Kiểm tra lỗi Xóa trên thiết bị bộ nhớ có thể nằm trong bộ nhớ
bộ điều khiển hoặc nền tảng khi phát hiện tỷ lệ lỗi cao bất ngờ.

Các tệp Sysfs để quét được ghi lại trong
ZZ0000ZZ