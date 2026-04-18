.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/firmware/firmware_cache.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================
Bộ đệm chương trình cơ sở
==============

Khi Linux tiếp tục tạm dừng một số trình điều khiển thiết bị yêu cầu tra cứu chương trình cơ sở để
khởi tạo lại thiết bị. Trong quá trình tiếp tục, có thể có một khoảng thời gian trong đó
không thể tra cứu phần sụn, trong khoảng thời gian ngắn này phần sụn
yêu cầu sẽ thất bại. Tuy nhiên, thời gian là điều cốt yếu và việc trì hoãn các tài xế để chờ đợi
hệ thống tập tin gốc của chương trình cơ sở làm trì hoãn trải nghiệm của người dùng với thiết bị
chức năng. Để hỗ trợ những yêu cầu này, phần sụn
cơ sở hạ tầng triển khai bộ đệm chương trình cơ sở cho trình điều khiển thiết bị cho hầu hết API
cuộc gọi, tự động ở hậu trường.

Bộ đệm chương trình cơ sở giúp việc sử dụng các cuộc gọi API chương trình cơ sở nhất định trở nên an toàn trong thiết bị
tài xế tạm dừng và tiếp tục gọi lại.  Người dùng các cuộc gọi API này không cần lưu vào bộ nhớ đệm
chương trình cơ sở để xử lý tình trạng mất chương trình cơ sở trong quá trình khôi phục hệ thống.

Bộ nhớ đệm chương trình cơ sở hoạt động bằng cách yêu cầu chương trình cơ sở trước khi tạm dừng và
lưu trữ nó trong bộ nhớ. Khi khôi phục trình điều khiển thiết bị bằng phần sụn API sẽ
có quyền truy cập vào phần sụn ngay lập tức mà không cần phải chờ root
hệ thống tập tin để gắn kết hoặc xử lý các vấn đề về chủng tộc có thể xảy ra bằng cách tra cứu dưới dạng
gắn kết hệ thống tập tin gốc.

Một số chi tiết triển khai về thiết lập bộ nhớ đệm chương trình cơ sở:

* Bộ nhớ đệm chương trình cơ sở được thiết lập bằng cách thêm mục nhập dành cho nhà phát triển cho mỗi thiết bị
  sử dụng tất cả cuộc gọi đồng bộ ngoại trừ ZZ0000ZZ.

* Nếu sử dụng cuộc gọi không đồng bộ, bộ đệm chương trình cơ sở chỉ được thiết lập cho
  thiết bị nếu đối số thứ hai (uevent) của request_firmware_nowait() là
  đúng. Khi sự kiện đúng, nó yêu cầu gửi một sự kiện kobject tới
  không gian người dùng cho yêu cầu phần sụn thông qua cơ chế dự phòng sysfs
  nếu không tìm thấy tập tin phần sụn.

* Nếu bộ nhớ đệm chương trình cơ sở được xác định là cần thiết theo hai điều trên
  tiêu chí bộ đệm chương trình cơ sở được thiết lập bằng cách thêm mục nhập devres cho
  thiết bị thực hiện yêu cầu phần sụn.

* Mục nhập nhà phát triển chương trình cơ sở được duy trì trong suốt thời gian sử dụng của
  thiết bị. Điều này có nghĩa là ngay cả khi bạn phát hành_firmware() bộ nhớ đệm chương trình cơ sở
  sẽ vẫn được sử dụng trong sơ yếu lý lịch sau khi tạm dừng.

* Thời gian chờ của cơ chế dự phòng tạm thời giảm xuống còn 10 giây
  vì bộ đệm chương trình cơ sở được thiết lập trong quá trình tạm dừng, thời gian chờ được đặt lại thành
  giá trị cũ bạn đã định cấu hình sau khi thiết lập bộ đệm.

* Sau khi tạm dừng mọi yêu cầu chương trình cơ sở không chính xác đang chờ xử lý sẽ bị hủy để tránh
  trì hoãn kernel, việc này được thực hiện bằng kill_requests_without_uevent(). hạt nhân
  do đó các cuộc gọi yêu cầu không phải sự kiện cần phải triển khai chương trình cơ sở của riêng chúng
  cơ chế bộ đệm nhưng không được sử dụng phần sụn API khi tạm dừng.

