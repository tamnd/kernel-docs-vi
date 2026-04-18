.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/iio/iio_dmabuf_api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================================
Giao diện DMABUF tốc độ cao cho IIO
===================================

1. Tổng quan
===========

Hệ thống con I/O công nghiệp hỗ trợ truy cập vào bộ đệm thông qua
giao diện dựa trên tập tin, với các lệnh gọi truy cập read() và write() thông qua
Nút phát triển của thiết bị IIO.

Nó cũng hỗ trợ giao diện dựa trên DMABUF, nơi không gian người dùng
có thể đính kèm các đối tượng DMABUF (được tạo bên ngoài) vào bộ đệm IIO và
sau đó sử dụng chúng để truyền dữ liệu.

Sau đó, một ứng dụng không gian người dùng có thể sử dụng giao diện này để chia sẻ DMABUF
các đối tượng giữa một số giao diện, cho phép nó truyền dữ liệu một cách
kiểu không sao chép, chẳng hạn như giữa IIO và ngăn xếp USB.

Ứng dụng không gian người dùng cũng có thể ánh xạ bộ nhớ các đối tượng DMABUF và
truy cập trực tiếp vào dữ liệu mẫu. Ưu điểm của việc này so với
Giao diện read() là nó tránh được việc sao chép thêm dữ liệu giữa
kernel và không gian người dùng. Điều này đặc biệt hữu ích cho các thiết bị tốc độ cao
tạo ra vài megabyte hoặc thậm chí gigabyte dữ liệu mỗi giây.
Tuy nhiên, nó làm tăng tính đồng bộ hóa không gian hạt nhân-không gian người dùng
chi phí chung, vì IOCTL DMA_BUF_SYNC_START và DMA_BUF_SYNC_END phải
được sử dụng để đảm bảo tính toàn vẹn dữ liệu.

2. Người dùng API
===========

Là một phần của giao diện này, ba IOCTL mới đã được thêm vào. Ba người này
IOCTL phải được thực hiện trên bộ mô tả tệp của bộ đệm IIO,
có thể thu được bằng cách sử dụng IIO_BUFFER_GET_FD_IOCTL() ioctl.

ZZ0000ZZ
    Đính kèm đối tượng DMABUF, được xác định bởi bộ mô tả tệp của nó, vào
    Bộ đệm IIO. Trả về 0 nếu thành công và giá trị lỗi âm nếu
    lỗi.

ZZ0000ZZ
    Tách đối tượng DMABUF đã cho, được xác định bởi bộ mô tả tệp của nó,
    từ bộ đệm IIO. Trả về số 0 khi thành công và lỗi âm
    giá trị bị lỗi.

Lưu ý rằng việc đóng bộ mô tả tệp của bộ đệm IIO sẽ
    tự động tách tất cả các đối tượng DMABUF đã đính kèm trước đó.

ZZ0000ZZ
    Đưa một đối tượng DMABUF đã được đính kèm trước đó vào hàng đợi bộ đệm.
    Các DMABUF được xếp hàng đợi sẽ được đọc từ (nếu là bộ đệm đầu ra) hoặc được ghi vào
    (nếu bộ đệm đầu vào) miễn là bộ đệm được bật.