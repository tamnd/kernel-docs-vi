.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/dm-raid.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================
cuộc đột kích dm
================

Mục tiêu RAID (dm-raid) của trình ánh xạ thiết bị cung cấp cầu nối từ DM đến MD.
Nó cho phép truy cập trình điều khiển MD RAID bằng trình ánh xạ thiết bị
giao diện.


Giao diện bảng ánh xạ
-----------------------
Mục tiêu được đặt tên là "đột kích" và nó chấp nhận các tham số sau::

<raid_type> <#raid_params> <raid_params> \
    <#raid_devs> <metadata_dev0> <dev0> [.. <metadata_devN> <devN>]

<raid_type>:

============== =====================================================================
  sọc raid0 RAID0 (không có khả năng phục hồi)
  phản chiếu raid1 RAID1
  raid4 RAID4 với đĩa chẵn lẻ cuối cùng chuyên dụng
  raid5_n RAID5 với đĩa chẵn lẻ cuối cùng chuyên dụng hỗ trợ tiếp quản từ/đến raid1
		Tương tự như raid4

- Bố trí tạm thời để tiếp quản từ/đến raid1
  raid5_la RAID5 trái không đối xứng

- xoay chẵn lẻ 0 với việc tiếp tục dữ liệu
  raid5_ra RAID5 phải không đối xứng

- luân chuyển chẵn lẻ N với việc tiếp tục dữ liệu
  raid5_ls RAID5 đối xứng trái

- xoay chẵn lẻ 0 khi khởi động lại dữ liệu
  raid5_rs RAID5 đối xứng phải

- xoay chẵn lẻ N khi khởi động lại dữ liệu
  raid6_zr RAID6 không khởi động lại

- xoay số chẵn lẻ bằng 0 (từ trái sang phải) khi khởi động lại dữ liệu
  raid6_nr RAID6 N khởi động lại

- xoay chẵn lẻ N (từ phải sang trái) khi khởi động lại dữ liệu
  raid6_nc RAID6 N tiếp tục

- xoay chẵn lẻ N (từ phải sang trái) với việc tiếp tục dữ liệu
  raid6_n_6 RAID6 với các đĩa chẵn lẻ chuyên dụng

- chẵn lẻ và hội chứng Q trên 2 đĩa cuối;
		  bố trí để tiếp quản từ/đến raid0/raid4/raid5_n
  raid6_la_6 Tương tự như "raid_la" cộng với đĩa hội chứng Q chuyên dụng cuối cùng hỗ trợ tiếp quản từ/đến raid5

- bố trí để tiếp quản từ raid5_la từ/đến raid6
  raid6_ra_6 Tương tự như đĩa "raid5_ra" dành riêng cho hội chứng Q cuối cùng

- bố trí để tiếp quản từ raid5_ra từ/đến raid6
  raid6_ls_6 Tương tự như đĩa "raid5_ls" dành riêng cho hội chứng Q cuối cùng

- bố trí để tiếp quản từ raid5_ls từ/đến raid6
  raid6_rs_6 Tương tự như đĩa "raid5_rs" dành riêng cho hội chứng Q cuối cùng

- bố trí để tiếp quản từ raid5_rs từ/đến raid6
  raid10 Các thuật toán lấy cảm hứng từ RAID10 khác nhau được chọn bởi các thông số bổ sung
		(xem raid10_format và raid10_copies bên dưới)

- RAID10: Gương sọc (hay còn gọi là “Sọc trên gương”)
		- RAID1E: Phản chiếu sọc liền kề tích hợp
		- RAID1E: Phản chiếu sọc bù đắp tích hợp
		- và các biến thể RAID10 tương tự khác
  ============== =====================================================================

Tham khảo: Chương 4 của
  ZZ0000ZZ

<#raid_params>: Số lượng tham số theo sau.

<raid_params> bao gồm

Các thông số bắt buộc:
        <chunk_size>:
		      Kích thước chunk trong các lĩnh vực.  Thông số này thường được gọi là
		      "kích thước sọc".  Đây là tham số bắt buộc duy nhất và
		      được đặt đầu tiên.

theo sau là các tham số tùy chọn (theo thứ tự bất kỳ):
	[đồng bộ|không đồng bộ]
		Buộc hoặc ngăn chặn việc khởi tạo RAID.

[xây dựng lại <idx>]
		Xây dựng lại số ổ đĩa 'idx' (ổ đĩa đầu tiên là 0).

[daemon_ngủ <ms>]
		Khoảng thời gian giữa các lần chạy của daemon bitmap
		bit rõ ràng.  Khoảng thời gian dài hơn có nghĩa là I/O bitmap ít hơn nhưng
		việc đồng bộ lại sau khi bị lỗi có thể sẽ mất nhiều thời gian hơn.

[min_recovery_rate <kB/giây/đĩa>]
		Khởi tạo ga RAID
	[max_recovery_rate <kB/giây/đĩa>]
		Khởi tạo ga RAID
	[write_mostly <idx>]
		Đánh dấu chỉ mục ổ đĩa 'idx' chủ yếu ghi.
	[max_write_behind <sector>]
		Xem '--write-behind=' (man mdadm)
	[stripe_cache <sector>]
		Kích thước bộ đệm sọc (chỉ RAID 4/5/6)
	[kích thước vùng <ngành>]
		Kích thước vùng nhân với số vùng là
		kích thước logic của mảng.  Bitmap ghi lại thiết bị
		trạng thái đồng bộ hóa cho từng khu vực.

[raid10_copies <# copies>], [raid10_format <near|far|offset>]
		Hai tùy chọn này được sử dụng để thay đổi bố cục mặc định của
		cấu hình RAID10.  Số lượng bản sao có thể là
		được chỉ định, nhưng mặc định là 2. Ngoài ra còn có ba
		các biến thể về cách sắp xếp các bản sao - mặc định
		là "gần".  Gần bản sao là những gì hầu hết mọi người nghĩ đến với
		tôn trọng sự phản ánh.  Nếu các tùy chọn này không được chỉ định,
		hoặc 'raid10_copies 2' và/hoặc 'raid10_format gần' được cung cấp,
		thì bố cục cho 2, 3 và 4 thiết bị là:

======== ==========================
		2 ổ 3 ổ 4 ổ
		======== ==========================
		A1 A1 A1 A1 A2 A1 A1 A2 A2
		A2 A2 A2 A3 A3 A3 A3 A4 A4
		A3 A3 A4 A4 A5 A5 A5 A6 A6
		A4 A4 A5 A6 A6 A7 A7 A8 A8
		..  ..           ..  ..  ..        ..  ..  ..  ..
======== ==========================

Cách bố trí 2 thiết bị tương đương RAID1 2 chiều.  4 thiết bị
		bố cục giống như một chiếc RAID10 truyền thống.  các
		Bố cục 3 thiết bị có thể được gọi là 'RAID1E - Tích hợp
		Phản chiếu sọc liền kề'.

Nếu 'raid10_copies 2' và 'raid10_format far' thì bố cục
		cho 2, 3 và 4 thiết bị là:

=========================================
		2 ổ 3 ổ 4 ổ
		=========================================
		A1 A2 A1 A2 A3 A1 A2 A3 A4
		A3 A4 A4 A5 A6 A5 A6 A7 A8
		A5 A6 A7 A8 A9 A9 A10 A11 A12
		..  ..               ..   ..   ..         ..   ..   ..   ..
A2 A1 A3 A1 A2 A2 A1 A4 A3
		A4 A3 A6 A4 A5 A6 A5 A8 A7
		A6 A5 A9 A7 A8 A10 A9 A12 A11
		..  ..               ..   ..   ..         ..   ..   ..   ..
=========================================

Nếu 'raid10_copies 2' và 'độ lệch raid10_format', thì
		bố trí cho 2, 3 và 4 thiết bị là:

=====================================
		2 ổ 3 ổ 4 ổ
		=====================================
		A1 A2 A1 A2 A3 A1 A2 A3 A4
		A2 A1 A3 A1 A2 A2 A1 A4 A3
		A3 A4 A4 A5 A6 A5 A6 A7 A8
		A4 A3 A6 A4 A5 A6 A5 A8 A7
		A5 A6 A7 A8 A9 A9 A10 A11 A12
		A6 A5 A9 A7 A8 A10 A9 A12 A11
		..  ..         ..  ..  ..         ..  ..  ..  ..
=====================================

Ở đây chúng ta thấy bố cục gần giống với 'RAID1E - Tích hợp
		Phản chiếu sọc bù đắp'.

[delta_disks <N>]
		Giá trị tùy chọn delta_disks (-251 < N < +251) kích hoạt
		loại bỏ thiết bị (giá trị âm) hoặc thêm thiết bị (giá trị dương
		value) cho bất kỳ sự thay đổi nào hỗ trợ các cấp độ đột kích 4/5/6 và 10.
		RAID cấp 4/5/6 cho phép thêm và bớt thiết bị
                (siêu dữ liệu và bộ thiết bị dữ liệu), raid10_near và raid10_offset
                chỉ cho phép bổ sung thiết bị. raid10_far không hỗ trợ bất kỳ
		định hình lại chút nào.
		Cần phải giữ lại tối thiểu các thiết bị để tăng cường khả năng phục hồi,
		đó là 3 thiết bị cho raid4/5 và 4 thiết bị cho raid6.

[data_offset <sector>]
		Giá trị tùy chọn này xác định phần bù vào từng thiết bị dữ liệu
		nơi dữ liệu bắt đầu. Điều này được sử dụng để cung cấp ngoài vị trí
		định hình lại không gian để tránh ghi đè lên dữ liệu trong khi
		thay đổi bố cục của các sọc, do đó gây gián đoạn/sự cố
		có thể xảy ra bất cứ lúc nào mà không có nguy cơ mất dữ liệu.
		Ví dụ. khi thêm thiết bị vào nhóm đột kích hiện có trong thời gian
		định hình lại về phía trước, không gian ngoài vị trí sẽ được phân bổ
		ở đầu mỗi thiết bị đột kích. Cuộc đột kích hạt nhân4/5/6/10
		Các cá nhân MD hỗ trợ việc bổ sung thiết bị như vậy sẽ đọc dữ liệu từ
		các sọc đầu tiên hiện có (những sọc có số sọc nhỏ hơn)
		bắt đầu từ data_offset để điền vào một sọc mới với kích thước lớn hơn
		số sọc, tính khối dư thừa (hội chứng CRC/Q)
		và viết sọc mới đó để bù 0. Điều tương tự sẽ được áp dụng cho tất cả
		N-1 sọc mới khác. Sơ đồ không đúng chỗ này được sử dụng để thay đổi
		loại RAID (tức là thuật toán phân bổ), ví dụ:
		thay đổi từ raid5_ls sang raid5_n.

[tạp chí_dev <dev>]
		Tùy chọn này thêm một thiết bị nhật ký vào các nhóm đột kích raid4/5/6 và
		sử dụng nó để đóng 'lỗ ghi' do các bản cập nhật phi nguyên tử gây ra
		tới các thiết bị thành phần có thể gây mất dữ liệu trong quá trình khôi phục.
		Thiết bị nhật ký được sử dụng để ghi qua, do đó khiến việc ghi vào
		được điều chỉnh so với các bộ raid4/5/6 không được ghi nhật ký.
		Không thể tiếp quản/định hình lại bằng thiết bị nhật ký raid4/5/6;
		nó phải được giải cấu hình trước khi yêu cầu những thứ này.

[chế độ tạp chí <chế độ>]
		Tùy chọn này đặt chế độ bộ nhớ đệm trên các nhóm đột kích raid4/5/6 được ghi nhật ký
		(xem 'journal_dev <dev>' ở trên) thành 'writethrough' hoặc 'writeback'.
		Nếu 'writeback' được chọn thì thiết bị nhật ký phải có khả năng phục hồi
		và không được gặp phải vấn đề 'lỗ ghi' (ví dụ: sử dụng
		raid1 hoặc raid10) để tránh một điểm lỗi.

<#raid_devs>: Số lượng thiết bị tạo thành mảng.
	Mỗi thiết bị bao gồm hai mục.  Đầu tiên là thiết bị
	chứa siêu dữ liệu (nếu có); cái thứ hai là cái chứa
	dữ liệu. Hỗ trợ tối đa 64 mục siêu dữ liệu/thiết bị dữ liệu
	lên đến phiên bản mục tiêu 1.8.0.
	1.9.0 hỗ trợ tối đa 253, được thực thi bởi thời gian chạy hạt nhân MD đã sử dụng.

Nếu một ổ đĩa bị lỗi hoặc bị thiếu tại thời điểm tạo, dấu '-' có thể
	được cung cấp cho cả siêu dữ liệu và ổ dữ liệu cho một vị trí nhất định.


Bảng mẫu
--------------

::

# ZZ0000ZZ - 4 ổ dữ liệu, 1 ổ chẵn lẻ (không có thiết bị siêu dữ liệu)
  Các thiết bị siêu dữ liệu # No được chỉ định để chứa thông tin siêu khối/bitmap
  # Chunk kích thước 1MiB
  # (Các dòng được tách ra để dễ đọc)

0 1960893648 đột kích \
          raid4 1 2048 \
          5 - 8:17 - 8:33 - 8:49 - 8:65 - 8:81

# ZZ0000ZZ - 4 ổ dữ liệu, 1 ổ chẵn lẻ (có thiết bị siêu dữ liệu)
  Kích thước # Chunk là 1MiB, buộc khởi tạo RAID,
  Tốc độ phục hồi #       min ở mức 20 kiB/giây/đĩa

0 1960893648 đột kích \
          raid4 4 2048 đồng bộ hóa min_recovery_rate 20 \
          5 8:17 8:18 8:33 8:34 8:49 8:50 8:65 8:66 8:81 8:82


Đầu ra trạng thái
-------------
'Bảng dmsetup' hiển thị bảng được sử dụng để xây dựng ánh xạ.
Các thông số tùy chọn luôn được in theo thứ tự liệt kê
ở trên với "sync" hoặc "nosync" luôn xuất ra trước cái kia
đối số, bất kể thứ tự được sử dụng khi tải bảng ban đầu.
Các đối số có thể lặp lại được sắp xếp theo giá trị.


'trạng thái dmsetup' mang lại thông tin về trạng thái và tình trạng của mảng.
Đầu ra như sau (thường là một dòng, nhưng được mở rộng ở đây cho
sự rõ ràng)::

1: <s> <l> đột kích \
  2: <raid_type> <#devices> <health_chars> \
  3: <sync_ratio> <sync_action> <mismatch_cnt>

Dòng 1 là đầu ra tiêu chuẩn được tạo bởi trình ánh xạ thiết bị.

Dòng 2 & 3 được tạo ra bởi mục tiêu đột kích và được giải thích rõ nhất bằng ví dụ::

0 1960893648 đột kích raid4 5 AAAAA 2/490221568 ban đầu 0

Ở đây chúng ta có thể thấy loại RAID là raid4, có 5 thiết bị - tất cả
là 'A'live và mảng có vị trí 2/490221568 hoàn chỉnh với phần đầu tiên của nó
phục hồi.  Dưới đây là mô tả đầy đủ hơn về các trường riêng lẻ:

==============================================================================
	<raid_type> Tương tự như <raid_type> được sử dụng để tạo mảng.
	<health_chars> Một ký tự cho mỗi thiết bị, cho biết:

- 'A' = sống động và không đồng bộ
			- 'a' = còn hoạt động nhưng không đồng bộ
			- ‘D’ = chết/thất bại.
	<sync_ratio> Tỷ lệ cho biết mảng đã trải qua bao nhiêu phần
			quá trình được mô tả bởi 'sync_action'.  Nếu
			'sync_action' là "kiểm tra" hoặc "sửa chữa", thì quá trình
			"đồng bộ lại" hoặc "khôi phục" có thể được coi là hoàn thành.
	<sync_action> Một trong các trạng thái có thể xảy ra sau đây:

nhàn rỗi
				- Không có hành động đồng bộ hóa nào được thực hiện.
			đông lạnh
				- Hành động hiện tại đã bị dừng lại.
			đồng bộ lại
				- Mảng đang trong quá trình đồng bộ lần đầu
				  hoặc đang đồng bộ hóa lại sau khi tắt máy không sạch sẽ
				  (có thể được hỗ trợ bởi một bitmap).
			phục hồi
				- Một thiết bị trong mảng đang được xây dựng lại hoặc
				  được thay thế.
			kiểm tra
				- Việc kiểm tra toàn bộ mảng do người dùng thực hiện là
				  đang được thực hiện.  Tất cả các khối được đọc và
				  đã kiểm tra tính nhất quán.  Số lượng
				  sự khác biệt được tìm thấy được ghi lại trong
				  <không khớp_cnt>.  Không có thay đổi nào được thực hiện đối với
				  mảng bằng hành động này.
			sửa chữa
				- Giống như "kiểm tra", nhưng có sự khác biệt
				  đã sửa.
			định hình lại
				- Mảng đang được định hình lại.
	<mismatch_cnt> Số lượng khác biệt được tìm thấy giữa các bản sao phản chiếu
			trong RAID1/10 hoặc tìm thấy giá trị chẵn lẻ sai trong RAID4/5/6.
			Giá trị này chỉ hợp lệ sau khi "kiểm tra" mảng
			được thực hiện.  Một mảng lành mạnh có 'mismatch_cnt' bằng 0.
	<data_offset> Dữ liệu hiện tại lệch về điểm bắt đầu của dữ liệu người dùng trên
			mỗi thiết bị thành phần của một nhóm đột kích (xem phần tương ứng
			tham số đột kích để hỗ trợ định hình lại ngoài vị trí).
	<journal_char> - 'A' - thiết bị ghi nhật ký đang hoạt động.
			- 'a' - thiết bị nhật ký ghi lại hoạt động.
			- 'D' - thiết bị nhật ký đã chết.
			- '-' - không có thiết bị nhật ký.
	==============================================================================


Giao diện tin nhắn
-----------------
Mục tiêu dm-raid sẽ chấp nhận một số hành động nhất định thông qua giao diện 'tin nhắn'.
('man dmsetup' để biết thêm thông tin về giao diện tin nhắn.) Những hành động này
bao gồm:

==============================================================
	"nhàn rỗi" Dừng hành động đồng bộ hóa hiện tại.
	"đóng băng" Đóng băng hành động đồng bộ hóa hiện tại.
	"đồng bộ lại" Bắt đầu/tiếp tục đồng bộ lại.
	"recover" Bắt đầu/tiếp tục quá trình khôi phục.
	"kiểm tra" Bắt đầu kiểm tra (tức là "chà") của mảng.
	"sửa chữa" Bắt đầu sửa chữa mảng.
	==============================================================


Hủy hỗ trợ
---------------
Việc triển khai hỗ trợ loại bỏ giữa các nhà cung cấp phần cứng là khác nhau.
Khi một khối bị loại bỏ, một số thiết bị lưu trữ sẽ trả về số 0 khi
khối được đọc.  Các thiết bị này đặt 'discard_zeroes_data'
thuộc tính.  Các thiết bị khác sẽ trả về dữ liệu ngẫu nhiên.  Điều khó hiểu là một số
các thiết bị quảng cáo 'discard_zeroes_data' sẽ không quay trở lại một cách đáng tin cậy
số 0 khi đọc các khối bị loại bỏ!  Vì RAID 4/5/6 sử dụng khối
từ một số thiết bị để tính toán các khối chẵn lẻ và (để thực hiện
lý do) dựa vào 'discard_zeroes_data' là đáng tin cậy, điều quan trọng là
rằng các thiết bị phải nhất quán.  Các khối có thể bị loại bỏ ở giữa
của sọc RAID 4/5/6 và nếu kết quả đọc tiếp theo không
nhất quán, các khối chẵn lẻ có thể được tính toán khác nhau bất cứ lúc nào;
làm cho các khối chẵn lẻ trở nên vô dụng đối với sự dư thừa.  Điều quan trọng là phải
hiểu cách phần cứng của bạn hoạt động với việc loại bỏ nếu bạn định
cho phép loại bỏ với RAID 4/5/6.

Do hoạt động của các thiết bị lưu trữ không đáng tin cậy ở khía cạnh này,
ngay cả khi báo cáo 'discard_zeroes_data', theo mặc định RAID 4/5/6
hỗ trợ loại bỏ bị vô hiệu hóa -- điều này đảm bảo tính toàn vẹn dữ liệu tại
chi phí mất đi một số hiệu suất.

Các thiết bị lưu trữ hỗ trợ đúng cách 'discard_zeroes_data' là
ngày càng được đưa vào danh sách trắng trong kernel và do đó có thể được tin cậy.

Đối với các thiết bị đáng tin cậy, có thể đặt tham số mô-đun dm-raid sau
để kích hoạt hỗ trợ loại bỏ một cách an toàn cho RAID 4/5/6:

'devices_handle_discards_safely'


Hỗ trợ tiếp quản/định hình lại
------------------------
Mục tiêu thực sự hỗ trợ hai loại chuyển đổi MDRAID này:

o Takeover: Chuyển đổi một mảng từ cấp độ RAID này sang cấp độ khác

o Định hình lại: Thay đổi bố cục bên trong trong khi vẫn duy trì mức RAID hiện tại

Mỗi thao tác chỉ hợp lệ trong các ràng buộc cụ thể do bố cục và cấu hình của mảng hiện có áp đặt.


Tiếp quản:
tuyến tính -> raid1 với N >= 2 gương
raid0 -> raid4 (thêm thiết bị chẵn lẻ chuyên dụng)
raid0 -> raid5 (thêm thiết bị chẵn lẻ chuyên dụng)
raid0 -> raid10 với bố cục gần và N >= 2 nhóm gương (sọc raid0 phải trở thành thành viên đầu tiên trong nhóm gương)
đột kích1 -> tuyến tính
raid1 -> raid5 với 2 gương
raid4 -> raid5 w/chẵn lẻ luân phiên
raid5 với thiết bị chẵn lẻ chuyên dụng -> raid4
raid5 -> raid6 (với hội chứng Q chuyên dụng)
raid6 (với hội chứng Q chuyên dụng) -> raid5
raid10 với bố cục gần và số lượng đĩa chẵn -> raid0 (chọn bất kỳ thiết bị không đồng bộ nào từ mỗi nhóm nhân bản)

Định hình lại:
tuyến tính: không thể
đột kích0: không thể
raid1: thay đổi số lượng gương
raid4: thêm và xóa sọc (tối thiểu 3), thay đổi kích thước sọc
raid5: thêm và xóa sọc (tối thiểu 3, trường hợp đặc biệt 2 để tiếp quản raid1), thay đổi thuật toán chẵn lẻ luân phiên, thay đổi kích thước sọc
raid6: thêm và xóa sọc (tối thiểu 4), thay đổi thuật toán hội chứng xoay, thay đổi kích thước sọc
raid10 gần: thêm sọc (tối thiểu 4), thay đổi kích thước sọc, không thể xóa sọc, thay đổi bố cục bù đắp
offset raid10: thêm sọc, thay đổi kích thước sọc, không thể xóa sọc, thay đổi thành bố cục gần
raid10 xa: không thể

Ví dụ về dòng bảng:

### raid1 -> raid5
#
Giới hạn thiết bị # 2 trong raid1.
Tính cách # raid5 chỉ có thể lên đồ 2 như raid1.
# Reshape sau khi tiếp quản để chuyển sang bố cục raid5 đầy đủ

0 1960886272 đột kích raid1 3 0 vùng_size 2048 2 /dev/dm-0 /dev/dm-1 /dev/dm-2 /dev/dm-3

# dm-0 và dm-2 là ví dụ: Các thiết bị siêu dữ liệu lớn 4MiB, dm-1 và dm-3 phải có kích thước tối thiểu là 1960886272.
#
Dòng # Table tiếp quản raid5

0 1960886272 đột kích raid5 3 0 vùng_size 2048 2 /dev/dm-0 /dev/dm-1 /dev/dm-2 /dev/dm-3

# Add yêu cầu không gian định hình lại không đúng chỗ cho phần đầu của 2 thiết bị dữ liệu nhất định,
# allocate một bộ siêu dữ liệu/thiết bị dữ liệu khác có cùng kích thước cho không gian chẵn lẻ
# and zero 4K đầu tiên của thiết bị siêu dữ liệu.
#
Bảng # Example về việc bổ sung không gian định hình lại vị trí ngoài vị trí cho một thiết bị dữ liệu, ví dụ: dm-1

0 8192 tuyến tính 8:0 0 1960903888 # <- phải là đoạn không gian trống
  8192 1960886272 tuyến tính 8:0 0 2048 Phân đoạn dữ liệu # previous

Bảng # Mapping cho ví dụ: việc định hình lại raid5_rs khiến kích thước của thiết bị đột kích tăng gấp đôi sau khi quá trình định hình lại kết thúc.
# Check đầu ra trạng thái (ví dụ: "dmsetup status $RaidDev") để biết tiến trình.

0 $((2 * 1960886272)) đột kích raid5 7 0 vùng_size 2048 data_offset 8192 delta_disk 1 2 /dev/dm-0 /dev/dm-1 /dev/dm-2 /dev/dm-3


Lịch sử phiên bản
---------------

::

1.0.0 Phiên bản đầu tiên.  Hỗ trợ RAID 4/5/6
 1.1.0 Đã thêm hỗ trợ cho RAID 1
 1.2.0 Xử lý việc tạo mảng chứa các thiết bị bị lỗi.
 1.3.0 Đã thêm hỗ trợ cho RAID 10
 1.3.1 Cho phép thay thế/xây dựng lại thiết bị cho RAID 10
 1.3.2 Khắc phục/cải thiện việc kiểm tra dự phòng cho RAID10
 1.4.0 Thay đổi phi chức năng.  Loại bỏ arg khỏi chức năng ánh xạ.
 1.4.1 RAID10 sửa lỗi kiểm tra xác thực dự phòng (cam kết 55ebbb5).
 1.4.2 Thêm hỗ trợ thuật toán RAID10 "xa" và "offset".
 1.5.0 Thêm giao diện tin nhắn để cho phép thao tác với sync_action.
	Các trường trạng thái mới (STATUSTYPE_INFO): sync_action và mismatch_cnt.
 1.5.1 Thêm khả năng khôi phục các thiết bị bị lỗi tạm thời khi tiếp tục.
 1.5.2 'mismatch_cnt' bằng 0 trừ khi [last_]sync_action là "kiểm tra".
 1.6.0 Thêm hỗ trợ loại bỏ (và thông số mô-đun devices_handle_discard_safely).
 1.7.0 Thêm hỗ trợ cho ánh xạ MD RAID0.
 1.8.0 Kiểm tra rõ ràng các cờ tương thích trong siêu dữ liệu siêu khối
	và từ chối bắt đầu tập hợp đột kích nếu có tập hợp này được thiết lập bởi một tập hợp mới hơn
	phiên bản mục tiêu, do đó tránh được dữ liệu bị hỏng trên nhóm đột kích
	với quá trình định hình lại đang diễn ra.
 1.9.0 Thêm hỗ trợ cho việc tiếp quản/định hình lại/kích thước vùng RAID
	và thiết lập giảm kích thước.
 1.9.1 Sửa lỗi kích hoạt các thiết bị được ánh xạ RAID 4/10 hiện có
 1.9.2 Không phát ra '- -' trên dòng bảng trạng thái trong trường hợp hàm tạo
	không đọc được siêu khối. Phát ra chính xác 'maj:min1 maj:min2' và
	'D' trên dòng trạng thái.  Nếu '- -' được truyền vào hàm tạo, hãy phát ra
	'- -' trên dòng bảng và '-' là ký tự tình trạng của dòng trạng thái.
 1.10.0 Thêm hỗ trợ cho thiết bị nhật ký raid4/5/6
 1.10.1 Sửa lỗi dữ liệu khi yêu cầu định hình lại
 1.11.0 Sửa thứ tự đối số dòng trong bảng
	(sai chuỗi raid10_copies/raid10_format)
 1.11.1 Thêm hỗ trợ ghi lại tạp chí raid4/5/6 thông qua tùy chọn Journal_mode
 1.12.1 Có sẵn bản sửa lỗi MD bế tắc giữa mddev_suspend() và md_write_start()
 1.13.0 Sửa trạng thái dev_health ở cuối "recover" (trước đây là 'a', giờ là 'A')
 1.13.1 Khắc phục tình trạng bế tắc do md_stop_writes() sớm gây ra.  Đồng thời sửa kích thước an
	cuộc đua nhà nước.
 1.13.2 Sửa lỗi xác thực dự phòng đột kích và tránh đóng băng nhóm đột kích
 1.14.0 Sửa lỗi định hình lại cuộc đua trên các thiết bị nhỏ.  Sửa sọc thêm hình dạng lại
	bế tắc/tiềm ẩn dữ liệu bị hỏng.  Cập nhật siêu khối khi
	các thiết bị cụ thể được yêu cầu thông qua việc xây dựng lại.  Sửa chân RAID
	xây dựng lại lỗi.
 1.15.0 Sửa lỗi phần mở rộng kích thước không được đồng bộ hóa trong trường hợp bitmap MD mới
        trang được phân bổ;  đồng thời khắc phục những lỗi không xảy ra sau lần giảm trước đó
 1.15.1 Sửa số lượng đối số và đối số cho việc xây dựng lại/write_mostly/journal_(dev|mode)
        trên dòng trạng thái.
