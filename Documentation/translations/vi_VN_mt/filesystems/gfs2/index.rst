.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/gfs2/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Hệ thống tệp toàn cầu 2
=======================

Tổng quan
========

GFS2 là một hệ thống tập tin cụm. Nó cho phép một cụm máy tính
đồng thời sử dụng một thiết bị khối được chia sẻ giữa chúng (với FC,
iSCSI, NBD, v.v.).  GFS2 đọc và ghi vào thiết bị khối giống như thiết bị cục bộ
hệ thống tập tin mà còn sử dụng mô-đun khóa để cho phép các máy tính phối hợp
I/O của họ để duy trì tính nhất quán của hệ thống tệp.  Một trong những điều tiện lợi
các tính năng của GFS2 là tính nhất quán hoàn hảo - những thay đổi được thực hiện đối với hệ thống tệp
trên một máy hiển thị ngay lập tức trên tất cả các máy khác trong cụm.

GFS2 sử dụng cơ chế khóa liên nút có thể hoán đổi cho nhau, hiện tại
cơ chế được hỗ trợ là:

khóa_nolock
    - cho phép GFS2 được sử dụng làm hệ thống tệp cục bộ

khóa_dlm
    - sử dụng trình quản lý khóa phân tán (dlm) để khóa giữa các nút.
      Dlm được tìm thấy tại linux/fs/dlm/

lock_dlm phụ thuộc vào hệ thống quản lý cụm không gian người dùng được tìm thấy
tại URL ở trên.

Để sử dụng GFS2 làm hệ thống tệp cục bộ, không có hệ thống phân cụm bên ngoài nào
cần thiết, đơn giản là::

$ mkfs -t gfs2 -p lock_nolock -j 1/dev/block_device
  $ mount -t gfs2 /dev/block_device /dir

Gói gfs2-utils được yêu cầu trên tất cả các nút cụm và đối với lock_dlm, bạn
cũng sẽ cần các tiện ích không gian người dùng dlm và corosync được định cấu hình theo
tài liệu.

gfs2-utils có thể được tìm thấy tại ZZ0000ZZ

GFS2 không tương thích trên đĩa với các phiên bản trước của GFS, nhưng nó
khá gần.

Các trang hướng dẫn sau đây có sẵn từ gfs2-utils:

==============================================================
  fsck.gfs2 để sửa chữa hệ thống tập tin
  gfs2_grow để mở rộng hệ thống tập tin trực tuyến
  gfs2_jadd để thêm tạp chí vào hệ thống tập tin trực tuyến
  tunegfs2 để thao tác, kiểm tra và điều chỉnh hệ thống tập tin
  gfs2_convert để chuyển đổi hệ thống tập tin gfs thành GFS2 tại chỗ
  mkfs.gfs2 để tạo một hệ thống tập tin
  ==============================================================

Ghi chú thực hiện
====================

.. toctree::
   :maxdepth: 1

   glocks
   uevents