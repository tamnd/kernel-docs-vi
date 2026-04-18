.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/pm/intel_uncore_frequency_scaling.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

=================================
Mở rộng tần số Intel Uncore
=================================

:Bản quyền: ZZ0000ZZ 2022-2023 Tập đoàn Intel

:Tác giả: Srinivas Pandruvada <srinivas.pandruvada@linux.intel.com>

Giới thiệu
------------

Uncore có thể tiêu thụ lượng điện năng đáng kể trong các máy chủ Xeon của Intel
về đặc điểm khối lượng công việc. Để tối ưu hóa tổng sức mạnh và cải thiện tổng thể
hiệu suất, SoC có các thuật toán nội bộ để mở rộng tần số không lõi. Những cái này
Các thuật toán giám sát việc sử dụng khối lượng công việc của uncore và đặt tần suất mong muốn.

Có thể người dùng có những kỳ vọng khác nhau về hiệu năng không cốt lõi và
muốn kiểm soát nó. Mục tiêu tương tự như việc cho phép người dùng thiết lập
tần số tối thiểu/tối đa chia tỷ lệ thông qua sysfs cpufreq để cải thiện hiệu suất CPU.
Người dùng có thể có một số khối lượng công việc nhạy cảm với độ trễ mà họ không muốn bất kỳ
thay đổi tần số uncore. Ngoài ra, người dùng có thể có khối lượng công việc đòi hỏi
hiệu suất lõi và không lõi khác nhau ở các giai đoạn riêng biệt và họ có thể muốn
sử dụng cả cpufreq và giao diện mở rộng không lõi để phân phối sức mạnh và
cải thiện hiệu suất tổng thể.

Giao diện hệ thống
---------------

Để kiểm soát tần số không lõi, giao diện sysfs được cung cấp trong thư mục:
ZZ0000ZZ.

Có một thư mục cho mỗi gói và tổ hợp khuôn trong phạm vi của
kiểm soát tỷ lệ không lõi được thực hiện trên mỗi khuôn trong nhiều SoC khuôn/gói hoặc trên mỗi khuôn
gói cho khuôn đơn cho mỗi gói SoC. Cái tên tượng trưng cho
phạm vi kiểm soát. Ví dụ: 'package_00_die_00' dành cho id gói 0 và
chết 0.

Mỗi gói_*_die_* chứa các thuộc tính sau:

ZZ0000ZZ
	Sau khi thiết lập lại, thuộc tính này biểu thị tần số tối đa có thể.
	Đây là thuộc tính chỉ đọc. Nếu người dùng điều chỉnh max_freq_khz,
	họ luôn có thể quay lại mức tối đa bằng cách sử dụng giá trị từ thuộc tính này.

ZZ0000ZZ
	Sau khi thiết lập lại, thuộc tính này biểu thị tần số tối thiểu có thể.
	Đây là thuộc tính chỉ đọc. Nếu người dùng điều chỉnh min_freq_khz,
	chúng luôn có thể quay về mức tối thiểu bằng cách sử dụng giá trị từ thuộc tính này.

ZZ0000ZZ
	Thuộc tính này được sử dụng để đặt tần số không lõi tối đa.

ZZ0000ZZ
	Thuộc tính này được sử dụng để đặt tần số uncore tối thiểu.

ZZ0000ZZ
	Thuộc tính này được sử dụng để lấy tần số hiện tại.

SoC với TPMI (Đăng ký nhận biết cấu trúc liên kết và Giao diện viên nang PM)
-----------------------------------------------------------------

Một SoC có thể chứa nhiều miền năng lượng riêng lẻ hoặc tập hợp
của các phân vùng dạng lưới. Phân vùng này được gọi là cụm vải.

Một số loại mắt lưới sẽ cần chạy ở cùng tần số, chúng sẽ
được đặt trong cùng một cụm vải. Lợi ích của cụm vải là nó
cung cấp một cơ chế có thể mở rộng để xử lý các loại vải được phân vùng trong SoC.

Giao diện sysfs hiện tại hỗ trợ các điều khiển ở cấp độ gói và khuôn.
Giao diện này không đủ để hỗ trợ điều khiển chi tiết hơn tại
cấp độ cụm vải.

SoC với sự hỗ trợ của TPMI (Đăng ký nhận thức cấu trúc liên kết và PM Capsule
Giao diện), có thể có nhiều miền quyền lực. Mỗi miền quyền lực có thể
chứa một hoặc nhiều cụm vải.

Để thể hiện các điều khiển ở cấp cụm vải ngoài
điều khiển ở cấp độ gói và khuôn (như các hệ thống không có TPMI
hỗ trợ), sysfs được nâng cao. Giao diện chi tiết này được trình bày trong
sysfs với tên thư mục có tiền tố "uncore". Ví dụ:
uncore00, uncore01, v.v.

Phạm vi kiểm soát được xác định bởi thuộc tính “package_id”, “domain_id”
và "fabric_cluster_id" trong thư mục.

Các thuộc tính trong mỗi thư mục:

ZZ0000ZZ
	Thuộc tính này được sử dụng để lấy id miền quyền lực của phiên bản này.

ZZ0000ZZ
	Thuộc tính này được sử dụng để lấy id die Linux của phiên bản này.
	Thuộc tính này chỉ hiện diện cho các miền có tác nhân cốt lõi và
	khi CPUID lá 0x1f xuất hiện ID chết.

ZZ0000ZZ
	Thuộc tính này được sử dụng để lấy id cụm vải của phiên bản này.

ZZ0000ZZ
	Thuộc tính này được sử dụng để lấy id gói của phiên bản này.

ZZ0000ZZ
	Thuộc tính này hiển thị tất cả các tác nhân phần cứng có trong
	miền. Mỗi tác nhân có khả năng điều khiển một hoặc nhiều phần cứng
	các hệ thống con, bao gồm: lõi, bộ đệm, bộ nhớ và I/O.

Các thuộc tính khác giống như được trình bày ở cấp độ gói_*_die_*.

Trong hầu hết các trường hợp sử dụng hiện tại, "max_freq_khz" và "min_freq_khz"
được cập nhật ở cấp độ "gói_*_die_*". Mô hình này sẽ vẫn được hỗ trợ
với cách tiếp cận sau:

Khi người dùng sử dụng các điều khiển ở cấp độ "gói_*_die_*", thì mọi loại vải
cụm bị ảnh hưởng trong gói đó và chết. Ví dụ: thay đổi của người dùng
"max_freq_khz" trong gói_00_die_00, sau đó là "max_freq_khz" cho gói không lõi*
thư mục có cùng id gói sẽ được cập nhật. Trong trường hợp này người dùng có thể
vẫn cập nhật "max_freq_khz" ở mỗi cấp độ uncore*, mức độ này hạn chế hơn.
Tương tự, người dùng có thể cập nhật "min_freq_khz" ở cấp độ "package_*_die_*"
để áp dụng ở mỗi cấp độ uncore*.

Hỗ trợ cho "current_freq_khz" chỉ khả dụng ở mỗi cụm vải
cấp độ (tức là trong thư mục uncore*).

Đánh đổi hiệu quả và độ trễ
-------------------------------

Tính năng Kiểm soát độ trễ hiệu quả (ELC) cải thiện hiệu suất
mỗi watt. Với tính năng này thuật toán quản lý năng lượng phần cứng
tối ưu hóa sự cân bằng giữa độ trễ và mức tiêu thụ điện năng. Đối với một số
Khối lượng công việc nhạy cảm với độ trễ có thể được điều chỉnh thêm bằng SW để
có được hiệu suất mong muốn.

Phần cứng giám sát mức sử dụng CPU trung bình trên tất cả các lõi
trong miền năng lượng đều đặn và quyết định tần số không lõi.
Mặc dù điều này có thể mang lại hiệu suất tốt nhất trên mỗi watt nhưng khối lượng công việc có thể
mong đợi hiệu suất cao hơn với chi phí năng lượng. Hãy xem xét một
ứng dụng thỉnh thoảng thức dậy để thực hiện việc đọc bộ nhớ trên
mặt khác hệ thống nhàn rỗi. Trong những trường hợp như vậy, nếu phần cứng hạ thấp uncore
tần số thì có thể có sự chậm trễ trong việc tăng tần số để đáp ứng
hiệu suất mục tiêu.

Điều khiển ELC xác định một số tham số có thể thay đổi từ SW.
Nếu mức sử dụng CPU trung bình thấp hơn ngưỡng do người dùng xác định
(thuộc tính elc_low_threshold_percent bên dưới), uncore do người dùng xác định
tần số sàn sẽ được sử dụng (thuộc tính elc_floor_freq_khz bên dưới)
thay vì phần cứng được tính toán tối thiểu.

Tương tự như vậy trong kịch bản tải cao khi mức sử dụng CPU vượt quá
giá trị ngưỡng cao (thuộc tính elc_high_threshold_percent bên dưới)
thay vì nhảy tới tần số tối đa, tần số sẽ tăng lên
theo bước 100 MHz. Điều này tránh tiêu thụ điện năng cao không cần thiết
ngay lập tức với mức sử dụng CPU tăng đột biến.

Các thuộc tính để kiểm soát độ trễ hiệu quả:

ZZ0000ZZ
	Thuộc tính này được sử dụng để lấy/đặt tần số sàn độ trễ hiệu quả.
	Nếu biến này thấp hơn 'min_freq_khz', nó sẽ bị bỏ qua bởi
	phần sụn.

ZZ0000ZZ
	Thuộc tính này được sử dụng để nhận/đặt kiểm soát độ trễ hiệu quả ở mức thấp
	ngưỡng. Thuộc tính này tính theo phần trăm sử dụng CPU.

ZZ0000ZZ
	Thuộc tính này được sử dụng để nhận/đặt kiểm soát độ trễ hiệu quả ở mức cao
	ngưỡng. Thuộc tính này tính theo phần trăm sử dụng CPU.

ZZ0000ZZ
	Thuộc tính này được sử dụng để bật/tắt kiểm soát độ trễ hiệu quả
	ngưỡng cao. Viết '1' để bật, '0' để tắt.

Cấu hình hệ thống ví dụ bên dưới, thực hiện như sau:
  * khi mức sử dụng CPU dưới 10%: đặt tần số không lõi thành 800 MHz
  * khi mức sử dụng CPU cao hơn 95%: tăng tần số không lõi trong
    Các bước 100 MHz, cho đến khi đạt đến giới hạn công suất

elc_floor_freq_khz:800000
  elc_high_threshold_percent:95
  elc_high_threshold_enable:1
  elc_low_threshold_percent:10