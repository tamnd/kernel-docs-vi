.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/cache.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========
Bộ nhớ đệm
==========

Giới thiệu
============

dm-cache là mục tiêu ánh xạ thiết bị được viết bởi Joe Thornber, Heinz
Mauelshagen và Mike Snitzer.

Nó nhằm mục đích cải thiện hiệu suất của một thiết bị khối (ví dụ: trục xoay) bằng cách
di chuyển động một số dữ liệu sang thiết bị nhỏ hơn, nhanh hơn
(ví dụ: SSD).

Giải pháp ánh xạ thiết bị này cho phép chúng tôi chèn bộ nhớ đệm này vào
các cấp độ khác nhau của ngăn xếp dm, ví dụ như phía trên thiết bị dữ liệu dành cho
một hồ bơi cung cấp mỏng.  Giải pháp bộ nhớ đệm được tích hợp nhiều hơn
chặt chẽ với hệ thống bộ nhớ ảo nên cho hiệu năng tốt hơn.

Mục tiêu sử dụng lại thư viện siêu dữ liệu được sử dụng trong hệ thống cung cấp mỏng
thư viện.

Quyết định về việc di chuyển dữ liệu nào và khi nào để lại cho trình cắm
mô-đun chính sách  Một số trong số này đã được viết khi chúng tôi thử nghiệm,
và chúng tôi hy vọng những người khác sẽ đóng góp cho những vấn đề cụ thể
các tình huống (ví dụ: máy chủ hình ảnh vm).

Thuật ngữ
========

Di chuyển
	       Di chuyển bản sao chính của một khối logic từ một
	       thiết bị này sang thiết bị khác.
  Khuyến mãi
	       Di chuyển từ thiết bị chậm sang thiết bị nhanh.
  giáng chức
	       Di chuyển từ thiết bị nhanh sang thiết bị chậm.

Thiết bị gốc luôn chứa một bản sao của khối logic, khối này
có thể đã lỗi thời hoặc được giữ đồng bộ với bản sao trên thiết bị lưu trữ
(tùy chính sách).

Thiết kế
======

Thiết bị phụ
-----------

Mục tiêu được xây dựng bằng cách chuyển ba thiết bị tới nó (cùng với
các thông số khác chi tiết sau):

1. Thiết bị gốc - thiết bị lớn, chậm.

2. Thiết bị lưu trữ - thiết bị nhỏ, nhanh.

3. Một thiết bị siêu dữ liệu nhỏ - ghi lại các khối trong bộ đệm,
   không rõ ràng và các gợi ý bổ sung để đối tượng chính sách sử dụng.
   Thông tin này có thể được đưa vào thiết bị đệm, nhưng việc có nó
   riêng biệt cho phép trình quản lý âm lượng định cấu hình nó theo cách khác,
   ví dụ: như một tấm gương để tăng thêm sự chắc chắn.  Thiết bị siêu dữ liệu này chỉ có thể
   được sử dụng bởi một thiết bị bộ đệm duy nhất.

Kích thước khối cố định
----------------

Nguồn gốc được chia thành các khối có kích thước cố định.  Kích thước khối này
có thể định cấu hình khi bạn tạo bộ đệm lần đầu tiên.  Thông thường chúng tôi đã
sử dụng kích thước khối 256KB - 1024KB.  Kích thước khối phải nằm trong khoảng 64
các cung (32KB) và 2097152 cung (1GB) và bội số của 64 cung (32KB).

Việc có kích thước khối cố định sẽ đơn giản hóa mục tiêu rất nhiều.  Nhưng nó là
một cái gì đó của một sự thỏa hiệp.  Ví dụ, một phần nhỏ của khối có thể
bị ảnh hưởng nhiều nhưng toàn bộ khối sẽ được đưa vào bộ đệm.
Vì vậy, kích thước khối lớn là không tốt vì chúng lãng phí dung lượng bộ đệm.  Và nhỏ
kích thước khối không tốt vì chúng làm tăng lượng siêu dữ liệu (cả
trong lõi và trên đĩa).

Chế độ hoạt động của bộ đệm
---------------------

Bộ đệm có ba chế độ hoạt động: ghi lại, ghi qua và
đi qua.

Nếu ghi lại, mặc định, được chọn thì ghi vào một khối được
được lưu vào bộ đệm sẽ chỉ được chuyển đến bộ đệm và khối sẽ bị đánh dấu là bẩn trong
siêu dữ liệu.

Nếu chọn ghi qua thì việc ghi vào khối được lưu trong bộ nhớ đệm sẽ không được thực hiện
hoàn thành cho đến khi nó chạm tới cả thiết bị gốc và thiết bị lưu trữ.  Sạch sẽ
khối nên vẫn sạch sẽ.

Nếu chọn chuyển qua, hữu ích khi không biết nội dung bộ đệm
để nhất quán với thiết bị gốc thì tất cả các lần đọc sẽ được cung cấp từ
thiết bị gốc (tất cả các lần đọc đều bỏ qua bộ đệm) và tất cả các lần ghi đều được thực hiện
được chuyển tiếp đến thiết bị gốc; Ngoài ra, ghi lần truy cập gây ra bộ đệm
khối vô hiệu.  Để kích hoạt chế độ chuyển tiếp, bộ đệm phải sạch.
Chế độ truyền qua cho phép thiết bị bộ đệm được kích hoạt mà không cần phải
lo lắng về sự mạch lạc.  Sự gắn kết tồn tại được duy trì, mặc dù
bộ đệm sẽ dần dần nguội khi quá trình ghi diễn ra.  Nếu sự mạch lạc của
bộ đệm sau này có thể được xác minh hoặc thiết lập thông qua việc sử dụng
thông báo "invalidate_cblocks", thiết bị bộ đệm có thể được chuyển sang
chế độ ghi qua hoặc ghi lại khi vẫn còn ấm.  Nếu không, bộ nhớ đệm
nội dung có thể bị loại bỏ trước khi chuyển sang nội dung mong muốn
chế độ vận hành.

Một chính sách dọn dẹp đơn giản được cung cấp, nó sẽ dọn sạch (ghi lại) tất cả
khối bẩn trong bộ đệm.  Hữu ích cho việc ngừng hoạt động bộ nhớ đệm hoặc khi
thu nhỏ bộ đệm.  Thu gọn thiết bị nhanh của bộ đệm yêu cầu tất cả bộ đệm
các khối, trong khu vực bộ đệm được xóa, phải sạch sẽ.  Nếu
khu vực bị xóa khỏi bộ đệm vẫn chứa các khối bẩn thay đổi kích thước
sẽ thất bại.  Phải cẩn thận để không bao giờ giảm âm lượng sử dụng cho
thiết bị nhanh của bộ đệm cho đến khi bộ đệm sạch.  Điều này đặc biệt
quan trọng nếu chế độ ghi lại được sử dụng.  Viết và chuyển qua
các chế độ đã duy trì bộ đệm sạch.  Hỗ trợ trong tương lai để làm sạch một phần
bộ đệm, trên ngưỡng được chỉ định, sẽ cho phép giữ bộ đệm
ấm và ở chế độ ghi lại trong khi thay đổi kích thước.

Điều chỉnh di chuyển
--------------------

Di chuyển dữ liệu giữa thiết bị gốc và thiết bị lưu trữ sử dụng băng thông.
Người dùng có thể đặt van tiết lưu để ngăn chặn nhiều hơn một lượng nhất định
di cư xảy ra tại một thời điểm bất kỳ.  Hiện tại chúng tôi không nhận bất kỳ
lưu lượng truy cập io bình thường đến các thiết bị.  Thêm nhu cầu công việc
làm ở đây để tránh di chuyển trong những thời điểm io cao điểm đó.

Hiện tại, có thông báo "migration_threshold <#sectors>"
có thể được sử dụng để đặt số lượng lĩnh vực tối đa được di chuyển,
mặc định là 2048 cung (1MB).

Cập nhật siêu dữ liệu trên đĩa
-------------------------

Siêu dữ liệu trên đĩa được cam kết mỗi khi viết tiểu sử FLUSH hoặc FUA.
Nếu không có yêu cầu nào như vậy được thực hiện thì các lần xác nhận sẽ diễn ra mỗi giây.  Cái này
có nghĩa là bộ đệm hoạt động giống như một đĩa vật lý có chức năng ghi dễ thay đổi
bộ đệm.  Nếu mất điện, bạn có thể mất một số lần ghi gần đây.  Siêu dữ liệu
phải luôn nhất quán bất chấp mọi sự cố.

Trạng thái 'bẩn' của khối bộ đệm thay đổi quá thường xuyên đối với chúng tôi
để tiếp tục cập nhật nó một cách nhanh chóng.  Vì vậy, chúng tôi coi nó như một gợi ý.  Bình thường
hoạt động nó sẽ được ghi khi thiết bị dm bị treo.  Nếu
hệ thống gặp sự cố, tất cả các khối bộ đệm sẽ bị coi là bẩn khi khởi động lại.

Gợi ý chính sách cho mỗi khối
----------------------

Các plugin chính sách có thể lưu trữ một đoạn dữ liệu trên mỗi khối bộ đệm.  Tùy vào thôi
chính sách này lớn đến mức nào, nhưng nó nên được giữ ở mức nhỏ.  Giống như
cờ bẩn dữ liệu này sẽ bị mất nếu có sự cố nên dự phòng an toàn
giá trị phải luôn luôn có thể.

Gợi ý chính sách ảnh hưởng đến hiệu suất chứ không ảnh hưởng đến tính chính xác.

Thông báo chính sách
----------------

Các chính sách sẽ có những điều chỉnh khác nhau, cụ thể cho từng chính sách, vì vậy chúng tôi
cần một cách chung để nhận và thiết lập những thứ này.  Trình ánh xạ thiết bị
tin nhắn được sử dụng.  Tham khảo cache-policies.txt.

Loại bỏ độ phân giải bitset
-------------------------

Chúng ta có thể tránh sao chép dữ liệu trong quá trình di chuyển nếu chúng ta biết khối đó có
bị loại bỏ.  Một ví dụ điển hình về điều này là khi mkfs loại bỏ
toàn bộ khối thiết bị.  Chúng tôi lưu trữ một bitset theo dõi trạng thái loại bỏ của
khối.  Tuy nhiên, chúng tôi cho phép bitset này có kích thước khối khác
từ các khối bộ đệm.  Điều này là do chúng tôi cần theo dõi việc loại bỏ
trạng thái cho tất cả thiết bị gốc (so sánh với bitset bẩn
chỉ dành cho thiết bị bộ đệm nhỏ hơn).

Giao diện mục tiêu
================

Người xây dựng
-----------

  ::

bộ nhớ đệm <nhà phát triển siêu dữ liệu> <nhà phát triển bộ đệm> <nhà phát triển nguồn gốc> <kích thước khối>
         <#feature tranh luận> [<tính năng tranh luận>]*
         <chính sách> <#policy lập luận> [chính sách lập luận]*

=============================================================================
 siêu dữ liệu nhà phát triển thiết bị nhanh chứa siêu dữ liệu liên tục
 bộ nhớ cache dev thiết bị nhanh đang giữ các khối dữ liệu được lưu trong bộ nhớ cache
 Origin dev chậm thiết bị giữ khối dữ liệu gốc
 kích thước khối kích thước đơn vị bộ đệm trong các lĩnh vực

#feature lập luận số lượng đối số tính năng được thông qua
 feature args writethrough hoặc passthrough (Mặc định là writeback.)

chính sách chính sách thay thế để sử dụng
 #policy lập luận số lượng đối số chẵn tương ứng với
                  cặp khóa/giá trị được chuyển cho chính sách
 chính sách đối số các cặp khóa/giá trị được truyền cho chính sách
		  Ví dụ: 'ngưỡng_tuần tự 1024'
		  Xem cache-policies.txt để biết chi tiết.
 =============================================================================

Đối số tính năng tùy chọn là:


==================================================================================
   ghi qua ghi qua bộ nhớ đệm cấm chặn bộ đệm
			nội dung khác với nội dung khối gốc.
			Không có đối số này, hành vi mặc định là viết
			quay lại nội dung chặn bộ đệm sau này vì lý do hiệu suất,
			vì vậy chúng có thể khác với các khối gốc tương ứng.

chuyển qua một chế độ xuống cấp hữu ích cho sự kết hợp bộ đệm khác nhau
			các tình huống (ví dụ: khôi phục ảnh chụp nhanh của
			lưu trữ cơ bản).	 Đọc và viết luôn đi đến
			nguồn gốc.	Nếu một lần ghi đi đến một nguồn gốc được lưu trong bộ nhớ cache
			chặn thì khối bộ đệm sẽ bị vô hiệu.
			Để kích hoạt chế độ chuyển tiếp, bộ đệm phải sạch.

siêu dữ liệu2 sử dụng phiên bản 2 của siêu dữ liệu.  Cái này lưu trữ đồ bẩn
			các bit trong một btree riêng biệt, giúp cải thiện tốc độ
			tắt bộ đệm.

no_discard_passdown vô hiệu hóa việc loại bỏ khỏi bộ đệm
			tới thiết bị dữ liệu của nguồn gốc.
   ==================================================================================

Chính sách được gọi là 'mặc định' luôn được đăng ký.  Đây là bí danh của
chính sách mà chúng tôi hiện cho rằng đang mang lại hiệu quả tốt nhất.

Vì chính sách mặc định có thể khác nhau giữa các hạt nhân, nếu bạn đang dựa vào
các đặc điểm của một chính sách cụ thể, luôn yêu cầu nó bằng tên.

Trạng thái
------

::

<kích thước khối siêu dữ liệu> <khối siêu dữ liệu #used>/<khối siêu dữ liệu #total>
  <kích thước khối bộ đệm> <khối bộ đệm #used>/<khối bộ đệm #total>
  <#read trúng đích> <#read trúng đích> <#write trúng đích> <#write trượt>
  <#demotions> <#promotions> <#dirty> <#features> <tính năng>*
  <#core đối số> <đối số cốt lõi>* <tên chính sách> <#policy đối số> <đối số chính sách>*
  <chế độ siêu dữ liệu bộ đệm>


====================================================================================
kích thước khối siêu dữ liệu Kích thước khối cố định cho mỗi khối siêu dữ liệu trong
			  lĩnh vực
Khối siêu dữ liệu #used Số khối siêu dữ liệu được sử dụng
Khối siêu dữ liệu #total Tổng số khối siêu dữ liệu
kích thước khối bộ đệm Kích thước khối có thể định cấu hình cho thiết bị bộ đệm
			  trong các lĩnh vực
Khối bộ đệm #used Số khối thường trú trong bộ đệm
Khối bộ đệm #total Tổng số khối bộ đệm
#read truy cập Số lần tiểu sử READ được ánh xạ
			  vào bộ đệm
#read trượt Số lần tiểu sử READ được ánh xạ
			  về nguồn gốc
#write đạt số lần tiểu sử WRITE được ánh xạ
			  vào bộ đệm
#write trượt Số lần tiểu sử WRITE bị trượt
			  ánh xạ tới nguồn gốc
#demotions Số lần một khối bị xóa
			  từ bộ đệm
#promotions Số lần một khối được chuyển đến
			  bộ đệm
#dirty Số khối trong bộ đệm khác nhau
			  từ nguồn gốc
#feature đối số Số lượng đối số tính năng cần tuân theo
tính năng lập luận 'writethrough' (tùy chọn)
#core đối số Số đối số cốt lõi (phải là số chẵn)
core args Cặp khóa/giá trị để điều chỉnh lõi
			  ví dụ: di chuyển_threshold
tên chính sách Tên chính sách
#policy đối số Số đối số chính sách cần tuân theo (phải là số chẵn)
chính sách lập luận Cặp khóa/giá trị, ví dụ: tuần tự_ngưỡng
chế độ siêu dữ liệu bộ đệm ro nếu chỉ đọc, rw nếu đọc-ghi

Trong những trường hợp nghiêm trọng, ngay cả chế độ chỉ đọc cũng bị
			  được coi là không an toàn, I/O sẽ không được phép tiếp tục và
			  trạng thái sẽ chỉ chứa chuỗi 'Không thành công'.
			  Sau đó, các công cụ khôi phục không gian người dùng sẽ được sử dụng.
Needs_check 'needs_check' nếu được đặt, '-' nếu không được đặt
			  Thao tác siêu dữ liệu không thành công, dẫn đến
			  cờ Need_check được đặt trong siêu dữ liệu
			  siêu khối.  Thiết bị siêu dữ liệu phải
			  ngừng hoạt động và kiểm tra/sửa chữa trước khi
			  bộ đệm có thể được thực hiện hoạt động đầy đủ trở lại.
			  '-' cho biết Need_check chưa được đặt.
====================================================================================

Tin nhắn
--------

Các chính sách sẽ có những điều chỉnh khác nhau, cụ thể cho từng chính sách, vì vậy chúng tôi
cần một cách chung để nhận và thiết lập những thứ này.  Trình ánh xạ thiết bị
tin nhắn được sử dụng.  (Cũng có thể có giao diện sysfs.)

Định dạng tin nhắn là::

<khóa> <giá trị>

Ví dụ.::

tin nhắn dmsetup my_cache 0 tuần tự_threshold 1024


Vô hiệu hóa là xóa một mục khỏi bộ đệm mà không ghi nó
trở lại.  Khối bộ đệm có thể bị vô hiệu hóa thông qua không hợp lệ_cblocks
tin nhắn có số lượng phạm vi cblock tùy ý.  Mỗi cblock
giá trị cuối của phạm vi là "một quá khứ", nghĩa là 5-10 thể hiện một phạm vi
có giá trị từ 5 đến 9. Mỗi cblock phải được biểu diễn dưới dạng số thập phân
giá trị, trong tương lai một thông báo biến thể có phạm vi cblock
thể hiện bằng hệ thập lục phân có thể cần thiết để hỗ trợ hiệu quả hơn
vô hiệu hóa các bộ nhớ đệm lớn hơn.  Bộ đệm phải ở chế độ chuyển tiếp
khi không hợp lệ_cblocks được sử dụng ::

không hợp lệ_cblocks [<cblock>|<cblock started>-<cblock end>]*

Ví dụ.::

tin nhắn dmsetup my_cache 0 không hợp lệ_cblocks 2345 3456-4567 5678-6789

Ví dụ
========

Bộ thử nghiệm có thể được tìm thấy ở đây:

ZZ0000ZZ

::

dmsetup tạo my_cache --table '0 41943040 bộ đệm /dev/mapper/metadata \
	  /dev/mapper/ssd /dev/mapper/Origin 512 1 mặc định ghi lại 0'
  dmsetup tạo my_cache --table '0 41943040 bộ đệm /dev/mapper/metadata \
	  /dev/mapper/ssd /dev/mapper/Origin 1024 1 ghi lại \
	  mq 4 tuần tự_threshold 1024 ngẫu nhiên_threshold 8'
