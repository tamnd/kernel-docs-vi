.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/net_dim.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================================================
Net DIM - Kiểm duyệt ngắt động mạng chung
======================================================

:Tác giả: Tal Gilboa <talgi@mellanox.com>

.. contents:: :depth: 2

Giả định
===========

Tài liệu này giả định người đọc có kiến thức cơ bản về driver mạng
và nói chung là ngắt quãng.


Giới thiệu
============

Kiểm duyệt ngắt động (DIM) (trong mạng) đề cập đến việc thay đổi
ngắt cấu hình kiểm duyệt của kênh để tối ưu hóa gói
xử lý. Cơ chế này bao gồm một thuật toán quyết định xem có nên thực hiện hay không và làm thế nào để
thay đổi các tham số kiểm duyệt cho một kênh, thường bằng cách thực hiện phân tích trên
dữ liệu thời gian chạy được lấy mẫu từ hệ thống. Net DIM là một cơ chế như vậy. Trong mỗi
lặp lại thuật toán, nó phân tích một mẫu dữ liệu nhất định, so sánh nó
với mẫu trước đó và nếu được yêu cầu, nó có thể quyết định thay đổi một số
làm gián đoạn các trường cấu hình kiểm duyệt. Mẫu dữ liệu bao gồm dữ liệu
băng thông, số lượng gói và số lượng sự kiện. Thời gian giữa
mẫu cũng được đo. Net DIM so sánh dữ liệu hiện tại và dữ liệu trước đó và
trả về một đối tượng cấu hình kiểm duyệt ngắt đã điều chỉnh. Trong một số trường hợp,
thuật toán có thể quyết định không thay đổi bất cứ điều gì. Các trường cấu hình là
thời lượng tối thiểu (micro giây) được phép giữa các sự kiện và thời lượng tối đa
số lượng gói mong muốn cho mỗi sự kiện. Thuật toán Net DIM nhấn mạnh tầm quan trọng của
tăng băng thông bằng cách giảm tốc độ ngắt.


Thuật toán DIM ròng
=================

Mỗi lần lặp của thuật toán Net DIM đều tuân theo các bước sau:

#. Tính toán mẫu dữ liệu mới.
#. So sánh nó với mẫu trước đó.
#. Đưa ra quyết định - đề xuất ngắt các trường cấu hình kiểm duyệt.
#. Áp dụng chức năng lập lịch làm việc, áp dụng cấu hình được đề xuất.

Hai bước đầu tiên rất đơn giản, cả dữ liệu mới và dữ liệu trước đó đều được
được cung cấp bởi trình điều khiển đã đăng ký trên Net DIM. Dữ liệu trước đó là dữ liệu mới
được cung cấp cho lần lặp trước. Bước so sánh kiểm tra sự khác biệt
giữa dữ liệu mới và dữ liệu trước đó và quyết định kết quả của bước cuối cùng.
Một bước sẽ cho kết quả là "tốt hơn" nếu băng thông tăng và sẽ "tệ hơn" nếu
băng thông giảm. Nếu không có thay đổi về băng thông thì tốc độ gói tin là
được so sánh theo cách tương tự - tăng == "tốt hơn" và giảm == "tệ hơn".
Trong trường hợp không có sự thay đổi về tốc độ gói, tốc độ ngắt là
so sánh. Ở đây thuật toán cố gắng tối ưu hóa để có tốc độ ngắt thấp hơn nên
việc tăng tốc độ ngắt được coi là "tệ hơn" và việc giảm
được coi là "tốt hơn". Bước #2 có tính năng tối ưu hóa để tránh kết quả sai: nó
chỉ coi sự khác biệt giữa các mẫu là hợp lệ nếu nó lớn hơn giá trị
tỷ lệ nhất định. Ngoài ra, vì Net DIM không tự đo bất cứ thứ gì nên nó
giả sử dữ liệu được cung cấp bởi trình điều khiển là hợp lệ.

Bước #3 quyết định cấu hình đề xuất dựa trên kết quả từ bước #2
và trạng thái bên trong của thuật toán. Các bang phản ánh “hướng” của
thuật toán: nó đi sang trái (giảm điều độ), sang phải (tăng
điều độ) hoặc đứng yên. Một sự tối ưu hóa khác là nếu một quyết định
để đứng yên được thực hiện nhiều lần, khoảng thời gian giữa các lần lặp lại của
thuật toán sẽ tăng lên để giảm chi phí tính toán. Ngoài ra, sau
"đỗ xe" theo một trong những quyết định trái nhất hoặc đúng nhất, thuật toán có thể
quyết định xác minh quyết định này bằng cách thực hiện một bước theo hướng khác. Đây là
được thực hiện để tránh bị mắc kẹt trong tình huống "ngủ sâu". Một lần
quyết định được đưa ra, cấu hình kiểm duyệt ngắt được chọn từ
các hồ sơ được xác định trước.

Bước cuối cùng là thông báo cho người lái xe đã đăng ký rằng họ nên áp dụng
cấu hình được đề xuất. Điều này được thực hiện bằng cách lập kế hoạch cho một chức năng công việc, được xác định bởi
Net DIM API và được cung cấp bởi trình điều khiển đã đăng ký.

Như bạn có thể thấy, bản thân Net DIM không tương tác tích cực với hệ thống. Nó
sẽ gặp khó khăn trong việc đưa ra quyết định đúng nếu dữ liệu sai được cung cấp cho
nó và sẽ vô ích nếu chức năng công việc không áp dụng được đề xuất
cấu hình. Tuy nhiên, điều này cho phép người lái xe đã đăng ký có chỗ để
thao tác vì nó có thể cung cấp một phần dữ liệu hoặc bỏ qua đề xuất thuật toán
dưới một số điều kiện.


Đăng ký thiết bị mạng với DIM
===================================

Net DIM API hiển thị hàm chính net_dim().
Chức năng này là điểm vào Net
Thuật toán DIM và phải được gọi mỗi khi người lái xe muốn kiểm tra xem
nó sẽ thay đổi các tham số kiểm duyệt ngắt. Người lái xe nên cung cấp hai
cấu trúc dữ liệu: ZZ0000ZZ và
ZZ0001ZZ. ZZ0002ZZ
mô tả trạng thái của DIM cho một đối tượng cụ thể (hàng đợi RX, hàng đợi TX,
hàng đợi khác, v.v.). Điều này bao gồm hồ sơ được chọn hiện tại, dữ liệu trước đó
mẫu, chức năng gọi lại do trình điều khiển cung cấp và hơn thế nữa.
ZZ0003ZZ mô tả một mẫu dữ liệu,
sẽ được so sánh với mẫu dữ liệu được lưu trữ trong ZZ0004ZZ
để quyết định bước tiếp theo của thuật toán
bước. Mẫu nên bao gồm byte, gói và ngắt, được đo bằng
người lái xe.

Để sử dụng Net DIM từ trình điều khiển mạng, trình điều khiển cần gọi
hàm net_dim() chính. Phương pháp được đề xuất là gọi net_dim() trên mỗi
ngắt lời. Vì Net DIM có tính năng kiểm duyệt được tích hợp sẵn và nó có thể quyết định bỏ qua
lặp đi lặp lại trong những điều kiện nhất định, không cần phải kiểm duyệt net_dim()
cuộc gọi cũng vậy. Như đã đề cập ở trên, trình điều khiển cần cung cấp một đối tượng thuộc loại
ZZ0000ZZ vào lệnh gọi hàm net_dim(). Nó được khuyên dùng cho
mỗi thực thể sử dụng Net DIM để giữ ZZ0001ZZ như một phần của nó
cấu trúc dữ liệu và sử dụng nó làm đối tượng Net DIM API chính.
ZZ0002ZZ sẽ có phiên bản mới nhất
số byte, gói và số lần ngắt. Không cần thực hiện bất kỳ phép tính nào, chỉ cần
bao gồm dữ liệu thô.

Bản thân lệnh gọi net_dim() không trả về bất cứ thứ gì. Thay vào đó Net DIM dựa vào
trình điều khiển để cung cấp chức năng gọi lại, chức năng này được gọi khi thuật toán
quyết định thực hiện thay đổi các tham số điều tiết ngắt. Cuộc gọi lại này
sẽ được lên lịch và chạy trong một luồng riêng biệt để không thêm chi phí vào
luồng dữ liệu. Sau khi hoàn thành công việc, thuật toán Net DIM cần được đặt thành
trạng thái thích hợp để chuyển sang lần lặp tiếp theo.


Ví dụ
=======

Đoạn mã sau đây trình bày cách đăng ký trình điều khiển vào Net DIM. thực tế
việc sử dụng chưa hoàn tất nhưng nó phải làm rõ nội dung sử dụng.

.. code-block:: c

  #include <linux/dim.h>

  /* Callback for net DIM to schedule on a decision to change moderation */
  void my_driver_do_dim_work(struct work_struct *work)
  {
	/* Get struct dim from struct work_struct */
	struct dim *dim = container_of(work, struct dim,
				       work);
	/* Do interrupt moderation related stuff */
	...

	/* Signal net DIM work is done and it should move to next iteration */
	dim->state = DIM_START_MEASURE;
  }

  /* My driver's interrupt handler */
  int my_driver_handle_interrupt(struct my_driver_entity *my_entity, ...)
  {
	...
	/* A struct to hold current measured data */
	struct dim_sample dim_sample;
	...
	/* Initiate data sample struct with current data */
	dim_update_sample(my_entity->events,
		          my_entity->packets,
		          my_entity->bytes,
		          &dim_sample);
	/* Call net DIM */
	net_dim(&my_entity->dim, &dim_sample);
	...
  }

  /* My entity's initialization function (my_entity was already allocated) */
  int my_driver_init_my_entity(struct my_driver_entity *my_entity, ...)
  {
	...
	/* Initiate struct work_struct with my driver's callback function */
	INIT_WORK(&my_entity->dim.work, my_driver_do_dim_work);
	...
  }


Điều chỉnh DIM
==========

Net DIM phục vụ nhiều loại thiết bị mạng và mang lại khả năng tăng tốc tuyệt vời
lợi ích. Tuy nhiên, người ta nhận thấy rằng một số cấu hình cài sẵn của DIM có thể
không phù hợp liền mạch với các thông số kỹ thuật khác nhau của thiết bị mạng và
sự khác biệt này đã được xác định là một yếu tố dẫn đến hiệu suất dưới mức tối ưu
kết quả của các thiết bị mạng hỗ trợ DIM, liên quan đến cấu hình không khớp.

Để giải quyết vấn đề này, Net DIM giới thiệu tính năng điều khiển trên mỗi thiết bị để sửa đổi và
truy cập các thông số ZZ0001ZZ và ZZ0002ZZ của thiết bị:
Giả sử thiết bị mạng đích có tên là ethx và ethx chỉ khai báo
hỗ trợ cài đặt cấu hình RX và hỗ trợ sửa đổi trường ZZ0003ZZ
và trường ZZ0004ZZ (Xem cấu trúc dữ liệu:
ZZ0000ZZ).

Bạn có thể sử dụng ethtool để sửa đổi cấu hình RX DIM hiện tại trong đó tất cả
giá trị là 64::

$ ethtool -C ethx rx-profile 1,1,n_2,2,n_3,n,n_n,4,n_n,n,n

ZZ0000ZZ có nghĩa là không sửa đổi trường này và ZZ0001ZZ tách cấu trúc
các phần tử của mảng hồ sơ.

Truy vấn hồ sơ hiện tại bằng cách sử dụng::

$ ethtool -c ethx
    ...
hồ sơ rx:
    {.usec = 1, .pkts = 1, .comps = n/a,},
    {.usec = 2, .pkts = 2, .comps = n/a,},
    {.usec = 3, .pkts = 64, .comps = n/a,},
    {.usec = 64, .pkts = 4, .comps = n/a,},
    {.usec = 64, .pkts = 64, .comps = n/a,}
    hồ sơ tx: n/a

Nếu thiết bị mạng không hỗ trợ các trường cụ thể của cấu hình DIM,
ZZ0000ZZ tương ứng sẽ hiển thị. Nếu trường ZZ0001ZZ đang được
sửa đổi, thông báo lỗi sẽ được báo cáo.


Thư viện điều chế ngắt động (DIM) API
==============================================

.. kernel-doc:: include/linux/dim.h
    :internal:
