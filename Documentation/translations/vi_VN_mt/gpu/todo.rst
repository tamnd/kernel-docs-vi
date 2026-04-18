.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/todo.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _todo:

==============
Danh sách TODO
==============

Phần này chứa danh sách các tác vụ dọn dẹp nhỏ hơn trong kernel DRM
hệ thống con đồ họa hữu ích cho các dự án người mới. Hoặc cho những ngày mưa chậm.

Khó khăn
----------

Để làm cho nó dễ dàng hơn, nhiệm vụ được phân loại thành các cấp độ khác nhau:

Người khởi xướng: Nhiệm vụ tốt để bắt đầu với hệ thống con DRM.

Trung cấp: Các nhiệm vụ cần một số kinh nghiệm làm việc trong DRM
hệ thống con hoặc một số kiến thức đồ họa/hiển thị GPU cụ thể. Đối với vấn đề gỡ lỗi
thật tốt khi có sẵn phần cứng liên quan (hoặc thiết lập trình điều khiển ảo)
để thử nghiệm.

Nâng cao: Các tác vụ phức tạp cần hiểu biết khá tốt về hệ thống con DRM
và chủ đề đồ họa. Nói chung cần phần cứng có liên quan để phát triển và
thử nghiệm.

Chuyên gia: Chỉ thử những điều này nếu bạn đã hoàn thành thành công một số việc khó
đã tái cấu trúc và là chuyên gia trong lĩnh vực cụ thể

Tái cấu trúc toàn hệ thống con
==============================

Mã mở drm_simple_encoding_init()
-----------------------------------

Trình trợ giúp drm_simple_encode_init() được cho là để đơn giản hóa bộ mã hóa
khởi tạo. Thay vào đó nó chỉ thêm một lớp trung gian giữa nguyên tử
cài đặt chế độ và trình điều khiển DRM.

Nhiệm vụ ở đây là loại bỏ drm_simple_encoding_init(). Tìm kiếm tài xế
gọi drm_simple_encode_init() và nội tuyến trình trợ giúp. Người lái xe sẽ
cũng cần phiên bản drm_encode_funcs riêng của nó.

Liên hệ: Thomas Zimmermann, người bảo trì trình điều khiển tương ứng

Cấp độ: Dễ

Thay thế struct drm_simple_display_pipe bằng các trình trợ giúp nguyên tử thông thường
--------------------------------------------------------------------------------------

Kiểu dữ liệu struct drm_simple_display_pipe và các phần trợ giúp của nó được cho là
để đơn giản hóa việc phát triển trình điều khiển. Thay vào đó họ chỉ thêm một lớp trung gian
giữa cài đặt chế độ nguyên tử và trình điều khiển DRM.

Vẫn có trình điều khiển sử dụng drm_simple_display_pipe. Nhiệm vụ ở đây là
chuyển đổi chúng để sử dụng các trợ giúp nguyên tử thông thường. Tìm kiếm tài xế gọi
drm_simple_display_pipe_init() và nội tuyến tất cả những người trợ giúp từ drm_simple_kms_helper.c
vào trình điều khiển, do đó không yêu cầu giao diện KMS đơn giản. Xin vui lòng cũng
đổi tên tất cả các chức năng nội tuyến theo quy ước của trình điều khiển.

Liên hệ: Thomas Zimmermann, người bảo trì trình điều khiển tương ứng

Cấp độ: Dễ

Xóa triển khai câm_map_offset tùy chỉnh
---------------------------------------------

Thay vào đó, tất cả các trình điều khiển dựa trên GEM nên sử dụng drm_gem_create_mmap_offset().
Kiểm tra từng trình điều khiển riêng lẻ, đảm bảo nó sẽ hoạt động với trình điều khiển chung
triển khai (có rất nhiều khóa còn sót lại lỗi thời trong nhiều
triển khai), sau đó loại bỏ nó.

Liên hệ: Simona Vetter, người bảo trì trình điều khiển tương ứng

Trình độ: Trung cấp

Chuyển đổi trình điều khiển KMS hiện có sang chế độ nguyên tử
-------------------------------------------------------------

3.19 có các giao diện và trợ giúp chế độ nguyên tử, vì vậy các trình điều khiển giờ đây có thể
đã chuyển đổi qua. Các nhà soạn nhạc hiện đại như Wayland hoặc Surfaceflinger trên Android
thực sự muốn có một giao diện chế độ nguyên tử, vì vậy đây là tất cả về sự tươi sáng
tương lai.

Có hướng dẫn chuyển đổi cho nguyên tử [1]_ và tất cả những gì bạn cần là GPU cho
trình điều khiển không được chuyển đổi.  Chuỗi bài "Tổng quan về thiết kế cài đặt chế độ nguyên tử" [2]_
[3]_ tại LWN.net cũng có thể hữu ích.

Là một phần của trình điều khiển này cũng cần phải chuyển đổi sang mặt phẳng phổ quát (có nghĩa là
hiển thị chính và con trỏ dưới dạng đối tượng mặt phẳng thích hợp). Nhưng điều đó dễ dàng hơn nhiều
thực hiện bằng cách trực tiếp sử dụng lệnh gọi lại trình điều khiển trợ giúp nguyên tử mới.

  .. [1] https://blog.ffwll.ch/2014/11/atomic-modeset-support-for-kms-drivers.html
  .. [2] https://lwn.net/Articles/653071/
  .. [3] https://lwn.net/Articles/653466/

Liên hệ: Simona Vetter, người bảo trì trình điều khiển tương ứng

Cấp độ: Nâng cao

Dọn dẹp sự nhầm lẫn phối hợp bị cắt bớt xung quanh các mặt phẳng
----------------------------------------------------------------

Chúng tôi có một người trợ giúp để giải quyết vấn đề này bằng drm_plane_helper_check_update(), nhưng
nó không được sử dụng nhất quán. Điều này cần được khắc phục, tốt nhất là trong nguyên tử
người trợ giúp (và người lái xe sau đó chuyển sang tọa độ đã cắt bớt). Có lẽ là
người trợ giúp cũng nên được chuyển từ drm_plane_helper.c sang người trợ giúp nguyên tử, sang
tránh nhầm lẫn - những trợ giúp khác trong tệp đó đều là những phiên bản cũ không được dùng nữa
những người giúp đỡ.

Liên hệ: Ville Syrjälä, Simona Vetter, người bảo trì tài xế

Cấp độ: Nâng cao

Cải thiện người trợ giúp Atomic_check máy bay
---------------------------------------------

Ngoài các tọa độ bị cắt bớt ngay phía trên, còn có một số thứ chưa tối ưu
với những người trợ giúp hiện tại:

- drm_plane_helper_funcs->atomic_check được gọi để bật hoặc tắt
  máy bay. Tốt nhất thì điều này có vẻ khiến người lái xe bối rối, tệ nhất là họ sẽ nổ tung
  khi máy bay bị vô hiệu hóa mà không có CRTC. Cách xử lý đặc biệt duy nhất là
  đặt lại các giá trị trong cấu trúc trạng thái mặt phẳng, thay vào đó nên di chuyển
  vào các hàm drm_plane_funcs->atomic_duplicate_state.

- Khi đã xong, người trợ giúp có thể ngừng gọi ->atomic_check cho người bị vô hiệu hóa
  máy bay.

- Sau đó chúng ta có thể xem qua tất cả các trình điều khiển và loại bỏ những phần ít nhiều bị nhầm lẫn
  kiểm tra máy bay_state->fb và máy bay_state->crtc.

Liên hệ: Simona Vetter

Cấp độ: Nâng cao

Chuyển đổi trình điều khiển nguyên tử ban đầu thành trình trợ giúp cam kết không đồng bộ
----------------------------------------------------------------------------------------

Trong năm đầu tiên, trình trợ giúp chế độ nguyên tử không hỗ trợ chế độ không đồng bộ /
các cam kết không chặn và mọi tài xế đều phải thực hiện chúng bằng tay. Điều này đã được sửa
hiện tại, nhưng vẫn còn rất nhiều trình điều khiển hiện có có thể dễ dàng sử dụng
chuyển đổi sang cơ sở hạ tầng mới.

Một vấn đề với những người trợ giúp là họ yêu cầu trình điều khiển xử lý việc hoàn thành
các sự kiện cho các cam kết nguyên tử một cách chính xác. Nhưng dù sao sửa những lỗi này cũng tốt.

Có liên quan một chút là bản hack Legacy_cursor_update, nên được thay thế bằng
chức năng Atomic_async_check/commit mới trong trình trợ giúp trong trình điều khiển
vẫn nhìn vào lá cờ đó.

Liên hệ: Simona Vetter, người bảo trì trình điều khiển tương ứng

Cấp độ: Nâng cao

Đổi tên drm_atomic_state
------------------------

Khung KMS sử dụng hai định nghĩa hơi khác nhau cho ZZ0000ZZ
khái niệm. Đối với một đối tượng nhất định (mặt phẳng, CRTC, bộ mã hóa, v.v., vì vậy
ZZ0001ZZ), trạng thái là toàn bộ trạng thái của đối tượng đó. Tuy nhiên,
ở cấp độ thiết bị, ZZ0002ZZ đề cập đến bản cập nhật trạng thái cho một
số lượng đối tượng có hạn.

Trạng thái không phải là toàn bộ trạng thái của thiết bị mà chỉ là trạng thái đầy đủ của một số
các đối tượng trong thiết bị đó. Điều này gây nhầm lẫn cho người mới và
ZZ0000ZZ nên được đổi tên thành một cái gì đó rõ ràng hơn như
ZZ0001ZZ.

Ngoài việc đổi tên cấu trúc, nó cũng có nghĩa là đổi tên một số
các chức năng liên quan (ZZ0000ZZ, ZZ0001ZZ,
ZZ0002ZZ, ZZ0003ZZ,
ZZ0004ZZ, v.v.).

Liên hệ: Maxime Ripard <mripard@kernel.org>

Cấp độ: Nâng cao

Bụi phóng xạ từ nguyên tử KMS
-----------------------------

ZZ0000ZZ cung cấp một loạt chức năng triển khai kế thừa
IOCTL trên giao diện trình điều khiển nguyên tử mới. Điều đó thực sự tốt đẹp cho
chuyển đổi dần dần các trình điều khiển, nhưng tiếc là sự không phù hợp về mặt ngữ nghĩa
hơi quá nghiêm trọng. Vì vậy có một số công việc tiếp theo để điều chỉnh chức năng
giao diện để khắc phục những vấn đề này:

* nguyên tử cần khóa lấy bối cảnh. Tại thời điểm đó đã trôi qua
  ngầm với một số vụ hack khủng khiếp và nó cũng được phân bổ bằng
  ZZ0000ZZ hậu trường. Tất cả các đường dẫn cũ cần bắt đầu phân bổ
  bối cảnh thu được một cách rõ ràng trên ngăn xếp và sau đó chuyển nó xuống
  trình điều khiển một cách rõ ràng để các hàm kế thừa trên nguyên tử có thể sử dụng chúng.

Ngoại trừ một số mã trình điều khiển, việc này được thực hiện. Nhiệm vụ này phải được hoàn thành trước
  thêm WARN_ON(!drm_drv_uses_atomic_modeset) vào drm_modeset_lock_all().

* Một đống hook vtable hiện nay đặt sai vị trí: DRM bị chia cắt
  giữa các bảng vfunc lõi (có tên ZZ0000ZZ), được sử dụng để
  triển khai không gian người dùng ABI. Và sau đó là các móc tùy chọn cho
  thư viện trợ giúp (tên ZZ0001ZZ), hoàn toàn dành cho
  sử dụng nội bộ. Một số móc này nên được chuyển từ ZZ0002ZZ sang
  ZZ0003ZZ vì chúng không phải là một phần của lõi ABI. Có một
  Nhận xét ZZ0004ZZ trong kerneldoc cho từng trường hợp như vậy trong ZZ0005ZZ.

Liên hệ: Simona Vetter

Trình độ: Trung cấp

Di chuyển Khóa đối tượng bộ đệm sang dma_resv_lock()
----------------------------------------------------

Nhiều trình điều khiển có sơ đồ khóa theo đối tượng riêng, thường sử dụng
mutex_lock(). Điều này gây ra đủ loại rắc rối cho việc chia sẻ bộ đệm, vì
tùy thuộc vào trình điều khiển nào là nhà xuất khẩu và nhà nhập khẩu, hệ thống phân cấp khóa là
đảo ngược.

Để giải quyết vấn đề này chúng ta cần một cơ chế khóa cho mỗi đối tượng tiêu chuẩn, đó là
dma_resv_lock(). Khóa này cần phải gọi là khóa ngoài cùng, với tất cả
loại bỏ các khóa cho mỗi đối tượng cụ thể của trình điều khiển khác. Vấn đề là việc triển khai
sự thay đổi thực tế đối với hợp đồng khóa là ngày cờ, do struct dma_buf
chia sẻ bộ đệm.

Cấp độ: Chuyên gia

Chuyển đổi ghi nhật ký thành các hàm drm_* với tham số drm_device
-----------------------------------------------------------------

Đối với các trình điều khiển có thể có nhiều phiên bản, cần phải
phân biệt giữa cái nào trong nhật ký. Vì DRM_INFO/WARN/ERROR
đừng làm điều này, các trình điều khiển đã sử dụng dev_info/warn/err để tạo ra sự khác biệt này. Chúng tôi
hiện có các biến thể drm_* của chức năng in drm, vì vậy chúng ta có thể bắt đầu chuyển đổi
những trình điều khiển đó quay lại sử dụng thông báo tường trình cụ thể có định dạng drm.

Trước khi bạn bắt đầu chuyển đổi này, vui lòng liên hệ với những người bảo trì có liên quan để thực hiện
chắc chắn công việc của bạn sẽ được hợp nhất - không phải ai cũng đồng ý rằng macro dmesg DRM
tốt hơn.

Liên hệ: Sean Paul, Người bảo trì trình điều khiển bạn dự định chuyển đổi

Cấp độ: Người mới bắt đầu

Chuyển đổi trình điều khiển để sử dụng tạm dừng/tiếp tục chế độ đơn giản
------------------------------------------------------------------------

Hầu hết các trình điều khiển (trừ i915 và nouveau) sử dụng
drm_atomic_helper_suspend/resume() có thể được chuyển đổi để sử dụng
drm_mode_config_helper_suspend/resume(). Ngoài ra vẫn còn phiên bản mã mở
của mã tạm dừng/tiếp tục nguyên tử trong trình điều khiển chế độ nguyên tử cũ hơn.

Liên hệ: Người bảo trì driver mà bạn dự định chuyển đổi

Trình độ: Trung cấp

Thực hiện lại các hàm trong drm_fbdev_fb_ops không có fbdev
-----------------------------------------------------------

Một số hàm gọi lại trong drm_fbdev_fb_ops có thể được hưởng lợi từ
được viết lại mà không phụ thuộc vào mô-đun fbdev. Một số
người trợ giúp có thể hưởng lợi nhiều hơn từ việc sử dụng struct iosys_map thay vì
con trỏ thô.

Liên hệ: Thomas Zimmermann <tzimmermann@suse.de>, Simona Vetter

Cấp độ: Nâng cao

Điểm chuẩn và tối ưu hóa chức năng làm mờ và chuyển đổi định dạng
-----------------------------------------------------------------

Vẽ để hiển thị nhanh bộ nhớ là rất quan trọng đối với nhiều ứng dụng'
hiệu suất.

Trên ít nhất x86-64, sys_imageblit() chậm hơn đáng kể so với
cfb_imageblit(), mặc dù cả hai đều sử dụng cùng một thuật toán làm mờ và
cái sau được viết cho bộ nhớ I/O. Hóa ra là cfb_imageblit()
sử dụng hướng dẫn movl, trong khi sys_imageblit dường như không. Cái này
có vẻ như có vấn đề với trình tối ưu hóa của gcc. Chuyển đổi định dạng của DRM
người trợ giúp có thể gặp phải vấn đề tương tự.

Điểm chuẩn và tối ưu hóa các trình trợ giúp sys_() của fbdev và chuyển đổi định dạng của DRM
những người giúp đỡ. Trong trường hợp có thể được tối ưu hóa hơn nữa, có thể triển khai một cách khác
thuật toán. Để tối ưu hóa vi mô, hãy sử dụng rõ ràng các hướng dẫn movl/movq.
Điều đó có thể yêu cầu những người trợ giúp theo kiến trúc cụ thể (ví dụ: storel()
storeq()).

Liên hệ: Thomas Zimmermann <tzimmermann@suse.de>

Trình độ: Trung cấp

dọn dẹp drm_framebuffer_funcs và drm_mode_config_funcs.fb_create
-----------------------------------------------------------------

Nhiều trình điều khiển hơn có thể được chuyển sang trình trợ giúp drm_gem_framebuffer.
Các khoản tạm giữ khác nhau:

- Cần chuyển sang mã theo dõi bẩn chung chung bằng cách sử dụng
  drm_atomic_helper_dirtyfb trước tiên (ví dụ: qxl).

- Cần chuyển sang drm_fbdev_generic_setup(), nếu không thì custom fb rất nhiều
  mã thiết lập không thể xóa được.

- Cần chuyển sang drm_gem_fb_create(), vì bây giờ drm_gem_fb_create() sẽ kiểm tra
  định dạng hợp lệ cho trình điều khiển nguyên tử.

- Nhiều trình điều khiển thuộc lớp con drm_framebuffer, chúng tôi cần một trình điều khiển nhúng tương thích
  phiên bản của các hàm varios drm_gem_fb_create. Có lẽ được gọi
  drm_gem_fb_create/_with_dirty/_with_funcs nếu cần.

Liên hệ: Simona Vetter

Trình độ: Trung cấp

Hỗ trợ defio fbdev chung
---------------------------

Mã hỗ trợ defio trong lõi fbdev có một số yêu cầu rất cụ thể,
điều đó có nghĩa là trình điều khiển cần phải có bộ đệm khung đặc biệt cho fbdev. chính
vấn đề là nó sử dụng một số trường trong chính trang cấu trúc, điều này làm hỏng shmem
đồ vật đá quý (và những thứ khác). Để hỗ trợ defio, trình điều khiển bị ảnh hưởng cần có
việc sử dụng bộ đệm bóng, có thể thêm CPU và chi phí bộ nhớ.

Giải pháp khả thi là viết mã defio mmap của riêng chúng ta vào drm fbdev
thi đua. Nó sẽ cần phải bao bọc hoàn toàn các hoạt động mmap hiện có, chuyển tiếp
mọi thứ sau khi nó đã thực hiện xong thủ thuật write-protect/mkwrite:

- Trong trình trợ giúp drm_fbdev_fb_mmap, nếu chúng ta cần defio, hãy thay đổi
  trang mặc định được bảo vệ chống ghi bằng thứ gì đó như thế này ::

vma->vm_page_prot = pgprot_wrprotect(vma->vm_page_prot);

- Đặt lệnh gọi lại mkwrite và fsync với cách triển khai tương tự như lõi
  công cụ định dạng fbdev. Tất cả những thứ này đều hoạt động trên ptes đơn giản, thực tế chúng không
  yêu cầu một trang cấu trúc.  uff. Tất cả những thứ này sẽ hoạt động trên ptes đơn giản, chúng không
  thực sự yêu cầu một trang cấu trúc.

- Theo dõi các trang bẩn trong một cấu trúc riêng biệt (trường bit có một bit trên mỗi trang
  nên hoạt động) để tránh làm tắc nghẽn trang cấu trúc.

Có thể cũng tốt nếu có một số trường hợp thử nghiệm igt cho việc này.

Liên hệ: Simona Vetter, Noralf Tronnes

Cấp độ: Nâng cao

sửa lỗi đăng ký/hủy đăng ký kết nối
-----------------------------------

- Đối với hầu hết các trình kết nối, bạn không thể gọi drm_connector_register/unregister
  trực tiếp từ mã trình điều khiển, drm_dev_register/unregister hãy xử lý việc này
  rồi. Chúng tôi có thể loại bỏ tất cả chúng.

- Đối với trình điều khiển dp, điều này rắc rối hơn một chút vì chúng ta cần có đầu nối
  đã đăng ký khi gọi drm_dp_aux_register. Hãy khắc phục điều này bằng cách thay vì gọi
  drm_dp_aux_init và chuyển đăng ký thực tế sang Late_register
  gọi lại theo khuyến nghị trong kerneldoc.

Trình độ: Trung cấp

Xóa các lệnh gọi lại tải/dỡ tải
-------------------------------

Lệnh gọi lại tải/dỡ tải trong struct &drm_driver có rất nhiều chức năng ở giữa, cộng thêm
vì lý do lịch sử, họ đặt hàng sai (và chúng tôi không thể khắc phục điều đó)
giữa việc thiết lập cấu trúc &drm_driver và gọi drm_dev_register().

- Làm lại trình điều khiển để không còn sử dụng lệnh gọi lại tải/dỡ tải nữa, mã hóa trực tiếp
  trình tự tải/dỡ vào chức năng thăm dò của trình điều khiển.

- Sau khi tất cả các trình điều khiển được chuyển đổi, hãy xóa lệnh gọi lại tải/dỡ tải.

Liên hệ: Simona Vetter

Trình độ: Trung cấp

Thay thế drm_ detect_hdmi_monitor() bằng drm_display_info.is_hdmi
-----------------------------------------------------------------

Khi EDID được phân tích cú pháp, thông tin hỗ trợ HDMI của màn hình sẽ có sẵn thông qua
drm_display_info.is_hdmi. Nhiều trình điều khiển vẫn gọi drm_ detect_hdmi_monitor() để
truy xuất thông tin tương tự nhưng kém hiệu quả hơn.

Kiểm tra từng trình điều khiển riêng lẻ gọi drm_ detect_hdmi_monitor() và chuyển sang
drm_display_info.is_hdmi nếu có.

Liên hệ: Laurent Pinchart, người bảo trì trình điều khiển tương ứng

Trình độ: Trung cấp

Hợp nhất các thuộc tính của bộ chế độ trình điều khiển tùy chỉnh
----------------------------------------------------------------

Trước khi chế độ nguyên tử diễn ra, nhiều trình điều khiển đã tạo chế độ riêng của họ
tài sản. Trong số những thứ khác, nguyên tử đưa ra yêu cầu tùy chỉnh,
Không nên sử dụng các thuộc tính cụ thể của trình điều khiển.

Đối với nhiệm vụ này, chúng tôi mong muốn giới thiệu những công cụ trợ giúp cốt lõi hoặc tái sử dụng những công cụ trợ giúp hiện có
nếu có:

Một danh sách ví dụ nhanh chóng, chưa được xác nhận.

Giới thiệu những người trợ giúp cốt lõi:
- âm thanh (amdgpu, intel, gma500, radeon)
- độ sáng, độ tương phản, v.v. (armada, nouveau) - chỉ lớp phủ (?)
- phát sóng rgb (gma500, intel)
- colorkey (armada, nouveau, rcar) - chỉ lớp phủ (?)
- hoà sắc (amdgpu, nouveau, radeon) - khác nhau giữa các trình điều khiển
- gia đình quét ngầm (amdgpu, radeon, nouveau)

Đã có trong cốt lõi:
- không gian màu (sti)
- tên định dạng tv, cải tiến (gma500, intel)
- quét quá mức tv, lề, v.v. (gma500, intel)
- zorder (omapdrm) - giống như zpos (?)


Liên hệ: Emil Velikov, người bảo trì trình điều khiển tương ứng

Trình độ: Trung cấp

Sử dụng struct iosys_map trong toàn bộ codebase
-----------------------------------------------

Con trỏ tới bộ nhớ thiết bị dùng chung được lưu trữ trong struct iosys_map. Mỗi
instance biết liệu nó đề cập đến hệ thống hay bộ nhớ I/O. Hầu hết DRM trên toàn thế giới
giao diện đã được chuyển đổi để sử dụng struct iosys_map, nhưng việc triển khai
thường vẫn sử dụng con trỏ thô.

Nhiệm vụ là sử dụng struct iosys_map ở nơi hợp lý.

* Người quản lý bộ nhớ nên sử dụng struct iosys_map cho bộ đệm được nhập dma-buf.
* TTM có thể được hưởng lợi từ việc sử dụng struct iosys_map nội bộ.
* Trình trợ giúp sao chép và làm mờ bộ đệm khung sẽ hoạt động trên struct iosys_map.

Liên hệ: Thomas Zimmermann <tzimmermann@suse.de>, Christian König, Simona Vetter

Trình độ: Trung cấp

Xem lại tất cả trình điều khiển để cài đặt struct drm_mode_config.{max_width,max_height} một cách chính xác
-----------------------------------------------------------------------------------------------------------

Các giá trị trong struct drm_mode_config.{max_width,max_height} mô tả
kích thước bộ đệm khung được hỗ trợ tối đa. Đó là kích thước màn hình ảo nhưng nhiều
trình điều khiển coi nó như những hạn chế của độ phân giải vật lý.

Độ rộng tối đa phụ thuộc vào khoảng cách quét tối đa của phần cứng. các
chiều cao tối đa phụ thuộc vào dung lượng bộ nhớ video có thể định địa chỉ. Xem lại tất cả
trình điều khiển để khởi tạo các trường với giá trị chính xác.

Liên hệ: Thomas Zimmermann <tzimmermann@suse.de>

Trình độ: Trung cấp

Yêu cầu vùng bộ nhớ trong tất cả trình điều khiển fbdev
-------------------------------------------------------

Trình điều khiển fbdev cũ/cũ không yêu cầu bộ nhớ của chúng đúng cách.
Đi qua các trình điều khiển này và thêm mã để yêu cầu vùng bộ nhớ
mà người lái xe sử dụng. Điều này yêu cầu thêm lệnh gọi tới request_mem_khu vực(),
pci_request_zone() hoặc các chức năng tương tự. Sử dụng người trợ giúp để dọn dẹp được quản lý
nếu có thể. Các khu vực có vấn đề bao gồm phần cứng có phạm vi độc quyền
như VGA. VGA16fb không yêu cầu phạm vi như mong đợi.
Các tài xế làm việc này khá tệ và thường có xung đột giữa các tài xế.
Trình điều khiển DRM và fbdev. Tuy nhiên, đó là điều đúng đắn để làm.

Liên hệ: Thomas Zimmermann <tzimmermann@suse.de>

Cấp độ: Người mới bắt đầu

Xóa phụ thuộc trình điều khiển trên FB_DEVICE
---------------------------------------------

Một số trình điều khiển fbdev cung cấp các thuộc tính thông qua sysfs và do đó phụ thuộc vào
trên CONFIG_FB_DEVICE để được chọn. Xem lại từng trình điều khiển và cố gắng thực hiện
bất kỳ sự phụ thuộc nào vào CONFIG_FB_DEVICE là tùy chọn. Ở mức tối thiểu, tương ứng
mã trong trình điều khiển có thể được điều kiện hóa thông qua ifdef CONFIG_FB_DEVICE. Không
tất cả các trình điều khiển có thể bỏ CONFIG_FB_DEVICE.

Liên hệ: Thomas Zimmermann <tzimmermann@suse.de>

Cấp độ: Người mới bắt đầu

Loại bỏ việc vô hiệu hóa/không chuẩn bị trong việc loại bỏ/tắt máy trong panel-simple và panel-edp
--------------------------------------------------------------------------------------------------

Kể từ cam kết d2aacaf07395 ("drm/panel: Kiểm tra xem đã được chuẩn bị/bật trong
drm_panel"), chúng tôi sẽ kiểm tra lõi drm_panel để đảm bảo không ai
cuộc gọi kép chuẩn bị/bật/tắt/không chuẩn bị. Cuối cùng điều đó có lẽ nên
được biến thành WARN_ON() hoặc bằng cách nào đó được làm to hơn.

Hiện tại, chúng tôi cho rằng chúng tôi vẫn có thể gặp phải các cảnh báo trong
lõi drm_panel khi sử dụng panel-simple và panel-edp. Vì những tấm bảng đó
trình điều khiển được sử dụng với rất nhiều trình điều khiển chế độ DRM khác nhau mà họ vẫn
nỗ lực thêm để vô hiệu hóa/hủy chuẩn bị bảng điều khiển khi tắt máy
thời gian. Cụ thể là chúng tôi vẫn có thể gặp phải những cảnh báo đó nếu bảng điều khiển
trình điều khiển bị tắt máy() _trước_ trình điều khiển bộ chế độ DRM và bộ chế độ DRM
trình điều khiển gọi đúng drm_atomic_helper_shutdown() khi tắt máy của chính nó()
gọi lại. Cảnh báo có thể tránh được trong trường hợp như vậy bằng cách sử dụng cái gì đó như
liên kết thiết bị để đảm bảo rằng bảng điều khiển sẽ tắt() sau khi cài đặt chế độ DRM
người lái xe.

Khi tất cả các trình điều khiển chế độ DRM được biết là đã tắt đúng cách, phần bổ sung
lệnh gọi để tắt/không chuẩn bị xóa/tắt máy trong panel-simple và panel-edp
nên được loại bỏ và mục TODO này được đánh dấu là hoàn thành.

Liên hệ: Douglas Anderson <dianders@chromium.org>

Trình độ: Trung cấp

Chuyển đổi khỏi sử dụng các hàm MIPI DSI không được dùng nữa
------------------------------------------------------------

Có nhiều hàm được định nghĩa trong ZZ0000ZZ đã được
không được dùng nữa. Mỗi chức năng không được dùng nữa đều không được dùng nữa để thay thế cho ZZ0001ZZ của nó
biến thể (ví dụ ZZ0002ZZ và ZZ0003ZZ).
Biến thể ZZ0004ZZ của một chức năng bao gồm việc xử lý lỗi và logic được cải thiện
điều này làm cho việc thực hiện nhiều cuộc gọi liên tiếp trở nên thuận tiện hơn, vì hầu hết MIPI
trình điều khiển làm.

Trình điều khiển cần được cập nhật để sử dụng các chức năng không được dùng nữa. Một khi tất cả các cách sử dụng của
Các hàm MIPI DSI không được dùng nữa đã bị xóa, định nghĩa của chúng có thể là
đã bị xóa khỏi ZZ0000ZZ.

Liên hệ: Douglas Anderson <dianders@chromium.org>

Cấp độ: Người mới bắt đầu

Xóa devm_drm_put_bridge()
----------------------------

Do cách cầu bảng điều khiển xử lý thời gian tồn tại của đối tượng drm_bridge, đặc biệt
phải cẩn thận để loại bỏ đối tượng drm_bridge khi
panel_bridge bị xóa. Điều này hiện được quản lý bằng cách sử dụng
devm_drm_put_bridge(), nhưng đó là giải pháp tạm thời, không an toàn. Để sửa chữa
rằng tuổi thọ của bảng điều khiển DRM cần phải được làm lại. Sau khi làm lại là
xong, hãy xóa devm_drm_put_bridge() và TODO trong
drm_panel_bridge_remove().

Liên hệ: Maxime Ripard <mripard@kernel.org>,
         Luca Ceresoli <luca.ceresoli@bootlin.com>

Trình độ: Trung cấp

Chuyển đổi người dùng of_drm_find_bridge() thành of_drm_find_and_get_bridge()
-----------------------------------------------------------------------------

Lấy một con trỏ struct drm_bridge yêu cầu lấy một tham chiếu và đặt
nó sau khi loại bỏ con trỏ. Hầu hết các hàm đều trả về một cấu trúc
Con trỏ drm_bridge đã gọi drm_bridge_get() để tăng số tiền hoàn lại
và người dùng của họ đã được cập nhật để gọi drm_bridge_put() khi
thích hợp. of_drm_find_bridge() không nhận được tài liệu tham khảo và nó đã được
không được dùng nữa để ủng hộ of_drm_find_and_get_bridge(), nhưng một số
người dùng vẫn cần phải được chuyển đổi.

Liên hệ: Maxime Ripard <mripard@kernel.org>,
         Luca Ceresoli <luca.ceresoli@bootlin.com>

Trình độ: Trung cấp

Tái cấu trúc cốt lõi
====================

Làm cho việc xử lý hoảng loạn có hiệu quả
-----------------------------------------

Đây là một nhiệm vụ thực sự đa dạng với rất nhiều chi tiết nhỏ:

* Hiện tại không thể kiểm tra đường dẫn hoảng loạn, dẫn đến liên tục bị đứt. các
  vấn đề chính ở đây là sự hoảng loạn có thể được kích hoạt từ bối cảnh khó khăn và
  do đó tất cả các cuộc gọi lại liên quan đến hoảng loạn có thể chạy trong ngữ cảnh hardirq. Nó sẽ là
  thật tuyệt nếu chúng ta có thể kiểm tra ít nhất mã trợ giúp và mã trình điều khiển fbdev bằng cách
  ví dụ: kích hoạt cuộc gọi thông qua các tập tin debugfs drm. bối cảnh hardirq có thể là
  đạt được bằng cách sử dụng IPI cho bộ xử lý cục bộ.

* Có sự nhầm lẫn lớn giữa các phương pháp xử lý cơn hoảng loạn khác nhau. Mô phỏng fbdev DRM
  những người trợ giúp đã có mã riêng của họ (đã bị xóa từ lâu), nhưng trên hết là chính mã fbcon
  cũng có một cái. Chúng ta cần đảm bảo rằng họ ngừng tranh giành nhau.
  Điều này được giải quyết bằng cách kiểm tra ZZ0000ZZ tại các điểm vào khác nhau
  vào trình trợ giúp mô phỏng DRM fbdev. Một cách tiếp cận rõ ràng hơn nhiều ở đây sẽ là
  chuyển fbcon sang ZZ0001ZZ.

* ZZ0000ZZ là một mớ hỗn độn. Nó che giấu các lỗi thực sự trong hoạt động bình thường và
  không phải là giải pháp đầy đủ cho những con đường hoảng loạn. Chúng ta cần đảm bảo rằng nó chỉ
  trả về true nếu có sự hoảng loạn thực sự xảy ra và khắc phục tất cả
  bụi phóng xạ.

* Người xử lý cơn hoảng loạn không bao giờ được ngủ, điều đó cũng có nghĩa là người đó không bao giờ được ngủ
  ZZ0000ZZ. Ngoài ra, nó không thể lấy bất kỳ khóa nào khác một cách vô điều kiện, không
  thậm chí cả spinlocks (vì NMI và hardirq cũng có thể hoảng sợ). Chúng ta cần phải
  đảm bảo không gọi những đường dẫn như vậy hoặc thử khóa mọi thứ. Thực sự khó khăn.

* Một giải pháp rõ ràng sẽ là hỗ trợ đầu ra hoảng loạn hoàn toàn riêng biệt trong KMS,
  bỏ qua sự hỗ trợ fbcon hiện tại. Xem ZZ0000ZZ.

* Mã hóa các lỗi thực tế và dmesg trước đó trong QR có thể giúp ích cho
  vấn đề đáng sợ "những thứ quan trọng bị cuộn đi". Xem ZZ0000ZZ
  để biết một số mã ví dụ có thể được sử dụng lại.

Liên hệ: Simona Vetter

Cấp độ: Nâng cao

Dọn dẹp hỗ trợ debugfs
----------------------------

Có một loạt vấn đề với nó:

- Chuyển đổi trình điều khiển để hỗ trợ chức năng drm_debugfs_add_files() thay vì
  hàm drm_debugfs_create_files().

- Cải thiện các lỗi đăng ký muộn bằng cách triển khai các lỗi đăng ký trước tương tự
  cơ sở hạ tầng cho kết nối và crtc nữa. Bằng cách đó, người lái xe sẽ không cần phải
  chia mã thiết lập của họ thành init và đăng ký nữa.

- Có lẽ chúng tôi muốn có một số hỗ trợ cho các tệp debugfs trên crtc/trình kết nối và
  có thể các đối tượng km khác trực tiếp trong lõi. Thậm chí còn có hỗ trợ drm_print trong
  các chức năng để các đối tượng này chuyển trạng thái km, vì vậy tất cả đều ở đó. Và sau đó
  Các hàm ->show() rõ ràng sẽ cung cấp cho bạn một con trỏ tới đúng đối tượng.

- Các hook drm_driver->debugfs_init mà chúng ta có chỉ là một tạo tác của cái cũ
  trình tự tải lớp giữa. Các bản gỡ lỗi DRM sẽ hoạt động giống như các sysf hơn, nơi bạn
  có thể tạo các thuộc tính/tệp cho một đối tượng bất cứ lúc nào bạn muốn và cốt lõi
  đảm nhiệm việc xuất bản/hủy xuất bản tất cả các tệp khi đăng ký/hủy đăng ký
  thời gian. Người lái xe không cần phải lo lắng về những kỹ thuật này và việc sửa chữa
  điều này (cùng với di chuyển drm_minor->drm_device) sẽ cho phép chúng tôi xóa
  debugfs_init.

Liên hệ: Simona Vetter

Trình độ: Trung cấp

Sửa lỗi trọn đời của đối tượng
------------------------------

Có hai vấn đề liên quan ở đây

- Dọn dẹp các lệnh gọi lại khác nhau -> hủy các lệnh gọi lại, thường giống nhau
  mã đơn giản.

- Rất nhiều trình điều khiển phân bổ sai đối tượng chế độ DRM bằng cách sử dụng devm_kzalloc,
  dẫn đến các vấn đề miễn phí sau khi sử dụng khi dỡ trình điều khiển. Điều này có thể nghiêm trọng
  rắc rối ngay cả đối với trình điều khiển cho phần cứng được tích hợp trên SoC do
  Sự lùi lại của EPROBE_DEFERRED.

Cả hai vấn đề này đều có thể được giải quyết bằng cách chuyển sang drmm_kzalloc() và
nhiều loại giấy gói tiện lợi khác nhau được cung cấp, ví dụ: drmm_crtc_alloc_with_planes(),
drmm_universal_plane_alloc(), ..., v.v.

Liên hệ: Simona Vetter

Trình độ: Trung cấp

Xóa ánh xạ trang tự động khỏi quá trình nhập dma-buf
----------------------------------------------------

Khi nhập dma-buf, khung dma-buf và PRIME sẽ tự động ánh xạ
các trang đã nhập vào khu vực DMA của nhà nhập khẩu. drm_gem_prime_fd_to_handle() và
drm_gem_prime_handle_to_fd() yêu cầu nhà nhập khẩu gọi dma_buf_attach()
ngay cả khi họ không bao giờ thực hiện DMA trên thiết bị thực tế mà chỉ truy cập CPU thông qua
dma_buf_vmap(). Đây là sự cố đối với các thiết bị USB không hỗ trợ DMA
hoạt động.

Để khắc phục sự cố, nên xóa ánh xạ trang tự động khỏi
mã chia sẻ bộ đệm. Việc sửa lỗi này phức tạp hơn một chút, vì quá trình nhập/xuất
bộ đệm cũng được liên kết với &drm_gem_object.import_attach. Trong khi đó chúng tôi viết lại
vấn đề này đối với các thiết bị USB bằng cách sử dụng thiết bị điều khiển máy chủ USB, như
miễn là nó hỗ trợ DMA. Nếu không, việc nhập vẫn có thể thất bại.

Liên hệ: Thomas Zimmermann <tzimmermann@suse.de>, Simona Vetter

Cấp độ: Nâng cao

Triển khai ioctl DUMB_CREATE2 mới
----------------------------------

DUMB_CREATE ioctl hiện tại chưa được xác định rõ. Thay vì một pixel và
định dạng bộ đệm khung, nó chỉ chấp nhận chế độ màu có ngữ nghĩa mơ hồ. Giả sử
bộ đệm khung tuyến tính, chế độ màu đưa ra ý tưởng về pixel được hỗ trợ
định dạng. Nhưng không gian người dùng phải đoán các giá trị chính xác một cách hiệu quả. Nó thực sự
chỉ hoạt động đáng tin cậy với bộ đệm khung trong XRGB8888. Không gian người dùng đã bắt đầu
khắc phục những hạn chế này bằng cách tính toán kích thước bộ đệm của định dạng tùy ý và
tính toán kích thước của chúng theo pixel XRGB8888.

Một giải pháp khả thi là ioctl DUMB_CREATE2 mới. Nó sẽ chấp nhận DRM
định dạng và công cụ sửa đổi định dạng để giải quyết sự mơ hồ của chế độ màu. Như
bộ đệm khung có thể là nhiều mặt phẳng, ioctl mới phải trả về kích thước bộ đệm,
cao độ và tay cầm GEM cho từng mặt phẳng màu riêng lẻ.

Trong bước đầu tiên, ioctl mới có thể bị giới hạn ở các tính năng hiện tại của
DUMB_CREATE hiện có. Trình điều khiển riêng lẻ sau đó có thể được mở rộng để hỗ trợ
định dạng đa mặt phẳng. Rockchip có thể yêu cầu điều này và sẽ là một ứng cử viên sáng giá.

Nó cũng có thể hữu ích cho không gian người dùng khi truy vấn thông tin về kích thước của
một bộ đệm tiềm năng, nếu được phân bổ. Không gian người dùng sẽ cung cấp hình học và định dạng;
hạt nhân sẽ trả về kích thước phân bổ tối thiểu và độ cao của dòng quét. có
quan tâm đến việc phân bổ bộ nhớ đó từ một thiết bị khác và cung cấp nó cho
Trình điều khiển DRM (nói qua dma-buf).

Một tính năng được yêu cầu khác là khả năng phân bổ bộ đệm theo kích thước mà không cần
định dạng. Máy gia tốc sử dụng điều này để phân bổ bộ đệm và có thể
khái quát hóa.

Ngoài việc triển khai kernel, phải có hỗ trợ không gian người dùng
cho ioctl mới. Có mã ở Mesa có thể sử dụng được cái mới
gọi.

Liên hệ: Thomas Zimmermann <tzimmermann@suse.de>

Cấp độ: Nâng cao

Kiểm tra tốt hơn
================

Thêm các bài kiểm tra đơn vị bằng cách sử dụng khung Kiểm tra đơn vị hạt nhân (KUnit)
-------------------------------------------------------------------------------------

ZZ0000ZZ
cung cấp một khuôn khổ chung cho các bài kiểm tra đơn vị trong nhân Linux. Có một
bộ thử nghiệm sẽ cho phép xác định hồi quy sớm hơn.

Một ứng cử viên sáng giá cho các bài kiểm tra đơn vị đầu tiên là những người trợ giúp chuyển đổi định dạng trong
ZZ0000ZZ.

Liên hệ: Javier Martinez Canillas <javierm@redhat.com>

Trình độ: Trung cấp

Dọn dẹp và ghi lại các bộ selftests cũ
---------------------------------------------

Một số bộ thử nghiệm KUnit (drm_buddy, drm_cmdline_parser, drm_damage_helper,
drm_format, drm_framebuffer, drm_dp_mst_helper, drm_mm, drm_plane_helper và
drm_ect) là các bộ phần mềm tự kiểm tra trước đây đã được chuyển đổi khi KUnit
lần đầu tiên được giới thiệu.

Những dãy phòng này khá không có giấy tờ và có mục tiêu khác với đơn vị nào
các bài kiểm tra có thể được. Cố gắng xác định những gì mỗi bài kiểm tra trong các bộ này thực sự kiểm tra
cho dù điều đó có hợp lý đối với một bài kiểm tra đơn vị hay không và loại bỏ nó nếu nó
không hoặc ghi lại nó nếu có sẽ giúp ích rất nhiều.

Liên hệ: Maxime Ripard <mripard@kernel.org>

Trình độ: Trung cấp

Kích hoạt bộ ba cho DRM
-----------------------

Và khắc phục hậu quả. Chắc hẳn sẽ rất thú vị...

Cấp độ: Nâng cao

Thực hiện các bài kiểm tra KMS bằng i-g-t chung
-----------------------------------------------

Nhóm trình điều khiển i915 duy trì một bộ thử nghiệm mở rộng cho trình điều khiển i915 DRM,
bao gồm hàng tấn trường hợp thử nghiệm cho các trường hợp góc trong cài đặt chế độ API. Nó sẽ
thật tuyệt vời nếu những thử nghiệm đó (ít nhất là những thử nghiệm không dựa trên GEM dành riêng cho Intel
tính năng) có thể được tạo để chạy trên bất kỳ trình điều khiển KMS nào.

Công việc cơ bản để chạy thử nghiệm i-g-t trên không phải i915 đã hoàn tất, điều còn thiếu là hàng loạt-
chuyển đổi mọi thứ. Đối với các bài kiểm tra modeset, trước tiên chúng ta cũng cần một chút
cơ sở hạ tầng để sử dụng bộ đệm câm cho bộ đệm chưa được xử lý, để có thể chạy tất cả
các bài kiểm tra chế độ cụ thể không phải i915.

Cấp độ: Nâng cao

Mở rộng trình điều khiển thử nghiệm ảo (VKMS)
---------------------------------------------

Xem tài liệu của ZZ0000ZZ để biết thêm chi tiết. Đây là một lý tưởng
nhiệm vụ thực tập vì nó chỉ yêu cầu một máy ảo và có thể có kích thước phù hợp
phù hợp với thời gian sẵn có.

Cấp độ: Xem chi tiết

Tái cấu trúc đèn nền
---------------------

Trình điều khiển đèn nền có trạng thái bật/tắt ba lần, hơi quá mức cần thiết.
Lên kế hoạch khắc phục điều này:

1. Triển khai các trình trợ giúp đèn nền_enable() và đèn nền_disable() ở khắp mọi nơi. Cái này
   đã bắt đầu rồi.
2. Nói chung, chỉ nhìn vào một trong ba bit trạng thái được thiết lập bởi những người trợ giúp ở trên.
3. Loại bỏ hai bit trạng thái còn lại.

Liên hệ: Simona Vetter

Trình độ: Trung cấp

Trình điều khiển cụ thể
=======================

Trình điều khiển màn hình DC AMD
--------------------------------

AMD DC là trình điều khiển hiển thị cho các thiết bị AMD bắt đầu từ Vega. Đã có
có rất nhiều tiến bộ trong việc dọn dẹp nó nhưng vẫn còn rất nhiều việc phải làm.

Xem trình điều khiển/gpu/drm/AMD/display/TODO để biết các tác vụ.

Liên hệ: Harry Wentland, Alex Deucher

Khởi động
==========

Hiện tại đã có hỗ trợ để viết ứng dụng khách DRM nội bộ.
có thể lấy lại tác phẩm khởi động đã bị từ chối vì nó được viết
cho fbdev.

- [v6,8/8] drm/client: Hack: Thêm ví dụ về bootsplash
  ZZ0000ZZ

- [RFC PATCH v2 00/13] Bootsplash dựa trên hạt nhân
  ZZ0000ZZ

Liên hệ: Sam Ravnborg

Cấp độ: Nâng cao

Xử lý độ sáng trên các thiết bị có nhiều bảng bên trong
============================================================

Trên các thiết bị x86/ACPI có thể có nhiều giao diện chương trình cơ sở đèn nền:
(ACPI), video cụ thể của nhà cung cấp và các video khác. Cũng như trực tiếp/gốc (PWM)
đăng ký lập trình bằng trình điều khiển KMS.

Để xử lý trình điều khiển đèn nền này được sử dụng trong lệnh gọi x86/ACPI
acpi_video_get_backlight_type() có phương pháp phỏng đoán (+quirks) để chọn
nên sử dụng giao diện đèn nền nào; và trình điều khiển đèn nền không khớp
kiểu được trả về sẽ không tự đăng ký nên chỉ có một đèn nền
thiết bị được đăng ký (trong một thiết lập GPU duy nhất, xem bên dưới).

Hiện tại, điều này ít nhiều giả định rằng sẽ chỉ có
là 1 bảng điều khiển (nội bộ) trên một hệ thống.

Trên các hệ thống có 2 bảng điều này có thể là một vấn đề, tùy thuộc vào
giao diện nào acpi_video_get_backlight_type() chọn:

1. gốc: trong trường hợp này, trình điều khiển KMS phải biết đèn nền nào
   thiết bị thuộc về đầu ra nào nên mọi thứ sẽ hoạt động bình thường.
2. video: điều này không hỗ trợ kiểm soát nhiều đèn nền, nhưng một số hoạt động
   sẽ cần phải được thực hiện để có được ánh xạ thiết bị đèn nền <-> đầu ra

Ở trên giả định cả hai bảng sẽ yêu cầu loại giao diện đèn nền giống nhau.
Mọi thứ sẽ bị hỏng trên các hệ thống có nhiều bảng mà cần có 2 bảng
một kiểu điều khiển khác. Ví dụ. một bảng điều khiển cần điều khiển đèn nền video ACPI,
trong khi cái kia đang sử dụng điều khiển đèn nền gốc. Hiện tại trong trường hợp này
chỉ một trong 2 thiết bị đèn nền bắt buộc sẽ được đăng ký, dựa trên
giá trị trả về acpi_video_get_backlight_type().

Nếu trường hợp (lý thuyết) này xuất hiện thì việc hỗ trợ này sẽ cần một số
làm việc. Một giải pháp khả thi ở đây là chuyển tên thiết bị và trình kết nối
vào acpi_video_get_backlight_type() để nó có thể giải quyết vấn đề này.

Lưu ý theo cách chúng tôi đã gặp trường hợp không gian người dùng nhìn thấy 2 bảng,
trong các thiết lập máy tính xách tay GPU kép có mux. Trên những hệ thống đó chúng ta có thể thấy
2 thiết bị đèn nền gốc; hoặc 2 thiết bị đèn nền gốc.

Không gian người dùng đã có mã để giải quyết vấn đề này bằng cách phát hiện xem liệu có liên quan hay không
bảng điều khiển đang hoạt động (iow cách mux giữa GPU và các bảng
điểm) và sau đó sử dụng thiết bị đèn nền đó. Không gian người dùng ở đây rất nhiều
mặc dù giả định một bảng điều khiển duy nhất. Nó chỉ chọn 1 trong 2 thiết bị đèn nền
và sau đó chỉ sử dụng cái đó.

Lưu ý rằng tất cả mã không gian người dùng (mà tôi biết) hiện được mã hóa cứng
để giả định một bảng điều khiển duy nhất.

Trước những thay đổi gần đây về việc không đăng ký nhiều (ví dụ: video + bản gốc)
/sys/class/thiết bị đèn nền cho một bảng điều khiển (trên một máy tính xách tay GPU),
không gian người dùng sẽ thấy nhiều thiết bị có đèn nền đều điều khiển giống nhau
đèn nền.

Để xử lý không gian người dùng này, bạn phải luôn chọn một thiết bị ưa thích trong
/sys/class/backlight và sẽ bỏ qua những cái khác. Vì vậy để hỗ trợ độ sáng
kiểm soát trên nhiều bảng không gian người dùng cũng sẽ cần được cập nhật.

Có kế hoạch cho phép kiểm soát độ sáng thông qua KMS API bằng cách thêm
thuộc tính "độ sáng màn hình" cho các đối tượng drm_connector cho bảng điều khiển. Cái này
giải quyết một số vấn đề với /sys/class/backlight API, bao gồm cả không
có thể ánh xạ thiết bị đèn nền sysfs tới một đầu nối cụ thể. bất kỳ
thay đổi không gian người dùng để thêm hỗ trợ kiểm soát độ sáng trên các thiết bị có
nhiều bảng thực sự nên được xây dựng dựa trên thuộc tính KMS mới này.

Liên hệ: Hans de Goede

Cấp độ: Nâng cao

Tuổi bộ đệm hoặc thuật toán tích lũy thiệt hại khác đối với hư hỏng bộ đệm
==========================================================================

Các trình điều khiển thực hiện tải lên trên mỗi bộ đệm cần xử lý hư hỏng bộ đệm (thay vì
hư hỏng khung hình giống như trình điều khiển thực hiện tải lên trên mỗi mặt phẳng hoặc trên mỗi CRTC), nhưng có
không hỗ trợ lấy tuổi đệm hoặc bất kỳ thuật toán tích lũy thiệt hại nào khác.

Vì lý do này, những người trợ giúp thiệt hại chỉ chuyển sang bản cập nhật mặt phẳng đầy đủ nếu
bộ đệm khung gắn vào một mặt phẳng đã thay đổi kể từ lần lật trang cuối cùng. Trình điều khiển
đặt &drm_plane_state.ignore_damage_clips thành true làm dấu hiệu cho
drm_atomic_helper_damage_iter_init() và drm_atomic_helper_damage_iter_next()
những người trợ giúp rằng các clip hư hỏng nên được bỏ qua.

Điều này cần được cải thiện để tính năng theo dõi hư hỏng hoạt động chính xác trên các trình điều khiển
thực hiện tải lên trên mỗi bộ đệm.

Thông tin thêm về việc theo dõi thiệt hại và tài liệu tham khảo về tài liệu học tập có thể
được tìm thấy trong ZZ0000ZZ.

Liên hệ: Javier Martinez Canillas <javierm@redhat.com>

Cấp độ: Nâng cao

Lỗi truy vấn từ drm_syncobj
================================

Bộ chứa drm_syncobj có thể được sử dụng bởi mã độc lập của trình điều khiển để báo hiệu
hoàn tất việc nộp hồ sơ.

Một tính năng nhỏ vẫn còn thiếu là DRM IOCTL chung để truy vấn lỗi
trạng thái của nhị phân và dòng thời gian drm_syncobj.

Điều này có lẽ nên được cải thiện bằng cách triển khai giao diện kernel cần thiết
và thêm hỗ trợ cho điều đó trong ngăn xếp không gian người dùng.

Liên hệ: Christian König

Cấp độ: Người mới bắt đầu

Trình lập lịch DRM GPU
======================

Cung cấp giải pháp kế thừa phổ quát cho drm_sched_resubmit_jobs()
-----------------------------------------------------------------

drm_sched_resubmit_jobs() không được dùng nữa. Nguyên nhân chính là nó dẫn đến
đang khởi tạo lại dma_fences. Xem tài liệu của chức năng đó để biết chi tiết. Càng tốt
cách tiếp cận để gửi lại hợp lệ bởi amdgpu và Xe (rõ ràng) là để tìm ra
công việc nào (và, thông qua liên kết: thực thể nào) đã gây ra tình trạng treo máy. Sau đó,
dữ liệu bộ đệm của công việc, cùng với tất cả dữ liệu bộ đệm của công việc khác hiện có trong
vòng phần cứng giống nhau, phải bị vô hiệu. Ví dụ, điều này có thể được thực hiện bởi
ghi đè lên nó. amdgpu hiện đang xác định công việc nào đang được thực hiện và cần
được ghi đè bằng cách giữ các bản sao của công việc. Xe có được thông tin đó bằng cách
truy cập trực tiếp vào danh sách đang chờ xử lý của drm_sched.

Nhiệm vụ:

1. triển khai chức năng lập lịch trình mà qua đó người lái xe có thể nhận được
   thông tin về các công việc ZZ0000ZZ hiện đang có trong vòng phần cứng.
2. Cơ sở hạ tầng như vậy thường sẽ được sử dụng trong
   drm_sched_backend_ops.timedout_job(). Tài liệu đó.
3. Chuyển trình điều khiển làm người dùng đầu tiên.
4. Ghi lại giải pháp thay thế mới vào tài liệu không được dùng nữa
   drm_sched_resubmit_jobs().

Liên hệ: Christian König <christian.koenig@amd.com>
         Philipp Stanner <phasta@kernel.org>

Cấp độ: Nâng cao

Thêm khóa cho runqueues
-------------------------

Có một FIXME cũ của Sima trong include/drm/gpu_scheduler.h. Nó chi tiết rằng
struct drm_sched_rq được đọc ở nhiều nơi mà không có bất kỳ khóa nào, thậm chí không có
READ_ONCE. Tại XDC 2025 không ai có thể thực sự biết tại sao lại như vậy, liệu
khóa là cần thiết và liệu chúng có thể được thêm vào hay không. (Nhưng thực tế thì điều đó nên
có lẽ đã bị khóa!). Kiểm tra xem có thể thêm khóa ở mọi nơi không và
làm như vậy nếu có.

Liên hệ: Philipp Stanner <phasta@kernel.org>

Trình độ: Trung cấp

Bên ngoài DRM
=============

Chuyển đổi trình điều khiển fbdev sang DRM
------------------------------------------

Có rất nhiều trình điều khiển fbdev cho phần cứng cũ hơn. Một số phần cứng có
trở nên lỗi thời, nhưng một số vẫn cung cấp bộ đệm khung tốt (-đủ). các
trình điều khiển vẫn hữu ích nên được chuyển đổi sang DRM và sau đó
đã bị xóa khỏi fbdev.

Trình điều khiển fbdev rất đơn giản có thể được chuyển đổi tốt nhất bằng cách bắt đầu bằng một trình điều khiển mới
Trình điều khiển DRM. Những người trợ giúp KMS đơn giản và SHMEM sẽ có thể xử lý mọi vấn đề
phần cứng hiện có. Các chức năng gọi lại của trình điều khiển mới được điền từ
mã fbdev hiện có.

Trình điều khiển fbdev phức tạp hơn có thể được tái cấu trúc từng bước thành DRM
driver với sự trợ giúp của người trợ giúp fbconv DRM [4]_. Những người trợ giúp này cung cấp
lớp chuyển tiếp giữa cơ sở hạ tầng lõi DRM và fbdev
giao diện điều khiển. Tạo trình điều khiển DRM mới bên cạnh trình trợ giúp fbconv,
sao chép trình điều khiển fbdev và nối nó với mã DRM. Ví dụ cho
một số trình điều khiển fbdev có sẵn trong cây fbconv của Thomas Zimmermann
[4]_, cũng như hướng dẫn về quy trình này [5]_. Kết quả là một nguyên thủy
Trình điều khiển DRM có thể chạy X11 và Weston.

 .. [4] https://gitlab.freedesktop.org/tzimmermann/linux/tree/fbconv
 .. [5] https://gitlab.freedesktop.org/tzimmermann/linux/blob/fbconv/drivers/gpu/drm/drm_fbconv_helper.c

Liên hệ: Thomas Zimmermann <tzimmermann@suse.de>

Cấp độ: Nâng cao
