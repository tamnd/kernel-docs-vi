.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/pm/intel_idle.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. include:: <isonum.txt>

==================================================
Trình điều khiển quản lý thời gian nhàn rỗi ZZ0000ZZ CPU
==============================================

:Bản quyền: ZZ0000ZZ 2020 Tập đoàn Intel

:Tác giả: Rafael J. Wysocki <rafael.j.wysocki@intel.com>


Thông tin chung
===================

ZZ0001ZZ là một phần của
ZZ0000ZZ trong nhân Linux
(ZZ0002ZZ).  Đây là trình điều khiển quản lý thời gian nhàn rỗi CPU mặc định cho
Nehalem và các thế hệ bộ xử lý Intel sau này, nhưng mức độ hỗ trợ cho
một mô hình bộ xử lý cụ thể trong đó phụ thuộc vào việc nó có nhận ra điều đó hay không
kiểu bộ xử lý và cũng có thể phụ thuộc vào thông tin đến từ nền tảng
phần sụn.  [Để hiểu ZZ0003ZZ cần phải biết ZZ0004ZZ như thế nào
hoạt động nói chung, vì vậy đây là lúc để làm quen với
Documentation/admin-guide/pm/cpuidle.rst nếu bạn chưa làm điều đó.]

ZZ0000ZZ sử dụng lệnh ZZ0001ZZ để thông báo cho bộ xử lý rằng
logic CPU đang thực thi nó ở trạng thái rảnh và do đó có thể đặt một số
các khối chức năng của bộ xử lý sang trạng thái năng lượng thấp.  Hướng dẫn đó mất hai
đối số (được truyền trong các thanh ghi ZZ0002ZZ và ZZ0003ZZ của CPU đích),
đầu tiên, được gọi là ZZ0006ZZ, có thể được bộ xử lý sử dụng để
xác định những gì có thể được thực hiện (để biết chi tiết, hãy tham khảo tài liệu của Nhà phát triển phần mềm Intel
Hướng dẫn sử dụng [1]_).  Theo đó, ZZ0004ZZ từ chối làm việc với các bộ xử lý ở
hỗ trợ cho lệnh ZZ0005ZZ đã bị vô hiệu hóa (ví dụ:
thông qua menu cấu hình chương trình cơ sở nền tảng) hoặc không hỗ trợ điều đó
chỉ dẫn gì cả.

ZZ0000ZZ không phải là mô-đun nên không thể dỡ xuống, điều đó có nghĩa là
cách duy nhất để truyền các tham số thời gian cấu hình sớm cho nó là thông qua kernel
dòng lệnh.

Giao diện hệ thống
===============

Trình điều khiển ZZ0000ZZ hiển thị các thuộc tính ZZ0001ZZ sau trong
ZZ0002ZZ:

ZZ0000ZZ
	Bật hoặc tắt chức năng hạ cấp C1 cho tất cả CPU trong hệ thống. Tập tin này là
	chỉ hiển thị trên các nền tảng hỗ trợ tính năng giáng cấp C1 và ở đâu
	nó đã được thử nghiệm. Giá trị 0 có nghĩa là việc hạ cấp C1 bị vô hiệu hóa, giá trị 1 có nghĩa là
	rằng nó đã được kích hoạt. Viết 0 hoặc 1 để vô hiệu hóa hoặc kích hoạt việc hạ cấp C1 cho
	tất cả các CPU.

Tính năng hạ cấp C1 liên quan đến việc hạ cấp sâu phần mềm nền tảng
	Yêu cầu trạng thái C từ HĐH (ví dụ: yêu cầu C6) đến C1. Ý tưởng là vậy
	chương trình cơ sở giám sát tốc độ đánh thức CPU và nếu nó cao hơn tốc độ
	ngưỡng dành riêng cho nền tảng, chương trình cơ sở sẽ giảm bớt các yêu cầu trạng thái C sâu
	đến C1. Ví dụ: Linux yêu cầu C6, nhưng phần sụn nhận thấy có quá nhiều
	thời gian đánh thức mỗi giây và giữ CPU ở C1. Khi CPU ở lại
	C1 đủ lâu, nền tảng sẽ thăng cấp nó trở lại C6. Điều này có thể cải thiện
	hiệu suất của một số khối lượng công việc nhưng nó cũng có thể làm tăng mức tiêu thụ điện năng.

.. _intel-idle-enumeration-of-states:

Bảng liệt kê các trạng thái nhàn rỗi
==========================

Mỗi giá trị gợi ý ZZ0000ZZ được bộ xử lý hiểu là giấy phép để
tự cấu hình lại theo một cách nhất định để tiết kiệm năng lượng.  Bộ xử lý
cấu hình (với mức tiêu thụ điện năng giảm) do đó được đề cập đến
dưới dạng trạng thái C (theo thuật ngữ ACPI) hoặc trạng thái không hoạt động.  Danh sách ý nghĩa
Giá trị gợi ý ZZ0001ZZ và trạng thái không hoạt động (tức là cấu hình năng lượng thấp của
bộ xử lý) tương ứng với chúng tùy thuộc vào kiểu bộ xử lý và nó cũng có thể
phụ thuộc vào cấu hình của nền tảng.

Để tạo danh sách các trạng thái không hoạt động khả dụng theo yêu cầu của ZZ0001ZZ
hệ thống con (xem ZZ0000ZZ trong
Tài liệu/admin-guide/pm/cpuidle.rst),
ZZ0002ZZ có thể sử dụng hai nguồn thông tin: bảng tĩnh trạng thái không hoạt động
cho các mẫu bộ xử lý khác nhau có trong chính trình điều khiển và các bảng ACPI
của hệ thống.  Cái trước luôn được sử dụng nếu kiểu bộ xử lý hiện có
được ZZ0003ZZ công nhận và cái sau được sử dụng nếu điều đó là cần thiết cho
mô hình bộ xử lý nhất định (đó là trường hợp của tất cả các mô hình bộ xử lý máy chủ
được ZZ0004ZZ nhận dạng) hoặc nếu kiểu bộ xử lý không được nhận dạng.
[Có một tham số mô-đun có thể được sử dụng để khiến trình điều khiển sử dụng ACPI
các bảng có bất kỳ kiểu bộ xử lý nào được nó nhận dạng; xem
ZZ0005ZZ.]

Nếu các bảng ACPI sẽ được sử dụng để xây dựng danh sách các nhàn rỗi có sẵn
nêu rõ, ZZ0000ZZ trước tiên tìm kiếm đối tượng ZZ0001ZZ theo một trong các ACPI
các đối tượng tương ứng với CPU trong hệ thống (tham khảo thông số kỹ thuật ACPI
[2]_ để biết mô tả về ZZ0002ZZ và gói đầu ra của nó).  Bởi vì
Hệ thống con ZZ0003ZZ dự kiến rằng danh sách các trạng thái rảnh được cung cấp bởi
trình điều khiển sẽ phù hợp với tất cả các CPU được nó xử lý và ZZ0004ZZ là
được đăng ký làm trình điều khiển ZZ0005ZZ cho tất cả các CPU trong hệ thống,
trình điều khiển tìm kiếm đối tượng ZZ0006ZZ đầu tiên trả về ít nhất một trạng thái rảnh hợp lệ
mô tả trạng thái và sao cho tất cả các trạng thái nhàn rỗi có trong kết quả trả về của nó
gói thuộc loại FFH (Phần cứng cố định chức năng), có nghĩa là
Lệnh ZZ0007ZZ dự kiến sẽ được sử dụng để báo cho bộ xử lý biết rằng nó có thể
nhập một trong số họ.  Gói trả lại của ZZ0008ZZ đó sau đó được coi là
áp dụng cho tất cả các CPU khác trong hệ thống và trạng thái không hoạt động
các mô tả được trích xuất từ nó được lưu trữ trong danh sách sơ bộ các trạng thái không hoạt động
đến từ các bảng ACPI.  [Bước này được bỏ qua nếu ZZ0009ZZ
được cấu hình để bỏ qua các bảng ACPI; xem ZZ0010ZZ.]

Tiếp theo, mục đầu tiên (chỉ số 0) trong danh sách trạng thái rảnh có sẵn là
được khởi tạo để thể hiện "trạng thái nhàn rỗi thăm dò" (trạng thái giả nhàn rỗi trong đó
CPU đích liên tục tìm nạp và thực hiện các lệnh) và
các mục nhập trạng thái nhàn rỗi (thực) tiếp theo được điền như sau.

Nếu kiểu bộ xử lý hiện có được ZZ0001ZZ nhận dạng thì có một
(tĩnh) bảng mô tả trạng thái không hoạt động cho nó trong trình điều khiển.  Trong trường hợp đó,
bảng "nội bộ" là nguồn thông tin chính về trạng thái nhàn rỗi và
thông tin từ nó được sao chép vào danh sách cuối cùng của các trạng thái nhàn rỗi có sẵn.  Nếu
không cần sử dụng bảng ACPI để liệt kê các trạng thái không hoạt động
(tùy thuộc vào kiểu bộ xử lý), tất cả trạng thái không hoạt động được liệt kê đều được bật bởi
mặc định (vì vậy tất cả chúng sẽ được ZZ0002ZZ xem xét
bộ điều chỉnh trong quá trình lựa chọn trạng thái rảnh rỗi của CPU).  Mặt khác, một số nhàn rỗi được liệt kê
các trạng thái có thể không được bật theo mặc định nếu không có mục nhập phù hợp trong
danh sách sơ bộ các trạng thái rảnh đến từ các bảng ACPI.  Trong trường hợp đó người dùng
không gian vẫn có thể kích hoạt chúng sau này (trên cơ sở mỗi CPU) với sự trợ giúp của
thuộc tính trạng thái rảnh ZZ0003ZZ trong ZZ0004ZZ (xem
ZZ0000ZZ trong
Tài liệu/admin-guide/pm/cpuidle.rst).  Điều này về cơ bản có nghĩa là
các trạng thái không hoạt động mà trình điều khiển đã biết có thể không được bật theo mặc định nếu chúng có
không bị lộ bởi phần sụn nền tảng (thông qua các bảng ACPI).

Nếu kiểu bộ xử lý đã cho không được ZZ0000ZZ nhận dạng, nhưng nó
hỗ trợ ZZ0001ZZ, danh sách sơ bộ các trạng thái không hoạt động đến từ ACPI
các bảng được sử dụng để xây dựng danh sách cuối cùng sẽ được cung cấp cho
Lõi ZZ0002ZZ trong quá trình đăng ký trình điều khiển.  Đối với mỗi trạng thái không hoạt động trong danh sách đó,
mô tả, gợi ý ZZ0003ZZ và độ trễ thoát được sao chép sang tệp tương ứng
mục trong danh sách cuối cùng của trạng thái nhàn rỗi.  Tên của trạng thái nhàn rỗi được thể hiện
bởi nó (được trả về bởi thuộc tính trạng thái nhàn rỗi ZZ0004ZZ trong ZZ0005ZZ) là
"CX_ACPI", trong đó X là chỉ mục của trạng thái không hoạt động đó trong danh sách cuối cùng (lưu ý rằng
giá trị tối thiểu của X là 1, vì 0 được dành riêng cho trạng thái "bỏ phiếu") và
nơi cư trú mục tiêu của nó dựa trên giá trị độ trễ thoát.  Cụ thể, đối với
Nhàn rỗi loại C1 cho biết giá trị độ trễ thoát cũng được sử dụng làm nơi cư trú mục tiêu
(để tương thích với phần lớn các bảng trạng thái nhàn rỗi "nội bộ" cho
các mẫu bộ xử lý khác nhau được ZZ0006ZZ công nhận) và cho các mẫu bộ xử lý nhàn rỗi khác
loại trạng thái (C2 và C3), giá trị cư trú mục tiêu gấp 3 lần độ trễ thoát
(một lần nữa, đó là vì nó phản ánh tỷ lệ nơi cư trú mục tiêu và tỷ lệ độ trễ thoát
trong phần lớn các trường hợp đối với các kiểu bộ xử lý được ZZ0007ZZ công nhận).
Tất cả các trạng thái không hoạt động trong danh sách cuối cùng đều được bật theo mặc định trong trường hợp này.


.. _intel-idle-initialization:

Khởi tạo
==============

Việc khởi tạo ZZ0000ZZ bắt đầu bằng việc kiểm tra xem lệnh kernel có
tùy chọn dòng cấm sử dụng lệnh ZZ0001ZZ.  Nếu đúng như vậy,
một mã lỗi được trả về ngay lập tức.

Bước tiếp theo là kiểm tra xem model bộ xử lý có được người dùng biết đến hay không.
trình điều khiển, xác định phương pháp liệt kê trạng thái nhàn rỗi (xem
ZZ0004ZZ) và bộ xử lý có hay không
hỗ trợ ZZ0000ZZ (quá trình khởi tạo không thành công nếu không đúng như vậy).  Sau đó,
hỗ trợ ZZ0001ZZ trong bộ xử lý được liệt kê thông qua ZZ0002ZZ và
Việc khởi tạo trình điều khiển không thành công nếu mức hỗ trợ không như mong đợi (đối với
ví dụ: nếu tổng số trạng thái con ZZ0003ZZ được trả về là 0).

Tiếp theo, nếu trình điều khiển không được cấu hình để bỏ qua các bảng ACPI (xem
ZZ0000ZZ), thông tin trạng thái rảnh được cung cấp bởi
phần sụn nền tảng được trích xuất từ ​​chúng.

Sau đó, các đối tượng thiết bị ZZ0000ZZ được phân bổ cho tất cả các CPU và danh sách
trạng thái nhàn rỗi có sẵn được tạo như được giải thích
ZZ0001ZZ.

Cuối cùng, ZZ0000ZZ được đăng ký với sự trợ giúp của cpuidle_register_driver()
làm trình điều khiển ZZ0001ZZ cho tất cả các CPU trong hệ thống và gọi lại trực tuyến CPU
để định cấu hình các CPU riêng lẻ được đăng ký qua cpuhp_setup_state(),
(trong số những thứ khác) khiến thủ tục gọi lại được gọi cho tất cả
Các CPU có trong hệ thống tại thời điểm đó (mỗi CPU thực thi phiên bản riêng của nó
thói quen gọi lại).  Quy trình đó đăng ký một thiết bị ZZ0002ZZ cho CPU
chạy nó (cho phép hệ thống con ZZ0003ZZ vận hành CPU đó) và
tùy chọn thực hiện một số hành động khởi tạo dành riêng cho CPU có thể
cần thiết cho mô hình bộ xử lý nhất định.


.. _intel-idle-parameters:

Tùy chọn dòng lệnh hạt nhân và tham số mô-đun
=================================================

Mã hỗ trợ kiến trúc ZZ0005ZZ nhận dạng ba dòng lệnh kernel
các tùy chọn liên quan đến quản lý thời gian nhàn rỗi của CPU: ZZ0000ZZ, ZZ0001ZZ,
và ZZ0002ZZ.  Nếu bất kỳ cái nào trong số chúng có mặt trong dòng lệnh kernel, thì
Lệnh ZZ0003ZZ không được phép sử dụng, do đó việc khởi tạo
ZZ0004ZZ sẽ thất bại.

Ngoài ra còn có năm tham số mô-đun được ZZ0000ZZ công nhận
chính nó có thể được thiết lập thông qua dòng lệnh kernel (chúng không thể được cập nhật qua
sysfs, vì vậy đó là cách duy nhất để thay đổi giá trị của chúng).

Giá trị tham số ZZ0001ZZ là chỉ số trạng thái không tải tối đa trong danh sách
trạng thái nhàn rỗi được cung cấp cho lõi ZZ0002ZZ trong quá trình đăng ký
người lái xe.  Đây cũng là số lượng trạng thái nhàn rỗi thông thường (không kiểm soát vòng) tối đa mà
có thể được sử dụng bởi ZZ0003ZZ, do đó việc liệt kê các trạng thái nhàn rỗi bị chấm dứt
sau khi tìm thấy số lượng trạng thái nhàn rỗi có thể sử dụng được (các trạng thái nhàn rỗi khác
có khả năng có thể đã được sử dụng nếu ZZ0004ZZ lớn hơn thì không
đều được xem xét).  Cài đặt ZZ0005ZZ có thể ngăn chặn
ZZ0006ZZ khỏi để lộ các trạng thái không hoạt động được coi là "quá sâu" đối với
một số lý do đối với lõi ZZ0007ZZ, nhưng nó làm được như vậy bằng cách làm cho chúng hoạt động hiệu quả
vô hình cho đến khi hệ thống tắt và khởi động lại, điều này có thể không phải lúc nào cũng
được mong muốn.  Trong thực tế, điều đó chỉ thực sự cần thiết nếu nhàn rỗi
các trạng thái được đề cập không thể được kích hoạt trong quá trình khởi động hệ thống, bởi vì trong
trạng thái làm việc của hệ thống chất lượng dịch vụ quản lý nguồn CPU (PM
Tính năng QoS) có thể được sử dụng để ngăn ZZ0008ZZ chạm vào các trạng thái không hoạt động đó
ngay cả khi chúng đã được liệt kê (xem ZZ0000ZZ trong
Tài liệu/admin-guide/pm/cpuidle.rst).
Đặt ZZ0009ZZ thành 0 khiến quá trình khởi tạo ZZ0010ZZ không thành công.

Các thông số mô-đun ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ là
được ZZ0003ZZ công nhận nếu kernel đã được cấu hình với ACPI
hỗ trợ.  Trong trường hợp ACPI không được định cấu hình, các cờ này không có tác động
về chức năng.

ZZ0000ZZ - Hoàn toàn không sử dụng ACPI.  Chỉ có chế độ gốc, không có
Chế độ ACPI.

ZZ0000ZZ - Không hoạt động ở chế độ ACPI, người lái xe sẽ tham khảo bảng ACPI để biết
Trạng thái bật/tắt trạng thái C ở chế độ gốc.

ZZ0000ZZ - Chỉ hoạt động ở chế độ ACPI, không có chế độ gốc (bỏ qua
tất cả các bảng tùy chỉnh).

Giá trị của tham số mô-đun ZZ0000ZZ (0 theo mặc định) đại diện cho một
danh sách các trạng thái nhàn rỗi bị tắt theo mặc định dưới dạng mặt nạ bit.

Cụ thể, vị trí của các bit được đặt trong giá trị ZZ0004ZZ là
các chỉ mục của trạng thái nhàn rỗi bị tắt theo mặc định (như được phản ánh bởi tên
của các thư mục trạng thái rảnh tương ứng trong ZZ0005ZZ, ZZ0000ZZ,
ZZ0001ZZ ... ZZ0002ZZ ..., trong đó ZZ0006ZZ là chỉ số của
trạng thái nhàn rỗi; xem ZZ0003ZZ trong
Tài liệu/admin-guide/pm/cpuidle.rst).

Ví dụ: nếu ZZ0000ZZ bằng 3, trình điều khiển sẽ tắt chế độ chờ
trạng thái 0 và 1 theo mặc định và nếu nó bằng 8 thì trạng thái rảnh 3 sẽ là
bị tắt theo mặc định, v.v. (vị trí bit vượt quá chỉ số trạng thái không hoạt động tối đa
được bỏ qua).

Các trạng thái không hoạt động bị vô hiệu hóa theo cách này có thể được bật (trên cơ sở mỗi CPU) từ người dùng
không gian thông qua ZZ0000ZZ.

Tham số mô-đun ZZ0000ZZ là cờ boolean (mặc định là
sai). Nếu được đặt, nó được sử dụng để kiểm soát nếu IBRS (Nhánh gián tiếp bị hạn chế
Speculation) nên được tắt khi CPU chuyển sang trạng thái không hoạt động.
Cờ này không ảnh hưởng đến CPU sử dụng IBRS nâng cao mà có thể vẫn còn
bật với ít tác động đến hiệu suất.

Đối với một số CPU, IBRS sẽ được chọn làm biện pháp giảm nhẹ cho Spectre v2 và Retbleed
lỗ hổng bảo mật theo mặc định.  Việc bật chế độ IBRS trong khi chạy không tải có thể
có tác động đến hiệu suất trên người anh em CPU của nó.  Chế độ IBRS sẽ bị tắt
theo mặc định khi CPU chuyển sang trạng thái không hoạt động sâu, nhưng không ở một số
những cái nông hơn.  Việc thiết lập tham số mô-đun ZZ0000ZZ sẽ buộc IBRS
chế độ tắt khi CPU ở bất kỳ trạng thái không hoạt động nào.  Điều này có thể
giúp hiệu suất của anh chị em CPU với chi phí đánh thức cao hơn một chút
độ trễ cho CPU nhàn rỗi.

Đối số ZZ0000ZZ cho phép tùy chỉnh độ trễ và mục tiêu ở trạng thái không hoạt động
cư trú. Cú pháp là danh sách được phân tách bằng dấu phẩy của ZZ0001ZZ
các mục nhập, trong đó ZZ0002ZZ là tên trạng thái không hoạt động, ZZ0003ZZ là độ trễ thoát
tính bằng micro giây và ZZ0004ZZ là nơi cư trú mục tiêu tính bằng micro giây. Nó
không cần thiết phải chỉ định tất cả các trạng thái rảnh rỗi; chỉ những thứ được tùy chỉnh. cho
ví dụ: ZZ0005ZZ đặt độ trễ thoát và vị trí mục tiêu cho
C1 và C6 lần lượt là 1/3 và 50/100 micro giây. Các trạng thái nhàn rỗi còn lại
giữ giá trị mặc định của họ. Trình điều khiển xác minh rằng trạng thái nhàn rỗi sâu hơn có
độ trễ và nơi cư trú mục tiêu cao hơn so với những nơi nông hơn. Ngoài ra, mục tiêu
nơi cư trú không thể nhỏ hơn độ trễ thoát. Nếu bất kỳ điều kiện nào trong số này là
không đáp ứng, trình điều khiển bỏ qua toàn bộ tham số ZZ0006ZZ.

.. _intel-idle-core-and-package-idle-states:

Cấp độ cốt lõi và gói của trạng thái nhàn rỗi
======================================

Thông thường, trong bộ xử lý hỗ trợ lệnh ZZ0000ZZ có (tại
ít nhất) hai mức trạng thái không hoạt động (hoặc trạng thái C).  Một cấp độ, được gọi là
"trạng thái C lõi", bao gồm các lõi riêng lẻ trong bộ xử lý, trong khi các lõi khác
cấp độ, được gọi là "trạng thái gói C", bao gồm toàn bộ gói bộ xử lý
và nó cũng có thể liên quan đến các thành phần khác của hệ thống (GPU, bộ nhớ
bộ điều khiển, trung tâm I/O, v.v.).

Một số giá trị gợi ý ZZ0000ZZ cho phép bộ xử lý chỉ sử dụng trạng thái C lõi
(quan trọng nhất, đó là trường hợp của giá trị gợi ý ZZ0001ZZ tương ứng
sang trạng thái không hoạt động của ZZ0002ZZ), nhưng phần lớn trong số họ cấp cho nó giấy phép để đặt
lõi đích (tức là lõi chứa CPU logic thực thi ZZ0003ZZ
với giá trị gợi ý đã cho) sang trạng thái C cốt lõi cụ thể và sau đó (nếu có thể)
để nhập trạng thái C của gói cụ thể ở cấp độ sâu hơn.  Ví dụ,
Giá trị gợi ý ZZ0004ZZ biểu thị trạng thái không hoạt động của ZZ0005ZZ cho phép bộ xử lý
đưa lõi mục tiêu vào trạng thái năng lượng thấp được gọi là "lõi ZZ0006ZZ" (hoặc
ZZ0007ZZ), điều này xảy ra nếu tất cả các CPU logic (anh chị em SMT) trong lõi đó
đã thực thi ZZ0008ZZ với giá trị gợi ý ZZ0009ZZ (hoặc với giá trị gợi ý
đại diện cho trạng thái nhàn rỗi sâu hơn) và thêm vào đó (trong phần lớn
trường hợp), nó cấp cho bộ xử lý giấy phép để đặt toàn bộ gói (có thể
bao gồm một số thành phần không phải CPU như GPU hoặc bộ điều khiển bộ nhớ) vào
trạng thái năng lượng thấp được gọi là "gói ZZ0010ZZ" (hoặc ZZ0011ZZ), xảy ra nếu
tất cả các lõi đã chuyển sang trạng thái ZZ0012ZZ và (có thể) một số lõi bổ sung
các điều kiện được thỏa mãn (ví dụ: nếu GPU được bao phủ bởi ZZ0013ZZ, nó có thể
phải ở trạng thái năng lượng thấp dành riêng cho GPU nhất định để ZZ0014ZZ hoạt động
có thể truy cập được).

Theo quy định, không có cách đơn giản nào để khiến bộ xử lý chỉ sử dụng trạng thái C lõi
nếu các điều kiện để nhập trạng thái C của gói tương ứng được đáp ứng, thì
CPU logic thực thi ZZ0001ZZ với giá trị gợi ý không phải là cấp độ lõi
chỉ (như đối với ZZ0002ZZ) phải luôn cho rằng điều này có thể khiến bộ xử lý
nhập trạng thái gói C.  [Đó là lý do tại sao độ trễ thoát và nơi cư trú mục tiêu
các giá trị tương ứng với phần lớn các giá trị gợi ý ZZ0003ZZ trong phần "nội bộ"
bảng trạng thái rảnh trong ZZ0004ZZ phản ánh các thuộc tính của gói
C-states.] Nếu việc sử dụng gói C-states hoàn toàn không được mong muốn
ZZ0000ZZ hoặc tham số mô-đun ZZ0005ZZ của
ZZ0006ZZ được mô tả ZZ0009ZZ phải được sử dụng để
giới hạn phạm vi trạng thái nhàn rỗi cho phép ở những trạng thái chỉ có cấp độ lõi
Giá trị gợi ý ZZ0007ZZ (như ZZ0008ZZ).


Tài liệu tham khảo
==========

.. [1] *Intel® 64 and IA-32 Architectures Software Developer’s Manual Volume 2B*,
       https://www.intel.com/content/www/us/en/architecture-and-technology/64-ia-32-architectures-software-developer-vol-2b-manual.html

.. [2] *Advanced Configuration and Power Interface (ACPI) Specification*,
       https://uefi.org/specifications