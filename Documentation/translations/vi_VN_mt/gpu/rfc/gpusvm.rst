.. SPDX-License-Identifier: (GPL-2.0+ OR MIT)

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/gpu/rfc/gpusvm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
Phần GPU SVM
=================

Thống nhất nguyên tắc thiết kế
==============================

* đường dẫn di chuyển_to_ram
	* Chỉ dựa vào các khái niệm MM cốt lõi (PTE di chuyển, tham chiếu trang và
	  khóa trang).
	* Không có khóa cụ thể cho trình điều khiển nào ngoài khóa tương tác phần cứng trong
	  con đường này. Những điều này không bắt buộc và nói chung là một ý tưởng tồi để
	  phát minh ra các khóa do trình điều khiển xác định để phong ấn các cuộc đua MM cốt lõi.
	* Một ví dụ về sự cố gây ra khóa dành riêng cho trình điều khiển trước đây
	  sửa do_swap_page để khóa trang bị lỗi. Khóa dành riêng cho người lái
	  trong Migify_to_ram tạo ra một livelock ổn định nếu đọc đủ chủ đề
	  trang bị lỗi.
	* Hỗ trợ di chuyển một phần (tức là một tập hợp con các trang đang cố gắng
	  di chuyển thực sự có thể di chuyển, chỉ đảm bảo trang bị lỗi
	  để di cư).
	* Trình điều khiển xử lý các quá trình di chuyển hỗn hợp thông qua các vòng thử lại thay vì khóa.
* Trục xuất
	* Việc trục xuất được định nghĩa là di chuyển dữ liệu từ GPU trở lại
	  CPU không có địa chỉ ảo để giải phóng bộ nhớ GPU.
	* Chỉ nhìn vào cấu trúc và khóa dữ liệu bộ nhớ vật lý chứ không phải
	  nhìn vào cấu trúc và khóa dữ liệu bộ nhớ ảo.
	* Không nhìn vào cấu trúc mm/vma hoặc dựa vào những cấu trúc bị khóa.
	* Cơ sở của hai điểm trên là địa chỉ ảo CPU
	  có thể thay đổi bất cứ lúc nào, trong khi các trang vật lý vẫn ổn định.
	* Việc vô hiệu hóa bảng trang GPU, yêu cầu địa chỉ ảo GPU, là
	  được xử lý thông qua trình thông báo có quyền truy cập vào địa chỉ ảo GPU.
* Bên lỗi GPU
	* mmap_read chỉ được sử dụng xung quanh các hàm MM cốt lõi yêu cầu khóa này
	  và nên cố gắng chỉ lấy khóa mmap_read trong lớp GPU SVM.
	* Vòng thử lại lớn để xử lý tất cả các cuộc đua với trình thông báo mmu dưới gpu
	  khóa có thể phân trang/khóa phạm vi thông báo mmu/bất cứ điều gì chúng ta gọi
          những cái đó.
	* Các cuộc đua (đặc biệt là chống lại việc trục xuất đồng thời hoặc di chuyển_to_ram)
	  không nên xử lý lỗi bằng cách cố giữ ổ khóa;
	  đúng hơn, chúng nên được xử lý bằng cách sử dụng vòng lặp thử lại. Một khả năng
	  ngoại lệ đang giữ khóa dma-resv của BO trong quá trình di chuyển ban đầu
	  tới VRAM, vì đây là khóa được xác định rõ ràng có thể được đặt bên dưới
	  khóa mmap_read.
	* Một vấn đề có thể xảy ra với cách tiếp cận trên là nếu người lái xe có quy định nghiêm ngặt về
	  chính sách di chuyển yêu cầu quyền truy cập GPU xảy ra trong bộ nhớ GPU.
	  Truy cập CPU đồng thời có thể gây ra hiện tượng khóa trực tiếp do số lần thử lại không ngừng.
	  Mặc dù không có người dùng hiện tại (Xe) của GPU SVM có chính sách như vậy, nhưng rất có thể
	  sẽ được bổ sung trong tương lai. Tốt nhất, vấn đề này nên được giải quyết trên
	  bên core-MM thay vì thông qua khóa bên trình điều khiển.
* Bộ nhớ vật lý cho con trỏ ngược ảo
	* Điều này không hoạt động vì không có con trỏ từ bộ nhớ vật lý đến bộ nhớ ảo
	  bộ nhớ nên tồn tại. mremap() là một ví dụ về cập nhật MM cốt lõi
	  địa chỉ ảo mà không thông báo cho trình điều khiển địa chỉ
	  thay đổi thay vì trình điều khiển chỉ nhận được thông báo vô hiệu.
	* Con trỏ ngược bộ nhớ vật lý (trang->zone_device_data) sẽ được giữ nguyên
	  ổn định từ khi cấp phát đến khi có trang trống. Cập nhật an toàn điều này chống lại một
	  người dùng đồng thời sẽ rất khó khăn trừ khi trang này miễn phí.
* Khóa phân trang GPU
	* Khóa trình thông báo chỉ bảo vệ cây phạm vi, trạng thái trang hợp lệ cho một phạm vi
	  (chứ không phải seqno do trình thông báo rộng hơn), các mục nhập có thể phân trang và
	  Theo dõi seqno của trình thông báo mmu, nó không phải là khóa toàn cầu để bảo vệ
          chống lại các chủng tộc.
	* Tất cả các cuộc đua đều được xử lý với số lần thử lại lớn như đã đề cập ở trên.

Tổng quan về thiết kế cơ sở
===========================

.. kernel-doc:: drivers/gpu/drm/drm_gpusvm.c
   :doc: Overview

.. kernel-doc:: drivers/gpu/drm/drm_gpusvm.c
   :doc: Locking

.. kernel-doc:: drivers/gpu/drm/drm_gpusvm.c
   :doc: Partial Unmapping of Ranges

.. kernel-doc:: drivers/gpu/drm/drm_gpusvm.c
   :doc: Examples

Tổng quan về thiết kế drm_pagemap
=================================

.. kernel-doc:: drivers/gpu/drm/drm_pagemap.c
   :doc: Overview

.. kernel-doc:: drivers/gpu/drm/drm_pagemap.c
   :doc: Migration

Các tính năng thiết kế có thể có trong tương lai
================================================

* Lỗi GPU đồng thời
	* Các lỗi CPU xảy ra đồng thời nên có GPU đồng thời là điều hợp lý
	  lỗi.
	* Có thể thực hiện được với khóa chi tiết trong trình điều khiển GPU
	  người xử lý lỗi.
	* Không cần thay đổi GPU SVM dự kiến.
* Phạm vi với các trang thiết bị và hệ thống hỗn hợp
	* Có thể thêm nếu cần vào drm_gpusvm_get_pages khá dễ dàng.
* Hỗ trợ Multi-GPU
	* Công việc đang được tiến hành và các bản vá dự kiến sau khi hạ cánh lần đầu trên GPU
	  SVM.
	* Lý tưởng nhất là có thể thực hiện được mà không cần thay đổi nhiều đối với GPU SVM.
* Thả phạm vi theo hướng có lợi cho cây cơ số
	* Có thể mong muốn cho người thông báo nhanh hơn.
* Trang thiết bị phức hợp
	* Nvidia, AMD và Intel đều đã đồng ý về các chức năng MM lõi đắt tiền trong
	  lớp thiết bị di chuyển là một nút thắt cổ chai về hiệu suất, có sự kết hợp
	  trang thiết bị sẽ giúp tăng hiệu suất bằng cách giảm số lượng
	  của những cuộc gọi đắt tiền này.
* Ánh xạ DMA bậc cao hơn để di chuyển
	* Ánh xạ DMA 4k ảnh hưởng xấu đến hiệu suất di chuyển trên Intel
	  phần cứng, ánh xạ dma bậc cao hơn (2M) sẽ trợ giúp ở đây.
* Xây dựng triển khai userptr chung trên GPU SVM
* Chính sách di chuyển và triển khai bên tài xế điên cuồng
* Kéo các thay đổi API ánh xạ dma đang chờ xử lý từ Leon / Nvidia khi những vùng đất này