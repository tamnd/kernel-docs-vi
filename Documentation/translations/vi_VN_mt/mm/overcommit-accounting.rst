.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/overcommit-accounting.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Kế toán vượt mức
=====================

Nhân Linux hỗ trợ các chế độ xử lý vượt mức sau đây

0
	Xử lý quá mức heuristic. Rõ ràng là vượt quá địa chỉ
	không gian bị từ chối. Được sử dụng cho một hệ thống điển hình. Nó đảm bảo một
	phân bổ hoang dã nghiêm trọng không thành công trong khi cho phép cam kết quá mức
	giảm việc sử dụng trao đổi. Đây là mặc định.

1
	Luôn luôn cam kết quá mức. Thích hợp cho một số khoa học
	ứng dụng. Ví dụ cổ điển là mã sử dụng mảng thưa thớt và
	chỉ dựa vào bộ nhớ ảo bao gồm gần như hoàn toàn
	không có trang nào.

2
	Đừng cam kết quá mức. Tổng không gian địa chỉ cam kết cho
	hệ thống không được phép vượt quá trao đổi + số tiền có thể định cấu hình
	(mặc định là 50%) của RAM vật lý.  Tùy vào số tiền bạn
	sử dụng, trong hầu hết các trường hợp, điều này có nghĩa là một quy trình sẽ không được
	bị giết khi truy cập các trang nhưng sẽ gặp lỗi trên bộ nhớ
	phân bổ cho phù hợp.

Hữu ích cho các ứng dụng muốn đảm bảo bộ nhớ của chúng
	phân bổ sẽ có sẵn trong tương lai mà không cần phải
	khởi tạo mỗi trang.

Chính sách cam kết quá mức được đặt thông qua sysctl ZZ0000ZZ.

Số tiền cam kết vượt mức có thể được đặt thông qua ZZ0000ZZ (phần trăm)
hoặc ZZ0001ZZ (giá trị tuyệt đối). Những điều này chỉ có tác dụng
khi ZZ0002ZZ được đặt thành 2.

Giới hạn vượt mức hiện tại và số tiền đã cam kết có thể xem được trong
ZZ0000ZZ lần lượt là CommitLimit và Commited_AS.

vấn đề
=======

Sự phát triển của ngăn xếp ngôn ngữ C thực hiện một mremap ngầm. Nếu bạn muốn tuyệt đối
đảm bảo và chạy sát mép bạn MUST mmmap ngăn xếp của bạn cho
kích thước lớn nhất mà bạn nghĩ bạn sẽ cần. Đối với việc sử dụng ngăn xếp thông thường, điều này không
không quan trọng lắm nhưng đó là trường hợp khó khăn nếu bạn thực sự quan tâm

Ở chế độ 2, cờ MAP_NORESERVE bị bỏ qua.


Nó hoạt động như thế nào
============

Việc cam kết quá mức dựa trên các quy tắc sau

Đối với bản đồ được sao lưu bằng tập tin
	| SHARED hoặc READ-only - 0 phí (tệp là bản đồ không trao đổi)
	| PRIVATE WRITABLE - kích thước ánh xạ trên mỗi phiên bản

Đối với bản đồ ẩn danh hoặc ZZ0000ZZ
	| SHARED - kích thước ánh xạ
	| PRIVATE READ-only - giá 0 (nhưng ít sử dụng)
	| PRIVATE WRITABLE - kích thước ánh xạ trên mỗi phiên bản

Kế toán bổ sung
	| Các trang được tạo bản sao có thể ghi bằng mmap
	| bộ nhớ shmfs được rút ra từ cùng một nhóm

Trạng thái
======

* Chúng tôi tính đến ánh xạ bộ nhớ mmap
* Chúng tôi tính đến những thay đổi của mprotect trong cam kết
* Chúng tôi tính đến những thay đổi về kích thước của mremap
* Chúng tôi tài khoản brk
* Chúng tôi tài khoản munmap
* Chúng tôi báo cáo trạng thái cam kết trong /proc
* Tài khoản và kiểm tra trên ngã ba
* Xem lại việc xử lý/xây dựng ngăn xếp trên exec
* Kế toán SHMfs
* Triển khai thực thi hạn mức thực tế

phải làm
=====
* Trang ptrace tài khoản (điều này khó)
