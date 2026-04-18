.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/xilinx/eemi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================================
Tài liệu Xilinx Zynq MPSoC EEMI
====================================

Giao diện phần mềm Xilinx Zynq MPSoC
-------------------------------------
Nút zynqmp-firmware mô tả giao diện với phần sụn nền tảng.
ZynqMP có giao diện để giao tiếp với phần mềm bảo mật. Phần sụn
trình điều khiển cung cấp giao diện cho các API phần sụn. API giao diện có thể
được sử dụng bởi bất kỳ trình điều khiển nào để liên lạc với PMC (Bộ điều khiển quản lý nền tảng).

Giao diện quản lý năng lượng nhúng (EEMI)
----------------------------------------------
Giao diện quản lý năng lượng nhúng được sử dụng để cho phép phần mềm
các thành phần chạy trên các cụm xử lý khác nhau trên một con chip hoặc
thiết bị để giao tiếp với bộ điều khiển quản lý nguồn (PMC) trên
thiết bị để đưa ra hoặc đáp ứng các yêu cầu quản lý nguồn.

Bất kỳ trình điều khiển nào muốn giao tiếp với PMC bằng API EEMI đều sử dụng
chức năng được cung cấp cho từng chức năng.

IOCTL
------
IOCTL API dành cho điều khiển và cấu hình thiết bị. Nó không phải là một hệ thống
IOCTL nhưng nó là EEMI API. API này có thể được chủ nhân sử dụng để điều khiển
bất kỳ cấu hình cụ thể của thiết bị. Định nghĩa IOCTL có thể là nền tảng
cụ thể. API này cũng quản lý cấu hình thiết bị dùng chung.

Các ID IOCTL sau đây hợp lệ để điều khiển thiết bị:
-IOCTL_SET_PLL_FRAC_MODE 8
-IOCTL_GET_PLL_FRAC_MODE 9
-IOCTL_SET_PLL_FRAC_DATA 10
-IOCTL_GET_PLL_FRAC_DATA 11

Tham khảo hướng dẫn EEMI API [0] để biết các thông số cụ thể của IOCTL và các API EEMI khác.

Tài liệu tham khảo
----------
[0] Giao diện quản lý năng lượng nhúng (EEMI) Hướng dẫn API:
    ZZ0000ZZ
