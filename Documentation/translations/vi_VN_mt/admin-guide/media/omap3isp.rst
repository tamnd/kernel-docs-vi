.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/omap3isp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. include:: <isonum.txt>

Trình điều khiển Bộ xử lý tín hiệu hình ảnh OMAP 3 (ISP)
==========================================

Bản quyền ZZ0000ZZ 2010 Nokia Corporation

Bản quyền ZZ0000ZZ 2009 Texas Instruments, Inc.

Người liên hệ: Laurent Pinchart <laurent.pinchart@ideasonboard.com>,
Sakari Ailus <sakari.ailus@iki.fi>, David Cohen <dacohen@gmail.com>


Giới thiệu
------------

Tệp này ghi lại Bộ xử lý tín hiệu hình ảnh OMAP 3 của Texas Instruments (ISP)
trình điều khiển nằm trong trình điều khiển/media/platform/ti/omap3isp. Trình điều khiển ban đầu là
được viết bởi Texas Instruments nhưng kể từ đó nó đã được viết lại (hai lần) vào
Nokia.

Trình điều khiển đã được sử dụng thành công trên các phiên bản sau của OMAP 3:

- 3430
- 3530
- 3630

Trình điều khiển triển khai các giao diện V4L2, Bộ điều khiển phương tiện và v4l2_subdev.
Trình điều khiển cảm biến, ống kính và flash sử dụng giao diện v4l2_subdev trong kernel
được hỗ trợ.


Chia thành các nhóm phụ
----------------

OMAP 3 ISP được chia thành các nhóm con V4L2, mỗi khối bên trong ISP
có một subdev để đại diện cho nó. Mỗi nhà phát triển con cung cấp một nhà phát triển con V4L2
giao diện với không gian người dùng.

- OMAP3 ISP CCP2
- OMAP3 ISP CSI2a
- OMAP3 ISP CCDC
- Xem trước OMAP3 ISP
- Bộ thay đổi kích thước OMAP3 ISP
- OMAP3 ISP AEWB
- OMAP3 ISP AF
- Biểu đồ OMAP3 ISP

Mỗi liên kết có thể có trong ISP được mô hình hóa bằng một liên kết trong Bộ điều khiển phương tiện
giao diện. Để biết chương trình ví dụ, hãy xem [#]_.


Điều khiển OMAP 3 ISP
--------------------------

Nhìn chung, các cài đặt được cung cấp cho OMAP 3 ISP sẽ có hiệu lực ngay từ đầu
của khung sau. Điều này được thực hiện khi mô-đun không hoạt động trong thời gian
khoảng thời gian trống dọc trên cảm biến. Trong hoạt động từ bộ nhớ đến bộ nhớ, đường ống
được chạy từng khung một. Việc áp dụng các cài đặt được thực hiện giữa các khung.

Tất cả các khối trong ISP, ngoại trừ CSI-2 và có thể cả bộ thu CCP2,
nhấn mạnh vào việc nhận được khung hình hoàn chỉnh. Do đó, các cảm biến không bao giờ được gửi ISP
khung một phần.

Autoidle ít nhất có vấn đề với một số khối ISP trên 3430.
Autoidle chỉ được kích hoạt trên 3630 khi tham số mô-đun omap3isp autoidle
là khác không.

Hướng dẫn tham khảo kỹ thuật (TRM) và các tài liệu khác
----------------------------------------------------------

OMAP 3430 TRM:
<URL:ZZ0000ZZ
Tham khảo ngày 05-03-2011.

OMAP 35xx TRM:
<URL:ZZ0000ZZ Được tham chiếu 2011-03-05.

OMAP 3630 TRM:
<URL:ZZ0000ZZ
Tham khảo ngày 05-03-2011.

DM 3730 TRM:
<URL:ZZ0000ZZ Được tham chiếu ngày 06-03-2011.


Tài liệu tham khảo
----------

.. [#] http://git.ideasonboard.org/?p=media-ctl.git;a=summary