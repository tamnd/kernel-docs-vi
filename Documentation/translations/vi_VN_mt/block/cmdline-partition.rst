.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/block/cmdline-partition.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================================
Phân tích phân vùng dòng lệnh của thiết bị nhúng
==============================================

Tùy chọn dòng lệnh "blkdevparts" bổ sung thêm hỗ trợ cho việc đọc
chặn bảng phân vùng thiết bị từ dòng lệnh kernel.

Nó thường được sử dụng cho các thiết bị nhúng khối cố định (eMMC).
Nó không có MBR nên tiết kiệm không gian lưu trữ. Bootloader có thể dễ dàng truy cập
theo địa chỉ tuyệt đối của dữ liệu trên thiết bị khối.
Người dùng có thể dễ dàng thay đổi phân vùng.

Định dạng cho dòng lệnh giống như mtdparts:

blkdevparts=<blkdev-def>[;<blkdev-def>]
  <blkdev-def> := <blkdev-id>:<partdef>[,<partdef>]
    <partdef> := <size>[@<offset>](tên bộ phận)

<blkdev-id>
    chặn tên đĩa thiết bị. Thiết bị nhúng sử dụng thiết bị khối cố định.
    Tên đĩa của nó cũng được cố định, chẳng hạn như: mmcblk0, mmcblk1, mmcblk0boot0.

<kích thước>
    kích thước phân vùng, tính bằng byte, chẳng hạn như: 512, 1m, 1G.
    kích thước có thể chứa hậu tố tùy chọn (chữ hoa hoặc chữ thường):

K, M, G, T, P, E.

"-" được sử dụng để biểu thị tất cả không gian còn lại.

<bù đắp>
    địa chỉ bắt đầu phân vùng, tính bằng byte.
    phần bù có thể chứa hậu tố tùy chọn của (chữ hoa hoặc chữ thường):

K, M, G, T, P, E.

(tên một phần)
    tên phân vùng. Kernel gửi sự kiện có "PARTNAME". Ứng dụng có thể
    tạo liên kết chặn phân vùng thiết bị với tên "PARTNAME".
    Ứng dụng không gian người dùng có thể truy cập phân vùng theo tên phân vùng.

ro
    chỉ đọc. Gắn cờ phân vùng là chỉ đọc.

Ví dụ:

Tên đĩa eMMC là "mmcblk0" và "mmcblk0boot0".

bootargs::

'blkdevparts=mmcblk0:1G(data0),1G(data1),-;mmcblk0boot0:1m(boot)ro,-(kernel)'

dmesg::

mmcblk0: p1(data0) p2(data1) p3()
    mmcblk0boot0: p1(boot) p2(kernel)
