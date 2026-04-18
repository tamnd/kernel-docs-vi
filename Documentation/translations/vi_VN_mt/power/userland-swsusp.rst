.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/power/userland-swsusp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================================================
Tài liệu về giao diện treo phần mềm userland
==========================================================

(C) 2006 Rafael J. Wysocki <rjw@sisk.pl>

Đầu tiên, những cảnh báo ở đầu swsusp.txt vẫn được áp dụng.

Thứ hai, bạn nên đọc FAQ trong swsusp.txt _now_ nếu chưa
đã làm được rồi.

Bây giờ, để sử dụng giao diện người dùng cho việc tạm dừng phần mềm, bạn cần có đặc biệt
các tiện ích sẽ đọc/ghi ảnh chụp nhanh bộ nhớ hệ thống từ/đến
hạt nhân.  Những tiện ích như vậy có sẵn, ví dụ, từ
<ZZ0000ZZ Bạn có thể muốn xem qua chúng nếu bạn
sẽ phát triển các tiện ích tạm dừng/tiếp tục của riêng bạn.

Giao diện bao gồm một thiết bị ký tự cung cấp open(),
các hoạt động Release(), read() và write() cũng như một số ioctl()
các lệnh được xác định trong include/linux/suspend_ioctls.h .  Chính và phụ
số của thiết bị lần lượt là 10 và 231 và chúng có thể
được đọc từ /sys/class/misc/snapshot/dev.

Thiết bị có thể được mở để đọc hoặc để viết.  Nếu mở cho
đọc, nó được coi là ở chế độ tạm dừng.  Nếu không thì nó là
được cho là đang ở chế độ tiếp tục.  Thiết bị không thể mở đồng thời
đọc và viết.  Cũng không thể mở thiết bị nhiều hơn
một lần một lần.

Ngay cả việc mở thiết bị cũng có tác dụng phụ. Cấu trúc dữ liệu được
được phân bổ và chuỗi PM_HIBERNATION_PREPARE / PM_RESTORE_PREPARE được
được gọi.

Các lệnh ioctl() được thiết bị nhận dạng là:

SNAPSHOT_FREEZE
	đóng băng các quy trình không gian người dùng (quy trình hiện tại là
	không bị đông lạnh); điều này là bắt buộc đối với SNAPSHOT_CREATE_IMAGE
	và SNAPSHOT_ATOMIC_RESTORE để thành công

SNAPSHOT_UNFREEZE
	làm tan băng các quy trình không gian người dùng bị đóng băng bởi SNAPSHOT_FREEZE

SNAPSHOT_CREATE_IMAGE
	tạo ảnh chụp nhanh bộ nhớ hệ thống; cái
	đối số cuối cùng của ioctl() phải là một con trỏ tới biến int,
	giá trị của nó sẽ cho biết liệu cuộc gọi có được trả lại sau
	tạo ảnh chụp nhanh (1) hoặc sau khi khôi phục trạng thái bộ nhớ hệ thống
	từ nó (0) (sau khi tiếp tục, hệ thống sẽ tự kết thúc
	SNAPSHOT_CREATE_IMAGE ioctl() nữa); sau ảnh chụp nhanh
	đã được tạo, thao tác read() có thể được sử dụng để chuyển
	nó ra khỏi kernel

SNAPSHOT_ATOMIC_RESTORE
	khôi phục trạng thái bộ nhớ hệ thống từ
	hình ảnh chụp nhanh đã tải lên; trước khi gọi nó bạn nên chuyển
	ảnh chụp nhanh bộ nhớ hệ thống trở lại kernel bằng cách sử dụng write()
	hoạt động; cuộc gọi này sẽ không thành công nếu ảnh chụp nhanh
	hình ảnh không có sẵn cho kernel

SNAPSHOT_FREE
	bộ nhớ trống được phân bổ cho ảnh chụp nhanh

SNAPSHOT_PREF_IMAGE_SIZE
	đặt kích thước tối đa ưa thích của hình ảnh
	(kernel sẽ cố gắng hết sức để đảm bảo kích thước hình ảnh không vượt quá
	con số này, nhưng nếu nó không thể thực hiện được thì kernel sẽ
	tạo hình ảnh nhỏ nhất có thể)

SNAPSHOT_GET_IMAGE_SIZE
	trả về kích thước thực tế của hình ảnh ngủ đông
	(đối số cuối cùng phải là một con trỏ tới biến loff_t
	sẽ chứa kết quả nếu cuộc gọi thành công)

SNAPSHOT_AVAIL_SWAP_SIZE
	trả về số lượng trao đổi có sẵn tính bằng byte
	(đối số cuối cùng phải là một con trỏ tới biến loff_t
	sẽ chứa kết quả nếu cuộc gọi thành công)

SNAPSHOT_ALLOC_SWAP_PAGE
	phân bổ một trang trao đổi từ phân vùng sơ yếu lý lịch
	(đối số cuối cùng phải là một con trỏ tới biến loff_t
	sẽ chứa phần bù trang trao đổi nếu cuộc gọi thành công)

SNAPSHOT_FREE_SWAP_PAGES
	giải phóng tất cả các trang trao đổi được phân bổ bởi
	SNAPSHOT_ALLOC_SWAP_PAGE

SNAPSHOT_SET_SWAP_AREA
	thiết lập phân vùng tiếp tục và phần bù (trong <PAGE_SIZE>
	đơn vị) từ đầu phân vùng nơi tiêu đề trao đổi được đặt
	được định vị (đối số ioctl() cuối cùng sẽ trỏ đến một cấu trúc
	sơ yếu lý lịch_swap_area, như được định nghĩa trong kernel/power/suspend_ioctls.h,
	chứa thông số kỹ thuật của thiết bị sơ yếu lý lịch và phần bù); để trao đổi
	phân vùng, offset luôn bằng 0, nhưng nó khác 0 đối với
	trao đổi tập tin (xem Documentation/power/swsusp-and-swap-files.rst để biết
	chi tiết).

SNAPSHOT_PLATFORM_SUPPORT
	bật/tắt hỗ trợ nền tảng ngủ đông,
	tùy thuộc vào giá trị đối số (bật, nếu đối số khác 0)

SNAPSHOT_POWER_OFF
	làm cho kernel chuyển hệ thống sang chế độ ngủ đông
	trạng thái (ví dụ: ACPI S4) bằng trình điều khiển nền tảng (ví dụ: ACPI)

SNAPSHOT_S2RAM
	tạm dừng RAM; sử dụng lệnh gọi này khiến kernel
	ngay lập tức chuyển sang trạng thái tạm dừng đối với RAM, vì vậy lệnh gọi này phải luôn
	được bắt đầu bằng lệnh gọi SNAPSHOT_FREEZE và nó cũng cần thiết
	để sử dụng cuộc gọi SNAPSHOT_UNFREEZE sau khi hệ thống thức dậy.  Cuộc gọi này
	là cần thiết để thực hiện cơ chế tạm dừng cho cả hai trong đó
	hình ảnh đình chỉ được tạo lần đầu tiên, như thể hệ thống đã bị đình chỉ
	vào đĩa, sau đó hệ thống sẽ bị treo ở RAM (điều này giúp có thể thực hiện được
	để tiếp tục hệ thống từ RAM nếu có đủ pin hoặc khôi phục
	trạng thái của nó trên cơ sở hình ảnh treo đã lưu nếu không)

Thao tác read() của thiết bị có thể được sử dụng để truyền ảnh chụp nhanh từ
hạt nhân.  Nó có những hạn chế sau:

- bạn không thể đọc() nhiều trang bộ nhớ ảo cùng một lúc
- không thể đọc() trên các ranh giới trang (tức là nếu bạn đọc() 1/2 của
  một trang trong cuộc gọi trước, bạn sẽ chỉ có thể đọc()
  ZZ0000ZZ 1/2 trang trong cuộc gọi tiếp theo)

Thao tác write() của thiết bị được sử dụng để tải lên ảnh chụp nhanh bộ nhớ hệ thống
vào hạt nhân.  Nó có những hạn chế tương tự như thao tác read().

Hoạt động phát hành () giải phóng tất cả bộ nhớ được phân bổ cho ảnh chụp nhanh
và tất cả các trang trao đổi được phân bổ bằng SNAPSHOT_ALLOC_SWAP_PAGE (nếu có).
Vì vậy không cần thiết phải sử dụng SNAPSHOT_FREE hoặc
SNAPSHOT_FREE_SWAP_PAGES trước khi đóng thiết bị (trên thực tế nó cũng sẽ
giải phóng các quy trình không gian người dùng bị đóng băng bởi SNAPSHOT_UNFREEZE nếu chúng
vẫn bị treo khi đóng thiết bị).

Hiện tại người ta giả định rằng các tiện ích của người dùng đang đọc/ghi
Ảnh chụp nhanh từ/đến kernel sẽ sử dụng một phân vùng trao đổi, được gọi là sơ yếu lý lịch
phân vùng hoặc tệp hoán đổi làm không gian lưu trữ (nếu sử dụng tệp hoán đổi, sơ yếu lý lịch sẽ
phân vùng là phân vùng chứa tệp này).  Tuy nhiên, đây thực sự không phải
được yêu cầu, vì họ có thể sử dụng, ví dụ, một phân vùng treo đặc biệt (trống) hoặc
một tệp trên phân vùng chưa được ngắt kết nối trước SNAPSHOT_CREATE_IMAGE và
được gắn sau đó.

Các tiện ích MUST NOT này đưa ra bất kỳ giả định nào liên quan đến thứ tự của
dữ liệu trong ảnh chụp nhanh.  Nội dung của hình ảnh hoàn toàn thuộc sở hữu
bởi kernel và cấu trúc của nó có thể được thay đổi trong các bản phát hành kernel trong tương lai.

Ảnh chụp nhanh MUST được ghi vào kernel mà không bị thay đổi gì (tức là tất cả ảnh
dữ liệu, siêu dữ liệu và tiêu đề MUST được ghi bằng _chính xác_ cùng số lượng, hình thức
và thứ tự đọc chúng).  Ngược lại, hành vi của
hệ thống được nối lại có thể hoàn toàn không thể đoán trước được.

Trong khi thực thi SNAPSHOT_ATOMIC_RESTORE, kernel sẽ kiểm tra xem
Cấu trúc của ảnh chụp phù hợp với thông tin được lưu trữ
trong tiêu đề hình ảnh.  Nếu phát hiện có sự không nhất quán,
SNAPSHOT_ATOMIC_RESTORE sẽ không thành công.  Tuy nhiên, đây không phải là một bằng chứng ngu ngốc
cơ chế và tiện ích vùng người dùng sử dụng giao diện SHOULD sử dụng bổ sung
các phương tiện, chẳng hạn như tổng kiểm tra, để đảm bảo tính toàn vẹn của ảnh chụp nhanh.

Các tiện ích tạm dừng và tiếp tục MUST tự khóa trong bộ nhớ,
tốt nhất là sử dụng mlockall(), trước khi gọi SNAPSHOT_FREEZE.

Tiện ích tạm dừng MUST kiểm tra giá trị được lưu trữ bởi SNAPSHOT_CREATE_IMAGE
ở vị trí bộ nhớ được trỏ bởi đối số cuối cùng của ioctl() và tiếp tục
theo nó:

1. Nếu giá trị là 1 (tức là ảnh chụp nhanh bộ nhớ hệ thống vừa được
	được tạo và hệ thống đã sẵn sàng để lưu nó):

(a) Tiện ích tạm dừng MUST NOT đóng thiết bị chụp nhanh
		_trừ khi_ toàn bộ thủ tục đình chỉ bị hủy bỏ, trong
		trong trường hợp đó, nếu ảnh chụp nhanh đã được lưu,
		đình chỉ tiện ích SHOULD phá hủy nó, tốt nhất là bằng cách hạ gục
		tiêu đề của nó.  Nếu việc đình chỉ không được hủy bỏ thì
		hệ thống MUST bị tắt nguồn hoặc khởi động lại sau khi chụp nhanh
		hình ảnh đã được lưu.
	(b) Tiện ích tạm dừng SHOULD NOT cố gắng thực hiện bất kỳ
		các hoạt động của hệ thống tệp (bao gồm cả các lần đọc) trên hệ thống tệp
		đã được gắn trước khi SNAPSHOT_CREATE_IMAGE được lắp đặt
		được gọi.  Tuy nhiên, MAY gắn một hệ thống tập tin không được
		được gắn vào thời điểm đó và thực hiện một số thao tác trên nó (ví dụ:
		sử dụng nó để lưu hình ảnh).

2. Nếu giá trị là 0 (tức là trạng thái hệ thống vừa được khôi phục từ
	ảnh chụp nhanh), tiện ích tạm dừng MUST đóng ảnh chụp nhanh
	thiết bị.  Sau đó, nó sẽ được coi như một quy trình người dùng thông thường,
	vì vậy nó không cần phải thoát ra.

Tiện ích tiếp tục SHOULD NOT cố gắng gắn kết bất kỳ hệ thống tệp nào có thể
được gắn trước khi tạm dừng và SHOULD NOT cố gắng thực hiện bất kỳ thao tác nào
liên quan đến các hệ thống tập tin như vậy.

Để biết chi tiết, vui lòng tham khảo mã nguồn.
