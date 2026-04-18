.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/s390/qeth.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Trình điều khiển Ethernet IBM s390 QDIO
=============================

Hỗ trợ cổng cầu OSA và HiperSockets
========================================

Sự kiện
-------

Để tạo ra các sự kiện, thiết bị phải được gán một vai trò
Cổng cầu chính hoặc cổng cầu thứ cấp. Để biết thêm thông tin, xem
"Kết nối z/VM, SC24-6174".

Khi chạy trên phần cứng Cổng có khả năng kết nối OSA hoặc HiperSockets và trạng thái
của một số thiết bị Bridge Port được định cấu hình khi kênh thay đổi, udev
sự kiện với ACTION=CHANGE được phát ra thay mặt cho sự kiện tương ứng
thiết bị ccwgroup. Sự kiện này có các thuộc tính sau:

BRIDGEPORT=thay đổi trạng thái
  cho biết thiết bị Bridge Port đã thay đổi
  trạng thái của nó.

ROLE={chính|secondary|none}
  vai trò được giao cho cảng.

STATE={active|standby|inactive}
  trạng thái mới giả định của cảng.

Khi chạy trên phần cứng Cổng có khả năng cầu nối HiperSockets với địa chỉ máy chủ
thông báo được bật, một sự kiện udev với ACTION=CHANGE sẽ được phát ra.
Nó được phát ra thay mặt cho thiết bị ccwgroup tương ứng khi một máy chủ
hoặc VLAN đã được đăng ký hoặc chưa đăng ký trên mạng do thiết bị phục vụ.
Sự kiện này có các thuộc tính sau:

BRIDGEDHOST={đặt lại|register|deregister|hủy bỏ}
  địa chỉ máy chủ
  thông báo được bắt đầu lại, máy chủ mới hoặc VLAN được đăng ký hoặc
  đã hủy đăng ký trên kênh Bridge Port HiperSockets hoặc địa chỉ
  thông báo bị hủy bỏ.

VLAN=số-vlan-id
  ID VLAN nơi xảy ra sự kiện. Không bao gồm
  nếu không có VLAN nào tham gia vào sự kiện.

MAC=xx:xx:xx:xx:xx:xx
  Địa chỉ MAC của máy chủ đang được đăng ký
  hoặc hủy đăng ký khỏi kênh HiperSockets. Không được báo cáo nếu
  sự kiện báo cáo việc tạo hoặc phá hủy VLAN.

NTOK_BUSID=x.y.zzzz
  ID bus thiết bị (CSSID, SSID và số thiết bị).

NTOK_IID=xx
  thiết bị IID.

NTOK_CHPID=xx
  thiết bị CHPID.

NTOK_CHID=xxxx
  ID kênh thiết bị.

Lưu ý rằng các thuộc tính ZZ0000ZZ đề cập đến các thiết bị không phải là thiết bị
được kết nối với hệ thống mà hệ điều hành đang chạy.
