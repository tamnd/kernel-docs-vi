.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/unicode.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Hỗ trợ Unicode
===============

Cập nhật lần cuối: 17-01-2005, phiên bản 1.4

Lưu ý: Phiên bản gốc của tài liệu này được lưu giữ tại
lanana.org như một phần của Cơ quan cấp số và tên được gán cho Linux
(LANANA), dự án không còn tồn tại.  Vì vậy, phiên bản này trong
Nhân Linux chính tuyến hiện là tài liệu chính được duy trì.

Giới thiệu
------------

Mã nhân Linux đã được viết lại để sử dụng Unicode để ánh xạ
ký tự thành phông chữ.  Bằng cách tải xuống một bảng Unicode-to-font,
cả bộ ký tự 8 bit và chế độ UTF-8 đều được thay đổi để sử dụng
phông chữ như đã chỉ ra.

Điều này làm thay đổi ngữ nghĩa của bảng ký tự 8 bit một cách tinh vi.
Bốn bảng ký tự bây giờ là:

===================================================================
Ký hiệu bản đồ Tên bản đồ Mã thoát (G0)
===================================================================
LAT1_MAP Latin-1 (ISO 8859-1) ESC ( B
GRAF_MAP DEC VT100 bút giả ESC ( 0
IBMPC_MAP IBM mã trang 437 ESC ( U
USER_MAP Người dùng định nghĩa ESC ( K
===================================================================

Đặc biệt, ESC ( U không còn "thẳng tới phông chữ", vì phông chữ
có thể hoàn toàn khác với bộ ký tự IBM.  Cái này
ví dụ như cho phép sử dụng đồ họa khối ngay cả với phông chữ Latin-1
đã tải.

Lưu ý rằng mặc dù các mã này tương tự như ISO 2022, nhưng cả
mã cũng như cách sử dụng của chúng không khớp với ISO 2022; Linux có hai mã 8 bit (G0 và
G1), trong khi ISO 2022 có bốn mã 7 bit (G0-G3).

Theo tiêu chuẩn Unicode/ISO 10646, phạm vi từ U+F000 đến
U+F8FF đã được dành riêng cho phân bổ trên toàn hệ điều hành (Tiêu chuẩn Unicode
gọi đây là "Khu vực công ty", vì điều này không chính xác đối với
Linux, chúng tôi gọi nó là "Khu vực Linux").  U+F000 được chọn làm người bắt đầu
điểm vì nó cho phép khu vực ánh xạ trực tiếp bắt đầu với lũy thừa lớn
hai (trong trường hợp phông chữ 1024 hoặc 2048 ký tự trở nên cần thiết).
Điều này khiến U+E000 thành U+EFFF là Vùng người dùng cuối.

[v1.2]: Phạm vi Unicode từ U+F000 và lên đến U+F7FF đã được
được mã hóa cứng để ánh xạ trực tiếp tới phông chữ được tải, bỏ qua
bảng dịch.  Bản đồ do người dùng xác định bây giờ được mặc định là U+F000 để
U+F0FF, mô phỏng hành vi trước đó.  Trong thực tế, phạm vi này
có thể ngắn hơn; ví dụ: vgacon chỉ có thể xử lý 256 ký tự
(U+F000..U+F0FF) hoặc phông chữ 512 ký tự (U+F000..U+F1FF).


Các ký tự thực tế được gán trong Vùng Linux
--------------------------------------------

Ngoài ra, các ký tự sau không có trong Unicode 1.1.4
đã được xác định; chúng được sử dụng bởi bản đồ đồ họa DEC VT.  [v1.2]
THIS USE LÀ OBSOLETE AND SHOULD KHÔNG LONGER ĐƯỢC USED; PLEASE SEE BELOW.

====== ==========================================
U+F800 DEC VT GRAPHICS HORIZONTAL LINE SCAN 1
U+F801 DEC VT GRAPHICS HORIZONTAL LINE SCAN 3
U+F803 DEC VT GRAPHICS HORIZONTAL LINE SCAN 7
U+F804 DEC VT GRAPHICS HORIZONTAL LINE SCAN 9
====== ==========================================

DEC VT220 sử dụng ma trận ký tự 6x10 và các ký tự này tạo thành
một tiến triển suôn sẻ trong bộ ký tự đồ họa DEC VT.  tôi có
đã bỏ qua dòng scan 5 vì nó cũng được sử dụng làm đồ họa khối
ký tự và do đó đã được mã hóa thành U+2500 FORMS LIGHT HORIZONTAL.

[v1.3]: Các ký tự này đã chính thức được thêm vào Unicode 3.2.0;
chúng được thêm vào tại U+23BA, U+23BB, U+23BC, U+23BD.  Linux hiện nay sử dụng
những giá trị mới.

[v1.2]: Các ký tự sau đã được thêm vào để thể hiện các ký tự chung
các ký hiệu bàn phím khó có thể được thêm vào Unicode
vì chúng đặc biệt dành riêng cho nhà cung cấp.  Tất nhiên, đây là một
ví dụ tuyệt vời về thiết kế khủng khiếp.

====== ==========================================
U+F810 KEYBOARD SYMBOL FLYING FLAG
U+F811 KEYBOARD SYMBOL PULLDOWN MENU
U+F812 KEYBOARD SYMBOL OPEN APPLE
U+F813 KEYBOARD SYMBOL SOLID APPLE
====== ==========================================

Hỗ trợ ngôn ngữ Klingon
------------------------

Năm 1996, Linux là hệ điều hành đầu tiên trên thế giới có thêm
hỗ trợ ngôn ngữ nhân tạo Klingon, được tạo bởi Marc Okrand
cho loạt phim truyền hình "Star Trek".	Mã hóa này sau đó đã được
được Cơ quan đăng ký Unicode ConScript thông qua và đề xuất (nhưng cuối cùng
bị từ chối) để đưa vào Mặt phẳng Unicode 1. Vì vậy, nó vẫn là một
Phân công riêng Linux/CSUR trong Vùng Linux.

Bảng mã này đã được Viện Ngôn ngữ Klingon xác nhận.
Để biết thêm thông tin, liên hệ với họ tại:

ZZ0000ZZ

Vì các ký tự ở phần đầu của Linux CZ đã có nhiều hơn
thuộc loại dingbats/ký hiệu/biểu mẫu và đây là một ngôn ngữ, tôi có
đặt nó ở cuối, trên ranh giới 16 ô theo tiêu chuẩn
Thực hành Unicode.

.. note::

  This range is now officially managed by the ConScript Unicode
  Registry.  The normative reference is at:

	https://www.evertype.com/standards/csur/klingon.html

Tiếng Klingon có bảng chữ cái gồm 26 ký tự, cách viết số theo vị trí
hệ thống có 10 chữ số và được viết từ trái sang phải, từ trên xuống dưới.

Một số dạng ký tự cho bảng chữ cái Klingon đã được đề xuất.
Tuy nhiên, vì tập hợp các ký hiệu có vẻ nhất quán xuyên suốt nên
chỉ có hình dạng thực tế là khác nhau, phù hợp với tiêu chuẩn
Thực hành Unicode những khác biệt này được coi là các biến thể phông chữ.

====== =============================================================
U+F8D0 KLINGON LETTER A
U+F8D1 KLINGON LETTER B
U+F8D2 KLINGON LETTER CH
U+F8D3 KLINGON LETTER D
U+F8D4 KLINGON LETTER E
U+F8D5 KLINGON LETTER GH
U+F8D6 KLINGON LETTER H
U+F8D7 KLINGON LETTER tôi
U+F8D8 KLINGON LETTER J
U+F8D9 KLINGON LETTER L
U+F8DA KLINGON LETTER M
U+F8DB KLINGON LETTER N
U+F8DC KLINGON LETTER NG
U+F8DD KLINGON LETTER O
U+F8DE KLINGON LETTER P
U+F8DF KLINGON LETTER Q
	- Viết <q> theo phiên âm chuẩn tiếng Latin Okrand
U+F8E0 KLINGON LETTER QH
	- Viết <Q> theo phiên âm tiếng Latin Okrand chuẩn
U+F8E1 KLINGON LETTER R
U+F8E2 KLINGON LETTER S
U+F8E3 KLINGON LETTER T
U+F8E4 KLINGON LETTER TLH
U+F8E5 KLINGON LETTER U
U+F8E6 KLINGON LETTER V
U+F8E7 KLINGON LETTER W
U+F8E8 KLINGON LETTER Y
U+F8E9 KLINGON LETTER GLOTTAL STOP

U+F8F0 KLINGON DIGIT ZERO
U+F8F1 KLINGON DIGIT ONE
U+F8F2 KLINGON DIGIT TWO
U+F8F3 KLINGON DIGIT THREE
U+F8F4 KLINGON DIGIT FOUR
U+F8F5 KLINGON DIGIT FIVE
U+F8F6 KLINGON DIGIT SIX
U+F8F7 KLINGON DIGIT SEVEN
U+F8F8 KLINGON DIGIT EIGHT
U+F8F9 KLINGON DIGIT NINE

U+F8FD KLINGON COMMA
U+F8FE KLINGON FULL STOP
U+F8FF KLINGON SYMBOL FOR EMPIRE
====== =============================================================

Kịch bản hư cấu và nhân tạo khác
--------------------------------------

Kể từ khi gán khối Unicode Klingon Linux, sổ đăng ký của
kịch bản hư cấu và nhân tạo đã được thành lập bởi John Cowan
<jcowan@reutershealth.com> và Michael Everson <everson@evertype.com>.
Có thể truy cập Sổ đăng ký Unicode ConScript tại:

ZZ0000ZZ

Phạm vi được sử dụng nằm ở mức thấp nhất của Vùng người dùng cuối và do đó có thể
không được chỉ định một cách thông thường, nhưng chúng tôi khuyên những người
muốn mã hóa các chữ viết hư cấu, hãy sử dụng các mã này vì lợi ích của
khả năng tương tác.  Đối với Klingon, CSUR đã áp dụng mã hóa Linux.
Những người CSUR đang nỗ lực thêm Tengwar và Cirth vào Unicode
Mặt phẳng 1; việc bổ sung Klingon vào Unicode Plane 1 đã bị từ chối
và do đó mã hóa ở trên vẫn chính thức.
