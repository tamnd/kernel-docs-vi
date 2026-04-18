.. SPDX-License-Identifier: BSD-3-Clause

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/netlink/genetlink-legacy.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=======================================================================
Hỗ trợ đặc tả Netlink cho các dòng Netlink chung cũ
=================================================================

Tài liệu này mô tả nhiều đặc điểm và thuộc tính bổ sung
cần thiết để mô tả các họ Generic Netlink cũ hơn hình thành
cấp độ giao thức ZZ0000ZZ.

Đặc điểm kỹ thuật
=============

Quả cầu
-------

Các thuộc tính được liệt kê trực tiếp ở cấp độ gốc của tệp thông số kỹ thuật.

phiên bản
~~~~~~~

Phiên bản gia đình Netlink chung, mặc định là 1.

ZZ0000ZZ trong lịch sử đã được sử dụng để giới thiệu những thay đổi về họ
có thể phá vỡ khả năng tương thích ngược. Vì những thay đổi phá vỡ khả năng tương thích
thường không được phép ZZ0001ZZ rất hiếm khi được sử dụng.

Tổ loại thuộc tính
--------------------

Các dòng Netlink mới nên sử dụng ZZ0000ZZ để xác định mảng.
Các gia đình cũ hơn (ví dụ: gia đình kiểm soát ZZ0001ZZ) đã cố gắng
xác định các loại mảng sử dụng lại loại thuộc tính để mang thông tin.

Để tham khảo, mảng ZZ0000ZZ có thể trông như thế này ::

[ARRAY-ATTR]
    [INDEX (tùy chọn)]
    [MEMBER1]
    [MEMBER2]
  [SOME-OTHER-ATTR]
  [ARRAY-ATTR]
    [INDEX (tùy chọn)]
    [MEMBER1]
    [MEMBER2]

trong đó ZZ0000ZZ là kiểu mục nhập mảng.

mảng được lập chỉ mục
~~~~~~~~~~~~~

ZZ0000ZZ bao bọc toàn bộ mảng trong một thuộc tính bổ sung (do đó
giới hạn kích thước của nó ở mức 64kB). Tổ ZZ0001ZZ rất đặc biệt và có
chỉ mục của mục nhập làm loại của chúng thay vì loại thuộc tính thông thường.

Cần có ZZ0000ZZ để mô tả loại nào trong ZZ0001ZZ. MỘT ZZ0002ZZ
ZZ0003ZZ có nghĩa là có các mảng lồng nhau trong ZZ0004ZZ, với cấu trúc
trông giống như::

[SOME-OTHER-ATTR]
  [ARRAY-ATTR]
    [ENTRY]
      [MEMBER1]
      [MEMBER2]
    [ENTRY]
      [MEMBER1]
      [MEMBER2]

ZZ0000ZZ khác như ZZ0001ZZ nghĩa là chỉ có một thành viên như mô tả
trong ZZ0002ZZ trong ZZ0003ZZ. Cấu trúc trông giống như::

[SOME-OTHER-ATTR]
  [ARRAY-ATTR]
    [ENTRY u32]
    [ENTRY u32]

giá trị loại
~~~~~~~~~~

ZZ0000ZZ là một cấu trúc sử dụng các loại thuộc tính để mang
thông tin về một đối tượng (thường được sử dụng khi kết xuất mảng
theo từng mục nhập).

Ví dụ: ZZ0000ZZ có thể có nhiều cấp độ lồng nhau
kết xuất chính sách của Genetlink tạo ra các cấu trúc sau ::

[POLICY-IDX]
    [ATTR-IDX]
      [POLICY-INFO-ATTR1]
      [POLICY-INFO-ATTR2]

Trong đó cấp độ lồng đầu tiên có chỉ mục chính sách làm thuộc tính
loại, nó chứa một tổ duy nhất có chỉ mục thuộc tính là
loại. Bên trong tổ attr-index là các thuộc tính chính sách. hiện đại
Thay vào đó, các họ Netlink nên định nghĩa đây là một cấu trúc phẳng,
việc làm tổ không phục vụ mục đích tốt ở đây.

Hoạt động
==========

Mô hình Enum (ID tin nhắn)
-----------------------

thống nhất
~~~~~~~

Các gia đình hiện đại sử dụng mô hình ID tin nhắn ZZ0000ZZ, sử dụng
một bảng liệt kê duy nhất cho tất cả các tin nhắn trong họ. Yêu cầu và
phản hồi chia sẻ cùng một ID tin nhắn. Thông báo có riêng biệt
ID từ cùng một không gian. Ví dụ đưa ra danh sách sau đây
của hoạt động:

.. code-block:: yaml

  -
    name: a
    value: 1
    do: ...
  -
    name: b
    do: ...
  -
    name: c
    value: 4
    notify: a
  -
    name: d
    do: ...

Các yêu cầu và phản hồi cho hoạt động ZZ0000ZZ sẽ có ID là 1,
các yêu cầu và phản hồi của ZZ0001ZZ - 2 (vì không có quy định rõ ràng
ZZ0002ZZ là hoạt động trước đó ZZ0003ZZ). Thông báo ZZ0004ZZ sẽ
sử dụng ID của 4, thao tác ZZ0005ZZ 5, v.v.

định hướng
~~~~~~~~~~~

Mô hình ZZ0000ZZ phân chia việc gán ID theo hướng
tin nhắn. Các tin nhắn từ và đến kernel không thể bị nhầm lẫn với
lẫn nhau nên điều này bảo toàn không gian ID (với chi phí tạo ra
việc lập trình trở nên cồng kềnh hơn).

Trong trường hợp này thuộc tính ZZ0000ZZ phải được chỉ định trong ZZ0001ZZ
Các phần ZZ0002ZZ của thao tác (nếu một thao tác có cả ZZ0003ZZ
và ZZ0004ZZ các ID được chia sẻ, ZZ0005ZZ phải được đặt trong ZZ0006ZZ).
Đối với thông báo, ZZ0007ZZ được cung cấp ở cấp độ hoạt động nhưng nó
chỉ phân bổ ZZ0008ZZ (tức là ID "từ hạt nhân"). Hãy nhìn
ở một ví dụ:

.. code-block:: yaml

  -
    name: a
    do:
      request:
        value: 2
        attributes: ...
      reply:
        value: 1
        attributes: ...
  -
    name: b
    notify: a
  -
    name: c
    notify: a
    value: 7
  -
    name: d
    do: ...

Trong trường hợp này ZZ0000ZZ sẽ sử dụng 2 khi gửi tin nhắn đến kernel
và mong đợi tin nhắn có ID 1 phản hồi. Thông báo ZZ0001ZZ phân bổ
ID "từ hạt nhân" là 2. ZZ0002ZZ phân bổ ID "từ hạt nhân" là 7.
Nếu hoạt động ZZ0003ZZ không đặt ZZ0004ZZ rõ ràng trong thông số kỹ thuật
nó sẽ được phân bổ 3 cho yêu cầu (ZZ0005ZZ là hoạt động trước đó
với phần yêu cầu và giá trị là 2) và 8 cho phản hồi (ZZ0006ZZ là
thao tác trước đó theo hướng "từ hạt nhân").

Những điều kỳ quặc khác
============

Cấu trúc
----------

Các họ kế thừa có thể định nghĩa cả hai cấu trúc C để được sử dụng làm nội dung của
một thuộc tính và như một tiêu đề thư cố định. Cấu trúc được xác định trong
ZZ0000ZZ và được tham chiếu trong các hoạt động hoặc thuộc tính.

thành viên
~~~~~~~

- ZZ0001ZZ - Tên thuộc tính của thành viên struct
 - ZZ0002ZZ - Một trong các loại vô hướng ZZ0003ZZ, ZZ0004ZZ, ZZ0005ZZ, ZZ0006ZZ, ZZ0007ZZ,
   ZZ0008ZZ, ZZ0009ZZ, ZZ0010ZZ, ZZ0011ZZ, ZZ0012ZZ hoặc ZZ0013ZZ.
 - ZZ0014ZZ - ZZ0015ZZ hoặc ZZ0016ZZ
 - ZZ0017ZZ, ZZ0018ZZ, ZZ0019ZZ, ZZ0020ZZ - Tương tự như đối với
   ZZ0000ZZ

Lưu ý rằng các cấu trúc được xác định trong YAML được đóng gói ngầm theo C
quy ước. Ví dụ: cấu trúc sau là 4 byte, không phải 6 byte:

.. code-block:: c

  struct {
          u8 a;
          u16 b;
          u8 c;
  }

Mọi phần đệm phải được thêm rõ ràng và các ngôn ngữ giống C sẽ suy ra
cần có phần đệm rõ ràng để xem liệu các thành viên có được căn chỉnh tự nhiên hay không.

Đây là định nghĩa cấu trúc ở trên, được khai báo trong YAML:

.. code-block:: yaml

  definitions:
    -
      name: message-header
      type: struct
      members:
        -
          name: a
          type: u8
        -
          name: b
          type: u16
        -
          name: c
          type: u8

Tiêu đề cố định
~~~~~~~~~~~~~

Tiêu đề thư cố định có thể được thêm vào hoạt động bằng ZZ0000ZZ.
ZZ0001ZZ mặc định có thể được đặt trong ZZ0002ZZ và nó có thể được đặt
hoặc ghi đè cho mỗi thao tác.

.. code-block:: yaml

  operations:
    fixed-header: message-header
    list:
      -
        name: get
        fixed-header: custom-header
        attribute-set: message-attrs

Thuộc tính
~~~~~~~~~~

Thuộc tính ZZ0000ZZ có thể được hiểu là cấu trúc C bằng cách sử dụng
Thuộc tính ZZ0001ZZ với tên của định nghĩa cấu trúc. các
Thuộc tính ZZ0002ZZ ngụ ý ZZ0003ZZ nên không cần thiết phải
chỉ định một loại phụ.

.. code-block:: yaml

  attribute-sets:
    -
      name: stats-attrs
      attributes:
        -
          name: stats
          type: binary
          struct: vport-stats

Mảng C
--------

Các dòng kế thừa cũng sử dụng thuộc tính ZZ0000ZZ để đóng gói mảng C. các
ZZ0001ZZ được sử dụng để xác định loại vô hướng cần trích xuất.

.. code-block:: yaml

  attributes:
    -
      name: ports
      type: binary
      sub-type: u32

LÀM nhiều tin nhắn
----------------

Các dòng Netlink mới sẽ không bao giờ phản hồi lại thao tác DO với nhiều
trả lời, với bộ ZZ0000ZZ. Thay vào đó hãy sử dụng bãi chứa đã được lọc.

Ở cấp độ thông số kỹ thuật, chúng ta có thể xác định thuộc tính ZZ0000ZZ cho ZZ0001ZZ,
có lẽ với các giá trị ZZ0002ZZ và ZZ0003ZZ tùy thuộc vào
về cách thực hiện phân tích cú pháp (phân tích cú pháp thành một câu trả lời duy nhất
so với danh sách các đối tượng, tức là gần như một bãi chứa).