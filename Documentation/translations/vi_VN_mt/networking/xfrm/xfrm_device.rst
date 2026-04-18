.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/xfrm/xfrm_device.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _xfrm_device:

====================================================
Thiết bị XFRM - giảm tải tính toán IPsec
====================================================

Shannon Nelson <shannon.nelson@oracle.com>
Leon Romanovsky <leonro@nvidia.com>


Tổng quan
========

IPsec là một tính năng hữu ích để bảo mật lưu lượng mạng, nhưng
chi phí tính toán cao: liên kết 10Gbps có thể dễ dàng bị hạ xuống
đến dưới 1Gbps, tùy thuộc vào cấu hình lưu lượng và liên kết.
May mắn thay, có những NIC cung cấp tính năng giảm tải IPsec dựa trên phần cứng.
có thể tăng đáng kể thông lượng và giảm mức sử dụng CPU.  XFRM
Giao diện thiết bị cho phép trình điều khiển NIC cung cấp quyền truy cập ngăn xếp vào
giảm tải phần cứng.

Hiện tại, có hai loại giảm tải phần cứng mà kernel hỗ trợ:

* Giảm tải mật mã IPsec:

* NIC thực hiện mã hóa/giải mã
   * Hạt nhân làm mọi việc khác

* Giảm tải gói IPsec:

* NIC thực hiện mã hóa/giải mã
   * NIC thực hiện đóng gói
   * Kernel và NIC có SA và chính sách không đồng bộ
   * NIC xử lý các trạng thái SA và chính sách
   * Kernel nói chuyện với keymanager

Quyền truy cập của người dùng vào phần giảm tải thường thông qua một hệ thống như
libreswan hoặc KAME/raccoon, nhưng bộ lệnh iproute2 'ip xfrm' có thể
thuận tiện khi thử nghiệm.  Một lệnh ví dụ có thể trông giống như thế nào đó
như thế này để giảm tải tiền điện tử::

ip x s thêm proto esp dst 14.0.0.70 src 14.0.0.52 spi 0x07 chế độ vận chuyển \
     reqid 0x07 cửa sổ phát lại 32 \
     aead 'rfc4106(gcm(aes))' 0x444342413433323124232222114131211f4f3f2f1 128 \
     sel src 14.0.0.52/24 dst 14.0.0.70/24 proto tcp \
     giảm tải thư mục dev eth4 trong

và để giảm tải gói::

ip x s thêm proto esp dst 14.0.0.70 src 14.0.0.52 spi 0x07 chế độ vận chuyển \
     reqid 0x07 cửa sổ phát lại 32 \
     aead 'rfc4106(gcm(aes))' 0x444342413433323124232222114131211f4f3f2f1 128 \
     sel src 14.0.0.52/24 dst 14.0.0.70/24 proto tcp \
     giảm tải gói thư mục dev eth4 trong

ip x p thêm src 14.0.0.70 dst 14.0.0.52 giảm tải gói thư mục dev eth4 trong
  tmpl src 14.0.0.70 dst 14.0.0.52 proto esp reqid 10000 mode vận chuyển

Đúng, điều đó thật xấu xí, nhưng đó chính là mục đích của các tập lệnh shell và/hoặc libreswan.



Lệnh gọi lại để triển khai
======================

::

/* từ include/linux/netdevice.h */
  cấu trúc xfrmdev_ops {
        /* Lệnh gọi lại giảm tải tiền điện tử và gói */
	int (*xdo_dev_state_add)(struct net_device *dev,
                                     cấu trúc xfrm_state *x,
                                     struct netlink_ext_ack *extack);
	khoảng trống (*xdo_dev_state_delete)(struct net_device *dev,
                                        cấu trúc xfrm_state *x);
	khoảng trống (*xdo_dev_state_free)(struct net_device *dev,
                                      cấu trúc xfrm_state *x);
	bool (*xdo_dev_offload_ok) (struct sk_buff *skb,
				       cấu trúc xfrm_state *x);
	khoảng trống (*xdo_dev_state_advance_esn) (struct xfrm_state *x);
	khoảng trống (*xdo_dev_state_update_stats) (struct xfrm_state *x);

/* Chỉ gọi lại giảm tải gói */
	int (*xdo_dev_policy_add) (struct xfrm_policy *x, struct netlink_ext_ack *extack);
	khoảng trống (*xdo_dev_policy_delete) (struct xfrm_policy *x);
	khoảng trống (*xdo_dev_policy_free) (struct xfrm_policy *x);
  };

Trình điều khiển NIC cung cấp giảm tải ipsec sẽ cần triển khai lệnh gọi lại
liên quan đến giảm tải được hỗ trợ để cung cấp giảm tải cho mạng
hệ thống con XFRM của ngăn xếp. Ngoài ra, các bit tính năng NETIF_F_HW_ESP và
NETIF_F_HW_ESP_TX_CSUM sẽ báo hiệu sự sẵn có của việc giảm tải.



Chảy
====

Tại thời điểm thăm dò và trước lệnh gọi register_netdev(), trình điều khiển nên
thiết lập cấu trúc dữ liệu cục bộ và lệnh gọi lại XFRM, đồng thời đặt các bit tính năng.
Trình nghe mã XFRM sẽ hoàn tất quá trình thiết lập trên NETDEV_REGISTER.

::

bộ chuyển đổi->netdev->xfrmdev_ops = &ixgbe_xfrmdev_ops;
		bộ chuyển đổi->netdev->tính năng |= NETIF_F_HW_ESP;
		bộ chuyển đổi->netdev->hw_enc_features |= NETIF_F_HW_ESP;

Khi các SA mới được thiết lập với yêu cầu về tính năng "giảm tải",
xdo_dev_state_add() của trình điều khiển sẽ được cấp SA mới để được giảm tải
và một dấu hiệu cho biết nó dành cho Rx hay Tx.  Người lái xe nên

- xác minh thuật toán được hỗ trợ để giảm tải
	- lưu trữ thông tin SA (khóa, muối, ip đích, giao thức, v.v.)
	- kích hoạt tính năng giảm tải CTNH của SA
	- trả về giá trị trạng thái:

==================================================
		0 thành công
		-EOPNETSUPP không hỗ trợ giảm tải, hãy thử SW IPsec,
                              không áp dụng cho chế độ giảm tải gói
		khác không thực hiện được yêu cầu
		==================================================

Trình điều khiển cũng có thể đặt offload_handle trong SA, một con trỏ void mờ
có thể được sử dụng để truyền tải ngữ cảnh vào các yêu cầu giảm tải đường dẫn nhanh::

xs->xso.offload_handle = bối cảnh;


Khi ngăn xếp mạng đang chuẩn bị gói IPsec cho SA có
được thiết lập để giảm tải, đầu tiên nó gọi vào xdo_dev_offload_ok() với
skb và trạng thái giảm tải dự định để hỏi người lái xe xem liệu việc giảm tải có xảy ra không
sẽ có thể sử dụng được.  Điều này có thể kiểm tra thông tin gói để chắc chắn rằng
giảm tải có thể được hỗ trợ (ví dụ: IPv4 hoặc IPv6, không có tùy chọn IPv4, v.v.) và
trả về đúng hoặc sai để biểu thị sự hỗ trợ của nó. Trong trường hợp trình điều khiển không thực hiện
cuộc gọi lại này, ngăn xếp sẽ cung cấp các giá trị mặc định hợp lý.

Chế độ giảm tải tiền điện tử:
Khi sẵn sàng gửi, trình điều khiển cần kiểm tra gói Tx để biết
giảm tải thông tin, bao gồm bối cảnh mờ đục và thiết lập gói
gửi cho phù hợp::

xs = xfrm_input_state(skb);
		bối cảnh = xs->xso.offload_handle;
		thiết lập HW để gửi

Ngăn xếp đã chèn các tiêu đề IPsec thích hợp vào
dữ liệu gói, việc giảm tải chỉ cần thực hiện mã hóa và sửa chữa
các giá trị tiêu đề.


Khi một gói được nhận và HW đã chỉ ra rằng nó đã giảm tải
giải mã, trình điều khiển cần thêm tham chiếu đến SA đã giải mã vào
skb của gói tin.  Tại thời điểm này, dữ liệu sẽ được giải mã nhưng
Tiêu đề IPsec vẫn còn trong dữ liệu gói; chúng sẽ bị xóa sau đó
ngăn xếp trong xfrm_input().

1. Tìm và giữ SA đã được sử dụng cho Rx skb::

/* lấy spi, giao thức và IP đích từ các tiêu đề gói */
		xs = tìm xs từ (spi, giao thức, dest_IP)
		xfrm_state_hold(xs);

2. Lưu trữ thông tin trạng thái vào skb::

sp = secpath_set(skb);
		if (!sp) trả về;
		sp->xvec[sp->len++] = xs;
		sp->olen++;

3. Cho biết trạng thái thành công và/hoặc lỗi của quá trình giảm tải::

xo = xfrm_offload(skb);
		xo->flags = CRYPTO_DONE;
		xo->trạng thái = crypto_status;

4. Chuyển gói tin tới napi_gro_receive() như bình thường.

Trong chế độ ESN, xdo_dev_state_advance_esn() được gọi từ
xfrm_replay_advance_esn() cho RX và xfrm_replay_overflow_offload_esn cho TX.
Trình điều khiển sẽ kiểm tra số thứ tự gói và cập nhật trạng thái máy HW ESN nếu cần.

Chế độ giảm tải gói:
HW thêm và xóa các tiêu đề XFRM. Vì vậy, trong đường dẫn RX, ngăn xếp XFRM bị bỏ qua nếu HW
báo cáo thành công. Trong đường dẫn TX, gói rời khỏi kernel mà không có tiêu đề bổ sung
và không được mã hóa thì CTNH có trách nhiệm thực hiện.

Khi người dùng xóa SA, xdo_dev_state_delete() của trình điều khiển
và xdo_dev_policy_delete() được yêu cầu tắt tính năng giảm tải.  Sau đó,
xdo_dev_state_free() và xdo_dev_policy_free() được gọi từ thùng rác
quy trình thu thập sau tất cả các lần tham chiếu đến trạng thái và chính sách
đã bị xóa và mọi tài nguyên còn lại có thể được xóa cho
trạng thái giảm tải.  Người lái xe sử dụng những thứ này như thế nào sẽ phụ thuộc vào từng điều kiện cụ thể.
nhu cầu phần cứng.

Khi một netdev được đặt thành DOWN, trình nghe netdev của ngăn xếp XFRM sẽ gọi
xdo_dev_state_delete(), xdo_dev_policy_delete(), xdo_dev_state_free() và
xdo_dev_policy_free() trên mọi trạng thái giảm tải còn lại.

Kết quả của các gói xử lý CTNH, lõi XFRM không thể đếm được giới hạn cứng, giới hạn mềm.
CTNH/người lái xe có trách nhiệm thực hiện và cung cấp số liệu chính xác khi
xdo_dev_state_update_stats() được gọi. Trong trường hợp một trong những giới hạn này
xảy ra, người lái xe cần gọi tới xfrm_state_check_expire() để đảm bảo
XFRM thực hiện trình tự khóa lại.