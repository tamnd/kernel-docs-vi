.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/mmap_prepare.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
mmap_prepare gọi lại HOWTO
===========================

Giới thiệu
============

Lệnh gọi lại ZZ0000ZZ không được dùng nữa vì nó vừa là một
sự ổn định và rủi ro bảo mật, và không phải lúc nào cũng cho phép sáp nhập các khu vực liền kề
ánh xạ dẫn đến sự phân mảnh bộ nhớ không cần thiết.

Nó đã được thay thế bằng lệnh gọi lại ZZ0000ZZ
giải quyết những vấn đề này.

Móc này được gọi ngay khi bắt đầu thiết lập ánh xạ và
quan trọng là nó được gọi ZZ0000ZZ bất kỳ việc hợp nhất các ánh xạ liền kề nào đều được thực hiện
nơi.

Nếu xảy ra lỗi khi ánh xạ, nó có thể phát sinh sau khi cuộc gọi lại này được thực hiện
được viện dẫn, do đó nó nên được coi là không trạng thái một cách hiệu quả.

Nghĩa là - không có tài nguyên nào được phân bổ cũng như không được cập nhật trạng thái để phản ánh rằng một
ánh xạ đã được thiết lập, vì ánh xạ có thể được hợp nhất hoặc không thể
được ánh xạ sau khi gọi lại hoàn tất.

Cuộc gọi lại được ánh xạ
---------------

Nếu tài nguyên cần được phân bổ cho mỗi ánh xạ hoặc trạng thái như tham chiếu
số lượng cần được thao tác, việc này nên được thực hiện bằng ZZ0000ZZ
hook, bản thân nó phải được thiết lập bởi hook >mmap_prepare.

Cuộc gọi lại này chỉ được gọi nếu ánh xạ mới đã được thiết lập và không được thực hiện
được hợp nhất với bất kỳ cái nào khác và được gọi tại điểm không thể xảy ra lỗi trước đó
bản đồ được thiết lập.

Bạn có thể trả về lỗi cho chính cuộc gọi lại, điều này sẽ khiến ánh xạ
trở nên không được ánh xạ và lỗi được trả về cho người gọi mmap(). Điều này rất hữu ích nếu
nguồn lực cần được phân bổ và việc phân bổ đó có thể thất bại.

Cách sử dụng
==========

Trong cấu trúc file_Operation của trình điều khiển của bạn, hãy chỉ định ZZ0000ZZ
gọi lại thay vì gọi ZZ0001ZZ, ví dụ: cho ext4:

.. code-block:: C

    const struct file_operations ext4_file_operations = {
        ...
        .mmap_prepare    = ext4_file_mmap_prepare,
    };

Cái này có chữ ký của ZZ0000ZZ.

Kiểm tra loại struct vm_area_desc:

.. code-block:: C

    struct vm_area_desc {
        /* Immutable state. */
        const struct mm_struct *const mm;
        struct file *const file; /* May vary from vm_file in stacked callers. */
        unsigned long start;
        unsigned long end;

        /* Mutable fields. Populated with initial state. */
        pgoff_t pgoff;
        struct file *vm_file;
        vma_flags_t vma_flags;
        pgprot_t page_prot;

        /* Write-only fields. */
        const struct vm_operations_struct *vm_ops;
        void *private_data;

        /* Take further action? */
        struct mmap_action action;
    };

Điều này rất đơn giản - bạn có tất cả các trường bạn cần để thiết lập
ánh xạ và bạn có thể cập nhật các trường có thể thay đổi và có thể ghi, ví dụ:

.. code-block:: C

    static int ext4_file_mmap_prepare(struct vm_area_desc *desc)
    {
        int ret;
        struct file *file = desc->file;
        struct inode *inode = file->f_mapping->host;

        ...

        file_accessed(file);
        if (IS_DAX(file_inode(file))) {
            desc->vm_ops = &ext4_dax_vm_ops;
            vma_desc_set_flags(desc, VMA_HUGEPAGE_BIT);
        } else {
            desc->vm_ops = &ext4_file_vm_ops;
        }
        return 0;
    }

Điều quan trọng là bạn không còn phải loay hoay với số tham chiếu hoặc khóa nữa
khi cập nhật các trường này - ZZ0000ZZ.

Mọi thứ đều được đảm nhiệm bởi mã bản đồ.

Cờ VMA
---------

Cùng với ZZ0000ZZ, cờ VMA đã trải qua một cuộc đại tu. Trước đây ở đâu
bạn sẽ gọi một trong các vm_flags_init(), vm_flags_reset(), vm_flags_set(),
vm_flags_clear() và vm_flags_mod() để sửa đổi cờ (và để có
khóa được thực hiện chính xác cho bạn, điều này không còn cần thiết nữa.

Ngoài ra, cách tiếp cận truyền thống là chỉ định cờ VMA thông qua ZZ0000ZZ, ZZ0001ZZ,
v.v. - tức là việc sử dụng macro ZZ0002ZZ- cũng đã thay đổi.

Khi triển khai mmap_prepare(), các cờ tham chiếu theo số bit của chúng, được xác định
dưới dạng macro ZZ0000ZZ, ví dụ: ZZ0001ZZ, ZZ0002ZZ, v.v.,
và sử dụng một trong (trong đó ZZ0003ZZ là con trỏ tới struct vm_area_desc):

* ZZ0000ZZ - Chỉ định danh sách các cờ được phân tách bằng dấu phẩy
  bạn muốn kiểm tra (xem _any_ có được đặt hay không), ví dụ: - ZZ0001ZZ - trả về ZZ0002ZZ nếu một trong hai được đặt,
  nếu không thì ZZ0003ZZ.
* ZZ0004ZZ - Cập nhật các cờ mô tả VMA để đặt
  cờ bổ sung được chỉ định bởi danh sách được phân tách bằng dấu phẩy,
  ví dụ: -ZZ0005ZZ.
* ZZ0006ZZ - Cập nhật các cờ mô tả VMA để xóa
  cờ được chỉ định bởi danh sách được phân tách bằng dấu phẩy, ví dụ: -ZZ0007ZZ.

hành động
=======

Bây giờ bạn có thể dễ dàng thực hiện các hành động trên bản đồ sau khi được thiết lập bởi
sử dụng các hàm trợ giúp đơn giản được gọi dựa trên struct vm_area_desc
con trỏ. Đây là:

* mmap_action_remap() - Ánh xạ lại một phạm vi chỉ bao gồm PFN cho một phạm vi cụ thể
  phạm vi bắt đầu bằng địa chỉ ảo và số PFN có kích thước đã đặt.

* mmap_action_remap_full() - Tương tự như mmap_action_remap(), chỉ ánh xạ lại
  toàn bộ ánh xạ từ ZZ0000ZZ trở đi.

* mmap_action_ioremap() - Giống như mmap_action_remap(), chỉ thực hiện I/O
  ánh xạ lại.

* mmap_action_ioremap_full() - Tương tự như mmap_action_ioremap(), chỉ ánh xạ lại
  toàn bộ ánh xạ từ ZZ0000ZZ trở đi.

* mmap_action_simple_ioremap() - Thiết lập bản sửa lại I/O từ một địa chỉ được chỉ định
  địa chỉ vật lý và trên một độ dài xác định.

* mmap_action_map_kernel_pages() - Ánh xạ một mảng được chỉ định của ZZ0000ZZ
  con trỏ trong VMA từ một offset cụ thể.

* mmap_action_map_kernel_pages_full() - Ánh xạ một mảng con trỏ ZZ0000ZZ được chỉ định trên toàn bộ VMA. Người gọi phải đảm bảo có
  đủ các mục trong mảng trang để bao quát toàn bộ phạm vi của
  được mô tả VMA.

ZZ0001ZZ Trường ZZ0000ZZ thường không bao giờ được thao tác trực tiếp,
đúng hơn là bạn nên sử dụng một trong những trợ giúp này.