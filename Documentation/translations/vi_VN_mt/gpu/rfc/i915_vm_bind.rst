.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/gpu/rfc/i915_vm_bind.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==============================================
I915 VM_BIND thiết kế tính năng và các trường hợp sử dụng
==========================================

Tính năng VM_BIND
================
ioctls DRM_I915_GEM_VM_BIND/UNBIND cho phép UMD liên kết/hủy liên kết bộ đệm GEM
các đối tượng (BO) hoặc các phần của BO tại các địa chỉ ảo GPU được chỉ định trên một
không gian địa chỉ được chỉ định (VM). Những ánh xạ này (còn được gọi là liên tục
ánh xạ) sẽ liên tục trên nhiều lần gửi GPU (các lệnh gọi execbuf)
do UMD cấp mà không cần người dùng phải cung cấp danh sách tất cả các yêu cầu
ánh xạ trong mỗi lần gửi (theo yêu cầu của chế độ execbuf cũ hơn).

Các cuộc gọi VM_BIND/UNBIND cho phép UMD yêu cầu hàng rào ngoài dòng thời gian cho
báo hiệu sự hoàn thành của hoạt động liên kết/hủy liên kết.

Tính năng VM_BIND được quảng cáo tới người dùng thông qua I915_PARAM_VM_BIND_VERSION.
Người dùng phải chọn tham gia chế độ liên kết VM_BIND cho không gian địa chỉ (VM)
trong thời gian tạo VM thông qua tiện ích mở rộng I915_VM_CREATE_FLAGS_USE_VM_BIND.

Các cuộc gọi ioctl VM_BIND/UNBIND được thực hiện đồng thời trên các luồng CPU khác nhau
không được đặt hàng. Hơn nữa, các phần của hoạt động VM_BIND/UNBIND có thể được thực hiện
không đồng bộ, khi hàng rào hợp lệ được chỉ định.

Các tính năng của VM_BIND bao gồm:

* Ánh xạ nhiều địa chỉ ảo (VA) có thể ánh xạ tới cùng một trang vật lý
  của một đối tượng (bí danh).
* Ánh xạ VA có thể ánh xạ tới một phần của BO (liên kết một phần).
* Hỗ trợ chụp các ánh xạ liên tục trong kết xuất khi xảy ra lỗi GPU.
* Hỗ trợ cho các đối tượng đá quý userptr (không yêu cầu uapi đặc biệt cho việc này).

Xem xét xả TLB
------------------------
Trình điều khiển i915 sẽ xóa TLB cho mỗi lần gửi và khi một đối tượng
các trang được phát hành. Thao tác VM_BIND/UNBIND sẽ không thực hiện bất kỳ thao tác bổ sung nào.
Xả nước TLB. Mọi ánh xạ VM_BIND được thêm vào sẽ nằm trong bộ làm việc cho các lần tiếp theo.
gửi trên máy ảo đó và sẽ không có trong bộ làm việc hiện đang chạy
lô (sẽ yêu cầu xả TLB bổ sung, không được hỗ trợ).

Execbuf ioctl ở chế độ VM_BIND
-------------------------------
Máy ảo ở chế độ VM_BIND sẽ không hỗ trợ chế độ liên kết execbuf cũ hơn.
Việc xử lý execbuf ioctl ở chế độ VM_BIND khác biệt đáng kể so với
execbuf2 ioctl cũ hơn (Xem struct drm_i915_gem_execbuffer2).
Do đó, một execbuf3 ioctl mới đã được thêm vào để hỗ trợ chế độ VM_BIND. (Xem
cấu trúc drm_i915_gem_execbuffer3). execbuf3 ioctl sẽ không chấp nhận bất kỳ
nhà điều hành. Do đó, không hỗ trợ đồng bộ ngầm. Dự kiến bên dưới
công việc sẽ có thể hỗ trợ các yêu cầu cài đặt phụ thuộc đối tượng trong tất cả
trường hợp sử dụng:

"dma-buf: Thêm API để xuất tệp đồng bộ hóa"
(ZZ0000ZZ

execbuf3 ioctl mới chỉ hoạt động ở chế độ VM_BIND và chỉ chế độ VM_BIND
làm việc với execbuf3 ioctl để gửi. Tất cả các BO được ánh xạ trên VM đó (thông qua
Cuộc gọi VM_BIND) tại thời điểm cuộc gọi execbuf3 được coi là cần thiết cho việc đó
trình.

execbuf3 ioctl chỉ định trực tiếp địa chỉ lô thay vì dưới dạng
đối tượng xử lý như trong execbuf2 ioctl. execbuf3 ioctl cũng sẽ không
hỗ trợ nhiều tính năng cũ hơn như hàng rào vào/ra/gửi, mảng hàng rào,
bối cảnh đá quý mặc định và nhiều bối cảnh khác (Xem struct drm_i915_gem_execbuffer3).

Ở chế độ VM_BIND, việc phân bổ VA hoàn toàn do người dùng quản lý thay vì
trình điều khiển i915. Do đó, tất cả việc chuyển nhượng, trục xuất VA đều không được áp dụng ở
Chế độ VM_BIND. Ngoài ra, để xác định tính hoạt động của đối tượng, chế độ VM_BIND sẽ không
đang sử dụng theo dõi tham chiếu hoạt động i915_vma. Thay vào đó nó sẽ sử dụng dma-resv
phản đối điều đó (Xem ZZ0000ZZ).

Vì vậy, rất nhiều mã hiện có hỗ trợ execbuf2 ioctl, như di dời, VA
trục xuất, bảng tra cứu vma, đồng bộ hóa ngầm, theo dõi tham chiếu hoạt động vma, v.v.
không áp dụng cho execbuf3 ioctl. Do đó, tất cả các xử lý cụ thể của execbuf3
phải ở trong một tệp riêng biệt và chỉ có các chức năng chung cho các ioctls này
có thể là mã được chia sẻ nếu có thể.

Đối tượng VM_PRIVATE
-------------------
Theo mặc định, BO có thể được ánh xạ trên nhiều VM và cũng có thể là dma-buf
đã xuất khẩu. Do đó các BO này được gọi là BO chia sẻ.
Trong mỗi lần gửi execbuf, hàng rào yêu cầu phải được thêm vào
danh sách hàng rào dma-resv của tất cả các BO được chia sẻ được ánh xạ trên VM.

Tính năng VM_BIND giới thiệu tính năng tối ưu hóa trong đó người dùng có thể tạo BO
là riêng tư đối với một VM được chỉ định thông qua cờ I915_GEM_CREATE_EXT_VM_PRIVATE trong
sáng tạo BO. Không giống như các BO được chia sẻ, các BO riêng tư VM này chỉ có thể được ánh xạ trên
VM mà chúng ở chế độ riêng tư và không thể xuất dma-buf.
Tất cả các BO riêng của VM đều chia sẻ đối tượng dma-resv. Do đó trong mỗi execbuf
gửi, họ chỉ cần cập nhật một danh sách hàng rào dma-resv. Như vậy, việc nhanh
đường dẫn (nơi ánh xạ bắt buộc đã bị ràng buộc) độ trễ gửi là O(1)
ghi số lượng VM riêng BO.

Hệ thống phân cấp khóa VM_BIND
-------------------------
Thiết kế khóa ở đây hỗ trợ chế độ execbuf cũ hơn (dựa trên người thực thi), chế độ
chế độ VM_BIND mới hơn, chế độ VM_BIND có lỗi trang GPU và tương lai có thể xảy ra
hỗ trợ cấp phát hệ thống (Xem ZZ0000ZZ).
Chế độ execbuf cũ hơn và chế độ VM_BIND mới hơn không có lỗi trang quản lý
nơi lưu trữ sao lưu bằng cách sử dụng dma_fence. Chế độ VM_BIND có lỗi trang
và hỗ trợ cấp phát hệ thống hoàn toàn không sử dụng bất kỳ dma_fence nào.

Thứ tự khóa VM_BIND như sau.

1) Lock-A: Một mutex vm_bind sẽ bảo vệ danh sách vm_bind. Khóa này được đưa vào
   lệnh gọi vm_bind/vm_unbind ioctl, trong đường dẫn execbuf và trong khi giải phóng
   lập bản đồ.

Trong tương lai, khi lỗi trang GPU được hỗ trợ, chúng tôi có thể sử dụng
   thay vào đó, rwsem, để nhiều trình xử lý lỗi trang có thể đảm nhận việc đọc
   lock để tra cứu ánh xạ và do đó có thể chạy song song.
   Chế độ liên kết execbuf cũ hơn không cần khóa này.

2) Lock-B: Khóa dma-resv của đối tượng sẽ bảo vệ trạng thái i915_vma và cần phải
   được giữ trong khi liên kết/hủy liên kết vma trong trình chạy không đồng bộ và trong khi cập nhật
   danh sách hàng rào dma-resv của một đối tượng. Lưu ý rằng các BO riêng của VM sẽ
   chia sẻ một đối tượng dma-resv.

Hỗ trợ cấp phát hệ thống trong tương lai sẽ sử dụng khóa được quy định HMM
   thay vào đó.

3) Lock-C: Spinlock/s để bảo vệ một số danh sách của VM như danh sách
   vmas bị vô hiệu (do bị trục xuất và vô hiệu của userptr), v.v.

Khi lỗi trang GPU được hỗ trợ, đường dẫn execbuf không lấy bất kỳ lỗi nào trong số này
ổ khóa. Ở đó chúng ta sẽ đơn giản đập địa chỉ bộ đệm lô mới vào vòng và
sau đó báo cho bộ lập lịch chạy điều đó. Việc lấy khóa chỉ xảy ra từ trang
trình xử lý lỗi, trong đó chúng tôi lấy khóa A ở chế độ đọc, bất kỳ khóa B nào chúng tôi cần
tìm bộ lưu trữ sao lưu (khóa dma_resv cho các đối tượng đá quý và hmm/core mm cho
bộ cấp phát hệ thống) và một số khóa bổ sung (lock-D) để quản lý trang
cuộc đua bàn. Chế độ lỗi trang không cần phải thao tác với danh sách vm,
vì vậy sẽ không bao giờ cần lock-C.

Xử lý VM_BIND LRU
---------------------
Chúng ta cần đảm bảo các đối tượng được ánh xạ VM_BIND được gắn thẻ LRU đúng cách để tránh
suy thoái hiệu suất. Chúng tôi cũng sẽ cần hỗ trợ cho việc di chuyển LRU số lượng lớn
Đối tượng VM_BIND để tránh độ trễ bổ sung trong đường dẫn execbuf.

Các trang bảng trang tương tự như các đối tượng được ánh xạ VM_BIND (Xem
ZZ0000ZZ) và được duy trì trên mỗi VM và cần phải
được ghim vào bộ nhớ khi VM được kích hoạt (tức là khi có lệnh gọi execbuf với
máy ảo đó). Vì vậy, việc di chuyển số lượng lớn LRU của các trang trong bảng trang cũng là cần thiết.

Cách sử dụng VM_BIND DMA_resv
-----------------------
Hàng rào cần được thêm vào tất cả các đối tượng được ánh xạ VM_BIND. Trong mỗi lần thực hiện
gửi, chúng sẽ được thêm vào bằng cách sử dụng DMA_RESV_USAGE_BOOKKEEP để ngăn chặn
đồng bộ hóa quá mức (Xem enum dma_resv_usage). Người ta có thể ghi đè nó bằng một trong hai
Sử dụng DMA_RESV_USAGE_READ hoặc DMA_RESV_USAGE_WRITE trong đối tượng rõ ràng
thiết lập phụ thuộc.

Lưu ý rằng ioctls DRM_I915_GEM_WAIT và DRM_I915_GEM_BUSY không kiểm tra
Việc sử dụng DMA_RESV_USAGE_BOOKKEEP và do đó không nên sử dụng vào cuối đợt
kiểm tra. Thay vào đó, nên sử dụng hàng rào execbuf3 để kiểm tra cuối đợt
(Xem cấu trúc drm_i915_gem_execbuffer3).

Ngoài ra, trong chế độ VM_BIND, hãy sử dụng api dma-resv để xác định mức độ hoạt động của đối tượng
(Xem dma_resv_test_signaled() và dma_resv_wait_timeout()) và không sử dụng
tính năng theo dõi tham chiếu hoạt động i915_vma cũ hơn không được dùng nữa. Điều này nên được
dễ dàng hơn để làm cho nó hoạt động với chương trình phụ trợ TTM hiện tại.

Trường hợp sử dụng Mesa
--------------
VM_BIND có khả năng giảm chi phí CPU ở Mesa (cả Vulkan và Iris),
do đó cải thiện hiệu suất của các ứng dụng gắn với CPU. Nó cũng cho phép chúng ta
triển khai Tài nguyên thưa thớt của Vulkan. Với hiệu suất phần cứng GPU ngày càng tăng,
việc giảm chi phí CPU trở nên có tác động hơn.


Các trường hợp sử dụng VM_BIND khác
========================

Bối cảnh tính toán chạy dài
------------------------------
Việc sử dụng dma-fence mong đợi rằng chúng sẽ hoàn thành trong khoảng thời gian hợp lý.
Mặt khác, việc tính toán có thể kéo dài. Do đó nó thích hợp cho
tính toán để sử dụng hàng rào người dùng/bộ nhớ (Xem ZZ0000ZZ) và cách sử dụng hàng rào dma
phải được giới hạn chỉ tiêu thụ trong kernel.

Trong trường hợp không có lỗi trang GPU, trình điều khiển hạt nhân khi bộ đệm bị vô hiệu hóa
sẽ bắt đầu tạm dừng (ưu tiên) bối cảnh chạy dài, kết thúc
vô hiệu hóa, xác nhận lại BO và sau đó tiếp tục bối cảnh tính toán. Đây là
được thực hiện bằng cách có hàng rào ưu tiên theo ngữ cảnh được kích hoạt khi ai đó cố gắng
để chờ đợi và kích hoạt quyền ưu tiên ngữ cảnh.

Hàng rào người dùng/bộ nhớ
~~~~~~~~~~~~~~~~~~
Hàng rào người dùng/bộ nhớ là một cặp <địa chỉ, giá trị>. Để báo hiệu hàng rào người dùng,
giá trị được chỉ định sẽ được ghi tại địa chỉ ảo được chỉ định và đánh thức
quá trình chờ đợi. Hàng rào người dùng có thể được báo hiệu bằng GPU hoặc kernel async
công nhân (như khi hoàn thành liên kết). Người dùng có thể chờ đợi trên hàng rào người dùng với một cái mới
hàng rào người dùng chờ ioctl.

Đây là một số công việc trước đây về vấn đề này:
ZZ0000ZZ

Gửi có độ trễ thấp
~~~~~~~~~~~~~~~~~~~~~~~
Cho phép tính toán UMD gửi trực tiếp các công việc GPU thay vì thông qua execbuf
ioctl. Điều này có thể thực hiện được bởi VM_BIND không được đồng bộ hóa với
execbuf. VM_BIND cho phép liên kết/hủy liên kết các ánh xạ cần thiết cho trực tiếp
công việc đã nộp.

Trình gỡ lỗi
---------
Với giao diện sự kiện gỡ lỗi, quy trình không gian người dùng (trình gỡ lỗi) có thể theo dõi
và hành động dựa trên các tài nguyên được tạo bởi một quy trình khác (đã được gỡ lỗi) và được đính kèm
tới GPU thông qua giao diện vm_bind.

Lỗi trang GPU
----------------
Lỗi trang GPU khi được hỗ trợ (trong tương lai), sẽ chỉ được hỗ trợ trong
Chế độ VM_BIND. Trong khi cả chế độ execbuf cũ hơn và chế độ VM_BIND mới hơn của
ràng buộc sẽ yêu cầu sử dụng dma-fence để đảm bảo nơi cư trú, lỗi trang GPU
chế độ khi được hỗ trợ, sẽ không sử dụng bất kỳ hàng rào dma nào vì nơi cư trú hoàn toàn được quản lý
bằng cách cài đặt và xóa/vô hiệu hóa các mục trong bảng trang.

Cài đặt gợi ý cấp trang
--------------------------
VM_BIND cho phép cài đặt bất kỳ gợi ý nào trên mỗi ánh xạ thay vì trên mỗi BO. Gợi ý có thể
bao gồm vị trí và tính nguyên tử. Gợi ý sắp xếp cấp độ Sub-BO sẽ còn nhiều hơn nữa
phù hợp với tính năng hỗ trợ lỗi trang theo yêu cầu GPU sắp tới.

Cài đặt bộ đệm/CLOS cấp trang
-------------------------------
VM_BIND cho phép cài đặt bộ đệm/CLOS trên mỗi ánh xạ thay vì trên mỗi BO.

Phân bổ bảng trang có thể loại bỏ
---------------------------------
Làm cho việc phân bổ có thể phân trang có thể bị loại bỏ và quản lý chúng tương tự như VM_BIND
các đối tượng được ánh xạ. Các trang của bảng trang tương tự như các ánh xạ liên tục của một
VM (điểm khác biệt ở đây là các trang trong bảng trang sẽ không có i915_vma
cấu trúc và sau khi hoán đổi các trang trở lại, liên kết trang mẹ cần phải được
đã cập nhật).

Hỗ trợ bộ nhớ ảo chia sẻ (SVM)
------------------------------------
Giao diện VM_BIND có thể được sử dụng để ánh xạ trực tiếp bộ nhớ hệ thống (không cần gem BO
trừu tượng) bằng giao diện HMM. SVM chỉ được hỗ trợ với trang GPU
lỗi được kích hoạt.

VM_BIND UAPI
=============

.. kernel-doc:: Documentation/gpu/rfc/i915_vm_bind.h
