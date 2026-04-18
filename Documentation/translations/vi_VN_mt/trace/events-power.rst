.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/events-power.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Điểm theo dõi hệ thống con: sức mạnh
====================================

Hệ thống theo dõi quyền lực nắm bắt các sự kiện liên quan đến chuyển đổi quyền lực
bên trong hạt nhân. Nói rộng ra có ba tiêu đề chính:

- Chuyển đổi trạng thái nguồn báo cáo các sự kiện liên quan đến việc tạm dừng (trạng thái S),
    cpuidle (trạng thái C) và cpufreq (trạng thái P)
  - Thay đổi liên quan đến đồng hồ hệ thống
  - Các thay đổi và chuyển tiếp liên quan đến miền điện

Tài liệu này mô tả từng điểm theo dõi là gì và tại sao chúng
có thể hữu ích.

Cf. include/trace/events/power.h cho các định nghĩa sự kiện.

1. Sự kiện chuyển đổi trạng thái nguồn
======================================

1.1 Dấu vết API
-----------------

Lớp sự kiện 'cpu' tập hợp các sự kiện liên quan đến CPU: cpuidle và
cpufreq.
::::::::

cpu_idle "state=%lu cpu_id=%lu"
  cpu_tần số "trạng thái=%lu cpu_id=%lu"
  cpu_ Frequency_limits "min=%lu max=%lu cpu_id=%lu"

Sự kiện tạm dừng được sử dụng để chỉ ra hệ thống đang vào và ra khỏi
chế độ tạm dừng:
::::::::::::::::

machine_suspend "trạng thái=%lu"


Lưu ý: giá trị '-1' hoặc '4294967295' cho trạng thái có nghĩa là thoát khỏi trạng thái hiện tại,
tức là trace_cpu_idle(4, smp_processor_id()) có nghĩa là hệ thống
chuyển sang trạng thái không hoạt động 4, trong khi trace_cpu_idle(PWR_EVENT_EXIT, smp_processor_id())
có nghĩa là hệ thống thoát khỏi trạng thái không hoạt động trước đó.

Sự kiện có 'state=4294967295' trong dấu vết là rất quan trọng đối với người dùng
các công cụ không gian đang sử dụng nó để phát hiện sự kết thúc của trạng thái hiện tại, v.v.
vẽ chính xác sơ đồ trạng thái và tính toán số liệu thống kê chính xác, v.v.

2. Sự kiện đồng hồ
==================
Các sự kiện đồng hồ được sử dụng để bật/tắt đồng hồ và để
thay đổi tốc độ đồng hồ.
::::::::::::::::::::::::

clock_enable "%s state=%lu cpu_id=%lu"
  clock_disable "%s state=%lu cpu_id=%lu"
  clock_set_rate "%s state=%lu cpu_id=%lu"

Tham số đầu tiên cung cấp tên đồng hồ (ví dụ: "gpio1_iclk").
Tham số thứ hai là '1' để bật, '0' để tắt, mục tiêu
tốc độ xung nhịp cho set_rate.

3. Sự kiện miền quyền lực
=========================
Các sự kiện miền quyền lực được sử dụng để chuyển đổi miền quyền lực
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

power_domain_target "%s state=%lu cpu_id=%lu"

Tham số đầu tiên cung cấp tên miền nguồn (ví dụ: "mpu_pwrdm").
Tham số thứ hai là trạng thái mục tiêu của miền điện.

4. Sự kiện QoS PM
=================
Các sự kiện PM QoS được sử dụng cho yêu cầu thêm/cập nhật/xóa QoS và cho
cập nhật mục tiêu/cờ.
:::::::::::::::::::::

pm_qos_update_target "action=%s prev_value=%dcurr_value=%d"
  pm_qos_update_flags "action=%s prev_value=0x%x curr_value=0x%x"

Tham số đầu tiên cung cấp tên hành động QoS (ví dụ: "ADD_REQ").
Tham số thứ hai là giá trị QoS trước đó.
Tham số thứ ba là giá trị QoS hiện tại cần cập nhật.

Ngoài ra còn có các sự kiện được sử dụng cho yêu cầu thêm/cập nhật/xóa PM QoS của thiết bị.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

dev_pm_qos_add_request "thiết bị=%s loại=%s new_value=%d"
  dev_pm_qos_update_request "thiết bị=%s loại=%s new_value=%d"
  dev_pm_qos_remove_request "thiết bị=%s loại=%s new_value=%d"

Tham số đầu tiên cung cấp tên thiết bị cố gắng thêm/cập nhật/xóa
các yêu cầu QoS.
Tham số thứ hai cung cấp loại yêu cầu (ví dụ: "DEV_PM_QOS_RESUME_LATENCY").
Tham số thứ ba là giá trị được thêm/cập nhật/xóa.

Và, có những sự kiện được sử dụng cho yêu cầu thêm/cập nhật/xóa QoS có độ trễ CPU.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

pm_qos_add_request "giá trị=%d"
  pm_qos_update_request "giá trị=%d"
  pm_qos_remove_request "value=%d"

Tham số là giá trị được thêm/cập nhật/xóa.
