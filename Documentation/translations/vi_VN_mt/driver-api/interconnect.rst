.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/interconnect.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
Hệ thống chung Kết nối hệ thống con
=====================================

Giới thiệu
------------

Khung này được thiết kế để cung cấp giao diện kernel tiêu chuẩn để kiểm soát
cài đặt của các kết nối trên SoC. Những cài đặt này có thể là thông lượng,
độ trễ và mức độ ưu tiên giữa nhiều thiết bị được kết nối hoặc chức năng
khối. Điều này có thể được điều khiển linh hoạt để tiết kiệm năng lượng hoặc cung cấp
hiệu suất tối đa.

Bus kết nối là phần cứng với các thông số có thể cấu hình được, có thể
đặt trên đường dẫn dữ liệu theo yêu cầu nhận được từ các trình điều khiển khác nhau.
Một ví dụ về các bus kết nối là các kết nối giữa nhiều
các thành phần hoặc khối chức năng trong chipset. Có thể có nhiều kết nối
trên một SoC có thể có nhiều tầng.

Dưới đây là sơ đồ đơn giản hóa cấu trúc liên kết bus kết nối SoC trong thế giới thực.

::

+++ +----------------+
 ZZ0000ZZ--->ZZ0001ZZ<--------------+
 +++ ----------------+ |
                         ZZ0002ZZ +-------------+
  +------+ +-------------+ V +------+ ZZ0003ZZ
  ZZ0004ZZ ZZ0005ZZ PCIe ZZ0006ZZ |
  +------+ ZZ0007ZZ Nô lệ ZZ0008ZZ |
    ^ ^ ZZ0009ZZ ZZ0010ZZ
    ZZ0011ZZ V V ZZ0012ZZ
 +-------------------+ +--------------------------+ ZZ0013ZZ +------+
 ZZ0014ZZ->ZZ0015ZZ->ZZ0016ZZ->ZZ0017ZZ
 ZZ0018ZZ -->ZZ0019ZZ<--ZZ0020ZZ +------+
 ZZ0021ZZ ZZ0022ZZ +-------------+
 ZZ0023ZZ<--ZZ0024ZZ----------+ |
 ZZ0025ZZ<--ZZ0026ZZ<------+ ZZ0027ZZ +--------+
 +-------------------+ +--------------------------+ ZZ0028ZZ +-->ZZ0029ZZ
   ^ ^ ^ ^ ^ ZZ0030ZZ +--------+
   ZZ0031ZZ ZZ0032ZZ ZZ0033ZZ V
 +------+ |  +------+ +------+ +----------+ +----------------+ +--------+
 ZZ0034ZZ ZZ0035ZZ GPU ZZ0036ZZ DSP ZZ0037ZZ Bậc thầy ZZ0038ZZ P NoC ZZ0039ZZ Nô lệ |
 +------+ |  +------+ +------+ +----------+ +----------------+ +--------+
           |
       +-------+
       ZZ0040ZZ
       +-------+

Thuật ngữ
-----------

Nhà cung cấp kết nối là định nghĩa phần mềm của phần cứng kết nối.
Các nhà cung cấp kết nối trong sơ đồ trên là M NoC, S NoC, C NoC, P NoC
và Mem NoC.

Nút kết nối là định nghĩa phần mềm của phần cứng kết nối
cổng. Mỗi nhà cung cấp kết nối bao gồm nhiều nút kết nối,
được kết nối với các thành phần SoC khác bao gồm các kết nối khác
các nhà cung cấp. Điểm trên sơ đồ nơi CPU kết nối với bộ nhớ là
được gọi là nút kết nối, thuộc về nhà cung cấp kết nối Mem NoC.

Điểm cuối kết nối là phần tử đầu tiên hoặc cuối cùng của đường dẫn. Mỗi
điểm cuối là một nút, nhưng không phải nút nào cũng là điểm cuối.

Đường dẫn kết nối là mọi thứ giữa hai điểm cuối bao gồm tất cả các nút
phải được duyệt qua để đi từ nút nguồn đến nút đích. Nó có thể
bao gồm nhiều cặp chủ-nô lệ trên một số nhà cung cấp kết nối.

Người tiêu dùng kết nối là những thực thể sử dụng các đường dẫn dữ liệu được hiển thị
bởi các nhà cung cấp. Người tiêu dùng gửi yêu cầu đến nhà cung cấp với nhiều yêu cầu khác nhau
thông lượng, độ trễ và mức độ ưu tiên. Thông thường người tiêu dùng là người điều khiển thiết bị,
gửi yêu cầu dựa trên nhu cầu của họ. Một ví dụ cho người tiêu dùng là bộ giải mã video
hỗ trợ nhiều định dạng và kích thước hình ảnh khác nhau.

Nhà cung cấp kết nối
----------------------

Nhà cung cấp kết nối là một thực thể thực hiện các phương thức để khởi tạo và
cấu hình phần cứng bus kết nối. Trình điều khiển của nhà cung cấp kết nối nên
được đăng ký với lõi nhà cung cấp kết nối.

.. kernel-doc:: include/linux/interconnect-provider.h

.. kernel-doc:: drivers/interconnect/core.c
   :functions: icc_provider_init icc_provider_register icc_provider_deregister
               icc_node_create icc_node_create_dyn icc_node_destroy
               icc_node_add icc_node_del icc_nodes_remove icc_node_set_name
               icc_link_create icc_link_nodes

Kết nối người tiêu dùng
----------------------

Người tiêu dùng kết nối là những khách hàng sử dụng API kết nối để
nhận đường dẫn giữa các điểm cuối và đặt các yêu cầu về băng thông/độ trễ/QoS của chúng
cho các đường dẫn kết nối này.

.. kernel-doc:: drivers/interconnect/core.c
   :functions: devm_of_icc_get of_icc_get_by_index of_icc_get icc_get
               icc_put icc_enable icc_disable icc_set_bw icc_set_tag
               icc_get_name

.. kernel-doc:: drivers/interconnect/bulk.c

Kết nối các giao diện debugfs
-------------------------------

Giống như một số hệ thống con khác, kết nối sẽ tạo ra một số tệp để gỡ lỗi
và sự xem xét nội tâm. Các tệp trong debugfs không được coi là ABI nên ứng dụng
phần mềm không nên dựa vào sự thay đổi chi tiết định dạng giữa các phiên bản kernel.

ZZ0000ZZ:

Hiển thị tất cả các nút kết nối trong hệ thống với băng thông tổng hợp của chúng
yêu cầu. Thụt lề dưới mỗi nút hiển thị các yêu cầu băng thông từ mỗi thiết bị.

ZZ0000ZZ:

Hiển thị biểu đồ kết nối ở định dạng chấm graphviz. Nó hiển thị tất cả
kết nối các nút và liên kết trong hệ thống và nhóm các nút lại với nhau từ
cùng một nhà cung cấp như đồ thị con. Định dạng này con người có thể đọc được và cũng có thể được chuyển đổi
thông qua dấu chấm để tạo sơ đồ ở nhiều định dạng đồ họa::

$ cat /sys/kernel/debug/interconnect/interconnect_graph | \
                dấu chấm -Tsvg > kết nối_graph.svg

Thư mục ZZ0000ZZ cung cấp các giao diện để đưa ra các yêu cầu BW tới
bất kỳ con đường tùy ý. Lưu ý rằng vì lý do an toàn, tính năng này bị tắt bởi
mặc định không có Kconfig để kích hoạt nó. Việc kích hoạt nó yêu cầu thay đổi mã thành
ZZ0001ZZ. Ví dụ sử dụng::

cd /sys/kernel/debug/interconnect/test-client/

Điểm cuối nút # Configure cho đường dẫn từ CPU đến DDR trên
        # qcom/sm8550.
        echo chm_apps > src_node
        echo ebi > dst_node

Đường dẫn # Get giữa src_node và dst_node. Đây chỉ là
        # necessary sau khi cập nhật điểm cuối của nút.
        tiếng vang 1 > nhận được

# Set mong muốn BW ở mức trung bình 1Gbps và mức cao nhất là 2Gbps.
        echo 1000000 > avg_bw
        echo 2000000 > đỉnh_bw

# Vote cho avg_bw và Peak_bw trên đường dẫn mới nhất từ ​​"get".
        Có thể thực hiện # Voting cho nhiều đường dẫn bằng cách lặp lại điều này
        # process cho các điểm cuối nút khác nhau.
        echo 1 > cam kết