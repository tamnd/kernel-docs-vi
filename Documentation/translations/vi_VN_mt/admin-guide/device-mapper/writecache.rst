.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/writecache.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===================
Mục tiêu ghi bộ đệm
=================

Bộ nhớ đệm đích writecache ghi trên bộ nhớ liên tục hoặc trên SSD. Nó
không đọc bộ đệm vì các lần đọc được cho là được lưu trong bộ đệm trang
trong RAM bình thường.

Khi thiết bị được xây dựng, khu vực đầu tiên phải bằng 0 hoặc
khu vực đầu tiên phải chứa siêu khối hợp lệ từ lệnh gọi trước đó.

Các tham số của hàm tạo:

1. loại thiết bị bộ đệm - "p" hoặc "s"
	- p - bộ nhớ liên tục
	-s-SSD
2. thiết bị cơ bản sẽ được lưu trữ
3. thiết bị đệm
4. kích thước khối (khuyến nghị 4096; kích thước khối tối đa là trang
   kích thước)
5. số lượng tham số tùy chọn (các tham số có đối số
   tính là hai)

start_sector n (mặc định: 0)
		bù đắp từ khi bắt đầu thiết bị bộ đệm trong các cung 512 byte
	high_watermark n (mặc định: 50)
		bắt đầu viết lại khi số khối được sử dụng đạt đến mức này
		hình mờ
	low_watermark x (mặc định: 45)
		dừng ghi lại khi số lượng khối được sử dụng giảm xuống dưới
		hình mờ này
	writeback_jobs n (mặc định: không giới hạn)
		giới hạn số lượng khối đang bay trong thời gian
		viết lại. Đặt giá trị này làm giảm việc viết lại
		thông lượng, nhưng nó có thể cải thiện độ trễ của yêu cầu đọc
	autocommit_blocks n (mặc định: 64 cho pmem, 65536 cho ssd)
		khi ứng dụng ghi số lượng khối này mà không
		đưa ra yêu cầu FLUSH, các khối sẽ tự động
		cam kết
	autocommit_time ms (mặc định: 1000)
		thời gian tự động xác nhận tính bằng mili giây. Dữ liệu được tự động
		được cam kết nếu thời gian này trôi qua và không có yêu cầu FLUSH nào được thực hiện
		đã nhận được
	fua (bật theo mặc định)
		chỉ áp dụng cho bộ nhớ liên tục - sử dụng cờ FUA
		khi ghi dữ liệu từ bộ nhớ liên tục trở lại
		thiết bị cơ bản
	nofua
		chỉ áp dụng cho bộ nhớ liên tục - không sử dụng FUA
		gắn cờ khi ghi lại dữ liệu và gửi yêu cầu FLUSH
		sau đó

- một số thiết bị cơ bản hoạt động tốt hơn với fua, một số
		  với nofua. Người dùng nên kiểm tra nó
	sạch hơn
		khi tùy chọn này được kích hoạt (trong hàm tạo
		đối số hoặc bằng tin nhắn), bộ đệm sẽ không quảng bá
		ghi mới (tuy nhiên, ghi vào các khối đã được lưu trong bộ nhớ đệm là
		được quảng bá, để tránh hỏng dữ liệu do sắp xếp sai
		ghi) và nó sẽ dần dần ghi lại mọi dữ liệu được lưu trong bộ nhớ đệm
		dữ liệu. Sau đó, không gian người dùng có thể giám sát việc dọn dẹp
		xử lý với "trạng thái dmsetup". Khi số lượng bộ nhớ đệm
		khối giảm xuống 0, không gian người dùng có thể dỡ bỏ
		mục tiêu dm-writecache và thay thế nó bằng dm-tuyến tính hoặc
		các mục tiêu khác.
	max_age n
		chỉ định tuổi tối đa của một khối tính bằng mili giây. Nếu
		một khối được lưu trữ trong bộ đệm quá lâu, nó sẽ
		được ghi vào thiết bị cơ bản và được dọn sạch.
	chỉ siêu dữ liệu
		chỉ siêu dữ liệu được nâng cấp vào bộ đệm. Tùy chọn này
		cải thiện hiệu suất cho khối lượng công việc REQ_META nặng hơn.
	tạm dừng_writeback n (mặc định: 3000)
		tạm dừng ghi lại nếu có một số I/O ghi được chuyển hướng đến
		âm lượng gốc trong n mili giây cuối cùng

Trạng thái:

1. chỉ báo lỗi - 0 nếu không có lỗi, nếu không thì số lỗi
2. số khối
3. số khối miễn phí
4. số khối được ghi lại
5. số khối đọc
6. số lượng khối đọc chạm vào bộ đệm
7. số lượng khối ghi
8. số lượng khối ghi chạm vào khối không được cam kết
9. số lượng khối ghi chạm vào khối đã cam kết
10. số lượng khối ghi bỏ qua bộ đệm
11. số lượng khối ghi được phân bổ trong bộ đệm
12. số lượng yêu cầu ghi bị chặn trên danh sách tự do
13. số lượng yêu cầu tuôn ra
14. số khối bị loại bỏ

Tin nhắn:
	tuôn ra
		Xóa thiết bị bộ đệm. Tin nhắn trả về thành công
		nếu thiết bị bộ đệm được xóa mà không có lỗi
	tuôn ra_on_suspend
		Xóa thiết bị bộ đệm trong lần tạm dừng tiếp theo. Sử dụng tin nhắn này
		khi bạn định xóa thiết bị bộ đệm. thích hợp
		trình tự để xóa thiết bị bộ đệm là:

1. gửi tin nhắn "flush_on_suspend"
		2. tải một bảng không hoạt động với mục tiêu tuyến tính ánh xạ
		   đến thiết bị cơ bản
		3. treo thiết bị
		4. hỏi trạng thái và xác minh rằng không có lỗi
		5. tiếp tục thiết bị để nó sẽ sử dụng tuyến tính
		   mục tiêu
		6. thiết bị bộ đệm hiện không hoạt động và nó có thể bị xóa
	sạch hơn
		Xem tài liệu về hàm tạo "sạch hơn" ở trên.
	Clear_stats
		Xóa số liệu thống kê được báo cáo trên dòng trạng thái
