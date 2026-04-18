.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/block/ublk.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============================================================================
Trình điều khiển thiết bị khối không gian người dùng (trình điều khiển ublk)
============================================================================

Tổng quan
=========

ublk là một khung chung để triển khai logic thiết bị khối từ không gian người dùng.
Động lực đằng sau nó là việc di chuyển trình điều khiển khối ảo vào không gian người dùng,
chẳng hạn như loop, nbd và những thứ tương tự có thể rất hữu ích. Nó có thể giúp thực hiện
thiết bị khối ảo mới như ublk-qcow2 (có một số nỗ lực
triển khai trình điều khiển qcow2 trong kernel).

Các thiết bị chặn không gian người dùng rất hấp dẫn vì:

- Chúng có thể được viết bằng nhiều ngôn ngữ lập trình.
- Họ có thể sử dụng các thư viện không có sẵn trong kernel.
- Chúng có thể được sửa lỗi bằng các công cụ quen thuộc với các nhà phát triển ứng dụng.
- Crash kernel không làm hoảng loạn máy.
- Các lỗi có thể có tác động bảo mật thấp hơn các lỗi trong kernel
  mã.
- Chúng có thể được cài đặt và cập nhật độc lập với kernel.
- Chúng có thể được sử dụng để mô phỏng thiết bị khối một cách dễ dàng với người dùng chỉ định
  tham số/cài đặt cho mục đích kiểm tra/gỡ lỗi

thiết bị khối ublk (ZZ0000ZZ) được thêm bởi trình điều khiển ublk. Mọi yêu cầu IO
trên thiết bị sẽ được chuyển tiếp tới chương trình không gian người dùng ublk. Để thuận tiện,
trong tài liệu này, ZZ0001ZZ đề cập đến không gian người dùng ublk chung
chương trình. ZZ0002ZZ [#userspace]_ là một trong những triển khai như vậy. Nó
cung cấp thư viện ZZ0003ZZ [#userspace_lib]_ để phát triển các ứng dụng cụ thể
thiết bị chặn người dùng một cách thuận tiện, đồng thời cũng là thiết bị chặn loại chung
được bao gồm, chẳng hạn như vòng lặp và null. Richard WM Jones đã viết thiết bị nbd không gian người dùng
ZZ0004ZZ [#userspace_nbdublk]_ dựa trên ZZ0005ZZ [#userspace_lib]_.

Sau khi IO được xử lý bởi không gian người dùng, kết quả sẽ được chuyển trở lại
trình điều khiển, do đó hoàn thành chu trình yêu cầu. Bằng cách này, mọi hoạt động xử lý IO cụ thể
logic hoàn toàn được thực hiện bởi không gian người dùng, chẳng hạn như xử lý IO của vòng lặp, IO của NBD
giao tiếp hoặc ánh xạ IO của qcow2.

ZZ0000ZZ được điều khiển bởi trình điều khiển dựa trên yêu cầu blk-mq. Mỗi yêu cầu là
được gán bởi một thẻ duy nhất trên toàn hàng đợi. máy chủ ublk gán thẻ duy nhất cho mỗi
IO cũng vậy, được ánh xạ 1:1 với IO của ZZ0001ZZ.

Cả việc chuyển tiếp yêu cầu IO và cam kết kết quả xử lý IO đều được thực hiện thông qua
Lệnh chuyển qua ZZ0000ZZ; đó là lý do tại sao ublk cũng dựa trên io_uring
chặn trình điều khiển. Người ta nhận thấy rằng việc sử dụng lệnh chuyển tiếp io_uring có thể
cho IOPS tốt hơn khối IO; đó là lý do tại sao ublk là một trong những ứng dụng có hiệu suất cao
triển khai thiết bị khối không gian người dùng: không chỉ giao tiếp yêu cầu IO được
được thực hiện bởi io_uring, nhưng cách xử lý IO ưa thích trong máy chủ ublk là io_uring
cách tiếp cận dựa trên quá.

ublk cung cấp giao diện điều khiển để thiết lập/lấy thông số thiết bị khối ublk.
Giao diện có thể mở rộng và tương thích kabi: về cơ bản mọi yêu cầu ublk
tham số của hàng đợi hoặc tham số tính năng chung của ublk có thể được đặt/nhận thông qua
giao diện. Vì vậy, ublk là khung thiết bị khối không gian người dùng chung.
Ví dụ: thật dễ dàng để thiết lập một thiết bị ublk với khối được chỉ định
các tham số từ không gian người dùng.

Sử dụng ublk
============

ublk yêu cầu máy chủ ublk không gian người dùng xử lý logic thiết bị khối thực.

Dưới đây là ví dụ về việc sử dụng ZZ0000ZZ để cung cấp thiết bị vòng lặp dựa trên ublk.

- thêm một thiết bị::

ublk thêm -t loop -f ublk-loop.img

- định dạng bằng xfs, sau đó sử dụng nó ::

mkfs.xfs /dev/ublkb0
     gắn kết/dev/ublkb0/mnt
     # do bất cứ thứ gì. tất cả IO được xử lý bởi io_uring
     ...
số lượng /mnt

- liệt kê các thiết bị với thông tin của chúng::

danh sách ublk

- xóa thiết bị::

ublk del -a
     ublk del -n $ublk_dev_id

Xem chi tiết sử dụng trong README của ZZ0000ZZ [#userspace_readme]_.

Thiết kế
========

Mặt phẳng điều khiển
--------------------

trình điều khiển ublk cung cấp nút thiết bị linh tinh toàn cầu (ZZ0000ZZ) cho
quản lý và điều khiển các thiết bị ublk với sự trợ giúp của một số lệnh điều khiển:

-ZZ0000ZZ

Thêm thiết bị ublk char (ZZ0000ZZ) được nói chuyện với máy chủ ublk
  WRT Giao tiếp lệnh IO. Thông tin cơ bản về thiết bị được gửi cùng với thông tin này
  lệnh. Nó đặt cấu trúc UAPI của ZZ0001ZZ,
  chẳng hạn như ZZ0002ZZ, ZZ0003ZZ và kích thước bộ đệm yêu cầu IO tối đa,
  mà thông tin được thương lượng với người lái xe và gửi lại máy chủ.
  Khi lệnh này được hoàn thành, thông tin cơ bản của thiết bị là không thay đổi.

-ZZ0000ZZ / ZZ0001ZZ

Đặt hoặc lấy thông số của thiết bị, có thể là tính năng chung
  liên quan hoặc liên quan đến giới hạn hàng đợi yêu cầu, nhưng không thể cụ thể theo logic IO,
  bởi vì trình điều khiển không xử lý bất kỳ logic IO nào. Lệnh này phải được
  được gửi trước khi gửi ZZ0000ZZ.

-ZZ0000ZZ

Sau khi máy chủ chuẩn bị tài nguyên không gian người dùng (chẳng hạn như tạo trình xử lý I/O
  thread & io_uring để xử lý ublk IO), lệnh này được gửi tới
  trình điều khiển để phân bổ và hiển thị ZZ0000ZZ. Các thông số được thiết lập thông qua
  ZZ0001ZZ được áp dụng để tạo thiết bị.

-ZZ0000ZZ

Dừng IO trên ZZ0000ZZ và tháo thiết bị. Khi lệnh này trở lại,
  máy chủ ublk sẽ giải phóng tài nguyên (chẳng hạn như hủy các luồng xử lý I/O &
  io_uring).

-ZZ0000ZZ

Loại bỏ ZZ0000ZZ. Khi lệnh này trả về, thiết bị ublk được phân bổ
  số có thể được tái sử dụng.

-ZZ0000ZZ

Khi ZZ0000ZZ được thêm vào, trình điều khiển sẽ tạo bộ thẻ lớp khối, vì vậy
  rằng thông tin về mối quan hệ của mỗi hàng đợi đều có sẵn. Máy chủ gửi
  ZZ0001ZZ để truy xuất thông tin về mối quan hệ hàng đợi. Nó có thể
  thiết lập ngữ cảnh trên mỗi hàng đợi một cách hiệu quả, chẳng hạn như liên kết các CPU affine với IO
  pthread và cố gắng phân bổ bộ đệm trong ngữ cảnh luồng IO.

-ZZ0000ZZ

Để truy xuất thông tin thiết bị qua ZZ0000ZZ. Đó là của máy chủ
  trách nhiệm lưu thông tin cụ thể của mục tiêu IO trong không gian người dùng.

-ZZ0000ZZ
  Cùng mục đích với ZZ0001ZZ, nhưng máy chủ ublk phải
  cung cấp đường dẫn của thiết bị char của ZZ0002ZZ để kernel chạy
  kiểm tra quyền và lệnh này được thêm vào để hỗ trợ không có đặc quyền
  ublk và được giới thiệu cùng với ZZ0003ZZ.
  Chỉ người dùng sở hữu thiết bị được yêu cầu mới có thể truy xuất thông tin thiết bị.

Cách xử lý khả năng tương thích không gian người dùng/kernel:

1) nếu kernel có khả năng xử lý ZZ0000ZZ

Nếu máy chủ ublk hỗ trợ ZZ0000ZZ:

máy chủ ublk sẽ gửi ZZ0000ZZ, được cung cấp bất cứ lúc nào
    ứng dụng không có đặc quyền cần truy vấn các thiết bị mà người dùng hiện tại sở hữu,
    khi ứng dụng không biết ZZ0001ZZ có được đặt hay không
    do thông tin khả năng là không trạng thái và ứng dụng phải luôn
    lấy nó qua ZZ0002ZZ

Nếu máy chủ ublk không hỗ trợ ZZ0000ZZ:

ZZ0000ZZ luôn được gửi tới kernel và tính năng của
    UBLK_F_UNPRIVILEGED_DEV không có sẵn cho người dùng

2) nếu kernel không có khả năng xử lý ZZ0000ZZ

Nếu máy chủ ublk hỗ trợ ZZ0000ZZ:

ZZ0000ZZ được thử trước tiên và sẽ thất bại, sau đó
    ZZ0001ZZ cần được thử lại
    Không thể đặt ZZ0002ZZ

Nếu máy chủ ublk không hỗ trợ ZZ0000ZZ:

ZZ0000ZZ luôn được gửi tới kernel và tính năng của
    ZZ0001ZZ không có sẵn cho người dùng

-ZZ0000ZZ

Lệnh này hợp lệ nếu tính năng ZZ0000ZZ được bật. Cái này
  lệnh được chấp nhận sau khi quá trình cũ đã thoát, thiết bị ublk không hoạt động
  và ZZ0001ZZ được phát hành. Người dùng nên gửi lệnh này trước khi bắt đầu
  một quy trình mới mở lại ZZ0002ZZ. Khi lệnh này trả về,
  thiết bị ublk đã sẵn sàng cho quy trình mới.

-ZZ0000ZZ

Lệnh này hợp lệ nếu tính năng ZZ0000ZZ được bật. Cái này
  lệnh được chấp nhận sau khi thiết bị ublk ngừng hoạt động và một quy trình mới có
  đã mở ZZ0001ZZ và chuẩn bị sẵn sàng tất cả hàng đợi ublk. Khi lệnh này
  trả về, thiết bị ublk không được yêu cầu và các yêu cầu I/O mới được chuyển tới
  quá trình mới.

- mô tả tính năng khôi phục người dùng

Ba tính năng mới được thêm vào để phục hồi người dùng: ZZ0000ZZ,
  ZZ0001ZZ và ZZ0002ZZ. Đến
  cho phép khôi phục thiết bị ublk sau khi máy chủ ublk thoát, máy chủ ublk
  nên chỉ định cờ ZZ0003ZZ khi tạo thiết bị. các
  máy chủ ublk có thể chỉ định thêm nhiều nhất một trong số
  ZZ0004ZZ và ZZ0005ZZ đến
  sửa đổi cách xử lý I/O trong khi máy chủ ublk sắp chết/chết (điều này được gọi là
  vỏ ZZ0006ZZ trong mã trình điều khiển).

Chỉ với ZZ0000ZZ được đặt, sau khi máy chủ ublk thoát,
  ublk không xóa ZZ0001ZZ trong suốt quá trình
  giai đoạn khôi phục và ID thiết bị ublk được giữ lại. Đó là máy chủ ublk
  trách nhiệm khôi phục bối cảnh thiết bị bằng kiến thức của chính nó.
  Các yêu cầu chưa được gửi tới không gian người dùng sẽ được yêu cầu xếp hàng đợi. Yêu cầu
  đã được cấp cho không gian người dùng sẽ bị hủy bỏ.

Với ZZ0000ZZ được thiết lập bổ sung, sau máy chủ ublk
  thoát ra, trái ngược với ZZ0001ZZ,
  các yêu cầu đã được đưa ra cho không gian người dùng sẽ được xếp hàng đợi và sẽ được
  được cấp lại cho quy trình mới sau khi xử lý ZZ0002ZZ.
  ZZ0003ZZ được thiết kế dành cho những người phụ trợ có khả năng chịu đựng
  ghi hai lần vì trình điều khiển có thể đưa ra cùng một yêu cầu I/O hai lần. Nó
  có thể hữu ích cho chương trình phụ trợ FS hoặc VM chỉ đọc.

Với ZZ0000ZZ được thiết lập bổ sung, sau máy chủ ublk
  thoát, các yêu cầu gửi đến không gian người dùng đều không thành công, cũng như mọi yêu cầu khác
  các yêu cầu được đưa ra sau đó. Các ứng dụng liên tục đưa ra I/O đối với
  các thiết bị có bộ cờ này sẽ thấy một loạt lỗi I/O cho đến khi có một ublk mới
  máy chủ phục hồi thiết bị.

Thiết bị ublk không có đặc quyền được hỗ trợ bằng cách chuyển ZZ0000ZZ.
Khi cờ được đặt, tất cả các lệnh điều khiển có thể được gửi bằng cách không có đặc quyền
người dùng. Ngoại trừ lệnh của ZZ0001ZZ, kiểm tra quyền
thiết bị char được chỉ định (ZZ0002ZZ) được thực hiện cho tất cả các điều khiển khác
lệnh của trình điều khiển ublk, để thực hiện điều đó, đường dẫn của thiết bị char phải
được cung cấp trong tải trọng của các lệnh này từ máy chủ ublk. Với cách này,
thiết bị ublk trở thành kho chứa và thiết bị được tạo trong một thùng chứa
có thể được kiểm soát/truy cập ngay bên trong vùng chứa này.

Mặt phẳng dữ liệu
-----------------

Máy chủ ublk sẽ tạo các luồng chuyên dụng để xử lý I/O. Mỗi
luồng phải có io_uring riêng để thông báo về điều mới
I/O và thông qua đó nó có thể hoàn thành I/O. Những chủ đề chuyên dụng này
nên tập trung vào xử lý IO và không nên xử lý bất kỳ điều khiển &
nhiệm vụ quản lý.

IO của được gán bởi một thẻ duy nhất, được ánh xạ 1:1 với IO
yêu cầu của ZZ0000ZZ.

Cấu trúc UAPI của ZZ0000ZZ được xác định để mô tả từng IO từ
người lái xe. Một vùng (mảng) được ánh xạ cố định trên ZZ0001ZZ được cung cấp cho
xuất thông tin IO tới máy chủ; chẳng hạn như độ lệch IO, độ dài, OP/cờ và
địa chỉ bộ đệm. Mỗi phiên bản ZZ0002ZZ có thể được lập chỉ mục thông qua id hàng đợi
và thẻ IO trực tiếp.

Các lệnh IO sau đây được truyền đạt thông qua lệnh chuyển tiếp io_uring,
và mỗi lệnh chỉ để chuyển tiếp IO và hoàn thành kết quả
với thẻ IO được chỉ định trong dữ liệu lệnh:

Các lệnh Per-I/O truyền thống
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-ZZ0000ZZ

Được gửi từ luồng I/O của máy chủ để tìm nạp các yêu cầu I/O đến trong tương lai
  định mệnh là ZZ0000ZZ. Lệnh này chỉ được gửi một lần từ máy chủ
  IO pthread cho trình điều khiển ublk để thiết lập môi trường chuyển tiếp IO.

Khi một luồng đưa ra lệnh này đối với một cặp (qid,tag) nhất định, luồng đó
  tự đăng ký làm daemon của I/O đó. Trong tương lai, chỉ có daemon của I/O đó
  được phép đưa ra các lệnh đối với I/O. Nếu bất kỳ chủ đề nào khác cố gắng
  để đưa ra lệnh chống lại cặp (qid,tag) mà luồng không phải là
  daemon, lệnh sẽ thất bại. Daemon chỉ có thể được thiết lập lại khi trải qua
  phục hồi.

Khả năng mỗi cặp (qid,tag) có nhiệm vụ daemon độc lập riêng
  được biểu thị bằng tính năng ZZ0000ZZ. Nếu tính năng này không
  được trình điều khiển hỗ trợ, thay vào đó, các daemon phải ở trên mỗi hàng đợi - tức là tất cả I/O
  liên quan đến một qid phải được xử lý bởi cùng một tác vụ.

-ZZ0000ZZ

Khi một yêu cầu IO được gửi đến ZZ0000ZZ, trình điều khiển sẽ lưu trữ
  ZZ0001ZZ của IO tới khu vực được ánh xạ đã chỉ định; sau đó
  lệnh IO đã nhận trước đó của thẻ IO này (ZZ0002ZZ
  hoặc ZZ0003ZZ đã hoàn tất nên máy chủ sẽ nhận được
  thông báo IO qua io_uring.

Sau khi máy chủ xử lý IO, kết quả của nó được chuyển trở lại
  điều khiển bằng cách gửi lại ZZ0000ZZ. Một lần ublkdrv
  nhận được lệnh này, nó phân tích kết quả và hoàn thành yêu cầu
  ZZ0001ZZ. Trong khi đó, môi trường thiết lập để tìm nạp trong tương lai
  các yêu cầu có cùng thẻ IO. Tức là ZZ0002ZZ
  được sử dụng lại cho cả yêu cầu tìm nạp và gửi lại kết quả IO.

-ZZ0000ZZ

Khi ZZ0000ZZ được bật, yêu cầu WRITE trước tiên sẽ được thực hiện
  cấp cho máy chủ ublk mà không cần sao chép dữ liệu. Sau đó, phần phụ trợ IO của máy chủ ublk
  nhận được yêu cầu và nó có thể phân bổ bộ đệm dữ liệu và nhúng địa chỉ của nó
  bên trong lệnh io mới này. Sau khi trình điều khiển kernel nhận được lệnh,
  sao chép dữ liệu được thực hiện từ các trang yêu cầu tới bộ đệm của chương trình phụ trợ này. Cuối cùng,
  chương trình phụ trợ nhận lại yêu cầu với dữ liệu được ghi và nó có thể
  thực sự xử lý yêu cầu.

ZZ0000ZZ bổ sung thêm một chuyến khứ hồi và một chuyến
  io_uring_enter() cuộc gọi tòa nhà. Bất kỳ người dùng nào cũng nghĩ rằng nó có thể làm giảm hiệu suất
  không nên kích hoạt UBLK_F_NEED_GET_DATA. máy chủ ublk phân bổ trước IO
  bộ đệm cho mỗi IO theo mặc định. Bất kỳ dự án mới nào cũng nên thử sử dụng cái này
  đệm để giao tiếp với trình điều khiển ublk. Tuy nhiên, dự án hiện tại có thể
  bị hỏng hoặc không thể sử dụng giao diện bộ đệm mới; đó là lý do tại sao điều này
  lệnh được thêm vào để tương thích ngược để các dự án hiện có
  vẫn có thể sử dụng bộ đệm hiện có.

- sao chép dữ liệu giữa bộ đệm IO của máy chủ ublk và yêu cầu IO chặn khối ublk

Trình điều khiển cần sao chép các trang yêu cầu khối IO vào bộ đệm máy chủ
  (trang) trước cho WRITE trước khi thông báo cho máy chủ về IO sắp tới, vì vậy
  rằng máy chủ có thể xử lý yêu cầu WRITE.

Khi máy chủ xử lý yêu cầu READ và gửi
  ZZ0000ZZ vào máy chủ, ublkdrv cần sao chép
  bộ đệm máy chủ (trang) đọc tới các trang yêu cầu IO.

Lệnh I/O hàng loạt (UBLK_F_BATCH_IO)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tính năng ZZ0000ZZ cung cấp giải pháp hiệu suất cao thay thế
Mô hình xử lý I/O thay thế các lệnh per-I/O truyền thống bằng
lệnh hàng loạt trên mỗi hàng đợi. Điều này làm giảm đáng kể chi phí liên lạc
và cho phép cân bằng tải tốt hơn trên nhiều tác vụ máy chủ.

Sự khác biệt chính so với chế độ truyền thống:

- ZZ0000ZZ: Các lệnh hoạt động trên hàng đợi thay vì I/O riêng lẻ
- ZZ0001ZZ: Nhiều I/O được xử lý trong các thao tác đơn lẻ
- ZZ0002ZZ: Sử dụng chế độ chụp nhiều ảnh io_uring để giảm chi phí gửi bài
- ZZ0003ZZ: Mọi tác vụ đều có thể xử lý bất kỳ I/O nào (không có trình nền cho mỗi I/O)
- ZZ0004ZZ: Nhiệm vụ có thể điều chỉnh khối lượng công việc một cách linh hoạt

Lệnh I/O hàng loạt:

-ZZ0000ZZ

Chuẩn bị nhiều lệnh I/O theo đợt. Máy chủ cung cấp bộ đệm
  chứa nhiều bộ mô tả I/O sẽ được xử lý cùng nhau.
  Điều này làm giảm số lượng yêu cầu gửi lệnh riêng lẻ.

-ZZ0000ZZ

Cam kết kết quả cho nhiều thao tác I/O theo đợt và chuẩn bị
  Bộ mô tả I/O để chấp nhận các yêu cầu mới. Máy chủ cung cấp bộ đệm
  chứa kết quả của nhiều I/O đã hoàn thành, cho phép thực hiện hiệu quả
  hoàn thành hàng loạt các yêu cầu.

-ZZ0000ZZ

ZZ0000ZZ để tìm nạp các lệnh I/O theo đợt. Đây là chìa khóa
  lệnh cho phép xử lý hàng loạt hiệu suất cao:

* Sử dụng khả năng chụp nhiều ảnh io_uring để giảm chi phí gửi
  * Một lệnh có thể tìm nạp nhiều yêu cầu I/O theo thời gian
  * Kích thước bộ đệm xác định kích thước lô tối đa cho mỗi thao tác
  * Có thể gửi nhiều lệnh tìm nạp để cân bằng tải
  * Chỉ có một lệnh tìm nạp được kích hoạt bất cứ lúc nào trên mỗi hàng đợi
  * Hỗ trợ cân bằng tải động trên nhiều tác vụ máy chủ

Đó là một yêu cầu io_uring nhiều lần chụp điển hình với bộ đệm được cung cấp và nó
  sẽ không được hoàn thành cho đến khi có bất kỳ lỗi nào được kích hoạt.

Mỗi tác vụ có thể gửi ZZ0000ZZ với bộ đệm khác nhau
  kích thước để kiểm soát lượng công việc nó xử lý. Điều này cho phép tinh vi
  chiến lược cân bằng tải trong các máy chủ đa luồng.

Di chuyển: Các ứng dụng sử dụng lệnh truyền thống (ZZ0000ZZ,
ZZ0001ZZ) không thể sử dụng chế độ hàng loạt cùng một lúc.

Không sao chép
--------------

Bản sao ublk zero dựa vào bộ đệm hạt nhân cố định của io_uring, cung cấp
hai API: ZZ0000ZZ và ZZ0001ZZ.

ublk thêm lệnh IO của ZZ0000ZZ để gọi
ZZ0001ZZ cho máy chủ ublk để đăng ký yêu cầu của khách hàng
đệm vào bảng đệm io_uring, sau đó máy chủ ublk có thể gửi io_uring
IO với chỉ mục bộ đệm đã đăng ký. Lệnh IO của ZZ0002ZZ
gọi ZZ0003ZZ để hủy đăng ký bộ đệm, nghĩa là
được đảm bảo vẫn hoạt động giữa việc gọi ZZ0004ZZ và
ZZ0005ZZ. Bất kỳ hoạt động io_uring nào hỗ trợ điều này
loại bộ đệm kernel sẽ lấy một tham chiếu của bộ đệm cho đến khi
hoạt động được hoàn thành.

máy chủ ublk triển khai bản sao bằng 0 hoặc bản sao của người dùng phải là CAP_SYS_ADMIN và
được tin cậy, vì trách nhiệm của máy chủ ublk là đảm bảo bộ đệm IO
chứa đầy dữ liệu để xử lý lệnh đọc và máy chủ ublk phải quay lại
kết quả chính xác cho trình điều khiển ublk khi xử lý lệnh READ và kết quả
phải khớp với số byte được lấp đầy vào bộ đệm IO. Nếu không,
Bộ đệm IO kernel chưa được khởi tạo sẽ được hiển thị cho ứng dụng khách.

server ublk cần căn chỉnh tham số của ZZ0000ZZ
với phần phụ trợ để không có bản sao nào hoạt động chính xác.

Để đạt được hiệu suất IO tốt nhất, máy chủ ublk phải căn chỉnh phân khúc của nó
tham số của ZZ0000ZZ với phần phụ trợ để tránh
phân chia IO không cần thiết, điều này thường ảnh hưởng đến hiệu suất io_uring.

Đăng ký bộ đệm tự động
------------------------

Tính năng ZZ0000ZZ tự động xử lý đăng ký bộ đệm
và hủy đăng ký các yêu cầu I/O, giúp đơn giản hóa việc quản lý bộ đệm
xử lý và giảm chi phí triển khai máy chủ ublk.

Đây là một lá cờ tính năng khác để sử dụng bản sao không và nó tương thích với
ZZ0000ZZ.

Tổng quan về tính năng
~~~~~~~~~~~~~~~~~~~~~~

Tính năng này tự động đăng ký bộ đệm yêu cầu vào ngữ cảnh io_uring
trước khi gửi các lệnh I/O đến máy chủ ublk và hủy đăng ký chúng khi
hoàn thành các lệnh I/O. Điều này giúp loại bỏ sự cần thiết của bộ đệm thủ công
đăng ký/hủy đăng ký qua ZZ0000ZZ và
Các lệnh ZZ0001ZZ, sau đó xử lý IO trong máy chủ ublk
có thể tránh sự phụ thuộc vào hai thao tác uring_cmd.

IO không thể được cấp đồng thời cho io_uring nếu có bất kỳ sự phụ thuộc nào
trong số các IO này. Vì vậy, cách này không chỉ đơn giản hóa việc triển khai máy chủ ublk,
mà còn giúp việc xử lý IO đồng thời trở nên khả thi bằng cách loại bỏ
phụ thuộc vào các lệnh đăng ký và hủy đăng ký bộ đệm.

Yêu cầu sử dụng
~~~~~~~~~~~~~~~~~~

1. Máy chủ ublk phải tạo bảng đệm thưa trên cùng ZZ0000ZZ
   được sử dụng cho ZZ0001ZZ và ZZ0002ZZ. Nếu
   uring_cmd được cấp trên ZZ0003ZZ khác, bộ đệm thủ công
   yêu cầu hủy đăng ký.

2. Dữ liệu đăng ký bộ đệm phải được chuyển qua ZZ0000ZZ của uring_cmd với
   cấu trúc sau::

cấu trúc ublk_auto_buf_reg {
        chỉ số __u16;      /* Chỉ mục đệm để đăng ký */
        __u8 cờ;       /* Cờ đăng ký */
        __u8 dành riêng0;   /*Dự trữ để sử dụng sau này*/
        __u32 dành riêng1;  /*Dự trữ để sử dụng sau này*/
    };

ublk_auto_buf_reg_to_sqe_addr() dùng để chuyển cấu trúc trên thành
   ZZ0000ZZ.

3. Tất cả các trường dành riêng trong ZZ0000ZZ phải bằng 0.

4. Cờ tùy chọn có thể được chuyển qua ZZ0000ZZ.

Hành vi dự phòng
~~~~~~~~~~~~~~~~~

Nếu đăng ký bộ đệm tự động không thành công:

1. Khi ZZ0000ZZ được bật:

- Uing_cmd đã hoàn tất
   - ZZ0000ZZ được đặt trong ZZ0001ZZ
   - Máy chủ ublk phải xử lý lỗi theo cách thủ công, chẳng hạn như đăng ký
     bộ đệm theo cách thủ công hoặc sử dụng tính năng sao chép của người dùng để truy xuất dữ liệu
     để xử lý ublk IO

2. Nếu tính năng dự phòng không được bật:

- Yêu cầu I/O ublk bị lỗi âm thầm
   - Uing_cmd sẽ không được hoàn thành

Hạn chế
~~~~~~~~~~~

- Yêu cầu cùng ZZ0000ZZ cho mọi hoạt động
- Có thể yêu cầu quản lý bộ đệm thủ công trong trường hợp dự phòng
- Bảng đệm io_ring_ctx có kích thước tối đa là 16K, có thể không đủ
  trong trường hợp có quá nhiều thiết bị ublk được xử lý bởi io_ring_ctx này
  và mỗi cái có độ sâu hàng đợi rất lớn

Bản sao bộ nhớ chia sẻ không (UBLK_F_SHMEM_ZC)
----------------------------------------------

Tính năng ZZ0000ZZ cung cấp đường dẫn không sao chép thay thế
hoạt động bằng cách chia sẻ các trang bộ nhớ vật lý giữa ứng dụng khách
và máy chủ ublk. Không giống như cách tiếp cận bộ đệm cố định io_uring ở trên,
bản sao bộ nhớ chia sẻ không yêu cầu đăng ký bộ đệm io_uring
trên mỗi I/O - thay vào đó, nó dựa vào kernel phù hợp với các trang vật lý
tại thời điểm I/O. Điều này cho phép máy chủ ublk truy cập vào phần chia sẻ
đệm trực tiếp, điều này khó có thể xảy ra đối với bộ đệm cố định io_uring
cách tiếp cận.

Động lực
~~~~~~~~~~

Bản sao không có bộ nhớ dùng chung có cách tiếp cận khác: nếu máy khách
ứng dụng và máy chủ ublk đều ánh xạ cùng một bộ nhớ vật lý, có
không có gì để sao chép. Hạt nhân tự động phát hiện các trang được chia sẻ và
cho máy chủ biết nơi dữ liệu đã tồn tại.

ZZ0000ZZ có thể được coi là một phần bổ sung cho khách hàng được tối ưu hóa
ứng dụng — khi máy khách sẵn sàng phân bổ bộ đệm I/O từ
bộ nhớ dùng chung, toàn bộ đường dẫn dữ liệu sẽ không có bản sao.

Trường hợp sử dụng
~~~~~~~~~~~~~~~~~~

Tính năng này rất hữu ích khi ứng dụng khách có thể được cấu hình để
sử dụng vùng bộ nhớ dùng chung cụ thể cho bộ đệm I/O của nó:

- ZZ0000ZZ phân bổ bộ đệm I/O từ bộ nhớ dùng chung
  (memfd, Hugetlbfs) và cấp I/O trực tiếp tới thiết bị ublk
- ZZ0001ZZ sử dụng vùng đệm được phân bổ trước với O_DIRECT

Nó hoạt động như thế nào
~~~~~~~~~~~~~~~~~~~~~~~~

1. Cả máy chủ và máy khách ublk ZZ0000ZZ đều có cùng một tệp (memfd hoặc
   Hugetlbfs) với ZZ0001ZZ. Điều này cho phép cả hai quá trình truy cập vào
   các trang vật lý giống nhau.

2. Máy chủ ublk đăng ký ánh xạ của nó với kernel::

struct ublk_shmem_buf_reg buf = { .addr = mmap_va, .len = size };
     ublk_ctrl_cmd(UBLK_U_CMD_REG_BUF, .addr = &buf);

Hạt nhân ghim các trang và xây dựng cây tra cứu PFN.

3. Khi máy khách phát hành I/O trực tiếp (ZZ0000ZZ) tới ZZ0001ZZ,
   kernel kiểm tra xem các trang đệm I/O có khớp với bất kỳ trang nào đã đăng ký không
   trang bằng cách so sánh PFN.

4. Khi khớp, kernel đặt ZZ0000ZZ trong I/O
   bộ mô tả và mã hóa chỉ mục bộ đệm và phần bù trong ZZ0001ZZ::

if (iod->op_flags & UBLK_IO_F_SHMEM_ZC) {
         /* Dữ liệu đã có trong ánh xạ chung của chúng tôi — không sao chép */
         chỉ mục = ublk_shmem_zc_index(iod->addr);
         offset = ublk_shmem_zc_offset(iod->addr);
         buf = shmem_table[index].mmap_base + offset;
     }

5. Nếu các trang không khớp (ví dụ: ứng dụng khách đã sử dụng bộ đệm không chia sẻ),
   I/O âm thầm quay trở lại đường dẫn sao chép bình thường.

Bộ nhớ dùng chung có thể được thiết lập thông qua hai phương pháp:

- ZZ0002ZZ: máy khách gửi memfd đến máy chủ ublk qua
  ZZ0000ZZ trên ổ cắm unix. Máy chủ mmaps và đăng ký nó.
- ZZ0003ZZ: cả hai quá trình ZZ0001ZZ đều giống nhau
  tập tin Hugetlbfs. Không cần IPC - cùng một tệp sẽ cung cấp các trang vật lý giống nhau.

Thuận lợi
~~~~~~~~~~

- ZZ0000ZZ: không có lệnh đăng ký hoặc hủy đăng ký bộ đệm trên mỗi I/O.
  Khi bộ đệm chia sẻ được đăng ký, tất cả I/O phù hợp sẽ không có bản sao
  tự động.
- ZZ0001ZZ: máy chủ ublk có thể đọc và ghi nội dung được chia sẻ
  đệm trực tiếp thông qua mmap của chính nó mà không cần thông qua io_uring đã sửa
  hoạt động đệm. Điều này thân thiện hơn cho việc triển khai máy chủ.
- ZZ0002ZZ: Đối sánh PFN là tra cứu cây phong đơn lẻ trên mỗi bvec. Không
  io_uring lệnh khứ hồi để quản lý bộ đệm.
- ZZ0003ZZ: I/O không khớp âm thầm quay trở lại đường dẫn sao chép.
  Thiết bị hoạt động bình thường đối với mọi khách hàng, không có bản sao nào
  tối ưu hóa khi có bộ nhớ dùng chung.

Hạn chế
~~~~~~~~~~~

- ZZ0002ZZ: client phải phân bổ I/O của nó
  bộ đệm từ vùng bộ nhớ dùng chung. Điều này đòi hỏi một tùy chỉnh hoặc
  máy khách được cấu hình - các ứng dụng tiêu chuẩn sử dụng bộ đệm của riêng chúng
  sẽ không được hưởng lợi.
- ZZ0003ZZ: I/O được đệm (không có ZZ0000ZZ) đi qua
  bộ đệm trang, phân bổ các trang riêng của nó. Những hạt nhân được phân bổ này
  các trang sẽ không bao giờ khớp với bộ đệm chia sẻ đã đăng ký. Chỉ ZZ0001ZZ
  đặt các trang đệm của máy khách trực tiếp vào khối I/O.
- ZZ0004ZZ: dữ liệu của mỗi yêu cầu I/O phải liền kề nhau
  trong một bộ đệm đã đăng ký. Phân tán/thu thập I/O trải dài
  nhiều bộ đệm đã đăng ký không liền kề không thể sử dụng đường dẫn không sao chép.

Lệnh điều khiển
~~~~~~~~~~~~~~~~

-ZZ0000ZZ

Đăng ký bộ nhớ đệm dùng chung. ZZ0000ZZ trỏ tới một
  ZZ0001ZZ chứa địa chỉ và kích thước bộ đệm ảo.
  Trả về chỉ số bộ đệm được chỉ định (>= 0) nếu thành công. Các chân hạt nhân
  trang và xây dựng cây tra cứu PFN. Việc đóng băng hàng đợi được xử lý
  nội bộ.

-ZZ0000ZZ

Hủy đăng ký bộ đệm đã đăng ký trước đó. ZZ0000ZZ là
  chỉ số đệm. Bỏ ghim các trang và xóa các mục PFN khỏi tra cứu
  cây.

Tài liệu tham khảo
==================

.. [#userspace] https://github.com/ming1/ubdsrv

.. [#userspace_lib] https://github.com/ming1/ubdsrv/tree/master/lib

.. [#userspace_nbdublk] https://gitlab.com/rwmjones/libnbd/-/tree/nbdublk

.. [#userspace_readme] https://github.com/ming1/ubdsrv/blob/master/README