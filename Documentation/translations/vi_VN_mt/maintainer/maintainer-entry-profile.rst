.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/maintainer/maintainer-entry-profile.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _maintainerentryprofile:

Hồ sơ đăng nhập của người bảo trì
========================

Hồ sơ mục nhập của người bảo trì bổ sung cho các tài liệu quy trình cấp cao nhất
(gửi-bản vá, gửi trình điều khiển...) với
hệ thống con/trình điều khiển thiết bị-địa phương cũng như thông tin chi tiết về bản vá
vòng đời đệ trình. Một người đóng góp sử dụng tài liệu này để thiết lập cấp độ
mong đợi của họ và tránh những sai lầm thường gặp; người bảo trì có thể sử dụng những thứ này
hồ sơ để xem xét các hệ thống con để có cơ hội hội tụ
thực tiễn chung.


Tổng quan
--------
Cung cấp phần giới thiệu về cách hoạt động của hệ thống con. Trong khi MAINTAINERS
cho người đóng góp biết nơi gửi bản vá cho tệp nào, nhưng nó không
truyền tải cơ sở hạ tầng và cơ chế hệ thống con-cục bộ khác hỗ trợ
sự phát triển.

Các câu hỏi ví dụ cần xem xét:

- Có thông báo khi các bản vá được áp dụng cho cây cục bộ hay không
  sáp nhập ngược dòng?
- Hệ thống con có phiên bản chắp vá không? Là trạng thái chắp vá
  những thay đổi được thông báo?
- Bất kỳ cơ sở hạ tầng bot hoặc CI nào theo dõi danh sách hoặc tự động
  kiểm tra phản hồi mà hệ thống con sử dụng để chấp nhận cổng?
- Các nhánh Git được kéo vào -next?
- Những người đóng góp nên nộp đơn chống lại chi nhánh nào?
- Liên kết tới bất kỳ Hồ sơ nhập Người bảo trì nào khác? Ví dụ một
  trình điều khiển thiết bị có thể trỏ đến một mục nhập cho hệ thống con mẹ của nó. Điều này làm cho
  người đóng góp nhận thức được các nghĩa vụ mà người bảo trì có thể có đối với
  những người bảo trì khác trong chuỗi trình.


Gửi phụ lục danh sách kiểm tra
-------------------------
Liệt kê các tiêu chí bắt buộc và tư vấn, ngoài "danh sách kiểm tra gửi" chung
để một bản vá được coi là đủ tốt để thu hút sự chú ý của người bảo trì.
Ví dụ: "vượt qua checkpatch.pl không có lỗi hoặc cảnh báo. Vượt qua
kiểm tra đơn vị chi tiết ở mức $URI".

Phụ lục Danh sách kiểm tra Gửi cũng có thể bao gồm thông tin chi tiết về trạng thái
thông số kỹ thuật phần cứng liên quan. Ví dụ, hệ thống con
yêu cầu các thông số kỹ thuật được công bố ở một bản sửa đổi nhất định trước khi vá lỗi
sẽ được xem xét.


Ngày chu kỳ chính
---------------
Một trong những hiểu lầm phổ biến của người gửi là các bản vá có thể được
được gửi bất cứ lúc nào trước khi cửa sổ hợp nhất đóng lại và vẫn có thể được
được xem xét cho -rc1 tiếp theo. Thực tế là hầu hết các bản vá cần phải
được giải quyết bằng cách ngâm trong linux-next trước cửa sổ hợp nhất
khai mạc. Làm rõ cho người gửi những ngày quan trọng (về mặt phát hành -rc
tuần) các bản vá đó có thể được xem xét để hợp nhất và khi các bản vá cần
đợi -rc tiếp theo. Tối thiểu:

- -rc cuối cùng để gửi tính năng mới:

Việc gửi tính năng mới nhắm mục tiêu vào cửa sổ hợp nhất tiếp theo phải có
  bài đăng đầu tiên của họ để xem xét trước thời điểm này. Bản vá đó
  được gửi sau thời điểm này phải rõ ràng rằng họ đang nhắm mục tiêu
  cửa sổ hợp nhất NEXT+1 hoặc phải có lý do chính đáng
  tại sao chúng nên được xem xét theo một lịch trình nhanh chóng. Một vị tướng
  nguyên tắc là đặt kỳ vọng với những người đóng góp rằng tính năng mới
  bài nộp phải xuất hiện trước -rc5.

- Last -rc to merge feature: Hạn chót đưa ra quyết định hợp nhất

Cho những người đóng góp biết thời điểm mà bản vá chưa được áp dụng
  set sẽ cần đợi cửa sổ hợp nhất NEXT+1. Tất nhiên là không có
  nghĩa vụ phải chấp nhận bất kỳ bản vá nào, nhưng nếu việc đánh giá không
  đã kết luận vào thời điểm này, kỳ vọng là người đóng góp nên chờ đợi và
  gửi lại cho cửa sổ hợp nhất sau.

Không bắt buộc:

- Đầu tiên -rc tại đó nhánh đường cơ sở phát triển, được liệt kê trong phần
  phần tổng quan, nên được coi là đã sẵn sàng cho các bài nộp mới.


Xem lại nhịp
--------------
Một trong những nguồn gây lo lắng lớn nhất cho cộng tác viên là việc ping sẽ sớm diễn ra như thế nào
sau khi một bản vá đã được đăng mà không nhận được bất kỳ phản hồi nào. trong
ngoài việc chỉ định thời gian chờ đợi trước khi gửi lại
cũng có thể chỉ ra kiểu cập nhật ưa thích như gửi lại
toàn bộ chuỗi hoặc gửi email nhắc nhở riêng. Phần này cũng có thể
liệt kê cách thức hoạt động của quá trình đánh giá đối với vùng mã này và các phương pháp để nhận phản hồi
không trực tiếp từ người bảo trì.

Hồ sơ hiện có
-----------------

Hiện tại, hồ sơ người bảo trì hiện có được liệt kê ở đây; chúng tôi có thể sẽ muốn
làm điều gì đó khác biệt trong tương lai gần.

.. toctree::
   :maxdepth: 1

   ../doc-guide/maintainer-profile
   ../nvdimm/maintainer-entry-profile
   ../arch/riscv/patch-acceptance
   ../process/maintainer-soc
   ../process/maintainer-soc-clean-dts
   ../driver-api/media/maintainer-entry-profile
   ../process/maintainer-netdev
   ../driver-api/vfio-pci-device-specific-driver-acceptance
   ../nvme/feature-and-quirk-policy
   ../filesystems/nfs/nfsd-maintainer-entry-profile
   ../filesystems/xfs/xfs-maintainer-entry-profile
   ../mm/damon/maintainer-profile
