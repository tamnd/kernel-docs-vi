.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/drivers/bttv-devel.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

tài xế bttv
===============

bttv và âm thanh mini hướng dẫn
-------------------------

Hiện có rất nhiều bo mạch dựa trên bt848/849/878/879 khác nhau.
Làm video thường xuyên không phải là vấn đề lớn vì việc này đã được xử lý
hoàn toàn bằng chip bt8xx, vốn phổ biến trên tất cả các bo mạch.  Nhưng
âm thanh được xử lý theo những cách hơi khác nhau trên mỗi bảng.

Để xử lý các bảng tóm tắt một cách chính xác, có một mảng tvcards[] trong
bttv-cards.c, chứa thông tin cần thiết cho mỗi bảng.
Âm thanh sẽ chỉ hoạt động nếu sử dụng đúng mục nhập (đối với video, nó thường
không tạo ra sự khác biệt).  Trình điều khiển bttv in một dòng tới kernel
log, cho biết loại thẻ nào được sử dụng.  Như cái này::

bttv0: model: BT848(Hauppauge cũ) [tự động phát hiện]

Bạn nên xác minh điều này là chính xác.  Nếu không, bạn phải vượt qua
đúng loại bảng làm đối số insmod, ZZ0000ZZ cho
ví dụ.  File Documentation/admin-guide/media/bttv-cardlist.rst có danh sách
các đối số hợp lệ cho thẻ.

Nếu thẻ của bạn không được liệt kê ở đó, bạn có thể kiểm tra mã nguồn để tìm
mục mới chưa được liệt kê.  Nếu không có cái nào dành cho bạn
thẻ, bạn có thể kiểm tra xem một trong các mục hiện có có phù hợp với bạn không
(chỉ là thử và sai...).

Một số bo mạch có bộ xử lý bổ sung cho âm thanh để giải mã âm thanh nổi
và các tính năng hay khác.  Các chip msp34xx được Hauppauge sử dụng cho
ví dụ.  Nếu bảng của bạn có một bảng, bạn có thể phải tải một trình trợ giúp
mô-đun như ZZ0000ZZ để tạo ra âm thanh.  Nếu không có cái nào cho
chip được sử dụng trên bảng của bạn: Xui xẻo.  Bắt đầu viết một cái mới.  Vâng,
trước tiên bạn có thể muốn kiểm tra kho lưu trữ danh sách gửi thư của video4linux...

Tất nhiên bạn cần một soundcard được cài đặt chính xác trừ khi bạn có
loa được kết nối trực tiếp với bảng ghim.  Gợi ý: kiểm tra
cài đặt máy trộn quá.  Ví dụ: ALSA có mọi thứ bị tắt tiếng theo mặc định.


Cách âm thanh hoạt động chi tiết
~~~~~~~~~~~~~~~~~~~~~~~~~

Vẫn không hoạt động?  Có vẻ như cần phải hack một số trình điều khiển.
Dưới đây là mô tả tự làm cho bạn.

Các chip bt8xx có 32 chân đa năng và các thanh ghi để điều khiển
những chân này.  Một thanh ghi là thanh ghi cho phép đầu ra
(ZZ0000ZZ), nó cho biết chân nào được điều khiển tích cực bởi
chip bt848.  Một cái khác là thanh ghi dữ liệu (ZZ0001ZZ), trong đó
bạn có thể nhận/đặt trạng thái nếu các chân này.  Chúng có thể được sử dụng làm đầu vào
và đầu ra.

Hầu hết các nhà cung cấp bo mạch Grabber đều sử dụng các chân này để điều khiển chip bên ngoài
định tuyến âm thanh.  Nhưng mỗi bảng có một chút khác nhau.
Những chân này cũng được một số công ty sử dụng để điều khiển điều khiển từ xa
chip thu.  Một số bo mạch sử dụng bus i2c thay vì chân gpio
để kết nối chip mux.

Như đã đề cập ở trên, có một mảng chứa yêu cầu
thông tin cho mỗi bảng đã biết.  Về cơ bản bạn phải tạo một cái mới
dòng cho bảng của bạn.  Các trường quan trọng là hai trường sau::

cấu trúc tvcard
  {
	[ ... ]
	u32 gpiomask;
	u32 audiomux[6]; /* Bộ dò sóng, Radio, bên ngoài, bên trong, tắt tiếng, âm thanh nổi */
  };

gpiomask chỉ định chân nào được sử dụng để điều khiển chip mux âm thanh.
Các bit tương ứng trong thanh ghi cho phép đầu ra
(ZZ0000ZZ) sẽ được đặt vì các chân này phải được điều khiển bởi
chip bt848.

Mảng ZZ0000ZZ chứa các giá trị dữ liệu cho các đầu vào khác nhau
(tức là chân nào phải cao/thấp để điều chỉnh/tắt tiếng/...).  Đây sẽ là
được ghi vào thanh ghi dữ liệu (ZZ0001ZZ) để chuyển đổi âm thanh
mux.


Những gì bạn phải làm là tìm ra các giá trị chính xác cho gpiomask và
mảng audiomux.  Nếu bạn có Windows và trình điều khiển bốn
đã cài đặt thẻ, bạn có thể kiểm tra xem bạn có thể đọc các sổ đăng ký này không
các giá trị được sử dụng bởi trình điều khiển windows.  Một công cụ để làm điều này có sẵn
từ ZZ0000ZZ

Bạn cũng có thể tìm hiểu kỹ các tệp ZZ0000ZZ của ứng dụng Windows.
Bạn có thể nhìn vào bảng để xem chân gpio nào
đã kết nối rồi bắt đầu thử và sai ...


Bắt đầu với bản phát hành 0.7.41 bttv có một số tùy chọn insmod để
làm cho việc gỡ lỗi gpio dễ dàng hơn:

=====================================================================
	bttv_gpio=0/1 bật/tắt thông báo gỡ lỗi gpio
	gpiomask=n đặt giá trị gpiomask
	audiomux=i,j,... đặt giá trị của mảng audiomux
	audioall=a đặt các giá trị của mảng audiomux (một
				giá trị cho tất cả các phần tử mảng, hữu ích để kiểm tra
				ra giá trị cụ thể có ảnh hưởng gì).
	=====================================================================

Các tin nhắn được in bằng ZZ0000ZZ trông như thế này::

bttv0: gpio: en=00000027, out=00000024 in=00ffffd8 [âm thanh: tắt]

en = thanh ghi đầu ra _en_able (BT848_GPIO_OUT_EN)
	out = _out_put bit của thanh ghi dữ liệu (BT848_GPIO_DATA),
		tức là BT848_GPIO_DATA & BT848_GPIO_OUT_EN
	in = _in_put bit của thanh ghi dữ liệu,
		tức là BT848_GPIO_DATA & ~BT848_GPIO_OUT_EN