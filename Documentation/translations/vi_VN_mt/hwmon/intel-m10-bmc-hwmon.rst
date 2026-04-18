.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/intel-m10-bmc-hwmon.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân intel-m10-bmc-hwmon
=================================

Chip được hỗ trợ:

* Intel MAX 10 BMC dành cho Intel PAC N3000

Tiền tố: 'n3000bmc-hwmon'

Tác giả: Xu Yilun <yilun.xu@intel.com>


Sự miêu tả
-----------

Trình điều khiển này thêm nhiệt độ, điện áp, dòng điện và công suất
hỗ trợ chip Intel MAX 10 Board Management Controller (BMC).
Chip BMC được tích hợp trong một số bộ tăng tốc lập trình của Intel
Thẻ (PAC). Nó kết nối với một bộ chip cảm biến để theo dõi
dữ liệu cảm biến của các thành phần khác nhau trên bảng. Phần sụn BMC là
chịu trách nhiệm lấy mẫu và ghi dữ liệu cảm biến trong hệ thống chia sẻ
sổ đăng ký. Trình điều khiển máy chủ đọc dữ liệu cảm biến từ các dữ liệu được chia sẻ này
đăng ký và hiển thị chúng cho người dùng dưới dạng giao diện hwmon.

Chip BMC được triển khai bằng Intel MAX 10 CPLD. Nó có thể là
được lập trình lại cho một số biến thể để hỗ trợ Intel khác nhau
PAC. Trình điều khiển được thiết kế để có thể phân biệt giữa
các biến thể, nhưng hiện tại nó chỉ hỗ trợ BMC cho Intel PAC N3000.


Thuộc tính Sysfs
----------------

Các thuộc tính sau được hỗ trợ:

- Intel MAX 10 BMC dành cho Intel PAC N3000:

====================================================================================
tempX_input Nhiệt độ của thành phần (được chỉ định bởi tempX_label)
tempX_max Điểm đặt nhiệt độ tối đa của thành phần
tempX_crit Điểm đặt nhiệt độ tới hạn của thành phần
tempX_max_hyst Độ trễ cho nhiệt độ tối đa của thành phần
tempX_crit_hyst Độ trễ cho nhiệt độ tới hạn của thành phần
temp1_label "Nhiệt độ bảng"
temp2_label "Nhiệt độ khuôn FPGA"
temp3_label "Nhiệt độ QSFP0"
temp4_label "Nhiệt độ QSFP1"
temp5_label "Retimer A Nhiệt độ"
temp6_label "Retimer A SerDes Nhiệt độ"
temp7_label "Nhiệt độ Retimer B"
temp8_label "Retimer B SerDes Nhiệt độ"

inX_input Điện áp đo được của linh kiện (được chỉ định bởi
                        inX_label)
in0_label "Điện áp nguồn QSFP0"
in1_label "Điện áp nguồn QSFP1"
in2_label "Điện áp lõi FPGA"
in3_label "Điện áp bảng nối đa năng 12V"
in4_label "Điện áp 1,2V"
in5_label "Điện áp 12V AUX"
in6_label "Điện áp 1.8V"
in7_label "Điện áp 3,3V"

currX_input Dòng điện đo được của thành phần (được chỉ định bởi
                        currX_label)
curr1_label "Dòng lõi FPGA"
curr2_label "Dòng điện đa năng 12V"
curr3_label "Dòng điện 12V AUX"

powerX_input Công suất đo được của thành phần (được chỉ định bởi
                        powerX_label)
power1_label "Sức mạnh của bo mạch"

====================================================================================

Tất cả các thuộc tính là chỉ đọc.