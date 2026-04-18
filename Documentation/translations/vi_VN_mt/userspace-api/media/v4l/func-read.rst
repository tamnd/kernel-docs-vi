.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/func-read.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _func-read:

*************
V4L2 đọc()
***********

Tên
====

v4l2-read - Đọc từ thiết bị V4L2

Tóm tắt
========

.. code-block:: c

    #include <unistd.h>

.. c:function:: ssize_t read( int fd, void *buf, size_t count )

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ
   Bộ đệm cần được lấp đầy

ZZ0000ZZ
  Số byte tối đa để đọc

Sự miêu tả
===========

ZZ0000ZZ cố gắng đọc tối đa ZZ0003ZZ byte từ tệp
bộ mô tả ZZ0004ZZ vào bộ đệm bắt đầu từ ZZ0005ZZ. Bố cục của
dữ liệu trong bộ đệm được thảo luận trong giao diện thiết bị tương ứng
phần, xem ##. Nếu ZZ0006ZZ bằng 0, ZZ0001ZZ trả về 0
và không có kết quả nào khác. Nếu ZZ0007ZZ lớn hơn ZZ0008ZZ,
kết quả là không xác định. Bất kể giá trị ZZ0009ZZ mỗi
Cuộc gọi ZZ0002ZZ sẽ cung cấp tối đa một khung (hai trường)
giá trị của dữ liệu.

Theo mặc định, ZZ0000ZZ sẽ chặn cho đến khi có dữ liệu. Khi nào
cờ ZZ0007ZZ đã được trao cho ZZ0001ZZ
chức năng này sẽ trả về ngay lập tức với mã lỗi ZZ0008ZZ khi không có dữ liệu
có sẵn. ZZ0002ZZ hoặc
Các chức năng ZZ0003ZZ luôn có thể được sử dụng để tạm dừng
thực hiện cho đến khi có dữ liệu. Tất cả các trình điều khiển hỗ trợ
Chức năng ZZ0004ZZ cũng phải hỗ trợ ZZ0005ZZ và
ZZ0006ZZ.

Trình điều khiển có thể triển khai chức năng đọc theo nhiều cách khác nhau, sử dụng
một hoặc nhiều bộ đệm và loại bỏ các khung hình cũ nhất hoặc mới nhất
khi bộ đệm bên trong được lấp đầy.

ZZ0000ZZ không bao giờ trả về "ảnh chụp nhanh" của bộ đệm đang được lấp đầy.
Sử dụng một bộ đệm duy nhất, trình điều khiển sẽ ngừng chụp khi
ứng dụng bắt đầu đọc bộ đệm cho đến khi quá trình đọc kết thúc. Như vậy
chỉ có khoảng thời gian của khoảng trống dọc có sẵn cho
đọc hoặc tốc độ chụp phải giảm xuống dưới tốc độ khung hình danh nghĩa của
tiêu chuẩn video.

Hành vi của ZZ0000ZZ khi được gọi trong ảnh đang hoạt động
dấu chấm hoặc khoảng trống dọc ngăn cách trường trên và dưới
phụ thuộc vào chính sách loại bỏ. Trình điều khiển loại bỏ các khung hình cũ nhất
tiếp tục ghi vào bộ đệm bên trong, liên tục ghi đè lên
trước đó, không đọc khung và trả về khung được nhận tại
thời gian của cuộc gọi ZZ0001ZZ ngay sau khi nó hoàn tất.

Trình điều khiển loại bỏ các khung hình mới nhất sẽ dừng chụp cho đến khung hình tiếp theo
Cuộc gọi ZZ0000ZZ. Khung đang được nhận tại ZZ0001ZZ
thời gian bị loại bỏ, thay vào đó trả về khung hình sau. Một lần nữa điều này
ngụ ý giảm tỷ lệ bắt giữ xuống một nửa hoặc ít hơn
tốc độ khung hình danh nghĩa. Một ví dụ của mô hình này là chế độ đọc video của
trình điều khiển bttv, khởi tạo DMA vào bộ nhớ người dùng khi ZZ0002ZZ
được gọi và quay trở lại khi DMA kết thúc.

Trong nhiều trình điều khiển mô hình bộ đệm duy trì một vòng nội bộ
bộ đệm, tự động chuyển sang bộ đệm trống tiếp theo. Điều này cho phép
chụp liên tục khi ứng dụng có thể làm trống bộ đệm nhanh
đủ rồi. Một lần nữa, hiện tượng khi trình điều khiển hết bộ đệm trống
phụ thuộc vào chính sách loại bỏ.

Các ứng dụng có thể lấy và thiết lập số lượng bộ đệm được sử dụng nội bộ bởi
trình điều khiển với ZZ0000ZZ và
ZZ0001ZZ ioctls. Chúng là tùy chọn,
tuy nhiên. Chính sách loại bỏ không được báo cáo và không thể thay đổi.
Để biết các yêu cầu tối thiểu, hãy xem ZZ0002ZZ.

Giá trị trả về
============

Khi thành công, số byte đã đọc sẽ được trả về. Đó không phải là lỗi nếu
con số này nhỏ hơn số byte được yêu cầu hoặc số lượng
dữ liệu cần thiết cho một khung hình. Điều này có thể xảy ra chẳng hạn vì
ZZ0000ZZ bị gián đoạn bởi tín hiệu. Nếu có lỗi, -1 là
được trả về và biến ZZ0001ZZ được đặt thích hợp. Trong trường hợp này
lần đọc tiếp theo sẽ bắt đầu ở đầu khung mới. Lỗi có thể xảy ra
mã là:

EAGAIN
    I/O không chặn đã được chọn bằng O_NONBLOCK và không có dữ liệu nào được chọn
    ngay lập tức có sẵn để đọc.

EBADF
    ZZ0000ZZ không phải là bộ mô tả tệp hợp lệ hoặc không mở để đọc hoặc
    quá trình này đã mở được số lượng tệp tối đa.

EBUSY
    Trình điều khiển không hỗ trợ nhiều luồng đọc và thiết bị
    đã được sử dụng.

EFAULT
    ZZ0000ZZ tham chiếu vùng bộ nhớ không thể truy cập.

EINTR
    Cuộc gọi bị gián đoạn bởi một tín hiệu trước khi bất kỳ dữ liệu nào được đọc.

EIO
    Lỗi vào/ra. Điều này cho thấy một số vấn đề phần cứng hoặc lỗi
    giao tiếp với một thiết bị từ xa (máy ảnh USB, v.v.).

EINVAL
    Chức năng ZZ0000ZZ không được trình điều khiển này hỗ trợ, không
    trên thiết bị này hoặc nói chung là không có trên loại thiết bị này.