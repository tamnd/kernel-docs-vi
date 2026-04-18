.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/nfs/knfsd-stats.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
Thống kê máy chủ Kernel NFS
===============================

:Tác giả: Greg Banks <gnb@sgi.com> - 26/03/2009

Tài liệu này mô tả định dạng và ngữ nghĩa của số liệu thống kê
mà máy chủ NFS kernel cung cấp cho không gian người dùng.  Những cái này
số liệu thống kê có sẵn ở một số tệp giả dạng văn bản, mỗi tệp
được mô tả riêng dưới đây.

Trong hầu hết các trường hợp, bạn không cần phải biết các định dạng này, vì nfsstat(8)
chương trình từ bản phân phối nfs-utils cung cấp một dòng lệnh hữu ích
giao diện để trích xuất và in chúng.

Tất cả các tệp được mô tả ở đây được định dạng dưới dạng một chuỗi các dòng văn bản,
được phân tách bằng ký tự '\n' dòng mới.  Các dòng bắt đầu bằng hàm băm
Ký tự '#' là những nhận xét dành cho con người và nên được bỏ qua
bằng cách phân tích các thói quen.  Tất cả các dòng khác chứa một chuỗi các trường
cách nhau bởi khoảng trắng.

/proc/fs/nfsd/pool_stats
========================

Tệp này có sẵn trong kernel từ 2.6.30 trở đi, nếu
/proc/fs/nfsd hệ thống tập tin được gắn kết (hầu như luôn luôn như vậy).

Dòng đầu tiên là chú thích mô tả các trường có trong
tất cả các dòng khác.  Các dòng khác trình bày dữ liệu sau đây như
một chuỗi các trường số thập phân không dấu.  Một dòng được hiển thị
cho mỗi nhóm luồng NFS.

Tất cả các bộ đếm đều rộng 64 bit và bao bọc một cách tự nhiên.  Không có cách nào
về 0 các bộ đếm này, thay vào đó các ứng dụng sẽ tự thực hiện
chuyển đổi tỷ giá.

hồ bơi
	Số id của nhóm luồng NFS mà dòng này áp dụng.
	Con số này không thay đổi.

Id nhóm luồng là một tập hợp các số nguyên nhỏ liền kề bắt đầu
	ở mức không.  Giá trị tối đa phụ thuộc vào chế độ nhóm luồng, nhưng
	hiện tại không thể lớn hơn số lượng CPU trong hệ thống.
	Lưu ý rằng trong trường hợp mặc định sẽ có một nhóm luồng đơn
	chứa tất cả các luồng nfsd và tất cả CPU trong hệ thống,
	và do đó tệp này sẽ có một dòng duy nhất có id nhóm là "0".

gói-đã đến
	Đếm xem có bao nhiêu gói NFS đã đến.  Chính xác hơn, điều này
	là số lần ngăn xếp mạng đã thông báo cho
	lớp máy chủ sunrpc mà dữ liệu mới có thể có sẵn trên phương tiện truyền tải
	(ví dụ: ổ cắm NFS hoặc UDP hoặc điểm cuối NFS/RDMA).

Tùy thuộc vào mẫu khối lượng công việc NFS và ngăn xếp mạng khác nhau
	các hiệu ứng (chẳng hạn như Giảm tải nhận lớn) có thể kết hợp các gói
	trên dây, giá trị này có thể nhiều hơn hoặc ít hơn số
	số cuộc gọi NFS đã nhận được (thống kê này có sẵn ở nơi khác).
	Tuy nhiên đây là thước đo chính xác hơn và ít phụ thuộc vào khối lượng công việc hơn
	về lượng tải CPU đang được đặt trên lớp máy chủ sunrpc
	do lưu lượng mạng NFS.

hàng đợi ổ cắm
	Đếm số lần một phương tiện vận chuyển NFS được xếp hàng chờ đợi
	một luồng nfsd để phục vụ nó, tức là không có luồng nfsd nào được xem xét
	có sẵn.

Tình huống mà thống kê này theo dõi cho thấy rằng có NFS
	công việc đối mặt với mạng phải được thực hiện nhưng không thể thực hiện ngay lập tức,
	do đó gây ra độ trễ nhỏ trong việc phục vụ các cuộc gọi NFS.  Lý tưởng
	tốc độ thay đổi của bộ đếm này bằng 0; đáng kể khác không
	các giá trị có thể chỉ ra giới hạn hiệu suất.

Điều này có thể xảy ra do có quá ít luồng nfsd trong luồng
	nhóm cho khối lượng công việc NFS (khối lượng công việc bị giới hạn theo luồng), trong đó
	trường hợp cấu hình nhiều luồng nfsd hơn có thể sẽ cải thiện
	hiệu suất của khối lượng công việc NFS.

chủ đề đánh thức
	Đếm số lần một luồng nfsd nhàn rỗi được đánh thức để cố gắng
	nhận một số dữ liệu từ phương tiện truyền tải NFS.

Thống kê này theo dõi tình huống khi đến
	Công việc NFS đối mặt với mạng đang được xử lý nhanh chóng, đây là một điều tốt
	thứ.  Tỷ lệ thay đổi lý tưởng cho bộ đếm này sẽ gần bằng
	nhưng nhỏ hơn tốc độ thay đổi của bộ đếm gói tin đến.

chủ đề hết thời gian chờ
	Đếm số lần một luồng nfsd kích hoạt thời gian chờ không hoạt động,
	tức là không được đánh thức để xử lý bất kỳ gói mạng đến nào cho
	một thời gian.

Thống kê này tính đến trường hợp có nhiều nfsd hơn
	các luồng được định cấu hình có thể được sử dụng bởi khối lượng công việc NFS.  Đây là
	manh mối cho thấy số lượng luồng nfsd có thể giảm đi mà không cần
	ảnh hưởng đến hiệu suất.  Thật không may, đó chỉ là manh mối chứ không phải
	một dấu hiệu mạnh mẽ, vì một vài lý do:

- Hiện nay tốc độ tăng của bộ đếm là khá
	   chậm; thời gian chờ không hoạt động là 60 phút.  Trừ khi khối lượng công việc NFS
	   không đổi trong nhiều giờ liền, bộ đếm này khó có thể xảy ra
	   để cung cấp thông tin vẫn còn hữu ích.

- Thông thường, sẽ là một chính sách khôn ngoan khi cung cấp một chút thời gian,
	   tức là định cấu hình thêm một vài nfsds so với mức cần thiết hiện tại,
	   để cho phép tải tăng đột biến trong tương lai.


Lưu ý rằng các gói đến trên đường truyền NFS sẽ được xử lý theo
một trong ba cách.  Một luồng nfsd có thể được đánh thức (số lượng luồng được đánh thức
trường hợp này), hoặc việc vận chuyển có thể được xếp hàng để được chú ý sau này
(trong trường hợp này số lượng ổ cắm được xếp hàng đợi) hoặc gói có thể tạm thời
bị trì hoãn vì việc vận chuyển hiện đang được sử dụng bởi một nfsd
chủ đề.  Trường hợp cuối cùng này không thú vị lắm và không rõ ràng
được tính, nhưng có thể được suy ra từ các bộ đếm khác::

gói-trì hoãn = gói đã đến - ( sockets-enqueued + thread-woken )


Hơn
====

Mô tả về tệp thống kê khác sẽ có ở đây.
