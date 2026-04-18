.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/ext4/bitmaps.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Chặn và inode Bitmap
-----------------------

Bitmap khối dữ liệu theo dõi việc sử dụng các khối dữ liệu trong khối
nhóm.

Bitmap inode ghi lại các mục trong bảng inode đang được sử dụng.

Như với hầu hết các ảnh bitmap, một bit biểu thị trạng thái sử dụng của một dữ liệu
chặn hoặc nhập bảng inode. Điều này ngụ ý kích thước nhóm khối là 8 *
số_of_byte_in_a_logic_block.

NOTE: Nếu ZZ0000ZZ được đặt cho một nhóm khối nhất định, các phần khác nhau
của hạt nhân và mã e2fspross giả vờ rằng bitmap khối chứa
số không (tức là tất cả các khối trong nhóm đều miễn phí). Tuy nhiên, nó không phải
nhất thiết là trường hợp không có khối nào được sử dụng -- nếu ZZ0001ZZ được đặt,
bitmap và bộ mô tả nhóm nằm trong nhóm. Thật không may,
ext2fs_test_block_bitmap2() sẽ trả về '0' cho các vị trí đó,
tạo ra đầu ra debugfs khó hiểu.