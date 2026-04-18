.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/dev-tools/kasan.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright (C) 2023, Google LLC.

Bộ khử trùng địa chỉ hạt nhân (KASAN)
================================

Tổng quan
--------

Kernel address Sanitizer (KASAN) là trình phát hiện lỗi an toàn bộ nhớ động
được thiết kế để tìm ra các lỗi vượt quá giới hạn và lỗi sử dụng sau này.

KASAN có ba chế độ:

1. KASAN chung
2. KASAN dựa trên thẻ phần mềm
3. KASAN dựa trên thẻ phần cứng

KASAN chung, được kích hoạt cùng với CONFIG_KASAN_GENERIC, là chế độ dành cho
gỡ lỗi, tương tự như không gian người dùng ASan. Chế độ này được hỗ trợ trên nhiều CPU
kiến trúc, nhưng nó có hiệu năng đáng kể và chi phí bộ nhớ.

KASAN hoặc SW_TAGS KASAN dựa trên thẻ phần mềm, được bật với CONFIG_KASAN_SW_TAGS,
có thể được sử dụng cho cả việc gỡ lỗi và thử nghiệm dogfood, tương tự như HWASan trong không gian người dùng.
Chế độ này chỉ được hỗ trợ cho arm64, nhưng chi phí bộ nhớ vừa phải của nó cho phép
sử dụng nó để thử nghiệm trên các thiết bị bị giới hạn bộ nhớ với khối lượng công việc thực tế.

KASAN hoặc HW_TAGS KASAN dựa trên thẻ phần cứng, được bật với CONFIG_KASAN_HW_TAGS,
là chế độ được thiết kế để sử dụng làm trình phát hiện lỗi bộ nhớ tại chỗ hoặc như một
giảm nhẹ an ninh. Chế độ này chỉ hoạt động trên CPU arm64 hỗ trợ MTE
(Tiện ích mở rộng gắn thẻ bộ nhớ), nhưng nó có chi phí hoạt động và bộ nhớ thấp và
do đó có thể được sử dụng trong sản xuất.

Để biết chi tiết về tác động của bộ nhớ và hiệu suất của từng chế độ KASAN, hãy xem phần
mô tả về các tùy chọn Kconfig tương ứng.

Chế độ Chung và Dựa trên thẻ phần mềm thường được gọi là chế độ
các chế độ phần mềm Chế độ dựa trên thẻ phần mềm và dựa trên thẻ phần cứng là
được gọi là các chế độ dựa trên thẻ.

Ủng hộ
-------

Kiến trúc
~~~~~~~~~~~~~

Generic KASAN được hỗ trợ trên x86_64, arm, arm64, powerpc, riscv, s390, xtensa,
và loongarch, đồng thời các chế độ KASAN dựa trên thẻ chỉ được hỗ trợ trên arm64.

Trình biên dịch
~~~~~~~~~

Các chế độ KASAN của phần mềm sử dụng thiết bị đo thời gian biên dịch để chèn kiểm tra tính hợp lệ
trước mỗi lần truy cập bộ nhớ và do đó yêu cầu một phiên bản trình biên dịch cung cấp
hỗ trợ cho việc đó. Chế độ dựa trên thẻ phần cứng dựa vào phần cứng để thực hiện
những kiểm tra này nhưng vẫn yêu cầu phiên bản trình biên dịch hỗ trợ bộ nhớ
hướng dẫn gắn thẻ.

KASAN chung yêu cầu GCC phiên bản 8.3.0 trở lên
hoặc bất kỳ phiên bản Clang nào được kernel hỗ trợ.

KASAN dựa trên thẻ phần mềm yêu cầu GCC 11+
hoặc bất kỳ phiên bản Clang nào được kernel hỗ trợ.

KASAN dựa trên thẻ phần cứng yêu cầu GCC 10+ hoặc Clang 12+.

Các loại bộ nhớ
~~~~~~~~~~~~

Generic KASAN hỗ trợ tìm lỗi ở tất cả các loại deck, page_alloc, vmap, vmalloc,
ngăn xếp và bộ nhớ toàn cục.

KASAN dựa trên thẻ phần mềm hỗ trợ bộ nhớ sàn, page_alloc, vmalloc và ngăn xếp.

KASAN dựa trên thẻ phần cứng hỗ trợ phiến, page_alloc và vmalloc không thể thực thi
trí nhớ.

Cách sử dụng
-----

Để bật KASAN, hãy định cấu hình kernel bằng::

CONFIG_KASAN=y

và chọn giữa ZZ0000ZZ (để bật KASAN chung),
ZZ0001ZZ (để bật KASAN dựa trên thẻ phần mềm) và
ZZ0002ZZ (để bật KASAN dựa trên thẻ phần cứng).

Đối với các chế độ phần mềm, hãy chọn giữa ZZ0000ZZ và
ZZ0001ZZ. Dàn bài và nội tuyến là các loại công cụ biên dịch.
Cái trước tạo ra một nhị phân nhỏ hơn trong khi cái sau nhanh hơn tới 2 lần.

Để đưa dấu vết phân bổ và ngăn xếp miễn phí của các đối tượng bản sàn bị ảnh hưởng vào báo cáo,
kích hoạt ZZ0000ZZ. Để bao gồm dấu vết phân bổ và ngăn xếp miễn phí của bị ảnh hưởng
các trang vật lý, bật ZZ0001ZZ và khởi động bằng ZZ0002ZZ.

Thông số khởi động
~~~~~~~~~~~~~~~

KASAN bị ảnh hưởng bởi tham số dòng lệnh ZZ0000ZZ chung.
Khi được bật, KASAN sẽ xử lý kernel sau khi in báo cáo lỗi.

Theo mặc định, KASAN chỉ in báo cáo lỗi cho lần truy cập bộ nhớ không hợp lệ đầu tiên.
Với ZZ0000ZZ, KASAN in báo cáo về mọi truy cập không hợp lệ. Cái này
vô hiệu hóa ZZ0001ZZ một cách hiệu quả cho các báo cáo KASAN.

Ngoài ra, độc lập với ZZ0000ZZ, khởi động ZZ0001ZZ
tham số có thể được sử dụng để kiểm soát hành vi hoảng loạn và báo cáo:

- ZZ0000ZZ, ZZ0001ZZ, hoặc ZZ0002ZZ kiểm soát xem
  chỉ in báo cáo KASAN, hoảng loạn hạt nhân hoặc hoảng sợ hạt nhân trên
  chỉ ghi không hợp lệ (mặc định: ZZ0003ZZ). Sự hoảng loạn xảy ra ngay cả khi
  ZZ0004ZZ được kích hoạt. Lưu ý rằng khi sử dụng chế độ không đồng bộ của
  KASAN dựa trên thẻ phần cứng, ZZ0005ZZ luôn hoảng loạn
  các truy cập được kiểm tra không đồng bộ (bao gồm cả các lần đọc).

Các chế độ KASAN dựa trên thẻ phần mềm và phần cứng (xem phần về các chế độ khác nhau
các chế độ bên dưới) hỗ trợ thay đổi hành vi thu thập dấu vết ngăn xếp:

- ZZ0000ZZ hoặc ZZ0001ZZ vô hiệu hóa hoặc kích hoạt phân bổ và ngăn xếp miễn phí
  bộ sưu tập dấu vết (mặc định: ZZ0002ZZ).
- ZZ0003ZZ chỉ định số lượng mục
  trong vòng ngăn xếp (mặc định: ZZ0004ZZ).

Chế độ KASAN dựa trên thẻ phần cứng được thiết kế để sử dụng trong sản xuất như một biện pháp bảo mật
giảm nhẹ. Vì vậy, nó hỗ trợ các tham số khởi động bổ sung cho phép
vô hiệu hóa hoàn toàn KASAN hoặc kiểm soát các tính năng của nó:

- ZZ0000ZZ hoặc ZZ0001ZZ kiểm soát xem KASAN có được bật hay không (mặc định: ZZ0002ZZ).

- ZZ0000ZZ, ZZ0001ZZ hoặc ZZ0002ZZ kiểm soát xem KASAN
  được cấu hình ở chế độ đồng bộ, không đồng bộ hoặc không đối xứng của
  thực thi (mặc định: ZZ0003ZZ).
  Chế độ đồng bộ: truy cập xấu được phát hiện ngay lập tức khi thẻ
  kiểm tra lỗi xảy ra.
  Chế độ không đồng bộ: phát hiện truy cập xấu bị trì hoãn. Khi kiểm tra thẻ
  xảy ra lỗi, thông tin được lưu trữ trong phần cứng (trong TFSR_EL1
  đăng ký arm64). Kernel kiểm tra định kỳ phần cứng và
  chỉ báo cáo lỗi gắn thẻ trong quá trình kiểm tra này.
  Chế độ bất đối xứng: truy cập xấu được phát hiện đồng bộ trên các lần đọc và
  không đồng bộ khi ghi.

- ZZ0000ZZ hoặc ZZ0001ZZ kiểm soát xem KASAN
  kiểm tra chỉ truy cập ghi (lưu trữ) hoặc tất cả các truy cập (mặc định: ZZ0002ZZ).

- ZZ0000ZZ hoặc ZZ0001ZZ vô hiệu hóa hoặc cho phép gắn thẻ vmalloc
  phân bổ (mặc định: ZZ0002ZZ).

- ZZ0000ZZ chỉ tạo thẻ KASAN mỗi
  Phân bổ page_alloc thứ n với thứ tự bằng hoặc lớn hơn
  ZZ0001ZZ, trong đó N là giá trị của ZZ0002ZZ
  tham số (mặc định: ZZ0003ZZ hoặc gắn thẻ cho mỗi phân bổ như vậy).
  Tham số này nhằm mục đích giảm thiểu chi phí hiệu suất được đưa ra
  bởi KASAN.
  Lưu ý rằng việc bật tham số này sẽ khiến KASAN dựa trên thẻ phần cứng bỏ qua việc kiểm tra
  phân bổ được chọn bằng cách lấy mẫu và do đó bỏ lỡ quyền truy cập không hợp lệ vào các phân bổ này
  phân bổ. Sử dụng giá trị mặc định để phát hiện lỗi chính xác.

- ZZ0000ZZ chỉ định mức tối thiểu
  thứ tự phân bổ bị ảnh hưởng bởi việc lấy mẫu (mặc định: ZZ0001ZZ).
  Chỉ áp dụng khi ZZ0002ZZ được đặt thành giá trị lớn hơn
  hơn ZZ0003ZZ.
  Tham số này nhằm mục đích chỉ cho phép lấy mẫu page_alloc lớn
  phân bổ, đây là nguồn lớn nhất của chi phí hoạt động.

Báo cáo lỗi
~~~~~~~~~~~~~

Một báo cáo KASAN điển hình trông như thế này::

=======================================================================
    BUG: KASAN: vượt quá giới hạn trong kmalloc_oob_right+0xa8/0xbc [kasan_test]
    Viết kích thước 1 tại addr ffff8801f44ec37b bằng tác vụ insmod/2760

CPU: 1 PID: 2760 Comm: insmod Không bị nhiễm độc 4.19.0-rc3+ #698
    Tên phần cứng: QEMU PC tiêu chuẩn (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
    Theo dõi cuộc gọi:
     dump_stack+0x94/0xd8
     print_address_description+0x73/0x280
     kasan_report+0x144/0x187
     __asan_report_store1_noabort+0x17/0x20
     kmalloc_oob_right+0xa8/0xbc [kasan_test]
     kmalloc_tests_init+0x16/0x700 [kasan_test]
     do_one_initcall+0xa5/0x3ae
     do_init_module+0x1b6/0x547
     tải_module+0x75df/0x8070
     __do_sys_init_module+0x1c6/0x200
     __x64_sys_init_module+0x6e/0xb0
     do_syscall_64+0x9f/0x2c0
     entry_SYSCALL_64_after_hwframe+0x44/0xa9
    RIP: 0033:0x7f96443109da
    RSP: 002b:00007ffcf0b51b08 EFLAGS: 00000202 ORIG_RAX: 000000000000000af
    RAX: ffffffffffffffda RBX: 000055dc3ee521a0 RCX: 00007f96443109da
    RDX: 00007f96445cff88 RSI: 0000000000057a50 RDI: 00007f9644992000
    RBP: 000055dc3ee510b0 R08: 00000000000000003 R09: 0000000000000000
    R10: 00007f964430cd0a R11: 0000000000000202 R12: 00007f96445cff88
    R13: 000055dc3ee51090 R14: 00000000000000000 R15: 0000000000000000

Phân bổ theo nhiệm vụ 2760:
     save_stack+0x43/0xd0
     kasan_kmalloc+0xa7/0xd0
     kmem_cache_alloc_trace+0xe1/0x1b0
     kmalloc_oob_right+0x56/0xbc [kasan_test]
     kmalloc_tests_init+0x16/0x700 [kasan_test]
     do_one_initcall+0xa5/0x3ae
     do_init_module+0x1b6/0x547
     tải_module+0x75df/0x8070
     __do_sys_init_module+0x1c6/0x200
     __x64_sys_init_module+0x6e/0xb0
     do_syscall_64+0x9f/0x2c0
     entry_SYSCALL_64_after_hwframe+0x44/0xa9

Được giải phóng bởi nhiệm vụ 815:
     save_stack+0x43/0xd0
     __kasan_slab_free+0x135/0x190
     kasan_slab_free+0xe/0x10
     kfree+0x93/0x1a0
     ừm_complete+0x6a/0xa0
     call_usermodehelper_exec_async+0x4c3/0x640
     ret_from_fork+0x35/0x40

Địa chỉ lỗi thuộc về đối tượng tại ffff8801f44ec300
     thuộc về bộ đệm kmalloc-128 có kích thước 128
    Địa chỉ lỗi nằm ở 123 byte bên trong
     Vùng 128 byte [ffff8801f44ec300, ffff8801f44ec380)
    Địa chỉ lỗi thuộc về trang:
    trang:ffffea0007d13b00 số lượng:1 số bản đồ:0 ánh xạ:ffff8801f7001640 chỉ mục:0x0
    cờ: 0x200000000000100 (tấm)
    thô: 0200000000000100 ffffea0007d11dc0 0000001a0000001a ffff8801f7001640
    nguyên: 0000000000000000 0000000080150015 00000001ffffffff 00000000000000000
    trang bị hủy vì: kasan: phát hiện truy cập kém

Trạng thái bộ nhớ xung quanh địa chỉ có lỗi:
     ffff8801f44ec200: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
     ffff8801f44ec280: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
    >ffff8801f44ec300: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 03
                                                                    ^
     ffff8801f44ec380: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
     ffff8801f44ec400: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
    =======================================================================

Tiêu đề báo cáo tóm tắt loại lỗi nào đã xảy ra và loại quyền truy cập nào
gây ra nó. Tiếp theo là dấu vết ngăn xếp của quyền truy cập không hợp lệ, dấu vết ngăn xếp của
nơi bộ nhớ truy cập được phân bổ (trong trường hợp đối tượng bản sàn được truy cập),
và dấu vết ngăn xếp về nơi đối tượng được giải phóng (trong trường hợp use-after-free
báo cáo lỗi). Tiếp theo là mô tả về đối tượng bản sàn được truy cập và
thông tin về trang bộ nhớ được truy cập.

Cuối cùng, báo cáo hiển thị trạng thái bộ nhớ xung quanh địa chỉ được truy cập.
Trong nội bộ, KASAN theo dõi trạng thái bộ nhớ riêng biệt cho từng hạt bộ nhớ.
là 8 hoặc 16 byte căn chỉnh tùy thuộc vào chế độ KASAN. Mỗi số trong
phần trạng thái bộ nhớ của báo cáo hiển thị trạng thái của một trong các bộ nhớ
các hạt bao quanh địa chỉ được truy cập.

Đối với KASAN chung, kích thước của mỗi hạt bộ nhớ là 8. Trạng thái của mỗi hạt
hạt được mã hóa trong một byte bóng. 8 byte đó có thể truy cập được,
có thể truy cập một phần, được giải phóng hoặc là một phần của redzone. KASAN sử dụng như sau
mã hóa cho mỗi byte bóng: 00 có nghĩa là tất cả 8 byte tương ứng
vùng bộ nhớ có thể truy cập được; số N (1 <= N <= 7) nghĩa là N đầu tiên
các byte có thể truy cập được còn các byte (8 - N) khác thì không; bất kỳ giá trị âm nào
chỉ ra rằng toàn bộ từ 8 byte không thể truy cập được. KASAN sử dụng khác nhau
giá trị âm để phân biệt giữa các loại bộ nhớ không thể truy cập khác nhau
như redzones hoặc bộ nhớ được giải phóng (xem mm/kasan/kasan.h).

Trong báo cáo ở trên, mũi tên chỉ vào byte bóng ZZ0000ZZ, có nghĩa là
rằng địa chỉ được truy cập có thể truy cập được một phần.

Đối với các chế độ KASAN dựa trên thẻ, phần báo cáo cuối cùng này hiển thị các thẻ nhớ xung quanh
địa chỉ được truy cập (xem phần ZZ0000ZZ).

Lưu ý các tiêu đề lỗi KASAN (như ZZ0000ZZ hoặc ZZ0001ZZ)
là nỗ lực tốt nhất: KASAN in loại lỗi có thể xảy ra nhất dựa trên giới hạn
thông tin nó có. Loại lỗi thực tế có thể khác.

KASAN chung cũng báo cáo tối đa hai dấu vết ngăn xếp cuộc gọi phụ. Những ngăn xếp này
dấu vết trỏ đến các vị trí trong mã tương tác với đối tượng nhưng không phải
hiện diện trực tiếp trong dấu vết ngăn xếp truy cập xấu. Hiện nay, điều này bao gồm
call_rcu() và xếp hàng công việc.

CONFIG_KASAN_EXTRA_INFO
~~~~~~~~~~~~~~~~~~~~~~~

Kích hoạt CONFIG_KASAN_EXTRA_INFO cho phép KASAN ghi lại và báo cáo nhiều hơn
thông tin. Thông tin bổ sung hiện được hỗ trợ là số CPU và
dấu thời gian khi phân bổ và miễn phí. Thông tin thêm có thể giúp tìm ra nguyên nhân của
lỗi và liên hệ lỗi đó với các sự kiện hệ thống khác, với chi phí sử dụng
bộ nhớ bổ sung để ghi thêm thông tin (chi tiết chi phí hơn trong văn bản trợ giúp của
CONFIG_KASAN_EXTRA_INFO).

Đây là báo cáo có kích hoạt CONFIG_KASAN_EXTRA_INFO (chỉ
các phần khác nhau được hiển thị)::

=======================================================================
    ...
Được phân bổ theo nhiệm vụ 134 trên cpu 5 tại 229.133855s:
    ...
Được giải phóng bởi nhiệm vụ 136 trên cpu 3 ở 230.199335s:
    ...
=======================================================================

Chi tiết triển khai
----------------------

Chung KASAN
~~~~~~~~~~~~~

Các chế độ KASAN của phần mềm sử dụng bộ nhớ bóng để ghi lại xem mỗi byte bộ nhớ có
an toàn để truy cập và sử dụng công cụ đo thời gian biên dịch để chèn bộ nhớ ẩn
kiểm tra trước mỗi lần truy cập bộ nhớ.

KASAN chung dành 1/8 bộ nhớ kernel cho bộ nhớ bóng của nó (16TB
để bao phủ 128TB trên x86_64) và sử dụng ánh xạ trực tiếp với tỷ lệ và độ lệch thành
dịch địa chỉ bộ nhớ sang địa chỉ bóng tương ứng của nó.

Đây là hàm dịch một địa chỉ sang bóng tương ứng của nó
địa chỉ::

khoảng trống nội tuyến tĩnh *kasan_mem_to_shadow(const void *addr)
    {
	return (void *)((unsigned long)addr >> KASAN_SHADOW_SCALE_SHIFT)
		+ KASAN_SHADOW_OFFSET;
    }

ở đâu ZZ0000ZZ.

Công cụ đo thời gian biên dịch được sử dụng để chèn các kiểm tra truy cập bộ nhớ. Trình biên dịch
chèn các lệnh gọi hàm (ZZ0000ZZ, ZZ0001ZZ) trước
mỗi truy cập bộ nhớ có kích thước 1, 2, 4, 8 hoặc 16. Các chức năng này kiểm tra xem
truy cập bộ nhớ có hợp lệ hay không bằng cách kiểm tra bộ nhớ bóng tương ứng.

Với công cụ đo lường nội tuyến, thay vì thực hiện lệnh gọi hàm, trình biên dịch
trực tiếp chèn mã để kiểm tra bộ nhớ bóng. Tùy chọn này đáng kể
phóng to hạt nhân, nhưng nó mang lại hiệu suất tăng x1.1-x2 so với
kernel có công cụ phác thảo.

KASAN chung là chế độ duy nhất trì hoãn việc sử dụng lại các đối tượng được giải phóng thông qua
cách ly (xem mm/kasan/quarantine.c để biết cách thực hiện).

KASAN dựa trên thẻ phần mềm
~~~~~~~~~~~~~~~~~~~~~~~~

KASAN dựa trên thẻ phần mềm sử dụng phương pháp gắn thẻ bộ nhớ phần mềm để kiểm tra
tính hợp lệ truy cập. Hiện tại nó chỉ được triển khai cho kiến ​​trúc arm64.

KASAN dựa trên thẻ phần mềm sử dụng tính năng Bỏ qua Byte hàng đầu (TBI) của CPU arm64
để lưu trữ thẻ con trỏ ở byte trên cùng của con trỏ hạt nhân. Nó sử dụng bộ nhớ bóng
để lưu trữ các thẻ nhớ liên kết với mỗi ô nhớ 16 byte (do đó, nó
dành 1/16 bộ nhớ kernel cho bộ nhớ bóng).

Trên mỗi lần cấp phát bộ nhớ, KASAN dựa trên thẻ phần mềm sẽ tạo một thẻ ngẫu nhiên, các thẻ
bộ nhớ được phân bổ với thẻ này và nhúng cùng một thẻ vào bộ nhớ được trả về
con trỏ.

KASAN dựa trên thẻ phần mềm sử dụng thiết bị đo thời gian biên dịch để chèn séc
trước mỗi lần truy cập bộ nhớ. Những kiểm tra này đảm bảo rằng thẻ của bộ nhớ
đang được truy cập bằng thẻ của con trỏ được sử dụng để truy cập
ký ức này. Trong trường hợp thẻ không khớp, KASAN dựa trên thẻ phần mềm sẽ in lỗi
báo cáo.

KASAN dựa trên thẻ phần mềm cũng có hai chế độ thiết bị (phác thảo, chế độ
phát ra các cuộc gọi lại để kiểm tra quyền truy cập bộ nhớ; và nội tuyến, thực hiện bóng
kiểm tra bộ nhớ nội tuyến). Với chế độ đo đạc phác thảo, một báo cáo lỗi sẽ được
được in từ chức năng thực hiện kiểm tra quyền truy cập. Với nội tuyến
thiết bị đo, một lệnh ZZ0000ZZ được trình biên dịch phát ra và một
trình xử lý ZZ0001ZZ chuyên dụng được sử dụng để in báo cáo lỗi.

KASAN dựa trên thẻ phần mềm sử dụng 0xFF làm thẻ con trỏ khớp tất cả (truy cập thông qua
con trỏ có thẻ con trỏ 0xFF không được chọn). Giá trị 0xFE hiện tại là
dành riêng để gắn thẻ các vùng bộ nhớ được giải phóng.

KASAN dựa trên thẻ phần cứng
~~~~~~~~~~~~~~~~~~~~~~~~

KASAN dựa trên thẻ phần cứng tương tự như chế độ phần mềm trong khái niệm nhưng sử dụng
hỗ trợ gắn thẻ bộ nhớ phần cứng thay vì thiết bị biên dịch và
ký ức bóng tối.

KASAN dựa trên thẻ phần cứng hiện chỉ được triển khai cho kiến trúc arm64
và dựa trên cả Tiện ích mở rộng gắn thẻ bộ nhớ arm64 (MTE) được giới thiệu trong ARMv8.5
Kiến trúc tập lệnh và bỏ qua byte hàng đầu (TBI).

Các lệnh arm64 đặc biệt được sử dụng để gán thẻ nhớ cho mỗi lần cấp phát.
Các thẻ giống nhau được gán cho các con trỏ tới các phân bổ đó. Trên mỗi kỷ niệm
truy cập, phần cứng đảm bảo rằng thẻ của bộ nhớ đang được truy cập là
bằng với thẻ của con trỏ được sử dụng để truy cập bộ nhớ này. Trong trường hợp một
thẻ không khớp, lỗi sẽ xảy ra và báo cáo sẽ được in.

KASAN dựa trên thẻ phần cứng sử dụng 0xFF làm thẻ con trỏ khớp tất cả (truy cập thông qua
con trỏ có thẻ con trỏ 0xFF không được chọn). Giá trị 0xFE hiện tại là
dành riêng để gắn thẻ các vùng bộ nhớ được giải phóng.

Nếu phần cứng không hỗ trợ MTE (trước ARMv8.5), KASAN dựa trên thẻ phần cứng
sẽ không được kích hoạt. Trong trường hợp này, tất cả các tham số khởi động KASAN đều bị bỏ qua.

Lưu ý rằng việc bật CONFIG_KASAN_HW_TAGS luôn dẫn đến TBI trong kernel bị
đã bật. Ngay cả khi ZZ0000ZZ được cung cấp hoặc khi phần cứng không
hỗ trợ MTE (nhưng hỗ trợ TBI).

KASAN dựa trên thẻ phần cứng chỉ báo cáo lỗi được tìm thấy đầu tiên. Sau đó, thẻ MTE
việc kiểm tra bị vô hiệu hóa.

Ký ức bóng tối
-------------

Nội dung của phần này chỉ áp dụng cho các chế độ KASAN của phần mềm.

Hạt nhân ánh xạ bộ nhớ vào nhiều phần khác nhau của không gian địa chỉ.
Phạm vi địa chỉ ảo hạt nhân rất lớn: không có đủ địa chỉ thực
bộ nhớ để hỗ trợ vùng bóng thực cho mọi địa chỉ có thể
được kernel truy cập. Do đó, KASAN chỉ ánh xạ bóng thực cho một số trường hợp nhất định.
các phần của không gian địa chỉ.

Hành vi mặc định
~~~~~~~~~~~~~~~~~

Theo mặc định, kiến trúc chỉ ánh xạ bộ nhớ thực qua vùng bóng
để lập bản đồ tuyến tính (và có thể cả các khu vực nhỏ khác). Cho tất cả
các khu vực khác - chẳng hạn như không gian vmalloc và vmemmap - một vùng chỉ đọc duy nhất
trang được ánh xạ trên vùng bóng. Trang bóng chỉ đọc này
tuyên bố tất cả các truy cập bộ nhớ là được phép.

Điều này gây ra một vấn đề cho các mô-đun: chúng không hoạt động ở dạng tuyến tính.
ánh xạ nhưng trong một không gian mô-đun chuyên dụng. Bằng cách nối vào mô-đun
bộ cấp phát, KASAN tạm thời ánh xạ bộ nhớ bóng thực để che chúng.
Ví dụ, điều này cho phép phát hiện các quyền truy cập không hợp lệ vào các mô-đun toàn cầu.

Điều này cũng tạo ra sự không tương thích với ZZ0000ZZ: nếu ngăn xếp
sống trong không gian vmalloc, nó sẽ bị che khuất bởi trang chỉ đọc và
kernel sẽ bị lỗi khi cố gắng thiết lập dữ liệu bóng cho ngăn xếp
các biến.

CONFIG_KASAN_VMALLOC
~~~~~~~~~~~~~~~~~~~~

Với ZZ0000ZZ, KASAN có thể bao phủ không gian vmalloc tại
chi phí sử dụng bộ nhớ lớn hơn. Hiện tại, điều này được hỗ trợ trên x86,
arm64, riscv, s390 và powerpc.

Điều này hoạt động bằng cách nối vào vmalloc và vmap và tự động
phân bổ bộ nhớ bóng thực để sao lưu ánh xạ.

Hầu hết các ánh xạ trong không gian vmalloc đều nhỏ, yêu cầu ít hơn
trang của không gian bóng tối. Việc phân bổ một trang bóng đầy đủ cho mỗi ánh xạ sẽ
nên lãng phí. Hơn nữa, để đảm bảo rằng các ánh xạ khác nhau
sử dụng các trang bóng khác nhau, ánh xạ sẽ phải được căn chỉnh theo
ZZ0000ZZ.

Thay vào đó, KASAN chia sẻ không gian sao lưu trên nhiều ánh xạ. Nó phân bổ
trang hỗ trợ khi ánh xạ trong không gian vmalloc sử dụng một trang cụ thể
của vùng bóng tối. Trang này có thể được chia sẻ bởi vmalloc khác
bản đồ sau này.

KASAN nối vào cơ sở hạ tầng vmap để dọn dẹp bóng không sử dụng một cách lười biếng
trí nhớ.

Để tránh những khó khăn xung quanh việc hoán đổi ánh xạ xung quanh, KASAN mong đợi
rằng phần vùng bóng bao phủ không gian vmalloc sẽ
không bị che phủ bởi trang bóng ban đầu nhưng sẽ không được ánh xạ.
Điều này sẽ yêu cầu thay đổi mã dành riêng cho Arch.

Điều này cho phép hỗ trợ ZZ0000ZZ trên x86 và có thể đơn giản hóa việc hỗ trợ
kiến trúc không có vùng mô-đun cố định.

Dành cho nhà phát triển
--------------

Bỏ qua quyền truy cập
~~~~~~~~~~~~~~~~~

Các chế độ KASAN của phần mềm sử dụng công cụ biên dịch để chèn kiểm tra tính hợp lệ.
Công cụ như vậy có thể không tương thích với một số phần của hạt nhân, và
do đó cần phải bị vô hiệu hóa.

Các phần khác của kernel có thể truy cập siêu dữ liệu cho các đối tượng được phân bổ.
Thông thường, KASAN phát hiện và báo cáo những truy cập như vậy, nhưng trong một số trường hợp (ví dụ:
trong bộ cấp phát bộ nhớ), những truy cập này là hợp lệ.

Đối với các chế độ KASAN của phần mềm, để tắt thiết bị đo cho một tệp cụ thể hoặc
thư mục, thêm chú thích ZZ0000ZZ vào kernel tương ứng
Tạo tệp:

- Đối với một tập tin (ví dụ: main.o)::

KASAN_SANITIZE_main.o := n

- Đối với tất cả các tập tin trong một thư mục::

KASAN_SANITIZE := n

Đối với các chế độ KASAN của phần mềm, để tắt thiết bị đo trên cơ sở từng chức năng,
sử dụng thuộc tính hàm ZZ0000ZZ dành riêng cho KASAN hoặc thuộc tính
chung ZZ0001ZZ một.

Lưu ý rằng việc tắt công cụ biên dịch (trên mỗi tệp hoặc trên
cơ sở từng chức năng) khiến KASAN bỏ qua các truy cập xảy ra trực tiếp trong
mã đó cho các chế độ KASAN của phần mềm. Nó không giúp ích gì khi việc truy cập xảy ra
gián tiếp (thông qua các lệnh gọi đến các chức năng được đo lường) hoặc bằng Phần cứng
KASAN dựa trên thẻ, không sử dụng công cụ biên dịch.

Đối với các chế độ KASAN của phần mềm, để tắt báo cáo KASAN trong một phần của mã hạt nhân
đối với tác vụ hiện tại, hãy chú thích phần mã này bằng một
Phần ZZ0000ZZ/ZZ0001ZZ. Điều này cũng
vô hiệu hóa các báo cáo về các truy cập gián tiếp xảy ra thông qua lệnh gọi hàm.

Đối với chế độ KASAN dựa trên thẻ, để tắt kiểm tra quyền truy cập, hãy sử dụng
ZZ0000ZZ hoặc ZZ0001ZZ. Lưu ý rằng tạm thời
vô hiệu hóa kiểm tra quyền truy cập qua ZZ0002ZZ yêu cầu lưu và
khôi phục thẻ KASAN trên mỗi trang thông qua ZZ0003ZZ/ZZ0004ZZ.

Kiểm tra
~~~~~

Có các bài kiểm tra KASAN cho phép xác minh rằng KASAN hoạt động và có thể phát hiện
một số loại lỗi bộ nhớ.

Tất cả các bài kiểm tra KASAN đều được tích hợp với Khung kiểm tra KUnit và có thể được kích hoạt
thông qua ZZ0000ZZ. Các bài kiểm tra có thể được chạy và xác minh một phần
tự động theo một số cách khác nhau; xem hướng dẫn bên dưới.

Mỗi lần kiểm tra KASAN sẽ in một trong nhiều báo cáo KASAN nếu phát hiện thấy lỗi.
Sau đó kiểm tra in số lượng và trạng thái của nó.

Khi bài kiểm tra vượt qua::

được 28 - kmalloc_double_kzfree

Khi kiểm tra không thành công do ZZ0000ZZ bị lỗi::

# kmalloc_large_oob_right: ASSERTION FAILED tại mm/kasan/kasan_test.c:245
        Ptr dự kiến không phải là null, nhưng là
        không ổn 5 - kmalloc_large_oob_right

Khi kiểm tra không thành công do thiếu báo cáo KASAN::

# kmalloc_double_kzfree: EXPECTATION FAILED tại mm/kasan/kasan_test.c:709
        Dự kiến có lỗi KASAN trong "kfree_sensitive(ptr)", nhưng không xảy ra lỗi nào
        không ổn 28 - kmalloc_double_kzfree


Cuối cùng, trạng thái tích lũy của tất cả các xét nghiệm KASAN sẽ được in. Về thành công::

được 1 - kasan

Hoặc, nếu một trong các thử nghiệm không thành công::

không ổn 1 - kasan

Có một số cách để chạy thử nghiệm KASAN.

1. Mô-đun có thể tải

Khi bật ZZ0000ZZ, các bài kiểm tra có thể được xây dựng dưới dạng mô-đun có thể tải được
   và chạy bằng cách tải ZZ0001ZZ với ZZ0002ZZ hoặc ZZ0003ZZ.

2. Tích hợp sẵn

Với ZZ0000ZZ được tích hợp sẵn, các bài kiểm tra cũng có thể được tích hợp sẵn.
   Trong trường hợp này, các bài kiểm tra sẽ chạy khi khởi động dưới dạng lệnh gọi khởi tạo muộn.

3. Sử dụng kunit_tool

Với ZZ0000ZZ và ZZ0001ZZ được tích hợp sẵn, nó cũng
   có thể sử dụng ZZ0002ZZ để xem kết quả kiểm tra KUnit một cách chi tiết hơn
   cách dễ đọc. Thao tác này sẽ không in báo cáo KASAN về các thử nghiệm đã vượt qua.
   Xem ZZ0004ZZ
   for more up-to-date information on ZZ0003ZZ.

.. _KUnit: https://www.kernel.org/doc/html/latest/dev-tools/kunit/index.html