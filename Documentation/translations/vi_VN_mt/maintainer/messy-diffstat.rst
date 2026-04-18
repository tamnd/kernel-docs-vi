.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/maintainer/messy-diffstat.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================================
Xử lý các khác biệt về yêu cầu kéo lộn xộn
==========================================

Người bảo trì hệ thống con thường xuyên sử dụng ZZ0000ZZ như một phần của
quá trình gửi công việc ngược dòng.  Thông thường, kết quả bao gồm một
diffstat hiển thị những tập tin nào sẽ được chạm vào và số lượng mỗi tập tin sẽ được chạm vào.
được thay đổi.  Tuy nhiên, đôi khi, một kho lưu trữ có kích thước tương đối
lịch sử phát triển phức tạp sẽ mang lại một sự khác biệt lớn chứa đựng một
rất nhiều công việc không liên quan.  Kết quả trông xấu xí và che khuất những gì
yêu cầu kéo thực sự đang được thực hiện.  Tài liệu này mô tả những gì đang xảy ra
và cách khắc phục mọi thứ; nó có nguồn gốc từ Trí tuệ của Linus Torvalds,
được tìm thấy trong Linus1_ và Linus2_.

.. _Linus1: https://lore.kernel.org/lkml/CAHk-=wg3wXH2JNxkQi+eLZkpuxqV+wPiHhw_Jf7ViH33Sw7PHA@mail.gmail.com/
.. _Linus2: https://lore.kernel.org/lkml/CAHk-=wgXbSa8yq8Dht8at+gxb_idnJ7X5qWZQWRBN4_CUPr=eQ@mail.gmail.com/

Lịch sử phát triển Git diễn ra dưới dạng một loạt các cam kết.  Một cách đơn giản
Theo cách này, quá trình phát triển hạt nhân dòng chính trông như thế này::

  ... vM --- vN-rc1 --- vN-rc2 --- vN-rc3 --- ... --- vN-rc7 --- vN

Nếu muốn xem điều gì đã thay đổi giữa hai điểm, một lệnh như
điều này sẽ thực hiện công việc::

$ git diff --stat --tóm tắt vN-rc2..vN-rc3

Ở đây, có hai điểm rõ ràng trong lịch sử; Về cơ bản, Git sẽ
"trừ" điểm đầu khỏi điểm cuối và hiển thị kết quả
sự khác biệt.  Thao tác được yêu cầu là rõ ràng và đủ dễ dàng để
hiểu.

Khi người bảo trì hệ thống con tạo một nhánh và cam kết các thay đổi với nó,
kết quả trong trường hợp đơn giản nhất là một lịch sử trông giống như ::

  ... vM --- vN-rc1 --- vN-rc2 --- vN-rc3 --- ... --- vN-rc7 --- vN
                          |
                          +-- c1 --- c2 --- ... --- cN

Nếu người bảo trì đó bây giờ sử dụng ZZ0000ZZ để xem điều gì đã thay đổi giữa
nhánh chính (hãy gọi nó là "linus") và cN, vẫn còn hai
điểm cuối rõ ràng và kết quả như mong đợi.  Vì vậy, một yêu cầu kéo
được tạo bằng ZZ0001ZZ cũng sẽ như mong đợi.  Nhưng bây giờ
xem xét lịch sử phát triển phức tạp hơn một chút ::

  ... vM --- vN-rc1 --- vN-rc2 --- vN-rc3 --- ... --- vN-rc7 --- vN
                |         |
                |         +-- c1 --- c2 --- ... --- cN
                |                   /
                +-- x1 --- x2 --- x3

Người bảo trì của chúng tôi đã tạo một nhánh tại vN-rc1 và một nhánh khác tại vN-rc2; cái
hai sau đó đã được hợp nhất thành c2.  Bây giờ một yêu cầu kéo đã được tạo
đối với cN thực sự có thể trở nên lộn xộn và các nhà phát triển thường băn khoăn
tại sao.

Điều đang xảy ra ở đây là không còn hai điểm kết thúc rõ ràng cho
thao tác ZZ0000ZZ để sử dụng.  Sự phát triển lên đến đỉnh điểm ở cN
bắt đầu ở hai nơi khác nhau; để tạo ra sự khác biệt, ZZ0001ZZ
cuối cùng phải chọn một trong số họ và hy vọng điều tốt nhất.  Nếu sự khác biệt
bắt đầu tại vN-rc1, nó có thể bao gồm tất cả những thay đổi giữa đó
và điểm cuối gốc thứ hai (vN-rc2), đây chắc chắn không phải là điểm cuối của chúng tôi
người bảo trì đã có trong tâm trí.  Với tất cả những thứ rác rưởi đó trong bộ khuếch tán, nó
có thể không thể biết được điều gì thực sự đã xảy ra trong những thay đổi dẫn đến
tới cN.

Những người bảo trì thường cố gắng giải quyết vấn đề này bằng cách, ví dụ, khởi động lại
nhánh hoặc thực hiện việc hợp nhất khác với nhánh Linus, sau đó tạo lại
yêu cầu kéo.  Cách tiếp cận này có xu hướng không dẫn đến niềm vui khi nhận được
kết thúc yêu cầu kéo đó; khởi động lại và/hoặc hợp nhất ngay trước khi đẩy
ngược dòng là một cách nổi tiếng để nhận được phản hồi gắt gỏng.

Vậy phải làm gì?  Phản ứng tốt nhất khi đối mặt với điều này
tình huống thực sự là phải hợp nhất với chi nhánh mà bạn dự định làm việc
bị lôi kéo vào, nhưng phải làm việc đó một cách riêng tư, như thể đó là nguồn gốc của
xấu hổ.  Tạo một nhánh mới, bỏ đi và thực hiện hợp nhất ở đó ::

  ... vM --- vN-rc1 --- vN-rc2 --- vN-rc3 --- ... --- vN-rc7 --- vN
                |         |                                      |
                |         +-- c1 --- c2 --- ... --- cN           |
                |                   /               |            |
                +-- x1 --- x2 --- x3                +------------+-- TEMP

Hoạt động hợp nhất giải quyết tất cả các vấn đề phức tạp do
nhiều điểm bắt đầu, mang lại một kết quả mạch lạc chỉ chứa
sự khác biệt so với nhánh chính.  Bây giờ nó sẽ có thể
tạo một diffstat với thông tin mong muốn ::

$ git diff -C --stat --tóm tắt linus..TEMP

Lưu kết quả đầu ra từ lệnh này, sau đó chỉ cần xóa nhánh TEMP;
nhất định không được đưa nó ra thế giới bên ngoài.  Lấy sự khác biệt đã lưu
xuất ra và chỉnh sửa nó thành yêu cầu kéo lộn xộn, mang lại kết quả là
cho thấy những gì đang thực sự xảy ra  Yêu cầu đó sau đó có thể được gửi ngược dòng.