.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/media-committers.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _Media Committers:

Người ủy thác truyền thông
================

Người truyền thông là ai?
-------------------------

Người quản lý phương tiện truyền thông là Người bảo trì phương tiện truyền thông có quyền truy cập chắp vá, người đã
được cấp quyền truy cập cam kết để đẩy các bản vá từ các nhà phát triển khác và của chính họ
các bản vá lỗi cho
ZZ0000ZZ
cây.

Các quyền cam kết này được cấp với kỳ vọng về trách nhiệm:
những người cam kết là những người quan tâm đến toàn bộ hạt nhân Linux và
về hệ thống con phương tiện Linux và muốn thúc đẩy sự phát triển của nó. Nó
cũng dựa trên mối quan hệ tin cậy giữa những người cam kết, người bảo trì khác
và cộng đồng Linux Media.

Với tư cách là Người cam kết truyền thông, bạn có thêm các trách nhiệm sau:

1. Các bản vá bạn tạo phải có ZZ0001ZZ, ZZ0002ZZ
   hoặc ZZ0003ZZ từ Người bảo trì phương tiện khác;
2. Nếu một bản vá gây ra hiện tượng hồi quy thì điều đó phải được khắc phục càng sớm càng tốt.
   càng tốt. Thông thường, bản vá được hoàn nguyên hoặc bổ sung
   bản vá cam kết khắc phục hồi quy;
3. Nếu các bản vá đang sửa lỗi đối với Hạt nhân đã được phát hành, bao gồm
   hoàn nguyên được đề cập ở trên, Người ủy thác truyền thông sẽ bổ sung những thông tin cần thiết
   thẻ. Vui lòng xem ZZ0000ZZ để biết thêm chi tiết.
4. Tất cả những người cam kết truyền thông đều có trách nhiệm duy trì
   ZZ0004ZZ,
   cập nhật trạng thái của các bản vá mà họ xem xét hoặc hợp nhất.


Trở thành người truyền thông
--------------------------

Người cam kết truyền thông hiện tại có thể đề cử Người bảo trì phương tiện để được cấp
cam kết quyền. Người bảo trì phương tiện phải có quyền truy cập chắp vá,
đã xem xét các bản vá từ bên thứ ba một thời gian và đã
thể hiện sự hiểu biết tốt về nhiệm vụ và quy trình của người bảo trì.

Trách nhiệm cuối cùng trong việc chấp nhận người cam kết được chỉ định là tùy thuộc vào
Người bảo trì hệ thống con phương tiện. Người cam kết được đề cử phải đạt được
mối quan hệ tin cậy với tất cả Người bảo trì hệ thống con phương tiện, bằng cách cấp cho bạn
cam kết quyền lợi, một phần trách nhiệm của họ được giao lại cho bạn.

Vì vậy, để trở thành Media Committer, cần có sự đồng thuận giữa tất cả các Media
Người bảo trì hệ thống con là bắt buộc.

.. Note::

   In order to preserve/protect the developers that could have their commit
   rights granted, denied or removed as well as the subsystem maintainers who
   have the task to accept or deny commit rights, all communication related to
   changing commit rights should happen in private as much as possible.

.. _media-committer-agreement:

Thỏa thuận của Media Committer
---------------------------

Sau khi người ủy quyền được chỉ định được tất cả Người bảo trì hệ thống con phương tiện chấp nhận,
họ sẽ hỏi liệu nhà phát triển có quan tâm đến việc đề cử hay không và thảo luận
(những) lĩnh vực nào của hệ thống con truyền thông mà người cam kết sẽ chịu trách nhiệm.
Những khu vực đó thường sẽ giống với những khu vực được đề cử
commiter đã được duy trì.

Khi nhà phát triển chấp nhận trở thành người cam kết, người cam kết mới sẽ
chấp nhận rõ ràng các chính sách phát triển hạt nhân được mô tả trong phần
Tài liệu/, và đặc biệt là các quy định trong tài liệu này, bằng văn bản
một e-mail đến media-committers@linuxtv.org, kèm theo tuyên bố về ý định
theo mô hình dưới đây::

Tôi, John Doe, muốn thay đổi trạng thái của mình thành: Người đi làm

Với tư cách là Người bảo trì phương tiện, tôi chấp nhận các quyền cam kết đối với các lĩnh vực sau
   Hệ thống con truyền thông:

   ...

Với mục đích cam kết các bản vá cho cây cam kết phương tiện,
   Tôi sẽ sử dụng người dùng ZZ0000ZZ của mình

Tiếp theo là tuyên bố chính thức về thỏa thuận với việc phát triển hạt nhân
quy tắc::

Tôi đồng ý tuân theo các quy tắc phát triển hạt nhân được mô tả tại:

ZZ0000ZZ

và các quy tắc của quá trình phát triển hạt nhân Linux.

Tôi đồng ý tuân theo Quy tắc ứng xử như được ghi trong:
   ZZ0000ZZ

Tôi biết rằng tôi có thể nghỉ hưu bất cứ lúc nào. Trong trường hợp đó, tôi sẽ
   gửi e-mail để thông báo cho Người bảo trì hệ thống con phương tiện để họ thu hồi
   quyền cam kết của tôi.

Tôi biết rằng các quy tắc phát triển hạt nhân thay đổi theo thời gian.
   Bằng cách thực hiện một cú đẩy mới tới cây cam kết truyền thông, tôi hiểu rằng tôi đồng ý
   tuân thủ các quy định có hiệu lực tại thời điểm cam kết.

Email đó sẽ được ký thông qua Kernel Web tin cậy bằng phím chéo PGP
được ký bởi các nhà phát triển hạt nhân và phương tiện truyền thông khác. Như được mô tả tại
ZZ0000ZZ, chữ ký PGP, cùng với người dùng gitlab
bảo mật là các thành phần cơ bản đảm bảo tính xác thực của việc hợp nhất
các yêu cầu sẽ xảy ra tại cây media-committers.git.

Trong trường hợp quá trình phát triển kernel thay đổi, bằng cách hợp nhất các cam kết mới với
ZZ0000ZZ,
Người ủy quyền truyền thông ngầm tuyên bố sự đồng ý của họ với thông tin mới nhất
phiên bản của quy trình được ghi lại bao gồm nội dung của tệp này.

Nếu Người ủy quyền truyền thông quyết định nghỉ hưu, nghĩa vụ của người đó là phải
thông báo cho Người bảo trì hệ thống con phương tiện về quyết định đó.

.. note::

   1. Changes to the kernel media development process shall be announced in
      the media-committers mailing list with a reasonable review period. All
      committers are automatically subscribed to that mailing list;
   2. Due to the distributed nature of the Kernel development, it is
      possible that kernel development process changes may end being
      reviewed/merged at the Linux Docs and/or at the Linux Kernel mailing
      lists, especially for the contents under Documentation/process and for
      trivial typo fixes.

Người cam kết của Media Core
---------------------

Media Core Committer là Người bảo trì Media Core với các quyền cam kết.

Như được mô tả trong Tài liệu/driver-api/media/maintainer-entry-profile.rst,
Người bảo trì Media Core cũng duy trì các khung lõi đa phương tiện, bên cạnh đó
chỉ các trình điều khiển và do đó được phép thay đổi các tệp cốt lõi và hệ thống con phương tiện
Hạt nhân API. Mức độ tài trợ của người cam kết cốt lõi sẽ được trình bày chi tiết bởi
Người bảo trì hệ thống con phương tiện khi họ đề cử Người cam kết Media Core.

Người cam kết truyền thông hiện tại có thể trở thành Người cam kết Media Core và ngược lại.
Những quyết định như vậy sẽ được đưa ra với sự đồng thuận giữa Hệ thống con truyền thông
Người bảo trì.

Quy tắc của người ủy quyền truyền thông
----------------------

Những người cam kết truyền thông sẽ cố gắng hết sức để tránh việc hợp nhất các bản vá lỗi
sẽ phá vỡ mọi trình điều khiển hiện có. Nếu nó bị hỏng, hãy sửa chữa hoặc hoàn nguyên các bản vá
sẽ được sáp nhập càng sớm càng tốt, nhằm mục đích được sáp nhập vào cùng một Kernel
chu kỳ lỗi được báo cáo.

Người cam kết truyền thông phải hành xử phù hợp với các quyền được cấp bởi
Người bảo trì hệ thống con phương tiện, đặc biệt liên quan đến phạm vi thay đổi
họ có thể nộp đơn trực tiếp tại cây cam kết phương tiện. Phạm vi đó có thể
thay đổi theo thời gian theo thỏa thuận chung giữa các Ủy viên Truyền thông và
Người bảo trì hệ thống con truyền thông.

Quy trình làm việc của Media Committer được mô tả tại ZZ0000ZZ.

.. _Maintain Media Status:

Duy trì trạng thái Người duy trì phương tiện hoặc Người cam kết
------------------------------------------------

Một cộng đồng các nhà bảo trì làm việc cùng nhau để di chuyển Linux Kernel
về phía trước là điều cần thiết để tạo ra các dự án thành công mang lại lợi ích
để làm việc tiếp. Nếu có vấn đề hoặc bất đồng trong cộng đồng,
chúng thường có thể được giải quyết thông qua thảo luận và tranh luận lành mạnh.

Trong trường hợp không may là Người bảo trì phương tiện hoặc Người bảo trì tiếp tục
coi thường quyền công dân tốt (hoặc chủ động phá vỡ dự án), chúng ta có thể cần
thu hồi tư cách của người đó. Trong những trường hợp như vậy, nếu ai đó gợi ý
thu hồi với một lý do chính đáng, sau đó sau khi thảo luận vấn đề này giữa các phương tiện truyền thông
Người bảo trì, quyết định cuối cùng được đưa ra bởi Người bảo trì hệ thống con phương tiện.

Vì quyết định trở thành Người bảo trì hoặc Người đảm bảo phương tiện truyền thông xuất phát từ
sự đồng thuận giữa những người bảo trì hệ thống con phương tiện, một Hệ thống con phương tiện duy nhất
Người bảo trì không còn tin tưởng Người bảo trì phương tiện hoặc Người bảo trì nữa là đủ
thu hồi quyền bảo trì, tài trợ chắp vá và/hoặc quyền cam kết.

Việc thu hồi quyền cam kết không ngăn cản Người bảo trì phương tiện giữ
đóng góp cho hệ thống con thông qua yêu cầu kéo hoặc qua quy trình làm việc qua email
như được ghi lại tại ZZ0000ZZ.

Nếu người bảo trì không hoạt động trong hơn một vài chu kỳ hạt nhân,
những người bảo trì sẽ cố gắng liên lạc với bạn qua e-mail. Nếu không thể, họ có thể
thu hồi quyền bảo trì/chắp vá và người cam kết của họ và cập nhật MAINTAINERS
mục tập tin cho phù hợp. Nếu bạn muốn tiếp tục đóng góp với tư cách là người duy trì
sau này, hãy liên hệ với Người bảo trì hệ thống con phương tiện để hỏi xem liệu bạn có
bảo trì, tài trợ chắp vá và quyền cam kết có thể được khôi phục.

Tài liệu tham khảo
----------

Phần lớn điều này được lấy cảm hứng từ/sao chép từ các chính sách của người cam kết:

- ZZ0000ZZ;
- ZZ0001ZZ;
-ZZ0002ZZ.