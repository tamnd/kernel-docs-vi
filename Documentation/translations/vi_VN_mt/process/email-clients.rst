.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/email-clients.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _email_clients:

Thông tin ứng dụng khách email cho Linux
========================================

Git
---

Ngày nay hầu hết các nhà phát triển đều sử dụng ZZ0000ZZ thay vì thông thường
khách hàng email.  Trang hướng dẫn này khá tốt.  Vào ngày nhận
cuối cùng, người bảo trì sử dụng ZZ0001ZZ để áp dụng các bản vá.

Nếu bạn chưa quen với ZZ0000ZZ thì hãy gửi bản vá đầu tiên cho chính bạn.  Lưu nó
dưới dạng văn bản thô bao gồm tất cả các tiêu đề.  Chạy ZZ0001ZZ và
sau đó xem lại nhật ký thay đổi với ZZ0002ZZ.  Khi nó hoạt động thì gửi
bản vá vào (các) danh sách gửi thư thích hợp.

Sở thích chung
-------------------

Các bản vá cho nhân Linux được gửi qua email, tốt nhất là dưới dạng
văn bản nội tuyến trong nội dung của email.  Một số người bảo trì chấp nhận
tệp đính kèm, nhưng tệp đính kèm phải có loại nội dung
ZZ0000ZZ.  Tuy nhiên, các tệp đính kèm thường không được tán thành vì
nó làm cho việc trích dẫn các phần của bản vá trở nên khó khăn hơn trong bản vá
quá trình xem xét.

Chúng tôi cũng khuyên bạn nên sử dụng văn bản thuần túy trong nội dung email của mình,
cho các bản vá và các email khác. ZZ0000ZZ có thể hữu ích
để biết thông tin về cách định cấu hình ứng dụng email khách ưa thích của bạn, cũng như
liệt kê các ứng dụng email được đề xuất nếu bạn chưa có tùy chọn.

Ứng dụng email khách được sử dụng cho các bản vá nhân Linux phải gửi
văn bản vá không bị ảnh hưởng.  Ví dụ: họ không nên sửa đổi hoặc xóa các tab
hoặc khoảng trắng, thậm chí ở đầu hoặc cuối dòng.

Không gửi bản vá bằng ZZ0000ZZ.  Điều này có thể gây ra bất ngờ
và ngắt dòng không mong muốn.

Đừng để ứng dụng email của bạn tự động gói từ cho bạn.
Điều này cũng có thể làm hỏng bản vá của bạn.

Ứng dụng email khách không nên sửa đổi mã hóa bộ ký tự của văn bản.
Các bản vá được gửi qua email chỉ được ở dạng mã hóa ASCII hoặc UTF-8.
Nếu bạn định cấu hình ứng dụng email khách của mình để gửi email có mã hóa UTF-8,
bạn tránh được một số vấn đề về bộ ký tự có thể xảy ra.

Ứng dụng email khách phải tạo và duy trì "Tham khảo:" hoặc "Trả lời tới:"
tiêu đề để luồng thư không bị hỏng.

Sao chép và dán (hoặc cắt và dán) thường không hoạt động đối với các bản vá
vì các tab được chuyển đổi thành dấu cách.  Sử dụng xclipboard, xclip và/hoặc
xcutsel có thể hoạt động, nhưng tốt nhất bạn nên tự mình kiểm tra điều này hoặc tránh
sao chép và dán.

Không sử dụng chữ ký PGP/GPG trong thư có chứa các bản vá.
Điều này phá vỡ nhiều tập lệnh đọc và áp dụng các bản vá.
(Điều này có thể khắc phục được.)

Bạn nên gửi bản vá cho chính mình, lưu tin nhắn đã nhận,
và áp dụng thành công nó bằng 'patch' trước khi gửi bản vá tới Linux
danh sách gửi thư.


Một số gợi ý về ứng dụng email (MUA)
------------------------------------

Dưới đây là một số gợi ý cấu hình MUA cụ thể để chỉnh sửa và gửi
các bản vá cho nhân Linux.  Những điều này không có nghĩa là phải hoàn thành
tóm tắt cấu hình gói phần mềm.


Huyền thoại:

- TUI = giao diện người dùng dựa trên văn bản
- GUI = giao diện người dùng đồ họa

Núi cao (TUI)
*************

Tùy chọn cấu hình:

Trong phần ZZ0000ZZ:

- ZZ0000ZZ phải là ZZ0002ZZ
- ZZ0001ZZ phải là ZZ0003ZZ

Khi soạn tin nhắn, con trỏ phải được đặt ở vị trí của bản vá.
sẽ xuất hiện, sau đó nhấn ZZ0000ZZ để bạn chỉ định tệp vá
để chèn vào tin nhắn.

Thư có móng vuốt (GUI)
**********************

Hoạt động. Một số người sử dụng thành công điều này cho các bản vá lỗi.

Để chèn một bản vá, hãy sử dụng ZZ0000ZZ (ZZ0001ZZ)
hoặc một trình soạn thảo bên ngoài.

Nếu bản vá được chèn phải được chỉnh sửa trong cửa sổ thành phần Claws
"Tự động gói" trong
ZZ0000ZZ nên
bị vô hiệu hóa.

Tiến hóa (GUI)
***************

Một số người sử dụng thành công điều này cho các bản vá lỗi.

Khi soạn thư chọn: Preformat
  từ ZZ0000ZZ (ZZ0001ZZ)
  hoặc thanh công cụ

Sau đó sử dụng:
ZZ0000ZZ (ZZ0001ZZ)
để chèn bản vá.

Bạn cũng có thể ZZ0001ZZ, chọn
ZZ0000ZZ, sau đó dán bằng nút giữa.

Kmail (GUI)
***********

Một số người sử dụng Kmail thành công cho các bản vá lỗi.

Cài đặt mặc định không soạn thảo trong HTML là phù hợp; không
kích hoạt nó.

Khi soạn email, trong tùy chọn, bỏ chọn "word Wrap". duy nhất
nhược điểm là bất kỳ văn bản nào bạn nhập vào email sẽ không được gói gọn trong từng từ
vì vậy bạn sẽ phải ngắt dòng văn bản theo cách thủ công trước khi vá lỗi. Dễ nhất
Cách giải quyết vấn đề này là soạn email của bạn với tính năng ngắt từ, sau đó lưu
nó như một bản nháp. Một khi bạn kéo nó lên lại từ bản nháp của mình thì bây giờ thật khó
word-wrapped và bạn có thể bỏ chọn "word Wrapped" mà không làm mất từ hiện có
gói.

Ở cuối email của bạn, hãy đặt dấu phân cách bản vá thường được sử dụng trước
chèn bản vá của bạn: ba dấu gạch ngang (ZZ0000ZZ).

Sau đó từ mục menu ZZ0000ZZ, chọn
ZZ0001ZZ và chọn bản vá của bạn.
Là một phần thưởng bổ sung, bạn có thể tùy chỉnh menu thanh công cụ tạo tin nhắn
và đặt biểu tượng ZZ0002ZZ vào đó.

Làm cho cửa sổ soạn thảo đủ rộng để không có đường kẻ nào bị ngắt quãng. Kể từ
KMail 1.13.5 (KDE 4.5.4), KMail sẽ áp dụng gói từ khi gửi
email nếu các dòng ngắt dòng trong cửa sổ soạn thảo. Có gói từ
bị tắt trong menu Tùy chọn là không đủ. Vì vậy, nếu bản vá của bạn có rất
dài dòng, bạn phải làm cho cửa sổ soạn thảo thật rộng trước khi gửi
email. Xem: ZZ0000ZZ

Bạn có thể ký các tệp đính kèm GPG một cách an toàn, nhưng văn bản nội tuyến được ưu tiên cho
các bản vá vì vậy đừng GPG ký chúng.  Ký các bản vá đã được chèn
vì văn bản được nội tuyến sẽ khiến chúng khó trích xuất từ mã hóa 7 bit của chúng.

Nếu bạn nhất định phải gửi các bản vá dưới dạng tệp đính kèm thay vì nội tuyến
chúng dưới dạng văn bản, nhấp chuột phải vào tệp đính kèm và chọn ZZ0000ZZ,
và tô sáng ZZ0001ZZ để đính kèm
được nội tuyến để làm cho nó dễ xem hơn.

Khi lưu các bản vá được gửi dưới dạng văn bản nội tuyến, hãy chọn email
chứa bản vá từ khung danh sách tin nhắn, nhấp chuột phải và chọn
ZZ0000ZZ.  Bạn có thể sử dụng toàn bộ email chưa sửa đổi làm bản vá
nếu nó được sáng tác đúng cách.  Email chỉ được lưu dưới dạng đọc-ghi cho người dùng
bạn sẽ phải chỉnh sửa chúng để làm cho chúng có thể đọc được theo nhóm và trên thế giới nếu bạn sao chép
chúng ở nơi khác.

Hương sen (GUI)
*****************

Chạy trốn khỏi nó.

Câu IBM (Web GUI)
*******************

Xem Ghi chú hoa sen.

Đột biến (TUI)
**************

Rất nhiều nhà phát triển Linux sử dụng ZZ0000ZZ, vì vậy nó hẳn phải hoạt động khá tốt.

Mutt không có trình soạn thảo đi kèm, vì vậy bất kỳ trình soạn thảo nào bạn sử dụng cũng phải có
được sử dụng theo cách không có ngắt dòng tự động.  Hầu hết các biên tập viên đều có
tùy chọn ZZ0000ZZ chèn nội dung của tệp
không thay đổi.

Để sử dụng ZZ0000ZZ với mutt ::

đặt trình soạn thảo="vi"

Nếu sử dụng xclip, gõ lệnh ::

:đặt dán

trước nút giữa hoặc shift-insert hoặc sử dụng ::

:r tên tập tin

nếu bạn muốn bao gồm bản vá nội tuyến.
(a)đính kèm hoạt động tốt mà không cần ZZ0000ZZ.

Bạn cũng có thể tạo các bản vá bằng ZZ0000ZZ và sau đó sử dụng Mutt
để gửi cho họ::

$ mutt -H 0001-some-bug-fix.patch

Tùy chọn cấu hình:

Nó sẽ hoạt động với các cài đặt mặc định.
Tuy nhiên, bạn nên đặt ZZ0000ZZ thành::

đặt send_charset="us-ascii:utf-8"

Mutt có khả năng tùy biến cao. Đây là cấu hình tối thiểu để bắt đầu
sử dụng Mutt để gửi các bản vá qua Gmail ::

# .muttrc
  # ================= IMAP =======================
  đặt imap_user = 'yourusername@gmail.com'
  đặt imap_pass = 'mật khẩu của bạn'
  đặt spoolfile = imaps://imap.gmail.com/INBOX
  đặt thư mục = imaps://imap.gmail.com/
  đặt bản ghi="imaps://imap.gmail.com/[Gmail]/Thư đã gửi"
  đặt hoãn="imaps://imap.gmail.com/[Gmail]/Drafts"
  đặt mbox="imaps://imap.gmail.com/[Gmail]/All Mail"

# ================= SMTP =======================
  đặt smtp_url = "smtp://username@smtp.gmail.com:587/"
  đặt smtp_pass = $imap_pass
  đặt ssl_force_tls = có kết nối được mã hóa # Require

# ================= Thành phần ======================
  đặt trình chỉnh sửa = ZZ0000ZZ
  đặt edit_headers = Yes # See tiêu đề khi chỉnh sửa
  đặt bộ ký tự = UTF-8 # value của $LANG; cũng là dự phòng cho send_charset
  # Sender, địa chỉ email và dòng đăng xuất phải khớp
  bỏ đặt use_domain # because joe@localhost thật đáng xấu hổ
  đặt tên thật = "YOUR NAME"
  đặt từ = "username@gmail.com"
  đặt use_from = có

Tài liệu Mutt có nhiều thông tin hơn:

ZZ0000ZZ

ZZ0000ZZ

Thông (TUI)
***********

Trước đây, Pine đã gặp phải một số vấn đề về việc cắt bớt khoảng trắng, nhưng những vấn đề này
tất cả nên được sửa chữa ngay bây giờ.

Sử dụng Alpine (kế thừa của cây thông) nếu có thể.

Tùy chọn cấu hình:

- ZZ0000ZZ cần thiết cho các phiên bản gần đây
- cần có tùy chọn ZZ0001ZZ


Sylpheed (GUI)
**************

- Hoạt động tốt cho nội tuyến văn bản (hoặc sử dụng tệp đính kèm).
- Cho phép sử dụng trình soạn thảo bên ngoài.
- Chậm trên các thư mục lớn.
- Sẽ không xác thực TLS SMTP qua kết nối không phải SSL.
- Có thanh thước hữu ích trong cửa sổ soạn thư.
- Thêm địa chỉ vào sổ địa chỉ không hiểu tên hiển thị
  đúng cách.

Thunderbird (GUI)
*****************

Thunderbird là một bản sao Outlook thích đọc văn bản, nhưng có nhiều cách
để ép buộc nó hành xử.

Sau khi thực hiện sửa đổi, việc này bao gồm cài đặt các tiện ích mở rộng,
bạn cần khởi động lại Thunderbird.

- Cho phép sử dụng trình soạn thảo bên ngoài:

Cách dễ nhất để làm với Thunderbird và các bản vá là sử dụng các tiện ích mở rộng
  mở trình soạn thảo bên ngoài yêu thích của bạn.

Dưới đây là một số tiện ích mở rộng mẫu có khả năng thực hiện việc này.

- "Trình chỉnh sửa bên ngoài được hồi sinh"

ZZ0000ZZ

ZZ0000ZZ

Nó yêu cầu cài đặt một "máy chủ nhắn tin gốc".
    Vui lòng đọc wiki có thể tìm thấy ở đây:
    ZZ0000ZZ

- "Biên tập viên bên ngoài"

ZZ0000ZZ

Để thực hiện việc này, hãy tải xuống và cài đặt tiện ích mở rộng, sau đó mở
    Cửa sổ ZZ0000ZZ, thêm nút cho nó bằng cách sử dụng
    ZZ0001ZZ
    sau đó chỉ cần nhấp vào nút mới khi bạn muốn sử dụng trình chỉnh sửa bên ngoài.

Xin lưu ý rằng "Trình chỉnh sửa bên ngoài" yêu cầu trình soạn thảo của bạn không được
    fork, hay nói cách khác, người soạn thảo không được quay lại trước khi đóng.
    Bạn có thể phải vượt qua các cờ bổ sung hoặc thay đổi cài đặt của
    biên tập viên. Đáng chú ý nhất là nếu bạn đang sử dụng gvim thì bạn phải vượt qua -f
    tùy chọn cho gvim bằng cách đặt ZZ0001ZZ (nếu nhị phân ở
    ZZ0002ZZ) vào trường soạn thảo văn bản trong ZZ0000ZZ
    cài đặt. Nếu bạn đang sử dụng một số trình soạn thảo khác thì vui lòng đọc hướng dẫn sử dụng của nó
    để tìm hiểu cách thực hiện việc này.

Để đánh bại một số ý nghĩa của trình soạn thảo nội bộ, hãy làm điều này:

- Chỉnh sửa cài đặt cấu hình Thunderbird của bạn để nó không sử dụng ZZ0001ZZ!
  Đi tới cửa sổ chính và tìm nút cho menu thả xuống chính của bạn.
  ZZ0000ZZ
  để hiển thị trình soạn thảo sổ đăng ký của Thunderbird.

- Đặt ZZ0000ZZ thành ZZ0001ZZ

- Đặt ZZ0000ZZ từ ZZ0001ZZ đến ZZ0002ZZ ZZ0003ZZ cài đặt
    Tiện ích mở rộng "Chuyển đổi gói dòng"

ZZ0000ZZ

ZZ0000ZZ

để kiểm soát sổ đăng ký này một cách nhanh chóng.

- Không viết tin nhắn HTML! Đi đến cửa sổ chính
  ZZ0000ZZ!
  Ở đó bạn có thể tắt tùy chọn "Soạn tin nhắn ở định dạng HTML".

- Chỉ mở tin nhắn dưới dạng văn bản thuần túy! Đi đến cửa sổ chính
  ZZ0000ZZ!

TkRat (GUI)
***********

Hoạt động.  Sử dụng "Chèn tệp..." hoặc trình chỉnh sửa bên ngoài.

Gmail (Web GUI)
***************

Không hoạt động để gửi bản vá.

Ứng dụng khách web Gmail tự động chuyển đổi các tab thành dấu cách.

Đồng thời, nó ngắt dòng mỗi 78 ký tự với các ngắt dòng kiểu CRLF
mặc dù vấn đề về tab2space có thể được giải quyết bằng trình soạn thảo bên ngoài.

Một vấn đề khác là Gmail sẽ mã hóa base64 bất kỳ thư nào có
ký tự không phải ASCII. Điều đó bao gồm những thứ như tên châu Âu.

HacKerMaiL (TUI)
****************

HacKerMaiL (hkml) là một công cụ quản lý thư đơn giản dựa trên hộp thư đến công cộng.
không yêu cầu đăng ký danh sách gửi thư.  Nó được phát triển và duy trì
bởi người bảo trì DAMON và nhằm mục đích hỗ trợ các quy trình phát triển đơn giản cho
DAMON và các hệ thống con kernel chung.  Tham khảo README
(ZZ0000ZZ để biết chi tiết.
