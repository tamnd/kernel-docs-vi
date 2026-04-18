.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/researcher-guidelines.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _researcher_guidelines:

Hướng dẫn dành cho nhà nghiên cứu
+++++++++++++++++++++

Cộng đồng nhân Linux hoan nghênh nghiên cứu minh bạch về Linux
hạt nhân, các hoạt động liên quan đến việc sản xuất nó và bất kỳ sản phẩm phụ nào khác
sự phát triển của nó. Linux được hưởng lợi rất nhiều từ loại nghiên cứu này, và
hầu hết các khía cạnh của Linux đều được thúc đẩy bởi nghiên cứu dưới hình thức này hay hình thức khác.

Cộng đồng đánh giá rất cao nếu các nhà nghiên cứu có thể chia sẻ sơ bộ
những phát hiện trước khi công bố kết quả của họ, đặc biệt nếu nghiên cứu đó
liên quan đến an ninh. Tham gia sớm giúp cả hai nâng cao chất lượng
nghiên cứu và khả năng để Linux cải tiến từ nó. Trong mọi trường hợp,
chia sẻ các bản sao truy cập mở của nghiên cứu đã xuất bản với cộng đồng
được khuyến khích.

Tài liệu này tìm cách làm rõ những gì cộng đồng nhân Linux xem xét
những thực hành có thể chấp nhận được và không thể chấp nhận được khi tiến hành nghiên cứu đó. Tại
ít nhất, những hoạt động nghiên cứu và liên quan như vậy phải tuân theo
quy tắc đạo đức nghiên cứu tiêu chuẩn. Để biết thêm thông tin cơ bản về đạo đức nghiên cứu
nói chung, đạo đức trong công nghệ và nghiên cứu của cộng đồng nhà phát triển
cụ thể, xem:

* ZZ0000ZZ
* ZZ0001ZZ
* ZZ0002ZZ

Cộng đồng nhân Linux mong đợi rằng mọi người tương tác với
dự án đang tham gia một cách thiện chí để làm cho Linux tốt hơn. Nghiên cứu về
bất kỳ tạo phẩm nào có sẵn công khai (bao gồm nhưng không giới hạn ở nguồn
code) do cộng đồng nhân Linux tạo ra đều được hoan nghênh, mặc dù nghiên cứu
đối với các nhà phát triển phải được chọn tham gia một cách rõ ràng.

Nghiên cứu thụ động hoàn toàn dựa trên các nguồn có sẵn công khai,
bao gồm các bài đăng vào danh sách gửi thư công khai và cam kết công khai
kho lưu trữ, rõ ràng là được cho phép. Mặc dù, giống như bất kỳ nghiên cứu nào,
chuẩn mực đạo đức vẫn phải được tuân theo.

Tuy nhiên, nghiên cứu tích cực về hành vi của nhà phát triển phải được thực hiện với
thỏa thuận rõ ràng và tiết lộ đầy đủ cho các nhà phát triển cá nhân
có liên quan. Các nhà phát triển không thể tương tác/thử nghiệm mà không có
sự đồng ý; đây cũng là đạo đức nghiên cứu tiêu chuẩn.

Khảo sát
=======

Nghiên cứu thường diễn ra dưới hình thức khảo sát gửi đến người bảo trì hoặc
những người đóng góp.  Tuy nhiên, theo nguyên tắc chung, cộng đồng hạt nhân bắt nguồn từ
ít giá trị từ những cuộc khảo sát này.  Quá trình phát triển kernel hoạt động
bởi vì mọi nhà phát triển đều được hưởng lợi từ sự tham gia của họ, thậm chí làm việc
với những người có mục tiêu khác.  Tuy nhiên, việc trả lời một cuộc khảo sát là một
nhu cầu một chiều đặt lên những nhà phát triển bận rộn không có lợi ích tương ứng cho
bản thân họ hoặc cho toàn bộ cộng đồng hạt nhân.  Vì lý do này, điều này
phương pháp nghiên cứu không được khuyến khích.

Các thành viên cộng đồng hạt nhân đã nhận được quá nhiều email và có khả năng
coi các yêu cầu khảo sát chỉ là một nhu cầu khác về thời gian của họ.  Đang gửi
những yêu cầu như vậy làm mất đi thời gian đóng góp có giá trị của cộng đồng và
khó có thể mang lại phản hồi hữu ích về mặt thống kê.

Thay vào đó, các nhà nghiên cứu nên xem xét việc tham dự các sự kiện dành cho nhà phát triển,
tổ chức các phiên trong đó dự án nghiên cứu và lợi ích của nó đối với
người tham gia có thể được giải thích và tương tác trực tiếp với cộng đồng
ở đó.  Thông tin nhận được sẽ phong phú hơn nhiều so với thông tin thu được từ
một cuộc khảo sát qua email và cộng đồng sẽ có được khả năng học hỏi từ
những hiểu biết sâu sắc của bạn là tốt.

Bản vá lỗi
=======

Để giúp làm rõ: gửi bản vá cho nhà phát triển tương tác ZZ0000ZZ
với họ, nhưng họ đã đồng ý nhận *thiện chí
đóng góp*. Cố tình gửi các bản vá thiếu sót/dễ bị tổn thương hoặc
đóng góp thông tin sai lệch vào các cuộc thảo luận không được chấp thuận
đến. Việc giao tiếp như vậy có thể gây tổn hại cho nhà phát triển (ví dụ: làm cạn kiệt
thời gian, công sức và tinh thần) và gây tổn hại cho dự án bằng cách làm xói mòn
sự tin tưởng của toàn bộ cộng đồng nhà phát triển vào người đóng góp (và
tổ chức của người đóng góp nói chung), làm suy yếu những nỗ lực cung cấp
phản hồi mang tính xây dựng cho những người đóng góp và khiến người dùng cuối có nguy cơ bị
lỗi phần mềm.

Sự tham gia vào quá trình phát triển Linux của chính các nhà nghiên cứu, cũng như
với bất kỳ ai, đều được hoan nghênh và khuyến khích. Nghiên cứu về mã Linux là
một thực tế phổ biến, đặc biệt là khi phát triển hoặc chạy
công cụ phân tích tạo ra kết quả có thể thực hiện được.

Khi tương tác với cộng đồng nhà phát triển, việc gửi bản vá có
theo truyền thống là cách tốt nhất để tạo ra tác động. Linux đã có rồi
rất nhiều lỗi đã biết -- điều hữu ích hơn nhiều là có các bản sửa lỗi đã được hiệu đính.
Trước khi đóng góp, hãy đọc kỹ tài liệu thích hợp:

* Tài liệu/quy trình/phát triển-process.rst
* Tài liệu/quy trình/gửi-patches.rst
* Tài liệu/admin-guide/reporting-issues.rst
* Tài liệu/quy trình/security-bugs.rst

Sau đó gửi một bản vá (bao gồm nhật ký cam kết với tất cả các chi tiết được liệt kê
bên dưới) và theo dõi mọi phản hồi từ các nhà phát triển khác.

Khi gửi các bản vá được tạo ra từ nghiên cứu, nhật ký cam kết phải
chứa ít nhất các chi tiết sau để các nhà phát triển có
bối cảnh thích hợp để hiểu sự đóng góp. Trả lời:

* Vấn đề cụ thể đã được tìm thấy là gì?
* Làm thế nào có thể đạt được sự cố trên hệ thống đang chạy?
* Việc gặp sự cố có ảnh hưởng gì đến hệ thống?
* Vấn đề được phát hiện như thế nào? Cụ thể bao gồm chi tiết về bất kỳ
  chương trình thử nghiệm, phân tích tĩnh hoặc động và bất kỳ công cụ hoặc
  các phương pháp được sử dụng để thực hiện công việc.
* Vấn đề được phát hiện trên phiên bản Linux nào? Sử dụng gần đây nhất
  phát hành hoặc một nhánh linux-next gần đây được ưu tiên hơn (xem
  Tài liệu/quy trình/howto.rst).
* Điều gì đã được thay đổi để khắc phục vấn đề và tại sao nó được cho là đúng?
* Bản dựng thay đổi được thử nghiệm và thử nghiệm trong thời gian chạy như thế nào?
* Thay đổi này khắc phục được cam kết nào trước đó? Điều này sẽ có trong phần "Sửa lỗi:"
  thẻ như tài liệu mô tả.
* Ai khác đã xem lại bản vá này? Điều này sẽ diễn ra phù hợp
  Thẻ "Được đánh giá bởi:"; xem bên dưới.

Ví dụ::

Từ: Tác giả <tác giả@email>
  Chủ đề: [PATCH] driver/foo_bar: Thêm kfree() bị thiếu

Đường dẫn lỗi trong trình điều khiển foo_bar không giải phóng chính xác vùng được phân bổ
  cấu trúc foo_bar_info. Điều này có thể xảy ra nếu thiết bị foo_bar được đính kèm
  từ chối các gói khởi tạo được gửi trong foo_bar_probe(). Cái này
  sẽ dẫn đến rò rỉ bộ nhớ phiến 64 byte một lần cho mỗi thiết bị đính kèm,
  lãng phí tài nguyên bộ nhớ theo thời gian.

Lỗ hổng này được phát hiện bằng công cụ phân tích tĩnh thử nghiệm mà chúng tôi đang
  đang phát triển, LeakMagic[1], đã đưa ra cảnh báo sau khi
  phân tích bản phát hành kernel v5.15:

path/to/foo_bar.c:187: thiếu cuộc gọi kfree()?

Thêm kfree() bị thiếu vào đường dẫn lỗi. Không có tài liệu tham khảo nào khác đến
  bộ nhớ này tồn tại bên ngoài chức năng thăm dò, vì vậy đây là bộ nhớ duy nhất
  nơi nó có thể được giải phóng.

Bản dựng defconfig x86_64 và arm64 với CONFIG_FOO_BAR=y sử dụng GCC
  11.2 không hiển thị cảnh báo mới và LeakMagic không còn cảnh báo về điều này nữa
  đường dẫn mã. Vì chúng tôi không có thiết bị FooBar để kiểm tra nên không có thời gian chạy
  thử nghiệm đã có thể được thực hiện.

[1] ZZ0000ZZ

Người báo cáo: Nhà nghiên cứu <researcher@email>
  Sửa lỗi: aaaabbbbccccdddd ("Giới thiệu hỗ trợ cho FooBar")
  Người ký tên: Tác giả <author@email>
  Người đánh giá: Người đánh giá <reviewer@email>

Nếu bạn là người đóng góp lần đầu tiên thì bản vá nên
bản thân nó sẽ được người khác xem xét riêng trước khi đăng lên danh sách công khai.
(Điều này là bắt buộc nếu bạn đã được thông báo rõ ràng rằng các bản vá của bạn cần
xem xét nội bộ cẩn thận hơn.) Những người này được kỳ vọng sẽ có
Thẻ "Được đánh giá bởi" được bao gồm trong bản vá kết quả. Tìm người khác
nhà phát triển quen thuộc với sự đóng góp của Linux, đặc biệt là trong chính bạn
tổ chức và nhờ họ giúp đánh giá trước khi gửi chúng đến
danh sách gửi thư công cộng có xu hướng cải thiện đáng kể chất lượng của
tạo ra các bản vá và nhờ đó giảm bớt gánh nặng cho các nhà phát triển khác.

Nếu không thể tìm thấy ai để xem xét nội bộ các bản vá và bạn cần
giúp tìm người như vậy hoặc nếu bạn có bất kỳ câu hỏi nào khác
liên quan đến tài liệu này và mong đợi của cộng đồng nhà phát triển,
vui lòng liên hệ với danh sách gửi thư riêng của Ban cố vấn kỹ thuật:
<tech-board@groups.linuxfoundation.org>.