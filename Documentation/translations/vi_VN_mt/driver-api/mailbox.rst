.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/mailbox.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
Khung hộp thư chung
===============================

:Tác giả: Jassi Brar <jaswinder.singh@linaro.org>

Tài liệu này nhằm mục đích giúp các nhà phát triển viết ứng dụng khách và bộ điều khiển
trình điều khiển cho API. Nhưng trước khi bắt đầu, chúng ta hãy lưu ý rằng
trình điều khiển máy khách (đặc biệt) và bộ điều khiển có thể sẽ
rất cụ thể về nền tảng vì chương trình cơ sở từ xa có thể
độc quyền và thực hiện giao thức không chuẩn. Vì vậy, ngay cả khi hai
các nền tảng sử dụng bộ điều khiển PL320, trình điều khiển máy khách không thể
được chia sẻ trên chúng. Ngay cả trình điều khiển PL320 cũng có thể cần phải đáp ứng
một số vấn đề cụ thể về nền tảng. Vì vậy, API chủ yếu nhằm tránh
các bản sao mã tương tự được viết cho mỗi nền tảng. Nói xong,
không có gì ngăn cản f/w từ xa cũng dựa trên Linux và sử dụng
cùng một api ở đó. Tuy nhiên, điều đó không giúp ích được gì cho chúng tôi tại địa phương vì chúng tôi chỉ
từng giao dịch ở cấp độ giao thức của khách hàng.

Một số lựa chọn được thực hiện trong quá trình thực hiện là kết quả của việc này.
đặc thù của khuôn khổ "chung" này.



Trình điều khiển Bộ điều khiển (Xem include/linux/mailbox_controller.h)
==========================================================


Phân bổ mbox_controller và mảng mbox_chan.
Điền vào mbox_chan_ops, ngoại trừ Flush() và Peek_data(), tất cả đều bắt buộc.
Trình điều khiển bộ điều khiển có thể biết một tin nhắn đã được sử dụng
bằng điều khiển từ xa bằng cách lấy IRQ hoặc thăm dò một số cờ phần cứng
hoặc nó không bao giờ có thể biết (khách hàng biết thông qua giao thức).
Phương thức theo thứ tự ưu tiên là IRQ -> Poll -> None, trong đó
trình điều khiển bộ điều khiển phải được đặt qua 'txdone_irq' hoặc 'txdone_poll'
hoặc không.


Trình điều khiển máy khách (Xem include/linux/mailbox_client.h)
==================================================


Máy khách có thể muốn hoạt động ở chế độ chặn (đồng bộ
gửi tin nhắn trước khi quay lại) hoặc chế độ không chặn/không đồng bộ (gửi
một tin nhắn và chức năng gọi lại tới API và quay lại ngay lập tức).

::

cấu trúc demo_client {
		cấu trúc mbox_client cl;
		struct mbox_chan *mbox;
		hoàn thành cấu trúc c;
		bool không đồng bộ;
		/* ... */
	};

/*
	* Đây là trình xử lý dữ liệu nhận được từ xa. Hành vi đó hoàn toàn là
	* phụ thuộc vào giao thức. Đây chỉ là một ví dụ.
	*/
	tin nhắn void tĩnh_from_remote(struct mbox_client *cl, void *mssg)
	{
		struct demo_client *dc = container_of(cl, struct demo_client, cl);
		nếu (dc->async) {
			nếu (is_an_ack(mssg)) {
				/* Một ACK cho mẫu cuối cùng của chúng tôi đã được gửi */
				trở lại; /* Hoặc làm gì đó khác ở đây */
			} else { /* Một tin nhắn mới từ xa */
				queue_req(mssg);
			}
		} khác {
			/* Remote f/w chỉ gửi các gói ACK trên kênh này */
			trở lại;
		}
	}

static void sample_sent(struct mbox_client *cl, void *mssg, int r)
	{
		struct demo_client *dc = container_of(cl, struct demo_client, cl);
		hoàn thành(&dc->c);
	}

static void client_demo(struct platform_device *pdev)
	{
		cấu trúc demo_client *dc_sync, *dc_async;
		/* Controller đã biết async_pkt và sync_pkt */
		cấu trúc async_pkt ap;
		cấu trúc sync_pkt sp;

dc_sync = kzalloc(sizeof(*dc_sync), GFP_KERNEL);
		dc_async = kzalloc(sizeof(*dc_async), GFP_KERNEL);

/* Điền vào máy khách chế độ không chặn */
		dc_async->cl.dev = &pdev->dev;
		dc_async->cl.rx_callback = message_from_remote;
		dc_async->cl.tx_done = sample_sent;
		dc_async->cl.tx_block = false;
		dc_async->cl.tx_tout = 0; /* ở đây không quan trọng */
		dc_async->cl.knows_txdone = false; /* tùy thuộc vào giao thức */
		dc_async->async = true;
		init_completion(&dc_async->c);

/* Điền vào ứng dụng khách chế độ chặn */
		dc_sync->cl.dev = &pdev->dev;
		dc_sync->cl.rx_callback = message_from_remote;
		dc_sync->cl.tx_done = NULL; /*hoạt động ở chế độ chặn */
		dc_sync->cl.tx_block = true;
		dc_sync->cl.tx_tout = 500; /* nửa giây */
		dc_sync->cl.knows_txdone = false; /* tùy thuộc vào giao thức */
		dc_sync->async = sai;

/* Hộp thư ASync được liệt kê thứ hai trong thuộc tính 'mboxes' */
		dc_async->mbox = mbox_request_channel(&dc_async->cl, 1);
		/* Điền gói dữ liệu */
		/* ap.xxx = 123; v.v. */
		/* Gửi tin nhắn không đồng bộ tới điều khiển từ xa */
		mbox_send_message(dc_async->mbox, &ap);

/* Hộp thư đồng bộ được liệt kê đầu tiên trong thuộc tính 'mboxes' */
		dc_sync->mbox = mbox_request_channel(&dc_sync->cl, 0);
		/* Điền gói dữ liệu */
		/* sp.abc = 123; v.v. */
		/* Gửi tin nhắn tới remote ở chế độ chặn */
		mbox_send_message(dc_sync->mbox, &sp);
		/* Tại thời điểm này 'sp' đã được gửi */

/* Bây giờ hãy đợi async chan hoàn tất */
		wait_for_completion(&dc_async->c);
	}
