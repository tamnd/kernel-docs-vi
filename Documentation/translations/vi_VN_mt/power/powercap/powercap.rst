.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/power/powercap/powercap.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========================
Khung giới hạn năng lượng
=======================

Khung giới hạn năng lượng cung cấp giao diện nhất quán giữa kernel
và không gian người dùng cho phép trình điều khiển giới hạn nguồn hiển thị các cài đặt
không gian người dùng một cách thống nhất.

Thuật ngữ
===========

Khung này hiển thị các thiết bị giới hạn nguồn tới không gian người dùng thông qua sysfs trong
dạng cây đồ vật. Các đối tượng ở cấp độ gốc của cây đại diện cho
'các loại điều khiển', tương ứng với các phương pháp giới hạn công suất khác nhau.  cho
Ví dụ: loại điều khiển intel-rapl đại diện cho Intel "Running Average
Công nghệ Power Limit" (RAPL), trong khi loại điều khiển 'tiêm không tải'
tương ứng với việc sử dụng chế độ chèn không tải để kiểm soát nguồn điện.

Vùng điện đại diện cho các phần khác nhau của hệ thống, có thể được kiểm soát và
được giám sát bằng phương pháp giới hạn công suất được xác định bởi loại điều khiển
khu vực nhất định thuộc về. Mỗi chúng đều chứa các thuộc tính để giám sát sức mạnh, như
cũng như các điều khiển được thể hiện dưới dạng các hạn chế về quyền lực.  Nếu các bộ phận của
hệ thống được đại diện bởi các vùng quyền lực khác nhau có tính phân cấp (nghĩa là một
phần lớn hơn bao gồm nhiều phần nhỏ hơn, mỗi phần có sức mạnh riêng
điều khiển), các vùng quyền lực đó cũng có thể được tổ chức theo thứ bậc với một
vùng năng lượng chính chứa nhiều vùng con, v.v. để phản ánh sức mạnh
topo điều khiển của hệ thống.  Trong trường hợp đó có thể dùng điện
giới hạn một tập hợp các thiết bị cùng nhau bằng cách sử dụng vùng nguồn chính và nếu nhiều hơn
cần phải có sự kiểm soát chi tiết, nó có thể được áp dụng thông qua các tiểu vùng.


Ví dụ về cây giao diện sysfs::

/sys/thiết bị/ảo/powercap
  └──intel-rapl
      ├──intel-rapl:0
      │   ├──ràng buộc_0_name
      │   ├──constraint_0_power_limit_uw
      │   ├──ràng buộc_0_time_window_us
      │   ├──ràng buộc_1_name
      │   ├──ràng buộc_1_power_limit_uw
      │   ├──ràng buộc_1_time_window_us
      │   ├──thiết bị -> ../../intel-rapl
      │   ├──năng lượng_uj
      │   ├──intel-rapl:0:0
      │   │   ├──ràng buộc_0_name
      │   │   ├──constraint_0_power_limit_uw
      │   │   ├──ràng buộc_0_time_window_us
      │   │   ├──ràng buộc_1_name
      │   │   ├──ràng buộc_1_power_limit_uw
      │   │   ├──ràng buộc_1_time_window_us
      │   │   ├──thiết bị -> ../../intel-rapl:0
      │   │   ├──năng lượng_uj
      │   │   ├──max_energy_range_uj
      │   │   ├──tên
      │   │   ├──đã bật
      │   │   ├──sức mạnh
      │   │   │   ├──không đồng bộ
      │   │   │   []
      │   │   ├──hệ thống con -> ../../../../../class/power_cap
      │   │   └──sự kiện
      │   ├──intel-rapl:0:1
      │   │   ├──ràng buộc_0_name
      │   │   ├──constraint_0_power_limit_uw
      │   │   ├──ràng buộc_0_time_window_us
      │   │   ├──ràng buộc_1_name
      │   │   ├──ràng buộc_1_power_limit_uw
      │   │   ├──ràng buộc_1_time_window_us
      │   │   ├──thiết bị -> ../../intel-rapl:0
      │   │   ├──năng lượng_uj
      │   │   ├──max_energy_range_uj
      │   │   ├──tên
      │   │   ├──đã bật
      │   │   ├──sức mạnh
      │   │   │   ├──không đồng bộ
      │   │   │   []
      │   │   ├──hệ thống con -> ../../../../../class/power_cap
      │   │   └──sự kiện
      │   ├──max_energy_range_uj
      │   ├──max_power_range_uw
      │   ├──tên
      │   ├──đã bật
      │   ├──sức mạnh
      │   │   ├──không đồng bộ
      │   │   []
      │   ├──hệ thống con -> ../../../../class/power_cap
      │   ├──đã bật
      │   ├──sự kiện
      ├──intel-rapl:1
      │   ├──ràng buộc_0_name
      │   ├──constraint_0_power_limit_uw
      │   ├──ràng buộc_0_time_window_us
      │   ├──ràng buộc_1_name
      │   ├──ràng buộc_1_power_limit_uw
      │   ├──ràng buộc_1_time_window_us
      │   ├──thiết bị -> ../../intel-rapl
      │   ├──năng lượng_uj
      │   ├──intel-rapl:1:0
      │   │   ├──ràng buộc_0_name
      │   │   ├──constraint_0_power_limit_uw
      │   │   ├──ràng buộc_0_time_window_us
      │   │   ├──ràng buộc_1_name
      │   │   ├──ràng buộc_1_power_limit_uw
      │   │   ├──ràng buộc_1_time_window_us
      │   │   ├──thiết bị -> ../../intel-rapl:1
      │   │   ├──năng lượng_uj
      │   │   ├──max_energy_range_uj
      │   │   ├──tên
      │   │   ├──đã bật
      │   │   ├──sức mạnh
      │   │   │   ├──không đồng bộ
      │   │   │   []
      │   │   ├──hệ thống con -> ../../../../../class/power_cap
      │   │   └──sự kiện
      │   ├──intel-rapl:1:1
      │   │   ├──ràng buộc_0_name
      │   │   ├──constraint_0_power_limit_uw
      │   │   ├──ràng buộc_0_time_window_us
      │   │   ├──ràng buộc_1_name
      │   │   ├──ràng buộc_1_power_limit_uw
      │   │   ├──ràng buộc_1_time_window_us
      │   │   ├──thiết bị -> ../../intel-rapl:1
      │   │   ├──năng lượng_uj
      │   │   ├──max_energy_range_uj
      │   │   ├──tên
      │   │   ├──đã bật
      │   │   ├──sức mạnh
      │   │   │   ├──không đồng bộ
      │   │   │   []
      │   │   ├──hệ thống con -> ../../../../../class/power_cap
      │   │   └──sự kiện
      │   ├──max_energy_range_uj
      │   ├──max_power_range_uw
      │   ├──tên
      │   ├──đã bật
      │   ├──sức mạnh
      │   │   ├──không đồng bộ
      │   │   []
      │   ├──hệ thống con -> ../../../../class/power_cap
      │   ├──sự kiện
      ├──sức mạnh
      │   ├──không đồng bộ
      │   []
      ├──hệ thống con -> ../../../../class/power_cap
      ├──đã bật
      └──sự kiện

Ví dụ trên minh họa trường hợp trong đó công nghệ Intel RAPL,
có sẵn trong Kiến trúc bộ xử lý Intel® IA-64 và IA-32, được sử dụng. Có một cái
loại điều khiển được gọi là intel-rapl chứa hai vùng năng lượng, intel-rapl:0 và
intel-rapl:1, đại diện cho các gói CPU.  Mỗi vùng quyền lực này chứa
hai vùng con, intel-rapl:j:0 và intel-rapl:j:1 (j = 0, 1), đại diện cho
phần "lõi" và "không lõi" của gói CPU đã cho tương ứng.  Tất cả
các vùng và tiểu vùng chứa các thuộc tính giám sát năng lượng (energy_uj,
max_energy_range_uj) và thuộc tính ràng buộc (ràng buộc_*) cho phép điều khiển
được áp dụng (các ràng buộc trong vùng quyền lực 'gói' áp dụng cho toàn bộ
Các gói CPU và các ràng buộc vùng phụ chỉ áp dụng cho các phần tương ứng của
gói nhất định riêng lẻ). Vì Intel RAPL không cung cấp tức thời
giá trị sức mạnh, không có thuộc tính power_uw.

Ngoài ra, mỗi vùng năng lượng còn chứa một thuộc tính tên, cho phép
một phần của hệ thống được đại diện bởi vùng đó sẽ được xác định.
Ví dụ::

mèo /sys/class/power_cap/intel-rapl/intel-rapl:0/name

gói-0
---------

Tùy thuộc vào các vùng công suất khác nhau, công nghệ Intel RAPL cho phép
một hoặc nhiều hạn chế như công suất ngắn hạn, dài hạn và công suất đỉnh,
với các cửa sổ thời gian khác nhau được áp dụng cho từng vùng điện.
Tất cả các vùng chứa các thuộc tính đại diện cho tên ràng buộc,
giới hạn công suất và kích thước của cửa sổ thời gian. Lưu ý rằng cửa sổ thời gian
không áp dụng được với công suất đỉnh. Ở đây, thuộc tính ràng buộc_j_*
tương ứng với ràng buộc thứ j (j = 0,1,2).

Ví dụ::

ràng buộc_0_name
	ràng buộc_0_power_limit_uw
	ràng buộc_0_time_window_us
	ràng buộc_1_name
	ràng buộc_1_power_limit_uw
	ràng buộc_1_time_window_us
	ràng buộc_2_name
	ràng buộc_2_power_limit_uw
	ràng buộc_2_time_window_us

Thuộc tính vùng quyền lực
=====================

Thuộc tính giám sát
---------------------

năng lượng_uj (rw)
	Bộ đếm năng lượng hiện tại tính bằng micro joules. Viết "0" để thiết lập lại.
	Nếu bộ đếm không thể được đặt lại thì thuộc tính này ở dạng chỉ đọc.

max_energy_range_uj (ro)
	Phạm vi của bộ đếm năng lượng trên tính bằng micro-joules.

power_uw (ro)
	Công suất hiện tại tính bằng micro watt.

max_power_range_uw (ro)
	Phạm vi của giá trị công suất trên tính bằng micro-watt.

tên (ro)
	Tên vùng điện này

Có thể một số miền có cả dải công suất và dải bộ đếm năng lượng;
tuy nhiên, chỉ có một là bắt buộc.

Hạn chế
-----------

ràng buộc_X_power_limit_uw (rw)
	Giới hạn công suất tính bằng micro watt, nên được áp dụng cho
	khoảng thời gian được chỉ định bởi "constraint_X_time_window_us".

ràng buộc_X_time_window_us (rw)
	Cửa sổ thời gian tính bằng micro giây.

ràng buộc_X_name (ro)
	Tên tùy chọn của ràng buộc

ràng buộc_X_max_power_uw(ro)
	Công suất tối đa cho phép tính bằng micro watt.

ràng buộc_X_min_power_uw(ro)
	Công suất tối thiểu cho phép tính bằng micro watt.

ràng buộc_X_max_time_window_us(ro)
	Cửa sổ thời gian tối đa được phép tính bằng micro giây.

ràng buộc_X_min_time_window_us(ro)
	Cửa sổ thời gian tối thiểu được phép tính bằng micro giây.

Ngoại trừ power_limit_uw và time_window_us các trường khác là tùy chọn.

Thuộc tính vùng chung và loại điều khiển
---------------------------------------

đã bật (rw): Bật/Tắt điều khiển ở cấp vùng hoặc cho tất cả các vùng bằng cách sử dụng
một loại điều khiển.

Giao diện trình điều khiển máy khách Power Cap
=================================

Tóm tắt API:

Gọi powercap_register_control_type() để đăng ký đối tượng loại điều khiển.
Gọi powercap_register_zone() để đăng ký vùng nguồn (theo
loại điều khiển), hoặc là vùng quyền lực cấp cao nhất hoặc là vùng con của vùng khác
vùng điện đã đăng ký trước đó.
Số lượng ràng buộc trong vùng quyền lực và các lệnh gọi lại tương ứng có
được xác định trước khi gọi powercap_register_zone() để đăng ký vùng đó.

Để giải phóng vùng điện, hãy gọi powercap_unregister_zone().
Để giải phóng một đối tượng loại điều khiển, hãy gọi powercap_unregister_control_type().
API chi tiết có thể được tạo bằng kernel-doc trên include/linux/powercap.h.
