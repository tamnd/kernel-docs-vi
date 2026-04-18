.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/ext4/verity.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Tập tin xác thực
----------------

ext4 hỗ trợ fs-verity, đây là một tính năng của hệ thống tập tin cung cấp
Băm dựa trên cây Merkle cho các tệp chỉ đọc riêng lẻ.  Hầu hết
fs-verity là chung cho tất cả các hệ thống tập tin hỗ trợ nó; xem
ZZ0000ZZ dành cho
tài liệu fs-verity.  Tuy nhiên, cách bố trí trên đĩa của xác thực
siêu dữ liệu dành riêng cho hệ thống tập tin.  Trên ext4, siêu dữ liệu xác thực là
được lưu trữ sau phần cuối của dữ liệu tệp, theo định dạng sau:

- Không đệm vào ranh giới 65536 byte tiếp theo.  Phần đệm này không cần thiết
  thực sự được phân bổ trên đĩa, tức là nó có thể là một lỗ hổng.

- Cây Merkle, như được ghi lại trong
  ZZ0000ZZ, với các cấp độ cây được lưu theo thứ tự từ
  từ gốc đến lá, và các khối cây trong mỗi cấp được lưu trữ trong
  trật tự tự nhiên.

- Không đệm vào ranh giới khối hệ thống tập tin tiếp theo.

- Bộ mô tả xác thực, như được ghi lại trong
  ZZ0000ZZ,
  với blob chữ ký được thêm vào tùy chọn.

- Không đệm cho phần bù tiếp theo là 4 byte trước hệ thống tệp
  ranh giới khối.

- Kích thước của bộ mô tả xác thực tính bằng byte, nhỏ 4 byte
  số nguyên endian.

Các nút Verity có bộ EXT4_VERITY_FL và chúng phải sử dụng phạm vi, tức là.
EXT4_EXTENTS_FL phải được đặt và EXT4_INLINE_DATA_FL phải rõ ràng.
Họ có thể có bộ EXT4_ENCRYPT_FL, trong trường hợp đó siêu dữ liệu xác thực
được mã hóa cũng như chính dữ liệu.

Các tệp xác thực không thể có các khối được phân bổ sau phần cuối của xác thực
siêu dữ liệu.

Verity và DAX không tương thích và cố gắng đặt cả hai cờ này
trên một tập tin sẽ thất bại.