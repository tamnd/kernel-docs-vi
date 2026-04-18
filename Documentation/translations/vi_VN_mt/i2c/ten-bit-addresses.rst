.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/i2c/ten-bit-addresses.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Địa chỉ mười bit I2C
=====================

Giao thức I2C biết về hai loại địa chỉ thiết bị: 7 bit bình thường
địa chỉ và một tập hợp địa chỉ 10 bit mở rộng. Các bộ địa chỉ
không giao nhau: địa chỉ 7 bit 0x10 không giống với địa chỉ 10 bit
địa chỉ 0x10 (mặc dù một thiết bị có thể phản hồi cả hai địa chỉ đó).
Để tránh sự mơ hồ, người dùng sẽ thấy các địa chỉ 10 bit được ánh xạ tới một địa chỉ khác
không gian địa chỉ, cụ thể là 0xa000-0xa3ff. 0xa (= 10) đứng đầu đại diện cho
Chế độ 10 bit. Điều này được sử dụng để tạo tên thiết bị trong sysfs. Nó cũng là
cần thiết khi khởi tạo thiết bị 10 bit thông qua tệp new_device trong sysfs.

Tin nhắn I2C đến và đi từ các thiết bị có địa chỉ 10 bit có định dạng khác.
Xem thông số kỹ thuật I2C để biết chi tiết.

Hỗ trợ địa chỉ 10 bit hiện tại là tối thiểu. Tuy nhiên, nó sẽ hoạt động
bạn có thể gặp phải một số vấn đề trong quá trình thực hiện:

* Không phải tất cả trình điều khiển xe buýt đều hỗ trợ địa chỉ 10 bit. Một số thì không vì
  phần cứng không hỗ trợ chúng (SMBus không yêu cầu địa chỉ 10 bit
  hỗ trợ chẳng hạn), một số thì không vì không ai bận tâm thêm
  mã (hoặc có ở đó nhưng không hoạt động bình thường.) Triển khai phần mềm
  (i2c-algo-bit) được biết là có tác dụng.
* Một số tính năng tùy chọn không hỗ trợ địa chỉ 10 bit. Đây là
  trường hợp tự động phát hiện và khởi tạo thiết bị bằng cách của họ,
  trình điều khiển chẳng hạn.
* Nhiều gói không gian người dùng (ví dụ: công cụ i2c) thiếu hỗ trợ cho
  Địa chỉ 10 bit.

Lưu ý rằng các thiết bị địa chỉ 10 bit vẫn còn khá hiếm, vì vậy những hạn chế
liệt kê ở trên có thể tồn tại trong một thời gian dài, thậm chí có thể là mãi mãi nếu không có ai
cần chúng được sửa chữa.
