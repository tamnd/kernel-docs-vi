.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/i2c/dma-considerations.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===================
Linux I2C và DMA
=================

Cho rằng I2C là một bus tốc độ thấp, qua đó phần lớn các tin nhắn
được chuyển nhỏ, nó không được coi là người dùng chính của quyền truy cập DMA. Lúc này
tại thời điểm viết bài, chỉ 10% trình điều khiển chính xe buýt I2C có hỗ trợ DMA
được thực hiện. Và phần lớn các giao dịch rất nhỏ nên việc thiết lập
DMA vì nó có thể sẽ tăng thêm chi phí so với chuyển PIO đơn giản.

Do đó, ZZ0000ZZ bắt buộc bộ đệm của thông báo I2C phải an toàn với DMA.
Có vẻ không hợp lý khi áp dụng thêm gánh nặng khi tính năng này là như vậy
hiếm khi được sử dụng. Tuy nhiên, bạn nên sử dụng bộ đệm an toàn DMA nếu
kích thước tin nhắn có thể áp dụng cho DMA. Hầu hết các trình điều khiển đều có ngưỡng này
khoảng 8 byte (tuy nhiên, tính đến ngày hôm nay, đây chủ yếu là phỏng đoán có cơ sở). cho
bất kỳ tin nhắn nào có kích thước 16 byte hoặc lớn hơn, đó có thể là một ý tưởng thực sự hay. làm ơn
lưu ý rằng các hệ thống con khác mà bạn sử dụng có thể bổ sung thêm yêu cầu. Ví dụ: nếu bạn
Trình điều khiển chính xe buýt I2C đang sử dụng USB làm cầu nối thì bạn cần phải có DMA
bộ đệm luôn an toàn vì USB yêu cầu nó.

Khách hàng
-------

Đối với khách hàng, nếu bạn sử dụng bộ đệm an toàn DMA trong i2c_msg, hãy đặt I2C_M_DMA_SAFE
gắn cờ với nó. Sau đó, lõi I2C và trình điều khiển biết rằng họ có thể vận hành DMA một cách an toàn
trên đó. Lưu ý rằng việc sử dụng cờ này là tùy chọn. Trình điều khiển máy chủ I2C không
được cập nhật để sử dụng cờ này sẽ hoạt động như trước. Và giống như trước đây, họ mạo hiểm
sử dụng bộ đệm DMA không an toàn. Để cải thiện tình trạng này, sử dụng I2C_M_DMA_SAFE trong
ngày càng nhiều khách hàng và trình điều khiển máy chủ là con đường đã được lên kế hoạch. Cũng lưu ý
việc đặt cờ này chỉ có ý nghĩa trong không gian kernel. Dữ liệu không gian người dùng được
dù sao cũng được sao chép vào không gian kernel. Lõi I2C đảm bảo đích đến
bộ đệm trong không gian kernel luôn có khả năng DMA. Ngoài ra, khi lõi mô phỏng
Giao dịch SMBus qua I2C, bộ đệm để chuyển khối là DMA an toàn. Người dùng
của các hàm i2c_master_send() và i2c_master_recv() hiện có thể sử dụng DMA an toàn
các biến thể (i2c_master_send_dmasafe() và i2c_master_recv_dmasafe()) khi chúng
biết bộ đệm của họ là DMA an toàn. Người dùng i2c_transfer() phải đặt
Cờ I2C_M_DMA_SAFE theo cách thủ công.

Thạc sĩ
-------

Trình điều khiển chính xe buýt muốn triển khai DMA an toàn có thể sử dụng các chức năng trợ giúp từ
lõi I2C. Một cung cấp cho bạn bộ đệm an toàn DMA cho i2c_msg nhất định miễn là
ngưỡng nhất định được đáp ứng::

dma_buf = i2c_get_dma_safe_msg_buf(tin nhắn, ngưỡng_in_byte);

Nếu một bộ đệm được trả về, nó sẽ là msg->buf cho trường hợp I2C_M_DMA_SAFE hoặc một
bộ đệm bị trả lại. Nhưng bạn không cần quan tâm tới chi tiết đó mà chỉ cần sử dụng
bộ đệm được trả về. Nếu NULL được trả về, ngưỡng không được đáp ứng hoặc bị trả lại
bộ đệm không thể được phân bổ. Quay trở lại PIO trong trường hợp đó.

Trong mọi trường hợp, bộ đệm thu được từ trên cần phải được giải phóng. Một người trợ giúp khác
đảm bảo bộ đệm thoát có khả năng được sử dụng sẽ được giải phóng ::

i2c_put_dma_safe_msg_buf(dma_buf, msg, xferred);

Đối số cuối cùng 'xferred' kiểm soát xem bộ đệm có được đồng bộ hóa trở lại
tin nhắn hay không. Không cần đồng bộ trong trường hợp thiết lập DMA gặp lỗi và
không có dữ liệu được chuyển giao.

Việc xử lý bộ đệm thoát từ lõi rất chung chung và đơn giản. Nó sẽ luôn luôn
cấp phát một bộ đệm thoát mới. Nếu bạn muốn xử lý phức tạp hơn (ví dụ:
sử dụng lại bộ đệm được cấp phát trước), bạn có thể tự do triển khai bộ đệm của riêng mình.

Ngoài ra, vui lòng kiểm tra tài liệu trong kernel để biết chi tiết. I2c-sh_mobile
trình điều khiển có thể được sử dụng làm ví dụ tham khảo về cách sử dụng các trình trợ giúp trên.

Lưu ý cuối cùng: Nếu bạn dự định sử dụng DMA với I2C (hoặc thực tế là với bất kỳ thứ gì khác)
đảm bảo bạn đã bật CONFIG_DMA_API_DEBUG trong quá trình phát triển. Nó có thể giúp
bạn tìm thấy nhiều vấn đề khác nhau có thể phức tạp để gỡ lỗi.
