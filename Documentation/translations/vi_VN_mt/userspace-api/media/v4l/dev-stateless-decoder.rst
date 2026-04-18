.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/dev-stateless-decoder.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _stateless_decoder:

****************************************************
Giao diện bộ giải mã video không trạng thái từ bộ nhớ đến bộ nhớ
**************************************************

Bộ giải mã không trạng thái là bộ giải mã hoạt động mà không giữ lại bất kỳ loại trạng thái nào
giữa các khung đã được xử lý. Điều này có nghĩa là mỗi khung hình được giải mã độc lập
của bất kỳ khung nào trước đây và tương lai, và khách hàng chịu trách nhiệm về
duy trì trạng thái giải mã và cung cấp nó cho bộ giải mã với mỗi
yêu cầu giải mã. Điều này trái ngược với giao diện bộ giải mã video có trạng thái,
nơi phần cứng và trình điều khiển duy trì trạng thái giải mã và tất cả máy khách
phải làm là cung cấp luồng được mã hóa thô và khung được giải mã dequeue trong
thứ tự hiển thị.

Phần này mô tả cách không gian người dùng ("máy khách") dự kiến sẽ giao tiếp
với bộ giải mã không trạng thái để giải mã thành công luồng được mã hóa.
So với các codec có trạng thái, trình tự bộ giải mã/máy khách đơn giản hơn, nhưng
chi phí của sự đơn giản này là sự phức tạp cao hơn ở khách hàng chịu trách nhiệm
để duy trì trạng thái giải mã nhất quán.

Bộ giải mã không trạng thái sử dụng ZZ0000ZZ. Một người không quốc tịch
bộ giải mã phải thể hiện khả năng ZZ0003ZZ trên
ZZ0004ZZ xếp hàng khi ZZ0001ZZ hoặc ZZ0002ZZ
được gọi.

Tùy thuộc vào các định dạng mã hóa được bộ giải mã hỗ trợ, một
khung có thể là kết quả của một số yêu cầu giải mã (ví dụ: luồng H.264
với nhiều lát trên mỗi khung). Bộ giải mã hỗ trợ các định dạng như vậy cũng phải
bộc lộ khả năng ZZ0000ZZ trên
Hàng đợi ZZ0001ZZ.

Khả năng truy vấn
=====================

1. Để liệt kê tập hợp các định dạng mã hóa được bộ giải mã hỗ trợ, máy khách
   gọi ZZ0000ZZ trên hàng đợi ZZ0001ZZ.

* Trình điều khiển phải luôn trả về đầy đủ các định dạng ZZ0000ZZ được hỗ trợ,
     bất kể định dạng hiện được đặt trên hàng đợi ZZ0001ZZ.

* Đồng thời, trình điều khiển phải hạn chế tập hợp các giá trị được trả về bởi
     điều khiển khả năng dành riêng cho codec (chẳng hạn như cấu hình H.264) cho bộ
     thực sự được hỗ trợ bởi phần cứng.

2. Để liệt kê tập hợp các định dạng thô được hỗ trợ, máy khách gọi
   ZZ0000ZZ trên hàng đợi ZZ0001ZZ.

* Trình điều khiển chỉ được trả về các định dạng được hỗ trợ cho định dạng hiện tại
     hoạt động trên hàng đợi ZZ0000ZZ.

* Tùy thuộc vào định dạng ZZ0000ZZ hiện được đặt, bộ tệp thô được hỗ trợ
     các định dạng có thể phụ thuộc vào giá trị của một số điều khiển phụ thuộc vào codec.
     Khách hàng có trách nhiệm đảm bảo rằng các biện pháp kiểm soát này được thiết lập
     trước khi truy vấn hàng đợi ZZ0001ZZ. Nếu không làm như vậy sẽ dẫn đến
     các giá trị mặc định cho các điều khiển này đang được sử dụng và một tập hợp các định dạng được trả về
     có thể không sử dụng được cho phương tiện mà khách hàng đang cố giải mã.

3. Máy khách có thể sử dụng ZZ0000ZZ để phát hiện các thiết bị được hỗ trợ
   độ phân giải cho một định dạng nhất định, chuyển định dạng pixel mong muốn sang
   ZZ0002ZZ của ZZ0001ZZ.

4. Cấu hình và cấp độ được hỗ trợ cho định dạng ZZ0001ZZ hiện tại, nếu
   có thể áp dụng, có thể được truy vấn bằng cách sử dụng các điều khiển tương ứng của họ thông qua
   ZZ0000ZZ.

Khởi tạo
==============

1. Đặt định dạng được mã hóa trên hàng đợi ZZ0001ZZ thông qua ZZ0000ZZ.

* ZZ0000ZZ

ZZ0000ZZ
         một enum ZZ0001ZZ thích hợp cho ZZ0002ZZ.

ZZ0000ZZ
         một định dạng pixel được mã hóa.

ZZ0000ZZ, ZZ0001ZZ
         chiều rộng và chiều cao được mã hóa được phân tích cú pháp từ luồng.

các lĩnh vực khác
         tuân theo ngữ nghĩa tiêu chuẩn.

   .. note::

      Changing the ``OUTPUT`` format may change the currently set ``CAPTURE``
      format. The driver will derive a new ``CAPTURE`` format from the
      ``OUTPUT`` format being set, including resolution, colorimetry
      parameters, etc. If the client needs a specific ``CAPTURE`` format,
      it must adjust it afterwards.

2. Gọi ZZ0000ZZ để đặt tất cả các điều khiển (tiêu đề được phân tích cú pháp,
   v.v.) theo yêu cầu của định dạng ZZ0001ZZ để liệt kê các định dạng ZZ0002ZZ.

3. Gọi ZZ0000ZZ cho hàng đợi ZZ0001ZZ để nhận định dạng cho
   bộ đệm đích được phân tích/giải mã từ dòng byte.

* ZZ0000ZZ

ZZ0000ZZ
         một enum ZZ0001ZZ thích hợp cho ZZ0002ZZ.

* ZZ0000ZZ

ZZ0000ZZ, ZZ0001ZZ
         độ phân giải bộ đệm khung cho các khung được giải mã.

ZZ0000ZZ
         định dạng pixel cho khung được giải mã.

ZZ0000ZZ (chỉ dành cho _MPLANE ZZ0001ZZ)
         số lượng mặt phẳng cho định dạng pixel.

ZZ0000ZZ, ZZ0001ZZ
         theo ngữ nghĩa tiêu chuẩn; định dạng bộ đệm khung phù hợp.

   .. note::

      The value of ``pixelformat`` may be any pixel format supported for the
      ``OUTPUT`` format, based on the hardware capabilities. It is suggested
      that the driver chooses the preferred/optimal format for the current
      configuration. For example, a YUV format may be preferred over an RGB
      format, if an additional conversion step would be required for RGB.

4. ZZ0005ZZ Liệt kê các định dạng ZZ0002ZZ thông qua ZZ0000ZZ trên
   hàng đợi ZZ0003ZZ. Khách hàng có thể sử dụng ioctl này để khám phá
   các định dạng thô thay thế được hỗ trợ cho định dạng ZZ0004ZZ hiện tại và
   chọn một trong số chúng thông qua ZZ0001ZZ.

   .. note::

      The driver will return only formats supported for the currently selected
      ``OUTPUT`` format and currently set controls, even if more formats may be
      supported by the decoder in general.

      For example, a decoder may support YUV and RGB formats for
      resolutions 1920x1088 and lower, but only YUV for higher resolutions (due
      to hardware limitations). After setting a resolution of 1920x1088 or lower
      as the ``OUTPUT`` format, :c:func:`VIDIOC_ENUM_FMT` may return a set of
      YUV and RGB pixel formats, but after setting a resolution higher than
      1920x1088, the driver will not return RGB pixel formats, since they are
      unsupported for this resolution.

5. ZZ0004ZZ Chọn định dạng ZZ0002ZZ khác với định dạng được đề xuất qua
   ZZ0000ZZ trên hàng đợi ZZ0003ZZ. Khách hàng có thể
   chọn một định dạng khác với định dạng được chọn/gợi ý bởi trình điều khiển trong
   ZZ0001ZZ.

* ZZ0000ZZ

ZZ0000ZZ
          một enum ZZ0001ZZ thích hợp cho ZZ0002ZZ.

ZZ0000ZZ
          một định dạng pixel thô.

ZZ0001ZZ, ZZ0002ZZ
         độ phân giải bộ đệm khung của luồng được giải mã; thường không thay đổi so với
         những gì đã được trả lại với ZZ0000ZZ, nhưng nó có thể khác
         liệu phần cứng có hỗ trợ bố cục và/hoặc chia tỷ lệ hay không.

Sau khi thực hiện bước này, khách hàng phải thực hiện lại bước 3 để
   để có được thông tin cập nhật về kích thước và bố cục bộ đệm.

6. Phân bổ bộ đệm nguồn (dòng byte) qua ZZ0000ZZ trên
   Hàng đợi ZZ0001ZZ.

* ZZ0000ZZ

ZZ0000ZZ
          số lượng bộ đệm được yêu cầu phân bổ; lớn hơn không.

ZZ0000ZZ
          một enum ZZ0001ZZ thích hợp cho ZZ0002ZZ.

ZZ0000ZZ
          tuân theo ngữ nghĩa tiêu chuẩn.

* ZZ0000ZZ

ZZ0000ZZ
          số lượng bộ đệm thực tế được phân bổ.

* Nếu cần, người lái sẽ điều chỉnh ZZ0000ZZ bằng hoặc lớn hơn
      số lượng bộ đệm ZZ0001ZZ tối thiểu cần thiết cho định dạng đã cho và
      số lượng được yêu cầu. Máy khách phải kiểm tra giá trị này sau khi ioctl trả về
      để có được số lượng bộ đệm thực tế được phân bổ.

7. Phân bổ bộ đệm đích (định dạng thô) thông qua ZZ0000ZZ trên
   Hàng đợi ZZ0001ZZ.

* ZZ0000ZZ

ZZ0000ZZ
          số lượng bộ đệm được yêu cầu phân bổ; lớn hơn không. khách hàng
          chịu trách nhiệm suy ra số lượng bộ đệm tối thiểu cần thiết
          để luồng được giải mã chính xác (lấy ví dụ: khung tham chiếu
          vào tài khoản) và chuyển một số bằng hoặc lớn hơn.

ZZ0000ZZ
          một enum ZZ0001ZZ thích hợp cho ZZ0002ZZ.

ZZ0000ZZ
          tuân theo ngữ nghĩa tiêu chuẩn. ZZ0001ZZ không được hỗ trợ
          cho bộ đệm ZZ0002ZZ.

* ZZ0000ZZ

ZZ0000ZZ
          được điều chỉnh theo số lượng bộ đệm được phân bổ, trong trường hợp codec yêu cầu
          nhiều bộ đệm hơn yêu cầu.

* Người lái xe phải điều chỉnh số lượng tối thiểu theo yêu cầu
      Bộ đệm ZZ0000ZZ cho định dạng hiện tại, cấu hình luồng và
      số lượng được yêu cầu. Khách hàng phải kiểm tra giá trị này sau ioctl
      trả về để lấy số lượng bộ đệm được phân bổ.

8. Phân bổ các yêu cầu (có thể là một yêu cầu cho mỗi bộ đệm ZZ0001ZZ) thông qua
    ZZ0000ZZ trên thiết bị media.

9. Bắt đầu phát trực tuyến trên cả hàng đợi ZZ0001ZZ và ZZ0002ZZ qua
    ZZ0000ZZ.

Giải mã
========

Với mỗi khung, client có trách nhiệm gửi ít nhất một yêu cầu tới
được đính kèm sau đây:

* Lượng dữ liệu được mã hóa mà codec mong đợi cho hiện tại của nó
  cấu hình, như một bộ đệm được gửi đến hàng đợi ZZ0000ZZ. Thông thường, điều này
  tương ứng với một khung dữ liệu được mã hóa, nhưng một số định dạng có thể cho phép (hoặc
  yêu cầu) số lượng khác nhau cho mỗi đơn vị.
* Tất cả siêu dữ liệu cần thiết để giải mã dữ liệu được mã hóa đã gửi, dưới dạng
  các điều khiển liên quan đến định dạng được giải mã.

Lượng dữ liệu và nội dung của bộ đệm ZZ0000ZZ nguồn cũng như
các điều khiển phải được đặt theo yêu cầu, tùy thuộc vào pixel được mã hóa đang hoạt động
định dạng và có thể bị ảnh hưởng bởi các điều khiển mở rộng dành riêng cho codec, như đã nêu trong
tài liệu của từng định dạng.

Nếu có khả năng khung được giải mã sẽ yêu cầu một hoặc nhiều
giải mã các yêu cầu sau yêu cầu hiện tại để được tạo ra, sau đó khách hàng
phải đặt cờ ZZ0000ZZ trên ZZ0001ZZ
bộ đệm. Điều này sẽ dẫn đến ZZ0002ZZ được giải mã (có thể một phần)
bộ đệm không được cung cấp để loại bỏ hàng đợi và được sử dụng lại cho lần giải mã tiếp theo
yêu cầu nếu dấu thời gian của bộ đệm ZZ0003ZZ tiếp theo không thay đổi.

Do đó, một khung thông thường sẽ được giải mã theo trình tự sau:

1. Xếp hàng bộ đệm ZZ0001ZZ chứa một đơn vị dữ liệu dòng byte được mã hóa cho
   yêu cầu giải mã, sử dụng ZZ0000ZZ.

* ZZ0000ZZ

ZZ0000ZZ
          chỉ mục của bộ đệm đang được xếp hàng đợi.

ZZ0000ZZ
          loại bộ đệm.

ZZ0000ZZ
          số byte được lấy bởi khung dữ liệu được mã hóa trong bộ đệm.

ZZ0000ZZ
          cờ ZZ0001ZZ phải được đặt. Ngoài ra, nếu
          chúng tôi không chắc chắn rằng yêu cầu giải mã hiện tại là yêu cầu cuối cùng cần thiết
          để tạo ra một khung được giải mã hoàn toàn, sau đó
          ZZ0002ZZ cũng phải được đặt.

ZZ0000ZZ
          phải được đặt thành bộ mô tả tệp của yêu cầu giải mã.

ZZ0000ZZ
          phải được đặt thành một giá trị duy nhất cho mỗi khung. Giá trị này sẽ được truyền bá
          vào bộ đệm của khung được giải mã và cũng có thể được sử dụng để sử dụng khung này
          như tài liệu tham khảo của người khác. Nếu sử dụng nhiều yêu cầu giải mã cho mỗi
          frame, sau đó là dấu thời gian của tất cả các bộ đệm ZZ0001ZZ cho một khung nhất định
          khung phải giống hệt nhau. Nếu dấu thời gian thay đổi thì hiện tại
          Bộ đệm ZZ0002ZZ được giữ sẽ được cung cấp để loại bỏ hàng đợi và
          yêu cầu hiện tại sẽ hoạt động trên bộ đệm ZZ0003ZZ mới.

2. Đặt các điều khiển dành riêng cho codec cho yêu cầu giải mã bằng cách sử dụng
   ZZ0000ZZ.

* ZZ0000ZZ

ZZ0000ZZ
          phải là ZZ0001ZZ.

ZZ0000ZZ
          phải được đặt thành bộ mô tả tệp của yêu cầu giải mã.

các lĩnh vực khác
          các trường khác được đặt như bình thường khi cài đặt điều khiển. ZZ0000ZZ
          mảng phải chứa tất cả các điều khiển dành riêng cho codec cần thiết để giải mã
          một khung.

   .. note::

      It is possible to specify the controls in different invocations of
      :c:func:`VIDIOC_S_EXT_CTRLS`, or to overwrite a previously set control, as
      long as ``request_fd`` and ``which`` are properly set. The controls state
      at the moment of request submission is the one that will be considered.

   .. note::

      The order in which steps 1 and 2 take place is interchangeable.

3. Gửi yêu cầu bằng cách gọi ZZ0000ZZ trên
   yêu cầu FD.

Nếu yêu cầu được gửi mà không có bộ đệm ZZ0002ZZ hoặc nếu một số
    các điều khiển bắt buộc bị thiếu trong yêu cầu, thì
    ZZ0000ZZ sẽ trả về ZZ0003ZZ. Nếu nhiều hơn một
    Bộ đệm ZZ0004ZZ được xếp hàng đợi, sau đó nó sẽ trả về ZZ0005ZZ.
    ZZ0001ZZ trả về khác 0 có nghĩa là không
    Bộ đệm ZZ0006ZZ sẽ được sản xuất cho yêu cầu này.

Bộ đệm ZZ0000ZZ không được nằm trong yêu cầu và được xếp hàng đợi
một cách độc lập. Chúng được trả về theo thứ tự giải mã (tức là cùng thứ tự với thứ tự được mã hóa
các khung đã được gửi tới hàng đợi ZZ0001ZZ).

Lỗi giải mã thời gian chạy được báo hiệu bởi bộ đệm ZZ0000ZZ đã được loại bỏ hàng đợi
mang cờ ZZ0001ZZ. Nếu khung tham chiếu được giải mã có
lỗi thì tất cả các khung được giải mã sau đây tham chiếu đến nó cũng có
Đã đặt cờ ZZ0002ZZ, mặc dù bộ giải mã vẫn sẽ cố gắng
tạo ra các khung (có thể bị hỏng).

Quản lý bộ đệm trong khi giải mã
================================
Ngược lại với bộ giải mã có trạng thái, bộ giải mã không có trạng thái không thực hiện bất kỳ loại
quản lý bộ đệm: nó chỉ đảm bảo rằng bộ đệm ZZ0000ZZ đã được loại bỏ hàng đợi có thể được
được khách hàng sử dụng miễn là chúng không được xếp hàng đợi nữa. "Đã qua sử dụng" ở đây
bao gồm việc sử dụng bộ đệm để tổng hợp hoặc hiển thị.

Bộ đệm chụp đã được loại bỏ hàng đợi cũng có thể được sử dụng làm khung tham chiếu của bộ đệm khác
bộ đệm.

Một khung được chỉ định làm tham chiếu bằng cách chuyển đổi dấu thời gian của nó thành nano giây,
và lưu trữ nó vào thành viên có liên quan của cấu trúc điều khiển phụ thuộc vào codec.
Chức năng ZZ0000ZZ phải được sử dụng để thực hiện điều đó
chuyển đổi. Dấu thời gian của một khung có thể được sử dụng để tham chiếu nó ngay khi tất cả
đơn vị dữ liệu được mã hóa của nó được gửi thành công đến hàng đợi ZZ0001ZZ.

Bộ đệm đã giải mã chứa khung tham chiếu không được phép sử dụng lại làm bộ giải mã
target cho đến khi tất cả các khung tham chiếu đến nó được giải mã. Cách an toàn nhất để
đạt được điều này là hạn chế việc xếp hàng bộ đệm tham chiếu cho đến khi tất cả
các khung được giải mã tham chiếu đến nó đã bị loại bỏ. Tuy nhiên, nếu người lái xe có thể
đảm bảo rằng các bộ đệm được xếp hàng đợi vào hàng đợi ZZ0000ZZ được xử lý theo hàng đợi
đặt hàng, thì không gian người dùng có thể tận dụng sự đảm bảo này và xếp hàng
bộ đệm tham chiếu khi đáp ứng các điều kiện sau:

1. Tất cả các yêu cầu về khung bị ảnh hưởng bởi khung tham chiếu đã được
   xếp hàng và

2. Số lượng bộ đệm ZZ0000ZZ đủ để bao phủ tất cả các dữ liệu được giải mã
   khung tham chiếu đã được xếp hàng đợi.

Khi xếp hàng yêu cầu giải mã, trình điều khiển sẽ tăng số lượng tham chiếu của
tất cả các tài nguyên liên quan đến khung tham chiếu. Điều này có nghĩa là khách hàng
có thể ví dụ đóng bộ mô tả tệp DMABUF của bộ đệm khung tham chiếu nếu nó
sau này sẽ không cần chúng nữa.

Đang tìm kiếm
=======
Để tìm kiếm, khách hàng chỉ cần gửi yêu cầu bằng cách sử dụng bộ đệm đầu vào
tương ứng với vị trí luồng mới. Tuy nhiên nó phải nhận thức được rằng
độ phân giải có thể đã thay đổi và tuân theo trình tự thay đổi độ phân giải động trong
trường hợp đó. Ngoài ra, tùy thuộc vào codec được sử dụng, các thông số hình ảnh (ví dụ: SPS/PPS
đối với H.264) có thể đã thay đổi và khách hàng có trách nhiệm đảm bảo rằng
trạng thái hợp lệ được gửi đến bộ giải mã.

Sau đó, máy khách có thể tự do bỏ qua mọi bộ đệm ZZ0000ZZ được trả về
từ vị trí tìm kiếm trước.

Tạm dừng
=======

Để tạm dừng, khách hàng chỉ cần ngừng xếp hàng bộ đệm trên ZZ0000ZZ
xếp hàng. Không có dữ liệu dòng byte nguồn thì không có dữ liệu để xử lý và codec
sẽ vẫn nhàn rỗi.

Thay đổi độ phân giải động
=========================

Nếu máy khách phát hiện sự thay đổi độ phân giải trong luồng, nó sẽ cần thực hiện
trình tự khởi tạo lại với độ phân giải mới:

1. Nếu yêu cầu được gửi lần cuối dẫn đến bộ đệm ZZ0000ZZ bị
   được giữ bằng cách sử dụng cờ ZZ0001ZZ, sau đó
   khung cuối cùng không có sẵn trên hàng đợi ZZ0002ZZ. Trong trường hợp này, một
   Lệnh ZZ0003ZZ sẽ được gửi. Điều này sẽ khiến người lái xe
   dequeue bộ đệm ZZ0004ZZ được giữ.

2. Đợi cho đến khi tất cả các yêu cầu được gửi hoàn tất và hủy hàng đợi
   bộ đệm đầu ra tương ứng.

3. Gọi ZZ0000ZZ trên cả ZZ0001ZZ và ZZ0002ZZ
   hàng đợi.

4. Giải phóng tất cả bộ đệm ZZ0001ZZ bằng cách gọi ZZ0000ZZ trên
   Hàng đợi ZZ0002ZZ có số lượng bộ đệm bằng 0.

5. Thực hiện lại trình tự khởi tạo (trừ việc phân bổ
   bộ đệm ZZ0000ZZ), với độ phân giải mới được đặt trên hàng đợi ZZ0001ZZ.
   Lưu ý rằng do hạn chế về độ phân giải, có thể cần phải có định dạng khác
   được chọn trên hàng đợi ZZ0002ZZ.

Làm khô hạn
=====

Nếu yêu cầu được gửi lần cuối dẫn đến bộ đệm ZZ0000ZZ bị
được giữ bằng cách sử dụng cờ ZZ0001ZZ, sau đó
khung cuối cùng không có sẵn trên hàng đợi ZZ0002ZZ. Trong trường hợp này, một
Lệnh ZZ0003ZZ sẽ được gửi. Điều này sẽ khiến người lái xe
dequeue bộ đệm ZZ0004ZZ được giữ.

Sau đó, để thoát luồng trên bộ giải mã không trạng thái, máy khách
chỉ cần đợi cho đến khi tất cả các yêu cầu đã gửi được hoàn thành.