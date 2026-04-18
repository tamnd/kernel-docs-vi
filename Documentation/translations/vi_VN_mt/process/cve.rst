.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/cve.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====
CVE
====

Các số liệu về Lỗ hổng và Mức độ phơi nhiễm phổ biến (CVE®) đã được phát triển dưới dạng
cách rõ ràng để xác định, xác định và lập danh mục được công bố công khai
lỗ hổng bảo mật.  Theo thời gian, tính hữu dụng của chúng đã giảm dần theo thời gian.
liên quan đến dự án hạt nhân và số CVE thường được chỉ định
theo những cách không phù hợp và vì những lý do không phù hợp.  Vì điều này,
cộng đồng phát triển hạt nhân có xu hướng tránh chúng.  Tuy nhiên,
sự kết hợp của áp lực liên tục để chỉ định CVE và các hình thức khác của
số nhận dạng bảo mật và các hành vi lạm dụng đang diễn ra của các cá nhân và công ty
bên ngoài cộng đồng kernel đã nói rõ rằng kernel
cộng đồng nên có quyền kiểm soát những nhiệm vụ đó.

Nhóm phát triển nhân Linux có khả năng gán CVE cho
các vấn đề bảo mật nhân Linux tiềm ẩn.  Nhiệm vụ này là độc lập
của ZZ0000ZZ.

Có thể tìm thấy danh sách tất cả các CVE được gán cho nhân Linux trong
kho lưu trữ danh sách gửi thư linux-cve, như đã thấy trên
ZZ0001ZZ Để nhận thông báo về
các CVE được chỉ định, vui lòng ZZ0000ZZ vào danh sách gửi thư đó.

Quá trình
=======

Là một phần của quá trình phát hành ổn định thông thường, các thay đổi kernel được
các vấn đề bảo mật tiềm ẩn được xác định bởi các nhà phát triển chịu trách nhiệm
để gán số CVE và tự động gán số CVE
cho họ.  Các bài tập này được xuất bản trên linux-cve-announce
danh sách gửi thư dưới dạng thông báo một cách thường xuyên.

Lưu ý, do lớp mà nhân Linux nằm trong hệ thống, hầu như
bất kỳ lỗi nào cũng có thể bị khai thác để xâm phạm tính bảo mật của kernel,
nhưng khả năng khai thác thường không rõ ràng khi lỗi được
đã sửa.  Vì điều này mà nhóm phân công CVE quá thận trọng và
gán số CVE cho bất kỳ lỗi nào mà chúng xác định được.  Cái này
giải thích số lượng lớn CVE được phát hành bởi Linux
đội hạt nhân.

Nếu nhóm phân công CVE bỏ lỡ một bản sửa lỗi cụ thể mà bất kỳ người dùng nào cũng cảm thấy
nên được gán CVE cho nó, vui lòng gửi email cho họ theo địa chỉ <cve@kernel.org>
và nhóm ở đó sẽ làm việc với bạn về vấn đề đó.  Lưu ý rằng không có tiềm năng
vấn đề bảo mật nên được gửi tới bí danh này, đó là ONLY để chuyển nhượng
của CVE cho các bản sửa lỗi đã có trong cây nhân được phát hành.  Nếu bạn
cảm thấy bạn đã tìm thấy một vấn đề bảo mật chưa được khắc phục, vui lòng làm theo
ZZ0000ZZ.

Sẽ không có CVE nào được tự động gán cho các vấn đề bảo mật chưa được khắc phục trong
nhân Linux; việc chuyển nhượng sẽ chỉ tự động diễn ra sau khi sửa lỗi
có sẵn và được áp dụng cho cây nhân ổn định và nó sẽ được theo dõi
theo cách đó bằng id cam kết git của bản sửa lỗi ban đầu.  Nếu có ai mong muốn
vui lòng chỉ định CVE trước khi vấn đề được giải quyết bằng một cam kết
hãy liên hệ với nhóm phân công kernel CVE tại <cve@kernel.org> để nhận được
mã định danh được chỉ định từ lô mã định danh dành riêng của chúng.

Sẽ không có CVE nào được chỉ định cho bất kỳ vấn đề nào được tìm thấy trong phiên bản kernel
hiện không được hạt nhân Stable/LTS hỗ trợ tích cực
đội.  Có thể tìm thấy danh sách các nhánh kernel hiện được hỗ trợ tại
ZZ0000ZZ

Tranh chấp CVE được giao
=========================

Quyền tranh chấp hoặc sửa đổi CVE được chỉ định cho một hạt nhân cụ thể
thay đổi chỉ thuộc về những người duy trì hệ thống con có liên quan
bị ảnh hưởng.  Nguyên tắc này đảm bảo độ chính xác cao và
trách nhiệm giải trình trong việc báo cáo tình trạng dễ bị tổn thương.  Chỉ những cá nhân có
chuyên môn sâu và kiến thức sâu sắc về hệ thống con có thể
đánh giá tính hợp lệ và phạm vi của lỗ hổng được báo cáo và xác định
ký hiệu CVE thích hợp của nó.  Bất kỳ nỗ lực sửa đổi hoặc tranh chấp CVE
ngoài thẩm quyền được chỉ định này có thể dẫn đến nhầm lẫn, không chính xác
báo cáo và cuối cùng là các hệ thống bị xâm nhập.

CVE không hợp lệ
============

Nếu tìm thấy sự cố bảo mật trong nhân Linux chỉ được hỗ trợ bởi
một bản phân phối Linux do những thay đổi đã được thực hiện bởi bản phân phối đó
phân phối hoặc do phân phối hỗ trợ phiên bản kernel
đó không còn là một trong những bản phát hành được kernel.org hỗ trợ nữa mà là CVE
nhóm CVE nhân Linux không thể chỉ định và phải được yêu cầu
từ chính bản phân phối Linux đó.

Bất kỳ CVE nào được gán cho nhân Linux để hoạt động tích cực
phiên bản kernel được hỗ trợ, bởi bất kỳ nhóm nào khác ngoài việc gán kernel
Nhóm CVE không được coi là CVE hợp lệ.  Hãy thông báo cho
nhóm phân công kernel CVE tại <cve@kernel.org> để họ có thể làm việc
vô hiệu hóa các mục nhập đó thông qua quy trình khắc phục CNA.

Khả năng ứng dụng của CVE cụ thể
==============================

Vì nhân Linux có thể được sử dụng theo nhiều cách khác nhau, với nhiều
những cách khác nhau để người dùng bên ngoài truy cập vào nó hoặc không có quyền truy cập nào cả,
khả năng ứng dụng của bất kỳ CVE cụ thể nào là tùy thuộc vào người dùng Linux
xác định, việc đó không phụ thuộc vào nhóm phân công CVE.  Làm ơn đừng
liên hệ với chúng tôi để cố gắng xác định khả năng áp dụng của bất kỳ biện pháp cụ thể nào
CVE.

Ngoài ra, vì cây nguồn quá lớn và bất kỳ một hệ thống nào cũng chỉ sử dụng một
tập hợp con nhỏ của cây nguồn, bất kỳ người dùng Linux nào cũng nên biết rằng
số lượng lớn CVE được chỉ định không phù hợp với hệ thống của họ.

Tóm lại, chúng tôi không biết trường hợp sử dụng của bạn và chúng tôi không biết phần nào
của kernel mà bạn sử dụng, vì vậy không có cách nào để chúng tôi xác định liệu có
CVE cụ thể phù hợp với hệ thống của bạn.

Như mọi khi, tốt nhất là nên lấy tất cả các thay đổi kernel đã phát hành, vì chúng là
được thử nghiệm cùng nhau trong một tổng thể thống nhất bởi nhiều thành viên cộng đồng chứ không phải như
những thay đổi do anh đào chọn.  Cũng lưu ý rằng đối với nhiều lỗi,
giải pháp cho vấn đề tổng thể không được tìm thấy trong một sự thay đổi duy nhất mà bằng
tổng của nhiều bản sửa lỗi chồng lên nhau.  Lý tưởng nhất là CVE sẽ
được giao cho tất cả các bản sửa lỗi cho mọi vấn đề, nhưng đôi khi chúng tôi sẽ không thực hiện được
thông báo sửa lỗi, do đó giả sử rằng một số thay đổi không được gán CVE
có thể có liên quan để thực hiện.

