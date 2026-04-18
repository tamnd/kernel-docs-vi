.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/w1/masters/w1-uart.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================
Trình điều khiển hạt nhân w1-uart
=================================

Tác giả: Christoph Winklhofer <cj.winklhofer@gmail.com>


Sự miêu tả
-----------

Trình điều khiển xe buýt 1 dây UART. Trình điều khiển sử dụng giao diện UART thông qua
Bus thiết bị nối tiếp để tạo các mẫu định thời 1 dây như được mô tả trong
tài liệu ZZ0000ZZ.

.. _"Using a UART to Implement a 1-Wire Bus Master": https://www.analog.com/en/technical-articles/using-a-uart-to-implement-a-1wire-bus-master.html

Nói tóm lại, thiết bị ngoại vi UART phải hỗ trợ song công hoàn toàn và hoạt động ở chế độ
chế độ xả mở. Các mẫu thời gian được tạo ra bởi một
sự kết hợp giữa tốc độ baud và byte được truyền, tương ứng với một
1-bit đọc dây, bit ghi hoặc xung reset.

Ví dụ: mẫu thời gian để đặt lại 1 dây và phát hiện hiện diện sử dụng
tốc độ baud 9600, tức là 104,2 us mỗi bit. Byte được truyền 0xf0 qua
UART (bit ít quan trọng nhất đầu tiên, bit khởi động thấp) đặt thời gian đặt lại thấp
cho 1-Dây tới 521 chúng tôi. Thiết bị 1-Dây hiện tại thay đổi byte nhận được bằng cách
kéo vạch xuống thấp, được người lái xe sử dụng để đánh giá kết quả của
hoạt động 1 dây.

Tương tự đối với bit đọc hoặc ghi 1 dây, sử dụng tốc độ baud
115200, tức là 8,7 us mỗi bit. Byte 0x80 được truyền đi được sử dụng cho
Hoạt động ghi-0 (thời gian thấp 69,6us) và byte 0xff cho Đọc-0, Đọc-1
và Write-1 (thời gian thấp 8,7us).

Tốc độ truyền mặc định để đặt lại và phát hiện sự hiện diện là 9600 và cho
a Hoạt động đọc hoặc ghi 1 dây 115200. Trong trường hợp tốc độ truyền thực tế
khác với byte được yêu cầu, byte được truyền sẽ được điều chỉnh
để tạo ra các mẫu định thời 1-Dây.


Cách sử dụng
------------

Chỉ định bus 1 dây UART trong cây thiết bị bằng cách thêm một con duy nhất
onewire tới nút nối tiếp (ví dụ: uart0). Ví dụ:
:::::::::::::::::::::::::::::::::::::::::::::::

@uart0 {
    ...
một dây {
      tương thích = "w1-uart";
    };
  };