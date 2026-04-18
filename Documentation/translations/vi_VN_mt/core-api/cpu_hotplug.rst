.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/cpu_hotplug.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Hotplug CPU trong Kernel
=========================

:Ngày: Tháng 9 năm 2021
:Tác giả: Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
         Rusty Russell <rusty@rustcorp.com.au>,
         Srivatsa Vaddagiri <vatsa@in.ibm.com>,
         Ashok Raj <ashok.raj@intel.com>,
         Joel Schopp <jschopp@austin.ibm.com>,
	 Thomas Gleixner <tglx@kernel.org>

Giới thiệu
============

Những tiến bộ hiện đại trong kiến trúc hệ thống đã gây ra lỗi nâng cao
khả năng báo cáo và sửa lỗi trong bộ xử lý. Có vài OEMS đó
hỗ trợ phần cứng NUMA có khả năng cắm nóng, trong đó nút vật lý
chèn và gỡ bỏ yêu cầu hỗ trợ cho phích cắm nóng CPU.

Những tiến bộ như vậy yêu cầu các CPU có sẵn trong hạt nhân phải được loại bỏ để
lý do cung cấp hoặc vì mục đích của RAS để ngăn chặn CPU vi phạm
đường dẫn thực thi hệ thống. Do đó cần có hỗ trợ cắm nóng CPU trong
Hạt nhân Linux.

Một cách sử dụng mới hơn của hỗ trợ CPU-hotplug là việc sử dụng nó ngày nay trong sơ yếu lý lịch tạm dừng
hỗ trợ cho SMP. Hỗ trợ lõi kép và HT giúp ngay cả máy tính xách tay cũng chạy được nhân SMP
không hỗ trợ các phương pháp này.


Công tắc dòng lệnh
=====================
ZZ0000ZZ
  Hạn chế thời gian khởi động của CPU ở ZZ0002ZZ. Giả sử bạn có bốn CPU, sử dụng
  ZZ0001ZZ sẽ chỉ khởi động được hai. Bạn có thể chọn mang theo
  các CPU khác sau đó sẽ trực tuyến.

ZZ0000ZZ
  Hạn chế tổng số lượng CPU mà kernel sẽ hỗ trợ. Nếu số
  được cung cấp ở đây thấp hơn số lượng CPU vật lý sẵn có, thì
  những CPU đó sau này không thể được đưa lên mạng.

ZZ0000ZZ
  Tùy chọn này đặt các bit ZZ0001ZZ trong ZZ0002ZZ.

Tùy chọn này được giới hạn ở kiến ​​trúc X86 và S390.

ZZ0000ZZ
  Cho phép tắt CPU0.

Tùy chọn này được giới hạn ở kiến ​​trúc X86.

Bản đồ CPU
========

ZZ0000ZZ
  Bitmap của các CPU có thể có sẵn trong
  hệ thống. Điều này được sử dụng để phân bổ một số bộ nhớ thời gian khởi động cho các biến per_cpu
  không được thiết kế để tăng/thu nhỏ khi CPU được cung cấp hoặc loại bỏ.
  Sau khi được đặt trong giai đoạn khám phá thời gian khởi động, bản đồ sẽ ở trạng thái tĩnh, tức là không có bit nào
  được thêm vào hoặc loại bỏ bất cứ lúc nào. Cắt tỉa chính xác cho nhu cầu hệ thống của bạn
  trả trước có thể tiết kiệm một số bộ nhớ thời gian khởi động.

ZZ0000ZZ
  Bitmap của tất cả các CPU hiện đang trực tuyến. Nó được đặt trong ZZ0001ZZ
  sau khi CPU có sẵn để lập lịch kernel và sẵn sàng nhận
  ngắt từ các thiết bị. Nó bị xóa khi CPU bị hạ xuống bằng cách sử dụng
  ZZ0002ZZ, trước đó tất cả các dịch vụ hệ điều hành bao gồm cả các ngắt đều được
  đã di chuyển sang mục tiêu khác CPU.

ZZ0000ZZ
  Bitmap của CPU hiện có trong hệ thống. Không phải tất cả
  trong số họ có thể trực tuyến. Khi phích cắm nóng vật lý được xử lý bởi bộ phận liên quan
  hệ thống con (ví dụ ACPI) có thể thay đổi và bit mới được thêm hoặc xóa
  từ bản đồ tùy theo sự kiện là thêm nóng/xóa nóng. Hiện tại có
  không có quy tắc khóa như bây giờ. Cách sử dụng thông thường là khởi tạo cấu trúc liên kết trong khi khởi động,
  lúc đó hotplug bị vô hiệu hóa.

Bạn thực sự không cần phải thao tác với bất kỳ bản đồ CPU nào của hệ thống. Họ nên
ở chế độ chỉ đọc cho hầu hết mục đích sử dụng. Khi thiết lập tài nguyên trên mỗi CPU hầu như luôn sử dụng
ZZ0000ZZ hoặc ZZ0001ZZ để lặp lại. Để vĩ mô
ZZ0002ZZ có thể được sử dụng để lặp lại mặt nạ CPU tùy chỉnh.

Không bao giờ sử dụng bất cứ thứ gì khác ngoài ZZ0000ZZ để thể hiện bitmap của CPU.


Sử dụng phích cắm nóng CPU
=================

Tùy chọn kernel ZZ0000ZZ cần được bật. Hiện tại nó đang
có sẵn trên nhiều kiến trúc bao gồm ARM, MIPS, PowerPC và X86. các
cấu hình được thực hiện thông qua giao diện sysfs ::

$ ls -lh /sys/devices/system/cpu
 tổng 0
 drwxr-xr-x 9 gốc gốc 0 21 tháng 12 16:33 cpu0
 drwxr-xr-x 9 gốc gốc 0 21/12 16:33 cpu1
 drwxr-xr-x 9 gốc gốc 0 21/12 16:33 cpu2
 drwxr-xr-x 9 gốc gốc 0 21/12 16:33 cpu3
 drwxr-xr-x 9 gốc gốc 0 21/12 16:33 cpu4
 drwxr-xr-x 9 gốc gốc 0 21/12 16:33 cpu5
 drwxr-xr-x 9 gốc gốc 0 21/12 16:33 cpu6
 drwxr-xr-x 9 gốc gốc 0 21/12 16:33 cpu7
 drwxr-xr-x 2 root root 0 21 tháng 12 16:33 hotplug
 -r--r--r-- 1 root 4.0K 21/12 16:33 nhé
 -r--r--r-- 1 root gốc 4.0K 21/12 16:33 trực tuyến
 -r--r--r-- 1 root root 4.0K 21/12 16:33 có thể
 -r--r--r-- 1 gốc 4.0K 21/12 16:33 hiện tại

Các tệp ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ đại diện cho mặt nạ CPU.
Mỗi thư mục CPU chứa tệp ZZ0004ZZ điều khiển logic trên (1) và
trạng thái tắt (0). Để tắt CPU4 một cách hợp lý::

$ echo 0 > /sys/devices/system/cpu/cpu4/online
  smpboot: CPU 4 hiện đang ngoại tuyến

Sau khi CPU tắt, nó sẽ bị xóa khỏi ZZ0000ZZ,
ZZ0001ZZ và cũng không được hiển thị bằng lệnh ZZ0002ZZ. Đến
đưa CPU4 trực tuyến trở lại::

$ echo 1 > /sys/devices/system/cpu/cpu4/online
 smpboot: Khởi động Bộ xử lý Node 0 4 APIC 0x1

CPU có thể sử dụng lại được. Điều này sẽ hoạt động trên tất cả các CPU, nhưng CPU0 thường đặc biệt
và bị loại trừ khỏi phích cắm nóng CPU.

Sự phối hợp hotplug CPU
============================

Trường hợp ngoại tuyến
----------------

Khi CPU đã được tắt một cách hợp lý các lệnh gọi lại đã đăng ký
trạng thái cắm nóng sẽ được gọi, bắt đầu bằng ZZ0000ZZ và kết thúc
ở trạng thái ZZ0001ZZ. Điều này bao gồm:

* Nếu tác vụ bị treo do hoạt động tạm dừng thì ZZ0001ZZ
  sẽ được đặt thành đúng.
* Tất cả các quy trình được di chuyển khỏi CPU cũ này sang CPU mới.
  CPU mới được chọn từ bộ CPU hiện tại của mỗi quy trình, có thể là
  một tập hợp con của tất cả các CPU trực tuyến.
* Tất cả các ngắt được nhắm mục tiêu tới CPU này sẽ được di chuyển sang CPU mới
* bộ tính giờ cũng được di chuyển sang CPU mới
* Sau khi tất cả các dịch vụ được di chuyển, kernel sẽ gọi một quy trình cụ thể của Arch
  ZZ0000ZZ để thực hiện dọn dẹp vòm cụ thể.


Ổ cắm nóng CPU API
===================

Máy trạng thái cắm nóng CPU
-------------------------

Hotplug CPU sử dụng máy trạng thái tầm thường với không gian trạng thái tuyến tính từ
CPUHP_OFFLINE đến CPUHP_ONLINE. Mỗi tiểu bang có một công ty khởi nghiệp và một công ty phá bỏ
gọi lại.

Khi CPU được trực tuyến, các lệnh gọi lại khởi động sẽ được gọi tuần tự cho đến khi
đạt đến trạng thái CPUHP_ONLINE. Chúng cũng có thể được gọi khi
lệnh gọi lại của một trạng thái được thiết lập hoặc một phiên bản được thêm vào nhiều phiên bản
trạng thái.

Khi CPU ngoại tuyến, lệnh gọi lại phân tách sẽ được gọi ngược lại
đặt hàng tuần tự cho đến khi đạt đến trạng thái CPUHP_OFFLINE. Họ cũng có thể
được gọi khi lệnh gọi lại của một trạng thái bị xóa hoặc một thể hiện bị
được loại bỏ khỏi trạng thái đa phiên bản.

Nếu một trang sử dụng chỉ yêu cầu gọi lại theo một hướng của hotplug
hoạt động (CPU trực tuyến hoặc CPU ngoại tuyến) sau đó gọi lại không bắt buộc khác
có thể được đặt thành NULL khi trạng thái được thiết lập.

Không gian trạng thái được chia thành ba phần:

* Phần PREPARE

Phần PREPARE bao gồm không gian trạng thái từ CPUHP_OFFLINE tới
  CPUHP_BRINGUP_CPU.

Các cuộc gọi lại khởi động trong phần này được gọi trước khi CPU được
  bắt đầu trong quá trình hoạt động trực tuyến CPU. Các cuộc gọi lại phân tích được gọi
  sau khi CPU không hoạt động trong quá trình hoạt động ngoại tuyến CPU.

Các cuộc gọi lại được gọi trên CPU điều khiển vì rõ ràng chúng không thể chạy được
  CPU được cắm nóng chưa được khởi động hoặc đã trở thành
  đã rối loạn chức năng rồi.

Lệnh gọi lại khởi động được sử dụng để thiết lập các tài nguyên cần thiết để
  mang CPU trực tuyến thành công. Các cuộc gọi lại phân tích được sử dụng để giải phóng
  tài nguyên hoặc để chuyển công việc đang chờ xử lý sang CPU trực tuyến sau khi cắm nóng
  CPU trở nên rối loạn chức năng.

Các cuộc gọi lại khởi động được phép thất bại. Nếu cuộc gọi lại không thành công, CPU
  hoạt động trực tuyến bị hủy bỏ và CPU được đưa xuống phiên bản trước đó
  lại trạng thái (thường là CPUHP_OFFLINE).

Các cuộc gọi lại phân tích trong phần này không được phép thất bại.

* Phần STARTING

Phần STARTING bao gồm không gian trạng thái giữa CPUHP_BRINGUP_CPU + 1
  và CPUHP_AP_ONLINE.

Lệnh gọi lại khởi động trong phần này được gọi trên CPU đã được cắm nóng
  với các ngắt bị vô hiệu hóa trong quá trình hoạt động trực tuyến CPU ở CPU đầu tiên
  mã thiết lập. Các cuộc gọi lại phân tích được gọi với các ngắt bị vô hiệu hóa
  trên CPU được cắm nóng trong khi CPU hoạt động ngoại tuyến ngay trước khi
  CPU đã tắt hoàn toàn.

Các cuộc gọi lại trong phần này không được phép thất bại.

Các lệnh gọi lại được sử dụng để khởi tạo/tắt phần cứng ở mức độ thấp và
  cho các hệ thống con cốt lõi.

* Phần ONLINE

Phần ONLINE bao gồm không gian trạng thái giữa CPUHP_AP_ONLINE + 1 và
  CPUHP_ONLINE.

Lệnh gọi lại khởi động trong phần này được gọi trên CPU đã được cắm nóng
  trong quá trình hoạt động trực tuyến CPU. Các cuộc gọi lại phân tách được gọi trên
  đã cắm nóng CPU trong khi CPU hoạt động ngoại tuyến.

Các lệnh gọi lại được gọi trong ngữ cảnh của mỗi luồng cắm nóng CPU,
  được ghim trên CPU đã được cắm nóng. Các cuộc gọi lại được gọi với
  ngắt và kích hoạt quyền ưu tiên.

Các cuộc gọi lại được phép thất bại. Khi một cuộc gọi lại không thành công trong hotplug
  hoạt động bị hủy bỏ và CPU được đưa trở lại trạng thái trước đó.

CPU hoạt động trực tuyến/ngoại tuyến
-----------------------------

Một hoạt động trực tuyến thành công trông như thế này::

[CPUHP_OFFLINE]
  [CPUHP_OFFLINE + 1]->khởi động() -> thành công
  [CPUHP_OFFLINE + 2]->khởi động() -> thành công
  [CPUHP_OFFLINE + 3] -> bị bỏ qua vì khởi động == NULL
  ...
[CPUHP_BRINGUP_CPU]->khởi động() -> thành công
  === Kết thúc phần PREPARE
  [CPUHP_BRINGUP_CPU + 1]->khởi động() -> thành công
  ...
[CPUHP_AP_ONLINE]->khởi động() -> thành công
  === Kết thúc phần STARTUP
  [CPUHP_AP_ONLINE + 1]->khởi động() -> thành công
  ...
[CPUHP_ONLINE - 1]->khởi động() -> thành công
  [CPUHP_ONLINE]

Hoạt động ngoại tuyến thành công trông như thế này::

[CPUHP_ONLINE]
  [CPUHP_ONLINE - 1]->teardown() -> thành công
  ...
[CPUHP_AP_ONLINE + 1]->teardown() -> thành công
  === Bắt đầu phần STARTUP
  [CPUHP_AP_ONLINE]->teardown() -> thành công
  ...
[CPUHP_BRINGUP_ONLINE - 1]->phân tích()
  ...
=== Bắt đầu phần PREPARE
  [CPUHP_BRINGUP_CPU]->phân tích()
  [CPUHP_OFFLINE + 3]->phân tích()
  [CPUHP_OFFLINE + 2] -> bị bỏ qua vì bị hỏng == NULL
  [CPUHP_OFFLINE + 1]->phân tích()
  [CPUHP_OFFLINE]

Một hoạt động trực tuyến không thành công trông như thế này::

[CPUHP_OFFLINE]
  [CPUHP_OFFLINE + 1]->khởi động() -> thành công
  [CPUHP_OFFLINE + 2]->khởi động() -> thành công
  [CPUHP_OFFLINE + 3] -> bị bỏ qua vì khởi động == NULL
  ...
[CPUHP_BRINGUP_CPU]->khởi động() -> thành công
  === Kết thúc phần PREPARE
  [CPUHP_BRINGUP_CPU + 1]->khởi động() -> thành công
  ...
[CPUHP_AP_ONLINE]->khởi động() -> thành công
  === Kết thúc phần STARTUP
  [CPUHP_AP_ONLINE + 1]->khởi động() -> thành công
  ---
  [CPUHP_AP_ONLINE + N]->khởi động() -> thất bại
  [CPUHP_AP_ONLINE + (N - 1)]->phân tích()
  ...
[CPUHP_AP_ONLINE + 1]->phân tích()
  === Bắt đầu phần STARTUP
  [CPUHP_AP_ONLINE]->phân tích()
  ...
[CPUHP_BRINGUP_ONLINE - 1]->phân tích()
  ...
=== Bắt đầu phần PREPARE
  [CPUHP_BRINGUP_CPU]->phân tích()
  [CPUHP_OFFLINE + 3]->phân tích()
  [CPUHP_OFFLINE + 2] -> bị bỏ qua vì bị hỏng == NULL
  [CPUHP_OFFLINE + 1]->phân tích()
  [CPUHP_OFFLINE]

Thao tác ngoại tuyến không thành công trông như thế này::

[CPUHP_ONLINE]
  [CPUHP_ONLINE - 1]->teardown() -> thành công
  ...
[CPUHP_ONLINE - N]->teardown() -> thất bại
  [CPUHP_ONLINE - (N - 1)]->khởi động()
  ...
[CPUHP_ONLINE - 1]->khởi động()
  [CPUHP_ONLINE]

Thất bại đệ quy không thể được xử lý một cách hợp lý. Nhìn vào những điều sau đây
ví dụ về lỗi đệ quy do thao tác ngoại tuyến không thành công: ::

[CPUHP_ONLINE]
  [CPUHP_ONLINE - 1]->teardown() -> thành công
  ...
[CPUHP_ONLINE - N]->teardown() -> thất bại
  [CPUHP_ONLINE - (N - 1)]->startup() -> thành công
  [CPUHP_ONLINE - (N - 2)]->khởi động() -> thất bại

Máy trạng thái cắm nóng CPU dừng ngay tại đây và không cố gắng quay lại
lại vì điều đó có thể dẫn đến một vòng lặp vô tận::

[CPUHP_ONLINE - (N - 1)]->teardown() -> thành công
  [CPUHP_ONLINE - N]->teardown() -> thất bại
  [CPUHP_ONLINE - (N - 1)]->startup() -> thành công
  [CPUHP_ONLINE - (N - 2)]->khởi động() -> thất bại
  [CPUHP_ONLINE - (N - 1)]->teardown() -> thành công
  [CPUHP_ONLINE - N]->teardown() -> thất bại

Tạo bọt, rửa sạch và lặp lại. Trong trường hợp này, CPU vẫn ở trạng thái::

[CPUHP_ONLINE - (N - 1)]

điều này ít nhất cũng cho phép hệ thống tiến bộ và mang đến cho người dùng cơ hội
gỡ lỗi hoặc thậm chí giải quyết tình huống.

Phân bổ một trạng thái
------------------

Có hai cách để phân bổ trạng thái cắm nóng CPU:

* Phân bổ tĩnh

Phân bổ tĩnh phải được sử dụng khi hệ thống con hoặc trình điều khiển có
  yêu cầu đặt hàng so với các trạng thái cắm nóng CPU khác. Ví dụ. lõi PERF
  cuộc gọi lại khởi động phải được gọi trước khi khởi động trình điều khiển PERF
  gọi lại trong quá trình hoạt động trực tuyến CPU. Trong quá trình hoạt động ngoại tuyến CPU
  lệnh gọi lại phân tách trình điều khiển phải được gọi trước khi phân tích lõi
  gọi lại. Các trạng thái được phân bổ tĩnh được mô tả bằng các hằng số trong
  enum cpuhp_state có thể tìm thấy trong include/linux/cpuhotplug.h.

Chèn trạng thái vào enum ở vị trí thích hợp để sắp xếp thứ tự
  yêu cầu được đáp ứng. Hằng số trạng thái phải được sử dụng cho trạng thái
  thiết lập và gỡ bỏ.

Phân bổ tĩnh cũng được yêu cầu khi không đặt lệnh gọi lại trạng thái
  khởi động trong thời gian chạy và là một phần của trình khởi tạo trạng thái cắm nóng CPU
  mảng trong kernel/cpu.c.

* Phân bổ động

Khi không có yêu cầu đặt hàng nào cho các cuộc gọi lại trạng thái thì
  phân bổ động là phương pháp ưa thích. Số trạng thái được phân bổ
  bởi chức năng thiết lập và trả lại cho người gọi thành công.

Chỉ các phần PREPARE và ONLINE cung cấp phân bổ động
  phạm vi. Phần STARTING không giống như hầu hết các cuộc gọi lại trong đó
  phần có yêu cầu đặt hàng rõ ràng.

Thiết lập trạng thái cắm nóng CPU
----------------------------

Mã lõi cung cấp các chức năng sau để thiết lập trạng thái:

* cpuhp_setup_state(trạng thái, tên, khởi động, phân tích)
* cpuhp_setup_state_nocalls(trạng thái, tên, khởi động, phân tích)
* cpuhp_setup_state_cpuslocked(trạng thái, tên, khởi động, phân tích)
* cpuhp_setup_state_nocalls_cpuslocked(trạng thái, tên, khởi động, phân tích)

Đối với trường hợp trình điều khiển hoặc hệ thống con có nhiều phiên bản và giống nhau
Cần gọi lại các lệnh gọi lại trạng thái cắm nóng CPU cho từng phiên bản, CPU
lõi hotplug cung cấp hỗ trợ đa phiên bản. Lợi thế hơn người lái xe
danh sách phiên bản cụ thể là các chức năng liên quan đến phiên bản được cung cấp đầy đủ
được tuần tự hóa dựa trên các hoạt động cắm nóng CPU và cung cấp tính năng tự động
lời gọi các lệnh gọi lại trạng thái khi thêm và xóa. Để thiết lập một
trạng thái đa phiên bản, chức năng sau có sẵn:

* cpuhp_setup_state_multi(trạng thái, tên, khởi động, phân tích)

Đối số @state là trạng thái được phân bổ tĩnh hoặc một trong các trạng thái
hằng số cho các trạng thái được phân bổ động - CPUHP_BP_PREPARE_DYN,
CPUHP_AP_ONLINE_DYN - tùy thuộc vào phần trạng thái (PREPARE, ONLINE) cho
trạng thái động nào cần được phân bổ.

Đối số @name được sử dụng cho đầu ra sysfs và cho thiết bị đo đạc. các
quy ước đặt tên là "subsys:mode" hoặc "subsys/driver:mode",
ví dụ: "perf:mode" hoặc "perf/x86:mode". Tên chế độ phổ biến là:

=====================================================================
chuẩn bị cho các trạng thái trong phần PREPARE

đã chết Đối với các trạng thái trong phần PREPARE không cung cấp
         cuộc gọi lại khởi động

bắt đầu Đối với các trạng thái trong phần STARTING

chết Đối với các trạng thái trong phần STARTING không cung cấp
         cuộc gọi lại khởi động

trực tuyến Đối với các tiểu bang trong phần ONLINE

ngoại tuyến Đối với các trạng thái trong phần ONLINE không cung cấp
         cuộc gọi lại khởi động
=====================================================================

Vì đối số @name chỉ được sử dụng cho chế độ sysfs và thiết bị đo đạc khác
mô tả cũng có thể được sử dụng nếu chúng mô tả bản chất của trạng thái
tốt hơn những cái thông thường.

Ví dụ về đối số @name: "perf/online", "perf/x86:prepare",
"RCU/cây:đang chết", "đã lên lịch/chờ"

Đối số @startup là một con trỏ hàm tới lệnh gọi lại cần được thực hiện
được gọi trong hoạt động trực tuyến CPU. Nếu trang web sử dụng không yêu cầu
gọi lại khi khởi động đặt con trỏ thành NULL.

Đối số @teardown là một con trỏ hàm tới lệnh gọi lại sẽ
được gọi trong quá trình hoạt động ngoại tuyến CPU. Nếu trang web sử dụng không
yêu cầu gọi lại phân tách, đặt con trỏ thành NULL.

Các hàm này khác nhau ở cách xử lý các lệnh gọi lại đã cài đặt:

* cpuhp_setup_state_nocalls(), cpuhp_setup_state_nocalls_cpuslocked()
    và cpuhp_setup_state_multi() chỉ cài đặt các cuộc gọi lại

* cpuhp_setup_state() và cpuhp_setup_state_cpuslocked() cài đặt
    gọi lại và gọi lệnh gọi lại @startup (nếu không phải NULL) cho tất cả trực tuyến
    CPU hiện có trạng thái lớn hơn trạng thái mới được cài đặt
    trạng thái. Tùy thuộc vào phần trạng thái, lệnh gọi lại sẽ được gọi
    CPU hiện tại (phần PREPARE) hoặc trên mỗi CPU trực tuyến (ONLINE
    phần) trong ngữ cảnh của luồng cắm nóng của CPU.

Nếu lệnh gọi lại không thành công cho CPU N thì lệnh gọi lại phân tách cho CPU
    0 .. N-1 được gọi để khôi phục thao tác. Thiết lập trạng thái không thành công,
    các cuộc gọi lại cho trạng thái không được cài đặt và trong trường hợp động
    phân bổ trạng thái được phân bổ được giải phóng.

Thiết lập trạng thái và các lệnh gọi lại được tuần tự hóa theo CPU
hoạt động cắm nóng. Nếu chức năng thiết lập phải được gọi từ CPU
vùng bị khóa đọc hotplug thì các biến thể _cpuslocked() phải được
đã sử dụng. Không thể sử dụng các chức năng này từ bên trong lệnh gọi lại hotplug CPU.

Hàm trả về các giá trị:
  =================================================================================
  0 Trạng thái phân bổ tĩnh đã được thiết lập thành công

>0 Trạng thái phân bổ động đã được thiết lập thành công.

Số được trả về là số trạng thái đã được phân bổ. Nếu
           các cuộc gọi lại trạng thái phải được loại bỏ sau đó, ví dụ: mô-đun
           xóa thì số này phải được người gọi lưu lại và sử dụng
           làm đối số @state cho hàm xóa trạng thái. cho
           trạng thái đa trường hợp, số trạng thái được phân bổ động là
           cũng được yêu cầu làm đối số @state cho phiên bản thêm/xóa
           hoạt động.

<0 Thao tác không thành công
  =================================================================================

Loại bỏ trạng thái cắm nóng CPU
------------------------------

Để xóa trạng thái đã thiết lập trước đó, các chức năng sau được cung cấp:

* cpuhp_remove_state(trạng thái)
* cpuhp_remove_state_nocalls(trạng thái)
* cpuhp_remove_state_nocalls_cpuslocked(trạng thái)
* cpuhp_remove_multi_state(trạng thái)

Đối số @state là trạng thái được phân bổ tĩnh hoặc trạng thái
số được phân bổ trong phạm vi động bởi cpuhp_setup_state*(). Nếu
trạng thái nằm trong phạm vi động, khi đó số trạng thái được giải phóng và
có sẵn để phân bổ động một lần nữa.

Các hàm này khác nhau ở cách xử lý các lệnh gọi lại đã cài đặt:

* cpuhp_remove_state_nocalls(), cpuhp_remove_state_nocalls_cpuslocked()
    và cpuhp_remove_multi_state() chỉ xóa các cuộc gọi lại.

* cpuhp_remove_state() loại bỏ các lệnh gọi lại và thực hiện phân tích
    gọi lại (nếu không phải NULL) cho tất cả các CPU trực tuyến hiện có trạng thái
    lớn hơn trạng thái bị loại bỏ. Tùy thuộc vào phần tiểu bang
    gọi lại được gọi trên CPU hiện tại (phần PREPARE) hoặc trên
    mỗi CPU trực tuyến (phần ONLINE) trong bối cảnh hotplug của CPU
    chủ đề.

Để hoàn tất quá trình xóa, lệnh gọi lại phân tách sẽ không thành công.

Việc loại bỏ trạng thái và các lệnh gọi lại được tuần tự hóa theo CPU
hoạt động cắm nóng. Nếu chức năng xóa phải được gọi từ CPU
vùng bị khóa đọc hotplug thì các biến thể _cpuslocked() phải được
đã sử dụng. Không thể sử dụng các chức năng này từ bên trong lệnh gọi lại hotplug CPU.

Nếu trạng thái đa phiên bản bị xóa thì người gọi phải xóa tất cả
trường hợp đầu tiên.

Quản lý phiên bản trạng thái đa phiên bản
----------------------------------------

Khi trạng thái đa phiên bản được thiết lập, các phiên bản có thể được thêm vào
tiểu bang:

* cpuhp_state_add_instance(trạng thái, nút)
  * cpuhp_state_add_instance_nocalls(trạng thái, nút)

Đối số @state là trạng thái được phân bổ tĩnh hoặc trạng thái
số được phân bổ trong phạm vi động bởi cpuhp_setup_state_multi().

Đối số @node là một con trỏ tới hlist_node được nhúng trong
cấu trúc dữ liệu của instance. Con trỏ được trao cho đa thể hiện
gọi lại trạng thái và có thể được sử dụng bởi lệnh gọi lại để truy xuất phiên bản
thông qua container_of().

Các hàm này khác nhau ở cách xử lý các lệnh gọi lại đã cài đặt:

* cpuhp_state_add_instance_nocalls() và chỉ thêm phiên bản vào
    danh sách nút của trạng thái đa thể hiện.

* cpuhp_state_add_instance() thêm phiên bản và gọi quá trình khởi động
    gọi lại (nếu không phải NULL) được liên kết với @state cho tất cả các CPU trực tuyến
    hiện có trạng thái lớn hơn @state. Cuộc gọi lại chỉ
    được gọi cho phiên bản được thêm vào. Tùy thuộc vào phần tiểu bang
    cuộc gọi lại được gọi trên CPU hiện tại (phần PREPARE) hoặc
    trên mỗi CPU trực tuyến (phần ONLINE) trong bối cảnh hotplug của CPU
    chủ đề.

Nếu lệnh gọi lại không thành công cho CPU N thì lệnh gọi lại phân tách cho CPU
    0 .. N-1 được gọi để khôi phục thao tác, hàm không thành công và
    phiên bản này không được thêm vào danh sách nút của trạng thái đa phiên bản.

Để xóa một thể hiện khỏi danh sách nút của trạng thái, các chức năng này là
có sẵn:

* cpuhp_state_remove_instance(trạng thái, nút)
  * cpuhp_state_remove_instance_nocalls(trạng thái, nút)

Các đối số giống như đối với cpuhp_state_add_instance*()
các biến thể ở trên.

Các hàm này khác nhau ở cách xử lý các lệnh gọi lại đã cài đặt:

* cpuhp_state_remove_instance_nocalls() chỉ xóa phiên bản khỏi
    danh sách nút của trạng thái.

* cpuhp_state_remove_instance() xóa phiên bản và gọi
    Cuộc gọi lại phân tích (nếu không phải NULL) được liên kết với @state cho tất cả trực tuyến
    CPU hiện có trạng thái lớn hơn @state.  Cuộc gọi lại là
    chỉ được gọi cho trường hợp cần loại bỏ.  Tùy theo tiểu bang
    phần gọi lại được gọi trên CPU hiện tại (PREPARE
    phần) hoặc trên mỗi CPU trực tuyến (phần ONLINE) trong ngữ cảnh của
    Chủ đề cắm nóng của CPU.

Để hoàn tất quá trình xóa, lệnh gọi lại phân tách sẽ không thành công.

Các hoạt động thêm/xóa danh sách nút và các lệnh gọi lại là
được tuần tự hóa dựa trên các hoạt động cắm nóng CPU. Các chức năng này không thể được sử dụng
từ bên trong các lệnh gọi lại hotplug CPU và các vùng bị khóa đọc hotplug CPU.

Ví dụ
--------

Thiết lập và phân chia trạng thái được phân bổ tĩnh trong phần STARTING cho
thông báo về hoạt động trực tuyến và ngoại tuyến::

ret = cpuhp_setup_state(CPUHP_SUBSYS_STARTING, "subsys:starting", subsys_cpu_starting, subsys_cpu_dying);
   nếu (ret < 0)
        trở lại ret;
   ....
cpuhp_remove_state(CPUHP_SUBSYS_STARTING);

Thiết lập và phân chia trạng thái được phân bổ động trong phần ONLINE
để biết thông báo về hoạt động ngoại tuyến::

trạng thái = cpuhp_setup_state(CPUHP_AP_ONLINE_DYN, "subsys:offline", NULL, subsys_cpu_offline);
   nếu (trạng thái < 0)
       trạng thái trả về;
   ....
cpuhp_remove_state(trạng thái);

Thiết lập và phân chia trạng thái được phân bổ động trong phần ONLINE
để biết thông báo về các hoạt động trực tuyến mà không cần gọi lại::

trạng thái = cpuhp_setup_state_nocalls(CPUHP_AP_ONLINE_DYN, "subsys:online", subsys_cpu_online, NULL);
   nếu (trạng thái < 0)
       trạng thái trả về;
   ....
cpuhp_remove_state_nocalls(trạng thái);

Thiết lập, sử dụng và phân tách trạng thái đa phiên bản được phân bổ động trong
Phần ONLINE để thông báo về hoạt động trực tuyến và ngoại tuyến::

trạng thái = cpuhp_setup_state_multi(CPUHP_AP_ONLINE_DYN, "subsys:online", subsys_cpu_online, subsys_cpu_offline);
   nếu (trạng thái < 0)
       trạng thái trả về;
   ....
ret = cpuhp_state_add_instance(state, &inst1->node);
   nếu (ret)
        trở lại ret;
   ....
ret = cpuhp_state_add_instance(state, &inst2->node);
   nếu (ret)
        trở lại ret;
   ....
cpuhp_remove_instance(trạng thái, &inst1->nút);
   ....
cpuhp_remove_instance(trạng thái, &inst2->nút);
   ....
cpuhp_remove_multi_state(trạng thái);


Kiểm tra trạng thái cắm nóng
=========================

Một cách để xác minh xem trạng thái tùy chỉnh có hoạt động như mong đợi hay không là
tắt CPU rồi đưa nó lên mạng trở lại. Cũng có thể đặt CPU
sang trạng thái nhất định (ví dụ ZZ0000ZZ) và sau đó quay lại
ZZ0001ZZ. Điều này sẽ mô phỏng một trạng thái lỗi sau ZZ0002ZZ
điều này sẽ dẫn đến việc quay trở lại trạng thái trực tuyến.

Tất cả các trạng thái đã đăng ký được liệt kê trong ZZ0000ZZ ::

$ tail /sys/devices/system/cpu/hotplug/states
 138: mm/vmscan:trực tuyến
 139: mm/vmstat:trực tuyến
 140: lib/percpu_cnt:trực tuyến
 141: acpi/cpu-drv:trực tuyến
 142: base/cacheinfo:online
 143: virtio/net:trực tuyến
 144: x86/mce:trực tuyến
 145: printk:trực tuyến
 168: đã lên lịch:đang hoạt động
 169: trực tuyến

Để khôi phục CPU4 về ZZ0000ZZ và quay lại trực tuyến, chỉ cần thực hiện ::

$ cat /sys/devices/system/cpu/cpu4/hotplug/state
  169
  $ echo 140 > /sys/devices/system/cpu/cpu4/hotplug/target
  $ cat /sys/devices/system/cpu/cpu4/hotplug/state
  140

Điều quan trọng cần lưu ý là lệnh gọi lại của trạng thái 140 đã được
được gọi. Và bây giờ hãy trực tuyến trở lại::

$ echo 169 > /sys/devices/system/cpu/cpu4/hotplug/target
  $ cat /sys/devices/system/cpu/cpu4/hotplug/state
  169

Khi bật sự kiện theo dõi, các bước riêng lẻ cũng hiển thị::

#  ZZ0002ZZ-ZZ0003ZZ CPU#    ZZ0005ZZ FUNCTION
  #     ZZ0007ZZ ZZ0001ZZ |
      bash-394 [001] 22.976: cpuhp_enter: cpu: 0004 mục tiêu: 140 bước: 169 (cpuhp_kick_ap_work)
   cpuhp/4-31 [004] 22.977: cpuhp_enter: cpu: 0004 mục tiêu: 140 bước: 168 (sched_cpu_deactivate)
   cpuhp/4-31 [004] 22.990: cpuhp_exit: cpu: 0004 trạng thái: 168 bước: 168 ret: 0
   cpuhp/4-31 [004] 22.991: cpuhp_enter: cpu: 0004 mục tiêu: 140 bước: 144 (mce_cpu_pre_down)
   cpuhp/4-31 [004] 22.992: cpuhp_exit: cpu: 0004 trạng thái: 144 bước: 144 ret: 0
   cpuhp/4-31 [004] 22.993: cpuhp_multi_enter: cpu: 0004 mục tiêu: 140 bước: 143 (virtnet_cpu_down_prep)
   cpuhp/4-31 [004] 22.994: cpuhp_exit: cpu: 0004 trạng thái: 143 bước: 143 ret: 0
   cpuhp/4-31 [004] 22.995: cpuhp_enter: cpu: 0004 mục tiêu: 140 bước: 142 (cacheinfo_cpu_pre_down)
   cpuhp/4-31 [004] 22.996: cpuhp_exit: cpu: 0004 trạng thái: 142 bước: 142 ret: 0
      bash-394 [001] 22.997: cpuhp_exit: cpu: 0004 trạng thái: 140 bước: 169 ret: 0
      bash-394 [005] 95.540: cpuhp_enter: cpu: 0004 mục tiêu: 169 bước: 140 (cpuhp_kick_ap_work)
   cpuhp/4-31 [004] 95.541: cpuhp_enter: cpu: 0004 mục tiêu: 169 bước: 141 (acpi_soft_cpu_online)
   cpuhp/4-31 [004] 95.542: cpuhp_exit: cpu: 0004 trạng thái: 141 bước: 141 ret: 0
   cpuhp/4-31 [004] 95.543: cpuhp_enter: cpu: 0004 mục tiêu: 169 bước: 142 (cacheinfo_cpu_online)
   cpuhp/4-31 [004] 95.544: cpuhp_exit: cpu: 0004 trạng thái: 142 bước: 142 ret: 0
   cpuhp/4-31 [004] 95.545: cpuhp_multi_enter: cpu: 0004 mục tiêu: 169 bước: 143 (virtnet_cpu_online)
   cpuhp/4-31 [004] 95.546: cpuhp_exit: cpu: 0004 trạng thái: 143 bước: 143 ret: 0
   cpuhp/4-31 [004] 95.547: cpuhp_enter: cpu: 0004 mục tiêu: 169 bước: 144 (mce_cpu_online)
   cpuhp/4-31 [004] 95.548: cpuhp_exit: cpu: 0004 trạng thái: 144 bước: 144 ret: 0
   cpuhp/4-31 [004] 95.549: cpuhp_enter: cpu: 0004 mục tiêu: 169 bước: 145 (console_cpu_notify)
   cpuhp/4-31 [004] 95.550: cpuhp_exit: cpu: 0004 trạng thái: 145 bước: 145 ret: 0
   cpuhp/4-31 [004] 95.551: cpuhp_enter: cpu: 0004 mục tiêu: 169 bước: 168 (sched_cpu_activate)
   cpuhp/4-31 [004] 95.552: cpuhp_exit: cpu: 0004 trạng thái: 168 bước: 168 ret: 0
      bash-394 [005] 95.553: cpuhp_exit: cpu: 0004 trạng thái: 169 bước: 140 ret: 0

Như đã thấy, CPU4 đã ngừng hoạt động cho đến dấu thời gian 22.996 và sau đó sao lưu cho đến khi
95.552. Tất cả các cuộc gọi lại được gọi bao gồm cả mã trả về của chúng đều hiển thị trong
dấu vết.

Yêu cầu của kiến ​​trúc
===========================

Cần có các chức năng và cấu hình sau:

ZZ0000ZZ
  Mục này cần được kích hoạt trong Kconfig

ZZ0000ZZ
  Giao diện Arch để hiển thị CPU

ZZ0000ZZ
  Giao diện Arch để tắt CPU, không còn ngắt nào có thể được xử lý bởi
  kernel sau khi thói quen trở lại. Điều này bao gồm việc tắt bộ đếm thời gian.

ZZ0000ZZ
  Điều này thực sự được cho là để đảm bảo cái chết của CPU. Trên thực tế nhìn vào một số
  mã ví dụ trong vòm khác triển khai plugin nóng CPU. Bộ xử lý được lấy
  xuống từ vòng lặp ZZ0001ZZ cho kiến trúc cụ thể đó. ZZ0002ZZ
  thường đợi một số trạng thái per_cpu được thiết lập để đảm bảo bộ xử lý đã chết
  thói quen được gọi là chắc chắn tích cực.

Thông báo không gian người dùng
=======================

Sau khi CPU gửi các sự kiện udev trực tuyến hoặc ngoại tuyến thành công. Một quy tắc udev như::

SUBSYSTEM=="cpu", DRIVERS=="bộ xử lý", DEVPATH=="/devices/system/cpu/*", RUN+="the_hotplug_receiver.sh"

sẽ nhận được tất cả các sự kiện. Một kịch bản như::

#!/bin/sh

nếu [ "${ACTION}" = "ngoại tuyến" ]
  sau đó
      echo "CPU ${DEVPATH##*/} ngoại tuyến"

Elif [ "${ACTION}" = "trực tuyến" ]
  sau đó
      echo "CPU ${DEVPATH##*/} trực tuyến"

fi

có thể xử lý sự kiện thêm nữa.

Khi xảy ra thay đổi đối với CPU trong hệ thống, tệp sysfs
/sys/devices/system/cpu/crash_hotplug chứa '1' nếu kernel
cập nhật danh sách kernel chụp kdump của chính CPU (thông qua elfcorehdr và
phân đoạn kexec có liên quan khác) hoặc '0' nếu không gian người dùng phải cập nhật kdump
nắm bắt danh sách kernel của CPU.

Tính khả dụng phụ thuộc vào cấu hình kernel CONFIG_HOTPLUG_CPU
tùy chọn.

Để bỏ qua quá trình xử lý không gian người dùng của các sự kiện rút/cắm nóng CPU cho kdump
(tức là dỡ tải rồi tải lại để lấy danh sách CPU hiện tại), sysfs này
tập tin có thể được sử dụng trong quy tắc udev như sau:

SUBSYSTEM=="cpu", ATTRS{crash_hotplug}=="1", GOTO="kdump_reload_end"

Đối với sự kiện rút/cắm nóng CPU, nếu kiến trúc hỗ trợ cập nhật kernel
của elfcorehdr (chứa danh sách CPU) và các thông tin liên quan khác
kexec, thì quy tắc sẽ bỏ qua quá trình dỡ tải rồi tải lại của kdump
bắt hạt nhân.

Tài liệu tham khảo nội tuyến hạt nhân
======================================

.. kernel-doc:: include/linux/cpuhotplug.h
