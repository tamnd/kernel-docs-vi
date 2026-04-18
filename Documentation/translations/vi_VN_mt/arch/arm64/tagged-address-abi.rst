.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm64/tagged-address-abi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
AArch64 TAGGED ADDRESS ABI
=============================

Tác giả: Vincenzo Frascino <vincenzo.frascino@arm.com>
         Bến du thuyền Catalin <catalin.marinas@arm.com>

Ngày: 21 tháng 8 năm 2019

Tài liệu này mô tả cách sử dụng và ngữ nghĩa của Địa chỉ được gắn thẻ
ABI trên AArch64 Linux.

1. Giới thiệu
---------------

Trên AArch64, bit ZZ0000ZZ được đặt theo mặc định, cho phép
không gian người dùng (EL0) để thực hiện truy cập bộ nhớ thông qua con trỏ 64-bit với
một byte trên cùng khác 0. Tài liệu này mô tả sự thư giãn của
syscall ABI cho phép không gian người dùng chuyển các con trỏ được gắn thẻ nhất định tới
các cuộc gọi hệ thống kernel.

2. Địa chỉ được gắn thẻ AArch64 ABI
-----------------------------

Từ góc độ giao diện tòa nhà hạt nhân và cho các mục đích
tài liệu này, "con trỏ được gắn thẻ hợp lệ" là một con trỏ có khả năng
byte trên cùng khác 0 tham chiếu đến một địa chỉ trong địa chỉ tiến trình của người dùng
không gian thu được bằng một trong những cách sau:

- Tòa nhà cao tầng ZZ0000ZZ trong đó:

- cờ có tập bit ZZ0000ZZ hoặc
  - bộ mô tả tập tin đề cập đến một tập tin thông thường (bao gồm cả những tập tin
    được trả về bởi ZZ0001ZZ) hoặc ZZ0002ZZ

- Tòa nhà ZZ0000ZZ (tức là vùng heap giữa vị trí ban đầu của
  chương trình bị ngắt khi tạo tiến trình và vị trí hiện tại của nó).

- bất kỳ bộ nhớ nào được ánh xạ bởi kernel trong không gian địa chỉ của tiến trình
  trong quá trình tạo và có các hạn chế tương tự như đối với ZZ0000ZZ ở trên
  (ví dụ: dữ liệu, bss, ngăn xếp).

Địa chỉ được gắn thẻ AArch64 ABI có hai giai đoạn thư giãn tùy thuộc vào
cách hạt nhân sử dụng địa chỉ người dùng:

1. Địa chỉ người dùng không được kernel truy cập nhưng được sử dụng cho không gian địa chỉ
   quản lý (ví dụ ZZ0000ZZ, ZZ0001ZZ). Việc sử dụng hợp lệ
   con trỏ được gắn thẻ trong ngữ cảnh này được cho phép với các ngoại lệ sau:

- Đối số ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ cho
     ZZ0003ZZ vì chúng có khả năng đặt bí danh với các
     địa chỉ người dùng.

NOTE: Hành vi này đã thay đổi trong v5.6 và do đó một số hạt nhân trước đó có thể
     chấp nhận không chính xác các con trỏ được gắn thẻ hợp lệ cho ZZ0000ZZ,
     Cuộc gọi hệ thống ZZ0001ZZ và ZZ0002ZZ.

- Các đối số ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ cho
     ZZ0003ZZ ``ioctl()`` được sử dụng trên bộ mô tả tệp thu được từ
     ZZ0005ZZ, dưới dạng địa chỉ lỗi sau đó thu được bằng cách đọc
     bộ mô tả tập tin sẽ không được gắn thẻ, điều này có thể gây nhầm lẫn
     chương trình không nhận biết thẻ.

NOTE: Hành vi này đã thay đổi trong v5.14 và do đó một số hạt nhân trước đó có thể
     chấp nhận không chính xác các con trỏ được gắn thẻ hợp lệ cho lệnh gọi hệ thống này.

2. Địa chỉ người dùng được hạt nhân truy cập (ví dụ: ZZ0000ZZ). ABI này
   thư giãn bị tắt theo mặc định và luồng ứng dụng cần phải
   kích hoạt nó một cách rõ ràng thông qua ZZ0001ZZ như sau:

- ZZ0000ZZ: bật hoặc tắt AArch64 Tagged
     Địa chỉ ABI cho chuỗi cuộc gọi.

Đối số ZZ0000ZZ là một mặt nạ bit mô tả
     chế độ điều khiển được sử dụng:

- ZZ0000ZZ: bật Địa chỉ được gắn thẻ AArch64 ABI.
       Trạng thái mặc định bị tắt.

Các đối số ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ phải bằng 0.

- ZZ0000ZZ: lấy trạng thái của AArch64 Tagged
     Địa chỉ ABI cho chuỗi cuộc gọi.

Các đối số ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ và ZZ0003ZZ phải bằng 0.

Các thuộc tính ABI được mô tả ở trên nằm trong phạm vi luồng, được kế thừa trên
   clone() và fork() và bị xóa trên exec().

Gọi ZZ0000ZZ
   trả về ZZ0001ZZ nếu Địa chỉ ABI được gắn thẻ AArch64 trên toàn cầu
   bị vô hiệu hóa bởi ZZ0002ZZ. Mặc định
   Cấu hình ZZ0003ZZ là 0.

Khi Địa chỉ được gắn thẻ AArch64 ABI được bật cho một chuỗi,
đảm bảo các hành vi sau:

- Tất cả các syscall ngoại trừ các trường hợp nêu ở phần 3 đều có thể chấp nhận bất kỳ
  con trỏ được gắn thẻ hợp lệ.

- Hành vi của cuộc gọi tòa nhà không được xác định đối với các con trỏ được gắn thẻ không hợp lệ: nó có thể
  dẫn đến mã lỗi được trả về, tín hiệu (nghiêm trọng) được nâng lên,
  hoặc các dạng hư hỏng khác.

- Hành vi của syscall đối với một con trỏ được gắn thẻ hợp lệ cũng giống như đối với
  con trỏ không được gắn thẻ tương ứng.


Có thể tìm thấy định nghĩa về ý nghĩa của các con trỏ được gắn thẻ trên AArch64
trong Tài liệu/arch/arm64/tagged-pointers.rst.

3. Địa chỉ được gắn thẻ AArch64 ABI Ngoại lệ
-----------------------------------------

Các tham số cuộc gọi hệ thống sau đây phải được bỏ gắn thẻ bất kể
Thư giãn ABI:

- ZZ0000ZZ không phải là con trỏ tới dữ liệu người dùng được truyền trực tiếp hoặc
  gián tiếp làm đối số được hạt nhân truy cập.

- ZZ0000ZZ không phải là con trỏ tới dữ liệu người dùng được truyền trực tiếp hoặc
  gián tiếp làm đối số được hạt nhân truy cập.

- ZZ0000ZZ và ZZ0001ZZ.

- ZZ0000ZZ (kể từ kernel v5.6).

- ZZ0000ZZ (kể từ kernel v5.6).

- ZZ0000ZZ, đối số ZZ0001ZZ (kể từ kernel v5.6).

Mọi nỗ lực sử dụng con trỏ được gắn thẻ khác 0 đều có thể dẫn đến mã lỗi
được trả về, tín hiệu (gây tử vong) được nâng lên hoặc các chế độ khác của
thất bại.

4. Ví dụ về cách sử dụng đúng
---------------------------
.. code-block:: c

   #include <stdlib.h>
   #include <string.h>
   #include <unistd.h>
   #include <sys/mman.h>
   #include <sys/prctl.h>
   
   #define PR_SET_TAGGED_ADDR_CTRL	55
   #define PR_TAGGED_ADDR_ENABLE	(1UL << 0)
   
   #define TAG_SHIFT		56
   
   int main(void)
   {
   	int tbi_enabled = 0;
   	unsigned long tag = 0;
   	char *ptr;
   
   	/* check/enable the tagged address ABI */
   	if (!prctl(PR_SET_TAGGED_ADDR_CTRL, PR_TAGGED_ADDR_ENABLE, 0, 0, 0))
   		tbi_enabled = 1;
   
   	/* memory allocation */
   	ptr = mmap(NULL, sysconf(_SC_PAGE_SIZE), PROT_READ | PROT_WRITE,
   		   MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
   	if (ptr == MAP_FAILED)
   		return 1;
   
   	/* set a non-zero tag if the ABI is available */
   	if (tbi_enabled)
   		tag = rand() & 0xff;
   	ptr = (char *)((unsigned long)ptr | (tag << TAG_SHIFT));
   
   	/* memory access to a tagged address */
   	strcpy(ptr, "tagged pointer\n");
   
   	/* syscall with a tagged pointer */
   	write(1, ptr, strlen(ptr));
   
   	return 0;
   }
