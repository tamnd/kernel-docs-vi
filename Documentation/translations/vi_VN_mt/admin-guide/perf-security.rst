.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/perf-security.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _perf_security:

Sự kiện hoàn hảo và bảo mật công cụ
===================================

Tổng quan
---------

Cách sử dụng Bộ đếm hiệu suất cho Linux (perf_events) [1]_ , [2]_ , [3]_
có thể gây ra rủi ro đáng kể về việc rò rỉ dữ liệu nhạy cảm được truy cập bởi
các quá trình được giám sát. Việc rò rỉ dữ liệu có thể xảy ra cả trong các tình huống
sử dụng trực tiếp hệ thống perf_events gọi API [2]_ và qua các tệp dữ liệu
được tạo bởi tiện ích chế độ người dùng công cụ Perf (Perf) [3]_ , [4]_ . Nguy cơ
phụ thuộc vào bản chất của dữ liệu mà việc theo dõi hiệu suất của perf_events
đơn vị (PMU) [2]_ và Perf thu thập và hiển thị để phân tích hiệu suất.
Dữ liệu hiệu suất và hệ thống được thu thập có thể được chia thành nhiều phần
loại:

1. Dữ liệu cấu hình phần cứng và phần mềm hệ thống, ví dụ: CPU
   mô hình và cấu hình bộ đệm của nó, lượng bộ nhớ khả dụng và
   cấu trúc liên kết của nó, phiên bản kernel và Perf đã sử dụng, giám sát hiệu suất
   thiết lập bao gồm thời gian thử nghiệm, cấu hình sự kiện, lệnh Perf
   tham số dòng, v.v.

2. Đường dẫn mô-đun người dùng và hạt nhân cũng như địa chỉ tải của chúng cùng với kích thước,
   tên tiến trình và luồng cùng với PID và TID của chúng, dấu thời gian cho
   ghi lại các sự kiện phần cứng và phần mềm.

3. Nội dung của bộ đếm phần mềm kernel (ví dụ: đối với các chuyển đổi ngữ cảnh, trang
   lỗi, di chuyển CPU), bộ đếm hiệu suất phần cứng kiến trúc
   (PMC) [8]_ và các thanh ghi cụ thể của máy (MSR) [9]_ cung cấp
   số liệu thực thi cho các phần được giám sát khác nhau của hệ thống (ví dụ:
   bộ điều khiển bộ nhớ (IMC), kết nối (QPI/UPI) hoặc thiết bị ngoại vi (PCIe)
   bộ đếm không lõi) mà không có sự quy kết trực tiếp cho bất kỳ bối cảnh thực thi nào
   trạng thái.

4. Nội dung của các thanh ghi bối cảnh thực thi kiến trúc (ví dụ: RIP, RSP,
   RBP trên x86_64), xử lý địa chỉ bộ nhớ không gian kernel và người dùng và
   dữ liệu, nội dung của các MSR kiến trúc khác nhau thu thập dữ liệu từ
   thể loại này.

Dữ liệu thuộc loại thứ tư có thể chứa
dữ liệu quá trình nhạy cảm. Nếu PMU ở một số chế độ giám sát nắm bắt được giá trị
của các thanh ghi bối cảnh thực thi hoặc dữ liệu từ bộ nhớ tiến trình sau đó truy cập
đối với các chế độ giám sát như vậy đòi hỏi phải được sắp xếp và bảo mật đúng cách.
Vì vậy, các hoạt động giám sát hiệu suất và khả năng quan sát của perf_events là
chủ đề về quản lý kiểm soát truy cập bảo mật [5]_ .

kiểm soát truy cập perf_events
-------------------------------

Để thực hiện kiểm tra bảo mật, việc triển khai Linux chia nhỏ các tiến trình
thành hai loại [6]_ : a) các quy trình đặc quyền (có người dùng hiệu quả
ID là 0, được gọi là superuser hoặc root) và b) không có đặc quyền
các quy trình (có UID hiệu quả khác không). Bỏ qua các quy trình đặc quyền
tất cả các quyền kiểm tra quyền bảo mật kernel để hiệu suất perf_events
giám sát hoàn toàn có sẵn cho các quy trình đặc quyền mà không cần truy cập,
hạn chế về phạm vi và nguồn lực.

Các quy trình không có đặc quyền phải được kiểm tra quyền bảo mật đầy đủ
dựa trên thông tin xác thực của quy trình [5]_ (thường là: UID hiệu quả,
GID có hiệu lực và danh sách nhóm bổ sung).

Linux phân chia các đặc quyền truyền thống gắn liền với siêu người dùng
thành các đơn vị riêng biệt, được gọi là khả năng [6]_, có thể
được kích hoạt và vô hiệu hóa độc lập trên cơ sở từng luồng cho các tiến trình và
tập tin của người dùng không có đặc quyền.

Các quy trình không có đặc quyền có khả năng CAP_PERFMON được kích hoạt sẽ được xử lý
như các quy trình đặc quyền liên quan đến hiệu suất perf_events
do đó, các hoạt động giám sát và quan sát sẽ bỏ qua các quyền của ZZ0000ZZ
kiểm tra trong kernel. CAP_PERFMON thực hiện nguyên tắc tối thiểu
đặc quyền [13]_ (POSIX 1003.1e: 2.2.2.39) để theo dõi hiệu suất và
các hoạt động có thể quan sát được trong kernel và cung cấp một cách tiếp cận an toàn cho
giám sát hiệu suất và khả năng quan sát trong hệ thống.

Vì lý do tương thích ngược, quyền truy cập vào giám sát perf_events và
Các hoạt động có thể quan sát cũng được mở cho đặc quyền CAP_SYS_ADMIN
xử lý nhưng việc sử dụng CAP_SYS_ADMIN để giám sát và quan sát an toàn
các trường hợp sử dụng không được khuyến khích đối với khả năng của CAP_PERFMON.
Nếu kiểm tra hệ thống ghi lại [14]_ cho một quy trình sử dụng lệnh gọi hệ thống perf_events
API chứa hồ sơ từ chối mua cả CAP_PERFMON và CAP_SYS_ADMIN
sau đó cung cấp cho quy trình khả năng CAP_PERFMON riêng lẻ
được khuyến nghị là phương pháp an toàn ưu tiên để giải quyết truy cập kép
ghi nhật ký từ chối liên quan đến việc sử dụng giám sát hiệu suất và khả năng quan sát.

Các quy trình không có đặc quyền của Linux v5.9 trước đây sử dụng lệnh gọi hệ thống perf_events
cũng là đối tượng để kiểm tra chế độ truy cập ptrace PTRACE_MODE_READ_REALCREDS
[7]_ , kết quả của nó quyết định liệu việc giám sát có được phép hay không.
Vì vậy, các quy trình không có đặc quyền được cung cấp khả năng CAP_SYS_PTRACE là
được phép vượt qua kiểm tra một cách hiệu quả. Bắt đầu từ Linux v5.9
Khả năng CAP_SYS_PTRACE là không cần thiết và CAP_PERFMON là đủ để
được cung cấp cho các quy trình để thực hiện giám sát hiệu suất và khả năng quan sát
hoạt động.

Các khả năng khác được cấp cho các quy trình không có đặc quyền có thể
cho phép thu thập dữ liệu bổ sung cần thiết một cách hiệu quả cho lần sau
phân tích hiệu suất của các quy trình hoặc hệ thống được giám sát. Ví dụ,
Khả năng CAP_SYSLOG cho phép đọc địa chỉ bộ nhớ không gian kernel từ
tập tin /proc/kallsyms.

Nhóm người dùng Perf đặc quyền
---------------------------------

Cơ chế của các khả năng, các tệp câm có khả năng đặc quyền [6]_,
hệ thống tập tin ACL [10]_ và tiện ích sudo [15]_ có thể được sử dụng để tạo
các nhóm người dùng Perf đặc quyền được phép thực thi
giám sát hiệu suất và khả năng quan sát không có giới hạn. Sau đây
có thể thực hiện các bước để tạo các nhóm người dùng Perf đặc quyền như vậy.

1. Tạo nhóm perf_users gồm những người dùng Perf đặc quyền, gán perf_users
   nhóm vào công cụ thực thi Perf và giới hạn quyền truy cập vào tệp thực thi cho
   những người dùng khác trong hệ thống không thuộc nhóm perf_users:

::

# groupadd perf_users
   # ls -alhF
   -rwxr-xr-x 2 gốc gốc 11M ngày 19 tháng 10 15:12 hoàn hảo
   # chgrp perf_users hoàn hảo
   # ls -alhF
   -rwxr-xr-x 2 gốc perf_users 11 tháng 19 ngày 19 tháng 10 15:12 hoàn hảo
   Sự hoàn hảo của # chmod o-rwx
   # ls -alhF
   -rwxr-x--- 2 root perf_users 11 tháng 10 19 15:12 hoàn hảo

2. Gán các khả năng cần thiết cho tệp thực thi công cụ Perf và
   cho phép các thành viên của nhóm perf_users có khả năng giám sát và quan sát
   đặc quyền [6]_ :

::

# setcap "cap_perfmon,cap_sys_ptrace,cap_syslog=ep" hoàn hảo
   # setcap -v "cap_perfmon,cap_sys_ptrace,cap_syslog=ep" hoàn hảo
   hoàn hảo: được rồi
   Sự hoàn hảo của # getcap
   hoàn hảo = cap_sys_ptrace,cap_syslog,cap_perfmon+ep

Nếu libcap [16]_ được cài đặt chưa hỗ trợ "cap_perfmon", thay vào đó hãy sử dụng "38",
tức là:

::

# setcap "38,cap_ipc_lock,cap_sys_ptrace,cap_syslog=ep" hoàn hảo

Lưu ý rằng bạn có thể cần phải có 'cap_ipc_lock' trong danh sách kết hợp cho các công cụ như
'perf top', hoặc sử dụng 'perf top -m N', để giảm bộ nhớ
nó sử dụng cho bộ đệm vòng hoàn hảo, xem phần cấp phát bộ nhớ bên dưới.

Sử dụng libcap mà không hỗ trợ CAP_PERFMON sẽ tạo ra cap_get_flag(caps, 38,
CAP_EFFECTIVE, &val) không thành công, điều này sẽ dẫn đến sự kiện mặc định là 'cycles:u',
vì vậy, như một cách giải quyết, hãy yêu cầu rõ ràng sự kiện 'chu kỳ', tức là:

::

# perf chu kỳ hàng đầu -e

Để lấy mẫu hạt nhân và người dùng với tệp nhị phân hoàn hảo chỉ với CAP_PERFMON.

Kết quả là các thành viên của nhóm perf_users có khả năng tiến hành
giám sát hiệu suất và khả năng quan sát bằng cách sử dụng chức năng của
Công cụ Perf được cấu hình có thể thực thi được mà khi thực thi sẽ vượt qua perf_events
kiểm tra phạm vi hệ thống con.

Trong trường hợp không thể chỉ định các khả năng thực thi của công cụ Perf (ví dụ:
hệ thống tập tin được gắn với tùy chọn nosuid hoặc các thuộc tính mở rộng được
không được hệ thống tập tin hỗ trợ) thì việc tạo ra các khả năng
môi trường đặc quyền, vỏ tự nhiên, là có thể. Vỏ cung cấp
các quy trình vốn có với CAP_PERFMON và các khả năng cần thiết khác để
các hoạt động giám sát hiệu suất và khả năng quan sát có sẵn trong
môi trường không có giới hạn. Quyền truy cập vào môi trường có thể được mở thông qua sudo
tiện ích chỉ dành cho thành viên của nhóm perf_users. Để tạo được như vậy
môi trường:

1. Tạo shell script sử dụng tiện ích capsh [16]_ để gán CAP_PERFMON
   và các khả năng cần thiết khác vào bộ khả năng xung quanh của vỏ
   xử lý, khóa các bit bảo mật quy trình sau khi kích hoạt SECBIT_NO_SETUID_FIXUP,
   Các bit SECBIT_NOROOT và SECBIT_NO_CAP_AMBIENT_RAISE rồi thay đổi
   danh tính quy trình cho người gọi sudo của tập lệnh, về cơ bản sẽ
   là thành viên của nhóm perf_users:

::

# ls -alh /usr/local/bin/perf.shell
   -rwxr-xr-x. 1 gốc 83 13 tháng 10 23:57 /usr/local/bin/perf.shell
   # cat /usr/local/bin/perf.shell
   thực thi /usr/sbin/capsh --iab=^cap_perfmon --secbits=239 --user=$SUDO_USER -- -l

2. Mở rộng chính sách sudo tại tệp /etc/sudoers với quy tắc cho nhóm perf_users:

::

# grep perf_users /etc/sudoers
   %perf_users ALL=/usr/local/bin/perf.shell

3. Kiểm tra xem các thành viên của nhóm perf_users có quyền truy cập vào đặc quyền không
   shell và kích hoạt CAP_PERFMON cũng như các khả năng cần thiết khác
   trong các tập hợp khả năng được phép, hiệu quả và xung quanh của một quá trình vốn có:

::

$ id
  uid=1003(capsh_test) gid=1004(capsh_test) nhóm=1004(capsh_test),1000(perf_users) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
  $ sudo perf.shell
  [sudo] mật khẩu cho capsh_test:
  $ grep Cap /proc/self/status
  CapInh: 0000004000000000
  CapPrm: 0000004000000000
  CapEff: 0000004000000000
  CapBnd: 000000ffffffffff
  CapAmb: 0000004000000000
  $ capsh --decode=0000004000000000
  0x0000004000000000=cap_perfmon

Kết quả là, các thành viên của nhóm perf_users có quyền truy cập vào đặc quyền
môi trường nơi họ có thể sử dụng các công cụ sử dụng API giám sát hiệu suất
được quản lý bởi khả năng của CAP_PERFMON Linux.

Quản lý kiểm soát truy cập cụ thể này chỉ có sẵn cho siêu người dùng
hoặc root các tiến trình đang chạy bằng CAP_SETPCAP, CAP_SETFCAP [6]_
khả năng.

Người dùng không có đặc quyền
-----------------------------------

perf_events Kiểm soát ZZ0000ZZ và ZZ0001ZZ cho các quy trình không có đặc quyền
được điều chỉnh bởi cài đặt perf_event_paranoid [2]_:

-1:
     Không áp đặt các hạn chế ZZ0000ZZ và ZZ0001ZZ khi sử dụng perf_events
     giám sát hiệu suất. Mỗi người dùng trên mỗi CPU perf_event_mlock_kb [2]_
     giới hạn khóa bị bỏ qua khi cấp phát bộ nhớ đệm để lưu trữ
     dữ liệu hiệu suất. Đây là chế độ kém an toàn nhất kể từ khi được phép
     ZZ0002ZZ được giám sát được tối đa hóa và không có giới hạn cụ thể về perf_events
     được áp dụng trên ZZ0003ZZ được phân bổ để theo dõi hiệu suất.

>=0:
     ZZ0000ZZ bao gồm giám sát hiệu suất trên toàn hệ thống và theo quy trình
     nhưng không bao gồm các điểm theo dõi thô và các điểm theo dõi hàm ftrace
     giám sát. CPU và các sự kiện hệ thống đã xảy ra khi thực thi một trong hai
     người dùng hoặc trong không gian kernel có thể được theo dõi và ghi lại cho lần sau
     phân tích. Giới hạn khóa perf_event_mlock_kb cho mỗi người dùng trên mỗi CPU là
     áp đặt nhưng bị bỏ qua đối với các quy trình không có đặc quyền với CAP_IPC_LOCK
     [6]_ khả năng.

>=1:
     ZZ0000ZZ chỉ bao gồm giám sát hiệu suất trên mỗi quy trình và
     loại trừ giám sát hiệu suất toàn hệ thống. CPU và các sự kiện hệ thống
     xảy ra khi thực thi trong người dùng hoặc trong không gian kernel có thể
     được theo dõi và ghi lại để phân tích sau này. Mỗi người dùng trên mỗi CPU
     giới hạn khóa perf_event_mlock_kb được áp dụng nhưng bị bỏ qua đối với
     các quy trình không có đặc quyền với khả năng CAP_IPC_LOCK.

>=2:
     ZZ0000ZZ chỉ bao gồm giám sát hiệu suất trên mỗi quy trình. CPU và
     các sự kiện hệ thống xảy ra khi chỉ thực thi trong không gian người dùng
     được theo dõi và ghi lại để phân tích sau này. Mỗi người dùng trên mỗi CPU
     giới hạn khóa perf_event_mlock_kb được áp dụng nhưng bị bỏ qua đối với
     các quy trình không có đặc quyền với khả năng CAP_IPC_LOCK.

Kiểm soát tài nguyên
---------------------------------

Mở bộ mô tả tập tin
+++++++++++++++++++++

Hệ thống perf_events gọi API [2]_ phân bổ các bộ mô tả tệp cho
mọi sự kiện PMU được định cấu hình. Bộ mô tả tệp mở là một quy trình
tài nguyên có trách nhiệm được quản lý bởi giới hạn RLIMIT_NOFILE [11]_
(ulimit -n), thường bắt nguồn từ quá trình shell đăng nhập. Khi nào
định cấu hình bộ sưu tập Perf cho danh sách dài các sự kiện trên máy chủ lớn
hệ thống, giới hạn này có thể dễ dàng đạt được, ngăn cản việc giám sát cần thiết
cấu hình. Giới hạn RLIMIT_NOFILE có thể tăng lên tùy theo từng người dùng
sửa đổi nội dung của file limit.conf [12]_ . Thông thường, một sự hoàn hảo
phiên lấy mẫu (bản ghi hoàn hảo) yêu cầu một lượng perf_event mở
bộ mô tả tệp không ít hơn số lượng sự kiện được theo dõi
nhân với số lượng CPU được giám sát.

Phân bổ bộ nhớ
+++++++++++++++++

Dung lượng bộ nhớ có sẵn cho các tiến trình của người dùng để chụp
dữ liệu giám sát hiệu suất được điều chỉnh bởi perf_event_mlock_kb [2]_
thiết lập. Cài đặt tài nguyên cụ thể perf_event này xác định tổng thể
giới hạn bộ nhớ trên mỗi CPU được phép để ánh xạ bởi các quy trình của người dùng tới
thực hiện giám sát hiệu suất. Cài đặt về cơ bản mở rộng
Giới hạn RLIMIT_MEMLOCK [11]_, nhưng chỉ dành cho các vùng bộ nhớ được ánh xạ
đặc biệt để ghi lại các sự kiện hiệu suất được giám sát và dữ liệu liên quan.

Ví dụ: nếu máy có tám lõi và giới hạn perf_event_mlock_kb
được đặt thành 516 KiB, thì quy trình người dùng được cung cấp 516 KiB * 8 =
4128 KiB bộ nhớ vượt quá giới hạn RLIMIT_MEMLOCK (ulimit -l) cho
bộ đệm mmap perf_event. Đặc biệt, điều này có nghĩa là nếu người dùng
muốn bắt đầu hai hoặc nhiều quá trình giám sát hiệu suất, người dùng
được yêu cầu phân phối thủ công 4128 KiB có sẵn giữa
ví dụ: các quy trình giám sát bằng cách sử dụng bản ghi --mmap-pages Perf
tùy chọn chế độ. Mặt khác, quá trình giám sát hiệu suất bắt đầu đầu tiên
phân bổ tất cả 4128 KiB có sẵn và các quy trình khác sẽ không thực hiện được
tiếp tục do thiếu bộ nhớ.

Các ràng buộc tài nguyên RLIMIT_MEMLOCK và perf_event_mlock_kb bị bỏ qua
cho các quy trình có khả năng CAP_IPC_LOCK. Do đó, perf_events/Perf
người dùng đặc quyền có thể được cung cấp bộ nhớ vượt quá giới hạn cho
mục đích giám sát hiệu suất perf_events/Perf bằng cách cung cấp Perf
có thể thực thi được với khả năng CAP_IPC_LOCK.

Thư mục
------------

.. [1] `<https://lwn.net/Articles/337493/>`_
.. [2] `<http://man7.org/linux/man-pages/man2/perf_event_open.2.html>`_
.. [3] `<http://web.eece.maine.edu/~vweaver/projects/perf_events/>`_
.. [4] `<https://perf.wiki.kernel.org/index.php/Main_Page>`_
.. [5] `<https://www.kernel.org/doc/html/latest/security/credentials.html>`_
.. [6] `<http://man7.org/linux/man-pages/man7/capabilities.7.html>`_
.. [7] `<http://man7.org/linux/man-pages/man2/ptrace.2.html>`_
.. [8] `<https://en.wikipedia.org/wiki/Hardware_performance_counter>`_
.. [9] `<https://en.wikipedia.org/wiki/Model-specific_register>`_
.. [10] `<http://man7.org/linux/man-pages/man5/acl.5.html>`_
.. [11] `<http://man7.org/linux/man-pages/man2/getrlimit.2.html>`_
.. [12] `<http://man7.org/linux/man-pages/man5/limits.conf.5.html>`_
.. [13] `<https://sites.google.com/site/fullycapable>`_
.. [14] `<http://man7.org/linux/man-pages/man8/auditd.8.html>`_
.. [15] `<https://man7.org/linux/man-pages/man8/sudo.8.html>`_
.. [16] `<https://git.kernel.org/pub/scm/libs/libcap/libcap.git/>`_
