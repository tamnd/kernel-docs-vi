.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/gpu/rfc/color_pipeline.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Đường ống màu Linux API
===========================

Chúng ta đang giải quyết vấn đề gì?
============================

Chúng tôi muốn hỗ trợ màu phức tạp trước và sau pha trộn
các biến đổi trong phần cứng bộ điều khiển hiển thị để cho phép
Các trường hợp sử dụng HDR được HW hỗ trợ, cũng như cung cấp hỗ trợ cho
các ứng dụng quản lý màu sắc, chẳng hạn như trình chỉnh sửa video hoặc hình ảnh.

Có thể hỗ trợ đầu ra HDR trên CTNH hỗ trợ Không gian màu
và các thuộc tính drm_connector siêu dữ liệu HDR, nhưng điều đó đòi hỏi
bộ tổng hợp hoặc ứng dụng để kết xuất và soạn nội dung thành một
bộ đệm cuối cùng dành cho hiển thị. Làm như vậy rất tốn kém.

Hầu hết HW màn hình hiện đại đều cung cấp nhiều LUT 1D, LUT 3D, ma trận và các loại khác
hoạt động hỗ trợ chuyển đổi màu sắc. Các hoạt động này thường
được triển khai trong CTNH có chức năng cố định và do đó tiết kiệm điện hơn nhiều so với
thực hiện các thao tác tương tự thông qua trình đổ bóng hoặc CPU.

Chúng tôi muốn sử dụng chức năng CTNH này để hỗ trợ màu sắc phức tạp.
các phép biến đổi không có hoặc tải CPU hoặc trình đổ bóng tối thiểu. Sự chuyển đổi giữa HW
các khối chức năng cố định và bộ đổ bóng/CPU phải liền mạch, không nhìn thấy được
sự khác biệt khi dự phòng cho shader/CPU là cần thiết bất cứ lúc nào.


Các hệ điều hành khác giải quyết vấn đề này như thế nào?
========================================

Các trường hợp sử dụng được hỗ trợ rộng rãi nhất liên quan đến nội dung HDR, cho dù là video hay
chơi game.

Hầu hết các hệ điều hành sẽ chỉ định định dạng nội dung nguồn (gam màu, truyền mã hóa
chức năng và siêu dữ liệu khác, chẳng hạn như mức ánh sáng tối đa và trung bình) cho trình điều khiển.
Sau đó, các trình điều khiển sẽ lập trình CTNH có chức năng cố định của họ để lập bản đồ từ một
không gian của bộ đệm nội dung nguồn sang không gian của màn hình.

Khi không có CTNH có chức năng cố định, bộ tổng hợp sẽ tập hợp một bộ đổ bóng để
yêu cầu GPU thực hiện chuyển đổi từ định dạng nội dung nguồn sang định dạng
định dạng của màn hình.

Chức năng ánh xạ của bộ tổng hợp và chức năng ánh xạ của trình điều khiển thường
khái niệm hoàn toàn riêng biệt. Trên các hệ điều hành mà nhà cung cấp CTNH không có hiểu biết sâu sắc về
mã nguồn đóng, nhà cung cấp như vậy sẽ điều chỉnh việc quản lý màu của họ
mã để khớp trực quan với mã của nhà soạn nhạc. Trên các hệ điều hành khác, nơi cả ánh xạ
các hàm được mở cho người triển khai, chúng sẽ đảm bảo cả hai ánh xạ đều khớp.

Điều này dẫn đến việc khóa thuật toán ánh xạ, nghĩa là không ai một mình có thể
thử nghiệm hoặc giới thiệu các thuật toán ánh xạ mới và đạt được
kết quả nhất quán bất kể con đường thực hiện nào được thực hiện.

Tại sao Linux lại khác biệt?
=======================

Không giống như các hệ điều hành khác, nơi có một bộ tổng hợp cho một hoặc nhiều trình điều khiển, trên
Linux chúng ta có mối quan hệ nhiều-nhiều. Nhiều nhà soạn nhạc; nhiều tài xế.
Ngoài ra, mỗi nhà cung cấp hoặc cộng đồng bộ tổng hợp đều có quan điểm riêng về cách
quản lý màu sắc nên được thực hiện. Đây là điều làm cho Linux trở nên tuyệt vời.

Điều này có nghĩa là nhà cung cấp CTNH giờ đây không còn có thể điều chỉnh trình điều khiển của họ theo một
bộ tổng hợp, vì việc điều chỉnh nó thành một bộ có thể làm cho nó trông khá khác so với
ánh xạ màu của một nhà soạn nhạc khác.

Chúng ta cần một giải pháp tốt hơn.


Mô tả API
===============

API mô tả không gian màu nguồn và đích là một mô tả
API. Nó mô tả không gian màu đầu vào và đầu ra nhưng không mô tả
chúng nên được lập bản đồ chính xác như thế nào. Việc ánh xạ như vậy bao gồm nhiều phút
quyết định thiết kế có thể ảnh hưởng lớn đến hình thức của kết quả cuối cùng.

Việc mô tả bản đồ đó với đủ chi tiết để đảm bảo rằng
cùng một kết quả từ mỗi lần thực hiện. Trên thực tế, những ánh xạ này rất tích cực
khu vực nghiên cứu.


API theo quy định
================

API mang tính quy định không mô tả không gian màu nguồn và đích. Nó
thay vào đó quy định một công thức về cách thao tác các giá trị pixel để đạt được
kết quả mong muốn.

Công thức này nói chung là một danh sách có thứ tự các thao tác đơn giản,
với các định nghĩa toán học rõ ràng, chẳng hạn như LUT 1D, LUT 3D, ma trận,
hoặc các hoạt động khác có thể được mô tả một cách chính xác.


Đường dẫn màu API
======================

Quy trình quản lý màu CTNH có thể khác biệt đáng kể giữa các CTNH
nhà cung cấp về tính sẵn có, đặt hàng và khả năng của CTNH
khối. Điều này tạo nên một định nghĩa chung về các khối quản lý màu sắc và
việc đặt hàng của họ gần như không thể. Thay vào đó chúng tôi đang xác định một API
cho phép không gian người dùng khám phá các khả năng CTNH một cách chung chung,
bất khả tri về trình điều khiển và phần cứng cụ thể.


Đối tượng drm_colorop
==================

Để hỗ trợ định nghĩa các đường dẫn màu, chúng tôi xác định lõi DRM
loại đối tượng drm_colorop. Các đối tượng drm_colorop riêng lẻ sẽ bị xâu chuỗi
thông qua thuộc tính NEXT của drm_colorop để tạo thành một đường dẫn màu.
Mỗi đối tượng drm_colorop là duy nhất, tức là ngay cả khi có nhiều màu
các đường ống có cùng hoạt động, chúng sẽ không chia sẻ cùng drm_colorop
đối tượng để mô tả hoạt động đó.

Lưu ý rằng trình điều khiển không được yêu cầu ánh xạ tĩnh các đối tượng drm_colorop
tới các khối CTNH cụ thể. Việc ánh xạ các đối tượng drm_colorop hoàn toàn là một
chi tiết bên trong trình điều khiển và có thể động hoặc tĩnh tùy theo nhu cầu của trình điều khiển
nó sẽ như vậy. Xem thêm ở phần Hướng dẫn triển khai Driver bên dưới.

Mỗi drm_colorop có ba thuộc tính cốt lõi:

TYPE: Thuộc tính liệt kê, xác định loại chuyển đổi, chẳng hạn như
* đường cong liệt kê
* tùy chỉnh (đồng phục) 1D LUT
* Ma trận 3x3
* Ma trận 3x4
* 3D LUT
* v.v.

Tùy thuộc vào loại chuyển đổi, các thuộc tính khác sẽ mô tả
biết thêm chi tiết.

BYPASS: Thuộc tính boolean có thể được sử dụng để dễ dàng đặt một khối vào
chế độ bỏ qua. Thuộc tính BYPASS không bắt buộc đối với colorop, miễn là
vì toàn bộ đường ống có thể bị bỏ qua bằng cách bật COLOR_PIPELINE
một mặt phẳng về '0'.

NEXT: ID của drm_colorop tiếp theo trong đường dẫn màu hoặc 0 nếu điều này
drm_colorop là cái cuối cùng trong chuỗi.

Một ví dụ về đối tượng drm_colorop có thể trông giống như một trong những đối tượng sau::

/* Đường cong liệt kê 1D */
    Thao tác màu 42
    ├─ "TYPE": enum bất biến {Đường cong liệt kê 1D, LUT 1D, ma trận 3x3, ma trận 3x4, 3D LUT, v.v.} = Đường cong liệt kê 1D
    ├─ "BYPASS": bool {đúng, sai}
    ├─ "CURVE_1D_TYPE": enum {sRGB EOTF, sRGB nghịch đảo EOTF, PQ EOTF, PQ nghịch đảo EOTF, …}
    └─ "NEXT": ID hoạt động màu không thay đổi = 43

/* mục nhập 4k tùy chỉnh 1D LUT */
    Thao tác màu 52
    ├─ "TYPE": enum bất biến {Đường cong liệt kê 1D, LUT 1D, ma trận 3x3, ma trận 3x4, 3D LUT, v.v.} = 1D LUT
    ├─ "BYPASS": bool {đúng, sai}
    ├─ "SIZE": phạm vi không thay đổi = 4096
    ├─ "DATA": đốm màu
    └─ "NEXT": ID hoạt động màu không thay đổi = 0

/* 17^3 3D LUT */
    Thao tác màu 72
    ├─ "TYPE": enum bất biến {Đường cong liệt kê 1D, LUT 1D, ma trận 3x3, ma trận 3x4, 3D LUT, v.v.} = 3D LUT
    ├─ "BYPASS": bool {đúng, sai}
    ├─ "SIZE": phạm vi không thay đổi = 17
    ├─ "DATA": đốm màu
    └─ "NEXT": ID hoạt động màu không thay đổi = 73

khả năng mở rộng drm_colorop
-------------------------

Không giống như các đối tượng cốt lõi DRM hiện có, như &drm_plane, drm_colorop thì không
có thể mở rộng. Điều này đơn giản hóa việc triển khai và giữ tất cả chức năng
để quản lý các đối tượng &drm_colorop trong lõi DRM.

Nếu có nhu cầu, người ta có thể giới thiệu &drm_colorop_funcs đơn giản
bảng chức năng trong tương lai, ví dụ để hỗ trợ IN_FORMATS
thuộc tính trên &drm_colorop.

Nếu trình điều khiển yêu cầu khả năng tạo màu dành riêng cho trình điều khiển
đối tượng họ sẽ cần thêm hỗ trợ bảng func &drm_colorop với
hỗ trợ các chức năng thông thường, như hủy, Atomic_duplicate_state,
và Atomic_destroy_state.


Thuộc tính máy bay COLOR_PIPELINE
=============================

Đường ống màu được tạo bởi trình điều khiển và được quảng cáo thông qua một giao diện mới
Thuộc tính enum COLOR_PIPELINE trên mỗi mặt phẳng. Giá trị của tài sản
luôn bao gồm id đối tượng 0, là mặc định và có nghĩa là tất cả các màu
quá trình xử lý bị vô hiệu hóa. Các giá trị bổ sung sẽ là ID đối tượng của
drm_colorop đầu tiên trong một đường dẫn. Trình điều khiển không thể tạo và quảng cáo,
một hoặc nhiều đường ống màu có thể. Máy khách DRM sẽ chọn một màu
đường dẫn bằng cách đặt COLOR PIPELINE thành giá trị tương ứng.

NOTE: Nhiều máy khách DRM sẽ đặt thuộc tính liệt kê thông qua chuỗi
giá trị, thường mã hóa cứng nó. Vì bảng liệt kê này được tạo ra dựa trên
trên ID đối tượng colorop, điều quan trọng là phải thực hiện Đường ống màu
Discovery, được mô tả bên dưới, thay vì đường dẫn màu mã hóa cứng
nhiệm vụ. Trình điều khiển có thể tạo chuỗi enum một cách linh hoạt.
Các chuỗi được mã hóa cứng chỉ có thể hoạt động đối với các trình điều khiển cụ thể trên một thiết bị cụ thể
mảnh CTNH. Color Pipeline Discovery có thể hoạt động phổ biến, miễn là
trình điều khiển thực hiện các hoạt động màu sắc cần thiết.

Thuộc tính COLOR_PIPELINE chỉ được hiển thị khi
DRM_CLIENT_CAP_PLANE_COLOR_PIPELINE được thiết lập. Người lái xe sẽ bỏ qua bất kỳ
các hoạt động trộn màu trước hiện có khi giới hạn này được đặt, chẳng hạn như
COLOR_RANGE và COLOR_ENCODING. Nếu trình điều khiển muốn hỗ trợ COLOR_RANGE
hoặc chức năng COLOR_ENCODING khi nắp máy khách đường dẫn màu được
được thiết lập, họ dự kiến sẽ hiển thị các colorops trong quy trình để cho phép
sự chuyển đổi màu sắc thích hợp.

Cài đặt thuộc tính mặt phẳng COLOR_PIPELINE hoặc thuộc tính drm_colorop
chỉ được phép đối với không gian người dùng đặt giới hạn ứng dụng khách này.

Một ví dụ về thuộc tính COLOR_PIPELINE trên mặt phẳng có thể trông như thế này ::

Máy bay 10
    ├─ "TYPE": enum bất biến {Lớp phủ, Chính, Con trỏ} = Chính
    ├─…
    └─ "COLOR_PIPELINE": enum {0, 42, 52} = 0


Khám phá đường ống màu
========================

Khách hàng DRM muốn quản lý màu trên drm_plane sẽ:

1. Lấy thuộc tính COLOR_PIPELINE của máy bay
2. lặp lại tất cả các giá trị enum COLOR_PIPELINE
3. đối với mỗi giá trị enum, hãy đi theo đường dẫn màu (thông qua con trỏ NEXT)
   và xem liệu các thao tác màu có sẵn có phù hợp với
   hoạt động quản lý màu sắc mong muốn

Nếu không gian người dùng gặp phải thao tác màu không xác định hoặc không phù hợp trong quá trình
khám phá ra nó không cần phải từ chối hoàn toàn toàn bộ đường dẫn màu,
miễn là màu sắc không xác định hoặc không phù hợp có thuộc tính "BYPASS".
Trình điều khiển sẽ đảm bảo rằng khối bỏ qua không có bất kỳ ảnh hưởng nào.

Một ví dụ về các thuộc tính được xâu chuỗi để xác định màu trộn trước AMD
đường ống có thể trông như thế này::

Máy bay 10
    ├─ "TYPE" (không thay đổi) = Chính
    └─ "COLOR_PIPELINE": enum {0, 44} = 0

Thao tác màu 44
    ├─ "TYPE" (bất biến) = Đường cong liệt kê 1D
    ├─ "BYPASS": bool
    ├─ "CURVE_1D_TYPE": enum {sRGB EOTF, PQ EOTF} = sRGB EOTF
    └─ "NEXT" (không thay đổi) = 45

Thao tác màu 45
    ├─ "TYPE" (bất biến) = Ma trận 3x4
    ├─ "BYPASS": bool
    ├─ "DATA": đốm màu
    └─ "NEXT" (không thay đổi) = 46

Thao tác màu 46
    ├─ "TYPE" (bất biến) = Đường cong liệt kê 1D
    ├─ "BYPASS": bool
    ├─ "CURVE_1D_TYPE": enum {sRGB nghịch đảo EOTF, PQ nghịch đảo EOTF} = sRGB EOTF
    └─ "NEXT" (không thay đổi) = 47

Thao tác màu 47
    ├─ "TYPE" (không thay đổi) = 1D LUT
    ├─ "SIZE": phạm vi không thay đổi = 4096
    ├─ "DATA": đốm màu
    └─ "NEXT" (không thay đổi) = 48

Thao tác màu 48
    ├─ "TYPE" (không thay đổi) = 3D LUT
    ├─ "DATA": đốm màu
    └─ "NEXT" (không thay đổi) = 49

Thao tác màu 49
    ├─ "TYPE" (bất biến) = Đường cong liệt kê 1D
    ├─ "BYPASS": bool
    ├─ "CURVE_1D_TYPE": enum {sRGB EOTF, PQ EOTF} = sRGB EOTF
    └─ "NEXT" (không thay đổi) = 0


Lập trình đường ống màu
==========================

Khi khách hàng DRM đã tìm được đường dẫn phù hợp, nó sẽ:

1. Đặt giá trị enum COLOR_PIPELINE thành giá trị trỏ vào đầu tiên
   đối tượng drm_colorop của đường ống mong muốn
2. Đặt thuộc tính cho tất cả các đối tượng drm_colorop trong đường dẫn tới
   giá trị mong muốn, đặt BYPASS thành true cho các khối drm_colorop không sử dụng,
   và sai đối với các khối drm_colorop đã bật
3. Thực hiện cam kết nguyên tử (TEST_ONLY hoặc không) với tất cả các KMS khác
   nói rằng nó muốn thay đổi

Để định cấu hình đường ống cho mặt phẳng PQ HDR10 và trộn theo đường dẫn tuyến tính
không gian, một bộ tổng hợp có thể thực hiện một cam kết nguyên tử với những điều sau đây
giá trị thuộc tính::

Máy bay 10
    └─ "COLOR_PIPELINE" = 42

Thao tác màu 42
    └─ "BYPASS" = đúng

Thao tác màu 44
    └─ "BYPASS" = đúng

Thao tác màu 45
    └─ "BYPASS" = đúng

Thao tác màu 46
    └─ "BYPASS" = đúng

Thao tác màu 47
    ├─ "DATA" = Ánh xạ gam màu + ánh xạ tông màu + chế độ ban đêm
    └─ "BYPASS" = sai

Thao tác màu 48
    ├─ "CURVE_1D_TYPE" = PQ EOTF
    └─ "BYPASS" = sai


Hướng dẫn thực hiện lái xe
==========================

Tất cả điều này có ý nghĩa gì đối với việc triển khai trình điều khiển? Như đã lưu ý ở trên
colorops có thể ánh xạ trực tiếp tới CTNH nhưng không cần phải làm như vậy. Đây là một số
gợi ý về cách suy nghĩ về việc tạo đường dẫn màu của bạn:

- Cố gắng hiển thị các đường ống sử dụng các colorops đã được xác định, ngay cả khi
  đường dẫn phần cứng của bạn được phân chia khác nhau. Điều này cho phép hiện có
  không gian người dùng để tận dụng ngay phần cứng.

- Ngoài ra, hãy thử hiển thị các khối phần cứng thực tế của bạn dưới dạng colorops.
  Xác định các loại colorop mới mà bạn tin rằng nó có thể mang lại hiệu quả đáng kể
  lợi ích nếu không gian người dùng học cách lập trình chúng.

- Tránh xác định các màu mới cho các hoạt động phức hợp với phạm vi rất hẹp
  phạm vi. Nếu bạn có một khối phần cứng cho một hoạt động đặc biệt
  không thể chia nhỏ hơn nữa, bạn có thể hiển thị nó dưới dạng loại colorop mới.
  Tuy nhiên, cố gắng không xác định colorops cho "trường hợp sử dụng", đặc biệt nếu
  họ yêu cầu bạn kết hợp nhiều khối phần cứng.

- Thiết kế các màu mới mang tính quy định, không mang tính mô tả; bởi
  công thức toán học, không phải theo đầu vào và đầu ra giả định.

Loại colorop được xác định phải mang tính xác định. Hành vi chính xác của
colorop phải được ghi lại toàn bộ, cho dù thông qua công thức toán học
hoặc một số mô tả khác. Hoạt động của nó chỉ có thể phụ thuộc vào
thuộc tính và đầu vào và không có gì khác, dung sai lỗi cho phép
mặc dù vậy.


Khả năng tương thích tiến/lùi của trình điều khiển
=====================================

Vì đây là trình điều khiển uAPI không thể khôi phục các đường dẫn màu đã được
được giới thiệu cho một thế hệ CTNH nhất định. Các thế hệ CTNH mới được tự do
từ bỏ các đường ống màu được quảng cáo cho các thế hệ trước.
Tuy nhiên, có thể có ích nếu thực hiện hỗ trợ cho màu hiện có.
chuyển tiếp các đường ống vì chúng có thể đã được hỗ trợ trong DRM
khách hàng.

Việc giới thiệu các colorops mới cho quy trình cũng được, miễn là chúng có thể
được bỏ qua hoặc hoàn toàn mang tính thông tin. Hỗ trợ triển khai khách hàng DRM
vì đường dẫn luôn có thể bỏ qua các thuộc tính không xác định miễn là chúng có thể
hãy tin chắc rằng làm như vậy sẽ không gây ra kết quả ngoài mong đợi.

Nếu một colorop mới không thuộc một trong các loại trên
(có thể bỏ qua hoặc mang tính thông tin) đường ống đã sửa đổi sẽ không sử dụng được
cho không gian người dùng. Trong trường hợp này, một đường ống mới cần được xác định.


Tài liệu tham khảo
==========

1. ZZ0000ZZ