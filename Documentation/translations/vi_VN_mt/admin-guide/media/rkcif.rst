.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/rkcif.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================================
Giao diện máy ảnh Rockchip (CIF)
=========================================

Giới thiệu
============

Giao diện máy ảnh Rockchip (CIF) được giới thiệu trong nhiều SoC Rockchip ở
các biến thể khác nhau.
Các biến thể khác nhau là sự kết hợp của các khối xây dựng chung, chẳng hạn như

* Các khối INTERFACE thuộc nhiều loại khác nhau, cụ thể là

* Cổng Video Kỹ thuật số (DVP, giao diện dữ liệu song song)
  * khối giao diện cho bộ thu MIPI CSI-2

* Đơn vị CROP

* Bộ thu MIPI CSI-2 (không có sẵn trên tất cả các biến thể): Thiết bị này được tham khảo
  thành MIPI CSI HOST trong tài liệu Rockchip.
  Về mặt kỹ thuật, nó là một khối phần cứng riêng biệt nhưng được liên kết chặt chẽ với
  CIF và do đó được đưa vào đây.

* Các đơn vị MUX (không có sẵn trên tất cả các biến thể) truyền dữ liệu video tới một
  bộ xử lý tín hiệu hình ảnh (ISP)

* Đơn vị SCALE (không có sẵn trên tất cả các biến thể)

* Công cụ DMA truyền dữ liệu video vào bộ nhớ hệ thống bằng cách sử dụng
  cơ chế đệm đôi được gọi là chế độ bóng bàn

* Hỗ trợ bốn luồng trên mỗi khối INTERFACE (không khả dụng trên tất cả
  các biến thể), ví dụ: đối với Kênh ảo (VC) MIPI CSI-2

Tài liệu này mô tả các biến thể khác nhau của CIF, phần cứng của chúng
bố cục cũng như sự thể hiện của chúng trong rkcif trung tâm bộ điều khiển phương tiện
trình điều khiển thiết bị, nằm trong trình điều khiển/media/platform/rockchip/rkcif.

Biến thể
========

Bộ xử lý đầu vào video Rockchip PX30 (VIP)
-----------------------------------------

Bộ xử lý đầu vào video PX30 (VIP) có cổng video kỹ thuật số chấp nhận
dữ liệu video song song hoặc BT.656.
Vì các giao thức này không có nhiều luồng nên VIP có một DMA
công cụ chuyển dữ liệu video đầu vào vào bộ nhớ hệ thống.

Trình điều khiển rkcif đại diện cho biến thể phần cứng này bằng cách hiển thị một thiết bị con V4L2
(khối DVP INTERFACE/CROP) và một thiết bị V4L2 (động cơ DVP DMA).

Quay video Rockchip RK3568 (VICAP)
-------------------------------------

Thiết bị quay video RK3568 (VICAP) có cổng video kỹ thuật số và MIPI
Bộ thu CSI-2 có thể nhận dữ liệu video độc lập.
DVP chấp nhận dữ liệu video song song, BT.656 và BT.1120.
Vì giao thức BT.1120 có thể có nhiều luồng, RK3568 VICAP
DVP có bốn công cụ DMA có thể thu được các luồng khác nhau.
Tương tự, bộ thu RK3568 VICAP MIPI CSI-2 có bốn động cơ DMA để
xử lý các Kênh ảo (VC) khác nhau.

Trình điều khiển rkcif đại diện cho biến thể phần cứng này bằng cách hiển thị thông tin sau
Thiết bị phụ V4L2:

* rkcif-dvp0: Khối INTERFACE/CROP cho DVP

và các thiết bị video sau:

* rkcif-dvp0-id0: Chưa hỗ trợ nhiều luồng trên DVP
  được triển khai vì rất khó tìm thấy phần cứng thử nghiệm. Vì vậy, thiết bị video này
  đại diện cho động cơ DMA đầu tiên của RK3568 DVP.

.. kernel-figure:: rkcif-rk3568-vicap.dot
    :alt:   Topology of the RK3568 Video Capture (VICAP) unit
    :align: center