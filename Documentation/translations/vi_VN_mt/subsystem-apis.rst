.. SPDX-License-Identifier: GPL-2.0

.. include:: ../disclaimer-vi.rst

:Original: Documentation/subsystem-apis.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================================
Tài liệu hệ thống con hạt nhân
==============================

Những cuốn sách này đi sâu vào chi tiết về cách hoạt động của các hệ thống con kernel cụ thể
từ quan điểm của một nhà phát triển hạt nhân.  Phần lớn thông tin ở đây
được lấy trực tiếp từ nguồn hạt nhân, có thêm vật liệu bổ sung
khi cần thiết (hoặc ít nhất là khi chúng tôi cố gắng thêm nó - có lẽ là ZZ0000ZZ, tất cả chỉ có vậy
cần thiết).

Hệ thống con cốt lõi
---------------

.. toctree::
   :maxdepth: 1

   core-api/index
   driver-api/index
   mm/index
   power/index
   scheduler/index
   timers/index
   locking/index

Giao diện con người
----------------

.. toctree::
   :maxdepth: 1

   input/index
   hid/index
   sound/index
   gpu/index
   fb/index
   leds/index

Giao diện mạng
---------------------

.. toctree::
   :maxdepth: 1

   networking/index
   netlabel/index
   infiniband/index
   isdn/index
   mhi/index

Giao diện lưu trữ
------------------

.. toctree::
   :maxdepth: 1

   filesystems/index
   block/index
   cdrom/index
   scsi/index
   target/index
   nvme/index

Các hệ thống con khác
----------------
ZZ0000ZZ: ở đây cần có nhiều công việc tổ chức hơn nữa.

.. toctree::
   :maxdepth: 1

   accounting/index
   cpu-freq/index
   edac/index
   fpga/index
   i2c/index
   iio/index
   pcmcia/index
   spi/index
   w1/index
   watchdog/index
   virt/index
   hwmon/index
   accel/index
   security/index
   crypto/index
   bpf/index
   usb/index
   PCI/index
   misc-devices/index
   peci/index
   wmi/index
   tee/index