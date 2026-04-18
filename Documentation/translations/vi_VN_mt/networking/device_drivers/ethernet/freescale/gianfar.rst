.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/freescale/gianfar.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==============================
Trình điều khiển Ethernet Gianfar
===========================

:Tác giả: Andy Fleming <afleming@freescale.com>
:Cập nhật: 28-07-2005


Giảm tải tổng kiểm tra
===================

Bộ điều khiển eTSEC (được đưa vào các phần đầu tiên từ cuối năm 2005 như
8548) có khả năng thực hiện kiểm tra TCP, UDP và IP
trong phần cứng.  Nhân Linux chỉ giảm tải TCP và UDP
tổng kiểm tra (và luôn thực hiện tổng kiểm tra tiêu đề giả), vì vậy
trình điều khiển chỉ hỗ trợ kiểm tra tổng cho TCP/IP và UDP/IP
gói.  Sử dụng ethtool để bật hoặc tắt tính năng này cho RX
và TX.

VLAN
====

Để sử dụng VLAN, vui lòng tham khảo tài liệu Linux trên
cấu hình VLAN.  Trình điều khiển gianfar hỗ trợ chèn phần cứng và
trích xuất các tiêu đề VLAN nhưng không lọc.  Quá trình lọc sẽ được
được thực hiện bởi kernel.

Đa phương tiện
============

Trình điều khiển gianfar hỗ trợ sử dụng bảng băm nhóm trên
TSEC (và bảng băm mở rộng trên eTSEC) cho phát đa hướng
lọc.  Trên eTSEC, các thanh ghi MAC khớp chính xác được sử dụng
trước các bảng băm.  Xem tài liệu Linux về cách tham gia
nhóm phát đa hướng.

Phần đệm
=======

Trình điều khiển gianfar hỗ trợ đệm các khung nhận được với 2 byte
để căn chỉnh tiêu đề IP thành ranh giới 16 byte, khi được hỗ trợ bởi
phần cứng.

Ethtool
=======

Driver gianfar hỗ trợ sử dụng ethtool cho nhiều người
các tùy chọn cấu hình.  Hiện tại bạn chỉ được chạy ethtool
các giao diện mở.  Xem tài liệu ethtool để biết chi tiết.