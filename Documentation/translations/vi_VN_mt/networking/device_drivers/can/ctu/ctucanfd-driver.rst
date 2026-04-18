.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/can/ctu/ctucanfd-driver.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển CTU CAN FD
=================

Tác giả: Martin Jerabek <martin.jerabek01@gmail.com>


Giới thiệu về lõi IP CTU CAN FD
------------------------

ZZ0000ZZ
là một lõi mềm mã nguồn mở được viết bằng VHDL.
Nó bắt nguồn từ năm 2015 dưới dạng dự án của Ondrej Ille
tại ZZ0001ZZ
của ZZ0002ZZ tại ZZ0003ZZ.

Trình điều khiển SocketCAN dành cho bo mạch MicroZed dựa trên Xilinx Zynq SoC
ZZ0000ZZ
và bo mạch Terasic DE0-Nano-SoC dựa trên Intel Cyclone V 5CSEMA4U23C6
ZZ0001ZZ
đã được phát triển cũng như hỗ trợ cho
ZZ0002ZZ của lõi.

Trong trường hợp của Zynq, lõi được kết nối thông qua bus hệ thống APB.
không có hỗ trợ liệt kê và thiết bị phải được chỉ định trong Cây thiết bị.
Loại thiết bị này được gọi là thiết bị nền tảng trong kernel và được
được xử lý bởi trình điều khiển thiết bị nền tảng.

Mô hình chức năng cơ bản của thiết bị ngoại vi CTU CAN FD đã được
được chấp nhận vào dòng chính QEMU. Xem QEMU ZZ0000ZZ
dành cho xe buýt CAN FD, kết nối máy chủ và mô phỏng lõi CTU CAN FD. Sự phát triển
phiên bản hỗ trợ mô phỏng có thể được sao chép từ nhánh ctu-canfd của QEMU cục bộ
phát triển ZZ0001ZZ.


Giới thiệu về SocketCAN
---------------

SocketCAN là giao diện chung tiêu chuẩn cho các thiết bị CAN trong Linux
hạt nhân. Như tên cho thấy, xe buýt được truy cập thông qua ổ cắm, tương tự
đến các thiết bị mạng thông thường. Lý do đằng sau điều này là sâu sắc
được mô tả trong ZZ0000ZZ.
Tóm lại, nó cung cấp một
cách tự nhiên để triển khai và làm việc với các giao thức lớp cao hơn trên CAN,
theo cách tương tự như UDP/IP qua Ethernet.

Đầu dò thiết bị
~~~~~~~~~~~~

Trước khi đi vào chi tiết về cấu trúc của driver thiết bị bus CAN,
hãy nhắc lại cách kernel nhận biết về thiết bị.
Một số bus, như PCI hoặc PCIe, hỗ trợ liệt kê thiết bị. Tức là khi
hệ thống khởi động, nó phát hiện tất cả các thiết bị trên xe buýt và đọc
cấu hình của họ. Hạt nhân xác định thiết bị thông qua ID nhà cung cấp của nó
và ID thiết bị và liệu có trình điều khiển được đăng ký cho mã định danh này hay không
kết hợp, phương thức thăm dò của nó được gọi để điền thông tin của trình điều khiển
ví dụ cho phần cứng nhất định. Tình huống tương tự cũng xảy ra với USB, chỉ
nó cho phép cắm nóng thiết bị.

Tình huống sẽ khác đối với các thiết bị ngoại vi được nhúng trực tiếp
trong SoC và được kết nối với bus hệ thống nội bộ (AXI, APB, Avalon,
và những người khác). Những bus này không hỗ trợ liệt kê, và do đó kernel
phải tìm hiểu về các thiết bị từ nơi khác. Đây chính xác là những gì
Cây thiết bị được tạo ra cho.

Cây thiết bị
~~~~~~~~~~~

Một mục trong cây thiết bị cho biết rằng một thiết bị tồn tại trong hệ thống, làm thế nào
nó có thể truy cập được (trên bus nào nó cư trú) và cấu hình của nó –
đăng ký địa chỉ, ngắt và như vậy. Một ví dụ về một thiết bị như vậy
cây được đưa vào .

::

/ {
               /* ... */
               amba: amba {
                   #address-cells = <1>;
                   #size-cells = <1>;
                   tương thích = "bus đơn giản";

CTU_CAN_FD_0: CTU_CAN_FD@43c30000 {
                       tương thích = "ctu,ctucanfd";
                       ngắt-parent = <&intc>;
                       ngắt = <0 30 4>;
                       đồng hồ = <&clkc 15>;
                       reg = <0x43c30000 0x10000>;
                   };
               };
           };


.. _sec:socketcan:drv:

Cấu trúc trình điều khiển
~~~~~~~~~~~~~~~~

Trình điều khiển có thể được chia thành hai phần – thiết bị phụ thuộc vào nền tảng
khám phá và thiết lập cũng như thiết bị mạng CAN độc lập với nền tảng
thực hiện.

.. _sec:socketcan:platdev:

Trình điều khiển thiết bị nền tảng
^^^^^^^^^^^^^^^^^^^^^^

Trong trường hợp của Zynq, lõi được kết nối thông qua bus hệ thống AXI,
không có hỗ trợ liệt kê và thiết bị phải được chỉ định trong
Cây thiết bị. Loại thiết bị này được gọi là ZZ0000ZZ trong
kernel và được xử lý bởi ZZ0001ZZ\ [1]_.

Trình điều khiển thiết bị nền tảng cung cấp những thứ sau:

- Chức năng ZZ0000ZZ

- Chức năng ZZ0000ZZ

- Bảng các thiết bị ZZ0000ZZ mà người lái xe có thể xử lý

Hàm ZZ0000ZZ được gọi chính xác một lần khi thiết bị xuất hiện (hoặc
trình điều khiển đã được tải, tùy điều kiện nào xảy ra sau). Nếu có nhiều hơn
các thiết bị được xử lý bởi cùng một trình điều khiển, chức năng ZZ0001ZZ được gọi cho
mỗi người trong số họ. Vai trò của nó là phân bổ và khởi tạo tài nguyên
cần thiết để xử lý thiết bị cũng như thiết lập các chức năng cấp thấp
đối với lớp độc lập với nền tảng, ví dụ: ZZ0002ZZ và ZZ0003ZZ.
Sau đó, trình điều khiển sẽ đăng ký thiết bị lên lớp cao hơn, trong
trường hợp như một ZZ0004ZZ.

Chức năng ZZ0000ZZ được gọi khi thiết bị biến mất hoặc
tài xế sắp được dỡ hàng. Nó phục vụ để giải phóng các tài nguyên
được phân bổ trong ZZ0001ZZ và hủy đăng ký thiết bị khỏi các lớp cao hơn.

Cuối cùng, bảng thiết bị ZZ0001ZZ cho biết thiết bị nào
tài xế có thể xử lý được. Mục nhập Cây thiết bị ZZ0000ZZ được khớp
so với các bàn của tất cả ZZ0002ZZ.

.. code:: c

           /* Match table for OF platform binding */
           static const struct of_device_id ctucan_of_match[] = {
               { .compatible = "ctu,canfd-2", },
               { .compatible = "ctu,ctucanfd", },
               { /* end of list */ },
           };
           MODULE_DEVICE_TABLE(of, ctucan_of_match);

           static int ctucan_probe(struct platform_device *pdev);
           static int ctucan_remove(struct platform_device *pdev);

           static struct platform_driver ctucanfd_driver = {
               .probe  = ctucan_probe,
               .remove = ctucan_remove,
               .driver = {
                   .name = DRIVER_NAME,
                   .of_match_table = ctucan_of_match,
               },
           };
           module_platform_driver(ctucanfd_driver);


.. _sec:socketcan:netdev:

Trình điều khiển thiết bị mạng
^^^^^^^^^^^^^^^^^^^^^

Mỗi thiết bị mạng phải hỗ trợ ít nhất các hoạt động sau:

- Đưa máy lên: ZZ0000ZZ

- Mang máy xuống: ZZ0000ZZ

- Gửi khung TX tới thiết bị: ZZ0000ZZ

- Hoàn thành tín hiệu TX và lỗi tới hệ thống con mạng: ISR

- Gửi khung RX đến hệ thống con mạng: ISR và NAPI

Có hai nguồn sự kiện có thể xảy ra: thiết bị và mạng
hệ thống con. Các sự kiện của thiết bị thường được báo hiệu thông qua một ngắt, được xử lý
trong Quy trình dịch vụ ngắt (ISR). Trình xử lý sự kiện
bắt nguồn từ hệ thống con mạng sau đó được chỉ định trong
ZZ0000ZZ.

Khi thiết bị được kích hoạt, ví dụ: bằng cách gọi ZZ0000ZZ,
chức năng của trình điều khiển ZZ0001ZZ được gọi. Nó nên xác nhận
cấu hình giao diện và cấu hình và kích hoạt thiết bị. các
đối diện tương tự là ZZ0002ZZ, được gọi khi thiết bị đang được
bị hạ thấp, dù là rõ ràng hay ngầm định.

Khi hệ thống cần truyền một khung, nó sẽ thực hiện bằng cách gọi
ZZ0000ZZ, đưa khung vào thiết bị. Nếu
hàng đợi CTNH của thiết bị (FIFO, hộp thư hoặc bất kỳ cách triển khai nào)
trở nên đầy đủ, việc triển khai ZZ0001ZZ sẽ thông báo cho mạng
hệ thống con sẽ dừng hàng đợi TX (thông qua ZZ0002ZZ).
Sau đó, nó được kích hoạt lại sau trong ISR khi thiết bị có dung lượng trống
có sẵn một lần nữa và có thể liệt kê một khung khác.

Tất cả các sự kiện của thiết bị được xử lý trong ISR, cụ thể là:

#. ZZ0000ZZ. Khi thiết bị kết thúc truyền thành công
   một khung, khung đó được lặp lại cục bộ. Có lỗi, lỗi thông tin
   thay vào đó, frame [2]_ được gửi đến hệ thống con mạng. Trong cả hai trường hợp,
   hàng đợi TX phần mềm được tiếp tục để có thể gửi nhiều khung hình hơn.

#. ZZ0000ZZ. Nếu có sự cố xảy ra (ví dụ: thiết bị ngừng hoạt động
   xảy ra tình trạng ngắt bus hoặc tràn RX), bộ đếm lỗi được cập nhật và
   các khung lỗi thông tin được xếp vào hàng đợi SW RX.

#. ZZ0000ZZ. Trong trường hợp này, hãy đọc khung RX và ghi lại
   chúng vào hàng đợi SW RX. Thông thường NAPI được sử dụng làm lớp giữa (xem Tài nguyên).

.. _sec:socketcan:napi:

NAPI
~~~~

Tần số của các khung hình đến có thể cao và chi phí để gọi
quy trình phục vụ ngắt cho mỗi khung có thể gây ra sự cố đáng kể
tải hệ thống. Có nhiều cơ chế trong nhân Linux để xử lý
với tình huống này. Chúng đã phát triển qua nhiều năm của nhân Linux
phát triển và cải tiến. Đối với các thiết bị mạng, chuẩn hiện hành
là NAPI – ZZ0000ZZ. Nó tương tự như nửa trên/nửa dưới cổ điển
xử lý ngắt ở chỗ nó chỉ xác nhận ngắt trong ISR
và báo hiệu rằng phần còn lại của quá trình xử lý sẽ được thực hiện trong softirq
bối cảnh. Trên hết, nó mang lại khả năng cho ZZ0001ZZ mới
khung hình trong một thời gian. Điều này có khả năng tránh được vòng quay tốn kém
cho phép ngắt, xử lý IRQ đến trong ISR, kích hoạt lại
softirq và chuyển ngữ cảnh trở lại softirq.

Xem ZZ0000ZZ để biết thêm thông tin.

Tích hợp lõi vào Xilinx Zynq
-----------------------------------

Giao diện cốt lõi là một tập hợp con đơn giản của Avalon
(tìm kiếm Intel ZZ0000ZZ)
xe buýt như ban đầu nó được sử dụng trên
Chip Alterra FPGA, nhưng Xilinx có giao diện nguyên bản với AXI
(tìm kiếm ARM **AMBA AXI và ACE Đặc tả giao thức AXI3,
AXI4 và AXI4-Lite, ACE và ACE-Lite**).
Giải pháp rõ ràng nhất là sử dụng
cầu nối Avalon/AXI hoặc triển khai một số thực thể chuyển đổi đơn giản.
Tuy nhiên, giao diện của lõi là bán song công và không bắt tay
truyền tín hiệu, trong khi AXI là song công hoàn toàn với tín hiệu hai chiều. Hơn nữa,
ngay cả giao diện nô lệ AXI-Lite cũng khá tốn tài nguyên và
tính linh hoạt và tốc độ của AXI không cần thiết đối với lõi CAN.

Do đó, một bus đơn giản hơn nhiều đã được chọn – APB (Bus ngoại vi nâng cao)
(tìm kiếm ARM ZZ0000ZZ).
Cầu APB-AXI có sẵn trực tiếp tại
Xilinx Vivado và thực thể bộ điều hợp giao diện chỉ là một vài thao tác đơn giản
các bài tập tổ hợp.

Cuối cùng, để có thể đưa lõi vào sơ đồ khối dưới dạng tùy chỉnh
IP, lõi, cùng với giao diện APB, đã được đóng gói dưới dạng
Thành phần Vivado.

Thiết kế trình điều khiển CTU CAN FD
------------------------

Cấu trúc chung của trình điều khiển thiết bị CAN đã được kiểm tra
trong . Các đoạn tiếp theo cung cấp mô tả chi tiết hơn về CTU
Trình điều khiển lõi CAN FD nói riêng.

Trình điều khiển cấp thấp
~~~~~~~~~~~~~~~~

Lõi không nhằm mục đích chỉ được sử dụng với SocketCAN, và do đó nó
mong muốn có trình điều khiển cấp thấp độc lập với hệ điều hành. Mức độ thấp này
trình điều khiển sau đó có thể được sử dụng trong việc triển khai trình điều khiển hệ điều hành hoặc trực tiếp
trên kim loại trần hoặc trong ứng dụng không gian người dùng. Một lợi thế khác
là nếu phần cứng thay đổi một chút thì chỉ có trình điều khiển cấp thấp
cần phải được sửa đổi.

Mã [3]_ một phần được tạo tự động và một phần được viết
do tác giả nòng cốt thực hiện thủ công, có đóng góp của tác giả luận án.
Trình điều khiển cấp thấp hỗ trợ các hoạt động như: đặt thời gian bit, đặt
chế độ điều khiển, bật/tắt, đọc khung RX, ghi khung TX, v.v.
trên.

Định cấu hình thời gian bit
~~~~~~~~~~~~~~~~~~~~~~

Trên CAN, mỗi bit được chia thành bốn đoạn: SYNC, PROP, PHASE1 và
PHASE2. Thời lượng của chúng được biểu thị bằng bội số của Lượng tử thời gian
(chi tiết trong ZZ0000ZZ, chương 8).
Khi cấu hình
tốc độ bit, thời lượng của tất cả các phân đoạn (và lượng tử thời gian) phải là
được tính toán từ tốc độ bit và Điểm mẫu. Việc này được thực hiện
độc lập cho cả tốc độ bit danh nghĩa và tốc độ bit dữ liệu cho CAN FD.

SocketCAN khá linh hoạt và cung cấp khả năng tùy biến cao
cấu hình bằng cách đặt tất cả thời lượng phân đoạn theo cách thủ công hoặc
cấu hình thuận tiện bằng cách chỉ cài đặt tốc độ bit và điểm mẫu
(và thậm chí nó còn được chọn tự động theo khuyến nghị của Bosch nếu không
được chỉ định). Tuy nhiên, mỗi bộ điều khiển CAN có thể có xung nhịp cơ bản khác nhau
tần số và độ rộng khác nhau của các thanh ghi thời lượng phân đoạn. các
do đó thuật toán cần các giá trị tối thiểu và tối đa cho các khoảng thời gian
(và bộ đếm trước đồng hồ) và cố gắng tối ưu hóa các con số để phù hợp với cả
các ràng buộc và các tham số được yêu cầu.

.. code:: c

           struct can_bittiming_const {
               char name[16];      /* Name of the CAN controller hardware */
               __u32 tseg1_min;    /* Time segment 1 = prop_seg + phase_seg1 */
               __u32 tseg1_max;
               __u32 tseg2_min;    /* Time segment 2 = phase_seg2 */
               __u32 tseg2_max;
               __u32 sjw_max;      /* Synchronisation jump width */
               __u32 brp_min;      /* Bit-rate prescaler */
               __u32 brp_max;
               __u32 brp_inc;
           };


[lst:can_bittiming_const]

Một độc giả tò mò sẽ nhận thấy rằng thời lượng của các phân đoạn PROP_SEG
và PHASE_SEG1 không được xác định riêng biệt mà được kết hợp và
thì theo mặc định, TSEG1 thu được sẽ được chia đều cho PROP_SEG
và PHASE_SEG1. Trong thực tế, điều này hầu như không gây ra hậu quả gì vì
điểm mẫu nằm giữa PHASE_SEG1 và PHASE_SEG2. Trong CTU CAN FD,
tuy nhiên, các thanh ghi thời lượng ZZ0000ZZ và ZZ0001ZZ có khác nhau
chiều rộng (tương ứng là 6 và 7 bit), do đó các giá trị được tính toán tự động có thể
tràn thanh ghi ngắn hơn và do đó phải được phân phối lại giữa các
hai [4]_.

Xử lý RX
~~~~~~~~~~~

Việc nhận khung được xử lý trong hàng đợi NAPI, được bật từ ISR khi
bit RXNE (RX FIFO Không trống) được đặt. Các khung được đọc từng cái một
cho đến khi không còn khung nào trong RX FIFO hoặc hạn ngạch công việc tối đa
đã đạt được mục tiêu cho cuộc thăm dò NAPI (xem Tài nguyên). Mỗi khung hình sau đó được chuyển
đến hàng đợi RX giao diện mạng.

Khung đến có thể là khung CAN 2.0 hoặc khung CAN FD. các
cách để phân biệt giữa hai cái này trong kernel là phân bổ một trong hai
ZZ0000ZZ hoặc ZZ0001ZZ, cả hai đều có sự khác biệt
kích thước. Trong bộ điều khiển, thông tin về loại khung được lưu trữ
trong từ đầu tiên của RX FIFO.

Điều này mang đến cho chúng tôi một vấn đề về quả trứng gà: chúng tôi muốn phân bổ ZZ0000ZZ
đối với khung và chỉ khi thành công, hãy tìm nạp khung từ FIFO;
nếu không hãy giữ nó ở đó cho sau này. Nhưng để có thể phân bổ
đúng ZZ0001ZZ, chúng ta phải tìm tác phẩm đầu tiên của FIFO. có
một số giải pháp khả thi:

#. Đọc từ, sau đó phân bổ. Nếu không thành công, hãy loại bỏ phần còn lại
   khung. Khi hệ thống sắp hết bộ nhớ, tình hình vẫn rất tệ.

#. Luôn phân bổ trước ZZ0000ZZ đủ lớn cho khung FD. Sau đó
   điều chỉnh các bộ phận bên trong ZZ0001ZZ để trông giống như nó đã được phân bổ cho
   khung CAN 2.0 nhỏ hơn.

#. Thêm tùy chọn để xem qua FIFO thay vì đọc từ ngữ.

#. Nếu việc phân bổ không thành công, hãy lưu từ đã đọc vào dữ liệu của trình điều khiển. Bật
   lần thử tiếp theo, hãy sử dụng từ đã lưu thay vì đọc lại.

Tùy chọn 1 đủ đơn giản, nhưng không thỏa mãn lắm nếu chúng ta có thể làm được
tốt hơn. Tùy chọn 2 không được chấp nhận vì nó đòi hỏi phải sửa đổi
trạng thái riêng của cấu trúc hạt nhân tích hợp. Cao hơn một chút
mức tiêu thụ bộ nhớ chỉ là một quả anh đào ảo trên “chiếc bánh”. Tùy chọn
3 yêu cầu những thay đổi CTNH không tầm thường và không lý tưởng xét theo quan điểm CTNH
xem.

Tùy chọn 4 có vẻ như là một sự thỏa hiệp tốt, nhưng nhược điểm của nó là
một phần khung có thể tồn tại trong FIFO trong thời gian dài. Tuy nhiên,
có thể chỉ có một chủ sở hữu của RX FIFO và do đó không ai khác nên
xem khung một phần (bỏ qua một số tình huống gỡ lỗi kỳ lạ).
Về cơ bản, trình điều khiển sẽ đặt lại lõi khi khởi tạo, do đó
khung một phần cũng không thể được “chấp nhận”. Cuối cùng, phương án 4 là
đã chọn [5]_.

.. _subsec:ctucanfd:rxtimestamp:

Khung thời gian RX
^^^^^^^^^^^^^^^^^^^^^^

Lõi CTU CAN FD báo cáo dấu thời gian chính xác khi khung hình được
đã nhận được. Dấu thời gian theo mặc định được ghi lại tại điểm mẫu của
bit cuối cùng của EOF nhưng có thể cấu hình để ghi lại ở bit SOF.
Nguồn dấu thời gian nằm bên ngoài lõi và có thể lên tới 64 bit
rộng. Tại thời điểm viết bài, chuyển dấu thời gian từ kernel sang
không gian người dùng chưa được triển khai nhưng được lên kế hoạch trong tương lai.

Xử lý TX
~~~~~~~~~~~

Lõi CTU CAN FD có 4 bộ đệm TX độc lập, mỗi bộ đệm có bộ đệm riêng
trạng thái và mức độ ưu tiên. Khi lõi muốn truyền, bộ đệm TX trong
Trạng thái sẵn sàng có mức ưu tiên cao nhất được chọn.

Ưu tiên là số 3 bit trong thanh ghi TX_PRIORITY
(căn chỉnh nibble). Điều này phải đủ linh hoạt cho hầu hết các trường hợp sử dụng.
Tuy nhiên, SocketCAN chỉ hỗ trợ một hàng đợi FIFO cho dữ liệu đi
khung [6]_. Các mức độ ưu tiên của bộ đệm có thể được sử dụng để mô phỏng FIFO
hành vi bằng cách gán cho mỗi bộ đệm một mức độ ưu tiên riêng biệt và ZZ0000ZZ
ưu tiên sau khi quá trình truyền khung hoàn tất.

Ngoài việc ưu tiên luân chuyển, SW còn phải duy trì đầu đuôi
con trỏ vào FIFO được tạo bởi bộ đệm TX để có thể xác định
bộ đệm nào sẽ được sử dụng cho khung tiếp theo (ZZ0001ZZ) và bộ đệm nào
phải là cái hoàn thành đầu tiên (ZZ0002ZZ). Bộ đệm thực tế
các chỉ số (rõ ràng) là modulo 4 (số lượng bộ đệm TX), nhưng
con trỏ phải rộng hơn ít nhất một chút để có thể phân biệt
giữa FIFO đầy và FIFO trống – trong tình huống này,
ZZ0000ZZ. Một ví dụ về cách
FIFO được duy trì, cùng với chế độ xoay ưu tiên, được mô tả trong

|

+------+---+---+---+---+
ZZ0000ZZ 0 ZZ0001ZZ 2 ZZ0002ZZ
+======+===+===+===+===+
ZZ0003ZZ A ZZ0004ZZ C ZZ0005ZZ
+------+---+---+---+---+
ZZ0006ZZ 7 ZZ0007ZZ 5 ZZ0008ZZ
+------+---+---+---+---+
ZZ0009ZZ ZZ0010ZZ ZZ0011ZZ
+------+---+---+---+---+

|

+------+---+---+---+---+
ZZ0000ZZ 0 ZZ0001ZZ 2 ZZ0002ZZ
+======+===+===+===+===+
ZZ0003ZZ ZZ0004ZZ C ZZ0005ZZ
+------+---+---+---+---+
ZZ0006ZZ 4 ZZ0007ZZ 6 ZZ0008ZZ
+------+---+---+---+---+
ZZ0009ZZ ZZ0010ZZ ZZ0011ZZ
+------+---+---+---+---+

|

+------+---+---+---+---+----+
ZZ0000ZZ 0 ZZ0001ZZ 2 ZZ0002ZZ 0’ |
+======+===+===+===+===+====+
ZZ0003ZZ E ZZ0004ZZ C ZZ0005ZZ |
+------+---+---+---+---+----+
ZZ0006ZZ 4 ZZ0007ZZ 6 ZZ0008ZZ |
+------+---+---+---+---+----+
ZZ0009ZZ ZZ0010ZZ ZZ0011ZZ H |
+------+---+---+---+---+----+

|

.. kernel-figure:: fsm_txt_buffer_user.svg

   TX Buffer states with possible transitions

.. _subsec:ctucanfd:txtimestamp:

Khung TX theo dấu thời gian
^^^^^^^^^^^^^^^^^^^^^^

Khi gửi khung tới bộ đệm TX, người ta có thể chỉ định dấu thời gian tại
khung nào sẽ được truyền đi. Việc truyền khung có thể bắt đầu
muộn hơn, nhưng không sớm hơn. Lưu ý rằng dấu thời gian không tham gia vào
ưu tiên bộ đệm - điều đó chỉ được quyết định bởi cơ chế
được mô tả ở trên.

Hỗ trợ truyền gói dựa trên thời gian gần đây đã được sáp nhập vào Linux
v4.19 ZZ0000ZZ,
nhưng nó vẫn chưa được nghiên cứu
liệu chức năng này có thiết thực cho CAN hay không.

Cũng tương tự như việc truy xuất dấu thời gian của khung RX, lõi
hỗ trợ truy xuất dấu thời gian của khung TX - đó là thời điểm
khung đã được chuyển giao thành công. Các chi tiết rất giống nhau
để đánh dấu thời gian cho các khung RX và được mô tả trong .

Xử lý lỗi tràn bộ đệm RX
~~~~~~~~~~~~~~~~~~~~~~~~~~

Khi khung nhận được không còn vừa với phần cứng RX FIFO trong đó
toàn bộ, cờ tràn RX FIFO (STATUS[DOR]) được đặt và tràn dữ liệu
Ngắt (DOI) được kích hoạt. Khi bảo trì ngắt, phải cẩn thận
được thực hiện trước tiên để xóa cờ DOR (thông qua COMMAND[CDO]) và sau đó
xóa cờ ngắt DOI. Nếu không, ngắt sẽ là
ngay lập tức [7]_ vũ trang lại.

ZZ0000ZZ: Trong quá trình phát triển, người ta đã thảo luận liệu CTNH nội bộ có
đường ống không thể phá vỡ trình tự rõ ràng này và liệu một bổ sung
chu kỳ giả là cần thiết giữa việc xóa cờ và ngắt. Bật
giao diện Avalon, nó thực sự đã được chứng minh là như vậy, nhưng APB đang
an toàn vì nó sử dụng giao dịch 2 chu kỳ. Về cơ bản, cờ DOR
sẽ bị xóa, nhưng đầu vào cài sẵn của thanh ghi DOI vẫn ở mức cao
chu kỳ khi yêu cầu xóa DOI cũng sẽ được áp dụng (bằng cách cài đặt
đầu vào Reset ở mức cao của thanh ghi). Vì Set có mức độ ưu tiên cao hơn Reset,
cờ DOI sẽ không được đặt lại. Điều này đã được sửa bằng cách hoán đổi
mức độ ưu tiên Đặt/Đặt lại (xem vấn đề #187).

Báo cáo lỗi thụ động và điều kiện tắt xe buýt
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Có thể nên báo cáo khi nút đạt tới ZZ0000ZZ,
Điều kiện ZZ0001ZZ và ZZ0002ZZ. Người lái xe được thông báo về
thay đổi trạng thái lỗi do ngắt (EPI, EWLI), sau đó tiến tới
xác định trạng thái lỗi của lõi bằng cách đọc bộ đếm lỗi của nó.

Tuy nhiên, có một điều kiện tranh đua nhỏ ở đây – có sự chậm trễ
giữa thời điểm xảy ra quá trình chuyển đổi trạng thái (và thời điểm ngắt được
được kích hoạt) và khi bộ đếm lỗi được đọc. Khi nhận được EPI,
nút có thể là ZZ0000ZZ hoặc ZZ0001ZZ. Nếu nút đi
ZZ0002ZZ, rõ ràng là nó vẫn ở trạng thái cho đến khi được đặt lại.
Nếu không, nút là ZZ0003ZZ ZZ0004ZZ. Tuy nhiên, nó có thể xảy ra
trạng thái đọc là ZZ0005ZZ hoặc thậm chí ZZ0006ZZ. Nó có thể là
không rõ liệu có nên báo cáo chính xác điều gì trong trường hợp đó hay không, nhưng tôi
cá nhân tôi có ý tưởng rằng tình trạng lỗi trong quá khứ vẫn nên
được báo cáo. Tương tự, khi nhận được EWLI nhưng trạng thái muộn hơn
được phát hiện là ZZ0007ZZ, ZZ0008ZZ phải được báo cáo.


Tham khảo nguồn trình điều khiển CTU CAN FD
-----------------------------------

.. kernel-doc:: drivers/net/can/ctucanfd/ctucanfd.h
   :internal:

.. kernel-doc:: drivers/net/can/ctucanfd/ctucanfd_base.c
   :internal:

.. kernel-doc:: drivers/net/can/ctucanfd/ctucanfd_pci.c
   :internal:

.. kernel-doc:: drivers/net/can/ctucanfd/ctucanfd_platform.c
   :internal:

Xác nhận phát triển trình điều khiển và lõi IP CTU CAN FD
---------------------------------------------------------

* Odrej Ille <ondrej.ille@gmail.com>

* bắt đầu dự án khi là sinh viên Khoa Đo Lường, FEE, CTU
  * đã đầu tư rất nhiều thời gian và tâm huyết cá nhân cho dự án trong nhiều năm
  * thực hiện các nhiệm vụ được tài trợ nhiều hơn

* ZZ0000ZZ,
  ZZ0001ZZ,
  ZZ0002ZZ

* là chủ đầu tư chính của dự án trong nhiều năm
  * sử dụng dự án trong khung chẩn đoán CAN/CAN FD của họ cho ZZ0000ZZ

* ZZ0000ZZ

* tài trợ cho dự án CAN FD Hỗ trợ lõi mở Hệ thống dựa trên hạt nhân Linux
  * đã thương lượng và thanh toán CTU để cho phép công chúng truy cập vào dự án
  * cung cấp thêm kinh phí cho công việc

* ZZ0000ZZ,
  ZZ0001ZZ,
  ZZ0002ZZ

* giải quyết dự án CAN FD Hỗ trợ lõi mở Hệ thống dựa trên hạt nhân Linux
  * cung cấp quản lý GitLab
  * máy chủ ảo và sức mạnh tính toán để tích hợp liên tục
  * cung cấp phần cứng cho các thử nghiệm tích hợp liên tục HIL

* ZZ0000ZZ

* nguồn tài trợ nhỏ để bắt đầu chuẩn bị nguồn mở cho dự án

* Petr Porazil <porazil@pikron.com>

* thiết kế bo mạch bổ trợ bộ thu phát PCIe và lắp ráp các bo mạch
  * thiết kế và lắp ráp ván chân tường MZ_APO cho hệ thống dựa trên MicroZed/Zynq

* Martin Jerabek <martin.jerabek01@gmail.com>

* Phát triển trình điều khiển Linux
  * kiến trúc nền tảng tích hợp liên tục và cập nhật GHDL
  * luận án ZZ0000ZZ

* Jiri Novak <jnovak@fel.cvut.cz>

* Khởi tạo, quản lý và sử dụng dự án tại Cục Đo lường, FEE, CTU

* Pavel Pisa <pisa@cmp.felk.cvut.cz>

* khởi xướng nguồn mở, điều phối dự án, quản lý tại Khoa Kỹ thuật Điều khiển, FEE, CTU

* Jaroslav Beran<jara.beran@gmail.com>

* tích hợp hệ thống để kiểm tra và cập nhật Intel SoC, lõi và trình điều khiển

* Carsten Emde (ZZ0000ZZ)

* cung cấp chuyên môn cho OSADL để thảo luận về việc cấp phép lõi IP
 * chỉ ra sự bế tắc có thể xảy ra đối với trường hợp bằng sáng chế có thể xảy ra đối với xe buýt LGPL và CAN dẫn đến việc cấp lại giấy phép thiết kế lõi IP cho BSD

* Reiner Zitzmann và Holger Zeltwanger (ZZ0000ZZ)

* cung cấp các đề xuất và trợ giúp để thông báo cho cộng đồng về dự án và mời chúng tôi tham dự các sự kiện tập trung vào hướng phát triển trong tương lai của xe buýt CAN

* Jan Charvat

* đã triển khai mô hình chức năng CTU CAN FD cho QEMU đã được tích hợp vào đường dây chính QEMU (ZZ0000ZZ)
 * Luận văn tốt nghiệp Model Bộ điều khiển truyền thông CAN FD cho Trình giả lập QEMU

Ghi chú
-----


.. [1]
   Other buses have their own specific driver interface to set up the
   device.

.. [2]
   Not to be mistaken with CAN Error Frame. This is a ``can_frame`` with
   ``CAN_ERR_FLAG`` set and some error info in its ``data`` field.

.. [3]
   Available in CTU CAN FD repository
   `<https://gitlab.fel.cvut.cz/canbus/ctucanfd_ip_core>`_

.. [4]
   As is done in the low-level driver functions
   ``ctucan_hw_set_nom_bittiming`` and
   ``ctucan_hw_set_data_bittiming``.

.. [5]
   At the time of writing this thesis, option 1 is still being used and
   the modification is queued in gitlab issue #222

.. [6]
   Strictly speaking, multiple CAN TX queues are supported since v4.19
   `can: enable multi-queue for SocketCAN devices <https://lore.kernel.org/patchwork/patch/913526/>`_ but no mainline driver is using
   them yet.

.. [7]
   Or rather in the next clock cycle