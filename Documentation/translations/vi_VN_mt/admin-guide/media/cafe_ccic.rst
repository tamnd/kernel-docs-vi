.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/cafe_ccic.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Tài xế cafe_ccic
====================

Tác giả: Jonathan Corbet <corbet@lwn.net>

Giới thiệu
------------

"cafe_ccic" là driver cho máy ảnh Marvell 88ALP01 "cafe" CMOS
bộ điều khiển.  Đây là bộ điều khiển được tìm thấy trong các hệ thống OLPC thế hệ đầu tiên,
và trình điều khiển này được viết với sự hỗ trợ từ dự án OLPC.

Trạng thái hiện tại: trình điều khiển cốt lõi hoạt động.  Nó có thể tạo dữ liệu trong YUV422,
Các định dạng RGB565 và RGB444.  (Ai nhìn vào code sẽ thấy RGB32 là
tốt, nhưng đó là một công cụ hỗ trợ gỡ lỗi sẽ sớm bị xóa).  VGA và
Chế độ QVGA hoạt động; CIF vẫn có nhưng màu sắc vẫn vui nhộn.  Chỉ có OV7670
Cảm biến được biết là hoạt động với bộ điều khiển này vào thời điểm này.

Để dùng thử: một trong hai lệnh này sẽ hoạt động:

.. code-block:: none

     $ mplayer tv:// -tv driver=v4l2:width=640:height=480 -nosound
     $ mplayer tv:// -tv driver=v4l2:width=640:height=480:outfmt=bgr16 -nosound

Tiện ích "xawtv" cũng hoạt động; gqcam thì không, không rõ lý do.

Tùy chọn thời gian tải
-----------------

Có một số tùy chọn về thời gian tải, hầu hết có thể thay đổi sau
cũng tải qua sysfs:

- alloc_bufs_at_load: Thông thường driver sẽ không cấp phát DMA nào cả
   đệm cho đến lúc truyền dữ liệu.  Nếu tùy chọn này được đặt,
   thì bộ đệm có kích thước trong trường hợp xấu nhất sẽ được phân bổ tại thời điểm tải mô-đun.
   Tùy chọn này xác định bộ nhớ cho tuổi thọ của mô-đun, nhưng
   có lẽ làm giảm khả năng phân bổ thất bại sau này.

- dma_buf_size: Kích thước của bộ đệm DMA cần phân bổ.  Lưu ý rằng điều này
   tùy chọn chỉ được tư vấn để phân bổ thời gian tải; khi có bộ đệm
   được phân bổ vào thời gian chạy, chúng sẽ có kích thước phù hợp với hiện tại
   cài đặt máy ảnh.

- n_dma_bufs: Bộ điều khiển có thể chuyển qua hai hoặc ba DMA
   bộ đệm.  Thông thường, trình điều khiển cố gắng sử dụng ba bộ đệm; nhanh hơn
   tuy nhiên, nó sẽ hoạt động tốt chỉ với hai hệ thống.

- min_buffers: Số lượng bộ đệm I/O phát trực tuyến tối thiểu mà trình điều khiển
   sẽ đồng ý làm việc cùng.  Mặc định là một, nhưng trên các hệ thống chậm hơn,
   hành vi tốt hơn với mplayer có thể đạt được bằng cách cài đặt ở mức cao hơn
   giá trị (như sáu).

- max_buffers: Số lượng bộ đệm I/O phát trực tuyến tối đa; mặc định là
   mười.  Con số đó đã được chọn ra một cách cẩn thận và không nên
   được cho là thực sự có ý nghĩa nhiều về bất cứ điều gì.

- flip: Nếu tham số boolean này được đặt, cảm biến sẽ được hướng dẫn
   đảo ngược hình ảnh video.  Việc nó có hợp lý hay không được xác định bằng cách
   máy ảnh cụ thể của bạn đã được gắn.