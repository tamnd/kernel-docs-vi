.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/io-mapping.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Các hàm io_mapping
========================

API
===

Các hàm io_mapping trong linux/io-mapping.h cung cấp sự trừu tượng hóa cho
ánh xạ hiệu quả các vùng nhỏ của thiết bị I/O tới CPU. ban đầu
việc sử dụng là để hỗ trợ khẩu độ đồ họa lớn trên bộ xử lý 32 bit trong đó
ioremap_wc không thể được sử dụng để ánh xạ tĩnh toàn bộ khẩu độ tới CPU
vì nó sẽ tiêu tốn quá nhiều không gian địa chỉ kernel.

Một đối tượng ánh xạ được tạo trong quá trình khởi tạo trình điều khiển bằng cách sử dụng ::

struct io_mapping *io_mapping_create_wc(cơ sở dài không dấu,
						kích thước dài không dấu)

'cơ sở' là địa chỉ xe buýt của khu vực được thực hiện
có thể ánh xạ được, trong khi 'kích thước' cho biết vùng ánh xạ sẽ lớn đến mức nào
kích hoạt. Cả hai đều tính bằng byte.

Biến thể _wc này cung cấp một ánh xạ chỉ có thể được sử dụng với
io_mapping_map_atomic_wc(), io_mapping_map_local_wc() hoặc
io_mapping_map_wc().

Với đối tượng ánh xạ này, các trang riêng lẻ có thể được ánh xạ tạm thời
hoặc lâu dài tùy theo yêu cầu. Tất nhiên, bản đồ tạm thời là
hiệu quả hơn. Chúng có hai hương vị::

khoảng trống *io_mapping_map_local_wc(struct io_mapping *mapping,
				      phần bù dài không dấu)

khoảng trống *io_mapping_map_atomic_wc(struct io_mapping *mapping,
				       phần bù dài không dấu)

'offset' là phần bù trong vùng ánh xạ đã xác định.  Truy cập
địa chỉ ngoài vùng được chỉ định trong hàm tạo mang lại
kết quả không xác định. Sử dụng phần bù không được căn chỉnh theo trang sẽ mang lại kết quả
kết quả không xác định. Giá trị trả về trỏ đến một trang trong địa chỉ CPU
không gian.

Biến thể _wc này trả về bản đồ kết hợp ghi vào trang và chỉ có thể
được sử dụng với ánh xạ được tạo bởi io_mapping_create_wc()

Ánh xạ tạm thời chỉ hợp lệ trong ngữ cảnh của người gọi. Bản đồ
không được đảm bảo hiển thị trên toàn cầu.

io_mapping_map_local_wc() có tác dụng phụ trên X86 32bit khi nó vô hiệu hóa
di chuyển để làm cho mã ánh xạ hoạt động. Không người gọi nào có thể dựa vào bên này
hiệu ứng.

io_mapping_map_atomic_wc() có tác dụng phụ là vô hiệu hóa quyền ưu tiên và
lỗi trang. Không sử dụng trong mã mới. Thay vào đó hãy sử dụng io_mapping_map_local_wc().

Ánh xạ lồng nhau cần phải được hoàn tác theo thứ tự ngược lại vì ánh xạ
mã sử dụng ngăn xếp để theo dõi chúng ::

addr1 = io_mapping_map_local_wc(map1, offset1);
 addr2 = io_mapping_map_local_wc(map2, offset2);
 ...
io_mapping_unmap_local(addr2);
 io_mapping_unmap_local(addr1);

Các ánh xạ được phát hành với::

void io_mapping_unmap_local(void *vaddr)
	void io_mapping_unmap_atomic(void *vaddr)

'vaddr' phải là giá trị được trả về bởi io_mapping_map_local_wc() cuối cùng hoặc
cuộc gọi io_mapping_map_atomic_wc(). Điều này sẽ hủy bản đồ ánh xạ đã chỉ định và
hoàn tác các tác dụng phụ của các chức năng ánh xạ.

Nếu bạn cần ngủ trong khi đang cầm bản đồ, bạn có thể sử dụng chế độ thông thường
biến thể, mặc dù điều này có thể chậm hơn đáng kể::

khoảng trống *io_mapping_map_wc(struct io_mapping *mapping,
				phần bù dài không dấu)

Điều này hoạt động giống như io_mapping_map_atomic/local_wc() ngoại trừ nó không có mặt nào
hiệu ứng và con trỏ có thể nhìn thấy trên toàn cầu.

Các ánh xạ được phát hành với::

void io_mapping_unmap(void *vaddr)

Sử dụng cho các trang được ánh xạ bằng io_mapping_map_wc().

Vào thời điểm đóng trình điều khiển, đối tượng io_mapping phải được giải phóng ::

void io_mapping_free(struct io_mapping *mapping)
