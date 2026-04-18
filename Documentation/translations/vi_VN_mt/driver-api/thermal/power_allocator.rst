.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/thermal/power_allocator.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================
Bộ điều chỉnh bộ điều chỉnh cấp phát điện
=================================

Điểm chuyến đi
-----------

Bộ điều tốc hoạt động tối ưu với hai điểm ngắt thụ động sau:

1. Điểm ngắt "bật": nhiệt độ trên mức mà bộ điều tốc
    vòng điều khiển bắt đầu hoạt động.  Đây là chuyến đi thụ động đầu tiên
    điểm của vùng nhiệt

2. Điểm ngắt "nhiệt độ mong muốn": nó phải cao hơn nhiệt độ mong muốn
    điểm chuyến đi "bật".  Đây là nhiệt độ mục tiêu của thống đốc
    đang kiểm soát cho.  Đây là điểm dừng thụ động cuối cùng của
    vùng nhiệt.

Bộ điều khiển PID
--------------

Bộ điều chỉnh phân bổ quyền lực thực hiện một
Bộ điều khiển đạo hàm tỉ lệ-tích phân (bộ điều khiển PID) với
nhiệt độ làm đầu vào điều khiển và công suất làm đầu ra được điều khiển:

P_max = k_p * e + k_i * err_integral + k_d * diff_err + bền vững_power

ở đâu
   - e = nhiệt độ mong muốn - nhiệt độ hiện tại
   - err_integral là tổng các lỗi trước đó
   - diff_err = e - previous_error

Nó tương tự như mô tả dưới đây::

k_d
				       |
  hiện tại_temp |
       |                               v
       |              +----------+ +---+
       ZZ0000ZZ khác_err ZZ0001ZZ X |------+
       ZZ0002ZZ +----------+ +---+ |
       ZZ0003ZZ |      diễn viên tdp
       ZZ0004ZZ k_i ZZ0005ZZ get_requested_power()
       ZZ0006ZZ ZZ0007ZZ ZZ0008ZZ |
       ZZ0009ZZ ZZ0010ZZ ZZ0011ZZ | ...
       v |                       v v v v v
     +---+ |      +-------+ +---+ +---+ +---+ +----------+
     ZZ0012ZZ------+------->ZZ0013ZZ----->ZZ0014ZZ--->ZZ0015ZZ-->ZZ0016ZZ-->ZZ0017ZZ
     +---+ |      +-------+      +---+    +---+   +---+   |allocation|
       ^ |                                ^ +----------+
       ZZ0019ZZ ZZ0020ZZ |
       ZZ0021ZZ +---+ ZZ0022ZZ |
       ZZ0023ZZ X |-------------------+ v v
       |                +---+ được cấp hiệu suất
  mong muốn_nhiệt độ ^
			  |
			  |
		      k_po/k_pu

Sức mạnh bền vững
-----------------

Ước tính công suất tiêu tán bền vững (tính bằng mW) phải là
được cung cấp trong khi đăng ký vùng nhiệt.  Điều này ước tính
sức mạnh duy trì có thể được tiêu tan ở mức kiểm soát mong muốn
nhiệt độ.  Đây là công suất duy trì tối đa để phân bổ tại
nhiệt độ tối đa mong muốn.  Sức mạnh duy trì thực tế có thể thay đổi
vì một số lý do.  Bộ điều khiển vòng kín sẽ đảm nhiệm việc
những biến đổi như điều kiện môi trường và một số yếu tố liên quan
đến cấp độ tốc độ của silicon.  Do đó ZZ0000ZZ là
chỉ đơn giản là một ước tính và có thể được điều chỉnh để tác động đến mức độ hung hãn của
đoạn đường nối nhiệt. Để tham khảo, sức mạnh bền vững của điện thoại 4"
thường là 2000mW, trong khi trên máy tính bảng 10" là khoảng 4500mW (có thể thay đổi
tùy thuộc vào kích thước màn hình). Có thể có giá trị công suất
được thể hiện ở một thang đo trừu tượng. Sức mạnh bền vững phải được căn chỉnh
theo quy mô được sử dụng bởi các thiết bị làm mát liên quan.

Nếu bạn đang sử dụng cây thiết bị, hãy thêm nó làm thuộc tính của
vùng nhiệt.  Ví dụ::

vùng nhiệt {
		xã hội_thermal {
			bỏ phiếu-độ trễ = <1000>;
			bỏ phiếu-độ trễ-thụ động = <100>;
			năng lượng bền vững = <2500>;
			...

Thay vào đó, nếu vùng nhiệt được đăng ký từ mã nền tảng, hãy chuyển một
ZZ0000ZZ có ZZ0001ZZ.  Nếu không
ZZ0002ZZ đã được thông qua, sau đó có nội dung như bên dưới
sẽ đủ::

cấu trúc const tĩnh Thermal_zone_params tz_params = {
		.sustainable_power = 3500,
	};

và sau đó chuyển ZZ0000ZZ làm tham số thứ 5 cho
ZZ0001ZZ

k_po và k_pu
-------------

Việc triển khai bộ điều khiển PID trong bộ cấp nguồn
bộ điều chỉnh nhiệt cho phép cấu hình hai số hạng tỷ lệ
hằng số: ZZ0000ZZ và ZZ0001ZZ.  ZZ0002ZZ là số hạng tỷ lệ
không đổi trong thời gian vượt quá nhiệt độ (nhiệt độ hiện tại là
trên điểm ngắt "nhiệt độ mong muốn").  Ngược lại, ZZ0003ZZ là
hằng số tỷ lệ trong thời gian thiếu nhiệt độ
(nhiệt độ hiện tại dưới điểm ngắt "nhiệt độ mong muốn").

Những điều khiển này được coi là cơ chế chính để cấu hình
"đoạn đường nối" nhiệt được phép của hệ thống.  Ví dụ, mức thấp hơn
Giá trị ZZ0000ZZ sẽ cung cấp tốc độ chậm hơn, với chi phí giới hạn
công suất sẵn có ở nhiệt độ thấp.  Mặt khác, mức cao
giá trị của ZZ0001ZZ sẽ dẫn đến việc thống đốc trao quyền lực rất cao
trong khi nhiệt độ thấp và có thể dẫn đến nhiệt độ tăng vọt.

Giá trị mặc định cho ZZ0000ZZ là::

2 * sức mạnh bền vững / (nhiệt độ mong muốn - switch_on_temp)

Điều này có nghĩa là tại ZZ0000ZZ, đầu ra của bộ điều khiển
số hạng tỷ lệ sẽ là 2 * ZZ0001ZZ.  Giá trị mặc định
đối với ZZ0002ZZ là::

bền vững_power / (mong muốn_nhiệt độ - switch_on_temp)

Tập trung vào các giá trị tỷ lệ và chuyển tiếp của PID
phương trình điều khiển ta có::

P_max = k_p * e + sức mạnh bền vững

Số hạng tỷ lệ tỷ lệ thuận với sự khác biệt giữa
nhiệt độ mong muốn và nhiệt độ hiện tại.  Khi nhiệt độ hiện tại
là giá trị mong muốn thì thành phần tỷ lệ bằng 0 và
ZZ0000ZZ = ZZ0001ZZ.  Tức là hệ thống phải hoạt động ở
cân bằng nhiệt dưới tải không đổi.  ZZ0002ZZ chỉ
một ước tính, đó là lý do cho việc điều khiển vòng kín như thế này.

Mở rộng ZZ0000ZZ chúng ta có::

P_max = 2 * sức mạnh bền vững * (T_set - T) / (T_set - T_on) +
	sức mạnh bền vững

Ở đâu:

- T_set là nhiệt độ mong muốn
    - T là nhiệt độ hiện tại
    - T_on là công tắc bật nhiệt độ

Khi nhiệt độ hiện tại là nhiệt độ switch_on, nhiệt độ trên
công thức trở thành::

P_max = 2 * sức mạnh bền vững * (T_set - T_on) / (T_set - T_on) +
	sức mạnh bền vững = 2 * sức mạnh bền vững + sức mạnh bền vững =
	3 * sức mạnh bền vững

Do đó, chỉ riêng thuật ngữ tỷ lệ đã làm giảm tuyến tính công suất từ
3 * ZZ0000ZZ đến ZZ0001ZZ là nhiệt độ
tăng từ công tắc bật nhiệt độ đến nhiệt độ mong muốn.

k_i và tích phân_cutoff
-----------------------

ZZ0000ZZ định cấu hình hằng số thuật ngữ tích phân của vòng lặp PID.  Thuật ngữ này
cho phép bộ điều khiển PID bù cho độ trôi dài hạn và cho
bản chất lượng tử hóa của điều khiển đầu ra: thiết bị làm mát không thể thiết lập
quyền lực chính xác mà thống đốc yêu cầu.  Khi nhiệt độ
lỗi dưới ZZ0001ZZ, lỗi được tích lũy trong
thuật ngữ tích phân.  Số hạng này sau đó được nhân với ZZ0002ZZ và kết quả
thêm vào đầu ra của bộ điều khiển.  Thông thường ZZ0003ZZ được đặt ở mức thấp (1
hoặc 2) và ZZ0004ZZ là 0.

k_d
---

ZZ0000ZZ cấu hình hằng số thuật ngữ đạo hàm của vòng lặp PID.  Đó là
nên để nó làm mặc định: 0.

Công suất thiết bị làm mát API
========================

Các thiết bị làm mát được điều khiển bởi bộ điều tốc này phải cung cấp thêm
"quyền lực" API trong ZZ0000ZZ của họ.  Nó bao gồm ba hoạt động:

1. ::

int get_requested_power(struct Thermal_cooling_device *cdev,
			    cấu trúc Thermal_zone_device *tz, u32 *power);


@cdev:
	Con trỏ ZZ0000ZZ
@tz:
	vùng nhiệt mà chúng tôi hiện đang hoạt động
@power:
	con trỏ để lưu trữ công suất tính toán

ZZ0000ZZ tính toán công suất mà thiết bị yêu cầu
tính bằng miliwatt và lưu trữ nó trong @power .  Nó sẽ trả về 0 vào
thành công, -E* khi thất bại.  Điều này hiện đang được sử dụng bởi sức mạnh
bộ điều chỉnh cấp phát để tính toán lượng điện năng cung cấp cho mỗi lần làm mát
thiết bị.

2. ::

int state2power(struct Thermal_cooling_device *cdev, struct
			Thermal_zone_device *tz, trạng thái dài không dấu,
			u32 *nguồn);

@cdev:
	Con trỏ ZZ0000ZZ
@tz:
	vùng nhiệt mà chúng tôi hiện đang hoạt động
@state:
	Trạng thái thiết bị làm mát
@power:
	con trỏ để lưu trữ sức mạnh tương đương

Chuyển đổi trạng thái @state của thiết bị làm mát thành mức tiêu thụ điện năng trong
miliwatt và lưu trữ nó trong @power.  Nó sẽ trả về 0 nếu thành công, -E*
về sự thất bại.  Điều này hiện đang được lõi nhiệt sử dụng để tính toán
công suất tối đa mà tác nhân có thể tiêu thụ.

3. ::

int power2state(struct Thermal_cooling_device *cdev, nguồn u32,
			trạng thái * dài không dấu);

@cdev:
	Con trỏ ZZ0000ZZ
@power:
	công suất tính bằng miliwatt
@state:
	con trỏ để lưu trữ trạng thái kết quả

Tính toán trạng thái thiết bị làm mát sẽ khiến thiết bị tiêu thụ ở mức
nhất @power mW và lưu trữ nó trong @state.  Nó sẽ trả về 0 nếu thành công,
-E* khi thất bại.  Điều này hiện đang được lõi nhiệt sử dụng để chuyển đổi
một quyền lực nhất định do thống đốc cơ quan phân bổ quyền lực đặt ra cho một tiểu bang mà
thiết bị làm mát có thể thiết lập.  Nó là một chức năng vì sự chuyển đổi này có thể
phụ thuộc vào các yếu tố bên ngoài có thể thay đổi nên chức năng này sẽ
chuyển đổi tốt nhất dựa trên "hoàn cảnh hiện tại".

Trọng lượng thiết bị làm mát
----------------------

Trọng lượng là một cơ chế để thiên vị sự phân bổ giữa các hệ thống làm mát
thiết bị.  Chúng thể hiện hiệu suất năng lượng tương đối của các loại khác nhau
các thiết bị làm mát.  Trọng lượng cao hơn có thể được sử dụng để thể hiện sức mạnh cao hơn
hiệu quả.  Trọng số mang tính tương đối sao cho nếu mỗi thiết bị làm mát
có trọng lượng bằng một thì chúng được coi là bằng nhau.  Điều này đặc biệt
hữu ích trong các hệ thống không đồng nhất trong đó hai thiết bị làm mát có thể thực hiện
cùng một loại tính toán nhưng có hiệu quả khác nhau.  Ví dụ,
một hệ thống có hai loại bộ xử lý khác nhau.

Nếu vùng nhiệt được đăng ký bằng cách sử dụng
ZZ0000ZZ (tức là mã nền tảng), sau đó cân
được thông qua như một phần của ZZ0001ZZ của vùng nhiệt.
Nếu nền tảng được đăng ký bằng cây thiết bị thì chúng sẽ được chuyển qua
làm thuộc tính ZZ0002ZZ của mỗi bản đồ trong nút ZZ0003ZZ.

Hạn chế của bộ điều tốc phân bổ quyền lực
===========================================

Bộ điều khiển PID của bộ điều tốc cấp phát điện hoạt động tốt nhất nếu có
đánh dấu định kỳ.  Nếu bạn có một tài xế gọi
ZZ0000ZZ (hoặc bất cứ thứ gì gọi là
chức năng ZZ0001ZZ của bộ điều tốc) lặp đi lặp lại, phản hồi của bộ điều tốc
sẽ không được tốt lắm.  Lưu ý rằng điều này không đặc biệt với điều này
thống đốc, từng bước cũng sẽ hoạt động sai nếu bạn gọi ga của nó()
nhanh hơn tích tắc khung nhiệt thông thường (do bị gián đoạn trong
ví dụ) vì nó sẽ phản ứng thái quá.

Yêu cầu về mô hình năng lượng
=========================

Một điều quan trọng khác là thang đo nhất quán của các giá trị công suất
được cung cấp bởi các thiết bị làm mát. Tất cả các thiết bị làm mát trong một
vùng nhiệt phải có giá trị công suất được báo cáo tính bằng mili-Watt
hoặc được chia tỷ lệ theo cùng một 'tỷ lệ trừu tượng'.
