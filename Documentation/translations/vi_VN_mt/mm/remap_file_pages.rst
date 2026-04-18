.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/remap_file_pages.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================================
lệnh gọi hệ thống remap_file_pages()
==============================

Lệnh gọi hệ thống remap_file_pages() được sử dụng để tạo ánh xạ phi tuyến,
nghĩa là ánh xạ trong đó các trang của tệp được ánh xạ vào một
thứ tự không tuần tự trong bộ nhớ. Ưu điểm của việc sử dụng remap_file_pages()
việc sử dụng các cuộc gọi lặp đi lặp lại tới mmap(2) là cách tiếp cận trước đây không
yêu cầu kernel tạo thêm dữ liệu VMA (Vùng bộ nhớ ảo)
các cấu trúc.

Hỗ trợ ánh xạ phi tuyến đòi hỏi số lượng đáng kể các công cụ không tầm thường
mã trong hệ thống con bộ nhớ ảo kernel bao gồm các đường dẫn nóng. Ngoài ra để có được
Hạt nhân công việc ánh xạ phi tuyến cần một cách để phân biệt bảng trang bình thường
các mục từ các mục có phần bù tệp (pte_file). Cờ dự trữ hạt nhân trong
PTE cho mục đích này. Cờ PTE là tài nguyên khan hiếm, đặc biệt là trên một số CPU
kiến trúc. Sẽ thật tốt nếu giải phóng cờ cho mục đích sử dụng khác.

May mắn thay, không có nhiều người dùng remap_file_pages() ngoài đời thực.
Người ta chỉ biết rằng một doanh nghiệp triển khai RDBMS sử dụng syscall
trên các hệ thống 32 bit để ánh xạ các tệp lớn hơn mức có thể khớp tuyến tính với 32 bit
không gian địa chỉ ảo. Trường hợp sử dụng này không còn quan trọng nữa vì 64-bit
hệ thống có sẵn rộng rãi.

Tòa nhà cao tầng không được dùng nữa và hiện được thay thế bằng một mô phỏng. các
mô phỏng tạo ra các VMA mới thay vì ánh xạ phi tuyến. Nó sẽ
hoạt động chậm hơn đối với những người dùng hiếm hoi của remap_file_pages() nhưng ABI vẫn được giữ nguyên.

Một tác dụng phụ của việc mô phỏng (ngoài hiệu suất) là người dùng có thể nhấn
Giới hạn vm.max_map_count dễ dàng hơn do có thêm VMA. Xem bình luận cho
DEFAULT_MAX_MAP_COUNT để biết thêm chi tiết về giới hạn.
