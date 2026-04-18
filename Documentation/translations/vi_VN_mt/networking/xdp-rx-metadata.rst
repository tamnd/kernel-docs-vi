.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/xdp-rx-metadata.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================
Siêu dữ liệu XDP RX
===============

Tài liệu này mô tả cách chương trình Đường dẫn dữ liệu eXpress (XDP) có thể truy cập
siêu dữ liệu phần cứng liên quan đến gói bằng cách sử dụng một tập hợp các chức năng trợ giúp,
và cách nó có thể chuyển siêu dữ liệu đó đến những người tiêu dùng khác.

Thiết kế chung
==============

XDP có quyền truy cập vào một tập hợp kfuncs để thao tác siêu dữ liệu trong khung XDP.
Mọi trình điều khiển thiết bị muốn hiển thị siêu dữ liệu gói bổ sung có thể
triển khai các kfuncs này. Tập hợp kfuncs được khai báo trong ZZ0000ZZ
thông qua ZZ0001ZZ.

Hiện tại, các kfunc sau được hỗ trợ. Trong tương lai, càng nhiều
siêu dữ liệu được hỗ trợ, bộ này sẽ phát triển:

.. kernel-doc:: net/core/xdp.c
   :identifiers: bpf_xdp_metadata_rx_timestamp

.. kernel-doc:: net/core/xdp.c
   :identifiers: bpf_xdp_metadata_rx_hash

.. kernel-doc:: net/core/xdp.c
   :identifiers: bpf_xdp_metadata_rx_vlan_tag

Chương trình XDP có thể sử dụng các kfuncs này để đọc siêu dữ liệu vào ngăn xếp
biến để tiêu dùng riêng của mình. Hoặc, để chuyển siêu dữ liệu cho người khác
người tiêu dùng, chương trình XDP có thể lưu trữ nó vào vùng siêu dữ liệu được chứa
trước gói tin. Không phải tất cả các gói cần thiết đều có yêu cầu
siêu dữ liệu có sẵn trong trường hợp trình điều khiển trả về ZZ0000ZZ.

Không phải tất cả kfunc đều phải được trình điều khiển thiết bị triển khai; khi không
được triển khai, những cái mặc định trả về ZZ0000ZZ sẽ được sử dụng
để cho biết trình điều khiển thiết bị chưa triển khai kfunc này.


Trong khung XDP, bố cục siêu dữ liệu (được truy cập qua ZZ0000ZZ) là
như sau::

+----------+--------+------+
  Siêu dữ liệu tùy chỉnh ZZ0000ZZ ZZ0001ZZ
  +----------+--------+------+
             ^ ^
             ZZ0002ZZ
   xdp_buff->data_meta xdp_buff->dữ liệu

Chương trình XDP có thể lưu trữ các mục siêu dữ liệu riêng lẻ vào ZZ0000ZZ này
khu vực ở bất kỳ định dạng nào nó chọn. Người tiêu dùng siêu dữ liệu sau này
sẽ phải đồng ý về định dạng của một số hợp đồng ngoài nhóm (như đối với
trường hợp sử dụng AF_XDP, xem bên dưới).

AF_XDP
======

Trường hợp sử dụng ZZ0000ZZ ngụ ý rằng có một hợp đồng giữa BPF
chương trình chuyển hướng các khung XDP vào ổ cắm ZZ0001ZZ (ZZ0002ZZ) và
người tiêu dùng cuối cùng. Do đó, chương trình BPF phân bổ thủ công một số lượng cố định
byte ra khỏi siêu dữ liệu qua ZZ0003ZZ và gọi một tập hợp con
của kfuncs để điền vào nó. Không gian người dùng ZZ0004ZZ tính toán cho người tiêu dùng
ZZ0005ZZ để định vị siêu dữ liệu đó.
Lưu ý, ZZ0006ZZ được xác định trong ZZ0007ZZ và
ZZ0008ZZ là hằng số dành riêng cho ứng dụng (ZZ0009ZZ nhận
bộ mô tả _not_ mang kích thước của siêu dữ liệu một cách rõ ràng).

Đây là bố cục dành cho người tiêu dùng ZZ0000ZZ (lưu ý thiếu con trỏ ZZ0001ZZ)::

+----------+--------+------+
  Siêu dữ liệu tùy chỉnh ZZ0000ZZ ZZ0001ZZ
  +----------+--------+------+
                               ^
                               |
                        rx_desc->địa chỉ

XDP_PASS
========

Đây là đường dẫn mà các gói được xử lý bởi chương trình XDP được chuyển qua
vào hạt nhân. Hạt nhân tạo ZZ0000ZZ từ ZZ0001ZZ
nội dung. Hiện tại, mọi trình điều khiển đều có mã kernel tùy chỉnh để phân tích
các bộ mô tả và điền siêu dữ liệu ZZ0002ZZ khi thực hiện việc này ZZ0003ZZ
chuyển đổi và siêu dữ liệu XDP không được kernel sử dụng khi xây dựng
ZZ0004ZZ. Tuy nhiên, các chương trình TC-BPF có thể truy cập vùng siêu dữ liệu XDP bằng cách sử dụng
con trỏ ZZ0005ZZ.

Trong tương lai, chúng tôi muốn hỗ trợ trường hợp chương trình XDP
có thể ghi đè một số siêu dữ liệu được sử dụng để xây dựng ZZ0000ZZ.

bpf_redirect_map
================

ZZ0000ZZ có thể chuyển hướng khung sang một thiết bị khác.
Một số thiết bị (như liên kết ethernet ảo) hỗ trợ chạy XDP thứ hai
chương trình sau khi chuyển hướng. Tuy nhiên, người tiêu dùng cuối cùng không có
truy cập vào bộ mô tả phần cứng ban đầu và không thể truy cập bất kỳ
siêu dữ liệu gốc. Điều tương tự cũng áp dụng cho các chương trình XDP được cài đặt
vào devmaps và cpumaps.

Điều này có nghĩa là đối với các gói được chuyển hướng chỉ có siêu dữ liệu tùy chỉnh
hiện được hỗ trợ, phải được chuẩn bị bởi chương trình XDP ban đầu
trước khi chuyển hướng. Nếu khung cuối cùng được chuyển tới kernel,
ZZ0000ZZ được tạo từ khung như vậy sẽ không có bất kỳ siêu dữ liệu phần cứng nào được điền
trong ZZ0001ZZ của nó. Nếu gói như vậy sau đó được chuyển hướng vào ZZ0002ZZ,
cũng sẽ chỉ có quyền truy cập vào siêu dữ liệu tùy chỉnh.

bpf_tail_call
=============

Thêm các chương trình truy cập siêu dữ liệu kfuncs vào ZZ0000ZZ
hiện tại không được hỗ trợ.

Thiết bị được hỗ trợ
=================

Có thể truy vấn kfunc nào mà netdev cụ thể triển khai thông qua
netlink. Xem thuộc tính ZZ0000ZZ được đặt trong
ZZ0001ZZ.

Triển khai trình điều khiển
=====================

Một số thiết bị nhất định có thể thêm siêu dữ liệu vào các gói đã nhận. Tuy nhiên, tính đến thời điểm hiện tại,
ZZ0000ZZ thiếu khả năng truyền đạt kích thước của vùng ZZ0001ZZ
tới người tiêu dùng. Vì vậy, trách nhiệm của người lái xe là sao chép bất kỳ thông tin nào
siêu dữ liệu dành riêng cho thiết bị ra khỏi khu vực siêu dữ liệu và đảm bảo rằng
ZZ0002ZZ đang trỏ tới ZZ0003ZZ trước khi trình bày
khung vào chương trình XDP. Điều này là cần thiết để sau chương trình XDP
điều chỉnh vùng siêu dữ liệu, người tiêu dùng có thể truy xuất siêu dữ liệu một cách đáng tin cậy
địa chỉ sử dụng offset ZZ0004ZZ.

Sơ đồ sau đây cho thấy siêu dữ liệu tùy chỉnh được định vị như thế nào so với
dữ liệu gói và cách điều chỉnh con trỏ để truy cập siêu dữ liệu::

ZZ0000ZZ
  xdp_buff mới->data_meta xdp_buff cũ->data_meta
              ZZ0001ZZ
              |                                            xdp_buff->dữ liệu
              ZZ0002ZZ
   +----------+------------------------------------------------------+------+
   ZZ0003ZZ siêu dữ liệu tùy chỉnh ZZ0004ZZ
   +----------+------------------------------------------------------+------+
              ZZ0005ZZ
              |                                            xdp_desc->addr
              ZZ0006ZZ

ZZ0000ZZ đảm bảo rằng ZZ0001ZZ được căn chỉnh thành 4 byte,
không vượt quá 252 byte và có đủ không gian để xây dựng
xdp_frame. Nếu những điều kiện này không được đáp ứng, nó sẽ trả về lỗi âm. Trong này
trường hợp này, chương trình BPF không nên tiến hành điền dữ liệu vào ZZ0002ZZ
khu vực.

Ví dụ
=======

Xem ZZ0000ZZ và
ZZ0001ZZ để biết ví dụ về
Chương trình BPF xử lý siêu dữ liệu XDP.