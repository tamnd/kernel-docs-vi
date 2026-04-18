.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scheduler/sched-capacity.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
Lập kế hoạch nhận biết năng lực
===============================

1. Dung lượng CPU
===============

1.1 Giới thiệu
----------------

Các nền tảng SMP thông thường, đồng nhất bao gồm các thành phần hoàn toàn giống nhau
CPU. Mặt khác, các nền tảng không đồng nhất bao gồm các CPU có
các đặc tính hiệu suất khác nhau - trên các nền tảng như vậy, không phải tất cả các CPU đều có thể
được coi là bình đẳng.

Dung lượng CPU là thước đo hiệu suất mà CPU có thể đạt được, được chuẩn hóa theo
CPU hiệu suất cao nhất trong hệ thống. Các hệ thống không đồng nhất còn được gọi là
hệ thống dung lượng CPU không đối xứng, vì chúng chứa các CPU có dung lượng khác nhau.

Sự chênh lệch về hiệu suất tối đa có thể đạt được (IOW ở công suất CPU tối đa) bắt nguồn từ
từ hai yếu tố:

- không phải tất cả các CPU đều có thể có cùng một vi kiến ​​trúc (µarch).
- với Thang đo tần số và điện áp động (DVFS), không phải tất cả CPU đều có thể
  có thể chất để đạt được Điểm hiệu suất hoạt động cao hơn (OPP).

Hệ thống Arm big.LITTLE là một ví dụ cho cả hai. CPU lớn thì nhiều hơn
định hướng hiệu suất hơn LITTLE (nhiều giai đoạn đường ống hơn, bộ nhớ đệm lớn hơn,
dự đoán thông minh hơn, v.v.) và thường có thể đạt được OPP cao hơn so với LITTLE
có thể.

Hiệu suất của CPU thường được biểu thị bằng Hàng triệu lệnh mỗi giây
(MIPS), cũng có thể được biểu thị dưới dạng số lượng lệnh nhất định có thể đạt được
mỗi Hz, dẫn đến::

dung lượng(cpu) = công_per_hz(cpu) * max_freq(cpu)

1.2 Điều khoản của người lập lịch
-------------------

Hai giá trị dung lượng khác nhau được sử dụng trong bộ lập lịch. Một chiếc CPU
ZZ0000ZZ là công suất tối đa có thể đạt được, tức là mức tối đa của nó
mức hiệu suất có thể đạt được. Công suất ban đầu này được trả về bởi
hàm Arch_scale_cpu_capacity(). ZZ0001ZZ của CPU là ZZ0002ZZ của nó mà một số mất hiệu suất khả dụng (ví dụ: thời gian sử dụng
xử lý IRQ) bị trừ.

Lưu ý rằng ZZ0000ZZ của CPU chỉ dành cho lớp CFS sử dụng,
trong khi ZZ0001ZZ là bất khả tri về lớp. Phần còn lại của tài liệu này sẽ sử dụng
thuật ngữ ZZ0002ZZ có thể thay thế cho nhau bằng ZZ0003ZZ vì mục đích
ngắn gọn.

1.3 Ví dụ về nền tảng
---------------------

1.3.1 OPP giống hệt nhau
~~~~~~~~~~~~~~~~~~~~

Hãy xem xét một hệ thống dung lượng CPU lõi kép không đối xứng giả định trong đó

- công_per_hz(CPU0) = W
- công_per_hz(CPU1) = W/2
- tất cả các CPU đang chạy ở cùng tần số cố định

Theo định nghĩa trên về năng lực:

- công suất(CPU0) = C
- công suất(CPU1) = C/2

Để vẽ song song với Arm big.LITTLE, CPU0 sẽ lớn trong khi CPU1 sẽ
là LITTLE.

Với khối lượng công việc thực hiện định kỳ một lượng công việc cố định, bạn sẽ nhận được
dấu vết thực hiện như vậy::

CPU0 hoạt động ^
           |     ____ ____ ____
           ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ |
           +----+----+----+----+----+----+----+----+----+----+-> thời gian

CPU1 hoạt động ^
           |     _________ _________ ____
           ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ
           +----+----+----+----+----+----+----+----+----+----+-> thời gian

CPU0 có công suất cao nhất trong hệ thống (C) và hoàn thành một lượng cố định
tính W theo đơn vị T thời gian. Mặt khác, CPU1 có một nửa công suất
CPU0 và do đó chỉ hoàn thành W/2 trong T.

1.3.2 OPP tối đa khác nhau
~~~~~~~~~~~~~~~~~~~~~~~~

Thông thường, các CPU có giá trị công suất khác nhau cũng có mức tối đa khác nhau.
OPP. Hãy xem xét các CPU tương tự như trên (tức là cùng một work_per_hz()) với:

- max_freq(CPU0) = F
- max_freq(CPU1) = 2/3 * F

Điều này mang lại:

- công suất(CPU0) = C
- công suất(CPU1) = C/3

Thực hiện cùng một khối lượng công việc như được mô tả trong 1.3.1, mỗi CPU chạy ở tốc độ riêng của nó.
tần số tối đa dẫn đến::

CPU0 hoạt động ^
           |     ____ ____ ____
           ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ |
           +----+----+----+----+----+----+----+----+----+----+-> thời gian

khối lượng công việc trên CPU1
 CPU1 hoạt động ^
           |     ______________ ______________ ____
           ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ
           +----+----+----+----+----+----+----+----+----+----+-> thời gian

1.4 Thông báo trước về cách trình bày
-------------------------

Cần lưu ý rằng việc có giá trị ZZ0000ZZ để thể hiện sự khác biệt trong CPU
hiệu suất là một điểm gây tranh cãi. Hiệu suất tương đối
sự khác biệt giữa hai µarch khác nhau có thể là X% đối với các phép tính số nguyên, Y% đối với
các phép toán dấu phẩy động, Z% trên các nhánh, v.v. Tuy nhiên, kết quả sử dụng này
cách tiếp cận đơn giản đã được thỏa đáng cho bây giờ.

2. Sử dụng nhiệm vụ
===================

2.1 Giới thiệu
----------------

Lập kế hoạch nhận biết năng lực đòi hỏi sự thể hiện các yêu cầu của nhiệm vụ với
liên quan đến dung lượng CPU. Mỗi lớp lập lịch trình có thể thể hiện điều này một cách khác nhau và
trong khi việc sử dụng tác vụ là dành riêng cho CFS, thật thuận tiện để mô tả nó ở đây
để giới thiệu những khái niệm chung hơn.

Việc sử dụng tác vụ là tỷ lệ phần trăm nhằm thể hiện các yêu cầu về thông lượng
của một nhiệm vụ. Một cách gần đúng đơn giản của nó là chu kỳ nhiệm vụ của nhiệm vụ, tức là::

task_util(p) = nhiệm vụ_cycle(p)

Trên hệ thống SMP có tần số cố định, mức sử dụng 100% cho thấy tác vụ là một
vòng lặp bận rộn. Ngược lại, mức sử dụng 10% cho thấy đó là một nhiệm vụ nhỏ định kỳ
dành nhiều thời gian để ngủ hơn là thực hiện. Tần số CPU có thể thay đổi và
dung lượng CPU không đối xứng phần nào làm phức tạp điều này; các phần sau đây sẽ
mở rộng về những điều này.

2.2 Bất biến tần số
------------------------

Một vấn đề cần được tính đến là chu kỳ nhiệm vụ của khối lượng công việc
bị ảnh hưởng trực tiếp bởi OPP hiện tại mà CPU đang chạy. Hãy cân nhắc việc chạy một
khối lượng công việc định kỳ ở tần số nhất định F::

CPU hoạt động ^
           |     ____ ____ ____
           ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ |
           +----+----+----+----+----+----+----+----+----+----+-> thời gian

Điều này mang lại Duty_cycle(p) == 25%.

Bây giờ, hãy cân nhắc việc chạy khối lượng công việc ZZ0000ZZ ở tần số F/2::

CPU hoạt động ^
           |     _________ _________ ____
           ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ
           +----+----+----+----+----+----+----+----+----+----+-> thời gian

Điều này mang lại Duty_cycle(p) == 50%, mặc dù nhiệm vụ có cùng một kết quả
hành vi (tức là thực hiện cùng một lượng công việc) trong cả hai lần thực thi.

Tín hiệu sử dụng nhiệm vụ có thể được tạo thành bất biến tần số bằng cách sử dụng như sau
công thức::

task_util_freq_inv(p) = Duty_cycle(p) * (curr_ần số(cpu) / max_ần số(cpu))

Áp dụng công thức này cho hai ví dụ trên sẽ mang lại một tần số bất biến
việc sử dụng nhiệm vụ là 25%.

2.3 CPU bất biến
------------------

Dung lượng CPU có tác dụng tương tự đối với việc sử dụng tác vụ khi chạy một
khối lượng công việc giống hệt nhau trên các CPU có giá trị dung lượng khác nhau sẽ mang lại kết quả khác nhau
chu kỳ nhiệm vụ.

Hãy xem xét hệ thống được mô tả trong 1.3.2., tức là::

- công suất(CPU0) = C
- công suất(CPU1) = C/3

Việc thực hiện khối lượng công việc định kỳ nhất định trên mỗi CPU ở tần suất tối đa của chúng sẽ
dẫn đến::

CPU0 hoạt động ^
           |     ____ ____ ____
           ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ |
           +----+----+----+----+----+----+----+----+----+----+-> thời gian

CPU1 hoạt động ^
           |     ______________ ______________ ____
           ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ
           +----+----+----+----+----+----+----+----+----+----+-> thời gian

IOW,

- Duty_cycle(p) == 25% nếu p chạy trên CPU0 ở tần số tối đa
- Duty_cycle(p) == 75% nếu p chạy trên CPU1 ở tần số tối đa

Tín hiệu sử dụng tác vụ có thể được tạo thành bất biến CPU bằng cách sử dụng cách sau
công thức::

task_util_cpu_inv(p) = Duty_cycle(p) * (dung lượng(cpu) / max_capacity)

với ZZ0000ZZ là giá trị dung lượng CPU cao nhất trong
hệ thống. Áp dụng công thức này cho ví dụ trên mang lại CPU
việc sử dụng nhiệm vụ bất biến là 25%.

2.4 Sử dụng tác vụ bất biến
------------------------------

Cả tần số và tính bất biến CPU cần được áp dụng cho việc sử dụng tác vụ trong
để thu được tín hiệu thực sự bất biến. Công thức giả cho một nhiệm vụ
Do đó, việc sử dụng cả CPU và tần số không đổi đối với một
nhiệm vụ p::

công suất curr_tần số(cpu)(cpu)
  task_util_inv(p) = nhiệm vụ_cycle(p) * ------------------- * -------------
                                     tần số tối đa (cpu) max_capacity

Nói cách khác, việc sử dụng tác vụ bất biến mô tả hành vi của một tác vụ như
nếu nó đang chạy trên CPU có dung lượng cao nhất trong hệ thống, chạy ở tốc độ của nó
tần số tối đa.

Bất kỳ đề cập nào đến việc sử dụng nhiệm vụ trong các phần sau sẽ hàm ý rằng
dạng bất biến.

2.5 Ước tính sử dụng
--------------------------

Nếu không có quả cầu pha lê, hành vi nhiệm vụ (và do đó việc sử dụng nhiệm vụ) không thể
được dự đoán chính xác vào thời điểm tác vụ đầu tiên có thể chạy được. Lớp CFS
duy trì một số tín hiệu CPU và tác vụ dựa trên Tải trên mỗi thực thể
Cơ chế theo dõi (PELT), một trong những cơ chế mang lại khả năng sử dụng ZZ0000ZZ (như
trái ngược với tức thời).

Điều này có nghĩa là trong khi các tiêu chí lập kế hoạch nhận biết năng lực sẽ được ghi
xem xét việc sử dụng nhiệm vụ "thực sự" (sử dụng quả cầu pha lê), việc thực hiện
sẽ chỉ có thể sử dụng công cụ ước tính của nó.

3. Yêu cầu về năng lực lập kế hoạch
=========================================

3.1 Dung lượng CPU
----------------

Linux hiện không thể tự mình tìm ra dung lượng CPU, do đó thông tin này
cần phải giao cho nó. Kiến trúc phải xác định Arch_scale_cpu_capacity()
vì mục đích đó.

Kiến trúc arm, arm64 và RISC-V ánh xạ trực tiếp điều này tới trình điều khiển Arch_topology
Dữ liệu chia tỷ lệ CPU, được lấy từ liên kết dung lượng-dmips-mhz CPU; xem
Tài liệu/devicetree/binds/cpu/cpu-capacity.txt.

3.2 Bất biến tần số
------------------------

Như đã nêu ở phần 2.2, việc lập kế hoạch nhận biết dung lượng yêu cầu một nhiệm vụ không thay đổi tần số
việc sử dụng. Kiến trúc phải xác định Arch_scale_freq_capacity(cpu) cho điều đó
mục đích.

Việc thực hiện chức năng này đòi hỏi phải tìm ra tần số của mỗi CPU
đã chạy ở. Một cách để thực hiện điều này là tận dụng bộ đếm phần cứng
có thang đo tốc độ tăng theo tần số hiện tại của CPU (APERF/MPERF trên x86,
AMU trên arm64). Một cách khác là nối trực tiếp vào các chuyển đổi tần số cpufreq,
khi hạt nhân nhận biết được tần số chuyển sang (cũng được sử dụng bởi
cánh tay/cánh tay64).

4. Cấu trúc liên kết lập lịch
=====================

Trong quá trình xây dựng các miền được lập lịch, người lập lịch sẽ tìm ra
liệu hệ thống có thể hiện khả năng CPU không đối xứng hay không. Đó có phải là
trường hợp:

- Khóa tĩnh sched_asym_cpucapacity sẽ được bật.
- Cờ SD_ASYM_CPUCAPACITY_FULL sẽ được đặt ở sched_domain thấp nhất
  mức bao trùm tất cả các giá trị dung lượng CPU duy nhất.
- Cờ SD_ASYM_CPUCAPACITY sẽ được đặt cho bất kỳ sched_domain nào kéo dài
  CPU có bất kỳ phạm vi bất đối xứng nào.

Khóa tĩnh sched_asym_cpucapacity nhằm mục đích bảo vệ các phần mã
phục vụ cho các hệ thống công suất CPU không đối xứng. Tuy nhiên, hãy lưu ý rằng chìa khóa đã nói là
ZZ0000ZZ. Hãy tưởng tượng thiết lập sau đây bằng cách sử dụng cpusets::

công suất C/2 C
            ________ ________
           / \ / \
  CPU 0 1 2 3 4 5 6 7
           \__/ \______________/
  bộ xử lý cs0 cs1

Có thể được tạo thông qua:

.. code-block:: sh

  mkdir /sys/fs/cgroup/cpuset/cs0
  echo 0-1 > /sys/fs/cgroup/cpuset/cs0/cpuset.cpus
  echo 0 > /sys/fs/cgroup/cpuset/cs0/cpuset.mems

  mkdir /sys/fs/cgroup/cpuset/cs1
  echo 2-7 > /sys/fs/cgroup/cpuset/cs1/cpuset.cpus
  echo 0 > /sys/fs/cgroup/cpuset/cs1/cpuset.mems

  echo 0 > /sys/fs/cgroup/cpuset/cpuset.sched_load_balance

Vì có sự bất đối xứng về dung lượng ZZ0000ZZ CPU trong hệ thống, nên
Khóa tĩnh sched_asym_cpucapacity sẽ được bật. Tuy nhiên, sched_domain
hệ thống phân cấp của CPU 0-1 trải rộng trên một giá trị dung lượng duy nhất: SD_ASYM_CPUCAPACITY không
được thiết lập theo hệ thống phân cấp đó, nó mô tả một hòn đảo SMP và phải được xử lý như vậy.

Do đó, mẫu 'chuẩn' để bảo vệ các đường dẫn mã phục vụ cho
Dung lượng CPU không đối xứng là:

- Kiểm tra key tĩnh sched_asym_cpucapacity
- Nếu nó được bật thì hãy kiểm tra sự hiện diện của SD_ASYM_CPUCAPACITY trong
  hệ thống phân cấp sched_domain (nếu có liên quan, tức là đường dẫn mã nhắm mục tiêu một địa chỉ cụ thể
  CPU hoặc nhóm của chúng)

5. Nhận thức được năng lực thực hiện lập kế hoạch
===========================================

5.1 CFS
-------

5.1.1 Năng lực phù hợp
~~~~~~~~~~~~~~~~~~~~~~

Tiêu chí lập kế hoạch công suất chính của CFS là::

task_util(p) < dung lượng(task_cpu(p))

Đây thường được gọi là tiêu chí phù hợp năng lực, tức là CFS phải đảm bảo
nhiệm vụ "phù hợp" trên CPU của nó. Nếu vi phạm, nhiệm vụ sẽ cần đạt được nhiều hơn
hoạt động tốt hơn những gì CPU của nó có thể cung cấp: nó sẽ bị giới hạn bởi CPU.

Hơn nữa, uclamp cho phép không gian người dùng chỉ định mức sử dụng tối thiểu và tối đa
giá trị cho một tác vụ, thông qua sched_setattr() hoặc qua giao diện cgroup (xem
Tài liệu/admin-guide/cgroup-v2.rst). Đúng như tên gọi của nó, điều này có thể được sử dụng để
kẹp task_util() trong tiêu chí trước đó.

5.1.2 Lựa chọn Wakeup CPU
~~~~~~~~~~~~~~~~~~~~~~~~~~

Đánh thức tác vụ CFS Lựa chọn CPU tuân theo tiêu chí dung lượng phù hợp được mô tả
ở trên. Trên hết, uclamp được sử dụng để kẹp các giá trị sử dụng tác vụ,
cho phép không gian người dùng có nhiều đòn bẩy hơn so với lựa chọn CPU của CFS
nhiệm vụ. Lựa chọn IOW, CFS đánh thức CPU tìm kiếm CPU thỏa mãn::

kẹp(task_util(p), task_uclamp_min(p), task_uclamp_max(p)) < dung lượng(cpu)

Bằng cách sử dụng uclamp, không gian người dùng có thể ví dụ: cho phép chạy vòng lặp bận (sử dụng 100%)
trên bất kỳ CPU nào bằng cách đặt giá trị uclamp.max thấp cho nó. Ngược lại, nó có thể buộc một lượng nhỏ
nhiệm vụ định kỳ (ví dụ: sử dụng 10%) để chạy trên CPU có hiệu suất cao nhất bằng cách
mang lại cho nó một giá trị uclamp.min cao.

.. note::

  Wakeup CPU selection in CFS can be eclipsed by Energy Aware Scheduling
  (EAS), which is described in Documentation/scheduler/sched-energy.rst.

5.1.3 Cân bằng tải
~~~~~~~~~~~~~~~~~~~~

Một trường hợp bệnh lý trong quá trình lựa chọn CPU khi thức dậy xảy ra khi một tác vụ hiếm khi được thực hiện
ngủ, nếu có - do đó nó hiếm khi thức dậy, nếu có. Coi như::

w == sự kiện đánh thức

công suất(CPU0) = C
  công suất(CPU1) = C/3

khối lượng công việc trên CPU0
  CPU hoạt động ^
           |     _________ _________ ____
           ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ
           +----+----+----+----+----+----+----+----+----+----+-> thời gian
                ồ ồ

khối lượng công việc trên CPU1
  CPU hoạt động ^
           |     ____________________________________________
           ZZ0000ZZ
           +----+----+----+----+----+----+----+----+----+----+->
                w

Khối lượng công việc này sẽ chạy trên CPU0, nhưng nếu tác vụ:

- đã được lên kế hoạch không đúng ngay từ đầu (thời gian ban đầu không chính xác
  ước tính sử dụng)
- đã được lên kế hoạch hợp lý ngay từ đầu, nhưng đột nhiên cần nhiều hơn
  sức mạnh xử lý

sau đó nó có thể trở thành giới hạn CPU, IOW ZZ0000ZZ;
tiêu chí lập kế hoạch công suất CPU bị vi phạm và có thể không còn nữa
sự kiện đánh thức để khắc phục vấn đề này thông qua lựa chọn đánh thức CPU.

Các nhiệm vụ trong tình huống này được gọi là nhiệm vụ "không phù hợp" và cơ chế
đưa ra để xử lý cổ phiếu này cùng tên. Di chuyển nhiệm vụ không phù hợp
tận dụng bộ cân bằng tải CFS, cụ thể hơn là phần cân bằng tải hoạt động
(phục vụ cho việc di chuyển các tác vụ hiện đang chạy). Khi cân bằng tải xảy ra,
cân bằng tải hoạt động không phù hợp sẽ được kích hoạt nếu một tác vụ không phù hợp có thể được di chuyển
lên CPU có dung lượng lớn hơn CPU hiện tại.

5.2 RT
------

5.2.1 Lựa chọn Wakeup CPU
~~~~~~~~~~~~~~~~~~~~~~~~~~

Đánh thức tác vụ RT Lựa chọn CPU tìm kiếm CPU thỏa mãn::

task_uclamp_min(p) <= dung lượng(task_cpu(cpu))

trong khi vẫn tuân theo các ràng buộc ưu tiên thông thường. Nếu không có ứng viên nào
CPU có thể đáp ứng tiêu chí dung lượng này, sau đó lập lịch dựa trên mức độ ưu tiên nghiêm ngặt
được tuân theo và dung lượng CPU bị bỏ qua.

5.3 DL
------

5.3.1 Lựa chọn Wakeup CPU
~~~~~~~~~~~~~~~~~~~~~~~~~~

Lựa chọn CPU đánh thức tác vụ DL sẽ tìm kiếm CPU thỏa mãn::

task_bandwidth(p) < dung lượng(task_cpu(p))

trong khi vẫn tôn trọng các hạn chế về băng thông và thời hạn thông thường. Nếu
không có CPU ứng cử viên nào có thể đáp ứng tiêu chí dung lượng này, thì
nhiệm vụ sẽ vẫn còn trên CPU hiện tại của nó.
