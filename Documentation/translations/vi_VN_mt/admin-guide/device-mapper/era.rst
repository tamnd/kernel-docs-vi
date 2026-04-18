.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/era.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========
thời đại dm
===========

Giới thiệu
============

dm-era là mục tiêu hoạt động tương tự như mục tiêu tuyến tính.  trong
Ngoài ra, nó còn theo dõi khối nào được viết trong người dùng
khoảng thời gian xác định gọi là "thời đại".  Mỗi trường hợp mục tiêu thời đại
duy trì kỷ nguyên hiện tại dưới dạng 32-bit tăng đơn điệu
quầy.

Các trường hợp sử dụng bao gồm theo dõi các khối đã thay đổi đối với phần mềm sao lưu và
vô hiệu hóa một phần nội dung của bộ đệm để khôi phục bộ đệm
sự mạch lạc sau khi khôi phục ảnh chụp nhanh của nhà cung cấp.

Người xây dựng
==============

era <metadata dev> <origin dev> <block size>

============================================================================
 siêu dữ liệu nhà phát triển thiết bị nhanh chứa siêu dữ liệu liên tục
 thiết bị dev gốc chứa các khối dữ liệu có thể thay đổi
 kích thước khối kích thước khối của thiết bị dữ liệu gốc, độ chi tiết được
		  được theo dõi bởi mục tiêu
 ============================================================================

Tin nhắn
========

Không có tin nhắn dm nào có bất kỳ đối số nào.

trạm kiểm soát
--------------

Có thể chuyển sang một kỷ nguyên mới.  Bạn không nên cho rằng thời đại đã
tăng lên.  Sau khi gửi tin nhắn này, bạn nên kiểm tra
thời đại hiện tại thông qua dòng trạng thái.

take_metadata_snap
------------------

Tạo một bản sao của siêu dữ liệu để cho phép quy trình người dùng đọc nó.

drop_metadata_snap
------------------

Bỏ ảnh chụp nhanh siêu dữ liệu.

Trạng thái
==========

<kích thước khối siêu dữ liệu> <khối siêu dữ liệu #used>/<khối siêu dữ liệu #total>
<thời đại hiện tại> <gốc siêu dữ liệu được giữ | '-'>

=============================================================================
kích thước khối siêu dữ liệu Kích thước khối cố định cho mỗi khối siêu dữ liệu trong
			  lĩnh vực
Khối siêu dữ liệu #used Số khối siêu dữ liệu được sử dụng
Khối siêu dữ liệu #total Tổng số khối siêu dữ liệu
thời đại hiện tại thời đại hiện tại
gốc siêu dữ liệu được giữ Vị trí, tính theo khối, của gốc siêu dữ liệu
			  đã được 'giữ' để đọc không gian người dùng
			  truy cập. '-' cho biết không có quyền root
=============================================================================

Trường hợp sử dụng chi tiết
===========================

Tình huống vô hiệu hóa bộ đệm khi khôi phục nhà cung cấp
ảnh chụp nhanh là trường hợp sử dụng chính khi phát triển mục tiêu này:

Chụp ảnh nhanh nhà cung cấp
---------------------------

- Gửi tin nhắn điểm kiểm tra đến mục tiêu thời đại
- Ghi chú thời đại hiện tại vào dòng trạng thái của nó
- Chụp ảnh nhanh nhà cung cấp (thời đại và ảnh chụp nhanh sẽ tồn tại mãi mãi
  liên kết ngay bây giờ).

Quay lại ảnh chụp nhanh của nhà cung cấp
----------------------------------------

- Cache vào chế độ passthrough (xem: tài liệu của dm-cache trong cache.txt)
- Lưu trữ nhà cung cấp khôi phục
- Chụp nhanh siêu dữ liệu
- Xác định khối nào đã được ghi kể từ khi chụp ảnh nhanh
  bằng cách kiểm tra thời đại của từng khối
- Vô hiệu hóa các khối đó trong phần mềm bộ nhớ đệm
- Bộ nhớ đệm trở về chế độ ghi lại/ghi qua

Sử dụng bộ nhớ
==============

Mục tiêu sử dụng một bitset để ghi lại việc ghi trong thời đại hiện tại.  Nó cũng
có một bitset dự phòng sẵn sàng để chuyển sang một kỷ nguyên mới.  Khác với
rằng nó sử dụng một số khối 4k để cập nhật siêu dữ liệu::

(4 * nr_blocks) byte + bộ đệm

khả năng phục hồi
=================

Siêu dữ liệu được cập nhật trên đĩa trước khi ghi vào một dữ liệu chưa được ghi trước đó
khối được thực hiện.  Vì thời đại dm như vậy không nên bị ảnh hưởng bởi một sự cứng rắn
sự cố như mất điện.

Công cụ người dùng
==================

Các công cụ dành cho người dùng được tìm thấy ngày càng ít được đặt tên
dự án công cụ cung cấp mỏng:

ZZ0000ZZ
