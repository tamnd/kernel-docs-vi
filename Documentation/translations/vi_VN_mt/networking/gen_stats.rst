.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/gen_stats.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================================
Thống kê mạng chung cho người dùng netlink
===============================================

Bộ đếm thống kê được nhóm thành các cấu trúc:

==================================================================
Cấu trúc kiểu TLV Mô tả
==================================================================
gnet_stats_basic TCA_STATS_BASIC Thống kê cơ bản
gnet_stats_rate_est TCA_STATS_RATE_EST Công cụ ước tính tỷ lệ
gnet_stats_queue TCA_STATS_QUEUE Thống kê hàng đợi
TCA_STATS_APP Ứng dụng cụ thể
==================================================================


Thu thập:
-----------

Khai báo các cấu trúc thống kê bạn cần ::

cấu trúc mystruct {
		struct gnet_stats_basic bstats;
		cấu trúc gnet_stats_queue qstats;
		...
	};

Cập nhật số liệu thống kê, chỉ trong các phương thức dequeue(), (trong khi sở hữu qdisc->running)::

mystruct->tstats.packet++;
	mystruct->qstats.backlog += skb->pkt_len;


Xuất sang không gian người dùng (Dump):
---------------------------

::

my_dumping_routine(struct sk_buff *skb, ...)
    {
	    kết xuất cấu trúc gnet_dump;

if (gnet_stats_start_copy(skb, TCA_STATS2, &mystruct->lock, &dump,
				    TCA_PAD) < 0)
		    đi đến rttatr_failure;

if (gnet_stats_copy_basic(&dump, &mystruct->bstats) < 0 ||
		gnet_stats_copy_queue(&dump, &mystruct->qstats) < 0 ||
		    gnet_stats_copy_app(&dump, &xstats, sizeof(xstats)) < 0)
		    đi đến rttatr_failure;

nếu (gnet_stats_finish_copy(&dump) < 0)
		    đi đến rttatr_failure;
	    ...
    }

Khả năng tương thích ngược TCA_STATS/TCA_XSTATS:
--------------------------------------------

Người dùng trước của struct tc_stats và xstats có thể duy trì ngược
khả năng tương thích bằng cách gọi các trình bao bọc tương thích để tiếp tục cung cấp
các loại TLV hiện có::

my_dumping_routine(struct sk_buff *skb, ...)
    {
	nếu (gnet_stats_start_copy_compat(skb, TCA_STATS2, TCA_STATS,
					TCA_XSTATS, &mystruct->lock, &dump,
					TCA_PAD) < 0)
		    đi đến rttatr_failure;
	    ...
    }

Cấu trúc tc_stats sẽ được điền trong các lệnh gọi gnet_stats_copy_*
và được thêm vào skb. TCA_XSTATS được cung cấp nếu gnet_stats_copy_app
đã được gọi.


Khóa:
--------

Khóa được thực hiện trước khi viết và phát hành sau khi tất cả số liệu thống kê đã được thực hiện
đã được viết. Khóa luôn được giải phóng trong trường hợp có lỗi. bạn
có trách nhiệm đảm bảo rằng khóa được khởi tạo.


Công cụ ước tính tỷ lệ:
---------------

0) Chuẩn bị thuộc tính ước tính. Nhiều khả năng điều này sẽ có trong người dùng
   không gian. Giá trị của TLV này phải chứa cấu trúc tc_estimator.
   Như thường lệ, TLV như vậy cần được căn chỉnh 32 bit và do đó
   độ dài cần phải được đặt thích hợp, v.v. Khoảng ước tính
   và nhật ký ewma cần được chuyển đổi thành các giá trị thích hợp.
   tc_estimator.c::tc_setup_estimator() được khuyến khích sử dụng làm
   thói quen chuyển đổi. Nó thực hiện một số điều thông minh. Phải mất một thời gian
   khoảng thời gian tính bằng micro giây, hằng số thời gian cũng tính bằng micro giây và cấu trúc
   tc_estimator được điền. tc_estimator được trả về có thể là
   được vận chuyển đến hạt nhân.  Chuyển cấu trúc như vậy sang loại TLV
   TCA_RATE vào mã của bạn trong kernel.

Trong kernel khi thiết lập:

1) trước tiên hãy đảm bảo bạn có số liệu thống kê cơ bản và thiết lập thống kê tỷ lệ.
2) đảm bảo bạn đã khởi tạo khóa thống kê được sử dụng để thiết lập như vậy
   số liệu thống kê.
3) Bây giờ hãy khởi tạo một công cụ ước tính mới ::

int ret = gen_new_estimator(my_basicstats,my_rate_est_stats,
	mystats_lock, attr_with_tcestimator_struct);

nếu ret == 0
	sự thành công
    khác
	thất bại

Từ giờ trở đi, mỗi khi bạn đổ my_rate_est_stats nó sẽ chứa
thông tin cập nhật.

Khi bạn đã hoàn tất, hãy gọi gen_kill_estimator(my_basicstats,
my_rate_est_stats) Đảm bảo rằng my_basicstats và my_rate_est_stats
vẫn hợp lệ (tức là vẫn tồn tại) tại thời điểm thực hiện cuộc gọi này.


tác giả:
--------
- Thomas Graf <tgraf@suug.ch>
- Jamal Hadi Salim <hadi@cyberus.ca>