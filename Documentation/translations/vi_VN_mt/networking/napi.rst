.. SPDX-License-Identifier: (GPL-2.0-only OR BSD-2-Clause)

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/napi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _napi:

====
NAPI
====

NAPI là cơ chế xử lý sự kiện được sử dụng bởi ngăn xếp mạng Linux.
Cái tên NAPI không còn đại diện cho bất cứ điều gì cụ thể [#]_.

Trong hoạt động cơ bản, thiết bị sẽ thông báo cho máy chủ về các sự kiện mới
thông qua một ngắt.
Sau đó, máy chủ lên lịch cho phiên bản NAPI để xử lý các sự kiện.
Thiết bị cũng có thể được thăm dò các sự kiện thông qua NAPI mà không nhận được
ngắt đầu tiên (ZZ0000ZZ).

Quá trình xử lý NAPI thường xảy ra trong bối cảnh ngắt phần mềm,
nhưng có một tùy chọn để sử dụng ZZ0000ZZ
để xử lý NAPI.

Nhìn chung, NAPI tóm tắt bối cảnh và cấu hình khỏi trình điều khiển
xử lý sự kiện (gói Rx và Tx).

Trình điều khiển API
==========

Hai thành phần quan trọng nhất của NAPI là struct napi_struct
và phương pháp thăm dò liên quan. struct napi_struct giữ trạng thái
của phiên bản NAPI trong khi phương thức này là sự kiện dành riêng cho trình điều khiển
người xử lý. Phương thức này thường sẽ giải phóng các gói Tx đã được
được truyền đi và xử lý các gói tin mới nhận được.

.. _drv_ctrl:

Điều khiển API
-----------

netif_napi_add() và netif_napi_del() thêm/xóa phiên bản NAPI
từ hệ thống. Các phiên bản được gắn vào netdevice đã được thông qua
làm đối số (và sẽ tự động bị xóa khi netdevice được
chưa đăng ký). Các trường hợp được thêm vào ở trạng thái bị vô hiệu hóa.

napi_enable() và napi_disable() quản lý trạng thái bị tắt.
Không thể lên lịch NAPI bị vô hiệu hóa và phương thức thăm dò ý kiến của nó được đảm bảo
để không được triệu tập. napi_disable() chờ quyền sở hữu NAPI
dụ sẽ được phát hành.

Các API kiểm soát không bình thường. Kiểm soát các cuộc gọi API được đảm bảo an toàn
sử dụng đồng thời các API đường dữ liệu nhưng trình tự điều khiển không chính xác API
các cuộc gọi có thể dẫn đến sự cố, bế tắc hoặc tình trạng chạy đua. Ví dụ,
gọi napi_disable() nhiều lần liên tiếp sẽ bế tắc.

Đường dẫn dữ liệu API
------------

napi_schedule() là phương pháp cơ bản để lên lịch cuộc thăm dò NAPI.
Trình điều khiển nên gọi hàm này trong trình xử lý ngắt của họ
(xem ZZ0000ZZ để biết thêm thông tin). Cuộc gọi thành công tới napi_schedule()
sẽ sở hữu phiên bản NAPI.

Sau này, sau khi NAPI được lên lịch, phương thức thăm dò ý kiến của người lái xe sẽ là
được gọi để xử lý các sự kiện/gói. Phương thức này lấy ZZ0000ZZ
đối số - trình điều khiển có thể xử lý việc hoàn thành cho bất kỳ số lượng Tx nào
các gói nhưng chỉ nên xử lý số lượng tối đa ZZ0001ZZ
gói Rx. Xử lý Rx thường đắt hơn nhiều.

Nói cách khác để xử lý Rx, đối số ZZ0000ZZ giới hạn số lượng
trình điều khiển gói có thể xử lý trong một cuộc thăm dò duy nhất. Trang tương tự API cụ thể của Rx
pool hoặc XDP hoàn toàn không thể được sử dụng khi ZZ0001ZZ bằng 0.
Quá trình xử lý skb Tx sẽ diễn ra bất kể ZZ0002ZZ, nhưng nếu
đối số là 0, trình điều khiển không thể gọi bất kỳ API XDP (hoặc nhóm trang) nào.

.. warning::

   The ``budget`` argument may be 0 if core tries to only process
   skb Tx completions and no Rx or XDP packets.

Phương thức thăm dò trả về số lượng công việc đã hoàn thành. Nếu người lái xe vẫn
có việc cần làm (ví dụ: ZZ0000ZZ đã cạn kiệt)
phương thức thăm dò ý kiến ​​sẽ trả về chính xác ZZ0001ZZ. Trong trường hợp đó,
phiên bản NAPI sẽ được bảo trì/kiểm tra lại (không có
cần phải lên lịch).

Nếu quá trình xử lý sự kiện đã hoàn tất (tất cả các gói chưa được xử lý
được xử lý), phương thức thăm dò ý kiến sẽ gọi napi_complete_done()
trước khi quay lại. napi_complete_done() giải phóng quyền sở hữu
của ví dụ.

.. warning::

   The case of finishing all events and using exactly ``budget``
   must be handled carefully. There is no way to report this
   (rare) condition to the stack, so the driver must either
   not call napi_complete_done() and wait to be called again,
   or return ``budget - 1``.

   If the ``budget`` is 0 napi_complete_done() should never be called.

Trình tự cuộc gọi
-------------

Người lái xe không nên đưa ra giả định về trình tự chính xác
của các cuộc gọi. Phương thức thăm dò có thể được gọi mà không cần lập lịch trình điều khiển
phiên bản đó (trừ khi phiên bản đó bị vô hiệu hóa). Tương tự,
không đảm bảo rằng phương thức thăm dò ý kiến sẽ được gọi, thậm chí
nếu napi_schedule() thành công (ví dụ: nếu phiên bản bị vô hiệu hóa).

Như đã đề cập trong phần ZZ0000ZZ - napi_disable() và phần tiếp theo
các cuộc gọi đến phương thức thăm dò ý kiến chỉ chờ quyền sở hữu cá thể
sẽ được phát hành, không phải để thoát khỏi phương thức thăm dò ý kiến. Điều này có nghĩa là
trình điều khiển nên tránh truy cập bất kỳ cấu trúc dữ liệu nào sau khi gọi
napi_complete_done().

.. _drv_sched:

Lập kế hoạch và tạo mặt nạ IRQ
--------------------------

Người lái xe nên che giấu các gián đoạn sau khi lên lịch
phiên bản NAPI - cho đến khi quá trình bỏ phiếu NAPI kết thúc thêm
ngắt là không cần thiết.

Các trình điều khiển phải che giấu các ngắt một cách rõ ràng (trái ngược với
để IRQ được thiết bị tự động che giấu) nên sử dụng napi_schedule_prep()
và các cuộc gọi __napi_schedule():

.. code-block:: c

  if (napi_schedule_prep(&v->napi)) {
      mydrv_mask_rxtx_irq(v->idx);
      /* schedule after masking to avoid races */
      __napi_schedule(&v->napi);
  }

IRQ chỉ nên được hiển thị sau khi gọi thành công tới napi_complete_done():

.. code-block:: c

  if (budget && napi_complete_done(&v->napi, work_done)) {
    mydrv_unmask_rxtx_irq(v->idx);
    return min(work_done, budget - 1);
  }

napi_schedule_irqoff() là một biến thể của napi_schedule() tận dụng lợi thế
về các đảm bảo được đưa ra bằng cách gọi trong ngữ cảnh IRQ (không cần
mặt nạ ngắt). napi_schedule_irqoff() sẽ quay trở lại napi_schedule() nếu
IRQ được phân luồng (chẳng hạn như nếu ZZ0000ZZ được bật).

Sơ đồ ánh xạ hàng đợi
-------------------------

Các thiết bị hiện đại có nhiều phiên bản NAPI (struct napi_struct) trên mỗi
giao diện. Không có yêu cầu mạnh mẽ về cách thức các phiên bản được thực hiện
ánh xạ tới hàng đợi và ngắt. NAPI chủ yếu là một công cụ bỏ phiếu/xử lý
sự trừu tượng hóa mà không có ngữ nghĩa cụ thể hướng tới người dùng. Điều đó nói rằng, hầu hết các mạng
các thiết bị cuối cùng sử dụng NAPI theo những cách khá giống nhau.

Các phiên bản NAPI thường tương ứng 1:1:1 với các cặp ngắt và hàng đợi
(cặp hàng đợi là một tập hợp của một hàng đợi Rx và một hàng đợi Tx).

Trong những trường hợp ít phổ biến hơn, phiên bản NAPI có thể được sử dụng cho nhiều hàng đợi
hoặc hàng đợi Rx và Tx có thể được phục vụ bởi các phiên bản NAPI riêng biệt trên một
cốt lõi. Tuy nhiên, bất kể việc phân công hàng đợi như thế nào, vẫn thường có
ánh xạ 1:1 giữa các phiên bản NAPI và các ngắt.

Điều đáng lưu ý là ethtool API sử dụng thuật ngữ "kênh" trong đó
mỗi kênh có thể là ZZ0000ZZ, ZZ0001ZZ hoặc ZZ0002ZZ. Nó không rõ ràng
những gì tạo nên một kênh; cách giải thích được đề nghị là để hiểu
một kênh dưới dạng IRQ/NAPI phục vụ các hàng đợi thuộc một loại nhất định. Ví dụ,
dự kiến sẽ có cấu hình gồm 1 kênh ZZ0003ZZ, 1 ZZ0004ZZ và 1 kênh ZZ0005ZZ
để sử dụng 3 ngắt, 2 hàng đợi Rx và 2 Tx.

Cấu hình NAPI liên tục
----------------------

Trình điều khiển thường phân bổ và giải phóng các phiên bản NAPI một cách linh hoạt. Điều này dẫn đến mất mát
cấu hình người dùng liên quan đến NAPI mỗi khi phiên bản NAPI được phân bổ lại.
netif_napi_add_config() API ngăn chặn việc mất cấu hình này bằng cách
liên kết từng phiên bản NAPI với cấu hình NAPI liên tục dựa trên
giá trị chỉ mục do trình điều khiển xác định, chẳng hạn như số hàng đợi.

Việc sử dụng API này cho phép ID NAPI liên tục (trong số các cài đặt khác), có thể
có lợi cho các chương trình không gian người dùng sử dụng ZZ0000ZZ. Xem
các phần bên dưới để biết các cài đặt cấu hình NAPI khác.

Trình điều khiển nên cố gắng sử dụng netif_napi_add_config() bất cứ khi nào có thể.

Người dùng API
========

Tương tác của người dùng với NAPI phụ thuộc vào ID phiên bản NAPI. ID phiên bản
chỉ hiển thị với người dùng thông qua tùy chọn ổ cắm ZZ0000ZZ.

Người dùng có thể truy vấn ID NAPI cho thiết bị hoặc hàng đợi thiết bị bằng liên kết mạng. Điều này có thể
được thực hiện theo chương trình trong ứng dụng người dùng hoặc bằng cách sử dụng tập lệnh có trong
cây nguồn hạt nhân: ZZ0000ZZ.

Ví dụ: sử dụng tập lệnh để kết xuất tất cả hàng đợi cho một thiết bị (mà
sẽ tiết lộ ID NAPI của mỗi hàng đợi):

.. code-block:: bash

   $ kernel-source/tools/net/ynl/pyynl/cli.py \
             --spec Documentation/netlink/specs/netdev.yaml \
             --dump queue-get \
             --json='{"ifindex": 2}'

Xem ZZ0000ZZ để biết thêm chi tiết về
các hoạt động và thuộc tính có sẵn.

Phần mềm kết hợp IRQ
-----------------------

Theo mặc định, NAPI không thực hiện bất kỳ sự hợp nhất sự kiện rõ ràng nào.
Trong hầu hết các trường hợp, việc phân khối xảy ra do quá trình kết hợp IRQ được thực hiện
bởi thiết bị. Có những trường hợp việc hợp nhất phần mềm rất hữu ích.

NAPI có thể được cấu hình để kích hoạt bộ đếm thời gian thay vì vạch mặt
phần cứng bị gián đoạn ngay khi tất cả các gói được xử lý.
Cấu hình sysfs ZZ0000ZZ của netdevice
được tái sử dụng để điều khiển độ trễ của bộ định thời, trong khi
ZZ0001ZZ kiểm soát số lượng phiếu bầu trống liên tiếp
trước khi NAPI từ bỏ và quay lại sử dụng IRQ phần cứng.

Các tham số trên cũng có thể được đặt trên cơ sở mỗi NAPI bằng cách sử dụng liên kết mạng qua
netdev-genl. Khi được sử dụng với liên kết mạng và được định cấu hình trên cơ sở mỗi NAPI,
các tham số được đề cập ở trên sử dụng dấu gạch nối thay vì dấu gạch dưới:
ZZ0000ZZ và ZZ0001ZZ.

Cấu hình Per-NAPI có thể được thực hiện theo chương trình trong ứng dụng người dùng
hoặc bằng cách sử dụng tập lệnh có trong cây nguồn kernel:
ZZ0000ZZ.

Ví dụ: sử dụng tập lệnh:

.. code-block:: bash

  $ kernel-source/tools/net/ynl/pyynl/cli.py \
            --spec Documentation/netlink/specs/netdev.yaml \
            --do napi-set \
            --json='{"id": 345,
                     "defer-hard-irqs": 111,
                     "gro-flush-timeout": 11111}'

Tương tự, tham số ZZ0000ZZ có thể được đặt bằng netlink
thông qua netdev-genl. Không có tham số sysfs chung cho giá trị này.

ZZ0000ZZ được sử dụng để xác định thời gian ứng dụng có thể
đình chỉ hoàn toàn IRQ. Nó được sử dụng kết hợp với SO_PREFER_BUSY_POLL,
có thể được đặt trên cơ sở ngữ cảnh mỗi epoll với ZZ0001ZZ ioctl.

.. _poll:

Bỏ phiếu bận rộn
------------

Kiểm tra bận cho phép tiến trình người dùng kiểm tra các gói đến trước khi
thiết bị ngắt lửa. Như trường hợp của bất kỳ cuộc bỏ phiếu bận rộn nào, nó giao dịch
tắt chu kỳ CPU để có độ trễ thấp hơn (sử dụng NAPI để bỏ phiếu bận
không được biết đến nhiều).

Bỏ phiếu bận được bật bằng cách bật ZZ0001ZZ
ổ cắm đã chọn hoặc sử dụng ZZ0002ZZ toàn cầu và
Hệ thống ZZ0003ZZ. Một io_uring API dành cho NAPI đang bận bỏ phiếu
cũng tồn tại. Thăm dò theo luồng của NAPI cũng có chế độ thăm dò bận rộn cho
gói (ZZ0000ZZ) sử dụng NAPI
xử lý kthread.

bỏ phiếu bận rộn dựa trên epoll
------------------------

Có thể kích hoạt xử lý gói trực tiếp từ các cuộc gọi đến
ZZ0000ZZ. Để sử dụng tính năng này, ứng dụng người dùng phải đảm bảo
tất cả các bộ mô tả tệp được thêm vào ngữ cảnh epoll đều có cùng ID NAPI.

Nếu ứng dụng sử dụng một luồng chấp nhận chuyên dụng, ứng dụng có thể lấy được
ID NAPI của kết nối đến bằng SO_INCOMING_NAPI_ID, sau đó
phân phối bộ mô tả tệp đó tới một chuỗi công việc. Chuỗi công nhân sẽ thêm
bộ mô tả tập tin vào ngữ cảnh epoll của nó. Điều này sẽ đảm bảo mỗi luồng công nhân
có bối cảnh epoll với các FD có cùng ID NAPI.

Ngoài ra, nếu ứng dụng sử dụng SO_REUSEPORT, chương trình bpf hoặc ebpf có thể
được chèn vào để phân phối các kết nối đến các luồng sao cho mỗi luồng
chỉ được cung cấp các kết nối đến có cùng ID NAPI. Phải cẩn thận để
xử lý cẩn thận các trường hợp trong đó một hệ thống có thể có nhiều NIC.

Để kích hoạt bỏ phiếu bận, có hai lựa chọn:

1. ZZ0000ZZ có thể được đặt thời gian tính bằng u giây để bận
   vòng lặp chờ sự kiện. Đây là cài đặt toàn hệ thống và sẽ gây ra tất cả
   các ứng dụng dựa trên epoll sẽ bận thăm dò ý kiến khi chúng gọi epoll_wait. Điều này có thể
   không được mong muốn vì nhiều ứng dụng có thể không có nhu cầu thăm dò ý kiến bận rộn.

2. Các ứng dụng sử dụng kernel gần đây có thể phát hành ioctl trên bối cảnh epoll
   bộ mô tả tệp để đặt (ZZ0000ZZ) hoặc nhận (ZZ0001ZZ) ZZ0002ZZ:, mà chương trình người dùng có thể xác định như sau:

.. code-block:: c

  struct epoll_params {
      uint32_t busy_poll_usecs;
      uint16_t busy_poll_budget;
      uint8_t prefer_busy_poll;

      /* pad the struct to a multiple of 64bits */
      uint8_t __pad;
  };

Giảm thiểu IRQ
---------------

Trong khi việc bỏ phiếu bận được cho là sẽ được sử dụng bởi các ứng dụng có độ trễ thấp,
một cơ chế tương tự có thể được sử dụng để giảm thiểu IRQ.

Các ứng dụng có yêu cầu mỗi giây rất cao (đặc biệt là các ứng dụng định tuyến/chuyển tiếp
các ứng dụng và đặc biệt là các ứng dụng sử dụng ổ cắm AF_XDP) có thể không
muốn bị gián đoạn cho đến khi họ xử lý xong một yêu cầu hoặc một đợt
của các gói.

Những ứng dụng như vậy có thể cam kết với kernel rằng chúng sẽ thực hiện một công việc bận
hoạt động thăm dò định kỳ và trình điều khiển nên giữ IRQ của thiết bị
bị che khuất vĩnh viễn. Chế độ này được kích hoạt bằng cách sử dụng ZZ0000ZZ
tùy chọn ổ cắm. Để tránh hành vi sai trái của hệ thống, cam kết sẽ bị thu hồi
nếu ZZ0001ZZ vượt qua mà không có bất kỳ cuộc gọi thăm dò ý kiến bận nào. Dựa trên epoll
các ứng dụng bỏ phiếu bận rộn, trường ZZ0002ZZ của ZZ0003ZZ có thể được đặt thành 1 và ZZ0004ZZ ioctl có thể được cấp cho
kích hoạt chế độ này. Xem phần trên để biết thêm chi tiết.

Ngân sách NAPI dành cho bỏ phiếu bận rộn thấp hơn mặc định (điều này làm cho
có ý nghĩa với ý định có độ trễ thấp của việc bỏ phiếu bận rộn thông thường). Đây là
Tuy nhiên, không phải như vậy với việc giảm thiểu IRQ, do đó ngân sách có thể được điều chỉnh
với tùy chọn ổ cắm ZZ0000ZZ. Dành cho bỏ phiếu bận rộn dựa trên epoll
ứng dụng, trường ZZ0001ZZ có thể được điều chỉnh theo giá trị mong muốn
trong ZZ0002ZZ và đặt bối cảnh epoll cụ thể bằng ZZ0003ZZ
ioctl. Xem phần trên để biết thêm chi tiết.

Điều quan trọng cần lưu ý là việc chọn giá trị lớn cho ZZ0000ZZ
sẽ trì hoãn IRQ để cho phép xử lý hàng loạt tốt hơn nhưng sẽ gây ra độ trễ
khi hệ thống chưa được tải đầy đủ. Chọn giá trị nhỏ cho
ZZ0001ZZ có thể gây nhiễu ứng dụng của người dùng.
cố gắng thăm dò bận rộn bằng IRQ của thiết bị và xử lý softirq. Giá trị này
nên được lựa chọn cẩn thận với những sự đánh đổi này. bận dựa trên epol
các ứng dụng bỏ phiếu có thể giảm thiểu mức độ xử lý của người dùng xảy ra
bằng cách chọn giá trị thích hợp cho ZZ0002ZZ.

Người dùng có thể muốn xem xét một phương pháp thay thế, hệ thống treo IRQ, để giúp giải quyết
với những sự đánh đổi này.

Hệ thống treo IRQ
--------------

Hệ thống treo IRQ là một cơ chế trong đó IRQ của thiết bị bị che trong khi epoll
kích hoạt xử lý gói NAPI.

Trong khi ứng dụng gọi tới epoll_wait để truy xuất thành công các sự kiện, kernel sẽ
trì hoãn bộ hẹn giờ treo IRQ. Nếu kernel không truy xuất bất kỳ sự kiện nào
trong khi bận bỏ phiếu (ví dụ: do mức lưu lượng mạng giảm xuống), IRQ
hệ thống treo bị vô hiệu hóa và các chiến lược giảm thiểu IRQ được mô tả ở trên là
đã đính hôn.

Điều này cho phép người dùng cân bằng mức tiêu thụ CPU với xử lý mạng
hiệu quả.

Để sử dụng cơ chế này:

1. Tham số cấu hình ZZ0000ZZ trên mỗi NAPI phải được đặt thành
     thời gian tối đa (tính bằng nano giây) ứng dụng có thể có IRQ
     bị đình chỉ. Điều này được thực hiện bằng cách sử dụng netlink, như được mô tả ở trên. Thời gian chờ này
     đóng vai trò như một cơ chế an toàn để khởi động lại quá trình xử lý ngắt trình điều khiển IRQ nếu
     ứng dụng đã bị đình trệ. Giá trị này nên được chọn sao cho nó bao gồm
     lượng thời gian mà ứng dụng người dùng cần để xử lý dữ liệu từ
     gọi tới epoll_wait, lưu ý rằng các ứng dụng có thể kiểm soát lượng dữ liệu
     họ truy xuất bằng cách đặt ZZ0001ZZ khi gọi epoll_wait.

2. Tham số sysfs hoặc tham số cấu hình per-NAPI ZZ0000ZZ
     và ZZ0001ZZ có thể được đặt ở giá trị thấp. Chúng sẽ được sử dụng
     để trì hoãn IRQ sau khi cuộc thăm dò bận rộn không tìm thấy dữ liệu.

3. Cờ ZZ0000ZZ phải được đặt thành true. Điều này có thể được thực hiện bằng cách sử dụng
     ZZ0001ZZ ioctl như được mô tả ở trên.

4. Ứng dụng sử dụng epoll như mô tả ở trên để kích hoạt gói NAPI
     xử lý.

Như đã đề cập ở trên, miễn là các lệnh gọi tiếp theo tới epoll_wait sẽ trả lại các sự kiện cho
vùng người dùng, ZZ0000ZZ bị hoãn lại và IRQ bị vô hiệu hóa. Cái này
cho phép ứng dụng xử lý dữ liệu mà không bị can thiệp.

Khi lệnh gọi tới epoll_wait không tìm thấy sự kiện nào, việc tạm dừng IRQ sẽ bị hủy
tự động bị vô hiệu hóa và ZZ0000ZZ và
Cơ chế giảm thiểu ZZ0001ZZ tiếp quản.

Dự kiến ​​ZZ0000ZZ sẽ được đặt thành giá trị lớn hơn nhiều
hơn ZZ0001ZZ vì ZZ0002ZZ sẽ tạm dừng IRQ trong
thời lượng của một chu kỳ xử lý vùng người dùng.

Mặc dù không thực sự cần thiết phải sử dụng ZZ0000ZZ và
ZZ0001ZZ sử dụng hệ thống treo IRQ, công dụng của chúng rất mạnh mẽ
đề nghị.

Hệ thống treo IRQ khiến hệ thống luân phiên giữa chế độ bỏ phiếu và chế độ
phân phối gói theo hướng irq. Trong thời gian bận rộn, ZZ0000ZZ
ghi đè ZZ0001ZZ và giữ cho hệ thống bận rộn kiểm tra vòng, nhưng khi
epoll không tìm thấy sự kiện nào, cài đặt của ZZ0002ZZ và
ZZ0003ZZ xác định bước tiếp theo.

Về cơ bản có ba vòng lặp có thể có để xử lý mạng và
phân phối gói:

1) hardirq -> softirq -> thăm dò napi; phân phối ngắt cơ bản
2) hẹn giờ -> softirq -> thăm dò napi; xử lý irq hoãn lại
3) epoll -> bận-thăm dò ý kiến -> napi thăm dò ý kiến; vòng lặp bận rộn

Vòng 2 có thể lấy quyền điều khiển từ Vòng 1, nếu ZZ0000ZZ và
ZZ0001ZZ đã được thiết lập.

Nếu ZZ0000ZZ và ZZ0001ZZ được đặt, Vòng lặp 2
và 3 người “vật lộn” với nhau để giành quyền kiểm soát.

Trong thời gian bận, ZZ0000ZZ được sử dụng làm bộ đếm thời gian ở Vòng 2,
về cơ bản nghiêng quá trình xử lý mạng theo hướng có lợi cho Vòng 3.

Nếu ZZ0000ZZ và ZZ0001ZZ không được đặt, Vòng 3
không thể kiểm soát từ Vòng 1.

Do đó, việc cài đặt ZZ0000ZZ và ZZ0001ZZ là
mức sử dụng được khuyến nghị, vì nếu không thì cài đặt ZZ0002ZZ
có thể không có bất kỳ tác dụng rõ rệt nào.

.. _threaded_busy_poll:

Threaded NAPI đang bận bỏ phiếu
--------------------------

Tính năng bỏ phiếu bận rộn của NAPI theo luồng mở rộng NAPI theo luồng và thêm hỗ trợ để thực hiện
việc bỏ phiếu bận rộn liên tục của NAPI. Điều này có thể hữu ích cho việc chuyển tiếp hoặc
Ứng dụng AF_XDP.

Tính năng bỏ phiếu bận NAPI theo luồng có thể được bật trên cơ sở hàng đợi NIC bằng Netlink.

Ví dụ: sử dụng tập lệnh sau:

.. code-block:: bash

  $ ynl --family netdev --do napi-set \
            --json='{"id": 66, "threaded": "busy-poll"}'

Hạt nhân sẽ tạo một kthread để thực hiện các cuộc thăm dò trên NAPI này.

Người dùng có thể chọn đặt mối quan hệ CPU của kthread này thành CPU chưa sử dụng
cốt lõi để cải thiện tần suất NAPI được thăm dò với chi phí CPU lãng phí
chu kỳ. Lưu ý rằng điều này sẽ khiến lõi CPU bận rộn với mức sử dụng 100%.

Khi tính năng bỏ phiếu bận theo luồng được bật cho NAPI, PID của kthread có thể
được truy xuất bằng Netlink để có thể thiết lập mối quan hệ của kthread.

Ví dụ: tập lệnh sau có thể được sử dụng để tìm nạp PID:

.. code-block:: bash

  $ ynl --family netdev --do napi-get --json='{"id": 66}'

Điều này sẽ tạo ra kết quả như sau, pid ZZ0000ZZ là PID của
kthread đang thăm dò NAPI này.

.. code-block:: bash

  $ {'defer-hard-irqs': 0,
     'gro-flush-timeout': 0,
     'id': 66,
     'ifindex': 2,
     'irq-suspend-timeout': 0,
     'pid': 258,
     'threaded': 'busy-poll'}

.. _threaded:

Ren NAPI
-------------

Threaded NAPI là chế độ hoạt động sử dụng kernel chuyên dụng
các luồng thay vì bối cảnh IRQ phần mềm để xử lý NAPI.
Mỗi phiên bản NAPI theo luồng sẽ sinh ra một luồng riêng
(được gọi là ZZ0000ZZ).

Nên ghim từng luồng nhân vào một CPU duy nhất, giống nhau
CPU là CPU phục vụ ngắt. Lưu ý rằng việc ánh xạ
giữa các phiên bản IRQ và NAPI có thể không tầm thường (và trình điều khiển
phụ thuộc). ID phiên bản NAPI sẽ được gán theo cách ngược lại
thứ tự hơn ID tiến trình của các luồng nhân.

Threaded NAPI được điều khiển bằng cách ghi 0/1 vào tệp ZZ0000ZZ trong
thư mục sysfs của netdev. Nó cũng có thể được kích hoạt cho một NAPI cụ thể bằng cách sử dụng
giao diện liên kết mạng.

Ví dụ: sử dụng tập lệnh:

.. code-block:: bash

  $ ynl --family netdev --do napi-set --json='{"id": 66, "threaded": 1}'

.. rubric:: Footnotes

.. [#] NAPI was originally referred to as New API in 2.4 Linux.