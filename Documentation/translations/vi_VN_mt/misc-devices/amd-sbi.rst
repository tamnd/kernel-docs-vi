.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/misc-devices/amd-sbi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
Giao diện AMD SIDE BAND
==========================

Một số bộ xử lý dựa trên AMD Zen hỗ trợ quản lý hệ thống
chức năng thông qua giao diện băng tần bên (SBI) được gọi là
Liên kết quản lý nền tảng nâng cao (APML). APML là I2C/I3C
dựa trên giao diện đích của bộ xử lý 2 dây. APML được sử dụng để
giao tiếp với Giao diện quản lý từ xa
(Giao diện quản lý từ xa SB (SB-RMI)
và Giao diện cảm biến nhiệt độ SB (SB-TSI)).

Thông tin chi tiết về giao diện có thể được tìm thấy trong chương
"5 Liên kết quản lý nền tảng nâng cao (APML)" của dòng/model PPR [1]_.

.. [1] https://docs.amd.com/v/u/en-US/55898_B1_pub_0_50


Thiết bị SBRMI
==============

Trình điều khiển apml_sbrmi trong trình điều khiển/misc/AMD-sbi tạo thiết bị sai
/dev/sbrmi-* để cho phép các chương trình không gian người dùng chạy hộp thư APML, CPUID,
MCAMSR và đăng ký lệnh xfer.

Bộ thanh ghi phổ biến trên các giao thức APML. IOCTL đang cung cấp đồng bộ hóa
giữa các giao thức vì giao dịch có thể tạo ra điều kiện cạnh tranh.

.. code-block:: bash

   $ ls -al /dev/sbrmi-3c
   crw-------    1 root     root       10,  53 Jul 10 11:13 /dev/sbrmi-3c

Trình điều khiển apml_sbrmi đăng ký cảm biến hwmon để theo dõi power_cap_max,
mức tiêu thụ điện năng hiện tại và quản lý power_cap.

Đặc điểm của nút dev:
 * Giao thức Differnet xfer được xác định:
	* Hộp thư
	* CPUID
	* MCA_MSR
	* Đăng ký xfer

Hạn chế truy cập:
 * Chỉ người dùng root mới được phép mở tệp.
 * Tin nhắn trong Hộp thư APML và quyền truy cập Đăng ký xfer đều được đọc-ghi,
 * Truy cập CPUID và MCA_MSR ở chế độ chỉ đọc.

Trình điều khiển IOCTL
======================

.. c:macro:: SBRMI_IOCTL_MBOX_CMD
.. kernel-doc:: include/uapi/misc/amd-apml.h
   :doc: SBRMI_IOCTL_MBOX_CMD
.. c:macro:: SBRMI_IOCTL_CPUID_CMD
.. kernel-doc:: include/uapi/misc/amd-apml.h
   :doc: SBRMI_IOCTL_CPUID_CMD
.. c:macro:: SBRMI_IOCTL_MCAMSR_CMD
.. kernel-doc:: include/uapi/misc/amd-apml.h
   :doc: SBRMI_IOCTL_MCAMSR_CMD
.. c:macro:: SBRMI_IOCTL_REG_XFER_CMD
.. kernel-doc:: include/uapi/misc/amd-apml.h
   :doc: SBRMI_IOCTL_REG_XFER_CMD

Mức sử dụng không gian người dùng
=================================

Để truy cập giao diện dải bên từ chương trình C.
Đầu tiên, người dùng cần bao gồm các tiêu đề::

#include <uapi/misc/amd-apml.h>

Xác định cấu trúc dữ liệu và IOCTL được hỗ trợ sẽ được chuyển
từ không gian người dùng.

Điều tiếp theo, mở tệp thiết bị, như sau ::

tập tin int;

tệp = open("/dev/sbrmi-*", O_RDWR);
  nếu (tệp < 0) {
    /* ERROR HANDLING */
    thoát (1);
  }

Các IOCTL sau đây được xác định:

ZZ0000ZZ
ZZ0001ZZ
ZZ0002ZZ
ZZ0003ZZ
ZZ0004ZZ


C-API không gian người dùng được cung cấp bởi esmi_oob_library, được lưu trữ tại
[2]_ được cung cấp bởi dự án E-SMS [3]_.

.. [2] https://github.com/amd/esmi_oob_library
.. [3] https://www.amd.com/en/developer/e-sms.html