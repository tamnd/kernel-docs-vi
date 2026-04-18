.. SPDX-License-Identifier: (GPL-2.0+ OR MIT)

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/drm-vm-bind-locking.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
Khóa VM_BIND
=================

Tài liệu này cố gắng mô tả những gì cần thiết để khóa VM_BIND đúng cách,
bao gồm cả khóa userptr mmu_notifier. Nó cũng thảo luận về một số
tối ưu hóa để loại bỏ việc lặp qua tất cả các ánh xạ userptr và
ánh xạ đối tượng bên ngoài / chia sẻ cần thiết theo cách đơn giản nhất
thực hiện. Ngoài ra còn có phần mô tả khóa VM_BIND
cần thiết để triển khai các lỗi trang có thể phục hồi.

Bộ trợ giúp DRM GPUVM
============================

Có một bộ trợ giúp dành cho trình điều khiển triển khai VM_BIND và bộ này
bộ trợ giúp thực hiện nhiều, nhưng không phải tất cả các khóa được mô tả
trong tài liệu này. Đặc biệt, hiện tại nó đang thiếu userptr
thực hiện. Tài liệu này không có ý định mô tả DRM GPUVM
triển khai chi tiết nhưng nó được đề cập trong ZZ0000ZZ. Nó rất được khuyến khích cho bất kỳ người lái xe
triển khai VM_BIND để sử dụng các trình trợ giúp DRM GPUVM và mở rộng nó nếu
chức năng chung bị thiếu.

Danh pháp
============

* ZZ0002ZZ: Trừu tượng hóa không gian địa chỉ GPU ảo với
  siêu dữ liệu. Thông thường một cái cho mỗi khách hàng (tệp DRM riêng tư) hoặc một cái cho mỗi khách hàng
  bối cảnh thực hiện.
* ZZ0003ZZ: Trừu tượng hóa dải địa chỉ GPU trong gpu_vm với
  siêu dữ liệu liên quan. Bộ nhớ đệm của gpu_vma có thể là
  một đối tượng GEM hoặc các trang ẩn danh hoặc bộ đệm trang cũng được ánh xạ vào CPU
  không gian địa chỉ cho tiến trình.
* ZZ0004ZZ: Tóm tắt sự liên kết của đối tượng GEM và
  một máy ảo. Đối tượng GEM duy trì một danh sách gpu_vm_bos, trong đó mỗi gpu_vm_bo
  duy trì một danh sách gpu_vmas.
* ZZ0005ZZ: Một gpu_vma, có cửa hàng hỗ trợ
  là các trang ẩn danh hoặc bộ đệm trang như được mô tả ở trên.
* ZZ0006ZZ: Xác nhận lại gpu_vma có nghĩa là tạo phiên bản mới nhất
  của cư dân cửa hàng hỗ trợ và đảm bảo gpu_vma
  các mục trong bảng trang trỏ đến cửa hàng hỗ trợ đó.
* ZZ0007ZZ: Một struct dma_fence tương tự như việc hoàn thành struct
  và theo dõi hoạt động của GPU. Khi hoạt động GPU kết thúc,
  các tín hiệu dma_fence. Vui lòng tham khảo phần ZZ0008ZZ của
  ZZ0000ZZ.
* ZZ0009ZZ: Cấu trúc dma_resv (còn gọi là đối tượng đặt trước) được sử dụng
  để theo dõi hoạt động GPU dưới dạng nhiều dma_fences trên một
  gpu_vm hoặc đối tượng GEM. Dma_resv chứa một mảng/danh sách
  của dma_fences và một khóa cần được giữ khi thêm
  dma_fences bổ sung cho dma_resv. Khóa là loại
  cho phép khóa an toàn bế tắc của nhiều dma_resv tùy ý
  đặt hàng. Vui lòng tham khảo phần ZZ0010ZZ của
  ZZ0001ZZ.
* ZZ0011ZZ: Hàm exec là hàm xác nhận lại tất cả
  gpu_vmas bị ảnh hưởng, gửi một lô lệnh GPU và đăng ký
  dma_fence thể hiện hoạt động của lệnh GPU với tất cả các lệnh bị ảnh hưởng
  dma_resvs. Để hoàn thiện, mặc dù không được đề cập trong tài liệu này,
  điều đáng nói là hàm exec cũng có thể là
  nhân viên xác nhận lại được một số trình điều khiển sử dụng trong tính toán /
  chế độ chạy lâu dài.
* ZZ0012ZZ: Đối tượng GEM chỉ được ánh xạ trong một
  VM đơn. Các đối tượng GEM cục bộ chia sẻ dma_resv của gpu_vm.
* ZZ0013ZZ: hay còn gọi là đối tượng dùng chung: Một đối tượng GEM có thể được chia sẻ
  bởi nhiều gpu_vms và bộ nhớ sao lưu của chúng có thể được chia sẻ với
  những người lái xe khác.

Ổ khóa và thứ tự khóa
=======================

Một trong những lợi ích của VM_BIND là các đối tượng GEM cục bộ chia sẻ gpu_vm
đối tượng dma_resv và do đó khóa dma_resv. Vì vậy, ngay cả với một lượng lớn
số đối tượng GEM cục bộ, chỉ cần một khóa để thực thi
trình tự nguyên tử.

Các khóa và lệnh khóa sau đây được sử dụng:

* ZZ0000ZZ (tùy chọn là rwsem). Bảo vệ gpu_vm
  cấu trúc dữ liệu theo dõi gpu_vmas. Nó cũng có thể bảo vệ các
  danh sách userptr gpu_vmas của gpu_vm. Với sự tương tự CPU mm, điều này sẽ
  tương ứng với mmap_lock. Một rwsem cho phép nhiều độc giả bước đi
  cây VM đồng thời, nhưng lợi ích của việc đồng thời đó lớn nhất
  có thể thay đổi từ người lái xe này sang người lái xe khác.
* ZZ0001ZZ. Khóa này được thực hiện ở chế độ đọc cho mỗi
  userptr gpu_vma trên danh sách userptr của gpu_vm và ở chế độ ghi trong mmu
  vô hiệu hóa trình thông báo. Đây không phải là một seqlock thực sự nhưng được mô tả trong
  ZZ0002ZZ là "Bên đọc/ghi bên va chạm-thử lại
  'khóa' rất giống một số thứ tự. Tuy nhiên điều này cho phép nhiều
  bên viết để giữ nó cùng một lúc...". Phần quan trọng bên đọc
  được bao quanh bởi ZZ0003ZZ với ZZ0004ZZ
  ngủ nếu bên ghi được giữ.
  Mặt ghi được giữ bởi lõi mm trong khi gọi khoảng mmu
  thông báo vô hiệu.
* Khóa ZZ0005ZZ. Bảo vệ danh sách gpu_vmas cần của gpu_vm
  việc đóng lại, cũng như trạng thái cư trú của tất cả địa phương của gpu_vm
  Đối tượng GEM.
  Hơn nữa, nó thường bảo vệ danh sách bị trục xuất và bị trục xuất của gpu_vm.
  các đối tượng GEM bên ngoài.
* ZZ0006ZZ. Đây là một rwsem đó là
  được chụp ở chế độ đọc trong chế độ thực thi và ghi trong trình thông báo mmu
  vô hiệu. Khóa thông báo userptr là trên gpu_vm.
* ZZ0007ZZ Khóa này bảo vệ đối tượng GEM
  danh sách gpu_vm_bos. Đây thường là khóa giống như GEM
  dma_resv của đối tượng, nhưng một số trình điều khiển bảo vệ danh sách này theo cách khác,
  xem bên dưới.
* ZZ0008ZZ. Với một số triển khai, chúng cần thiết
  để có thể cập nhật đối tượng gpu_vm bị trục xuất và bên ngoài
  danh sách. Đối với những triển khai đó, các khóa xoay được lấy khi
  danh sách bị thao túng. Tuy nhiên, để tránh vi phạm lệnh khóa
  với các khóa dma_resv, cần có một sơ đồ đặc biệt khi lặp lại
  trên các danh sách.

.. _gpu_vma lifetime:

Bảo vệ và tuổi thọ của gpu_vm_bos và gpu_vmas
==================================================

Danh sách gpu_vm_bos của đối tượng GEM và danh sách gpu_vmas của gpu_vm_bo
được bảo vệ bởi ZZ0000ZZ, thường là
giống như dma_resv của đối tượng GEM, nhưng nếu trình điều khiển
cần truy cập các danh sách này từ bên trong tín hiệu dma_fence
phần quan trọng, thay vào đó nó có thể chọn bảo vệ nó bằng một
khóa riêng biệt, có thể khóa từ bên trong tín hiệu dma_fence
phần quan trọng. Những người lái xe như vậy khi đó cần phải chú ý hơn
đến những khóa nào cần được lấy từ bên trong vòng lặp khi lặp lại
qua danh sách gpu_vm_bo và gpu_vma để tránh vi phạm lệnh khóa.

Bộ trợ giúp DRM GPUVM cung cấp lockdep khẳng định rằng khóa này là
được tổ chức trong những tình huống liên quan và cũng cung cấp một phương tiện để tự thực hiện
biết khóa nào thực sự được sử dụng: ZZ0000ZZ.

Mỗi gpu_vm_bo chứa một con trỏ được tính tham chiếu tới GEM bên dưới
đối tượng và mỗi gpu_vma giữ một con trỏ được tính tham chiếu tới
gpu_vm_bo. Khi lặp qua danh sách gpu_vm_bos và
trên danh sách gpu_vmas của gpu_vm_bo, ZZ0000ZZ phải
không bị loại bỏ, nếu không, gpu_vmas được gắn vào gpu_vm_bo có thể
biến mất mà không cần thông báo vì chúng không được tính tham chiếu. A
người lái xe có thể thực hiện kế hoạch riêng của mình để cho phép điều này với chi phí
phức tạp hơn, nhưng điều này nằm ngoài phạm vi của tài liệu này.

Trong triển khai DRM GPUVM, mỗi gpu_vm_bo và mỗi gpu_vma
giữ số lượng tham chiếu trên chính gpu_vm. Do đó, và để tránh vòng tròn
việc đếm tham chiếu, việc dọn dẹp gpu_vmas của gpu_vm không được thực hiện từ
hàm hủy của gpu_vm. Trình điều khiển thường thực hiện đóng gpu_vm
chức năng cho việc dọn dẹp này. Hàm đóng gpu_vm sẽ hủy gpu
thực thi bằng VM này, hủy ánh xạ tất cả gpu_vmas và giải phóng bộ nhớ bảng trang.

Xác nhận lại và trục xuất các đối tượng địa phương
==========================================

Lưu ý rằng trong tất cả các ví dụ mã được đưa ra dưới đây, chúng tôi sử dụng đơn giản hóa
mã giả. Đặc biệt, thuật toán tránh bế tắc dma_resv
cũng như việc dành bộ nhớ cho hàng rào dma_resv bị loại bỏ.

Xác nhận lại
____________
Với VM_BIND, tất cả các đối tượng cục bộ cần phải được lưu trữ khi gpu hoạt động.
thực thi bằng gpu_vm và các đối tượng cần phải có giá trị hợp lệ
gpu_vmas đã thiết lập trỏ đến chúng. Thông thường, mỗi bộ đệm lệnh gpu
do đó việc gửi đi trước phần xác nhận lại:

.. code-block:: C

   dma_resv_lock(gpu_vm->resv);

   // Validation section starts here.
   for_each_gpu_vm_bo_on_evict_list(&gpu_vm->evict_list, &gpu_vm_bo) {
           validate_gem_bo(&gpu_vm_bo->gem_bo);

           // The following list iteration needs the Gem object's
           // dma_resv to be held (it protects the gpu_vm_bo's list of
           // gpu_vmas, but since local gem objects share the gpu_vm's
           // dma_resv, it is already held at this point.
           for_each_gpu_vma_of_gpu_vm_bo(&gpu_vm_bo, &gpu_vma)
                  move_gpu_vma_to_rebind_list(&gpu_vma, &gpu_vm->rebind_list);
   }

   for_each_gpu_vma_on_rebind_list(&gpu vm->rebind_list, &gpu_vma) {
           rebind_gpu_vma(&gpu_vma);
           remove_gpu_vma_from_rebind_list(&gpu_vma);
   }
   // Validation section ends here, and job submission starts.

   add_dependencies(&gpu_job, &gpu_vm->resv);
   job_dma_fence = gpu_submit(&gpu_job));

   add_dma_fence(job_dma_fence, &gpu_vm->resv);
   dma_resv_unlock(gpu_vm->resv);

Lý do có danh sách rebind gpu_vm riêng là vì có
có thể là userptr gpu_vmas không ánh xạ đối tượng bộ đệm
cũng cần phải đóng lại.

Trục xuất
________

Việc trục xuất một trong những đối tượng cục bộ này sau đó sẽ trông giống như
sau đây:

.. code-block:: C

   obj = get_object_from_lru();

   dma_resv_lock(obj->resv);
   for_each_gpu_vm_bo_of_obj(obj, &gpu_vm_bo);
           add_gpu_vm_bo_to_evict_list(&gpu_vm_bo, &gpu_vm->evict_list);

   add_dependencies(&eviction_job, &obj->resv);
   job_dma_fence = gpu_submit(&eviction_job);
   add_dma_fence(&obj->resv, job_dma_fence);

   dma_resv_unlock(&obj->resv);
   put_object(obj);

Lưu ý rằng vì đối tượng là cục bộ của gpu_vm nên nó sẽ chia sẻ thông tin của gpu_vm
khóa dma_resv sao cho ZZ0000ZZ.
Gpu_vm_bos được đánh dấu để trục xuất sẽ được đưa vào danh sách trục xuất của gpu_vm,
được bảo vệ bởi ZZ0001ZZ. Trong thời gian trục xuất tất cả địa phương
các đối tượng có dma_resv bị khóa và do sự bình đẳng ở trên, cũng
dma_resv của gpu_vm bảo vệ danh sách trục xuất của gpu_vm đã bị khóa.

Với VM_BIND, gpu_vmas không cần phải được giải phóng trước khi bị trục xuất,
vì người lái xe phải đảm bảo rằng việc trục xuất hoặc sao chép sẽ chờ
đối với GPU không hoạt động hoặc phụ thuộc vào tất cả hoạt động GPU trước đó. Hơn nữa, bất kỳ
nỗ lực tiếp theo của GPU để truy cập bộ nhớ đã giải phóng thông qua
gpu_vma sẽ được bắt đầu bằng một hàm exec mới, với sự xác nhận lại
phần này sẽ đảm bảo tất cả gpu_vmas đều được phục hồi. Việc trục xuất
mã giữ dma_resv của đối tượng trong khi xác nhận lại sẽ đảm bảo
chức năng thực thi mới có thể không chạy đua với việc trục xuất.

Trình điều khiển có thể được triển khai theo cách mà trên mỗi chức năng thực thi,
chỉ một tập hợp con của vmas được chọn để rebind.  Trong trường hợp này, tất cả vmas được
ZZ0000ZZ được chọn để liên kết lại phải được hủy liên kết trước khi thực thi
khối lượng công việc chức năng được gửi.

Khóa với các đối tượng đệm bên ngoài
====================================

Vì các đối tượng bộ đệm bên ngoài có thể được chia sẻ bởi nhiều gpu_vm nên chúng
không thể chia sẻ đối tượng đặt trước của họ với một gpu_vm. Thay vào đó
họ cần phải có một đối tượng đặt trước của riêng mình. Bên ngoài
Do đó, các đối tượng được liên kết với gpu_vm sử dụng một hoặc nhiều gpu_vmas sẽ được đặt trên một
danh sách per-gpu_vm được bảo vệ bởi khóa dma_resv của gpu_vm hoặc
một trong những ZZ0000ZZ. Một lần
đối tượng đặt trước của gpu_vm đã bị khóa, việc đi qua nó là an toàn
danh sách đối tượng bên ngoài và khóa dma_resvs của tất cả các đối tượng bên ngoài
đồ vật. Tuy nhiên, nếu thay vào đó sử dụng một spinlock danh sách thì một cách phức tạp hơn
sơ đồ lặp cần phải được sử dụng.

Tại thời điểm bị trục xuất, gpu_vm_bos của ZZ0002ZZ gpu_vms bên ngoài
đối tượng nhất định cần phải được đưa vào danh sách trục xuất gpu_vm của họ.
Tuy nhiên, khi đuổi một đối tượng bên ngoài, dma_resvs của
gpu_vms đối tượng bị ràng buộc thường không được giữ. Chỉ
dma_resv riêng tư của đối tượng có thể được đảm bảo được giữ lại. Nếu có
bối cảnh ww_acquire có sẵn tại thời điểm trục xuất, chúng ta có thể lấy những bối cảnh đó
dma_resvs nhưng điều đó có thể gây ra hiện tượng khôi phục ww_mutex tốn kém. Một cách đơn giản
tùy chọn là chỉ đánh dấu gpu_vm_bos của đối tượng đá quý bị đuổi bằng
một bool ZZ0000ZZ được kiểm tra trước lần tiếp theo
danh sách gpu_vm bị loại bỏ tương ứng cần được duyệt qua. Ví dụ, khi
duyệt qua danh sách các đối tượng bên ngoài và khóa chúng. Vào thời điểm đó,
cả dma_resv của gpu_vm và dma_resv của đối tượng đều được giữ và
gpu_vm_bo được đánh dấu là bị trục xuất, sau đó có thể được thêm vào danh sách của gpu_vm
đã trục xuất gpu_vm_bos. Bool ZZ0001ZZ được bảo vệ chính thức bởi
dma_resv của đối tượng.

Hàm exec trở thành

.. code-block:: C

   dma_resv_lock(gpu_vm->resv);

   // External object list is protected by the gpu_vm->resv lock.
   for_each_gpu_vm_bo_on_extobj_list(gpu_vm, &gpu_vm_bo) {
           dma_resv_lock(gpu_vm_bo.gem_obj->resv);
           if (gpu_vm_bo_marked_evicted(&gpu_vm_bo))
                   add_gpu_vm_bo_to_evict_list(&gpu_vm_bo, &gpu_vm->evict_list);
   }

   for_each_gpu_vm_bo_on_evict_list(&gpu_vm->evict_list, &gpu_vm_bo) {
           validate_gem_bo(&gpu_vm_bo->gem_bo);

           for_each_gpu_vma_of_gpu_vm_bo(&gpu_vm_bo, &gpu_vma)
                  move_gpu_vma_to_rebind_list(&gpu_vma, &gpu_vm->rebind_list);
   }

   for_each_gpu_vma_on_rebind_list(&gpu vm->rebind_list, &gpu_vma) {
           rebind_gpu_vma(&gpu_vma);
           remove_gpu_vma_from_rebind_list(&gpu_vma);
   }

   add_dependencies(&gpu_job, &gpu_vm->resv);
   job_dma_fence = gpu_submit(&gpu_job));

   add_dma_fence(job_dma_fence, &gpu_vm->resv);
   for_each_external_obj(gpu_vm, &obj)
          add_dma_fence(job_dma_fence, &obj->resv);
   dma_resv_unlock_all_resv_locks();

Và việc trục xuất nhận biết đối tượng được chia sẻ tương ứng sẽ như sau:

.. code-block:: C

   obj = get_object_from_lru();

   dma_resv_lock(obj->resv);
   for_each_gpu_vm_bo_of_obj(obj, &gpu_vm_bo)
           if (object_is_vm_local(obj))
                add_gpu_vm_bo_to_evict_list(&gpu_vm_bo, &gpu_vm->evict_list);
           else
                mark_gpu_vm_bo_evicted(&gpu_vm_bo);

   add_dependencies(&eviction_job, &obj->resv);
   job_dma_fence = gpu_submit(&eviction_job);
   add_dma_fence(&obj->resv, job_dma_fence);

   dma_resv_unlock(&obj->resv);
   put_object(obj);

.. _Spinlock iteration:

Truy cập danh sách của gpu_vm mà không cần khóa dma_resv
===========================================================

Một số trình điều khiển sẽ giữ khóa dma_resv của gpu_vm khi truy cập
danh sách trục xuất của gpu_vm và danh sách các đối tượng bên ngoài. Tuy nhiên, có
trình điều khiển cần truy cập vào các danh sách này mà không cần khóa dma_resv
được giữ lại, ví dụ do cập nhật trạng thái không đồng bộ từ bên trong
dma_fence báo hiệu đường quan trọng. Trong những trường hợp như vậy, một spinlock có thể
được sử dụng để bảo vệ thao tác của danh sách. Tuy nhiên, vì trình độ cao hơn
cần phải thực hiện khóa ngủ cho từng mục trong danh sách trong khi lặp lại
trên các danh sách, các mục đã được lặp lại cần phải được
tạm thời được chuyển sang danh sách riêng tư và spinlock được giải phóng
trong khi xử lý từng mục:

.. code block:: C

    struct list_head still_in_list;

    INIT_LIST_HEAD(&still_in_list);

    spin_lock(&gpu_vm->list_lock);
    do {
            struct list_head *entry = list_first_entry_or_null(&gpu_vm->list, head);

            if (!entry)
                    break;

            list_move_tail(&entry->head, &still_in_list);
            list_entry_get_unless_zero(entry);
            spin_unlock(&gpu_vm->list_lock);

            process(entry);

            spin_lock(&gpu_vm->list_lock);
            list_entry_put(entry);
    } while (true);

    list_splice_tail(&still_in_list, &gpu_vm->list);
    spin_unlock(&gpu_vm->list_lock);

Do có thêm các hoạt động khóa và nguyên tử, trình điều khiển ZZ0002ZZ
tránh truy cập danh sách gpu_vm bên ngoài khóa dma_resv
cũng có thể muốn tránh sơ đồ lặp này. Đặc biệt, nếu
người lái xe dự đoán một số lượng lớn các mục trong danh sách. Đối với các danh sách có
số lượng mục danh sách dự kiến ​​là nhỏ, trong đó việc lặp lại danh sách không
xảy ra rất thường xuyên hoặc nếu có một chi phí bổ sung đáng kể
liên kết với mỗi lần lặp, chi phí hoạt động nguyên tử
liên quan đến kiểu lặp này rất có thể là không đáng kể. Lưu ý rằng
nếu sử dụng sơ đồ này thì cần phải đảm bảo danh sách này
phép lặp được bảo vệ bởi khóa cấp độ bên ngoài hoặc semaphore, vì danh sách
các mục tạm thời bị xóa khỏi danh sách trong khi lặp lại và nó được
cũng đáng đề cập rằng danh sách địa phương ZZ0000ZZ nên
cũng được coi là được bảo vệ bởi ZZ0001ZZ và nó được
do đó có thể các mục cũng có thể bị xóa khỏi danh sách cục bộ
đồng thời với việc lặp danh sách.

Vui lòng tham khảo ZZ0000ZZ và nội bộ của nó
Chức năng ZZ0001ZZ.


userptr gpu_vmas
================

Userptr gpu_vma là một gpu_vma, thay vì ánh xạ một đối tượng đệm tới một
Dải địa chỉ ảo GPU, ánh xạ trực tiếp phạm vi địa chỉ ẩn danh CPU mm
hoặc tập tin các trang bộ đệm trang.
Một cách tiếp cận rất đơn giản là chỉ cần ghim các trang bằng cách sử dụng
pin_user_pages() tại thời điểm liên kết và bỏ ghim chúng tại thời điểm hủy liên kết, nhưng điều này
tạo một vectơ từ chối dịch vụ do một quy trình không gian người dùng duy nhất
sẽ có thể ghim tất cả bộ nhớ hệ thống, điều này không
mong muốn. (Đối với các trường hợp sử dụng đặc biệt và giả sử việc ghim kế toán phù hợp có thể
tuy nhiên vẫn là một tính năng được mong muốn). Những gì chúng ta cần làm trong
trường hợp chung là để có được một tham chiếu đến các trang mong muốn, hãy đảm bảo
chúng tôi được thông báo bằng cách sử dụng trình thông báo MMU ngay trước khi CPU mm hủy ánh xạ
các trang, làm bẩn chúng nếu chúng không được ánh xạ ở chế độ chỉ đọc tới GPU và
sau đó bỏ tham chiếu.
Khi chúng tôi được trình thông báo MMU thông báo rằng CPU mm sắp thả
các trang, chúng ta cần dừng quyền truy cập GPU vào các trang bằng cách đợi VM không hoạt động
trong trình thông báo MMU và đảm bảo rằng trước lần tiếp theo GPU
cố gắng truy cập bất cứ thứ gì hiện có trong phạm vi CPU mm, chúng tôi hủy ánh xạ
các trang cũ từ bảng trang GPU và lặp lại quá trình
có được tài liệu tham khảo trang mới. (Xem ZZ0000ZZ bên dưới). Lưu ý rằng khi lõi mm quyết định
trang giặt ủi, chúng tôi nhận được thông báo MMU chưa được lập bản đồ và có thể đánh dấu
các trang lại bị bẩn trước lần truy cập GPU tiếp theo. Chúng tôi cũng nhận được MMU tương tự
thông báo về tính toán NUMA mà trình điều khiển GPU thực sự không có
cần quan tâm, nhưng cho đến nay nó đã được chứng minh là khó loại trừ
một số thông báo nhất định.

Sử dụng trình thông báo MMU cho thiết bị DMA (và các phương pháp khác) được mô tả trong
ZZ0000ZZ.

Bây giờ, phương pháp lấy tham chiếu trang cấu trúc bằng cách sử dụng
Rất tiếc, get_user_pages() không thể được sử dụng dưới khóa dma_resv
vì điều đó sẽ vi phạm thứ tự khóa của khóa dma_resv so với
mmap_lock được lấy khi giải quyết lỗi trang CPU. Điều này có nghĩa
danh sách userptr gpu_vmas của gpu_vm cần được bảo vệ bởi một
khóa bên ngoài, trong ví dụ của chúng tôi dưới đây là ZZ0000ZZ.

Seqlock khoảng thời gian MMU cho userptr gpu_vma được sử dụng như sau
cách:

.. code-block:: C

   // Exclusive locking mode here is strictly needed only if there are
   // invalidated userptr gpu_vmas present, to avoid concurrent userptr
   // revalidations of the same userptr gpu_vma.
   down_write(&gpu_vm->lock);
   retry:

   // Note: mmu_interval_read_begin() blocks until there is no
   // invalidation notifier running anymore.
   seq = mmu_interval_read_begin(&gpu_vma->userptr_interval);
   if (seq != gpu_vma->saved_seq) {
           obtain_new_page_pointers(&gpu_vma);
           dma_resv_lock(&gpu_vm->resv);
           add_gpu_vma_to_revalidate_list(&gpu_vma, &gpu_vm);
           dma_resv_unlock(&gpu_vm->resv);
           gpu_vma->saved_seq = seq;
   }

   // The usual revalidation goes here.

   // Final userptr sequence validation may not happen before the
   // submission dma_fence is added to the gpu_vm's resv, from the POW
   // of the MMU invalidation notifier. Hence the
   // userptr_notifier_lock that will make them appear atomic.

   add_dependencies(&gpu_job, &gpu_vm->resv);
   down_read(&gpu_vm->userptr_notifier_lock);
   if (mmu_interval_read_retry(&gpu_vma->userptr_interval, gpu_vma->saved_seq)) {
          up_read(&gpu_vm->userptr_notifier_lock);
          goto retry;
   }

   job_dma_fence = gpu_submit(&gpu_job));

   add_dma_fence(job_dma_fence, &gpu_vm->resv);

   for_each_external_obj(gpu_vm, &obj)
          add_dma_fence(job_dma_fence, &obj->resv);

   dma_resv_unlock_all_resv_locks();
   up_read(&gpu_vm->userptr_notifier_lock);
   up_write(&gpu_vm->lock);

Mã giữa ZZ0000ZZ và
ZZ0001ZZ đánh dấu phần quan trọng bên đọc của
cái mà chúng tôi gọi là ZZ0002ZZ. Trong thực tế, userptr của gpu_vm
danh sách gpu_vma được lặp lại và quá trình kiểm tra được thực hiện đối với ZZ0003ZZ của nó
userptr gpu_vmas, mặc dù chúng tôi chỉ hiển thị một cái duy nhất ở đây.

Trình thông báo vô hiệu userptr gpu_vma MMU có thể được gọi từ
lấy lại bối cảnh và một lần nữa, để tránh vi phạm lệnh khóa, chúng tôi không thể
lấy bất kỳ khóa dma_resv nào cũng như gpu_vm->lock từ bên trong nó.

.. _Invalidation example:
.. code-block:: C

  bool gpu_vma_userptr_invalidate(userptr_interval, cur_seq)
  {
          // Make sure the exec function either sees the new sequence
          // and backs off or we wait for the dma-fence:

          down_write(&gpu_vm->userptr_notifier_lock);
          mmu_interval_set_seq(userptr_interval, cur_seq);
          up_write(&gpu_vm->userptr_notifier_lock);

          // At this point, the exec function can't succeed in
          // submitting a new job, because cur_seq is an invalid
          // sequence number and will always cause a retry. When all
          // invalidation callbacks, the mmu notifier core will flip
          // the sequence number to a valid one. However we need to
          // stop gpu access to the old pages here.

          dma_resv_wait_timeout(&gpu_vm->resv, DMA_RESV_USAGE_BOOKKEEP,
                                false, MAX_SCHEDULE_TIMEOUT);
          return true;
  }

Khi trình thông báo vô hiệu này quay trở lại, GPU không thể được sử dụng nữa
truy cập các trang cũ của userptr gpu_vma và cần làm lại
liên kết trang trước khi gửi GPU mới có thể thành công.

Lặp lại userptr gpu_vma exec_function hiệu quả
_________________________________________________

Nếu danh sách userptr gpu_vmas của gpu_vm trở nên lớn, thì đó là
không hiệu quả khi duyệt qua danh sách đầy đủ các userptrs trên mỗi
exec để kiểm tra xem mỗi userptr gpu_vma đã được lưu chưa
số thứ tự đã cũ. Giải pháp cho vấn đề này là đặt tất cả
ZZ0004ZZ userptr gpu_vmas trên một danh sách gpu_vm riêng biệt và
chỉ kiểm tra gpu_vmas có trong danh sách này trên mỗi tệp thực thi
chức năng. Danh sách này sau đó sẽ rất phù hợp với spinlock
sơ đồ khóa đó là
ZZ0000ZZ, kể từ
trong trình thông báo mmu, nơi chúng tôi thêm gpu_vmas không hợp lệ vào
danh sách, không thể lấy bất kỳ ổ khóa bên ngoài nào như
ZZ0001ZZ hoặc khóa ZZ0002ZZ. Lưu ý rằng
ZZ0003ZZ vẫn cần được lấy trong khi lặp để đảm bảo danh sách
đầy đủ, như đã đề cập trong phần đó.

Nếu sử dụng danh sách userptr không hợp lệ như thế này, hãy thử kiểm tra lại trong
Chức năng exec trở thành một cách tầm thường để kiểm tra danh sách trống không hợp lệ.

Khóa tại thời điểm liên kết và hủy liên kết
===============================

Tại thời điểm liên kết, giả sử một đối tượng GEM được hỗ trợ gpu_vma, mỗi đối tượng
gpu_vma cần được liên kết với gpu_vm_bo và điều đó
gpu_vm_bo lần lượt cần được thêm vào đối tượng GEM
danh sách gpu_vm_bo và có thể cả đối tượng bên ngoài của gpu_vm
danh sách. Điều này được gọi là ZZ0005ZZ gpu_vma và thường
yêu cầu ZZ0000ZZ và ZZ0001ZZ
được tổ chức. Khi hủy liên kết gpu_vma, các khóa tương tự sẽ được giữ,
và điều đó đảm bảo rằng khi lặp qua `ZZ0004ZZ, dưới
dma_resv của đối tượng ZZ0002ZZ hoặc GEM, gpu_vmas
tồn tại miễn là khóa mà chúng ta lặp lại không được giải phóng. cho
userptr gpu_vmas, điều tương tự cũng được yêu cầu là trong quá trình hủy vma,
ZZ0003ZZ bên ngoài được giữ lại, nếu không thì khi lặp lại
danh sách userptr không hợp lệ như được mô tả trong phần trước,
không có gì giữ được những gpu_vmas userptr đó tồn tại.

Khóa để cập nhật bảng trang lỗi trang có thể phục hồi
=====================================================

Có hai điều quan trọng chúng ta cần đảm bảo khi khóa cho
lỗi trang có thể phục hồi:

* Tại thời điểm đó, chúng tôi trả lại các trang trở lại hệ thống / bộ cấp phát cho
  tái sử dụng, sẽ không còn ánh xạ GPU nào và bất kỳ GPU TLB nào
  chắc đã bị rửa trôi.
* Việc hủy ánh xạ và ánh xạ gpu_vma không được chạy đua.

Vì việc hủy ánh xạ (hoặc hạ gục) các pte GPU thường diễn ra
ở những nơi khó hoặc thậm chí không thể lấy được bất kỳ ổ khóa cấp độ bên ngoài nào, chúng tôi
phải giới thiệu một khóa mới được giữ ở cả ánh xạ và
thời gian lập bản đồ hoặc nhìn vào các ổ khóa mà chúng tôi nắm giữ tại thời điểm lập bản đồ và
đảm bảo rằng chúng cũng được giữ tại thời điểm lập bản đồ. Dành cho người dùng
gpu_vmas, ZZ0000ZZ được giữ ở chế độ ghi trong mmu
trình thông báo vô hiệu nơi xảy ra hiện tượng Zapping. Do đó, nếu
ZZ0001ZZ cũng như ZZ0002ZZ
được giữ ở chế độ đọc trong quá trình ánh xạ, nó sẽ không chạy đua với
hạ gục. Đối với gpu_vmas được hỗ trợ bởi đối tượng GEM, việc chuyển đổi sẽ diễn ra theo
dma_resv của đối tượng GEM và đảm bảo rằng dma_resv cũng được giữ
khi điền vào bảng trang cho bất kỳ gpu_vma nào trỏ đến GEM
đối tượng, tương tự sẽ đảm bảo chúng ta không có chủng tộc.

Nếu bất kỳ phần nào của ánh xạ được thực hiện không đồng bộ
dưới hàng rào dma với những ổ khóa này đã được mở, việc hạ gục sẽ cần phải
đợi hàng rào dma đó phát tín hiệu dưới khóa liên quan trước
bắt đầu sửa đổi bảng trang.

Kể từ khi sửa đổi
cấu trúc bảng trang theo cách giải phóng bộ nhớ bảng trang
cũng có thể yêu cầu khóa cấp độ bên ngoài, việc hạ gục các ptes GPU
thường chỉ tập trung vào việc xóa các mục trong bảng trang hoặc thư mục trang
và xóa TLB, trong khi việc giải phóng bộ nhớ bảng trang được trì hoãn
thời gian hủy liên kết hoặc khởi động lại.