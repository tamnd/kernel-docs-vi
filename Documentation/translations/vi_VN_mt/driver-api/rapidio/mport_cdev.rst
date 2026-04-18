.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/rapidio/mport_cdev.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=======================================================================
Trình điều khiển thiết bị nhập ký tự của hệ thống con RapidIO (rio_mport_cdev.c)
==================================================================

1. Tổng quan
===========

Trình điều khiển thiết bị này là kết quả của sự hợp tác trong RapidIO.org
Nhóm tác vụ phần mềm (STG) giữa Texas Instruments, Freescale,
Công nghệ Prodrive, Mạng Nokia, BAE và IDT.  Đầu vào bổ sung là
nhận được từ các thành viên khác của RapidIO.org. Mục tiêu là tạo ra một
giao diện trình điều khiển chế độ ký tự thể hiện khả năng của RapidIO
thiết bị trực tiếp tới các ứng dụng, theo cách cho phép nhiều và
triển khai RapidIO khác nhau để tương tác.

Trình điều khiển này (MPORT_CDEV) cung cấp quyền truy cập vào các hoạt động cơ bản của hệ thống con RapidIO
cho các ứng dụng không gian người dùng. Hầu hết các hoạt động RapidIO đều được hỗ trợ thông qua
cuộc gọi hệ thống 'ioctl'.

Khi được tải, trình điều khiển thiết bị này sẽ tạo các nút hệ thống tệp có tên rio_mportX trong /dev
thư mục cho mỗi thiết bị nhập RapidIO đã đăng ký. 'X' trong tên nút khớp
tới ID cổng duy nhất được gán cho từng thiết bị nhập cục bộ.

Bằng cách sử dụng bộ lệnh ioctl có sẵn, các ứng dụng trong không gian người dùng có thể thực hiện
sau các hoạt động của hệ thống con và bus RapidIO:

- Đọc và ghi từ/đến các thanh ghi cấu hình của thiết bị nhập khẩu
  (RIO_MPORT_MAINT_READ_LOCAL/RIO_MPORT_MAINT_WRITE_LOCAL)
- Đọc và ghi từ/đến các thanh ghi cấu hình của thiết bị RapidIO từ xa.
  Hoạt động này được định nghĩa là đọc/ghi Bảo trì RapidIO trong thông số RIO.
  (RIO_MPORT_MAINT_READ_REMOTE/RIO_MPORT_MAINT_WRITE_REMOTE)
- Đặt ID đích RapidIO cho thiết bị nhập khẩu (RIO_MPORT_MAINT_HDID_SET)
- Đặt Thẻ thành phần RapidIO cho thiết bị mport (RIO_MPORT_MAINT_COMPTAG_SET)
- Truy vấn chỉ mục logic của thiết bị nhập khẩu (RIO_MPORT_MAINT_PORT_IDX_GET)
- Khả năng truy vấn và cấu hình liên kết RapidIO của thiết bị nhập khẩu
  (RIO_MPORT_GET_PROPERTIES)
- Bật/Tắt báo cáo các sự kiện chuông cửa RapidIO cho các ứng dụng trong không gian người dùng
  (RIO_ENABLE_DOORBELL_RANGE/RIO_DISABLE_DOORBELL_RANGE)
- Bật/Tắt báo cáo sự kiện ghi cổng RIO cho các ứng dụng trong không gian người dùng
  (RIO_ENABLE_PORTWRITE_RANGE/RIO_DISABLE_PORTWRITE_RANGE)
- Loại sự kiện truy vấn/điều khiển được báo cáo thông qua trình điều khiển này: chuông cửa,
  ghi cổng hoặc cả hai (RIO_SET_EVENT_MASK/RIO_GET_EVENT_MASK)
- Định cấu hình/Ánh xạ (các) cửa sổ yêu cầu gửi đi của mport cho kích thước cụ thể,
  ID đích RapidIO, số bước nhảy và loại yêu cầu
  (RIO_MAP_OUTBOUND/RIO_UNMAP_OUTBOUND)
- Định cấu hình/Ánh xạ (các) cửa sổ yêu cầu gửi đến của mport cho kích thước cụ thể,
  Địa chỉ cơ sở RapidIO và địa chỉ cơ sở bộ nhớ cục bộ
  (RIO_MAP_INBOUND/RIO_UNMAP_INBOUND)
- Phân bổ/miễn phí bộ đệm kết hợp DMA liền kề để truyền dữ liệu DMA
  đến/từ các thiết bị RapidIO từ xa (RIO_ALLOC_DMA/RIO_FREE_DMA)
- Bắt đầu truyền dữ liệu DMA đến/từ các thiết bị RapidIO từ xa (RIO_TRANSFER).
  Hỗ trợ dữ liệu chặn, không đồng bộ và được đăng (còn gọi là 'bắn và quên')
  các chế độ chuyển giao.
- Kiểm tra/Chờ hoàn tất truyền dữ liệu DMA không đồng bộ
  (RIO_WAIT_FOR_ASYNC)
- Quản lý các đối tượng thiết bị được hỗ trợ bởi hệ thống con RapidIO (RIO_DEV_ADD/RIO_DEV_DEL).
  Điều này cho phép thực hiện các thuật toán liệt kê vải RapidIO khác nhau
  như các ứng dụng trong không gian người dùng trong khi sử dụng chức năng còn lại được cung cấp bởi
  hệ thống con RapidIO hạt nhân.

2. Khả năng tương thích phần cứng
=========================

Trình điều khiển thiết bị này sử dụng các giao diện tiêu chuẩn được xác định bởi hệ thống con RapidIO kernel
và do đó nó có thể được sử dụng với bất kỳ trình điều khiển thiết bị mport nào được RapidIO đăng ký
hệ thống con với các giới hạn được đặt ra bởi việc triển khai nhập khẩu có sẵn.

Tại thời điểm này, hạn chế phổ biến nhất là tính sẵn có của RapidIO dành riêng cho
Khung công cụ DMA cho thiết bị nhập khẩu cụ thể. Người dùng nên xác minh có sẵn
chức năng của nền tảng của họ khi dự định sử dụng trình điều khiển này:

- Thiết bị cầu nối PCIe-to-RapidIO IDT Tsi721 và trình điều khiển thiết bị mport của nó có đầy đủ
  tương thích với trình điều khiển này.
- Trình điều khiển mport 'fsl_rio' của Freescale SoC không được triển khai cho RapidIO
  hỗ trợ công cụ DMA cụ thể và do đó truyền dữ liệu DMA trình điều khiển mport_cdev
  không có sẵn.

3. Thông số mô-đun
====================

- 'dma_timeout'
      - Hết thời gian chờ hoàn thành chuyển DMA (tính bằng msec, giá trị mặc định 3000).
        Tham số này đặt thời gian chờ hoàn thành tối đa cho chế độ SYNC DMA
        yêu cầu chuyển giao và cho các yêu cầu ioctl RIO_WAIT_FOR_ASYNC.

- 'dbg_level'
      - Tham số này cho phép kiểm soát lượng thông tin gỡ lỗi
        được tạo bởi trình điều khiển thiết bị này. Tham số này được hình thành bởi tập hợp
        mặt nạ bit tương ứng với các khối chức năng cụ thể.
        Để biết định nghĩa mặt nạ, hãy xem 'drivers/rapidio/devices/rio_mport_cdev.c'
        Tham số này có thể được thay đổi linh hoạt.
        Sử dụng CONFIG_RAPIDIO_DEBUG=y để bật đầu ra gỡ lỗi ở cấp cao nhất.

4. Các vấn đề đã biết
=================

Không có.

5. Ứng dụng không gian người dùng và API
==================================

Thư viện và ứng dụng API sử dụng trình điều khiển thiết bị này có sẵn từ
RapidIO.org.

6. Danh sách TODO
============

- Thêm hỗ trợ gửi/nhận gói tin nhắn RapidIO "thô".
- Thêm bộ nhớ được ánh xạ truyền dữ liệu DMA dưới dạng tùy chọn khi DMA dành riêng cho RapidIO
  không có sẵn.
