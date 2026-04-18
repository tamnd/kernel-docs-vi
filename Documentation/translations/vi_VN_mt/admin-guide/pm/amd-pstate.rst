.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/pm/amd-pstate.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

====================================================
Trình điều khiển mở rộng hiệu suất ZZ0000ZZ CPU
===============================================

:Bản quyền: ZZ0000ZZ 2021 Advanced Micro Devices, Inc.

:Tác giả: Huang Rui <ray.huang@amd.com>


Giới thiệu
===================

ZZ0000ZZ là trình điều khiển mở rộng hiệu suất AMD CPU giới thiệu một
Cơ chế điều khiển tần số CPU mới trên dòng AMD APU và CPU hiện đại ở
Hạt nhân Linux. Cơ chế mới dựa trên Bộ xử lý cộng tác
Kiểm soát hiệu suất (CPPC) cung cấp khả năng quản lý tần số chi tiết hơn
hơn P-State phần cứng ACPI truyền thống. Nền tảng AMD CPU/APU hiện đang sử dụng
trình điều khiển trạng thái P ACPI để quản lý tần số và đồng hồ CPU bằng cách chuyển đổi
chỉ ở 3 trạng thái P. CPPC thay thế các điều khiển trạng thái P của ACPI và cho phép
giao diện linh hoạt, độ trễ thấp để nhân Linux truy cập trực tiếp
truyền đạt các gợi ý về hiệu suất tới phần cứng.

ZZ0000ZZ tận dụng các trình điều khiển nhân Linux như ZZ0001ZZ,
ZZ0002ZZ, v.v. để quản lý các gợi ý về hiệu suất được cung cấp bởi
Chức năng phần cứng CPPC tuân theo phần cứng bên trong
thông số kỹ thuật (để biết chi tiết, hãy tham khảo Hướng dẫn lập trình viên kiến trúc AMD64
Tập 2: Lập trình hệ thống [1]_). Hiện tại, ZZ0003ZZ hỗ trợ cơ bản
chức năng điều khiển tần số theo bộ điều khiển kernel trên một số
Bộ xử lý Zen2 và Zen3 và chúng tôi sẽ triển khai nhiều chức năng cụ thể hơn của AMD
trong tương lai sau khi chúng tôi xác minh chúng trên phần cứng và SBIOS.


Tổng quan về AMD CPPC
=======================

Giao diện Kiểm soát hiệu suất bộ xử lý cộng tác (CPPC) liệt kê một
giá trị hiệu suất liên tục, trừu tượng và không có đơn vị trong thang đo
không bị ràng buộc với trạng thái/tần suất hiệu suất cụ thể. Đây là ACPI
tiêu chuẩn [2]_ phần mềm nào có thể chỉ định mục tiêu hiệu suất ứng dụng và
gợi ý như một mục tiêu tương đối với các giới hạn cơ sở hạ tầng. Bộ xử lý AMD
cung cấp mô hình thanh ghi có độ trễ thấp (MSR) thay vì mã AML
thông dịch viên để điều chỉnh hiệu suất. ZZ0000ZZ sẽ khởi tạo một
Phiên bản ZZ0001ZZ, ZZ0002ZZ, với lệnh gọi lại
để quản lý từng hành vi cập nhật hiệu suất. ::

Hiệu suất cao nhất ------>+--------------+ +--------------+
                     ZZ0000ZZ ZZ0001ZZ
                     ZZ0002ZZ ZZ0003ZZ
                     ZZ0004ZZ Hiệu suất tối đa ---->ZZ0005ZZ
                     ZZ0006ZZ ZZ0007ZZ
                     ZZ0008ZZ ZZ0009ZZ
 Hiệu suất danh nghĩa ------>+--------------+ +--------------+
                     ZZ0010ZZ ZZ0011ZZ
                     ZZ0012ZZ ZZ0013ZZ
                     ZZ0014ZZ ZZ0015ZZ
                     ZZ0016ZZ ZZ0017ZZ
                     ZZ0018ZZ ZZ0019ZZ
                     ZZ0020ZZ ZZ0021ZZ
                     ZZ0022ZZ Sự hoàn hảo mong muốn ---->ZZ0023ZZ
                     ZZ0024ZZ ZZ0025ZZ
                     ZZ0026ZZ ZZ0027ZZ
                     ZZ0028ZZ ZZ0029ZZ
                     ZZ0030ZZ ZZ0031ZZ
                     ZZ0032ZZ ZZ0033ZZ
                     ZZ0034ZZ ZZ0035ZZ
                     ZZ0036ZZ ZZ0037ZZ
                     ZZ0038ZZ ZZ0039ZZ
                     ZZ0040ZZ ZZ0041ZZ
  Thấp nhất không phải ZZ0042ZZ ZZ0043ZZ
  sự hoàn hảo tuyến tính ------>+--------------+ +--------------+
                     ZZ0044ZZ ZZ0045ZZ
                     ZZ0046ZZ Hiệu suất tối thiểu ---->ZZ0047ZZ
                     ZZ0048ZZ ZZ0049ZZ
  Hiệu suất thấp nhất ------>+--------------+ +--------------+
                     ZZ0050ZZ ZZ0051ZZ
                     ZZ0052ZZ ZZ0053ZZ
                     ZZ0054ZZ ZZ0055ZZ
          0 ------>+--------------+ +--------------+

Thang hiệu suất AMD P-States


.. _perf_cap:

Khả năng hoạt động của AMD CPPC
--------------------------------

Hiệu suất cao nhất (RO)
.........................

Đây là hiệu suất tối đa tuyệt đối mà một bộ xử lý riêng lẻ có thể đạt được,
giả sử điều kiện lý tưởng. Mức hiệu suất này có thể không bền vững
trong thời gian dài và chỉ có thể đạt được nếu các thành phần nền tảng khác
đang ở trong một trạng thái cụ thể; ví dụ: nó có thể yêu cầu các bộ xử lý khác ở trong
một trạng thái nhàn rỗi. Điều này sẽ tương đương với tần số cao nhất
được hỗ trợ bởi bộ xử lý.

Hiệu suất danh nghĩa (Được đảm bảo) (RO)
......................................

Đây là mức hiệu suất duy trì tối đa của bộ xử lý, giả sử
điều kiện hoạt động lý tưởng. Trong trường hợp không có ràng buộc bên ngoài (quyền lực,
nhiệt, v.v.), đây là mức hiệu suất mà bộ xử lý dự kiến sẽ đạt được
có thể duy trì liên tục. Tất cả các lõi/bộ xử lý dự kiến sẽ
có thể duy trì đồng thời trạng thái hoạt động danh nghĩa của họ.

Hiệu suất phi tuyến tính thấp nhất (RO)
...................................

Đây là mức hiệu suất thấp nhất mà tại đó mức tiết kiệm năng lượng phi tuyến có thể được thực hiện.
đạt được, ví dụ, do tác động kết hợp của điện áp và tần số
nhân rộng. Trên ngưỡng này, mức hiệu suất thấp hơn thường được
hiệu quả năng lượng hơn mức hiệu suất cao hơn. Sổ đăng ký này
truyền tải hiệu quả mức hiệu suất hiệu quả nhất đến ZZ0000ZZ.

Hiệu suất thấp nhất (RO)
........................

Đây là mức hiệu suất thấp nhất tuyệt đối của bộ xử lý. Chọn một
mức hiệu suất thấp hơn mức hiệu suất phi tuyến thấp nhất có thể
gây ra hiệu quả kém nhưng sẽ làm giảm công suất tức thời
mức tiêu thụ của bộ xử lý.

Kiểm soát hiệu suất AMD CPPC
------------------------------

ZZ0000ZZ vượt qua các mục tiêu hiệu suất thông qua các thanh ghi này. các
register điều khiển hành vi của mục tiêu hiệu suất mong muốn.

Hiệu suất yêu cầu tối thiểu (RW)
...................................

ZZ0000ZZ chỉ định mức hiệu suất tối thiểu được phép.

Hiệu suất được yêu cầu tối đa (RW)
...................................

ZZ0000ZZ chỉ định giới hạn hiệu suất tối đa được mong đợi
được cung cấp bởi phần cứng.

Mục tiêu hiệu suất mong muốn (RW)
...................................

ZZ0000ZZ chỉ định mục tiêu mong muốn trong thang hiệu suất CPPC như
một con số tương đối Điều này có thể được biểu thị bằng phần trăm của danh nghĩa
hiệu suất (cơ sở hạ tầng tối đa). Dưới hiệu suất duy trì danh nghĩa
mức độ, hiệu suất mong muốn thể hiện mức hiệu suất trung bình của
bộ xử lý phụ thuộc vào phần cứng. Trên mức hiệu suất danh nghĩa,
bộ xử lý phải cung cấp ít nhất hiệu suất danh nghĩa được yêu cầu và cao hơn
nếu điều kiện hoạt động hiện tại cho phép.

Tùy chọn hiệu suất năng lượng (EPP) (RW)
.........................................

Thuộc tính này cung cấp gợi ý cho phần cứng nếu phần mềm muốn thiên vị
hướng tới hiệu suất (0x0) hoặc hiệu quả năng lượng (0xff).


Hỗ trợ của các thống đốc chủ chốt
=======================

ZZ0000ZZ có thể được sử dụng với tất cả các bộ điều chỉnh tỷ lệ (chung) được liệt kê
bởi thuộc tính chính sách ZZ0001ZZ trong ZZ0002ZZ. Sau đó,
nó chịu trách nhiệm cấu hình các đối tượng chính sách tương ứng với
CPU và cung cấp lõi ZZ0003ZZ (và các bộ điều chỉnh tỷ lệ được đính kèm
cho các đối tượng chính sách) với thông tin chính xác về mức tối đa và tối thiểu
tần số hoạt động được hỗ trợ bởi phần cứng. Người dùng có thể kiểm tra
Thông tin ZZ0004ZZ đến từ lõi ZZ0005ZZ.

ZZ0000ZZ chủ yếu hỗ trợ ZZ0001ZZ và ZZ0002ZZ cho động
điều khiển tần số. Đó là tinh chỉnh cấu hình bộ xử lý trên
ZZ0003ZZ sang ZZ0004ZZ bằng bộ lập lịch CPU CFS. ZZ0005ZZ
đăng ký lệnh gọi lại adjustment_perf để triển khai hành vi cập nhật hiệu suất
tương tự như CPPC. Nó được khởi tạo bởi ZZ0006ZZ và sau đó điền vào
Con trỏ update_util_data của CPU để gán ZZ0007ZZ làm
chức năng gọi lại cập nhật sử dụng trong bộ lập lịch CPU. Bộ lập lịch CPU
sẽ gọi ZZ0008ZZ và chỉ định hiệu suất mục tiêu theo
tới ZZ0009ZZ chứa bản cập nhật sử dụng.
Sau đó, ZZ0010ZZ cập nhật hiệu suất mong muốn theo CPU
người lập lịch được giao.

.. _processor_support:

Hỗ trợ bộ xử lý
=======================

Việc khởi tạo ZZ0000ZZ sẽ thất bại nếu mục ZZ0001ZZ trong ACPI
SBIOS không tồn tại trong bộ xử lý được phát hiện. Nó sử dụng ZZ0002ZZ
để kiểm tra sự tồn tại của ZZ0003ZZ. Tất cả các bộ xử lý dựa trên Zen đều hỗ trợ kế thừa
Chức năng P-State của phần cứng ACPI, vì vậy khi khởi tạo ZZ0004ZZ không thành công,
kernel sẽ quay lại để khởi tạo trình điều khiển ZZ0005ZZ.

Có hai loại triển khai phần cứng cho ZZ0001ZZ: một là
ZZ0004ZZ và một cái khác là ZZ0005ZZ. Nó có thể sử dụng cờ tính năng ZZ0000ZZ để
chỉ ra các loại khác nhau. (Để biết chi tiết, hãy tham khảo Lập trình bộ xử lý
Tài liệu tham khảo (PPR) dành cho AMD Dòng 19h Model 51h, Bộ xử lý A1 sửa đổi [3]_.)
ZZ0002ZZ phải đăng ký các phiên bản ZZ0003ZZ khác nhau cho các
triển khai phần cứng.

Hiện tại, một số bộ xử lý Zen2 và Zen3 hỗ trợ ZZ0000ZZ. trong
trong tương lai, nó sẽ được hỗ trợ ngày càng nhiều trên bộ xử lý AMD.

Hỗ trợ đầy đủ MSR
-----------------

Một số bộ xử lý Zen3 mới như Cezanne cung cấp trực tiếp các thanh ghi MSR
trong khi cờ tính năng ZZ0000ZZ CPU được đặt.
ZZ0001ZZ có thể xử lý thanh ghi MSR để thực hiện chuyển đổi nhanh
chức năng trong ZZ0002ZZ có thể làm giảm độ trễ của điều khiển tần số trong
làm gián đoạn bối cảnh. Các hàm có tiền tố ZZ0003ZZ đại diện cho
hoạt động trên các thanh ghi MSR.

Hỗ trợ bộ nhớ chia sẻ
----------------------

Nếu cờ tính năng ZZ0000ZZ CPU không được đặt,
bộ xử lý hỗ trợ giải pháp bộ nhớ dùng chung. Trong trường hợp này, ZZ0001ZZ
sử dụng các phương thức trợ giúp ZZ0002ZZ để triển khai các hàm gọi lại
được xác định trên ZZ0003ZZ. Các chức năng có tiền tố ZZ0004ZZ
thể hiện hoạt động của các trình trợ giúp ACPI CPPC cho giải pháp bộ nhớ dùng chung.


AMD P-States và ACPI phần cứng P-States luôn có thể được hỗ trợ trong một
bộ xử lý. Nhưng AMD P-States có mức độ ưu tiên cao hơn và nếu nó được bật
với ZZ0000ZZ hoặc ZZ0001ZZ, nó sẽ phản hồi
theo yêu cầu từ AMD P-States.


Giao diện không gian người dùng trong ZZ0000ZZ - Kiểm soát theo chính sách
======================================================

ZZ0000ZZ hiển thị một số thuộc tính (tệp) toàn cầu trong ZZ0001ZZ cho
kiểm soát chức năng của nó ở cấp độ hệ thống. Chúng nằm ở
Thư mục ZZ0002ZZ và ảnh hưởng đến tất cả các CPU. ::

root@hr-test1:/home/ray# ls /sys/devices/system/cpu/cpufreq/policy0/ZZ0000ZZ
 /sys/devices/system/cpu/cpufreq/policy0/amd_pstate_highest_perf
 /sys/devices/system/cpu/cpufreq/policy0/amd_pstate_hw_prefcore
 /sys/devices/system/cpu/cpufreq/policy0/amd_pstate_lowest_nonTuyến_freq
 /sys/devices/system/cpu/cpufreq/policy0/amd_pstate_max_freq
 /sys/devices/system/cpu/cpufreq/policy0/amd_pstate_floor_freq
 /sys/devices/system/cpu/cpufreq/policy0/amd_pstate_floor_count
 /sys/devices/system/cpu/cpufreq/policy0/amd_pstate_prefcore_ranking


ZZ0000ZZ

Hiệu suất CPPC tối đa và tần số CPU mà trình điều khiển được phép
được đặt, tính bằng phần trăm của mức hiệu suất CPPC được hỗ trợ tối đa (mức cao nhất
hiệu suất được hỗ trợ trong ZZ0002ZZ).
Trong một số ASIC, hiệu suất CPPC cao nhất không phải là hiệu suất trong ZZ0000ZZ
table, vì vậy chúng ta cần hiển thị nó với sysfs. Nếu tăng cường không hoạt động, nhưng
vẫn được hỗ trợ, tần số tối đa này sẽ lớn hơn tần số trong
ZZ0001ZZ.
Thuộc tính này là chỉ đọc.

ZZ0000ZZ

Tần số CPPC CPU phi tuyến tính thấp nhất mà trình điều khiển được phép đặt,
tính bằng phần trăm của mức hiệu suất CPPC được hỗ trợ tối đa. (Xin vui lòng xem
hiệu suất phi tuyến tính thấp nhất trong ZZ0000ZZ.)
Thuộc tính này là chỉ đọc.

ZZ0000ZZ

Liệu nền tảng có hỗ trợ tính năng cốt lõi ưu tiên hay không và nó có
đã được kích hoạt. Thuộc tính này là chỉ đọc. Tập tin này chỉ hiển thị
trên các nền tảng hỗ trợ tính năng cốt lõi ưa thích.

ZZ0000ZZ

Xếp hạng hiệu suất của lõi. Số này không có đơn vị, nhưng
số lượng lớn hơn được ưa thích tại thời điểm đọc. Điều này có thể thay đổi ở
thời gian chạy dựa trên điều kiện nền tảng. Thuộc tính này là chỉ đọc. tập tin này
chỉ hiển thị trên các nền tảng hỗ trợ tính năng cốt lõi ưa thích.

ZZ0000ZZ

Tần số sàn được liên kết với mỗi CPU. Không gian người dùng có thể viết bất kỳ
giá trị giữa ZZ0000ZZ và ZZ0001ZZ vào đây
tập tin. Khi hệ thống bị hạn chế về nguồn điện hoặc nhiệt,
chương trình cơ sở nền tảng sẽ cố gắng điều chỉnh tần số CPU đến mức
giá trị được chỉ định trong ZZ0002ZZ trước khi điều chỉnh nó
hơn nữa. Điều này cho phép không gian người dùng chỉ định các tần số sàn khác nhau
tới các CPU khác nhau. Để có kết quả tối ưu, các luồng của cùng một lõi
phải có cùng giá trị tần số sàn. Tập tin này chỉ hiển thị
trên các nền tảng hỗ trợ tính năng Ưu tiên hiệu suất CPPC.


ZZ0000ZZ

Số mức Hiệu suất Sàn riêng biệt được hỗ trợ bởi
nền tảng. Ví dụ: nếu giá trị này là 2 thì số lượng duy nhất
các giá trị thu được từ lệnh ZZ0000ZZ tối đa phải bằng số này đối với hành vi
được mô tả trong ZZ0001ZZ để có hiệu lực. Giá trị bằng 0
ngụ ý rằng nền tảng hỗ trợ mức hiệu suất sàn không giới hạn.
Tệp này chỉ hiển thị trên các nền tảng hỗ trợ CPPC
Tính năng ưu tiên hiệu suất.

ZZ0003ZZ: Khi ZZ0000ZZ khác 0, tần số thành
mà CPU được điều chỉnh dưới các hạn chế về điện hoặc nhiệt là
không xác định khi số lượng giá trị duy nhất của ZZ0001ZZ
trên tất cả các CPU trong hệ thống vượt quá ZZ0002ZZ.

ZZ0000ZZ

Danh sách tất cả các tùy chọn EPP được hỗ trợ có thể được sử dụng cho
ZZ0000ZZ trên hệ thống này.
Những hồ sơ này đại diện cho những gợi ý khác nhau được cung cấp
đến chương trình cơ sở cấp thấp về năng lượng và hiệu quả mong muốn của người dùng
sự đánh đổi.  ZZ0001ZZ đại diện cho giá trị epp được đặt theo nền tảng
phần sụn. ZZ0002ZZ chỉ định rằng các giá trị nguyên 0-255 có thể được ghi
cũng vậy.  Thuộc tính này là chỉ đọc.

ZZ0000ZZ

Tùy chọn hiệu suất năng lượng hiện tại có thể được đọc từ thuộc tính này.
và người dùng có thể thay đổi tùy chọn hiện tại theo nhu cầu năng lượng hoặc hiệu suất
Hồ sơ có tên thô có sẵn trong thuộc tính
ZZ0000ZZ.
Người dùng cũng có thể viết các giá trị nguyên riêng lẻ trong khoảng từ 0 đến 255.
Khi EPP động được bật, việc ghi vào energy_performance_preference sẽ bị chặn
ngay cả khi tính năng EPP được kích hoạt bởi phần sụn nền tảng. Giá trị epp thấp hơn sẽ làm thay đổi độ lệch
hướng tới hiệu suất được cải thiện trong khi giá trị epp cao hơn sẽ chuyển xu hướng sang
tiết kiệm điện. Tác động chính xác có thể thay đổi từ nền tảng này sang nền tảng khác.
Nếu một số nguyên hợp lệ được ghi lần cuối thì một số sẽ được trả về trong các lần đọc sau.
Nếu một chuỗi hợp lệ được ghi lần cuối thì chuỗi đó sẽ được trả về trong các lần đọc sau.
Thuộc tính này là đọc-ghi.

ZZ0000ZZ
Thuộc tính sysfs ZZ0001ZZ cung cấp quyền kiểm soát lõi CPU
tăng hiệu suất, cho phép người dùng quản lý giới hạn tần số tối đa
của CPU. Thuộc tính này có thể được sử dụng để bật hoặc tắt tính năng tăng cường
trên các CPU riêng lẻ.

Khi tính năng tăng tốc được bật, CPU có thể tự động tăng tần số
vượt quá tần số cơ bản, mang lại hiệu suất nâng cao cho khối lượng công việc đòi hỏi khắt khe.
Mặt khác, việc tắt tính năng tăng tốc sẽ hạn chế CPU hoạt động ở tốc độ
tần số cơ bản, có thể được mong muốn trong một số trường hợp nhất định để ưu tiên nguồn điện
hiệu quả hoặc quản lý nhiệt độ.

Để thao tác thuộc tính ZZ0000ZZ, người dùng có thể viết giá trị ZZ0001ZZ để vô hiệu hóa
boost hoặc ZZ0002ZZ để kích hoạt nó, đối với CPU tương ứng bằng đường dẫn sysfs
ZZ0003ZZ, trong đó ZZ0004ZZ đại diện cho số CPU.

Các giá trị hiệu suất và tần số khác có thể được đọc lại từ
ZZ0001ZZ, xem ZZ0000ZZ.

Hồ sơ hiệu suất năng lượng động
==================================
Trình điều khiển amd-pstate hỗ trợ tự động chọn hiệu suất năng lượng
profile dựa trên việc máy đang chạy bằng nguồn AC hay DC.

Hành vi này có được bật theo mặc định hay không tùy thuộc vào kernel
tùy chọn cấu hình ZZ0001ZZ. Hành vi này cũng có thể được ghi đè
trong thời gian chạy bằng tệp sysfs ZZ0000ZZ.

Khi được đặt thành bật, trình điều khiển sẽ chọn hiệu suất năng lượng khác
profile khi máy chạy bằng pin hoặc nguồn AC. Người lái xe sẽ
cũng đăng ký với trình xử lý hồ sơ nền tảng để nhận thông báo về
trạng thái năng lượng mong muốn của người dùng và phản ứng với những trạng thái đó.
Khi được đặt thành tắt, trình điều khiển sẽ không thay đổi cấu hình hiệu suất năng lượng
dựa trên nguồn điện và sẽ không phản ứng với trạng thái năng lượng mong muốn của người dùng.

Đang cố gắng ghi thủ công vào hệ thống ZZ0000ZZ
tập tin sẽ không thành công khi ZZ0001ZZ được kích hoạt.

ZZ0000ZZ so với ZZ0001ZZ
======================================

Trên phần lớn các nền tảng AMD được ZZ0000ZZ hỗ trợ, các bảng ACPI
được cung cấp bởi phần sụn nền tảng được sử dụng để mở rộng hiệu suất CPU, nhưng
chỉ cung cấp 3 trạng thái P trên bộ xử lý AMD.
Tuy nhiên, trên dòng AMD APU và CPU hiện đại, phần cứng cung cấp tính năng Cộng tác
Kiểm soát hiệu suất bộ xử lý theo giao thức ACPI và tùy chỉnh điều này
cho nền tảng AMD. Đó là, dải tần số chi tiết và liên tục
thay vì trạng thái P phần cứng cũ. ZZ0001ZZ là hạt nhân
mô-đun hỗ trợ cơ chế P-States AMD mới trên hầu hết AMD trong tương lai
nền tảng. Cơ chế P-States AMD mang lại hiệu suất và năng lượng cao hơn
phương pháp quản lý tần số hiệu quả trên bộ xử lý AMD.


Các chế độ hoạt động của trình điều khiển ZZ0000ZZ
======================================

ZZ0000ZZ CPPC có 3 chế độ hoạt động: chế độ tự động (active),
chế độ không tự trị (thụ động) và chế độ tự trị có hướng dẫn (có hướng dẫn).
Chế độ chủ động/thụ động/có hướng dẫn có thể được chọn bởi các tham số kernel khác nhau.

- Ở chế độ tự động, nền tảng bỏ qua yêu cầu mức hiệu suất mong muốn
  và chỉ tính đến các giá trị được đặt ở mức tối thiểu, tối đa và năng lượng
  đăng ký ưu tiên hiệu suất.
- Ở chế độ không tự trị, nền tảng đạt được mức hiệu suất mong muốn
  từ hệ điều hành trực tiếp thông qua Đăng ký hiệu suất mong muốn.
- Ở chế độ tự động có hướng dẫn, nền tảng đặt mức hiệu suất vận hành
  tự chủ theo khối lượng công việc hiện tại và trong giới hạn do
  Hệ điều hành thông qua các thanh ghi hiệu suất tối thiểu và tối đa.

Chế độ hoạt động
------------

ZZ0000ZZ

Đây là chế độ điều khiển phần sụn cấp thấp được ZZ0000ZZ triển khai
trình điều khiển có ZZ0001ZZ được chuyển tới kernel trong dòng lệnh.
Ở chế độ này, trình điều khiển ZZ0002ZZ cung cấp gợi ý cho phần cứng nếu phần mềm
muốn thiên về hiệu suất (0x0) hoặc hiệu quả năng lượng (0xff) cho phần sụn CPPC.
sau đó thuật toán nguồn CPPC sẽ tính toán khối lượng công việc thời gian chạy và điều chỉnh thời gian thực
tần số lõi theo nguồn điện và nhiệt, điện áp lõi và một số thứ khác
điều kiện phần cứng.

Chế độ thụ động
------------

ZZ0000ZZ

Nó sẽ được kích hoạt nếu ZZ0000ZZ được chuyển tới kernel trong dòng lệnh.
Ở chế độ này, phần mềm trình điều khiển ZZ0001ZZ chỉ định mục tiêu QoS mong muốn trong CPPC
thang đo hiệu suất dưới dạng một con số tương đối. Điều này có thể được biểu thị bằng phần trăm của danh nghĩa
hiệu suất (cơ sở hạ tầng tối đa). Dưới mức hiệu quả duy trì danh nghĩa,
hiệu suất mong muốn thể hiện mức hiệu suất trung bình của đối tượng bộ xử lý
vào sổ đăng ký Dung sai giảm hiệu suất. Trên mức hiệu suất danh nghĩa,
bộ xử lý phải cung cấp ít nhất hiệu suất danh nghĩa được yêu cầu và cao hơn nếu hiện tại
điều kiện hoạt động cho phép.

Chế độ hướng dẫn
-----------

ZZ0000ZZ

Nếu ZZ0000ZZ được chuyển tới tùy chọn dòng lệnh kernel thì chế độ này
được kích hoạt.  Ở chế độ này, trình điều khiển yêu cầu hiệu suất tối thiểu và tối đa
cấp độ và nền tảng tự động chọn mức hiệu suất trong phạm vi này
và phù hợp với khối lượng công việc hiện tại.

Lõi ưu tiên ZZ0000ZZ
=================================

Tần số lõi chịu sự thay đổi của quá trình trong chất bán dẫn.
Không phải tất cả các lõi đều có thể đạt tần số tối đa
hạn chế về cơ sở hạ tầng. Do đó, AMD đã định nghĩa lại khái niệm về
tần số tối đa của một phần. Điều này có nghĩa là một phần lõi có thể đạt tới
tần số tối đa. Để tìm ra chính sách lập kế hoạch quy trình tốt nhất cho một
kịch bản, hệ điều hành cần biết thứ tự cốt lõi được nền tảng thông báo thông qua
thanh ghi khả năng hiệu suất cao nhất của giao diện CPPC.

Lõi ưu tiên ZZ0000ZZ cho phép bộ lập lịch ưu tiên lập lịch trên
lõi có thể đạt được tần số cao hơn với điện áp thấp hơn. Ưu tiên
thứ hạng cốt lõi có thể thay đổi linh hoạt dựa trên khối lượng công việc, điều kiện nền tảng,
nhiệt độ và lão hóa.

Số liệu ưu tiên sẽ được khởi tạo bởi trình điều khiển ZZ0000ZZ. ZZ0001ZZ
trình điều khiển cũng sẽ xác định xem lõi ưu tiên ZZ0002ZZ có phải là
được hỗ trợ bởi nền tảng.

Trình điều khiển ZZ0000ZZ sẽ cung cấp thứ tự lõi ban đầu khi hệ thống khởi động.
Nền tảng sử dụng giao diện CPPC để truyền đạt thứ hạng cốt lõi tới
hệ điều hành và bộ lập lịch để đảm bảo rằng hệ điều hành đang chọn lõi
với hiệu suất cao nhất trước tiên để lập kế hoạch cho quá trình. Khi ZZ0001ZZ
người lái xe nhận được tin nhắn có sự thay đổi hiệu suất cao nhất, nó sẽ
cập nhật thứ hạng cốt lõi và đặt mức độ ưu tiên của cpu.

Công tắc lõi ưa thích ZZ0000ZZ
=====================================
Thông số hạt nhân
-----------------

Lõi ưu tiên ZZ0000ZZ`` has two states: enable and disable.
Enable/disable states can be chosen by different kernel parameters.
Default enable ``amd-pstate``.

ZZ0000ZZ

Đối với các hệ thống hỗ trợ lõi ưu tiên ZZ0000ZZ, bảng xếp hạng lõi sẽ
luôn được quảng cáo bởi nền tảng. Nhưng hệ điều hành có thể chọn bỏ qua điều đó thông qua
tham số hạt nhân ZZ0001ZZ.

ZZ0000ZZ

Khi AMD pstate ở chế độ tự động, EPP động sẽ kiểm soát xem kernel có
tự động thay đổi chế độ EPP. Mặc định được cấu hình bởi
ZZ0000ZZ nhưng có thể được kích hoạt rõ ràng bằng
ZZ0001ZZ hoặc bị vô hiệu hóa với ZZ0002ZZ.

Giao diện không gian người dùng trong ZZ0000ZZ - Chung
===========================================

Thuộc tính chung
-----------------

ZZ0000ZZ hiển thị một số thuộc tính (tệp) toàn cầu trong ZZ0001ZZ cho
kiểm soát chức năng của nó ở cấp độ hệ thống.  Chúng nằm ở
Thư mục ZZ0002ZZ và ảnh hưởng đến tất cả các CPU.

ZZ0000ZZ
	Chế độ hoạt động của trình điều khiển: "hoạt động", "thụ động", "được hướng dẫn" hoặc "vô hiệu hóa".

"hoạt động"
		Trình điều khiển có chức năng và có trong ZZ0000ZZ

"thụ động"
		Trình điều khiển có chức năng và có trong ZZ0000ZZ

"được hướng dẫn"
		Trình điều khiển có chức năng và có trong ZZ0000ZZ

"vô hiệu hóa"
		Trình điều khiển chưa được đăng ký và hiện không hoạt động.

Thuộc tính này có thể được ghi vào để thay đổi trình điều khiển
        chế độ hoạt động hoặc hủy đăng ký nó.  Chuỗi được viết cho nó phải là
        một trong những giá trị có thể có của nó và nếu thành công, hãy viết một trong những giá trị đó
        những giá trị này vào tệp sysfs sẽ khiến trình điều khiển chuyển đổi
        sang chế độ hoạt động được đại diện bởi chuỗi đó - hoặc được
        chưa đăng ký trong trường hợp "vô hiệu hóa".

ZZ0000ZZ
	Trạng thái cốt lõi ưu tiên của trình điều khiển: "đã bật" hoặc "đã tắt".

"đã bật"
		Kích hoạt lõi ưu tiên ZZ0000ZZ.

"bị vô hiệu hóa"
		Vô hiệu hóa lõi ưu tiên ZZ0000ZZ


Thuộc tính này ở chế độ chỉ đọc để kiểm tra trạng thái của bộ lõi ưu tiên
        bởi tham số kernel.

Hỗ trợ công cụ ZZ0000ZZ cho ZZ0001ZZ
===============================================

ZZ0000ZZ được hỗ trợ bởi công cụ ZZ0001ZZ, có thể được sử dụng để kết xuất
thông tin tần số. Đang trong quá trình phát triển để hỗ trợ ngày càng nhiều
hoạt động cho mô-đun ZZ0002ZZ mới bằng công cụ này. ::

root@hr-test1:/home/ray# cpupower tần số-thông tin
 phân tích CPU 0:
   trình điều khiển: amd-pstate
   CPU chạy ở cùng tần số phần cứng: 0
   CPU cần điều phối tần số bằng phần mềm: 0
   độ trễ chuyển tiếp tối đa: 131 us
   giới hạn phần cứng: 400 MHz - 4,68 GHz
   bộ điều chỉnh cpufreq có sẵn: bảo thủ theo yêu cầu tiết kiệm hiệu suất không gian người dùng lịch trình
   chính sách hiện tại: tần số phải nằm trong khoảng 400 MHz và 4,68 GHz.
                   Thống đốc "schedutil" có thể quyết định sử dụng tốc độ nào
                   trong phạm vi này.
   tần số CPU hiện tại: Không thể gọi phần cứng
   tần số CPU hiện tại: 4,02 GHz (được xác nhận bằng lệnh gọi tới kernel)
   tăng cường hỗ trợ của nhà nước:
     Được hỗ trợ: có
     Hoạt động: có
     AMD PSTATE Hiệu suất cao nhất: 166. Tần số tối đa: 4,68 GHz.
     AMD PSTATE Hiệu suất danh nghĩa: 117. Tần số danh nghĩa: 3,30 GHz.
     AMD PSTATE Hiệu suất phi tuyến tính thấp nhất: 39. Tần số phi tuyến tính thấp nhất: 1,10 GHz.
     AMD PSTATE Hiệu suất thấp nhất: 15. Tần số thấp nhất: 400 MHz.


Chẩn đoán và điều chỉnh
=======================

Theo dõi sự kiện
--------------

Có hai sự kiện theo dõi tĩnh có thể được sử dụng cho ZZ0000ZZ
chẩn đoán. Một trong số đó là sự kiện theo dõi ZZ0001ZZ thường được sử dụng
bởi ZZ0002ZZ và cái còn lại là sự kiện theo dõi ZZ0003ZZ
dành riêng cho ZZ0004ZZ.  Chuỗi lệnh shell sau đây có thể
được sử dụng để kích hoạt chúng và xem đầu ra của chúng (nếu kernel
được cấu hình để hỗ trợ theo dõi sự kiện). ::

root@hr-test1:/home/ray# cd /sys/kernel/tracing/
 root@hr-test1:/sys/kernel/tracing# echo 1 > sự kiện/amd_cpu/bật
 root@hr-test1:/sys/kernel/tracing# cat trace
 # tracer: không
 #
 # entries-in-buffer/mục viết: 47827/42233061 #P:2
 #
 #                                _-----=> không hoạt động
 # / _---=> cần được chỉnh sửa lại
 # | / _---=> hardirq/softirq
 # || / _--=> ưu tiên độ sâu
 # ||| / trì hoãn
 #           ZZ0003ZZ-ZZ0004ZZ CPU# ||||   TIMESTAMP FUNCTION
 #              ZZ0008ZZ ZZ0001ZZ||ZZ0002ZZ |
          <nhàn rỗi>-0 [015] dN... 4995.979886: amd_pstate_perf: amd_min_perf=85 amd_des_perf=85 amd_max_perf=166 cpu_id=15 đã thay đổi=false fast_switch=true
          <nhàn rỗi>-0 [007] d.h.. 4995.979893: amd_pstate_perf: amd_min_perf=85 amd_des_perf=85 amd_max_perf=166 cpu_id=7 đã thay đổi=false fast_switch=true
             cat-2161 [000] d.... 4995.980841: amd_pstate_perf: amd_min_perf=85 amd_des_perf=85 amd_max_perf=166 cpu_id=0 đã thay đổi=false fast_switch=true
            sshd-2125 [004] d.s.. 4995.980968: amd_pstate_perf: amd_min_perf=85 amd_des_perf=85 amd_max_perf=166 cpu_id=4 đã thay đổi=false fast_switch=true
          <nhàn rỗi>-0 [007] d.s.. 4995.980968: amd_pstate_perf: amd_min_perf=85 amd_des_perf=85 amd_max_perf=166 cpu_id=7 đã thay đổi=false fast_switch=true
          <nhàn rỗi>-0 [003] d.s.. 4995.980971: amd_pstate_perf: amd_min_perf=85 amd_des_perf=85 amd_max_perf=166 cpu_id=3 đã thay đổi=false fast_switch=true
          <nhàn rỗi>-0 [011] d.s.. 4995.980996: amd_pstate_perf: amd_min_perf=85 amd_des_perf=85 amd_max_perf=166 cpu_id=11 đã thay đổi=false fast_switch=true

Sự kiện theo dõi ZZ0000ZZ sẽ được kích hoạt bằng cách chia tỷ lệ ZZ0001ZZ
bộ điều chỉnh (đối với các chính sách được đính kèm) hoặc bởi lõi ZZ0002ZZ (đối với
chính sách với các bộ điều chỉnh quy mô khác).


Công cụ theo dõi
-------------

ZZ0000ZZ có thể ghi và phân tích nhật ký theo dõi ZZ0001ZZ, sau đó
tạo ra các biểu đồ hiệu suất. Tiện ích này có thể được sử dụng để gỡ lỗi và điều chỉnh
hiệu suất của trình điều khiển ZZ0002ZZ. Công cụ theo dõi cần nhập intel
chất đánh dấu pstate.

Công cụ theo dõi nằm trong ZZ0000ZZ. Nó có thể
được sử dụng theo hai cách. Nếu có sẵn tệp theo dõi, thì hãy phân tích trực tiếp tệp
bằng lệnh ::

./amd_pstate_trace.py [-c cpu] -t <trace_file> -n <test_name>

Hoặc tạo tệp theo dõi với quyền root, sau đó phân tích cú pháp và vẽ đồ thị bằng lệnh ::

sudo ./amd_pstate_trace.py [-c cpus] -n <test_name> -i <interval> [-m kbyte]

Kết quả kiểm tra có thể được tìm thấy trong ZZ0000ZZ. Sau đây là ví dụ
về một phần sản lượng. ::

common_cpu common_secs common_usecs min_perf des_perf max_perf tần suất tối đa apef tsc thời lượng tải_ms sample_num elapsed_time common_comm
 CPU_005 712 116384 39 49 166 0,7565 9645075 2214891 38431470 25,1 11,646 469 2,496 kworker/5:0-40
 CPU_006 712 116408 39 49 166 0,6769 8950227 1839034 37192089 24,06 11,272 470 2,496 kworker/6:0-1264

Kiểm tra đơn vị cho amd-pstate
-------------------------

ZZ0000ZZ là mô-đun thử nghiệm để kiểm tra trình điều khiển ZZ0001ZZ.

* Nó có thể giúp tất cả người dùng xác minh sự hỗ trợ của bộ xử lý của họ (SBIOS/Firmware hoặc Hardware).

* Kernel có thể có một bài kiểm tra chức năng cơ bản để tránh hồi quy kernel trong quá trình cập nhật.

* Chúng tôi có thể giới thiệu nhiều thử nghiệm chức năng hoặc hiệu suất hơn để căn chỉnh kết quả với nhau, điều này sẽ mang lại lợi ích cho việc tối ưu hóa quy mô hiệu suất và sức mạnh.

1. Mô tả test case

1). Kiểm tra cơ bản

Kiểm tra các chức năng cơ bản và tiên quyết của trình điều khiển ZZ0000ZZ.

+----------+--------------------------------+------------------------------------------------------------------------------------+
        ZZ0004ZZ Chức năng ZZ0005ZZ
        +==========+========================================================== ===============================================================================================================
        ZZ0006ZZ amd_pstate_ut_acpi_cpc_valid |ZZ0007ZZ
        ZZ0008ZZ |ZZ0009ZZ
        ZZ0010ZZ |ZZ0011ZZ
        +----------+--------------------------------+------------------------------------------------------------------------------------+
        ZZ0012ZZ amd_pstate_ut_check_enabled |ZZ0013ZZ
        ZZ0014ZZ |ZZ0015ZZ
        ZZ0016ZZ |ZZ0017ZZ
        ZZ0018ZZ ZZ0019ZZ
        ZZ0020ZZ ZZ0021ZZ
        ZZ0022ZZ ZZ0023ZZ
        +----------+--------------------------------+------------------------------------------------------------------------------------+
        ZZ0024ZZ amd_pstate_ut_check_perf |ZZ0025ZZ
        ZZ0026ZZ |ZZ0027ZZ
        +----------+--------------------------------+------------------------------------------------------------------------------------+
        ZZ0028ZZ amd_pstate_ut_check_freq |ZZ0029ZZ
        ZZ0030ZZ ZZ0031ZZ
        ZZ0032ZZ |ZZ0033ZZ
        ZZ0034ZZ |ZZ0035ZZ
        ZZ0036ZZ ZZ0037ZZ
        +----------+--------------------------------+------------------------------------------------------------------------------------+

2). Kiểm tra Tbench

Kiểm tra và theo dõi những thay đổi của CPU khi chạy điểm chuẩn tbench theo bộ điều chỉnh được chỉ định.
        Những thay đổi này bao gồm hiệu suất mong muốn, tần suất, tải, hiệu suất, năng lượng, v.v.
        Thống đốc được chỉ định là ondemand hoặc schedutil.
        Tbench cũng có thể được test trên kernel driver ZZ0000ZZ để so sánh.

3). Kiểm tra nguồn Git

        Test and monitor the cpu changes when running gitsource benchmark under the specified governor.
        These changes include desire performance, frequency, load, time, energy etc.
        The specified governor is ondemand or schedutil.
        Gitsource can also be tested on the ``acpi-cpufreq`` kernel driver for comparison.

#. Cách thực hiện các bài kiểm tra

   We use test module in the kselftest frameworks to implement it.
   We create ``amd-pstate-ut`` module and tie it into kselftest.(for
   details refer to Linux Kernel Selftests [4]_).

    1). Build

        + open the :c:macro:`CONFIG_X86_AMD_PSTATE` configuration option.
        + set the :c:macro:`CONFIG_X86_AMD_PSTATE_UT` configuration option to M.
        + make project
        + make selftest ::

            $ cd linux
            $ make -C tools/testing/selftests

        + make perf ::

            $ cd tools/perf/
            $ make


    2). Installation & Steps ::

        $ make -C tools/testing/selftests install INSTALL_PATH=~/kselftest
        $ cp tools/perf/perf /usr/bin/perf
        $ sudo ./kselftest/run_kselftest.sh -c amd-pstate

    3). Specified test case ::

        $ cd ~/kselftest/amd-pstate
        $ sudo ./run.sh -t basic
        $ sudo ./run.sh -t tbench
        $ sudo ./run.sh -t tbench -m acpi-cpufreq
        $ sudo ./run.sh -t gitsource
        $ sudo ./run.sh -t gitsource -m acpi-cpufreq
        $ ./run.sh --help
        ./run.sh: illegal option -- -
        Usage: ./run.sh [OPTION...]
                [-h <help>]
                [-o <output-file-for-dump>]
                [-c <all: All testing,
                     basic: Basic testing,
                     tbench: Tbench testing,
                     gitsource: Gitsource testing.>]
                [-t <tbench time limit>]
                [-p <tbench process number>]
                [-l <loop times for tbench>]
                [-i <amd tracer interval>]
                [-m <comparative test: acpi-cpufreq>]


    4). Results

        + basic

         When you finish test, you will get the following log info ::

          $ dmesg | grep "amd_pstate_ut" | tee log.txt
          [12977.570663] amd_pstate_ut: 1    amd_pstate_ut_acpi_cpc_valid  success!
          [12977.570673] amd_pstate_ut: 2    amd_pstate_ut_check_enabled   success!
          [12977.571207] amd_pstate_ut: 3    amd_pstate_ut_check_perf      success!
          [12977.571212] amd_pstate_ut: 4    amd_pstate_ut_check_freq      success!

        + tbench

         When you finish test, you will get selftest.tbench.csv and png images.
         The selftest.tbench.csv file contains the raw data and the drop of the comparative test.
         The png images shows the performance, energy and performan per watt of each test.
         Open selftest.tbench.csv :

         +-------------------------------------------------+--------------+----------+---------+----------+-------------+---------+----------------------+
         + Governor                                        | Round        | Des-perf | Freq    | Load     | Performance | Energy  | Performance Per Watt |
         +-------------------------------------------------+--------------+----------+---------+----------+-------------+---------+----------------------+
         + Unit                                            |              |          | GHz     |          | MB/s        | J       | MB/J                 |
         +=================================================+==============+==========+=========+==========+=============+=========+======================+
         + amd-pstate-ondemand                             | 1            |          |         |          | 2504.05     | 1563.67 | 158.5378             |
         +-------------------------------------------------+--------------+----------+---------+----------+-------------+---------+----------------------+
         + amd-pstate-ondemand                             | 2            |          |         |          | 2243.64     | 1430.32 | 155.2941             |
         +-------------------------------------------------+--------------+----------+---------+----------+-------------+---------+----------------------+
         + amd-pstate-ondemand                             | 3            |          |         |          | 2183.88     | 1401.32 | 154.2860             |
         +-------------------------------------------------+--------------+----------+---------+----------+-------------+---------+----------------------+
         + amd-pstate-ondemand                             | Average      |          |         |          | 2310.52     | 1465.1  | 156.1268             |
         +-------------------------------------------------+--------------+----------+---------+----------+-------------+---------+----------------------+
         + amd-pstate-schedutil                            | 1            | 165.329  | 1.62257 | 99.798   | 2136.54     | 1395.26 | 151.5971             |
         +-------------------------------------------------+--------------+----------+---------+----------+-------------+---------+----------------------+
         + amd-pstate-schedutil                            | 2            | 166      | 1.49761 | 99.9993  | 2100.56     | 1380.5  | 150.6377             |
         +-------------------------------------------------+--------------+----------+---------+----------+-------------+---------+----------------------+
         + amd-pstate-schedutil                            | 3            | 166      | 1.47806 | 99.9993  | 2084.12     | 1375.76 | 149.9737             |
         +-------------------------------------------------+--------------+----------+---------+----------+-------------+---------+----------------------+
         + amd-pstate-schedutil                            | Average      | 165.776  | 1.53275 | 99.9322  | 2107.07     | 1383.84 | 150.7399             |
         +-------------------------------------------------+--------------+----------+---------+----------+-------------+---------+----------------------+
         + acpi-cpufreq-ondemand                           | 1            |          |         |          | 2529.9      | 1564.4  | 160.0997             |
         +-------------------------------------------------+--------------+----------+---------+----------+-------------+---------+----------------------+
         + acpi-cpufreq-ondemand                           | 2            |          |         |          | 2249.76     | 1432.97 | 155.4297             |
         +-------------------------------------------------+--------------+----------+---------+----------+-------------+---------+----------------------+
         + acpi-cpufreq-ondemand                           | 3            |          |         |          | 2181.46     | 1406.88 | 153.5060             |
         +-------------------------------------------------+--------------+----------+---------+----------+-------------+---------+----------------------+
         + acpi-cpufreq-ondemand                           | Average      |          |         |          | 2320.37     | 1468.08 | 156.4741             |
         +-------------------------------------------------+--------------+----------+---------+----------+-------------+---------+----------------------+
         + acpi-cpufreq-schedutil                          | 1            |          |         |          | 2137.64     | 1385.24 | 152.7723             |
         +-------------------------------------------------+--------------+----------+---------+----------+-------------+---------+----------------------+
         + acpi-cpufreq-schedutil                          | 2            |          |         |          | 2107.05     | 1372.23 | 152.0138             |
         +-------------------------------------------------+--------------+----------+---------+----------+-------------+---------+----------------------+
         + acpi-cpufreq-schedutil                          | 3            |          |         |          | 2085.86     | 1365.35 | 151.2433             |
         +-------------------------------------------------+--------------+----------+---------+----------+-------------+---------+----------------------+
         + acpi-cpufreq-schedutil                          | Average      |          |         |          | 2110.18     | 1374.27 | 152.0136             |
         +-------------------------------------------------+--------------+----------+---------+----------+-------------+---------+----------------------+
         + acpi-cpufreq-ondemand VS acpi-cpufreq-schedutil | Comprison(%) |          |         |          | -9.0584     | -6.3899 | -2.8506              |
         +-------------------------------------------------+--------------+----------+---------+----------+-------------+---------+----------------------+
         + amd-pstate-ondemand VS amd-pstate-schedutil     | Comprison(%) |          |         |          | 8.8053      | -5.5463 | -3.4503              |
         +-------------------------------------------------+--------------+----------+---------+----------+-------------+---------+----------------------+
         + acpi-cpufreq-ondemand VS amd-pstate-ondemand    | Comprison(%) |          |         |          | -0.4245     | -0.2029 | -0.2219              |
         +-------------------------------------------------+--------------+----------+---------+----------+-------------+---------+----------------------+
         + acpi-cpufreq-schedutil VS amd-pstate-schedutil  | Comprison(%) |          |         |          | -0.1473     | 0.6963  | -0.8378              |
         +-------------------------------------------------+--------------+----------+---------+----------+-------------+---------+----------------------+

        + gitsource

         When you finish test, you will get selftest.gitsource.csv and png images.
         The selftest.gitsource.csv file contains the raw data and the drop of the comparative test.
         The png images shows the performance, energy and performan per watt of each test.
         Open selftest.gitsource.csv :

         +-------------------------------------------------+--------------+----------+----------+----------+-------------+---------+----------------------+
         + Governor                                        | Round        | Des-perf | Freq     | Load     | Time        | Energy  | Performance Per Watt |
         +-------------------------------------------------+--------------+----------+----------+----------+-------------+---------+----------------------+
         + Unit                                            |              |          | GHz      |          | s           | J       | 1/J                  |
         +=================================================+==============+==========+==========+==========+=============+=========+======================+
         + amd-pstate-ondemand                             | 1            | 50.119   | 2.10509  | 23.3076  | 475.69      | 865.78  | 0.001155027          |
         +-------------------------------------------------+--------------+----------+----------+----------+-------------+---------+----------------------+
         + amd-pstate-ondemand                             | 2            | 94.8006  | 1.98771  | 56.6533  | 467.1       | 839.67  | 0.001190944          |
         +-------------------------------------------------+--------------+----------+----------+----------+-------------+---------+----------------------+
         + amd-pstate-ondemand                             | 3            | 76.6091  | 2.53251  | 43.7791  | 467.69      | 855.85  | 0.001168429          |
         +-------------------------------------------------+--------------+----------+----------+----------+-------------+---------+----------------------+
         + amd-pstate-ondemand                             | Average      | 73.8429  | 2.20844  | 41.2467  | 470.16      | 853.767 | 0.001171279          |
         +-------------------------------------------------+--------------+----------+----------+----------+-------------+---------+----------------------+
         + amd-pstate-schedutil                            | 1            | 165.919  | 1.62319  | 98.3868  | 464.17      | 866.8   | 0.001153668          |
         +-------------------------------------------------+--------------+----------+----------+----------+-------------+---------+----------------------+
         + amd-pstate-schedutil                            | 2            | 165.97   | 1.31309  | 99.5712  | 480.15      | 880.4   | 0.001135847          |
         +-------------------------------------------------+--------------+----------+----------+----------+-------------+---------+----------------------+
         + amd-pstate-schedutil                            | 3            | 165.973  | 1.28448  | 99.9252  | 481.79      | 867.02  | 0.001153375          |
         +-------------------------------------------------+--------------+----------+----------+----------+-------------+---------+----------------------+
         + amd-pstate-schedutil                            | Average      | 165.954  | 1.40692  | 99.2944  | 475.37      | 871.407 | 0.001147569          |
         +-------------------------------------------------+--------------+----------+----------+----------+-------------+---------+----------------------+
         + acpi-cpufreq-ondemand                           | 1            |          |          |          | 2379.62     | 742.96  | 0.001345967          |
         +-------------------------------------------------+--------------+----------+----------+----------+-------------+---------+----------------------+
         + acpi-cpufreq-ondemand                           | 2            |          |          |          | 441.74      | 817.49  | 0.001223256          |
         +-------------------------------------------------+--------------+----------+----------+----------+-------------+---------+----------------------+
         + acpi-cpufreq-ondemand                           | 3            |          |          |          | 455.48      | 820.01  | 0.001219497          |
         +-------------------------------------------------+--------------+----------+----------+----------+-------------+---------+----------------------+
         + acpi-cpufreq-ondemand                           | Average      |          |          |          | 425.613     | 793.487 | 0.001260260          |
         +-------------------------------------------------+--------------+----------+----------+----------+-------------+---------+----------------------+
         + acpi-cpufreq-schedutil                          | 1            |          |          |          | 459.69      | 838.54  | 0.001192548          |
         +-------------------------------------------------+--------------+----------+----------+----------+-------------+---------+----------------------+
         + acpi-cpufreq-schedutil                          | 2            |          |          |          | 466.55      | 830.89  | 0.001203528          |
         +-------------------------------------------------+--------------+----------+----------+----------+-------------+---------+----------------------+
         + acpi-cpufreq-schedutil                          | 3            |          |          |          | 470.38      | 837.32  | 0.001194286          |
         +-------------------------------------------------+--------------+----------+----------+----------+-------------+---------+----------------------+
         + acpi-cpufreq-schedutil                          | Average      |          |          |          | 465.54      | 835.583 | 0.001196769          |
         +-------------------------------------------------+--------------+----------+----------+----------+-------------+---------+----------------------+
         + acpi-cpufreq-ondemand VS acpi-cpufreq-schedutil | Comprison(%) |          |          |          | 9.3810      | 5.3051  | -5.0379              |
         +-------------------------------------------------+--------------+----------+----------+----------+-------------+---------+----------------------+
         + amd-pstate-ondemand VS amd-pstate-schedutil     | Comprison(%) | 124.7392 | -36.2934 | 140.7329 | 1.1081      | 2.0661  | -2.0242              |
         +-------------------------------------------------+--------------+----------+----------+----------+-------------+---------+----------------------+
         + acpi-cpufreq-ondemand VS amd-pstate-ondemand    | Comprison(%) |          |          |          | 10.4665     | 7.5968  | -7.0605              |
         +-------------------------------------------------+--------------+----------+----------+----------+-------------+---------+----------------------+
         + acpi-cpufreq-schedutil VS amd-pstate-schedutil  | Comprison(%) |          |          |          | 2.1115      | 4.2873  | -4.1110              |
         +-------------------------------------------------+--------------+----------+----------+----------+-------------+---------+----------------------+

Reference
===========

.. [1] AMD64 Architecture Programmer's Manual Volume 2: System Programming,
       https://docs.amd.com/v/u/en-US/24593_3.44_APM_Vol2

.. [2] Advanced Configuration and Power Interface Specification,
       https://uefi.org/sites/default/files/resources/ACPI_Spec_6_4_Jan22.pdf

.. [3] Processor Programming Reference (PPR) for AMD Family 19h Model 51h, Revision A1 Processors
       https://docs.amd.com/v/u/en-US/56569-A1-PUB_3.03

.. [4] Linux Kernel Selftests,
       https://www.kernel.org/doc/html/latest/dev-tools/kselftest.html