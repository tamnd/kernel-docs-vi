.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/ext4/mmp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Bảo vệ nhiều núi
-------------------------

Bảo vệ nhiều ngàm (MMP) là một tính năng bảo vệ
hệ thống tập tin chống lại nhiều máy chủ đang cố gắng sử dụng hệ thống tập tin
đồng thời. Khi một hệ thống tập tin được mở (để gắn kết hoặc fsck,
v.v.), mã MMP chạy trên nút (gọi nó là nút A) sẽ kiểm tra một
số thứ tự. Nếu số thứ tự là EXT4_MMP_SEQ_CLEAN,
mở tiếp tục. Nếu số thứ tự là EXT4_MMP_SEQ_FSCK thì
fsck (hy vọng) đang chạy và mở không thành công ngay lập tức. Nếu không,
mã mở sẽ đợi gấp đôi khoảng thời gian kiểm tra MMP được chỉ định và kiểm tra
số thứ tự nữa. Nếu số thứ tự đã thay đổi thì
hệ thống tập tin đang hoạt động trên một máy khác và việc mở không thành công. Nếu MMP
vượt qua tất cả các bước kiểm tra đó, số thứ tự MMP mới sẽ được tạo
và được ghi vào khối MMP, quá trình gắn kết tiếp tục.

Trong khi hệ thống tập tin đang hoạt động, kernel sẽ thiết lập bộ đếm thời gian để kiểm tra lại
Khối MMP tại khoảng thời gian kiểm tra MMP được chỉ định. Để thực hiện việc kiểm tra lại,
số thứ tự MMP được đọc lại; nếu nó không khớp với bộ nhớ trong
Số thứ tự MMP, sau đó một nút khác (nút B) đã gắn kết
hệ thống tập tin và nút A kể lại hệ thống tập tin chỉ đọc. Nếu
số thứ tự trùng nhau thì số thứ tự được tăng lên cả về
bộ nhớ và trên đĩa, quá trình kiểm tra lại hoàn tất.

Tên máy chủ và tên tệp thiết bị được ghi vào khối MMP bất cứ khi nào
một hoạt động mở thành công. Mã MMP không sử dụng các giá trị này; họ
được cung cấp hoàn toàn cho mục đích thông tin.

Tổng kiểm tra được tính toán dựa trên cấu trúc FS UUID và MMP.
Cấu trúc MMP (ZZ0000ZZ) như sau:

.. list-table::
   :widths: 8 12 20 40
   :header-rows: 1

   * - Offset
     - Type
     - Name
     - Description
   * - 0x0
     - __le32
     - mmp_magic
     - Magic number for MMP, 0x004D4D50 (“MMP”).
   * - 0x4
     - __le32
     - mmp_seq
     - Sequence number, updated periodically.
   * - 0x8
     - __le64
     - mmp_time
     - Time that the MMP block was last updated.
   * - 0x10
     - char[64]
     - mmp_nodename
     - Hostname of the node that opened the filesystem.
   * - 0x50
     - char[32]
     - mmp_bdevname
     - Block device name of the filesystem.
   * - 0x70
     - __le16
     - mmp_check_interval
     - The MMP re-check interval, in seconds.
   * - 0x72
     - __le16
     - mmp_pad1
     - Zero.
   * - 0x74
     - __le32[226]
     - mmp_pad2
     - Zero.
   * - 0x3FC
     - __le32
     - mmp_checksum
     - Checksum of the MMP block.