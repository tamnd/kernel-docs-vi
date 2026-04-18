.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/zero.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=======
dm-không
=======

Mục tiêu "không" của Device-Mapper cung cấp một thiết bị khối luôn trả về
dữ liệu bằng không khi đọc và âm thầm bỏ ghi. Đây là hành vi tương tự như
/dev/zero, nhưng là thiết bị khối thay vì thiết bị ký tự.

Dm-zero không có tham số dành riêng cho mục tiêu.

Một cách sử dụng rất thú vị của dm-zero là để tạo ra các thiết bị "thưa thớt" trong
kết hợp với dm-snapshot. Một thiết bị thưa thớt báo cáo kích thước thiết bị lớn hơn
hơn dung lượng lưu trữ thực tế có sẵn cho thiết bị đó. Một người dùng có thể
ghi dữ liệu vào bất cứ đâu trong thiết bị thưa thớt và đọc lại như bình thường
thiết bị. Việc đọc vào các vùng chưa được ghi trước đó sẽ trả về bộ đệm bằng 0. Khi nào
đủ dữ liệu đã được ghi để lấp đầy không gian lưu trữ thực tế, phần dữ liệu thưa thớt
thiết bị bị vô hiệu hóa. Điều này có thể rất hữu ích cho việc kiểm tra thiết bị và
hạn chế của hệ thống tập tin.

Để tạo một thiết bị thưa thớt, hãy bắt đầu bằng cách tạo một thiết bị dm-zero
kích thước mong muốn của thiết bị thưa thớt. Trong ví dụ này, chúng tôi sẽ giả sử 10TB
thiết bị thưa thớt::

TEN_TERABYTES=ZZ0000ZZ # 10 TB trong các lĩnh vực
  echo "0 $TEN_TERABYTES không" | dmsetup tạo zero1

Sau đó, tạo ảnh chụp nhanh của thiết bị số 0, sử dụng bất kỳ thiết bị khối có sẵn nào làm
thiết bị COW. Kích thước của thiết bị COW sẽ quyết định số lượng thực
không gian có sẵn cho thiết bị thưa thớt. Trong ví dụ này, chúng tôi sẽ giả sử /dev/sdb1
là phân vùng 10GB có sẵn::

echo "0 $TEN_TERABYTES ảnh chụp nhanh /dev/mapper/zero1 /dev/sdb1 p 128" | \
     dmsetup tạo thưa thớt1

Điều này sẽ tạo ra một thiết bị thưa thớt 10TB có tên /dev/mapper/sparse1 có
10GB dung lượng lưu trữ thực tế có sẵn. Nếu có nhiều hơn 10GB dữ liệu được ghi
vào thiết bị này, nó sẽ bắt đầu trả về lỗi I/O.
