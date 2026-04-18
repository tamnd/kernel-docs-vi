.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/dev-tools/kunit/api/functionredirection.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Chuyển hướng chức năng API
========================

Tổng quan
========

Khi viết bài kiểm thử đơn vị, điều quan trọng là có thể tách biệt mã đang được
được thử nghiệm từ các phần khác của kernel. Điều này đảm bảo độ tin cậy của bài kiểm tra
(nó sẽ không bị ảnh hưởng bởi các yếu tố bên ngoài), giảm sự phụ thuộc vào cụ thể
tùy chọn phần cứng hoặc cấu hình (giúp chạy thử nghiệm dễ dàng hơn) và bảo vệ
sự ổn định của phần còn lại của hệ thống (làm cho nó ít có khả năng xảy ra đối với các thử nghiệm cụ thể
trạng thái can thiệp vào phần còn lại của hệ thống).

Trong khi đối với một số mã (thường là cấu trúc dữ liệu chung, trình trợ giúp và các mã khác
"chức năng thuần túy") điều này là tầm thường đối với những người khác (như trình điều khiển thiết bị,
hệ thống tập tin, hệ thống con cốt lõi) mã được kết hợp chặt chẽ với các phần khác của
hạt nhân.

Sự kết hợp này thường do trạng thái toàn cục theo một cách nào đó: có thể là một danh sách toàn cục của
thiết bị, hệ thống tập tin hoặc một số trạng thái phần cứng. Việc kiểm tra cần phải cẩn thận
quản lý, cô lập và khôi phục trạng thái hoặc họ có thể tránh hoàn toàn trạng thái đó bằng cách
thay thế quyền truy cập và đột biến trạng thái này bằng một biến thể "giả" hoặc "giả".

Bằng cách tái cấu trúc quyền truy cập vào trạng thái đó, chẳng hạn như bằng cách giới thiệu một lớp
gián tiếp có thể sử dụng hoặc mô phỏng một tập hợp trạng thái thử nghiệm riêng biệt. Tuy nhiên,
việc tái cấu trúc như vậy đi kèm với chi phí riêng của nó (và thực hiện đáng kể
tái cấu trúc trước khi có thể viết bài kiểm tra là chưa tối ưu).

Một cách đơn giản hơn để chặn và thay thế một số lệnh gọi hàm là sử dụng
chuyển hướng chức năng thông qua sơ khai tĩnh.


Sơ khai tĩnh
============

Sơ khai tĩnh là một cách chuyển hướng cuộc gọi đến một chức năng ("thực"
chức năng) sang chức năng khác (chức năng "thay thế").

Nó hoạt động bằng cách thêm macro vào hàm "thực" để kiểm tra xem liệu thử nghiệm có
đang chạy và liệu có chức năng thay thế nào không. Nếu vậy thì chức năng đó là
được gọi thay cho bản gốc.

Sử dụng sơ khai tĩnh khá đơn giản:

1. Thêm macro KUNIT_STATIC_STUB_REDIRECT() vào đầu "thực"
   chức năng.

Đây phải là câu lệnh đầu tiên trong hàm, sau bất kỳ biến nào
   các tuyên bố. KUNIT_STATIC_STUB_REDIRECT() lấy tên của
   hàm, theo sau là tất cả các đối số được truyền cho hàm thực.

Ví dụ:

   .. code-block:: c

void send_data_to_hardware(const char *str)
	{
		KUNIT_STATIC_STUB_REDIRECT(gửi_data_to_hardware, str);
		/*triển khai thực tế*/
	}

2. Viết một hoặc nhiều hàm thay thế.

Các hàm này phải có cùng chữ ký hàm với hàm thực.
   Trong trường hợp họ cần truy cập hoặc sửa đổi trạng thái cụ thể của bài kiểm tra, họ có thể sử dụng
   kunit_get_current_test() để lấy con trỏ struct kunit. Điều này sau đó có thể
   được chuyển đến macro kỳ vọng/xác nhận hoặc được sử dụng để tra cứu KUnit
   tài nguyên.

Ví dụ:

   .. code-block:: c

void fake_send_data_to_hardware(const char *str)
	{
		struct kunit *test = kunit_get_current_test();
		KUNIT_EXPECT_STREQ(kiểm tra, str, "Xin chào thế giới!");
	}

3. Kích hoạt sơ khai tĩnh từ bài kiểm tra của bạn.

Từ trong thử nghiệm, chuyển hướng có thể được kích hoạt bằng
   kunit_activate_static_stub(), chấp nhận con trỏ struct kunit,
   hàm thực và hàm thay thế. Bạn có thể gọi đây là một số
   lần với các chức năng thay thế khác nhau để hoán đổi việc triển khai
   chức năng.

Trong ví dụ của chúng tôi, đây sẽ là

   .. code-block:: c

kunit_activate_static_stub(kiểm tra,
				   gửi_data_to_hardware,
				   fake_send_data_to_hardware);

4. Gọi (có lẽ gián tiếp) hàm thực.

Sau khi chuyển hướng được kích hoạt, mọi lệnh gọi đến hàm thực sẽ gọi
   chức năng thay thế thay thế. Những lời kêu gọi như vậy có thể bị chôn sâu trong
   thực hiện một chức năng khác nhưng phải xảy ra từ kthread của thử nghiệm.

Ví dụ:

   .. code-block:: c

send_data_to_hardware("Xin chào thế giới!"); /*Thành công*/
	send_data_to_hardware("Cái gì đó khác"); /* Bài kiểm tra thất bại. */

5. (Tùy chọn) vô hiệu hóa sơ khai.

Khi bạn không cần nó nữa, hãy tắt tính năng chuyển hướng (và do đó tiếp tục
   hành vi ban đầu của hàm 'thực') bằng cách sử dụng
   kunit_deactivate_static_stub(). Nếu không nó sẽ tự động bị vô hiệu hóa
   khi bài kiểm tra kết thúc.

Ví dụ:

   .. code-block:: c

kunit_deactivate_static_stub(test, send_data_to_hardware);


Cũng có thể sử dụng các chức năng thay thế này để kiểm tra xem liệu
hàm hoàn toàn được gọi, ví dụ:

.. code-block:: c

	void send_data_to_hardware(const char *str)
	{
		KUNIT_STATIC_STUB_REDIRECT(send_data_to_hardware, str);
		/* real implementation */
	}

	/* In test file */
	int times_called = 0;
	void fake_send_data_to_hardware(const char *str)
	{
		times_called++;
	}
	...
	/* In the test case, redirect calls for the duration of the test */
	kunit_activate_static_stub(test, send_data_to_hardware, fake_send_data_to_hardware);

	send_data_to_hardware("hello");
	KUNIT_EXPECT_EQ(test, times_called, 1);

	/* Can also deactivate the stub early, if wanted */
	kunit_deactivate_static_stub(test, send_data_to_hardware);

	send_data_to_hardware("hello again");
	KUNIT_EXPECT_EQ(test, times_called, 1);



Tham khảo API
=============

.. kernel-doc:: include/kunit/static_stub.h
   :internal: