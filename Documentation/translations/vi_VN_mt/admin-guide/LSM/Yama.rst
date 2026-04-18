.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/LSM/Yama.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====
Yama
====

Yama là Mô-đun bảo mật Linux thu thập bảo mật DAC trên toàn hệ thống
các biện pháp bảo vệ không được xử lý bởi chính hạt nhân lõi. Đây là
có thể lựa chọn tại thời điểm xây dựng với ZZ0000ZZ và có thể được kiểm soát
tại thời gian chạy thông qua sysctls trong ZZ0001ZZ:

ptrace_scope
============

Khi Linux ngày càng phổ biến, nó sẽ trở thành mục tiêu lớn hơn cho
phần mềm độc hại. Một điểm yếu đặc biệt đáng lo ngại của quy trình Linux
giao diện là một người dùng có thể kiểm tra bộ nhớ và
trạng thái đang chạy của bất kỳ quy trình nào của họ. Ví dụ, nếu một ứng dụng
(ví dụ: Pidgin) đã bị xâm phạm, kẻ tấn công có thể
đính kèm vào các quy trình đang chạy khác (ví dụ: phiên Firefox, SSH, tác nhân GPG,
v.v.) để trích xuất thông tin xác thực bổ sung và tiếp tục mở rộng phạm vi
cuộc tấn công của họ mà không cần dùng đến lừa đảo do người dùng hỗ trợ.

Đây không phải là một vấn đề lý thuyết. ZZ0000ZZ
và ZZ0001ZZ đã tấn công rồi
tồn tại và vẫn có thể tồn tại nếu ptrace được phép hoạt động như trước.
Vì ptrace không được sử dụng phổ biến bởi những người không phải là nhà phát triển và không phải quản trị viên nên hệ thống
người xây dựng nên được phép tùy chọn tắt hệ thống gỡ lỗi này.

Để có giải pháp, một số ứng dụng sử dụng ZZ0000ZZ để
đặc biệt không cho phép đính kèm ptrace như vậy (ví dụ: ssh-agent), nhưng nhiều
không. Một giải pháp tổng quát hơn là chỉ cho phép ptrace trực tiếp từ một
cha mẹ cho một tiến trình con (tức là vẫn trực tiếp "gdb EXE" và "srace EXE"
hoạt động) hoặc với ZZ0001ZZ (tức là "gdb --pid=PID" và "strace -p PID"
vẫn hoạt động như root).

Ở chế độ 1, phần mềm đã xác định các mối quan hệ dành riêng cho ứng dụng
giữa quá trình gỡ lỗi và quá trình kém hơn của nó (trình xử lý sự cố, v.v.),
ZZ0000ZZ có thể được sử dụng. Cấp dưới có thể khai báo điều gì
quá trình khác (và con cháu của nó) được phép gọi ZZ0001ZZ
chống lại nó. Chỉ có một quy trình gỡ lỗi được khai báo như vậy có thể tồn tại cho
mỗi người thấp kém một lúc. Ví dụ: điều này được sử dụng bởi KDE, Chrome và
Trình xử lý sự cố của Firefox và bởi Wine vì chỉ cho phép các quy trình Wine
để ptrace nhau. Nếu một tiến trình muốn vô hiệu hóa hoàn toàn các ptrace này
hạn chế, nó có thể gọi ZZ0002ZZ
sao cho bất kỳ quy trình nào được phép khác (ngay cả những quy trình trong không gian tên pid bên ngoài)
có thể đính kèm.

Cài đặt sysctl (chỉ có thể ghi với ZZ0000ZZ) là:

0 - quyền ptrace cổ điển:
    một tiến trình có thể chuyển ZZ0000ZZ sang bất kỳ tiến trình nào khác
    quá trình chạy trong cùng một uid, miễn là nó có thể kết xuất được (tức là
    không chuyển đổi uid, bắt đầu có đặc quyền hoặc đã gọi
    ZZ0001ZZ rồi). Tương tự, ZZ0002ZZ là
    không thay đổi.

1 - ptrace bị hạn chế:
    một quá trình phải có một mối quan hệ được xác định trước
    với cấp dưới nó muốn gọi ZZ0000ZZ. Theo mặc định,
    mối quan hệ này chỉ là mối quan hệ con cháu của nó khi ở trên
    tiêu chí cổ điển cũng được đáp ứng. Để thay đổi mối quan hệ, một
    cấp dưới có thể gọi ZZ0001ZZ để khai báo
    một trình gỡ lỗi được phép PID gọi ZZ0002ZZ ở cấp độ thấp hơn.
    Việc sử dụng ZZ0003ZZ không thay đổi.

2 - tệp đính kèm chỉ dành cho quản trị viên:
    chỉ các quy trình với ZZ0000ZZ mới có thể sử dụng ptrace, với
    ZZ0001ZZ hoặc thông qua trẻ em gọi ZZ0002ZZ.

3 - không đính kèm:
    không có quy trình nào có thể sử dụng ptrace với ZZ0000ZZ cũng như thông qua
    ZZ0001ZZ. Sau khi được đặt, giá trị sysctl này không thể thay đổi.

Logic ban đầu chỉ dành cho trẻ em dựa trên những hạn chế trong grsecurity.
