.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/x86_64/fsgs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Sử dụng phân đoạn FS và GS trong các ứng dụng không gian người dùng
===================================================

Kiến trúc x86 hỗ trợ phân đoạn. Hướng dẫn truy cập
bộ nhớ có thể sử dụng chế độ đánh địa chỉ dựa trên thanh ghi phân đoạn. Sau đây
ký hiệu được sử dụng để đánh địa chỉ một byte trong một phân đoạn:

Đăng ký phân đoạn: Địa chỉ byte

Địa chỉ cơ sở của phân đoạn được thêm vào địa chỉ Byte để tính toán
kết quả là địa chỉ ảo được truy cập. Điều này cho phép truy cập nhiều
các trường hợp dữ liệu có cùng địa chỉ Byte, tức là cùng một mã. các
việc lựa chọn một trường hợp cụ thể hoàn toàn dựa trên địa chỉ cơ sở trong
thanh ghi phân đoạn.

Ở chế độ 32-bit, CPU cung cấp 6 phân đoạn, cũng hỗ trợ phân đoạn
giới hạn. Các giới hạn có thể được sử dụng để thực thi các biện pháp bảo vệ không gian địa chỉ.

Ở chế độ 64-bit, các phân đoạn CS/SS/DS/ES bị bỏ qua và địa chỉ cơ sở là
luôn bằng 0 để cung cấp không gian địa chỉ 64 bit đầy đủ. Các phân đoạn FS và GS là
vẫn hoạt động ở chế độ 64-bit.

Cách sử dụng FS và GS phổ biến
------------------------------

Phân đoạn FS thường được sử dụng để đánh địa chỉ Bộ nhớ cục bộ luồng (TLS). FS
thường được quản lý bằng mã thời gian chạy hoặc thư viện luồng. Biến
được khai báo bằng bộ xác định lớp lưu trữ '__thread' được khởi tạo theo
luồng và trình biên dịch phát ra tiền tố địa chỉ FS: để truy cập vào các luồng này
các biến. Mỗi luồng có địa chỉ cơ sở FS riêng nên mã chung có thể được
được sử dụng mà không cần tính toán bù địa chỉ phức tạp để truy cập vào mỗi luồng
trường hợp. Các ứng dụng không nên sử dụng FS cho các mục đích khác khi chúng sử dụng
thời gian chạy hoặc thư viện luồng quản lý FS trên mỗi luồng.

Phân đoạn GS không có mục đích sử dụng chung và có thể được sử dụng tự do bởi
ứng dụng. GCC và Clang hỗ trợ đánh địa chỉ dựa trên GS thông qua không gian địa chỉ
số nhận dạng.

Đọc và ghi địa chỉ cơ sở FS/GS
------------------------------------------

Tồn tại hai cơ chế để đọc và ghi địa chỉ cơ sở FS/GS:

- lệnh gọi hệ thống Arch_prctl()

- họ lệnh FSGSBASE

Truy cập cơ sở FS/GS bằng Arch_prctl()
--------------------------------------

Cơ chế dựa trên Arch_prctl(2) có sẵn trên tất cả các CPU 64-bit và tất cả
 các phiên bản hạt nhân.

Đọc cơ sở:

Arch_prctl(ARCH_GET_FS, &fsbase);
   Arch_prctl(ARCH_GET_GS, &gsbase);

Viết cơ sở:

Arch_prctl(ARCH_SET_FS, fsbase);
   Arch_prctl(ARCH_SET_GS, gsbase);

ARCH_SET_GS prctl có thể bị tắt tùy thuộc vào cấu hình kernel
 và cài đặt bảo mật.

Truy cập cơ sở FS/GS bằng lệnh FSGSBASE
---------------------------------------------------

Với thế hệ Ivy Bridge CPU, Intel đã giới thiệu một bộ chip mới
 hướng dẫn truy cập vào các thanh ghi cơ sở FS và GS trực tiếp từ người dùng
 không gian. Các hướng dẫn này cũng được hỗ trợ trên CPU AMD Family 17H. các
 có sẵn các hướng dẫn sau:

==============================================
  RDFSBASE %reg Đọc thanh ghi cơ sở FS
  RDGSBASE %reg Đọc thanh ghi cơ sở GS
  WRFSBASE %reg Viết thanh ghi cơ sở FS
  WRGSBASE %reg Viết thanh ghi cơ sở GS
  ==============================================

Các hướng dẫn tránh chi phí chung của tòa nhà Arch_prctl() và cho phép
 cách sử dụng linh hoạt hơn các chế độ đánh địa chỉ FS/GS trong không gian người dùng
 ứng dụng. Điều này không ngăn ngừa xung đột giữa các thư viện luồng
 và thời gian chạy sử dụng FS và các ứng dụng muốn sử dụng nó cho
 mục đích riêng của họ.

Kích hoạt hướng dẫn FSGSBASE
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Các hướng dẫn được liệt kê trong CPUID lá 7, bit 0 của EBX. Nếu
 có sẵn /proc/cpuinfo hiển thị 'fsgsbase' trong mục nhập cờ của CPU.

Sự sẵn có của các hướng dẫn không cho phép họ
 tự động. Kernel phải kích hoạt chúng một cách rõ ràng trong CR4. các
 lý do cho điều này là các hạt nhân cũ hơn đưa ra các giả định về các giá trị trong
 đăng ký GS và thực thi chúng khi cơ sở GS được thiết lập thông qua
 Arch_prctl(). Cho phép không gian người dùng ghi các giá trị tùy ý vào cơ sở GS
 sẽ vi phạm những giả định này và gây ra sự cố.

Trên các hạt nhân không kích hoạt FSGSBASE, việc thực thi FSGSBASE
 hướng dẫn sẽ bị lỗi với ngoại lệ #UD.

Hạt nhân cung cấp thông tin đáng tin cậy về trạng thái được kích hoạt trong
 Vectơ ELF AUX. Nếu bit HWCAP2_FSGSBASE được đặt trong vectơ AUX, thì
 kernel đã kích hoạt các lệnh FSGSBASE và các ứng dụng có thể sử dụng chúng.
 Ví dụ về mã sau đây cho thấy cách phát hiện này hoạt động::

#include <sys/auxv.h>
   #include <elf.h>

/* Cuối cùng sẽ có trong asm/hwcap.h */
   #ifndef HWCAP2_FSGSBASE
   #define HWCAP2_FSGSBASE (1 << 1)
   #endif

   ....

giá trị không dấu = getauxval(AT_HWCAP2);

nếu (val & HWCAP2_FSGSBASE)
        printf("Đã bật FSGSBASE\n");

Hỗ trợ trình biên dịch hướng dẫn FSGSBASE
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

GCC phiên bản 4.6.4 và mới hơn cung cấp nội dung cơ bản cho FSGSBASE
hướng dẫn. Clang 5 cũng hỗ trợ họ.

==================================================
  _readfsbase_u64() Đọc thanh ghi cơ sở FS
  _readgsbase_u64() Đọc thanh ghi cơ sở GS
  _writefsbase_u64() Viết thanh ghi cơ sở FS
  _writegsbase_u64() Viết thanh ghi cơ sở GS
  ==================================================

Để sử dụng các nội tại này <immintrin.h> phải được đưa vào nguồn
mã và tùy chọn trình biên dịch -mfsgsbase phải được thêm vào.

Hỗ trợ trình biên dịch cho việc đánh địa chỉ dựa trên FS/GS
-------------------------------------------

GCC phiên bản 6 và mới hơn cung cấp hỗ trợ cho việc đánh địa chỉ dựa trên FS/GS thông qua
Không gian địa chỉ được đặt tên. GCC triển khai không gian địa chỉ sau
số nhận dạng cho x86:

=================================================
  __seg_fs Biến được định địa chỉ liên quan đến FS
  __seg_gs Biến được định địa chỉ liên quan đến GS
  =================================================

Các ký hiệu tiền xử lý __SEG_FS và __SEG_GS được xác định khi các ký hiệu này
không gian địa chỉ được hỗ trợ. Mã thực hiện các chế độ dự phòng sẽ
kiểm tra xem các ký hiệu này có được xác định hay không. Ví dụ sử dụng::

#ifdef __SEG_GS

dữ liệu dài0 = 0;
  dữ liệu dài1 = 1;

dài __seg_gs *ptr;

/* Kiểm tra xem FSGSBASE có được kernel kích hoạt hay không (HWCAP2_FSGSBASE) */
  ....

/* Đặt cơ sở GS trỏ tới data0 */
  _writegsbase_u64(&data0);

/* Độ lệch truy cập 0 của GS */
  ptr = 0;
  printf("data0 = %ld\n", *ptr);

/* Đặt cơ sở GS trỏ tới data1 */
  _writegsbase_u64(&data1);
  /* ptr vẫn có địa chỉ offset 0! */
  printf("data1 = %ld\n", *ptr);


Clang không cung cấp mã định danh không gian địa chỉ GCC, nhưng nó cung cấp
không gian địa chỉ thông qua cơ chế dựa trên thuộc tính trong Clang 2.6 trở lên
phiên bản:

===============================================================================
  __attribute__((address_space(256)) Biến được định địa chỉ liên quan đến GS
  __attribute__((address_space(257)) Biến được định địa chỉ liên quan đến FS
 ===============================================================================

Địa chỉ dựa trên FS/GS với lắp ráp nội tuyến
-------------------------------------------

Trong trường hợp trình biên dịch không hỗ trợ không gian địa chỉ, tập hợp nội tuyến có thể
được sử dụng cho chế độ đánh địa chỉ dựa trên FS/GS::

di chuyển %fs: offset, %reg
	di chuyển %gs:offset, %reg

di chuyển %reg, %fs:offset
	di chuyển %reg, %gs:offset