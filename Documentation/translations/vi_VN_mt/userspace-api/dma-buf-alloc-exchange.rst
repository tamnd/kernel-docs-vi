.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/userspace-api/dma-buf-alloc-exchange.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright 2021-2023 Collabora Ltd.

===========================
Trao đổi bộ đệm pixel
===========================

Theo thiết kế ban đầu, hệ thống con đồ họa Linux có rất nhiều hạn chế
hỗ trợ chia sẻ phân bổ bộ đệm pixel giữa các quy trình, thiết bị và
các hệ thống con. Các hệ thống hiện đại đòi hỏi sự tích hợp rộng rãi giữa cả ba
lớp học; tài liệu này mô tả chi tiết cách các ứng dụng và hệ thống con kernel nên
tiếp cận việc chia sẻ dữ liệu hình ảnh hai chiều này.

Nó được viết có tham chiếu đến hệ thống con DRM dành cho GPU và các thiết bị hiển thị,
V4L2 dành cho thiết bị đa phương tiện cũng như Vulkan, EGL và Wayland dành cho không gian người dùng
hỗ trợ, tuy nhiên bất kỳ hệ thống con nào khác cũng nên tuân theo thiết kế và lời khuyên này.


Bảng chú giải thuật ngữ
=================

.. glossary::

    image:
      Conceptually a two-dimensional array of pixels. The pixels may be stored
      in one or more memory buffers. Has width and height in pixels, pixel
      format and modifier (implicit or explicit).

    row:
      A span along a single y-axis value, e.g. from co-ordinates (0,100) to
      (200,100).

    scanline:
      Synonym for row.

    column:
      A span along a single x-axis value, e.g. from co-ordinates (100,0) to
      (100,100).

    memory buffer:
      A piece of memory for storing (parts of) pixel data. Has stride and size
      in bytes and at least one handle in some API. May contain one or more
      planes.

    plane:
      A two-dimensional array of some or all of an image's color and alpha
      channel values.

    pixel:
      A picture element. Has a single color value which is defined by one or
      more color channels values, e.g. R, G and B, or Y, Cb and Cr. May also
      have an alpha value as an additional channel.

    pixel data:
      Bytes or bits that represent some or all of the color/alpha channel values
      of a pixel or an image. The data for one pixel may be spread over several
      planes or memory buffers depending on format and modifier.

    color value:
      A tuple of numbers, representing a color. Each element in the tuple is a
      color channel value.

    color channel:
      One of the dimensions in a color model. For example, RGB model has
      channels R, G, and B. Alpha channel is sometimes counted as a color
      channel as well.

    pixel format:
      A description of how pixel data represents the pixel's color and alpha
      values.

    modifier:
      A description of how pixel data is laid out in memory buffers.

    alpha:
      A value that denotes the color coverage in a pixel. Sometimes used for
      translucency instead.

    stride:
      A value that denotes the relationship between pixel-location co-ordinates
      and byte-offset values. Typically used as the byte offset between two
      pixels at the start of vertically-consecutive tiling blocks. For linear
      layouts, the byte offset between two vertically-adjacent pixels. For
      non-linear formats the stride must be computed in a consistent way, which
      usually is done as-if the layout was linear.

    pitch:
      Synonym for stride.


Định dạng và sửa đổi
=====================

Mỗi bộ đệm phải có một định dạng cơ bản. Định dạng này mô tả màu sắc
giá trị được cung cấp cho mỗi pixel. Mặc dù mỗi hệ thống con có định dạng riêng
mô tả (ví dụ: V4L2 và fbdev), mã thông báo ZZ0000ZZ phải được sử dụng lại
bất cứ khi nào có thể, vì chúng là những mô tả tiêu chuẩn được sử dụng để trao đổi.
Các mã thông báo này được mô tả trong tệp ZZ0001ZZ, là một phần của
uAPI của DRM.

Mỗi mã thông báo ZZ0000ZZ mô tả bản dịch giữa một pixel
phối hợp trong một hình ảnh và các giá trị màu cho pixel đó có trong
bộ nhớ đệm của nó. Số lượng và loại kênh màu được mô tả:
cho dù chúng là RGB hay YUV, số nguyên hay dấu phẩy động, kích thước của mỗi kênh
và vị trí của chúng trong bộ nhớ pixel cũng như mối quan hệ giữa màu sắc
máy bay.

Ví dụ: ZZ0000ZZ mô tả một định dạng trong đó mỗi pixel có
một giá trị 32 bit duy nhất trong bộ nhớ. Các kênh màu Alpha, đỏ, lục và lam là
có sẵn ở độ chính xác 8 bit cho mỗi kênh, được sắp xếp tương ứng từ hầu hết đến
các bit ít quan trọng nhất trong bộ lưu trữ endian nhỏ. ZZ0001ZZ thì không
bị ảnh hưởng bởi CPU hoặc độ bền của thiết bị; mẫu byte trong bộ nhớ là
luôn như được mô tả trong định nghĩa định dạng, thường là endian nhỏ.

Như một ví dụ phức tạp hơn, ZZ0000ZZ mô tả một định dạng trong đó độ sáng
và các mẫu sắc độ YUV được lưu trữ trong các mặt phẳng riêng biệt, trong đó mặt phẳng sắc độ
được lưu trữ ở một nửa độ phân giải ở cả hai chiều (tức là một sắc độ U/V
mẫu được lưu trữ cho mỗi nhóm pixel 2x2).

Công cụ sửa đổi định dạng mô tả cơ chế dịch giữa bộ nhớ trên mỗi pixel này
mẫu và bộ nhớ lưu trữ thực tế cho bộ đệm. Đơn giản nhất
công cụ sửa đổi là ZZ0000ZZ, mô tả sơ đồ trong đó mỗi mặt phẳng
được sắp xếp theo hàng tuần tự, từ góc trên bên trái đến góc dưới bên phải.
Đây được coi là định dạng trao đổi cơ bản và thuận tiện nhất cho CPU
truy cập.

Phần cứng hiện đại sử dụng các cơ chế truy cập phức tạp hơn nhiều, điển hình là
sử dụng quyền truy cập theo ô và có thể cả tính năng nén. Ví dụ,
Công cụ sửa đổi ZZ0000ZZ mô tả bộ nhớ lưu trữ trong đó các pixel
được lưu trữ trong các khối 4x4 được sắp xếp theo thứ tự hàng lớn, tức là ô đầu tiên trong
một mặt phẳng lưu trữ các pixel (0,0) đến (3,3) và ô thứ hai trong một mặt phẳng
lưu trữ các pixel (4.0) đến (7.3).

Một số công cụ sửa đổi có thể sửa đổi số lượng mặt phẳng cần thiết cho một hình ảnh; cho
ví dụ: công cụ sửa đổi ZZ0000ZZ thêm mặt phẳng thứ hai vào RGB
các định dạng trong đó nó lưu trữ dữ liệu về trạng thái của mỗi ô, đặc biệt là
bao gồm liệu ô có được điền đầy đủ dữ liệu pixel hay không hoặc có thể
mở rộng từ một màu đơn sắc.

Các bố cục mở rộng này rất cụ thể cho nhà cung cấp và thậm chí cụ thể cho
các thế hệ hoặc cấu hình cụ thể của thiết bị cho mỗi nhà cung cấp. Vì lý do này,
sự hỗ trợ của các sửa đổi phải được liệt kê và thương lượng rõ ràng bởi tất cả người dùng
để đảm bảo một đường ống tương thích và tối ưu, như được thảo luận dưới đây.


Kích thước và kích thước
===================

Mỗi bộ đệm pixel phải đi kèm với kích thước pixel hợp lý. Điều này ám chỉ
số lượng mẫu duy nhất có thể được trích xuất hoặc lưu trữ vào
lưu trữ bộ nhớ cơ bản. Ví dụ: mặc dù 1920x1080
Bộ đệm ZZ0000ZZ có mặt phẳng luma chứa các mẫu 1920x1080 cho Y
thành phần và các mẫu 960x540 cho các thành phần U và V, bộ đệm tổng thể là
vẫn được mô tả là có kích thước 1920x1080.

Việc lưu trữ trong bộ nhớ của bộ đệm không được đảm bảo bắt đầu ngay lập tức tại
địa chỉ cơ sở của bộ nhớ cơ bản, cũng như không đảm bảo rằng bộ nhớ
lưu trữ được cắt chặt theo một trong hai chiều.

Do đó, mỗi mặt phẳng phải được mô tả bằng ZZ0000ZZ tính bằng byte, sẽ được
được thêm vào địa chỉ cơ sở của bộ nhớ lưu trữ trước khi thực hiện bất kỳ pixel nào
tính toán. Điều này có thể được sử dụng để kết hợp nhiều mặt phẳng vào một bộ nhớ
đệm; ví dụ: ZZ0001ZZ có thể được lưu trữ trong một bộ nhớ đệm
nơi lưu trữ của mặt phẳng luma bắt đầu ngay khi bắt đầu bộ đệm
với độ lệch bằng 0 và bộ lưu trữ của mặt phẳng sắc độ nằm trong cùng một bộ đệm
bắt đầu từ phần bù byte cho mặt phẳng đó.

Mỗi mặt phẳng cũng phải có ZZ0000ZZ tính bằng byte, biểu thị phần bù trong bộ nhớ
giữa hai hàng liền kề. Ví dụ: bộ đệm ZZ0001ZZ
với kích thước 1000x1000 có thể đã được phân bổ như thể nó là 1024x1000, trong
để cho phép các mẫu truy cập được căn chỉnh. Trong trường hợp này, bộ đệm vẫn sẽ
được mô tả với chiều rộng 1000, tuy nhiên sải chân sẽ là ZZ0002ZZ,
chỉ ra rằng có 24 pixel ở cực dương của trục x có
các giá trị không đáng kể.

Bộ đệm cũng có thể được đệm thêm theo chiều y, chỉ bằng cách phân bổ một
diện tích lớn hơn mức yêu cầu thông thường. Ví dụ, nhiều bộ giải mã phương tiện
không thể xuất ra bộ đệm có chiều cao 1080 mà thay vào đó yêu cầu một
chiều cao hiệu quả là 1088 pixel. Trong trường hợp này, bộ đệm tiếp tục được
được mô tả là có chiều cao 1080, với sự phân bổ bộ nhớ cho mỗi bộ đệm
được tăng lên để giải thích cho phần đệm thêm.


liệt kê
===========

Mọi người dùng bộ đệm pixel phải có khả năng liệt kê một tập hợp các định dạng được hỗ trợ
và các công cụ sửa đổi, được mô tả cùng nhau. Trong KMS, điều này đạt được nhờ
Thuộc tính ZZ0000ZZ trên mỗi mặt phẳng DRM, liệt kê các định dạng DRM được hỗ trợ và
các sửa đổi được hỗ trợ cho từng định dạng. Trong không gian người dùng, điều này được hỗ trợ thông qua
điểm vào mở rộng ZZ0001ZZ cho EGL,
Phần mở rộng ZZ0002ZZ cho Vulkan và
Phần mở rộng ZZ0003ZZ cho Wayland.

Mỗi giao diện này cho phép người dùng truy vấn một tập hợp các giao diện được hỗ trợ
kết hợp định dạng + sửa đổi.


đàm phán
===========

Trách nhiệm của không gian người dùng là phải thương lượng định dạng + công cụ sửa đổi được chấp nhận
sự kết hợp cho việc sử dụng nó. Điều này được thực hiện thông qua một giao điểm đơn giản của
danh sách. Ví dụ: nếu người dùng muốn sử dụng Vulkan để hiển thị hình ảnh
được hiển thị trên mặt phẳng KMS, nó phải:

- truy vấn KMS để tìm thuộc tính ZZ0000ZZ cho mặt phẳng đã cho
 - truy vấn Vulkan để biết các định dạng được hỗ trợ cho thiết bị vật lý của nó, đảm bảo
   để vượt qua ZZ0001ZZ và ZZ0002ZZ
   tương ứng với mục đích sử dụng kết xuất dự kiến
 - giao nhau các định dạng này để xác định định dạng thích hợp nhất
 - đối với định dạng này, hãy cắt ngang danh sách các công cụ sửa đổi được hỗ trợ cho cả KMS và
   Vulkan, để có được danh sách cuối cùng các công cụ sửa đổi được chấp nhận cho định dạng đó

Giao lộ này phải được thực hiện cho tất cả các mục đích sử dụng. Ví dụ, nếu người dùng
cũng muốn mã hóa hình ảnh thành luồng video, nó phải truy vấn phương tiện API
nó dự định sử dụng để mã hóa cho tập hợp các công cụ sửa đổi mà nó hỗ trợ và
Ngoài ra còn giao nhau với danh sách này.

Nếu giao điểm của tất cả các danh sách là một danh sách trống thì không thể chia sẻ
vùng đệm theo cách này và phải xem xét chiến lược thay thế (ví dụ: sử dụng
CPU truy cập các thói quen để sao chép dữ liệu giữa các mục đích sử dụng khác nhau, với
chi phí thực hiện tương ứng).

Danh sách sửa đổi kết quả chưa được sắp xếp; thứ tự không đáng kể.


Phân bổ
==========

Khi không gian người dùng đã xác định được định dạng phù hợp và danh sách tương ứng
các sửa đổi được chấp nhận, nó phải phân bổ bộ đệm. Vì không có cái chung
giao diện cấp phát bộ đệm có sẵn ở cấp độ kernel hoặc không gian người dùng,
khách hàng đưa ra lựa chọn tùy ý về giao diện phân bổ, chẳng hạn như Vulkan, GBM hoặc
một phương tiện truyền thông API.

Mỗi yêu cầu phân bổ tối thiểu phải có: định dạng pixel, danh sách
các sửa đổi được chấp nhận cũng như chiều rộng và chiều cao của bộ đệm. Mỗi API có thể mở rộng
tập hợp các thuộc tính này theo nhiều cách khác nhau, chẳng hạn như cho phép phân bổ nhiều
hơn hai chiều, mô hình sử dụng dự định, v.v.

Thành phần phân bổ bộ đệm sẽ đưa ra lựa chọn tùy ý về những gì
nó xem xét công cụ sửa đổi 'tốt nhất' trong danh sách có thể chấp nhận được cho yêu cầu
phân bổ, bất kỳ phần đệm nào được yêu cầu và các thuộc tính khác của lớp cơ bản
bộ nhớ đệm chẳng hạn như chúng được lưu trữ trong hệ thống hay thiết bị cụ thể
bộ nhớ, cho dù chúng có liền kề về mặt vật lý hay không và chế độ bộ đệm của chúng.
Các thuộc tính này của bộ nhớ đệm không hiển thị với không gian người dùng, tuy nhiên
ZZ0000ZZ API là một nỗ lực nhằm giải quyết vấn đề này.

Sau khi phân bổ, máy khách phải truy vấn bộ cấp phát để xác định giá trị thực tế
công cụ sửa đổi được chọn cho bộ đệm, cũng như độ lệch và bước tiến trên mỗi mặt phẳng.
Người cấp phát không được phép thay đổi định dạng đang sử dụng, để chọn một công cụ sửa đổi không
được cung cấp trong danh sách có thể chấp nhận được cũng như không thay đổi kích thước pixel ngoài
phần đệm được thể hiện thông qua độ lệch, bước tiến và kích thước.

Truyền đạt các ràng buộc bổ sung, chẳng hạn như căn chỉnh bước tiến hoặc độ lệch,
vị trí trong một vùng bộ nhớ cụ thể, v.v., nằm ngoài phạm vi của dma-buf,
và không được giải quyết bằng mã thông báo định dạng và sửa đổi.


Nhập khẩu
======

Để sử dụng bộ đệm trong bối cảnh, thiết bị hoặc hệ thống con khác, người dùng
chuyển các tham số này (định dạng, công cụ sửa đổi, chiều rộng, chiều cao và độ lệch trên mỗi mặt phẳng
và sải bước) sang API đang nhập.

Mỗi bộ nhớ đệm được tham chiếu bằng một bộ xử lý bộ đệm, có thể là duy nhất hoặc
được nhân đôi trong một hình ảnh. Ví dụ: bộ đệm ZZ0000ZZ có thể có
bộ đệm độ sáng và sắc độ được kết hợp thành một bộ đệm bộ nhớ duy nhất bằng cách sử dụng
các tham số offset trên mỗi mặt phẳng hoặc chúng có thể được phân bổ hoàn toàn riêng biệt trong
trí nhớ. Vì lý do này, mỗi lần nhập và phân bổ API phải cung cấp một
xử lý cho mỗi mặt phẳng.

Mỗi hệ thống con kernel có các kiểu và giao diện riêng để quản lý bộ đệm.
DRM sử dụng các đối tượng bộ đệm GEM (BO), V4L2 có các tham chiếu riêng, v.v. Những loại này
không thể di chuyển giữa các bối cảnh, quy trình, thiết bị hoặc hệ thống con.

Để giải quyết vấn đề này, các tay cầm ZZ0000ZZ được sử dụng làm nút trao đổi chung cho
bộ đệm. Các hoạt động dành riêng cho hệ thống con được sử dụng để xuất các bộ xử lý bộ đệm gốc
vào bộ mô tả tệp ZZ0001ZZ và nhập các bộ mô tả tệp đó vào một
xử lý bộ đệm gốc. bộ mô tả tập tin dma-buf có thể được chuyển giữa
bối cảnh, quy trình, thiết bị và hệ thống con.

Ví dụ: trình phát đa phương tiện Wayland có thể sử dụng V4L2 để giải mã khung hình video thành
Bộ đệm ZZ0000ZZ. Điều này sẽ dẫn đến hai mặt phẳng bộ nhớ (luma và
chroma) đang được người dùng loại bỏ khỏi V4L2. Những chiếc máy bay này sau đó được xuất khẩu sang
một bộ mô tả tệp dma-buf trên mỗi mặt phẳng, những bộ mô tả này sau đó sẽ được gửi cùng
với siêu dữ liệu (định dạng, công cụ sửa đổi, chiều rộng, chiều cao, độ lệch trên mỗi mặt phẳng và bước tiến)
đến máy chủ Wayland. Máy chủ Wayland sau đó sẽ nhập các tệp này
bộ mô tả dưới dạng EGLImage để sử dụng thông qua EGL/OpenGL (ES), VkImage để sử dụng
thông qua Vulkan hoặc đối tượng bộ đệm khung KMS; mỗi hoạt động nhập khẩu này
sẽ lấy cùng một siêu dữ liệu và chuyển đổi các bộ mô tả tệp dma-buf thành
xử lý bộ đệm gốc.

Việc có một giao điểm không trống của các công cụ sửa đổi được hỗ trợ không đảm bảo rằng
nhập khẩu sẽ thành công tới mọi người tiêu dùng; họ có thể có những hạn chế ngoài những hạn chế đó
ngụ ý bởi các sửa đổi phải được thỏa mãn.


Công cụ sửa đổi ngầm định
==================

Khái niệm về các công cụ sửa đổi có sau tất cả các hệ thống con được đề cập ở trên. Như
như vậy, nó đã được trang bị thêm vào tất cả các API này và để đảm bảo
khả năng tương thích ngược, cần có sự hỗ trợ cho trình điều khiển và không gian người dùng
không (chưa) hỗ trợ sửa đổi.

Ví dụ: GBM được sử dụng để phân bổ bộ đệm được chia sẻ giữa EGL cho
kết xuất và KMS để hiển thị. Nó có hai điểm vào để phân bổ bộ đệm:
ZZ0000ZZ chỉ lấy định dạng, chiều rộng, chiều cao và mã thông báo sử dụng,
và ZZ0001ZZ mở rộng điều này với một danh sách các công cụ sửa đổi.

Trong trường hợp thứ hai, việc phân bổ được thực hiện như đã thảo luận ở trên, được cung cấp một
danh sách các sửa đổi được chấp nhận mà việc triển khai có thể chọn (hoặc thất bại nếu
không thể phân bổ trong những ràng buộc đó). Trong trường hợp trước
trong trường hợp không cung cấp công cụ sửa đổi, việc triển khai GBM phải tự tạo
lựa chọn những gì có thể là cách bố trí 'tốt nhất'. Sự lựa chọn như vậy hoàn toàn
dành riêng cho việc triển khai: một số sẽ sử dụng bố cục theo ô trong nội bộ mà không
CPU có thể truy cập được nếu việc triển khai quyết định đó là một ý tưởng hay thông qua
bất cứ điều gì heuristic. Trách nhiệm của người thực hiện là đảm bảo rằng
sự lựa chọn này là phù hợp.

Để hỗ trợ trường hợp này không biết bố cục vì không có nhận thức
trong số các công cụ sửa đổi, mã thông báo ZZ0000ZZ đặc biệt đã được xác định. Cái này
công cụ sửa đổi giả tuyên bố rằng bố cục không được biết và trình điều khiển
nên sử dụng logic riêng của nó để xác định bố cục cơ bản có thể là gì.

.. note::

  ``DRM_FORMAT_MOD_INVALID`` is a non-zero value. The modifier value zero is
  ``DRM_FORMAT_MOD_LINEAR``, which is an explicit guarantee that the image
  has the linear layout. Care and attention should be taken to ensure that
  zero as a default value is not mixed up with either no modifier or the linear
  modifier. Also note that in some APIs the invalid modifier value is specified
  with an out-of-band flag, like in ``DRM_IOCTL_MODE_ADDFB2``.

Có bốn trường hợp có thể sử dụng mã thông báo này:
  - trong quá trình liệt kê, một giao diện có thể trả về ZZ0000ZZ
    với tư cách là thành viên duy nhất của danh sách sửa đổi để tuyên bố rằng các công cụ sửa đổi rõ ràng là
    không được hỗ trợ hoặc là một phần của danh sách lớn hơn để khai báo rằng các công cụ sửa đổi ngầm định
    có thể được sử dụng
  - trong quá trình phân bổ, người dùng có thể cung cấp ZZ0001ZZ, dưới dạng
    thành viên duy nhất của danh sách sửa đổi (tương đương với việc không cung cấp danh sách sửa đổi
    chút nào) để tuyên bố rằng các công cụ sửa đổi rõ ràng không được hỗ trợ và không được
    được sử dụng hoặc như một phần của danh sách lớn hơn để khai báo rằng việc phân bổ sử dụng ẩn
    sửa đổi được chấp nhận
  - trong truy vấn sau phân bổ, việc triển khai có thể trả về
    ZZ0002ZZ làm công cụ sửa đổi bộ đệm được phân bổ để khai báo
    rằng bố cục cơ bản được xác định theo cách triển khai và một cách rõ ràng
    mô tả sửa đổi không có sẵn; theo các quy tắc trên, điều này chỉ có thể
    được trả về khi người dùng đã đưa ZZ0003ZZ vào như một phần của
    danh sách các sửa đổi được chấp nhận hoặc không được cung cấp danh sách
  - khi nhập bộ đệm, người dùng có thể cung cấp ZZ0004ZZ làm
    công cụ sửa đổi bộ đệm (hoặc không cung cấp công cụ sửa đổi) để chỉ ra rằng công cụ sửa đổi là
    không rõ vì lý do gì; điều này chỉ được chấp nhận khi bộ đệm có
    không được phân bổ với một công cụ sửa đổi rõ ràng

Từ đó, đối với bất kỳ bộ đệm đơn nào, chuỗi hoạt động hoàn chỉnh
được hình thành bởi nhà sản xuất và tất cả người tiêu dùng phải hoàn toàn ngầm hiểu hoặc hoàn toàn
rõ ràng. Ví dụ: nếu người dùng muốn phân bổ bộ đệm để sử dụng giữa
GPU, màn hình và phương tiện, nhưng phương tiện API không hỗ trợ sửa đổi, thì
người dùng ZZ0000ZZ phân bổ bộ đệm bằng các công cụ sửa đổi rõ ràng và cố gắng
nhập bộ đệm vào phương tiện API mà không cần sửa đổi nhưng thực hiện
phân bổ bằng cách sử dụng công cụ sửa đổi ngầm định hoặc phân bổ bộ đệm để sử dụng phương tiện
riêng biệt và sao chép giữa hai bộ đệm.

Là một ngoại lệ đối với trường hợp trên, việc phân bổ có thể được 'nâng cấp' từ ngầm định
để sửa đổi rõ ràng. Ví dụ: nếu bộ đệm được phân bổ với
ZZ0000ZZ (không sử dụng công cụ sửa đổi), sau đó người dùng có thể truy vấn công cụ sửa đổi bằng
ZZ0001ZZ và sau đó sử dụng công cụ sửa đổi này làm mã thông báo sửa đổi rõ ràng
nếu một sửa đổi hợp lệ được trả về.

Khi phân bổ bộ đệm để trao đổi giữa những người dùng và người sửa đổi khác nhau
không có sẵn, việc triển khai được khuyến khích sử dụng
ZZ0000ZZ để phân bổ, vì đây là đường cơ sở chung
để trao đổi. Tuy nhiên, không đảm bảo rằng điều này sẽ dẫn đến kết quả chính xác
giải thích nội dung bộ đệm, vì hoạt động sửa đổi ngầm định vẫn có thể
tùy thuộc vào heuristic của trình điều khiển cụ thể.

Bất kỳ người dùng mới nào - các chương trình và giao thức không gian người dùng, hệ thống con kernel, v.v. -
muốn trao đổi bộ đệm phải cung cấp khả năng tương tác thông qua tệp dma-buf
bộ mô tả cho các mặt phẳng bộ nhớ, mã thông báo định dạng DRM để mô tả định dạng, DRM
công cụ sửa đổi định dạng để mô tả bố cục trong bộ nhớ, ít nhất là chiều rộng và chiều cao cho
kích thước, và ít nhất là offset và sải bước cho mỗi mặt phẳng bộ nhớ.

.. _zwp_linux_dmabuf_v1: https://gitlab.freedesktop.org/wayland/wayland-protocols/-/blob/main/unstable/linux-dmabuf/linux-dmabuf-unstable-v1.xml
.. _VK_EXT_image_drm_format_modifier: https://registry.khronos.org/vulkan/specs/1.3-extensions/man/html/VK_EXT_image_drm_format_modifier.html
.. _EGL_EXT_image_dma_buf_import_modifiers: https://registry.khronos.org/EGL/extensions/EXT/EGL_EXT_image_dma_buf_import_modifiers.txt