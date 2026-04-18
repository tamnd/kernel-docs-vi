.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/ntc_thermistor.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân ntc_thermistor
========================================

Nhiệt điện trở được hỗ trợ từ Murata:

* Điện trở nhiệt Murata NTC NCP15WB473, NCP18WB473, NCP21WB473, NCP03WB473,
  NCP15WL333, NCP03WF104, NCP15XH103

Tiền tố: 'ncp15wb473', 'ncp18wb473', 'ncp21wb473', 'ncp03wb473',
  'ncp15wl333', 'ncp03wf104', 'ncp15xh103'

Bảng dữ liệu: Có sẵn công khai tại Murata

Nhiệt điện trở được hỗ trợ từ EPCOS:

* Điện trở nhiệt EPCOS NTC B57330V2103

Tiền tố: b57330v2103

Bảng dữ liệu: Có sẵn công khai tại EPCOS

Các điện trở nhiệt NTC khác có thể được hỗ trợ đơn giản bằng cách thêm bù
bảng; ví dụ: hỗ trợ NCP15WL333 được thêm vào bởi bảng ncpXXwl333.

tác giả:

Ham MyungJoo <myungjoo.ham@samsung.com>

Sự miêu tả
-----------

Điện trở nhiệt NTC (Hệ số nhiệt độ âm) là một điện trở nhiệt đơn giản
yêu cầu người dùng cung cấp kháng cự và tra cứu tương ứng
bảng bù để lấy nhiệt độ đầu vào.

Trình điều khiển NTC cung cấp các bảng tra cứu với hàm xấp xỉ tuyến tính
và bốn mô hình mạch với tùy chọn không sử dụng bất kỳ mô hình nào trong bốn mô hình.

Sử dụng quy ước sau::

điện trở $
   [TH] nhiệt điện trở

Bốn mô hình mạch được cung cấp là:

1. kết nối = NTC_CONNECTED_POSITIVE, pullup_ohm > 0::

[pullup_uV]
	 ZZ0000ZZ
	[TH] $ (pullup_ohm)
	 ZZ0001ZZ
	 +----+--------------[read_uV]
	 |
	 $ (kéo xuống_ohm)
	 |
	-+- (mặt đất)

2. connect = NTC_CONNECTED_POSITIVE, pullup_ohm = 0 (không kết nối)::

[pullup_uV]
	 |
	[TH]
	 |
	 +------------------------------[read_uV]
	 |
	 $ (kéo xuống_ohm)
	 |
	-+- (mặt đất)

3. kết nối = NTC_CONNECTED_GROUND, pulldown_ohm > 0::

[pullup_uV]
	 |
	 $ (pullup_ohm)
	 |
	 +----+--------------[read_uV]
	 ZZ0000ZZ
	[TH] $ (pulldown_ohm)
	 ZZ0001ZZ
	-+----+- (mặt đất)

4. connect = NTC_CONNECTED_GROUND, pulldown_ohm = 0 (không kết nối)::

[pullup_uV]
	 |
	 $ (pullup_ohm)
	 |
	 +------------------------------[read_uV]
	 |
	[TH]
	 |
	-+- (mặt đất)

Khi một trong bốn mô hình mạch được sử dụng, read_uV, pullup_uV, pullup_ohm,
pulldown_ohm và kết nối phải được cung cấp. Khi không có mô hình nào trong bốn mô hình
phù hợp hoặc người dùng có thể nhận được điện trở trực tiếp, người dùng nên
cung cấp read_ohm và _not_ cung cấp những cái khác.

Giao diện hệ thống
------------------

================ ====================================================================
đặt tên cho thuộc tính toàn cầu bắt buộc, tên nhiệt điện trở.
================ ====================================================================
temp1_type RO luôn 4 (nhiệt điện trở)

temp1_input RO đo nhiệt độ và cung cấp giá trị đo được.
		   (đọc tệp này sẽ bắt đầu quy trình đọc.)
================ ====================================================================

Lưu ý rằng mỗi điện trở nhiệt NTC chỉ có _một_ điện trở nhiệt; do đó, chỉ có temp1 tồn tại.
