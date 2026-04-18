.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/dev-rds.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _rds:

*************
Giao diện RDS
*************

Hệ thống dữ liệu vô tuyến truyền thông tin bổ sung ở dạng nhị phân
định dạng, ví dụ như tên trạm hoặc thông tin du lịch, trên một
sóng mang phụ âm thanh không nghe được của một chương trình phát thanh. Giao diện này nhằm mục đích
tại các thiết bị có khả năng nhận và/hoặc truyền thông tin RDS.

Để biết thêm thông tin, hãy xem tiêu chuẩn RDS lõi ZZ0000ZZ và
RBDS tiêu chuẩn ZZ0001ZZ.

.. note::

   Note that the RBDS standard as is used in the USA is almost
   identical to the RDS standard. Any RDS decoder/encoder can also handle
   RBDS. Only some of the fields have slightly different meanings. See the
   RBDS standard for more information.

Tiêu chuẩn RBDS cũng chỉ định hỗ trợ cho MMBS (Modified Mobile
Tìm kiếm). Đây là một định dạng độc quyền dường như đã bị ngừng sử dụng.
Giao diện RDS không hỗ trợ định dạng này. Nên hỗ trợ cho MMBS
(hay còn gọi là 'khối E' nói chung) nếu có nhu cầu vui lòng liên hệ
danh sách gửi thư linux-media:
ZZ0000ZZ.

Khả năng truy vấn
=====================

Các thiết bị hỗ trợ RDS chụp API sẽ đặt
Cờ ZZ0004ZZ trong trường ZZ0005ZZ của cấu trúc
ZZ0000ZZ được trả lại bởi
ZZ0001ZZ ioctl. Bất kỳ bộ chỉnh nào
hỗ trợ RDS sẽ đặt cờ ZZ0006ZZ trong
Trường ZZ0007ZZ của cấu trúc ZZ0002ZZ. Nếu
trình điều khiển chỉ chuyển các khối RDS mà không giải thích dữ liệu
Cờ ZZ0008ZZ phải được đặt, xem
ZZ0003ZZ. Để sử dụng cờ trong tương lai
ZZ0009ZZ cũng đã được xác định. Tuy nhiên, một tài xế
đối với bộ thu sóng radio có khả năng này vẫn chưa tồn tại, vì vậy nếu bạn
dự định viết một trình điều khiển như vậy bạn nên thảo luận vấn đề này trên
danh sách gửi thư linux-media:
ZZ0010ZZ.

Có thể phát hiện tín hiệu RDS hay không bằng cách nhìn vào
Trường ZZ0001ZZ của cấu trúc ZZ0000ZZ:
ZZ0002ZZ sẽ được đặt nếu dữ liệu RDS được phát hiện.

Các thiết bị hỗ trợ đầu ra RDS API đặt ZZ0006ZZ
cờ trong trường ZZ0007ZZ của cấu trúc
ZZ0000ZZ được trả lại bởi
ZZ0001ZZ ioctl. Bất kỳ bộ điều biến nào
hỗ trợ RDS sẽ đặt cờ ZZ0008ZZ trong
Trường cấu trúc ZZ0009ZZ
ZZ0002ZZ. Để kích hoạt RDS
người ta phải đặt bit ZZ0010ZZ trong
Trường cấu trúc ZZ0011ZZ
ZZ0003ZZ. Nếu người lái xe chỉ vượt qua RDS
chặn mà không giải thích dữ liệu ZZ0012ZZ
cờ phải được thiết lập. Nếu bộ điều chỉnh có khả năng xử lý các thực thể RDS
như mã nhận dạng chương trình và văn bản radio, cờ
ZZ0013ZZ nên được đặt, xem
ZZ0004ZZ và
ZZ0005ZZ.

.. _reading-rds-data:

Đọc dữ liệu RDS
================

Dữ liệu RDS có thể được đọc từ thiết bị vô tuyến bằng
Chức năng ZZ0000ZZ. Dữ liệu được đóng gói theo nhóm
ba byte.

.. _writing-rds-data:

Ghi dữ liệu RDS
================

Dữ liệu RDS có thể được ghi vào thiết bị vô tuyến bằng
Chức năng ZZ0000ZZ. Dữ liệu được đóng gói theo nhóm
ba byte như sau:

Cấu trúc cơ sở hạ tầng RDS
==================

.. c:type:: v4l2_rds_data

.. flat-table:: struct v4l2_rds_data
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 5

    * - __u8
      - ``lsb``
      - Least Significant Byte of RDS Block
    * - __u8
      - ``msb``
      - Most Significant Byte of RDS Block
    * - __u8
      - ``block``
      - Block description


.. _v4l2-rds-block:

.. tabularcolumns:: |p{2.9cm}|p{14.6cm}|

.. flat-table:: Block description
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 5

    * - Bits 0-2
      - Block (aka offset) of the received data.
    * - Bits 3-5
      - Deprecated. Currently identical to bits 0-2. Do not use these
	bits.
    * - Bit 6
      - Corrected bit. Indicates that an error was corrected for this data
	block.
    * - Bit 7
      - Error bit. Indicates that an uncorrectable error occurred during
	reception of this block.


.. _v4l2-rds-block-codes:

.. tabularcolumns:: |p{6.4cm}|p{2.0cm}|p{1.2cm}|p{7.0cm}|

.. flat-table:: Block defines
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 1 5

    * - V4L2_RDS_BLOCK_MSK
      -
      - 7
      - Mask for bits 0-2 to get the block ID.
    * - V4L2_RDS_BLOCK_A
      -
      - 0
      - Block A.
    * - V4L2_RDS_BLOCK_B
      -
      - 1
      - Block B.
    * - V4L2_RDS_BLOCK_C
      -
      - 2
      - Block C.
    * - V4L2_RDS_BLOCK_D
      -
      - 3
      - Block D.
    * - V4L2_RDS_BLOCK_C_ALT
      -
      - 4
      - Block C'.
    * - V4L2_RDS_BLOCK_INVALID
      - read-only
      - 7
      - An invalid block.
    * - V4L2_RDS_BLOCK_CORRECTED
      - read-only
      - 0x40
      - A bit error was detected but corrected.
    * - V4L2_RDS_BLOCK_ERROR
      - read-only
      - 0x80
      - An uncorrectable error occurred.