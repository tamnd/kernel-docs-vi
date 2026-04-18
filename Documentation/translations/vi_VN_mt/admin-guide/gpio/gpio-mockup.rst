.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/gpio/gpio-mockup.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển kiểm tra GPIO
==============================

.. note::

   This module has been obsoleted by the more flexible gpio-sim.rst.
   New developments should use that API and existing developments are
   encouraged to migrate as soon as possible.
   This module will continue to be maintained but no new features will be
   added.

Trình điều khiển kiểm tra GPIO (gpio-mockup) cung cấp cách tạo GPIO mô phỏng
chip cho mục đích thử nghiệm. Các dòng được hiển thị bởi các chip này có thể được truy cập
sử dụng giao diện thiết bị ký tự GPIO tiêu chuẩn cũng như thao tác
sử dụng cấu trúc thư mục debugfs chuyên dụng.

Tạo chip mô phỏng bằng cách sử dụng thông số mô-đun
---------------------------------------------------

Khi tải trình điều khiển gpio-mockup, một số tham số có thể được chuyển tới
mô-đun.

gpio_mockup_ranges

Tham số này nhận một đối số ở dạng một mảng số nguyên
        cặp. Mỗi cặp xác định số GPIO cơ sở (số nguyên không âm)
        và số đầu tiên sau số cuối cùng của con chip này. Nếu cơ sở GPIO
        là -1, gpiolib sẽ tự động gán nó. trong khi sau đây
        tham số là số dòng được hiển thị bởi chip.

Ví dụ: gpio_mockup_ranges=-1,8,-1,16,405,409

Dòng trên tạo ra ba chip. Cái đầu tiên sẽ hiển thị 8 dòng,
        16 thứ hai và 4 thứ ba. GPIO cơ sở cho chip thứ ba được thiết lập
        đến 405 trong khi đối với hai chip đầu tiên, nó sẽ được gán tự động.

gpio_mockup_named_lines

Tham số này không nhận bất kỳ đối số nào. Nó cho người lái xe biết rằng
        Các dòng GPIO do nó lộ ra nên được đặt tên.

Định dạng tên là: gpio-mockup-X-Y trong đó X là ID của chip mô phỏng
        và Y là độ lệch dòng.

Thao tác mô phỏng đường nét
----------------------------

Mỗi chip mô phỏng tạo thư mục con riêng trong /sys/kernel/debug/gpio-mockup/.
Thư mục được đặt tên theo nhãn của chip. Một liên kết tượng trưng cũng được tạo ra, được đặt tên
sau tên của chip, trỏ đến thư mục nhãn.

Bên trong mỗi thư mục con, có một thuộc tính riêng cho mỗi dòng GPIO. các
tên của thuộc tính thể hiện độ lệch của dòng trong chip.

Đọc từ thuộc tính dòng trả về giá trị hiện tại. Viết cho nó (0 hoặc 1)
thay đổi cấu hình của điện trở kéo lên/kéo xuống mô phỏng
(1 - kéo lên, 0 - kéo xuống).