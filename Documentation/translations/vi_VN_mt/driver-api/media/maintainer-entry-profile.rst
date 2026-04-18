.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/maintainer-entry-profile.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Hồ sơ hệ thống con truyền thông
=======================

Tổng quan
--------

Cộng đồng Truyền thông Linux (còn gọi là: Cộng đồng LinuxTV) được thành lập bởi
các nhà phát triển làm việc trên Hệ thống con truyền thông hạt nhân Linux, cùng với người dùng
người cũng đóng vai trò quan trọng trong việc kiểm tra mã.

Hệ thống con truyền thông có mã để hỗ trợ nhiều loại hoạt động liên quan đến truyền thông
thiết bị: thu luồng, luồng truyền hình analog và kỹ thuật số, máy ảnh,
codec video, xử lý video (bộ chỉnh lại, v.v.), radio, bộ điều khiển từ xa,
HDMI CEC và điều khiển đường ống truyền thông.

Hệ thống con phương tiện bao gồm các thư mục sau trong kernel
cây:

- trình điều khiển/phương tiện truyền thông
  - trình điều khiển/dàn dựng/phương tiện truyền thông
  - bao gồm/phương tiện truyền thông
  - Tài liệu/devicetree/bind/media/\ [1]_
  - Tài liệu/admin-guide/media
  - Tài liệu/driver-api/media
  - Tài liệu/không gian người dùng-api/phương tiện truyền thông

.. [1] Device tree bindings are maintained by the
       OPEN FIRMWARE AND FLATTENED DEVICE TREE BINDINGS maintainers
       (see the MAINTAINERS file). So, changes there must be reviewed
       by them before being merged into the media subsystem's development
       tree.

Cả không gian người dùng phương tiện và API hạt nhân đều được ghi lại và tài liệu
phải được giữ đồng bộ với những thay đổi của API. Nó có nghĩa là tất cả các bản vá lỗi
thêm các tính năng mới vào hệ thống con cũng phải mang lại những thay đổi cho
tài liệu API tương ứng.

Người bảo trì phương tiện
-----------------

Người bảo trì phương tiện không chỉ là những người có khả năng viết mã mà họ còn
là những nhà phát triển đã chứng tỏ được khả năng cộng tác với
nhóm, thu hút những người hiểu biết nhất để xem xét mã, đóng góp
mã chất lượng cao và làm theo để khắc phục sự cố (trong mã hoặc kiểm tra).

Do kích thước và phạm vi rộng của hệ thống con truyền thông, nhiều lớp
cần có người bảo trì, mỗi người có lĩnh vực chuyên môn riêng:

-ZZ0000ZZ:
    Chịu trách nhiệm về một hoặc nhiều trình điều khiển trong Hệ thống con truyền thông. Họ
    được liệt kê trong tệp MAINTAINERS làm người bảo trì cho các trình điều khiển đó. Phương tiện truyền thông
    Người bảo trì trình điều khiển xem xét các bản vá cho các trình điều khiển đó, cung cấp phản hồi nếu
    các bản vá không tuân theo các quy tắc của hệ thống con hoặc không sử dụng
    hạt nhân phương tiện hoặc API không gian người dùng một cách chính xác hoặc nếu chúng có mã kém
    chất lượng.

Nếu bạn là tác giả bản vá, bạn sẽ làm việc với Phương tiện khác
    Người bảo trì để đảm bảo các bản vá của bạn được xem xét.

Một số Người bảo trì trình điều khiển phương tiện có thêm trách nhiệm. Họ có
    được cấp quyền truy cập Patchwork và giữ
    ZZ0000ZZ
    cập nhật, quyết định khi nào các bản vá đã sẵn sàng để hợp nhất và tạo Pull
    Yêu cầu Người bảo trì hệ thống con phương tiện hợp nhất.

-ZZ0000ZZ:
    Người bảo trì trình điều khiển phương tiện có quyền truy cập Patchwork cũng chịu trách nhiệm về
    một hoặc nhiều khung lõi truyền thông.

Những thay đổi về khung cốt lõi được thực hiện thông qua sự đồng thuận giữa các phương tiện truyền thông liên quan
    Người bảo trì cốt lõi. Người bảo trì phương tiện có thể bao gồm các thay đổi khung cốt lõi trong
    Yêu cầu Kéo của họ nếu chúng được Media Core có liên quan phê duyệt
    Người bảo trì.

-ZZ0000ZZ:
    Người bảo trì Media Core cũng chịu trách nhiệm về hệ thống con với tư cách là người
    toàn bộ, với quyền truy cập vào toàn bộ hệ thống con. Chịu trách nhiệm sáp nhập Pull
    Yêu cầu từ những người bảo trì phương tiện khác.

Các thay đổi API/ABI của không gian người dùng được thực hiện thông qua sự đồng thuận giữa Hệ thống con truyền thông
    Người bảo trì\ [2]_. Người bảo trì phương tiện có thể bao gồm các thay đổi API/ABI trong
    Yêu cầu kéo của họ nếu chúng được tất cả Hệ thống con truyền thông phê duyệt
    Người bảo trì.

Tất cả Người bảo trì phương tiện phải đồng ý với quy trình phát triển hạt nhân như
được mô tả trong Documentation/process/index.rst và với sự phát triển hạt nhân
các quy tắc trong tài liệu Kernel, bao gồm cả quy tắc ứng xử của nó.

Người bảo trì phương tiện thường có thể truy cập được qua kênh #linux-media IRC tại OFTC.

.. [2] Everything that would break backward compatibility with existing
       non-kernel code are API/ABI changes. This includes ioctl and sysfs
       interfaces, v4l2 controls, and their behaviors.

Truy cập chắp vá
----------------

Tất cả Người bảo trì phương tiện đã được cấp quyền truy cập Patchwork phải đảm bảo rằng
ZZ0000ZZ
sẽ phản ánh trạng thái hiện tại, ví dụ: các bản vá lỗi sẽ được ủy quyền cho Phương tiện truyền thông
Người bảo trì đang xử lý chúng và trạng thái bản vá sẽ được cập nhật theo
tới những quy tắc này:

- ZZ0000ZZ: Được sử dụng nếu bản vá yêu cầu ý kiến thứ hai
  hoặc khi nó là một phần của Yêu cầu kéo;
- ZZ0001ZZ: Có phiên bản mới hơn của bản vá được đăng lên
  danh sách gửi thư.
- ZZ0002ZZ: Có một bản vá khác cũng làm điều tương tự từ ai đó
  khác điều đó đã được chấp nhận.
- ZZ0003ZZ: Dùng cho các dòng patch chưa được gộp tại media.git
  cây (ví dụ: drm, dmabuf, hợp nhất ngược dòng, v.v.) nhưng được đăng chéo lên
  danh sách gửi thư linux-media.
- ZZ0004ZZ: Sau khi một bản vá được hợp nhất trong cây đa cộng tác. Chỉ phương tiện
  Người bảo trì có quyền cam kết được phép thiết lập trạng thái này.

Nếu Người bảo trì phương tiện quyết định không chấp nhận bản vá, họ nên trả lời
vá lỗi cho tác giả qua email, giải thích lý do tại sao nó không được chấp nhận và
cập nhật ZZ0000ZZ
tương ứng với một trong các trạng thái sau:

- ZZ0000ZZ: nếu yêu cầu sửa đổi mới;
- ZZ0001ZZ: nếu thay đổi được đề xuất không được chấp nhận chút nào.

.. Note::

   Patchwork supports a couple of clients to help semi-automate
   status updates via its REST interface:

   https://patchwork.readthedocs.io/en/latest/usage/clients/

Đối với các bản vá thuộc phạm vi trách nhiệm của họ, Người bảo trì phương tiện
cũng quyết định khi nào các bản vá đó sẵn sàng để hợp nhất và tạo Yêu cầu kéo
để Người bảo trì hệ thống con phương tiện hợp nhất.

Khía cạnh quan trọng nhất của việc trở thành Người bảo trì phương tiện với quyền truy cập Patchwork
là bạn đã chứng tỏ được khả năng đưa ra những đánh giá mã tốt. Chúng tôi đánh giá cao
khả năng của bạn trong việc đưa ra các đánh giá mã kỹ lưỡng, mang tính xây dựng.

Như vậy, những người bảo trì tiềm năng phải có đủ uy tín và sự tin tưởng từ
Cộng đồng truyền thông Linux. Để làm được điều đó, các nhà phát triển phải làm quen với việc mở
mô hình nguồn và đã hoạt động trong cộng đồng Linux Kernel một thời gian,
và đặc biệt là trong hệ thống con truyền thông.

Ngoài việc thực sự thực hiện các thay đổi về mã, về cơ bản bạn còn
thể hiện:

- cam kết với dự án;
- khả năng cộng tác với nhóm và giao tiếp tốt;
- hiểu biết về cách thức hoạt động của thượng nguồn và Cộng đồng Truyền thông Linux
  (chính sách, quy trình kiểm thử, review code,...)
- Kiến thức hợp lý về:

- Quá trình phát triển hạt nhân:
    Tài liệu/quy trình/index.rst

- Hồ sơ phát triển truyền thông:
    Tài liệu/driver-api/media/maintainer-entry-profile.rst

- hiểu biết về cơ sở mã và phong cách mã hóa của dự án;
- khả năng cung cấp phản hồi cho tác giả bản vá;
- khả năng đánh giá khi nào một bản vá có thể sẵn sàng để xem xét và gửi đi;
- khả năng viết mã tốt (cuối cùng nhưng không kém phần quan trọng).

Khuyến khích những Người bảo trì trình điều khiển phương tiện mong muốn có được quyền truy cập Patchwork
tham gia Hội nghị thượng đỉnh truyền thông Linux hàng năm, thường được tổ chức cùng với
một hội nghị liên quan đến Linux. Những hội nghị thượng đỉnh này được công bố trên linux-media
danh sách gửi thư.

Nếu bạn đang thực hiện những nhiệm vụ như vậy và đã trở thành một nhà phát triển có giá trị,
Người bảo trì phương tiện truyền thông hiện tại có thể đề cử bạn vào Người bảo trì hệ thống con phương tiện.

Trách nhiệm cuối cùng trong việc chấp nhận người bảo trì được chỉ định là tùy thuộc vào
người bảo trì hệ thống con. Người bảo trì được chỉ định phải có được sự tin tưởng
mối quan hệ với tất cả Người bảo trì hệ thống con phương tiện, bằng cách được cấp
Truy cập chắp vá, bạn sẽ đảm nhận một phần nhiệm vụ bảo trì của mình.

Người ủy thác truyền thông
----------------

Người bảo trì phương tiện có kinh nghiệm và đáng tin cậy có thể được cấp quyền cam kết
thay vào đó, cho phép họ đẩy trực tiếp các bản vá vào cây phát triển phương tiện
về việc đăng Yêu cầu kéo dành cho Người bảo trì hệ thống con phương tiện. Điều này giúp
giảm tải một số công việc của Người bảo trì hệ thống con phương tiện.

Bạn có thể tìm hiểu thêm thông tin chi tiết về vai trò và trách nhiệm của Người cam kết truyền thông.
tìm thấy ở đây: ZZ0000ZZ.

Các trang web phát triển truyền thông
-----------------------

Trang web ZZ0000ZZ lưu trữ tin tức về hệ thống con,
cùng với:

- ZZ0000ZZ;
- ZZ0001ZZ;
- ZZ0002ZZ;
- và hơn thế nữa

Các cây phát triển chính được hệ thống con phương tiện sử dụng là:

- Cây ổn định:
  -ZZ0000ZZ

- Cây cam kết truyền thông:
  -ZZ0000ZZ

Xin lưu ý rằng nó có thể được khởi động lại, mặc dù chỉ là phương sách cuối cùng.

- Cây phát triển phương tiện, bao gồm ứng dụng và CI:

-ZZ0000ZZ
  -ZZ0001ZZ


.. _Media development workflow:

Quy trình phát triển phương tiện truyền thông
++++++++++++++++++++++++++

Tất cả các thay đổi đối với hệ thống con phương tiện sẽ được gửi trước tiên dưới dạng e-mail đến
danh sách gửi thư của phương tiện truyền thông, theo quy trình được ghi lại tại
Tài liệu/quy trình/index.rst.

Điều đó có nghĩa là các bản vá sẽ chỉ được gửi dưới dạng văn bản thuần túy qua e-mail tới
linux-media@vger.kernel.org (còn gọi là: LMML). Mặc dù việc đăng ký là không bắt buộc,
bạn có thể tìm thấy thông tin chi tiết về cách đăng ký và xem kho lưu trữ của nó tại:

ZZ0000ZZ

Email có HTML sẽ bị máy chủ thư tự động từ chối.

Sẽ là khôn ngoan nếu bạn sao chép (các) Người bảo trì phương tiện có liên quan. Bạn nên sử dụng
ZZ0000ZZ để xác định ai khác cần được sao chép.
Hãy luôn sao chép tác giả và người bảo trì trình điều khiển.

Để giảm thiểu nguy cơ xung đột hợp nhất cho chuỗi bản vá của bạn và làm cho nó
dễ dàng chuyển các bản vá lỗi sang Kernel ổn định hơn, chúng tôi khuyên bạn nên sử dụng
đường cơ sở sau đây cho loạt bản vá của bạn:

1. Các tính năng cho bản phát hành chính tiếp theo:

- đường cơ sở sẽ là nhánh ZZ0000ZZ;

2. Sửa lỗi cho bản phát hành chính tiếp theo:

- đường cơ sở sẽ là nhánh ZZ0000ZZ. Nếu
     những thay đổi phụ thuộc vào bản sửa lỗi từ ZZ0001ZZ
     nhánh, thì bạn có thể sử dụng nó làm đường cơ sở.

3. Sửa lỗi cho bản phát hành dòng chính hiện tại (-rcX):

- đường cơ sở phải là bản phát hành -rcX chính thống mới nhất hoặc
     Nhánh ZZ0000ZZ nếu các thay đổi phụ thuộc vào tuyến chính
     sửa lỗi chưa được hợp nhất;

.. Note::

   See https://www.kernel.org/category/releases.html for an overview
   about Kernel release types.

Các bản vá có sửa lỗi sẽ có:

- thẻ ZZ0000ZZ trỏ đến lần xác nhận đầu tiên gây ra lỗi;
- khi áp dụng, ZZ0001ZZ.

Các bản vá sửa lỗi được báo cáo công khai bởi ai đó tại
danh sách gửi thư linux-media@vger.kernel.org sẽ có:

- thẻ ZZ0000ZZ ngay sau đó là thẻ ZZ0001ZZ.

Các bản vá thay đổi API sẽ cập nhật tài liệu tương ứng tại
cùng một loạt bản vá.

Xem Documentation/process/index.rst để biết thêm chi tiết về cách gửi e-mail.

Sau khi bản vá được gửi, nó có thể tuân theo một trong các bước sau
quy trình làm việc:

Một. Quy trình làm việc của Người bảo trì phương tiện: Người bảo trì phương tiện đăng Yêu cầu kéo,
   được xử lý bởi Người bảo trì hệ thống con phương tiện::

+-------+ +-------------+ +------+ +-------+ +-------------+
     ZZ0000ZZ->ZZ0001ZZ->ZZ0002ZZ->ZZ0003ZZ->ZZ0004ZZ
     ZZ0005ZZ ZZ0006ZZ ZZ0007ZZ ZZ0008ZZ ZZ0009ZZ
     ZZ0010ZZ ZZ0011ZZ ZZ0012ZZ ZZ0013ZZ ZZ0014ZZ
     +-------+ +-------------+ +------+ +-------+ +-------------+

Đối với quy trình công việc này, Yêu cầu kéo được tạo bởi Người bảo trì phương tiện với
   Truy cập chắp vá.  Nếu bạn không có quyền truy cập Patchwork thì vui lòng không
   gửi Yêu cầu kéo vì chúng sẽ không được xử lý.

b. Quy trình làm việc của Người bảo trì phương tiện: các bản vá được Người bảo trì phương tiện xử lý bằng
   cam kết quyền::

+-------+ +-------------+ +------+ +-----------------+
     ZZ0000ZZ->ZZ0001ZZ->ZZ0002ZZ->ZZ0003ZZ
     ZZ0004ZZ ZZ0005ZZ ZZ0006ZZ ZZ0007ZZ
     +-------+ +-------------+ +------+ +-----------------+

Khi các bản vá được chọn bởi
ZZ0000ZZ
và khi được sáp nhập tại các media-committers, các bot Media CI sẽ kiểm tra lỗi và
có thể cung cấp phản hồi qua e-mail về các vấn đề về bản vá. Khi điều này xảy ra, bản vá
người gửi phải sửa chúng hoặc giải thích lý do lỗi là sai.

Các bản vá sẽ chỉ được chuyển sang giai đoạn tiếp theo trong hai quy trình công việc này nếu chúng
chuyển Media CI hoặc nếu có kết quả dương tính giả trong báo cáo Media CI.

Đối với cả hai quy trình công việc, tất cả các bản vá sẽ được xem xét đúng cách tại
linux-media@vger.kernel.org (LMML) trước khi được sáp nhập vào
ZZ0000ZZ. Các bản vá phương tiện sẽ được xem xét kịp thời
bởi người bảo trì và người đánh giá như được liệt kê trong tệp MAINTAINERS.

Người bảo trì phương tiện sẽ yêu cầu đánh giá từ Người bảo trì phương tiện khác và
nhà phát triển nếu có, tức là vì những nhà phát triển đó có nhiều
kiến thức về một số lĩnh vực được thay đổi bởi một bản vá.

Sẽ không có vấn đề mở hoặc phản hồi chưa được giải quyết hoặc mâu thuẫn
từ bất cứ ai. Hãy dọn sạch chúng trước tiên. Trì hoãn hệ thống con truyền thông
Người bảo trì nếu cần.

Lỗi khi gửi email
+++++++++++++++++++++++++++++++++

Quy trình làm việc của Media chủ yếu dựa trên Patchwork, nghĩa là sau khi tạo một bản vá,
được gửi, e-mail trước tiên sẽ được chấp nhận bởi danh sách gửi thư
máy chủ và sau một thời gian, nó sẽ xuất hiện tại:

-ZZ0000ZZ

Nếu nó không tự động xuất hiện ở đó sau một thời gian [3]_, thì
có thể đã xảy ra lỗi trong bài gửi của bạn. Vui lòng kiểm tra xem
email chỉ ở dạng văn bản thuần túy\ [4]_ và nếu người gửi email của bạn không đọc sai
khoảng trắng trước khi khiếu nại hoặc gửi lại.

Để khắc phục sự cố, trước tiên bạn nên kiểm tra xem danh sách gửi thư có
máy chủ đã chấp nhận bản vá của bạn, bằng cách xem:

-ZZ0000ZZ

Nếu bản vá có ở đó và không có ở
ZZ0000ZZ,
có khả năng là người gửi email của bạn đã làm sai bản vá. Chắp vá nội bộ
có logic kiểm tra xem e-mail nhận được có chứa bản vá hợp lệ hay không.
Bất kỳ khoảng trắng và ngắt dòng mới nào làm xáo trộn bản vá sẽ không được công nhận
ZZ0001ZZ,
và bản vá như vậy sẽ bị từ chối.

.. [3] It usually takes a few minutes for the patch to arrive, but
       the e-mail server may be busy, so it may take a longer time
       for a patch to be picked by
       `Patchwork <https://patchwork.linuxtv.org/project/linux-media/list/>`_.

.. [4] If your email contains HTML, the mailing list server will simply
       drop it, without any further notice.

.. _media-developers-gpg:

Xác thực cho các yêu cầu kéo và hợp nhất
++++++++++++++++++++++++++++++++++++++++++

Tính xác thực của các nhà phát triển gửi Yêu cầu kéo và yêu cầu hợp nhất
sẽ được xác thực bằng cách sử dụng Linux Kernel Web of Trust, với chữ ký PGP
vào một thời điểm nào đó. Xem: ZZ0000ZZ.

Với quy trình làm việc Yêu cầu kéo, Yêu cầu kéo sẽ sử dụng thẻ có chữ ký PGP.

Với quy trình làm việc của người ủy quyền, điều này được đảm bảo tại thời điểm yêu cầu hợp nhất
quyền sẽ được cấp cho phiên bản gitlab được media-committers.git sử dụng
cây, sau khi nhận được e-mail được ghi trong
ZZ0000ZZ.

Để biết thêm chi tiết về việc ký PGP, vui lòng đọc
Tài liệu/quy trình/bảo trì-pgp-guide.rst.

Duy trì trạng thái người duy trì phương tiện
-----------------------------------

Xem ZZ0000ZZ.

Danh sách người bảo trì phương tiện
-------------------------

Những người bảo trì phương tiện được liệt kê ở đây đều có quyền truy cập chắp vá và có thể
thực hiện Yêu cầu kéo hoặc có quyền cam kết.

Người bảo trì hệ thống con phương tiện là:
  - Mauro Carvalho Chehab <mchehab@kernel.org>
  - Hans Verkuil <hverkuil@kernel.org>

Người bảo trì Media Core là:
  - Sakari Ailus <sakari.ailus@linux.intel.com>

- Trình điều khiển bộ điều khiển phương tiện
    - Khung điều khiển phương tiện lõi
    -ISP
    - trình điều khiển cảm biến
    - khung lõi v4l2-async và v4l2-fwnode
    - khung lõi lớp v4l2-flash-led-class

- Mauro Carvalho Chehab <mchehab@kernel.org>

-DVB

- Laurent Pinchart <laurent.pinchart@ideasonboard.com>

- Trình điều khiển bộ điều khiển phương tiện
    - Khung điều khiển phương tiện lõi
    -ISP

- Hans Verkuil <hverkuil@kernel.org>

- Trình điều khiển V4L2
    - Khung lõi V4L2 và videobuf2
    - Trình điều khiển HDMI CEC
    - Khung lõi HDMI CEC

- Sean Young <sean@mess.org>

- Trình điều khiển điều khiển từ xa (hồng ngoại)
    - Khung lõi điều khiển từ xa (hồng ngoại)

Người bảo trì trình điều khiển phương tiện chịu trách nhiệm về các lĩnh vực cụ thể là:
  - Nicolas Dufresne <nicolas.dufresne@collabora.com>

- Trình điều khiển Codec
    - Trình điều khiển M2M không được ủy quyền

- Bryan O'Donoghue <bryan.odonoghue@linaro.org>

- Trình điều khiển Qualcomm

Gửi phụ lục danh sách kiểm tra
-------------------------

Các bản vá thay đổi liên kết Open Firmware/Device Tree phải được
được xem xét bởi những người bảo trì Cây thiết bị. Vì vậy, người bảo trì DT nên
Cc:ed khi chúng được gửi qua gửi thư devicetree@vger.kernel.org
danh sách.

Có một bộ công cụ tuân thủ tại ZZ0000ZZ
nên được sử dụng để kiểm tra xem trình điều khiển có đúng không
triển khai các API phương tiện:

==================== ============================================================
Loại tiện ích
==================== ============================================================
Trình điều khiển V4L2\ [5]_ ZZ0000ZZ
Trình điều khiển ảo V4L2 ZZ0001ZZ
Trình điều khiển CEC ZZ0002ZZ
==================== ============================================================

.. [5] The ``v4l2-compliance`` utility also covers the media controller usage
       inside V4L2 drivers.

Những thử nghiệm đó cần phải vượt qua trước khi các bản vá được đưa lên thượng nguồn.

Ngoài ra, xin lưu ý rằng chúng tôi xây dựng Kernel với::

tạo CF=-D__CHECK_ENDIAN__ CONFIG_DEBUG_SECTION_MISMATCH=y C=1 W=1 CHECK=check_script

Tập lệnh kiểm tra nằm ở đâu::

#!/bin/bash
	/devel/smatch/smatch -p=kernel $@ >&2
	/phát triển/thưa thớt/thưa thớt $@ >&2

Đảm bảo không đưa ra cảnh báo mới trên các bản vá của bạn mà không có
lý do rất tốt.

Vui lòng xem ZZ0000ZZ để biết các quy tắc gửi e-mail.

Bản vá dọn dẹp phong cách
+++++++++++++++++++++

Việc dọn dẹp phong cách được hoan nghênh khi chúng đi kèm với những thay đổi khác
tại các tập tin mà sự thay đổi kiểu dáng sẽ ảnh hưởng.

Chúng tôi có thể chấp nhận việc dọn dẹp theo phong cách độc lập thuần túy, nhưng lý tưởng nhất là chúng nên
là một bản vá cho toàn bộ hệ thống con (nếu quá trình dọn dẹp có khối lượng thấp),
hoặc ít nhất được nhóm theo mỗi thư mục. Vì vậy, ví dụ, nếu bạn đang làm một
thay đổi dọn dẹp lớn được đặt ở trình điều khiển trong trình điều khiển/phương tiện, vui lòng gửi một
bản vá cho tất cả các trình điều khiển trong trình điều khiển/media/pci, một bản khác dành cho
trình điều khiển/phương tiện/usb, v.v.

Phụ lục về kiểu mã hóa
+++++++++++++++++++++

Phát triển phương tiện sử dụng ZZ0000ZZ ở chế độ nghiêm ngặt để xác minh mã
phong cách, ví dụ::

$ ./scripts/checkpatch.pl --strict --max-line-length=80

Về nguyên tắc, các bản vá phải tuân theo các quy tắc về kiểu mã hóa, nhưng các ngoại lệ
được phép nếu có lý do chính đáng. Trong trường hợp đó, người bảo trì và người đánh giá
có thể đặt câu hỏi về lý do không giải quyết ZZ0000ZZ.

Xin lưu ý rằng mục tiêu ở đây là cải thiện khả năng đọc mã. Bật
trong một số trường hợp, ZZ0000ZZ thực sự có thể chỉ ra điều gì đó có thể
trông tệ hơn. Vì vậy, bạn nên sử dụng ý thức tốt.

Lưu ý rằng chỉ giải quyết một vấn đề ZZ0000ZZ (dưới bất kỳ hình thức nào) có thể dẫn đến
để có dòng dài hơn 80 ký tự trên mỗi dòng. Trong khi điều này không
bị nghiêm cấm, cần nỗ lực duy trì trong phạm vi 80
ký tự trên mỗi dòng. Điều này có thể bao gồm việc sử dụng mã tái bao thanh toán dẫn đến
để ít thụt lề hơn, tên biến hoặc hàm ngắn hơn và cuối cùng nhưng không
ít nhất, chỉ đơn giản là gói các dòng.

Đặc biệt, chúng tôi chấp nhận các dòng có hơn 80 cột:

- trên chuỗi, vì chúng không bị hỏng do giới hạn độ dài dòng;
    - khi một hàm hoặc tên biến cần có tên định danh dài,
      điều này khiến việc tôn trọng giới hạn 80 cột trở nên khó khăn;
    - trên các biểu thức số học, khi việc ngắt dòng khiến chúng khó thực hiện hơn
      đọc;
    - khi họ tránh dòng kết thúc bằng dấu ngoặc đơn mở hoặc dấu mở
      khung.

Ngày chu kỳ chính
---------------

Các bài nộp mới có thể được gửi bất cứ lúc nào, nhưng nếu chúng có ý định đạt được
cửa sổ hợp nhất tiếp theo, chúng sẽ được gửi trước -rc5 và được ổn định một cách lý tưởng
trong nhánh linux-media bởi -rc6.

Xem lại nhịp
--------------

Với điều kiện là bản vá của bạn đã cập bến
ZZ0000ZZ, nó
sớm hay muộn cũng sẽ được xử lý nên bạn không cần phải gửi lại bản vá.

Ngoại trừ các bản sửa lỗi quan trọng, chúng tôi thường không thêm các bản vá mới vào
cây phát triển giữa -rc6 và -rc1 tiếp theo.

Xin lưu ý rằng hệ thống con phương tiện truyền thông là hệ thống có lưu lượng truy cập cao, vì vậy nó
có thể mất một thời gian để chúng tôi có thể xem xét các bản vá của bạn. Hãy thoải mái
để ping nếu bạn không nhận được phản hồi trong vài tuần hoặc để hỏi
các nhà phát triển khác thêm công khai ZZ0000ZZ và quan trọng hơn là
Thẻ ZZ0001ZZ.

Xin lưu ý rằng chúng tôi mong đợi một mô tả chi tiết cho ZZ0000ZZ,
xác định những bảng nào đã được sử dụng trong quá trình thử nghiệm và những gì nó đã được kiểm tra.