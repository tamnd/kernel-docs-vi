.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/virt/hyperv/overview.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Tổng quan
========
Nhân Linux chứa nhiều loại mã để chạy dưới dạng đầy đủ
vị khách được khai sáng trên bộ ảo hóa Hyper-V của Microsoft.  Hyper-V
bao gồm chủ yếu là một bộ ảo hóa kim loại trần cộng với một máy ảo
dịch vụ quản lý đang chạy trong phân vùng chính (khoảng
tương đương với KVM và QEMU chẳng hạn).  Máy ảo khách chạy ở chế độ con
phân vùng.  Trong tài liệu này, các tham chiếu đến Hyper-V thường
bao gồm cả bộ ảo hóa và dịch vụ VMM mà không cần thực hiện
sự khác biệt về chức năng nào được cung cấp bởi chức năng nào
thành phần.

Hyper-V chạy trên kiến trúc x86/x64 và arm64 và máy khách Linux
đều được hỗ trợ trên cả hai.  Chức năng và hành vi của Hyper-V là
nói chung là giống nhau trên cả hai kiến trúc trừ khi có ghi chú khác.

Giao tiếp khách Linux với Hyper-V
--------------------------------------
Khách Linux giao tiếp với Hyper-V theo bốn cách khác nhau:

* Bẫy ngầm: Như được xác định bởi kiến trúc x86/x64 hoặc arm64,
  một số hành động của khách bẫy Hyper-V.  Hyper-V mô phỏng hành động và
  trả lại quyền điều khiển cho khách.  Hành vi này nói chung là vô hình
  vào nhân Linux.

* Siêu lệnh gọi rõ ràng: Linux thực hiện lệnh gọi hàm rõ ràng tới
  Hyper-V, truyền tham số.  Hyper-V thực hiện hành động được yêu cầu
  và trả lại quyền điều khiển cho người gọi.  Các tham số được truyền vào
  các thanh ghi bộ xử lý hoặc trong bộ nhớ được chia sẻ giữa máy khách Linux và
  Hyper-V.   Trên x86/x64, siêu cuộc gọi sử dụng cách gọi cụ thể của Hyper-V
  trình tự.  Trên arm64, hypercall sử dụng cách gọi SMCCC tiêu chuẩn ARM
  trình tự.

* Truy cập thanh ghi tổng hợp: Hyper-V triển khai nhiều loại
  thanh ghi tổng hợp.  Trên x86/x64, các thanh ghi này xuất hiện dưới dạng MSR trong
  khách và nhân Linux có thể đọc hoặc ghi các MSR này bằng cách sử dụng
  các cơ chế thông thường được xác định bởi kiến trúc x86/x64.  Bật
  arm64, các thanh ghi tổng hợp này phải được truy cập bằng cách sử dụng rõ ràng
  siêu cuộc gọi.

* VMBus: VMBus là cấu trúc phần mềm cấp cao hơn được xây dựng trên
  3 cơ chế còn lại.  Nó là một giao diện truyền thông điệp giữa
  máy chủ Hyper-V và máy khách Linux.  Nó sử dụng bộ nhớ được chia sẻ
  giữa Hyper-V và khách, cùng với nhiều tín hiệu khác nhau
  cơ chế.

Ba cơ chế giao tiếp đầu tiên được ghi lại trong
ZZ0000ZZ.  TLFS mô tả
chức năng chung của Hyper-V và cung cấp thông tin chi tiết về các siêu lệnh
và các thanh ghi tổng hợp.  TLFS hiện được viết cho
chỉ có kiến trúc x86/x64.

.. _Hyper-V Top Level Functional Spec (TLFS): https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/tlfs/tlfs

VMBus không được ghi lại.  Tài liệu này cung cấp một mức độ cao
tổng quan về VMBus và cách thức hoạt động, nhưng có thể nhận thấy các chi tiết
chỉ từ mã.

Chia sẻ bộ nhớ
--------------
Nhiều khía cạnh giao tiếp giữa Hyper-V và Linux dựa trên
về việc chia sẻ bộ nhớ.  Việc chia sẻ như vậy thường được thực hiện như
sau:

* Linux phân bổ bộ nhớ từ không gian địa chỉ vật lý của nó bằng cách sử dụng
  cơ chế Linux tiêu chuẩn.

* Linux cho Hyper-V biết địa chỉ vật lý của khách (GPA) của
  bộ nhớ được phân bổ.  Nhiều khu vực chia sẻ được giữ ở mức 1 trang để
  GPA duy nhất là đủ.   Các khu vực chia sẻ lớn hơn yêu cầu một danh sách
  GPA, thường không cần phải liền kề trong khách
  không gian địa chỉ vật lý.  Cách Hyper-V được thông báo về GPA hoặc danh sách
  điểm trung bình GPA khác nhau.  Trong một số trường hợp, một GPA được ghi vào một
  sổ tổng hợp.  Trong các trường hợp khác, GPA hoặc danh sách GPA được gửi
  trong tin nhắn VMBus.

* Hyper-V dịch GPA thành địa chỉ bộ nhớ vật lý "thực",
  và tạo một ánh xạ ảo mà nó có thể sử dụng để truy cập bộ nhớ.

* Linux sau này có thể thu hồi tính năng chia sẻ mà nó đã thiết lập trước đó bởi
  yêu cầu Hyper-V đặt GPA được chia sẻ về 0.

Hyper-V hoạt động với kích thước trang 4 Kbyte. Điểm trung bình được thông báo tới
Hyper-V có thể ở dạng số trang và luôn mô tả một
phạm vi 4 Kbyte.  Vì kích thước trang khách Linux trên x86/x64 là
cũng 4 Kbyte, ánh xạ từ trang khách sang trang Hyper-V là 1-1.
Trên arm64, Hyper-V hỗ trợ khách với các trang 4/16/64 Kbyte như
được xác định bởi kiến trúc arm64.   Nếu Linux đang sử dụng 16 hoặc 64
Các trang Kbyte, mã Linux phải cẩn thận khi giao tiếp với Hyper-V
chỉ xét về các trang 4 Kbyte.  HV_HYP_PAGE_SIZE và các macro liên quan
được sử dụng trong mã giao tiếp với Hyper-V để nó hoạt động
chính xác trong mọi cấu hình.

Như được mô tả trong TLFS, một số trang bộ nhớ được chia sẻ giữa Hyper-V
và khách Linux là các trang "lớp phủ".  Với các trang lớp phủ, Linux
sử dụng cách tiếp cận thông thường là phân bổ bộ nhớ của khách và thông báo
Hyper-V GPA của bộ nhớ được phân bổ.  Nhưng Hyper-V sau đó thay thế
trang bộ nhớ vật lý đó với một trang được phân bổ và
trang bộ nhớ vật lý ban đầu không còn có thể truy cập được trong máy khách
VM.  Linux có thể truy cập bộ nhớ bình thường như thể nó là bộ nhớ
mà nó được phân bổ ban đầu.  Hành vi "lớp phủ" có thể nhìn thấy được
chỉ vì nội dung của trang (được Linux nhìn thấy) thay đổi tại
thời điểm Linux ban đầu thiết lập việc chia sẻ và
trang lớp phủ được chèn vào.  Tương tự, nội dung thay đổi nếu Linux
thu hồi việc chia sẻ, trong trường hợp đó Hyper-V sẽ xóa trang lớp phủ,
và trang khách được Linux phân bổ ban đầu sẽ hiển thị
một lần nữa.

Trước khi Linux thực hiện kexec với kernel kdump hoặc bất kỳ kernel nào khác,
bộ nhớ được chia sẻ với Hyper-V sẽ bị thu hồi.  Hyper-V có thể sửa đổi
một trang được chia sẻ hoặc xóa một trang lớp phủ sau khi hạt nhân mới được hoàn thành
sử dụng trang này cho mục đích khác, làm hỏng kernel mới.
Hyper-V không cung cấp một thao tác "thiết lập mọi thứ" để
máy ảo khách, do đó mã Linux phải thu hồi riêng lẻ tất cả việc chia sẻ trước khi
đang làm kexec.   Xem hv_kexec_handler() và hv_crash_handler().  Nhưng
đường dẫn sự cố/hoảng loạn vẫn còn lỗ hổng trong việc dọn dẹp vì một số đã chia sẻ
các trang được thiết lập bằng cách sử dụng các thanh ghi tổng hợp theo CPU và không có
cơ chế thu hồi các trang chia sẻ cho các CPU không phải CPU
chạy theo con đường hoảng loạn.

Quản lý CPU
--------------
Hyper-V không có khả năng thêm nóng hoặc xóa nóng CPU
từ một máy ảo đang chạy.  Tuy nhiên, Windows Server 2019 Hyper-V và
các phiên bản trước đó có thể cung cấp cho khách các bảng ACPI cho biết
nhiều CPU hơn số lượng thực tế có trong VM.  Như thường lệ, Linux
xử lý các CPU bổ sung này như các CPU bổ sung nóng tiềm năng và báo cáo
chúng như vậy mặc dù Hyper-V sẽ không bao giờ thực sự thêm chúng vào.
Bắt đầu từ Windows Server 2022 Hyper-V, các bảng ACPI phản ánh
chỉ có CPU thực sự có trong VM, vì vậy Linux không báo cáo
bất kỳ CPU bổ sung nóng nào.

Máy khách Linux CPU có thể được đưa ngoại tuyến bằng Linux thông thường
cơ chế, miễn là không có ngắt kênh VMBus nào được gán cho
CPU.  Xem phần về Ngắt VMBus để biết thêm chi tiết
về cách các ngắt kênh VMBus có thể được chỉ định lại để cho phép
đang dùng CPU ngoại tuyến.

32-bit và 64-bit
-----------------
Trên x86/x64, Hyper-V hỗ trợ khách 32 bit và 64 bit và Linux
sẽ xây dựng và chạy trong một trong hai phiên bản. Trong khi phiên bản 32-bit là
dự kiến sẽ hoạt động nhưng nó hiếm khi được sử dụng và có thể bị ảnh hưởng bởi các lỗi không được phát hiện
hồi quy.

Trên arm64, Hyper-V chỉ hỗ trợ khách 64-bit.

tính chất endian
-----------
Tất cả giao tiếp giữa Hyper-V và máy ảo khách đều sử dụng Little-Endian
định dạng trên cả x86/x64 và arm64.  Định dạng Big-endian trên arm64 thì không
được hỗ trợ bởi Hyper-V và mã Linux không sử dụng macro endian-ness
khi truy cập dữ liệu được chia sẻ với Hyper-V.

Phiên bản
----------
Các nhân Linux hiện tại hoạt động chính xác với các phiên bản cũ hơn của
Hyper-V trở lại Windows Server 2012 Hyper-V. Hỗ trợ chạy
trên bản phát hành Hyper-V gốc trong Windows Server 2008/2008 R2
đã được gỡ bỏ.

Một khách Linux trên Hyper-V xuất ra dmesg phiên bản của Hyper-V
nó đang chạy tiếp.  Phiên bản này ở dạng Windows build
số và chỉ dành cho mục đích hiển thị. Mã Linux không
kiểm tra số phiên bản này trong thời gian chạy để xác định các tính năng có sẵn
và chức năng. Hyper-V cho biết tính khả dụng của tính năng/chức năng
thông qua các cờ trong MSR tổng hợp mà Hyper-V cung cấp cho khách,
và mã khách kiểm tra các cờ này.

VMBus có phiên bản giao thức riêng được đàm phán trong quá trình
kết nối VMBus ban đầu từ máy khách tới Hyper-V. Phiên bản này
số cũng được xuất ra dmesg trong khi khởi động.  Số phiên bản này
được kiểm tra ở một vài vị trí trong mã để xác định xem có cụ thể không
chức năng hiện có.

Hơn nữa, mỗi thiết bị tổng hợp trên VMBus còn có một giao thức
phiên bản tách biệt với phiên bản giao thức VMBus. Thiết bị
trình điều khiển cho các thiết bị tổng hợp này thường đàm phán thiết bị
phiên bản giao thức và có thể kiểm tra phiên bản giao thức đó để xác định
nếu có chức năng cụ thể của thiết bị.

Mã đóng gói
--------------
Mã liên quan đến Hyper-V xuất hiện trong cây mã nhân Linux trong ba
lĩnh vực chính:

1. trình điều khiển/hv

2. Arch/x86/hyperv và Arch/arm64/hyperv

3. các khu vực trình điều khiển thiết bị riêng lẻ như trình điều khiển/scsi, trình điều khiển/mạng,
   trình điều khiển/nguồn đồng hồ, v.v.

Một vài tập tin linh tinh xuất hiện ở nơi khác. Xem danh sách đầy đủ bên dưới
"Hyper-V/Azure CORE AND DRIVERS" và "DRM DRIVER FOR HYPERV
SYNTHETIC VIDEO DEVICE" trong tệp MAINTAINERS.

Mã trong #1 và #2 chỉ được tạo khi CONFIG_HYPERV được đặt.
Tương tự, mã cho hầu hết các trình điều khiển liên quan đến Hyper-V chỉ được xây dựng
khi CONFIG_HYPERV được đặt.

Hầu hết mã liên quan đến Hyper-V trong #1 và #3 đều có thể được xây dựng dưới dạng mô-đun.
Mã cụ thể về kiến ​​trúc trong #2 phải được tích hợp sẵn.  Ngoài ra,
driver/hv/hv_common.c là mã cấp thấp phổ biến trên
kiến trúc và phải được tích hợp sẵn.