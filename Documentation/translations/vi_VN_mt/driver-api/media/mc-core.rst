.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/mc-core.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Thiết bị điều khiển phương tiện
------------------------

Bộ điều khiển phương tiện
~~~~~~~~~~~~~~~~

Không gian người dùng bộ điều khiển phương tiện API được ghi lại trong
ZZ0000ZZ. Tài liệu này tập trung
về việc triển khai phía hạt nhân của khung truyền thông.

Mô hình thiết bị truyền thông trừu tượng
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Khám phá cấu trúc liên kết bên trong thiết bị và định cấu hình nó khi chạy là một trong những
mục tiêu của khuôn khổ truyền thông. Để đạt được điều này, các thiết bị phần cứng
được mô hình hóa dưới dạng biểu đồ định hướng của các khối xây dựng được gọi là các thực thể được kết nối
thông qua các miếng đệm.

Một thực thể là một khối xây dựng phần cứng phương tiện truyền thông cơ bản. Nó có thể tương ứng với
một lượng lớn các khối logic như các thiết bị phần cứng vật lý
(ví dụ: cảm biến CMOS), thiết bị phần cứng logic (khối xây dựng
trong đường dẫn xử lý hình ảnh Hệ thống trên Chip), các kênh DMA hoặc vật lý
đầu nối.

Một phần đệm là điểm cuối kết nối mà qua đó một thực thể có thể tương tác với
các thực thể khác. Dữ liệu (không giới hạn ở video) do một thực thể tạo ra
chuyển từ đầu ra của thực thể đến một hoặc nhiều đầu vào của thực thể. Miếng đệm nên
không bị nhầm lẫn với các chân vật lý ở ranh giới chip.

Một liên kết là một kết nối định hướng điểm-điểm giữa hai miếng đệm, hoặc
trên cùng một thực thể hoặc trên các thực thể khác nhau. Luồng dữ liệu từ một nguồn
đệm vào một miếng đệm bồn rửa.

Thiết bị truyền thông
^^^^^^^^^^^^

Một thiết bị đa phương tiện được đại diện bởi một cấu trúc media_device
dụ, được xác định trong ZZ0001ZZ.
Việc phân bổ cấu trúc được xử lý bởi trình điều khiển thiết bị đa phương tiện, thường là bởi
nhúng phiên bản ZZ0000ZZ vào một phiên bản dành riêng cho trình điều khiển lớn hơn
cấu trúc.

Trình điều khiển khởi tạo phiên bản thiết bị đa phương tiện bằng cách gọi
ZZ0000ZZ. Sau khi khởi tạo một phiên bản thiết bị đa phương tiện, nó được
đã đăng ký bằng cách gọi ZZ0001ZZ qua macro
ZZ0004ZZ và chưa đăng ký bằng cách gọi
ZZ0002ZZ. Một thiết bị đa phương tiện được khởi tạo phải
cuối cùng đã dọn sạch bằng cách gọi ZZ0003ZZ.

Lưu ý rằng không được phép hủy đăng ký phiên bản thiết bị đa phương tiện không được
đã đăng ký trước đó hoặc dọn sạch phiên bản thiết bị đa phương tiện chưa được
được khởi tạo trước đó.

Thực thể
^^^^^^^^

Các thực thể được đại diện bởi một cấu trúc media_entity
dụ, được định nghĩa trong ZZ0002ZZ. Cấu trúc thường là
được nhúng vào một cấu trúc cấp cao hơn, chẳng hạn như
ZZ0000ZZ hoặc ZZ0001ZZ
các trường hợp, mặc dù trình điều khiển có thể phân bổ các thực thể trực tiếp.

Trình điều khiển khởi tạo các miếng thực thể bằng cách gọi
ZZ0000ZZ.

Trình điều khiển đăng ký thực thể với thiết bị đa phương tiện bằng cách gọi
ZZ0000ZZ
và hủy đăng ký bằng cách gọi
ZZ0001ZZ.

Giao diện
^^^^^^^^^^

Các giao diện được thể hiện bằng một
cá thể struct media_interface, được định nghĩa trong
ZZ0000ZZ. Hiện nay chỉ có một loại giao diện
được định nghĩa: một nút thiết bị. Các giao diện như vậy được thể hiện bằng một
cấu trúc media_intf_devnode.

Trình điều khiển khởi tạo và tạo giao diện nút thiết bị bằng cách gọi
ZZ0000ZZ
và loại bỏ chúng bằng cách gọi:
ZZ0001ZZ.

Miếng đệm
^^^^
Các miếng đệm được biểu diễn bằng một thể hiện struct media_pad,
được xác định trong ZZ0000ZZ. Mỗi thực thể lưu trữ các miếng đệm của nó trong
một mảng miếng đệm được quản lý bởi trình điều khiển thực thể. Trình điều khiển thường nhúng mảng vào
một cấu trúc dành riêng cho trình điều khiển.

Các miếng đệm được xác định bởi thực thể của chúng và chỉ số dựa trên 0 của chúng trong các miếng đệm
mảng.

Cả hai thông tin đều được lưu trữ trong struct media_pad,
tạo con trỏ struct media_pad theo cách chuẩn
để lưu trữ và chuyển các tham chiếu liên kết.

Các miếng đệm có các cờ mô tả khả năng và trạng thái của miếng đệm.

ZZ0000ZZ chỉ ra rằng bảng hỗ trợ dữ liệu chìm.
ZZ0001ZZ chỉ ra rằng bảng hỗ trợ tìm nguồn dữ liệu.

.. note::

  One and only one of ``MEDIA_PAD_FL_SINK`` or ``MEDIA_PAD_FL_SOURCE`` must
  be set for each pad.

Liên kết
^^^^^

Các liên kết được thể hiện bằng một thể hiện struct media_link,
được xác định trong ZZ0000ZZ. Có hai loại liên kết:

ZZ0000ZZ:

Liên kết hai thực thể thông qua PAD của chúng. Mỗi thực thể có một danh sách trỏ
tới tất cả các liên kết bắt nguồn từ hoặc nhắm mục tiêu đến bất kỳ phần đệm nào của nó.
Do đó, một liên kết nhất định sẽ được lưu trữ hai lần, một lần trong thực thể nguồn và một lần trong
thực thể mục tiêu.

Trình điều khiển tạo liên kết pad to pad bằng cách gọi:
ZZ0000ZZ và loại bỏ bằng
ZZ0001ZZ.

ZZ0000ZZ:

Liên kết một giao diện với một Liên kết.

Trình điều khiển tạo giao diện cho các liên kết thực thể bằng cách gọi:
ZZ0000ZZ và loại bỏ bằng
ZZ0001ZZ.

.. note::

   Links can only be created after having both ends already created.

Các liên kết có các cờ mô tả khả năng và trạng thái của liên kết. các
các giá trị hợp lệ được mô tả tại ZZ0000ZZ và
ZZ0001ZZ.

Truyền tải đồ thị
^^^^^^^^^^^^^^^

Khung phương tiện cung cấp các API để duyệt qua các biểu đồ phương tiện, định vị các kết nối
thực thể và liên kết.

Để lặp lại tất cả các thực thể thuộc một thiết bị đa phương tiện, trình điều khiển có thể sử dụng
macro media_device_for_each_entity, được xác định trong
ZZ0000ZZ.

..  code-block:: c

    struct media_entity *entity;

    media_device_for_each_entity(entity, mdev) {
    // entity will point to each entity in turn
    ...
    }

Các hàm trợ giúp có thể được sử dụng để tìm liên kết giữa hai miếng đệm nhất định hoặc một miếng đệm
được kết nối với một bảng khác thông qua liên kết được kích hoạt
(ZZ0000ZZ, ZZ0001ZZ,
ZZ0002ZZ và
ZZ0003ZZ).

Sử dụng số lượng và xử lý sức mạnh
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Do sự khác biệt lớn giữa các trình điều khiển về quản lý năng lượng
nhu cầu, bộ điều khiển phương tiện không thực hiện quản lý nguồn điện. Tuy nhiên,
cấu trúc media_entity bao gồm ZZ0000ZZ
lĩnh vực mà trình điều khiển phương tiện truyền thông
có thể sử dụng để theo dõi số lượng người dùng của mọi thực thể để quản lý năng lượng
nhu cầu.

Trường ZZ0000ZZ.\ ZZ0002ZZ được sở hữu bởi
trình điều khiển phương tiện và không được
được chạm bởi trình điều khiển thực thể. Quyền truy cập vào trường phải được bảo vệ bởi
Khóa ZZ0001ZZ.\ ZZ0003ZZ.

Thiết lập liên kết
^^^^^^^^^^^

Thuộc tính liên kết có thể được sửa đổi trong thời gian chạy bằng cách gọi
ZZ0000ZZ.

Đường ống và luồng truyền thông
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Luồng phương tiện là luồng pixel hoặc siêu dữ liệu có nguồn gốc từ một hoặc nhiều
các thiết bị nguồn (chẳng hạn như cảm biến) và truyền qua các miếng đệm thực thể phương tiện
về phía bồn rửa cuối cùng. Luồng có thể được sửa đổi trên tuyến bởi
thiết bị (ví dụ: chuyển đổi tỷ lệ hoặc định dạng pixel) hoặc có thể được chia thành
nhiều nhánh hoặc nhiều nhánh có thể được hợp nhất.

Đường dẫn truyền thông là một tập hợp các luồng truyền thông phụ thuộc lẫn nhau. Cái này
sự phụ thuộc lẫn nhau có thể do phần cứng gây ra (ví dụ: cấu hình của thiết bị thứ hai
luồng không thể thay đổi nếu luồng đầu tiên đã được bật) hoặc bởi trình điều khiển
do thiết kế phần mềm. Thông thường nhất một đường dẫn truyền thông bao gồm một
luồng không phân nhánh.

Khi bắt đầu phát trực tuyến, trình điều khiển phải thông báo cho tất cả các thực thể trong quy trình để
ngăn trạng thái liên kết bị sửa đổi trong quá trình phát trực tuyến bằng cách gọi
ZZ0000ZZ.

Hàm này sẽ đánh dấu tất cả các phần đệm là một phần của đường ống là phát trực tuyến.

Phiên bản struct media_pipeline được đối số pipe trỏ đến sẽ là
được lưu trữ trong mỗi miếng đệm trong đường ống. Trình điều khiển nên nhúng cấu trúc
media_pipeline trong cấu trúc đường ống cấp cao hơn và sau đó có thể truy cập
đường ống thông qua trường ống struct media_pad.

Các cuộc gọi đến ZZ0000ZZ có thể được lồng vào nhau.
Con trỏ đường dẫn phải giống hệt nhau đối với tất cả các lệnh gọi hàm lồng nhau.

ZZ0000ZZ có thể trả về lỗi. Trong trường hợp đó,
nó sẽ tự xóa mọi thay đổi mà nó đã thực hiện.

Khi dừng luồng, tài xế phải thông báo cho các đơn vị bằng
ZZ0000ZZ.

Nếu có nhiều cuộc gọi tới ZZ0000ZZ
đã thực hiện cùng số lượng cuộc gọi ZZ0001ZZ
được yêu cầu ngừng phát trực tuyến.
Trường ZZ0002ZZ.\ ZZ0003ZZ được đặt lại thành ZZ0004ZZ vào lần cuối
lệnh dừng lồng nhau.

Cấu hình liên kết sẽ không thành công với ZZ0000ZZ theo mặc định nếu một trong hai đầu của
liên kết là một thực thể phát trực tuyến. Các liên kết có thể được sửa đổi trong khi phát trực tuyến phải
được đánh dấu bằng cờ ZZ0001ZZ.

Nếu các hoạt động khác cần không được phép trên các thực thể phát trực tuyến (chẳng hạn như
thay đổi các tham số cấu hình thực thể) trình điều khiển có thể kiểm tra rõ ràng
trường media_entity streaming_count để tìm hiểu xem một thực thể có đang phát trực tuyến hay không. Cái này
thao tác phải được thực hiện với media_device graph_mutex được giữ.

Xác thực liên kết
^^^^^^^^^^^^^^^

Xác thực liên kết được thực hiện bởi ZZ0000ZZ
đối với bất kỳ thực thể nào có miếng đệm chìm trong đường ống. các
Gọi lại ZZ0001ZZ.\ ZZ0002ZZ được sử dụng cho việc đó
mục đích. Trong cuộc gọi lại ZZ0003ZZ, trình điều khiển thực thể nên kiểm tra
rằng các thuộc tính của vùng đệm nguồn của thực thể được kết nối và của chính nó
phù hợp với miếng đệm bồn rửa. Điều này tùy thuộc vào loại thực thể (và cuối cùng,
thuộc tính của phần cứng) việc so khớp thực sự có ý nghĩa gì.

Các hệ thống con nên tạo điều kiện thuận lợi cho việc xác thực liên kết bằng cách cung cấp thông tin cụ thể về hệ thống con
chức năng trợ giúp để cung cấp khả năng truy cập dễ dàng cho các thông tin thường cần và
cuối cùng cung cấp cách sử dụng lệnh gọi lại dành riêng cho trình điều khiển.

Truyền tải đường ống
^^^^^^^^^^^^^^^^^^

Khi một đường ống đã được xây dựng bằng ZZ0000ZZ,
trình điều khiển có thể lặp lại các thực thể hoặc phần đệm trong quy trình bằng
:c:macro:'media_pipeline_for_each_entity` and
:c:macro:´media_pipeline_for_each_pad` macro. Lặp lại trên các miếng đệm là
đơn giản:

.. code-block:: c

   media_pipeline_pad_iter iter;
   struct media_pad *pad;

   media_pipeline_for_each_pad(pipe, &iter, pad) {
       /* 'pad' will point to each pad in turn */
       ...
   }

Để lặp qua các thực thể, trình vòng lặp cần được khởi tạo và dọn dẹp
như một bước bổ sung:

.. code-block:: c

   media_pipeline_entity_iter iter;
   struct media_entity *entity;
   int ret;

   ret = media_pipeline_entity_iter_init(pipe, &iter);
   if (ret)
       ...;

   media_pipeline_for_each_entity(pipe, &iter, entity) {
       /* 'entity' will point to each entity in turn */
       ...
   }

   media_pipeline_entity_iter_cleanup(&iter);

Bộ phân bổ thiết bị điều khiển phương tiện API
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Khi thiết bị đa phương tiện thuộc về nhiều trình điều khiển, phương tiện được chia sẻ
thiết bị được phân bổ với thiết bị cấu trúc dùng chung làm chìa khóa để tra cứu.

Thiết bị đa phương tiện dùng chung phải ở trạng thái đã đăng ký cho đến lần cuối cùng
trình điều khiển hủy đăng ký nó. Ngoài ra, thiết bị đa phương tiện nên được giải phóng khi
tất cả các tài liệu tham khảo được phát hành. Mỗi trình điều khiển được tham chiếu đến phương tiện truyền thông
thiết bị trong quá trình thăm dò, khi nó phân bổ thiết bị đa phương tiện. Nếu thiết bị đa phương tiện được
đã được phân bổ, API phân bổ sẽ tăng số tiền hoàn lại và trả về
thiết bị truyền thông hiện có. Trình điều khiển đưa tham chiếu trở lại trạng thái ngắt kết nối
thường lệ khi nó gọi ZZ0000ZZ.

Thiết bị đa phương tiện chưa được đăng ký và được dọn sạch từ trình xử lý đặt kref sang
đảm bảo rằng thiết bị đa phương tiện vẫn ở trạng thái đã đăng ký cho đến trình điều khiển cuối cùng
hủy đăng ký thiết bị đa phương tiện.

ZZ0000ZZ

Trình điều khiển nên sử dụng các quy trình truyền thông lõi thích hợp để quản lý dữ liệu được chia sẻ
thời gian sử dụng của thiết bị đa phương tiện xử lý hai trạng thái:
1. phân bổ -> đăng ký -> xóa
2. lấy tham chiếu đến thiết bị đã đăng ký -> xóa

gọi thủ tục ZZ0000ZZ để đảm bảo phương tiện được chia sẻ
xóa thiết bị được xử lý chính xác.

ZZ0002ZZ
Gọi ZZ0000ZZ để phân bổ hoặc nhận tài liệu tham khảo
Gọi ZZ0001ZZ, nếu media devnode chưa được đăng ký

ZZ0001ZZ
Gọi ZZ0000ZZ để giải phóng media_device. Giải phóng là
được xử lý bởi trình xử lý kref put.

Định nghĩa API
^^^^^^^^^^^^^^^

.. kernel-doc:: include/media/media-device.h

.. kernel-doc:: include/media/media-devnode.h

.. kernel-doc:: include/media/media-entity.h

.. kernel-doc:: include/media/media-request.h

.. kernel-doc:: include/media/media-dev-allocator.h