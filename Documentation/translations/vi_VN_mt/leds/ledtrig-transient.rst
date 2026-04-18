.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/leds/ledtrig-transient.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=======================
Kích hoạt tức thời LED
=====================

Hiện tại trigger hẹn giờ led chưa có giao diện để kích hoạt
một bộ đếm thời gian một lần bắn. Hỗ trợ hiện tại cho phép cài đặt hai bộ hẹn giờ, một cho
chỉ định trạng thái sẽ tồn tại trong bao lâu và trạng thái thứ hai trong bao lâu
được tắt. Giá trị delay_on chỉ định khoảng thời gian LED sẽ tồn tại
ở trạng thái bật, theo sau là giá trị delay_off chỉ định thời gian LED
nên ở trạng thái tắt. Chu kỳ bật tắt lặp đi lặp lại cho đến khi kích hoạt
bị vô hiệu hóa. Không có quy định kích hoạt một lần để thực hiện
các tính năng yêu cầu trạng thái bật hoặc tắt chỉ được giữ một lần và sau đó giữ nguyên
trạng thái ban đầu mãi mãi.

Nếu không có giao diện hẹn giờ chụp một lần, không gian người dùng vẫn có thể sử dụng trình kích hoạt hẹn giờ để
tuy nhiên, hãy đặt bộ hẹn giờ để giữ trạng thái khi ứng dụng trong không gian người dùng gặp sự cố hoặc
biến mất mà không tắt bộ hẹn giờ, phần cứng sẽ ở lại đó
trạng thái vĩnh viễn.

Trình kích hoạt tạm thời giải quyết nhu cầu kích hoạt bộ hẹn giờ một lần. các
kích hoạt tạm thời có thể được bật và tắt giống như các đèn led khác
kích hoạt.

Khi trình điều khiển thiết bị lớp led tự đăng ký, nó có thể chỉ định tất cả các đèn led
kích hoạt nó hỗ trợ và kích hoạt mặc định. Trong quá trình đăng ký, kích hoạt
thói quen cho trình kích hoạt mặc định sẽ được gọi. Trong quá trình đăng ký một led
thiết bị lớp, trạng thái LED không thay đổi.

Khi trình điều khiển hủy đăng ký, quy trình hủy kích hoạt cho trình điều khiển hiện đang hoạt động
trigger sẽ được gọi và trạng thái LED được thay đổi thành LED_OFF.

Việc tạm dừng trình điều khiển thay đổi trạng thái LED thành LED_OFF và tiếp tục không thay đổi
nhà nước. Xin lưu ý rằng không có sự tương tác rõ ràng giữa
tạm dừng và tiếp tục các hành động cũng như trình kích hoạt hiện được bật. Trạng thái LED
các thay đổi bị tạm dừng trong khi trình điều khiển ở trạng thái tạm dừng. Bất kỳ đồng hồ hẹn giờ nào
đang hoạt động tại thời điểm người lái xe bị đình chỉ, tiếp tục chạy mà không cần
có thể thực sự thay đổi trạng thái LED. Sau khi trình điều khiển được tiếp tục, sẽ kích hoạt
bắt đầu hoạt động trở lại.

Các thay đổi trạng thái LED được điều khiển bằng độ sáng là đèn led thông thường
thuộc tính thiết bị lớp. Khi độ sáng được đặt thành 0 từ không gian người dùng thông qua
echo 0 > độ sáng, điều này sẽ dẫn đến việc tắt kích hoạt hiện tại.

Trình kích hoạt tạm thời sử dụng giao diện đăng ký và hủy đăng ký tiêu chuẩn. Trong thời gian
đăng ký kích hoạt, cho mỗi thiết bị lớp dẫn chỉ định trình kích hoạt này
làm trình kích hoạt mặc định, quy trình kích hoạt trình kích hoạt sẽ được gọi. Trong thời gian
đăng ký, trạng thái LED không thay đổi, trừ khi có trình kích hoạt khác
hoạt động, trong trường hợp đó trạng thái LED thay đổi thành LED_OFF.

Trong quá trình hủy đăng ký kích hoạt, trạng thái LED được đổi thành LED_OFF.

Quy trình kích hoạt kích hoạt tạm thời không thay đổi trạng thái LED. Nó
tạo ra các thuộc tính của nó và thực hiện khởi tạo nó. Kích hoạt tạm thời
thói quen hủy kích hoạt, sẽ hủy mọi bộ hẹn giờ đang hoạt động trước khi nó dọn dẹp
up và loại bỏ các thuộc tính mà nó đã tạo. Nó sẽ khôi phục trạng thái LED thành
trạng thái không nhất thời. Khi người lái xe bị đình chỉ, bất kể thời gian tạm thời
trạng thái, trạng thái LED thay đổi thành LED_OFF.

Kích hoạt tạm thời có thể được bật và tắt từ không gian người dùng trên lớp led
các thiết bị hỗ trợ trình kích hoạt này như hiển thị bên dưới::

tiếng vang nhất thời> kích hoạt
	không có tiếng vang > kích hoạt

NOTE:
	Thêm trạng thái kích hoạt thuộc tính mới để kiểm soát trạng thái.

Trình kích hoạt này xuất ba thuộc tính, kích hoạt, trạng thái và thời lượng. Khi nào
kích hoạt tạm thời được kích hoạt, các thuộc tính này được đặt thành giá trị mặc định.

- thời lượng cho phép thiết lập giá trị bộ đếm thời gian tính bằng mili giây. Giá trị ban đầu là 0.
- kích hoạt cho phép kích hoạt và hủy kích hoạt bộ hẹn giờ được chỉ định bởi
  thời hạn khi cần thiết. Giá trị ban đầu và mặc định là 0. Điều này sẽ cho phép
  khoảng thời gian được đặt sau khi kích hoạt kích hoạt.
- trạng thái cho phép người dùng chỉ định trạng thái nhất thời được giữ cho thời gian đã chỉ định
  thời lượng.

kích hoạt
	      - cơ chế kích hoạt hẹn giờ một lần chụp.
		1 khi được kích hoạt, 0 khi bị vô hiệu hóa.
		giá trị mặc định bằng 0 khi kích hoạt tạm thời được bật,
		để cho phép thiết lập thời lượng.

trạng thái kích hoạt cho biết bộ hẹn giờ có giá trị được chỉ định
		thời lượng đang chạy.
		trạng thái ngừng hoạt động cho biết không có bộ hẹn giờ hoạt động
		đang chạy.

thời lượng
	      - giá trị hẹn giờ một lần chụp. Khi kích hoạt được đặt, giá trị thời lượng
		được sử dụng để bắt đầu một bộ đếm thời gian chạy một lần. Giá trị này không
		bị kích hoạt thay đổi trừ khi người dùng thực hiện thiết lập thông qua
		echo new_value > thời lượng

tiểu bang
	      - trạng thái nhất thời được giữ. Nó có hai giá trị 0 hoặc 1. 0 bản đồ
		tới LED_OFF và 1 bản đồ tới LED_FULL. Trạng thái được chỉ định là
		được giữ trong suốt thời gian của bộ đếm thời gian một lần chụp và sau đó
		trạng thái được thay đổi thành trạng thái không nhất thời, đó là
		nghịch đảo của trạng thái nhất thời.
		Nếu trạng thái = LED_FULL, khi hết giờ trạng thái sẽ
		quay lại LED_OFF.
		Nếu trạng thái = LED_OFF, khi hết giờ trạng thái sẽ
		quay lại LED_FULL.
		Xin lưu ý rằng trạng thái LED hiện tại không được kiểm tra trước
		thay đổi trạng thái sang trạng thái xác định.
		Trình điều khiển có thể ánh xạ các giá trị này thành đảo ngược tùy thuộc vào
		trạng thái mặc định mà nó xác định cho LED ở độ sáng_set()
		giao diện được gọi từ độ sáng led_set()
		giao diện để kiểm soát trạng thái LED.

Khi hết giờ, kích hoạt sẽ trở lại trạng thái ngừng hoạt động, thời lượng còn lại
ở giá trị đã đặt sẽ được sử dụng khi kích hoạt được đặt vào thời điểm trong tương lai. Điều này sẽ
cho phép ứng dụng người dùng đặt thời gian một lần và kích hoạt nó để chạy một lần cho
giá trị quy định khi cần thiết. Khi hết giờ, trạng thái được khôi phục về
trạng thái không nhất thời là nghịch đảo của trạng thái nhất thời:

======================================================================
	echo 1 > kích hoạt bắt đầu hẹn giờ = thời lượng khi thời lượng không bằng 0.
	echo 0 > kích hoạt hủy bộ đếm thời gian hiện đang chạy.
	echo n > thời lượng lưu trữ giá trị bộ đếm thời gian sẽ được sử dụng cho lần tiếp theo
			    kích hoạt. Hẹn giờ hiện đang hoạt động nếu
			    bất kỳ, tiếp tục chạy trong thời gian quy định.
	echo 0 > thời lượng lưu trữ giá trị bộ đếm thời gian sẽ được sử dụng cho lần tiếp theo
			    kích hoạt. Hẹn giờ hiện đang hoạt động nếu có,
			    tiếp tục chạy trong thời gian quy định.
	echo 1 > trạng thái lưu trữ trạng thái nhất thời mong muốn LED_FULL
			    được giữ trong thời hạn quy định.
	echo 0 > lưu trữ trạng thái nhất thời mong muốn LED_OFF
			    được giữ trong thời hạn quy định.
	======================================================================

Những gì không được hỗ trợ
=====================

- Kích hoạt bộ hẹn giờ là một lần và kéo dài và/hoặc rút ngắn bộ hẹn giờ
  không được hỗ trợ.

Ví dụ
========

trường hợp sử dụng 1::

tiếng vang nhất thời> kích hoạt
	echo n > thời lượng
	echo 1 > trạng thái

lặp lại bước sau nếu cần::

echo 1 > kích hoạt - bắt đầu hẹn giờ = thời lượng chạy một lần
	echo 1 > kích hoạt - bắt đầu hẹn giờ = thời lượng chạy một lần
	không có tiếng vang > kích hoạt

Trình kích hoạt này dự kiến ​​sẽ được sử dụng cho các trường hợp sử dụng ví dụ sau:

- Sử dụng LED bởi ứng dụng không gian người dùng làm chỉ báo hoạt động.
 - Việc ứng dụng không gian người dùng sử dụng LED như một loại chỉ báo cơ quan giám sát -- như
   miễn là ứng dụng còn tồn tại, nó có thể giữ cho LED luôn sáng nếu nó chết
   LED sẽ tự động tắt.
 - Sử dụng bởi bất kỳ ứng dụng không gian người dùng nào cần đầu ra GPIO tạm thời.
