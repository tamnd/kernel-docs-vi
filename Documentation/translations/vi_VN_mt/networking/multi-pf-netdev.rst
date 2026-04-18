.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/multi-pf-netdev.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

=================
Netdev đa PF
=================

Nội dung
========

-ZZ0000ZZ
-ZZ0001ZZ
-ZZ0002ZZ
-ZZ0003ZZ
-ZZ0004ZZ
-ZZ0005ZZ
-ZZ0006ZZ

Lý lịch
==========

Công nghệ Multi-PF NIC cho phép một số CPU trong máy chủ nhiều ổ cắm kết nối trực tiếp với
mạng, mỗi mạng thông qua giao diện PCIe chuyên dụng của riêng mình. Thông qua một khai thác kết nối mà
chia các làn PCIe giữa hai thẻ hoặc bằng cách chia đôi khe cắm PCIe cho một thẻ. Cái này
dẫn đến việc loại bỏ lưu lượng mạng đi qua bus nội bộ giữa các ổ cắm,
giảm đáng kể chi phí và độ trễ, ngoài việc giảm mức sử dụng CPU và tăng
thông lượng mạng.

Tổng quan
========

Tính năng này bổ sung hỗ trợ cho việc kết hợp nhiều PF của cùng một cổng trong môi trường Multi-PF trong
một phiên bản netdev. Nó được thực hiện trong lớp netdev. Các phiên bản lớp thấp hơn như pci func,
mục nhập sysfs và liên kết dev được giữ riêng biệt.
Truyền lưu lượng truy cập qua các thiết bị khác nhau thuộc các ổ cắm NUMA khác nhau giúp tiết kiệm chéo NUMA
lưu lượng truy cập và cho phép các ứng dụng chạy trên cùng một netdev từ các NUMA khác nhau vẫn có cảm giác
ở gần thiết bị và đạt được hiệu suất được cải thiện.

triển khai mlx5
===================

Multi-PF hoặc Socket-direct trong mlx5 đạt được bằng cách nhóm các PF lại với nhau thuộc cùng một
NIC và đã bật thuộc tính socket-direct, khi tất cả các PF được thăm dò, chúng tôi sẽ tạo một netdev duy nhất
để thể hiện tất cả chúng, một cách đối xứng, chúng tôi hủy netdev bất cứ khi nào bất kỳ PF nào bị xóa.

Các kênh mạng netdev được phân phối giữa tất cả các thiết bị, cấu hình phù hợp sẽ tận dụng được
nút NUMA đóng chính xác khi làm việc trên một ứng dụng/CPU nhất định.

Chúng tôi chọn một PF làm người lãnh đạo chính và nó đảm nhận một vai trò đặc biệt. Các thiết bị khác
(thứ cấp) bị ngắt kết nối khỏi mạng ở cấp độ chip (được đặt ở chế độ im lặng). Trong im lặng
chế độ, không có giao thông hướng nam <-> hướng bắc chạy trực tiếp qua PF thứ cấp. Nó cần sự hỗ trợ của
người lãnh đạo PF (đông <-> giao thông tây) để hoạt động. Tất cả lưu lượng Rx/Tx được điều khiển thông qua mạng chính
đến/từ các phần phụ.

Hiện tại, chúng tôi chỉ giới hạn hỗ trợ cho PF và tối đa hai PF (ổ cắm).

Phân phối kênh
=====================

Chúng tôi phân phối các kênh giữa các PF khác nhau để đạt được hiệu suất nút NUMA cục bộ
trên nhiều nút NUMA.

Mỗi kênh kết hợp hoạt động dựa trên một PF cụ thể, tạo ra tất cả các hàng đợi đường dẫn dữ liệu dựa trên nó. Chúng tôi
phân phối các kênh tới PF theo chính sách quay vòng.

::

Ví dụ cho 2 PF và 5 kênh:
        +--------+--------+
        ZZ0000ZZ PF idx |
        +--------+--------+
        ZZ0001ZZ 0 |
        ZZ0002ZZ 1 |
        ZZ0003ZZ 0 |
        ZZ0004ZZ 1 |
        ZZ0005ZZ 0 |
        +--------+--------+


Lý do chúng tôi thích thi đấu vòng tròn là vì nó ít bị ảnh hưởng bởi những thay đổi về số lượng kênh. các
ánh xạ giữa chỉ mục kênh và PF được cố định, bất kể người dùng định cấu hình bao nhiêu kênh.
Vì số liệu thống kê kênh liên tục trong suốt thời gian đóng kênh nên việc ánh xạ sẽ thay đổi mỗi lần
sẽ khiến số liệu thống kê tích lũy ít thể hiện lịch sử của kênh hơn.

Điều này đạt được bằng cách sử dụng đúng phiên bản thiết bị lõi (mdev) trong mỗi kênh, thay vì chúng
tất cả đều sử dụng cùng một phiên bản trong "priv->mdev".

Khả năng quan sát
=============
Mối quan hệ giữa PF, irq, napi và hàng đợi có thể được quan sát thông qua thông số netlink ::

$ ./tools/net/ynl/pyynl/cli.py --spec Tài liệu/netlink/specs/netdev.yaml --dump queue-get --json='{"ifindex": 13}'
  [{'id': 0, 'ifindex': 13, 'napi-id': 539, 'type': 'rx'},
   {'id': 1, 'ifindex': 13, 'napi-id': 540, 'type': 'rx'},
   {'id': 2, 'ifindex': 13, 'napi-id': 541, 'type': 'rx'},
   {'id': 3, 'ifindex': 13, 'napi-id': 542, 'type': 'rx'},
   {'id': 4, 'ifindex': 13, 'napi-id': 543, 'type': 'rx'},
   {'id': 0, 'ifindex': 13, 'napi-id': 539, 'type': 'tx'},
   {'id': 1, 'ifindex': 13, 'napi-id': 540, 'type': 'tx'},
   {'id': 2, 'ifindex': 13, 'napi-id': 541, 'type': 'tx'},
   {'id': 3, 'ifindex': 13, 'napi-id': 542, 'type': 'tx'},
   {'id': 4, 'ifindex': 13, 'napi-id': 543, 'type': 'tx'}]

$ ./tools/net/ynl/pyynl/cli.py --spec Tài liệu/netlink/specs/netdev.yaml --dump napi-get --json='{"ifindex": 13}'
  [{'id': 543, 'ifindex': 13, 'irq': 42},
   {'id': 542, 'ifindex': 13, 'irq': 41},
   {'id': 541, 'ifindex': 13, 'irq': 40},
   {'id': 540, 'ifindex': 13, 'irq': 39},
   {'id': 539, 'ifindex': 13, 'irq': 36}]

Tại đây bạn có thể quan sát rõ ràng chính sách phân phối kênh của chúng tôi::

$ ls /proc/irq/{36,39,40,41,42}/mlx5* -d -1
  /proc/irq/36/mlx5_comp0@pci:0000:08:00.0
  /proc/irq/39/mlx5_comp0@pci:0000:09:00.0
  /proc/irq/40/mlx5_comp1@pci:0000:08:00.0
  /proc/irq/41/mlx5_comp1@pci:0000:09:00.0
  /proc/irq/42/mlx5_comp2@pci:0000:08:00.0

chỉ đạo
========
PF thứ cấp được đặt ở chế độ "im lặng", nghĩa là chúng bị ngắt kết nối khỏi mạng.

Trong Rx, các bảng điều khiển chỉ thuộc về PF chính và nó có vai trò phân phối tín hiệu vào
lưu lượng truy cập đến các PF khác, thông qua khả năng điều khiển chéo vhca. Vẫn duy trì một bảng RSS mặc định duy nhất,
có khả năng trỏ đến hàng đợi nhận của một PF khác.

Trong Tx, PF chính tạo ra một bảng luồng Tx mới, được đặt bí danh bởi các phần phụ, để chúng có thể
đi ra ngoài mạng thông qua nó.

Ngoài ra, chúng tôi đặt cấu hình XPS mặc định, dựa trên CPU, chọn SQ thuộc về
PF trên cùng nút với CPU.

Ví dụ về cấu hình mặc định của XPS:

(Các) nút NUMA: 2
Nút NUMA0 CPU(s): 0-11
NUMA nút1 CPU(s): 12-23

PF0 trên nút0, PF1 trên nút1.

- /sys/class/net/eth2/queues/tx-0/xps_cpus:000001
- /sys/class/net/eth2/queues/tx-1/xps_cpus:001000
- /sys/class/net/eth2/queues/tx-2/xps_cpus:000002
- /sys/class/net/eth2/queues/tx-3/xps_cpus:002000
- /sys/class/net/eth2/queues/tx-4/xps_cpus:000004
- /sys/class/net/eth2/queues/tx-5/xps_cpus:004000
- /sys/class/net/eth2/queues/tx-6/xps_cpus:000008
- /sys/class/net/eth2/queues/tx-7/xps_cpus:008000
- /sys/class/net/eth2/queues/tx-8/xps_cpus:000010
- /sys/class/net/eth2/queues/tx-9/xps_cpus:010000
- /sys/class/net/eth2/queues/tx-10/xps_cpus:000020
- /sys/class/net/eth2/queues/tx-11/xps_cpus:020000
- /sys/class/net/eth2/queues/tx-12/xps_cpus:000040
- /sys/class/net/eth2/queues/tx-13/xps_cpus:040000
- /sys/class/net/eth2/queues/tx-14/xps_cpus:000080
- /sys/class/net/eth2/queues/tx-15/xps_cpus:080000
- /sys/class/net/eth2/queues/tx-16/xps_cpus:000100
- /sys/class/net/eth2/queues/tx-17/xps_cpus:100000
- /sys/class/net/eth2/queues/tx-18/xps_cpus:000200
- /sys/class/net/eth2/queues/tx-19/xps_cpus:200000
- /sys/class/net/eth2/queues/tx-20/xps_cpus:000400
- /sys/class/net/eth2/queues/tx-21/xps_cpus:400000
- /sys/class/net/eth2/queues/tx-22/xps_cpus:000800
- /sys/class/net/eth2/queues/tx-23/xps_cpus:800000

Các tính năng loại trừ lẫn nhau
===========================

Bản chất của Multi-PF, trong đó các kênh khác nhau hoạt động với các PF khác nhau, xung đột với
các tính năng trạng thái trong đó trạng thái được duy trì ở một trong các PF.
Ví dụ: trong tính năng giảm tải thiết bị TLS, các đối tượng ngữ cảnh đặc biệt được tạo cho mỗi kết nối
và được duy trì trong PF.  Việc chuyển đổi giữa các RQ/SQ khác nhau sẽ làm hỏng tính năng này. Do đó,
chúng tôi vô hiệu hóa sự kết hợp này ngay bây giờ.