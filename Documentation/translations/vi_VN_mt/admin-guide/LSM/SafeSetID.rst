.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/LSM/SafeSetID.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========
ID an toàn
=========
SafeSetID là một mô-đun LSM kiểm soát nhóm hệ thống setid để hạn chế
UID/GID chuyển đổi từ UID/GID nhất định sang chỉ những chuyển đổi được phê duyệt bởi một
danh sách cho phép trên toàn hệ thống. Những hạn chế này cũng cấm các UID/GID nhất định
để có được các đặc quyền phụ trợ được liên kết với ID CAP_SET{U/G}, chẳng hạn như
cho phép người dùng thiết lập ánh xạ không gian tên người dùng UID/GID.


Lý lịch
==========
Trong trường hợp không có khả năng tập tin, các quy trình xuất hiện trên hệ thống Linux cần
để chuyển sang một người dùng khác phải được tạo ra với các đặc quyền CAP_SETUID.
CAP_SETUID được cấp cho các chương trình chạy bằng root hoặc những chương trình chạy không phải root
người dùng đã được cấp rõ ràng khả năng chạy CAP_SETUID. Đó là
thường thích sử dụng các khả năng thời gian chạy của Linux hơn là sử dụng tệp
khả năng, kể từ khi sử dụng khả năng tập tin để chạy một chương trình với nâng cao
các đặc quyền sẽ mở ra các lỗ hổng bảo mật có thể xảy ra vì bất kỳ người dùng nào có quyền truy cập vào
file có thể exec() chương trình đó để có được các đặc quyền nâng cao.

Mặc dù có thể triển khai một cây quy trình bằng cách cung cấp đầy đủ
Khả năng CAP_SET{U/G}ID, điều này thường mâu thuẫn với mục tiêu chạy một
cây quy trình dưới quyền của (những) người dùng không phải root ngay từ đầu. Cụ thể,
vì CAP_SETUID cho phép thay đổi thành bất kỳ người dùng nào trên hệ thống, kể cả root
người dùng, đó là khả năng vượt trội cho những gì cần thiết trong tình huống này,
đặc biệt là vì các chương trình thường chỉ gọi setuid() để bỏ đặc quyền xuống một
người dùng có đặc quyền thấp hơn - không nâng cao đặc quyền. Thật không may, không có
cách khả thi chung trong Linux để hạn chế các UID tiềm năng mà người dùng có thể
chuyển sang setuid() ngoài việc cho phép chuyển sang bất kỳ người dùng nào trên hệ thống.
SafeSetID LSM này tìm cách cung cấp giải pháp hạn chế setid
khả năng theo cách như vậy.

Trường hợp sử dụng chính của LSM này là cho phép một chương trình không phải root chuyển sang
các uid không đáng tin cậy khác không có khả năng CAP_SETUID đầy đủ. Không phải root
chương trình vẫn cần CAP_SETUID để thực hiện bất kỳ loại chuyển đổi nào, nhưng
các hạn chế bổ sung do LSM này áp đặt có nghĩa là đây là phiên bản "an toàn hơn"
của CAP_SETUID do chương trình không phải root không thể tận dụng CAP_SETUID để
thực hiện bất kỳ hành động không được phê duyệt nào (ví dụ: setuid thành uid 0 hoặc tạo/nhập người dùng mới
không gian tên). Mục tiêu cấp cao hơn là cho phép hệ thống sandbox dựa trên uid
dịch vụ mà không cần phải cung cấp CAP_SETUID ở mọi nơi chỉ để
các chương trình không phải root có thể giảm xuống các uid thậm chí có ít đặc quyền hơn. Điều này đặc biệt
có liên quan khi một daemon không phải root trên hệ thống được phép sinh ra một daemon khác
xử lý dưới dạng các uid khác nhau, nhưng việc cung cấp cho daemon một
về cơ bản là CAP_SETUID tương đương với root.


Các phương pháp tiếp cận khác được xem xét
===========================

Giải quyết vấn đề này trong không gian người dùng
-------------------------------
Dành cho các ứng dụng ứng viên muốn hạn chế khả năng setid
như được triển khai trong LSM này, một lựa chọn thay thế sẽ đơn giản là loại bỏ
khả năng setid hoàn toàn từ ứng dụng và cấu trúc lại quy trình
tạo ra ngữ nghĩa trong ứng dụng (ví dụ: bằng cách sử dụng chương trình trợ giúp đặc quyền
để thực hiện quá trình sinh sản và chuyển tiếp UID/GID). Thật không may, có một
số lượng ngữ nghĩa xung quanh quá trình sinh sản sẽ bị ảnh hưởng bởi điều này, chẳng hạn như
như các cuộc gọi fork() trong đó chương trình không gọi ngay exec() sau
fork(), các tiến trình cha chỉ định các biến môi trường tùy chỉnh hoặc dòng lệnh
đối số cho các tiến trình con được sinh ra hoặc kế thừa các thẻ điều khiển tệp trên một
ngã ba()/exec(). Vì lý do này, giải pháp sử dụng trình trợ giúp đặc quyền trong
không gian người dùng có thể sẽ kém hấp dẫn hơn khi kết hợp vào các dự án hiện có
dựa vào ngữ nghĩa sinh sản quy trình nhất định trong Linux.

Sử dụng không gian tên người dùng
-------------------
Một cách tiếp cận khả thi khác là chạy một cây quy trình nhất định trong người dùng của chính nó
không gian tên và cung cấp cho các chương trình khả năng setid của cây. Bằng cách này,
các chương trình trong cây có thể thay đổi thành bất kỳ UID/GID nào mong muốn trong bối cảnh của chúng.
không gian tên người dùng riêng và chỉ các UID/GID được phê duyệt mới có thể được ánh xạ trở lại
không gian tên người dùng hệ thống ban đầu, ngăn chặn việc leo thang đặc quyền một cách hiệu quả.
Thật không may, nói chung việc sử dụng các không gian tên người dùng một cách riêng lẻ là không khả thi,
mà không ghép nối chúng với các loại không gian tên khác, điều này không phải lúc nào cũng là một lựa chọn.
Linux kiểm tra các khả năng dựa trên không gian tên người dùng "sở hữu" một số
thực thể. Ví dụ, Linux có quan niệm rằng các không gian tên mạng được sở hữu bởi
không gian tên người dùng nơi họ được tạo. Hậu quả của việc này là
kiểm tra khả năng truy cập vào một không gian tên mạng nhất định được thực hiện bằng cách kiểm tra
liệu một tác vụ có khả năng nhất định trong ngữ cảnh của không gian tên người dùng hay không
sở hữu không gian tên mạng -- không nhất thiết phải có không gian tên người dùng trong
mà nhiệm vụ nhất định chạy. Do đó, sinh ra một quy trình trong không gian tên người dùng mới
ngăn chặn nó một cách hiệu quả khỏi việc truy cập vào không gian tên mạng thuộc sở hữu của
không gian tên ban đầu. Đây là một công cụ phá vỡ thỏa thuận đối với bất kỳ ứng dụng nào mong muốn
giữ lại khả năng CAP_NET_ADMIN cho mục đích điều chỉnh mạng
cấu hình. Việc sử dụng không gian tên người dùng một cách riêng biệt sẽ gây ra các vấn đề liên quan đến
các tương tác hệ thống khác, bao gồm việc sử dụng không gian tên pid và tạo thiết bị.

Sử dụng LSM hiện có
-------------------
Không có LSM nào trong cây khác có khả năng chuyển tiếp cổng setid, hoặc
thậm chí còn sử dụng hook security_task_fix_setuid. SELinux nói về cái móc đó:
"Vì setuid chỉ ảnh hưởng đến quy trình hiện tại và vì SELinux kiểm soát
không dựa trên các thuộc tính nhận dạng Linux, SELinux không cần kiểm soát
hoạt động này."


Hướng dẫn sử dụng
==================
LSM này nối các tòa nhà chọc trời setid để đảm bảo cho phép chuyển đổi nếu một
chính sách hạn chế hiện hành được áp dụng. Chính sách được cấu hình thông qua
securityfs bằng cách ghi vào safesetid/uid_allowlist_policy và
các tệp safesetid/gid_allowlist_policy tại vị trí có securityfs
gắn kết. Định dạng để thêm chính sách là '<UID>:<UID>' hoặc '<GID>:<GID>',
sử dụng số bằng chữ và kết thúc bằng ký tự dòng mới, chẳng hạn như '123:456\n'.
Viết một chuỗi trống "" sẽ xóa chính sách. Một lần nữa, cấu hình một chính sách
đối với UID/GID sẽ ngăn UID/GID đó lấy setid phụ
các đặc quyền, chẳng hạn như cho phép người dùng thiết lập ánh xạ không gian tên người dùng UID/GID.

Lưu ý về các chính sách và nhóm setgroups của GID()
====================================
Trong v5.9, chúng tôi sẽ thêm hỗ trợ để giới hạn các đặc quyền CAP_SETGID như đã được thực hiện
trước đây cho CAP_SETUID. Tuy nhiên, để tương thích với sandbox thông thường
quy ước mã liên quan trong không gian người dùng, chúng tôi hiện cho phép tùy ý
setgroups() gọi các quy trình có hạn chế CAP_SETGID. Cho đến khi chúng tôi thêm
hỗ trợ trong bản phát hành trong tương lai để hạn chế lệnh gọi setgroups(), những GID này
chính sách không thêm bảo mật có ý nghĩa. các hạn chế setgroups() sẽ được thực thi
khi chúng tôi có sẵn mã kiểm tra chính sách, mã này sẽ dựa vào chính sách GID
mã cấu hình được thêm vào trong v5.9.
