.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/dev-overlay.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _overlay:

***********************
Giao diện lớp phủ video
***********************

ZZ0000ZZ

Các thiết bị lớp phủ video có khả năng genlock (TV-)video vào
(VGA-)tín hiệu video của card đồ họa hoặc để lưu trữ hình ảnh đã chụp
trực tiếp trong bộ nhớ video của card đồ họa, thường có tính năng cắt bớt.
Điều này có thể hiệu quả hơn đáng kể so với việc chụp ảnh và
hiển thị chúng bằng các phương tiện khác. Ngày xưa chỉ có điện hạt nhân
các nhà máy cần tháp làm mát, đây từng là cách duy nhất để đưa vào hoạt động
video vào một cửa sổ.

Các thiết bị lớp phủ video được truy cập thông qua cùng một ký tự đặc biệt
các tập tin dưới dạng thiết bị ZZ0000ZZ.

.. note::

   The default function of a ``/dev/video`` device is video
   capturing. The overlay function is only available after calling
   the :ref:`VIDIOC_S_FMT <VIDIOC_G_FMT>` ioctl.

Trình điều khiển có thể hỗ trợ lớp phủ và chụp đồng thời bằng cách sử dụng
đọc/ghi và truyền phát các phương thức I/O. Nếu vậy, hoạt động ở mức danh nghĩa
tốc độ khung hình của tiêu chuẩn video không được đảm bảo. Các khung có thể
hướng từ lớp phủ sang chụp hoặc một trường có thể được sử dụng cho
lớp phủ và cái còn lại để chụp nếu các tham số chụp cho phép điều này.

Các ứng dụng nên sử dụng các bộ mô tả tệp khác nhau để thu thập và
lớp phủ. Điều này phải được hỗ trợ bởi tất cả các trình điều khiển có khả năng đồng thời
chụp và phủ. Tùy chọn các trình điều khiển này cũng có thể cho phép
chụp và phủ bằng một bộ mô tả tệp duy nhất để tương thích
với V4L và các phiên bản V4L2 trước đó. [#f1]_

Một ứng dụng phổ biến của hai bộ mô tả tệp là X11
Trình điều khiển giao diện ZZ0000ZZ và ứng dụng V4L2.
Trong khi máy chủ X kiểm soát lớp phủ video, ứng dụng có thể mất
lợi thế của ánh xạ bộ nhớ và DMA.

Khả năng truy vấn
=====================

Các thiết bị hỗ trợ giao diện lớp phủ video đặt
Cờ ZZ0002ZZ trong trường ZZ0003ZZ của cấu trúc
ZZ0000ZZ được trả lại bởi
ZZ0001ZZ ioctl. I/O lớp phủ
phương pháp được chỉ định dưới đây phải được hỗ trợ. Bộ điều chỉnh và đầu vào âm thanh được
tùy chọn.


Chức năng bổ sung
======================

Các thiết bị lớp phủ video sẽ hỗ trợ ZZ0000ZZ,
ZZ0001ZZ, ZZ0002ZZ,
ZZ0003ZZ và
ZZ0004ZZ ioctls khi cần thiết. các
ZZ0005ZZ và ZZ0006ZZ
ioctls phải được hỗ trợ bởi tất cả các thiết bị lớp phủ video.


Cài đặt
=======

ZZ0003ZZ
Trước khi lớp phủ có thể bắt đầu, các ứng dụng phải lập trình trình điều khiển với
tham số bộ đệm khung, cụ thể là địa chỉ và kích thước của bộ đệm khung
và định dạng hình ảnh, ví dụ RGB 5:6:5. các
ZZ0000ZZ và
ZZ0001ZZ ioctls có sẵn để nhận và
thiết lập các thông số này tương ứng. ZZ0002ZZ ioctl là
đặc quyền vì nó cho phép thiết lập DMA vào bộ nhớ vật lý,
bỏ qua cơ chế bảo vệ bộ nhớ của kernel. Chỉ có
superuser có thể thay đổi địa chỉ và kích thước bộ đệm khung. Người dùng không
phải chạy các ứng dụng TV với quyền root hoặc với bộ bit SUID. Một cái nhỏ
ứng dụng trợ giúp có đặc quyền phù hợp sẽ truy vấn đồ họa
hệ thống và lập trình trình điều khiển V4L2 vào thời điểm thích hợp.

Một số thiết bị thêm lớp phủ video vào tín hiệu đầu ra của đồ họa
thẻ. Trong trường hợp này, bộ đệm khung không bị thiết bị video sửa đổi,
và địa chỉ bộ đệm khung cũng như định dạng pixel không cần thiết bởi
người lái xe. ZZ0000ZZ ioctl không có đặc quyền. Một ứng dụng
có thể kiểm tra loại thiết bị này bằng cách gọi ZZ0001ZZ
ioctl.

Trình điều khiển có thể hỗ trợ bất kỳ (hoặc không hỗ trợ) bất kỳ phương pháp nào trong năm phương pháp cắt/trộn:

1. Khóa sắc độ chỉ hiển thị hình ảnh được phủ ở nơi có các pixel trong
   bề mặt đồ họa chính có một màu nhất định.

2. ZZ0000ZZ
   Một bitmap có thể được chỉ định trong đó mỗi bit tương ứng với một pixel trong
   hình ảnh được phủ lên. Khi bit được đặt, video tương ứng
   pixel được hiển thị, nếu không thì sẽ là pixel của bề mặt đồ họa.

3. ZZ0000ZZ
   Một danh sách các hình chữ nhật cắt có thể được chỉ định. Ở những vùng này ZZ0001ZZ
   video được hiển thị, do đó bề mặt đồ họa có thể được nhìn thấy ở đây.

4. Bộ đệm khung có một kênh alpha có thể được sử dụng để cắt hoặc
   trộn bộ đệm khung với video.

5. Giá trị alpha toàn cục có thể được chỉ định để trộn bộ đệm khung
   nội dung có hình ảnh video.

Khi hỗ trợ chụp và phủ đồng thời và phần cứng
cấm các định dạng bộ đệm khung và hình ảnh khác nhau, định dạng được yêu cầu
đầu tiên được ưu tiên. Nỗ lực nắm bắt
(ZZ0000ZZ) hoặc lớp phủ
(ZZ0001ZZ) có thể bị lỗi với lỗi ZZ0002ZZ
mã hoặc trả về các tham số đã sửa đổi tương ứng ..


Cửa sổ lớp phủ
==============

Hình ảnh phủ được xác định bằng cửa sổ cắt xén và lớp phủ
các thông số. Trước đây chọn một khu vực của hình ảnh video để chụp,
sau này là cách hình ảnh được phủ và cắt bớt. Khởi tạo cắt xén
tối thiểu yêu cầu đặt lại các tham số về mặc định. Một ví dụ là
được đưa ra trong ZZ0000ZZ.

Cửa sổ lớp phủ được mô tả bằng cấu trúc
ZZ0000ZZ. Nó xác định kích thước của hình ảnh,
vị trí của nó trên bề mặt đồ họa và phần cắt được áp dụng.
Để có được các ứng dụng tham số hiện tại, hãy đặt trường ZZ0004ZZ của
cấu trúc ZZ0001ZZ thành
ZZ0005ZZ và gọi
ZZ0002ZZ ioctl. Người lái xe điền vào
cấu trúc con ZZ0003ZZ có tên ZZ0006ZZ. Nó không phải
có thể truy xuất danh sách cắt hoặc bitmap đã được lập trình trước đó.

Để lập trình các ứng dụng cửa sổ lớp phủ, hãy đặt trường ZZ0006ZZ của
cấu trúc ZZ0000ZZ thành
ZZ0007ZZ, khởi tạo cấu trúc con ZZ0008ZZ và
gọi ZZ0001ZZ ioctl. Người lái xe
điều chỉnh các tham số theo giới hạn phần cứng và trả về giá trị thực tế
các thông số như ZZ0002ZZ. Giống như ZZ0003ZZ,
ZZ0004ZZ ioctl có thể được sử dụng để học
về khả năng của trình điều khiển mà không thực sự thay đổi trạng thái trình điều khiển. Không giống
ZZ0005ZZ tính năng này cũng hoạt động sau khi lớp phủ được bật.

Hệ số tỷ lệ của hình ảnh được phủ được ngụ ý bởi chiều rộng và
chiều cao được cho trong cấu trúc ZZ0000ZZ và kích thước
của hình chữ nhật cắt xén. Để biết thêm thông tin, hãy xem ZZ0001ZZ.

Khi hỗ trợ chụp và phủ đồng thời và phần cứng
cấm các kích thước hình ảnh và cửa sổ khác nhau, kích thước được yêu cầu trước tiên
được ưu tiên. Nỗ lực nắm bắt hoặc che phủ cũng
(ZZ0000ZZ) có thể bị lỗi với lỗi ZZ0001ZZ
mã hoặc trả về các tham số đã sửa đổi tương ứng.


.. c:type:: v4l2_window

cấu trúc v4l2_window
--------------------

ZZ0001ZZ
    Kích thước và vị trí của cửa sổ so với góc trên, bên trái của
    bộ đệm khung được xác định bằng
    ZZ0000ZZ. Cửa sổ có thể mở rộng
    chiều rộng và chiều cao của bộ đệm khung, tọa độ ZZ0002ZZ và ZZ0003ZZ có thể
    âm và nó có thể nằm hoàn toàn bên ngoài vùng đệm khung. các
    trình điều khiển sẽ cắt cửa sổ cho phù hợp hoặc nếu điều đó là không thể,
    sửa đổi kích thước và/hoặc vị trí của nó.

ZZ0000ZZ
    Các ứng dụng đặt trường này để xác định trường video nào sẽ được
    được phủ lên, thường là một trong ZZ0001ZZ (0),
    ZZ0002ZZ, ZZ0003ZZ hoặc
    ZZ0004ZZ. Người lái xe có thể phải chọn phương án khác
    thứ tự trường và trả về cài đặt thực tế tại đây.

ZZ0003ZZ
    Khi khóa sắc độ đã được thương lượng với
    Các ứng dụng ZZ0000ZZ thiết lập trường này
    đến giá trị pixel mong muốn cho phím sắc độ. Định dạng là
    giống như định dạng pixel của bộ đệm khung (struct
    ZZ0001ZZ ZZ0004ZZ
    trường), với các byte theo thứ tự máy chủ. Ví dụ. cho
    ZZ0002ZZ giá trị nên
    là 0xRRGGBB trên máy chủ endian nhỏ, 0xBBGGRR trên máy chủ endian lớn.

ZZ0001ZZ
    ZZ0002ZZ
    Khi khóa sắc độ đã ZZ0003ZZ được thương lượng và
    ZZ0000ZZ chỉ ra khả năng này,
    các ứng dụng có thể đặt trường này để trỏ đến một mảng cắt
    hình chữ nhật.

Giống như tọa độ cửa sổ w, việc cắt các hình chữ nhật được xác định
    so với góc trên, bên trái của bộ đệm khung. Tuy nhiên
    cắt hình chữ nhật không được mở rộng chiều rộng bộ đệm khung và
    chiều cao và chúng không được chồng lên nhau. Nếu có thể ứng dụng
    nên hợp nhất các hình chữ nhật liền kề. Liệu điều này có phải tạo ra
    Các dải x-y hoặc y-x hoặc thứ tự hình chữ nhật không được xác định. Khi nào
    danh sách clip không được hỗ trợ, trình điều khiển sẽ bỏ qua trường này. của nó
    nội dung sau khi gọi ZZ0000ZZ
    không được xác định.

ZZ0001ZZ
    ZZ0003ZZ
    Khi ứng dụng đặt trường ZZ0002ZZ, trường này phải
    chứa số lượng hình chữ nhật cắt trong danh sách. Khi clip
    danh sách không được hỗ trợ trình điều khiển bỏ qua trường này, nội dung của nó
    sau khi gọi ZZ0000ZZ đều không được xác định. Khi danh sách clip được
    được hỗ trợ nhưng không muốn cắt bớt, trường này phải được đặt thành 0.

ZZ0001ZZ
    ZZ0002ZZ
    Khi khóa sắc độ đã ZZ0003ZZ được thương lượng và
    ZZ0000ZZ chỉ ra khả năng này,
    các ứng dụng có thể đặt trường này để trỏ đến mặt nạ bit cắt.

Nó phải có cùng kích thước với cửa sổ, ZZ0000ZZ và ZZ0001ZZ.
Mỗi bit tương ứng với một pixel trong ảnh được phủ, đó là
chỉ hiển thị khi bit là ZZ0002ZZ. Tọa độ pixel dịch sang
bit như:


.. code-block:: c

    ((__u8 *) bitmap)[w.width * y + x / 8] & (1 << (x & 7))

trong đó ZZ0000ZZ ≤ x < ZZ0001ZZ và ZZ0002ZZ ≤ y <ZZ0003ZZ. [#f2]_

Khi mặt nạ bit cắt không được hỗ trợ, trình điều khiển sẽ bỏ qua trường này,
nội dung của nó sau khi gọi ZZ0000ZZ là
không xác định. Khi mặt nạ bit được hỗ trợ nhưng không cần cắt bớt
trường phải được đặt thành ZZ0001ZZ.

Ứng dụng không cần tạo danh sách clip hoặc mặt nạ bit. Khi họ đi qua
cả hai, hoặc mặc dù đã đàm phán về khóa sắc độ, kết quả vẫn không được xác định.
Bất kể phương pháp nào được chọn, khả năng cắt của phần cứng
có thể bị hạn chế về số lượng hoặc chất lượng. Kết quả khi các giới hạn này được
vượt quá là không xác định. [#f3]_

ZZ0002ZZ
    Giá trị alpha chung được sử dụng để trộn bộ đệm khung với video
    hình ảnh, nếu việc trộn alpha toàn cầu đã được thương lượng
    (ZZ0003ZZ, xem
    ZZ0000ZZ,
    ZZ0001ZZ).

.. note::

   This field was added in Linux 2.6.23, extending the
   structure. However the :ref:`VIDIOC_[G|S|TRY]_FMT <VIDIOC_G_FMT>`
   ioctls, which take a pointer to a :c:type:`v4l2_format`
   parent structure with padding bytes at the end, are not affected.


.. c:type:: v4l2_clip

cấu trúc v4l2_clip [#f4]_
-------------------------

ZZ0000ZZ
    Tọa độ của hình chữ nhật cắt, so với phần trên, bên trái
    góc của bộ đệm khung. Chỉ các pixel cửa sổ ZZ0001ZZ tất cả
    hình chữ nhật cắt được hiển thị.

ZZ0000ZZ
    Con trỏ tới hình chữ nhật cắt tiếp theo, ZZ0001ZZ khi đây là hình cuối cùng
    hình chữ nhật. Trình điều khiển bỏ qua trường này, nó không thể được sử dụng để vượt qua
    danh sách liên kết của các hình chữ nhật cắt.


.. c:type:: v4l2_rect

cấu trúc v4l2_orth
------------------

ZZ0000ZZ
    Độ lệch ngang của góc trên, bên trái của hình chữ nhật, trong
    pixel.

ZZ0000ZZ
    Độ lệch dọc của góc trên, bên trái của hình chữ nhật, tính bằng pixel.
    Độ lệch tăng dần sang phải và xuống.

ZZ0000ZZ
    Chiều rộng của hình chữ nhật, tính bằng pixel.

ZZ0000ZZ
    Chiều cao của hình chữ nhật, tính bằng pixel.


Kích hoạt lớp phủ
=================

Để bắt đầu hoặc dừng các ứng dụng lớp phủ bộ đệm khung, hãy gọi phương thức
ZZ0000ZZ ioctl.

.. [#f1]
   In the opinion of the designers of this API, no driver writer taking
   the efforts to support simultaneous capturing and overlay will
   restrict this ability by requiring a single file descriptor, as in
   V4L and earlier versions of V4L2. Making this optional means
   applications depending on two file descriptors need backup routines
   to be compatible with all drivers, which is considerable more work
   than using two fds in applications which do not. Also two fd's fit
   the general concept of one file descriptor for each logical stream.
   Hence as a complexity trade-off drivers *must* support two file
   descriptors and *may* support single fd operation.

.. [#f2]
   Should we require ``w.width`` to be a multiple of eight?

.. [#f3]
   When the image is written into frame buffer memory it will be
   undesirable if the driver clips out less pixels than expected,
   because the application and graphics system are not aware these
   regions need to be refreshed. The driver should clip out more pixels
   or not write the image at all.

.. [#f4]
   The X Window system defines "regions" which are vectors of ``struct
   BoxRec { short x1, y1, x2, y2; }`` with ``width = x2 - x1`` and
   ``height = y2 - y1``, so one cannot pass X11 clip lists directly.