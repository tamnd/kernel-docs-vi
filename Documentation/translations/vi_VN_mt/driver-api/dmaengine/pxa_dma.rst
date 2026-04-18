.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/dmaengine/pxa_dma.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================
PXA/MMP - Bộ điều khiển phụ DMA
==============================

Hạn chế
===========

a) Chuyển hàng đợi nóng
Người lái xe nộp đơn chuyển nhượng và phát hành nó phải được cấp giấy chuyển nhượng
được xếp hàng ngay cả trên kênh DMA đang chạy.
Điều này ngụ ý rằng việc xếp hàng không đợi kết thúc chuyển giao trước đó,
và việc xâu chuỗi bộ mô tả không chỉ được thực hiện trong mã irq/tasklet
được kích hoạt khi kết thúc quá trình chuyển giao.
Chuyển khoản được gửi và phát hành trên phy không đợi phy thực hiện
dừng và khởi động lại, nhưng được gửi trên "kênh đang chạy". Cái khác
trình điều khiển, đặc biệt là mmp_pdma đợi phy dừng trước khi khởi chạy lại
một cuộc chuyển giao mới.

b) Tất cả các giao dịch chuyển tiền có yêu cầu xác nhận đều phải được báo hiệu
Bất kỳ chuyển khoản nào được phát hành với DMA_PREP_INTERRUPT sẽ kích hoạt cuộc gọi lại.
Điều này ngụ ý rằng ngay cả khi một irq/tasklet được kích hoạt vào cuối tx1, nhưng
tại thời điểm irq/dma tx2 đã hoàn tất, tx1->complete() và
tx2->complete() nên được gọi.

c) Trạng thái chạy kênh
Trình điều khiển sẽ có thể truy vấn xem kênh có đang chạy hay không. Đối với
trường hợp đa phương tiện, chẳng hạn như quay video, nếu truyền được gửi và sau đó
việc kiểm tra kênh DMA báo cáo "kênh đã dừng", quá trình truyền sẽ
không được phát hành cho đến lần "bắt đầu ngắt khung" tiếp theo, do đó cần phải
biết kênh đang ở trạng thái chạy hay dừng.

d) Đảm bảo băng thông
Kiến trúc PXA có 4 mức độ ưu tiên DMA: cao, bình thường, thấp.
Mức độ ưu tiên cao nhận được băng thông gấp đôi so với mức bình thường, nhận được gấp đôi
nhiều như những ưu tiên thấp.
Người lái xe có thể yêu cầu mức độ ưu tiên, đặc biệt là thời gian thực
những cái như pxa_Camera có thông lượng (lớn).

Thiết kế
======
a) Kênh ảo
Khái niệm tương tự như trong trình điều khiển sa11x0, tức là. một tài xế đã được chỉ định một "ảo
kênh" được liên kết với đường dây của người yêu cầu và kênh DMA vật lý được
được chỉ định ngay khi chuyển khoản được thực hiện.

b) Giải phẫu chuyển giao cho chuyển giao phân tán-thu thập

::

+-------------+------+---------------+----------------+----+
   ZZ0000ZZ ... Trình cập nhật trạng thái ZZ0001ZZ ZZ0002ZZ
   +-------------+------+---------------+----------------+----+

Cấu trúc này được trỏ bởi dma->sg_cpu.
Các mô tả được sử dụng như sau:

- desc-sg[i]: ký hiệu mô tả thứ i, truyền sg thứ i
      phần tử để thu thập phân tán bộ đệm video

- cập nhật trạng thái
      Chuyển một u32 sang bộ nhớ mạch lạc dma nổi tiếng để rời đi
      dấu vết cho thấy việc chuyển giao này đã được thực hiện. Cái "nổi tiếng" là duy nhất cho mỗi
      kênh vật lý, nghĩa là việc đọc giá trị này sẽ cho biết kênh nào
      là lần chuyển hoàn thành cuối cùng tại thời điểm đó.

- người về đích: có ddadr=DADDR_STOP, dcmd=ENDIRQEN

- trình liên kết: có ddadr= desc-sg[0] của lần chuyển tiếp theo, dcmd=0

c) Chuyển chuỗi nóng
Giả sử chuỗi đang chạy là:

::

Bộ đệm 1 Bộ đệm 2
   +----------+----+---+ +----+----+----+---+
   ZZ0000ZZ .. ZZ0001ZZ l ZZ0002ZZ d0 ZZ0003ZZ dN ZZ0004ZZ
   +----------+----+-|-+ ^------+------+----+---+
                    ZZ0005ZZ
                    +----+

Sau lệnh gọi tới dmaengine_submit(b3), chuỗi sẽ trông như sau:

::

Bộ đệm 1 Bộ đệm 2 Bộ đệm 3
   +----------+----+---+ +------+----+----+---+ +----+----+------+---+
   ZZ0000ZZ .. ZZ0001ZZ l ZZ0002ZZ d0 ZZ0003ZZ dN ZZ0004ZZ ZZ0005ZZ .. ZZ0006ZZ f |
   +----------+----+-ZZ0007ZZ-+ ^------+---++----+---+
                    ZZ0008ZZ ZZ0009ZZ
                    +----+ +----+
                                         liên kết mới

Nếu trong khi new_link được tạo, kênh DMA đã dừng thì đó là _not_
được khởi động lại. Chuỗi nóng không phá vỡ giả định rằng
dma_async_issue_pending() sẽ được sử dụng để đảm bảo quá trình truyền thực sự được bắt đầu.

Một ngoại lệ cho quy tắc này:

- nếu Buffer1 và Buffer2 có tất cả địa chỉ của chúng được căn chỉnh 8 byte

- và nếu Buffer3 có ít nhất một địa chỉ không được căn chỉnh 4 byte

- khi đó chuỗi nóng không thể xảy ra vì kênh phải bị dừng,
  "bit căn chỉnh" phải được đặt và kênh được khởi động lại. Do đó,
  việc chuyển tx_submit() như vậy sẽ được xếp hàng đợi trên hàng đợi đã gửi và
  trường hợp cụ thể này nếu DMA đang chạy ở chế độ căn chỉnh.

d) Trình cập nhật hoàn tất chuyển giao
Mỗi lần quá trình truyền hoàn tất trên một kênh, một ngắt có thể xảy ra.
được tạo ra hay không, tùy theo yêu cầu của khách hàng. Nhưng trong mỗi trường hợp, điều cuối cùng
mô tả chuyển khoản, "trình cập nhật trạng thái", sẽ viết thông tin mới nhất
việc chuyển giao đang được hoàn thành vào dấu hoàn thành của kênh vật lý.

Điều này sẽ tăng tốc độ tính toán dư lượng đối với các giao dịch chuyển lớn như video
bộ đệm chứa khoảng 6k bộ mô tả trở lên. Điều này cũng cho phép mà không cần
bất kỳ khóa nào để tìm hiểu quá trình chuyển hoàn thành mới nhất đang diễn ra là gì
Chuỗi DMA.

e) Hoàn thành chuyển giao, irq và tasklet
Khi quá trình truyền được gắn cờ là "DMA_PREP_INTERRUPT" hoàn tất, dma irq
được nâng lên. Khi bị gián đoạn này, một tác vụ nhỏ được lên lịch cho vùng vật lý
kênh.

Nhiệm vụ nhỏ này có trách nhiệm:

- đọc dấu cập nhật cuối cùng của kênh vật lý

- gọi tất cả các cuộc gọi lại chuyển khoản của các lần chuyển đã hoàn thành, dựa trên
  dấu đó và mỗi lá cờ chuyển giao.

Nếu quá trình chuyển hoàn tất trong khi quá trình xử lý này được thực hiện, dma irq sẽ
được nâng lên và tasklet sẽ được lên lịch một lần nữa, có một nhiệm vụ mới
dấu cập nhật.

f) Dư lượng
Mức độ chi tiết của dư lượng sẽ dựa trên mô tả. Đã ban hành nhưng chưa hoàn thành
các lần chuyển giao sẽ được quét để tìm tất cả các bộ mô tả của chúng dựa trên
bộ mô tả hiện đang chạy.

g) Trường hợp phức tạp nhất về hàng đợi tx của tài xế
Tình huống khó khăn nhất là khi:

- không có chuyển khoản "ack" (tx0)

- trình điều khiển đã gửi tx1 thẳng hàng, không bị xích

- trình điều khiển đã gửi tx2 được căn chỉnh => tx2 bị xích lạnh vào tx1

- trình điều khiển được cấp tx1+tx2 => kênh đang chạy ở chế độ căn chỉnh

- trình điều khiển đã gửi tx3 được căn chỉnh => tx3 bị xích nóng

- trình điều khiển đã gửi tx4 => tx4 không được phân bổ được đưa vào hàng đợi đã gửi,
   không bị xiềng xích

- trình điều khiển được cấp tx4 => tx4 được đưa vào hàng đợi được cấp, không bị xâu chuỗi

- trình điều khiển đã gửi tx5 được căn chỉnh => tx5 được đưa vào hàng đợi đã gửi chứ không phải
   bị xiềng xích

- trình điều khiển đã gửi tx6 thẳng hàng => tx6 được đưa vào hàng đợi đã gửi,
   bị xích lạnh vào tx5

Điều này được dịch thành (sau khi tx4 được phát hành):

- hàng đợi đã phát hành

 ::

+------+ +------+ +------+ +------+
      ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ
      +---ZZ0004ZZ-+ ^------+ +------+
          ZZ0005ZZ ZZ0006ZZ
          +---+ +---+
        - hàng đợi đã gửi
      +------+ +------+
      ZZ0007ZZ ZZ0008ZZ
      +---|-+ ^-----+
          ZZ0009ZZ
          +---+

- hàng đợi đã hoàn thành: trống

- hàng đợi được phân bổ: tx0

Cần lưu ý rằng sau khi tx3 hoàn tất, kênh sẽ bị dừng và
được khởi động lại ở "chế độ chưa được căn chỉnh" để xử lý tx4.

Tác giả: Robert Jarzmik <robert.jarzmik@free.fr>
