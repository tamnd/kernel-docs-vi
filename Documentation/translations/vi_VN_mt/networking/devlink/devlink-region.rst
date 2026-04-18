.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/devlink-region.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================
Khu vực liên kết nhà phát triển
==============

Các vùng ZZ0000ZZ cho phép truy cập vào các vùng địa chỉ do trình điều khiển xác định bằng cách sử dụng
devlink.

Mỗi thiết bị có thể tạo và đăng ký vùng địa chỉ được hỗ trợ của riêng mình. các
khu vực sau đó có thể được truy cập thông qua giao diện khu vực liên kết phát triển.

Ảnh chụp nhanh khu vực được trình điều khiển thu thập và có thể được truy cập thông qua chức năng đọc
hoặc kết xuất lệnh. Điều này cho phép phân tích trong tương lai về các ảnh chụp nhanh đã tạo.
Các khu vực có thể tùy chọn hỗ trợ kích hoạt ảnh chụp nhanh theo yêu cầu.

Giá trị nhận dạng ảnh chụp nhanh nằm trong phạm vi phiên bản liên kết nhà phát triển chứ không phải theo khu vực.
Tất cả các ảnh chụp nhanh có cùng id ảnh chụp nhanh trong một phiên bản liên kết nhà phát triển
tương ứng với cùng một sự kiện.

Lợi ích chính của việc tạo vùng là cung cấp quyền truy cập vào nội bộ
địa chỉ các vùng mà người dùng không thể truy cập được.

Các khu vực cũng có thể được sử dụng để cung cấp một cách bổ sung để gỡ lỗi phức tạp
các tiểu bang, nhưng cũng xem thêm Tài liệu/mạng/devlink/devlink-health.rst

Các khu vực có thể tùy chọn hỗ trợ chụp ảnh chụp nhanh theo yêu cầu thông qua
Tin nhắn liên kết mạng ZZ0000ZZ. Một người lái xe muốn cho phép
ảnh chụp nhanh được yêu cầu phải triển khai lệnh gọi lại ZZ0001ZZ cho khu vực
trong cấu trúc ZZ0002ZZ của nó. Nếu id ảnh chụp nhanh không được đặt trong
hạt nhân yêu cầu ZZ0003ZZ sẽ phân bổ một và gửi
thông tin ảnh chụp nhanh vào không gian người dùng.

Các khu vực có thể tùy ý cho phép đọc trực tiếp từ nội dung của mình mà không cần
ảnh chụp nhanh. Yêu cầu đọc trực tiếp không phải là nguyên tử. Đặc biệt là một yêu cầu đọc
có kích thước 256 byte hoặc lớn hơn sẽ được chia thành nhiều phần. Nếu nguyên tử
cần có quyền truy cập, hãy sử dụng ảnh chụp nhanh. Một trình điều khiển muốn kích hoạt tính năng này cho một
khu vực nên triển khai lệnh gọi lại ZZ0000ZZ trong ZZ0001ZZ
cấu trúc. Không gian người dùng có thể yêu cầu đọc trực tiếp bằng cách sử dụng
Thuộc tính ZZ0002ZZ thay vì chỉ định ảnh chụp nhanh
id.

cách sử dụng ví dụ
-------------

.. code:: shell

    $ devlink region help
    $ devlink region show [ DEV/REGION ]
    $ devlink region del DEV/REGION snapshot SNAPSHOT_ID
    $ devlink region dump DEV/REGION [ snapshot SNAPSHOT_ID ]
    $ devlink region read DEV/REGION [ snapshot SNAPSHOT_ID ] address ADDRESS length LENGTH

    # Show all of the exposed regions with region sizes:
    $ devlink region show
    pci/0000:00:05.0/cr-space: size 1048576 snapshot [1 2] max 8
    pci/0000:00:05.0/fw-health: size 64 snapshot [1 2] max 8

    # Delete a snapshot using:
    $ devlink region del pci/0000:00:05.0/cr-space snapshot 1

    # Request an immediate snapshot, if supported by the region
    $ devlink region new pci/0000:00:05.0/cr-space
    pci/0000:00:05.0/cr-space: snapshot 5

    # Dump a snapshot:
    $ devlink region dump pci/0000:00:05.0/fw-health snapshot 1
    0000000000000000 0014 95dc 0014 9514 0035 1670 0034 db30
    0000000000000010 0000 0000 ffff ff04 0029 8c00 0028 8cc8
    0000000000000020 0016 0bb8 0016 1720 0000 0000 c00f 3ffc
    0000000000000030 bada cce5 bada cce5 bada cce5 bada cce5

    # Read a specific part of a snapshot:
    $ devlink region read pci/0000:00:05.0/fw-health snapshot 1 address 0 length 16
    0000000000000000 0014 95dc 0014 9514 0035 1670 0034 db30

    # Read from the region without a snapshot
    $ devlink region read pci/0000:00:05.0/fw-health address 16 length 16
    0000000000000010 0000 0000 ffff ff04 0029 8c00 0028 8cc8

Vì các khu vực có thể rất cụ thể về thiết bị hoặc trình điều khiển nên không có khu vực chung nào được
được xác định. Xem các tập tin tài liệu dành riêng cho trình điều khiển để biết thông tin về
các khu vực cụ thể mà trình điều khiển hỗ trợ.