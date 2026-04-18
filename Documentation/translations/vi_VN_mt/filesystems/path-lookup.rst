.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/path-lookup.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================
Tra cứu tên đường dẫn
===============

Bài viết này dựa trên ba bài báo được xuất bản tại lwn.net:

- <ZZ0000ZZ Tra cứu tên đường dẫn trong Linux
- <ZZ0001ZZ RCU-walk: tra cứu tên đường dẫn nhanh hơn trong Linux
- <ZZ0002ZZ Đi dạo giữa các liên kết tượng trưng

Được viết bởi Neil Brown với sự trợ giúp của Al Viro và Jon Corbet.
Sau đó nó đã được cập nhật để phản ánh những thay đổi trong kernel
bao gồm:

- tra cứu tên song song trên mỗi thư mục.
- Cờ hạn chế độ phân giải ZZ0000ZZ.

Giới thiệu về tra cứu tên đường dẫn
===============================

Khía cạnh rõ ràng nhất của việc tra cứu tên đường dẫn, rất ít
cần phải khám phá để khám phá, đó là điều phức tạp.  có
nhiều quy tắc, trường hợp đặc biệt và các lựa chọn thay thế thực hiện mà tất cả đều
kết hợp lại khiến người đọc vô tình bối rối.  Khoa học máy tính từ lâu đã
làm quen với sự phức tạp như vậy và có các công cụ để giúp quản lý nó.  một
công cụ mà chúng tôi sẽ sử dụng rộng rãi là "phân chia và chinh phục".  cho
phần đầu của phân tích chúng tôi sẽ chia ra các liên kết tượng trưng - để lại
chúng cho đến phần cuối cùng.  Vâng, trước khi chúng ta có được các liên kết tượng trưng, ​​chúng ta có
một bộ phận chính khác dựa trên phương pháp khóa của VFS
sẽ cho phép chúng tôi xem xét riêng "REF-walk" và "RCU-walk".  Nhưng chúng tôi
đang đi trước chúng ta.  Có một số mức độ quan trọng thấp
sự khác biệt chúng ta cần làm rõ trước tiên.

Có hai loại...
--------------------------

.. _openat: http://man7.org/linux/man-pages/man2/openat.2.html

Tên đường dẫn (đôi khi là "tên tệp"), được sử dụng để xác định các đối tượng trong
hệ thống tập tin, sẽ quen thuộc với hầu hết độc giả.  Chúng chứa hai loại
của các phần tử: "dấu gạch chéo" là chuỗi của một hoặc nhiều "ZZ0000ZZ"
ký tự và "thành phần" là chuỗi của một hoặc nhiều
các ký tự không phải "ZZ0001ZZ".  Những hình thức này tạo thành hai loại con đường.  Những cái đó
bắt đầu bằng dấu gạch chéo là "tuyệt đối" và bắt đầu từ gốc hệ thống tập tin.
Những cái khác là "tương đối" và bắt đầu từ thư mục hiện tại, hoặc
từ một số vị trí khác được chỉ định bởi bộ mô tả tệp được cung cấp cho
Các lệnh gọi hệ thống "ZZ0002ZZ" chẳng hạn như ZZ0003ZZ.

.. _execveat: http://man7.org/linux/man-pages/man2/execveat.2.html

Thật thú vị khi mô tả loại thứ hai là bắt đầu bằng một
thành phần, nhưng điều đó không phải lúc nào cũng chính xác: tên đường dẫn có thể thiếu cả hai
dấu gạch chéo và các thành phần, nói cách khác, nó có thể trống.  Đây là
thường bị cấm trong POSIX, nhưng một số lệnh gọi hệ thống "ZZ0000ZZ" đó
trong Linux cho phép điều đó khi cờ ZZ0001ZZ được đưa ra.  cho
Ví dụ: nếu bạn có một bộ mô tả tệp đang mở trên một tệp thi hành, bạn
có thể thực thi nó bằng cách gọi ZZ0003ZZ đi qua
bộ mô tả tệp, đường dẫn trống và cờ ZZ0002ZZ.

Những đường dẫn này có thể được chia thành hai phần: thành phần cuối cùng và
mọi thứ khác.  "Mọi thứ khác" là một chút dễ dàng.  Trong mọi trường hợp
nó phải xác định một thư mục đã tồn tại, nếu không sẽ có lỗi
chẳng hạn như ZZ0000ZZ hoặc ZZ0001ZZ sẽ được báo cáo.

Thành phần cuối cùng không đơn giản như vậy.  Không chỉ làm hệ thống khác nhau
các cuộc gọi diễn giải nó hoàn toàn khác nhau (ví dụ: một số tạo ra nó, một số làm
không), nhưng nó thậm chí có thể không tồn tại: cả tên đường dẫn trống lẫn tên
tên đường dẫn chỉ là dấu gạch chéo có thành phần cuối cùng.  Nếu có
tồn tại, nó có thể là "ZZ0000ZZ" hoặc "ZZ0001ZZ" được xử lý hoàn toàn khác
từ các thành phần khác.

.. _POSIX: https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap04.html#tag_04_12

Nếu tên đường dẫn kết thúc bằng dấu gạch chéo, chẳng hạn như "ZZ0000ZZ" thì đó có thể là
hấp dẫn để xem xét rằng có một thành phần cuối cùng trống rỗng.  Ở nhiều nơi
những cách có thể dẫn đến kết quả đúng, nhưng không phải lúc nào cũng vậy.  trong
cụ thể, mỗi ZZ0001ZZ và ZZ0002ZZ đều tạo hoặc xóa một thư mục có tên
bởi thành phần cuối cùng và chúng được yêu cầu làm việc với tên đường dẫn
kết thúc bằng "ZZ0003ZZ".  Theo POSIX_:

Tên đường dẫn chứa ít nhất một ký tự không phải <slash> và
  kết thúc bằng một hoặc nhiều ký tự <dấu gạch chéo> ở cuối sẽ không
  được giải quyết thành công trừ khi thành phần tên đường dẫn cuối cùng trước
  các ký tự <slash> ở cuối đặt tên cho một thư mục hiện có hoặc một
  mục nhập thư mục sẽ được tạo cho một thư mục ngay lập tức
  sau khi tên đường dẫn được giải quyết.

Mã đi bộ tên đường dẫn Linux (chủ yếu ở ZZ0000ZZ) đề cập đến
tất cả những vấn đề này: chia đường dẫn thành các thành phần, xử lý
"mọi thứ khác" hoàn toàn tách biệt với thành phần cuối cùng và
kiểm tra xem dấu gạch chéo ở cuối không được sử dụng ở nơi không có
được phép.  Nó cũng giải quyết vấn đề quan trọng của việc đồng thời
truy cập.

Trong khi một tiến trình đang tìm kiếm tên đường dẫn thì một tiến trình khác có thể đang thực hiện
những thay đổi ảnh hưởng đến việc tra cứu đó.  Một trường hợp khá cực đoan là nếu
"a/b" được đổi tên thành "a/c/b" trong khi một quy trình khác đang tra cứu
"a/b/..", quá trình đó có thể giải quyết thành công trên "a/c".
Hầu hết các chủng tộc đều tinh tế hơn nhiều và một phần lớn nhiệm vụ của
tra cứu tên đường dẫn là để ngăn chặn chúng có tác hại.  Nhiều
của các chủng tộc có thể được nhìn thấy rõ ràng nhất trong bối cảnh của
"dcache" và sự hiểu biết về điều đó là trọng tâm của sự hiểu biết
tra cứu tên đường dẫn.

Không chỉ là một bộ đệm
----------------------

"dcache" lưu trữ thông tin về tên trong mỗi hệ thống tập tin vào
làm cho chúng nhanh chóng có sẵn để tra cứu.  Mỗi mục (được gọi là một
"dentry") chứa ba trường quan trọng: tên thành phần,
con trỏ tới nha khoa gốc và một con trỏ tới "inode"
chứa thêm thông tin về đối tượng trong cha mẹ đó với
tên đã cho.  Con trỏ inode có thể là ZZ0000ZZ chỉ ra rằng
tên không tồn tại trong cha mẹ.  Mặc dù có thể có sự liên kết trong
nha khoa của một thư mục đến các nha khoa của trẻ em, mối liên kết đó là
không được sử dụng để tra cứu tên đường dẫn và do đó sẽ không được xem xét ở đây.

Dcache có một số công dụng ngoài việc tăng tốc tra cứu.  một
điều đặc biệt có liên quan là nó được tích hợp chặt chẽ
với bảng gắn kết ghi lại hệ thống tập tin nào được gắn ở đâu.
Những gì bảng gắn thực sự lưu trữ là răng nào được gắn trên cùng
trong đó có nha khoa khác.

Khi xem xét dcache, chúng tôi có một trong "hai loại" khác
sự khác biệt: có hai loại hệ thống tập tin.

Một số hệ thống tập tin đảm bảo rằng thông tin trong dcache luôn được
hoàn toàn chính xác (mặc dù không nhất thiết phải đầy đủ).  Điều này có thể cho phép
VFS để xác định xem một tệp cụ thể có tồn tại hay không
mà không cần kiểm tra hệ thống tập tin và có nghĩa là VFS có thể
bảo vệ hệ thống tập tin chống lại các chủng tộc nhất định và các vấn đề khác.
Đây thường là các hệ thống tệp "cục bộ" như ext3, XFS và Btrfs.

Các hệ thống tập tin khác không cung cấp sự đảm bảo đó vì chúng không thể.
Đây thường là các hệ thống tập tin được chia sẻ trên mạng,
cho dù các hệ thống tệp từ xa như NFS và 9P hay hệ thống tệp cụm
như ocfs2 hoặc cephfs.  Các hệ thống tập tin này cho phép VFS xác nhận lại
thông tin được lưu trữ trong bộ nhớ đệm và phải cung cấp sự bảo vệ riêng của họ chống lại
những cuộc đua vụng về.  VFS có thể phát hiện các hệ thống tập tin này bằng cách
Cờ ZZ0000ZZ đang được đặt trong nha khoa.

REF-walk: quản lý đồng thời đơn giản với tính năng đếm lại và khóa quay
--------------------------------------------------------------------

Với tất cả các bộ phận được phân loại cẩn thận, bây giờ chúng ta có thể bắt đầu
nhìn vào quá trình thực tế của việc đi dọc theo một con đường.  Đặc biệt
chúng ta sẽ bắt đầu với việc xử lý phần "mọi thứ khác" của một
tên đường dẫn và tập trung vào cách tiếp cận đồng thời "REF-walk"
quản lý.  Mã này được tìm thấy trong hàm ZZ0000ZZ, nếu
bạn bỏ qua tất cả những nơi chỉ chạy khi "ZZ0001ZZ"
(biểu thị việc sử dụng RCU-walk) được thiết lập.

.. _Meet the Lockers: https://lwn.net/Articles/453685/

REF-walk khá nặng tay với các ổ khóa và số lượng tham chiếu.  Không
nặng tay như ngày xưa "khóa hạt nhân lớn" nhưng chắc chắn là không
sợ lấy chìa khóa khi cần thiết.  Nó sử dụng nhiều loại
điều khiển đồng thời khác nhau.  Một sự hiểu biết nền tảng về
nhiều nguyên thủy khác nhau được giả định, hoặc có thể được thu thập từ nơi khác như
như trong ZZ0000ZZ.

Các cơ chế khóa được REF-walk sử dụng bao gồm:

nha khoa->d_lockref
~~~~~~~~~~~~~~~~~

Điều này sử dụng nguyên hàm lockref để cung cấp cả spinlock và
số lượng tham khảo  Nước sốt đặc biệt của người nguyên thủy này chính là
trình tự khái niệm "lock; inc_ref; unlock;" thường có thể được thực hiện
với một hoạt động bộ nhớ nguyên tử duy nhất.

Giữ một tài liệu tham khảo trên nha khoa đảm bảo rằng nha khoa sẽ không đột ngột
được giải phóng và sử dụng cho mục đích khác, vì vậy các giá trị trong các trường khác nhau
sẽ hành xử như mong đợi.  Nó cũng bảo vệ tham chiếu ZZ0000ZZ
đến inode ở một mức độ nào đó.

Sự liên kết giữa một nha khoa và nút của nó khá lâu dài.
Ví dụ: khi một tập tin được đổi tên, nha khoa và inode sẽ di chuyển
cùng đến địa điểm mới.  Khi một tập tin được tạo ra, nha khoa sẽ
ban đầu có giá trị âm (tức là ZZ0000ZZ là ZZ0001ZZ) và sẽ được gán
tới inode mới như một phần của hành động sáng tạo.

Khi một tập tin bị xóa, điều này có thể được phản ánh trong bộ đệm bằng cách
đặt ZZ0000ZZ thành ZZ0001ZZ hoặc bằng cách xóa nó khỏi bảng băm
(được mô tả ngắn gọn) dùng để tra cứu tên trong thư mục mẹ.
Nếu nha khoa vẫn đang được sử dụng thì tùy chọn thứ hai sẽ được sử dụng như hiện tại
hoàn toàn hợp pháp để tiếp tục sử dụng một tập tin đang mở sau khi nó đã bị xóa
và có răng giả xung quanh sẽ giúp ích.  Nếu nha khoa không ở vị trí khác
sử dụng (tức là nếu số tiền hoàn lại trong ZZ0002ZZ là một), chỉ khi đó mới
ZZ0003ZZ được đặt thành ZZ0004ZZ.  Làm theo cách này sẽ hiệu quả hơn
trường hợp rất phổ biến.

Vì vậy, miễn là một tham chiếu được tính được giữ ở một nha khoa, một ZZ0000ZZ ZZ0001ZZ không phải là ZZ0000ZZ
giá trị sẽ không bao giờ thay đổi.

nha khoa->d_lock
~~~~~~~~~~~~~~

ZZ0000ZZ là từ đồng nghĩa với spinlock là một phần của ZZ0001ZZ ở trên.
Vì mục đích của chúng tôi, việc giữ khóa này sẽ bảo vệ răng khỏi bị
được đổi tên hoặc hủy liên kết.  Đặc biệt, cha mẹ của nó (ZZ0002ZZ) và
tên (ZZ0003ZZ) không thể thay đổi và không thể xóa nó khỏi
bảng băm nha khoa.

Khi tìm kiếm tên trong một thư mục, REF-walk sẽ đưa ZZ0000ZZ vào
mỗi nha khoa ứng cử viên mà nó tìm thấy trong bảng băm và sau đó kiểm tra
rằng cha mẹ và tên là chính xác.  Vì vậy, nó không khóa cha mẹ
trong khi tìm kiếm trong bộ đệm; nó chỉ khóa trẻ em.

Khi tìm tên cha cho một tên cụ thể (để xử lý "ZZ0000ZZ"),
REF-walk có thể mất ZZ0001ZZ để có được tham chiếu ổn định đến ZZ0002ZZ,
nhưng trước tiên nó sẽ thử một cách tiếp cận nhẹ nhàng hơn.  Như đã thấy trong
ZZ0003ZZ, nếu tài liệu tham khảo có thể được yêu cầu đối với phụ huynh và nếu
sau đó có thể thấy ZZ0004ZZ không thay đổi, thì có
thực sự không cần phải khóa đứa trẻ.

đổi tên_lock
~~~~~~~~~~~

Tra cứu một tên nhất định trong một thư mục nhất định liên quan đến việc tính toán hàm băm
từ hai giá trị (tên và mục nhập của thư mục),
truy cập vị trí đó trong bảng băm và tìm kiếm danh sách được liên kết
được tìm thấy ở đó.

Khi một nha khoa được đổi tên, cả tên và nha khoa gốc đều có thể
thay đổi nên hàm băm gần như chắc chắn cũng sẽ thay đổi.  Điều này sẽ di chuyển
dentry tới một chuỗi khác trong bảng băm.  Nếu tìm kiếm tên tập tin
tình cờ nhìn thấy một chiếc răng giả được di chuyển theo cách này,
nó có thể sẽ tiếp tục tìm kiếm sai chuỗi,
và do đó bỏ lỡ một phần của chuỗi chính xác.

Quá trình tra cứu tên (ZZ0000ZZ) ZZ0003ZZ cố gắng ngăn chặn điều này
xảy ra mà chỉ để phát hiện khi nó xảy ra.
ZZ0001ZZ là một seqlock được cập nhật bất cứ khi nào có bất kỳ răng giả nào được
được đổi tên.  Nếu ZZ0002ZZ thấy rằng việc đổi tên đã xảy ra trong khi nó
quét chuỗi trong bảng băm không thành công, nó chỉ cần thử
một lần nữa.

ZZ0000ZZ cũng được sử dụng để phát hiện và phòng thủ trước các cuộc tấn công tiềm ẩn
chống lại ZZ0001ZZ và ZZ0002ZZ khi phân giải ".." (trong đó
thư mục mẹ được di chuyển ra ngoài thư mục gốc, bỏ qua ZZ0003ZZ
kiểm tra). Nếu ZZ0004ZZ được cập nhật trong quá trình tra cứu và gặp đường dẫn
a "..", một cuộc tấn công tiềm tàng đã xảy ra và ZZ0005ZZ sẽ giải cứu bằng
ZZ0006ZZ.

inode->i_rwsem
~~~~~~~~~~~~~~

ZZ0000ZZ là một semaphore đọc/ghi tuần tự hóa tất cả các thay đổi đối với một
thư mục.  Điều này đảm bảo rằng, ví dụ, ZZ0001ZZ và ZZ0002ZZ
cả hai không thể xảy ra cùng một lúc.  Nó cũng giữ thư mục
ổn định trong khi hệ thống tập tin được yêu cầu tra cứu tên không
hiện tại trong dcache hoặc, tùy chọn, khi danh sách các mục trong một
thư mục đang được truy xuất bằng ZZ0003ZZ.

Điều này có vai trò bổ sung cho vai trò của ZZ0000ZZ: ZZ0001ZZ trên
thư mục bảo vệ tất cả các tên trong thư mục đó, trong khi ZZ0002ZZ
trên một tên chỉ bảo vệ một tên trong một thư mục.  Hầu hết các thay đổi về
dcache giữ ZZ0003ZZ trên inode thư mục liên quan và nhanh chóng lấy
ZZ0004ZZ trên một hoặc nhiều răng giả trong khi thay đổi diễn ra.  một
ngoại lệ là khi các răng giả không hoạt động được xóa khỏi dcache do
áp lực trí nhớ  Cái này sử dụng ZZ0005ZZ, nhưng ZZ0006ZZ không có vai trò gì.

Semaphore ảnh hưởng đến việc tra cứu tên đường dẫn theo hai cách riêng biệt.  Đầu tiên nó
ngăn chặn những thay đổi trong quá trình tra cứu tên trong một thư mục.  ZZ0000ZZ sử dụng
ZZ0001ZZ trước tiên sẽ kiểm tra xem tên đó có trong bộ đệm hay không,
chỉ sử dụng khóa ZZ0002ZZ.  Nếu không tìm thấy tên thì ZZ0003ZZ
quay trở lại ZZ0004ZZ có khóa chung trên ZZ0005ZZ, kiểm tra lại xem
tên đó không có trong bộ đệm và sau đó gọi vào hệ thống tập tin để nhận
câu trả lời dứt khoát.  Một nha khoa mới sẽ được thêm vào bộ đệm bất kể
kết quả.

Thứ hai, khi tra cứu tên đường dẫn đến thành phần cuối cùng, nó sẽ
đôi khi cần phải có một khóa độc quyền trên ZZ0000ZZ trước khi thực hiện tra cứu lần cuối
rằng có thể đạt được sự loại trừ cần thiết.  Cách tra cứu đường dẫn chọn
lấy hoặc không lấy, ZZ0001ZZ là một trong những
vấn đề được đề cập ở phần tiếp theo.

Nếu hai luồng cố gắng tra cứu cùng một tên cùng một lúc - a
tên chưa có trong dcache - khóa chia sẻ trên ZZ0000ZZ sẽ
không ngăn cản cả hai thêm các răng mới có cùng tên.  Như thế này
sẽ gây nhầm lẫn khi sử dụng mức độ khóa liên động bổ sung,
dựa trên bảng băm thứ cấp (ZZ0001ZZ) và
bit cờ mỗi nha (ZZ0002ZZ).

Để thêm một nha khoa mới vào bộ đệm trong khi chỉ giữ khóa chung
ZZ0000ZZ, một thread phải gọi ZZ0001ZZ.  Điều này phân bổ một
nha khoa, lưu trữ tên được yêu cầu và cha mẹ trong đó, kiểm tra xem có
đã là một nha khoa phù hợp trong hàm băm chính hoặc phụ
các bảng, và nếu không, sẽ lưu trữ nha khoa mới được phân bổ trong bảng thứ cấp
bảng băm, với bộ ZZ0002ZZ.

Nếu tìm thấy một răng phù hợp trong bảng băm chính thì đó là
được trả về và người gọi có thể biết rằng nó đã thua trong cuộc đua với một số khác
chủ đề thêm mục nhập.  Nếu không tìm thấy răng giả phù hợp ở một trong hai
bộ đệm, nha khoa mới được phân bổ sẽ được trả về và người gọi có thể
phát hiện điều này từ sự hiện diện của ZZ0000ZZ.  Trong trường hợp này nó
biết rằng nó đã thắng bất kỳ cuộc đua nào và bây giờ có trách nhiệm yêu cầu
hệ thống tập tin để thực hiện tra cứu và tìm inode phù hợp.  Khi nào
việc tra cứu hoàn tất, nó phải gọi ZZ0001ZZ để xóa
lá cờ và thực hiện một số công việc trông nhà khác, bao gồm cả việc dỡ bỏ lá cờ
nha khoa từ bảng băm thứ cấp - thông thường nó sẽ được
đã được thêm vào bảng băm chính rồi.  Lưu ý rằng ZZ0002ZZ được chuyển tới ZZ0003ZZ và
ZZ0004ZZ phải được gọi trong khi ZZ0005ZZ này vẫn còn
trong phạm vi.

Nếu tìm thấy một răng phù hợp trong bảng băm phụ,
ZZ0000ZZ còn một chút việc phải làm. Đầu tiên nó chờ đợi
ZZ0001ZZ sẽ bị xóa, sử dụng wait_queue đã được thông qua
ví dụ về ZZ0002ZZ đã thắng cuộc đua và điều đó
sẽ được đánh thức bởi cuộc gọi đến ZZ0003ZZ.  Sau đó nó kiểm tra xem
nếu nha khoa bây giờ đã được thêm vào bảng băm chính.  Nếu nó
có, chiếc răng giả sẽ được trả lại và người gọi chỉ thấy rằng nó đã bị mất bất kỳ thứ gì
cuộc đua.  Nếu nó chưa được thêm vào bảng băm chính, thì hầu hết
lời giải thích có thể là một số răng giả khác đã được thêm vào thay vì sử dụng
ZZ0004ZZ.  Trong mọi trường hợp, ZZ0005ZZ lặp lại tất cả
tra cứu từ đầu và thường sẽ trả lại thứ gì đó từ
bảng băm chính.

mnt->mnt_count
~~~~~~~~~~~~~~

ZZ0000ZZ là bộ đếm tham chiếu trên mỗi CPU trên cấu trúc "ZZ0001ZZ".
Per-CPU ở đây có nghĩa là việc tăng số lượng sẽ rẻ vì nó chỉ
sử dụng bộ nhớ cục bộ CPU, nhưng việc kiểm tra xem số đếm có bằng 0 hay không thì tốn kém vì
nó cần kiểm tra với mọi CPU.  Lấy tham chiếu ZZ0002ZZ
ngăn không cho cấu trúc gắn kết biến mất do sử dụng thường xuyên
thao tác ngắt kết nối, nhưng không ngăn chặn việc ngắt kết nối "lười biếng".  Vì vậy đang nắm giữ
ZZ0003ZZ không đảm bảo rằng giá trị gắn kết vẫn còn trong không gian tên và,
đặc biệt là không ổn định được liên kết với ngà răng gắn trên.  Nó
tuy nhiên, đảm bảo rằng cấu trúc dữ liệu ZZ0004ZZ vẫn mạch lạc,
và nó cung cấp một tham chiếu đến răng giả gốc của răng được gắn
hệ thống tập tin.  Vì vậy, tham chiếu qua ZZ0005ZZ mang lại sự ổn định
tham chiếu đến hàm răng được gắn chứ không phải hàm răng được gắn trên.

mount_lock
~~~~~~~~~~

ZZ0000ZZ là một seqlock toàn cầu, hơi giống ZZ0001ZZ.  Nó có thể được sử dụng để
kiểm tra xem có bất kỳ thay đổi nào đã được thực hiện đối với bất kỳ điểm gắn kết nào không.

Khi đi xuống cây (cách xa gốc) khóa này được sử dụng khi
băng qua một điểm gắn kết để kiểm tra xem việc băng qua có an toàn không.  Đó là,
giá trị trong seqlock được đọc, sau đó mã sẽ tìm thấy giá trị gắn kết đó
được gắn vào thư mục hiện tại, nếu có, và tăng dần
ZZ0000ZZ.  Cuối cùng, giá trị trong ZZ0001ZZ được kiểm tra
giá trị cũ.  Nếu không có thay đổi thì việc vượt biển đã an toàn.  Nếu có
là một sự thay đổi, ZZ0002ZZ bị giảm đi và toàn bộ quá trình được
đã thử lại.

Khi đi lên cây (về phía gốc) bằng cách đi theo liên kết "..",
cần phải chăm sóc nhiều hơn một chút.  Trong trường hợp này, seqlock (mà
chứa cả bộ đếm và khóa xoay) được khóa hoàn toàn để ngăn chặn
bất kỳ thay đổi nào đối với bất kỳ điểm gắn kết nào trong khi nâng cấp.  Khóa này là
cần thiết để ổn định liên kết với ngà răng gắn trên, mà
Việc hoàn lại tiền trên bản thân thú cưỡi không đảm bảo.

ZZ0000ZZ cũng được sử dụng để phát hiện và phòng thủ trước các cuộc tấn công tiềm ẩn
chống lại ZZ0001ZZ và ZZ0002ZZ khi phân giải ".." (trong đó
thư mục mẹ được di chuyển ra ngoài thư mục gốc, bỏ qua ZZ0003ZZ
kiểm tra). Nếu ZZ0004ZZ được cập nhật trong quá trình tra cứu và gặp đường dẫn
a "..", một cuộc tấn công tiềm tàng đã xảy ra và ZZ0005ZZ sẽ giải cứu bằng
ZZ0006ZZ.

RCU
~~~

Cuối cùng, khóa đọc RCU toàn cầu (nhưng cực kỳ nhẹ) được giữ
theo thời gian để đảm bảo một số cấu trúc dữ liệu nhất định không bị giải phóng
một cách bất ngờ.

Đặc biệt, nó được giữ trong khi quét chuỗi trong hàm băm dcache
bảng và bảng băm điểm gắn kết.

Kết hợp nó với ZZ0000ZZ
----------------------------------------------

.. _First edition Unix: https://minnie.tuhs.org/cgi-bin/utree.pl?file=V1/u2.s

Trong suốt quá trình đi trên một con đường, trạng thái hiện tại được lưu trữ
trong ZZ0000ZZ, "namei" là tên truyền thống - hẹn hò
hoàn toàn quay trở lại ZZ0002ZZ - của chức năng
chuyển đổi "tên" thành "inode".  ZZ0001ZZ chứa (trong số
lĩnh vực khác):

ZZ0000ZZ
~~~~~~~~~~~~~~~~~~~~

ZZ0000ZZ chứa ZZ0001ZZ (là
được nhúng trong ZZ0002ZZ) và ZZ0003ZZ.  Cùng với nhau những điều này
ghi lại tình trạng hiện tại của cuộc đi bộ.  Họ bắt đầu đề cập đến
điểm bắt đầu (thư mục làm việc hiện tại, thư mục gốc hoặc một số thư mục khác
thư mục được xác định bởi bộ mô tả tệp) và được cập nhật trên mỗi
bước.  Luôn luôn có một tham chiếu qua ZZ0004ZZ và ZZ0005ZZ
được tổ chức.

ZZ0000ZZ
~~~~~~~~~~~~~~~~~~~~

Đây là một chuỗi cùng với độ dài (tức là ZZ0001ZZ ZZ0000ZZ đã kết thúc)
đó là thành phần "tiếp theo" trong tên đường dẫn.

ZZ0000ZZ
~~~~~~~~~~~~~~~~~

Đây là một trong những ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ hoặc ZZ0003ZZ.
Trường ZZ0004ZZ chỉ hợp lệ nếu loại là ZZ0005ZZ.

ZZ0000ZZ
~~~~~~~~~~~~~~~~~~~~

Điều này được sử dụng để giữ một tham chiếu đến gốc hiệu quả của
hệ thống tập tin.  Thông thường, tham chiếu đó sẽ không cần thiết, vì vậy trường này
chỉ được gán vào lần đầu tiên nó được sử dụng hoặc khi một root không chuẩn
được yêu cầu.  Giữ một tài liệu tham khảo trong ZZ0000ZZ đảm bảo rằng
chỉ có một gốc có hiệu lực cho toàn bộ đường đi bộ, ngay cả khi nó chạy đua
với lệnh gọi hệ thống ZZ0001ZZ.

Cần lưu ý rằng trong trường hợp ZZ0000ZZ hoặc
ZZ0001ZZ, root hiệu quả sẽ trở thành bộ mô tả tệp thư mục
được chuyển tới ZZ0002ZZ (hiển thị các cờ ZZ0003ZZ này).

Cần có gốc khi một trong hai điều kiện thỏa mãn: (1) hoặc
tên đường dẫn hoặc liên kết tượng trưng bắt đầu bằng "'/'" hoặc (2) "ZZ0000ZZ"
thành phần đang được xử lý, vì "ZZ0001ZZ" từ gốc phải luôn ở lại
ở gốc.  Giá trị được sử dụng thường là thư mục gốc hiện tại của
quá trình gọi điện.  Một gốc thay thế có thể được cung cấp như khi
ZZ0002ZZ gọi ZZ0003ZZ và khi NFSv4 hoặc Btrfs gọi
ZZ0004ZZ.  Trong mỗi trường hợp, tên đường dẫn được tra cứu theo cách rất
phần cụ thể của hệ thống tập tin và việc tra cứu không được phép
thoát khỏi cây con đó.  Nó hoạt động hơi giống ZZ0005ZZ cục bộ.

Bỏ qua việc xử lý các liên kết tượng trưng, bây giờ chúng ta có thể mô tả
Chức năng "ZZ0000ZZ", xử lý việc tra cứu mọi thứ
ngoại trừ thành phần cuối cùng là:

Cho một đường dẫn (ZZ0000ZZ) và cấu trúc tênidata (ZZ0001ZZ), hãy kiểm tra xem
   thư mục hiện tại có quyền thực thi và sau đó nâng cấp ZZ0002ZZ
   trên một thành phần trong khi cập nhật ZZ0003ZZ và ZZ0004ZZ.  Nếu đó
   là thành phần cuối cùng, sau đó trả về, nếu không thì gọi
   ZZ0005ZZ và lặp lại từ trên xuống.

ZZ0000ZZ thậm chí còn dễ dàng hơn.  Nếu thành phần là ZZ0001ZZ,
nó gọi ZZ0002ZZ để thực hiện khóa cần thiết
được mô tả.  Nếu nó tìm thấy thành phần ZZ0003ZZ, trước tiên nó sẽ gọi
"ZZ0004ZZ" chỉ tìm trong dcache nhưng sẽ hỏi
hệ thống tập tin để xác nhận lại kết quả nếu đó là loại hệ thống tập tin.
Nếu điều đó không mang lại kết quả tốt, nó sẽ gọi "ZZ0005ZZ"
lấy ZZ0006ZZ, kiểm tra lại bộ đệm và sau đó hỏi hệ thống tập tin
để tìm ra câu trả lời dứt khoát.

Là bước cuối cùng của walk_comComponent(), step_into() sẽ được gọi
trực tiếp từ walk_comComponent() hoặc từ hand_dots().  Nó gọi
hand_mounts(), để kiểm tra và xử lý các điểm gắn kết, trong đó một điểm mới
ZZ0000ZZ được tạo có chứa tham chiếu được tính đến nha khoa mới và
tham chiếu đến ZZ0001ZZ mới chỉ được tính nếu nó
khác với ZZ0002ZZ trước đây. Sau đó nếu có
một liên kết tượng trưng, step_into() gọi pick_link() để xử lý nó,
nếu không nó sẽ cài đặt ZZ0003ZZ mới vào ZZ0004ZZ, và
bỏ các tài liệu tham khảo không cần thiết.

Trình tự "trao tay" này để có được một tham chiếu đến cái mới
nha khoa trước khi bỏ tham chiếu đến nha khoa trước đó có thể
có vẻ hiển nhiên nhưng đáng được chỉ ra để chúng ta nhận ra nó
tương tự trong phiên bản "RCU-walk".

Xử lý thành phần cuối cùng
----------------------------

ZZ0000ZZ chỉ đi xa đến mức cài đặt ZZ0001ZZ và
ZZ0002ZZ để chỉ thành phần cuối cùng của đường dẫn.  Nó có
lần trước đừng gọi ZZ0003ZZ như vậy nữa.  Xử lý trận chung kết đó
thành phần vẫn còn để người gọi sắp xếp. Những người gọi đó là
path_lookupat(), path_parentat() và
path_openat() mỗi cái xử lý các yêu cầu khác nhau của
các cuộc gọi hệ thống khác nhau.

ZZ0000ZZ rõ ràng là đơn giản nhất - nó chỉ gói gọn một chút
dọn phòng xung quanh ZZ0001ZZ và trả lại cha mẹ
thư mục và thành phần cuối cùng cho người gọi.  Người gọi sẽ là
nhằm mục đích tạo tên (thông qua ZZ0002ZZ) hoặc xóa hoặc đổi tên
một tên (trong trường hợp đó ZZ0003ZZ được sử dụng).  Họ sẽ sử dụng
ZZ0004ZZ để loại trừ các thay đổi khác trong khi chúng xác thực và sau đó
thực hiện hoạt động của họ.

ZZ0000ZZ gần như đơn giản - nó được sử dụng khi một hệ thống hiện có
đối tượng được truy nã chẳng hạn như ZZ0001ZZ hoặc ZZ0002ZZ.  Về cơ bản nó chỉ
gọi ZZ0003ZZ trên thành phần cuối cùng thông qua lệnh gọi tới
ZZ0004ZZ.  ZZ0005ZZ chỉ trả lại chiếc răng giả cuối cùng.
Điều đáng chú ý là khi cờ ZZ0006ZZ được đặt,
path_lookupat() sẽ bỏ đặt LOOKUP_JUMPED trong nameidata để trong
truyền tải đường dẫn tiếp theo d_weak_revalidate() sẽ không được gọi.
Điều này rất quan trọng khi ngắt kết nối một hệ thống tập tin không thể truy cập được, chẳng hạn như
một cái được cung cấp bởi một máy chủ NFS đã chết.

Cuối cùng ZZ0000ZZ được sử dụng cho lệnh gọi hệ thống ZZ0001ZZ; nó
chứa, trong các hàm hỗ trợ bắt đầu bằng "open_last_lookups()", tất cả
độ phức tạp cần thiết để xử lý các chi tiết khác nhau của O_CREAT (với
hoặc không có O_EXCL), ký tự "ZZ0002ZZ" cuối cùng và ký hiệu ở cuối
liên kết.  Chúng ta sẽ xem lại điều này trong phần cuối cùng của loạt bài này, trong đó
tập trung vào những liên kết tượng trưng đó.  "open_last_lookups()" đôi khi sẽ xảy ra, nhưng
không phải lúc nào cũng vậy, hãy lấy ZZ0003ZZ, tùy thuộc vào những gì nó tìm thấy.

Mỗi chức năng này hoặc các chức năng gọi chúng cần phải cảnh giác với
khả năng thành phần cuối cùng không phải là ZZ0000ZZ.  Nếu
mục tiêu của việc tra cứu là tạo ra thứ gì đó, sau đó bất kỳ giá trị nào cho
ZZ0001ZZ không phải ZZ0002ZZ sẽ gây ra lỗi.  cho
ví dụ nếu ZZ0003ZZ báo cáo ZZ0004ZZ thì người gọi
sẽ không cố gắng tạo ra cái tên đó.  Họ cũng kiểm tra dấu gạch chéo
bằng cách thử nghiệm ZZ0005ZZ.  Nếu có bất kỳ nhân vật nào ngoài
thành phần cuối cùng thì nó phải là dấu gạch chéo ở cuối.

Xác nhận lại và tự động đếm
---------------------------

Ngoài các liên kết tượng trưng, ​​chỉ có hai phần của "REF-walk"
quá trình chưa được đề cập.  Một là xử lý các mục bộ đệm cũ
và cái còn lại là automounts.

Trên các hệ thống tập tin yêu cầu nó, các thủ tục tra cứu sẽ gọi
Phương pháp nha khoa ZZ0000ZZ để đảm bảo rằng thông tin được lưu trong bộ nhớ cache
là hiện tại.  Điều này thường sẽ xác nhận tính hợp lệ hoặc cập nhật một vài chi tiết
từ một máy chủ.  Trong một số trường hợp có thể thấy rằng đã có sự thay đổi
tiếp tục đi lên con đường và điều gì đó được cho là hợp lệ
trước đây thực sự không phải vậy.  Khi điều này xảy ra, việc tra cứu toàn bộ
đường dẫn bị hủy bỏ và thử lại với cờ "ZZ0001ZZ".  Cái này
buộc việc xác nhận lại phải kỹ lưỡng hơn.  Chúng ta sẽ xem thêm chi tiết về
quá trình thử lại này trong bài viết tiếp theo.

Điểm tự động gắn kết là các vị trí trong hệ thống tập tin nơi cố gắng
tra cứu một tên có thể kích hoạt những thay đổi về cách thức tra cứu đó
được xử lý, đặc biệt bằng cách gắn hệ thống tập tin vào đó.  Đây là
được trình bày chi tiết hơn trong autofs.rst trong tài liệu Linux
cây, nhưng có một số lưu ý cụ thể liên quan đến việc tra cứu đường dẫn theo thứ tự
ở đây.

Linux VFS có khái niệm về các răng giả "được quản lý".  Có ba
những điều thú vị tiềm tàng về những răng này tương ứng
tới ba cờ khác nhau có thể được đặt trong ZZ0000ZZ:

ZZ0000ZZ
~~~~~~~~~~~~~~~~~~~~~~~~~

Nếu cờ này đã được đặt thì hệ thống tập tin đã yêu cầu
Hoạt động nha khoa ZZ0000ZZ được gọi trước khi xử lý bất kỳ điều gì có thể
điểm gắn kết.  Điều này có thể thực hiện hai dịch vụ cụ thể:

Nó có thể chặn để tránh các cuộc đua.  Nếu một điểm tự động đang được
chưa được kết nối, chức năng ZZ0000ZZ thường sẽ chờ điều đó
quá trình hoàn tất trước khi cho phép tiến hành tra cứu mới và có thể
kích hoạt một automount mới.

Nó có thể chọn lọc chỉ cho phép một số tiến trình chuyển qua một
điểm gắn kết.  Khi một tiến trình máy chủ đang quản lý việc tự động đếm, nó có thể
cần truy cập vào một thư mục mà không kích hoạt tính năng tự động đếm thông thường
xử lý.  Quá trình máy chủ đó có thể tự nhận dạng ZZ0000ZZ
hệ thống tập tin, sau đó sẽ cấp cho nó một quyền truy cập đặc biệt
ZZ0001ZZ bằng cách trả về ZZ0002ZZ.

ZZ0000ZZ
~~~~~~~~~~~~~~~~~~

Cờ này được đặt trên mỗi răng giả được gắn trên đó.  Như Linux
hỗ trợ nhiều không gian tên hệ thống tập tin, có thể là
nha khoa có thể không được gắn vào không gian tên ZZ0000ZZ, chỉ trong một số
khác.  Vì thế lá cờ này được xem như một lời gợi ý chứ không phải một lời hứa hẹn.

Nếu cờ này được đặt và ZZ0000ZZ không trả về ZZ0001ZZ,
ZZ0002ZZ được gọi để kiểm tra bảng băm gắn kết (tôn vinh
ZZ0003ZZ được mô tả trước đó) và có thể trả lại ZZ0004ZZ mới
và ZZ0005ZZ mới (cả hai đều có số tham chiếu được tính).

ZZ0000ZZ
~~~~~~~~~~~~~~~~~~~~~~~~~

Nếu ZZ0000ZZ cho phép chúng ta tiến xa đến mức này, còn ZZ0001ZZ thì không
tìm điểm gắn kết thì cờ này gây ra lỗi răng ZZ0002ZZ
hoạt động được gọi.

Hoạt động ZZ0000ZZ có thể phức tạp tùy ý và có thể
giao tiếp với các quy trình máy chủ, v.v. nhưng cuối cùng nó cũng phải
báo cáo rằng đã xảy ra lỗi, không có gì để gắn kết, hoặc
nên cung cấp ZZ0001ZZ được cập nhật với ZZ0002ZZ và ZZ0003ZZ mới.

Trong trường hợp sau, ZZ0000ZZ sẽ được gọi đến nơi an toàn
cài đặt điểm gắn kết mới vào bảng gắn kết.

Không có khóa nhập khẩu mới nào ở đây và điều quan trọng là không có
khóa (chỉ các tham chiếu được tính) được giữ lại trong quá trình xử lý này do
khả năng rất thực tế của sự chậm trễ kéo dài.
Điều này sẽ trở nên quan trọng hơn vào lần tới khi chúng ta xem xét RCU-walk
đặc biệt nhạy cảm với sự chậm trễ.

RCU-walk - tra cứu tên đường dẫn nhanh hơn trong Linux
==========================================

RCU-walk là một thuật toán khác để thực hiện tra cứu tên đường dẫn trong Linux.
Về nhiều mặt, nó tương tự như REF-walk và cả hai có khá nhiều điểm chung
của mã.  Sự khác biệt đáng kể trong RCU-walk là cách nó cho phép
khả năng truy cập đồng thời.

Chúng tôi lưu ý rằng REF-walk rất phức tạp vì có nhiều chi tiết
và các trường hợp đặc biệt.  RCU-walk giảm thiểu sự phức tạp này bằng cách đơn giản
từ chối xử lý một số trường hợp -- thay vào đó nó quay trở lại
REF-đi bộ.  Khó khăn với RCU-walk đến từ một nguyên nhân khác
hướng: không quen thuộc.  Các quy tắc khóa khi tùy thuộc vào RCU là
khá khác so với khóa truyền thống, vì vậy chúng tôi sẽ chi thêm một chút
đã đến lúc chúng ta đến với những điều đó.

Phân chia vai trò rõ ràng
--------------------------

Cách dễ nhất để quản lý sự tương tranh là buộc dừng bất kỳ hoạt động nào khác
luồng từ việc thay đổi cấu trúc dữ liệu mà một luồng đã cho
đang nhìn vào.  Trong trường hợp không có chủ đề nào khác thậm chí nghĩ đến
thay đổi dữ liệu và rất nhiều chủ đề khác nhau muốn đọc tại
đồng thời, điều này có thể rất tốn kém.  Ngay cả khi sử dụng ổ khóa cho phép
nhiều đầu đọc đồng thời, hành động đơn giản là cập nhật số lượng
số lượng độc giả hiện tại có thể gây ra một chi phí không mong muốn.  Vì vậy
mục tiêu khi đọc cấu trúc dữ liệu được chia sẻ mà không có tiến trình nào khác thực hiện được
thay đổi là để tránh ghi bất cứ điều gì vào bộ nhớ.  Không
khóa, không đếm, không để lại dấu chân.

Cơ chế đi bộ REF đã được mô tả chắc chắn không tuân theo điều này
nguyên tắc, nhưng sau đó nó thực sự được thiết kế để hoạt động khi có thể
là các chủ đề khác sửa đổi dữ liệu.  Ngược lại, RCU-walk là
được thiết kế cho tình huống chung nơi có rất nhiều hoạt động thường xuyên
độc giả và chỉ những người viết thỉnh thoảng.  Điều này có thể không phổ biến ở tất cả
các phần của cây hệ thống tập tin, nhưng ở nhiều phần thì nó sẽ như vậy.  Đối với
các bộ phận khác, điều quan trọng là RCU-walk có thể nhanh chóng quay trở lại
sử dụng REF-walk.

Tra cứu tên đường dẫn luôn bắt đầu ở chế độ RCU-walk nhưng chỉ duy trì ở đó
miễn là thứ nó đang tìm kiếm nằm trong bộ đệm và ổn định.  Nó
nhảy nhẹ xuống hình ảnh hệ thống tập tin được lưu trong bộ nhớ cache, không để lại dấu chân
và cẩn thận quan sát xem nó ở đâu để chắc chắn rằng nó không bị trượt.  Nếu nó
nhận thấy có điều gì đó đã thay đổi hoặc đang thay đổi, hoặc nếu có điều gì đó
không có trong bộ đệm, sau đó nó sẽ cố gắng dừng nhẹ nhàng và chuyển sang
REF-đi bộ.

Việc dừng này đòi hỏi phải có một tham chiếu được tính trên hiện tại
ZZ0000ZZ và ZZ0001ZZ và đảm bảo rằng chúng vẫn hợp lệ -
rằng một con đường đi bộ với REF-walk sẽ tìm thấy các mục tương tự.
Đây là một bất biến mà RCU-walk phải đảm bảo.  Nó chỉ có thể làm
các quyết định, chẳng hạn như lựa chọn bước tiếp theo, đó là những quyết định
REF-walk cũng có thể được thực hiện nếu nó đang đi xuống cây ở
cùng một lúc.  Nếu điểm dừng duyên dáng thành công, phần còn lại của con đường là
được xử lý bằng REF-walk đáng tin cậy, mặc dù hơi chậm.  Nếu
RCU-walk thấy nó không thể dừng lại một cách duyên dáng, nó chỉ đơn giản là bỏ cuộc và
khởi động lại từ đầu với REF-walk.

Mẫu "thử RCU-walk, nếu không thành công, hãy thử REF-walk"
thấy rõ trong các hàm như filename_lookup(),
tên tệp_parentat(),
do_filp_open() và do_file_open_root().  Bốn người này
tương ứng gần đúng với ba hàm ZZ0000ZZ mà chúng ta đã gặp trước đó,
mỗi trong số đó gọi ZZ0001ZZ.  Các chức năng ZZ0002ZZ là
được gọi bằng cách sử dụng các cờ chế độ khác nhau cho đến khi tìm thấy chế độ hoạt động.
Lần đầu tiên họ được gọi với ZZ0003ZZ được đặt để yêu cầu "RCU-walk".  Nếu
không thành công với lỗi ZZ0004ZZ, chúng được gọi lại mà không có
cờ đặc biệt để yêu cầu "REF-walk".  Nếu một trong hai người báo cáo
lỗi ZZ0005ZZ lần thử cuối cùng được thực hiện với bộ ZZ0006ZZ (và không có
ZZ0007ZZ) để đảm bảo rằng các mục được tìm thấy trong bộ đệm bị buộc phải
được xác nhận lại - thông thường các mục chỉ được xác nhận lại nếu hệ thống tập tin
xác định rằng họ đã quá già để tin tưởng.

Nỗ lực ZZ0000ZZ có thể bỏ cờ đó bên trong và chuyển sang
REF-walk, nhưng sau đó sẽ không bao giờ thử chuyển về RCU-walk.  Địa điểm
chuyến đi lên RCU-walk có nhiều khả năng là ở gần những chiếc lá và
vì vậy rất khó có thể có được nhiều lợi ích từ
chuyển đổi trở lại.

RCU và seqlocks: nhanh và nhẹ
--------------------------------

Không có gì đáng ngạc nhiên khi RCU rất quan trọng đối với chế độ đi bộ của RCU.  các
ZZ0000ZZ được giữ trong suốt thời gian RCU-walk đang đi bộ
xuống một con đường.  Sự đảm bảo cụ thể mà nó cung cấp là chìa khóa
cấu trúc dữ liệu - dentries, inodes, super_blocks và mounts - sẽ
không được giải phóng trong khi khóa được giữ.  Chúng có thể bị hủy liên kết hoặc
bị vô hiệu theo cách này hay cách khác, nhưng bộ nhớ sẽ không
được tái sử dụng để các giá trị trong các lĩnh vực khác nhau vẫn có ý nghĩa.  Cái này
là sự đảm bảo duy nhất mà RCU cung cấp; mọi thứ khác được thực hiện bằng cách sử dụng
seqlocks.

Như chúng ta đã thấy ở trên, REF-walk giữ một tham chiếu được tính đến hiện tại
nha khoa và vfsmount hiện tại và không phát hành các tài liệu tham khảo đó
trước khi tham chiếu đến nha khoa "tiếp theo" hoặc vfsmount.  Nó cũng
đôi khi có spinlock ZZ0000ZZ.  Những tài liệu tham khảo và khóa này là
được thực hiện để ngăn chặn những thay đổi nhất định xảy ra.  RCU-đi bộ không được
lấy những tham chiếu hoặc khóa đó và do đó không thể ngăn chặn những thay đổi đó.
Thay vào đó, nó kiểm tra xem liệu một thay đổi đã được thực hiện chưa và hủy bỏ hoặc
thử lại nếu có.

Để bảo toàn tính bất biến được đề cập ở trên (RCU-walk chỉ có thể làm cho
quyết định mà REF-walk có thể đã đưa ra), nó phải thực hiện kiểm tra tại
hoặc gần những nơi mà REF-walk lưu giữ các tài liệu tham khảo.  Vì vậy, khi
REF-walk tăng số lượng tham chiếu hoặc thực hiện khóa quay, RCU-walk
lấy mẫu trạng thái của seqlock bằng ZZ0000ZZ hoặc
chức năng tương tự.  Khi REF-walk giảm số lượng hoặc giảm
lock, RCU-walk kiểm tra xem trạng thái lấy mẫu có còn hợp lệ hay không bằng cách sử dụng
ZZ0001ZZ hoặc tương tự.

Tuy nhiên, có nhiều điều hơn thế về seqlocks.  Nếu
RCU-walk truy cập hai trường khác nhau trong chế độ được bảo vệ bằng seqlock
cấu trúc hoặc truy cập vào cùng một trường hai lần, không có ưu tiên
đảm bảo tính nhất quán giữa các truy cập đó.  Khi tính nhất quán
là cần thiết - điều này thường là như vậy - RCU-walk phải lấy một bản sao và sau đó
sử dụng ZZ0000ZZ để xác thực bản sao đó.

ZZ0000ZZ không chỉ kiểm tra số thứ tự mà còn
áp đặt một rào cản bộ nhớ để không có lệnh đọc bộ nhớ nào từ
ZZ0007ZZ cuộc gọi có thể bị trì hoãn cho đến khi ZZ0008ZZ thực hiện cuộc gọi, bằng cách
CPU hoặc bởi trình biên dịch.  Một ví dụ đơn giản về điều này có thể được nhìn thấy trong
ZZ0001ZZ, dành cho các hệ thống tập tin không sử dụng đơn giản
đẳng thức tên theo byte, gọi vào hệ thống tập tin để so sánh tên
chống lại một chiếc răng giả.  Con trỏ độ dài và tên được sao chép vào cục bộ
các biến, sau đó ZZ0002ZZ được gọi để xác nhận hai
nhất quán và chỉ khi đó ZZ0003ZZ mới được gọi.  Khi nào
so sánh tên tệp tiêu chuẩn được sử dụng, ZZ0004ZZ được gọi
thay vào đó.  Đáng chú ý là ZZ0009ZZ sử dụng ZZ0005ZZ, nhưng
thay vào đó có một nhận xét lớn giải thích lý do đảm bảo tính nhất quán
không cần thiết.  ZZ0006ZZ tiếp theo sẽ là
đủ để nắm bắt bất kỳ vấn đề nào có thể xảy ra tại thời điểm này.

Với một chút nhắc lại về seqlocks, chúng ta có thể xem xét
bức tranh lớn hơn về cách RCU-walk sử dụng seqlocks.

ZZ0000ZZ và ZZ0001ZZ
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Chúng tôi đã gặp seqlock ZZ0000ZZ khi REF-walk sử dụng nó
đảm bảo rằng việc vượt qua điểm gắn kết được thực hiện an toàn.  Công dụng của RCU-walk
nó cũng dành cho điều đó, nhưng còn hơn thế nữa.

Thay vì lấy một tham chiếu được tính cho mỗi ZZ0000ZZ vì nó
đi xuống cây, RCU-walk lấy mẫu trạng thái của ZZ0001ZZ tại
bắt đầu bước đi và lưu số thứ tự ban đầu này vào
ZZ0002ZZ trong trường ZZ0003ZZ.  Một ổ khóa và một cái
số thứ tự được sử dụng để xác thực tất cả quyền truy cập vào tất cả ZZ0004ZZ,
và tất cả các điểm giao nhau.  Khi có những thay đổi đối với bảng gắn kết
tương đối hiếm, việc quay lại REF-walk bất cứ lúc nào là điều hợp lý
rằng bất kỳ thao tác "gắn kết" hoặc "ngắt kết nối" nào sẽ xảy ra.

ZZ0000ZZ được kiểm tra (sử dụng ZZ0001ZZ) khi kết thúc chuyến đi RCU
trình tự, cho dù chuyển sang REF-walk cho phần còn lại của đường dẫn hay
khi đến cuối con đường.  Nó cũng được kiểm tra khi bước
xuống trên điểm gắn kết (trong ZZ0002ZZ) hoặc lên trên (trong
ZZ0003ZZ).  Nếu nó được phát hiện đã thay đổi,
toàn bộ chuỗi bước đi RCU bị hủy bỏ và đường dẫn được xử lý lại bởi
REF-đi bộ.

Nếu RCU-walk thấy rằng ZZ0000ZZ không thay đổi thì có thể chắc chắn
rằng, nếu REF-walk lấy các tài liệu tham khảo được tính trên mỗi vfsmount, thì
kết quả sẽ giống nhau.  Điều này đảm bảo giữ bất biến,
ít nhất là đối với cấu trúc vfsmount.

ZZ0000ZZ và ZZ0001ZZ
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Thay vì đếm hoặc khóa các mẫu ZZ0000ZZ, RCU-walk
khóa seqlock ZZ0001ZZ mỗi nha khoa và lưu số thứ tự trong
Trường ZZ0002ZZ của cấu trúc nameidata, vì vậy ZZ0003ZZ phải luôn là
số thứ tự hiện tại của ZZ0004ZZ.  Con số này cần được
được xác nhận lại sau khi sao chép và trước khi sử dụng tên, cha mẹ hoặc
inode của nha khoa.

Việc xử lý tên mà chúng ta đã xem xét và tên cha là
chỉ được truy cập trong ZZ0000ZZ, điều này khá tầm thường
mẫu được yêu cầu, mặc dù nó làm như vậy cho ba trường hợp khác nhau.

Khi không ở điểm gắn kết, ZZ0000ZZ được theo dõi và ZZ0001ZZ của nó được theo sau
được thu thập.  Thay vào đó, khi chúng ta đang ở điểm gắn kết, chúng ta làm theo
Liên kết ZZ0002ZZ để nhận một chiếc răng giả mới và thu thập nó
ZZ0003ZZ.  Sau đó, sau khi tìm được ZZ0004ZZ để theo dõi, chúng ta phải
kiểm tra xem chúng ta đã hạ cánh xuống một điểm gắn kết chưa và nếu có thì phải tìm ra điểm đó
điểm gắn kết và theo liên kết ZZ0005ZZ.  Điều này có nghĩa là một
hoàn cảnh hơi bất thường, nhưng chắc chắn có thể xảy ra, trong đó
điểm bắt đầu của việc tra cứu đường dẫn là một phần của hệ thống tập tin
đã được gắn vào và do đó không thể nhìn thấy được từ thư mục gốc.

Con trỏ inode, được lưu trữ trong ZZ0000ZZ, có nhiều hơn một chút
thú vị.  Inode sẽ luôn cần được truy cập ít nhất
hai lần, một lần để xác định xem đó có phải là NULL hay không và một lần để xác minh quyền truy cập
quyền.  Việc xử lý liên kết tượng trưng cũng yêu cầu một con trỏ inode được xác thực.
Thay vì xác nhận lại mỗi lần truy cập, một bản sao sẽ được tạo vào lần đầu tiên
truy cập và nó được lưu trữ trong trường ZZ0001ZZ của ZZ0002ZZ từ đâu
nó có thể được truy cập một cách an toàn mà không cần xác nhận thêm.

ZZ0000ZZ là thói quen tra cứu duy nhất được sử dụng ở chế độ RCU,
ZZ0001ZZ quá chậm và cần có khóa.  Nó ở trong
ZZ0002ZZ mà chúng tôi nhận thấy theo dõi "bàn tay" quan trọng
của nha khoa hiện nay.

Số ZZ0000ZZ hiện tại và số ZZ0001ZZ hiện tại được chuyển tới
ZZ0002ZZ, nếu thành công sẽ trả về một ZZ0003ZZ mới và một
số ZZ0004ZZ mới.  ZZ0005ZZ sau đó sao chép con trỏ inode và
xác nhận lại số ZZ0006ZZ mới.  Sau đó nó xác nhận ZZ0007ZZ cũ
với ZZ0008ZZ cũ lần cuối cùng và chỉ sau đó mới tiếp tục.  Cái này
quá trình lấy số ZZ0009ZZ của răng giả mới và sau đó
kiểm tra số ZZ0010ZZ của cái cũ phản ánh chính xác quá trình
nhận được một tài liệu tham khảo được tính cho nha khoa mới trước khi bỏ nó cho
chiếc răng giả cũ mà chúng ta đã thấy trong REF-walk.

Không có ZZ0000ZZ hoặc thậm chí ZZ0001ZZ
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Semaphore là một khóa khá nặng, chỉ có thể lấy được khi nó được
được phép ngủ.  Vì ZZ0000ZZ cấm ngủ,
ZZ0001ZZ không có vai trò gì trong RCU-walk.  Nếu một số chủ đề khác làm
lấy ZZ0002ZZ và sửa đổi thư mục theo cách mà RCU-walk cần
cần lưu ý, kết quả sẽ là RCU-walk không tìm thấy
nha khoa mà nó đang tìm kiếm, hoặc nó sẽ tìm thấy một nha khoa
ZZ0003ZZ sẽ không xác thực.  Trong cả hai trường hợp, nó sẽ giảm xuống
Chế độ đi bộ REF có thể lấy bất kỳ ổ khóa nào cần thiết.

Mặc dù ZZ0000ZZ có thể được RCU-walk sử dụng vì nó không yêu cầu
có ngủ thì RCU-walk cũng không bận tâm.  REF-walk sử dụng ZZ0001ZZ để
bảo vệ khỏi khả năng xảy ra chuỗi băm trong quá trình thay đổi dcache
trong khi họ đang được tìm kiếm.  Điều này có thể dẫn đến việc không tìm thấy
một cái gì đó thực sự ở đó  Khi RCU-walk không tìm thấy
thứ gì đó trong bộ nhớ đệm của nha khoa, cho dù nó có thực sự ở đó hay không, nó
đã giảm xuống REF-walk và thử lại với mức thích hợp
khóa.  Điều này xử lý gọn gàng tất cả các trường hợp, vì vậy hãy thêm các kiểm tra bổ sung vào
đổi tên_lock sẽ không mang lại giá trị đáng kể.

ZZ0000ZZ và ZZ0001ZZ
-----------------------------------------

Việc "thả xuống REF-walk" thường liên quan đến lệnh gọi tới
ZZ0000ZZ, được đặt tên như vậy bởi vì "RCU-walk" đôi khi cũng
gọi là "đi bộ lười biếng".  ZZ0001ZZ được gọi khi
đi theo đường dẫn xuống cặp vfsmount/dentry hiện tại dường như
đã tiến hành thành công, nhưng bước tiếp theo có vấn đề.  Cái này
có thể xảy ra nếu không tìm thấy tên tiếp theo trong dcache, nếu
không thể đạt được việc kiểm tra quyền hoặc xác nhận lại tên trong khi
ZZ0002ZZ được giữ (cấm ngủ), nếu
điểm tự động được tìm thấy hoặc trong một số trường hợp liên quan đến liên kết tượng trưng.
Nó cũng được gọi từ ZZ0003ZZ khi việc tra cứu đã đạt đến
thành phần cuối cùng hoặc phần cuối của đường dẫn, tùy thuộc vào thành phần nào
hương vị đặc biệt của tra cứu được sử dụng.

Các lý do khác khiến RCU-walk không kích hoạt cuộc gọi
đến ZZ0000ZZ là khi tìm thấy một số điểm không nhất quán mà không thể giải quyết được
được xử lý ngay lập tức, chẳng hạn như ZZ0001ZZ hoặc một trong các ZZ0002ZZ
seqlocks báo cáo một sự thay đổi.  Trong những trường hợp này, chức năng liên quan
sẽ trả về ZZ0003ZZ, nó sẽ thấm dần cho đến khi nó kích hoạt một giao diện mới
thử từ trên xuống bằng cách sử dụng REF-walk.

Đối với những trường hợp ZZ0000ZZ là một tùy chọn, về cơ bản nó
lấy một tham chiếu trên mỗi con trỏ mà nó giữ (vfsmount,
nha khoa và có thể một số liên kết tượng trưng) và sau đó xác minh rằng
seqlocks có liên quan không được thay đổi.  Nếu đã có những thay đổi,
nó cũng hủy bỏ với ZZ0001ZZ, nếu không thì chuyển sang REF-walk
đã thành công và quá trình tra cứu vẫn tiếp tục.

Việc tham khảo những con trỏ đó không hoàn toàn đơn giản như chỉ
tăng một bộ đếm.  Điều đó có tác dụng để tham khảo lần thứ hai nếu bạn
đã có một cái (thường gián tiếp thông qua một đối tượng khác), nhưng nó
là không đủ nếu bạn không thực sự có một tài liệu tham khảo được tính tại
tất cả.  Đối với ZZ0000ZZ, việc tăng tham chiếu là an toàn
counter để lấy tham chiếu trừ khi nó được đánh dấu rõ ràng là
"chết" liên quan đến việc đặt bộ đếm thành ZZ0001ZZ.
ZZ0002ZZ đạt được điều này.

Đối với ZZ0000ZZ, việc tham khảo là an toàn miễn là
ZZ0001ZZ sau đó được sử dụng để xác thực tham chiếu.  Nếu đó
xác thực không thành công, ZZ0006ZZ có thể an toàn khi thả tham chiếu đó vào
cách gọi tiêu chuẩn ZZ0002ZZ - một cuộc ngắt kết nối có thể có
đã tiến triển quá xa.  Vì vậy, mã trong ZZ0003ZZ, khi nó
thấy rằng tài liệu tham khảo mà nó nhận được có thể không an toàn, hãy kiểm tra
Cờ ZZ0004ZZ để xác định xem ZZ0005ZZ đơn giản có phải là
đúng, hoặc nếu nó chỉ nên giảm số lượng và giả vờ như không có gì
điều này đã từng xảy ra.

Chăm sóc trong hệ thống tập tin
--------------------------

RCU-walk phụ thuộc gần như hoàn toàn vào thông tin được lưu trong bộ nhớ đệm và thường sẽ
không gọi vào hệ thống tập tin nào cả.  Tuy nhiên có hai nơi,
bên cạnh việc so sánh tên thành phần đã được đề cập, trong đó
hệ thống tập tin có thể được bao gồm trong RCU-walk và nó phải được biết là
cẩn thận.

Nếu hệ thống tập tin có các yêu cầu kiểm tra quyền không chuẩn -
chẳng hạn như hệ thống tệp được nối mạng có thể cần kiểm tra với máy chủ
- giao diện ZZ0000ZZ có thể được gọi trong quá trình RCU-walk.
Trong trường hợp này, một cờ "ZZ0001ZZ" bổ sung được chuyển để nó
biết không ngủ mà trả lại ZZ0002ZZ nếu không thể hoàn thành
kịp thời.  ZZ0003ZZ được cấp con trỏ inode, không phải con trỏ
nha khoa, do đó không cần phải lo lắng về việc kiểm tra tính nhất quán hơn nữa.
Tuy nhiên, nếu nó truy cập bất kỳ cấu trúc dữ liệu hệ thống tập tin nào khác, nó phải
đảm bảo chúng an toàn khi được truy cập chỉ bằng ZZ0004ZZ
được tổ chức.  Điều này thường có nghĩa là chúng phải được giải phóng bằng ZZ0005ZZ hoặc
tương tự.

.. _READ_ONCE: https://lwn.net/Articles/624126/

Nếu hệ thống tập tin có thể cần xác nhận lại các mục dcache, thì
ZZ0000ZZ cũng có thể được gọi trong RCU-walk.  Giao diện này
ZZ0006ZZ đã vượt qua nha khoa nhưng không có quyền truy cập vào ZZ0001ZZ hoặc
Số ZZ0002ZZ từ ZZ0003ZZ nên cần hết sức cẩn thận
khi truy cập các trường trong nha khoa.  Sự "chăm sóc thêm" này thường
liên quan đến việc sử dụng ZZ0005ZZ để truy cập các trường và xác minh
kết quả không phải là NULL trước khi sử dụng.  Mô hình này có thể được nhìn thấy trong
ZZ0004ZZ.

Một cặp hoa văn
------------------

Ở nhiều nơi khác nhau trong chi tiết của REF-walk và RCU-walk, cũng như trong
bức tranh lớn, có một vài mẫu liên quan có giá trị
đang nhận thức được.

Đầu tiên là "thử nhanh và kiểm tra, nếu thất bại hãy thử từ từ".  Chúng tôi
có thể thấy điều đó trong cách tiếp cận cấp cao khi thử RCU-walk lần đầu tiên và
sau đó thử đi bộ REF và ở những nơi ZZ0000ZZ đã quen
chuyển sang REF-walk cho phần còn lại của con đường.  Chúng tôi cũng đã thấy nó trước đó
trong ZZ0001ZZ khi theo liên kết "ZZ0002ZZ".  Nó cố gắng một cách nhanh chóng
để lấy tài liệu tham khảo, sau đó quay lại lấy khóa nếu cần.

Mẫu thứ hai là "thử nhanh và kiểm tra, nếu thất bại hãy thử
một lần nữa - nhiều lần".  Điều này được thấy khi sử dụng ZZ0000ZZ và
ZZ0001ZZ trong REF-walk.  RCU-walk không sử dụng mẫu này -
nếu có vấn đề gì xảy ra thì sẽ an toàn hơn nhiều nếu bạn chỉ cần hủy bỏ và thử thêm
cách tiếp cận an thần.

Điểm nhấn ở đây là "thử nhanh và kiểm tra".  Có lẽ nó nên như vậy
"thử nhanh ZZ0000ZZ rồi kiểm tra".  Thực tế việc kiểm tra là
cần có một lời nhắc nhở rằng hệ thống này rất năng động và chỉ có một giới hạn
nhiều thứ đều an toàn.  Nguyên nhân thường gặp nhất gây ra lỗi trong
toàn bộ quá trình này đang giả định điều gì đó là an toàn trong khi thực tế nó
không phải.  Xem xét cẩn thận những gì chính xác đảm bảo sự an toàn của
mỗi lần truy cập đôi khi là cần thiết.

Đi dạo giữa các liên kết tượng trưng
=========================

Có một số vấn đề cơ bản mà chúng ta sẽ xem xét để hiểu được
xử lý các liên kết tượng trưng: ngăn xếp liên kết tượng trưng, ​​cùng với bộ đệm
vòng đời, sẽ giúp chúng ta hiểu cách xử lý đệ quy tổng thể của
liên kết tượng trưng và dẫn đến sự chăm sóc đặc biệt cần thiết cho thành phần cuối cùng.
Sau đó xem xét các cập nhật về thời gian truy cập và tóm tắt các thông tin khác nhau
cờ kiểm soát tra cứu sẽ kết thúc câu chuyện.

Ngăn xếp liên kết tượng trưng
-----------------

Chỉ có hai loại đối tượng hệ thống tập tin có thể hữu ích
xuất hiện trong đường dẫn trước thành phần cuối cùng: thư mục và liên kết tượng trưng.
Xử lý các thư mục khá đơn giản: thư mục mới
đơn giản trở thành điểm khởi đầu để diễn giải ý tiếp theo
thành phần trên đường dẫn.  Xử lý các liên kết tượng trưng đòi hỏi nhiều hơn một chút
làm việc.

Về mặt khái niệm, các liên kết tượng trưng có thể được xử lý bằng cách chỉnh sửa đường dẫn.  Nếu
tên thành phần đề cập đến một liên kết tượng trưng thì thành phần đó là
được thay thế bằng phần thân của liên kết và nếu phần thân đó bắt đầu bằng '/',
thì tất cả các phần trước của đường dẫn sẽ bị loại bỏ.  Đây là những gì
Lệnh "ZZ0000ZZ" thực hiện được, mặc dù nó cũng chỉnh sửa "ZZ0001ZZ" và
Các thành phần "ZZ0002ZZ".

Việc chỉnh sửa trực tiếp chuỗi đường dẫn không thực sự cần thiết khi tìm kiếm
đi theo một lộ trình và việc loại bỏ các thành phần ban đầu là vô nghĩa vì chúng không
dù sao cũng nhìn vào.  Việc theo dõi tất cả các thành phần còn lại là
quan trọng, nhưng tất nhiên chúng có thể được giữ riêng; không cần thiết
để nối chúng.  Vì một liên kết tượng trưng có thể dễ dàng đề cập đến một liên kết khác,
do đó có thể đề cập đến phần thứ ba, chúng ta có thể cần giữ phần còn lại
các thành phần của một số đường dẫn, mỗi đường dẫn sẽ được xử lý khi đường dẫn trước đó
những cái đó đã được hoàn thành.  Những phần còn lại của con đường này được giữ trên một chồng
kích thước hạn chế.

Có hai lý do để đặt giới hạn về số lượng liên kết tượng trưng có thể
xảy ra trong một lần tra cứu đường dẫn duy nhất.  Rõ ràng nhất là tránh các vòng lặp.
Nếu một liên kết tượng trưng đề cập đến chính nó một cách trực tiếp hoặc thông qua
trung gian, thì việc theo liên kết tượng trưng không bao giờ có thể hoàn thành
thành công - lỗi ZZ0000ZZ phải được trả về.  Vòng lặp có thể
được phát hiện mà không áp đặt giới hạn, nhưng giới hạn là giải pháp đơn giản nhất
và, với lý do hạn chế thứ hai, là khá đầy đủ.

.. _outlined recently: http://thread.gmane.org/gmane.linux.kernel/1934390/focus=1934550

Lý do thứ hai là ZZ0000ZZ của Linus:

Bởi vì đó cũng là vấn đề về độ trễ và DoS. Chúng ta cần phản ứng tốt với
   các vòng lặp đúng mà còn có các vòng lặp không "rất sâu". Đó không phải là về trí nhớ
   sử dụng, đó là về việc người dùng kích hoạt các tài nguyên CPU không hợp lý.

Linux áp đặt giới hạn về độ dài của bất kỳ tên đường dẫn nào: ZZ0000ZZ,
là 4096. Có một số lý do dẫn tới giới hạn này; không để cho
kernel dành quá nhiều thời gian cho một con đường là một trong số đó.  Với
các liên kết tượng trưng bạn có thể tạo ra các đường dẫn dài hơn một cách hiệu quả nên một số
loại giới hạn là cần thiết vì lý do tương tự.  Linux áp đặt một giới hạn
tối đa 40 (MAXSYMLINKS) liên kết tượng trưng trong bất kỳ tra cứu đường dẫn nào.  Trước đây nó đã áp đặt
giới hạn nữa là tám cho độ sâu đệ quy tối đa, nhưng đó là
tăng lên 40 khi một ngăn xếp riêng biệt được triển khai, vì vậy hiện tại có
chỉ là một giới hạn.

Cấu trúc ZZ0000ZZ mà chúng ta đã gặp trong bài viết trước chứa một
ngăn xếp nhỏ có thể được sử dụng để lưu trữ phần còn lại của tối đa hai
liên kết tượng trưng.  Trong nhiều trường hợp điều này sẽ là đủ.  Nếu không, một
ngăn xếp riêng biệt được phân bổ chỗ cho 40 liên kết tượng trưng.  Tên đường dẫn
tra cứu sẽ không bao giờ vượt quá ngăn xếp đó vì khi liên kết tượng trưng thứ 40 được
được phát hiện, một lỗi sẽ được trả về.

Có vẻ như những cái tên còn sót lại là tất cả những gì cần được lưu trữ trên đó.
đống này, nhưng chúng ta cần nhiều hơn một chút.  Để thấy được điều đó chúng ta cần chuyển sang
vòng đời của bộ đệm.

Lưu trữ và tuổi thọ của các liên kết tượng trưng được lưu trong bộ nhớ cache
---------------------------------------

Giống như các tài nguyên hệ thống tập tin khác, chẳng hạn như inode và thư mục
các mục, liên kết tượng trưng được Linux lưu vào bộ nhớ đệm để tránh việc truy cập tốn kém nhiều lần
sang bộ nhớ ngoài.  Điều đặc biệt quan trọng đối với RCU-walk là
có thể tìm và tạm thời giữ các mục được lưu trong bộ nhớ đệm này, để
nó không cần phải thả xuống REF-walk.

.. _object-oriented design pattern: https://lwn.net/Articles/446317/

Mặc dù mỗi hệ thống tập tin được tự do lựa chọn, nhưng các liên kết tượng trưng
thường được lưu trữ ở một trong hai nơi.  Các liên kết tượng trưng ngắn thường
được lưu trữ trực tiếp trong inode.  Khi một hệ thống tập tin phân bổ một ZZ0000ZZ, nó thường phân bổ thêm không gian để lưu trữ dữ liệu riêng tư (một
ZZ0001ZZ phổ biến trong kernel).  Điều này sẽ
đôi khi bao gồm không gian cho một liên kết tượng trưng.  Vị trí chung khác là
trong bộ đệm trang, nơi thường lưu trữ nội dung của tệp.  các
tên đường dẫn trong một liên kết tượng trưng có thể được xem là nội dung của liên kết tượng trưng đó và
có thể dễ dàng được lưu trữ trong bộ đệm trang giống như nội dung tệp.

Khi cả hai điều này đều không phù hợp, kịch bản có thể xảy ra tiếp theo là
rằng hệ thống tập tin sẽ phân bổ một số bộ nhớ tạm thời và sao chép hoặc
xây dựng nội dung liên kết tượng trưng vào bộ nhớ đó bất cứ khi nào cần thiết.

Khi liên kết tượng trưng được lưu trữ trong inode, nó có cùng thời gian tồn tại với
inode mà bản thân nó được bảo vệ bởi RCU hoặc bởi một tham chiếu được tính
trên nha khoa.  Điều này có nghĩa là cơ chế tra cứu tên đường dẫn
việc sử dụng để truy cập dcache và icache (bộ đệm inode) một cách an toàn khá
đủ để truy cập một số liên kết tượng trưng được lưu trong bộ nhớ cache một cách an toàn.  Trong những trường hợp này,
con trỏ ZZ0000ZZ trong inode được đặt để trỏ tới bất kỳ nơi nào
liên kết tượng trưng được lưu trữ và nó có thể được truy cập trực tiếp bất cứ khi nào cần thiết.

Khi liên kết tượng trưng được lưu trữ trong bộ đệm trang hoặc ở nơi khác,
tình hình không đơn giản như vậy.  Một tài liệu tham khảo về nha khoa hoặc thậm chí
trên một nút không ngụ ý bất kỳ tham chiếu nào trên các trang được lưu trong bộ nhớ cache của nút đó
inode và thậm chí ZZ0000ZZ cũng không đủ để đảm bảo rằng
một trang sẽ không biến mất.  Vì vậy, đối với các liên kết tượng trưng này, việc tra cứu tên đường dẫn
mã cần yêu cầu hệ thống tập tin cung cấp một tham chiếu ổn định và,
đáng kể, cần giải phóng tham chiếu đó khi nó kết thúc
với nó.

Thường có thể tham chiếu đến trang bộ đệm ngay cả trong RCU-walk
chế độ.  Nó đòi hỏi phải thực hiện những thay đổi đối với bộ nhớ, điều tốt nhất nên tránh,
nhưng đó không hẳn là một chi phí lớn và còn tốt hơn là bỏ đi
hoàn toàn thoát khỏi chế độ RCU-walk.  Ngay cả các hệ thống tập tin phân bổ
không gian để sao chép liên kết tượng trưng vào có thể sử dụng ZZ0000ZZ để thường thành công
phân bổ bộ nhớ mà không cần phải thoát khỏi RCU-walk.  Nếu một
hệ thống tập tin không thể lấy tham chiếu thành công ở chế độ RCU-walk, nó
phải trả về ZZ0001ZZ và ZZ0002ZZ sẽ được gọi để quay lại
Chế độ đi bộ REF trong đó hệ thống tập tin được phép ngủ.

Nơi để tất cả điều này xảy ra là inode ZZ0000ZZ
phương pháp. Điều này được gọi cả trong RCU-walk và REF-walk. Trong RCU-walk
Đối số ZZ0001ZZ là NULL, ZZ0002ZZ có thể trả về -ECHILD để thoát khỏi
RCU-đi bộ.  Giống như phương pháp ZZ0003ZZ, chúng tôi
đã xem xét trước đây, ZZ0004ZZ sẽ cần phải cẩn thận rằng
tất cả các cấu trúc dữ liệu mà nó tham chiếu đều an toàn để được truy cập trong khi
không có tham chiếu được tính, chỉ có khóa RCU. Cuộc gọi lại
ZZ0005ZZ sẽ được chuyển cho ZZ0006ZZ:
hệ thống tệp có thể thiết lập hàm và đối số put_link của riêng chúng thông qua
set_delayed_call(). Sau này khi VFS muốn đặt link thì nó sẽ gọi
do_delayed_call() để gọi hàm gọi lại đó bằng đối số.

Để loại bỏ tham chiếu đến từng liên kết tượng trưng khi quá trình đi bộ hoàn tất,
dù ở RCU-walk hay REF-walk, ngăn xếp liên kết tượng trưng cần chứa,
cùng với tàn dư của con đường:

- ZZ0000ZZ để cung cấp tham chiếu đến đường dẫn trước đó
- ZZ0001ZZ để cung cấp tham chiếu đến tên trước đó
- ZZ0002ZZ để cho phép chuyển đường đi một cách an toàn từ RCU-walk sang REF-walk
- ZZ0003ZZ để gọi sau này.

Điều này có nghĩa là mỗi mục trong ngăn xếp liên kết tượng trưng cần chứa năm
con trỏ và một số nguyên thay vì chỉ một con trỏ (đường dẫn
tàn dư).  Trên hệ thống 64 bit, đây là khoảng 40 byte cho mỗi mục nhập;
với 40 mục, tổng cộng lên tới 1600 byte, nhỏ hơn
nửa trang.  Vì vậy, nó có vẻ như rất nhiều, nhưng không có nghĩa là
quá mức.

Lưu ý rằng, trong khung ngăn xếp nhất định, phần còn lại của đường dẫn (ZZ0000ZZ) không
một phần của liên kết tượng trưng mà các trường khác tham chiếu đến.  Đó là tàn dư
được theo sau khi liên kết tượng trưng đó đã được phân tích cú pháp đầy đủ.

Theo liên kết tượng trưng
---------------------

Vòng lặp chính trong ZZ0000ZZ lặp lại liền mạch trên tất cả
các thành phần trong đường dẫn và tất cả các liên kết tượng trưng không phải cuối cùng.  Là liên kết tượng trưng
được xử lý, con trỏ ZZ0001ZZ được điều chỉnh để trỏ tới một địa chỉ mới
liên kết tượng trưng hoặc được khôi phục từ ngăn xếp, do đó phần lớn vòng lặp
không cần để ý.  Bật và tắt biến ZZ0002ZZ này
ngăn xếp rất đơn giản; đẩy và bật các tài liệu tham khảo là
phức tạp hơn một chút.

Khi tìm thấy một liên kết tượng trưng, walk_comComponent() gọi pick_link() thông qua step_into()
trả về liên kết từ hệ thống tập tin.
Với điều kiện hoạt động đó thành công, đường dẫn cũ ZZ0000ZZ sẽ được đặt trên
ngăn xếp và giá trị mới được sử dụng làm ZZ0001ZZ trong một thời gian.  Khi kết thúc
đường dẫn đã được tìm thấy (tức là ZZ0002ZZ là ZZ0003ZZ) ZZ0004ZZ cũ được khôi phục
ra khỏi ngăn xếp và tiếp tục đi bộ trên đường.

Đẩy và bật các con trỏ tham chiếu (inode, cookie, v.v.) hiệu quả hơn
phức tạp một phần vì mong muốn xử lý đệ quy đuôi.  Khi nào
thành phần cuối cùng của chính liên kết tượng trưng trỏ đến một liên kết tượng trưng, chúng tôi
muốn bật liên kết tượng trưng vừa hoàn thành ra khỏi ngăn xếp trước khi đẩy
liên kết tượng trưng vừa tìm thấy để tránh để lại phần còn lại của đường dẫn trống
chỉ cần cản đường.

Thuận tiện nhất là đẩy các tham chiếu liên kết tượng trưng mới vào
xếp chồng trong ZZ0000ZZ ngay lập tức khi tìm thấy liên kết tượng trưng;
ZZ0001ZZ cũng là đoạn mã cuối cùng cần xem xét
liên kết tượng trưng cũ khi nó đi qua thành phần cuối cùng đó.  Vì vậy nó khá
thuận tiện cho ZZ0002ZZ giải phóng liên kết tượng trưng cũ và bật lên
các tài liệu tham khảo ngay trước khi đẩy thông tin tham khảo cho
liên kết tượng trưng mới.  Nó được hướng dẫn bởi ba lá cờ: ZZ0003ZZ
cấm nó đi theo một liên kết tượng trưng nếu nó tìm thấy một liên kết tượng trưng, ZZ0004ZZ
điều đó cho thấy vẫn còn quá sớm để phát hành
liên kết tượng trưng hiện tại và ZZ0005ZZ cho biết rằng nó nằm ở cuối cùng
của việc tra cứu, vì vậy chúng tôi sẽ kiểm tra cờ vùng người dùng ZZ0006ZZ để
quyết định xem có theo dõi nó hay không khi nó là một liên kết tượng trưng và gọi ZZ0007ZZ để
kiểm tra xem chúng tôi có đặc quyền để theo dõi nó không.

Liên kết tượng trưng không có thành phần cuối cùng
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Một cặp liên kết tượng trưng trong trường hợp đặc biệt xứng đáng được giải thích thêm một chút.
Cả hai đều dẫn đến việc đặt một ZZ0000ZZ mới (có ngàm và ngàm)
lên trong ZZ0001ZZ và dẫn đến pick_link() trả về ZZ0002ZZ.

Trường hợp rõ ràng hơn là một liên kết tượng trưng đến "ZZ0000ZZ".  Tất cả các liên kết tượng trưng bắt đầu
với "ZZ0001ZZ" được phát hiện trong pick_link() sẽ đặt lại ZZ0002ZZ
để trỏ đến gốc hệ thống tập tin hiệu quả.  Nếu chỉ liên kết tượng trưng
chứa "ZZ0003ZZ" thì không còn gì để làm, không có thành phần nào cả,
vì vậy ZZ0004ZZ được trả về để chỉ ra rằng liên kết tượng trưng có thể được giải phóng và
khung ngăn xếp bị loại bỏ.

Trường hợp khác liên quan đến những thứ trong ZZ0000ZZ trông giống như các liên kết tượng trưng nhưng
không thực sự (và do đó thường được gọi là "liên kết ma thuật")::

$ ls -l /proc/self/fd/1
     lrwx------ 1 neilb neilb 64 ngày 13 tháng 6 10:19 /proc/self/fd/1 -> /dev/pts/4

Mọi bộ mô tả tệp đang mở trong bất kỳ quy trình nào đều được thể hiện trong ZZ0000ZZ bởi
một cái gì đó trông giống như một liên kết tượng trưng.  Nó thực sự là một tài liệu tham khảo cho
tập tin mục tiêu, không chỉ tên của nó.  Khi bạn ZZ0001ZZ này
các đối tượng bạn nhận được một tên có thể đề cập đến cùng một tệp - trừ khi nó
đã được hủy liên kết hoặc được gắn kết.  Khi ZZ0002ZZ theo sau
một trong số đó, phương thức ZZ0003ZZ trong "procfs" không trả về
một tên chuỗi mà thay vào đó gọi nd_jump_link() để cập nhật
ZZ0004ZZ tại chỗ để trỏ đến mục tiêu đó.  ZZ0005ZZ rồi
trả về ZZ0006ZZ.  Một lần nữa không có thành phần cuối cùng và pick_link()
trả về ZZ0007ZZ.

Theo liên kết tượng trưng trong thành phần cuối cùng
--------------------------------------------

Tất cả điều này dẫn đến việc ZZ0000ZZ phải xem xét từng bộ phận và
đi theo tất cả các liên kết tượng trưng mà nó tìm thấy cho đến khi đạt được kết quả cuối cùng
thành phần.  Điều này vừa được trả về trong trường ZZ0001ZZ của ZZ0002ZZ.
Đối với một số người gọi, đây là tất cả những gì họ cần; họ muốn tạo ra điều đó
Tên ZZ0003ZZ nếu nó không tồn tại hoặc báo lỗi nếu có.  Khác
người gọi sẽ muốn theo một liên kết tượng trưng nếu tìm thấy một liên kết tượng trưng và có thể
áp dụng cách xử lý đặc biệt cho thành phần cuối cùng của liên kết tượng trưng đó, thay vào đó
chứ không chỉ là thành phần cuối cùng của tên tệp gốc.  Những người gọi này
có thể cần phải gọi đi gọi lại ZZ0004ZZ
các liên kết tượng trưng liên tiếp cho đến khi tìm thấy một liên kết không trỏ đến một liên kết khác
liên kết tượng trưng.

Trường hợp này được xử lý bởi người gọi liên quan của link_path_walk(), chẳng hạn như
path_lookupat(), path_openat() sử dụng vòng lặp gọi link_path_walk(),
và sau đó xử lý thành phần cuối cùng bằng cách gọi open_last_lookups() hoặc
tra cứu_last(). Nếu đó là một liên kết tượng trưng cần được theo dõi,
open_last_lookups() hoặc lookup_last() sẽ thiết lập mọi thứ đúng cách và
trả lại đường dẫn để vòng lặp lặp lại, gọi
link_path_walk() một lần nữa.  Điều này có thể lặp lại tới 40 lần nếu lần cuối cùng
thành phần của mỗi liên kết tượng trưng là một liên kết tượng trưng khác.

Trong số các chức năng khác nhau kiểm tra thành phần cuối cùng, 
open_last_lookups() là thú vị nhất vì nó hoạt động song song
với do_open() để mở tệp.  Một phần của open_last_lookups() chạy
với ZZ0000ZZ được giữ và phần này có chức năng riêng biệt: lookup_open().

Việc giải thích hoàn toàn open_last_lookups() và do_open() nằm ngoài phạm vi
của bài viết này, nhưng có một số điểm nổi bật sẽ giúp ích cho những người thích khám phá
mã.

1. Thay vì chỉ tìm tệp đích, do_open() được sử dụng sau
   open_last_lookup() để mở
   nó.  Nếu tệp được tìm thấy trong dcache thì ZZ0000ZZ sẽ được sử dụng cho
   cái này.  Nếu không, ZZ0001ZZ sẽ gọi ZZ0002ZZ (nếu
   hệ thống tập tin cung cấp nó) để kết hợp tra cứu cuối cùng với mở hoặc
   sẽ thực hiện các bước ZZ0003ZZ và ZZ0004ZZ riêng biệt
   trực tiếp.  Trong trường hợp sau, "mở" thực sự của cái mới được tìm thấy này hoặc
   tập tin đã tạo sẽ được thực hiện bởi vfs_open(), giống như tên
   đã được tìm thấy trong dcache.

2. vfs_open() có thể bị lỗi với ZZ0000ZZ nếu thông tin được lưu trong bộ nhớ đệm
   vẫn chưa đủ hiện tại.  Nếu nó ở RCU-walk ZZ0001ZZ sẽ được trả lại
   nếu không thì ZZ0002ZZ sẽ được trả về.  Khi ZZ0003ZZ được trả lại, người gọi có thể
   thử lại với bộ cờ ZZ0004ZZ.

3. Mở bằng O_CREAT ZZ0001ZZ theo liên kết tượng trưng trong thành phần cuối cùng,
   không giống như các lệnh gọi hệ thống tạo khác (như ZZ0000ZZ).  Vậy trình tự::

ln -s bar /tmp/foo
          echo xin chào > /tmp/foo

sẽ tạo một tệp có tên ZZ0000ZZ.  Điều này không được phép nếu
   ZZ0001ZZ được thiết lập nhưng mặt khác được xử lý đối với O_CREAT mở nhiều
   giống như đối với mở không tạo: lookup_last() hoặc open_last_lookup()
   trả về giá trị không phải ZZ0002ZZ và link_path_walk() được gọi và
   quá trình mở tiếp tục trên liên kết tượng trưng đã được tìm thấy.

Cập nhật thời gian truy cập
------------------------

Trước đây chúng tôi đã nói về RCU-walk rằng nó sẽ "không có khóa, tăng dần
không đếm, không để lại dấu chân."  Kể từ đó chúng tôi đã thấy rằng một số
"dấu chân" có thể cần thiết khi xử lý các liên kết tượng trưng dưới dạng được đếm
có thể cần đến tài liệu tham khảo (hoặc thậm chí là cấp phát bộ nhớ).  Nhưng những điều này
dấu chân tốt nhất được giữ ở mức tối thiểu.

Một nơi khác mà việc đi xuống một liên kết tượng trưng có thể liên quan đến việc rời khỏi
dấu chân theo cách không ảnh hưởng đến thư mục là cập nhật thời gian truy cập.
Trong Unix (và Linux), mọi đối tượng hệ thống tập tin đều có "truy cập lần cuối
thời gian" hoặc "ZZ0000ZZ".  Đi qua một thư mục để truy cập một tập tin
bên trong không được coi là quyền truy cập cho các mục đích
ZZ0001ZZ; chỉ liệt kê nội dung của một thư mục mới có thể cập nhật ZZ0002ZZ của nó.
Có vẻ như các liên kết tượng trưng là khác nhau.  Cả hai đều đọc một liên kết tượng trưng (với ZZ0003ZZ)
và tìm kiếm một liên kết tượng trưng trên đường tới một số điểm đến khác có thể
cập nhật thời gian trên liên kết tượng trưng đó.

.. _clearest statement: https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap04.html#tag_04_08

Không rõ tại sao lại như vậy; POSIX có rất ít điều để nói về
chủ đề.  ZZ0000ZZ là, nếu một triển khai cụ thể
cập nhật dấu thời gian ở một nơi không được POSIX chỉ định, điều này phải là
được ghi lại "ngoại trừ bất kỳ thay đổi nào do việc phân giải tên đường dẫn gây ra đều cần
không được ghi lại".  Điều này dường như ngụ ý rằng POSIX không thực sự
quan tâm đến cập nhật thời gian truy cập trong quá trình tra cứu tên đường dẫn.

.. _Linux 1.3.87: https://git.kernel.org/cgit/linux/kernel/git/history/history.git/diff/fs/ext2/symlink.c?id=f806c6db77b8eaa6e00dcfb6b567706feae8dbb8

Kiểm tra lịch sử cho thấy rằng trước ZZ0000ZZ, ext2
ít nhất là hệ thống tập tin không cập nhật khi theo một liên kết.
Thật không may, chúng tôi không có hồ sơ về lý do tại sao hành vi đó lại bị thay đổi.

Trong mọi trường hợp, thời gian truy cập phải được cập nhật và hoạt động đó có thể được thực hiện
khá phức tạp.  Cố gắng duy trì RCU-walk trong khi thực hiện là tốt nhất
tránh được.  May mắn thay, nó thường được phép bỏ qua ZZ0000ZZ
cập nhật.  Bởi vì các bản cập nhật ZZ0001ZZ gây ra vấn đề về hiệu suất ở nhiều khía cạnh khác nhau.
các khu vực, Linux hỗ trợ tùy chọn gắn kết ZZ0002ZZ, thường
giới hạn các bản cập nhật của ZZ0003ZZ một lần mỗi ngày trên các tệp không
đang được thay đổi (và các liên kết tượng trưng không bao giờ thay đổi sau khi được tạo).  Ngay cả khi không có
ZZ0004ZZ, nhiều hệ thống tập tin ghi ZZ0005ZZ với tốc độ một giây
mức độ chi tiết, do đó chỉ cần một lần cập nhật mỗi giây.

Thật dễ dàng để kiểm tra xem có cần cập nhật ZZ0000ZZ khi đang ở RCU-walk hay không
chế độ và nếu không, bản cập nhật có thể bị bỏ qua và chế độ RCU-walk
tiếp tục.  Chỉ khi thực sự cần phải cập nhật ZZ0001ZZ thì
con đường đi bộ thả xuống REF-walk.  Tất cả điều này được xử lý trong
Chức năng ZZ0002ZZ.

Một vài lá cờ
-----------

Một cách thích hợp để kết thúc chuyến tham quan đi bộ theo tên đường này là liệt kê
các cờ khác nhau có thể được lưu trữ trong ZZ0000ZZ để hướng dẫn
quá trình tra cứu.  Nhiều trong số này chỉ có ý nghĩa ở trận chung kết
thành phần, các thành phần khác phản ánh trạng thái hiện tại của việc tra cứu tên đường dẫn và một số
áp dụng các hạn chế cho tất cả các thành phần đường dẫn gặp phải khi tra cứu đường dẫn.

Và sau đó là ZZ0000ZZ, về mặt khái niệm không phù hợp với
những người khác.  Nếu điều này không được đặt, tên đường dẫn trống sẽ gây ra lỗi
từ rất sớm.  Nếu nó được đặt, tên đường dẫn trống sẽ không được coi là
một lỗi.

Cờ quốc gia toàn cầu
~~~~~~~~~~~~~~~~~~

Chúng tôi đã gặp hai lá cờ trạng thái toàn cầu: ZZ0000ZZ và
ZZ0001ZZ.  Những lựa chọn này giữa một trong ba cách tiếp cận tổng thể
để tra cứu: RCU-walk, REF-walk và REF-walk với xác nhận lại bắt buộc.

ZZ0000ZZ chỉ ra rằng thành phần cuối cùng chưa đạt được
chưa.  Điều này chủ yếu được sử dụng để báo cho hệ thống con kiểm toán biết đầy đủ
bối cảnh của một quyền truy cập cụ thể đang được kiểm tra.

ZZ0000ZZ chỉ ra rằng trường ZZ0001ZZ trong ZZ0002ZZ là
do người gọi cung cấp, vì vậy nó sẽ không được giải phóng khi không có
cần thiết lâu hơn.

ZZ0000ZZ có nghĩa là nha khoa hiện tại được chọn không phải vì
nó có tên đúng nhưng vì lý do nào khác.  Điều này xảy ra khi
theo "ZZ0001ZZ", theo liên kết tượng trưng đến ZZ0002ZZ, vượt qua điểm gắn kết
hoặc truy cập liên kết tượng trưng "ZZ0003ZZ" (còn được gọi là "ma thuật
liên kết"). Trong trường hợp này, hệ thống tập tin không được yêu cầu xác nhận lại
tên (với ZZ0004ZZ).  Trong những trường hợp như vậy, inode vẫn có thể cần
được xác nhận lại nên ZZ0005ZZ được gọi nếu
ZZ0006ZZ được đặt khi giao diện hoàn tất - có thể ở
thành phần cuối cùng hoặc khi tạo, hủy liên kết hoặc đổi tên ở thành phần áp chót.

Cờ hạn chế độ phân giải
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Để cho phép không gian người dùng tự bảo vệ mình trước các điều kiện chủng tộc nhất định
và các kịch bản tấn công liên quan đến việc thay đổi các thành phần đường dẫn, một loạt cờ được
có sẵn áp dụng các hạn chế cho tất cả các thành phần đường dẫn gặp phải trong quá trình
tra cứu đường dẫn. Những cờ này được hiển thị thông qua trường ZZ0001ZZ của ZZ0000ZZ.

ZZ0000ZZ chặn tất cả các đường truyền liên kết tượng trưng (bao gồm cả các liên kết ma thuật).
Điều này khác biệt rõ rệt với ZZ0001ZZ, vì ZZ0001ZZ chỉ có
liên quan đến việc hạn chế các liên kết tượng trưng theo sau.

ZZ0000ZZ chặn tất cả các đường truyền liên kết ma thuật. Hệ thống tập tin phải
đảm bảo rằng chúng trả về lỗi từ ZZ0001ZZ, vì đó là cách
ZZ0002ZZ và các hạn chế liên kết ma thuật khác được triển khai.

ZZ0000ZZ chặn tất cả các đường truyền ZZ0001ZZ (bao gồm cả
giá treo liên kết và giá treo thông thường). Lưu ý rằng ZZ0002ZZ chứa
tra cứu được xác định bởi điểm gắn kết đầu tiên mà đường dẫn tra cứu đạt tới --
đường dẫn tuyệt đối bắt đầu bằng ZZ0003ZZ của ZZ0004ZZ và đường dẫn tương đối bắt đầu bằng
với ZZ0006ZZ của ZZ0005ZZ. Liên kết ma thuật chỉ được phép nếu
ZZ0007ZZ của đường dẫn không thay đổi.

ZZ0000ZZ chặn mọi thành phần đường dẫn giải quyết bên ngoài
điểm bắt đầu của nghị quyết. Điều này được thực hiện bằng cách chặn ZZ0001ZZ
cũng như chặn ".." nếu nó nhảy ra ngoài điểm xuất phát.
ZZ0002ZZ và ZZ0003ZZ được sử dụng để phát hiện các cuộc tấn công chống lại
độ phân giải của "..". Các liên kết ma thuật cũng bị chặn.

ZZ0000ZZ giải quyết tất cả các thành phần đường dẫn như điểm bắt đầu
là gốc của hệ thống tập tin. ZZ0001ZZ đưa độ phân giải trở lại
điểm bắt đầu và ".." tại điểm bắt đầu sẽ hoạt động như một điểm không hoạt động. Như với
ZZ0002ZZ, ZZ0003ZZ và ZZ0004ZZ được sử dụng để phát hiện
tấn công chống lại độ phân giải "..". Các liên kết ma thuật cũng bị chặn.

Cờ thành phần cuối cùng
~~~~~~~~~~~~~~~~~~~~~

Một số cờ này chỉ được đặt khi thành phần cuối cùng đang được
được xem xét.  Những người khác chỉ được kiểm tra khi xem xét cuối cùng
thành phần.

ZZ0000ZZ đảm bảo rằng, nếu thành phần cuối cùng là một automount
điểm, sau đó quá trình gắn kết được kích hoạt.  Một số hoạt động sẽ kích hoạt nó
dù sao đi nữa, nhưng các hoạt động như ZZ0001ZZ cố tình không làm như vậy.  ZZ0002ZZ
cần kích hoạt ngàm nhưng mặt khác hoạt động rất giống ZZ0003ZZ, vì vậy
nó đặt ZZ0004ZZ, cũng như "ZZ0005ZZ" và việc xử lý
"ZZ0006ZZ".

ZZ0000ZZ có chức năng tương tự ZZ0001ZZ nhưng dành cho
liên kết tượng trưng.  Một số lệnh gọi hệ thống thiết lập hoặc xóa nó một cách ngầm định, trong khi
những người khác có cờ API như ZZ0002ZZ và
ZZ0003ZZ để điều khiển nó.  Tác dụng của nó tương tự như
ZZ0004ZZ mà chúng ta đã gặp nhưng nó được sử dụng theo một cách khác.

ZZ0000ZZ nhấn mạnh rằng thành phần cuối cùng là một thư mục.
Nhiều người gọi khác nhau đặt cái này và nó cũng được đặt khi thành phần cuối cùng
được tìm thấy theo sau bởi một dấu gạch chéo.

Cuối cùng là ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ và
ZZ0003ZZ không được VFS sử dụng trực tiếp mà được sản xuất
có sẵn cho hệ thống tập tin và đặc biệt là ZZ0004ZZ
phương pháp.  Một hệ thống tập tin có thể chọn không bận tâm đến việc xác nhận lại quá khó
nếu nó biết rằng nó sẽ sớm được yêu cầu mở hoặc tạo tệp.
Những cờ này trước đây cũng hữu ích cho ZZ0005ZZ nhưng với
giới thiệu ZZ0006ZZ chúng ít liên quan hơn ở đó.

Cuối con đường
---------------

Bất chấp sự phức tạp của nó, tất cả mã tra cứu tên đường dẫn này dường như
trong tình trạng tốt - nhiều phần bây giờ chắc chắn dễ hiểu hơn
thậm chí hơn một vài bản phát hành trước đây.  Nhưng điều đó không có nghĩa là nó
"hoàn thành".   Như đã đề cập, RCU-walk hiện chỉ theo sau
các liên kết tượng trưng được lưu trữ trong inode, trong khi nó xử lý nhiều ext4
liên kết tượng trưng, ​​nó không giúp ích gì với NFS, XFS hoặc Btrfs.  Sự hỗ trợ đó
không có khả năng bị trì hoãn lâu.
