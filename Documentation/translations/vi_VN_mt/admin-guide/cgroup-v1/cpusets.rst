.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/cgroup-v1/cpusets.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _cpusets:

=======
CPUSETS
=======

Bản quyền (C) 2004 BULL SA.

Viết bởi Simon.Derr@bull.net

- Các phần Bản quyền (c) 2004-2006 Silicon Graphics, Inc.
- Được sửa đổi bởi Paul Jackson <pj@sgi.com>
- Được sửa đổi bởi Christoph Lameter <cl@gentwo.org>
- Được sửa đổi bởi Paul Menage <menage@google.com>
- Được sửa đổi bởi Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>

.. CONTENTS:

   1. Cpusets
     1.1 What are cpusets ?
     1.2 Why are cpusets needed ?
     1.3 How are cpusets implemented ?
     1.4 What are exclusive cpusets ?
     1.5 What is memory_pressure ?
     1.6 What is memory spread ?
     1.7 What is sched_load_balance ?
     1.8 What is sched_relax_domain_level ?
     1.9 How do I use cpusets ?
   2. Usage Examples and Syntax
     2.1 Basic Usage
     2.2 Adding/removing cpus
     2.3 Setting flags
     2.4 Attaching processes
   3. Questions
   4. Contact

1. CPU
==========

1.1 CPUset là gì?
----------------------

Cpusets cung cấp cơ chế gán một bộ CPU và bộ nhớ
Các nút cho một tập hợp các nhiệm vụ.   Trong tài liệu này "Nút bộ nhớ" đề cập đến
một nút trực tuyến có chứa bộ nhớ.

Cpusets giới hạn các tác vụ CPU và Bộ nhớ chỉ ở mức
các tài nguyên trong bộ CPU hiện tại của tác vụ.  Chúng tạo thành một lồng nhau
hệ thống phân cấp hiển thị trong một hệ thống tập tin ảo.  Đây là những điều thiết yếu
móc, ngoài những gì đã có, cần thiết để quản lý động
bố trí công việc trên các hệ thống lớn.

Cpusets sử dụng hệ thống con cgroup chung được mô tả trong
Tài liệu/admin-guide/cgroup-v1/cgroups.rst.

Yêu cầu bởi một tác vụ, sử dụng lệnh gọi hệ thống sched_setaffinity(2) tới
bao gồm các CPU trong mặt nạ ái lực CPU của nó và sử dụng mbind(2) và
lệnh gọi hệ thống set_mempolicy(2) để đưa Nút bộ nhớ vào bộ nhớ của nó
chính sách, cả hai đều được lọc qua bộ xử lý của tác vụ đó, lọc ra bất kỳ
CPU hoặc Nút bộ nhớ không có trong bộ CPU đó.  Bộ lập lịch sẽ không
lên lịch tác vụ trên CPU không được phép trong cpus_allowed của nó
vector và bộ cấp phát trang kernel sẽ không cấp phát một trang trên
nút không được phép trong vectơ mems_allowed của tác vụ yêu cầu.

Mã cấp độ người dùng có thể tạo và hủy các bộ CPU theo tên trong nhóm
hệ thống tập tin ảo, quản lý các thuộc tính và quyền của chúng
cpuset và CPU và Nút bộ nhớ nào được gán cho mỗi cpuset,
chỉ định và truy vấn CPUset nào được gán tác vụ và liệt kê
pid nhiệm vụ được gán cho một cpuset.


1.2 Tại sao cần CPUset?
----------------------------

Việc quản lý các hệ thống máy tính lớn, có nhiều bộ xử lý (CPU),
hệ thống phân cấp bộ nhớ đệm phức tạp và nhiều Nút bộ nhớ có
thời gian truy cập không đồng nhất (NUMA) đặt ra những thách thức bổ sung cho
lập kế hoạch hiệu quả và sắp xếp bộ nhớ của các tiến trình.

Các hệ thống có kích thước khiêm tốn hơn thường có thể được vận hành với đầy đủ
hiệu quả chỉ bằng cách để hệ điều hành tự động chia sẻ
tài nguyên CPU và Bộ nhớ có sẵn trong số các tác vụ được yêu cầu.

Nhưng các hệ thống lớn hơn sẽ được hưởng lợi nhiều hơn từ bộ xử lý cẩn thận và
vị trí bộ nhớ để giảm thời gian truy cập và tranh chấp bộ nhớ,
và thường thể hiện khoản đầu tư lớn hơn cho khách hàng,
có thể được hưởng lợi từ việc đặt công việc một cách rõ ràng trên các tập hợp con có kích thước phù hợp
hệ thống.

Điều này có thể đặc biệt có giá trị trên:

* Máy chủ Web chạy nhiều phiên bản của cùng một ứng dụng web,
    * Máy chủ chạy các ứng dụng khác nhau (ví dụ: máy chủ web
      và cơ sở dữ liệu), hoặc
    * Hệ thống NUMA chạy các ứng dụng HPC lớn với yêu cầu khắt khe
      đặc điểm hiệu suất.

Các tập hợp con hoặc "phân vùng mềm" này phải có khả năng hoạt động linh hoạt
được điều chỉnh khi cơ cấu công việc thay đổi mà không ảnh hưởng đến các công việc khác
thực hiện các công việc. Vị trí của các trang việc làm đang chạy cũng có thể được di chuyển
khi vị trí bộ nhớ bị thay đổi.

Bản vá cpuset kernel cung cấp kernel cần thiết tối thiểu
các cơ chế cần thiết để thực hiện hiệu quả các tập hợp con đó.  Nó
tận dụng các cơ sở CPU và Vị trí bộ nhớ hiện có trong Linux
kernel để tránh bất kỳ tác động bổ sung nào lên bộ lập lịch quan trọng hoặc
mã cấp phát bộ nhớ.


1.3 CPUset được triển khai như thế nào?
---------------------------------

Cpusets cung cấp cơ chế nhân Linux để hạn chế CPU và
Nút bộ nhớ được sử dụng bởi một quy trình hoặc một tập hợp các quy trình.

Nhân Linux đã có sẵn một cặp cơ chế để xác định cơ chế nào
CPU, một tác vụ có thể được lên lịch (sched_setaffinity) và trên đó Bộ nhớ
Các nút có thể lấy bộ nhớ (mbind, set_mempolicy).

Cpusets mở rộng hai cơ chế này như sau:

- Cpusets là tập hợp các CPU và Nút bộ nhớ được phép, được biết đến bởi
   hạt nhân.
 - Mỗi tác vụ trong hệ thống được gắn vào một CPUset, thông qua một con trỏ
   trong cấu trúc nhiệm vụ sang cấu trúc cgroup được tính tham chiếu.
 - Các cuộc gọi tới sched_setaffinity chỉ được lọc cho những CPU đó
   được phép trong cpuset của tác vụ đó.
 - Các lệnh gọi tới mbind và set_mempolicy được lọc chỉ còn
   những Nút bộ nhớ được phép trong bộ xử lý của tác vụ đó.
 - CPUset gốc chứa tất cả CPU và bộ nhớ của hệ thống
   Nút.
 - Đối với bất kỳ CPUset nào, người ta có thể xác định các CPUset con chứa một tập hợp con
   của các tài nguyên CPU và Nút bộ nhớ gốc.
 - Hệ thống phân cấp của cpuset có thể được gắn tại /dev/cpuset, dành cho
   duyệt và thao tác từ không gian người dùng.
 - Một CPUset có thể được đánh dấu độc quyền, đảm bảo rằng không có CPU nào khác
   cpuset (trừ tổ tiên và con cháu trực tiếp) có thể chứa
   bất kỳ CPU hoặc Nút bộ nhớ chồng chéo nào.
 - Bạn có thể liệt kê tất cả các tác vụ (theo pid) gắn liền với bất kỳ CPUset nào.

Việc triển khai cpuset yêu cầu một vài móc nối đơn giản
vào phần còn lại của kernel, không có đường dẫn quan trọng nào về hiệu năng:

- trong init/main.c, để khởi tạo bộ CPU gốc khi khởi động hệ thống.
 - trong fork và exit, để đính kèm và tách một tác vụ khỏi bộ xử lý của nó.
 - trong sched_setaffinity, để che dấu các CPU được yêu cầu bằng những gì
   được phép trong cpuset của tác vụ đó.
 - trong sched.c Migrate_live_tasks(), để tiếp tục di chuyển các tác vụ trong
   các CPU được CPUset của họ cho phép, nếu có thể.
 - trong lệnh gọi hệ thống mbind và set_mempolicy, để che giấu yêu cầu
   Nút bộ nhớ theo mức được phép trong bộ xử lý của tác vụ đó.
 - trong page_alloc.c, để hạn chế bộ nhớ ở các nút được phép.
 - trong vmscan.c, để hạn chế việc khôi phục trang đối với bộ xử lý hiện tại.

Bạn nên gắn loại hệ thống tập tin "cgroup" để kích hoạt
duyệt và sửa đổi các bộ xử lý hiện có trong kernel.  Không
các lệnh gọi hệ thống mới được thêm vào cho bộ CPU - tất cả đều hỗ trợ truy vấn và
sửa đổi cpusets là thông qua hệ thống tập tin cpuset này.

Tệp /proc/<pid>/status cho mỗi tác vụ có thêm bốn dòng,
hiển thị cpus_allowed của tác vụ (trên CPU nào nó có thể được lên lịch)
và mems_allowed (trên Nút bộ nhớ nào nó có thể lấy bộ nhớ),
ở hai định dạng được thấy trong ví dụ sau::

Cpus_allowed: ffffffff,ffffffff,ffffffff,ffffffff
  Cpus_allowed_list: 0-127
  Mems_allowed: ffffffff,ffffffff
  Mems_allowed_list: 0-63

Mỗi CPUset được đại diện bởi một thư mục trong hệ thống tập tin cgroup
chứa (trên đầu các tệp cgroup tiêu chuẩn) như sau
các tập tin mô tả cpuset đó:

- cpuset.cpus: danh sách các CPU trong cpuset đó
 - cpuset.mems: danh sách các Memory Node trong cpuset đó
 - cờ cpuset.memory_migrate: nếu được đặt, hãy di chuyển các trang đến các nút cpusets
 - cờ cpuset.cpu_exclusive: vị trí cpu có độc quyền không?
 - cờ cpuset.mem_exclusive: vị trí bộ nhớ có độc quyền không?
 - cờ cpuset.mem_hardwall: phân bổ bộ nhớ có vách cứng không
 - cpuset.memory_ Pressure: đo áp lực phân trang trong cpuset là bao nhiêu
 - cờ cpuset.memory_s Lan_page: nếu được đặt, hãy trải đều bộ đệm trang trên các nút được phép
 - cờ cpuset.memory_s Lan_slab: OBSOLETE. Không có bất kỳ chức năng nào.
 - cờ cpuset.sched_load_balance: nếu được đặt, cân bằng tải trong các CPU trên cpuset đó
 - cpuset.sched_relax_domain_level: phạm vi tìm kiếm khi di chuyển tác vụ

Ngoài ra, chỉ có cpuset gốc mới có tệp sau:

- cờ cpuset.memory_ Pressure_enabled: tính toán Memory_ Pressure?

Các CPUset mới được tạo bằng lệnh gọi hệ thống mkdir hoặc shell
lệnh.  Các thuộc tính của CPUset, chẳng hạn như cờ của nó, được cho phép
CPU và Nút bộ nhớ cũng như các tác vụ đính kèm được sửa đổi bằng cách ghi
vào tệp thích hợp trong thư mục cpusets đó, như được liệt kê ở trên.

Cấu trúc phân cấp được đặt tên của các bộ CPU lồng nhau cho phép phân vùng
một hệ thống lớn thành các "phân vùng mềm" lồng nhau, có thể thay đổi linh hoạt.

Phần đính kèm của từng nhiệm vụ, được kế thừa tự động tại ngã ba bởi bất kỳ
nhiệm vụ đó, để một cpuset cho phép tổ chức khối lượng công việc
trên hệ thống thành các tập nhiệm vụ có liên quan sao cho mỗi tập bị ràng buộc
đến việc sử dụng CPU và Nút bộ nhớ của một bộ CPU cụ thể.  một nhiệm vụ
có thể được gắn lại vào bất kỳ cpuset nào khác, nếu được phép
trên các thư mục hệ thống tập tin cpuset cần thiết.

Việc quản lý một hệ thống "trên diện rộng" như vậy tích hợp trơn tru với
vị trí chi tiết được thực hiện trên các tác vụ và vùng bộ nhớ riêng lẻ
bằng cách sử dụng lệnh gọi hệ thống sched_setaffinity, mbind và set_mempolicy.

Các quy tắc sau đây áp dụng cho từng CPUset:

- CPU và Nút bộ nhớ của nó phải là tập hợp con của nút cha.
 - Nó không thể được đánh dấu độc quyền trừ khi cha mẹ của nó là độc quyền.
 - Nếu CPU hoặc bộ nhớ của nó là độc quyền thì chúng không được trùng lặp với bất kỳ anh chị em nào.

Các quy tắc này và hệ thống phân cấp tự nhiên của bộ xử lý CPU cho phép sử dụng hiệu quả
thực thi bảo đảm độc quyền mà không cần phải quét tất cả
cpuset mỗi khi chúng thay đổi để đảm bảo không có gì trùng lặp
bộ xử lý độc quyền.  Ngoài ra, việc sử dụng hệ thống tệp ảo Linux (vfs)
để thể hiện hệ thống phân cấp cpuset cung cấp một quyền quen thuộc
và không gian tên cho CPUset, với tối thiểu mã hạt nhân bổ sung.

Các tập tin cpus và mems trong cpuset gốc (top_cpuset) là
chỉ đọc.  Tệp cpus tự động theo dõi giá trị của
cpu_online_mask bằng trình thông báo cắm nóng CPU và tệp mems
tự động theo dõi giá trị của node_states[N_MEMORY]--tức là
các nút có bộ nhớ--sử dụng hook cpuset_track_online_nodes().

Các tệp cpuset.effect_cpus và cpuset.effect_mems là
bản sao thông thường chỉ đọc của các tập tin cpuset.cpus và cpuset.mems
tương ứng.  Nếu hệ thống tập tin cpuset cgroup được gắn với
tùy chọn "cpuset_v2_mode" đặc biệt, hoạt động của các tệp này sẽ trở thành
tương tự như các tệp tương ứng trong cpuset v2.  Nói cách khác, cắm nóng
các sự kiện sẽ không thay đổi cpuset.cpus và cpuset.mems.  Những sự kiện đó sẽ
chỉ ảnh hưởng đến cpuset.effect_cpus và cpuset.effect_mems hiển thị
CPU thực tế và các nút bộ nhớ hiện đang được CPUset này sử dụng.
Xem Tài liệu/admin-guide/cgroup-v2.rst để biết thêm thông tin về
hành vi cpuset v2.


1.4 CPUset độc quyền là gì?
--------------------------------

Nếu một CPUset là CPU hoặc Mem độc quyền thì không có CPUset nào khác ngoài
tổ tiên hoặc hậu duệ trực tiếp, có thể chia sẻ bất kỳ CPU hoặc
Các nút bộ nhớ.

CPUset là cpuset.mem_exclusive ZZ0000ZZ cpuset.mem_hardwall là "có tường cứng",
tức là nó hạn chế phân bổ kernel cho trang, bộ đệm và dữ liệu khác
thường được chia sẻ bởi kernel trên nhiều người dùng.  Tất cả các CPU,
dù có tường cứng hay không, hãy hạn chế việc phân bổ bộ nhớ cho người dùng
không gian.  Điều này cho phép cấu hình một hệ thống sao cho một số
công việc có thể chia sẻ dữ liệu kernel chung, chẳng hạn như các trang hệ thống tệp, trong khi
cô lập việc phân bổ người dùng của từng công việc trong bộ CPU riêng của nó.  Để làm điều này,
xây dựng một cpuset mem_exclusive lớn để chứa tất cả các công việc và
xây dựng các bộ CPU con, không phải mem_exclusive cho từng công việc riêng lẻ.
Chỉ một lượng nhỏ bộ nhớ kernel thông thường, chẳng hạn như các yêu cầu từ
trình xử lý ngắt, được phép đưa ra ngoài ngay cả
bộ xử lý mem_exclusive.


1.5 Áp suất bộ nhớ là gì?
-----------------------------
Áp suất bộ nhớ của CPUset cung cấp số liệu đơn giản cho mỗi CPU
về tốc độ mà các tác vụ trong CPUset đang cố gắng giải phóng trong
sử dụng bộ nhớ trên các nút của cpuset để đáp ứng bộ nhớ bổ sung
yêu cầu.

Điều này cho phép người quản lý hàng loạt giám sát các công việc đang chạy trong
cpuset để phát hiện hiệu quả mức độ áp lực bộ nhớ mà công việc đó
đang gây ra.

Điều này hữu ích cả trên các hệ thống được quản lý chặt chẽ chạy nhiều loại
các công việc đã gửi, có thể chọn chấm dứt hoặc tái ưu tiên các công việc
đang cố gắng sử dụng nhiều bộ nhớ hơn mức cho phép trên các nút được gán cho chúng,
và với sự kết hợp chặt chẽ, lâu dài, khoa học song song ồ ạt
các công việc tính toán sẽ không đáp ứng được hiệu suất cần thiết một cách đáng kể
mục tiêu nếu họ bắt đầu sử dụng nhiều bộ nhớ hơn mức cho phép.

Cơ chế này cung cấp một cách rất tiết kiệm cho người quản lý hàng loạt
để theo dõi CPUset để phát hiện các dấu hiệu áp lực bộ nhớ.  Tùy thuộc vào
trình quản lý lô hoặc mã người dùng khác để quyết định phải làm gì với nó và
hành động.

==>
    Trừ khi tính năng này được kích hoạt bằng cách ghi "1" vào tệp đặc biệt
    /dev/cpuset/memory_ Pressure_enabled, móc nối trong quá trình tái cân bằng
    mã __alloc_pages() cho số liệu này đơn giản chỉ là nhận thấy
    rằng cờ cpuset_memory_ Pressure_enabled bằng 0.  Vì vậy chỉ
    các hệ thống kích hoạt tính năng này sẽ tính toán số liệu.

Tại sao mỗi CPU chạy trung bình:

Bởi vì đồng hồ đo này được tính theo từng CPU, chứ không phải theo mỗi tác vụ hoặc mm,
    tải hệ thống được áp đặt bởi bộ lập lịch hàng loạt theo dõi việc này
    số liệu bị giảm mạnh trên các hệ thống lớn, vì việc quét
    danh sách nhiệm vụ có thể tránh được trên mỗi bộ truy vấn.

Bởi vì đồng hồ đo này là số trung bình đang chạy, thay vì số liệu tích lũy
    bộ đếm, bộ lập lịch hàng loạt có thể phát hiện áp lực bộ nhớ bằng một
    đọc một lần, thay vì phải đọc và tích lũy kết quả
    trong một khoảng thời gian.

Vì đồng hồ đo này tính theo mỗi cpuset chứ không phải theo mỗi tác vụ hoặc mm,
    bộ lập lịch hàng loạt có thể lấy thông tin chính, bộ nhớ
    áp lực trong một CPUset, chỉ với một lần đọc, thay vì phải
    truy vấn và tích lũy kết quả trên tất cả các (thay đổi động)
    tập hợp các tác vụ trong cpuset.

Bộ lọc kỹ thuật số đơn giản trên mỗi CPU (yêu cầu khóa xoay và 3 từ
dữ liệu trên mỗi cpuset) được lưu giữ và cập nhật bởi bất kỳ tác vụ nào gắn liền với nó
cpuset, nếu nó nhập mã lấy lại trang đồng bộ (trực tiếp).

Tệp trên mỗi cpuset cung cấp một số nguyên biểu thị giá trị gần đây
(thời gian bán hủy 10 giây) tốc độ lấy lại trang trực tiếp do
các tác vụ trong cpuset, tính theo đơn vị số lần thu hồi được thực hiện mỗi giây,
lần 1000.


1.6 Trải rộng bộ nhớ là gì?
---------------------------
Có hai tệp cờ boolean trên mỗi CPUset kiểm soát vị trí của
kernel phân bổ các trang cho bộ đệm hệ thống tập tin và liên quan đến
cấu trúc dữ liệu hạt nhân.  Chúng được gọi là 'cpuset.memory_s Lan_page' và
'cpuset.memory_s Lan_slab'.

Nếu tệp cờ boolean trên mỗi cpuset 'cpuset.memory_s Lan_page' được đặt thì
hạt nhân sẽ trải đều bộ đệm hệ thống tệp (bộ đệm trang)
thay vào đó, trên tất cả các nút mà tác vụ bị lỗi được phép sử dụng
thích đặt những trang đó vào nút nơi tác vụ đang chạy.

Nếu tệp cờ boolean trên mỗi cpuset 'cpuset.memory_s Lan_slab' được đặt,
sau đó kernel sẽ phát tán một số bộ đệm phiến liên quan đến hệ thống tệp,
chẳng hạn như đối với các nút và răng cưa đều trên tất cả các nút mà
tác vụ gây lỗi được phép sử dụng, thay vì ưu tiên đặt những tác vụ đó
các trang trên nút nơi tác vụ đang chạy.

Việc cài đặt các cờ này không ảnh hưởng đến phân đoạn dữ liệu ẩn danh hoặc
xếp chồng các trang phân đoạn của một tác vụ.

Theo mặc định, cả hai loại phân bổ bộ nhớ đều bị tắt và bộ nhớ
các trang được phân bổ trên nút cục bộ đến nơi tác vụ đang chạy,
ngoại trừ có lẽ được sửa đổi bởi bộ nhớ hoặc bộ xử lý NUMA của tác vụ
cấu hình, miễn là có đủ trang bộ nhớ trống.

Khi các bộ CPU mới được tạo, chúng sẽ kế thừa cài đặt phân bổ bộ nhớ
của cha mẹ họ.

Cài đặt trải rộng bộ nhớ gây ra sự phân bổ cho trang bị ảnh hưởng
hoặc bộ đệm phiến để bỏ qua chính sách ghi nhớ NUMA của nhiệm vụ và được lan truyền
thay vào đó.    Tác vụ sử dụng lệnh gọi mbind() hoặc set_mempolicy() để đặt NUMA
các chính sách sẽ không nhận thấy bất kỳ thay đổi nào trong các cuộc gọi này do
cài đặt phân bổ bộ nhớ của tác vụ chứa chúng.  Nếu bộ nhớ lan rộng
bị tắt thì chính sách ghi nhớ NUMA hiện được chỉ định lại một lần nữa
áp dụng cho việc phân bổ trang bộ nhớ.

Cả 'cpuset.memory_s Lan_page' và 'cpuset.memory_s Lan_slab' đều là cờ boolean
tập tin.  Theo mặc định chúng chứa "0", nghĩa là tính năng này bị tắt
cho bộ xử lý đó.  Nếu số "1" được ghi vào tệp đó thì điều đó sẽ
tính năng được đặt tên trên.

Việc thực hiện rất đơn giản.

Đặt cờ 'cpuset.memory_s Lan_page' sẽ bật cờ cho mỗi quy trình
PFA_SPREAD_PAGE cho mỗi tác vụ trong bộ CPU đó hoặc sau đó
tham gia cpuset đó.  Việc phân bổ trang yêu cầu bộ đệm trang
được sửa đổi để thực hiện kiểm tra nội tuyến cho tác vụ PFA_SPREAD_PAGE này
cờ và nếu được đặt, lệnh gọi đến một quy trình mới cpuset_mem_s Lan_node()
trả về nút thích hợp để phân bổ.

Tương tự, cài đặt “cpuset.memory_s Lan_slab” sẽ bật cờ
PFA_SPREAD_SLAB và các bộ đệm phiến được đánh dấu thích hợp sẽ phân bổ
các trang từ nút được trả về bởi cpuset_mem_s Lan_node().

Quy trình cpuset_mem_s Lan_node() cũng đơn giản.  Nó sử dụng
giá trị của rôto mỗi tác vụ cpuset_mem_s Lan_rotor để chọn mục tiếp theo
nút trong mems_allowed của tác vụ hiện tại để ưu tiên phân bổ.

Chính sách vị trí bộ nhớ này còn được gọi (trong các bối cảnh khác) là
quay vòng hoặc xen kẽ.

Chính sách này có thể mang lại những cải tiến đáng kể cho những công việc cần
để đặt dữ liệu cục bộ của luồng trên nút tương ứng, nhưng điều đó cần
để truy cập các tập dữ liệu hệ thống tệp lớn cần được trải rộng trên
một số nút trong bộ xử lý công việc để phù hợp.  Không có cái này
chính sách, đặc biệt đối với các công việc có thể có một luồng đọc trong
tập dữ liệu, phân bổ bộ nhớ trên các nút trong bộ xử lý công việc
có thể trở nên rất không đồng đều.

1.7 sched_load_balance là gì?
--------------------------------

Bộ lập lịch kernel (kernel/sched/core.c) tự động cân bằng tải
nhiệm vụ.  Nếu một CPU không được sử dụng đúng mức, mã kernel chạy trên đó
CPU sẽ tìm kiếm các tác vụ trên các CPU khác bị quá tải hơn và di chuyển chúng
nhiệm vụ cho chính nó, trong sự ràng buộc của các cơ chế sắp xếp như vậy
như cpusets và sched_setaffinity.

Chi phí thuật toán của cân bằng tải và tác động của nó đối với khóa chia sẻ
cấu trúc dữ liệu hạt nhân như danh sách tác vụ tăng nhiều hơn
tuyến tính với số lượng CPU được cân bằng.  Vì vậy bộ lập lịch
có hỗ trợ phân vùng CPU hệ thống thành một số lịch trình
các miền sao cho nó chỉ tải số dư trong mỗi miền được lập lịch.
Mỗi miền được lập lịch bao gồm một số tập hợp con CPU trong hệ thống;
không có hai miền được lập lịch trùng nhau; một số CPU có thể không có trong bất kỳ lịch trình nào
tên miền và do đó sẽ không được cân bằng tải.

Nói một cách đơn giản, việc cân bằng giữa hai miền được lập lịch nhỏ hơn sẽ tốn ít chi phí hơn
hơn một cái lớn, nhưng làm như vậy có nghĩa là quá tải ở một trong những
hai miền sẽ không được cân bằng tải với miền kia.

Theo mặc định, có một miền được lập lịch bao gồm tất cả các CPU, bao gồm cả các CPU đó.
được đánh dấu tách biệt bằng cách sử dụng đối số "isolcpus=" về thời gian khởi động kernel. Tuy nhiên,
các CPU bị cô lập sẽ không tham gia cân bằng tải và sẽ không
có nhiệm vụ chạy trên chúng trừ khi được giao rõ ràng.

Cân bằng tải mặc định này trên tất cả các CPU không phù hợp lắm với
hai tình huống sau:

1) Trên các hệ thống lớn, việc cân bằng tải trên nhiều CPU rất tốn kém.
    Nếu hệ thống được quản lý bằng CPUset để thực hiện các công việc độc lập
    trên các bộ CPU riêng biệt, việc cân bằng toàn tải là không cần thiết.
 2) Hệ thống hỗ trợ thời gian thực trên một số CPU cần giảm thiểu
    chi phí hệ thống trên các CPU đó, bao gồm cả việc tránh tải tác vụ
    cân bằng nếu không cần thiết.

Khi cờ mỗi cpuset "cpuset.sched_load_balance" được bật (mặc định
cài đặt), nó yêu cầu tất cả các CPU trong bộ CPU đó cho phép 'cpuset.cpus'
được chứa trong một miền được lập lịch duy nhất, đảm bảo rằng việc cân bằng tải
có thể di chuyển một nhiệm vụ (không được ghim theo cách khác, như sched_setaffinity)
từ bất kỳ CPU nào trong bộ xử lý đó đến bất kỳ bộ xử lý nào khác.

Khi cờ mỗi cpuset "cpuset.sched_load_balance" bị tắt thì
bộ lập lịch sẽ tránh cân bằng tải trên các CPU trong bộ CPU đó,
--ngoại trừ-- trong chừng mực cần thiết vì một số bộ xử lý chồng chéo
đã bật "sched_load_balance".

Vì vậy, ví dụ: nếu cpuset trên cùng có cờ "cpuset.sched_load_balance"
được bật thì bộ lập lịch sẽ có một miền được lập lịch bao gồm tất cả
CPU và cài đặt cờ "cpuset.sched_load_balance" trong bất kỳ thiết bị nào khác
cpuset sẽ không thành vấn đề vì chúng tôi đã cân bằng tải hoàn toàn.

Do đó trong hai tình huống trên, cờ cpuset trên cùng
"cpuset.sched_load_balance" phải bị tắt và chỉ một số nhỏ hơn,
CPUset con đã bật cờ này.

Khi thực hiện việc này, bạn thường không muốn để lại bất kỳ nhiệm vụ nào chưa được ghim trong
CPUset hàng đầu có thể sử dụng số lượng CPU không hề nhỏ, như các tác vụ như vậy
có thể bị hạn chế một cách giả tạo đối với một số tập hợp con CPU, tùy thuộc vào
các chi tiết của cài đặt cờ này trong các bộ CPU con cháu.  Kể cả nếu
một tác vụ như vậy có thể sử dụng các chu trình CPU dự phòng trong một số CPU khác, nhân
bộ lập lịch có thể không xem xét khả năng cân bằng tải
nhiệm vụ cho CPU chưa được sử dụng.

Tất nhiên, các tác vụ được ghim vào một CPU cụ thể có thể được để lại trong bộ xử lý
điều đó vô hiệu hóa "cpuset.sched_load_balance" vì những tác vụ đó sẽ không đi đến đâu
dù sao đi nữa.

Có sự không phù hợp về trở kháng ở đây, giữa bộ CPU và miền được lập lịch.
Cpusets có tính phân cấp và lồng nhau.  Các miền theo lịch trình đều bằng phẳng; họ không
chồng chéo và mỗi CPU nằm trong nhiều nhất một miền được lập lịch.

Điều cần thiết là các miền được lập lịch phải bằng phẳng vì việc cân bằng tải
trên các bộ CPU chồng chéo một phần sẽ có nguy cơ hoạt động không ổn định
điều đó vượt quá tầm hiểu biết của chúng ta.  Vì vậy, nếu mỗi trong hai một phần
các CPUset chồng chéo sẽ kích hoạt cờ 'cpuset.sched_load_balance', sau đó chúng tôi
tạo thành một miền được lập lịch duy nhất là siêu tập hợp của cả hai.  Chúng tôi sẽ không di chuyển
một nhiệm vụ cho CPU bên ngoài bộ xử lý của nó, nhưng cân bằng tải của bộ lập lịch
mã có thể lãng phí một số chu kỳ tính toán khi xem xét khả năng đó.

Sự không phù hợp này là lý do tại sao không có mối quan hệ một-một đơn giản
giữa các bộ CPU có cờ "cpuset.sched_load_balance" được bật,
và cấu hình miền theo lịch trình.  Nếu một CPUset kích hoạt cờ, nó
sẽ cân bằng trên tất cả các CPU của nó, nhưng nếu nó tắt cờ,
nó sẽ chỉ được đảm bảo không cân bằng tải nếu không có sự chồng chéo nào khác
cpuset kích hoạt cờ.

Nếu hai CPUset được phép chồng chéo một phần 'cpuset.cpus' và chỉ
một trong số họ đã bật cờ này thì người kia có thể tìm thấy cờ đó
các tác vụ chỉ được cân bằng tải một phần, chỉ trên các CPU chồng chéo.
Đây chỉ là trường hợp chung của ví dụ top_cpuset được đưa ra một vài
các đoạn trên.  Trong trường hợp chung, như trong trường hợp cpuset trên cùng,
đừng để những nhiệm vụ có thể sử dụng lượng CPU không hề nhỏ trong
các bộ CPU được cân bằng tải một phần như vậy, vì chúng có thể được thực hiện một cách giả tạo.
bị hạn chế ở một số tập hợp con của CPU được phép sử dụng chúng, vì thiếu
cân bằng tải cho các CPU khác.

Các CPU trong "cpuset.isolcpus" đã bị loại khỏi tính năng cân bằng tải bởi
isolcpus= tùy chọn khởi động kernel và sẽ không bao giờ được cân bằng tải bất kể
giá trị của "cpuset.sched_load_balance" trong bất kỳ cpuset nào.

1.7.1 chi tiết triển khai sched_load_balance.
------------------------------------------------

Cờ mỗi cpuset 'cpuset.sched_load_balance' mặc định được bật (ngược lại
với hầu hết các cờ cpuset.) Khi được bật cho một cpuset, kernel sẽ
đảm bảo rằng nó có thể cân bằng tải trên tất cả các CPU trong bộ CPU đó
(đảm bảo rằng tất cả các CPU trong cpus_allowed của cpuset đó đều được
trong cùng một miền được lập lịch.)

Nếu cả hai bộ CPU chồng chéo đều được bật 'cpuset.sched_load_balance',
thì chúng sẽ (phải) cả hai đều nằm trong cùng một miền được lập lịch.

Nếu, theo mặc định, bộ CPU hàng đầu đã bật 'cpuset.sched_load_balance',
thì theo cách trên, điều đó có nghĩa là có một miền được lập lịch duy nhất bao gồm
toàn bộ hệ thống, bất kể cài đặt cpuset nào khác.

Kernel cam kết với không gian người dùng rằng nó sẽ tránh việc cân bằng tải
nó có thể ở đâu.  Nó sẽ chọn một phân vùng chi tiết của lịch trình
miền nhất có thể trong khi vẫn cung cấp cân bằng tải cho bất kỳ bộ nào
số CPU được phép sử dụng CPUset có bật 'cpuset.sched_load_balance'.

Giao diện CPUset nhân bên trong tới bộ lập lịch chuyển từ
mã cpuset tới mã lịch trình một phân vùng được cân bằng tải
CPU trong hệ thống. Phân vùng này là một tập hợp các tập hợp con (được biểu diễn
như một mảng cấu trúc cpumask) của các CPU, tách rời theo cặp, bao gồm
tất cả các CPU phải được cân bằng tải.

Mã cpuset xây dựng một phân vùng mới như vậy và chuyển nó tới
mã thiết lập tên miền được lập lịch trình, để xây dựng lại các miền được lập lịch trình
khi cần thiết, bất cứ khi nào:

- cờ 'cpuset.sched_load_balance' của bộ xử lý có các thay đổi về CPU không trống,
 - hoặc CPU đến hoặc đi từ một bộ xử lý có bật cờ này,
 - hoặc giá trị 'cpuset.sched_relax_domain_level' của bộ CPU có CPU không trống
   và với những thay đổi được kích hoạt bằng cờ này,
 - hoặc một bộ xử lý có CPU không trống và khi cờ này được bật sẽ bị xóa,
 - hoặc CPU đang ngoại tuyến/trực tuyến.

Phân vùng này xác định chính xác những miền được lập lịch trình mà bộ lập lịch nên thực hiện
thiết lập - một miền được lập lịch cho mỗi phần tử (struct cpumask) trong
phân vùng.

Bộ lập lịch ghi nhớ các phân vùng miền được lập lịch hiện đang hoạt động.
Khi quy trình lập lịch phân vùng_sched_domains() được gọi từ
mã cpuset để cập nhật các tên miền được lập lịch này, nó sẽ so sánh tên miền mới
phân vùng được yêu cầu với hiện tại và cập nhật các miền theo lịch trình của nó,
loại bỏ cái cũ và thêm cái mới cho mỗi thay đổi.


1.8 sched_relax_domain_level là gì?
--------------------------------------

Trong miền lịch trình, bộ lập lịch di chuyển các tác vụ theo 2 cách; tải định kỳ
số dư theo từng tích tắc và tại thời điểm diễn ra một số sự kiện theo lịch trình.

Khi một tác vụ được đánh thức, bộ lập lịch sẽ cố gắng di chuyển tác vụ đó trên CPU không hoạt động.
Ví dụ: nếu tác vụ A chạy trên CPU X kích hoạt tác vụ B khác
trên cùng một CPU X và nếu CPU Y là anh chị em của X và đang hoạt động không hoạt động,
sau đó bộ lập lịch di chuyển tác vụ B sang CPU Y để tác vụ B có thể bắt đầu
CPU Y mà không cần chờ nhiệm vụ A trên CPU X.

Và nếu CPU hết nhiệm vụ trong hàng đợi, CPU sẽ cố gắng kéo
nhiệm vụ bổ sung từ các CPU bận rộn khác để trợ giúp chúng trước khi nó diễn ra
nhàn rỗi.

Tất nhiên phải mất một số chi phí tìm kiếm để tìm các nhiệm vụ có thể di chuyển và/hoặc
CPU nhàn rỗi, bộ lập lịch có thể không tìm kiếm tất cả các CPU trong miền
mọi lúc.  Trong thực tế, trong một số kiến trúc, việc tìm kiếm nằm trong phạm vi
các sự kiện được giới hạn trong cùng một ổ cắm hoặc nút nơi đặt CPU,
trong khi cân bằng tải tích vào tìm kiếm tất cả.

Ví dụ: giả sử CPU Z tương đối xa CPU X. Ngay cả khi CPU Z
không hoạt động trong khi CPU X và các anh chị em đang bận, bộ lập lịch không thể di chuyển
đánh thức tác vụ B từ X lên Z vì nó nằm ngoài phạm vi tìm kiếm của nó.
Kết quả là tác vụ B trên CPU X cần đợi tác vụ A hoặc chờ cân bằng tải
ở tích tắc tiếp theo.  Đối với một số ứng dụng trong tình huống đặc biệt, chờ đợi
1 tích tắc có thể quá dài.

Tệp 'cpuset.sched_relax_domain_level' cho phép bạn yêu cầu thay đổi
phạm vi tìm kiếm này như bạn muốn.  Tệp này có giá trị int
cho biết kích thước của phạm vi tìm kiếm ở các cấp độ xấp xỉ như sau,
mặt khác giá trị ban đầu -1 cho biết cpuset không có yêu cầu.

====== =================================================================
  -1 không có yêu cầu. sử dụng mặc định của hệ thống hoặc làm theo yêu cầu của người khác.
   0 không tìm kiếm.
   1 anh chị em tìm kiếm (siêu phân luồng trong lõi).
   2 lõi tìm kiếm trong một gói.
   3 CPU tìm kiếm trong một nút [= toàn hệ thống trên hệ thống không phải NUMA]
   4 nút tìm kiếm trong một đoạn nút [trên hệ thống NUMA]
   5 hệ thống tìm kiếm rộng [trên hệ thống NUMA]
====== =================================================================

Không phải tất cả các mức đều có thể hiện diện và các giá trị có thể thay đổi tùy theo
kiến trúc hệ thống và cấu hình kernel. Kiểm tra
/sys/kernel/debug/sched/domains/cpu*/domain*/ dành riêng cho hệ thống
chi tiết.

Mặc định của hệ thống phụ thuộc vào kiến ​​trúc.  Mặc định hệ thống
có thể được thay đổi bằng tham số khởi động Relax_domain_level=.

Tệp này dành cho mỗi CPU và ảnh hưởng đến miền được lập lịch nơi CPUset
thuộc về.  Do đó, nếu cờ 'cpuset.sched_load_balance' của cpuset
bị vô hiệu hóa thì 'cpuset.sched_relax_domain_level' không có hiệu lực kể từ đó
không có tên miền theo lịch trình thuộc về cpuset.

Nếu nhiều bộ xử lý chồng lên nhau và do đó chúng tạo thành một lịch trình duy nhất
tên miền, giá trị lớn nhất trong số đó được sử dụng.  Hãy cẩn thận, nếu một
yêu cầu 0 và các yêu cầu khác là -1 thì 0 được sử dụng.

Lưu ý rằng việc sửa đổi tập tin này sẽ có cả tác động tốt và xấu,
và liệu nó có được chấp nhận hay không tùy thuộc vào hoàn cảnh của bạn.
Đừng sửa đổi tập tin này nếu bạn không chắc chắn.

Nếu tình huống của bạn là:

- Chi phí di chuyển giữa mỗi CPU có thể được giả định đáng kể
   nhỏ (đối với bạn) do hành vi của ứng dụng đặc biệt của bạn hoặc
   hỗ trợ phần cứng đặc biệt cho bộ đệm CPU, v.v.
 - Chi phí tìm kiếm không ảnh hưởng (đối với bạn) hoặc bạn có thể thực hiện
   chi phí tìm kiếm đủ nhỏ bằng cách quản lý cpuset để thu gọn, v.v.
 - Cần có độ trễ ngay cả khi nó hy sinh tốc độ truy cập bộ đệm, v.v.
   thì việc tăng 'sched_relax_domain_level' sẽ có lợi cho bạn.


1.9 Làm cách nào để sử dụng CPUset?
--------------------------

Để giảm thiểu tác động của cpuset lên kernel quan trọng
mã, chẳng hạn như bộ lập lịch, và do thực tế là kernel
không hỗ trợ một tác vụ cập nhật vị trí bộ nhớ của tác vụ khác
tác vụ trực tiếp, tác động đến tác vụ thay đổi cpuset CPU của nó
hoặc vị trí Nút bộ nhớ hoặc thay đổi CPUset nào cho một tác vụ
được đính kèm, là tinh tế.

Nếu một CPUset có Nút bộ nhớ được sửa đổi thì đối với mỗi tác vụ được đính kèm
cho cpuset đó, lần tiếp theo kernel cố gắng phân bổ
một trang bộ nhớ dành cho tác vụ đó, kernel sẽ nhận thấy sự thay đổi
trong bộ xử lý của tác vụ và cập nhật vị trí bộ nhớ cho mỗi tác vụ của nó thành
vẫn nằm trong vị trí bộ nhớ cpuset mới.  Nếu tác vụ đang sử dụng
mempolicy MPOL_BIND và các nút được liên kết chồng chéo với
cpuset mới của nó thì tác vụ sẽ tiếp tục sử dụng bất kỳ tập hợp con nào
trong số các nút MPOL_BIND vẫn được phép trong bộ xử lý mới.  Nếu nhiệm vụ
đang sử dụng MPOL_BIND và hiện tại không có nút MPOL_BIND nào của nó được phép
trong bộ CPU mới thì tác vụ về cơ bản sẽ được xử lý như thể nó
MPOL_BIND có bị ràng buộc với bộ xử lý mới không (mặc dù vị trí NUMA của nó,
như được truy vấn bởi get_mempolicy(), không thay đổi).  Nếu một nhiệm vụ được di chuyển
từ bộ xử lý này sang bộ xử lý khác, sau đó kernel sẽ điều chỉnh tác vụ
vị trí bộ nhớ, như trên, vào lần tiếp theo kernel thử
để phân bổ một trang bộ nhớ cho tác vụ đó.

Nếu một CPUset đã được sửa đổi 'cpuset.cpus' thì mỗi tác vụ trong CPUset đó
sẽ thay đổi vị trí CPU được phép ngay lập tức.  Tương tự,
nếu pid của một tác vụ được ghi vào tệp 'tác vụ' của cpuset khác, thì nó
Vị trí CPU được phép sẽ được thay đổi ngay lập tức.  Nếu một nhiệm vụ như vậy đã được
được liên kết với một số tập hợp con của bộ CPU bằng cách sử dụng lệnh gọi sched_setaffinity(),
tác vụ sẽ được phép chạy trên bất kỳ CPU nào được phép trong bộ CPU mới của nó,
phủ nhận tác dụng của lệnh gọi sched_setaffinity() trước đó.

Tóm lại, vị trí bộ nhớ của tác vụ có bộ xử lý bị thay đổi là
được cập nhật bởi kernel, trong lần phân bổ trang tiếp theo cho tác vụ đó,
và vị trí bộ xử lý được cập nhật ngay lập tức.

Thông thường, khi một trang được phân bổ (cung cấp một trang vật lý
của bộ nhớ chính) thì trang đó sẽ ở trên bất kỳ nút nào mà nó
đã được phân bổ, miễn là nó vẫn được phân bổ, ngay cả khi
chính sách vị trí bộ nhớ cpusets 'cpuset.mems' sau đó sẽ thay đổi.
Nếu tệp cờ cpuset 'cpuset.memory_migrate' được đặt đúng thì khi
các tác vụ được gắn vào bộ xử lý đó, bất kỳ trang nào mà tác vụ đó có
được phân bổ cho nó trên các nút trong bộ xử lý trước đó của nó sẽ được di chuyển
vào cpuset mới của nhiệm vụ. Vị trí tương đối của trang trong
cpuset được bảo toàn trong các hoạt động di chuyển này nếu có thể.
Ví dụ: nếu trang nằm trên nút hợp lệ thứ hai của bộ xử lý trước đó
sau đó trang sẽ được đặt trên nút hợp lệ thứ hai của bộ xử lý mới.

Ngoài ra, nếu 'cpuset.memory_migrate' được đặt thành đúng, thì nếu cpuset đó
Tệp 'cpuset.mems' được sửa đổi, các trang được phân bổ cho các tác vụ trong đó
cpuset, nằm trên các nút trong cài đặt trước đó của 'cpuset.mems',
sẽ được chuyển đến các nút trong cài đặt mới của 'mems.'
Các trang không có trong bộ xử lý trước của tác vụ hoặc trong bộ xử lý của bộ xử lý
cài đặt 'cpuset.mems' trước đó sẽ không bị di chuyển.

Có một ngoại lệ ở trên.  Nếu chức năng cắm nóng được sử dụng
để loại bỏ tất cả các CPU hiện được gán cho một bộ CPU,
thì tất cả các tác vụ trong cpuset đó sẽ được chuyển đến tổ tiên gần nhất
với cpu không trống.  Nhưng việc di chuyển một số (hoặc tất cả) nhiệm vụ có thể thất bại nếu
cpuset bị ràng buộc với một hệ thống con cgroup khác có một số hạn chế
về nhiệm vụ đính kèm.  Trong trường hợp thất bại này, những nhiệm vụ đó sẽ ở lại
trong cpuset gốc và kernel sẽ tự động cập nhật
cpus_allowed của họ để cho phép tất cả các CPU trực tuyến.  Khi cắm nóng bộ nhớ
chức năng loại bỏ Nút bộ nhớ có sẵn, một ngoại lệ tương tự
dự kiến ​​cũng sẽ được áp dụng ở đó.  Nói chung, kernel thích
vi phạm vị trí cpuset, bỏ đói một nhiệm vụ đã có tất cả
CPU hoặc Nút bộ nhớ được phép của nó được ngoại tuyến.

Có một ngoại lệ thứ hai ở trên.  Các yêu cầu GFP_ATOMIC là
phân bổ nội bộ kernel phải được đáp ứng ngay lập tức.
Hạt nhân có thể loại bỏ một số yêu cầu, trong một số ít trường hợp thậm chí còn hoảng loạn, nếu một
Việc phân bổ GFP_ATOMIC không thành công.  Nếu yêu cầu không thể được đáp ứng trong vòng
cpuset của tác vụ hiện tại, sau đó chúng tôi thư giãn cpuset và tìm kiếm
bộ nhớ ở bất cứ nơi nào chúng ta có thể tìm thấy nó.  Tốt hơn là vi phạm cpuset
hơn là nhấn mạnh hạt nhân.

Để bắt đầu một công việc mới nằm trong CPUset, các bước là:

1) mkdir /sys/fs/cgroup/cpuset
 2) mount -t cgroup -ocpuset cpuset /sys/fs/cgroup/cpuset
 3) Tạo cpuset mới bằng cách thực hiện mkdir và viết (hoặc echo) trong
    hệ thống tệp ảo /sys/fs/cgroup/cpuset.
 4) Bắt đầu một nhiệm vụ sẽ là “cha đẻ” của công việc mới.
 5) Đính kèm tác vụ đó vào bộ xử lý mới bằng cách ghi pid của nó vào
    /sys/fs/cgroup/cpuset tệp tác vụ cho bộ xử lý đó.
 6) phân tách, thực hiện hoặc sao chép các nhiệm vụ công việc từ nhiệm vụ của người sáng lập này.

Ví dụ: chuỗi lệnh sau đây sẽ thiết lập một cpuset
có tên là "Charlie", chỉ chứa CPU 2 và 3, và Nút bộ nhớ 1,
và sau đó bắt đầu một shell con 'sh' trong cpuset đó::

mount -t cgroup -ocpuset cpuset /sys/fs/cgroup/cpuset
  cd /sys/fs/cgroup/cpuset
  mkdir Charlie
  cd Charlie
  /bin/echo 2-3 > cpuset.cpus
  /bin/echo 1 > cpuset.mems
  /bin/echo $$ > nhiệm vụ
  sh
  # The subshell 'sh' hiện đang chạy trong cpuset Charlie
  # The dòng tiếp theo sẽ hiển thị '/ Charlie'
  mèo /proc/self/cpuset

Có nhiều cách để truy vấn hoặc sửa đổi bộ CPU:

- trực tiếp thông qua hệ thống tập tin cpuset, sử dụng nhiều cd, mkdir, echo,
   cat, lệnh rmdir từ shell hoặc tương đương từ C.
 - thông qua thư viện C libcpuset.
 - thông qua thư viện C libcgroup.
   (ZZ0000ZZ
 - thông qua cset ứng dụng python.
   (ZZ0001ZZ

Các lệnh gọi sched_setaffinity cũng có thể được thực hiện tại dấu nhắc shell bằng cách sử dụng
Runon của SGI hoặc nhiệm vụ của Robert Love.  Mbind và set_mempolicy
các cuộc gọi có thể được thực hiện tại dấu nhắc shell bằng lệnh numactl
(một phần của gói numa của Andi Kleen).

2. Ví dụ sử dụng và cú pháp
============================

2.1 Cách sử dụng cơ bản
---------------

Việc tạo, sửa đổi, sử dụng cpuset có thể được thực hiện thông qua cpuset
hệ thống tập tin ảo.

Để gắn kết nó, gõ:
# mount -t cgroup -o cpuset cpuset /sys/fs/cgroup/cpuset

Sau đó, dưới /sys/fs/cgroup/cpuset bạn có thể tìm thấy một cây tương ứng với
cây của các cpuset trong hệ thống. Ví dụ: /sys/fs/cgroup/cpuset
là cpuset chứa toàn bộ hệ thống.

Nếu bạn muốn tạo một cpuset mới trong /sys/fs/cgroup/cpuset::

# cd /sys/fs/cgroup/cpuset
  # mkdir my_cpuset

Bây giờ bạn muốn làm gì đó với cpuset này::

# cd my_cpuset

Trong thư mục này bạn có thể tìm thấy một số tập tin::

# ls
  cgroup.clone_children cpuset.memory_áp lực
  cgroup.event_control cpuset.memory_s Lan_page
  cgroup.procs cpuset.memory_s Lan_slab
  cpuset.cpu_exclusive cpuset.mems
  cpuset.cpus cpuset.sched_load_balance
  cpuset.mem_exclusive cpuset.sched_relax_domain_level
  cpuset.mem_hardwall thông báo_on_release
  nhiệm vụ cpuset.memory_migrate

Đọc chúng sẽ cung cấp cho bạn thông tin về trạng thái của bộ xử lý này:
CPU và Nút bộ nhớ mà nó có thể sử dụng, các tiến trình đang sử dụng
nó, thuộc tính của nó.  Bằng cách ghi vào các tập tin này, bạn có thể thao tác
bộ xử lý.

Đặt một số cờ::

# /bin/echo 1 > cpuset.cpu_exclusive

Thêm một số CPU::

# /bin/echo 0-7 > cpuset.cpus

Thêm một số mem::

# /bin/echo 0-7 > cpuset.mems

Bây giờ hãy gắn shell của bạn vào cpuset này::

# /bin/echo $$ > nhiệm vụ

Bạn cũng có thể tạo các bộ CPU bên trong bộ CPU của mình bằng cách sử dụng mkdir trong phần này
thư mục::

# mkdir my_sub_cs

Để xóa cpuset, chỉ cần sử dụng rmdir::

# rmdir my_sub_cs

Điều này sẽ thất bại nếu CPUset đang được sử dụng (có CPUset bên trong hoặc có
quy trình đính kèm).

Lưu ý rằng vì các lý do cũ, hệ thống tập tin "cpuset" tồn tại dưới dạng
bao bọc xung quanh hệ thống tập tin cgroup.

Lệnh::

mount -t cpuset X /sys/fs/cgroup/cpuset

tương đương với::

mount -t cgroup -ocpuset,noprefix X /sys/fs/cgroup/cpuset
  echo "/sbin/cpuset_release_agent" > /sys/fs/cgroup/cpuset/release_agent

2.2 Thêm/bớt CPU
------------------------

Đây là cú pháp sử dụng khi ghi vào tập tin cpu hoặc mems
trong thư mục cpuset::

# /bin/echo 1-4 > cpuset.cpus -> đặt danh sách cpu thành cpu 1,2,3,4
  # /bin/echo 1,2,3,4 > cpuset.cpus -> đặt danh sách cpu thành cpu 1,2,3,4

Để thêm CPU vào cpuset, hãy viết danh sách CPU mới bao gồm
CPU sẽ được thêm vào. Để thêm 6 vào cpuset trên::

# /bin/echo 1-4,6 > cpuset.cpus -> đặt danh sách cpu thành cpu 1,2,3,4,6

Tương tự để xóa CPU khỏi cpuset, hãy viết danh sách CPU mới
không cần xóa CPU.

Để loại bỏ tất cả các CPU::

# /bin/echo "" > cpuset.cpus -> xóa danh sách cpu

2.3 Đặt cờ
-----------------

Cú pháp rất đơn giản::

# /bin/echo 1 > cpuset.cpu_exclusive -> đặt cờ 'cpuset.cpu_exclusive'
  # /bin/echo 0 > cpuset.cpu_exclusive -> bỏ đặt cờ 'cpuset.cpu_exclusive'

2.4 Quy trình đính kèm
-----------------------

::

# /bin/echo PID > nhiệm vụ

Lưu ý rằng đó là PID, không phải PID. Bạn chỉ có thể đính kèm nhiệm vụ ONE tại một thời điểm.
Nếu bạn có nhiều nhiệm vụ cần đính kèm, bạn phải thực hiện lần lượt từng nhiệm vụ::

# /bin/echo PID1 > nhiệm vụ
  # /bin/echo PID2 > nhiệm vụ
	...
  # /bin/echo PIDn > tasks


3. Câu hỏi
============

Hỏi:
   có chuyện gì với '/bin/echo' này vậy?

Đáp:
   Lệnh 'echo' dựng sẵn của bash không kiểm tra các lệnh gọi tới write()
   lỗi. Nếu bạn sử dụng nó trong hệ thống tập tin cpuset, bạn sẽ không
   có thể cho biết một lệnh đã thành công hay thất bại.

Hỏi:
   Khi tôi đính kèm các quy trình, chỉ dòng đầu tiên mới thực sự được đính kèm!

Đáp:
   Chúng tôi chỉ có thể trả về một mã lỗi cho mỗi lệnh gọi tới write(). Vì vậy bạn cũng nên
   chỉ đặt pid ONE.

4. Liên hệ
==========

Web: ZZ0000ZZ
