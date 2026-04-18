.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/hac300s.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân hac300s
=====================

Chip được hỗ trợ:

* HiTRON HAC300S

Tiền tố: 'hac300s'

Bảng dữ liệu: Có sẵn công khai tại trang web HiTRON.

Tác giả:

- Vasileios Amoiridis <vasileios.amoiridis@cern.ch>

Sự miêu tả
-----------

Trình điều khiển này hỗ trợ HiTRON HAC300S PSU. Đây là đầu vào AC phổ thông
Hiệu chỉnh hài hòa AC-DC có thể tráo đổi nóng CompactPCI Serial Đầu ra kép
(với chế độ chờ 5V) Bộ nguồn chuyển mạch chia sẻ dòng điện hoạt động 312 Watts.

Thiết bị có đầu vào 90-264VAC và 2 đầu ra danh định có điện áp 12V và
5V mà chúng có thể cung cấp tương ứng lên tới 25A và 2,5A.

Mục nhập hệ thống
-------------

======= ==============================================
Curr1 Dòng điện đầu ra
in1 Điện áp đầu ra
power1 Công suất đầu ra
temp1 Nhiệt độ môi trường bên trong mô-đun
temp2 Nhiệt độ của thành phần thứ cấp bên trong
======= ==============================================