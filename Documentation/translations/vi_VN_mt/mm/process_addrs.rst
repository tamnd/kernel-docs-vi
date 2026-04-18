.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/process_addrs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===================
Địa chỉ quy trình
=================

.. toctree::
   :maxdepth: 3


Phạm vi bộ nhớ của người dùng được kernel theo dõi thông qua Vùng bộ nhớ ảo hoặc
'VMA thuộc loại ZZ0000ZZ.

Mỗi VMA mô tả một dải bộ nhớ gần như liền kề với các
thuộc tính, mỗi thuộc tính được mô tả bởi ZZ0000ZZ
đối tượng. Quyền truy cập vùng người dùng bên ngoài VMA là không hợp lệ ngoại trừ trường hợp
ngăn xếp liền kề VMA có thể được mở rộng để chứa địa chỉ được truy cập.

Tất cả các VMA được chứa trong một và chỉ một không gian địa chỉ ảo, được mô tả
bởi một đối tượng ZZ0000ZZ được tham chiếu bởi tất cả các tác vụ (nghĩa là
thread) chia sẻ không gian địa chỉ ảo. Chúng tôi gọi đây là
ZZ0001ZZ.

Mỗi đối tượng mm chứa cấu trúc dữ liệu cây phong mô tả tất cả VMA
trong không gian địa chỉ ảo.

.. note:: An exception to this is the 'gate' VMA which is provided by
          architectures which use :c:struct:`!vsyscall` and is a global static
          object which does not belong to any specific mm.

-------
Khóa
-------

Hạt nhân được thiết kế để có khả năng mở rộng cao đối với các hoạt động đọc đồng thời
trên VMA ZZ0000ZZ nên cần có một bộ khóa phức tạp để đảm bảo bộ nhớ
tham nhũng không xảy ra.

.. note:: Locking VMAs for their metadata does not have any impact on the memory
          they describe nor the page tables that map them.

Thuật ngữ
-----------

* ZZ0013ZZ - Mỗi MM có một semaphore đọc/ghi ZZ0000ZZ
  khóa ở mức độ chi tiết của không gian địa chỉ quy trình có thể có được thông qua
  ZZ0001ZZ, ZZ0002ZZ và các biến thể.
* ZZ0014ZZ - Khóa VMA ở mức độ chi tiết VMA (tất nhiên) hoạt động
  như một semaphore đọc/ghi trong thực tế. Khóa đọc VMA có được thông qua
  ZZ0003ZZ (và được mở khóa thông qua ZZ0004ZZ) và
  khóa ghi qua vma_start_write() hoặc vma_start_write_killable()
  (tất cả các khóa ghi VMA đều được mở khóa
  tự động khi khóa ghi mmap được giải phóng). Để lấy khóa ghi VMA
  bạn ZZ0015ZZ đã có ZZ0005ZZ.
* ZZ0016ZZ - Khi cố gắng truy cập VMA thông qua ánh xạ ngược thông qua
  Đối tượng ZZ0006ZZ hoặc ZZ0007ZZ
  (có thể truy cập từ folio qua ZZ0008ZZ). VMA phải được ổn định thông qua
  ZZ0009ZZ hoặc ZZ0010ZZ cho
  bộ nhớ ẩn danh và ZZ0011ZZ hoặc
  ZZ0012ZZ cho bộ nhớ hỗ trợ tập tin. Chúng tôi đề cập đến những điều này
  khóa dưới dạng khóa ánh xạ ngược hoặc 'khóa rmap' để cho ngắn gọn.

Chúng tôi thảo luận riêng về khóa bảng trang trong phần dành riêng bên dưới.

Điều đầu tiên ZZ0000ZZ của các ổ khóa này đạt được là ZZ0001ZZ VMA
trong cây MM. Tức là đảm bảo rằng đối tượng VMA sẽ không bị
đã bị xóa khỏi bạn và cũng không được sửa đổi (ngoại trừ một số trường cụ thể
được mô tả dưới đây).

Việc ổn định VMA cũng giữ không gian địa chỉ được mô tả xung quanh.

Khóa sử dụng
----------

Nếu bạn muốn các trường siêu dữ liệu ZZ0000ZZ VMA hoặc chỉ giữ VMA ổn định, bạn
phải thực hiện một trong các thao tác sau:

* Nhận khóa đọc mmap ở mức độ chi tiết MM thông qua ZZ0000ZZ (hoặc
  biến thể phù hợp), mở khóa bằng ZZ0001ZZ phù hợp khi
  bạn đã hoàn tất với VMA, ZZ0004ZZ
* Cố gắng lấy khóa đọc VMA qua ZZ0002ZZ. Điều này cố gắng
  lấy được khóa một cách nguyên tử nên có thể thất bại, trong trường hợp đó logic dự phòng là
  thay vào đó được yêu cầu lấy khóa đọc mmap nếu điều này trả về ZZ0003ZZ,
  ZZ0005ZZ
* Có được khóa rmap trước khi duyệt qua cây khoảng thời gian bị khóa (cho dù
  ẩn danh hoặc được hỗ trợ bằng tệp) để có được VMA cần thiết.

Nếu bạn muốn các trường siêu dữ liệu ZZ0000ZZ VMA thì mọi thứ sẽ khác nhau tùy thuộc vào
trường (chúng tôi khám phá chi tiết từng trường VMA bên dưới). Đối với đa số bạn phải:

* Nhận khóa ghi mmap ở mức độ chi tiết MM thông qua ZZ0000ZZ (hoặc
  biến thể phù hợp), mở khóa bằng ZZ0001ZZ phù hợp khi
  bạn đã hoàn tất với VMA, ZZ0006ZZ
* Nhận khóa ghi VMA qua ZZ0002ZZ cho mỗi VMA mà bạn muốn
  sửa đổi, sẽ được phát hành tự động khi ZZ0003ZZ được
  được gọi.
* Nếu bạn muốn có thể ghi vào trường ZZ0004ZZ, bạn cũng phải ẩn VMA
  từ ánh xạ ngược bằng cách lấy ZZ0005ZZ.

Khóa VMA đặc biệt ở chỗ bạn phải có khóa mmap ZZ0001ZZ ZZ0002ZZ
để có được khóa VMA ZZ0003ZZ. Tuy nhiên, khóa VMA ZZ0004ZZ có thể được
có được mà không cần bất kỳ khóa nào khác (ZZ0000ZZ sau đó sẽ có được
phát hành khóa RCU để tra cứu VMA cho bạn).

Điều này hạn chế tác động của người viết đối với người đọc, vì người viết có thể tương tác với
một VMA trong khi một đầu đọc tương tác đồng thời với một đầu đọc khác.

.. note:: The primary users of VMA read locks are page fault handlers, which
          means that without a VMA write lock, page faults will run concurrent with
          whatever you are doing.

Kiểm tra tất cả các trạng thái khóa hợp lệ:

.. table::

   ========= ======== ========= ======= ===== =========== ==========
   mmap lock VMA lock rmap lock Stable? Read? Write most? Write all?
   ========= ======== ========= ======= ===== =========== ==========
   \-        \-       \-        N       N     N           N
   \-        R        \-        Y       Y     N           N
   \-        \-       R/W       Y       Y     N           N
   R/W       \-/R     \-/R/W    Y       Y     N           N
   W         W        \-/R      Y       Y     Y           N
   W         W        W         Y       Y     Y           Y
   ========= ======== ========= ======= ===== =========== ==========

.. warning:: While it's possible to obtain a VMA lock while holding an mmap read lock,
             attempting to do the reverse is invalid as it can result in deadlock - if
             another task already holds an mmap write lock and attempts to acquire a VMA
             write lock that will deadlock on the VMA read lock.

Tất cả các khóa này hoạt động như các ẩn dụ đọc/ghi trong thực tế, vì vậy bạn có thể
có được khóa đọc hoặc khóa ghi cho mỗi khóa này.

.. note:: Generally speaking, a read/write semaphore is a class of lock which
          permits concurrent readers. However a write lock can only be obtained
          once all readers have left the critical region (and pending readers
          made to wait).

          This renders read locks on a read/write semaphore concurrent with other
          readers and write locks exclusive against all others holding the semaphore.

Các trường VMA
^^^^^^^^^^

Chúng ta có thể chia nhỏ các trường ZZ0000ZZ theo mục đích của chúng, điều này làm cho nó
dễ dàng hơn để khám phá các đặc điểm khóa của chúng:

.. note:: We exclude VMA lock-specific fields here to avoid confusion, as these
          are in effect an internal implementation detail.

.. table:: Virtual layout fields

   ===================== ======================================== ===========
   Field                 Description                              Write lock
   ===================== ======================================== ===========
   :c:member:`!vm_start` Inclusive start virtual address of range mmap write,
                         VMA describes.                           VMA write,
                                                                  rmap write.
   :c:member:`!vm_end`   Exclusive end virtual address of range   mmap write,
                         VMA describes.                           VMA write,
                                                                  rmap write.
   :c:member:`!vm_pgoff` Describes the page offset into the file, mmap write,
                         the original page offset within the      VMA write,
                         virtual address space (prior to any      rmap write.
                         :c:func:`!mremap`), or PFN if a PFN map
                         and the architecture does not support
                         :c:macro:`!CONFIG_ARCH_HAS_PTE_SPECIAL`.
   ===================== ======================================== ===========

Các trường này mô tả kích thước, điểm bắt đầu và kết thúc của VMA và do đó không thể
được sửa đổi mà không bị ẩn khỏi ánh xạ ngược vì các trường này
được sử dụng để xác định vị trí VMA trong cây khoảng thời gian ánh xạ ngược.

.. table:: Core fields

   ============================ ======================================== =========================
   Field                        Description                              Write lock
   ============================ ======================================== =========================
   :c:member:`!vm_mm`           Containing mm_struct.                    None - written once on
                                                                         initial map.
   :c:member:`!vm_page_prot`    Architecture-specific page table         mmap write, VMA write.
                                protection bits determined from VMA
                                flags.
   :c:member:`!vm_flags`        Read-only access to VMA flags describing N/A
                                attributes of the VMA, in union with
                                private writable
                                :c:member:`!__vm_flags`.
   :c:member:`!__vm_flags`      Private, writable access to VMA flags    mmap write, VMA write.
                                field, updated by
                                :c:func:`!vm_flags_*` functions.
   :c:member:`!vm_file`         If the VMA is file-backed, points to a   None - written once on
                                struct file object describing the        initial map.
                                underlying file, if anonymous then
                                :c:macro:`!NULL`.
   :c:member:`!vm_ops`          If the VMA is file-backed, then either   None - Written once on
                                the driver or file-system provides a     initial map by
                                :c:struct:`!struct vm_operations_struct` :c:func:`!f_ops->mmap()`.
                                object describing callbacks to be
                                invoked on VMA lifetime events.
   :c:member:`!vm_private_data` A :c:member:`!void *` field for          Handled by driver.
                                driver-specific metadata.
   ============================ ======================================== =========================

Đây là các trường cốt lõi mô tả MM mà VMA thuộc về và các thuộc tính của nó.

.. table:: Config-specific fields

   ================================= ===================== ======================================== ===============
   Field                             Configuration option  Description                              Write lock
   ================================= ===================== ======================================== ===============
   :c:member:`!anon_name`            CONFIG_ANON_VMA_NAME  A field for storing a                    mmap write,
                                                           :c:struct:`!struct anon_vma_name`        VMA write.
                                                           object providing a name for anonymous
                                                           mappings, or :c:macro:`!NULL` if none
                                                           is set or the VMA is file-backed. The
							   underlying object is reference counted
							   and can be shared across multiple VMAs
							   for scalability.
   :c:member:`!swap_readahead_info`  CONFIG_SWAP           Metadata used by the swap mechanism      mmap read,
                                                           to perform readahead. This field is      swap-specific
                                                           accessed atomically.                     lock.
   :c:member:`!vm_policy`            CONFIG_NUMA           :c:type:`!mempolicy` object which        mmap write,
                                                           describes the NUMA behaviour of the      VMA write.
                                                           VMA. The underlying object is reference
							   counted.
   :c:member:`!numab_state`          CONFIG_NUMA_BALANCING :c:type:`!vma_numab_state` object which  mmap read,
                                                           describes the current state of           numab-specific
                                                           NUMA balancing in relation to this VMA.  lock.
                                                           Updated under mmap read lock by
                                                           :c:func:`!task_numa_work`.
   :c:member:`!vm_userfaultfd_ctx`   CONFIG_USERFAULTFD    Userfaultfd context wrapper object of    mmap write,
                                                           type :c:type:`!vm_userfaultfd_ctx`,      VMA write.
                                                           either of zero size if userfaultfd is
                                                           disabled, or containing a pointer
                                                           to an underlying
                                                           :c:type:`!userfaultfd_ctx` object which
                                                           describes userfaultfd metadata.
   ================================= ===================== ======================================== ===============

Các trường này có hiện diện hay không tùy thuộc vào việc kernel có liên quan
tùy chọn cấu hình được thiết lập.

.. table:: Reverse mapping fields

   =================================== ========================================= ============================
   Field                               Description                               Write lock
   =================================== ========================================= ============================
   :c:member:`!shared.rb`              A red/black tree node used, if the        mmap write, VMA write,
                                       mapping is file-backed, to place the VMA  i_mmap write.
                                       in the
                                       :c:member:`!struct address_space->i_mmap`
                                       red/black interval tree.
   :c:member:`!shared.rb_subtree_last` Metadata used for management of the       mmap write, VMA write,
                                       interval tree if the VMA is file-backed.  i_mmap write.
   :c:member:`!anon_vma_chain`         List of pointers to both forked/CoW’d     mmap read, anon_vma write.
                                       :c:type:`!anon_vma` objects and
                                       :c:member:`!vma->anon_vma` if it is
                                       non-:c:macro:`!NULL`.
   :c:member:`!anon_vma`               :c:type:`!anon_vma` object used by        When :c:macro:`NULL` and
                                       anonymous folios mapped exclusively to    setting non-:c:macro:`NULL`:
                                       this VMA. Initially set by                mmap read, page_table_lock.
                                       :c:func:`!anon_vma_prepare` serialised
                                       by the :c:macro:`!page_table_lock`. This  When non-:c:macro:`NULL` and
                                       is set as soon as any page is faulted in. setting :c:macro:`NULL`:
                                                                                 mmap write, VMA write,
                                                                                 anon_vma write.
   =================================== ========================================= ============================

Các trường này được sử dụng để đặt VMA trong ánh xạ ngược và để
ánh xạ ẩn danh, để có thể truy cập cả hai đối tượng ZZ0000ZZ có liên quan
và ZZ0001ZZ trong đó các folio được ánh xạ riêng cho VMA này sẽ
cư trú.

.. note:: If a file-backed mapping is mapped with :c:macro:`!MAP_PRIVATE` set
          then it can be in both the :c:type:`!anon_vma` and :c:type:`!i_mmap`
          trees at the same time, so all of these fields might be utilised at
          once.

Bảng trang
-----------

Chúng tôi sẽ không nói một cách thấu đáo về chủ đề này nhưng nói rộng ra, bản đồ bảng trang
địa chỉ ảo đến địa chỉ vật lý thông qua một loạt các bảng trang, mỗi bảng
chứa các mục có địa chỉ vật lý cho cấp bảng trang tiếp theo
(cùng với cờ) và ở cấp độ lá, địa chỉ vật lý của
các trang dữ liệu vật lý cơ bản hoặc một mục nhập đặc biệt như mục nhập trao đổi,
mục di chuyển hoặc điểm đánh dấu đặc biệt khác. Phần bù vào các trang này được cung cấp
bởi chính địa chỉ ảo đó.

Trong Linux, chúng được chia thành năm cấp độ - PGD, P4D, PUD, PMD và PTE. Rất lớn
các trang có thể loại bỏ một hoặc hai cấp độ này, nhưng trong trường hợp này chúng tôi
thường coi cấp lá là cấp PTE bất kể.

.. note:: In instances where the architecture supports fewer page tables than
	  five the kernel cleverly 'folds' page table levels, that is stubbing
	  out functions related to the skipped levels. This allows us to
	  conceptually act as if there were always five levels, even if the
	  compiler might, in practice, eliminate any code relating to missing
	  ones.

Có bốn thao tác chính thường được thực hiện trên bảng trang:

1. Bảng trang ZZ0006ZZ - Đơn giản chỉ cần đọc bảng trang để duyệt qua
   họ. Điều này chỉ yêu cầu VMA được giữ ổn định, do đó, một khóa
   thiết lập điều này đủ để truyền tải (cũng có các biến thể không khóa
   loại bỏ ngay cả yêu cầu này, chẳng hạn như ZZ0000ZZ). có
   cũng là một trường hợp đặc biệt của việc duyệt bảng trang cho các vùng không phải VMA mà chúng ta
   xem xét riêng dưới đây.
2. Ánh xạ bảng trang ZZ0007ZZ - Cho dù tạo ánh xạ mới hay
   sửa đổi một cái hiện có theo cách để thay đổi danh tính của nó. Cái này
   yêu cầu VMA được giữ ổn định thông qua khóa mmap hoặc VMA (rõ ràng là không
   khóa rmap).
3. Các mục trong bảng trang ZZ0008ZZ - Đây là tên mà kernel gọi
   chỉ xóa ánh xạ bảng trang ở cấp độ lá, trong khi để lại tất cả các trang
   bàn tại chỗ. Đây là một thao tác rất phổ biến trong kernel được thực hiện trên
   cắt bớt tập tin, thao tác ZZ0001ZZ thông qua
   ZZ0002ZZ và những thứ khác. Điều này được thực hiện bởi một số chức năng
   bao gồm ZZ0003ZZ và ZZ0004ZZ.
   VMA chỉ cần được giữ ổn định cho hoạt động này.
4. Bảng trang ZZ0009ZZ - Cuối cùng, khi kernel loại bỏ các bảng trang khỏi một
   Quá trình người dùng (thường thông qua ZZ0005ZZ) phải hết sức cẩn thận
   được thực hiện để đảm bảo việc này được thực hiện một cách an toàn, vì logic này cuối cùng đã giải phóng tất cả các trang
   các bảng trong phạm vi đã chỉ định, bỏ qua các mục lá hiện có (nó giả sử
   người gọi vừa cắt phạm vi vừa ngăn chặn bất kỳ lỗi nào khác hoặc
   sửa đổi bên trong nó).

.. note:: Modifying mappings for reclaim or migration is performed under rmap
          lock as it, like zapping, does not fundamentally modify the identity
          of what is being mapped.

Các dãy ZZ0000ZZ và ZZ0001ZZ có thể được thực hiện bằng cách giữ bất kỳ một trong các
các khóa được mô tả trong phần thuật ngữ ở trên - đó là khóa mmap,
Khóa VMA hoặc một trong các khóa ánh xạ ngược.

Nghĩa là - miễn là bạn giữ VMA ZZ0000ZZ có liên quan - bạn có thể tiếp tục
trước và thực hiện các thao tác này trên các bảng trang (mặc dù bên trong, kernel
các hoạt động thực hiện việc ghi cũng yêu cầu các khóa bảng trang nội bộ để
serialise - xem phần chi tiết triển khai bảng trang để biết thêm chi tiết).

.. note:: We free empty PTE tables on zap under the RCU lock - this does not
          change the aforementioned locking requirements around zapping.

Khi các mục trong bảng trang ZZ0000ZZ, khóa mmap hoặc VMA phải được giữ để
giữ cho VMA ổn định. Chúng tôi khám phá lý do tại sao điều này lại có trong chi tiết khóa bảng trang
phần bên dưới.

Bảng trang ZZ0000ZZ là một hoạt động quản lý bộ nhớ trong hoàn toàn và
có yêu cầu đặc biệt (xem phần giải phóng trang bên dưới để biết thêm chi tiết).

.. warning:: When **freeing** page tables, it must not be possible for VMAs
             containing the ranges those page tables map to be accessible via
             the reverse mapping.

             The :c:func:`!free_pgtables` function removes the relevant VMAs
             from the reverse mappings, but no other VMAs can be permitted to be
             accessible and span the specified range.

Duyệt qua các bảng trang không phải VMA
------------------------------

Ở trên chúng ta đã tập trung vào việc duyệt các bảng trang thuộc VMA. Nó cũng là
có thể duyệt qua các bảng trang không được VMA đại diện.

Bản thân việc ánh xạ bảng trang hạt nhân thường được quản lý nhưng bất kỳ phần nào của
kernel đã thiết lập chúng và các quy tắc khóa nói trên không được áp dụng -
ví dụ vmalloc có bộ khóa riêng được sử dụng cho
thiết lập và phá bỏ các bảng trang của nó.

Tuy nhiên, để thuận tiện, chúng tôi cung cấp ZZ0000ZZ
chức năng được đồng bộ hóa thông qua khóa mmap trên ZZ0001ZZ
khởi tạo kernel của đối tượng siêu dữ liệu ZZ0002ZZ.

Nếu một thao tác yêu cầu quyền truy cập độc quyền, khóa ghi sẽ được sử dụng, nhưng nếu không,
khóa đọc là đủ - chúng tôi chỉ xác nhận rằng ít nhất đã có được khóa đọc.

Vì, ngoài vmalloc và phích cắm nóng bộ nhớ, các bảng trang kernel không bị rách
thường xuyên giảm tất cả - điều này thường là đủ, tuy nhiên bất kỳ người gọi điều này
chức năng phải đảm bảo rằng mọi khóa cần thiết bổ sung đều được cung cấp trong
tiến lên.

Chúng tôi cũng cho phép một trường hợp thực sự bất thường là việc truyền tải các phạm vi không phải VMA trong
Phạm vi ZZ0001ZZ, do ZZ0000ZZ cung cấp.

Điều này chỉ có một người dùng - logic kết xuất bảng trang chung (được triển khai trong
ZZ0000ZZ) - tìm cách hiển thị tất cả ánh xạ cho mục đích gỡ lỗi
ngay cả khi chúng rất khác thường (có thể là kiến trúc cụ thể) và không
được hỗ trợ bởi VMA.

Chúng ta phải hết sức cẩn thận trong trường hợp này vì việc triển khai ZZ0000ZZ
tách các VMA dưới khóa ghi mmap trước khi xé các bảng trang dưới một
khóa đọc mmap bị hạ cấp.

Điều này có nghĩa là một hoạt động như vậy có thể chạy đua với điều này và do đó, ZZ0000ZZ mmap
khóa là cần thiết.

Thứ tự khóa
-------------

Vì chúng tôi có nhiều khóa trên kernel nên có thể được lấy hoặc không ở
cùng lúc với các khóa mm hoặc VMA rõ ràng, chúng ta phải cảnh giác với việc đảo ngược khóa và
ZZ0000ZZ trong đó khóa được lấy và mở khóa trở nên rất quan trọng.

.. note:: Lock inversion occurs when two threads need to acquire multiple locks,
   but in doing so inadvertently cause a mutual deadlock.

   For example, consider thread 1 which holds lock A and tries to acquire lock B,
   while thread 2 holds lock B and tries to acquire lock A.

   Both threads are now deadlocked on each other. However, had they attempted to
   acquire locks in the same order, one would have waited for the other to
   complete its work and no deadlock would have occurred.

Lời bình mở đầu trong ZZ0000ZZ mô tả chi tiết các yêu cầu
thứ tự các khóa trong mã quản lý bộ nhớ:

.. code-block::

  inode->i_rwsem        (while writing or truncating, not reading or faulting)
    mm->mmap_lock
      mapping->invalidate_lock (in filemap_fault)
        folio_lock
          hugetlbfs_i_mmap_rwsem_key (in huge_pmd_share, see hugetlbfs below)
            vma_start_write
              mapping->i_mmap_rwsem
                anon_vma->rwsem
                  mm->page_table_lock or pte_lock
                    swap_lock (in swap_duplicate, swap_info_get)
                      mmlist_lock (in mmput, drain_mmlist and others)
                      mapping->private_lock (in block_dirty_folio)
                          i_pages lock (widely used)
                            lruvec->lru_lock (in folio_lruvec_lock_irq)
                      inode->i_lock (in set_page_dirty's __mark_inode_dirty)
                      bdi.wb->list_lock (in set_page_dirty's __mark_inode_dirty)
                        sb_lock (within inode_lock in fs/fs-writeback.c)
                        i_pages lock (widely used, in set_page_dirty,
                                  in arch-dependent flush_dcache_mmap_lock,
                                  within bdi.wb->list_lock in __sync_single_inode)

Ngoài ra còn có nhận xét thứ tự khóa dành riêng cho hệ thống tệp nằm ở đầu
ZZ0000ZZ:

.. code-block::

  ->i_mmap_rwsem                        (truncate_pagecache)
    ->private_lock                      (__free_pte->block_dirty_folio)
      ->swap_lock                       (exclusive_swap_page, others)
        ->i_pages lock

  ->i_rwsem
    ->invalidate_lock                   (acquired by fs in truncate path)
      ->i_mmap_rwsem                    (truncate->unmap_mapping_range)

  ->mmap_lock
    ->i_mmap_rwsem
      ->page_table_lock or pte_lock     (various, mainly in memory.c)
        ->i_pages lock                  (arch-dependent flush_dcache_mmap_lock)

  ->mmap_lock
    ->invalidate_lock                   (filemap_fault)
      ->lock_page                       (filemap_fault, access_process_vm)

  ->i_rwsem                             (generic_perform_write)
    ->mmap_lock                         (fault_in_readable->do_page_fault)

  bdi->wb.list_lock
    sb_lock                             (fs/fs-writeback.c)
    ->i_pages lock                      (__sync_single_inode)

  ->i_mmap_rwsem
    ->anon_vma.lock                     (vma_merge)

  ->anon_vma.lock
    ->page_table_lock or pte_lock       (anon_vma_prepare and various)

  ->page_table_lock or pte_lock
    ->swap_lock                         (try_to_unmap_one)
    ->private_lock                      (try_to_unmap_one)
    ->i_pages lock                      (try_to_unmap_one)
    ->lruvec->lru_lock                  (follow_page_mask->mark_page_accessed)
    ->lruvec->lru_lock                  (check_pte_range->folio_isolate_lru)
    ->private_lock                      (folio_remove_rmap_pte->set_page_dirty)
    ->i_pages lock                      (folio_remove_rmap_pte->set_page_dirty)
    bdi.wb->list_lock                   (folio_remove_rmap_pte->set_page_dirty)
    ->inode->i_lock                     (folio_remove_rmap_pte->set_page_dirty)
    bdi.wb->list_lock                   (zap_pte_range->set_page_dirty)
    ->inode->i_lock                     (zap_pte_range->set_page_dirty)
    ->private_lock                      (zap_pte_range->block_dirty_folio)

Vui lòng kiểm tra trạng thái hiện tại của những nhận xét này, chúng có thể đã thay đổi kể từ
thời điểm viết tài liệu này.

------------------------------
Khóa chi tiết triển khai
------------------------------

.. warning:: Locking rules for PTE-level page tables are very different from
             locking rules for page tables at other levels.

Chi tiết khóa bảng trang
--------------------------

.. note:: This section explores page table locking requirements for page tables
          encompassed by a VMA. See the above section on non-VMA page table
          traversal for details on how we handle that case.

Ngoài các khóa được mô tả trong phần thuật ngữ ở trên, chúng ta còn có
các khóa bổ sung dành riêng cho bảng trang:

* ZZ0001ZZ - Bảng trang cấp cao hơn, đó là PGD, P4D
  và PUD đều sử dụng độ chi tiết của không gian địa chỉ quy trình
  Khóa ZZ0000ZZ khi sửa đổi.

* ZZ0003ZZ - PMD và PTE đều có khóa chi tiết
  hoặc được lưu giữ trong các folio mô tả các bảng trang hoặc được phân bổ
  được phân tách và chỉ vào các tờ giấy nếu ZZ0000ZZ là
  thiết lập. Khóa xoay PMD có được thông qua ZZ0001ZZ, tuy nhiên PTE thì
  được ánh xạ vào bộ nhớ cao hơn (nếu là hệ thống 32 bit) và được khóa cẩn thận thông qua
  ZZ0002ZZ.

Các khóa này thể hiện mức tối thiểu cần thiết để tương tác với mỗi bảng trang
mức độ, nhưng có những yêu cầu cao hơn.

Điều quan trọng, hãy lưu ý rằng trên bảng trang ZZ0000ZZ, đôi khi không có bảng trang nào như vậy
ổ khóa được lấy. Tuy nhiên, ở cấp độ PTE, ít nhất bảng trang đồng thời
phải ngăn chặn việc xóa (sử dụng RCU) và bảng trang phải được ánh xạ vào
bộ nhớ cao, xem bên dưới.

Việc đọc các mục trong bảng trang có được chú ý hay không tùy thuộc vào
kiến trúc, xem phần về tính nguyên tử bên dưới.

Quy tắc khóa
^^^^^^^^^^^^^

Chúng ta thiết lập các quy tắc khóa cơ bản khi tương tác với các bảng trang:

* Khi thay đổi một mục trong bảng trang, bảng trang sẽ khóa bảng trang đó
  ZZ0001ZZ được giữ lại, trừ khi bạn có thể cho rằng không ai có thể truy cập trang một cách an toàn
  các bảng đồng thời (chẳng hạn như khi gọi ZZ0000ZZ).
* Đọc và ghi vào các mục trong bảng trang phải là ZZ0002ZZ
  nguyên tử. Xem phần về tính nguyên tử bên dưới để biết chi tiết.
* Việc điền các mục trống trước đó yêu cầu khóa mmap hoặc VMA
  được giữ (đọc hoặc ghi), làm như vậy chỉ với khóa rmap sẽ nguy hiểm (xem
  cảnh báo bên dưới).
* Như đã đề cập trước đó, việc hạ gục có thể được thực hiện trong khi chỉ cần giữ VMA
  ổn định, tức là đang giữ bất kỳ khóa mmap, VMA hoặc rmap nào.

.. warning:: Populating previously empty entries is dangerous as, when unmapping
             VMAs, :c:func:`!vms_clear_ptes` has a window of time between
             zapping (via :c:func:`!unmap_vmas`) and freeing page tables (via
             :c:func:`!free_pgtables`), where the VMA is still visible in the
             rmap tree. :c:func:`!free_pgtables` assumes that the zap has
             already been performed and removes PTEs unconditionally (along with
             all other page tables in the freed range), so installing new PTE
             entries could leak memory and also cause other unexpected and
             dangerous behaviour.

Có các quy tắc bổ sung áp dụng khi di chuyển bảng trang mà chúng tôi thảo luận
trong phần về chủ đề này dưới đây.

Bảng trang cấp độ PTE khác với bảng trang ở cấp độ khác và ở đó
là những yêu cầu bổ sung để truy cập chúng:

* Trên kiến trúc 32-bit, chúng có thể ở bộ nhớ cao (có nghĩa là chúng cần phải
  ánh xạ vào bộ nhớ kernel để có thể truy cập được).
* Khi trống, chúng có thể được hủy liên kết và giải phóng RCU trong khi giữ khóa mmap hoặc
  khóa rmap để đọc kết hợp với khóa bảng trang PTE và PMD.
  Đặc biệt, điều này xảy ra trong ZZ0000ZZ khi xử lý
  ZZ0001ZZ.
  Vì vậy, việc truy cập các bảng trang cấp PTE yêu cầu ít nhất phải có khóa đọc RCU;
  nhưng điều đó chỉ đủ cho những độc giả có thể chịu đựng được việc chạy đua cùng lúc
  bảng trang cập nhật sao cho có một PTE trống được quan sát (trong một bảng trang có
  thực tế đã được tách ra và đánh dấu để giải phóng RCU) trong khi một cái khác
  bảng trang mới đã được cài đặt ở cùng một vị trí và chứa đầy
  mục nhập. Người viết thường cần lấy khóa PTE và xác nhận lại rằng
  Mục nhập PMD vẫn đề cập đến cùng một bảng trang cấp PTE.
  Nếu người viết không quan tâm liệu đó có phải là cùng một bảng trang cấp PTE hay không thì nó
  có thể lấy khóa PMD và xác nhận lại rằng nội dung của mục nhập pmd vẫn đáp ứng
  các yêu cầu. Đặc biệt, điều này còn xảy ra ở ZZ0002ZZ
  khi xử lý ZZ0003ZZ.

Để truy cập các bảng trang cấp PTE, một trình trợ giúp như ZZ0000ZZ hoặc
ZZ0001ZZ có thể được sử dụng tùy theo yêu cầu về độ ổn định.
Chúng ánh xạ bảng trang vào bộ nhớ kernel nếu được yêu cầu, lấy khóa RCU và
tùy thuộc vào biến thể, cũng có thể tra cứu hoặc lấy khóa PTE.
Xem bình luận trên ZZ0002ZZ.

Tính nguyên tử
^^^^^^^^^

Bất kể khóa bảng trang, phần cứng MMU đều có thể cập nhật đồng thời
và các bit bẩn (có thể nhiều hơn, tùy thuộc vào kiến trúc). Ngoài ra, trang
hoạt động duyệt bảng song song (mặc dù giữ VMA ổn định) và
chức năng như bảng trang GUP-nhanh chóng duyệt qua (đọc) không khóa,
thậm chí còn không giữ cho VMA ổn định.

Khi thực hiện duyệt bảng trang và giữ VMA ổn định, cho dù
việc đọc phải được thực hiện một lần và chỉ một lần hay không phụ thuộc vào kiến trúc
(ví dụ x86-64 không yêu cầu bất kỳ biện pháp phòng ngừa đặc biệt nào).

Nếu việc ghi đang được thực hiện hoặc nếu việc đọc cho biết liệu việc ghi có diễn ra hay không
(chẳng hạn như khi cài đặt một mục trong bảng trang trong
ZZ0000ZZ), phải luôn được chăm sóc đặc biệt. Trong những trường hợp này chúng tôi
không bao giờ có thể cho rằng các khóa bảng trang cung cấp cho chúng ta quyền truy cập hoàn toàn độc quyền và
phải truy xuất các mục trong bảng trang một lần và chỉ một lần.

Nếu chúng ta đang đọc các mục trong bảng trang thì chúng ta chỉ cần đảm bảo rằng trình biên dịch
không sắp xếp lại tải của chúng tôi. Điều này đạt được thông qua ZZ0000ZZ
chức năng - ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ,
ZZ0004ZZ và ZZ0005ZZ.

Mỗi cái này sử dụng ZZ0000ZZ để đảm bảo rằng trình biên dịch đọc
mục bảng trang chỉ một lần.

Tuy nhiên, nếu chúng ta muốn thao tác một mục trong bảng trang hiện có và quan tâm đến
dữ liệu được lưu trữ trước đó, chúng ta phải tiến xa hơn và sử dụng phần cứng nguyên tử
hoạt động, ví dụ như trong ZZ0000ZZ.

Tương tự, các hoạt động không phụ thuộc vào VMA được giữ ổn định, chẳng hạn như
GUP-fast (xem ZZ0000ZZ và các trình xử lý cấp bảng trang khác nhau của nó như
ZZ0001ZZ), phải tương tác rất cẩn thận với bảng trang
các mục nhập, sử dụng các hàm như ZZ0002ZZ và tương đương cho
cấp độ bảng trang cao hơn.

Việc ghi vào các mục trong bảng trang cũng phải có tính nguyên tử thích hợp, như đã được thiết lập
bởi các chức năng ZZ0000ZZ - ZZ0001ZZ, ZZ0002ZZ,
ZZ0003ZZ, ZZ0004ZZ và ZZ0005ZZ.

Các chức năng tương tự mà các mục trong bảng trang rõ ràng phải có tính nguyên tử thích hợp,
như trong các hàm ZZ0000ZZ - ZZ0001ZZ,
ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ và
ZZ0005ZZ.

Cài đặt bảng trang
^^^^^^^^^^^^^^^^^^^^^^^

Việc cài đặt bảng trang được thực hiện với VMA được giữ ổn định rõ ràng bằng một
khóa mmap hoặc VMA ở chế độ đọc hoặc ghi (xem cảnh báo trong quy tắc khóa
phần để biết chi tiết về lý do).

Khi phân bổ P4D, PUD hoặc PMD và đặt mục nhập có liên quan ở trên
PGD, P4D hoặc PUD, ZZ0000ZZ phải được giữ. Đây là
mua lại trong ZZ0001ZZ, ZZ0002ZZ và
ZZ0003ZZ tương ứng.

.. note:: :c:func:`!__pmd_alloc` actually invokes :c:func:`!pud_lock` and
   :c:func:`!pud_lockptr` in turn, however at the time of writing it ultimately
   references the :c:member:`!mm->page_table_lock`.

Việc phân bổ PTE sẽ sử dụng ZZ0000ZZ hoặc, nếu
ZZ0001ZZ được xác định, một khóa được nhúng trong PMD
siêu dữ liệu trang vật lý ở dạng ZZ0002ZZ, được mua lại bởi
ZZ0003ZZ được gọi từ ZZ0004ZZ và cuối cùng
ZZ0005ZZ.

Cuối cùng, việc sửa đổi nội dung của PTE cần được xử lý đặc biệt, vì
Phải lấy khóa bảng trang PTE bất cứ khi nào chúng tôi muốn ổn định và độc quyền
quyền truy cập vào các mục có trong PTE, đặc biệt khi chúng tôi muốn sửa đổi
họ.

Điều này được thực hiện thông qua ZZ0000ZZ để kiểm tra cẩn thận
đảm bảo rằng PTE không thay đổi so với chúng tôi, cuối cùng gọi
ZZ0001ZZ để có được khóa xoay ở độ chi tiết PTE có trong
ZZ0002ZZ được liên kết với trang PTE vật lý. cái khóa
phải được phát hành thông qua ZZ0003ZZ.

.. note:: There are some variants on this, such as
   :c:func:`!pte_offset_map_rw_nolock` when we know we hold the PTE stable but
   for brevity we do not explore this.  See the comment for
   :c:func:`!pte_offset_map_lock` for more details.

Khi sửa đổi dữ liệu trong phạm vi, chúng tôi thường chỉ muốn phân bổ trang cao hơn
các bảng nếu cần thiết, sử dụng các khóa này để tránh chạy đua hoặc ghi đè bất cứ thứ gì,
và thiết lập/xóa dữ liệu ở mức PTE theo yêu cầu (ví dụ khi lỗi trang
hoặc hạ gục).

Một mẫu điển hình được thực hiện khi duyệt qua các mục trong bảng trang để cài đặt một ứng dụng mới
ánh xạ là để xác định một cách lạc quan xem mục nhập bảng trang trong bảng có
ở trên trống, nếu vậy thì chỉ khi đó mới lấy được khóa bảng trang và kiểm tra
một lần nữa để xem liệu nó có được phân bổ bên dưới chúng ta hay không.

Điều này cho phép việc truyền tải với các khóa bảng trang chỉ được thực hiện khi
được yêu cầu. Một ví dụ về điều này là ZZ0000ZZ.

Ở bảng trang lá đó là PTE, chúng ta không thể hoàn toàn dựa vào mẫu này được
vì chúng tôi có các khóa PMD và PTE riêng biệt và việc sập THP chẳng hạn có thể có
đã loại bỏ mục PMD cũng như PTE khỏi chúng tôi.

Đây là lý do tại sao ZZ0000ZZ truy xuất mục nhập PMD một cách dễ dàng
đối với PTE, hãy kiểm tra cẩn thận xem nó có như mong đợi hay không trước khi mua
Khóa dành riêng cho PTE, sau đó ZZ0001ZZ kiểm tra xem mục nhập PMD có như mong đợi hay không.

Nếu xảy ra hiện tượng sập THP (hoặc tương tự) thì khóa trên cả hai trang sẽ
có thể bị lấy lại, vì vậy chúng tôi có thể đảm bảo điều này được ngăn chặn trong khi khóa PTE được giữ.

Việc cài đặt các mục theo cách này đảm bảo loại trừ lẫn nhau khi ghi.

Giải phóng bảng trang
^^^^^^^^^^^^^^^^^^

Việc xé bỏ các bảng trang là một việc đòi hỏi sự quan tâm đáng kể.
quan tâm. Chắc chắn không có cách nào mà các bảng trang được chỉ định để loại bỏ có thể bị
được duyệt qua hoặc được tham chiếu bởi các tác vụ đồng thời.

Sẽ là không đủ nếu chỉ giữ khóa ghi mmap và khóa VMA (sẽ
ngăn ngừa lỗi đua xe và hoạt động rmap), vì ánh xạ được sao lưu bằng tệp có thể
bị cắt bớt chỉ dưới ZZ0000ZZ.

Kết quả là không có VMA nào có thể được truy cập thông qua ánh xạ ngược (hoặc
thông qua các cây khoảng ZZ0000ZZ hoặc ZZ0001ZZ) có thể phá bỏ các bảng trang của nó.

Hoạt động thường được thực hiện thông qua ZZ0000ZZ, giả sử
hoặc khóa ghi mmap đã được thực hiện (như được chỉ định bởi nó
Tham số ZZ0001ZZ) hoặc VMA đã không thể truy cập được.

Nó cẩn thận loại bỏ VMA khỏi tất cả các ánh xạ ngược, tuy nhiên điều quan trọng là
rằng không có tuyến đường mới nào trùng lặp với những tuyến đường này hoặc bất kỳ tuyến đường nào còn lại để cho phép truy cập vào các địa chỉ
trong phạm vi có bảng trang đang bị phá bỏ.

Ngoài ra, nó giả định rằng một zap đã được thực hiện và các bước đã được thực hiện.
được thực hiện để đảm bảo rằng không có mục nào trong bảng trang có thể được cài đặt thêm giữa
zap và lệnh gọi ZZ0000ZZ.

Vì giả định rằng tất cả các bước như vậy đã được thực hiện nên các mục trong bảng trang được
được xóa mà không khóa bảng trang (trong ZZ0000ZZ, ZZ0001ZZ,
Chức năng ZZ0002ZZ và ZZ0003ZZ.

.. note:: It is possible for leaf page tables to be torn down independent of
          the page tables above it as is done by
          :c:func:`!retract_page_tables`, which is performed under the i_mmap
          read lock, PMD, and PTE page table locks, without this level of care.

Bảng trang đang di chuyển
^^^^^^^^^^^^^^^^^

Một số chức năng thao tác các cấp độ bảng trang trên PMD (đó là PUD, P4D và PGD
bảng trang). Đáng chú ý nhất trong số này là ZZ0000ZZ, có khả năng
di chuyển các bảng trang cấp cao hơn.

Trong những trường hợp này, yêu cầu phải lấy khóa ZZ0000ZZ, nghĩa là
khóa mmap, khóa VMA và các khóa rmap có liên quan.

Bạn có thể quan sát điều này khi triển khai ZZ0000ZZ trong hàm
ZZ0001ZZ và ZZ0002ZZ thực hiện rmap
khía cạnh thu thập khóa, cuối cùng được gọi bởi ZZ0003ZZ.

Bộ phận bên trong khóa VMA
------------------

Tổng quan
^^^^^^^^

Khóa đọc VMA hoàn toàn lạc quan - nếu khóa được tranh chấp hoặc cạnh tranh
quá trình ghi đã bắt đầu thì chúng tôi không nhận được khóa đọc.

Khóa VMA ZZ0004ZZ được lấy bởi ZZ0000ZZ, trước tiên
gọi ZZ0001ZZ để đảm bảo rằng VMA được tra cứu trong RCU
phần quan trọng, sau đó cố gắng khóa VMA thông qua ZZ0002ZZ,
trước khi mở khóa RCU qua ZZ0003ZZ.

Trong trường hợp người dùng đã giữ khóa đọc mmap, ZZ0000ZZ
và ZZ0001ZZ có thể được sử dụng. Những chức năng này không
không thành công do tranh chấp khóa nhưng người gọi vẫn nên kiểm tra giá trị trả về của họ
trong trường hợp họ thất bại vì lý do khác.

VMA đọc khóa tăng bộ đếm tham chiếu ZZ0000ZZ cho chúng
thời lượng và người gọi ZZ0001ZZ phải gửi nó qua
ZZ0002ZZ.

Khóa VMA ZZ0003ZZ được lấy thông qua ZZ0000ZZ trong trường hợp
VMA sắp được sửa đổi, không giống như ZZ0001ZZ khóa luôn
có được. Khóa ghi mmap ZZ0004ZZ được giữ trong suốt thời gian ghi VMA
khóa, giải phóng hoặc hạ cấp khóa ghi mmap cũng giải phóng ghi VMA
khóa nên không có chức năng ZZ0002ZZ.

Lưu ý rằng khi khóa ghi khóa VMA, ZZ0000ZZ tạm thời
được sửa đổi để người đọc có thể phát hiện được sự hiện diện của người viết. Bộ đếm tham chiếu là
được khôi phục sau khi số thứ tự vma được sử dụng để xê-ri hóa được cập nhật.

Điều này đảm bảo ngữ nghĩa mà chúng tôi yêu cầu - Khóa ghi VMA cung cấp khả năng ghi độc quyền
truy cập vào VMA.

Chi tiết triển khai
^^^^^^^^^^^^^^^^^^^^^^

Cơ chế khóa VMA được thiết kế như một phương tiện gọn nhẹ để tránh việc sử dụng
của khóa mmap có nhiều tranh cãi. Nó được thực hiện bằng cách sử dụng sự kết hợp của một
bộ đếm tham chiếu và số thứ tự thuộc về chứa
ZZ0000ZZ và VMA.

Khóa đọc được lấy thông qua ZZ0000ZZ, đây là một phương pháp lạc quan
hoạt động, tức là nó cố gắng lấy khóa đọc nhưng trả về sai nếu nó bị khóa
không thể làm như vậy. Khi kết thúc thao tác đọc, ZZ0001ZZ được
được gọi để giải phóng khóa đọc VMA.

Việc gọi ZZ0000ZZ yêu cầu ZZ0001ZZ phải có
được gọi đầu tiên, xác nhận rằng chúng tôi đang ở phần quan trọng RCU trên VMA
đọc khóa mua lại. Sau khi có được, khóa RCU có thể được giải phóng vì nó chỉ
cần thiết để tra cứu. Điều này được trừu tượng hóa bởi ZZ0002ZZ
là giao diện mà người dùng nên sử dụng.

Việc ghi yêu cầu mmap phải được khóa ghi và khóa VMA phải được lấy thông qua
ZZ0000ZZ, tuy nhiên khóa ghi được giải phóng bằng cách chấm dứt hoặc
hạ cấp khóa ghi mmap nên không cần ZZ0001ZZ.

Tất cả điều này đạt được bằng cách sử dụng số lượng trình tự trên mỗi mm và mỗi VMA, đó là
được sử dụng để giảm độ phức tạp, đặc biệt đối với các hoạt động có khóa ghi
nhiều VMA cùng một lúc.

Nếu số chuỗi mm thì ZZ0000ZZ bằng VMA
đếm trình tự ZZ0001ZZ thì VMA bị khóa ghi. Nếu
chúng khác nhau, vậy thì không phải vậy.

Mỗi lần khóa ghi mmap được giải phóng trong ZZ0000ZZ hoặc
ZZ0001ZZ, ZZ0002ZZ được gọi
cũng tăng ZZ0003ZZ thông qua
ZZ0004ZZ.

Bằng cách này, chúng tôi đảm bảo rằng, bất kể số thứ tự của VMA, khóa ghi
không bao giờ được chỉ định không chính xác và khi chúng tôi giải phóng khóa ghi mmap, chúng tôi
giải phóng hiệu quả các khóa ghi ZZ0000ZZ VMA có trong mmap tại
cùng một lúc.

Vì khóa ghi mmap chỉ dành riêng cho những người nắm giữ nó nên tính năng tự động
việc phát hành bất kỳ khóa VMA nào khi phát hành đều có ý nghĩa, vì bạn sẽ không bao giờ muốn
giữ VMA bị khóa trong các hoạt động ghi hoàn toàn riêng biệt. Nó cũng duy trì
đúng thứ tự khóa.

Mỗi lần có được khóa đọc VMA, chúng tôi sẽ tăng ZZ0000ZZ
bộ đếm tham chiếu và kiểm tra xem số thứ tự của VMA có khớp không
của mm.

Nếu đúng như vậy, khóa đọc không thành công và ZZ0000ZZ bị loại bỏ.
Nếu không, chúng tôi giữ nguyên bộ đếm tham chiếu, loại trừ người viết, nhưng
cho phép những người đọc khác cũng có thể lấy khóa này theo RCU.

Điều quan trọng là các thao tác với cây phong được thực hiện trong ZZ0000ZZ
RCU cũng an toàn nên toàn bộ hoạt động khóa đọc được đảm bảo hoạt động
một cách chính xác.

Về mặt ghi, chúng tôi đặt một bit trong ZZ0000ZZ không thể
được người đọc sửa đổi và đợi tất cả người đọc bỏ số tham chiếu của họ.
Khi không có đầu đọc, số thứ tự của VMA được đặt khớp với số của
mm. Trong toàn bộ hoạt động này, khóa ghi mmap được giữ.

Bằng cách này, nếu có bất kỳ khóa đọc nào có hiệu lực, ZZ0000ZZ sẽ ngủ
cho đến khi những điều này được hoàn thành và đạt được sự loại trừ lẫn nhau.

Sau khi thiết lập số thứ tự của VMA, bit trong ZZ0000ZZ
cho biết một nhà văn đã bị xóa. Từ thời điểm này trở đi, số thứ tự của VMA sẽ
cho biết trạng thái khóa ghi của VMA cho đến khi khóa ghi mmap bị hủy hoặc hạ cấp.

Sự kết hợp thông minh giữa bộ đếm tham chiếu và số trình tự cho phép
thu thập khóa mỗi VMA dựa trên RCU nhanh chóng (đặc biệt là về lỗi trang).
được sử dụng ở nơi khác) với độ phức tạp tối thiểu xung quanh thứ tự khóa.

hạ cấp khóa ghi mmap
---------------------------

Khi khóa ghi mmap được giữ, người ta có quyền truy cập độc quyền vào các tài nguyên trong
mmap (với những cảnh báo thông thường về việc yêu cầu khóa ghi VMA để tránh các cuộc đua với
nhiệm vụ giữ khóa đọc VMA).

Sau đó, có thể chuyển ZZ0003ZZ từ khóa ghi sang khóa đọc thông qua
ZZ0000ZZ, tương tự như ZZ0001ZZ,
ngầm chấm dứt tất cả các khóa ghi VMA thông qua ZZ0002ZZ, nhưng
quan trọng là không từ bỏ khóa mmap trong khi hạ cấp, do đó
giữ cho không gian địa chỉ ảo bị khóa ổn định.

Một hệ quả thú vị của việc này là các khóa bị hạ cấp là độc quyền
chống lại bất kỳ nhiệm vụ nào khác có khóa bị hạ cấp (vì nhiệm vụ đua xe sẽ
trước tiên phải có khóa ghi để hạ cấp nó và khóa bị hạ cấp
ngăn chặn việc lấy được khóa ghi mới cho đến khi khóa ban đầu được thực hiện
được thả ra).

Để rõ ràng, chúng tôi ánh xạ các khóa đọc (R)/ghi xuống cấp (D)/ghi (W) với một
một cái khác hiển thị khóa nào loại trừ những khóa khác:

.. list-table:: Lock exclusivity
   :widths: 5 5 5 5
   :header-rows: 1
   :stub-columns: 1

   * -
     - R
     - D
     - W
   * - R
     - N
     - N
     - Y
   * - D
     - N
     - Y
     - Y
   * - W
     - Y
     - Y
     - Y

Ở đây chữ Y biểu thị các khóa trong hàng/cột phù hợp là loại trừ lẫn nhau,
và N chỉ ra rằng chúng không như vậy.

Mở rộng ngăn xếp
---------------

Việc mở rộng ngăn xếp làm tăng thêm sự phức tạp mà chúng tôi không thể cho phép ở đó
là lỗi trang đua xe, do đó chúng tôi gọi ZZ0000ZZ để
ngăn chặn điều này trong ZZ0001ZZ hoặc ZZ0002ZZ.

---------------
Chức năng và cấu trúc
------------------------

.. kernel-doc:: include/linux/mmap_lock.h