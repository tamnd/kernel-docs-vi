.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/PCI/pcieaer-howto.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

================================================================
Hướng dẫn trình điều khiển báo cáo lỗi nâng cao PCI Express HOWTO
===========================================================

:Tác giả: - T. Long Nguyễn <tom.l.nguyen@intel.com>
          - Yanmin Zhang <yanmin.zhang@intel.com>

:Bản quyền: ZZ0000ZZ 2006 Tập đoàn Intel

Tổng quan
===========

Giới thiệu về hướng dẫn này
----------------

Hướng dẫn này mô tả những điều cơ bản về Lỗi nâng cao PCI Express (PCIe)
Trình điều khiển báo cáo (AER) và cung cấp thông tin về cách sử dụng nó, cũng như
cũng như cách kích hoạt trình điều khiển của thiết bị Endpoint để phù hợp với
trình điều khiển PCIe AER.


Trình điều khiển PCIe AER là gì?
----------------------------

Tín hiệu lỗi PCIe có thể xảy ra trên chính liên kết PCIe
hoặc thay mặt cho các giao dịch được thực hiện trên liên kết. PCIe
xác định hai mô hình báo cáo lỗi: khả năng cơ bản và
khả năng báo cáo lỗi nâng cao. Năng lực cơ bản là
yêu cầu của tất cả các thành phần PCIe cung cấp mức tối thiểu được xác định
tập hợp các yêu cầu báo cáo lỗi. Báo cáo lỗi nâng cao
khả năng được triển khai với Báo cáo lỗi nâng cao PCIe
cấu trúc khả năng mở rộng cung cấp báo cáo lỗi mạnh mẽ hơn.

Trình điều khiển PCIe AER cung cấp cơ sở hạ tầng hỗ trợ PCIe Advanced
Khả năng báo cáo lỗi. Trình điều khiển PCIe AER cung cấp ba cơ bản
chức năng:

- Thu thập thông tin lỗi toàn diện nếu xảy ra lỗi.
  - Báo lỗi cho người dùng.
  - Thực hiện các hành động khắc phục lỗi.

Trình điều khiển AER chỉ gắn vào Cổng gốc và RCEC hỗ trợ PCIe
Khả năng AER.


Hướng dẫn sử dụng
==========

Bao gồm Trình điều khiển gốc PCIe AER vào nhân Linux
------------------------------------------------------

Trình điều khiển PCIe AER là trình điều khiển dịch vụ Root Port được đính kèm
thông qua trình điều khiển Bus cổng PCIe. Nếu người dùng muốn sử dụng nó, trình điều khiển
phải được biên soạn. Nó được kích hoạt với CONFIG_PCIEAER,
phụ thuộc vào CONFIG_PCIEPORTBUS.

Tải trình điều khiển gốc PCIe AER
-------------------------

Một số hệ thống có hỗ trợ AER trong phần sụn. Kích hoạt hỗ trợ Linux AER tại
đồng thời phần sụn xử lý AER sẽ dẫn đến kết quả không thể đoán trước
hành vi. Do đó, Linux không xử lý các sự kiện AER trừ khi phần sụn
cấp quyền kiểm soát AER cho HĐH thông qua phương thức ACPI _OSC. Xem phần mềm PCI
Thông số kỹ thuật để biết chi tiết về việc sử dụng _OSC.

Đầu ra lỗi AER
----------------

Khi phát hiện lỗi PCIe AER, thông báo lỗi sẽ được xuất ra
bảng điều khiển. Nếu đó là một lỗi có thể sửa được thì nó sẽ xuất ra dưới dạng một thông báo cảnh báo.
Nếu không, nó sẽ được in ra như một lỗi. Vì vậy người dùng có thể chọn khác nhau
mức nhật ký để lọc ra các thông báo lỗi có thể sửa được.

Dưới đây cho thấy một ví dụ::

0000:50:00.0: Lỗi Bus PCIe: mức độ nghiêm trọng=Không thể sửa được (Nghiêm trọng), loại=Lớp giao dịch, (ID người yêu cầu)
  0000:50:00.0: trạng thái lỗi thiết bị [8086:0329]/mặt nạ=00100000/00000000
  0000:50:00.0: [20] UnsupReq (Đầu tiên)
  0000:50:00.0: TLP Tiêu đề: 0x04000001 0x00200a03 0x05010000 0x00050100

Trong ví dụ, 'ID người yêu cầu' có nghĩa là ID của thiết bị đã gửi
thông báo lỗi tới Cổng gốc. Vui lòng tham khảo thông số kỹ thuật PCIe để biết các thông số khác
lĩnh vực.

'Tiêu đề TLP' là tiền tố/tiêu đề của TLP gây ra lỗi
ở định dạng hex thô. Để giải mã Tiêu đề TLP thành dạng người có thể đọc được
người ta có thể sử dụng công cụ tlp:

ZZ0000ZZ

Ví dụ sử dụng::

cuộn tròn -L ZZ0000ZZ | công cụ rtlp --aer

Giới hạn tỷ lệ AER
--------------

Vì thông báo lỗi có thể được tạo ra cho mỗi giao dịch nên chúng ta có thể thấy
khối lượng lớn các lỗi được báo cáo. Để ngăn chặn các thiết bị spam tràn ngập
việc thực thi bảng điều khiển/dừng lại, các thông báo được điều chỉnh theo thiết bị và lỗi
loại (có thể sửa được và không gây tử vong không thể sửa được).  Các lỗi nghiêm trọng, bao gồm
Lỗi DPC, không được giới hạn tốc độ.

AER sử dụng giới hạn tốc độ mặc định là DEFAULT_RATELIMIT_BURST (10 sự kiện)
DEFAULT_RATELIMIT_INTERVAL (5 giây).

Giới hạn tỷ lệ được hiển thị dưới dạng thuộc tính sysfs và có thể định cấu hình.
Xem Tài liệu/ABI/testing/sysfs-bus-pci-devices-aer.

Thống kê / Bộ đếm AER
-------------------------

Khi phát hiện lỗi PCIe AER, bộ đếm/số liệu thống kê cũng bị lộ
ở dạng thuộc tính sysfs được ghi lại tại
Tài liệu/ABI/thử nghiệm/sysfs-bus-pci-devices-aer.

Hướng dẫn dành cho nhà phát triển
===============

Để kích hoạt tính năng khôi phục lỗi, trình điều khiển phần mềm phải cung cấp lệnh gọi lại.

Để hỗ trợ AER tốt hơn, các nhà phát triển cần hiểu cách AER hoạt động.

Lỗi PCIe được phân thành hai loại: lỗi có thể sửa được
và những lỗi không thể sửa được. Sự phân loại này dựa trên tác động
về những lỗi đó, có thể dẫn đến suy giảm hiệu suất hoặc chức năng
thất bại.

Các lỗi có thể sửa được sẽ không ảnh hưởng đến chức năng của
giao diện. Giao thức PCIe có thể phục hồi mà không cần bất kỳ phần mềm nào
can thiệp hoặc mất mát dữ liệu. Những lỗi này được phát hiện và
sửa bằng phần cứng.

Không giống như lỗi có thể sửa được, lỗi không thể sửa được
lỗi ảnh hưởng đến chức năng của giao diện. Lỗi không thể sửa được
có thể gây ra một giao dịch cụ thể hoặc một liên kết PCIe cụ thể
trở nên không đáng tin cậy. Tùy thuộc vào các điều kiện lỗi đó, không thể sửa được
lỗi còn được phân loại thành lỗi không nghiêm trọng và lỗi nghiêm trọng.
Các lỗi không nghiêm trọng khiến giao dịch cụ thể không đáng tin cậy,
nhưng bản thân liên kết PCIe có đầy đủ chức năng. Lỗi nghiêm trọng, bật
mặt khác, khiến liên kết không đáng tin cậy.

Khi bật tính năng báo cáo lỗi PCIe, thiết bị sẽ tự động gửi thông báo
thông báo lỗi tới Cổng gốc phía trên nó khi nó chụp
một lỗi. Cổng gốc, khi nhận được thông báo báo lỗi,
xử lý nội bộ và ghi lại thông báo lỗi trong AER của nó
Cấu trúc năng lực. Thông tin lỗi được ghi lại bao gồm việc lưu trữ
ID người yêu cầu của tác nhân báo cáo lỗi vào Nguồn lỗi
Các thanh ghi nhận dạng và thiết lập các bit lỗi của Lỗi gốc
Đăng ký trạng thái cho phù hợp. Nếu báo cáo lỗi AER được bật trong Root
Thanh ghi lệnh bị lỗi, Cổng gốc tạo ra ngắt khi
lỗi được phát hiện.

Lưu ý rằng các lỗi như mô tả ở trên có liên quan đến PCIe
hệ thống phân cấp và liên kết. Những lỗi này không bao gồm bất kỳ thiết bị cụ thể nào
lỗi vì lỗi cụ thể của thiết bị vẫn sẽ được gửi trực tiếp tới
trình điều khiển thiết bị.

Cung cấp cuộc gọi lại
-----------------

Lệnh gọi lại khắc phục lỗi PCI
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Trình điều khiển gốc PCIe AER sử dụng lệnh gọi lại lỗi để phối hợp
với trình điều khiển thiết bị hạ nguồn được liên kết với hệ thống phân cấp được đề cập
khi thực hiện các hành động khắc phục lỗi.

Cấu trúc dữ liệu pci_driver có một con trỏ err_handler để trỏ tới
pci_error_handlers bao gồm một vài hàm gọi lại
con trỏ. Trình điều khiển AER tuân theo các quy tắc được xác định trong
pci-error-recovery.rst ngoại trừ các phần dành riêng cho PCIe (xem
bên dưới). Vui lòng tham khảo pci-error-recovery.rst để biết chi tiết
định nghĩa của các cuộc gọi lại.

Các phần bên dưới chỉ định thời điểm gọi các hàm gọi lại lỗi.

Lỗi có thể sửa được
~~~~~~~~~~~~~~~~~~

Các lỗi có thể sửa được không ảnh hưởng đến chức năng của
giao diện. Giao thức PCIe có thể phục hồi mà không cần bất kỳ
sự can thiệp của phần mềm hoặc bất kỳ sự mất mát dữ liệu nào. Những lỗi này không
yêu cầu bất kỳ hành động phục hồi nào. Trình điều khiển AER xóa thiết bị
đăng ký trạng thái lỗi có thể sửa chữa tương ứng và ghi lại các lỗi này.

Lỗi không thể sửa được (không nghiêm trọng và nghiêm trọng)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Trình điều khiển AER thực hiện Thiết lập lại Bus thứ cấp để khôi phục từ
những lỗi không thể sửa được. Việc thiết lập lại được áp dụng tại cổng trên
thiết bị gốc: Nếu thiết bị gốc là Điểm cuối,
chỉ có Điểm cuối được đặt lại. Mặt khác, nếu nguồn gốc
thiết bị có các thiết bị phụ, tất cả đều bị ảnh hưởng bởi
thiết lập lại là tốt.

Nếu thiết bị gốc là Điểm cuối tích hợp Root Complex,
không có cổng nào phía trên có thể áp dụng Thiết lập lại xe buýt phụ.
Trong trường hợp này, trình điều khiển AER thay vào đó sẽ áp dụng Đặt lại cấp độ chức năng.

Nếu thông báo lỗi cho biết lỗi không nghiêm trọng, hãy thực hiện cài đặt lại
ở thượng nguồn là không cần thiết. Trình điều khiển AER gọi error_ detected(dev,
pci_channel_io_normal) tới tất cả các trình điều khiển được liên kết trong hệ thống phân cấp trong
câu hỏi. Ví dụ::

Điểm cuối <==> Cổng xuôi dòng B <==> Cổng ngược dòng A <==> Cổng gốc

Nếu Cổng ngược dòng A gặp lỗi AER, hệ thống phân cấp bao gồm
Hạ lưu cổng B và điểm cuối.

Trình điều khiển có thể trả về PCI_ERS_RESULT_CAN_RECOVER,
PCI_ERS_RESULT_DISCONNECT hoặc PCI_ERS_RESULT_NEED_RESET, tùy thuộc vào
liệu nó có thể khôi phục mà không cần thiết lập lại hay không, coi thiết bị là không thể khôi phục được
hoặc cần thiết lập lại để phục hồi. Nếu tất cả người lái xe bị ảnh hưởng đồng ý rằng họ có thể
khôi phục mà không cần thiết lập lại, nó sẽ bị bỏ qua. Nếu một trình điều khiển yêu cầu thiết lập lại,
nó ghi đè tất cả các trình điều khiển khác.

Nếu thông báo lỗi cho biết lỗi nghiêm trọng, kernel sẽ phát sóng
error_ detected(dev, pci_channel_io_frozen) tới tất cả các trình điều khiển bên trong
một hệ thống phân cấp trong câu hỏi. Sau đó, thực hiện thiết lập lại ở thượng nguồn là
cần thiết. Nếu phát hiện lỗi trả về PCI_ERS_RESULT_CAN_RECOVER
để chỉ ra rằng có thể khôi phục mà không cần thiết lập lại, lỗi
việc xử lý chuyển sang mmio_enabled, nhưng sau đó việc thiết lập lại vẫn được thực hiện
được thực hiện.

Nói cách khác, đối với các lỗi không nghiêm trọng, người lái xe có thể chọn đặt lại.
Nhưng đối với các lỗi nghiêm trọng, họ không thể chọn không đặt lại, dựa trên
giả định rằng liên kết là không đáng tin cậy.

Câu hỏi thường gặp
--------------------------

Hỏi:
  Điều gì xảy ra nếu trình điều khiển thiết bị PCIe không cung cấp
  trình xử lý khôi phục lỗi (pci_driver->err_handler bằng NULL)?

Đáp:
  Các thiết bị được gắn với trình điều khiển sẽ không được phục hồi.
  Hạt nhân sẽ in ra các thông báo thông tin để xác định
  thiết bị không thể phục hồi được.


Chèn lỗi phần mềm
========================

Việc gỡ lỗi mã khôi phục lỗi PCIe AER khá khó khăn vì nó
khó gây ra lỗi phần cứng thực sự. Lỗi dựa trên phần mềm
tính năng tiêm có thể được sử dụng để giả mạo nhiều loại lỗi PCIe khác nhau.

Trước tiên, bạn nên kích hoạt tính năng chèn lỗi phần mềm PCIe AER trong kernel
cấu hình, nghĩa là mục sau đây phải có trong .config của bạn.

CONFIG_PCIEAER_INJECT=y hoặc CONFIG_PCIEAER_INJECT=m

Sau khi khởi động lại với kernel mới hoặc chèn mô-đun, một tệp thiết bị có tên
/dev/aer_inject nên được tạo.

Sau đó, bạn cần một công cụ không gian người dùng có tên là aer-inject, có thể lấy được
từ:

ZZ0000ZZ

Thông tin thêm về aer-inject có thể được tìm thấy trong tài liệu ở
mã nguồn của nó.