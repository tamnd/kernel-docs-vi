.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/thermal/exynos_thermal_emulation.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Chế độ giả lập Exynos
=======================

Bản quyền (C) 2012 Samsung Electronics

Viết bởi Jonghwa Lee <jonghwa3.lee@samsung.com>

Sự miêu tả
-----------

Exynos 4x12 (4212, 4412) và 5 series cung cấp chế độ mô phỏng cho tản nhiệt
đơn vị quản lý. Chế độ mô phỏng nhiệt hỗ trợ gỡ lỗi phần mềm cho
Hoạt động của TMU. Người dùng có thể cài đặt nhiệt độ thủ công bằng mã phần mềm
và TMU sẽ đọc nhiệt độ hiện tại từ giá trị người dùng chứ không phải từ cảm biến
giá trị.

Kích hoạt tùy chọn CONFIG_THERMAL_EMULATION sẽ thực hiện hỗ trợ này
có sẵn. Khi được bật, nút sysfs sẽ được tạo dưới dạng
/sys/devices/virtual/thermal/thermal_zone'zone id'/emul_temp.

Nút sysfs, 'emul_node', sẽ chứa giá trị 0 cho trạng thái ban đầu.
Khi bạn nhập bất kỳ nhiệt độ nào bạn muốn cập nhật vào nút sysfs, nó sẽ
tự động kích hoạt chế độ mô phỏng và nhiệt độ hiện tại sẽ
đã thay đổi thành nó.

(Exynos cũng hỗ trợ thời gian trễ có thể thay đổi của người dùng, được sử dụng để
sự chậm trễ của việc thay đổi nhiệt độ. Tuy nhiên, nút này chỉ sử dụng độ trễ tương tự
của thời gian cảm nhận thực, 938us.)

Chế độ mô phỏng Exynos yêu cầu thực hiện thay đổi giá trị và kích hoạt
một cách đồng bộ. Điều này có nghĩa là khi bạn muốn cập nhật bất kỳ giá trị nào, chẳng hạn như
độ trễ hoặc nhiệt độ tiếp theo, bạn phải bật chế độ mô phỏng cùng lúc
thời gian (hoặc giữ chế độ được bật). Nếu không, giá trị sẽ không cập nhật được
và giá trị thành công cuối cùng sẽ tiếp tục được sử dụng. Vì lý do này,
nút này chỉ cho phép người dùng thay đổi nhiệt độ. Cung cấp một đơn
giao diện giúp sử dụng đơn giản hơn.

Tắt chế độ mô phỏng chỉ yêu cầu ghi giá trị 0 vào nút sysfs.

::


TEMP 120 |
	    |
	100 |
	    |
	 80 |
	    |				 +----------
	 60 ZZ0000ZZ |
	    ZZ0001ZZ |
	 40 ZZ0002ZZ ZZ0003ZZ
	    ZZ0004ZZ ZZ0005ZZ
	 20 ZZ0006ZZ |          +----------
	    ZZ0007ZZ ZZ0008ZZ |
	  0 ZZ0009ZZ_____________ZZ0010ZZ__________|_________
		   A A A A TIME
		   ZZ0011ZZ ZZ0012ZZ ZZ0013ZZ |
		   ZZ0014ZZ ZZ0015ZZ ZZ0016ZZ |
  thi đua : 0 50 ZZ0017ZZ 20 |          0
  nhiệt độ hiện tại: cảm biến 50 70 20
