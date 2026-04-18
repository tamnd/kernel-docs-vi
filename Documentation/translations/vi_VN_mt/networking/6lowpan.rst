.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/6lowpan.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================================
Phòng dữ liệu riêng Netdev cho 6 giao diện lowpan
==============================================

Tất cả các thiết bị mạng có khả năng 6lowpan, nghĩa là tất cả các giao diện với ARPHRD_6LOWPAN,
phải có "struct lowpan_priv" ở đầu netdev_priv.

Priv_size của mỗi giao diện phải được tính bằng::

dev->priv_size = LOWPAN_PRIV_SIZE(LL_6LOWPAN_PRIV_DATA);

Trong đó LL_PRIV_6LOWPAN_DATA là cấu trúc dữ liệu riêng tư của lớp liên kết 6lowpan.
Để truy cập cấu trúc LL_PRIV_6LOWPAN_DATA, bạn có thể truyền ::

lowpan_priv(dev)-priv;

vào cấu trúc LL_6LOWPAN_PRIV_DATA của bạn.

Trước khi đăng ký giao diện netdev lowpan, bạn phải chạy ::

lowpan_netdev_setup(dev, LOWPAN_LLTYPE_FOOBAR);

trong đó LOWPAN_LLTYPE_FOOBAR là định nghĩa cho loại lớp liên kết 6LoWAN của bạn
enum lowpan_lltypes.

Ví dụ để đánh giá riêng tư thông thường bạn có thể làm::

cấu trúc nội tuyến tĩnh lowpan_priv_foobar *
 lowpan_foobar_priv(struct net_device *dev)
 {
	return (struct lowpan_priv_foobar *)lowpan_priv(dev)->priv;
 }

chuyển đổi (dev->type) {
 vỏ ARPHRD_6LOWPAN:
	lowpan_priv = lowpan_priv(dev);
	/* làm những điều tuyệt vời liên quan đến ARPHRD_6LOWPAN */
	chuyển đổi (lowpan_priv->lltype) {
	vỏ LOWPAN_LLTYPE_FOOBAR:
		/* xử lý 802.15.4 6LoWPAN tại đây */
		lowpan_foobar_priv(dev)->bar = foo;
		phá vỡ;
	...
}
	phá vỡ;
 ...
 }

Trong trường hợp nhánh 6lowpan chung ("net/6lowpan"), bạn có thể xóa séc
trên ARPHRD_6LOWPAN, vì bạn có thể chắc chắn rằng các hàm này được gọi
bởi giao diện ARPHRD_6LOWPAN.