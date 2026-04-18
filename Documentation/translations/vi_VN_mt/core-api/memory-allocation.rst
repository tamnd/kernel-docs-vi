.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/memory-allocation.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _memory_allocation:

==========================
Hướng dẫn phân bổ bộ nhớ
==========================

Linux cung cấp nhiều loại API để phân bổ bộ nhớ. bạn có thể
phân bổ các khối nhỏ bằng cách sử dụng các họ ZZ0000ZZ hoặc ZZ0001ZZ,
các khu vực gần như liền kề rộng lớn sử dụng ZZ0002ZZ và các dẫn xuất của nó,
hoặc bạn có thể trực tiếp yêu cầu các trang từ bộ cấp phát trang với
ZZ0003ZZ. Cũng có thể sử dụng các bộ cấp phát chuyên dụng hơn,
ví dụ ZZ0004ZZ hoặc ZZ0005ZZ.

Hầu hết các API cấp phát bộ nhớ đều sử dụng cờ GFP để thể hiện cách thức điều đó
bộ nhớ cần được phân bổ. Từ viết tắt GFP là viết tắt của "nhận miễn phí
pages", chức năng cấp phát bộ nhớ cơ bản.

Sự đa dạng của API phân bổ kết hợp với nhiều cờ GFP
đặt ra câu hỏi "Tôi nên phân bổ bộ nhớ như thế nào?" không dễ dàng như vậy
câu trả lời, mặc dù rất có thể bạn nên sử dụng

::

kzalloc(<kích thước>, GFP_KERNEL);

Tất nhiên có những trường hợp khi các API phân bổ khác và GFP khác nhau
phải sử dụng cờ.

Nhận cờ trang miễn phí
======================

Cờ GFP kiểm soát hành vi của bộ cấp phát. Họ kể ký ức nào
các vùng có thể được sử dụng, người cấp phát nên cố gắng tìm vùng trống như thế nào
bộ nhớ, liệu bộ nhớ có thể được truy cập bởi không gian người dùng hay không, v.v.
ZZ0000ZZ cung cấp
tài liệu tham khảo về cờ GFP và sự kết hợp của chúng cũng như
ở đây chúng tôi phác thảo ngắn gọn cách sử dụng được đề xuất của họ:

* Hầu hết ZZ0000ZZ là thứ bạn cần. Bộ nhớ dành cho
    cấu trúc dữ liệu kernel, bộ nhớ DMAable, bộ đệm inode, tất cả những thứ này và
    nhiều loại phân bổ khác có thể sử dụng ZZ0001ZZ. Lưu ý rằng
    sử dụng ZZ0002ZZ ngụ ý ZZ0003ZZ, có nghĩa là
    việc thu hồi trực tiếp có thể được kích hoạt dưới áp lực bộ nhớ; sự kêu gọi
    bối cảnh phải được phép ngủ.
  * Nếu việc phân bổ được thực hiện từ bối cảnh nguyên tử, ví dụ như ngắt
    trình xử lý, hãy sử dụng ZZ0004ZZ. Cờ này ngăn chặn việc thu hồi trực tiếp và
    IO hoặc hoạt động của hệ thống tập tin. Do đó, dưới áp lực bộ nhớ
    Việc phân bổ ZZ0005ZZ có thể không thành công. Người sử dụng cờ này cần
    để cung cấp một phương án dự phòng phù hợp để đối phó với những thất bại đó khi
    thích hợp.
  * Nếu bạn cho rằng việc truy cập vào kho dự trữ bộ nhớ là hợp lý và kernel
    sẽ bị căng thẳng trừ khi việc phân bổ thành công, bạn có thể sử dụng ZZ0006ZZ.
  * Phân bổ không đáng tin cậy được kích hoạt từ không gian người dùng phải là chủ đề
    tính toán kmem và phải có bộ bit ZZ0007ZZ. Ở đó
    là phím tắt ZZ0008ZZ tiện dụng cho ZZ0009ZZ
    các khoản phân bổ cần được tính đến.
  * Phân bổ không gian người dùng nên sử dụng một trong hai ZZ0010ZZ,
    Cờ ZZ0011ZZ hoặc ZZ0012ZZ. Càng dài
    tên cờ càng ít hạn chế.

ZZ0000ZZ không yêu cầu bộ nhớ được phân bổ đó
    sẽ có thể được truy cập trực tiếp bởi kernel và ngụ ý rằng
    dữ liệu có thể di chuyển được.

ZZ0000ZZ có nghĩa là bộ nhớ được phân bổ không thể di chuyển được,
    nhưng kernel không bắt buộc phải truy cập trực tiếp được. Một
    ví dụ có thể là phân bổ phần cứng ánh xạ dữ liệu trực tiếp vào
    không gian người dùng nhưng không có giới hạn về địa chỉ.

ZZ0000ZZ có nghĩa là bộ nhớ được phân bổ không thể di chuyển được và nó
    phải được kernel truy cập trực tiếp.

Bạn có thể nhận thấy rằng có khá nhiều sự phân bổ trong mã hiện tại
chỉ định ZZ0001ZZ hoặc ZZ0002ZZ. Trong lịch sử, họ đã quen với việc
ngăn chặn sự bế tắc đệ quy do lệnh gọi lấy lại bộ nhớ trực tiếp gây ra
quay trở lại các đường dẫn FS hoặc IO và chặn trên các đường dẫn đã được giữ
tài nguyên. Kể từ phiên bản 4.12, cách ưa thích để giải quyết vấn đề này là
sử dụng API phạm vi mới được mô tả trong
ZZ0000ZZ.

Các cờ GFP kế thừa khác là ZZ0000ZZ và ZZ0001ZZ. Họ là
được sử dụng để đảm bảo rằng bộ nhớ được phân bổ có thể truy cập được bằng phần cứng
với khả năng đánh địa chỉ hạn chế. Vì vậy trừ khi bạn đang viết một
trình điều khiển cho thiết bị có những hạn chế như vậy, hãy tránh sử dụng các cờ này.
Và ngay cả với phần cứng có những hạn chế thì vẫn nên sử dụng
API ZZ0002ZZ.

Cờ GFP và hành vi lấy lại
------------------------------
Việc phân bổ bộ nhớ có thể kích hoạt việc thu hồi trực tiếp hoặc nền và
hữu ích để hiểu mức độ khó mà người cấp phát trang sẽ cố gắng đáp ứng điều đó
hoặc một yêu cầu khác.

* ZZ0000ZZ - phân bổ lạc quan không có _any_
    cố gắng giải phóng bộ nhớ. Chế độ trọng lượng nhẹ nhất mà thậm chí
    không đá đòi lại nền. Nên sử dụng cẩn thận vì nó
    có thể làm cạn kiệt bộ nhớ và người dùng tiếp theo có thể tấn công mạnh hơn
    đòi lại.

* ZZ0000ZZ (hoặc ZZ0001ZZ)- lạc quan
    phân bổ mà không có bất kỳ nỗ lực nào để giải phóng bộ nhớ khỏi hiện tại
    bối cảnh nhưng có thể đánh thức kswapd để lấy lại bộ nhớ nếu vùng ở dưới
    hình mờ thấp. Có thể được sử dụng từ bối cảnh nguyên tử hoặc khi
    yêu cầu là tối ưu hóa hiệu suất và có một yêu cầu khác
    dự phòng cho một con đường chậm.

* ZZ0000ZZ (còn gọi là ZZ0001ZZ) -
    phân bổ không ngủ với một dự phòng đắt tiền để nó có thể truy cập
    một phần dự trữ bộ nhớ. Thường được sử dụng từ ngắt/nửa dưới
    bối cảnh với một dự phòng đường dẫn chậm đắt tiền.

* ZZ0000ZZ - cho phép cả thu hồi nền và thu hồi trực tiếp và
    Hành vi cấp phát trang ZZ0001ZZ được sử dụng. Điều đó có nghĩa là không tốn kém
    các yêu cầu phân bổ về cơ bản là không thất bại nhưng không có gì đảm bảo về
    hành vi đó nên lỗi phải được người gọi kiểm tra đúng cách
    (ví dụ: nạn nhân sát thủ OOM hiện được phép thất bại).

* ZZ0000ZZ - ghi đè hành vi cấp phát mặc định
    và tất cả các yêu cầu phân bổ đều thất bại sớm thay vì gây ra sự gián đoạn
    lấy lại (một vòng lấy lại trong quá trình triển khai này). Kẻ giết người OOM
    không được gọi.

* ZZ0000ZZ - ghi đè bộ cấp phát mặc định
    hành vi và tất cả các yêu cầu phân bổ đều cố gắng hết sức. yêu cầu
    sẽ thất bại nếu việc đòi lại không thể đạt được bất kỳ tiến triển nào. Kẻ giết người OOM
    sẽ không được kích hoạt.

* ZZ0000ZZ - ghi đè hành vi cấp phát mặc định
    và tất cả các yêu cầu phân bổ sẽ lặp lại vô tận cho đến khi thành công.
    Điều này có thể thực sự nguy hiểm, đặc biệt đối với các đơn hàng lớn hơn.

Chọn cấp phát bộ nhớ
==========================

Cách đơn giản nhất để cấp phát bộ nhớ là sử dụng hàm
từ họ kmalloc(). Và để đảm bảo an toàn tốt nhất nên sử dụng
các quy trình đặt bộ nhớ về 0, như kzalloc(). Nếu bạn cần
cấp phát bộ nhớ cho một mảng thì có kmalloc_array() và kcalloc()
những người giúp đỡ. Các hàm trợ giúp struct_size(), array_size() và array3_size() có thể
được sử dụng để tính toán kích thước đối tượng một cách an toàn mà không bị tràn.

Kích thước tối đa của một đoạn có thể được phân bổ bằng ZZ0000ZZ là
hạn chế. Giới hạn thực tế phụ thuộc vào phần cứng và kernel
cấu hình, nhưng cách tốt nhất là sử dụng ZZ0001ZZ cho các đối tượng
nhỏ hơn kích thước trang.

Địa chỉ của một đoạn được phân bổ bằng ZZ0000ZZ được căn chỉnh ít nhất theo
byte ARCH_KMALLOC_MINALIGN. Đối với các kích thước là lũy thừa của hai,
căn chỉnh cũng được đảm bảo ít nhất là kích thước tương ứng. Đối với người khác
kích thước, sự liên kết được đảm bảo ít nhất là lũy thừa lớn nhất của hai
chia của kích thước.

Các khối được phân bổ bằng kmalloc() có thể được thay đổi kích thước bằng krealloc(). Tương tự
tới kmalloc_array(): một trình trợ giúp để thay đổi kích thước mảng được cung cấp dưới dạng
krealloc_array().

Đối với phân bổ lớn, bạn có thể sử dụng vmalloc() và vzalloc() hoặc trực tiếp
yêu cầu các trang từ bộ cấp phát trang. Bộ nhớ được phân bổ bởi ZZ0000ZZ
và các chức năng liên quan không liền kề nhau về mặt vật lý.

Nếu bạn không chắc liệu kích thước phân bổ có quá lớn đối với
ZZ0000ZZ, có thể sử dụng kvmalloc() và các dẫn xuất của nó. Nó sẽ
hãy thử phân bổ bộ nhớ bằng ZZ0001ZZ và nếu việc phân bổ không thành công
sẽ được thử lại với ZZ0002ZZ. Có những hạn chế đối với GFP
cờ có thể được sử dụng với ZZ0003ZZ; vui lòng xem tài liệu tham khảo kvmalloc_node()
tài liệu. Lưu ý rằng ZZ0004ZZ có thể trả về bộ nhớ không đúng
liền kề về mặt vật lý.

Nếu bạn cần phân bổ nhiều đối tượng giống hệt nhau, bạn có thể sử dụng bảng
bộ cấp phát bộ đệm. Bộ nhớ đệm phải được thiết lập bằng kmem_cache_create() hoặc
kmem_cache_create_usercopy() trước khi có thể sử dụng. Chức năng thứ hai
nên được sử dụng nếu một phần bộ đệm có thể được sao chép vào không gian người dùng.
Sau khi bộ đệm được tạo kmem_cache_alloc() và sự tiện lợi của nó
trình bao bọc có thể phân bổ bộ nhớ từ bộ đệm đó.

Khi bộ nhớ được cấp phát không còn cần thiết nữa, nó phải được giải phóng.

Các đối tượng được phân bổ bởi ZZ0000ZZ có thể được giải phóng bởi ZZ0001ZZ hoặc ZZ0002ZZ. Đối tượng
được phân bổ bởi ZZ0003ZZ có thể được giải phóng bằng ZZ0004ZZ, ZZ0005ZZ
hoặc ZZ0006ZZ, trong đó hai cái sau có thể thuận tiện hơn nhờ không
cần con trỏ kmem_cache.

Các quy tắc tương tự áp dụng cho các loại _bulk và _rcu của các hàm giải phóng.

Bộ nhớ được phân bổ bởi ZZ0000ZZ có thể được giải phóng bằng ZZ0001ZZ hoặc ZZ0002ZZ.
Bộ nhớ được phân bổ bởi ZZ0003ZZ có thể được giải phóng bằng ZZ0004ZZ.
Bộ nhớ đệm được tạo bởi ZZ0005ZZ sẽ được giải phóng bằng
ZZ0006ZZ chỉ sau khi giải phóng tất cả các đối tượng được phân bổ trước.
