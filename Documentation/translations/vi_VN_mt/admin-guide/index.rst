.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================================
Hướng dẫn sử dụng nhân Linux và quản trị viên
=====================================================

Sau đây là tập hợp các tài liệu hướng tới người dùng đã được
được thêm vào kernel theo thời gian.  Cho đến nay, có rất ít thứ tự tổng thể hoặc
tổ chức ở đây - tài liệu này không được viết thành một bản duy nhất, mạch lạc
tài liệu!  Với may mắn mọi thứ sẽ được cải thiện nhanh chóng theo thời gian.

Hướng dẫn chung về quản trị kernel
---------------------------------------

Phần ban đầu này chứa thông tin tổng thể, bao gồm README
tập tin mô tả toàn bộ hạt nhân, tài liệu về các tham số hạt nhân,
v.v.

.. toctree::
   :maxdepth: 1

   README
   devices

   features

Một phần quan trọng trong giao diện quản trị của kernel là /proc và sysfs
hệ thống tập tin ảo; những tài liệu này mô tả cách tương tác với tem

.. toctree::
   :maxdepth: 1

   sysfs-rules
   sysctl/index
   cputopology
   abi

Tài liệu liên quan đến bảo mật:

.. toctree::
   :maxdepth: 1

   hw-vuln/index
   LSM/index
   perf-security

Khởi động kernel
------------------

.. toctree::
   :maxdepth: 1

   bootconfig
   kernel-parameters
   efi-stub
   initrd


Theo dõi và xác định vấn đề
--------------------------------------

Đây là bộ tài liệu hướng tới người dùng đang cố gắng truy tìm
vấn đề và lỗi nói riêng.

.. toctree::
   :maxdepth: 1

   reporting-issues
   reporting-regressions
   quickly-build-trimmed-linux
   verify-bugs-and-bisect-regressions
   bug-hunting
   bug-bisect
   tainted-kernels
   ramoops
   dynamic-debug-howto
   init
   kdump/index
   perf/index
   pstore-blk
   clearing-warn-once
   kernel-per-CPU-kthreads
   lockup-watchdogs
   RAS/index
   sysrq


Hệ thống con lõi-nhân
----------------------

Những tài liệu này mô tả các giao diện quản trị lõi-nhân
có thể được quan tâm trên hầu hết mọi hệ thống.

.. toctree::
   :maxdepth: 1

   cgroup-v2
   cgroup-v1/index
   cpu-isolation
   cpu-load
   mm/index
   module-signing
   namespaces/index
   numastat
   pm/index
   syscall-user-dispatch

Hỗ trợ các định dạng nhị phân không phải gốc.  Lưu ý rằng một số trong số này
giấy tờ thì...cũ...

.. toctree::
   :maxdepth: 1

   binfmt-misc
   java
   mono


Quản trị lớp khối và hệ thống tập tin
-----------------------------------------

.. toctree::
   :maxdepth: 1

   bcache
   binderfs
   blockdev/index
   cifs/index
   device-mapper/index
   ext4
   filesystem-monitoring
   nfs/index
   iostats
   jfs
   md
   ufs
   xfs

Hướng dẫn dành riêng cho thiết bị
---------------------------------

Cách định cấu hình phần cứng trong hệ thống Linux của bạn.

.. toctree::
   :maxdepth: 1

   acpi/index
   aoe/index
   auxdisplay/index
   braille-console
   btmrvl
   dell_rbu
   edid
   gpio/index
   hw_random
   laptops/index
   lcd-panel-cgram
   media/index
   nvme-multipath
   parport
   pnp
   rapidio
   rtc
   serial-console
   svga
   thermal/index
   thunderbolt
   vga-softcursor
   video-output

Phân tích khối lượng công việc
------------------------------

Đây là sự khởi đầu của một phần với thông tin quan tâm đến
nhà phát triển ứng dụng và nhà tích hợp hệ thống thực hiện phân tích
Nhân Linux cho các ứng dụng quan trọng về an toàn. Tài liệu hỗ trợ
phân tích các tương tác hạt nhân với các ứng dụng và hạt nhân chính
kỳ vọng của hệ thống con sẽ được tìm thấy ở đây.

.. toctree::
   :maxdepth: 1

   workload-tracing

Mọi thứ khác
---------------

Một số tài liệu khó phân loại và nhìn chung đã lỗi thời.

.. toctree::
   :maxdepth: 1

   ldm
   unicode
