.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/dscr.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================================
DSCR (Thanh ghi điều khiển luồng dữ liệu)
===================================

Đăng ký DSCR trong powerpc cho phép người dùng có một số quyền kiểm soát việc tìm nạp trước dữ liệu
luồng trong bộ xử lý. Vui lòng tham khảo tài liệu ISA hoặc hướng dẫn sử dụng liên quan
để biết thêm thông tin chi tiết về cách sử dụng DSCR này để đạt được điều này
kiểm soát việc tìm nạp trước. Tài liệu này ở đây cung cấp một cái nhìn tổng quan về kernel
hỗ trợ cho DSCR, các đối tượng hạt nhân liên quan, các chức năng của nó và được xuất
giao diện người dùng.

(A) Cấu trúc dữ liệu:

(1) thread_struct::

dscr /* Giá trị DSCR của chủ đề */
		dscr_inherit /* Thread đã thay đổi DSCR mặc định */

(2) PACA::

dscr_default /* per-CPU DSCR giá trị mặc định */

(3) sysfs.c::

dscr_default /* Giá trị mặc định của hệ thống DSCR */

(B) Thay đổi lịch trình:

Bộ lập lịch sẽ ghi mặc định cho mỗi CPU DSCR được lưu trữ trong
	Giá trị PACA của CPU vào thanh ghi nếu luồng có giá trị dscr_inherit
	đã bị xóa, điều đó có nghĩa là cho đến nay nó vẫn chưa thay đổi DSCR mặc định.
	Nếu giá trị dscr_inherit được đặt có nghĩa là nó đã thay đổi
	giá trị DSCR mặc định, bộ lập lịch sẽ ghi giá trị đã thay đổi.
	bây giờ được chứa trong dscr của cấu trúc luồng vào sổ đăng ký thay vì
	giá trị DSCR mặc định trên mỗi CPU.

NOTE: Xin lưu ý ở đây rằng giá trị DSCR toàn cầu trên toàn hệ thống không bao giờ
	được sử dụng trực tiếp trong quá trình chuyển đổi ngữ cảnh của quy trình lập lịch trình.

(C) Giao diện SYSFS:

- Mặc định DSCR toàn cầu: /sys/devices/system/cpu/dscr_default
	- CPU mặc định DSCR cụ thể: /sys/devices/system/cpu/cpuN/dscr

Thay đổi mặc định DSCR toàn cầu trong sysfs sẽ thay đổi tất cả CPU
	DSCR cụ thể được mặc định ngay lập tức trong cấu trúc PACA của chúng. Một lần nữa nếu
	quy trình hiện tại có dscr_inherit rõ ràng, nó cũng ghi mới
	giá trị vào sổ đăng ký DSCR của mọi CPU ngay lập tức và cập nhật giá trị hiện tại
	giá trị DSCR của luồng.

Việc thay đổi giá trị mặc định DSCR cụ thể của CPU trong sysfs thực hiện chính xác
	điều tương tự như trên nhưng không giống như toàn cầu ở trên, nó chỉ thay đổi
	nội dung dành cho CPU cụ thể đó thay vì cho tất cả các CPU trên hệ thống.

(D) Hướng dẫn về không gian người dùng:

Thanh ghi DSCR có thể được truy cập trong không gian người dùng bằng bất kỳ cách nào trong số này
	hai số SPR có sẵn cho mục đích đó.

(1) Trạng thái sự cố SPR: 0x03 (Không có đặc quyền, chỉ POWER8)
	(2) Trạng thái đặc quyền SPR: 0x11 (Đặc quyền)

Truy cập DSCR thông qua số SPR đặc quyền (0x11) từ không gian người dùng
	hoạt động, vì nó được mô phỏng theo một ngoại lệ hướng dẫn bất hợp pháp
	bên trong hạt nhân. Cả hai lệnh mfspr và mtspr đều được mô phỏng.

Việc truy cập DSCR thông qua cấp độ người dùng SPR (0x03) từ không gian người dùng trước tiên sẽ
	tạo một ngoại lệ cơ sở không có sẵn. Bên trong trình xử lý ngoại lệ này
	tất cả các lần đọc dựa trên lệnh mfspr sẽ được mô phỏng và trả về
	trong đó lần thử ghi dựa trên lệnh mtspr đầu tiên sẽ cho phép
	cơ sở DSCR cho lần tiếp theo (cả để đọc và ghi) bởi
	thiết lập cơ sở DSCR trong thanh ghi FSCR.

(E) Thông tin cụ thể về 'dscr_inherit':

Phần tử cấu trúc luồng 'dscr_inherit' thể hiện liệu luồng có
	được đề cập đã thử và thay đổi chính DSCR bằng cách sử dụng bất kỳ
	các phương pháp sau đây. Phần tử này biểu thị liệu luồng có muốn
	sử dụng giá trị DSCR mặc định của CPU hoặc giá trị DSCR đã thay đổi của chính nó trong
	hạt nhân.

(1) lệnh mtspr (SPR số 0x03)
		(2) lệnh mtspr (SPR số 0x11)
		(3) giao diện ptrace (Đặt rõ ràng giá trị DSCR của người dùng)

Bất kỳ tiến trình con nào được tạo sau sự kiện này trong tiến trình đều kế thừa
	hành vi tương tự này là tốt.
