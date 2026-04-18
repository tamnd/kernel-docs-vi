.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/i2c/busses/i2c-taos-evm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================
Trình điều khiển hạt nhân i2c-taos-evm
==========================

Tác giả: Jean Delvare <jdelvare@suse.de>

Đây là trình điều khiển cho các mô-đun đánh giá cho chip TAOS I2C/SMBus.
Các mô-đun bao gồm một SMBus master với khả năng hạn chế, có thể
được điều khiển qua cổng nối tiếp. Hầu như tất cả các mô-đun đánh giá
đều được hỗ trợ, nhưng cần thêm một vài dòng mã cho mỗi dòng mới
mô-đun để khởi tạo chip I2C bên phải trên xe buýt. Rõ ràng là tài xế
đối với con chip được đề cập cũng cần thiết.

Các thiết bị hiện được hỗ trợ là:

* TAOS TSL2550 EVM

Để biết thêm thông tin về các sản phẩm TAOS, vui lòng xem
  ZZ0000ZZ


Sử dụng trình điều khiển này
-----------------

Để sử dụng trình điều khiển này, bạn sẽ cần trình điều khiển dịch vụ và
công cụ inputattach, là một phần của gói input-utils. Sau đây
các lệnh sẽ cho kernel biết rằng bạn có TAOS EVM ở lần đầu tiên
cổng nối tiếp::

Dịch vụ # modprobe
  # inputattach --taos-evm /dev/ttyS0


Chi tiết kỹ thuật
-----------------

Chỉ có 4 loại giao dịch SMBus được hỗ trợ bởi đánh giá TAOS
mô-đun:
* Nhận byte
* Gửi byte
* Đọc byte
* Viết Byte

Giao thức truyền thông dựa trên văn bản và khá đơn giản. Đó là
được mô tả trong tài liệu PDF trên đĩa CD đi kèm với bản đánh giá
mô-đun. Giao tiếp khá chậm vì cổng nối tiếp có
hoạt động ở tốc độ 1200 bps. Tuy nhiên, tôi không nghĩ rằng đây là một mối quan tâm lớn trong
thực hành, vì các mô-đun này chỉ nhằm mục đích đánh giá và kiểm tra.
