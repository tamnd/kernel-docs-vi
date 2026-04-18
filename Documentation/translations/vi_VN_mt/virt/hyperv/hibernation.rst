.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/virt/hyperv/hibernation.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Máy ảo khách ngủ đông
=====================

Lý lịch
----------
Linux hỗ trợ khả năng tự ngủ đông để tiết kiệm điện năng.
Chế độ ngủ đông đôi khi được gọi là tạm dừng vào đĩa vì nó ghi vào bộ nhớ
hình ảnh vào đĩa và đặt phần cứng ở mức công suất thấp nhất có thể
trạng thái. Sau khi tiếp tục từ chế độ ngủ đông, phần cứng sẽ được khởi động lại và
hình ảnh bộ nhớ được khôi phục từ đĩa để nó có thể tiếp tục thực thi
nó đã dừng lại ở đâu. Xem phần "Ngủ đông" của
Tài liệu/admin-guide/pm/sleep-states.rst.

Chế độ ngủ đông thường được thực hiện trên các thiết bị có một người dùng, chẳng hạn như
máy tính xách tay cá nhân. Ví dụ: máy tính xách tay chuyển sang chế độ ngủ đông khi
nắp được đóng lại và tiếp tục hoạt động khi nắp được mở lại.
Ngủ đông và tiếp tục xảy ra trên cùng một phần cứng và nhân Linux
mã điều phối các bước ngủ đông giả định rằng phần cứng
cấu hình không bị thay đổi khi ở trạng thái ngủ đông.

Chế độ ngủ đông có thể được bắt đầu trong Linux bằng cách ghi "đĩa" vào
/sys/power/state hoặc bằng cách gọi lệnh gọi hệ thống khởi động lại bằng lệnh
những lý lẽ thích hợp. Chức năng này có thể được bao bọc bởi không gian người dùng
các lệnh như "systemctl hibernate" được chạy trực tiếp từ một
dòng lệnh hoặc để phản hồi các sự kiện như đóng nắp máy tính xách tay.

Những điều cần cân nhắc khi ngủ đông VM khách
---------------------------------------
Khách Linux trên Hyper-V cũng có thể ở chế độ ngủ đông, trong trường hợp đó
phần cứng là phần cứng ảo được Hyper-V cung cấp cho máy ảo khách.
Chỉ có VM khách được nhắm mục tiêu ở chế độ ngủ đông, trong khi các VM khách khác và
máy chủ Hyper-V bên dưới tiếp tục chạy bình thường. Trong khi
Windows Hyper-V cơ bản và phần cứng vật lý chứa nó
đang chạy cũng có thể được ngủ đông bằng chức năng ngủ đông trong
máy chủ Windows, chế độ ngủ đông của máy chủ và tác động của nó đối với máy ảo khách là không
trong phạm vi tài liệu này.

Việc khôi phục máy ảo khách ngủ đông có thể khó khăn hơn so với
phần cứng vật lý vì VM giúp việc thay đổi phần cứng rất dễ dàng
cấu hình giữa chế độ ngủ đông và tiếp tục. Ngay cả khi sơ yếu lý lịch
được thực hiện trên cùng một máy ảo đã ngủ đông, kích thước bộ nhớ có thể là
đã thay đổi hoặc các NIC ảo hoặc bộ điều khiển SCSI có thể được thêm vào hoặc
bị loại bỏ. Các thiết bị PCI ảo được gán cho VM có thể được thêm hoặc
bị loại bỏ. Tuy nhiên, hầu hết những thay đổi như vậy đều khiến các bước tiếp tục không thành công.
việc thêm bộ điều khiển NIC, SCSI hoặc thiết bị vPCI ảo mới sẽ hoạt động.

Sự phức tạp bổ sung có thể xảy ra do các đĩa của máy ảo ngủ đông
có thể được chuyển sang một máy ảo mới được tạo khác có cùng chức năng
cấu hình phần cứng ảo. Mặc dù mong muốn có được sơ yếu lý lịch từ
ngủ đông để thành công sau một động thái như vậy, có những thách thức. Xem
chi tiết về tình huống này và những hạn chế của nó trong phần "Tiếp tục
Phần VM khác" bên dưới.

Hyper-V cũng cung cấp các cách để di chuyển VM từ một máy chủ Hyper-V sang
cái khác. Hyper-V cố gắng đảm bảo model bộ xử lý và phiên bản Hyper-V
khả năng tương thích bằng cách sử dụng Phiên bản cấu hình VM và ngăn chặn việc di chuyển sang
một máy chủ không tương thích. Linux thích ứng với máy chủ và bộ xử lý
sự khác biệt bằng cách phát hiện chúng khi khởi động, nhưng việc phát hiện như vậy không
được thực hiện khi tiếp tục thực hiện trong hình ảnh ngủ đông. Nếu một VM là
ngủ đông trên một máy chủ, sau đó tiếp tục lại trên máy chủ có bộ xử lý khác
model hoặc phiên bản Hyper-V, cài đặt được ghi trong ảnh ngủ đông
có thể không phù hợp với máy chủ mới. Bởi vì Linux không phát hiện ra điều đó
không khớp khi tiếp tục hình ảnh ngủ đông, hành vi không xác định
và thất bại có thể xảy ra.


Kích hoạt chế độ ngủ đông VM khách
-----------------------------
Chế độ ngủ đông của máy ảo khách Hyper-V bị tắt theo mặc định vì
chế độ ngủ đông không tương thích với tính năng bổ sung nóng bộ nhớ, như được cung cấp bởi
Trình điều khiển bóng bay Hyper-V. Nếu hot-add được sử dụng và VM ngủ đông, nó
ngủ đông với nhiều bộ nhớ hơn so với ban đầu. Nhưng khi máy ảo
tiếp tục sau chế độ ngủ đông, Hyper-V chỉ cung cấp cho VM bản gốc
bộ nhớ được chỉ định và kích thước bộ nhớ không khớp khiến cho việc tiếp tục không thành công.

Để kích hoạt máy ảo Hyper-V ở chế độ ngủ đông, quản trị viên Hyper-V phải
kích hoạt trạng thái ngủ S4 ảo ACPI trong cấu hình ACPI
Hyper-V cung cấp cho VM khách. Sự hỗ trợ như vậy được thực hiện bằng
sửa đổi thuộc tính WMI của VM, các bước nằm ngoài
phạm vi của tài liệu này nhưng có sẵn trên web.
Việc kích hoạt được coi là dấu hiệu cho thấy quản trị viên
ưu tiên chế độ ngủ đông của Linux trong VM hơn là hot-add, vì vậy Hyper-V
trình điều khiển bong bóng trong Linux vô hiệu hóa tính năng thêm nóng. Kích hoạt được chỉ định nếu
nội dung của /sys/power/disk chứa "nền tảng" làm tùy chọn. các
sự hỗ trợ cũng được hiển thị trong /sys/bus/vmbus/hibernation. Xem chức năng
hv_is_hibernation_supported().

Linux hỗ trợ trạng thái ngủ ACPI trên x86, nhưng không hỗ trợ trên arm64. Vì vậy Linux
Chế độ ngủ đông VM khách không khả dụng trên Hyper-V cho arm64.

Bắt đầu chế độ ngủ đông VM khách
-------------------------------
Máy ảo khách có thể tự bắt đầu chế độ ngủ đông bằng Linux tiêu chuẩn
phương pháp ghi "đĩa" vào /sys/power/state hoặc hệ thống khởi động lại
gọi. Là một lớp bổ sung, các máy khách Linux trên Hyper-V hỗ trợ
Dịch vụ tích hợp "Tắt máy", qua đó quản trị viên Hyper-V có thể
yêu cầu máy ảo Linux ngủ đông bằng lệnh bên ngoài máy ảo. các
lệnh tạo yêu cầu tới trình điều khiển tắt máy Hyper-V trong Linux,
sẽ gửi sự kiện "EVENT=hibernate". Xem các hàm kernel
tắt máy_onchannelcallback() và send_hibernate_uevent(). Quy tắc udev
phải được cung cấp trong VM xử lý sự kiện này và bắt đầu
ngủ đông.

Xử lý thiết bị VMBus trong chế độ ngủ đông và tiếp tục
--------------------------------------------------
Trình điều khiển xe buýt VMBus và trình điều khiển thiết bị VMBus riêng lẻ,
thực hiện các chức năng tạm dừng và tiếp tục được gọi là một phần của
Sự phối hợp của chế độ ngủ đông và khôi phục chế độ ngủ đông của Linux.
Cách tiếp cận tổng thể là để lại các cấu trúc dữ liệu cho
các kênh VMBus chính và các thiết bị Linux liên quan của chúng, chẳng hạn như
Bộ điều khiển SCSI và các bộ điều khiển khác để chúng được ghi lại trong
hình ảnh ngủ đông. Cách tiếp cận này cho phép bất kỳ trạng thái nào liên quan đến
thiết bị sẽ được duy trì trong suốt thời gian ngủ đông/tiếp tục. Khi máy ảo
tiếp tục hoạt động, các thiết bị được Hyper-V cung cấp lại và được kết nối với
các cấu trúc dữ liệu đã tồn tại trong chế độ ngủ đông được tiếp tục
hình ảnh.

Các thiết bị VMBus được xác định theo lớp và phiên bản GUID. (Xem phần
"Tạo/xóa thiết bị VMBus" trong
Documentation/virt/hyperv/vmbus.rst.) Sau khi tiếp tục từ chế độ ngủ đông,
các chức năng tiếp tục mong đợi rằng các thiết bị do Hyper-V cung cấp có
GUID lớp/phiên bản giống như các thiết bị có tại thời điểm
ngủ đông. Có cùng GUID lớp/phiên bản cho phép cung cấp
các thiết bị được khớp với cấu trúc dữ liệu kênh VMBus chính trong
ký ức về hình ảnh ngủ đông hiện đã được tiếp tục. Nếu có bất kỳ thiết bị nào
được cung cấp không khớp với cấu trúc dữ liệu kênh VMBus chính
đã tồn tại thì chúng được xử lý bình thường như các thiết bị mới được thêm vào. Nếu
các kênh VMBus chính tồn tại trong hình ảnh ngủ đông được tiếp tục là
không khớp với thiết bị được cung cấp trong VM được tiếp tục, sơ yếu lý lịch
trình tự chờ trong 10 giây rồi tiếp tục. Nhưng thiết bị chưa từng có
có khả năng gây ra lỗi trong VM được nối lại.

Khi tiếp tục các kênh VMBus chính hiện có, kênh mới được cung cấp
relids có thể khác nhau vì relids có thể thay đổi trên mỗi lần khởi động VM,
ngay cả khi cấu hình VM không thay đổi. Tài xế xe buýt VMBus
Chức năng tiếp tục khớp với GUID lớp/thể hiện và cập nhật
relids trong trường hợp họ đã thay đổi.

Các kênh phụ VMBus không được duy trì trong hình ảnh ngủ đông. Mỗi
Chức năng tạm dừng của trình điều khiển thiết bị VMBus phải đóng mọi kênh phụ
trước khi ngủ đông. Việc đóng một kênh phụ sẽ khiến Hyper-V gửi một
Thông báo RESCIND_CHANNELOFFER mà Linux xử lý bằng cách giải phóng
cấu trúc dữ liệu kênh sao cho tất cả dấu vết của kênh con đều được
bị loại bỏ. Ngược lại, các kênh chính được đánh dấu là đóng và chúng
bộ đệm vòng được giải phóng, nhưng Hyper-V không gửi thông báo hủy bỏ,
vì vậy cấu trúc dữ liệu kênh tiếp tục tồn tại. Khi tiếp tục,
chức năng tiếp tục của trình điều khiển thiết bị phân bổ lại bộ đệm vòng và
mở lại kênh hiện có. Sau đó nó giao tiếp với Hyper-V để
mở lại các kênh phụ từ đầu.

Các đầu Linux của ổ cắm Hyper-V buộc phải đóng vào thời điểm
ngủ đông. Khách không thể buộc đóng đầu máy chủ của ổ cắm,
nhưng mọi hành động phía máy chủ ở đầu máy chủ sẽ gây ra lỗi.

Các thiết bị VMBus sử dụng chức năng tạm dừng tương tự cho việc "đóng băng" và
các giai đoạn "tắt nguồn" và chức năng tiếp tục tương tự cho giai đoạn "tan băng" và
giai đoạn "khôi phục". Xem phần "Bước vào chế độ ngủ đông" của
Documentation/driver-api/pm/devices.rst để biết trình tự của
các giai đoạn.

Trình tự ngủ đông chi tiết
-----------------------------
1. Hệ thống con quản lý nguồn (PM) Linux chuẩn bị cho
   ngủ đông bằng cách đóng băng các tiến trình không gian của người dùng và phân bổ
   bộ nhớ để giữ hình ảnh ngủ đông.
2. Là một phần của giai đoạn "đóng băng", Linux PM gọi là "tạm dừng"
   chức năng lần lượt cho từng thiết bị VMBus. Như đã mô tả ở trên, điều này
   chức năng loại bỏ các kênh phụ và để lại kênh chính trong
   một trạng thái đóng.
3. Linux PM gọi chức năng "tạm dừng" cho bus VMBus, chức năng này
   đóng mọi kênh ổ cắm Hyper-V và hủy tải cấp cao nhất
   Kết nối VMBus với máy chủ Hyper-V.
4. Linux PM vô hiệu hóa các CPU không khởi động được, tạo image ngủ đông trong
   bộ nhớ được phân bổ trước đó, sau đó kích hoạt lại các CPU không khởi động được.
   Hình ảnh ngủ đông chứa cấu trúc dữ liệu bộ nhớ cho
   đóng các kênh chính, nhưng không có kênh phụ.
5. Là một phần của giai đoạn "tan băng", Linux PM gọi chức năng "tiếp tục"
   cho xe buýt VMBus, thiết lập lại VMBus cấp cao nhất
   kết nối và yêu cầu Hyper-V cung cấp lại các thiết bị VMBus.
   Khi các ưu đãi được nhận cho các kênh chính, các lượt truy cập sẽ
   được cập nhật như mô tả trước đây.
6. Linux PM gọi chức năng "tiếp tục" cho từng thiết bị VMBus. Mỗi
   thiết bị mở lại kênh chính và liên lạc với Hyper-V
   để thiết lập lại các kênh phụ nếu thích hợp. Các kênh phụ
   được tạo lại dưới dạng kênh mới vì chúng đã bị xóa trước đó
   hoàn toàn ở Bước 2.
7. Với các thiết bị VMBus hiện đang hoạt động trở lại, Linux PM ghi
   hình ảnh ngủ đông từ bộ nhớ vào đĩa.
8. Linux PM lặp lại Bước 2 và 3 ở trên như một phần của quá trình "tắt nguồn"
   giai đoạn. Các kênh VMBus đã đóng và VMBus cấp cao nhất
   kết nối được dỡ bỏ.
9. Linux PM vô hiệu hóa các CPU không khởi động được, sau đó chuyển sang trạng thái ngủ ACPI
   S4. Giờ ngủ đông đã hoàn tất.

Trình tự sơ yếu lý lịch chi tiết
------------------------
1. VM khách khởi động vào phiên bản hệ điều hành Linux mới. Trong quá trình khởi động,
   kết nối VMBus cấp cao nhất được thiết lập và tổng hợp
   các thiết bị được kích hoạt. Điều này xảy ra thông qua các đường dẫn bình thường không
   liên quan đến ngủ đông.
2. Mã ngủ đông Linux PM đọc không gian trao đổi là tìm và đọc
   hình ảnh ngủ đông vào bộ nhớ. Nếu không có ngủ đông
   image thì boot này sẽ trở thành boot bình thường.
3. Nếu đây là sơ yếu lý lịch sau chế độ ngủ đông, giai đoạn "đóng băng" sẽ được sử dụng
   để tắt các thiết bị VMBus và dỡ bỏ VMBus cấp cao nhất
   kết nối trong phiên bản hệ điều hành mới đang chạy, giống như Bước 2
   và 3 trong trình tự ngủ đông.
4. Linux PM vô hiệu hóa các CPU không khởi động được và chuyển quyền điều khiển sang
   hình ảnh ngủ đông đọc vào. Trong hình ảnh ngủ đông hiện đang chạy,
   CPU không khởi động được khởi động lại.
5. Là một phần của giai đoạn "tiếp tục", Linux PM lặp lại Bước 5 và 6
   từ trình tự ngủ đông. Kết nối VMBus cấp cao nhất là
   được thiết lập lại và các đề nghị được nhận và khớp với chính
   các kênh trong ảnh. Relids được cập nhật. Sơ yếu lý lịch thiết bị VMBus
   chức năng mở lại các kênh chính và tạo lại các kênh phụ.
6. Linux PM thoát khỏi trình tự tiếp tục ngủ đông và VM bây giờ
   chạy bình thường từ hình ảnh ngủ đông.

Cặp khóa-giá trị (KVP) Sự bất thường của thiết bị giả
--------------------------------------------
Thiết bị VMBus KVP hoạt động khác với các thiết bị giả khác
được cung cấp bởi Hyper-V.  Khi kênh chính KVP bị đóng, Hyper-V
gửi một tin nhắn hủy bỏ, khiến tất cả dấu tích của thiết bị bị xóa
bị loại bỏ. Nhưng sau đó Hyper-V lại cung cấp lại thiết bị, khiến nó trở thành mới
được tạo lại. Việc loại bỏ và tạo lại xảy ra trong quá trình "đóng băng"
giai đoạn ngủ đông, vì vậy hình ảnh ngủ đông chứa các thông tin được tạo lại
Thiết bị KVP. Hành vi tương tự xảy ra trong giai đoạn "đóng băng" của
tiếp tục trình tự trong khi vẫn ở phiên bản hệ điều hành mới. Nhưng ở cả hai
trường hợp, kết nối VMBus cấp cao nhất sau đó sẽ bị hủy tải, điều này
khiến thiết bị bị loại bỏ ở phía Hyper-V. Vì thế không có hại gì
đã xong và mọi thứ vẫn hoạt động.

Thiết bị PCI ảo
-------------------
Thiết bị PCI ảo là thiết bị PCI vật lý được ánh xạ trực tiếp
vào không gian địa chỉ vật lý của VM để VM có thể tương tác trực tiếp
với phần cứng. Các thiết bị vPCI bao gồm những thiết bị được truy cập thông qua Hyper-V
gọi "Gán thiết bị rời" (DDA), cũng như SR-IOV NIC
Các thiết bị chức năng ảo (VF). Xem Tài liệu/virt/hyperv/vpci.rst.

Các thiết bị Hyper-V DDA được cung cấp cho các máy ảo khách sau VMBus cấp cao nhất
kết nối được thiết lập, giống như các thiết bị tổng hợp VMBus. Họ là
được gán tĩnh cho VM và GUID phiên bản của chúng không thay đổi
trừ khi quản trị viên Hyper-V thực hiện thay đổi cấu hình.
Các thiết bị DDA được thể hiện trong Linux dưới dạng các thiết bị PCI ảo có
danh tính VMBus cũng như danh tính PCI. Do đó, khách Linux
chế độ ngủ đông trước tiên xử lý các thiết bị DDA dưới dạng thiết bị VMBus để
quản lý kênh VMBus. Nhưng sau đó chúng cũng được xử lý dưới dạng PCI
các thiết bị sử dụng chức năng ngủ đông được thực hiện bởi nguồn gốc của chúng
Trình điều khiển PCI.

Các VF SR-IOV NIC cũng có mã nhận dạng VMBus cũng như PCI
danh tính và tổng thể được xử lý tương tự như các thiết bị DDA. A
điểm khác biệt là VF không được cung cấp cho VM trong lần khởi động đầu tiên
của VM. Thay vào đó, trình điều khiển NIC tổng hợp VMBus khởi động lần đầu tiên
vận hành và thông báo với Hyper-V rằng nó sẵn sàng chấp nhận một yêu cầu
VF, và sau đó đề nghị VF được thực hiện. Tuy nhiên, kết nối VMBus
sau đó có thể được dỡ bỏ và sau đó được thiết lập lại mà không cần VM
được khởi động lại, như xảy ra ở Bước 3 và 5 trong Chế độ ngủ đông chi tiết
Trình tự ở trên và trong Trình tự Sơ yếu lý lịch Chi tiết. Trong trường hợp như vậy,
các VF có thể đã trở thành một phần của VM trong lần khởi động đầu tiên, vì vậy khi
Kết nối VMBus được thiết lập lại, VF được cung cấp trên
kết nối được thiết lập lại mà không cần sự can thiệp của trình điều khiển NIC tổng hợp.

Thiết bị UIO
-----------
Một thiết bị VMBus có thể được tiếp xúc với không gian người dùng bằng Hyper-V UIO
trình điều khiển (uio_hv_generic.c) để trình điều khiển không gian người dùng có thể kiểm soát và
vận hành thiết bị. Tuy nhiên, trình điều khiển VMBus UIO không hỗ trợ
tạm dừng và tiếp tục các hoạt động cần thiết cho chế độ ngủ đông. Nếu một VMBus
thiết bị được cấu hình để sử dụng trình điều khiển UIO, việc ngủ đông VM không thành công
và Linux tiếp tục chạy bình thường. Việc sử dụng phổ biến nhất của Hyper-V
Trình điều khiển UIO dành cho mạng DPDK, nhưng cũng có những cách sử dụng khác.

Tiếp tục trên một máy ảo khác
--------------------------
Kịch bản này xảy ra trong đám mây công cộng Azure ở trạng thái ngủ đông
VM của khách hàng chỉ tồn tại dưới dạng cấu hình và ổ đĩa đã lưu -- VM không
còn tồn tại trên bất kỳ máy chủ Hyper-V nào. Khi VM của khách hàng được tiếp tục, một
Máy ảo Hyper-V mới có cấu hình giống hệt nhau được tạo, có thể trên một
máy chủ Hyper-V khác nhau. Máy ảo Hyper-V mới đó sẽ được tiếp tục
VM của khách hàng và các bước mà nhân Linux thực hiện để tiếp tục từ
hình ảnh ngủ đông phải hoạt động trong VM mới đó.

Trong khi các ổ đĩa và nội dung của chúng được bảo toàn từ máy ảo gốc,
GUID phiên bản VMBus do Hyper-V cung cấp của bộ điều khiển đĩa và
các thiết bị tổng hợp khác thường sẽ khác. Sự khác biệt
sẽ khiến quá trình tiếp tục từ trạng thái ngủ đông không thành công, vì vậy có một số điều
thực hiện để giải quyết vấn đề này:

* Đối với các thiết bị tổng hợp VMBus chỉ hỗ trợ một phiên bản duy nhất,
  Hyper-V luôn gán cùng một GUID phiên bản. Ví dụ,
  Chuột Hyper-V, thiết bị giả tắt máy, giả đồng bộ hóa thời gian
  thiết bị, v.v., luôn có cùng phiên bản GUID, cho cả thiết bị cục bộ
  Cài đặt Hyper-V cũng như trên đám mây Azure.

* Bộ điều khiển SCSI tổng hợp VMBus có thể có nhiều phiên bản trong một
  VM và trong trường hợp chung GUID khác nhau tùy theo VM.
  Tuy nhiên, máy ảo Azure luôn có chính xác hai SCSI tổng hợp
  bộ điều khiển và mã Azure ghi đè hành vi Hyper-V thông thường
  vì vậy các bộ điều khiển này luôn được gán cùng hai phiên bản
  GUID. Do đó, khi một máy ảo khách hàng được tiếp tục trên một máy ảo mới
  đã tạo VM, các GUID phiên bản khớp với nhau. Nhưng sự đảm bảo này không
  giữ để cài đặt Hyper-V cục bộ.

* Tương tự, các NIC tổng hợp VMBus có thể có nhiều phiên bản trong một
  VM và các GUID phiên bản khác nhau tùy theo VM. Một lần nữa, mã Azure
  ghi đè hành vi Hyper-V thông thường để phiên bản GUID
  của NIC tổng hợp trong VM khách hàng không thay đổi, ngay cả khi
  VM của khách hàng được hủy phân bổ hoặc ngủ đông, sau đó được cấu thành lại
  trên máy ảo mới được tạo. Giống như bộ điều khiển SCSI, hành vi này
  không giữ được cho các cài đặt Hyper-V cục bộ.

* Các thiết bị vPCI không có GUID phiên bản giống nhau khi tiếp tục
  khỏi chế độ ngủ đông trên máy ảo mới được tạo. Do đó, Azure thực hiện
  không hỗ trợ chế độ ngủ đông cho các máy ảo có thiết bị DDA như
  Bộ điều khiển NVMe hoặc GPU. Đối với các VF SR-IOV NIC, Azure sẽ loại bỏ
  VF từ VM trước khi nó ngủ đông để hình ảnh ngủ đông
  không chứa thiết bị VF. Khi VM được nối lại
  khởi tạo một VF mới, thay vì cố gắng khớp với một VF
  hiện diện trong hình ảnh ngủ đông. Bởi vì Azure phải
  xóa mọi VF trước khi bắt đầu chế độ ngủ đông, Azure VM
  chế độ ngủ đông phải được bắt đầu từ bên ngoài từ Cổng thông tin Azure hoặc
  Azure CLI, lần lượt sử dụng dịch vụ tích hợp Tắt máy để
  yêu cầu Linux thực hiện chế độ ngủ đông. Nếu chế độ ngủ đông tự bắt đầu
  trong Azure VM, VF vẫn ở trạng thái ngủ đông và được
  không được tiếp tục lại đúng cách.

Tóm lại, Azure thực hiện các hành động đặc biệt để loại bỏ VF và để đảm bảo
GUID phiên bản thiết bị VMBus khớp với VM mới/khác, cho phép
chế độ ngủ đông để hoạt động với hầu hết các kích thước máy ảo Azure có mục đích chung. Trong khi
các hành động đặc biệt tương tự có thể được thực hiện khi tiếp tục trên một máy ảo khác
trên bản cài đặt Hyper-V cục bộ, việc sắp xếp các hành động như vậy không được cung cấp
vượt trội so với Hyper-V cục bộ và do đó yêu cầu tập lệnh tùy chỉnh.