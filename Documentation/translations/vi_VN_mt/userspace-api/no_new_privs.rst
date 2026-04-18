.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/userspace-api/no_new_privs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================
Không có cờ đặc quyền mới
=========================

Cuộc gọi hệ thống thực thi có thể cấp các đặc quyền của chương trình mới bắt đầu
cha mẹ của nó không có.  Các ví dụ rõ ràng nhất là setuid/setgid
các chương trình và khả năng tập tin.  Để ngăn chặn chương trình gốc
cũng đạt được những đặc quyền này, hạt nhân và mã người dùng phải được
cẩn thận để ngăn chặn phụ huynh làm bất cứ điều gì có thể phá hoại
đứa trẻ.  Ví dụ:

- Trình tải động xử lý các biến môi trường ZZ0000ZZ khác nhau nếu
   một chương trình được thiết lập.

- chroot không được phép thực hiện các tiến trình không có đặc quyền, vì nó sẽ cho phép
   ZZ0000ZZ được thay thế theo quan điểm của một quá trình
   chroot được kế thừa.

- Mã exec có cách xử lý đặc biệt dành cho ptrace.

Đây đều là các bản sửa lỗi đặc biệt.  Bit ZZ0000ZZ (kể từ Linux 3.5) là một
cơ chế chung, mới để đảm bảo an toàn cho quá trình sửa đổi nó
môi trường thực thi theo cách tồn tại xuyên suốt quá trình thực thi.  Bất kỳ nhiệm vụ
có thể đặt ZZ0001ZZ.  Khi bit được thiết lập, nó sẽ được kế thừa qua nhánh,
sao chép và thực thi và không thể bỏ đặt.  Với bộ ZZ0002ZZ, ZZ0003ZZ
hứa sẽ không trao đặc quyền để làm bất cứ điều gì mà không thể có
được thực hiện mà không có lệnh gọi execve.  Ví dụ: setuid và setgid
bit sẽ không còn thay đổi uid hoặc gid nữa; khả năng tập tin sẽ không
thêm vào tập hợp được phép và LSM sẽ không nới lỏng các ràng buộc sau
thực hiện.

Để đặt ZZ0000ZZ, hãy sử dụng::

prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0);

Tuy nhiên, hãy cẩn thận: LSM cũng có thể không thắt chặt các ràng buộc đối với việc thực thi.
ở chế độ ZZ0000ZZ.  (Điều này có nghĩa là việc thiết lập một mục đích chung
trình khởi chạy dịch vụ để thiết lập ZZ0001ZZ trước khi thực thi các trình nền có thể
can thiệp vào hộp cát dựa trên LSM.)

Lưu ý rằng ZZ0000ZZ không ngăn chặn những thay đổi đặc quyền không
liên quan đến ZZ0001ZZ.  Một tác vụ có đặc quyền phù hợp vẫn có thể gọi
ZZ0002ZZ và nhận datagram SCM_RIGHTS.

Cho đến nay, có hai trường hợp sử dụng chính cho ZZ0000ZZ:

- Các bộ lọc được cài đặt cho sandbox seccomp mode 2 vẫn tồn tại
   execve và có thể thay đổi hành vi của các chương trình mới được thực thi.
   Do đó, người dùng không có đặc quyền chỉ được phép cài đặt các bộ lọc như vậy
   nếu ZZ0000ZZ được đặt.

- Bản thân ZZ0000ZZ có thể được sử dụng để giảm bề mặt tấn công
   có sẵn cho người dùng không có đặc quyền.  Nếu mọi thứ chạy với
   uid đã cho đã được đặt ZZ0001ZZ thì uid đó sẽ không thể
   leo thang đặc quyền của nó bằng cách tấn công trực tiếp setuid, setgid và
   nhị phân sử dụng fcap; nó sẽ cần phải thỏa hiệp một cái gì đó mà không có
   Bit ZZ0002ZZ được đặt đầu tiên.

Trong tương lai, các tính năng hạt nhân tiềm ẩn nguy hiểm khác có thể trở thành
có sẵn cho các tác vụ không có đặc quyền nếu ZZ0000ZZ được đặt.  Về nguyên tắc,
một số tùy chọn cho ZZ0001ZZ và ZZ0002ZZ sẽ an toàn khi
ZZ0003ZZ được thiết lập và ZZ0004ZZ + ZZ0005ZZ thấp hơn đáng kể
nguy hiểm hơn chroot.
