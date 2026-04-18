.. SPDX-License-Identifier: BSD-3-Clause

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/netlink/netlink-raw.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================================================
Hỗ trợ đặc tả Netlink cho các họ Netlink thô
===========================================================

Tài liệu này mô tả các thuộc tính bổ sung được yêu cầu bởi Netlink thô
các họ như ZZ0000ZZ sử dụng giao thức ZZ0001ZZ
đặc điểm kỹ thuật.

Đặc điểm kỹ thuật
=============

Lược đồ netlink-raw mở rộng ZZ0000ZZ
lược đồ với các thuộc tính cần thiết để xác định số giao thức và
ID multicast được sử dụng bởi các dòng liên kết mạng thô. Xem ZZ0001ZZ để biết thêm
thông tin. Các họ liên kết mạng thô cũng sử dụng các loại cụ thể
các tin nhắn phụ.

Quả cầu
-------

proton
~~~~~~~~

Thuộc tính ZZ0000ZZ được sử dụng để chỉ định số giao thức sẽ sử dụng khi
mở một ổ cắm netlink.

.. code-block:: yaml

  # SPDX-License-Identifier: ((GPL-2.0 WITH Linux-syscall-note) OR BSD-3-Clause)

  name: rt-addr
  protocol: netlink-raw
  protonum: 0             # part of the NETLINK_ROUTE protocol


Thuộc tính nhóm multicast
--------------------------

giá trị
~~~~~

Thuộc tính ZZ0000ZZ được sử dụng để chỉ định ID nhóm sẽ sử dụng cho phát đa hướng
đăng ký nhóm.

.. code-block:: yaml

  mcast-groups:
    list:
      -
        name: rtnlgrp-ipv4-ifaddr
        value: 5
      -
        name: rtnlgrp-ipv6-ifaddr
        value: 9
      -
        name: rtnlgrp-mctp-ifaddr
        value: 34

Tin nhắn phụ
------------

Một số họ liên kết mạng thô như
ZZ0000ZZ và
ZZ0001ZZ sử dụng lồng thuộc tính làm
trừu tượng để mang thông tin cụ thể của mô-đun.

Về mặt khái niệm, nó trông như sau::

[OUTER NEST HOẶC MESSAGE LEVEL]
      [GENERIC ATTR 1]
      [GENERIC ATTR 2]
      [GENERIC ATTR 3]
      [GENERIC ATTR - giấy gói]
        [MODULE SPECIFIC ATTR 1]
        [MODULE SPECIFIC ATTR 2]

ZZ0000ZZ ở cấp độ bên ngoài được xác định trong lõi (hoặc rt_link hoặc
core TC), trong khi các trình điều khiển cụ thể, bộ phân loại TC, qdiscs, v.v. có thể mang
thông tin riêng được gói trong ZZ0001ZZ. Mặc dù
ví dụ trên hiển thị các thuộc tính lồng bên trong trình bao bọc, các mô-đun nói chung
có toàn quyền tự do xác định định dạng của tổ. Trong thực tế tải trọng của
attr của trình bao bọc có các đặc điểm rất giống với thông báo liên kết mạng. Nó có thể
chứa tiêu đề/cấu trúc cố định, thuộc tính liên kết mạng hoặc cả hai. Bởi vì
những đặc điểm chung đó mà chúng tôi gọi là tải trọng của thuộc tính trình bao bọc là
một tin nhắn phụ.

Thuộc tính thông điệp phụ sử dụng giá trị của thuộc tính khác làm khóa chọn để
chọn định dạng tin nhắn phụ phù hợp. Ví dụ: nếu thuộc tính sau có
đã được giải mã:

.. code-block:: json

  { "kind": "gre" }

và chúng tôi gặp phải thông số thuộc tính sau:

.. code-block:: yaml

  -
    name: data
    type: sub-message
    sub-message: linkinfo-data-msg
    selector: kind

Sau đó, chúng tôi tìm kiếm định nghĩa tin nhắn phụ có tên ZZ0000ZZ và sử dụng
giá trị của thuộc tính ZZ0001ZZ tức là ZZ0002ZZ làm khóa để chọn
định dạng đúng cho tin nhắn phụ:

.. code-block:: yaml

  sub-messages:
    name: linkinfo-data-msg
    formats:
      -
        value: bridge
        attribute-set: linkinfo-bridge-attrs
      -
        value: gre
        attribute-set: linkinfo-gre-attrs
      -
        value: geneve
        attribute-set: linkinfo-geneve-attrs

Điều này sẽ giải mã giá trị thuộc tính dưới dạng thông báo phụ với tập thuộc tính
gọi ZZ0000ZZ là không gian thuộc tính.

Một tin nhắn phụ có thể có ZZ0000ZZ tùy chọn theo sau là 0 hoặc nhiều hơn
thuộc tính từ ZZ0001ZZ. Ví dụ như sau
Tin nhắn phụ ZZ0002ZZ xác định các định dạng tin nhắn sử dụng hỗn hợp
ZZ0003ZZ, ZZ0004ZZ hoặc cả hai cùng nhau:

.. code-block:: yaml

  sub-messages:
    -
      name: tc-options-msg
      formats:
        -
          value: bfifo
          fixed-header: tc-fifo-qopt
        -
          value: cake
          attribute-set: tc-cake-attrs
        -
          value: netem
          fixed-header: tc-netem-qopt
          attribute-set: tc-netem-attrs

Lưu ý rằng thuộc tính selector phải xuất hiện trong thông báo liên kết mạng trước bất kỳ
thuộc tính thông điệp phụ phụ thuộc vào nó.

Nếu một thuộc tính như ZZ0000ZZ được xác định ở nhiều cấp độ lồng, thì một
bộ chọn tin nhắn phụ sẽ được giải quyết bằng cách sử dụng giá trị 'gần nhất' với bộ chọn.
Ví dụ: nếu cùng một tên thuộc tính được xác định trong ZZ0001ZZ lồng nhau
cùng với bộ chọn tin nhắn phụ và cả ở ZZ0002ZZ cấp cao nhất, sau đó
bộ chọn sẽ được giải quyết bằng giá trị 'gần nhất' với bộ chọn. Nếu
giá trị không có trong thông báo ở cùng mức như được xác định trong thông số kỹ thuật
thì đây là một lỗi.

Định nghĩa cấu trúc lồng nhau
-------------------------

Nhiều họ liên kết mạng thô như ZZ0000ZZ
sử dụng các định nghĩa cấu trúc lồng nhau. Lược đồ ZZ0001ZZ làm cho nó
có thể nhúng cấu trúc trong định nghĩa cấu trúc bằng ZZ0002ZZ
tài sản. Ví dụ: định nghĩa cấu trúc sau đây nhúng
Định nghĩa cấu trúc ZZ0003ZZ cho cả ZZ0004ZZ và ZZ0005ZZ
thành viên của ZZ0006ZZ.

.. code-block:: yaml

  -
    name: tc-tbf-qopt
    type: struct
    members:
      -
        name: rate
        type: binary
        struct: tc-ratespec
      -
        name: peakrate
        type: binary
        struct: tc-ratespec
      -
        name: limit
        type: u32
      -
        name: buffer
        type: u32
      -
        name: mtu
        type: u32