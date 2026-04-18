.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/gpu/amdgpu/driver-misc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
 Thông tin driver linh tinh AMDGPU
====================================

Thông tin sản phẩm GPU
=======================

Thông tin về GPU có thể được lấy trên một số thẻ nhất định
thông qua sysfs

tên_sản phẩm
------------

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_fru_eeprom.c
   :doc: product_name

số_sản phẩm
--------------

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_fru_eeprom.c
   :doc: product_number

số seri
-------------

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_fru_eeprom.c
   :doc: serial_number

trái_id
-------------

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_fru_eeprom.c
   :doc: fru_id

nhà sản xuất
-------------

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_fru_eeprom.c
   :doc: manufacturer

duy nhất_id
---------

.. kernel-doc:: drivers/gpu/drm/amd/pm/amdgpu_pm.c
   :doc: unique_id

bảng_thông tin
----------

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_device.c
   :doc: board_info

Thông tin sử dụng bộ nhớ GPU
============================

Tính toán bộ nhớ khác nhau có thể được truy cập thông qua sysfs

mem_info_vram_total
-------------------

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_vram_mgr.c
   :doc: mem_info_vram_total

mem_info_vram_used
------------------

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_vram_mgr.c
   :doc: mem_info_vram_used

mem_info_vis_vram_total
-----------------------

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_vram_mgr.c
   :doc: mem_info_vis_vram_total

mem_info_vis_vram_used
----------------------

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_vram_mgr.c
   :doc: mem_info_vis_vram_used

mem_info_gtt_total
------------------

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_gtt_mgr.c
   :doc: mem_info_gtt_total

mem_info_gtt_used
-----------------

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_gtt_mgr.c
   :doc: mem_info_gtt_used

Thông tin kế toán PCIe
===========================

pcie_bw
-------

.. kernel-doc:: drivers/gpu/drm/amd/pm/amdgpu_pm.c
   :doc: pcie_bw

pcie_replay_count
-----------------

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_device.c
   :doc: pcie_replay_count

Thông tin SmartShift GPU
==========================

Thông tin GPU SmartShift qua sysfs

Smartshift_apu_power
--------------------

.. kernel-doc:: drivers/gpu/drm/amd/pm/amdgpu_pm.c
   :doc: smartshift_apu_power

Smartshift_dgpu_power
---------------------

.. kernel-doc:: drivers/gpu/drm/amd/pm/amdgpu_pm.c
   :doc: smartshift_dgpu_power

Smartshift_bias
---------------

.. kernel-doc:: drivers/gpu/drm/amd/pm/amdgpu_pm.c
   :doc: smartshift_bias

Khắc UMA
============

Một số phiên bản của Atom ROM có các tùy chọn có sẵn cho kích thước khắc VRAM,
và cho phép thay đổi kích thước khắc thông qua mã chức năng ATCS 0xA được hỗ trợ
Triển khai BIOS.

Đối với những nền tảng đó, người dùng có thể sử dụng các tệp sau trong uma/ để đặt
kích thước khắc, theo cách tương tự như những gì người dùng Windows có thể thực hiện trong phần "Điều chỉnh"
tab trong AMD Adrenalin.

Lưu ý rằng đối với các triển khai BIOS không hỗ trợ điều này, các tệp này sẽ không
được tạo ra chút nào.

uma/carveout_options
--------------------

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_device.c
   :doc: uma/carveout_options

uma/khắc
--------------------

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_device.c
   :doc: uma/carveout
