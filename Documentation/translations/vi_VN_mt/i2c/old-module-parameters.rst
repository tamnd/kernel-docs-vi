.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/i2c/old-module-parameters.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================================================================
Kiểm soát liên kết trình điều khiển thiết bị I2C từ không gian người dùng trong hạt nhân cũ
================================================================

.. NOTE::
   Note: this section is only relevant if you are handling some old code
   found in kernel 2.6. If you work with more recent kernels, you can
   safely skip this section.

Lên đến kernel 2.6.32, nhiều trình điều khiển I2C đã sử dụng macro trợ giúp do
<linux/i2c.h> đã tạo các tham số mô-đun tiêu chuẩn để cho phép người dùng
kiểm soát cách người lái xe thăm dò xe buýt I2C và gắn vào thiết bị. Những cái này
các tham số được gọi là ZZ0000ZZ (để cho phép trình điều khiển thăm dò thêm
địa chỉ), ZZ0001ZZ (để buộc gắn trình điều khiển vào một thiết bị nhất định) và
ZZ0002ZZ (để ngăn trình điều khiển thăm dò một địa chỉ nhất định).

Với việc chuyển đổi hệ thống con I2C sang trình điều khiển thiết bị tiêu chuẩn
mô hình liên kết, rõ ràng là các tham số trên mỗi mô-đun này không
cần thiết lâu hơn và việc triển khai tập trung là có thể. Cái mới,
giao diện dựa trên sysfs được mô tả trong
Tài liệu/i2c/instantiating-devices.rst, phần
"Phương pháp 4: Khởi tạo từ không gian người dùng".

Dưới đây là ánh xạ từ các tham số mô-đun cũ sang giao diện mới.

Gắn trình điều khiển vào thiết bị I2C
-----------------------------------

Phương thức cũ (tham số mô-đun)::

Đầu dò # modprobe <trình điều khiển> = 1,0x2d
  # modprobe <lực> lực=1,0x2d
  # modprobe <trình điều khiển> lực_<thiết bị>=1,0x2d

Phương thức mới (giao diện sysfs)::

# echo <thiết bị> 0x2d > /sys/bus/i2c/devices/i2c-1/new_device

Ngăn chặn trình điều khiển gắn vào thiết bị I2C
---------------------------------------------------

Phương thức cũ (tham số mô-đun)::

# modprobe <trình điều khiển> bỏ qua=1,0x2f

Phương thức mới (giao diện sysfs)::

# echo giả 0x2f > /sys/bus/i2c/devices/i2c-1/new_device
  # modprobe <trình điều khiển>

Tất nhiên, điều quan trọng là phải khởi tạo thiết bị ZZ0000ZZ trước khi tải
người lái xe. Thiết bị giả sẽ được xử lý bởi chính i2c-core, ngăn chặn
các trình điều khiển khác liên kết với nó sau này. Nếu có một thiết bị thực ở
địa chỉ có vấn đề và bạn muốn một trình điều khiển khác liên kết với nó thì chỉ cần
chuyển tên của thiết bị được đề cập thay vì ZZ0001ZZ.
