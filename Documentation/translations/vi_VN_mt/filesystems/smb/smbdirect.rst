.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/smb/smbdirect.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
SMB Trực tiếp - SMB3 trên RDMA
==============================

Tài liệu này mô tả cách thiết lập máy khách và máy chủ Linux SMB để
sử dụng RDMA.

Tổng quan
========
Máy khách nhân Linux SMB hỗ trợ SMB Direct, đây là một phương thức vận chuyển
lược đồ cho SMB3 sử dụng RDMA (Truy cập bộ nhớ trực tiếp từ xa) để cung cấp
thông lượng cao và độ trễ thấp bằng cách bỏ qua TCP/IP truyền thống
ngăn xếp.
SMB Trực tiếp trên máy khách Linux SMB có thể được kiểm tra với KSMBD - một
máy chủ SMB không gian hạt nhân.

Cài đặt
=============
- Cài đặt thiết bị RDMA. Miễn là trình điều khiển thiết bị RDMA được hỗ trợ
  bởi kernel, nó sẽ hoạt động. Điều này bao gồm cả trình giả lập phần mềm (phần mềm
  RoCE, iWARP mềm) và các thiết bị phần cứng (InfiniBand, RoCE, iWARP).

- Cài đặt kernel có hỗ trợ SMB Direct. Bản phát hành kernel đầu tiên cho
  hỗ trợ SMB Direct trên cả phía máy khách và máy chủ là 5.15. Vì vậy,
  cần có bản phân phối tương thích với kernel 5.15 trở lên.

- Cài đặt cifs-utils, cung cấp lệnh ZZ0000ZZ để mount SMB
  cổ phiếu.

- Cấu hình ngăn xếp RDMA

Đảm bảo rằng cấu hình kernel của bạn đã bật hỗ trợ RDMA. Dưới
  Trình điều khiển thiết bị -> Hỗ trợ Infiniband, cập nhật cấu hình kernel lên
  kích hoạt hỗ trợ Infiniband.

Kích hoạt hỗ trợ IB HCA thích hợp hoặc hỗ trợ bộ điều hợp iWARP,
  tùy thuộc vào phần cứng của bạn.

Nếu bạn đang sử dụng InfiniBand, hãy bật hỗ trợ IP-over-InfiniBand.

Đối với RDMA mềm, hãy bật iWARP mềm (ZZ0000ZZ) hoặc RoCE mềm
  (ZZ0001ZZ) mô-đun. Cài đặt gói ZZ0002ZZ và sử dụng
  Lệnh ZZ0003ZZ để tải mô-đun và tạo một
  Giao diện RDMA.

ví dụ. nếu giao diện ethernet cục bộ của bạn là ZZ0000ZZ, bạn có thể sử dụng:

    .. code-block:: bash

        sudo rdma link add siw0 type siw netdev eth0

- Kích hoạt tính năng hỗ trợ trực tiếp SMB cho cả máy chủ và máy khách trong kernel
  cấu hình.

Thiết lập máy chủ

    .. code-block:: text

        Network File Systems  --->
            <M> SMB3 server support
                [*] Support for SMB Direct protocol

Thiết lập máy khách

    .. code-block:: text

        Network File Systems  --->
            <M> SMB3 and CIFS support (advanced network filesystem)
                [*] SMB Direct support

- Xây dựng và cài đặt kernel. Hỗ trợ trực tiếp SMB sẽ được bật trong
  mô-đun cifs.ko và ksmbd.ko.

Thiết lập và sử dụng
================

- Thiết lập và khởi động máy chủ KSMBD như được mô tả trong ZZ0000ZZ.
  Đồng thời thêm tham số "hỗ trợ đa kênh máy chủ = có" vào ksmbd.conf.

- Trên máy khách, mount chia sẻ với tùy chọn mount ZZ0000ZZ để sử dụng SMB Direct
  (chỉ định SMB phiên bản 3.0 trở lên bằng ZZ0001ZZ).

Ví dụ:

    .. code-block:: bash

        mount -t cifs //server/share /mnt/point -o vers=3.1.1,rdma

- Để xác minh rằng khung gắn đang sử dụng SMB Direct, bạn có thể kiểm tra dmesg để tìm
  dòng nhật ký sau khi lắp:

    .. code-block:: text

        CIFS: VFS: RDMA transport established

Hoặc, xác minh tùy chọn gắn ZZ0000ZZ để chia sẻ trong ZZ0001ZZ:

    .. code-block:: bash

        cat /proc/mounts | grep cifs