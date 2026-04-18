.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/remotes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================
Truy tìm điều khiển từ xa
=========================

:Tác giả: Vincent Donnefort <vdonnefort@google.com>

Tổng quan
=========
Phần sụn và phần mềm ảo hóa là hộp đen của kernel. Có cách để xem những gì
họ đang làm có thể hữu ích để gỡ lỗi cả hai. Đây là nơi bộ đệm theo dõi từ xa
đi vào. Bộ đệm theo dõi từ xa là bộ đệm vòng được thực thi bởi phần sụn hoặc
bộ ảo hóa vào bộ nhớ được ánh xạ tới nhân máy chủ. Điều này tương tự
về cách bộ nhớ không gian người dùng ánh xạ bộ đệm vòng hạt nhân nhưng trong trường hợp này hạt nhân
hoạt động giống như không gian người dùng và phần sụn hoặc bộ ảo hóa là phía "hạt nhân".
Với bộ đệm vòng theo dõi từ xa, phần sụn và bộ ảo hóa có thể ghi lại các sự kiện
mà nhân máy chủ có thể nhìn thấy và hiển thị với không gian người dùng.

Đăng ký một điều khiển từ xa
============================
Điều khiển từ xa phải cung cấp một tập hợp các cuộc gọi lại ZZ0000ZZ mà
mô tả có thể được tìm thấy dưới đây. Những cuộc gọi lại đó cho phép Tracefs kích hoạt và
vô hiệu hóa việc theo dõi và các sự kiện, để tải và dỡ bỏ bộ đệm theo dõi (một tập hợp
bộ đệm vòng) và hoán đổi trang đọc với trang đầu, điều này cho phép
tiêu tốn việc đọc.

.. kernel-doc:: include/linux/trace_remote.h

Sau khi đăng ký, một phiên bản cho điều khiển từ xa này sẽ xuất hiện trong Tracefs
thư mục ZZ0000ZZ. Bộ đệm sau đó có thể được đọc bằng các tệp Tracefs thông thường
ZZ0001ZZ và ZZ0002ZZ.

Khai báo một sự kiện từ xa
==========================
Macro được cung cấp để dễ dàng khai báo các sự kiện từ xa, theo cách tương tự
thời trang cho các sự kiện trong kernel. Một tờ khai phải cung cấp ID, mô tả về
các đối số sự kiện và cách in sự kiện:

.. code-block:: c

	REMOTE_EVENT(foo, EVENT_FOO_ID,
		RE_STRUCT(
			re_field(u64, bar)
		),
		RE_PRINTK("bar=%lld", __entry->bar)
	);

Sau đó, những sự kiện đó phải được khai báo trong tệp C với nội dung sau:

.. code-block:: c

	#define REMOTE_EVENT_INCLUDE_FILE foo_events.h
	#include <trace/define_remote_events.h>

Điều này sẽ cung cấp một ZZ0000ZZ có thể được trao cho
ZZ0001ZZ.

Các sự kiện đã đăng ký xuất hiện trong thư mục từ xa dưới ZZ0000ZZ.

Bộ đệm vòng đơn giản
====================
Có thể tìm thấy một cách triển khai đơn giản cho trình ghi bộ đệm vòng trong
kernel/trace/simple_ring_buffer.c.

.. kernel-doc:: include/linux/simple_ring_buffer.h