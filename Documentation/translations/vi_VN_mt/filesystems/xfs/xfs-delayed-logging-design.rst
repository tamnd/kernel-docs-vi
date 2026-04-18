.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/xfs/xfs-delayed-logging-design.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================
Thiết kế ghi nhật ký XFS
========================

Lời mở đầu
==========

Tài liệu này mô tả thiết kế và các thuật toán mà XFS ghi nhật ký
hệ thống con dựa trên. Tài liệu này mô tả thiết kế và các thuật toán
dựa trên hệ thống con ghi nhật ký XFS để người đọc có thể làm quen
bản thân họ với các khái niệm chung về cách hoạt động của quá trình xử lý giao dịch trong XFS.

Chúng tôi bắt đầu với tổng quan về các giao dịch trong XFS, sau đó là mô tả cách thức
việc đặt trước giao dịch được cấu trúc và hạch toán, sau đó chuyển sang cách chúng tôi
đảm bảo tiến độ chuyển tiếp cho các giao dịch dài hạn với thời gian ban đầu hữu hạn
giới hạn bảo lưu. Tại thời điểm này, chúng ta cần giải thích cách hoạt động của việc đăng nhập lại. Với
các khái niệm cơ bản được đề cập, việc thiết kế cơ chế ghi nhật ký bị trì hoãn là
được ghi lại.


Giới thiệu
============

XFS sử dụng Ghi nhật ký ghi trước để đảm bảo các thay đổi đối với siêu dữ liệu hệ thống tệp
là nguyên tử và có thể phục hồi được. Vì lý do hiệu quả về không gian và thời gian,
cơ chế ghi nhật ký rất đa dạng và phức tạp, kết hợp các ý định, logic và
cơ chế ghi nhật ký vật lý để cung cấp sự phục hồi cần thiết đảm bảo
hệ thống tập tin yêu cầu.

Một số đối tượng, chẳng hạn như inodes và dquots, được ghi lại ở định dạng logic trong đó
các chi tiết được ghi lại được tạo thành từ những thay đổi đối với cấu trúc bên trong lõi chứ không phải
các cấu trúc trên đĩa. Các đối tượng khác - thường là bộ đệm - có
những thay đổi được ghi lại. Các sửa đổi nguyên tử chạy dài có những thay đổi riêng lẻ
được liên kết với nhau theo ý định, đảm bảo rằng quá trình khôi phục nhật ký có thể khởi động lại và
hoàn thành một thao tác chỉ được thực hiện một phần khi hệ thống dừng
hoạt động.

Lý do cho những khác biệt này là để giữ lượng không gian nhật ký và thời gian CPU
cần thiết để xử lý các đối tượng được sửa đổi càng nhỏ càng tốt và do đó
chi phí đăng nhập càng thấp càng tốt. Một số mục được sửa đổi rất thường xuyên,
và một số phần của đối tượng được sửa đổi thường xuyên hơn những phần khác, vì vậy việc giữ
chi phí ghi nhật ký siêu dữ liệu ở mức thấp có tầm quan trọng hàng đầu.

Phương pháp được sử dụng để ghi lại các sửa đổi của một mục hoặc chuỗi cùng nhau không phải là
đặc biệt quan trọng trong phạm vi của tài liệu này. Chỉ cần biết điều đó là đủ
phương pháp được sử dụng để ghi nhật ký một đối tượng cụ thể hoặc sửa đổi chuỗi
cùng nhau là khác nhau và phụ thuộc vào đối tượng và/hoặc sự sửa đổi
được thực hiện. Hệ thống con ghi nhật ký chỉ quan tâm đến một số quy tắc cụ thể nhất định
tuân theo để đảm bảo tiến độ chuyển tiếp và ngăn ngừa bế tắc.


Giao dịch bằng XFS
===================

XFS có hai loại giao dịch cấp cao, được xác định bởi loại không gian nhật ký
đặt phòng họ thực hiện. Chúng được gọi là "một lần" và "vĩnh viễn"
giao dịch. Đặt chỗ giao dịch vĩnh viễn có thể đặt chỗ trong khoảng thời gian
cam kết ranh giới, trong khi các giao dịch "một lần" chỉ dành cho một nguyên tử
sửa đổi.

Loại và quy mô đặt chỗ phải phù hợp với việc sửa đổi
nơi.  Điều này có nghĩa là các giao dịch vĩnh viễn có thể được sử dụng cho một lần
sửa đổi, nhưng việc đặt trước một lần không thể được sử dụng vĩnh viễn
giao dịch.

Trong mã, mẫu giao dịch một lần trông giống như thế này::

tp = xfs_trans_alloc(<reservation>)
	<khóa vật phẩm>
	<tham gia mục vào giao dịch>
	<thực hiện sửa đổi>
	xfs_trans_commit(tp);

Khi các mục được sửa đổi trong giao dịch, các vùng bẩn trong các mục đó sẽ được
được theo dõi thông qua việc xử lý giao dịch.  Sau khi giao dịch được thực hiện, tất cả
các tài nguyên tham gia vào nó sẽ được giải phóng, cùng với phần dự trữ chưa sử dụng còn lại
không gian đã được thực hiện tại thời điểm phân bổ giao dịch.

Ngược lại, một giao dịch lâu dài được tạo thành từ nhiều cá nhân được liên kết
giao dịch và mẫu trông như thế này::

tp = xfs_trans_alloc(<reservation>)
	xfs_ilock(ip, XFS_ILOCK_EXCL)

vòng lặp {
		xfs_trans_ijoin(tp, 0);
		<thực hiện sửa đổi>
		xfs_trans_log_inode(tp, ip);
		xfs_trans_roll(&tp);
	}

xfs_trans_commit(tp);
	xfs_iunlock(ip, XFS_ILOCK_EXCL);

Mặc dù điều này có thể trông giống như giao dịch một lần, nhưng có một điều quan trọng
sự khác biệt: xfs_trans_roll() thực hiện một thao tác cụ thể liên kết hai
giao dịch với nhau::

ntp = xfs_trans_dup(tp);
	xfs_trans_commit(tp);
	xfs_trans_reserve(ntp);

Điều này dẫn đến một loạt "giao dịch luân phiên" trong đó nút inode bị khóa
trong toàn bộ chuỗi giao dịch.  Do đó trong khi loạt lăn này
giao dịch đang chạy, không có gì khác có thể đọc hoặc ghi vào inode và
điều này cung cấp một cơ chế cho những thay đổi phức tạp xuất hiện nguyên tử từ bên ngoài
quan điểm của người quan sát.

Điều quan trọng cần lưu ý là một loạt các giao dịch luân phiên diễn ra vĩnh viễn.
giao dịch không tạo thành một thay đổi nguyên tử trong tạp chí. Trong khi mỗi
sửa đổi riêng lẻ là nguyên tử, chuỗi là ZZ0000ZZ. Nếu chúng ta gặp sự cố một nửa
cho đến hết thì quá trình khôi phục sẽ chỉ phát lại cho đến giao dịch cuối cùng
sửa đổi vòng lặp được thực hiện đã được cam kết với tạp chí.

Điều này ảnh hưởng đến các giao dịch cố định lâu dài ở chỗ không thể thực hiện được
dự đoán bao nhiêu hoạt động chạy dài sẽ thực sự được phục hồi bởi vì
không có gì đảm bảo về mức độ hoạt động đã đạt đến mức lưu trữ cũ. Do đó
nếu một hoạt động chạy dài yêu cầu nhiều giao dịch để hoàn thành đầy đủ,
hoạt động cấp cao phải sử dụng ý định và hoạt động trì hoãn để đảm bảo
recovery có thể hoàn thành thao tác sau khi các giao dịch đầu tiên được duy trì trong
nhật ký trên đĩa.


Giao dịch không đồng bộ
=============================

Trong XFS, theo mặc định, tất cả các giao dịch cấp cao đều không đồng bộ. Điều này có nghĩa là
xfs_trans_commit() không đảm bảo rằng việc sửa đổi đã được thực hiện
để lưu trữ ổn định khi nó trở lại. Do đó khi một hệ thống gặp sự cố, không phải tất cả
các giao dịch đã hoàn thành sẽ được phát lại trong quá trình khôi phục.

Tuy nhiên, hệ thống con ghi nhật ký cung cấp đảm bảo đặt hàng toàn cầu, chẳng hạn như
rằng nếu thấy một thay đổi cụ thể sau khi khôi phục thì tất cả các sửa đổi siêu dữ liệu
đã được cam kết trước sự thay đổi đó cũng sẽ được nhìn thấy.

Đối với các thao tác bắn một lần cần đạt đến mức lưu trữ ổn định ngay lập tức, hoặc
đảm bảo rằng một giao dịch lâu dài và lâu dài được cam kết đầy đủ sau khi nó được thực hiện
hoàn tất, chúng tôi có thể gắn thẻ giao dịch một cách rõ ràng là đồng bộ. Điều này sẽ kích hoạt
một "lực lượng log" để chuyển các giao dịch đã cam kết còn tồn đọng sang bộ lưu trữ ổn định
trong nhật ký và đợi cho đến khi hoàn thành.

Tuy nhiên, các giao dịch đồng bộ hiếm khi được sử dụng vì chúng hạn chế việc ghi nhật ký
thông lượng đến giới hạn độ trễ IO của bộ lưu trữ cơ bản. Thay vào đó, chúng tôi
có xu hướng sử dụng lực lượng log để đảm bảo các sửa đổi chỉ được lưu trữ ổn định khi
thao tác của người dùng yêu cầu xảy ra điểm đồng bộ hóa (ví dụ: fsync).


Đặt chỗ giao dịch
========================

Người ta đã đề cập nhiều lần rằng hệ thống con ghi nhật ký cần phải
cung cấp một sự đảm bảo về tiến độ chuyển tiếp để không có sửa đổi nào bị đình trệ
bởi vì nó không thể được viết vào tạp chí do thiếu chỗ trống trong
tạp chí. Điều này đạt được bằng việc đặt trước giao dịch được thực hiện khi
một giao dịch được phân bổ đầu tiên. Đối với các giao dịch lâu dài, các khoản đặt trước này
được duy trì như một phần của cơ chế cuộn giao dịch.

Việc đặt trước giao dịch cung cấp sự đảm bảo rằng có không gian nhật ký vật lý
sẵn sàng viết sửa đổi vào nhật ký trước khi chúng tôi bắt đầu thực hiện
sửa đổi các đối tượng và vật phẩm. Như vậy, lượng đặt chỗ cần phải lớn
đủ để tính đến lượng siêu dữ liệu mà thay đổi có thể cần
đăng nhập trong trường hợp xấu nhất. Điều này có nghĩa là nếu chúng ta sửa đổi một btree trong
giao dịch, chúng tôi phải dành đủ không gian để ghi lại toàn bộ quá trình phân chia từ lá đến gốc
của btree. Như vậy, việc đặt chỗ khá phức tạp vì chúng tôi phải
tính đến tất cả những thay đổi tiềm ẩn có thể xảy ra.

Ví dụ: phân bổ phạm vi dữ liệu người dùng liên quan đến việc phân bổ phạm vi từ
không gian trống, điều này làm thay đổi cây không gian trống. Đó là hai cây btree.  chèn
phạm vi trong bản đồ phạm vi của inode có thể yêu cầu phân chia bản đồ phạm vi
btree, yêu cầu phân bổ khác có thể sửa đổi cây không gian trống
một lần nữa.  Sau đó, chúng tôi có thể phải cập nhật ánh xạ ngược, điều này vẫn chưa sửa đổi
một cây btree khác có thể cần nhiều không gian hơn. Và vân vân.  Do đó số lượng
siêu dữ liệu mà một thao tác "đơn giản" có thể sửa đổi có thể khá lớn.

Phép tính "trường hợp xấu nhất" này cung cấp cho chúng ta "đặt trước đơn vị" tĩnh
cho giao dịch được tính toán tại thời điểm gắn kết. Chúng ta phải đảm bảo rằng
log có sẵn nhiều dung lượng như vậy trước khi giao dịch được phép tiếp tục
để khi chúng tôi ghi siêu dữ liệu bẩn vào nhật ký, chúng tôi sẽ không hết
không gian nhật ký trong nửa chặng đường ghi.

Đối với các giao dịch một lần, chỉ cần đặt trước một đơn vị không gian
cần thiết để giao dịch được tiến hành. Tuy nhiên, đối với các giao dịch lâu dài, chúng tôi
cũng có "số lượng nhật ký" ảnh hưởng đến quy mô đặt chỗ sẽ được thực hiện
thực hiện.

Mặc dù một giao dịch vĩnh viễn có thể được thực hiện chỉ với một đơn vị không gian
đặt trước, việc này sẽ không hiệu quả vì nó đòi hỏi
cơ chế cuộn giao dịch để dự trữ lại không gian trên mỗi cuộn giao dịch. Chúng tôi
biết từ việc thực hiện các giao dịch cố định có bao nhiêu giao dịch
các cuộn có khả năng dành cho những sửa đổi chung cần được thực hiện.

Ví dụ: phân bổ inode thường là hai giao dịch - một đến
cấp phát vật lý một đoạn inode trống trên đĩa, và một đoạn khác để phân bổ một đoạn inode
từ một đoạn inode có các inode trống trong đó.  Do đó để phân bổ inode
giao dịch, chúng tôi có thể đặt số lượng nhật ký đặt chỗ thành giá trị 2 để biểu thị
rằng giao dịch đường dẫn chung/nhanh sẽ thực hiện hai giao dịch được liên kết trong một
chuỗi. Mỗi lần thực hiện một giao dịch cố định, nó sẽ tiêu tốn toàn bộ đơn vị
đặt phòng.

Do đó khi giao dịch cố định được phân bổ lần đầu tiên, không gian nhật ký
việc đặt trước được tăng từ việc đặt trước một đơn vị lên nhiều đơn vị
đặt phòng. Bội số đó được xác định bởi số lượng nhật ký đặt chỗ và điều này
có nghĩa là chúng tôi có thể thực hiện giao dịch nhiều lần trước khi phải đặt trước lại
không gian đăng nhập khi chúng tôi thực hiện giao dịch. Điều này đảm bảo rằng điểm chung
những sửa đổi chúng tôi thực hiện chỉ cần đặt trước không gian nhật ký một lần.

Nếu số lượng nhật ký cho một giao dịch vĩnh viễn đạt đến 0 thì nó cần phải
dự trữ lại không gian vật lý trong nhật ký. Việc này hơi phức tạp và đòi hỏi
hiểu biết về cách nhật ký chiếm dung lượng đã được đặt trước.


Đăng nhập không gian kế toán
============================

Vị trí trong nhật ký thường được gọi là Số thứ tự nhật ký (LSN).
Nhật ký có hình tròn nên các vị trí trong nhật ký được xác định bằng tổ hợp
của số chu kỳ - số lần nhật ký đã được ghi đè - và
bù đắp vào nhật ký.  LSN mang chu trình ở 32 bit trên và
offset ở 32 bit thấp hơn. Phần bù được tính bằng đơn vị "khối cơ bản" (512
byte). Do đó, chúng ta có thể thực hiện phép toán dựa trên LSN tương đối đơn giản để theo dõi
không gian có sẵn trong nhật ký.

Việc tính toán không gian nhật ký được thực hiện thông qua một cặp cấu trúc được gọi là "đầu cấp".  các
vị trí của các đầu cấp là một giá trị tuyệt đối, do đó lượng không gian
có sẵn trong nhật ký được xác định bởi khoảng cách giữa vị trí của
cấp đầu và đuôi nhật ký hiện tại. Nghĩa là, có bao nhiêu không gian có thể
dành riêng/tiêu thụ trước khi người đứng đầu cấp phép hoàn toàn bao bọc nhật ký và vượt qua
vị trí đuôi.

Người đứng đầu cấp đầu tiên là người đứng đầu "dự trữ". Điều này theo dõi số byte của
đặt chỗ hiện đang được giữ bởi các giao dịch đang hoạt động. Nó hoàn toàn nằm trong bộ nhớ
tính toán việc đặt trước không gian và, như vậy, thực sự theo dõi độ lệch byte
vào nhật ký thay vì các khối cơ bản. Do đó về mặt kỹ thuật nó không sử dụng LSN để
đại diện cho vị trí nhật ký, nhưng nó vẫn được xử lý như một {chu kỳ, offset} được phân tách
tuple cho mục đích theo dõi không gian đặt trước.

Đầu cấp dự trữ được sử dụng để hạch toán chính xác giao dịch chính xác
số lượng đặt trước và số byte chính xác mà các sửa đổi thực sự tạo ra
và cần phải ghi vào nhật ký. Đầu dự trữ được sử dụng để ngăn ngừa mới
giao dịch từ việc nhận đặt chỗ mới khi người đứng đầu đạt đến hiện tại
đuôi. Nó sẽ chặn các đặt chỗ mới trong hàng đợi FIFO và khi đuôi nhật ký di chuyển
về phía trước nó sẽ đánh thức chúng theo thứ tự khi có đủ không gian. FIFO này
cơ chế đảm bảo không có giao dịch nào bị thiếu tài nguyên khi không gian nhật ký
tình trạng thiếu hụt xảy ra.

Đầu cấp còn lại là đầu "ghi". Không giống như người đứng đầu dự bị, khoản trợ cấp này
head chứa LSN và nó theo dõi việc sử dụng không gian vật lý trong nhật ký. Trong khi
điều này nghe có vẻ giống như nó đang hạch toán cùng trạng thái với người đứng đầu cấp dự trữ
- và nó chủ yếu theo dõi chính xác vị trí giống như người đứng đầu cấp dự trữ -
có sự khác biệt quan trọng trong hành vi giữa chúng cung cấp
tiến độ chuyển tiếp đảm bảo rằng các giao dịch luân phiên vĩnh viễn yêu cầu.

Những khác biệt này khi một giao dịch cố định được thực hiện và "nhật ký nội bộ
count" đạt tới 0 và tập hợp đơn vị đặt trước ban đầu đã được
kiệt sức. Tại thời điểm này, chúng tôi vẫn yêu cầu đặt trước không gian nhật ký để tiếp tục
giao dịch tiếp theo trong chuỗi, nhưng chúng tôi không còn lại giao dịch nào. Chúng tôi không thể
ngủ trong quá trình cam kết giao dịch, chờ không gian nhật ký mới trở thành
có sẵn, vì chúng tôi có thể kết thúc ở cuối hàng đợi FIFO và các vật phẩm chúng tôi có
bị khóa trong khi chúng ta ngủ có thể sẽ ghim đuôi khúc gỗ trước khi có
đủ không gian trống trong nhật ký để hoàn thành tất cả các đặt chỗ đang chờ xử lý và
sau đó đánh thức giao dịch cam kết đang diễn ra.

Để đặt chỗ mới mà không ngủ đòi hỏi chúng ta phải có khả năng
đặt chỗ ngay cả khi hiện tại không còn chỗ trống. Đó là,
chúng ta cần có ZZ0000ZZ không gian đặt trước nhật ký. Như đã có
đã được trình bày chi tiết, chúng tôi không thể vượt quá dung lượng nhật ký vật lý. Tuy nhiên, dự trữ
đầu cấp không theo dõi không gian vật lý - nó chỉ chiếm số lượng
đặt phòng chúng tôi hiện đang có chưa thanh toán. Do đó nếu đầu dự trữ vượt qua
ở phần cuối của nhật ký, điều đó có nghĩa là các đặt chỗ mới sẽ bị hạn chế
ngay lập tức và tiếp tục được điều tiết cho đến khi đuôi khúc gỗ được di chuyển về phía trước đủ xa
để loại bỏ cam kết quá mức và bắt đầu nhận đặt chỗ mới. Nói cách khác, chúng tôi
có thể vượt quá phần đầu dự trữ mà không vi phạm đầu và đuôi nhật ký vật lý
quy luật.

Do đó, các giao dịch vĩnh viễn chỉ "cấp lại" không gian đặt trước trong thời gian
xfs_trans_commit(), trong khi việc đặt trước không gian nhật ký vật lý - được theo dõi bởi
đầu ghi - sau đó được dành riêng bằng lệnh gọi tới xfs_log_reserve()
sau khi cam kết hoàn thành. Sau khi cam kết hoàn tất, chúng ta có thể ngủ chờ
không gian nhật ký vật lý được dành riêng từ đầu cấp quyền ghi, nhưng chỉ khi một
quy tắc quan trọng đã được tuân thủ::

Mã sử dụng đặt chỗ vĩnh viễn phải luôn ghi nhật ký các mục họ giữ
	bị khóa trên mỗi giao dịch mà họ thực hiện trong chuỗi.

"Đăng nhập lại" các vật phẩm bị khóa trên mỗi cuộn giao dịch đảm bảo rằng các vật phẩm đó
gắn liền với chuỗi giao dịch đang được triển khai luôn được chuyển đến
đầu vật lý của khúc gỗ và do đó không ghim phần đuôi của khúc gỗ. Nếu một mục bị khóa
ghim phần đuôi của nhật ký khi chúng tôi ngủ trên phần đặt trước ghi, sau đó chúng tôi sẽ
làm bế tắc nhật ký vì chúng tôi không thể lấy các khóa cần thiết để ghi lại mục đó và
di chuyển phần đuôi của nhật ký về phía trước để giải phóng không gian cấp quyền ghi. Đăng nhập lại
các mục bị khóa sẽ tránh được sự bế tắc này và đảm bảo rằng việc đặt trước nhật ký của chúng tôi
khiến không thể tự bế tắc.

Nếu tất cả các giao dịch cuộn đều tuân theo quy tắc này thì tất cả chúng đều có thể chuyển tiếp
tiến triển độc lập vì không có gì cản trở tiến trình của nhật ký
đuôi di chuyển về phía trước và do đó đảm bảo rằng không gian cấp quyền ghi luôn luôn
(cuối cùng) được cung cấp cho các giao dịch vĩnh viễn bất kể bao nhiêu lần
họ lăn.


Giải thích đăng nhập lại
========================

XFS cho phép thực hiện nhiều sửa đổi riêng biệt cho một đối tượng
nhật ký tại bất kỳ thời điểm nào.  Điều này cho phép nhật ký tránh phải xóa từng
chuyển sang đĩa trước khi ghi lại một thay đổi mới vào đối tượng. XFS thực hiện điều này thông qua một
phương pháp gọi là "đăng nhập lại". Về mặt khái niệm, điều này khá đơn giản - tất cả những gì nó yêu cầu
là bất kỳ thay đổi mới nào đối với đối tượng đều được ghi lại bằng ZZ0000ZZ của tất cả
những thay đổi hiện có trong giao dịch mới được ghi vào nhật ký.

Nghĩa là, nếu chúng ta có một chuỗi các thay đổi từ A đến F và đối tượng là
được ghi vào đĩa sau thay đổi D, chúng ta sẽ thấy trong nhật ký chuỗi sau
của các giao dịch, nội dung của chúng và số thứ tự nhật ký (LSN) của
giao dịch::

Nội dung giao dịch LSN
	   A A X
	   B A+B X+n
	   C A+B+C X+n+m
	   D A+B+C+D X+n+m+o
	    <đối tượng được ghi vào đĩa>
	   E E Y (> X+n+m+o)
	   F E+F Y+p

Nói cách khác, mỗi khi một đối tượng được đăng nhập lại, giao dịch mới sẽ chứa
tổng hợp tất cả các thay đổi trước đó hiện chỉ được lưu giữ trong nhật ký.

Kỹ thuật ghi lại nhật ký này cho phép các đối tượng được di chuyển về phía trước trong nhật ký để
một đối tượng được ghi lại không ngăn cản phần đuôi của khúc gỗ di chuyển
về phía trước.  Điều này có thể được nhìn thấy trong bảng trên bằng cách thay đổi (tăng) LSN
của mỗi giao dịch tiếp theo và đó là kỹ thuật cho phép chúng tôi
thực hiện các giao dịch cố định lâu dài, có nhiều cam kết.

Một ví dụ điển hình của giao dịch luân phiên là việc loại bỏ các phạm vi khỏi một
inode chỉ có thể được thực hiện với tốc độ hai phạm vi cho mỗi giao dịch vì
về giới hạn kích thước đặt trước. Do đó, một giao dịch loại bỏ phạm vi luân phiên
tiếp tục đăng nhập lại bộ đệm inode và btree khi chúng được sửa đổi trong mỗi bộ đệm
thao tác loại bỏ. Điều này giúp chúng tiến về phía trước trong nhật ký khi hoạt động
tiến triển, đảm bảo rằng hoạt động hiện tại không bao giờ bị chặn nếu
khúc gỗ quấn quanh.

Do đó có thể thấy rằng hoạt động đăng nhập lại là nền tảng cho việc xác định chính xác
hoạt động của hệ thống con ghi nhật ký XFS. Từ mô tả trên, hầu hết
mọi người sẽ có thể hiểu tại sao các hoạt động siêu dữ liệu XFS lại ghi nhiều đến vậy
nhật ký - các thao tác lặp lại cho cùng một đối tượng sẽ ghi những thay đổi giống nhau vào
nhật ký lặp đi lặp lại. Tệ hơn nữa là thực tế là các vật thể có xu hướng nhận được
bẩn hơn khi chúng được đăng nhập lại, vì vậy mỗi giao dịch tiếp theo sẽ ghi nhiều hơn
siêu dữ liệu vào nhật ký.

Bây giờ cũng rõ ràng cách đăng nhập lại và giao dịch không đồng bộ diễn ra như thế nào
tay trong tay. Nghĩa là, các giao dịch không được ghi vào nhật ký vật lý
cho đến khi bộ đệm nhật ký được lấp đầy (bộ đệm nhật ký có thể chứa nhiều
giao dịch) hoặc một hoạt động đồng bộ buộc các bộ đệm nhật ký giữ
giao dịch vào đĩa. Điều này có nghĩa là XFS đang thực hiện tổng hợp các giao dịch
trong bộ nhớ - sắp xếp chúng theo nhóm, nếu bạn muốn - để giảm thiểu tác động của nhật ký IO lên
thông lượng giao dịch.

Hạn chế về thông lượng giao dịch không đồng bộ là số lượng và kích thước của
bộ đệm nhật ký được cung cấp bởi người quản lý nhật ký. Theo mặc định có 8 nhật ký
bộ đệm có sẵn và kích thước của mỗi bộ đệm là 32kB - kích thước có thể tăng lên
lên 256kB bằng cách sử dụng tùy chọn gắn kết.

Thực tế, điều này mang lại cho chúng tôi giới hạn tối đa về những thay đổi siêu dữ liệu nổi bật
có thể được thực hiện đối với hệ thống tập tin vào bất kỳ thời điểm nào - nếu tất cả nhật ký
bộ đệm đã đầy và ở mức IO, thì không thể thực hiện thêm giao dịch nào cho đến khi
Lô hiện tại hoàn thành. Hiện nay, một lõi CPU hiện tại thường được sử dụng
có thể phát hành đủ giao dịch để giữ cho bộ đệm nhật ký luôn đầy đủ và dưới mức
IO vĩnh viễn. Do đó, hệ thống con ghi nhật ký XFS có thể được coi là IO
ràng buộc.

Ghi nhật ký bị trì hoãn: Các khái niệm
======================================

Điều quan trọng cần lưu ý về việc ghi nhật ký không đồng bộ kết hợp với
kỹ thuật ghi nhật ký lại mà XFS sử dụng là chúng ta có thể ghi nhật ký lại các đối tượng đã thay đổi
nhiều lần trước khi chúng được đưa vào đĩa trong bộ đệm nhật ký. Nếu chúng ta
quay lại ví dụ đăng nhập lại trước đó, hoàn toàn có thể
các giao dịch từ A đến D được chuyển vào đĩa trong cùng một bộ đệm nhật ký.

Nghĩa là, một bộ đệm nhật ký có thể chứa nhiều bản sao của cùng một đối tượng,
nhưng chỉ cần có một trong những bản sao đó - bản "D" cuối cùng, vì nó
chứa tất cả các thay đổi từ những thay đổi trước đó. Nói cách khác, chúng ta có một
bản sao cần thiết trong bộ đệm nhật ký và ba bản sao cũ đơn giản
lãng phí không gian. Khi chúng ta thực hiện các thao tác lặp đi lặp lại trên cùng một tập hợp
các đối tượng, những "đối tượng cũ" này có thể chiếm hơn 90% không gian được sử dụng trong nhật ký
bộ đệm. Rõ ràng là việc giảm số lượng đối tượng cũ được ghi vào
log sẽ làm giảm đáng kể lượng siêu dữ liệu mà chúng tôi ghi vào nhật ký và điều này
là mục tiêu cơ bản của việc ghi nhật ký bị trì hoãn.

Từ quan điểm khái niệm, XFS đã thực hiện đăng nhập lại vào bộ nhớ (trong đó
bộ nhớ == bộ đệm nhật ký), chỉ có điều nó hoạt động cực kỳ kém hiệu quả. Nó đang sử dụng
định dạng logic sang vật lý để thực hiện việc đăng nhập lại vì không có
cơ sở hạ tầng để theo dõi những thay đổi logic trong bộ nhớ trước khi thực hiện
định dạng các thay đổi trong giao dịch vào bộ đệm nhật ký. Vì thế chúng ta không thể tránh
tích lũy các đối tượng cũ trong bộ đệm nhật ký.

Ghi nhật ký bị trì hoãn là tên chúng tôi đặt cho việc lưu giữ và theo dõi các giao dịch
thay đổi các đối tượng trong bộ nhớ bên ngoài cơ sở hạ tầng bộ đệm nhật ký. Bởi vì
khái niệm ghi nhật ký cơ bản của hệ thống con ghi nhật ký XFS, đây là
thực sự tương đối dễ thực hiện - tất cả những thay đổi đối với các mục đã ghi đã được thực hiện
được theo dõi trong cơ sở hạ tầng hiện tại. Vấn đề lớn là làm thế nào để tích lũy
chúng và đưa chúng vào nhật ký một cách nhất quán, có thể phục hồi được.
Mô tả các vấn đề và cách chúng được giải quyết là trọng tâm của phần này.
tài liệu.

Một trong những thay đổi quan trọng mà việc ghi nhật ký bị trì hoãn gây ra đối với hoạt động của
hệ thống con ghi nhật ký là nó tách rời số lượng còn tồn đọng
siêu dữ liệu thay đổi về kích thước và số lượng bộ đệm nhật ký có sẵn. Ở nơi khác
thay vì chỉ có tối đa 2 MB giao dịch thay đổi không
được ghi vào nhật ký tại bất kỳ thời điểm nào, có thể có số lượng lớn hơn nhiều
được tích lũy trong bộ nhớ. Do đó khả năng mất siêu dữ liệu trên một
sự cố lớn hơn nhiều so với cơ chế ghi nhật ký hiện có.

Cần lưu ý rằng điều này không thay đổi sự đảm bảo rằng việc khôi phục nhật ký sẽ
sẽ dẫn đến một hệ thống tập tin nhất quán. Điều đó có nghĩa là theo như
hệ thống tập tin được khôi phục có liên quan, có thể có hàng nghìn giao dịch
điều đó đơn giản không xảy ra do vụ va chạm. Điều này làm cho nó thậm chí còn nhiều hơn
điều quan trọng là các ứng dụng quan tâm đến dữ liệu của họ sẽ sử dụng fsync() khi chúng
cần đảm bảo tính toàn vẹn dữ liệu ở cấp độ ứng dụng được duy trì.

Cần lưu ý rằng việc ghi nhật ký bị trì hoãn không phải là một khái niệm mới mang tính đổi mới
đảm bảo bằng chứng nghiêm ngặt để xác định xem nó có đúng hay không. phương pháp
tích lũy những thay đổi trong bộ nhớ trong một khoảng thời gian trước khi ghi chúng vào
log được sử dụng hiệu quả trong nhiều hệ thống tập tin bao gồm ext3 và ext4. Do đó
tài liệu này không dành thời gian để thuyết phục người đọc rằng
khái niệm là âm thanh. Thay vào đó nó chỉ được coi là một "vấn đề đã được giải quyết" và
Việc triển khai nó trong XFS hoàn toàn là một bài tập về công nghệ phần mềm.

Các yêu cầu cơ bản để trì hoãn việc đăng nhập vào XFS rất đơn giản:

1. Giảm số lượng siêu dữ liệu được ghi vào nhật ký ít nhất
	   một thứ tự độ lớn.
	2. Cung cấp đủ số liệu thống kê để xác thực Yêu cầu #1.
	3. Cung cấp đủ cơ sở hạ tầng truy tìm mới để có thể gỡ lỗi
	   vấn đề với mã mới.
	4. Không thay đổi định dạng trên đĩa (định dạng siêu dữ liệu hoặc nhật ký).
	5. Kích hoạt và vô hiệu hóa bằng tùy chọn gắn kết.
	6. Không có hồi quy hiệu suất cho khối lượng công việc giao dịch đồng bộ.

Ghi nhật ký bị trì hoãn: Thiết kế
=================================

Lưu trữ các thay đổi
--------------------

Vấn đề với việc tích lũy các thay đổi ở mức logic (tức là chỉ sử dụng
theo dõi vùng bẩn của mục nhật ký hiện có) là khi viết
thay đổi đối với bộ đệm nhật ký, chúng ta cần đảm bảo rằng đối tượng chúng ta đang định dạng
không thay đổi khi chúng ta làm điều này. Điều này đòi hỏi phải khóa đối tượng để ngăn chặn
sửa đổi đồng thời Do đó, việc xóa các thay đổi hợp lý vào nhật ký sẽ
yêu cầu chúng tôi khóa mọi đối tượng, định dạng chúng và sau đó mở khóa lại.

Điều này tạo ra nhiều khả năng xảy ra bế tắc với các giao dịch đã được thực hiện
đang chạy. Ví dụ: một giao dịch có đối tượng A bị khóa và sửa đổi, nhưng cần
khóa theo dõi ghi nhật ký bị trì hoãn để thực hiện giao dịch. Tuy nhiên,
luồng xả có khóa theo dõi ghi nhật ký bị trì hoãn đã được giữ và
cố gắng lấy khóa trên đối tượng A để xóa nó vào bộ đệm nhật ký. Điều này xuất hiện
là một tình trạng bế tắc không thể giải quyết được, và nó đã giải quyết được vấn đề này
là rào cản cho việc thực hiện ghi nhật ký bị trì hoãn quá lâu.

Giải pháp tương đối đơn giản - chỉ mất một thời gian dài để nhận ra nó.
Nói một cách đơn giản, mã ghi nhật ký hiện tại định dạng các thay đổi đối với từng mục thành một
mảng vectơ trỏ đến các vùng đã thay đổi trong mục. Mã ghi nhật ký
chỉ cần sao chép bộ nhớ mà các vectơ này trỏ tới vào bộ đệm nhật ký trong quá trình
cam kết giao dịch trong khi mục bị khóa trong giao dịch. Thay vì
bằng cách sử dụng bộ đệm nhật ký làm đích của mã định dạng, chúng ta có thể sử dụng
bộ nhớ đệm được phân bổ đủ lớn để vừa với vectơ được định dạng.

Sau đó, nếu chúng ta sao chép vectơ vào bộ nhớ đệm và viết lại vectơ thành
trỏ tới bộ nhớ đệm chứ không phải chính đối tượng đó, bây giờ chúng ta có một bản sao của
những thay đổi ở định dạng tương thích với mã ghi bộ đệm nhật ký.
điều đó không yêu cầu chúng ta khóa mục để truy cập. Định dạng này và
việc viết lại đều có thể được thực hiện trong khi đối tượng bị khóa trong quá trình cam kết giao dịch,
dẫn đến một vectơ nhất quán về mặt giao dịch và có thể được truy cập
mà không cần phải khóa mục sở hữu.

Do đó chúng ta tránh được việc phải khóa các mục khi chúng ta cần xóa các mục còn tồn đọng
giao dịch không đồng bộ vào nhật ký. Sự khác biệt giữa hiện tại
phương pháp định dạng và định dạng ghi nhật ký bị trì hoãn có thể được nhìn thấy trong
sơ đồ dưới đây.

Vectơ nhật ký định dạng hiện tại::

Đối tượng +---------------------------------------------+
    Vectơ 1 +----+
    Vectơ 2 +----+
    Vectơ 3 +----------+

Sau khi định dạng::

Bộ đệm nhật ký +-V1-+-V2-+----V3----+

Vectơ ghi nhật ký bị trì hoãn::

Đối tượng +---------------------------------------------+
    Vectơ 1 +----+
    Vectơ 2 +----+
    Vectơ 3 +----------+

Sau khi định dạng::

Bộ nhớ đệm +-V1-+-V2-+----V3----+
    Vectơ 1 +----+
    Vectơ 2 +----+
    Vectơ 3 +----------+

Bộ nhớ đệm và vectơ liên quan cần được truyền dưới dạng một đối tượng,
nhưng vẫn cần được liên kết với đối tượng cha nên nếu đối tượng đó là
được đăng nhập lại, chúng ta có thể thay thế bộ nhớ đệm hiện tại bằng bộ nhớ đệm mới
chứa những thay đổi mới nhất.

Lý do giữ lại vectơ sau khi chúng ta định dạng bộ nhớ
bộ đệm là để hỗ trợ phân tách vectơ qua ranh giới bộ đệm nhật ký một cách chính xác.
Nếu chúng ta không giữ vectơ xung quanh, chúng ta sẽ không biết ranh giới vùng ở đâu
có trong mục này, vì vậy chúng tôi cần một phương thức đóng gói mới cho các vùng trong nhật ký
ghi đệm (tức là đóng gói kép). Đây sẽ là một định dạng trên đĩa
thay đổi và như vậy là không mong muốn.  Điều đó cũng có nghĩa là chúng ta phải viết nhật ký
tiêu đề vùng trong giai đoạn định dạng, đây là vấn đề vì có
trạng thái vùng cần được đặt vào tiêu đề trong quá trình ghi nhật ký.

Do đó chúng ta cần giữ lại vectơ nhưng bằng cách gắn bộ nhớ đệm vào nó và
viết lại các địa chỉ vectơ để trỏ vào bộ nhớ đệm, chúng ta sẽ có một
đối tượng tự mô tả có thể được truyền vào bộ đệm nhật ký ghi mã để
được xử lý theo cách tương tự như cách xử lý các vectơ nhật ký hiện có.
Do đó, chúng tôi tránh cần một định dạng mới trên đĩa để xử lý các mục đã được
được đăng nhập lại vào bộ nhớ.


Theo dõi thay đổi
-----------------

Bây giờ chúng ta có thể ghi lại những thay đổi giao dịch trong bộ nhớ dưới dạng cho phép
chúng được sử dụng không hạn chế, chúng ta cần có khả năng theo dõi và tích lũy
chúng để chúng có thể được ghi vào nhật ký vào một thời điểm nào đó sau đó.  các
mục nhật ký là nơi tự nhiên để lưu trữ vectơ và bộ đệm này, đồng thời cũng có ý nghĩa
là đối tượng được sử dụng để theo dõi các đối tượng đã cam kết vì nó sẽ luôn như vậy
tồn tại một khi đối tượng đã được đưa vào một giao dịch.

Mục nhật ký đã được sử dụng để theo dõi các mục nhật ký đã được ghi vào
nhật ký nhưng chưa được ghi vào đĩa. Các mục nhật ký như vậy được coi là "hoạt động"
và như vậy được lưu trữ trong Danh sách mục hoạt động (AIL), được đặt hàng theo LSN
danh sách liên kết đôi. Các mục được chèn vào danh sách này trong bộ đệm nhật ký IO
hoàn thành, sau đó chúng được bỏ ghim và có thể được ghi vào đĩa. Một vật thể
đó là trong AIL có thể được đăng nhập lại, điều này khiến đối tượng bị ghim lại
và sau đó di chuyển về phía trước trong AIL khi bộ đệm nhật ký IO hoàn thành việc đó
giao dịch.

Về cơ bản, điều này cho thấy một mục trong AIL vẫn có thể được sửa đổi
và được đăng nhập lại, vì vậy mọi hoạt động theo dõi phải tách biệt với cơ sở hạ tầng AIL. Như
như vậy, chúng tôi không thể sử dụng lại con trỏ danh sách AIL để theo dõi các mục đã cam kết, cũng như
chúng tôi có thể lưu trữ trạng thái trong bất kỳ trường nào được bảo vệ bằng khóa AIL không. Do đó
Theo dõi mục đã cam kết cần có khóa, danh sách và trường trạng thái riêng trong nhật ký
mục.

Tương tự như AIL, việc theo dõi các mục đã cam kết được thực hiện thông qua danh sách mới
được gọi là Danh sách mục đã cam kết (CIL).  Danh sách theo dõi các mục nhật ký đã được
đã cam kết và có bộ nhớ đệm được định dạng gắn liền với chúng. Nó theo dõi các đối tượng
theo thứ tự cam kết giao dịch, vì vậy khi một đối tượng được đăng nhập lại, nó sẽ bị xóa khỏi
vị trí của nó trong danh sách và được chèn lại ở phần đuôi. Điều này hoàn toàn tùy ý
và được thực hiện để dễ dàng gỡ lỗi - các mục cuối cùng trong danh sách là
những cái được sửa đổi gần đây nhất. Việc đặt hàng CIL là không cần thiết đối với
tính toàn vẹn giao dịch (như được thảo luận trong phần tiếp theo) nên thứ tự là
được thực hiện để thuận tiện/sự tỉnh táo của các nhà phát triển.


Ghi nhật ký bị trì hoãn: Điểm kiểm tra
--------------------------------------

Khi chúng tôi có sự kiện đồng bộ hóa nhật ký, thường được gọi là "lực lượng nhật ký",
tất cả các mục trong CIL phải được ghi vào nhật ký thông qua bộ đệm nhật ký.
Chúng ta cần viết các mục này theo thứ tự chúng tồn tại trong CIL và chúng
cần phải được viết dưới dạng một giao dịch nguyên tử. Sự cần thiết của tất cả các đối tượng
được viết dưới dạng một giao dịch nguyên tử xuất phát từ các yêu cầu đăng nhập lại và
phát lại nhật ký - tất cả các thay đổi trong tất cả các đối tượng trong một giao dịch nhất định phải
hoặc được phát lại hoàn toàn trong quá trình khôi phục nhật ký hoặc hoàn toàn không được phát lại. Nếu
một giao dịch không được thực hiện lại vì nó chưa hoàn tất trong nhật ký, thì
cũng không có giao dịch nào sau đó được thực hiện lại.

Để đáp ứng yêu cầu này, chúng ta cần ghi toàn bộ CIL vào một nhật ký duy nhất
giao dịch. May mắn thay, mã nhật ký XFS không có giới hạn cố định về kích thước của một
giao dịch, cũng như mã phát lại nhật ký. Giới hạn cơ bản duy nhất là
giao dịch không thể lớn hơn một nửa kích thước của nhật ký.  các
Sở dĩ có giới hạn này là để tìm được đầu và đuôi của khúc gỗ thì phải
có ít nhất một giao dịch hoàn chỉnh trong nhật ký tại bất kỳ thời điểm nào. Nếu một
giao dịch lớn hơn một nửa nhật ký thì có khả năng xảy ra
sự cố trong quá trình ghi một giao dịch như vậy có thể ghi đè một phần
chỉ hoàn thành giao dịch trước đó trong nhật ký. Điều này sẽ dẫn đến sự phục hồi
lỗi và hệ thống tập tin không nhất quán và do đó chúng ta phải thực thi mức tối đa
kích thước của điểm kiểm tra nhỏ hơn một nửa nhật ký một chút.

Ngoài yêu cầu về kích thước này, giao dịch tại điểm kiểm tra trông không khác gì
tới bất kỳ giao dịch nào khác - nó chứa tiêu đề giao dịch, một loạt
các mục nhật ký được định dạng và một bản ghi cam kết ở cuối. Từ sự phục hồi
Ở góc độ khác, giao dịch tại điểm kiểm tra cũng không khác gì - chỉ là rất nhiều
lớn hơn với nhiều mặt hàng hơn trong đó. Hậu quả xấu nhất của việc này là chúng ta
có thể cần phải điều chỉnh kích thước băm của đối tượng giao dịch khôi phục.

Bởi vì điểm kiểm tra chỉ là một giao dịch khác và tất cả những thay đổi đối với nhật ký
các mục được lưu trữ dưới dạng vectơ nhật ký, chúng ta có thể sử dụng cách ghi bộ đệm nhật ký hiện có
mã để ghi các thay đổi vào nhật ký. Để làm được điều này một cách hiệu quả, chúng ta cần
giảm thiểu thời gian chúng tôi giữ CIL bị khóa trong khi viết điểm kiểm tra
giao dịch. Mã ghi nhật ký hiện tại cho phép chúng tôi thực hiện việc này một cách dễ dàng với
cách nó tách biệt việc ghi nội dung giao dịch (vectơ nhật ký) khỏi
bản ghi cam kết giao dịch, nhưng việc theo dõi điều này đòi hỏi chúng ta phải có
bối cảnh trên mỗi điểm kiểm tra đi qua quá trình ghi nhật ký đến
hoàn thành điểm kiểm tra.

Do đó, một điểm kiểm tra có bối cảnh theo dõi trạng thái của dòng điện
điểm kiểm tra từ khi bắt đầu đến khi hoàn thành điểm kiểm tra. Một bối cảnh mới được bắt đầu
đồng thời một giao dịch điểm kiểm tra được bắt đầu. Tức là khi chúng ta loại bỏ
tất cả các mục hiện tại từ CIL trong quá trình vận hành điểm kiểm tra, chúng tôi sẽ di chuyển tất cả
những thay đổi đó trong bối cảnh điểm kiểm tra hiện tại. Sau đó chúng tôi khởi tạo một cái mới
ngữ cảnh và đính kèm nó vào CIL để tổng hợp các giao dịch mới.

Điều này cho phép chúng tôi mở khóa CIL ngay sau khi chuyển tất cả
các mục đã cam kết và cho phép thực hiện các giao dịch mới một cách hiệu quả trong khi chúng tôi
đang định dạng điểm kiểm tra vào nhật ký. Nó cũng cho phép đồng thời
điểm kiểm tra được ghi vào bộ đệm nhật ký trong trường hợp lực lượng nhật ký nặng
khối lượng công việc, giống như mã cam kết giao dịch hiện tại. Tuy nhiên, điều này
yêu cầu chúng tôi sắp xếp nghiêm ngặt các bản ghi cam kết trong nhật ký để
Thứ tự trình tự điểm kiểm tra được duy trì trong quá trình phát lại nhật ký.

Để đảm bảo rằng chúng tôi có thể ghi một mục vào giao dịch điểm kiểm tra tại
cùng lúc một giao dịch khác sửa đổi mục và chèn mục nhật ký
vào CIL mới, khi đó mã cam kết giao dịch điểm kiểm tra không thể sử dụng các mục nhật ký
để lưu trữ danh sách các vectơ nhật ký cần được ghi vào giao dịch.
Do đó, các vectơ log cần có khả năng được xâu chuỗi lại với nhau để cho phép chúng được
tách ra khỏi các mục nhật ký. Nghĩa là, khi CIL bị xóa bộ nhớ
bộ đệm và vectơ nhật ký được gắn vào mỗi mục nhật ký cần được gắn vào
bối cảnh điểm kiểm tra để mục nhật ký có thể được giải phóng. Ở dạng sơ đồ,
CIL sẽ trông như thế này trước khi xả::

Đầu CIL
	   |
	   V.
	Mục nhật ký <-> vectơ nhật ký 1 -> bộ nhớ đệm
	   |				-> mảng vectơ
	   V.
	Mục nhật ký <-> vectơ nhật ký 2 -> bộ nhớ đệm
	   |				-> mảng vectơ
	   V.
	......
	   |
	   V
Mục nhật ký <-> vectơ nhật ký N-1 -> bộ nhớ đệm
	   |				-> mảng vectơ
	   V.
	Mục nhật ký <-> vectơ nhật ký N -> bộ nhớ đệm
					-> mảng vectơ

Và sau khi xả, đầu CIL trống và nhật ký ngữ cảnh điểm kiểm tra
danh sách vector sẽ trông giống như::

Bối cảnh điểm kiểm tra
	   |
	   V.
	log vector 1 -> bộ nhớ đệm
	   |		-> mảng vectơ
	   |		-> Mục nhật ký
	   V.
	log vector 2 -> bộ nhớ đệm
	   |		-> mảng vectơ
	   |		-> Mục nhật ký
	   V.
	......
	   |
	   V
vectơ nhật ký N-1 -> bộ nhớ đệm
	   |		-> mảng vectơ
	   |		-> Mục nhật ký
	   V.
	vectơ nhật ký N -> bộ nhớ đệm
			-> mảng vectơ
			-> Mục nhật ký

Sau khi quá trình chuyển này hoàn tất, CIL có thể được mở khóa và các giao dịch mới có thể
bắt đầu, trong khi mã xóa điểm kiểm tra hoạt động trên chuỗi vectơ nhật ký để
cam kết điểm kiểm tra.

Khi điểm kiểm tra được ghi vào bộ đệm nhật ký, bối cảnh điểm kiểm tra sẽ
được đính kèm vào bộ đệm nhật ký mà bản ghi cam kết được ghi vào cùng với một
gọi lại hoàn thành. Việc hoàn thành nhật ký IO sẽ gọi cuộc gọi lại đó, sau đó có thể
chạy xử lý cam kết giao dịch cho các mục nhật ký (tức là chèn vào AIL
và bỏ ghim) trong chuỗi vectơ nhật ký, sau đó giải phóng chuỗi vectơ nhật ký và
bối cảnh điểm kiểm tra.

Điểm thảo luận: Tôi không chắc chắn liệu mục nhật ký có phù hợp nhất không
cách hiệu quả để theo dõi vectơ, mặc dù đó có vẻ là cách tự nhiên để làm
nó. Thực tế là chúng tôi quản lý các mục nhật ký (trong CIL) chỉ để xâu chuỗi nhật ký
vectơ và phá vỡ liên kết giữa mục nhật ký và vectơ nhật ký có nghĩa là
chúng tôi lấy một dòng bộ đệm để sửa đổi danh sách mục nhật ký, sau đó một dòng khác cho
chuỗi vector log. Nếu chúng ta theo dõi bằng vectơ log thì chúng ta chỉ cần
phá vỡ liên kết giữa mục nhật ký và vectơ nhật ký, điều đó có nghĩa là chúng ta nên
chỉ làm bẩn các dòng đệm của mục nhật ký. Thông thường tôi sẽ không quan tâm đến một
so với hai đường dẫn lưu trữ bẩn ngoại trừ thực tế là tôi đã thấy tới 80.000 nhật ký
vectơ trong một giao dịch điểm kiểm tra. Tôi đoán đây là một "biện pháp và
so sánh" tình huống có thể được thực hiện sau khi triển khai và xem xét lại
nằm trong cây dev....

Ghi nhật ký bị trì hoãn: Trình tự điểm kiểm tra
-----------------------------------------------

Một trong những khía cạnh quan trọng của hệ thống con giao dịch XFS là nó gắn thẻ
giao dịch đã cam kết với số thứ tự nhật ký của giao dịch cam kết.
Điều này cho phép các giao dịch được phát hành một cách không đồng bộ mặc dù có thể có
các hoạt động trong tương lai không thể hoàn thành cho đến khi giao dịch đó được thực hiện đầy đủ
cam kết với nhật ký. Trong trường hợp hiếm hoi xảy ra thao tác phụ thuộc (ví dụ:
sử dụng lại phạm vi siêu dữ liệu được giải phóng cho phạm vi dữ liệu), nhật ký đặc biệt, được tối ưu hóa
lực lượng có thể được ban hành để buộc giao dịch phụ thuộc vào đĩa ngay lập tức.

Để thực hiện việc này, các giao dịch cần ghi lại LSN của bản ghi cam kết của
giao dịch. LSN này đến trực tiếp từ bộ đệm nhật ký mà giao dịch được thực hiện
được viết vào. Mặc dù điều này chỉ hoạt động tốt đối với giao dịch hiện tại
cơ chế này, nó không hoạt động đối với việc ghi nhật ký bị trì hoãn vì các giao dịch không được thực hiện
được ghi trực tiếp vào bộ đệm nhật ký. Do đó một số phương pháp giải trình tự khác
giao dịch là cần thiết.

Như đã thảo luận trong phần điểm kiểm tra, việc ghi nhật ký bị trì hoãn sử dụng cho mỗi điểm kiểm tra
ngữ cảnh, và do đó thật đơn giản để gán số thứ tự cho mỗi ngữ cảnh
trạm kiểm soát. Bởi vì việc chuyển đổi bối cảnh điểm kiểm tra phải được thực hiện
về mặt nguyên tử, thật đơn giản để đảm bảo rằng mỗi bối cảnh mới có một sự đơn điệu
tăng số thứ tự được gán cho nó mà không cần một bộ điều khiển bên ngoài
bộ đếm nguyên tử - chúng ta chỉ cần lấy số thứ tự ngữ cảnh hiện tại và thêm
một cho nó cho bối cảnh mới.

Sau đó, thay vì gán bộ đệm nhật ký LSN cho giao dịch, hãy cam kết LSN
trong quá trình cam kết, chúng ta có thể chỉ định trình tự điểm kiểm tra hiện tại. Điều này cho phép
hoạt động theo dõi các giao dịch chưa hoàn thành biết những gì
trình tự điểm kiểm tra cần phải được cam kết trước khi chúng có thể tiếp tục. Như một
kết quả là mã buộc nhật ký vào một LSN cụ thể hiện cần phải đảm bảo rằng
nhật ký buộc phải đến một điểm kiểm tra cụ thể.

Để đảm bảo rằng chúng tôi có thể làm được điều này, chúng tôi cần theo dõi tất cả bối cảnh của điểm kiểm tra
hiện đang cam kết với nhật ký. Khi chúng tôi xóa một trạm kiểm soát,
bối cảnh được thêm vào danh sách "cam kết" có thể tìm kiếm được. Khi một
cam kết điểm kiểm tra hoàn tất, nó sẽ bị xóa khỏi danh sách cam kết. Bởi vì
bối cảnh điểm kiểm tra ghi lại LSN của bản ghi cam kết cho điểm kiểm tra,
chúng ta cũng có thể đợi trên bộ đệm nhật ký chứa bản ghi cam kết, do đó
sử dụng các cơ chế log lực hiện có để thực hiện các lực đồng bộ.

Cần lưu ý rằng lực đồng bộ có thể cần phải được mở rộng bằng
các thuật toán giảm thiểu tương tự như mã bộ đệm nhật ký hiện tại để cho phép
tổng hợp nhiều giao dịch đồng bộ nếu đã có
các giao dịch đồng bộ đang bị xóa. Điều tra hiệu quả hoạt động của
thiết kế hiện tại là cần thiết trước khi đưa ra bất kỳ quyết định nào ở đây.

Mối quan tâm chính với lực lượng log là đảm bảo rằng tất cả các điểm kiểm tra trước đó
cũng được cam kết vào đĩa trước đĩa chúng ta cần chờ. Vì vậy chúng tôi
cần kiểm tra xem tất cả các bối cảnh trước đó trong danh sách cam kết cũng có
hoàn thành trước khi chờ đợi cái chúng ta cần hoàn thành. Chúng tôi làm điều này
đồng bộ hóa mã lực lượng nhật ký để chúng tôi không cần phải đợi ở đâu
khác đối với việc tuần tự hóa như vậy - nó chỉ quan trọng khi chúng tôi thực hiện lực lượng log.

Sự phức tạp duy nhất còn lại là lực lượng log bây giờ cũng phải xử lý
trường hợp số thứ tự bắt buộc giống với bối cảnh hiện tại. Đó
là, chúng ta cần xóa CIL và có thể đợi nó hoàn thành. Đây là một
bổ sung đơn giản vào nhật ký hiện có buộc mã phải kiểm tra số thứ tự
và đẩy nếu cần thiết. Thật vậy, việc đặt điểm kiểm tra trình tự hiện tại trong
mã lực lượng nhật ký cho phép cơ chế hiện tại phát hành đồng bộ
các giao dịch không bị ảnh hưởng (tức là thực hiện một giao dịch không đồng bộ, sau đó
buộc ghi nhật ký tại LSN của giao dịch đó) và do đó mã cấp cao hơn
hoạt động giống nhau bất kể việc ghi nhật ký bị trì hoãn có được sử dụng hay không.

Ghi nhật ký bị trì hoãn: Kế toán không gian nhật ký điểm kiểm tra
-----------------------------------------------------------------

Vấn đề lớn đối với giao dịch điểm kiểm tra là việc đặt trước không gian nhật ký cho
giao dịch. Chúng tôi không biết giao dịch tại điểm kiểm tra sẽ lớn đến mức nào
trước thời hạn, cũng như cần bao nhiêu bộ đệm nhật ký để ghi ra, cũng như
số vùng vectơ nhật ký phân tách sẽ được sử dụng. Chúng tôi có thể theo dõi
lượng không gian nhật ký cần thiết khi chúng tôi thêm các mục vào danh sách mục cam kết, nhưng chúng tôi
vẫn cần dành chỗ trống trong nhật ký cho trạm kiểm soát.

Một giao dịch thông thường dành đủ dung lượng trong nhật ký cho khoảng trống trong trường hợp xấu nhất
việc sử dụng giao dịch. Các tài khoản dành riêng cho các tiêu đề bản ghi nhật ký,
tiêu đề giao dịch và vùng, tiêu đề cho các vùng được phân chia, phần đệm đuôi bộ đệm,
v.v. cũng như không gian thực tế cho tất cả siêu dữ liệu đã thay đổi trong
giao dịch. Trong khi một số chi phí này là cố định, phần lớn phụ thuộc vào
quy mô của giao dịch và số vùng được ghi lại (số
của vectơ nhật ký trong giao dịch).

Một ví dụ về sự khác biệt là ghi nhật ký thay đổi thư mục so với ghi nhật ký
inode thay đổi. Nếu bạn sửa đổi nhiều lõi inode (ví dụ ZZ0000ZZ), thì
có rất nhiều giao dịch chỉ chứa lõi inode và nhật ký inode
cấu trúc định dạng. Nghĩa là, hai vectơ có tổng cộng khoảng 150 byte. Nếu chúng ta sửa đổi
10.000 inode, chúng tôi có khoảng 1,5 MB siêu dữ liệu để ghi vào 20.000 vectơ. Mỗi
vectơ là 12 byte, do đó tổng dung lượng được ghi là khoảng 1,75 MB. trong
so sánh, nếu chúng tôi ghi lại bộ đệm thư mục đầy đủ, chúng thường là 4KB
mỗi bộ đệm, vì vậy, trong 1,5 MB bộ đệm thư mục, chúng ta sẽ có khoảng 400 bộ đệm và một
cấu trúc định dạng bộ đệm cho mỗi bộ đệm - khoảng 800 vectơ hoặc tổng cộng 1,51 MB
không gian.  Từ đó, có thể thấy rõ rằng việc đặt trước không gian nhật ký tĩnh là
không đặc biệt linh hoạt và khó chọn “giá trị tối ưu” cho
mọi khối lượng công việc.

Hơn nữa, nếu chúng ta định sử dụng đặt chỗ tĩnh, phần nào của toàn bộ
đặt phòng nó có bao gồm không? Chúng tôi tính đến không gian được sử dụng bởi giao dịch
đặt trước bằng cách theo dõi không gian hiện được đối tượng sử dụng trong CIL và
sau đó tính toán sự tăng hoặc giảm không gian được sử dụng làm đối tượng
đã đăng nhập lại. Điều này cho phép việc đặt trước điểm kiểm tra chỉ phải tính đến
siêu dữ liệu bộ đệm nhật ký được sử dụng như bản ghi tiêu đề nhật ký.

Tuy nhiên, ngay cả việc sử dụng đặt chỗ tĩnh chỉ cho siêu dữ liệu nhật ký cũng
có vấn đề. Thông thường, các tiêu đề bản ghi nhật ký sử dụng ít nhất 16KB dung lượng nhật ký cho mỗi
Đã sử dụng 1 MB dung lượng nhật ký (512 byte trên 32k) và cần phải đặt trước
đủ lớn để xử lý các giao dịch điểm kiểm tra có kích thước tùy ý. Cái này
việc đặt chỗ cần phải được thực hiện trước khi trạm kiểm soát bắt đầu và chúng tôi cần phải
có thể dành chỗ mà không cần ngủ.  Đối với điểm kiểm tra 8 MB, chúng tôi cần một
dự trữ khoảng 150KB, đây là một lượng không gian không hề nhỏ.

Việc đặt trước tĩnh cần thao tác với bộ đếm cấp nhật ký - chúng ta có thể thực hiện
đặt chỗ vĩnh viễn trên không gian, nhưng chúng tôi vẫn cần đảm bảo rằng chúng tôi làm mới
việc đặt trước ghi (không gian thực tế có sẵn cho giao dịch) sau
mỗi lần hoàn thành giao dịch điểm kiểm tra. Thật không may, nếu không gian này không
có sẵn khi được yêu cầu, sau đó mã cấp lại sẽ ngủ chờ nó.

Vấn đề với điều này là nó có thể dẫn đến bế tắc vì chúng ta có thể cần phải cam kết
điểm kiểm tra để có thể giải phóng không gian nhật ký (tham khảo lại mô tả về
giao dịch luân phiên là một ví dụ về điều này).  Do đó chúng tôi ZZ0000ZZ luôn có
không gian có sẵn trong nhật ký nếu chúng tôi sử dụng đặt chỗ tĩnh và đó là
rất khó khăn và phức tạp để sắp xếp. Có thể làm được nhưng có một
cách đơn giản hơn.

Cách đơn giản hơn để thực hiện việc này là theo dõi toàn bộ không gian nhật ký được sử dụng bởi
các mục trong CIL và sử dụng thông tin này để tính toán động lượng nhật ký
không gian được yêu cầu bởi siêu dữ liệu nhật ký. Nếu không gian siêu dữ liệu nhật ký này thay đổi dưới dạng
kết quả của một cam kết giao dịch chèn bộ đệm bộ nhớ mới vào CIL, sau đó
sự khác biệt về không gian cần thiết sẽ bị loại bỏ khỏi giao dịch gây ra
sự thay đổi. Giao dịch ở cấp độ này sẽ ZZ0000ZZ có đủ dung lượng
sẵn sàng đặt trước cho việc này vì họ đã đặt trước
lượng không gian siêu dữ liệu nhật ký tối đa mà họ yêu cầu và việc đặt trước delta như vậy
sẽ luôn nhỏ hơn hoặc bằng số tiền tối đa trong đặt phòng.

Do đó, chúng tôi có thể tăng cường đặt chỗ giao dịch tại điểm kiểm tra một cách linh hoạt dưới dạng các mục
được thêm vào CIL và tránh nhu cầu đặt trước và cấp lại không gian nhật ký
lên phía trước. Điều này tránh được tình trạng bế tắc và loại bỏ điểm chặn khỏi
mã xả điểm kiểm tra.

Như đã đề cập ở trên, các giao dịch không thể tăng lên quá một nửa quy mô của
nhật ký. Do đó, như một phần của việc đặt chỗ ngày càng tăng, chúng tôi cũng cần kiểm tra kích thước
của việc đặt trước so với quy mô giao dịch tối đa được phép. Nếu chúng ta đạt được
ngưỡng tối đa, chúng ta cần đẩy CIL vào nhật ký. Điều này có hiệu quả
"xóa nền" và được thực hiện theo yêu cầu. Điều này giống hệt với
một lực đẩy CIL được kích hoạt bởi lực log, chỉ có điều là không cần chờ đợi
điểm kiểm tra cam kết hoàn thành. Việc đẩy nền này được kiểm tra và thực thi bởi
mã cam kết giao dịch.

Nếu hệ thống con giao dịch không hoạt động trong khi chúng tôi vẫn còn các mục trong CIL,
chúng sẽ bị xóa bởi lực lượng nhật ký định kỳ do xfssyncd cấp. Nhật ký này
lực sẽ đẩy CIL vào đĩa và nếu hệ thống con giao dịch không hoạt động,
cho phép nhật ký nhàn rỗi được che phủ (được đánh dấu sạch một cách hiệu quả) theo cùng một cách
cách được thực hiện cho phương pháp ghi nhật ký hiện có. Một điểm thảo luận là
liệu lực lượng log này có cần được thực hiện thường xuyên hơn tốc độ hiện tại hay không
tức là cứ 30 giây một lần.


Ghi nhật ký bị trì hoãn: Ghim mục nhật ký
-----------------------------------------

Các mục nhật ký hiện tại được ghim trong quá trình cam kết giao dịch trong khi các mục đó được
vẫn bị khóa. Điều này xảy ra ngay sau khi các mục được định dạng, mặc dù nó có thể
được thực hiện bất cứ lúc nào trước khi các mục được mở khóa. Kết quả của cơ chế này là
các mục đó được ghim một lần cho mỗi giao dịch được cam kết vào nhật ký
bộ đệm. Do đó, các mục được đăng nhập lại vào bộ đệm nhật ký sẽ có số lượng pin
đối với mọi giao dịch chưa thanh toán mà chúng đã bị làm bẩn. Khi mỗi giao dịch này
giao dịch hoàn tất, họ sẽ bỏ ghim mục đó một lần. Kết quả là, mục
chỉ được bỏ ghim khi tất cả các giao dịch hoàn tất và không có
giao dịch đang chờ xử lý. Do đó, việc ghim và bỏ ghim một mục nhật ký là đối xứng
vì có mối quan hệ 1:1 với cam kết giao dịch và hoàn thành mục nhật ký.

Tuy nhiên, đối với việc ghi nhật ký bị trì hoãn, chúng tôi có cam kết giao dịch không đối xứng với
mối quan hệ hoàn thiện Mỗi khi một đối tượng được đăng nhập lại vào CIL, nó sẽ hoạt động
thông qua quá trình cam kết mà không đăng ký hoàn thành tương ứng.
Nghĩa là, bây giờ chúng ta có mối quan hệ nhiều-một giữa cam kết giao dịch và
hoàn thành mục nhật ký. Kết quả của việc này là việc ghim và bỏ ghim
các mục nhật ký sẽ trở nên mất cân bằng nếu chúng tôi giữ lại "ghim trên cam kết giao dịch, bỏ ghim
về mô hình hoàn thành giao dịch".

Để giữ tính đối xứng ghim/bỏ ghim, thuật toán cần thay đổi thành "ghim trên
chèn vào CIL, bỏ ghim khi hoàn thành điểm kiểm tra". Nói cách khác, sự
ghim và bỏ ghim trở nên đối xứng xung quanh bối cảnh điểm kiểm tra. Chúng tôi phải
ghim đối tượng vào lần đầu tiên nó được chèn vào CIL - nếu nó đã ở trong
CIL trong quá trình cam kết giao dịch, sau đó chúng tôi sẽ không ghim lại. Bởi vì ở đó
có thể có nhiều bối cảnh điểm kiểm tra nổi bật, chúng ta vẫn có thể thấy ghim được nâng cao
đếm, nhưng khi mỗi điểm kiểm tra hoàn thành, số lượng pin sẽ giữ nguyên chính xác
giá trị theo ngữ cảnh của nó.

Chỉ để làm cho vấn đề phức tạp hơn một chút, bối cảnh cấp điểm kiểm tra này
đối với số lượng ghim có nghĩa là việc ghim một mục phải diễn ra theo
Khóa cam kết/xóa CIL. Nếu chúng ta ghim đối tượng ra ngoài ổ khóa này thì chúng ta không thể
đảm bảo số lượng pin được liên kết với bối cảnh nào. Điều này là do
thực tế việc ghim mục này phụ thuộc vào việc mục đó có trong
CIL hiện tại hay không. Nếu chúng ta không ghim CIL trước khi kiểm tra và ghim
đối tượng, chúng ta có một cuộc đua với CIL đang bị xóa giữa séc và mã pin
(hoặc không ghim, tùy từng trường hợp). Do đó, chúng ta phải giữ lệnh xả/cam kết CIL
lock để đảm bảo rằng chúng tôi ghim các mục một cách chính xác.

Ghi nhật ký bị trì hoãn: Khả năng mở rộng đồng thời
---------------------------------------------------

Yêu cầu cơ bản đối với CIL là truy cập thông qua giao dịch
các cam kết phải mở rộng theo nhiều cam kết đồng thời. Cam kết giao dịch hiện tại
mã không bị hỏng ngay cả khi có giao dịch đến từ năm 2048
bộ xử lý cùng một lúc. Mã giao dịch hiện tại không nhanh hơn nếu
chỉ có một chiếc CPU sử dụng nó, nhưng nó cũng không bị chậm lại.

Do đó, mã cam kết giao dịch ghi nhật ký bị trì hoãn cần được thiết kế
cho sự đồng thời ngay từ đầu. Rõ ràng là có tuần tự hóa
điểm trong thiết kế - ba điểm quan trọng là:

1. Khóa các cam kết giao dịch mới trong khi xóa CIL
	2. Thêm vật phẩm vào CIL và cập nhật kế toán không gian vật phẩm
	3. Kiểm tra thứ tự cam kết

Nhìn vào cam kết giao dịch và tương tác xả CIL, có thể thấy rõ
rằng chúng ta có sự tương tác nhiều-một ở đây. Nghĩa là, hạn chế duy nhất đối với
số lượng giao dịch đồng thời có thể cố gắng thực hiện cùng một lúc là
lượng không gian có sẵn trong nhật ký dành cho việc đặt chỗ của họ. Thực tế
giới hạn ở đây là vào khoảng vài trăm giao dịch đồng thời cho một
Nhật ký 128 MB, có nghĩa là nó thường là một bản ghi cho mỗi CPU trong máy.

Lượng thời gian mà một giao dịch cam kết cần để thực hiện một lần xả là
khoảng thời gian tương đối dài - việc ghim các mục nhật ký cần phải được thực hiện
trong khi chúng tôi đang tổ chức một đợt xả CIL, vì vậy tại thời điểm này điều đó có nghĩa là nó được giữ
qua việc định dạng các đối tượng vào vùng đệm bộ nhớ (tức là trong khi memcpy()s
đang được tiến hành). Cuối cùng, một thuật toán hai lượt trong đó việc định dạng được thực hiện
riêng biệt với việc ghim các đối tượng có thể được sử dụng để giảm thời gian giữ của
bên cam kết giao dịch.

Do số lượng người nắm giữ bên cam kết giao dịch tiềm năng nên khóa
thực sự cần phải có một khóa ngủ - nếu xả CIL có khóa, chúng tôi không
muốn mọi CPU khác trong máy quay trên khóa CIL. Cho rằng
việc xóa CIL có thể liên quan đến việc xem danh sách hàng chục nghìn bản ghi
các vật phẩm, nó sẽ được giữ trong một thời gian đáng kể và vì vậy việc tranh chấp vòng quay là một
mối quan tâm đáng kể. Ngăn chặn nhiều CPU quay mà không làm gì là
lý do chính để chọn khóa ngủ mặc dù không có gì trong
cam kết giao dịch hoặc bên phẳng CIL ngủ với khóa được giữ.

Cũng cần lưu ý rằng xả nước CIL cũng là một thao tác tương đối hiếm gặp
so với cam kết giao dịch đối với khối lượng công việc giao dịch không đồng bộ - chỉ
Thời gian sẽ trả lời liệu việc sử dụng semaphore đọc-ghi để loại trừ có hạn chế hay không
giao dịch cam kết đồng thời do dòng bộ đệm bật lên của khóa trên
bên đọc.

Điểm tuần tự hóa thứ hai nằm ở phía cam kết giao dịch nơi các mục
được chèn vào CIL. Vì giao dịch có thể nhập mã này
đồng thời, CIL cần được bảo vệ riêng biệt với các thiết bị trên
loại trừ cam kết/xóa. Nó cũng cần phải là một khóa độc quyền nhưng nó chỉ
được giữ trong một thời gian rất ngắn và do đó, khóa xoay là thích hợp ở đây. Đó là
có thể khóa này sẽ trở thành điểm tranh chấp, nhưng trong thời gian ngắn
giữ thời gian một lần cho mỗi giao dịch. Tôi nghĩ rằng sự tranh chấp khó xảy ra.

Điểm tuần tự hóa cuối cùng là mã thứ tự bản ghi cam kết của điểm kiểm tra
được chạy như một phần của cam kết điểm kiểm tra và trình tự lực lượng nhật ký. Mã
đường dẫn kích hoạt tuôn ra CIL (tức là bất cứ điều gì kích hoạt lực lượng log) sẽ đi vào
một vòng lặp sắp xếp sau khi ghi tất cả các vectơ nhật ký vào bộ đệm nhật ký nhưng
trước khi viết bản ghi cam kết. Vòng lặp này đi theo danh sách cam kết
điểm kiểm tra và cần chặn chờ điểm kiểm tra hoàn thành cam kết của họ
ghi chép. Kết quả là nó cần một khóa và một biến chờ. Đăng nhập lực lượng
trình tự cũng yêu cầu cơ chế khóa, đi theo danh sách và chặn tương tự để
đảm bảo hoàn thành các điểm kiểm tra.

Hai hoạt động giải trình tự này có thể sử dụng cơ chế mặc dù
sự kiện họ đang chờ đợi là khác nhau. Bản ghi cam kết điểm kiểm tra
trình tự cần đợi cho đến khi bối cảnh điểm kiểm tra chứa LSN cam kết
(thu được thông qua việc hoàn thành ghi bản ghi cam kết) trong khi lực lượng log
trình tự cần đợi cho đến khi bối cảnh điểm kiểm tra trước đó được xóa khỏi
danh sách cam kết (tức là họ đã hoàn thành). Một biến chờ đơn giản và
phát sóng đánh thức (đàn sấm sét) đã được sử dụng để thực hiện hai điều này
hàng đợi tuần tự hóa. Họ cũng sử dụng khóa tương tự như CIL. Nếu chúng ta cũng thấy
có nhiều tranh cãi về khóa CIL hoặc có quá nhiều chuyển đổi ngữ cảnh do
các lần đánh thức phát sóng, các hoạt động này có thể được đặt dưới một khóa quay mới và
đưa ra danh sách chờ riêng biệt để giảm tranh chấp khóa và số lượng quy trình
thức dậy bởi sự kiện sai lầm.


Thay đổi vòng đời
-----------------

Vòng đời của mục nhật ký hiện tại như sau::

1. Phân bổ giao dịch
	2. Dự trữ giao dịch
	3. Khóa mục
	4. Tham gia mục để giao dịch
		Nếu chưa được đính kèm,
			Phân bổ mục nhật ký
			Đính kèm mục nhật ký vào mục chủ sở hữu
		Đính kèm mục nhật ký vào giao dịch
	5. Sửa đổi mục
		Ghi lại các sửa đổi trong mục nhật ký
	6. Cam kết giao dịch
		Ghim mục vào bộ nhớ
		Định dạng mục vào bộ đệm nhật ký
		Viết cam kết LSN vào giao dịch
		Mở khóa mục
		Đính kèm giao dịch vào bộ đệm nhật ký

<đệm nhật ký IO đã được gửi đi>
	<đăng nhập bộ đệm IO hoàn tất>

7. Hoàn tất giao dịch
		Đánh dấu mục nhật ký đã cam kết
		Chèn mục nhật ký vào AIL
			Viết cam kết LSN vào mục nhật ký
		Bỏ ghim mục nhật ký
	8. Truyền tải AIL
		Khóa mục
		Đánh dấu mục nhật ký là sạch
		Xoá mục vào đĩa

<hoàn thành mục IO>

9. Mục nhật ký bị xóa khỏi AIL
		Di chuyển đuôi khúc gỗ
		Đã mở khóa mục

Về cơ bản, các bước 1-6 hoạt động độc lập với bước 7, cũng là bước
độc lập với các bước 8-9. Một mục có thể bị khóa ở bước 1-6 hoặc bước 8-9
đồng thời bước 7 đang diễn ra nhưng chỉ có thể xảy ra bước 1-6 hoặc 8-9
cùng một lúc. Nếu mục nhật ký nằm trong AIL hoặc giữa bước 6 và 7
và các bước 1-6 được nhập lại, sau đó mục này sẽ được đăng nhập lại. Chỉ khi bước 8-9
được nhập và hoàn thành là đối tượng được coi là sạch.

Với việc ghi nhật ký bị trì hoãn, sẽ có các bước mới được đưa vào vòng đời::

1. Phân bổ giao dịch
	2. Dự trữ giao dịch
	3. Khóa mục
	4. Tham gia mục để giao dịch
		Nếu chưa được đính kèm,
			Phân bổ mục nhật ký
			Đính kèm mục nhật ký vào mục chủ sở hữu
		Đính kèm mục nhật ký vào giao dịch
	5. Sửa đổi mục
		Ghi lại các sửa đổi trong mục nhật ký
	6. Cam kết giao dịch
		Ghim mục vào bộ nhớ nếu chưa được ghim trong CIL
		Định dạng mục thành vectơ nhật ký + bộ đệm
		Đính kèm vectơ nhật ký và bộ đệm vào mục nhật ký
		Chèn mục nhật ký vào CIL
		Viết chuỗi ngữ cảnh CIL vào giao dịch
		Mở khóa mục

<lực đăng nhập tiếp theo>

7. Đẩy CIL
		khóa xả CIL
		Chuỗi các vectơ nhật ký và bộ đệm với nhau
		Xóa các mục khỏi CIL
		mở khóa CIL tuôn ra
		ghi vectơ nhật ký vào nhật ký
		bản ghi cam kết trình tự
		đính kèm bối cảnh điểm kiểm tra vào bộ đệm nhật ký

<đệm nhật ký IO đã được gửi đi>
	<đăng nhập bộ đệm IO hoàn tất>

8. Hoàn thành điểm kiểm tra
		Đánh dấu mục nhật ký đã cam kết
		Chèn mục vào AIL
			Viết cam kết LSN vào mục nhật ký
		Bỏ ghim mục nhật ký
	9. Truyền tải AIL
		Khóa mục
		Đánh dấu mục nhật ký là sạch
		Xoá mục vào đĩa
	<hoàn thành mục IO>
	10. Mục nhật ký bị xóa khỏi AIL
		Di chuyển đuôi khúc gỗ
		Đã mở khóa mục

Từ đó, có thể thấy rằng sự khác biệt duy nhất về vòng đời giữa hai loài
các phương pháp ghi nhật ký đang ở giữa vòng đời - chúng vẫn giống nhau
các ràng buộc bắt đầu, kết thúc và thực hiện. Sự khác biệt duy nhất là ở
cam kết các mục nhật ký vào chính nhật ký đó và quá trình xử lý hoàn thành.
Do đó việc ghi nhật ký bị trì hoãn sẽ không gây ra bất kỳ ràng buộc nào đối với mục nhật ký
hành vi, phân bổ hoặc giải phóng chưa tồn tại.

Nhờ việc "chèn" cơ sở hạ tầng ghi nhật ký bị trì hoãn không có tác động này
và thiết kế cấu trúc bên trong để tránh những thay đổi về định dạng đĩa, chúng tôi
về cơ bản có thể chuyển đổi giữa ghi nhật ký bị trì hoãn và cơ chế hiện có bằng một
tùy chọn gắn kết. Về cơ bản, không có lý do gì mà trình quản lý nhật ký lại không
có thể trao đổi phương thức một cách tự động và minh bạch tùy theo tải
đặc điểm, nhưng điều này không cần thiết nếu việc ghi nhật ký bị trì hoãn hoạt động như
được thiết kế.