.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/volatile-considered-harmful.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.


.. _volatile_considered_harmful:

Tại sao không nên sử dụng lớp loại "dễ bay hơi"
------------------------------------------------

Các lập trình viên C thường hiểu biến động có nghĩa là biến có thể
đã thay đổi bên ngoài luồng thực thi hiện tại; kết quả là họ
đôi khi bị cám dỗ sử dụng nó trong mã hạt nhân khi cấu trúc dữ liệu được chia sẻ
đang được sử dụng.  Nói cách khác, chúng được biết là có tác dụng điều trị các loại dễ bay hơi
như một loại biến nguyên tử dễ dàng, nhưng thực ra không phải vậy.  Việc sử dụng chất dễ bay hơi trong
mã hạt nhân hầu như không bao giờ đúng; tài liệu này mô tả lý do tại sao.

Điểm mấu chốt cần hiểu liên quan đến sự biến động là mục đích của nó là
để ngăn chặn việc tối ưu hóa, điều gần như không bao giờ là điều người ta thực sự muốn
làm.  Trong kernel, người ta phải bảo vệ cấu trúc dữ liệu dùng chung chống lại
truy cập đồng thời không mong muốn, đó là một nhiệm vụ hoàn toàn khác.  các
Quá trình bảo vệ chống lại sự tương tranh không mong muốn cũng sẽ tránh được gần như
tất cả các vấn đề liên quan đến tối ưu hóa theo cách hiệu quả hơn.

Giống như tính dễ bay hơi, các nguyên hàm kernel giúp truy cập đồng thời vào dữ liệu
an toàn (spinlocks, mutexes, rào cản bộ nhớ, v.v.) được thiết kế để ngăn chặn
tối ưu hóa không mong muốn.  Nếu chúng được sử dụng đúng cách thì sẽ không có
cũng cần sử dụng biến động.  Nếu tính dễ bay hơi vẫn cần thiết thì có
gần như chắc chắn có lỗi trong mã ở đâu đó.  Trong kernel được viết đúng
mã, tính dễ bay hơi chỉ có thể làm mọi thứ chậm lại.

Hãy xem xét một khối mã hạt nhân điển hình::

spin_lock(&the_lock);
    do_something_on(&shared_data);
    do_something_else_with(&shared_data);
    spin_unlock(&the_lock);

Nếu tất cả mã tuân theo quy tắc khóa thì giá trị của dữ liệu chia sẻ không thể
thay đổi bất ngờ trong khi the_lock được giữ.  Bất kỳ mã nào khác có thể
muốn chơi với dữ liệu đó sẽ chờ trên khóa.  khóa quay
nguyên thủy đóng vai trò là rào cản bộ nhớ - chúng được viết rõ ràng để làm như vậy -
có nghĩa là việc truy cập dữ liệu sẽ không được tối ưu hóa trên chúng.  Vì vậy
trình biên dịch có thể nghĩ rằng nó biết những gì sẽ có trong dữ liệu chia sẻ, nhưng
lệnh gọi spin_lock(), vì nó hoạt động như một rào cản bộ nhớ, sẽ buộc nó phải
quên bất cứ điều gì nó biết.  Sẽ không có vấn đề tối ưu hóa với
truy cập vào dữ liệu đó.

Nếu dữ liệu chia sẻ được khai báo là không ổn định, khóa vẫn sẽ có hiệu lực
cần thiết.  Nhưng trình biên dịch cũng sẽ bị ngăn cản việc tối ưu hóa quyền truy cập
tới dữ liệu được chia sẻ _trong_ phần quan trọng, khi chúng tôi biết rằng không có ai khác
có thể làm việc với nó  Trong khi khóa được giữ, dữ liệu chia sẻ thì không
dễ bay hơi.  Khi xử lý dữ liệu được chia sẻ, việc khóa thích hợp sẽ làm cho dữ liệu không ổn định.
không cần thiết - và có khả năng gây hại.

Lớp lưu trữ dễ bay hơi ban đầu được dùng cho I/O được ánh xạ bộ nhớ
sổ đăng ký.  Trong kernel, quyền truy cập đăng ký cũng cần được bảo vệ
bằng khóa, nhưng người ta cũng không muốn đăng ký "tối ưu hóa" trình biên dịch
truy cập trong một phần quan trọng.  Tuy nhiên, bên trong kernel, bộ nhớ I/O
việc truy cập luôn được thực hiện thông qua các hàm truy cập; truy cập bộ nhớ I/O
trực tiếp thông qua con trỏ không được tán thành và không hoạt động trên tất cả
kiến trúc.  Những trình truy cập đó được viết để ngăn chặn những điều không mong muốn
tối ưu hóa, do đó, một lần nữa, biến động là không cần thiết.

Một tình huống khác mà người ta có thể bị cám dỗ sử dụng tính dễ bay hơi là
khi bộ xử lý đang bận chờ giá trị của một biến.  Bên phải
cách để thực hiện chờ đợi bận là::

trong khi (my_variable != what_i_want)
        cpu_relax();

Lệnh gọi cpu_relax() có thể giảm mức tiêu thụ điện năng của CPU hoặc mang lại
bộ xử lý đôi siêu phân luồng; nó cũng tình cờ phục vụ như một trình biên dịch
rào cản, vì vậy, một lần nữa, sự biến động là không cần thiết.  Tất nhiên là bận-
chờ đợi nói chung là một hành động chống đối xã hội ngay từ đầu.

Vẫn còn một vài tình huống hiếm hoi mà sự biến động có ý nghĩa trong
hạt nhân:

- Các chức năng truy cập nêu trên có thể sử dụng dễ bay hơi trên
    kiến trúc nơi hoạt động truy cập bộ nhớ I/O trực tiếp.  Về cơ bản,
    mỗi lệnh gọi của trình truy cập sẽ tự trở thành một phần quan trọng và
    đảm bảo rằng việc truy cập diễn ra như mong đợi của người lập trình.

- Mã hợp ngữ nội tuyến thay đổi bộ nhớ nhưng không có bộ nhớ nào khác
    tác dụng phụ có thể nhìn thấy, nguy cơ bị GCC xóa.  Thêm chất dễ bay hơi
    các câu lệnh từ khóa đến asm sẽ ngăn chặn việc xóa này.

- Biến jiffies đặc biệt ở chỗ nó có thể có giá trị khác
    mỗi khi nó được tham chiếu, nhưng nó có thể được đọc mà không cần bất kỳ điều gì đặc biệt
    khóa.  Vì vậy, giá trị jiffies có thể không ổn định, nhưng việc bổ sung các giá trị khác
    các biến kiểu này bị phản đối mạnh mẽ.  Jiffies được coi là
    là một vấn đề "di sản ngu ngốc" (lời của Linus) về mặt này; sửa nó
    sẽ gặp nhiều rắc rối hơn giá trị của nó.

- Con trỏ tới cấu trúc dữ liệu trong bộ nhớ mạch lạc có thể được sửa đổi
    bởi các thiết bị I/O đôi khi có thể không ổn định một cách hợp pháp.  Bộ đệm vòng
    được sử dụng bởi bộ điều hợp mạng, trong đó bộ điều hợp đó thay đổi con trỏ thành
    cho biết mô tả nào đã được xử lý, là một ví dụ về điều này
    loại tình huống.

Đối với hầu hết các mã, không có lời biện minh nào ở trên cho tính dễ bay hơi được áp dụng.  Như một
kết quả là việc sử dụng chất dễ bay hơi có thể bị coi là một lỗi và sẽ mang lại
sự xem xét bổ sung đối với mã.  Các nhà phát triển muốn sử dụng
dễ bay hơi nên lùi lại một bước và suy nghĩ về những gì họ đang thực sự cố gắng
để hoàn thành.

Các bản vá để loại bỏ các biến dễ thay đổi thường được hoan nghênh - miễn là
họ đưa ra lời biện minh cho thấy rằng các vấn đề tương tranh có
đã được suy nghĩ thấu đáo.


Tài liệu tham khảo
==========

[1] ZZ0000ZZ

[2] ZZ0000ZZ

Tín dụng
=======

Động lực ban đầu và nghiên cứu của Randy Dunlap

Viết bởi Jonathan Corbet

Những cải tiến thông qua nhận xét từ Satyam Sharma, Johannes Stezenbach, Jesper
Juhl, Heikki Orsila, H. Peter Anvin, Philipp Hahn và Stefan
Richter.
