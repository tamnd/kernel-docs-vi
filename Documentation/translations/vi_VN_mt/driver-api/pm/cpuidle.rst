.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/pm/cpuidle.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

===========================
CPU Quản lý thời gian nhàn rỗi
========================

:Bản quyền: ZZ0000ZZ 2019 Tập đoàn Intel

:Tác giả: Rafael J. Wysocki <rafael.j.wysocki@intel.com>


Hệ thống con quản lý thời gian nhàn rỗi CPU
==================================

Mỗi khi một trong các CPU logic trong hệ thống (các thực thể xuất hiện
tìm nạp và thực hiện các hướng dẫn: luồng phần cứng, nếu có hoặc bộ xử lý
cores) không hoạt động sau một sự kiện gián đoạn hoặc sự kiện đánh thức tương đương, điều đó có nghĩa là
không có nhiệm vụ nào để chạy trên đó ngoại trừ nhiệm vụ "nhàn rỗi" đặc biệt được liên kết
với nó, có cơ hội tiết kiệm năng lượng cho bộ xử lý mà nó
thuộc về.  Điều đó có thể được thực hiện bằng cách làm cho CPU logic nhàn rỗi ngừng tìm nạp
hướng dẫn từ bộ nhớ và đặt một số đơn vị chức năng của bộ xử lý
bị phụ thuộc vào nó, rơi vào trạng thái không hoạt động và sẽ tiêu thụ ít năng lượng hơn.

Tuy nhiên, có thể có nhiều trạng thái rỗi khác nhau có thể được sử dụng trong một
về nguyên tắc, vì vậy có thể cần phải tìm ra một tình huống phù hợp nhất
(từ phối cảnh hạt nhân) và yêu cầu bộ xử lý sử dụng (hoặc "nhập") thông tin đó
trạng thái nhàn rỗi cụ thể.  Đó chính là vai trò của việc quản lý thời gian nhàn rỗi của CPU
hệ thống con trong kernel, được gọi là ZZ0000ZZ.

Thiết kế của ZZ0000ZZ là mô-đun và dựa trên việc tránh trùng lặp mã
nguyên tắc, do đó mã chung về nguyên tắc không cần phụ thuộc vào phần cứng
hoặc chi tiết thiết kế nền tảng trong đó tách biệt với mã tương tác với
phần cứng.  Nó thường được chia thành ba loại chức năng
đơn vị: ZZ0001ZZ chịu trách nhiệm chọn trạng thái nhàn rỗi để yêu cầu bộ xử lý
để tham gia, ZZ0002ZZ chuyển các quyết định của thống đốc tới phần cứng và
ZZ0003ZZ cung cấp một khuôn khổ chung cho chúng.


CPU Bộ điều chỉnh thời gian nhàn rỗi
=======================

Bộ điều chỉnh thời gian nhàn rỗi CPU (ZZ0000ZZ) là một gói mã chính sách được gọi khi
một trong những CPU logic trong hệ thống không hoạt động.  Vai trò của nó là
chọn trạng thái không hoạt động để yêu cầu bộ xử lý nhập vào nhằm tiết kiệm năng lượng.

Bộ điều chỉnh ZZ0000ZZ là chung và mỗi bộ điều chỉnh có thể được sử dụng trên mọi phần cứng
nền tảng mà nhân Linux có thể chạy trên đó.  Vì lý do này, cấu trúc dữ liệu
được vận hành bởi chúng không thể phụ thuộc vào bất kỳ kiến trúc hoặc nền tảng phần cứng nào
chi tiết thiết kế là tốt.

Bản thân bộ điều chỉnh được đại diện bởi một đối tượng struct cpuidle_governor
chứa bốn con trỏ gọi lại, ZZ0000ZZ, ZZ0001ZZ,
ZZ0002ZZ, ZZ0003ZZ, trường ZZ0004ZZ được mô tả
bên dưới và tên (chuỗi) được sử dụng để xác định nó.

Để thống đốc có mặt ở tất cả, đối tượng đó cần phải được đăng ký
với lõi ZZ0002ZZ bằng cách gọi ZZ0000ZZ bằng
một con trỏ tới nó được chuyển làm đối số.  Nếu thành công, điều đó khiến lõi
thêm thống đốc vào danh sách toàn cầu của các thống đốc có sẵn và, nếu đó là
chỉ một trong danh sách (nghĩa là danh sách trống trước đó) hoặc giá trị của nó
Trường ZZ0001ZZ lớn hơn giá trị của trường đó đối với
Thống đốc hiện đang được sử dụng, hoặc tên của Thống đốc mới đã được chuyển cho
kernel làm giá trị của tham số dòng lệnh ZZ0003ZZ, cái mới
bộ điều tốc sẽ được sử dụng kể từ thời điểm đó (chỉ có thể có một ZZ0004ZZ
thống đốc được sử dụng tại một thời điểm).  Ngoài ra, không gian người dùng có thể chọn ZZ0005ZZ
thống đốc để sử dụng trong thời gian chạy thông qua ZZ0006ZZ.

Sau khi đã đăng ký, bộ điều chỉnh ZZ0000ZZ không thể hủy đăng ký, vì vậy nó không phải là
thực tế để đưa chúng vào các mô-đun hạt nhân có thể tải được.

Giao diện giữa bộ điều chỉnh ZZ0000ZZ và lõi bao gồm bốn
gọi lại:

ZZ0000ZZ
	::

int (*enable) (struct cpuidle_driver *drv, struct cpuidle_device *dev);

Vai trò của lệnh gọi lại này là chuẩn bị cho bộ điều chỉnh xử lý
	(logic) CPU được biểu thị bằng đối tượng struct cpuidle_device nhọn
	bằng đối số ZZ0000ZZ.  Đối tượng struct cpuidle_driver nhọn
	tới đối số ZZ0001ZZ đại diện cho trình điều khiển ZZ0002ZZ sẽ được sử dụng
	với CPU đó (trong số những thứ khác, nó phải chứa danh sách
	Các đối tượng struct cpuidle_state đại diện cho trạng thái nhàn rỗi mà
	bộ xử lý đang giữ CPU đã cho có thể được yêu cầu nhập).

Nó có thể thất bại, trong trường hợp đó dự kiến sẽ trả về lỗi âm
	mã và điều đó làm cho kernel chạy cấu trúc cụ thể
	mã mặc định cho các CPU nhàn rỗi trên CPU được đề cập thay vì ZZ0000ZZ
	cho đến khi lệnh gọi lại bộ điều chỉnh ZZ0001ZZ được gọi cho CPU đó
	một lần nữa.

ZZ0000ZZ
	::

khoảng trống (*disable) (struct cpuidle_driver *drv, struct cpuidle_device *dev);

Được kêu gọi yêu cầu thống đốc ngừng xử lý CPU (hợp lý) được đại diện
	bởi đối tượng struct cpuidle_device được trỏ bởi ZZ0000ZZ
	lý lẽ.

Dự kiến ​​sẽ đảo ngược mọi thay đổi được thực hiện bởi ZZ0000ZZ
	gọi lại khi nó được gọi lần cuối cho CPU mục tiêu, giải phóng tất cả bộ nhớ
	được phân bổ bởi cuộc gọi lại đó, v.v.

ZZ0000ZZ
	::

int (*select) (struct cpuidle_driver *drv, struct cpuidle_device *dev,
	                 bool *stop_tick);

Được gọi để chọn trạng thái rảnh cho bộ xử lý đang giữ (logic)
	CPU được đại diện bởi đối tượng struct cpuidle_device được trỏ tới bởi
	Đối số ZZ0000ZZ.

Danh sách các trạng thái rảnh rỗi cần xem xét được biểu thị bằng
	Mảng ZZ0000ZZ của các đối tượng struct cpuidle_state được giữ bởi
	đối tượng struct cpuidle_driver được trỏ đến bởi đối số ZZ0001ZZ (mà
	đại diện cho trình điều khiển ZZ0002ZZ sẽ được sử dụng cùng với CPU).  các
	giá trị được trả về bởi lệnh gọi lại này được hiểu là một chỉ mục trong đó
	mảng (trừ khi đó là mã lỗi âm).

Đối số ZZ0000ZZ được sử dụng để cho biết có nên dừng hay không
	đánh dấu bộ lập lịch trước khi yêu cầu bộ xử lý nhập dữ liệu đã chọn
	trạng thái nhàn rỗi.  Khi biến ZZ0001ZZ được nó trỏ đến (được đặt
	tới ZZ0002ZZ trước khi gọi lại lệnh gọi lại này) được xóa thành ZZ0003ZZ,
	bộ xử lý sẽ được yêu cầu chuyển sang trạng thái không hoạt động đã chọn mà không
	dừng đánh dấu bộ lập lịch trên CPU đã cho (nếu đánh dấu đã được
	đã dừng trên CPU đó rồi, tuy nhiên, nó sẽ không được khởi động lại trước đó
	yêu cầu bộ xử lý chuyển sang trạng thái không hoạt động).

Lệnh gọi lại này là bắt buộc (tức là con trỏ gọi lại ZZ0000ZZ
	trong struct cpuidle_governor không được là ZZ0001ZZ để đăng ký
	của thống đốc để thành công).

ZZ0000ZZ
	::

khoảng trống (*reflect) (struct cpuidle_device *dev, chỉ mục int);

Được kêu gọi để cho phép thống đốc đánh giá tính chính xác của trạng thái nhàn rỗi
	lựa chọn được thực hiện bởi lệnh gọi lại ZZ0000ZZ (khi nó được gọi lần cuối
	time) và có thể sử dụng kết quả đó để cải thiện độ chính xác của
	lựa chọn trạng thái nhàn rỗi trong tương lai.

Ngoài ra, bộ điều tốc ZZ0002ZZ được yêu cầu quản lý năng lượng
hạn chế về chất lượng dịch vụ (PM QoS) đối với độ trễ đánh thức bộ xử lý thành
tài khoản khi chọn trạng thái nhàn rỗi.  Để có được hiệu quả hiện tại
Giới hạn độ trễ đánh thức PM QoS cho CPU nhất định, bộ điều chỉnh ZZ0003ZZ là
dự kiến sẽ chuyển số CPU cho
ZZ0000ZZ.  Sau đó, ZZ0004ZZ của thống đốc
gọi lại không được trả về chỉ mục của trạng thái indle có
Giá trị ZZ0001ZZ lớn hơn số được trả về
chức năng.


Trình điều khiển quản lý thời gian nhàn rỗi CPU
================================

Trình điều khiển quản lý thời gian nhàn rỗi CPU (ZZ0000ZZ) cung cấp giao diện giữa
các bộ phận khác của ZZ0001ZZ và phần cứng.

Trước hết, trình điều khiển ZZ0001ZZ phải điền vào mảng ZZ0000ZZ
của các đối tượng struct cpuidle_state có trong đối tượng struct cpuidle_driver
đại diện cho nó.  Trong tương lai mảng này sẽ đại diện cho danh sách có sẵn
trạng thái nhàn rỗi rằng phần cứng bộ xử lý có thể được yêu cầu nhập vào được chia sẻ bởi tất cả
các CPU logic được xử lý bởi trình điều khiển nhất định.

Các mục trong mảng ZZ0000ZZ dự kiến sẽ được sắp xếp theo
giá trị của trường ZZ0001ZZ trong cấu trúc cpuidle_state trong
thứ tự tăng dần (nghĩa là chỉ số 0 phải tương ứng với trạng thái không hoạt động với
giá trị tối thiểu của ZZ0002ZZ).  [Kể từ khi
Giá trị ZZ0003ZZ được kỳ vọng sẽ phản ánh "độ sâu" của
trạng thái nhàn rỗi được biểu thị bằng đối tượng struct cpuidle_state đang giữ nó, trạng thái này
thứ tự sắp xếp phải giống với thứ tự sắp xếp tăng dần theo thời gian rảnh
trạng thái "độ sâu".]

Ba trường trong struct cpuidle_state được ZZ0000ZZ hiện có sử dụng
bộ điều chỉnh cho các tính toán liên quan đến việc lựa chọn trạng thái nhàn rỗi:

ZZ0000ZZ
	Thời gian tối thiểu để ở trạng thái nhàn rỗi này bao gồm cả thời gian cần thiết để
	nhập nó (có thể là đáng kể) để tiết kiệm nhiều năng lượng hơn mức có thể
	được cứu bằng cách ở trong trạng thái nhàn rỗi nông hơn trong cùng một lượng thời gian
	thời gian, tính bằng micro giây.

ZZ0000ZZ
	Thời gian tối đa để CPU yêu cầu bộ xử lý chuyển sang trạng thái rảnh này
	trạng thái bắt đầu thực hiện lệnh đầu tiên sau khi thức dậy từ lệnh đó,
	tính bằng micro giây.

ZZ0000ZZ
	Cờ đại diện cho các thuộc tính trạng thái nhàn rỗi.  Hiện nay các thống đốc chỉ sử dụng
	cờ ZZ0001ZZ được đặt nếu đối tượng đã cho
	không đại diện cho trạng thái nhàn rỗi thực sự mà là giao diện của phần mềm
	"vòng lặp" có thể được sử dụng để tránh yêu cầu bộ xử lý nhập
	bất kỳ trạng thái nhàn rỗi nào cả.  [Có những cờ khác được ZZ0002ZZ sử dụng
	cốt lõi trong những tình huống đặc biệt.]

Con trỏ gọi lại ZZ0000ZZ trong cấu trúc cpuidle_state, không được phép
là ZZ0001ZZ, trỏ đến thủ tục cần thực thi để yêu cầu bộ xử lý
nhập trạng thái nhàn rỗi cụ thể này:

::

khoảng trống (*enter) (struct cpuidle_device *dev, struct cpuidle_driver *drv,
                 chỉ số int);

Hai đối số đầu tiên của nó trỏ đến đối tượng struct cpuidle_device
đại diện cho CPU logic đang chạy lệnh gọi lại này và
Đối tượng struct cpuidle_driver tương ứng đại diện cho chính trình điều khiển,
và cái cuối cùng là chỉ mục của mục struct cpuidle_state trong trình điều khiển
Mảng ZZ0000ZZ biểu thị trạng thái không hoạt động để yêu cầu bộ xử lý
đi vào.

Lệnh gọi lại ZZ0000ZZ tương tự trong struct cpuidle_state được sử dụng
chỉ để triển khai tính năng quản lý năng lượng trên toàn hệ thống từ trạng thái tạm dừng đến không hoạt động.
Sự khác biệt giữa in và ZZ0001ZZ là nó không được kích hoạt lại
ngắt tại bất kỳ thời điểm nào (thậm chí tạm thời) hoặc cố gắng thay đổi trạng thái của
thiết bị sự kiện đồng hồ, đôi khi lệnh gọi lại ZZ0002ZZ có thể thực hiện.

Khi mảng ZZ0000ZZ đã được điền, số lượng hợp lệ
các mục trong đó phải được lưu trữ trong trường ZZ0001ZZ của
đối tượng struct cpuidle_driver đại diện cho trình điều khiển.  Hơn nữa, nếu có
các mục trong mảng ZZ0002ZZ biểu thị trạng thái nhàn rỗi "được ghép nối" (đó
là trạng thái nhàn rỗi chỉ có thể được yêu cầu nếu có nhiều CPU logic liên quan
nhàn rỗi), trường ZZ0003ZZ trong struct cpuidle_driver cần
là chỉ số của trạng thái rảnh không được "kết hợp" (nghĩa là trạng thái có thể
được yêu cầu nếu chỉ có một CPU logic không hoạt động).

Ngoài ra, nếu trình điều khiển ZZ0001ZZ đã cho chỉ xử lý một
tập hợp con của các CPU logic trong hệ thống, trường ZZ0000ZZ trong
Đối tượng struct cpuidle_driver phải trỏ tới tập hợp (mặt nạ) CPU sẽ được
được nó xử lý.

Trình điều khiển ZZ0003ZZ chỉ có thể được sử dụng sau khi đã được đăng ký.  Nếu có
không có mục nhập trạng thái nhàn rỗi "được ghép nối" nào trong mảng ZZ0000ZZ của trình điều khiển,
điều đó có thể được thực hiện bằng cách truyền đối tượng struct cpuidle_driver của trình điều khiển
tới ZZ0001ZZ.  Nếu không thì ZZ0002ZZ
nên được sử dụng cho mục đích này.

Tuy nhiên, cũng cần phải đăng ký các đối tượng struct cpuidle_device cho
tất cả các CPU logic được xử lý bởi trình điều khiển ZZ0005ZZ nhất định với
trợ giúp của ZZ0000ZZ sau khi đã đăng ký driver
và ZZ0001ZZ, không giống như ZZ0002ZZ,
không làm điều đó một cách tự động.  Vì lý do này, các trình điều khiển sử dụng
ZZ0003ZZ tự đăng ký cũng phải cẩn thận
đăng ký các đối tượng struct cpuidle_device khi cần thiết, vì vậy nói chung là
khuyến nghị sử dụng ZZ0004ZZ cho trình điều khiển ZZ0006ZZ
đăng ký trong mọi trường hợp.

Việc đăng ký đối tượng struct cpuidle_device gây ra ZZ0000ZZ
Giao diện ZZ0001ZZ sẽ được tạo và lệnh gọi lại ZZ0002ZZ của thống đốc tới
được gọi cho CPU logic được đại diện bởi nó, vì vậy nó phải diễn ra sau
đăng ký trình điều khiển sẽ xử lý CPU được đề cập.

Trình điều khiển ZZ0003ZZ và các đối tượng struct cpuidle_device có thể bị hủy đăng ký
khi chúng không còn cần thiết nữa, điều này cho phép một số tài nguyên được liên kết với
chúng sẽ được thả ra.  Do sự phụ thuộc giữa chúng, tất cả
struct cpuidle_device đối tượng đại diện cho CPU được xử lý bởi cái đã cho
Trình điều khiển ZZ0004ZZ phải chưa được đăng ký, với sự trợ giúp của
ZZ0000ZZ, trước khi gọi
ZZ0001ZZ để hủy đăng ký trình điều khiển.  Ngoài ra,
ZZ0002ZZ có thể được gọi để hủy đăng ký trình điều khiển ZZ0005ZZ
cùng với tất cả các đối tượng struct cpuidle_device đại diện cho CPU được xử lý
bởi nó.

Trình điều khiển ZZ0005ZZ có thể đáp ứng các thay đổi về cấu hình hệ thống thời gian chạy
dẫn đến sửa đổi danh sách trạng thái nhàn rỗi của bộ xử lý có sẵn (có thể
xảy ra, ví dụ: khi nguồn điện của hệ thống được chuyển từ AC sang
pin hoặc ngược lại).  Khi được thông báo về sự thay đổi như vậy,
trình điều khiển ZZ0006ZZ dự kiến sẽ gọi ZZ0000ZZ để
tạm thời tắt ZZ0007ZZ rồi tắt ZZ0001ZZ
tất cả các đối tượng struct cpuidle_device đại diện cho CPU bị ảnh hưởng bởi điều đó
thay đổi.  Tiếp theo, nó có thể cập nhật mảng ZZ0002ZZ theo
cấu hình mới của hệ thống, hãy gọi ZZ0003ZZ để biết
tất cả các đối tượng struct cpuidle_device có liên quan và gọi
ZZ0004ZZ để cho phép ZZ0008ZZ được sử dụng lại.