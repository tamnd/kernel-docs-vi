.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/dm-ebs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======
dm-ebs
======


Mục tiêu này tương tự như mục tiêu tuyến tính ngoại trừ việc nó mô phỏng
kích thước khối logic nhỏ hơn trên thiết bị có khối logic lớn hơn
kích thước.  Mục đích chính của nó là cung cấp khả năng mô phỏng các cung 512 byte trên
các thiết bị không cung cấp mô phỏng này (tức là đĩa gốc 4K).

Hỗ trợ kích thước khối logic mô phỏng 512, 1024, 2048 và 4096.

Kích thước khối cơ bản có thể được đặt thành > 4K để kiểm tra việc đệm các đơn vị lớn hơn.


Tham số bảng
----------------
<đường dẫn phát triển> <offset> <các lĩnh vực được mô phỏng> [<các lĩnh vực cơ bản>]

Các thông số bắt buộc:

<đường dẫn nhà phát triển>:
        Tên đường dẫn đầy đủ đến thiết bị khối cơ bản,
        hoặc số thiết bị "chính: phụ".
    <bù đắp>:
        Khu vực bắt đầu trong thiết bị;
        phải là bội số của <các khu vực được mô phỏng>.
    <các lĩnh vực mô phỏng>:
        Số lượng các lĩnh vực xác định kích thước khối logic được mô phỏng;
        Hỗ trợ 1, 2, 4, 8 cung 512 byte.

Tham số tùy chọn:

<ngành cơ bản>:
        Số lượng lĩnh vực xác định kích thước khối logic của <dev path>.
        2^N được hỗ trợ, ví dụ: 8 = mô phỏng 8 cung 512 byte = 4KiB.
        Nếu không được cung cấp, kích thước khối logic của <dev path> sẽ được sử dụng.


Ví dụ:

Mô phỏng 1 khu vực = kích thước khối logic 512 byte trên/dev/sda bắt đầu từ
bù đắp 1024 lĩnh vực với kích thước khối thiết bị cơ bản được đặt tự động:

ebs/dev/sda 1024 1

Mô phỏng 2 khu vực = kích thước khối logic 1KiB trên/dev/sda bắt đầu từ
bù đắp 128 lĩnh vực, thực thi kích thước khối thiết bị cơ bản 2KiB.
Điều này giả định kích thước khối logic 2KiB trên/dev/sda trở xuống sẽ hoạt động:

ebs /dev/sda 128 2 4
