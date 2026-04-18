.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/maintainer-netdev.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _netdev-FAQ:

================================
Hệ thống con mạng (netdev)
=============================

tl;dr
-----

- chỉ định bản vá của bạn cho một cái cây - ZZ0000ZZ hoặc ZZ0001ZZ
 - để sửa lỗi, cần có thẻ ZZ0002ZZ, bất kể cây
 - không đăng loạt bài lớn (> 15 bản vá), chia nhỏ chúng ra
 - không đăng lại các bản vá của bạn trong vòng 24 giờ
 - đảo ngược cây xmas

netdev
------

netdev là danh sách gửi thư cho tất cả nội dung liên quan đến mạng Linux.  Cái này
bao gồm mọi thứ được tìm thấy trong net/ (tức là mã lõi như IPv6) và
driver/net (tức là trình điều khiển dành riêng cho phần cứng) trong cây nguồn Linux.

Lưu ý rằng một số hệ thống con (ví dụ: trình điều khiển không dây) có tốc độ cao
lưu lượng truy cập có danh sách gửi thư và cây cụ thể của riêng họ.

Giống như nhiều danh sách gửi thư Linux khác, danh sách netdev được lưu trữ tại
kernel.org với kho lưu trữ có sẵn tại ZZ0000ZZ

Ngoài các hệ thống con như đã đề cập ở trên, tất cả các hệ thống liên quan đến mạng
Quá trình phát triển Linux (tức là RFC, đánh giá, nhận xét, v.v.) diễn ra trên
netdev.

Chu kỳ phát triển
-----------------

Dưới đây là một chút thông tin cơ bản về
nhịp độ phát triển của Linux.  Mỗi bản phát hành mới bắt đầu bằng một
"cửa sổ hợp nhất" hai tuần trong đó những người bảo trì chính cung cấp nội dung mới của họ
tới Linus để sáp nhập vào cây chính.  Sau hai tuần,
cửa sổ hợp nhất bị đóng và nó được gọi/gắn thẻ ZZ0000ZZ.  Không có gì mới
sau này các tính năng sẽ được đưa vào chính thức -- chỉ có các bản sửa lỗi cho nội dung RC1 là
mong đợi.  Sau khoảng một tuần thu thập các bản sửa lỗi cho nội dung RC1,
RC2 được phát hành.  Điều này lặp lại hàng tuần cho đến khi RC7
(thông thường; đôi khi RC6 nếu mọi thứ yên tĩnh hoặc rc8 nếu mọi thứ đang trong tình trạng ổn định
trạng thái rời bỏ) và một tuần sau khi vX.Y-rcN cuối cùng được thực hiện,
vX.Y chính thức được phát hành.

Để tìm hiểu xem chúng ta đang ở đâu trong chu kỳ - hãy tải dòng chính (Linus)
trang ở đây:

ZZ0000ZZ

và lưu ý phần đầu của phần "thẻ".  Nếu là RC1 thì còn sớm
chu kỳ phát triển.  Nếu nó được gắn thẻ RC7 một tuần trước thì bản phát hành sẽ là
có lẽ sắp xảy ra. Nếu thẻ gần đây nhất là thẻ phát hành cuối cùng
(không có hậu tố ZZ0000ZZ) - rất có thể chúng tôi đang ở trong một cửa sổ hợp nhất
và ZZ0001ZZ bị đóng.

cây git và dòng chảy vá
------------------------

Có hai cây mạng (kho git) đang hoạt động.  Cả hai đều là
được điều hành bởi David Miller, người bảo trì mạng chính.  Có
Cây ZZ0000ZZ và cây ZZ0001ZZ.  Như bạn có thể đoán từ
tên, cây ZZ0002ZZ dành cho các bản sửa lỗi cho mã hiện có trong
cây chính từ Linus và ZZ0003ZZ là nơi chứa mã mới
cho lần phát hành trong tương lai.  Bạn có thể tìm thấy cây ở đây:

-ZZ0000ZZ
-ZZ0001ZZ

Liên quan đến việc phát triển hạt nhân: Vào đầu tuần thứ 2
cửa sổ hợp nhất, cây ZZ0000ZZ sẽ bị đóng - không có thay đổi/tính năng mới.
Nội dung mới tích lũy trong ~10 tuần qua sẽ được chuyển vào
mainline/Linus thông qua yêu cầu kéo cho vX.Y -- đồng thời,
Cây ZZ0001ZZ sẽ bắt đầu tích lũy các bản sửa lỗi cho nội dung được kéo này
liên quan đến vX.Y

Thông báo cho biết khi nào ZZ0000ZZ đã bị đóng
gửi tới netdev, nhưng biết những điều trên thì bạn có thể đoán trước được điều đó.

.. warning::
  Do not send new ``net-next`` content to netdev during the
  period during which ``net-next`` tree is closed.

Các bản vá RFC chỉ được gửi để xem xét rõ ràng là được hoan nghênh bất cứ lúc nào
(sử dụng ZZ0000ZZ với ZZ0001ZZ).

Ngay sau khi hai tuần trôi qua (và vX.Y-rc1 được phát hành),
cây cho ZZ0000ZZ mở lại để thu thập nội dung cho lần tiếp theo (vX.Y+1)
thả ra.

Nếu bạn chưa đăng ký netdev và/hoặc đơn giản là không chắc chắn liệu
ZZ0000ZZ đã mở lại chưa, bạn chỉ cần kiểm tra git ZZ0001ZZ
liên kết kho lưu trữ ở trên cho bất kỳ cam kết mới nào liên quan đến mạng.  Bạn có thể
đồng thời kiểm tra trang web sau để biết trạng thái hiện tại:

ZZ0000ZZ

Cây ZZ0000ZZ tiếp tục thu thập các bản sửa lỗi cho nội dung vX.Y và
được phản hồi lại Linus theo định kỳ (~ hàng tuần).  Có nghĩa là
trọng tâm của ZZ0001ZZ là ổn định và sửa lỗi.

Cuối cùng, vX.Y được giải phóng và toàn bộ chu trình bắt đầu lại.

đánh giá bản vá netdev
-------------------

.. _patch_status:

Trạng thái bản vá
~~~~~~~~~~~~

Trạng thái của một bản vá có thể được kiểm tra bằng cách xem bản vá chính
hàng đợi cho netdev:

ZZ0000ZZ

Trường "Trạng thái" sẽ cho bạn biết chính xác mọi thứ đang diễn ra với
vá:

======================================================================================
Trạng thái bản vá Mô tả
======================================================================================
Mới, Đang được xem xét đang chờ xem xét, bản vá nằm trong hàng chờ của người bảo trì
                   xem xét; hai trạng thái được sử dụng thay thế cho nhau (tùy thuộc vào
                   người đồng bảo trì chính xác xử lý sự chắp vá vào thời điểm đó)
Bản vá được chấp nhận đã được áp dụng cho cây mạng thích hợp, đây là
                   thường được thiết lập tự động bởi pw-bot
Cần ACK đang chờ xác nhận từ chuyên gia trong khu vực hoặc thử nghiệm
Bản vá được yêu cầu chưa vượt qua được quá trình xem xét, dự kiến sẽ có bản sửa đổi mới
                   với mã thích hợp và cam kết thay đổi thông báo
Bản vá bị từ chối đã bị từ chối và dự kiến sẽ không có bản sửa đổi mới
Bản vá không áp dụng dự kiến sẽ được áp dụng bên ngoài mạng
                   hệ thống con
Đang chờ bản vá ngược dòng nên được xem xét và xử lý bởi cơ quan thích hợp
                   người bảo trì phụ, người sẽ gửi nó tới các cây mạng;
                   các bản vá được đặt thành ZZ0000ZZ trong bản vá của netdev
                   thường sẽ vẫn ở trạng thái này, cho dù người bảo trì phụ
                   yêu cầu thay đổi, chấp nhận hoặc từ chối bản vá
Bản vá bị trì hoãn cần được đăng lại sau, thường là do phụ thuộc
                   hoặc bởi vì nó đã được đăng cho một cây đã đóng cửa
Phiên bản mới được thay thế của bản vá đã được đăng, thường được thiết lập bởi
                   pw-bot
RFC không được áp dụng, thường không nằm trong hàng đợi đánh giá của người bảo trì,
                   pw-bot có thể tự động thiết lập các bản vá ở trạng thái này dựa trên
                   trên thẻ chủ đề
======================================================================================

Các bản vá được lập chỉ mục theo tiêu đề ZZ0000ZZ của email
đã mang chúng nên nếu bạn gặp khó khăn khi tìm thấy bản vá của mình, hãy nối thêm
giá trị của ZZ0001ZZ đến URL ở trên.

Cập nhật trạng thái bản vá
~~~~~~~~~~~~~~~~~~~~~

Người đóng góp và người đánh giá không có quyền cập nhật bản vá
trạng thái trực tiếp trong chắp vá. Chắp vá không lộ nhiều thông tin
về lịch sử trạng thái của các bản vá, do đó có nhiều
mọi người cập nhật trạng thái dẫn đến nhầm lẫn.

Thay vì ủy quyền các quyền chắp vá, netdev sử dụng một thư đơn giản
bot tìm kiếm các lệnh/dòng đặc biệt trong các email được gửi tới
danh sách gửi thư. Ví dụ: để đánh dấu một chuỗi là Đã yêu cầu thay đổi
người ta cần gửi dòng sau vào bất cứ đâu trong chuỗi email ::

pw-bot: yêu cầu thay đổi

Kết quả là bot sẽ đặt toàn bộ chuỗi thành Thay đổi được yêu cầu.
Điều này có thể hữu ích khi tác giả phát hiện ra lỗi trong bộ truyện của chính họ
và muốn ngăn chặn nó được áp dụng.

Việc sử dụng bot là hoàn toàn tùy chọn, nếu nghi ngờ hãy bỏ qua sự tồn tại của nó
hoàn toàn. Người bảo trì sẽ phân loại và cập nhật trạng thái của các bản vá
chính họ. Không bao giờ được gửi email vào danh sách với mục đích chính
khi giao tiếp với bot, các lệnh của bot sẽ được xem dưới dạng siêu dữ liệu.

Việc sử dụng bot được giới hạn ở các tác giả của các bản vá (ZZ0000ZZ
tiêu đề khi gửi bản vá và lệnh phải khớp!), người duy trì
mã đã sửa đổi theo tệp MAINTAINERS (một lần nữa, ZZ0001ZZ
phải phù hợp với mục nhập MAINTAINERS) và một số người đánh giá cao cấp.

Bot ghi lại hoạt động của nó ở đây:

ZZ0000ZZ

Xem lại mốc thời gian
~~~~~~~~~~~~~~~~

Nói chung, các bản vá được xử lý nhanh chóng (trong vòng chưa đầy
48h). Nhưng hãy kiên nhẫn, nếu bản vá của bạn hoạt động ở chế độ chắp vá (tức là nó
liệt kê trong danh sách bản vá của dự án) khả năng nó bị bỏ sót là gần bằng không.

Khối lượng phát triển cao trên netdev khiến người đánh giá tiếp tục
từ các cuộc thảo luận tương đối nhanh chóng. Nhận xét và trả lời mới
rất khó có thể đến sau một tuần im lặng. Nếu một bản vá
không còn hoạt động trong chế độ chắp vá và chuỗi này không còn hoạt động nữa
hơn một tuần - làm rõ các bước tiếp theo và/hoặc đăng phiên bản tiếp theo.

Cụ thể đối với các bài đăng RFC, nếu không có ai phản hồi sau một tuần - người đánh giá
hoặc bỏ lỡ bài đăng hoặc không có ý kiến ​​mạnh mẽ. Nếu mã đã sẵn sàng,
đăng lại dưới dạng PATCH.

Những email chỉ nói "ping" hoặc "bump" được coi là thô lỗ. Nếu bạn không thể hình dung
đưa ra trạng thái của bản vá từ bản vá hoặc nơi cuộc thảo luận đã diễn ra
đã hạ cánh - mô tả dự đoán tốt nhất của bạn và hỏi xem nó có đúng không. Ví dụ::

Tôi không hiểu các bước tiếp theo là gì. Người X có vẻ không vui
  với A, tôi có nên làm B và đăng lại các bản vá không?

.. _Changes requested:

Đã yêu cầu thay đổi
~~~~~~~~~~~~~~~~~

Bản vá ZZ0000ZZ như ZZ0001ZZ cần
được sửa đổi. Phiên bản mới sẽ đi kèm với nhật ký thay đổi,
tốt nhất là bao gồm các liên kết đến các bài đăng trước đó, ví dụ::

[PATCH net-next v3] net: làm bò kêu moo

Ngay cả những người dùng không uống sữa cũng thích nghe tiếng bò kêu "moo".

Số lượng mooing sẽ phụ thuộc vào tốc độ gói nên phải phù hợp
  chu kỳ ngày đêm khá tốt.

Người đăng ký: Joe Defarmer <joe@barn.org>
  ---
  v3:
    - thêm ghi chú về sự biến động của thời gian trong ngày vào thông báo cam kết
  v2: ZZ0000ZZ
    - sửa đối số bị thiếu trong tài liệu kernel cho netif_is_bovine()
    - sửa lỗi rò rỉ bộ nhớ trong netdev_register_cow()
  v1: ZZ0001ZZ

Thông báo cam kết cần được sửa đổi để trả lời bất kỳ câu hỏi nào của người đánh giá
đã phải hỏi trong các cuộc thảo luận trước đó. Thỉnh thoảng cập nhật
thông báo cam kết sẽ là thay đổi duy nhất trong phiên bản mới.

Gửi lại một phần
~~~~~~~~~~~~~~~

Vui lòng luôn gửi lại toàn bộ loạt bản vá và đảm bảo bạn đánh số
các bản vá rõ ràng rằng đây là bộ bản vá mới nhất và tuyệt vời nhất
điều đó có thể được áp dụng. Đừng cố gắng chỉ gửi lại các bản vá đã thay đổi.

Xử lý các bản vá bị áp dụng sai
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Đôi khi một loạt bản vá được áp dụng trước khi nhận được phản hồi quan trọng,
hoặc phiên bản sai của một chuỗi sẽ được áp dụng.

Không thể làm cho bản vá biến mất sau khi nó được đẩy ra ngoài, cam kết
lịch sử trong cây netdev là bất biến.
Vui lòng gửi các phiên bản gia tăng dựa trên những gì đã được hợp nhất để khắc phục
các bản vá sẽ trông như thế nào nếu loạt bản vá mới nhất của bạn được phát hành
sáp nhập.

Trong trường hợp cần hoàn nguyên toàn bộ, phải gửi lại hoàn nguyên
như một bản vá cho danh sách với thông báo cam kết giải thích các vấn đề kỹ thuật
vấn đề với cam kết hoàn nguyên. Việc hoàn nguyên nên được sử dụng như là phương sách cuối cùng,
khi thay đổi ban đầu là sai hoàn toàn; các bản sửa lỗi tăng dần được ưu tiên.

Cây ổn định
~~~~~~~~~~~

Mặc dù trước đây việc gửi netdev không được cho phép
để mang các thẻ ZZ0001ZZ rõ ràng không còn
vụ việc ngày hôm nay. Hãy làm theo các quy tắc ổn định tiêu chuẩn trong
ZZ0000ZZ,
và đảm bảo bạn bao gồm các thẻ Bản sửa lỗi thích hợp!

Sửa lỗi bảo mật
~~~~~~~~~~~~~~

Đừng gửi email trực tiếp cho người bảo trì netdev nếu bạn cho rằng mình đã phát hiện ra
một lỗi có thể có liên quan đến bảo mật.
Người bảo trì netdev hiện tại đã liên tục yêu cầu rằng
mọi người sử dụng danh sách gửi thư và không liên hệ trực tiếp.  Nếu bạn không
Được rồi, vậy thì có lẽ hãy xem xét gửi thư security@kernel.org hoặc
đọc về ZZ0000ZZ
các cơ chế thay thế có thể.


Đồng đăng các thay đổi đối với các thành phần không gian người dùng
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mã không gian người dùng thực hiện các tính năng kernel nên được đăng
bên cạnh các bản vá kernel. Điều này mang lại cho người đánh giá cơ hội để xem
cách sử dụng bất kỳ giao diện mới nào và nó hoạt động tốt như thế nào.

Khi các công cụ không gian người dùng nằm trong kernel repo, mọi thay đổi
nói chung nên có dạng một chuỗi. Nếu chuỗi trở nên quá lớn
hoặc dự án không gian người dùng chưa được xem xét trên netdev, hãy bao gồm một liên kết
đến một kho lưu trữ công khai nơi có thể nhìn thấy các bản vá không gian người dùng.

Trong trường hợp công cụ không gian người dùng tồn tại trong một kho lưu trữ riêng biệt nhưng được
được xem xét trên kernel netdev (ví dụ: các bản vá cho công cụ ZZ0000ZZ) và
các bản vá không gian người dùng sẽ tạo thành các chuỗi (chủ đề) riêng biệt khi được đăng
vào danh sách gửi thư, ví dụ::

[PATCH net-next 0/3] net: một số thư xin việc về tính năng
   └─ [PATCH net-next 1/3] net: chuẩn bị một số tính năng
   └─ [PATCH net-next 2/3] net: một số tính năng làm được điều đó
   └─ [PATCH net-next 3/3] selftest: net: một số tính năng

[PATCH iproute2-next] ip: thêm hỗ trợ cho một số tính năng

Việc đăng bài dưới dạng một chủ đề không được khuyến khích vì nó gây nhầm lẫn cho việc chắp vá
(kể từ bản chắp vá 2.2.2).

Tự kiểm tra đồng đăng
~~~~~~~~~~~~~~~~~~~~

Các bài tự kiểm tra phải nằm trong cùng một chuỗi khi mã thay đổi.
Cụ thể để sửa lỗi, cả thay đổi mã và kiểm tra liên quan đều phải được thực hiện
cùng một cây (các bài kiểm tra có thể thiếu thẻ Fixes, dự kiến).
Không nên kết hợp các thay đổi mã và thay đổi kiểm tra trong một lần xác nhận.

Đang chuẩn bị thay đổi
-----------------

Chú ý đến chi tiết là quan trọng.  Đọc lại tác phẩm của chính bạn như thể bạn là
người đánh giá.  Bạn có thể bắt đầu bằng việc sử dụng ZZ0000ZZ, thậm chí có thể với
cờ ZZ0001ZZ.  Nhưng đừng trở thành người máy một cách thiếu suy nghĩ khi làm như vậy.
Nếu thay đổi của bạn là một bản sửa lỗi, hãy đảm bảo rằng nhật ký cam kết của bạn cho biết
triệu chứng có thể nhìn thấy của người dùng cuối, lý do cơ bản tại sao nó xảy ra,
và sau đó, nếu cần, hãy giải thích lý do tại sao cách khắc phục được đề xuất là cách tốt nhất để
hoàn thành công việc.  Đừng viết sai khoảng trắng, và như thường lệ, đừng
đối số hàm thụt lề sai kéo dài trên nhiều dòng.  Nếu nó là của bạn
bản vá đầu tiên, hãy gửi nó cho chính bạn để bạn có thể thử áp dụng nó cho một
cây chưa được vá để xác nhận cơ sở hạ tầng không làm hỏng nó.

Cuối cùng, quay lại và đọc
ZZ0000ZZ
để chắc chắn rằng bạn không lặp lại một số lỗi phổ biến được ghi lại ở đó.

Chỉ ra cây mục tiêu
~~~~~~~~~~~~~~~~~~~~~~

Để giúp người bảo trì và bot CI, bạn nên đánh dấu rõ ràng cây nào
bản vá của bạn đang nhắm mục tiêu. Giả sử bạn sử dụng git, hãy sử dụng tiền tố
cờ::

git format-patch --subject-prefix='PATCH net-next' start..finish

Sử dụng ZZ0000ZZ thay vì ZZ0001ZZ (luôn luôn viết thường) ở trên cho
sửa lỗi nội dung ZZ0002ZZ.

Chia công việc thành các bản vá
~~~~~~~~~~~~~~~~~~~~~~~~~~

Hãy đặt mình vào vị trí của người đánh giá. Mỗi bản vá được đọc riêng
và do đó sẽ tạo thành một bước đi dễ hiểu hướng tới mục tiêu đã nêu của bạn
mục tiêu.

Tránh gửi chuỗi dài hơn 15 bản vá. Chuỗi lớn hơn mất nhiều thời gian hơn
để xem xét vì người đánh giá sẽ trì hoãn việc xem xét nó cho đến khi họ tìm thấy một lượng lớn
một đoạn thời gian. Một loạt nhỏ có thể được xem xét trong thời gian ngắn, vì vậy Người bảo trì
cứ làm đi. Kết quả là một chuỗi các chuỗi nhỏ hơn được hợp nhất nhanh hơn và
với phạm vi đánh giá tốt hơn. Đăng lại loạt bài lớn cũng làm tăng lượng gửi thư
liệt kê lưu lượng truy cập.

Hạn chế các bản vá còn sót lại trong danh sách gửi thư
-----------------------------------------

Tránh có nhiều hơn 15 bản vá trên tất cả các dòng, nổi bật dành cho
xem xét danh sách gửi thư cho một cây. Nói cách khác, tối đa
15 bản vá đang được xem xét trên mạng và tối đa 15 bản vá đang được xem xét trên
net-tiếp theo.

Giới hạn này nhằm mục đích tập trung nỗ lực của nhà phát triển vào việc thử nghiệm các bản vá trước
đánh giá ngược dòng. Hỗ trợ chất lượng của các bản đệ trình ngược dòng và giảm bớt các thủ tục
tải về người đánh giá.

.. _rcs:

Thứ tự biến cục bộ ("cây Giáng sinh đảo ngược", "RCS")
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Netdev có quy ước sắp xếp thứ tự các biến cục bộ trong hàm.
Sắp xếp các dòng khai báo biến dài nhất đến ngắn nhất, ví dụ:::

danh sách phân tán cấu trúc *sg;
  cấu trúc sk_buff *skb;
  int err, tôi;

Nếu có sự phụ thuộc giữa các biến cản trở việc sắp xếp thứ tự
di chuyển việc khởi tạo ra khỏi dòng.

Ưu tiên định dạng
~~~~~~~~~~~~~~~~~

Khi làm việc với mã hiện có sử dụng định dạng không chuẩn,
mã của bạn tuân theo các nguyên tắc mới nhất để cuối cùng tất cả mã
trong miền netdev có định dạng ưa thích.

Sử dụng cấu trúc do thiết bị quản lý và cleanup.h
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Netdev vẫn hoài nghi về lời hứa của tất cả các API "tự động dọn dẹp",
bao gồm cả những người trợ giúp ZZ0000ZZ, theo lịch sử. Họ không phải là người được ưa thích
phong cách thực hiện, chỉ đơn thuần là một phong cách có thể chấp nhận được.

Việc sử dụng ZZ0000ZZ không được khuyến khích trong bất kỳ chức năng nào dài hơn 20 dòng,
ZZ0001ZZ được coi là dễ đọc hơn. Sử dụng khóa/mở khóa thông thường là
vẫn (yếu) được ưa thích.

Cấu trúc dọn dẹp ở mức độ thấp (chẳng hạn như ZZ0000ZZ) có thể được sử dụng khi xây dựng
API và trình trợ giúp, đặc biệt là các trình vòng lặp có phạm vi. Tuy nhiên, việc sử dụng trực tiếp
ZZ0001ZZ trong lõi mạng và trình điều khiển không được khuyến khích.
Hướng dẫn tương tự áp dụng cho việc khai báo các biến ở giữa hàm.

Các bản vá dọn dẹp
~~~~~~~~~~~~~~~~

Netdev không khuyến khích các bản vá thực hiện việc dọn dẹp đơn giản, không có trong
bối cảnh của công việc khác. Ví dụ:

* Giải quyết ZZ0001ZZ và các cảnh báo về kiểu mã hóa tầm thường khác
* Giải quyết các vấn đề về ZZ0000ZZ
* Chuyển đổi sang API do thiết bị quản lý (người trợ giúp ZZ0002ZZ)

Điều này là do người ta cảm thấy rằng sự hỗn loạn do những thay đổi đó tạo ra
với chi phí lớn hơn giá trị của việc dọn dẹp đó.

Ngược lại, việc sửa lỗi chính tả và ngữ pháp không được khuyến khích.

Gửi lại sau khi xem xét
~~~~~~~~~~~~~~~~~~~~~~

Cho phép ít nhất 24 giờ trôi qua giữa các bài đăng. Điều này sẽ đảm bảo cho người đánh giá
từ mọi vị trí địa lý đều có cơ hội tham gia. Đừng chờ đợi
quá dài (tuần) giữa các bài đăng vì điều này sẽ gây khó khăn hơn cho người đánh giá
để nhớ lại tất cả bối cảnh.

Đảm bảo bạn giải quyết tất cả các phản hồi trong bài đăng mới của mình. Đừng đăng bài mới
phiên bản mã nếu cuộc thảo luận về phiên bản trước đó vẫn còn
đang diễn ra, trừ khi được người đánh giá trực tiếp hướng dẫn.

Phiên bản mới của các bản vá lỗi sẽ được đăng dưới dạng một chủ đề riêng biệt,
không phải là một câu trả lời cho bài đăng trước đó. Nhật ký thay đổi phải bao gồm một liên kết
tới bài đăng trước đó (xem ZZ0000ZZ).

Kiểm tra
-------

Mức độ kiểm tra dự kiến
~~~~~~~~~~~~~~~~~~~~~~~~~

Ở mức tối thiểu, những thay đổi của bạn phải tồn tại ở ZZ0000ZZ và
Bản dựng ZZ0001ZZ với bộ ZZ0002ZZ không có cảnh báo hoặc lỗi mới.

Lý tưởng nhất là bạn đã thực hiện kiểm tra thời gian chạy cụ thể cho thay đổi của mình,
và chuỗi bản vá chứa một bộ kernel selftest dành cho
ZZ0000ZZ hoặc sử dụng khung KUnit.

Bạn phải kiểm tra các thay đổi của mình trên mạng có liên quan
cây (ZZ0000ZZ hoặc ZZ0001ZZ) chứ không phải cây, ví dụ: cây ổn định hoặc ZZ0002ZZ.

kiểm tra chắp vá
~~~~~~~~~~~~~~~~

Kiểm tra trong bản chắp vá hầu hết là các trình bao bọc đơn giản xung quanh hạt nhân hiện có
tập lệnh, các nguồn có sẵn tại:

ZZ0000ZZ

ZZ0000ZZ đăng các bản vá của bạn chỉ để chạy chúng qua quá trình kiểm tra.
Bạn phải đảm bảo rằng các bản vá của bạn đã sẵn sàng bằng cách thử nghiệm chúng cục bộ
trước khi đăng vào danh sách gửi thư. Phiên bản bot xây dựng chắp vá
rất dễ bị quá tải và netdev@vger thực sự không cần thêm
giao thông nếu chúng ta có thể giúp được.

netdevsim
~~~~~~~~~

ZZ0000ZZ là trình điều khiển thử nghiệm có thể được sử dụng để tập luyện trình điều khiển
API cấu hình mà không yêu cầu phần cứng có khả năng.
Khuyến khích mô phỏng và kiểm tra dựa trên ZZ0001ZZ khi
thêm các API mới có logic phức tạp vào ngăn xếp. Các thử nghiệm nên
được viết để chúng có thể chạy cả với ZZ0002ZZ và một
thiết bị (xem ZZ0003ZZ).
Các thử nghiệm chỉ dành cho ZZ0004ZZ nên tập trung vào thử nghiệm các trường hợp góc
và các đường dẫn lỗi trong lõi mà khó có thể thực hiện được với một trình điều khiển thực sự.

Bản thân ZZ0000ZZ được coi là ZZ0001ZZ
một trường hợp sử dụng/người dùng. Bạn cũng phải triển khai các API mới trong trình điều khiển thực.

Chúng tôi không đảm bảo rằng ZZ0000ZZ sẽ không thay đổi trong tương lai
theo cách có thể phá vỡ những gì thường được coi là uAPI.

ZZ0000ZZ chỉ được dành riêng để sử dụng cho các thử nghiệm ngược dòng, vì vậy mọi
các tính năng ZZ0001ZZ mới phải đi kèm với quá trình tự kiểm tra theo
ZZ0002ZZ.

Trạng thái được hỗ trợ cho trình điều khiển
----------------------------

.. note: The following requirements apply only to Ethernet NIC drivers.

Netdev xác định các yêu cầu bổ sung cho trình điều khiển muốn có được
trạng thái ZZ0000ZZ trong tệp MAINTAINERS. Trình điều khiển ZZ0001ZZ phải
đang chạy tất cả các bài kiểm tra trình điều khiển ngược dòng và báo cáo kết quả hai lần một ngày.
Trình điều khiển không tuân thủ yêu cầu này nên sử dụng ZZ0002ZZ
trạng thái. Hiện tại không có sự khác biệt về cách ZZ0003ZZ và ZZ0004ZZ
trình điều khiển được xử lý ngược dòng.

Các quy tắc chính xác mà người lái xe phải tuân theo để có được trạng thái ZZ0000ZZ:

1. Phải chạy tất cả các thử nghiệm theo mục tiêu ZZ0000ZZ và ZZ0001ZZ
   các bài tự kiểm tra của Linux. Việc chạy và báo cáo các thử nghiệm riêng tư/nội bộ là
   cũng được hoan nghênh, nhưng việc kiểm tra ngược dòng là điều bắt buộc.

2. Tần suất chạy tối thiểu là 12 giờ một lần. Phải thử nghiệm
   nhánh được chỉ định từ nguồn cấp dữ liệu nhánh đã chọn. Lưu ý rằng các nhánh
   được xây dựng tự động và có thể bị đăng bản vá độc hại có chủ ý,
   vì vậy hệ thống kiểm tra phải được cách ly.

3. Trình điều khiển hỗ trợ nhiều thế hệ thiết bị phải kiểm tra ở mức
   ít nhất một thiết bị từ mỗi thế hệ. Một bảng kê khai thử nghiệm (chính xác
   định dạng TBD) sẽ mô tả các kiểu thiết bị được thử nghiệm.

4. Các thử nghiệm phải chạy một cách đáng tin cậy, nếu nhiều nhánh bị bỏ qua hoặc các thử nghiệm
   đang thất bại do vấn đề về môi trường thực thi ZZ0000ZZ
   trạng thái sẽ bị thu hồi.

5. Kiểm tra thất bại do lỗi trong trình điều khiển hoặc chính kiểm tra,
   hoặc thiếu sự hỗ trợ cho tính năng mà thử nghiệm đang hướng tới
   ZZ0001ZZ là cơ sở để mất trạng thái ZZ0000ZZ.

netdev CI sẽ duy trì một trang chính thức về các thiết bị được hỗ trợ, liệt kê chúng
kết quả kiểm tra gần đây.

Người bảo trì trình điều khiển có thể sắp xếp để người khác chạy thử nghiệm,
không có yêu cầu nào đối với người được liệt kê là người bảo trì (hoặc
người sử dụng lao động) chịu trách nhiệm thực hiện các bài kiểm tra. Sự hợp tác giữa
các nhà cung cấp, lưu trữ GH CI, các kho lưu trữ khác trên linux-netdev, v.v. đều được chào đón nhiều nhất.

Xem ZZ0000ZZ để biết thêm thông tin về
netdev CI. Vui lòng liên hệ với người bảo trì hoặc danh sách nếu có bất kỳ câu hỏi nào.

Hướng dẫn người đánh giá
-----------------

Việc xem xét các bản vá của người khác trong danh sách rất được khuyến khích,
không phụ thuộc vào trình độ chuyên môn. Để được hướng dẫn chung và
lời khuyên hữu ích xin vui lòng xem ZZ0000ZZ.

Có thể an toàn khi cho rằng những người bảo trì netdev biết cộng đồng và mức độ
chuyên môn của người đánh giá. Người đánh giá không nên quan tâm đến
nhận xét của họ cản trở hoặc làm chệch hướng dòng bản vá. Thẻ được người đánh giá
được hiểu là "Tôi đã xem lại mã này trong khả năng tốt nhất của mình"
thay vì "Tôi có thể chứng thực mã này là chính xác".

Người phản biện được khuyến khích thực hiện đánh giá sâu hơn về các bài nộp
và không tập trung hoàn toàn vào các vấn đề về quy trình, tầm thường hoặc chủ quan
các vấn đề như định dạng mã, thẻ, v.v.

Lời chứng thực / phản hồi
-----------------------

Một số công ty sử dụng phản hồi ngang hàng trong đánh giá hiệu suất của nhân viên.
Vui lòng yêu cầu phản hồi từ những người bảo trì netdev,
đặc biệt nếu bạn dành nhiều thời gian để xem lại mã
và nỗ lực cải thiện cơ sở hạ tầng dùng chung.

Phản hồi phải được yêu cầu bởi bạn, người đóng góp và sẽ luôn
được chia sẻ với bạn (ngay cả khi bạn yêu cầu gửi nó tới
người quản lý).