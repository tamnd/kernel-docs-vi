.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/power/opp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==============================================
Thư viện điểm hiệu suất hoạt động (OPP)
==========================================

(C) 2009-2010 Nishanth Menon <nm@ti.com>, Tập đoàn Texas Instruments

.. Contents

  1. Introduction
  2. Initial OPP List Registration
  3. OPP Search Functions
  4. OPP Availability Control Functions
  5. OPP Data Retrieval Functions
  6. Data Structures

1. Giới thiệu
===============

1.1 Điểm hiệu suất hoạt động (OPP) là gì?
-------------------------------------------------

Các SoC phức tạp ngày nay bao gồm nhiều mô-đun phụ hoạt động cùng nhau.
Trong một hệ điều hành thực thi các trường hợp sử dụng khác nhau, không phải tất cả các mô-đun trong SoC đều
cần phải hoạt động ở tần suất hoạt động cao nhất mọi lúc. Đến
tạo điều kiện thuận lợi cho việc này, các mô-đun phụ trong SoC được nhóm thành các miền, cho phép một số
các miền chạy ở điện áp và tần số thấp hơn trong khi các miền khác chạy ở
cặp điện áp/tần số cao hơn.

Tập hợp các bộ rời rạc bao gồm các cặp tần số và điện áp
thiết bị sẽ hỗ trợ cho mỗi miền được gọi là Điểm Hiệu suất Hoạt động hoặc
OPP.

Như một ví dụ:

Chúng ta hãy xem xét một thiết bị MPU hỗ trợ các tính năng sau:
{300 MHz ở điện áp tối thiểu 1V}, {800 MHz ở điện áp tối thiểu 1,2V},
{1GHz ở điện áp tối thiểu 1,3V}

Chúng ta có thể biểu diễn chúng dưới dạng ba OPP dưới dạng các bộ dữ liệu {Hz, uV} sau:

- {300000000, 1000000}
- {800000000, 1200000}
- {1000000000, 1300000}

1.2 Thư viện điểm hiệu suất hoạt động
----------------------------------------

Thư viện OPP cung cấp một tập hợp các hàm trợ giúp để sắp xếp và truy vấn OPP
thông tin. Thư viện nằm trong thư mục driver/opp/ và tiêu đề
nằm ở include/linux/pm_opp.h. Thư viện OPP có thể được kích hoạt bằng cách kích hoạt
CONFIG_PM_OPP từ menu cấu hình menu quản lý nguồn. Một số SoC nhất định như Texas
Khung OMAP của thiết bị cho phép tùy chọn khởi động ở một OPP nhất định mà không cần
đang cần cpufreq.

Cách sử dụng điển hình của thư viện OPP như sau::

(người dùng) -> đăng ký một bộ OPP mặc định -> (thư viện)
 Khung SoC -> sửa đổi trong các trường hợp bắt buộc một số OPP nhất định -> Lớp OPP
		-> truy vấn để tìm kiếm/truy xuất thông tin ->

Lớp OPP mong muốn mỗi miền được biểu thị bằng một con trỏ thiết bị duy nhất. SoC
framework đăng ký một tập hợp OPP ban đầu cho mỗi thiết bị với lớp OPP. Cái này
danh sách dự kiến ​​sẽ là một con số nhỏ tối ưu, thường là khoảng 5 trên mỗi thiết bị.
Danh sách ban đầu này chứa một tập hợp các OPP mà khung dự kiến sẽ an toàn
được bật theo mặc định trong hệ thống.

Lưu ý về tính khả dụng của OPP
^^^^^^^^^^^^^^^^^^^^^^^^

Khi hệ thống tiếp tục hoạt động, hệ thống SoC có thể chọn đảm bảo một số
OPP có sẵn hoặc không có sẵn trên mỗi thiết bị dựa trên nhiều yếu tố bên ngoài khác nhau
các yếu tố. Ví dụ sử dụng: Quản lý nhiệt hoặc các tình huống đặc biệt khác khi
Khung SoC có thể chọn tắt OPP tần số cao hơn để tiếp tục một cách an toàn
hoạt động cho đến khi OPP có thể được kích hoạt lại nếu có thể.

Thư viện OPP tạo điều kiện thuận lợi cho khái niệm này được triển khai. Sau đây
các chức năng vận hành chỉ hoạt động trên các opps có sẵn:
dev_pm_opp_find_freq_{trần nhà, tầng}, dev_pm_opp_get_điện áp, dev_pm_opp_get_freq,
dev_pm_opp_get_opp_count.

dev_pm_opp_find_freq_exact được sử dụng để tìm con trỏ opp
sau đó có thể được sử dụng cho các hàm dev_pm_opp_enable/disable để tạo một
opp có sẵn theo yêu cầu.

WARNING: Người dùng thư viện OPP nên làm mới số lượng khả dụng của họ bằng cách sử dụng
get_opp_count nếu các hàm dev_pm_opp_enable/disable được gọi cho một
thiết bị, cơ chế chính xác để kích hoạt những thiết bị này hoặc cơ chế thông báo
đối với các hệ thống con phụ thuộc khác như cpufreq được tùy ý quyết định
khung cụ thể của SoC sử dụng thư viện OPP. Nhu cầu chăm sóc tương tự
cần lưu ý làm mới bảng cpufreq trong trường hợp thực hiện các thao tác này.

2. Đăng ký danh sách OPP ban đầu
================================
Việc triển khai SoC gọi hàm dev_pm_opp_add lặp đi lặp lại để thêm OPP cho mỗi
thiết bị. Dự kiến SoC framework sẽ đăng ký các mục OPP
tối ưu- các số điển hình nằm trong phạm vi nhỏ hơn 5. Danh sách được tạo bởi
việc đăng ký OPP được duy trì bởi thư viện OPP trên toàn thiết bị
hoạt động. Khung SoC sau đó có thể kiểm soát tính khả dụng của
OPP một cách linh hoạt bằng cách sử dụng các chức năng dev_pm_opp_enable/disable.

dev_pm_opp_add
	Thêm OPP mới cho một miền cụ thể được biểu thị bằng con trỏ thiết bị.
	OPP được xác định bằng tần số và điện áp. Sau khi được thêm vào, OPP
	được giả định là có sẵn và việc kiểm soát tính sẵn có của nó có thể được thực hiện
	với các hàm dev_pm_opp_enable/disable. Thư viện OPP
	lưu trữ nội bộ và quản lý thông tin này trong cấu trúc dev_pm_opp.
	Chức năng này có thể được SoC framework sử dụng để xác định danh sách tối ưu
	theo nhu cầu của môi trường sử dụng SoC.

WARNING:
		Không sử dụng chức năng này trong bối cảnh ngắt.

Ví dụ::

soc_pm_init()
	 {
		/*Làm những việc*/
		r = dev_pm_opp_add(mpu_dev, 1000000, 900000);
		nếu (! r) {
			pr_err("%s: không thể đăng ký mpu opp(%d)\n", r);
			đi đến no_cpufreq;
		}
		/* Thực hiện các thao tác cpufreq */
	 no_cpufreq:
		/*Làm những việc còn lại*/
	 }

3. Chức năng tìm kiếm OPP
=======================
Khung cấp cao như cpufreq hoạt động trên tần số. Để lập bản đồ
tần số trở lại OPP tương ứng, thư viện OPP cung cấp các chức năng tiện dụng
để tìm kiếm danh sách OPP mà thư viện OPP quản lý nội bộ. Những tìm kiếm này
các hàm trả về con trỏ phù hợp biểu thị opp nếu kết quả khớp
tìm thấy, nếu không sẽ trả về lỗi. Những lỗi này dự kiến sẽ được xử lý theo tiêu chuẩn
kiểm tra lỗi chẳng hạn như IS_ERR() và các hành động thích hợp được thực hiện bởi người gọi.

Người gọi các hàm này sẽ gọi dev_pm_opp_put() sau khi họ đã sử dụng
OPP. Nếu không, bộ nhớ dành cho OPP sẽ không bao giờ được giải phóng và dẫn đến
memleak.

dev_pm_opp_find_freq_exact
	Tìm kiếm OPP dựa trên tần số ZZ0000ZZ và
	sự sẵn có. Chức năng này đặc biệt hữu ích để kích hoạt OPP
	không có sẵn theo mặc định.
	Ví dụ: Trong trường hợp khung SoC phát hiện tình huống trong đó
	tần số cao hơn có thể được cung cấp, nó có thể sử dụng chức năng này để
	tìm OPP trước khi gọi dev_pm_opp_enable để thực sự thực hiện
	nó có sẵn::

opp = dev_pm_opp_find_freq_exact(dev, 1000000000, sai);
	 dev_pm_opp_put(opp);
	 /* không thao tác trên con trỏ.. chỉ cần kiểm tra độ tỉnh táo.. */
	 nếu (IS_ERR(opp)) {
		pr_err("tần số không bị tắt!\n");
		/* kích hoạt các hành động thích hợp.. */
	 } khác {
		dev_pm_opp_enable(dev,1000000000);
	 }

NOTE:
	  Đây là chức năng tìm kiếm duy nhất hoạt động trên các OPP được
	  không có sẵn.

dev_pm_opp_find_freq_floor
	Tìm kiếm OPP có sẵn là ZZ0000ZZ
	tần số được cung cấp. Chức năng này rất hữu ích khi tìm kiếm ít hơn
	khớp HOẶC thao tác trên thông tin OPP theo thứ tự giảm dần
	tần số.
	Ví dụ: Để tìm opp cao nhất cho một thiết bị::

tần số = ULONG_MAX;
	 opp = dev_pm_opp_find_freq_floor(dev, &freq);
	 dev_pm_opp_put(opp);

dev_pm_opp_find_freq_ceil
	Tìm kiếm OPP có sẵn là ZZ0000ZZ
	tần số được cung cấp. Chức năng này rất hữu ích khi tìm kiếm một
	phù hợp cao hơn HOẶC hoạt động trên thông tin OPP theo thứ tự tăng dần
	tần số.
	Ví dụ 1: Tìm opp thấp nhất cho một thiết bị::

tần số = 0;
	 opp = dev_pm_opp_find_freq_ceil(dev, &freq);
	 dev_pm_opp_put(opp);

Ví dụ 2: Cách triển khai SoC cpufreq_driver->target::

soc_cpufreq_target(..)
	 {
		/* Thực hiện những công việc như kiểm tra chính sách, v.v. */
		/* Tìm tần số phù hợp nhất cho yêu cầu */
		opp = dev_pm_opp_find_freq_ceil(dev, &freq);
		dev_pm_opp_put(opp);
		nếu (!IS_ERR(opp))
			soc_switch_to_freq_điện áp (tần số);
		khác
			/* làm gì đó khi không thể đáp ứng được yêu cầu */
		/*làm việc khác*/
	 }

4. Chức năng kiểm soát tính khả dụng của OPP
=====================================
Danh sách OPP mặc định được đăng ký với thư viện OPP có thể không đáp ứng được tất cả các nhu cầu có thể
tình huống. Thư viện OPP cung cấp một tập hợp các hàm để sửa đổi
sự sẵn có của OPP trong danh sách OPP. Điều này cho phép các khung SoC có
kiểm soát động chi tiết về bộ OPP nào có sẵn để vận hành.
Các chức năng này nhằm mục đích ZZ0000ZZ loại bỏ OPP trong các điều kiện như
như những cân nhắc về nhiệt (ví dụ: không sử dụng OPPx cho đến khi nhiệt độ giảm xuống).

WARNING:
	Không sử dụng các hàm này trong ngữ cảnh ngắt.

dev_pm_opp_enable
	Cung cấp OPP để hoạt động.
	Ví dụ: Giả sử rằng OPP 1GHz chỉ được cung cấp nếu
	Nhiệt độ SoC thấp hơn một ngưỡng nhất định. Khung SoC
	việc triển khai có thể chọn thực hiện một số việc như sau ::

nếu (cur_temp < temp_low_thresh) {
		/* Kích hoạt 1GHz nếu nó bị tắt */
		opp = dev_pm_opp_find_freq_exact(dev, 1000000000, sai);
		dev_pm_opp_put(opp);
		/*chỉ kiểm tra lỗi*/
		nếu (!IS_ERR(opp))
			ret = dev_pm_opp_enable(dev, 1000000000);
		khác
			hãy thử_something_else;
	 }

dev_pm_opp_disable
	Làm cho OPP không thể hoạt động được
	Ví dụ: Giả sử rằng OPP 1GHz sẽ bị tắt nếu nhiệt độ
	vượt quá một giá trị ngưỡng. Việc triển khai khung SoC có thể
	chọn làm điều gì đó như sau::

nếu (cur_temp > temp_high_thresh) {
		/* Tắt 1GHz nếu nó được bật */
		opp = dev_pm_opp_find_freq_exact(dev, 1000000000, true);
		dev_pm_opp_put(opp);
		/*chỉ kiểm tra lỗi*/
		nếu (!IS_ERR(opp))
			ret = dev_pm_opp_disable(dev, 1000000000);
		khác
			hãy thử_something_else;
	 }

5. Chức năng truy xuất dữ liệu OPP
===============================
Vì thư viện OPP tóm tắt thông tin OPP nên một tập hợp các hàm để kéo
thông tin từ cấu trúc dev_pm_opp là cần thiết. Khi con trỏ OPP được
được truy xuất bằng các chức năng tìm kiếm, SoC có thể sử dụng các chức năng sau
framework để lấy thông tin được biểu thị bên trong lớp OPP.

dev_pm_opp_get_điện áp
	Lấy điện áp được biểu thị bằng con trỏ opp.
	Ví dụ: Khi chuyển đổi cpufreq sang tần số khác, SoC
	framework yêu cầu đặt điện áp được đại diện bởi OPP bằng cách sử dụng
	khung điều chỉnh cho chip Quản lý nguồn cung cấp
	điện áp::

soc_switch_to_freq_điện áp (tần số)
	 {
		/*làm việc gì đó*/
		opp = dev_pm_opp_find_freq_ceil(dev, &freq);
		v = dev_pm_opp_get_điện áp(opp);
		dev_pm_opp_put(opp);
		nếu (v)
			điều chỉnh_set_điện áp (.., v);
		/*làm việc khác*/
	 }

dev_pm_opp_get_freq
	Truy xuất tần số được biểu thị bằng con trỏ opp.
	Ví dụ: Giả sử khung SoC sử dụng một vài hàm trợ giúp
	chúng ta có thể chuyển con trỏ opp thay vì thực hiện các tham số bổ sung cho
	xử lý yên lặng một chút thông số dữ liệu::

soc_cpufreq_target(..)
	 {
		/* làm việc gì đó.. */
		 max_freq = ULONG_MAX;
		 max_opp = dev_pm_opp_find_freq_floor(dev,&max_freq);
		 được yêu cầu_opp = dev_pm_opp_find_freq_ceil(dev,&freq);
		 if (!IS_ERR(max_opp) && !IS_ERR(requested_opp))
			r = soc_test_validity(max_opp, request_opp);
		 dev_pm_opp_put(max_opp);
		 dev_pm_opp_put(requested_opp);
		/*làm việc khác*/
	 }
	 soc_test_validity(..)
	 {
		 if(dev_pm_opp_get_điện áp(max_opp) < dev_pm_opp_get_điện áp(requested_opp))
			 trả về -EINVAL;
		 if(dev_pm_opp_get_freq(max_opp) < dev_pm_opp_get_freq(requested_opp))
			 trả về -EINVAL;
		/* làm việc gì đó.. */
	 }

dev_pm_opp_get_opp_count
	Truy xuất số opps có sẵn cho một thiết bị
	Ví dụ: Giả sử bộ đồng xử lý trong SoC cần biết khả năng
	tần số trong một bảng, bộ xử lý chính có thể thông báo như sau::

soc_notify_coproc_available_frequency()
	 {
		/*Làm những việc*/
		num_available = dev_pm_opp_get_opp_count(dev);
		tốc độ = kcalloc(num_available, sizeof(u32), GFP_KERNEL);
		/*điền vào bảng theo thứ tự tăng dần */
		tần số = 0;
		while (!IS_ERR(opp = dev_pm_opp_find_freq_ceil(dev, &freq))) {
			tốc độ[i] = tần số;
			tần số++;
			tôi++;
			dev_pm_opp_put(opp);
		}

soc_notify_coproc(AVAILABLE_FREQ, tốc độ, num_available);
		/*Làm việc khác*/
	 }

6. Cấu trúc dữ liệu
==================
Thông thường, một SoC chứa nhiều miền điện áp có thể thay đổi. Mỗi
miền được đại diện bởi một con trỏ thiết bị. Mối quan hệ với OPP có thể là
được thể hiện như sau::

SoC
   |- thiết bị 1
   ZZ0000ZZ- opp 1 (sẵn có, tần số, điện áp)
   ZZ0001ZZ-opp 2 ..
   ...	...
|	`- à ừ..
   |- thiết bị 2
   ...
`- thiết bị m

Thư viện OPP duy trì một danh sách nội bộ mà khung SoC điền vào và
được truy cập bởi các chức năng khác nhau như được mô tả ở trên. Tuy nhiên, các cấu trúc
đại diện cho các OPP và miền thực tế là nội bộ của chính thư viện OPP
để cho phép sự trừu tượng phù hợp có thể tái sử dụng trên các hệ thống.

cấu trúc dev_pm_opp
	Cấu trúc dữ liệu nội bộ của thư viện OPP được sử dụng để
	đại diện cho một OPP. Ngoài tần số, điện áp, tính khả dụng
	thông tin, nó cũng chứa thông tin ghi sổ nội bộ cần thiết
	để thư viện OPP hoạt động.  Con trỏ tới cấu trúc này là
	được cung cấp lại cho người dùng như khung SoC để sử dụng như một
	mã định danh cho OPP trong các tương tác với lớp OPP.

WARNING:
	  Con trỏ struct dev_pm_opp không được phân tích cú pháp hoặc sửa đổi bởi
	  người dùng. Giá trị mặc định của một phiên bản được điền bởi
	  dev_pm_opp_add, nhưng tính khả dụng của OPP có thể được sửa đổi
	  bởi các chức năng dev_pm_opp_enable/disable.

thiết bị cấu trúc
	Điều này được sử dụng để xác định một miền cho lớp OPP. các
	bản chất của thiết bị và việc thực hiện nó được giao cho người sử dụng
	Thư viện OPP như khung SoC.

Nhìn chung, theo cách nhìn đơn giản, các hoạt động của cấu trúc dữ liệu được biểu diễn dưới dạng
sau đây::

Khởi tạo/sửa đổi:
              +------+ /- dev_pm_opp_enable
  dev_pm_opp_add --> ZZ0000ZZ <-------
    |         +------+ \- dev_pm_opp_disable
    \-------> thông tin miền_(thiết bị)

Chức năng tìm kiếm:
               /-- dev_pm_opp_find_freq_ceil ---\ +------+
  domain_info<---- dev_pm_opp_find_freq_exact -----> ZZ0000ZZ
               \-- dev_pm_opp_find_freq_floor ---/ +------+

Chức năng truy xuất:
  +------+ /- dev_pm_opp_get_volt
  ZZ0000ZZ <---
  +------+ \- dev_pm_opp_get_freq

domain_info <- dev_pm_opp_get_opp_count
