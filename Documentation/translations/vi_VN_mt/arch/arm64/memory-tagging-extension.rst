.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm64/memory-tagging-extension.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================================
Tiện ích mở rộng gắn thẻ bộ nhớ (MTE) trong AArch64 Linux
===============================================

Tác giả: Vincenzo Frascino <vincenzo.frascino@arm.com>
         Bến du thuyền Catalin <catalin.marinas@arm.com>

Ngày: 25/02/2020

Tài liệu này mô tả việc cung cấp Tiện ích mở rộng gắn thẻ bộ nhớ
chức năng trong AArch64 Linux.

Giới thiệu
============

Bộ xử lý dựa trên ARMv8.5 giới thiệu Tiện ích mở rộng gắn thẻ bộ nhớ (MTE)
tính năng. MTE được xây dựng dựa trên tính năng gắn thẻ địa chỉ ảo ARMv8.0 TBI
(Bỏ qua Byte hàng đầu) và cho phép phần mềm truy cập 4 bit
thẻ phân bổ cho mỗi hạt 16 byte trong không gian địa chỉ vật lý.
Phạm vi bộ nhớ như vậy phải được ánh xạ với bộ nhớ được gắn thẻ thông thường
thuộc tính. Thẻ logic được lấy từ bit 59-56 của ảo
địa chỉ được sử dụng để truy cập bộ nhớ. Một CPU được kích hoạt MTE sẽ so sánh
thẻ logic đối với thẻ phân bổ và có khả năng tăng
ngoại lệ về sự không khớp, tùy thuộc vào cấu hình thanh ghi hệ thống.

Hỗ trợ không gian người dùng
=================

Khi ZZ0000ZZ được chọn và Tiện ích gắn thẻ bộ nhớ được bật
được phần cứng hỗ trợ, kernel sẽ quảng cáo tính năng này tới
không gian người dùng thông qua ZZ0001ZZ.

PROT_MTE
--------

Để truy cập các thẻ phân bổ, quy trình người dùng phải kích hoạt Tagged
thuộc tính bộ nhớ trên một dải địa chỉ bằng cờ ZZ0000ZZ mới cho
ZZ0001ZZ và ZZ0002ZZ:

ZZ0000ZZ - Các trang cho phép truy cập vào thẻ phân bổ MTE.

Thẻ phân bổ được đặt thành 0 khi các trang đó được ánh xạ lần đầu tiên trong
không gian địa chỉ người dùng và được bảo toàn khi sao chép khi ghi. ZZ0000ZZ là
được hỗ trợ và các thẻ phân bổ có thể được chia sẻ giữa các tiến trình.

ZZ0005ZZ: ZZ0000ZZ chỉ được hỗ trợ trên ZZ0001ZZ và
Ánh xạ tệp dựa trên RAM (ZZ0002ZZ, ZZ0003ZZ). Chuyển nó cho người khác
các loại ánh xạ sẽ dẫn đến ZZ0004ZZ được hệ thống này trả về
cuộc gọi.

ZZ0002ZZ: Cờ ZZ0000ZZ (và loại bộ nhớ tương ứng) không thể
được xóa bởi ZZ0001ZZ.

ZZ0003ZZ: Phạm vi bộ nhớ ZZ0000ZZ với ZZ0001ZZ và
ZZ0002ZZ có thể xóa thẻ phân bổ (đặt thành 0) bất kỳ lúc nào
điểm sau cuộc gọi hệ thống.

Lỗi kiểm tra thẻ
----------------

Khi ZZ0000ZZ được bật trên một dải địa chỉ và không khớp giữa
các thẻ logic và phân bổ xuất hiện khi truy cập, có ba
hành vi có thể cấu hình:

- ZZ0000ZZ - Đây là chế độ mặc định. CPU (và kernel) bỏ qua
  lỗi kiểm tra thẻ.

- ZZ0005ZZ - Hạt nhân nâng ZZ0000ZZ một cách đồng bộ, với
  ZZ0001ZZ và ZZ0002ZZ. các
  truy cập bộ nhớ không được thực hiện. Nếu ZZ0003ZZ bị bỏ qua hoặc bị chặn
  bởi luồng vi phạm, quá trình chứa được kết thúc bằng một
  ZZ0004ZZ.

- ZZ0003ZZ - Hạt nhân tăng ZZ0000ZZ, trong trường hợp vi phạm
  luồng, không đồng bộ theo sau một hoặc nhiều lỗi kiểm tra thẻ,
  với ZZ0001ZZ và ZZ0002ZZ (lỗi
  địa chỉ không rõ).

- ZZ0000ZZ - Việc đọc được xử lý như đối với chế độ đồng bộ trong khi ghi
  được xử lý như đối với chế độ không đồng bộ.

Người dùng có thể chọn các chế độ trên cho mỗi luồng bằng cách sử dụng
Cuộc gọi hệ thống ZZ0000ZZ trong đó ZZ0001ZZ
chứa bất kỳ số giá trị nào sau đây trong ZZ0002ZZ
trường bit:

- ZZ0000ZZ  - Lỗi kiểm tra thẻ ZZ0003ZZ
                         (bỏ qua nếu kết hợp với các tùy chọn khác)
- ZZ0001ZZ - Chế độ kiểm tra lỗi thẻ ZZ0004ZZ
- ZZ0002ZZ - Chế độ kiểm tra lỗi thẻ ZZ0005ZZ

Nếu không có chế độ nào được chỉ định, lỗi kiểm tra thẻ sẽ bị bỏ qua. Nếu một
chế độ nào được chỉ định thì chương trình sẽ chạy ở chế độ đó. Nếu nhiều
chế độ được chỉ định, chế độ được chọn như được mô tả trong "Per-CPU
phần chế độ kiểm tra thẻ ưa thích" bên dưới.

Cấu hình lỗi kiểm tra thẻ hiện tại có thể được đọc bằng cách sử dụng
Cuộc gọi hệ thống ZZ0000ZZ. Nếu
nhiều chế độ được yêu cầu thì tất cả sẽ được báo cáo.

Việc kiểm tra thẻ cũng có thể bị vô hiệu hóa đối với chuỗi người dùng bằng cách đặt
Bit ZZ0000ZZ với ZZ0001ZZ.

ZZ0003ZZ: Bộ xử lý tín hiệu luôn được gọi bằng ZZ0000ZZ,
bất kể bối cảnh bị gián đoạn. ZZ0001ZZ được khôi phục trên
ZZ0002ZZ.

ZZ0000ZZ: Không có thẻ logic ZZ0001ZZ nào có sẵn cho người dùng
ứng dụng.

ZZ0005ZZ: Kernel truy cập vào không gian địa chỉ người dùng (ví dụ: ZZ0000ZZ
cuộc gọi hệ thống) không được kiểm tra nếu chế độ kiểm tra thẻ luồng của người dùng được bật
ZZ0001ZZ hoặc ZZ0002ZZ. Nếu chế độ kiểm tra thẻ là
ZZ0003ZZ, kernel nỗ lực hết sức để kiểm tra người dùng của nó
truy cập địa chỉ, tuy nhiên nó không phải lúc nào cũng đảm bảo điều đó. Truy cập hạt nhân
tới địa chỉ người dùng luôn được thực hiện với ZZ0004ZZ hiệu quả
giá trị bằng 0, bất kể cấu hình người dùng.

Loại trừ các Thẻ trong hướng dẫn ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ
-----------------------------------------------------------------

Kiến trúc cho phép loại trừ một số thẻ nhất định được tạo ngẫu nhiên
thông qua trường bit thanh ghi ZZ0000ZZ. Theo mặc định, Linux
loại trừ tất cả các thẻ khác 0. Chuỗi người dùng có thể kích hoạt các thẻ cụ thể
trong tập hợp được tạo ngẫu nhiên bằng cách sử dụng lệnh gọi hệ thống ZZ0001ZZ trong đó ZZ0002ZZ chứa các thẻ bitmap
trong trường bit ZZ0003ZZ.

ZZ0004ZZ: Phần cứng sử dụng mặt nạ loại trừ nhưng ZZ0000ZZ
giao diện cung cấp một mặt nạ bao gồm. Mặt nạ bao gồm của ZZ0001ZZ (loại trừ
mặt nạ ZZ0002ZZ) dẫn đến CPU luôn tạo thẻ ZZ0003ZZ.

Chế độ kiểm tra thẻ ưa thích Per-CPU
-----------------------------------

Trên một số CPU, hiệu suất của MTE ở chế độ kiểm tra thẻ chặt chẽ hơn
tương tự như các chế độ kiểm tra thẻ ít nghiêm ngặt hơn. Điều này làm cho nó
đáng giá để cho phép kiểm tra chặt chẽ hơn trên các CPU đó khi quy định ít nghiêm ngặt hơn
chế độ kiểm tra được yêu cầu để đạt được khả năng phát hiện lỗi
lợi ích của việc kiểm tra chặt chẽ hơn mà không có nhược điểm về hiệu suất. Đến
hỗ trợ kịch bản này, người dùng đặc quyền có thể định cấu hình chặt chẽ hơn
chế độ kiểm tra thẻ là chế độ kiểm tra thẻ ưa thích của CPU.

Chế độ kiểm tra thẻ ưu tiên cho mỗi CPU được điều khiển bởi
ZZ0000ZZ, mà một
người dùng đặc quyền có thể viết giá trị ZZ0001ZZ, ZZ0002ZZ hoặc ZZ0003ZZ.  các
chế độ ưu tiên mặc định cho mỗi CPU là ZZ0004ZZ.

Để cho phép một chương trình có khả năng chạy trong thẻ ưu tiên của CPU
chế độ kiểm tra, chương trình người dùng có thể đặt chế độ lỗi kiểm tra nhiều thẻ
các bit trong đối số ZZ0000ZZ cho lệnh gọi hệ thống ZZ0001ZZ. Nếu cả đồng bộ và không đồng bộ
các chế độ được yêu cầu thì chế độ bất đối xứng cũng có thể được chọn bởi
hạt nhân. Nếu chế độ kiểm tra thẻ ưa thích của CPU nằm trong tác vụ được đặt
trong số các chế độ kiểm tra thẻ được cung cấp, chế độ đó sẽ được chọn. Nếu không,
một trong các chế độ trong chế độ của tác vụ sẽ được kernel chọn
từ chế độ của tác vụ được đặt bằng cách sử dụng thứ tự ưu tiên:

1. Không đồng bộ
	2. Bất đối xứng
	3. Đồng bộ

Lưu ý rằng không gian người dùng không có cách nào để yêu cầu nhiều chế độ và
cũng vô hiệu hóa chế độ bất đối xứng.

Trạng thái quá trình ban đầu
---------------------

Trên ZZ0000ZZ, quy trình mới có cấu hình sau:

- ZZ0000ZZ được đặt thành 0 (đã tắt)
- Không có chế độ kiểm tra thẻ nào được chọn (lỗi kiểm tra thẻ bị bỏ qua)
- ZZ0001ZZ được đặt thành 0 (loại trừ tất cả các thẻ)
- ZZ0002ZZ đặt thành 0
- ZZ0003ZZ không được đặt trên bất kỳ bản đồ bộ nhớ ban đầu nào

Trên ZZ0000ZZ, quy trình mới kế thừa cấu hình của quy trình gốc và
thuộc tính bản đồ bộ nhớ ngoại trừ phạm vi ZZ0001ZZ
với ZZ0002ZZ sẽ xóa dữ liệu và thẻ (đặt
đến 0).

Giao diện ZZ0000ZZ
--------------------------

ZZ0000ZZ và ZZ0001ZZ cho phép đọc dấu vết
các thẻ từ hoặc đặt các thẻ vào không gian địa chỉ của người theo dõi. các
Cuộc gọi hệ thống ZZ0002ZZ được gọi là ZZ0003ZZ trong đó:

- ZZ0000ZZ - một trong ZZ0001ZZ hoặc ZZ0002ZZ.
- ZZ0003ZZ - PID của người theo dõi.
- ZZ0004ZZ - địa chỉ trong không gian địa chỉ của người theo dõi.
- ZZ0005ZZ - con trỏ tới ZZ0006ZZ trong đó ZZ0007ZZ trỏ tới
  bộ đệm có độ dài ZZ0008ZZ trong không gian địa chỉ của bộ theo dõi.

Các thẻ trong bộ đệm ZZ0000ZZ của bộ theo dõi được biểu diễn dưới dạng một
Thẻ 4 bit trên mỗi byte và tương ứng với hạt thẻ MTE 16 byte trong
không gian địa chỉ của tracee.

ZZ0001ZZ: Nếu ZZ0000ZZ không được căn chỉnh theo hạt 16 byte, thì hạt nhân
sẽ sử dụng địa chỉ căn chỉnh tương ứng.

Giá trị trả về ZZ0000ZZ:

- 0 - thẻ đã được sao chép, ZZ0000ZZ của bộ theo dõi đã được cập nhật lên
  số lượng thẻ được chuyển. Điều này có thể nhỏ hơn yêu cầu
  ZZ0001ZZ nếu phạm vi địa chỉ được yêu cầu nằm trong phạm vi của người theo dõi hoặc
  Không gian của Tracer không thể truy cập được hoặc không có thẻ hợp lệ.
- ZZ0002ZZ - không thể theo dõi quá trình được chỉ định.
- ZZ0003ZZ - không thể truy cập được dải địa chỉ của người theo dõi (ví dụ: không hợp lệ
  địa chỉ) và không có thẻ nào được sao chép. ZZ0004ZZ chưa được cập nhật.
- ZZ0005ZZ - lỗi truy cập bộ nhớ của bộ theo dõi (ZZ0006ZZ
  hoặc bộ đệm ZZ0007ZZ) và không có thẻ nào được sao chép. ZZ0008ZZ chưa được cập nhật.
- ZZ0009ZZ - địa chỉ của người theo dõi không có thẻ hợp lệ (không bao giờ
  được ánh xạ với cờ ZZ0010ZZ). ZZ0011ZZ chưa được cập nhật.

ZZ0000ZZ: Không có lỗi nhất thời nào đối với các yêu cầu trên, vì vậy người dùng
các chương trình không nên thử lại trong trường hợp trả về cuộc gọi hệ thống khác 0.

ZZ0000ZZ và ZZ0001ZZ với ``addr ==
``NT_ARM_TAGGED_ADDR_CTRL`` allow ``ptrace()`` access to the tagged
address ABI control and MTE configuration of a process as per the
``prctl()`` options described in
Documentation/arch/arm64/tagged-address-abi.rst and above. The corresponding
``regset`` is 1 element of 8 bytes (``sizeof(dài))``).

Hỗ trợ kết xuất lõi
-----------------

Các thẻ phân bổ cho bộ nhớ người dùng được ánh xạ với ZZ0000ZZ bị loại bỏ
trong tệp lõi dưới dạng các phân đoạn ZZ0001ZZ bổ sung. các
tiêu đề chương trình cho phân đoạn đó được định nghĩa là:

:ZZ0000ZZ: ZZ0001ZZ
:ZZ0002ZZ: 0
:ZZ0003ZZ: phần bù tập tin phân đoạn
:ZZ0004ZZ: địa chỉ ảo phân đoạn, giống như địa chỉ tương ứng
  Phân đoạn ZZ0005ZZ
:ZZ0006ZZ: 0
:ZZ0007ZZ: kích thước phân đoạn trong tệp, được tính bằng ZZ0008ZZ
  (hai thẻ 4 bit bao gồm 32 byte bộ nhớ)
:ZZ0009ZZ: kích thước phân đoạn trong bộ nhớ, giống như kích thước tương ứng
  Phân đoạn ZZ0010ZZ
:ZZ0011ZZ: 0

Các thẻ được lưu trữ trong tệp lõi tại ZZ0000ZZ dưới dạng hai thẻ 4 bit
trong một byte. Với phần thẻ 16 byte, một trang 4K yêu cầu 128
byte trong tệp lõi.

Ví dụ về cách sử dụng đúng
========================

ZZ0000ZZ

.. code-block:: c

    /*
     * To be compiled with -march=armv8.5-a+memtag
     */
    #include <errno.h>
    #include <stdint.h>
    #include <stdio.h>
    #include <stdlib.h>
    #include <unistd.h>
    #include <sys/auxv.h>
    #include <sys/mman.h>
    #include <sys/prctl.h>

    /*
     * From arch/arm64/include/uapi/asm/hwcap.h
     */
    #define HWCAP2_MTE              (1 << 18)

    /*
     * From arch/arm64/include/uapi/asm/mman.h
     */
    #define PROT_MTE                 0x20

    /*
     * From include/uapi/linux/prctl.h
     */
    #define PR_SET_TAGGED_ADDR_CTRL 55
    #define PR_GET_TAGGED_ADDR_CTRL 56
    # define PR_TAGGED_ADDR_ENABLE  (1UL << 0)
    # define PR_MTE_TCF_SHIFT       1
    # define PR_MTE_TCF_NONE        (0UL << PR_MTE_TCF_SHIFT)
    # define PR_MTE_TCF_SYNC        (1UL << PR_MTE_TCF_SHIFT)
    # define PR_MTE_TCF_ASYNC       (2UL << PR_MTE_TCF_SHIFT)
    # define PR_MTE_TCF_MASK        (3UL << PR_MTE_TCF_SHIFT)
    # define PR_MTE_TAG_SHIFT       3
    # define PR_MTE_TAG_MASK        (0xffffUL << PR_MTE_TAG_SHIFT)

    /*
     * Insert a random logical tag into the given pointer.
     */
    #define insert_random_tag(ptr) ({                       \
            uint64_t __val;                                 \
            asm("irg %0, %1" : "=r" (__val) : "r" (ptr));   \
            __val;                                          \
    })

    /*
     * Set the allocation tag on the destination address.
     */
    #define set_tag(tagged_addr) do {                                      \
            asm volatile("stg %0, [%0]" : : "r" (tagged_addr) : "memory"); \
    } while (0)

    int main()
    {
            unsigned char *a;
            unsigned long page_sz = sysconf(_SC_PAGESIZE);
            unsigned long hwcap2 = getauxval(AT_HWCAP2);

            /* check if MTE is present */
            if (!(hwcap2 & HWCAP2_MTE))
                    return EXIT_FAILURE;

            /*
             * Enable the tagged address ABI, synchronous or asynchronous MTE
             * tag check faults (based on per-CPU preference) and allow all
             * non-zero tags in the randomly generated set.
             */
            if (prctl(PR_SET_TAGGED_ADDR_CTRL,
                      PR_TAGGED_ADDR_ENABLE | PR_MTE_TCF_SYNC | PR_MTE_TCF_ASYNC |
                      (0xfffe << PR_MTE_TAG_SHIFT),
                      0, 0, 0)) {
                    perror("prctl() failed");
                    return EXIT_FAILURE;
            }

            a = mmap(0, page_sz, PROT_READ | PROT_WRITE,
                     MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
            if (a == MAP_FAILED) {
                    perror("mmap() failed");
                    return EXIT_FAILURE;
            }

            /*
             * Enable MTE on the above anonymous mmap. The flag could be passed
             * directly to mmap() and skip this step.
             */
            if (mprotect(a, page_sz, PROT_READ | PROT_WRITE | PROT_MTE)) {
                    perror("mprotect() failed");
                    return EXIT_FAILURE;
            }

            /* access with the default tag (0) */
            a[0] = 1;
            a[1] = 2;

            printf("a[0] = %hhu a[1] = %hhu\n", a[0], a[1]);

            /* set the logical and allocation tags */
            a = (unsigned char *)insert_random_tag(a);
            set_tag(a);

            printf("%p\n", a);

            /* non-zero tag access */
            a[0] = 3;
            printf("a[0] = %hhu a[1] = %hhu\n", a[0], a[1]);

            /*
             * If MTE is enabled correctly the next instruction will generate an
             * exception.
             */
            printf("Expecting SIGSEGV...\n");
            a[16] = 0xdd;

            /* this should not be printed in the PR_MTE_TCF_SYNC mode */
            printf("...haven't got one\n");

            return EXIT_FAILURE;
    }
