.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/xfs/xfs-online-fsck-design.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _xfs_online_fsck_design:

..
        Mapping of heading styles within this document:
        Heading 1 uses "====" above and below
        Heading 2 uses "===="
        Heading 3 uses "----"
        Heading 4 uses "````"
        Heading 5 uses "^^^^"
        Heading 6 uses "~~~~"
        Heading 7 uses "...."

        Sections are manually numbered because apparently that's what everyone
        does in the kernel.

============================
XFS Thiết kế Fsck trực tuyến
============================

Tài liệu này ghi lại thiết kế của tính năng kiểm tra hệ thống tập tin trực tuyến cho
XFS.
Mục đích của tài liệu này gồm ba phần:

- Để giúp các nhà phân phối kernel hiểu chính xác fsck trực tuyến XFS là gì
  đặc điểm và các vấn đề mà họ cần biết.

- Để giúp người đọc mã làm quen với các thuật ngữ liên quan
  các khái niệm và điểm thiết kế trước khi bắt đầu đào sâu vào mã.

- Giúp các nhà phát triển duy trì hệ thống bằng cách nắm bắt các lý do
  hỗ trợ việc ra quyết định ở cấp cao hơn.

Khi mã fsck trực tuyến được hợp nhất, các liên kết trong tài liệu này đến các nhánh chủ đề
sẽ được thay thế bằng các liên kết tới mã.

Tài liệu này được cấp phép theo các điều khoản của Giấy phép Công cộng GNU, v2.
Tác giả chính là Darrick J. Wong.

Tài liệu thiết kế này được chia thành bảy phần.
Phần 1 định nghĩa công cụ fsck là gì và động lực để viết một công cụ mới.
Phần 2 và 3 trình bày tổng quan cấp cao về cách hoạt động của quy trình fsck trực tuyến
và cách nó được kiểm tra để đảm bảo hoạt động chính xác.
Phần 4 thảo luận về giao diện người dùng và các chế độ sử dụng dự kiến của phiên bản mới
chương trình.
Phần 5 và 6 trình bày các thành phần cấp cao và cách chúng khớp với nhau, đồng thời
sau đó trình bày các nghiên cứu điển hình về cách thức hoạt động thực sự của từng chức năng sửa chữa.
Phần 7 tóm tắt những gì đã được thảo luận cho đến nay và suy đoán về những gì khác
có thể được xây dựng trên fsck trực tuyến.

.. contents:: Table of Contents
   :local:

1. Kiểm tra hệ thống tập tin là gì?
==============================

Một hệ thống tập tin Unix có bốn trách nhiệm chính:

- Cung cấp một hệ thống phân cấp tên thông qua đó các chương trình ứng dụng có thể liên kết
  các khối dữ liệu tùy ý trong bất kỳ khoảng thời gian nào,

- Ảo hóa phương tiện lưu trữ vật lý trên các tên đó và

- Truy xuất các đốm màu dữ liệu được đặt tên bất cứ lúc nào.

- Kiểm tra việc sử dụng tài nguyên.

Siêu dữ liệu hỗ trợ trực tiếp các chức năng này (ví dụ: tệp, thư mục, dấu cách
ánh xạ) đôi khi được gọi là siêu dữ liệu chính.
Hỗ trợ siêu dữ liệu thứ cấp (ví dụ: ánh xạ ngược và con trỏ thư mục gốc)
các hoạt động nội bộ của hệ thống tập tin, chẳng hạn như kiểm tra tính nhất quán nội bộ
và tổ chức lại.
Siêu dữ liệu tóm tắt, như tên gọi của nó, cô đọng thông tin chứa trong
siêu dữ liệu chính vì lý do hiệu suất.

Công cụ kiểm tra hệ thống tệp (fsck) kiểm tra tất cả siêu dữ liệu trong hệ thống tệp
để tìm kiếm lỗi.
Ngoài việc tìm kiếm các lỗi siêu dữ liệu rõ ràng, fsck còn
tham chiếu chéo các loại bản ghi siêu dữ liệu khác nhau với nhau để xem xét
vì sự không nhất quán.
Mọi người không thích mất dữ liệu nên hầu hết các công cụ fsck cũng chứa một số khả năng
để khắc phục mọi vấn đề được tìm thấy.
Xin lưu ý -- mục tiêu chính của hầu hết các công cụ fsck Linux là khôi phục
siêu dữ liệu hệ thống tập tin ở trạng thái nhất quán, không tối đa hóa dữ liệu
đã hồi phục.
Tiền lệ đó sẽ không bị thách thức ở đây.

Các hệ thống tập tin của thế kỷ 20 nói chung không có bất kỳ phần dư thừa nào trong ondisk
định dạng, có nghĩa là fsck chỉ có thể phản hồi lỗi bằng cách xóa các tệp cho đến khi
lỗi không còn được phát hiện.
Các thiết kế hệ thống tập tin gần đây hơn chứa đủ dữ liệu dư thừa trong siêu dữ liệu của chúng để
giờ đây có thể tạo lại cấu trúc dữ liệu khi xảy ra lỗi không nghiêm trọng
xảy ra; khả năng này hỗ trợ cả hai chiến lược.

+-----------------------------------------------------------------------------------+
ZZ0001ZZ
+-----------------------------------------------------------------------------------+
ZZ0002ZZ
ZZ0003ZZ
ZZ0004ZZ
ZZ0005ZZ
ZZ0006ZZ
+-----------------------------------------------------------------------------------+

TLDR; Cho tôi xem mã!
-----------------------

Mã hạt nhân và không gian người dùng đã được hợp nhất hoàn toàn kể từ tháng 10 năm 2025.

Mỗi bản vá kernel thêm chức năng sửa chữa trực tuyến sẽ sử dụng cùng một nhánh
tên trên kernel, xfsprogs và fstests git repos.

Công cụ hiện có
--------------

Công cụ fsck trực tuyến được mô tả ở đây sẽ là công cụ thứ ba trong lịch sử
XFS (trên Linux) để kiểm tra và sửa chữa hệ thống tập tin.
Hai chương trình đi trước nó:

Chương trình đầu tiên, ZZ0000ZZ, được tạo như một phần của trình gỡ lỗi XFS
(ZZ0001ZZ) và chỉ có thể được sử dụng với các hệ thống tệp chưa được gắn kết.
Nó duyệt tất cả siêu dữ liệu trong hệ thống tập tin để tìm kiếm sự không nhất quán trong
siêu dữ liệu, mặc dù nó không có khả năng sửa chữa những gì nó tìm thấy.
Do yêu cầu bộ nhớ cao và không có khả năng sửa chữa mọi thứ, điều này
chương trình hiện không còn được dùng nữa và sẽ không được thảo luận thêm.

Chương trình thứ hai, ZZ0000ZZ, được tạo ra để nhanh hơn và mạnh mẽ hơn
hơn chương trình đầu tiên.
Giống như người tiền nhiệm của nó, nó chỉ có thể được sử dụng với các hệ thống tập tin chưa được gắn kết.
Nó sử dụng cấu trúc dữ liệu trong bộ nhớ dựa trên phạm vi để giảm mức tiêu thụ bộ nhớ,
và cố gắng lên lịch IO đọc trước một cách thích hợp để giảm thời gian chờ đợi I/O
trong khi nó quét siêu dữ liệu của toàn bộ hệ thống tập tin.
Tính năng quan trọng nhất của công cụ này là khả năng đáp ứng
sự không nhất quán trong siêu dữ liệu tệp và cây thư mục bằng cách xóa những thứ cần thiết
để loại bỏ các vấn đề.
Siêu dữ liệu sử dụng không gian được xây dựng lại từ siêu dữ liệu tệp được quan sát.

Tuyên bố vấn đề
-----------------

Các công cụ XFS hiện tại vẫn chưa giải quyết được một số vấn đề:

1. ZZ0000ZZ bất ngờ chuyển sang hệ thống tập tin ZZ0001ZZ khi không mong muốn
   tắt máy xảy ra do lỗi thầm lặng trong siêu dữ liệu.
   Những điều này xảy ra với ZZ0002ZZ và thường không có cảnh báo.

2. ZZ0000ZZ trải nghiệm ZZ0001ZZ trong thời gian phục hồi
   sau khi xảy ra ZZ0002ZZ.

3. ZZ0000ZZ trải nghiệm ZZ0001ZZ nếu hệ thống tập tin bị lấy
   ngoại tuyến tới ZZ0002ZZ một cách chủ động.

4. ZZ0000ZZ không thể ZZ0001ZZ dữ liệu được lưu trữ của họ mà không có
   đọc tất cả của nó.
   Điều này có thể khiến họ phải chịu chi phí thanh toán đáng kể khi quét phương tiện tuyến tính
   được thực hiện bởi quản trị viên hệ thống lưu trữ có thể đủ.

5. ZZ0000ZZ không thể xử lý ZZ0001ZZ một cửa sổ bảo trì
   bị hỏng nếu họ dùng ZZ0002ZZ để đánh giá tình trạng hệ thống tập tin
   trong khi hệ thống tập tin đang trực tuyến.

6. ZZ0000ZZ không thể ZZ0001ZZ của hệ thống tập tin
   sức khỏe khi làm như vậy cần có ZZ0002ZZ và thời gian ngừng hoạt động.

7. ZZ0000ZZ có thể bị lừa vào ZZ0001ZZ khi
   Tác nhân độc hại ZZ0002ZZ đặt tên gây hiểu lầm
   trong các thư mục.

Với định nghĩa này về các vấn đề cần giải quyết và các tác nhân sẽ
lợi ích, giải pháp được đề xuất là công cụ fsck thứ ba hoạt động trên hệ thống đang chạy
hệ thống tập tin.

Chương trình thứ ba mới này có ba thành phần: một cơ sở trong kernel để kiểm tra
siêu dữ liệu, cơ sở trong hạt nhân để sửa chữa siêu dữ liệu và trình điều khiển không gian người dùng
chương trình điều khiển hoạt động fsck trên hệ thống tập tin trực tiếp.
ZZ0000ZZ là tên của chương trình điều khiển.
Phần còn lại của tài liệu này trình bày các mục tiêu và trường hợp sử dụng của fsck mới
công cụ, mô tả các điểm thiết kế chính của nó liên quan đến các mục tiêu đó và
thảo luận về những điểm tương đồng và khác biệt với các công cụ hiện có.

+-----------------------------------------------------------------------------------+
ZZ0003ZZ
+-----------------------------------------------------------------------------------+
ZZ0004ZZ
ZZ0005ZZ
ZZ0006ZZ
ZZ0007ZZ
ZZ0008ZZ
ZZ0009ZZ
ZZ0010ZZ
+-----------------------------------------------------------------------------------+

Hệ thống phân cấp đặt tên được chia thành các đối tượng được gọi là thư mục và tệp
và không gian vật lý được chia thành các phần được gọi là nhóm phân bổ.
Sharding cho phép thực hiện tốt hơn trên các hệ thống song song cao và giúp
chứa đựng những thiệt hại khi tham nhũng xảy ra.
Việc phân chia hệ thống tập tin thành các đối tượng chính (nhóm phân bổ và
inodes) có nghĩa là có nhiều cơ hội để thực hiện kiểm tra có chủ đích và
sửa chữa trên một tập hợp con của hệ thống tập tin.

Trong khi điều này đang diễn ra, các bộ phận khác vẫn tiếp tục xử lý các yêu cầu IO.
Ngay cả khi một phần siêu dữ liệu của hệ thống tập tin chỉ có thể được tạo lại bằng cách quét
toàn bộ hệ thống, quá trình quét vẫn có thể được thực hiện ở chế độ nền trong khi tệp khác
hoạt động tiếp tục.

Tóm lại, fsck trực tuyến tận dụng lợi thế của việc phân chia tài nguyên và dư thừa
siêu dữ liệu để cho phép các hoạt động kiểm tra và sửa chữa có mục tiêu trong khi hệ thống
đang chạy.
Khả năng này sẽ được kết hợp với quản lý hệ thống tự động để
khả năng tự phục hồi tự động của XFS tối đa hóa tính khả dụng của dịch vụ.

2. Lý thuyết hoạt động
======================

Vì fsck trực tuyến cần khóa và quét các đối tượng siêu dữ liệu trực tiếp,
fsck trực tuyến bao gồm ba thành phần mã riêng biệt.
Đầu tiên là chương trình điều khiển không gian người dùng ZZ0000ZZ, chịu trách nhiệm
để xác định các mục siêu dữ liệu riêng lẻ, lên lịch các mục công việc cho chúng,
phản ứng với kết quả một cách thích hợp và báo cáo kết quả lên hệ thống
quản trị viên.
Cái thứ hai và thứ ba nằm trong kernel, thực hiện các chức năng để kiểm tra
và sửa chữa từng loại hạng mục công việc fsck trực tuyến.

+--------------------------------------------------------------------------------+
ZZ0001ZZ
+--------------------------------------------------------------------------------+
ZZ0002ZZ
ZZ0003ZZ
+--------------------------------------------------------------------------------+

Các loại mục chà được mô tả theo cách phù hợp với thiết kế Unix
triết lý, có nghĩa là mỗi mục nên xử lý một khía cạnh của một
cấu trúc siêu dữ liệu và xử lý nó tốt.

Phạm vi
-----

Về nguyên tắc, fsck trực tuyến sẽ có thể kiểm tra và sửa chữa mọi thứ
chương trình fsck ngoại tuyến có thể xử lý.
Tuy nhiên, fsck trực tuyến không thể chạy 100% thời gian, điều đó có nghĩa là
các lỗi tiềm ẩn có thể xuất hiện sau khi quá trình quét hoàn tất.
Nếu những lỗi này khiến lần gắn kết tiếp theo không thành công thì fsck ngoại tuyến là cách duy nhất
giải pháp.
Hạn chế này có nghĩa là việc bảo trì công cụ fsck ngoại tuyến sẽ tiếp tục.
Hạn chế thứ hai của fsck trực tuyến là nó phải tuân theo cùng một tài nguyên
chia sẻ và khóa các quy tắc thu thập như hệ thống tập tin thông thường.
Điều này có nghĩa là chà không thể dùng phím tắt ZZ0002ZZ để tiết kiệm thời gian, vì thực hiện
vì vậy có thể dẫn đến các vấn đề tương tranh.
Nói cách khác, fsck trực tuyến không phải là sự thay thế hoàn toàn cho fsck ngoại tuyến và
một lần chạy fsck trực tuyến hoàn chỉnh có thể mất nhiều thời gian hơn fsck ngoại tuyến.
Tuy nhiên, cả hai hạn chế này đều là sự đánh đổi có thể chấp nhận được để đáp ứng
động lực khác nhau của fsck trực tuyến, đó là ZZ0000ZZ
và tới ZZ0001ZZ.

.. _scrubphases:

Các giai đoạn công việc
--------------

Chương trình trình điều khiển không gian người dùng ZZ0000ZZ chia nhỏ công việc kiểm tra và
sửa chữa toàn bộ hệ thống tập tin thành bảy giai đoạn.
Mỗi giai đoạn tập trung vào việc kiểm tra các loại hạng mục chà cụ thể và phụ thuộc vào
về sự thành công của tất cả các giai đoạn trước đó.
Bảy giai đoạn như sau:

1. Thu thập thông tin hình học về hệ thống tập tin được gắn và máy tính,
   khám phá các khả năng fsck trực tuyến của kernel và mở
   các thiết bị lưu trữ cơ bản.

2. Kiểm tra siêu dữ liệu nhóm phân bổ, tất cả siêu dữ liệu khối lượng thời gian thực và tất cả hạn ngạch
   tập tin.
   Mỗi cấu trúc siêu dữ liệu được lên lịch dưới dạng một mục xóa riêng biệt.
   Nếu tìm thấy lỗi trong tiêu đề inode hoặc inode btree và ZZ0000ZZ
   được phép thực hiện sửa chữa thì những hạng mục đó sẽ được sửa chữa để
   chuẩn bị cho giai đoạn 3.
   Việc sửa chữa được thực hiện bằng cách sử dụng thông tin trong mục chà để
   gửi lại cuộc gọi chà kernel với cờ sửa chữa được bật; đây là
   được thảo luận trong phần tiếp theo.
   Việc tối ưu hóa và tất cả các sửa chữa khác được hoãn lại sang giai đoạn 4.

3. Kiểm tra tất cả siêu dữ liệu của mọi tệp trong hệ thống tệp.
   Mỗi cấu trúc siêu dữ liệu cũng được lên lịch dưới dạng một mục xóa riêng biệt.
   Nếu cần sửa chữa và ZZ0000ZZ được phép thực hiện sửa chữa,
   và không có vấn đề nào được phát hiện trong giai đoạn 2, thì những mục đã được xử lý đó
   được sửa chữa ngay lập tức.
   Việc tối ưu hóa, sửa chữa bị trì hoãn và sửa chữa không thành công được hoãn lại
   giai đoạn 4.

4. Tất cả các sửa chữa còn lại và tối ưu hóa theo lịch trình sẽ được thực hiện trong thời gian này.
   giai đoạn, nếu người gọi cho phép họ.
   Trước khi bắt đầu sửa chữa, bộ đếm tóm tắt được kiểm tra và mọi thông tin cần thiết
   việc sửa chữa được thực hiện sao cho những lần sửa chữa tiếp theo sẽ không làm hỏng tài nguyên
   bước đặt trước do bộ đếm tóm tắt cực kỳ không chính xác.
   Những sửa chữa không thành công sẽ được xếp hàng đợi miễn là tiến độ sửa chữa tiếp theo được đáp ứng.
   được thực hiện ở đâu đó trong hệ thống tập tin.
   Dung lượng trống trong hệ thống tập tin sẽ bị cắt bớt vào cuối giai đoạn 4 nếu
   hệ thống tập tin sạch sẽ.

5. Khi bắt đầu giai đoạn này, tất cả siêu dữ liệu hệ thống tệp chính và phụ
   phải đúng.
   Các bộ đếm tóm tắt như số lượng không gian trống và số lượng tài nguyên hạn ngạch
   được kiểm tra và sửa chữa.
   Tên mục nhập thư mục và tên thuộc tính mở rộng được kiểm tra
   các mục đáng ngờ như ký tự điều khiển hoặc chuỗi Unicode khó hiểu
   xuất hiện trong những cái tên

6. Nếu người gọi yêu cầu quét phương tiện, hãy đọc tất cả dữ liệu được phân bổ và ghi
   phạm vi tập tin trong hệ thống tập tin.
   Khả năng sử dụng tính năng kiểm tra tính toàn vẹn của tệp dữ liệu được hỗ trợ bằng phần cứng là tính năng mới
   tới fsck trực tuyến; cả hai công cụ trước đây đều không có khả năng này.
   Nếu xảy ra lỗi phương tiện, chúng sẽ được ánh xạ tới các tệp sở hữu và được báo cáo.

7. Kiểm tra lại bộ đếm tóm tắt và đưa cho người gọi bản tóm tắt về
   sử dụng không gian và số lượng tập tin.

Việc phân bổ trách nhiệm này sẽ là ZZ0000ZZ
sau này trong tài liệu này.

Các bước cho từng hạng mục chà
-------------------------

Mã chà kernel sử dụng chiến lược ba bước để kiểm tra và sửa chữa
một khía cạnh của đối tượng siêu dữ liệu được biểu thị bằng mục chà:

1. Mục chà quan tâm được kiểm tra xem có bị hỏng không; cơ hội cho
   tối ưu hóa; và đối với các giá trị được hệ thống điều khiển trực tiếp
   quản trị viên nhưng có vẻ nghi ngờ.
   Nếu mục này không bị hỏng hoặc không cần tối ưu hóa, tài nguyên sẽ được
   được phát hành và kết quả quét dương tính sẽ được trả về không gian người dùng.
   Nếu mục bị hỏng hoặc có thể được tối ưu hóa nhưng người gọi không cho phép
   điều này, tài nguyên được giải phóng và kết quả quét âm tính được trả về
   không gian người dùng.
   Nếu không, kernel sẽ chuyển sang bước thứ hai.

2. Hàm sửa chữa được gọi để xây dựng lại cấu trúc dữ liệu.
   Các chức năng sửa chữa thường chọn xây dựng lại cấu trúc từ siêu dữ liệu khác
   thay vì cố gắng cứu vãn cấu trúc hiện có.
   Nếu việc sửa chữa không thành công, kết quả quét từ bước đầu tiên sẽ được trả về
   không gian người dùng.
   Ngược lại, kernel sẽ chuyển sang bước thứ ba.

3. Ở bước thứ ba, kernel chạy các bước kiểm tra tương tự đối với siêu dữ liệu mới
   để đánh giá hiệu quả của việc sửa chữa.
   Kết quả đánh giá lại được trả về không gian người dùng.

Phân loại siêu dữ liệu
--------------------------

Mỗi loại đối tượng siêu dữ liệu (và do đó, mỗi loại mục chà) là
được phân loại như sau:

Siêu dữ liệu chính
````````````````

Cấu trúc siêu dữ liệu trong danh mục này phải quen thuộc nhất với hệ thống tập tin
người dùng vì họ được người dùng trực tiếp tạo ra hoặc họ lập chỉ mục
đối tượng do người dùng tạo
Hầu hết các đối tượng hệ thống tập tin đều thuộc lớp này:

- Không gian trống và thông tin về số lượng tài liệu tham khảo

- Bản ghi và chỉ mục Inode

- Thông tin ánh xạ lưu trữ cho dữ liệu tệp

- Thư mục

- Thuộc tính mở rộng

- Liên kết tượng trưng

- Giới hạn hạn ngạch

Scrub tuân theo các quy tắc tương tự như truy cập hệ thống tập tin thông thường để lấy tài nguyên và khóa
mua lại.

Các đối tượng siêu dữ liệu chính là đối tượng đơn giản nhất để xử lý.
Đối tượng hệ thống tập tin chính (nhóm phân bổ hoặc inode)
sở hữu mục đang bị xóa sẽ bị khóa để bảo vệ khỏi các bản cập nhật đồng thời.
Chức năng kiểm tra sẽ kiểm tra mọi bản ghi liên quan đến loại để biết rõ ràng
lỗi và tham chiếu chéo các hồ sơ lành mạnh với siêu dữ liệu khác để tìm kiếm
sự không nhất quán.
Việc sửa chữa loại hạng mục chà này rất đơn giản vì chức năng sửa chữa
bắt đầu bằng cách giữ tất cả các tài nguyên có được ở bước trước.
Chức năng sửa chữa quét siêu dữ liệu có sẵn khi cần thiết để ghi lại tất cả
quan sát cần thiết để hoàn thành cấu trúc.
Tiếp theo, nó thực hiện các quan sát trong cấu trúc ondisk mới và cam kết nó
nguyên tử để hoàn thành việc sửa chữa.
Cuối cùng, việc lưu trữ từ cấu trúc dữ liệu cũ được thu thập một cách cẩn thận.

Vì ZZ0000ZZ khóa đối tượng chính trong suốt thời gian sửa chữa,
đây thực sự là một hoạt động sửa chữa ngoại tuyến được thực hiện trên một tập hợp con của
hệ thống tập tin.
Điều này giảm thiểu độ phức tạp của mã sửa chữa vì không cần thiết phải
xử lý các cập nhật đồng thời từ các luồng khác và cũng không cần thiết phải truy cập
bất kỳ phần nào khác của hệ thống tập tin.
Kết quả là các cấu trúc được lập chỉ mục có thể được xây dựng lại rất nhanh chóng và các chương trình
cố gắng truy cập vào cấu trúc bị hư hỏng sẽ bị chặn cho đến khi việc sửa chữa hoàn tất.
Cơ sở hạ tầng duy nhất cần thiết cho mã sửa chữa là khu vực tổ chức cho
quan sát và một phương tiện để ghi cấu trúc mới vào đĩa.
Bất chấp những hạn chế này, lợi thế mà việc sửa chữa trực tuyến mang lại là rất rõ ràng:
công việc được nhắm mục tiêu trên các phân đoạn riêng lẻ của hệ thống tập tin sẽ tránh được việc mất toàn bộ
dịch vụ.

Cơ chế này được mô tả trong phần 2.1 ("Thuật toán ngoại tuyến") của
V. Srinivasan và M. J. Carey, ZZ0000ZZ,
ZZ0001ZZ, trang 293-309, 1992.

Hầu hết các chức năng sửa chữa siêu dữ liệu chính đều sắp xếp các kết quả trung gian của chúng theo một
mảng trong bộ nhớ trước khi định dạng cấu trúc ondisk mới, điều này rất
tương tự như thuật toán dựa trên danh sách được thảo luận trong phần 2.3 ("Dựa trên danh sách
Thuật toán") của Srinivasan.
Tuy nhiên, bất kỳ trình tạo cấu trúc dữ liệu nào duy trì khóa tài nguyên cho
thời gian sửa chữa là ZZ0000ZZ một thuật toán ngoại tuyến.

.. _secondary_metadata:

Siêu dữ liệu thứ cấp
``````````````````

Cấu trúc siêu dữ liệu trong danh mục này phản ánh các bản ghi được tìm thấy trong siêu dữ liệu chính,
nhưng chỉ cần thiết cho fsck trực tuyến hoặc để tổ chức lại hệ thống tập tin.

Siêu dữ liệu thứ cấp bao gồm:

- Thông tin bản đồ ngược

- Con trỏ thư mục cha

Lớp siêu dữ liệu này khó xử lý vì quá trình chà sẽ gắn vào
tới đối tượng phụ nhưng cần kiểm tra siêu dữ liệu chính chạy truy cập
theo thứ tự thu thập tài nguyên thông thường.
Thông thường, điều này có nghĩa là cần phải quét toàn bộ hệ thống tập tin để xây dựng lại
siêu dữ liệu.
Chức năng kiểm tra có thể được giới hạn phạm vi để giảm thời gian chạy.
Tuy nhiên, việc sửa chữa yêu cầu quét toàn bộ siêu dữ liệu chính, việc này có thể mất nhiều thời gian.
còn lâu mới hoàn thành.
Trong những điều kiện này, ZZ0000ZZ không thể khóa tài nguyên cho toàn bộ
thời gian sửa chữa.

Thay vào đó, các chức năng sửa chữa thiết lập cấu trúc phân tầng trong bộ nhớ để lưu trữ
quan sát.
Tùy thuộc vào yêu cầu của chức năng sửa chữa cụ thể, việc dàn dựng
chỉ mục sẽ có cùng định dạng với cấu trúc ondisk hoặc một thiết kế
cụ thể cho chức năng sửa chữa đó.
Bước tiếp theo là giải phóng tất cả các khóa và bắt đầu quét hệ thống tập tin.
Khi máy quét sửa chữa cần ghi lại một quan sát, dữ liệu dàn dựng sẽ được
bị khóa đủ lâu để áp dụng bản cập nhật.
Trong khi quá trình quét hệ thống tập tin đang diễn ra, chức năng sửa chữa sẽ kết nối
hệ thống tập tin để nó có thể áp dụng các bản cập nhật hệ thống tập tin đang chờ xử lý cho dàn dựng
thông tin.
Sau khi quét xong, đối tượng sở hữu sẽ bị khóa lại, dữ liệu trực tiếp được sử dụng để
viết một cấu trúc ondisk mới và việc sửa chữa được thực hiện nguyên tử.
Các móc bị vô hiệu hóa và khu vực tổ chức được giải phóng.
Cuối cùng, việc lưu trữ từ cấu trúc dữ liệu cũ được thu thập một cách cẩn thận.

Việc giới thiệu tính năng đồng thời giúp sửa chữa trực tuyến tránh được nhiều vấn đề về khóa khác nhau, nhưng
có chi phí cao cho độ phức tạp của mã.
Mã hệ thống tập tin trực tiếp phải được nối để chức năng sửa chữa có thể quan sát
cập nhật đang được tiến hành.
Khu vực tổ chức phải trở thành một cấu trúc song song đầy đủ chức năng để
các bản cập nhật có thể được hợp nhất từ các hook.
Cuối cùng, hook, quét hệ thống tập tin và mô hình khóa inode phải được
được tích hợp đủ tốt để một sự kiện hook có thể quyết định liệu một bản cập nhật nhất định có
nên được áp dụng cho cấu trúc dàn dựng.

Về lý thuyết, việc triển khai chà có thể áp dụng các kỹ thuật tương tự cho
siêu dữ liệu chính, nhưng làm như vậy sẽ làm cho siêu dữ liệu trở nên phức tạp hơn và ít
biểu diễn.
Các chương trình cố gắng truy cập vào cấu trúc bị hỏng không bị chặn
hoạt động, có thể gây ra lỗi ứng dụng hoặc hệ thống tập tin ngoài kế hoạch
tắt máy.

Cảm hứng cho chiến lược sửa chữa siêu dữ liệu thứ cấp được rút ra từ phần
2.4 của Srinivasan ở trên và phần 2 ("NSF: Xây dựng chỉ mục không có tệp phụ")
và 3.1.1 ("Vấn đề chèn khóa trùng lặp") trong C. Mohan, ZZ0000ZZ, 1992.

Chỉ mục sidecar được đề cập ở trên có một số điểm tương đồng với tệp phụ
phương pháp được đề cập trong Srinivasan và Mohan.
Phương pháp của họ bao gồm một trình xây dựng chỉ mục trích xuất dữ liệu bản ghi có liên quan tới
xây dựng cấu trúc mới càng nhanh càng tốt; và một cấu trúc phụ trợ
nắm bắt tất cả các bản cập nhật sẽ được các luồng khác cam kết lập chỉ mục
chỉ mục mới đã trực tuyến.
Sau khi quá trình quét xây dựng chỉ mục kết thúc, các bản cập nhật được ghi trong tệp bên
được áp dụng cho chỉ mục mới.
Để tránh xung đột giữa trình tạo chỉ mục và các luồng trình soạn thảo khác,
trình xây dựng duy trì một con trỏ hiển thị công khai để theo dõi tiến trình của
quét qua không gian bản ghi.
Để tránh sự trùng lặp công việc giữa tệp bên và trình tạo chỉ mục, bên
các bản cập nhật tệp sẽ bị loại bỏ khi ID bản ghi cho bản cập nhật lớn hơn
vị trí con trỏ trong không gian ID bản ghi.

Để giảm thiểu các thay đổi đối với phần còn lại của cơ sở mã, tính năng sửa chữa trực tuyến XFS sẽ giữ nguyên
chỉ mục thay thế được ẩn cho đến khi nó hoàn toàn sẵn sàng hoạt động.
Nói cách khác, không có nỗ lực nào để lộ không gian khóa của chỉ mục mới
trong khi quá trình sửa chữa đang diễn ra.
Sự phức tạp của cách tiếp cận như vậy sẽ rất cao và có lẽ còn nhiều hơn nữa.
thích hợp để xây dựng các chỉ số ZZ0000ZZ.

ZZ0000ZZ: Có thể quét toàn bộ và cập nhật trực tiếp mã được sử dụng để
tạo điều kiện thuận lợi cho việc sửa chữa cũng được sử dụng để thực hiện kiểm tra toàn diện?

ZZ0000ZZ: Về lý thuyết thì đúng vậy.  Kiểm tra sẽ mạnh mẽ hơn nhiều nếu mỗi chức năng chà
đã sử dụng những lần quét trực tiếp này để tạo bản sao ẩn của siêu dữ liệu và sau đó
so sánh các bản ghi bóng với các bản ghi ondisk.
Tuy nhiên, làm điều đó tốn nhiều công sức hơn chức năng kiểm tra.
làm ngay bây giờ.
Tính năng quét trực tiếp và hook được phát triển muộn hơn nhiều.
Điều đó lần lượt làm tăng thời gian chạy của các hàm chà đó.

Thông tin tóm tắt
```````````````````

Cấu trúc siêu dữ liệu trong danh mục cuối cùng này tóm tắt nội dung của dữ liệu chính
bản ghi siêu dữ liệu.
Chúng thường được sử dụng để tăng tốc các truy vấn sử dụng tài nguyên và nhiều khi
nhỏ hơn siêu dữ liệu chính mà chúng đại diện.

Ví dụ về thông tin tóm tắt bao gồm:

- Tóm tắt số lượng không gian trống và nút

- Số lượng liên kết tập tin từ các thư mục

- Số lượng sử dụng tài nguyên hạn ngạch

Kiểm tra và sửa chữa yêu cầu quét toàn bộ hệ thống tập tin, nhưng tài nguyên và khóa
việc mua lại đi theo các đường dẫn giống như truy cập hệ thống tập tin thông thường.

Bộ đếm tóm tắt siêu khối có các yêu cầu đặc biệt do cơ sở
thực hiện các bộ đếm incore và sẽ được xử lý riêng.
Kiểm tra và sửa chữa các loại bộ đếm tóm tắt khác (số lượng tài nguyên hạn ngạch
và số lượng liên kết tệp) sử dụng cùng một chức năng quét và nối hệ thống tệp
kỹ thuật như đã nêu ở trên, nhưng vì dữ liệu cơ bản là tập hợp các
bộ đếm số nguyên, dữ liệu dàn không cần phải là một bản sao đầy đủ chức năng của
cấu trúc ondisk

Cảm hứng cho các chiến lược sửa chữa hạn ngạch và số lượng liên kết tập tin được rút ra từ
phần 2.12 ("Hoạt động chỉ mục trực tuyến") đến 2.14 ("Chế độ xem gia tăng
Bảo trì") của G. Graefe, ZZ0000ZZ, 2011.

Vì hạn ngạch là số nguyên không âm của việc sử dụng tài nguyên nên trực tuyến
hạn ngạch có thể sử dụng vùng đồng bằng chế độ xem tăng dần được mô tả trong phần 2.14 để
theo dõi các thay đổi đang chờ xử lý đối với số lượng sử dụng khối và inode trong mỗi giao dịch,
và cam kết những thay đổi đó vào tệp phụ dquot khi giao dịch được thực hiện.
Việc theo dõi delta là cần thiết cho dquot vì trình tạo chỉ mục sẽ quét các nút,
trong khi cấu trúc dữ liệu đang được xây dựng lại là chỉ mục của dquots.
Việc kiểm tra số lượng liên kết kết hợp các vùng đồng bằng chế độ xem và bước cam kết thành một vì
nó thiết lập các thuộc tính của đối tượng được quét thay vì ghi chúng vào một
cấu trúc dữ liệu riêng biệt
Mỗi chức năng fsck trực tuyến sẽ được thảo luận dưới dạng nghiên cứu điển hình sau này
tài liệu.

Quản lý rủi ro
---------------

Trong quá trình phát triển fsck trực tuyến, một số yếu tố rủi ro đã được xác định
điều đó có thể làm cho tính năng này không phù hợp với một số nhà phân phối và người dùng nhất định.
Các bước có thể được thực hiện để giảm thiểu hoặc loại bỏ những rủi ro đó, mặc dù phải trả giá
chức năng.

- ZZ0000ZZ: Thêm chỉ mục siêu dữ liệu vào hệ thống tập tin
  tăng chi phí thời gian cho việc liên tục thay đổi ổ đĩa và không gian đảo ngược
  ánh xạ và con trỏ thư mục gốc cũng không ngoại lệ.
  Quản trị viên hệ thống yêu cầu hiệu suất tối đa có thể vô hiệu hóa
  đảo ngược các tính năng ánh xạ tại thời điểm định dạng, mặc dù sự lựa chọn này đáng kể
  làm giảm khả năng fsck trực tuyến tìm ra sự không nhất quán và sửa chữa chúng.

- ZZ0004ZZ: Giống như tất cả phần mềm, có thể có lỗi trong
  phần mềm dẫn đến việc sửa chữa không chính xác được ghi vào hệ thống tập tin.
  Kiểm tra fuzz có hệ thống (chi tiết trong phần tiếp theo) được sử dụng bởi
  tác giả tìm ra lỗi sớm nhưng có thể không nắm bắt được mọi thứ.
  Hệ thống xây dựng kernel cung cấp các tùy chọn Kconfig (ZZ0000ZZ
  và ZZ0001ZZ) để cho phép các nhà phân phối chọn không
  chấp nhận rủi ro này.
  Hệ thống xây dựng xfsprogs có tùy chọn cấu hình (ZZ0002ZZ)
  vô hiệu hóa việc xây dựng hệ nhị phân ZZ0003ZZ, mặc dù đây không phải là một rủi ro
  giảm thiểu nếu chức năng kernel vẫn được kích hoạt.

- ZZ0000ZZ: Đôi khi, một hệ thống tập tin bị hư hỏng quá nặng nên không thể
  có thể sửa chữa được.
  Nếu không gian khóa của một số chỉ mục siêu dữ liệu trùng nhau theo một cách nào đó nhưng
  câu chuyện mạch lạc không thể được hình thành từ các hồ sơ được thu thập, sau đó việc sửa chữa
  thất bại.
  Để giảm khả năng sửa chữa sẽ thất bại với một giao dịch bẩn và
  làm cho hệ thống tập tin không thể sử dụng được, các chức năng sửa chữa trực tuyến đã bị ngừng hoạt động.
  được thiết kế để phân giai đoạn và xác nhận tất cả các hồ sơ mới trước khi thực hiện hồ sơ mới
  cấu trúc.

- ZZ0000ZZ: fsck trực tuyến yêu cầu nhiều đặc quyền -- IO thô để chặn
  thiết bị, mở tệp bằng tay cầm, bỏ qua kiểm soát truy cập tùy ý của Unix,
  và khả năng thực hiện các thay đổi hành chính.
  Việc chạy tự động ở chế độ nền này khiến mọi người sợ hãi, vì vậy systemd
  dịch vụ nền được cấu hình để chỉ chạy với các đặc quyền được yêu cầu.
  Rõ ràng, điều này không thể giải quyết được một số vấn đề nhất định như lỗi kernel hoặc
  bế tắc, nhưng nó phải đủ để ngăn chặn quá trình loại bỏ khỏi
  thoát và cấu hình lại hệ thống.
  Công việc định kỳ không có sự bảo vệ này.

- ZZ0000ZZ: Hiện nay có nhiều người dường như nghĩ rằng chạy
  kiểm tra lông tơ tự động của các tạo phẩm trên đĩa để tìm ra hành vi tinh quái và
  rải mã khai thác vào danh sách gửi thư công khai để có được lỗ hổng zero-day ngay lập tức
  việc tiết lộ bằng cách nào đó mang lại lợi ích xã hội nào đó.
  Theo quan điểm của tác giả này, lợi ích chỉ được nhận ra khi lông tơ
  các nhà khai thác giúp ZZ0001ZZ khắc phục những sai sót, nhưng ý kiến này rõ ràng là không
  được chia sẻ rộng rãi giữa các "nhà nghiên cứu" bảo mật.
  Khả năng tiếp tục quản lý các sự kiện này của người bảo trì XFS thể hiện một
  rủi ro liên tục đối với sự ổn định của quá trình phát triển.
  Kiểm thử tự động sẽ nhận diện trước một số rủi ro trong khi tính năng này được
  được coi là EXPERIMENTAL.

Nhiều rủi ro trong số này là cố hữu của việc lập trình phần mềm.
Mặc dù vậy, người ta hy vọng rằng chức năng mới này sẽ hữu ích trong
giảm thời gian ngừng hoạt động bất ngờ.

3. Kế hoạch kiểm tra
===============

Như đã nêu trước đây, các công cụ fsck có ba mục tiêu chính:

1. Phát hiện sự không nhất quán trong siêu dữ liệu;

2. Loại bỏ những mâu thuẫn đó; Và

3. Giảm thiểu việc mất thêm dữ liệu.

Việc trình diễn hoạt động chính xác là cần thiết để tạo dựng niềm tin cho người dùng
rằng phần mềm hoạt động trong sự mong đợi.
Thật không may, việc thực hiện kiểm tra toàn diện thường xuyên là không thực sự khả thi.
về mọi khía cạnh của công cụ fsck cho đến khi giới thiệu công nghệ ảo chi phí thấp
máy có bộ lưu trữ IOPS cao.
Với tính sẵn có của phần cứng dồi dào, chiến lược thử nghiệm cho
dự án fsck liên quan đến phân tích khác biệt so với các công cụ fsck hiện có và
kiểm tra có hệ thống mọi thuộc tính của mọi loại đối tượng siêu dữ liệu.
Thử nghiệm có thể được chia thành bốn loại chính, như được thảo luận dưới đây.

Thử nghiệm tích hợp với fstests
-------------------------------

Mục tiêu chính của bất kỳ nỗ lực đảm bảo chất lượng phần mềm miễn phí nào là làm cho việc thử nghiệm trở thành
không tốn kém và phổ biến nhất có thể để tối đa hóa lợi thế mở rộng quy mô của
cộng đồng.
Nói cách khác, việc kiểm tra sẽ tối đa hóa bề rộng của cấu hình hệ thống tập tin
kịch bản và thiết lập phần cứng.
Điều này cải thiện chất lượng mã bằng cách cho phép các tác giả của fsck trực tuyến tìm và
sửa lỗi sớm và giúp nhà phát triển các tính năng mới tìm cách tích hợp
vấn đề trước đó trong nỗ lực phát triển của họ.

Cộng đồng hệ thống tập tin Linux chia sẻ bộ thử nghiệm QA chung,
ZZ0003ZZ, dành cho
kiểm tra chức năng và hồi quy.
Ngay cả trước khi công việc phát triển bắt đầu trên fsck trực tuyến, fstests (khi chạy trên XFS)
sẽ chạy cả hai lệnh ZZ0000ZZ và ZZ0001ZZ trong bài kiểm tra và
hệ thống tập tin đầu giữa mỗi lần kiểm tra.
Điều này cung cấp một mức độ đảm bảo rằng kernel và các công cụ fsck vẫn ở trạng thái ổn định.
sự liên kết về những gì tạo nên siêu dữ liệu nhất quán.
Trong quá trình phát triển mã kiểm tra trực tuyến, fstests đã được sửa đổi để chạy
ZZ0002ZZ giữa mỗi lần kiểm tra để đảm bảo rằng mã kiểm tra mới
tạo ra kết quả tương tự như hai công cụ fsck hiện có.

Để bắt đầu phát triển tính năng sửa chữa trực tuyến, fstests đã được sửa đổi để chạy
ZZ0000ZZ để xây dựng lại các chỉ mục siêu dữ liệu của hệ thống tệp giữa các lần kiểm tra.
Điều này đảm bảo rằng việc sửa chữa ngoại tuyến không gặp sự cố, để lại hệ thống tệp bị hỏng
sau khi nó tồn tại hoặc gây ra khiếu nại từ việc kiểm tra trực tuyến.
Điều này cũng thiết lập cơ sở cho những gì có thể và không thể sửa chữa ngoại tuyến.
Để hoàn thành giai đoạn đầu phát triển dịch vụ sửa chữa trực tuyến, fstests đã
được sửa đổi để có thể chạy ZZ0001ZZ ở chế độ "xây dựng lại lực lượng".
Điều này cho phép so sánh hiệu quả của việc sửa chữa trực tuyến so với
các công cụ sửa chữa ngoại tuyến hiện có.

Kiểm tra Fuzz chung của các khối siêu dữ liệu
---------------------------------------

XFS được hưởng lợi rất nhiều từ việc có một công cụ sửa lỗi rất mạnh mẽ, ZZ0000ZZ.

Trước khi bắt đầu phát triển fsck trực tuyến, một tập hợp fstest đã được tạo
để kiểm tra lỗi khá phổ biến là toàn bộ khối siêu dữ liệu bị hỏng.
Điều này yêu cầu tạo mã thư viện fstests có thể tạo hệ thống tệp
chứa mọi loại đối tượng siêu dữ liệu có thể có.
Tiếp theo, các trường hợp thử nghiệm riêng lẻ được tạo để tạo hệ thống tệp thử nghiệm, xác định
một khối của một loại đối tượng siêu dữ liệu cụ thể, hãy xóa nó bằng
Lệnh ZZ0000ZZ hiện có trong ZZ0001ZZ và kiểm tra phản ứng của
chiến lược xác thực siêu dữ liệu cụ thể.

Bộ thử nghiệm trước đó này cho phép các nhà phát triển XFS kiểm tra khả năng của
các chức năng xác thực trong kernel và khả năng của công cụ fsck ngoại tuyến
phát hiện và loại bỏ siêu dữ liệu không nhất quán.
Phần này của bộ thử nghiệm đã được mở rộng để bao gồm fsck trực tuyến một cách chính xác
cùng một cách.

Nói cách khác, đối với cấu hình hệ thống tệp fstests nhất định:

* Đối với từng đối tượng siêu dữ liệu hiện có trên hệ thống tệp:

* Viết rác cho nó

* Kiểm tra phản ứng của:

1. Trình xác minh kernel để dừng siêu dữ liệu xấu rõ ràng
    2. Sửa chữa ngoại tuyến (ZZ0000ZZ) để phát hiện và khắc phục
    3. Sửa chữa trực tuyến (ZZ0001ZZ) để phát hiện và khắc phục

Kiểm tra Fuzz có mục tiêu của các bản ghi siêu dữ liệu
-----------------------------------------

Kế hoạch thử nghiệm cho fsck trực tuyến bao gồm việc mở rộng thử nghiệm fs hiện có
cơ sở hạ tầng để cung cấp một cơ sở mạnh mẽ hơn nhiều: thử nghiệm lông tơ có mục tiêu
của mọi trường siêu dữ liệu của mọi đối tượng siêu dữ liệu trong hệ thống tệp.
ZZ0000ZZ có thể sửa đổi mọi trường của mọi cấu trúc siêu dữ liệu trong mọi
chặn trong hệ thống tập tin để mô phỏng tác động của việc hỏng bộ nhớ và
lỗi phần mềm.
Vì fstests đã có khả năng tạo hệ thống tập tin
chứa mọi định dạng siêu dữ liệu được hệ thống tập tin biết đến, ZZ0001ZZ có thể
được sử dụng để thực hiện kiểm tra lông tơ toàn diện!

Đối với cấu hình hệ thống tập tin fstests nhất định:

* Đối với mỗi đối tượng siêu dữ liệu hiện có trên hệ thống tệp...

* Đối với mỗi bản ghi bên trong đối tượng siêu dữ liệu đó...

* Đối với mỗi trường bên trong bản ghi đó...

* Đối với mỗi loại biến đổi có thể hình dung được có thể áp dụng cho trường bit...

1. Xóa tất cả các bit
        2. Đặt tất cả các bit
        3. Chuyển đổi bit quan trọng nhất
        4. Chuyển đổi bit giữa
        5. Chuyển đổi bit ít quan trọng nhất
        6. Thêm một lượng nhỏ
        7. Trừ một lượng nhỏ
        8. Ngẫu nhiên hóa nội dung

* ...kiểm tra phản ứng của:

1. Trình xác minh kernel để dừng siêu dữ liệu xấu rõ ràng
          2. Kiểm tra ngoại tuyến (ZZ0000ZZ)
          3. Sửa chữa ngoại tuyến (ZZ0001ZZ)
          4. Kiểm tra trực tuyến (ZZ0002ZZ)
          5. Sửa chữa trực tuyến (ZZ0003ZZ)
          6. Cả hai công cụ sửa chữa (ZZ0004ZZ và sau đó là ZZ0005ZZ nếu sửa chữa trực tuyến không thành công)

Đây thực sự là một vụ nổ tổ hợp!

May mắn thay, việc có nhiều thử nghiệm như vậy giúp các nhà phát triển XFS dễ dàng
kiểm tra phản hồi của các công cụ fsck của XFS.
Kể từ khi giới thiệu khung thử nghiệm fuzz, các thử nghiệm này đã được
được sử dụng để phát hiện mã sửa chữa không chính xác và chức năng bị thiếu cho toàn bộ
các lớp đối tượng siêu dữ liệu trong ZZ0000ZZ.
Thử nghiệm nâng cao đã được sử dụng để hoàn tất việc ngừng sử dụng ZZ0001ZZ bởi
xác nhận rằng ZZ0002ZZ có thể phát hiện ít nhất nhiều lỗi như
công cụ cũ hơn.

Những thử nghiệm này rất có giá trị đối với ZZ0000ZZ theo những cách tương tự -- chúng
cho phép các nhà phát triển fsck trực tuyến so sánh fsck trực tuyến với fsck ngoại tuyến,
và chúng cho phép các nhà phát triển XFS tìm ra những thiếu sót trong cơ sở mã.

Các bản vá được đề xuất bao gồm
ZZ0000ZZ.

Kiểm tra căng thẳng
--------------

Yêu cầu duy nhất đối với fsck trực tuyến là khả năng hoạt động trên hệ thống tệp
đồng thời với khối lượng công việc thường xuyên.
Mặc dù tất nhiên là không thể chạy ZZ0000ZZ với ZZ0001ZZ có thể quan sát được
ảnh hưởng đến hệ thống đang chạy, mã sửa chữa trực tuyến không bao giờ nên đưa vào
sự không nhất quán trong siêu dữ liệu của hệ thống tập tin và khối lượng công việc thông thường sẽ
không bao giờ nhận thấy nạn đói tài nguyên.
Để xác minh rằng các điều kiện này đang được đáp ứng, fstests đã được cải tiến trong
những cách sau:

* Đối với mỗi loại mục chà, hãy tạo một bài kiểm tra để thực hiện kiểm tra loại mục đó
  trong khi chạy ZZ0000ZZ.
* Đối với mỗi loại vật phẩm chà, hãy tạo một bài kiểm tra để thực hiện sửa chữa loại vật phẩm đó
  trong khi chạy ZZ0001ZZ.
* Đua ZZ0002ZZ và ZZ0003ZZ để đảm bảo kiểm tra toàn bộ
  hệ thống tập tin không gây ra vấn đề.
* Đua ZZ0004ZZ và ZZ0005ZZ ở chế độ xây dựng lại lực lượng để đảm bảo rằng
  việc buộc sửa chữa toàn bộ hệ thống tập tin không gây ra vấn đề gì.
* Đua ZZ0006ZZ ở chế độ kiểm tra và buộc sửa chữa chống lại ZZ0007ZZ trong khi
  đóng băng và làm tan băng hệ thống tập tin.
* Đua ZZ0008ZZ ở chế độ kiểm tra và buộc sửa chữa chống lại ZZ0009ZZ trong khi
  kể lại hệ thống tập tin chỉ đọc và đọc-ghi.
* Tương tự, nhưng chạy ZZ0010ZZ thay vì ZZ0011ZZ.  (Chưa xong à?)

Thành công được xác định bằng khả năng chạy tất cả các thử nghiệm này mà không cần quan sát
bất kỳ sự tắt hệ thống tập tin không mong muốn nào do siêu dữ liệu bị hỏng, treo kernel
kiểm tra các cảnh báo hoặc bất kỳ hành vi nghịch ngợm nào khác.

4. Giao diện người dùng
=================

Người dùng chính của fsck trực tuyến là quản trị viên hệ thống, giống như ngoại tuyến
sửa chữa.
Fsck trực tuyến trình bày hai chế độ hoạt động cho quản trị viên:
Quy trình CLI tiền cảnh dành cho fsck trực tuyến theo yêu cầu và dịch vụ nền
thực hiện việc kiểm tra và sửa chữa tự động.

Kiểm tra theo yêu cầu
------------------

Dành cho những quản trị viên muốn có thông tin mới nhất tuyệt đối về
siêu dữ liệu trong hệ thống tệp, ZZ0000ZZ có thể được chạy dưới dạng quy trình nền trước trên
một dòng lệnh.
Chương trình kiểm tra mọi phần siêu dữ liệu trong hệ thống tập tin trong khi
quản trị viên đợi kết quả được báo cáo giống như hiện tại
Công cụ ZZ0001ZZ.
Cả hai công cụ đều có chung tùy chọn ZZ0002ZZ để thực hiện quét chỉ đọc và ZZ0003ZZ
tùy chọn để tăng tính chi tiết của thông tin được báo cáo.

Một tính năng mới của ZZ0000ZZ là tùy chọn ZZ0001ZZ, sử dụng lỗi
khả năng sửa lỗi của phần cứng để kiểm tra nội dung file dữ liệu.
Quét phương tiện không được bật theo mặc định vì nó có thể tăng đáng kể
thời gian chạy chương trình và tiêu tốn nhiều băng thông trên phần cứng lưu trữ cũ.

Đầu ra của lệnh gọi tiền cảnh được ghi lại trong nhật ký hệ thống.

Chương trình ZZ0000ZZ duyệt qua danh sách các hệ thống tập tin được gắn và
khởi tạo ZZ0001ZZ cho từng cái một cách song song.
Nó tuần tự hóa các lần quét để tìm bất kỳ hệ thống tệp nào được phân giải ở cùng cấp cao nhất
thiết bị chặn kernel để ngăn chặn việc tiêu thụ quá nhiều tài nguyên.

Dịch vụ nền
------------------

Để giảm bớt khối lượng công việc của quản trị viên hệ thống, gói ZZ0000ZZ
cung cấp bộ tính giờ và dịch vụ ZZ0001ZZ
chạy fsck trực tuyến tự động vào cuối tuần theo mặc định.
Dịch vụ nền cấu hình chà để chạy với ít đặc quyền như
có thể, mức ưu tiên CPU và IO thấp nhất và trong một đơn bị ràng buộc CPU
chế độ luồng.
Điều này có thể được quản trị viên hệ thống điều chỉnh bất cứ lúc nào để phù hợp với độ trễ
và yêu cầu về thông lượng của khối lượng công việc của khách hàng.

Đầu ra của dịch vụ nền cũng được ghi lại trong nhật ký hệ thống.
Nếu muốn, các báo cáo về lỗi (do không nhất quán hoặc chỉ do thời gian chạy
lỗi) có thể được gửi qua email tự động bằng cách cài đặt môi trường ZZ0000ZZ
biến trong các tệp dịch vụ sau:

* ZZ0000ZZ
* ZZ0001ZZ
* ZZ0002ZZ

Quyết định kích hoạt tính năng quét nền thuộc về quản trị viên hệ thống.
Điều này có thể được thực hiện bằng cách kích hoạt một trong các dịch vụ sau:

* ZZ0000ZZ trên hệ thống systemd
* ZZ0001ZZ trên các hệ thống không có hệ thống

Quá trình quét tự động hàng tuần này được cấu hình ngay lập tức để thực hiện
quét phương tiện bổ sung của tất cả dữ liệu tệp mỗi tháng một lần.
Điều này ít rõ ràng hơn so với việc lưu trữ tổng kiểm tra khối dữ liệu tệp, nhưng nhiều
hiệu suất cao hơn nếu phần mềm ứng dụng cung cấp khả năng kiểm tra tính toàn vẹn của riêng nó,
dự phòng có thể được cung cấp ở nơi khác phía trên hệ thống tập tin hoặc bộ lưu trữ
đảm bảo tính toàn vẹn của thiết bị được coi là đủ.

Các định nghĩa tệp đơn vị systemd đã được kiểm tra bảo mật
(kể từ systemd 249) để đảm bảo rằng các tiến trình xfs_scrub có ít
truy cập vào phần còn lại của hệ thống càng tốt.
Việc này được thực hiện thông qua ZZ0000ZZ, sau đó có các đặc quyền
bị giới hạn ở mức yêu cầu tối thiểu, hộp cát được thiết lập ở mức tối đa
mức độ có thể với hộp cát và lọc cuộc gọi hệ thống; và quyền truy cập vào
cây hệ thống tập tin bị hạn chế ở mức tối thiểu cần thiết để khởi động chương trình và
truy cập vào hệ thống tập tin đang được quét.
Các tệp định nghĩa dịch vụ hạn chế mức sử dụng CPU ở mức 80% của một lõi CPU và
áp dụng mức độ ưu tiên cao nhất cho việc lập lịch IO và CPU càng tốt.
Biện pháp này được thực hiện để giảm thiểu độ trễ trong phần còn lại của hệ thống tập tin.
Không có công việc tăng cường nào như vậy được thực hiện cho công việc định kỳ.

Báo cáo sức khỏe
----------------

XFS lưu trữ bản tóm tắt về trạng thái sức khỏe của từng hệ thống tệp trong bộ nhớ.
Thông tin được cập nhật bất cứ khi nào ZZ0000ZZ được chạy hoặc bất cứ khi nào
sự không nhất quán được phát hiện trong siêu dữ liệu của hệ thống tập tin trong quá trình
hoạt động.
Quản trị viên hệ thống nên sử dụng lệnh ZZ0001ZZ của ZZ0002ZZ để
tải thông tin này về định dạng mà con người có thể đọc được.
Nếu quan sát thấy vấn đề, quản trị viên có thể lên lịch giảm
cửa sổ dịch vụ để chạy công cụ sửa chữa trực tuyến nhằm khắc phục sự cố.
Nếu không, quản trị viên có thể quyết định lên lịch thời gian bảo trì để
chạy công cụ sửa chữa ngoại tuyến truyền thống để khắc phục sự cố.

ZZ0000ZZ: Báo cáo sức khỏe có nên tích hợp với phiên bản mới
hệ thống thông báo lỗi inotify fs?
Sẽ có ích cho các quản trị viên hệ thống nếu có một daemon để lắng nghe tham nhũng
thông báo và bắt đầu sửa chữa?

ZZ0000ZZ: Những câu hỏi này vẫn chưa được trả lời nhưng sẽ là một phần của
trò chuyện với những người dùng đầu tiên và người dùng tiềm năng của XFS.

5. Thuật toán hạt nhân và cấu trúc dữ liệu
========================================

Phần này thảo luận về các thuật toán chính và cấu trúc dữ liệu của kernel
mã cung cấp khả năng kiểm tra và sửa chữa siêu dữ liệu trong khi hệ thống
đang chạy.
Các chương đầu tiên trong phần này tiết lộ những phần cung cấp
nền tảng để kiểm tra siêu dữ liệu.
Phần còn lại của phần này trình bày các cơ chế mà qua đó XFS
tự nó tái sinh.

Siêu dữ liệu tự mô tả
------------------------

Bắt đầu với XFS phiên bản 5 vào năm 2012, XFS đã cập nhật định dạng của gần như mọi
tiêu đề khối ondisk để ghi lại số ma thuật, tổng kiểm tra, tổng thể
mã định danh "duy nhất" (UUID), mã chủ sở hữu, địa chỉ ondisk của khối,
và một số thứ tự nhật ký.
Khi tải bộ đệm khối từ đĩa, số ma thuật, UUID, chủ sở hữu và
địa chỉ ondisk xác nhận rằng khối được truy xuất khớp với chủ sở hữu cụ thể của
hệ thống tập tin hiện tại và thông tin chứa trong khối là
được cho là được tìm thấy tại địa chỉ ondisk.
Ba thành phần đầu tiên cho phép các công cụ kiểm tra bỏ qua siêu dữ liệu bị cáo buộc
không thuộc về hệ thống tập tin và thành phần thứ tư cho phép
hệ thống tập tin để phát hiện việc ghi bị mất.

Bất cứ khi nào một thao tác hệ thống tệp sửa đổi một khối, thay đổi đó sẽ được gửi
vào nhật ký như một phần của giao dịch.
Nhật ký sau đó xử lý các giao dịch này và đánh dấu chúng được thực hiện sau khi chúng được thực hiện.
được lưu giữ một cách an toàn vào kho lưu trữ.
Mã ghi nhật ký duy trì tổng kiểm tra và số thứ tự nhật ký của lần cuối cùng
cập nhật giao dịch.
Tổng kiểm tra rất hữu ích trong việc phát hiện các bản ghi bị rách và những khác biệt khác có thể
được đưa vào giữa máy tính và các thiết bị lưu trữ của nó.
Theo dõi số thứ tự cho phép khôi phục nhật ký để tránh áp dụng lỗi thời
log cập nhật vào hệ thống tập tin.

Hai tính năng này cải thiện khả năng phục hồi thời gian chạy tổng thể bằng cách cung cấp phương tiện để
hệ thống tập tin để phát hiện lỗi rõ ràng khi đọc các khối siêu dữ liệu từ
đĩa, nhưng những trình xác minh bộ đệm này không thể cung cấp bất kỳ kiểm tra tính nhất quán nào
giữa các cấu trúc siêu dữ liệu.

Để biết thêm thông tin, vui lòng xem tài liệu dành cho
Tài liệu/hệ thống tập tin/xfs/xfs-self-description-metadata.rst

Ánh xạ ngược
---------------

Thiết kế ban đầu của XFS (khoảng năm 1993) là một cải tiến của Unix những năm 1980
thiết kế hệ thống tập tin.
Vào thời đó, mật độ lưu trữ đắt đỏ, thời gian dành cho CPU khan hiếm và
thời gian tìm kiếm quá mức có thể giết chết hiệu suất.
Vì lý do hiệu suất, các tác giả hệ thống tập tin đã miễn cưỡng thêm phần dự phòng vào
hệ thống tập tin, thậm chí phải trả giá bằng tính toàn vẹn dữ liệu.
Các nhà thiết kế hệ thống tập tin vào đầu thế kỷ 21 chọn các chiến lược khác nhau để
tăng sự dư thừa nội bộ -- hoặc lưu trữ các bản sao gần như giống hệt nhau của
siêu dữ liệu hoặc các kỹ thuật mã hóa tiết kiệm không gian hơn.

Đối với XFS, một chiến lược dự phòng khác đã được chọn để hiện đại hóa thiết kế:
chỉ mục sử dụng không gian thứ cấp ánh xạ các phạm vi đĩa được phân bổ trở lại vị trí của chúng
các chủ sở hữu.
Bằng cách thêm một chỉ mục mới, hệ thống tập tin vẫn giữ được hầu hết khả năng mở rộng quy mô
tốt cho khối lượng công việc có nhiều luồng liên quan đến các tập dữ liệu lớn, vì cơ sở dữ liệu chính
siêu dữ liệu tệp (cây thư mục, sơ đồ khối tệp và phân bổ
nhóm) không thay đổi.
Giống như bất kỳ hệ thống nào cải thiện tính dư thừa, tính năng ánh xạ ngược sẽ tăng
chi phí chung cho các hoạt động lập bản đồ không gian.
Tuy nhiên, nó có hai ưu điểm quan trọng: thứ nhất, chỉ số đảo ngược là chìa khóa để
cho phép fsck trực tuyến và các chức năng được yêu cầu khác như dung lượng trống
chống phân mảnh, báo cáo lỗi phương tiện tốt hơn và thu nhỏ hệ thống tập tin.
Thứ hai, định dạng lưu trữ ondisk khác nhau của btree ánh xạ ngược
đánh bại sự trùng lặp cấp thiết bị vì hệ thống tập tin yêu cầu thực tế
dư thừa.

+-----------------------------------------------------------------------------------+
ZZ0001ZZ
+-----------------------------------------------------------------------------------+
ZZ0002ZZ
ZZ0003ZZ
ZZ0004ZZ
ZZ0005ZZ
ZZ0006ZZ
ZZ0007ZZ
ZZ0008ZZ
ZZ0009ZZ
ZZ0010ZZ
ZZ0011ZZ
ZZ0012ZZ
ZZ0013ZZ
+-----------------------------------------------------------------------------------+

Thông tin được ghi lại trong bản ghi ánh xạ không gian ngược như sau:

.. code-block:: c

	struct xfs_rmap_irec {
	    xfs_agblock_t    rm_startblock;   /* extent start block */
	    xfs_extlen_t     rm_blockcount;   /* extent length */
	    uint64_t         rm_owner;        /* extent owner */
	    uint64_t         rm_offset;       /* offset within the owner */
	    unsigned int     rm_flags;        /* state flags */
	};

Hai trường đầu tiên nắm bắt vị trí và kích thước của không gian vật lý,
theo đơn vị khối hệ thống tập tin.
Trường chủ sở hữu cho biết cấu trúc siêu dữ liệu hoặc inode tệp nào đã được
được giao không gian này.
Đối với không gian được phân bổ cho các tệp, trường offset sẽ cho biết không gian đó ở đâu
được ánh xạ trong nhánh tập tin.
Cuối cùng, trường flags cung cấp thêm thông tin về việc sử dụng dung lượng --
đây có phải là phạm vi phân nhánh thuộc tính không?  Một tập tin ánh xạ phạm vi btree?  Hoặc một
phạm vi dữ liệu không được ghi?

Kiểm tra hệ thống tệp trực tuyến đánh giá tính nhất quán của từng siêu dữ liệu chính
ghi lại bằng cách so sánh thông tin của nó với tất cả các chỉ số không gian khác.
Chỉ số ánh xạ ngược đóng vai trò chính trong quá trình kiểm tra tính nhất quán
bởi vì nó chứa một bản sao thay thế tập trung của tất cả việc phân bổ không gian
thông tin.
Thời gian chạy chương trình và sự dễ dàng trong việc thu thập tài nguyên là những giới hạn thực sự duy nhất đối với
những gì kiểm tra trực tuyến có thể tham khảo.
Ví dụ: có thể kiểm tra ánh xạ phạm vi dữ liệu tệp:

* Sự vắng mặt của một mục trong thông tin không gian trống.
* Sự vắng mặt của một mục trong chỉ mục inode.
* Sự vắng mặt của mục trong dữ liệu đếm tham chiếu nếu tệp không có
  được đánh dấu là có phạm vi chia sẻ.
* Sự tương ứng của một mục trong thông tin ánh xạ ngược.

Có một số quan sát cần thực hiện về các chỉ số ánh xạ ngược:

1. Ánh xạ ngược có thể đưa ra sự khẳng định tích cực về tính đúng đắn nếu có bất kỳ
   siêu dữ liệu chính ở trên đang bị nghi ngờ.
   Mã kiểm tra cho hầu hết siêu dữ liệu chính đều đi theo một đường dẫn tương tự như
   một điều đã được nêu ở trên.

2. Chứng minh tính nhất quán của siêu dữ liệu thứ cấp với siêu dữ liệu chính là
   khó khăn vì điều đó đòi hỏi phải quét toàn bộ siêu dữ liệu của không gian chính,
   việc này rất tốn thời gian.
   Ví dụ: kiểm tra bản ghi ánh xạ ngược để ánh xạ phạm vi tệp
   khối btree yêu cầu khóa tệp và tìm kiếm toàn bộ btree để
   xác nhận khối.
   Thay vào đó, chà dựa vào tham chiếu chéo nghiêm ngặt trong không gian chính
   kiểm tra cấu trúc ánh xạ.

3. Quét nhất quán phải sử dụng các nguyên tắc thu thập khóa không chặn nếu
   Thứ tự khóa bắt buộc không giống thứ tự được sử dụng bởi hệ thống tập tin thông thường
   hoạt động.
   Ví dụ: nếu hệ thống tệp thường lấy tệp ILOCK trước khi lấy
   khóa bộ đệm AGF nhưng chà muốn lấy tệp ILOCK trong khi giữ
   khóa bộ đệm AGF, bộ lọc không thể chặn trong lần thu thập thứ hai đó.
   Điều này có nghĩa là tiến trình chuyển tiếp trong phần này của quá trình quét ngược lại
   dữ liệu ánh xạ không thể được đảm bảo nếu tải hệ thống nặng.

Tóm lại, ánh xạ ngược đóng một vai trò quan trọng trong việc tái cấu trúc sơ cấp
siêu dữ liệu.
Chi tiết về cách các bản ghi này được sắp xếp, ghi vào đĩa và được cam kết
vào hệ thống tập tin được đề cập trong các phần tiếp theo.

Kiểm tra và tham khảo chéo
------------------------------

Bước đầu tiên của việc kiểm tra cấu trúc siêu dữ liệu là kiểm tra mọi bản ghi
chứa trong cấu trúc và mối quan hệ của nó với phần còn lại của
hệ thống.
XFS chứa nhiều lớp kiểm tra để cố gắng ngăn chặn sự không nhất quán
siêu dữ liệu khỏi sự tàn phá hệ thống.
Mỗi lớp này đóng góp thông tin giúp hạt nhân tạo ra
ba quyết định về tình trạng của cấu trúc siêu dữ liệu:

- Rõ ràng là một phần của cấu trúc này đã bị hỏng (ZZ0000ZZ)?
- Cấu trúc này có mâu thuẫn với phần còn lại của hệ thống không?
  (ZZ0001ZZ) ?
- Có quá nhiều thiệt hại xung quanh hệ thống tập tin mà việc tham chiếu chéo không được thực hiện
  có thể (ZZ0002ZZ)?
- Cấu trúc có thể được tối ưu hóa để cải thiện hiệu suất hoặc giảm kích thước của
  siêu dữ liệu (ZZ0003ZZ)?
- Cấu trúc có chứa dữ liệu không nhất quán nhưng đáng được xem xét lại không
  bởi quản trị viên hệ thống (ZZ0004ZZ)?

Các phần sau đây mô tả cách hoạt động của quá trình lọc siêu dữ liệu.

Xác minh bộ đệm siêu dữ liệu
````````````````````````````

Lớp bảo vệ siêu dữ liệu thấp nhất trong XFS là các trình xác minh siêu dữ liệu được xây dựng
vào bộ đệm đệm.
Các chức năng này thực hiện kiểm tra tính nhất quán nội bộ của khối một cách rẻ tiền.
chính nó và trả lời những câu hỏi sau:

- Khối này có thuộc về hệ thống tập tin này không?

- Khối có thuộc cấu trúc yêu cầu đọc không?
  Điều này giả định rằng các khối siêu dữ liệu chỉ có một chủ sở hữu, điều này luôn đúng
  trong XFS.

- Loại dữ liệu được lưu trữ trong khối có nằm trong phạm vi hợp lý của những gì không?
  chà đang mong đợi?

- Vị trí vật lý của khối có khớp với vị trí nó được đọc không?

- Tổng kiểm tra khối có khớp với dữ liệu không?

Phạm vi bảo vệ ở đây rất hạn chế -- người xác minh chỉ có thể
chứng minh rằng mã hệ thống tập tin hợp lý không có lỗi hỏng nặng
và hệ thống lưu trữ có khả năng truy xuất hợp lý.
Các vấn đề tham nhũng được quan sát thấy trong thời gian chạy gây ra việc tạo ra các báo cáo sức khỏe,
các cuộc gọi hệ thống không thành công và trong trường hợp cực đoan, hệ thống tập tin sẽ tắt nếu
siêu dữ liệu bị hỏng buộc phải hủy bỏ một giao dịch bẩn.

Mọi chức năng lọc fsck trực tuyến đều phải đọc mọi siêu dữ liệu ondisk
khối kết cấu trong quá trình kiểm tra kết cấu.
Các vấn đề tham nhũng được phát hiện trong quá trình kiểm tra sẽ được báo cáo ngay lập tức cho
không gian người dùng bị tham nhũng; trong quá trình tham khảo chéo, chúng được báo cáo là
không tham khảo chéo sau khi hoàn thành bài kiểm tra đầy đủ.
Đọc hài lòng bởi bộ đệm đã có trong bộ đệm (và do đó đã được xác minh)
bỏ qua những kiểm tra này.

Kiểm tra tính nhất quán nội bộ
```````````````````````````

Sau bộ đệm đệm, cấp độ bảo vệ siêu dữ liệu tiếp theo là nội bộ
ghi lại mã xác minh được tích hợp vào hệ thống tập tin.
Các bước kiểm tra này được phân chia giữa những người xác minh bộ đệm, những người dùng trong hệ thống tập tin của
bộ đệm đệm và chính mã xóa, tùy thuộc vào số lượng cao hơn
mức độ bối cảnh cần thiết.
Phạm vi kiểm tra vẫn là nội bộ khối.
Các chức năng kiểm tra cấp cao hơn này trả lời những câu hỏi sau:

- Loại dữ liệu được lưu trữ trong khối có khớp với những gì được mong đợi không?

- Khối có thuộc cấu trúc sở hữu yêu cầu đọc không?

- Nếu khối chứa các bản ghi, các bản ghi có nằm trong khối không?

- Nếu khối theo dõi thông tin không gian trống bên trong, nó có phù hợp với
  các khu vực kỷ lục?

- Các hồ sơ chứa bên trong khối có bị sai sót rõ ràng không?

Việc kiểm tra hồ sơ trong danh mục này nghiêm ngặt hơn và tốn nhiều thời gian hơn.
Ví dụ: con trỏ khối và inumbers được kiểm tra để đảm bảo rằng chúng trỏ tới
trong các phần được phân bổ động của nhóm phân bổ và trong
hệ thống tập tin.
Tên được kiểm tra các ký tự không hợp lệ và cờ được kiểm tra không hợp lệ
sự kết hợp.
Các thuộc tính bản ghi khác được kiểm tra các giá trị hợp lý.
Các bản ghi Btree trải dài trong một khoảng của không gian khóa btree được kiểm tra
thứ tự đúng và thiếu khả năng hợp nhất (ngoại trừ ánh xạ ngã ba tệp).
Vì lý do hiệu suất, mã thông thường có thể bỏ qua một số bước kiểm tra này trừ khi
gỡ lỗi được kích hoạt hoặc việc ghi sắp xảy ra.
Tất nhiên, chức năng chà phải kiểm tra tất cả các vấn đề có thể xảy ra.

Xác thực các thuộc tính bản ghi do không gian người dùng kiểm soát
````````````````````````````````````````````````````

Nhiều phần siêu dữ liệu hệ thống tập tin khác nhau được không gian người dùng kiểm soát trực tiếp.
Vì tính chất này, công việc xác nhận không thể chính xác hơn việc kiểm tra
rằng một giá trị nằm trong phạm vi có thể.
Các trường này bao gồm:

- Các trường Superblock được điều khiển bởi các tùy chọn gắn kết
- Nhãn hệ thống tập tin
- Dấu thời gian tập tin
- Quyền tập tin
- Kích thước tập tin
- Tập tin cờ
- Tên hiện diện trong các mục thư mục, khóa thuộc tính mở rộng và hệ thống tập tin
  nhãn
- Không gian tên khóa thuộc tính mở rộng
- Giá trị thuộc tính mở rộng
- Nội dung khối dữ liệu file
- Giới hạn hạn ngạch
- Hết hạn định giờ (nếu mức sử dụng tài nguyên vượt quá giới hạn mềm)

Siêu dữ liệu không gian tham chiếu chéo
````````````````````````````````

Sau khi kiểm tra khối nội bộ, cấp độ kiểm tra cao hơn tiếp theo là
các bản ghi tham chiếu chéo giữa các cấu trúc siêu dữ liệu.
Đối với mã thời gian chạy thông thường, chi phí của những lần kiểm tra này được coi là
cực kỳ tốn kém, nhưng vì chà được dành riêng để loại bỏ tận gốc
mâu thuẫn, nó phải theo đuổi mọi con đường điều tra.
Tập hợp tham chiếu chéo chính xác phụ thuộc rất nhiều vào bối cảnh của
cấu trúc dữ liệu đang được kiểm tra

Mã btree XFS có chức năng quét không gian phím mà fsck trực tuyến sử dụng để
tham chiếu chéo cấu trúc này với cấu trúc khác.
Cụ thể, chà có thể quét không gian khóa của một chỉ mục để xác định xem liệu đó có phải là không gian khóa không.
không gian khóa đầy đủ, thưa thớt hoặc hoàn toàn không được ánh xạ tới các bản ghi.
Đối với btree ánh xạ ngược, có thể che các phần của khóa cho
mục đích thực hiện quét không gian phím để bộ lọc có thể quyết định xem rmap có
btree chứa các bản ghi ánh xạ một phạm vi không gian vật lý nhất định mà không có
sự thưa thớt của phần còn lại của không gian phím rmap đang cản trở.

Các khối Btree trải qua các bước kiểm tra sau trước khi tham khảo chéo:

- Loại dữ liệu được lưu trữ trong khối có khớp với những gì được mong đợi không?

- Khối có thuộc cấu trúc sở hữu yêu cầu đọc không?

- Các bản ghi có vừa với khối không?

- Các hồ sơ chứa bên trong khối có bị sai sót rõ ràng không?

- Tên băm có đúng thứ tự không?

- Thực hiện các con trỏ nút trong btree trỏ tới các địa chỉ khối hợp lệ cho loại
  của btree?

- Con trỏ con có hướng về phía lá không?

- Các con trỏ anh chị em có trỏ qua cùng cấp độ không?

- Đối với mỗi bản ghi khối nút, khóa bản ghi có phản ánh chính xác nội dung không?
  của khối con?

Hồ sơ phân bổ không gian được tham chiếu chéo như sau:

1. Bất kỳ khoảng trống nào được đề cập bởi bất kỳ cấu trúc siêu dữ liệu nào đều được tham chiếu chéo dưới dạng
   sau:

- Chỉ mục ánh xạ ngược có liệt kê chỉ chủ sở hữu thích hợp làm
     chủ sở hữu của mỗi khối?

- Không có khối nào được coi là không gian trống?

- Nếu đây không phải là khối dữ liệu tệp thì không có khối nào được coi là không gian
     được chia sẻ bởi các chủ sở hữu khác nhau?

2. Các khối Btree được tham chiếu chéo như sau:

- Tất cả mọi thứ ở lớp 1 ở trên.

- Nếu có khối nút cha, các khóa được liệt kê cho khối này có khớp với
     không gian phím của khối này?

- Các con trỏ anh em có trỏ đến các khối hợp lệ không?  Cùng đẳng cấp?

- Các con trỏ con có trỏ đến các khối hợp lệ không?  Cấp độ tiếp theo xuống?

3. Các bản ghi btree không gian trống được tham chiếu chéo như sau:

- Tất cả mọi thứ ở lớp 1 và 2 ở trên.

- Chỉ mục ánh xạ ngược có liệt kê không có chủ sở hữu của không gian này không?

- Không gian này không được chỉ số inode cho inode xác nhận phải không?

- Có phải nó không được đề cập bởi chỉ số đếm tham chiếu?

- Có bản ghi trùng khớp trong btree không gian trống khác không?

4. Các bản ghi Inode btree được tham chiếu chéo như sau:

- Tất cả mọi thứ ở lớp 1 và 2 ở trên.

- Có bản ghi trùng khớp trong btree inode miễn phí không?

- Các bit bị xóa trong mặt nạ lỗ có tương ứng với cụm inode không?

- Đặt các bit trong freemask tương ứng với các bản ghi inode có liên kết 0
     đếm?

5. Các bản ghi Inode được tham chiếu chéo như sau:

- Mọi thứ ở lớp 1.

- Thực hiện tất cả các trường tóm tắt thông tin về file fork
     phù hợp với những chiếc nĩa đó?

- Mỗi inode có số lượng liên kết bằng 0 có tương ứng với một bản ghi trong
     inode btree?

6. Các bản ghi ánh xạ không gian nhánh tệp được tham chiếu chéo như sau:

- Tất cả mọi thứ ở lớp 1 và 2 ở trên.

- Không gian này không được btrees inode nhắc đến phải không?

- Nếu đây là ánh xạ nhánh CoW, nó có tương ứng với mục nhập CoW trong
     số lượng tài liệu tham khảo btree?

7. Hồ sơ đếm tham chiếu được tham chiếu chéo như sau:

- Tất cả mọi thứ ở lớp 1 và 2 ở trên.

- Trong không gian khóa con space của rmap btree (có nghĩa là, tất cả
     bản ghi được ánh xạ tới một phạm vi không gian cụ thể và bỏ qua thông tin chủ sở hữu),
     có cùng số lượng bản ghi ánh xạ ngược cho mỗi khối như
     số lượng tài liệu tham khảo xác nhận quyền sở hữu?

Kiểm tra thuộc tính mở rộng
````````````````````````````

Thuộc tính mở rộng triển khai kho lưu trữ khóa-giá trị cho phép phân đoạn dữ liệu
để được đính kèm vào bất kỳ tập tin.
Cả kernel và không gian người dùng đều có thể truy cập các khóa và giá trị, tùy thuộc vào
không gian tên và hạn chế đặc quyền.
Thông thường nhất, các đoạn này là siêu dữ liệu về tệp -- nguồn gốc, bảo mật
ngữ cảnh, nhãn do người dùng cung cấp, thông tin lập chỉ mục, v.v.

Tên có thể dài tới 255 byte và có thể tồn tại ở nhiều dạng khác nhau
không gian tên.
Giá trị có thể lớn tới 64KB.
Các thuộc tính mở rộng của tệp được lưu trữ trong các khối được ánh xạ bởi ngã ba attr.
Ánh xạ trỏ tới các khối lá, khối giá trị từ xa hoặc khối dabtree.
Khối 0 trong ngã ba thuộc tính luôn ở trên cùng của cấu trúc, nhưng nếu không thì
mỗi loại trong số ba loại khối có thể được tìm thấy ở bất kỳ phần bù nào trong ngã ba attr.
Các khối lá chứa các bản ghi khóa thuộc tính trỏ đến tên và giá trị.
Tên luôn được lưu trữ ở nơi khác trong cùng một khối lá.
Các giá trị nhỏ hơn 3/4 kích thước của khối hệ thống tệp cũng được lưu trữ
nơi khác trong cùng một khối lá.
Các khối giá trị từ xa chứa các giá trị quá lớn để vừa với một chiếc lá.
Nếu thông tin lá vượt quá một khối hệ thống tập tin duy nhất, một dabtree (cũng
bắt nguồn từ khối 0) được tạo để ánh xạ các giá trị băm của tên thuộc tính vào lá
các khối trong ngã ba attr.

Việc kiểm tra cấu trúc thuộc tính mở rộng không đơn giản như vậy do
thiếu sự tách biệt giữa khối attr và khối chỉ mục.
Scrub phải đọc từng khối được ánh xạ bởi attr fork và bỏ qua khối không có lá
khối:

1. Đưa cây dabtree vào ngã ba attr (nếu có) để đảm bảo rằng không có
   sự bất thường trong các khối hoặc ánh xạ dabtree không trỏ đến
   khối lá attr.

2. Đi qua các khối ở ngã ba attr để tìm các khối lá.
   Đối với mỗi mục bên trong một chiếc lá:

Một. Xác thực rằng tên không chứa ký tự không hợp lệ.

b. Đọc giá trị attr.
      Điều này thực hiện tra cứu có tên của tên attr để đảm bảo tính chính xác
      của cây dabtree.
      Nếu giá trị được lưu trữ trong một khối từ xa, điều này cũng xác nhận
      tính toàn vẹn của khối giá trị từ xa.

Kiểm tra và tham khảo chéo các thư mục
``````````````````````````````````````````

Cây thư mục hệ thống tập tin là một cấu trúc đồ thị acylic có hướng, với các tập tin
tạo thành các nút và các mục thư mục (hướng) tạo thành các cạnh.
Thư mục là một loại tập tin đặc biệt chứa một tập hợp các ánh xạ từ một
Chuỗi (tên) 255 byte thành inumber.
Chúng được gọi là mục nhập thư mục hoặc viết tắt là dirents.
Mỗi tệp thư mục phải có chính xác một thư mục trỏ đến tệp.
Một thư mục gốc trỏ đến chính nó.
Các mục trong thư mục trỏ đến các tập tin thuộc bất kỳ loại nào.
Mỗi tệp không phải thư mục có thể có nhiều thư mục trỏ đến nó.

Trong XFS, các thư mục được triển khai dưới dạng tệp chứa tối đa ba 32GB
phân vùng.
Phân vùng đầu tiên chứa các khối dữ liệu mục nhập thư mục.
Mỗi khối dữ liệu chứa các bản ghi có kích thước thay đổi liên kết với một địa chỉ do người dùng cung cấp.
tên bằng inumber và tùy chọn loại tệp.
Nếu dữ liệu mục nhập thư mục phát triển vượt quá một khối, phân vùng thứ hai (được
tồn tại dưới dạng phạm vi sau EOF) được điền với một khối chứa không gian trống
thông tin và chỉ mục ánh xạ các giá trị băm của tên trực tiếp vào dữ liệu thư mục
các khối trong phân vùng đầu tiên.
Điều này làm cho việc tra cứu tên thư mục rất nhanh.
Nếu phân vùng thứ hai này phát triển vượt quá một khối thì phân vùng thứ ba là
được cung cấp một mảng thông tin không gian trống tuyến tính để nhanh hơn
mở rộng.
Nếu không gian trống đã được tách ra và phân vùng thứ hai sẽ phát triển trở lại
ngoài một khối, thì dabtree được sử dụng để ánh xạ các giá trị băm của các tên khác nhau tới
khối dữ liệu thư mục.

Kiểm tra một thư mục khá đơn giản:

1. Di chuyển cây dabtree vào phân vùng thứ hai (nếu có) để đảm bảo rằng có
   không có sự bất thường nào trong các khối hoặc ánh xạ dabtree mà không trỏ đến
   khối trực tiếp.

2. Đi dọc các khối của phân vùng đầu tiên để tìm các mục trong thư mục.
   Mỗi hướng được kiểm tra như sau:

Một. Tên có chứa ký tự không hợp lệ không?

b. Inumber có tương ứng với một inode thực tế được phân bổ không?

c. Inode con có số lượng liên kết khác 0 không?

d. Nếu một loại tệp được bao gồm trong thư mục, nó có khớp với loại của tệp không?
      nút?

đ. Nếu đứa trẻ là một thư mục con, con trỏ dấu chấm của đứa trẻ có trỏ tới không
      về với cha mẹ?

f. Nếu thư mục có phân vùng thứ hai, hãy thực hiện tra cứu có tên của
      tên dirent để đảm bảo tính chính xác của dabtree.

3. Kiểm tra danh sách dung lượng trống trong phân vùng thứ ba (nếu có) để đảm bảo rằng
   những không gian trống mà nó mô tả thực sự không được sử dụng.

Kiểm tra các hoạt động liên quan đến ZZ0000ZZ và
ZZ0001ZZ sẽ được thảo luận chi tiết hơn ở phần sau
phần.

Kiểm tra cây thư mục/thuộc tính
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Như đã nêu ở các phần trước, chỉ mục thư mục/thuộc tính btree (dabtree)
ánh xạ các tên do người dùng cung cấp để cải thiện thời gian tra cứu bằng cách tránh quét tuyến tính.
Trong nội bộ, nó ánh xạ hàm băm 32 bit của tên tới phần bù khối trong
nĩa tập tin thích hợp.

Cấu trúc bên trong của dabtree gần giống với btrees ghi lại
bản ghi siêu dữ liệu có kích thước cố định -- mỗi khối dabtree chứa một số ma thuật, một
tổng kiểm tra, con trỏ anh em, UUID, cấp độ cây và số thứ tự nhật ký.
Định dạng của các bản ghi lá và nút giống nhau -- mỗi mục nhập trỏ đến
cấp độ tiếp theo trong hệ thống phân cấp, với các bản ghi nút dabtree trỏ đến dabtree
khối lá và bản ghi lá dabtree trỏ đến các khối không phải dabtree ở nơi khác
trong cái nĩa.

Việc kiểm tra và tham chiếu chéo dabtree rất giống với những gì được thực hiện đối với
cây không gian:

- Loại dữ liệu được lưu trữ trong khối có khớp với những gì được mong đợi không?

- Khối có thuộc cấu trúc sở hữu yêu cầu đọc không?

- Các bản ghi có vừa với khối không?

- Các hồ sơ chứa bên trong khối có bị sai sót rõ ràng không?

- Tên băm có đúng thứ tự không?

- Thực hiện các con trỏ nút trong điểm dabtree tới các offset rẽ nhánh hợp lệ cho dabtree
  khối?

- Thực hiện các con trỏ lá trong điểm dabtree tới các offset rẽ nhánh hợp lệ cho thư mục
  hoặc khối lá attr?

- Con trỏ con có hướng về phía lá không?

- Các con trỏ anh chị em có trỏ qua cùng cấp độ không?

- Đối với mỗi bản ghi nút dabtree, khóa bản ghi có phản ánh chính xác không?
  nội dung của khối dabtree con?

- Đối với mỗi bản ghi lá dabtree, khóa bản ghi có phản ánh chính xác không?
  nội dung của thư mục hoặc khối attr?

Bộ đếm tóm tắt tham chiếu chéo
``````````````````````````````````

XFS duy trì ba loại bộ đếm tóm tắt: tài nguyên sẵn có, hạn ngạch
việc sử dụng tài nguyên và số lượng liên kết tập tin.

Về lý thuyết, lượng tài nguyên sẵn có (khối dữ liệu, nút, thời gian thực
mức độ) có thể được tìm thấy bằng cách duyệt qua toàn bộ hệ thống tập tin.
Điều này sẽ làm cho việc báo cáo rất chậm, do đó hệ thống tập tin giao dịch có thể
duy trì bản tóm tắt thông tin này trong siêu khối.
Việc tham chiếu chéo các giá trị này với siêu dữ liệu hệ thống tập tin phải là một
vấn đề đơn giản là di chuyển không gian trống và siêu dữ liệu inode trong mỗi AG và
bitmap thời gian thực, nhưng có những vấn đề phức tạp sẽ được thảo luận trong
ZZ0000ZZ sau này.

ZZ0000ZZ và ZZ0001ZZ
việc kiểm tra đủ phức tạp để đảm bảo có các phần riêng biệt.

Xác minh lại sau sửa chữa
``````````````````````````

Sau khi thực hiện sửa chữa, mã kiểm tra sẽ được chạy lần thứ hai để xác thực
cấu trúc mới và kết quả đánh giá sức khỏe được ghi lại
nội bộ và quay lại quá trình gọi.
Bước này rất quan trọng để cho phép quản trị viên hệ thống theo dõi trạng thái
của hệ thống tập tin và tiến trình của bất kỳ sửa chữa nào.
Đối với các nhà phát triển, đây là một phương tiện hữu ích để đánh giá hiệu quả của việc phát hiện lỗi
và sửa lỗi trong các công cụ kiểm tra trực tuyến và ngoại tuyến.

Tính nhất quán cuối cùng so với Fsck trực tuyến
------------------------------------

Các hoạt động phức tạp có thể thực hiện sửa đổi đối với nhiều cấu trúc dữ liệu trên mỗi AG
với một chuỗi giao dịch.
Các chuỗi này, sau khi được cam kết với nhật ký, sẽ được khởi động lại trong quá trình khôi phục nhật ký nếu
hệ thống gặp sự cố trong khi xử lý chuỗi.
Bởi vì bộ đệm tiêu đề AG được mở khóa giữa các giao dịch trong chuỗi,
kiểm tra trực tuyến phải phối hợp với các hoạt động xâu chuỗi đang được tiến hành để
tránh phát hiện không chính xác sự không nhất quán do chuỗi đang chờ xử lý.
Hơn nữa, sửa chữa trực tuyến không được chạy khi các hoạt động đang chờ xử lý vì
siêu dữ liệu tạm thời không nhất quán với nhau và việc xây dựng lại là
không thể được.

Chỉ fsck trực tuyến mới có yêu cầu này về tính nhất quán hoàn toàn của siêu dữ liệu AG và
nên tương đối hiếm so với các hoạt động thay đổi hệ thống tập tin.
Fsck trực tuyến phối hợp với các chuỗi giao dịch như sau:

* Đối với mỗi AG, hãy duy trì số lượng mục đích nhắm mục tiêu vào AG đó.
  Số lượng sẽ được tăng lên bất cứ khi nào một mục mới được thêm vào chuỗi.
  Số lượng sẽ bị loại bỏ khi hệ thống tập tin đã khóa tiêu đề AG
  bộ đệm và hoàn thành công việc.

* Khi fsck trực tuyến muốn kiểm tra AG, nó sẽ khóa tiêu đề AG
  bộ đệm để ngừng hoạt động tất cả các chuỗi giao dịch muốn sửa đổi AG đó.
  Nếu số đếm bằng 0, hãy tiến hành thao tác kiểm tra.
  Nếu nó khác 0, hãy xoay vòng khóa bộ đệm để cho phép chuỗi tiến về phía trước
  tiến bộ.

Điều này có thể dẫn đến việc fsck trực tuyến mất nhiều thời gian để hoàn thành, nhưng thường xuyên
cập nhật hệ thống tập tin được ưu tiên hơn hoạt động kiểm tra lý lịch.
Thông tin chi tiết về việc phát hiện ra tình huống này được trình bày trong
ZZ0000ZZ và thông tin chi tiết về giải pháp
được trình bày ZZ0001ZZ.

.. _chain_coordination:

Khám phá vấn đề
````````````````````````

Đang trong quá trình phát triển tính năng lọc trực tuyến, các bài kiểm tra fsstress
đã phát hiện ra sự tương tác sai giữa fsck trực tuyến và chuỗi giao dịch phức hợp
được tạo bởi các chủ đề người viết khác dẫn đến báo cáo sai về siêu dữ liệu
sự không nhất quán.
Nguyên nhân cốt lõi của những báo cáo này là mô hình nhất quán cuối cùng được giới thiệu bởi
việc mở rộng các hạng mục công việc trả chậm và chuỗi giao dịch phức tạp khi
ánh xạ ngược và liên kết lại đã được giới thiệu.

Ban đầu, chuỗi giao dịch được thêm vào XFS để tránh bế tắc khi
hủy ánh xạ không gian khỏi các tập tin.
Quy tắc tránh bế tắc yêu cầu các AG chỉ bị khóa theo thứ tự tăng dần,
điều này làm cho không thể (chẳng hạn) sử dụng một giao dịch để giải phóng không gian
phạm vi trong AG 7 và sau đó cố gắng giải phóng khối btree ánh xạ khối hiện không cần thiết
ở AG3.
Để tránh những kiểu bế tắc này, XFS tạo nhật ký Ý định giải phóng mức độ (EFI)
các mục để cam kết giải phóng một số không gian trong một giao dịch trong khi trì hoãn
cập nhật siêu dữ liệu thực tế cho một giao dịch mới.
Trình tự giao dịch trông như thế này:

1. Giao dịch đầu tiên chứa bản cập nhật vật lý cho ánh xạ khối của tệp
   cấu trúc để loại bỏ ánh xạ khỏi các khối btree.
   Sau đó nó gắn vào giao dịch trong bộ nhớ một mục hành động để lên lịch
   trì hoãn việc giải phóng không gian.
   Cụ thể, mỗi giao dịch duy trì một danh sách các đối tượng ZZ0000ZZ, mỗi giao dịch duy trì một danh sách các đối tượng ZZ0001ZZ.
   Quay lại ví dụ trên, mục hành động theo dõi việc giải phóng cả hai
   không gian chưa được ánh xạ từ AG 7 và khối btree ánh xạ khối (BMBT) từ
   AG 3.
   Các khoản giải phóng bị trì hoãn được ghi theo cách này được cam kết trong nhật ký bằng cách tạo
   một mục nhật ký EFI từ đối tượng ZZ0002ZZ và
   đính kèm mục nhật ký vào giao dịch.
   Khi nhật ký được lưu vào đĩa, mục EFI sẽ được ghi vào ondisk
   bản ghi giao dịch.
   EFI có thể liệt kê tối đa 16 phạm vi miễn phí, tất cả được sắp xếp theo thứ tự AG.

2. Giao dịch thứ hai chứa bản cập nhật vật lý cho các cây không gian trống
   của AG 3 để phát hành khối BMBT trước đây và bản cập nhật vật lý thứ hai cho
   btrees không gian trống của AG 7 để giải phóng không gian tệp chưa được ánh xạ.
   Quan sát xem các bản cập nhật vật lý có được sắp xếp lại theo đúng thứ tự không
   khi có thể.
   Kèm theo giao dịch là một mục nhật ký được thực hiện miễn phí trong phạm vi (EFD).
   EFD chứa một con trỏ tới EFI đã đăng nhập vào giao dịch #1 để nhật ký đó
   recovery có thể cho biết liệu EFI có cần được phát lại hay không.

Nếu hệ thống ngừng hoạt động sau khi giao dịch #1 được ghi lại vào hệ thống tập tin
nhưng trước khi #2 được cam kết, việc quét siêu dữ liệu hệ thống tệp sẽ hiển thị
siêu dữ liệu hệ thống tập tin không nhất quán vì dường như không có chủ sở hữu nào
của không gian chưa được lập bản đồ.
Thật may mắn là việc khôi phục nhật ký sẽ khắc phục sự không nhất quán này cho chúng tôi -- khi quá trình khôi phục tìm thấy
một mục nhật ký ý định nhưng không tìm thấy mục ý định đã thực hiện tương ứng, nó sẽ
xây dựng lại trạng thái cốt lõi của mục mục đích và hoàn thành nó.
Trong ví dụ trên, nhật ký phải phát lại cả hai bản giải phóng được mô tả trong tệp đã được khôi phục.
EFI để hoàn thành giai đoạn phục hồi.

Có những điểm tinh tế trong chiến lược chuỗi giao dịch của XFS cần xem xét:

* Các mục nhật ký phải được thêm vào giao dịch theo đúng thứ tự để ngăn chặn
  xung đột với các đối tượng chính không được giao dịch nắm giữ.
  Nói cách khác, tất cả các cập nhật siêu dữ liệu trên mỗi AG cho một khối chưa được ánh xạ phải
  hoàn thành trước lần cập nhật cuối cùng để giải phóng phạm vi và các phạm vi sẽ không
  được phân bổ lại cho đến khi bản cập nhật cuối cùng đó được ghi vào nhật ký.

* Bộ đệm tiêu đề AG được giải phóng giữa mỗi giao dịch trong chuỗi.
  Điều này có nghĩa là các luồng khác có thể quan sát AG ở trạng thái trung gian,
  nhưng miễn là sự tinh tế đầu tiên được xử lý, điều này sẽ không ảnh hưởng đến
  tính chính xác của các hoạt động của hệ thống tập tin.

* Việc ngắt kết nối hệ thống tập tin sẽ xóa tất cả công việc đang chờ xử lý vào đĩa, điều đó có nghĩa là
  fsck ngoại tuyến không bao giờ thấy sự mâu thuẫn tạm thời do trì hoãn gây ra
  xử lý hạng mục công việc.

Theo cách này, XFS sử dụng một hình thức nhất quán cuối cùng để tránh bế tắc
và tăng tính song song.

Trong giai đoạn thiết kế các tính năng ánh xạ ngược và liên kết lại, cần
đã quyết định rằng việc nhồi nhét tất cả các bản cập nhật ánh xạ ngược cho một
hệ thống tập tin đơn lẻ thay đổi thành một giao dịch duy nhất vì một tập tin duy nhất
hoạt động lập bản đồ có thể bùng nổ thành nhiều cập nhật nhỏ:

* Bản thân bản cập nhật ánh xạ khối
* Bản cập nhật ánh xạ ngược cho bản cập nhật ánh xạ khối
* Sửa danh sách miễn phí
* Bản cập nhật ánh xạ ngược cho bản sửa lỗi danh sách miễn phí

* Một sự thay đổi hình dạng đối với btree ánh xạ khối
* Bản cập nhật ánh xạ ngược cho bản cập nhật btree
* Sửa danh sách miễn phí (một lần nữa)
* Bản cập nhật ánh xạ ngược cho bản sửa lỗi danh sách miễn phí

* Cập nhật thông tin đếm tham chiếu
* Bản cập nhật ánh xạ ngược cho bản cập nhật số tiền hoàn lại
* Sửa danh sách miễn phí (lần thứ ba)
* Bản cập nhật ánh xạ ngược cho bản sửa lỗi danh sách miễn phí

* Giải phóng mọi không gian chưa được ánh xạ và không thuộc sở hữu của bất kỳ tệp nào khác
* Sửa danh sách miễn phí (lần thứ tư)
* Bản cập nhật ánh xạ ngược cho bản sửa lỗi danh sách miễn phí

* Giải phóng không gian được sử dụng bởi btree ánh xạ khối
* Sửa danh sách miễn phí (lần thứ năm)
* Bản cập nhật ánh xạ ngược cho bản sửa lỗi danh sách miễn phí

Việc sửa danh sách miễn phí thường không cần thiết nhiều hơn một lần cho mỗi AG cho mỗi giao dịch
nhưng về mặt lý thuyết thì có thể thực hiện được nếu không gian rất chật hẹp.
Đối với các bản cập nhật sao chép khi ghi, điều này thậm chí còn tệ hơn, vì việc này phải được thực hiện một lần để
xóa khoảng trắng khỏi khu vực tổ chức và một lần nữa để ánh xạ nó vào tệp!

Để đối phó với vụ nổ này một cách bình tĩnh, XFS mở rộng việc sử dụng thời gian trả chậm
các mục công việc bao gồm hầu hết các cập nhật về bản đồ ngược và tất cả các cập nhật về số tiền hoàn lại.
Điều này làm giảm quy mô trường hợp xấu nhất của việc đặt trước giao dịch bằng cách phá vỡ
làm việc thành một chuỗi dài các cập nhật nhỏ, làm tăng mức độ cuối cùng
tính nhất quán trong hệ thống.
Một lần nữa, điều này thường không phải là vấn đề vì XFS yêu cầu hoãn công việc
các mục một cách cẩn thận để tránh xung đột tái sử dụng tài nguyên giữa các luồng không nghi ngờ.

Tuy nhiên, fsck trực tuyến thay đổi các quy tắc -- hãy nhớ rằng mặc dù
các cập nhật cho cấu trúc trên mỗi AG được điều phối bằng cách khóa bộ đệm cho AG
tiêu đề, khóa bộ đệm bị loại bỏ giữa các giao dịch.
Sau khi chà lấy tài nguyên và lấy khóa cho cấu trúc dữ liệu, nó phải thực hiện
tất cả công việc xác nhận mà không cần giải phóng khóa.
Nếu khóa chính cho btree không gian là khóa bộ đệm tiêu đề AG, thì việc chà có thể có
làm gián đoạn một luồng khác đang trong quá trình hoàn thành một chuỗi.
Ví dụ: nếu một luồng thực hiện sao chép khi ghi đã hoàn thành việc đảo ngược
cập nhật ánh xạ nhưng không cập nhật số lần đếm tương ứng, hai btree AG
sẽ xuất hiện không nhất quán để chà và quan sát tham nhũng sẽ được
được ghi lại.  Quan sát này sẽ không chính xác.
Nếu cố gắng sửa chữa ở trạng thái này, kết quả sẽ rất thảm khốc!

Một số giải pháp khác cho vấn đề này đã được đánh giá khi phát hiện ra điều này
sai sót và bị từ chối:

1. Thêm khóa cấp cao hơn vào các nhóm phân bổ và yêu cầu các chủ đề của người viết
   lấy khóa cấp cao hơn theo thứ tự AG trước khi thực hiện bất kỳ thay đổi nào.
   Điều này sẽ rất khó thực hiện trong thực tế vì nó
   khó xác định những khóa nào cần lấy và theo thứ tự nào,
   mà không mô phỏng toàn bộ hoạt động.
   Việc thực hiện thao tác chạy thử tệp để khám phá các khóa cần thiết sẽ
   làm cho hệ thống tập tin rất chậm.

2. Làm cho mã điều phối viên công việc bị hoãn lại nhận biết được các mục mục đích liên tiếp
   nhắm mục tiêu cùng một AG và giữ nó giữ bộ đệm tiêu đề AG bị khóa trên
   cuộn giao dịch giữa các bản cập nhật.
   Điều này sẽ tạo ra rất nhiều sự phức tạp cho bộ điều phối vì nó
   chỉ được kết hợp lỏng lẻo với các hạng mục công việc bị trì hoãn thực tế.
   Nó cũng sẽ không giải quyết được vấn đề vì các hạng mục công việc bị trì hoãn có thể
   tạo các nhiệm vụ con bị trì hoãn mới, nhưng tất cả các nhiệm vụ phụ phải được hoàn thành trước
   công việc có thể bắt đầu với một nhiệm vụ anh chị em mới.

3. Hướng dẫn fsck trực tuyến cách thực hiện tất cả các giao dịch đang chờ (các) khóa nào
   bảo vệ cấu trúc dữ liệu đang bị xóa để tìm kiếm các hoạt động đang chờ xử lý.
   Các hoạt động kiểm tra và sửa chữa phải tính các hoạt động đang chờ xử lý này vào
   các đánh giá đang được thực hiện.
   Giải pháp này không thông minh vì nó xâm lấn vào phần chính của ZZ0000ZZ
   hệ thống tập tin.

.. _intent_drains:

Ý định thoát nước
`````````````

Fsck trực tuyến sử dụng bộ đếm mục đích nguyên tử và khóa chu trình để phối hợp
với chuỗi giao dịch.
Có hai thuộc tính chính của cơ chế thoát nước.
Đầu tiên, bộ đếm được tăng lên khi một mục công việc bị trì hoãn là ZZ0000ZZ thành một
giao dịch và nó sẽ giảm dần sau khi mục nhật ký thực hiện mục đích liên quan được thực hiện
ZZ0001ZZ sang giao dịch khác.
Thuộc tính thứ hai là công việc bị trì hoãn có thể được thêm vào giao dịch mà không cần
giữ khóa tiêu đề AG, nhưng không thể đánh dấu các mục công việc trên mỗi AG nếu không có
khóa bộ đệm tiêu đề AG đó để ghi lại các cập nhật vật lý và mục đích đã thực hiện
mục nhật ký.
Thuộc tính đầu tiên cho phép chà để tạo ra các chuỗi giao dịch đang chạy,
là sự loại bỏ ưu tiên rõ ràng của fsck trực tuyến để mang lại lợi ích cho các hoạt động của tệp.
Đặc tính thứ hai của cống là chìa khóa cho sự phối hợp chính xác của việc chà rửa,
vì chà sẽ luôn có thể quyết định xem có thể xảy ra xung đột hay không.

Đối với mã hệ thống tập tin thông thường, cống hoạt động như sau:

1. Gọi hàm hệ thống con thích hợp để thêm mục công việc bị trì hoãn vào
   giao dịch.

2. Hàm gọi ZZ0000ZZ để tăng bộ đếm.

3. Khi người quản lý hạng mục bị trì hoãn muốn hoàn thành hạng mục công việc bị trì hoãn, nó
   gọi ZZ0000ZZ để hoàn thành nó.

4. Việc triển khai ZZ0000ZZ ghi lại một số thay đổi và lệnh gọi
   ZZ0001ZZ để giảm bộ đếm cẩu thả và đánh thức mọi luồng
   đang chờ trên cống.

5. Giao dịch phụ cam kết, mở khóa tài nguyên được liên kết với
   mục ý định.

Đối với chà, cống hoạt động như sau:

1. Khóa (các) tài nguyên được liên kết với siêu dữ liệu đang được xóa.
   Ví dụ: quét btree đếm lại sẽ khóa tiêu đề AGI và AGF
   bộ đệm.

2. Nếu bộ đếm bằng 0 (ZZ0000ZZ trả về sai), không có
   chuỗi đang được tiến hành và hoạt động có thể tiếp tục.

3. Nếu không, hãy giải phóng các tài nguyên đã lấy ở bước 1.

4. Đợi bộ đếm ý định về 0 (ZZ0000ZZ), sau đó đi
   quay lại bước 1 trừ khi bắt được tín hiệu.

Để tránh bỏ phiếu ở bước 4, Drain cung cấp một hàng đợi cho các luồng chà để
được đánh thức bất cứ khi nào số lượng ý định giảm xuống 0.

.. _jump_labels:

Khóa tĩnh (còn gọi là Patch Nhãn nhảy)
`````````````````````````````````````

fsck trực tuyến cho XFS tách hệ thống tệp thông thường khỏi việc kiểm tra và
mã sửa chữa càng nhiều càng tốt.
Tuy nhiên, có một số phần của fsck trực tuyến (chẳng hạn như mục đích rút cạn và
sau đó, các hook cập nhật trực tiếp) nơi mã fsck trực tuyến cần biết
những gì đang xảy ra trong phần còn lại của hệ thống tập tin.
Vì người ta không mong đợi rằng fsck trực tuyến sẽ chạy liên tục trong
nền tảng, điều rất quan trọng là giảm thiểu chi phí thời gian chạy do
những hook này khi fsck trực tuyến được biên dịch vào kernel nhưng không hoạt động
chạy thay mặt cho không gian người dùng.
Lấy các khóa trong đường dẫn nóng của luồng trình ghi để chỉ truy cập cấu trúc dữ liệu
thấy rằng không cần thực hiện thêm hành động nào là tốn kém -- theo ý kiến của tác giả
máy tính, cái này có tổng chi phí là 40-50ns cho mỗi lần truy cập.
May mắn thay, kernel hỗ trợ vá mã động, cho phép XFS
thay thế một nhánh tĩnh để móc mã bằng xe trượt ZZ0000ZZ khi không có fsck trực tuyến
đang chạy.
Xe trượt này có tổng thời gian sử dụng bao lâu để bộ giải mã lệnh thực hiện
bỏ qua chiếc xe trượt tuyết, có vẻ như ở mức dưới 1ns và
không truy cập bộ nhớ ngoài việc tìm nạp lệnh.

Khi fsck trực tuyến kích hoạt khóa tĩnh, xe trượt sẽ được thay thế bằng một
nhánh vô điều kiện để gọi mã hook.
Việc chuyển đổi khá tốn kém (~22000ns) nhưng được thanh toán hoàn toàn bởi
chương trình gọi fsck trực tuyến và có thể được khấu hao nếu có nhiều luồng
nhập fsck trực tuyến cùng lúc hoặc nếu nhiều hệ thống tập tin đang được
được kiểm tra cùng một lúc.
Việc thay đổi hướng nhánh yêu cầu phải sử dụng khóa cắm nóng CPU và vì
Việc khởi tạo CPU yêu cầu cấp phát bộ nhớ, fsck trực tuyến phải cẩn thận để không
để thay đổi khóa tĩnh trong khi giữ bất kỳ khóa hoặc tài nguyên nào có thể
được truy cập trong các đường dẫn lấy lại bộ nhớ.
Để giảm thiểu sự tranh chấp trên khóa cắm nóng CPU, cần lưu ý không
bật hoặc tắt các phím tĩnh một cách không cần thiết.

Bởi vì các phím tĩnh nhằm mục đích giảm thiểu chi phí hook cho các thao tác thông thường.
hoạt động của hệ thống tập tin khi xfs_scrub không chạy, mục đích sử dụng
các mẫu như sau:

- Phần hook của XFS phải khai báo khóa tĩnh có phạm vi tĩnh
  mặc định là sai.
  Macro ZZ0000ZZ đảm nhiệm việc này.
  Bản thân khóa tĩnh phải được khai báo là biến ZZ0001ZZ.

- Khi quyết định gọi mã chỉ được sử dụng bởi chà, thông thường
  hệ thống tập tin nên gọi vị từ ZZ0000ZZ để tránh
  mã hook chỉ chà nếu khóa tĩnh không được bật.

- Hệ thống tập tin thông thường sẽ xuất các hàm trợ giúp gọi
  ZZ0000ZZ để bật và ZZ0001ZZ để tắt
  khóa tĩnh.
  Các hàm bao bọc giúp dễ dàng biên dịch mã liên quan nếu kernel
  nhà phân phối tắt fsck trực tuyến tại thời điểm xây dựng.

- Chức năng chà muốn bật chức năng XFS chỉ chà nên gọi
  ZZ0000ZZ từ chức năng thiết lập để kích hoạt một chức năng cụ thể
  cái móc.
  Việc này phải được thực hiện trước khi lấy bất kỳ tài nguyên nào được bộ nhớ sử dụng
  đòi lại.
  Người gọi tốt hơn nên chắc chắn rằng họ thực sự cần chức năng được kiểm soát bởi
  khóa tĩnh; cờ ZZ0001ZZ rất hữu ích ở đây.

Quét trực tuyến có các công cụ trợ giúp thu thập tài nguyên (ví dụ: ZZ0000ZZ) để
xử lý khóa bộ đệm AGI và AGF cho tất cả các chức năng chà sàn.
Nếu nó phát hiện xung đột giữa chà và các giao dịch đang chạy, nó sẽ
cố gắng chờ đợi ý định hoàn thành.
Nếu người gọi của trình trợ giúp chưa kích hoạt khóa tĩnh, trình trợ giúp sẽ
trả về -EDEADLOCK, điều này sẽ dẫn đến việc quá trình chà được khởi động lại bằng
Bộ cờ ZZ0001ZZ.
Chức năng thiết lập chà sẽ phát hiện cờ đó, bật khóa tĩnh và
thử chà lại lần nữa.
Việc gỡ bỏ chà sẽ vô hiệu hóa tất cả các khóa tĩnh mà ZZ0002ZZ thu được.

Để biết thêm thông tin, vui lòng xem tài liệu kernel của
Tài liệu/dàn dựng/static-keys.rst.

.. _xfile:

Bộ nhớ hạt nhân có thể phân trang
----------------------

Một số chức năng kiểm tra trực tuyến hoạt động bằng cách quét hệ thống tập tin để xây dựng một
bản sao ẩn của cấu trúc siêu dữ liệu ondisk trong bộ nhớ và so sánh hai cấu trúc đó
bản sao.
Để sửa chữa trực tuyến xây dựng lại cấu trúc siêu dữ liệu, nó phải tính toán bản ghi
tập hợp sẽ được lưu trữ trong cấu trúc mới trước khi nó có thể tồn tại lâu dài trong cấu trúc mới đó
cấu trúc vào đĩa.
Lý tưởng nhất là việc sửa chữa hoàn tất bằng một cam kết nguyên tử duy nhất giới thiệu
một cấu trúc dữ liệu mới.
Để đáp ứng những mục tiêu này, kernel cần thu thập một lượng lớn thông tin
ở một nơi không yêu cầu hoạt động chính xác của hệ thống tập tin.

Bộ nhớ hạt nhân không phù hợp vì:

* Việc cấp phát một vùng bộ nhớ liền kề để tạo mảng C là rất khó khăn.
  khó khăn, đặc biệt là trên hệ thống 32-bit.

* Danh sách các bản ghi được liên kết giới thiệu chi phí con trỏ kép rất cao
  và loại bỏ khả năng tra cứu được lập chỉ mục.

* Bộ nhớ hạt nhân được ghim, có thể đưa hệ thống vào tình trạng OOM.

* Hệ thống có thể không có đủ bộ nhớ để sắp xếp tất cả thông tin.

Tại bất kỳ thời điểm nào, fsck trực tuyến không cần lưu giữ toàn bộ bản ghi trong
bộ nhớ, có nghĩa là các bản ghi riêng lẻ có thể được phân trang nếu cần thiết.
Sự phát triển liên tục của fsck trực tuyến đã chứng minh rằng khả năng thực hiện
lưu trữ dữ liệu được lập chỉ mục cũng sẽ rất hữu ích.
May mắn thay, nhân Linux đã có sẵn phương tiện để định địa chỉ byte và
lưu trữ có thể phân trang: tmpfs.
Trình điều khiển đồ họa trong kernel (đáng chú ý nhất là i915) tận dụng các tệp tmpfs
để lưu trữ dữ liệu trung gian không cần phải có trong bộ nhớ mọi lúc, vì vậy
tiền lệ sử dụng đó đã được thiết lập.
Do đó, ZZ0000ZZ đã ra đời!

+-----------------------------------------------------------------------------------+
ZZ0001ZZ
+-----------------------------------------------------------------------------------+
ZZ0002ZZ
ZZ0003ZZ
ZZ0004ZZ
ZZ0005ZZ
ZZ0006ZZ
ZZ0007ZZ
ZZ0008ZZ
ZZ0009ZZ
ZZ0010ZZ
+-----------------------------------------------------------------------------------+

Mô hình truy cập xfile
```````````````````

Một cuộc khảo sát về mục đích sử dụng xfiles đã đề xuất các trường hợp sử dụng sau:

1. Mảng các bản ghi có kích thước cố định (cây quản lý không gian, thư mục và
   mục thuộc tính mở rộng)

2. Mảng thưa thớt của các bản ghi có kích thước cố định (hạn ngạch và số lượng liên kết)

3. Các đối tượng nhị phân lớn (BLOB) có kích thước thay đổi (thư mục và phần mở rộng)
   tên thuộc tính và giá trị)

4. Sắp xếp các cây trong bộ nhớ (btree ánh xạ ngược)

5. Nội dung tùy ý (quản lý không gian thời gian thực)

Để hỗ trợ bốn trường hợp sử dụng đầu tiên, cấu trúc dữ liệu cấp cao bao bọc xfile
để chia sẻ chức năng giữa các chức năng fsck trực tuyến.
Phần còn lại của phần này thảo luận về các giao diện mà xfile trình bày
bốn trong số năm cấu trúc dữ liệu cấp cao hơn.
Trường hợp sử dụng thứ năm được thảo luận trong trường hợp ZZ0000ZZ
học tập.

XFS dựa trên bản ghi rất nhiều, điều này cho thấy khả năng tải và lưu trữ
hồ sơ đầy đủ là quan trọng.
Để hỗ trợ những trường hợp này, một cặp ZZ0000ZZ và ZZ0001ZZ
các hàm được cung cấp để đọc và lưu giữ các đối tượng vào một tệp xfile xử lý bất kỳ
lỗi như lỗi hết bộ nhớ.  Để sửa chữa trực tuyến, đè bẹp các điều kiện lỗi
theo cách này là một hành vi có thể chấp nhận được vì phản ứng duy nhất là hủy bỏ
hoạt động trở lại không gian người dùng.

Tuy nhiên, không có cuộc thảo luận nào về các thuật ngữ truy cập tệp được hoàn tất nếu không trả lời
câu hỏi, "Nhưng còn mmap thì sao?"
Thật thuận tiện khi truy cập bộ nhớ trực tiếp bằng con trỏ, giống như không gian người dùng
mã thực hiện với bộ nhớ thông thường.
fsck trực tuyến không được đưa hệ thống vào điều kiện OOM, điều đó có nghĩa là
xfiles phải đáp ứng được việc thu hồi bộ nhớ.
tmpfs chỉ có thể đẩy một folio pagecache vào bộ đệm trao đổi nếu folio đó không
được ghim hay khóa, nghĩa là xfile không được ghim quá nhiều folio.

Truy cập trực tiếp ngắn hạn vào nội dung xfile được thực hiện bằng cách khóa pagecache
folio và ánh xạ nó vào không gian địa chỉ kernel.  Tải đối tượng và lưu trữ sử dụng điều này
cơ chế.  Khóa Folio không được phép giữ trong thời gian dài, vì vậy
quyền truy cập trực tiếp lâu dài vào nội dung xfile được thực hiện bằng cách tăng số lượt truy cập folio,
ánh xạ nó vào không gian địa chỉ kernel và bỏ khóa folio.
Những người dùng lâu dài ZZ0000ZZ này phản ứng nhanh với việc lấy lại bộ nhớ bằng cách nối vào
cơ sở hạ tầng thu gọn để biết khi nào nên phát hành folio.

Các chức năng ZZ0002ZZ và ZZ0003ZZ được cung cấp cho
truy xuất folio (đã khóa) hỗ trợ một phần của xfile và phát hành nó.
Mã duy nhất để sử dụng các hàm cho thuê folio này là xfarray
Thuật toán ZZ0000ZZ và ZZ0001ZZ.

Điều phối truy cập xfile
`````````````````````````

Vì lý do bảo mật, xfiles phải được hạt nhân sở hữu riêng.
Chúng được đánh dấu ZZ0000ZZ để ngăn chặn sự can thiệp từ hệ thống an ninh,
không bao giờ được ánh xạ vào các bảng mô tả tệp quy trình và các trang của chúng phải
không bao giờ được ánh xạ vào các quy trình không gian người dùng.

Để tránh khóa các sự cố đệ quy với VFS, tất cả quyền truy cập vào tệp shmfs
được thực hiện bằng cách thao tác trực tiếp vào bộ đệm trang.
người viết xfile gọi các hàm ZZ0000ZZ và ZZ0001ZZ của
không gian địa chỉ của xfile để lấy các trang có thể ghi, sao chép bộ đệm của người gọi vào
trang và phát hành các trang.
Trình đọc xfile gọi ZZ0002ZZ để lấy trang trực tiếp
trước khi sao chép nội dung vào bộ đệm của người gọi.
Nói cách khác, xfiles bỏ qua đường dẫn mã đọc và ghi VFS để tránh
phải tạo một ZZ0003ZZ giả và tránh lấy inode và
khóa đóng băng.
tmpfs không thể bị đóng băng và xfiles không được hiển thị trong không gian người dùng.

Nếu một xfile được chia sẻ giữa các luồng để sửa chữa giai đoạn, người gọi phải cung cấp
ổ khóa riêng của mình để phối hợp truy cập.
Ví dụ: nếu chức năng chà lưu trữ kết quả quét trong một tệp xfile và cần
các luồng khác để cung cấp thông tin cập nhật cho dữ liệu được quét, chức năng chà phải
cung cấp một khóa cho tất cả các chủ đề để chia sẻ.

.. _xfarray:

Mảng bản ghi có kích thước cố định
`````````````````````````````

Trong XFS, mỗi loại siêu dữ liệu không gian được lập chỉ mục (không gian trống, nút, tham chiếu
số lượng, không gian nhánh tệp và ánh xạ ngược) bao gồm một tập hợp các kích thước cố định
các bản ghi được lập chỉ mục bằng cây B+ cổ điển.
Các thư mục có một tập hợp các bản ghi trực tiếp có kích thước cố định trỏ đến tên,
và các thuộc tính mở rộng có một tập hợp các khóa thuộc tính có kích thước cố định trỏ tới
tên và giá trị.
Bộ đếm hạn ngạch và bộ đếm liên kết tệp chỉ mục các bản ghi bằng số.
Trong quá trình sửa chữa, chà cần tạo các bản ghi mới trong bước thu thập và
lấy chúng trong bước xây dựng btree.

Mặc dù yêu cầu này có thể được thỏa mãn bằng cách gọi đọc và ghi
các phương thức của xfile một cách trực tiếp, sẽ đơn giản hơn cho người gọi khi có một
mức độ trừu tượng cao hơn để đảm nhiệm việc tính toán độ lệch mảng, để cung cấp
các hàm lặp và để xử lý các bản ghi và sắp xếp thưa thớt.
Bản tóm tắt ZZ0000ZZ trình bày một mảng tuyến tính cho các bản ghi có kích thước cố định ở trên cùng
xfile có thể truy cập byte.

.. _xfarray_access_patterns:

Các mẫu truy cập mảng
^^^^^^^^^^^^^^^^^^^^^

Các mẫu truy cập mảng trong fsck trực tuyến có xu hướng rơi vào ba loại.
Việc lặp lại các hồ sơ được coi là cần thiết cho mọi trường hợp và sẽ
được đề cập trong phần tiếp theo.

Loại người gọi đầu tiên xử lý các bản ghi được lập chỉ mục theo vị trí.
Khoảng trống có thể tồn tại giữa các bản ghi và một bản ghi có thể được cập nhật nhiều lần
trong bước thu thập.
Nói cách khác, những người gọi này muốn có một tệp bảng có địa chỉ tuyến tính thưa thớt.
Trường hợp sử dụng điển hình là bản ghi hạn ngạch hoặc bản ghi số lượng liên kết tệp.
Việc truy cập vào các phần tử mảng được thực hiện theo chương trình thông qua ZZ0000ZZ và
Các hàm ZZ0001ZZ, bao bọc các hàm xfile có tên tương tự thành
cung cấp khả năng tải và lưu trữ các phần tử mảng tại các chỉ số mảng tùy ý.
Khoảng trống được xác định là bản ghi null và bản ghi null được xác định là bản ghi rỗng
chuỗi của tất cả các byte bằng 0.
Bản ghi null được phát hiện bằng cách gọi ZZ0002ZZ.
Chúng được tạo bằng cách gọi ZZ0003ZZ để loại bỏ một hiện có
record hoặc bằng cách không bao giờ lưu trữ bất cứ thứ gì vào một chỉ mục mảng.

Loại người gọi thứ hai xử lý các bản ghi không được lập chỉ mục theo vị trí
và không yêu cầu cập nhật nhiều bản ghi.
Trường hợp sử dụng điển hình ở đây là xây dựng lại cây không gian và cây khóa/giá trị.
Những người gọi này có thể thêm bản ghi vào mảng mà không cần quan tâm đến chỉ số mảng
thông qua chức năng ZZ0000ZZ, lưu trữ một bản ghi ở cuối
mảng.
Đối với người gọi yêu cầu hồ sơ phải được trình bày theo một thứ tự cụ thể (ví dụ:
xây dựng lại dữ liệu btree), hàm ZZ0001ZZ có thể sắp xếp sắp xếp
hồ sơ; chức năng này sẽ được đề cập sau.

Loại người gọi thứ ba là một cái túi, rất hữu ích cho việc đếm các bản ghi.
Trường hợp sử dụng điển hình ở đây là xây dựng số lượng tham chiếu phạm vi không gian từ
thông tin ánh xạ ngược.
Hồ sơ có thể cho vào túi theo thứ tự tùy ý, có thể lấy ra khỏi túi
bất cứ lúc nào và tính duy nhất của hồ sơ được để lại cho người gọi.
Hàm ZZ0000ZZ được sử dụng để chèn một bản ghi vào bất kỳ
khe ghi trống trong túi; và chức năng ZZ0001ZZ sẽ loại bỏ một
ghi lại từ túi.

Lặp lại các phần tử mảng
^^^^^^^^^^^^^^^^^^^^^^^^

Hầu hết người dùng xfarray đều yêu cầu khả năng lặp lại các bản ghi được lưu trữ trong
mảng.
Người gọi có thể thăm dò mọi chỉ mục mảng có thể có bằng cách sau:

.. code-block:: c

	xfarray_idx_t i;
	foreach_xfarray_idx(array, i) {
	    xfarray_load(array, i, &rec);

	    /* do something with rec */
	}

Tất cả người dùng thành ngữ này phải được chuẩn bị để xử lý các bản ghi rỗng hoặc phải
biết rằng không có cái nào cả.

Đối với người dùng xfarray muốn lặp lại một mảng thưa thớt, ZZ0000ZZ
hàm bỏ qua các chỉ mục trong xfarray chưa bao giờ được ghi vào
gọi ZZ0001ZZ (sử dụng nội bộ ZZ0002ZZ) để bỏ qua các khu vực
của mảng không được điền các trang bộ nhớ.
Khi nó tìm thấy một trang, nó sẽ bỏ qua các vùng được đánh số 0 của trang.

.. code-block:: c

	xfarray_idx_t i = XFARRAY_CURSOR_INIT;
	while ((ret = xfarray_iter(array, &i, &rec)) == 1) {
	    /* do something with rec */
	}

.. _xfarray_sort:

Sắp xếp các phần tử mảng
^^^^^^^^^^^^^^^^^^^^^^

Trong buổi trình diễn sửa chữa trực tuyến lần thứ tư, một nhà đánh giá cộng đồng đã nhận xét
rằng vì lý do hiệu suất, sửa chữa trực tuyến phải tải hàng loạt hồ sơ
vào các khối bản ghi btree thay vì chèn các bản ghi vào khối btree mới tại một thời điểm
thời gian.
Mã chèn btree trong XFS chịu trách nhiệm duy trì thứ tự chính xác
của các bản ghi, do đó, xfarray đương nhiên cũng phải hỗ trợ sắp xếp bản ghi
thiết lập trước khi tải số lượng lớn.

Nghiên cứu điển hình: Sắp xếp xfarray
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Thuật toán sắp xếp được sử dụng trong xfarray thực sự là sự kết hợp của thuật toán thích ứng
thuật toán con quicksort và heapsort theo tinh thần
ZZ0001ZZ và
ZZ0002ZZ, với các tùy chỉnh cho Linux
hạt nhân.
Để sắp xếp các bản ghi trong một khoảng thời gian ngắn hợp lý, ZZ0000ZZ cần
lợi thế của việc phân vùng nhị phân được cung cấp bởi quicksort, nhưng nó cũng sử dụng
heapsort để phòng ngừa sự sụp đổ hiệu suất nếu trục xoay quicksort được chọn
đang nghèo.
Cả hai thuật toán (nói chung) đều là O(n * lg(n)), nhưng có hiệu suất rộng
khoảng cách giữa hai lần thực hiện.

Nhân Linux đã có sẵn một triển khai heapsort khá nhanh.
Nó chỉ hoạt động trên mảng C thông thường, điều này giới hạn phạm vi hữu dụng của nó.
Có hai vị trí chính mà xfarray sử dụng nó:

* Sắp xếp bất kỳ tập hợp con bản ghi nào được hỗ trợ bởi một trang xfile.

* Đang tải một số lượng nhỏ bản ghi xfarray từ các phần có khả năng khác nhau
  của xfarray vào bộ nhớ đệm và sắp xếp bộ đệm.

Nói cách khác, ZZ0000ZZ sử dụng heapsort để hạn chế đệ quy lồng nhau của
quicksort, từ đó giảm thiểu hành vi tồi tệ nhất trong thời gian chạy của quicksort.

Chọn một trục xoay sắp xếp nhanh là một công việc khó khăn.
Một trục xoay tốt sẽ chia tập hợp thành một nửa, dẫn đến sự chia để trị
hành vi quan trọng đối với hiệu suất O(n * lg(n)).
Một trục xoay kém hầu như không chia tách được tập hợp con, dẫn đến O(n\ ZZ0000ZZ)
thời gian chạy.
Quy trình sắp xếp xfarray cố gắng tránh chọn một trục xoay xấu bằng cách lấy mẫu chín
ghi vào bộ nhớ đệm và sử dụng kernel heapsort để xác định
trung vị của chín.

Hầu hết các triển khai sắp xếp nhanh hiện đại đều sử dụng "thứ chín" của Tukey để chọn một
xoay vòng từ một mảng C cổ điển.
Việc triển khai thứ chín điển hình chọn ba bộ ba bản ghi duy nhất, sắp xếp từng bộ
của các bộ ba, sau đó sắp xếp giá trị ở giữa của mỗi bộ ba để xác định
giá trị thứ chín.
Tuy nhiên, như đã nêu trước đây, việc truy cập xfile không hoàn toàn rẻ.
Hóa ra việc đọc chín phần tử thành một bảng sẽ hiệu quả hơn nhiều.
bộ nhớ đệm, chạy heapsort trong bộ nhớ của kernel trên bộ đệm và chọn
phần tử thứ 4 của bộ đệm đó làm trục xoay.
Những cấp độ thứ chín của Tukey được mô tả trong J. W. Tukey, ZZ0000ZZ, trong *Contributions to
Lấy mẫu khảo sát và thống kê ứng dụng*, do H. David biên tập, (Nhà xuất bản học thuật,
1978), trang 251–257.

Việc phân vùng sắp xếp nhanh khá dễ hiểu - sắp xếp lại bản ghi
tập hợp con xung quanh trục xoay, sau đó thiết lập các khung ngăn xếp hiện tại và tiếp theo để
sắp xếp tương ứng với nửa lớn hơn và nhỏ hơn của trục xoay.
Điều này giữ cho các yêu cầu về không gian ngăn xếp ở mức log2 (số lượng bản ghi).

Là bước tối ưu hóa hiệu suất cuối cùng, giai đoạn quét hi và lo của quicksort
giữ các trang xfile đã kiểm tra được ánh xạ trong kernel càng lâu càng tốt để
giảm chu kỳ bản đồ/hủy bản đồ.
Đáng ngạc nhiên là điều này làm giảm thời gian chạy sắp xếp tổng thể gần một nửa sau
tính đến việc áp dụng heapsort trực tiếp lên các trang xfile.

.. _xfblob:

Bộ nhớ blob
````````````

Các thuộc tính và thư mục mở rộng bổ sung thêm yêu cầu cho việc dàn dựng
bản ghi: chuỗi byte tùy ý có độ dài hữu hạn.
Mỗi bản ghi mục nhập thư mục cần lưu trữ tên mục nhập,
và mỗi thuộc tính mở rộng cần lưu trữ cả tên và giá trị thuộc tính.
Tên, khóa và giá trị có thể tiêu tốn một lượng lớn bộ nhớ, do đó
Sự trừu tượng hóa ZZ0000ZZ được tạo ra để đơn giản hóa việc quản lý các đốm màu này
trên một xfile.

Mảng Blob cung cấp các hàm ZZ0000ZZ và ZZ0001ZZ để truy xuất
và các đối tượng kiên trì.
Hàm lưu trữ trả về một cookie ma thuật cho mọi đối tượng mà nó tồn tại.
Sau đó, người gọi cung cấp cookie này cho ZZ0002ZZ để gọi lại đối tượng.
Hàm ZZ0003ZZ giải phóng một blob cụ thể và ZZ0004ZZ
chức năng giải phóng tất cả vì không cần nén.

Chi tiết về sửa chữa thư mục và thuộc tính mở rộng sẽ được thảo luận
trong phần tiếp theo về trao đổi nội dung tệp nguyên tử.
Tuy nhiên cần lưu ý rằng các chức năng sửa chữa này chỉ sử dụng blob storage
để lưu trữ một số lượng nhỏ các mục trước khi thêm chúng vào đĩa tạm thời
tập tin, đó là lý do tại sao việc nén là không cần thiết.

.. _xfbtree:

Cây B+trong bộ nhớ
`````````````````

Chương về ZZ0000ZZ đã đề cập rằng
kiểm tra và sửa chữa siêu dữ liệu thứ cấp thường yêu cầu sự phối hợp
giữa việc quét siêu dữ liệu trực tiếp của hệ thống tập tin và các luồng ghi
cập nhật siêu dữ liệu đó.
Việc giữ cho dữ liệu quét được cập nhật đòi hỏi khả năng truyền bá
cập nhật siêu dữ liệu từ hệ thống tệp vào dữ liệu đang được thu thập trong quá trình quét.
ZZ0001ZZ này được thực hiện bằng cách thêm các bản cập nhật đồng thời vào một tệp nhật ký riêng và
áp dụng chúng trước khi ghi siêu dữ liệu mới vào đĩa, nhưng điều này dẫn đến
tiêu thụ bộ nhớ không giới hạn nếu phần còn lại của hệ thống rất bận.
Một tùy chọn khác là bỏ qua nhật ký phụ và cam kết cập nhật trực tiếp từ
hệ thống tập tin trực tiếp vào dữ liệu quét, điều này sẽ đánh đổi nhiều chi phí hơn để có chi phí thấp hơn
yêu cầu bộ nhớ tối đa.
Trong cả hai trường hợp, cấu trúc dữ liệu chứa kết quả quét phải hỗ trợ lập chỉ mục
truy cập để thực hiện tốt.

Vì việc tra cứu dữ liệu quét được lập chỉ mục là cần thiết cho cả hai chiến lược, trực tuyến
fsck sử dụng chiến lược thứ hai là đưa các cập nhật trực tiếp trực tiếp vào
quét dữ liệu.
Vì xfararray không được lập chỉ mục và không thực thi thứ tự bản ghi nên chúng
không phù hợp với nhiệm vụ này.
Tuy nhiên, thuận tiện hơn, XFS có một thư viện để tạo và duy trì lệnh đảo ngược
bản ghi ánh xạ: mã btree rmap hiện có!
Giá như có một phương tiện để tạo ra một cái trong trí nhớ.

Hãy nhớ lại rằng sự trừu tượng hóa ZZ0000ZZ biểu diễn các trang bộ nhớ như một
tập tin thông thường, có nghĩa là kernel có thể tạo byte hoặc khối có thể định địa chỉ
không gian địa chỉ ảo theo ý muốn.
Bộ đệm đệm XFS chuyên trừu tượng hóa IO thành địa chỉ hướng khối
khoảng trắng, có nghĩa là việc điều chỉnh bộ đệm đệm để giao tiếp với
xfiles cho phép sử dụng lại toàn bộ thư viện btree.
Btrees được xây dựng trên xfile được gọi chung là ZZ0001ZZ.
Một số phần tiếp theo mô tả cách chúng thực sự hoạt động.

Sử dụng xfiles làm mục tiêu bộ đệm đệm
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Cần có hai sửa đổi để hỗ trợ xfile làm mục tiêu bộ đệm đệm.
Đầu tiên là làm cho cấu trúc ZZ0000ZZ có thể
lưu trữ ZZ0001ZZ rhashtable, bởi vì thông thường chúng được giữ bởi một
cấu trúc mỗi AG.
Thay đổi thứ hai là sửa đổi chức năng bộ đệm ZZ0002ZZ để "đọc" bộ đệm
các trang từ xfile và "ghi" các trang được lưu trong bộ nhớ đệm trở lại xfile.
Nhiều quyền truy cập vào các bộ đệm riêng lẻ được điều khiển bằng khóa ZZ0003ZZ,
vì xfile không tự cung cấp bất kỳ khóa nào.
Với sự thích ứng này, người dùng bộ đệm đệm được hỗ trợ bởi xfile sẽ sử dụng
chính xác các API giống như người dùng bộ đệm đệm được hỗ trợ bằng đĩa.
Sự tách biệt giữa xfile và bộ đệm đệm ngụ ý mức sử dụng bộ nhớ cao hơn vì
họ không chia sẻ trang, nhưng thuộc tính này một ngày nào đó có thể cho phép giao dịch
cập nhật lên btree trong bộ nhớ.
Tuy nhiên, ngày nay nó chỉ đơn giản là loại bỏ nhu cầu về mã mới.

Quản lý không gian với xfbtree
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Quản lý không gian cho một xfile rất đơn giản -- mỗi khối btree là một bộ nhớ
trang về kích thước.
Các khối này sử dụng cùng định dạng tiêu đề như btree trên đĩa, nhưng phần trong bộ nhớ
trình xác minh khối bỏ qua tổng kiểm tra, giả sử rằng bộ nhớ xfile không còn nữa
dễ bị tham nhũng hơn DRAM thông thường.
Việc sử dụng lại mã hiện có ở đây quan trọng hơn hiệu quả bộ nhớ tuyệt đối.

Khối đầu tiên của xfile sao lưu xfbtree chứa khối tiêu đề.
Tiêu đề mô tả chủ sở hữu, chiều cao và số khối của thư mục gốc
khối xfbtree.

Để phân bổ khối btree, hãy sử dụng ZZ0000ZZ để tìm khoảng trống trong tệp.
Nếu không có khoảng trống, hãy tạo một khoảng trống bằng cách kéo dài độ dài của xfile.
Phân bổ trước không gian cho khối bằng ZZ0001ZZ và trao lại
vị trí.
Để giải phóng khối xfbtree, hãy sử dụng ZZ0002ZZ (sử dụng nội bộ
ZZ0003ZZ) để xóa trang bộ nhớ khỏi xfile.

Điền một xfbtree
^^^^^^^^^^^^^^^^^^^^^

Hàm fsck trực tuyến muốn tạo xfbtree phải tiến hành như
sau:

1. Gọi ZZ0000ZZ để tạo xfile.

2. Gọi ZZ0000ZZ để tạo cấu trúc đích của bộ đệm đệm
   trỏ đến xfile.

3. Chuyển mục tiêu bộ đệm bộ đệm, hoạt động bộ đệm và thông tin khác tới
   ZZ0000ZZ để khởi tạo thông tin đã truyền trong ZZ0001ZZ và viết một
   khối gốc ban đầu vào xfile.
   Mỗi loại btree sẽ xác định một trình bao bọc chuyển các đối số cần thiết tới
   chức năng tạo.
   Ví dụ: rmap btrees xác định ZZ0002ZZ để xử lý
   tất cả các chi tiết cần thiết cho người gọi.

4. Truyền đối tượng xfbtree tới hàm tạo con trỏ btree cho
   loại btree.
   Theo ví dụ trên, ZZ0000ZZ sẽ xử lý việc này
   cho người gọi.

5. Chuyển con trỏ btree tới các hàm btree thông thường để thực hiện truy vấn
   và cập nhật btree trong bộ nhớ.
   Ví dụ: một con trỏ btree cho rmap xfbtree có thể được truyền tới
   ZZ0001ZZ hoạt động giống như bất kỳ con trỏ btree nào khác.
   Xem ZZ0000ZZ để biết thông tin về cách xử lý
   các bản cập nhật xfbtree được ghi vào một giao dịch.

6. Khi hoàn tất, xóa con trỏ btree, hủy đối tượng xfbtree, giải phóng
   mục tiêu đệm và hủy xfile để giải phóng tất cả tài nguyên.

.. _xfbtree_commit:

Cam kết bộ đệm xfbtree đã ghi
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Mặc dù việc sử dụng lại mã btree rmap để xử lý việc dàn dựng là một cách hack thông minh
cấu trúc, bản chất phù du của việc lưu trữ khối btree trong bộ nhớ thể hiện
một số thách thức của riêng mình.
Trình quản lý giao dịch XFS không được cam kết các mục nhật ký bộ đệm cho bộ đệm được hỗ trợ
bởi xfile vì định dạng nhật ký không hiểu các bản cập nhật cho thiết bị
ngoài thiết bị dữ liệu.
Một xfbtree phù du có thể sẽ không tồn tại vào thời điểm điểm kiểm tra AIL
ghi lại các giao dịch vào hệ thống tập tin và chắc chắn sẽ không tồn tại trong quá trình
phục hồi nhật ký.
Vì những lý do này, bất kỳ mã nào cập nhật xfbtree trong ngữ cảnh giao dịch đều phải
xóa các mục nhật ký bộ đệm khỏi giao dịch và ghi các cập nhật vào
sao lưu xfile trước khi thực hiện hoặc hủy giao dịch.

Các hàm ZZ0000ZZ và ZZ0001ZZ triển khai
chức năng này như sau:

1. Tìm từng mục nhật ký bộ đệm có bộ đệm nhắm mục tiêu xfile.

2. Ghi lại trạng thái bẩn/đặt hàng của mục nhật ký.

3. Tách mục nhật ký khỏi bộ đệm.

4. Xếp hàng bộ đệm vào danh sách delwri đặc biệt.

5. Xóa cờ bẩn giao dịch nếu các mục nhật ký bẩn duy nhất là những mục đó
   đã được tách ra ở bước 3.

6. Gửi danh sách delwri để cam kết các thay đổi đối với xfile, nếu các bản cập nhật
   đang được cam kết.

Sau khi loại bỏ bộ đệm đã ghi xfile khỏi giao dịch theo cách này,
giao dịch có thể được cam kết hoặc hủy bỏ.

Tải hàng loạt cây Ondisk B+
------------------------------

Như đã đề cập trước đó, những lần sửa chữa trực tuyến đầu tiên đã xây dựng btree mới
cấu trúc bằng cách tạo một cây btree mới và thêm các quan sát riêng lẻ.
Tải một bản ghi btree tại một thời điểm có một lợi thế nhỏ là không yêu cầu
các bản ghi incore được sắp xếp trước khi cam kết, nhưng rất chậm và bị rò rỉ
chặn nếu hệ thống gặp sự cố trong quá trình sửa chữa.
Việc tải từng bản ghi một cũng có nghĩa là việc sửa chữa không thể kiểm soát được
hệ số tải của các khối trong btree mới.

May mắn thay, công cụ ZZ0000ZZ đáng kính đã có một phương tiện hiệu quả hơn để
xây dựng lại chỉ mục btree từ bộ sưu tập các bản ghi -- tải btree số lượng lớn.
Điều này được triển khai theo mã khá kém hiệu quả, vì ZZ0001ZZ
có các triển khai sao chép và dán riêng biệt cho từng loại btree.

Để chuẩn bị cho fsck trực tuyến, mỗi trong số bốn bộ tải số lượng lớn đã được nghiên cứu, ghi chú
đã được lấy và bốn cái đã được tái cấu trúc thành một khối btree chung duy nhất
cơ chế tải.
Những ghi chú đó lần lượt đã được làm mới và được trình bày dưới đây.

Tính toán hình học
````````````````````

Bước thứ 0 của việc tải số lượng lớn là tập hợp toàn bộ bộ bản ghi sẽ
được lưu trữ trong btree mới và sắp xếp các bản ghi.
Tiếp theo, gọi ZZ0000ZZ để tính toán hình dạng của
btree từ tập bản ghi, loại btree và bất kỳ tùy chọn hệ số tải nào.
Thông tin này là cần thiết để dự trữ tài nguyên.

Đầu tiên, tính toán hình học sẽ tính toán các bản ghi tối thiểu và tối đa
sẽ phù hợp với một khối lá có kích thước bằng khối btree và kích thước của
tiêu đề khối.
Nói một cách đại khái, số lượng hồ sơ tối đa là::

maxrecs = (block_size - header_size) / record_size

Thiết kế XFS chỉ định rằng các khối btree phải được hợp nhất khi có thể,
có nghĩa là số lượng bản ghi tối thiểu là một nửa maxrecs::

minrecs = maxrecs / 2

Biến tiếp theo cần xác định là hệ số tải mong muốn.
Giá trị này ít nhất phải là minrecs và không nhiều hơn maxrecs.
Việc chọn minrecs là điều không mong muốn vì nó lãng phí một nửa khối.
Việc chọn maxrecs cũng là điều không mong muốn vì việc thêm một bản ghi vào mỗi
khối lá mới được xây dựng lại sẽ gây ra hiện tượng tách cây, gây ra hiện tượng rõ rệt
giảm hiệu suất ngay sau đó.
Hệ số tải mặc định được chọn là 75% maxrecs, cung cấp
cấu trúc nhỏ gọn hợp lý mà không có bất kỳ hình phạt phân chia ngay lập tức nào::

default_load_factor = (maxrecs + minrecs) / 2

Nếu không gian chật hẹp, hệ số tải sẽ được đặt thành maxrecs để tránh
hết dung lượng::

leaf_load_factor = đủ dung lượng? default_load_factor : maxrecs

Hệ số tải được tính cho các khối nút btree bằng cách sử dụng kích thước kết hợp của
khóa btree và con trỏ làm kích thước bản ghi::

maxrecs = (block_size - header_size) / (key_size + ptr_size)
        minrecs = maxrecs / 2
        node_load_factor = đủ dung lượng? default_load_factor : maxrecs

Khi đã xong, số khối lá cần thiết để lưu trữ tập bản ghi
có thể được tính như sau::

leaf_blocks = ceil(record_count / leaf_load_factor)

Số lượng khối nút cần thiết để trỏ tới cấp độ tiếp theo trong cây
được tính như sau::

n_blocks = (n == 0 ? leaf_blocks : node_blocks[n])
        node_blocks[n + 1] = ceil(n_blocks / node_load_factor)

Toàn bộ tính toán được thực hiện đệ quy cho đến mức hiện tại
cần một khối.
Hình học kết quả là như sau:

- Đối với cây btree có gốc AG thì cấp này là cấp gốc nên chiều cao của cây mới
  cây là ZZ0000ZZ và không gian cần thiết là tổng số lượng
  khối ở mỗi cấp độ.

- Đối với các cây có gốc bằng inode mà các bản ghi ở cấp cao nhất không phù hợp với
  khu vực ngã ba inode, chiều cao là ZZ0000ZZ, không gian cần thiết là
  tổng số khối ở mỗi cấp độ và ngã ba inode trỏ đến
  khối gốc.

- Đối với các cây btree có gốc bằng inode nơi các bản ghi ở mức cao nhất có thể được lưu trữ trong
  khu vực ngã ba inode, sau đó khối gốc có thể được lưu trữ trong inode,
  chiều cao là ZZ0000ZZ và khoảng trống cần thiết nhỏ hơn tổng một đơn vị
  số khối ở mỗi cấp độ.
  Điều này chỉ có ý nghĩa khi các cây không phải bmap có khả năng root trong
  một inode, là một bản vá trong tương lai và chỉ được đưa vào đây để hoàn thiện.

.. _newbt:

Đặt trước các khối cây B+Mới
```````````````````````````

Sau khi sửa chữa biết số khối cần thiết cho btree mới, nó sẽ phân bổ
những khối đó bằng cách sử dụng thông tin không gian trống.
Mỗi phạm vi dành riêng được theo dõi riêng biệt bởi dữ liệu trạng thái của trình tạo btree.
Để cải thiện khả năng phục hồi sau sự cố, mã đặt trước cũng ghi lại Mức độ giải phóng
Mục ý định (EFI) trong cùng một giao dịch với mỗi lần phân bổ không gian và đính kèm
đối tượng ZZ0000ZZ trong bộ nhớ của nó để dành chỗ trống.
Nếu hệ thống gặp sự cố, việc khôi phục nhật ký sẽ sử dụng các EFI chưa hoàn thành để giải phóng
không gian chưa sử dụng, không gian trống, giữ nguyên hệ thống tập tin.

Mỗi lần người xây dựng btree yêu cầu một khối cho btree từ một tài khoản dành riêng
ở mức độ nào đó, nó cập nhật phần đặt trước trong bộ nhớ để phản ánh không gian được yêu cầu.
Đặt trước khối cố gắng phân bổ càng nhiều không gian liền kề càng tốt để
giảm số lượng EFI đang hoạt động.

Trong khi sửa chữa đang viết các khối btree mới này, các EFI được tạo cho không gian
đặt chỗ ghim đuôi của nhật ký ondisk.
Có thể các bộ phận khác của hệ thống sẽ vẫn bận rộn và khiến đầu óc phải bận rộn.
của khúc gỗ hướng về phía cái đuôi bị ghim.
Để tránh khóa hệ thống tập tin, EFI không được ghim phần đuôi của nhật ký
quá lâu.
Để giảm bớt vấn đề này, khả năng đăng nhập lại động của các hoạt động bị trì hoãn
cơ chế được sử dụng lại ở đây để thực hiện một giao dịch ở phần đầu nhật ký có chứa
EFD cho EFI cũ và EFI mới ở đầu.
Điều này cho phép nhật ký giải phóng EFI cũ để giữ cho nhật ký tiếp tục tiến về phía trước.

EFI có vai trò trong giai đoạn cam kết và thu hoạch; xin vui lòng xem
phần tiếp theo và phần về ZZ0000ZZ để biết thêm chi tiết.

Viết cây mới
````````````````````

Phần này khá đơn giản - người xây dựng btree (ZZ0000ZZ) tuyên bố
một khối từ danh sách dành riêng, ghi tiêu đề khối btree mới, điền vào
phần còn lại của khối có bản ghi và thêm khối lá mới vào danh sách
khối viết::

┌────┐
  │lá│
  │RRR │
  └────┘

Con trỏ anh chị em được đặt mỗi khi một khối mới được thêm vào cấp độ ::

┌────┐ ┌────┐ ┌────┐ ┌────┐
  │lá│→│lá│→│lá│→│lá│
  │RRR │←│RRR │←│RRR │←│RRR │
  └────┘ └────┘ └────┘ └────┘

Khi nó ghi xong các khối lá bản ghi, nó sẽ chuyển sang nút
khối
Để lấp đầy một khối nút, nó sẽ chuyển từng khối ở cấp độ tiếp theo xuống dưới cây
để tính toán các khóa có liên quan và ghi chúng vào nút cha ::

┌────┐ ┌────┐
      │nút│──────→│nút│
      │PP │←──────│PP │
      └────┘ └────┘
      ↙ ↘ ↙ ↘
  ┌────┐ ┌────┐ ┌────┐ ┌────┐
  │lá│→│lá│→│lá│→│lá│
  │RRR │←│RRR │←│RRR │←│RRR │
  └────┘ └────┘ └────┘ └────┘

Khi đạt đến cấp độ gốc, nó sẵn sàng cam kết btree mới!::

┌─────────┐
          │ gốc │
          │ PP │
          └─────────┘
          ↙ ↘
      ┌────┐ ┌────┐
      │nút│──────→│nút│
      │PP │←──────│PP │
      └────┘ └────┘
      ↙ ↘ ↙ ↘
  ┌────┐ ┌────┐ ┌────┐ ┌────┐
  │lá│→│lá│→│lá│→│lá│
  │RRR │←│RRR │←│RRR │←│RRR │
  └────┘ └────┘ └────┘ └────┘

Bước đầu tiên để chuyển giao btree mới là lưu các khối btree vào đĩa
một cách đồng bộ.
Điều này hơi phức tạp vì một khối btree mới có thể đã được giải phóng
trong thời gian gần đây nên người xây dựng phải sử dụng ZZ0000ZZ để
xóa bộ đệm (cũ) khỏi danh sách AIL trước khi nó có thể ghi các khối mới
vào đĩa.
Các khối được xếp hàng đợi IO bằng danh sách delwri và được viết thành một lô lớn
với ZZ0001ZZ.

Khi các khối mới đã được lưu vào đĩa, quyền điều khiển sẽ quay trở lại
chức năng sửa chữa riêng lẻ được gọi là bộ nạp số lượng lớn.
Chức năng sửa chữa phải ghi lại vị trí của root mới trong một giao dịch,
dọn dẹp các khoảng trống đã được đặt cho cây btree mới và thu thập
khối siêu dữ liệu cũ:

1. Cam kết vị trí của gốc btree mới.

2. Đối với mỗi lần đặt trước incore:

Một. Ghi lại các mục đã hoàn tất giải phóng mức độ (EFD) cho tất cả dung lượng đã được sử dụng
      bởi người xây dựng btree.  Các EFD mới phải trỏ đến các EFI được đính kèm với
      việc đặt trước để ngăn việc khôi phục nhật ký giải phóng các khối mới.

b. Đối với các phần đặt trước incore chưa được xác nhận, hãy tạo một khoản trả chậm thông thường
      mở rộng mục công việc miễn phí để giải phóng không gian chưa sử dụng sau này trong
      chuỗi giao dịch.

c. Các EFD và EFI đã đăng nhập ở bước 2a và 2b không được vượt quá
      bảo lưu giao dịch đã cam kết.
      Nếu mã tải btree nghi ngờ điều này có thể sắp xảy ra thì nó phải
      gọi ZZ0000ZZ để giải quyết công việc bị trì hoãn và nhận được
      giao dịch mới.

3. Xóa công việc bị trì hoãn lần thứ hai để hoàn thành cam kết và dọn dẹp
   giao dịch sửa chữa.

Giao dịch được thực hiện ở bước 2c và 3 thể hiện điểm yếu trong quá trình sửa chữa
thuật toán, bởi vì việc xóa nhật ký và sự cố trước khi kết thúc bước gặt có thể
dẫn đến rò rỉ không gian.
Chức năng sửa chữa trực tuyến giảm thiểu nguy cơ xảy ra điều này bằng cách sử dụng rất nhiều
các giao dịch lớn, mỗi giao dịch có thể chứa hàng nghìn giao dịch giải phóng khối
hướng dẫn.
Quá trình sửa chữa chuyển sang việc thu thập các khối cũ sẽ được trình bày dưới dạng
ZZ0000ZZ tiếp theo sau một vài nghiên cứu điển hình về tải số lượng lớn.

Nghiên cứu điển hình: Xây dựng lại chỉ số Inode
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Quá trình cấp cao để xây dựng lại btree chỉ mục inode là:

1. Đi qua các bản ghi ánh xạ ngược để tạo ZZ0000ZZ
   các bản ghi từ thông tin đoạn inode và một bitmap của btree inode cũ
   khối.

2. Nối các bản ghi vào xfarray theo thứ tự inode.

3. Sử dụng hàm ZZ0000ZZ để tính số
   số khối cần thiết cho cây inode.
   Nếu btree inode không gian trống được bật, hãy gọi lại nó để ước tính
   hình học của finobt.

4. Phân bổ số khối được tính ở bước trước.

5. Sử dụng ZZ0000ZZ để ghi các bản ghi xfarray vào các khối btree và
   tạo ra các khối nút bên trong.
   Nếu btree inode không gian trống được bật, hãy gọi lại nó để tải finobt.

6. Cam kết vị trí của (các) khối gốc btree mới cho AGI.

7. Gặt lại các khối btree cũ bằng cách sử dụng bitmap được tạo ở bước 1.

Chi tiết như sau.

Inode btree ánh xạ inumber tới vị trí ondisk của liên kết
các bản ghi inode, có nghĩa là các cây inode có thể được xây dựng lại từ
thông tin ánh xạ ngược.
Các bản ghi ánh xạ ngược với chủ sở hữu ZZ0000ZZ đánh dấu
vị trí của các khối btree inode cũ.
Mỗi bản ghi ánh xạ ngược có chủ sở hữu là ZZ0001ZZ đánh dấu
vị trí của ít nhất một bộ đệm cụm inode.
Một cụm là số lượng nút ondisk nhỏ nhất có thể được phân bổ hoặc
giải phóng trong một giao dịch duy nhất; nó không bao giờ nhỏ hơn 1 khối fs hoặc 4 nút.

Đối với không gian được đại diện bởi mỗi cụm inode, hãy đảm bảo rằng không có
các bản ghi trong btree không gian trống cũng như bất kỳ bản ghi nào trong btree đếm tham chiếu.
Nếu có thì sự không nhất quán của siêu dữ liệu không gian là lý do đủ để hủy bỏ
hoạt động.
Nếu không, hãy đọc từng bộ đệm cụm để kiểm tra xem nội dung của nó có vẻ như
inode ondisk và quyết định xem tập tin có được phân bổ hay không
(ZZ0000ZZ) hoặc miễn phí (ZZ0001ZZ).
Tích lũy kết quả đọc bộ đệm cụm inode liên tiếp cho đến khi có
đủ thông tin để điền vào một bản ghi đoạn inode đơn, dài 64 đoạn liên tiếp
các số trong không gian phím inumber.
Nếu đoạn này thưa thớt, bản ghi đoạn có thể chứa các lỗ hổng.

Khi chức năng sửa chữa tích lũy được một đoạn dữ liệu, nó sẽ gọi
ZZ0000ZZ để thêm bản ghi btree inode vào xfarray.
Xfarray này được thực hiện hai lần trong bước tạo btree -- một lần để điền vào
btree inode với tất cả các bản ghi đoạn inode và lần thứ hai để điền vào
btree inode miễn phí với các bản ghi cho các đoạn có các inode miễn phí không thưa thớt.
Số lượng bản ghi cho inode btree là số lượng bản ghi xfarray,
nhưng số lượng bản ghi cho btree inode miễn phí phải được tính dưới dạng đoạn inode
các bản ghi được lưu trữ trong xfarray.

Nghiên cứu điển hình: Xây dựng lại số lượng tham chiếu không gian
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Bản ghi ánh xạ ngược được sử dụng để xây dựng lại thông tin đếm tham chiếu.
Cần có số lượng tham chiếu để vận hành chính xác bản sao khi ghi để chia sẻ
dữ liệu tập tin.
Hãy tưởng tượng các mục ánh xạ ngược dưới dạng hình chữ nhật biểu thị phạm vi của
các khối vật lý và các hình chữ nhật có thể được đặt xuống để cho phép chúng
chồng lên nhau.
Từ sơ đồ bên dưới, rõ ràng là bản ghi số tham chiếu phải bắt đầu
hoặc kết thúc ở bất cứ nơi nào chiều cao của ngăn xếp thay đổi.
Nói cách khác, kích thích phát thải kỷ lục được kích hoạt theo cấp độ::

█ ███
              ██ █████ ████ ███ ██████
        ██ ████ ███████████ ████ █████████
        ████████████████████████████████ ███████████
        ^ ^ ^^ ^^ ^^ ^^ ^^^ ^^ ^^ ^^ ^^ ^^ ^ ^ ^
        2 1 23 21 3 43 234 2123 1 01 2 3 0

Btree đếm tham chiếu ondisk không lưu trữ các trường hợp đếm lại == 0 vì
btree không gian trống đã ghi lại khối nào trống.
Các phạm vi được sử dụng để thực hiện các hoạt động sao chép khi ghi phải là các bản ghi duy nhất
với số tiền hoàn lại == 1.
Khối tệp một chủ sở hữu không được ghi vào không gian trống hoặc
số lượng tài liệu tham khảo btrees.

Quy trình cấp cao để xây dựng lại btree đếm tham chiếu là:

1. Đi qua các bản ghi ánh xạ ngược để tạo ZZ0000ZZ
   bản ghi cho bất kỳ không gian nào có nhiều hơn một ánh xạ ngược và thêm chúng vào
   xfarray.
   Mọi bản ghi thuộc sở hữu của ZZ0001ZZ cũng được thêm vào xfarray
   bởi vì đây là những phạm vi được phân bổ để tạo một bản sao trong thao tác ghi và
   được theo dõi trong btree đếm tiền.

Sử dụng bất kỳ bản ghi nào thuộc sở hữu của ZZ0000ZZ để tạo bitmap cũ
   đếm lại khối btree.

2. Sắp xếp các bản ghi theo thứ tự phạm vi vật lý, đặt phạm vi dàn dựng CoW
   ở cuối xfarray.
   Điều này khớp với thứ tự sắp xếp của các bản ghi trong cây đếm lại.

3. Sử dụng hàm ZZ0000ZZ để tính số
   số khối cần thiết cho cây mới.

4. Phân bổ số khối được tính ở bước trước.

5. Sử dụng ZZ0000ZZ để ghi các bản ghi xfarray vào các khối btree và
   tạo ra các khối nút bên trong.

6. Cam kết vị trí của khối gốc btree mới cho AGF.

7. Gặt lại các khối btree cũ bằng cách sử dụng bitmap được tạo ở bước 1.

Chi tiết như sau; thuật toán tương tự được ZZ0000ZZ sử dụng để
tạo thông tin đếm lại từ các bản ghi ánh xạ ngược.

- Cho đến khi btree ánh xạ ngược hết bản ghi:

- Lấy bản ghi tiếp theo từ btree và cho vào túi.

- Thu thập tất cả các bản ghi có cùng khối bắt đầu từ cây btree và đặt
    chúng trong túi.

- Khi túi chưa rỗng:

- Trong số các ánh xạ trong túi, hãy tính số khối thấp nhất trong đó
      số lượng tham chiếu thay đổi.
      Vị trí này sẽ là số khối bắt đầu của khối tiếp theo
      ánh xạ ngược chưa được xử lý hoặc khối tiếp theo sau ánh xạ ngắn nhất
      trong túi.

- Loại bỏ tất cả các ánh xạ khỏi túi kết thúc ở vị trí này.

- Thu thập tất cả các ánh xạ ngược bắt đầu ở vị trí này từ btree
      và bỏ chúng vào túi.

- Nếu kích thước của túi thay đổi và lớn hơn một, hãy tạo mới
      bản ghi đếm lại liên kết phạm vi số khối mà chúng tôi vừa đi tới
      kích thước của túi.

Cấu trúc dạng túi trong trường hợp này là xfarray loại 2 như đã thảo luận trong phần
Phần ZZ0000ZZ.
Ánh xạ ngược được thêm vào túi bằng ZZ0001ZZ và
được xóa qua ZZ0002ZZ.
Các thành viên túi được kiểm tra thông qua các vòng lặp ZZ0003ZZ.

Nghiên cứu điển hình: Xây dựng lại các chỉ số ánh xạ ngã ba tệp
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Quy trình cấp cao để xây dựng lại btree ánh xạ ngã ba dữ liệu/attr là:

1. Đi qua các bản ghi ánh xạ ngược để tạo ZZ0000ZZ
   các bản ghi từ các bản ghi ánh xạ ngược cho nút và ngã ba đó.
   Nối các bản ghi này vào một xfarray.
   Tính toán bitmap của các khối bmap bmap cũ từ ZZ0001ZZ
   hồ sơ.

2. Sử dụng hàm ZZ0000ZZ để tính số
   số khối cần thiết cho cây mới.

3. Sắp xếp các bản ghi theo thứ tự offset của tệp.

4. Nếu các bản ghi phạm vi vừa với khu vực ngay lập tức của ngã ba inode, hãy cam kết
   ghi vào khu vực ngay lập tức đó và chuyển sang bước 8.

5. Phân bổ số khối được tính ở bước trước.

6. Sử dụng ZZ0000ZZ để ghi các bản ghi xfarray vào các khối btree và
   tạo ra các khối nút bên trong.

7. Cam kết khối gốc btree mới vào khu vực ngay lập tức của ngã ba inode.

8. Gặt lại các khối btree cũ bằng cách sử dụng bitmap được tạo ở bước 1.

Có một số điều phức tạp ở đây:
Đầu tiên, có thể di chuyển phần bù càng nâng để điều chỉnh kích thước của
các khu vực ngay lập tức nếu các nhánh dữ liệu và attr không ở cả định dạng BMBT.
Thứ hai, nếu có đủ ít ánh xạ rẽ nhánh, có thể sử dụng
Định dạng EXTENTS thay vì BMBT, có thể yêu cầu chuyển đổi.
Thứ ba, bản đồ phạm vi incore phải được tải lại cẩn thận để tránh làm phiền
bất kỳ mức độ phân bổ bị trì hoãn nào.

.. _reaping:

Thu thập các khối siêu dữ liệu cũ
---------------------------

Bất cứ khi nào fsck trực tuyến xây dựng cấu trúc dữ liệu mới để thay thế cấu trúc dữ liệu cũ
nghi ngờ, có một câu hỏi là làm thế nào để tìm và xử lý các khối
thuộc về cấu trúc cũ.
Phương pháp lười biếng nhất tất nhiên là không giải quyết chúng chút nào mà là từ từ
dẫn đến xuống cấp dịch vụ khi không gian bị rò rỉ ra khỏi hệ thống tập tin.
Hy vọng rằng ai đó sẽ lên lịch xây dựng lại thông tin dung lượng trống để
bịt tất cả những chỗ rò rỉ đó.
Sửa chữa ngoại tuyến sẽ xây dựng lại tất cả siêu dữ liệu không gian sau khi ghi lại việc sử dụng
các tập tin và thư mục mà nó quyết định không xóa, do đó nó có thể tạo mới
cấu trúc trong không gian trống được phát hiện và tránh vấn đề thu hoạch.

Là một phần của quá trình sửa chữa, fsck trực tuyến chủ yếu dựa vào các bản ghi ánh xạ ngược
để tìm không gian thuộc sở hữu của chủ sở hữu rmap tương ứng nhưng thực sự miễn phí.
Việc tham chiếu chéo các bản ghi rmap với các bản ghi rmap khác là cần thiết vì
có thể có những cấu trúc dữ liệu khác cũng cho rằng họ sở hữu một số cấu trúc đó
các khối (ví dụ: cây liên kết chéo).
Việc cho phép người cấp phát khối phân phát lại chúng sẽ không thúc đẩy hệ thống
hướng tới sự nhất quán.

Đối với siêu dữ liệu không gian, quá trình tìm kiếm phạm vi để xử lý nói chung
tuân theo định dạng này:

1. Tạo một bitmap không gian được sử dụng bởi các cấu trúc dữ liệu cần được bảo tồn.
   Việc đặt trước không gian được sử dụng để tạo siêu dữ liệu mới có thể được sử dụng ở đây nếu
   mã chủ sở hữu rmap tương tự được sử dụng để biểu thị tất cả các đối tượng đang được xây dựng lại.

2. Khảo sát dữ liệu ánh xạ ngược để tạo bitmap không gian thuộc sở hữu của
   cùng số ZZ0000ZZ cho siêu dữ liệu đang được bảo tồn.

3. Sử dụng toán tử tách bitmap để trừ (1) từ (2).
   Các bit tập hợp còn lại biểu thị phạm vi ứng cử viên có thể được giải phóng.
   Quá trình chuyển sang bước 4 bên dưới.

Sửa chữa siêu dữ liệu dựa trên tệp như thuộc tính mở rộng, thư mục,
liên kết tượng trưng, ​​tập tin hạn ngạch và bitmap thời gian thực được thực hiện bằng cách xây dựng một
cấu trúc mới được gắn vào một tệp tạm thời và trao đổi tất cả ánh xạ trong
nĩa tập tin.
Sau đó, các ánh xạ trong nhánh tập tin cũ là các khối ứng viên cho
xử lý.

Quy trình xử lý các phạm vi cũ như sau:

4. Đối với mỗi phạm vi ứng cử viên, hãy đếm số lượng bản ghi ánh xạ ngược cho
   khối đầu tiên trong phạm vi đó không có cùng chủ sở hữu rmap cho
   cấu trúc dữ liệu đang được sửa chữa

- Nếu bằng 0 thì khối có một chủ sở hữu duy nhất và có thể được giải phóng.

- Nếu không, khối này là một phần của cấu trúc liên kết ngang và không được phép
     được giải thoát.

5. Bắt đầu với khối tiếp theo trong phạm vi, tính xem có bao nhiêu khối nữa
   có cùng trạng thái chủ sở hữu khác bằng 0/khác 0 như khối đầu tiên đó.

6. Nếu vùng được liên kết chéo, hãy xóa mục ánh xạ ngược cho
   cấu trúc đang được sửa chữa và chuyển sang khu vực tiếp theo.

7. Nếu vùng cần được giải phóng, hãy đánh dấu bất kỳ vùng đệm tương ứng nào trong vùng đệm
   cache ở dạng cũ để ngăn chặn việc ghi lại nhật ký.

8. Giải phóng khu vực và đi tiếp.

Tuy nhiên, có một sự phức tạp đối với thủ tục này.
Giao dịch có kích thước hữu hạn nên quá trình thu thập phải cẩn thận
giao dịch để tránh bị vượt mức.
Vượt mức đến từ hai nguồn:

Một. EFI được đăng nhập thay mặt cho không gian không còn bị chiếm dụng

b. Ghi lại các mục khi bộ đệm bị vô hiệu hóa

Đây cũng là cửa sổ mà sự cố trong quá trình gặt có thể bị rò rỉ
khối.
Như đã nêu trước đó, chức năng sửa chữa trực tuyến sử dụng các giao dịch rất lớn để
giảm thiểu khả năng xảy ra điều này.

Nghiên cứu điển hình: Thu hoạch sau khi sửa chữa cây Btree thường xuyên
````````````````````````````````````````````````

Số tham chiếu cũ và btree inode là dễ lấy nhất vì chúng có
bản ghi rmap với mã chủ sở hữu đặc biệt: ZZ0000ZZ để được hoàn tiền
btree và ZZ0001ZZ cho btree inode và inode tự do.
Việc tạo danh sách các phạm vi để gặt các khối btree cũ khá đơn giản,
về mặt khái niệm:

1. Khóa bộ đệm tiêu đề AGI/AGF có liên quan để ngăn chặn việc phân bổ và giải phóng.

2. Đối với mỗi bản ghi ánh xạ ngược có chủ sở hữu rmap tương ứng với
   cấu trúc siêu dữ liệu đang được xây dựng lại, hãy đặt phạm vi tương ứng trong bitmap.

3. Đi theo cấu trúc dữ liệu hiện tại có cùng chủ sở hữu rmap.
   Đối với mỗi khối được truy cập, hãy xóa phạm vi đó trong bitmap trên.

4. Mỗi bit được đặt trong bitmap đại diện cho một khối có thể là một khối từ
   cấu trúc dữ liệu cũ và do đó là một ứng cử viên để khai thác.
   Nói cách khác, ZZ0000ZZ
   là những khối có thể được giải phóng.

Nếu có thể duy trì khóa AGF trong suốt quá trình sửa chữa (đó là
trường hợp thông thường), thì bước 2 có thể được thực hiện cùng lúc với bước ngược lại
ánh xạ bản ghi đi bộ tạo bản ghi cho btree mới.

Nghiên cứu điển hình: Xây dựng lại các chỉ số không gian trống
`````````````````````````````````````````````

Quy trình cấp cao để xây dựng lại các chỉ số không gian trống là:

1. Đi qua các bản ghi ánh xạ ngược để tạo ZZ0000ZZ
   ghi lại từ những khoảng trống trong btree ánh xạ ngược.

2. Nối các bản ghi vào xfarray.

3. Sử dụng hàm ZZ0000ZZ để tính số
   số khối cần thiết cho mỗi cây mới.

4. Phân bổ số khối được tính ở bước trước từ khối trống
   thông tin không gian được thu thập

5. Sử dụng ZZ0000ZZ để ghi các bản ghi xfarray vào các khối btree và
   tạo các khối nút bên trong cho không gian trống theo chỉ số độ dài.
   Gọi lại để có dung lượng trống theo chỉ số số khối.

6. Cam kết vị trí của các khối gốc btree mới cho AGF.

7. Gặt lại các khối btree cũ bằng cách tìm kiếm khoảng trống không được ghi lại bởi
   btree ánh xạ ngược, btree không gian trống mới hoặc AGFL.

Việc sửa chữa các cây không gian trống có ba vấn đề phức tạp chính so với thông thường
sửa chữa btree:

Đầu tiên, không gian trống không được theo dõi rõ ràng trong các bản ghi ánh xạ ngược.
Do đó, các bản ghi không gian trống mới phải được suy ra từ những khoảng trống trong không gian vật lý.
thành phần không gian của không gian khóa của btree ánh xạ ngược.

Thứ hai, việc sửa chữa không gian trống không thể sử dụng mã đặt chỗ btree thông thường vì
các khối mới được dành riêng ngoài btrees không gian trống.
Điều này là không thể khi tự sửa chữa các cây không gian trống.
Tuy nhiên, việc sửa chữa sẽ giữ khóa bộ đệm AGF trong suốt thời gian còn trống
xây dựng lại chỉ mục, do đó nó có thể sử dụng thông tin không gian trống được thu thập để
cung cấp các khối cho btrees không gian trống mới.
Không cần thiết phải sao lưu từng phạm vi dành riêng bằng EFI vì phiên bản mới
btree không gian trống được xây dựng theo hệ thống tập tin ondisk nghĩ là
không gian vô danh.
Tuy nhiên, nếu đặt trước các khối cho cây btree mới từ không gian trống đã thu thập
thông tin thay đổi số lượng bản ghi dung lượng trống, sửa chữa phải ước tính lại
hình học btree không gian trống mới với số lượng bản ghi mới cho đến khi
đặt phòng là đủ.
Là một phần của việc cam kết các btree mới, việc sửa chữa phải đảm bảo rằng ánh xạ ngược
được tạo cho các khối dành riêng và các khối dành riêng không được sử dụng sẽ được
được chèn vào btree không gian trống.
Các hoạt động giải phóng và rmap bị trì hoãn được sử dụng để đảm bảo rằng quá trình chuyển đổi này
là nguyên tử, tương tự như các chức năng sửa chữa btree khác.

Thứ ba, việc tìm khối để gặt sau khi sửa chữa không quá khó
đơn giản.
Các khối dành cho cây không gian trống và cây ánh xạ ngược được cung cấp bởi
AGFL.
Các khối đưa vào AGFL có bản ghi ánh xạ ngược với chủ sở hữu
ZZ0000ZZ.
Quyền sở hữu này được giữ lại khi các khối di chuyển từ AGFL vào không gian trống
btrees hoặc btrees ánh xạ ngược.
Khi sửa chữa các bản ghi ánh xạ ngược để tổng hợp các bản ghi không gian trống, nó
tạo một bitmap (ZZ0001ZZ) của tất cả không gian được xác nhận bởi
Bản ghi ZZ0002ZZ.
Bối cảnh sửa chữa duy trì bitmap thứ hai tương ứng với rmap btree
khối và khối AGFL (ZZ0003ZZ).
Khi quá trình đi bộ hoàn tất, thao tác phân tách bitmap ZZ0004ZZ sẽ tính toán phạm vi được sử dụng bởi không gian trống cũ
btrees.
Những khối này sau đó có thể được thu thập bằng cách sử dụng các phương pháp được nêu ở trên.

.. _rmap_reap:

Nghiên cứu điển hình: Thu hoạch sau khi sửa chữa Btree ánh xạ ngược
``````````````````````````````````````````````````````````

Các cây ánh xạ ngược cũ sẽ ít khó thu thập hơn sau khi sửa chữa.
Như đã đề cập ở phần trước, các khối trên AGFL, hai không gian trống
các khối btree và các khối btree ánh xạ ngược đều có ánh xạ ngược
ghi lại với ZZ0001ZZ là chủ sở hữu.
Toàn bộ quá trình thu thập các bản ghi ánh xạ ngược và xây dựng btree mới
được mô tả trong nghiên cứu trường hợp của
ZZ0000ZZ, nhưng một điểm quan trọng từ đó
thảo luận là rmap btree mới sẽ không chứa bất kỳ bản ghi nào cho cái cũ
rmap btree, các khối btree cũ cũng sẽ không được theo dõi trong btrees không gian trống.
Danh sách các khối thu thập ứng cử viên được tính bằng cách thiết lập các bit
tương ứng với các khoảng trống trong bản ghi btree rmap mới, sau đó xóa
các bit tương ứng với phạm vi trong btrees không gian trống và AGFL hiện tại
khối.
Kết quả ZZ0002ZZ được thu thập bằng cách sử dụng
các phương pháp đã nêu ở trên.

Phần còn lại của quá trình xây dựng lại btree ánh xạ ngược sẽ được thảo luận
trong một ZZ0000ZZ riêng biệt.

Nghiên cứu điển hình: Xây dựng lại AGFL
```````````````````````````````

Danh sách chặn miễn phí nhóm phân bổ (AGFL) được sửa chữa như sau:

1. Tạo một bitmap cho tất cả không gian mà dữ liệu ánh xạ ngược yêu cầu
   thuộc sở hữu của ZZ0000ZZ.

2. Trừ không gian được sử dụng bởi hai cây không gian trống và cây rmap.

3. Trừ đi mọi khoảng trống mà dữ liệu bản đồ ngược tuyên bố thuộc sở hữu của bất kỳ ai
   chủ sở hữu khác, để tránh thêm lại các khối liên kết chéo vào AGFL.

4. Khi AGFL đã đầy, hãy thu thập mọi khối còn sót lại.

5. Thao tác tiếp theo để sửa danh sách tự do sẽ điều chỉnh kích thước danh sách cho phù hợp.

Xem ZZ0000ZZ để biết thêm chi tiết.

Sửa chữa bản ghi Inode
--------------------

Các bản ghi inode phải được xử lý cẩn thận, vì chúng có cả bản ghi ondisk
("dinodes") và biểu diễn trong bộ nhớ ("được lưu trong bộ nhớ cache").
Có khả năng xảy ra các vấn đề liên kết bộ đệm rất cao nếu fsck trực tuyến không được hỗ trợ
cẩn thận truy cập siêu dữ liệu ondisk ZZ0000ZZ khi siêu dữ liệu ondisk như vậy
bị hỏng nặng đến mức hệ thống tập tin không thể tải biểu diễn trong bộ nhớ.
Khi fsck trực tuyến muốn mở một tệp bị hỏng để xóa, nó phải sử dụng
các chức năng thu thập tài nguyên chuyên dụng trả về dữ liệu trong bộ nhớ
đại diện ZZ0001ZZ khóa trên bất kỳ đối tượng nào là cần thiết để ngăn chặn bất kỳ
cập nhật vào vị trí ondisk.

Việc sửa chữa duy nhất cần được thực hiện đối với bộ đệm inode ondisk là bất cứ điều gì
là cần thiết để tải cấu trúc trong lõi.
Điều này có nghĩa là sửa chữa bất cứ thứ gì bị bắt bởi bộ đệm cụm inode và ngã ba inode
trình xác minh và thử lại thao tác ZZ0000ZZ.
Nếu ZZ0001ZZ thứ hai bị lỗi thì việc sửa chữa đã thất bại.

Khi biểu diễn trong bộ nhớ được tải, việc sửa chữa có thể khóa inode và có thể
phải kiểm tra, sửa chữa và tối ưu hóa toàn diện.
Hầu hết các thuộc tính inode đều dễ kiểm tra và hạn chế hoặc do người dùng kiểm soát
mẫu bit tùy ý; cả hai đều dễ sửa.
Xử lý dữ liệu và số lượng phạm vi ngã ba attr cũng như số lượng khối tệp là
phức tạp hơn, vì việc tính toán giá trị chính xác đòi hỏi phải duyệt qua
phân nhánh hoặc nếu thất bại, hãy để các trường không hợp lệ và chờ phân nhánh
chức năng fsck để chạy.

Sửa chữa bản ghi hạn ngạch
--------------------

Tương tự như inode, các bản ghi hạn ngạch ("dquots") cũng có cả bản ghi ondisk và
một biểu diễn trong bộ nhớ và do đó phải tuân theo cùng một tính nhất quán của bộ nhớ đệm
vấn đề.
Hơi khó hiểu, cả hai đều được gọi là dquot trong cơ sở mã XFS.

Việc sửa chữa duy nhất cần được thực hiện đối với bộ đệm bản ghi hạn ngạch ondisk là
bất cứ điều gì cần thiết để tải cấu trúc trong lõi.
Khi biểu diễn trong bộ nhớ được tải, các thuộc tính duy nhất cần
kiểm tra rõ ràng là các giới hạn xấu và giá trị bộ đếm thời gian.

Bộ đếm mức sử dụng hạn mức được kiểm tra, sửa chữa và thảo luận riêng trong phần
phần về ZZ0000ZZ.

.. _fscounters:

Đóng băng để sửa bộ đếm tóm tắt
--------------------------------

Bộ đếm tóm tắt hệ thống tập tin theo dõi tính khả dụng của tài nguyên hệ thống tập tin như
dưới dạng các khối miễn phí, các nút miễn phí và các nút được phân bổ.
Thông tin này có thể được biên soạn bằng cách duyệt qua các chỉ mục không gian trống và inode,
nhưng đây là một quá trình chậm, vì vậy XFS duy trì một bản sao trong siêu khối ondisk
nó sẽ phản ánh siêu dữ liệu trên đĩa, ít nhất là khi hệ thống tập tin đã được
tháo lắp sạch sẽ.
Vì lý do hiệu suất, XFS cũng duy trì các bản sao nội bộ của các bộ đếm đó,
đó là chìa khóa để cho phép đặt trước tài nguyên cho các giao dịch đang hoạt động.
Các luồng Writer dự trữ số lượng tài nguyên trong trường hợp xấu nhất từ
bộ đếm incore và trả lại bất cứ thứ gì họ không sử dụng vào thời điểm cam kết.
Do đó chỉ cần thiết phải tuần tự hóa trên siêu khối khi
superblock đang được chuyển sang đĩa.

Tính năng bộ đếm siêu khối lười biếng được giới thiệu trong XFS v5 đã đưa điều này đi xa hơn nữa
bằng cách đào tạo việc khôi phục nhật ký để tính toán lại bộ đếm tóm tắt từ các tiêu đề AG,
điều này đã loại bỏ nhu cầu thực hiện hầu hết các giao dịch, thậm chí là chạm vào siêu khối.
Lần duy nhất XFS thực hiện các bộ đếm tóm tắt là khi ngắt kết nối hệ thống tập tin.
Để giảm sự tranh chấp hơn nữa, bộ đếm incore được triển khai như một
bộ đếm percpu, có nghĩa là mỗi CPU được phân bổ một loạt khối từ một
bộ đếm incore toàn cục và có thể đáp ứng các phân bổ nhỏ từ lô cục bộ.

Bản chất hiệu suất cao của bộ đếm tóm tắt gây khó khăn cho
fsck trực tuyến để kiểm tra chúng, vì không có cách nào để tắt bộ đếm percpu
trong khi hệ thống đang chạy.
Mặc dù fsck trực tuyến có thể đọc siêu dữ liệu hệ thống tập tin để tính toán chính xác
giá trị của bộ đếm tóm tắt, không có cách nào để giữ giá trị của một percpu
bộ đếm ổn định, do đó rất có thể bộ đếm sẽ lỗi thời
thời điểm cuộc đi bộ kết thúc.
Các phiên bản trước của quá trình xóa trực tuyến sẽ quay trở lại không gian người dùng với bản cập nhật chưa hoàn chỉnh.
cờ quét, nhưng đây không phải là kết quả khiến người quản trị hệ thống hài lòng.
Để sửa chữa, bộ đếm trong bộ nhớ phải được ổn định khi di chuyển
siêu dữ liệu hệ thống tập tin để có được kết quả đọc chính xác và cài đặt nó trong percpu
quầy.

Để đáp ứng yêu cầu này, fsck trực tuyến phải ngăn chặn các chương trình khác trong
hệ thống bắt đầu ghi mới vào hệ thống tập tin, nó phải vô hiệu hóa nền
các luồng thu gom rác và nó phải đợi các chương trình ghi hiện có
thoát khỏi hạt nhân.
Khi điều đó đã được thiết lập, chà có thể thực hiện các chỉ mục không gian trống AG,
btree inode và bitmap thời gian thực để tính toán giá trị chính xác của tất cả
bốn quầy tóm tắt.
Điều này rất giống với việc đóng băng hệ thống tập tin, mặc dù không phải tất cả các phần đều được
cần thiết:

- Trạng thái đóng băng cuối cùng được đặt cao hơn ZZ0000ZZ một
  ngăn chặn các luồng khác làm tan băng hệ thống tập tin hoặc các luồng chà khác
  từ việc bắt đầu đóng băng fscounters khác.

- Nó không làm yên nhật ký.

Với mã này, giờ đây có thể tạm dừng hệ thống tập tin chỉ trong
đủ lâu để kiểm tra và sửa các bộ đếm tóm tắt.

+-----------------------------------------------------------------------------------+
ZZ0005ZZ
+-----------------------------------------------------------------------------------+
ZZ0006ZZ
ZZ0007ZZ
ZZ0008ZZ
ZZ0009ZZ
ZZ0010ZZ
ZZ0011ZZ
ZZ0012ZZ
ZZ0013ZZ
ZZ0014ZZ
ZZ0015ZZ
ZZ0016ZZ
ZZ0017ZZ
ZZ0018ZZ
ZZ0019ZZ
ZZ0020ZZ
ZZ0021ZZ
ZZ0022ZZ
ZZ0023ZZ
ZZ0024ZZ
ZZ0025ZZ
ZZ0026ZZ
ZZ0027ZZ
ZZ0028ZZ
ZZ0029ZZ
ZZ0030ZZ
ZZ0031ZZ
ZZ0032ZZ
ZZ0033ZZ
ZZ0034ZZ
ZZ0035ZZ
ZZ0036ZZ
ZZ0037ZZ
+-----------------------------------------------------------------------------------+

Quét toàn bộ hệ thống tập tin
---------------------

Một số loại siêu dữ liệu nhất định chỉ có thể được kiểm tra bằng cách duyệt từng tệp trong
toàn bộ hệ thống tập tin để ghi lại các quan sát và so sánh các quan sát với
những gì được ghi trên đĩa.
Giống như mọi loại sửa chữa trực tuyến khác, việc sửa chữa được thực hiện bằng cách viết những
quan sát vào đĩa trong một cấu trúc thay thế và thực hiện nó một cách nguyên tử.
Tuy nhiên, việc tắt toàn bộ hệ thống tập tin để kiểm tra là không thực tế.
hàng trăm tỷ tập tin vì thời gian ngừng hoạt động sẽ quá lớn.
Do đó, fsck trực tuyến phải xây dựng cơ sở hạ tầng để quản lý việc quét trực tiếp
tất cả các tập tin trong hệ thống tập tin.
Có hai câu hỏi cần được giải quyết để thực hiện bước đi trực tiếp:

- Làm cách nào để chà quản lý quá trình quét trong khi đang thu thập dữ liệu?

- Làm thế nào quá trình quét theo kịp các thay đổi được thực hiện đối với hệ thống bởi người khác
  chủ đề?

.. _iscan:

Quét Inode phối hợp
```````````````````````

Trong hệ thống tập tin Unix đầu tiên của những năm 1970, mỗi mục thư mục chứa
một số chỉ mục (ZZ0002ZZ) được sử dụng làm chỉ mục trên mảng ondisk
(ZZ0003ZZ) của các bản ghi có kích thước cố định (ZZ0004ZZ) mô tả các thuộc tính và
ánh xạ khối dữ liệu của nó.
Hệ thống này được mô tả bởi J. Lions, ZZ0000ZZ trong *Lions' Commentary on
UNIX, Phiên bản thứ 6*, (Khoa Khoa học Máy tính, Đại học New South
Wales, tháng 11 năm 1977), trang 18-2; và sau đó là D. Ritchie và K. Thompson,
ZZ0001ZZ, từ *UNIX
Hệ thống chia sẻ thời gian*, (Tạp chí Kỹ thuật Hệ thống Bell, tháng 7 năm 1978), tr.
1913-4.

XFS giữ lại hầu hết thiết kế này, ngoại trừ bây giờ inumbers là phím tìm kiếm trên tất cả
không gian trong hệ thống tập tin phần dữ liệu.
Chúng tạo thành một không gian khóa liên tục có thể được biểu diễn dưới dạng số nguyên 64 bit,
mặc dù bản thân các nút này được phân bố thưa thớt trong không gian khóa.
Quá trình quét tiến hành theo kiểu tuyến tính trên không gian phím inumber, bắt đầu từ
ZZ0000ZZ và kết thúc ở ZZ0001ZZ.
Đương nhiên, việc quét qua không gian phím yêu cầu đối tượng con trỏ quét để theo dõi
tiến trình quét.
Bởi vì không gian phím này thưa thớt nên con trỏ này chứa hai phần.
Phần đầu tiên của đối tượng con trỏ quét này sẽ theo dõi inode sẽ được
kiểm tra tiếp theo; gọi đây là con trỏ kiểm tra.
Ít rõ ràng hơn, đối tượng con trỏ quét cũng phải theo dõi phần nào của
không gian khóa đã được truy cập, điều này rất quan trọng để quyết định xem liệu một
cập nhật hệ thống tập tin đồng thời cần được tích hợp vào dữ liệu quét.
Gọi đây là con trỏ inode đã truy cập.

Tiến lên con trỏ quét là một quá trình gồm nhiều bước được gói gọn trong
ZZ0000ZZ:

1. Khóa bộ đệm AGI của AG chứa inode được trỏ tới bởi điểm truy cập
   con trỏ inode.
   Điều này đảm bảo rằng các nút trong AG này không thể được phân bổ hoặc giải phóng trong khi
   tiến con trỏ.

2. Sử dụng btree inode trên mỗi AG để tra cứu inumber tiếp theo sau inumber đó
   vừa được truy cập, vì nó có thể không liền kề với không gian phím.

3. Nếu không còn nút nào trong AG này:

Một. Di chuyển con trỏ kiểm tra đến điểm của vùng phím inumber
      tương ứng với thời điểm bắt đầu của AG tiếp theo.

b. Điều chỉnh con trỏ inode đã truy cập để cho biết rằng nó đã "truy cập"
      inode cuối cùng có thể có trong không gian phím inode của AG hiện tại.
      Các số XFS được phân đoạn, do đó con trỏ cần được đánh dấu là có
      đã truy cập toàn bộ không gian phím cho đến ngay trước khi bắt đầu AG tiếp theo
      không gian phím inode.

c. Mở khóa AGI và quay lại bước 1 nếu có AG chưa được kiểm tra trong
      hệ thống tập tin.

d. Nếu không còn AG nào để kiểm tra, hãy đặt cả hai con trỏ ở cuối
      không gian phím inumber.
      Quá trình quét hiện đã hoàn tất.

4. Mặt khác, có ít nhất một nút nữa để quét trong AG này:

Một. Di chuyển con trỏ kiểm tra tới nút tiếp theo được đánh dấu là đã phân bổ
      bởi btree inode.

b. Điều chỉnh con trỏ inode đã truy cập để trỏ đến inode ngay trước vị trí
      con trỏ kiểm tra bây giờ.
      Bởi vì máy quét giữ khóa bộ đệm AGI nên không có nút nào có thể được
      được tạo trong phần không gian khóa inode mà con trỏ inode đã truy cập
      vừa tiến bộ.

5. Lấy incore inode cho số i của con trỏ kiểm tra.
   Bằng cách duy trì khóa bộ đệm AGI cho đến thời điểm này, máy quét sẽ biết rằng
   việc di chuyển con trỏ kiểm tra trên toàn bộ không gian phím là an toàn,
   và nó đã ổn định nút tiếp theo này để nó không thể biến mất khỏi
   hệ thống tập tin cho đến khi quá trình quét giải phóng incore inode.

6. Thả khóa AGI và trả lại incore inode cho người gọi.

Chức năng fsck trực tuyến quét tất cả các tệp trong hệ thống tệp như sau:

1. Bắt đầu quét bằng cách gọi ZZ0000ZZ.

2. Tiến con trỏ quét (ZZ0000ZZ) để lấy inode tiếp theo.
   Nếu một cái được cung cấp:

Một. Khóa inode để ngăn cập nhật trong quá trình quét.

b. Quét inode.

c. Trong khi vẫn giữ khóa inode, điều chỉnh con trỏ inode đã truy cập
      (ZZ0000ZZ) để trỏ tới inode này.

d. Mở khóa và giải phóng inode.

8. Gọi ZZ0000ZZ để hoàn tất quá trình quét.

Có một số điểm phức tạp với bộ đệm inode làm phức tạp việc lấy incore
inode cho người gọi.
Rõ ràng, yêu cầu tuyệt đối là siêu dữ liệu inode phải nhất quán
đủ để tải nó vào bộ đệm inode.
Thứ hai, nếu incore inode bị kẹt ở trạng thái trung gian nào đó, quá trình quét sẽ
điều phối viên phải giải phóng AGI và đẩy hệ thống tập tin chính để lấy inode
trở lại trạng thái có thể tải được.

Quản lý nút
````````````````

Trong mã hệ thống tập tin thông thường, các tham chiếu đến các nút incore XFS được phân bổ là
luôn thu được (ZZ0000ZZ) bên ngoài bối cảnh giao dịch vì
việc tạo ngữ cảnh cốt lõi cho tệp hiện có không yêu cầu siêu dữ liệu
cập nhật.
Tuy nhiên, điều quan trọng cần lưu ý là các tham chiếu đến incore inode thu được dưới dạng
một phần của việc tạo tập tin phải được thực hiện trong ngữ cảnh giao dịch vì
hệ thống tập tin phải đảm bảo tính nguyên tử của các cập nhật chỉ mục btree ondisk inode
và khởi tạo inode ondisk thực tế.

Các tham chiếu đến incore inode luôn được giải phóng (ZZ0000ZZ) bên ngoài
bối cảnh giao dịch vì có một số hoạt động có thể
yêu cầu cập nhật ondisk:

- VFS có thể quyết định bắt đầu ghi lại như một phần của nút ZZ0000ZZ
  thả ra.

- Việc phân bổ trước mang tính đầu cơ cần phải không được bảo lưu.

- Một tập tin không được liên kết có thể đã mất tham chiếu cuối cùng của nó, trong trường hợp đó toàn bộ
  tập tin phải được vô hiệu hóa, bao gồm việc giải phóng tất cả tài nguyên của nó trong
  siêu dữ liệu ondisk và giải phóng inode.

Những hoạt động này được gọi chung là vô hiệu hóa inode.
Việc ngừng hoạt động có hai phần -- phần VFS, bắt đầu ghi lại tất cả
các trang tệp bẩn và phần XFS, giúp dọn sạch thông tin dành riêng cho XFS
và giải phóng inode nếu nó không được liên kết.
Nếu inode không được liên kết (hoặc không được kết nối sau thao tác xử lý tệp), thì
kernel thả inode vào bộ máy bất hoạt ngay lập tức.

Trong quá trình hoạt động bình thường, việc thu thập tài nguyên để cập nhật tuân theo thứ tự này
để tránh bế tắc:

1. Tham chiếu nút (ZZ0000ZZ).

2. Bảo vệ đóng băng hệ thống tập tin, nếu sửa chữa (ZZ0000ZZ).

3. Khóa Inode ZZ0000ZZ (VFS ZZ0001ZZ) để điều khiển file IO.

4. Khóa Inode ZZ0000ZZ (bộ đệm trang ZZ0001ZZ) cho các hoạt động
   có thể cập nhật ánh xạ bộ đệm trang.

5. Kích hoạt tính năng nhật ký.

6. Cấp không gian nhật ký giao dịch.

7. Không gian trên dữ liệu và thiết bị thời gian thực cho giao dịch.

8. Incore dquot tham chiếu, nếu một tập tin đang được sửa chữa.
   Lưu ý rằng chúng không bị khóa, chỉ có được.

9. Inode ZZ0000ZZ để cập nhật siêu dữ liệu tệp.

10. Khóa bộ đệm tiêu đề AG / Inode siêu dữ liệu thời gian thực ILOCK.

11. Khóa bộ đệm siêu dữ liệu thời gian thực, nếu có.

12. Ánh xạ các khối btree theo phạm vi rộng, nếu có.

Tài nguyên thường được giải phóng theo thứ tự ngược lại, mặc dù điều này không bắt buộc.
Tuy nhiên, fsck trực tuyến khác với các hoạt động XFS thông thường vì nó có thể kiểm tra
một đối tượng thường có được ở giai đoạn sau của lệnh khóa và
sau đó quyết định tham chiếu chéo đối tượng với đối tượng thu được
trước đó trong đơn đặt hàng.
Một số phần tiếp theo trình bày chi tiết các cách cụ thể mà fsck trực tuyến xử lý
để tránh bế tắc.

iget và irele Trong khi chà
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Quét inode được thực hiện thay mặt cho thao tác chà chạy trong giao dịch
bối cảnh và có thể với các tài nguyên đã bị khóa và ràng buộc với nó.
Đây không phải là vấn đề lớn đối với ZZ0000ZZ vì nó có thể hoạt động trong ngữ cảnh
của một giao dịch hiện có, miễn là tất cả các tài nguyên bị ràng buộc đều được mua lại
trước tham chiếu inode trong hệ thống tập tin thông thường.

Khi hàm VFS ZZ0000ZZ được cấp một nút liên kết không có nút nào khác
tài liệu tham khảo, nó thường đặt inode vào danh sách LRU với hy vọng rằng nó có thể
tiết kiệm thời gian nếu một tiến trình khác mở lại file trước khi hệ thống hết
bộ nhớ và giải phóng nó.
Người gọi hệ thống tập tin có thể đoản mạch quy trình LRU bằng cách đặt ZZ0001ZZ
gắn cờ trên inode để khiến kernel cố gắng thả inode vào
ngừng hoạt động máy móc ngay lập tức.

Trước đây, việc vô hiệu hóa luôn được thực hiện từ quá trình loại bỏ
inode, đây là một vấn đề đối với chà vì chà có thể đã giữ một
giao dịch và XFS không hỗ trợ các giao dịch lồng nhau.
Mặt khác, nếu không có giao dịch chà, thì nên loại bỏ
nếu không thì các nút không được sử dụng ngay lập tức để tránh gây ô nhiễm bộ đệm.
Để nắm bắt được những sắc thái này, mã fsck trực tuyến có ZZ0000ZZ riêng
chức năng đặt hoặc xóa cờ ZZ0001ZZ để có được bản phát hành cần thiết
hành vi.

.. _ilocking:

Khóa Inode
^^^^^^^^^^^^^^

Trong mã hệ thống tệp thông thường, VFS và XFS sẽ thu được nhiều khóa IOLOCK
theo thứ tự quen thuộc: cha mẹ → con khi cập nhật cây thư mục và
theo thứ tự số của các địa chỉ của đối tượng ZZ0000ZZ của chúng.
Đối với các tệp thông thường, MMAPLOCK có thể được lấy sau IOLOCK để dừng trang
lỗi.
Nếu phải lấy hai MMAPLOCK, chúng sẽ được lấy theo thứ tự số
địa chỉ của các đối tượng ZZ0001ZZ của họ.
Do cấu trúc của mã hệ thống tập tin hiện có, IOLOCK và MMAPLOCK phải được
có được trước khi giao dịch được phân bổ.
Nếu phải lấy hai ILOCK, chúng sẽ được lấy theo thứ tự inumber.

Việc thu thập khóa inode phải được thực hiện cẩn thận trong quá trình quét inode phối hợp.
fsck trực tuyến không thể tuân theo các quy ước này, vì đối với cây thư mục
máy quét, quá trình chà sẽ giữ IOLOCK của tệp đang được quét và nó
cần lấy IOLOCK của tệp ở đầu kia của liên kết thư mục.
Nếu cây thư mục bị hỏng vì nó chứa chu trình, ZZ0000ZZ
không thể sử dụng các chức năng khóa inode thông thường và tránh bị mắc kẹt trong một
ABBA bế tắc.

Giải quyết cả hai vấn đề này đều đơn giản -- fsck trực tuyến bất cứ lúc nào
cần lấy khóa thứ hai cùng loại, nó sử dụng khóa thử để tránh ABBA
bế tắc.
Nếu khóa thử không thành công, chà sẽ loại bỏ tất cả các khóa inode và sử dụng vòng lặp trylock để
(lại) có được tất cả các nguồn lực cần thiết.
Vòng lặp Trylock cho phép chà để kiểm tra các tín hiệu nghiêm trọng đang chờ xử lý, đó là cách
chà tránh làm tắc nghẽn hệ thống tập tin hoặc trở thành một quá trình không phản hồi.
Tuy nhiên, vòng lặp trylock có nghĩa là fsck trực tuyến phải được chuẩn bị để đo lường
tài nguyên đang được lọc trước và sau chu kỳ khóa để phát hiện các thay đổi và
phản ứng tương ứng.

.. _dirparent:

Nghiên cứu điển hình: Tìm thư mục gốc
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Hãy xem xét mã sửa chữa con trỏ thư mục cha làm ví dụ.
fsck trực tuyến phải xác minh rằng thư mục dotdot của một thư mục trỏ đến một
thư mục mẹ và thư mục mẹ chứa chính xác một thư mục trực tiếp
trỏ xuống thư mục con.
Việc xác nhận đầy đủ mối quan hệ này (và sửa chữa nó nếu có thể) yêu cầu một
đi qua mọi thư mục trên hệ thống tập tin trong khi vẫn khóa trẻ và
trong khi cập nhật cây thư mục đang được thực hiện.
Quét inode phối hợp cung cấp một cách để điều khiển hệ thống tập tin mà không cần
khả năng thiếu một inode.
Thư mục con được khóa để ngăn chặn các cập nhật tới thư mục dotdot dirent, nhưng
nếu máy quét không khóa được cha mẹ, nó có thể thả và khóa lại cả trẻ
và cha mẹ tương lai.
Nếu mục nhập dấu chấm thay đổi trong khi thư mục được mở khóa thì việc di chuyển hoặc
thao tác đổi tên phải thay đổi nguồn gốc của trẻ và quá trình quét có thể
thoát sớm.

.. _fshooks:

Móc hệ thống tập tin
`````````````````

Phần hỗ trợ thứ hai mà các chức năng fsck trực tuyến cần trong suốt quá trình
quét hệ thống tập tin là khả năng cập nhật thông tin về các cập nhật được thực hiện bởi
các luồng khác trong hệ thống tập tin, vì việc so sánh với quá khứ là vô ích
trong một môi trường năng động.
Hai phần cơ sở hạ tầng nhân Linux cho phép fsck trực tuyến giám sát thường xuyên
hoạt động của hệ thống tập tin: móc hệ thống tập tin và ZZ0000ZZ.

Các hook hệ thống tập tin truyền tải thông tin về hoạt động đang diễn ra của hệ thống tập tin tới
một người tiêu dùng ở hạ nguồn.
Trong trường hợp này, người tiêu dùng xuôi dòng luôn là một hàm fsck trực tuyến.
Vì nhiều hàm fsck có thể chạy song song nên fsck trực tuyến sử dụng Linux
cơ sở chuỗi cuộc gọi thông báo để gửi thông tin cập nhật tới bất kỳ số lượng người quan tâm nào
quá trình fsck.
Chuỗi cuộc gọi là một danh sách động, có nghĩa là chúng có thể được cấu hình tại
thời gian chạy.
Bởi vì các hook này là riêng tư đối với mô-đun XFS nên thông tin được truyền đi
chứa chính xác những gì chức năng kiểm tra cần để cập nhật các quan sát của nó.

Việc triển khai móc XFS hiện tại sử dụng chuỗi trình thông báo SRCU để giảm
tác động đến khối lượng công việc có nhiều luồng.
Chuỗi thông báo chặn thông thường sử dụng rwsem và dường như có mức độ thấp hơn nhiều
chi phí chung cho các ứng dụng đơn luồng.
Tuy nhiên, có thể hóa ra là sự kết hợp giữa chuỗi chặn và chuỗi tĩnh
các phím là sự kết hợp hiệu quả hơn; cần nghiên cứu thêm ở đây.

Các phần sau đây là cần thiết để nối một điểm nhất định trong hệ thống tập tin:

- Đối tượng ZZ0000ZZ phải được nhúng ở nơi thuận tiện như
  một đối tượng hệ thống tập tin incore nổi tiếng.

- Mỗi hook phải xác định một mã hành động và cấu trúc chứa nhiều ngữ cảnh hơn
  về hành động.

- Nhà cung cấp hook nên cung cấp các hàm và cấu trúc bao bọc thích hợp
  xung quanh các đối tượng ZZ0000ZZ và ZZ0001ZZ để tận dụng lợi thế của loại
  kiểm tra để đảm bảo sử dụng đúng.

- Phải chọn một callsite trong mã hệ thống tập tin thông thường để gọi
  ZZ0000ZZ với mã hành động và cấu trúc dữ liệu.
  Địa điểm này phải liền kề (và không sớm hơn) nơi
  bản cập nhật hệ thống tập tin được cam kết cho giao dịch.
  Nói chung, khi hệ thống tập tin gọi một chuỗi móc, nó có thể
  xử lý chế độ ngủ và không dễ bị thu hồi hoặc khóa bộ nhớ
  đệ quy.
  Tuy nhiên, các yêu cầu chính xác phụ thuộc rất nhiều vào ngữ cảnh của hook
  người gọi và người được gọi.

- Hàm fsck trực tuyến cần xác định cấu trúc để chứa dữ liệu quét, khóa
  để phối hợp truy cập vào dữ liệu quét và đối tượng ZZ0000ZZ.
  Chức năng quét và mã hệ thống tập tin thông thường phải lấy tài nguyên
  theo cùng một thứ tự; xem phần tiếp theo để biết chi tiết.

- Code fsck online phải chứa hàm C mới bắt được code hook action
  và cấu trúc dữ liệu.
  Nếu đối tượng đang được cập nhật đã được quét, thì
  thông tin hook phải được áp dụng cho dữ liệu quét.

- Trước khi unlock inodes để bắt đầu quét, fsck online phải gọi
  ZZ0000ZZ để khởi tạo ZZ0001ZZ và
  ZZ0002ZZ để kích hoạt hook.

- fsck trực tuyến phải gọi ZZ0000ZZ để vô hiệu hóa hook sau khi quét xong
  hoàn thành.

Số lượng móc nên được giữ ở mức tối thiểu để giảm độ phức tạp.
Các khóa tĩnh được sử dụng để giảm chi phí hoạt động của các hook hệ thống tập tin xuống gần như
bằng 0 khi fsck trực tuyến không chạy.

.. _liveupdate:

Cập nhật trực tiếp trong quá trình quét
``````````````````````````

Đường dẫn mã của mã quét fsck trực tuyến và ZZ0000ZZ
mã hệ thống tập tin trông như thế này ::

chương trình khác
                  ↓
            khóa inode ←────────────────────┐
                  ↓ │
            Khóa tiêu đề AG │
                  ↓ │
            chức năng hệ thống tập tin │
                  ↓ │
            chuỗi cuộc gọi thông báo │ tương tự
                  ↓ ├─── nút
            chức năng chà móc │ khóa
                  ↓ │
            quét dữ liệu mutex ←──┐ giống nhau │
                  ↓ ├─── quét │
            cập nhật dữ liệu quét │ khóa │
                  ↑ │ │
            quét dữ liệu mutex ←──┘ │
                  ↑ │
            khóa inode ←────────────────────┘
                  ↑
            chức năng chà
                  ↑
            máy quét inode
                  ↑
            xfs_scrub

Những quy tắc này phải được tuân theo để đảm bảo sự tương tác chính xác giữa
kiểm tra mã và mã thực hiện cập nhật cho hệ thống tập tin:

- Trước khi gọi chuỗi lệnh gọi trình thông báo, chức năng hệ thống tập tin sẽ được
  được nối phải có cùng khóa mà chức năng quét chà có được
  để quét inode.

- Chức năng quét và chức năng chà móc phải phối hợp truy cập vào
  dữ liệu quét bằng cách lấy khóa dữ liệu quét.

- Chức năng chà móc không được thêm thông tin cập nhật trực tiếp vào quá trình quét
  quan sát trừ khi inode đang được cập nhật đã được quét.
  Điều phối viên quét có một vị từ trợ giúp (ZZ0000ZZ)
  vì điều này.

- Chức năng Scrub hook không được thay đổi trạng thái của người gọi, kể cả trạng thái
  giao dịch mà nó đang chạy.
  Họ không được lấy bất kỳ tài nguyên nào có thể xung đột với hệ thống tập tin
  chức năng đang được nối.

- Hàm hook có thể hủy bỏ quá trình quét inode để tránh vi phạm các quy tắc khác.

API quét inode khá đơn giản:

- ZZ0000ZZ bắt đầu quét

- ZZ0000ZZ lấy tham chiếu đến nút tiếp theo trong quá trình quét hoặc
  trả về 0 nếu không còn gì để quét

- ZZ0000ZZ để quyết định xem một nút đã được cài đặt chưa
  đã truy cập trong quá trình quét.
  Điều này rất quan trọng để các hàm hook quyết định xem chúng có cần cập nhật
  thông tin quét trong bộ nhớ.

- ZZ0000ZZ để đánh dấu một inode đã được truy cập trong
  quét

- ZZ0000ZZ để kết thúc quá trình quét

.. _quotacheck:

Nghiên cứu điển hình: Kiểm tra bộ đếm hạn ngạch
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Sẽ rất hữu ích khi so sánh mã kiểm tra hạn ngạch thời gian gắn kết với mã sửa chữa trực tuyến
mã kiểm tra hạn ngạch.
Kiểm tra hạn ngạch thời gian gắn kết không phải đối mặt với các hoạt động đồng thời, vì vậy
nó thực hiện như sau:

1. Đảm bảo các dquot trên đĩa ở trạng thái đủ tốt để tất cả các lõi trong
   dquots sẽ thực sự tải và không có bộ đếm mức sử dụng tài nguyên trong
   bộ đệm ondisk.

2. Đi qua từng nút trong hệ thống tập tin.
   Thêm mức sử dụng tài nguyên của mỗi tệp vào incore dquot.

3. Đi bộ từng điểm số.
   Nếu incore dquot không bị xóa, hãy thêm bộ đệm ondisk sao lưu
   incore dquot vào danh sách ghi chậm (delwri).

4. Ghi danh sách bộ đệm vào đĩa.

Giống như hầu hết các chức năng fsck trực tuyến, hạn ngạch trực tuyến không thể ghi vào thông thường
đối tượng hệ thống tệp cho đến khi siêu dữ liệu mới được thu thập phản ánh tất cả hệ thống tệp
trạng thái.
Do đó, việc kiểm tra hạn ngạch trực tuyến sẽ ghi lại việc sử dụng tài nguyên tệp vào một vùng tối
chỉ mục được triển khai với ZZ0000ZZ thưa thớt và chỉ ghi vào các dấu ngoặc kép thực
khi quá trình quét hoàn tất.
Việc xử lý các cập nhật giao dịch rất khó khăn vì các cập nhật sử dụng tài nguyên hạn ngạch
được xử lý theo từng giai đoạn để giảm thiểu tranh chấp về dquots:

1. Các nút liên quan được nối và khóa trong một giao dịch.

2. Đối với mỗi dquot đính kèm file:

Một. Dquot đã bị khóa.

b. Việc đặt trước hạn ngạch được thêm vào việc sử dụng tài nguyên của dquot.
      Việc đặt chỗ được ghi lại trong giao dịch.

c. Dquot đã được mở khóa.

3. Những thay đổi trong việc sử dụng hạn ngạch thực tế sẽ được theo dõi trong giao dịch.

4. Tại thời điểm cam kết giao dịch, mỗi dquot được kiểm tra lại:

Một. Dquot lại bị khóa.

b. Những thay đổi về mức sử dụng hạn ngạch được ghi lại và phần đặt chỗ chưa sử dụng sẽ được trả lại cho
      dquot.

c. Dquot đã được mở khóa.

Để kiểm tra hạn ngạch trực tuyến, các móc được đặt ở bước 2 và 4.
Móc bước 2 tạo phiên bản bóng của bối cảnh giao dịch dquot
(ZZ0000ZZ) hoạt động theo cách tương tự như mã thông thường.
Móc bước 4 cam kết bóng ZZ0001ZZ thay đổi thành bóng dquots.
Lưu ý rằng cả hai hook đều được gọi với inode bị khóa, đó là cách
tọa độ cập nhật trực tiếp với máy quét inode.

Quá trình quét kiểm tra hạn ngạch trông như thế này:

1. Thiết lập quét inode phối hợp.

2. Đối với mỗi inode được trả về bởi trình vòng lặp quét inode:

Một. Lấy và khóa inode.

b. Xác định mức sử dụng tài nguyên của inode đó (khối dữ liệu, số lượng inode,
      khối thời gian thực) và thêm nó vào phần bóng tối cho người dùng, nhóm,
      và id dự án được liên kết với inode.

c. Mở khóa và giải phóng inode.

3. Đối với mỗi dquot trong hệ thống:

Một. Lấy và khóa dquot.

b. Kiểm tra dquot với các dquot bóng được tạo bởi quá trình quét và cập nhật
      bởi các móc trực tiếp.

Cập nhật trực tiếp là chìa khóa để có thể vượt qua mọi kỷ lục hạn ngạch mà không cần
cần phải giữ bất kỳ ổ khóa nào trong thời gian dài.
Nếu muốn sửa chữa, các dquot thực và bóng sẽ bị khóa và chúng
số lượng tài nguyên được đặt thành các giá trị trong bóng dquot.

.. _nlinks:

Nghiên cứu điển hình: Kiểm tra số lượng liên kết tệp
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Kiểm tra số lượng liên kết tệp cũng sử dụng móc cập nhật trực tiếp.
Máy quét inode phối hợp được sử dụng để truy cập tất cả các thư mục trên
hệ thống tệp và bản ghi số lượng liên kết trên mỗi tệp được lưu trữ trong ZZ0000ZZ thưa thớt
được lập chỉ mục bởi inumber.
Trong giai đoạn quét, mỗi mục trong thư mục tạo ra sự quan sát
dữ liệu như sau:

1. Nếu mục nhập là mục nhập dấu chấm (ZZ0000ZZ) của thư mục gốc,
   số lượng liên kết gốc của thư mục bị lỗi do dấu chấm của thư mục gốc
   mục nhập là tự tham khảo.

2. Nếu mục nhập là mục nhập dấu chấm của thư mục con, thì phản hồi ngược của thư mục gốc
   số lượng bị va chạm.

3. Nếu mục nhập không phải là mục nhập dấu chấm hay dấu chấm, thì mục gốc của tệp đích
   số lượng bị va chạm.

4. Nếu mục tiêu là thư mục con, số lượng liên kết con của cha mẹ sẽ bị tăng lên.

Một điểm quan trọng để hiểu về cách tương tác của trình quét inode đếm liên kết
với các móc cập nhật trực tiếp là con trỏ quét sẽ theo dõi ZZ0001ZZ
thư mục đã được quét.
Nói cách khác, các bản cập nhật trực tiếp sẽ bỏ qua mọi cập nhật về ZZ0000ZZ khi A có
chưa được quét, ngay cả khi B đã được quét.
Hơn nữa, thư mục con A có mục nhập dấu chấm trỏ ngược lại B là
được tính như một bộ đếm ngược trong dữ liệu bóng cho A, vì dotdot con
các mục ảnh hưởng đến số lượng liên kết của cha mẹ.
Các móc cập nhật trực tiếp được đặt cẩn thận trong tất cả các phần của hệ thống tập tin
tạo, thay đổi hoặc xóa các mục trong thư mục vì các thao tác đó liên quan đến
liên kết nhỏ và liên kết nhỏ.

Đối với bất kỳ tệp nào, số lượng liên kết chính xác là số lượng cha mẹ cộng với số lượng
của các thư mục con.
Các thư mục không bao giờ có bất kỳ loại con nào.
Thông tin backref được sử dụng để phát hiện sự không nhất quán về số lượng
liên kết trỏ đến thư mục con và số lượng mục nhập dấu chấm
chỉ lại.

Sau khi quét xong, số lượng liên kết của mỗi tệp có thể được kiểm tra bằng cách khóa
cả dữ liệu inode và dữ liệu bóng và so sánh số lượng liên kết.
Con trỏ quét inode phối hợp thứ hai được sử dụng để so sánh.
Cập nhật trực tiếp là chìa khóa để có thể di chuyển mọi inode mà không cần giữ
bất kỳ khóa nào giữa các nút.
Nếu muốn sửa chữa, số lượng liên kết của inode được đặt thành giá trị trong
thông tin bóng tối.
Nếu không tìm thấy cha, tệp phải là ZZ0000ZZ cho
trại trẻ mồ côi để tránh việc tập tin bị mất vĩnh viễn.

.. _rmap_repair:

Nghiên cứu điển hình: Xây dựng lại các bản ghi ánh xạ ngược
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Hầu hết các chức năng sửa chữa đều tuân theo cùng một mẫu: khóa tài nguyên hệ thống tập tin,
kiểm tra siêu dữ liệu trên đĩa còn sót lại để tìm bản ghi siêu dữ liệu thay thế,
và sử dụng ZZ0000ZZ để lưu trữ các quan sát đã thu thập được.
Ưu điểm chính của phương pháp này là tính đơn giản và tính mô-đun của
mã sửa chữa -- mã và dữ liệu hoàn toàn được chứa trong mô-đun chà,
không yêu cầu hook trong hệ thống tập tin chính và thường hiệu quả nhất
trong việc sử dụng bộ nhớ.
Ưu điểm phụ của phương pháp sửa chữa này là tính nguyên tử -- một khi hạt nhân
quyết định cấu trúc bị hỏng, không có luồng nào khác có thể truy cập siêu dữ liệu cho đến khi
kernel hoàn tất việc sửa chữa và xác nhận lại siêu dữ liệu.

Để sửa chữa diễn ra trong một phân đoạn của hệ thống tập tin, những ưu điểm này
lớn hơn sự chậm trễ vốn có trong việc khóa mảnh vỡ trong khi sửa chữa các bộ phận của
mảnh vỡ.
Thật không may, việc sửa chữa btree ánh xạ ngược không thể sử dụng "tiêu chuẩn"
Chiến lược sửa chữa btree vì nó phải quét mọi ánh xạ không gian của mọi nhánh của
mọi tệp trong hệ thống tệp và hệ thống tệp không thể dừng lại.
Do đó, rmap repair bỏ qua tính nguyên tử giữa chà và sửa chữa.
Nó kết hợp ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ để hoàn thành
quét các bản ghi ánh xạ ngược.

1. Thiết lập xfbtree để phân loại các bản ghi rmap.

2. Trong khi giữ các khóa trên bộ đệm AGI và AGF có được trong quá trình
   chà, tạo ánh xạ ngược cho tất cả siêu dữ liệu AG: inodes, btrees, CoW
   phạm vi dàn dựng và nhật ký nội bộ.

3. Thiết lập máy quét inode.

4. Kết nối các bản cập nhật rmap cho AG đang được sửa chữa để dữ liệu quét trực tiếp
   có thể nhận các bản cập nhật cho rmap btree từ phần còn lại của hệ thống tập tin trong
   quá trình quét tập tin.

5. Đối với mỗi ánh xạ không gian được tìm thấy ở một trong hai nhánh của mỗi tệp được quét,
   quyết định xem ánh xạ có khớp với AG quan tâm hay không.
   Nếu vậy:

Một. Tạo một con trỏ btree cho btree trong bộ nhớ.

b. Sử dụng mã rmap để thêm bản ghi vào btree trong bộ nhớ.

c. Sử dụng ZZ0000ZZ để viết
      xfbtree thay đổi thành xfile.

6. Đối với mỗi bản cập nhật trực tiếp nhận được qua hook, hãy quyết định xem chủ sở hữu đã
   đã được quét.
   Nếu vậy, hãy áp dụng bản cập nhật trực tiếp vào dữ liệu quét:

Một. Tạo một con trỏ btree cho btree trong bộ nhớ.

b. Phát lại thao tác vào btree trong bộ nhớ.

c. Sử dụng ZZ0000ZZ để viết
      xfbtree thay đổi thành xfile.
      Điều này được thực hiện với một giao dịch trống để tránh thay đổi
      trạng thái của người gọi.

7. Khi quá trình quét inode kết thúc, hãy tạo một giao dịch chà mới và khóa lại
   hai tiêu đề AG.

8. Tính toán hình học btree mới bằng cách sử dụng số lượng bản ghi rmap trong
   Shadow btree, giống như tất cả các chức năng xây dựng lại btree khác.

9. Phân bổ số khối được tính ở bước trước.

10. Thực hiện tải hàng loạt btree thông thường và cam kết cài đặt rmap mới
    btree.

11. Lấy lại các khối btree rmap cũ như đã thảo luận trong nghiên cứu điển hình về cách
    tới ZZ0000ZZ.

12. Giải phóng xfbtree ngay bây giờ khi không cần thiết.

Sửa chữa theo giai đoạn với các tệp tạm thời trên đĩa
--------------------------------------------

XFS lưu trữ một lượng siêu dữ liệu đáng kể trong các nhánh tệp: thư mục,
thuộc tính mở rộng, mục tiêu liên kết tượng trưng, ​​bitmap không gian trống và tóm tắt
thông tin về khối lượng thời gian thực và bản ghi hạn ngạch.
Các nhánh tệp ánh xạ phạm vi không gian phân nhánh tệp logic 64-bit sang không gian lưu trữ vật lý
phạm vi, tương tự như cách đơn vị quản lý bộ nhớ ánh xạ các địa chỉ ảo 64 bit
tới các địa chỉ bộ nhớ vật lý.
Vì vậy, các cấu trúc cây dựa trên tập tin (chẳng hạn như các thư mục và các
thuộc tính) sử dụng các khối được ánh xạ trong không gian địa chỉ offset của nhánh tệp mà điểm đó
tới các khối khác được ánh xạ trong cùng không gian địa chỉ đó và tuyến tính dựa trên tệp
các cấu trúc (chẳng hạn như bitmap và bản ghi hạn ngạch) tính toán độ lệch phần tử mảng trong
không gian địa chỉ offset của nhánh tập tin.

Vì các nhánh tệp có thể tiêu tốn nhiều dung lượng bằng toàn bộ hệ thống tệp, nên việc sửa chữa
không thể được sắp xếp trong bộ nhớ, ngay cả khi có sẵn sơ đồ phân trang.
Do đó, việc sửa chữa trực tuyến siêu dữ liệu dựa trên tệp sẽ tạo ra một tệp tạm thời trong
hệ thống tập tin XFS, ghi một cấu trúc mới ở độ lệch chính xác vào
tập tin tạm thời và trao đổi nguyên tử tất cả các ánh xạ phân nhánh của tập tin (và do đó
nội dung ngã ba) để cam kết sửa chữa.
Sau khi quá trình sửa chữa hoàn tất, chiếc nĩa cũ có thể được thu hồi nếu cần thiết; nếu
hệ thống bị hỏng trong quá trình gặt, mã iunlink sẽ xóa các khối
trong quá trình khôi phục nhật ký.

ZZ0000ZZ: Tất cả các chỉ số sử dụng không gian và inode trong hệ thống tập tin ZZ0001ZZ đều được
nhất quán để sử dụng một tập tin tạm thời một cách an toàn!
Sự phụ thuộc này là lý do tại sao sửa chữa trực tuyến chỉ có thể sử dụng kernel có thể phân trang
bộ nhớ để hiển thị thông tin sử dụng dung lượng trên đĩa.

Việc trao đổi ánh xạ tệp siêu dữ liệu với tệp tạm thời yêu cầu chủ sở hữu
trường của các tiêu đề khối để khớp với tệp đang được sửa chữa chứ không phải tệp
tập tin tạm thời.
Thư mục, thuộc tính mở rộng và các chức năng liên kết tượng trưng đều được
được sửa đổi để cho phép người gọi chỉ định rõ ràng số chủ sở hữu.

Có một nhược điểm trong quá trình thu thập -- nếu hệ thống gặp sự cố trong quá trình
giai đoạn gặt và phạm vi phân nhánh được liên kết chéo, quá trình xử lý iunlink sẽ
thất bại vì việc giải phóng không gian sẽ tìm thấy các ánh xạ ngược bổ sung và hủy bỏ.

Các tệp tạm thời được tạo để sửa chữa tương tự như các tệp ZZ0000ZZ được tạo
theo không gian người dùng.
Chúng không được liên kết vào một thư mục và toàn bộ tập tin sẽ được lấy khi
tham chiếu cuối cùng đến tập tin bị mất.
Điểm khác biệt chính là những tệp này không được phép truy cập bên ngoài
hạt nhân, chúng phải được đánh dấu đặc biệt để tránh bị
được mở bằng tay cầm và chúng không bao giờ được liên kết vào cây thư mục.

+-----------------------------------------------------------------------------------+
ZZ0003ZZ
+-----------------------------------------------------------------------------------+
ZZ0004ZZ
ZZ0005ZZ
ZZ0006ZZ
ZZ0007ZZ
ZZ0008ZZ
ZZ0009ZZ
ZZ0010ZZ
ZZ0011ZZ
ZZ0012ZZ
ZZ0013ZZ
ZZ0014ZZ
ZZ0015ZZ
ZZ0016ZZ
ZZ0017ZZ
ZZ0018ZZ
ZZ0019ZZ
ZZ0020ZZ
ZZ0021ZZ
ZZ0022ZZ
ZZ0023ZZ
ZZ0024ZZ
ZZ0025ZZ
ZZ0026ZZ
ZZ0027ZZ
ZZ0028ZZ
ZZ0029ZZ
ZZ0030ZZ
ZZ0031ZZ
ZZ0032ZZ
ZZ0033ZZ
ZZ0034ZZ
ZZ0035ZZ
ZZ0036ZZ
ZZ0037ZZ
ZZ0038ZZ
ZZ0039ZZ
ZZ0040ZZ
ZZ0041ZZ
ZZ0042ZZ
ZZ0043ZZ
ZZ0044ZZ
ZZ0045ZZ
ZZ0046ZZ
ZZ0047ZZ
ZZ0048ZZ
ZZ0049ZZ
ZZ0050ZZ
ZZ0051ZZ
ZZ0052ZZ
ZZ0053ZZ
ZZ0054ZZ
+-----------------------------------------------------------------------------------+

Sử dụng tệp tạm thời
``````````````````````

Mã sửa chữa trực tuyến nên sử dụng chức năng ZZ0000ZZ để tạo
tập tin tạm thời bên trong hệ thống tập tin.
Việc này cấp phát một inode, đánh dấu inode trong lõi là riêng tư và gắn nó vào
bối cảnh chà.
Các tệp này bị ẩn khỏi không gian người dùng, có thể không được thêm vào cây thư mục,
và phải được giữ kín.

Các tệp tạm thời chỉ sử dụng hai khóa inode: IOLOCK và ILOCK.
MMAPLOCK không cần thiết ở đây vì không được có lỗi trang từ
không gian người dùng cho các khối phân nhánh dữ liệu.
Cách sử dụng của hai khóa này giống như đối với bất kỳ tệp XFS nào khác --
quyền truy cập vào dữ liệu tệp được kiểm soát thông qua IOLOCK và quyền truy cập vào siêu dữ liệu tệp
được điều khiển thông qua ILOCK.
Trình trợ giúp khóa được cung cấp để tệp tạm thời và trạng thái khóa của nó có thể
được làm sạch bởi bối cảnh chà.
Để tuân thủ chiến lược khóa lồng nhau được trình bày trong phần ZZ0000ZZ, các chức năng chà nên sử dụng
xrep_tempfile_ilock*_nowait người trợ giúp khóa.

Dữ liệu có thể được ghi vào một tập tin tạm thời bằng hai cách:

1. ZZ0000ZZ có thể được sử dụng để thiết lập nội dung của một trang thông thường
   tập tin tạm thời từ một xfile.

2. Thư mục thông thường, liên kết tượng trưng và các hàm thuộc tính mở rộng có thể
   được sử dụng để ghi vào tập tin tạm thời.

Khi một bản sao tốt của tệp dữ liệu đã được tạo trong một tệp tạm thời, nó
phải được chuyển đến tập tin đang được sửa chữa, đó là chủ đề của phần tiếp theo
phần.

Trao đổi nội dung tệp đã ghi
-----------------------------

Sau khi sửa chữa sẽ tạo một tệp tạm thời với cấu trúc dữ liệu mới được ghi vào
nó, nó phải chuyển những thay đổi mới vào tập tin hiện có.
Không thể hoán đổi inumbers của hai tệp, thay vào đó, tệp mới
siêu dữ liệu phải thay thế cái cũ.
Điều này cho thấy nhu cầu về khả năng hoán đổi phạm vi, nhưng phạm vi hiện có
việc hoán đổi mã được sử dụng bởi công cụ chống phân mảnh tệp ZZ0000ZZ là không đủ
để sửa chữa trực tuyến vì:

Một. Khi bật btree ánh xạ ngược, mã hoán đổi phải giữ nguyên
   thông tin ánh xạ ngược được cập nhật với mỗi lần trao đổi ánh xạ.
   Do đó, nó chỉ có thể trao đổi một ánh xạ cho mỗi giao dịch và mỗi
   giao dịch là độc lập.

b. Ánh xạ ngược rất quan trọng đối với hoạt động của fsck trực tuyến, do đó, cách cũ
   mã chống phân mảnh (đã hoán đổi toàn bộ các nhánh của phạm vi trong một
   hoạt động) không hữu ích ở đây.

c. Việc chống phân mảnh được cho là xảy ra giữa hai tập tin có cùng
   nội dung.
   Đối với trường hợp sử dụng này, việc trao đổi không đầy đủ sẽ không dẫn đến kết quả hiển thị cho người dùng
   thay đổi nội dung tập tin, ngay cả khi hoạt động bị gián đoạn.

d. Sửa chữa trực tuyến cần trao đổi nội dung của hai tệp theo định nghĩa
   ZZ0000ZZ giống hệt nhau.
   Để sửa chữa thư mục và xattr, nội dung mà người dùng nhìn thấy có thể là
   giống nhau nhưng nội dung của từng khối có thể rất khác nhau.

đ. Các khối cũ trong file có thể được liên kết chéo với cấu trúc khác và phải
   không xuất hiện lại nếu hệ thống ngừng hoạt động giữa quá trình sửa chữa.

Những vấn đề này được khắc phục bằng cách tạo một hoạt động trì hoãn mới và một kiểu mới
mục mục đích nhật ký để theo dõi tiến trình của một thao tác trao đổi hai tệp
phạm vi.
Loại hoạt động trao đổi mới xâu chuỗi các giao dịch giống nhau được sử dụng bởi
mã hoán đổi phạm vi ánh xạ ngược, nhưng ghi lại tiến trình trung gian trong
log để các hoạt động có thể được khởi động lại sau sự cố.
Chức năng mới này được gọi là trao đổi nội dung tệp (xfs_exchrange)
mã.
Ánh xạ nhánh tệp trao đổi triển khai cơ bản (xfs_exchmaps).
Mục nhật ký mới ghi lại tiến trình trao đổi để đảm bảo rằng một khi
trao đổi bắt đầu, nó sẽ luôn chạy đến khi hoàn thành, thậm chí có
sự gián đoạn.
Cờ tính năng không tương thích ZZ0000ZZ mới
trong siêu khối bảo vệ các bản ghi mục nhật ký mới này khỏi bị phát lại trên
hạt nhân cũ.

+-----------------------------------------------------------------------------------+
ZZ0005ZZ
+-----------------------------------------------------------------------------------+
ZZ0006ZZ
ZZ0007ZZ
ZZ0008ZZ
ZZ0009ZZ
ZZ0010ZZ
ZZ0011ZZ
ZZ0012ZZ
ZZ0013ZZ
ZZ0014ZZ
ZZ0015ZZ
ZZ0016ZZ
ZZ0017ZZ
ZZ0018ZZ
ZZ0019ZZ
ZZ0020ZZ
ZZ0021ZZ
ZZ0022ZZ
ZZ0023ZZ
ZZ0024ZZ
ZZ0025ZZ
ZZ0026ZZ
ZZ0027ZZ
ZZ0028ZZ
ZZ0029ZZ
ZZ0030ZZ
ZZ0031ZZ
ZZ0032ZZ
ZZ0033ZZ
ZZ0034ZZ
ZZ0035ZZ
ZZ0036ZZ
ZZ0037ZZ
ZZ0038ZZ
ZZ0039ZZ
ZZ0040ZZ
ZZ0041ZZ
ZZ0042ZZ
+-----------------------------------------------------------------------------------+

Cơ chế trao đổi nội dung tệp đã ghi
```````````````````````````````````````````

Trao đổi nội dung giữa các nhánh tập tin là một nhiệm vụ phức tạp.
Mục tiêu là trao đổi tất cả các ánh xạ rẽ nhánh tệp giữa hai nhánh rẽ nhánh tệp
phạm vi.
Có thể có nhiều ánh xạ phạm vi trong mỗi nhánh và các cạnh của
các ánh xạ không nhất thiết phải được căn chỉnh.
Hơn nữa, có thể có những cập nhật khác cần diễn ra sau khi trao đổi,
chẳng hạn như trao đổi kích thước tệp, cờ inode hoặc chuyển đổi dữ liệu nhánh sang cục bộ
định dạng.
Đây gần như là định dạng của mục công việc ánh xạ trao đổi bị trì hoãn mới:

.. code-block:: c

	struct xfs_exchmaps_intent {
	    /* Inodes participating in the operation. */
	    struct xfs_inode    *xmi_ip1;
	    struct xfs_inode    *xmi_ip2;

	    /* File offset range information. */
	    xfs_fileoff_t       xmi_startoff1;
	    xfs_fileoff_t       xmi_startoff2;
	    xfs_filblks_t       xmi_blockcount;

	    /* Set these file sizes after the operation, unless negative. */
	    xfs_fsize_t         xmi_isize1;
	    xfs_fsize_t         xmi_isize2;

	    /* XFS_EXCHMAPS_* log operation flags */
	    uint64_t            xmi_flags;
	};

Mục mục đích nhật ký mới chứa đủ thông tin để theo dõi hai nhánh logic
phạm vi bù: ZZ0000ZZ và ZZ0001ZZ.
Mỗi bước của hoạt động trao đổi trao đổi ánh xạ phạm vi tệp lớn nhất
có thể từ tập tin này sang tập tin khác.
Sau mỗi bước trong hoạt động trao đổi, hai trường bắt đầu được
tăng lên và trường đếm khối giảm đi để phản ánh tiến trình
thực hiện.
Trường cờ ghi lại các tham số hành vi như trao đổi ngã ba attr
ánh xạ thay vì phân nhánh dữ liệu và các công việc khác sẽ được thực hiện sau khi trao đổi.
Hai trường isize được sử dụng để trao đổi kích thước tệp ở cuối
hoạt động nếu nhánh dữ liệu tệp là mục tiêu của hoạt động.

Khi việc trao đổi được bắt đầu, trình tự các hoạt động như sau:

1. Tạo một mục công việc bị trì hoãn để trao đổi ánh xạ tệp.
   Khi bắt đầu, nó phải chứa toàn bộ phạm vi khối tệp cần được
   trao đổi.

2. Gọi ZZ0000ZZ để xử lý trao đổi.
   Điều này được gói gọn trong ZZ0001ZZ cho các hoạt động chà.
   Điều này sẽ ghi lại một mục mục đích hoán đổi phạm vi cho giao dịch cho khoản trả chậm
   mục công việc trao đổi ánh xạ.

3. Cho đến khi ZZ0000ZZ của mục công việc trao đổi ánh xạ hoãn lại bằng 0,

Một. Đọc bản đồ khối của cả hai phạm vi tệp bắt đầu từ ZZ0000ZZ và
      ZZ0001ZZ tương ứng và tính toán phạm vi dài nhất có thể
      được trao đổi trong một bước duy nhất.
      Đây là mức tối thiểu trong số hai ZZ0002ZZ trong ánh xạ.
      Tiếp tục tiến qua các nhánh tệp cho đến khi có ít nhất một trong các ánh xạ
      chứa các khối viết.
      Các lỗ hổng lẫn nhau, phạm vi không được viết và ánh xạ phạm vi tới cùng một phạm vi vật lý
      không gian không được trao đổi.

Đối với một số bước tiếp theo, tài liệu này sẽ đề cập đến ánh xạ đi kèm
      từ tệp 1 là "map1" và ánh xạ đến từ tệp 2 là "map2".

b. Tạo bản cập nhật ánh xạ khối bị trì hoãn để hủy ánh xạ map1 khỏi tệp 1.

c. Tạo bản cập nhật ánh xạ khối bị trì hoãn để hủy ánh xạ map2 khỏi tệp 2.

d. Tạo bản cập nhật ánh xạ khối trì hoãn để ánh xạ map1 vào tệp 2.

đ. Tạo bản cập nhật ánh xạ khối bị trì hoãn để ánh xạ map2 vào tệp 1.

f. Ghi lại các cập nhật về khối, hạn ngạch và số lượng phạm vi cho cả hai tệp.

g. Mở rộng kích thước ondisk của một trong hai tệp nếu cần.

h. Ghi nhật ký mục nhật ký trao đổi ánh xạ được thực hiện cho nhật ký mục đích trao đổi ánh xạ
      mục đã được đọc ở đầu bước 3.

Tôi. Tính toán số lượng phạm vi tập tin vừa được bao phủ.
      Số lượng này là ZZ0000ZZ, vì bước 3a có thể bỏ qua các lỗ.

j. Tăng độ lệch ban đầu của ZZ0000ZZ và ZZ0001ZZ
      theo số khối được tính ở bước trước và giảm dần
      ZZ0002ZZ với số lượng tương tự.
      Điều này thúc đẩy con trỏ.

k. Ghi nhật ký mục nhật ký mục đích trao đổi ánh xạ mới phản ánh trạng thái nâng cao
      của hạng mục công việc.

tôi. Trả lại mã lỗi thích hợp (EAGAIN) cho người quản lý hoạt động trì hoãn
      để thông báo rằng còn nhiều việc phải làm.
      Người quản lý vận hành hoàn thành công việc bị trì hoãn ở bước 3b-3e trước
      quay trở lại điểm bắt đầu của bước 3.

4. Thực hiện bất kỳ quá trình xử lý hậu kỳ nào.
   Điều này sẽ được thảo luận chi tiết hơn trong các phần tiếp theo.

Nếu hệ thống tập tin gặp sự cố khi đang thực hiện thao tác, việc khôi phục nhật ký sẽ
tìm mục mục đích nhật ký trao đổi ánh xạ chưa hoàn thành gần đây nhất và khởi động lại
từ đó.
Đây là cách trao đổi ánh xạ tệp nguyên tử đảm bảo rằng người quan sát bên ngoài
sẽ nhìn thấy cấu trúc cũ bị hỏng hoặc cấu trúc mới và không bao giờ có sự xáo trộn của
cả hai.

Chuẩn bị cho việc trao đổi nội dung tệp
``````````````````````````````````````

Có một số điều cần phải được quan tâm trước khi bắt đầu một
hoạt động trao đổi ánh xạ tập tin nguyên tử.
Đầu tiên, các tập tin thông thường yêu cầu bộ đệm trang phải được xóa vào đĩa trước khi
hoạt động bắt đầu và lệnh ghi được dừng lại.
Giống như bất kỳ hoạt động hệ thống tập tin nào, việc trao đổi ánh xạ tập tin phải xác định
dung lượng ổ đĩa và hạn ngạch tối đa có thể được sử dụng thay mặt cho cả hai
các tập tin trong hoạt động và dự trữ số lượng tài nguyên đó để tránh
lỗi hết dung lượng không thể phục hồi được khi nó bắt đầu làm hỏng siêu dữ liệu.
Bước chuẩn bị quét phạm vi của cả hai tệp để ước tính:

- Khối thiết bị dữ liệu cần thiết để xử lý các bản cập nhật lặp lại cho nhánh
  ánh xạ.
- Thay đổi dữ liệu và số khối thời gian thực cho cả hai tệp.
- Tăng mức sử dụng hạn ngạch cho cả hai tệp, nếu hai tệp không chia sẻ
  cùng một bộ id hạn ngạch.
- Số lượng ánh xạ phạm vi sẽ được thêm vào mỗi tệp.
- Có hay không có phạm vi thời gian thực được viết một phần.
  Các chương trình người dùng không bao giờ được phép truy cập vào phạm vi tệp thời gian thực ánh xạ
  ở các mức độ khác nhau về khối lượng thời gian thực, điều này có thể xảy ra nếu
  hoạt động không thể chạy đến khi hoàn thành.

Nhu cầu ước tính chính xác làm tăng thời gian thực hiện trao đổi
hoạt động, nhưng điều rất quan trọng là phải duy trì việc hạch toán chính xác.
Hệ thống tập tin không được hết dung lượng trống và ánh xạ cũng không được
Exchange luôn thêm nhiều ánh xạ phạm vi vào một nhánh hơn mức nó có thể hỗ trợ.
Người dùng thông thường được yêu cầu tuân theo giới hạn hạn ngạch, mặc dù việc sửa chữa siêu dữ liệu
có thể vượt quá hạn ngạch để giải quyết siêu dữ liệu không nhất quán ở nơi khác.

Các tính năng đặc biệt để trao đổi nội dung tệp siêu dữ liệu
``````````````````````````````````````````````````````

Các thuộc tính mở rộng, liên kết tượng trưng và thư mục có thể đặt định dạng nhánh thành
"cục bộ" và coi phân nhánh như một khu vực theo nghĩa đen để lưu trữ dữ liệu.
Việc sửa chữa siêu dữ liệu phải thực hiện các bước bổ sung để hỗ trợ những trường hợp này:

- Nếu cả hai nhánh đều ở định dạng cục bộ và vùng nhánh đủ lớn,
  trao đổi được thực hiện bằng cách sao chép nội dung nhánh incore, ghi lại cả hai
  nĩa và cam kết.
  Cơ chế trao đổi ánh xạ tập tin nguyên tử là không cần thiết, vì điều này có thể
  được thực hiện chỉ với một giao dịch.

- Nếu cả hai nhánh ánh xạ các khối thì việc trao đổi ánh xạ tệp nguyên tử thông thường sẽ diễn ra
  đã sử dụng.

- Nếu không, chỉ có một nhánh ở định dạng cục bộ.
  Nội dung của nhánh định dạng cục bộ được chuyển đổi thành một khối để thực hiện
  trao đổi.
  Việc chuyển đổi sang định dạng khối phải được thực hiện trong cùng một giao dịch
  ghi lại mục nhật ký mục đích trao đổi ánh xạ ban đầu.
  Trao đổi ánh xạ nguyên tử thông thường được sử dụng để trao đổi tệp siêu dữ liệu
  ánh xạ.
  Các cờ đặc biệt được đặt trong hoạt động trao đổi để giao dịch có thể
  được cuộn lại một lần nữa để chuyển nhánh của tệp thứ hai trở lại cục bộ
  định dạng để tệp thứ hai sẵn sàng hoạt động ngay khi ILOCK được cài đặt
  bị rơi.

Các thuộc tính và thư mục mở rộng đóng dấu inode sở hữu vào mỗi khối,
nhưng trình xác minh bộ đệm không thực sự kiểm tra số inode!
Mặc dù không có xác minh nhưng điều quan trọng là phải duy trì
tính toàn vẹn tham chiếu, vì vậy trước khi thực hiện trao đổi ánh xạ, hãy trực tuyến
sửa chữa xây dựng mọi khối trong cấu trúc dữ liệu mới với trường chủ sở hữu của
tập tin đang được sửa chữa.

Sau khi thao tác đổi trả thành công, thao tác sửa chữa phải gặt lại
khối ngã ba bằng cách xử lý từng ánh xạ nhánh thông qua cơ chế ZZ0000ZZ tiêu chuẩn được thực hiện sau sửa chữa.
Nếu hệ thống tập tin bị hỏng trong quá trình sửa chữa,
Quá trình xử lý iunlink khi kết thúc quá trình khôi phục sẽ giải phóng cả tệp tạm thời và
bất cứ khối nào không được gặt hái.
Tuy nhiên, quá trình xử lý iunlink này bỏ qua việc phát hiện liên kết chéo của trực tuyến.
sửa chữa và không hoàn toàn có thể khắc phục được.

Trao đổi nội dung tệp tạm thời
``````````````````````````````````

Để sửa chữa tệp siêu dữ liệu, sửa chữa trực tuyến tiến hành như sau:

1. Tạo một tập tin sửa chữa tạm thời.

2. Sử dụng dữ liệu dàn dựng để ghi nội dung mới vào bản sửa chữa tạm thời
   tập tin.
   Cái ngã ba tương tự phải được ghi là đang được sửa chữa.

3. Cam kết giao dịch chà, kể từ bước ước tính tài nguyên trao đổi
   phải được hoàn thành trước khi thực hiện đặt chỗ giao dịch.

4. Gọi ZZ0000ZZ để phân bổ một giao dịch chà mới với
   đặt trước tài nguyên thích hợp, khóa và điền vào ZZ0001ZZ các chi tiết về hoạt động trao đổi.

5. Gọi ZZ0000ZZ để trao đổi nội dung.

6. Cam kết giao dịch hoàn tất việc sửa chữa.

.. _rtsummary:

Nghiên cứu điển hình: Sửa tệp tóm tắt thời gian thực
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Trong phần "thời gian thực" của hệ thống tệp XFS, dung lượng trống được theo dõi thông qua
bitmap, tương tự như Unix FFS.
Mỗi bit trong bitmap đại diện cho một phạm vi thời gian thực, là bội số của
kích thước khối hệ thống tập tin có kích thước từ 4KiB đến 1GiB.
Tệp tóm tắt thời gian thực lập chỉ mục số lượng phạm vi miễn phí của một kích thước nhất định cho
phần bù của khối trong bitmap không gian trống thời gian thực nơi những khối đó miễn phí
phạm vi bắt đầu.
Nói cách khác, tệp tóm tắt giúp người cấp phát tìm thấy các phạm vi trống bằng cách
chiều dài, tương tự như không gian trống theo số lượng (cntbt) btree dành cho dữ liệu
phần.

Bản thân tệp tóm tắt là một tệp phẳng (không có tiêu đề khối hoặc tổng kiểm tra!)
được phân vùng thành các phần ZZ0000ZZ chứa đủ 32-bit
bộ đếm để khớp với số khối trong bitmap rt.
Mỗi bộ đếm ghi lại số lượng phạm vi miễn phí bắt đầu trong khối bitmap đó
và có thể đáp ứng yêu cầu phân bổ lũy thừa hai.

Để kiểm tra tệp tóm tắt dựa trên bitmap:

1. Lấy ILOCK của cả tệp bitmap và tệp tóm tắt thời gian thực.

2. Đối với mỗi phạm vi không gian trống được ghi trong bitmap:

Một. Tính toán vị trí trong tệp tóm tắt có chứa bộ đếm
      đại diện cho mức độ tự do này.

b. Đọc bộ đếm từ xfile.

c. Tăng nó lên và ghi lại vào xfile.

3. So sánh nội dung của tệp xfile với tệp ondisk.

Để sửa tệp tóm tắt, hãy ghi nội dung xfile vào tệp tạm thời
và sử dụng trao đổi ánh xạ nguyên tử để cam kết nội dung mới.
Các tập tin tạm thời sau đó được thu thập.

Nghiên cứu điển hình: Tận dụng các thuộc tính mở rộng
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Trong XFS, các thuộc tính mở rộng được triển khai dưới dạng kho lưu trữ tên-giá trị được đặt tên.
Các giá trị được giới hạn về kích thước ở mức 64KiB, nhưng không có giới hạn về số lượng
những cái tên.
Phân nhánh thuộc tính không được phân vùng, có nghĩa là gốc của thuộc tính
cấu trúc luôn ở khối logic 0, nhưng các khối lá thuộc tính, dabtree
khối chỉ mục và khối giá trị từ xa được trộn lẫn với nhau.
Các khối lá thuộc tính chứa các bản ghi có kích thước thay đổi liên kết
tên do người dùng cung cấp với các giá trị do người dùng cung cấp.
Các giá trị lớn hơn một khối được phân bổ các phạm vi riêng biệt và được ghi ở đó.
Nếu thông tin lá mở rộng ra ngoài một khối duy nhất, một thư mục/thuộc tính
btree (ZZ0000ZZ) được tạo để ánh xạ giá trị băm của tên thuộc tính vào các mục
để tra cứu nhanh.

Việc cứu các thuộc tính mở rộng được thực hiện như sau:

1. Đi qua ánh xạ ngã ba attr của tệp đang được sửa chữa để tìm thuộc tính
   khối lá.
   Khi một người được tìm thấy,

Một. Đi qua khối lá attr để tìm khóa ứng viên.
      Khi một người được tìm thấy,

1. Kiểm tra tên xem có vấn đề không và bỏ qua tên nếu có.

2. Truy xuất giá trị.
         Nếu thành công, hãy thêm tên và giá trị vào dàn xfarray và
         xfblob.

2. Nếu mức sử dụng bộ nhớ của xfarray và xfblob vượt quá một lượng nhất định
   bộ nhớ hoặc không còn khối attr fork nào để kiểm tra, mở khóa tệp và
   thêm các thuộc tính mở rộng theo giai đoạn vào tệp tạm thời.

3. Sử dụng trao đổi ánh xạ tệp nguyên tử để trao đổi phần mở rộng mới và cũ
   các cấu trúc thuộc tính.
   Các khối thuộc tính cũ hiện được gắn vào tệp tạm thời.

4. Lấy lại tập tin tạm thời.

Sửa thư mục
------------------

Việc sửa các thư mục rất khó khăn với các tính năng hệ thống tập tin hiện có,
vì các mục trong thư mục không dư thừa.
Công cụ sửa chữa ngoại tuyến quét tất cả các nút để tìm các tệp có số lượng liên kết khác 0,
và sau đó nó quét tất cả các thư mục để thiết lập nguồn gốc của các tệp được liên kết đó.
Các tập tin và thư mục bị hỏng sẽ bị cắt và các tập tin không có cha mẹ sẽ bị loại bỏ.
đã chuyển đến thư mục ZZ0000ZZ.
Nó không cố gắng cứu vãn bất cứ điều gì.

Điều tốt nhất mà sửa chữa trực tuyến có thể làm lúc này là đọc dữ liệu thư mục
chặn và cứu bất kỳ hướng dẫn nào có vẻ hợp lý, số lượng liên kết chính xác và
di chuyển trẻ mồ côi trở lại cây thư mục.
Quá trình cứu vãn được thảo luận trong nghiên cứu trường hợp ở cuối phần này.
Mã ZZ0000ZZ đảm nhiệm việc sửa số lượng liên kết
và di chuyển trẻ mồ côi vào thư mục ZZ0001ZZ.

Nghiên cứu điển hình: Thư mục trục vớt
`````````````````````````````````

Không giống như các thuộc tính mở rộng, các khối thư mục đều có cùng kích thước, do đó
việc cứu hộ các thư mục rất đơn giản:

1. Tìm thư mục gốc.
   Nếu mục nhập dấu chấm không thể đọc được, hãy thử xác nhận rằng mục bị cáo buộc
   cha mẹ có một mục con trỏ lại thư mục đang được sửa chữa.
   Nếu không, hãy đi bộ trong hệ thống tập tin để tìm nó.

2. Đi qua phân vùng dữ liệu đầu tiên của thư mục để tìm thư mục
   khối dữ liệu đầu vào.
   Khi một người được tìm thấy,

Một. Đi qua khối dữ liệu thư mục để tìm các mục ứng cử viên.
      Khi một mục được tìm thấy:

Tôi. Kiểm tra tên xem có vấn đề không và bỏ qua tên nếu có.

ii. Lấy inumber và lấy inode.
          Nếu thành công, hãy thêm tên, số inode và loại tệp vào
          dàn dựng xfarray và xblob.

3. Nếu mức sử dụng bộ nhớ của xfarray và xfblob vượt quá một lượng nhất định
   bộ nhớ hoặc không còn khối dữ liệu thư mục nào để kiểm tra, mở khóa
   thư mục và thêm các hướng dẫn theo giai đoạn vào thư mục tạm thời.
   Cắt bớt các tập tin dàn dựng.

4. Sử dụng trao đổi ánh xạ tệp nguyên tử để trao đổi thư mục mới và cũ
   các cấu trúc.
   Các khối thư mục cũ hiện được gắn vào tệp tạm thời.

5. Lấy lại tập tin tạm thời.

ZZ0000ZZ: Nên sửa chữa xác nhận lại bộ nhớ đệm của nha khoa khi
xây dựng lại một thư mục?

ZZ0000ZZ: Đúng vậy.

Về lý thuyết, cần phải quét tất cả các mục trong bộ nhớ đệm của nha khoa để tìm một thư mục
đảm bảo rằng một trong những điều sau đây được áp dụng:

1. Nha khoa được lưu trong bộ nhớ đệm phản ánh một thư mục ondisk trong thư mục mới.

2. Nha khoa được lưu trong bộ nhớ đệm không còn có thư mục ondisk tương ứng trong phiên bản mới
   thư mục và nha khoa có thể được xóa khỏi bộ đệm.

3. Nha khoa được lưu trong bộ nhớ đệm không còn có dirent trên đĩa nhưng không thể lưu trữ nha khoa
   thanh lọc.
   Đây là trường hợp có vấn đề.

Thật không may, thiết kế bộ đệm nha khoa hiện tại không cung cấp phương tiện để đi lại
mỗi nha khoa con của một thư mục cụ thể, điều này khiến đây trở thành một vấn đề khó khăn.
Không có giải pháp nào được biết đến.

Con trỏ gốc
```````````````

Con trỏ gốc là một phần siêu dữ liệu của tệp cho phép người dùng định vị
thư mục mẹ của tập tin mà không cần phải duyệt qua cây thư mục từ
gốc.
Không có chúng, việc xây dựng lại cây thư mục sẽ bị cản trở theo nhiều cách tương tự.
theo cách mà việc thiếu thông tin lập bản đồ không gian ngược trong lịch sử đã từng cản trở
xây dựng lại siêu dữ liệu không gian hệ thống tập tin.
Tuy nhiên, tính năng con trỏ cha giúp xây dựng lại toàn bộ thư mục
có thể.

Con trỏ cha XFS chứa thông tin cần thiết để xác định
mục nhập thư mục tương ứng trong thư mục mẹ.
Nói cách khác, các tập tin con sử dụng các thuộc tính mở rộng để lưu trữ các con trỏ tới
cha mẹ ở dạng ZZ0000ZZ.
Quá trình kiểm tra thư mục có thể được tăng cường để đảm bảo rằng mục tiêu của
mỗi dirent cũng chứa một con trỏ cha trỏ ngược lại dirent.
Tương tự, mỗi con trỏ cha có thể được kiểm tra bằng cách đảm bảo rằng đích của
mỗi con trỏ cha là một thư mục và nó chứa một kết quả khớp trực tiếp
con trỏ cha.
Cả sửa chữa trực tuyến và ngoại tuyến đều có thể sử dụng chiến lược này.

+-----------------------------------------------------------------------------------+
ZZ0006ZZ
+-----------------------------------------------------------------------------------+
ZZ0007ZZ
ZZ0008ZZ
ZZ0009ZZ
ZZ0010ZZ
ZZ0011ZZ
ZZ0012ZZ
ZZ0013ZZ
ZZ0014ZZ
ZZ0015ZZ
ZZ0016ZZ
ZZ0017ZZ
ZZ0018ZZ
ZZ0019ZZ
ZZ0020ZZ
ZZ0021ZZ
ZZ0022ZZ
ZZ0023ZZ
ZZ0024ZZ
ZZ0025ZZ
ZZ0026ZZ
ZZ0027ZZ
ZZ0028ZZ
ZZ0029ZZ
ZZ0030ZZ
ZZ0031ZZ
ZZ0032ZZ
ZZ0033ZZ
ZZ0034ZZ
ZZ0035ZZ
ZZ0036ZZ
ZZ0037ZZ
ZZ0038ZZ
ZZ0039ZZ
ZZ0040ZZ
ZZ0041ZZ
ZZ0042ZZ
ZZ0043ZZ
ZZ0044ZZ
ZZ0045ZZ
ZZ0046ZZ
ZZ0047ZZ
ZZ0048ZZ
ZZ0049ZZ
ZZ0050ZZ
ZZ0051ZZ
ZZ0052ZZ
ZZ0053ZZ
ZZ0054ZZ
ZZ0055ZZ
ZZ0056ZZ
ZZ0057ZZ
ZZ0058ZZ
ZZ0059ZZ
ZZ0060ZZ
ZZ0061ZZ
ZZ0062ZZ
ZZ0063ZZ
ZZ0064ZZ
ZZ0065ZZ
ZZ0066ZZ
ZZ0067ZZ
ZZ0068ZZ
ZZ0069ZZ
ZZ0070ZZ
ZZ0071ZZ
ZZ0072ZZ
ZZ0073ZZ
ZZ0074ZZ
ZZ0075ZZ
ZZ0076ZZ
ZZ0077ZZ
ZZ0078ZZ
ZZ0079ZZ
ZZ0080ZZ
ZZ0081ZZ
ZZ0082ZZ
ZZ0083ZZ
ZZ0084ZZ
ZZ0085ZZ
ZZ0086ZZ
ZZ0087ZZ
ZZ0088ZZ
ZZ0089ZZ
ZZ0090ZZ
ZZ0091ZZ
+-----------------------------------------------------------------------------------+


Nghiên cứu điển hình: Sửa chữa thư mục bằng con trỏ gốc
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Việc xây dựng lại thư mục sử dụng ZZ0000ZZ và
ZZ0001ZZ như sau:

1. Thiết lập thư mục tạm thời để tạo cấu trúc thư mục mới,
   một xfblob để lưu trữ tên mục nhập và một xfarray để lưu trữ các mục đã sửa
   các trường kích thước liên quan đến cập nhật thư mục: ZZ0000ZZ.

2. Thiết lập máy quét inode và móc vào mã mục nhập thư mục để nhận
   cập nhật về hoạt động thư mục.

3. Đối với mỗi con trỏ cha được tìm thấy trong mỗi tệp được quét, hãy quyết định xem con trỏ cha có
   con trỏ tham chiếu thư mục quan tâm.
   Nếu vậy:

Một. Bỏ tên con trỏ cha và mục nhập tên bổ sung cho thư mục này trong
      xfblob và xfarray tương ứng.

b. Khi quét xong tập tin đó hoặc mức tiêu thụ bộ nhớ kernel vượt quá
      một ngưỡng, hãy chuyển các bản cập nhật được lưu trữ vào thư mục tạm thời.

4. Đối với mỗi bản cập nhật thư mục trực tiếp nhận được qua hook, hãy quyết định xem con đó có
   đã được quét rồi.
   Nếu vậy:

Một. Bỏ tên con trỏ cha vào mục nhập tên bổ sung hoặc tên xóa cho mục này
      cập nhật trực tiếp trong xfblob và xfarray sau này.
      Chúng ta không thể ghi trực tiếp vào thư mục tạm thời vì hook
      các chức năng không được phép sửa đổi siêu dữ liệu hệ thống tập tin.
      Thay vào đó, chúng tôi lưu trữ các bản cập nhật trong xfarray và dựa vào chuỗi máy quét
      để áp dụng các bản cập nhật được lưu trữ vào thư mục tạm thời.

5. Khi quá trình quét hoàn tất, hãy phát lại mọi mục được lưu trữ trong xfarray.

6. Khi quá trình quét hoàn tất, hãy trao đổi nguyên tử nội dung của tệp tạm thời
   thư mục và thư mục đang được sửa chữa.
   Thư mục tạm thời hiện chứa cấu trúc thư mục bị hỏng.

7. Lấy lại thư mục tạm thời.

Nghiên cứu điển hình: Sửa chữa con trỏ gốc
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Việc xây dựng lại trực tuyến thông tin con trỏ cha của tệp hoạt động tương tự như
xây dựng lại thư mục:

1. Thiết lập tệp tạm thời để tạo cấu trúc thuộc tính mở rộng mới,
   một xfblob để lưu trữ tên con trỏ cha và một xfarray để lưu trữ
   các trường có kích thước cố định liên quan đến cập nhật con trỏ gốc: ZZ0000ZZ.

2. Thiết lập máy quét inode và móc vào mã mục nhập thư mục để nhận
   cập nhật về hoạt động thư mục.

3. Đối với mỗi mục nhập thư mục được tìm thấy trong mỗi thư mục được quét, hãy quyết định xem
   tham chiếu trực tiếp đến tập tin quan tâm.
   Nếu vậy:

Một. Bỏ tên trực tiếp và mục addpptr cho con trỏ cha này trong
      xfblob và xfarray tương ứng.

b. Khi quét xong thư mục hoặc kernel tiêu tốn bộ nhớ
      vượt quá ngưỡng, hãy chuyển các bản cập nhật được lưu vào tệp tạm thời.

4. Đối với mỗi bản cập nhật thư mục trực tiếp nhận được qua hook, hãy quyết định xem thư mục gốc có
   đã được quét rồi.
   Nếu vậy:

Một. Bỏ tên dirent và mục addpptr hoặc Removepptr cho dirent này
      cập nhật trong xfblob và xfarray sau này.
      Chúng ta không thể ghi con trỏ cha trực tiếp vào tệp tạm thời vì
      chức năng hook không được phép sửa đổi siêu dữ liệu hệ thống tập tin.
      Thay vào đó, chúng tôi lưu trữ các bản cập nhật trong xfarray và dựa vào chuỗi máy quét
      để áp dụng các bản cập nhật con trỏ gốc được lưu trữ vào tệp tạm thời.

5. Khi quá trình quét hoàn tất, hãy phát lại mọi mục được lưu trữ trong xfarray.

6. Sao chép tất cả các thuộc tính mở rộng của con trỏ không phải cha mẹ vào tệp tạm thời.

7. Khi quá trình quét hoàn tất, trao đổi nguyên tử ánh xạ của thuộc tính
   các nhánh của tệp tạm thời và tệp đang được sửa chữa.
   Tệp tạm thời hiện chứa cấu trúc thuộc tính mở rộng bị hỏng.

8. Gặt lại tập tin tạm thời.

Lạc đề: Kiểm tra ngoại tuyến các con trỏ gốc
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Kiểm tra con trỏ gốc trong sửa chữa ngoại tuyến hoạt động khác vì bị hỏng
các tập tin sẽ bị xóa rất lâu trước khi việc kiểm tra kết nối cây thư mục được thực hiện.
Do đó, kiểm tra con trỏ gốc là bước thứ hai được thêm vào
kiểm tra kết nối:

1. Sau khi thiết lập xong tập tin còn sót lại (giai đoạn 6),
   duyệt các thư mục còn sót lại của mỗi AG trong hệ thống tập tin.
   Điều này đã được thực hiện như một phần của quá trình kiểm tra kết nối.

2. Đối với mỗi mục thư mục được tìm thấy,

Một. Nếu tên đã được lưu trong xfblob thì hãy sử dụng cookie đó
      và bỏ qua bước tiếp theo.

b. Nếu không, hãy ghi tên vào xfblob và ghi nhớ cookie xfblob.
      Ánh xạ duy nhất là rất quan trọng đối với

1. Loại bỏ tên trùng lặp để giảm mức sử dụng bộ nhớ và

2. Tạo một khóa sắp xếp ổn định cho các chỉ mục con trỏ cha để
         Xác thực con trỏ gốc được mô tả bên dưới sẽ hoạt động.

c. Lưu trữ các bộ dữ liệu ZZ0000ZZ trong một tấm trong bộ nhớ cho mỗi AG.  ZZ0001ZZ
      được tham chiếu trong phần này là hàm băm tên mục nhập thư mục thông thường, không phải
      cái chuyên dụng được sử dụng cho xattrs con trỏ cha.

3. Đối với mỗi AG trong hệ thống tập tin,

Một. Sắp xếp bộ tuple trên mỗi AG theo thứ tự ZZ0000ZZ, ZZ0001ZZ,
      ZZ0002ZZ và ZZ0003ZZ.
      Việc có một ZZ0004ZZ duy nhất cho mỗi ZZ0005ZZ là rất quan trọng đối với
      xử lý trường hợp không phổ biến của một thư mục chứa nhiều liên kết cứng
      vào cùng một tệp trong đó tất cả các tên được băm có cùng giá trị.

b. Đối với mỗi nút trong AG,

1. Quét inode để tìm con trỏ cha.
         Đối với mỗi con trỏ cha được tìm thấy,

Một. Xác thực con trỏ cha ondisk.
            Nếu việc xác thực không thành công, hãy chuyển sang con trỏ cha tiếp theo trong
            tập tin.

b. Nếu tên đã được lưu trong xfblob thì hãy sử dụng tên đó
            cookie và bỏ qua bước tiếp theo.

c. Ghi lại tên trong xfblob cho mỗi tệp và ghi nhớ xfblob
            bánh quy.

d. Lưu trữ các bộ dữ liệu ZZ0000ZZ trong một bản cho mỗi tệp.

2. Sắp xếp các bộ dữ liệu trên mỗi tệp theo thứ tự ZZ0000ZZ, ZZ0001ZZ,
         và ZZ0002ZZ.

3. Đặt một con trỏ phiến ở đầu bản ghi của inode trong
         tấm tuple trên mỗi AG.
         Điều này không đáng kể vì các bộ dữ liệu trên mỗi AG nằm ở inumber con
         đặt hàng.

4. Định vị con trỏ bản thứ hai ở đầu bản bản tuple cho mỗi tệp.

5. Lặp lại hai con trỏ theo bước khóa, so sánh ZZ0000ZZ,
         Các trường ZZ0001ZZ và ZZ0002ZZ của các bản ghi trong mỗi trường
         con trỏ:

Một. Nếu con trỏ trên mỗi AG ở điểm thấp hơn trong vùng phím so với điểm
            con trỏ trên mỗi tệp, sau đó con trỏ trên mỗi AG trỏ đến cha mẹ bị thiếu
            con trỏ.
            Thêm con trỏ cha vào nút và nâng cao mỗi AG
            con trỏ.

b. Nếu con trỏ trên mỗi tệp ở điểm thấp hơn trong không gian khóa so với
            con trỏ trên mỗi AG, sau đó con trỏ trên mỗi tệp sẽ trỏ đến một điểm treo lơ lửng
            con trỏ cha.
            Xóa con trỏ cha khỏi nút và nâng cao mỗi tệp
            con trỏ.

c. Ngược lại, cả hai con trỏ đều trỏ đến cùng một con trỏ cha.
            Cập nhật thành phần parent_gen nếu cần.
            Tiến lên cả hai con trỏ.

4. Chuyển sang kiểm tra số lượng liên kết, như chúng ta làm hôm nay.

Việc xây dựng lại các thư mục từ con trỏ gốc trong quá trình sửa chữa ngoại tuyến sẽ rất khó khăn.
đầy thách thức vì xfs_repair hiện sử dụng hai lần quét một lượt của
hệ thống tập tin trong giai đoạn 3 và 4 để quyết định tập tin nào bị hỏng đến mức
bị hạ gục.
Quá trình quét này sẽ phải được chuyển đổi thành quét nhiều lần:

1. Lần quét đầu tiên sẽ loại bỏ các nút, nhánh và thuộc tính bị hỏng
   nhiều như bây giờ.
   Các thư mục bị hỏng sẽ được ghi lại nhưng không bị loại bỏ.

2. Pass tiếp theo ghi lại con trỏ cha trỏ tới thư mục đã ghi chú
   như bị hỏng trong lần vượt qua đầu tiên.
   Việc vượt qua thứ hai này có thể phải diễn ra sau quá trình quét bản sao ở giai đoạn 4
   khối, nếu giai đoạn 4 cũng có khả năng hạ gục các thư mục.

3. Bước thứ ba đặt lại các thư mục bị hỏng thành một thư mục dạng ngắn trống.
   Siêu dữ liệu dung lượng trống chưa được đảm bảo nên việc sửa chữa chưa thể sử dụng
   mã xây dựng thư mục trong libxfs.

4. Khi bắt đầu Giai đoạn 6, siêu dữ liệu không gian đã được xây dựng lại.
   Sử dụng thông tin con trỏ cha được ghi lại trong bước 2 để xây dựng lại
   các dirents và thêm chúng vào các thư mục hiện trống.

Mã này chưa được xây dựng.

.. _dirtree:

Nghiên cứu điển hình: Cấu trúc cây thư mục
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Như đã đề cập trước đó, cây thư mục hệ thống tập tin được cho là một
Cấu trúc đồ thị acylic có hướng
Tuy nhiên, mỗi nút trong biểu đồ này là một đối tượng ZZ0000ZZ riêng biệt với
khóa riêng, điều này làm cho việc xác nhận chất lượng của cây trở nên khó khăn.
May mắn thay, các thư mục không được phép có nhiều cha và không thể
có con nên chỉ cần quét thư mục.
Các thư mục thường chiếm 5-10% số tệp trong hệ thống tệp,
làm giảm đáng kể khối lượng công việc.

Nếu cây thư mục có thể bị đóng băng thì sẽ dễ dàng phát hiện ra các chu trình và
các vùng bị ngắt kết nối bằng cách chạy theo chiều sâu (hoặc chiều rộng) trước tiên hãy tìm kiếm xuống dưới
từ thư mục gốc và đánh dấu một bitmap cho mỗi thư mục được tìm thấy.
Tại bất kỳ thời điểm nào trong quá trình đi bộ, việc cố gắng thiết lập một bit đã được thiết lập có nghĩa là có một
chu kỳ.
Sau khi quá trình quét hoàn tất, XOR bitmap inode được đánh dấu bằng inode
bitmap phân bổ cho thấy các nút bị ngắt kết nối.
Tuy nhiên, một trong những mục tiêu thiết kế của sửa chữa trực tuyến là tránh khóa toàn bộ
hệ thống tập tin trừ khi nó thực sự cần thiết.
Cập nhật cây thư mục có thể di chuyển các cây con qua mặt sóng máy quét một cách trực tiếp
hệ thống tập tin, do đó thuật toán bitmap không thể được áp dụng.

Các con trỏ thư mục gốc cho phép một cách tiếp cận gia tăng để xác nhận hợp lệ của
cấu trúc cây.
Thay vì sử dụng một luồng để quét toàn bộ hệ thống tập tin, nhiều luồng có thể
đi bộ từ các thư mục con riêng lẻ trở lên thư mục gốc.
Để làm việc này, tất cả các mục nhập thư mục và con trỏ cha phải ở bên trong
nhất quán, mỗi mục trong thư mục phải có một con trỏ cha và liên kết
số lượng tất cả các thư mục phải chính xác.
Mỗi luồng máy quét phải có khả năng lấy IOLOCK của cha mẹ bị cáo buộc
thư mục trong khi giữ IOLOCK của thư mục con để ngăn chặn
thư mục khỏi bị di chuyển trong cây.
Điều này là không thể vì VFS không lấy IOLOCK của một đứa trẻ
thư mục con khi di chuyển thư mục con đó, vì vậy thay vào đó máy quét sẽ ổn định
mối quan hệ cha mẹ -> con bằng cách lấy ILOCK và cài đặt dirent
hook cập nhật để phát hiện các thay đổi.

Quá trình quét sử dụng một hook trực tiếp để phát hiện các thay đổi đối với các thư mục
được đề cập trong dữ liệu quét.
Quá trình quét hoạt động như sau:

1. Đối với mỗi thư mục con trong hệ thống tập tin,

Một. Đối với mỗi con trỏ cha của thư mục con đó,

1. Tạo một đối tượng đường dẫn cho con trỏ cha đó và đánh dấu
         số inode thư mục con trong bitmap của đối tượng đường dẫn.

2. Ghi lại tên con trỏ cha và số inode trong cấu trúc đường dẫn.

3. Nếu thư mục mẹ bị cáo buộc là thư mục con đang bị xóa, đường dẫn là
         một chu kỳ.
         Đánh dấu đường dẫn để xóa và lặp lại bước 1a với bước tiếp theo
         con trỏ cha của thư mục con.

4. Cố gắng đánh dấu số inode gốc được cho là bằng bitmap trong đường dẫn
         đối tượng.
         Nếu bit đã được đặt thì sẽ có một chu trình trong thư mục
         cây.
         Đánh dấu đường dẫn là một chu trình và lặp lại bước 1a với thư mục con tiếp theo
         con trỏ cha.

5. Tải phụ huynh bị cáo buộc.
         Nếu thư mục gốc bị cáo buộc không phải là thư mục được liên kết, hãy hủy quá trình quét
         vì thông tin con trỏ cha không nhất quán.

6. Đối với mỗi con trỏ cha của thư mục tổ tiên được cho là này,

Một. Ghi lại tên con trỏ cha và số inode trong đối tượng đường dẫn
            nếu không có cha mẹ nào được đặt ở cấp độ đó.

b. Nếu tổ tiên có nhiều hơn một cha mẹ, hãy đánh dấu đường dẫn là bị hỏng.
            Lặp lại bước 1a với con trỏ thư mục con tiếp theo.

c. Lặp lại các bước 1a3-1a6 cho tổ tiên được xác định ở bước 1a6a.
            Điều này lặp lại cho đến khi đạt đến gốc cây thư mục hoặc không có cha mẹ
            được tìm thấy.

7. Nếu quá trình đi bộ kết thúc ở thư mục gốc, hãy đánh dấu đường dẫn là ok.

8. Nếu cuộc đi bộ kết thúc mà không đến được điểm gốc, hãy đánh dấu đường đi là
         bị ngắt kết nối.

2. Nếu hook cập nhật mục nhập thư mục kích hoạt, hãy kiểm tra tất cả các đường dẫn đã được tìm thấy
   bằng cách quét.
   Nếu mục nhập khớp với một phần của đường dẫn, hãy đánh dấu đường dẫn đó và bản quét cũ.
   Khi luồng quét thấy rằng quá trình quét đã được đánh dấu là cũ, nó sẽ xóa
   tất cả dữ liệu quét và bắt đầu lại.

Sửa chữa cây thư mục hoạt động như sau:

1. Đi từng đường dẫn của thư mục con đích.

Một. Đường dẫn bị hỏng và đường dành cho xe đạp được tính là đáng ngờ.

b. Đường dẫn đã được đánh dấu để xóa được tính là xấu.

c. Đường dẫn đến gốc được tính là tốt.

2. Nếu thư mục con là thư mục gốc hoặc không có số lượng liên kết,
   xóa tất cả các mục nhập thư mục đến trong thư mục gốc ngay lập tức.
   Việc sửa chữa đã hoàn tất.

3. Nếu thư mục con có chính xác một đường dẫn, hãy đặt mục nhập dấu chấm thành
   cha mẹ và thoát ra.

4. Nếu thư mục con có ít nhất một đường dẫn tốt, hãy xóa tất cả các đường dẫn còn lại
   các mục thư mục đến trong cha mẹ trực tiếp.

5. Nếu thư mục con không có đường dẫn tốt và có nhiều đường dẫn nghi ngờ, hãy xóa
   tất cả các mục thư mục đến khác trong thư mục cha trực tiếp.

6. Nếu thư mục con không có đường dẫn, hãy đính kèm nó vào thư mục bị mất và tìm thấy.

.. _orphanage:

trại trẻ mồ côi
-------------

Các hệ thống tập tin trình bày các tập tin dưới dạng biểu đồ được định hướng và hy vọng là không theo chu kỳ.
Nói cách khác, một cái cây.
Thư mục gốc của hệ thống tập tin là một thư mục và mỗi mục trong thư mục trỏ tới
xuống nhiều thư mục con hơn hoặc các tệp không có thư mục.
Thật không may, sự gián đoạn trong các con trỏ biểu đồ thư mục dẫn đến một
biểu đồ bị ngắt kết nối, khiến các tệp không thể truy cập được qua đường dẫn thông thường
độ phân giải.

Nếu không có con trỏ cha, mã chà trực tuyến của con trỏ cha có thể
phát hiện mục nhập dấu chấm trỏ đến thư mục mẹ không có liên kết
quay lại thư mục con và trình kiểm tra số lượng liên kết tệp có thể phát hiện một tệp
không được trỏ đến bởi bất kỳ thư mục nào trong hệ thống tập tin.
Nếu một tệp như vậy có số lượng liên kết dương thì tệp đó là tệp mồ côi.

Với con trỏ cha, các thư mục có thể được xây dựng lại bằng cách quét con trỏ cha
và con trỏ cha có thể được xây dựng lại bằng cách quét các thư mục.
Điều này sẽ làm giảm tỷ lệ tệp kết thúc bằng ZZ0000ZZ.

Khi tìm thấy trẻ mồ côi, chúng sẽ được kết nối lại với cây thư mục.
fsck ngoại tuyến giải quyết vấn đề bằng cách tạo thư mục ZZ0000ZZ để
phục vụ như một trại trẻ mồ côi và liên kết các tập tin mồ côi vào trại trẻ mồ côi bằng cách sử dụng
inumber như tên gọi.
Việc cấp lại tập tin vào trại trẻ mồ côi không đặt lại bất kỳ quyền nào của nó hoặc
ACL.

Quá trình này liên quan nhiều đến kernel hơn là trong không gian người dùng.
Các chức năng thiết lập sửa chữa số lượng liên kết thư mục và tập tin phải sử dụng thông thường
VFS có cơ chế tạo thư mục trại trẻ mồ côi với tất cả các tính năng cần thiết
thuộc tính bảo mật và mục nhập bộ nhớ đệm của nha khoa, giống như một thư mục thông thường
sửa đổi cây.

Các tập tin mồ côi được trại trẻ mồ côi thông qua như sau:

1. Gọi ZZ0000ZZ khi bắt đầu chức năng thiết lập chà
   để cố gắng đảm bảo rằng thư mục bị mất và tìm thấy thực sự tồn tại.
   Điều này cũng gắn thư mục trại trẻ mồ côi vào bối cảnh chà.

2. Nếu quyết định kết nối lại một tập tin, hãy lấy IOLOCK của cả hai
   trại trẻ mồ côi và tập tin đang được đính kèm lại.
   Hàm ZZ0000ZZ tuân theo khóa inode
   chiến lược đã thảo luận trước đó.

3. Sử dụng ZZ0000ZZ để dự trữ tài nguyên cho việc sửa chữa
   giao dịch.

4. Gọi ZZ0000ZZ để tính tên mới trong
   trại trẻ mồ côi.

5. Nếu việc nhận con nuôi sắp diễn ra, hãy gọi ZZ0000ZZ để
   sắp xếp lại tập tin mồ côi vào tập tin bị mất và tìm thấy và vô hiệu hóa nha khoa
   bộ đệm.

6. Gọi ZZ0000ZZ để xác nhận mọi cập nhật hệ thống tập tin, phát hành
   trại trẻ mồ côi ILOCK và làm sạch giao dịch chà.  Gọi
   ZZ0001ZZ để cam kết cập nhật và giao dịch chà.

7. Nếu xảy ra lỗi thời gian chạy, hãy gọi ZZ0000ZZ để giải phóng tất cả
   tài nguyên.

6. Thuật toán không gian người dùng và cấu trúc dữ liệu
===========================================

Phần này thảo luận về các thuật toán chính và cấu trúc dữ liệu của không gian người dùng
chương trình ZZ0000ZZ, cung cấp khả năng kiểm tra siêu dữ liệu và
sửa chữa trong kernel, xác minh dữ liệu tệp và tìm kiếm các sự cố tiềm ẩn khác.

.. _scrubcheck:

Kiểm tra siêu dữ liệu
-----------------

Nhớ lại ZZ0000ZZ đã nêu trước đó.
Cấu trúc đó tuân theo một cách tự nhiên từ các phụ thuộc dữ liệu được thiết kế trong
hệ thống tập tin từ khi bắt đầu vào năm 1993.
Trong XFS, có một số nhóm phụ thuộc siêu dữ liệu:

Một. Số lượng tóm tắt của hệ thống tập tin phụ thuộc vào tính nhất quán trong các chỉ mục inode,
   btrees không gian nhóm phân bổ và không gian khối lượng thời gian thực
   thông tin.

b. Số lượng tài nguyên hạn ngạch phụ thuộc vào tính nhất quán trong dữ liệu tệp hạn ngạch
   các nhánh, chỉ mục inode, bản ghi inode và các nhánh của mọi tệp trên
   hệ thống.

c. Hệ thống phân cấp đặt tên phụ thuộc vào tính nhất quán trong thư mục và
   cấu trúc thuộc tính mở rộng.
   Điều này bao gồm số lượng liên kết tập tin.

d. Thư mục, thuộc tính mở rộng và dữ liệu tệp phụ thuộc vào tính nhất quán trong
   tập tin phân nhánh thư mục ánh xạ và dữ liệu thuộc tính mở rộng sang vật lý
   phương tiện lưu trữ.

đ. Việc phân nhánh tệp phụ thuộc vào tính nhất quán trong các bản ghi inode và khoảng trống
   chỉ số siêu dữ liệu của các nhóm phân bổ và khối lượng thời gian thực.
   Điều này bao gồm các tệp siêu dữ liệu hạn ngạch và thời gian thực.

f. Bản ghi inode phụ thuộc vào tính nhất quán trong các chỉ mục siêu dữ liệu inode.

g. Siêu dữ liệu không gian thời gian thực phụ thuộc vào các bản ghi inode và các nhánh dữ liệu của
   inode siêu dữ liệu thời gian thực.

h. Các chỉ số siêu dữ liệu của nhóm phân bổ (không gian trống, nút, số tham chiếu,
   và btree ánh xạ ngược) phụ thuộc vào tính nhất quán trong các tiêu đề AG và
   giữa tất cả các cây siêu dữ liệu AG.

Tôi. ZZ0000ZZ phụ thuộc vào hệ thống tập tin được gắn kết và hỗ trợ kernel
   cho chức năng fsck trực tuyến.

Do đó, biểu đồ phụ thuộc siêu dữ liệu là một cách thuận tiện để lên lịch kiểm tra
hoạt động trong chương trình ZZ0000ZZ:

- Giai đoạn 1 kiểm tra xem đường dẫn được cung cấp có ánh xạ tới hệ thống tệp XFS không và phát hiện
  khả năng lọc của hạt nhân, xác nhận nhóm (i).

- Giai đoạn 2 loại bỏ các nhóm (g) và (h) song song bằng cách sử dụng một chuỗi công việc theo luồng.

- Giai đoạn 3 quét song song các inode.
  Đối với mỗi inode, các nhóm (f), (e) và (d) được kiểm tra theo thứ tự đó.

- Giai đoạn 4 sửa chữa mọi thứ theo nhóm (i) đến (d) sao cho giai đoạn 5 và 6
  có thể chạy đáng tin cậy.

- Giai đoạn 5 bắt đầu bằng việc kiểm tra song song các nhóm (b) và (c) trước khi tiếp tục
  để kiểm tra tên.

- Giai đoạn 6 phụ thuộc vào các nhóm (i) đến (b) tìm các khối dữ liệu file để xác minh,
  để đọc chúng và báo cáo khối nào của tệp nào bị ảnh hưởng.

- Nhóm kiểm tra Giai đoạn 7 (a), đã xác nhận mọi thứ khác.

Lưu ý rằng sự phụ thuộc dữ liệu giữa các nhóm được thực thi bởi cấu trúc
của dòng chảy chương trình.

Quét Inode song song
--------------------

Hệ thống tệp XFS có thể dễ dàng chứa hàng trăm triệu nút.
Vì XFS nhắm mục tiêu cài đặt với bộ lưu trữ hiệu suất cao lớn,
nên thực hiện song song các nút để giảm thiểu thời gian chạy, đặc biệt là
nếu chương trình được gọi thủ công từ dòng lệnh.
Điều này đòi hỏi phải lập kế hoạch cẩn thận để giữ cho các luồng được tải đồng đều như
có thể.

Những phiên bản đầu tiên của máy quét inode ZZ0000ZZ đã ngây thơ tạo ra một
hàng công việc và lên lịch một mục hàng công việc cho mỗi AG.
Mỗi mục trong hàng công việc đều đi qua cây inode (với ZZ0001ZZ) để tìm
các đoạn inode rồi gọi là Bulkstat (ZZ0002ZZ) để tập hợp đủ
thông tin để xây dựng các xử lý tập tin.
Sau đó, phần xử lý tệp được chuyển đến một hàm để tạo các mục xóa cho mỗi
đối tượng siêu dữ liệu của mỗi inode.
Thuật toán đơn giản này dẫn đến vấn đề cân bằng luồng trong giai đoạn 3 nếu
hệ thống tập tin chứa một AG với một vài tập tin thưa thớt lớn và phần còn lại của
AG chứa nhiều tệp nhỏ hơn.
Chức năng điều phối quét inode không đủ chi tiết; nó nên có
được gửi ở cấp độ các nút riêng lẻ hoặc để hạn chế bộ nhớ
tiêu thụ, hồ sơ btree inode.

Nhờ có Dave Chinner, hàng đợi công việc được giới hạn trong không gian người dùng cho phép ZZ0000ZZ
tránh vấn đề này một cách dễ dàng bằng cách thêm hàng đợi công việc thứ hai.
Cũng giống như trước đây, hàng công việc đầu tiên được gieo một mục hàng công việc cho mỗi AG,
và nó sử dụng INUMBERS để tìm các đoạn btree inode.
Tuy nhiên, hàng làm việc thứ hai được cấu hình với giới hạn trên của số
của các mục có thể chờ để được chạy.
Mỗi đoạn cây inode được tìm thấy bởi các công nhân của hàng đợi công việc đầu tiên sẽ được xếp hàng vào
hàng công việc thứ hai và chính hàng công việc thứ hai này truy vấn BULKSTAT,
tạo một trình xử lý tệp và chuyển nó đến một hàm để tạo các mục xóa cho
từng đối tượng siêu dữ liệu của mỗi nút.
Nếu hàng đợi công việc thứ hai quá đầy, chức năng thêm hàng đợi công việc sẽ chặn
công nhân của hàng đợi công việc đầu tiên cho đến khi lượng tồn đọng giảm bớt.
Điều này không hoàn toàn giải quyết được vấn đề cân bằng, nhưng làm giảm nó đủ để
chuyển sang những vấn đề cấp bách hơn.

.. _scrubrepair:

Lên lịch sửa chữa
------------------

Trong giai đoạn 2, các sai sót và sự không nhất quán được báo cáo trong bất kỳ tiêu đề hoặc AGI nào
inode btree được sửa chữa ngay lập tức vì giai đoạn 3 phụ thuộc vào
chức năng của các chỉ số inode để tìm các inode cần quét.
Việc sửa chữa không thành công được dời lại sang giai đoạn 4.
Các vấn đề được báo cáo trong bất kỳ siêu dữ liệu không gian nào khác sẽ được chuyển sang giai đoạn 4.
Các cơ hội tối ưu hóa luôn được hoãn lại sang giai đoạn 4, bất kể chúng có
nguồn gốc.

Trong giai đoạn 3, các sai sót và sự không nhất quán được báo cáo ở bất kỳ phần nào của
siêu dữ liệu của tệp sẽ được sửa chữa ngay lập tức nếu tất cả siêu dữ liệu không gian được xác thực
trong giai đoạn 2.
Những sửa chữa không thành công hoặc không thể sửa chữa ngay lập tức được lên kế hoạch cho giai đoạn 4.

Trong thiết kế ban đầu của ZZ0000ZZ, người ta cho rằng việc sửa chữa sẽ
không thường xuyên đến mức các đối tượng ZZ0001ZZ được sử dụng để
giao tiếp với kernel cũng có thể được sử dụng làm đối tượng chính để
đặt lịch sửa chữa.
Với sự gia tăng gần đây về số lượng tối ưu hóa có thể có cho một
đối tượng hệ thống tập tin, việc theo dõi tất cả các tệp đủ điều kiện sẽ trở nên hiệu quả hơn nhiều về bộ nhớ.
sửa chữa cho một đối tượng hệ thống tập tin nhất định bằng một mục sửa chữa duy nhất.
Mỗi mục sửa chữa đại diện cho một đối tượng có thể khóa -- AG, tệp siêu dữ liệu,
các nút riêng lẻ hoặc một lớp thông tin tóm tắt.

Giai đoạn 4 chịu trách nhiệm lập kế hoạch cho nhiều công việc sửa chữa càng nhanh càng tốt.
cách thực tế nhất.
ZZ0000ZZ được nêu trước đó vẫn được áp dụng,
có nghĩa là ZZ0001ZZ phải cố gắng hoàn thành công việc sửa chữa theo lịch trình
giai đoạn 2 trước khi thử công việc sửa chữa theo kế hoạch ở giai đoạn 3.
Quá trình sửa chữa như sau:

1. Bắt đầu một vòng sửa chữa với hàng công việc và đủ công nhân để giữ CPU
   bận rộn như người dùng mong muốn.

Một. Đối với mỗi hạng mục sửa chữa được xếp hàng ở giai đoạn 2,

Tôi.   Yêu cầu kernel sửa chữa mọi thứ được liệt kê trong mục sửa chữa trong một thời gian
           đối tượng hệ thống tập tin nhất định.

ii.  Ghi lại nếu kernel có bất kỳ tiến bộ nào trong việc giảm số lượng
           sửa chữa cần thiết cho đối tượng này.

iii. Nếu đối tượng không còn cần sửa chữa nữa, hãy xác thực lại tất cả siêu dữ liệu
           liên quan đến đối tượng này.
           Nếu việc xác nhận lại thành công, hãy bỏ vật phẩm sửa chữa.
           Nếu không, hãy yêu cầu xếp hàng để sửa chữa thêm.

b. Nếu có bất kỳ sửa chữa nào được thực hiện, hãy quay lại bước 1a để thử lại tất cả các mục của giai đoạn 2.

c. Đối với mỗi hạng mục sửa chữa được xếp hàng theo giai đoạn 3,

Tôi.   Yêu cầu kernel sửa chữa mọi thứ được liệt kê trong mục sửa chữa trong một thời gian
           đối tượng hệ thống tập tin nhất định.

ii.  Ghi lại nếu kernel có bất kỳ tiến bộ nào trong việc giảm số lượng
           sửa chữa cần thiết cho đối tượng này.

iii. Nếu đối tượng không còn cần sửa chữa nữa, hãy xác thực lại tất cả siêu dữ liệu
           liên quan đến đối tượng này.
           Nếu việc xác nhận lại thành công, hãy bỏ vật phẩm sửa chữa.
           Nếu không, hãy yêu cầu xếp hàng để sửa chữa thêm.

d. Nếu có bất kỳ sửa chữa nào được thực hiện, hãy quay lại 1c để thử lại tất cả các mục của giai đoạn 3.

2. Nếu bước 1 thực hiện bất kỳ tiến trình sửa chữa nào, hãy quay lại bước 1 để bắt đầu
   một đợt sửa chữa khác.

3. Nếu còn những hạng mục cần sửa chữa, hãy chạy tất cả chúng một cách tuần tự thêm một lần nữa.
   Khiếu nại nếu việc sửa chữa không thành công, vì đây là cơ hội cuối cùng
   để sửa chữa bất cứ điều gì.

Các tham nhũng và mâu thuẫn gặp phải trong giai đoạn 5 và 7 được sửa chữa
ngay lập tức.
Các khối dữ liệu tệp bị hỏng được báo cáo ở giai đoạn 6 không thể được phục hồi bằng
hệ thống tập tin.

Kiểm tra tên cho các chuỗi Unicode dễ nhầm lẫn
-----------------------------------------------

Nếu ZZ0000ZZ thành công trong việc xác thực siêu dữ liệu hệ thống tập tin vào cuối
giai đoạn 4, nó chuyển sang giai đoạn 5, kiểm tra những cái tên đáng ngờ trong
hệ thống tập tin.
Những tên này bao gồm nhãn hệ thống tập tin, tên trong các mục thư mục và
tên của các thuộc tính mở rộng.
Giống như hầu hết các hệ thống tập tin Unix, XFS áp đặt các ràng buộc ít nhất đối với
nội dung của một cái tên:

- Không được phép có dấu gạch chéo và byte rỗng trong các mục trong thư mục.

- Các byte rỗng không được phép trong các thuộc tính mở rộng hiển thị trong không gian người dùng.

- Các byte rỗng không được phép trong nhãn hệ thống tập tin.

Các mục thư mục và khóa thuộc tính lưu trữ độ dài của tên một cách rõ ràng
ondisk, có nghĩa là null không phải là dấu kết thúc tên.
Đối với phần này, thuật ngữ "miền đặt tên" đề cập đến bất kỳ nơi nào có tên
được trình bày cùng nhau -- tất cả các tên trong một thư mục hoặc tất cả các thuộc tính của một
tập tin.

Mặc dù các ràng buộc đặt tên Unix rất dễ dãi, nhưng thực tế hầu hết
Các hệ thống Linux hiện đại là các chương trình hoạt động với mã ký tự Unicode
điểm để hỗ trợ các ngôn ngữ quốc tế.
Các chương trình này thường mã hóa các điểm mã đó trong UTF-8 khi giao tiếp
với thư viện C vì kernel mong đợi các tên kết thúc null.
Do đó, trong trường hợp thông thường, các tên được tìm thấy trong hệ thống tệp XFS thực sự là
Dữ liệu Unicode được mã hóa UTF-8.

Để tối đa hóa tính biểu cảm của nó, tiêu chuẩn Unicode xác định các điều khiển riêng biệt
điểm cho các ký tự khác nhau thể hiện tương tự hoặc giống hệt nhau bằng văn bản
các hệ thống trên khắp thế giới.
Ví dụ: ký tự "Chữ nhỏ Cyrillic A" U+0430 "а" thường biểu thị
giống hệt với "Chữ nhỏ La tinh A" U+0061 "a".

Tiêu chuẩn này cũng cho phép các ký tự được xây dựng theo nhiều cách --
bằng cách sử dụng một điểm mã xác định hoặc bằng cách kết hợp một điểm mã với
dấu hiệu kết hợp khác nhau.
Ví dụ: ký tự "Angstrom Sign U+212B "Å" cũng có thể được biểu thị
là "Chữ in hoa Latinh A" U+0041 "A" theo sau là "Kết hợp vòng trên"
U+030A "◌̊".
Cả hai chuỗi đều hiển thị giống hệt nhau.

Giống như các tiêu chuẩn trước đó, Unicode cũng định nghĩa các điều khiển khác nhau
các ký tự để thay đổi cách trình bày của văn bản.
Ví dụ: ký tự "Ghi đè từ phải sang trái" U+202E có thể đánh lừa một số
chương trình hiển thị "moo\\xe2\\x80\\xaegnp.txt" dưới dạng "mootxt.png".
Loại vấn đề hiển thị thứ hai liên quan đến các ký tự khoảng trắng.
Nếu gặp ký tự "Không gian có chiều rộng bằng không" U+200B trong tên tệp, thì
tên sẽ hiển thị giống hệt với tên không có chiều rộng bằng 0
không gian.

Nếu hai tên trong miền đặt tên có chuỗi byte khác nhau nhưng hiển thị
giống hệt nhau, người dùng có thể bị nhầm lẫn bởi nó.
Hạt nhân, không quan tâm đến các sơ đồ mã hóa cấp cao hơn, cho phép điều này.
Hầu hết các trình điều khiển hệ thống tập tin đều duy trì tên chuỗi byte được cấp cho chúng
bởi VFS.

Các kỹ thuật phát hiện tên dễ gây nhầm lẫn được giải thích rất chi tiết trong
phần 4 và 5 của
ZZ0001ZZ
tài liệu.
Khi ZZ0000ZZ phát hiện mã hóa UTF-8 đang được sử dụng trên hệ thống, nó sẽ sử dụng
Dạng chuẩn hóa Unicode NFD kết hợp với tên dễ nhầm lẫn
thành phần phát hiện của
ZZ0002ZZ
để xác định tên bằng một thư mục hoặc trong các thuộc tính mở rộng của tệp
có thể nhầm lẫn với nhau.
Tên cũng được kiểm tra các ký tự điều khiển, ký tự không hiển thị và
trộn lẫn các ký tự hai chiều.
Tất cả các vấn đề tiềm ẩn này đều được báo cáo cho quản trị viên hệ thống trong quá trình
giai đoạn 5.

Xác minh phương tiện của phạm vi dữ liệu tệp
---------------------------------------

Quản trị viên hệ thống có thể chọn bắt đầu quét phương tiện tất cả dữ liệu tệp
khối.
Quá trình quét này sau khi xác thực tất cả siêu dữ liệu hệ thống tập tin (ngoại trừ bản tóm tắt
quầy) như giai đoạn 6.
Quá trình quét bắt đầu bằng cách gọi ZZ0000ZZ để quét bản đồ không gian hệ thống tập tin
để tìm các khu vực được phân bổ cho phạm vi phân nhánh dữ liệu của tệp.
Khoảng cách giữa các phạm vi phân nhánh dữ liệu nhỏ hơn 64k được xử lý như thể
chúng là các nhánh phân nhánh dữ liệu để giảm chi phí thiết lập lệnh.
Khi quá trình quét bản đồ không gian tích lũy một vùng lớn hơn 32MB, phương tiện
yêu cầu xác minh được gửi tới đĩa dưới dạng đọc hướng dẫn của khối thô
thiết bị.

Nếu quá trình đọc xác minh không thành công, ZZ0000ZZ sẽ thử lại với các lần đọc một khối
để thu hẹp lỗi vào khu vực cụ thể của phương tiện và ghi lại.
Khi nó hoàn thành việc đưa ra các yêu cầu xác minh, nó lại sử dụng không gian
ánh xạ ioctl để ánh xạ các lỗi phương tiện đã ghi trở lại cấu trúc siêu dữ liệu
và báo cáo những gì đã mất.
Đối với các lỗi phương tiện trong các khối thuộc sở hữu của tệp, con trỏ cha có thể được sử dụng để
xây dựng đường dẫn tệp từ số inode để báo cáo thân thiện với người dùng.

7. Kết luận và công việc trong tương lai
=============================

Hy vọng rằng người đọc tài liệu này đã làm theo các thiết kế được đưa ra
trong tài liệu này và hiện đã quen với cách XFS hoạt động trực tuyến
xây dựng lại các chỉ mục siêu dữ liệu của nó và cách người dùng hệ thống tập tin có thể tương tác với
chức năng đó.
Mặc dù phạm vi của công việc này còn khó khăn nhưng hy vọng rằng hướng dẫn này sẽ
giúp người đọc mã dễ dàng hiểu được cái gì đã được xây dựng, nó dành cho ai
đã được xây dựng và tại sao.
Vui lòng liên hệ với danh sách gửi thư XFS nếu có thắc mắc.

XFS_IOC_EXCHANGE_RANGE
----------------------

Như đã thảo luận trước đó, giao diện người dùng thứ hai cho trao đổi ánh xạ tệp nguyên tử
cơ chế là một lệnh gọi ioctl mới mà các chương trình không gian người dùng có thể sử dụng để cam kết cập nhật
vào các tập tin một cách nguyên tử.
Giao diện người dùng này đã được đưa ra để xem xét trong vài năm nay, mặc dù
những cải tiến cần thiết để sửa chữa trực tuyến và thiếu nhu cầu của khách hàng có nghĩa là
đề xuất đã không được đẩy mạnh lắm.

Trao đổi nội dung tệp với tệp người dùng thông thường
``````````````````````````````````````````````

Như đã đề cập trước đó, XFS từ lâu đã có khả năng hoán đổi phạm vi giữa
các tập tin, được ZZ0000ZZ hầu như chỉ sử dụng để chống phân mảnh các tập tin.
Hình thức sớm nhất của điều này là cơ chế hoán đổi nhánh, trong đó toàn bộ
nội dung của các nhánh dữ liệu có thể được trao đổi giữa hai tập tin bằng cách trao đổi
byte thô trong khu vực trực tiếp của mỗi ngã ba inode.
Khi XFS v5 xuất hiện cùng với siêu dữ liệu tự mô tả, cơ chế cũ này đã phát triển
một số hỗ trợ nhật ký để tiếp tục ghi lại các trường chủ sở hữu của khối BMBT trong
phục hồi nhật ký.
Khi btree ánh xạ ngược sau đó được thêm vào XFS, cách duy nhất để duy trì
tính nhất quán của ánh xạ ngã ba với chỉ mục ánh xạ ngược là
phát triển một cơ chế lặp sử dụng các hoạt động bmap và rmap trì hoãn để
trao đổi ánh xạ một lần.
Cơ chế này giống hệt với các bước 2-3 của quy trình trên ngoại trừ
các mục theo dõi mới, bởi vì cơ chế trao đổi ánh xạ tệp nguyên tử được
sự lặp lại của một cơ chế hiện có chứ không phải một cái gì đó hoàn toàn mới lạ.
Đối với trường hợp chống phân mảnh tập tin hẹp, nội dung tập tin phải
giống nhau nên lợi ích đảm bảo thu hồi không mang lại nhiều lợi ích.

Trao đổi nội dung tệp nguyên tử linh hoạt hơn nhiều so với swapext hiện có
triển khai vì nó có thể đảm bảo rằng người gọi không bao giờ nhìn thấy sự kết hợp giữa
nội dung cũ và mới ngay cả sau khi gặp sự cố và nó có thể hoạt động trên hai tùy ý
phạm vi ngã ba tập tin.
Tính linh hoạt bổ sung cho phép một số trường hợp sử dụng mới:

- ZZ0001ZZ: Một tiến trình không gian người dùng sẽ mở một tập tin mà nó
  muốn cập nhật.
  Tiếp theo, nó mở một tệp tạm thời và gọi thao tác sao chép tệp để liên kết lại
  nội dung của tệp đầu tiên vào tệp tạm thời.
  Thay vào đó, việc ghi vào tệp gốc nên được ghi vào tệp tạm thời.
  Cuối cùng, quá trình gọi lệnh hệ thống trao đổi ánh xạ tệp nguyên tử
  (ZZ0000ZZ) để trao đổi nội dung tập tin, qua đó
  cam kết tất cả các bản cập nhật cho tệp gốc hoặc không có bản cập nhật nào trong số đó.

.. _exchrange_if_unchanged:

- ZZ0001ZZ: Cơ chế tương tự như trên nhưng người gọi
  chỉ muốn cam kết xảy ra nếu nội dung của tệp gốc không có
  đã thay đổi.
  Để thực hiện điều này, quá trình gọi sẽ chụp nhanh việc sửa đổi tệp và
  thay đổi dấu thời gian của tệp gốc trước khi liên kết lại dữ liệu của nó với
  tập tin tạm thời.
  Khi chương trình đã sẵn sàng thực hiện các thay đổi, nó sẽ chuyển dấu thời gian
  vào kernel làm đối số cho lệnh gọi hệ thống trao đổi ánh xạ tệp nguyên tử.
  Hạt nhân chỉ cam kết các thay đổi nếu dấu thời gian được cung cấp khớp với
  tập tin gốc.
  Một ioctl mới (ZZ0000ZZ) được cung cấp để thực hiện việc này.

- ZZ0000ZZ: Xuất thiết bị khối có
  kích thước khu vực logic phù hợp với kích thước khối hệ thống tập tin để buộc tất cả ghi
  để được căn chỉnh theo kích thước khối hệ thống tập tin.
  Tất cả giai đoạn ghi vào một tệp tạm thời và khi việc đó hoàn tất, hãy gọi
  hệ thống trao đổi ánh xạ tệp nguyên tử gọi bằng cờ để chỉ ra rằng các lỗ hổng
  trong tập tin tạm thời nên được bỏ qua.
  Điều này mô phỏng một thiết bị nguyên tử ghi vào phần mềm và có thể hỗ trợ tùy ý
  viết rải rác.

(Chức năng này đã được sáp nhập vào tuyến chính kể từ năm 2025)

Vector hóa chà
----------------

Hóa ra, ZZ0000ZZ của các hạng mục sửa chữa đã đề cập
trước đó là chất xúc tác để kích hoạt lệnh gọi hệ thống chà được vector hóa.
Kể từ năm 2018, chi phí thực hiện cuộc gọi kernel đã tăng đáng kể trên một số
hệ thống để giảm thiểu tác động của các cuộc tấn công thực thi suy đoán.
Điều này khuyến khích các tác giả chương trình thực hiện càng ít lệnh gọi hệ thống càng tốt để
giảm số lần đường dẫn thực thi đi qua ranh giới bảo mật.

Với vectorized chà, không gian người dùng sẽ đẩy vào kernel danh tính của một
đối tượng hệ thống tập tin, một danh sách các loại chà để chạy đối tượng đó và một
biểu diễn đơn giản về sự phụ thuộc dữ liệu giữa vùng đã chọn
các loại.
Hạt nhân thực thi kế hoạch của người gọi nhiều nhất có thể cho đến khi nó chạm vào
sự phụ thuộc không thể được thỏa mãn do bị hỏng và thông báo cho không gian người dùng
đã hoàn thành được bao nhiêu.
Hy vọng rằng ZZ0000ZZ sẽ có đủ chức năng này để
fsck trực tuyến có thể sử dụng nó thay vì thêm một hệ thống lọc vectơ riêng biệt
gọi tới XFS.

(Chức năng này đã được sáp nhập vào tuyến chính kể từ năm 2025)

Mục tiêu chất lượng dịch vụ của Scrub
------------------------------------

Một thiếu sót nghiêm trọng của mã fsck trực tuyến là lượng thời gian
nó có thể sử dụng trong kernel để giữ các khóa tài nguyên về cơ bản là không bị giới hạn.
Không gian người dùng được phép gửi tín hiệu nghiêm trọng đến quá trình sẽ gây ra
ZZ0000ZZ thoát ra khi đạt đến điểm dừng tốt, nhưng không có cách nào
để không gian người dùng cung cấp quỹ thời gian cho kernel.
Vì cơ sở mã chà có các công cụ trợ giúp để phát hiện các tín hiệu nghiêm trọng, nên không nên
mất quá nhiều công sức để cho phép không gian người dùng chỉ định thời gian chờ cho việc sửa chữa/sửa chữa
hoạt động và hủy bỏ hoạt động nếu nó vượt quá ngân sách.
Tuy nhiên, hầu hết các chức năng sửa chữa đều có đặc tính là khi chúng bắt đầu chạm tới
ondisk siêu dữ liệu, hoạt động không thể bị hủy hoàn toàn, sau đó QoS
thời gian chờ không còn hữu ích nữa.

Chống phân mảnh không gian trống
------------------------

Trong những năm qua, nhiều người dùng XFS đã yêu cầu tạo một chương trình để
xóa một phần bộ nhớ vật lý bên dưới hệ thống tập tin để nó
trở thành một đoạn không gian trống liền kề.
Gọi tắt là công cụ chống phân mảnh không gian trống này là ZZ0000ZZ.

Phần đầu tiên mà chương trình ZZ0000ZZ cần là khả năng đọc
chỉ mục ánh xạ ngược từ không gian người dùng.
Điều này đã tồn tại ở dạng ZZ0001ZZ ioctl.
Phần thứ hai nó cần là một chế độ dự phòng mới
(ZZ0002ZZ) phân bổ không gian trống trong một vùng và
ánh xạ nó vào một tập tin.
Gọi tệp này là tệp "thu thập không gian".
Phần thứ ba là khả năng buộc sửa chữa trực tuyến.

Để xóa tất cả siêu dữ liệu khỏi một phần bộ nhớ vật lý, hãy xóa khoảng trống
sử dụng lệnh gọi fallocate map-freespace mới để ánh xạ bất kỳ không gian trống nào trong khu vực đó
vào tập tin thu thập không gian.
Tiếp theo, Clearspace tìm tất cả các khối siêu dữ liệu trong vùng đó bằng cách
ZZ0000ZZ và đưa ra các yêu cầu sửa chữa bắt buộc trên cấu trúc dữ liệu.
Điều này thường dẫn đến việc siêu dữ liệu được xây dựng lại ở một nơi nào đó không được
đã xóa.
Sau mỗi lần di chuyển, Clearspace gọi lại chức năng "bản đồ không gian trống" để
thu thập bất kỳ không gian mới được giải phóng nào trong khu vực đang bị xóa.

Để xóa tất cả dữ liệu tệp khỏi một phần bộ nhớ vật lý, hãy xóa khoảng trống
sử dụng thông tin FSMAP để tìm các khối dữ liệu tệp có liên quan.
Đã xác định được mục tiêu tốt, nó sử dụng lệnh gọi ZZ0001ZZ ở phần đó
của tệp để cố gắng chia sẻ không gian vật lý với một tệp giả.
Nhân bản phạm vi có nghĩa là chủ sở hữu ban đầu không thể ghi đè lên phạm vi
nội dung; mọi thay đổi sẽ được viết ở nơi khác thông qua tính năng sao chép khi ghi.
Clearspace tạo bản sao của riêng mình về phạm vi bị đóng băng ở một khu vực không được
đã xóa và sử dụng ZZ0002ZZ (hoặc tính năng ZZ0000ZZ) để thay đổi phạm vi dữ liệu của tệp đích
lập bản đồ ra khỏi khu vực đang được giải tỏa.
Khi tất cả các ánh xạ khác đã được di chuyển, khoảng trống sẽ liên kết lại không gian vào
tập tin thu thập không gian để nó không còn khả dụng.

Có những tối ưu hóa hơn nữa có thể áp dụng cho thuật toán trên.
Để xóa một phần lưu trữ vật lý có hệ số chia sẻ cao, đó là
rất mong muốn giữ lại yếu tố chia sẻ này.
Trên thực tế, những phạm vi này nên được di chuyển trước để tối đa hóa hệ số chia sẻ sau.
thao tác hoàn tất.
Để công việc này diễn ra suôn sẻ, Clearspace cần một ioctl mới
(ZZ0000ZZ) để báo cáo thông tin đếm tham chiếu cho không gian người dùng.
Với thông tin hoàn tiền được tiết lộ, Clearspace có thể nhanh chóng tìm thấy thời gian dài nhất,
phạm vi dữ liệu được chia sẻ nhiều nhất trong hệ thống tệp và nhắm mục tiêu chúng trước tiên.

ZZ0000ZZ: Hệ thống tập tin có thể di chuyển các đoạn inode như thế nào?

ZZ0000ZZ: Để di chuyển các khối inode, Dave Chinner đã xây dựng một chương trình nguyên mẫu
tạo một tệp mới với nội dung cũ và sau đó chạy xung quanh một cách không giới hạn
các mục nhập thư mục cập nhật hệ thống tập tin.
Thao tác không thể hoàn tất nếu hệ thống tập tin bị hỏng.
Vấn đề đó không hoàn toàn không thể khắc phục được: tạo bảng ánh xạ lại inode
ẩn đằng sau nhãn nhảy và một mục nhật ký theo dõi kernel di chuyển
hệ thống tập tin để cập nhật các mục thư mục.
Vấn đề là kernel không thể làm gì với các tập tin đang mở vì nó không thể
thu hồi chúng.

ZZ0001ZZ: Có thể sử dụng khóa tĩnh để giảm thiểu chi phí
hỗ trợ ZZ0000ZZ trên các tệp XFS?

ZZ0000ZZ: Vâng.
Cho đến lần thu hồi đầu tiên, mã cứu trợ không cần phải có trong đường dẫn cuộc gọi tại
tất cả.

Các bản vá có liên quan là
ZZ0000ZZ
và
ZZ0001ZZ
loạt.

Thu nhỏ hệ thống tập tin
---------------------

Việc loại bỏ phần cuối của hệ thống tập tin phải là một vấn đề đơn giản như sơ tán
dữ liệu và siêu dữ liệu ở cuối hệ thống tệp và trao không gian trống
vào mã thu nhỏ.
Điều đó đòi hỏi phải sơ tán không gian ở cuối hệ thống tập tin, đây là một
sử dụng tính năng chống phân mảnh không gian trống!