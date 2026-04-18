.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/syscall-user-dispatch.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Gửi người dùng Syscall
=======================

Lý lịch
----------

Các lớp tương thích như Wine cần một cách để mô phỏng hệ thống một cách hiệu quả
chỉ gọi một phần quy trình của họ - phần có
mã không tương thích - trong khi có thể thực thi các cuộc gọi tổng hợp gốc mà không cần
một hình phạt hiệu suất cao đối với phần gốc của quy trình.  Seccomp
không thực hiện được nhiệm vụ này vì nó có sự hỗ trợ hạn chế để thực hiện một cách hiệu quả
lọc các cuộc gọi tòa nhà dựa trên vùng bộ nhớ và nó không hỗ trợ loại bỏ
bộ lọc.  Vì vậy cần có một cơ chế mới.

Syscall User Dispatch mang đến tính năng lọc của bộ điều phối syscall
địa chỉ trở lại không gian người dùng.  Ứng dụng này đang kiểm soát một lượt lật
switch, cho biết tính chất hiện tại của quá trình.  A
ứng dụng đa nhân cách sau đó có thể bật công tắc mà không cần
gọi kernel khi vượt qua lớp tương thích API
ranh giới, để bật/tắt chuyển hướng cuộc gọi tòa nhà và thực thi
trực tiếp các cuộc gọi chung (đã bị vô hiệu hóa) hoặc gửi chúng để mô phỏng trong không gian người dùng
thông qua SIGSYS.

Mục tiêu của thiết kế này là cung cấp lớp tương thích rất nhanh
vượt qua ranh giới, đạt được bằng cách không thực hiện một cuộc gọi hệ thống để thay đổi
cá tính mỗi khi lớp tương thích thực thi.  Thay vào đó, một
Vùng bộ nhớ không gian người dùng tiếp xúc với kernel cho biết hiện tại
tính cách và ứng dụng chỉ cần sửa đổi biến đó thành
cấu hình cơ chế.

Có một chi phí tương đối cao liên quan đến việc xử lý tín hiệu trên hầu hết
kiến trúc, như x86, nhưng ít nhất là đối với Wine, các tòa nhà được phát hành bởi
Mã Windows gốc hiện không được coi là vấn đề về hiệu năng,
vì chúng khá hiếm, ít nhất là đối với các ứng dụng chơi game hiện đại.

Vì cơ chế này được thiết kế để nắm bắt các cuộc gọi tòa nhà do
các ứng dụng không phải bản địa, nó phải hoạt động trên các tòa nhà cao tầng có lệnh gọi
ABI hoàn toàn bất ngờ đối với Linux.  Do đó, việc gửi người dùng Syscall
không dựa vào bất kỳ syscall ABI nào để thực hiện lọc.  Nó sử dụng
chỉ có địa chỉ người điều phối cuộc gọi tòa nhà và khóa vùng người dùng.

Vì Linux không biết ABI của các tòa nhà bị chặn này nên Linux
syscalls không thể đo được thông qua ptrace hoặc tracepoints syscall.

Giao diện
---------

Một luồng có thể thiết lập cơ chế này trên các hạt nhân được hỗ trợ bằng cách thực thi lệnh
thực hành sau:

prctl(PR_SET_SYSCALL_USER_DISPATCH, <op>, <offset>, <length>, [bộ chọn])

<op> là PR_SYS_DISPATCH_EXCLUSIVE_ON/PR_SYS_DISPATCH_INCLUSIVE_ON
hoặc PR_SYS_DISPATCH_OFF, để bật và tắt cơ chế trên toàn cầu cho
sợi chỉ đó.  Khi sử dụng PR_SYS_DISPATCH_OFF, các trường khác phải bằng 0.

Đối với ranh giới PR_SYS_DISPATCH_EXCLUSIVE_ON [<offset>, <offset>+<length>)
một khoảng vùng bộ nhớ mà từ đó các cuộc gọi hệ thống luôn được thực thi trực tiếp,
bất kể bộ chọn không gian người dùng.  Điều này cung cấp một con đường nhanh chóng cho
Thư viện C, bao gồm các bộ điều phối cuộc gọi chung phổ biến nhất trong ngôn ngữ gốc
ứng dụng mã và cũng cung cấp cách để bộ xử lý tín hiệu trả về
mà không kích hoạt SIGSYS lồng nhau trên (rt\_)sigreturn.  Người dùng này
giao diện phải đảm bảo rằng ít nhất mã tấm bạt lò xo tín hiệu là
được đưa vào khu vực này. Ngoài ra, đối với các cuộc gọi hệ thống thực hiện
mã tấm bạt lò xo trên vDSO, tấm bạt lò xo đó không bao giờ bị chặn.

Đối với ranh giới PR_SYS_DISPATCH_INCLUSIVE_ON [<offset>, <offset>+<length>)
một khoảng vùng bộ nhớ mà từ đó các cuộc gọi tòa nhà được gửi đi dựa trên
bộ chọn không gian người dùng. Các cuộc gọi từ bên ngoài phạm vi luôn
được thực hiện trực tiếp.

[selector] là một con trỏ tới vùng có kích thước char trong bộ nhớ tiến trình
khu vực, cung cấp một cách nhanh chóng để kích hoạt tính năng vô hiệu hóa chuyển hướng cuộc gọi tòa nhà
toàn luồng mà không cần gọi trực tiếp kernel.  bộ chọn
có thể được đặt thành SYSCALL_DISPATCH_FILTER_ALLOW hoặc SYSCALL_DISPATCH_FILTER_BLOCK.
Bất kỳ giá trị nào khác sẽ kết thúc chương trình bằng SIGSYS.

Ngoài ra, cấu hình gửi người dùng tòa nhà có thể được xem qua
và chọc qua ptrace PTRACE_(GET|SET)_SYSCALL_USER_DISPATCH_CONFIG
yêu cầu. Điều này rất hữu ích cho phần mềm điểm kiểm tra/khởi động lại.

Ghi chú bảo mật
---------------

Syscall User Dispatch cung cấp chức năng cho các lớp tương thích để
nhanh chóng nắm bắt các cuộc gọi hệ thống được thực hiện bởi một phần không phải bản địa của
ứng dụng, trong khi không ảnh hưởng đến các vùng gốc Linux của
quá trình.  Nó không phải là một cơ chế cho các cuộc gọi hệ thống hộp cát và nó
không nên được coi là một cơ chế bảo mật vì nó không quan trọng đối với một
ứng dụng độc hại nhằm phá hoại cơ chế bằng cách chuyển sang một ứng dụng được phép
khu vực điều phối trước khi thực hiện cuộc gọi hệ thống hoặc để khám phá
địa chỉ và sửa đổi giá trị bộ chọn.  Nếu trường hợp sử dụng yêu cầu bất kỳ
loại hộp cát bảo mật, thay vào đó nên sử dụng Seccomp.

Bất kỳ phân nhánh hoặc thực thi nào của quy trình hiện tại sẽ đặt lại cơ chế thành
PR_SYS_DISPATCH_OFF.