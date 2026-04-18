.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/mm/numaperf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========================
Hiệu suất bộ nhớ NUMA
=======================

NUMA địa phương
=============

Một số nền tảng có thể có nhiều loại bộ nhớ được gắn vào máy tính
nút. Các phạm vi bộ nhớ khác nhau này có thể có chung một số đặc điểm, chẳng hạn như
như sự kết hợp bộ nhớ đệm CPU, nhưng có thể có hiệu suất khác nhau. Ví dụ,
các loại phương tiện và xe buýt khác nhau ảnh hưởng đến băng thông và độ trễ.

Một hệ thống hỗ trợ bộ nhớ không đồng nhất như vậy bằng cách nhóm từng loại bộ nhớ
trong các miền hoặc "nút" khác nhau, dựa trên vị trí và hiệu suất
đặc điểm.  Một số bộ nhớ có thể chia sẻ cùng một nút với CPU và một số khác
được cung cấp dưới dạng các nút chỉ có bộ nhớ. Trong khi các nút chỉ có bộ nhớ không cung cấp
CPU, chúng vẫn có thể là cục bộ của một hoặc nhiều nút tính toán liên quan đến
các nút khác. Sơ đồ sau đây cho thấy một ví dụ như vậy về hai máy tính
các nút có bộ nhớ cục bộ và một nút chỉ có bộ nhớ cho mỗi nút điện toán ::

+-------------------+ +-------------------+
 ZZ0000ZZ
 ZZ0001ZZ ZZ0002ZZ
 +--------+----------+ +--------+----------+
          ZZ0003ZZ
 +--------+----------+ +--------+----------+
 ZZ0004ZZ ZZ0005ZZ
 +----------+ +--------+----------+

"Bộ khởi tạo bộ nhớ" là một nút chứa một hoặc nhiều thiết bị như
CPU hoặc các thiết bị I/O bộ nhớ riêng biệt có thể khởi tạo các yêu cầu bộ nhớ.
"Mục tiêu bộ nhớ" là một nút chứa một hoặc nhiều địa chỉ vật lý
phạm vi có thể truy cập được từ một hoặc nhiều bộ khởi tạo bộ nhớ.

Khi có nhiều bộ khởi tạo bộ nhớ tồn tại, chúng có thể không giống nhau
hiệu suất khi truy cập vào một mục tiêu bộ nhớ nhất định. Mỗi mục tiêu khởi xướng
cặp có thể được tổ chức thành các lớp truy cập được xếp hạng khác nhau để đại diện cho
mối quan hệ này. Người khởi xướng có hiệu suất cao nhất cho một mục tiêu nhất định
được coi là một trong những người khởi xướng tại địa phương của mục tiêu đó và được đưa ra
lớp truy cập cao nhất, 0. Bất kỳ mục tiêu nào cũng có thể có một hoặc nhiều
người khởi xướng cục bộ và bất kỳ người khởi xướng cụ thể nào cũng có thể có nhiều người khởi tạo cục bộ
mục tiêu bộ nhớ.

Để hỗ trợ các ứng dụng khớp các mục tiêu bộ nhớ với các bộ khởi tạo của chúng,
kernel cung cấp các liên kết tượng trưng cho nhau. Ví dụ sau liệt kê các
mối quan hệ cho các bộ khởi tạo và mục tiêu bộ nhớ lớp truy cập "0" ::

# symlinks -v /sys/devices/system/node/nodeX/access0/targets/
	tương đối: /sys/devices/system/node/nodeX/access0/targets/nodeY -> ../../nodeY

# symlinks -v /sys/devices/system/node/nodeY/access0/initiators/
	tương đối: /sys/devices/system/node/nodeY/access0/initiators/nodeX -> ../../nodeX

Bộ khởi tạo bộ nhớ có thể có nhiều mục tiêu bộ nhớ trong cùng một quyền truy cập
lớp học. Các bộ khởi tạo của bộ nhớ đích trong một lớp nhất định cho biết
đặc điểm truy cập của các nút có cùng hiệu suất so với các nút khác
các nút khởi tạo được liên kết. Mỗi mục tiêu trong lớp truy cập của người khởi tạo,
tuy nhiên, không nhất thiết phải thực hiện giống nhau.

Lớp truy cập "1" được sử dụng để cho phép phân biệt giữa những người khởi tạo
đó là CPU và do đó phù hợp cho việc lập lịch tác vụ chung và
Các bộ khởi tạo IO như GPU và NIC.  Không giống như truy cập lớp 0, chỉ
các nút chứa CPU được xem xét.

Hiệu suất NUMA
================

Các ứng dụng có thể muốn xem xét nút nào chúng muốn bộ nhớ của chúng lưu trữ
được phân bổ dựa trên đặc tính hiệu suất của nút. Nếu
hệ thống cung cấp các thuộc tính này, kernel sẽ xuất chúng theo
phân cấp nút sysfs bằng cách nối thêm thư mục thuộc tính trong thư mục
bộ khởi tạo lớp 0 truy cập của nút bộ nhớ như sau ::

/sys/devices/system/node/nodeY/access0/initiators/

Các thuộc tính này chỉ áp dụng khi được truy cập từ các nút có
được liên kết dưới sự khởi tạo của quyền truy cập này.

Các đặc tính hiệu suất mà kernel cung cấp cho các bộ khởi tạo cục bộ
được xuất khẩu như sau::

# tree -P "read*|write*" /sys/devices/system/node/nodeY/access0/initiators/
	/sys/devices/system/node/nodeY/access0/initiators/
	|-- băng thông đọc
	|-- độ trễ đọc
	|-- write_bandwidth
	`-- độ trễ ghi

Các thuộc tính băng thông được cung cấp tính bằng MiB/giây.

Các thuộc tính độ trễ được cung cấp tính bằng nano giây.

Các giá trị được báo cáo ở đây tương ứng với độ trễ và băng thông định mức
cho nền tảng.

Truy cập lớp 1 có dạng tương tự nhưng chỉ bao gồm các giá trị cho CPU để
hoạt động trí nhớ.

Bộ đệm NUMA
==========

Bộ nhớ hệ thống có thể được xây dựng theo thứ bậc gồm các thành phần với nhiều
đặc tính hiệu suất để cung cấp không gian địa chỉ lớn của
bộ nhớ hoạt động chậm hơn được lưu vào bộ nhớ đệm có hiệu suất cao hơn nhỏ hơn. các
địa chỉ vật lý của hệ thống mà người khởi tạo bộ nhớ biết được đều được cung cấp
theo mức bộ nhớ cuối cùng trong hệ thống phân cấp. Trong khi đó hệ thống sử dụng
bộ nhớ có hiệu suất cao hơn để truy cập bộ nhớ đệm một cách minh bạch
mức độ chậm hơn.

Thuật ngữ "bộ nhớ xa" được sử dụng để biểu thị bộ nhớ cấp cuối cùng trong
thứ bậc. Mỗi mức bộ nhớ đệm tăng dần sẽ mang lại hiệu suất cao hơn
truy cập khởi tạo và thuật ngữ "gần bộ nhớ" thể hiện tốc độ truy cập nhanh nhất
bộ đệm do hệ thống cung cấp.

Việc đánh số này khác với bộ nhớ đệm CPU ở mức độ bộ nhớ đệm (ví dụ:
L1, L2, L3) sử dụng chế độ xem bên CPU trong đó mỗi cấp độ tăng sẽ thấp hơn
biểu diễn. Ngược lại, mức độ bộ nhớ đệm tập trung vào điểm cuối cùng.
cấp độ bộ nhớ, do đó cấp độ bộ đệm được đánh số cao hơn tương ứng với bộ nhớ
gần CPU hơn và xa bộ nhớ xa hơn.

Bộ nhớ đệm phía bộ nhớ không thể được đánh địa chỉ trực tiếp bằng phần mềm. Khi nào
phần mềm truy cập vào địa chỉ hệ thống, hệ thống sẽ trả về địa chỉ đó từ
gần bộ nhớ cache nếu nó có mặt. Nếu nó không tồn tại thì hệ thống
truy cập cấp độ bộ nhớ tiếp theo cho đến khi có một lần truy cập vào cấp độ đó
mức bộ đệm hoặc nó đạt đến bộ nhớ xa.

Một ứng dụng không cần biết về các thuộc tính bộ nhớ đệm để
để sử dụng hệ thống. Phần mềm có thể tùy chọn truy vấn bộ nhớ đệm
các thuộc tính để tối đa hóa hiệu suất của thiết lập như vậy.
Nếu hệ thống cung cấp một cách để kernel khám phá thông tin này,
ví dụ với ACPI HMAT (Bảng thuộc tính bộ nhớ không đồng nhất),
kernel sẽ nối các thuộc tính này vào mục tiêu bộ nhớ của nút NUMA.

Khi kernel đăng ký lần đầu bộ nhớ cache với một nút, kernel
sẽ tạo thư mục sau::

/sys/devices/system/node/nodeX/memory_side_cache/

Nếu thư mục đó không có thì hệ thống cũng không cung cấp
bộ đệm phía bộ nhớ hoặc thông tin đó không thể truy cập được vào kernel.

Các thuộc tính cho từng cấp độ bộ đệm được cung cấp trong bộ đệm của nó
chỉ số cấp độ::

/sys/devices/system/node/nodeX/memory_side_cache/indexA/
	/sys/devices/system/node/nodeX/memory_side_cache/indexB/
	/sys/devices/system/node/nodeX/memory_side_cache/indexC/

Thư mục của mỗi cấp độ bộ đệm cung cấp các thuộc tính của nó. Ví dụ,
phần sau đây hiển thị một cấp độ bộ đệm duy nhất và các thuộc tính có sẵn cho
phần mềm để truy vấn::

# tree /sys/devices/system/node/node0/memory_side_cache/
	/sys/devices/system/node/node0/memory_side_cache/
	|-- chỉ mục1
	ZZ0000ZZ-- lập chỉ mục
	ZZ0001ZZ--line_size
	ZZ0002ZZ-- kích thước
	|   `-- viết_chính sách

"Chỉ mục" sẽ là 0 nếu đó là bộ đệm được ánh xạ trực tiếp và khác 0
cho bất kỳ sự kết hợp đa chiều, dựa trên chỉ mục nào khác.

"line_size" là số byte được truy cập từ bộ đệm tiếp theo
mức độ bỏ lỡ.

"Kích thước" là số byte được cung cấp bởi cấp độ bộ nhớ đệm này.

"write_policy" sẽ là 0 đối với ghi lại và khác 0 đối với
bộ nhớ đệm ghi qua.

Xem thêm
========

[1] ZZ0000ZZ
- Mục 5.2.27
