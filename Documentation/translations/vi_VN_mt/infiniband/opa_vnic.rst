.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/infiniband/opa_vnic.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================================================================
Bộ điều khiển giao diện mạng ảo Intel Omni-Path (OPA) (VNIC)
=======================================================================

Tính năng Bộ điều khiển giao diện mạng ảo Intel Omni-Path (OPA) (VNIC)
hỗ trợ chức năng Ethernet trên kết cấu Omni-Path bằng cách đóng gói
các gói Ethernet giữa các nút HFI.

Ngành kiến ​​​​trúc
===================
Các mô hình trao đổi của các gói Ethernet được đóng gói Omni-Path
liên quan đến một hoặc nhiều bộ chuyển mạch Ethernet ảo được phủ trên Omni-Path
cấu trúc liên kết vải. Một tập hợp con các nút HFI trên kết cấu Omni-Path là
được phép trao đổi các gói Ethernet được đóng gói trên một mạng cụ thể
chuyển mạch Ethernet ảo. Các bộ chuyển mạch Ethernet ảo có tính logic
mức độ trừu tượng đạt được bằng cách định cấu hình các nút HFI trên kết cấu cho
tạo và xử lý tiêu đề. Trong cấu hình đơn giản nhất tất cả HFI
các nút trên mạng trao đổi kết cấu các gói Ethernet được đóng gói qua một
chuyển mạch Ethernet ảo duy nhất. Một bộ chuyển mạch Ethernet ảo hoạt động hiệu quả
một mạng Ethernet độc lập. Việc cấu hình được thực hiện bởi một
Trình quản lý Ethernet (EM) là một phần của Trình quản lý vải (FM) đáng tin cậy
ứng dụng. Các nút HFI có thể có nhiều VNIC, mỗi nút được kết nối với một
chuyển mạch Ethernet ảo khác nhau. Sơ đồ dưới đây trình bày một trường hợp
của hai bộ chuyển mạch Ethernet ảo với hai nút HFI::

+-------------------+
                               ZZ0000ZZ
                               ZZ0001ZZ
                               ZZ0002ZZ
                               +-------------------+
                                  / /
                                / /
                              / /
                            / /
  +------------------------------------------+ +------------------------------+
  ZZ0003ZZ ZZ0004ZZ
  ZZ0005ZZ ZZ0006ZZ
  ZZ0007ZZ VPORT ZZ0008ZZ VPORT ZZ0009ZZ ZZ0010ZZ VPORT ZZ0011ZZ VPORT ZZ0012ZZ
  +---+----------+------+---------+-+ +-+----------+------+----------+---+
           ZZ0013ZZ
           ZZ0014ZZ
           ZZ0015ZZ
           ZZ0016ZZ
           ZZ0017ZZ
       +----------+-------------+ +-------------+-------------+
       ZZ0018ZZ VNIC ZZ0019ZZ VNIC ZZ0020ZZ
       +----------+-------------+ +-------------+-------------+
       ZZ0021ZZ ZZ0022ZZ
       +------------------------+ +--------------------------+


Định dạng gói Ethernet được đóng gói Omni-Path như được mô tả bên dưới.

========================================================
Trường bit
========================================================
Bốn từ 0:
0-19 SLID (20 bit thấp hơn)
Độ dài 20-30 (bằng 4 từ)
31 bit BECN
32-51 DLID (20 bit thấp hơn)
52-56 SC (Lớp dịch vụ)
57-59 RC (Kiểm soát định tuyến)
60 bit FECN
61-62 L2 (=10, định dạng 16B)
63 LT (=1, Đầu truyền liên kết Flit)

Bốn từ 1:
Loại 0-7 L4 (=0x78 ETHERNET)
8-11 SLID[23:20]
12-15 DLID[23:20]
16-31 PKEY
32-47 Entropy
48-63 Dự trữ

Tứ Từ 2:
0-15 Dự trữ
Tiêu đề 16-31 L4
Gói Ethernet 32-63

Bốn Từ 3 đến N-1:
Gói Ethernet 0-63 (mở rộng pad)

Bốn từ N (cuối cùng):
Gói Ethernet 0-23 (mở rộng pad)
24-55 ICRC
Đuôi 56-61
62-63 LT (=01, Đuôi chuyển liên kết)
========================================================

Gói Ethernet được đệm ở phía phát để đảm bảo rằng VNIC OPA
gói được căn chỉnh theo từng từ. Trường 'Tail' chứa số byte
đệm. Về phía nhận, trường 'Tail' được đọc và phần đệm là
đã xóa (cùng với tiêu đề ICRC, Tail và OPA) trước khi chuyển gói lên
ngăn xếp mạng.

Trường tiêu đề L4 chứa id bộ chuyển mạch Ethernet ảo, cổng VNIC
thuộc về. Ở phía nhận, trường này được sử dụng để khử ghép kênh
đã nhận được gói VNIC đến các cổng VNIC khác nhau.

Thiết kế trình điều khiển
=========================
Thiết kế phần mềm Intel OPA VNIC được trình bày trong sơ đồ bên dưới.
OPA Chức năng VNIC có thành phần phụ thuộc CTNH và CTNH
thành phần độc lập.

Đã thêm hỗ trợ cho thiết bị IB để phân bổ và giải phóng RDMA
thiết bị netdev. Netdev RDMA hỗ trợ giao tiếp mạng
ngăn xếp do đó tạo ra giao diện mạng tiêu chuẩn. OPA_VNIC là RDMA
loại thiết bị netdev.

Chức năng VNIC phụ thuộc CTNH là một phần của trình điều khiển HFI1. Nó
thực hiện các động từ để phân bổ và giải phóng netdev OPA_VNIC RDMA.
Nó liên quan đến việc phân bổ/quản lý tài nguyên CTNH cho chức năng VNIC.
Nó giao tiếp với ngăn xếp mạng và thực hiện các yêu cầu
chức năng net_device_ops. Nó mong đợi Ethernet được đóng gói Omni-Path
các gói trong đường truyền và cung cấp quyền truy cập CTNH vào chúng. Nó dải
tiêu đề Omni-Path từ các gói đã nhận trước khi chuyển chúng đi
ngăn xếp mạng. Nó cũng thực hiện các hoạt động điều khiển netdev RDMA.

Mô-đun OPA VNIC triển khai chức năng VNIC độc lập với CTNH.
Nó bao gồm hai phần. Tác nhân quản lý Ethernet VNIC (VEMA)
tự đăng ký với lõi IB như một máy khách IB và giao tiếp với
Ngăn xếp IB MAD. Nó trao đổi thông tin quản lý với Ethernet
Trình quản lý (EM) và netdev VNIC. Phần netdev VNIC phân bổ và giải phóng
các thiết bị netdev OPA_VNIC RDMA. Nó ghi đè các hàm net_device_ops
được thiết lập bởi trình điều khiển VNIC phụ thuộc CTNH khi cần thiết để đáp ứng mọi điều khiển
hoạt động. Nó cũng xử lý việc đóng gói các gói Ethernet bằng một
Tiêu đề Omni-Path trong đường truyền. Đối với mỗi giao diện VNIC,
thông tin cần thiết cho việc đóng gói được cấu hình bởi EM thông qua VEMA MAD
giao diện. Nó cũng chuyển bất kỳ thông tin điều khiển nào đến trình điều khiển phụ thuộc CTNH
bằng cách gọi các hoạt động điều khiển netdev RDMA::

+-------------------+ +----------------------+
        ZZ0000ZZ ZZ0001ZZ
        ZZ0002ZZ ZZ0003ZZ
        ZZ0004ZZ ZZ0005ZZ
        +-------------------+ +----------------------+
                 ZZ0006ZZ |
                 ZZ0007ZZ |
        +-----------------------------+ |
        ZZ0008ZZ |
        ZZ0009ZZ |
        ZZ0010ZZ |
        ZZ0011ZZ |
        ZZ0012ZZ |
        +-----------------------------+ |
                    ZZ0013ZZ
                    ZZ0014ZZ
           +-------------------+ |
           ZZ0015ZZ |
           +-------------------+ |
                    ZZ0016ZZ
                    ZZ0017ZZ
        +---------------------------------------------+
        ZZ0018ZZ
        ZZ0019ZZ
        ZZ0020ZZ
        +---------------------------------------------+
