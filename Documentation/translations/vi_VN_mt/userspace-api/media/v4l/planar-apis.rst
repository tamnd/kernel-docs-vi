.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/planar-apis.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _planar-apis:

*****************************
API đơn và đa mặt phẳng
*****************************

Một số thiết bị yêu cầu dữ liệu cho từng khung hình video đầu vào hoặc đầu ra
được đặt trong các bộ nhớ đệm rời rạc. Trong những trường hợp như vậy, một khung hình video
phải được xử lý bằng nhiều hơn một địa chỉ bộ nhớ, tức là một con trỏ
trên mỗi "máy bay". Mặt phẳng là vùng đệm phụ của khung hiện tại. Ví dụ
các định dạng như vậy, hãy xem ZZ0000ZZ.

Ban đầu, V4L2 API không hỗ trợ bộ đệm đa mặt phẳng và một bộ
các phần mở rộng đã được giới thiệu để xử lý chúng. Những phần mở rộng đó
tạo thành cái được gọi là "API đa mặt phẳng".

Một số lệnh gọi và cấu trúc V4L2 API được diễn giải khác nhau,
tùy thuộc vào việc API đơn hay đa mặt phẳng đang được sử dụng. Một
ứng dụng có thể chọn sử dụng cái này hay cái kia bằng cách chuyển một
loại bộ đệm tương ứng với các lệnh gọi ioctl của nó. Phiên bản đa mặt phẳng của
các loại bộ đệm được gắn với chuỗi ZZ0001ZZ. Đối với một danh sách
các loại bộ đệm đa mặt phẳng có sẵn, xem enum
ZZ0000ZZ.


Định dạng nhiều mặt phẳng
====================

Multi-planar API giới thiệu các định dạng đa mặt phẳng mới. Những định dạng đó sử dụng
một bộ mã FourCC riêng biệt. Điều quan trọng là phải phân biệt giữa
API đa mặt phẳng và định dạng nhiều mặt phẳng. Cuộc gọi API đa mặt phẳng
cũng có thể xử lý tất cả các định dạng một mặt phẳng (miễn là chúng được chuyển qua
trong các cấu trúc API đa mặt phẳng), trong khi API một mặt phẳng không thể
xử lý các định dạng đa mặt phẳng.


Lệnh gọi phân biệt giữa API đơn và API nhiều mặt phẳng
===========================================================

ZZ0000ZZ
    Hai khả năng đa mặt phẳng bổ sung được thêm vào. Chúng có thể được thiết lập
    cùng với những cái không đa phẳng cho các thiết bị xử lý cả hai
    định dạng đơn và đa mặt phẳng.

ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ
    Cấu trúc mới để mô tả các định dạng đa mặt phẳng được thêm vào: struct
    ZZ0003ZZ và
    cấu trúc ZZ0004ZZ.
    Trình điều khiển có thể xác định các định dạng đa mặt phẳng mới, có các đặc điểm riêng biệt
    Mã FourCC từ mã đơn phẳng hiện có.

ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ
    Cấu trúc ZZ0003ZZ cấu trúc mới cho
    mô tả các mặt phẳng được thêm vào. Mảng có cấu trúc này được truyền vào
    trường cấu trúc ZZ0005ZZ mới
    ZZ0004ZZ.

ZZ0000ZZ
    Sẽ phân bổ bộ đệm đa mặt phẳng theo yêu cầu.