.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/nexthop-group-resilient.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Nhóm Next-hop kiên cường
=========================

Các nhóm kiên cường là một loại nhóm tiếp theo nhằm mục đích giảm thiểu
sự gián đoạn trong việc định tuyến luồng khi thay đổi thành phần nhóm và
trọng số của các bước nhảy tiếp theo thành phần.

Ý tưởng đằng sau các nhóm băm linh hoạt được giải thích rõ ràng nhất trái ngược với
nhóm bước nhảy tiếp theo đa đường kế thừa, sử dụng ngưỡng băm
thuật toán, được mô tả trong RFC 2992.

Để chọn bước nhảy tiếp theo, thuật toán ngưỡng băm trước tiên chỉ định một phạm vi
băm vào mỗi bước nhảy tiếp theo trong nhóm và sau đó chọn bước nhảy tiếp theo bằng cách
so sánh hàm băm SKB với các phạm vi riêng lẻ. Khi có bước nhảy tiếp theo
bị xóa khỏi nhóm, các phạm vi sẽ được tính toán lại, dẫn đến
gán lại các phần của không gian băm từ bước nhảy tiếp theo này sang bước nhảy tiếp theo khác. RFC 2992
minh họa nó như sau::

+-------+-------+-------+-------+-------+
             ZZ0000ZZ 2 ZZ0001ZZ 4 ZZ0002ZZ
             +-------+-+------+---+---+------+-+-------+
             ZZ0003ZZ 2 ZZ0004ZZ 5 |
             +--------------+----------+---------+---------+

Trước và sau khi xóa next hop 3
	      theo thuật toán ngưỡng băm.

Lưu ý rằng bước nhảy tiếp theo 2 đã nhường một phần không gian băm để chuyển sang bước nhảy tiếp theo 1,
và 4 ủng hộ 5. Mặc dù thường sẽ có một số điểm trùng lặp giữa
phân phối trước đó và phân phối mới, một số luồng lưu lượng thay đổi bước nhảy tiếp theo
mà họ giải quyết.

Nếu một nhóm đa đường được sử dụng để cân bằng tải giữa nhiều máy chủ,
việc gán lại không gian băm này gây ra sự cố khi gửi các gói từ một
luồng đột nhiên đến một máy chủ không mong đợi chúng. Cái này
có thể khiến các kết nối TCP bị đặt lại.

Nếu một nhóm đa đường được sử dụng để cân bằng tải giữa các đường có sẵn tới
cùng một máy chủ, vấn đề là độ trễ và sự sắp xếp lại khác nhau
cách làm cho các gói đến không đúng thứ tự, dẫn đến
hiệu suất ứng dụng bị suy giảm.

Để giảm thiểu việc chuyển hướng luồng nêu trên, các nhóm bước nhảy tiếp theo linh hoạt
chèn một lớp gián tiếp khác giữa không gian băm và
thành phần bước nhảy tiếp theo: một bảng băm. Thuật toán lựa chọn sử dụng hàm băm SKB
để chọn một nhóm bảng băm, sau đó đọc bước nhảy tiếp theo mà nhóm này
chứa và chuyển tiếp lưu lượng truy cập ở đó.

Sự gián tiếp này mang lại một tính năng quan trọng. Trong ngưỡng băm
thuật toán, phạm vi giá trị băm liên quan đến bước nhảy tiếp theo phải là
liên tục. Với bảng băm, ánh xạ giữa các nhóm bảng băm và
các bước nhảy tiếp theo riêng lẻ là tùy ý. Vì vậy khi bước nhảy tiếp theo bị xóa
các nhóm chứa nó chỉ đơn giản là được gán lại cho các bước nhảy tiếp theo khác ::

+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	    ZZ0000ZZ1ZZ0001ZZ1ZZ0002ZZ2ZZ0003ZZ2ZZ0004ZZ3ZZ0005ZZ3ZZ0006ZZ4ZZ0007ZZ4ZZ0008ZZ5ZZ0009ZZ5|
	    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	                     v v v v
	    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	    ZZ0010ZZ1ZZ0011ZZ1ZZ0012ZZ2ZZ0013ZZ2ZZ0014ZZ2ZZ0015ZZ5ZZ0016ZZ4ZZ0017ZZ4ZZ0018ZZ5ZZ0019ZZ5|
	    +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

Trước và sau khi xóa next hop 3
	    theo thuật toán băm linh hoạt.

Khi trọng số của các bước nhảy tiếp theo trong một nhóm bị thay đổi, có thể
chọn một tập hợp con các nhóm hiện không được sử dụng để chuyển tiếp
lưu lượng truy cập và sử dụng chúng để đáp ứng nhu cầu phân phối bước nhảy tiếp theo mới,
giữ nguyên các thùng "bận". Bằng cách này, các luồng được thiết lập là lý tưởng
tiếp tục được chuyển tiếp đến cùng các điểm cuối thông qua các đường dẫn giống như trước
sự thay đổi của nhóm next-hop.

Thuật toán
---------

Tóm lại, thuật toán hoạt động như sau. Mỗi bước nhảy tiếp theo xứng đáng có một
số lượng xô nhất định, tùy theo trọng lượng của nó và số lượng
các thùng trong bảng băm. Theo mã nguồn, chúng tôi sẽ gọi
con số này là "số lượng mong muốn" của bước nhảy tiếp theo. Trong trường hợp xảy ra sự kiện có thể
gây ra thay đổi phân bổ nhóm, số lượng mong muốn cho từng bước nhảy tiếp theo
được cập nhật.

Các bước nhảy tiếp theo có ít nhóm hơn số lượng mong muốn của chúng, được gọi là
“thiếu cân”. Những người có nhiều hơn là "thừa cân". Nếu không có
thừa cân (và do đó không thiếu cân) bước nhảy tiếp theo trong nhóm, đó là
gọi là “cân bằng”.

Mỗi nhóm duy trì một bộ đếm thời gian được sử dụng lần cuối. Mỗi khi một gói được chuyển tiếp
thông qua một nhóm, bộ đếm thời gian này được cập nhật thành giá trị jiffies hiện tại. một
thuộc tính của một nhóm linh hoạt khi đó là "bộ đếm thời gian nhàn rỗi", là
khoảng thời gian mà một chiếc thùng không được bị va chạm bởi xe cộ để nó có thể
được coi là "nhàn rỗi". Các thùng không nhàn rỗi đang bận.

Sau khi gán số lượng mong muốn cho các bước nhảy tiếp theo, thuật toán "bảo trì" sẽ chạy. cho
xô:

1) không có bước nhảy tiếp theo được chỉ định, hoặc
2) bước nhảy tiếp theo của nó đã bị loại bỏ, hoặc
3) không hoạt động và bước nhảy tiếp theo của họ quá tải,

bảo trì thay đổi bước nhảy tiếp theo mà nhóm tham chiếu đến một trong các
bước nhảy tiếp theo thiếu cân. Nếu sau khi xem xét tất cả các nhóm theo cách này,
vẫn còn những bước nhảy tiếp theo thiếu trọng lượng, một đợt bảo trì khác được lên lịch vào
thời gian trong tương lai.

Có thể không có đủ nhóm "nhàn rỗi" để đáp ứng số lượng mong muốn được cập nhật
của tất cả các bước nhảy tiếp theo. Một thuộc tính khác của một nhóm kiên cường là “sự mất cân bằng
đồng hồ bấm giờ". Bộ hẹn giờ này có thể được đặt thành 0, trong trường hợp đó bàn sẽ không hoạt động
cân bằng cho đến khi các thùng nhàn rỗi xuất hiện, có thể là không bao giờ. Nếu được đặt thành một
giá trị khác 0, giá trị này biểu thị khoảng thời gian mà bảng được
được phép mất cân bằng.

Với suy nghĩ này, chúng tôi cập nhật danh sách các điều kiện ở trên với một điều kiện nữa
mục. Vì vậy, xô:

4) bước nhảy tiếp theo của họ bị thừa cân và lượng thời gian mà bảng có
   bị mất cân bằng vượt quá bộ đếm thời gian không cân bằng, nếu nó khác 0,

\... cũng được di chuyển.

Giảm tải & Phản hồi của trình điều khiển
----------------------------

Khi giảm tải các nhóm linh hoạt, thuật toán phân phối các nhóm
trong số các bước nhảy tiếp theo vẫn là bước nhảy ở SW. Trình điều khiển được thông báo về các bản cập nhật cho
nhóm hop tiếp theo theo ba cách sau:

- Thông báo nhóm đầy đủ với loại
  ZZ0000ZZ. Điều này được sử dụng ngay sau khi nhóm được
  được tạo và các nhóm được điền lần đầu tiên.

- Loại thông báo một nhóm
  ZZ0000ZZ, được sử dụng để thông báo về
  di cư cá nhân trong một nhóm đã được thành lập.

- Thông báo trước khi thay thế, ZZ0000ZZ. Cái này
  được gửi trước khi nhóm được thay thế và là cách để người lái xe phủ quyết
  nhóm trước khi cam kết bất cứ điều gì với HW.

Một số thông báo một nhóm bị ép buộc, như được biểu thị bằng "bắt buộc"
cờ trong thông báo. Chúng được sử dụng cho các trường hợp ví dụ: tiếp theo
hop liên quan đến nhóm đã bị loại bỏ và nhóm thực sự phải được
đã di cư.

Trình điều khiển có thể ghi đè các thông báo không bắt buộc bằng cách trả về một
mã lỗi. Trường hợp sử dụng cho việc này là trình điều khiển thông báo cho CTNH rằng
nhóm nên được di chuyển, nhưng HW phát hiện ra rằng trên thực tế, nhóm có
bị xe cộ tông trúng.

Cách thứ hai để HW báo cáo rằng thùng đang bận là thông qua
ZZ0000ZZ API. Các thùng được xác định theo cách này
bận rộn đều được đối xử như thể bị xe cộ đâm vào.

Các thùng đã giảm tải phải được gắn cờ là "giảm tải" hoặc "bẫy". Đây là
được thực hiện thông qua ZZ0000ZZ API.

Netlink UAPI
------------

Thay thế nhóm kiên cường
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Các nhóm đàn hồi được cấu hình bằng thông báo ZZ0000ZZ trong
cách tương tự như các nhóm đa đường khác. Những thay đổi sau đây áp dụng cho
các thuộc tính được truyền trong thông báo netlink:

==================================================================================
  ZZ0000ZZ Nên là ZZ0001ZZ dành cho nhóm kiên cường.
  ZZ0002ZZ Một tổ chứa các thuộc tính dành riêng cho khả năng phục hồi
                      các nhóm.
  ==================================================================================

Tải trọng ZZ0000ZZ:

=================================================================================
  ZZ0000ZZ Số nhóm trong bảng băm.
  ZZ0001ZZ Hẹn giờ nhàn rỗi tính bằng đơn vị clock_t.
  ZZ0002ZZ Bộ đếm thời gian không cân bằng theo đơn vị clock_t.
  =================================================================================

Bước nhảy tiếp theo Nhận
^^^^^^^^^^^^

Yêu cầu có được các nhóm bước nhảy tiếp theo linh hoạt sử dụng ZZ0000ZZ
nhắn tin theo cách giống hệt như các yêu cầu nhận bước nhảy tiếp theo khác. các
thuộc tính phản hồi khớp với thuộc tính thay thế được trích dẫn ở trên, ngoại trừ
Tải trọng ZZ0001ZZ sẽ bao gồm thuộc tính sau:

=================================================================================
  ZZ0000ZZ Nhóm kiên cường đã ra mắt được bao lâu rồi
                                      cân bằng, tính bằng đơn vị clock_t.
  =================================================================================

Xô Nhận
^^^^^^^^^^

Thông báo ZZ0000ZZ không có cờ ZZ0001ZZ là
được sử dụng để yêu cầu một nhóm duy nhất. Các thuộc tính được nhận dạng khi nhận yêu cầu
là:

==================================================================================
  ZZ0000ZZ ID của nhóm next-hop chứa nhóm đó.
  ZZ0001ZZ Một tổ chứa các thuộc tính dành riêng cho nhóm.
  ==================================================================================

Tải trọng ZZ0000ZZ:

==================================================================================
  ZZ0000ZZ Chỉ số của thùng trong bảng đàn hồi.
  ==================================================================================

Xô đổ
^^^^^^^^^^^^

Thông báo ZZ0000ZZ với cờ ZZ0001ZZ được sử dụng
để yêu cầu kết xuất các nhóm phù hợp. Các thuộc tính được nhận dạng tại bãi chứa
yêu cầu là:

==================================================================================
  ZZ0000ZZ Nếu được chỉ định, giới hạn kết xuất chỉ ở nhóm bước nhảy tiếp theo
                      với ID này.
  ZZ0001ZZ Nếu được chỉ định, hãy giới hạn kết xuất ở các nhóm chứa
                      bước nhảy tiếp theo sử dụng thiết bị có ifindex này.
  ZZ0002ZZ Nếu được chỉ định, hãy giới hạn kết xuất ở các nhóm chứa
                      các bước nhảy tiếp theo sử dụng thiết bị trong VRF với ifindex này.
  ZZ0003ZZ Một tổ chứa các thuộc tính dành riêng cho nhóm.
  ==================================================================================

Tải trọng ZZ0000ZZ:

==================================================================================
  ZZ0000ZZ Nếu được chỉ định, hãy giới hạn kết xuất ở các nhóm
                           chứa bước nhảy tiếp theo với ID này.
  ==================================================================================

Cách sử dụng
-----

Để minh họa cách sử dụng, hãy xem xét các lệnh sau::

# ip nexthop thêm id 1 qua 192.0.2.2 dev eth0
	# ip nexthop thêm id 2 qua 192.0.2.3 dev eth0
	# ip nexthop thêm id 10 nhóm 1/2 loại đàn hồi \
		nhóm 8 không tải_timer 60 không cân bằng_timer 300

Lệnh cuối cùng tạo ra một nhóm next-hop linh hoạt. Nó sẽ có 8 thùng
(là con số thấp bất thường và được sử dụng ở đây nhằm mục đích trình diễn
chỉ), mỗi nhóm sẽ được coi là không hoạt động khi không có lưu lượng truy cập nào truy cập vào nó tại
ít nhất 60 giây và nếu bàn mất cân bằng trong 300 giây,
nó sẽ được đưa vào trạng thái cân bằng một cách mạnh mẽ.

Thay đổi trọng số bước nhảy tiếp theo dẫn đến thay đổi trong phân bổ nhóm::

# ip nexthop thay thế id 10 nhóm 1,3/2 loại đàn hồi

Điều này có thể được xác nhận bằng cách xem xét các nhóm riêng lẻ::

# ip nhóm nexthop hiển thị id 10
	id 10 chỉ số 0 thời gian rảnh 5,59 nhid 1
	id 10 chỉ số 1 nhàn rỗi_time 5,59 nhid 1
	id 10 chỉ số 2 nhàn rỗi_time 8,74 nhid 2
	id 10 chỉ số 3 nhàn rỗi_time 8,74 nhid 2
	id 10 chỉ số 4 nhàn rỗi_time 8,74 nhid 1
	id 10 chỉ số 5 nhàn rỗi_time 8,74 nhid 1
	id 10 chỉ số 6 nhàn rỗi_time 8,74 nhid 1
	id 10 chỉ số 7 nhàn rỗi_time 8,74 nhid 1

Lưu ý hai nhóm có thời gian rảnh ngắn hơn. Đó là những cái mà
đã được di chuyển sau lệnh thay thế bước nhảy tiếp theo để đáp ứng nhu cầu mới
bước nhảy tiếp theo 1 sẽ được cấp 6 thùng thay vì 4.

Netdevsim
---------

Trình điều khiển netdevsim thực hiện mô phỏng giảm tải các nhóm linh hoạt và
hiển thị giao diện debugfs cho phép đánh dấu các nhóm riêng lẻ là bận.
Ví dụ: phần sau đây sẽ đánh dấu nhóm 23 trong nhóm next-hop 10 là
hoạt động::

# echo 10 23 > /sys/kernel/debug/netdevsim/netdevsim10/fib/nexthop_bucket_activity

Ngoài ra, một giao diện debugfs khác có thể được sử dụng để cấu hình
lần thử tiếp theo để di chuyển một nhóm sẽ không thành công::

# echo 1 > /sys/kernel/debug/netdevsim/netdevsim10/fib/fail_nexthop_bucket_replace

Ngoài vai trò là một ví dụ, các giao diện mà netdevsim trưng bày còn có
hữu ích trong thử nghiệm tự động và
ZZ0000ZZ sử dụng
chúng để kiểm tra thuật toán.