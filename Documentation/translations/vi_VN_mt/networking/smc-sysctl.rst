.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/smc-sysctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============
Hệ thống SMC
============

/proc/sys/net/smc/* Các biến
=============================

autocorking_size - INTEGER
	Cài đặt kích thước nút chai tự động SMC:
	Nút chai tự động SMC giống như nút chai tự động TCP từ ứng dụng
	quan điểm của quan điểm. Khi các ứng dụng làm nhỏ liên tiếp
	lệnh gọi hệ thống write()/sendmsg(), chúng tôi cố gắng kết hợp các lệnh ghi nhỏ này
	càng nhiều càng tốt, để giảm tổng số lượng CDC và RDMA Viết được
	đã gửi.
	autocorking_size giới hạn số byte được đóng nút tối đa có thể được gửi tới
	thiết bị dưới trong 1 lần gửi. Nếu được đặt thành 0, SMC sẽ tự động đóng nút
	bị vô hiệu hóa.
	Các ứng dụng vẫn có thể sử dụng TCP_CORK để có hoạt động tối ưu khi chúng
	biết làm thế nào/khi nào để mở ổ cắm của họ.

Mặc định: 64K

smcr_buf_type - INTEGER
	Kiểm soát loại sdbufs và RMB nào sẽ được sử dụng trong những sản phẩm mới được tạo sau này
	Nhóm liên kết SMC-R. Chỉ dành cho SMC-R.

Mặc định: 0 (sdbufs và RMB liền kề về mặt vật lý)

Các giá trị có thể:

- 0 - Sử dụng bộ đệm liền kề về mặt vật lý
	- 1 - Sử dụng bộ đệm gần như liền kề
	- 2 – Sử dụng hỗn hợp cả hai loại. Trước tiên hãy thử các bộ đệm liền kề về mặt vật lý.
	  Nếu không có sẵn, hãy sử dụng bộ đệm gần như liền kề.

smcr_testlink_time - INTEGER
	Tần suất liên kết SMC-R gửi tin nhắn TEST_LINK LLC để xác nhận
	khả năng tồn tại sau hoạt động cuối cùng của các kết nối trên đó. Giá trị 0 có nghĩa là
	vô hiệu hóa TEST_LINK.

Mặc định: 30 giây.

wmem - INTEGER
	Kích thước ban đầu của bộ đệm gửi được sử dụng bởi ổ cắm SMC.

Giá trị tối thiểu là 16KiB và không có giới hạn cứng cho giá trị tối đa, nhưng
	chỉ cho phép 512KiB đối với SMC-R và 1MiB đối với SMC-D.

Mặc định: 64KiB

rmem - INTEGER
	Kích thước ban đầu của bộ đệm nhận (RMB) được sử dụng bởi ổ cắm SMC.

Giá trị tối thiểu là 16KiB và không có giới hạn cứng cho giá trị tối đa, nhưng
	chỉ cho phép 512KiB đối với SMC-R và 1MiB đối với SMC-D.

Mặc định: 64KiB

smcr_max_links_per_lgr - INTEGER
	Kiểm soát số lượng liên kết tối đa có thể được thêm vào nhóm liên kết SMC-R. Chú ý rằng
	số lượng liên kết thực tế được thêm vào nhóm liên kết SMC-R phụ thuộc vào số lượng
	số thiết bị RDMA tồn tại trong hệ thống. Giá trị được chấp nhận nằm trong khoảng từ 1 đến 2. Chỉ
	dành cho SMC-R v2.1 trở lên.

Mặc định: 2

smcr_max_conns_per_lgr - INTEGER
	Kiểm soát số lượng kết nối tối đa có thể được thêm vào nhóm liên kết SMC-R. các
	giá trị chấp nhận được nằm trong khoảng từ 16 đến 255. Chỉ dành cho SMC-R v2.1 trở lên.

Mặc định: 255

smcr_max_send_wr - INTEGER
	Cái gọi là bộ đệm yêu cầu công việc có cấp độ liên kết SMCR (và cặp hàng đợi RDMA)
	nguồn lực cần thiết để thực hiện các hoạt động RDMA. Kể từ khi lên tới 255
	các kết nối có thể chia sẻ một nhóm liên kết và do đó cũng là một liên kết và số
	của vùng đệm yêu cầu công việc được quyết định khi liên kết được phân bổ,
	tùy thuộc vào khối lượng công việc, nó có thể là một nút cổ chai theo nghĩa các luồng
	phải đợi bộ đệm yêu cầu công việc có sẵn. Trước khi
	giới thiệu điều khiển này số lượng bộ đệm yêu cầu công việc tối đa
	có sẵn trên đường dẫn gửi được mã hóa cứng thành 16. Với điều khiển này
	nó trở nên có thể cấu hình được. Phạm vi chấp nhận được là từ 2 đến 2048.

Xin lưu ý rằng tất cả các bộ đệm cần phải được phân bổ dưới dạng vật lý
	mảng liên tục trong đó mỗi phần tử là một bộ đệm duy nhất và có kích thước
	của SMC_WR_BUF_SIZE (48) byte. Nếu việc phân bổ không thành công, chúng tôi tiếp tục thử lại
	với một nửa số lượng bộ đệm cho đến khi nó thành công hoặc (không chắc)
	chúng tôi giảm xuống dưới giá trị được mã hóa cứng cũ là 16, nơi chúng tôi từ bỏ nhiều
	như trước khi có quyền kiểm soát này.

Mặc định: 16

smcr_max_recv_wr - INTEGER
	Cái gọi là bộ đệm yêu cầu công việc có cấp độ liên kết SMCR (và cặp hàng đợi RDMA)
	nguồn lực cần thiết để thực hiện các hoạt động RDMA. Kể từ khi lên tới 255
	các kết nối có thể chia sẻ một nhóm liên kết và do đó cũng là một liên kết và số
	của vùng đệm yêu cầu công việc được quyết định khi liên kết được phân bổ,
	tùy thuộc vào khối lượng công việc, nó có thể là một nút cổ chai theo nghĩa các luồng
	phải đợi bộ đệm yêu cầu công việc có sẵn. Trước khi
	giới thiệu điều khiển này số lượng bộ đệm yêu cầu công việc tối đa
	có sẵn trên đường dẫn nhận được sử dụng để mã hóa cứng thành 16. Với điều khiển này
	nó trở nên có thể cấu hình được. Phạm vi chấp nhận được là từ 2 đến 2048.

Xin lưu ý rằng tất cả các bộ đệm cần phải được phân bổ dưới dạng vật lý
	mảng liên tục trong đó mỗi phần tử là một bộ đệm duy nhất và có kích thước
	của SMC_WR_BUF_SIZE (48) byte. Nếu việc phân bổ không thành công, chúng tôi tiếp tục thử lại
	với một nửa số lượng bộ đệm cho đến khi nó thành công hoặc (không chắc)
	chúng tôi giảm xuống dưới giá trị được mã hóa cứng cũ là 16, nơi chúng tôi từ bỏ nhiều
	như trước khi có quyền kiểm soát này.

Mặc định: 48

limit_smc_hs - INTEGER
	Có hạn chế bắt tay SMC cho các ổ cắm mới được tạo hay không.

Khi được bật, đường dẫn nghe SMC sẽ áp dụng giới hạn bắt tay dựa trên
	tắc nghẽn công nhân bắt tay và tải bắt tay SMC xếp hàng đợi.

Các giá trị có thể:

- 0 - Tắt giới hạn bắt tay
	- 1 - Bật giới hạn bắt tay

Mặc định: 0 (tắt)

hs_ctrl - STRING
	Chọn cấu hình điều khiển bắt tay SMC theo tên.

Chuỗi này đề cập đến tên của một chương trình do người dùng thực hiện
	Phiên bản BPF struct_ops của loại smc_hs_ctrl.

Cấu hình đã chọn sẽ kiểm soát xem các tùy chọn SMC có được quảng cáo hay không
	trong khi bắt tay TCP SYN/SYN-ACK.

Chỉ khả dụng khi CONFIG_SMC_HS_CTRL_BPF được bật.
	Viết một chuỗi trống để xóa hồ sơ hiện tại.

Mặc định: chuỗi trống