.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/backporting.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================
Backport và giải quyết xung đột
======================================

:Tác giả: Vegard Nossum <vegard.nossum@oracle.com>

.. contents::
    :local:
    :depth: 3
    :backlinks: none

Giới thiệu
============

Một số nhà phát triển có thể không bao giờ thực sự phải xử lý các bản vá lỗi backport,
sáp nhập các chi nhánh hoặc giải quyết xung đột trong công việc hàng ngày của họ, vì vậy
khi xung đột hợp nhất xuất hiện, nó có thể gây khó khăn. May mắn thay,
giải quyết xung đột là một kỹ năng giống như bất kỳ kỹ năng nào khác và có rất nhiều kỹ năng hữu ích
các kỹ thuật bạn có thể sử dụng để làm cho quá trình diễn ra suôn sẻ hơn và nâng cao khả năng của bạn.
niềm tin vào kết quả.

Tài liệu này nhằm mục đích trở thành một hướng dẫn toàn diện, từng bước để
backport và giải quyết xung đột.

Áp dụng bản vá cho cây
============================

Đôi khi bản vá bạn đang nhập lại đã tồn tại dưới dạng cam kết git,
trong trường hợp đó bạn chỉ cần chọn nó trực tiếp bằng cách sử dụng
ZZ0000ZZ. Tuy nhiên, nếu bản vá đến từ email, vì nó
thường làm với nhân Linux, bạn sẽ cần áp dụng nó cho cây
sử dụng ZZ0001ZZ.

Nếu bạn đã từng sử dụng ZZ0000ZZ thì có lẽ bạn đã biết nó là
khá kén chọn về bản vá áp dụng hoàn hảo cho cây nguồn của bạn. trong
thực tế, bạn có thể đã gặp ác mộng về các tập tin ZZ0001ZZ và cố gắng
chỉnh sửa bản vá để áp dụng nó.

Thay vào đó, chúng tôi khuyên bạn nên tìm một phiên bản cơ sở thích hợp
nơi bản vá được áp dụng sạch sẽ và ZZ0000ZZ hãy chọn nó cho bạn
cây đích, vì điều này sẽ tạo ra các điểm đánh dấu xung đột đầu ra git và cho phép
bạn giải quyết xung đột với sự trợ giúp của git và bất kỳ xung đột nào khác
công cụ giải quyết mà bạn có thể thích sử dụng. Ví dụ, nếu bạn muốn
áp dụng bản vá vừa có trên LKML cho kernel ổn định cũ hơn, bạn
có thể áp dụng nó cho kernel chính gần đây nhất và sau đó chọn nó
đến chi nhánh ổn định cũ của bạn.

Nói chung, tốt hơn là sử dụng cùng một đế giống như bản vá
được tạo ra từ đó, nhưng điều đó không thực sự quan trọng miễn là nó
áp dụng sạch sẽ và không quá xa cơ sở ban đầu. duy nhất
vấn đề với việc áp dụng miếng vá vào đế "sai" là nó có thể kéo
trong những thay đổi không liên quan hơn trong bối cảnh khác biệt khi hái anh đào
nó đến nhánh cũ hơn.

Một lý do chính đáng để thích ZZ0000ZZ hơn ZZ0001ZZ là vì git
biết lịch sử chính xác của một cam kết hiện có, vì vậy nó sẽ biết khi nào
mã đã di chuyển xung quanh và thay đổi số dòng; điều này lần lượt làm cho
ít có khả năng áp dụng bản vá sai vị trí (điều này có thể dẫn đến
trong những sai lầm thầm lặng hoặc những xung đột lộn xộn).

Nếu bạn đang sử dụng ZZ0006ZZ. và bạn đang áp dụng bản vá trực tiếp từ một
email, bạn có thể sử dụng ZZ0000ZZ với các tùy chọn ZZ0001ZZ/ZZ0002ZZ
và ZZ0003ZZ/ZZ0004ZZ để thực hiện một số việc này một cách tự động (xem phần
ZZ0007ZZ để biết thêm thông tin). Tuy nhiên, phần còn lại này
bài viết sẽ cho rằng bạn đang thực hiện một ZZ0005ZZ đơn giản.

.. _b4: https://people.kernel.org/monsieuricon/introducing-b4-and-patch-attestation
.. _b4 presentation: https://youtu.be/mF10hgVIx9o?t=2996

Khi bạn có bản vá trong git, bạn có thể tiếp tục và chọn nó vào
cây nguồn của bạn. Đừng quên chọn anh đào với ZZ0000ZZ nếu bạn muốn
bản ghi chép về nguồn gốc của bản vá!

Lưu ý rằng nếu bạn đang gửi bản vá cho bản ổn định, định dạng là
hơi khác một chút; dòng đầu tiên sau dòng chủ đề cần phải là
hoặc::

cam kết <cam kết ngược dòng> ngược dòng

hoặc::

[ Cam kết ngược dòng <cam kết ngược dòng> ]

Giải quyết xung đột
===================

Ờ-ồ; Cherry-pick không thành công với một tin nhắn đe dọa mơ hồ::

CONFLICT (nội dung): Hợp nhất xung đột

Phải làm gì bây giờ?

Nói chung, xung đột xuất hiện khi bối cảnh của bản vá (tức là,
các dòng được thay đổi và/hoặc các dòng xung quanh những thay đổi) không
khớp với những gì có trong cây mà bạn đang cố gắng áp dụng bản vá ZZ0000ZZ.

Đối với backport, điều có thể xảy ra là chi nhánh của bạn
backporting từ chứa các bản vá không có trong nhánh bạn đang backporting
đến. Tuy nhiên, điều ngược lại cũng có thể xảy ra. Trong mọi trường hợp, kết quả là một
mâu thuẫn cần giải quyết.

Nếu nỗ lực chọn anh đào của bạn không thành công do xung đột, git sẽ tự động
chỉnh sửa các tập tin để bao gồm cái gọi là điểm đánh dấu xung đột cho bạn biết vị trí
xung đột là gì và hai nhánh đã phân kỳ như thế nào. Giải quyết
xung đột thường có nghĩa là chỉnh sửa kết quả cuối cùng theo cách mà nó
có tính đến những cam kết khác.

Giải quyết xung đột có thể được thực hiện bằng tay trong một văn bản thông thường
trình chỉnh sửa hoặc sử dụng công cụ giải quyết xung đột chuyên dụng.

Nhiều người thích sử dụng trình soạn thảo văn bản thông thường của họ và chỉnh sửa
xung đột trực tiếp, vì có thể dễ hiểu hơn những gì bạn đang làm
và kiểm soát kết quả cuối cùng. Chắc chắn có những ưu và nhược điểm
từng phương pháp và đôi khi có giá trị khi sử dụng cả hai.

Chúng tôi sẽ không đề cập đến việc sử dụng các công cụ hợp nhất chuyên dụng ở đây ngoài việc cung cấp một số
con trỏ tới các công cụ khác nhau mà bạn có thể sử dụng:

-ZZ0000ZZ
-ZZ0001ZZ
-ZZ0002ZZ
-ZZ0003ZZ
-ZZ0004ZZ
-ZZ0005ZZ
-ZZ0006ZZ
-ZZ0007ZZ
-ZZ0008ZZ

Để định cấu hình git hoạt động với những thứ này, hãy xem ZZ0000ZZ hoặc
ZZ0001ZZ chính thức.

.. _git-mergetool documentation: https://git-scm.com/docs/git-mergetool

Các bản vá tiên quyết
--------------------

Hầu hết xung đột xảy ra do nhánh bạn đang chuyển tiếp đến là
thiếu một số bản vá so với nhánh bạn đang backport ZZ0000ZZ.
Trong trường hợp tổng quát hơn (chẳng hạn như sáp nhập hai nhánh độc lập),
sự phát triển có thể đã xảy ra ở một trong hai chi nhánh, hoặc các chi nhánh có
chỉ đơn giản là chuyển hướng -- có lẽ nhánh cũ của bạn có một số cổng sau khác
áp dụng cho nó rằng bản thân họ cần giải quyết xung đột, gây ra một
sự khác biệt.

Điều quan trọng là luôn xác định các cam kết hoặc các cam kết đã gây ra
xung đột, nếu không bạn không thể tin tưởng vào tính đúng đắn của
độ phân giải của bạn. Là một phần thưởng bổ sung, đặc biệt nếu bản vá nằm trong
vực mà bạn không quen thuộc, nhật ký thay đổi của những cam kết này sẽ
thường cung cấp cho bạn ngữ cảnh để hiểu mã và các vấn đề tiềm ẩn
hoặc những cạm bẫy trong việc giải quyết xung đột của bạn.

nhật ký git
~~~~~~~

Bước đầu tiên tốt nhất là xem ZZ0000ZZ để tìm tệp có
xung đột -- điều này thường là đủ khi không có nhiều
vá vào tệp, nhưng có thể gây nhầm lẫn nếu tệp lớn và
thường xuyên được vá. Bạn nên chạy ZZ0001ZZ trên phạm vi xác nhận
giữa chi nhánh hiện đã thanh toán của bạn (ZZ0002ZZ) và phụ huynh của
bản vá bạn đang chọn (ZZ0003ZZ), tức là::

git log HEAD..<commit>^ -- <path>

Thậm chí tốt hơn, nếu bạn muốn hạn chế đầu ra này ở một chức năng duy nhất
(vì đó là nơi xuất hiện xung đột), bạn có thể sử dụng cách sau
cú pháp::

git log -L:'\<function\>':<path> HEAD..<commit>^

.. note::
     The ``\<`` and ``\>`` around the function name ensure that the
     matches are anchored on a word boundary. This is important, as this
     part is actually a regex and git only follows the first match, so
     if you use ``-L:thread_stack:kernel/fork.c`` it may only give you
     results for the function ``try_release_thread_stack_to_cache`` even
     though there are many other functions in that file containing the
     string ``thread_stack`` in their names.

Một tùy chọn hữu ích khác cho ZZ0000ZZ là ZZ0001ZZ, cho phép bạn
lọc trên các chuỗi nhất định xuất hiện trong phần khác biệt của các cam kết mà bạn đang thực hiện
niêm yết::

git log -G'regex' HEAD..<commit>^ -- <path>

Đây cũng có thể là một cách thuận tiện để nhanh chóng tìm thấy khi có thứ gì đó (ví dụ: một
lệnh gọi hàm hoặc một biến) đã được thay đổi, thêm hoặc xóa. Việc tìm kiếm
chuỗi là một biểu thức chính quy, có nghĩa là bạn có thể tìm kiếm
để biết những thứ cụ thể hơn như bài tập cho một thành viên cấu trúc cụ thể ::

git log -G'\->index\>.*='

đổ lỗi cho
~~~~~~~~~

Một cách khác để tìm các cam kết tiên quyết (mặc dù chỉ là các cam kết gần đây nhất
một cho một xung đột nhất định) là chạy ZZ0000ZZ. Trong trường hợp này, bạn
cần chạy nó dựa trên cam kết gốc của bản vá mà bạn đang có
Cherry-picking và tệp xuất hiện xung đột, tức là::

git đổ lỗi <commit>^ -- <path>

Lệnh này cũng chấp nhận đối số ZZ0000ZZ (để hạn chế
xuất ra một hàm duy nhất), nhưng trong trường hợp này bạn chỉ định tên tệp
ở cuối lệnh như thường lệ::

git đổ lỗi -L:'\<function\>' <commit>^ -- <path>

Điều hướng đến nơi xảy ra xung đột. Cột đầu tiên của
đầu ra đổ lỗi là ID cam kết của bản vá đã thêm một dòng nhất định
của mã.

Có thể là một ý tưởng hay đối với ZZ0000ZZ những cam kết này và xem liệu chúng có
có vẻ như họ có thể là nguồn gốc của xung đột. Đôi khi sẽ có
có nhiều hơn một trong số các cam kết này, bởi vì có nhiều cam kết
đã thay đổi các dòng khác nhau của cùng một khu vực xung đột ZZ0002ZZ vì nhiều
các bản vá tiếp theo đã thay đổi cùng một dòng (hoặc các dòng) nhiều lần. trong
trong trường hợp sau, bạn có thể phải chạy lại ZZ0001ZZ và chỉ định
phiên bản cũ hơn của tệp cần xem xét để tìm hiểu sâu hơn về
lịch sử của tập tin.

Điều kiện tiên quyết so với các bản vá ngẫu nhiên
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sau khi tìm thấy bản vá gây ra xung đột, bạn cần xác định
liệu đó có phải là điều kiện tiên quyết cho bản vá mà bạn đang chuyển tiếp hay không
liệu nó chỉ là ngẫu nhiên và có thể bỏ qua. Một bản vá ngẫu nhiên
sẽ là một mã chạm vào cùng mã với bản vá mà bạn đang có
chuyển ngược, nhưng không thay đổi ngữ nghĩa của mã theo bất kỳ cách nào
cách vật chất. Ví dụ, một bản vá dọn dẹp khoảng trắng hoàn toàn
ngẫu nhiên -- tương tự như vậy, một bản vá chỉ đơn giản đổi tên một chức năng hoặc một
biến cũng sẽ là ngẫu nhiên. Mặt khác, nếu hàm
việc thay đổi thậm chí không tồn tại trong nhánh hiện tại của bạn thì điều này sẽ
hoàn toàn không phải ngẫu nhiên và bạn cần xem xét cẩn thận liệu
bản vá thêm chức năng nên được chọn trước.

Nếu bạn thấy rằng có một bản vá tiên quyết cần thiết thì bạn cần
thay vào đó hãy dừng lại và chọn nó. Nếu bạn đã giải quyết được một số
xung đột trong một tệp khác và không muốn lặp lại, bạn có thể
tạo một bản sao tạm thời của tập tin đó.

Để hủy bỏ thao tác chọn anh đào hiện tại, hãy tiếp tục và chạy
ZZ0000ZZ, sau đó khởi động lại quá trình hái anh đào
thay vào đó bằng ID cam kết của bản vá tiên quyết.

Hiểu các dấu hiệu xung đột
------------------------------

khác biệt kết hợp
~~~~~~~~~~~~~~

Giả sử bạn đã quyết định không chọn (hoặc hoàn nguyên) bổ sung
các bản vá và bạn chỉ muốn giải quyết xung đột. Git sẽ có
đã chèn các điểm đánh dấu xung đột vào tệp của bạn. Ra khỏi hộp, cái này sẽ trông như thế này
đại loại như::

<<<<<<< HEAD
    đây là những gì trên cây hiện tại của bạn trước khi hái anh đào
    =======
    đây chính là điều mà bản vá mong muốn sau khi hái anh đào
    >>>>>>> <cam kết>... tiêu đề

Đây là những gì bạn sẽ thấy nếu mở tệp trong trình chỉnh sửa của mình.
Tuy nhiên, nếu bạn chạy ZZ0000ZZ mà không có bất kỳ đối số nào,
đầu ra sẽ trông giống như thế này::

$ git khác biệt
    […]
    ++<<<<<<<< HEAD
     +đây là những gì có trên cây hiện tại của bạn trước khi hái anh đào
    ++========
    + đây chính là điều mà bản vá mong muốn sau khi hái anh đào
    ++>>>>>>>> <cam kết>... tiêu đề

Khi bạn đang giải quyết xung đột, hành vi của ZZ0000ZZ sẽ khác
khỏi hành vi bình thường của nó. Lưu ý hai cột đánh dấu khác biệt
thay vì cái thông thường; đây được gọi là "ZZ0001ZZ", ở đây
hiển thị khác biệt 3 chiều (hoặc khác biệt) giữa

#. chi nhánh hiện tại (trước khi hái anh đào) và chi nhánh hiện tại đang làm việc
   thư mục và
#. nhánh hiện tại (trước khi hái anh đào) và tệp trông như thế nào
   sau khi bản vá gốc đã được áp dụng.

.. _combined diff: https://git-scm.com/docs/diff-format#_combined_diff_format


Khác biệt tốt hơn
~~~~~~~~~~~~

Sự khác biệt kết hợp 3 chiều bao gồm tất cả những thay đổi khác đã xảy ra với
tập tin giữa chi nhánh hiện tại của bạn và chi nhánh bạn đang hái
từ. Mặc dù điều này rất hữu ích trong việc phát hiện những thay đổi khác mà bạn cần
tính đến điều này cũng làm cho đầu ra của ZZ0000ZZ phần nào
đáng sợ và khó đọc. Thay vào đó bạn có thể thích chạy
ZZ0001ZZ (hoặc ZZ0002ZZ) chỉ hiển thị khác biệt
giữa chi nhánh hiện tại trước khi hái anh đào và chi nhánh hiện tại đang làm việc
thư mục. Nó trông như thế này::

$ git khác HEAD
    […]
    +<<<<<<<< HEAD
     đây là những gì trên cây hiện tại của bạn trước khi hái anh đào
    +=========
    +đây chính là điều mà bản vá mong muốn sau khi hái anh đào
    +>>>>>>>> <cam kết>... tiêu đề

Như bạn có thể thấy, điều này giống như bất kỳ khác biệt nào khác và làm cho nó rõ ràng
dòng nào nằm trong nhánh hiện tại và dòng nào đang được thêm vào
bởi vì chúng là một phần của xung đột hợp nhất hoặc bản vá đang được
hái anh đào.

Hợp nhất các kiểu và diff3
~~~~~~~~~~~~~~~~~~~~~~

Kiểu đánh dấu xung đột mặc định được hiển thị ở trên được gọi là ZZ0000ZZ
phong cách. Ngoài ra còn có một kiểu dáng khác, được gọi là ZZ0001ZZ
phong cách, trông như thế này::

<<<<<<< HEAD
    đây là những gì có trên cây hiện tại của bạn trước khi hái anh đào
    ||||||| cha mẹ của <commit> (tiêu đề)
    đây là những gì bản vá dự kiến sẽ tìm thấy ở đó
    =======
    đây là bản vá mong muốn sau khi được áp dụng
    >>>>>>> <cam kết> (tiêu đề)

Như bạn có thể thấy, phần này có 3 phần thay vì 2 và bao gồm những gì git
dự kiến ​​sẽ tìm thấy ở đó nhưng không. Đó là ZZ0000ZZ để sử dụng
phong cách xung đột này vì nó làm cho nó rõ ràng hơn nhiều về bản vá thực sự
đã thay đổi; tức là nó cho phép bạn so sánh các phiên bản trước và sau
của tệp dành cho cam kết mà bạn đang chọn. Điều này cho phép bạn
đưa ra quyết định tốt hơn về cách giải quyết xung đột.

Để thay đổi kiểu đánh dấu xung đột, bạn có thể sử dụng lệnh sau ::

cấu hình git merge.conflictStyle diff3

Có tùy chọn thứ ba, ZZ0000ZZ, được giới thiệu trong ZZ0002ZZ,
có 3 phần giống như ZZ0001ZZ, nhưng có các đường chung
đã bị cắt bớt, làm cho khu vực xung đột nhỏ hơn trong một số trường hợp.

.. _Git 2.35: https://github.blog/2022-01-24-highlights-from-git-2-35/

Lặp lại các giải pháp xung đột
---------------------------------

Bước đầu tiên trong bất kỳ quá trình giải quyết xung đột nào là hiểu được
bản vá bạn đang backport. Đối với nhân Linux, điều này đặc biệt
quan trọng, vì một thay đổi không chính xác có thể dẫn đến toàn bộ hệ thống
gặp sự cố -- hoặc tệ hơn là một lỗ hổng bảo mật chưa được phát hiện.

Việc hiểu bản vá có thể dễ hoặc khó tùy thuộc vào bản vá
chính nó, nhật ký thay đổi và mức độ quen thuộc của bạn với mã đang được thay đổi.
Tuy nhiên, một câu hỏi hay cho mỗi thay đổi (hoặc mỗi phần của bản vá)
có thể là: "Tại sao mảnh này lại có trong bản vá?" Những câu trả lời cho những điều này
các câu hỏi sẽ cho biết cách giải quyết xung đột của bạn.

Quá trình giải quyết
~~~~~~~~~~~~~~~~~~

Đôi khi điều dễ dàng nhất có thể làm là xóa tất cả trừ phần đầu tiên
một phần của xung đột, giữ nguyên tệp về cơ bản không thay đổi và áp dụng
những thay đổi bằng tay. Có lẽ bản vá đang thay đổi lệnh gọi hàm
đối số từ ZZ0000ZZ đến ZZ0001ZZ trong khi một thay đổi xung đột đã thêm một
tham số hoàn toàn mới (và không đáng kể) ở cuối tham số
danh sách; trong trường hợp đó, thật dễ dàng để thay đổi đối số từ ZZ0002ZZ
tới ZZ0003ZZ bằng tay và để nguyên các đối số còn lại. Cái này
kỹ thuật áp dụng các thay đổi theo cách thủ công hầu hết đều hữu ích nếu có xung đột
kéo theo nhiều bối cảnh không liên quan mà bạn không thực sự cần quan tâm
về.

Đối với những xung đột đặc biệt khó chịu với nhiều dấu hiệu xung đột, bạn có thể sử dụng
ZZ0000ZZ hoặc ZZ0001ZZ để điều chỉnh các quyết tâm của bạn một cách có chọn lọc
đưa họ ra khỏi đường đi; điều này cũng cho phép bạn sử dụng ZZ0002ZZ để
luôn xem những gì còn lại cần giải quyết hoặc ZZ0003ZZ để xem
bản vá của bạn trông như thế nào cho đến nay.

Xử lý việc đổi tên tập tin
~~~~~~~~~~~~~~~~~~~~~~~~~

Một trong những điều khó chịu nhất có thể xảy ra khi nhập lại một
patch đang phát hiện ra rằng một trong những tập tin đang được vá đã bị
được đổi tên, vì điều đó thường có nghĩa là git thậm chí sẽ không đưa vào các điểm đánh dấu xung đột,
nhưng sẽ chỉ giơ tay và nói (diễn giải): "Con đường chưa được hợp nhất!
Anh làm việc đi..."

Nói chung có một số cách để giải quyết vấn đề này. Nếu bản vá cho
tập tin được đổi tên có kích thước nhỏ, giống như thay đổi một dòng, cách dễ nhất là
chỉ cần tiếp tục và áp dụng thay đổi bằng tay là xong. Trên
Mặt khác, nếu sự thay đổi lớn hoặc phức tạp, bạn chắc chắn không
muốn làm điều đó bằng tay.

Trong lần vượt qua đầu tiên, bạn có thể thử một cái gì đó như thế này, điều này sẽ làm giảm
đổi tên ngưỡng phát hiện thành 30% (theo mặc định, git sử dụng 50%, nghĩa là
rằng hai tệp cần phải có ít nhất 50% điểm chung để có thể xem xét
một cặp thêm-xóa để có thể đổi tên)::

git Cherry-pick -strategy=đệ quy -Xrename-threshold=30

Đôi khi điều đúng đắn cần làm cũng là cung cấp lại bản vá
đã đổi tên, nhưng đó chắc chắn không phải là trường hợp phổ biến nhất. Thay vào đó,
điều bạn có thể làm là tạm thời đổi tên tệp trong nhánh bạn đang
chuyển ngược sang (sử dụng ZZ0000ZZ và xác nhận kết quả), khởi động lại
cố gắng chọn bản vá, đổi tên tệp trở lại (ZZ0001ZZ và
cam kết lại) và cuối cùng xóa kết quả bằng ZZ0002ZZ
(xem ZZ0003ZZ) để nó xuất hiện dưới dạng một lần xác nhận khi bạn
đã xong.

.. _rebase tutorial: https://medium.com/@slamflipstrom/a-beginners-guide-to-squashing-commits-with-git-rebase-8185cf6e62ec

vấn đề
-------

Đối số hàm
~~~~~~~~~~~~~~~~~~

Hãy chú ý đến việc thay đổi các đối số của hàm! Thật dễ dàng để phủ bóng
chi tiết và nghĩ rằng hai dòng giống nhau nhưng thực ra chúng khác nhau
trong một số chi tiết nhỏ như biến nào được truyền dưới dạng đối số
(đặc biệt nếu hai biến đều là một ký tự đơn trông giống như
giống nhau, giống như i và j).

Xử lý lỗi
~~~~~~~~~~~~~~

Nếu bạn chọn một bản vá bao gồm câu lệnh ZZ0000ZZ (thường
để xử lý lỗi), nhất thiết phải kiểm tra kỹ xem
nhãn mục tiêu vẫn chính xác trong nhánh mà bạn đang chuyển tiếp tới.
Điều tương tự cũng xảy ra với ZZ0001ZZ, ZZ0002ZZ và ZZ0003ZZ được thêm vào
các tuyên bố.

Việc xử lý lỗi thường nằm ở cuối hàm, vì vậy nó
có thể không phải là một phần của xung đột mặc dù nó có thể được thay đổi bởi
các bản vá khác.

Một cách tốt để đảm bảo rằng bạn xem lại các đường dẫn lỗi là luôn sử dụng
ZZ0000ZZ và ZZ0001ZZ (AKA ZZ0002ZZ) khi
kiểm tra những thay đổi của bạn.  Đối với mã C, điều này sẽ hiển thị cho bạn toàn bộ
chức năng đang được thay đổi trong một bản vá. Một trong những điều thường xuyên
xảy ra lỗi trong quá trình backport là có gì đó khác trong hàm đã thay đổi
trên một trong các nhánh mà bạn đang chuyển tiếp từ hoặc tới. Bởi
bao gồm toàn bộ hàm trong phần khác biệt, bạn sẽ có thêm ngữ cảnh và có thể
dễ dàng phát hiện ra các vấn đề hơn mà có thể không được chú ý.

Mã được tái cấu trúc
~~~~~~~~~~~~~~~

Điều xảy ra khá thường xuyên là mã được tái cấu trúc bởi
"phân tích" một chuỗi hoặc mẫu mã phổ biến thành một trình trợ giúp
chức năng. Khi chuyển các bản vá lỗi tới một khu vực có quá trình tái cấu trúc như vậy
đã diễn ra, bạn thực sự cần phải làm ngược lại khi
backporting: một bản vá cho một vị trí có thể cần được áp dụng cho
nhiều vị trí trong phiên bản backport. (Một quà tặng cho việc này
tình huống là một chức năng đã được đổi tên -- nhưng không phải lúc nào cũng như vậy
trường hợp.)

Để tránh các bản backport không đầy đủ, bạn nên cố gắng tìm hiểu xem liệu
bản vá sửa lỗi xuất hiện ở nhiều nơi. Một cách để làm
điều này sẽ là sử dụng ZZ0000ZZ. (Đây thực sự là một ý tưởng hay để làm
nói chung, không chỉ dành cho backport.) Nếu bạn tìm thấy loại tương tự
sửa chữa sẽ áp dụng cho những nơi khác, cũng đáng để xem liệu những điều đó
những nơi tồn tại ở thượng nguồn -- nếu không, có thể bản vá có thể cần
để được điều chỉnh. ZZ0001ZZ là bạn của bạn để tìm hiểu chuyện gì đã xảy ra
tới những khu vực này vì ZZ0002ZZ sẽ không hiển thị cho bạn mã đã được
bị loại bỏ.

Nếu bạn tìm thấy các trường hợp khác có cùng mẫu trong cây ngược dòng
và bạn không chắc liệu đó có phải là lỗi hay không, bạn nên hỏi
tác giả vá. Không có gì lạ khi tìm thấy lỗi mới trong quá trình nhập ngược!

Xác minh kết quả
====================

khác biệt màu sắc
---------

Sau khi đưa ra bản vá mới không có xung đột, giờ đây bạn có thể so sánh
vá vào bản vá ban đầu. Chúng tôi khuyên bạn nên sử dụng một
công cụ như ZZ0000ZZ có thể hiển thị hai tệp cạnh nhau và màu sắc
chúng theo những thay đổi giữa chúng::

colordiff -yw -W 200 <(git diff -W <commit ngược dòng>^-) <(git diff -W HEAD^-) | ít -SR

.. _colordiff: https://www.colordiff.org/

Ở đây, ZZ0000ZZ có nghĩa là thực hiện so sánh song song; ZZ0001ZZ bỏ qua
khoảng trắng và ZZ0002ZZ đặt độ rộng của đầu ra (nếu không thì nó
sẽ sử dụng 130 theo mặc định, thường hơi quá ít).

Về cơ bản, cú pháp ZZ0000ZZ là một cách viết tắt tiện dụng của ZZ0001ZZ.
chỉ cung cấp cho bạn sự khác biệt cho lần cam kết đó; cũng thấy
ZZ0002ZZ chính thức.

.. _git rev-parse documentation: https://git-scm.com/docs/git-rev-parse#_other_rev_parent_shorthand_notations

Một lần nữa, hãy lưu ý việc bao gồm ZZ0000ZZ cho ZZ0001ZZ; điều này đảm bảo rằng
bạn sẽ thấy chức năng đầy đủ cho bất kỳ chức năng nào đã thay đổi.

Một điều cực kỳ quan trọng mà colordiff thực hiện là làm nổi bật các đường nét
đó là khác nhau. Ví dụ: nếu ZZ0000ZZ xử lý lỗi có
đã thay đổi nhãn giữa bản vá gốc và bản vá được nhập ngược, colordiff sẽ
hiển thị những thứ này cạnh nhau nhưng được đánh dấu bằng màu khác.  Vì vậy, nó
dễ dàng nhận thấy rằng hai câu lệnh ZZ0001ZZ đang nhảy sang các vị trí khác nhau
nhãn. Tương tự như vậy, các dòng không được sửa đổi bởi bản vá nhưng
khác nhau trong bối cảnh cũng sẽ được làm nổi bật và do đó nổi bật trong suốt quá trình
một cuộc kiểm tra thủ công.

Tất nhiên, đây chỉ là kiểm tra trực quan; bài kiểm tra thực sự đang được xây dựng
và chạy kernel (hoặc chương trình) đã vá.

Xây dựng thử nghiệm
-------------

Chúng tôi sẽ không đề cập đến việc kiểm tra thời gian chạy ở đây nhưng có thể là một ý tưởng hay nếu bạn xây dựng
chỉ các tập tin được bản vá chạm vào để kiểm tra tình trạng nhanh chóng. Đối với
Nhân Linux, bạn có thể xây dựng các tệp đơn lẻ như thế này, giả sử bạn có
ZZ0000ZZ và môi trường xây dựng được thiết lập chính xác::

tạo đường dẫn/đến/file.o

Lưu ý rằng thao tác này sẽ không phát hiện ra lỗi liên kết, vì vậy bạn vẫn nên thực hiện
bản dựng đầy đủ sau khi xác minh rằng tệp đơn đã biên dịch. Bằng cách biên soạn
trước tiên, bạn có thể tránh phải chờ bản dựng đầy đủ *in
case* có lỗi trình biên dịch trong bất kỳ tệp nào bạn đã thay đổi.

Kiểm tra thời gian chạy
---------------

Ngay cả một bản dựng hoặc thử nghiệm khởi động thành công cũng không nhất thiết đủ để thống trị
ra một sự phụ thuộc bị thiếu ở đâu đó. Mặc dù cơ hội là rất nhỏ,
có thể có những thay đổi về mã trong đó có hai thay đổi độc lập đối với cùng một
kết quả là không có xung đột, không có lỗi thời gian biên dịch và lỗi thời gian chạy
chỉ trong những trường hợp ngoại lệ.

Một ví dụ cụ thể về điều này là một cặp bản vá cho lệnh gọi hệ thống
mã nhập trong đó bản vá đầu tiên đã lưu/khôi phục một sổ đăng ký và bản vá sau đó
bản vá đã sử dụng cùng một thanh ghi ở đâu đó ở giữa phần này
trình tự. Vì không có sự chồng chéo giữa các thay đổi nên người ta có thể
chọn bản vá thứ hai, không có xung đột và tin rằng
mọi thứ đều ổn, trong khi thực tế là đoạn mã hiện đang viết nguệch ngoạc trên một
sổ đăng ký chưa được lưu.

Mặc dù phần lớn các lỗi sẽ được phát hiện trong quá trình biên dịch
hoặc bằng cách thực thi mã một cách hời hợt, cách duy nhất để xác minh ZZ0000ZZ
một backport là để xem xét bản vá cuối cùng với cùng mức độ xem xét kỹ lưỡng
như bạn sẽ (hoặc nên) cung cấp cho bất kỳ bản vá nào khác. Có bài kiểm tra đơn vị và
kiểm tra hồi quy hoặc các loại kiểm tra tự động khác có thể giúp tăng
sự tin tưởng vào tính đúng đắn của một backport.

Gửi backport tới ổn định
==============================

Khi những người bảo trì ổn định cố gắng chọn các bản sửa lỗi cho đường dây chính của họ
hạt nhân ổn định, họ có thể gửi email yêu cầu backport khi
gặp phải xung đột, xem ví dụ:
<ZZ0000ZZ
Những email này thường bao gồm các bước chính xác mà bạn cần để chọn
bản vá vào đúng cây và gửi bản vá.

Một điều cần đảm bảo là nhật ký thay đổi của bạn phù hợp với dự kiến
định dạng::

<tiêu đề bản vá gốc>

[ Cam kết ngược dòng <chính tuyến rev> ]

<phần còn lại của nhật ký thay đổi ban đầu>
  [ <tóm tắt các xung đột và cách giải quyết> ]
  Người đăng ký: <tên và email của bạn>

Dòng "Cam kết ngược dòng" đôi khi hơi khác một chút tùy thuộc vào
phiên bản ổn định. Phiên bản cũ hơn sử dụng định dạng này::

cam kết <mainline rev> ngược dòng.

Thông thường nhất là chỉ ra phiên bản kernel mà bản vá áp dụng cho
trong dòng chủ đề email (sử dụng ví dụ:
ZZ0000ZZ), nhưng bạn cũng có thể đặt
nó trong vùng Signed-off-by:-area hoặc bên dưới dòng ZZ0001ZZ.

Những người bảo trì ổn định mong đợi các bản đệ trình riêng biệt cho từng hoạt động
phiên bản ổn định và mỗi lần gửi cũng phải được kiểm tra riêng.

Một vài lời khuyên cuối cùng
===========================

1) Tiếp cận quá trình backport với sự khiêm tốn.
2) Hiểu bản vá bạn đang backport; điều này có nghĩa là đọc cả hai
   nhật ký thay đổi và mã.
3) Hãy trung thực về sự tin tưởng của bạn vào kết quả khi nộp hồ sơ
   vá.
4) Hỏi những người bảo trì có liên quan để biết các xác nhận rõ ràng.

Ví dụ
========

Phần trên cho thấy đại khái quy trình lý tưởng hóa của việc nhập lại một bản vá.
Để biết ví dụ cụ thể hơn, hãy xem video hướng dẫn này trong đó có hai bản vá
được chuyển từ dòng chính sang ổn định:
ZZ0000ZZ.

.. _Backporting Linux Kernel Patches: https://youtu.be/sBR7R1V2FeA