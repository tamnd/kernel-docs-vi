.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/freescale/dpaa2/dpio-driver.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

======================================
Tổng quan về DPAA2 DPIO (I/O đường dẫn dữ liệu)
===================================

:Bản quyền: ZZ0000ZZ 2016-2018 NXP

Tài liệu này cung cấp thông tin tổng quan về Freescale DPAA2 DPIO
trình điều khiển

Giới thiệu
============

DPAA2 DPIO (I/O đường dẫn dữ liệu) là một đối tượng phần cứng cung cấp
các giao diện để xếp hàng và loại bỏ các khung hình đến/từ các giao diện mạng
và các máy gia tốc khác.  DPIO cũng cung cấp bộ đệm phần cứng
quản lý nhóm cho các giao diện mạng.

Tài liệu này cung cấp thông tin tổng quan về trình điều khiển Linux DPIO,
các thành phần phụ và API của nó.

Xem
Tài liệu/mạng/device_drivers/ethernet/freescale/dpaa2/overview.rst
để biết tổng quan chung về DPAA2 và kiến trúc trình điều khiển DPAA2 chung
trong Linux.

Tổng quan về trình điều khiển
---------------

Trình điều khiển DPIO được liên kết với các đối tượng DPIO được phát hiện trên bus fsl-mc và
cung cấp các dịch vụ:

A. cho phép các trình điều khiển khác, chẳng hạn như trình điều khiển Ethernet, xếp hàng và loại bỏ
     khung cho các đối tượng tương ứng của họ
  B. cho phép người lái xe đăng ký cuộc gọi lại để nhận thông báo về tính khả dụng của dữ liệu
     khi dữ liệu có sẵn trên hàng đợi hoặc kênh
  C. cho phép trình điều khiển quản lý vùng đệm phần cứng

Trình điều khiển Linux DPIO bao gồm 3 thành phần chính--
   Trình điều khiển đối tượng DPIO-- trình điều khiển fsl-mc quản lý đối tượng DPIO

Dịch vụ DPIO-- cung cấp API cho các trình điều khiển Linux khác cho các dịch vụ

Giao diện cổng thông tin QBman-- gửi lệnh cổng thông tin, nhận phản hồi::

fsl-mc khác
           tài xế xe buýt
            ZZ0000ZZ
        +---+----+ +------+------+
        ZZ0001ZZ ZZ0002ZZ
        ZZ0003ZZ---ZZ0004ZZ
        +--------+ +------+------+
                            |
                     +------+------+
                     ZZ0005ZZ
                     ZZ0006ZZ
                     +-----------+
                            |
                         phần cứng


Sơ đồ bên dưới cho thấy các thành phần trình điều khiển DPIO khớp với các thành phần khác như thế nào
Các thành phần trình điều khiển Linux DPAA2::

+-----------+
                                                   ZZ0000ZZ
                                                   ZZ0001ZZ
                 +-------------+ +-------------+
                 ZZ0002ZZ. . . . . . .       ZZ0003ZZ
                 ZZ0004ZZ ZZ0005ZZ
                 +-.----------+ +---+---+----+
                  .          .                         ^ |
                 .            .           <dữ liệu có sẵn, ZZ0006ZZ<enqueue,
                .              .           xác nhận tx> Hàng đợi ZZ0007ZZ>
    +-------------+ .                      ZZ0008ZZ
    ZZ0009ZZ.    +--------+ +-------------+
    ZZ0010ZZ. . ZZ0011ZZ ZZ0012ZZ
    +----------+--+ ZZ0013ZZ-ZZ0014ZZ
               |                      +--------+ +------+------+
               ZZ0015ZZ------+
               ZZ0016ZZ QBman |
          +----+--------------+ ZZ0017ZZ
          ZZ0018ZZ +-------------+
          ZZ0019ZZ |
          ZZ0020ZZ |
          +-------------------+ |
                                                    |
 =========================================================================================================
                                        +-+--DPIO---|-------------+
                                        ZZ0022ZZ |
                                        ZZ0023ZZ
                                        +--------------+

==================================================================================


Trình điều khiển đối tượng DPIO (dpio-driver.c)
----------------------------------

Thành phần trình điều khiển dpio đăng ký với bus fsl-mc để xử lý các đối tượng của
   gõ "dpio".  Việc triển khai thăm dò() xử lý việc khởi tạo cơ bản
   của DPIO bao gồm ánh xạ các vùng DPIO (cổng QBman SW)
   và khởi tạo các ngắt và đăng ký trình xử lý irq.  Trình điều khiển dpio
   đăng ký DPIO được thăm dò với dịch vụ dpio.

Dịch vụ DPIO (dpio-service.c, dpaa2-io.h)
------------------------------------------

Thành phần dịch vụ dpio cung cấp hàng đợi, thông báo và bộ đệm
   dịch vụ quản lý cho trình điều khiển DPAA2, chẳng hạn như trình điều khiển Ethernet.  Một hệ thống
   thường sẽ phân bổ 1 đối tượng DPIO cho mỗi CPU để cho phép các hoạt động xếp hàng
   xảy ra đồng thời trên tất cả các CPU.

Xử lý thông báo
      dpaa2_io_service_register()

dpaa2_io_service_deregister()

dpaa2_io_service_rearm()

Xếp hàng
      dpaa2_io_service_pull_fq()

dpaa2_io_service_pull_channel()

dpaa2_io_service_enqueue_fq()

dpaa2_io_service_enqueue_qd()

dpaa2_io_store_create()

dpaa2_io_store_destroy()

dpaa2_io_store_next()

Quản lý vùng đệm
      dpaa2_io_service_release()

dpaa2_io_service_acquire()

Giao diện cổng thông tin QBman (qbman-portal.c)
---------------------------------------

Thành phần cổng thông tin qbman cung cấp các API để thực hiện phần cứng cấp thấp
   xoay vòng một chút cho các hoạt động như:

- khởi tạo cổng phần mềm Qman
      - xây dựng và gửi lệnh cổng thông tin
      - cấu hình và xử lý ngắt cổng thông tin

API cổng thông tin qbman không được công khai đối với các trình điều khiển khác và được
   chỉ được sử dụng bởi dịch vụ dpio.

Khác (dpaa2-fd.h, dpaa2-global.h)
----------------------------------

Các định nghĩa về bộ mô tả khung và tập hợp phân tán cũng như các API được sử dụng để
   thao tác chúng được xác định trong dpaa2-fd.h.

Các API phân tích và cấu trúc kết quả Dequeue được xác định trong dpaa2-global.h.
