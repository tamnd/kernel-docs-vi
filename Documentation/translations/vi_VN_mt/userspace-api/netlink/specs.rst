.. SPDX-License-Identifier: BSD-3-Clause

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/netlink/specs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================================
Thông số kỹ thuật giao thức Netlink (trong YAML)
=========================================

Thông số kỹ thuật của giao thức Netlink đã hoàn tất, các mô tả về máy có thể đọc được
Giao thức Netlink được viết bằng YAML. Mục tiêu của thông số kỹ thuật là cho phép
tách phân tích cú pháp Netlink khỏi logic không gian người dùng và giảm thiểu số lượng
Mã Netlink viết tay cho mỗi họ, lệnh, thuộc tính mới.
Thông số kỹ thuật của Netlink phải đầy đủ và không phụ thuộc vào bất kỳ thông số kỹ thuật nào khác
hoặc tệp tiêu đề C, giúp dễ sử dụng bằng các ngôn ngữ không thể bao gồm
tiêu đề kernel trực tiếp.

Hạt nhân nội bộ sử dụng thông số kỹ thuật YAML để tạo:

- tiêu đề C uAPI
 - tài liệu về giao thức dưới dạng tệp ReST - xem ZZ0000ZZ
 - bảng chính sách để xác thực thuộc tính đầu vào
 - bảng hoạt động

Thông số kỹ thuật của YAML có thể được tìm thấy trong ZZ0000ZZ

Tài liệu này mô tả chi tiết về lược đồ.
Xem ZZ0000ZZ để biết hướng dẫn bắt đầu thực tế.

Tất cả các thông số kỹ thuật phải được cấp phép theo
ZZ0000ZZ
để cho phép dễ dàng áp dụng mã không gian của người dùng.

Mức độ tương thích
====================

Có bốn cấp độ lược đồ cho các thông số Netlink, từ cấp độ đơn giản nhất được sử dụng
bởi các gia đình mới cho đến những gia đình phức tạp nhất, bao gồm tất cả những điều kỳ quặc của những gia đình cũ.
Mỗi cấp độ tiếp theo kế thừa các thuộc tính của cấp độ trước đó, nghĩa là
người dùng có khả năng phân tích các lược đồ ZZ0000ZZ phức tạp hơn cũng tương thích
với những cái đơn giản hơn. Các cấp độ là:

- ZZ0000ZZ - tinh gọn nhất, nên dùng cho mọi gia đình mới
 - ZZ0001ZZ - superset của ZZ0002ZZ với các thuộc tính bổ sung cho phép
   tùy chỉnh tên loại và giá trị xác định và enum; lược đồ này nên
   tương đương với ZZ0003ZZ cho tất cả các triển khai không tương tác
   trực tiếp với tiêu đề C uAPI
 - ZZ0004ZZ - Netlink chung nắm bắt tất cả các lược đồ hỗ trợ các đặc điểm của
   tất cả các họ liên kết gen cũ, các định dạng thuộc tính lạ, cấu trúc nhị phân, v.v.
 - ZZ0005ZZ - nắm bắt tất cả các lược đồ hỗ trợ các giao thức Netlink tiền chung
   chẳng hạn như ZZ0006ZZ

Có thể tìm thấy định nghĩa của các lược đồ (trong ZZ0000ZZ)
dưới ZZ0001ZZ.

Cấu trúc lược đồ
================

Lược đồ YAML có các phần khái niệm sau:

- toàn cầu
 - định nghĩa
 - thuộc tính
 - hoạt động
 - nhóm phát đa hướng

Hầu hết các thuộc tính trong lược đồ đều chấp nhận (hoặc trên thực tế yêu cầu) ZZ0000ZZ
thuộc tính phụ ghi lại đối tượng được xác định.

Các phần sau đây mô tả các thuộc tính của ZZ0001ZZ hiện đại nhất
lược đồ. Xem tài liệu của ZZ0000ZZ
để biết thông tin về cách tên C được bắt nguồn từ các thuộc tính tên.

Xem thêm ZZ0000ZZ để biết
thông tin về các thuộc tính đặc tả Netlink chỉ liên quan đến
không gian kernel chứ không phải là một phần của không gian người dùng API.

liên kết gen
=========

Quả cầu
-------

Các thuộc tính được liệt kê trực tiếp ở cấp độ gốc của tệp thông số kỹ thuật.

tên
~~~~

Tên của gia đình. Tên xác định gia đình theo một cách duy nhất, vì
ID gia đình được phân bổ động.

giao thức
~~~~~~~~

Mức lược đồ, mặc định là ZZ0000ZZ, là giá trị duy nhất
được phép cho dòng ZZ0001ZZ mới.

định nghĩa
-----------

Mảng kiểu và định nghĩa hằng.

tên
~~~~

Tên của loại/hằng số.

kiểu
~~~~

Một trong các loại sau:

- const - một hằng số độc lập
 - enum - định nghĩa một bảng liệt kê số nguyên, với các giá trị cho mỗi mục
   tăng thêm 1, (ví dụ: 0, 1, 2, 3)
 - cờ - xác định một bảng liệt kê số nguyên, với các giá trị cho mỗi mục
   chiếm một bit, bắt đầu từ bit 0, (ví dụ: 1, 2, 4, 8)

giá trị
~~~~~

Giá trị của ZZ0000ZZ.

giá trị bắt đầu
~~~~~~~~~~~

Giá trị đầu tiên cho ZZ0000ZZ và ZZ0001ZZ, cho phép ghi đè giá trị mặc định
giá trị bắt đầu của ZZ0002ZZ (đối với ZZ0003ZZ) và bit bắt đầu (đối với ZZ0004ZZ).
Đối với ZZ0005ZZ ZZ0006ZZ chọn bit bắt đầu, không phải giá trị được dịch chuyển.

Bảng liệt kê thưa thớt không được hỗ trợ.

mục
~~~~~~~

Mảng tên của các mục dành cho ZZ0000ZZ và ZZ0001ZZ.

tiêu đề
~~~~~~

Đối với các ngôn ngữ tương thích với C, tiêu đề đã xác định giá trị này.
Trong trường hợp định nghĩa được chia sẻ bởi nhiều họ (ví dụ ZZ0000ZZ)
trình tạo mã cho các ngôn ngữ tương thích với C có thể muốn thêm một ngôn ngữ thích hợp
include thay vì hiển thị một định nghĩa mới.

tập thuộc tính
--------------

Thuộc tính này chứa thông tin về các thuộc tính liên kết mạng của họ.
Tất cả các họ đều có ít nhất một tập thuộc tính, hầu hết đều có nhiều tập thuộc tính.
ZZ0000ZZ là một mảng, mỗi mục mô tả một tập hợp.

Lưu ý rằng thông số kỹ thuật được "làm phẳng" và không có nghĩa là trông giống
định dạng của các thông báo liên kết mạng (không giống như một số tài liệu đặc biệt
các định dạng nhìn thấy trong nhận xét kernel). Trong bộ thuộc tính phụ của spec
không được định nghĩa nội tuyến như một tổ mà được định nghĩa trong một tập thuộc tính riêng biệt
được gọi bằng thuộc tính ZZ0000ZZ của vùng chứa.

Thông số kỹ thuật cũng có thể chứa các bộ phân số - các bộ chứa ZZ0000ZZ
tài sản. Những bộ như vậy mô tả một phần của một bộ đầy đủ, cho phép thu hẹp
thuộc tính nào được phép trong tổ hoặc tinh chỉnh tiêu chí xác thực.
Tập hợp phân số chỉ có thể được sử dụng trong tổ. Chúng không được hiển thị cho uAPI
theo bất kỳ cách nào.

tên
~~~~

Xác định duy nhất tập thuộc tính, thao tác và thuộc tính lồng nhau
tham khảo các bộ của ZZ0000ZZ.

tập hợp con của
~~~~~~~~~

Xác định lại một phần của tập hợp khác (tập hợp phân số).
Cho phép thu hẹp các trường và thay đổi tiêu chí xác thực
hoặc thậm chí các loại thuộc tính tùy thuộc vào tổ mà chúng
được chứa. ZZ0000ZZ của mỗi thuộc tính trong phân số
tập hợp hoàn toàn giống như trong tập hợp chính.

thuộc tính
~~~~~~~~~~

Danh sách các thuộc tính trong tập hợp.

.. _attribute_properties:

Thuộc tính thuộc tính
--------------------

tên
~~~~

Xác định thuộc tính, duy nhất trong tập hợp.

kiểu
~~~~

Loại thuộc tính Netlink, xem ZZ0000ZZ.

.. _assign_val:

giá trị
~~~~~

ID thuộc tính số, được sử dụng trong các tin nhắn Netlink được tuần tự hóa.
Thuộc tính ZZ0000ZZ có thể được bỏ qua, trong trường hợp đó thuộc tính ID
sẽ là giá trị của thuộc tính trước đó cộng với một (đệ quy)
và ZZ0001ZZ cho thuộc tính đầu tiên trong bộ thuộc tính.

Các thuộc tính (và hoạt động) sử dụng ZZ0000ZZ làm giá trị mặc định cho lần đầu tiên
mục nhập (không giống như enum trong định nghĩa bắt đầu từ ZZ0001ZZ) vì
mục ZZ0002ZZ hầu như luôn được bảo lưu dưới dạng không xác định. Spec có thể rõ ràng
đặt giá trị thành ZZ0003ZZ nếu cần.

Lưu ý rằng ZZ0000ZZ của một thuộc tính chỉ được xác định trong tập chính của nó
(không có trong tập hợp con).

liệt kê
~~~~

Đối với kiểu số nguyên chỉ định các giá trị trong thuộc tính thuộc về
tới ZZ0000ZZ hoặc ZZ0001ZZ từ phần ZZ0002ZZ.

enum-như-cờ
~~~~~~~~~~~~~

Hãy coi ZZ0000ZZ là ZZ0001ZZ bất kể loại của nó trong ZZ0002ZZ.
Khi cần cả hai dạng ZZ0003ZZ và ZZ0004ZZ thì ZZ0005ZZ nên
chứa ZZ0006ZZ và các thuộc tính cần có dạng ZZ0007ZZ phải
sử dụng thuộc tính này.

thuộc tính lồng nhau
~~~~~~~~~~~~~~~~~

Xác định không gian thuộc tính cho các thuộc tính được lồng trong thuộc tính đã cho.
Chỉ hợp lệ cho các thuộc tính phức tạp có thể có thuộc tính phụ.

đa attr (mảng)
~~~~~~~~~~~~~~~~~~~

Thuộc tính Boolean biểu thị rằng thuộc tính có thể xuất hiện nhiều lần.
Cho phép một thuộc tính lặp lại là cách được khuyến nghị để triển khai mảng
(không lồng thêm).

thứ tự byte
~~~~~~~~~~

Đối với các loại số nguyên chỉ định thứ tự byte thuộc tính - ZZ0000ZZ
hoặc ZZ0001ZZ.

séc
~~~~~~

Các ràng buộc xác thực đầu vào được hạt nhân sử dụng. Không gian người dùng nên truy vấn
chính sách của kernel đang chạy bằng cách sử dụng tính năng xem xét nội bộ Netlink chung,
thay vì phụ thuộc vào những gì được chỉ định trong tệp thông số kỹ thuật.

Chính sách xác thực trong kernel được hình thành bằng cách kết hợp kiểu
định nghĩa (ZZ0000ZZ và ZZ0001ZZ) và ZZ0002ZZ.

tiểu loại
~~~~~~~~

Các họ kế thừa có những cách đặc biệt để thể hiện mảng. ZZ0001ZZ có thể
được sử dụng để xác định loại thành viên mảng trong trường hợp các thành viên mảng không
được xác định đầy đủ dưới dạng thuộc tính (trong không gian thuộc tính thực sự). Ví dụ
một mảng C gồm các giá trị u32 có thể được chỉ định bằng ZZ0002ZZ và
ZZ0003ZZ. Các kiểu nhị phân và định dạng mảng kế thừa được mô tả trong
chi tiết hơn trong ZZ0000ZZ.

gợi ý hiển thị
~~~~~~~~~~~~

Chỉ báo định dạng tùy chọn chỉ nhằm mục đích chọn đúng
cơ chế định dạng khi hiển thị các giá trị thuộc loại này. Hiện được hỗ trợ
gợi ý là ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ và ZZ0005ZZ.

hoạt động
----------

Phần này mô tả các thông điệp được truyền giữa kernel và không gian người dùng.
Có ba loại mục trong phần này - hoạt động, thông báo
và các sự kiện.

Các hoạt động mô tả giao tiếp yêu cầu - phản hồi phổ biến nhất. người dùng
gửi yêu cầu và trả lời kernel. Mỗi thao tác có thể chứa bất kỳ sự kết hợp nào
trong hai chế độ quen thuộc với người dùng netlink - ZZ0000ZZ và ZZ0001ZZ.
Lần lượt ZZ0002ZZ và ZZ0003ZZ chứa sự kết hợp của ZZ0004ZZ và
Thuộc tính ZZ0005ZZ. Nếu không có thông báo rõ ràng với các thuộc tính được chuyển
theo một hướng nhất định (ví dụ: ZZ0006ZZ không chấp nhận bộ lọc hoặc ZZ0007ZZ
của hoạt động SET mà hạt nhân phản hồi chỉ bằng lỗi liên kết mạng
code) Có thể bỏ qua phần ZZ0008ZZ hoặc ZZ0009ZZ.
Phần ZZ0010ZZ và ZZ0011ZZ liệt kê các thuộc tính được phép trong tin nhắn.
Danh sách chỉ chứa tên của các thuộc tính từ một tập hợp được tham chiếu
bởi thuộc tính ZZ0012ZZ.

Thông báo và sự kiện đều đề cập đến các tin nhắn không đồng bộ được gửi bởi
kernel cho các thành viên của một nhóm multicast. Sự khác biệt giữa
hai là thông báo chia sẻ nội dung của nó với thao tác GET
(tên của thao tác GET được chỉ định trong thuộc tính ZZ0000ZZ).
Sự sắp xếp này thường được sử dụng để thông báo về
đối tượng trong đó thông báo mang định nghĩa đối tượng đầy đủ.

Các sự kiện được tập trung hơn và chỉ mang theo một tập hợp thông tin chứ không phải đầy đủ
trạng thái đối tượng (một ví dụ tạo thành sẽ là một sự kiện thay đổi trạng thái liên kết chỉ với
tên giao diện và trạng thái liên kết mới). Các sự kiện chứa ZZ0000ZZ
tài sản. Các sự kiện được coi là ít thành ngữ hơn đối với liên kết mạng và thông báo
nên được ưu tiên.

danh sách
~~~~

Thuộc tính duy nhất của ZZ0000ZZ dành cho ZZ0001ZZ, nắm giữ danh sách
hoạt động, thông báo, v.v.

Thuộc tính hoạt động
--------------------

tên
~~~~

Xác định hoạt động.

giá trị
~~~~~

ID tin nhắn bằng số, được sử dụng trong các tin nhắn Netlink được tuần tự hóa.
Các quy tắc liệt kê tương tự được áp dụng cho
ZZ0000ZZ.

tập thuộc tính
~~~~~~~~~~~~~

Chỉ định tập thuộc tính có trong thông báo.

LÀM
~~~

Đặc điểm kỹ thuật cho yêu cầu ZZ0001ZZ. Nên chứa ZZ0002ZZ, ZZ0003ZZ
hoặc cả hai thuộc tính này, mỗi thuộc tính chứa ZZ0000ZZ.

bãi rác
~~~~

Đặc điểm kỹ thuật cho yêu cầu ZZ0001ZZ. Nên chứa ZZ0002ZZ, ZZ0003ZZ
hoặc cả hai thuộc tính này, mỗi thuộc tính chứa ZZ0000ZZ.

thông báo
~~~~~~

Chỉ định tin nhắn như một thông báo. Chứa tên của hoạt động
(có thể giống như hoạt động nắm giữ tài sản này) chia sẻ
nội dung có thông báo (ZZ0000ZZ).

sự kiện
~~~~~

Đặc tả các thuộc tính trong sự kiện, chứa ZZ0000ZZ.
Thuộc tính ZZ0001ZZ loại trừ lẫn nhau với ZZ0002ZZ.

mcgrp
~~~~~

Được sử dụng với ZZ0000ZZ và ZZ0001ZZ, chỉ định nhóm multicast nào
tin nhắn thuộc về.

.. _attr_list:

Danh sách thuộc tính tin nhắn
----------------------

Các thuộc tính ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ có một ZZ0003ZZ duy nhất
thuộc tính chứa danh sách tên thuộc tính.

Tin nhắn cũng có thể xác định các thuộc tính ZZ0000ZZ và ZZ0001ZZ sẽ được hiển thị
như các lệnh gọi ZZ0002ZZ và ZZ0003ZZ trong kernel (các thuộc tính này sẽ
bị bỏ qua bởi không gian người dùng).

nhóm mcast
------------

Phần này liệt kê các nhóm multicast của họ.

danh sách
~~~~

Thuộc tính duy nhất của ZZ0000ZZ dành cho ZZ0001ZZ, nắm giữ danh sách
của các nhóm.

Thuộc tính nhóm multicast
--------------------------

tên
~~~~

Xác định duy nhất nhóm multicast trong họ. Tương tự với
ID gia đình, ID nhóm Multicast cần được phân giải trong thời gian chạy, dựa trên
trên tên.

.. _attr_types:

Các loại thuộc tính
===============

Phần này mô tả các loại thuộc tính được ZZ0000ZZ hỗ trợ
mức độ tương thích. Tham khảo tài liệu ở các cấp độ khác nhau để biết thêm
các loại thuộc tính.

Các kiểu số nguyên thông dụng
--------------------

ZZ0000ZZ và ZZ0001ZZ đại diện cho số nguyên 64 bit có dấu và không dấu.
Nếu giá trị có thể vừa với 32 bit thì chỉ có 32 bit được mang trong liên kết mạng
tin nhắn, nếu không thì toàn bộ 64 bit sẽ được mang. Lưu ý rằng tải trọng
chỉ được căn chỉnh theo 4B, vì vậy giá trị 64 bit đầy đủ có thể không được căn chỉnh!

Phần lớn các loại số nguyên phổ biến nên được ưu tiên hơn các loại có chiều rộng cố định
của các trường hợp.

Các loại số nguyên có chiều rộng cố định
-----------------------

Các loại số nguyên có chiều rộng cố định bao gồm:
ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ, ZZ0005ZZ, ZZ0006ZZ, ZZ0007ZZ.

Lưu ý nên tránh sử dụng những loại nhỏ hơn 32 bit
không lưu bất kỳ bộ nhớ nào trong tin nhắn Netlink (do căn chỉnh).
Xem ZZ0000ZZ để biết phần đệm của thuộc tính 64 bit.

Tải trọng của thuộc tính là số nguyên theo thứ tự máy chủ trừ khi ZZ0000ZZ
chỉ định khác.

Các giá trị 64 bit thường được căn chỉnh bởi kernel nhưng được khuyến khích
rằng không gian người dùng có thể xử lý các giá trị không được căn chỉnh.

.. _pad_type:

đệm
---

Loại thuộc tính đặc biệt được sử dụng cho các thuộc tính đệm yêu cầu căn chỉnh
lớn hơn căn chỉnh 4B tiêu chuẩn mà netlink yêu cầu (ví dụ: số nguyên 64 bit).
Chỉ có thể có một thuộc tính duy nhất thuộc loại ZZ0000ZZ trong bất kỳ bộ thuộc tính nào
và nó sẽ được tự động sử dụng để đệm khi cần thiết.

lá cờ
----

Thuộc tính không có tải trọng, sự hiện diện của nó là toàn bộ thông tin.

nhị phân
------

Thuộc tính dữ liệu nhị phân thô, nội dung mờ đối với mã chung.

sợi dây
------

Chuỗi ký tự. Trừ khi ZZ0000ZZ có ZZ0001ZZ được đặt thành ZZ0002ZZ
chuỗi được yêu cầu phải được kết thúc bằng null.
ZZ0003ZZ trong ZZ0004ZZ cho biết chuỗi dài nhất có thể,
nếu không có thì độ dài của chuỗi là không giới hạn.

Lưu ý rằng ZZ0000ZZ không tính ký tự kết thúc.

tổ
----

Thuộc tính chứa các thuộc tính (lồng nhau) khác.
ZZ0000ZZ chỉ định bộ thuộc tính nào được sử dụng bên trong.