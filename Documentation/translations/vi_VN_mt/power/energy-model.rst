.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/power/energy-model.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
Mô hình năng lượng của thiết bị
===============================

1. Tổng quan
-----------

Khung Mô hình Năng lượng (EM) đóng vai trò là giao diện giữa những người lái xe biết
năng lượng tiêu thụ của các thiết bị ở các mức hiệu suất khác nhau và hạt nhân
các hệ thống con sẵn sàng sử dụng thông tin đó để đưa ra quyết định nhận thức về năng lượng.

Nguồn thông tin về mức điện năng tiêu thụ của các thiết bị có thể rất khác nhau
từ nền tảng này sang nền tảng khác. Những chi phí năng lượng này có thể được ước tính bằng cách sử dụng
dữ liệu devicetree trong một số trường hợp. Ở những nơi khác, phần sụn sẽ biết rõ hơn.
Ngoài ra, không gian người dùng có thể được định vị tốt nhất. Để tránh
có mỗi và mọi hệ thống con khách hàng triển khai lại hỗ trợ cho mỗi và mọi
nguồn thông tin có thể có của riêng nó, khung EM can thiệp như một
lớp trừu tượng chuẩn hóa định dạng của bảng chi phí điện năng trong
kernel, do đó cho phép tránh được công việc dư thừa.

Các giá trị công suất có thể được biểu thị bằng micro-Watt hoặc theo 'thang trừu tượng'.
Nhiều hệ thống con có thể sử dụng EM và tùy thuộc vào nhà tích hợp hệ thống
kiểm tra xem các yêu cầu đối với các loại thang đo giá trị công suất có được đáp ứng hay không. Một ví dụ
có thể được tìm thấy trong tài liệu Lập lịch nhận biết năng lượng
Tài liệu/lịch trình/sched-energy.rst. Đối với một số hệ thống con như nhiệt hoặc
các giá trị công suất của powercap được biểu thị theo 'thang trừu tượng' có thể gây ra sự cố.
Các hệ thống con này quan tâm nhiều hơn đến việc ước tính công suất sử dụng trong quá khứ,
do đó có thể cần đến micro-Watt thực sự. Một ví dụ về những yêu cầu này có thể
được tìm thấy trong Phân bổ năng lượng thông minh ở
Tài liệu/driver-api/thermal/power_allocator.rst.
Các hệ thống con hạt nhân có thể thực hiện phát hiện tự động để kiểm tra xem EM có
thiết bị đã đăng ký có thang đo không nhất quán (dựa trên cờ nội bộ EM).
Một điều quan trọng cần ghi nhớ là khi các giá trị công suất được biểu thị bằng
sẽ không thể thực hiện được một 'thang đo trừu tượng' lấy được năng lượng thực ở mức micro-Joules.

Hình bên dưới mô tả một ví dụ về trình điều khiển (ở đây dành riêng cho Arm, nhưng
cách tiếp cận có thể áp dụng cho bất kỳ kiến trúc nào) cung cấp chi phí điện năng cho EM
framework và các khách hàng quan tâm đọc dữ liệu từ nó::

+--------------+ +---------+ +---------------+
       ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ
       +--------------+ +---------+ +---------------+
               ZZ0003ZZ em_cpu_energy() |
               ZZ0004ZZ em_cpu_get() |
               +----------+ |         +----------+
                         ZZ0005ZZ |
                         v v v
                        +----------------------+
                        ZZ0006ZZ
                        ZZ0007ZZ
                        +----------------------+
                           ^ ^ ^
                           ZZ0008ZZ | em_dev_register_perf_domain()
                +----------+ |       +----------+
                ZZ0009ZZ |
        +--------------+ +---------------+ +--------------+
        ZZ0010ZZ ZZ0011ZZ ZZ0012ZZ
        +--------------+ +---------------+ +--------------+
                ^ ^ ^
                ZZ0013ZZ |
        +--------------+ +--------------+ +--------------+
        ZZ0014ZZ ZZ0015ZZ ZZ0016ZZ
        +--------------+ +--------------+ +--------------+

Trong trường hợp thiết bị CPU, khung EM quản lý các bảng chi phí điện năng cho mỗi thiết bị.
'miền hiệu suất' trong hệ thống. Miền hiệu suất là một nhóm CPU
hiệu suất của chúng được chia tỷ lệ với nhau. Các miền hiệu suất thường có
Ánh xạ 1-1 với chính sách CPUFreq. Tất cả các CPU trong miền hiệu suất đều
bắt buộc phải có cùng một vi kiến trúc. CPU có hiệu năng khác nhau
các miền có thể có các kiến trúc vi mô khác nhau.

Để phản ánh tốt hơn sự thay đổi công suất do tĩnh điện (rò rỉ), EM
hỗ trợ sửa đổi thời gian chạy của các giá trị nguồn. Cơ chế dựa vào
RCU để giải phóng bộ nhớ bảng EM perf_state có thể sửa đổi. Người dùng của nó, nhiệm vụ
bộ lập lịch, cũng sử dụng RCU để truy cập bộ nhớ này. Khung EM cung cấp
API để phân bổ/giải phóng bộ nhớ mới cho bảng EM có thể sửa đổi.
Bộ nhớ cũ được giải phóng tự động bằng cơ chế gọi lại RCU khi có
không còn là chủ sở hữu của phiên bản bảng thời gian chạy EM đã cho. Điều này được theo dõi
sử dụng cơ chế kref. Trình điều khiển thiết bị đã cung cấp EM mới khi chạy,
nên gọi EM API để giải phóng an toàn khi không cần dùng nữa. EM
framework sẽ xử lý việc dọn dẹp khi có thể.

Mã hạt nhân muốn sửa đổi các giá trị EM được bảo vệ khỏi các sự cố đồng thời.
truy cập bằng mutex. Vì vậy, mã trình điều khiển thiết bị phải chạy ở chế độ ngủ
context khi nó cố gắng sửa đổi EM.

Với EM có thể sửa đổi thời gian chạy, chúng tôi chuyển từ 'đơn lẻ và trong toàn bộ
thiết kế EM' (thuộc tính hệ thống) tĩnh thời gian chạy thành một 'EM đơn có thể
đã thay đổi trong thời gian chạy, ví dụ: vào khối lượng công việc' (hệ thống và khối lượng công việc
tài sản) thiết kế.

Cũng có thể sửa đổi các giá trị hiệu suất CPU cho từng EM
trạng thái hiệu suất. Do đó, hồ sơ sức mạnh và hiệu suất đầy đủ (mà
là một đường cong hàm mũ) có thể được thay đổi theo ví dụ: đến khối lượng công việc
hoặc thuộc tính hệ thống.


2. API cốt lõi
------------

2.1 Tùy chọn cấu hình
^^^^^^^^^^^^^^^^^^

CONFIG_ENERGY_MODEL phải được kích hoạt để sử dụng khung EM.


2.2 Đăng ký miền hiệu suất
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Đăng ký EM 'cao cấp'
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

EM 'cao cấp' có tên như vậy do người lái xe được phép
để cung cấp một mô hình năng lượng chính xác hơn. Nó không giới hạn ở một số phép toán được thực hiện
công thức trong khung (giống như trong trường hợp EM 'đơn giản'). Nó có thể phản ánh tốt hơn
các phép đo công suất thực được thực hiện cho từng trạng thái hiệu suất. Như vậy, điều này
phương pháp đăng ký nên được ưu tiên trong trường hợp xem xét nguồn điện tĩnh EM
(rò rỉ) là quan trọng.

Trình điều khiển dự kiến ​​sẽ đăng ký miền hiệu suất vào khung EM bằng cách
gọi API sau::

int em_dev_register_perf_domain(struct device *dev, unsigned int nr_states,
		struct em_data_callback *cb, cpumask_t *cpus, bool microwatt);

Trình điều khiển phải cung cấp chức năng gọi lại trả về các bộ dữ liệu <tần số, nguồn>
cho mỗi trạng thái hiệu suất. Chức năng gọi lại do trình điều khiển cung cấp là miễn phí
để tìm nạp dữ liệu từ bất kỳ vị trí có liên quan nào (DT, chương trình cơ sở, ...) và bằng bất kỳ cách nào
được coi là cần thiết. Chỉ dành cho thiết bị CPU, trình điều khiển phải chỉ định CPU của
miền hiệu suất sử dụng cpumask. Đối với các thiết bị khác ngoài CPU, cuối cùng
đối số phải được đặt thành NULL.
Đối số cuối cùng 'microwatts' rất quan trọng để đặt giá trị chính xác. hạt nhân
các hệ thống con sử dụng EM có thể dựa vào cờ này để kiểm tra xem tất cả các thiết bị EM có sử dụng
cùng một quy mô. Nếu có các thang đo khác nhau, các hệ thống con này có thể quyết định
để trả về cảnh báo/lỗi, ngừng hoạt động hoặc hoảng loạn.
Xem Phần 3. để biết ví dụ về trình điều khiển thực hiện điều này
gọi lại hoặc Phần 2.4 để biết thêm tài liệu về API này

Đăng ký EM bằng DT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

EM cũng có thể được đăng ký bằng khung OPP và thông tin trong DT
"điểm điều hành-v2". Mỗi mục nhập OPP trong DT có thể được mở rộng bằng một thuộc tính
"opp-microwatt" chứa giá trị năng lượng micro-Watt. Thuộc tính DT OPP này
cho phép nền tảng đăng ký các giá trị công suất EM phản ánh tổng công suất
(tĩnh + động). Những giá trị công suất này có thể đến trực tiếp từ
thí nghiệm và đo lường.

Đăng ký EM 'nhân tạo'
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Có một tùy chọn để cung cấp một cuộc gọi lại tùy chỉnh cho các trình điều khiển bị thiếu thông tin chi tiết
kiến thức về giá trị công suất cho từng trạng thái hiệu suất. Cuộc gọi lại
.get_cost() là tùy chọn và cung cấp các giá trị 'chi phí' được EAS sử dụng.
Điều này hữu ích cho các nền tảng chỉ cung cấp thông tin tương đối
hiệu quả giữa các loại CPU, trong đó người ta có thể sử dụng thông tin để
tạo ra một mô hình quyền lực trừu tượng. Nhưng ngay cả một mô hình quyền lực trừu tượng cũng có thể
đôi khi khó phù hợp do các hạn chế về kích thước giá trị nguồn đầu vào.
.get_cost() cho phép cung cấp các giá trị 'chi phí' phản ánh
hiệu quả của các CPU. Điều này sẽ cho phép cung cấp thông tin EAS
có mối quan hệ khác với những gì bị ép buộc bởi nội bộ EM
công thức tính giá trị 'chi phí'. Để đăng ký EM cho nền tảng đó,
trình điều khiển phải đặt cờ 'microwatts' thành 0, cung cấp lệnh gọi lại .get_power()
và cung cấp lệnh gọi lại .get_cost(). Khung EM sẽ xử lý nền tảng như vậy
đúng cách trong quá trình đăng ký. Cờ EM_PERF_DOMAIN_ARTIFICIAL được đặt cho những trường hợp như vậy
nền tảng. Cần đặc biệt chú ý đến các framework khác đang sử dụng EM
để kiểm tra và xử lý cờ này đúng cách.

Đăng ký EM 'đơn giản'
~~~~~~~~~~~~~~~~~~~~~~~~~~~

EM 'đơn giản' được đăng ký bằng chức năng trợ giúp khung
cpufreq_register_em_with_opp(). Nó thực hiện một mô hình năng lượng được gắn với một
công thức toán::

Công suất = C * V^2 * f

EM được đăng ký bằng phương pháp này có thể không phản ánh chính xác
vật lý của một thiết bị thực, ví dụ: khi tĩnh điện (rò rỉ) là quan trọng.


2.3 Truy cập các miền hiệu suất
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Có hai hàm API cung cấp quyền truy cập vào mô hình năng lượng:
em_cpu_get() lấy id CPU làm đối số và em_pd_get() với thiết bị
con trỏ làm đối số. Nó phụ thuộc vào hệ thống con mà nó có giao diện nào
sẽ sử dụng, nhưng trong trường hợp thiết bị CPU, cả hai chức năng đều trả về như nhau
miền hiệu suất.

Các hệ thống con quan tâm đến mô hình năng lượng của CPU có thể truy xuất nó bằng cách sử dụng
em_cpu_get() API. Các bảng mô hình năng lượng được phân bổ một lần khi tạo
các miền hiệu suất và được giữ nguyên trong bộ nhớ.

Năng lượng tiêu thụ của một miền hiệu suất có thể được ước tính bằng cách sử dụng
em_cpu_energy() API. Việc ước tính được thực hiện với giả định rằng schedutil
Bộ điều chỉnh CPUfreq được sử dụng trong trường hợp thiết bị CPU. Hiện nay cách tính này
không được cung cấp cho các loại thiết bị khác.

Bạn có thể tìm thêm thông tin chi tiết về các API trên trong ZZ0000ZZ
hoặc trong Phần 2.5


2.4 Sửa đổi thời gian chạy
^^^^^^^^^^^^^^^^^^^^^^^^^

Trình điều khiển sẵn sàng cập nhật EM khi chạy nên sử dụng phần mềm chuyên dụng sau
chức năng phân bổ một phiên bản mới của EM đã sửa đổi. API được liệt kê
dưới đây::

cấu trúc em_perf_table __rcu *em_table_alloc(struct em_perf_domain *pd);

Điều này cho phép phân bổ cấu trúc chứa bảng EM mới với
cũng cần có RCU và kref trong khung EM. 'struct em_perf_table'
chứa mảng 'struct em_perf_state state[]' là danh sách hiệu suất
trạng thái theo thứ tự tăng dần. Danh sách đó phải được trình điều khiển thiết bị điền
muốn cập nhật EM. Danh sách tần số có thể được lấy từ
EM hiện có (được tạo trong khi khởi động). Nội dung trong 'struct em_perf_state'
cũng phải được người lái xe điền vào.

Đây là API thực hiện cập nhật EM, sử dụng trao đổi con trỏ RCU ::

int em_dev_update_perf_domain(thiết bị cấu trúc *dev,
			struct em_perf_table __rcu *new_table);

Trình điều khiển phải cung cấp một con trỏ tới EM mới được phân bổ và khởi tạo
'cấu trúc em_perf_table'. EM mới đó sẽ được sử dụng an toàn trong khuôn khổ EM
và sẽ hiển thị với các hệ thống con khác trong kernel (nhiệt, powercap).
Mục tiêu thiết kế chính của API này là nhanh và tránh phải tính toán thêm
hoặc phân bổ bộ nhớ khi chạy. Khi EM được tính toán trước có sẵn trong
trình điều khiển thiết bị, thì có thể chỉ cần sử dụng lại chúng với chi phí thấp
chi phí hiệu suất.

Để giải phóng EM, do trình điều khiển cung cấp trước đó (ví dụ: khi mô-đun
chưa được tải), cần phải gọi API::

void em_table_free(struct em_perf_table __rcu *table);

Nó sẽ cho phép EM framework xóa bộ nhớ một cách an toàn khi có
không có hệ thống con nào khác sử dụng nó, ví dụ: EAS.

Để sử dụng các giá trị công suất trong các hệ thống con khác (như nhiệt, powercap), cần có
cần gọi API để bảo vệ đầu đọc và cung cấp tính nhất quán của EM
dữ liệu bảng::

cấu trúc em_perf_state *em_perf_state_from_pd(struct em_perf_domain *pd);

Nó trả về con trỏ 'struct em_perf_state' là một mảng hiệu suất
trạng thái theo thứ tự tăng dần.
Chức năng này phải được gọi trong phần khóa đọc RCU (sau
rcu_read_lock()). Khi bảng EM không còn cần thiết nữa thì cần phải
gọi rcu_read_unlock(). Bằng cách này EM sử dụng phần đọc RCU một cách an toàn
và bảo vệ người dùng. Nó cũng cho phép khung EM quản lý bộ nhớ
và giải phóng nó. Bạn có thể tìm thấy thêm chi tiết về cách sử dụng nó trong Phần 3.2 trong phần
trình điều khiển ví dụ.

Có API dành riêng cho trình điều khiển thiết bị để tính toán em_perf_state::cost
giá trị::

int em_dev_compute_costs(thiết bị cấu trúc *dev, struct em_perf_state *table,
                           int nr_state);

Các giá trị 'chi phí' này từ EM được sử dụng trong EAS. Bảng EM mới cần được thông qua
cùng với số lượng mục và con trỏ thiết bị. Khi tính toán
trong số các giá trị chi phí được thực hiện đúng thì giá trị trả về từ hàm là 0.
Chức năng này đảm nhiệm việc thiết lập đúng mức độ kém hiệu quả cho từng hiệu suất
nhà nước là tốt. Nó cập nhật em_perf_state::flags tương ứng.
Sau đó, EM mới được chuẩn bị sẵn như vậy có thể được chuyển tới em_dev_update_perf_domain()
chức năng sẽ cho phép sử dụng nó.

Bạn có thể tìm thêm thông tin chi tiết về các API trên trong ZZ0000ZZ
hoặc trong Phần 3.2 với mã ví dụ hiển thị cách triển khai đơn giản của
cơ chế cập nhật trong trình điều khiển thiết bị.


2.5 Mô tả chi tiết về chiếc API này
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. kernel-doc:: include/linux/energy_model.h
   :internal:

.. kernel-doc:: kernel/power/energy_model.c
   :export:


3. Ví dụ
-----------

3.1 Ví dụ driver có đăng ký EM
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Khung CPUFreq hỗ trợ gọi lại chuyên dụng để đăng ký
EM cho một đối tượng 'chính sách' CPU(s) nhất định: cpufreq_driver::register_em().
Cuộc gọi lại đó phải được triển khai đúng cách cho một trình điều khiển nhất định,
bởi vì khung sẽ gọi nó vào đúng thời điểm trong quá trình thiết lập.
Phần này cung cấp một ví dụ đơn giản về trình điều khiển CPUFreq đăng ký một
miền hiệu suất trong khung Mô hình Năng lượng bằng cách sử dụng 'foo' (giả)
giao thức. Trình điều khiển thực hiện hàm est_power() để cung cấp cho
Khung EM::

-> trình điều khiển/cpufreq/foo_cpufreq.c

01 int tĩnh est_power(thiết bị cấu trúc *dev, unsigned long *mW,
  02 dài không dấu *KHz)
  03 {
  04 tần số dài, nguồn;
  05
  06 /* Sử dụng giao thức 'foo' để hạn chế tần số */
  07 tần số = foo_get_freq_ceil(dev, *KHz);
  08 nếu (tần số < 0)
  tần số quay về 09;
  10
  11 /* Ước tính chi phí điện năng cho nhà phát triển ở tần số phù hợp. */
  12 công suất = foo_estimate_power(dev, freq);
  13 nếu (công suất < 0)
  14 trở về điện;
  15
  16 /* Trả về giá trị cho EM framework */
  17 *mW = công suất;
  18 *KHz = tần số;
  19
  20 trả về 0;
  21 }
  22
  23 static void foo_cpufreq_register_em(struct cpufreq_policy *policy)
  24 {
  25 cấu trúc em_data_callback em_cb = EM_DATA_CB(est_power);
  26 thiết bị cấu trúc *cpu_dev;
  27 int nr_opp;
  28
  29 cpu_dev = get_cpu_device(cpumask_first(chính sách->cpus));
  30
  31 /* Tìm số OPP cho chính sách này */
  32 nr_opp = foo_get_nr_opp(chính sách);
  33
  34 /* Và đăng ký miền hiệu suất mới */
  35 em_dev_register_perf_domain(cpu_dev, nr_opp, &em_cb, chính sách->cpus,
  36 đúng);
  37 }
  38
  39 cấu trúc tĩnh cpufreq_driver foo_cpufreq_driver = {
  40 .register_em = foo_cpufreq_register_em,
  41 };


3.2 Trình điều khiển mẫu có sửa đổi EM
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Phần này cung cấp một ví dụ đơn giản về trình điều khiển nhiệt sửa đổi EM.
Trình điều khiển triển khai hàm foo_thermal_em_update(). Tài xế đã thức giấc
up định kỳ để kiểm tra nhiệt độ và sửa đổi dữ liệu EM::

-> trình điều khiển/soc/example/example_em_mod.c

01 khoảng trống tĩnh foo_get_new_em(struct foo_context *ctx)
  02 {
  03 cấu trúc em_perf_table __rcu *em_table;
  04 cấu trúc em_perf_state *table, *new_table;
  05 thiết bị cấu trúc *dev = ctx->dev;
  06 cấu trúc em_perf_domain *pd;
  07 tần số dài không dấu;
  08 int i, ret;
  09
  10 pd = em_pd_get(dev);
  11 nếu (!pd)
  12 trở về;
  13
  14 em_table = em_table_alloc(pd);
  15 nếu (!em_table)
  16 trở về;
  17
  18 new_table = em_table->state;
  19
  20 rcu_read_lock();
  21 bảng = em_perf_state_from_pd(pd);
  22 cho (i = 0; i < pd->nr_perf_states; i++) {
  23 tần số = bảng[i].tần số;
  24 foo_get_power_perf_values(dev, freq, &new_table[i]);
  25 }
  26 rcu_read_unlock();
  27
  28 /* Tính giá trị 'chi phí' cho EAS */
  29 ret = em_dev_compute_costs(dev, new_table, pd->nr_perf_states);
  30 nếu (ret) {
  31 dev_warn(dev, "EM: chi phí tính toán thất bại %d\n", ret);
  32 em_table_free(em_table);
  33 trở về;
  34 }
  35
  36 ret = em_dev_update_perf_domain(dev, em_table);
  37 nếu (ret) {
  38 dev_warn(dev, "EM: cập nhật thất bại %d\n", ret);
  39 em_table_free(em_table);
  40 trở về;
  41 }
  42
  43 /*
  44 * Vì đây là bản cập nhật một lần nên sẽ bỏ bộ đếm mức sử dụng.
  45 * Khung EM sau này sẽ giải phóng bảng khi cần.
  46 */
  47 em_table_free(em_table);
  48 }
  49
  50 /*
  51 * Chức năng được gọi định kỳ để kiểm tra nhiệt độ và
  52* cập nhật EM nếu cần
  53 */
  54 khoảng trống tĩnh foo_thermal_em_update(struct foo_context *ctx)
  55 {
  56 thiết bị cấu trúc *dev = ctx->dev;
  CPU 57 int;
  58
  59 ctx->nhiệt độ = foo_get_temp(dev, ctx);
  60 nếu (ctx->nhiệt độ < FOO_EM_UPDATE_TEMP_THRESHOLD)
  61 trở về;
  62
  63 foo_get_new_em(ctx);
  64 }