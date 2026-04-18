.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/bpf_devel_QA.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
HOWTO tương tác với hệ thống con BPF
=================================

Tài liệu này cung cấp thông tin cho hệ thống con BPF về nhiều
quy trình công việc liên quan đến báo cáo lỗi, gửi bản vá và xếp hàng
bản vá cho hạt nhân ổn định.

Để biết thông tin chung về việc gửi bản vá, vui lòng tham khảo
Tài liệu/quy trình/gửi-patches.rst. Tài liệu này chỉ mô tả
thông tin cụ thể bổ sung liên quan đến BPF.

.. contents::
    :local:
    :depth: 2

Báo cáo lỗi
==============

Câu hỏi: Làm cách nào để báo cáo lỗi cho mã hạt nhân BPF?
--------------------------------------------
Trả lời: Vì tất cả sự phát triển kernel BPF cũng như bpftool và iproute2 BPF
quá trình phát triển trình tải diễn ra thông qua danh sách gửi thư hạt nhân bpf,
vui lòng báo cáo mọi vấn đề được tìm thấy xung quanh BPF theo cách gửi thư sau
danh sách:

bpf@vger.kernel.org

Điều này cũng có thể bao gồm các vấn đề liên quan đến truy tìm XDP, BPF, v.v.

Do netdev có lưu lượng truy cập cao, vui lòng thêm BPF
người bảo trì sang Cc (từ tệp kernel ZZ0000ZZ):

* Alexei Starovoytov <ast@kernel.org>
* Daniel Borkmann <daniel@iogearbox.net>

Trong trường hợp một cam kết có lỗi đã được xác định, hãy đảm bảo giữ lại
các tác giả cam kết thực tế trong Cc cũng cho báo cáo. Họ có thể
thường được xác định thông qua cây git của kernel.

**Vui lòng báo cáo NOT các vấn đề về BPF cho bugzilla.kernel.org vì nó
là sự đảm bảo rằng vấn đề được báo cáo sẽ được bỏ qua.**

Gửi bản vá
==================

Câu hỏi: Làm cách nào để chạy BPF CI trên các thay đổi của tôi trước khi gửi chúng đi xem xét?
------------------------------------------------------------------------
Trả lời: BPF CI dựa trên GitHub và được lưu trữ tại ZZ0000ZZ
Mặc dù GitHub cũng cung cấp CLI có thể được sử dụng để thực hiện điều tương tự
kết quả, ở đây chúng tôi tập trung vào quy trình làm việc dựa trên giao diện người dùng.

Các bước sau đây trình bày cách bắt đầu chạy CI cho các bản vá của bạn:

- Tạo một nhánh của kho lưu trữ nói trên trong tài khoản của riêng bạn (một lần
  hành động)

- Sao chép ngã ba cục bộ, kiểm tra chi nhánh mới theo dõi bpf-next
  hoặc nhánh bpf và áp dụng các bản vá cần thử nghiệm của bạn lên trên nó

- Đẩy nhánh địa phương tới nhánh của bạn và tạo yêu cầu kéo đối với
  kernel-patches/nhánh bpf-next_base hoặc bpf_base của bpf tương ứng

Ngay sau khi yêu cầu kéo được tạo, quy trình làm việc CI sẽ chạy. Lưu ý
dung lượng đó được chia sẻ với các bản vá được gửi ngược dòng đang được kiểm tra và do đó
tùy thuộc vào việc sử dụng, quá trình chạy có thể mất một lúc để hoàn thành.

Hơn nữa, lưu ý rằng cả hai nhánh cơ sở (bpf-next_base và bpf_base) sẽ
được cập nhật khi các bản vá được đẩy lên các nhánh ngược dòng tương ứng mà chúng theo dõi. Như
như vậy, bộ bản vá của bạn cũng sẽ tự động (được cố gắng) khởi động lại.
Hiện tượng này có thể dẫn đến việc chạy CI bị hủy bỏ và khởi động lại với cái mới
đường cơ sở.

Hỏi: Tôi cần gửi bản vá BPF của mình tới danh sách gửi thư nào?
------------------------------------------------------------
Trả lời: Vui lòng gửi các bản vá BPF của bạn tới danh sách gửi thư kernel bpf:

bpf@vger.kernel.org

Trong trường hợp bản vá của bạn có những thay đổi trong các hệ thống con khác nhau (ví dụ:
mạng, truy tìm, bảo mật, v.v.), hãy đảm bảo Cc việc gửi thư hạt nhân liên quan
danh sách và người bảo trì từ đó nữa, vì vậy họ có thể xem xét
những thay đổi và cung cấp Acked-by của họ cho các bản vá.

Câu hỏi: Tôi có thể tìm các bản vá hiện đang được thảo luận cho hệ thống con BPF ở đâu?
-------------------------------------------------------------------------
Trả lời: Tất cả các bản vá được Cc cho netdev đều được xếp hàng để xem xét trong netdev
dự án chắp vá:

ZZ0000ZZ

Những bản vá nhắm mục tiêu BPF, được gán cho một đại biểu 'bpf' cho
xử lý thêm từ các nhà bảo trì BPF. Hàng đợi hiện tại với
các bản vá đang được xem xét có thể được tìm thấy tại:

ZZ0000ZZ

Sau khi toàn bộ cộng đồng BPF đã xem xét các bản vá
và được người bảo trì BPF phê duyệt, trạng thái chắp vá của họ sẽ là
đã thay đổi thành 'Được chấp nhận' và người gửi sẽ được thông báo qua thư. Cái này
có nghĩa là các bản vá trông đẹp từ góc độ BPF và đã được
được áp dụng cho một trong hai cây hạt nhân BPF.

Trong trường hợp phản hồi từ cộng đồng yêu cầu phản hồi lại các bản vá,
trạng thái của họ trong bản chắp vá sẽ được đặt thành 'Đã yêu cầu thay đổi' và bị xóa
từ hàng đợi xem xét hiện tại. Tương tự như vậy đối với các trường hợp các bản vá sẽ
bị từ chối hoặc không áp dụng được cho cây BPF (nhưng được gán cho
đại biểu 'bpf').

Hỏi: Những thay đổi này được đưa vào Linux như thế nào?
------------------------------------------------
Trả lời: Có hai cây hạt nhân BPF (kho git). Một khi các bản vá có
được các nhà bảo trì BPF chấp nhận, chúng sẽ được áp dụng cho một
của hai cây BPF:

* ZZ0000ZZ
 * ZZ0001ZZ

Bản thân cây bpf chỉ dành cho các bản sửa lỗi, trong khi bpf-next dành cho các tính năng,
dọn dẹp hoặc các loại cải tiến khác (nội dung "tương tự tiếp theo"). Đây là
tương tự như cây net và cây net-next để kết nối mạng. Cả bpf và
bpf-next sẽ chỉ có một nhánh chính để đơn giản hóa việc chống lại
bản vá chi nhánh nào sẽ được khởi động lại.

Các bản vá BPF tích lũy trong cây bpf sẽ thường xuyên bị kéo
vào cây hạt nhân mạng. Tương tự như vậy, các bản vá BPF tích lũy được chấp nhận
vào cây bpf-next sẽ đi vào cây net-next. mạng lưới và
net-next đều do David S. Miller điều hành. Từ đó họ sẽ đi
vào cây nhân dòng chính do Linus Torvalds điều hành. Để đọc trên
quá trình net và net-next được hợp nhất vào cây dòng chính, xem
tài liệu về hệ thống con netdev tại
Tài liệu/quy trình/bảo trì-netdev.rst.



Đôi khi, để tránh xung đột hợp nhất, chúng tôi có thể gửi yêu cầu kéo
sang các cây khác (ví dụ: truy tìm) bằng một tập hợp con nhỏ các mảnh, nhưng
net và net-next luôn là những cây chính được nhắm đến để tích hợp.

Các yêu cầu kéo sẽ chứa một bản tóm tắt cấp cao về dữ liệu tích lũy
các bản vá lỗi và có thể được tìm kiếm trên danh sách gửi thư của hạt nhân netdev thông qua
các dòng chủ đề sau (ZZ0000ZZ là ngày kéo
yêu cầu)::

yêu cầu kéo: bpf yyyy-mm-dd
  yêu cầu kéo: bpf-next yyyy-mm-dd

Câu hỏi: Làm cách nào để chỉ ra bản vá của tôi nên được áp dụng cho cây nào (bpf so với bpf-next)?
---------------------------------------------------------------------------------

Trả lời: Quá trình này rất giống với quy trình được mô tả trong hệ thống con netdev
tài liệu tại Documentation/process/maintainer-netdev.rst,
vì vậy xin vui lòng đọc về nó. Dòng chủ đề phải cho biết liệu
bản vá là một bản sửa lỗi hay đúng hơn là nội dung "tương tự tiếp theo" để cho phép
người bảo trì biết liệu nó được nhắm mục tiêu vào bpf hay bpf-next.

Để sửa lỗi cuối cùng sẽ vào bpf -> net tree, chủ đề phải
trông giống như::

git format-patch --subject-prefix='PATCH bpf' start..finish

Đối với các tính năng/cải tiến/v.v. mà cuối cùng sẽ được đưa vào
bpf-next -> net-next, chủ đề phải có dạng::

git format-patch --subject-prefix='PATCH bpf-next' start..finish

Nếu không chắc chắn nên đưa bản vá hay chuỗi bản vá vào bpf
hoặc net trực tiếp, hoặc bpf-next hoặc net-next trực tiếp, nó không phải là
vấn đề nếu dòng chủ đề nói net hoặc net-next là mục tiêu.
Cuối cùng, người bảo trì có quyền thực hiện việc ủy quyền
các bản vá.

Nếu rõ ràng rằng các bản vá sẽ được đưa vào cây bpf hoặc bpf-next,
vui lòng đảm bảo rebase các bản vá chống lại những cây đó trong
nhằm giảm bớt những xung đột có thể xảy ra.

Trong trường hợp bản vá hoặc loạt bản vá phải được làm lại và gửi đi
một lần nữa trong lần sửa đổi thứ hai hoặc muộn hơn, cũng cần phải thêm một
số phiên bản (ZZ0000ZZ, ZZ0001ZZ, ...) vào tiền tố chủ đề::

git format-patch --subject-prefix='PATCH bpf-next v2' start..finish

Khi có yêu cầu thay đổi đối với loạt bản vá, hãy luôn gửi
lại toàn bộ loạt bản vá có tích hợp phản hồi (không bao giờ gửi
sự khác biệt riêng lẻ so với loạt phim cũ).

Câu hỏi: Việc áp dụng một bản vá cho cây bpf hoặc bpf-next có ý nghĩa gì?
-----------------------------------------------------------------------
Đáp: Điều đó có nghĩa là bản vá có vẻ phù hợp để đưa vào dòng chính từ
một quan điểm BPF.

Xin lưu ý rằng đây không phải là phán quyết cuối cùng về việc bản vá sẽ
cuối cùng sẽ tự động được chấp nhận vào cây net hoặc net-next:

Trên danh sách gửi thư hạt nhân bpf, các bài đánh giá có thể đến bất kỳ lúc nào
đúng lúc. Nếu các cuộc thảo luận xung quanh một bản vá kết luận rằng họ không thể
được đưa vào nguyên trạng, chúng tôi sẽ áp dụng bản sửa lỗi tiếp theo hoặc loại bỏ
chúng hoàn toàn khỏi cây. Vì vậy, chúng tôi cũng dự trữ để rebase
cây xanh khi thấy cần thiết. Suy cho cùng, mục đích của cái cây
là:

i) tích lũy và tạo các bản vá BPF để tích hợp vào cây
   như net và net-next, và

ii) chạy bộ thử nghiệm BPF mở rộng và
    khối lượng công việc trên các bản vá trước khi chúng tiến xa hơn.

Sau khi yêu cầu kéo BPF được David S. Miller chấp nhận, thì
các bản vá lần lượt xuất hiện trong cây net hoặc cây net-next, và
tiến sâu hơn từ đó vào tuyến chính. Một lần nữa, hãy xem
tài liệu cho hệ thống con netdev tại
Tài liệu/quy trình/bảo trì-netdev.rst để biết thêm thông tin
ví dụ: về tần suất chúng được hợp nhất vào dòng chính.

H: Tôi cần đợi phản hồi về các bản vá BPF của mình trong bao lâu?
-------------------------------------------------------------
Đáp: Chúng tôi cố gắng giữ độ trễ ở mức thấp. Thời gian thông thường để phản hồi sẽ
khoảng 2 hoặc 3 ngày làm việc. Nó có thể thay đổi tùy thuộc vào
sự phức tạp của những thay đổi và tải bản vá hiện tại.

Câu hỏi: Bạn có thường xuyên gửi yêu cầu kéo đến các cây nhân chính như net hoặc net-next không?
----------------------------------------------------------------------------------

Đáp: Các yêu cầu kéo sẽ được gửi đi khá thường xuyên để không
tích lũy quá nhiều bản vá trong bpf hoặc bpf-next.

Theo nguyên tắc chung, hãy chờ đợi các yêu cầu kéo cho mỗi cây một cách thường xuyên
vào cuối tuần. Trong một số trường hợp, yêu cầu kéo có thể bổ sung
cũng đến vào giữa tuần tùy theo bản vá hiện tại
tải hoặc khẩn cấp.

Câu hỏi: Các bản vá có được áp dụng cho bpf-next khi cửa sổ hợp nhất mở không?
-----------------------------------------------------------------
Trả lời: Trong thời gian cửa sổ hợp nhất mở, bpf-next sẽ không được
đã xử lý. Điều này gần giống với quá trình xử lý bản vá tiếp theo,
vì vậy hãy thoải mái đọc tài liệu netdev tại
Documentation/process/maintainer-netdev.rst để biết thêm chi tiết.

Trong thời gian hợp nhất hai tuần đó, chúng tôi có thể yêu cầu bạn gửi lại
loạt bản vá của bạn sau khi bpf-next được mở lại. Khi Linus phát hành
ZZ0000ZZ sau cửa sổ hợp nhất, chúng tôi tiếp tục xử lý bpf-next.

Đối với những người không đăng ký vào danh sách gửi thư kernel, cũng có một trạng thái
trang do David S. Miller điều hành trên net-next cung cấp hướng dẫn:

ZZ0000ZZ

Câu hỏi: Những thay đổi của người xác minh và các trường hợp thử nghiệm
----------------------------------
Câu hỏi: Tôi đã thực hiện thay đổi trình xác minh BPF, tôi có cần thêm trường hợp kiểm thử cho
Tự kiểm tra kernel BPF_?

Trả lời: Nếu bản vá có những thay đổi về hoạt động của trình xác minh thì có,
việc thêm các trường hợp thử nghiệm vào kernel BPF là hoàn toàn cần thiết
bộ selftests_. Nếu họ không có mặt và chúng tôi nghĩ rằng họ có mặt
cần thiết thì chúng tôi có thể yêu cầu chúng trước khi chấp nhận bất kỳ thay đổi nào.

Đặc biệt, test_verifier.c đang theo dõi số lượng lớn thử nghiệm BPF
các trường hợp, bao gồm rất nhiều trường hợp ở góc mà mặt sau LLVM BPF có thể
tạo ra mã C bị hạn chế. Vì vậy, việc thêm các trường hợp thử nghiệm là
cực kỳ quan trọng để đảm bảo những thay đổi trong tương lai không vô tình
ảnh hưởng đến các trường hợp sử dụng trước đó. Vì vậy, hãy coi những trường hợp thử nghiệm đó là:
hành vi không được theo dõi trong test_verifier.c có thể có khả năng
có thể thay đổi.

Câu hỏi: ưu tiên mẫu/bpf so với tự kiểm tra?
---------------------------------------
Câu hỏi: Khi nào tôi nên thêm mã vào ZZ0000ZZ và khi nào vào kernel BPF
tự kiểm tra_?

Trả lời: Nói chung, chúng tôi thích các phần bổ sung cho selftests kernel BPF_ hơn là
ZZ0000ZZ. Lý do rất đơn giản: việc tự kiểm tra kernel là
thường xuyên được chạy bởi nhiều bot khác nhau để kiểm tra hồi quy kernel.

Chúng tôi càng thêm nhiều trường hợp thử nghiệm vào bản tự kiểm tra của BPF thì phạm vi bao phủ càng tốt
và càng ít có khả năng chúng vô tình bị vỡ. Đó là
không phải việc tự kiểm tra kernel BPF không thể trình diễn cách một tính năng cụ thể có thể
được sử dụng.

Điều đó có nghĩa là ZZ0000ZZ có thể là nơi tốt để mọi người bắt đầu,
vì vậy có thể khuyến khích các bản demo đơn giản về các tính năng có thể được đưa vào
ZZ0001ZZ, nhưng thử nghiệm chức năng và trường hợp góc tiên tiến hơn
vào các bản tự kiểm tra kernel.

Nếu mẫu của bạn trông giống như một trường hợp thử nghiệm, thì hãy tự kiểm tra kernel BPF
thay vào đó!

Câu hỏi: Khi nào tôi nên thêm mã vào bpftool?
-----------------------------------------
Đáp: Mục đích chính của bpftool (trong phần tools/bpf/bpftool/) là cung cấp
một công cụ không gian người dùng trung tâm để gỡ lỗi và xem xét nội bộ các chương trình BPF
và các bản đồ đang hoạt động trong kernel. Nếu UAPI thay đổi liên quan đến BPF
cho phép loại bỏ thông tin bổ sung của chương trình hoặc bản đồ, sau đó
bpftool cũng nên được mở rộng để hỗ trợ việc bán phá giá chúng.

Câu hỏi: Khi nào tôi nên thêm mã vào trình tải BPF của iproute2?
---------------------------------------------------
Trả lời: Đối với các thay đổi của UAPI liên quan đến lớp XDP hoặc tc (ví dụ: ZZ0000ZZ),
quy ước là những thay đổi liên quan đến đường dẫn điều khiển đó sẽ được thêm vào
Trình tải BPF của iproute2 cũng như từ phía không gian người dùng. Đây không chỉ là
hữu ích khi các thay đổi của UAPI được thiết kế phù hợp để có thể sử dụng được, nhưng cũng
để cung cấp những thay đổi đó cho cơ sở người dùng rộng hơn của các
phân phối hạ lưu.

Câu hỏi: Bạn có chấp nhận các bản vá cho trình tải BPF của iproute2 không?
-----------------------------------------------------------
Trả lời: Các bản vá cho trình tải BPF của iproute2 phải được gửi tới:

netdev@vger.kernel.org

Mặc dù các bản vá đó không được các nhà bảo trì kernel BPF xử lý,
vui lòng giữ chúng trong Cc để có thể xem xét.

Kho git chính thức cho iproute2 được điều hành bởi Stephen Hemminger
và có thể được tìm thấy tại:

ZZ0000ZZ

Các bản vá cần phải có tiền tố chủ đề là 'ZZ0000ZZ' hoặc 'ZZ0001ZZ'. 'ZZ0002ZZ' hoặc
'ZZ0003ZZ' mô tả nhánh mục tiêu nơi có bản vá
áp dụng cho. Có nghĩa là, nếu các thay đổi của kernel được đưa vào kernel net-next
cây, thì những thay đổi liên quan đến iproute2 cần được đưa vào iproute2
net-next, nếu không chúng có thể được nhắm mục tiêu vào nhánh chính. các
nhánh iproute2 net-next sẽ được sáp nhập vào nhánh chính sau
phiên bản iproute2 hiện tại từ master đã được phát hành.

Giống như BPF, các bản vá cuối cùng được chắp vá theo dự án netdev và
được ủy quyền cho 'shemminger' để xử lý thêm:

ZZ0000ZZ

Hỏi: Yêu cầu tối thiểu trước khi tôi gửi bản vá BPF của mình là gì?
------------------------------------------------------------------
Đáp: Khi gửi bản vá, hãy luôn dành thời gian và kiểm tra đúng cách
bản vá ZZ0000ZZ để gửi. Đừng bao giờ vội vàng với họ! Nếu người bảo trì tìm thấy
rằng các bản vá của bạn chưa được kiểm tra đúng cách, đó là một cách tốt để
làm cho họ gắt gỏng. Kiểm tra việc gửi bản vá là một yêu cầu khó khăn!

Lưu ý, các bản sửa lỗi đi tới cây bpf ZZ0002ZZ có kèm theo thẻ ZZ0000ZZ.
Điều tương tự cũng áp dụng cho các bản sửa lỗi nhắm mục tiêu bpf-next, nơi bị ảnh hưởng
cam kết nằm trong net-next (hoặc trong một số trường hợp là bpf-next). Thẻ ZZ0001ZZ là
rất quan trọng để xác định các cam kết tiếp theo và giúp ích rất nhiều
dành cho những người phải thực hiện backport, vì vậy nó là thứ phải có!

Chúng tôi cũng không chấp nhận các bản vá có thông báo cam kết trống. Lấy của bạn
thời gian và viết đúng một thông điệp cam kết chất lượng cao, đó là
thiết yếu!

Hãy nghĩ về nó theo cách này: các nhà phát triển khác xem mã của bạn mỗi tháng
từ bây giờ cần phải hiểu ZZ0000ZZ một sự thay đổi nhất định đã được thực hiện
và liệu có sai sót nào trong phân tích hoặc giả định hay không
mà tác giả ban đầu đã làm. Từ đó đưa ra lý do chính đáng và
mô tả trường hợp sử dụng cho những thay đổi là điều bắt buộc.

Việc gửi bản vá có >1 bản vá phải có thư xin việc bao gồm
một mô tả cấp cao của bộ truyện. Bản tóm tắt cấp cao này sẽ
sau đó được đưa vào cam kết hợp nhất bởi những người bảo trì BPF sao cho
nó cũng có thể truy cập được từ nhật ký git để tham khảo trong tương lai.

Hỏi: Tính năng thay đổi BPF JIT và/hoặc LLVM
----------------------------------------
Hỏi: Tôi cần cân nhắc điều gì khi thêm hướng dẫn hoặc tính năng mới
điều đó cũng yêu cầu tích hợp BPF JIT và/hoặc LLVM?

Trả lời: Chúng tôi cố gắng hết sức để cập nhật tất cả các JIT của BPF sao cho cùng một người dùng
trải nghiệm có thể được đảm bảo khi chạy các chương trình BPF trên các nền tảng khác nhau
kiến trúc mà không cần phải thực hiện chương trình kém hiệu quả hơn
trình thông dịch trong trường hợp BPF JIT trong kernel được bật.

Nếu bạn không thể triển khai hoặc kiểm tra các thay đổi JIT cần thiết cho
một số kiến trúc nhất định, vui lòng làm việc cùng với BPF JIT có liên quan
các nhà phát triển để triển khai tính năng này một cách kịp thời.
Vui lòng tham khảo nhật ký git (ZZ0000ZZ) để xác định vị trí cần thiết
mọi người giúp đỡ với.

Ngoài ra, hãy luôn đảm bảo thêm các trường hợp thử nghiệm BPF (ví dụ: test_bpf.c và
test_verifier.c) để biết các hướng dẫn mới để họ có thể nhận được
phạm vi thử nghiệm rộng rãi và giúp thử nghiệm trong thời gian chạy các JIT BPF khác nhau.

Trong trường hợp hướng dẫn BPF mới, khi các thay đổi đã được chấp nhận
vào nhân Linux, vui lòng triển khai hỗ trợ vào BPF của LLVM
kết thúc. Xem phần LLVM_ bên dưới để biết thêm thông tin.

Câu hỏi: Không gian tên biểu tượng "BPF_INTERNAL" dùng để làm gì?
-----------------------------------------------
Trả lời: Các biểu tượng được xuất dưới dạng BPF_INTERNAL chỉ có thể được sử dụng bởi cơ sở hạ tầng BPF
giống như các mô-đun hạt nhân tải trước với khung nhẹ. Hầu hết các biểu tượng bên ngoài
của BPF_INTERNAL dự kiến cũng sẽ không được sử dụng bởi mã bên ngoài BPF.
Các ký hiệu có thể thiếu chỉ định vì chúng có trước các không gian tên,
hoặc do sơ suất.

Trình ổn định
=================

Câu hỏi: Tôi cần cam kết BPF cụ thể trong hạt nhân ổn định. Tôi nên làm gì?
--------------------------------------------------------------------
Trả lời: Trong trường hợp bạn cần một bản sửa lỗi cụ thể trong hạt nhân ổn định, trước tiên hãy kiểm tra xem
cam kết đã được áp dụng trong các nhánh ZZ0000ZZ có liên quan:

ZZ0000ZZ

Nếu không đúng như vậy, hãy gửi email tới người bảo trì BPF kèm theo
danh sách gửi thư kernel netdev trong Cc và yêu cầu xếp hàng sửa lỗi:

netdev@vger.kernel.org

Quá trình nói chung cũng giống như trên netdev, xem thêm
tài liệu về hệ thống con mạng tại
Tài liệu/quy trình/bảo trì-netdev.rst.

Câu hỏi: Bạn có backport cho các kernel hiện không được duy trì ổn định không?
----------------------------------------------------------------------
Đáp: Không. Nếu bạn cần một cam kết BPF cụ thể trong các hạt nhân hiện không có
được duy trì bởi những người duy trì ổn định, sau đó bạn phải tự mình thực hiện.

Các kernel ổn định lâu dài và ổn định hiện tại đều được liệt kê ở đây:

ZZ0000ZZ

Hỏi: Bản vá BPF mà tôi sắp gửi cũng cần phải chuyển sang trạng thái ổn định
-------------------------------------------------------------------
Tôi nên làm gì?

Đáp: Các quy tắc tương tự được áp dụng như với việc gửi bản vá netdev nói chung, hãy xem
tài liệu netdev tại Documentation/process/maintainer-netdev.rst.

Không bao giờ thêm "ZZ0000ZZ" vào mô tả bản vá, nhưng
thay vào đó hãy yêu cầu người bảo trì BPF xếp hàng các bản vá. Điều này có thể được thực hiện
với một ghi chú, chẳng hạn như bên dưới phần ZZ0001ZZ của bản vá.
không đi vào nhật ký git. Ngoài ra, điều này có thể được thực hiện đơn giản
thay vào đó hãy yêu cầu qua thư.

Q: Xếp hàng các bản vá ổn định
-----------------------
Hỏi: Tôi có thể tìm các bản vá BPF hiện đang xếp hàng đợi sẽ được gửi ở đâu
ổn định?

Trả lời: Sau khi các bản vá sửa các lỗi nghiêm trọng được áp dụng vào cây bpf, chúng sẽ
được xếp hàng để gửi ổn định theo:

ZZ0000ZZ

Họ sẽ bị giữ ở đó ít nhất cho đến khi cam kết liên quan được thực hiện.
đường vào cây hạt nhân chính.

Sau khi được hiển thị rộng rãi hơn, các bản vá được xếp hàng đợi sẽ được
do người bảo trì BPF gửi tới người bảo trì ổn định.

Các bản vá thử nghiệm
===============

Hỏi: Cách chạy bản tự kiểm tra BPF
---------------------------
A: Sau khi bạn đã khởi động vào kernel mới được biên dịch, hãy điều hướng đến
bộ BPF selftests_ để kiểm tra chức năng BPF (hiện tại
thư mục làm việc trỏ đến thư mục gốc của cây git nhân bản)::

$ cd công cụ/kiểm tra/selftests/bpf/
  $ kiếm được

Để chạy kiểm tra trình xác minh::

$ sudo ./test_verifier

Các cuộc kiểm tra người xác minh in ra tất cả các cuộc kiểm tra hiện tại đang được thực hiện.
được thực hiện. Bản tóm tắt khi kết thúc quá trình chạy tất cả các bài kiểm tra sẽ kết xuất
thông tin về sự thành công và thất bại của thử nghiệm::

Tóm tắt: 418 PASSED, 0 FAILED

Để chạy qua tất cả các lần tự kiểm tra BPF, lệnh sau là
cần thiết::

$ sudo tạo run_tests

Xem ZZ0000ZZ
để biết chi tiết.

Để tối đa hóa số lượng bài kiểm tra vượt qua, .config của kernel
đang được thử nghiệm phải khớp với đoạn tệp cấu hình trong
tools/testing/selftests/bpf càng chặt chẽ càng tốt.

Cuối cùng để đảm bảo hỗ trợ các tính năng Định dạng Loại BPF mới nhất -
được thảo luận trong Documentation/bpf/btf.rst - pahole phiên bản 1.16
là bắt buộc đối với các hạt nhân được xây dựng bằng CONFIG_DEBUG_INFO_BTF=y.
hố được giao theo gói của người lùn hoặc có thể được xây dựng
từ nguồn tại

ZZ0000ZZ

pahole bắt đầu sử dụng các định nghĩa và API libbpf kể từ phiên bản 1.13 sau phiên bản
cam kết 21507cd3e97b ("pahole: thêm libbpf làm mô hình con trong lib/bpf").
Nó hoạt động tốt với kho git vì mô-đun con libbpf sẽ
sử dụng "git submodule update --init --recursive" để cập nhật.

Thật không may, mã nguồn phát hành github mặc định không chứa
mã nguồn mô-đun con libbpf và điều này sẽ gây ra sự cố khi xây dựng, tarball
từ ZZ0000ZZ cũng giống với
github, bạn có thể lấy tarball nguồn với mô-đun con libbpf tương ứng
mã từ

ZZ0000ZZ

Một số bản phân phối đã đóng gói phiên bản pahole 1.16, ví dụ:
Fedora, Gentoo.

Câu hỏi: Tôi nên chạy kernel của mình trên phiên bản tự kiểm tra kernel BPF nào?
---------------------------------------------------------------------
Trả lời: Nếu bạn chạy kernel ZZ0000ZZ thì hãy luôn chạy bản tự kiểm tra kernel BPF
từ kernel ZZ0001ZZ đó. Đừng mong đợi rằng BPF selftest
từ cây chính mới nhất sẽ luôn trôi qua.

Đặc biệt, test_bpf.c và test_verifier.c có số lượng lớn
các trường hợp thử nghiệm và được cập nhật liên tục với các chuỗi thử nghiệm BPF mới hoặc
những cái hiện có được điều chỉnh cho phù hợp với những thay đổi của người xác minh, ví dụ: do người xác minh
trở nên thông minh hơn và có thể theo dõi những thứ nhất định tốt hơn.

LLVM
====

Câu hỏi: Tôi có thể tìm LLVM có hỗ trợ BPF ở đâu?
-----------------------------------------
Trả lời: Phần phụ trợ BPF dành cho LLVM là phiên bản ngược dòng trong LLVM kể từ phiên bản 3.7.1.

Tất cả các bản phân phối chính hiện nay đều xuất xưởng LLVM với phần phụ trợ BPF được kích hoạt,
vì vậy, đối với phần lớn các trường hợp sử dụng, không cần phải biên dịch LLVM bằng cách
tay nữa, chỉ cần cài đặt gói phân phối được cung cấp.

Trình biên dịch tĩnh của LLVM liệt kê các mục tiêu được hỗ trợ thông qua
ZZ0000ZZ, đảm bảo các mục tiêu BPF được liệt kê. Ví dụ::

$ llc --version
     LLVM (ZZ0000ZZ
       LLVM phiên bản 10.0.0
       Cấu hình tối ưu.
       Mục tiêu mặc định: x86_64-unknown-linux-gnu
       Máy chủ CPU: skylake

Mục tiêu đã đăng ký:
         aarch64 - AArch64 (endian nhỏ)
         bpf - BPF (máy chủ endian)
         bpfeb - BPF (endian lớn)
         bpfel - BPF (endian nhỏ)
         x86 - X86 32-bit: Pentium-Pro trở lên
         x86-64 - X86 64-bit: EM64T và AMD64

Dành cho các nhà phát triển để sử dụng các tính năng mới nhất được thêm vào LLVM
Phần cuối của BPF, bạn nên chạy các bản phát hành LLVM mới nhất. Hỗ trợ
để biết các tính năng mới của nhân BPF chẳng hạn như các bổ sung cho lệnh BPF
bộ thường được phát triển cùng nhau.

Tất cả các bản phát hành LLVM có thể được tìm thấy tại: ZZ0000ZZ

Hỏi: Hiểu rồi, vậy làm cách nào để xây dựng LLVM theo cách thủ công?
--------------------------------------------------
Đáp: Chúng tôi khuyên các nhà phát triển muốn có bản dựng tăng dần nhanh nhất
sử dụng hệ thống xây dựng Ninja, bạn có thể tìm thấy nó trong gói hệ thống của bạn
người quản lý, gói thường là ninja hoặc ninja-build.

Bạn cần ninja, cmake và gcc-c++ làm điều kiện cần thiết để xây dựng LLVM. Một khi bạn
đã thiết lập xong, hãy tiến hành xây dựng phiên bản LLVM và clang mới nhất
từ kho git ::

$ git bản sao ZZ0000ZZ
     $ mkdir -p llvm-project/llvm/build
     $ cd llvm-project/llvm/build
     $ cmake .. -G "Ninja" -DLLVM_TARGETS_TO_BUILD="BPF;X86" \
                -DLLVM_ENABLE_PROJECTS="clang" \
                -DCMAKE_BUILD_TYPE=Phát hành \
                -DLLVM_BUILD_RUNTIME=OFF
     $ ninja

Sau đó, các tệp nhị phân được xây dựng có thể được tìm thấy trong thư mục build/bin/, trong đó
bạn có thể trỏ biến PATH tới.

Đặt ZZ0000ZZ bằng mục tiêu bạn muốn xây dựng, bạn
sẽ tìm thấy danh sách đầy đủ các mục tiêu trong llvm-project/llvm/lib/Target
thư mục.

Câu hỏi: Báo cáo sự cố LLVM BPF
----------------------------
Câu hỏi: Tôi có nên thông báo cho người bảo trì kernel BPF về các vấn đề trong mã BPF của LLVM không
thế hệ back-end hoặc về mã LLVM được tạo mà người xác minh
từ chối chấp nhận?

A: Vâng, xin vui lòng làm!

Mặt sau BPF của LLVM là phần quan trọng của toàn bộ BPF
cơ sở hạ tầng và nó liên quan sâu sắc đến việc xác minh các chương trình từ
phía hạt nhân. Vì vậy, mọi vấn đề của hai bên đều cần được điều tra
và sửa chữa bất cứ khi nào cần thiết.

Vì vậy, vui lòng đảm bảo đưa chúng lên khi gửi thư kernel netdev
list và các trình bảo trì Cc BPF cho LLVM và các bit kernel:

* Bài hát Yonghong <yhs@fb.com>
* Alexei Starovoytov <ast@kernel.org>
* Daniel Borkmann <daniel@iogearbox.net>

LLVM cũng có trình theo dõi vấn đề, nơi có thể tìm thấy các lỗi liên quan đến BPF:

ZZ0000ZZ

Tuy nhiên, tốt hơn là bạn nên tiếp cận thông qua danh sách gửi thư bằng cách có
người bảo trì trong Cc.

Hỏi: Hướng dẫn BPF mới cho kernel và LLVM
------------------------------------------
Hỏi: Tôi đã thêm lệnh BPF mới vào kernel, làm cách nào để tích hợp
nó vào LLVM?

Trả lời: LLVM có bộ chọn ZZ0000ZZ cho phần sau BPF để cho phép
việc lựa chọn các phần mở rộng tập lệnh BPF. Trước phiên bản llvm 20,
mục tiêu bộ xử lý ZZ0001ZZ được sử dụng, đây là lệnh cơ bản
bộ (v1) của BPF. Kể từ llvm 20, mục tiêu bộ xử lý mặc định đã thay đổi
vào tập lệnh v3.

LLVM có tùy chọn để chọn ZZ0000ZZ nơi nó sẽ thăm dò máy chủ
kernel cho các phần mở rộng tập lệnh BPF được hỗ trợ và chọn
thiết lập tối ưu một cách tự động.

Để biên dịch chéo, một phiên bản cụ thể cũng có thể được chọn thủ công ::

$ llc -march bpf -mcpu=help
     CPU có sẵn cho mục tiêu này:

chung - Chọn bộ xử lý chung.
       đầu dò - Chọn bộ xử lý đầu dò.
       v1 - Chọn bộ xử lý v1.
       v2 - Chọn bộ xử lý v2.
     […]

Các hướng dẫn BPF mới được thêm vào nhân Linux cần phải tuân theo tương tự
lược đồ, nâng cấp phiên bản tập lệnh và thực hiện việc thăm dò cho
các tiện ích mở rộng mà người dùng ZZ0000ZZ có thể hưởng lợi từ
tối ưu hóa một cách minh bạch khi nâng cấp hạt nhân của họ.

Nếu bạn không thể triển khai hỗ trợ cho lệnh BPF mới được thêm vào
vui lòng liên hệ với nhà phát triển BPF để được trợ giúp.

Nhân tiện, các bản tự kiểm tra kernel BPF chạy với ZZ0000ZZ sẽ tốt hơn
phạm vi kiểm tra.

Q: cờ clang cho bpf mục tiêu?
-----------------------------
Hỏi: Trong một số trường hợp, cờ clang ZZ0000ZZ được sử dụng nhưng trong các trường hợp khác,
mục tiêu clang mặc định phù hợp với kiến trúc cơ bản sẽ được sử dụng.
Sự khác biệt là gì và khi nào tôi nên sử dụng cái nào?

Trả lời: Mặc dù việc tạo và tối ưu hóa IR LLVM cố gắng duy trì kiến trúc
độc lập, ZZ0000ZZ vẫn có một số tác động đến mã được tạo:

- Chương trình BPF có thể bao gồm đệ quy (các) tệp tiêu đề với phạm vi tệp
  mã lắp ráp nội tuyến. Mục tiêu mặc định có thể xử lý tốt việc này,
  trong khi mục tiêu ZZ0000ZZ có thể thất bại nếu trình biên dịch chương trình phụ trợ bpf không
  hiểu các mã lắp ráp này, điều này đúng trong hầu hết các trường hợp.

- Khi được biên dịch không có ZZ0000ZZ, các phần yêu tinh bổ sung, ví dụ:
  .eh_frame và .rela.eh_frame, có thể có trong tệp đối tượng
  với mục tiêu mặc định, nhưng không phải với mục tiêu ZZ0001ZZ.

- Target mặc định có thể biến câu lệnh switch C thành bảng switch
  thao tác tra cứu và nhảy. Vì bàn chuyển mạch được đặt
  trong phần chỉ đọc toàn cục, chương trình bpf sẽ không tải được.
  Mục tiêu bpf không hỗ trợ tối ưu hóa bảng chuyển đổi.
  Tùy chọn clang ZZ0000ZZ có thể được sử dụng để tắt
  tạo bảng chuyển mạch.

- Đối với clang ZZ0000ZZ, đảm bảo rằng con trỏ hoặc dài /
  các loại dài không dấu sẽ luôn có chiều rộng 64 bit, bất kể
  cho dù mục tiêu (hoặc hạt nhân) mặc định hoặc nhị phân clang cơ bản là
  32 bit. Tuy nhiên, khi mục tiêu clang gốc được sử dụng thì nó sẽ
  biên dịch các loại này dựa trên các quy ước của kiến trúc cơ bản,
  nghĩa là trong trường hợp kiến trúc 32 bit, con trỏ hoặc dài/không dấu
  các loại dài, ví dụ: trong cấu trúc ngữ cảnh BPF sẽ có chiều rộng 32 bit
  trong khi phần sau BPF LLVM vẫn hoạt động ở chế độ 64 bit. Người bản xứ
  mục tiêu chủ yếu cần thiết trong việc truy tìm trường hợp đi bộ ZZ0001ZZ
  hoặc các cấu trúc hạt nhân khác trong đó độ rộng thanh ghi của CPU có vấn đề.
  Nếu không, ZZ0002ZZ thường được khuyên dùng.

Bạn nên sử dụng mục tiêu mặc định khi:

- Chương trình của bạn bao gồm một tệp tiêu đề, ví dụ: ptrace.h, cuối cùng
  kéo vào một số tệp tiêu đề chứa mã lắp ráp máy chủ phạm vi tệp.

- Bạn có thể thêm ZZ0000ZZ để khắc phục sự cố bảng chuyển đổi.

Nếu không, bạn có thể sử dụng mục tiêu ZZ0000ZZ. Ngoài ra, ZZ0001ZZ của bạn sử dụng mục tiêu bpf
khi:

- Chương trình của bạn sử dụng cấu trúc dữ liệu có con trỏ hoặc long/unsigned long
  các loại có giao diện với trình trợ giúp BPF hoặc cấu trúc dữ liệu ngữ cảnh. Truy cập
  vào các cấu trúc này được xác minh bởi trình xác minh BPF và có thể dẫn đến
  trong trường hợp xác minh không thành công nếu kiến trúc gốc không phù hợp với
  kiến trúc BPF, ví dụ: 64-bit. Một ví dụ về điều này là
  BPF_PROG_TYPE_SK_MSG yêu cầu ZZ0000ZZ


.. Links
.. _selftests:
   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/tools/testing/selftests/bpf/

Chúc bạn hack BPF vui vẻ!
