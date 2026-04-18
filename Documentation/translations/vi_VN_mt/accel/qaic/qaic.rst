.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/accel/qaic/qaic.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
 Trình điều khiển QAIC
======================

Trình điều khiển QAIC là Trình điều khiển chế độ hạt nhân (KMD) cho dòng AI AIC100
sản phẩm máy gia tốc.

Ngắt
==========

Giảm nhẹ bão IRQ
--------------------

Trong khi phần cứng Cầu AIC100 DMA thực hiện giảm thiểu bão IRQ
cơ chế này, vẫn có khả năng xảy ra bão IRQ. Một cơn bão có thể xảy ra
nếu khối lượng công việc đặc biệt nhanh và máy chủ phản hồi nhanh. Nếu chủ nhà
có thể rút hết phản hồi FIFO nhanh như thiết bị có thể chèn các phần tử vào
thì thiết bị sẽ thường xuyên chuyển phản hồi FIFO từ trống sang
không trống và tạo MSI với tốc độ tương đương với tốc độ của
khả năng xử lý đầu vào của khối lượng công việc. Lprnet (mạng đọc biển số xe)
khối lượng công việc được biết là gây ra tình trạng này và có thể tạo ra vượt quá 100 nghìn
MSI mỗi giây. Người ta đã quan sát thấy rằng hầu hết các hệ thống không thể chịu đựng được điều này
trong thời gian dài và sẽ sụp đổ do một số hình thức cơ quan giám sát do chi phí hoạt động quá cao
bộ điều khiển ngắt làm gián đoạn máy chủ CPU.

Để giảm thiểu vấn đề này, trình điều khiển QAIC triển khai xử lý IRQ cụ thể. Khi nào
QAIC nhận được IRQ, nó sẽ vô hiệu hóa dòng đó. Điều này ngăn chặn sự gián đoạn
bộ điều khiển làm gián đoạn CPU. Sau đó AIC xả FIFO. Một khi FIFO
cạn kiệt, QAIC thực hiện thuật toán thăm dò "cơ hội cuối cùng" trong đó QAIC sẽ
ngủ một lúc để xem liệu khối lượng công việc có tạo ra nhiều hoạt động hơn không. IRQ
dòng vẫn bị vô hiệu hóa trong thời gian này. Nếu không phát hiện thấy hoạt động nào, QAIC sẽ thoát
chế độ bỏ phiếu và kích hoạt lại dòng IRQ.

Việc giảm thiểu này trong QAIC rất hiệu quả. Cách sử dụng lprnet tương tự
tạo ra 100k IRQ mỗi giây (mỗi /proc/ngắt) giảm xuống còn khoảng 64
IRQ trên 5 phút trong khi vẫn giữ cho hệ thống máy chủ ổn định và có cùng
hiệu suất thông lượng khối lượng công việc (trong phạm vi biến đổi tiếng ồn từ lần chạy này sang lần chạy khác).

Chế độ MSI đơn
---------------

MultiMSI không được hỗ trợ tốt trên tất cả các hệ thống; những cái ảo hóa thậm chí còn ít hơn
(khoảng năm 2023). Giữa các trình ảo hóa che giấu cấu trúc khả năng PCIe MSI để
yêu cầu bộ nhớ lớn cho vIOMMU (cần thiết để hỗ trợ MultiMSI), đó là
hữu ích để có thể quay lại một MSI khi cần.

Để hỗ trợ dự phòng này, chúng tôi cho phép trường hợp chỉ có một MSI có thể
được phân bổ và chia sẻ một MSI đó giữa MHI và các DBC. Thiết bị phát hiện
khi chỉ có một MSI được cấu hình và chỉ đạo các ngắt cho DBC
tới ngắt thường được sử dụng cho MHI. Thật không may, điều này có nghĩa là
trình xử lý ngắt cho mỗi DBC và MHI thức dậy cho mỗi ngắt đó
đến; tuy nhiên, trình xử lý irq theo luồng DBC chỉ được khởi động khi công việc kết thúc.
done được phát hiện (MHI sẽ luôn khởi động trình xử lý luồng của nó).

Nếu DBC được cấu hình để buộc MSI bị gián đoạn, điều này có thể phá vỡ
phần mềm giảm bão IRQ đã đề cập ở trên. Vì MSI được chia sẻ nên nó
không bao giờ bị vô hiệu hóa, cho phép mỗi mục nhập mới vào FIFO kích hoạt một ngắt mới.


Giao thức điều khiển mạng thần kinh (NNC)
=====================================

Việc triển khai NNC được phân chia giữa KMD (QAIC) và UMD. Nói chung,
QAIC hiểu cách mã hóa/giải mã giao thức dây NNC và các thành phần của
giao thức yêu cầu kiến thức về không gian hạt nhân để xử lý (ví dụ: ánh xạ
bộ nhớ máy chủ vào IOVA của thiết bị). QAIC hiểu cấu trúc của tin nhắn và
tất cả các giao dịch. QAIC không hiểu lệnh (tải trọng của
giao dịch thông qua).

QAIC xử lý và thực thi độ bền cần thiết và căn chỉnh 64-bit,
đến mức có thể. Vì QAIC không biết nội dung của một
giao dịch thông qua, nó dựa vào UMD để đáp ứng các yêu cầu.

Giao dịch chấm dứt được sử dụng cụ thể cho QAIC. QAIC không biết về
các tài nguyên được tải vào thiết bị vì phần lớn hoạt động đó
xảy ra trong các lệnh NNC. Kết quả là QAIC không có phương tiện để
khôi phục hoạt động không gian người dùng. Để đảm bảo rằng tài nguyên của máy khách không gian người dùng
được phát hành đầy đủ trong trường hợp xảy ra sự cố quy trình hoặc có lỗi, QAIC sử dụng
lệnh chấm dứt để cho QSM biết khi nào người dùng rời đi và các tài nguyên
có thể được thả ra.

QSM có thể báo cáo số phiên bản của giao thức NNC mà nó hỗ trợ. Đây là trong
dạng số chính và số thứ.

Các cập nhật số chính cho thấy những thay đổi đối với giao thức NNC ảnh hưởng đến
định dạng tin nhắn hoặc giao dịch (tác động đến QAIC).

Cập nhật số nhỏ cho biết những thay đổi đối với giao thức NNC ảnh hưởng đến
lệnh (không ảnh hưởng đến QAIC).

uAPI
====

QAIC tạo một thiết bị tăng tốc cho mỗi thiết bị PCIe vật lý. Thiết bị tăng tốc này tồn tại
miễn là thiết bị PCIe được Linux biết đến.

Thiết bị PCIe có thể không ở trạng thái chấp nhận yêu cầu từ không gian người dùng tại
mọi lúc. QAIC sẽ kích hoạt các sự kiện KOBJ_ONLINE/OFFLINE để quảng cáo khi
thiết bị có thể chấp nhận yêu cầu (ONLINE) và khi thiết bị không còn chấp nhận
yêu cầu (OFFLINE) do thiết lập lại hoặc chuyển đổi trạng thái khác.

QAIC xác định một số IOCTL dành riêng cho trình điều khiển như một phần của không gian người dùng API.

DRM_IOCTL_QAIC_MANAGE
  IOCTL này cho phép không gian người dùng gửi yêu cầu NNC tới QSM. Cuộc gọi sẽ
  chặn cho đến khi nhận được phản hồi hoặc yêu cầu đã hết thời gian chờ.

DRM_IOCTL_QAIC_CREATE_BO
  IOCTL này cho phép không gian người dùng phân bổ một đối tượng bộ đệm (BO) có thể gửi
  hoặc nhận dữ liệu từ một khối lượng công việc. Cuộc gọi sẽ trả về một bộ điều khiển GEM
  đại diện cho bộ đệm được phân bổ. BO không thể sử dụng được cho đến khi nó được
  thái lát (xem DRM_IOCTL_QAIC_ATTACH_SLICE_BO).

DRM_IOCTL_QAIC_MMAP_BO
  IOCTL này cho phép không gian người dùng chuẩn bị BO được phân bổ để đưa vào
  quá trình không gian người dùng.

DRM_IOCTL_QAIC_ATTACH_SLICE_BO
  IOCTL này cho phép không gian người dùng cắt BO để chuẩn bị gửi BO
  tới thiết bị. Cắt lát là hoạt động mô tả những phần nào của BO
  được gửi đến nơi một khối lượng công việc. Điều này yêu cầu một bộ truyền DMA cho
  Cầu DMA và do đó, khóa BO với một DBC cụ thể.

DRM_IOCTL_QAIC_EXECUTE_BO
  IOCTL này cho phép không gian người dùng gửi một bộ BO được cắt lát tới thiết bị. các
  cuộc gọi không bị chặn. Thành công chỉ cho biết BO đã được xếp hàng
  vào thiết bị, nhưng không đảm bảo chúng đã được thực thi.

DRM_IOCTL_QAIC_PARTIAL_EXECUTE_BO
  IOCTL này hoạt động giống như DRM_IOCTL_QAIC_EXECUTE_BO, nhưng nó cho phép không gian người dùng
  để thu nhỏ BO được gửi tới thiết bị cho cuộc gọi cụ thể này. Nếu một BO
  thường có N đầu vào, nhưng chỉ có sẵn một tập hợp con trong số đó, IOCTL này
  cho phép không gian người dùng chỉ ra rằng chỉ M byte đầu tiên của BO mới được
  được gửi đến thiết bị để giảm thiểu chi phí truyền dữ liệu. IOCTL này động
  tính toán lại việc cắt và do đó có một số chi phí xử lý trước khi
  BO có thể được xếp hàng vào thiết bị.

DRM_IOCTL_QAIC_WAIT_BO
  IOCTL này cho phép không gian người dùng xác định khi nào một BO cụ thể được
  được thiết bị xử lý. Cuộc gọi sẽ bị chặn cho đến khi BO được
  được xử lý và có thể được xếp hàng lại vào thiết bị hoặc xảy ra thời gian chờ.

DRM_IOCTL_QAIC_PERF_STATS_BO
  IOCTL này cho phép không gian người dùng thu thập số liệu thống kê hiệu suất nhiều nhất
  việc thực hiện BO gần đây. Điều này cho phép không gian người dùng xây dựng từ đầu đến cuối
  dòng thời gian của quá trình xử lý BO để phân tích hiệu suất.

DRM_IOCTL_QAIC_DETACH_SLICE_BO
  IOCTL này cho phép không gian người dùng xóa thông tin cắt khỏi BO
  ban đầu được cung cấp bởi một cuộc gọi tới DRM_IOCTL_QAIC_ATTACH_SLICE_BO. Cái này
  là nghịch đảo của DRM_IOCTL_QAIC_ATTACH_SLICE_BO. BO phải nhàn rỗi trong
  DRM_IOCTL_QAIC_DETACH_SLICE_BO được gọi. Sau khi tách lát thành công
  hoạt động BO có thể có thông tin cắt lát mới được đính kèm với cuộc gọi mới
  tới DRM_IOCTL_QAIC_ATTACH_SLICE_BO. Sau khi tách lát cắt, BO không thể
  được thực hiện cho đến sau một thao tác lát đính kèm mới. Kết hợp lát đính kèm
  và tách các lệnh gọi lát cho phép không gian người dùng sử dụng BO với nhiều khối lượng công việc.

Cách ly máy khách không gian người dùng
==========================

AIC100 hỗ trợ nhiều khách hàng. Nhiều DBC có thể được sử dụng bởi một
khách hàng và nhiều khách hàng, mỗi khách hàng có thể sử dụng một hoặc nhiều DBC. Khối lượng công việc
có thể chứa thông tin nhạy cảm do đó chỉ có khách hàng sở hữu
khối lượng công việc phải được phép giao tiếp với DBC.

Khách hàng được xác định bởi phiên bản được liên kết với open() của họ. Một khách hàng
chỉ có thể sử dụng bộ nhớ mà chúng cấp phát và các DBC được gán cho chúng
khối lượng công việc. Những nỗ lực truy cập tài nguyên được chỉ định cho các máy khách khác sẽ bị
bị từ chối.

Thông số mô-đun
=================

QAIC hỗ trợ các tham số mô-đun sau:

ZZ0000ZZ

Định cấu hình QAIC để sử dụng chuỗi thăm dò cho các sự kiện đường dữ liệu thay vì dựa vào
trên thiết bị bị gián đoạn. Hữu ích cho các nền tảng có multiMSI bị hỏng. Phải là
được đặt ở khởi tạo trình điều khiển QAIC. Mặc định là 0 (tắt).

ZZ0000ZZ

Đặt giá trị thời gian chờ cho các hoạt động MHI tính bằng mili giây (ms). Phải được thiết lập
tại thời điểm người lái xe phát hiện một thiết bị. Mặc định là 2000 (2 giây).

ZZ0000ZZ

Đặt giá trị thời gian chờ cho phản hồi QSM đối với tin nhắn NNC tính bằng giây (giây). phải
được đặt tại thời điểm trình điều khiển gửi yêu cầu tới QSM. Mặc định là 60 (một
phút).

ZZ0000ZZ

Đặt thời gian chờ mặc định cho wait_exec ioctl tính bằng mili giây (ms). Phải là
được đặt trước lệnh gọi waic_exec ioctl. Một giá trị được chỉ định trong lệnh gọi ioctl
ghi đè điều này cho cuộc gọi đó. Mặc định là 5000 (5 giây).

ZZ0000ZZ

Đặt khoảng thời gian kiểm tra tính bằng micro giây (chúng tôi) khi kiểm tra đường dẫn dữ liệu đang hoạt động.
Có hiệu lực ở khoảng thời gian bỏ phiếu tiếp theo. Mặc định là 100 (100 us).

ZZ0000ZZ

Đặt khoảng thời gian tính bằng mili giây (ms) giữa hai lần đồng bộ hóa liên tiếp
hoạt động. Mặc định là 1000 (1000 mili giây).