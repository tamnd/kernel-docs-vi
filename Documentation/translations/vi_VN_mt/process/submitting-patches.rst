.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/submitting-patches.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _submittingpatches:

Gửi bản vá: hướng dẫn cần thiết để đưa mã của bạn vào kernel
============================================================================

Dành cho cá nhân hoặc công ty muốn gửi thay đổi cho Linux
kernel, quá trình này đôi khi có thể khó khăn nếu bạn không quen
với “hệ thống”.  Văn bản này là tập hợp các gợi ý
có thể làm tăng đáng kể cơ hội thay đổi của bạn được chấp nhận.

Tài liệu này chứa một số lượng lớn các đề xuất một cách tương đối ngắn gọn
định dạng.  Để biết thông tin chi tiết về quá trình phát triển hạt nhân
hoạt động, hãy xem Tài liệu/quy trình/phát triển-process.rst. Ngoài ra, hãy đọc
Tài liệu/quy trình/gửi-checklist.rst
để có danh sách các mục cần kiểm tra trước khi gửi mã.
Để biết các bản vá liên kết cây thiết bị, hãy đọc
Tài liệu/devicetree/ràng buộc/gửi-patches.rst.

Tài liệu này giả định rằng bạn đang sử dụng ZZ0000ZZ để chuẩn bị các bản vá của mình.
Nếu bạn chưa quen với ZZ0001ZZ, bạn nên học cách
sử dụng nó, nó sẽ giúp ích cho cuộc sống của bạn với tư cách là một nhà phát triển hạt nhân và nói chung là rất nhiều
dễ dàng hơn.

Một số hệ thống con và cây bảo trì có thêm thông tin về
quy trình làm việc và kỳ vọng của họ, hãy xem
Tài liệu/quy trình/người bảo trì-handbooks.rst.

Lấy cây nguồn hiện tại
----------------------------

Nếu bạn không có sẵn kho lưu trữ nguồn kernel hiện tại, hãy sử dụng
ZZ0000ZZ để có được một cái.  Bạn sẽ muốn bắt đầu với kho lưu trữ chính,
có thể được lấy bằng::

git bản sao git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git

Tuy nhiên, lưu ý rằng bạn có thể không muốn phát triển dựa trên cây chính
trực tiếp.  Hầu hết những người bảo trì hệ thống con đều chạy cây của riêng họ và muốn xem
các miếng vá được chuẩn bị để chống lại những cái cây đó.  Xem mục ZZ0000ZZ cho hệ thống con
trong tệp MAINTAINERS để tìm cây đó hoặc chỉ cần hỏi người bảo trì xem
cây không được liệt kê ở đó.

.. _describe_changes:

Mô tả những thay đổi của bạn
---------------------

Mô tả vấn đề của bạn.  Cho dù bản vá của bạn là bản sửa lỗi một dòng hay
5000 dòng của một tính năng mới, chắc chắn phải có một vấn đề tiềm ẩn nào đó
thúc đẩy bạn làm công việc này.  Thuyết phục người đánh giá rằng có một
vấn đề đáng được khắc phục và việc họ đọc qua phần này là điều hợp lý
đoạn đầu tiên.

Mô tả tác động mà người dùng có thể nhìn thấy.  Trực tiếp gặp sự cố và khóa máy
khá thuyết phục, nhưng không phải lỗi nào cũng trắng trợn như vậy.  Ngay cả khi
vấn đề đã được phát hiện trong quá trình xem xét mã, hãy mô tả tác động mà bạn nghĩ
nó có thể ảnh hưởng đến người dùng.  Hãy nhớ rằng phần lớn Linux
cài đặt chạy hạt nhân từ cây ổn định thứ cấp hoặc
cây dành riêng cho nhà cung cấp/sản phẩm mà chỉ chọn các bản vá cụ thể
từ thượng nguồn, vì vậy hãy bao gồm mọi thứ có thể giúp định hướng thay đổi của bạn
xuôi dòng: tình tiết kích động, đoạn trích từ dmesg, sự cố
mô tả, hồi quy hiệu suất, độ trễ tăng đột biến, khóa, v.v.

Định lượng tối ưu hóa và đánh đổi.  Nếu bạn yêu cầu cải tiến trong
hiệu suất, mức tiêu thụ bộ nhớ, dấu chân ngăn xếp hoặc kích thước nhị phân,
bao gồm các con số hỗ trợ chúng.  Nhưng cũng mô tả không rõ ràng
chi phí.  Việc tối ưu hóa thường không miễn phí mà phải đánh đổi giữa CPU,
bộ nhớ và khả năng đọc; hoặc, khi nói đến phương pháp phỏng đoán, giữa
khối lượng công việc khác nhau.  Mô tả những nhược điểm dự kiến của bạn
tối ưu hóa để người đánh giá có thể cân nhắc giữa chi phí và lợi ích.

Khi vấn đề đã được xác định, hãy mô tả những gì bạn thực sự đang làm
về nó một cách chi tiết kỹ thuật.  Điều quan trọng là phải mô tả sự thay đổi
bằng tiếng Anh đơn giản để người đánh giá xác minh rằng mã đang hoạt động
như bạn dự định.

Người bảo trì sẽ cảm ơn bạn nếu bạn viết mô tả bản vá của mình bằng một
biểu mẫu có thể dễ dàng đưa vào quản lý mã nguồn của Linux
hệ thống, ZZ0001ZZ, dưới dạng "nhật ký cam kết".  Xem ZZ0000ZZ.

Chỉ giải quyết một vấn đề trên mỗi bản vá.  Nếu mô tả của bạn bắt đầu nhận được
dài, đó là dấu hiệu cho thấy bạn có thể cần phải chia nhỏ bản vá của mình.
Xem ZZ0000ZZ.

Khi bạn gửi hoặc gửi lại một bản vá hoặc loạt bản vá, hãy bao gồm
mô tả bản vá đầy đủ và biện minh cho nó.  Đừng chỉ
nói rằng đây là phiên bản N của bản vá (loạt phim).  Đừng mong đợi
người bảo trì hệ thống con để tham khảo lại các phiên bản vá lỗi trước đó hoặc được tham chiếu
URL để tìm mô tả bản vá và đưa nó vào bản vá.
Tức là, bản vá (loạt) và mô tả của nó phải độc lập.
Điều này mang lại lợi ích cho cả người bảo trì và người đánh giá.  Một số người đánh giá
có lẽ thậm chí còn không nhận được các phiên bản vá lỗi trước đó.

Mô tả những thay đổi của bạn trong tâm trạng mệnh lệnh, ví dụ: "làm xyzzy làm đông lạnh"
thay vì "[Bản vá này] làm cho xyzzy bị đóng băng" hoặc "[Tôi] đã thay đổi xyzzy
để làm lạnh", như thể bạn đang ra lệnh cho cơ sở mã thay đổi
hành vi của nó.

Nếu bạn muốn tham khảo một cam kết cụ thể, đừng chỉ tham khảo
SHA-1 ID của cam kết. Vui lòng bao gồm cả bản tóm tắt trực tuyến của
cam kết, để giúp người đánh giá dễ dàng biết nội dung của nó hơn.
Ví dụ::

Cam kết e21d2170f36602ae2708 ("video: xóa không cần thiết
	platform_set_drvdata()") đã loại bỏ những thứ không cần thiết
	platform_set_drvdata(), nhưng không sử dụng biến "dev",
	xóa nó.

Bạn cũng nên đảm bảo sử dụng ít nhất 12 ký tự đầu tiên của
Mã SHA-1.  Kho kernel chứa ZZ0000ZZ của các đối tượng, tạo nên
va chạm với ID ngắn hơn là một khả năng thực sự.  Hãy nhớ rằng, ngay cả khi
hiện tại không có xung đột với ID sáu ký tự của bạn, tình trạng đó có thể
thay đổi năm năm kể từ bây giờ.

Nếu các cuộc thảo luận liên quan hoặc bất kỳ thông tin cơ bản nào khác đằng sau sự thay đổi
có thể được tìm thấy trên web, hãy thêm thẻ 'Link:' trỏ tới nó. Nếu bản vá là một
kết quả của một số cuộc thảo luận về danh sách gửi thư trước đó hoặc điều gì đó được ghi lại trên
web, hãy trỏ tới nó.

Khi liên kết tới kho lưu trữ danh sách gửi thư, tốt nhất nên sử dụng lore.kernel.org
dịch vụ lưu trữ tin nhắn. Để tạo liên kết URL, hãy sử dụng nội dung của
Tiêu đề ZZ0000ZZ của tin nhắn không có dấu ngoặc nhọn xung quanh.
Ví dụ::

Liên kết: ZZ0000ZZ

Vui lòng kiểm tra liên kết để đảm bảo rằng nó thực sự hoạt động và ghi điểm
đến thông điệp liên quan.

Tuy nhiên, hãy cố gắng làm cho lời giải thích của bạn có thể hiểu được mà không cần đến những tác động bên ngoài.
tài nguyên. Ngoài việc cung cấp URL cho kho lưu trữ danh sách gửi thư hoặc lỗi,
tóm tắt các điểm có liên quan của cuộc thảo luận đã dẫn đến
bản vá như đã gửi.

Trong trường hợp bản vá của bạn sửa lỗi, hãy sử dụng thẻ 'Đóng:' có tham chiếu URL
báo cáo trong kho lưu trữ danh sách gửi thư hoặc trình theo dõi lỗi công khai. Ví dụ::

Đóng: ZZ0000ZZ

Một số trình theo dõi lỗi có khả năng tự động đóng các vấn đề khi
cam kết với thẻ như vậy được áp dụng. Một số bot theo dõi danh sách gửi thư có thể
cũng theo dõi các thẻ như vậy và thực hiện một số hành động nhất định. Trình theo dõi lỗi riêng tư và
URL không hợp lệ bị cấm.

Nếu bản vá của bạn sửa lỗi trong một cam kết cụ thể, ví dụ: bạn đã tìm thấy một vấn đề khi sử dụng
ZZ0000ZZ, vui lòng sử dụng thẻ 'Sửa lỗi:' với ít nhất 12 thẻ đầu tiên
các ký tự của ID SHA-1 và tóm tắt một dòng.  Không chia nhỏ thẻ
trên nhiều dòng, các thẻ được miễn khỏi quy tắc "bọc ở 75 cột" trong
để đơn giản hóa các tập lệnh phân tích cú pháp.  Ví dụ::

Sửa lỗi: 54a4f0239f2e ("KVM: MMU: make kvm_mmu_zap_page() trả về số trang nó thực sự được giải phóng")

Các cài đặt ZZ0000ZZ sau đây có thể được sử dụng để thêm định dạng đẹp cho
xuất kiểu trên trong các lệnh ZZ0001ZZ hoặc ZZ0002ZZ ::

[cốt lõi]
		viết tắt = 12
	[đẹp]
		sửa chữa = Sửa lỗi: %h (\"%s\")

Một cuộc gọi ví dụ ::

$ git log -1 --pretty=sửa 54a4f0239f2e
	Sửa lỗi: 54a4f0239f2e ("KVM: MMU: make kvm_mmu_zap_page() trả về số trang nó thực sự được giải phóng")

.. _split_changes:

Tách biệt các thay đổi của bạn
---------------------

Tách mỗi ZZ0000ZZ thành một bản vá riêng.

Ví dụ: nếu những thay đổi của bạn bao gồm cả sửa lỗi và hiệu suất
cải tiến cho một trình điều khiển duy nhất, hãy tách những thay đổi đó thành hai
hoặc nhiều bản vá.  Nếu những thay đổi của bạn bao gồm bản cập nhật API và bản cập nhật mới
trình điều khiển sử dụng API mới đó, hãy tách chúng thành hai bản vá.

Mặt khác, nếu bạn thực hiện một thay đổi duy nhất cho nhiều tệp,
nhóm những thay đổi đó thành một bản vá duy nhất.  Do đó, một sự thay đổi logic duy nhất
được chứa trong một bản vá duy nhất.

Điểm cần nhớ là mỗi bản vá phải tạo ra một nội dung dễ hiểu
thay đổi có thể được xác nhận bởi người đánh giá.  Mỗi bản vá phải hợp lý
dựa trên giá trị riêng của nó.

Nếu một bản vá phụ thuộc vào bản vá khác để có thể thay đổi
hoàn tất, thế là được.  Đơn giản chỉ cần lưu ý ZZ0000ZZ
trong mô tả bản vá của bạn.

Khi chia thay đổi của bạn thành một loạt các bản vá, hãy đặc biệt chú ý đến
đảm bảo rằng kernel được xây dựng và chạy đúng cách sau mỗi bản vá trong
loạt.  Các nhà phát triển sử dụng ZZ0000ZZ để theo dõi sự cố có thể gặp phải
chia nhỏ chuỗi bản vá của bạn tại bất kỳ thời điểm nào; họ sẽ không cảm ơn bạn nếu bạn
giới thiệu lỗi ở giữa.

Nếu bạn không thể thu gọn bộ bản vá của mình thành một bộ bản vá nhỏ hơn,
sau đó chỉ đăng khoảng 15 bài mỗi lần và chờ xem xét và tích hợp.



Kiểu-kiểm tra các thay đổi của bạn
------------------------

Kiểm tra bản vá của bạn để biết các vi phạm kiểu cơ bản, chi tiết về chúng có thể
được tìm thấy trong Tài liệu/process/coding-style.rst.
Không làm như vậy chỉ lãng phí
người đánh giá mất thời gian và có thể bản vá của bạn sẽ bị từ chối
thậm chí không được đọc.

Một ngoại lệ quan trọng là khi di chuyển mã từ một tệp này sang tệp khác.
khác -- trong trường hợp này bạn không nên sửa đổi mã đã di chuyển chút nào trong
cùng một bản vá di chuyển nó.  Điều này thể hiện rõ ràng hành vi của
di chuyển mã và những thay đổi của bạn.  Điều này hỗ trợ rất nhiều cho việc xem xét
sự khác biệt thực tế và cho phép các công cụ theo dõi lịch sử của
chính mã đó.

Kiểm tra các bản vá của bạn bằng trình kiểm tra kiểu bản vá trước khi gửi
(script/checkpatch.pl).  Tuy nhiên, xin lưu ý rằng trình kiểm tra kiểu dáng phải là
được xem như một hướng dẫn chứ không phải là một sự thay thế cho sự phán xét của con người.  Nếu mã của bạn
có vẻ tốt hơn nếu vi phạm thì có lẽ tốt nhất nên để yên.

Người kiểm tra báo cáo ở ba cấp độ:
 - ERROR: những điều rất có thể sai
 - WARNING: những điều cần xem xét cẩn thận
 - CHECK: những điều cần suy nghĩ

Bạn sẽ có thể biện minh cho tất cả các hành vi vi phạm còn tồn tại trong
vá.


Chọn người nhận bản vá của bạn
------------------------------------

Bạn phải luôn sao chép (các) người bảo trì hệ thống con thích hợp và (các) danh sách trên
bất kỳ bản vá mã nào mà họ duy trì; xem qua tệp MAINTAINERS và
lịch sử sửa đổi mã nguồn để xem những người bảo trì đó là ai.  kịch bản
scripts/get_maintainer.pl có thể rất hữu ích ở bước này (chuyển đường dẫn tới
các bản vá làm đối số cho scripts/get_maintainer.pl).  Nếu bạn không thể tìm thấy một
người bảo trì hệ thống con mà bạn đang làm việc, Andrew Morton
(akpm@linux-foundation.org) đóng vai trò là người duy trì biện pháp cuối cùng.

linux-kernel@vger.kernel.org nên được sử dụng theo mặc định cho tất cả các bản vá, nhưng
khối lượng trong danh sách đó đã khiến một số nhà phát triển bỏ qua nó.  làm ơn
Tuy nhiên, đừng spam các danh sách không liên quan và những người không liên quan.

Nhiều danh sách liên quan đến kernel được lưu trữ tại kernel.org; bạn có thể tìm thấy một danh sách
trong số đó tại ZZ0000ZZ Có danh sách liên quan đến kernel
Tuy nhiên, cũng được lưu trữ ở nơi khác.

Linus Torvalds là trọng tài cuối cùng của mọi thay đổi được chấp nhận trong
Hạt nhân Linux.  Địa chỉ email của anh ấy là <torvalds@linux-foundation.org>.
Anh ấy nhận được rất nhiều e-mail, và tại thời điểm này, rất ít bản vá được thực hiện.
Linus trực tiếp, vì vậy thông thường bạn nên cố gắng hết sức để -tránh-
gửi e-mail cho anh ấy.

Nếu bạn có bản vá sửa lỗi bảo mật có thể khai thác được, hãy gửi bản vá đó
tới security@kernel.org.  Đối với các lỗi nghiêm trọng, lệnh cấm vận ngắn hạn có thể được xem xét
cho phép các nhà phân phối cung cấp bản vá cho người dùng; trong những trường hợp như vậy,
rõ ràng là bản vá không nên được gửi tới bất kỳ danh sách công khai nào. Xem thêm
Tài liệu/quy trình/bảo mật-bugs.rst.

Các bản vá sửa lỗi nghiêm trọng trong kernel đã phát hành nên được hướng dẫn
hướng tới những người duy trì sự ổn định bằng cách đặt một dòng như thế này::

Cc: stable@vger.kernel.org

vào khu vực đăng xuất của bản vá của bạn (lưu ý, NOT là người nhận email).  bạn
cũng nên đọc Documentation/process/stable-kernel-rules.rst
Ngoài tài liệu này.

Nếu các thay đổi ảnh hưởng đến giao diện hạt nhân-người dùng, vui lòng gửi MAN-PAGES
người bảo trì (như được liệt kê trong tệp MAINTAINERS), bản vá trang man hoặc tại
ít nhất là một thông báo về sự thay đổi, để một số thông tin được thực hiện theo cách của nó
vào các trang hướng dẫn.  Các thay đổi API trong không gian người dùng cũng phải được sao chép vào
linux-api@vger.kernel.org.


Không có MIME, không có liên kết, không nén, không có tệp đính kèm.  Chỉ là văn bản đơn giản
-------------------------------------------------------------------

Linus và các nhà phát triển kernel khác cần có khả năng đọc và bình luận
về những thay đổi bạn đang gửi.  Điều quan trọng đối với kernel
nhà phát triển có thể "trích dẫn" những thay đổi của bạn bằng cách sử dụng e-mail tiêu chuẩn
công cụ để họ có thể nhận xét về các phần cụ thể trong mã của bạn.

Vì lý do này, tất cả các bản vá phải được gửi qua e-mail "nội tuyến". các
cách dễ nhất để làm điều này là với ZZ0000ZZ, một giải pháp mạnh mẽ
đề nghị.  Hướng dẫn tương tác cho ZZ0001ZZ có sẵn tại
ZZ0002ZZ

Nếu bạn chọn không sử dụng ZZ0000ZZ:

.. warning::

  Be wary of your editor's word-wrap corrupting your patch,
  if you choose to cut-n-paste your patch.

Không đính kèm bản vá dưới dạng tệp đính kèm MIME, được nén hay không.
Nhiều ứng dụng e-mail phổ biến không phải lúc nào cũng truyền được MIME
tệp đính kèm dưới dạng văn bản thuần túy, khiến bạn không thể nhận xét về
mã.  Tệp đính kèm MIME cũng khiến Linus mất thêm một chút thời gian để xử lý,
giảm khả năng thay đổi đính kèm MIME của bạn được chấp nhận.

Ngoại lệ: Nếu người gửi thư của bạn đang ghi sai các bản vá thì ai đó có thể hỏi
bạn gửi lại chúng bằng MIME.

Xem Documentation/process/email-clients.rst để biết các gợi ý về cách định cấu hình
ứng dụng e-mail của bạn để nó gửi các bản vá của bạn nguyên vẹn.

Trả lời các bình luận đánh giá
--------------------------

Bản vá của bạn gần như chắc chắn sẽ nhận được nhận xét từ người đánh giá về các cách thức
bản vá nào có thể được cải thiện, dưới hình thức trả lời email của bạn. Bạn phải
trả lời những ý kiến đó; bỏ qua người đánh giá là một cách tốt để được bỏ qua trong
trở lại. Bạn chỉ cần trả lời email của họ để trả lời nhận xét của họ. Xem lại
các nhận xét hoặc câu hỏi không dẫn đến thay đổi mã gần như chắc chắn sẽ
đưa ra nhận xét hoặc mục nhật ký thay đổi để người đánh giá tiếp theo tốt hơn
hiểu chuyện gì đang xảy ra.

Hãy nhớ nói với người đánh giá những thay đổi bạn đang thực hiện và cảm ơn họ
cho thời gian của họ.  Đánh giá mã là một quá trình mệt mỏi và tốn thời gian, và
người đánh giá đôi khi trở nên gắt gỏng.  Tuy nhiên, ngay cả trong trường hợp đó, hãy trả lời
một cách lịch sự và giải quyết các vấn đề mà họ đã chỉ ra.  Khi gửi tiếp theo
phiên bản, hãy thêm ZZ0001ZZ vào thư xin việc hoặc vào các bản vá riêng lẻ
giải thích sự khác biệt so với lần nộp trước (xem
ZZ0000ZZ).
Thông báo cho những người đã nhận xét về bản vá của bạn về các phiên bản mới bằng cách thêm họ vào
danh sách các bản vá CC.

Xem Documentation/process/email-clients.rst để biết các đề xuất về email
khách hàng và nghi thức trong danh sách gửi thư.

.. _interleaved_replies:

Sử dụng các câu trả lời xen kẽ được cắt bớt trong các cuộc thảo luận qua email
----------------------------------------------------
Việc đăng bài hàng đầu không được khuyến khích trong quá trình phát triển nhân Linux
các cuộc thảo luận. Các câu trả lời xen kẽ (hoặc "nội tuyến") khiến cuộc trò chuyện trở nên thú vị hơn
dễ theo dõi hơn. Để biết thêm chi tiết xem:
ZZ0000ZZ

Như thường được trích dẫn trong danh sách gửi thư::

Đ: ZZ0000ZZ
  Hỏi: Tôi có thể tìm thông tin về thứ được gọi là bài đăng hàng đầu ở đâu?
  Đáp: Bởi vì nó làm xáo trộn trật tự mà mọi người thường đọc văn bản.
  Hỏi: Tại sao việc đăng bài lên top lại là một điều xấu?
  A: Đăng bài hàng đầu.
  Q: Điều khó chịu nhất trong email là gì?

Tương tự, vui lòng cắt bớt những trích dẫn không cần thiết và không liên quan
để trả lời của bạn. Điều này giúp cho việc tìm câu trả lời dễ dàng hơn và tiết kiệm thời gian cũng như
không gian. Để biết thêm chi tiết, xem: ZZ0000ZZ ::

Đ: Không.
  Hỏi: Tôi có nên kèm theo các trích dẫn sau câu trả lời của mình không?

.. _resend_reminders:

Đừng nản lòng - hoặc thiếu kiên nhẫn
------------------------------------

Sau khi bạn đã gửi thay đổi của mình, hãy kiên nhẫn và chờ đợi.  Người đánh giá là
những người bận rộn và có thể không nhận được bản vá của bạn ngay lập tức.

Ngày xửa ngày xưa, các bản vá đã từng biến mất vào khoảng trống mà không có lời bình luận nào,
nhưng quá trình phát triển diễn ra suôn sẻ hơn bây giờ.  Bạn nên
nhận được nhận xét trong vòng vài tuần (thường là 2-3); nếu điều đó không
xảy ra, hãy đảm bảo rằng bạn đã gửi các bản vá của mình đến đúng nơi.
Đợi tối thiểu một tuần trước khi gửi lại hoặc gửi tin nhắn cho người đánh giá
- có thể lâu hơn trong thời gian bận rộn như hợp nhất các cửa sổ.

Bạn cũng có thể gửi lại bản vá hoặc loạt bản vá sau một vài lần.
tuần có thêm từ "RESEND" vào dòng chủ đề::

[PATCH Vx RESEND] sub/sys: Tóm tắt bản vá cô đọng

Không thêm "RESEND" khi bạn gửi phiên bản sửa đổi của
bản vá hoặc loạt bản vá - "RESEND" chỉ áp dụng cho việc gửi lại bản vá
bản vá hoặc loạt bản vá chưa được sửa đổi dưới bất kỳ hình thức nào từ
trình trước đó.


Bao gồm PATCH trong chủ đề
-----------------------------

Do lưu lượng e-mail đến Linus và linux-kernel cao nên điều này thường xảy ra
quy ước đặt tiền tố dòng chủ đề của bạn bằng [PATCH].  Điều này cho phép Linus
và các nhà phát triển hạt nhân khác dễ dàng phân biệt các bản vá hơn với các bản khác
thảo luận qua email.

ZZ0000ZZ sẽ tự động thực hiện việc này cho bạn.


Ký tên vào tác phẩm của bạn - Giấy chứng nhận xuất xứ của nhà phát triển
------------------------------------------------------

Để cải thiện việc theo dõi xem ai đã làm gì, đặc biệt là với các bản vá có thể
thấm đến nơi an nghỉ cuối cùng trong hạt nhân thông qua nhiều
lớp người bảo trì, chúng tôi đã giới thiệu quy trình "đăng xuất" trên
các bản vá đang được gửi qua email xung quanh.

Việc đăng xuất là một dòng đơn giản ở cuối phần giải thích cho
bản vá, chứng nhận rằng bạn đã viết nó hoặc có quyền
chuyển nó dưới dạng bản vá nguồn mở.  Các quy tắc khá đơn giản: nếu bạn
có thể chứng nhận dưới đây:

Giấy chứng nhận xuất xứ của nhà phát triển 1.1
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Bằng việc đóng góp cho dự án này, tôi chứng nhận rằng:

(a) Khoản đóng góp được tạo ra toàn bộ hoặc một phần bởi tôi và tôi
            có quyền gửi nó theo giấy phép nguồn mở
            được chỉ định trong hồ sơ; hoặc

(b) Sự đóng góp dựa trên công việc trước đó, theo cách tốt nhất
            theo hiểu biết của tôi, được bảo vệ theo một nguồn mở thích hợp
            giấy phép và tôi có quyền theo giấy phép đó để gửi giấy phép đó
            làm việc với các sửa đổi, cho dù được tạo toàn bộ hay một phần
            bởi tôi, theo cùng một giấy phép nguồn mở (trừ khi tôi
            được phép gửi theo một giấy phép khác), như đã chỉ ra
            trong tập tin; hoặc

(c) Sự đóng góp được cung cấp trực tiếp cho tôi bởi một số người khác
            người đã chứng nhận (a), (b) hoặc (c) và tôi chưa sửa đổi
            nó.

(d) Tôi hiểu và đồng ý rằng dự án này và sự đóng góp
            là công khai và hồ sơ đóng góp (bao gồm tất cả
            thông tin cá nhân tôi gửi cùng với nó, bao gồm cả việc tôi ký xác nhận) là
            được duy trì vô thời hạn và có thể được phân phối lại phù hợp với
            dự án này hoặc (các) giấy phép nguồn mở có liên quan.

sau đó bạn chỉ cần thêm một dòng nói::

Người đăng ký: Nhà phát triển Random J <random@developer.example.org>

sử dụng danh tính đã biết (xin lỗi, không có đóng góp ẩn danh nào.)
Việc này sẽ được thực hiện tự động cho bạn nếu bạn sử dụng ZZ0000ZZ.
Việc hoàn nguyên cũng phải bao gồm "Đã đăng xuất bởi". ZZ0001ZZ làm được điều đó
dành cho bạn.

Một số người còn đặt thêm thẻ ở cuối.  Họ sẽ bị bỏ qua vì
ngay bây giờ, nhưng bạn có thể làm điều này để đánh dấu các thủ tục nội bộ của công ty hoặc chỉ
chỉ ra một số chi tiết đặc biệt về việc đăng xuất.

Bất kỳ SoB nào khác (Được ký bởi:'s) sau SoB của tác giả đều đến từ
người xử lý và vận chuyển bản vá nhưng không tham gia vào việc đó
sự phát triển. Chuỗi SoB sẽ phản ánh lộ trình ZZ0000ZZ mà bản vá đã thực hiện
vì nó đã được truyền bá tới những người bảo trì và cuối cùng là Linus, với
mục SoB đầu tiên báo hiệu quyền tác giả chính của một tác giả.


Khi nào nên sử dụng Acked-by:, Cc:, và Co-develop-by:
------------------------------------------------

Thẻ Signed-off-by: chỉ ra rằng người ký đã tham gia vào
sự phát triển của bản vá hoặc anh ấy/cô ấy đang trong quá trình phân phối bản vá.

Nếu một người không trực tiếp tham gia vào việc chuẩn bị hoặc xử lý một
vá nhưng muốn biểu thị và ghi lại sự chấp thuận của họ đối với nó thì họ có thể
yêu cầu thêm dòng Acked-by: vào nhật ký thay đổi của bản vá.

Acked-by: được sử dụng bởi những người chịu trách nhiệm hoặc có liên quan đến
mã bị ảnh hưởng theo cách này hay cách khác.  Thông thường nhất, người bảo trì khi đó
người bảo trì không đóng góp hay chuyển tiếp bản vá.

Được xác nhận bởi: cũng có thể được sử dụng bởi các bên liên quan khác, chẳng hạn như những người có tên miền
kiến thức (ví dụ: tác giả ban đầu của mã đang được sửa đổi), phía không gian người dùng
người đánh giá bản vá uAPI kernel hoặc người dùng chính của một tính năng.  Tùy chọn, trong
Trong những trường hợp này, việc thêm "# Suffix" để làm rõ ý nghĩa của nó có thể hữu ích::

Được xác nhận bởi: Người dùng chính của Bên liên quan <stakeholder@example.org> # As

Acked-by: không trang trọng như Signed-off-by:.  Đó là một kỷ lục mà Acker
ít nhất đã xem xét bản vá và đã thể hiện sự chấp nhận.  Do đó vá
việc sáp nhập đôi khi sẽ chuyển đổi thủ công câu nói "vâng, tôi thấy ổn" của acker
thành Acked-by: (nhưng lưu ý rằng thường tốt hơn nên yêu cầu một
xác nhận rõ ràng).

Acked-by: cũng ít trang trọng hơn Reviewed-by:.  Ví dụ, người bảo trì có thể
sử dụng nó để biểu thị rằng họ đồng ý với việc hạ cánh theo bản vá, nhưng họ có thể không có
đã xem xét nó kỹ lưỡng như thể Người được đánh giá: đã được cung cấp.  Tương tự, một khóa
người dùng có thể chưa thực hiện đánh giá kỹ thuật về bản vá nhưng họ có thể
hài lòng với cách tiếp cận chung, tính năng hoặc giao diện người dùng.

Được xác nhận bởi: không nhất thiết biểu thị sự thừa nhận của toàn bộ bản vá.
Ví dụ: nếu một bản vá ảnh hưởng đến nhiều hệ thống con và có Acked-by: from
một người bảo trì hệ thống con thì điều này thường biểu thị sự thừa nhận
phần ảnh hưởng đến mã của người bảo trì đó.  Sự phán xét nên được sử dụng ở đây.
Khi có nghi ngờ, mọi người nên tham khảo cuộc thảo luận ban đầu trong thư gửi
liệt kê các kho lưu trữ.  "# Suffix" cũng có thể được sử dụng trong trường hợp này để làm rõ.

Nếu một người có cơ hội bình luận về một bản vá nhưng chưa
cung cấp những nhận xét như vậy, bạn có thể tùy ý thêm thẻ ZZ0000ZZ vào bản vá.
Thẻ này chứa các tài liệu mà các bên có khả năng quan tâm đã được đưa vào
cuộc thảo luận. Lưu ý, đây là một trong ba thẻ duy nhất bạn có thể sử dụng
mà không có sự cho phép rõ ràng của người có tên (xem 'Gắn thẻ mọi người yêu cầu
quyền' bên dưới để biết chi tiết).

Được đồng phát triển bởi: nêu rõ rằng bản vá được nhiều nhà phát triển đồng tạo ra;
nó được sử dụng để ghi công cho các đồng tác giả (ngoài tác giả
được gán bởi thẻ From:) khi nhiều người cùng làm việc trên một bản vá.  Kể từ khi
Co-develop-by: biểu thị quyền tác giả, mọi Co-develop-by: phải ngay lập tức
theo sau là Người ký tắt: của đồng tác giả liên quan.  Đăng xuất tiêu chuẩn
áp dụng quy trình, tức là thứ tự của các thẻ Signed-off-by: phải phản ánh
lịch sử theo trình tự thời gian của bản vá trong chừng mực có thể, bất kể liệu
tác giả được phân bổ thông qua From: hoặc Co-develop-by:.  Đáng chú ý, cuối cùng
Người đăng ký: phải luôn là của nhà phát triển gửi bản vá.

Lưu ý, thẻ From: là tùy chọn khi tác giả From: cũng là người (và
email) được liệt kê trong dòng From: của tiêu đề email.

Ví dụ về bản vá được gửi bởi Người từ: tác giả::

<nhật ký thay đổi>

Đồng phát triển bởi: Đồng tác giả đầu tiên <first@coauthor.example.org>
	Người ký tắt: Đồng tác giả đầu tiên <first@coauthor.example.org>
	Đồng phát triển bởi: Đồng tác giả thứ hai <second@coauthor.example.org>
	Người đăng ký: Đồng tác giả thứ hai <second@coauthor.example.org>
	Người đăng ký: Từ tác giả <from@author.example.org>

Ví dụ về bản vá được gửi bởi Người đồng phát triển: tác giả::

Từ: Từ tác giả <from@author.example.org>

<nhật ký thay đổi>

Đồng phát triển bởi: Đồng tác giả ngẫu nhiên <random@coauthor.example.org>
	Người ký tắt: Đồng tác giả ngẫu nhiên <random@coauthor.example.org>
	Người đăng ký: Từ tác giả <from@author.example.org>
	Đồng phát triển bởi: Đồng tác giả gửi <sub@coauthor.example.org>
	Người ký tắt: Đồng tác giả gửi <sub@coauthor.example.org>


Sử dụng Người báo cáo:, Người kiểm tra:, Người đánh giá:, Người đề xuất: và Bản sửa lỗi:
----------------------------------------------------------------------

Thẻ Người báo cáo ghi công cho những người tìm thấy lỗi và báo cáo lỗi đó.
hy vọng sẽ truyền cảm hứng cho họ để giúp chúng tôi một lần nữa trong tương lai. Thẻ này nhằm mục đích
lỗi; vui lòng không sử dụng nó để yêu cầu tính năng tín dụng. Thẻ nên được
theo sau là thẻ Đóng: trỏ đến báo cáo, trừ khi báo cáo không được
có sẵn trên web. Thẻ Link: có thể được sử dụng thay cho Closes: nếu bản vá
khắc phục một phần của (các) sự cố đang được báo cáo. Lưu ý, thẻ Người báo cáo là một
chỉ có ba thẻ bạn có thể sử dụng mà không cần sự cho phép rõ ràng của
người được nêu tên (xem 'Gắn thẻ mọi người cần có sự cho phép' bên dưới để biết chi tiết).

Thẻ Tested-by: cho biết rằng bản vá đã được thử nghiệm thành công (trong
một số môi trường) bởi người có tên.  Thẻ này thông báo cho người bảo trì rằng
một số thử nghiệm đã được thực hiện, cung cấp phương tiện để xác định vị trí người thử nghiệm
các bản vá trong tương lai và đảm bảo tín dụng cho người thử nghiệm.

Người đánh giá: thay vào đó, chỉ ra rằng bản vá đã được xem xét và tìm thấy
chấp nhận được theo Tuyên bố của Người đánh giá:

Tuyên bố giám sát của người đánh giá
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Bằng cách cung cấp thẻ Người đánh giá: của tôi, tôi tuyên bố rằng:

(a) Tôi đã tiến hành đánh giá kỹ thuật của bản vá này để
	     đánh giá sự phù hợp và sẵn sàng của nó để đưa vào
	     hạt nhân dòng chính.

(b) Mọi vấn đề, thắc mắc hoặc thắc mắc liên quan đến bản vá
	     đã được thông báo lại cho người gửi.  tôi hài lòng
	     với phản hồi của người gửi đối với nhận xét của tôi.

(c) Mặc dù có thể có những điều có thể được cải thiện bằng cách này
	     trình, tôi tin rằng vào thời điểm này, (1) một
	     sự sửa đổi đáng giá đối với hạt nhân và (2) không có các lỗi đã biết
	     những vấn đề có thể phản đối việc đưa nó vào.

(d) Trong khi tôi đã xem lại bản vá và tin rằng nó ổn, tôi
	     không (trừ khi được nêu rõ ràng ở nơi khác) thực hiện bất kỳ
	     bảo đảm hoặc đảm bảo rằng nó sẽ đạt được mục tiêu đã nêu
	     mục đích hoặc hoạt động đúng đắn trong bất kỳ tình huống nào.

Thẻ được đánh giá bởi là một tuyên bố quan điểm rằng bản vá là một
sửa đổi thích hợp của kernel mà không có bất kỳ sự sửa đổi nghiêm trọng nào còn lại
các vấn đề kỹ thuật.  Bất kỳ người đánh giá nào quan tâm (người đã thực hiện công việc) đều có thể
cung cấp thẻ Người đánh giá cho bản vá.  Thẻ này dùng để cung cấp tín dụng cho
người xem xét và thông báo cho người bảo trì về mức độ xem xét đã được thực hiện
được thực hiện trên bản vá.  Người đánh giá: thẻ, khi được cung cấp bởi người đánh giá đã biết
hiểu lĩnh vực chủ đề và thực hiện đánh giá kỹ lưỡng, thông thường sẽ
tăng khả năng bản vá của bạn vào được kernel.

Cả hai thẻ Được kiểm tra bởi và Được đánh giá, sau khi nhận được trong danh sách gửi thư từ người kiểm tra
hoặc người đánh giá, phải được tác giả thêm vào các bản vá có thể áp dụng khi gửi
các phiên bản tiếp theo.  Tuy nhiên, nếu bản vá đã thay đổi đáng kể sau
phiên bản này, các thẻ này có thể không còn áp dụng được nữa và do đó cần được xóa.
Thông thường, việc xóa các thẻ Được người xác nhận, Người kiểm tra hoặc Người đánh giá của ai đó phải thực hiện
được đề cập trong nhật ký thay đổi bản vá kèm theo lời giải thích (sau '---'
dấu phân cách).

Thẻ Đề xuất bởi: cho biết ý tưởng bản vá được đề xuất bởi người đó
được đặt tên và đảm bảo công nhận cho người có ý tưởng: nếu chúng ta siêng năng ghi công
những phóng viên ý tưởng của chúng tôi, hy vọng họ sẽ được truyền cảm hứng để giúp chúng tôi một lần nữa trong
tương lai. Lưu ý, đây là một trong ba thẻ duy nhất bạn có thể sử dụng mà không cần
sự cho phép rõ ràng của người có tên (xem 'Gắn thẻ mọi người yêu cầu
quyền' bên dưới để biết chi tiết).

Thẻ Fixes: cho biết rằng bản vá đã sửa lỗi trong lần xác nhận trước đó. Nó
được sử dụng để giúp bạn dễ dàng xác định nguồn gốc của sự cố, điều này có thể giúp ích
xem xét sửa lỗi. Thẻ này cũng hỗ trợ nhóm hạt nhân ổn định trong việc xác định
phiên bản kernel ổn định nào sẽ nhận được bản sửa lỗi của bạn. Đây là ưu tiên
phương pháp chỉ ra lỗi đã được sửa bởi bản vá. Xem ZZ0000ZZ
để biết thêm chi tiết.

Lưu ý: Việc đính kèm thẻ Fixes: không phá vỡ các quy tắc kernel ổn định
quá trình cũng như yêu cầu về Cc: stable@vger.kernel.org trên tất cả ổn định
vá ứng cử viên. Để biết thêm thông tin, vui lòng đọc
Tài liệu/quy trình/ổn định-kernel-rules.rst.

Cuối cùng, mặc dù việc cung cấp thẻ được hoan nghênh và thường được đánh giá rất cao, vui lòng
lưu ý rằng người ký (tức là người nộp và người duy trì) có thể sử dụng theo ý mình trong
áp dụng các thẻ được cung cấp.

.. _tagging_people:

Gắn thẻ mọi người cần có sự cho phép
----------------------------------

Hãy cẩn thận khi thêm các thẻ nói trên vào bản vá của bạn, vì tất cả
ngoại trừ Cc:, Người báo cáo:, và Người gợi ý: cần có sự cho phép rõ ràng của
người có tên. Đối với ba sự cho phép ngầm đó là đủ nếu người đó
đã đóng góp cho nhân Linux bằng tên và địa chỉ email đó theo
vào kho lưu trữ truyền thuyết hoặc lịch sử cam kết -- và trong trường hợp Người báo cáo:
và Người được đề xuất: đã báo cáo hoặc đề xuất trước công chúng. Lưu ý,
bugzilla.kernel.org theo nghĩa này là một nơi công cộng, nhưng địa chỉ email
được sử dụng có riêng tư; vì vậy đừng để chúng trong thẻ, trừ khi người đó
đã sử dụng chúng trong những đóng góp trước đó.

Sử dụng Được hỗ trợ bởi:
------------------

Nếu bạn sử dụng bất kỳ loại công cụ mã hóa nâng cao nào khi tạo bản vá của mình,
bạn cần thừa nhận việc sử dụng đó bằng cách thêm thẻ Được hỗ trợ.  Thất bại trong việc
làm như vậy có thể cản trở việc chấp nhận công việc của bạn.  Xin vui lòng xem
Tài liệu/quy trình/coding-assistants.rst để biết chi tiết về
sự thừa nhận của trợ lý mã hóa.


.. _the_canonical_patch_format:

Định dạng bản vá chuẩn
--------------------------

Phần này mô tả cách định dạng bản vá.  Lưu ý
rằng, nếu bạn có các bản vá được lưu trữ trong kho ZZ0000ZZ, bản vá thích hợp
định dạng có thể có với ZZ0001ZZ.  Các công cụ không thể tạo
Tuy nhiên, văn bản cần thiết, vì vậy hãy đọc hướng dẫn bên dưới.

Dòng chủ đề
^^^^^^^^^^^^

Dòng chủ đề bản vá chuẩn là::

Chủ đề: [PATCH 001/123] hệ thống con: cụm từ tóm tắt

Nội dung thông báo bản vá chuẩn có nội dung sau:

- Một dòng ZZ0000ZZ chỉ định tác giả bản vá, theo sau là một dòng trống
    dòng (chỉ cần thiết nếu người gửi bản vá không phải là tác giả).

- Phần thân bài giải thích, có dòng bao gồm 75 cột.
    được sao chép vào nhật ký thay đổi vĩnh viễn để mô tả bản vá này.

- Một dòng trống.

- Các dòng ZZ0000ZZ được mô tả ở trên sẽ
    cũng đi vào nhật ký thay đổi.

- Một dòng đánh dấu chỉ chứa ZZ0000ZZ.

- Bất kỳ ý kiến ​​bổ sung nào không phù hợp với nhật ký thay đổi.

- Bản vá thực tế (đầu ra ZZ0000ZZ).

Định dạng dòng Chủ đề giúp sắp xếp email rất dễ dàng
theo thứ tự bảng chữ cái theo dòng chủ đề - hầu như bất kỳ người đọc email nào cũng sẽ
hỗ trợ điều đó - vì số thứ tự không được đệm,
cách sắp xếp theo số và chữ cái là như nhau.

ZZ0000ZZ trong Chủ đề của email sẽ xác định
khu vực hoặc hệ thống con của kernel đang được vá.

ZZ0000ZZ trong Chủ đề của email phải chính xác
mô tả bản vá mà email đó chứa.  ZZ0001ZZ không được là tên tệp.  Không sử dụng cùng một ZZ0002ZZ cho mọi bản vá trong toàn bộ chuỗi bản vá (trong đó ZZ0003ZZ là một chuỗi được sắp xếp theo thứ tự của nhiều bản vá có liên quan).

Hãy nhớ rằng ZZ0000ZZ trong email của bạn sẽ trở thành
mã định danh duy nhất trên toàn cầu cho bản vá đó.  Nó lan truyền khắp mọi nơi
vào nhật ký thay đổi ZZ0001ZZ.  ZZ0002ZZ sau này có thể được sử dụng trong
các cuộc thảo luận của nhà phát triển đề cập đến bản vá.  Mọi người sẽ muốn
google tìm ZZ0003ZZ để đọc thảo luận về vấn đề đó
vá.  Đó cũng sẽ là thứ duy nhất mà mọi người có thể nhanh chóng nhìn thấy
khi đó, hai hoặc ba tháng sau, có lẽ họ sẽ trải qua
hàng nghìn bản vá bằng các công cụ như ZZ0004ZZ hoặc ZZ0005ZZ.

Vì những lý do này, ZZ0000ZZ phải không quá 70-75
các ký tự và nó cũng phải mô tả cả những thay đổi của bản vá
tại sao bản vá có thể cần thiết.  Thật khó để trở thành cả hai
ngắn gọn và mang tính mô tả, nhưng đó là những gì một bản tóm tắt được viết tốt
nên làm.

ZZ0000ZZ có thể được bắt đầu bằng các thẻ được đặt trong hình vuông
dấu ngoặc: "Chủ đề: [PATCH <thẻ>...] <cụm từ tóm tắt>".  Các thẻ là
không được coi là một phần của cụm từ tóm tắt nhưng hãy mô tả cách vá lỗi
nên được điều trị.  Các thẻ phổ biến có thể bao gồm bộ mô tả phiên bản nếu
nhiều phiên bản của bản vá đã được gửi đi để đáp lại
nhận xét (ví dụ: "v1, v2, v3") hoặc "RFC" để biểu thị yêu cầu
ý kiến.

Nếu có bốn bản vá trong một chuỗi bản vá thì các bản vá riêng lẻ có thể
được đánh số như sau: 1/4, 2/4, 3/4, 4/4. Điều này đảm bảo rằng các nhà phát triển
hiểu thứ tự áp dụng các bản vá và điều đó
họ đã xem xét hoặc áp dụng tất cả các bản vá trong loạt bản vá.

Dưới đây là một số ví dụ điển hình

Chủ đề: [PATCH 2/5] ext2: cải thiện khả năng mở rộng tìm kiếm bitmap
    Chủ đề: [PATCH v2 01/27] x86: sửa lỗi theo dõi eflags
    Chủ đề: [PATCH v2] sub/sys: Tóm tắt bản vá cô đọng
    Chủ đề: [PATCH v2 M/N] sub/sys: Tóm tắt bản vá cô đọng

Từ dòng
^^^^^^^^^

Dòng ZZ0000ZZ phải là dòng đầu tiên trong nội dung thư,
và có dạng:

Từ: Tác giả bản vá <author@example.com>

Dòng ZZ0000ZZ chỉ định ai sẽ được ghi nhận là tác giả của
vá trong nhật ký thay đổi vĩnh viễn.  Nếu thiếu dòng ZZ0001ZZ,
thì dòng ZZ0002ZZ từ tiêu đề email sẽ được sử dụng để xác định
tác giả bản vá trong nhật ký thay đổi.

Tác giả có thể cho biết liên kết của họ hoặc nhà tài trợ của tác phẩm
bằng cách thêm tên của một tổ chức vào dòng ZZ0000ZZ và ZZ0001ZZ,
ví dụ:

Từ: Tác giả bản vá (Công ty) <author@example.com>

Nội dung giải thích
^^^^^^^^^^^^^^^^

Cơ quan giải trình sẽ cam kết nguồn vĩnh viễn
nhật ký thay đổi, do đó sẽ có ý nghĩa đối với người đọc thành thạo, những người đã có kinh nghiệm lâu năm
quên mất những chi tiết trực tiếp của cuộc thảo luận có thể dẫn đến
bản vá này. Bao gồm các dấu hiệu lỗi mà bản vá giải quyết
(thông báo nhật ký kernel, thông báo lỗi, v.v.) đặc biệt hữu ích cho
những người có thể đang tìm kiếm nhật ký cam kết đang tìm kiếm thông tin áp dụng
vá. Văn bản phải được viết chi tiết sao cho khi đọc
vài tuần, vài tháng hoặc thậm chí nhiều năm sau, nó có thể cung cấp cho người đọc những thông tin cần thiết
chi tiết để nắm được lý do ZZ0000ZZ bản vá đã được tạo.

Nếu một bản vá khắc phục lỗi biên dịch, có thể không cần thiết phải đưa vào
_all_ của các lỗi biên dịch; chỉ đủ để có khả năng là như vậy
ai đó đang tìm kiếm bản vá có thể tìm thấy nó. Như trong ZZ0000ZZ, điều quan trọng là phải ngắn gọn cũng như mang tính mô tả.

.. _backtraces:

Dấu vết quay lại trong thông điệp cam kết
"""""""""""""""""""""""""""""

Dấu vết quay lại giúp ghi lại chuỗi cuộc gọi dẫn đến sự cố. Tuy nhiên,
không phải tất cả các dấu vết quay lại đều hữu ích. Ví dụ: chuỗi cuộc gọi khởi động sớm là
độc đáo và rõ ràng. Tuy nhiên, việc sao chép nguyên văn đầu ra dmesg đầy đủ,
thêm thông tin gây mất tập trung như dấu thời gian, danh sách mô-đun, đăng ký và
ngăn xếp bãi rác.

Do đó, các dấu vết quay lại hữu ích nhất sẽ chắt lọc được những thông tin liên quan
thông tin từ bãi rác, giúp tập trung vào thực tế dễ dàng hơn
vấn đề. Đây là một ví dụ về một vết lùi được cắt tỉa cẩn thận::

Lỗi truy cập MSR không được kiểm tra: WRMSR thành 0xd51 (đã cố ghi 0x00000000000000064)
  tại rIP: 0xffffffffae059994 (native_write_msr+0x4/0x20)
  Theo dõi cuộc gọi:
  mba_wrmsr
  cập nhật_domain
  rdtgroup_mkdir

bình luận
^^^^^^^^^^

Dòng đánh dấu ZZ0000ZZ phục vụ mục đích thiết yếu là đánh dấu cho
công cụ xử lý bản vá nơi thông báo thay đổi kết thúc.

Một cách sử dụng tốt cho các nhận xét bổ sung sau điểm đánh dấu ZZ0000ZZ là
đối với ZZ0001ZZ, để hiển thị những tập tin đã thay đổi và số lượng
các dòng được chèn và xóa trên mỗi tập tin. ZZ0002ZZ đặc biệt hữu ích
trên các bản vá lớn hơn. Nếu bạn định đưa ZZ0003ZZ vào sau
Điểm đánh dấu ZZ0004ZZ, vui lòng sử dụng tùy chọn ZZ0005ZZ ZZ0006ZZ để
tên tập tin được liệt kê từ đầu cây nguồn kernel và không
sử dụng quá nhiều không gian theo chiều ngang (dễ dàng vừa với 80 cột, có thể với một số
thụt lề). (ZZ0007ZZ tạo ra các khác biệt thích hợp theo mặc định.)

Các nhận xét khác chỉ liên quan đến thời điểm hoặc người bảo trì, không phải
phù hợp với nhật ký thay đổi vĩnh viễn, cũng nên vào đây. tốt
ví dụ về những nhận xét như vậy có thể là ZZ0000ZZ mô tả
điều gì đã thay đổi giữa phiên bản v1 và v2 của bản vá.

Hãy để thông tin này ZZ0001ZZ vào dòng ZZ0000ZZ ngăn cách
nhật ký thay đổi từ phần còn lại của bản vá. Thông tin phiên bản là
không phải là một phần của nhật ký thay đổi được cam kết với cây git. Đó là
thông tin bổ sung cho người đánh giá. Nếu nó được đặt phía trên
thẻ cam kết, nó cần tương tác thủ công để xóa nó. Nếu nó ở dưới
đường phân cách, nó sẽ tự động bị loại bỏ khi áp dụng
vá.  Nếu có, hãy thêm liên kết vào các phiên bản trước của bản vá (ví dụ:
liên kết lưu trữ lore.kernel.org) được khuyến nghị để giúp người đánh giá::

<thông báo cam kết>
  ...
Người ký tên: Tác giả <author@mail>
  ---
  V2 -> V3: Loại bỏ chức năng trợ giúp dư thừa
  V1 -> V2: Cải tiến kiểu mã hóa và giải quyết các nhận xét đánh giá

v2: ZZ0000ZZ
  v1: ZZ0001ZZ

đường dẫn/đến/tập tin | 5+++--
  ...

Xem thêm chi tiết về định dạng bản vá thích hợp ở phần sau
tài liệu tham khảo.

.. _explicit_in_reply_to:

Tiêu đề trả lời rõ ràng
----------------------------

Có thể hữu ích khi thêm tiêu đề In-Reply-To: vào bản vá theo cách thủ công
(ví dụ: khi sử dụng ZZ0000ZZ) để liên kết bản vá với
cuộc thảo luận có liên quan trước đó, ví dụ. để liên kết bản sửa lỗi với email với
báo cáo lỗi.  Tuy nhiên, đối với một loạt nhiều bản vá, nhìn chung
tốt nhất nên tránh sử dụng In-Reply-To: để liên kết tới các phiên bản cũ hơn của
loạt.  Bằng cách này, nhiều phiên bản của bản vá không trở thành một
rừng tài liệu tham khảo không thể quản lý trong ứng dụng email.  Nếu một liên kết là
hữu ích, bạn có thể sử dụng bộ chuyển hướng ZZ0001ZZ (ví dụ: trong
văn bản email bìa) để liên kết đến phiên bản cũ hơn của loạt bản vá.


Cung cấp thông tin cây cơ sở
-------------------------------

Khi các nhà phát triển khác nhận được bản vá của bạn và bắt đầu quá trình đánh giá,
điều thực sự cần thiết là họ phải biết đâu là cơ sở
cam kết/nhánh mà công việc của bạn áp dụng, xem xét số lượng tuyệt đối
cây duy trì hiện nay. Lưu ý lại mục ZZ0000ZZ trong
Tệp MAINTAINERS đã được giải thích ở trên.

Điều này thậm chí còn quan trọng hơn đối với các quy trình CI tự động cố gắng
tiến hành một loạt thử nghiệm để xác định chất lượng của
gửi trước khi người bảo trì bắt đầu xem xét.

Nếu bạn đang sử dụng ZZ0000ZZ để tạo các bản vá của mình, bạn có thể
tự động đưa thông tin cây cơ sở vào bài gửi của bạn bằng cách
sử dụng cờ ZZ0001ZZ. Cách dễ dàng và thuận tiện nhất để sử dụng
tùy chọn này dành cho các nhánh chuyên đề::

$ git kiểm tra -t -b my-topical-branch master
    Chi nhánh 'my-topical-branch' được thiết lập để theo dõi 'master' chi nhánh địa phương.
    Đã chuyển sang nhánh mới 'my-topical-branch'

[thực hiện các chỉnh sửa và cam kết của bạn]

$ git format-patch --base=auto --cover-letter -o gửi đi/ chủ
    gửi đi/0000-cover-letter.patch
    gửi đi/0001-First-Commit.patch
    đi/...

Khi bạn mở ZZ0000ZZ để chỉnh sửa, bạn sẽ
lưu ý rằng nó sẽ có đoạn giới thiệu ZZ0001ZZ ngay từ đầu
dưới cùng, cung cấp cho người đánh giá và các công cụ CI đầy đủ thông tin
để thực hiện ZZ0002ZZ đúng cách mà không phải lo lắng về xung đột::

$ git kiểm tra -b xem xét bản vá [base-commit-id]
    Đã chuyển sang nhánh mới 'đánh giá bản vá'
    $ git am Patch.mbox
    Áp dụng: Cam kết đầu tiên
    Áp dụng: ...

Vui lòng xem ZZ0000ZZ để biết thêm thông tin về điều này
tùy chọn.

.. note::

    The ``--base`` feature was introduced in git version 2.9.0.

Nếu bạn không sử dụng git để định dạng các bản vá của mình, bạn vẫn có thể bao gồm
đoạn giới thiệu ZZ0000ZZ tương tự để biểu thị hàm băm xác nhận của cây
công việc của bạn dựa vào đó. Bạn nên thêm nó vào bìa
chữ cái hoặc trong bản vá đầu tiên của bộ truyện và nó nên được đặt
ở dưới dòng ZZ0001ZZ hoặc ở dưới cùng của tất cả các dòng khác
nội dung, ngay trước chữ ký email của bạn.

Đảm bảo rằng cam kết cơ sở nằm trong cây bảo trì/cây chính thức
và không phải trong một số cây nội bộ, chỉ có thể truy cập được đối với cây của bạn - nếu không thì nó
sẽ là vô giá trị.

Dụng cụ
-------

Nhiều khía cạnh kỹ thuật của quy trình này có thể được tự động hóa bằng cách sử dụng
b4, được ghi lại tại <ZZ0000ZZ Điều này có thể
trợ giúp những việc như theo dõi các phần phụ thuộc, chạy bản kiểm tra và
với việc định dạng và gửi thư.

Tài liệu tham khảo
----------

Andrew Morton, "Bản vá hoàn hảo" (tpp).
  <ZZ0000ZZ

Jeff Garzik, "Định dạng gửi bản vá nhân Linux".
  <ZZ0000ZZ

Greg Kroah-Hartman, "Làm thế nào để chọc giận người bảo trì hệ thống con kernel".
  <ZZ0000ZZ

<ZZ0000ZZ

<ZZ0000ZZ

<ZZ0000ZZ

<ZZ0000ZZ

<ZZ0000ZZ

Tài liệu hạt nhân/process/coding-style.rst

Thư của Linus Torvalds về định dạng bản vá chuẩn:
  <ZZ0000ZZ

Andi Kleen, "Về việc gửi bản vá kernel"
  Một số chiến lược để thực hiện những thay đổi khó khăn hoặc gây tranh cãi.

ZZ0000ZZ
