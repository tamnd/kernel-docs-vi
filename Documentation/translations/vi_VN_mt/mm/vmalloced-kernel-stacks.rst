.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/vmalloced-kernel-stacks.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================================
Hỗ trợ ngăn xếp hạt nhân được ánh xạ ảo
=====================================

:Tác giả: Shuah Khan <skhan@linuxfoundation.org>

.. contents:: :local:

Tổng quan
--------

Đây là sự tổng hợp thông tin từ code và bản vá gốc
loạt giới thiệu ZZ0000ZZ

Giới thiệu
------------

Tràn ngăn xếp hạt nhân thường khó gỡ lỗi và tạo hạt nhân
dễ bị lợi dụng. Các vấn đề có thể xuất hiện sau này
rất khó để cô lập và tìm ra nguyên nhân gốc rễ.

Các ngăn xếp hạt nhân được ánh xạ ảo với các trang bảo vệ gây ra tình trạng ngăn xếp hạt nhân
tràn ra để bị bắt ngay lập tức thay vì gây khó khăn
chẩn đoán tham nhũng.

Tùy chọn cấu hình HAVE_ARCH_VMAP_STACK và VMAP_STACK cho phép
hỗ trợ cho các ngăn xếp được ánh xạ ảo với các trang bảo vệ. Tính năng này
gây ra lỗi đáng tin cậy khi ngăn xếp tràn. Khả năng sử dụng của
dấu vết ngăn xếp sau khi tràn và phản hồi với chính lỗi tràn
phụ thuộc vào kiến trúc.

.. note::
        As of this writing, arm64, powerpc, riscv, s390, um, and x86 have
        support for VMAP_STACK.

HAVE_ARCH_VMAP_STACK
--------------------

Các kiến trúc có thể hỗ trợ Ngăn xếp hạt nhân được ánh xạ ảo nên
kích hoạt tùy chọn cấu hình bool này. Các yêu cầu là:

- Dung lượng vmalloc phải đủ lớn để chứa nhiều kernel stack. Cái này
  có thể loại trừ nhiều kiến trúc 32-bit.
- Ngăn xếp trong không gian vmalloc cần hoạt động đáng tin cậy.  Ví dụ, nếu
  Các bảng trang vmap được tạo theo yêu cầu, cơ chế này
  cần phải hoạt động trong khi ngăn xếp trỏ đến một địa chỉ ảo với
  bảng trang hoặc mã vòm không được phổ biến (switch_to() và switch_mm(),
  rất có thể) cần đảm bảo rằng các mục trong bảng trang của ngăn xếp
  được điền trước khi chạy trên một ngăn xếp có thể chưa được điền.
- Nếu ngăn xếp tràn vào một trang bảo vệ, điều gì đó hợp lý
  nên xảy ra. Định nghĩa “hợp lý” rất linh hoạt, nhưng
  khởi động lại ngay lập tức mà không đăng nhập bất cứ điều gì sẽ không thân thiện.

VMAP_STACK
----------

Khi được bật, tùy chọn cấu hình bool VMAP_STACK sẽ phân bổ hầu như
ngăn xếp nhiệm vụ được ánh xạ. Tùy chọn này phụ thuộc vào HAVE_ARCH_VMAP_STACK.

- Kích hoạt tính năng này nếu bạn muốn sử dụng các ngăn xếp hạt nhân được ánh xạ ảo
  với các trang bảo vệ. Điều này khiến ngăn xếp kernel bị bắt
  ngay lập tức thay vì gây ra tham nhũng khó chẩn đoán.

.. note::

        Using this feature with KASAN requires architecture support
        for backing virtual mappings with real shadow memory, and
        KASAN_VMALLOC must be enabled.

.. note::

        VMAP_STACK is enabled, it is not possible to run DMA on stack
        allocated data.

Các tùy chọn cấu hình hạt nhân và các phần phụ thuộc liên tục thay đổi. tham khảo
cơ sở mã mới nhất:

ZZ0000ZZ

Phân bổ
-----------

Khi một luồng nhân mới được tạo, một ngăn xếp luồng được phân bổ từ
các trang bộ nhớ gần như liền kề từ bộ cấp phát cấp độ trang. Những cái này
các trang được ánh xạ vào không gian ảo kernel liền kề với PAGE_KERNEL
sự bảo vệ.

alloc_thread_stack_node() gọi __vmalloc_node_range() để phân bổ ngăn xếp
với sự bảo vệ PAGE_KERNEL.

- Ngăn xếp được phân bổ được lưu vào bộ nhớ đệm và sau đó được sử dụng lại bởi các luồng mới, vì vậy memcg
  việc tính toán được thực hiện thủ công khi phân công/giải phóng các ngăn xếp cho các nhiệm vụ.
  Do đó, __vmalloc_node_range được gọi mà không có __GFP_ACCOUNT.
- vm_struct được lưu vào bộ nhớ đệm để có thể tìm thấy khi bắt đầu xử lý luồng miễn phí
  trong bối cảnh gián đoạn. free_thread_stack() có thể được gọi khi bị gián đoạn
  bối cảnh.
- Trên arm64, tất cả các ngăn xếp của VMAP cần được căn chỉnh giống nhau để đảm bảo
  tính năng phát hiện tràn ngăn xếp của VMAP'd hoạt động chính xác. Vòm cụ thể
  Bộ cấp phát ngăn xếp vmap sẽ xử lý chi tiết này.
- Điều này không giải quyết được các ngăn xếp bị gián đoạn - theo bản vá gốc

Phân bổ ngăn xếp luồng được bắt đầu từ clone(), fork(), vfork(),
kernel_thread() thông qua kernel_clone(). Đây là một số gợi ý để tìm kiếm
cơ sở mã để hiểu thời điểm và cách phân bổ ngăn xếp luồng.

Phần lớn mã nằm trong:
ZZ0000ZZ.

Con trỏ stack_vm_area trong task_struct theo dõi hầu như được phân bổ
ngăn xếp và một con trỏ stack_vm_area khác null đóng vai trò là dấu hiệu cho thấy
ngăn xếp hạt nhân hầu như được ánh xạ được kích hoạt.

::

cấu trúc vm_struct *stack_vm_area;

Xử lý tràn ngăn xếp
-----------------------

Các trang bảo vệ đầu và cuối giúp phát hiện tình trạng tràn ngăn xếp. Khi ngăn xếp
tràn vào các trang bảo vệ, người xử lý phải cẩn thận để không tràn
ngăn xếp một lần nữa. Khi các trình xử lý được gọi, có thể có rất ít
không gian ngăn xếp còn lại.

Trên x86, việc này được thực hiện bằng cách xử lý lỗi trang chỉ ra kernel
tràn ngăn xếp trên ngăn xếp lỗi kép.

Kiểm tra phân bổ VMAP với các trang bảo vệ
----------------------------------------

Làm cách nào để chúng tôi đảm bảo rằng VMAP_STACK thực sự đang được phân bổ với vị trí dẫn đầu
và trang bảo vệ theo sau? Các bài kiểm tra lkdtm sau đây có thể giúp phát hiện bất kỳ
hồi quy.

::

làm mất hiệu lực lkdtm_STACK_GUARD_PAGE_LEADING()
        làm mất hiệu lực lkdtm_STACK_GUARD_PAGE_TRAILING()

Kết luận
-----------

- Bộ đệm percpu của ngăn xếp vmalloced có vẻ nhanh hơn một chút so với
  phân bổ ngăn xếp thứ tự cao, ít nhất là khi bộ đệm truy cập.
- THREAD_INFO_IN_TASK loại bỏ hoàn toàn thread_info dành riêng cho Arch và
  chỉ cần nhúng thread_info (chỉ chứa cờ) và 'int cpu' vào
  nhiệm vụ_struct.
- Ngăn xếp luồng có thể được giải phóng ngay khi tác vụ kết thúc (không cần
  chờ RCU) và sau đó, nếu ngăn xếp vmapped đang được sử dụng, hãy lưu vào bộ đệm
  toàn bộ ngăn xếp để sử dụng lại trên cùng một CPU.