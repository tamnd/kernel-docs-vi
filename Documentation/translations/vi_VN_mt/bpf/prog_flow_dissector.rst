.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/prog_flow_dissector.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
BPF_PROG_TYPE_FLOW_DISSECTOR
===============================

Tổng quan
========

Trình phân tích luồng là một quy trình phân tích siêu dữ liệu ra khỏi các gói. Đó là
được sử dụng ở nhiều nơi khác nhau trong hệ thống con mạng (RFS, hàm băm luồng, v.v.).

Bộ phân tích luồng BPF là một nỗ lực nhằm triển khai lại logic phân tích luồng dựa trên C
trong BPF để tận dụng tất cả lợi ích của trình xác minh BPF (cụ thể là các giới hạn về
số lượng hướng dẫn và gọi đuôi).

API
===

Các chương trình phân tích dòng BPF hoạt động trên ZZ0000ZZ. Tuy nhiên, chỉ có
cho phép tập hợp các trường giới hạn: ZZ0001ZZ, ZZ0002ZZ và ZZ0003ZZ.
ZZ0004ZZ là ZZ0005ZZ và chứa đầu vào bộ phân tích dòng chảy
và các đối số đầu ra.

Các đầu vào là:
  * ZZ0000ZZ - phần bù ban đầu của tiêu đề mạng
  * ZZ0001ZZ - offset ban đầu của tiêu đề vận chuyển, được khởi tạo thành nhoff
  * ZZ0002ZZ - Loại giao thức L3, được phân tách ra khỏi tiêu đề L2
  * ZZ0003ZZ - cờ tùy chọn

Chương trình BPF của bộ phân tích dòng chảy sẽ điền vào phần còn lại của các trường ZZ0000ZZ. Đối số đầu vào ZZ0001ZZ phải là
cũng được điều chỉnh cho phù hợp.

Mã trả về của chương trình BPF là BPF_OK để biểu thị thành công
mổ xẻ hoặc BPF_DROP để biểu thị lỗi phân tích cú pháp.

__sk_buff->dữ liệu
===============

Trong trường hợp không có VLAN, đây là trạng thái ban đầu của luồng BPF
người mổ xẻ trông giống như::

+------+------+-------------+----------+
  ZZ0000ZZ SMAC ZZ0001ZZ L3_HEADER |
  +------+------+-------------+----------+
                              ^
                              |
                              +-- bộ phân tích dòng chảy bắt đầu từ đây


.. code:: c

  skb->data + flow_keys->nhoff point to the first byte of L3_HEADER
  flow_keys->thoff = nhoff
  flow_keys->n_proto = ETHER_TYPE

Trong trường hợp VLAN, bộ phân tích dòng có thể được gọi với hai trạng thái khác nhau.

Phân tích cú pháp trước VLAN::

+------+------+------+------+----------+----------+
  ZZ0000ZZ SMAC ZZ0001ZZ TCI ZZ0002ZZ L3_HEADER |
  +------+------+------+------+----------+----------+
                        ^
                        |
                        +-- bộ phân tích dòng chảy bắt đầu từ đây

.. code:: c

  skb->data + flow_keys->nhoff point the to first byte of TCI
  flow_keys->thoff = nhoff
  flow_keys->n_proto = TPID

Xin lưu ý rằng TPID có thể là 802.1AD và do đó, chương trình BPF sẽ
phải phân tích thông tin VLAN hai lần đối với các gói được gắn thẻ kép.


Phân tích cú pháp sau VLAN::

+------+------+------+------+----------+----------+
  ZZ0000ZZ SMAC ZZ0001ZZ TCI ZZ0002ZZ L3_HEADER |
  +------+------+------+------+----------+----------+
                                          ^
                                          |
                                          +-- bộ phân tích dòng chảy bắt đầu từ đây

.. code:: c

  skb->data + flow_keys->nhoff point the to first byte of L3_HEADER
  flow_keys->thoff = nhoff
  flow_keys->n_proto = ETHER_TYPE

Trong trường hợp này thông tin VLAN đã được xử lý trước khi phân tích luồng
và không cần phải có bộ phân tích dòng BPF để xử lý nó.


Bài học rút ra ở đây như sau: Chương trình phân tích dòng BPF có thể được gọi bằng
tiêu đề VLAN tùy chọn và sẽ xử lý khéo léo cả hai trường hợp: khi đơn
hoặc gấp đôi VLAN có mặt và khi nó không có mặt. Cùng một chương trình
có thể được gọi cho cả hai trường hợp và sẽ phải được viết cẩn thận để
xử lý cả hai trường hợp.


Cờ
=====

ZZ0000ZZ có thể chứa các cờ đầu vào tùy chọn hoạt động như sau:

* ZZ0000ZZ - báo cho bộ phân tích dòng BPF biết
  tiếp tục phân tích đoạn đầu tiên; hành vi dự kiến ​​mặc định là
  bộ phân tích luồng quay trở lại ngay khi phát hiện ra gói bị phân mảnh;
  được ZZ0001ZZ sử dụng để ước tính độ dài của tất cả các tiêu đề cho GRO.
* ZZ0002ZZ - báo cho bộ phân tích dòng BPF biết
  ngừng phân tích cú pháp ngay khi đạt đến nhãn luồng IPv6; được sử dụng bởi
  ZZ0003ZZ để lấy hàm băm luồng.
* ZZ0004ZZ - yêu cầu bộ phân tích dòng BPF dừng lại
  phân tích cú pháp ngay khi nó đạt đến các tiêu đề được đóng gói; được sử dụng bởi định tuyến
  cơ sở hạ tầng.


Triển khai tham khảo
========================

Xem ZZ0000ZZ để tham khảo
triển khai và ZZ0001ZZ
cho máy xúc. bpftool cũng có thể được sử dụng để tải chương trình phân tích dòng BPF.

Việc thực hiện tham chiếu được tổ chức như sau:
  * Bản đồ ZZ0000ZZ chứa các chương trình con cho từng giao thức L3 được hỗ trợ
  * Quy trình ZZ0001ZZ - điểm vào; nó thực hiện phân tích cú pháp ZZ0002ZZ và
    thực hiện ZZ0003ZZ cho trình xử lý L3 thích hợp

Vì BPF tại thời điểm này không hỗ trợ vòng lặp (hoặc bất kỳ thao tác nhảy lùi nào),
thay vào đó, jmp_table được sử dụng để xử lý nhiều cấp độ đóng gói (và
tùy chọn IPv6).


Hạn chế hiện tại
===================
Trình phân tích luồng BPF không hỗ trợ xuất tất cả siêu dữ liệu trong kernel
Triển khai dựa trên C có thể xuất. Ví dụ đáng chú ý là VLAN đơn (802.1Q)
và nhân đôi thẻ VLAN (802.1AD). Vui lòng tham khảo ZZ0000ZZ
đối với một tập hợp thông tin hiện có thể được xuất từ ngữ cảnh BPF.

Khi bộ phân tích luồng BPF được gắn vào không gian tên mạng gốc (toàn máy
chính sách), người dùng không thể ghi đè nó trong không gian tên mạng con của họ.