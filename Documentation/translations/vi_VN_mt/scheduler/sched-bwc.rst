.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scheduler/sched-bwc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================
Kiểm soát băng thông CFS
========================

.. note::
   This document only discusses CPU bandwidth control for SCHED_NORMAL.
   The SCHED_RT case is covered in Documentation/scheduler/sched-rt-group.rst

Kiểm soát băng thông CFS là một phần mở rộng của CONFIG_FAIR_GROUP_SCHED cho phép
thông số kỹ thuật về băng thông CPU tối đa có sẵn cho một nhóm hoặc hệ thống phân cấp.

Băng thông được phép cho một nhóm được chỉ định bằng hạn ngạch và khoảng thời gian. trong vòng
mỗi "khoảng thời gian" nhất định (micro giây), một nhóm nhiệm vụ được phân bổ theo "hạn ngạch"
micro giây của thời gian CPU. Hạn ngạch đó được gán cho hàng đợi chạy trên mỗi CPU trong
các lát cắt khi các luồng trong nhóm có thể chạy được. Khi tất cả hạn ngạch đã được
được chỉ định bất kỳ yêu cầu bổ sung nào về hạn ngạch sẽ dẫn đến việc các luồng đó bị
bị ga. Các chủ đề bị điều chỉnh sẽ không thể chạy lại cho đến lần tiếp theo
thời điểm hạn ngạch được bổ sung.

Hạn ngạch chưa được chỉ định của một nhóm được theo dõi trên toàn cầu và được làm mới trở lại
đơn vị cfs_quota tại mỗi ranh giới thời kỳ. Khi các luồng tiêu thụ băng thông này
được chuyển đến "silo" cpu cục bộ trên cơ sở nhu cầu. Số tiền đã chuyển
trong mỗi bản cập nhật này đều có thể điều chỉnh được và được mô tả là "lát cắt".

Tính năng bùng nổ
-------------
Tính năng này mượn thời gian hiện tại để chống lại sự thiếu hụt trong tương lai của chúng tôi, với cái giá phải trả là
tăng sự can thiệp đối với những người sử dụng hệ thống khác. Tất cả đều được giới hạn độc đáo.

Kiểm soát băng thông truyền thống (UP-EDF) giống như:

(U = \Sum u_i) <= 1

Điều này đảm bảo rằng mọi thời hạn đều được đáp ứng và hệ thống được
ổn định. Xét cho cùng, nếu U > 1 thì cứ mỗi giây của walltime,
chúng tôi sẽ phải chạy hơn một giây trong thời gian của chương trình và rõ ràng là đã bỏ lỡ
hạn chót của chúng tôi, nhưng thời hạn tiếp theo sẽ còn xa hơn nữa, còn có
không bao giờ có thời gian để bắt kịp, thất bại không giới hạn.

Tính năng bùng nổ nhận thấy rằng khối lượng công việc không phải lúc nào cũng thực thi đầy đủ
hạn ngạch; điều này cho phép người ta mô tả u_i dưới dạng phân phối thống kê.

Ví dụ: có u_i = {x,e__i, trong đó x là p(95) và x+e p(100)
(WCET truyền thống). Điều này cho phép bạn nhỏ hơn một cách hiệu quả,
tăng hiệu quả (chúng ta có thể đóng gói nhiều tác vụ hơn vào hệ thống), nhưng tại
cái giá của việc trễ thời hạn khi tất cả các cơ hội đều xuất hiện. Tuy nhiên, nó
duy trì sự ổn định, vì mỗi lần vượt mức phải được ghép nối với một
vượt mức miễn là x của chúng tôi cao hơn mức trung bình.

Nghĩa là, giả sử chúng ta có 2 tác vụ, cả hai đều chỉ định giá trị p(95), thì chúng ta
có khả năng p(95)*p(95) = 90,25% cả hai nhiệm vụ đều nằm trong hạn ngạch và
mọi thứ đều tốt Đồng thời chúng ta có cơ hội p(5)p(5) = 0,25%
cả hai nhiệm vụ sẽ vượt quá hạn ngạch cùng một lúc (thời hạn được đảm bảo
thất bại). Đâu đó ở giữa có một ngưỡng mà người ta vượt qua và
cái kia không đủ để bù đắp; điều này phụ thuộc vào
CDF cụ thể.

Đồng thời, chúng ta có thể nói rằng trường hợp xấu nhất là lỡ thời hạn, sẽ là
\Tổng e_i; nghĩa là có một độ trễ giới hạn (theo giả định
x+e đó thực sự là WCET).

Sự can thiệp khi sử dụng cụm được đánh giá bằng khả năng
thiếu thời hạn và WCET trung bình. Kết quả thử nghiệm cho thấy khi
có nhiều nhóm hoặc CPU chưa được sử dụng nên sẽ có hiện tượng nhiễu
hạn chế. Thêm chi tiết được hiển thị trong:
ZZ0000ZZ

Sự quản lý
----------
Hạn ngạch, thời gian và cụm được quản lý trong hệ thống con cpu thông qua cgroupfs.

.. note::
   The cgroupfs files described in this section are only applicable
   to cgroup v1. For cgroup v2, see
   :ref:`Documentation/admin-guide/cgroup-v2.rst <cgroup-v2-cpu>`.

- cpu.cfs_quota_us: thời gian chạy được bổ sung trong một khoảng thời gian (tính bằng micro giây)
- cpu.cfs_ Period_us: độ dài của một khoảng thời gian (tính bằng micro giây)
- cpu.stat: xuất số liệu thống kê điều chỉnh [được giải thích thêm bên dưới]
- cpu.cfs_burst_us: thời gian chạy tích lũy tối đa (tính bằng micro giây)

Các giá trị mặc định là::

cpu.cfs_ Period_us=100ms
	cpu.cfs_quota_us=-1
	cpu.cfs_burst_us=0

Giá trị -1 cho cpu.cfs_quota_us chỉ ra rằng nhóm không có bất kỳ
hạn chế băng thông tại chỗ, một nhóm như vậy được mô tả là không bị ràng buộc
nhóm băng thông. Điều này thể hiện hành vi tiết kiệm công việc truyền thống cho
CFS.

Viết bất kỳ (các) giá trị dương (hợp lệ) nào không nhỏ hơn cpu.cfs_burst_us sẽ
ban hành giới hạn băng thông được chỉ định. Hạn ngạch tối thiểu được phép đối với hạn ngạch hoặc
chu kỳ là 1ms. Ngoài ra còn có giới hạn trên đối với độ dài khoảng thời gian là 1 giây.
Các hạn chế bổ sung tồn tại khi giới hạn băng thông được sử dụng trong hệ thống phân cấp
thời trang, những điều này sẽ được giải thích chi tiết hơn dưới đây.

Việc ghi bất kỳ giá trị âm nào vào cpu.cfs_quota_us sẽ xóa giới hạn băng thông
và đưa nhóm trở lại trạng thái không bị ràng buộc một lần nữa.

Giá trị 0 cho cpu.cfs_burst_us chỉ ra rằng nhóm không thể tích lũy
bất kỳ băng thông nào chưa được sử dụng. Nó làm cho hành vi kiểm soát băng thông truyền thống cho
CFS không thay đổi. Viết bất kỳ (các) giá trị dương (hợp lệ) nào không lớn hơn
cpu.cfs_quota_us vào cpu.cfs_burst_us sẽ áp dụng giới hạn băng thông chưa sử dụng
tích lũy.

Bất kỳ cập nhật nào đối với thông số kỹ thuật băng thông của một nhóm sẽ khiến nhóm đó trở thành
không được điều chỉnh nếu nó ở trạng thái bị hạn chế.

Cài đặt toàn hệ thống
--------------------
Để đạt hiệu quả, thời gian chạy được chuyển giữa nhóm chung và CPU cục bộ
"silo" theo kiểu hàng loạt. Điều này làm giảm đáng kể áp lực kế toán toàn cầu
trên các hệ thống lớn. Số tiền được chuyển mỗi lần cần cập nhật như vậy
được mô tả là "lát".

Điều này có thể điều chỉnh được thông qua Procfs::

/proc/sys/kernel/sched_cfs_bandwidth_slice_us (mặc định=5ms)

Giá trị lát cắt lớn hơn sẽ giảm chi phí chuyển giao, trong khi giá trị nhỏ hơn cho phép
để tiêu thụ nhiều hạt mịn hơn.

Thống kê
----------
Thống kê băng thông của một nhóm được xuất qua 5 trường trong cpu.stat.

cpu.stat:

- nr_ Periods: Số khoảng thời gian thực thi đã trôi qua.
- nr_throttled: Số lần nhóm bị điều tiết/giới hạn.
- Thred_time: Tổng thời lượng (tính bằng nano giây) cho các thực thể
  của nhóm đã bị hạn chế.
- nr_bursts: Số chu kỳ xảy ra.
-burst_time: Thời gian treo tường tích lũy (tính bằng nano giây) mà bất kỳ CPU nào đã sử dụng
  vượt hạn mức trong các thời kỳ tương ứng.

Giao diện này chỉ đọc.

Cân nhắc về thứ bậc
---------------------------
Giao diện buộc băng thông của một thực thể riêng lẻ luôn luôn
có thể đạt được, đó là: max(c_i) <= C. Tuy nhiên, đăng ký quá mức trong
trường hợp tổng hợp được cho phép rõ ràng để kích hoạt ngữ nghĩa bảo toàn công việc
trong một hệ thống phân cấp:

ví dụ. \Sum (c_i) có thể vượt quá C

[ Trong đó C là băng thông của cha mẹ và c_i con của nó ]


Có hai cách mà một nhóm có thể bị hạn chế:

Một. nó tiêu thụ hết hạn ngạch của mình trong một khoảng thời gian
	b. hạn ngạch của phụ huynh được sử dụng hết trong thời hạn của nó

Trong trường hợp b) ở trên, mặc dù trẻ có thể còn thời gian chạy nhưng nó sẽ không
được phép cho đến khi thời gian chạy của cha mẹ được làm mới.

Hãy cẩn thận về hạn ngạch băng thông CFS
---------------------------
Khi một lát được gán cho CPU, nó sẽ không hết hạn.  Tuy nhiên tất cả trừ 1ms
lát cắt có thể được trả về nhóm chung nếu tất cả các luồng trên CPU đó trở thành
không thể chạy được. Điều này được cấu hình tại thời điểm biên dịch bởi min_cfs_rq_runtime
biến. Đây là một tinh chỉnh hiệu suất giúp ngăn chặn sự tranh chấp thêm trên
khóa toàn cầu.

Việc các lát CPU-local không hết hạn dẫn đến một số góc thú vị
trường hợp cần hiểu.

Đối với các ứng dụng bị giới hạn CPU của cgroup bị giới hạn CPU thì đây là một
điểm tương đối cần tranh luận vì họ sẽ tự nhiên tiêu thụ toàn bộ
hạn ngạch cũng như toàn bộ từng lát CPU-local trong từng thời kỳ. Như một
kết quả là người ta mong đợi rằng nr_ Periods gần bằng nr_throttled và điều đó
cpuacct.usage sẽ tăng khoảng bằng cfs_quota_us trong từng thời kỳ.

Đối với các ứng dụng có nhiều luồng, không bị ràng buộc bởi CPU, sắc thái không hết hạn này
cho phép các ứng dụng vượt quá giới hạn hạn ngạch của họ trong thời gian ngắn
lát không được sử dụng trên mỗi CPU mà nhóm tác vụ đang chạy (thường nhiều nhất là
1ms trên mỗi CPU hoặc như được xác định bởi min_cfs_rq_runtime).  Chỉ bùng nổ nhẹ này thôi
áp dụng nếu hạn ngạch đã được gán cho một CPU và sau đó không được sử dụng hết hoặc được trả lại
ở các thời kỳ trước. Lượng bùng nổ này sẽ không được chuyển giữa các lõi.
Vì vậy, cơ chế này vẫn hạn chế nghiêm ngặt nhóm công tác về hạn ngạch.
mức sử dụng trung bình, mặc dù trong khoảng thời gian dài hơn một khoảng thời gian.  Cái này
cũng giới hạn khả năng bùng nổ không quá 1ms trên mỗi cpu.  Điều này cung cấp
trải nghiệm người dùng dễ dự đoán tốt hơn cho các ứng dụng có nhiều luồng với
giới hạn hạn ngạch nhỏ trên các máy có số lượng lõi cao. Nó cũng loại bỏ sự
xu hướng điều tiết các ứng dụng này đồng thời sử dụng ít hơn
số lượng hạn ngạch của cpu. Một cách khác để nói điều này là bằng cách cho phép những phần không được sử dụng
phần của một lát vẫn có giá trị trong các khoảng thời gian, chúng tôi đã giảm
khả năng hết hạn ngạch một cách lãng phí trên các silo CPU cục bộ không cần
toàn bộ lượng thời gian CPU của lát cắt.

Sự tương tác giữa các ứng dụng tương tác gắn với CPU và không gắn với CPU
cũng cần được xem xét, đặc biệt khi mức sử dụng lõi đơn đạt 100%. Nếu bạn
đã cung cấp cho mỗi ứng dụng này một nửa lõi CPU và cả hai đều được lên lịch
trên cùng một CPU, về mặt lý thuyết có thể ứng dụng không liên kết với CPU
sẽ sử dụng hạn ngạch bổ sung lên tới 1ms trong một số giai đoạn, do đó ngăn chặn
ứng dụng bị ràng buộc bởi CPU không sử dụng hết hạn ngạch của nó với cùng số tiền đó. Trong này
trường hợp, nó sẽ tùy thuộc vào thuật toán CFS (xem sched-design-CFS.rst) để
quyết định ứng dụng nào được chọn để chạy, vì cả hai đều có thể chạy được và
có hạn ngạch còn lại. Sự khác biệt về thời gian chạy này sẽ được giải quyết sau đây
khoảng thời gian khi ứng dụng tương tác không hoạt động.

Ví dụ
--------
1. Giới hạn thời gian chạy của một nhóm ở mức 1 CPU::

Nếu khoảng thời gian là 250 mili giây và hạn ngạch cũng là 250 mili giây, nhóm sẽ nhận được
	Thời gian chạy có giá trị 1 CPU cứ sau 250 mili giây.

# echo 250000 > cpu.cfs_quota_us /* hạn ngạch = 250ms */
	# echo 250000 > cpu.cfs_ Period_us /* chu kỳ = 250ms */

2. Giới hạn thời gian chạy của một nhóm ở 2 CPU trên máy nhiều CPU

Với khoảng thời gian 500ms và hạn ngạch 1000ms, nhóm có thể nhận được 2 CPU trị giá
   thời gian chạy cứ sau 500ms::

# echo 1000000 > cpu.cfs_quota_us /* hạn ngạch = 1000ms */
	# echo 500000 > cpu.cfs_ Period_us /* chu kỳ = 500ms */

Khoảng thời gian lớn hơn ở đây cho phép tăng công suất bùng nổ.

3. Giới hạn một nhóm ở mức 20% của 1 CPU.

Với khoảng thời gian 50ms, hạn ngạch 10ms sẽ tương đương với 20% của 1 CPU::

# echo 10000 > cpu.cfs_quota_us /* hạn ngạch = 10ms */
	# echo 50000 > cpu.cfs_ Period_us /* chu kỳ = 50ms */

Bằng cách sử dụng một khoảng thời gian nhỏ ở đây, chúng tôi đảm bảo độ trễ nhất quán
   đáp ứng với chi phí của công suất bùng nổ.

4. Giới hạn một nhóm ở mức 40% của 1 CPU và cho phép tích lũy tối đa 20% của 1 CPU
   Ngoài ra, trong trường hợp tích lũy đã được thực hiện.

Với khoảng thời gian 50ms, hạn ngạch 20ms sẽ tương đương với 40% của 1 CPU.
   Và 10ms bùng nổ sẽ tương đương với 20% của 1 CPU::

# echo 20000 > cpu.cfs_quota_us /* hạn ngạch = 20ms */
	# echo 50000 > cpu.cfs_ Period_us /* chu kỳ = 50ms */
	# echo 10000 > cpu.cfs_burst_us /* nổ = 10ms */

Cài đặt bộ đệm lớn hơn (không lớn hơn hạn ngạch) cho phép dung lượng bùng nổ lớn hơn.
