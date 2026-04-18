.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/maintainer/pull-requests.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Tạo yêu cầu kéo
======================

Chương này mô tả cách người bảo trì có thể tạo và gửi yêu cầu kéo
cho những người bảo trì khác. Điều này rất hữu ích cho việc chuyển các thay đổi từ một
cây bảo trì sang cây bảo trì khác.

Tài liệu này được viết bởi Tobin C. Harding (lúc đó chưa phải là một
người bảo trì có kinh nghiệm) chủ yếu từ ý kiến của Greg Kroah-Hartman
và Linus Torvalds trên LKML. Đề xuất và cách khắc phục của Jonathan Corbet và
Mauro Carvalho Chehab.  Sự xuyên tạc là vô tình nhưng không thể tránh khỏi,
vui lòng gửi trực tiếp hành vi lạm dụng tới Tobin C. Harding <me@tobin.cc>.

Chuỗi email gốc::

ZZ0000ZZ


Tạo chi nhánh
-------------

Để bắt đầu, bạn sẽ cần phải có tất cả những thay đổi mà bạn muốn đưa vào
yêu cầu kéo trên một nhánh riêng biệt. Thông thường bạn sẽ căn cứ nhánh này
ra khỏi một nhánh trong cây nhà phát triển mà bạn định gửi lệnh kéo
yêu cầu.

Để tạo yêu cầu kéo, trước tiên bạn phải gắn thẻ nhánh mà bạn
vừa tạo ra. Bạn nên chọn tên thẻ có ý nghĩa,
theo cách mà bạn và những người khác có thể hiểu được, thậm chí sau một thời gian.  tốt
thực tiễn là bao gồm trong tên một chỉ số về hệ thống con xuất xứ
và phiên bản kernel đích.

Greg đưa ra những điều sau đây. Một yêu cầu kéo với nhiều thứ linh tinh cho
driver/char, được áp dụng ở phiên bản Kernel 4.15-rc1 có thể được đặt tên
như ZZ0000ZZ. Nếu thẻ đó được tạo từ một nhánh
có tên ZZ0001ZZ, bạn sẽ sử dụng lệnh sau ::

thẻ git -s char-misc-4.15-rc1 char-misc-next

điều đó sẽ tạo ra một thẻ đã ký tên là ZZ0000ZZ dựa trên
cam kết cuối cùng trong nhánh ZZ0001ZZ và ký nó bằng khóa gpg của bạn
(xem Tài liệu/người bảo trì/configure-git.rst).

Linus sẽ chỉ chấp nhận các yêu cầu kéo dựa trên thẻ đã ký. Khác
người bảo trì có thể khác nhau.

Khi bạn chạy lệnh trên ZZ0000ZZ sẽ đưa bạn vào trình chỉnh sửa và hỏi
bạn để mô tả thẻ.  Trong trường hợp này, bạn đang mô tả một yêu cầu kéo,
vì vậy hãy phác thảo những gì có ở đây, tại sao nó nên được hợp nhất và điều gì, nếu
bất kỳ, thử nghiệm đã được thực hiện.  Tất cả thông tin này sẽ kết thúc trong thẻ
chính nó, và sau đó trong cam kết hợp nhất mà người bảo trì thực hiện nếu/khi họ
hợp nhất yêu cầu kéo. Vì vậy hãy viết nó lên thật tốt, vì nó sẽ có trong kernel
cây mãi mãi.

Như Linus đã nói ::

Dù sao, ít nhất với tôi, phần quan trọng là ZZ0000ZZ. tôi muốn
	để hiểu những gì tôi đang kéo và tại sao tôi nên kéo nó. tôi cũng
	muốn sử dụng tin nhắn đó làm tin nhắn cho việc hợp nhất, vì vậy nó nên
	không chỉ có ý nghĩa với tôi mà còn có ý nghĩa như một ghi chép lịch sử
	quá.

Lưu ý rằng nếu có điều gì đó kỳ lạ về yêu cầu kéo, thì đó
	nên có rất nhiều trong lời giải thích. Nếu bạn đang chạm vào tập tin
	mà bạn không duy trì, hãy giải thích _tại sao_. Tôi sẽ thấy nó trong
	Dù sao đi nữa, diffstat và nếu bạn không đề cập đến nó, tôi sẽ bổ sung thêm
	đáng ngờ.  Và khi bạn gửi cho tôi những thứ mới sau cửa sổ hợp nhất
	(hoặc thậm chí là sửa lỗi, nhưng có vẻ đáng sợ), không chỉ giải thích
	họ làm gì và tại sao họ làm điều đó, nhưng hãy giải thích _thời gian_. cái gì
	đã xảy ra trường hợp điều này không đi qua cửa sổ hợp nhất..

Tôi sẽ lấy cả những gì bạn viết trong email pull request _and_ vào
	thẻ đã ký, vì vậy tùy thuộc vào quy trình làm việc của bạn, bạn có thể
	mô tả công việc của bạn trong thẻ đã ký (thẻ này cũng sẽ tự động
	gửi nó vào email yêu cầu kéo) hoặc bạn có thể tạo chữ ký
	chỉ gắn thẻ một trình giữ chỗ không có gì thú vị trong đó và mô tả
	công việc sau này khi bạn thực sự gửi cho tôi yêu cầu kéo.

Và vâng, tôi sẽ chỉnh sửa tin nhắn. Một phần vì tôi có xu hướng chỉ làm
	định dạng tầm thường (toàn bộ thụt lề và trích dẫn, v.v.), nhưng
	một phần vì một phần của thông điệp có thể có ý nghĩa đối với tôi
	thời gian (mô tả những xung đột và vấn đề cá nhân của bạn để gửi
	ngay bây giờ), nhưng có thể không có ý nghĩa trong bối cảnh hợp nhất
	thông điệp cam kết, vì vậy tôi sẽ cố gắng làm cho nó có ý nghĩa. tôi sẽ
	đồng thời sửa mọi lỗi chính tả và ngữ pháp xấu mà tôi nhận thấy,
	đặc biệt đối với những người không phải người bản xứ (và cả những người bản xứ
	;^). Nhưng tôi có thể bỏ lỡ một số, hoặc thậm chí thêm một số.

Linus

Greg đưa ra, như một ví dụ về yêu cầu kéo::

Các bản vá Char/Misc cho 4.15-rc1

Đây là bộ bản vá char/misc lớn cho cửa sổ hợp nhất 4.15-rc1.
	Chứa trong đây là tập hợp các chức năng mới thông thường được thêm vào tất cả
	của những tay lái điên rồ này, cũng như những chiếc xe hoàn toàn mới sau đây
	hệ thống con:
		- time_travel_controller: Cuối cùng là bộ trình điều khiển cho
		  kiến trúc bus du hành thời gian mới nhất cung cấp I/O cho
		  CPU trước khi được yêu cầu, cho phép không bị gián đoạn
		  chế biến
		- relativity_shifters: do ảnh hưởng của
		  time_travel_controllers có trên toàn bộ hệ thống, ở đó
		  là cần có một bộ trình điều khiển dịch chuyển thuyết tương đối mới để
		  chứa các lỗ đen mới hình thành sẽ
		  đe dọa hút CPU vào chúng.  Hệ thống con này xử lý
		  điều này theo cách để hóa giải thành công các vấn đề.
		  Có một tùy chọn Kconfig để buộc những tùy chọn này được kích hoạt
		  khi cần thiết nên sẽ không xảy ra vấn đề gì.

Tất cả các bản vá này đã được thử nghiệm thành công trong phiên bản mới nhất
	các bản phát hành linux-next và các vấn đề ban đầu mà nó tìm thấy có
	tất cả đã được giải quyết (xin lỗi những ai sống gần Canberra vì
	thiếu các tùy chọn Kconfig trong các phiên bản trước của
	sáng tạo cây linux-next.)

Người đăng ký: Tên của bạn tại đây <your_email@domain>


Định dạng thông báo thẻ giống như id cam kết git.  Một dòng ở trên cùng
để biết "chủ đề tóm tắt" và nhớ ký tên ở phía dưới.

Bây giờ bạn đã có thẻ được ký cục bộ, bạn cần đẩy nó lên vị trí
có thể được lấy ra::

git đẩy nguồn gốc char-misc-4.15-rc1


Tạo yêu cầu kéo
-------------------

Điều cuối cùng cần làm là tạo thông báo yêu cầu kéo.  ZZ0000ZZ một cách thủ công
sẽ thực hiện việc này cho bạn bằng lệnh ZZ0001ZZ, nhưng nó cần một
một chút trợ giúp trong việc xác định những gì bạn muốn kéo và dựa vào những gì để kéo
chống lại (để hiển thị những thay đổi chính xác được kéo và diffstat). các
(các) lệnh sau sẽ tạo yêu cầu kéo::

git yêu cầu-pull master git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/char-misc.git/ char-misc-4.15-rc1

Trích dẫn Greg::

Đây là yêu cầu git so sánh sự khác biệt so với
	Vị trí thẻ 'char-misc-4.15-rc1', ở đầu 'master'
	nhánh (trong trường hợp của tôi trỏ đến vị trí cuối cùng trong Linus's
	cây mà tôi đã chuyển hướng từ đó, thường là bản phát hành -rc) và sử dụng
	giao thức git:// để lấy từ đó.  Nếu bạn muốn sử dụng ZZ0000ZZ
	thay vào đó cũng có thể được sử dụng ở đây (nhưng lưu ý rằng một số người đằng sau
	tường lửa sẽ gặp vấn đề với https git pulls).

Nếu thẻ char-misc-4.15-rc1 không có trong kho lưu trữ của tôi
	yêu cầu được kéo ra, git sẽ phàn nàn rằng nó không có ở đó,
	một cách hữu ích để nhớ thực sự đẩy nó đến một vị trí công cộng.

Đầu ra của 'git request-pull' sẽ chứa vị trí của
	cây git và thẻ cụ thể để lấy từ đó và toàn bộ văn bản
	mô tả của thẻ đó (đó là lý do tại sao bạn cần cung cấp
	thông tin trong thẻ đó).  Nó cũng sẽ tạo ra sự khác biệt về
	kéo yêu cầu và một bản tóm tắt của cá nhân cam kết rằng
	yêu cầu kéo sẽ cung cấp.

Linus trả lời rằng anh ấy có xu hướng thích giao thức ZZ0000ZZ hơn. Khác
người bảo trì có thể có những ưu tiên khác nhau. Ngoài ra, hãy lưu ý rằng nếu bạn
tạo các yêu cầu kéo mà không có thẻ đã ký thì ZZ0001ZZ có thể là một
sự lựa chọn tốt hơn. Vui lòng xem chủ đề gốc để thảo luận đầy đủ.


Gửi yêu cầu kéo
-------------------

Yêu cầu kéo được gửi theo cách tương tự như bản vá thông thường. Gửi dưới dạng
email nội tuyến tới người bảo trì và CC LKML cũng như mọi hệ thống phụ cụ thể
danh sách nếu được yêu cầu. Yêu cầu kéo tới Linus thường có dòng chủ đề
đại loại như::

[GIT PULL] <hệ thống con> thay đổi cho v4.15-rc1
