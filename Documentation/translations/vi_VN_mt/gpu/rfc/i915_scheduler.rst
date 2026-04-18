.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/gpu/rfc/i915_scheduler.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================
Phần gửi GuC I915/Phần lập lịch DRM
=============================================

Kế hoạch thượng nguồn
=============
Đối với kế hoạch tổng thể về việc gửi GuC và tích hợp thượng nguồn
i915 với bộ lập lịch DRM là:

* Hợp nhất việc gửi GuC cơ bản
	* Hỗ trợ gửi cơ bản cho tất cả các nền tảng gen11+
	* Không được bật theo mặc định trên bất kỳ nền tảng hiện tại nào nhưng có thể được bật qua
	  modparam kích hoạt_guc
	* Sẽ cần phải làm lại rất nhiều để tích hợp với bộ lập lịch DRM
	  không cần phải chọn mọi thứ trong mã, nó chỉ cần như vậy
	  hoạt động tốt, không có lỗi mã hóa/phân lớp lớn và không bị thoái lui
	  những người thực thi
	* Cập nhật IGT / bản tự kiểm tra khi cần để hoạt động với việc gửi GuC
	* Kích hoạt CI trên các nền tảng được hỗ trợ cho đường cơ sở
	* Làm lại / nhận CI một cách nhiệt tình để gửi GuC tại chỗ khi cần
* Hợp nhất uAPI gửi song song mới
	* Liên kết uAPI hoàn toàn không tương thích với việc gửi GuC, ngoài ra nó còn có
	  vấn đề thiết kế nghiêm trọng nói chung, đó là lý do tại sao chúng tôi muốn ngừng sử dụng nó.
	  vấn đề gì
	* uAPI mới bổ sung bước thiết lập ngữ cảnh I915_CONTEXT_ENGINES_EXT_PARALLEL
	  cấu hình một vị trí có N bối cảnh
	* Sau I915_CONTEXT_ENGINES_EXT_PARALLEL, người dùng có thể gửi N đợt tới
	  một khe trong một execbuf IOCTL duy nhất và các lô chạy trên GPU trong
	  song song
	* Ban đầu chỉ dành cho việc gửi GuC nhưng những người thực thi có thể được hỗ trợ nếu
	  cần thiết
* Chuyển đổi i915 để sử dụng bộ lập lịch DRM
	* Phần phụ trợ gửi GuC được tích hợp hoàn toàn với bộ lập lịch DRM
		* Tất cả các hàng đợi yêu cầu đã bị xóa khỏi phần phụ trợ (ví dụ: tất cả các hàng đợi áp lực ngược
		  được xử lý trong bộ lập lịch DRM)
		* Đặt lại / hủy móc trong bộ lập lịch DRM
		* Watchdog móc vào bộ lập lịch DRM
		* Rất nhiều sự phức tạp của phần phụ trợ GuC có thể được loại bỏ một lần
		  được tích hợp với bộ lập lịch DRM (ví dụ: máy trạng thái được
		  đơn giản hơn, việc khóa trở nên đơn giản hơn, v.v...)
	* Phần phụ trợ của Execlists sẽ được yêu cầu ở mức tối thiểu để kết nối với bộ lập lịch DRM
		* Giao diện kế thừa
		* Các tính năng như chia thời gian / ưu tiên / công cụ ảo sẽ
		  khó tích hợp với bộ lập lịch DRM và những thứ này
		  các tính năng không bắt buộc phải có khi gửi GuC như GuC đã làm
		  những điều này cho chúng ta
		* ROI chưa tích hợp đầy đủ vào bộ lập lịch DRM
		* Tích hợp đầy đủ sẽ tăng thêm nhiều độ phức tạp cho DRM
		  người lập kế hoạch
	* Tính năng kế thừa / tăng cường ưu tiên cổng i915 trong bộ lập lịch DRM
		* Được sử dụng để lật trang i915, có thể hữu ích cho các trình điều khiển DRM khác như
		  à
		* Sẽ là một tính năng tùy chọn trong bộ lập lịch DRM
	* Xóa các giả định hoàn thành theo thứ tự khỏi bộ lập lịch DRM
		* Ngay cả khi sử dụng bộ lập lịch DRM, phần phụ trợ sẽ xử lý
		  quyền ưu tiên, chia thời gian, v.v... để các công việc có thể
		  kết thúc không theo thứ tự
	* Rút ra các mức ưu tiên của i915 và sử dụng các mức ưu tiên của DRM
	* Tối ưu hóa bộ lập lịch DRM khi cần

TODO để gửi GuC ngược dòng
=================================

* Cần cập nhật lên firmware GuC / i915 để bật tính năng ghi trạng thái lỗi
* Công cụ nguồn mở để giải mã nhật ký GuC
* Thông số GuC công khai

uAPI mới để gửi GuC cơ bản
=================================
Không có thay đổi lớn nào được yêu cầu đối với uAPI để gửi GuC cơ bản. duy nhất
thay đổi là thuộc tính lập lịch mới: I915_SCHEDULER_CAP_STATIC_PRIORITY_MAP.
Thuộc tính này cho biết mức độ ưu tiên của người dùng i915 2k được ánh xạ tĩnh
thành 3 cấp độ như sau:

* -1k đến -1 Mức độ ưu tiên thấp
* 0 Ưu tiên trung bình
* Ưu tiên cao 1 đến 1k

Điều này là cần thiết vì GuC chỉ có 4 băng tần ưu tiên. Ưu tiên cao nhất
băng tần được dành riêng cho kernel. Điều này phù hợp với mức độ ưu tiên của bộ lập lịch DRM
cấp độ quá.

Thông số tham khảo:
----------------
* ZZ0000ZZ
* ZZ0001ZZ
* ZZ0002ZZ

uAPI gửi song song mới
============================
UAPI liên kết hiện tại hoàn toàn bị hỏng khi gửi GuC vì
không biết liệu một lần gửi là một lần gửi theo ngữ cảnh hay gửi song song
cho đến khi thời gian execbuf được kích hoạt thông qua I915_SUBMIT_FENCE. Để gửi nhiều
bối cảnh song song với GuC, bối cảnh phải được đăng ký rõ ràng với
N bối cảnh và tất cả N bối cảnh phải được gửi trong một lệnh duy nhất tới GuC.
Giao diện GuC không hỗ trợ thay đổi linh hoạt giữa N bối cảnh vì
liên kết uAPI nào. Do đó cần có một giao diện trình song song mới. Ngoài ra
uAPI liên kết kế thừa khá khó hiểu và không trực quan chút nào. Hơn nữa
I915_SUBMIT_FENCE được thiết kế như một hàng rào trong tương lai, vì vậy chúng tôi không thực sự nên làm điều gì đó
tiếp tục ủng hộ.

UAPI gửi song song mới bao gồm 3 phần:

* Xuất bản đồ logic của động cơ
* Tiện ích mở rộng 'set_parallel' để định cấu hình ngữ cảnh song song
  trình
* Mở rộng execbuf2 IOCTL để hỗ trợ gửi N BB trong một IOCTL duy nhất

Xuất bản đồ logic của công cụ
------------------------------
Một số trường hợp sử dụng nhất định yêu cầu đặt BB trên phiên bản công cụ theo thứ tự hợp lý
(ví dụ: chia khung trên gen11+). Ánh xạ logic của các phiên bản động cơ có thể thay đổi
dựa trên sự kết hợp. Thay vì làm cho UMD nhận thức được việc kết hợp, chỉ cần hiển thị
ánh xạ logic với thông tin công cụ truy vấn hiện có IOCTL. Ngoài ra còn có GuC
giao diện gửi hiện chỉ hỗ trợ gửi nhiều ngữ cảnh tới
động cơ theo thứ tự hợp lý là một yêu cầu mới so với các nhà thực thi.
Cuối cùng, tất cả các nền tảng hiện tại đều có tối đa 2 phiên bản công cụ và logic
thứ tự giống như thứ tự uAPI. Điều này sẽ thay đổi trên các nền tảng có nhiều hơn 2
trường hợp động cơ.

Một bit sẽ được thêm vào drm_i915_engine_info.flags cho biết rằng
phiên bản logic đã được trả về và một trường mới,
drm_i915_engine_info.logic_instance, trả về phiên bản logic.

Tiện ích mở rộng 'set_parallel' để định cấu hình ngữ cảnh cho việc gửi song song
------------------------------------------------------------------------
Tiện ích mở rộng 'set_parallel' định cấu hình một vị trí để gửi song song N BB.
Đây là bước thiết lập phải được gọi trước khi sử dụng bất kỳ ngữ cảnh nào. Xem
I915_CONTEXT_ENGINES_EXT_LOAD_BALANCE hoặc I915_CONTEXT_ENGINES_EXT_BOND cho
ví dụ tương tự hiện có. Khi một vị trí được định cấu hình để gửi song song,
execbuf2 IOCTL có thể được gọi là gửi N BB trong một IOCTL duy nhất. Ban đầu chỉ
hỗ trợ gửi GuC. Hỗ trợ Execlists có thể được thêm vào sau nếu cần.

Thêm I915_CONTEXT_ENGINES_EXT_PARALLEL_SUBMIT và
drm_i915_context_engines_parallel_submit tới uAPI để triển khai điều này
phần mở rộng.

.. c:namespace-push:: rfc

.. kernel-doc:: include/uapi/drm/i915_drm.h
        :functions: i915_context_engines_parallel_submit

.. c:namespace-pop::

Mở rộng execbuf2 IOCTL để hỗ trợ gửi N BB trong một IOCTL duy nhất
-------------------------------------------------------------------
Các bối cảnh đã được định cấu hình bằng tiện ích mở rộng 'set_parallel' chỉ có thể
gửi N BB trong một execbuf2 IOCTL duy nhất. BB là N đối tượng cuối cùng
trong danh sách drm_i915_gem_exec_object2 hoặc N đầu tiên nếu I915_EXEC_BATCH_FIRST là
thiết lập. Số lượng BB được ẩn dựa trên vị trí được gửi và cách thức nó có
đã được định cấu hình bởi 'set_parallel' hoặc các tiện ích mở rộng khác. Không có thay đổi uAPI nào
được yêu cầu đối với execbuf2 IOCTL.
