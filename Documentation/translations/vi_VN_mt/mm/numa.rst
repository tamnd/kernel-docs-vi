.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/numa.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Bắt đầu vào tháng 11 năm 1999 bởi Kanoj Sarcar <kanoj@sgi.com>

==============
NUMA là gì?
=============

Câu hỏi này có thể được trả lời từ một số góc độ:
chế độ xem phần cứng và chế độ xem phần mềm Linux.

Từ góc độ phần cứng, hệ thống NUMA là một nền tảng máy tính
bao gồm nhiều thành phần hoặc tập hợp, mỗi thành phần có thể chứa 0
hoặc nhiều CPU, bộ nhớ cục bộ và/hoặc bus IO.  Để ngắn gọn và
phân biệt quan điểm phần cứng của các thành phần/cụm vật lý này
từ sự trừu tượng hóa phần mềm của chúng, chúng ta sẽ gọi các thành phần/tập hợp
'ô' trong tài liệu này.

Mỗi 'ô' có thể được xem dưới dạng tập hợp con SMP [đa bộ xử lý đối xứng]
của hệ thống - mặc dù một số thành phần cần thiết cho hệ thống SMP độc lập
có thể không được điền vào bất kỳ ô nào.   Các ô của hệ thống NUMA là
được kết nối với nhau bằng một số loại kết nối hệ thống - ví dụ: thanh ngang hoặc
liên kết điểm-điểm là các loại kết nối phổ biến của hệ thống NUMA.  Cả hai
các loại kết nối này có thể được tổng hợp để tạo ra nền tảng NUMA với
các tế bào ở nhiều khoảng cách từ các tế bào khác.

Đối với Linux, nền tảng NUMA được quan tâm chủ yếu là cái được gọi là Cache
Hệ thống NUMA hoặc ccNUMA mạch lạc.   Với hệ thống ccNUMA, tất cả bộ nhớ đều hiển thị
tới và có thể truy cập từ bất kỳ CPU nào được gắn vào bất kỳ kết hợp ô và bộ đệm nào
được xử lý trong phần cứng bởi bộ nhớ đệm của bộ xử lý và/hoặc kết nối hệ thống.

Thời gian truy cập bộ nhớ và băng thông bộ nhớ hiệu quả thay đổi tùy thuộc vào khoảng cách
loại bỏ ô chứa bus CPU hoặc IO để truy cập bộ nhớ từ
ô chứa bộ nhớ đích.  Ví dụ: truy cập vào bộ nhớ của CPU
được gắn vào cùng một ô sẽ có thời gian truy cập nhanh hơn và cao hơn
băng thông hơn so với truy cập vào bộ nhớ trên các ô ở xa khác.  Nền tảng NUMA
có thể có các ô ở nhiều khoảng cách xa từ bất kỳ ô nào.

Các nhà cung cấp nền tảng không xây dựng hệ thống NUMA chỉ để thu hút các nhà phát triển phần mềm
sống thú vị.  Đúng hơn, kiến trúc này là một phương tiện để cung cấp khả năng mở rộng
băng thông bộ nhớ.  Tuy nhiên, để đạt được băng thông bộ nhớ có thể mở rộng, hệ thống và
phần mềm ứng dụng phải sắp xếp phần lớn các tham chiếu bộ nhớ
[lỗi bộ nhớ cache] nằm trong bộ nhớ "cục bộ"--bộ nhớ trên cùng một ô, nếu có--hoặc
đến ô gần nhất có bộ nhớ.

Điều này dẫn đến chế độ xem phần mềm Linux của hệ thống NUMA:

Linux chia tài nguyên phần cứng của hệ thống thành nhiều phần mềm
trừu tượng được gọi là "nút".  Linux ánh xạ các nút vào các ô vật lý
của nền tảng phần cứng, trừu tượng hóa một số chi tiết cho một số
kiến trúc.  Giống như các ô vật lý, các nút phần mềm có thể chứa 0 hoặc nhiều hơn
CPU, bộ nhớ và/hoặc bus IO.  Và một lần nữa, bộ nhớ truy cập vào bộ nhớ trên
các nút "gần hơn"--các nút ánh xạ tới các ô gần hơn--thường sẽ gặp phải
thời gian truy cập nhanh hơn và băng thông hiệu quả cao hơn so với truy cập vào nhiều
tế bào ở xa.

Đối với một số kiến trúc, chẳng hạn như x86, Linux sẽ "ẩn" bất kỳ nút nào đại diện cho một
ô vật lý không có bộ nhớ kèm theo và gán lại bất kỳ CPU nào được gắn vào
ô đó đến một nút đại diện cho một ô có bộ nhớ.  Như vậy, trên
những kiến trúc này, người ta không thể cho rằng tất cả các CPU mà Linux liên kết với
một nút nhất định sẽ có cùng thời gian và băng thông truy cập bộ nhớ cục bộ.

Ngoài ra, đối với một số kiến trúc, x86 lại là một ví dụ, Linux hỗ trợ
việc mô phỏng các nút bổ sung.  Để mô phỏng NUMA, linux sẽ khắc phục
các nút hiện có--hoặc bộ nhớ hệ thống cho các nền tảng không phải NUMA--thành nhiều
nút.  Mỗi nút được mô phỏng sẽ quản lý một phần của các ô bên dưới'
bộ nhớ vật lý.  Mô phỏng NUMA rất hữu ích để kiểm tra kernel NUMA và
các tính năng ứng dụng trên nền tảng không phải NUMA và dưới dạng một loại tài nguyên bộ nhớ
cơ chế quản lý khi được sử dụng cùng với cpusets.
[xem Tài liệu/admin-guide/cgroup-v1/cpusets.rst]

Đối với mỗi nút có bộ nhớ, Linux xây dựng một cơ chế quản lý bộ nhớ độc lập
hệ thống con, hoàn chỉnh với danh sách trang miễn phí, danh sách trang đang sử dụng, cách sử dụng
số liệu thống kê và khóa để làm trung gian truy cập.  Ngoài ra, Linux xây dựng cho
mỗi vùng bộ nhớ [một hoặc nhiều DMA, DMA32, NORMAL, HIGH_MEMORY, MOVABLE],
một "zonelist" được ra lệnh.  Danh sách vùng chỉ định các vùng/nút sẽ truy cập khi
vùng/nút đã chọn không thể đáp ứng yêu cầu phân bổ.  Tình trạng này,
khi một vùng không còn bộ nhớ trống để đáp ứng yêu cầu, được gọi
"tràn" hoặc "dự phòng".

Bởi vì một số nút chứa nhiều vùng chứa các loại
bộ nhớ, Linux phải quyết định xem có sắp xếp các danh sách vùng sao cho việc phân bổ
quay trở lại cùng loại vùng trên một nút khác hoặc đến một vùng khác
gõ trên cùng một nút.  Đây là một sự cân nhắc quan trọng bởi vì một số khu vực,
chẳng hạn như DMA hoặc DMA32, đại diện cho các nguồn tài nguyên tương đối khan hiếm.  Linux chọn
một danh sách vùng theo thứ tự Node mặc định. Điều này có nghĩa là nó cố gắng dự phòng sang các vùng khác
từ cùng một nút trước khi sử dụng các nút từ xa được sắp xếp theo khoảng cách NUMA.

Theo mặc định, Linux sẽ cố gắng đáp ứng các yêu cầu cấp phát bộ nhớ từ
nút mà CPU thực hiện yêu cầu được chỉ định.  Cụ thể,
Linux sẽ cố gắng phân bổ từ nút đầu tiên trong danh sách vùng thích hợp
cho nút nơi yêu cầu bắt nguồn.  Điều này được gọi là "phân bổ địa phương."
Nếu nút "cục bộ" không thể đáp ứng yêu cầu, hạt nhân sẽ kiểm tra nút khác
vùng của các nút trong danh sách vùng đã chọn đang tìm kiếm vùng đầu tiên trong danh sách
đó có thể đáp ứng được yêu cầu.

Phân bổ cục bộ sẽ có xu hướng giữ quyền truy cập tiếp theo vào bộ nhớ được phân bổ
"cục bộ" đối với các tài nguyên vật lý cơ bản và kết nối ngoài hệ thống--
miễn là tác vụ mà kernel thay mặt phân bổ một số bộ nhớ không
sau đó di chuyển ra khỏi bộ nhớ đó.  Bộ lập lịch Linux nhận thức được
Cấu trúc liên kết NUMA của nền tảng - được thể hiện trong dữ liệu "miền lập lịch"
cấu trúc [xem Tài liệu/bộ lập lịch/sched-domains.rst]--và bộ lập lịch
cố gắng giảm thiểu việc di chuyển nhiệm vụ sang các miền lập kế hoạch ở xa.  Tuy nhiên,
bộ lập lịch không tính trực tiếp đến dấu chân NUMA của nhiệm vụ.
Do đó, dưới sự mất cân bằng đủ lớn, các tác vụ có thể di chuyển giữa các nút, từ xa
từ cấu trúc dữ liệu nút và hạt nhân ban đầu của chúng.

Quản trị viên hệ thống và nhà thiết kế ứng dụng có thể hạn chế việc di chuyển tác vụ
để cải thiện vị trí NUMA bằng cách sử dụng các giao diện dòng lệnh có quan hệ CPU khác nhau,
chẳng hạn như tasket(1) và numactl(1), và các giao diện chương trình như
lịch_setaffinity(2).  Hơn nữa, người ta có thể sửa đổi địa chỉ cục bộ mặc định của kernel
hành vi phân bổ bằng chính sách bộ nhớ NUMA của Linux. [xem
Tài liệu/admin-guide/mm/numa_memory_policy.rst].

Quản trị viên hệ thống có thể hạn chế bộ nhớ của CPU và nút mà bộ nhớ không
Người dùng đặc quyền có thể chỉ định trong các lệnh và chức năng lập lịch hoặc NUMA
sử dụng các nhóm điều khiển và bộ CPU.  [xem Tài liệu/admin-guide/cgroup-v1/cpusets.rst]

Trên các kiến trúc không ẩn các nút không có bộ nhớ, Linux sẽ chỉ bao gồm
vùng [nút] có bộ nhớ trong danh sách vùng.  Điều này có nghĩa là đối với một người không có trí nhớ
nút "nút bộ nhớ cục bộ"--nút của vùng đầu tiên trong nút của CPU
danh sách vùng--sẽ không phải là nút đó.  Đúng hơn, nó sẽ là nút mà
kernel được chọn làm nút gần nhất có bộ nhớ khi nó xây dựng danh sách vùng.
Vì vậy, mặc định, việc phân bổ cục bộ sẽ thành công với kernel cung cấp
bộ nhớ khả dụng gần nhất.  Đây là hệ quả của cùng một cơ chế
cho phép phân bổ như vậy dự phòng cho các nút lân cận khác khi một nút
có chứa lỗi tràn bộ nhớ.

Một số phân bổ kernel không muốn hoặc không thể chấp nhận dự phòng phân bổ này
hành vi.  Đúng hơn là họ muốn chắc chắn rằng họ nhận được bộ nhớ từ nút được chỉ định
hoặc nhận được thông báo rằng nút không còn bộ nhớ trống.  Điều này thường xảy ra khi
Ví dụ: một hệ thống con phân bổ cho mỗi tài nguyên bộ nhớ CPU.

Một mô hình điển hình để thực hiện phân bổ như vậy là lấy id nút của
nút mà "CPU hiện tại" được gắn vào bằng một trong các hạt nhân
các hàm numa_node_id() hoặc CPU_to_node() và sau đó chỉ yêu cầu bộ nhớ từ
id nút được trả về.  Khi việc phân bổ như vậy không thành công, hệ thống con yêu cầu
có thể trở lại đường dẫn dự phòng của chính nó.  Bộ cấp phát bộ nhớ hạt nhân phiến là một
ví dụ về điều này.  Hoặc hệ thống con có thể chọn tắt hoặc không bật
chính nó về sự thất bại phân bổ.  Hệ thống con định hình hạt nhân là một ví dụ về
cái này.

Nếu kiến trúc hỗ trợ--không ẩn-các nút không có bộ nhớ thì CPU
được gắn vào các nút không có bộ nhớ sẽ luôn phát sinh chi phí đường dẫn dự phòng
hoặc một số hệ thống con sẽ không khởi tạo được nếu chúng cố gắng phân bổ
bộ nhớ độc quyền từ một nút không có bộ nhớ.  Để hỗ trợ như vậy
kiến trúc một cách minh bạch, các hệ thống con kernel có thể sử dụng numa_mem_id()
hoặc hàm cpu_to_mem() để định vị "nút bộ nhớ cục bộ" để gọi hoặc
chỉ định CPU.  Một lần nữa, đây chính là nút mà từ đó trang cục bộ, mặc định
việc phân bổ sẽ được thử.
