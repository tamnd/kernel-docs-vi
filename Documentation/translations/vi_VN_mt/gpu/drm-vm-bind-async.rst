.. SPDX-License-Identifier: (GPL-2.0+ OR MIT)

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/drm-vm-bind-async.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
VM_BIND không đồng bộ
======================

Danh pháp:
=============

* ZZ0000ZZ: Bộ nhớ trên thiết bị. Đôi khi được gọi là bộ nhớ cục bộ của thiết bị.

* ZZ0000ZZ: Không gian địa chỉ GPU ảo. Thông thường cho mỗi quá trình, nhưng
  có thể được chia sẻ bởi nhiều tiến trình.

* ZZ0000ZZ: Một thao tác hoặc danh sách các thao tác để sửa đổi gpu_vm bằng cách sử dụng
  một chiếc IOCTL. Các hoạt động bao gồm hệ thống ánh xạ và hủy ánh xạ- hoặc
  Bộ nhớ VRAM.

* ZZ0000ZZ: Vùng chứa trừu tượng hóa các đối tượng đồng bộ hóa. các
  các đối tượng đồng bộ hóa có thể chung chung, như dma-fences hoặc
  trình điều khiển cụ thể. Syncobj thường chỉ ra loại của
  đối tượng đồng bộ hóa cơ bản.

* ZZ0000ZZ: Đối số cho VM_BIND IOCTL, thao tác VM_BIND chờ
  cho những điều này trước khi bắt đầu.

* ZZ0000ZZ: Đối số cho một VM_BIND_IOCTL, phép toán VM_BIND
  báo hiệu những điều này khi hoạt động liên kết hoàn tất.

* ZZ0001ZZ: Đối tượng đồng bộ hóa trình điều khiển chéo. Một cơ bản
  cần có sự hiểu biết về hàng rào dma để hiểu được điều này
  tài liệu. Vui lòng tham khảo phần ZZ0002ZZ của
  ZZ0000ZZ.

* ZZ0000ZZ: Đối tượng đồng bộ hóa, khác với hàng rào dma.
  Hàng rào bộ nhớ sử dụng giá trị của một vị trí bộ nhớ được chỉ định để xác định
  trạng thái được báo hiệu. Một hàng rào bộ nhớ có thể được chờ đợi và báo hiệu bởi cả hai
  GPU và CPU. Hàng rào bộ nhớ đôi khi được gọi là
  hàng rào người dùng, hàng rào không gian người dùng hoặc gpu futexes và không nhất thiết phải tuân theo
  quy tắc báo hiệu dma-fence trong một "khoảng thời gian hợp lý".
  Do đó, kernel nên tránh chờ đợi hàng rào bộ nhớ có khóa được giữ.

* ZZ0000ZZ: Khối lượng công việc có thể mất nhiều thời gian hơn
  độ trễ tín hiệu tối đa của hàng rào dma được quy định hiện tại để hoàn thành và
  do đó cần đặt bối cảnh thực thi gpu_vm hoặc GPU trong
  một chế độ nhất định không cho phép hoàn thành hàng rào dma.

* ZZ0000ZZ: Hàm exec là hàm xác nhận lại tất cả
  gpu_vmas bị ảnh hưởng, gửi một lô lệnh GPU và đăng ký
  dma_fence thể hiện hoạt động của lệnh GPU với tất cả các lệnh bị ảnh hưởng
  dma_resvs. Để hoàn thiện, mặc dù không được đề cập trong tài liệu này,
  điều đáng nói là hàm exec cũng có thể là
  nhân viên xác nhận lại được một số trình điều khiển sử dụng trong tính toán /
  chế độ chạy lâu dài.

* ZZ0000ZZ: Mã định danh ngữ cảnh được sử dụng cho VM_BIND
  hoạt động. Các hoạt động VM_BIND sử dụng cùng bối cảnh liên kết có thể được thực hiện
  giả định, ở những nơi quan trọng, phải hoàn thành theo thứ tự nộp. Không như vậy
  các giả định có thể được thực hiện cho các hoạt động VM_BIND bằng cách sử dụng các bối cảnh liên kết riêng biệt.

* ZZ0000ZZ: Trình điều khiển chế độ người dùng.

* ZZ0000ZZ: Trình điều khiển chế độ hạt nhân.


Hoạt động VM_BIND đồng bộ / không đồng bộ
============================================

VM_BIND đồng bộ
___________________
Với VM_BIND đồng bộ, tất cả các hoạt động của VM_BIND đều hoàn tất trước khi
IOCTL trở lại. VM_BIND đồng bộ không có hàng rào bên trong cũng như không có
ngoài hàng rào. VM_BIND đồng bộ có thể chặn và chờ các hoạt động của GPU;
ví dụ như trao đổi hoặc xóa hoặc thậm chí các liên kết trước đó.

VM_BIND không đồng bộ
____________________
VM_BIND không đồng bộ chấp nhận cả in-syncobjs và out-syncobjs. Trong khi
IOCTL có thể quay trở lại ngay lập tức, các thao tác VM_BIND chờ các in-syncobjs
trước khi sửa đổi bảng trang GPU và báo hiệu các out-syncobjs khi
việc sửa đổi được thực hiện theo nghĩa là hàm exec tiếp theo
đang chờ out-syncobjs sẽ thấy sự thay đổi. Lỗi được báo cáo
một cách đồng bộ.
Trong các tình huống bộ nhớ thấp, việc triển khai có thể bị chặn, thực hiện
VM_BIND đồng bộ, vì có thể không đủ bộ nhớ
có sẵn ngay lập tức để chuẩn bị hoạt động không đồng bộ.

Nếu VM_BIND IOCTL lấy một danh sách hoặc một mảng thao tác làm đối số,
in-syncobjs cần báo hiệu trước khi thao tác đầu tiên bắt đầu
thực thi và tín hiệu out-syncobjs sau thao tác cuối cùng
hoàn thành. Các hoạt động trong danh sách hoạt động có thể được giả định, trong đó nó
vấn đề, để hoàn thành theo thứ tự.

Vì các hoạt động VM_BIND không đồng bộ có thể sử dụng hàng rào dma được nhúng trong
out-syncobjs và nội bộ trong KMD để báo hiệu việc hoàn thành liên kết, bất kỳ
hàng rào bộ nhớ được cung cấp dưới dạng hàng rào trong VM_BIND cần phải được chờ đợi
đồng bộ trước khi VM_BIND ioctl quay trở lại, vì hàng rào dma,
cần phải báo hiệu trong một khoảng thời gian hợp lý, không bao giờ có thể thực hiện được
phụ thuộc vào hàng rào bộ nhớ không có hạn chế như vậy.

Mục đích của hoạt động VM_BIND không đồng bộ là dành cho chế độ người dùng
trình điều khiển để có thể thực hiện các sửa đổi gpu_vm xen kẽ và
chức năng thực thi. Đối với khối lượng công việc chạy dài, việc phân phối liên kết như vậy
hoạt động không được phép và cần phải chờ đợi bất kỳ hàng rào nào
một cách đồng bộ. Lý do cho điều này là gấp đôi. Đầu tiên, bất kỳ ký ức nào
hàng rào được kiểm soát bởi khối lượng công việc kéo dài và được sử dụng làm in-syncobjs cho
Dù sao đi nữa, hoạt động của VM_BIND sẽ cần phải được chờ đợi đồng bộ (xem
ở trên). Thứ hai, mọi hàng rào dma được sử dụng làm in-syncobjs cho VM_BIND
hoạt động cho khối lượng công việc dài hạn sẽ không cho phép tạo đường ống
dù sao đi nữa vì khối lượng công việc chạy trong thời gian dài không cho phép dma-fences
out-syncobjs, vì vậy về mặt lý thuyết có thể sử dụng chúng
có vấn đề và nên bị từ chối cho đến khi có trường hợp sử dụng có giá trị.
Lưu ý rằng đây không phải là giới hạn do quy tắc dma-fence áp đặt, nhưng
đúng hơn là một hạn chế được áp đặt để giữ cho việc triển khai KMD trở nên đơn giản. Nó có
không ảnh hưởng đến việc sử dụng dma-fences làm phần phụ thuộc trong thời gian dài
bản thân khối lượng công việc, được cho phép bởi các quy tắc dma-fence, nhưng đúng hơn là đối với
chỉ hoạt động VM_BIND.

Hoạt động VM_BIND không đồng bộ có thể mất nhiều thời gian để
hoàn thành và báo hiệu out_fence. Đặc biệt nếu hoạt động
được dẫn sâu đằng sau các hoạt động và khối lượng công việc VM_BIND khác
được gửi bằng cách sử dụng các hàm exec. Trong trường hợp đó, UMD có thể muốn tránh một
thao tác VM_BIND tiếp theo sẽ được xếp sau thao tác đầu tiên nếu
không có sự phụ thuộc rõ ràng. Để tránh việc xếp hàng như vậy, một
Việc triển khai VM_BIND có thể cho phép các ngữ cảnh VM_BIND được
được tạo ra. Đối với mỗi bối cảnh, các hoạt động VM_BIND sẽ được đảm bảo
hoàn thành theo thứ tự chúng được gửi, nhưng thực tế không phải vậy
cho các hoạt động VM_BIND thực thi trên các bối cảnh VM_BIND riêng biệt. Thay vào đó
KMD sẽ cố gắng thực hiện các hoạt động VM_BIND đó song song nhưng
không để lại sự đảm bảo nào rằng chúng sẽ thực sự được thực thi trong
song song. Có thể có những phụ thuộc tiềm ẩn bên trong mà chỉ KMD mới biết
về, ví dụ như thay đổi cấu trúc bảng trang. Một cách để cố gắng
để tránh sự phụ thuộc nội bộ như vậy là phải có VM_BIND khác nhau
bối cảnh sử dụng các vùng riêng biệt của VM.

Ngoài ra, đối với VM_BINDS đối với gpu_vms chạy lâu, trình điều khiển chế độ người dùng thường phải
chọn hàng rào bộ nhớ làm hàng rào ngoài vì điều đó mang lại sự linh hoạt cao hơn cho
trình điều khiển chế độ kernel để đưa các hoạt động khác vào liên kết /
các hoạt động hủy ràng buộc. Ví dụ như chèn điểm dừng vào hàng loạt
bộ đệm. Việc thực hiện khối lượng công việc sau đó có thể dễ dàng được chuyển tiếp phía sau
hoàn thành liên kết bằng cách sử dụng hàng rào ngoài bộ nhớ làm điều kiện tín hiệu
cho một semaphore GPU được nhúng bởi UMD trong khối lượng công việc.

Không có sự khác biệt trong các hoạt động được hỗ trợ hoặc trong
hỗ trợ đa thao tác giữa VM_BIND không đồng bộ và VM_BIND đồng bộ.

Xử lý lỗi và ngắt VM_BIND IOCTL đa thao tác
===========================================================

Hoạt động VM_BIND của IOCTL có thể bị lỗi vì nhiều lý do, ví dụ:
Ví dụ do thiếu nguồn lực để hoàn thành và do bị gián đoạn
chờ đợi.
Trong những tình huống này, UMD tốt nhất nên khởi động lại IOCTL sau
thực hiện hành động phù hợp.
Nếu UMD đã cam kết quá mức tài nguyên bộ nhớ, lỗi -ENOSPC sẽ xuất hiện
được trả về và UMD sau đó có thể hủy liên kết các tài nguyên không được sử dụng tại
khoảnh khắc và chạy lại IOCTL. Trên -EINTR, UMD chỉ cần chạy lại
Không gian người dùng IOCTL và trên -ENOMEM có thể cố gắng giải phóng các thông tin đã biết
tài nguyên bộ nhớ hệ thống hoặc bị lỗi. Trong trường hợp UMD quyết định thất bại
hoạt động liên kết, do trả về lỗi nên không cần thực hiện thêm hành động nào
để dọn dẹp thao tác thất bại và VM vẫn ở trạng thái tương tự
như trước khi IOCTL bị lỗi.
Các hoạt động hủy liên kết được đảm bảo không trả lại bất kỳ lỗi nào do
hạn chế về tài nguyên, nhưng có thể trả về lỗi do, ví dụ:
đối số không hợp lệ hoặc gpu_vm bị cấm.
Trong trường hợp xảy ra lỗi không mong muốn trong quá trình liên kết không đồng bộ
quá trình, gpu_vm sẽ bị cấm và cố gắng sử dụng nó sau khi cấm
sẽ trả về -ENOENT.

Ví dụ: Xe VM_BIND uAPI
============================

Bắt đầu với cấu trúc hoạt động VM_BIND, lệnh gọi IOCTL có thể thực hiện
không, một hoặc nhiều hoạt động như vậy. Số 0 chỉ có nghĩa là
phần đồng bộ hóa của IOCTL được thực hiện: một phần không đồng bộ
VM_BIND cập nhật các đối tượng đồng bộ, trong khi VM_BIND đồng bộ hóa chờ
sự phụ thuộc ngầm định phải được đáp ứng.

.. code-block:: c

   struct drm_xe_vm_bind_op {
	/**
	 * @obj: GEM object to operate on, MBZ for MAP_USERPTR, MBZ for UNMAP
	 */
	__u32 obj;

	/** @pad: MBZ */
	__u32 pad;

	union {
		/**
		 * @obj_offset: Offset into the object for MAP.
		 */
		__u64 obj_offset;

		/** @userptr: user virtual address for MAP_USERPTR */
		__u64 userptr;
	};

	/**
	 * @range: Number of bytes from the object to bind to addr, MBZ for UNMAP_ALL
	 */
	__u64 range;

	/** @addr: Address to operate on, MBZ for UNMAP_ALL */
	__u64 addr;

	/**
	 * @tile_mask: Mask for which tiles to create binds for, 0 == All tiles,
	 * only applies to creating new VMAs
	 */
	__u64 tile_mask;

       /* Map (parts of) an object into the GPU virtual address range.
    #define XE_VM_BIND_OP_MAP		0x0
        /* Unmap a GPU virtual address range */
    #define XE_VM_BIND_OP_UNMAP		0x1
        /*
	 * Map a CPU virtual address range into a GPU virtual
	 * address range.
	 */
    #define XE_VM_BIND_OP_MAP_USERPTR	0x2
        /* Unmap a gem object from the VM. */
    #define XE_VM_BIND_OP_UNMAP_ALL	0x3
        /*
	 * Make the backing memory of an address range resident if
	 * possible. Note that this doesn't pin backing memory.
	 */
    #define XE_VM_BIND_OP_PREFETCH	0x4

        /* Make the GPU map readonly. */
    #define XE_VM_BIND_FLAG_READONLY	(0x1 << 16)
	/*
	 * Valid on a faulting VM only, do the MAP operation immediately rather
	 * than deferring the MAP to the page fault handler.
	 */
    #define XE_VM_BIND_FLAG_IMMEDIATE	(0x1 << 17)
	/*
	 * When the NULL flag is set, the page tables are setup with a special
	 * bit which indicates writes are dropped and all reads return zero.  In
	 * the future, the NULL flags will only be valid for XE_VM_BIND_OP_MAP
	 * operations, the BO handle MBZ, and the BO offset MBZ. This flag is
	 * intended to implement VK sparse bindings.
	 */
    #define XE_VM_BIND_FLAG_NULL	(0x1 << 18)
	/** @op: Operation to perform (lower 16 bits) and flags (upper 16 bits) */
	__u32 op;

	/** @mem_region: Memory region to prefetch VMA to, instance not a mask */
	__u32 region;

	/** @reserved: Reserved */
	__u64 reserved[2];
   };


Bản thân đối số VM_BIND IOCTL trông như sau. Lưu ý rằng đối với
VM_BIND đồng bộ, các trường num_syncs và syncs phải bằng 0. đây
trường ZZ0000ZZ là bối cảnh VM_BIND đã thảo luận trước đó
được sử dụng để tạo điều kiện cho các VM_BIND không theo thứ tự.

.. code-block:: c

    struct drm_xe_vm_bind {
	/** @extensions: Pointer to the first extension struct, if any */
	__u64 extensions;

	/** @vm_id: The ID of the VM to bind to */
	__u32 vm_id;

	/**
	 * @exec_queue_id: exec_queue_id, must be of class DRM_XE_ENGINE_CLASS_VM_BIND
	 * and exec queue must have same vm_id. If zero, the default VM bind engine
	 * is used.
	 */
	__u32 exec_queue_id;

	/** @num_binds: number of binds in this IOCTL */
	__u32 num_binds;

        /* If set, perform an async VM_BIND, if clear a sync VM_BIND */
    #define XE_VM_BIND_IOCTL_FLAG_ASYNC	(0x1 << 0)

	/** @flag: Flags controlling all operations in this ioctl. */
	__u32 flags;

	union {
		/** @bind: used if num_binds == 1 */
		struct drm_xe_vm_bind_op bind;

		/**
		 * @vector_of_binds: userptr to array of struct
		 * drm_xe_vm_bind_op if num_binds > 1
		 */
		__u64 vector_of_binds;
	};

	/** @num_syncs: amount of syncs to wait for or to signal on completion. */
	__u32 num_syncs;

	/** @pad2: MBZ */
	__u32 pad2;

	/** @syncs: pointer to struct drm_xe_sync array */
	__u64 syncs;

	/** @reserved: Reserved */
	__u64 reserved[2];
    };