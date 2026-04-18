.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/security/landlock.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright © 2017-2020 Mickaël Salaün <mic@digikod.net>
.. Copyright © 2019-2020 ANSSI

=====================================
Landlock LSM: tài liệu hạt nhân
==================================

:Tác giả: Mickaël Salaün
:Ngày: Tháng 3 năm 2026

Mục tiêu của Landlock là tạo ra khả năng kiểm soát truy cập có phạm vi (tức là hộp cát).  Đến
củng cố toàn bộ hệ thống, tính năng này sẽ có sẵn cho bất kỳ quy trình nào,
kể cả những người không có đặc quyền.  Bởi vì quá trình như vậy có thể bị tổn hại hoặc
bị cửa sau (tức là không đáng tin cậy), các tính năng của Landlock phải an toàn để sử dụng từ
kernel và quan điểm của các tiến trình khác.  Do đó, giao diện của Landlock phải
để lộ một bề mặt tấn công tối thiểu.

Landlock được thiết kế để có thể sử dụng được bởi các quy trình không có đặc quyền trong khi tuân theo các
chính sách bảo mật hệ thống được thực thi bởi các cơ chế kiểm soát truy cập khác (ví dụ: DAC,
LSM).  Quy tắc Landlock sẽ không can thiệp vào các biện pháp kiểm soát truy cập khác được thực thi
trên hệ thống, chỉ thêm nhiều hạn chế hơn.

Bất kỳ người dùng nào cũng có thể thực thi các bộ quy tắc Landlock trên quy trình của họ.  Chúng được hợp nhất và
được đánh giá dựa trên các tập quy tắc kế thừa theo cách đảm bảo rằng chỉ có nhiều hơn
có thể thêm các ràng buộc.

Tài liệu về không gian người dùng có thể được tìm thấy ở đây:
Tài liệu/userspace-api/landlock.rst.

Nguyên tắc hướng dẫn kiểm soát truy cập an toàn
===========================================

* Thay vào đó, quy tắc Landlock sẽ tập trung vào kiểm soát truy cập trên các đối tượng kernel
  lọc cuộc gọi tòa nhà (tức là các đối số cuộc gọi tòa nhà), đó là mục đích của
  seccomp-bpf.
* Để tránh nhiều loại tấn công kênh bên (ví dụ: rò rỉ thông tin bảo mật
  chính sách, các cuộc tấn công dựa trên CPU), các quy tắc Landlock sẽ không thể
  lập trình giao tiếp với không gian người dùng.
* Kiểm tra quyền truy cập hạt nhân sẽ không làm chậm yêu cầu truy cập từ hộp cát
  quá trình.
* Việc tính toán liên quan đến hoạt động Landlock (ví dụ: thực thi một bộ quy tắc) sẽ
  chỉ tác động đến các quy trình yêu cầu chúng.
* Tài nguyên (ví dụ: bộ mô tả tệp) được lấy trực tiếp từ kernel bởi một
  quy trình đóng hộp cát sẽ giữ lại quyền truy cập trong phạm vi của chúng (tại thời điểm tài nguyên
  mua lại) bất kỳ quá trình nào sử dụng chúng.
  Cf. ZZ0000ZZ.
* Việc từ chối truy cập sẽ được ghi lại theo hệ thống và miền Landlock
  cấu hình.  Các mục nhật ký phải chứa thông tin về nguyên nhân của sự cố.
  từ chối và chủ sở hữu của chính sách bảo mật liên quan.  Việc tạo nhật ký như vậy
  nên có hiệu suất và tác động bộ nhớ không đáng kể đối với các yêu cầu được phép.

Lựa chọn thiết kế
==============

Quyền truy cập Inode
-------------------

Tất cả các quyền truy cập được gắn với một nút và những gì có thể được truy cập thông qua nó.
Đọc nội dung của một thư mục không có nghĩa là được phép đọc
nội dung của một inode được liệt kê.  Thật vậy, tên tệp là cục bộ đối với tên tệp gốc của nó
thư mục và một inode có thể được tham chiếu bằng nhiều tên tệp nhờ
liên kết (cứng).  Khả năng hủy liên kết một tập tin chỉ có tác động trực tiếp đến
thư mục chứ không phải inode chưa được liên kết.  Đây là lý do tại sao
ZZ0000ZZ hoặc ZZ0001ZZ thì không
được phép gắn với các tập tin nhưng chỉ với các thư mục.

Quyền truy cập mô tả tập tin
-----------------------------

Quyền truy cập được kiểm tra và gắn với bộ mô tả tệp tại thời điểm mở.  các
nguyên tắc cơ bản là các chuỗi hoạt động tương đương sẽ dẫn đến
kết quả giống nhau khi chúng được thực thi trong cùng một miền Landlock.

Lấy ZZ0001ZZ làm ví dụ, nó có thể
được phép mở một tập tin để ghi mà không được phép
ZZ0000ZZ bộ mô tả tệp kết quả nếu tệp liên quan
hệ thống phân cấp không cấp quyền truy cập đó.  Các trình tự sau đây của
các hoạt động có cùng ngữ nghĩa và sau đó sẽ có cùng một kết quả:

* ZZ0000ZZ
* ZZ0001ZZ

Tương tự như các chế độ truy cập tệp (ví dụ ZZ0000ZZ), quyền truy cập Landlock
được đính kèm vào bộ mô tả tập tin sẽ được giữ lại ngay cả khi chúng được chuyển giữa
các quy trình (ví dụ: thông qua ổ cắm tên miền Unix).  Quyền truy cập như vậy sau đó sẽ được
được thực thi ngay cả khi quá trình nhận không được Landlock đóng hộp cát.  Thật vậy,
điều này là cần thiết để giữ cho các biện pháp kiểm soát truy cập nhất quán trên toàn bộ hệ thống và
điều này tránh được việc bỏ qua không được giám sát thông qua việc truyền mô tả tệp (tức là bị nhầm lẫn
phó tấn công).

.. _scoped-flags-interaction:

Tương tác giữa các cờ có phạm vi và các quyền truy cập khác
--------------------------------------------------------

Cờ ZZ0000ZZ trong &struct landlock_ruleset_attr hạn chế
sử dụng ZZ0001ZZ IPC từ miền Landlock đã tạo, trong khi chúng
cho phép tiếp cận các điểm cuối IPC ZZ0002ZZ Landlock đã tạo
miền.

Trong tương lai, các cờ có phạm vi ZZ0000ZZ sẽ tương tác với các quyền truy cập khác,
ví dụ: để các ổ cắm UNIX trừu tượng có thể được liệt kê cho phép theo tên, hoặc tương tự
các tín hiệu đó có thể được liệt kê cho phép theo số tín hiệu hoặc quy trình đích.

Khi giới thiệu ZZ0000ZZ, chúng tôi đã định nghĩa nó là
ngầm có cùng ngữ nghĩa phạm vi như một
Cờ ZZ0001ZZ sẽ có: kết nối với
Ổ cắm UNIX trong cùng một miền (trong đó
ZZ0002ZZ được sử dụng) là vô điều kiện
được phép.

Lý do là:

* Giống như các cơ chế IPC khác, kết nối với các ổ cắm UNIX có tên trong
  cùng một tên miền nên được mong đợi và vô hại.  (Nếu cần, người dùng có thể
  hoàn thiện hơn nữa các chính sách Landlock của họ với các miền lồng nhau hoặc bằng
  hạn chế ZZ0000ZZ.)
* Chúng tôi bảo lưu quyền lựa chọn vẫn giới thiệu
  ZZ0001ZZ trong tương lai.  (Điều này sẽ
  sẽ hữu ích nếu chúng tôi muốn có quy tắc Landlock để cho phép truy cập IPC
  sang các miền Landlock khác.)
* Nhưng chúng ta có thể trì hoãn thời điểm người dùng phải giải quyết
  hai cờ tương tác hiển thị trong không gian người dùng API.  (Đặc biệt,
  có thể nó sẽ không cần thiết trong thực tế, trong trường hợp đó chúng ta
  có thể tránh hoàn toàn lá cờ thứ hai.)
* Nếu chúng tôi giới thiệu ZZ0004ZZ trong
  trong tương lai, việc đặt cờ có phạm vi này trong bộ quy tắc sẽ thực hiện ZZ0005ZZ
  hạn chế, bởi vì quyền truy cập trong cùng phạm vi đã được
  được phép dựa trên ZZ0003ZZ.

Kiểm tra
=====

Kiểm tra không gian người dùng về khả năng tương thích ngược, hạn chế ptrace và hệ thống tệp
hỗ trợ có thể được tìm thấy ở đây: ZZ0000ZZ.

Cấu trúc hạt nhân
=================

Sự vật
------

.. kernel-doc:: security/landlock/object.h
    :identifiers:

Hệ thống tập tin
----------

.. kernel-doc:: security/landlock/fs.h
    :identifiers:

Xử lý thông tin xác thực
------------------

.. kernel-doc:: security/landlock/cred.h
    :identifiers:

Bộ quy tắc và tên miền
------------------

Một miền là một bộ quy tắc chỉ đọc được gắn với một tập hợp các chủ đề (tức là các nhiệm vụ)
thông tin xác thực).  Mỗi lần một bộ quy tắc được thực thi trên một tác vụ, miền hiện tại sẽ được
được sao chép và bộ quy tắc được nhập dưới dạng một lớp quy tắc mới trong
miền.  Thật vậy, khi ở trong một miền, mỗi quy tắc được gắn với một cấp độ lớp.  Đến
cấp quyền truy cập vào một đối tượng, ít nhất một quy tắc của mỗi lớp phải cho phép
yêu cầu hành động trên đối tượng.  Sau đó, một tác vụ chỉ có thể chuyển sang một miền mới
đó là giao điểm của các ràng buộc từ miền hiện tại và những ràng buộc đó
của một tập quy tắc do tác vụ cung cấp.

Định nghĩa của một chủ đề được ngầm định cho chính việc đóng hộp cát của nhiệm vụ, điều này
làm cho việc lập luận trở nên dễ dàng hơn nhiều và giúp tránh được những cạm bẫy.

.. kernel-doc:: security/landlock/ruleset.h
    :identifiers:

.. kernel-doc:: security/landlock/domain.h
    :identifiers:

Tài liệu bổ sung
========================

* Tài liệu/userspace-api/landlock.rst
* Tài liệu/admin-guide/LSM/landlock.rst
* ZZ0000ZZ

.. Links
.. _tools/testing/selftests/landlock/:
   https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/tools/testing/selftests/landlock/