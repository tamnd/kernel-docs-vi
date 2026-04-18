.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/security-bugs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _securitybugs:

Lỗi bảo mật
=============

Các nhà phát triển nhân Linux rất coi trọng vấn đề bảo mật.  Như vậy, chúng tôi sẽ
muốn biết khi nào một lỗi bảo mật được tìm thấy để có thể sửa nó và
được tiết lộ càng nhanh càng tốt.

Đang chuẩn bị báo cáo của bạn
-----------------------------

Giống như bất kỳ báo cáo lỗi nào, báo cáo lỗi bảo mật yêu cầu nhiều công việc phân tích
từ các nhà phát triển, vì vậy bạn càng chia sẻ được nhiều thông tin về vấn đề này,
tốt hơn.  Vui lòng xem lại quy trình được nêu trong
Documentation/admin-guide/reporting-issues.rst nếu bạn không rõ về điều gì
thông tin rất hữu ích.  Những thông tin sau đây thực sự cần thiết trong
Báo cáo lỗi bảo mật ZZ0000ZZ:

* ZZ0000ZZ: không có chỉ báo phiên bản, báo cáo của bạn
    sẽ không được xử lý.  Một phần quan trọng của các báo cáo là về các lỗi
    đã được sửa chữa, vì vậy điều cực kỳ quan trọng là các lỗ hổng
    được xác minh trên các phiên bản gần đây (cây phát triển hoặc bản ổn định mới nhất
    phiên bản), ít nhất bằng cách xác minh rằng mã không thay đổi kể từ
    phiên bản nơi nó được phát hiện.

* ZZ0000ZZ: mô tả chi tiết vấn đề, kèm theo
    dấu vết cho thấy sự biểu hiện của nó, và tại sao bạn cho rằng điều được quan sát
    hành vi như một vấn đề trong kernel là cần thiết.

* ZZ0000ZZ: các nhà phát triển sẽ cần có khả năng tái tạo vấn đề để
    coi việc sửa chữa là có hiệu quả.  Điều này bao gồm cả một cách để kích hoạt vấn đề
    và một cách để xác nhận nó xảy ra.  Một trình tái tạo có độ phức tạp thấp
    sẽ cần đến các phụ thuộc (mã nguồn, tập lệnh shell, trình tự của
    hướng dẫn, hình ảnh hệ thống tập tin, v.v.).  Các tệp thực thi chỉ có dạng nhị phân thì không
    được chấp nhận.  Các hoạt động khai thác cực kỳ hữu ích và sẽ không được phát hành
    mà không có sự đồng ý của phóng viên, trừ khi chúng đã được công khai.  Bởi
    định nghĩa nếu một vấn đề không thể được tái tạo lại thì nó không thể khai thác được, do đó nó
    không phải là lỗi bảo mật.

* ZZ0000ZZ: nếu lỗi phụ thuộc vào các tùy chọn cấu hình nhất định,
    sysctls, quyền, thời gian, sửa đổi mã, v.v., những thứ này phải là
    được chỉ ra.

Ngoài ra, những thông tin sau đây rất được mong muốn:

* ZZ0000ZZ: tên tập tin và chức năng nơi
    lỗi bị nghi ngờ là có mặt là rất quan trọng, ít nhất là để giúp chuyển tiếp
    báo cáo cho người bảo trì thích hợp.  Khi không thể (ví dụ:
    "hệ thống bị treo mỗi lần tôi chạy lệnh này"), nhóm bảo mật sẽ trợ giúp
    xác định nguồn gốc của lỗi.

* ZZ0002ZZ: người báo cáo lỗi đã phân tích nguyên nhân gây ra lỗi trong
    mã nguồn hầu như luôn có ý tưởng chính xác về cách khắc phục nó,
    bởi vì họ đã dành một thời gian dài để nghiên cứu nó và ý nghĩa của nó.  Đề xuất
    bản sửa lỗi đã được thử nghiệm sẽ tiết kiệm cho người bảo trì rất nhiều thời gian, ngay cả khi bản sửa lỗi kết thúc
    không phải là đúng vì nó giúp hiểu được lỗi.  Khi nào
    đề xuất bản sửa lỗi đã được thử nghiệm, vui lòng luôn định dạng nó theo cách có thể
    được hợp nhất ngay lập tức (xem Tài liệu/quy trình/gửi-patches.rst).
    Điều này sẽ lưu lại một số trao đổi qua lại nếu nó được chấp nhận và bạn
    sẽ được ghi nhận vì đã tìm và khắc phục sự cố này.  Lưu ý rằng trong trường hợp này
    chỉ cần thẻ ZZ0000ZZ, không cần thẻ ZZ0001ZZ khi
    phóng viên và tác giả đều giống nhau.

* ZZ0000ZZ: rất thường xuyên trong quá trình phân tích lỗi, một số cách giảm thiểu
    vấn đề xuất hiện. Việc chia sẻ chúng sẽ rất hữu ích vì chúng có thể hữu ích cho
    giữ cho người dùng cuối được bảo vệ trong thời gian họ áp dụng bản sửa lỗi.

Xác định danh bạ
--------------------

Cách hiệu quả nhất để báo cáo lỗi bảo mật là gửi trực tiếp tới
những người bảo trì hệ thống con bị ảnh hưởng và Cc: nhóm bảo mật nhân Linux.  làm
không gửi nó vào danh sách công khai ở giai đoạn này, trừ khi bạn có lý do chính đáng để
coi vấn đề là công khai hoặc tầm thường để khám phá (ví dụ: kết quả của một
công cụ quét lỗ hổng tự động có sẵn rộng rãi có thể được lặp lại bởi
bất cứ ai).

Nếu bạn đang gửi báo cáo về các sự cố ảnh hưởng đến nhiều phần trong kernel,
ngay cả khi chúng có những vấn đề khá giống nhau, vui lòng gửi từng tin nhắn riêng lẻ (nghĩ
rằng những người bảo trì sẽ không giải quyết tất cả các vấn đề cùng một lúc). duy nhất
ngoại lệ là khi một vấn đề liên quan đến các bộ phận có liên quan chặt chẽ được duy trì bởi
chính xác cùng một tập hợp con của người bảo trì và những phần này dự kiến sẽ được sửa chữa tất cả
cùng một lúc bằng cùng một cam kết thì việc báo cáo chúng cùng một lúc có thể được chấp nhận.

Một khó khăn đối với hầu hết các phóng viên lần đầu là tìm ra danh sách phù hợp
người nhận gửi báo cáo tới.  Trong nhân Linux, tất cả các nhà bảo trì chính thức
được tin cậy, do đó hậu quả của việc vô tình thêm sai người bảo trì
về cơ bản là ồn ào hơn một chút đối với người đó, tức là không có gì kịch tính.  Như
như vậy, một phương pháp phù hợp để tìm ra danh sách những người bảo trì (kernel nào
nhân viên an ninh sử dụng) là dựa vào tập lệnh get_maintainer.pl, được điều chỉnh để
chỉ báo cáo người bảo trì.  Tập lệnh này, khi được truyền tên tệp, sẽ tìm kiếm
đường dẫn của nó trong tệp MAINTAINERS để tìm ra danh sách phân cấp có liên quan
người bảo trì.  Gọi nó là lần đầu tiên với mức lọc tốt nhất sẽ
hầu hết thời gian đều trả về một danh sách ngắn những người bảo trì tệp cụ thể này ::

$ ./scripts/get_maintainer.pl --no-l --no-r --pattern-deep 1 \
    trình điều khiển/example.c
  Nhà phát triển Một <dev1@example.com> (người bảo trì: trình điều khiển mẫu)
  Nhà phát triển Hai <dev2@example.org> (người bảo trì:trình điều khiển mẫu)

Hai người bảo trì này sau đó sẽ nhận được tin nhắn.  Nếu lệnh không
trả lại bất cứ thứ gì, điều đó có nghĩa là tệp bị ảnh hưởng là một phần của hệ thống con rộng hơn, vì vậy chúng tôi
nên ít cụ thể hơn::

$ ./scripts/get_maintainer.pl --no-l --no-r driver/example.c
  Nhà phát triển Một <dev1@example.com> (người bảo trì: hệ thống con ví dụ)
  Nhà phát triển thứ hai <dev2@example.org> (người bảo trì: hệ thống con ví dụ)
  Nhà phát triển thứ ba <dev3@example.com> (người bảo trì: hệ thống con ví dụ [GENERAL])
  Nhà phát triển Bốn <dev4@example.org> (người bảo trì:hệ thống con ví dụ [GENERAL])

Ở đây, chỉ cần chọn cái đầu tiên, cụ thể nhất là đủ.  Khi danh sách được
dài, có thể tạo danh sách địa chỉ e-mail được phân cách bằng dấu phẩy trên một
một dòng thích hợp để sử dụng trong trường To: của một người gửi thư như thế này::

$ ./scripts/get_maintainer.pl --no-tree --no-l --no-r --no-n --m \
    --no-git-fallback --no-substatus --no-rolistats --no-multiline \
    --pattern-độ sâu 1 trình điều khiển/example.c
  dev1@example.com, dev2@example.org

hoặc cái này cho danh sách rộng hơn ::

$ ./scripts/get_maintainer.pl --no-tree --no-l --no-r --no-n --m \
    --no-git-fallback --no-substatus --no-rolistats --no-multiline \
    trình điều khiển/example.c
  dev1@example.com, dev2@example.org, dev3@example.com, dev4@example.org

Nếu tại thời điểm này bạn vẫn gặp khó khăn trong việc xác định đúng
người bảo trì, ZZ0000ZZ, bạn có thể gửi báo cáo của mình tới
chỉ dành cho nhóm bảo mật nhân Linux.  Tin nhắn của bạn sẽ được phân loại và bạn
sẽ nhận được hướng dẫn về người cần liên hệ, nếu cần.  Tin nhắn của bạn có thể
đều được chuyển tiếp nguyên trạng đến những người bảo trì có liên quan.

Gửi báo cáo
------------------

Các báo cáo sẽ được gửi riêng qua e-mail.  Vui lòng sử dụng e-mail đang hoạt động
địa chỉ, tốt nhất là địa chỉ bạn muốn xuất hiện trong thẻ ZZ0000ZZ
nếu có.  Nếu không chắc chắn, hãy gửi báo cáo cho chính bạn trước.

Đội ngũ bảo mật và người bảo trì hầu như luôn yêu cầu bổ sung
thông tin ngoài những gì được cung cấp ban đầu trong báo cáo và dựa vào
cộng tác tích cực và hiệu quả với phóng viên để thực hiện thêm
thử nghiệm (ví dụ: xác minh phiên bản, tùy chọn cấu hình, biện pháp giảm thiểu hoặc
bản vá lỗi). Trước khi liên hệ với đội an ninh, người báo cáo phải đảm bảo
họ sẵn sàng giải thích những phát hiện của mình, tham gia vào các cuộc thảo luận và
chạy thử nghiệm bổ sung.  Báo cáo mà phóng viên không trả lời kịp thời
hoặc không thể thảo luận một cách hiệu quả những phát hiện của họ có thể bị bỏ rơi nếu
giao tiếp không được cải thiện nhanh chóng.

Báo cáo phải được gửi đến người bảo trì, với nhóm bảo mật trong ZZ0000ZZ.
Có thể liên hệ với nhóm bảo mật nhân Linux qua email tại
<security@kernel.org>.  Đây là danh sách riêng của nhân viên an ninh
who will help verify the bug report and assist developers working on a fix.
Có thể đội an ninh sẽ huy động thêm sự trợ giúp từ khu vực
người bảo trì hiểu và khắc phục lỗ hổng bảo mật.

Vui lòng gửi email ZZ0001ZZ không có tệp đính kèm nếu có thể.
Sẽ khó hơn nhiều khi có một cuộc thảo luận dựa trên ngữ cảnh về một vấn đề phức tạp
vấn đề nếu tất cả các chi tiết bị ẩn trong tệp đính kèm.  Hãy nghĩ về nó giống như một
ZZ0000ZZ
(ngay cả khi bạn chưa có bản vá): mô tả vấn đề và tác động, liệt kê
các bước sao chép và thực hiện theo bản sửa lỗi được đề xuất, tất cả đều ở dạng văn bản thuần túy.
Các báo cáo có định dạng Markdown, HTML và RST đặc biệt bị phản đối vì
chúng khá khó đọc đối với con người và khuyến khích sử dụng người xem chuyên dụng,
đôi khi trực tuyến, theo định nghĩa là không thể chấp nhận được đối với thông tin bí mật
báo cáo an ninh. Lưu ý rằng một số người gửi thư có xu hướng đọc sai định dạng của văn bản đơn giản.
văn bản theo mặc định, vui lòng tham khảo Documentation/process/email-clients.rst để biết
thêm thông tin.

Tiết lộ và cấm thông tin
------------------------------------

Danh sách bảo mật không phải là một kênh tiết lộ.  Để biết điều đó, hãy xem Phối hợp
bên dưới.

Khi bản sửa lỗi mạnh mẽ đã được phát triển, quá trình phát hành sẽ bắt đầu.  sửa lỗi
đối với các lỗi được biết đến công khai sẽ được phát hành ngay lập tức.

Mặc dù ưu tiên của chúng tôi là phát hành các bản sửa lỗi cho các lỗi không được tiết lộ công khai
ngay khi chúng sẵn sàng, việc này có thể được hoãn lại theo yêu cầu của
người báo cáo hoặc bên bị ảnh hưởng trong tối đa 7 ngày theo lịch kể từ khi bắt đầu
của quá trình phát hành, với thời gian gia hạn đặc biệt là 14 ngày theo lịch
nếu mọi người đồng ý rằng mức độ nghiêm trọng của lỗi cần nhiều thời gian hơn.  các
lý do hợp lệ duy nhất để trì hoãn việc xuất bản bản sửa lỗi là để đáp ứng
hậu cần của QA và triển khai quy mô lớn cần phát hành
sự phối hợp.

Mặc dù thông tin bị cấm có thể được chia sẻ với các cá nhân đáng tin cậy trong
để phát triển bản sửa lỗi, thông tin đó sẽ không được công bố cùng với
bản sửa lỗi hoặc trên bất kỳ kênh tiết lộ nào khác mà không có sự cho phép của
phóng viên.  Điều này bao gồm nhưng không giới hạn ở báo cáo lỗi ban đầu
và các cuộc thảo luận tiếp theo (nếu có), khai thác, thông tin CVE hoặc
danh tính của phóng viên.

Nói cách khác, mối quan tâm duy nhất của chúng tôi là sửa lỗi.  Tất cả khác
thông tin được gửi đến danh sách bảo mật và mọi cuộc thảo luận tiếp theo
của báo cáo được xử lý bí mật ngay cả sau khi lệnh cấm vận đã được dỡ bỏ
được dỡ bỏ, vĩnh viễn.

Phối hợp với các nhóm khác
------------------------------

Trong khi nhóm bảo mật kernel chỉ tập trung vào việc sửa lỗi,
các nhóm khác tập trung vào việc khắc phục sự cố trong các bản phân phối và điều phối
tiết lộ giữa các nhà cung cấp hệ điều hành.  Sự phối hợp thường
được xử lý bởi danh sách gửi thư "linux-distros" và được tiết lộ bởi
danh sách gửi thư "bảo mật oss" công khai, cả hai đều có liên quan chặt chẽ với nhau
và được trình bày trong wiki linux-distros:
<ZZ0000ZZ

Xin lưu ý rằng các chính sách và quy định tương ứng sẽ khác nhau vì
3 danh sách theo đuổi các mục tiêu khác nhau.  Phối hợp giữa hạt nhân
nhóm bảo mật và các nhóm khác gặp khó khăn vì bảo mật kernel
đội thỉnh thoảng bị cấm vận (theo số lượng tối đa được phép
ngày) bắt đầu từ khi có bản sửa lỗi, trong khi đối với "bản phân phối linux"
họ bắt đầu từ bài đăng đầu tiên đến danh sách bất kể
sự sẵn có của một sửa chữa.

Do đó, nhóm bảo mật kernel đặc biệt khuyến nghị rằng với tư cách là phóng viên
về một vấn đề bảo mật tiềm ẩn, bạn NOT hãy liên hệ với "linux-distros"
danh sách gửi thư UNTIL một bản sửa lỗi được chấp nhận bởi những người bảo trì mã bị ảnh hưởng
và bạn đã đọc trang wiki distro ở trên và bạn hoàn toàn hiểu
các yêu cầu liên hệ với "linux-distros" sẽ áp đặt lên bạn và
cộng đồng hạt nhân.  Điều này cũng có nghĩa là nhìn chung nó không tạo ra
có ý nghĩa với Cc: cả hai danh sách cùng một lúc, ngoại trừ có thể để phối hợp nếu và
trong khi bản sửa lỗi được chấp nhận vẫn chưa được hợp nhất.  Nói cách khác, cho đến khi một
bản sửa lỗi được chấp nhận không Cc: "linux-distros" và sau khi nó được hợp nhất thì không
Cc: nhóm bảo mật kernel.

Nhiệm vụ CVE
--------------

Nhóm bảo mật không chỉ định CVE và chúng tôi cũng không yêu cầu chúng cho
báo cáo hoặc sửa lỗi, vì điều này có thể làm phức tạp quá trình một cách không cần thiết và có thể
trì hoãn việc xử lý lỗi.  Nếu phóng viên muốn có mã định danh CVE
được chỉ định cho một vấn đề đã được xác nhận, họ có thể liên hệ với ZZ0000ZZ để nhận được một vấn đề.

Thỏa thuận không tiết lộ
-------------------------

Nhóm bảo mật nhân Linux không phải là một cơ quan chính thức và do đó không thể
để tham gia bất kỳ thỏa thuận không tiết lộ.
