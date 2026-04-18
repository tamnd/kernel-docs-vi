.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/staging/rpmsg.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================================
Khung nhắn tin bộ xử lý từ xa (rpmsg)
============================================

.. note::

  This document describes the rpmsg bus and how to write rpmsg drivers.
  To learn how to add rpmsg support for new platforms, check out remoteproc.txt
  (also a resident of Documentation/).

Giới thiệu
============

Các SoC hiện đại thường sử dụng các thiết bị xử lý từ xa không đồng nhất trong
cấu hình đa xử lý bất đối xứng (AMP), có thể đang chạy
các phiên bản khác nhau của hệ điều hành, cho dù đó là Linux hay bất kỳ hệ điều hành nào khác
hương vị của hệ điều hành thời gian thực.

Ví dụ: OMAP4 có Cortex-A9 kép, Cortex-M3 kép và C64x+ DSP.
Thông thường, Cortex-A9 kép đang chạy Linux ở cấu hình SMP,
và mỗi lõi trong số ba lõi còn lại (hai lõi M3 và một lõi DSP) đang chạy
phiên bản RTOS của riêng nó trong cấu hình AMP.

Thông thường bộ xử lý từ xa AMP sử dụng codec và đa phương tiện DSP chuyên dụng
bộ tăng tốc phần cứng và do đó thường được sử dụng để giảm tải CPU chuyên sâu
tác vụ đa phương tiện từ bộ xử lý ứng dụng chính.

Những bộ xử lý từ xa này cũng có thể được sử dụng để kiểm soát độ trễ nhạy cảm
cảm biến, điều khiển các khối phần cứng ngẫu nhiên hoặc chỉ thực hiện các tác vụ nền
trong khi CPU chính đang chạy không tải.

Người dùng của các bộ xử lý từ xa đó có thể là ứng dụng dành cho người dùng (ví dụ: đa phương tiện
các khung nói chuyện với các thành phần OMX từ xa) hoặc trình điều khiển hạt nhân (điều khiển
phần cứng chỉ có thể được truy cập bởi bộ xử lý từ xa, dành riêng quyền kiểm soát kernel
tài nguyên thay mặt cho bộ xử lý từ xa, v.v.).

Rpmsg là một bus nhắn tin dựa trên virtio cho phép các trình điều khiển kernel giao tiếp
với bộ xử lý từ xa có sẵn trên hệ thống. Đổi lại, người lái xe sau đó có thể
hiển thị các giao diện không gian người dùng thích hợp, nếu cần.

Khi viết trình điều khiển hiển thị giao tiếp RPMSG tới vùng người dùng, vui lòng
hãy nhớ rằng các bộ xử lý từ xa có thể có quyền truy cập trực tiếp vào
bộ nhớ vật lý của hệ thống và các tài nguyên phần cứng nhạy cảm khác (ví dụ: trên
OMAP4, lõi từ xa và bộ tăng tốc phần cứng có thể có quyền truy cập trực tiếp vào
bộ nhớ vật lý, ngân hàng gpio, bộ điều khiển dma, bus i2c, gptimers, hộp thư
thiết bị, hwspinlocks, v.v.). Hơn nữa, những bộ xử lý từ xa đó có thể
đang chạy RTOS trong đó mọi tác vụ đều có thể truy cập vào toàn bộ bộ nhớ/thiết bị được hiển thị
đến bộ xử lý. Để giảm thiểu rủi ro về mã vùng người dùng giả mạo (hoặc có lỗi)
khai thác các lỗi từ xa và bằng cách chiếm quyền điều khiển hệ thống, nó thường
mong muốn giới hạn vùng người dùng ở các kênh RPMSG cụ thể (xem định nghĩa bên dưới)
nó có thể gửi tin nhắn và nếu có thể, hãy giảm thiểu mức độ kiểm soát
nó có nội dung của tin nhắn.

Mỗi thiết bị RPMSG là một kênh liên lạc với bộ xử lý từ xa (do đó
thiết bị RPMSg được gọi là kênh). Các kênh được xác định bằng tên văn bản
và có địa chỉ RPMSG cục bộ ("nguồn") và RPMSG từ xa ("Đích")
địa chỉ.

Khi trình điều khiển bắt đầu nghe trên một kênh, cuộc gọi lại rx của nó bị ràng buộc với
một địa chỉ cục bộ RPMSG duy nhất (số nguyên 32 bit). Bằng cách này khi có tin nhắn gửi đến
đến nơi, lõi RPMSG sẽ gửi chúng đến trình điều khiển thích hợp theo
tới địa chỉ đích của chúng (việc này được thực hiện bằng cách gọi trình xử lý rx của trình điều khiển
với tải trọng của tin nhắn gửi đến).


Người dùng API
========

::

int vòng/phútsg_send(cấu trúc vòng/phútsg_endpoint *ept, void *data, int len);

gửi tin nhắn tới bộ xử lý từ xa từ điểm cuối nhất định.
Người gọi phải chỉ định điểm cuối, dữ liệu muốn gửi,
và độ dài của nó (tính bằng byte). Tin nhắn sẽ được gửi theo địa chỉ được chỉ định
kênh của điểm cuối, tức là các trường địa chỉ nguồn và đích của nó sẽ là
tương ứng được đặt thành địa chỉ src của điểm cuối và kênh mẹ của nó
địa chỉ dst.

Trong trường hợp không có bộ đệm TX, chức năng sẽ chặn cho đến khi
một cái sẽ khả dụng (tức là cho đến khi bộ xử lý từ xa tiêu thụ hết
một bộ đệm tx và đặt nó trở lại vòng mô tả đã sử dụng của virtio),
hoặc hết thời gian 15 giây. Khi điều sau xảy ra,
-ERESTARTSYS được trả lại.

Hàm chỉ có thể được gọi từ ngữ cảnh tiến trình (hiện tại).
Trả về 0 nếu thành công và giá trị lỗi thích hợp nếu thất bại.

::

int vòng/phútsg_sendto(cấu trúc vòng/phútsg_endpoint *ept, void *data, int len, u32 dst);

gửi tin nhắn tới bộ xử lý từ xa từ một điểm cuối nhất định,
tới địa chỉ đích do người gọi cung cấp.

Người gọi phải chỉ định điểm cuối, dữ liệu muốn gửi,
độ dài của nó (tính bằng byte) và địa chỉ đích rõ ràng.

Thông báo sau đó sẽ được gửi đến bộ xử lý từ xa mà
kênh của điểm cuối thuộc về, sử dụng địa chỉ src của điểm cuối,
và địa chỉ dst do người dùng cung cấp (do đó địa chỉ dst của kênh
sẽ bị bỏ qua).

Trong trường hợp không có bộ đệm TX, chức năng sẽ chặn cho đến khi
một cái sẽ khả dụng (tức là cho đến khi bộ xử lý từ xa tiêu thụ hết
một bộ đệm tx và đặt nó trở lại vòng mô tả đã sử dụng của virtio),
hoặc hết thời gian 15 giây. Khi điều sau xảy ra,
-ERESTARTSYS được trả lại.

Hàm chỉ có thể được gọi từ ngữ cảnh tiến trình (hiện tại).
Trả về 0 nếu thành công và giá trị lỗi thích hợp nếu thất bại.

::

int vòng/phútsg_trysend(cấu trúc vòng/phútsg_endpoint *ept, void *data, int len);

gửi tin nhắn tới bộ xử lý từ xa từ một điểm cuối nhất định.
Người gọi phải chỉ định điểm cuối, dữ liệu muốn gửi,
và độ dài của nó (tính bằng byte). Tin nhắn sẽ được gửi theo địa chỉ được chỉ định
kênh của điểm cuối, tức là các trường địa chỉ nguồn và đích của nó sẽ là
tương ứng được đặt thành địa chỉ src của điểm cuối và kênh mẹ của nó
địa chỉ dst.

Trong trường hợp không có bộ đệm TX, chức năng sẽ ngay lập tức
trả về -ENOMEM mà không cần đợi cho đến khi có sẵn.

Hàm chỉ có thể được gọi từ ngữ cảnh tiến trình (hiện tại).
Trả về 0 nếu thành công và giá trị lỗi thích hợp nếu thất bại.

::

int vòng/phútsg_trysendto(cấu trúc vòng/phútsg_endpoint *ept, void *data, int len, u32 dst)


gửi tin nhắn tới bộ xử lý từ xa từ một điểm cuối nhất định,
đến địa chỉ đích do người dùng cung cấp.

Người dùng nên chỉ định kênh, dữ liệu muốn gửi,
độ dài của nó (tính bằng byte) và địa chỉ đích rõ ràng.

Thông báo sau đó sẽ được gửi đến bộ xử lý từ xa mà
kênh thuộc về, sử dụng địa chỉ src của kênh và do người dùng cung cấp
địa chỉ dst (do đó địa chỉ dst của kênh sẽ bị bỏ qua).

Trong trường hợp không có bộ đệm TX, chức năng sẽ ngay lập tức
trả về -ENOMEM mà không cần đợi cho đến khi có sẵn.

Hàm chỉ có thể được gọi từ ngữ cảnh tiến trình (hiện tại).
Trả về 0 nếu thành công và giá trị lỗi thích hợp nếu thất bại.

::

cấu trúc vòng/phútsg_endpoint *rpmsg_create_ept(struct rpmsg_device *rpdev,
					  RPMsg_rx_cb_t cb, void *priv,
					  cấu trúc vòng/phútsg_channel_info chinfo);

mọi địa chỉ RPMSG trong hệ thống đều bị ràng buộc với một cuộc gọi lại rx (vì vậy khi
các tin nhắn gửi đến sẽ được gửi đi bằng bus RPMSG bằng cách sử dụng
trình xử lý gọi lại thích hợp) bằng cấu trúc RPMsg_endpoint.

Chức năng này cho phép trình điều khiển tạo một điểm cuối như vậy và bằng cách đó,
liên kết một lệnh gọi lại và có thể cả một số dữ liệu riêng tư với địa chỉ RPMSG
(hoặc một cái đã được biết trước, hoặc một cái sẽ được tự động
được giao cho họ).

Trình điều khiển RPMSG đơn giản không cần gọi RPMSg_create_ept, vì điểm cuối
đã được tạo cho chúng khi chúng được thăm dò bởi bus RPMSG
(sử dụng lệnh gọi lại rx mà họ cung cấp khi đăng ký xe buýt vòng/phút).

Vì vậy, mọi thứ sẽ hoạt động bình thường đối với những trình điều khiển đơn giản: họ đã có
điểm cuối, cuộc gọi lại rx của họ được liên kết với địa chỉ RPMSG của họ và khi
các tin nhắn gửi đến có liên quan sẽ đến (tức là các tin nhắn có địa chỉ dst của họ
bằng với địa chỉ src của kênh RPMSG của họ), trình xử lý của trình điều khiển
được gọi để xử lý nó.

Điều đó nói rằng, các trình điều khiển phức tạp hơn có thể cần phải phân bổ
các địa chỉ vòng/phút bổ sung và liên kết chúng với các lệnh gọi lại rx khác nhau.
Để thực hiện được điều đó, những trình điều khiển đó cần gọi hàm này.
Trình điều khiển nên cung cấp kênh của họ (để điểm cuối mới sẽ liên kết
tới cùng một bộ xử lý từ xa mà kênh của họ thuộc về), một lệnh gọi lại rx
chức năng, một dữ liệu riêng tư tùy chọn (được cung cấp lại khi
cuộc gọi lại rx được gọi) và một địa chỉ mà họ muốn liên kết với
gọi lại. Nếu addr là RPMSG_ADDR_ANY thì RPMsg_create_ept sẽ
tự động gán cho chúng một địa chỉ RPMsg có sẵn (trình điều khiển phải có
một lý do rất chính đáng tại sao không phải lúc nào cũng sử dụng RPMSG_ADDR_ANY ở đây).

Trả về con trỏ tới điểm cuối nếu thành công hoặc NULL bị lỗi.

::

void vòng/phútsg_destroy_ept(cấu trúc vòng/phútsg_điểm cuối *ept);


phá hủy điểm cuối RPMSG hiện có. người dùng nên cung cấp một con trỏ
tới điểm cuối RPMSG đã được tạo trước đó bằng RPMsg_create_ept().

::

int register_rpmsg_driver(structrpmsg_driver *rpdrv);


đăng ký trình điều khiển vòng/phút với bus vòng/phút. người dùng nên cung cấp
một con trỏ tới cấu trúc RPMsg_driver, chứa trình điều khiển
->các hàm thăm dò() và ->remove(), lệnh gọi lại rx và id_table
chỉ định tên của các kênh mà trình điều khiển này quan tâm
được thăm dò.

::

void unregister_rpmsg_driver(structrpmsg_driver *rpdrv);


hủy đăng ký trình điều khiển RPMSG khỏi bus RPMSG. người dùng nên cung cấp
một con trỏ tới cấu trúc RPMsg_driver đã đăng ký trước đó.
Trả về 0 nếu thành công và giá trị lỗi thích hợp nếu thất bại.


Cách sử dụng điển hình
=============

Sau đây là trình điều khiển RPMSG đơn giản, gửi thông báo "Xin chào!" tin nhắn
trên thăm dò() và bất cứ khi nào nó nhận được tin nhắn đến, nó sẽ hủy
nội dung vào bảng điều khiển.

::

#include <linux/dev_printk.h>
  #include <linux/mod_devicetable.h>
  #include <linux/module.h>
  #include <linux/printk.h>
  #include <linux/rpmsg.h>
  #include <linux/types.h>

tĩnh void vòng/phútsg_sample_cb(struct vòng/phútsg_channel *rpdev, void *data, int len,
						void *priv, u32 src)
  {
	print_hex_dump(KERN_INFO, "tin nhắn đến:", DUMP_PREFIX_NONE,
						16, 1, dữ liệu, len, đúng);
  }

int tĩnh vòng/phútsg_sample_probe(cấu trúc vòng/phútsg_channel *rpdev)
  {
	int lỗi;

dev_info(&rpdev->dev, "chnl: 0x%x -> 0x%x\n", rpdev->src, rpdev->dst);

/* gửi tin nhắn trên kênh của chúng tôi */
	err = RPMsg_send(rpdev->ept, "xin chào!", 6);
	nếu (lỗi) {
		dev_err(&rpdev->dev, "rpmsg_send không thành công: %d\n", err);
		trả lại lỗi;
	}

trả về 0;
  }

tĩnh void RPMsg_sample_remove(struct vòng/phútsg_channel *rpdev)
  {
	dev_info(&rpdev->dev, "trình điều khiển máy khách mẫu vòng/phút đã bị xóa\n");
  }

cấu trúc tĩnh vòng/phútsg_device_id vòng/phútsg_driver_sample_id_table[] = {
	{ .name = "rpmsg-client-sample" },
	{ },
  };
  MODULE_DEVICE_TABLE(vòng/phútg, vòng/phútsg_driver_sample_id_table);

cấu trúc tĩnh vòng/phútsg_driver vòng/phútsg_sample_client = {
	.drv.name = KBUILD_MODNAME,
	.id_table = vòng/phútsg_driver_sample_id_table,
	.probe = vòng/phútsg_sample_probe,
	.callback = vòng/phútsg_sample_cb,
	.remove = vòng/phútsg_sample_remove,
  };
  module_rpmsg_driver(rpmsg_sample_client);

.. note::

   a similar sample which can be built and loaded can be found
   in samples/rpmsg/.

Phân bổ các kênh vòng/phút
=============================

Tại thời điểm này, chúng tôi chỉ hỗ trợ phân bổ động các kênh vòng/phút.

Điều này chỉ có thể thực hiện được với bộ xử lý từ xa có VIRTIO_RPMSG_F_NS
bộ tính năng thiết bị virtio. Bit tính năng này có nghĩa là điều khiển từ xa
bộ xử lý hỗ trợ các tin nhắn thông báo dịch vụ tên động.

Khi tính năng này được bật, việc tạo các thiết bị RPMsg (tức là các kênh)
hoàn toàn động: bộ xử lý từ xa thông báo sự tồn tại của
dịch vụ RPMSG từ xa bằng cách gửi tin nhắn dịch vụ tên (có chứa
tên và địa chỉ RPMSG của dịch vụ từ xa, xem struct RPMsg_ns_msg).

Thông báo này sau đó được xử lý bởi bus RPMSG, sau đó nó sẽ được xử lý một cách linh hoạt.
tạo và đăng ký kênh RPMSG (đại diện cho dịch vụ từ xa).
Nếu/khi trình điều khiển RPMSG có liên quan được đăng ký, nó sẽ được thăm dò ngay lập tức
bằng xe buýt và sau đó có thể bắt đầu gửi tin nhắn đến dịch vụ từ xa.

Kế hoạch cũng là bổ sung thêm tính năng tạo tĩnh các kênh RPMSG thông qua virtio
config, nhưng nó chưa được triển khai.
