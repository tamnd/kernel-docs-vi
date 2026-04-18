.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/dma-attributes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================
Thuộc tính DMA
==============

Tài liệu này mô tả ngữ nghĩa của các thuộc tính DMA
được định nghĩa trong linux/dma-mapping.h.

DMA_ATTR_WEAK_ORDERING
----------------------

DMA_ATTR_WEAK_ORDERING chỉ định rằng đọc và ghi vào ánh xạ
có thể được sắp xếp yếu, nghĩa là việc đọc và ghi có thể truyền qua nhau.

Vì các nền tảng có thể tùy chọn triển khai DMA_ATTR_WEAK_ORDERING,
những người không làm như vậy sẽ đơn giản bỏ qua thuộc tính và thể hiện mặc định
hành vi.

DMA_ATTR_WRITE_COMBINE
----------------------

DMA_ATTR_WRITE_COMBINE chỉ định rằng việc ghi vào ánh xạ có thể
đệm để cải thiện hiệu suất.

Vì các nền tảng có thể tùy chọn triển khai DMA_ATTR_WRITE_COMBINE,
những người không làm như vậy sẽ đơn giản bỏ qua thuộc tính và thể hiện mặc định
hành vi.

DMA_ATTR_NO_KERNEL_MAPPING
--------------------------

DMA_ATTR_NO_KERNEL_MAPPING cho phép nền tảng tránh tạo kernel
ánh xạ ảo cho bộ đệm được phân bổ. Trên một số kiến trúc tạo
việc lập bản đồ như vậy là một nhiệm vụ không hề nhỏ và tiêu tốn rất ít tài nguyên
(như không gian địa chỉ ảo kernel hoặc không gian địa chỉ nhất quán dma).
Bộ đệm được phân bổ với thuộc tính này chỉ có thể được chuyển đến không gian người dùng
bằng cách gọi dma_mmap_attrs(). Bằng cách sử dụng API này, bạn đang đảm bảo
rằng bạn sẽ không hủy đăng ký con trỏ được trả về bởi dma_alloc_attr(). bạn
có thể coi nó như một cookie phải được chuyển tới dma_mmap_attrs() và
dma_free_attrs(). Hãy chắc chắn rằng cả hai thứ này cũng có thuộc tính này
đặt trên mỗi cuộc gọi.

Vì nền tảng có thể tùy chọn triển khai
DMA_ATTR_NO_KERNEL_MAPPING, những người không làm như vậy sẽ đơn giản bỏ qua
thuộc tính và thể hiện hành vi mặc định.

DMA_ATTR_SKIP_CPU_SYNC
----------------------

Theo mặc định, họ hàm dma_map_{single,page,sg} chuyển một giá trị nhất định
đệm từ miền CPU sang miền thiết bị. Một số trường hợp sử dụng nâng cao có thể
yêu cầu chia sẻ bộ đệm giữa nhiều thiết bị. Điều này đòi hỏi
có một ánh xạ được tạo riêng cho từng thiết bị và thường
được thực hiện bằng cách gọi hàm dma_map_{single,page,sg} nhiều lần
cho bộ đệm nhất định có con trỏ thiết bị tới từng thiết bị tham gia
việc chia sẻ bộ đệm. Cuộc gọi đầu tiên chuyển bộ đệm từ miền 'CPU'
tới miền 'thiết bị', thứ sẽ đồng bộ hóa bộ đệm CPU cho vùng nhất định
(thông thường nó có nghĩa là bộ đệm đã bị xóa hoặc vô hiệu
tùy theo hướng dma). Tuy nhiên, các cuộc gọi tiếp theo tới
dma_map_{single,page,sg}() cho các thiết bị khác sẽ thực hiện chính xác
hoạt động đồng bộ hóa tương tự trên bộ đệm CPU. Đồng bộ hóa bộ đệm CPU
có thể là một hoạt động tốn thời gian, đặc biệt nếu bộ đệm
lớn, vì vậy nên tránh nó nếu có thể.
DMA_ATTR_SKIP_CPU_SYNC cho phép mã nền tảng bỏ qua việc đồng bộ hóa
bộ đệm CPU cho bộ đệm đã cho giả sử rằng nó đã được
được chuyển sang miền 'thiết bị'. Thuộc tính này cũng có thể được sử dụng cho
dma_unmap_{single,page,sg} có chức năng buộc bộ đệm ở lại
miền thiết bị sau khi phát hành ánh xạ cho nó. Sử dụng thuộc tính này với
quan tâm!

DMA_ATTR_FORCE_CONTIGUOUS
-------------------------

Theo mặc định, hệ thống con ánh xạ DMA được phép lắp ráp bộ đệm
được phân bổ bởi hàm dma_alloc_attrs() từ các trang riêng lẻ nếu có thể
được ánh xạ dưới dạng đoạn liền kề vào không gian địa chỉ dma của thiết bị. Bởi
chỉ định thuộc tính này bộ đệm được phân bổ buộc phải liền kề
cả trong bộ nhớ vật lý.

DMA_ATTR_ALLOC_SINGLE_PAGES
---------------------------

Đây là một gợi ý cho hệ thống con ánh xạ DMA mà có lẽ nó không có giá trị
đã đến lúc cố gắng phân bổ bộ nhớ theo cách mang lại TLB tốt hơn
hiệu quả (AKA không đáng để cố gắng xây dựng bản đồ từ các
trang).  Bạn có thể muốn chỉ định điều này nếu:

- Bạn biết rằng việc truy cập vào bộ nhớ này sẽ không ảnh hưởng đến TLB.
  Bạn có thể biết rằng các truy cập có thể là tuần tự hoặc
  rằng chúng không tuần tự nhưng không chắc bạn sẽ chơi bóng bàn
  giữa nhiều địa chỉ có thể ở các địa chỉ vật lý khác nhau
  trang.
- Bạn biết rằng hình phạt của TLB bị trượt khi truy cập
  bộ nhớ sẽ đủ nhỏ để không quan trọng.  Nếu bạn là
  thực hiện một thao tác nặng như giải mã hoặc giải nén cái này
  có thể là như vậy
- Bạn biết rằng ánh xạ DMA khá tạm thời.  Nếu bạn mong đợi
  việc lập bản đồ có thời gian tồn tại ngắn thì có thể đáng để thực hiện
  tối ưu hóa phân bổ (tránh xuất hiện các trang lớn) thay vì
  nhận được chiến thắng hiệu suất nhỏ của các trang lớn hơn.

Việc đặt gợi ý này không đảm bảo rằng bạn sẽ không nhận được các trang lớn nhưng nó
có nghĩa là chúng ta sẽ không cố gắng hết sức để có được chúng.

.. note:: At the moment DMA_ATTR_ALLOC_SINGLE_PAGES is only implemented on ARM,
	  though ARM64 patches will likely be posted soon.

DMA_ATTR_NO_WARN
----------------

Điều này báo cho hệ thống con ánh xạ DMA ngăn chặn các báo cáo lỗi phân bổ
(tương tự như __GFP_NOWARN).

Trên một số lỗi phân bổ kiến trúc được báo cáo kèm theo thông báo lỗi
vào nhật ký hệ thống.  Mặc dù điều này có thể giúp xác định và gỡ lỗi các vấn đề,
trình điều khiển xử lý lỗi (ví dụ: thử lại sau) không gặp vấn đề gì với chúng,
và thực sự có thể làm tràn ngập nhật ký hệ thống với các thông báo lỗi không hề có.
vấn đề gì cả, tùy thuộc vào việc thực hiện cơ chế thử lại.

Vì vậy, điều này cung cấp một cách để người lái xe tránh những thông báo lỗi đó trong các cuộc gọi
trong đó lỗi phân bổ không phải là vấn đề và không làm phiền nhật ký.

.. note:: At the moment DMA_ATTR_NO_WARN is only implemented on PowerPC.

DMA_ATTR_PRIVILEGED
-------------------

Một số thiết bị ngoại vi nâng cao như bộ xử lý từ xa và GPU hoạt động
truy cập vào bộ đệm DMA ở cả "người giám sát" đặc quyền và không có đặc quyền
chế độ "người dùng".  Thuộc tính này được sử dụng để biểu thị ánh xạ DMA
hệ thống con mà bộ đệm có thể truy cập đầy đủ ở đặc quyền nâng cao
cấp độ (và lý tưởng nhất là không thể truy cập được hoặc ít nhất là ở chế độ chỉ đọc tại
mức độ đặc quyền thấp hơn).

DMA_ATTR_MMIO
-------------

Thuộc tính này cho biết địa chỉ vật lý không phải là hệ thống bình thường
trí nhớ. Nó có thể không được sử dụng với kmap*()/phys_to_virt()/phys_to_page()
chức năng, nó có thể không được lưu vào bộ nhớ đệm và truy cập bằng cách tải/lưu trữ CPU
hướng dẫn có thể không được phép.

Thông thường, điều này sẽ được sử dụng để mô tả các địa chỉ MMIO hoặc các địa chỉ không thể lưu vào bộ nhớ đệm khác
đăng ký địa chỉ. Khi DMA ánh xạ loại địa chỉ này, chúng tôi gọi
hoạt động ngang hàng với tư cách một thiết bị là DMA'ing với một thiết bị khác.
Đối với thiết bị PCI, API p2pdma phải được sử dụng để xác định xem
DMA_ATTR_MMIO là phù hợp.

Dành cho các kiến trúc yêu cầu xóa bộ nhớ đệm để đảm bảo tính nhất quán của DMA
DMA_ATTR_MMIO sẽ không thực hiện bất kỳ thao tác xóa bộ đệm nào. Địa chỉ
được cung cấp không bao giờ được ánh xạ vào bộ nhớ đệm vào CPU.

DMA_ATTR_DEBUGGING_IGNORE_CACHELINES
------------------------------------

Thuộc tính này chỉ ra rằng các dòng bộ đệm CPU có thể chồng lên nhau đối với các bộ đệm được ánh xạ
với DMA_FROM_DEVICE hoặc DMA_BIDIRECTIONAL.

Sự chồng chéo như vậy có thể xảy ra khi người gọi ánh xạ nhiều bộ đệm nhỏ nằm trong
trong cùng một dòng bộ đệm. Trong trường hợp này, người gọi phải đảm bảo rằng CPU
sẽ không làm bẩn các dòng bộ đệm này sau khi ánh xạ được thiết lập. Khi điều này
được đáp ứng, nhiều bộ đệm có thể chia sẻ một dòng bộ đệm một cách an toàn mà không gặp rủi ro
tham nhũng dữ liệu.

Tất cả các ánh xạ chia sẻ một dòng bộ đệm phải đặt thuộc tính này để chặn DMA
cảnh báo gỡ lỗi về ánh xạ chồng chéo.

DMA_ATTR_REQUIRE_COHERENT
-------------------------

Yêu cầu ánh xạ DMA với DMA_ATTR_REQUIRE_COHERENT không thành công trên bất kỳ
hệ thống yêu cầu quản lý SWIOTLB hoặc bộ đệm. Điều này chỉ nên
được sử dụng để hỗ trợ các thiết kế uAPI yêu cầu HW DMA liên tục
sự gắn kết với các quy trình không gian người dùng, ví dụ RDMA và DRM. Tại một
bộ nhớ tối thiểu được ánh xạ phải là bộ nhớ không gian người dùng từ
pin_user_pages() hoặc tương tự.

Trình điều khiển nên cân nhắc sử dụng dma_mmap_pages() thay vì điều này
giao diện khi xây dựng uAPI của họ, khi có thể.

Nó không bao giờ được sử dụng trong trình điều khiển trong kernel chỉ hoạt động với
bộ nhớ hạt nhân.
