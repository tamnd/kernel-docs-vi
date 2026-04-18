.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/cgroup-v1/cgroups.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================
Nhóm kiểm soát
================

Được viết bởi Paul Menage <menage@google.com> dựa trên
Tài liệu/admin-guide/cgroup-v1/cpusets.rst

Tuyên bố bản quyền gốc từ cpusets.txt:

Các phần Bản quyền (C) 2004 BULL SA.

Các phần Bản quyền (c) 2004-2006 Silicon Graphics, Inc.

Được sửa đổi bởi Paul Jackson <pj@sgi.com>

Được sửa đổi bởi Christoph Lameter <cl@gentwo.org>

.. CONTENTS:

	1. Control Groups
	1.1 What are cgroups ?
	1.2 Why are cgroups needed ?
	1.3 How are cgroups implemented ?
	1.4 What does notify_on_release do ?
	1.5 What does clone_children do ?
	1.6 How do I use cgroups ?
	2. Usage Examples and Syntax
	2.1 Basic Usage
	2.2 Attaching processes
	2.3 Mounting hierarchies by name
	3. Kernel API
	3.1 Overview
	3.2 Synchronization
	3.3 Subsystem API
	4. Extended attributes usage
	5. Questions

1. Nhóm kiểm soát
=================

1.1 Nhóm là gì?
----------------------

Nhóm điều khiển cung cấp cơ chế tổng hợp/phân chia các tập hợp
nhiệm vụ và tất cả con cái tương lai của họ thành các nhóm có thứ bậc với
hành vi chuyên biệt.

định nghĩa:

ZZ0000ZZ liên kết một tập hợp các nhiệm vụ với một tập hợp các tham số cho một nhiệm vụ
hoặc nhiều hệ thống con.

ZZ0000ZZ là mô-đun sử dụng tính năng nhóm nhiệm vụ
các phương tiện được cung cấp bởi các nhóm để xử lý các nhóm nhiệm vụ trong
những cách cụ thể. Một hệ thống con thường là một "bộ điều khiển tài nguyên"
lên lịch tài nguyên hoặc áp dụng giới hạn cho mỗi nhóm, nhưng nó có thể
bất cứ điều gì muốn hành động trên một nhóm quy trình, ví dụ: một
hệ thống con ảo hóa.

ZZ0000ZZ là một tập hợp các nhóm được sắp xếp trên một cây sao cho
mọi tác vụ trong hệ thống đều thuộc chính xác một trong các nhóm trong
hệ thống phân cấp và một tập hợp các hệ thống con; mỗi hệ thống con có hệ thống cụ thể
trạng thái gắn liền với mỗi nhóm trong hệ thống phân cấp.  Mỗi hệ thống phân cấp có
một phiên bản của hệ thống tập tin ảo cgroup được liên kết với nó.

Tại một thời điểm bất kỳ có thể có nhiều hệ thống phân cấp nhiệm vụ đang hoạt động
cgroups. Mỗi hệ thống phân cấp là một phân vùng của tất cả các nhiệm vụ trong hệ thống.

Mã cấp độ người dùng có thể tạo và hủy các nhóm theo tên trong một
phiên bản của hệ thống tệp ảo cgroup, chỉ định và truy vấn tới
nhóm nào được giao nhiệm vụ và liệt kê các PID nhiệm vụ được giao cho
một nhóm. Những sáng tạo và nhiệm vụ đó chỉ ảnh hưởng đến hệ thống phân cấp
được liên kết với phiên bản đó của hệ thống tệp cgroup.

Về bản thân họ, mục đích sử dụng duy nhất của cgroup là cho công việc đơn giản
theo dõi. Mục đích là các hệ thống con khác nối vào hệ thống chung
hỗ trợ cgroup để cung cấp các thuộc tính mới cho các nhóm, chẳng hạn như
tính toán/giới hạn các tài nguyên xử lý trong một nhóm có thể
truy cập. Ví dụ: cpusets (xem Tài liệu/admin-guide/cgroup-v1/cpusets.rst) cho phép
bạn liên kết một tập hợp các CPU và một tập hợp các nút bộ nhớ với
nhiệm vụ trong mỗi nhóm.

.. _cgroups-why-needed:

1.2 Tại sao cần có cgroup?
----------------------------

Có nhiều nỗ lực nhằm cung cấp các tập hợp quy trình trong
Nhân Linux, chủ yếu nhằm mục đích theo dõi tài nguyên. Những nỗ lực như vậy
bao gồm cpusets, CKRM/ResGroups, UserBeanCounters và máy chủ ảo
không gian tên. Tất cả những điều này đều đòi hỏi khái niệm cơ bản về một
nhóm/phân vùng các tiến trình, với các tiến trình mới phân nhánh kết thúc
lên trong cùng một nhóm (cgroup) với quy trình mẹ của chúng.

Bản vá cgroup kernel cung cấp kernel cần thiết tối thiểu
cơ chế cần thiết để thực hiện hiệu quả các nhóm như vậy. Nó có
tác động tối thiểu đến các đường dẫn nhanh của hệ thống và cung cấp các kết nối cho
các hệ thống con cụ thể như cpuset để cung cấp hành vi bổ sung như
mong muốn.

Hỗ trợ nhiều hệ thống phân cấp được cung cấp để cho phép các tình huống trong đó
việc phân chia nhiệm vụ thành các nhóm là khác nhau rõ ràng đối với
các hệ thống con khác nhau - việc có các hệ thống phân cấp song song cho phép mỗi
phân cấp là sự phân chia nhiệm vụ một cách tự nhiên mà không cần phải xử lý
sự kết hợp phức tạp của các nhiệm vụ sẽ xuất hiện nếu một số
các hệ thống con không liên quan cần phải được đưa vào cùng một cây
cgroups.

Ở một thái cực, mỗi bộ điều khiển tài nguyên hoặc hệ thống con có thể ở trong một
hệ thống phân cấp riêng biệt; ở thái cực khác, tất cả các hệ thống con
sẽ được gắn vào cùng một hệ thống phân cấp.

Như một ví dụ về một kịch bản (ban đầu được đề xuất bởi vatsa@in.ibm.com)
có thể hưởng lợi từ nhiều hệ thống phân cấp, hãy xem xét một lượng lớn
máy chủ của trường đại học với nhiều người dùng khác nhau - sinh viên, giáo sư, hệ thống
nhiệm vụ, v.v. Việc lập kế hoạch tài nguyên cho máy chủ này có thể dọc theo
dòng sau::

CPU : "Bộ CPU hàng đầu"
                       / \
               CPUSet1 CPUSet2
                  ZZ0000ZZ
               (Giáo sư) (Sinh viên)

Ngoài ra (tác vụ hệ thống) được đính kèm với topcpuset (vì vậy
               rằng họ có thể chạy ở bất cứ đâu) với giới hạn 20%

Trí nhớ: Giáo sư (50%), Sinh viên (30%), Hệ thống (20%)

Đĩa : Giáo sư (50%), Sinh viên (30%), hệ thống (20%)

Mạng : Duyệt WWW (20%), Hệ thống tệp mạng (60%), khác (20%)
                               / \
               Giáo sư (15%) sinh viên (5%)

Các trình duyệt như Firefox/Lynx đi vào lớp mạng WWW, trong khi (k)nfsd đi vào lớp mạng
vào lớp mạng NFS.

Đồng thời Firefox/Lynx sẽ chia sẻ lớp CPU/Bộ nhớ thích hợp
tùy thuộc vào người đã phát động nó (giáo sư/sinh viên).

Với khả năng phân loại nhiệm vụ khác nhau cho các nguồn lực khác nhau
(bằng cách đặt các hệ thống con tài nguyên đó vào các hệ thống phân cấp khác nhau),
quản trị viên có thể dễ dàng thiết lập tập lệnh nhận thông báo thực thi
và tùy thuộc vào người đang khởi chạy trình duyệt, anh ta có thể::

# echo browser_pid > /sys/fs/cgroup/<restype>/<userclass>/tasks

Chỉ với một hệ thống phân cấp duy nhất, giờ đây anh ta có khả năng phải tạo ra
một nhóm riêng cho mỗi trình duyệt được khởi chạy và liên kết nó với
mạng thích hợp và lớp tài nguyên khác.  Điều này có thể dẫn đến
sự phát triển của các nhóm như vậy.

Ngoài ra, giả sử quản trị viên muốn cung cấp mạng nâng cao
truy cập tạm thời vào trình duyệt của học sinh (vì lúc đó là ban đêm và người dùng
muốn chơi game trực tuyến :)) HOẶC đưa cho một trong những mô phỏng của học sinh
ứng dụng nâng cao sức mạnh của CPU.

Với khả năng ghi PID trực tiếp vào các lớp tài nguyên, nó chỉ là một
vấn đề về::

# echo pid > /sys/fs/cgroup/network/<new_class>/tasks
       (sau một thời gian)
       # echo pid > /sys/fs/cgroup/network/<orig_class>/tasks

Nếu không có khả năng này, quản trị viên sẽ phải chia cgroup thành
nhiều nhóm riêng biệt và sau đó liên kết các nhóm mới với
các lớp tài nguyên mới.



1.3 Các nhóm được triển khai như thế nào?
-----------------------------------------

Nhóm điều khiển mở rộng kernel như sau:

- Mỗi tác vụ trong hệ thống có một con trỏ đếm tham chiếu tới một
   css_set.

- Một css_set chứa một tập hợp các con trỏ được tính tham chiếu tới
   các đối tượng cgroup_subsys_state, một đối tượng cho mỗi hệ thống con cgroup
   đã đăng ký trong hệ thống. Không có liên kết trực tiếp từ một nhiệm vụ đến
   nhóm mà nó là thành viên trong mỗi hệ thống phân cấp, nhưng điều này
   có thể được xác định bằng cách làm theo các gợi ý thông qua
   đối tượng cgroup_subsys_state. Điều này là do việc truy cập vào
   trạng thái hệ thống con là điều được mong đợi sẽ xảy ra thường xuyên
   và trong mã quan trọng về hiệu năng, trong khi các hoạt động yêu cầu
   nhiệm vụ nhóm thực tế của nhiệm vụ (đặc biệt là di chuyển giữa
   cgroups) ít phổ biến hơn. Một danh sách liên kết chạy qua cg_list
   trường của mỗi task_struct sử dụng css_set, được neo tại
   css_set->nhiệm vụ.

- Một hệ thống tập tin phân cấp cgroup có thể được gắn kết để duyệt và
   thao tác từ không gian người dùng.

- Bạn có thể liệt kê tất cả các nhiệm vụ (theo PID) được đính kèm vào bất kỳ nhóm nào.

Việc triển khai các nhóm đòi hỏi một vài móc nối đơn giản
vào phần còn lại của kernel, không có phần nào trong các đường dẫn quan trọng về hiệu năng:

- trong init/main.c, để khởi tạo các nhóm gốc và tên ban đầu
   css_set khi khởi động hệ thống.

- trong ngã ba và thoát, để đính kèm và tách một tác vụ khỏi css_set của nó.

Ngoài ra, một hệ thống tập tin mới thuộc loại "cgroup" có thể được gắn vào, để
cho phép duyệt và sửa đổi các nhóm hiện được biết đến
hạt nhân.  Khi gắn hệ thống phân cấp cgroup, bạn có thể chỉ định một
danh sách các hệ thống con được phân tách bằng dấu phẩy để gắn kết dưới dạng gắn kết hệ thống tập tin
tùy chọn.  Theo mặc định, việc gắn hệ thống tập tin cgroup sẽ cố gắng
gắn kết một hệ thống phân cấp chứa tất cả các hệ thống con đã đăng ký.

Nếu một hệ thống phân cấp đang hoạt động có cùng một tập hợp các hệ thống con
tồn tại, nó sẽ được sử dụng lại cho thú cưỡi mới. Nếu không có hệ thống phân cấp hiện có
trùng khớp và bất kỳ hệ thống con nào được yêu cầu đều đang được sử dụng trong hệ thống hiện có
phân cấp, quá trình gắn kết sẽ thất bại với -EBUSY. Ngược lại, một hệ thống phân cấp mới
được kích hoạt, liên kết với các hệ thống con được yêu cầu.

Hiện tại không thể liên kết một hệ thống con mới với một hệ thống đang hoạt động
hệ thống phân cấp cgroup hoặc để hủy liên kết một hệ thống con khỏi một nhóm đang hoạt động
thứ bậc. Điều này có thể xảy ra trong tương lai nhưng đầy rẫy những điều khó chịu.
vấn đề phục hồi lỗi.

Khi hệ thống tập tin cgroup được ngắt kết nối, nếu có bất kỳ
các nhóm con được tạo bên dưới nhóm cấp cao nhất, hệ thống phân cấp đó
sẽ vẫn hoạt động ngay cả khi chưa được gắn kết; nếu không có
các nhóm con thì hệ thống phân cấp sẽ bị vô hiệu hóa.

Không có cuộc gọi hệ thống mới nào được thêm vào cho các nhóm - tất cả đều hỗ trợ cho
truy vấn và sửa đổi các nhóm thông qua hệ thống tệp cgroup này.

Mỗi tác vụ trong /proc có một tệp bổ sung có tên 'cgroup' hiển thị,
đối với mỗi hệ thống phân cấp hoạt động, tên hệ thống con và tên nhóm
là đường dẫn tương ứng với thư mục gốc của hệ thống tập tin cgroup.

Mỗi cgroup được đại diện bởi một thư mục trong hệ thống tập tin cgroup
chứa các tệp sau mô tả nhóm đó:

- task: danh sách các task (theo PID) gắn với cgroup đó.  Danh sách này
   không được đảm bảo để được sắp xếp.  Viết ID luồng vào tệp này
   di chuyển chủ đề vào nhóm này.
 - cgroup.procs: danh sách ID nhóm thread trong cgroup.  Danh sách này là
   không đảm bảo được sắp xếp hoặc không có TGID trùng lặp và không gian người dùng
   nên sắp xếp/duy nhất danh sách nếu thuộc tính này là bắt buộc.
   Viết ID nhóm luồng vào tệp này sẽ di chuyển tất cả các luồng trong đó
   nhóm vào cgroup này.
 - cờ thông báo_on_release: chạy tác nhân phát hành khi thoát?
 - Release_agent: đường dẫn sử dụng cho thông báo phát hành (file này
   chỉ tồn tại trong nhóm hàng đầu)

Các hệ thống con khác như cpuset có thể thêm các tệp bổ sung vào mỗi
thư mục cgroup

Các nhóm mới được tạo bằng lệnh gọi hệ thống mkdir hoặc shell
lệnh.  Các thuộc tính của một nhóm, chẳng hạn như các cờ của nó, là
được sửa đổi bằng cách ghi vào tệp thích hợp trong các nhóm đó
thư mục như đã liệt kê ở trên.

Cấu trúc phân cấp được đặt tên của các nhóm lồng nhau cho phép phân vùng
một hệ thống lớn thành các "phân vùng mềm" lồng nhau, có thể thay đổi linh hoạt.

Phần đính kèm của từng nhiệm vụ, được kế thừa tự động tại ngã ba bởi bất kỳ
con của nhiệm vụ đó, để một cgroup cho phép tổ chức khối lượng công việc
trên hệ thống thành các tập nhiệm vụ có liên quan.  Một nhiệm vụ có thể được gắn lại vào
bất kỳ nhóm nào khác, nếu được phép bởi các quyền cần thiết
thư mục hệ thống tập tin cgroup.

Khi một tác vụ được chuyển từ nhóm này sang nhóm khác, nó sẽ nhận được một nhiệm vụ mới
con trỏ css_set - nếu đã tồn tại một css_set với
tập hợp các nhóm mong muốn thì nhóm đó sẽ được sử dụng lại, nếu không thì một nhóm mới
css_set được phân bổ. CSS_set hiện có thích hợp được đặt bởi
nhìn vào một bảng băm.

Để cho phép truy cập từ một nhóm vào css_sets (và do đó là các tác vụ)
bao gồm nó, một tập hợp các đối tượng cg_cgroup_link tạo thành một mạng;
mỗi cg_cgroup_link được liên kết thành một danh sách cg_cgroup_links cho
một nhóm duy nhất trên trường cgrp_link_list của nó và một danh sách
cg_cgroup_links cho một css_set trên cg_link_list của nó.

Do đó, tập hợp các nhiệm vụ trong một nhóm có thể được liệt kê bằng cách lặp lại
mỗi css_set tham chiếu đến nhóm và lặp lại
mỗi bộ nhiệm vụ của css_set.

Việc sử dụng hệ thống tệp ảo Linux (vfs) để thể hiện
Hệ thống phân cấp cgroup cung cấp không gian tên và quyền quen thuộc
đối với các nhóm, với tối thiểu mã hạt nhân bổ sung.

1.4 Thông báo_on_release làm gì?
------------------------------------

Nếu cờ thông báo_on_release được bật (1) trong một nhóm, thì
bất cứ khi nào tác vụ cuối cùng trong nhóm rời khỏi (thoát hoặc gắn vào
một số cgroup khác) và cgroup con cuối cùng của cgroup đó
bị xóa thì kernel sẽ chạy lệnh được chỉ định bởi nội dung
của tệp "release_agent" trong thư mục gốc của hệ thống phân cấp đó,
cung cấp tên đường dẫn (liên quan đến điểm gắn kết của cgroup
hệ thống tập tin) của nhóm bị bỏ rơi.  Điều này cho phép tự động
loại bỏ các cgroup bị bỏ rơi.  Giá trị mặc định của
thông báo_on_release trong nhóm gốc khi khởi động hệ thống bị tắt
(0).  Giá trị mặc định của các nhóm khác khi tạo là giá trị hiện tại
giá trị cài đặt notification_on_release của cha mẹ chúng. Giá trị mặc định của
đường dẫn Release_agent của hệ thống phân cấp cgroup trống.

1.5 clone_children làm gì?
---------------------------------

Cờ này chỉ ảnh hưởng đến bộ điều khiển cpuset. Nếu clone_children
cờ được bật (1) trong một nhóm, một nhóm cpuset mới sẽ sao chép nó
cấu hình từ cha mẹ trong quá trình khởi tạo.

1.6 Làm cách nào để sử dụng cgroups?
------------------------------------

Để bắt đầu một công việc mới được chứa trong một nhóm, hãy sử dụng
hệ thống con cgroup "cpuset", các bước giống như sau::

1) mount -t tmpfs cgroup_root /sys/fs/cgroup
 2) mkdir /sys/fs/cgroup/cpuset
 3) mount -t cgroup -ocpuset cpuset /sys/fs/cgroup/cpuset
 4) Tạo nhóm mới bằng cách thực hiện mkdir và viết (hoặc echo) trong
    hệ thống tệp ảo /sys/fs/cgroup/cpuset.
 5) Bắt đầu một nhiệm vụ sẽ là “cha đẻ” của công việc mới.
 6) Đính kèm nhiệm vụ đó vào nhóm mới bằng cách ghi PID của nó vào
    /sys/fs/cgroup/cpuset tệp tác vụ cho nhóm đó.
 7) phân tách, thực hiện hoặc sao chép các nhiệm vụ công việc từ nhiệm vụ của người sáng lập này.

Ví dụ: chuỗi lệnh sau sẽ thiết lập một cgroup
có tên là "Charlie", chỉ chứa CPU 2 và 3, và Nút bộ nhớ 1,
và sau đó bắt đầu một shell con 'sh' trong nhóm đó::

mount -t tmpfs cgroup_root /sys/fs/cgroup
  mkdir /sys/fs/cgroup/cpuset
  mount -t cgroup cpuset -ocpuset /sys/fs/cgroup/cpuset
  cd /sys/fs/cgroup/cpuset
  mkdir Charlie
  cd Charlie
  /bin/echo 2-3 > cpuset.cpus
  /bin/echo 1 > cpuset.mems
  /bin/echo $$ > nhiệm vụ
  sh
  # The subshell 'sh' hiện đang chạy trong cgroup Charlie
  # The dòng tiếp theo sẽ hiển thị '/ Charlie'
  mèo /proc/self/cgroup

2. Ví dụ sử dụng và cú pháp
============================

2.1 Cách sử dụng cơ bản
-----------------------

Việc tạo, sửa đổi, sử dụng cgroup có thể được thực hiện thông qua cgroup
hệ thống tập tin ảo.

Để gắn kết hệ thống phân cấp cgroup với tất cả các hệ thống con có sẵn, hãy nhập::

# mount -t cgroup xxx /sys/fs/cgroup

"xxx" không được mã cgroup diễn giải nhưng sẽ xuất hiện trong
/proc/mounts vì vậy có thể là bất kỳ chuỗi nhận dạng hữu ích nào mà bạn thích.

Lưu ý: Một số hệ thống con không hoạt động nếu không có sự nhập liệu của người dùng trước.  Ví dụ,
nếu cpusets được kích hoạt, người dùng sẽ phải điền vào các tập tin cpu và mems
cho mỗi nhóm mới được tạo trước khi nhóm đó có thể được sử dụng.

Như đã giải thích ở phần ZZ0000ZZ bạn nên tạo
các hệ thống phân cấp khác nhau của các nhóm cho từng tài nguyên hoặc nhóm
nguồn lực mà bạn muốn kiểm soát. Vì vậy, bạn nên gắn tmpfs vào
/sys/fs/cgroup và tạo thư mục cho từng tài nguyên hoặc tài nguyên của cgroup
nhóm::

# mount -t tmpfs cgroup_root /sys/fs/cgroup
  # mkdir /sys/fs/cgroup/rg1

Để gắn kết hệ thống phân cấp nhóm chỉ với bộ xử lý và bộ nhớ
hệ thống con, loại::

# mount -t cgroup -o cpuset,bộ nhớ hier1 /sys/fs/cgroup/rg1

Mặc dù việc kết nối lại các nhóm hiện được hỗ trợ nhưng điều đó không được khuyến khích
để sử dụng nó. Việc kết nối lại cho phép thay đổi các hệ thống con bị ràng buộc và
phát hành_agent. Việc đóng lại hầu như không hữu ích vì nó chỉ hoạt động khi
hệ thống phân cấp trống và bản thân Release_agent nên được thay thế bằng
fsnotify thông thường. Hỗ trợ cho việc kể lại sẽ bị xóa trong
tương lai.

Để chỉ định Release_agent của hệ thống phân cấp::

# mount -t cgroup -o cpuset,release_agent="/sbin/cpuset_release_agent" \
    xxx /sys/fs/cgroup/rg1

Lưu ý rằng việc chỉ định 'release_agent' nhiều lần sẽ trả về lỗi.

Lưu ý rằng việc thay đổi tập hợp các hệ thống con hiện chỉ được hỗ trợ
khi hệ thống phân cấp bao gồm một nhóm (gốc) duy nhất. Hỗ trợ
khả năng liên kết/hủy liên kết tùy ý các hệ thống con khỏi một hệ thống hiện có
Hệ thống phân cấp cgroup dự định sẽ được triển khai trong tương lai.

Sau đó, trong /sys/fs/cgroup/rg1, bạn có thể tìm thấy một cây tương ứng với
cây của các nhóm trong hệ thống. Ví dụ: /sys/fs/cgroup/rg1
là cgroup nắm giữ toàn bộ hệ thống.

Nếu bạn muốn thay đổi giá trị của Release_agent::

# echo "/sbin/new_release_agent" > /sys/fs/cgroup/rg1/release_agent

Nó cũng có thể được thay đổi thông qua remount.

Nếu bạn muốn tạo một nhóm mới trong /sys/fs/cgroup/rg1::

# cd /sys/fs/cgroup/rg1
  # mkdir my_cgroup

Bây giờ bạn muốn làm gì đó với cgroup này:

# cd my_cgroup

Trong thư mục này bạn có thể tìm thấy một số tập tin::

# ls
  nhiệm vụ cgroup.procs notification_on_release
  (cộng với bất kỳ tệp nào được thêm bởi các hệ thống con đính kèm)

Bây giờ hãy đính kèm shell của bạn vào nhóm này::

# /bin/echo $$ > nhiệm vụ

Bạn cũng có thể tạo các nhóm bên trong nhóm của mình bằng cách sử dụng mkdir trong phần này
thư mục::

# mkdir my_sub_cs

Để xóa một nhóm, chỉ cần sử dụng rmdir::

# rmdir my_sub_cs

Điều này sẽ thất bại nếu cgroup đang được sử dụng (có cgroups bên trong, hoặc
có các quy trình được đính kèm hoặc được duy trì bởi các hệ thống con cụ thể khác
tham khảo).

2.2 Quy trình đính kèm
-----------------------

::

# /bin/echo PID > nhiệm vụ

Lưu ý rằng đó là PID, không phải PID. Bạn chỉ có thể đính kèm nhiệm vụ ONE tại một thời điểm.
Nếu bạn có nhiều nhiệm vụ cần đính kèm, bạn phải thực hiện lần lượt từng nhiệm vụ::

# /bin/echo PID1 > nhiệm vụ
  # /bin/echo PID2 > nhiệm vụ
	  ...
# /bin/echo PIDn > nhiệm vụ

Bạn có thể đính kèm tác vụ shell hiện tại bằng cách lặp lại 0::

# echo 0 > nhiệm vụ

Bạn có thể sử dụng tệp cgroup.procs thay vì tệp tác vụ để di chuyển tất cả
các chủ đề trong một nhóm chủ đề cùng một lúc. Báo lại PID của bất kỳ nhiệm vụ nào trong một
threadgroup tới cgroup.procs khiến tất cả các tác vụ trong threadgroup đó bị
gắn liền với cgroup. Viết 0 vào cgroup.procs sẽ di chuyển tất cả các tác vụ
trong nhóm luồng của tác vụ viết.

Lưu ý: Vì mỗi tác vụ luôn là thành viên của đúng một nhóm trong mỗi
hệ thống phân cấp được gắn kết, để xóa một tác vụ khỏi nhóm hiện tại của nó, bạn phải
di chuyển nó vào một nhóm mới (có thể là nhóm gốc) bằng cách ghi vào
tập tin nhiệm vụ của cgroup mới.

Lưu ý: Do một số hạn chế được thực thi bởi một số hệ thống con cgroup, việc di chuyển
một quá trình tới một nhóm khác có thể thất bại.

2.3 Gắn hệ thống phân cấp theo tên
----------------------------------

Truyền tùy chọn name=<x> khi gắn cấu trúc phân cấp cgroups
liên kết tên đã cho với hệ thống phân cấp.  Điều này có thể được sử dụng khi
gắn kết một hệ thống phân cấp có sẵn, để gọi nó theo tên
chứ không phải bởi tập hợp các hệ thống con đang hoạt động của nó.  Mỗi hệ thống phân cấp là một trong hai
không tên hoặc có tên duy nhất.

Tên phải khớp với [\w.-]+

Khi chuyển tùy chọn name=<x> cho hệ thống phân cấp mới, bạn cần phải
chỉ định các hệ thống con theo cách thủ công; hành vi kế thừa của việc gắn kết tất cả
các hệ thống con khi không có hệ thống nào được chỉ định rõ ràng sẽ không được hỗ trợ khi
bạn đặt tên cho một hệ thống con.

Tên của hệ thống con xuất hiện như một phần của mô tả phân cấp
trong /proc/mounts và /proc/<pid>/cgroups.


3. Hạt nhân API
===============

3.1 Tổng quan
-------------

Mỗi hệ thống con kernel muốn nối vào nhóm chung
hệ thống cần tạo một đối tượng cgroup_subsys. Cái này chứa
các phương thức khác nhau, đó là các lệnh gọi lại từ hệ thống cgroup, cùng với
với ID hệ thống con sẽ được hệ thống cgroup chỉ định.

Các trường khác trong đối tượng cgroup_subsys bao gồm:

- subsys_id: chỉ mục mảng duy nhất cho hệ thống con, cho biết hệ thống con nào
  mục trong cgroup->subsys[] hệ thống con này sẽ quản lý.

- tên: nên được khởi tạo thành tên hệ thống con duy nhất. nên
  không dài hơn MAX_CGROUP_TYPE_NAMELEN.

- Early_init: cho biết hệ thống con có cần khởi tạo sớm không
  lúc khởi động hệ thống.

Mỗi đối tượng cgroup được hệ thống tạo ra có một mảng các con trỏ,
được lập chỉ mục theo ID hệ thống con; con trỏ này hoàn toàn được quản lý bởi
hệ thống con; mã cgroup chung sẽ không bao giờ chạm vào con trỏ này.

3.2 Đồng bộ hóa
-------------------

Có một mutex toàn cầu, cgroup_mutex, được cgroup sử dụng
hệ thống. Điều này nên được thực hiện bởi bất cứ ai muốn sửa đổi một
cgroup. Nó cũng có thể được thực hiện để ngăn chặn các nhóm bị
đã được sửa đổi, nhưng các khóa cụ thể hơn có thể phù hợp hơn trong trường hợp đó
tình huống.

Xem kernel/cgroup.c để biết thêm chi tiết.

Các hệ thống con có thể lấy/giải phóng cgroup_mutex thông qua các chức năng
cgroup_lock()/cgroup_unlock().

Việc truy cập con trỏ nhóm của tác vụ có thể được thực hiện theo các cách sau:
- trong khi giữ cgroup_mutex
- trong khi giữ alloc_lock của nhiệm vụ (thông qua task_lock())
- bên trong phần rcu_read_lock() thông qua rcu_dereference()

3.3 Hệ thống con API
--------------------

Mỗi hệ thống con nên:

- thêm một mục trong linux/cgroup_subsys.h
- định nghĩa một đối tượng cgroup_subsys có tên <name>_cgrp_subsys

Mỗi hệ thống con có thể xuất các phương thức sau. Bắt buộc duy nhất
các phương thức là css_alloc/free. Bất kỳ cái nào khác không có giá trị đều được coi là
thành công nhé.

ZZ0000ZZ
(cgroup_mutex do người gọi giữ)

Được gọi để phân bổ một đối tượng trạng thái hệ thống con cho một nhóm. các
hệ thống con nên phân bổ đối tượng trạng thái hệ thống con của nó cho thông tin được truyền
cgroup, trả về một con trỏ tới đối tượng mới khi thành công hoặc
Giá trị ERR_PTR(). Khi thành công, con trỏ hệ thống con sẽ trỏ tới
cấu trúc kiểu cgroup_subsys_state (thường được nhúng trong một
đối tượng cụ thể của hệ thống con lớn hơn), sẽ được khởi tạo bởi
hệ thống cgroup Lưu ý rằng điều này sẽ được gọi khi khởi tạo để
tạo trạng thái hệ thống con gốc cho hệ thống con này; trường hợp này có thể
được xác định bởi đối tượng cgroup đã truyền có cha mẹ NULL (vì
nó là gốc của hệ thống phân cấp) và có thể là nơi thích hợp cho
mã khởi tạo.

ZZ0000ZZ
(cgroup_mutex do người gọi giữ)

Được gọi sau khi @cgrp hoàn thành thành công tất cả các phân bổ và thực hiện
hiển thị với các trình vòng lặp cgroup_for_each_child/descendant_*(). các
hệ thống con có thể chọn không tạo được bằng cách trả về -errno. Cái này
gọi lại có thể được sử dụng để thực hiện chia sẻ trạng thái đáng tin cậy và
lan truyền dọc theo hệ thống phân cấp. Xem bình luận trên
cgroup_for_each_live_descendant_pre() để biết chi tiết.

ZZ0000ZZ
(cgroup_mutex do người gọi giữ)

Đây là bản sao của css_online() và được gọi là iff css_online()
đã thành công trên @cgrp. Điều này báo hiệu sự bắt đầu của sự kết thúc
@cgrp. @cgrp đang bị xóa và hệ thống con sẽ bắt đầu giảm
tất cả các tài liệu tham khảo nó đang giữ trên @cgrp. Khi tất cả các tài liệu tham khảo bị loại bỏ,
Việc xóa cgroup sẽ chuyển sang bước tiếp theo - css_free(). Sau này
gọi lại, @cgrp sẽ được coi là đã chết đối với hệ thống con.

ZZ0000ZZ
(cgroup_mutex do người gọi giữ)

Hệ thống cgroup sắp giải phóng @cgrp; hệ thống con sẽ giải phóng
đối tượng trạng thái hệ thống con của nó. Vào thời điểm phương thức này được gọi, @cgrp
hoàn toàn không được sử dụng; @cgrp->parent vẫn hợp lệ. (Lưu ý - cũng có thể
được gọi cho một nhóm mới được tạo nếu xảy ra lỗi sau đó
phương thức create() của hệ thống con đã được gọi cho cgroup mới).

ZZ0000ZZ
(cgroup_mutex do người gọi giữ)

Được gọi trước khi chuyển một hoặc nhiều nhiệm vụ vào một nhóm; nếu
hệ thống con trả về lỗi, điều này sẽ hủy bỏ thao tác đính kèm.
@tset chứa các tác vụ được đính kèm và được đảm bảo có tại
ít nhất một nhiệm vụ trong đó.

Nếu có nhiều tác vụ trong tập tác vụ thì:
  - đảm bảo rằng tất cả đều thuộc cùng một nhóm chủ đề
  - @tset chứa tất cả các tác vụ từ nhóm luồng dù có hay không
    họ đang chuyển nhóm
  - nhiệm vụ đầu tiên là người lãnh đạo

Mỗi mục @tset cũng chứa nhóm cũ của nhiệm vụ và các nhiệm vụ
không thể bỏ qua việc chuyển đổi nhóm một cách dễ dàng bằng cách sử dụng
Trình vòng lặp cgroup_taskset_for_each(). Lưu ý rằng điều này không được gọi trên
cái nĩa. Nếu phương thức này trả về 0 (thành công) thì phương thức này vẫn hợp lệ
trong khi người gọi giữ cgroup_mutex và được đảm bảo rằng
Attach() hoặc cancel_attach() sẽ được gọi trong tương lai.

ZZ0000ZZ
(cgroup_mutex do người gọi giữ)

Một thao tác tùy chọn sẽ khôi phục cấu hình của @css về
trạng thái ban đầu.  Điều này hiện chỉ được sử dụng trên hệ thống phân cấp thống nhất
khi một hệ thống con bị vô hiệu hóa trên cgroup thông qua
"cgroup.subtree_control" nhưng vẫn phải được bật vì khác
các hệ thống con phụ thuộc vào nó.  lõi cgroup làm cho một css như vậy trở nên vô hình bởi
xóa các tệp giao diện liên quan và gọi lệnh gọi lại này để
rằng hệ thống con ẩn có thể trở về trạng thái trung tính ban đầu.
Điều này ngăn chặn việc kiểm soát tài nguyên không mong muốn từ một css ẩn và
đảm bảo rằng cấu hình ở trạng thái ban đầu khi nó được thực hiện
có thể nhìn thấy lại sau này.

ZZ0000ZZ
(cgroup_mutex do người gọi giữ)

Được gọi khi thao tác đính kèm tác vụ không thành công sau khi can_attach() thành công.
Một hệ thống con có can_attach() có một số tác dụng phụ sẽ cung cấp điều này
để hệ thống con có thể thực hiện khôi phục. Nếu không thì không cần thiết.
Điều này sẽ chỉ được gọi về các hệ thống con có hoạt động can_attach() có
đã thành công. Các tham số giống hệt với can_attach().

ZZ0000ZZ
(cgroup_mutex do người gọi giữ)

Được gọi sau khi tác vụ đã được gắn vào cgroup, để cho phép mọi
hoạt động sau đính kèm yêu cầu phân bổ hoặc chặn bộ nhớ.
Các tham số giống hệt với can_attach().

ZZ0000ZZ

Được gọi khi một tác vụ được phân nhánh thành một nhóm.

ZZ0000ZZ

Được gọi trong khi thoát nhiệm vụ.

ZZ0000ZZ

Được gọi khi task_struct được giải phóng.

ZZ0000ZZ
(cgroup_mutex do người gọi giữ)

Được gọi khi một hệ thống con cgroup chuyển sang một hệ thống phân cấp khác
và nhóm gốc. Hiện nay điều này sẽ chỉ liên quan đến việc di chuyển giữa
hệ thống phân cấp mặc định (không bao giờ có nhóm con) và hệ thống phân cấp
đang được tạo/hủy (và do đó không có nhóm con).

4. Sử dụng thuộc tính mở rộng
=============================

hệ thống tập tin cgroup hỗ trợ một số loại thuộc tính mở rộng nhất định trong
thư mục và tập tin.  Các loại được hỗ trợ hiện tại là:

- Đáng tin cậy (XATTR_TRUSTED)
	- Bảo mật (XATTR_SECURITY)

Cả hai đều yêu cầu khả năng thiết lập CAP_SYS_ADMIN.

Giống như trong tmpfs, các thuộc tính mở rộng trong hệ thống tập tin cgroup được lưu trữ
sử dụng bộ nhớ kernel và bạn nên giữ mức sử dụng ở mức tối thiểu.  Cái này
là lý do tại sao các thuộc tính mở rộng do người dùng xác định không được hỗ trợ, vì
bất kỳ người dùng nào cũng có thể làm điều đó và không có giới hạn về kích thước giá trị.

Người dùng hiện tại được biết đến cho tính năng này là SELinux để hạn chế việc sử dụng cgroup
trong các thùng chứa và systemd cho các loại dữ liệu meta như PID chính trong một nhóm
(systemd tạo một nhóm cho mỗi dịch vụ).

5. Câu hỏi
============

::

Hỏi: '/bin/echo' này có chuyện gì thế?
  Trả lời: lệnh 'echo' dựng sẵn của bash không kiểm tra các cuộc gọi tới write() đối với
     lỗi. Nếu bạn sử dụng nó trong hệ thống tập tin cgroup, bạn sẽ không bị
     có thể cho biết một lệnh đã thành công hay thất bại.

Câu hỏi: Khi tôi đính kèm các quy trình, chỉ dòng đầu tiên mới thực sự được đính kèm !
  Đáp: Chúng tôi chỉ có thể trả về một mã lỗi cho mỗi lệnh gọi tới hàm write(). Vì vậy bạn cũng nên
     chỉ đặt ONE PID.
