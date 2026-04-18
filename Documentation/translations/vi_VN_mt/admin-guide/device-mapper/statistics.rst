.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/statistics.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============
Thống kê DM
=============

Device Mapper hỗ trợ thu thập số liệu thống kê I/O trên các thiết bị do người dùng xác định
các vùng của thiết bị DM.	 Nếu không có khu vực nào được xác định thì không có số liệu thống kê nào
được thu thập nên không có bất kỳ tác động hiệu suất nào.  Chỉ DM dựa trên sinh học
các thiết bị hiện được hỗ trợ.

Mỗi vùng do người dùng xác định chỉ định một đoạn bắt đầu, độ dài và bước.
Số liệu thống kê riêng lẻ sẽ được thu thập cho từng khu vực có quy mô từng bước trong phạm vi
phạm vi được chỉ định.

Bộ đếm thống kê I/O cho từng khu vực có kích thước theo từng bước của một khu vực là
ở cùng định dạng với ZZ0000ZZ hoặc ZZ0001ZZ (xem:
Tài liệu/admin-guide/iostats.rst).  Nhưng hai quầy phụ (12 và 13)
cung cấp: tổng thời gian dành cho việc đọc và viết.  Khi biểu đồ
đối số được sử dụng, tham số thứ 14 được báo cáo đại diện cho
biểu đồ độ trễ.  Tất cả các bộ đếm này có thể được truy cập bằng cách gửi
thông báo @stats_print tới thiết bị DM thích hợp thông qua dmsetup.

Thời gian được báo cáo tính bằng mili giây và mức độ chi tiết phụ thuộc vào
hạt nhân tích tắc.  Khi tùy chọn Precision_timestamps được sử dụng,
thời gian được báo cáo tính bằng nano giây.

Mỗi khu vực có một mã định danh duy nhất tương ứng mà chúng tôi gọi là
Region_id, được chỉ định khi vùng được tạo.	 Vùng_id
phải được cung cấp khi truy vấn số liệu thống kê về khu vực, xóa
khu vực, v.v. Các khu vực_id duy nhất cho phép nhiều chương trình không gian người dùng
yêu cầu và xử lý số liệu thống kê cho cùng một thiết bị DM mà không cần bước
trên dữ liệu của nhau.

Việc tạo số liệu thống kê DM sẽ phân bổ bộ nhớ thông qua kmalloc hoặc
dự phòng sử dụng không gian vmalloc.  Nhiều nhất là 1/4 tổng thể hệ thống
bộ nhớ có thể được phân bổ theo thống kê DM.  Quản trị viên có thể xem bao nhiêu
bộ nhớ được sử dụng bằng cách đọc:

/sys/module/dm_mod/parameters/stats_current_allocated_bytes

Tin nhắn
========

@stats_create <phạm vi> <bước> [<số_of_tùy chọn_arguments> <tùy chọn_arguments>...] [<program_id> [<aux_data>]]
	Tạo một vùng mới và trả về vùng_id.

<phạm vi>
	  "-"
		toàn bộ thiết bị
	  "<start_sector>+<độ dài>"
		một phạm vi <độ dài> 512 byte
		bắt đầu bằng <start_sector>.

<bước>
	  "<kích thước khu vực>"
		phạm vi được chia thành các khu vực, mỗi khu vực chứa
		<area_size> lĩnh vực.
	  "/<số_của_khu vực>"
		phạm vi được chia thành các chỉ định
		số khu vực.

<số_of_tùy chọn_arguments>
	  Số lượng đối số tùy chọn

<tùy chọn_arguments>
	  Các đối số tùy chọn sau được hỗ trợ:

chính xác_timestamps
		sử dụng bộ đếm thời gian chính xác với độ phân giải nano giây
		thay vì biến "jiffies".  Khi lập luận này được
		được sử dụng, thời gian kết quả tính bằng nano giây thay vì
		mili giây.  Dấu thời gian chính xác chậm hơn một chút
		để có được dấu thời gian dựa trên jiffies.
	  biểu đồ: n1,n2,n3,n4,...
		thu thập biểu đồ độ trễ.  các
		các số n1, n2, v.v. là những thời điểm biểu thị ranh giới
		của biểu đồ.  Nếu Precision_timestamps không được sử dụng,
		thời gian tính bằng mili giây, nếu không thì tính bằng
		nano giây.  Đối với mỗi phạm vi, kernel sẽ báo cáo
		số lượng yêu cầu đã hoàn thành trong phạm vi này. cho
		Ví dụ: nếu chúng ta sử dụng "biểu đồ:10,20,30", kernel sẽ
		báo cáo bốn số a:b:c:d. a là số lượng yêu cầu
		mất 0-10 mili giây để hoàn thành, b là số lượng yêu cầu
		mất 10-20 ms để hoàn thành, c là số lượng yêu cầu
		mất 20-30 ms để hoàn thành và d là số lượng
		các yêu cầu mất hơn 30 mili giây để hoàn thành.

<chương trình_id>
	  Một tham số tùy chọn.  Một cái tên xác định duy nhất
	  chủ sở hữu không gian người dùng của phạm vi.  Nhóm này nằm cùng nhau
	  để các chương trình không gian người dùng có thể xác định phạm vi mà chúng
	  được tạo ra và bỏ qua những thứ do người khác tạo ra.
	  Kernel trả về chuỗi này trong đầu ra của
	  Tin nhắn @stats_list, nhưng nó không sử dụng nó cho bất kỳ mục đích nào khác.
	  Nếu chúng ta bỏ qua số lượng đối số tùy chọn, id chương trình không được
	  là một số, nếu không nó sẽ được hiểu là số lượng
	  đối số tùy chọn.

<aux_data>
	  Một tham số tùy chọn.  Một từ cung cấp dữ liệu phụ trợ
	  điều đó hữu ích cho chương trình khách đã tạo phạm vi đó.
	  Kernel trả về chuỗi này trong đầu ra của
	  Tin nhắn @stats_list, nhưng nó không sử dụng giá trị này cho bất kỳ mục đích nào.

@stats_delete <khu vực_id>
	Xóa vùng có id được chỉ định.

<khu vực_id>
	  vùng_id được trả về từ @stats_create

@stats_clear <khu vực_id>
	Xóa tất cả các bộ đếm ngoại trừ bộ đếm I/O trên chuyến bay.

<khu vực_id>
	  vùng_id được trả về từ @stats_create

@stats_list [<program_id>]
	Liệt kê tất cả các khu vực đã đăng ký với @stats_create.

<chương trình_id>
	  Một tham số tùy chọn.
	  Nếu tham số này được chỉ định thì chỉ các vùng phù hợp
	  được trả lại.
	  Nếu nó không được chỉ định, tất cả các vùng sẽ được trả về.

Định dạng đầu ra:
	  <khu vực_id>: <start_sector>+<length> <step> <program_id> <aux_data>
	        biểu đồ chính xác_thời gian: n1, n2, n3,...

Các chuỗi "precise_timestamps" và "histogram" chỉ được in
	nếu chúng được chỉ định khi tạo vùng.

@stats_print <khu vực_id> [<starting_line> <number_of_lines>]
	Bộ đếm in cho từng khu vực có kích thước từng bước của một khu vực.

<khu vực_id>
	  vùng_id được trả về từ @stats_create

<bắt đầu_line>
	  Chỉ số của dòng bắt đầu trong đầu ra.
	  Nếu bỏ qua, tất cả các dòng sẽ được trả về.

<số_dòng>
	  Số dòng cần đưa vào đầu ra.
	  Nếu bỏ qua, tất cả các dòng sẽ được trả về.

Định dạng đầu ra cho từng khu vực có kích thước theo từng bước của một khu vực:

<start_sector>+<độ dài>
		quầy

11 quầy đầu tiên có ý nghĩa tương tự như
	  ZZ0000ZZ.

Vui lòng tham khảo Tài liệu/admin-guide/iostats.rst để biết chi tiết.

1. số lần đọc hoàn thành
	  2. số lần đọc được hợp nhất
	  3. số lượng lĩnh vực đọc
	  4. số mili giây dành cho việc đọc
	  5. số lần viết hoàn thành
	  6. số lượng ghi được hợp nhất
	  7. số lượng lĩnh vực được viết
	  8. số mili giây dành cho việc viết
	  9. số lượng I/O hiện đang được thực hiện
	  10. số mili giây dành cho việc thực hiện I/O
	  11. số mili giây có trọng số dành cho việc thực hiện I/O

Bộ đếm bổ sung:

12. tổng thời gian đọc tính bằng mili giây
	  13. tổng thời gian viết tính bằng mili giây

@stats_print_clear <khu vực_id> [<starting_line> <number_of_lines>]
	In nguyên tử và sau đó xóa tất cả các bộ đếm ngoại trừ
	quầy I/O trên chuyến bay.	 Hữu ích khi khách hàng sử dụng
	số liệu thống kê không muốn mất bất kỳ số liệu thống kê nào (những số liệu được cập nhật
	giữa in ấn và xóa).

<khu vực_id>
	  vùng_id được trả về từ @stats_create

<bắt đầu_line>
	  Chỉ số của dòng bắt đầu trong đầu ra.
	  Nếu bỏ qua, tất cả các dòng sẽ được in và sau đó bị xóa.

<số_dòng>
	  Số dòng cần xử lý
	  Nếu bỏ qua, tất cả các dòng sẽ được in và sau đó bị xóa.

@stats_set_aux <khu vực_id> <aux_data>
	Lưu trữ dữ liệu phụ trợ aux_data cho vùng được chỉ định.

<khu vực_id>
	  vùng_id được trả về từ @stats_create

<aux_data>
	  Chuỗi xác định dữ liệu hữu ích cho khách hàng
	  chương trình đã tạo ra phạm vi đó.  Kernel trả về cái này
	  chuỗi trở lại trong đầu ra của thông báo @stats_list, nhưng nó
	  không sử dụng giá trị này cho bất cứ điều gì.

Ví dụ
========

Chia thiết bị DM 'vol' thành 100 phần và bắt đầu thu thập
số liệu thống kê về chúng::

tin nhắn dmsetup vol 0 @stats_create - /100

Đặt chuỗi dữ liệu phụ trợ thành "foo bar baz" (thoát cho mỗi chuỗi
không gian cũng phải được thoát, nếu không shell sẽ tiêu thụ chúng)::

tin nhắn dmsetup vol 0 @stats_set_aux 0 foo\\ bar\\ baz

Liệt kê các số liệu thống kê::

tin nhắn dmsetup vol 0 @stats_list

In số liệu thống kê::

tin nhắn dmsetup vol 0 @stats_print 0

Xóa số liệu thống kê::

tin nhắn dmsetup vol 0 @stats_delete 0
