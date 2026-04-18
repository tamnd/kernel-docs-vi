.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/gpu/amdgpu/thermal.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================================
 GPU Giám sát và điều khiển nguồn/nhiệt
===============================================

Giao diện HWMON
================

.. kernel-doc:: drivers/gpu/drm/amd/pm/amdgpu_pm.c
   :doc: hwmon

GPU sysfs Giao diện trạng thái nguồn
====================================

Bộ điều khiển nguồn GPU được hiển thị thông qua các tệp sysfs.

power_dpm_state
---------------

.. kernel-doc:: drivers/gpu/drm/amd/pm/amdgpu_pm.c
   :doc: power_dpm_state

power_dpm_force_performance_level
---------------------------------

.. kernel-doc:: drivers/gpu/drm/amd/pm/amdgpu_pm.c
   :doc: power_dpm_force_performance_level

bảng pp_
--------

.. kernel-doc:: drivers/gpu/drm/amd/pm/amdgpu_pm.c
   :doc: pp_table

pp_od_clk_điện áp
-----------------

.. kernel-doc:: drivers/gpu/drm/amd/pm/amdgpu_pm.c
   :doc: pp_od_clk_voltage

pp_dpm_*
--------

.. kernel-doc:: drivers/gpu/drm/amd/pm/amdgpu_pm.c
   :doc: pp_dpm_sclk pp_dpm_mclk pp_dpm_socclk pp_dpm_fclk pp_dpm_dcefclk pp_dpm_pcie

pp_power_profile_mode
---------------------

.. kernel-doc:: drivers/gpu/drm/amd/pm/amdgpu_pm.c
   :doc: pp_power_profile_mode

chiều_chính sách
---------------------

.. kernel-doc:: drivers/gpu/drm/amd/pm/amdgpu_pm.c
   :doc: pm_policy

\*_busy_percent
---------------

.. kernel-doc:: drivers/gpu/drm/amd/pm/amdgpu_pm.c
   :doc: gpu_busy_percent

.. kernel-doc:: drivers/gpu/drm/amd/pm/amdgpu_pm.c
   :doc: mem_busy_percent

gpu_metrics
-----------

.. kernel-doc:: drivers/gpu/drm/amd/pm/amdgpu_pm.c
   :doc: gpu_metrics

đường cong quạt
---------------

.. kernel-doc:: drivers/gpu/drm/amd/pm/amdgpu_pm.c
   :doc: fan_curve

acoustic_limit_rpm_threshold
----------------------------

.. kernel-doc:: drivers/gpu/drm/amd/pm/amdgpu_pm.c
   :doc: acoustic_limit_rpm_threshold

âm thanh_target_rpm_threshold
-----------------------------

.. kernel-doc:: drivers/gpu/drm/amd/pm/amdgpu_pm.c
   :doc: acoustic_target_rpm_threshold

fan_target_nhiệt độ
----------------------

.. kernel-doc:: drivers/gpu/drm/amd/pm/amdgpu_pm.c
   :doc: fan_target_temperature

fan_minimum_pwm
---------------

.. kernel-doc:: drivers/gpu/drm/amd/pm/amdgpu_pm.c
   :doc: fan_minimum_pwm

fan_zero_rpm_enable
----------------------

.. kernel-doc:: drivers/gpu/drm/amd/pm/amdgpu_pm.c
   :doc: fan_zero_rpm_enable

fan_zero_vòng/phút_stop_nhiệt độ
--------------------------------

.. kernel-doc:: drivers/gpu/drm/amd/pm/amdgpu_pm.c
   :doc: fan_zero_rpm_stop_temperature

GFXOFF
======

GFXOFF là một tính năng có trong hầu hết các GPU gần đây giúp tiết kiệm năng lượng khi chạy. các
Phần sụn RLC (Bộ điều khiển RunList) của thẻ tắt nguồn gfx
linh hoạt khi không có khối lượng công việc trên gfx hoặc ống tính toán. GFXOFF được bật bởi
mặc định trên các GPU được hỗ trợ.

Không gian người dùng có thể tương tác với GFXOFF thông qua giao diện debugfs (tất cả các giá trị trong
ZZ0000ZZ, trừ khi có ghi chú khác):

ZZ0000ZZ
-----------------

Sử dụng nó để bật/tắt GFXOFF và kiểm tra xem hiện tại nó có được bật/tắt hay không::

$ xxd -l1 -p /sys/kernel/debug/dri/0/amdgpu_gfxoff
  01

- Viết 0 để tắt và 1 để bật.
- Đọc 0 tức là bị vô hiệu hóa, 1 là được kích hoạt.

Nếu nó được bật, điều đó có nghĩa là GPU có thể tự do chuyển sang chế độ GFXOFF như
cần thiết. Tắt có nghĩa là nó sẽ không bao giờ vào chế độ GFXOFF.

ZZ0000ZZ
------------------------

Đọc nó để kiểm tra trạng thái hiện tại của GFXOFF của GPU::

$ xxd -l1 -p /sys/kernel/debug/dri/0/amdgpu_gfxoff_status
  02

- 0: GPU ở trạng thái GFXOFF, động cơ gfx bị tắt nguồn.
- 1: Chuyển ra khỏi trạng thái GFXOFF
- 2: Không ở trạng thái GFXOFF
- 3: Chuyển sang trạng thái GFXOFF

Nếu GFXOFF được bật, giá trị sẽ luôn chuyển đổi xung quanh [0, 3]
tiến về 0 khi có thể. Khi nó bị vô hiệu hóa, nó luôn ở mức 2. Trả về
ZZ0000ZZ nếu nó không được hỗ trợ.

ZZ0000ZZ
-----------------------

Đọc nó để biết tổng số mục nhập GFXOFF tại thời điểm truy vấn vì hệ thống
bật nguồn. Tuy nhiên, giá trị này là loại ZZ0000ZZ, do giới hạn của phần sụn,
hiện tại nó có thể tràn dưới dạng ZZ0001ZZ. ZZ0002ZZ

ZZ0000ZZ
---------------------------

Viết 1 vào amdgpu_gfxoff_residency để bắt đầu ghi nhật ký và 0 để dừng. Đọc nó để
lấy % cư trú GFXOFF trung bình nhân với 100 trong lần ghi nhật ký cuối cùng
khoảng. Ví dụ. giá trị 7854 có nghĩa là 78,54% thời gian trong lần ghi cuối cùng
khoảng thời gian GPU ở chế độ GFXOFF. ZZ0000ZZ
