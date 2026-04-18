.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fb/deferred_io.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============
IO hoãn lại
============

IO trì hoãn là một cách để trì hoãn và tái sử dụng IO. Nó sử dụng bộ nhớ máy chủ như một
bộ đệm và lỗi trang MMU làm công cụ kích hoạt trước khi thực hiện thiết bị
IO. Ví dụ sau đây có thể là lời giải thích hữu ích về cách một thiết lập như vậy
hoạt động:

- ứng dụng không gian người dùng như bộ đệm khung Xfbdev mmaps
- IO bị trì hoãn và trình điều khiển thiết lập lỗi và trình xử lý page_mkwrite
- ứng dụng không gian người dùng cố gắng ghi vào vaaddress mmapped
- chúng tôi nhận được lỗi trang và xử lý lỗi
- trình xử lý lỗi tìm và trả về trang vật lý
- chúng tôi nhận được page_mkwrite nơi chúng tôi thêm trang này vào danh sách
- lên lịch cho một tác vụ hàng đợi công việc được chạy sau khi bị trì hoãn
- ứng dụng tiếp tục ghi vào trang đó mà không mất thêm chi phí. đây là
  lợi ích chính.
- tác vụ hàng đợi công việc xuất hiện và dọn dẹp các trang trong danh sách, sau đó
  hoàn thành công việc liên quan đến việc cập nhật bộ đệm khung. đây là
  công việc thực sự nói chuyện với thiết bị.
- ứng dụng cố gắng ghi vào địa chỉ (hiện đã được làm sạch)
- gặp lỗi trang và trình tự trên lại xảy ra

Như có thể thấy ở trên, một lợi ích đại khái là cho phép bộ đệm khung bùng nổ
ghi xảy ra với chi phí tối thiểu. Rồi sau một thời gian khi hy vọng mọi thứ
đã im lặng, chúng tôi tiến hành và thực sự cập nhật bộ đệm khung.
một hoạt động tương đối tốn kém hơn.

Đối với một số loại màn hình có độ trễ cao không biến đổi, hình ảnh mong muốn là
hình ảnh cuối cùng chứ không phải là giai đoạn trung gian, đó là lý do tại sao không sao cả
không cập nhật cho mỗi lần ghi đang diễn ra.

Có thể điều này cũng hữu ích trong các tình huống khác. Paul Mundt
đã đề cập đến một trường hợp có lợi khi sử dụng số trang để quyết định
liệu có nên hợp nhất và phát hành SG DMA hay thực hiện bùng nổ bộ nhớ.

Một cách khác có thể là nếu người ta có bộ đệm khung thiết bị ở định dạng thông thường,
giả sử RGB dịch chuyển theo đường chéo, thì đây có thể là một cơ chế để bạn cho phép
các ứng dụng giả vờ có bộ đệm khung bình thường nhưng thay đổi lại cho thiết bị
bộ đệm khung tại thời điểm vsync dựa trên danh sách trang được chạm.

Cách sử dụng: (dành cho ứng dụng)
---------------------------------
Không cần thay đổi. mmap bộ đệm khung như bình thường và chỉ cần sử dụng nó.

Cách sử dụng: (dành cho trình điều khiển fbdev)
-----------------------------------------------
Ví dụ sau đây có thể hữu ích.

1. Thiết lập cấu trúc của bạn. Ví dụ::

cấu trúc tĩnh fb_deferred_io hecubafb_defio = {
		.delay = HZ,
		.deferred_io = hecubafb_dpy_deferred_io,
	};

Độ trễ là độ trễ tối thiểu kể từ khi xảy ra trình kích hoạt page_mkwrite
và khi lệnh gọi lại deferred_io được gọi. Cuộc gọi lại deferred_io là
giải thích dưới đây.

2. Thiết lập lệnh gọi lại IO bị trì hoãn của bạn. Ví dụ::

static void hecubafb_dpy_deferred_io(struct fb_info *info,
					     cấu trúc list_head *pagelist)

Cuộc gọi lại deferred_io là nơi bạn sẽ thực hiện tất cả IO của mình trên màn hình
thiết bị. Bạn nhận được danh sách trang là danh sách các trang được viết
trong thời gian trì hoãn. Bạn không được sửa đổi danh sách này. Cuộc gọi lại này được gọi
từ một hàng đợi công việc.

3. Gọi init::

thông tin->fbdefio = &hecubafb_defio;
	fb_deferred_io_init(thông tin);

4. Dọn dẹp cuộc gọi::

fb_deferred_io_cleanup(thông tin);
