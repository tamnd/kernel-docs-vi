.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/abituguru.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân abituguru
=======================

Chip được hỗ trợ:

* Abit uGuru bản sửa đổi 1 & 2 (Chỉ phần Giám sát phần cứng)

Tiền tố: 'abituguru'

Địa chỉ được quét: ISA 0x0E0

Bảng dữ liệu: Không có sẵn, trình điều khiển này dựa trên kỹ thuật đảo ngược.
    Một "Bảng dữ liệu" đã được viết dựa trên kỹ thuật đảo ngược nó
    phải có sẵn trong cùng thư mục với tệp này dưới tên
    bảng dữ liệu abituguru.

Lưu ý:
	uGuru là một bộ vi điều khiển có phần sụn tích hợp để lập trình
	nó hoạt động như một IC hwmon. Có rất nhiều phiên bản khác nhau của
	phần sụn và do đó có nhiều phiên bản khác nhau của uGuru.
	Dưới đây là danh sách không đầy đủ các bản sửa đổi được sử dụng cho những mục nào
	Bo mạch chủ:

- uGuru 1,00 ~ 1,24 (AI7, KV8-MAX3, AN7) [1]_
	- uGuru 2.0.0.0 ~ 2.0.4.2 (KV8-PRO)
	- uGuru 2.1.0.0 ~ 2.1.2.8 (AS8, AV8, AA8, AG8, AA8XE, AX8)
	- uGuru 2.2.0.0 ~ 2.2.0.6 (AA8 Fatal1ty)
	- uGuru 2.3.0.0 ~ 2.3.0.9 (AN8)
	- uGuru 3.0.0.0 ~ 3.0.x.x (AW8, AL8, AT8, NI8 SLI, AT8 32X, AN8 32X,
	  AW9D-MAX) [2]_

.. [1]  For revisions 2 and 3 uGuru's the driver can autodetect the
	sensortype (Volt or Temp) for bank1 sensors, for revision 1 uGuru's
	this does not always work. For these uGuru's the autodetection can
	be overridden with the bank1_types module param. For all 3 known
	revision 1 motherboards the correct use of this param is:
	bank1_types=1,1,0,0,0,0,0,2,0,0,0,0,2,0,0,1
	You may also need to specify the fan_sensors option for these boards
	fan_sensors=5

.. [2]  There is a separate abituguru3 driver for these motherboards,
	the abituguru (without the 3 !) driver will not work on these
	motherboards (and vice versa)!

tác giả:
	- Hans de Goede <j.w.r.degoede@hhs.nl>,
	- (Kỹ thuật đảo ngược ban đầu được thực hiện bởi Olle Sandberg
	  <ollebull@gmail.com>)


Thông số mô-đun
-----------------

* lực: bool
			Phát hiện lực lượng. Lưu ý tham số này chỉ gây ra
			việc phát hiện sẽ bị bỏ qua, và do đó cần phải
			thành công. Nếu uGuru không thể đọc được hwmon thực tế
			trình điều khiển sẽ không tải và do đó sẽ không có thiết bị hwmon nào nhận được
			đã đăng ký.
* ngân hàng1_types: int[]
			Ghi đè tự động phát hiện loại cảm biến Bank1:

* -1 tự động phát hiện (mặc định)
			  * Cảm biến 0 vôn
			  * 1 cảm biến nhiệt độ
			  * 2 không được kết nối
* fan_sensors: int
			Cho tài xế biết có bao nhiêu cảm biến tốc độ quạt
			trên bo mạch chủ của bạn. Mặc định: 0 (tự động phát hiện).
* pwms: int
			Nói cho người lái xe biết có bao nhiêu điều khiển tốc độ quạt (quạt
			pwms) bo mạch chủ của bạn có. Mặc định: 0 (tự động phát hiện).
* dài dòng: int
			Người lái xe nên dài dòng như thế nào? (0-3):

* 0 đầu ra bình thường
			   * 1 + báo cáo lỗi dài dòng
			   * 2 + thông tin thăm dò loại cảm biến (mặc định)
			   * 3 + báo cáo lỗi có thể thử lại

Mặc định: 2 (trình điều khiển vẫn đang trong giai đoạn thử nghiệm)

Lưu ý: nếu bạn cần bất kỳ tùy chọn nào trong ba tùy chọn đầu tiên ở trên, vui lòng nhập
trình điều khiển có chi tiết được đặt thành 3 và gửi thư cho tôi <j.w.r.degoede@hhs.nl> đầu ra của:
dmesg | grep abituguru


Sự miêu tả
-----------

Trình điều khiển này hỗ trợ các tính năng giám sát phần cứng đầu tiên và
bản sửa đổi thứ hai của chip Abit uGuru được tìm thấy trên Abit uGuru có tính năng
bo mạch chủ (hầu hết các bo mạch chủ Abit hiện đại).

Bản sửa đổi đầu tiên và thứ hai của chip uGuru trên thực tế là Winbond
W83L950D cải trang (mặc dù Abit khẳng định đây là "bộ vi xử lý mới"
được thiết kế bởi Kỹ sư ABIT"). Thật không may, điều này không giúp ích gì vì
W83L950D là một bộ vi điều khiển chung có ứng dụng Abit tùy chỉnh đang chạy
trên đó.

Mặc dù Abit không tiết lộ bất kỳ thông tin nào liên quan đến uGuru, Olle
Sandberg <ollebull@gmail.com> đã tìm cách đảo ngược phần cảm biến
của uGuru. Nếu không có công việc của anh ấy, người lái xe này sẽ không thể thực hiện được.

Sự cố đã biết
------------

Các bộ phận điều khiển điện áp và tần số của Abit uGuru không được hỗ trợ.

.. toctree::
   :maxdepth: 1

   abituguru-datasheet.rst
