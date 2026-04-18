.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm64/arm-acpi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================
ACPI trên hệ thống Arm
===================

ACPI có thể được sử dụng cho các hệ thống Armv8 và Armv9 được thiết kế để tuân theo
BSA (Kiến trúc hệ thống cơ sở cánh tay) [0] và BBR (Arm
Yêu cầu khởi động cơ bản) [1] thông số kỹ thuật.  Cả BSA và BBR đều được công khai
các tài liệu có thể truy cập được.
Máy chủ Arm, ngoài việc tuân thủ BSA, còn tuân thủ một bộ
của các quy tắc được xác định trong SBSA (Kiến trúc hệ thống cơ sở máy chủ) [2].

Nhân Arm triển khai mô hình phần cứng rút gọn của phiên bản ACPI
5.1 trở lên.  Liên kết đến đặc điểm kỹ thuật và tất cả các tài liệu bên ngoài
nó đề cập đến được quản lý bởi Diễn đàn UEFI.  Đặc điểm kỹ thuật là
có sẵn tại ZZ0000ZZ và các tài liệu được tham khảo
theo đặc điểm kỹ thuật có thể được tìm thấy thông qua ZZ0001ZZ

Nếu hệ thống Arm không đáp ứng các yêu cầu của BSA và BBR,
hoặc không thể được mô tả bằng các cơ chế được xác định trong ACPI được yêu cầu
thông số kỹ thuật thì ACPI có thể không phù hợp với phần cứng.

Mặc dù các tài liệu nêu trên đặt ra các yêu cầu cho việc xây dựng
hệ thống Arm tiêu chuẩn công nghiệp, chúng cũng áp dụng cho nhiều hoạt động
hệ thống.  Mục đích của tài liệu này là mô tả sự tương tác giữa
Chỉ ACPI và Linux, trên hệ thống Arm -- tức là điều mà Linux mong đợi
ACPI và những gì ACPI có thể mong đợi ở Linux.


Tại sao ACPI trên cánh tay?
----------------
Trước khi kiểm tra chi tiết về giao diện giữa ACPI và Linux,
hữu ích để hiểu tại sao ACPI lại được sử dụng.  Một số công nghệ đã
Rốt cuộc, tồn tại trong Linux để mô tả phần cứng không thể đếm được.  Trong này
phần chúng tôi tóm tắt một bài đăng trên blog [3] từ Grant Có khả năng phác thảo
lý do đằng sau ACPI trên hệ thống Arm.  Thực ra, chúng tôi đã chôm được một phần lớn
thành thật mà nói, văn bản tóm tắt gần như trực tiếp.

Dạng cơ bản ngắn gọn của ACPI trên Arm là:

- Mã byte của ACPI (AML) cho phép nền tảng mã hóa hành vi phần cứng,
   trong khi DT rõ ràng không hỗ trợ điều này.  Đối với các nhà cung cấp phần cứng, việc
   có thể mã hóa hành vi là một công cụ quan trọng được sử dụng để hỗ trợ vận hành
   phát hành hệ thống trên phần cứng mới.

- OSPM của ACPI xác định mô hình quản lý năng lượng hạn chế những gì
   nền tảng được phép thực hiện thành một mô hình cụ thể trong khi vẫn cung cấp
   linh hoạt trong thiết kế phần cứng.

- Trong môi trường máy chủ doanh nghiệp, ACPI đã thiết lập các ràng buộc (như
   như RAS) hiện đang được sử dụng trong các hệ thống sản xuất.  DT thì không.
   Các ràng buộc như vậy có thể được xác định trong DT tại một thời điểm nào đó, nhưng làm như vậy có nghĩa là Arm
   và x86 sẽ sử dụng các đường dẫn mã hoàn toàn khác nhau trong cả hai phần sụn
   và hạt nhân.

- Lựa chọn một giao diện duy nhất để mô tả sự trừu tượng hóa giữa một nền tảng
   và một hệ điều hành là quan trọng.  Các nhà cung cấp phần cứng sẽ không bắt buộc phải triển khai
   cả DT và ACPI nếu chúng muốn hỗ trợ nhiều hệ điều hành.  Và,
   đồng ý về một giao diện duy nhất thay vì bị phân mảnh thành từng hệ điều hành
   giao diện làm cho khả năng tương tác tổng thể tốt hơn.

- Quy trình quản trị ACPI mới hoạt động tốt và Linux hiện tại cũng vậy
   table với tư cách là nhà cung cấp phần cứng và các nhà cung cấp hệ điều hành khác.  Trên thực tế, không có
   còn lý do gì để cảm thấy rằng ACPI chỉ thuộc về Windows hoặc
   Về mặt nào đó, Linux chỉ đứng sau Microsoft trong lĩnh vực này.  Sự di chuyển của
   Quản trị ACPI trong diễn đàn UEFI đã mở ra một cách đáng kể cơ hội
   quá trình phát triển đặc điểm kỹ thuật, và hiện tại, một phần lớn
   những thay đổi đang được thực hiện đối với ACPI đang được điều khiển bởi Linux.

Chìa khóa để sử dụng ACPI là mẫu hỗ trợ.  Đối với các máy chủ nói chung,
trách nhiệm về hoạt động của phần cứng không thể chỉ là phạm vi của
kernel mà đúng hơn là phải được phân chia giữa nền tảng và kernel, trong
để cho phép thay đổi có trật tự theo thời gian.  ACPI giải phóng hệ điều hành khỏi nhu cầu
để hiểu tất cả các chi tiết nhỏ của phần cứng để hệ điều hành không
cần phải được chuyển đến từng thiết bị riêng lẻ.  Nó cho phép
các nhà cung cấp phần cứng chịu trách nhiệm về hành vi quản lý năng lượng mà không cần
tùy thuộc vào chu kỳ phát hành hệ điều hành không nằm trong tầm kiểm soát của họ.

ACPI cũng rất quan trọng vì các nhà cung cấp phần cứng và hệ điều hành đã hoạt động
đưa ra các cơ chế hỗ trợ hệ sinh thái điện toán có mục đích chung.  các
Cơ sở hạ tầng đã sẵn sàng, các ràng buộc đã sẵn sàng và các quy trình đã sẵn sàng.
tại chỗ.  DT thực hiện chính xác những gì Linux cần khi làm việc theo chiều dọc
thiết bị tích hợp, nhưng không có quy trình tốt để hỗ trợ những gì
nhà cung cấp máy chủ cần.  Linux có khả năng đạt được điều đó với DT, nhưng làm như vậy
thực sự chỉ là sao chép một cái gì đó đã hoạt động.  ACPI đã làm được những gì rồi
các nhà cung cấp phần cứng cần, Microsoft sẽ không cộng tác trên DT và phần cứng
các nhà cung cấp cuối cùng vẫn sẽ cung cấp hai phần mềm hoàn toàn riêng biệt
giao diện - một cho Linux và một cho Windows.


Khả năng tương thích hạt nhân
--------------------
Một trong những động lực chính của ACPI là tiêu chuẩn hóa và sử dụng nó
để cung cấp khả năng tương thích ngược cho nhân Linux.  Trên thị trường máy chủ,
phần mềm và phần cứng thường được sử dụng trong thời gian dài.  ACPI cho phép
kernel và firmware để thống nhất về một sự trừu tượng nhất quán có thể được
được duy trì theo thời gian, ngay cả khi phần cứng hoặc phần mềm thay đổi.  Miễn là
sự trừu tượng được hỗ trợ, hệ thống có thể được cập nhật mà không nhất thiết phải có
để thay thế hạt nhân.

Khi trình điều khiển hoặc hệ thống con Linux được triển khai lần đầu tiên bằng ACPI, nó sẽ
định nghĩa cuối cùng yêu cầu một phiên bản cụ thể của đặc tả ACPI
-- đường cơ sở của nó.  Phần sụn ACPI phải tiếp tục hoạt động, mặc dù có thể
không tối ưu, với phiên bản kernel sớm nhất cung cấp hỗ trợ đầu tiên
cho phiên bản cơ bản của ACPI.  Có thể cần có thêm trình điều khiển,
nhưng việc thêm chức năng mới (ví dụ: quản lý nguồn CPU) sẽ không bị hỏng
phiên bản hạt nhân cũ hơn.  Hơn nữa, phần sụn ACPI cũng phải hoạt động với hầu hết
phiên bản gần đây của kernel.


Mối quan hệ với cây thiết bị
-----------------------------
Hỗ trợ ACPI trong trình điều khiển và hệ thống con cho Arm không bao giờ được hỗ trợ lẫn nhau
độc quyền với sự hỗ trợ DT tại thời điểm biên dịch.

Khi khởi động kernel sẽ chỉ sử dụng một phương thức mô tả tùy thuộc vào
các tham số được truyền từ bộ tải khởi động (bao gồm cả bootargs kernel).

Bất kể sử dụng DT hay ACPI, kernel phải luôn có khả năng
khởi động bằng một trong hai sơ đồ (trong hạt nhân có cả hai sơ đồ được kích hoạt khi biên dịch
thời gian).


Khởi động bằng bảng ACPI
-------------------------
Phương thức được xác định duy nhất để chuyển các bảng ACPI tới kernel trên Arm
thông qua bảng cấu hình hệ thống UEFI.  Chỉ để nó rõ ràng, điều này
có nghĩa là ACPI chỉ được hỗ trợ trên các nền tảng khởi động qua UEFI.

Khi hệ thống Arm khởi động, nó có thể có thông tin DT, bảng ACPI,
hoặc trong một số trường hợp rất bất thường, cả hai.  Nếu không có tham số dòng lệnh nào được sử dụng,
hạt nhân sẽ cố gắng sử dụng DT để liệt kê thiết bị; nếu không có DT
hiện tại, kernel sẽ cố gắng sử dụng các bảng ACPI, nhưng chỉ khi chúng có mặt.
Nếu không có sẵn thì kernel sẽ không khởi động được.  Nếu acpi=force được sử dụng
trên dòng lệnh, kernel sẽ cố gắng sử dụng các bảng ACPI trước tiên, nhưng
quay lại DT nếu không có bảng ACPI.  Ý tưởng cơ bản là
kernel sẽ không khởi động được trừ khi nó hoàn toàn không có lựa chọn nào khác.

Việc xử lý các bảng ACPI có thể bị vô hiệu hóa bằng cách chuyển acpi=off trên kernel
dòng lệnh; đây là hành vi mặc định.

Để kernel tải và sử dụng các bảng ACPI, việc triển khai UEFI
MUST đặt ACPI_20_TABLE_GUID để trỏ đến bảng RSDP (bảng có
chữ ký ACPI "RSD PTR ").  Nếu con trỏ này sai và acpi=force
được sử dụng, kernel sẽ vô hiệu hóa ACPI và thay vào đó thử sử dụng DT để khởi động; cái
trên thực tế, kernel đã xác định rằng các bảng ACPI không có ở đó
điểm.

Nếu con trỏ tới bảng RSDP đúng, bảng sẽ được ánh xạ vào
kernel bằng lõi ACPI, sử dụng địa chỉ do UEFI cung cấp.

Sau đó, lõi ACPI sẽ định vị và ánh xạ trong tất cả các bảng ACPI khác được cung cấp bởi
sử dụng các địa chỉ trong bảng RSDP để tìm XSDT (Hệ thống eXtends
Bảng mô tả).  XSDT lần lượt cung cấp địa chỉ cho tất cả các thiết bị khác
Các bảng ACPI được cung cấp bởi phần sụn hệ thống; lõi ACPI sau đó sẽ đi qua
bảng này và bản đồ trong các bảng được liệt kê.

Lõi ACPI sẽ bỏ qua mọi RSDT (Bảng mô tả hệ thống gốc) được cung cấp.
RSDT không được dùng nữa và bị bỏ qua trên arm64 vì chúng chỉ cho phép
cho các địa chỉ 32 bit.

Hơn nữa, lõi ACPI sẽ chỉ sử dụng các trường địa chỉ 64 bit trong FADT
(Đã sửa Bảng mô tả ACPI).  Bất kỳ trường địa chỉ 32-bit nào trong FADT sẽ
bị bỏ qua trên arm64.

Chế độ giảm phần cứng (xem Phần 4.1 của thông số kỹ thuật ACPI 6.1) sẽ
được thực thi bởi lõi ACPI trên arm64.  Làm như vậy cho phép lõi ACPI
chạy mã ít phức tạp hơn vì nó không còn phải cung cấp hỗ trợ cho các mã cũ
phần cứng từ các kiến trúc khác.  Bất kỳ trường nào không được sử dụng cho
chế độ giảm phần cứng phải được đặt thành 0.

Để lõi ACPI hoạt động bình thường và từ đó cung cấp thông tin
kernel cần cấu hình các thiết bị, nó hy vọng sẽ tìm thấy những thứ sau
các bảng (tất cả các số phần đều tham khảo thông số kỹ thuật ACPI 6.5):

- RSDP (Con trỏ mô tả hệ thống gốc), phần 5.2.5

- XSDT (Bảng mô tả hệ thống eXtends), phần 5.2.8

- FADT (Bảng mô tả ACPI đã sửa lỗi), phần 5.2.9

- DSDT (Bảng mô tả hệ thống khác biệt), phần
       5.2.11.1

- MADT (Bảng mô tả nhiều APIC), mục 5.2.12

- GTDT (Bảng mô tả bộ hẹn giờ chung), phần 5.2.24

- PPTT (Bảng cấu trúc liên kết thuộc tính bộ xử lý), phần 5.2.30

- DBG2 (cổng DeBuG bảng 2), mục 5.2.6, cụ thể là Bảng 5-6.

- APMT (Bảng đơn vị giám sát hiệu suất cánh tay), phần 5.2.6, cụ thể là Bảng 5-6.

- AGDI (Bảng giao diện thiết bị đặt lại và kết xuất chẩn đoán chung của Arm), phần 5.2.6, cụ thể là Bảng 5-6.

- Nếu PCI được hỗ trợ, MCFG (Cấu hình ánh xạ bộ nhớ
       Bảng), phần 5.2.6, cụ thể là Bảng 5-6.

- Nếu khởi động mà không có tham số kernel console=<device> thì
       được hỗ trợ, SPCR (Bảng chuyển hướng bảng điều khiển cổng nối tiếp),
       phần 5.2.6, cụ thể là Bảng 5-6.

- Nếu cần mô tả cấu trúc liên kết I/O, SMMU và GIC ITS,
       IORT (Bảng ánh xạ lại đầu ra đầu vào, phần 5.2.6, cụ thể là
       Bảng 5-6).

- Nếu NUMA được hỗ trợ, cần có các bảng sau:

- SRAT (Bảng quan hệ tài nguyên hệ thống), phần 5.2.16

- SLIT (Bảng thông tin khoảng cách địa phương của hệ thống), phần 5.2.17

- Nếu NUMA được hỗ trợ và hệ thống chứa bộ nhớ không đồng nhất,
       HMAT (Bảng thuộc tính bộ nhớ không đồng nhất), phần 5.2.28.

- Nếu cần có Giao diện lỗi nền tảng ACPI, hãy làm như sau
       các bảng được yêu cầu có điều kiện:

- BERT (Bảng ghi lỗi khởi động, phần 18.3.1)

- EINJ (Bảng INJection lỗi, phần 18.6.1)

- ERST (Bảng tuần tự hóa bản ghi lỗi, phần 18.5)

- HEST (Bảng nguồn lỗi phần cứng, phần 18.3.2)

- SDEI (Bảng Giao diện ngoại lệ được ủy quyền của phần mềm, phần 5.2.6,
         cụ thể là Bảng 5-6)

- AEST (Bảng nguồn lỗi cánh tay, phần 5.2.6,
         cụ thể là Bảng 5-6)

- RAS2 (Bảng tính năng ACPI RAS2, phần 5.2.21)

- Nếu hệ thống chứa bộ điều khiển sử dụng kênh PCC,
       PCCT (Bảng kênh truyền thông nền tảng), phần 14.1

- Nếu hệ thống chứa bộ điều khiển để ghi lại trạng thái hệ thống ở cấp độ bảng mạch,
       và liên lạc với máy chủ thông qua PCC, PDTT (Trình kích hoạt gỡ lỗi nền tảng
       Bảng), mục 5.2.29.

- Nếu NVDIMM được hỗ trợ, NFIT (Bảng giao diện chương trình cơ sở NVDIMM), phần 5.2.26

- Nếu có bộ đệm khung video, BGRT (Bảng tài nguyên đồ họa khởi động), phần 5.2.23

- Nếu IPMI được triển khai, SPMI (Giao diện quản lý nền tảng máy chủ),
       phần 5.2.6, cụ thể là Bảng 5-6.

- Nếu hệ thống chứa Cầu máy chủ CXL, CEDT (CXL Early Discovery
       Bảng), phần 5.2.6, cụ thể là Bảng 5-6.

- Nếu hệ thống hỗ trợ MPAM, MPAM (Bảng giám sát và phân vùng bộ nhớ), phần 5.2.6,
       cụ thể là Bảng 5-6.

- Nếu hệ thống thiếu bộ lưu trữ liên tục, IBFT (ISCSI Boot Firmware
       Bảng), phần 5.2.6, cụ thể là Bảng 5-6.


Nếu không có tất cả các bảng trên thì kernel có thể có hoặc không
có khả năng khởi động đúng cách vì nó có thể không cấu hình được tất cả các
các thiết bị có sẵn.  Danh sách các bảng này không có nghĩa là bao gồm tất cả;
trong một số môi trường, các bảng khác có thể cần thiết (ví dụ: bất kỳ bảng APEI nào
bảng từ phần 18) để hỗ trợ chức năng cụ thể.


Phát hiện ACPI
--------------
Trình điều khiển nên xác định loại thăm dò() của mình bằng cách kiểm tra giá trị rỗng
giá trị cho ACPI_HANDLE hoặc kiểm tra .of_node hoặc thông tin khác trong
cấu trúc thiết bị.  Điều này được trình bày chi tiết hơn trong phần "Trình điều khiển
phần Khuyến nghị".

Trong mã không phải trình điều khiển, nếu cần phát hiện sự hiện diện của ACPI tại
thời gian chạy, sau đó kiểm tra giá trị của acpi_disabled. Nếu CONFIG_ACPI không
được đặt, acpi_disabled sẽ luôn là 1.


Liệt kê thiết bị
------------------
Mô tả thiết bị trong ACPI phải sử dụng giao diện ACPI tiêu chuẩn được công nhận.
Những thông tin này có thể chứa ít thông tin hơn thông tin thường được cung cấp qua Thiết bị
Mô tả cây cho cùng một thiết bị.  Đây cũng là một trong những lý do khiến
ACPI có thể hữu ích -- trình điều khiển tính đến việc nó có thể có ít
thông tin chi tiết về thiết bị và thay vào đó sử dụng các giá trị mặc định hợp lý.
Nếu thực hiện đúng trình điều khiển, phần cứng có thể thay đổi và cải thiện hơn
thời gian mà không cần phải thay đổi tài xế.

Đồng hồ cung cấp một ví dụ tuyệt vời.  Trong DT, đồng hồ cần được chỉ định
và người lái xe cần phải tính đến chúng.  Trong ACPI, giả định
là UEFI sẽ để thiết bị ở trạng thái mặc định hợp lý, bao gồm
bất kỳ cài đặt đồng hồ nào.  Nếu vì lý do nào đó người lái xe cần thay đổi đồng hồ
giá trị, điều này có thể được thực hiện bằng phương pháp ACPI; tất cả những gì người lái xe cần làm là
gọi phương thức và không quan tâm đến việc phương thức đó cần làm gì
để thay đổi đồng hồ.  Việc thay đổi phần cứng sau đó có thể diễn ra theo thời gian
bằng cách thay đổi những gì phương thức ACPI thực hiện chứ không phải trình điều khiển.

Trong DT, các thông số cần thiết của driver để thiết lập đồng hồ như trong ví dụ
ở trên được gọi là "ràng buộc"; trong ACPI, chúng được gọi là "Thuộc tính thiết bị"
và cung cấp cho trình điều khiển thông qua đối tượng _DSD.

Các bảng ACPI được mô tả bằng ngôn ngữ chính thức có tên ASL, ACPI
Ngôn ngữ nguồn (phần 19 của thông số kỹ thuật).  Điều này có nghĩa là có
luôn có nhiều cách để mô tả cùng một thứ -- bao gồm cả thiết bị
tài sản.  Ví dụ: thuộc tính thiết bị có thể sử dụng cấu trúc ASL
trông như thế này: Tên(KEY0, "value0").  Trình điều khiển thiết bị ACPI sẽ
sau đó lấy giá trị của thuộc tính bằng cách đánh giá đối tượng KEY0.
Tuy nhiên, sử dụng Name() theo cách này có nhiều vấn đề: (1) giới hạn ACPI
tên ("KEY0") thành bốn ký tự không giống DT; (2) không có ngành công nghiệp
sổ đăng ký rộng rãi duy trì danh sách tên, giảm thiểu việc sử dụng lại; (3)
cũng không có cơ quan đăng ký nào định nghĩa các giá trị thuộc tính ("value0"),
một lần nữa làm cho việc tái sử dụng trở nên khó khăn; và (4) làm thế nào để duy trì sự lạc hậu
khả năng tương thích khi phần cứng mới xuất hiện?  Phương thức _DSD đã được tạo
để giải quyết chính xác những loại vấn đề này; Trình điều khiển Linux nên ALWAYS
sử dụng phương pháp _DSD cho các thuộc tính của thiết bị và không có gì khác.

Đối tượng _DSM (ACPI Mục 9.14.1) cũng có thể được sử dụng để truyền tải
thuộc tính thiết bị cho trình điều khiển.  Trình điều khiển Linux chỉ nên mong đợi nó
được sử dụng nếu _DSD không thể biểu diễn dữ liệu được yêu cầu và không có cách nào
để tạo một UUID mới cho đối tượng _DSD.  Lưu ý rằng thậm chí còn ít hơn
quy định về việc sử dụng _DSM so với _DSD.  Trình điều khiển phụ thuộc
về nội dung của các đối tượng _DSM sẽ khó duy trì hơn
thời gian vì điều này; tính đến thời điểm viết bài này, việc sử dụng _DSM là nguyên nhân
có khá nhiều vấn đề về phần sụn và không được khuyến khích.

Trình điều khiển nên tìm kiếm các thuộc tính thiết bị trong đối tượng _DSD ONLY; _DSD
đối tượng được mô tả trong phần thông số kỹ thuật ACPI 6.2.5, nhưng điều này chỉ
mô tả cách xác định cấu trúc của một đối tượng được trả về thông qua _DSD và
cách cấu trúc dữ liệu cụ thể được xác định bởi UUID cụ thể.  Linux nên
chỉ sử dụng Thuộc tính thiết bị _DSD UUID [4]:

- UUID: daffd814-6eba-4d8c-8a91-bc9bbf4aa301

Các thuộc tính thiết bị chung có thể được đăng ký bằng cách tạo yêu cầu kéo tới [4] để
rằng chúng có thể được sử dụng trên tất cả các hệ điều hành hỗ trợ ACPI.
Có thể sử dụng các thuộc tính thiết bị chưa được đăng ký với Diễn đàn UEFI
nhưng không phải là thuộc tính chung "uefi-".

Trước khi tạo thuộc tính thiết bị mới, hãy kiểm tra để chắc chắn rằng chúng chưa
đã được xác định trước đó và được đăng ký trong tài liệu nhân Linux
dưới dạng liên kết DT hoặc Diễn đàn UEFI dưới dạng thuộc tính thiết bị.  Trong khi chúng tôi không muốn
chỉ cần di chuyển tất cả các liên kết DT vào thuộc tính thiết bị ACPI, chúng ta có thể học hỏi từ
những gì đã được xác định trước đó.

Nếu cần xác định một thuộc tính thiết bị mới hoặc nếu điều đó hợp lý
tổng hợp định nghĩa của một ràng buộc để nó có thể được sử dụng trong bất kỳ phần sụn nào,
cả liên kết DT và thuộc tính thiết bị ACPI cho trình điều khiển thiết bị đều được xem xét
quá trình.  Sử dụng cả hai.  Khi bản thân trình điều khiển được gửi để xem xét
vào danh sách gửi thư của Linux, các định nghĩa thuộc tính thiết bị cần có phải là
nộp cùng một lúc.  Trình điều khiển hỗ trợ ACPI và sử dụng thiết bị
các thuộc tính sẽ không được coi là hoàn chỉnh nếu không có định nghĩa của chúng.  Một lần
thuộc tính thiết bị đã được cộng đồng Linux chấp nhận thì nó phải
đã đăng ký với Diễn đàn UEFI [4], diễn đàn này sẽ xem xét lại để đảm bảo tính nhất quán
trong sổ đăng ký.  Điều này có thể yêu cầu lặp lại.  Tuy nhiên, Diễn đàn UEFI,
sẽ luôn là trang web chuẩn cho các định nghĩa thuộc tính thiết bị.

Sẽ có ý nghĩa nếu cung cấp thông báo cho Diễn đàn UEFI rằng có
ý định đăng ký tên thuộc tính thiết bị chưa được sử dụng trước đây làm phương tiện
giữ lại tên để sử dụng sau.  Các nhà cung cấp hệ điều hành khác sẽ
cũng đang gửi yêu cầu đăng ký và điều này có thể giúp quá trình thực hiện diễn ra suôn sẻ
quá trình.

Khi việc đăng ký và xem xét đã hoàn tất, kernel sẽ cung cấp một
giao diện để tra cứu thuộc tính thiết bị theo cách độc lập với
DT hay ACPI đang được sử dụng.  Nên sử dụng API này [5]; nó có thể
loại bỏ một số trùng lặp đường dẫn mã trong các chức năng thăm dò trình điều khiển và
không khuyến khích sự khác biệt giữa các liên kết DT và thuộc tính thiết bị ACPI.


Tài nguyên điều khiển nguồn có thể lập trình
------------------------------------
Các tài nguyên điều khiển công suất có thể lập trình bao gồm các tài nguyên như điện áp/dòng điện
nhà cung cấp (cơ quan quản lý) và nguồn đồng hồ.

Với ACPI, khung điều chỉnh và đồng hồ kernel dự kiến sẽ không được sử dụng
không hề.

Hạt nhân giả định rằng việc kiểm soát sức mạnh của các tài nguyên này được thể hiện bằng
Đối tượng tài nguyên nguồn (ACPI phần 7.1).  Lõi ACPI sau đó sẽ xử lý
kích hoạt và vô hiệu hóa chính xác các tài nguyên khi cần thiết.  để
để điều đó hoạt động, ACPI giả định rằng mỗi thiết bị đều có trạng thái D được xác định và những trạng thái này
có thể được điều khiển thông qua các phương thức ACPI tùy chọn _PS0, _PS1, _PS2 và _PS3;
trong ACPI, _PS0 là phương thức gọi để bật hoàn toàn thiết bị và _PS3 dành cho
tắt hoàn toàn thiết bị.

Có hai tùy chọn để sử dụng các Nguồn năng lượng đó.  Họ có thể:

- được quản lý theo phương thức _PSx được gọi khi cấp nguồn
      trạng thái Dx.

- được khai báo riêng dưới dạng tài nguyên năng lượng với _ON và _OFF của riêng chúng
      phương pháp.  Sau đó, chúng được gắn trở lại trạng thái D cho một thiết bị cụ thể
      thông qua _PRx chỉ định nguồn điện nào thiết bị cần bật
      khi ở Dx.  Kernel sau đó theo dõi số lượng thiết bị sử dụng nguồn điện
      và gọi _ON/_OFF nếu cần.

Mã ACPI kernel cũng sẽ giả định rằng các phương thức _PSx tuân theo thông thường
Quy tắc ACPI cho các phương pháp như vậy:

- Nếu _PS0 hoặc _PS3 được triển khai thì phương pháp kia cũng phải
      được thực hiện.

- Nếu thiết bị yêu cầu sử dụng hoặc thiết lập nguồn điện khi bật, ASL
      nên sắp xếp để nó được phân bổ/kích hoạt bằng phương pháp _PS0.

- Tài nguyên được phân bổ hoặc kích hoạt trong phương thức _PS0 phải bị tắt
      hoặc hủy phân bổ trong phương pháp _PS3.

- Firmware sẽ để tài nguyên ở trạng thái hợp lý trước khi bàn giao
      quyền kiểm soát đối với kernel.

Mã như vậy trong các phương thức _PSx tất nhiên sẽ rất cụ thể về nền tảng.  Nhưng,
điều này cho phép trình điều khiển trừu tượng hóa giao diện vận hành thiết bị
và tránh phải đọc các giá trị không chuẩn đặc biệt từ các bảng ACPI. Hơn nữa,
trừu tượng hóa việc sử dụng các tài nguyên này cho phép phần cứng thay đổi theo thời gian
mà không yêu cầu cập nhật trình điều khiển.


Đồng hồ
------
ACPI đưa ra giả định rằng đồng hồ được khởi tạo bởi phần sụn --
UEFI, trong trường hợp này -- tới một giá trị làm việc nào đó trước khi chuyển giao quyền kiểm soát
tới hạt nhân.  Điều này có ý nghĩa đối với các thiết bị như UART hoặc SoC-driven
Ví dụ: màn hình LCD.

Khi kernel khởi động, đồng hồ được coi là được đặt ở mức hợp lý
các giá trị làm việc.  Nếu vì lý do nào đó mà tần số cần thay đổi -- ví dụ:
điều chỉnh để quản lý nguồn -- trình điều khiển thiết bị sẽ mong đợi điều đó
quá trình được trừu tượng hóa thành một số phương thức ACPI có thể được gọi
(vui lòng xem thông số kỹ thuật ACPI để biết thêm khuyến nghị về tiêu chuẩn
phương pháp được mong đợi).  Ngoại lệ duy nhất cho điều này là đồng hồ CPU trong đó
CPPC cung cấp giao diện phong phú hơn nhiều so với các phương pháp ACPI.  Nếu đồng hồ
chưa được thiết lập thì Linux không có cách nào trực tiếp để kiểm soát chúng.

Nếu nhà cung cấp SoC muốn cung cấp khả năng kiểm soát chi tiết về đồng hồ hệ thống,
họ có thể làm như vậy bằng cách cung cấp các phương thức ACPI mà Linux có thể gọi ra
trình điều khiển.  Tuy nhiên, đây là NOT được khuyến nghị và trình điều khiển Linux nên sử dụng NOT
những phương pháp như vậy, ngay cả khi chúng được cung cấp.  Những phương pháp như vậy hiện nay không
được tiêu chuẩn hóa trong đặc tả ACPI và việc sử dụng chúng có thể buộc một hạt nhân
với một SoC rất cụ thể hoặc gắn SoC với một phiên bản rất cụ thể của
kernel, cả hai điều chúng tôi đang cố gắng tránh.


Khuyến nghị của người lái xe
----------------------
NÊN NOT loại bỏ mọi thao tác xử lý DT khi thêm hỗ trợ ACPI cho trình điều khiển.  các
cùng một thiết bị có thể được sử dụng trên nhiều hệ thống khác nhau.

NÊN cố gắng cấu trúc trình điều khiển sao cho nó dựa trên dữ liệu.  Tức là thiết lập
một cấu trúc chứa trạng thái nội bộ trên mỗi thiết bị dựa trên giá trị mặc định và bất cứ điều gì
phần còn lại phải được phát hiện bởi chức năng thăm dò trình điều khiển.  Sau đó, có phần còn lại
của trình điều khiển hoạt động dựa trên nội dung của cấu trúc đó.  Làm như vậy nên
cho phép giữ hầu hết sự khác biệt giữa chức năng ACPI và DT
chức năng thăm dò thay vì nằm rải rác khắp trình điều khiển.  Ví dụ::

int tĩnh device_probe_dt(struct platform_device *pdev)
  {
         /* Chức năng cụ thể của DT */
         ...
  }

int tĩnh device_probe_acpi(struct platform_device *pdev)
  {
         /* Chức năng cụ thể của ACPI */
         ...
  }

static int device_probe(struct platform_device *pdev)
  {
         ...
struct device_node node = pdev->dev.of_node;
         ...

nếu (nút)
                 ret = device_probe_dt(pdev);
         khác nếu (ACPI_HANDLE(&pdev->dev))
                 ret = device_probe_acpi(pdev);
         khác
                 /*khởi tạo khác */
                 ...
/* Tiếp tục với mọi thao tác thăm dò chung */
         ...
  }

NÊN giữ các mục MODULE_DEVICE_TABLE cùng nhau trong trình điều khiển để tạo nó
xóa các tên khác nhau mà trình điều khiển được thăm dò, cả từ DT và từ
ACPI::

cấu trúc tĩnh of_device_id virtio_mmio_match[] = {
          { .tương thích = "virtio,mmio", },
          { }
  };
  MODULE_DEVICE_TABLE(của, virtio_mmio_match);

cấu trúc const tĩnh acpi_device_id virtio_mmio_acpi_match[] = {
          { "LNRO0005", },
          { }
  };
  MODULE_DEVICE_TABLE(acpi, virtio_mmio_acpi_match);


ASWG
----
Thông số kỹ thuật của ACPI thay đổi thường xuyên.  Chẳng hạn, trong năm 2014,
phiên bản 5.1 đã được phát hành và phiên bản 6.0 đã hoàn thiện cơ bản, với hầu hết
những thay đổi được thúc đẩy bởi các yêu cầu dành riêng cho Arm.  Những thay đổi được đề xuất là
được trình bày và thảo luận trong ASWG (Nhóm công tác đặc tả ACPI)
là một phần của Diễn đàn UEFI.  Phiên bản hiện tại của thông số kỹ thuật ACPI
là phiên bản 6.5 được phát hành vào tháng 8 năm 2022.

Tất cả thành viên UEFI đều có thể tham gia vào nhóm này.  Xin vui lòng xem
ZZ0000ZZ để biết chi tiết về tư cách thành viên nhóm.

Mục đích của mã hạt nhân Arm ACPI là tuân theo đặc tả ACPI
chặt chẽ nhất có thể và chỉ triển khai chức năng tuân thủ
các tiêu chuẩn được phát hành từ UEFI ASWG.  Về mặt thực tiễn, sẽ có
nhà cung cấp cung cấp bảng ACPI không tốt hoặc vi phạm tiêu chuẩn theo một cách nào đó.
Nếu điều này là do lỗi thì có thể cần phải có những điều kỳ quặc và sửa chữa, nhưng sẽ
tránh được nếu có thể.  Nếu có những tính năng bị thiếu trong ACPI sẽ ngăn cản
không được sử dụng trên nền tảng, ECR (Yêu cầu thay đổi kỹ thuật) phải được
gửi tới ASWG và trải qua quá trình phê duyệt thông thường; dành cho những người đó
không phải là thành viên UEFI, nhiều thành viên khác của cộng đồng Linux đang và sẽ
có khả năng sẵn sàng hỗ trợ gửi ECR.


Mã Linux
----------
Các mục riêng lẻ dành riêng cho Linux trên Arm, có trong Linux
mã nguồn, nằm trong danh sách sau:

ACPI_OS_NAME
                       Macro này xác định chuỗi được trả về khi
                       một phương thức ACPI gọi phương thức _OS.  Trên tay
                       hệ thống, macro này sẽ là "Linux" theo mặc định.
                       Tham số dòng lệnh acpi_os=<string>
                       có thể được sử dụng để đặt nó thành một số giá trị khác.  các
                       giá trị mặc định cho các kiến trúc khác là "Microsoft
                       Windows NT” chẳng hạn.

Đối tượng ACPI
------------
Kỳ vọng chi tiết cho các bảng và đối tượng ACPI được liệt kê trong tệp
Tài liệu/arch/arm64/acpi_object_usage.rst.


Tài liệu tham khảo
----------
[0] ZZ0000ZZ
    tài liệu Arm-DEN-0094: "Arm Base System Architecture", phiên bản 1.0C, ngày 6 tháng 10 năm 2022

[1] ZZ0000ZZ
    Tài liệu Arm-DEN-0044: "Yêu cầu khởi động đế cánh tay", phiên bản 2.0G, ngày 15 tháng 4 năm 2022

[2] ZZ0000ZZ
    Tài liệu Arm-DEN-0029: "Arm Server Base System Architecture", phiên bản 7.1, ngày 06 tháng 10 năm 2022

[3] ZZ0000ZZ
    Ngày 10 tháng 1 năm 2015, Bản quyền (c) 2015,
    Linaro Ltd., được viết bởi Grant Likely.

[4] Hướng dẫn triển khai _DSD (Dữ liệu cụ thể của thiết bị)
    ZZ0000ZZ

[5] Mã hạt nhân cho thiết bị hợp nhất
    giao diện thuộc tính có thể được tìm thấy trong
    bao gồm/linux/property.h và driver/base/property.c.


tác giả
-------
- Al Stone <al.stone@linaro.org>
- Graeme Gregory <graeme.gregory@linaro.org>
- Quách Hanjun <hanjun.guo@linaro.org>

- Cấp có khả năng <grant.likely@linaro.org>, cho phần "Tại sao ACPI trên ARM?" phần
