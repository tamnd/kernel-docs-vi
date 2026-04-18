.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/syscall64-abi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================================
Hệ thống Linux 64-bit Kiến trúc điện gọi ABI
===============================================

cuộc gọi chung
=======

Lời mời
----------
Tòa nhà được tạo bằng lệnh sc và trả về khi thực thi
tiếp tục theo hướng dẫn sau hướng dẫn sc.

Nếu PPC_FEATURE2_SCV xuất hiện trong vectơ phụ AT_HWCAP2 ELF, thì
Lệnh scv 0 là một giải pháp thay thế có thể mang lại hiệu suất tốt hơn,
với một số khác biệt về trình tự gọi.

trình tự gọi syscall\ [1]_ khớp với Power Architecture 64-bit ELF ABI
trình tự gọi hàm đặc tả C, bao gồm cả việc bảo quản thanh ghi
quy tắc, với những khác biệt sau đây.

.. [1] Some syscalls (typically low-level management functions) may have
       different calling sequences (e.g., rt_sigreturn).

Thông số
----------
Số cuộc gọi hệ thống được chỉ định trong r0.

Có tối đa 6 tham số nguyên cho một tòa nhà cao tầng, được truyền trong r3-r8.

Giá trị trả về
------------
- Đối với lệnh sc, cả giá trị và điều kiện lỗi đều được trả về.
  cr0.SO là tình trạng lỗi và r3 là giá trị trả về. Khi cr0.SO là
  rõ ràng, syscall đã thành công và r3 là giá trị trả về. Khi cr0.SO được đặt,
  cuộc gọi tòa nhà không thành công và r3 là giá trị lỗi (thường tương ứng với
  không có).

- Đối với lệnh scv 0, giá trị trả về biểu thị lỗi nếu nó bị lỗi
  -4095..-1 (tức là >= -MAX_ERRNO (-4095) dưới dạng so sánh không dấu),
  trong trường hợp đó giá trị lỗi là giá trị trả về phủ định.

ngăn xếp
-----
Cuộc gọi hệ thống không sửa đổi khung ngăn xếp của người gọi. Ví dụ: người gọi
Các trường lưu khung LR và CR không được sử dụng.

Đăng ký quy định bảo quản
---------------------------
Quy tắc bảo quản đăng ký khớp với trình tự gọi ELF ABI với một số
sự khác biệt.

Đối với lệnh sc, sự khác biệt so với ELF ABI như sau:

+--------------+----------------------+----------------------------------------+
Quy tắc bảo quản ZZ0000ZZ ZZ0001ZZ
+=========================================================================================================================
ZZ0002ZZ ZZ0003ZZ dễ bay hơi
+--------------+----------------------+----------------------------------------+
ZZ0004ZZ ZZ0005ZZ dễ bay hơi
+--------------+----------------------+----------------------------------------+
ZZ0006ZZ ZZ0007ZZ dễ bay hơi
+--------------+----------------------+----------------------------------------+
ZZ0008ZZ ZZ0009ZZ dễ bay hơi
+--------------+----------------------+----------------------------------------+
ZZ0010ZZ ZZ0011ZZ không biến đổi
+--------------+----------------------+----------------------------------------+
ZZ0012ZZ ZZ0013ZZ không biến đổi
+--------------+----------------------+----------------------------------------+

Đối với lệnh scv 0, sự khác biệt so với ELF ABI như sau:

+--------------+----------------------+----------------------------------------+
Quy tắc bảo quản ZZ0000ZZ ZZ0001ZZ
+=========================================================================================================================
ZZ0002ZZ ZZ0003ZZ dễ bay hơi
+--------------+----------------------+----------------------------------------+
ZZ0004ZZ ZZ0005ZZ dễ bay hơi
+--------------+----------------------+----------------------------------------+
ZZ0006ZZ ZZ0007ZZ dễ bay hơi
+--------------+----------------------+----------------------------------------+

Tất cả các thanh ghi dữ liệu dấu phẩy động và vectơ cũng như điều khiển và trạng thái
các thanh ghi là không biến đổi.

Bộ nhớ giao dịch
--------------------
Hành vi của hệ thống có thể thay đổi nếu bộ xử lý đang giao dịch hoặc bị treo
trạng thái giao dịch và syscall có thể ảnh hưởng đến hoạt động của giao dịch.

Nếu bộ xử lý ở trạng thái treo khi một cuộc gọi hệ thống được thực hiện, thì cuộc gọi hệ thống
sẽ được thực hiện như bình thường và sẽ trở lại như bình thường. Cuộc gọi chung sẽ là
được thực hiện ở trạng thái lơ lửng nên tác dụng phụ của nó sẽ dai dẳng theo
với ngữ nghĩa bộ nhớ giao dịch thông thường. Một cuộc gọi hệ thống có thể dẫn đến hoặc không
trong giao dịch bị hủy hoại bởi phần cứng.

Nếu bộ xử lý ở trạng thái giao dịch khi một cuộc gọi hệ thống được thực hiện thì
hành vi phụ thuộc vào sự hiện diện của PPC_FEATURE2_HTM_NOSC trong AT_HWCAP2 ELF
vectơ phụ trợ.

- Nếu có, đó là trường hợp của các hạt nhân mới hơn thì syscall sẽ không
  được thực hiện và giao dịch sẽ bị hủy bỏ bởi kernel với
  mã lỗi TM_CAUSE_SYSCALL | TM_CAUSE_PERSISTENT trong TEXASR SPR.

- Nếu không có (hạt nhân cũ hơn) thì hạt nhân sẽ tạm dừng
  trạng thái giao dịch và syscall sẽ tiến hành như trong trường hợp
  syscall trạng thái bị đình chỉ và sẽ tiếp tục trạng thái giao dịch trước khi
  quay lại với người gọi. Trường hợp này không được xác định hoặc hỗ trợ rõ ràng, vì vậy trường hợp này
  hành vi không nên dựa vào.

các tòa nhà chọc trời scv 0 sẽ luôn hoạt động như PPC_FEATURE2_HTM_NOSC.

ptrace
------
Khi hệ thống ptracing gọi (PTRACE_SYSCALL), giá trị pt_regs.trap chứa
kiểu cuộc gọi hệ thống có thể được sử dụng để phân biệt giữa sc và scv 0
các cuộc gọi hệ thống và các quy ước đăng ký khác nhau có thể được tính đến.

Nếu giá trị của (pt_regs.trap & 0xfff0) là 0xc00 thì lệnh gọi hệ thống là
được thực hiện bằng lệnh sc, nếu là 0x3000 thì lệnh gọi hệ thống là
thực hiện với lệnh scv 0.

vsyscall
========

Trình tự gọi vsyscall khớp với trình tự gọi syscall, với
những khác biệt sau đây. Một số vsyscalls có thể có trình tự gọi khác nhau.

Tham số và giá trị trả về
---------------------------
r0 không được sử dụng làm đầu vào. Vsyscall được chọn theo địa chỉ của nó.

ngăn xếp
-----
Vsyscall có thể hoặc không thể sử dụng vùng lưu khung ngăn xếp của người gọi.

Đăng ký quy định bảo quản
---------------------------

====================
r0 Dễ bay hơi
cr1, cr5-7 Dễ bay hơi
lr Dễ bay hơi
====================

Lời mời
----------
Vsyscall được thực hiện với lệnh rẽ nhánh có liên kết tới vsyscall
địa chỉ chức năng

Bộ nhớ giao dịch
--------------------
vsyscalls sẽ chạy ở trạng thái giao dịch giống như người gọi. Một cuộc gọi vsyscall
có thể có hoặc không dẫn đến việc giao dịch bị phần cứng thực hiện.
