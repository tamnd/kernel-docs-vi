.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/smpro-hwmon.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân Ampere(R)'s Altra(R) SMpro hwmon
==============================================

Chip được hỗ trợ:

* Ampe(R) Altra(R)

Tiền tố: ZZ0000ZZ

Tham khảo: ZZ0000ZZ

Tác giả: Thu Nguyễn <thu@os.amperecomputing.com>

Sự miêu tả
-----------
Trình điều khiển smpro-hwmon hỗ trợ giám sát phần cứng cho Ampere(R) Altra(R)
SoC dựa trên bộ đồng xử lý SMpro (SMpro).  Các số liệu cảm biến sau
được hỗ trợ bởi người lái xe:

* nhiệt độ
  * điện áp
  * hiện tại
  * quyền lực

Giao diện cung cấp các thanh ghi để truy vấn các cảm biến khác nhau và
giá trị của chúng sau đó được trình điều khiển này xuất sang không gian người dùng.

Ghi chú sử dụng
-----------

Trình điều khiển tạo ít nhất hai tệp sysfs cho mỗi cảm biến.

* ZZ0000ZZ báo cáo nhãn cảm biến.
* ZZ0001ZZ trả về giá trị cảm biến.

Các tệp sysfs được phân bổ trong thư mục SMpro rootfs, với một gốc
thư mục cho mỗi trường hợp.

Khi SoC bị tắt, trình điều khiển sẽ không đọc được các thanh ghi và
trả lại ZZ0000ZZ.

Mục nhập hệ thống
-------------

Các tệp sysfs sau được hỗ trợ:

* Ampe(R) Altra(R):

=============================== ====================================================
  Tên Đơn vị Perm Mô tả
  =============================== ====================================================
  nhiệt độ temp1_input millicelsius RO SoC
  temp2_input millicelsius RO Nhiệt độ tối đa được báo cáo giữa các SoC VRD
  temp2_crit millicelsius RO SoC VRD HOT Nhiệt độ ngưỡng
  temp3_input millicelsius RO Nhiệt độ tối đa được báo cáo trong số DIMM VRD
  temp4_input millicelsius RO Nhiệt độ tối đa được báo cáo giữa các Core VRD
  temp5_input millicelsius RO Nhiệt độ của DIMM0 trên CH0
  temp5_crit millicelsius RO MEM HOT Ngưỡng cho tất cả DIMM
  temp6_input millicelsius RO Nhiệt độ của DIMM0 trên CH1
  temp6_crit millicelsius RO MEM HOT Ngưỡng cho tất cả DIMM
  temp7_input millicelsius RO Nhiệt độ của DIMM0 trên CH2
  temp7_crit millicelsius RO MEM HOT Ngưỡng cho tất cả DIMM
  temp8_input millicelsius RO Nhiệt độ của DIMM0 trên CH3
  temp8_crit millicelsius RO MEM HOT Ngưỡng cho tất cả DIMM
  temp9_input millicelsius RO Nhiệt độ của DIMM0 trên CH4
  temp9_crit millicelsius RO MEM HOT Ngưỡng cho tất cả DIMM
  temp10_input millicelsius RO Nhiệt độ của DIMM0 trên CH5
  temp10_crit millicelsius RO MEM HOT Ngưỡng cho tất cả DIMM
  temp11_input millicelsius RO Nhiệt độ của DIMM0 trên CH6
  temp11_crit millicelsius RO MEM HOT Ngưỡng cho tất cả DIMM
  temp12_input millicelsius RO Nhiệt độ của DIMM0 trên CH7
  temp12_crit millicelsius RO MEM HOT Ngưỡng cho tất cả DIMM
  temp13_input millicelsius RO Nhiệt độ tối đa được báo cáo trong số RCA VRD
  in0_input millivolts RO Điện áp lõi
  in1_input mV RO Điện áp SoC
  in2_input millivolts Điện áp RO DIMM VRD1
  in3_input millivolts Điện áp RO DIMM VRD2
  in4_input millivolts Điện áp RO RCA VRD
  cur1_input milliamperes RO Core VRD hiện tại
  cur2_input milliamperes RO SoC VRD hiện tại
  cur3_input milliamperes RO DIMM VRD1 hiện tại
  cur4_input milliamperes RO DIMM VRD2 hiện tại
  cur5_input milliamperes RO RCA VRD hiện tại
  công suất1_đầu vào microwatt Công suất RO Core VRD
  power2_đầu vào microwatts RO SoC VRD điện
  power3_đầu vào microwatts RO DIMM VRD1 điện
  power4_đầu vào microwatts RO DIMM VRD2 điện
  điện5_đầu vào microwatts RO RCA VRD điện
  =============================== ====================================================

Ví dụ::

# cat đầu vào0_input
    830
    # cat temp1_input
    37000
    # cat curr1_input
    9000
    # cat nguồn5_input
    19500000