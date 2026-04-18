.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/devlink-dpipe.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==============
Devlink DPIPE
=============

Lý lịch
==========

Trong khi thực hiện quá trình giảm tải phần cứng, phần lớn phần cứng
không thể trình bày chi tiết cụ thể. Những chi tiết này rất hữu ích cho việc gỡ lỗi và
ZZ0000ZZ cung cấp một cách tiêu chuẩn hóa để cung cấp khả năng hiển thị
quá trình dỡ tải.

Ví dụ: thuật toán khớp tiền tố dài nhất định tuyến (LPM) được sử dụng bởi
Nhân Linux có thể khác với việc triển khai phần cứng. Gỡ lỗi đường ống
API (DPIPE) nhằm mục đích cung cấp cho người dùng khả năng hiển thị của ASIC
đường ống một cách chung chung.

Quá trình giảm tải phần cứng dự kiến sẽ được thực hiện theo cách mà người dùng
không thể phân biệt được giữa phần cứng và phần mềm
thực hiện. Trong quá trình này, các chi tiết cụ thể về phần cứng bị bỏ qua. trong
thực tế những chi tiết đó có thể có rất nhiều ý nghĩa và cần được bộc lộ theo một cách nào đó
cách tiêu chuẩn.

Vấn đề này thậm chí còn phức tạp hơn khi người ta muốn giảm tải
đường dẫn điều khiển của toàn bộ mạng tới switch ASIC. do
sự khác biệt trong mô hình phần cứng và phần mềm, một số quy trình không thể thực hiện được
được thể hiện một cách chính xác.

Một ví dụ là thuật toán LPM của kernel, trong nhiều trường hợp có sự khác biệt
rất nhiều đến việc triển khai phần cứng. Cấu hình API giống nhau,
nhưng người ta không thể dựa vào Cơ sở thông tin chuyển tiếp (FIB) để trông giống như
Mức nén đường dẫn trie (LPC-trie) trong phần cứng.

Trong nhiều tình huống cố gắng phân tích lỗi hệ thống chỉ dựa trên
kết xuất của kernel có thể không đủ. Bằng cách kết hợp dữ liệu này với dữ liệu bổ sung
thông tin về phần cứng cơ bản, việc gỡ lỗi này có thể được thực hiện
dễ dàng hơn; Ngoài ra, thông tin có thể hữu ích khi gỡ lỗi
các vấn đề về hiệu suất.

Tổng quan
========

Giao diện ZZ0000ZZ thu hẹp khoảng cách này. Đường dẫn của phần cứng là
được mô hình hóa dưới dạng biểu đồ của các bảng trận đấu/hành động. Mỗi bảng đại diện cho một nội dung cụ thể
khối phần cứng. Mô hình này không mới, lần đầu tiên được sử dụng bởi ngôn ngữ P4.

Theo truyền thống, nó được sử dụng như một mô hình thay thế cho phần cứng
cấu hình, nhưng giao diện ZZ0000ZZ sử dụng nó để hiển thị
mục đích như một công cụ bổ sung tiêu chuẩn. Góc nhìn của hệ thống từ
ZZ0001ZZ sẽ thay đổi theo những thay đổi được thực hiện bởi
công cụ cấu hình tiêu chuẩn.

Ví dụ: việc triển khai Danh sách kiểm soát truy cập (ACL) là khá phổ biến
sử dụng Bộ nhớ có thể định địa chỉ nội dung bậc ba (TCAM). Bộ nhớ TCAM có thể
được chia thành các vùng TCAM. Bộ lọc TC phức tạp có thể có nhiều quy tắc với
mức độ ưu tiên khác nhau và các khóa tra cứu khác nhau. Mặt khác phần cứng
Vùng TCAM có khóa tra cứu được xác định trước. Giảm tải các quy tắc lọc TC
sử dụng công cụ TCAM có thể dẫn đến nhiều vùng TCAM được kết nối với nhau
trong một chuỗi (có thể ảnh hưởng đến độ trễ của đường dẫn dữ liệu). Để đáp lại TC mới
lọc các bảng mới sẽ được tạo để mô tả các vùng đó.

Người mẫu
=====

Mô hình ZZ0000ZZ giới thiệu một số đối tượng:

* tiêu đề
  * bảng
  * mục

ZZ0000ZZ mô tả các định dạng gói và cung cấp tên cho các trường bên trong
gói tin. ZZ0001ZZ mô tả các khối phần cứng. Một ZZ0002ZZ mô tả
nội dung thực tế của một bảng cụ thể.

Đường dẫn phần cứng không phải là cổng cụ thể mà mô tả toàn bộ
ASIC. Do đó, nó được gắn với phần trên cùng của cơ sở hạ tầng ZZ0000ZZ.

Trình điều khiển có thể đăng ký và hủy đăng ký bảng trong thời gian chạy, để hỗ trợ
hành vi năng động. Hành vi động này là bắt buộc để mô tả phần cứng
các khối như vùng TCAM có thể được phân bổ và giải phóng một cách linh hoạt.

ZZ0000ZZ thường không dành cho cấu hình. Ngoại lệ
là tính phần cứng cho một bảng cụ thể.

Các lệnh sau được sử dụng để lấy các đối tượng ZZ0000ZZ từ
không gian người dùng:

* ZZ0000ZZ: Nhận mô tả của bảng.
  * ZZ0001ZZ: Nhận các tiêu đề được hỗ trợ của thiết bị.
  * ZZ0002ZZ: Nhận các mục hiện tại của bảng.
  * ZZ0003ZZ: Bật hoặc tắt bộ đếm trên bàn.

Bàn
-----

Trình điều khiển nên thực hiện các thao tác sau cho mỗi bảng:

* ZZ0000ZZ: Kết xuất các kết quả được hỗ trợ.
  * ZZ0001ZZ: Kết xuất các hành động được hỗ trợ.
  * ZZ0002ZZ: Kết xuất nội dung thực tế của bảng.
  * ZZ0003ZZ: Đồng bộ hóa phần cứng với bộ đếm được bật hoặc
    bị vô hiệu hóa.

Tiêu đề/Trường
------------

Theo cách tương tự, các tiêu đề và trường P4 được sử dụng để mô tả
hành vi. Có một chút khác biệt giữa các tiêu đề giao thức tiêu chuẩn
và siêu dữ liệu ASIC cụ thể. Các tiêu đề giao thức phải được khai báo trong
ZZ0000ZZ lõi API. Mặt khác, dữ liệu meta ASIC là dành riêng cho trình điều khiển
và cần được xác định trong trình điều khiển. Ngoài ra, mỗi trình điều khiển cụ thể
tệp tài liệu devlink sẽ ghi lại ZZ0001ZZ dành riêng cho trình điều khiển
tiêu đề nó thực hiện. Các tiêu đề và các trường được xác định bằng cách liệt kê.

Để cung cấp khả năng hiển thị cao hơn, một số trường siêu dữ liệu ASIC có thể được
được ánh xạ tới các đối tượng kernel. Ví dụ: các chỉ mục giao diện bộ định tuyến nội bộ có thể
được ánh xạ trực tiếp tới thiết bị mạng ifindex. Các chỉ mục bảng FIB được sử dụng bởi
các bảng Định tuyến và Chuyển tiếp Ảo (VRF) khác nhau có thể được ánh xạ tới
chỉ số bảng định tuyến nội bộ.

Cuộc thi đấu
-----

Các trận đấu được giữ nguyên và gần với hoạt động của phần cứng. Các loại kết hợp như
LPM không được hỗ trợ do đây chính xác là quy trình chúng tôi mong muốn
để mô tả đầy đủ chi tiết. Ví dụ về các trận đấu:

* ZZ0000ZZ: Khớp chính xác trên một trường cụ thể.
  * ZZ0001ZZ: So khớp chính xác trên một trường cụ thể sau khi tạo mặt nạ.
  * ZZ0002ZZ: Phù hợp trên một phạm vi cụ thể.

Id của tiêu đề và trường phải được chỉ định để
xác định lĩnh vực cụ thể. Hơn nữa, chỉ mục tiêu đề phải là
được chỉ định để phân biệt nhiều tiêu đề cùng loại trong một
gói (đường hầm).

Hoạt động
------

Tương tự như khớp, các thao tác được giữ nguyên và gần với phần cứng
hoạt động. Ví dụ:

* ZZ0000ZZ: Sửa đổi giá trị trường.
  * ZZ0001ZZ: Tăng giá trị trường.
  * ZZ0002ZZ: Thêm tiêu đề.
  * ZZ0003ZZ: Xóa tiêu đề.

Lối vào
-----

Các mục của một bảng cụ thể có thể được kết xuất theo yêu cầu. Mỗi mục nhập là
được xác định bằng một chỉ mục và các thuộc tính của nó được mô tả bằng một danh sách
giá trị trận đấu/hành động và bộ đếm cụ thể. Bằng cách loại bỏ nội dung của bảng,
tương tác giữa các bảng có thể được giải quyết.

Ví dụ trừu tượng
===================

Sau đây là một ví dụ về mô hình trừu tượng của phần L3 của
Phổ Mellanox ASIC. Các khối được mô tả theo thứ tự chúng xuất hiện
đường ống. Kích thước bảng trong các ví dụ sau là không có thật
kích thước phần cứng và được cung cấp cho mục đích trình diễn.

LPM
---

Thuật toán LPM có thể được triển khai dưới dạng danh sách các bảng băm. Mỗi hàm băm
bảng chứa các tuyến đường có cùng độ dài tiền tố. Gốc của danh sách là
/32 và trong trường hợp bị bỏ sót, phần cứng sẽ tiếp tục thực hiện hàm băm tiếp theo
cái bàn. Độ sâu của tìm kiếm sẽ ảnh hưởng đến độ trễ của đường dẫn dữ liệu.

Trong trường hợp có lượt truy cập, mục nhập chứa thông tin về giai đoạn tiếp theo của
đường dẫn giải quyết địa chỉ MAC. Giai đoạn tiếp theo có thể là cục bộ
bảng máy chủ cho các tuyến được kết nối trực tiếp hoặc bảng kề cho các bước nhảy tiếp theo.
Trường ZZ0000ZZ được sử dụng để kết nối hai bảng LPM.

.. code::

    table lpm_prefix_16 {
      size: 4096,
      counters_enabled: true,
      match: { meta.vr_id: exact,
               ipv4.dst_addr: exact_mask,
               ipv6.dst_addr: exact_mask,
               meta.lpm_prefix: exact },
      action: { meta.adj_index: set,
                meta.adj_group_size: set,
                meta.rif_port: set,
                meta.lpm_prefix: set },
    }

Máy chủ cục bộ
----------

Trong trường hợp các tuyến đường địa phương, việc tra cứu LPM đã giải quyết được lối ra
giao diện bộ định tuyến (RIF), tuy nhiên địa chỉ MAC chính xác vẫn chưa được biết. Địa phương
bảng máy chủ là bảng băm kết hợp id giao diện đầu ra với
địa chỉ IP đích làm khóa. Kết quả là địa chỉ MAC.

.. code::

    table local_host {
      size: 4096,
      counters_enabled: true,
      match: { meta.rif_port: exact,
               ipv4.dst_addr: exact},
      action: { ethernet.daddr: set }
    }

Sự kề cận
---------

Trong trường hợp các tuyến đường từ xa, bảng này thực hiện ECMP. Tra cứu LPM cho kết quả
Kích thước và chỉ mục nhóm ECMP đóng vai trò là phần bù chung cho bảng này.
Đồng thời một hàm băm của gói được tạo ra. Dựa trên kích thước nhóm ECMP
và hàm băm của gói sẽ tạo ra phần bù cục bộ. Nhiều mục LPM có thể
trỏ đến cùng một nhóm kề.

.. code::

    table adjacency {
      size: 4096,
      counters_enabled: true,
      match: { meta.adj_index: exact,
               meta.adj_group_size: exact,
               meta.packet_hash_index: exact },
      action: { ethernet.daddr: set,
                meta.erif: set }
    }

ERIF
----

Trong trường hợp RIF đầu ra và MAC đích đã được giải quyết trước đó
bảng, bảng này thực hiện nhiều thao tác như giảm TTL và kiểm tra MTU.
Sau đó, quyết định chuyển tiếp/bớt được thực hiện và số liệu thống kê của cổng L3 được
được cập nhật dựa trên loại gói (broadcast, unicast, multicast).

.. code::

    table erif {
      size: 800,
      counters_enabled: true,
      match: { meta.rif_port: exact,
               meta.is_l3_unicast: exact,
               meta.is_l3_broadcast: exact,
               meta.is_l3_multicast, exact },
      action: { meta.l3_drop: set,
                meta.l3_forward: set }
    }