.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/firmware-guide/acpi/DSD-properties-rules.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================================
Quy tắc sử dụng thuộc tính thiết bị _DSD
==================================

Thuộc tính, tập thuộc tính và tập hợp con thuộc tính
==============================================

Đối tượng cấu hình _DSD (Dữ liệu cụ thể của thiết bị), được giới thiệu trong ACPI 5.1,
cho phép mọi loại dữ liệu cấu hình thiết bị được cung cấp thông qua ACPI
không gian tên.  Về nguyên tắc, định dạng của dữ liệu có thể tùy ý, nhưng nó phải
được xác định bởi UUID, UUID phải được trình điều khiển xử lý
Đầu ra _DSD.  Tuy nhiên, có các UUID chung được xác định cho _DSD được công nhận bởi
hệ thống con ACPI trong nhân Linux tự động xử lý dữ liệu
các gói được liên kết với chúng và cung cấp những dữ liệu đó cho trình điều khiển thiết bị
là "thuộc tính thiết bị".

Thuộc tính thiết bị là một mục dữ liệu bao gồm khóa chuỗi và giá trị (của
loại cụ thể) được liên kết với nó.

Trong ngữ cảnh ACPI _DSD, nó là một thành phần của gói phụ theo sau
Thuộc tính thiết bị chung UUID trong gói trả lại _DSD như được chỉ định trong
phần có tiêu đề phần phụ "Các định dạng cấu trúc dữ liệu và UUID _DSD nổi tiếng"
Hướng dẫn triển khai "Thuộc tính thiết bị UUID" trong _DSD (Dữ liệu cụ thể của thiết bị)
tài liệu [1]_.

Nó cũng có thể được coi là định nghĩa của khóa và kiểu dữ liệu liên quan
có thể được _DSD trả lại trong gói phụ Thuộc tính thiết bị UUID cho một
thiết bị đã cho.

Tập thuộc tính là tập hợp các thuộc tính có thể áp dụng cho một thực thể phần cứng
giống như một thiết bị.  Trong ngữ cảnh ACPI _DSD, nó là tập hợp tất cả các thuộc tính
có thể được trả lại trong gói phụ Thuộc tính thiết bị UUID cho thiết bị trong
câu hỏi.

Tập hợp con thuộc tính là tập hợp các thuộc tính lồng nhau.  Mỗi người trong số họ là
được liên kết với một khóa (tên) bổ sung cho phép tập hợp con được tham chiếu
thành một tổng thể (và được coi như một thực thể riêng biệt).  kinh điển
việc biểu diễn các tập hợp con thuộc tính được thực hiện thông qua cơ chế được chỉ định trong
phần phụ có tiêu đề "Các định dạng cấu trúc dữ liệu và UUID _DSD nổi tiếng"
"Phần mở rộng dữ liệu phân cấp UUID" trong _DSD (Dữ liệu cụ thể của thiết bị)
Văn bản hướng dẫn thực hiện [1]_.

Tập thuộc tính có thể được phân cấp.  Nghĩa là, một tập thuộc tính có thể chứa
nhiều tập hợp con thuộc tính mà mỗi tập hợp con có thể chứa các tập hợp con thuộc tính của nó
của riêng và vân vân.

Quy tắc hợp lệ chung cho tập thuộc tính
=======================================

Các bộ thuộc tính hợp lệ phải tuân theo hướng dẫn được cung cấp bởi Thuộc tính thiết bị UUID
tài liệu định nghĩa [1].

Các thuộc tính _DSD được thiết kế để sử dụng bổ sung chứ không phải thay thế cho
các cơ chế hiện có được xác định bởi đặc tả ACPI.  Vì vậy, theo quy định,
chúng chỉ nên được sử dụng nếu thông số kỹ thuật ACPI không trực tiếp
quy định để xử lý trường hợp sử dụng cơ bản.  Nói chung là không hợp lệ để
trả về các bộ thuộc tính không tuân theo quy tắc đó từ _DSD trong gói dữ liệu
được liên kết với Thuộc tính thiết bị UUID.

Cân nhắc bổ sung
-------------------------

Có những trường hợp, ngay cả khi nguyên tắc chung nêu trên được tuân thủ trong
về nguyên tắc, tập thuộc tính có thể vẫn không được coi là hợp lệ.

Ví dụ: điều đó áp dụng cho các thuộc tính thiết bị có thể gây ra mã hạt nhân
(trình điều khiển thiết bị hoặc thư viện/hệ thống con) để truy cập phần cứng theo cách
có thể dẫn đến xung đột với các phương thức AML trong không gian tên ACPI.  trong
cụ thể, điều đó có thể xảy ra nếu mã hạt nhân sử dụng thuộc tính thiết bị để
thao tác phần cứng thường được điều khiển bằng các phương pháp ACPI liên quan đến nguồn điện
quản lý, như _PSx và _DSW (đối với đối tượng thiết bị) hoặc _ON và _OFF (đối với nguồn điện
đối tượng tài nguyên) hoặc bằng các phương thức vô hiệu hóa/kích hoạt thiết bị ACPI, như _DIS và
_SRS.

Trong mọi trường hợp mã hạt nhân có thể làm điều gì đó khiến AML nhầm lẫn là
kết quả của việc sử dụng thuộc tính thiết bị, các thuộc tính thiết bị được đề cập không
phù hợp với môi trường ACPI và do đó chúng không thể thuộc về một môi trường hợp lệ
bộ tài sản.

Tập thuộc tính và ràng buộc cây thiết bị
======================================

Việc tạo các bộ thuộc tính trả về _DSD theo Cây thiết bị thường rất hữu ích
ràng buộc.

Tuy nhiên, trong những trường hợp đó, những cân nhắc về tính hợp lệ ở trên phải được xem xét
tài khoản ngay từ đầu và trả lại bộ thuộc tính không hợp lệ từ _DSD phải
tránh được.  Vì lý do này, có thể không thể khiến _DSD trả lại tài sản
được đặt theo ràng buộc DT đã cho theo đúng nghĩa đen và đầy đủ.  Tuy nhiên, đối với
vì mục đích sử dụng lại mã, việc cung cấp càng nhiều cấu hình càng tốt
dữ liệu càng tốt dưới dạng thuộc tính thiết bị và bổ sung dữ liệu đó bằng
Cơ chế dành riêng cho ACPI phù hợp với trường hợp sử dụng hiện tại.

Trong bất kỳ trường hợp nào, các tập thuộc tính tuân theo các ràng buộc DT theo nghĩa đen không nên
dự kiến sẽ tự động hoạt động trong môi trường ACPI bất kể chúng
nội dung.

Tài liệu tham khảo
==========

.. [1] https://github.com/UEFI/DSD-Guide