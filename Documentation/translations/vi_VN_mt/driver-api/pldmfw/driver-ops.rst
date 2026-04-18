.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/pldmfw/driver-ops.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============================================
Lệnh gọi lại dành riêng cho trình điều khiển
============================================

Mô-đun ZZ0000ZZ dựa vào trình điều khiển thiết bị để triển khai thiết bị
hành vi cụ thể bằng cách sử dụng các hoạt động sau đây.

ZZ0000ZZ
-----------------

Hoạt động ZZ0000ZZ được sử dụng để xác định xem một PLDM nhất định có
bản ghi khớp với thiết bị đang được cập nhật. Điều này đòi hỏi phải so sánh hồ sơ
mô tả trong bản ghi với thông tin từ thiết bị. Nhiều kỷ lục
bộ mô tả được xác định theo tiêu chuẩn PLDM, nhưng nó cũng được phép
thiết bị để thực hiện mô tả riêng của họ.

Hoạt động ZZ0000ZZ sẽ trả về true nếu một bản ghi nhất định khớp
thiết bị.

ZZ0000ZZ
----------------------

Hoạt động ZZ0000ZZ được sử dụng để gửi thông tin dành riêng cho thiết bị
gói dữ liệu trong một bản ghi vào phần sụn của thiết bị. Nếu bản ghi phù hợp
cung cấp dữ liệu gói, ZZ0001ZZ sẽ gọi ZZ0002ZZ
hàm với một con trỏ tới dữ liệu gói và với dữ liệu gói
chiều dài. Trình điều khiển thiết bị sẽ gửi dữ liệu này đến phần sụn.

ZZ0000ZZ
-------------------------

Hoạt động ZZ0000ZZ được sử dụng để chuyển tiếp thành phần
thông tin tới thiết bị. Nó được gọi một lần cho mỗi thành phần thích hợp,
nghĩa là, đối với mỗi thành phần được biểu thị bằng bản ghi phù hợp. các
trình điều khiển thiết bị sẽ gửi thông tin thành phần đến phần sụn của thiết bị,
và chờ phản hồi. Cờ chuyển được cung cấp cho biết liệu điều này
là thành phần đầu tiên, cuối cùng hoặc ở giữa và dự kiến sẽ được chuyển tiếp
vào phần sụn như một phần của thông tin bảng thành phần. Người lái xe nên
lỗi trong trường hợp phần sụn chỉ ra rằng thành phần đó không thể
được cập nhật hoặc trả về 0 nếu thành phần có thể được cập nhật.

ZZ0000ZZ
--------------------

Hoạt động ZZ0000ZZ được sử dụng để thông báo cho trình điều khiển thiết bị về
flash một thành phần nhất định. Người lái xe phải thực hiện mọi bước cần thiết để gửi
dữ liệu thành phần vào thiết bị.

ZZ0000ZZ
--------------------

Hoạt động ZZ0000ZZ được thư viện ZZ0001ZZ sử dụng trong
để cho phép trình điều khiển thiết bị thực hiện bất kỳ thiết bị cụ thể nào còn lại
logic cần thiết để hoàn thành việc cập nhật.