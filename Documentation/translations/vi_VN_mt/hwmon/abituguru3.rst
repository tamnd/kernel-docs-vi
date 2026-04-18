.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/abituguru3.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân abituguru3
========================

Chip được hỗ trợ:
  * Abit uGuru phiên bản 3 (Phần giám sát phần cứng, chỉ đọc)

Tiền tố: 'abituguru3'

Địa chỉ được quét: ISA 0x0E0

Bảng dữ liệu: Không có sẵn, trình điều khiển này dựa trên kỹ thuật đảo ngược.

Lưu ý:
	uGuru là một bộ vi điều khiển có phần sụn tích hợp để lập trình
	nó hoạt động như một IC hwmon. Có rất nhiều phiên bản khác nhau của
	phần sụn và do đó có nhiều phiên bản khác nhau của uGuru.
	Dưới đây là danh sách không đầy đủ các bản sửa đổi được sử dụng cho những mục nào
	Bo mạch chủ:

- uGuru 1,00 ~ 1,24 (AI7, KV8-MAX3, AN7)
	- uGuru 2.0.0.0 ~ 2.0.4.2 (KV8-PRO)
	- uGuru 2.1.0.0 ~ 2.1.2.8 (AS8, AV8, AA8, AG8, AA8XE, AX8)
	- uGuru 2.3.0.0 ~ 2.3.0.9 (AN8)
	- uGuru 3.0.0.0 ~ 3.0.x.x (AW8, AL8, AT8, NI8 SLI, AT8 32X, AN8 32X,
	  AW9D-MAX)

Trình điều khiển abituguru3 chỉ dành cho bo mạch chủ phiên bản 3.0.x.x,
	trình điều khiển này sẽ không hoạt động trên các bo mạch chủ cũ hơn. Dành cho người lớn tuổi
	bo mạch chủ sử dụng trình điều khiển abituguru (không có 3!).

tác giả:
	- Hans de Goede <j.w.r.degoede@hhs.nl>,
	- (Kỹ thuật đảo ngược ban đầu được thực hiện bởi Louis Kruger)


Thông số mô-đun
-----------------

* lực: bool
			Phát hiện lực lượng. Lưu ý tham số này chỉ gây ra
			việc phát hiện sẽ bị bỏ qua, và do đó cần phải
			thành công. Nếu uGuru không thể đọc được hwmon thực tế
			trình điều khiển sẽ không tải và do đó sẽ không có thiết bị hwmon nào nhận được
			đã đăng ký.
* dài dòng: bool
			Người lái xe có nên dài dòng không?

* 0/tắt/đầu ra bình thường sai
			* 1/on/true + báo cáo lỗi dài dòng (mặc định)

Mặc định: 1 (trình điều khiển vẫn đang trong giai đoạn thử nghiệm)

Sự miêu tả
-----------

Trình điều khiển này hỗ trợ các tính năng giám sát phần cứng của phiên bản thứ ba của
chip Abit uGuru, được tìm thấy trên các bo mạch chủ Abit uGuru gần đây.

Phiên bản thứ 3 của chip uGuru trên thực tế là Winbond W83L951G.
Thật không may, điều này không giúp ích gì vì W83L951G là một bộ vi điều khiển chung
với một ứng dụng Abit tùy chỉnh đang chạy trên đó.

Mặc dù Abit không tiết lộ bất kỳ thông tin nào liên quan đến phiên bản uGuru 3,
Louis Kruger đã tìm cách đảo ngược phần cảm biến của uGuru.
Nếu không có công việc của anh ấy, người lái xe này sẽ không thể thực hiện được.

Sự cố đã biết
------------

Các bộ phận điều khiển điện áp và tần số của Abit uGuru không được hỗ trợ,
cũng không ghi bất kỳ cài đặt cảm biến nào và ghi/đọc
thanh ghi điều khiển tốc độ quạt (FanEQ)

Nếu bạn gặp bất kỳ vấn đề nào, vui lòng gửi thư cho tôi <j.w.r.degoede@hhs.nl> và
bao gồm đầu ra của: ZZ0000ZZ
