.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/drm-uapi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright 2020 DisplayLink (UK) Ltd.

=====================
Giao diện người dùng
=====================

Nói chung, lõi DRM xuất một số giao diện cho các ứng dụng
dự định sẽ được sử dụng thông qua các hàm bao bọc libdrm tương ứng. trong
Ngoài ra, trình điều khiển còn xuất giao diện dành riêng cho thiết bị để không gian người dùng sử dụng
trình điều khiển và ứng dụng nhận biết thiết bị thông qua các tệp ioctls và sysfs.

Các giao diện bên ngoài bao gồm: ánh xạ bộ nhớ, quản lý ngữ cảnh, DMA
hoạt động, quản lý AGP, điều khiển vblank, quản lý hàng rào, bộ nhớ
quản lý, quản lý đầu ra.

Trình bày bố cục ioctls và sysfs chung ở đây. Chúng tôi chỉ cần cấp độ cao
info, vì trang man sẽ bao gồm phần còn lại.

Tra cứu thiết bị libdrm
=======================

.. kernel-doc:: drivers/gpu/drm/drm_ioctl.c
   :doc: getunique and setversion story


.. _drm_primary_node:

Các nút chính, DRM Master và xác thực
============================================

.. kernel-doc:: drivers/gpu/drm/drm_auth.c
   :doc: master and authentication

.. kernel-doc:: drivers/gpu/drm/drm_auth.c
   :export:

.. kernel-doc:: include/drm/drm_auth.h
   :internal:


.. _drm_leasing:

Cho thuê tài nguyên hiển thị DRM
================================

.. kernel-doc:: drivers/gpu/drm/drm_lease.c
   :doc: drm leasing

Yêu cầu về không gian người dùng nguồn mở
=========================================

Hệ thống con DRM có yêu cầu khắt khe hơn hầu hết các hệ thống con kernel khác trên
phía không gian người dùng của uAPI mới cần trông như thế nào. Phần này ở đây
giải thích chính xác những yêu cầu đó là gì và tại sao chúng tồn tại.

Tóm tắt ngắn gọn là bất kỳ sự bổ sung nào của DRM uAPI đều yêu cầu
các bản vá không gian người dùng có nguồn mở và các bản vá đó phải được xem xét và sẵn sàng cho
sáp nhập vào một dự án thượng nguồn phù hợp và chuẩn mực.

Các thiết bị GFX (cả hiển thị và kết xuất/phía GPU) thực sự là những phần phức tạp của
phần cứng, với không gian người dùng và kernel do cần phải làm việc thực sự cùng nhau
chặt chẽ.  Các giao diện để hiển thị và cài đặt chế độ phải cực kỳ rộng
và linh hoạt, do đó hầu như không thể xác định chính xác
chúng cho mọi trường hợp góc có thể xảy ra. Điều này lần lượt làm cho nó thực sự thiết thực
không thể phân biệt giữa hành vi được yêu cầu bởi không gian người dùng và
không được thay đổi để tránh sự thụt lùi, và hành vi chỉ là một
tạo tác ngẫu nhiên của việc thực hiện hiện tại.

Không có quyền truy cập vào mã nguồn đầy đủ của tất cả người dùng không gian người dùng, điều đó có nghĩa là nó
không thể thay đổi chi tiết triển khai vì không gian người dùng có thể
phụ thuộc vào hành vi ngẫu nhiên của việc triển khai hiện tại tính bằng phút
chi tiết. Và việc gỡ lỗi các hồi quy như vậy mà không cần truy cập vào mã nguồn là khá tốt
nhiều điều không thể. Kết quả là điều này có nghĩa là:

- Chính sách "không hồi quy" của nhân Linux chỉ áp dụng trong thực tế cho
  không gian người dùng nguồn mở của hệ thống con DRM. Các nhà phát triển DRM hoàn toàn ổn
  nếu trình điều khiển blob nguồn đóng trong không gian người dùng sử dụng cùng uAPI như trình điều khiển mở
  trình điều khiển, nhưng chúng phải thực hiện theo cách giống hệt như các trình điều khiển đang mở.
  Việc sử dụng (ab) sáng tạo các giao diện sẽ và trước đây thường xuyên dẫn đến
  để vỡ.

- Bất kỳ giao diện không gian người dùng mới nào cũng phải có triển khai nguồn mở như
  xe trình diễn.

Lý do khác để yêu cầu không gian người dùng nguồn mở là việc xem xét uAPI. Kể từ khi
các phần kernel và không gian người dùng của ngăn xếp GFX phải phối hợp chặt chẽ với nhau, mã
đánh giá chỉ có thể đánh giá liệu một giao diện mới có đạt được mục tiêu hay không bằng cách xem xét
cả hai bên. Đảm bảo rằng giao diện thực sự bao gồm đầy đủ trường hợp sử dụng
dẫn đến một số yêu cầu bổ sung:

- Không gian người dùng nguồn mở không được là một ứng dụng đồ chơi/thử nghiệm mà là không gian thực
  thứ. Cụ thể là nó cần xử lý tất cả các trường hợp lỗi và góc thông thường.
  Đây thường là những nơi uAPI mới bị hỏng và do đó cần thiết cho
  đánh giá sự phù hợp của giao diện được đề xuất.

- Phía không gian người dùng phải được xem xét và kiểm tra đầy đủ theo các tiêu chuẩn của vùng đó
  dự án không gian người dùng. Ví dụ: mesa điều này có nghĩa là các trường hợp thử nghiệm piglit và đánh giá trên
  danh sách gửi thư. Điều này một lần nữa nhằm đảm bảo rằng giao diện mới thực sự có được
  công việc đã xong.  Người đánh giá phía không gian người dùng cũng phải cung cấp Acked-by trên
  bản vá uAPI kernel cho biết rằng họ tin rằng uAPI được đề xuất là hợp lý và
  được ghi chép và xác nhận đầy đủ cho việc sử dụng không gian người dùng.

- Các bản vá không gian người dùng phải chống lại quy chuẩn ngược dòng chứ không phải nhà cung cấp nào đó
  cái nĩa. Điều này nhằm đảm bảo rằng không ai gian lận trong quá trình đánh giá và kiểm tra
  yêu cầu bằng cách thực hiện một ngã ba nhanh chóng.

- Bản vá kernel chỉ có thể được hợp nhất sau khi đáp ứng tất cả các yêu cầu trên,
  nhưng ZZ0000ZZ được hợp nhất thành drm-next hoặc drm-misc-next ZZ0001ZZ
  đất vá không gian người dùng. uAPI luôn chảy từ kernel, thực hiện mọi việc
  cách khác có nguy cơ dẫn đến sự khác biệt giữa các định nghĩa và tệp tiêu đề uAPI.

Đây là những yêu cầu khá cao nhưng đã phát triển sau nhiều năm chia sẻ
nỗi đau và trải nghiệm với uAPI được thêm vào một cách vội vàng và hầu như luôn hối hận về
nhanh như vậy. Các thiết bị GFX thay đổi rất nhanh, đòi hỏi phải thay đổi mô hình và
toàn bộ bộ giao diện uAPI mới ít nhất vài năm một lần. Cùng với
Sự đảm bảo của nhân Linux sẽ duy trì không gian người dùng hiện tại hoạt động trong hơn 10 năm
vốn đã khá khó khăn đối với hệ thống con DRM, với nhiều uAPI khác nhau
cho cùng một điều cùng tồn tại. Nếu chúng ta thêm một vài lỗi hoàn chỉnh vào
trộn mỗi năm nó sẽ hoàn toàn không thể quản lý được.

.. _drm_render_node:

Kết xuất các nút
================

Lõi DRM cung cấp nhiều thiết bị ký tự cho không gian người dùng sử dụng.
Tùy thuộc vào thiết bị nào được mở, không gian người dùng có thể thực hiện các thao tác khác nhau
tập hợp các hoạt động (chủ yếu là ioctls). Nút chính luôn được tạo
và được gọi là thẻ<num>. Ngoài ra, nút điều khiển hiện không được sử dụng,
được gọi là controlD<num> cũng được tạo. Nút chính cung cấp tất cả
hoạt động kế thừa và về mặt lịch sử là giao diện duy nhất được sử dụng bởi
không gian người dùng. Với KMS, nút điều khiển đã được giới thiệu. Tuy nhiên,
giao diện điều khiển KMS theo kế hoạch chưa bao giờ được viết và do đó, điều khiển
nút vẫn chưa được sử dụng cho đến nay.

Với việc sử dụng ngày càng nhiều các trình kết xuất ngoài màn hình và các ứng dụng GPGPU,
khách hàng không còn yêu cầu chạy bộ tổng hợp hoặc máy chủ đồ họa để
sử dụng GPU. Nhưng DRM API yêu cầu các khách hàng không có đặc quyền phải
xác thực với DRM-Master trước khi có quyền truy cập GPU. Để tránh điều này
bước và cấp cho khách hàng quyền truy cập GPU mà không cần xác thực, kết xuất
các nút đã được giới thiệu. Các nút kết xuất chỉ phục vụ các máy khách kết xuất,
nghĩa là không có cài đặt chế độ hoặc ioctls đặc quyền nào có thể được cấp trên các nút kết xuất.
Chỉ cho phép các lệnh hiển thị không toàn cục. Nếu một trình điều khiển hỗ trợ
các nút kết xuất, nó phải quảng cáo nó thông qua trình điều khiển DRIVER_RENDER DRM
khả năng. Nếu không được hỗ trợ, nút chính phải được sử dụng để kết xuất
các máy khách cùng với thủ tục xác thực drmAuth cũ.

Nếu trình điều khiển quảng cáo hỗ trợ nút kết xuất, lõi DRM sẽ tạo
nút kết xuất riêng biệt được gọi là renderD<num>. Sẽ có một nút kết xuất
mỗi thiết bị. Sẽ không cho phép ioctls ngoại trừ ioctls liên quan đến PRIME trên
nút này. Đặc biệt GEM_OPEN sẽ bị cấm rõ ràng. Đối với một
danh sách đầy đủ các ioctls độc lập với trình điều khiển có thể được sử dụng khi kết xuất
các nút, xem ioctls được đánh dấu DRM_RENDER_ALLOW trong drm_ioctl.c Render
các nút được thiết kế để tránh rò rỉ bộ đệm, xảy ra nếu máy khách
đoán tên nhấp nháy hoặc độ lệch mmap trên giao diện cũ.
Ngoài giao diện cơ bản này, người lái xe phải đánh dấu
ioctls chỉ hiển thị phụ thuộc vào trình điều khiển như DRM_RENDER_ALLOW nên kết xuất
khách hàng có thể sử dụng chúng. Tác giả trình điều khiển phải cẩn thận không cho phép bất kỳ
ioctls đặc quyền trên các nút kết xuất.

Với các nút kết xuất, giờ đây không gian người dùng có thể kiểm soát quyền truy cập vào nút kết xuất
thông qua các chế độ truy cập hệ thống tập tin cơ bản. Một máy chủ đồ họa đang chạy
xác thực khách hàng trên nút chính/cũ có đặc quyền không còn nữa
được yêu cầu. Thay vào đó, máy khách có thể mở nút kết xuất và ngay lập tức
được cấp quyền truy cập GPU. Giao tiếp giữa các máy khách (hoặc máy chủ) được thực hiện
thông qua PRIME. FLINK từ nút kết xuất đến nút kế thừa không được hỗ trợ. Mới
khách hàng không được sử dụng giao diện FLINK không an toàn.

Bên cạnh việc loại bỏ tất cả các modeset/ioctls toàn cục, các nút kết xuất cũng loại bỏ
Khái niệm DRM-Master. Không có lý do gì để liên kết các ứng dụng khách kết xuất với
DRM-Master vì chúng độc lập với bất kỳ máy chủ đồ họa nào. Bên cạnh đó,
Dù sao thì chúng cũng phải hoạt động mà không có bất kỳ chủ nhân nào đang chạy. Người lái xe phải có khả năng
để chạy mà không có đối tượng chính nếu chúng hỗ trợ các nút kết xuất. Nếu, trên
mặt khác, trình điều khiển yêu cầu trạng thái chia sẻ giữa các máy khách.
hiển thị trong không gian người dùng và có thể truy cập được ngoài ranh giới tệp mở, chúng
không thể hỗ trợ các nút kết xuất.

Rút phích cắm nóng thiết bị
===========================

.. note::
   The following is the plan. Implementation is not there yet
   (2020 May).

Các thiết bị đồ họa (hiển thị và/hoặc kết xuất) có thể được kết nối qua USB (ví dụ:
bộ điều hợp màn hình hoặc trạm nối) hoặc Thunderbolt (ví dụ: eGPU). Một kết thúc
người dùng có thể rút phích cắm nóng của loại thiết bị này trong khi chúng đang được sử dụng
đã sử dụng và hy vọng rằng ít nhất máy không bị hỏng. bất kỳ
thiệt hại do rút phích cắm nóng thiết bị DRM cần được hạn chế ở mức tối đa
có thể và không gian người dùng phải có cơ hội xử lý nó nếu muốn
đến. Lý tưởng nhất là việc rút phích cắm của thiết bị DRM vẫn cho phép máy tính để bàn tiếp tục hoạt động.
chạy, nhưng điều đó sẽ cần sự hỗ trợ rõ ràng trong toàn bộ
ngăn xếp đồ họa: từ trình điều khiển kernel và không gian người dùng, thông qua hiển thị
máy chủ, thông qua các giao thức hệ thống cửa sổ, cũng như trong các ứng dụng và thư viện.

Các tình huống khác có thể dẫn đến điều tương tự là: GPU không thể phục hồi
gặp sự cố, thiết bị PCI biến mất khỏi xe buýt hoặc buộc tài xế phải hủy liên kết
từ thiết bị vật lý.

Nói cách khác, từ góc độ không gian người dùng, mọi thứ cần được tiếp tục
hoạt động ít nhiều cho đến khi không gian người dùng ngừng sử dụng DRM biến mất
thiết bị và đóng nó hoàn toàn. Không gian người dùng sẽ tìm hiểu về thiết bị
sự kiện biến mất khỏi thiết bị đã bị xóa, ioctls trả về ENODEV
(hoặc ioctls dành riêng cho trình điều khiển trả về những thứ dành riêng cho trình điều khiển) hoặc open()
trả lại ENXIO.

Chỉ sau khi không gian người dùng đã đóng tất cả thiết bị DRM và tệp dmabuf có liên quan
mô tả và loại bỏ tất cả các mmap, trình điều khiển DRM có thể phá bỏ nó
ví dụ cho thiết bị không còn tồn tại. Nếu cùng một thể chất
thiết bị nào đó quay trở lại vào thời điểm đó, nó sẽ là một chiếc DRM mới
thiết bị.

Tương tự như PID, số thứ tự chardev không được tái chế ngay lập tức. A
thiết bị DRM mới luôn chọn số phụ miễn phí tiếp theo so với số
cái trước được phân bổ và bao bọc khi có các số nhỏ
kiệt sức.

Mục tiêu đặt ra ít nhất các yêu cầu sau đối với kernel và
trình điều khiển.

Yêu cầu đối với KMS UAPI
-------------------------

- Đầu nối KMS phải thay đổi trạng thái thành ngắt kết nối.

- Các chế độ cũ và các lần lật trang cũng như các cam kết nguyên tử, cả thực và
  TEST_ONLY và bất kỳ ioctls nào khác đều bị lỗi với ENODEV hoặc giả mạo
  thành công.

- Các hoạt động KMS không chặn đang chờ xử lý sẽ cung cấp không gian người dùng sự kiện DRM
  đang mong đợi. Điều này cũng áp dụng cho các ioctls giả mạo thành công.

- open() trên nút thiết bị có thiết bị cơ bản đã biến mất sẽ
  thất bại với ENXIO.

- Cố gắng tạo hợp đồng thuê DRM trên thiết bị DRM đã biến mất sẽ
  thất bại với ENODEV. Các hợp đồng thuê DRM hiện tại vẫn duy trì và hoạt động như được liệt kê
  ở trên.

Yêu cầu đối với kết xuất và thiết bị chéo UAPI
----------------------------------------------

- Tất cả các công việc GPU không thể chạy được nữa đều phải có hàng rào
  buộc phải báo hiệu để tránh gây treo trên không gian người dùng.
  Mã lỗi liên quan là ENODEV.

- Một số API không gian người dùng đã xác định điều gì sẽ xảy ra khi thiết bị
  biến mất (OpenGL, GL ES: ZZ0000ZZ; ZZ0001ZZ:
  VK_ERROR_DEVICE_LOST; v.v.). Trình điều khiển DRM được tự do thực hiện việc này
  hành vi theo cách họ thấy rõ nhất, ví dụ: trả lại những thất bại trong
  ioctls dành riêng cho trình điều khiển và xử lý chúng trong trình điều khiển không gian người dùng hoặc
  dựa vào các sự kiện, v.v.

- dmabuf trỏ đến bộ nhớ đã biến mất sẽ không thành công
  nhập bằng ENODEV hoặc tiếp tục được nhập thành công nếu có
  đã thành công trước khi biến mất. Xem thêm về bản đồ bộ nhớ
  bên dưới cho các dmabuf đã được nhập.

- Cố gắng nhập dmabuf vào một thiết bị đã biến mất sẽ không thành công
  với ENODEV hoặc thành công nếu nó thành công mà không cần
  sự biến mất.

- open() trên nút thiết bị có thiết bị cơ bản đã biến mất sẽ
  thất bại với ENXIO.

.. _GL_KHR_robustness: https://www.khronos.org/registry/OpenGL/extensions/KHR/KHR_robustness.txt
.. _Vulkan: https://www.khronos.org/vulkan/

Yêu cầu đối với Bản đồ bộ nhớ
-----------------------------

Bản đồ bộ nhớ có các yêu cầu bổ sung áp dụng cho cả bản đồ hiện có
và bản đồ được tạo sau khi thiết bị biến mất. Nếu cơ sở
bộ nhớ biến mất, bản đồ được tạo hoặc sửa đổi để đọc và
ghi vẫn sẽ hoàn tất thành công nhưng kết quả không được xác định.
Điều này áp dụng cho cả bộ nhớ của không gian người dùng mmap() và bộ nhớ được trỏ bởi
dmabuf có thể được ánh xạ tới các thiết bị khác (dmabuf đa thiết bị
nhập khẩu).

Tăng SIGBUS không phải là một lựa chọn, vì không gian người dùng không thể thực tế
xử lý nó. Các trình xử lý tín hiệu có tính toàn cầu, điều này khiến chúng cực kỳ
khó sử dụng chính xác từ các thư viện như những thư viện mà Mesa tạo ra.
Trình xử lý tín hiệu không thể kết hợp được, bạn không thể có các trình xử lý khác nhau
dành cho GPU1 và GPU2 từ các nhà cung cấp khác nhau và trình xử lý thứ ba cho
các tập tin thông thường được mmapped. Chủ đề gây thêm đau đớn với tín hiệu
xử lý cũng vậy.

Đặt lại thiết bị
================

Ngăn xếp GPU thực sự phức tạp và dễ xảy ra lỗi, từ lỗi phần cứng,
các ứng dụng bị lỗi và mọi thứ ở giữa nhiều lớp. Một số lỗi
yêu cầu cài đặt lại thiết bị để có thể sử dụng lại thiết bị. Cái này
phần mô tả những kỳ vọng đối với DRM và trình điều khiển chế độ người dùng khi
đặt lại thiết bị và cách truyền bá trạng thái đặt lại.

Không thể tắt tính năng đặt lại thiết bị nếu không làm hỏng kernel, điều này có thể dẫn đến
treo toàn bộ hạt nhân thông qua bộ thu nhỏ/mmu_notifier. Vai trò không gian người dùng trong
đặt lại thiết bị là truyền thông báo đến ứng dụng và áp dụng bất kỳ
chính sách đặc biệt để chặn các ứng dụng có tội, nếu có. Hệ quả là thế
gỡ lỗi bối cảnh GPU bị treo yêu cầu hỗ trợ phần cứng để có thể ngăn chặn điều đó
bối cảnh GPU trong khi nó bị dừng.

Trình điều khiển chế độ hạt nhân
--------------------------------

KMD chịu trách nhiệm kiểm tra xem thiết bị có cần thiết lập lại hay không và thực hiện
nó khi cần thiết. Thông thường, lỗi treo được phát hiện khi một công việc bị kẹt khi thực thi.

Việc lan truyền lỗi tới không gian người dùng đã được chứng minh là khó khăn kể từ khi nó xâm nhập vào
hướng ngược lại với luồng lệnh thông thường. Vì nhà cung cấp này
việc xử lý lỗi độc lập đã được thêm vào đối tượng &dma_fence, theo cách này, trình điều khiển
có thể thêm mã lỗi vào hàng rào của họ trước khi báo hiệu cho họ. Xem chức năng
dma_fence_set_error() về cách thực hiện việc này và các ví dụ về mã lỗi cần sử dụng.

Bộ lập lịch DRM cũng cho phép đặt mã lỗi trên tất cả các hàng rào đang chờ xử lý khi
việc gửi phần cứng được khởi động lại sau khi thiết lập lại. Mã lỗi cũng có
được chuyển tiếp từ hàng rào phần cứng đến hàng rào lập lịch để xử lý lỗi
lên các cấp cao hơn của ngăn xếp và cuối cùng là không gian người dùng.

Lỗi hàng rào có thể được truy vấn bởi không gian người dùng thông qua SYNC_IOC_FILE_INFO chung
IOCTL cũng như thông qua các giao diện trình điều khiển cụ thể.

Ngoài việc cài đặt lỗi hàng rào, người lái xe cũng nên theo dõi số lần đặt lại mỗi lần.
ngữ cảnh, bộ lập lịch DRM cung cấp hàm drm_sched_entity_error() như
người trợ giúp cho trường hợp sử dụng này. Sau khi thiết lập lại, KMD sẽ từ chối lệnh mới
đệ trình cho các bối cảnh bị ảnh hưởng.

Trình điều khiển chế độ người dùng
----------------------------------

Sau khi gửi lệnh, UMD nên kiểm tra xem việc gửi đã được chấp nhận hay chưa
bị từ chối. Sau khi thiết lập lại, KMD sẽ từ chối gửi và UMD có thể đưa ra
ioctl vào KMD để kiểm tra trạng thái đặt lại và điều này có thể được kiểm tra thường xuyên hơn
nếu UMD yêu cầu. Sau khi phát hiện thiết lập lại, UMD sẽ tiến hành báo cáo
nó vào ứng dụng bằng mã lỗi API thích hợp, như được giải thích trong
phần bên dưới về độ bền.

Độ bền
----------

Cách duy nhất để cố gắng giữ cho bối cảnh đồ họa API hoạt động sau khi thiết lập lại là nếu
nó tuân thủ các khía cạnh mạnh mẽ của API đồ họa mà nó đang sử dụng.

API đồ họa cung cấp các cách để ứng dụng xử lý việc đặt lại thiết bị. Tuy nhiên,
không có gì đảm bảo rằng ứng dụng sẽ sử dụng các tính năng đó một cách chính xác và
không gian người dùng không hỗ trợ các giao diện mạnh mẽ (như một không gian không mạnh mẽ
Bối cảnh OpenGL hoặc API mà không có bất kỳ hỗ trợ mạnh mẽ nào như libva) hãy rời khỏi
xử lý mạnh mẽ hoàn toàn cho trình điều khiển không gian người dùng. Không có mạnh mẽ
sự đồng thuận của cộng đồng về những gì trình điều khiển không gian người dùng nên làm trong trường hợp đó,
vì tất cả các phương pháp hợp lý đều có một số nhược điểm rõ ràng.

OpenGL
~~~~~~

Các ứng dụng sử dụng OpenGL nên sử dụng các giao diện mạnh mẽ có sẵn, như
tiện ích mở rộng ZZ0000ZZ (hoặc ZZ0001ZZ cho OpenGL ES). Cái này
giao diện cho biết liệu việc thiết lập lại có xảy ra hay không và nếu có thì tất cả trạng thái ngữ cảnh là
bị coi là bị mất và ứng dụng sẽ tiếp tục bằng cách tạo những cái mới. Không có sự đồng thuận
về những việc cần làm nếu độ bền không được sử dụng.

Vulkan
~~~~~~

Các ứng dụng sử dụng Vulkan nên kiểm tra ZZ0000ZZ để gửi bài.
Mã lỗi này có nghĩa là, trong số những điều khác, việc thiết lập lại thiết bị đã xảy ra và
nó cần phải tạo lại bối cảnh để tiếp tục.

Báo cáo nguyên nhân reset
--------------------------

Ngoài việc truyền bá thiết lập lại qua ngăn xếp để các ứng dụng có thể khôi phục, nó còn
thực sự hữu ích cho các nhà phát triển trình điều khiển để tìm hiểu thêm về nguyên nhân gây ra việc thiết lập lại trong
nơi đầu tiên Đối với điều này, trình điều khiển có thể sử dụng devcoredump để lưu trữ có liên quan
thông tin về việc thiết lập lại và gửi sự kiện kết hợp thiết bị với ZZ0000ZZ recovery
phương pháp (như được giải thích trong chương "Thiết bị Wedging") để thông báo không gian người dùng, vì vậy phương pháp này
thông tin có thể được thu thập và thêm vào báo cáo lỗi của người dùng.

Nêm thiết bị
==============

Trình điều khiển có thể tùy ý sử dụng sự kiện kết hợp thiết bị (được triển khai dưới dạng
drm_dev_wedged_event() trong hệ thống con DRM), thông báo cho không gian người dùng về 'wedged'
(bị treo/không sử dụng được) của thiết bị DRM thông qua một sự kiện. Điều này rất hữu ích
đặc biệt trong trường hợp thiết bị không còn hoạt động như mong đợi và có
trở nên không thể phục hồi từ bối cảnh trình điều khiển. Mục đích của việc thực hiện này là để
cung cấp cho trình điều khiển một cách chung để khôi phục thiết bị với sự trợ giúp của không gian người dùng
can thiệp mà không thực hiện bất kỳ biện pháp quyết liệt nào (như thiết lập lại hoặc
liệt kê lại toàn bộ bus mà thiết bị vật lý cơ bản đang ngồi)
trong người lái xe.

Thiết bị 'nêm' về cơ bản là một thiết bị được tài xế tuyên bố là đã chết
sau khi dùng hết mọi nỗ lực có thể để khôi phục nó từ ngữ cảnh trình điều khiển. các
sự kiện là thông báo được gửi đến không gian người dùng cùng với gợi ý về
những gì có thể được cố gắng khôi phục thiết bị từ không gian người dùng và mang lại
nó trở lại trạng thái có thể sử dụng được. Những người lái xe khác nhau có thể có những ý tưởng khác nhau về một
thiết bị 'nêm' tùy thuộc vào việc triển khai phần cứng của cơ sở vật lý cơ bản
thiết bị, và do đó tính chất bất khả tri của nhà cung cấp của sự kiện. Nó tùy thuộc vào
người lái xe quyết định khi nào họ thấy cần khôi phục thiết bị và cách họ muốn
để phục hồi từ các phương pháp có sẵn.

Điều kiện tiên quyết của trình điều khiển
-----------------------------------------

Người lái xe trước khi chọn khôi phục cần đảm bảo rằng 'nêm'
thiết bị không gây hại cho toàn bộ hệ thống bằng cách quan tâm đến các điều kiện tiên quyết.
Các hành động cần thiết phải bao gồm việc vô hiệu hóa DMA vào bộ nhớ hệ thống cũng như bất kỳ
kênh liên lạc với các thiết bị khác. Ngoài ra, người lái xe phải đảm bảo
rằng tất cả các dma_fences đều được báo hiệu và mọi thiết bị đều cho biết lõi lõi
có thể phụ thuộc vào việc được dọn dẹp. Tất cả các mmap hiện có sẽ bị vô hiệu hóa và
lỗi trang sẽ được chuyển hướng đến một trang giả. Sau khi sự kiện được gửi đi,
thiết bị phải được giữ ở trạng thái 'nêm' cho đến khi quá trình khôi phục được thực hiện. Mới
quyền truy cập vào thiết bị (IOCTL) phải bị từ chối, tốt nhất là có lỗi
mã giống với loại lỗi mà thiết bị đã gặp phải. Điều này sẽ
biểu thị lý do nêm, có thể được báo cáo cho ứng dụng nếu
cần thiết.

Sự hồi phục
-----------

Việc triển khai hiện tại xác định bốn phương pháp khôi phục, trong đó, trình điều khiển
có thể sử dụng bất kỳ một, nhiều hoặc không. (Các) phương pháp lựa chọn sẽ được gửi trong
môi trường sự kiện như ZZ0000ZZ theo thứ tự từ ít đến
nhiều tác dụng phụ hơn. Xem phần ZZ0003ZZ
cho ZZ0001ZZ. Nếu người lái xe không chắc chắn về việc khôi phục hoặc
phương thức không xác định, thay vào đó ZZ0002ZZ sẽ được gửi.

Người sử dụng không gian người dùng có thể phân tích cú pháp sự kiện này và thử khôi phục theo
theo những mong đợi.

============================================================
    Phương pháp phục hồi Kỳ vọng của người tiêu dùng
    ============================================================
    không có bộ sưu tập đo từ xa tùy chọn
    rebind unbind + liên kết trình điều khiển
    hủy liên kết đặt lại xe buýt + đặt lại/liệt kê lại xe buýt + liên kết
    phương pháp phục hồi cụ thể của nhà cung cấp cụ thể
    chính sách tiêu dùng chưa biết
    ============================================================

Không phục hồi
--------------

Ở đây ZZ0000ZZ biểu thị rằng người tiêu dùng không mong đợi sự phục hồi nào
nhưng nó vẫn có thể cố gắng thu thập thông tin đo từ xa (devcoredump, syslog) cho
mục đích gỡ lỗi nhằm root nguyên nhân gây treo. Điều này rất hữu ích vì lần đầu tiên
treo thường là vấn đề quan trọng nhất có thể dẫn đến việc bị treo
hoặc nêm hoàn chỉnh.

Phục hồi cụ thể của nhà cung cấp
--------------------------------

Khi ZZ0000ZZ được gửi, nó cho biết thiết bị yêu cầu
một quy trình khôi phục dành riêng cho nhà cung cấp phần cứng và không phải là một trong những quy trình
các phương pháp tiếp cận được tiêu chuẩn hóa.

ZZ0000ZZ có thể được sử dụng để chỉ ra các trường hợp khác nhau trong một
trình điều khiển của nhà cung cấp duy nhất, mỗi trình điều khiển yêu cầu một quy trình khôi phục riêng biệt.
Trong những trường hợp như vậy, trình điều khiển của nhà cung cấp phải cung cấp tài liệu toàn diện
mô tả từng trường hợp, bao gồm các gợi ý bổ sung để xác định trường hợp cụ thể và
phác thảo thủ tục phục hồi tương ứng. Tài liệu bao gồm:

Trường hợp - Danh sách tất cả các trường hợp gửi phương thức khôi phục ZZ0000ZZ.

Gợi ý - Thông tin bổ sung để hỗ trợ người dùng không gian người dùng xác định và
phân biệt các trường hợp khác nhau. Điều này có thể được phơi bày thông qua sysfs, debugfs,
dấu vết, dmesg, v.v.

Quy trình phục hồi - Hướng dẫn, hướng dẫn phục hồi rõ ràng cho từng trường hợp.
Điều này có thể bao gồm các tập lệnh vùng người dùng, các công cụ cần thiết cho quy trình khôi phục.

Trách nhiệm của quản trị viên/người tiêu dùng không gian người dùng là xác định trường hợp và
xác minh các gợi ý nhận dạng bổ sung trước khi thử quy trình khôi phục.

Ví dụ: Nếu thiết bị sử dụng trình điều khiển Xe thì người tiêu dùng không gian người dùng nên tham khảo
ZZ0000ZZ để biết tài liệu chi tiết.

Thông tin nhiệm vụ
------------------

Thông tin về ứng dụng nào (nếu có) liên quan đến thiết bị
việc nêm rất hữu ích cho không gian người dùng nếu họ muốn thông báo cho người dùng về những gì
đã xảy ra (ví dụ: bộ tổng hợp hiển thị thông báo cho người dùng "<tên tác vụ>
gây ra lỗi đồ họa và hệ thống đã được khôi phục") hoặc để thực hiện các chính sách
(ví dụ: daemon có thể "cấm" tác vụ liên tục đặt lại thiết bị). Nếu nhiệm vụ
thông tin có sẵn, sự kiện sẽ hiển thị dưới dạng ZZ0000ZZ và
ZZ0001ZZ. Nếu không, ZZ0002ZZ và ZZ0003ZZ sẽ không xuất hiện trong
chuỗi sự kiện.

Độ tin cậy của thông tin này phụ thuộc vào trình điều khiển và phần cứng cụ thể và phải
hãy thận trọng về độ chính xác của nó. Để có một bức tranh lớn về những gì
thực sự đã xảy ra, tệp devcoredump cung cấp nhiều thông tin chi tiết hơn
về trạng thái thiết bị và về sự kiện.

Điều kiện tiên quyết của người tiêu dùng
----------------------------------------

Trách nhiệm của người tiêu dùng là đảm bảo rằng thiết bị hoặc
tài nguyên không được sử dụng bởi bất kỳ tiến trình nào trước khi thử khôi phục. Với IOCTL
bị lỗi, tất cả bộ nhớ thiết bị sẽ không được ánh xạ và bộ mô tả tệp sẽ
được đóng lại để tránh rò rỉ hoặc hành vi không xác định. Ý tưởng ở đây là để xóa
thiết bị của tất cả bối cảnh người dùng trước và tạo tiền đề cho quá trình khôi phục hoàn toàn.

Đối với phương pháp khôi phục ZZ0000ZZ, trách nhiệm của
người tiêu dùng kiểm tra tài liệu trình điều khiển và usecase trước khi thử
một sự phục hồi.

Ví dụ - rebind
----------------

Quy tắc Udev::

SUBSYSTEM=="drm", ENV{WEDGED}=="rebind", DEVPATH=="*/drm/card[0-9]",
    RUN+="/path/to/rebind.sh $env{DEVPATH}"

Tập lệnh khôi phục::

#!/bin/sh

DEVPATH=$(readlink -f /sys/$1/device)
    DEVICE=$(tên cơ sở $DEVPATH)
    DRIVER=$(readlink -f $DEVPATH/trình điều khiển)

echo -n $DEVICE > $DRIVER/hủy liên kết
    echo -n $DEVICE > $DRIVER/liên kết

Tùy chỉnh
-------------

Mặc dù có thể khôi phục cơ bản bằng một tập lệnh đơn giản nhưng người tiêu dùng có thể xác định
chính sách tùy chỉnh xung quanh việc phục hồi. Ví dụ: nếu trình điều khiển hỗ trợ nhiều
phương pháp khôi phục, người tiêu dùng có thể lựa chọn phương pháp phù hợp tùy theo tình huống
như tái phạm hoặc lỗi cụ thể của nhà cung cấp. Người tiêu dùng cũng có thể lựa chọn
có sẵn thiết bị để gỡ lỗi hoặc thu thập dữ liệu từ xa và căn cứ vào
quyết định thu hồi kết quả. Điều này rất hữu ích đặc biệt khi người lái xe
không chắc chắn về việc phục hồi hoặc phương pháp không xác định.

.. _drm_driver_ioctl:

Hỗ trợ IOCTL trên các nút thiết bị
==================================

.. kernel-doc:: drivers/gpu/drm/drm_ioctl.c
   :doc: driver specific ioctls

Giá trị trả về IOCTL được đề xuất
---------------------------------

Về lý thuyết, lệnh gọi lại IOCTL của trình điều khiển chỉ được phép trả về rất ít lỗi
mã. Trong thực tế, tốt hơn là lạm dụng thêm một vài thứ nữa. Phần này tài liệu chung
thực hành trong hệ thống con DRM:

ENOENT:
        Nghiêm túc, điều này chỉ nên được sử dụng khi một tập tin không tồn tại, ví dụ: khi nào
        gọi tòa nhà open(). Chúng tôi tái sử dụng thông tin đó để báo hiệu bất kỳ loại đối tượng nào
        tra cứu thất bại, ví dụ: đối với các bộ xử lý đối tượng bộ đệm GEM không xác định, KMS không xác định
        xử lý đối tượng và các trường hợp tương tự.

ENOSPC:
        Một số trình điều khiển sử dụng điều này để phân biệt "hết bộ nhớ kernel" với "hết bộ nhớ kernel".
        của VRAM". Đôi khi cũng áp dụng cho các tài nguyên gpu hạn chế khác được sử dụng cho
        hiển thị (ví dụ: khi bạn có bộ đệm nén giới hạn đặc biệt).
        Đôi khi có vấn đề về phân bổ/dự trữ tài nguyên khi gửi lệnh
        IOCTL cũng được báo hiệu thông qua EDEADLK.

Việc hết bộ nhớ kernel/hệ thống sẽ được báo hiệu qua ENOMEM.

EPERM/EACCES:
        Được trả về cho một thao tác hợp lệ nhưng cần nhiều đặc quyền hơn.
        Ví dụ. chỉ dành cho root hoặc phổ biến hơn nhiều, các hoạt động chỉ dành cho chủ DRM trả về
        điều này khi được gọi bởi các khách hàng không có đặc quyền. Không có gì rõ ràng
        sự khác biệt giữa EACCES và EPERM.

ENODEV:
        Thiết bị không còn tồn tại hoặc chưa được khởi tạo đầy đủ.

EOPNOTSUPP:
        Tính năng (như PRIME, cài đặt chế độ, GEM) không được trình điều khiển hỗ trợ.

ENXIO:
        Lỗi từ xa, có thể là giao dịch phần cứng (như i2c), nhưng cũng được sử dụng
        khi trình điều khiển xuất của dma-buf hoặc hàng rào được chia sẻ không hỗ trợ
        tính năng cần thiết.

EINTR:
        Trình điều khiển DRM giả định rằng không gian người dùng khởi động lại tất cả IOCTL. Bất kỳ DRM IOCTL nào cũng có thể
        trả lại EINTR và trong trường hợp như vậy nên khởi động lại bằng IOCTL
        các thông số không thay đổi.

EIO:
        GPU đã chết và không thể hồi sinh thông qua việc thiết lập lại. Chế độ cài đặt
        lỗi phần cứng được báo hiệu thông qua đầu nối "trạng thái liên kết"
        tài sản.

EINVAL:
        Bắt tất cả mọi thứ là sự kết hợp đối số không hợp lệ
        không thể làm việc.

IOCTL cũng sử dụng các mã lỗi khác như ETIME, EFAULT, EBUSY, ENOTTY nhưng chúng
cách dùng phù hợp với nghĩa thông thường. Danh sách trên cố gắng chỉ ghi lại
Các mẫu cụ thể của DRM. Lưu ý rằng ENOTTY có ý nghĩa hơi khó hiểu của
"IOCTL này không tồn tại" và được sử dụng chính xác như vậy trong DRM.

.. kernel-doc:: include/drm/drm_ioctl.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_ioctl.c
   :export:

.. kernel-doc:: drivers/gpu/drm/drm_ioc32.c
   :export:

Kiểm tra và xác nhận
======================

Yêu cầu kiểm tra đối với không gian người dùng API
--------------------------------------------------

Các phần mở rộng giao diện không gian người dùng trình điều khiển chéo mới, như IOCTL mới, KMS mới
thuộc tính, tệp mới trong sysfs hoặc bất kỳ thứ gì khác cấu thành thay đổi API
phải có các trường hợp kiểm tra bất khả tri về trình điều khiển trong IGT cho tính năng đó, nếu kiểm tra như vậy
có thể được thực hiện một cách hợp lý bằng cách sử dụng IGT cho phần cứng mục tiêu.

Xác thực các thay đổi với IGT
-----------------------------

Có một tập hợp các bài kiểm tra nhằm mục đích bao quát toàn bộ chức năng của
Trình điều khiển DRM và có thể được sử dụng để kiểm tra những thay đổi đối với trình điều khiển DRM hoặc
core không hồi quy chức năng hiện có. Bộ thử nghiệm này được gọi là IGT và
mã và hướng dẫn xây dựng và chạy của nó có thể được tìm thấy trong
ZZ0000ZZ

Sử dụng VKMS để kiểm tra DRM API
--------------------------------

VKMS là mẫu trình điều khiển KMS chỉ có phần mềm, hữu ích cho việc thử nghiệm
và để chạy các bộ tổng hợp. VKMS nhằm mục đích kích hoạt màn hình ảo mà không cần
sự cần thiết của khả năng hiển thị phần cứng. Những đặc điểm này đã tạo nên VKMS
một công cụ hoàn hảo để xác thực hành vi cốt lõi của DRM và cũng hỗ trợ
nhà phát triển bộ tổng hợp. VKMS cho phép kiểm tra các chức năng DRM trong một
máy ảo không có màn hình, đơn giản hóa việc xác thực một số
những thay đổi cốt lõi.

Để xác thực các thay đổi trong DRM API bằng VKMS, hãy bắt đầu cài đặt kernel: make
chắc chắn kích hoạt mô-đun VKMS; biên dịch kernel với VKMS được kích hoạt và
cài đặt nó vào máy mục tiêu. VKMS có thể chạy trong Máy ảo
(QEMU, virtme hoặc tương tự). Bạn nên sử dụng KVM ở mức tối thiểu
1GB RAM và bốn lõi.

Có thể chạy thử nghiệm IGT trong VM theo hai cách:

1. Sử dụng IGT bên trong VM
	2. Sử dụng IGT từ máy chủ và ghi kết quả vào thư mục dùng chung.

Sau đây là ví dụ về cách sử dụng VM với thư mục dùng chung với
máy chủ để chạy igt-tests. Ví dụ này sử dụng virtme::

$ virtme-run --rwdir /path/for/shared_dir --kdir=path/for/kernel/directory --mods=auto

Chạy thử nghiệm igt trong máy khách. Ví dụ này chạy 'kms_flip'
kiểm tra::

$ /path/for/igt-gpu-tools/scripts/run-tests.sh -p -s -t "kms_flip.*" -v

Trong ví dụ này, thay vì xây dựng igt_runner, Piglit được sử dụng
(tùy chọn -p). Nó tạo ra một bản tóm tắt HTML về kết quả kiểm tra và lưu lại
chúng trong thư mục "igt-gpu-tools/results". Nó chỉ thực hiện các bài kiểm tra igt
khớp với tùy chọn -t.

Hỗ trợ hiển thị CRC
-------------------

.. kernel-doc:: drivers/gpu/drm/drm_debugfs_crc.c
   :doc: CRC ABI

.. kernel-doc:: drivers/gpu/drm/drm_debugfs_crc.c
   :export:

Hỗ trợ gỡ lỗi
---------------

.. kernel-doc:: include/drm/drm_debugfs.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_debugfs.c
   :export:

Hỗ trợ hệ thống
===============

.. kernel-doc:: drivers/gpu/drm/drm_sysfs.c
   :doc: overview

.. kernel-doc:: drivers/gpu/drm/drm_sysfs.c
   :export:


Xử lý sự kiện VBlank
=====================

Lõi DRM hiển thị hai ioctls trống liên quan theo chiều dọc:

ZZ0000ZZ
    Điều này lấy cấu trúc struct drm_wait_vblank làm đối số của nó và
    nó được sử dụng để chặn hoặc yêu cầu tín hiệu khi vblank được chỉ định
    sự kiện xảy ra.

ZZ0000ZZ
    Điều này chỉ được sử dụng cho trình điều khiển cài đặt chế độ người dùng xung quanh cài đặt chế độ
    thay đổi để cho phép kernel cập nhật ngắt vblank sau
    cài đặt chế độ, vì trên nhiều thiết bị, bộ đếm trống dọc được
    đặt lại về 0 tại một số điểm trong khi thiết lập chế độ. Trình điều khiển hiện đại không nên
    gọi cái này nữa vì với cài đặt chế độ kernel thì nó không hoạt động.

Cấu trúc không gian người dùng API
==================================

.. kernel-doc:: include/uapi/drm/drm_mode.h
   :doc: overview

.. _crtc_index:

Chỉ số CRTC
-----------

CRTC có cả ID đối tượng và chỉ mục và chúng không giống nhau.
Chỉ mục này được sử dụng trong trường hợp mã định danh được đóng gói dày đặc cho CRTC
cần thiết, ví dụ như một bitmask của CRTC. Thành viên could_crtcs của struct
drm_mode_get_plane là một ví dụ.

ZZ0000ZZ đưa vào một cấu trúc với một mảng
ID CRTC và chỉ mục CRTC là vị trí của nó trong mảng này.

.. kernel-doc:: include/uapi/drm/drm.h
   :internal:

.. kernel-doc:: include/uapi/drm/drm_mode.h
   :internal:


khả năng tương tác dma-buf
==========================

Vui lòng xem Tài liệu/userspace-api/dma-buf-alloc-exchange.rst để biết
thông tin về cách DMA-buf được tích hợp và hiển thị trong DRM.


Theo dõi sự kiện
================

Xem Tài liệu/trace/tracepoints.rst để biết thông tin về cách sử dụng
Điểm theo dõi hạt nhân Linux.
Trong hệ thống con DRM, một số sự kiện được coi là uAPI ổn định để tránh
các công cụ phá vỡ (ví dụ: GPUVis, umr) dựa vào chúng. Ổn định có nghĩa là các trường
không thể xóa được cũng như không thể cập nhật định dạng của chúng. Thêm các trường mới là
có thể, theo yêu cầu uAPI thông thường.

Sự kiện uAPI ổn định
--------------------

Từ ZZ0000ZZ

.. kernel-doc::  drivers/gpu/drm/scheduler/gpu_scheduler_trace.h
   :doc: uAPI trace events