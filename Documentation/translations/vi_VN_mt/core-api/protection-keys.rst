.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/protection-keys.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================
Phím bảo vệ bộ nhớ
======================

Khóa bảo vệ bộ nhớ cung cấp cơ chế thực thi dựa trên trang
các biện pháp bảo vệ mà không yêu cầu sửa đổi bảng trang khi
ứng dụng thay đổi miền bảo vệ.

Không gian người dùng Pkeys (PKU) là một tính năng có thể tìm thấy trên:
        * CPU máy chủ Intel, Skylake trở lên
        * CPU máy khách Intel, Tiger Lake (Lõi thế hệ thứ 11) trở lên
        * CPU AMD trong tương lai
        * CPU arm64 triển khai Tiện ích mở rộng lớp phủ quyền (FEAT_S1POE)

x86_64
======
Pkey hoạt động bằng cách dành 4 bit dành riêng trước đó trong mỗi mục của bảng trang cho
một "chìa khóa bảo vệ", cung cấp 16 khóa có thể.

Các biện pháp bảo vệ cho mỗi khóa được xác định bằng một thanh ghi người dùng có thể truy cập trên mỗi CPU
(PKRU).  Mỗi cái trong số này là một thanh ghi 32 bit lưu trữ hai bit (Tắt truy cập
và Tắt ghi) cho mỗi phím trong số 16 phím.

Là một thanh ghi CPU, PKRU vốn có tính chất luồng cục bộ, có khả năng cung cấp cho mỗi
xâu chuỗi một bộ bảo vệ khác với mọi luồng khác.

Có hai hướng dẫn (RDPKRU/WRPKRU) để đọc và ghi vào
đăng ký.  Tính năng này chỉ khả dụng ở chế độ 64-bit, mặc dù có
về mặt lý thuyết là không gian trong PAE PTE.  Các quyền này được thực thi trên dữ liệu
chỉ truy cập và không ảnh hưởng đến việc tìm nạp lệnh.

cánh tay64
=====

Pkey sử dụng 3 bit trong mỗi mục trong bảng trang để mã hóa "chỉ mục khóa bảo vệ",
đưa ra 8 chìa khóa có thể.

Các biện pháp bảo vệ cho mỗi khóa được xác định bằng hệ thống người dùng có thể ghi trên mỗi CPU
đăng ký (POR_EL0).  Đây là mã hóa thanh ghi 64 bit đọc, ghi và thực thi
quyền che phủ cho từng chỉ mục khóa bảo vệ.

Là một thanh ghi CPU, POR_EL0 vốn có tính chất luồng cục bộ, có khả năng cung cấp
mỗi luồng có một bộ bảo vệ khác nhau với mọi luồng khác.

Không giống như x86_64, các quyền của khóa bảo vệ cũng áp dụng cho lệnh
tìm nạp.

tòa nhà chọc trời
========

Có 3 lệnh gọi hệ thống tương tác trực tiếp với pkey::

int pkey_alloc(cờ dài không dấu, init_access_rights dài không dấu)
	int pkey_free(int pkey);
	int pkey_mprotect(bắt đầu dài không dấu, size_t len,
			  prot dài không dấu, int pkey);

Trước khi có thể sử dụng pkey, trước tiên nó phải được cấp phát bằng pkey_alloc().  Một
ứng dụng ghi trực tiếp vào kiến trúc CPU cụ thể theo thứ tự
để thay đổi quyền truy cập vào bộ nhớ được bao phủ bởi một phím.  Trong ví dụ này
cái này được bao bọc bởi một hàm C có tên là pkey_set().
::

int real_prot = PROT_READ|PROT_WRITE;
	pkey = pkey_alloc(0, PKEY_DISABLE_WRITE);
	ptr = mmap(NULL, PAGE_SIZE, PROT_NONE, MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
	ret = pkey_mprotect(ptr, PAGE_SIZE, real_prot, pkey);
	... application runs here

Bây giờ, nếu ứng dụng cần cập nhật dữ liệu tại 'ptr', nó có thể
giành quyền truy cập, thực hiện cập nhật, sau đó xóa quyền ghi của nó ::

pkey_set(pkey, 0); // xóa PKEY_DISABLE_WRITE
	*ptr = foo; // gán cái gì đó
	pkey_set(pkey, PKEY_DISABLE_WRITE); // đặt lại PKEY_DISABLE_WRITE

Bây giờ khi nó giải phóng bộ nhớ, nó cũng sẽ giải phóng pkey vì nó
không còn được sử dụng nữa::

munmap(ptr, PAGE_SIZE);
	pkey_free(pkey);

.. note:: pkey_set() is a wrapper around writing to the CPU register.
          Example implementations can be found in
          tools/testing/selftests/mm/pkey-{arm64,powerpc,x86}.h

Hành vi
========

Hạt nhân cố gắng tạo ra các khóa bảo vệ nhất quán với
hành vi của một mprotect() đơn giản.  Ví dụ: nếu bạn làm điều này ::

mprotect(ptr, kích thước, PROT_NONE);
	cái gì đó(ptr);

bạn có thể mong đợi những hiệu ứng tương tự với các khóa bảo vệ khi thực hiện việc này::

pkey = pkey_alloc(0, PKEY_DISABLE_WRITE | PKEY_DISABLE_READ);
	pkey_mprotect(ptr, kích thước, PROT_READ|PROT_WRITE, pkey);
	cái gì đó(ptr);

Điều đó đúng cho dù something() có truy cập trực tiếp vào 'ptr' hay không
thích::

*ptr = foo;

hoặc khi kernel thực hiện quyền truy cập thay mặt ứng dụng như
với một lần đọc()::

đọc(fd, ptr, 1);

Hạt nhân sẽ gửi SIGSEGV trong cả hai trường hợp, nhưng si_code sẽ được đặt
tới SEGV_PKERR khi vi phạm các khóa bảo vệ so với SEGV_ACCERR khi
các quyền mprotect() đơn giản bị vi phạm.

Lưu ý rằng việc truy cập kernel từ kthread (chẳng hạn như io_uring) sẽ sử dụng mặc định
giá trị cho thanh ghi khóa bảo vệ và do đó sẽ không nhất quán với
giá trị vùng người dùng của thanh ghi hoặc mprotect().