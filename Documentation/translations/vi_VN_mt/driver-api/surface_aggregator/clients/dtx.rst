.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/surface_aggregator/clients/dtx.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. |__u16| replace:: :c:type:`__u16 <__u16>`
.. |sdtx_event| replace:: :c:type:`struct sdtx_event <sdtx_event>`
.. |sdtx_event_code| replace:: :c:type:`enum sdtx_event_code <sdtx_event_code>`
.. |sdtx_base_info| replace:: :c:type:`struct sdtx_base_info <sdtx_base_info>`
.. |sdtx_device_mode| replace:: :c:type:`struct sdtx_device_mode <sdtx_device_mode>`

===========================================================
Giao diện DTX (Hệ thống tách bảng tạm) không gian người dùng
======================================================

Trình điều khiển ZZ0000ZZ chịu trách nhiệm tách clipboard thích hợp
và xử lý việc đính kèm lại. Để đạt được mục đích này, nó cung cấp ZZ0001ZZ
tệp thiết bị, qua đó nó có thể giao tiếp với daemon không gian người dùng. Cái này
daemon sau đó chịu trách nhiệm cuối cùng trong việc xác định và thực hiện các biện pháp cần thiết
các hành động, chẳng hạn như tháo các thiết bị gắn vào đế,
dỡ/tải lại trình điều khiển đồ họa, thông báo người dùng, v.v.

Có hai nguyên tắc giao tiếp cơ bản được sử dụng trong trình điều khiển này: Lệnh
(trong các phần khác của tài liệu còn được gọi là yêu cầu) và
sự kiện. Các lệnh được gửi đến EC và có thể có ý nghĩa khác trong
bối cảnh khác nhau. Các sự kiện được EC gửi theo một số trạng thái nội bộ
thay đổi. Các lệnh luôn được khởi tạo bởi trình điều khiển, trong khi các sự kiện luôn được thực hiện
do EC khởi xướng.

.. contents::

Danh pháp
============

* ZZ0000ZZ
  Phần trên có thể tháo rời của Surface Book, chứa màn hình và CPU.

* ZZ0000ZZ
  Phần dưới của Surface Book nơi có thể lấy bảng nhớ tạm
  tách rời, tùy chọn (tùy theo kiểu máy) chứa GPU (dGPU) riêng biệt.

* ZZ0000ZZ
  Cơ chế giữ clipboard gắn vào đế bình thường
  hoạt động và cho phép nó được tách ra khi được yêu cầu.

* ZZ0000ZZ
  Lệnh được EC chấp nhận là lệnh hợp lệ và được xác nhận
  (tuân theo giao thức truyền thông tiêu chuẩn), nhưng EC không hoạt động
  trên đó, tức là bỏ qua nó.e phần trên của


Quá trình tách rời
==================

Cảnh báo: Phần tài liệu này dựa trên kỹ thuật đảo ngược và
kiểm tra và do đó có thể có lỗi hoặc không đầy đủ.

Trạng thái chốt
------------

Cơ chế chốt có hai trạng thái chính: ZZ0000ZZ và ZZ0001ZZ. trong
Trạng thái ZZ0002ZZ (mặc định), bảng tạm được cố định vào đế, trong khi ở trạng thái
trạng thái ZZ0003ZZ, người dùng có thể xóa bảng nhớ tạm.

Ngoài ra, chốt có thể được khóa và mở khóa tương ứng, điều này
có thể ảnh hưởng đến quá trình tách. Cụ thể, cơ chế khóa này
nhằm ngăn chặn dGPU, được đặt ở đế của thiết bị, khỏi
bị rút phích cắm nóng trong khi sử dụng. Thông tin chi tiết có thể được tìm thấy trong
tài liệu về thủ tục tách ra dưới đây. Theo mặc định, chốt là
đã được mở khóa.

Thủ tục tách ra
--------------------

Lưu ý rằng quá trình tách ra được điều chỉnh hoàn toàn bởi EC. các
Trình điều khiển ZZ0000ZZ chỉ chuyển tiếp các sự kiện từ EC sang không gian người dùng và
các lệnh từ không gian người dùng đến EC, tức là nó không ảnh hưởng đến quá trình này.

Quá trình tách được bắt đầu bằng việc người dùng nhấn nút ZZ0001ZZ
trên đế của thiết bị hoặc thực thi ZZ0000ZZ IOCTL.
Tiếp theo đó:

1. EC bật đèn chỉ báo trên nút tháo, gửi một tín hiệu
   Sự kiện ZZ0001ZZ (ZZ0000ZZ) và đang chờ đợi thêm
   hướng dẫn/lệnh. Trong trường hợp chốt được mở khóa, đèn led sẽ nhấp nháy
   màu xanh lá cây. Nếu chốt đã bị khóa thì led sẽ có màu đỏ đặc

2. Sự kiện này, thông qua trình điều khiển ZZ0000ZZ, được chuyển tiếp đến không gian người dùng, trong đó
   một daemon không gian người dùng thích hợp có thể xử lý nó và gửi lại hướng dẫn
   tới EC thông qua IOCTL do trình điều khiển này cung cấp.

3. EC chờ hướng dẫn từ không gian người dùng và hành động theo hướng dẫn đó.
   Nếu EC không nhận được bất kỳ hướng dẫn nào trong một khoảng thời gian nhất định, nó sẽ
   hết thời gian và tiếp tục như sau:

- Nếu chốt không khóa thì EC sẽ mở chốt và clipboard
     có thể tách rời khỏi đế. Đây là hành vi chính xác như không có
     trình điều khiển này hoặc bất kỳ daemon không gian người dùng nào. Xem ZZ0000ZZ
     mô tả bên dưới để biết thêm chi tiết về hoạt động tiếp theo của EC.

- Nếu chốt bị khóa thì EC sẽ ZZ0003ZZ mở chốt, nghĩa là
     clipboard không thể tách rời khỏi đế. Hơn nữa, EC gửi
     một sự kiện hủy bỏ (ZZ0001ZZ) nêu chi tiết điều này với sự kiện hủy bỏ
     lý do ZZ0002ZZ (xem ZZ0000ZZ để biết chi tiết).

Phản hồi hợp lệ của daemon không gian người dùng đối với sự kiện yêu cầu tách là:

- Chạy ZZ0000ZZ. Điều này sẽ ngay lập tức hủy bỏ
  quá trình tách rời. Hơn nữa, EC sẽ gửi một sự kiện yêu cầu tách ra,
  tương tự như việc người dùng nhấn nút tách để hủy quá trình đã nói (xem
  bên dưới).

- Chạy ZZ0000ZZ. Điều này sẽ khiến EC mở
  chốt, sau đó người dùng có thể tách bảng tạm và đế.

Khi điều này thay đổi trạng thái chốt, một sự kiện ZZ0002ZZ
  (ZZ0000ZZ) sẽ được gửi sau khi chốt được mở
  thành công. Nếu EC không mở được chốt, ví dụ: do phần cứng
  lỗi hoặc pin yếu, sự kiện hủy chốt (ZZ0001ZZ) sẽ xảy ra
  được gửi với lý do hủy cho biết lỗi cụ thể.

Nếu chốt hiện đang bị khóa, chốt sẽ tự động được khóa.
  đã được mở khóa trước khi mở.

- Chạy ZZ0000ZZ. Điều này sẽ thiết lập lại thời gian chờ nội bộ.
  Sẽ không có hành động nào khác được thực hiện, tức là quá trình tách sẽ không
  được hoàn thành hay bị hủy bỏ và EC vẫn sẽ chờ đợi thêm
  những phản hồi.

- Thực hiện ZZ0000ZZ. Điều này sẽ hủy bỏ quá trình tách ra,
  tương tự như ZZ0001ZZ, được mô tả ở trên hoặc nút
  nhấn, được mô tả dưới đây. Sự kiện ZZ0003ZZ (ZZ0002ZZ)
  được gửi để đáp lại điều này. Tuy nhiên, trái ngược với những điều đó, lệnh này
  không kích hoạt một quy trình tách mới nếu hiện tại không có quy trình nào trong
  tiến bộ.

- Không làm gì cả. Quá trình tách cuối cùng hết thời gian như được mô tả trong
  điểm 3.

Xem ZZ0000ZZ để biết thêm chi tiết về những phản hồi này.

Điều quan trọng cần lưu ý là, nếu người dùng nhấn nút tháo bất kỳ lúc nào
điểm khi một hoạt động tách đang được tiến hành (tức là sau khi EC đã gửi
sự kiện ZZ0001ZZ ban đầu (ZZ0000ZZ) và trước đó
nhận được phản hồi tương ứng kết thúc quá trình), nhóm tách ra
quá trình bị hủy ở cấp EC và một sự kiện giống hệt đang được gửi.
Do đó, bản thân sự kiện ZZ0002ZZ không báo hiệu sự bắt đầu của
quá trình tách rời.

Quá trình tách rời có thể bị EC hủy bỏ thêm do phần cứng
lỗi hoặc pin clipboard yếu. Việc này được thực hiện thông qua sự kiện hủy
(ZZ0000ZZ) với lý do hủy tương ứng.


Tài liệu về giao diện không gian người dùng
==================================

Mã lỗi và giá trị trạng thái
-----------------------------

Mã lỗi và trạng thái được chia thành các loại khác nhau, có thể
được sử dụng để xác định xem mã trạng thái có bị lỗi hay không và nếu có thì
mức độ nghiêm trọng và loại lỗi đó. Các loại hiện tại là:

.. flat-table:: Overview of Status/Error Categories.
   :widths: 2 1 3
   :header-rows: 1

   * - Name
     - Value
     - Short Description

   * - ``STATUS``
     - ``0x0000``
     - Non-error status codes.

   * - ``RUNTIME_ERROR``
     - ``0x1000``
     - Non-critical runtime errors.

   * - ``HARDWARE_ERROR``
     - ``0x2000``
     - Critical hardware failures.

   * - ``UNKNOWN``
     - ``0xF000``
     - Unknown error codes.

Các danh mục khác được dành riêng để sử dụng trong tương lai. Macro ZZ0000ZZ
có thể được sử dụng để xác định danh mục của bất kỳ giá trị trạng thái nào. các
Macro ZZ0001ZZ có thể được sử dụng để kiểm tra xem giá trị trạng thái có phải là
giá trị thành công (ZZ0002ZZ) hoặc nếu nó báo lỗi.

Trạng thái không xác định hoặc mã lỗi do EC gửi được gán cho ZZ0000ZZ
được người lái xe phân loại và có thể được triển khai thông qua mã riêng của họ trong
tương lai.

Mã lỗi hiện đang được sử dụng là:

.. flat-table:: Overview of Error Codes.
   :widths: 2 1 1 3
   :header-rows: 1

   * - Name
     - Category
     - Value
     - Short Description

   * - ``SDTX_DETACH_NOT_FEASIBLE``
     - ``RUNTIME``
     - ``0x1001``
     - Detachment not feasible due to low clipboard battery.

   * - ``SDTX_DETACH_TIMEDOUT``
     - ``RUNTIME``
     - ``0x1002``
     - Detachment process timed out while the latch was locked.

   * - ``SDTX_ERR_FAILED_TO_OPEN``
     - ``HARDWARE``
     - ``0x2001``
     - Failed to open latch.

   * - ``SDTX_ERR_FAILED_TO_REMAIN_OPEN``
     - ``HARDWARE``
     - ``0x2002``
     - Failed to keep latch open.

   * - ``SDTX_ERR_FAILED_TO_CLOSE``
     - ``HARDWARE``
     - ``0x2003``
     - Failed to close latch.

Các mã lỗi khác được dành riêng để sử dụng trong tương lai. Mã trạng thái không có lỗi có thể
chồng chéo và thường chỉ duy nhất trong trường hợp sử dụng của chúng:

.. flat-table:: Latch Status Codes.
   :widths: 2 1 1 3
   :header-rows: 1

   * - Name
     - Category
     - Value
     - Short Description

   * - ``SDTX_LATCH_CLOSED``
     - ``STATUS``
     - ``0x0000``
     - Latch is closed/has been closed.

   * - ``SDTX_LATCH_OPENED``
     - ``STATUS``
     - ``0x0001``
     - Latch is open/has been opened.

.. flat-table:: Base State Codes.
   :widths: 2 1 1 3
   :header-rows: 1

   * - Name
     - Category
     - Value
     - Short Description

   * - ``SDTX_BASE_DETACHED``
     - ``STATUS``
     - ``0x0000``
     - Base has been detached/is not present.

   * - ``SDTX_BASE_ATTACHED``
     - ``STATUS``
     - ``0x0001``
     - Base has been attached/is present.

Một lần nữa, các mã khác được dành riêng để sử dụng trong tương lai.

.. _events:

Sự kiện
------

Sự kiện có thể được nhận bằng cách đọc từ tập tin thiết bị. Họ bị vô hiệu hóa bởi
mặc định và phải được kích hoạt bằng cách thực thi ZZ0000ZZ
đầu tiên. Tất cả các sự kiện đều tuân theo bố cục do ZZ0001ZZ quy định. Cụ thể
các loại sự kiện có thể được xác định bằng mã sự kiện của chúng, được mô tả trong
ZZ0002ZZ. Lưu ý rằng các mã sự kiện khác được dành riêng để sử dụng trong tương lai,
do đó, trình phân tích sự kiện phải có khả năng xử lý mọi sự kiện không xác định/không được hỗ trợ
các loại một cách duyên dáng, bằng cách dựa vào độ dài tải trọng được cung cấp trong tiêu đề sự kiện.

Các loại sự kiện hiện được cung cấp là:

.. flat-table:: Overview of DTX events.
   :widths: 2 1 1 3
   :header-rows: 1

   * - Name
     - Code
     - Payload
     - Short Description

   * - ``SDTX_EVENT_REQUEST``
     - ``1``
     - ``0`` bytes
     - Detachment process initiated/aborted.

   * - ``SDTX_EVENT_CANCEL``
     - ``2``
     - ``2`` bytes
     - EC canceled detachment process.

   * - ``SDTX_EVENT_BASE_CONNECTION``
     - ``3``
     - ``4`` bytes
     - Base connection state changed.

   * - ``SDTX_EVENT_LATCH_STATUS``
     - ``4``
     - ``2`` bytes
     - Latch status changed.

   * - ``SDTX_EVENT_DEVICE_MODE``
     - ``5``
     - ``2`` bytes
     - Device mode changed.

Các sự kiện riêng lẻ chi tiết hơn:

ZZ0000ZZ
^^^^^^^^^^^^^^^^^^^^^^

Được gửi khi quá trình tách được bắt đầu hoặc, nếu đang diễn ra, bị hủy bỏ bởi
người dùng, thông qua nhấn nút tách hoặc yêu cầu tách
(ZZ0000ZZ) được gửi từ không gian người dùng.

Không có bất kỳ tải trọng nào.

ZZ0000ZZ
^^^^^^^^^^^^^^^^^^^^^

Được gửi khi quá trình tách bị EC hủy do chưa được thực hiện
điều kiện tiên quyết (ví dụ: pin clipboard quá yếu để tháo ra) hoặc phần cứng
thất bại. Lý do hủy được nêu chi tiết trong phần tải trọng sự kiện
bên dưới và có thể là một trong

* ZZ0000ZZ: Đã hết thời gian tách ra khi chốt đã bị khóa.
  Chốt chưa được mở cũng như không được mở khóa.

* ZZ0000ZZ: Việc tách rời không khả thi do bảng nhớ tạm thấp
  pin.

* ZZ0000ZZ: Không mở được chốt (lỗi phần cứng).

* ZZ0000ZZ: Không thể giữ chốt mở (phần cứng
  thất bại).

* ZZ0000ZZ: Không đóng được chốt (lỗi phần cứng).

Các mã lỗi khác trong ngữ cảnh này được dành riêng để sử dụng trong tương lai.

Các mã này có thể được phân loại thông qua macro ZZ0000ZZ để phân biệt
giữa các lỗi phần cứng nghiêm trọng (ZZ0001ZZ) hoặc
lỗi thời gian chạy (ZZ0002ZZ), lỗi sau có thể
xảy ra trong quá trình hoạt động bình thường nếu có những điều kiện tiên quyết nhất định để tách rời
không được đưa ra.

.. flat-table:: Detachment Cancel Event Payload
   :widths: 1 1 4
   :header-rows: 1

   * - Field
     - Type
     - Description

   * - ``reason``
     - |__u16|
     - Reason for cancellation.

ZZ0000ZZ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Được gửi khi trạng thái kết nối cơ sở đã thay đổi, tức là khi cơ sở đã được
việc gắn, tách hoặc tách đã trở nên không khả thi do bảng nhớ tạm thấp
pin. Trạng thái mới và nếu một cơ sở được kết nối, ID của cơ sở đó là
được cung cấp dưới dạng tải trọng loại ZZ0000ZZ với bố cục được trình bày
dưới đây:

.. flat-table:: Base-Connection-Change Event Payload
   :widths: 1 1 4
   :header-rows: 1

   * - Field
     - Type
     - Description

   * - ``state``
     - |__u16|
     - Base connection state.

   * - ``base_id``
     - |__u16|
     - Type of base connected (zero if none).

Các giá trị có thể có của ZZ0000ZZ là:

* ZZ0000ZZ,
* ZZ0001ZZ, và
*ZZ0002ZZ.

Các giá trị khác được dành riêng để sử dụng trong tương lai.

ZZ0000ZZ
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Được gửi khi trạng thái chốt đã thay đổi, tức là khi chốt đã được mở,
đã đóng hoặc xảy ra lỗi. Trạng thái hiện tại được cung cấp dưới dạng tải trọng:

.. flat-table:: Latch-Status-Change Event Payload
   :widths: 1 1 4
   :header-rows: 1

   * - Field
     - Type
     - Description

   * - ``status``
     - |__u16|
     - Latch status.

Các giá trị có thể có của ZZ0000ZZ là:

* ZZ0000ZZ,
* ZZ0001ZZ,
* ZZ0002ZZ,
* ZZ0003ZZ, và
*ZZ0004ZZ.

Các giá trị khác được dành riêng để sử dụng trong tương lai.

ZZ0000ZZ
^^^^^^^^^^^^^^^^^^^^^^^^^^

Được gửi khi chế độ thiết bị đã thay đổi. Chế độ thiết bị mới được cung cấp dưới dạng
tải trọng:

.. flat-table:: Device-Mode-Change Event Payload
   :widths: 1 1 4
   :header-rows: 1

   * - Field
     - Type
     - Description

   * - ``mode``
     - |__u16|
     - Device operation mode.

Các giá trị có thể có của ZZ0000ZZ là:

* ZZ0000ZZ,
* ZZ0001ZZ, và
*ZZ0002ZZ.

Các giá trị khác được dành riêng để sử dụng trong tương lai.

.. _ioctls:

IOCTL
------

Các IOCTL sau đây được cung cấp:

.. flat-table:: Overview of DTX IOCTLs
   :widths: 1 1 1 1 4
   :header-rows: 1

   * - Type
     - Number
     - Direction
     - Name
     - Description

   * - ``0xA5``
     - ``0x21``
     - ``-``
     - ``EVENTS_ENABLE``
     - Enable events for the current file descriptor.

   * - ``0xA5``
     - ``0x22``
     - ``-``
     - ``EVENTS_DISABLE``
     - Disable events for the current file descriptor.

   * - ``0xA5``
     - ``0x23``
     - ``-``
     - ``LATCH_LOCK``
     - Lock the latch.

   * - ``0xA5``
     - ``0x24``
     - ``-``
     - ``LATCH_UNLOCK``
     - Unlock the latch.

   * - ``0xA5``
     - ``0x25``
     - ``-``
     - ``LATCH_REQUEST``
     - Request clipboard detachment.

   * - ``0xA5``
     - ``0x26``
     - ``-``
     - ``LATCH_CONFIRM``
     - Confirm clipboard detachment request.

   * - ``0xA5``
     - ``0x27``
     - ``-``
     - ``LATCH_HEARTBEAT``
     - Send heartbeat signal to EC.

   * - ``0xA5``
     - ``0x28``
     - ``-``
     - ``LATCH_CANCEL``
     - Cancel detachment process.

   * - ``0xA5``
     - ``0x29``
     - ``R``
     - ``GET_BASE_INFO``
     - Get current base/connection information.

   * - ``0xA5``
     - ``0x2A``
     - ``R``
     - ``GET_DEVICE_MODE``
     - Get current device operation mode.

   * - ``0xA5``
     - ``0x2B``
     - ``R``
     - ``GET_LATCH_STATUS``
     - Get current device latch status.

ZZ0000ZZ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Được xác định là ZZ0000ZZ.

Kích hoạt sự kiện cho bộ mô tả tệp hiện tại. Sự kiện có thể thu được bằng cách
đọc từ thiết bị, nếu được bật. Sự kiện bị tắt theo mặc định.

ZZ0000ZZ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Được xác định là ZZ0000ZZ.

Tắt các sự kiện cho bộ mô tả tệp hiện tại. Sự kiện có thể thu được bằng cách
đọc từ thiết bị, nếu được bật. Sự kiện bị tắt theo mặc định.

ZZ0000ZZ
^^^^^^^^^^^^^^^^^^^^^^^^^

Được xác định là ZZ0000ZZ.

Khóa chốt, khiến quy trình tách bị hủy bỏ mà không mở được
chốt thời gian chờ. Chốt được mở khóa theo mặc định. Lệnh này sẽ được
âm thầm bỏ qua nếu chốt đã bị khóa.

ZZ0000ZZ
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Được xác định là ZZ0000ZZ.

Mở khóa chốt, khiến quy trình tháo rời mở chốt
hết thời gian chờ. Chốt được mở khóa theo mặc định. Lệnh này sẽ không mở
chốt khi được gửi trong quá trình tách rời đang diễn ra. Sẽ âm thầm
bỏ qua nếu chốt đã được mở khóa.

ZZ0000ZZ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Được xác định là ZZ0000ZZ.

Yêu cầu chốt chung. Hành vi phụ thuộc vào ngữ cảnh: Nếu không
quá trình tách rời đang hoạt động, việc tách rời được yêu cầu. Nếu không thì
quá trình tách rời hiện đang hoạt động sẽ bị hủy bỏ.

Nếu một quá trình tách rời bị hủy bỏ bởi thao tác này, một quá trình tách rời chung
sự kiện yêu cầu (ZZ0000ZZ) sẽ được gửi.

Về cơ bản, thao tác này hoạt động giống như thao tác nhấn nút tách rời.

ZZ0000ZZ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Được xác định là ZZ0000ZZ.

Xác nhận và xác nhận yêu cầu chốt. Nếu được gửi trong thời gian liên tục
quá trình tách rời, lệnh này sẽ khiến chốt được mở ngay lập tức.
Chốt cũng sẽ được mở nếu nó đã bị khóa. Trong trường hợp này, chốt
khóa được đặt lại về trạng thái mở khóa.

Lệnh này sẽ được âm thầm bỏ qua nếu hiện tại không có đội nào
thủ tục đang được tiến hành.

ZZ0000ZZ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Được xác định là ZZ0000ZZ.

Gửi nhịp tim, về cơ bản là đặt lại thời gian chờ của nhóm. Cái này
lệnh có thể được sử dụng để duy trì quá trình tách rời trong khi công việc được yêu cầu
để biệt đội thành công vẫn đang được tiến hành.

Lệnh này sẽ được âm thầm bỏ qua nếu hiện tại không có đội nào
thủ tục đang được tiến hành.

ZZ0000ZZ
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Được xác định là ZZ0000ZZ.

Hủy quá trình tách đang diễn ra (nếu có). Nếu quá trình tách bị hủy bỏ
bởi hoạt động này, một sự kiện yêu cầu tách nhóm chung
(ZZ0000ZZ) sẽ được gửi.

Lệnh này sẽ được âm thầm bỏ qua nếu hiện tại không có đội nào
thủ tục đang được tiến hành.

ZZ0000ZZ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Được xác định là ZZ0000ZZ.

Nhận trạng thái kết nối cơ sở hiện tại (tức là đã đính kèm/tách rời) và loại
của đế được kết nối với khay nhớ tạm. Đây là lệnh về cơ bản cung cấp
một cách để truy vấn thông tin được cung cấp bởi sự kiện thay đổi kết nối cơ sở
(ZZ0000ZZ).

Các giá trị có thể có của ZZ0000ZZ là:

* ZZ0000ZZ,
* ZZ0001ZZ, và
*ZZ0002ZZ.

Các giá trị khác được dành riêng để sử dụng trong tương lai.

ZZ0000ZZ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Được xác định là ZZ0000ZZ.

Trả về chế độ hoạt động của thiết bị, cho biết cơ sở có hoạt động hay không và như thế nào
đính kèm vào clipboard. Đây là lệnh về cơ bản cung cấp một cách để
truy vấn thông tin được cung cấp bởi sự kiện thay đổi chế độ thiết bị
(ZZ0000ZZ).

Các giá trị trả về là:

* ZZ0000ZZ
* ZZ0001ZZ
* ZZ0002ZZ

Xem ZZ0000ZZ để biết chi tiết. Các giá trị khác được dành riêng cho tương lai
sử dụng.


ZZ0000ZZ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Được xác định là ZZ0000ZZ.

Nhận trạng thái chốt hiện tại hoặc (có lẽ) lỗi cuối cùng gặp phải khi
cố gắng mở/đóng chốt. Đây là lệnh về cơ bản cung cấp một cách
để truy vấn thông tin được cung cấp bởi sự kiện thay đổi trạng thái chốt
(ZZ0000ZZ).

Các giá trị trả về là:

* ZZ0000ZZ,
* ZZ0001ZZ,
* ZZ0002ZZ,
* ZZ0003ZZ, và
*ZZ0004ZZ.

Các giá trị khác được dành riêng để sử dụng trong tương lai.

Lưu ý về ID cơ sở
------------------

Loại cơ sở/ID được cung cấp qua ZZ0000ZZ hoặc
ZZ0001ZZ được chuyển tiếp trực tiếp từ EC ở cấp độ thấp hơn
byte của giá trị ZZ0002ZZ kết hợp, với trình điều khiển lưu trữ loại EC từ
ID này xuất hiện ở byte cao (không có ID này, ID cơ sở trên các byte khác nhau
các loại EC có thể chồng chéo).

Macro ZZ0000ZZ có thể được sử dụng để xác định thiết bị EC
loại. Đây có thể là một trong

* ZZ0000ZZ, dành cho Mô-đun tổng hợp bề mặt trên HID và

* ZZ0000ZZ, dành cho Mô-đun tổng hợp bề mặt qua Surface Serial
  Trung tâm.

Lưu ý rằng hiện tại chỉ hỗ trợ ZZ0000ZZ loại EC, tuy nhiên ZZ0001ZZ
loại được dành riêng để sử dụng trong tương lai.

Cấu trúc và Enum
--------------------

.. kernel-doc:: include/uapi/linux/surface_aggregator/dtx.h

Người dùng API
=========

Có thể tìm thấy daemon không gian người dùng sử dụng API này tại
ZZ0000ZZ