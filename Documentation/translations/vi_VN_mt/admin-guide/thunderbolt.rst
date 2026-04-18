.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/thunderbolt.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================
 USB4 và Thunderbolt
========================
USB4 là thông số kỹ thuật công khai dựa trên giao thức Thunderbolt 3 với
một số khác biệt ở cấp độ đăng ký trong số những thứ khác. Kết nối
người quản lý là một thực thể chạy trên bộ định tuyến máy chủ (bộ điều khiển máy chủ)
chịu trách nhiệm liệt kê các bộ định tuyến và thiết lập đường hầm. A
trình quản lý kết nối có thể được triển khai trong phần sụn hoặc phần mềm.
Thông thường, PC đi kèm với trình quản lý kết nối chương trình cơ sở cho Thunderbolt 3
và các hệ thống có khả năng USB4 đời đầu. Mặt khác, các hệ thống của Apple sử dụng
trình quản lý kết nối phần mềm và các thiết bị tương thích USB4 sau này tuân theo
bộ đồ.

Trình điều khiển Thunderbolt của Linux hỗ trợ cả hai và có thể phát hiện trong thời gian chạy
việc triển khai trình quản lý kết nối sẽ được sử dụng. Để được an toàn
Trình quản lý kết nối phần mềm trong Linux cũng quảng cáo mức độ bảo mật
ZZ0000ZZ có nghĩa là đường hầm PCIe bị tắt theo mặc định. các
tài liệu bên dưới áp dụng cho cả hai cách triển khai ngoại trừ
trình quản lý kết nối phần mềm chỉ hỗ trợ mức bảo mật ZZ0001ZZ và
dự kiến ​​sẽ đi kèm với lớp bảo vệ DMA dựa trên IOMMU.

Mức độ bảo mật và cách sử dụng chúng
------------------------------------
Giao diện được trình bày ở đây không dành cho người dùng cuối. Thay vào đó
phải là một công cụ không gian người dùng xử lý tất cả các chi tiết cấp thấp, giữ
cơ sở dữ liệu về các thiết bị được ủy quyền và nhắc nhở người dùng về các kết nối mới.

Bạn có thể biết thêm chi tiết về giao diện sysfs cho các thiết bị Thunderbolt.
được tìm thấy trong Tài liệu/ABI/testing/sysfs-bus-thunderbolt.

Những người dùng chỉ muốn kết nối bất kỳ thiết bị nào mà không cần bất kỳ loại
công việc thủ công có thể thêm dòng sau vào
ZZ0000ZZ::

ACTION=="thêm", SUBSYSTEM=="thunderbolt", ATTR{authorized}=="0", ATTR{authorized}="1"

Điều này sẽ tự động cấp phép cho tất cả các thiết bị khi chúng xuất hiện. Tuy nhiên,
hãy nhớ rằng điều này sẽ bỏ qua các cấp độ bảo mật và làm cho hệ thống
dễ bị tấn công bởi DMA.

Bắt đầu với bộ điều khiển Intel Falcon Ridge Thunderbolt, có 4
mức độ bảo mật có sẵn. Intel Titan Ridge bổ sung thêm một cấp độ bảo mật
(thông thường). Lý do cho điều này là thực tế là các thiết bị được kết nối có thể
là chủ DMA và do đó đọc nội dung của bộ nhớ máy chủ mà không cần CPU và OS
biết về nó. Có nhiều cách để ngăn chặn điều này bằng cách thiết lập IOMMU nhưng
nó không phải lúc nào cũng có sẵn vì nhiều lý do.

Một số hệ thống USB4 có cài đặt BIOS để vô hiệu hóa đường hầm PCIe. Đây là
được coi là cấp độ bảo mật khác (nopcie).

Các mức độ bảo mật như sau:

không có
    Tất cả các thiết bị đều được kết nối tự động bằng phần mềm cơ sở. Không có người dùng
    cần có sự phê duyệt. Trong cài đặt BIOS, điều này thường được gọi là
    ZZ0000ZZ.

người dùng
    Người dùng được hỏi liệu thiết bị có được phép kết nối hay không.
    Dựa trên thông tin nhận dạng thiết bị có sẵn thông qua
    ZZ0000ZZ, người dùng có thể đưa ra quyết định.
    Trong cài đặt BIOS, nó thường được gọi là ZZ0001ZZ.

an toàn
    Người dùng được hỏi liệu thiết bị có được phép kết nối hay không. trong
    Ngoài UUID, thiết bị (nếu hỗ trợ kết nối an toàn) sẽ được gửi
    một thử thách phải phù hợp với thử thách được mong đợi dựa trên một khóa ngẫu nhiên
    được ghi vào thuộc tính sysfs ZZ0000ZZ. Trong cài đặt BIOS, đây là
    thường được gọi là ZZ0001ZZ.

dponly
    Phần sụn tự động tạo đường hầm cho Cổng hiển thị và
    USB. Không có đường hầm PCIe nào được thực hiện. Trong cài đặt BIOS, đây là
    thường được gọi là ZZ0000ZZ.

chỉ có chúng tôi
    Phần sụn tự động tạo đường hầm cho bộ điều khiển USB và
    Cổng hiển thị trong một dock. Tất cả các liên kết PCIe ở phía dưới của dock đều được
    bị loại bỏ.

nopcie
    Đường hầm PCIe bị vô hiệu hóa/bị cấm khỏi BIOS. Có sẵn ở một số
    Hệ thống USB4.

Mức độ bảo mật hiện tại có thể được đọc từ
ZZ0000ZZ trong đó ZZ0001ZZ là
miền Thunderbolt mà bộ điều khiển máy chủ quản lý. Thông thường có
một miền cho mỗi bộ điều khiển máy chủ Thunderbolt.

Nếu mức độ bảo mật ghi là ZZ0000ZZ hoặc ZZ0001ZZ thì thiết bị được kết nối
thiết bị phải được người dùng ủy quyền trước khi tạo đường hầm PCIe
(ví dụ: thiết bị PCIe xuất hiện).

Mỗi thiết bị Thunderbolt được cắm vào sẽ xuất hiện trong sysfs bên dưới
ZZ0000ZZ. Thư mục thiết bị mang
thông tin có thể được sử dụng để nhận dạng thiết bị cụ thể,
bao gồm tên của nó và UUID.

Cấp phép thiết bị khi mức bảo mật là ZZ0000ZZ hoặc ZZ0001ZZ
-----------------------------------------------------------------
Khi một thiết bị được cắm vào, nó sẽ xuất hiện trong sysfs như sau ::

/sys/bus/thunderbolt/devices/0-1/được ủy quyền - 0
  /sys/bus/thunderbolt/devices/0-1/device - 0x8004
  /sys/bus/thunderbolt/devices/0-1/device_name - Bộ chuyển đổi Thunderbolt sang FireWire
  /sys/bus/thunderbolt/devices/0-1/vendor - 0x1
  /sys/bus/thunderbolt/devices/0-1/vendor_name - Apple, Inc.
  /sys/bus/thunderbolt/devices/0-1/unique_id - e0376f00-0300-0100-ffff-ffffffffffff

Thuộc tính ZZ0000ZZ đọc 0, nghĩa là không có đường hầm PCIe nào
đã tạo chưa. Người dùng có thể ủy quyền cho thiết bị bằng cách nhập ::

# echo 1 > /sys/bus/thunderbolt/devices/0-1/được ủy quyền

Điều này sẽ tạo ra các đường hầm PCIe và thiết bị hiện đã được kết nối.

Nếu thiết bị hỗ trợ kết nối an toàn và mức độ bảo mật miền là
được đặt thành ZZ0000ZZ, nó có thuộc tính bổ sung ZZ0001ZZ có thể chứa
một giá trị 32 byte ngẫu nhiên được sử dụng để ủy quyền và thách thức thiết bị trong
kết nối tương lai::

/sys/bus/thunderbolt/devices/0-3/được ủy quyền - 0
  /sys/bus/thunderbolt/devices/0-3/device - 0x305
  /sys/bus/thunderbolt/devices/0-3/device_name - Hộp PCIe AKiTiO Thunder3
  /sys/bus/thunderbolt/devices/0-3/key -
  /sys/bus/thunderbolt/devices/0-3/vendor - 0x41
  /sys/bus/thunderbolt/devices/0-3/vendor_name - inXtron
  /sys/bus/thunderbolt/devices/0-3/unique_id - dc010000-0000-8508-a22d-32ca6421cb16

Lưu ý rằng khóa này trống theo mặc định.

Nếu người dùng không muốn sử dụng kết nối an toàn, họ có thể chỉ cần ZZ0000ZZ
thuộc tính ZZ0001ZZ và các đường hầm PCIe sẽ được tạo trong
theo cách tương tự như ở cấp độ bảo mật ZZ0002ZZ.

Nếu người dùng muốn sử dụng kết nối an toàn, lần đầu tiên thiết bị sẽ được
cắm một key cần tạo và gửi tới thiết bị::

# key=$(openssl rand -hex 32)
  # echo $key > /sys/bus/thunderbolt/devices/0-3/key
  # echo 1 > /sys/bus/thunderbolt/devices/0-3/được ủy quyền

Bây giờ thiết bị đã được kết nối (đường hầm PCIe được tạo) và ngoài ra
khóa được lưu trữ trên thiết bị NVM.

Lần tiếp theo khi thiết bị được cắm vào, người dùng có thể xác minh (thách thức)
thiết bị sử dụng cùng một khóa::

# echo $key > /sys/bus/thunderbolt/devices/0-3/key
  # echo 2 > /sys/bus/thunderbolt/devices/0-3/được ủy quyền

Nếu thử thách mà thiết bị trả về khớp với thử thách mà chúng tôi mong đợi dựa trên
trên phím, thiết bị được kết nối và đường hầm PCIe được tạo.
Tuy nhiên, nếu thử thách thất bại thì không có đường hầm nào được tạo và có lỗi.
được trả lại cho người dùng.

Nếu người dùng vẫn muốn kết nối thiết bị, họ có thể chấp thuận
thiết bị không có khóa hoặc viết khóa mới và ghi 1 vào
ZZ0000ZZ để lấy khóa mới được lưu trên thiết bị NVM.

Hủy cấp phép thiết bị
----------------------
Có thể hủy cấp quyền cho các thiết bị bằng cách ghi ZZ0000ZZ vào
Thuộc tính ZZ0001ZZ. Điều này yêu cầu sự hỗ trợ từ kết nối
việc triển khai trình quản lý và có thể được kiểm tra bằng cách đọc tên miền
Thuộc tính ZZ0002ZZ. Nếu nó đọc ZZ0003ZZ thì tính năng này là
được hỗ trợ.

Khi một thiết bị bị hủy cấp phép đường hầm PCIe từ thiết bị mẹ
Cổng xuôi dòng PCIe (hoặc gốc) tới thiết bị Cổng ngược dòng PCIe bị rách
xuống. Về cơ bản, điều này giống với PCIe hot-remove và PCIe
cấu trúc liên kết được đề cập sẽ không thể truy cập được nữa cho đến khi thiết bị được
được ủy quyền lại. Nếu có bộ lưu trữ như NVMe hoặc tương tự,
có nguy cơ mất dữ liệu nếu hệ thống tập tin trên bộ lưu trữ đó không được
tắt đúng cách. Bạn đã được cảnh báo!

Bảo vệ DMA sử dụng IOMMU
------------------------------
Các hệ thống gần đây từ năm 2018 trở đi có cổng Thunderbolt có thể tự nhiên
hỗ trợ IOMMU. Điều này có nghĩa là bảo mật Thunderbolt được xử lý bởi IOMMU
vì vậy các thiết bị được kết nối không thể truy cập các vùng bộ nhớ bên ngoài vùng được chỉ định
được các tài xế phân bổ cho họ. Khi Linux chạy trên hệ thống như vậy
tự động kích hoạt IOMMU nếu người dùng chưa kích hoạt. Những cái này
hệ thống có thể được xác định bằng cách đọc ZZ0000ZZ từ
Thuộc tính ZZ0001ZZ.

Trình điều khiển không làm gì đặc biệt trong trường hợp này nhưng vì DMA
việc bảo vệ được xử lý bởi IOMMU, các mức bảo mật (nếu được đặt) là
dư thừa. Vì lý do này, một số hệ thống có mức độ bảo mật được đặt thành
ZZ0000ZZ. Các hệ thống khác có mức bảo mật được đặt thành ZZ0001ZZ để
hỗ trợ hạ cấp xuống hệ điều hành cũ hơn, vì vậy người dùng muốn tự động
ủy quyền cho các thiết bị khi tính năng bảo vệ IOMMU DMA được bật có thể sử dụng
tuân theo quy tắc ZZ0002ZZ::

ACTION=="thêm", SUBSYSTEM=="thunderbolt", ATTRS{iommu_dma_protection}=="1", ATTR{authorized}=="0", ATTR{authorized}="1"

Nâng cấp NVM trên thiết bị Thunderbolt, máy chủ hoặc bộ đếm thời gian
---------------------------------------------------------------------
Vì hầu hết các chức năng được xử lý trong phần sụn chạy trên
bộ điều khiển máy chủ hoặc một thiết bị, điều quan trọng là phần sụn có thể
đã nâng cấp lên bản mới nhất khi các lỗi có thể xảy ra trong đó đã được sửa.
Thông thường các OEM cung cấp phần sụn này từ trang web hỗ trợ của họ.

Hiện tại, phương pháp cập nhật chương trình cơ sở được khuyến nghị là thông qua công cụ "fwupd".
Theo mặc định, nó sử dụng cổng LVFS (Dịch vụ chương trình cơ sở của nhà cung cấp Linux) để có được
chương trình cơ sở mới nhất từ ​​các nhà cung cấp phần cứng và cập nhật các thiết bị được kết nối nếu tìm thấy
tương thích. Để biết chi tiết tham khảo: ZZ0000ZZ

Trước khi bạn nâng cấp chương trình cơ sở trên thiết bị, máy chủ hoặc bộ đếm thời gian, vui lòng thực hiện
chắc chắn đó là một bản nâng cấp phù hợp. Không làm điều đó có thể khiến thiết bị
ở trạng thái không thể sử dụng nó đúng cách nữa nếu không có đặc biệt
công cụ!

Không hỗ trợ nâng cấp máy chủ NVM trên Apple Mac.

Fwupd được cài đặt theo mặc định. Nếu bạn không có nó trên hệ thống của mình, chỉ cần
sử dụng trình quản lý gói phân phối của bạn để có được nó.

Để xem các bản cập nhật có thể có thông qua fwupd, bạn cần cắm Thunderbolt
thiết bị để bộ điều khiển máy chủ xuất hiện. Không quan trọng cái nào
thiết bị đã được kết nối (trừ khi bạn đang nâng cấp NVM trên một thiết bị - thì bạn
cần kết nối thiết bị cụ thể đó).

Lưu ý phương pháp dành riêng cho OEM để cấp nguồn cho bộ điều khiển ("cấp nguồn") có thể
có sẵn cho hệ thống của bạn trong trường hợp đó không cần phải cắm
Thiết bị sấm sét.

Cập nhật chương trình cơ sở bằng fwupd rất đơn giản - tham khảo chính thức
readme trên fwupd github.

Nếu hình ảnh chương trình cơ sở được ghi thành công, thiết bị sẽ sớm biến mất.
Khi nó quay trở lại, người lái xe sẽ nhận thấy nó và khởi động toàn bộ sức mạnh
chu kỳ. Sau một thời gian, thiết bị lại xuất hiện và lần này nó sẽ như vậy
đầy đủ chức năng.

Thiết bị quan tâm sẽ hiển thị phiên bản mới trong "Phiên bản hiện tại"
và "Cập nhật trạng thái: Thành công" trong giao diện của fwupd.

Nâng cấp firmware theo cách thủ công
---------------------------------------------------------------
Nếu có thể, hãy sử dụng fwupd để cập nhật chương trình cơ sở. Tuy nhiên, nếu thiết bị OEM của bạn
chưa tải chương trình cơ sở lên LVFS nhưng có sẵn để tải xuống
từ phía họ, bạn có thể sử dụng phương pháp bên dưới để trực tiếp nâng cấp
phần sụn.

Cập nhật chương trình cơ sở thủ công có thể được thực hiện bằng công cụ 'dd'. Để cập nhật chương trình cơ sở
sử dụng phương pháp này, bạn cần ghi nó vào các phần không hoạt động của NVM
của máy chủ hoặc thiết bị. Ví dụ về cách cập nhật Intel NUC6i7KYK
(Skull Canyon) Bộ điều khiển Thunderbolt NVM::

# dd if=KYK_TBT_FW_0018.bin of=/sys/bus/thunderbolt/devices/0-0/nvm_non_active0/nvmem

Sau khi thao tác hoàn tất, chúng tôi có thể kích hoạt xác thực NVM và
quá trình nâng cấp như sau::

# echo 1 > /sys/bus/thunderbolt/devices/0-0/nvm_authenticate

Nếu không có lỗi nào được trả về, thiết bị sẽ hoạt động như mô tả ở phần trước
phần.

Chúng tôi có thể xác minh rằng phần sụn NVM mới đang hoạt động bằng cách chạy lệnh sau
lệnh::

# cat /sys/bus/thunderbolt/devices/0-0/nvm_authenticate
  0x0
  # cat /sys/bus/thunderbolt/devices/0-0/nvm_version
  18.0

Nếu ZZ0000ZZ chứa bất cứ thứ gì khác ngoài 0x0 thì đó là lỗi
mã từ chu kỳ xác thực cuối cùng, có nghĩa là xác thực
của hình ảnh NVM không thành công.

Note tên các thiết bị NVMem ZZ0000ZZ và ZZ0001ZZ
phụ thuộc vào thứ tự chúng được đăng ký trong hệ thống con NVMem. N trong
tên là mã định danh được hệ thống con NVMem thêm vào.

Nâng cấp bộ định thời gian trên bo mạch NVM khi không có cáp kết nối
--------------------------------------------------------------------
Nếu nền tảng hỗ trợ, có thể nâng cấp bộ hẹn giờ NVM
chương trình cơ sở ngay cả khi không có gì kết nối với USB4
cổng. Trong trường hợp này, thiết bị ZZ0000ZZ có hai đặc biệt
thuộc tính: ZZ0001ZZ và ZZ0002ZZ. Cách nâng cấp firmware
trước tiên là đặt cổng USB4 ở chế độ ngoại tuyến::

# echo 1 > /sys/bus/thunderbolt/devices/0-0/usb4_port1/offline

Bước này đảm bảo cổng không phản hồi với bất kỳ sự kiện cắm nóng nào,
và cũng đảm bảo bộ hẹn giờ được bật nguồn. Bước tiếp theo là quét
dành cho người hẹn giờ lại::

# echo 1 > /sys/bus/thunderbolt/devices/0-0/usb4_port1/rescan

Điều này liệt kê và thêm các bộ đếm thời gian trên tàu. Giờ đây, bộ đếm thời gian NVM có thể được
được nâng cấp theo cách tương tự như khi kết nối cáp (xem phần trước
phần). Tuy nhiên, bộ đếm thời gian không bị ngắt kết nối vì chúng tôi đang ngoại tuyến
mode) vì vậy sau khi ghi ZZ0000ZZ vào ZZ0001ZZ, bạn nên đợi
5 giây trở lên trước khi chạy lại quét lại::

# echo 1 > /sys/bus/thunderbolt/devices/0-0/usb4_port1/rescan

Điểm này nếu mọi việc suôn sẻ, cổng có thể được đưa trở lại
trạng thái chức năng một lần nữa::

# echo 0 > /sys/bus/thunderbolt/devices/0-0/usb4_port1/offline

Nâng cấp NVM khi bộ điều khiển máy chủ ở chế độ an toàn
-------------------------------------------------------
Nếu NVM hiện tại không được xác thực chính xác (hoặc bị thiếu),
bộ điều khiển máy chủ chuyển sang chế độ an toàn, điều đó có nghĩa là chỉ có sẵn
chức năng đang nhấp nháy một hình ảnh NVM mới. Khi ở chế độ này, việc đọc
ZZ0000ZZ không thành công với ZZ0001ZZ và nhận dạng thiết bị
thông tin bị thiếu.

Để khôi phục từ chế độ này, người ta cần flash hình ảnh NVM hợp lệ vào
bộ điều khiển máy chủ theo cách tương tự được thực hiện trong chương trước.

Sự kiện đào hầm
----------------
Trình điều khiển gửi các sự kiện ZZ0000ZZ tới không gian người dùng khi có
thay đổi đường hầm trong ZZ0001ZZ. Thông báo mang theo
các biến môi trường sau::

TUNNEL_EVENT=<EVENT>
  TUNNEL_DETAILS=0:12 <-> 1:20 (USB3)

Các giá trị có thể có của ZZ0000ZZ là:

kích hoạt
    Đường hầm đã được kích hoạt (được tạo).

đã thay đổi
    Có một sự thay đổi trong đường hầm này. Ví dụ: phân bổ băng thông là
    đã thay đổi.

bị vô hiệu hóa
    Đường hầm đã bị phá bỏ.

băng thông thấp
    Đường hầm không nhận được băng thông tối ưu.

không đủ băng thông
    Không có đủ băng thông cho các yêu cầu đường hầm hiện tại.

ZZ0000ZZ chỉ được cung cấp nếu biết đường hầm. cho
ví dụ: trong trường hợp Trình quản lý kết nối chương trình cơ sở, phần này bị thiếu hoặc không
không cung cấp thông tin đường hầm đầy đủ. Trong trường hợp Trình quản lý kết nối phần mềm
điều này bao gồm các chi tiết đường hầm đầy đủ. Định dạng hiện phù hợp với những gì
trình điều khiển sử dụng khi đăng nhập. Điều này có thể thay đổi theo thời gian.

Kết nối mạng qua cáp Thunderbolt
---------------------------------
Công nghệ Thunderbolt cho phép giao tiếp phần mềm giữa hai máy chủ
được kết nối bằng cáp Thunderbolt.

Có thể tạo đường hầm cho bất kỳ loại lưu lượng nào qua liên kết Thunderbolt nhưng
hiện tại chúng tôi chỉ hỗ trợ giao thức Apple ThunderboltIP.

Nếu máy chủ khác đang chạy Windows hoặc macOS, điều duy nhất bạn cần làm là
làm là kết nối cáp Thunderbolt giữa hai máy chủ; cái
Trình điều khiển ZZ0000ZZ được tải tự động. Nếu máy chủ khác là
Ngoài ra, Linux, bạn nên tải ZZ0001ZZ theo cách thủ công trên một máy chủ (nó
không quan trọng cái nào)::

Lưới sét # modprobe

Điều này sẽ tự động kích hoạt tải mô-đun trên máy chủ khác. Nếu người lái xe
được tích hợp sẵn vào kernel image nên không cần phải làm gì cả.

Trình điều khiển sẽ tạo một giao diện ethernet ảo cho mỗi Thunderbolt
cổng được đặt tên như ZZ0000ZZ, v.v. Từ thời điểm này
bạn có thể sử dụng các công cụ không gian người dùng tiêu chuẩn như ZZ0001ZZ để
định cấu hình giao diện hoặc để GUI của bạn tự động xử lý nó.

Sức mạnh cưỡng bức
------------------
Nhiều OEM bao gồm một phương pháp có thể được sử dụng để tăng sức mạnh của
Bộ điều khiển Thunderbolt sang trạng thái "Bật" ngay cả khi không có gì được kết nối.
Nếu được máy của bạn hỗ trợ, điều này sẽ được hiển thị bởi bus WMI với
thuộc tính sysfs có tên là "force_power", xem
Documentation/ABI/testing/sysfs-platform-intel-wmi-thunderbolt để biết chi tiết.

Lưu ý: hiện tại không thể truy vấn trạng thái sức mạnh của nền tảng.