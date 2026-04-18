.. SPDX-License-Identifier: (GPL-2.0+ OR CC-BY-4.0)

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/reporting-regressions.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. [see the bottom of this file for redistribution information]

Báo cáo hồi quy
+++++++++++++++++++++

"ZZ0000ZZ" là quy tắc đầu tiên trong quá trình phát triển nhân Linux;
Người sáng lập Linux và nhà phát triển chính Linus Torvalds đã tự mình thành lập nó và
đảm bảo nó được tuân theo.

Tài liệu này mô tả ý nghĩa của quy tắc đối với người dùng và cách hoạt động của nhân Linux.
mô hình phát triển đảm bảo giải quyết được tất cả các vấn đề hồi quy được báo cáo; các khía cạnh liên quan
đối với các nhà phát triển hạt nhân, phần còn lại của Tài liệu/quy trình/xử lý-regressions.rst.


Các bit quan trọng (còn gọi là "TL;DR")
================================

#. Đó là sự hồi quy nếu thứ gì đó chạy tốt với một nhân Linux hoạt động kém hơn
   hoặc hoàn toàn không với phiên bản mới hơn. Lưu ý, kernel mới hơn phải được biên dịch
   sử dụng cấu hình tương tự; những giải thích chi tiết dưới đây mô tả điều này
   và các bản in đẹp khác chi tiết hơn.

#. Báo cáo sự cố của bạn như được nêu trong Tài liệu/admin-guide/reporting-issues.rst,
   nó đã bao gồm tất cả các khía cạnh quan trọng đối với hồi quy và lặp lại
   bên dưới để thuận tiện. Hai trong số đó rất quan trọng: bắt đầu chủ đề báo cáo của bạn
   bằng "[REGRESSION]" và CC hoặc chuyển tiếp nó tới ZZ0000ZZ (regressions@lists.linux.dev).

#. Tùy chọn, nhưng được khuyến nghị: khi gửi hoặc chuyển tiếp báo cáo của bạn, hãy thực hiện
   Bot theo dõi hồi quy nhân Linux "regzbot" theo dõi vấn đề bằng cách chỉ định
   khi quá trình hồi quy bắt đầu như thế này::

#regzbot giới thiệu: v5.13..v5.14-rc1


Tất cả các chi tiết về hồi quy nhân Linux đều phù hợp với người dùng
==============================================================


Những điều cơ bản quan trọng
--------------------


"hồi quy" là gì và quy tắc "không hồi quy" là gì?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Đó là sự hồi quy nếu một số ứng dụng hoặc trường hợp sử dụng thực tế chạy tốt với
một nhân Linux hoạt động kém hơn hoặc hoàn toàn không hoạt động với phiên bản mới hơn được biên dịch bằng
cấu hình tương tự. Quy tắc "không hồi quy" cấm điều này diễn ra; nếu
nó xảy ra một cách tình cờ, các nhà phát triển gây ra sự cố này dự kiến sẽ nhanh chóng khắc phục
vấn đề.

Do đó, đây là một sự hồi quy khi trình điều khiển WiFi từ Linux 5.13 hoạt động tốt nhưng với
5.14 hoàn toàn không hoạt động, hoạt động chậm hơn đáng kể hoặc hoạt động không đúng cách nào đó.
Đó cũng là một sự hồi quy nếu một ứng dụng đang hoạt động hoàn hảo đột nhiên có biểu hiện thất thường.
hành vi với phiên bản kernel mới hơn; những vấn đề như vậy có thể được gây ra bởi những thay đổi trong
Procfs, sysfs hoặc một trong nhiều giao diện khác mà Linux cung cấp cho vùng người dùng
phần mềm. Nhưng hãy nhớ, như đã đề cập trước đó: 5.14 trong ví dụ này cần phải
được xây dựng từ cấu hình tương tự như cấu hình từ 5.13. Điều này có thể đạt được
sử dụng ZZ0000ZZ, như được giải thích chi tiết hơn bên dưới.

Lưu ý "trường hợp sử dụng thực tế" trong câu đầu tiên của phần này: nhà phát triển
bất chấp quy tắc "không hồi quy" vẫn được tự do thay đổi bất kỳ khía cạnh nào của kernel
và thậm chí cả API hoặc ABI cho vùng người dùng, miễn là không có ứng dụng hoặc mục đích sử dụng hiện có
phá vỡ vụ án.

Ngoài ra, hãy lưu ý quy tắc "không hồi quy" chỉ bao gồm các giao diện kernel
cung cấp cho vùng người dùng. Do đó, nó không áp dụng cho các giao diện nội bộ kernel
như mô-đun API, mà một số trình điều khiển được phát triển bên ngoài sử dụng để kết nối vào
hạt nhân.

Làm cách nào để báo cáo hồi quy?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Chỉ cần báo cáo vấn đề như được nêu trong
Tài liệu/admin-guide/reporting-issues.rst, nó đã mô tả
những điểm quan trọng. Các khía cạnh sau đây được nêu ra có liên quan đặc biệt
cho hồi quy:

* Khi kiểm tra các báo cáo hiện có để tham gia, hãy tìm kiếm ZZ0000ZZ và
   ZZ0001ZZ.

* Bắt đầu chủ đề báo cáo của bạn bằng "[REGRESSION]".

* Trong báo cáo của bạn, hãy đề cập rõ ràng phiên bản kernel cuối cùng hoạt động tốt và
   cái đầu tiên bị hỏng. Tốt nhất hãy cố gắng tìm ra sự thay đổi chính xác gây ra
   hồi quy bằng cách sử dụng phép chia đôi, như được giải thích chi tiết hơn dưới đây.

* Hãy nhớ để Linux hồi quy danh sách gửi thư
   (regressions@lists.linux.dev) biết về báo cáo của bạn:

* Nếu bạn báo cáo hồi quy qua thư, hãy CC danh sách hồi quy.

* Nếu bạn báo cáo hồi quy của mình cho một số trình theo dõi lỗi, hãy chuyển tiếp bản đã gửi
     báo cáo qua thư tới danh sách hồi quy trong khi CC cho người bảo trì và
     danh sách gửi thư cho hệ thống con được đề cập.

Nếu đó là sự hồi quy trong một chuỗi ổn định hoặc dài hạn (ví dụ:
   v5.15.3..v5.15.5), hãy nhớ CC ZZ0000ZZ (stable@vger.kernel.org).

Trong trường hợp bạn thực hiện chia đôi thành công, hãy thêm mọi người vào CC
  thông báo cam kết của thủ phạm đề cập đến các dòng bắt đầu bằng "Đã ký bởi:".

Khi CC để chuyển tiếp báo cáo của bạn tới danh sách, hãy cân nhắc việc nói trực tiếp với
Bot theo dõi hồi quy nhân Linux đã nói ở trên về báo cáo của bạn. để làm
đó, hãy đưa một đoạn như thế này vào thư của bạn::

#regzbot giới thiệu: v5.13..v5.14-rc1

Regzbot sau đó sẽ coi thư của bạn là một báo cáo về hồi quy được giới thiệu trong
phạm vi phiên bản được chỉ định. Trong trường hợp trên Linux v5.13 vẫn hoạt động tốt và Linux
v5.14-rc1 là phiên bản đầu tiên bạn gặp phải sự cố này. Nếu bạn
thực hiện phép chia đôi để tìm cam kết gây ra hồi quy, chỉ định
thay vào đó, id cam kết của thủ phạm ::

#regzbot giới thiệu: 1f2e3d4c5d

Việc đặt một "lệnh regzbot" như vậy có lợi cho bạn vì nó sẽ đảm bảo
báo cáo sẽ không lọt vào các vết nứt mà không được chú ý. Nếu bạn bỏ qua điều này, Linux
trình theo dõi hồi quy của kernel sẽ đảm nhiệm việc thông báo cho regzbot về
hồi quy, miễn là bạn gửi một bản sao đến danh sách gửi thư hồi quy. Nhưng
người theo dõi hồi quy chỉ là một con người đôi khi phải nghỉ ngơi hoặc thỉnh thoảng
thậm chí có thể tận hưởng một chút thời gian không sử dụng máy tính (điều đó nghe có vẻ điên rồ).
Việc trông cậy vào người này sẽ gây ra sự chậm trễ không cần thiết trước khi
hồi quy được đề cập đến ZZ0000ZZ và
báo cáo hồi quy hàng tuần được gửi bởi regzbot. Sự chậm trễ như vậy có thể dẫn đến Linus
Torvalds không biết về những hồi quy quan trọng khi quyết định giữa "tiếp tục"
phát triển hay gọi việc này là xong và phát hành bản cuối cùng?".

Có thực sự tất cả các hồi quy đều cố định?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Gần như tất cả đều như vậy, miễn là sự thay đổi gây ra sự hồi quy (sự
"thủ phạm cam kết") được xác định một cách đáng tin cậy. Một số hồi quy có thể được sửa mà không cần
điều này, nhưng nó thường được yêu cầu.

Ai cần tìm ra nguyên nhân gốc rễ của sự hồi quy?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Các nhà phát triển vùng mã bị ảnh hưởng nên cố gắng xác định thủ phạm trên
sở hữu. Nhưng đối với họ điều đó thường không thể thực hiện được nếu có nỗ lực hợp lý, vì khá
rất nhiều vấn đề chỉ xảy ra trong một môi trường cụ thể bên ngoài tầm kiểm soát của nhà phát triển
phạm vi tiếp cận -- ví dụ: một nền tảng phần cứng cụ thể, chương trình cơ sở, bản phân phối Linux,
cấu hình hoặc ứng dụng của hệ thống. Đó là lý do tại sao cuối cùng nó thường phụ thuộc vào
người báo cáo tìm ra thủ phạm phạm tội; đôi khi người dùng thậm chí có thể cần
chạy thử nghiệm bổ sung sau đó để xác định chính xác nguyên nhân gốc rễ. Nhà phát triển
nên đưa ra lời khuyên và trợ giúp hợp lý nếu có thể, để thực hiện quá trình này
tương đối dễ dàng và có thể đạt được đối với người dùng thông thường.

Làm thế nào tôi có thể tìm ra thủ phạm?
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Thực hiện chia đôi, như được phác thảo đại khái trong
Documentation/admin-guide/reporting-issues.rst và được mô tả chi tiết hơn bởi
Tài liệu/admin-guide/bug-bisect.rst. Nghe có vẻ như có rất nhiều công việc, nhưng
trong nhiều trường hợp tìm ra thủ phạm tương đối nhanh chóng. Nếu khó hoặc
tốn thời gian để tái tạo vấn đề một cách đáng tin cậy, hãy cân nhắc việc hợp tác với những người khác
người dùng bị ảnh hưởng để cùng nhau thu hẹp phạm vi tìm kiếm.

Tôi có thể xin lời khuyên từ ai khi nói đến sự hồi quy?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Gửi thư đến danh sách gửi thư hồi quy (regressions@lists.linux.dev) trong khi
CCing trình theo dõi hồi quy của nhân Linux (regressions@leemhuis.info); nếu
vấn đề có thể được giải quyết riêng tư tốt hơn, vui lòng bỏ qua danh sách.


Chi tiết bổ sung về hồi quy
------------------------------------


Mục tiêu của quy tắc "không hồi quy" là gì?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Người dùng nên yên tâm khi cập nhật phiên bản kernel và không phải lo lắng
một cái gì đó có thể bị phá vỡ. Đây là mối quan tâm của các nhà phát triển hạt nhân để thực hiện
cập nhật hấp dẫn: họ không muốn người dùng ở lại Linux ổn định hoặc lâu dài
loạt phim đã bị bỏ rơi hoặc đã hơn một năm rưỡi tuổi. Đó là
vì lợi ích của mọi người, như ZZ0000ZZ.
Ngoài ra, các nhà phát triển kernel muốn làm cho nó đơn giản và hấp dẫn đối với
người dùng thử nghiệm bản phát hành trước hoặc bản phát hành thông thường mới nhất. Đó cũng là trong
mọi người đều quan tâm, vì việc theo dõi và khắc phục sự cố sẽ dễ dàng hơn nhiều nếu
chúng được báo cáo ngay sau khi được giới thiệu.

Quy tắc "không hồi quy" có thực sự được tuân thủ trong thực tế không?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Nó được thực hiện thực sự nghiêm túc, như có thể thấy qua nhiều bài đăng trong danh sách gửi thư từ
Người sáng tạo Linux và nhà phát triển chính Linus Torvalds, một số trong đó được trích dẫn trong
Tài liệu/quy trình/xử lý-regressions.rst.

Các trường hợp ngoại lệ đối với quy tắc này là cực kỳ hiếm; trước đây các nhà phát triển hầu như luôn luôn
hóa ra là sai khi họ cho rằng một tình huống cụ thể nào đó là cần thiết
một ngoại lệ.

Ai đảm bảo quy tắc "không hồi quy" thực sự được tuân theo?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Những người bảo trì hệ thống con phải quan tâm đến vấn đề đó, được theo dõi và
được hỗ trợ bởi những người bảo trì cây -- ví dụ: Linus Torvalds cho tuyến chính và
Greg Kroah-Hartman và cộng sự. cho các chuỗi ổn định/dài hạn khác nhau.

Tất cả đều được giúp đỡ bởi những người đang cố gắng đảm bảo không có báo cáo hồi quy nào bị rơi
qua các vết nứt. Một trong số họ là Thorsten Leemhuis, người hiện đang đóng vai
"trình theo dõi hồi quy" của nhân Linux; để tạo điều kiện thuận lợi cho công việc này, anh ấy dựa vào
regzbot, bot theo dõi hồi quy nhân Linux. Chính vì vậy bạn muốn mang
báo cáo của bạn trên radar của những người này bằng cách gửi CC hoặc chuyển tiếp từng báo cáo tới
danh sách gửi thư hồi quy, lý tưởng nhất là có "lệnh regzbot" trong thư của bạn tới
theo dõi nó ngay lập tức.

Các hồi quy thường được cố định nhanh như thế nào?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Các nhà phát triển nên khắc phục mọi hồi quy được báo cáo càng nhanh càng tốt để cung cấp
ảnh hưởng đến người dùng bằng giải pháp kịp thời và ngăn chặn nhiều người dùng hơn
đang gặp vấn đề; tuy nhiên các nhà phát triển cần dành đủ thời gian và
cẩn thận để đảm bảo các bản sửa lỗi hồi quy không gây thêm thiệt hại.

Do đó, câu trả lời phụ thuộc vào nhiều yếu tố khác nhau như tác động của hồi quy,
tuổi hoặc dòng Linux nơi nó xuất hiện. Tuy nhiên, cuối cùng, hầu hết các hồi quy
phải được khắc phục trong vòng hai tuần.

Đây có phải là sự hồi quy nếu vấn đề có thể tránh được bằng cách cập nhật một số phần mềm?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Hầu như luôn luôn: có. Nếu nhà phát triển nói với bạn cách khác, hãy hỏi hồi quy
theo dõi để được tư vấn như đã nêu ở trên.

Đây có phải là sự hồi quy nếu kernel mới hoạt động chậm hơn hoặc tiêu tốn nhiều năng lượng hơn?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Có, nhưng sự khác biệt phải đáng kể. Chậm lại năm phần trăm trong một
do đó, điểm chuẩn vi mô khó có thể được coi là hồi quy, trừ khi nó cũng
ảnh hưởng đến kết quả của một tiêu chuẩn rộng hơn một phần trăm. Nếu ở
nghi ngờ, xin lời khuyên.

Đây có phải là sự hồi quy nếu mô-đun hạt nhân bên ngoài bị hỏng khi cập nhật Linux?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Không, vì quy tắc "không hồi quy" là về giao diện và dịch vụ của Linux
kernel cung cấp cho vùng người dùng. Do đó nó không bao gồm việc xây dựng hoặc vận hành
các mô-đun hạt nhân được phát triển bên ngoài, khi chúng chạy trong không gian hạt nhân và nối vào
kernel sử dụng giao diện bên trong đôi khi bị thay đổi.

Các trường hợp hồi quy do sửa lỗi bảo mật được xử lý như thế nào?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Trong những trường hợp cực kỳ hiếm gặp, vấn đề bảo mật không thể được khắc phục mà không gây ra
hồi quy; những sửa chữa đó đã được nhường chỗ, vì cuối cùng chúng là những điều ít xấu xa hơn.
May mắn thay, điều này hầu như luôn có thể tránh được, với tư cách là nhà phát triển chủ chốt của
khu vực bị ảnh hưởng và bản thân Linus Torvalds thường rất cố gắng để khắc phục vấn đề bảo mật
vấn đề mà không gây ra sự hồi quy.

Tuy nhiên, nếu bạn gặp phải trường hợp như vậy, hãy kiểm tra kho lưu trữ danh sách gửi thư nếu mọi người
đã cố gắng hết sức để tránh sự hồi quy. Nếu không, hãy báo cáo; nếu nghi ngờ, hãy hỏi
để được tư vấn như đã nêu ở trên.

Điều gì sẽ xảy ra nếu việc sửa lỗi hồi quy là không thể mà không gây ra lỗi khác?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Đáng buồn là những điều này vẫn xảy ra, nhưng may mắn thay là không thường xuyên; nếu chúng xảy ra, chuyên gia
nhà phát triển vùng mã bị ảnh hưởng nên xem xét vấn đề để tìm cách khắc phục
tránh được sự hồi quy hoặc ít nhất là tác động của chúng. Nếu bạn gặp phải trường hợp như vậy
tình huống, hãy làm những gì đã được vạch ra đối với các trường hợp hồi quy do bảo mật gây ra
cách khắc phục: kiểm tra các cuộc thảo luận trước đó nếu mọi người đã cố gắng hết sức và yêu cầu
lời khuyên nếu nghi ngờ.

Một lưu ý nhanh khi thực hiện: những tình huống này có thể tránh được nếu mọi người chịu
thường xuyên cung cấp các bản phát hành trước cho dòng chính (giả sử v5.15-rc1 hoặc -rc3) từ mỗi
chu kỳ phát triển chạy thử nghiệm. Điều này được giải thích tốt nhất bằng cách tưởng tượng một sự thay đổi
được tích hợp giữa Linux v5.14 và v5.15-rc1 gây ra hiện tượng hồi quy, nhưng tại
đồng thời là một yêu cầu khó khăn đối với một số cải tiến khác được áp dụng cho
5.15-rc1. Tất cả những thay đổi này thường có thể được hoàn nguyên một cách đơn giản và do đó quá trình hồi quy
đã được giải quyết, nếu ai đó tìm thấy và báo cáo nó trước khi bản 5.15 được phát hành. Một vài ngày hoặc
vài tuần sau, giải pháp này có thể trở nên bất khả thi vì một số phần mềm có thể có
bắt đầu dựa vào các khía cạnh được giới thiệu bởi một trong những thay đổi tiếp theo: hoàn nguyên
tất cả các thay đổi sau đó sẽ gây ra sự thoái lui đối với người dùng phần mềm nói trên và do đó
không còn nghi ngờ gì nữa.

Đây có phải là sự hồi quy nếu một số tính năng tôi dựa vào đã bị xóa vài tháng trước?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Đúng vậy, nhưng thường rất khó để khắc phục những sự hồi quy như vậy do các khía cạnh đã nêu
ở phần trước. Vì vậy cần phải xử lý theo từng trường hợp
cơ sở. Đây là một lý do khác tại sao mọi người đều quan tâm đến việc kiểm tra thường xuyên
bản phát hành trước của dòng chính.

Quy tắc "không hồi quy" có được áp dụng nếu tôi dường như là người duy nhất bị ảnh hưởng không?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Đúng vậy, nhưng chỉ dành cho mục đích sử dụng thực tế: các nhà phát triển Linux muốn được tự do
loại bỏ hỗ trợ cho phần cứng chỉ được tìm thấy trong gác mái và viện bảo tàng nữa.

Lưu ý, đôi khi không thể tránh khỏi sự hồi quy để đạt được tiến bộ - và điều sau đó
là cần thiết để ngăn chặn Linux khỏi tình trạng trì trệ. Do đó, nếu chỉ có rất ít người dùng dường như
bị ảnh hưởng bởi sự hồi quy, điều đó có thể mang lại lợi ích lớn hơn cho họ và
sự quan tâm của mọi người khác đối với việc để mọi thứ trôi qua. Đặc biệt nếu có một
cách dễ dàng để tránh sự hồi quy bằng cách nào đó, ví dụ bằng cách cập nhật một số
phần mềm hoặc sử dụng tham số kernel được tạo chỉ cho mục đích này.

Quy tắc hồi quy có áp dụng cho mã trong cây phân tầng không?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Không theo ZZ0000ZZ,
mà ngay từ những ngày đầu đã nêu::

Xin lưu ý rằng các trình điều khiển này đang được phát triển mạnh mẽ, có thể hoặc
       có thể không hoạt động và có thể chứa các giao diện không gian người dùng rất có thể
       sẽ được thay đổi trong thời gian sắp tới.

Tuy nhiên, các nhà phát triển dàn dựng thường tuân thủ quy tắc "không hồi quy",
nhưng đôi khi uốn cong nó để đạt được tiến bộ. Đó là ví dụ tại sao một số người dùng phải
xử lý các hồi quy (thường không đáng kể) khi trình điều khiển WiFi từ dàn
cây đã được thay thế bằng một cây hoàn toàn khác được viết từ đầu.

Tại sao các phiên bản sau này phải được "biên dịch với cấu hình tương tự"?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Bởi vì các nhà phát triển nhân Linux đôi khi tích hợp những thay đổi được biết là gây ra
hồi quy, nhưng đặt chúng là tùy chọn và vô hiệu hóa chúng trong cài đặt mặc định của kernel
cấu hình. Thủ thuật này cho phép tiến bộ, như quy tắc "không hồi quy"
nếu không sẽ dẫn đến trì trệ.

Ví dụ, hãy xem xét một tính năng bảo mật mới chặn quyền truy cập vào một số kernel
các giao diện thường bị phần mềm độc hại lạm dụng, đồng thời được yêu cầu chạy một
ít ứng dụng ít được sử dụng. Cách tiếp cận được vạch ra khiến cả hai phe đều hài lòng:
những người sử dụng các ứng dụng này có thể tắt tính năng bảo mật mới, đồng thời
mọi người khác có thể kích hoạt nó mà không gặp rắc rối.

Làm cách nào để tạo cấu hình tương tự như cấu hình của kernel cũ hơn?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Khởi động máy của bạn với kernel nổi tiếng và định cấu hình Linux mới hơn
phiên bản với ZZ0000ZZ. Điều này làm cho các tập lệnh xây dựng của kernel được chọn
thiết lập tệp cấu hình (tệp ".config") từ kernel đang chạy làm cơ sở
đối với cái mới bạn sắp biên dịch; sau đó họ thiết lập tất cả mới
tùy chọn cấu hình về giá trị mặc định của chúng, điều này sẽ vô hiệu hóa các tính năng mới
điều đó có thể gây ra sự hồi quy.

Tôi có thể báo cáo hồi quy mà tôi tìm thấy bằng hạt vani được biên dịch trước không?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Bạn cần đảm bảo kernel mới hơn được biên dịch với cấu hình tương tự
tập tin cũ hơn (xem ở trên), vì những tập tin tạo ra chúng có thể đã kích hoạt
một số tính năng được biết là không tương thích với kernel mới hơn. Nếu nghi ngờ, hãy báo cáo
vấn đề với nhà cung cấp kernel và xin lời khuyên.


Tìm hiểu thêm về theo dõi hồi quy với "regzbot"
---------------------------------------------

Theo dõi hồi quy là gì và tại sao tôi nên quan tâm đến nó?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Các quy tắc như "không hồi quy" cần có người đảm bảo chúng được tuân thủ, nếu không thì
chúng bị hỏng vô tình hoặc cố ý. Lịch sử đã chứng minh điều này
cũng đúng cho việc phát triển nhân Linux. Đó là lý do tại sao Thorsten Leemhuis,
Trình theo dõi hồi quy của Linux Kernel và một số người cố gắng đảm bảo tất cả hồi quy
được khắc phục bằng cách theo dõi chúng cho đến khi chúng được giải quyết. Cả hai đều không
được trả tiền cho việc này, đó là lý do tại sao công việc được thực hiện trên cơ sở nỗ lực cao nhất.

Tại sao và làm thế nào các hồi quy nhân Linux được theo dõi bằng bot?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Việc theo dõi hồi quy hoàn toàn thủ công đã được chứng minh là khá khó khăn do
bản chất phân tán và có cấu trúc lỏng lẻo của quá trình phát triển nhân Linux.
Đó là lý do tại sao trình theo dõi hồi quy của nhân Linux đã phát triển regzbot để hỗ trợ
công việc, với mục tiêu dài hạn là tự động hóa việc theo dõi hồi quy càng nhiều càng tốt
có thể cho tất cả mọi người tham gia.

Regzbot hoạt động bằng cách theo dõi phản hồi cho các báo cáo về hồi quy được theo dõi.
Ngoài ra, nó đang tìm kiếm các bản vá đã đăng hoặc đã cam kết tham chiếu đến các bản vá đó
báo cáo có thẻ "Liên kết:"; các câu trả lời cho các bài đăng bản vá như vậy cũng được theo dõi.
Kết hợp dữ liệu này cung cấp những hiểu biết sâu sắc về trạng thái sửa lỗi hiện tại
quá trình.

Làm cách nào để xem hiện tại các bản nhạc regzbot hồi quy nào?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Hãy kiểm tra ZZ0000ZZ.

Những loại vấn đề nào được cho là sẽ được theo dõi bởi regzbot?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Bot này có nhiệm vụ theo dõi quá trình hồi quy, do đó vui lòng không sử dụng regzbot để
các vấn đề thường xuyên. Nhưng trình theo dõi hồi quy của nhân Linux sẽ không sao nếu bạn
liên quan đến regzbot để theo dõi các vấn đề nghiêm trọng, như báo cáo về việc bị treo, bị hỏng
dữ liệu hoặc lỗi nội bộ (Panic, Oops, BUG(), cảnh báo, ...).

Làm cách nào để thay đổi các khía cạnh của hồi quy được theo dõi?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Bằng cách sử dụng 'lệnh regzbot' để trả lời trực tiếp hoặc gián tiếp thư có
báo cáo. Cách dễ nhất để làm điều đó: tìm báo cáo trong thư mục "Đã gửi" hoặc thư mục
lưu trữ danh sách gửi thư và trả lời nó bằng chức năng "Trả lời tất cả" của người gửi thư.
Trong thư đó, hãy sử dụng một trong các lệnh sau trong một đoạn độc lập (IOW:
sử dụng các dòng trống để tách một hoặc nhiều lệnh này khỏi phần còn lại của
văn bản của thư).

* Cập nhật khi quá trình hồi quy bắt đầu xảy ra, ví dụ sau khi thực hiện một
   chia đôi::

#regzbot giới thiệu: 1f2e3d4c5d

* Đặt hoặc cập nhật tiêu đề::

Tiêu đề #regzbot: foo

* Giám sát một cuộc thảo luận hoặc phiếu bugzilla.kernel.org nơi bổ sung các khía cạnh của
   vấn đề hoặc cách khắc phục sẽ được thảo luận:::

Màn hình #regzbot: ZZ0000ZZ
       Màn hình #regzbot: ZZ0001ZZ

* Chỉ vào một địa điểm có thêm chi tiết quan tâm, chẳng hạn như bài đăng trong danh sách gửi thư
   hoặc một phiếu trong trình theo dõi lỗi có liên quan đôi chút nhưng về một vấn đề khác
   chủ đề::

Liên kết #regzbot: ZZ0000ZZ

* Đánh dấu hồi quy là không hợp lệ::

#regzbot không hợp lệ: không phải là hồi quy, vấn đề luôn tồn tại

Regzbot hỗ trợ một số lệnh khác chủ yếu được các nhà phát triển hoặc mọi người sử dụng
theo dõi hồi quy. Họ và nhiều thông tin chi tiết hơn về regzbot đã nói ở trên
các lệnh có thể được tìm thấy trong ZZ0000ZZ và
ZZ0001ZZ
cho regzbot.

..
   end-of-content
..
   This text is available under GPL-2.0+ or CC-BY-4.0, as stated at the top
   of the file. If you want to distribute this text under CC-BY-4.0 only,
   please use "The Linux kernel developers" for author attribution and link
   this as source:
   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/plain/Documentation/admin-guide/reporting-regressions.rst
..
   Note: Only the content of this RST file as found in the Linux kernel sources
   is available under CC-BY-4.0, as versions of this text that were processed
   (for example by the kernel's build system) might contain content taken from
   files which use a more restrictive license.