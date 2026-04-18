.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/hisi-ptt.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================================
Thiết bị theo dõi và điều chỉnh HiSilicon PCIe
==============================================

Giới thiệu
============

Thiết bị theo dõi và điều chỉnh HiSilicon PCIe (PTT) là một tổ hợp gốc PCIe
thiết bị điểm cuối tích hợp (RCiEP), cung cấp khả năng
để tự động giám sát và điều chỉnh các sự kiện của liên kết PCIe (điều chỉnh),
và theo dõi các tiêu đề TLP (dấu vết). Hai chức năng này độc lập
nhưng nên sử dụng chúng cùng nhau để phân tích và nâng cao
Hiệu suất của liên kết PCIe.

Trên Kunpeng 930 SoC, Tổ hợp gốc PCIe bao gồm một số
lõi PCIe. Mỗi lõi PCIe bao gồm một số Cổng gốc và PTT
RCiEP, như bên dưới. Thiết bị PTT có khả năng điều chỉnh và
truy tìm các liên kết của lõi PCIe.
:::::::::::::::::::::::::::::::::::

+--------------Lõi 0-------+
          ZZ0000ZZ [ PTT] |
          ZZ0001ZZ [Cổng gốc]---[Điểm cuối]
          ZZ0002ZZ [Cổng gốc]---[Điểm cuối]
          ZZ0003ZZ [Cổng gốc]---[Điểm cuối]
    Tổ hợp gốc |------Lõi 1-------+
          ZZ0004ZZ [ PTT] |
          ZZ0005ZZ [Cổng gốc]---[ Chuyển đổi]---[Điểm cuối]
          ZZ0006ZZ [Cổng gốc]---[Điểm cuối] `-[Điểm cuối]
          ZZ0007ZZ [Cổng gốc]---[Điểm cuối]
          +---------------------------+

Trình điều khiển thiết bị PTT đăng ký một thiết bị PMU cho mỗi thiết bị PTT.
Tên của mỗi thiết bị PTT bao gồm tiền tố 'hisi_ptt' với
id của SICL và Core nơi nó đặt. Kunpeng 930
SoC đóng gói nhiều khuôn CPU (SCCL, Super CPU Cluster) và
IO chết (SICL, Cụm Super I/O), trong đó có một PCIe Root
Phức tạp cho mỗi SICL.
::::::::::::::::::::::

/sys/bus/event_source/devices/hisi_ptt<sicl_id>_<core_id>

Điều chỉnh
==========

Điều chỉnh PTT được thiết kế để theo dõi và điều chỉnh các tham số (sự kiện) liên kết PCIe.
Hiện tại chúng tôi hỗ trợ các sự kiện ở 2 lớp. Phạm vi của sự kiện
bao gồm lõi PCIe mà thiết bị PTT thuộc về.

Mỗi sự kiện được trình bày dưới dạng một tệp trong $(PTT PMU dir)/tune và
một chu trình mở/đọc/ghi/đóng đơn giản sẽ được sử dụng để điều chỉnh sự kiện.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

$ cd /sys/bus/event_source/devices/hisi_ptt<sicl_id>_<core_id>/tune
    $ ls
    qos_tx_cpl qos_tx_np qos_tx_p
    tx_path_rx_req_alloc_buf_level
    tx_path_tx_req_alloc_buf_level
    $ mèo qos_tx_dp
    1
    $ echo 2 > qos_tx_dp
    $ mèo qos_tx_dp
    2

Giá trị hiện tại (giá trị số) của sự kiện có thể được đọc một cách đơn giản
từ tệp và giá trị mong muốn được ghi vào tệp để điều chỉnh.

1. Kiểm soát QoS đường dẫn Tx
-----------------------------

Các tệp sau đây được cung cấp để điều chỉnh QoS của đường dẫn tx của
lõi PCIe.

- qos_tx_cpl: trọng số TLP hoàn thành Tx
- qos_tx_np: trọng số TLP chưa đăng của Tx
- qos_tx_p: trọng lượng TLP đã đăng Tx

Trọng lượng ảnh hưởng đến tỷ lệ của các gói nhất định trên liên kết PCIe.
Ví dụ: đối với kịch bản lưu trữ, hãy tăng tỷ lệ
của các gói hoàn thiện trên liên kết để nâng cao hiệu suất như
nhiều lần hoàn thành hơn được tiêu thụ.

Dữ liệu điều chỉnh có sẵn của các sự kiện này là [0, 1, 2].
Viết một giá trị âm sẽ trả về lỗi và nằm ngoài phạm vi
các giá trị sẽ được chuyển đổi thành 2. Lưu ý rằng giá trị sự kiện chỉ
chỉ ra mức độ có thể xảy ra nhưng không chính xác.

2. Kiểm soát bộ đệm đường dẫn Tx
--------------------------------

Các tệp sau được cung cấp để điều chỉnh bộ đệm của đường dẫn tx của lõi PCIe.

- rx_alloc_buf_level: hình mờ của Rx được yêu cầu
- tx_alloc_buf_level: hình mờ của Tx được yêu cầu

Những sự kiện này ảnh hưởng đến hình mờ của bộ đệm được phân bổ cho mỗi
loại. Rx có nghĩa là gửi vào trong khi Tx có nghĩa là gửi đi. Các gói sẽ
được lưu trữ trong bộ đệm trước và sau đó được truyền đi khi
đã đạt đến hình mờ hoặc khi hết thời gian chờ. Đối với một hướng bận rộn, bạn nên
tăng hình mờ bộ đệm liên quan để tránh đăng bài thường xuyên và
do đó nâng cao hiệu suất. Trong hầu hết các trường hợp chỉ giữ giá trị mặc định.

Dữ liệu giai điệu có sẵn của các sự kiện trên là [0, 1, 2].
Viết một giá trị âm sẽ trả về lỗi và nằm ngoài phạm vi
các giá trị sẽ được chuyển đổi thành 2. Lưu ý rằng giá trị sự kiện chỉ
chỉ ra mức độ có thể xảy ra nhưng không chính xác.

Dấu vết
=======

Dấu vết PTT được thiết kế để kết xuất các tiêu đề TLP vào bộ nhớ, giúp
có thể được sử dụng để phân tích các giao dịch và tình trạng sử dụng của PCIe
Liên kết. Bạn có thể chọn lọc các tiêu đề được theo dõi theo ID người yêu cầu,
hoặc những cổng xuôi dòng của một bộ Cổng gốc trên cùng lõi của PTT
thiết bị. Nó cũng được hỗ trợ để theo dõi các tiêu đề của loại nhất định và của
hướng nhất định.

Bạn có thể sử dụng lệnh perf ZZ0000ZZ để thiết lập các tham số, bắt đầu
theo dõi và lấy dữ liệu. Nó cũng được hỗ trợ để giải mã dấu vết
dữ liệu với ZZ0001ZZ. Các tham số điều khiển cho dấu vết được nhập vào
làm mã sự kiện cho từng sự kiện, mã này sẽ được minh họa rõ hơn sau.
Một cách sử dụng ví dụ giống như
::::::::::::::::::::::::::::::::

$ bản ghi hoàn hảo -e hisi_ptt0_2/filter=0x80001,type=1,direction=1,
      format=1/ -- ngủ 5

Điều này sẽ theo dõi cổng gốc xuôi dòng của tiêu đề TLP 0000:00:10.1 (sự kiện
mã cho 'bộ lọc' sự kiện là 0x80001) với loại yêu cầu TLP đã đăng,
hướng định dạng dữ liệu gửi đến và truy tìm của 8DW.

1. Lọc
---------

Các tiêu đề TLP để theo dõi có thể được lọc theo Cổng gốc hoặc ID người yêu cầu
của Điểm cuối, nằm trên cùng lõi của thiết bị PTT. bạn có thể
đặt bộ lọc bằng cách chỉ định tham số ZZ0000ZZ cần thiết để bắt đầu
dấu vết. Giá trị tham số là 20 bit. Bit 19 cho biết loại bộ lọc.
1 cho bộ lọc Cổng gốc và 0 cho bộ lọc Người yêu cầu. Bit[15:0] biểu thị
giá trị bộ lọc. Giá trị của Cổng gốc là mặt nạ của id cổng lõi.
được tính từ ID vị trí PCI của nó là (slotid & 7) * 2. Giá trị cho Người yêu cầu
là ID người yêu cầu (ID thiết bị của chức năng PCIe). Bit[18:16] hiện tại
dành riêng cho việc gia hạn.

Ví dụ: nếu bộ lọc mong muốn là Hàm điểm cuối 0000:01:00.1 thì bộ lọc
giá trị sẽ là 0x00101. Nếu bộ lọc mong muốn là Root Port 0000:00:10.0 thì
thì giá trị bộ lọc được tính là 0x80001.

Trình điều khiển cũng trình bày mọi bộ lọc Cổng gốc và Người yêu cầu được hỗ trợ thông qua
sysfs. Mỗi bộ lọc sẽ là một tệp riêng lẻ có tên PCIe liên quan
tên thiết bị (miền:bus:device.function). Các tập tin của bộ lọc Root Port là
trong $(PTT PMU dir)/root_port_filters và các tệp của bộ lọc Người yêu cầu
dưới $(PTT PMU dir)/requester_filters.

Lưu ý rằng nhiều Cổng gốc có thể được chỉ định cùng một lúc, nhưng chỉ có một
Chức năng điểm cuối có thể được chỉ định trong một dấu vết. Chỉ định cả cổng gốc
và chức năng cùng một lúc không được hỗ trợ. Người lái xe duy trì một danh sách
các bộ lọc có sẵn và sẽ kiểm tra các đầu vào không hợp lệ.

Các bộ lọc có sẵn sẽ được cập nhật động, có nghĩa là bạn sẽ luôn
nhận thông tin bộ lọc chính xác khi xảy ra sự kiện cắm nóng hoặc khi bạn thực hiện thủ công
loại bỏ/quét lại các thiết bị.

2. Loại
-------

Bạn có thể theo dõi các tiêu đề TLP của một số loại nhất định bằng cách chỉ định ZZ0000ZZ
tham số cần thiết để bắt đầu theo dõi. Giá trị tham số là
8 bit. Các loại được hỗ trợ hiện tại và các giá trị liên quan được hiển thị bên dưới:

- 8'b00000001: gửi yêu cầu (P)
- 8'b00000010: yêu cầu chưa được đăng (NP)
- 8'b00000100: số lần hoàn thành (CPL)

Bạn có thể chỉ định nhiều loại khi theo dõi các tiêu đề TLP gửi đến, nhưng chỉ có thể
chỉ định một khi truy tìm các tiêu đề TLP gửi đi.

3. Phương hướng
---------------

Bạn có thể theo dõi các tiêu đề TLP từ hướng nhất định, tương đối
tới Cổng gốc hoặc lõi PCIe, bằng cách chỉ định tham số ZZ0000ZZ.
Đây là tùy chọn và tham số mặc định là gửi đến. Giá trị tham số
là 4 bit. Khi định dạng mong muốn là 4DW, chỉ đường và các giá trị liên quan
được hỗ trợ được hiển thị dưới đây:

- 4'b0000: TLP gửi vào (P, NP, CPL)
- 4'b0001: TLP gửi đi (P, NP, CPL)
- 4'b0010: TLP gửi đi (P, NP, CPL) và TLP gửi đến (P, NP, CPL B)
- 4'b0011: TLP gửi đi (P, NP, CPL) và TLP gửi đến (CPL A)

Khi định dạng mong muốn là 8DW, hướng dẫn và các giá trị liên quan được hỗ trợ
hiển thị dưới đây:

- 4'b0000: dành riêng
- 4'b0001: TLP gửi đi (P, NP, CPL)
- 4'b0010: TLP gửi vào (P, NP, CPL B)
- 4'b0011: TLP gửi vào (CPL A)

Số lượt hoàn thành trong nước được phân thành hai loại:

- hoàn thành A (CPL A): hoàn thành các yêu cầu CHI/DMA/Native không được đăng, ngoại trừ CPL B
- hoàn thành B (CPL B): hoàn thành các yêu cầu chưa được đăng của DMA remote2local và P2P

4. Định dạng
--------------

Bạn có thể thay đổi định dạng của tiêu đề TLP được theo dõi bằng cách chỉ định
Thông số ZZ0000ZZ. Định dạng mặc định là 4DW. Giá trị tham số là 4 bit.
Các định dạng được hỗ trợ hiện tại và các giá trị liên quan được hiển thị bên dưới:

- 4'b0000: Độ dài 4DW trên mỗi tiêu đề TLP
- 4'b0001: Độ dài 8DW trên mỗi tiêu đề TLP

Định dạng tiêu đề TLP được theo dõi khác với tiêu chuẩn PCIe.

Khi sử dụng định dạng dữ liệu 8DW, toàn bộ tiêu đề TLP sẽ được ghi lại
(Tiêu đề DW0-3 hiển thị bên dưới). Ví dụ: tiêu đề TLP cho Bộ nhớ
Các lần đọc với địa chỉ 64-bit được hiển thị trong PCIe r5.0, Hình 2-17;
tiêu đề cho Yêu cầu cấu hình được hiển thị trong Hình 2.20, v.v.

Ngoài ra, các mục đệm theo dõi 8DW chứa dấu thời gian và
có thể là tiền tố cho tiền tố PASID TLP (xem Hình 6-20, PCIe r5.0).
Nếu không trường này sẽ là tất cả 0.

Bit[31:11] của DW0 luôn là 0x1fffff, có thể
dùng để phân biệt định dạng dữ liệu. Định dạng 8DW giống như
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

bit [ 31:11 ][ 10:0 ]
         ZZ0000ZZ-------------------|
     DW0 [ 0x1fffff] [Dành riêng (0x7ff)]
     DW1 [ Tiền tố ]
     DW2 [ Tiêu đề DW0 ]
     DW3 [ Tiêu đề DW1 ]
     DW4 [ Tiêu đề DW2 ]
     DW5 [ Tiêu đề DW3 ]
     DW6 [ Đã đặt trước (0x0)]
     DW7 [ Thời gian ]

Khi sử dụng định dạng dữ liệu 4DW, DW0 của mục nhập bộ đệm theo dõi
chứa các trường DW0 được chọn của TLP, cùng với một
dấu thời gian.  DW1-DW3 của mục đệm theo dõi chứa DW1-DW3
trực tiếp từ tiêu đề TLP.

Định dạng 4DW giống như
:::::::::::::::::::::::

bit [31:30] [ 29:25 ][24][23][22][21][ 20:11 ][ 10:0 ]
         ZZ0000ZZ--------ZZ0001ZZ---ZZ0002ZZ---ZZ0003ZZ-------------|
     DW0 [ Fmt ][ Loại ][T9][T8][TH][SO][ Độ dài ][ Thời gian ]
     DW1 [ Tiêu đề DW1 ]
     DW2 [ Tiêu đề DW2 ]
     DW3 [ Tiêu đề DW3 ]

5. Quản lý bộ nhớ
--------------------

Các tiêu đề TLP được theo dõi sẽ được ghi vào bộ nhớ được phân bổ
bởi người lái xe. Phần cứng chấp nhận 4 địa chỉ DMA có cùng kích thước,
và ghi bộ đệm tuần tự như dưới đây. Nếu DMA addr 3 là
kết thúc và dấu vết vẫn còn, nó sẽ trở về addr 0.
:::::::::::::::::::::::::::::::::::::::::::::::::

+->[DMA địa chỉ 0]->[DMA địa chỉ 1]->[DMA địa chỉ 2]->[DMA địa chỉ 3]-+
    +----------------------------------------------------------+

Trình điều khiển sẽ phân bổ mỗi bộ đệm DMA 4MiB. Bộ đệm đã hoàn thành
sẽ được sao chép vào bộ đệm hoàn hảo AUX được phân bổ bởi lõi hoàn hảo.
Khi bộ đệm AUX đầy trong khi dấu vết vẫn còn, trình điều khiển
sẽ cam kết bộ đệm AUX trước rồi áp dụng bộ đệm mới với
cùng kích thước. Kích thước của bộ đệm AUX được mặc định là 16MiB. Người dùng có thể
điều chỉnh kích thước bằng cách chỉ định tham số ZZ0000ZZ của lệnh perf.

6. Giải mã
-----------

Bạn có thể giải mã dữ liệu được theo dõi bằng lệnh ZZ0000ZZ (hiện tại
chỉ hỗ trợ kết xuất dữ liệu theo dõi thô). Dữ liệu truy tìm sẽ được giải mã
theo định dạng được mô tả trước đó (lấy 8DW làm ví dụ):
:::::::::::::::::::::::::::::::::::::::::::::::::::::::

[...tiêu đề hoàn hảo và thông tin khác]
    . ... Dữ liệu HISI PTT: kích thước 4194304 byte
    .  00000000: 00 00 00 00 Tiền tố
    .  00000004: 01 00 00 60 Tiêu đề DW0
    .  00000008: 0f 1e 00 01 Tiêu đề DW1
    .  0000000c: 04 00 00 00 Tiêu đề DW2
    .  00000010: 40 00 81 02 Tiêu đề DW3
    .  00000014: 33 c0 04 00 Thời gian
    .  00000020: 00 00 00 00 Tiền tố
    .  00000024: 01 00 00 60 Tiêu đề DW0
    .  00000028: 0f 1e 00 01 Tiêu đề DW1
    .  0000002c: 04 00 00 00 Tiêu đề DW2
    .  00000030: 40 00 81 02 Tiêu đề DW3
    .  00000034: 02 00 00 00 Thời gian
    .  00000040: 00 00 00 00 Tiền tố
    .  00000044: 01 00 00 60 Tiêu đề DW0
    .  00000048: 0f 1e 00 01 Tiêu đề DW1
    .  0000004c: 04 00 00 00 Tiêu đề DW2
    .  00000050: 40 00 81 02 Tiêu đề DW3
    […]