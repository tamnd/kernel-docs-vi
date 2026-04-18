.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/designs/compress-accel.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================
Tăng tốc bộ đồng xử lý ALSA API
==================================

Jaroslav Kysela <perex@perex.cz>


Tổng quan
========

Có yêu cầu để lộ phần cứng âm thanh giúp tăng tốc nhiều loại
các tác vụ cho không gian người dùng như bộ chuyển đổi tốc độ mẫu, nén
bộ giải mã luồng, v.v.

Đây là mô tả cho tiện ích mở rộng API dành cho nén ALSA API
có thể xử lý các "nhiệm vụ" không bị ràng buộc với các hoạt động thời gian thực
và cho phép tuần tự hóa các hoạt động.

Yêu cầu
============

Các yêu cầu chính là:

- tuần tự hóa nhiều tác vụ cho không gian người dùng để cho phép nhiều
  hoạt động mà không cần sự can thiệp của không gian người dùng

- bộ đệm riêng biệt (đầu vào + đầu ra) cho mỗi thao tác

- hiển thị bộ đệm bằng mmap tới không gian người dùng

- báo hiệu không gian người dùng khi tác vụ kết thúc (cơ chế thăm dò tiêu chuẩn)

Thiết kế
======

Một hướng mới SND_COMPRESS_ACCEL được giới thiệu để xác định
thông qua API.

Tiện ích mở rộng API chia sẻ việc liệt kê thiết bị và xử lý tham số từ
API được nén chính. Tất cả các ioctls phát trực tuyến thời gian thực khác đều bị vô hiệu hóa
và một bộ ioctls liên quan đến nhiệm vụ mới được giới thiệu. tiêu chuẩn
Các hoạt động đọc/ghi/mmap I/O không được hỗ trợ trong thiết bị chuyển tiếp.

Việc xử lý trạng thái thiết bị ("luồng") được giảm xuống OPEN/SETUP. Tất cả khác
các trạng thái không có sẵn cho chế độ chuyển tiếp.

Cơ chế I/O dữ liệu sử dụng giao diện dma-buf tiêu chuẩn với đầy đủ ưu điểm
như mmap, I/O tiêu chuẩn, chia sẻ bộ đệm, v.v. Một bộ đệm được sử dụng cho
dữ liệu đầu vào và bộ đệm thứ hai (riêng biệt) được sử dụng cho dữ liệu đầu ra. Mỗi nhiệm vụ
có bộ đệm I/O riêng biệt.

Đối với các tham số bộ đệm, các đoạn có nghĩa là giới hạn các tác vụ được phân bổ
cho thiết bị nhất định. Fragment_size giới hạn kích thước bộ đệm đầu vào cho
thiết bị. Kích thước bộ đệm đầu ra được xác định bởi trình điều khiển (có thể khác
từ kích thước bộ đệm đầu vào).

Máy trạng thái
=============

Máy trạng thái luồng âm thanh truyền qua được mô tả bên dưới::

+----------+
                                       ZZ0000ZZ
                                       ZZ0001ZZ
                                       ZZ0002ZZ
                                       +----------+
                                             |
                                             |
                                             | compr_set_params()
                                             |
                                             v
         tất cả các nhiệm vụ chuyển tiếp +----------+
  +-----------------------------------ZZ0003ZZ
  ZZ0004ZZ SETUP |
  ZZ0005ZZ
  |                                    +----------+
  ZZ0006ZZ
  +------------------------------------------+


Hoạt động truyền qua (ioctls)
===============================

Tất cả các hoạt động được bảo vệ bằng cách sử dụng luồng->thiết bị->khóa (mutex).

CREATE
------
Tạo một bộ đệm đầu vào/đầu ra. Kích thước bộ đệm đầu vào là
mảnh_size. Phân bổ seqno duy nhất.

Trình điều khiển phần cứng phân bổ 'struct dma_buf' bên trong cho cả đầu vào và
bộ đệm đầu ra (sử dụng hàm 'dma_buf_export()'). Người vô danh
bộ mô tả tệp cho các bộ đệm đó được chuyển đến không gian người dùng.

FREE
----
Giải phóng một bộ đệm đầu vào/đầu ra. Nếu một tác vụ đang hoạt động thì dừng
hoạt động được thực hiện trước đó. Nếu seqno bằng 0, thao tác được thực hiện cho tất cả
nhiệm vụ.

START
-----
Bắt đầu (xếp hàng) một nhiệm vụ. Có hai trường hợp nhiệm vụ bắt đầu - ngay sau
nhiệm vụ được tạo ra. Trong trường hợp này, Origin_seqno phải bằng 0.
Trường hợp thứ hai là sử dụng lại tác vụ đã hoàn thành. Nguồn gốc_seqno
phải xác định nhiệm vụ sẽ được sử dụng lại. Trong cả hai trường hợp, một giá trị seqno mới
được phân bổ và trả về không gian người dùng.

Điều kiện tiên quyết là ứng dụng phải chứa bộ đệm dma đầu vào với
dữ liệu nguồn mới và đặt input_size để chuyển kích thước dữ liệu thực cho trình điều khiển.

Thứ tự xử lý dữ liệu được giữ nguyên (công việc bắt đầu đầu tiên phải được
lúc đầu là xong).

Nếu nhiều tác vụ yêu cầu xử lý trạng thái (ví dụ: thao tác lấy mẫu lại),
không gian người dùng có thể đặt cờ SND_COMPRESS_TFLG_NEW_STREAM để đánh dấu
bắt đầu dữ liệu luồng mới. Sẽ rất hữu ích khi giữ các bộ đệm được phân bổ
cho hoạt động mới thay vì sử dụng cơ chế đóng/mở.

STOP
----
Dừng (dequeues) một nhiệm vụ. Nếu seqno bằng 0, thao tác được thực hiện cho tất cả
nhiệm vụ.

STATUS
------
Nhận trạng thái nhiệm vụ (đang hoạt động, đã hoàn thành). Ngoài ra, trình điều khiển sẽ thiết lập
kích thước dữ liệu đầu ra thực (vùng hợp lệ trong bộ đệm đầu ra).

Tín dụng
=======
- Vương Thịnh Cửu <shengjiu.wang@gmail.com>
- Takashi Iwai <tiwai@suse.de>
- Vinod Koul <vkoul@kernel.org>
