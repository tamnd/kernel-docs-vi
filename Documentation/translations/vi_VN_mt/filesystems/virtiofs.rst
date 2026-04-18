.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/virtiofs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _virtiofs_index:

========================================================
virtiofs: virtio-fs Host<->hệ thống tệp chia sẻ khách
========================================================

- Bản quyền (C) 2019 Red Hat, Inc.

Giới thiệu
============
Hệ thống tệp virtiofs dành cho Linux triển khai trình điều khiển cho ảo hóa song song
Thiết bị VIRTIO "virtio-fs" để chia sẻ hệ thống tệp máy chủ <-> khách.  Nó cho phép một
guest để gắn một thư mục đã được xuất trên máy chủ.

Khách thường yêu cầu quyền truy cập vào các tệp nằm trên máy chủ hoặc hệ thống từ xa.
Các trường hợp sử dụng bao gồm cung cấp tệp cho khách mới trong quá trình cài đặt,
khởi động từ hệ thống tập tin gốc nằm trên máy chủ, lưu trữ liên tục cho
khách không quốc tịch hoặc phù du và chia sẻ thư mục giữa các khách.

Mặc dù có thể sử dụng các hệ thống tệp mạng hiện có cho một số
nhiệm vụ, chúng yêu cầu các bước cấu hình khó tự động hóa và chúng
hiển thị mạng lưu trữ cho khách.  Thiết bị virtio-fs được thiết kế để
giải quyết những vấn đề này bằng cách cung cấp quyền truy cập hệ thống tệp mà không cần kết nối mạng.

Hơn nữa, thiết bị virtio-fs tận dụng lợi thế của vị trí đồng vị trí của
khách và máy chủ để tăng hiệu suất và cung cấp ngữ nghĩa không
có thể với các hệ thống tập tin mạng.

Cách sử dụng
============
Gắn hệ thống tệp có thẻ ZZ0000ZZ trên ZZ0001ZZ:

.. code-block:: sh

  guest# mount -t virtiofs myfs /mnt

Vui lòng xem ZZ0000ZZ để biết chi tiết về cách định cấu hình QEMU
và daemon virtiofsd.

Tùy chọn gắn kết
----------------

virtiofs hỗ trợ các tùy chọn gắn VFS chung, ví dụ: gắn lại,
ro, rw, context, v.v. Nó cũng hỗ trợ các tùy chọn gắn FUSE.

hành vi tại một thời điểm
^^^^^^^^^^^^^^^^^^^^^^^^^

Các tùy chọn gắn kết liên quan đến atime, ví dụ: noatime, strictatime,
bị bỏ qua. Hành vi tại một thời điểm của những người có tài năng cũng giống như
hệ thống tập tin cơ bản của thư mục đã được xuất
trên máy chủ.

Nội bộ
=========
Vì thiết bị virtio-fs sử dụng giao thức FUSE cho các yêu cầu hệ thống tệp, nên
hệ thống tệp virtiofs cho Linux được tích hợp chặt chẽ với hệ thống tệp FUSE
khách hàng.  Khách đóng vai trò là máy khách FUSE trong khi máy chủ đóng vai trò là FUSE
máy chủ.  Giao diện /dev/fuse giữa kernel và không gian người dùng được thay thế
với giao diện thiết bị virtio-fs.

Các yêu cầu FUSE được đặt vào hàng đợi và được máy chủ xử lý.  các
phần phản hồi của bộ đệm được điền bởi máy chủ và bộ xử lý khách
việc hoàn thành yêu cầu.

Ánh xạ /dev/fuse tới Virtqueues yêu cầu giải quyết những khác biệt về ngữ nghĩa
giữa /dev/fuse và virtqueues.  Mỗi lần thiết bị /dev/fuse được đọc,
Máy khách FUSE có thể chọn yêu cầu chuyển nào, để có thể
ưu tiên một số yêu cầu nhất định hơn những yêu cầu khác.  Virtqueues có ngữ nghĩa hàng đợi và
không thể thay đổi thứ tự các yêu cầu đã được xếp hàng đợi.
Điều này đặc biệt quan trọng nếu hàng đợi đức hạnh trở nên đầy đủ vì lúc đó
không thể thêm các yêu cầu có mức độ ưu tiên cao.  Để giải quyết sự khác biệt này,
thiết bị virtio-fs sử dụng hàng đợi virtio "hiprio" dành riêng cho các yêu cầu
được ưu tiên hơn các yêu cầu thông thường.