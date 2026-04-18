.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/mm/multigen_lru.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==============
LRU đa thế hệ
=============
LRU đa thế hệ là một triển khai LRU thay thế giúp tối ưu hóa
lấy lại trang và cải thiện hiệu suất dưới áp lực bộ nhớ. Trang
lấy lại quyết định chính sách bộ nhớ đệm của kernel và khả năng vượt mức
trí nhớ. Nó ảnh hưởng trực tiếp đến việc sử dụng kswapd CPU và hiệu quả của RAM.

Bắt đầu nhanh
===========
Xây dựng kernel với các cấu hình sau.

* ZZ0000ZZ
* ZZ0001ZZ

Đã hoàn tất!

Tùy chọn thời gian chạy
===============
ZZ0000ZZ chứa ABI ổn định được mô tả trong
các tiểu mục sau.

Công tắc tiêu diệt
-----------
ZZ0000ZZ chấp nhận các giá trị khác nhau để bật hoặc tắt
các thành phần sau. Giá trị mặc định của nó phụ thuộc vào
ZZ0001ZZ. Tất cả các thành phần nên được kích hoạt
trừ khi một số trong số chúng có tác dụng phụ không lường trước được. Viết cho
ZZ0002ZZ không có hiệu lực khi một thành phần không được hỗ trợ bởi
phần cứng và các giá trị hợp lệ sẽ được chấp nhận ngay cả khi công tắc chính
đã tắt.

==========================================================================
Thành phần giá trị
==========================================================================
0x0001 Công tắc chính cho LRU đa thế hệ.
0x0002 Xóa bit được truy cập trong các mục trong bảng trang lá với số lượng lớn
       lô, khi MMU đặt nó (ví dụ: trên x86). Hành vi này có thể
       về mặt lý thuyết làm trầm trọng thêm sự tranh chấp khóa (mmap_lock). Nếu nó là
       bị vô hiệu hóa, LRU đa thế hệ sẽ bị giảm hiệu suất
       suy giảm khối lượng công việc liên kết các trang nóng,
       các bit được truy cập của chúng có thể được xóa bằng cách khác với số lượng lớn hơn ít hơn
       lô.
0x0004 Xóa bit được truy cập trong các mục trong bảng trang không có lá như
       à, khi MMU đặt nó (ví dụ: trên x86). Hành vi này đã không
       đã được xác minh trên các loại x86 khác ngoài Intel và AMD. Nếu nó là
       bị vô hiệu hóa, LRU đa thế hệ sẽ bị ảnh hưởng không đáng kể
       suy thoái hiệu suất.
[yYnN] Áp dụng cho tất cả các thành phần trên.
==========================================================================

Ví dụ.,
::

echo y >/sys/kernel/mm/lru_gen/enabled
    mèo /sys/kernel/mm/lru_gen/enabled
    0x0007
    echo 5 >/sys/kernel/mm/lru_gen/enabled
    mèo /sys/kernel/mm/lru_gen/enabled
    0x0005

Phòng chống đập phá
--------------------
Máy tính cá nhân nhạy cảm hơn với va đập vì nó có thể
gây ra hiện tượng giật (chậm khi hiển thị giao diện người dùng) và tác động tiêu cực đến người dùng
kinh nghiệm. LRU đa thế hệ cung cấp khả năng chống va đập cho
phần lớn người dùng máy tính xách tay và máy tính để bàn không có ZZ0000ZZ.

Người dùng có thể ghi ZZ0000ZZ vào ZZ0001ZZ để ngăn bộ hoạt động của
ZZ0002ZZ còn mili giây nữa mới bị đuổi khỏi nhà. Kẻ giết người OOM được kích hoạt
nếu bộ làm việc này không thể được lưu giữ trong bộ nhớ. Nói cách khác, điều này
tùy chọn hoạt động như một van giảm áp có thể điều chỉnh và khi mở, nó
chấm dứt các ứng dụng hy vọng không được sử dụng.

Dựa trên độ trễ trung bình mà con người có thể phát hiện được (~100ms), ZZ0000ZZ thường
loại bỏ những cú giật không thể chịu đựng được do va đập. Giá trị lớn hơn như
ZZ0001ZZ làm cho hiện tượng giật ít được chú ý hơn trước nguy cơ OOM xuất hiện sớm
giết chết.

Giá trị mặc định ZZ0000ZZ có nghĩa là bị vô hiệu hóa.

Tính năng thử nghiệm
=====================
ZZ0000ZZ chấp nhận các lệnh được mô tả trong
các tiểu mục sau. Nhiều dòng lệnh được hỗ trợ,
nối với các dấu phân cách ZZ0001ZZ và ZZ0002ZZ.

ZZ0000ZZ cung cấp số liệu thống kê bổ sung cho
gỡ lỗi. ZZ0001ZZ giữ số liệu thống kê lịch sử từ
các thế hệ bị trục xuất trong tập tin này.

Ước tính tập công việc
----------------------
Ước tính tập công việc đo lường lượng bộ nhớ mà một ứng dụng cần
trong một khoảng thời gian nhất định và nó thường được thực hiện ít ảnh hưởng đến
hiệu suất của ứng dụng. Ví dụ: trung tâm dữ liệu muốn
tối ưu hóa việc lập kế hoạch công việc (đóng gói thùng) để cải thiện việc sử dụng bộ nhớ.
Khi có một công việc mới, người lập kế hoạch công việc cần tìm hiểu xem liệu
mỗi máy chủ mà nó quản lý có thể phân bổ một lượng bộ nhớ nhất định cho
công việc mới này trước khi có thể chọn được một ứng viên. Để làm được điều đó, công việc
người lập lịch trình cần ước tính nhóm công việc của các công việc hiện có.

Khi nó được đọc, ZZ0000ZZ trả về biểu đồ số trang
được truy cập trong các khoảng thời gian khác nhau cho từng memcg và nút.
ZZ0001ZZ quyết định số lượng thùng cho mỗi biểu đồ. các
biểu đồ không tích lũy.
::

memcg memcg_id memcg_path
       nút nút_id
           min_gen_nr age_in_ms nr_anon_pages nr_file_pages
           ...
max_gen_nr age_in_ms nr_anon_pages nr_file_pages

Mỗi thùng chứa số lượng trang ước tính đã được truy cập
trong ZZ0000ZZ. Ví dụ: ZZ0001ZZ chứa các trang lạnh nhất
và ZZ0002ZZ chứa các trang hấp dẫn nhất, kể từ ZZ0003ZZ của
cái trước là lớn nhất và cái sau là nhỏ nhất.

Người dùng có thể viết lệnh sau vào ZZ0000ZZ để tạo mới
thế hệ ZZ0001ZZ:

ZZ0000ZZ

ZZ0000ZZ mặc định là cài đặt trao đổi và nếu nó được đặt thành ZZ0001ZZ,
nó buộc phải quét các trang anon khi tắt trao đổi và ngược lại.
ZZ0002ZZ mặc định là ZZ0003ZZ và nếu được đặt thành ZZ0004ZZ, nó sẽ
sử dụng phương pháp phỏng đoán để giảm chi phí, điều này có thể làm giảm
phạm vi bảo hiểm là tốt.

Một trường hợp sử dụng điển hình là bộ lập lịch công việc chạy lệnh này tại một thời điểm
khoảng thời gian nhất định để tạo ra thế hệ mới và nó xếp hạng
máy chủ mà nó quản lý dựa trên kích thước của các trang lạnh được xác định bởi
khoảng thời gian này.

Chủ động đòi lại
-----------------
Xác nhận lại chủ động thực hiện xác nhận lại trang khi không còn bộ nhớ
áp lực. Nó thường chỉ nhắm mục tiêu các trang lạnh. Ví dụ: khi có công việc mới
đến, người lập lịch công việc muốn chủ động lấy lại các trang lạnh trên
máy chủ mà nó đã chọn, để nâng cao cơ hội hạ cánh thành công
công việc mới này.

Người dùng có thể viết lệnh sau vào ZZ0000ZZ để trục xuất
thế hệ nhỏ hơn hoặc bằng ZZ0001ZZ.

ZZ0000ZZ

ZZ0000ZZ phải nhỏ hơn ZZ0001ZZ, vì
ZZ0002ZZ và ZZ0003ZZ chưa được lão hóa hoàn toàn (tương đương với
danh sách đang hoạt động) và do đó không thể bị trục xuất. ZZ0004ZZ
ghi đè giá trị mặc định trong ZZ0005ZZ và giá trị hợp lệ
phạm vi là [0-200, max], với max được sử dụng riêng cho việc thu hồi
của ký ức vô danh. ZZ0006ZZ giới hạn số lượng trang cần loại bỏ.

Một trường hợp sử dụng điển hình là bộ lập lịch công việc chạy lệnh này trước khi nó
cố gắng tìm một công việc mới trên máy chủ. Nếu nó không thành hiện thực đủ
trang lạnh vì đánh giá quá cao, nó sẽ thử lại vào lần tiếp theo
máy chủ theo kết quả xếp hạng thu được từ bộ làm việc
bước ước lượng Cách tiếp cận ít mạnh mẽ hơn này hạn chế tác động lên
các công việc hiện có.