.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/surface_aggregator/client.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. |ssam_controller| replace:: :c:type:`struct ssam_controller <ssam_controller>`
.. |ssam_device| replace:: :c:type:`struct ssam_device <ssam_device>`
.. |ssam_device_driver| replace:: :c:type:`struct ssam_device_driver <ssam_device_driver>`
.. |ssam_client_bind| replace:: :c:func:`ssam_client_bind`
.. |ssam_client_link| replace:: :c:func:`ssam_client_link`
.. |ssam_get_controller| replace:: :c:func:`ssam_get_controller`
.. |ssam_controller_get| replace:: :c:func:`ssam_controller_get`
.. |ssam_controller_put| replace:: :c:func:`ssam_controller_put`
.. |ssam_device_alloc| replace:: :c:func:`ssam_device_alloc`
.. |ssam_device_add| replace:: :c:func:`ssam_device_add`
.. |ssam_device_remove| replace:: :c:func:`ssam_device_remove`
.. |ssam_device_driver_register| replace:: :c:func:`ssam_device_driver_register`
.. |ssam_device_driver_unregister| replace:: :c:func:`ssam_device_driver_unregister`
.. |module_ssam_device_driver| replace:: :c:func:`module_ssam_device_driver`
.. |SSAM_DEVICE| replace:: :c:func:`SSAM_DEVICE`
.. |ssam_notifier_register| replace:: :c:func:`ssam_notifier_register`
.. |ssam_notifier_unregister| replace:: :c:func:`ssam_notifier_unregister`
.. |ssam_device_notifier_register| replace:: :c:func:`ssam_device_notifier_register`
.. |ssam_device_notifier_unregister| replace:: :c:func:`ssam_device_notifier_unregister`
.. |ssam_request_do_sync| replace:: :c:func:`ssam_request_do_sync`
.. |ssam_event_mask| replace:: :c:type:`enum ssam_event_mask <ssam_event_mask>`


===============================
Viết trình điều khiển máy khách
===============================

Để biết tài liệu về API, hãy tham khảo:

.. toctree::
   :maxdepth: 2

   client-api


Tổng quan
========

Trình điều khiển máy khách có thể được thiết lập theo hai cách chính, tùy thuộc vào cách
thiết bị tương ứng được cung cấp cho hệ thống. Chúng tôi đặc biệt
phân biệt giữa các thiết bị được đưa vào hệ thống thông qua một trong các
những cách thông thường, ví dụ: như các thiết bị nền tảng thông qua ACPI và các thiết bị
không thể khám phá được và thay vào đó cần được cung cấp rõ ràng bởi một số
cơ chế khác, như được thảo luận thêm dưới đây.


Trình điều khiển máy khách không phải SSAM
=======================

Mọi giao tiếp với SAM EC được xử lý thông qua ZZ0000ZZ
đại diện cho EC đó cho kernel. Trình điều khiển nhắm mục tiêu thiết bị không phải SSAM (và
do đó không phải là ZZ0001ZZ) cần thiết lập rõ ràng
kết nối/quan hệ với bộ điều khiển đó. Điều này có thể được thực hiện thông qua
Chức năng ZZ0002ZZ. Hàm đã nói trả về một tham chiếu đến SSAM
bộ điều khiển, nhưng quan trọng hơn là còn thiết lập liên kết thiết bị giữa
thiết bị khách và bộ điều khiển (việc này cũng có thể được thực hiện riêng biệt thông qua
ZZ0003ZZ). Điều quan trọng là phải làm điều này, vì trước hết nó đảm bảo
rằng bộ điều khiển được trả về hợp lệ để sử dụng trong trình điều khiển máy khách vì
miễn là trình điều khiển này được liên kết với thiết bị của nó, tức là trình điều khiển nhận được
không bị ràng buộc trước khi bộ điều khiển trở nên không hợp lệ và thứ hai, vì nó
đảm bảo đặt hàng tạm dừng/tiếp tục chính xác. Việc thiết lập này phải được thực hiện trong
chức năng thăm dò của trình điều khiển và có thể được sử dụng để trì hoãn việc thăm dò trong trường hợp SSAM
hệ thống con chưa sẵn sàng, ví dụ:

.. code-block:: c

   static int client_driver_probe(struct platform_device *pdev)
   {
           struct ssam_controller *ctrl;

           ctrl = ssam_client_bind(&pdev->dev);
           if (IS_ERR(ctrl))
                   return PTR_ERR(ctrl) == -ENODEV ? -EPROBE_DEFER : PTR_ERR(ctrl);

           // ...

           return 0;
   }

Bộ điều khiển có thể được lấy riêng thông qua ZZ0000ZZ và
trọn đời được đảm bảo thông qua ZZ0001ZZ và ZZ0002ZZ.
Tuy nhiên, lưu ý rằng không có chức năng nào trong số này đảm bảo rằng bộ điều khiển
sẽ không bị đóng cửa hoặc đình chỉ. Các chức năng này về cơ bản chỉ hoạt động
trên tài liệu tham khảo, tức là chỉ đảm bảo khả năng truy cập tối thiểu
mà không có bất kỳ sự đảm bảo nào về khả năng hoạt động thực tế.


Thêm thiết bị SSAM
===================

Nếu một thiết bị chưa tồn tại/chưa được cung cấp qua thông thường
nghĩa là nó phải được cung cấp dưới dạng ZZ0000ZZ thông qua thiết bị khách SSAM
trung tâm. Các thiết bị mới có thể được thêm vào trung tâm này bằng cách nhập UID của chúng vào
sổ đăng ký tương ứng. Các thiết bị SSAM cũng có thể được phân bổ thủ công thông qua
ZZ0001ZZ, sau đó chúng phải được thêm vào thông qua
ZZ0002ZZ và cuối cùng bị xóa qua ZZ0003ZZ. Bởi
mặc định, thiết bị gốc được đặt thành thiết bị điều khiển được cung cấp
để phân bổ, tuy nhiên điều này có thể được thay đổi trước khi thêm thiết bị. Lưu ý
rằng, khi thay đổi thiết bị gốc, phải cẩn thận để đảm bảo rằng
tuổi thọ của bộ điều khiển và tạm dừng/tiếp tục đảm bảo đặt hàng, theo mặc định
thiết lập được cung cấp thông qua mối quan hệ cha-con sẽ được giữ nguyên. Nếu
cần thiết, bằng cách sử dụng ZZ0004ZZ như được thực hiện cho máy khách không phải SSAM
trình điều khiển và được mô tả chi tiết hơn ở trên.

Thiết bị khách phải luôn được xóa bởi bên đã thêm thiết bị đó.
thiết bị tương ứng trước khi bộ điều khiển tắt. Việc loại bỏ như vậy có thể
được đảm bảo bằng cách liên kết trình điều khiển cung cấp thiết bị SSAM với bộ điều khiển
thông qua ZZ0000ZZ, khiến nó không được liên kết trước trình điều khiển bộ điều khiển
cởi trói. Các thiết bị khách được đăng ký với bộ điều khiển là thiết bị gốc
tự động bị xóa khi bộ điều khiển tắt, nhưng điều này không nên
được dựa vào, đặc biệt là vì điều này không áp dụng cho các thiết bị khách có
cha mẹ khác nhau.


Trình điều khiển máy khách SSAM
===================

Trình điều khiển thiết bị máy khách SSAM về bản chất không khác gì các thiết bị khác
các loại trình điều khiển. Chúng được biểu diễn thông qua ZZ0002ZZ và liên kết với một
ZZ0003ZZ thông qua UID (ZZ0000ZZ) của nó
thành viên và bảng trận đấu
(ZZ0001ZZ),
nên được đặt khi khai báo phiên bản cấu trúc trình điều khiển. Tham khảo
Tài liệu macro ZZ0004ZZ để biết thêm chi tiết về cách xác định thành viên
của bảng đấu của tay đua.

UID dành cho thiết bị khách SSAM bao gồm ZZ0002ZZ, ZZ0003ZZ,
ZZ0004ZZ, ZZ0005ZZ và ZZ0006ZZ. ZZ0007ZZ được sử dụng
phân biệt giữa các thiết bị SAM vật lý
(ZZ0000ZZ), tức là các thiết bị có thể
được truy cập thông qua Surface Serial Hub và các cổng ảo
(ZZ0001ZZ), chẳng hạn như thiết bị khách
các trung tâm không có đại diện thực sự trên SAM EC và chỉ được sử dụng trên
hạt nhân/phía trình điều khiển. Đối với các thiết bị vật lý, ZZ0008ZZ đại diện cho
danh mục mục tiêu, ZZ0009ZZ ID mục tiêu và ZZ0010ZZ ID phiên bản
được sử dụng để truy cập thiết bị SAM vật lý. Ngoài ra, tài liệu tham khảo ZZ0011ZZ
một chức năng cụ thể của thiết bị nhưng không có ý nghĩa gì đối với SAM EC. các
(mặc định) tên của thiết bị khách được tạo dựa trên UID của nó.

Một phiên bản trình điều khiển có thể được đăng ký qua ZZ0000ZZ và
chưa đăng ký qua ZZ0001ZZ. Để thuận tiện,
Macro ZZ0002ZZ có thể được sử dụng để xác định mô-đun init- và
chức năng thoát đăng ký trình điều khiển.

Bộ điều khiển được liên kết với thiết bị khách SSAM có thể được tìm thấy trong
Thành viên ZZ0000ZZ. Tài liệu tham khảo này là
được đảm bảo có hiệu lực ít nhất trong thời gian trình điều khiển máy khách bị ràng buộc,
nhưng cũng phải có hiệu lực trong thời gian thiết bị khách tồn tại. Lưu ý,
tuy nhiên, quyền truy cập bên ngoài trình điều khiển máy khách bị ràng buộc phải đảm bảo rằng
thiết bị điều khiển không bị treo trong khi thực hiện bất kỳ yêu cầu hoặc
(bỏ) đăng ký thông báo sự kiện (và do đó thường nên tránh). Cái này
được đảm bảo khi bộ điều khiển được truy cập từ bên trong máy khách bị ràng buộc
người lái xe.


Thực hiện các yêu cầu đồng bộ
===========================

Các yêu cầu đồng bộ (hiện tại) là hình thức chính do máy chủ khởi tạo
liên lạc với EC. Có một số cách để xác định và thực hiện
tuy nhiên, những yêu cầu như vậy hầu hết đều có nội dung tương tự như được hiển thị
trong ví dụ dưới đây. Ví dụ này định nghĩa một yêu cầu ghi-đọc, nghĩa là
rằng người gọi cung cấp một đối số cho SAM EC và nhận được phản hồi.
Người gọi cần biết độ dài (tối đa) của tải trọng phản hồi và
cung cấp một bộ đệm cho nó.

Phải cẩn thận để đảm bảo rằng mọi dữ liệu tải trọng lệnh được truyền tới SAM
EC được cung cấp ở định dạng little-endian và tương tự, bất kỳ tải trọng phản hồi nào
dữ liệu nhận được từ nó được chuyển đổi từ endian nhỏ sang endian chủ.

.. code-block:: c

   int perform_request(struct ssam_controller *ctrl, u32 arg, u32 *ret)
   {
           struct ssam_request rqst;
           struct ssam_response resp;
           int status;

           /* Convert request argument to little-endian. */
           __le32 arg_le = cpu_to_le32(arg);
           __le32 ret_le = cpu_to_le32(0);

           /*
            * Initialize request specification. Replace this with your values.
            * The rqst.payload field may be NULL if rqst.length is zero,
            * indicating that the request does not have any argument.
            *
            * Note: The request parameters used here are not valid, i.e.
            *       they do not correspond to an actual SAM/EC request.
            */
           rqst.target_category = SSAM_SSH_TC_SAM;
           rqst.target_id = SSAM_SSH_TID_SAM;
           rqst.command_id = 0x02;
           rqst.instance_id = 0x03;
           rqst.flags = SSAM_REQUEST_HAS_RESPONSE;
           rqst.length = sizeof(arg_le);
           rqst.payload = (u8 *)&arg_le;

           /* Initialize request response. */
           resp.capacity = sizeof(ret_le);
           resp.length = 0;
           resp.pointer = (u8 *)&ret_le;

           /*
            * Perform actual request. The response pointer may be null in case
            * the request does not have any response. This must be consistent
            * with the SSAM_REQUEST_HAS_RESPONSE flag set in the specification
            * above.
            */
           status = ssam_request_do_sync(ctrl, &rqst, &resp);

           /*
            * Alternatively use
            *
            *   ssam_request_do_sync_onstack(ctrl, &rqst, &resp, sizeof(arg_le));
            *
            * to perform the request, allocating the message buffer directly
            * on the stack as opposed to allocation via kzalloc().
            */

           /*
            * Convert request response back to native format. Note that in the
            * error case, this value is not touched by the SSAM core, i.e.
            * 'ret_le' will be zero as specified in its initialization.
            */
           *ret = le32_to_cpu(ret_le);

           return status;
   }

Lưu ý rằng ZZ0000ZZ về bản chất là một trình bao bọc cho các cấp độ thấp hơn.
yêu cầu nguyên thủy, cũng có thể được sử dụng để thực hiện các yêu cầu. Tham khảo nó
thực hiện và tài liệu để biết thêm chi tiết.

Một cách được cho là thân thiện hơn với người dùng để xác định các hàm như vậy là sử dụng
một trong các macro của trình tạo, ví dụ: thông qua:

.. code-block:: c

   SSAM_DEFINE_SYNC_REQUEST_W(__ssam_tmp_perf_mode_set, __le32, {
           .target_category = SSAM_SSH_TC_TMP,
           .target_id       = SSAM_SSH_TID_SAM,
           .command_id      = 0x03,
           .instance_id     = 0x00,
   });

Ví dụ này định nghĩa một hàm

.. code-block:: c

   static int __ssam_tmp_perf_mode_set(struct ssam_controller *ctrl, const __le32 *arg);

thực hiện yêu cầu đã chỉ định, với bộ điều khiển được truyền vào khi gọi
chức năng đã nói. Trong ví dụ này, đối số được cung cấp thông qua ZZ0000ZZ
con trỏ. Lưu ý rằng hàm được tạo sẽ phân bổ bộ đệm tin nhắn trên
ngăn xếp. Vì vậy, nếu đối số được cung cấp qua yêu cầu lớn, thì những đối số này
nên tránh các loại macro. Cũng lưu ý rằng, trái ngược với
ví dụ không phải macro trước đó, hàm này không thực hiện bất kỳ độ bền nào
chuyển đổi, việc này phải được xử lý bởi người gọi. Ngoài những cái đó
sự khác biệt, hàm do macro tạo ra tương tự như hàm
được cung cấp trong ví dụ phi macro ở trên.

Danh sách đầy đủ các macro tạo chức năng như vậy là

- ZZ0000ZZ cho các yêu cầu không có giá trị trả về và
  không cần tranh cãi.
- ZZ0001ZZ cho các yêu cầu có giá trị trả về nhưng không có
  lý lẽ.
- ZZ0002ZZ cho các yêu cầu không có giá trị trả về nhưng
  với lập luận.

Tham khảo tài liệu tương ứng của họ để biết thêm chi tiết. Đối với mỗi một
các macro này, một biến thể đặc biệt được cung cấp, nhắm mục tiêu các loại yêu cầu
áp dụng cho nhiều phiên bản của cùng một loại thiết bị:

-ZZ0000ZZ
-ZZ0001ZZ
-ZZ0002ZZ

Sự khác biệt của các macro đó với các phiên bản đã đề cập trước đó là ở chỗ
ID mục tiêu và ID phiên bản của thiết bị không cố định cho chức năng được tạo,
nhưng thay vào đó phải được cung cấp bởi người gọi hàm nói trên.

Ngoài ra, các biến thể để sử dụng trực tiếp với thiết bị khách, tức là.
ZZ0000ZZ, cũng được cung cấp. Ví dụ, chúng có thể được sử dụng như
sau:

.. code-block:: c

   SSAM_DEFINE_SYNC_REQUEST_CL_R(ssam_bat_get_sta, __le32, {
           .target_category = SSAM_SSH_TC_BAT,
           .command_id      = 0x01,
   });

Lệnh gọi macro này định nghĩa một hàm

.. code-block:: c

   static int ssam_bat_get_sta(struct ssam_device *sdev, __le32 *ret);

thực hiện yêu cầu đã chỉ định, sử dụng ID thiết bị và bộ điều khiển được cung cấp
trong thiết bị khách hàng. Danh sách đầy đủ các macro như vậy cho thiết bị khách là:

-ZZ0000ZZ
-ZZ0001ZZ
-ZZ0002ZZ


Xử lý sự kiện
===============

Để nhận các sự kiện từ SAM EC, bạn phải đăng ký trình thông báo sự kiện cho
sự kiện mong muốn thông qua ZZ0000ZZ. Người thông báo phải
chưa được đăng ký qua ZZ0001ZZ một khi không cần thiết
nhiều hơn nữa. Đối với các máy khách loại ZZ0002ZZ, ZZ0003ZZ và
Nên ưu tiên sử dụng trình bao bọc ZZ0004ZZ vì chúng phù hợp
xử lý việc loại bỏ nóng các thiết bị khách.

Trình thông báo sự kiện được đăng ký bằng cách cung cấp (tối thiểu) lệnh gọi lại để gọi
trong trường hợp một sự kiện đã được nhận, cơ quan đăng ký sẽ chỉ định cách thức sự kiện đó xảy ra.
phải được bật, ID sự kiện chỉ định danh mục mục tiêu và,
tùy chọn và tùy thuộc vào sổ đăng ký được sử dụng, đối với sự kiện ID phiên bản nào
phải được bật và cuối cùng, các cờ mô tả cách EC sẽ gửi những thông tin này
sự kiện. Nếu sổ đăng ký cụ thể không kích hoạt các sự kiện theo ID phiên bản, thì
ID phiên bản phải được đặt thành 0. Ngoài ra, ưu tiên cho các lĩnh vực tương ứng
trình thông báo có thể được chỉ định, xác định thứ tự của nó liên quan đến bất kỳ
trình thông báo khác đã đăng ký cho cùng loại mục tiêu.

Theo mặc định, người thông báo sự kiện sẽ nhận được tất cả các sự kiện cho mục tiêu cụ thể
danh mục, bất kể ID phiên bản được chỉ định khi đăng ký
người thông báo. Phần lõi có thể được hướng dẫn chỉ gọi trình thông báo nếu mục tiêu
ID hoặc ID phiên bản (hoặc cả hai) của sự kiện khớp với ID được ngụ ý trong
ID thông báo (trong trường hợp ID mục tiêu, ID mục tiêu của sổ đăng ký), bởi
cung cấp mặt nạ sự kiện (xem ZZ0000ZZ).

Nói chung, ID đích của sổ đăng ký cũng là ID đích của
sự kiện được bật (với ngoại lệ đáng chú ý là sự kiện nhập bàn phím trên
Surface Laptop 1 và 2, được kích hoạt thông qua sổ đăng ký có ID mục tiêu 1,
nhưng cung cấp các sự kiện có ID mục tiêu 2).

Một ví dụ đầy đủ về việc đăng ký trình thông báo sự kiện và xử lý nhận được
sự kiện được cung cấp dưới đây:

.. code-block:: c

   u32 notifier_callback(struct ssam_event_notifier *nf,
                         const struct ssam_event *event)
   {
           int status = ...

           /* Handle the event here ... */

           /* Convert return value and indicate that we handled the event. */
           return ssam_notifier_from_errno(status) | SSAM_NOTIF_HANDLED;
   }

   int setup_notifier(struct ssam_device *sdev,
                      struct ssam_event_notifier *nf)
   {
           /* Set priority wrt. other handlers of same target category. */
           nf->base.priority = 1;

           /* Set event/notifier callback. */
           nf->base.fn = notifier_callback;

           /* Specify event registry, i.e. how events get enabled/disabled. */
           nf->event.reg = SSAM_EVENT_REGISTRY_KIP;

           /* Specify which event to enable/disable */
           nf->event.id.target_category = sdev->uid.category;
           nf->event.id.instance = sdev->uid.instance;

           /*
            * Specify for which events the notifier callback gets executed.
            * This essentially tells the core if it can skip notifiers that
            * don't have target or instance IDs matching those of the event.
            */
           nf->event.mask = SSAM_EVENT_MASK_STRICT;

           /* Specify event flags. */
           nf->event.flags = SSAM_EVENT_SEQUENCED;

           return ssam_notifier_register(sdev->ctrl, nf);
   }

Nhiều trình thông báo sự kiện có thể được đăng ký cho cùng một sự kiện. Sự kiện
lõi xử lý đảm nhiệm việc kích hoạt và vô hiệu hóa các sự kiện khi trình thông báo
đã đăng ký và chưa đăng ký, bằng cách theo dõi có bao nhiêu người thông báo cho một
sự kiện cụ thể (sự kết hợp của sổ đăng ký, danh mục mục tiêu sự kiện và sự kiện
ID phiên bản) hiện đã được đăng ký. Điều này có nghĩa là một sự kiện cụ thể sẽ
được kích hoạt khi thông báo đầu tiên cho nó đang được đăng ký và vô hiệu hóa
khi người thông báo cuối cùng cho nó chưa được đăng ký. Lưu ý rằng sự kiện
do đó, cờ chỉ được sử dụng trên trình thông báo đã đăng ký đầu tiên, tuy nhiên, một
nên lưu ý rằng người thông báo cho một sự kiện cụ thể luôn được đăng ký
có cùng một cờ và nó được coi là một lỗi nếu làm khác đi.