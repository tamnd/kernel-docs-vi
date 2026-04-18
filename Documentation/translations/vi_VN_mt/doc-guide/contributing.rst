.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/doc-guide/contributing.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Cách giúp cải thiện tài liệu kernel
========================================

Tài liệu là một phần quan trọng của bất kỳ dự án phát triển phần mềm nào.
Tài liệu tốt giúp thu hút các nhà phát triển mới và giúp thiết lập
các nhà phát triển làm việc hiệu quả hơn.  Nếu không có tài liệu chất lượng hàng đầu, rất nhiều
lãng phí thời gian vào việc thiết kế ngược mã và tạo ra những lỗi có thể tránh được
những sai lầm.

Thật không may, tài liệu của kernel hiện không đạt được những gì
nó cần phải hỗ trợ một dự án có quy mô và tầm quan trọng như thế này.

Hướng dẫn này dành cho những người đóng góp muốn cải thiện tình trạng đó.
Các cải tiến tài liệu hạt nhân có thể được thực hiện bởi các nhà phát triển ở nhiều
trình độ kỹ năng; chúng là một cách tương đối dễ dàng để tìm hiểu quy trình kernel trong
chung và tìm một vị trí trong cộng đồng.  Phần lớn những gì tiếp theo là
danh sách các nhiệm vụ cấp bách nhất của người bảo trì tài liệu
xong.

Danh sách tài liệu TODO
---------------------------

Có một danh sách vô tận các nhiệm vụ cần được thực hiện để đạt được mục tiêu của chúng ta.
tài liệu đến nơi cần đến.  Danh sách này chứa một số
những hạng mục quan trọng nhưng chưa đầy đủ; nếu bạn thấy một cách khác để
cải thiện tài liệu, xin vui lòng không giữ lại!

Giải quyết các cảnh báo
~~~~~~~~~~~~~~~~~~~

Việc xây dựng tài liệu hiện đang cung cấp một số lượng không thể tin được
cảnh báo.  Khi bạn có nhiều đến thế, bạn cũng có thể không có gì cả;
mọi người bỏ qua chúng và họ sẽ không bao giờ để ý khi công việc của họ có thêm thông tin mới
những cái đó.  Vì lý do này, việc loại bỏ các cảnh báo là một trong những ưu tiên cao nhất
nhiệm vụ trong danh sách tài liệu TODO.  Bản thân nhiệm vụ là hợp lý
đơn giản nhưng nó phải được tiếp cận một cách đúng đắn.
thành công.

Cảnh báo do trình biên dịch mã C đưa ra thường có thể bị coi là sai
tích cực, dẫn đến các bản vá nhằm mục đích đơn giản là tắt trình biên dịch.
Các cảnh báo từ quá trình xây dựng tài liệu hầu như luôn chỉ ra một vấn đề thực tế
vấn đề; làm cho những cảnh báo đó biến mất đòi hỏi phải hiểu được vấn đề
và sửa nó tại nguồn của nó.  Vì lý do này, tài liệu sửa lỗi
các cảnh báo có lẽ không nên nói "sửa cảnh báo" trong tiêu đề nhật ký thay đổi;
họ nên chỉ ra vấn đề thực sự đã được khắc phục.

Một điểm quan trọng khác là các cảnh báo tài liệu thường được tạo bởi
vấn đề trong nhận xét kerneldoc trong mã C.  Trong khi tài liệu
người bảo trì đánh giá cao việc sao chép các bản sửa lỗi cho những cảnh báo này,
cây tài liệu thường không phải là cây phù hợp để thực sự chứa những thứ đó
sửa chữa; họ nên liên hệ với người bảo trì hệ thống con được đề cập.

Ví dụ: trong quá trình xây dựng tài liệu, tôi đã nhận được một cặp cảnh báo gần như
ngẫu nhiên::

./drivers/devfreq/devfreq.c:1818: cảnh báo: dòng xấu:
  	- Devfreq_register_notifier() được quản lý tài nguyên
  ./drivers/devfreq/devfreq.c:1854: cảnh báo: dòng xấu:
	- Devfreq_unregister_notifier() được quản lý tài nguyên

(Các dòng được tách ra để dễ đọc).

Nhìn nhanh vào tệp nguồn có tên ở trên sẽ xuất hiện một vài kerneldoc
những bình luận trông như thế này::

/**
   * devm_devfreq_register_notifier()
	  - Devfreq_register_notifier() được quản lý tài nguyên
   * @dev: Thiết bị người dùng devfreq. (cha mẹ của devfreq)
   * @devfreq: Đối tượng devfreq.
   * @nb: Khối thông báo chưa được đăng ký.
   * @list: DEVFREQ_TRANSITION_NOTIFIER.
   */

Vấn đề là thiếu "*", điều này gây nhầm lẫn cho hệ thống xây dựng
ý tưởng đơn giản về hình thức của khối bình luận C.  Vấn đề này đã được
hiện diện kể từ khi nhận xét đó được thêm vào năm 2016 - tròn bốn năm.  sửa chữa
đó là vấn đề thêm các dấu hoa thị bị thiếu.  Nhìn nhanh vào
lịch sử của tập tin đó cho thấy định dạng thông thường của dòng chủ đề là gì,
và ZZ0000ZZ đã cho tôi biết ai sẽ nhận nó (chuyển đường dẫn tới
các bản vá của bạn làm đối số cho scripts/get_maintainer.pl).  Bản vá kết quả
trông như thế này::

[PATCH] PM/devfreq: Sửa hai bình luận kerneldoc không đúng định dạng

Hai nhận xét kerneldoc trong devfreq.c không tuân thủ định dạng được yêu cầu,
  dẫn đến những cảnh báo xây dựng tài liệu này:

./drivers/devfreq/devfreq.c:1818: cảnh báo: dòng xấu:
  	  - Devfreq_register_notifier() được quản lý tài nguyên
    ./drivers/devfreq/devfreq.c:1854: cảnh báo: dòng xấu:
	  - Devfreq_unregister_notifier() được quản lý tài nguyên

Thêm một vài dấu hoa thị bị thiếu và làm cho kerneldoc vui vẻ hơn một chút.

Người đăng ký: Jonathan Corbet <corbet@lwn.net>
  ---
   trình điều khiển/devfreq/devfreq.c | 4 ++--
   Đã thay đổi 1 tệp, 2 lần chèn (+), 2 lần xóa (-)

diff --git a/drivers/devfreq/devfreq.c b/drivers/devfreq/devfreq.c
  chỉ số 57f6944d65a6..00c9b80b3d33 100644
  --- a/drivers/devfreq/devfreq.c
  +++ b/drivers/devfreq/devfreq.c
  @@ -1814,7 +1814,7 @@ static void devm_devfreq_notifier_release(struct device *dev, void *res)

/**
    * devm_devfreq_register_notifier()
  - - Devfreq_register_notifier() được quản lý tài nguyên
  + * - Devfreq_register_notifier() được quản lý tài nguyên
    * @dev: Thiết bị người dùng devfreq. (cha mẹ của devfreq)
    * @devfreq: Đối tượng devfreq.
    * @nb: Khối thông báo chưa được đăng ký.
  @@ -1850,7 +1850,7 @@ EXPORT_SYMBOL(devm_devfreq_register_notifier);

/**
    * devm_devfreq_unregister_notifier()
  - - Devfreq_unregister_notifier() được quản lý tài nguyên
  + * - Devfreq_unregister_notifier() được quản lý tài nguyên
    * @dev: Thiết bị người dùng devfreq. (cha mẹ của devfreq)
    * @devfreq: Đối tượng devfreq.
    * @nb: Khối thông báo chưa được đăng ký.
  --
  2.24.1

Toàn bộ quá trình chỉ mất một vài phút.  Tất nhiên, sau đó tôi phát hiện ra rằng
ai đó đã sửa nó ở một cây riêng, đánh dấu một bài học khác:
luôn kiểm tra linux-next để xem sự cố đã được khắc phục chưa trước khi bạn đào
vào đó.

Các bản sửa lỗi khác sẽ mất nhiều thời gian hơn, đặc biệt là các bản sửa lỗi liên quan đến cấu trúc
thành viên hoặc tham số chức năng thiếu tài liệu.  Trong những trường hợp như vậy, nó
là cần thiết để tìm ra vai trò của các thành viên hoặc thông số đó là gì
và mô tả chúng một cách chính xác.  Nhìn chung, nhiệm vụ này hơi tẻ nhạt
nhiều lần, nhưng nó rất quan trọng.  Nếu chúng ta thực sự có thể loại bỏ cảnh báo
từ quá trình xây dựng tài liệu, thì chúng ta có thể bắt đầu mong đợi các nhà phát triển
tránh thêm những cái mới.

Ngoài các cảnh báo từ quá trình xây dựng tài liệu thông thường, bạn cũng có thể
chạy ZZ0000ZZ để tìm tài liệu tham khảo đến tài liệu không tồn tại
tập tin.

Bình luận kerneldoc mệt mỏi
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Các nhà phát triển được khuyến khích viết chú thích kerneldoc cho mã của họ, nhưng
nhiều nhận xét trong số đó không bao giờ được đưa vào bản dựng tài liệu.  Điều đó làm cho
thông tin này khó tìm hơn và chẳng hạn như khiến Sphinx không thể
tạo liên kết đến tài liệu đó.  Thêm chỉ thị ZZ0000ZZ vào
tài liệu để đưa những nhận xét đó vào có thể giúp cộng đồng rút ra
toàn bộ giá trị của công sức đã bỏ ra để tạo ra chúng.

Công cụ ZZ0000ZZ có thể được sử dụng để tìm những
những bình luận bị bỏ qua.

Lưu ý rằng giá trị lớn nhất đến từ việc lấy tài liệu về
các hàm và cấu trúc dữ liệu được xuất.  Nhiều hệ thống con cũng có
nhận xét kerneldoc để sử dụng nội bộ; những thứ đó không nên bị kéo vào
xây dựng tài liệu trừ khi chúng được đặt trong một tài liệu
đặc biệt nhằm vào các nhà phát triển làm việc trong hệ thống con có liên quan.


Sửa lỗi đánh máy
~~~~~~~~~~

Sửa lỗi đánh máy hoặc định dạng trong tài liệu một cách nhanh chóng
cách để tìm ra cách tạo và gửi các bản vá, và đó là một cách hữu ích
dịch vụ.  Tôi luôn sẵn sàng chấp nhận những bản vá lỗi như vậy.  Điều đó nói lên rằng, một khi bạn
đã sửa một số lỗi, vui lòng xem xét chuyển sang các tác vụ nâng cao hơn, để lại
một số lỗi chính tả để người mới bắt đầu tiếp theo giải quyết.

Xin lưu ý rằng một số lỗi chính tả của ZZ0000ZZ và không nên "sửa":

- Cho phép viết cả tiếng Anh Mỹ và tiếng Anh Anh trong
   tài liệu hạt nhân.  Không cần phải sửa một cái bằng cách thay thế nó bằng
   cái khác.

- Câu hỏi liệu một dấu chấm nên được theo sau bởi một hay hai dấu cách
   không cần phải tranh luận trong bối cảnh tài liệu hạt nhân.  Khác
   những lĩnh vực có sự bất đồng hợp lý, chẳng hạn như "dấu phẩy Oxford", cũng
   lạc đề ở đây.

Giống như bất kỳ bản vá nào cho bất kỳ dự án nào, vui lòng xem xét liệu thay đổi của bạn có phù hợp không?
thực sự làm mọi thứ tốt hơn.

Tài liệu cổ
~~~~~~~~~~~~~~~~~~~~~

Một số tài liệu kernel được cập nhật, duy trì và hữu ích.  Một số
tài liệu là ... không.  Tài liệu bụi bặm, cũ kỹ và không chính xác có thể
đánh lừa người đọc và gây nghi ngờ về toàn bộ tài liệu của chúng tôi.  Bất cứ điều gì
điều đó có thể được thực hiện để giải quyết những vấn đề như vậy là điều đáng hoan nghênh hơn.

Bất cứ khi nào bạn đang làm việc với một tài liệu, hãy xem xét liệu nó có
hiện tại, liệu nó có cần cập nhật hay không, hoặc liệu nó có nên được gỡ bỏ hay không
hoàn toàn.  Có một số dấu hiệu cảnh báo bạn có thể chú ý
tới đây:

- Tham chiếu đến hạt nhân 2.x
 - Con trỏ tới kho lưu trữ SourceForge
 - Không có gì ngoài việc sửa lỗi chính tả trong lịch sử mấy năm nay
 - Thảo luận về quy trình làm việc trước Git

Tất nhiên, điều tốt nhất nên làm là mang theo tài liệu
hiện tại, thêm bất kỳ thông tin nào là cần thiết.  Công việc như vậy thường đòi hỏi
sự hợp tác của các nhà phát triển quen thuộc với hệ thống con được đề cập, của
tất nhiên.  Các nhà phát triển thường sẵn sàng hợp tác với mọi người
làm việc để cải thiện tài liệu khi được yêu cầu một cách tử tế và khi họ
câu trả lời được lắng nghe và hành động.

Một số tài liệu nằm ngoài hy vọng; thỉnh thoảng chúng tôi tìm thấy những tài liệu
ví dụ, hãy tham khảo mã đã bị xóa khỏi kernel từ lâu.
Có sự phản đối đáng ngạc nhiên đối với việc loại bỏ tài liệu lỗi thời, nhưng chúng tôi
dù sao cũng nên làm điều đó  Hành trình bổ sung trong tài liệu của chúng tôi không giúp được ai.

Trong trường hợp có thể có một số thông tin hữu ích ở dạng đã lỗi thời
tài liệu và bạn không thể cập nhật nó, điều tốt nhất cần làm có thể là
thêm một cảnh báo ở đầu.  Văn bản sau đây được khuyến nghị::

  .. warning ::
  	This document is outdated and in need of attention.  Please use
thông tin này một cách thận trọng và vui lòng xem xét việc gửi các bản vá
	để cập nhật nó.

Bằng cách đó, ít nhất những độc giả kiên nhẫn của chúng tôi đã được cảnh báo rằng
tài liệu có thể khiến họ lạc lối.

Sự mạch lạc của tài liệu
~~~~~~~~~~~~~~~~~~~~~~~

Những người xưa ở đây sẽ nhớ những cuốn sách về Linux xuất hiện trên
các kệ vào những năm 1990.  Chúng chỉ đơn giản là bộ sưu tập tài liệu
các tập tin được thu thập từ nhiều vị trí khác nhau trên mạng.  Những cuốn sách có (hầu hết)
đã được cải thiện kể từ đó, nhưng tài liệu của kernel hầu như vẫn được xây dựng
trên mô hình đó.  Đó là hàng ngàn tập tin, hầu hết mỗi tập tin đều được viết
trong sự cô lập với tất cả những người khác.  Chúng ta không có một cơ thể thống nhất
tài liệu hạt nhân; chúng tôi có hàng ngàn tài liệu riêng lẻ.

Chúng tôi đã cố gắng cải thiện tình hình thông qua việc tạo ra
một bộ "sách" nhóm tài liệu cho những độc giả cụ thể.  Những cái này
bao gồm:

- Tài liệu/admin-guide/index.rst
 - Tài liệu/core-api/index.rst
 - Tài liệu/driver-api/index.rst
 - Tài liệu/userspace-api/index.rst

Cũng như cuốn sách này về tài liệu.

Chuyển tài liệu vào sổ sách thích hợp là một nhiệm vụ quan trọng và cần thiết
để tiếp tục.  Có một vài thách thức liên quan đến công việc này,
mặc dù.  Việc di chuyển các tập tin tài liệu tạo ra nỗi đau ngắn hạn cho người dân
ai làm việc với những tập tin đó; họ không nhiệt tình một cách dễ hiểu
những thay đổi như vậy.  Thông thường trường hợp có thể được thực hiện để di chuyển tài liệu một lần; chúng tôi
Tuy nhiên, thực sự không muốn tiếp tục thay đổi chúng.

Tuy nhiên, ngay cả khi tất cả tài liệu đều ở đúng nơi, chúng tôi chỉ có
đã biến một đống lớn thành một nhóm nhỏ hơn.  Công việc của
cố gắng kết hợp tất cả những tài liệu đó lại với nhau thành một tổng thể duy nhất chưa
vẫn chưa bắt đầu.  Nếu bạn có những ý tưởng sáng suốt về cách chúng ta có thể tiến hành trên mặt trận đó,
chúng tôi sẽ rất vui khi nghe họ.

Cải tiến biểu định kiểu
~~~~~~~~~~~~~~~~~~~~~~~

Với việc áp dụng Sphinx, chúng tôi có đầu ra HTML đẹp hơn nhiều so với chúng tôi
đã từng làm vậy.  Nhưng nó vẫn có thể có nhiều cải tiến; Donald Knuth và
Edward Tufte sẽ không mấy ấn tượng.  Điều đó đòi hỏi phải điều chỉnh bảng định kiểu của chúng tôi
để tạo ra kết quả đầu ra đúng kiểu chữ hơn, dễ tiếp cận và dễ đọc hơn.

Hãy cảnh báo: nếu bạn đảm nhận nhiệm vụ này, bạn đang tiến tới một cuộc đua xe đạp cổ điển
lãnh thổ.  Mong đợi rất nhiều ý kiến ​​và thảo luận thậm chí tương đối
những thay đổi rõ ràng.  Than ôi, đó là bản chất của thế giới chúng ta đang sống.

Bản dựng PDF không phải LaTeX
~~~~~~~~~~~~~~~~~~~

Đây rõ ràng là một nhiệm vụ không hề tầm thường đối với những người có nhiều thời gian và
Kỹ năng Python.  Chuỗi công cụ Sphinx tương đối nhỏ và tốt
chứa đựng; thật dễ dàng để thêm vào một hệ thống phát triển.  Nhưng xây dựng PDF hoặc
Đầu ra EPUB yêu cầu cài đặt LaTeX, bất cứ thứ gì ngoại trừ nhỏ hoặc tốt
chứa đựng.  Đó sẽ là một điều tốt đẹp để loại bỏ.

Hy vọng ban đầu là sử dụng công cụ rst2pdf (ZZ0000ZZ
cho thế hệ PDF, nhưng hóa ra nó không đáp ứng được nhiệm vụ.
Công việc phát triển trên rst2pdf dường như đã được tiến hành trở lại trong thời gian gần đây,
mặc dù vậy, đó là một dấu hiệu đầy hy vọng.  Nếu một nhà phát triển có động lực phù hợp muốn
làm việc với dự án đó để rst2pdf hoạt động với tài liệu kernel
xây dựng, thế giới sẽ mãi mãi biết ơn.

Viết thêm tài liệu
~~~~~~~~~~~~~~~~~~~~~~~~

Đương nhiên, có những phần lớn của hạt nhân bị ảnh hưởng nghiêm trọng.
không có đủ giấy tờ.  Nếu bạn có kiến thức để ghi lại một hạt nhân cụ thể
hệ thống con và mong muốn làm như vậy, vui lòng thực hiện một số
viết và đóng góp kết quả vào kernel.  Số lượng kernel chưa kể
nhà phát triển và người dùng sẽ cảm ơn bạn.