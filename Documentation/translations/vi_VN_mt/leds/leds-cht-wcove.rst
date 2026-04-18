.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/leds/leds-cht-wcove.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================================================
Trình điều khiển hạt nhân cho đèn LED Intel Cherry Trail Whiskey Cove PMIC
===========================================================

/sys/class/leds/<led>/hw_pattern
--------------------------------

Chỉ định mẫu phần cứng cho đèn LED Whiskey Cove PMIC.

Mẫu được hỗ trợ duy nhất là chế độ thở phần cứng::

"0 2000 1 2000"

^
	|
    Tối đa-|     ---
	|    / \
	|   / \
	|  / \ /
	| / \ /
    Min-|- ---
	|
	0------2------4--> thời gian (giây)

Thời gian tăng và giảm phải có cùng giá trị.
Các giá trị được hỗ trợ là 2000, 1000, 500 và 250 cho
tần số thở 1/4, 1/2, 1 và 2 Hz.

Mẫu đã đặt chỉ kiểm soát thời gian. Để có độ sáng tối đa cuối cùng
độ sáng cài đặt được sử dụng và độ sáng tối đa có thể được thay đổi
trong khi thở bằng cách viết thuộc tính độ sáng.

Điều này giống như cách hoạt động của tính năng nhấp nháy trong hệ thống con LED,
đối với cả sw và hw nhấp nháy, độ sáng cũng có thể được thay đổi
trong khi chớp mắt. Hít thở điều này thực sự chỉ là một biến thể
chế độ nhấp nháy.