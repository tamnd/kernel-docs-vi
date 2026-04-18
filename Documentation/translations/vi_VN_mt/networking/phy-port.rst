.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/phy-port.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _phy_port:

===================
Cổng Ethernet
=================

Tài liệu này là mô tả cơ bản về cơ sở hạ tầng phy_port,
được giới thiệu để thể hiện các giao diện vật lý của các thiết bị Ethernet.

Không có phy_port, chúng ta đã có khá nhiều thông tin về những gì
giao diện truyền thông của NIC có thể thực hiện và trông giống như, thông qua
Thuộc tính ZZ0000ZZ,
trong đó bao gồm:

- NIC có thể làm gì thông qua trường ZZ0000ZZ
 - Đối tác liên kết quảng cáo gì thông qua ZZ0001ZZ
 - Những tính năng chúng tôi đang quảng cáo thông qua ZZ0002ZZ

Chúng tôi cũng có thông tin về số lượng cặp và loại PORT. Những cài đặt này
được xây dựng bằng cách tổng hợp các thông tin được báo cáo bởi các thiết bị khác nhau
đang ngồi trên liên kết:

- Bản thân NIC, thông qua lệnh gọi lại ZZ0000ZZ
  - Thông tin chính xác từ MAC và PCS bằng cách sử dụng phyllink trong trình điều khiển MAC
  - Thông tin do thiết bị PHY báo cáo
  - Thông tin được báo cáo bởi mô-đun SFP (có thể bao gồm PHY)

Tuy nhiên, mô hình này bắt đầu bộc lộ những hạn chế khi chúng ta xem xét các thiết bị
có nhiều hơn một giao diện đa phương tiện. Trong trường hợp đó, chỉ có thông tin về
giao diện được sử dụng tích cực được báo cáo và không thể biết điều gì
các giao diện khác có thể làm được. Trên thực tế, chúng ta có rất ít thông tin về việc liệu
hoặc không có bất kỳ giao diện truyền thông nào khác.

Mục tiêu của việc biểu diễn phy_port là cung cấp một cách biểu diễn một
giao diện vật lý của NIC, bất kể cổng nào đang điều khiển cổng (NIC đến
chương trình cơ sở, mô-đun SFP, Ethernet PHY).

Ví dụ về giao diện đa cổng
==============================

Cho đến nay, một số trường hợp NIC đa giao diện đã được quan sát:

Mux MII nội bộ::

+-------------------+
  ZZ0000ZZ
  ZZ0001ZZ +------+
  ZZ0002ZZ ZZ0003ZZ PHY |
  ZZ0004ZZ MAC ZZ0005ZZ Mux ZZ0006ZZ +------+ +------+
  ZZ0007ZZ ZZ0008ZZ SFP |
  ZZ0009ZZ +------+
  +-------------------+

Mux nội bộ với PHY nội bộ::

+---------------+
  ZZ0000ZZ
  |          +------+ +------+
  ZZ0001ZZ ZZ0002ZZ PHY |
  ZZ0003ZZ MAC ZZ0004ZZ Mux | +------+ +------+
  ZZ0005ZZ ZZ0006ZZ SFP |
  ZZ0007ZZ +------+
  +---------------+

Mux bên ngoài::

+----------+
  ZZ0000ZZ +------+ +------+
  ZZ0001ZZ ZZ0002ZZ--ZZ0003ZZ
  ZZ0004ZZ ZZ0005ZZ +------+
  ZZ0006ZZ MAC ZZ0007ZZ Mux |  +------+
  ZZ0008ZZ ZZ0009ZZ--ZZ0010ZZ
  ZZ0011ZZ +------+ +------+
  ZZ0012ZZ |
  |    GPIO-------+
  +----------+

PHY cổng đôi::

+----------+
  ZZ0000ZZ +------+
  ZZ0001ZZ ZZ0002ZZ--- RJ45
  ZZ0003ZZ ZZ0004ZZ
  ZZ0005ZZ MAC ZZ0006ZZ PHY |   +------+
  ZZ0007ZZ ZZ0008ZZ---ZZ0009ZZ
  +----------+ +------+ +------+

phy_port nhằm mục đích cung cấp một đường dẫn để hỗ trợ tất cả các cấu trúc liên kết trên, bằng cách
trình bày các giao diện truyền thông theo cách không thể biết được điều gì đang thúc đẩy
giao diện. đối tượng struct phy_port có tập hợp các hoạt động gọi lại riêng và
cuối cùng sẽ có thể báo cáo ksettings của riêng mình::

_____ +------+
            ( )------ZZ0000ZZ
 +------+ ( ) +------+
 ZZ0001ZZ--( ??? )
 +------+ ( ) +------+
            (_____)------ZZ0002ZZ
                        +------+

Các bước tiếp theo
==========

Khi viết tài liệu này, chỉ các cổng được điều khiển bởi thiết bị PHY mới được
được hỗ trợ. Các bước tiếp theo sẽ là thêm Netlink API để hiển thị những
vào không gian người dùng và thêm hỗ trợ cho các cổng thô (được điều khiển bởi một số chương trình cơ sở và trực tiếp
được quản lý bởi trình điều khiển NIC).

Một nhiệm vụ song song khác là giới thiệu khung kết hợp MII để cho phép
kiểm soát các thiết lập nhiều cổng trình điều khiển không phải PHY.