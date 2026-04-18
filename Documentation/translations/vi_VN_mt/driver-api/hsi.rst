.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/hsi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Giao diện nối tiếp đồng bộ tốc độ cao (HSI)
=============================================

Giới thiệu
---------------

Giao diện đồng bộ tốc độ cao (HSI) là giao thức song công hoàn toàn, độ trễ thấp,
được tối ưu hóa cho kết nối cấp độ khuôn giữa Bộ xử lý ứng dụng
và một chipset Baseband. Nó đã được liên minh MIPI chỉ định vào năm 2003 và
được thực hiện bởi nhiều nhà cung cấp kể từ đó.

Giao diện HSI hỗ trợ giao tiếp song công hoàn toàn trên nhiều kênh
(thường là 8) và có khả năng đạt tốc độ lên tới 200 Mbit/s.

Giao thức nối tiếp sử dụng hai tín hiệu DATA và FLAG làm dữ liệu và đồng hồ kết hợp
tín hiệu và tín hiệu READY bổ sung để điều khiển luồng. Một WAKE bổ sung
tín hiệu có thể được sử dụng để đánh thức chip từ chế độ chờ. Các tín hiệu là
thường được đặt trước bởi AC cho các tín hiệu đi từ khuôn ứng dụng đến
khuôn di động và CA cho các tín hiệu đi ngược lại.

::

+-------------+ +--------------+
    ZZ0000ZZ ZZ0001ZZ
    ZZ0002ZZ ZZ0003ZZ
    ZZ0004ZZ - - - - - - CAWAKE - - - - - >ZZ0005ZZ
    ZZ0006ZZ----------- CADATA ------------>ZZ0007ZZ
    ZZ0008ZZ------------- CAFLAG -------------->ZZ0009ZZ
    ZZ0010ZZ<-----------ACREADY-----------ZZ0011ZZ
    ZZ0012ZZ ZZ0013ZZ
    ZZ0014ZZ ZZ0015ZZ
    ZZ0016ZZ< - - - - - ACWAKE - - - - - - -ZZ0017ZZ
    ZZ0018ZZ<-----------ACDATA-------------ZZ0019ZZ
    ZZ0020ZZ<-----------ACFLAG-------------ZZ0021ZZ
    ZZ0022ZZ------------- CAREADY ----------->ZZ0023ZZ
    ZZ0024ZZ ZZ0025ZZ
    ZZ0026ZZ ZZ0027ZZ
    +-------------+ +---------------+

Hệ thống con HSI trong Linux
-------------------------

Trong nhân Linux, hệ thống con hsi được cho là sẽ được sử dụng cho các thiết bị HSI.
Hệ thống con hsi chứa các trình điều khiển cho bộ điều khiển hsi bao gồm hỗ trợ cho
bộ điều khiển nhiều cổng và cung cấp API chung để sử dụng các cổng HSI.

Nó cũng chứa trình điều khiển máy khách HSI, sử dụng API chung để
triển khai giao thức được sử dụng trên giao diện HSI. Những trình điều khiển máy khách này có thể
sử dụng một số lượng kênh tùy ý.

thiết bị hsi-char
------------------

Mỗi cổng tự động đăng ký một trình điều khiển máy khách chung có tên hsi_char,
cung cấp một thiết bị ký tự cho không gian người dùng đại diện cho cổng HSI.
Nó có thể được sử dụng để liên lạc qua HSI từ không gian người dùng. Không gian người dùng có thể
định cấu hình thiết bị hsi_char bằng các lệnh ioctl sau:

HSC_RESET
 xả cổng HSI

HSC_SET_PM
 kích hoạt hoặc vô hiệu hóa máy khách.

HSC_SEND_BREAK
 gửi nghỉ

HSC_SET_RX
 đặt cấu hình RX

HSC_GET_RX
 lấy cấu hình RX

HSC_SET_TX
 đặt cấu hình TX

HSC_GET_TX
 lấy cấu hình TX

Hạt nhân HSI API
------------------

.. kernel-doc:: include/linux/hsi/hsi.h
   :internal:

.. kernel-doc:: drivers/hsi/hsi_core.c
   :export:

