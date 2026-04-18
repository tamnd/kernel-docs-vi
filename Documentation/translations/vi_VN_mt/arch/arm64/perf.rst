.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm64/perf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _perf_index:

====
hoàn hảo
====

Thuộc tính sự kiện Perf
=====================

:Tác giả: Andrew Murray <andrew.murray@arm.com>
:Ngày: 2019-03-06

loại trừ_user
------------

Thuộc tính này loại trừ không gian người dùng.

Không gian người dùng luôn chạy ở EL0 và do đó thuộc tính này sẽ loại trừ EL0.


loại trừ_kernel
--------------

Thuộc tính này loại trừ kernel.

Hạt nhân chạy ở EL2 với VHE và EL1 không có. Nhân khách luôn chạy
tại EL1.

Đối với máy chủ, thuộc tính này sẽ loại trừ EL1 và thêm vào đó là EL2 trên VHE
hệ thống.

Đối với khách, thuộc tính này sẽ loại trừ EL1. Xin lưu ý rằng EL2 là
không bao giờ được tính trong một khách.


loại trừ_hv
----------

Thuộc tính này loại trừ hypervisor.

Đối với máy chủ VHE, thuộc tính này bị bỏ qua vì chúng tôi coi nhân máy chủ là
trở thành người giám sát.

Đối với máy chủ không phải VHE, thuộc tính này sẽ loại trừ EL2 khi chúng tôi xem xét
hypervisor là bất kỳ mã nào chạy ở EL2, được sử dụng chủ yếu cho
chuyển tiếp khách/chủ.

Đối với khách, thuộc tính này không có hiệu lực. Xin lưu ý rằng EL2 là
không bao giờ được tính trong một khách.


loại trừ_host / loại trừ_khách
----------------------------

Các thuộc tính này loại trừ máy chủ và máy khách KVM tương ứng.

Máy chủ KVM có thể chạy ở EL0 (không gian người dùng), EL1 (nhân không phải VHE) và EL2 (VHE
kernel hoặc trình ảo hóa không phải VHE).

Khách KVM có thể chạy ở EL0 (không gian người dùng) và EL1 (kernel).

Do mức độ ngoại lệ chồng chéo giữa chủ nhà và khách nên chúng tôi không thể
hoàn toàn dựa vào tính năng lọc ngoại lệ phần cứng của PMU - do đó chúng tôi
phải bật/tắt tính năng đếm vào ra của khách. Đây là
được thực hiện khác nhau trên hệ thống VHE và không phải VHE.

Đối với các hệ thống không phải VHE, chúng tôi loại trừ EL2 cho loại trừ_host - khi nhập và
thoát khỏi khách, chúng tôi tắt/bật sự kiện khi thích hợp dựa trên
thuộc tính loại trừ_host và loại trừ_khách.

Đối với các hệ thống VHE, chúng tôi loại trừ EL1 cho loại trừ_guest và loại trừ cả EL0,EL2
cho loại trừ_host. Khi vào và ra khỏi khách, chúng tôi sửa đổi sự kiện
để bao gồm/loại trừ EL0 khi thích hợp dựa trên loại trừ_host và
thuộc tính loại trừ_khách.

Các câu lệnh trên cũng được áp dụng khi các thuộc tính này được sử dụng trong một
tuy nhiên, khách không phải là VHE, xin lưu ý rằng EL2 không bao giờ được tính trong một khách.


Sự chính xác
--------

Trên các máy chủ không phải VHE, chúng tôi bật/tắt bộ đếm khi vào/ra máy chủ/khách
chuyển đổi tại EL2 - tuy nhiên có một khoảng thời gian giữa
bật/tắt quầy và vào/ra khách. Chúng tôi là
có thể loại bỏ các bộ đếm sự kiện chủ nhà trên ranh giới của khách
vào/ra khi đếm sự kiện của khách bằng cách lọc ra EL2 cho
loại trừ_host. Tuy nhiên khi sử dụng !exclude_hv có một chút mất điện
cửa sổ tại lối vào/ra của khách, nơi các sự kiện chủ nhà không được ghi lại.

Trên hệ thống VHE không có cửa sổ tắt.

Perf Userspace PMU Truy cập bộ đếm phần cứng
==========================================

Tổng quan
--------
Công cụ không gian người dùng hoàn hảo dựa trên PMU để theo dõi các sự kiện. Nó cung cấp một
lớp trừu tượng trên các bộ đếm phần cứng vì lớp bên dưới
việc thực hiện phụ thuộc vào cpu.
Arm64 cho phép các công cụ không gian người dùng có quyền truy cập vào các thanh ghi lưu trữ
giá trị của bộ đếm phần cứng trực tiếp.

Điều này nhắm mục tiêu cụ thể đến các nhiệm vụ tự giám sát để giảm chi phí
bằng cách truy cập trực tiếp vào các thanh ghi mà không cần phải thông qua kernel.

Làm cách nào để
------
Tiêu điểm được đặt trên armv8 PMUv3 để đảm bảo rằng quyền truy cập vào pmu
đăng ký được kích hoạt và không gian người dùng có quyền truy cập vào các thông tin liên quan
thông tin để sử dụng chúng.

Để có quyền truy cập vào bộ đếm phần cứng, hệ thống toàn cầu
kernel/perf_user_access trước tiên phải được bật:

.. code-block:: sh

  echo 1 > /proc/sys/kernel/perf_user_access

Cần mở sự kiện bằng giao diện công cụ hoàn hảo với config1:1
tập bit attr: tòa nhà sys_perf_event_open trả về một fd có thể
sau đó được sử dụng với syscall mmap để truy xuất một trang bộ nhớ
chứa thông tin về sự kiện. Trình điều khiển PMU sử dụng trang này để hiển thị
cho người dùng chỉ mục của bộ đếm phần cứng và các dữ liệu cần thiết khác. Sử dụng cái này
chỉ mục cho phép người dùng truy cập vào các thanh ghi PMU bằng lệnh ZZ0000ZZ.
Quyền truy cập vào các thanh ghi PMU chỉ hợp lệ khi khóa trình tự không thay đổi.
Đặc biệt, thanh ghi PMSELR_EL0 sẽ về 0 mỗi lần khóa trình tự được thực hiện.
đã thay đổi.

Quyền truy cập không gian người dùng được hỗ trợ trong libperf bằng cách sử dụng perf_evsel__mmap()
và các hàm perf_evsel__read(). Xem ZZ0000ZZ để biết
một ví dụ

Về hệ thống không đồng nhất
---------------------------
Trên các hệ thống không đồng nhất như big.LITTLE, quyền truy cập bộ đếm PMU của không gian người dùng có thể
chỉ được kích hoạt khi các tác vụ được ghim vào một tập hợp con đồng nhất của các lõi và
phiên bản PMU tương ứng được mở bằng cách chỉ định thuộc tính 'type'.
Việc sử dụng các loại sự kiện chung không được hỗ trợ trong trường hợp này.

Hãy xem ZZ0000ZZ để biết ví dụ. Nó
có thể được chạy bằng công cụ hoàn hảo để kiểm tra xem quyền truy cập vào sổ đăng ký có hoạt động không
chính xác từ không gian người dùng:

.. code-block:: sh

  perf test -v user

Giới thiệu về các sự kiện được xâu chuỗi và kích thước bộ đếm
--------------------------------------
Người dùng có thể yêu cầu 32-bit (config1:0 == 0) hoặc 64-bit (config1:0 == 1)
truy cập cùng với quyền truy cập không gian người dùng. Tòa nhà sys_perf_event_open sẽ thất bại
nếu bộ đếm 64 bit được yêu cầu và phần cứng không hỗ trợ 64 bit
quầy. Các sự kiện theo chuỗi không được hỗ trợ cùng với bộ đếm không gian người dùng
truy cập. Nếu bộ đếm 32 bit được yêu cầu trên phần cứng có bộ đếm 64 bit thì
không gian người dùng phải coi 32 bit trên được đọc từ bộ đếm là UNKNOWN. các
Trường 'pmc_width' trong trang người dùng sẽ cho biết chiều rộng hợp lệ của bộ đếm
và nên được sử dụng để che các bit phía trên khi cần thiết.

.. Links
.. _tools/perf/arch/arm64/tests/user-events.c:
   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/tools/perf/arch/arm64/tests/user-events.c
.. _tools/lib/perf/tests/test-evsel.c:
   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/tools/lib/perf/tests/test-evsel.c

Ngưỡng đếm sự kiện
==========================================

Tổng quan
--------

FEAT_PMUv3_TH (Armv8.8) cho phép bộ đếm PMU chỉ tăng trên
các sự kiện có số lượng đáp ứng một điều kiện ngưỡng được chỉ định. Ví dụ nếu
ngưỡng_compare được đặt thành 2 ("Lớn hơn hoặc bằng") và
ngưỡng được đặt thành 2, thì bộ đếm PMU bây giờ sẽ chỉ tăng thêm
khi một sự kiện trước đó đã tăng bộ đếm PMU lên 2 hoặc
nhiều hơn trong một chu kỳ xử lý.

Để tăng thêm 1 sau khi vượt qua điều kiện ngưỡng thay vì
số sự kiện trong chu kỳ đó, hãy thêm tùy chọn 'threshold_count' vào
dòng lệnh.

Làm cách nào để
------

Đây là các tham số để kiểm soát tính năng:

.. list-table::
   :header-rows: 1

   * - Parameter
     - Description
   * - threshold
     - Value to threshold the event by. A value of 0 means that
       thresholding is disabled and the other parameters have no effect.
   * - threshold_compare
     - | Comparison function to use, with the following values supported:
       |
       | 0: Not-equal
       | 1: Equals
       | 2: Greater-than-or-equal
       | 3: Less-than
   * - threshold_count
     - If this is set, count by 1 after passing the threshold condition
       instead of the value of the event on this cycle.

Các giá trị ngưỡng, ngưỡng_so sánh và ngưỡng_count có thể là
được cung cấp cho mỗi sự kiện, ví dụ:

.. code-block:: sh

  perf stat -e stall_slot/threshold=2,threshold_compare=2/ \
            -e dtlb_walk/threshold=10,threshold_compare=3,threshold_count/

Trong ví dụ này, sự kiện gian_slot sẽ được tính bằng 2 hoặc nhiều hơn trên mỗi
chu kỳ xảy ra 2 hoặc nhiều gian hàng. Và dtlb_walk sẽ đếm bằng 1 trên
mỗi chu kỳ có số lần đi dtlb nhỏ hơn 10.

Giá trị ngưỡng được hỗ trợ tối đa có thể được đọc từ giới hạn của mỗi
PMU, ví dụ:

.. code-block:: sh

  cat /sys/bus/event_source/devices/armv8_pmuv3/caps/threshold_max

  0x000000ff

Nếu giá trị cao hơn giá trị này được đưa ra thì việc mở sự kiện sẽ dẫn đến
trong một lỗi. Mức tối đa cao nhất có thể là 4095, vì trường cấu hình
vì ngưỡng được giới hạn ở 12 bit và công cụ Perf sẽ từ chối
phân tích các giá trị cao hơn.

Nếu PMU không hỗ trợ FEAT_PMUv3_TH thì ngưỡng_max sẽ đọc
0 và việc cố gắng đặt giá trị ngưỡng cũng sẽ gây ra lỗi.
ngưỡng_max cũng sẽ đọc là 0 trên aarch32 khách, ngay cả khi chủ nhà
đang chạy trên phần cứng có tính năng này.