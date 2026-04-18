.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/assoc_array.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============================================
Triển khai mảng kết hợp chung
========================================

Tổng quan
========

Việc triển khai mảng kết hợp này là một vùng chứa đối tượng với các thành phần sau:
thuộc tính:

1. Đối tượng là con trỏ mờ.  Việc thực hiện không quan tâm họ ở đâu
   điểm (nếu ở bất cứ đâu) hoặc những gì họ trỏ tới (nếu có).

   .. note::

      Pointers to objects _must_ be zero in the least significant bit.

2. Các đối tượng không cần chứa các khối liên kết để mảng sử dụng.  Cái này
   cho phép một đối tượng được định vị trong nhiều mảng cùng một lúc.
   Đúng hơn, mảng được tạo thành từ các khối siêu dữ liệu trỏ đến các đối tượng.

3. Các đối tượng yêu cầu khóa chỉ mục để định vị chúng trong mảng.

4. Khóa chỉ mục phải là duy nhất.  Chèn một đối tượng có cùng khóa với một đối tượng
   đã có trong mảng sẽ thay thế đối tượng cũ.

5. Khóa chỉ mục có thể có độ dài bất kỳ và có thể có độ dài khác nhau.

6. Khóa chỉ mục phải mã hóa độ dài sớm trước khi có bất kỳ biến thể nào do
   chiều dài được nhìn thấy

7. Khóa chỉ mục có thể bao gồm hàm băm để phân tán các đối tượng trong mảng.

8. Mảng có thể lặp lại.  Các đối tượng sẽ không nhất thiết phải xuất hiện trong
   thứ tự khóa.

9. Mảng có thể được lặp đi lặp lại trong khi nó đang được sửa đổi, miễn là
   Khóa đọc RCU đang được giữ bởi trình vòng lặp.  Tuy nhiên, lưu ý rằng dưới những điều này
   trường hợp, một số đồ vật có thể được nhìn thấy nhiều lần.  Nếu đây là một
   vấn đề, trình lặp sẽ khóa chống sửa đổi.  Các đối tượng sẽ không
   tuy nhiên, có thể bị bỏ qua, trừ khi bị xóa.

10. Các đối tượng trong mảng có thể được tra cứu bằng khóa chỉ mục của chúng.

11. Các đối tượng có thể được tra cứu trong khi mảng đang được sửa đổi, miễn là
    Khóa đọc RCU đang được giữ bởi luồng đang thực hiện tra cứu.

Việc triển khai sử dụng cây gồm các nút 16 con trỏ bên trong được lập chỉ mục
ở mỗi cấp độ bằng cách nhấm nháp từ khóa chỉ mục theo cách tương tự như trong cơ số
cây.  Để cải thiện hiệu suất bộ nhớ, có thể đặt các phím tắt để bỏ qua
nếu không thì sẽ là một loạt các nút dành cho một người.  Hơn nữa, các nút
gói các con trỏ đối tượng lá vào không gian trống trong nút thay vì tạo một
nhánh bổ sung cho đến khi một đối tượng cần được thêm vào một nút đầy đủ.


API công cộng
==============

API công khai có thể được tìm thấy trong ZZ0000ZZ.  sự kết hợp
mảng được bắt nguồn từ cấu trúc sau::

cấu trúc PGS_array {
            ...
    };

Mã được chọn bằng cách bật ZZ0000ZZ với::

./script/config -e ASSOCIATIVE_ARRAY


Chỉnh sửa tập lệnh
-----------

Các chức năng chèn và xóa tạo ra một 'tập lệnh chỉnh sửa' mà sau này có thể được sử dụng
được áp dụng để thực hiện các thay đổi mà không gây rủi ro cho ZZ0000ZZ. Điều này giữ lại
các khối siêu dữ liệu được phân bổ trước sẽ được cài đặt trong cây nội bộ và
theo dõi các khối siêu dữ liệu sẽ bị xóa khỏi cây khi
kịch bản được áp dụng.

Điều này cũng được sử dụng để theo dõi các khối chết và các vật thể chết sau khi
tập lệnh đã được áp dụng để chúng có thể được giải phóng sau này.  Việc giải phóng đã xong
sau khi thời gian gia hạn RCU trôi qua - do đó cho phép các chức năng truy cập
tiến hành theo khóa đọc RCU.

Tập lệnh xuất hiện bên ngoài API dưới dạng con trỏ thuộc loại::

cấu trúc PGS_array_edit;

Có hai chức năng để xử lý tập lệnh:

1. Áp dụng tập lệnh chỉnh sửa::

void assoc_array_apply_edit(struct assoc_array_edit *edit);

Điều này sẽ thực hiện các chức năng chỉnh sửa, nội suy các rào cản ghi khác nhau
   để cho phép tiếp tục truy cập theo khóa đọc RCU.  Kịch bản chỉnh sửa
   sau đó sẽ được chuyển đến ZZ0000ZZ để giải phóng nó và mọi thứ đã chết trong đó
   trỏ đến.

2. Hủy tập lệnh chỉnh sửa::

void assoc_array_cancel_edit(struct assoc_array_edit *edit);

Điều này giải phóng tập lệnh chỉnh sửa và tất cả bộ nhớ được phân bổ trước ngay lập tức. Nếu
   đây là để chèn, đối tượng mới là ZZ0000ZZ được phát hành bởi chức năng này,
   nhưng đúng hơn là phải được người gọi giải phóng.

Các chức năng này được đảm bảo không bị lỗi.


Bảng hoạt động
----------------

Các chức năng khác nhau có một bảng hoạt động::

cấu trúc PGS_array_ops {
            ...
    };

Điều này chỉ ra một số phương pháp, tất cả đều cần được cung cấp:

1. Lấy một đoạn khóa chỉ mục từ dữ liệu người gọi::

dài không dấu (*get_key_chunk)(const void *index_key, cấp int);

Điều này sẽ trả về một đoạn khóa chỉ mục do người gọi cung cấp bắt đầu từ
   Vị trí ZZ0002ZZ được đưa ra bởi đối số cấp độ.  Đối số cấp độ sẽ là một
   bội số của ZZ0000ZZ và hàm sẽ trả về
   ZZ0001ZZ.  Không có lỗi có thể xảy ra.


2. Lấy một đoạn khóa chỉ mục của đối tượng::

dài không dấu (*get_object_key_chunk)(const void *object, cấp int);

Như hàm trước nhưng lấy dữ liệu từ một đối tượng trong mảng
   thay vì từ khóa chỉ mục do người gọi cung cấp.


3. Xem đây có phải là đối tượng chúng ta đang tìm kiếm không::

bool (*compare_object)(const void *object, const void *index_key);

So sánh đối tượng với khóa chỉ mục và trả về ZZ0000ZZ nếu nó khớp
   và ZZ0001ZZ nếu không.


4. Phân biệt khóa chỉ mục của hai đối tượng::

int (*diff_objects)(const void *object, const void *index_key);

Trả về vị trí bit tại đó khóa chỉ mục của đối tượng đã chỉ định
   khác với khóa chỉ mục đã cho hoặc -1 nếu chúng giống nhau.


5. Giải phóng một đối tượng::

khoảng trống (*free_object)(void *object);

Giải phóng đối tượng được chỉ định.  Lưu ý rằng đây có thể được gọi là thời gian gia hạn RCU
   sau khi ZZ0000ZZ được gọi, vì vậy ZZ0001ZZ có thể
   cần thiết khi dỡ tải mô-đun.


Chức năng thao tác
----------------------

Có một số hàm để thao tác với mảng kết hợp:

1. Khởi tạo một mảng kết hợp::

void assoc_array_init(struct assoc_array *array);

Điều này khởi tạo cấu trúc cơ sở cho một mảng kết hợp.  Nó không thể thất bại.


2. Chèn/thay thế một đối tượng trong mảng kết hợp::

cấu trúc PGS_array_edit *
    PGS_array_insert(struct assoc_array *mảng,
                       const struct assoc_array_ops *ops,
                       const void *index_key,
                       void *đối tượng);

Điều này chèn đối tượng đã cho vào mảng.  Lưu ý rằng ít nhất
   Bit quan trọng của con trỏ phải bằng 0 vì nó được sử dụng để đánh dấu kiểu
   con trỏ bên trong.

Nếu một đối tượng đã tồn tại cho khóa đó thì nó sẽ được thay thế bằng
   đối tượng mới và đối tượng cũ sẽ được giải phóng tự động.

Đối số ZZ0000ZZ sẽ chứa thông tin khóa chỉ mục và
   được chuyển đến các phương thức trong bảng ops khi chúng được gọi.

Hàm này không làm thay đổi bản thân mảng mà trả về
   một tập lệnh chỉnh sửa phải được áp dụng.  ZZ0000ZZ được trả lại trong trường hợp
   lỗi hết bộ nhớ.

Người gọi nên khóa riêng đối với các sửa đổi khác của mảng.


3. Xóa một đối tượng khỏi mảng kết hợp::

cấu trúc PGS_array_edit *
    PGS_array_delete(struct assoc_array *mảng,
                       const struct assoc_array_ops *ops,
                       const void *index_key);

Thao tác này sẽ xóa một đối tượng khớp với dữ liệu đã chỉ định khỏi mảng.

Đối số ZZ0000ZZ sẽ chứa thông tin khóa chỉ mục và
   được chuyển đến các phương thức trong bảng ops khi chúng được gọi.

Hàm này không làm thay đổi bản thân mảng mà trả về
   một tập lệnh chỉnh sửa phải được áp dụng.  ZZ0000ZZ được trả lại trong trường hợp
   lỗi hết bộ nhớ.  ZZ0001ZZ sẽ được trả về nếu đối tượng được chỉ định
   không được tìm thấy trong mảng.

Người gọi nên khóa riêng đối với các sửa đổi khác của mảng.


4. Xóa tất cả các đối tượng khỏi một mảng kết hợp::

cấu trúc PGS_array_edit *
    PGS_array_clear(struct PGS_array *mảng,
                      const struct assoc_array_ops *ops);

Thao tác này sẽ xóa tất cả các đối tượng khỏi một mảng kết hợp và để lại nó
   hoàn toàn trống rỗng.

Hàm này không làm thay đổi bản thân mảng mà trả về
   một tập lệnh chỉnh sửa phải được áp dụng.  ZZ0000ZZ được trả lại trong trường hợp
   lỗi hết bộ nhớ.

Người gọi nên khóa riêng đối với các sửa đổi khác của mảng.


5. Phá hủy một mảng kết hợp, xóa tất cả các đối tượng::

void assoc_array_destroy(struct assoc_array *array,
                             const struct assoc_array_ops *ops);

Điều này phá hủy nội dung của mảng kết hợp và để lại nó
   hoàn toàn trống rỗng.  Không được phép cho một luồng khác đi ngang qua
   mảng dưới khóa đọc RCU cùng lúc với chức năng này
   phá hủy nó vì không có sự trì hoãn RCU nào được thực hiện khi giải phóng bộ nhớ -
   một cái gì đó sẽ yêu cầu bộ nhớ được phân bổ.

Người gọi nên khóa riêng đối với các công cụ sửa đổi và truy cập khác
   của mảng.


6. Rác thu thập một mảng kết hợp::

int assoc_array_gc(struct assoc_array *array,
                       const struct assoc_array_ops *ops,
                       bool (*iterator)(void *object, void *iterator_data),
                       void *iterator_data);

Điều này lặp lại các đối tượng trong một mảng kết hợp và chuyển từng đối tượng
   tới ZZ0000ZZ.  Nếu ZZ0001ZZ trả về ZZ0002ZZ, đối tượng sẽ được giữ lại.
   Nếu nó trả về ZZ0003ZZ, đối tượng sẽ được giải phóng.  Nếu ZZ0004ZZ
   trả về ZZ0005ZZ, nó phải thực hiện bất kỳ lần đếm lại thích hợp nào
   tăng dần trên đối tượng trước khi quay trở lại.

Cây bên trong sẽ được đóng gói nếu có thể như một phần của vòng lặp
   để giảm số lượng nút trong đó.

ZZ0000ZZ được chuyển trực tiếp tới ZZ0001ZZ và ngược lại
   bị hàm này bỏ qua.

Hàm sẽ trả về ZZ0000ZZ nếu thành công và ZZ0001ZZ nếu không thành công
   đủ bộ nhớ.

Các luồng khác có thể lặp lại hoặc tìm kiếm mảng bên dưới
   khóa đọc RCU trong khi chức năng này đang được thực hiện.  Người gọi nên
   lock dành riêng cho các sửa đổi khác của mảng.


Chức năng truy cập
----------------

Có hai hàm để truy cập một mảng kết hợp:

1. Lặp lại tất cả các đối tượng trong một mảng kết hợp::

int assoc_array_iterate(const struct assoc_array *array,
                            int (*iterator)(const void *object,
                                            void *iterator_data),
                            void *iterator_data);

Điều này chuyển từng đối tượng trong mảng tới hàm gọi lại iterator.
   ZZ0000ZZ là dữ liệu riêng tư cho chức năng đó.

Điều này có thể được sử dụng trên một mảng cùng lúc với mảng đang được
   đã sửa đổi, miễn là khóa đọc RCU được giữ.  Trong hoàn cảnh như vậy,
   hàm lặp có thể nhìn thấy một số đối tượng hai lần.  Nếu
   đây là một vấn đề thì việc sửa đổi phải bị khóa lại.  các
   Tuy nhiên, thuật toán lặp không được bỏ sót bất kỳ đối tượng nào.

Hàm sẽ trả về ZZ0000ZZ nếu không có đối tượng nào trong mảng, nếu không thì nó
   sẽ trả về kết quả của hàm lặp cuối cùng được gọi.  Lặp lại
   dừng ngay lập tức nếu bất kỳ lệnh gọi nào đến hàm lặp dẫn đến một
   lợi nhuận khác không.


2. Tìm một đối tượng trong mảng kết hợp::

khoảng trống *assoc_array_find(const struct assoc_array *array,
                           const struct assoc_array_ops *ops,
                           const void *index_key);

Điều này đi qua cây bên trong của mảng trực tiếp đến đối tượng
   được chỉ định bởi khóa chỉ mục.

Điều này có thể được sử dụng trên một mảng cùng lúc với mảng đang được
   đã sửa đổi, miễn là khóa đọc RCU được giữ.

Hàm sẽ trả về đối tượng nếu tìm thấy (và đặt ZZ0000ZZ thành
   loại đối tượng) hoặc sẽ trả về ZZ0001ZZ nếu không tìm thấy đối tượng.


Biểu mẫu khóa chỉ mục
--------------

Khóa chỉ mục có thể ở bất kỳ dạng nào, nhưng vì thuật toán không cho biết thời gian tồn tại của nó là bao lâu.
điều quan trọng là, chúng tôi đặc biệt khuyến nghị rằng khóa chỉ mục bao gồm độ dài của nó
từ rất sớm trước khi bất kỳ sự thay đổi nào do độ dài sẽ ảnh hưởng đến
so sánh.

Điều này sẽ làm cho các lá có phím có độ dài khác nhau bị phân tán ra khỏi mỗi phím.
khác - và những phím có cùng độ dài để phân cụm lại với nhau.

Người ta cũng khuyên rằng khóa chỉ mục nên bắt đầu bằng hàm băm của phần còn lại của
key để tối đa hóa sự phân tán trong không gian phím.

Sự phân tán càng tốt thì cây bên trong sẽ càng rộng và thấp hơn.

Sự phân tán kém không phải là vấn đề quá lớn vì có các phím tắt và nút
có thể chứa hỗn hợp các lá và con trỏ siêu dữ liệu.

Khóa chỉ mục được đọc theo từng đoạn từ máy.  Mỗi đoạn được chia thành
một nibble (4 bit) cho mỗi cấp độ, vì vậy trên CPU 32 bit, điều này phù hợp với 8 cấp độ và
trên CPU 64 bit, 16 cấp độ.  Trừ khi sự tán xạ thực sự kém, nếu không thì
không chắc rằng sẽ phải có nhiều hơn một từ của bất kỳ khóa chỉ mục cụ thể nào
đã sử dụng.


Hoạt động nội bộ
=================

Cấu trúc dữ liệu mảng kết hợp có một cây bên trong.  Cây này là
được xây dựng từ hai loại khối siêu dữ liệu: nút và lối tắt.

Một nút là một mảng các vị trí.  Mỗi vị trí có thể chứa một trong bốn thứ:

* Con trỏ NULL, cho biết khe trống.
* Một con trỏ tới một đối tượng (một chiếc lá).
* Một con trỏ tới một nút ở cấp độ tiếp theo.
* Một con trỏ tới một phím tắt.


Bố cục cây nội bộ cơ bản
--------------------------

Tạm thời bỏ qua các phím tắt, các nút sẽ tạo thành một cây đa cấp.  chỉ số
không gian khóa được chia nhỏ hoàn toàn cho các nút trong cây và các nút xuất hiện trên
mức độ cố định.  Ví dụ::

Cấp độ: 0 1 2 3
        ================ =============================== =================
                                                        NODE D
                        NODE B NODE C +------>+---+
                +------>+---+ +------>+---+ ZZ0000ZZ 0 |
        NODE A ZZ0001ZZ 0 ZZ0002ZZ ZZ0003ZZ |       +---+
        +---+ ZZ0004ZZ +---+ |       : :
        ZZ0005ZZ ZZ0006ZZ : : |       +---+
        +---+ ZZ0007ZZ +---+ ZZ0008ZZ f |
        ZZ0009ZZ---+ ZZ0010ZZ---+ ZZ0011ZZ---+ +---+
        +---+ +---+ +---+
        : : : : ZZ0012ZZ---+
        +---+ +---+ +---+ |       NODE E
        ZZ0013ZZ---+ ZZ0014ZZ : : +------>+---+
        +---+ ZZ0015ZZ 0 |
        ZZ0016ZZ ZZ0017ZZ f |           +---+
        +---+ |                       +---+ : :
                |       NODE F +---+
                +------>+---+ ZZ0018ZZ
                        ZZ0019ZZ NODE G +---+
                        +---+ +------>+---+
                        : : ZZ0020ZZ 0 |
                        +---+ |       +---+
                        ZZ0021ZZ---+ : :
                        +---+ +---+
                        : : ZZ0022ZZ
                        +---+ +---+
                        ZZ0023ZZ
                        +---+

Trong ví dụ trên, có 7 nút (A-G), mỗi nút có 16 vị trí (0-f).
Giả sử không có nút siêu dữ liệu nào khác trong cây, không gian khóa được chia
do đó:

============ ====
    KEY PREFIX NODE
    ============ ====
    137*D
    138* Đ
    13[0-69-f]* C
    1[0-24-f]* B
    e6* G
    e[0-57-f]* F
    [02-df]* A
    ============ ====

Vì vậy, ví dụ: các khóa có khóa chỉ mục ví dụ sau sẽ được tìm thấy trong
các nút thích hợp:

================ ======= ====
    INDEX KEY PREFIX NODE
    ================ ======= ====
    13694892892489 13 C
    13795289025897 137 D
    13889dde88793 138 E
    138bbb89003093 138 E
    1394879524789 12 C
    1458952489 1 B
    9431809de993ba \- A
    b4542910809cd \- A
    e5284310def98 e F
    e68428974237 e6 G
    e7fffcbd443 e F
    f3842239082 \- A
    ================ ======= ====

Để tiết kiệm bộ nhớ, nếu một nút có thể chứa tất cả các lá trong phần không gian khóa của nó,
thì nút sẽ có tất cả những lá đó trong đó và sẽ không có bất kỳ siêu dữ liệu nào
con trỏ - ngay cả khi một số lá đó muốn ở cùng một vị trí.

Một nút có thể chứa sự kết hợp không đồng nhất của các lá và con trỏ siêu dữ liệu.
Con trỏ siêu dữ liệu phải nằm trong các vị trí khớp với phân mục khóa của chúng
không gian.  Các lá có thể nằm ở bất kỳ vị trí nào không bị con trỏ siêu dữ liệu chiếm giữ.  Nó
được đảm bảo rằng không có lá nào trong một nút sẽ khớp với một vị trí bị chiếm giữ bởi một nút
con trỏ siêu dữ liệu.  Nếu con trỏ siêu dữ liệu ở đó, bất kỳ lá nào có khóa khớp với
tiền tố khóa siêu dữ liệu phải nằm trong cây con mà con trỏ siêu dữ liệu trỏ tới
đến.

Trong danh sách ví dụ về các khóa chỉ mục ở trên, nút A sẽ chứa:

==== ====================================
    SLOT CONTENT INDEX KEY (PREFIX)
    ==== ====================================
    1 PTR ĐẾN NODE B 1*
    bất kỳ LEAF 9431809de993ba nào
    bất kỳ LEAF b4542910809cd nào
    e PTR ĐẾN NODE F e*
    bất kỳ LEAF f3842239082 nào
    ==== ====================================

và nút B:

==== ====================================
    SLOT CONTENT INDEX KEY (PREFIX)
    ==== ====================================
    3 PTR ĐẾN NODE C 13*
    bất kỳ LEAF 1458952489
    ==== ====================================


Phím tắt
---------

Phím tắt là bản ghi siêu dữ liệu nhảy qua một phần không gian phím.  Một phím tắt
là sự thay thế cho một loạt các nút chiếm một chỗ tăng dần qua
cấp độ.  Các phím tắt tồn tại để tiết kiệm bộ nhớ và tăng tốc độ truyền tải.

Có thể gốc của cây là một lối tắt - ví dụ:
cây chứa ít nhất 17 nút, tất cả đều có tiền tố khóa ZZ0000ZZ.  các
thuật toán chèn sẽ chèn một phím tắt để bỏ qua không gian phím ZZ0001ZZ
trong một giới hạn duy nhất và đạt đến cấp độ thứ tư nơi những thứ này thực sự trở thành
khác nhau.


Tách và thu gọn các nút
------------------------------

Mỗi nút có công suất tối đa là 16 lá và con trỏ siêu dữ liệu.  Nếu
Thuật toán chèn phát hiện ra rằng nó đang cố gắng chèn đối tượng thứ 17 vào
nút, nút đó sẽ được phân chia sao cho ít nhất hai lá có chung
đoạn khóa ở cấp độ đó kết thúc ở một nút riêng biệt bắt nguồn từ vị trí đó cho
đoạn khóa chung đó.

Nếu các lá trong một nút đầy đủ và lá đang được chèn vào
đủ giống nhau thì một phím tắt sẽ được chèn vào cây.

Khi số lượng đối tượng trong cây con có gốc tại một nút giảm xuống còn 16 hoặc
ít hơn thì cây con sẽ được thu gọn thành một nút duy nhất - và điều này sẽ
gợn về phía gốc nếu có thể.


Lặp lại không đệ quy
-----------------------

Mỗi nút và phím tắt chứa một con trỏ quay lại tới nút cha của nó và số lượng
vị trí trong cha mẹ đó trỏ đến nó.  Phép lặp không đệ quy sử dụng những điều này để
tiến từ gốc qua cây, tới nút cha, khe N+1 để
đảm bảo tiến trình được thực hiện mà không cần ngăn xếp.

Tuy nhiên, các con trỏ lùi làm cho việc thay đổi và lặp lại đồng thời trở nên phức tạp.


Thay đổi và lặp lại đồng thời
-------------------------------------

Có một số trường hợp cần xem xét:

1. Chèn/thay thế đơn giản.  Điều này chỉ đơn giản là thay thế một chiếc NULL hoặc chiếc cũ
   khớp con trỏ lá với con trỏ tới lá mới sau rào chắn.
   Các khối siêu dữ liệu không thay đổi theo cách khác.  Một chiếc lá già sẽ không được giải thoát
   cho đến sau thời gian gia hạn RCU.

2. Xóa đơn giản.  Điều này chỉ liên quan đến việc xóa một chiếc lá phù hợp cũ.  các
   khối siêu dữ liệu không thay đổi theo cách khác.  Chiếc lá cũ sẽ không được giải phóng cho đến khi
   sau thời gian gia hạn RCU.

3. Chèn thay thế một phần cây con mà chúng ta chưa nhập.  Cái này
   có thể liên quan đến việc thay thế một phần của cây con đó - nhưng điều đó sẽ không ảnh hưởng
   việc lặp lại vì chúng ta chưa chạm tới con trỏ tới nó và
   các khối tổ tiên không được thay thế (bố cục của những khối đó không thay đổi).

4. Nút chèn thay thế mà chúng tôi đang tích cực xử lý.  Đây không phải là một
   vấn đề khi chúng ta đã vượt qua con trỏ neo và không chuyển sang
   bố cục mới cho đến khi chúng ta làm theo các con trỏ quay lại - lúc đó chúng ta đã
   đã kiểm tra các lá trong nút được thay thế (chúng tôi lặp lại tất cả các
   rời khỏi một nút trước khi đi theo bất kỳ con trỏ siêu dữ liệu nào của nó).

Tuy nhiên, chúng ta có thể thấy lại một số lá đã được tách thành một lá mới
   nhánh nằm ở một khe xa hơn chỗ chúng tôi ở.

5. Chèn thay thế các nút mà chúng tôi đang xử lý một nhánh phụ thuộc.
   Điều này sẽ không ảnh hưởng đến chúng tôi cho đến khi chúng tôi làm theo các gợi ý phía sau.  Tương tự như (4).

6. Xóa một nhánh thuộc quyền của chúng tôi.  Điều này không ảnh hưởng đến chúng tôi vì
   con trỏ ngược sẽ đưa chúng ta trở lại nút cha của nút mới trước khi chúng ta
   có thể thấy nút mới.  Toàn bộ cây con bị sập sẽ bị vứt đi
   không thay đổi - và vẫn sẽ được root trên cùng một slot, vì vậy chúng ta không nên
   xử lý lần thứ hai vì chúng ta sẽ quay lại vị trí + 1.

.. note::

   Under some circumstances, we need to simultaneously change the parent
   pointer and the parent slot pointer on a node (say, for example, we
   inserted another node before it and moved it up a level).  We cannot do
   this without locking against a read - so we have to replace that node too.

   However, when we're changing a shortcut into a node this isn't a problem
   as shortcuts only have one slot and so the parent slot number isn't used
   when traversing backwards over one.  This means that it's okay to change
   the slot number first - provided suitable barriers are used to make sure
   the parent slot number is read after the back pointer.

Các khối và lá lỗi thời được giải phóng sau khi thời gian gia hạn RCU trôi qua,
vì vậy, miễn là bất kỳ ai thực hiện việc đi bộ hoặc lặp lại đều giữ khóa đọc RCU, thì
kiến trúc thượng tầng cũ không nên biến mất đối với họ.
