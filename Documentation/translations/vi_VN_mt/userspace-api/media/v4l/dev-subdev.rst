.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/dev-subdev.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _subdev:

**********************
Giao diện thiết bị phụ
**********************

Bản chất phức tạp của các thiết bị V4L2, trong đó phần cứng thường được làm bằng
một số mạch tích hợp cần tương tác với nhau trong một
cách được kiểm soát, dẫn đến trình điều khiển V4L2 phức tạp. Các tài xế thường
phản ánh mô hình phần cứng trong phần mềm và mô hình hóa phần cứng khác nhau
các thành phần dưới dạng khối phần mềm được gọi là thiết bị phụ.

Các thiết bị phụ V4L2 thường là các đối tượng chỉ có kernel. Nếu trình điều khiển V4L2
triển khai thiết bị đa phương tiện API, chúng sẽ tự động kế thừa từ
các đơn vị truyền thông. Các ứng dụng sẽ có thể liệt kê các thiết bị phụ
và khám phá cấu trúc liên kết phần cứng bằng cách sử dụng các thực thể truyền thông, miếng đệm và
liên kết liệt kê API.

Ngoài việc làm cho các thiết bị phụ có thể được phát hiện, người lái xe cũng có thể chọn
làm cho chúng có thể được cấu hình trực tiếp bởi các ứng dụng. Khi cả hai
trình điều khiển thiết bị phụ và trình điều khiển thiết bị V4L2 hỗ trợ điều này, các thiết bị phụ
sẽ có một nút thiết bị ký tự mà trên đó ioctls có thể được gọi tới

- truy vấn, đọc và ghi điều khiển thiết bị phụ

- đăng ký và hủy đăng ký các sự kiện và truy xuất chúng

- đàm phán các định dạng hình ảnh trên các miếng đệm riêng lẻ

- kiểm tra và sửa đổi định tuyến dữ liệu nội bộ giữa các miếng đệm của cùng một thực thể

Các nút thiết bị ký tự thiết bị phụ, được đặt tên theo quy ước
ZZ0000ZZ, sử dụng số chính 81.

Trình điều khiển có thể chọn giới hạn các thiết bị ký tự của thiết bị phụ chỉ hiển thị
các hoạt động không sửa đổi trạng thái thiết bị. Trong trường hợp như vậy, các thiết bị phụ
được gọi là ZZ0000ZZ trong phần còn lại của tài liệu này và
các hạn chế liên quan được ghi lại trong ioctls riêng lẻ.


Điều khiển
==========

Hầu hết các điều khiển V4L2 được triển khai bằng phần cứng thiết bị phụ. Trình điều khiển
thường hợp nhất tất cả các điều khiển và hiển thị chúng thông qua các nút thiết bị video.
Các ứng dụng có thể điều khiển tất cả các thiết bị phụ thông qua một giao diện duy nhất.

Các thiết bị phức tạp đôi khi thực hiện cùng một điều khiển ở các phần khác nhau
của phần cứng. Tình trạng này phổ biến trong các nền tảng nhúng, trong đó cả hai
cảm biến và phần cứng xử lý hình ảnh thực hiện các chức năng giống hệt nhau,
chẳng hạn như điều chỉnh độ tương phản, cân bằng trắng hoặc chỉnh sửa pixel bị lỗi.
Vì V4L2 điều khiển API không hỗ trợ một số điều khiển giống hệt nhau trong một
thiết bị duy nhất, tất cả ngoại trừ một trong những điều khiển giống hệt nhau đều bị ẩn.

Các ứng dụng có thể truy cập các điều khiển ẩn đó thông qua thiết bị phụ
nút có điều khiển V4L2 API được mô tả trong ZZ0000ZZ. các ioctls
hoạt động giống hệt như khi được phát hành trên các nút thiết bị V4L2, với
ngoại lệ là họ chỉ giải quyết các biện pháp kiểm soát được thực hiện trong
thiết bị phụ.

Tùy thuộc vào trình điều khiển, những điều khiển đó cũng có thể được hiển thị thông qua
một (hoặc một số) nút thiết bị V4L2.


Sự kiện
=======

Các thiết bị phụ V4L2 có thể thông báo cho ứng dụng về các sự kiện như được mô tả trong
ZZ0000ZZ. API hoạt động giống hệt như khi được sử dụng trên thiết bị V4L2
các nút, ngoại trừ việc nó chỉ xử lý các sự kiện được tạo bởi
thiết bị phụ. Tùy thuộc vào trình điều khiển, những sự kiện đó cũng có thể
được báo cáo trên một (hoặc một số) nút thiết bị V4L2.


.. _pad-level-formats:

Định dạng cấp độ pad
====================

.. warning::

    Pad-level formats are only applicable to very complex devices that
    need to expose low-level format configuration to user space. Generic
    V4L2 applications do *not* need to use the API described in this
    section.

.. note::

    For the purpose of this section, the term *format* means the
    combination of media bus data format, frame width and frame height.

Các định dạng hình ảnh thường được thương lượng khi quay và xuất video
các thiết bị sử dụng định dạng và
ZZ0000ZZ ioctls. Người lái xe là
chịu trách nhiệm định cấu hình mọi khối trong đường dẫn video theo
theo định dạng được yêu cầu ở đầu vào và/hoặc đầu ra của đường ống.

Đối với các thiết bị phức tạp, chẳng hạn như thường thấy trong các hệ thống nhúng,
kích thước hình ảnh ở đầu ra của một đường ống có thể đạt được bằng cách sử dụng các kích thước khác nhau
các cấu hình phần cứng. Một ví dụ như vậy được hiển thị trên
ZZ0000ZZ, nơi có thể thực hiện chia tỷ lệ hình ảnh trên cả hai
cảm biến video và phần cứng xử lý hình ảnh máy chủ.


.. _pipeline-scaling:

.. kernel-figure:: pipeline.dot
    :alt:   pipeline.dot
    :align: center

    Image Format Negotiation on Pipelines

    High quality and high speed pipeline configuration



Bộ chia tỷ lệ cảm biến thường có chất lượng kém hơn bộ chia tỷ lệ máy chủ, nhưng
Cần phải chia tỷ lệ trên cảm biến để đạt được tốc độ khung hình cao hơn.
Tùy thuộc vào trường hợp sử dụng (chất lượng và tốc độ), quy trình phải được
được cấu hình khác nhau. Các ứng dụng cần cấu hình các định dạng tại
mọi điểm trong đường ống một cách rõ ràng.

Trình điều khiển triển khai ZZ0000ZZ
có thể hiển thị cấu hình định dạng hình ảnh cấp độ pad cho các ứng dụng. Khi nào
họ làm vậy, các ứng dụng có thể sử dụng
ZZ0001ZZ và
ZZ0002ZZ ioctls. để
đàm phán các định dạng trên cơ sở mỗi pad.

Các ứng dụng chịu trách nhiệm cấu hình các thông số nhất quán trên
toàn bộ đường ống và đảm bảo rằng các miếng đệm được kết nối có khả năng tương thích
các định dạng. Đường ống được kiểm tra các định dạng không khớp tại
Thời gian ZZ0000ZZ và lỗi ZZ0001ZZ
mã sau đó được trả về nếu cấu hình không hợp lệ.

Hỗ trợ cấu hình định dạng hình ảnh cấp độ pad có thể được kiểm tra bằng cách gọi
ZZ0000ZZ ioctl trên pad
0. Nếu trình điều khiển trả về định dạng cấp độ bảng mã lỗi ZZ0001ZZ
cấu hình không được thiết bị phụ hỗ trợ.


Định dạng đàm phán
------------------

Các định dạng được chấp nhận trên miếng đệm có thể (và thường là như vậy) phụ thuộc vào một số
các tham số bên ngoài, chẳng hạn như các định dạng trên các phần đệm khác, các liên kết hoạt động hoặc
thậm chí cả điều khiển. Tìm sự kết hợp của các định dạng trên tất cả các miếng đệm trong video
đường dẫn, được cả ứng dụng và trình điều khiển chấp nhận, không thể dựa vào
chỉ định dạng liệt kê. Cần có cơ chế đàm phán định dạng.

Trọng tâm của cơ chế đàm phán định dạng là định dạng get/set
hoạt động. Khi được gọi với đối số ZZ0003ZZ được đặt thành
ZZ0000ZZ,
ZZ0001ZZ và
ZZ0002ZZ ioctls hoạt động trên
một tập hợp các tham số định dạng không được kết nối với phần cứng
cấu hình. Việc sửa đổi các định dạng 'thử' đó sẽ để lại trạng thái thiết bị
nguyên vẹn (điều này áp dụng cho cả trạng thái phần mềm được lưu trong trình điều khiển
và trạng thái phần cứng được lưu trữ trong chính thiết bị).

Mặc dù không được lưu giữ như một phần của trạng thái thiết bị, các định dạng thử được lưu trữ trong
tập tin thiết bị phụ xử lý. A
Cuộc gọi ZZ0000ZZ sẽ quay lại
bộ định dạng thử cuối cùng ZZ0001ZZ. Một số
do đó các ứng dụng truy vấn cùng một thiết bị phụ cùng lúc sẽ không
tương tác với nhau.

Để tìm hiểu xem một định dạng cụ thể có được thiết bị hỗ trợ hay không,
các ứng dụng sử dụng
ZZ0000ZZ ioctl. Trình điều khiển
xác minh và, nếu cần, thay đổi ZZ0001ZZ được yêu cầu dựa trên thiết bị
yêu cầu và trả về giá trị có thể được sửa đổi. Ứng dụng có thể
sau đó chọn thử định dạng khác hoặc chấp nhận giá trị trả về và
tiếp tục.

Các định dạng được trình điều khiển trả về trong quá trình lặp lại đàm phán là
đảm bảo được hỗ trợ bởi thiết bị. Đặc biệt, tài xế
đảm bảo rằng định dạng trả về sẽ không bị thay đổi thêm nếu được thông qua
tới cuộc gọi ZZ0000ZZ nguyên trạng
(miễn là các tham số bên ngoài, chẳng hạn như định dạng trên các phần đệm hoặc liên kết khác'
cấu hình không thay đổi).

Trình điều khiển tự động truyền bá các định dạng bên trong các thiết bị phụ. Khi thử
hoặc định dạng hoạt động được đặt trên một bảng, các định dạng tương ứng trên các bảng khác của
trình điều khiển có thể sửa đổi cùng một thiết bị phụ. Người lái xe được tự do
sửa đổi các định dạng theo yêu cầu của thiết bị. Tuy nhiên, họ phải tuân thủ
với các quy tắc sau khi có thể:

- Các định dạng cần được truyền bá từ sink pad đến source pad. sửa đổi
   định dạng trên bảng nguồn không được sửa đổi định dạng trên bất kỳ phần chìm nào
   đệm.

- Các thiết bị phụ chia tỷ lệ khung hình bằng hệ số tỷ lệ thay đổi sẽ
   đặt lại các hệ số tỷ lệ về giá trị mặc định khi định dạng miếng đệm chìm
   đã sửa đổi. Nếu tỷ lệ chia tỷ lệ 1:1 được hỗ trợ, điều này có nghĩa là
   định dạng miếng đệm nguồn phải được đặt lại về định dạng miếng đệm chìm.

Các định dạng không được truyền bá qua các liên kết, vì điều đó sẽ liên quan đến
truyền bá chúng từ một tập tin xử lý thiết bị phụ này sang một tập tin khác.
Sau đó, các ứng dụng phải chú ý định cấu hình cả hai đầu của mỗi liên kết
rõ ràng với các định dạng tương thích. Các định dạng giống nhau ở hai đầu của
một liên kết được đảm bảo tương thích. Trình điều khiển được tự do chấp nhận
các định dạng khác nhau phù hợp với yêu cầu của thiết bị vì tính tương thích.

ZZ0000ZZ hiển thị trình tự cấu hình mẫu
đối với đường dẫn được mô tả trong ZZ0001ZZ (các cột trong bảng
liệt kê tên thực thể và số pad).


.. raw:: latex

    \begingroup
    \scriptsize
    \setlength{\tabcolsep}{2pt}

.. tabularcolumns:: |p{2.0cm}|p{2.1cm}|p{2.1cm}|p{2.1cm}|p{2.1cm}|p{2.1cm}|p{2.1cm}|

.. _sample-pipeline-config:

.. flat-table:: Sample Pipeline Configuration
    :header-rows:  1
    :stub-columns: 0
    :widths: 5 5 5 5 5 5 5

    * -
      - Sensor/0

        format
      - Frontend/0

        format
      - Frontend/1

        format
      - Scaler/0

        format
      - Scaler/0

        compose selection rectangle
      - Scaler/1

        format
    * - Initial state
      - 2048x1536

        SGRBG8_1X8
      - (default)
      - (default)
      - (default)
      - (default)
      - (default)
    * - Configure frontend sink format
      - 2048x1536

        SGRBG8_1X8
      - *2048x1536*

        *SGRBG8_1X8*
      - *2046x1534*

        *SGRBG8_1X8*
      - (default)
      - (default)
      - (default)
    * - Configure scaler sink format
      - 2048x1536

        SGRBG8_1X8
      - 2048x1536

        SGRBG8_1X8
      - 2046x1534

        SGRBG8_1X8
      - *2046x1534*

        *SGRBG8_1X8*
      - *0,0/2046x1534*
      - *2046x1534*

        *SGRBG8_1X8*
    * - Configure scaler sink compose selection
      - 2048x1536

        SGRBG8_1X8
      - 2048x1536

        SGRBG8_1X8
      - 2046x1534

        SGRBG8_1X8
      - 2046x1534

        SGRBG8_1X8
      - *0,0/1280x960*
      - *1280x960*

        *SGRBG8_1X8*

.. raw:: latex

    \endgroup

1. Trạng thái ban đầu. Định dạng bảng nguồn cảm biến được đặt thành 3MP gốc
   kích thước và mã bus phương tiện V4L2_MBUS_FMT_SGRBG8_1X8. Các định dạng trên
   Giao diện máy chủ, phần chìm và phần đệm nguồn có mặc định
   các giá trị cũng như hình chữ nhật soạn trên bảng chìm của bộ chia tỷ lệ.

2. Ứng dụng định cấu hình kích thước của định dạng bảng chìm giao diện người dùng thành
   2048x1536 và mã bus phương tiện của nó tới V4L2_MBUS_FMT_SGRBG_1X8. các
   trình điều khiển truyền định dạng tới bảng nguồn giao diện người dùng.

3. Ứng dụng định cấu hình kích thước của định dạng tấm lót bồn rửa của bộ chia tỷ lệ thành
   2046x1534 và mã bus phương tiện tới V4L2_MBUS_FMT_SGRBG_1X8 tới
   khớp với kích thước nguồn giao diện người dùng và mã bus phương tiện. Mã bus phương tiện
   trên tấm lót bồn rửa được đặt thành V4L2_MBUS_FMT_SGRBG_1X8. Người lái xe
   truyền kích thước tới hình chữ nhật lựa chọn soạn thảo trên
   bảng chìm của bộ chia tỷ lệ và định dạng cho bảng nguồn của bộ chia tỷ lệ.

4. Ứng dụng định cấu hình kích thước của lựa chọn soạn thư
   hình chữ nhật của miếng đệm chìm của máy đo tỷ lệ 1280x960. Tài xế tuyên truyền
   kích thước sang định dạng bảng nguồn của bộ chia tỷ lệ.

Khi hài lòng với kết quả thử, ứng dụng có thể thiết lập kích hoạt
định dạng bằng cách đặt đối số ZZ0000ZZ thành
ZZ0001ZZ. Các định dạng hoạt động được thay đổi chính xác như thử
định dạng bằng trình điều khiển. Để tránh sửa đổi trạng thái phần cứng trong quá trình định dạng
đàm phán, các ứng dụng nên đàm phán thử các định dạng trước rồi mới đến
sửa đổi cài đặt hoạt động bằng cách sử dụng các định dạng thử được trả về trong quá trình
lần lặp lại đàm phán cuối cùng. Điều này đảm bảo rằng định dạng đang hoạt động sẽ
được áp dụng nguyên trạng bởi trình điều khiển mà không cần sửa đổi.


.. _v4l2-subdev-selections:

Các lựa chọn: cắt xén, chia tỷ lệ và bố cục
---------------------------------------------

Nhiều thiết bị phụ hỗ trợ cắt khung trên phần đầu vào hoặc đầu ra của chúng
(hoặc thậm chí có thể trên cả hai). Cắt ảnh được sử dụng để chọn vùng
quan tâm đến hình ảnh, thường là trên cảm biến hình ảnh hoặc bộ giải mã video.
Nó cũng có thể được sử dụng như một phần của việc triển khai thu phóng kỹ thuật số để chọn
diện tích của hình ảnh sẽ được phóng to.

Cài đặt cắt xén được xác định bằng một hình chữ nhật cắt xén và được thể hiện dưới dạng
struct ZZ0000ZZ theo tọa độ trên cùng
góc trái và kích thước hình chữ nhật. Cả tọa độ và kích thước đều
được thể hiện bằng pixel.

Đối với các định dạng pad, trình điều khiển lưu trữ các hình chữ nhật thử và hoạt động cho
mục tiêu lựa chọn ZZ0000ZZ.

Trên các miếng đệm chìm, việc cắt xén được áp dụng tương ứng với định dạng miếng đệm hiện tại.
Định dạng pad thể hiện kích thước hình ảnh mà thiết bị phụ nhận được
từ khối trước đó trong đường ống và hình chữ nhật cắt
đại diện cho hình ảnh phụ sẽ được truyền tiếp bên trong
thiết bị phụ để xử lý.

Thao tác chia tỷ lệ sẽ thay đổi kích thước của hình ảnh bằng cách chia tỷ lệ thành hình ảnh mới
kích thước. Tỷ lệ chia tỷ lệ không được chỉ định rõ ràng nhưng được ngụ ý
từ kích thước hình ảnh gốc và tỷ lệ. Cả hai kích thước được đại diện bởi
cấu trúc ZZ0000ZZ.

Hỗ trợ mở rộng quy mô là tùy chọn. Khi được hỗ trợ bởi một subdev, phần cắt
hình chữ nhật trên bảng chìm của subdev được chia tỷ lệ theo kích thước được định cấu hình
sử dụng
ZZ0000ZZ IOCTL
sử dụng mục tiêu lựa chọn ZZ0001ZZ trên cùng một bảng. Nếu
subdev hỗ trợ chia tỷ lệ nhưng không soạn thảo, giá trị trên cùng và bên trái là
không được sử dụng và phải luôn được đặt thành 0.

Trên các bảng nguồn, việc cắt xén tương tự như các bảng chìm, ngoại trừ
rằng kích thước nguồn mà việc cắt xén được thực hiện là
COMPOSE hình chữ nhật trên bệ bồn rửa. Trong cả phần đệm nguồn và phần chìm,
hình chữ nhật cắt phải được chứa hoàn toàn bên trong kích thước hình ảnh nguồn
cho hoạt động trồng trọt.

Trình điều khiển phải luôn sử dụng hình chữ nhật gần nhất có thể với người dùng
yêu cầu đối với tất cả các mục tiêu lựa chọn, trừ khi có quy định cụ thể khác.
Cờ ZZ0001ZZ và ZZ0002ZZ có thể được sử dụng để làm tròn
kích thước hình ảnh lên hoặc xuống. ZZ0000ZZ


Các loại mục tiêu lựa chọn
--------------------------


Mục tiêu thực tế
^^^^^^^^^^^^^^^^

Mục tiêu thực tế (không có hậu tố) phản ánh phần cứng thực tế
cấu hình tại bất kỳ thời điểm nào. Có mục tiêu BOUNDS
tương ứng với từng mục tiêu thực tế.


Mục tiêu BOUNDS
^^^^^^^^^^^^^^^

Mục tiêu BOUNDS là hình chữ nhật nhỏ nhất chứa tất cả các mục tiêu thực tế hợp lệ
hình chữ nhật. Có thể không đặt được hình chữ nhật thực tế là lớn
tuy nhiên, là hình chữ nhật BOUNDS. Điều này có thể là do ví dụ. một cảm biến
Mảng pixel không phải là hình chữ nhật mà có hình chữ thập hoặc hình tròn. Tối đa
kích thước cũng có thể nhỏ hơn hình chữ nhật BOUNDS.


.. _format-propagation:

Thứ tự cấu hình và truyền bá định dạng
---------------------------------------------

Bên trong các nhà phát triển con, thứ tự các bước xử lý ảnh sẽ luôn từ
miếng đệm chìm về phía miếng nguồn. Điều này cũng được thể hiện ở thứ tự
trong đó người dùng phải thực hiện cấu hình: những thay đổi
được thực hiện sẽ được phổ biến đến bất kỳ giai đoạn tiếp theo nào. Nếu hành vi này là
không mong muốn, người dùng phải đặt cờ ZZ0000ZZ. Cái này
cờ khiến không được phép truyền bá các thay đổi trong bất kỳ
hoàn cảnh. Điều này cũng có thể khiến hình chữ nhật được truy cập được điều chỉnh
bởi trình điều khiển, tùy thuộc vào thuộc tính của phần cứng cơ bản.

Tọa độ của một bước luôn đề cập đến kích thước thực tế của
bước trước đó. Ngoại lệ cho quy tắc này là việc soạn thư chìm
hình chữ nhật, đề cập đến hình chữ nhật giới hạn soạn thư chìm --- nếu nó
được hỗ trợ bởi phần cứng.

1. Định dạng miếng đệm chìm. Người dùng định cấu hình định dạng bảng chìm. Định dạng này
   xác định các tham số của hình ảnh mà thực thể nhận được thông qua
   đệm để xử lý tiếp.

2. Lựa chọn cây trồng thực tế. Cây trồng pad chìm xác định cây trồng
   được thực hiện ở định dạng tấm đệm chìm.

3. Lựa chọn soạn thảo thực tế của bảng chìm. Kích thước của miếng đệm bồn rửa
   hình chữ nhật xác định tỷ lệ tỷ lệ so với kích thước của bồn rửa
   pad cắt hình chữ nhật. Vị trí của hình chữ nhật soạn thư chỉ định
   vị trí của hình chữ nhật soạn bồn rửa thực tế trong soạn thảo bồn rửa
   giới hạn hình chữ nhật.

4. Nguồn pad lựa chọn cây trồng thực tế. Cắt trên bảng nguồn xác định cắt
   được thực hiện đối với hình ảnh trong hình chữ nhật giới hạn soạn thư chìm.

5. Định dạng bảng nguồn. Định dạng bảng nguồn xác định pixel đầu ra
   định dạng của subdev, cũng như các tham số khác với
   ngoại trừ chiều rộng và chiều cao của hình ảnh. Chiều rộng và chiều cao được xác định
   theo kích thước của lựa chọn cây trồng thực tế của vùng đệm nguồn.

Việc truy cập vào bất kỳ hình chữ nhật nào ở trên không được nhà phát triển phụ hỗ trợ sẽ
trả lại ZZ0000ZZ. Bất kỳ hình chữ nhật nào đề cập đến một hình chữ nhật không được hỗ trợ trước đó
thay vào đó, tọa độ hình chữ nhật sẽ tham chiếu đến tọa độ được hỗ trợ trước đó
hình chữ nhật. Ví dụ: nếu phần cắt chìm không được hỗ trợ thì tính năng soạn thư
Thay vào đó, lựa chọn sẽ đề cập đến kích thước định dạng của tấm lót bồn rửa.


.. _subdev-image-processing-crop:

.. kernel-figure:: subdev-image-processing-crop.svg
    :alt:   subdev-image-processing-crop.svg
    :align: center

    Image processing in subdevs: simple crop example

Trong ví dụ trên, subdev hỗ trợ cắt xén trên bảng chìm của nó. Đến
định cấu hình nó, người dùng sẽ đặt định dạng bus phương tiện trên phần chìm của subdev
đệm. Bây giờ, hình chữ nhật cắt thực tế có thể được đặt trên bảng chìm ---
vị trí và kích thước của hình chữ nhật này phản ánh vị trí và kích thước của một
hình chữ nhật được cắt từ định dạng chìm. Kích thước của bồn rửa
hình chữ nhật cũng sẽ là kích thước của định dạng nguồn của subdev
đệm.


.. _subdev-image-processing-scaling-multi-source:

.. kernel-figure:: subdev-image-processing-scaling-multi-source.svg
    :alt:   subdev-image-processing-scaling-multi-source.svg
    :align: center

    Image processing in subdevs: scaling with multiple sources

Trong ví dụ này, subdev có khả năng cắt xén trước, sau đó chia tỷ lệ
và cuối cùng cắt xén hai phần nguồn riêng lẻ từ kết quả
hình ảnh thu nhỏ. Vị trí của hình ảnh được chia tỷ lệ trong hình ảnh đã cắt là
bị bỏ qua trong mục tiêu soạn thư chìm. Cả hai địa điểm của nguồn cây trồng
hình chữ nhật đề cập đến hình chữ nhật chia tỷ lệ chìm, cắt xén độc lập
một khu vực tại vị trí được chỉ định bởi hình chữ nhật cắt nguồn từ nó.


.. _subdev-image-processing-full:

.. kernel-figure:: subdev-image-processing-full.svg
    :alt:    subdev-image-processing-full.svg
    :align:  center

    Image processing in subdevs: scaling and composition with multiple sinks and sources

Trình điều khiển subdev hỗ trợ hai miếng đệm chìm và hai miếng đệm nguồn. Những hình ảnh
từ cả hai miếng đệm bồn rửa đều được cắt riêng lẻ, sau đó thu nhỏ lại và
được soạn thảo thêm trên hình chữ nhật giới hạn thành phần. Từ đó, hai
các luồng độc lập được cắt và gửi ra khỏi subdev từ
miếng đệm nguồn.


.. toctree::
    :maxdepth: 1

    subdev-formats

.. _subdev-routing:

Luồng, miếng đệm đa phương tiện và định tuyến nội bộ
====================================================

Các thiết bị phụ V4L2 đơn giản không hỗ trợ nhiều luồng video không liên quan,
và chỉ một luồng duy nhất có thể đi qua liên kết phương tiện và bảng phương tiện.
Do đó, mỗi bảng chứa một định dạng và cấu hình lựa chọn cho điều đó.
luồng đơn. Một subdev có thể xử lý luồng và chia luồng thành
hai hoặc kết hợp hai luồng thành một, nhưng đầu vào và đầu ra cho
subdev vẫn là một luồng duy nhất trên mỗi bảng.

Một số phần cứng, ví dụ: MIPI CSI-2, hỗ trợ các luồng đa kênh, nghĩa là nhiều luồng
luồng dữ liệu được truyền trên cùng một bus, được đại diện bởi một phương tiện truyền thông
liên kết kết nối bảng nguồn máy phát với bảng chìm trên máy thu. cho
Ví dụ: cảm biến máy ảnh có thể tạo ra hai luồng riêng biệt, luồng pixel và luồng
luồng siêu dữ liệu, được truyền trên bus dữ liệu đa kênh, được biểu diễn
bằng một liên kết phương tiện kết nối bảng nguồn của cảm biến đơn với bộ thu
miếng đệm bồn rửa. Bộ thu nhận biết luồng sẽ tách kênh các luồng nhận được trên
miếng đệm chìm của nó và cho phép định tuyến chúng riêng lẻ đến một trong các nguồn của nó
miếng đệm.

Trình điều khiển thiết bị phụ hỗ trợ các luồng đa kênh tương thích với
trình điều khiển subdev không ghép kênh. Tuy nhiên, nếu driver ở đầu cuối của một liên kết
không hỗ trợ luồng thì chỉ có thể ghi lại luồng 0 của đầu nguồn.
Có thể có những hạn chế bổ sung cụ thể đối với thiết bị chìm.

Hiểu luồng
---------------------

Luồng là luồng nội dung (ví dụ: dữ liệu pixel hoặc siêu dữ liệu) chảy qua
đường dẫn truyền thông từ một nguồn (ví dụ: cảm biến) tới bộ thu cuối cùng (ví dụ:
bộ thu và bộ tách kênh trong SoC). Mỗi liên kết phương tiện truyền thông mang tất cả các kích hoạt
luồng từ đầu này đến đầu kia của liên kết và các thiết bị phụ có chức năng định tuyến
các bảng mô tả cách các luồng đến từ sink pad được định tuyến đến
miếng đệm nguồn.

ID luồng là mã định danh cục bộ của vùng đệm phương tiện cho một luồng. Luồng ID của
cùng một luồng phải bằng nhau ở cả hai đầu của liên kết. Nói cách khác,
một ID luồng cụ thể phải tồn tại trên cả hai mặt của phương tiện
liên kết, nhưng một ID luồng khác có thể được sử dụng cho cùng một luồng ở phía bên kia
của thiết bị phụ.

Một luồng tại một điểm cụ thể trong đường dẫn truyền thông được xác định bởi
thiết bị phụ và một cặp (pad, luồng). Đối với các thiết bị phụ không hỗ trợ
luồng được ghép kênh, trường 'luồng' luôn bằng 0.

Tương tác giữa các tuyến đường, luồng, định dạng và lựa chọn
------------------------------------------------------------

Việc bổ sung các luồng vào giao diện thiết bị phụ V4L2 sẽ di chuyển thiết bị phụ
định dạng và lựa chọn từ miếng đệm đến cặp (pad, luồng). Bên cạnh đó
pad thông thường, bạn cũng cần cung cấp ID luồng để cài đặt định dạng và
các lựa chọn. Thứ tự định cấu hình các định dạng và lựa chọn dọc theo luồng là
giống như không có luồng (xem ZZ0000ZZ).

Thay vì hợp nhất các luồng trên toàn thiết bị phụ từ tất cả các miếng đệm chìm
đối với tất cả các bảng nguồn, các luồng dữ liệu cho mỗi tuyến đều tách biệt với nhau
khác. Bất kỳ số tuyến đường nào từ các luồng trên đệm chìm tới các luồng trên
miếng đệm nguồn được cho phép, trong phạm vi được trình điều khiển hỗ trợ. Đối với mọi
tuy nhiên, phát trực tuyến trên bảng nguồn chỉ được phép sử dụng một tuyến duy nhất.

Bất kỳ cấu hình nào của luồng trong một bảng, chẳng hạn như định dạng hoặc lựa chọn,
độc lập với các cấu hình tương tự trên các luồng khác. Đây là
có thể thay đổi trong tương lai.

Loại thiết bị và thiết lập định tuyến
-------------------------------------

Các loại thiết bị phụ khác nhau có hành vi kích hoạt tuyến đường khác nhau,
tùy thuộc vào phần cứng. Tuy nhiên, trong mọi trường hợp, chỉ những tuyến đường có
Bộ cờ ZZ0000ZZ đang hoạt động.

Các thiết bị tạo luồng có thể cho phép bật và tắt một số
tuyến đường hoặc có cấu hình định tuyến cố định. Nếu các tuyến đường có thể bị vô hiệu hóa, không
khai báo các tuyến đường (hoặc khai báo chúng mà không có ZZ0000ZZ
cờ được đặt) trong ZZ0001ZZ sẽ vô hiệu hóa các tuyến đường.
ZZ0002ZZ vẫn sẽ trả lại các tuyến đường như vậy cho người dùng trong
mảng tuyến đường, với cờ ZZ0003ZZ không được đặt.

Các thiết bị truyền tải hầu như luôn có khả năng cấu hình cao hơn với
liên quan đến định tuyến. Thông thường, bất kỳ tuyến đường nào giữa phần gốc và nguồn của thiết bị phụ
có thể có các miếng đệm và nhiều tuyến đường (thường lên tới số lượng giới hạn nhất định) có thể
hoạt động đồng thời. Đối với các thiết bị như vậy, trình điều khiển không tạo tuyến đường
và các tuyến do người dùng tạo được thay thế hoàn toàn khi ZZ0000ZZ
được gọi trên thiết bị phụ. Các tuyến mới tạo như vậy đều có mặc định của thiết bị
cấu hình cho các hình chữ nhật định dạng và lựa chọn.

Định cấu hình luồng
-------------------

Cấu hình của các luồng được thực hiện riêng cho từng thiết bị phụ và
tính hợp lệ của các luồng giữa các thiết bị phụ được xác thực khi đường ống
được bắt đầu.

Có ba bước trong việc định cấu hình luồng:

1. Thiết lập liên kết. Kết nối các miếng đệm giữa các thiết bị phụ bằng cách sử dụng
   ZZ0000ZZ

2. Suối. Các luồng được khai báo và định tuyến của chúng được định cấu hình bằng cách đặt
   bảng định tuyến cho thiết bị phụ sử dụng ZZ0000ZZ ioctl. Lưu ý rằng việc thiết lập bảng định tuyến sẽ
   đặt lại các định dạng và lựa chọn trong thiết bị phụ về giá trị mặc định.

3. Định cấu hình các định dạng và lựa chọn. Các định dạng và lựa chọn của mỗi luồng là
   được định cấu hình riêng như tài liệu cho các thiết bị phụ đơn giản trong
   ZZ0000ZZ. ID luồng được đặt thành cùng một ID luồng
   được liên kết với phần đệm nguồn hoặc phần chìm của các tuyến được định cấu hình bằng cách sử dụng
   ZZ0001ZZ ioctl.

Ví dụ về thiết lập luồng đa kênh
---------------------------------

Một ví dụ đơn giản về thiết lập luồng đa kênh có thể như sau:

- Hai cảm biến giống hệt nhau (Cảm biến A và Cảm biến B). Mỗi cảm biến có một nguồn duy nhất
  pad (pad 0) mang luồng dữ liệu pixel.

- Cầu ghép kênh (Bridge). Cầu có hai miếng đệm chìm, nối với
  cảm biến (pad 0, 1) và một pad nguồn (pad 2), xuất ra hai luồng.

- Bộ thu trong SoC (Receiver). Bộ thu có một miếng đệm chìm duy nhất (pad 0),
  được kết nối với bridge và hai miếng đệm nguồn (miếng đệm 1-2), đi tới DMA
  động cơ. Bộ thu sẽ phân kênh các luồng đến tới các bảng nguồn.

- Công cụ DMA trong SoC (Công cụ DMA), một công cụ cho mỗi luồng. Mỗi động cơ DMA là
  được kết nối với một bảng nguồn duy nhất trong bộ thu.

Các cảm biến, cầu nối và bộ thu được mô hình hóa thành các thiết bị phụ V4L2,
tiếp xúc với không gian người dùng thông qua các nút thiết bị /dev/v4l-subdevX. Động cơ DMA là
được mô hình hóa dưới dạng thiết bị V4L2, được hiển thị với không gian người dùng thông qua các nút /dev/videoX.

Để định cấu hình đường dẫn này, không gian người dùng phải thực hiện các bước sau:

1. Thiết lập liên kết đa phương tiện giữa các thực thể: kết nối các cảm biến với cầu nối,
   cầu nối với bộ thu và bộ thu tới động cơ DMA. Bước này làm
   không khác với thiết lập bộ điều khiển phương tiện không ghép kênh thông thường.

2. Cấu hình định tuyến

.. flat-table:: Bridge routing table
    :header-rows:  1

    * - Sink Pad/Stream
      - Source Pad/Stream
      - Routing Flags
      - Comments
    * - 0/0
      - 2/0
      - V4L2_SUBDEV_ROUTE_FL_ACTIVE
      - Pixel data stream from Sensor A
    * - 1/0
      - 2/1
      - V4L2_SUBDEV_ROUTE_FL_ACTIVE
      - Pixel data stream from Sensor B

.. flat-table:: Receiver routing table
    :header-rows:  1

    * - Sink Pad/Stream
      - Source Pad/Stream
      - Routing Flags
      - Comments
    * - 0/0
      - 1/0
      - V4L2_SUBDEV_ROUTE_FL_ACTIVE
      - Pixel data stream from Sensor A
    * - 0/1
      - 2/0
      - V4L2_SUBDEV_ROUTE_FL_ACTIVE
      - Pixel data stream from Sensor B

3. Cấu hình các định dạng và lựa chọn

Sau khi định cấu hình định tuyến, bước tiếp theo là định cấu hình các định dạng và
   lựa chọn cho các luồng. Điều này tương tự như thực hiện bước này mà không cần
   luồng, chỉ với một ngoại lệ: trường ZZ0000ZZ cần được chỉ định
   với giá trị của ID luồng.

Một cách phổ biến để thực hiện điều này là bắt đầu từ các cảm biến và truyền
   các cấu hình dọc theo luồng hướng tới máy thu, sử dụng
   ZZ0000ZZ ioctls để định cấu hình từng cái
   điểm cuối luồng trong mỗi thiết bị phụ.