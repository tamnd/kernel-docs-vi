.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/nf_flowtable.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
Cơ sở hạ tầng có thể lưu chuyển của Netfilter
====================================

Tài liệu này mô tả cơ sở hạ tầng có thể lưu chuyển của Netfilter cho phép
bạn xác định đường dẫn nhanh thông qua đường dẫn dữ liệu có thể điều chỉnh. Cơ sở hạ tầng này
cũng cung cấp hỗ trợ giảm tải phần cứng. Hỗ trợ lưu lượng cho lớp 3
IPv4 và IPv6 cũng như các giao thức TCP và UDP lớp 4.

Tổng quan
--------

Khi gói đầu tiên của luồng được chuyển tiếp IP thành công
đường dẫn, từ gói thứ hai trở đi, bạn có thể quyết định giảm tải luồng tới
có thể lưu chuyển thông qua bộ quy tắc của bạn. Cơ sở hạ tầng có thể lưu chuyển cung cấp một quy tắc
hành động cho phép bạn chỉ định thời điểm thêm luồng vào bảng lưu trình.

Gói tìm thấy mục nhập phù hợp trong flowtable (tức là lượt truy cập flowtable) là
được truyền đến thiết bị mạng đầu ra thông qua neigh_xmit(), do đó, các gói sẽ bỏ qua
đường dẫn chuyển tiếp IP cổ điển (hiệu ứng rõ ràng là bạn không thấy những đường dẫn này
các gói từ bất kỳ móc Netfilter nào đến sau khi xâm nhập). Trong trường hợp đó
không có mục nào phù hợp trong bảng lưu lượng (tức là lỗi bảng lưu lượng), gói
đi theo con đường chuyển tiếp IP cổ điển.

Flowtable sử dụng bảng băm có thể thay đổi kích thước. Tra cứu dựa trên những điều sau đây
bộ chọn n-tuple: đóng gói giao thức lớp 2 (VLAN và PPPoE), lớp 3
nguồn và đích, cổng nguồn và đích lớp 4 và đầu vào
giao diện (hữu ích trong trường hợp có một số vùng conntrack).

Hành động 'thêm luồng' cho phép bạn điền vào bảng điều khiển, người dùng có chọn lọc
chỉ định những luồng nào được đặt vào bảng lưu lượng. Do đó, các gói tuân theo
đường dẫn chuyển tiếp IP cổ điển trừ khi người dùng hướng dẫn rõ ràng các luồng sử dụng đường dẫn này
đường dẫn chuyển tiếp thay thế mới thông qua chính sách.

Đường dẫn dữ liệu có thể điều chỉnh được biểu diễn trong Hình 1, mô tả IP cổ điển
đường dẫn chuyển tiếp bao gồm các móc Netfilter và đường vòng đường dẫn nhanh có thể lưu chuyển.

::

quá trình không gian người dùng
					  ^ |
					  ZZ0000ZZ
				     _____|____ ____\/___
				    / \ / \
				    ZZ0001ZZ ZZ0002ZZ
				    \__________/ \_________/
					 ^ |
					 ZZ0003ZZ
      _________ __________ --------- _____\/_____
     / \ / \ ZZ0004ZZ / \
  --> xâm nhập ---> định tuyến trước ---> ZZ0005ZZ ZZ0006ZZ --> neigh_xmit
     \_________/ \__________/ ---------- \____________/ ^
       ZZ0007ZZ ^ |
   bàn chảy ZZ0008ZZ |
       ZZ0009ZZ / \ ZZ0010ZZ
    __\/___ ZZ0011ZZ chuyển tiếp ZZ0012ZZ
    ZZ0013ZZ ZZ0014ZZ
    ZZ0015ZZ ZZ0016ZZ
    ZZ0017ZZ ZZ0018ZZ
    ZZ0019ZZ ZZ0020ZZ
       ZZ0021ZZ |
      / \ ZZ0022ZZ
     /hit\_no_|                                                           |
     \ ? / |
      \ / |
       ZZ0024ZZ

Hình 1 Móc Netfilter và tương tác có thể lưu chuyển

Mục có thể lưu chuyển cũng lưu trữ cấu hình NAT, vì vậy tất cả các gói đều được
được đọc sai theo chính sách NAT được chỉ định từ IP cổ điển
đường chuyển tiếp. TTL được giảm đi trước khi gọi neigh_xmit(). Bị phân mảnh
lưu lượng truy cập được chuyển tiếp theo đường dẫn chuyển tiếp IP cổ điển với điều kiện là
tiêu đề vận chuyển bị thiếu, trong trường hợp này, không thể tra cứu flowtable.
Các gói TCP RST và FIN cũng được chuyển đến đường dẫn chuyển tiếp IP cổ điển tới
giải phóng dòng chảy một cách duyên dáng. Các gói vượt quá MTU cũng được chuyển tới
đường dẫn chuyển tiếp cổ điển để báo cáo lỗi ICMP gói quá lớn cho người gửi.

Cấu hình ví dụ
---------------------

Việc kích hoạt flowtable bypass tương đối dễ dàng, bạn chỉ cần tạo một
flowtable và thêm một quy tắc vào chuỗi chuyển tiếp của bạn::

bảng inet x {
		lưu lượng được f {
			mức độ ưu tiên xâm nhập của móc 0; thiết bị = { eth0, eth1 };
		}
		chuỗi y {
			loại móc lọc ưu tiên chuyển tiếp 0; chính sách chấp nhận;
			giao thức ip luồng tcp thêm @f
			gói truy cập 0 byte 0
		}
	}

Ví dụ này thêm 'f' có thể điều chỉnh vào hook xâm nhập của eth0 và eth1
netdevices. Bạn có thể tạo bao nhiêu flowtable tùy thích trong trường hợp cần thiết
thực hiện phân vùng tài nguyên. Mức độ ưu tiên của flowtable xác định thứ tự trong đó
các hook được chạy trong đường ống, điều này thuận tiện trong trường hợp bạn đã có
chuỗi xâm nhập nftables (đảm bảo mức độ ưu tiên của flowtable nhỏ hơn mức ưu tiên
chuỗi xâm nhập của nftables do đó flowtable chạy trước trong đường ống).

Hành động 'giảm tải luồng' từ chuỗi chuyển tiếp 'y' sẽ thêm một mục vào
lưu lượng cho gói đồng bộ TCP đến theo hướng trả lời. Một khi
luồng được giảm tải, bạn sẽ thấy rằng quy tắc ngược trong ví dụ trên
không được cập nhật cho các gói đang được chuyển tiếp qua
chuyển tiếp bỏ qua.

Bạn có thể xác định các luồng đã giảm tải thông qua thẻ [OFFLOAD] khi liệt kê
bảng theo dõi kết nối.

::

# conntrack-L
	tcp 6 src=10.141.10.2 dst=192.168.10.2 sport=52728 dport=5201 src=192.168.10.2 dst=192.168.10.1 sport=5201 dport=52728 [OFFLOAD] mark=0 use=2


Đóng gói lớp 2
---------------------

Kể từ nhân Linux 5.13, cơ sở hạ tầng có thể điều chỉnh được sẽ khám phá ra thực tế
netdevice đằng sau các thiết bị mạng VLAN và PPPoE. Đường dẫn dữ liệu phần mềm có thể lưu chuyển
phân tích các tiêu đề lớp 2 VLAN và PPPoE để trích xuất ethertype và
ID VLAN / ID phiên PPPoE được sử dụng để tra cứu bảng lưu lượng. các
Đường dẫn dữ liệu có thể lưu chuyển cũng xử lý việc giải mã lớp 2.

Bạn không cần thêm các thiết bị PPPoE và VLAN vào flowtable của mình,
thay vào đó, thiết bị thực là đủ để bảng lưu lượng theo dõi luồng của bạn.

Chuyển tiếp cầu nối và IP
------------------------

Kể từ Linux kernel 5.13, bạn có thể thêm các cổng bridge vào flowtable. các
Cơ sở hạ tầng có thể lưu chuyển phát hiện cấu trúc liên kết đằng sau thiết bị cầu. Cái này
cho phép bảng phân luồng xác định đường vòng nhanh giữa các cổng cầu
(được biểu thị là eth1 và eth2 trong hình ví dụ bên dưới) và cổng
thiết bị (được biểu thị là eth0) trong bộ chuyển mạch/bộ định tuyến của bạn.

::

đường vòng nhanh
               .------------------------------.
              / \
              ZZ0003ZZ
              |          / \ \/
              |       br0 eth0..... eth0
              .       / \ ZZ0000ZZ
               -> eth1 eth2
                   .           ZZ0001ZZ
                   .
                   .
                 eth0
               ZZ0002ZZ

Cơ sở hạ tầng có thể lưu chuyển cũng hỗ trợ các hoạt động lọc cầu VLAN
chẳng hạn như PVID và không được gắn thẻ. Bạn cũng có thể xếp thiết bị VLAN cổ điển lên trên
cổng cầu của bạn.

Nếu bạn muốn lưu đồ của bạn xác định đường dẫn nhanh giữa cầu của bạn
cổng và đường dẫn chuyển tiếp IP của bạn, bạn phải thêm các cổng cầu nối của mình (như
được đại diện bởi netdevice thực) theo định nghĩa có thể lưu chuyển của bạn.

quầy
--------

Flowtable có thể đồng bộ hóa bộ đếm gói và byte với bộ đếm hiện có
mục theo dõi kết nối bằng cách chỉ định câu lệnh truy cập trong flowtable của bạn
định nghĩa, ví dụ

::

bảng inet x {
		lưu lượng được f {
			mức độ ưu tiên xâm nhập của móc 0; thiết bị = { eth0, eth1 };
			quầy tính tiền
		}
	}

Hỗ trợ bộ đếm có sẵn kể từ nhân Linux 5.7.

Giảm tải phần cứng
----------------

Nếu thiết bị mạng của bạn cung cấp hỗ trợ giảm tải phần cứng, bạn có thể bật nó bằng cách
có nghĩa là cờ 'giảm tải' trong định nghĩa bảng lưu lượng của bạn, ví dụ:

::

bảng inet x {
		lưu lượng được f {
			mức độ ưu tiên xâm nhập của móc 0; thiết bị = { eth0, eth1 };
			dỡ cờ;
		}
	}

Có một hàng công việc bổ sung các luồng vào phần cứng. Lưu ý rằng một số
các gói vẫn có thể chạy trên đường dẫn phần mềm có thể điều chỉnh cho đến khi hàng đợi công việc được xử lý xong.
một cơ hội để giảm tải luồng cho thiết bị mạng.

Bạn có thể xác định các luồng giảm tải phần cứng thông qua thẻ [HW_OFFLOAD] khi
liệt kê bảng theo dõi kết nối của bạn. Xin lưu ý rằng thẻ [OFFLOAD]
đề cập đến chế độ giảm tải phần mềm, do đó có sự khác biệt giữa [OFFLOAD]
đề cập đến đường dẫn nhanh có thể điều chỉnh bằng phần mềm và [HW_OFFLOAD] đề cập đến
tới đường dẫn dữ liệu giảm tải phần cứng đang được luồng sử dụng.

Cơ sở hạ tầng giảm tải phần cứng có thể lưu chuyển cũng hỗ trợ cho DSA
(Kiến trúc chuyển mạch phân tán).

Hạn chế
-----------

Flowtable hoạt động giống như một bộ đệm. Các mục trong flowtable có thể bị lỗi thời nếu
địa chỉ MAC đích hoặc thiết bị mạng đầu ra được sử dụng cho
truyền động thay đổi.

Đây có thể là một vấn đề nếu:

- Bạn chạy flowtable ở chế độ phần mềm và kết hợp bridge và IP
  chuyển tiếp trong thiết lập của bạn.
- Giảm tải phần cứng được kích hoạt.

Đọc thêm
------------

Tài liệu này dựa trên các bài viết của LWN.net [1]_\ [2]_. Rafal Milecki
cũng đã thực hiện một bản tóm tắt rất đầy đủ và toàn diện mang tên "Trạng thái mạng
tăng tốc" mô tả mọi thứ diễn ra như thế nào trước khi cơ sở hạ tầng này được hoàn thiện
viết chính [3]_ và nó cũng tạo nên một bản tóm tắt sơ bộ về tác phẩm này [4]_.

.. [1] https://lwn.net/Articles/738214/
.. [2] https://lwn.net/Articles/742164/
.. [3] http://lists.infradead.org/pipermail/lede-dev/2018-January/010830.html
.. [4] http://lists.infradead.org/pipermail/lede-dev/2018-January/010829.html