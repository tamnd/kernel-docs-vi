.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/freescale/dpaa2/ethernet-driver.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

==================================
Trình điều khiển Ethernet DPAA2
==================================

:Bản quyền: ZZ0000ZZ 2017-2018 NXP

Tệp này cung cấp tài liệu cho trình điều khiển Ethernet Freescale DPAA2.

Nền tảng được hỗ trợ
====================
Trình điều khiển này cung cấp hỗ trợ kết nối mạng cho SoC Freescale DPAA2, ví dụ:
LS2080A, LS2088A, LS1088A.


Tổng quan về kiến ​​trúc
========================
Không giống như các NIC thông thường, trong kiến trúc DPAA2 không có khối phần cứng duy nhất
đại diện cho giao diện mạng; thay vào đó, một số tài nguyên phần cứng riêng biệt
đồng ý cung cấp chức năng kết nối mạng:

- giao diện mạng
- hàng đợi, kênh
- vùng đệm
-MAC/PHY

Tất cả tài nguyên phần cứng được phân bổ và cấu hình thông qua Quản lý
Cổng thông tin phức tạp (MC). MC trừu tượng hóa hầu hết các tài nguyên này dưới dạng đối tượng DPAA2
và hiển thị các ABI mà qua đó chúng có thể được cấu hình và kiểm soát. Một vài
tài nguyên phần cứng, như hàng đợi, không có đối tượng MC tương ứng và
được coi là tài nguyên nội bộ của các đối tượng khác.

Để biết mô tả chi tiết hơn về kiến trúc DPAA2 và đối tượng của nó
trừu tượng xem
ZZ0000ZZ.

Mỗi thiết bị mạng Linux được xây dựng dựa trên Giao diện mạng Datapath (DPNI)
đối tượng và sử dụng Vùng đệm (DPBP), Cổng I/O (DPIO) và Bộ tập trung
(DPCON).

Giao diện cấu hình::

--------------
                ZZ0000ZZ
                 --------------
                     .      .      .
                     .      .      .
             . . . . .      .      . . . . . .
             .              .                .
             .              .                .
         ---------- ---------- ----------
        ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ
         ---------- ---------- ----------
             .              .                .             phần mềm
    ========.  ===========.  =============.  =====================
             .              .                .             phần cứng
         ------------------------------------------
        ZZ0004ZZ
         ------------------------------------------
             .              .                .
             .              .                .
          ------ ------ -------
         ZZ0005ZZ ZZ0006ZZ ZZ0007ZZ
          ------ ------ -------

DPNI là các giao diện mạng không có ánh xạ trực tiếp một-một tới PHY.
DPBP đại diện cho vùng đệm phần cứng. I/O gói được thực hiện trong ngữ cảnh
của các đối tượng DPCON, sử dụng cổng DPIO để quản lý và liên lạc với
tài nguyên phần cứng.

Giao diện đường dẫn dữ liệu (I/O)::

-----------------------------------------------
        ZZ0000ZZ
         -----------------------------------------------
          ZZ0001ZZ |
          ZZ0002ZZ ZZ0003ZZ |
   enqueue|   dequeue| dữ liệu Hạt giống ZZ0005ZZ |
    (Tx) Bộ đệm ZZ0006ZZ có sẵn.ZZ0007ZZ|
          ZZ0008ZZ thông báo|         | |
          ZZ0010ZZ ZZ0011ZZ |
          V ZZ0012ZZ V V
         -----------------------------------------------
        ZZ0013ZZ
         -----------------------------------------------
          ZZ0014ZZ ZZ0015ZZ |          phần mềm
          ZZ0016ZZ ZZ0017ZZ |  ==================
          ZZ0018ZZ ZZ0019ZZ |          phần cứng
         -----------------------------------------------
        ZZ0020ZZ
         -----------------------------------------------
          ZZ0021ZZ |
          ZZ0022ZZ ZZ0023ZZ |
          ZZ0024ZZ ZZ0025ZZ
          V |    ================== V
        ---------------------- |      -------------
 hàng đợi ---------------------- Vùng đệm ZZ0026ZZ |
          ---------------------- |      -------------
                   ==========================
                                Kênh

Cổng I/O Datapath (DPIO) cung cấp các dịch vụ, dữ liệu và hàng đợi
thông báo sẵn có và quản lý vùng đệm. dpio được chia sẻ giữa
tất cả các đối tượng DPAA2 (và ngầm định là tất cả các trình điều khiển hạt nhân DPAA2) hoạt động với dữ liệu
frame, nhưng phải liên kết với CPU nhằm mục đích phân phối lưu lượng.

Các khung được truyền và nhận thông qua hàng đợi khung phần cứng, có thể
được nhóm lại thành các kênh nhằm mục đích lập kế hoạch phần cứng. Trình điều khiển Ethernet
xếp các khung TX vào hàng đợi đầu ra và sau khi truyền xong một TX
khung xác nhận được gửi trở lại CPU.

Khi các khung có sẵn trên hàng đợi vào, thông báo về tính khả dụng của dữ liệu
được gửi đến CPU; thông báo được đưa ra trên mỗi kênh, vì vậy ngay cả khi có nhiều
hàng đợi trong cùng một kênh có sẵn khung thì chỉ gửi một thông báo.
Sau khi một kênh kích hoạt thông báo, kênh đó phải được sắp xếp lại một cách rõ ràng.

Mỗi giao diện mạng có thể có nhiều hàng đợi Rx, Tx và xác nhận
tới CPU và một kênh (DPCON) cho mỗi CPU phục vụ ít nhất một hàng đợi.
DPCON được sử dụng để phân phối lưu lượng truy cập vào các CPU khác nhau thông qua các lõi
affine dpio.

Vai trò của vùng đệm phần cứng là lưu trữ dữ liệu khung vào. Mỗi mạng
giao diện có một vùng đệm thuộc sở hữu riêng mà nó tạo ra với kernel được phân bổ
bộ đệm.


DPNI được tách rời khỏi PHY; DPNI có thể được kết nối với PHY thông qua DPMAC
đối tượng hoặc tới DPNI khác thông qua liên kết nội bộ, nhưng kết nối bị
được quản lý bởi MC và hoàn toàn minh bạch đối với trình điều khiển Ethernet.

::

--------- --------- ---------
    ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ
     --------- --------- ---------
          .           .          .
          .           .          .
          .           .          .
         --------------------------
        ZZ0003ZZ
         --------------------------
          .           .          .
          .           .          .
          .           .          .
       ------ ------ ------ -------
      ZZ0004ZZ ZZ0005ZZ ZZ0006ZZ ZZ0007ZZ----+
       ------ ------ ------ ------- |
         ZZ0008ZZ ZZ0009ZZ |
         ZZ0010ZZ ZZ0011ZZ -----
          =========== ===================== ZZ0012ZZ
                                                           -----

Tạo giao diện mạng
============================
Một thiết bị mạng được tạo cho mỗi đối tượng DPNI được thăm dò trên bus MC. Mỗi DPNI có
một số thuộc tính xác định cấu hình giao diện mạng
các tùy chọn và tài nguyên phần cứng liên quan.

Các đối tượng DPNI (và các đối tượng DPAA2 khác cần cho giao diện mạng) có thể
được thêm vào thùng chứa trên xe buýt MC theo một trong hai cách: tĩnh, thông qua
Bố cục đường dẫn dữ liệu Tệp nhị phân (DPL) được MC phân tích cú pháp khi khởi động; hoặc tạo ra
linh hoạt trong thời gian chạy, thông qua API đối tượng DPAA2.


Tính năng & Giảm tải
====================
Giảm tải tổng kiểm tra phần cứng được hỗ trợ cho TCP và UDP qua khung IPv4/6.
Việc giảm tải tổng kiểm tra có thể được cấu hình độc lập trên RX và TX thông qua
ethtool.

Giảm tải phần cứng của bộ lọc MAC unicast và multicast được hỗ trợ trên
đường dẫn xâm nhập và kích hoạt vĩnh viễn.

Các khung thu thập phân tán được hỗ trợ trên cả hai đường dẫn RX và TX. Hỗ trợ trên TX, SG
có thể cấu hình thông qua ethtool; trên RX nó luôn được kích hoạt.

Phần cứng DPAA2 có thể xử lý các khung Ethernet khổng lồ lên tới 10K byte.

Trình điều khiển Ethernet xác định sơ đồ băm luồng tĩnh để phân phối
lưu lượng dựa trên khóa 5 bộ: src IP, dst IP, IP proto, L4 src port,
Cổng L4 dst. Hiện tại không có cấu hình người dùng nào được hỗ trợ.

Thống kê cụ thể về phần cứng cho giao diện mạng cũng như một số
số liệu thống kê trình điều khiển không chuẩn có thể được tham khảo thông qua tùy chọn ethtool -S.