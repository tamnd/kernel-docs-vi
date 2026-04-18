.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/PCI/controller/rcar-pcie-firmware.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================================
Firmware của bộ điều khiển PCIe cho Renesas R-Car V4H
=====================================================

Renesas R-Car V4H (r8a779g0) có bộ điều khiển PCIe, yêu cầu một bộ điều khiển cụ thể
tải xuống firmware trong khi khởi động.

Tuy nhiên, Renesas hiện không thể phân phối phần mềm miễn phí.

Tệp chương trình cơ sở "104_PCIe_fw_addr_data_ver1.05.txt" (lưu ý rằng tên tệp
có thể khác nhau giữa các phiên bản bảng dữ liệu khác nhau) có thể được tìm thấy trong
biểu dữ liệu được mã hóa dưới dạng văn bản và do đó nội dung của tệp phải được chuyển đổi
trở lại dạng nhị phân. Điều này có thể đạt được bằng cách sử dụng tập lệnh ví dụ sau:

.. code-block:: sh

	$ awk '/^\s*0x[0-9A-Fa-f]{4}\s+0x[0-9A-Fa-f]{4}/ { print substr($2,5,2) substr($2,3,2) }' \
		104_PCIe_fw_addr_data_ver1.05.txt | \
			xxd -p -r > rcar_gen4_pcie.bin

Khi nội dung văn bản đã được chuyển đổi thành tệp chương trình cơ sở nhị phân, hãy xác minh
tổng kiểm tra của nó như sau:

.. code-block:: sh

	$ sha1sum rcar_gen4_pcie.bin
	1d0bd4b189b4eb009f5d564b1f93a79112994945  rcar_gen4_pcie.bin

Tệp nhị phân thu được có tên "rcar_gen4_pcie.bin" phải được đặt trong thư mục
Thư mục "/lib/firmware" trước khi trình điều khiển chạy.