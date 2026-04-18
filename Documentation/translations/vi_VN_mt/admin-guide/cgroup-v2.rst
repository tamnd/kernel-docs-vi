.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/cgroup-v2.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _cgroup-v2:

==================
Nhóm kiểm soát v2
================

:Ngày: Tháng 10 năm 2015
:Tác giả: Tejun Heo <tj@kernel.org>

Đây là tài liệu có thẩm quyền về thiết kế, giao diện và
quy ước của cgroup v2.  Nó mô tả tất cả các khía cạnh mà người dùng có thể nhìn thấy
của cgroup bao gồm các hành vi điều khiển cốt lõi và cụ thể.  Tất cả
những thay đổi trong tương lai phải được phản ánh trong tài liệu này.  Tài liệu cho
v1 có sẵn dưới dạng ZZ0000ZZ.

.. CONTENTS

   [Whenever any new section is added to this document, please also add
    an entry here.]

   1. Introduction
     1-1. Terminology
     1-2. What is cgroup?
   2. Basic Operations
     2-1. Mounting
     2-2. Organizing Processes and Threads
       2-2-1. Processes
       2-2-2. Threads
     2-3. [Un]populated Notification
     2-4. Controlling Controllers
       2-4-1. Availability
       2-4-2. Enabling and Disabling
       2-4-3. Top-down Constraint
       2-4-4. No Internal Process Constraint
     2-5. Delegation
       2-5-1. Model of Delegation
       2-5-2. Delegation Containment
     2-6. Guidelines
       2-6-1. Organize Once and Control
       2-6-2. Avoid Name Collisions
   3. Resource Distribution Models
     3-1. Weights
     3-2. Limits
     3-3. Protections
     3-4. Allocations
   4. Interface Files
     4-1. Format
     4-2. Conventions
     4-3. Core Interface Files
   5. Controllers
     5-1. CPU
       5-1-1. CPU Interface Files
     5-2. Memory
       5-2-1. Memory Interface Files
       5-2-2. Usage Guidelines
       5-2-3. Reclaim Protection
       5-2-4. Memory Ownership
     5-3. IO
       5-3-1. IO Interface Files
       5-3-2. Writeback
       5-3-3. IO Latency
         5-3-3-1. How IO Latency Throttling Works
         5-3-3-2. IO Latency Interface Files
       5-3-4. IO Priority
     5-4. PID
       5-4-1. PID Interface Files
     5-5. Cpuset
       5.5-1. Cpuset Interface Files
     5-6. Device controller
     5-7. RDMA
       5-7-1. RDMA Interface Files
     5-8. DMEM
       5-8-1. DMEM Interface Files
     5-9. HugeTLB
       5.9-1. HugeTLB Interface Files
     5-10. Misc
       5.10-1 Misc Interface Files
       5.10-2 Migration and Ownership
     5-11. Others
       5-11-1. perf_event
     5-N. Non-normative information
       5-N-1. CPU controller root cgroup process behaviour
       5-N-2. IO controller root cgroup process behaviour
   6. Namespace
     6-1. Basics
     6-2. The Root and Views
     6-3. Migration and setns(2)
     6-4. Interaction with Other Namespaces
   P. Information on Kernel Programming
     P-1. Filesystem Support for Writeback
   D. Deprecated v1 Core Features
   R. Issues with v1 and Rationales for v2
     R-1. Multiple Hierarchies
     R-2. Thread Granularity
     R-3. Competition Between Inner Nodes and Threads
     R-4. Other Interface Issues
     R-5. Controller Issues and Remedies
       R-5-1. Memory


Giới thiệu
============

Thuật ngữ
-----------

"cgroup" là viết tắt của "nhóm kiểm soát" và không bao giờ viết hoa.  các
dạng số ít được sử dụng để chỉ toàn bộ đặc điểm và cũng như một
vòng loại như trong "bộ điều khiển cgroup".  Khi đề cập rõ ràng đến
nhiều nhóm kiểm soát riêng lẻ, dạng số nhiều "cgroups" sẽ được sử dụng.


cgroup là gì?
---------------

cgroup là một cơ chế tổ chức các quy trình theo thứ bậc và
phân phối tài nguyên hệ thống dọc theo hệ thống phân cấp theo cách được kiểm soát và
cách có thể cấu hình được.

cgroup phần lớn bao gồm hai phần - lõi và bộ điều khiển.
Lõi cgroup chịu trách nhiệm chính trong việc tổ chức theo thứ bậc
quá trình.  Bộ điều khiển cgroup thường chịu trách nhiệm về
phân phối một loại tài nguyên hệ thống cụ thể dọc theo hệ thống phân cấp
mặc dù có những bộ điều khiển tiện ích phục vụ các mục đích khác ngoài
phân phối tài nguyên.

Các nhóm tạo thành một cấu trúc cây và mọi tiến trình trong hệ thống đều thuộc về
vào một và chỉ một nhóm.  Tất cả các luồng của một tiến trình đều thuộc về
cùng một nhóm.  Khi tạo, tất cả các quy trình được đặt trong cgroup
quá trình cha mẹ thuộc về vào thời điểm đó.  Một tiến trình có thể được di chuyển
sang một nhóm khác.  Việc di chuyển một quá trình chưa ảnh hưởng đến
các quá trình con cháu hiện có.

Theo những ràng buộc về cấu trúc nhất định, bộ điều khiển có thể được bật hoặc
bị vô hiệu hóa có chọn lọc trên một nhóm.  Tất cả các hành vi của người điều khiển đều
phân cấp - nếu bộ điều khiển được bật trên một nhóm, nó sẽ ảnh hưởng đến tất cả
các quy trình thuộc về các nhóm bao gồm toàn bộ
phân cấp phụ của nhóm cgroup.  Khi bộ điều khiển được bật trên một thiết bị lồng nhau
cgroup, nó luôn hạn chế việc phân phối tài nguyên hơn nữa.  các
không thể thực hiện được các hạn chế được đặt gần gốc hơn trong hệ thống phân cấp
ghi đè từ xa hơn.


Hoạt động cơ bản
================

gắn kết
--------

Không giống như v1, cgroup v2 chỉ có một hệ thống phân cấp duy nhất.  Nhóm v2
hệ thống phân cấp có thể được gắn kết bằng lệnh mount sau ::

# mount -t cgroup2 không có $MOUNT_POINT

hệ thống tập tin cgroup2 có số ma thuật 0x63677270 ("cgrp").  Tất cả
bộ điều khiển hỗ trợ v2 và không bị ràng buộc với hệ thống phân cấp v1 là
tự động được liên kết với hệ thống phân cấp v2 và hiển thị ở thư mục gốc.
Các bộ điều khiển không được sử dụng tích cực trong hệ thống phân cấp v2 có thể
ràng buộc với các hệ thống phân cấp khác.  Điều này cho phép trộn lẫn hệ thống phân cấp v2 với
nhiều hệ thống phân cấp kế thừa v1 theo cách tương thích ngược hoàn toàn.

Bộ điều khiển chỉ có thể được di chuyển qua các cấu trúc phân cấp sau khi bộ điều khiển
không còn được tham chiếu trong hệ thống phân cấp hiện tại của nó.  Bởi vì mỗi nhóm
trạng thái bộ điều khiển bị hủy không đồng bộ và bộ điều khiển có thể
có các tài liệu tham khảo kéo dài, bộ điều khiển có thể không hiển thị ngay lập tức trên
hệ thống phân cấp v2 sau umount cuối cùng của hệ thống phân cấp trước đó.
Tương tự, bộ điều khiển phải được tắt hoàn toàn để được chuyển ra khỏi
hệ thống phân cấp thống nhất và có thể mất một thời gian để người khuyết tật
bộ điều khiển có sẵn cho các hệ thống phân cấp khác; hơn nữa, do
đối với sự phụ thuộc giữa các bộ điều khiển, các bộ điều khiển khác có thể cần phải được
cũng bị vô hiệu hóa.

Mặc dù hữu ích cho việc phát triển và cấu hình thủ công, nhưng việc di chuyển
bộ điều khiển linh hoạt giữa v2 và các hệ thống phân cấp khác là
không được khuyến khích sử dụng trong sản xuất.  Nên quyết định
các hệ thống phân cấp và liên kết bộ điều khiển trước khi bắt đầu sử dụng
bộ điều khiển sau khi khởi động hệ thống.

Trong quá trình chuyển đổi sang v2, phần mềm quản lý hệ thống vẫn có thể
tự động gắn kết hệ thống tập tin v1 cgroup và chiếm quyền điều khiển tất cả các bộ điều khiển
trong quá trình khởi động, trước khi có thể can thiệp thủ công. Để thực hiện thử nghiệm
và thử nghiệm dễ dàng hơn, tham số kernel cgroup_no_v1= cho phép
vô hiệu hóa bộ điều khiển trong v1 và làm cho chúng luôn có sẵn trong v2.

cgroup v2 hiện hỗ trợ các tùy chọn gắn kết sau.

nsdelegate
	Hãy coi các không gian tên cgroup là ranh giới ủy nhiệm.  Cái này
	tùy chọn có trên toàn hệ thống và chỉ có thể được đặt trên mount hoặc sửa đổi
	thông qua remount từ không gian tên init.  Tùy chọn gắn kết là
	bị bỏ qua trên các mount không gian tên không phải init.  Vui lòng tham khảo
	Phần ủy quyền để biết chi tiết.

ủng hộ mod
        Giảm độ trễ của các sửa đổi nhóm động như
        di chuyển tác vụ và bật/tắt bộ điều khiển với chi phí thực hiện
        các hoạt động trên đường dẫn nóng như fork và exit đắt hơn.
        Mô hình sử dụng tĩnh của việc tạo một nhóm, cho phép
        bộ điều khiển, sau đó gieo hạt bằng CLONE_INTO_CGROUP là
        không bị ảnh hưởng bởi tùy chọn này.

bộ nhớ_localevents
        Chỉ điền vào bộ nhớ.events dữ liệu cho nhóm hiện tại,
        và không có bất kỳ cây con nào. Đây là hành vi kế thừa, mặc định
        hành vi không có tùy chọn này là bao gồm số lượng cây con.
        Tùy chọn này có trên toàn hệ thống và chỉ có thể được đặt trên mount hoặc
        được sửa đổi thông qua remount từ không gian tên init. gắn kết
        tùy chọn bị bỏ qua khi gắn kết không gian tên không phải init.

bộ nhớ_recursiveprot
        Áp dụng đệ quy bảo vệ Memory.min và Memory.low cho
        toàn bộ cây con mà không yêu cầu hướng xuống rõ ràng
        nhân giống vào các nhóm lá.  Điều này cho phép bảo vệ toàn bộ
        cây con với nhau trong khi vẫn duy trì sự cạnh tranh tự do
        trong các cây con đó.  Đây lẽ ra phải là mặc định
        hành vi nhưng là một tùy chọn gắn kết để tránh thiết lập thoái lui
        dựa vào ngữ nghĩa ban đầu (ví dụ: chỉ định không có thật
        giá trị bảo vệ 'bỏ qua' cao ở cấp độ cây cao hơn).

bộ nhớ_hugetlb_accounting
        Tính mức sử dụng bộ nhớ HugeTLB vào tổng thể của nhóm
        việc sử dụng bộ nhớ cho bộ điều khiển bộ nhớ (với mục đích
        báo cáo thống kê và bảo vệ bộ nhớ). Đây là một cái mới
        hành vi có thể làm thoái lui các thiết lập hiện có, vì vậy nó phải
        đã chọn tham gia một cách rõ ràng với tùy chọn gắn kết này.

Một số lưu ý cần ghi nhớ:

* Không có quản lý nhóm HugeTLB liên quan đến bộ nhớ
          bộ điều khiển. Nhóm được phân bổ trước không thuộc về bất kỳ ai.
          Cụ thể, khi một folio HugeTLB mới được phân bổ cho
          nhóm, nó không được tính từ quan điểm của
          bộ điều khiển bộ nhớ. Nó chỉ được tính phí cho một nhóm khi nó
          thực sự được sử dụng (ví dụ: tại thời điểm lỗi trang). Bộ nhớ máy chủ
          quản lý cam kết quá mức phải xem xét điều này khi định cấu hình
          giới hạn cứng. Nói chung, quản lý nhóm HugeTLB nên
          được thực hiện thông qua các cơ chế khác (chẳng hạn như bộ điều khiển HugeTLB).
        * Không sạc được folio HugeTLB vào bộ điều khiển bộ nhớ
          kết quả là SIGBUS. Điều này có thể xảy ra ngay cả khi nhóm HugeTLB
          vẫn còn các trang có sẵn (nhưng đã đạt đến giới hạn cgroup và
          nỗ lực đòi lại không thành công).
        * Việc sạc bộ nhớ HugeTLB vào bộ điều khiển bộ nhớ sẽ ảnh hưởng
          bảo vệ bộ nhớ và lấy lại động lực. Mọi điều chỉnh không gian người dùng
          (ví dụ: giới hạn thấp, tối thiểu) cần tính đến điều này.
        * Các trang HugeTLB được sử dụng khi tùy chọn này không được chọn
          sẽ không bị bộ điều khiển bộ nhớ theo dõi (ngay cả khi cgroup
          v2 sẽ được cập nhật lại sau này).

pids_localevents
        Tùy chọn khôi phục hành vi giống v1 của pids.events:max, đó chỉ là
        lỗi fork cục bộ (bên trong cgroup thích hợp) được tính. Không có cái này
        tùy chọn pids.events.max đại diện cho bất kỳ việc thực thi pids.max nào trên
        cây con của cgroup.



Tổ chức các tiến trình và chủ đề
--------------------------------

Quy trình
~~~~~~~~~

Ban đầu, chỉ tồn tại nhóm gốc mà tất cả các tiến trình thuộc về.
Một nhóm con có thể được tạo bằng cách tạo thư mục con::

# mkdir $CGROUP_NAME

Một nhóm nhất định có thể có nhiều nhóm con tạo thành một cây
cấu trúc.  Mỗi cgroup có một tệp giao diện có thể ghi được
"cgroup.procs".  Khi đọc, nó liệt kê các PID của tất cả các tiến trình
thuộc về nhóm một trên một dòng.  Các PID không được sắp xếp thứ tự và
cùng một PID có thể xuất hiện nhiều lần nếu quá trình được chuyển sang
một nhóm khác rồi quay lại hoặc PID đã được tái chế trong khi đọc.

Một tiến trình có thể được di chuyển vào một nhóm bằng cách ghi PID của nó vào
nhắm mục tiêu tệp "cgroup.procs" của cgroup.  Chỉ có một quá trình có thể được di chuyển
trong một cuộc gọi viết (2).  Nếu một tiến trình bao gồm nhiều
các luồng, việc ghi PID của bất kỳ luồng nào sẽ di chuyển tất cả các luồng của
quá trình.

Khi một tiến trình phân nhánh thành một tiến trình con, tiến trình mới sẽ được sinh ra trong
cgroup mà quá trình fork thuộc về vào thời điểm
hoạt động.  Sau khi thoát, một tiến trình vẫn được liên kết với cgroup
mà nó thuộc về lúc thoát ra cho đến khi được thu hoạch; tuy nhiên, một
quá trình zombie không xuất hiện trong "cgroup.procs" và do đó không thể
đã chuyển sang cgroup khác.

Một nhóm không có tiến trình con hoặc tiến trình trực tiếp nào có thể
bị phá hủy bằng cách loại bỏ thư mục.  Lưu ý rằng một nhóm không
có bất kỳ đứa con nào và chỉ liên quan đến các quá trình zombie
được coi là trống và có thể bị xóa::

# rmdir $CGROUP_NAME

"/proc/$PID/cgroup" liệt kê tư cách thành viên nhóm của một quy trình.  Nếu di sản
cgroup đang được sử dụng trong hệ thống, file này có thể chứa nhiều dòng,
một cho mỗi hệ thống phân cấp.  Mục nhập cho cgroup v2 luôn nằm trong
định dạng "0::$PATH"::

# cat /proc/842/cgroup
  ...
0::/test-cgroup/test-cgroup-lồng nhau

Nếu quá trình trở thành zombie và nhóm mà nó được liên kết với
bị xóa sau đó, " (đã xóa)" được thêm vào đường dẫn::

# cat /proc/842/cgroup
  ...
0::/test-cgroup/test-cgroup-nested (đã xóa)


chủ đề
~~~~~~~

cgroup v2 hỗ trợ mức độ chi tiết của luồng cho một tập hợp con các bộ điều khiển
hỗ trợ các trường hợp sử dụng yêu cầu phân phối tài nguyên theo cấp bậc trên
các luồng của một nhóm các tiến trình.  Theo mặc định, tất cả các chủ đề của một
quá trình thuộc về cùng một nhóm, cũng đóng vai trò là tài nguyên
miền để lưu trữ các mức tiêu thụ tài nguyên không dành riêng cho một
tiến trình hoặc luồng.  Chế độ luồng cho phép các luồng được trải rộng trên
một cây con trong khi vẫn duy trì miền tài nguyên chung cho chúng.

Bộ điều khiển hỗ trợ chế độ luồng được gọi là bộ điều khiển luồng.
Những cái không được gọi là bộ điều khiển miền.

Đánh dấu một luồng cgroup làm cho nó tham gia vào miền tài nguyên của nó
parent dưới dạng một nhóm luồng.  Cha mẹ có thể là một luồng khác
cgroup có miền tài nguyên ở cấp cao hơn trong hệ thống phân cấp.  Gốc
của một cây con có luồng, nghĩa là tổ tiên gần nhất không phải là
luồng, được gọi là miền luồng hoặc gốc luồng có thể hoán đổi cho nhau và
đóng vai trò là miền tài nguyên cho toàn bộ cây con.

Bên trong cây con có luồng, các luồng của một tiến trình có thể được đặt vào
các nhóm khác nhau và không tuân theo quy trình nội bộ
ràng buộc - bộ điều khiển luồng có thể được kích hoạt trên các nhóm không có lá
cho dù họ có chủ đề trong đó hay không.

Vì nhóm miền theo luồng lưu trữ tất cả tài nguyên miền
mức tiêu thụ của cây con, nó được coi là có nội bộ
tiêu thụ tài nguyên cho dù có các tiến trình trong đó hay không và
không thể có các nhóm con không được phân luồng.  Bởi vì
nhóm gốc không bị ràng buộc về quy trình nội bộ, nó có thể
vừa phục vụ như một miền theo luồng vừa là cha mẹ của các nhóm miền.

Chế độ hoạt động hiện tại hoặc loại của nhóm được hiển thị trong
Tệp "cgroup.type" cho biết cgroup có bình thường không
miền, một miền đóng vai trò là miền của cây con theo luồng,
hoặc một nhóm luồng.

Khi tạo, một nhóm luôn là một nhóm miền và có thể được tạo
xâu chuỗi bằng cách ghi "luồng" vào tệp "cgroup.type".  các
hoạt động là một hướng::

# echo được xâu chuỗi > cgroup.type

Sau khi được phân luồng, nhóm không thể được tạo lại thành miền.  Để kích hoạt
chế độ luồng, các điều kiện sau phải được đáp ứng.

- Vì cgroup sẽ tham gia vào miền tài nguyên của cha mẹ.  phụ huynh
  phải là một miền (có luồng) hợp lệ hoặc một nhóm theo luồng.

- Khi tên miền gốc là miền chưa được phân luồng thì nó không được có bất kỳ miền nào
  bộ điều khiển được kích hoạt hoặc các miền con được điền sẵn.  Gốc là
  được miễn yêu cầu này.

Về mặt cấu trúc liên kết, một nhóm có thể ở trạng thái không hợp lệ.  Hãy xem xét
cấu trúc liên kết sau::

A (miền có luồng) - B (có luồng) - C (miền, vừa tạo)

C được tạo dưới dạng miền nhưng không được kết nối với cha mẹ có thể
lưu trữ các miền con.  C không thể được sử dụng cho đến khi nó được chuyển thành
nhóm luồng.  Tệp "cgroup.type" sẽ báo cáo "tên miền (không hợp lệ)" trong
những trường hợp này.  Hoạt động không thành công do sử dụng cấu trúc liên kết không hợp lệ
EOPNOTSUPP là lỗi.

Một nhóm miền được chuyển thành miền luồng khi một trong các miền con của nó
cgroup trở thành bộ điều khiển luồng hoặc luồng được bật trong
Tệp "cgroup.subtree_control" trong khi có các tiến trình trong cgroup.
Miền luồng sẽ trở lại miền bình thường khi các điều kiện
rõ ràng.

Khi đọc, "cgroup.threads" chứa danh sách ID luồng của tất cả
chủ đề trong cgroup.  Ngoại trừ việc các hoạt động được thực hiện trên mỗi luồng
thay vì mỗi tiến trình, "cgroup.threads" có cùng định dạng và
hoạt động tương tự như "cgroup.procs".  Trong khi "cgroup.threads" có thể
được ghi vào bất kỳ nhóm nào, vì nó chỉ có thể di chuyển các luồng trong cùng một nhóm
miền luồng, các hoạt động của nó được giới hạn bên trong mỗi luồng
cây con.

Nhóm miền luồng đóng vai trò là miền tài nguyên cho toàn bộ
cây con, và trong khi các luồng có thể nằm rải rác trên cây con,
tất cả các quy trình được coi là nằm trong cgroup miền luồng.
"cgroup.procs" trong một miền theo chuỗi cgroup chứa các PID của tất cả
xử lý trong cây con và không thể đọc được trong cây con.
Tuy nhiên, "cgroup.procs" có thể được ghi vào từ bất kỳ đâu trong cây con
để di chuyển tất cả các luồng của quy trình phù hợp sang nhóm.

Chỉ có thể kích hoạt bộ điều khiển luồng trong cây con có luồng.  Khi nào
bộ điều khiển luồng được kích hoạt bên trong cây con có luồng, nó chỉ
hạch toán và kiểm soát việc tiêu thụ tài nguyên liên quan đến
các chủ đề trong cgroup và các nhánh con của nó.  Mọi hoạt động tiêu dùng mà
không bị ràng buộc với một chủ đề cụ thể thuộc về nhóm tên miền theo chuỗi.

Bởi vì cây con theo luồng không được miễn xử lý nội bộ
hạn chế, bộ điều khiển luồng phải có khả năng xử lý sự cạnh tranh
giữa các luồng trong một nhóm không có lá và các nhóm con của nó.  Mỗi
bộ điều khiển luồng xác định cách xử lý các cuộc thi như vậy.

Hiện tại, các bộ điều khiển sau đã được phân luồng và có thể được bật
trong một nhóm theo chuỗi::

- CPU
- bộ vi xử lý
- sự kiện hoàn hảo
- pid

[Un]thông báo được điền
--------------------------

Mỗi nhóm không phải root có một tệp "cgroup.events" chứa
trường "dân cư" cho biết liệu phân cấp phụ của nhóm có
các tiến trình trực tiếp trong đó.  Giá trị của nó là 0 nếu không có tiến trình nào đang hoạt động trong
nhóm cgroup và con cháu của nó; mặt khác, 1. thăm dò ý kiến và [id]thông báo
sự kiện được kích hoạt khi giá trị thay đổi.  Điều này có thể được sử dụng, cho
Ví dụ: để bắt đầu thao tác dọn dẹp sau tất cả các quy trình của một
hệ thống phân cấp phụ đã thoát.  Các cập nhật trạng thái dân cư và
thông báo là đệ quy.  Hãy xem xét hệ thống phân cấp phụ sau đây
trong đó các số trong ngoặc đơn biểu thị số lượng tiến trình
trong mỗi nhóm::

A(4) - B(0) - C(1)
              \ D(0)

Các trường "được điền" của A, B và C sẽ là 1 trong khi D là 0. Sau trường này
quá trình trong C thoát ra, các trường "được điền" của B và C sẽ chuyển sang "0" và
các sự kiện được sửa đổi tệp sẽ được tạo trên tệp "cgroup.events" của
cả hai nhóm.


Bộ điều khiển điều khiển
-----------------------

sẵn có
~~~~~~~~~~~~

Bộ điều khiển có sẵn trong một nhóm khi nó được kernel hỗ trợ (tức là
được biên dịch, không bị vô hiệu hóa và không được gắn vào hệ thống phân cấp v1) và được liệt kê trong
tập tin "cgroup.controllers". Tính khả dụng có nghĩa là các tệp giao diện của bộ điều khiển
được hiển thị trong thư mục của cgroup, cho phép phân phối mục tiêu
nguồn lực cần được quan sát hoặc kiểm soát trong nhóm đó.

Kích hoạt và vô hiệu hóa
~~~~~~~~~~~~~~~~~~~~~~

Mỗi cgroup có một tệp "cgroup.controllers" liệt kê tất cả
bộ điều khiển có sẵn cho cgroup để kích hoạt::

Bộ điều khiển cgroup # cat
  bộ nhớ cpu io

Không có bộ điều khiển nào được bật theo mặc định.  Bộ điều khiển có thể được kích hoạt và
bị vô hiệu hóa bằng cách ghi vào tệp "cgroup.subtree_control"::

# echo "+cpu +bộ nhớ -io" > cgroup.subtree_control

Chỉ những bộ điều khiển được liệt kê trong "cgroup.controllers" mới có thể được
đã bật.  Khi nhiều thao tác được chỉ định như trên, chúng
tất cả đều thành công hoặc thất bại.  Nếu nhiều thao tác trên cùng một bộ điều khiển
được chỉ định, cái cuối cùng có hiệu lực.

Việc kích hoạt bộ điều khiển trong một nhóm cho biết rằng việc phân phối
tài nguyên mục tiêu trên các phần tử con trực tiếp của nó sẽ được kiểm soát.
Hãy xem xét hệ thống phân cấp phụ sau đây.  Các bộ điều khiển được kích hoạt là
được liệt kê trong ngoặc đơn::

A(cpu,bộ nhớ) - B(bộ nhớ) - C()
                            \ D()

Vì A đã bật "cpu" và "bộ nhớ", A sẽ kiểm soát việc phân phối
của chu kỳ CPU và bộ nhớ cho các con của nó, trong trường hợp này là B. Vì B có
"bộ nhớ" được bật nhưng không phải "CPU", C và D sẽ cạnh tranh tự do trên CPU
theo chu kỳ nhưng việc phân chia bộ nhớ dành cho B sẽ được kiểm soát.

Là bộ điều khiển điều chỉnh việc phân phối tài nguyên đích tới
con của cgroup, cho phép nó tạo giao diện của bộ điều khiển
các tập tin trong các nhóm con.  Trong ví dụ trên, bật "cpu" trên B
sẽ tạo ra "cpu." các tập tin giao diện bộ điều khiển có tiền tố trong C và
D. Tương tự như vậy, việc vô hiệu hóa "bộ nhớ" khỏi B sẽ xóa "bộ nhớ".
các tập tin giao diện bộ điều khiển có tiền tố từ C và D. Điều này có nghĩa là
tập tin giao diện bộ điều khiển - bất cứ thứ gì không bắt đầu bằng
"nhóm." được sở hữu bởi công ty mẹ chứ không phải của chính cgroup.


Ràng buộc từ trên xuống
~~~~~~~~~~~~~~~~~~~

Tài nguyên được phân phối từ trên xuống và một nhóm có thể phân phối thêm
một tài nguyên chỉ khi tài nguyên đó đã được phân phối tới nó từ
cha mẹ.  Điều này có nghĩa là tất cả các tệp "cgroup.subtree_control" không phải root
chỉ có thể chứa các bộ điều khiển được kích hoạt trong phần cha mẹ
tập tin "cgroup.subtree_control".  Bộ điều khiển chỉ có thể được kích hoạt nếu
cha mẹ đã bật bộ điều khiển và không thể sử dụng bộ điều khiển
bị vô hiệu hóa nếu một hoặc nhiều trẻ em đã kích hoạt nó.


Không có ràng buộc quy trình nội bộ
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Các nhóm không phải root có thể phân phối tài nguyên miền cho con của họ
chỉ khi họ không có bất kỳ quy trình nào của riêng mình.  Nói cách khác,
chỉ các nhóm miền không chứa bất kỳ tiến trình nào mới có thể có miền
bộ điều khiển được kích hoạt trong tệp "cgroup.subtree_control" của chúng.

Điều này đảm bảo rằng, khi bộ điều khiển miền đang xem xét phần
của hệ thống phân cấp đã kích hoạt nó, các quy trình luôn chỉ bật
những chiếc lá.  Điều này loại trừ các tình huống mà các nhóm con cạnh tranh
chống lại các quy trình nội bộ của cha mẹ.

Nhóm gốc được miễn hạn chế này.  Gốc chứa
các quy trình và mức tiêu thụ tài nguyên ẩn danh không thể liên kết được
với bất kỳ nhóm nào khác và yêu cầu sự đối xử đặc biệt từ hầu hết
bộ điều khiển.  Việc tiêu thụ tài nguyên trong nhóm gốc được quản lý như thế nào
tùy thuộc vào từng bộ điều khiển (để biết thêm thông tin về chủ đề này, vui lòng
tham khảo phần Thông tin phi quy chuẩn trong Bộ điều khiển
chương).

Lưu ý rằng hạn chế sẽ không gây cản trở nếu không có
bộ điều khiển được kích hoạt trong "cgroup.subtree_control" của nhóm.  Đây là
quan trọng vì nếu không thì sẽ không thể tạo ra con của một
cgroup đông dân cư.  Để kiểm soát việc phân phối tài nguyên của một nhóm,
cgroup phải tạo các tiến trình con và chuyển tất cả các tiến trình của nó tới
trẻ em trước khi bật bộ điều khiển trong "cgroup.subtree_control" của nó
tập tin.


Phái đoàn
----------

Mô hình ủy quyền
~~~~~~~~~~~~~~~~~~~

Một cgroup có thể được ủy quyền theo hai cách.  Đầu tiên, dành cho người ít đặc quyền hơn
người dùng bằng cách cấp quyền truy cập ghi vào thư mục và "cgroup.procs" của nó,
các tệp "cgroup.threads" và "cgroup.subtree_control" cho người dùng.
Thứ hai, nếu tùy chọn gắn kết "nsdelegate" được đặt, sẽ tự động thành
không gian tên cgroup khi tạo không gian tên.

Bởi vì các tập tin giao diện kiểm soát tài nguyên trong một thư mục nhất định
kiểm soát việc phân phối tài nguyên của cha mẹ, người được ủy quyền
không được phép viết thư cho họ.  Đối với phương pháp đầu tiên, đây là
đạt được bằng cách không cấp quyền truy cập vào các tệp này.  Đối với thứ hai, các tập tin
bên ngoài không gian tên phải được ẩn khỏi người được ủy quyền bằng phương tiện
ít nhất là gắn kết không gian tên và kernel từ chối ghi vào tất cả
các tập tin trên một không gian tên gốc từ bên trong không gian tên cgroup, ngoại trừ
những tập tin được liệt kê trong "/sys/kernel/cgroup/delegate" (bao gồm
"cgroup.procs", "cgroup.threads", "cgroup.subtree_control", v.v.).

Kết quả cuối cùng là tương đương cho cả hai loại ủy quyền.  Một lần
được ủy quyền, người dùng có thể xây dựng hệ thống phân cấp phụ trong thư mục,
tổ chức các quy trình bên trong nó khi nó thấy phù hợp và phân phối thêm
tài nguyên mà nó nhận được từ cha mẹ.  Các giới hạn và cài đặt khác
của tất cả các bộ điều khiển tài nguyên đều được phân cấp và bất kể điều gì
xảy ra trong hệ thống phân cấp phụ được ủy quyền, không gì có thể thoát khỏi
hạn chế về nguồn lực do cha mẹ áp đặt.

Hiện tại cgroup không áp đặt bất kỳ hạn chế nào về số lượng.
các nhóm trong hoặc độ sâu lồng nhau của hệ thống phân cấp phụ được ủy quyền; tuy nhiên,
điều này có thể được hạn chế rõ ràng trong tương lai.


Ngăn chặn phái đoàn
~~~~~~~~~~~~~~~~~~~~~~

Một hệ thống phân cấp phụ được ủy quyền được chứa theo nghĩa là xử lý
Người được ủy quyền không thể di chuyển vào hoặc ra khỏi hệ thống phân cấp phụ.

Đối với việc ủy quyền cho người dùng ít đặc quyền hơn, điều này đạt được bằng cách
yêu cầu các điều kiện sau cho một quy trình có euid không phải root
để di chuyển một tiến trình đích vào một nhóm bằng cách ghi PID của nó vào
tập tin "cgroup.procs".

- Người viết phải có quyền ghi vào file "cgroup.procs".

- Người viết phải có quyền ghi vào tệp "cgroup.procs" của
  tổ tiên chung của nhóm nguồn và nhóm đích.

Hai ràng buộc trên đảm bảo rằng trong khi một đại biểu có thể di chuyển
xử lý tự do trong hệ thống phân cấp phụ được ủy quyền, nó không thể kéo được
vào từ hoặc đẩy ra bên ngoài hệ thống phân cấp phụ.

Ví dụ: giả sử các nhóm C0 và C1 đã được ủy quyền cho
người dùng U0 đã tạo C00, C01 trong C0 và C10 trong C1 như sau và
tất cả các tiến trình thuộc C0 và C1 đều thuộc về U0::

~~~~~~~~~~~~~~ - C0 - C00
  ~ nhóm ~ \ C01
  ~ thứ bậc ~
  ~~~~~~~~~~~~~~ - C1 - C10

Giả sử U0 muốn viết PID của một quy trình
hiện ở C10 thành "C00/cgroup.procs".  U0 có quyền ghi vào
tập tin; tuy nhiên, tổ tiên chung của nhóm nguồn C10 và
nhóm đích C00 nằm trên các điểm được ủy quyền và U0 sẽ
không có quyền ghi vào các tệp "cgroup.procs" của nó và do đó việc ghi
sẽ bị từ chối với -EACCES.

Đối với việc ủy quyền cho các không gian tên, việc ngăn chặn đạt được bằng cách yêu cầu
rằng cả nhóm nguồn và nhóm đích đều có thể truy cập được từ
không gian tên của quá trình đang cố gắng di chuyển.  Nếu một trong hai
không thể truy cập được, quá trình di chuyển bị từ chối bằng -ENOENT.


Hướng dẫn
----------

Tổ chức một lần và kiểm soát
~~~~~~~~~~~~~~~~~~~~~~~~~

Di chuyển một tiến trình giữa các nhóm là một hoạt động tương đối tốn kém
và các tài nguyên trạng thái như bộ nhớ không được di chuyển cùng với
quá trình.  Đây là một quyết định thiết kế rõ ràng vì thường tồn tại
sự đánh đổi cố hữu giữa di cư và các con đường nóng khác nhau về mặt
về chi phí đồng bộ hóa.

Như vậy, việc di chuyển các tiến trình giữa các nhóm thường xuyên như một phương tiện để
không khuyến khích áp dụng các hạn chế tài nguyên khác nhau.  Khối lượng công việc
nên được gán vào một nhóm theo logic và
cấu trúc tài nguyên một lần khi khởi động.  Điều chỉnh động đối với tài nguyên
phân phối có thể được thực hiện bằng cách thay đổi cấu hình bộ điều khiển thông qua
các tập tin giao diện.


Tránh xung đột tên
~~~~~~~~~~~~~~~~~~~~~

Các tập tin giao diện cho một cgroup và các nhóm con của nó chiếm cùng một vị trí
thư mục và có thể tạo các nhóm con xung đột
với các tập tin giao diện.

Tất cả các tệp giao diện lõi của cgroup đều có tiền tố là "cgroup." và mỗi
các tập tin giao diện của bộ điều khiển có tiền tố là tên bộ điều khiển và
một dấu chấm.  Tên của bộ điều khiển bao gồm các bảng chữ cái viết thường và
'_' nhưng không bao giờ bắt đầu bằng '_' nên nó có thể được sử dụng làm tiền tố
nhân vật tránh va chạm.  Ngoài ra, tên tệp giao diện sẽ không
bắt đầu hoặc kết thúc bằng các thuật ngữ thường được sử dụng trong việc phân loại khối lượng công việc
chẳng hạn như công việc, dịch vụ, lát cắt, đơn vị hoặc khối lượng công việc.

cgroup không làm bất cứ điều gì để ngăn chặn xung đột tên và đó là
trách nhiệm của người dùng là tránh chúng.


Mô hình phân phối tài nguyên
============================

bộ điều khiển cgroup thực hiện một số kế hoạch phân phối tài nguyên
tùy thuộc vào loại tài nguyên và trường hợp sử dụng dự kiến.  Phần này
mô tả các kế hoạch chính đang được sử dụng cùng với các hành vi dự kiến của chúng.


Trọng lượng
-------

Tài nguyên của cha mẹ được phân phối bằng cách cộng trọng số của tất cả
những đứa trẻ tích cực và cho mỗi phân số phù hợp với tỷ lệ của nó
trọng lượng so với tổng.  Là trẻ em duy nhất có thể sử dụng
tài nguyên tại thời điểm tham gia phân phối, đây là
bảo tồn công việc.  Do tính chất động nên mô hình này thường
được sử dụng cho các tài nguyên không trạng thái.

Tất cả trọng số đều nằm trong phạm vi [1, 10000] với giá trị mặc định là 100. Điều này
cho phép độ lệch nhân đối xứng theo cả hai hướng ở mức tốt
đủ độ chi tiết trong khi vẫn ở trong phạm vi trực quan.

Miễn là trọng lượng nằm trong phạm vi cho phép thì tất cả các kết hợp cấu hình đều phù hợp
hợp lệ và không có lý do gì để từ chối thay đổi cấu hình hoặc
quá trình di chuyển.

"cpu.weight" phân bổ tỷ lệ chu kỳ CPU cho trẻ năng động
và là một ví dụ về loại này.


.. _cgroupv2-limits-distributor:

Giới hạn
------

Một đứa trẻ chỉ có thể sử dụng lượng tài nguyên được định cấu hình.
Các giới hạn có thể được cam kết quá mức - tổng các giới hạn của trẻ em có thể
vượt quá số lượng tài nguyên có sẵn cho cha mẹ.

Các giới hạn nằm trong phạm vi [0, max] và mặc định là "max", tức là không.

Vì các giới hạn có thể được cam kết quá mức nên tất cả các kết hợp cấu hình đều
hợp lệ và không có lý do gì để từ chối thay đổi cấu hình hoặc
quá trình di chuyển.

"io.max" giới hạn BPS và/hoặc IOPS tối đa mà một nhóm có thể tiêu thụ
trên thiết bị IO và là một ví dụ về loại này.

.. _cgroupv2-protections-distributor:

Bảo vệ
-----------

Một nhóm được bảo vệ theo lượng tài nguyên được định cấu hình
miễn là tập quán của tất cả tổ tiên của nó đều tuân theo
mức độ được bảo vệ.  Các biện pháp bảo vệ có thể là sự đảm bảo cứng rắn hoặc nỗ lực hết mình
ranh giới mềm.  Các biện pháp bảo vệ cũng có thể được cam kết quá mức trong trường hợp đó
chỉ tối đa số tiền có sẵn cho phụ huynh mới được bảo vệ trong số
trẻ em.

Mức bảo vệ nằm trong phạm vi [0, max] và mặc định là 0, tức là
không.

Vì các biện pháp bảo vệ có thể được cam kết quá mức nên tất cả các kết hợp cấu hình
là hợp lệ và không có lý do gì để từ chối các thay đổi cấu hình hoặc
quá trình di chuyển.

"memory.low" thực hiện bảo vệ bộ nhớ với nỗ lực tốt nhất và là một
ví dụ về loại này.


Phân bổ
-----------

Một nhóm được phân bổ độc quyền một lượng hữu hạn nhất định
tài nguyên.  Phân bổ không thể được cam kết quá mức - tổng của
sự phân bổ của trẻ em không thể vượt quá số lượng nguồn lực
có sẵn cho cha mẹ.

Phân bổ nằm trong phạm vi [0, max] và mặc định là 0, không có
tài nguyên.

Vì việc phân bổ không thể được cam kết quá mức nên một số cấu hình
sự kết hợp không hợp lệ và nên bị từ chối.  Ngoài ra, nếu
tài nguyên là bắt buộc để thực thi các tiến trình, di chuyển tiến trình
có thể bị từ chối.


Tệp giao diện
===============

Định dạng
------

Tất cả các tệp giao diện phải ở một trong các định dạng sau bất cứ khi nào
có thể::

Các giá trị được phân tách bằng dòng mới
  (khi chỉ có thể viết một giá trị cùng một lúc)

VAL0\n
	VAL1\n
	...

  Space separated values
  (when read-only or multiple values can be written at once)

VAL0 VAL1 ...\n

Phím phẳng

KEY0 VAL0\n
	KEY1 VAL1\n
	...

  Nested keyed

KEY0 SUB_KEY0=VAL00 SUB_KEY1=VAL01...
	KEY1 SUB_KEY0=VAL10 SUB_KEY1=VAL11...
	...

Đối với một tập tin có thể ghi, định dạng để ghi thường phải phù hợp
đọc sách; tuy nhiên, bộ điều khiển có thể cho phép bỏ qua các trường sau hoặc
triển khai các phím tắt bị hạn chế cho hầu hết các trường hợp sử dụng phổ biến.

Đối với cả tệp có khóa phẳng và lồng nhau, chỉ các giá trị cho một khóa duy nhất
có thể được viết tại một thời điểm  Đối với các tệp có khóa lồng nhau, các cặp khóa phụ
có thể được chỉ định theo bất kỳ thứ tự nào và không phải tất cả các cặp đều phải được chỉ định.


Công ước
-----------

- Cài đặt cho một tính năng phải được chứa trong một tệp duy nhất.

- Nhóm gốc nên được miễn kiểm soát tài nguyên và do đó
  không nên có tập tin giao diện kiểm soát tài nguyên.

- Đơn vị thời gian mặc định là micro giây.  Nếu có một đơn vị khác
  được sử dụng thì phải có hậu tố đơn vị rõ ràng.

- Phần trên mỗi số lượng phải sử dụng phần trăm thập phân với ít nhất
  phần phân số có hai chữ số - ví dụ: 13 giờ 40.

- Nếu bộ điều khiển thực hiện phân phối tài nguyên dựa trên trọng lượng,
  tệp giao diện phải được đặt tên là "weight" và có phạm vi [1,
  10000] với 100 làm mặc định.  Các giá trị được chọn để cho phép
  độ lệch đủ và đối xứng theo cả hai hướng trong khi vẫn giữ nó
  trực quan (mặc định là 100%).

- Nếu bộ điều khiển thực hiện đảm bảo tài nguyên tuyệt đối và/hoặc
  giới hạn, các tệp giao diện phải được đặt tên là "min" và "max"
  tương ứng.  Nếu bộ điều khiển triển khai tài nguyên nỗ lực tốt nhất
  đảm bảo và/hoặc giới hạn, các tệp giao diện phải được đặt tên là "thấp"
  và "cao" tương ứng.

Trong bốn tệp điều khiển ở trên, mã thông báo đặc biệt "max" phải là
  được sử dụng để đại diện cho vô cực hướng lên cho cả việc đọc và viết.

- Nếu cài đặt có giá trị mặc định có thể định cấu hình và có khóa cụ thể
  ghi đè, mục nhập mặc định phải được khóa bằng "mặc định" và
  xuất hiện dưới dạng mục nhập đầu tiên trong tệp.

Giá trị mặc định có thể được cập nhật bằng cách viết "default $VAL" hoặc
  "$VAL".

Khi viết để cập nhật một ghi đè cụ thể, "mặc định" có thể được sử dụng làm
  giá trị để biểu thị việc loại bỏ phần ghi đè.  Ghi đè mục nhập
  với "mặc định" là giá trị không được xuất hiện khi đọc.

Ví dụ: cài đặt được khóa theo số thiết bị chính:thứ yếu
  với các giá trị số nguyên có thể trông giống như sau::

# cat cgroup-example-interface-file
    mặc định 150
    8:0 300

Giá trị mặc định có thể được cập nhật bởi::

# echo 125 > cgroup-example-interface-file

hoặc::

# echo "mặc định 125" > cgroup-example-interface-file

Ghi đè có thể được đặt bởi::

# echo "8:16 170" > cgroup-example-interface-file

và bị xóa bởi::

# echo "mặc định 8: 0"> cgroup-example-interface-file
    # cat cgroup-example-interface-file
    mặc định 125
    8:16 170

- Đối với các sự kiện có tần suất không cao, một tệp giao diện
  "sự kiện" sẽ được tạo để liệt kê các cặp giá trị khóa sự kiện.
  Bất cứ khi nào một sự kiện đáng chú ý xảy ra, sự kiện được sửa đổi tệp sẽ được
  được tạo trên tập tin.


Tệp giao diện cốt lõi
--------------------

Tất cả các tệp lõi của cgroup đều có tiền tố là "cgroup."

cgroup.type
	Một tệp giá trị đọc-ghi tồn tại trên máy không phải root
	cgroups.

Khi đọc, nó cho biết loại hiện tại của nhóm, loại này
	có thể là một trong các giá trị sau.

- "domain" : Nhóm miền hợp lệ thông thường.

- "domain threaded" : Một nhóm miền có luồng được
          đóng vai trò là gốc của cây con có luồng.

- "domain không hợp lệ" : Một nhóm đang ở trạng thái không hợp lệ.
	  Nó không thể được điền hoặc kích hoạt bộ điều khiển.  Nó có thể
	  được phép trở thành một nhóm luồng.

- "threaded" : Một nhóm luồng là thành viên của một
          cây con luồng.

Một cgroup có thể được biến thành một cgroup theo luồng bằng cách viết
	"xâu chuỗi" vào tập tin này.

cgroup.procs
	Tệp giá trị được phân tách bằng dòng mới đọc-ghi tồn tại trên
	tất cả các nhóm.

Khi đọc, nó liệt kê các PID của tất cả các tiến trình thuộc về
	cgroup một trên mỗi dòng.  Các PID không được sắp xếp thứ tự và
	cùng một PID có thể xuất hiện nhiều lần nếu quá trình được di chuyển
	sang nhóm khác rồi quay lại hoặc PID được tái chế trong khi
	đọc.

PID có thể được viết để di chuyển quá trình liên quan đến
	PID vào nhóm.  Người viết phải phù hợp với tất cả các
	điều kiện sau đây.

- Nó phải có quyền ghi vào tệp "cgroup.procs".

- Nó phải có quyền ghi vào tệp "cgroup.procs" của
	  tổ tiên chung của nhóm nguồn và nhóm đích.

Khi ủy quyền một hệ thống phân cấp phụ, hãy ghi quyền truy cập vào tệp này
	nên được cấp cùng với thư mục chứa.

Trong một nhóm theo chuỗi, việc đọc tệp này không thành công với EOPNOTSUPP
	vì tất cả các tiến trình đều thuộc về chủ đề gốc.  Viết là
	được hỗ trợ và di chuyển mọi luồng của quy trình sang cgroup.

cgroup.threads
	Tệp giá trị được phân tách bằng dòng mới đọc-ghi tồn tại trên
	tất cả các nhóm.

Khi đọc, nó liệt kê TID của tất cả các luồng thuộc về
	cgroup một trên mỗi dòng.  Các TID không được sắp xếp theo thứ tự và
	cùng một TID có thể xuất hiện nhiều lần nếu chuỗi được chuyển đến
	một nhóm khác rồi quay lại hoặc TID được tái chế trong khi
	đọc.

TID có thể được viết để di chuyển luồng được liên kết với
	TID vào nhóm.  Người viết phải phù hợp với tất cả các
	điều kiện sau đây.

- Nó phải có quyền ghi vào file "cgroup.threads".

- Nhóm mà chủ đề hiện tại phải nằm trong
          cùng miền tài nguyên với nhóm đích.

- Nó phải có quyền ghi vào tệp "cgroup.procs" của
	  tổ tiên chung của nhóm nguồn và nhóm đích.

Khi ủy quyền một hệ thống phân cấp phụ, hãy ghi quyền truy cập vào tệp này
	nên được cấp cùng với thư mục chứa.

cgroup.controllers
	Tệp giá trị được phân tách bằng dấu cách chỉ đọc tồn tại trên tất cả
	cgroups.

Nó hiển thị danh sách được phân tách bằng dấu cách của tất cả các bộ điều khiển có sẵn cho
	nhóm.  Bộ điều khiển không được đặt hàng.

cgroup.subtree_control
	Một tệp giá trị được phân tách bằng dấu cách đọc-ghi tồn tại trên tất cả
	cgroups.  Bắt đầu trống rỗng.

Khi đọc, nó hiển thị danh sách các bộ điều khiển được phân tách bằng dấu cách
	được kích hoạt để kiểm soát việc phân phối tài nguyên từ
	cgroup cho các con của nó.

Danh sách bộ điều khiển được phân tách bằng dấu cách có tiền tố '+' hoặc '-'
	có thể được viết để kích hoạt hoặc vô hiệu hóa bộ điều khiển.  Một bộ điều khiển
	tên có tiền tố '+' kích hoạt bộ điều khiển và '-'
	vô hiệu hóa.  Nếu một bộ điều khiển xuất hiện nhiều lần trong danh sách,
	cái cuối cùng có hiệu quả.  Khi bật và tắt nhiều lần
	các hoạt động được chỉ định, tất cả đều thành công hoặc tất cả đều thất bại.

cgroup.events
	Một tệp khóa phẳng chỉ đọc tồn tại trên các nhóm không phải gốc.
	Các mục sau đây được xác định.  Trừ khi được chỉ định
	mặt khác, sự thay đổi giá trị trong tệp này sẽ tạo ra một tệp
	sự kiện sửa đổi.

dân cư
		1 nếu nhóm hoặc con cháu của nó chứa bất kỳ
		quá trình; mặt khác, 0.
	  đông lạnh
		1 nếu nhóm bị đóng băng; mặt khác, 0.

cgroup.max.descendants
	Một tập tin giá trị đọc-ghi.  Mặc định là "tối đa".

Số lượng nhóm gốc tối đa được phép.
	Nếu số lượng con cháu thực tế bằng hoặc lớn hơn,
	nỗ lực tạo một nhóm mới trong hệ thống phân cấp sẽ thất bại.

cgroup.max.deep
	Một tập tin giá trị đọc-ghi.  Mặc định là "tối đa".

Độ sâu hạ xuống tối đa được phép bên dưới nhóm hiện tại.
	Nếu độ sâu hạ xuống thực tế bằng hoặc lớn hơn,
	nỗ lực tạo một nhóm con mới sẽ thất bại.

cgroup.stat
	Một tệp khóa phẳng chỉ đọc có các mục sau:

nr_hậu duệ
		Tổng số nhóm con cháu có thể nhìn thấy được.

nr_dying_hậu duệ
		Tổng số nhóm con cháu bị chết. Một nhóm trở thành
		chết sau khi bị người dùng xóa. Cgroup sẽ vẫn còn
		ở trạng thái hấp hối trong một khoảng thời gian không xác định (điều này có thể phụ thuộc vào
		khi tải hệ thống) trước khi bị phá hủy hoàn toàn.

Một tiến trình không thể vào một nhóm sắp chết trong bất kỳ trường hợp nào,
		một nhóm đang chết không thể hồi sinh được.

Một nhóm sắp chết có thể tiêu tốn tài nguyên hệ thống không quá
		giới hạn đang hoạt động tại thời điểm xóa cgroup.

nr_subsys_<cgroup_subsys>
		Tổng số hệ thống con nhóm trực tiếp (ví dụ: bộ nhớ
		cgroup) tại và bên dưới cgroup hiện tại.

nr_dying_subsys_<cgroup_subsys>
		Tổng số hệ thống con cgroup sắp chết (ví dụ: bộ nhớ
		cgroup) tại và bên dưới cgroup hiện tại.

cgroup.stat.local
	Một tệp khóa phẳng chỉ đọc tồn tại trong các nhóm không phải gốc.
	Mục sau đây được xác định:

đông lạnh_usec
		Thời gian tích lũy mà nhóm này đã trải qua từ khi đóng băng đến
		tan băng, bất kể bởi nhóm tự hay nhóm tổ tiên.
		Lưu ý: (không) đạt đến trạng thái "đóng băng" không được tính ở đây.

Sử dụng biểu diễn ASCII sau đây của tủ đông của nhóm
		trạng thái, ::

1 _____
			đông lạnh 0 __/ \__
			          ab cd

khoảng thời gian được đo là khoảng thời gian giữa a và c.

cgroup.freeze
	Một tệp giá trị đọc-ghi tồn tại trên các nhóm không phải gốc.
	Giá trị được phép là "0" và "1". Mặc định là "0".

Việc ghi "1" vào tập tin sẽ gây ra tình trạng đóng băng cgroup và tất cả
	các nhóm con cháu. Điều này có nghĩa là tất cả các tiến trình thuộc về sẽ
	bị dừng và sẽ không chạy cho đến khi cgroup được xác định rõ ràng
	rã đông. Việc đóng băng nhóm có thể mất một thời gian; khi hành động này
	hoàn thành, giá trị "đóng băng" trong file control cgroup.events
	sẽ được cập nhật thành "1" và thông báo tương ứng sẽ là
	ban hành.

Một nhóm có thể bị đóng băng bằng cài đặt của chính nhóm đó hoặc bằng cài đặt
	của bất kỳ nhóm tổ tiên nào. Nếu bất kỳ nhóm tổ tiên nào bị đóng băng,
	cgroup sẽ vẫn bị đóng băng.

Các tiến trình trong nhóm bị đóng băng có thể bị tắt bởi một tín hiệu nghiêm trọng.
	Họ cũng có thể vào và rời khỏi một nhóm bị đóng băng: bằng một lệnh rõ ràng
	di chuyển bởi người dùng hoặc nếu đóng băng cuộc đua cgroup bằng fork().
	Nếu một tiến trình được chuyển tới một nhóm đông lạnh, nó sẽ dừng lại. Nếu một quá trình được
	được chuyển ra khỏi một nhóm bị đóng băng, nó sẽ hoạt động.

Trạng thái đóng băng của một nhóm không ảnh hưởng đến bất kỳ hoạt động nào của cây cgroup:
	có thể xóa một nhóm bị đóng băng (và trống), cũng như
	tạo các nhóm con mới.

cgroup.kill
	Một tệp giá trị duy nhất chỉ ghi tồn tại trong các nhóm không phải gốc.
	Giá trị duy nhất được phép là "1".

Việc ghi "1" vào tập tin sẽ làm cho cgroup và tất cả các nhóm con cháu bị
	bị giết. Điều này có nghĩa là tất cả các tiến trình nằm trong nhóm bị ảnh hưởng
	cây sẽ bị giết thông qua SIGKILL.

Việc tiêu diệt cây cgroup sẽ xử lý các nhánh đồng thời một cách thích hợp và
	được bảo vệ chống lại sự di cư.

Trong một nhóm theo luồng, việc ghi tệp này không thành công với EOPNOTSUPP vì
	tiêu diệt các nhóm là một hoạt động được định hướng theo quy trình, tức là nó ảnh hưởng đến
	toàn bộ nhóm chủ đề.

cgroup.áp lực
	Tệp giá trị đơn đọc-ghi cho phép các giá trị là "0" và "1".
	Mặc định là "1".

Việc ghi "0" vào tệp sẽ vô hiệu hóa tính toán cgroup PSI.
	Việc ghi "1" vào tệp sẽ kích hoạt lại tính năng kế toán cgroup PSI.

Thuộc tính điều khiển này không phân cấp, vì vậy hãy tắt hoặc bật PSI
	kế toán trong một nhóm không ảnh hưởng đến kế toán PSI ở con cháu
	và không cần hỗ trợ vượt qua tổ tiên từ gốc.

Lý do thuộc tính điều khiển này tồn tại là do các tài khoản PSI bị treo
	mỗi nhóm riêng biệt và tổng hợp nó ở mỗi cấp độ của hệ thống phân cấp.
	Điều này có thể gây ra chi phí không đáng kể đối với một số khối lượng công việc khi
	mức độ sâu của hệ thống phân cấp, trong trường hợp đó thuộc tính điều khiển này có thể
	được sử dụng để vô hiệu hóa tính toán PSI trong các nhóm không có lá.

irq.áp lực
	Một tập tin có khóa lồng nhau đọc-ghi.

Hiển thị thông tin ngừng áp suất cho IRQ/SOFTIRQ. Xem
	ZZ0000ZZ để biết chi tiết.

Bộ điều khiển
===========

.. _cgroup-v2-cpu:

CPU
---

Bộ điều khiển "cpu" điều chỉnh việc phân phối chu trình CPU.  Cái này
bộ điều khiển thực hiện các mô hình giới hạn trọng lượng và băng thông tuyệt đối cho
chính sách lập lịch thông thường và mô hình phân bổ băng thông tuyệt đối cho
chính sách lập kế hoạch thời gian thực.

Trong tất cả các mô hình trên, phân bố chu kỳ chỉ được xác định theo thời gian
base và nó không tính đến tần suất thực hiện các tác vụ.
Hỗ trợ kẹp sử dụng (tùy chọn) cho phép gợi ý lịch trình
thống đốc cpufreq về tần số mong muốn tối thiểu phải luôn luôn là
được cung cấp bởi CPU, cũng như tần số mong muốn tối đa, không nên
bị vượt quá bởi CPU.

WARNING: Bộ điều khiển cpu cgroup2 chưa hỗ trợ kiểm soát (băng thông) của
các quá trình thời gian thực. Đối với hạt nhân được xây dựng bằng tùy chọn CONFIG_RT_GROUP_SCHED
được kích hoạt để lập lịch nhóm cho các quy trình thời gian thực, bộ điều khiển CPU chỉ có thể
được kích hoạt khi tất cả các tiến trình RT nằm trong nhóm gốc. Hãy nhận biết rằng hệ thống
phần mềm quản lý có thể đã đặt các quy trình RT vào các nhóm không phải gốc
trong quá trình khởi động hệ thống và các quá trình này có thể cần phải được chuyển sang
root cgroup trước khi bộ điều khiển cpu có thể được kích hoạt bằng
Hạt nhân kích hoạt CONFIG_RT_GROUP_SCHED.

Khi CONFIG_RT_GROUP_SCHED bị tắt, giới hạn này không được áp dụng và một số
các tệp giao diện ảnh hưởng đến các quy trình thời gian thực hoặc giải thích cho chúng. Xem
phần sau để biết chi tiết. Chỉ có bộ điều khiển cpu bị ảnh hưởng bởi
CONFIG_RT_GROUP_SCHED. Các bộ điều khiển khác có thể được sử dụng để kiểm soát tài nguyên của
quy trình thời gian thực bất kể CONFIG_RT_GROUP_SCHED.


Tệp giao diện CPU
~~~~~~~~~~~~~~~~~~~

Sự tương tác của một tiến trình với bộ điều khiển CPU phụ thuộc vào việc lập kế hoạch của nó
chính sách và bộ lập lịch cơ bản. Từ quan điểm của bộ điều khiển cpu,
các quá trình có thể được phân loại như sau:

* Các quy trình theo lịch trình công bằng
* Xử lý theo bộ lập lịch BPF với lệnh gọi lại ZZ0000ZZ
* Mọi thứ khác: ZZ0001ZZ và xử lý theo bộ lập lịch BPF
  không có lệnh gọi lại ZZ0002ZZ

Để biết chi tiết về thời điểm một quy trình nằm trong bộ lập lịch cấp công bằng hoặc bộ lập lịch BPF,
hãy kiểm tra ZZ0000ZZ.

Đối với mỗi tệp giao diện sau, các danh mục trên
sẽ được đề cập đến. Tất cả khoảng thời gian được tính bằng micro giây.

cpu.stat
	Một tập tin khóa phẳng chỉ đọc.
	Tệp này tồn tại cho dù bộ điều khiển có được bật hay không.

Nó luôn báo cáo ba số liệu thống kê sau đây, chiếm tất cả các
	các tiến trình trong nhóm:

- cách sử dụng_usec
	- user_usec
	- hệ thống_usec

và năm điều sau đây khi bộ điều khiển được bật, chiếm
	chỉ các quy trình theo bộ lập lịch lớp công bằng:

- nr_thời gian
	- nr_throttled
	- điều tiết_usec
	- nr_burst
	- nổ_usec

cpu.trọng lượng
	Một tệp giá trị đọc-ghi tồn tại trên máy không phải root
	cgroups.  Mặc định là "100".

Đối với các nhóm không rảnh (cpu.idle = 0), trọng số nằm trong
	phạm vi [1, 10000].

Nếu nhóm đã được cấu hình là SCHED_IDLE (cpu.idle = 1),
	thì trọng số sẽ hiển thị là 0.

Tệp này chỉ ảnh hưởng đến các quy trình theo bộ lập lịch lớp công bằng và BPF
	bộ lập lịch với lệnh gọi lại ZZ0000ZZ tùy thuộc vào những gì
	gọi lại thực sự có.

cpu.weight.nice
	Một tệp giá trị đọc-ghi tồn tại trên máy không phải root
	cgroups.  Mặc định là "0".

Giá trị Nice nằm trong khoảng [-20, 19].

Tệp giao diện này là một giao diện thay thế cho
	"cpu.weight" và cho phép đọc và cài đặt trọng lượng bằng cách sử dụng
	cùng các giá trị được sử dụng bởi nice(2).  Bởi vì phạm vi nhỏ hơn và
	độ chi tiết thô hơn đối với các giá trị Nice, giá trị đọc là
	xấp xỉ gần nhất của trọng lượng hiện tại.

Tệp này chỉ ảnh hưởng đến các quy trình theo bộ lập lịch lớp công bằng và BPF
	bộ lập lịch với lệnh gọi lại ZZ0000ZZ tùy thuộc vào những gì
	gọi lại thực sự có.

cpu.max
	Một tệp có hai giá trị đọc-ghi tồn tại trên các nhóm không phải gốc.
	Mặc định là "tối đa 100000".

Giới hạn băng thông tối đa.  Nó có định dạng sau::

$MAX $PERIOD

điều này cho biết rằng nhóm có thể tiêu tới $MAX trong mỗi
	Thời lượng $PERIOD.  "max" cho $MAX biểu thị không có giới hạn.  Nếu chỉ
	một số được viết, $MAX được cập nhật.

Tệp này chỉ ảnh hưởng đến các quy trình theo bộ lập lịch lớp công bằng.

cpu.max.burst
	Một tệp giá trị đọc-ghi tồn tại trên máy không phải root
	cgroups.  Mặc định là "0".

Sự bùng nổ trong phạm vi [0, $MAX].

Tệp này chỉ ảnh hưởng đến các quy trình theo bộ lập lịch lớp công bằng.

cpu.áp lực
	Một tập tin có khóa lồng nhau đọc-ghi.

Hiển thị thông tin ngừng áp suất cho CPU. Xem
	ZZ0000ZZ để biết chi tiết.

Tệp này chiếm tất cả các quy trình trong cgroup.

cpu.uclamp.min
	Một tệp giá trị đọc-ghi tồn tại trên các nhóm không phải gốc.
	Giá trị mặc định là "0", tức là không tăng mức sử dụng.

Mức sử dụng tối thiểu được yêu cầu (bảo vệ) dưới dạng phần trăm
	số hữu tỉ, ví dụ: 12,34 cho 12,34%.

Giao diện này cho phép đọc và thiết lập kẹp sử dụng tối thiểu
	các giá trị tương tự như sched_setattr(2). Việc sử dụng tối thiểu này
	giá trị được sử dụng để kẹp kẹp sử dụng tối thiểu cụ thể của nhiệm vụ,
	bao gồm cả những quy trình thời gian thực.

Mức sử dụng (bảo vệ) tối thiểu được yêu cầu luôn bị giới hạn bởi
	giá trị hiện tại cho mức sử dụng tối đa (giới hạn), tức là
	ZZ0000ZZ.

Tệp này ảnh hưởng đến tất cả các quy trình trong cgroup.

cpu.uclamp.max
	Một tệp giá trị đọc-ghi tồn tại trên các nhóm không phải gốc.
	Mặc định là "tối đa". tức là không có giới hạn sử dụng

Mức sử dụng (giới hạn) tối đa được yêu cầu dưới dạng tỷ lệ phần trăm hợp lý
	số, ví dụ 98,76 cho 98,76%.

Giao diện này cho phép đọc và thiết lập kẹp sử dụng tối đa
	các giá trị tương tự như sched_setattr(2). Việc sử dụng tối đa này
	giá trị được sử dụng để kẹp kẹp sử dụng tối đa cụ thể của nhiệm vụ,
	bao gồm cả những quy trình thời gian thực.

Tệp này ảnh hưởng đến tất cả các quy trình trong cgroup.

cpu.idle
	Một tệp giá trị đọc-ghi tồn tại trên các nhóm không phải gốc.
	Mặc định là 0.

Đây là tương tự cgroup của chính sách lập kế hoạch SCHED_IDLE cho mỗi nhiệm vụ.
	Đặt giá trị này thành 1 sẽ làm cho chính sách lập lịch của
	nhóm SCHED_IDLE. Các chủ đề bên trong cgroup sẽ giữ lại
	mức độ ưu tiên tương đối của riêng mình, nhưng bản thân nhóm sẽ được coi là
	mức độ ưu tiên rất thấp so với các đồng nghiệp của nó.

Tệp này chỉ ảnh hưởng đến các quy trình theo bộ lập lịch lớp công bằng.

Ký ức
------

Bộ điều khiển "bộ nhớ" điều chỉnh việc phân phối bộ nhớ.  Trí nhớ là
trạng thái và thực hiện cả mô hình giới hạn và bảo vệ.  Do
đan xen giữa việc sử dụng bộ nhớ và áp lực lấy lại và
tính chất trạng thái của bộ nhớ, mô hình phân phối tương đối
phức tạp.

Mặc dù không hoàn toàn kín nước, tất cả các cách sử dụng bộ nhớ chính đều có
cgroup được theo dõi để có thể tính toán tổng mức tiêu thụ bộ nhớ
được hạch toán và kiểm soát ở mức độ hợp lý.  Hiện nay,
các loại sử dụng bộ nhớ sau đây được theo dõi.

- Bộ nhớ người dùng - bộ đệm trang và bộ nhớ ẩn danh.

- Cấu trúc dữ liệu hạt nhân như dentries và inodes.

- Bộ đệm ổ cắm TCP.

Danh sách trên có thể mở rộng trong tương lai để có phạm vi phủ sóng tốt hơn.


Tập tin giao diện bộ nhớ
~~~~~~~~~~~~~~~~~~~~~~

Tất cả số lượng bộ nhớ đều tính bằng byte.  Nếu một giá trị không được liên kết với
PAGE_SIZE được ghi, giá trị có thể được làm tròn đến giá trị gần nhất
PAGE_SIZE bội số khi đọc lại.

bộ nhớ.current
	Tệp giá trị duy nhất chỉ đọc tồn tại trên máy không phải root
	cgroups.

Tổng dung lượng bộ nhớ hiện đang được cgroup sử dụng
	và con cháu của nó.

bộ nhớ.min
	Một tệp giá trị đọc-ghi tồn tại trên máy không phải root
	cgroups.  Mặc định là "0".

Bảo vệ bộ nhớ cứng.  Nếu mức sử dụng bộ nhớ của một cgroup
	nằm trong ranh giới tối thiểu hiệu dụng của nó, bộ nhớ của nhóm
	sẽ không được thu hồi dưới bất kỳ điều kiện nào. Nếu không có
	bộ nhớ có thể thu hồi không được bảo vệ có sẵn, sát thủ OOM
	được gọi. Trên ranh giới tối thiểu hiệu quả (hoặc
	ranh giới thấp hiệu quả nếu nó cao hơn), các trang sẽ được lấy lại
	tỷ lệ thuận với lượng dư thừa, giảm áp lực thu hồi cho
	dư thừa nhỏ hơn.

Ranh giới tối thiểu hiệu quả bị giới hạn bởi các giá trị bộ nhớ.min của
	nhóm tổ tiên. Nếu có quá mức cam kết về bộ nhớ.min
	(các nhóm con hoặc các nhóm đang yêu cầu bộ nhớ được bảo vệ nhiều hơn
	hơn mức cha mẹ cho phép), thì mỗi nhóm con sẽ nhận được
	phần bảo vệ của cha mẹ tỷ lệ thuận với nó
	mức sử dụng bộ nhớ thực tế bên dưới Memory.min.

Đặt nhiều bộ nhớ hơn mức thường có sẵn theo mục này
	việc bảo vệ không được khuyến khích và có thể dẫn đến OOM liên tục.

bộ nhớ.low
	Một tệp giá trị đọc-ghi tồn tại trên máy không phải root
	cgroups.  Mặc định là "0".

Bảo vệ bộ nhớ nỗ lực tốt nhất.  Nếu mức sử dụng bộ nhớ của một
	cgroup nằm trong ranh giới thấp hiệu quả của nó, cgroup
	bộ nhớ sẽ không được lấy lại trừ khi không có bộ nhớ nào có thể lấy lại được
	bộ nhớ có sẵn trong các nhóm không được bảo vệ.
	Trên ranh giới thấp hiệu quả (hoặc 
	ranh giới tối thiểu hiệu quả nếu nó cao hơn), các trang sẽ được lấy lại
	tỷ lệ thuận với lượng dư thừa, giảm áp lực thu hồi cho
	dư thừa nhỏ hơn.

Ranh giới thấp hiệu quả bị giới hạn bởi các giá trị bộ nhớ.thấp của
	nhóm tổ tiên. Nếu có bộ nhớ. cam kết quá thấp
	(các nhóm con hoặc các nhóm đang yêu cầu bộ nhớ được bảo vệ nhiều hơn
	hơn mức cha mẹ cho phép), thì mỗi nhóm con sẽ nhận được
	phần bảo vệ của cha mẹ tỷ lệ thuận với nó
	mức sử dụng bộ nhớ thực tế dưới mức Memory.low.

Đặt nhiều bộ nhớ hơn mức thường có sẵn theo mục này
	việc bảo vệ không được khuyến khích.

bộ nhớ.cao
	Một tệp giá trị đọc-ghi tồn tại trên máy không phải root
	cgroups.  Mặc định là "tối đa".

Giới hạn điều tiết sử dụng bộ nhớ.  Nếu việc sử dụng của một nhóm không thành công
	trên ranh giới cao, các quá trình của nhóm cgroup được
	bị điều tiết và đặt dưới áp lực thu hồi nặng nề.

Vượt quá giới hạn cao không bao giờ kích hoạt sát thủ OOM và
	trong điều kiện khắc nghiệt, giới hạn có thể bị vi phạm. cao
	giới hạn nên được sử dụng trong các tình huống trong đó một quy trình bên ngoài
	giám sát nhóm giới hạn để giảm bớt việc thu hồi nặng nề
	áp lực.

Nếu bộ nhớ.high được mở bằng O_NONBLOCK thì đồng bộ
	việc thu hồi được bỏ qua. Điều này rất hữu ích cho các quy trình quản trị
	cần phải tự động điều chỉnh giới hạn bộ nhớ của công việc mà không cần
	sử dụng tài nguyên CPU của riêng họ để cải tạo bộ nhớ. các
	công việc sẽ kích hoạt việc thu hồi và/hoặc bị điều chỉnh trên
	yêu cầu tính phí tiếp theo.

Xin lưu ý rằng với O_NONBLOCK, có khả năng
	Nhóm bộ nhớ đích có thể mất một khoảng thời gian không xác định để
	giảm mức sử dụng dưới giới hạn do yêu cầu tính phí bị trì hoãn hoặc
	bận đánh vào bộ nhớ của nó để làm chậm quá trình lấy lại.

bộ nhớ.max
	Một tệp giá trị đọc-ghi tồn tại trên máy không phải root
	cgroups.  Mặc định là "tối đa".

Giới hạn cứng sử dụng bộ nhớ.  Đây là cơ chế chính để hạn chế
	mức sử dụng bộ nhớ của một cgroup.  Nếu mức sử dụng bộ nhớ của một nhóm đạt đến
	giới hạn này và không thể giảm bớt, sát thủ OOM sẽ được triệu tập trong
	nhóm. Trong một số trường hợp nhất định, việc sử dụng có thể đi
	tạm thời vượt quá giới hạn.

Trong cấu hình mặc định, phân bổ 0 đơn hàng thông thường luôn
	thành công trừ khi kẻ giết người OOM chọn nhiệm vụ hiện tại làm nạn nhân.

Một số loại phân bổ không gọi ra sát thủ OOM.
	Người gọi có thể thử lại theo cách khác, quay lại không gian người dùng
	dưới dạng -ENOMEM hoặc âm thầm bỏ qua trong các trường hợp như đọc trước đĩa.

Nếu bộ nhớ.max được mở bằng O_NONBLOCK thì đồng bộ
	reclaim và oom-kill được bỏ qua. Điều này hữu ích cho quản trị viên
	các quy trình cần tự động điều chỉnh giới hạn bộ nhớ của công việc
	mà không cần sử dụng tài nguyên CPU của riêng họ để cải tạo bộ nhớ.
	Công việc sẽ kích hoạt việc thu hồi và/hoặc oom-kill ở lần tiếp theo
	yêu cầu tính phí.

Xin lưu ý rằng với O_NONBLOCK, có khả năng
	Nhóm bộ nhớ đích có thể mất một khoảng thời gian không xác định để
	giảm mức sử dụng dưới giới hạn do yêu cầu tính phí bị trì hoãn hoặc
	bận đánh vào bộ nhớ của nó để làm chậm quá trình lấy lại.

bộ nhớ.reclaim
	Một tệp có khóa lồng nhau chỉ ghi, tồn tại cho tất cả các nhóm.

Đây là một giao diện đơn giản để kích hoạt việc lấy lại bộ nhớ trong
	nhóm mục tiêu.

Ví dụ::

echo "1G"> bộ nhớ.reclaim

Xin lưu ý rằng hạt nhân có thể được lấy lại quá mức hoặc dưới mức
	nhóm mục tiêu. Nếu ít byte được lấy lại hơn
	số tiền đã chỉ định, -EAGAIN được trả về.

Xin lưu ý rằng việc thu hồi chủ động (được kích hoạt bởi điều này
	giao diện) không nhằm mục đích biểu thị áp lực bộ nhớ trên
	nhóm bộ nhớ. Do đó việc cân bằng bộ nhớ socket được kích hoạt bởi
	việc lấy lại bộ nhớ thông thường không được thực hiện trong trường hợp này.
	Điều này có nghĩa là lớp mạng sẽ không thích ứng dựa trên
	đòi lại gây ra bởi bộ nhớ.reclaim.

Các khóa lồng nhau sau đây được xác định.

==============================================
	  swappiness Giá trị Swappiness để đòi lại với
	  ==============================================

Việc chỉ định giá trị swappiness sẽ hướng dẫn kernel thực hiện
	sự đòi lại với giá trị có thể hoán đổi đó. Lưu ý rằng điều này có
	ngữ nghĩa tương tự như vm.swappiness áp dụng cho việc đòi lại memcg với
	tất cả những hạn chế hiện có và khả năng mở rộng trong tương lai.

Phạm vi hợp lệ cho khả năng hoán đổi là [0-200, tối đa], cài đặt
	swappiness=max độc quyền lấy lại bộ nhớ ẩn danh.

bộ nhớ.peak
	Một tệp giá trị đọc-ghi tồn tại trên các nhóm không phải gốc.

Mức sử dụng bộ nhớ tối đa được ghi lại cho nhóm cgroup và các nhóm con của nó kể từ
	hoặc là tạo nhóm hoặc thiết lập lại gần đây nhất cho FD đó.

Việc ghi bất kỳ chuỗi không trống nào vào tệp này sẽ đặt lại nó vào
	mức sử dụng bộ nhớ hiện tại cho các lần đọc tiếp theo thông qua cùng một
	bộ mô tả tập tin.

bộ nhớ.oom.group
	Một tệp giá trị đọc-ghi tồn tại trên máy không phải root
	cgroups.  Giá trị mặc định là "0".

Xác định xem cgroup có nên được coi là
	một khối lượng công việc không thể chia cắt của sát thủ OOM. Nếu được đặt,
	tất cả các nhiệm vụ thuộc về nhóm hoặc con cháu của nó
	(nếu nhóm bộ nhớ không phải là nhóm lá) bị giết
	cùng nhau hoặc không chút nào. Điều này có thể được sử dụng để tránh
	giết một phần để đảm bảo tính toàn vẹn của khối lượng công việc.

Nhiệm vụ có bảo vệ OOM (oom_score_adj được đặt thành -1000)
	được coi như một ngoại lệ và không bao giờ bị giết.

Nếu sát thủ OOM được gọi trong một nhóm, nó sẽ không hoạt động
	để loại bỏ bất kỳ nhiệm vụ nào bên ngoài nhóm này, bất kể
	giá trị Memory.oom.group của các nhóm tổ tiên.

bộ nhớ.events
	Một tệp khóa phẳng chỉ đọc tồn tại trên các nhóm không phải gốc.
	Các mục sau đây được xác định.  Trừ khi được chỉ định
	mặt khác, sự thay đổi giá trị trong tệp này sẽ tạo ra một tệp
	sự kiện sửa đổi.

Lưu ý rằng tất cả các trường trong tệp này đều có thứ bậc và
	sự kiện sửa đổi tập tin có thể được tạo ra do một sự kiện ở phía dưới
	thứ bậc. Đối với các sự kiện địa phương ở cấp độ nhóm, hãy xem
	bộ nhớ.events.local.

thấp
		Số lần cgroup được thu hồi do
		áp lực bộ nhớ cao mặc dù mức sử dụng của nó ở mức thấp
		ranh giới thấp.  Điều này thường chỉ ra rằng mức thấp
		boundary is over-committed.

cao
		Số lần các tiến trình của cgroup là
		điều chỉnh và định tuyến để thực hiện lấy lại bộ nhớ trực tiếp
		vì ranh giới bộ nhớ cao đã bị vượt quá.  Đối với một
		cgroup có mức sử dụng bộ nhớ bị giới hạn ở giới hạn cao
		thay vì áp lực bộ nhớ toàn cầu, sự kiện này
		sự cố được mong đợi.

tối đa
		Số lần sử dụng bộ nhớ của cgroup là
		sắp vượt quá giới hạn tối đa.  Nếu trực tiếp đòi lại
		không thể hạ nó xuống, nhóm sẽ chuyển sang trạng thái OOM.

ôi
		Số lần sử dụng bộ nhớ của cgroup là
		đã đạt đến giới hạn và việc phân bổ sắp thất bại.

Sự kiện này không được nêu ra nếu sát thủ OOM không
		được coi là một lựa chọn, ví dụ: vì thất bại ở bậc cao
		phân bổ hoặc nếu người gọi yêu cầu không thử lại.

oom_kill
		Số lượng tiến trình thuộc nhóm này
		bị giết bởi bất kỳ loại sát thủ OOM nào.

oom_group_kill
                Số lần một nhóm OOM đã xuất hiện.

sock_throttled
                Số lần ổ cắm mạng được liên kết với
                cgroup này đã được điều chỉnh.

bộ nhớ.events.local
	Tương tự như Memory.events nhưng các trường trong tệp là cục bộ
	vào nhóm, tức là không phân cấp. Sự kiện sửa đổi tập tin
	được tạo trên tệp này chỉ phản ánh các sự kiện cục bộ.

bộ nhớ.stat
	Một tệp khóa phẳng chỉ đọc tồn tại trên các nhóm không phải gốc.

Điều này chia dấu chân bộ nhớ của nhóm thành các phần khác nhau
	loại bộ nhớ, chi tiết cụ thể về loại và thông tin khác
	về trạng thái và các sự kiện trong quá khứ của hệ thống quản lý bộ nhớ.

Tất cả số lượng bộ nhớ đều tính bằng byte.

Các mục được sắp xếp để con người có thể đọc được và các mục mới
	có thể xuất hiện ở giữa Đừng dựa vào các mục còn lại trong
	vị trí cố định; sử dụng các phím để tra cứu các giá trị cụ thể!

Nếu mục nhập không có bộ đếm trên mỗi nút (hoặc không hiển thị trong
	bộ nhớ.numa_stat). Chúng tôi sử dụng 'npn' (không phải trên mỗi nút) làm thẻ
	để chỉ ra rằng nó sẽ không hiển thị trong bộ nhớ.numa_stat.

ngay sau đó
		Lượng bộ nhớ được sử dụng trong ánh xạ ẩn danh, chẳng hạn như
		brk(), sbrk() và mmap(MAP_ANONYMOUS). Lưu ý rằng
		một số cấu hình kernel có thể hoàn thành tài khoản lớn hơn
		phân bổ (ví dụ: THP) nếu chỉ một số chứ không phải tất cả
		bộ nhớ phân bổ như vậy được ánh xạ nữa.

tập tin
		Lượng bộ nhớ được sử dụng để lưu trữ dữ liệu hệ thống tập tin,
		bao gồm tmpfs và bộ nhớ dùng chung.

hạt nhân (npn)
		Tổng dung lượng bộ nhớ kernel, bao gồm
		(kernel_stack, pagetables, percpu, vmalloc, sàn) trong
		ngoài các trường hợp sử dụng bộ nhớ kernel khác.

kernel_stack
		Lượng bộ nhớ được phân bổ cho ngăn xếp hạt nhân.

bảng phân trang
                Lượng bộ nhớ được phân bổ cho các bảng trang.

sec_pagetables
		Lượng bộ nhớ được phân bổ cho các bảng trang phụ,
		điều này hiện bao gồm phân bổ mmu KVM trên x86
		và các bảng trang arm64 và IOMMU.

percpu (npn)
		Dung lượng bộ nhớ được sử dụng để lưu trữ kernel trên mỗi CPU
		các cấu trúc dữ liệu.

tất (npn)
		Dung lượng bộ nhớ được sử dụng trong bộ đệm truyền mạng

vmalloc (npn)
		Dung lượng bộ nhớ được sử dụng cho bộ nhớ được hỗ trợ vmap.

smem
		Lượng dữ liệu hệ thống tệp được lưu trong bộ nhớ đệm được hỗ trợ trao đổi,
		chẳng hạn như tmpfs, phân đoạn shm, mmap() ẩn danh được chia sẻ

trao đổi zswap
		Lượng bộ nhớ được tiêu thụ bởi chương trình phụ trợ nén zswap.

zswapped
		Lượng bộ nhớ ứng dụng được hoán đổi thành zswap.

file_mapped
		Lượng dữ liệu hệ thống tệp được lưu trong bộ nhớ đệm được ánh xạ bằng mmap(). Lưu ý
		rằng một số cấu hình kernel có thể đã hoàn tất
		phân bổ lớn hơn (ví dụ: THP) nếu chỉ một số, nhưng không
		không phải tất cả bộ nhớ của việc phân bổ như vậy đều được ánh xạ.

file_dirty
		Lượng dữ liệu hệ thống tập tin được lưu trong bộ nhớ đệm đã được sửa đổi nhưng
		chưa được ghi lại vào đĩa

file_writeback
		Lượng dữ liệu hệ thống tập tin được lưu trong bộ nhớ cache đã được sửa đổi và
		hiện đang được ghi lại vào đĩa

được hoán đổi trong bộ nhớ đệm
		Số lượng trao đổi được lưu trữ trong bộ nhớ. Swapcache được tính
		chống lại cả việc sử dụng bộ nhớ và trao đổi.

anon_thp
		Lượng bộ nhớ được sử dụng trong ánh xạ ẩn danh được hỗ trợ bởi
		trang lớn trong suốt

tập tin_thp
		Lượng dữ liệu hệ thống tập tin được lưu trong bộ nhớ cache được hỗ trợ bởi minh bạch
		trang lớn

shmem_thp
		Số lượng shm, tmpfs, mmap() ẩn danh được chia sẻ được hỗ trợ bởi
		trang lớn trong suốt

inactive_anon, active_anon, inactive_file, active_file, không thể hủy bỏ
		Dung lượng bộ nhớ, được hỗ trợ trao đổi và được hỗ trợ bởi hệ thống tập tin,
		trên danh sách quản lý bộ nhớ trong được sử dụng bởi
		thuật toán lấy lại trang.

Vì chúng thể hiện trạng thái danh sách nội bộ (ví dụ: các trang shmem nằm trên anon
		danh sách quản lý bộ nhớ), inactive_foo + active_foo có thể không bằng
		giá trị cho bộ đếm foo, vì bộ đếm foo dựa trên loại chứ không phải
		dựa trên danh sách.

phiến_reclaimable
		Một phần của "phiến" có thể được thu hồi, chẳng hạn như
		nha khoa và inode.

phiến_không thể lấy lại được
		Một phần của "phiến" không thể lấy lại được trên bộ nhớ
		áp lực.

tấm (npn)
		Lượng bộ nhớ được sử dụng để lưu trữ dữ liệu trong kernel
		các cấu trúc.

Workingset_refault_anon
		Số lỗi của các trang ẩn danh đã bị xóa trước đó.

Workingset_refault_file
		Số lần lỗi của các trang tệp bị xóa trước đó.

Workingset_activate_anon
		Số lượng trang ẩn danh bị lỗi ngay lập tức
		được kích hoạt.

Workingset_activate_file
		Số trang tệp bị lỗi đã được kích hoạt ngay lập tức.

Workingset_restore_anon
		Số trang ẩn danh được khôi phục đã được phát hiện là
		một bộ làm việc đang hoạt động trước khi chúng được thu hồi.

Workingset_restore_file
		Số trang tệp được khôi phục đã được phát hiện dưới dạng
		bộ làm việc đang hoạt động trước khi chúng được thu hồi.

Workingset_nodereclaim
		Số lần một nút bóng được thu hồi

pswpin (npn)
		Số trang được hoán đổi vào bộ nhớ

pswpout (npn)
		Số trang bị tráo đổi khỏi bộ nhớ

psscan (npn)
		Số lượng trang được quét (trong danh sách LRU không hoạt động)

pgsteal (npn)
		Số lượng trang được thu hồi

pgscan_kswapd (npn)
		Số lượng trang được quét theo kswapd (trong danh sách LRU không hoạt động)

pgscan_direct (npn)
		Số lượng trang được quét trực tiếp (trong danh sách LRU không hoạt động)

pgscan_khugepaged (npn)
		Số lượng trang được quét theo khugepaged (trong danh sách LRU không hoạt động)

pgscan_proactive (npn)
		Số lượng trang được quét chủ động (trong danh sách LRU không hoạt động)

pgstea_kswapd (npn)
		Số lượng trang được thu hồi bởi kswapd

pgsteal_direct (npn)
		Số lượng trang được thu hồi trực tiếp

pgsteal_khugepaged (npn)
		Số lượng trang được thu hồi bởi khugepaged

pgsteal_proactive (npn)
		Số lượng trang được thu hồi chủ động

pgfault (npn)
		Tổng số lỗi trang phát sinh

pgmajfault (npn)
		Số lượng lỗi trang lớn phát sinh

pgrefill (npn)
		Số lượng trang được quét (trong danh sách LRU đang hoạt động)

pgactiv (npn)
		Số lượng trang được chuyển tới danh sách LRU đang hoạt động

pghủy kích hoạt (npn)
		Số lượng trang được chuyển đến danh sách LRU không hoạt động

pglazyfree (npn)
		Số lượng trang bị trì hoãn để được giải phóng dưới áp lực bộ nhớ

pglazyfreed (npn)
		Số lượng trang lười biếng được thu hồi

swpin_zero
		Số trang được hoán đổi vào bộ nhớ và được điền bằng 0, trong đó I/O
		đã được tối ưu hóa vì nội dung trang được phát hiện bằng 0
		trong quá trình hoán đổi.

swpout_zero
		Số lượng trang trống bị tráo đổi với I/O bị bỏ qua do
		nội dung được phát hiện là số không.

zswpin
		Số trang được chuyển vào bộ nhớ từ zswap.

zswpout
		Số trang được chuyển ra khỏi bộ nhớ sang zswap.

zswpwb
		Số trang được viết từ zswap tới swap.

zswap_incomp
		Số trang không thể nén hiện được lưu trữ trong zswap
		không nén. Những trang này không thể nén được
		có kích thước nhỏ hơn PAGE_SIZE, vì vậy chúng được lưu trữ nguyên trạng.

thp_fault_alloc (npn)
		Số lượng trang lớn trong suốt được phân bổ để đáp ứng
		một lỗi trang. Bộ đếm này không xuất hiện khi CONFIG_TRANSPARENT_HUGEPAGE
                không được thiết lập.

thp_collapse_alloc (npn)
		Số lượng trang lớn minh bạch được phân bổ để cho phép
		thu gọn một phạm vi trang hiện có. Bộ đếm này không
		xuất hiện khi CONFIG_TRANSPARENT_HUGEPAGE không được thiết lập.

thp_swpout (npn)
		Số lượng trang lớn trong suốt được hoán đổi thành một phần
		mà không cần chia tách.

thp_swpout_fallback (npn)
		Số trang lớn trong suốt đã được chia trước khi hoán đổi.
		Thông thường là do không phân bổ được một số không gian trao đổi liên tục
		cho trang lớn.

numa_pages_migrated (npn)
		Số lượng trang được di chuyển bằng tính năng cân bằng NUMA.

numa_pte_updates (npn)
		Số trang có mục trong bảng trang được sửa đổi bởi
		Cân bằng NUMA để tạo ra các lỗi gợi ý NUMA khi truy cập.

numa_hint_faults (npn)
		Số lỗi gợi ý NUMA.

pgdemote_kswapd
		Số trang bị hạ cấp bởi kswapd.

pgdemote_direct
		Số trang bị hạ cấp trực tiếp.

pgdemote_khugepaged
		Số trang bị khugepaged hạ hạng.

pgdemote_proactive
		Số lượng trang bị hạ hạng chủ động.

khổng lồ
		Dung lượng bộ nhớ được sử dụng bởi các trang Hugetlb. Số liệu này chỉ hiển thị
		tăng nếu mức sử dụng Hugetlb được tính trong bộ nhớ.current (tức là
		cgroup được gắn kết với tùy chọn Memory_hugetlb_accounting).

bộ nhớ.numa_stat
	Một tệp có khóa lồng nhau chỉ đọc tồn tại trên các nhóm không phải gốc.

Điều này chia dấu chân bộ nhớ của nhóm thành các phần khác nhau
	loại bộ nhớ, chi tiết cụ thể về loại và thông tin khác
	mỗi nút về trạng thái của hệ thống quản lý bộ nhớ.

Điều này rất hữu ích để cung cấp khả năng hiển thị về địa phương NUMA
	thông tin trong memcg vì các trang được phép
	được phân bổ từ bất kỳ nút vật lý nào. Một trong những trường hợp sử dụng là đánh giá
	hiệu suất ứng dụng bằng cách kết hợp thông tin này với
	phân bổ CPU của ứng dụng.

Tất cả số lượng bộ nhớ đều tính bằng byte.

Định dạng đầu ra của Memory.numa_stat là::

gõ N0=<byte trong nút 0> N1=<byte trong nút 1> ...

Các mục được sắp xếp để con người có thể đọc được và các mục mới
	có thể xuất hiện ở giữa Đừng dựa vào các mục còn lại trong
	vị trí cố định; sử dụng các phím để tra cứu các giá trị cụ thể!

Các mục có thể tham khảo bộ nhớ.stat.

bộ nhớ.swap.current
	Tệp giá trị duy nhất chỉ đọc tồn tại trên máy không phải root
	cgroups.

Tổng số lượng swap hiện đang được cgroup sử dụng
	và con cháu của nó.

bộ nhớ.swap.high
	Một tệp giá trị đọc-ghi tồn tại trên máy không phải root
	cgroups.  Mặc định là "tối đa".

Hoán đổi giới hạn ga sử dụng.  Nếu mức sử dụng trao đổi của một nhóm vượt quá
	giới hạn này, tất cả các phân bổ tiếp theo của nó sẽ được điều chỉnh để
	cho phép không gian người dùng thực hiện các thủ tục hết bộ nhớ tùy chỉnh.

Giới hạn này đánh dấu điểm không thể quay trở lại của nhóm. Đó là NOT
	được thiết kế để quản lý số lượng hoán đổi một khối lượng công việc
	trong quá trình hoạt động thường xuyên. So sánh với Memory.swap.max, cái nào
	cấm hoán đổi vượt quá một số tiền nhất định, nhưng cho phép nhóm
	tiếp tục không bị cản trở miễn là bộ nhớ khác có thể được lấy lại.

Khối lượng công việc lành mạnh dự kiến ​​sẽ không đạt đến giới hạn này.

bộ nhớ.swap.peak
	Một tệp giá trị đọc-ghi tồn tại trên các nhóm không phải gốc.

Mức sử dụng trao đổi tối đa được ghi lại cho nhóm cgroup và các nhóm con của nó kể từ
	việc tạo nhóm hoặc thiết lập lại gần đây nhất cho FD đó.

Việc ghi bất kỳ chuỗi không trống nào vào tệp này sẽ đặt lại nó vào
	mức sử dụng bộ nhớ hiện tại cho các lần đọc tiếp theo thông qua cùng một
	bộ mô tả tập tin.

bộ nhớ.swap.max
	Một tệp giá trị đọc-ghi tồn tại trên máy không phải root
	cgroups.  Mặc định là "tối đa".

Hoán đổi giới hạn cứng sử dụng.  Nếu mức sử dụng trao đổi của một nhóm đạt đến mức này
	giới hạn, bộ nhớ ẩn danh của nhóm sẽ không bị tráo đổi.

bộ nhớ.swap.event
	Một tệp khóa phẳng chỉ đọc tồn tại trên các nhóm không phải gốc.
	Các mục sau đây được xác định.  Trừ khi được chỉ định
	mặt khác, sự thay đổi giá trị trong tệp này sẽ tạo ra một tệp
	sự kiện sửa đổi.

cao
		Số lần sử dụng swap của cgroup đã kết thúc
		ngưỡng cao.

tối đa
		Số lần sử dụng swap của cgroup là khoảng
		để vượt qua ranh giới tối đa và phân bổ trao đổi
		thất bại.

thất bại
		Số lần phân bổ trao đổi không thành công
		vì hết trao đổi trên toàn hệ thống hoặc tối đa
		giới hạn.

Khi giảm theo mức sử dụng hiện tại, trao đổi hiện có
	các mục được lấy lại dần dần và việc sử dụng trao đổi có thể giữ nguyên
	cao hơn giới hạn trong một thời gian dài.  Cái này
	giảm tác động đến khối lượng công việc và quản lý bộ nhớ.

bộ nhớ.zswap.current
	Tệp giá trị duy nhất chỉ đọc tồn tại trên máy không phải root
	cgroups.

Tổng dung lượng bộ nhớ được sử dụng cho quá trình nén zswap
	phụ trợ.

bộ nhớ.zswap.max
	Một tệp giá trị đọc-ghi tồn tại trên máy không phải root
	cgroups.  Mặc định là "tối đa".

Giới hạn cứng sử dụng Zswap. Nếu nhóm zswap của cgroup đạt đến mức này
	giới hạn, nó sẽ từ chối nhận thêm bất kỳ cửa hàng nào trước khi tồn tại
	các mục nhập bị lỗi hoặc được ghi ra đĩa.

bộ nhớ.zswap.writeback
	Một tập tin giá trị đọc-ghi. Giá trị mặc định là "1".
	Lưu ý rằng cài đặt này có tính phân cấp, tức là việc ghi lại sẽ là
	bị vô hiệu hóa hoàn toàn đối với các nhóm con nếu hệ thống phân cấp trên
	làm như vậy.

Khi giá trị này được đặt thành 0, tất cả các nỗ lực hoán đổi sang thiết bị hoán đổi
	bị vô hiệu hóa. Điều này bao gồm cả ghi lại zswap và hoán đổi do
	để zswap thất bại lưu trữ. Nếu lỗi cửa hàng zswap tái diễn
	(ví dụ: nếu các trang không thể nén được), người dùng có thể quan sát
	đòi lại sự kém hiệu quả sau khi vô hiệu hóa chức năng ghi lại (vì tương tự
	các trang có thể bị từ chối nhiều lần).

Lưu ý rằng điều này khác biệt một chút so với cài đặt Memory.swap.max thành
	0, vì nó vẫn cho phép các trang được ghi vào nhóm zswap.
	Cài đặt này không có hiệu lực nếu zswap bị tắt và việc hoán đổi
	được phép trừ khi Memory.swap.max được đặt thành 0.

bộ nhớ.áp lực
	Một tập tin có khóa lồng nhau chỉ đọc.

Hiển thị thông tin áp suất ổn định cho bộ nhớ. Xem
	ZZ0000ZZ để biết chi tiết.


Hướng dẫn sử dụng
~~~~~~~~~~~~~~~~

"memory.high" là cơ chế chính để kiểm soát việc sử dụng bộ nhớ.
Cam kết quá mức ở giới hạn cao (tổng giới hạn cao> bộ nhớ khả dụng)
và để áp lực bộ nhớ toàn cầu phân phối bộ nhớ theo
sử dụng là một chiến lược khả thi.

Bởi vì việc vi phạm giới hạn cao không gây ra sát thủ OOM mà là
ngăn chặn nhóm vi phạm, một đại lý quản lý có đủ
cơ hội để giám sát và thực hiện các hành động thích hợp như cấp
nhiều bộ nhớ hơn hoặc chấm dứt khối lượng công việc.

Việc xác định xem một nhóm có đủ bộ nhớ hay không không hề đơn giản như
việc sử dụng bộ nhớ không cho biết liệu khối lượng công việc có thể được hưởng lợi từ
nhiều bộ nhớ hơn.  Ví dụ: khối lượng công việc ghi dữ liệu nhận được từ
mạng vào một tập tin có thể sử dụng tất cả bộ nhớ có sẵn nhưng cũng có thể hoạt động như
hoạt động với một lượng nhỏ bộ nhớ.  Thước đo trí nhớ
áp lực - khối lượng công việc bị ảnh hưởng như thế nào do thiếu
bộ nhớ - cần thiết để xác định xem khối lượng công việc có cần nhiều hơn không
trí nhớ; Thật không may, cơ chế giám sát áp suất bộ nhớ không
đã triển khai chưa.

Bảo vệ đòi lại
~~~~~~~~~~~~~~~~~~

Việc bảo vệ được định cấu hình bằng "memory.low" hoặc "memory.min" được áp dụng tương đối
tới mục tiêu thu hồi (tức là bất kỳ giới hạn nhóm bộ nhớ nào, chủ động
Memory.reclaim hoặc Global Reclaim dường như nằm trong nhóm gốc).
Giá trị bảo vệ được cấu hình cho B áp dụng không thay đổi cho quá trình thu hồi
nhắm mục tiêu A (tức là do cạnh tranh với anh chị em E)::

gốc - ... - A - B - C
		              \ ZZ0000ZZ E

Khi việc đòi lại mục tiêu là tổ tiên của A thì việc bảo vệ hiệu quả của B là
bị giới hạn bởi giá trị bảo vệ được định cấu hình cho A (và bất kỳ giá trị trung gian nào khác
tổ tiên giữa A và mục tiêu).

Để bày tỏ sự thờ ơ về việc bảo vệ anh chị em họ hàng, nên
sử dụng bộ nhớ_recursiveprot. Cấu hình tất cả con cháu của cha mẹ với hữu hạn
bảo vệ ở mức "tối đa" hoạt động nhưng nó có thể làm lệch bộ nhớ một cách không cần thiết.events:low
lĩnh vực.

Quyền sở hữu bộ nhớ
~~~~~~~~~~~~~~~~

Một vùng bộ nhớ được tính cho nhóm đã khởi tạo nó và duy trì
được tính vào cgroup cho đến khi khu vực này được giải phóng.  Di chuyển một quá trình
sang một nhóm khác sẽ không di chuyển việc sử dụng bộ nhớ mà nó
được khởi tạo khi ở nhóm trước sang nhóm mới.

Một vùng bộ nhớ có thể được sử dụng bởi các tiến trình thuộc các nhóm khác nhau.
Khu vực sẽ được tính phí cho nhóm nào là không xác định; tuy nhiên,
theo thời gian, vùng bộ nhớ có thể sẽ thuộc về một nhóm cgroup có
đủ bộ nhớ để tránh áp lực lấy lại cao.

Nếu một nhóm quét một lượng bộ nhớ đáng kể như dự kiến
được các nhóm khác truy cập nhiều lần, nên sử dụng
POSIX_FADV_DONTNEED từ bỏ quyền sở hữu vùng bộ nhớ
thuộc về các tập tin bị ảnh hưởng để đảm bảo quyền sở hữu bộ nhớ chính xác.


IO
--

Bộ điều khiển "io" quy định việc phân phối tài nguyên IO.  Cái này
bộ điều khiển thực hiện cả băng thông tuyệt đối và dựa trên trọng lượng hoặc IOPS
giới hạn phân phối; tuy nhiên, phân phối dựa trên trọng lượng có sẵn
chỉ khi cfq-iosched được sử dụng và không có lược đồ nào khả dụng cho
thiết bị blk-mq.


Tệp giao diện IO
~~~~~~~~~~~~~~~~~~

io.stat
	Một tập tin có khóa lồng nhau chỉ đọc.

Các dòng được khóa bằng số thiết bị $MAJ:$MIN và không được đặt hàng.
	Các khóa lồng nhau sau đây được xác định.

====== =======================
	  rbyte Số byte đã đọc
	  wbyte Byte đã viết
	  rios Số lượng IO đã đọc
	  wios Số lượng IO ghi
	  dbyte Byte bị loại bỏ
	  dios Số lượng IO bị loại bỏ
	  ====== =======================

Một ví dụ đọc đầu ra sau::

8:16 rbyte=1459200 wbyte=314773504 rios=192 wios=353 dbyte=0 dios=0
	  8:0 rbyte=90430464 wbyte=299008000 rios=8950 wios=1252 dbyte=50331648 dios=3021

io.cost.qos
	Một tệp có khóa lồng nhau đọc-ghi chỉ tồn tại trên thư mục gốc
	cgroup.

Tệp này định cấu hình Chất lượng dịch vụ của chi phí IO
	bộ điều khiển dựa trên mô hình (CONFIG_BLK_CGROUP_IOCOST)
	hiện đang thực hiện kiểm soát tỷ lệ "io.weight".  dòng
	được khóa bởi số thiết bị $MAJ:$MIN và không được đặt hàng.  các
	dòng cho một thiết bị nhất định được điền vào lần ghi đầu tiên cho
	thiết bị trên "io.cost.qos" hoặc "io.cost.model".  Sau đây
	các khóa lồng nhau được xác định.

====== =========================================
	  bật tính năng kiểm soát dựa trên trọng lượng
	  ctrl "tự động" hoặc "người dùng"
	  rpct Phân vị độ trễ đọc [0, 100]
	  rlat Đọc ngưỡng độ trễ
	  wpct Phân vị độ trễ ghi [0, 100]
	  wlat Ngưỡng độ trễ ghi
	  phút Tỷ lệ chia tỷ lệ tối thiểu [1, 10000]
	  max Tỷ lệ chia tỷ lệ tối đa [1, 10000]
	  ====== =========================================

Bộ điều khiển bị tắt theo mặc định và có thể được bật bởi
	cài đặt "bật" thành 1. mặc định tham số "rpct" và "wpct"
	về 0 và bộ điều khiển sử dụng độ bão hòa của thiết bị bên trong
	trạng thái để điều chỉnh tốc độ IO tổng thể giữa "tối thiểu" và "tối đa".

Khi cần chất lượng điều khiển tốt hơn, độ trễ QoS
	các thông số có thể được cấu hình.  Ví dụ::

8:16 kích hoạt=1 ctrl=auto rpct=95,00 rlat=75000 wpct=95,00 wlat=150000 phút=50,00 tối đa=150,0

cho thấy trên sdb, bộ điều khiển được bật, sẽ xem xét
	thiết bị bão hòa nếu phần trăm thứ 95 của quá trình đọc hoàn thành
	độ trễ trên 75ms hoặc ghi 150ms và điều chỉnh tổng thể
	Tỷ lệ phát hành IO tương ứng từ 50% đến 150%.

Điểm bão hòa càng thấp thì QoS có độ trễ càng tốt
	chi phí của băng thông tổng hợp.  Cho phép càng hẹp
	phạm vi điều chỉnh giữa "min" và "max", càng phù hợp
	đến mô hình chi phí hành vi IO.  Lưu ý rằng vấn đề IO
	tỷ lệ cơ bản có thể khác xa mức 100% và cài đặt "tối thiểu" và "tối đa"
	một cách mù quáng có thể dẫn đến mất đáng kể dung lượng thiết bị hoặc
	kiểm soát chất lượng.  "min" và "max" rất hữu ích cho việc điều chỉnh
	các thiết bị hiển thị các thay đổi hành vi tạm thời trên diện rộng - ví dụ: một
	ssd chấp nhận ghi ở tốc độ dòng trong một thời gian và
	sau đó hoàn toàn dừng lại trong nhiều giây.

Khi "ctrl" là "auto", các tham số được điều khiển bởi
	kernel và có thể tự động thay đổi.  Đặt "ctrl" thành "người dùng"
	hoặc thiết lập bất kỳ thông số phần trăm và độ trễ nào sẽ đặt
	nó sang chế độ "người dùng" và vô hiệu hóa các thay đổi tự động.  các
	chế độ tự động có thể được khôi phục bằng cách đặt "ctrl" thành "tự động".

io.cost.model
	Một tệp có khóa lồng nhau đọc-ghi chỉ tồn tại trên thư mục gốc
	cgroup.

Tệp này định cấu hình mô hình chi phí của mô hình chi phí IO dựa trên
	bộ điều khiển (CONFIG_BLK_CGROUP_IOCOST) hiện tại
	thực hiện kiểm soát tỷ lệ "io.weight".  Các dòng được khóa
	bởi $MAJ:$MIN số thiết bị và chưa được đặt hàng.  Dòng dành cho một
	thiết bị đã cho được điền vào lần ghi đầu tiên cho thiết bị trên
	"io.cost.qos" hoặc "io.cost.model".  Các khóa lồng nhau sau đây
	được xác định.

===== ===================================
	  ctrl "tự động" hoặc "người dùng"
	  mô hình Mô hình chi phí đang được sử dụng - "tuyến tính"
	  ===== ===================================

Khi "ctrl" là "auto", kernel có thể thay đổi tất cả các tham số
	một cách năng động.  Khi "ctrl" được đặt thành "người dùng" hoặc bất kỳ tên nào khác
	các tham số được ghi vào, "ctrl" trở thành "người dùng" và
	thay đổi tự động bị vô hiệu hóa.

Khi "mô hình" là "tuyến tính", các tham số mô hình sau đây là
	được xác định.

==========================================================
	  [r|w]bps Thông lượng IO tuần tự tối đa
	  [r|w]seqiops IO tuần tự tối đa 4k mỗi giây
	  [r|w]randiops Tối đa 4k IO ngẫu nhiên mỗi giây
	  ==========================================================

Từ những điều trên, mô hình tuyến tính dựng sẵn xác định cơ sở
	chi phí của IO tuần tự và ngẫu nhiên và hệ số chi phí
	cho kích thước IO.  Mặc dù đơn giản nhưng mô hình này có thể bao gồm hầu hết
	các lớp thiết bị phổ biến có thể chấp nhận được.

Mô hình chi phí IO dự kiến sẽ không chính xác tuyệt đối
	có ý nghĩa và được điều chỉnh linh hoạt theo hành vi của thiết bị.

Nếu cần, có thể sử dụng tools/cgroup/iocost_coef_gen.py để
	tạo ra các hệ số dành riêng cho thiết bị.

io.weight
	Một tệp khóa phẳng đọc-ghi tồn tại trên các nhóm không phải gốc.
	Mặc định là "mặc định 100".

Dòng đầu tiên là trọng lượng mặc định áp dụng cho thiết bị
	không ghi đè cụ thể.  Phần còn lại được ghi đè bởi
	$MAJ:$MIN số thiết bị và chưa được đặt hàng.  Trọng lượng đang ở trong
	phạm vi [1, 10000] và chỉ định lượng thời gian IO tương đối
	cgroup có thể sử dụng trong mối quan hệ với anh chị em của nó.

Trọng lượng mặc định có thể được cập nhật bằng cách viết "mặc định
	$WEIGHT" hoặc đơn giản là "$WEIGHT".  Ghi đè có thể được thiết lập bằng cách viết
	"$MAJ:$MIN $WEIGHT" và hủy đặt bằng cách viết "$MAJ:$MIN default".

Một ví dụ đọc đầu ra sau::

mặc định 100
	  8:16 200
	  8:0 50

io.max
	Một tệp có khóa lồng nhau đọc-ghi tồn tại trên máy không phải root
	cgroups.

Giới hạn IO dựa trên BPS và IOPS.  Các dòng được khóa bởi $MAJ:$MIN
	số thiết bị và không được đặt hàng.  Các khóa lồng nhau sau đây là
	được xác định.

==========================================
	  rbps Số byte đọc tối đa mỗi giây
	  wbps Ghi tối đa byte mỗi giây
	  riops Max đọc các hoạt động IO mỗi giây
	  wiops Max ghi các hoạt động IO mỗi giây
	  ==========================================

Khi viết, bất kỳ số cặp khóa-giá trị lồng nhau nào cũng có thể được
	được chỉ định theo thứ tự bất kỳ.  "max" có thể được chỉ định làm giá trị
	để loại bỏ một giới hạn cụ thể.  Nếu cùng một khóa được chỉ định
	nhiều lần, kết quả không được xác định.

BPS và IOPS được đo theo từng hướng IO và IO được đo
	bị trì hoãn nếu đạt đến giới hạn.  Cho phép bùng nổ tạm thời.

Đặt giới hạn đọc ở 2M BPS và ghi ở 120 IOPS trong 8:16::

echo "8:16 rbps=2097152 wiops=120" > io.max

Việc đọc trả về kết quả sau::

8:16 rbps=2097152 wbps=riops tối đa=wiops tối đa=120

Có thể xóa giới hạn ghi IOPS bằng cách viết như sau::

echo "8:16 wiops=max"> io.max

Đọc bây giờ trả về như sau ::

8:16 rbps=2097152 wbps=max riops=wiops tối đa=max

io.áp lực
	Một tập tin có khóa lồng nhau chỉ đọc.

Hiển thị thông tin ngừng áp suất cho IO. Xem
	ZZ0000ZZ để biết chi tiết.


Viết lại
~~~~~~~~~

Bộ đệm trang bị xóa thông qua ghi vào bộ đệm và chia sẻ mmap và
được ghi không đồng bộ vào hệ thống tập tin sao lưu bằng cách ghi lại
cơ chế.  Writeback nằm giữa miền bộ nhớ và miền IO và
điều chỉnh tỷ lệ bộ nhớ bẩn bằng cách cân bằng giữa việc làm bẩn và
viết IO.

Bộ điều khiển io, kết hợp với bộ điều khiển bộ nhớ,
thực hiện kiểm soát các IO ghi lại bộ đệm trang.  Bộ điều khiển bộ nhớ
xác định miền bộ nhớ mà tỷ lệ bộ nhớ bẩn được tính toán và
được duy trì và bộ điều khiển io xác định miền io
ghi ra các trang bẩn cho miền bộ nhớ.  Cả trên toàn hệ thống và
trạng thái bộ nhớ bẩn trên mỗi nhóm được kiểm tra và hạn chế hơn
của cả hai được thi hành.

viết lại cgroup yêu cầu hỗ trợ rõ ràng từ cơ bản
hệ thống tập tin.  Hiện tại, cgroup writeback được triển khai trên ext2, ext4,
btrfs, f2fs và xfs.  Trên các hệ thống tập tin khác, tất cả các IO ghi lại đều được 
được quy cho nhóm gốc.

Có sự khác biệt cố hữu trong quản lý bộ nhớ và ghi lại
điều này ảnh hưởng đến cách theo dõi quyền sở hữu của cgroup.  Bộ nhớ được theo dõi mỗi
trang trong khi viết lại trên mỗi inode.  Với mục đích viết lại, một
inode được gán cho một nhóm và tất cả các yêu cầu IO để viết các trang bẩn
từ inode được quy cho nhóm đó.

Vì quyền sở hữu bộ nhớ của nhóm được theo dõi trên mỗi trang nên có thể có các trang
được liên kết với các nhóm khác với nhóm mà inode có
liên kết với.  Đây được gọi là trang nước ngoài.  Viết lại
liên tục theo dõi các trang nước ngoài và, nếu một trang nước ngoài cụ thể
cgroup trở thành đa số trong một khoảng thời gian nhất định, chuyển đổi
quyền sở hữu inode đối với nhóm đó.

Mặc dù mô hình này là đủ cho hầu hết các trường hợp sử dụng một nút nhất định
hầu hết bị làm bẩn bởi một nhóm duy nhất ngay cả khi nhóm viết chính
thay đổi theo thời gian, các trường hợp sử dụng trong đó nhiều nhóm ghi vào một
inode đồng thời không được hỗ trợ tốt.  Trong hoàn cảnh như vậy, một
một phần đáng kể của IO có thể được phân bổ không chính xác.
Vì bộ điều khiển bộ nhớ chỉ định quyền sở hữu trang trong lần sử dụng đầu tiên và
không cập nhật nó cho đến khi trang được phát hành, ngay cả khi viết lại
tuân thủ nghiêm ngặt quyền sở hữu trang, nhiều cgroup chồng chéo
các khu vực sẽ không hoạt động như mong đợi.  Nên tránh sử dụng như vậy
các mẫu.

Các nút sysctl ảnh hưởng đến hành vi ghi lại được áp dụng cho cgroup
viết lại như sau.

vm.dirty_background_ratio, vm.dirty_ratio
	Các tỷ lệ này áp dụng tương tự cho việc ghi lại cgroup với
	lượng bộ nhớ khả dụng bị giới hạn bởi các giới hạn do
	bộ điều khiển bộ nhớ và bộ nhớ sạch toàn hệ thống.

vm.dirty_background_bytes, vm.dirty_bytes
	Đối với ghi lại cgroup, điều này được tính thành tỷ lệ so với
	tổng bộ nhớ khả dụng và áp dụng theo cách tương tự như
	vm.dirty[_background]_ratio.


Độ trễ IO
~~~~~~~~~~

Đây là bộ điều khiển cgroup v2 để bảo vệ khối lượng công việc IO.  Bạn cung cấp một nhóm
với mục tiêu độ trễ và nếu độ trễ trung bình vượt quá mục tiêu đó thì
bộ điều khiển sẽ điều tiết bất kỳ thiết bị ngang hàng nào có mục tiêu độ trễ thấp hơn
khối lượng công việc được bảo vệ.

Các giới hạn chỉ được áp dụng ở cấp độ ngang hàng trong hệ thống phân cấp.  Điều này có nghĩa là
trong sơ đồ bên dưới, chỉ có nhóm A, B và C sẽ ảnh hưởng lẫn nhau và
nhóm D và F sẽ ảnh hưởng lẫn nhau.  Nhóm G sẽ không ảnh hưởng đến ai::

[gốc]
		/ |		\
		A B C
	       / \ |
	      D F G


Vì vậy, cách lý tưởng để định cấu hình điều này là đặt io.latency trong các nhóm A, B và C.
Nói chung bạn không muốn đặt giá trị thấp hơn độ trễ thiết bị của mình
hỗ trợ.  Hãy thử nghiệm để tìm ra giá trị phù hợp nhất với khối lượng công việc của bạn.
Bắt đầu ở độ trễ cao hơn dự kiến cho thiết bị của bạn và xem
giá trị avg_lat trong io.stat cho nhóm khối lượng công việc của bạn để có ý tưởng về
độ trễ bạn thấy trong quá trình hoạt động bình thường.  Sử dụng giá trị avg_lat làm cơ sở cho
cài đặt thực của bạn, cài đặt cao hơn 10-15% so với giá trị trong io.stat.

Cách điều chỉnh độ trễ IO hoạt động
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

io.latency là tiết kiệm công việc; miễn là mọi người đều đáp ứng được độ trễ của mình
nhắm mục tiêu bộ điều khiển không làm gì cả.  Khi một nhóm bắt đầu mất tích
target, nó bắt đầu hạn chế bất kỳ nhóm ngang hàng nào có mục tiêu cao hơn chính nó.
Việc điều chỉnh này có 2 hình thức:

- Điều chỉnh độ sâu hàng đợi.  Đây là số lượng IO nổi bật của một nhóm
  được phép có.  Chúng tôi sẽ kiểm soát tương đối nhanh chóng, bắt đầu từ mức không giới hạn
  và giảm dần xuống còn 1 IO mỗi lần.

- Cảm ứng trễ nhân tạo.  Có một số loại IO không thể
  được điều tiết mà không có khả năng ảnh hưởng bất lợi đến các nhóm có mức độ ưu tiên cao hơn.  Cái này
  bao gồm trao đổi và siêu dữ liệu IO.  Các loại IO này được phép xảy ra
  thông thường, tuy nhiên họ sẽ bị "tính phí" cho nhóm khởi tạo.  Nếu
  nhóm ban đầu đang được điều chỉnh, bạn sẽ thấy use_delay và delay
  các trường trong io.stat tăng lên.  Giá trị độ trễ là bao nhiêu micro giây
  được thêm vào bất kỳ tiến trình nào chạy trong nhóm này.  Vì con số này có thể
  phát triển khá lớn nếu có nhiều trao đổi hoặc IO siêu dữ liệu xảy ra.
  giới hạn các sự kiện trễ riêng lẻ ở mức 1 giây mỗi lần.

Sau khi nhóm nạn nhân bắt đầu đáp ứng lại mục tiêu về độ trễ, nhóm sẽ bắt đầu
hủy điều tiết bất kỳ nhóm ngang hàng nào đã bị điều tiết trước đó.  Nếu nạn nhân
nhóm chỉ cần ngừng thực hiện IO, bộ đếm toàn cầu sẽ mở khóa một cách thích hợp.

Tệp giao diện độ trễ IO
~~~~~~~~~~~~~~~~~~~~~~~~~~

io.độ trễ
	Điều này có định dạng tương tự như các bộ điều khiển khác.

"MAJOR:MINOR target=<thời gian mục tiêu tính bằng micro giây>"

io.stat
	Nếu bộ điều khiển được bật, bạn sẽ thấy số liệu thống kê bổ sung trong io.stat trong
	ngoài những cái thông thường.

độ sâu
		Đây là độ sâu hàng đợi hiện tại của nhóm.

trung bình_lat
		Đây là đường trung bình động hàm mũ với tốc độ giảm dần là 1/exp
		bị ràng buộc bởi khoảng thời gian lấy mẫu.  Khoảng tốc độ phân rã có thể là
		được tính bằng cách nhân giá trị win trong io.stat với
		số lượng mẫu tương ứng dựa trên giá trị win.

thắng
		Kích thước cửa sổ lấy mẫu tính bằng mili giây.  Đây là mức tối thiểu
		khoảng thời gian giữa các sự kiện đánh giá.  Windows chỉ trôi qua
		với hoạt động IO.  Khoảng thời gian nhàn rỗi sẽ mở rộng cửa sổ gần đây nhất.

Ưu tiên IO
~~~~~~~~~~~

Một thuộc tính duy nhất kiểm soát hành vi của chính sách nhóm ưu tiên I/O,
cụ thể là thuộc tính io.prio.class. Các giá trị sau được chấp nhận cho
thuộc tính đó:

không thay đổi
	Không sửa đổi lớp ưu tiên I/O.

quảng cáo-to-rt
	Đối với các yêu cầu có lớp ưu tiên I/O không phải RT, hãy đổi nó thành RT.
	Đồng thời thay đổi mức độ ưu tiên của các yêu cầu này thành 4. Không sửa đổi
	mức độ ưu tiên I/O của các yêu cầu có lớp ưu tiên RT.

hạn chế
	Đối với các yêu cầu không có lớp ưu tiên I/O hoặc có I/O
	lớp ưu tiên RT, đổi thành BE. Đồng thời thay đổi mức độ ưu tiên
	của các yêu cầu này thành 0. Không sửa đổi lớp ưu tiên I/O của
	yêu cầu có lớp ưu tiên IDLE.

nhàn rỗi
	Thay đổi lớp ưu tiên I/O của tất cả các yêu cầu thành IDLE, mức thấp nhất
	Lớp ưu tiên I/O

không có gì
	Không dùng nữa. Chỉ là bí danh cho quảng cáo-to-rt.

Các giá trị số sau đây được liên kết với chính sách ưu tiên I/O:

+----------------+---+
ZZ0000ZZ 0 |
+----------------+---+
ZZ0001ZZ 1 |
+----------------+---+
ZZ0002ZZ 2 |
+----------------+---+
ZZ0003ZZ 3 |
+----------------+---+

Giá trị số tương ứng với từng lớp ưu tiên I/O như sau:

+------------------------------+---+
ZZ0000ZZ 0 |
+------------------------------+---+
ZZ0001ZZ 1 |
+------------------------------+---+
ZZ0002ZZ 2 |
+------------------------------+---+
ZZ0003ZZ 3 |
+------------------------------+---+

Thuật toán đặt lớp ưu tiên I/O cho một yêu cầu như sau:

- Nếu chính sách lớp ưu tiên I/O là thăng hạng thành rt, hãy thay đổi yêu cầu I/O
  lớp ưu tiên thành IOPRIO_CLASS_RT và thay đổi mức độ ưu tiên I/O của yêu cầu
  lên cấp 4.
- Nếu chính sách lớp ưu tiên I/O không được thăng cấp thành rt, hãy dịch mức độ ưu tiên I/O
  chính sách lớp thành một số, sau đó thay đổi lớp ưu tiên I/O của yêu cầu
  vào số chính sách lớp ưu tiên I/O tối đa và số
  Lớp ưu tiên I/O

PID
---

Bộ điều khiển số quy trình được sử dụng để cho phép một nhóm dừng bất kỳ
nhiệm vụ mới từ fork()'d hoặc clone()'d sau một giới hạn được chỉ định là
đạt tới.

Số lượng nhiệm vụ trong một nhóm có thể được sử dụng hết theo những cách khác
bộ điều khiển không thể ngăn chặn, do đó bảo hành bộ điều khiển riêng của mình.  cho
Ví dụ: Fork Bomb có khả năng làm cạn kiệt số lượng nhiệm vụ trước đó
đánh hạn chế bộ nhớ.

Lưu ý rằng các PID được sử dụng trong bộ điều khiển này đề cập đến các TID, các ID tiến trình như
được sử dụng bởi kernel.


Tệp giao diện PID
~~~~~~~~~~~~~~~~~~~

pids.max
	Một tệp giá trị đọc-ghi tồn tại trên máy không phải root
	cgroups.  Mặc định là "tối đa".

Giới hạn cứng của số lượng tiến trình.

pids.current
	Tệp giá trị duy nhất chỉ đọc tồn tại trên các nhóm không phải gốc.

Số lượng tiến trình hiện có trong cgroup và
	con cháu.

pids.peak
	Tệp giá trị duy nhất chỉ đọc tồn tại trên các nhóm không phải gốc.

Giá trị tối đa mà số lượng tiến trình trong cgroup và của nó
	con cháu đã từng đạt tới.

pids.events
	Một tệp khóa phẳng chỉ đọc tồn tại trên các nhóm không phải gốc. Trừ khi
	được chỉ định khác, sự thay đổi giá trị trong tệp này sẽ tạo ra một tệp
	sự kiện sửa đổi. Các mục sau đây được xác định.

tối đa
		Số lần tổng số tiến trình của nhóm đạt tới pids.max
		giới hạn (xem thêm pids_localevents).

pids.events.local
	Tương tự như pids.events nhưng các trường trong tệp là cục bộ
	vào nhóm, tức là không phân cấp. Sự kiện sửa đổi tập tin
	được tạo trên tệp này chỉ phản ánh các sự kiện cục bộ.

Hoạt động của tổ chức không bị chính sách của cgroup chặn nên
có thể có pids.current > pids.max.  Điều này có thể được thực hiện bằng một trong hai
đặt giới hạn nhỏ hơn pids.current hoặc đính kèm đủ
xử lý vào nhóm sao cho pids.current lớn hơn
pids.max.  Tuy nhiên, không thể vi phạm chính sách PID của cgroup
thông qua fork() hoặc clone(). Những thứ này sẽ trả về -EAGAIN nếu việc tạo
của một quy trình mới sẽ khiến chính sách của cgroup bị vi phạm.


bộ xử lý
------

Bộ điều khiển "cpuset" cung cấp cơ chế hạn chế
CPU và vị trí nút bộ nhớ chỉ thực hiện các tác vụ đối với các tài nguyên
được chỉ định trong các tệp giao diện cpuset trong nhóm hiện tại của tác vụ.
Điều này đặc biệt có giá trị trên các hệ thống NUMA lớn nơi đặt công việc
trên các tập hợp con có kích thước phù hợp của hệ thống với bộ xử lý cẩn thận và
vị trí bộ nhớ để giảm sự truy cập và tranh chấp bộ nhớ giữa các nút
có thể cải thiện hiệu năng tổng thể của hệ thống.

Bộ điều khiển "cpuset" có tính phân cấp.  Điều đó có nghĩa là bộ điều khiển
không thể sử dụng CPU hoặc các nút bộ nhớ không được phép trong phần tử mẹ của nó.


Tệp giao diện CPUset
~~~~~~~~~~~~~~~~~~~~~~

cpuset.cpus
	Một tệp nhiều giá trị đọc-ghi tồn tại trên máy không phải root
	các nhóm hỗ trợ cpuset.

Nó liệt kê các CPU được yêu cầu sẽ được sử dụng bởi các tác vụ trong phạm vi này.
	cgroup.  Tuy nhiên, danh sách thực tế các CPU được cấp phép là
	chịu sự ràng buộc do cha mẹ áp đặt và có thể khác nhau
	từ các CPU được yêu cầu.

Số CPU là số hoặc phạm vi được phân tách bằng dấu phẩy.
	Ví dụ::

CPUset.cpus # cat
	  0-4,6,8-10

Giá trị trống cho biết nhóm đang sử dụng cùng một
	thiết lập làm tổ tiên của nhóm gần nhất với một giá trị không trống
	"cpuset.cpus" hoặc tất cả các CPU có sẵn nếu không tìm thấy.

Giá trị của "cpuset.cpus" không đổi cho đến lần cập nhật tiếp theo
	và sẽ không bị ảnh hưởng bởi bất kỳ sự kiện cắm nóng CPU nào.

cpuset.cpus.hiệu quả
	Một tệp nhiều giá trị chỉ đọc tồn tại trên tất cả
	các nhóm hỗ trợ cpuset.

Nó liệt kê các CPU trực tuyến thực sự được cấp cho việc này
	cgroup bởi cha mẹ của nó.  Những CPU này được phép sử dụng bởi
	nhiệm vụ trong nhóm hiện tại.

Nếu "cpuset.cpus" trống, tệp "cpuset.cpus.effect" sẽ hiển thị
	tất cả các CPU từ nhóm mẹ có thể sử dụng được
	được sử dụng bởi cgroup này.  Nếu không, nó phải là một tập hợp con của
	"cpuset.cpus" trừ khi không có CPU nào được liệt kê trong "cpuset.cpus"
	có thể được cấp.  Trong trường hợp này, nó sẽ được xử lý giống như một
	"cpuset.cpus" trống.

Giá trị của nó sẽ bị ảnh hưởng bởi các sự kiện cắm nóng CPU.

cpuset.mems
	Một tệp nhiều giá trị đọc-ghi tồn tại trên máy không phải root
	các nhóm hỗ trợ cpuset.

Nó liệt kê các nút bộ nhớ được yêu cầu sẽ được sử dụng bởi các tác vụ trong
	nhóm này.  Tuy nhiên, danh sách thực tế các nút bộ nhớ được cấp,
	phải chịu các ràng buộc do cha mẹ của nó áp đặt và có thể khác nhau
	từ các nút bộ nhớ được yêu cầu.

Số nút bộ nhớ là số hoặc phạm vi được phân tách bằng dấu phẩy.
	Ví dụ::

CPUset # cat.mems
	  0-1,3

Giá trị trống cho biết nhóm đang sử dụng cùng một
	thiết lập làm tổ tiên của nhóm gần nhất với một giá trị không trống
	"cpuset.mems" hoặc tất cả các nút bộ nhớ khả dụng nếu không có
	được tìm thấy.

Giá trị của "cpuset.mems" không đổi cho đến lần cập nhật tiếp theo
	và sẽ không bị ảnh hưởng bởi bất kỳ sự kiện cắm nóng nút bộ nhớ nào.

Việc đặt giá trị không trống thành "cpuset.mems" sẽ khiến bộ nhớ bị lỗi
	các nhiệm vụ trong nhóm sẽ được di chuyển đến các nút được chỉ định nếu
	họ hiện đang sử dụng bộ nhớ bên ngoài các nút được chỉ định.

Có một chi phí cho việc di chuyển bộ nhớ này.  Sự di cư
	có thể không hoàn chỉnh và một số trang bộ nhớ có thể bị bỏ lại.
	Vì vậy, nên đặt "cpuset.mems" đúng cách
	trước khi sinh ra các tác vụ mới vào cpuset.  Kể cả nếu có
	cần thay đổi "cpuset.mems" bằng các tác vụ đang hoạt động, không nên
	được thực hiện thường xuyên.

cpuset.mems.hiệu quả
	Một tệp nhiều giá trị chỉ đọc tồn tại trên tất cả
	các nhóm hỗ trợ cpuset.

Nó liệt kê các nút bộ nhớ trực tuyến thực sự được cấp cho
	cgroup này bởi cha mẹ của nó. Các nút bộ nhớ này được phép
	được sử dụng bởi các tác vụ trong nhóm hiện tại.

Nếu "cpuset.mems" trống, nó sẽ hiển thị tất cả các nút bộ nhớ từ
	cgroup gốc sẽ có sẵn để cgroup này sử dụng.
	Mặt khác, nó phải là tập hợp con của "cpuset.mems" trừ khi không có tập hợp nào
	các nút bộ nhớ được liệt kê trong "cpuset.mems" có thể được cấp.  Trong này
	trường hợp này, nó sẽ được xử lý giống như một "cpuset.mems" trống.

Giá trị của nó sẽ bị ảnh hưởng bởi các sự kiện cắm nóng nút bộ nhớ.

cpuset.cpus.exclusive
	Một tệp nhiều giá trị đọc-ghi tồn tại trên máy không phải root
	các nhóm hỗ trợ cpuset.

Nó liệt kê tất cả các CPU độc quyền được phép sử dụng
	để tạo một phân vùng cpuset mới.  Giá trị của nó không được sử dụng
	trừ khi cgroup trở thành gốc phân vùng hợp lệ.  Xem
	Phần "cpuset.cpus.partition" bên dưới để biết mô tả về những gì
	một phân vùng cpuset là.

Khi cgroup trở thành một phân vùng gốc, quyền độc quyền thực sự
	Các CPU được phân bổ cho phân vùng đó được liệt kê trong
	"cpuset.cpus.exclusive.effect" có thể khác
	từ "cpuset.cpus.exclusive".  Nếu "cpuset.cpus.exclusive"
	trước đây đã được đặt, "cpuset.cpus.exclusive.effect"
	luôn là tập con của nó.

Người dùng có thể đặt nó theo cách thủ công thành một giá trị khác với
	"cpuset.cpus".	Một hạn chế trong việc thiết lập nó là danh sách các
	CPU phải độc quyền đối với "cpuset.cpus.exclusive"
	và "cpuset.cpus.exclusive.effect" của các anh chị em của nó.	Khác
	hạn chế là nó không thể là siêu bộ của "cpuset.cpus"
	của anh chị em của nó để để lại ít nhất một CPU có sẵn cho
	anh chị em đó khi CPU độc quyền bị lấy đi.

Đối với một nhóm mẹ, bất kỳ CPU độc quyền nào của nó chỉ có thể
	được phân phối tới nhiều nhất một trong các nhóm con của nó.  Có một
	CPU độc quyền xuất hiện trong hai hoặc nhiều nhóm con của nó là
	không được phép (quy tắc độc quyền).  Giá trị vi phạm
	quy tắc độc quyền sẽ bị từ chối với lỗi ghi.

Nhóm gốc là một phân vùng gốc và tất cả các CPU có sẵn của nó
	nằm trong bộ CPU độc quyền của nó.

cpuset.cpus.exclusive.hiệu quả
	Tệp nhiều giá trị chỉ đọc tồn tại trên tất cả các máy không phải gốc
	các nhóm hỗ trợ cpuset.

Tệp này hiển thị tập hợp CPU độc quyền hiệu quả
	có thể được sử dụng để tạo một phân vùng gốc.  Nội dung
	của tệp này sẽ luôn là tập hợp con của tệp cha của nó
	"cpuset.cpus.exclusive.effect" nếu cấp độ gốc của nó không phải là root
	cgroup.  Nó cũng sẽ là một tập hợp con của "cpuset.cpus.exclusive"
	nếu nó được thiết lập.  Tệp này chỉ được để trống nếu một trong hai
	"cpuset.cpus.exclusive" được đặt hoặc khi cpuset hiện tại được
	một phân vùng gốc hợp lệ.

cpuset.cpus.isolat
	Tệp nhiều giá trị chỉ đọc và nhóm gốc.

Tệp này hiển thị tập hợp tất cả các CPU bị cô lập được sử dụng trong
	các phân vùng bị cô lập. Nó sẽ trống nếu không có phân vùng riêng biệt
	được tạo ra.

cpuset.cpus.partition
	Một tệp giá trị đọc-ghi tồn tại trên máy không phải root
	các nhóm hỗ trợ cpuset.  Cờ này thuộc sở hữu của cgroup mẹ
	và không được ủy quyền.

Nó chỉ chấp nhận các giá trị đầu vào sau khi được ghi vào.

===================================================
	  "thành viên" Thành viên không phải root của phân vùng
	  "root" Gốc phân vùng
	  Root phân vùng "bị cô lập" mà không cần cân bằng tải
	  ===================================================

Phân vùng cpuset là tập hợp các nhóm hỗ trợ cpuset với
	một gốc phân vùng ở đầu hệ thống phân cấp và các hậu duệ của nó
	ngoại trừ những cái có gốc phân vùng riêng biệt và
	con cháu của họ.  Một phân vùng có quyền truy cập độc quyền vào
	tập hợp các CPU độc quyền được phân bổ cho nó.	Các nhóm khác bên ngoài
	của phân vùng đó không thể sử dụng bất kỳ CPU nào trong bộ đó.

Có hai loại phân vùng - cục bộ và từ xa.  Một địa phương
	phân vùng là phân vùng có nhóm mẹ cũng là phân vùng hợp lệ
	gốc.  Một phân vùng từ xa là một phân vùng có nhóm cha mẹ không phải là một
	gốc phân vùng hợp lệ.

Việc ghi vào "cpuset.cpus.exclusive" là tùy chọn để tạo
	của một phân vùng cục bộ vì tệp "cpuset.cpus.exclusive" của nó sẽ
	giả sử một giá trị tiềm ẩn giống như "cpuset.cpus" nếu nó
	không được thiết lập.  Viết các giá trị "cpuset.cpus.exclusive" thích hợp
	xuống hệ thống phân cấp cgroup trước khi gốc phân vùng đích được
	bắt buộc để tạo một phân vùng từ xa.

Không phải tất cả các CPU được yêu cầu trong "cpuset.cpus.exclusive" đều có thể
	được sử dụng để tạo một phân vùng mới.  Chỉ những người có mặt
	trong điều khiển "cpuset.cpus.exclusive.effect" của cha mẹ nó
	có thể sử dụng tập tin .  Đối với các phân vùng được tạo mà không cần thiết lập
	"cpuset.cpus.exclusive", CPU độc quyền được chỉ định trong anh chị em
	"cpuset.cpus.exclusive" hoặc "cpuset.cpus.exclusive.effect"
	cũng không thể sử dụng được.

Hiện tại, không thể tạo phân vùng từ xa dưới địa chỉ cục bộ.
	phân vùng.  Tất cả tổ tiên của một phân vùng gốc từ xa ngoại trừ
	nhóm gốc không thể là gốc phân vùng.

Nhóm gốc luôn là một phân vùng gốc và trạng thái của nó không thể
	được thay đổi.  Tất cả các nhóm không phải root khác đều bắt đầu với tư cách là "thành viên".
	Mặc dù "cpuset.cpus.exclusive*" và "cpuset.cpus"
	các tập tin điều khiển không có trong nhóm gốc, chúng
	hoàn toàn giống với "/sys/devices/system/cpu/possible"
	tập tin sysfs.

Khi được đặt thành "root", nhóm hiện tại là gốc của một nhóm mới
	miền phân vùng hoặc lập kế hoạch.  Bộ CPU độc quyền là
	được xác định bởi giá trị của "cpuset.cpus.exclusive.effect" của nó.

Khi được đặt thành "cách ly", các CPU trong phân vùng đó sẽ ở trạng thái
	trạng thái biệt lập không có bất kỳ cân bằng tải nào từ bộ lập lịch
	và loại trừ khỏi hàng đợi công việc không bị ràng buộc.  Nhiệm vụ được đặt trong đó
	một phân vùng có nhiều CPU nên được phân phối cẩn thận
	và được liên kết với từng CPU riêng lẻ để có hiệu suất tối ưu.

Một phân vùng gốc ("root" hoặc "bị cô lập") có thể ở một trong các
	hai trạng thái có thể - hợp lệ hoặc không hợp lệ.  Phân vùng không hợp lệ
	root đang ở trạng thái xuống cấp trong đó một số thông tin trạng thái có thể
	được giữ lại nhưng cư xử giống một "thành viên" hơn.

Tất cả các chuyển đổi trạng thái có thể có giữa "thành viên", "gốc" và
	"cách ly" được cho phép.

Khi đọc, tệp "cpuset.cpus.partition" có thể hiển thị như sau
	các giá trị.

=======================================================================
	  "thành viên" Thành viên không phải root của phân vùng
	  "root" Gốc phân vùng
	  Root phân vùng "bị cô lập" mà không cần cân bằng tải
	  "root không hợp lệ (<reason>)" Gốc phân vùng không hợp lệ
	  "bị cô lập không hợp lệ (<lý do>)" Gốc phân vùng bị cô lập không hợp lệ
	  =======================================================================

Trong trường hợp gốc phân vùng không hợp lệ, một chuỗi mô tả trên
	tại sao phân vùng không hợp lệ được bao gồm trong dấu ngoặc đơn.

Để gốc phân vùng cục bộ hợp lệ, các điều kiện sau
	phải được đáp ứng.

1) Nhóm mẹ là gốc phân vùng hợp lệ.
	2) Tệp "cpuset.cpus.exclusive.effect" không được để trống,
	   mặc dù nó có thể chứa CPU ngoại tuyến.
	3) "cpuset.cpus.effect" không được để trống trừ khi có
	   không có nhiệm vụ liên quan đến phân vùng này.

Để gốc phân vùng từ xa hợp lệ, tất cả các điều kiện trên
	ngoại trừ điều đầu tiên phải được đáp ứng.

Các sự kiện bên ngoài như hotplug hoặc thay đổi đối với "cpuset.cpus" hoặc
	"cpuset.cpus.exclusive" có thể khiến root phân vùng hợp lệ bị lỗi
	trở nên vô hiệu và ngược lại.	Lưu ý rằng một nhiệm vụ không thể
	đã chuyển đến một nhóm có "cpuset.cpus.effect" trống.

Phân vùng gốc không phải gốc hợp lệ có thể phân phối tất cả CPU của nó
	vào các phân vùng cục bộ con của nó khi không có tác vụ nào liên quan
	với nó.

Phải cẩn thận để thay đổi gốc phân vùng hợp lệ thành "thành viên"
	vì tất cả các phân vùng cục bộ con của nó, nếu có, sẽ trở thành
	không hợp lệ gây gián đoạn các tác vụ đang chạy ở trẻ đó
	phân vùng. Những phân vùng không hoạt động này có thể được phục hồi nếu
	cha mẹ của chúng được chuyển trở lại phân vùng gốc với một phân vùng thích hợp
	giá trị trong "cpuset.cpus" hoặc "cpuset.cpus.exclusive".

Các sự kiện thăm dò và inotify được kích hoạt bất cứ khi nào trạng thái của
	thay đổi "cpuset.cpus.partition".  Điều đó bao gồm những thay đổi gây ra
	bằng cách ghi vào "cpuset.cpus.partition", cpu hotplug hoặc khác
	những thay đổi làm thay đổi trạng thái hợp lệ của phân vùng.
	Điều này sẽ cho phép các tác nhân không gian của người dùng theo dõi những thay đổi không mong muốn
	đến "cpuset.cpus.partition" mà không cần phải thực hiện liên tục
	bỏ phiếu.

Người dùng có thể định cấu hình trước một số CPU nhất định ở trạng thái biệt lập
	với tính năng cân bằng tải bị tắt khi khởi động với "isolcpus"
	tùy chọn dòng lệnh khởi động kernel.  Nếu những CPU đó được đặt
	vào một phân vùng thì chúng phải được sử dụng trong một phân vùng biệt lập.


Bộ điều khiển thiết bị
-----------------

Bộ điều khiển thiết bị quản lý quyền truy cập vào các tập tin thiết bị. Nó bao gồm cả
tạo các tập tin thiết bị mới (sử dụng mknod) và truy cập vào
tập tin thiết bị hiện có.

Bộ điều khiển thiết bị Cgroup v2 không có tệp giao diện và được triển khai
trên đỉnh cgroup BPF. Để kiểm soát quyền truy cập vào các tập tin thiết bị, người dùng có thể
tạo các chương trình bpf loại BPF_PROG_TYPE_CGROUP_DEVICE và đính kèm
chúng vào các nhóm có cờ BPF_CGROUP_DEVICE. Trong nỗ lực truy cập một
tập tin thiết bị, các chương trình BPF tương ứng sẽ được thực thi và tùy thuộc vào
trên giá trị trả về, lần thử sẽ thành công hay thất bại với -EPERM.

Một chương trình BPF_PROG_TYPE_CGROUP_DEVICE lấy một con trỏ tới
Cấu trúc bpf_cgroup_dev_ctx, mô tả nỗ lực truy cập thiết bị:
loại truy cập (mknod/đọc/ghi) và thiết bị (loại, số chính và số phụ).
Nếu chương trình trả về 0, lần thử không thành công với -EPERM, nếu không thì nó
thành công.

Một ví dụ về chương trình BPF_PROG_TYPE_CGROUP_DEVICE có thể được tìm thấy trong
tools/testing/selftests/bpf/progs/dev_cgroup.c trong cây nguồn kernel.


RDMA
----

Bộ điều khiển "rdma" điều chỉnh việc phân phối và tính toán
Tài nguyên RDMA.

Tệp giao diện RDMA
~~~~~~~~~~~~~~~~~~~~

rdma.max
	Một tệp có khóa lồng nhau ghi đọc tồn tại cho tất cả các nhóm
	ngoại trừ root mô tả giới hạn tài nguyên được cấu hình hiện tại
	cho thiết bị RDMA/IB.

Các dòng được khóa theo tên thiết bị và không được sắp xếp theo thứ tự.
	Mỗi dòng chứa tên tài nguyên được phân tách bằng dấu cách và cấu hình của nó
	giới hạn có thể được phân phối.

Các khóa lồng nhau sau đây được xác định.

==========================================
	  hca_handle Số lượng tay cầm HCA tối đa
	  hca_object Số lượng đối tượng HCA tối đa
	  ==========================================

Một ví dụ cho thiết bị mlx4 và ocrdma sau::

mlx4_0 hca_handle=2 hca_object=2000
	  ocrdma1 hca_handle=3 hca_object=max

rdma.current
	Tệp chỉ đọc mô tả việc sử dụng tài nguyên hiện tại.
	Nó tồn tại cho tất cả các nhóm ngoại trừ root.

Một ví dụ cho thiết bị mlx4 và ocrdma sau::

mlx4_0 hca_handle=1 hca_object=20
	  ocrdma1 hca_handle=1 hca_object=23

DMEM
----

Bộ điều khiển "dmem" điều chỉnh việc phân phối và tính toán
vùng bộ nhớ thiết bị. Bởi vì mỗi vùng bộ nhớ có thể có kích thước trang riêng,
không nhất thiết phải bằng kích thước trang hệ thống, đơn vị luôn là byte.

Tệp giao diện DMEM
~~~~~~~~~~~~~~~~~~~~

dmem.max, dmem.min, dmem.low
	Một tệp có khóa lồng nhau ghi đọc tồn tại cho tất cả các nhóm
	ngoại trừ root mô tả giới hạn tài nguyên được cấu hình hiện tại
	cho một khu vực.

Một ví dụ cho xe sau::

drm/0000:03:00.0/vram0 1073741824
	  drm/0000:03:00.0/bị đánh cắp tối đa

Ngữ nghĩa giống như đối với bộ điều khiển nhóm bộ nhớ và
	tính toán theo cách tương tự.

dmem.capacity
	Tệp chỉ đọc mô tả dung lượng vùng tối đa.
	Nó chỉ tồn tại trên cgroup gốc. Không phải tất cả bộ nhớ đều có thể
	được phân bổ bởi các nhóm, vì kernel dành một phần cho
	sử dụng nội bộ.

Một ví dụ cho xe sau::

drm/0000:03:00.0/vram0 8514437120
	  drm/0000:03:00.0/bị đánh cắp 67108864

dmem.current
	Tệp chỉ đọc mô tả việc sử dụng tài nguyên hiện tại.
	Nó tồn tại cho tất cả các nhóm ngoại trừ root.

Một ví dụ cho xe sau::

drm/0000:03:00.0/vram0 12550144
	  drm/0000:03:00.0/bị đánh cắp 8650752

TLB lớn
-------

Bộ điều khiển HugeTLB cho phép giới hạn mức sử dụng HugeTLB cho mỗi nhóm điều khiển và
thực thi giới hạn của bộ điều khiển khi xảy ra lỗi trang.

Tệp giao diện HugeTLB
~~~~~~~~~~~~~~~~~~~~~~~

Hugetlb.<hugepagesize>.current
	Hiển thị cách sử dụng hiện tại cho Hugetlb "hugepagesize".  Nó tồn tại cho tất cả
	cgroup ngoại trừ root.

Hugetlb.<hugepagesize>.max
	Đặt/hiển thị giới hạn cứng của việc sử dụng Hugetlb "hugepagesize".
	Giá trị mặc định là "tối đa".  Nó tồn tại cho tất cả các nhóm ngoại trừ root.

Hugetlb.<hugepagesize>.events
	Một tệp khóa phẳng chỉ đọc tồn tại trên các nhóm không phải gốc.

tối đa
		Số lần phân bổ không thành công do giới hạn HugeTLB

Hugetlb.<hugepagesize>.events.local
	Tương tự như Hugetlb.<hugepagesize>.events nhưng các trường trong tệp
	là cục bộ của nhóm, tức là không phân cấp. Sự kiện sửa đổi tập tin
	được tạo trên tệp này chỉ phản ánh các sự kiện cục bộ.

Hugetlb.<hugepagesize>.numa_stat
	Tương tự như Memory.numa_stat, nó hiển thị thông tin số của
        trang Hugetlb của <hugepagesize> trong nhóm này.  Chỉ hoạt động trong
        sử dụng các trang Hugetlb được bao gồm.  Các giá trị trên mỗi nút được tính bằng byte.

linh tinh
----

Nhóm linh tinh cung cấp tính năng theo dõi và giới hạn tài nguyên
cơ chế cho các tài nguyên vô hướng không thể trừu tượng hóa như cơ chế khác
tài nguyên của cgroup. Bộ điều khiển được kích hoạt bởi cấu hình CONFIG_CGROUP_MISC
tùy chọn.

Một tài nguyên có thể được thêm vào bộ điều khiển thông qua enum misc_res_type{} trong
include/linux/misc_cgroup.h và tên tương ứng thông qua misc_res_name[]
trong tệp kernel/cgroup/misc.c. Nhà cung cấp tài nguyên phải thiết lập
dung lượng trước khi sử dụng tài nguyên bằng cách gọi misc_cg_set_capacity().

Khi công suất được đặt thì việc sử dụng tài nguyên có thể được cập nhật bằng cách sử dụng phí và
giải phóng API. Tất cả các API để tương tác với bộ điều khiển linh tinh đều có trong
bao gồm/linux/misc_cgroup.h.

Tệp giao diện khác
~~~~~~~~~~~~~~~~~~~~

Bộ điều khiển khác cung cấp 3 tệp giao diện. Nếu hai tài nguyên linh tinh (res_a và res_b) được đăng ký thì:

linh tinh.capacity
        Một tệp khóa phẳng chỉ đọc chỉ hiển thị trong nhóm gốc.  Nó cho thấy
        tài nguyên vô hướng linh tinh có sẵn trên nền tảng cùng với
        số lượng của chúng::

$ cat misc.capacity
	  độ phân giải 50
	  độ phân giải_b 10

linh tinh.current
        Một tệp khóa phẳng chỉ đọc được hiển thị trong tất cả các nhóm.  Nó cho thấy
        việc sử dụng tài nguyên hiện tại trong cgroup và các nhóm con của nó.::

$ mèo linh tinh
	  độ phân giải 3
	  độ phân giải 0

linh tinh.peak
        Một tệp khóa phẳng chỉ đọc được hiển thị trong tất cả các nhóm.  Nó cho thấy
        việc sử dụng tối đa các tài nguyên trong cgroup trong lịch sử và
        trẻ em.::

$ mèo linh tinh.peak
	  độ phân giải 10
	  độ phân giải 8

linh tinh.max
        Một tệp khóa phẳng đọc-ghi được hiển thị trong các nhóm không phải gốc. Được phép
        sử dụng tối đa các tài nguyên trong cgroup và các nhóm con của nó.::

$ mèo linh tinh.max
	  độ phân giải tối đa
	  độ phân giải 4

Giới hạn có thể được thiết lập bởi::

# echo res_a 1 > linh tinh.max

Giới hạn có thể được đặt ở mức tối đa bằng cách::

# echo res_a max > linh tinh.max

Giới hạn có thể được đặt cao hơn giá trị dung lượng trong misc.capacity
        tập tin.

linh tinh.events
	Một tệp khóa phẳng chỉ đọc tồn tại trên các nhóm không phải gốc. các
	các mục sau đây được xác định. Trừ khi có quy định khác, giá trị
	thay đổi trong tệp này sẽ tạo ra một sự kiện sửa đổi tệp. Tất cả các trường trong
	tập tin này được phân cấp.

tối đa
		Số lần sử dụng tài nguyên của cgroup là
		sắp vượt quá giới hạn tối đa.

linh tinh.events.local
        Tương tự như misc.events nhưng các trường trong tệp là cục bộ của
        cgroup tức là không phân cấp. Sự kiện sửa đổi tệp được tạo vào
        tập tin này chỉ phản ánh các sự kiện địa phương.

Di chuyển và quyền sở hữu
~~~~~~~~~~~~~~~~~~~~~~~

Một tài nguyên vô hướng linh tinh được tính cho nhóm mà nó được sử dụng
đầu tiên và được tính phí cho nhóm đó cho đến khi tài nguyên đó được giải phóng. Di chuyển
một quy trình đến một nhóm khác không chuyển phí đến đích
cgroup nơi quá trình đã di chuyển.

Người khác
------

sự kiện hoàn hảo
~~~~~~~~~~

Bộ điều khiển perf_event, nếu không được gắn trên hệ thống phân cấp kế thừa, sẽ là
được kích hoạt tự động trên hệ thống phân cấp v2 để các sự kiện hoàn hảo có thể
luôn được lọc theo đường dẫn cgroup v2.  Bộ điều khiển vẫn có thể
được chuyển sang hệ thống phân cấp kế thừa sau khi hệ thống phân cấp v2 được phổ biến.


Thông tin không chuẩn mực
-------------------------

Phần này chứa thông tin không được coi là một phần của
kernel ổn định API và do đó có thể thay đổi.


Hành vi xử lý nhóm gốc của bộ điều khiển CPU
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Khi phân phối các chu trình CPU trong nhóm gốc, mỗi luồng trong này
cgroup được xử lý như thể nó được lưu trữ trong một nhóm con riêng biệt của
nhóm gốc. Trọng lượng cgroup con này phụ thuộc vào thread của nó
cấp độ.

Để biết chi tiết về ánh xạ này, hãy xem mảng sched_prio_to_weight trong
tệp kernel/sched/core.c (các giá trị từ mảng này phải được chia tỷ lệ
một cách thích hợp để giá trị trung tính - đẹp 0 - là 100 thay vì 1024).


Hành vi quá trình cgroup gốc của bộ điều khiển IO
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Các tiến trình của nhóm gốc được lưu trữ trong một nút con lá ẩn.
Khi phân phối tài nguyên IO, nút con ẩn này được đưa vào
tài khoản như thể nó là một nhóm con bình thường của nhóm gốc với một
giá trị trọng số là 200.


Không gian tên
=========

Khái niệm cơ bản
------

Không gian tên cgroup cung cấp một cơ chế để ảo hóa chế độ xem của
Tệp "/proc/$PID/cgroup" và gắn kết cgroup.  Bản sao CLONE_NEWCGROUP
cờ có thể được sử dụng với clone(2) và unshare(2) để tạo một nhóm mới
không gian tên.  Quá trình chạy bên trong không gian tên cgroup sẽ có
Đầu ra "/proc/$PID/cgroup" của nó bị giới hạn ở gốc cgroupns.  các
cgroupns root là cgroup của tiến trình tại thời điểm tạo
không gian tên cgroup.

Nếu không có không gian tên cgroup, tệp "/proc/$PID/cgroup" sẽ hiển thị
đường dẫn đầy đủ của nhóm của một quá trình.  Trong thiết lập vùng chứa nơi
một tập hợp các nhóm và không gian tên nhằm mục đích cô lập các tiến trình
Tệp "/proc/$PID/cgroup" có thể rò rỉ thông tin cấp hệ thống tiềm năng
đến các quá trình bị cô lập.  Ví dụ::

# cat /proc/self/cgroup
  0::/batchjobs/container_id1

Đường dẫn '/batchjobs/container_id1' có thể được coi là dữ liệu hệ thống
và không mong muốn tiếp xúc với các quá trình bị cô lập.  không gian tên nhóm
có thể được sử dụng để hạn chế khả năng hiển thị của đường dẫn này.  Ví dụ, trước đây
tạo một không gian tên cgroup, người ta sẽ thấy::

# ls -l /proc/self/ns/cgroup
  lrwxrwxrwx 1 gốc gốc 0 2014-07-15 10:37 /proc/self/ns/cgroup -> cgroup:[4026531835]
  # cat /proc/self/cgroup
  0::/batchjobs/container_id1

Sau khi hủy chia sẻ một không gian tên mới, chế độ xem sẽ thay đổi::

# ls -l /proc/self/ns/cgroup
  lrwxrwxrwx 1 gốc gốc 0 2014-07-15 10:35 /proc/self/ns/cgroup -> cgroup:[4026532183]
  # cat /proc/self/cgroup
  0::/

Khi một số luồng từ một tiến trình đa luồng hủy chia sẻ nhóm của nó
không gian tên, các nhóm mới sẽ được áp dụng cho toàn bộ quá trình (tất cả
các chủ đề).  Điều này là tự nhiên đối với hệ thống phân cấp v2; tuy nhiên, đối với
hệ thống phân cấp kế thừa, điều này có thể bất ngờ.

Không gian tên cgroup vẫn tồn tại miễn là có các tiến trình bên trong hoặc
gắn kết ghim nó.  Khi lần sử dụng cuối cùng không còn nữa, cgroup
không gian tên bị phá hủy.  Gốc của cgroupns và các nhóm thực tế
ở lại.


Nguồn gốc và lượt xem
------------------

'Gốc cgroupns' cho một không gian tên cgroup là cgroup trong đó
quá trình gọi unshare(2) đang chạy.  Ví dụ, nếu một tiến trình trong
/batchjobs/container_id1 cgroup gọi hủy chia sẻ, cgroup
/batchjobs/container_id1 trở thành gốc của cgroupns.  Đối với
init_cgroup_ns, đây là nhóm gốc ('/') thực sự.

Nhóm gốc của cgroupns không thay đổi ngay cả khi người tạo không gian tên
quá trình sau đó chuyển sang một nhóm khác::

# ~/unshare -c # unshare các nhóm trong một số nhóm
  # cat /proc/self/cgroup
  0::/
  # mkdir sub_cgrp_1
  # echo 0 > sub_cgrp_1/cgroup.procs
  # cat /proc/self/cgroup
  0::/sub_cgrp_1

Mỗi quy trình có chế độ xem dành riêng cho không gian tên của nó là "/proc/$PID/cgroup"

Các tiến trình chạy bên trong không gian tên cgroup sẽ có thể nhìn thấy
đường dẫn cgroup (trong /proc/self/cgroup) chỉ bên trong nhóm gốc của chúng.
Từ bên trong một nhóm không chia sẻ::

# sleep 100000 &
  [1] 7353
  # echo 7353 > sub_cgrp_1/cgroup.procs
  # cat /proc/7353/cgroup
  0::/sub_cgrp_1

Từ không gian tên cgroup ban đầu, đường dẫn cgroup thực sẽ là
có thể nhìn thấy::

$ mèo /proc/7353/cgroup
  0::/batchjobs/container_id1/sub_cgrp_1

Từ một không gian tên cgroup anh chị em (nghĩa là một không gian tên bắt nguồn từ một
cgroup khác), đường dẫn cgroup liên quan đến cgroup của chính nó
gốc không gian tên sẽ được hiển thị.  Ví dụ: nếu nhóm của PID 7353
gốc không gian tên ở '/batchjobs/container_id2', khi đó nó sẽ thấy::

# cat /proc/7353/cgroup
  0::/../container_id2/sub_cgrp_1

Lưu ý rằng đường dẫn tương đối luôn bắt đầu bằng '/' để chỉ ra rằng
nó liên quan đến gốc không gian tên cgroup của người gọi.


Di cư và định cư(2)
----------------------

Các tiến trình bên trong một namespace cgroup có thể di chuyển vào và ra khỏi
root không gian tên nếu họ có quyền truy cập thích hợp vào các nhóm bên ngoài.  cho
ví dụ, từ bên trong một không gian tên có gốc cgroupns tại
/batchjobs/container_id1 và giả sử rằng hệ thống phân cấp toàn cầu là
vẫn có thể truy cập được bên trong cgroupns::

# cat /proc/7353/cgroup
  0::/sub_cgrp_1
  # echo 7353 > batchjobs/container_id2/cgroup.procs
  # cat /proc/7353/cgroup
  0::/../container_id2

Lưu ý rằng kiểu thiết lập này không được khuyến khích.  Một nhiệm vụ bên trong cgroup
không gian tên chỉ nên được hiển thị theo hệ thống phân cấp cgroupns của chính nó.

setns(2) sang không gian tên cgroup khác được cho phép khi:

(a) quy trình có CAP_SYS_ADMIN dựa trên không gian tên người dùng hiện tại của nó
(b) quy trình có CAP_SYS_ADMIN so với nhóm mục tiêu
    người dùng của không gian tên

Không có thay đổi nhóm tiềm ẩn nào xảy ra khi gắn vào một nhóm khác
không gian tên.  Người ta mong đợi rằng ai đó sẽ di chuyển phần đính kèm
xử lý dưới gốc không gian tên cgroup đích.


Tương tác với các không gian tên khác
---------------------------------

Hệ thống phân cấp nhóm cụ thể của không gian tên có thể được gắn kết bởi một quy trình
chạy bên trong không gian tên cgroup không phải ban đầu::

# mount -t cgroup2 không có $MOUNT_POINT

Điều này sẽ gắn kết hệ thống phân cấp nhóm thống nhất với gốc cgroupns là
gốc hệ thống tập tin.  Quá trình này cần CAP_SYS_ADMIN đối với người dùng của nó và
gắn kết không gian tên.

Việc ảo hóa tệp /proc/self/cgroup kết hợp với việc hạn chế
chế độ xem hệ thống phân cấp cgroup theo không gian tên-private cgroupfs mount
cung cấp chế độ xem nhóm được cách ly đúng cách bên trong vùng chứa.


Thông tin về lập trình hạt nhân
=================================

Phần này chứa thông tin lập trình hạt nhân trong các lĩnh vực
nơi cần tương tác với cgroup.  lõi cgroup và
bộ điều khiển không được bảo hiểm.


Hỗ trợ hệ thống tập tin cho Writeback
--------------------------------

Một hệ thống tập tin có thể hỗ trợ ghi lại cgroup bằng cách cập nhật
address_space_Operations->writepages() để chú thích tiểu sử bằng cách sử dụng
hai chức năng sau.

wbc_init_bio(@wbc, @bio)
	Nên được gọi cho mỗi tiểu sử mang dữ liệu ghi lại và
	liên kết sinh học với nhóm chủ sở hữu của inode và
	hàng đợi yêu cầu tương ứng.  Điều này phải được gọi sau
	một hàng đợi (thiết bị) đã được liên kết với sinh học và
	trước khi nộp.

wbc_account_cgroup_owner(@wbc, @folio, @bytes)
	Nên được gọi cho mỗi phân đoạn dữ liệu được viết ra.
	Mặc dù chức năng này không quan tâm chính xác khi nào nó được gọi
	trong phiên viết lại, đây là cách dễ nhất và hiệu quả nhất
	gọi nó là tự nhiên vì các phân đoạn dữ liệu được thêm vào tiểu sử.

Với chú thích của tiểu sử viết lại, hỗ trợ cgroup có thể được bật cho mỗi
super_block bằng cách đặt SB_I_CGROUPWB trong ->s_iflags.  Điều này cho phép
vô hiệu hóa có chọn lọc hỗ trợ viết lại cgroup, điều này rất hữu ích khi
một số tính năng hệ thống tập tin nhất định, ví dụ: chế độ dữ liệu được ghi nhật ký, là
không tương thích.

wbc_init_bio() liên kết sinh học được chỉ định với nhóm của nó.  Tùy thuộc vào
cấu hình, tiểu sử có thể được thực thi ở mức ưu tiên thấp hơn và nếu
phiên ghi lại đang giữ các tài nguyên được chia sẻ, ví dụ: một tạp chí
mục nhập, có thể dẫn đến đảo ngược mức độ ưu tiên.  Không có một giải pháp dễ dàng nào
cho vấn đề này.  Hệ thống tập tin có thể cố gắng giải quyết vấn đề cụ thể
trường hợp bằng cách bỏ qua wbc_init_bio() và sử dụng bio_assocate_blkg()
trực tiếp.


Các tính năng cốt lõi của v1 không được dùng nữa
===========================

- Nhiều hệ thống phân cấp bao gồm cả những hệ thống được đặt tên không được hỗ trợ.

- Tất cả các tùy chọn gắn kết v1 không được hỗ trợ.

- Tệp "tác vụ" bị xóa và "cgroup.procs" không được sắp xếp.

- "cgroup.clone_children" bị xóa.

- /proc/cgroups là vô nghĩa đối với v2.  Sử dụng "cgroup.controllers" hoặc
  Thay vào đó, các tệp "cgroup.stat" ở thư mục gốc.


Các vấn đề với v1 và cơ sở lý luận cho v2
====================================

Nhiều thứ bậc
--------------------

cgroup v1 cho phép số lượng phân cấp tùy ý và mỗi
hệ thống phân cấp có thể lưu trữ bất kỳ số lượng bộ điều khiển.  Trong khi điều này dường như
cung cấp mức độ linh hoạt cao nhưng nó không hữu ích trong thực tế.

Ví dụ: vì chỉ có một phiên bản của mỗi bộ điều khiển nên tiện ích
loại bộ điều khiển như tủ đông có thể hữu ích trong tất cả
hệ thống phân cấp chỉ có thể được sử dụng trong một.  Vấn đề trở nên trầm trọng hơn bởi
thực tế là bộ điều khiển không thể được chuyển sang hệ thống phân cấp khác một lần
hệ thống phân cấp đã được phổ biến.  Một vấn đề khác là tất cả các bộ điều khiển
bị ràng buộc vào một hệ thống phân cấp buộc phải có cùng một quan điểm về
thứ bậc.  Không thể thay đổi độ chi tiết tùy thuộc vào
bộ điều khiển cụ thể.

Trong thực tế, những vấn đề này đã hạn chế rất nhiều việc bộ điều khiển nào có thể được
đặt trên cùng một hệ thống phân cấp và hầu hết các cấu hình đều dùng đến việc đặt
mỗi bộ điều khiển theo hệ thống phân cấp riêng của nó.  Chỉ những người có quan hệ họ hàng gần gũi, chẳng hạn
là bộ điều khiển cpu và cpuacct, nên được đặt trên cùng một
thứ bậc.  Điều này thường có nghĩa là vùng người dùng cuối cùng phải quản lý nhiều
các hệ thống phân cấp tương tự lặp lại các bước giống nhau trên mỗi hệ thống phân cấp
bất cứ khi nào một hoạt động quản lý phân cấp là cần thiết.

Hơn nữa, việc hỗ trợ nhiều hệ thống phân cấp phải trả giá đắt.
Việc triển khai lõi cgroup rất phức tạp nhưng quan trọng hơn là
sự hỗ trợ cho nhiều hệ thống phân cấp đã hạn chế cách thức hoạt động của cgroup
được sử dụng nói chung và những gì bộ điều khiển có thể làm.

Không có giới hạn về số lượng thứ bậc có thể có, điều đó có nghĩa là
rằng tư cách thành viên nhóm của một chủ đề không thể được mô tả một cách hữu hạn
chiều dài.  Khóa có thể chứa bất kỳ số lượng mục nào và không giới hạn
dài, khiến cho việc thao tác rất khó khăn và dẫn đến
bổ sung các bộ điều khiển chỉ tồn tại để xác định tư cách thành viên,
điều này lại làm trầm trọng thêm vấn đề ban đầu về sự gia tăng số lượng
của các hệ thống thứ bậc.

Ngoài ra, với tư cách là người kiểm soát không thể có bất kỳ kỳ vọng nào về
các cấu trúc liên kết phân cấp mà các bộ điều khiển khác có thể sử dụng, mỗi cấu trúc liên kết
bộ điều khiển phải giả định rằng tất cả các bộ điều khiển khác đều được gắn vào
hệ thống phân cấp hoàn toàn trực giao.  Điều này làm cho nó không thể, hoặc tại
ít nhất là rất cồng kềnh, để các bộ điều khiển hợp tác với nhau.

Trong hầu hết các trường hợp sử dụng, việc đặt bộ điều khiển theo hệ thống phân cấp
hoàn toàn trực giao với nhau là không cần thiết.  Thông thường là gì
được yêu cầu là khả năng có các mức độ chi tiết khác nhau
tùy thuộc vào bộ điều khiển cụ thể.  Nói cách khác, hệ thống phân cấp có thể
được thu gọn từ lá về phía gốc khi nhìn từ một góc cụ thể
bộ điều khiển.  Ví dụ: một cấu hình nhất định có thể không quan tâm đến
cách bộ nhớ được phân phối vượt quá một mức nhất định trong khi vẫn muốn
để kiểm soát cách phân phối chu kỳ CPU.


Độ chi tiết của chủ đề
------------------

cgroup v1 cho phép các luồng của một tiến trình thuộc về các nhóm khác nhau.
Điều này không có ý nghĩa đối với một số bộ điều khiển và những bộ điều khiển đó
cuối cùng đã thực hiện những cách khác nhau để bỏ qua những tình huống như vậy nhưng
quan trọng hơn nhiều là nó làm mờ ranh giới giữa API tiếp xúc với
các ứng dụng riêng lẻ và giao diện quản lý hệ thống.

Nói chung, kiến thức trong quá trình chỉ có sẵn cho quá trình
chính nó; do đó, không giống như việc tổ chức các quy trình ở cấp độ dịch vụ,
phân loại các luồng của một tiến trình đòi hỏi sự tham gia tích cực từ
ứng dụng sở hữu tiến trình đích.

cgroup v1 có mô hình ủy nhiệm được xác định mơ hồ và đã bị lạm dụng
kết hợp với độ chi tiết của luồng.  cgroups được ủy quyền
các ứng dụng riêng lẻ để họ có thể tạo và quản lý các ứng dụng riêng của mình
phân cấp phụ và kiểm soát việc phân phối tài nguyên dọc theo chúng.  Cái này
đã nâng cgroup một cách hiệu quả lên trạng thái API giống như tòa nhà chọc trời
để đặt các chương trình.

Trước hết, cgroup có một giao diện cơ bản không phù hợp để
lộ ra theo cách này.  Để một tiến trình có thể truy cập vào các nút bấm của chính nó, nó phải
trích xuất đường dẫn trên hệ thống phân cấp đích từ /proc/self/cgroup,
xây dựng đường dẫn bằng cách thêm tên của núm vào đường dẫn, mở
và sau đó đọc và/hoặc ghi vào nó.  Điều này không chỉ cực kỳ rắc rối
và khác thường nhưng cũng rất đặc sắc.  Không có cách thông thường nào để
xác định giao dịch qua các bước cần thiết và không có gì có thể đảm bảo
rằng quy trình thực sự sẽ hoạt động trên hệ thống phân cấp phụ của chính nó.

bộ điều khiển cgroup đã triển khai một số nút bấm sẽ không bao giờ có
được chấp nhận dưới dạng API công khai vì chúng chỉ thêm các nút điều khiển vào
hệ thống tập tin giả quản lý hệ thống.  cgroup đã kết thúc với giao diện
các nút bấm không được trừu tượng hóa hoặc tinh chỉnh đúng cách và trực tiếp
tiết lộ chi tiết bên trong hạt nhân.  Những núm này đã tiếp xúc với
các ứng dụng riêng lẻ thông qua cơ chế ủy quyền không xác định
lạm dụng cgroup một cách hiệu quả như một lối tắt để triển khai API công khai
mà không cần phải trải qua sự giám sát cần thiết.

Điều này gây đau đớn cho cả vùng người dùng và kernel.  Userland đã kết thúc với
các giao diện hoạt động sai và kém trừu tượng cũng như việc lộ hạt nhân và
vô tình bị khóa vào các công trình.


Cạnh tranh giữa các nút bên trong và các luồng
-------------------------------------------

cgroup v1 cho phép các luồng nằm trong bất kỳ nhóm nào đã tạo
vấn đề thú vị trong đó các luồng thuộc về một nhóm cha và
các nhóm trẻ em cạnh tranh để giành nguồn lực.  Điều này thật khó chịu như hai
các loại thực thể khác nhau cạnh tranh và không có cách nào rõ ràng để
giải quyết nó.  Bộ điều khiển khác nhau đã làm những việc khác nhau.

Bộ điều khiển CPU coi các luồng và nhóm là tương đương và
ánh xạ các mức tốt đẹp tới trọng số cgroup.  Điều này có tác dụng với một số trường hợp nhưng
thất bại khi trẻ muốn được phân bổ tỷ lệ cụ thể của CPU
chu kỳ và số lượng ren bên trong dao động - tỷ lệ
liên tục thay đổi khi số lượng các thực thể cạnh tranh biến động.
Ngoài ra còn có các vấn đề khác.  Bản đồ từ mức độ đẹp đến trọng lượng
không rõ ràng hoặc phổ quát, và có nhiều nút bấm khác
chỉ đơn giản là không có sẵn cho chủ đề.

Bộ điều khiển io đã ngầm tạo ra một nút lá ẩn cho mỗi
cgroup để lưu trữ các chủ đề.  Chiếc lá ẩn có bản sao riêng của tất cả
các núm có tiền tố ZZ0000ZZ.  Trong khi điều này cho phép tương đương
kiểm soát các luồng nội bộ, nó có những hạn chế nghiêm trọng.  Nó
luôn thêm một lớp lồng bổ sung, điều này không cần thiết
mặt khác, làm cho giao diện trở nên lộn xộn và phức tạp đáng kể
thực hiện.

Bộ điều khiển bộ nhớ không có cách nào để kiểm soát những gì đã xảy ra
giữa các nhiệm vụ nội bộ và các nhóm con và hành vi không
được xác định rõ ràng.  Đã có những nỗ lực bổ sung các hành vi đặc biệt và
các nút điều chỉnh để điều chỉnh hành vi cho phù hợp với khối lượng công việc cụ thể sẽ có
dẫn đến những vấn đề cực kỳ khó giải quyết về lâu dài.

Nhiều bộ điều khiển gặp khó khăn với các nhiệm vụ nội bộ và đưa ra
những cách khác nhau để giải quyết nó; Thật không may, tất cả các cách tiếp cận đều
thiếu sót nghiêm trọng và hơn nữa, những hành vi rất khác nhau
khiến cho toàn bộ cgroup trở nên thiếu nhất quán.

Đây rõ ràng là một vấn đề cần được giải quyết từ cốt lõi cgroup
một cách thống nhất.


Các vấn đề về giao diện khác
----------------------

cgroup v1 phát triển mà không cần giám sát và phát triển một số lượng lớn
những đặc điểm riêng và sự không nhất quán.  Một vấn đề về mặt cốt lõi của cgroup
đó là cách một nhóm trống được thông báo - một tệp nhị phân của trình trợ giúp vùng người dùng là
rẽ nhánh và thực hiện cho mỗi sự kiện.  Việc phân phối sự kiện không được
đệ quy hoặc có thể ủy quyền.  Những hạn chế của cơ chế cũng dẫn đến
đến cơ chế lọc phân phối sự kiện trong hạt nhân làm phức tạp thêm
giao diện.

Giao diện điều khiển cũng có vấn đề.  Một ví dụ cực đoan là
bộ điều khiển hoàn toàn bỏ qua việc tổ chức phân cấp và xử lý
tất cả các nhóm như thể chúng đều nằm ngay dưới thư mục gốc
cgroup.  Một số bộ điều khiển bộc lộ một lượng lớn thông tin không nhất quán
chi tiết triển khai cho vùng người dùng.

Cũng không có sự nhất quán giữa các bộ điều khiển.  Khi có một nhóm mới
đã được tạo, một số bộ điều khiển được mặc định không áp đặt thêm
hạn chế trong khi những hạn chế khác không cho phép sử dụng bất kỳ tài nguyên nào cho đến khi
được cấu hình rõ ràng.  Các nút cấu hình cho cùng loại
control sử dụng các sơ đồ và định dạng đặt tên rất khác nhau.  Thống kê
và các nút thông tin được đặt tên tùy ý và sử dụng các mục đích khác nhau
định dạng và đơn vị ngay cả trong cùng một bộ điều khiển.

cgroup v2 thiết lập các quy ước chung khi thích hợp và cập nhật
bộ điều khiển để chúng hiển thị các giao diện tối thiểu và nhất quán.


Các vấn đề về bộ điều khiển và cách khắc phục
------------------------------

Ký ức
~~~~~~

Ranh giới dưới ban đầu, giới hạn mềm, được xác định là giới hạn
đó là giá trị mặc định không được đặt.  Kết quả là tập hợp các nhóm
ưu tiên đòi lại toàn cầu là chọn tham gia, thay vì chọn không tham gia.  Các chi phí cho
việc tối ưu hóa các tra cứu chủ yếu là tiêu cực này cao đến mức
việc triển khai, mặc dù quy mô rất lớn, thậm chí không cung cấp được
hành vi mong muốn cơ bản.  Trước hết, giới hạn mềm không có
ý nghĩa thứ bậc.  Tất cả các nhóm được cấu hình đều được tổ chức theo kiểu toàn cầu
rbtree và được đối xử như những người ngang hàng bình đẳng, bất kể họ ở đâu
trong hệ thống phân cấp.  Điều này làm cho việc ủy ​​quyền cây con không thể thực hiện được.  Thứ hai,
thẻ lấy lại giới hạn mềm mạnh đến mức nó không chỉ
đưa độ trễ phân bổ cao vào hệ thống, nhưng cũng tác động
hiệu suất hệ thống do được yêu cầu lại quá mức, đến mức tính năng này
trở nên tự đánh bại.

Mặt khác, ranh giới bộ nhớ.low là ranh giới được phân bổ từ trên xuống
dự trữ.  Một nhóm được hưởng quyền đòi lại sự bảo vệ khi nó nằm trong phạm vi
hiệu quả ở mức thấp, điều này làm cho việc ủy quyền các cây con có thể thực hiện được. Nó cũng
thích có áp suất thu hồi tỷ lệ thuận với mức dư thừa của nó khi
trên mức thấp hiệu quả của nó.

Giới hạn cao ban đầu, giới hạn cứng, được định nghĩa là một giới hạn nghiêm ngặt
giới hạn không thể lay chuyển, ngay cả khi phải gọi tên sát thủ OOM.
Nhưng điều này thường đi ngược lại mục tiêu tận dụng tối đa
bộ nhớ có sẵn.  Mức tiêu thụ bộ nhớ của khối lượng công việc thay đổi trong
thời gian chạy và điều đó đòi hỏi người dùng phải cam kết quá mức.  Nhưng làm điều đó với một
giới hạn trên nghiêm ngặt đòi hỏi một dự đoán khá chính xác về
kích thước tập làm việc hoặc thêm độ chùng vào giới hạn.  Kể từ khi kích thước bộ làm việc
việc ước tính là khó khăn và dễ xảy ra sai sót, và việc ước tính sai sẽ dẫn đến
OOM tiêu diệt, hầu hết người dùng có xu hướng mắc sai lầm ở phía giới hạn lỏng lẻo hơn và
cuối cùng lãng phí nguồn tài nguyên quý giá.

Mặt khác, ranh giới bộ nhớ.cao có thể được đặt nhiều hơn nữa
một cách bảo thủ.  Khi bị tấn công, nó sẽ điều tiết việc phân bổ bằng cách buộc chúng
trực tiếp thu hồi để giải quyết phần dư thừa, nhưng nó không bao giờ viện dẫn
Sát thủ OOM.  Kết quả là, một ranh giới cao cũng được chọn
một cách tích cực sẽ không chấm dứt các tiến trình mà thay vào đó nó sẽ
dẫn đến suy giảm hiệu suất dần dần.  Người dùng có thể theo dõi điều này
và thực hiện các chỉnh sửa cho đến khi dung lượng bộ nhớ tối thiểu vẫn còn
cho hiệu suất chấp nhận được được tìm thấy.

Trong những trường hợp đặc biệt, với nhiều sự phân bổ đồng thời và một
sự cố của tiến trình thu hồi trong nhóm, ranh giới cao có thể
được vượt quá.  Nhưng ngay cả khi đó thì tốt hơn hết là thỏa mãn
phân bổ từ phần còn lại có sẵn trong các nhóm khác hoặc phần còn lại của
hệ thống hơn là giết chết nhóm.  Nếu không, Memory.max sẽ ở đó
hạn chế kiểu lan tỏa này và cuối cùng là chứa lỗi hoặc thậm chí
các ứng dụng độc hại.

Đặt bộ nhớ ban đầu.limit_in_bytes dưới mức sử dụng hiện tại là
tùy thuộc vào điều kiện chủng tộc, trong đó các khoản phí đồng thời có thể gây ra
cài đặt giới hạn không thành công. mặt khác, Memory.max trước tiên sẽ thiết lập
giới hạn để ngăn chặn các khoản phí mới, sau đó lấy lại và tiêu diệt OOM cho đến khi
giới hạn mới được đáp ứng - hoặc tác vụ ghi vào bộ nhớ.max bị hủy.

Việc tính toán và giới hạn bộ nhớ + trao đổi kết hợp được thay thế bằng
kiểm soát không gian trao đổi.

Đối số chính cho cơ sở bộ nhớ + trao đổi kết hợp trong bản gốc
thiết kế của cgroup là áp lực toàn cầu hoặc của phụ huynh sẽ luôn là
có thể trao đổi tất cả bộ nhớ ẩn danh của một nhóm con, bất kể
cấu hình riêng của trẻ (có thể không đáng tin cậy).  Tuy nhiên, không đáng tin cậy
các nhóm có thể phá hoại việc trao đổi bằng các cách khác - chẳng hạn như tham khảo
bộ nhớ ẩn danh trong một vòng lặp chặt chẽ - và quản trị viên không thể đảm nhận đầy đủ
khả năng hoán đổi khi thực hiện quá nhiều công việc không đáng tin cậy.

Mặt khác, đối với các công việc đáng tin cậy, bộ đếm kết hợp không phải là một
giao diện không gian người dùng trực quan và nó đi ngược lại ý tưởng
rằng bộ điều khiển cgroup phải tính đến và giới hạn vật lý cụ thể
tài nguyên.  Không gian hoán đổi là một tài nguyên giống như tất cả các tài nguyên khác trong hệ thống,
và đó là lý do tại sao hệ thống phân cấp thống nhất cho phép phân phối nó một cách riêng biệt.
