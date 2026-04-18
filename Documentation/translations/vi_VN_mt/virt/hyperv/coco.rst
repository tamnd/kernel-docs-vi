.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/virt/hyperv/coco.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Máy ảo điện toán bí mật
==========================
Hyper-V có thể tạo và chạy các máy khách Linux là Máy tính bí mật
(CoCo) máy ảo. Những máy ảo như vậy hợp tác với bộ xử lý vật lý để bảo vệ tốt hơn
tính bảo mật và toàn vẹn của dữ liệu trong bộ nhớ của VM, ngay cả trong
khuôn mặt của một trình ảo hóa/VMM đã bị xâm phạm và có thể có hành vi nguy hiểm.
Máy ảo CoCo trên Hyper-V chia sẻ bảo mật và mô hình mối đe dọa CoCo VM chung
mục tiêu được mô tả trong Tài liệu/bảo mật/snp-tdx-threat-model.rst. Lưu ý
mã cụ thể của Hyper-V trong Linux gọi máy ảo CoCo là "máy ảo biệt lập" hoặc
"VM cách ly".

Máy ảo Linux CoCo trên Hyper-V yêu cầu sự hợp tác và tương tác của
sau đây:

* Phần cứng vật lý với bộ xử lý hỗ trợ máy ảo CoCo

* Phần cứng chạy phiên bản Windows/Hyper-V có hỗ trợ máy ảo CoCo

* VM chạy phiên bản Linux hỗ trợ CoCo VM

Các yêu cầu phần cứng vật lý như sau:

* Bộ xử lý AMD với SEV-SNP. Hyper-V không chạy máy ảo khách với AMD SME,
  Mã hóa SEV hoặc SEV-ES và mã hóa như vậy là không đủ cho CoCo
  VM trên Hyper-V.

* Bộ xử lý Intel với TDX

Để tạo CoCo VM, thuộc tính "Isolated VM" phải được chỉ định cho Hyper-V
khi VM được tạo. Không thể thay đổi VM từ CoCo VM thành VM thông thường,
hoặc ngược lại sau khi được tạo.

Chế độ hoạt động
-----------------
Máy ảo Hyper-V CoCo có thể chạy ở hai chế độ. Chế độ được chọn khi VM được
được tạo và không thể thay đổi trong suốt vòng đời của VM.

* Chế độ hoàn toàn giác ngộ. Ở chế độ này, hệ điều hành khách được
  được khai sáng để hiểu và quản lý tất cả các khía cạnh của việc chạy như một máy ảo CoCo.

* Chế độ Paravisor. Trong chế độ này, một lớp paravisor giữa khách và
  máy chủ cung cấp một số thao tác cần thiết để chạy dưới dạng máy ảo CoCo. Khách điều hành
  hệ thống có thể có ít sự khai sáng CoCo hơn mức cần thiết trong
  trường hợp giác ngộ hoàn toàn.

Về mặt khái niệm, chế độ được khai sáng đầy đủ và chế độ paravisor có thể được coi là
các điểm trên một quang phổ bao trùm mức độ hiểu biết của khách cần thiết để chạy
dưới dạng máy ảo CoCo. Chế độ được khai sáng hoàn toàn là một đầu của quang phổ. đầy đủ
việc thực hiện chế độ paravisor là đầu kia của quang phổ, trong đó tất cả
các khía cạnh của việc chạy như một máy ảo CoCo được xử lý bởi bộ điều khiển và thông thường
Hệ điều hành khách không có kiến thức về mã hóa bộ nhớ hoặc các khía cạnh khác của máy ảo CoCo
có thể chạy thành công. Tuy nhiên, việc triển khai chế độ paravisor của Hyper-V
không đi xa đến mức này và nằm ở đâu đó ở giữa quang phổ. Một số
các khía cạnh của máy ảo CoCo được xử lý bởi paravisor Hyper-V trong khi hệ điều hành khách
phải được khai sáng về các khía cạnh khác. Thật không may, không có
liệt kê tiêu chuẩn hóa các tính năng/chức năng có thể được cung cấp trong
paravisor và không có cơ chế chuẩn hóa nào cho hệ điều hành khách truy vấn
paravisor cho tính năng/chức năng mà nó cung cấp. Sự hiểu biết về cái gì
paravisor cung cấp được mã hóa cứng trong hệ điều hành khách.

Chế độ Paravisor có những điểm tương đồng với ZZ0000ZZ, nhằm mục đích cung cấp
một công cụ hỗ trợ giới hạn để cung cấp dịch vụ cho khách, chẳng hạn như TPM ảo.
Tuy nhiên, paravisor Hyper-V thường xử lý nhiều khía cạnh hơn của máy ảo CoCo
hơn những gì được hình dung hiện nay đối với Dừa, và do đó tiến xa hơn tới mục tiêu "không
yêu cầu giác ngộ của khách" ở phần cuối của quang phổ.

.. _Coconut project: https://github.com/coconut-svsm/svsm

Trong mô hình mối đe dọa CoCo VM, paravisor nằm trong miền bảo mật khách
và phải được hệ điều hành khách tin cậy. Theo ngụ ý, bộ ảo hóa/VMM phải
tự bảo vệ mình trước một paravisor độc hại tiềm ẩn giống như nó
bảo vệ chống lại một vị khách có khả năng gây hại.

Cách tiếp cận kiến trúc phần cứng cho chế độ được khai sáng hoàn toàn so với chế độ paravisor
khác nhau tùy thuộc vào bộ xử lý cơ bản.

* Với bộ xử lý AMD SEV-SNP, ở chế độ được khai sáng hoàn toàn, hệ điều hành khách sẽ chạy trong đó
  VMPL 0 và có toàn quyền kiểm soát bối cảnh của khách. Trong chế độ paravisor,
  Hệ điều hành khách chạy trong VMPL 2 và paravisor chạy trong VMPL 0. Paravisor
  chạy trong VMPL 0 có những đặc quyền mà hệ điều hành khách trong VMPL 2 không có.
  Một số hoạt động nhất định yêu cầu khách gọi paravisor. Hơn nữa, trong
  chế độ paravisor, hệ điều hành khách hoạt động ở chế độ "Bộ nhớ ảo" (vTOM)
  như được định nghĩa bởi kiến trúc SEV-SNP. Chế độ này đơn giản hóa việc quản lý khách
  mã hóa bộ nhớ khi sử dụng paravisor.

* Với bộ xử lý Intel TDX, ở chế độ được chiếu sáng hoàn toàn, hệ điều hành khách sẽ chạy ở chế độ
  L1 VM. Trong chế độ paravisor, phân vùng TD được sử dụng. Trình paravisor chạy trong
  L1 VM và hệ điều hành khách chạy trong L2 VM lồng nhau.

Hyper-V hiển thị MSR tổng hợp cho khách mô tả chế độ CoCo. Cái này
MSR cho biết bộ xử lý cơ bản có sử dụng AMD SEV-SNP hoặc Intel TDX hay không, và
dù một paravisor đang được sử dụng. Thật đơn giản để xây dựng một
ảnh hạt nhân có thể khởi động và chạy đúng cách trên cả hai kiến trúc và trong
một trong hai chế độ.

Hiệu ứng Paravisor
-----------------
Chạy ở chế độ paravisor ảnh hưởng đến các khu vực sau của nhân Linux chung
Chức năng CoCo VM:

* Thiết lập bộ nhớ khách ban đầu. Khi một máy ảo mới được tạo ở chế độ paravisor,
  paravisor chạy trước và thiết lập bộ nhớ vật lý của khách dưới dạng được mã hóa. các
  Linux khách thực hiện khởi tạo bộ nhớ bình thường, ngoại trừ việc đánh dấu rõ ràng
  phạm vi thích hợp như được giải mã (được chia sẻ). Trong chế độ paravisor, Linux không
  thực hiện các bước thiết lập bộ nhớ khởi động ban đầu đặc biệt phức tạp với
  AMD SEV-SNP ở chế độ được chiếu sáng hoàn toàn.

* Xử lý ngoại lệ #VC/#VE. Trong chế độ paravisor, Hyper-V cấu hình máy khách
  CoCo VM để định tuyến các ngoại lệ #VC và #VE tới VMPL 0 và L1 VM,
  tương ứng chứ không phải Linux khách. Do đó, những trình xử lý ngoại lệ này
  không chạy trong Linux dành cho khách và không phải là sự hiểu biết cần thiết cho một
  Khách Linux ở chế độ paravisor.

* Cờ CPUID. Cả AMD SEV-SNP và Intel TDX đều cung cấp cờ CPUID trong
  khách cho biết VM đang hoạt động với phần cứng tương ứng
  hỗ trợ. Mặc dù các cờ CPUID này hiển thị trong các máy ảo CoCo đã được bật sáng hoàn toàn,
  trình paravisor lọc các cờ này và Linux khách không nhìn thấy chúng.
  Xuyên suốt nhân Linux, việc kiểm tra rõ ràng các cờ này hầu hết được thực hiện
  bị loại bỏ để nhường chỗ cho hàm cc_platform_has(), với mục tiêu là
  tóm tắt sự khác biệt giữa SEV-SNP và TDX. Nhưng
  Sự trừu tượng hóa cc_platform_has() cũng cho phép cấu hình paravisor Hyper-V
  để kích hoạt có chọn lọc các khía cạnh của chức năng CoCo VM ngay cả khi CPUID
  cờ không được đặt. Ngoại lệ là thiết lập bộ nhớ khởi động sớm trên SEV-SNP,
  kiểm tra cờ CPUID SEV-SNP. Nhưng không có cờ trong paravisor Hyper-V
  chế độ VM đạt được hiệu quả mong muốn hoặc không chạy SEV-SNP cụ thể sớm
  thiết lập bộ nhớ khởi động.

* Mô phỏng thiết bị. Trong chế độ paravisor, paravisor Hyper-V cung cấp
  mô phỏng các thiết bị như IO-APIC và TPM. Bởi vì việc mô phỏng
  xảy ra trong paravisor trong ngữ cảnh khách (thay vì hypervisor/VMM
  bối cảnh), thay vào đó, các truy cập MMIO vào các thiết bị này phải là các tham chiếu được mã hóa
  trong số các tài liệu tham khảo được giải mã sẽ được sử dụng trong CoCo được khai sáng đầy đủ
  VM. Hàm __ioremap_caller() đã được cải tiến để thực hiện cuộc gọi lại tới
  kiểm tra xem một dải địa chỉ cụ thể có nên được coi là mã hóa hay không
  (riêng tư). Xem lệnh gọi lại "is_private_mmio".

* Mã hóa/giải mã chuyển đổi bộ nhớ. Trong máy ảo CoCo, việc chuyển đổi khách
  bộ nhớ giữa được mã hóa và giải mã đòi hỏi phải phối hợp với
  trình ảo hóa/VMM. Điều này được thực hiện thông qua các cuộc gọi lại được gọi từ
  __set_memory_enc_pgtable(). Ở chế độ được chiếu sáng hoàn toàn, SEV-SNP bình thường và
  Việc triển khai TDX của các lệnh gọi lại này được sử dụng. Trong chế độ paravisor, Hyper-V
  tập hợp các cuộc gọi lại cụ thể được sử dụng. Những cuộc gọi lại này gọi paravisor để
  rằng paravisor có thể điều phối các quá trình chuyển đổi và thông báo cho hypervisor
  khi cần thiết. Xem hv_vtom_init() nơi thiết lập các lệnh gọi lại này.

* Tiêm gián đoạn. Ở chế độ được khai sáng đầy đủ, một trình ảo hóa độc hại
  đôi khi có thể đưa các ngắt vào hệ điều hành khách vi phạm x86/x64
  quy tắc kiến trúc. Để được bảo vệ đầy đủ, hệ điều hành khách nên bao gồm
  sự khai sáng sử dụng các tính năng quản lý tiêm ngắt được cung cấp
  bởi bộ xử lý có khả năng CoCo. Trong chế độ paravisor, paravisor làm trung gian
  làm gián đoạn việc đưa vào hệ điều hành khách và đảm bảo rằng chỉ hệ điều hành khách
  thấy các ngắt là "hợp pháp". Paravisor sử dụng phép tiêm ngắt
  các tính năng quản lý được cung cấp bởi bộ xử lý vật lý có khả năng CoCo, do đó
  che giấu những sự phức tạp này khỏi hệ điều hành khách.

Siêu cuộc gọi Hyper-V
------------------
Khi ở chế độ được bật sáng hoàn toàn, các siêu lệnh do máy khách Linux thực hiện sẽ được định tuyến
trực tiếp đến bộ ảo hóa, giống như trong máy ảo không phải CoCo. Nhưng ở chế độ paravisor,
các siêu lệnh thông thường sẽ bẫy paravisor trước tiên, từ đó có thể gọi ra
siêu giám sát. Nhưng paravisor có đặc điểm riêng về mặt này và một số ít
các siêu lệnh do máy khách Linux thực hiện phải luôn được định tuyến trực tiếp đến
siêu giám sát. Các trang web hypercall này kiểm tra sự hiện diện của paravisor và sử dụng
một chuỗi lời gọi đặc biệt. Xem hv_post_message() chẳng hạn.

Giao tiếp với khách với Hyper-V
--------------------------------
Tách biệt khỏi việc xử lý mã hóa bộ nhớ chung của nhân Linux trong Linux
CoCo VM, Hyper-V có các thiết bị VMBus và VMBus giao tiếp bằng bộ nhớ
được chia sẻ giữa máy khách Linux và máy chủ. Bộ nhớ dùng chung này phải được
được đánh dấu đã giải mã để cho phép liên lạc. Hơn nữa, vì mô hình mối đe dọa
bao gồm một máy chủ bị xâm nhập và có khả năng gây hại, khách phải bảo vệ
chống rò rỉ bất kỳ dữ liệu ngoài ý muốn nào đến máy chủ thông qua bộ nhớ dùng chung này.

Các trang bộ nhớ Hyper-V và VMBus này được đánh dấu là đã giải mã:

* Trang giám sát VMBus

* Các trang liên quan đến bộ điều khiển ngắt tổng hợp (SynIC) (trừ khi được cung cấp bởi
  người paravisor)

* Các trang đầu vào và đầu ra hypercall trên mỗi CPU (trừ khi chạy với paravisor)

* Bộ đệm vòng VMBus. Ánh xạ trực tiếp được đánh dấu là đã giải mã trong
  __vmbus_establish_gpadl(). Ánh xạ thứ cấp được tạo trong
  hv_ringbuffer_init() cũng phải bao gồm thuộc tính "đã giải mã".

Khi máy khách ghi dữ liệu vào bộ nhớ được chia sẻ với máy chủ, nó phải
đảm bảo rằng chỉ có dữ liệu dự định được ghi. Các trường đệm hoặc không sử dụng phải
được khởi tạo về số 0 trước khi sao chép vào bộ nhớ dùng chung sao cho ngẫu nhiên
dữ liệu kernel không vô tình được cung cấp cho máy chủ.

Tương tự, khi máy khách đọc bộ nhớ được chia sẻ với máy chủ, nó phải
xác thực dữ liệu trước khi hành động để máy chủ độc hại không thể gây ra
khách để lộ dữ liệu ngoài ý muốn. Thực hiện xác nhận như vậy có thể khó khăn
bởi vì máy chủ có thể sửa đổi các vùng bộ nhớ dùng chung ngay cả trong khi hoặc sau
xác nhận được thực hiện. Đối với các tin nhắn được truyền từ máy chủ đến khách trong một
Bộ đệm vòng VMBus, độ dài của tin nhắn được xác thực và tin nhắn được
được sao chép vào bộ đệm tạm thời (được mã hóa) để xác thực thêm và
xử lý. Việc sao chép làm tăng thêm một lượng chi phí nhỏ nhưng là cách duy nhất
để bảo vệ chống lại một máy chủ độc hại. Xem hv_pkt_iter_first().

Nhiều driver cho thiết bị VMBus đã được “cứng” bằng cách thêm code vào đầy đủ
xác thực các tin nhắn nhận được qua VMBus, thay vì cho rằng Hyper-V là
hành động hợp tác. Những trình điều khiển như vậy được đánh dấu là "allowed_in_isolat" trong
bảng vmbus_devs[]. Các trình điều khiển khác dành cho thiết bị VMBus không cần thiết trong
CoCo VM chưa được cứng hóa và chúng không được phép tải trong CoCo
VM. Xem vmbus_is_valid_offer() nơi loại trừ các thiết bị như vậy.

Hai thiết bị VMBus phụ thuộc vào máy chủ Hyper-V để thực hiện truyền dữ liệu DMA:
storvsc cho I/O đĩa và netvsc cho I/O mạng. storvsc sử dụng bình thường
API DMA của nhân Linux và do đó thoát khỏi bộ đệm thông qua swiotlb được giải mã
bộ nhớ được thực hiện ngầm. netvsc có hai chế độ để truyền dữ liệu. đầu tiên
chế độ đi qua không gian bộ đệm gửi và nhận được phân bổ rõ ràng
bởi trình điều khiển netvsc và được sử dụng cho hầu hết các gói nhỏ hơn. Chúng gửi và
bộ đệm nhận được đánh dấu là đã giải mã bằng __vmbus_establish_gpadl(). Bởi vì
trình điều khiển netvsc sao chép rõ ràng các gói đến/từ các bộ đệm này,
tương đương với việc đệm thoát giữa bộ nhớ được mã hóa và giải mã là
đã là một phần của đường dẫn dữ liệu. Chế độ thứ hai sử dụng kernel Linux bình thường
API DMA và được đệm thoát qua bộ nhớ swiotlb như trong
storvsc.

Cuối cùng, trình điều khiển PCI ảo VMBus cần xử lý đặc biệt trong CoCo VM.
Trình điều khiển thiết bị Linux PCI truy cập không gian cấu hình PCI bằng các API tiêu chuẩn được cung cấp
bởi hệ thống con Linux PCI. Trên Hyper-V, các chức năng này truy cập trực tiếp vào MMIO
không gian và các bẫy truy cập vào Hyper-V để mô phỏng. Nhưng trong máy ảo CoCo, bộ nhớ
mã hóa ngăn Hyper-V đọc luồng hướng dẫn khách tới
mô phỏng quyền truy cập. Vì vậy, trong máy ảo CoCo, các hàm này phải tạo một siêu lệnh gọi
với các đối số mô tả rõ ràng quyền truy cập. Xem
_hv_pcifront_read_config() và _hv_pcifront_write_config() và
Cờ "use_calls" cho biết sử dụng siêu lệnh gọi.

VMBus bí mật
------------------
VMBus bí mật cho phép khách bí mật không tương tác với
phân vùng máy chủ không đáng tin cậy và bộ ảo hóa không đáng tin cậy. Thay vào đó, vị khách
dựa vào paravisor đáng tin cậy để liên lạc với quá trình xử lý thiết bị
dữ liệu nhạy cảm. Phần cứng (SNP hoặc TDX) mã hóa bộ nhớ khách và
đăng ký trạng thái trong khi đo hình ảnh paravisor bằng cách sử dụng bảo mật nền tảng
bộ xử lý để đảm bảo tính toán đáng tin cậy và bí mật.

VMBus bí mật cung cấp kênh liên lạc an toàn giữa khách
và paravisor, đảm bảo rằng dữ liệu nhạy cảm được bảo vệ khỏi hypervisor-
cấp độ truy cập thông qua mã hóa bộ nhớ và cách ly trạng thái đăng ký.

VMBus bí mật là một phần mở rộng của máy ảo Điện toán bí mật (CoCo)
(hay còn gọi là máy ảo "Bị cô lập" trong thuật ngữ Hyper-V). Không có VMBus bí mật,
trình điều khiển thiết bị VMBus khách ("VSC" trong thuật ngữ VMBus) giao tiếp
với các máy chủ VMBus (VSP) đang chạy trên máy chủ Hyper-V. các
giao tiếp phải thông qua bộ nhớ đã được giải mã để
máy chủ có thể truy cập nó. Với VMBus bí mật, một hoặc nhiều VSP cư trú
trong lớp paravisor đáng tin cậy trong VM khách. Vì lớp paravisor cũng
hoạt động trong bộ nhớ được mã hóa, bộ nhớ được sử dụng để liên lạc với
các VSP như vậy không cần phải giải mã và do đó tiếp xúc với
Máy chủ Hyper-V. Paravisor chịu trách nhiệm liên lạc an toàn
với máy chủ Hyper-V khi cần thiết.

Dữ liệu được truyền trực tiếp giữa VM và thiết bị vPCI (a.k.a.
thiết bị chuyển tiếp PCI, xem ZZ0000ZZ) được gán trực tiếp cho VTL2
và hỗ trợ bộ nhớ được mã hóa. Trong trường hợp như vậy, cả phân vùng máy chủ đều không
Hypervisor cũng không có quyền truy cập vào dữ liệu. Khách cần thiết lập
kết nối VMBus chỉ với paravisor cho các kênh xử lý
dữ liệu nhạy cảm và paravisor tóm tắt các chi tiết giao tiếp
với các thiết bị cụ thể sẽ cung cấp cho khách những thông tin được thiết lập tốt
Giao diện VSP (Nhà cung cấp dịch vụ ảo) đã được hỗ trợ trong Hyper-V
tài xế trong một thập kỷ.

Trong trường hợp thiết bị không hỗ trợ bộ nhớ được mã hóa, paravisor
cung cấp bộ đệm thoát và mặc dù dữ liệu không được mã hóa, việc sao lưu
các trang không được ánh xạ vào phân vùng máy chủ thông qua SLAT. Tuy không phải là không thể,
việc phân vùng máy chủ lọc dữ liệu trở nên khó khăn hơn nhiều
hơn so với kết nối VMBus thông thường nơi phân vùng máy chủ
có quyền truy cập trực tiếp vào bộ nhớ được sử dụng để liên lạc.

Đây là luồng dữ liệu cho kết nối VMBus thông thường (ZZ0000ZZ là viết tắt của
máy khách hoặc VSC, ZZ0001ZZ cho máy chủ hoặc VSP, ZZ0002ZZ là một máy chủ vật lý, có thể
có nhiều chức năng ảo)::

+---- GUEST ----+ +------ DEVICE ----+ +---- HOST ------+
  ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ
  ZZ0003ZZ ZZ0004ZZ ZZ0005ZZ
  ZZ0006ZZ ZZ0007ZZ
  ZZ0008ZZ ZZ0009ZZ ZZ0010ZZ
  ZZ0011ZZ ZZ0012ZZ ZZ0013ZZ
  ZZ0014ZZ ZZ0015ZZ ZZ0016ZZ
  +------ C -------+ +-----------------+ +------- S ------+
         |ZZ0017ZZ|
         |ZZ0018ZZ|
  +------|ZZ0019ZZ|------+
  ZZ0020ZZ
  +--------------------------------------------------------------------------------+

và kết nối VMBus bí mật::

+---- GUEST --------------- VTL0 ------+ +-- DEVICE ---+
  ZZ0000ZZ ZZ0001ZZ
  ZZ0002ZZ ZZ0003ZZ
  ZZ0004ZZ +-- Rơle VMBus ------+ ====+================== |
  ZZ0005ZZ ZZ0006ZZ ZZ0007ZZ ZZ0008ZZ
  ZZ0009ZZ +-------- S ----------+ ZZ0010ZZ +-------------+
  ZZ0011ZZ |ZZ0012ZZ |
  ZZ0013ZZZZ0014ZZ |
  ZZ0015ZZ Linux ZZ0016ZZZZ0017ZZ |
  Hạt nhân ZZ0018ZZ ZZ0019ZZZZ0020ZZ |
  ZZ0021ZZZZ0022ZZ
  ZZ0023ZZZZ0024ZZZZ0025ZZ
  +-------++------- C -------------------+ +-------------+
          |ZZ0026ZZ HOST |
          ||                                             +----S------+
  +-------|ZZ0027ZZ|------+
  ZZ0028ZZ
  +--------------------------------------------------------------------------------+

Việc triển khai chuyển tiếp VMBus cung cấp VMBus bí mật
các kênh có sẵn trong dự án OpenVMM như một phần của OpenHCL
paravisor. Vui lòng tham khảo

* ZZ0000ZZ và
  * ZZ0001ZZ

để biết thêm thông tin về paravisor OpenHCL.

Một khách đang chạy với paravisor phải xác định trong thời gian chạy nếu
VMBus bí mật được hỗ trợ bởi paravisor hiện tại. Dành riêng cho x86_64
cách tiếp cận dựa trên lá Ngăn xếp ảo hóa CPUID; triển khai ARM64
dự kiến sẽ hỗ trợ VMBus bí mật vô điều kiện khi chạy
ARM CCA khách nhé.

VMBus bí mật là một đặc điểm của toàn bộ kết nối VMBus,
và của từng kênh VMBus được tạo. Khi một VMBus bí mật
kết nối được thiết lập, paravisor cung cấp cho khách thông điệp chuyển tiếp
đường dẫn được sử dụng để tạo và xóa thiết bị VMBus và nó cung cấp một
Bộ điều khiển ngắt tổng hợp per-CPU (SynIC) giống như SynIC
được cung cấp bởi máy chủ Hyper-V. Mỗi thiết bị VMBus được cung cấp cho khách
cho biết mức độ tham gia vào VMBus bí mật. Ưu đãi
cho biết liệu thiết bị có sử dụng bộ đệm vòng được mã hóa hay không và liệu thiết bị có sử dụng
bộ nhớ được mã hóa cho DMA được thực hiện bên ngoài bộ đệm vòng. Những cài đặt này
có thể khác nhau đối với các thiết bị khác nhau sử dụng cùng một VMBus bí mật
kết nối.

Mặc dù các cài đặt này riêng biệt nhưng trên thực tế, nó sẽ luôn được mã hóa
chỉ bộ đệm vòng hoặc cả bộ đệm vòng được mã hóa và dữ liệu bên ngoài. Nếu một kênh
được cung cấp bởi paravisor với VMBus bí mật, bộ đệm vòng luôn có thể
được mã hóa vì nó hoàn toàn dành cho giao tiếp giữa bộ điều khiển VTL2
và khách VTL0. Tuy nhiên, các vùng bộ nhớ khác thường được sử dụng cho ví dụ: DMA,
vì vậy chúng cần có thể truy cập được bằng phần cứng cơ bản và phải
không được mã hóa (trừ khi thiết bị hỗ trợ bộ nhớ được mã hóa). Hiện nay, có
không phải bất kỳ VSP nào trong OpenHCL hỗ trợ bộ nhớ ngoài được mã hóa, nhưng trong tương lai
các phiên bản dự kiến sẽ kích hoạt khả năng này.

Bởi vì một số thiết bị trên VMBus bí mật có thể yêu cầu bộ đệm vòng được giải mã
và chuyển khoản DMA, khách phải tương tác với hai SynIC -- một SynIC được cung cấp
bởi paravisor và cái được cung cấp bởi máy chủ Hyper-V khi Confidential
VMBus không được cung cấp. Các ngắt luôn được báo hiệu bởi SynIC paravisor,
nhưng khách phải kiểm tra tin nhắn và ngắt kênh trên cả hai SynIC.

Trong trường hợp VMBus bí mật, quyền truy cập SynIC thường xuyên của khách là
bị chặn bởi paravisor (điều này bao gồm nhiều MSR khác nhau như SIMP và
SIEFP, cũng như các siêu lệnh gọi như HvPostMessage và HvSignalEvent). Nếu
khách thực sự muốn giao tiếp với hypervisor, nó phải sử dụng đặc biệt
cơ chế (trang GHCB trên SNP hoặc tdcall trên TDX). Tin nhắn có thể là một trong hai
loại: với VMBus bí mật, tin nhắn sử dụng SynIC paravisor và nếu
khách đã chọn giao tiếp trực tiếp với hypervisor, họ sử dụng hypervisor
SynIC. Để báo hiệu ngắt, một số kênh có thể đang chạy trên máy chủ
(không bảo mật, sử dụng rơle VMBus) và sử dụng SynIC hypervisor, và
một số trên paravisor và sử dụng SynIC của nó. RelID được điều phối bởi
Máy chủ OpenHCL VMBus và được đảm bảo là duy nhất bất kể
kênh bắt nguồn từ máy chủ hoặc paravisor.

Load_unaligned_zeropad()
------------------------
Khi chuyển đổi bộ nhớ giữa được mã hóa và giải mã, người gọi
set_memory_encrypted() hoặc set_memory_decrypted() chịu trách nhiệm đảm bảo
bộ nhớ không được sử dụng và không được tham chiếu trong khi quá trình chuyển đổi đang diễn ra
tiến bộ. Quá trình chuyển đổi có nhiều bước và bao gồm sự tương tác với
máy chủ Hyper-V. Bộ nhớ ở trạng thái không nhất quán cho đến khi tất cả các bước được thực hiện
hoàn thành. Một tham chiếu trong khi trạng thái không nhất quán có thể dẫn đến một
ngoại lệ không thể sửa chữa được.

Tuy nhiên, cơ chế kernel Load_unaligned_zeropad() có thể làm lạc hướng
các tham chiếu mà người gọi set_memory_encrypted() hoặc
set_memory_decrypted(), do đó có mã cụ thể trong ngoại lệ #VC hoặc #VE
xử lý để khắc phục trường hợp này. Nhưng máy ảo CoCo chạy trên Hyper-V có thể
được định cấu hình để chạy với paravisor, với ngoại lệ #VC hoặc #VE được định tuyến tới
người paravisor. Không có cách kiến trúc nào để chuyển tiếp các ngoại lệ trở lại
kernel khách và trong trường hợp đó, mã sửa lỗi Load_unaligned_zeropad()
trong trình xử lý #VC/#VE không chạy.

Để tránh vấn đề này, các chức năng cụ thể của Hyper-V để thông báo cho
trình ảo hóa của các trang được đánh dấu chuyển tiếp là "không có" trong khi chuyển đổi
đang được tiến hành. Nếu Load_unaligned_zeropad() gây ra tham chiếu lạc,
lỗi trang bình thường được tạo thay vì #VC hoặc #VE và lỗi trang-
trình xử lý dựa trên Load_unaligned_zeropad() sửa lỗi tham chiếu. Khi
Quá trình chuyển đổi mã hóa/giải mã hoàn tất, các trang được đánh dấu là "hiện tại"
một lần nữa. Xem hv_vtom_clear_ Present() và hv_vtom_set_host_visibility().