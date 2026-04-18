.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/thermal/nouveau_thermal.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
Trình điều khiển hạt nhân mới
=============================

Chip được hỗ trợ:

*NV43+

Tác giả: Martin Peres (mupuf) <martin.peres@free.fr>

Sự miêu tả
-----------

Trình điều khiển này cho phép đọc nhiệt độ lõi GPU, điều khiển quạt GPU và
đặt cảnh báo nhiệt độ.

Hiện tại, do không có API trong kernel để truy cập trình điều khiển HWMON, Nouveau
không thể truy cập bất kỳ chip giám sát bên ngoài i2c nào mà nó có thể tìm thấy. Nếu bạn
có một trong số đó, quản lý nhiệt độ và/hoặc quạt thông qua HWMON của Nouveau
giao diện có thể không hoạt động. Tài liệu này có thể không bao gồm trường hợp của bạn
hoàn toàn.

Quản lý nhiệt độ
----------------------

Nhiệt độ được hiển thị dưới dạng temp1_input thuộc tính HWMON chỉ đọc.

Để bảo vệ GPU khỏi quá nóng, Nouveau hỗ trợ 4 cấu hình
ngưỡng nhiệt độ:

* Fan_Boost:
	Tốc độ quạt được đặt thành 100% khi đạt đến nhiệt độ này;
 * Đồng hồ xuống:
	GPU sẽ được giảm xung nhịp để giảm khả năng tiêu tán điện năng;
 * Quan trọng:
	GPU được tạm dừng để giảm mức tiêu thụ điện năng hơn nữa;
 * Tắt máy:
	Tắt máy tính để bảo vệ GPU của bạn.

WARNING:
	Một số ngưỡng này có thể không được Nouveau sử dụng tùy theo
	trên chipset của bạn.

Giá trị mặc định cho các ngưỡng này đến từ vbios của GPU. Những cái này
ngưỡng có thể được cấu hình nhờ các thuộc tính HWMON sau:

* Fan_boost: temp1_auto_point1_temp và temp1_auto_point1_temp_hyst;
 * Đồng hồ giảm tốc: temp1_max và temp1_max_hyst;
 * Quan trọng: temp1_crit và temp1_crit_hyst;
 * Tắt máy: temp1_emergency và temp1_emergency_hyst.

NOTE: Hãy nhớ rằng các giá trị được lưu trữ dưới dạng mili độ C. Đừng quên
để nhân lên!

Quản lý quạt
--------------

Không phải tất cả các thẻ đều có quạt điều khiển được. Nếu bạn làm vậy thì HWMON sau đây
các thuộc tính nên có sẵn:

* pwm1_enable:
	Chế độ quản lý quạt hiện tại (NONE, MANUAL hoặc AUTO);
 * pwm1:
	Giá trị PWM hiện tại (phần trăm công suất);
 * pwm1_min:
	Tốc độ PWM tối thiểu được phép;
 *pwm1_max:
	Tốc độ PWM tối đa cho phép (bỏ qua khi nhấn Fan_boost);

Bạn cũng có thể có thuộc tính sau:

* fan1_input:
	Tốc độ trong RPM của quạt của bạn.

Quạt của bạn có thể được điều khiển ở các chế độ khác nhau:

* 0: Quạt không bị ảnh hưởng;
 * 1: Quạt có thể được điều khiển bằng tay (sử dụng pwm1 để thay đổi tốc độ);
 * 2; Quạt được điều khiển tự động tùy thuộc vào nhiệt độ.

NOTE:
  Đảm bảo sử dụng chế độ thủ công nếu bạn muốn điều chỉnh tốc độ quạt theo cách thủ công

NOTE2:
  Khi hoạt động ở chế độ thủ công ngoài phạm vi được xác định bởi vbios
  Phạm vi [PWM_min,PWM_max], tốc độ quạt được báo cáo (RPM) có thể không chính xác
  tùy thuộc vào phần cứng của bạn.

Báo cáo lỗi
-----------

Quản lý nhiệt trên Nouveau là tính năng mới và có thể không hoạt động trên tất cả các thẻ. Nếu bạn có
nếu có thắc mắc, vui lòng ping mupuf trên IRC (#nouveau, OFTC).

Báo cáo lỗi phải được điền vào trình theo dõi lỗi của Freedesktop. Hãy theo dõi
ZZ0000ZZ
