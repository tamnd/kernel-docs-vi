.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/link_power_management_policy.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
Chính sách quản lý nguồn liên kết
==========================

Tham số này cho phép người dùng thiết lập quản lý nguồn liên kết (giao diện).
Có 6 lựa chọn có thể:

=================================================================================
Hiệu ứng giá trị
=================================================================================
min_power Bật chế độ ngủ (không có chế độ một phần) cho liên kết tới
			sử dụng ít năng lượng nhất có thể khi có thể.  Điều này có thể
			hy sinh một số hiệu suất do độ trễ tăng lên
			khi thoát khỏi trạng thái năng lượng thấp hơn.

max_performance Nói chung, điều này có nghĩa là không cần quản lý năng lượng.  kể
			bộ điều khiển ưu tiên hiệu suất
			về quản lý quyền lực.

Medium_power Yêu cầu bộ điều khiển chuyển sang trạng thái năng lượng thấp hơn
			khi có thể, nhưng không nhập công suất thấp nhất
			trạng thái, do đó cải thiện độ trễ so với cài đặt min_power.

keep_firmware_settings Không thay đổi cài đặt chương trình cơ sở hiện tại cho
			Quản lý điện năng. Đây là cài đặt mặc định.

med_power_with_dipm Tương tự như Medium_power, nhưng bổ sung thêm
			Đã bật quản lý nguồn do thiết bị khởi tạo (DIPM),
			như Công nghệ lưu trữ nhanh Intel (IRST).

min_power_with_partial Tương tự như min_power, nhưng bổ sung thêm một phần
			trạng thái nguồn được bật, có thể cải thiện hiệu suất
			qua cài đặt min_power.
=================================================================================