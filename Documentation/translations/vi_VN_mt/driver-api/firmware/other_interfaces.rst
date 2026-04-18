.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/firmware/other_interfaces.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Các giao diện phần mềm khác
=========================

Giao diện DMI
--------------

.. kernel-doc:: drivers/firmware/dmi_scan.c
   :export:

Giao diện EDD
--------------

.. kernel-doc:: drivers/firmware/edd.c
   :internal:

Giao diện bộ đệm khung hệ thống chung
-------------------------------------

.. kernel-doc:: drivers/firmware/sysfb.c
   :export:

Lớp dịch vụ SoC Intel Stratix10
---------------------------------
Một số tính năng của Intel Stratix10 SoC yêu cầu mức đặc quyền
cao hơn kernel được cấp. Các tính năng bảo mật như vậy bao gồm
Lập trình FPGA. Xét về kiến trúc ARMv8, kernel chạy
ở Cấp độ ngoại lệ 1 (EL1), quyền truy cập vào các tính năng yêu cầu
Ngoại lệ cấp 3 (EL3).

Lớp dịch vụ SoC Intel Stratix10 cung cấp API trong kernel cho
trình điều khiển để yêu cầu quyền truy cập vào các tính năng bảo mật. Các yêu cầu được xếp hàng đợi
và xử lý từng cái một. SMCCC của ARM được sử dụng để thực thi
của các yêu cầu lên màn hình an toàn (EL3).

.. kernel-doc:: include/linux/firmware/intel/stratix10-svc-client.h
   :functions: stratix10_svc_command_code

.. kernel-doc:: include/linux/firmware/intel/stratix10-svc-client.h
   :functions: stratix10_svc_client_msg

.. kernel-doc:: include/linux/firmware/intel/stratix10-svc-client.h
   :functions: stratix10_svc_command_config_type

.. kernel-doc:: include/linux/firmware/intel/stratix10-svc-client.h
   :functions: stratix10_svc_cb_data

.. kernel-doc:: include/linux/firmware/intel/stratix10-svc-client.h
   :functions: stratix10_svc_client

.. kernel-doc:: drivers/firmware/stratix10-svc.c
   :export:
