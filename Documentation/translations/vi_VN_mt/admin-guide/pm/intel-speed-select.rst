.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/pm/intel-speed-select.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================================================
Hướng dẫn sử dụng công nghệ chọn tốc độ Intel(R)
=================================================================

Công nghệ chọn tốc độ Intel(R) (Intel(R) SST) cung cấp một giải pháp mới mạnh mẽ
tập hợp các tính năng giúp kiểm soát chi tiết hơn hiệu suất của CPU.
Với Intel(R) SST, một máy chủ có thể được cấu hình về sức mạnh và hiệu năng cho một
yêu cầu khối lượng công việc đa dạng.

Tham khảo các liên kết dưới đây để biết tổng quan về công nghệ:

-ZZ0000ZZ
-ZZ0001ZZ

Những khả năng này còn được nâng cao hơn nữa ở một số thế hệ phần mềm mới hơn.
nền tảng máy chủ nơi các tính năng này có thể được liệt kê và kiểm soát
động mà không cần cấu hình trước thông qua các tùy chọn thiết lập BIOS. Động lực này
cấu hình được thực hiện thông qua các lệnh hộp thư đến phần cứng. Một cách để liệt kê
và định cấu hình các tính năng này bằng cách sử dụng tiện ích Intel Speed Select.

Tài liệu này giải thích cách sử dụng công cụ Intel Speed Select để liệt kê và
kiểm soát các tính năng Intel(R) SST. Tài liệu này đưa ra các lệnh ví dụ và giải thích
các lệnh này thay đổi cấu hình sức mạnh và hiệu suất của hệ thống như thế nào
kiểm tra. Sử dụng công cụ này làm ví dụ, khách hàng có thể sao chép tin nhắn
được triển khai trong công cụ trong phần mềm sản xuất của họ.

công cụ cấu hình intel-speed-select
======================================

Hầu hết các gói phân phối Linux có thể bao gồm công cụ "intel-speed-select". Nếu không,
nó có thể được xây dựng bằng cách tải xuống cây nhân Linux từ kernel.org. Một lần
được tải xuống, công cụ này có thể được xây dựng mà không cần xây dựng kernel đầy đủ.

Từ cây kernel, chạy các lệnh sau ::

Công cụ # cd/power/x86/intel-speed-select/
# make
Cài đặt # make

Nhận trợ giúp
-------------

Để được trợ giúp về công cụ này, hãy thực hiện lệnh bên dưới::

# intel-speed-select --trợ giúp

Trợ giúp cấp cao nhất mô tả các đối số và tính năng. Chú ý rằng có một
cấu trúc trợ giúp đa cấp trong công cụ. Ví dụ: để nhận trợ giúp về tính năng "perf-profile"::

Hồ sơ hoàn hảo # intel-speed-select --trợ giúp

Để nhận trợ giúp về một lệnh, một cấp độ trợ giúp khác sẽ được cung cấp. Ví dụ: thông tin lệnh "thông tin"::

Thông tin hồ sơ hoàn hảo của # intel-speed-select --help

Tóm tắt khả năng nền tảng
------------------------------
Để kiểm tra khả năng của nền tảng và trình điều khiển hiện tại, hãy thực thi::

#intel-speed-select --thông tin

Ví dụ: trên hệ thống kiểm tra ::

# intel-speed-select --thông tin
 Intel(R) Speed Select Technology
 Executing on CPU model: X
 Platform: API version : 1
 Platform: Driver version : 1
 Platform: mbox supported : 1
 Platform: mmio supported : 1
 Hỗ trợ Intel(R) SST-PP (cấu hình hoàn hảo tính năng)
 Kiểm soát thay đổi cấp độ TDP đã được mở khóa, cấp độ tối đa: 4
 Hỗ trợ Intel(R) SST-TF (tính năng turbo-freq)
 Intel(R) SST-BF (tần số cơ sở tính năng) không được hỗ trợ
 Hỗ trợ Intel(R) SST-CP (sức mạnh lõi tính năng)

Công nghệ chọn tốc độ Intel(R) - Cấu hình hiệu suất (Intel(R) SST-PP)
------------------------------------------------------------------------

Tính năng này cho phép cấu hình máy chủ một cách linh hoạt dựa trên khối lượng công việc
yêu cầu về hiệu suất. Điều này giúp ích cho người dùng trong quá trình triển khai vì họ không có
để chọn một cấu hình máy chủ cụ thể một cách tĩnh.  Chọn tốc độ Intel(R) này
Công nghệ - Tính năng Performance Profile (Intel(R) SST-PP) giới thiệu cơ chế
cho phép nhiều cấu hình hiệu suất được tối ưu hóa trên mỗi hệ thống. Mỗi hồ sơ
xác định một bộ CPU cần trực tuyến và nghỉ ngơi ngoại tuyến để duy trì
tần số cơ bản được đảm bảo. Khi người dùng đưa ra lệnh để sử dụng một
hồ sơ hiệu suất và đáp ứng yêu cầu trực tuyến/ngoại tuyến của CPU, người dùng có thể mong đợi
sự thay đổi tần số cơ sở một cách linh hoạt. Tính năng này được gọi là
"Perf-profile" khi sử dụng công cụ Intel Speed Select.

Số lượng hoặc mức hiệu suất
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Có thể có nhiều hồ sơ hiệu suất trên một hệ thống. Để có được số lượng
profile, thực hiện lệnh bên dưới::

# intel-speed-select cấp độ get-config-profile hoàn hảo
 Công nghệ chọn tốc độ Intel(R)
 Thi công trên model CPU: X
 gói-0
  chết-0
    cpu-0
        cấp độ get-config:4
 gói-1
  chết-0
    cpu-14
        cấp độ get-config:4

Trên hệ thống đang được thử nghiệm này, có 4 cấu hình hiệu suất bên cạnh
hồ sơ hiệu suất cơ bản (là mức hiệu suất 0).

Trạng thái khóa/mở khóa
~~~~~~~~~~~~~~~~~~~~~~~

Ngay cả khi có nhiều hồ sơ hiệu suất, có thể chúng
đang bị khóa. Nếu chúng bị khóa, người dùng không thể ra lệnh thay đổi
trạng thái hiệu suất. Có thể đã có setup BIOS để mở khóa hoặc kiểm tra
với nhà cung cấp hệ thống của bạn.

Để kiểm tra xem hệ thống có bị khóa hay không, hãy thực hiện lệnh sau ::

# intel-speed-select trạng thái nhận khóa hồ sơ hoàn hảo
 Công nghệ chọn tốc độ Intel(R)
 Thi công trên model CPU: X
 gói-0
  chết-0
    cpu-0
        trạng thái khóa: 0
 gói-1
  chết-0
    cpu-14
        trạng thái khóa: 0

Trong trường hợp này, trạng thái khóa là 0, nghĩa là hệ thống đã được mở khóa.

Thuộc tính của mức hiệu suất
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Để có được các thuộc tính của mức hiệu suất cụ thể (Ví dụ: cấp 0, bên dưới), hãy thực hiện lệnh bên dưới ::

Thông tin hồ sơ hoàn hảo # intel-speed-select -l 0
 Công nghệ chọn tốc độ Intel(R)
 Thi công trên model CPU: X
 gói-0
  chết-0
    cpu-0
      hoàn hảo-profile-cấp-0
        số lượng CPU: 28
        kích hoạt mặt nạ CPU: 000003ff, f0003fff
        bật danh sách CPU: 0,1,2,3,4,5,6,7,8,9,10,11,12,13,28,29,30,31,32,33,34,35,36,37,38,39,40,41
        tỷ lệ nhiệt-thiết kế-công suất: 26
        tần số cơ bản (MHz): 2600
        tốc độ-chọn-turbo-freq: bị vô hiệu hóa
        tốc độ-chọn-cơ sở-tần số: bị vô hiệu hóa
	...
	...

Ở đây tùy chọn -l được sử dụng để chỉ định mức hiệu suất.

Nếu tùy chọn -l bị bỏ qua thì lệnh này sẽ in thông tin về tất cả
các mức hiệu suất. Lệnh trên là in các thuộc tính của
mức hiệu suất 0.

Đối với cấu hình hiệu suất này, danh sách CPU được hiển thị bởi
"enable-cpu-mask/enable-cpu-list" ở mức tối đa có thể là "trực tuyến". Khi đó
đáp ứng điều kiện thì có thể duy trì tần số cơ bản 2600 MHz. Đến
hiểu thêm, thực thi "thông tin hồ sơ hoàn hảo chọn tốc độ intel" để biết hiệu suất
cấp độ 4::

Thông tin hồ sơ hoàn hảo # intel-speed-select -l 4
 Công nghệ chọn tốc độ Intel(R)
 Thi công trên model CPU: X
 gói-0
  chết-0
    cpu-0
      hoàn hảo-hồ sơ-cấp 4
        số lượng CPU: 28
        kích hoạt mặt nạ CPU: 000000fa, f0000faf
        bật danh sách CPU: 0,1,2,3,5,7,8,9,10,11,28,29,30,31,33,35,36,37,38,39
        tỷ lệ nhiệt-thiết kế-công suất: 28
        tần số cơ bản (MHz): 2800
        tốc độ-chọn-turbo-freq: bị vô hiệu hóa
        tốc độ-chọn-cơ sở-tần số: không được hỗ trợ
	...
	...

Có ít CPU hơn trong "enable-cpu-mask/enable-cpu-list". Theo đó, nếu
người dùng chỉ giữ các CPU này trực tuyến và phần còn lại "ngoại tuyến", sau đó cơ sở
tần số được tăng lên 2,8 GHz so với 2,6 GHz ở mức hiệu suất 0.

Nhận mức hiệu suất hiện tại
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Để có được mức hiệu suất hiện tại, hãy thực thi::

# intel-speed-select hồ sơ hoàn hảo get-config-current-level
 Công nghệ chọn tốc độ Intel(R)
 Thi công trên model CPU: X
 gói-0
  chết-0
    cpu-0
        get-config-current_level:0

Trước tiên hãy xác minh rằng tần số cơ sở được hiển thị bởi sysfs cpufreq là chính xác ::

# cat/sys/thiết bị/system/cpu/cpu0/cpufreq/base_ần số
 2600000

Giá trị này khớp với giá trị trường tần số cơ sở (MHz) được hiển thị từ
Lệnh "thông tin hồ sơ hoàn hảo" cho mức hiệu suất 0 (tần số cpufreq ở mức
KHz).

Để kiểm tra xem tần số trung bình có bằng tần số cơ bản khi bận 100% không
khối lượng công việc, tắt turbo::

# echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo

Sau đó chạy một khối lượng công việc bận rộn trên tất cả các CPU, ví dụ::

#stress-c 64

Để xác minh tần số cơ bản, hãy chạy turbostat::

#turbostat -c 0-13 --show Gói, Core,CPU,Bzy_MHz -i 1

Gói lõi CPU Bzy_MHz
		- - 2600
  0 0 0 2600
  0 1 1 2600
  0 2 2 2600
  0 3 3 2600
  0 4 4 2600
  .		.	.	.


Thay đổi mức hiệu suất
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Để thay đổi mức hiệu suất thành 4, hãy thực hiện::

# intel-speed-select -d perf-profile set-config-level -l 4 -o
 Công nghệ chọn tốc độ Intel(R)
 Thi công trên model CPU: X
 gói-0
  chết-0
    cpu-0
      hồ sơ hoàn hảo
        set_tdp_level:thành công

Trong lệnh trên, "-o" là tùy chọn. Nếu nó được chỉ định thì nó cũng sẽ
CPU ngoại tuyến không có trong Enable_cpu_mask cho hiệu suất này
cấp độ.

Bây giờ nếu base_number được chọn ::

#cat/sys/thiết bị/system/cpu/cpu0/cpufreq/base_ần số
 2800000

Điều này cho thấy tần số cơ bản hiện đã tăng từ 2600 MHz khi hoạt động
mức 0 đến 2800 MHz ở mức hiệu suất 4. Do đó, bất kỳ khối lượng công việc nào có thể
sử dụng ít CPU hơn, có thể thấy mức tăng 200 MHz so với mức hiệu suất 0.

Thay đổi mức hiệu suất thông qua Giao diện BMC
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Có thể thay đổi cấp độ SST-PP bằng cách sử dụng tác nhân ngoài băng tần (OOB) (Thông qua một số
bảng điều khiển quản lý từ xa, thông qua BMC "Bộ điều khiển quản lý ván chân tường"
giao diện). Chế độ này được hỗ trợ từ bộ xử lý Sapphire Rapids
thế hệ. Thay đổi kernel và công cụ để hỗ trợ chế độ này được thêm vào Linux
phiên bản hạt nhân 5.18. Để kích hoạt tính năng này, cấu hình kernel
"CONFIG_INTEL_HFI_THERMAL" là bắt buộc. Phiên bản tối thiểu của công cụ
là "v1.12" để hỗ trợ tính năng này, một phần của nhân Linux phiên bản 5.18.

Để hỗ trợ cấu hình như vậy, công cụ này có thể được sử dụng làm daemon. Thêm
một tùy chọn dòng lệnh --oob::

# intel-speed-select --oob
 Công nghệ chọn tốc độ Intel(R)
 Đang thực thi trên model CPU:143[0x8f]
 Chế độ OOB được bật và sẽ chạy dưới dạng daemon

Ở chế độ này, công cụ sẽ điều khiển CPU trực tuyến/ngoại tuyến dựa trên hiệu suất mới
cấp độ.

Kiểm tra sự hiện diện của các tính năng Intel(R) SST khác
---------------------------------------------------------

Mỗi hồ sơ hiệu suất cũng xác định liệu có sự hỗ trợ của
hai tính năng Intel(R) SST khác (Công nghệ chọn tốc độ Intel(R) - Tần số cơ bản
(Intel(R) SST-BF) và Công nghệ chọn tốc độ Intel(R) - Tần số Turbo (Intel
SST-TF)).

Ví dụ: từ đầu ra của "thông tin hồ sơ hoàn hảo" ở trên, cho cấp 0 và cấp
4:

Đối với cấp độ 0::
       tốc độ-chọn-turbo-freq: bị vô hiệu hóa
       tốc độ-chọn-cơ sở-tần số: bị vô hiệu hóa

Đối với cấp độ 4::
       tốc độ-chọn-turbo-freq: bị vô hiệu hóa
       tốc độ-chọn-cơ sở-tần số: không được hỗ trợ

Với những kết quả này, "speed-select-base-freq" (Intel(R) SST-BF) ở cấp 4
đã thay đổi từ "bị vô hiệu hóa" thành "không được hỗ trợ" so với mức hiệu suất 0.

Điều này có nghĩa là ở mức hiệu suất 4, tính năng "tốc độ chọn tần số cơ bản" được
không được hỗ trợ. Tuy nhiên, ở mức hiệu suất 0, tính năng này được "hỗ trợ", nhưng
hiện "bị vô hiệu hóa", nghĩa là người dùng chưa kích hoạt tính năng này. Trong khi đó
"speed-select-turbo-freq" (Intel(R) SST-TF) được hỗ trợ ở cả hiệu suất
cấp độ, nhưng hiện tại không được người dùng kích hoạt.

Các tính năng Intel(R) SST-BF và Intel(R) SST-TF được xây dựng trên nền tảng
công nghệ có tên Intel(R) Speed Select Technology - Core Power (Intel(R) SST-CP).
Phần sụn nền tảng kích hoạt tính năng này khi Intel(R) SST-BF hoặc Intel(R) SST-TF
được hỗ trợ trên một nền tảng.

Intel(R) Speed ​​Select Technology Core Power (Intel(R) SST-CP)
---------------------------------------------------------------

Intel(R) Speed Select Technology Core Power (Intel(R) SST-CP) là một giao diện
cho phép người dùng xác định mức độ ưu tiên theo cốt lõi. Điều này xác định một cơ chế để phân phối
sức mạnh giữa các lõi khi có tình huống hạn chế về sức mạnh. Điều này xác định một
cấu hình lớp dịch vụ (CLOS).

Người dùng có thể định cấu hình tối đa 4 loại cấu hình dịch vụ. Mỗi nhóm CLOS
cấu hình cho phép xác định các tham số, ảnh hưởng đến tần số
có thể bị hạn chế và quyền lực được phân phối. Mỗi lõi CPU có thể được gắn với một lớp
dịch vụ và do đó là một ưu tiên liên quan. Độ chi tiết ở mức cốt lõi không
ở mức CPU.

Kích hoạt ưu tiên dựa trên CLOS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Để sử dụng tính năng ưu tiên dựa trên CLOS, phần sụn phải được thông báo để kích hoạt
và sử dụng loại ưu tiên. Có một loại ưu tiên mặc định cho mỗi nền tảng, trong đó
có thể được thay đổi bằng tham số dòng lệnh tùy chọn.

Để kích hoạt và kiểm tra các tùy chọn, hãy thực thi::

Kích hoạt năng lượng lõi # intel-speed-select --help
 Công nghệ chọn tốc độ Intel(R)
 Thi công trên model CPU: X
 Kích hoạt năng lượng cốt lõi cho gói/khuôn
	Đóng Kích hoạt: Chỉ định loại ưu tiên với [--priority|-p]
		 0: Tỷ lệ thuận, 1: Sắp xếp

Có hai loại loại ưu tiên:

- Đã đặt hàng

Mức độ ưu tiên cho việc điều chỉnh theo thứ tự được xác định dựa trên chỉ số được chỉ định
Nhóm CLOS. Trong đó CLOS0 được ưu tiên cao nhất (điều chỉnh cuối cùng).

Thứ tự ưu tiên là:
CLOS0 > CLOS1 > CLOS2 > CLOS3.

- Tỷ lệ thuận

Khi sử dụng mức độ ưu tiên theo tỷ lệ, có một tham số bổ sung được gọi là
tần số_trọng lượng, có thể được chỉ định cho mỗi nhóm CLOS. Mục tiêu của
mức độ ưu tiên theo tỷ lệ là cung cấp cho mỗi lõi mức tối thiểu được yêu cầu, sau đó
phân bổ toàn bộ ngân sách (thừa/thâm) còn lại theo tỷ lệ đã xác định
trọng lượng. Mức độ ưu tiên theo tỷ lệ này có thể được định cấu hình bằng cách sử dụng "cấu hình nguồn lõi"
lệnh.

Để bật loại ưu tiên mặc định của nền tảng, hãy thực thi::

Kích hoạt năng lượng lõi # intel-speed-select
 Công nghệ chọn tốc độ Intel(R)
 Thi công trên model CPU: X
 gói-0
  chết-0
    cpu-0
      sức mạnh cốt lõi
        kích hoạt: thành công
 gói-1
  chết-0
    CPU-6
      sức mạnh cốt lõi
        kích hoạt: thành công

The scope of this enable is per package or die scoped when a package contains
multiple dies. To check if CLOS is enabled and get priority type, "core-power
info" command can be used. For example to check the status of core-power feature
on CPU 0, execute::

 # intel-speed-select -c 0 core-power info
 Intel(R) Speed Select Technology
 Executing on CPU model: X
 package-0
  die-0
    cpu-0
      core-power
        support-status:supported
        enable-status:enabled
        clos-enable-status:enabled
        priority-type:proportional
 package-1
  die-0
    cpu-24
      core-power
        support-status:supported
        enable-status:enabled
        clos-enable-status:enabled
        priority-type:proportional

Configuring CLOS groups
~~~~~~~~~~~~~~~~~~~~~~~

Each CLOS group has its own attributes including min, max, freq_weight and
desired. These parameters can be configured with "core-power config" command.
Defaults will be used if user skips setting a parameter except clos id, which is
mandatory. To check core-power config options, execute::

 # intel-speed-select core-power config --help
 Intel(R) Speed Select Technology
 Executing on CPU model: X
 Set core-power configuration for one of the four clos ids
	Specify targeted clos id with [--clos|-c]
	Specify clos Proportional Priority [--weight|-w]
	Specify clos min in MHz with [--min|-n]
	Specify clos max in MHz with [--max|-m]

For example::

 # intel-speed-select core-power config -c 0
 Intel(R) Speed Select Technology
 Executing on CPU model: X
 clos epp is not specified, default: 0
 clos frequency weight is not specified, default: 0
 clos min is not specified, default: 0 MHz
 clos max is not specified, default: 25500 MHz
 clos desired is not specified, default: 0
 package-0
  die-0
    cpu-0
      core-power
        config:success
 package-1
  die-0
    cpu-6
      core-power
        config:success

The user has the option to change defaults. For example, the user can change the
"min" and set the base frequency to always get guaranteed base frequency.

Get the current CLOS configuration
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To check the current configuration, "core-power get-config" can be used. For
example, to get the configuration of CLOS 0::

 # intel-speed-select core-power get-config -c 0
 Intel(R) Speed Select Technology
 Executing on CPU model: X
 package-0
  die-0
    cpu-0
      core-power
        clos:0
        epp:0
        clos-proportional-priority:0
        clos-min:0 MHz
        clos-max:Max Turbo frequency
        clos-desired:0 MHz
 package-1
  die-0
    cpu-24
      core-power
        clos:0
        epp:0
        clos-proportional-priority:0
        clos-min:0 MHz
        clos-max:Max Turbo frequency
        clos-desired:0 MHz

Associating a CPU with a CLOS group
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To associate a CPU to a CLOS group "core-power assoc" command can be used::

 # intel-speed-select core-power assoc --help
 Intel(R) Speed Select Technology
 Executing on CPU model: X
 Associate a clos id to a CPU
	Specify targeted clos id with [--clos|-c]


For example to associate CPU 10 to CLOS group 3, execute::

 # intel-speed-select -c 10 core-power assoc -c 3
 Intel(R) Speed Select Technology
 Executing on CPU model: X
 package-0
  die-0
    cpu-10
      core-power
        assoc:success

Once a CPU is associated, its sibling CPUs are also associated to a CLOS group.
Once associated, avoid changing Linux "cpufreq" subsystem scaling frequency
limits.

To check the existing association for a CPU, "core-power get-assoc" command can
be used. For example, to get association of CPU 10, execute::

 # intel-speed-select -c 10 core-power get-assoc
 Intel(R) Speed Select Technology
 Executing on CPU model: X
 package-1
  die-0
    cpu-10
      get-assoc
        clos:3

This shows that CPU 10 is part of a CLOS group 3.


Disable CLOS based prioritization
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To disable, execute::

# intel-speed-select core-power disable

Some features like Intel(R) SST-TF can only be enabled when CLOS based prioritization
is enabled. For this reason, disabling while Intel(R) SST-TF is enabled can cause
Intel(R) SST-TF to fail. This will cause the "disable" command to display an error
if Intel(R) SST-TF is already enabled. In turn, to disable, the Intel(R) SST-TF
feature must be disabled first.

Intel(R) Speed Select Technology - Base Frequency (Intel(R) SST-BF)
-------------------------------------------------------------------

The Intel(R) Speed Select Technology - Base Frequency (Intel(R) SST-BF) feature lets
the user control base frequency. If some critical workload threads demand
constant high guaranteed performance, then this feature can be used to execute
the thread at higher base frequency on specific sets of CPUs (high priority
CPUs) at the cost of lower base frequency (low priority CPUs) on other CPUs.
This feature does not require offline of the low priority CPUs.

The support of Intel(R) SST-BF depends on the Intel(R) Speed Select Technology -
Performance Profile (Intel(R) SST-PP) performance level configuration. It is
possible that only certain performance levels support Intel(R) SST-BF. It is also
possible that only base performance level (level = 0) has support of Intel
SST-BF. Consequently, first select the desired performance level to enable this
feature.

In the system under test here, Intel(R) SST-BF is supported at the base
performance level 0, but currently disabled. For example for the level 0::

 # intel-speed-select -c 0 perf-profile info -l 0
 Intel(R) Speed Select Technology
 Executing on CPU model: X
 package-0
  die-0
    cpu-0
      perf-profile-level-0
        ...

        speed-select-base-freq:disabled
	...

Before enabling Intel(R) SST-BF and measuring its impact on a workload
performance, execute some workload and measure performance and get a baseline
performance to compare against.

Here the user wants more guaranteed performance. For this reason, it is likely
that turbo is disabled. To disable turbo, execute::

#echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo

Based on the output of the "intel-speed-select perf-profile info -l 0" base
frequency of guaranteed frequency 2600 MHz.


Measure baseline performance for comparison
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To compare, pick a multi-threaded workload where each thread can be scheduled on
separate CPUs. "Hackbench pipe" test is a good example on how to improve
performance using Intel(R) SST-BF.

Below, the workload is measuring average scheduler wakeup latency, so a lower
number means better performance::

 # taskset -c 3,4 perf bench -r 100 sched pipe
 # Running 'sched/pipe' benchmark:
 # Executed 1000000 pipe operations between two processes
     Total time: 6.102 [sec]
       6.102445 usecs/op
         163868 ops/sec

While running the above test, if we take turbostat output, it will show us that
2 of the CPUs are busy and reaching max. frequency (which would be the base
frequency as the turbo is disabled). The turbostat output::

 #turbostat -c 0-13 --show Package,Core,CPU,Bzy_MHz -i 1
 Package	Core	CPU	Bzy_MHz
 0		0	0	1000
 0		1	1	1005
 0		2	2	1000
 0		3	3	2600
 0		4	4	2600
 0		5	5	1000
 0		6	6	1000
 0		7	7	1005
 0		8	8	1005
 0		9	9	1000
 0		10	10	1000
 0		11	11	995
 0		12	12	1000
 0		13	13	1000

From the above turbostat output, both CPU 3 and 4 are very busy and reaching
full guaranteed frequency of 2600 MHz.

Intel(R) SST-BF Capabilities
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To get capabilities of Intel(R) SST-BF for the current performance level 0,
execute::

 # intel-speed-select base-freq info -l 0
 Intel(R) Speed Select Technology
 Executing on CPU model: X
 package-0
  die-0
    cpu-0
      speed-select-base-freq
        high-priority-base-frequency(MHz):3000
        high-priority-cpu-mask:00000216,00002160
        high-priority-cpu-list:5,6,8,13,33,34,36,41
        low-priority-base-frequency(MHz):2400
        tjunction-temperature(C):125
        thermal-design-power(W):205

The above capabilities show that there are some CPUs on this system that can
offer base frequency of 3000 MHz compared to the standard base frequency at this
performance levels. Nevertheless, these CPUs are fixed, and they are presented
via high-priority-cpu-list/high-priority-cpu-mask. But if this Intel(R) SST-BF
feature is selected, the low priorities CPUs (which are not in
high-priority-cpu-list) can only offer up to 2400 MHz. As a result, if this
clipping of low priority CPUs is acceptable, then the user can enable Intel
SST-BF feature particularly for the above "sched pipe" workload since only two
CPUs are used, they can be scheduled on high priority CPUs and can get boost of
400 MHz.

Enable Intel(R) SST-BF
~~~~~~~~~~~~~~~~~~~~~~

To enable Intel(R) SST-BF feature, execute::

 # intel-speed-select base-freq enable -a
 Intel(R) Speed Select Technology
 Executing on CPU model: X
 package-0
  die-0
    cpu-0
      base-freq
        enable:success
 package-1
  die-0
    cpu-14
      base-freq
        enable:success

In this case, -a option is optional. This not only enables Intel(R) SST-BF, but it
also adjusts the priority of cores using Intel(R) Speed Select Technology Core
Power (Intel(R) SST-CP) features. This option sets the minimum performance of each
Intel(R) Speed Select Technology - Performance Profile (Intel(R) SST-PP) class to
maximum performance so that the hardware will give maximum performance possible
for each CPU.

If -a option is not used, then the following steps are required before enabling
Intel(R) SST-BF:

- Discover Intel(R) SST-BF and note low and high priority base frequency
- Note the high priority CPU list
- Enable CLOS using core-power feature set
- Configure CLOS parameters. Use CLOS.min to set to minimum performance
- Subscribe desired CPUs to CLOS groups

With this configuration, if the same workload is executed by pinning the
workload to high priority CPUs (CPU 5 and 6 in this case)::

 #taskset -c 5,6 perf bench -r 100 sched pipe
 # Running 'sched/pipe' benchmark:
 # Executed 1000000 pipe operations between two processes
     Total time: 5.627 [sec]
       5.627922 usecs/op
         177685 ops/sec

This way, by enabling Intel(R) SST-BF, the performance of this benchmark is
improved (latency reduced) by 7.79%. From the turbostat output, it can be
observed that the high priority CPUs reached 3000 MHz compared to 2600 MHz.
The turbostat output::

 #turbostat -c 0-13 --show Package,Core,CPU,Bzy_MHz -i 1
 Package	Core	CPU	Bzy_MHz
 0		0	0	2151
 0		1	1	2166
 0		2	2	2175
 0		3	3	2175
 0		4	4	2175
 0		5	5	3000
 0		6	6	3000
 0		7	7	2180
 0		8	8	2662
 0		9	9	2176
 0		10	10	2175
 0		11	11	2176
 0		12	12	2176
 0		13	13	2661

Disable Intel(R) SST-BF
~~~~~~~~~~~~~~~~~~~~~~~

To disable the Intel(R) SST-BF feature, execute::

# intel-speed-select base-freq disable -a


Intel(R) Speed Select Technology - Turbo Frequency (Intel(R) SST-TF)
--------------------------------------------------------------------

This feature enables the ability to set different "All core turbo ratio limits"
to cores based on the priority. By using this feature, some cores can be
configured to get higher turbo frequency by designating them as high priority at
the cost of lower or no turbo frequency on the low priority cores.

For this reason, this feature is only useful when system is busy utilizing all
CPUs, but the user wants some configurable option to get high performance on
some CPUs.

The support of Intel(R) Speed Select Technology - Turbo Frequency (Intel(R) SST-TF)
depends on the Intel(R) Speed Select Technology - Performance Profile (Intel
SST-PP) performance level configuration. It is possible that only a certain
performance level supports Intel(R) SST-TF. It is also possible that only the base
performance level (level = 0) has the support of Intel(R) SST-TF. Hence, first
select the desired performance level to enable this feature.

In the system under test here, Intel(R) SST-TF is supported at the base
performance level 0, but currently disabled::

 # intel-speed-select -c 0 perf-profile info -l 0
 Intel(R) Speed Select Technology
 package-0
  die-0
    cpu-0
      perf-profile-level-0
        ...
        ...
        speed-select-turbo-freq:disabled
        ...
        ...


To check if performance can be improved using Intel(R) SST-TF feature, get the turbo
frequency properties with Intel(R) SST-TF enabled and compare to the base turbo
capability of this system.

Get Base turbo capability
~~~~~~~~~~~~~~~~~~~~~~~~~

To get the base turbo capability of performance level 0, execute::

 # intel-speed-select perf-profile info -l 0
 Intel(R) Speed Select Technology
 Executing on CPU model: X
 package-0
  die-0
    cpu-0
      perf-profile-level-0
        ...
        ...
        turbo-ratio-limits-sse
          bucket-0
            core-count:2
            max-turbo-frequency(MHz):3200
          bucket-1
            core-count:4
            max-turbo-frequency(MHz):3100
          bucket-2
            core-count:6
            max-turbo-frequency(MHz):3100
          bucket-3
            core-count:8
            max-turbo-frequency(MHz):3100
          bucket-4
            core-count:10
            max-turbo-frequency(MHz):3100
          bucket-5
            core-count:12
            max-turbo-frequency(MHz):3100
          bucket-6
            core-count:14
            max-turbo-frequency(MHz):3100
          bucket-7
            core-count:16
            max-turbo-frequency(MHz):3100

Based on the data above, when all the CPUS are busy, the max. frequency of 3100
MHz can be achieved. If there is some busy workload on cpu 0 - 11 (e.g. stress)
and on CPU 12 and 13, execute "hackbench pipe" workload::

 # taskset -c 12,13 perf bench -r 100 sched pipe
 # Running 'sched/pipe' benchmark:
 # Executed 1000000 pipe operations between two processes
     Total time: 5.705 [sec]
       5.705488 usecs/op
         175269 ops/sec

The turbostat output::

 #turbostat -c 0-13 --show Package,Core,CPU,Bzy_MHz -i 1
 Package	Core	CPU	Bzy_MHz
 0		0	0	3000
 0		1	1	3000
 0		2	2	3000
 0		3	3	3000
 0		4	4	3000
 0		5	5	3100
 0		6	6	3100
 0		7	7	3000
 0		8	8	3100
 0		9	9	3000
 0		10	10	3000
 0		11	11	3000
 0		12	12	3100
 0		13	13	3100

Based on turbostat output, the performance is limited by frequency cap of 3100
MHz. To check if the hackbench performance can be improved for CPU 12 and CPU
13, first check the capability of the Intel(R) SST-TF feature for this performance
level.

Get Intel(R) SST-TF Capability
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To get the capability, the "turbo-freq info" command can be used::

 # intel-speed-select turbo-freq info -l 0
 Intel(R) Speed Select Technology
 Executing on CPU model: X
 package-0
  die-0
    cpu-0
      speed-select-turbo-freq
          bucket-0
            high-priority-cores-count:2
            high-priority-max-frequency(MHz):3200
            high-priority-max-avx2-frequency(MHz):3200
            high-priority-max-avx512-frequency(MHz):3100
          bucket-1
            high-priority-cores-count:4
            high-priority-max-frequency(MHz):3100
            high-priority-max-avx2-frequency(MHz):3000
            high-priority-max-avx512-frequency(MHz):2900
          bucket-2
            high-priority-cores-count:6
            high-priority-max-frequency(MHz):3100
            high-priority-max-avx2-frequency(MHz):3000
            high-priority-max-avx512-frequency(MHz):2900
          speed-select-turbo-freq-clip-frequencies
            low-priority-max-frequency(MHz):2600
            low-priority-max-avx2-frequency(MHz):2400
            low-priority-max-avx512-frequency(MHz):2100

Based on the output above, there is an Intel(R) SST-TF bucket for which there are
two high priority cores. If only two high priority cores are set, then max.
turbo frequency on those cores can be increased to 3200 MHz. This is 100 MHz
more than the base turbo capability for all cores.

In turn, for the hackbench workload, two CPUs can be set as high priority and
rest as low priority. One side effect is that once enabled, the low priority
cores will be clipped to a lower frequency of 2600 MHz.

Enable Intel(R) SST-TF
~~~~~~~~~~~~~~~~~~~~~~

To enable Intel(R) SST-TF, execute::

 # intel-speed-select -c 12,13 turbo-freq enable -a
 Intel(R) Speed Select Technology
 Executing on CPU model: X
 package-0
  die-0
    cpu-12
      turbo-freq
        enable:success
 package-0
  die-0
    cpu-13
      turbo-freq
        enable:success
 package--1
  die-0
    cpu-63
      turbo-freq --auto
        enable:success

In this case, the option "-a" is optional. If set, it enables Intel(R) SST-TF
feature and also sets the CPUs to high and low priority using Intel Speed
Select Technology Core Power (Intel(R) SST-CP) features. The CPU numbers passed
with "-c" arguments are marked as high priority, including its siblings.

If -a option is not used, then the following steps are required before enabling
Intel(R) SST-TF:

- Discover Intel(R) SST-TF and note buckets of high priority cores and maximum frequency

- Enable CLOS using core-power feature set - Configure CLOS parameters

- Subscribe desired CPUs to CLOS groups making sure that high priority cores are set to the maximum frequency

If the same hackbench workload is executed, schedule hackbench threads on high
priority CPUs::

 #taskset -c 12,13 perf bench -r 100 sched pipe
 # Running 'sched/pipe' benchmark:
 # Executed 1000000 pipe operations between two processes
     Total time: 5.510 [sec]
       5.510165 usecs/op
         180826 ops/sec

This improved performance by around 3.3% improvement on a busy system. Here the
turbostat output will show that the CPU 12 and CPU 13 are getting 100 MHz boost.
The turbostat output::

 #turbostat -c 0-13 --show Package,Core,CPU,Bzy_MHz -i 1
 Package	Core	CPU	Bzy_MHz
 ...
 0		12	12	3200
 0		13	13	3200