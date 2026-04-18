.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/list.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Danh sách liên kết trong Linux
==============================

:Tác giả: Nicolas Frattaroli <nicolas.frattaroli@collabora.com>

.. contents::

Giới thiệu
============

Danh sách liên kết là một trong những cấu trúc dữ liệu cơ bản nhất được sử dụng trong nhiều chương trình.
Nhân Linux triển khai một số dạng danh sách liên kết khác nhau. các
Mục đích của tài liệu này không phải là giải thích các danh sách liên kết nói chung mà là chỉ ra
nhà phát triển hạt nhân mới cách sử dụng triển khai hạt nhân Linux của liên kết
danh sách.

Xin lưu ý rằng mặc dù danh sách liên kết chắc chắn có ở khắp mọi nơi nhưng chúng hiếm khi được sử dụng.
cấu trúc dữ liệu tốt nhất để sử dụng trong trường hợp chưa có mảng đơn giản
đủ. Đặc biệt, do vị trí dữ liệu kém nên danh sách liên kết là một phương pháp tồi.
lựa chọn trong các tình huống mà hiệu suất có thể được xem xét. Làm quen
bản thân với các cấu trúc dữ liệu chung trong kernel khác, đặc biệt là cho các cấu trúc đồng thời
truy cập, rất được khuyến khích.

Linux triển khai danh sách liên kết đôi
===========================================

Việc triển khai danh sách liên kết của Linux có thể được sử dụng bằng cách đưa vào tệp tiêu đề
ZZ0000ZZ.

Danh sách liên kết đôi có thể sẽ quen thuộc nhất với nhiều độc giả. Đó là một
danh sách có thể được duyệt qua tiến và lùi một cách hiệu quả.

Danh sách liên kết đôi của nhân Linux có tính chất vòng tròn. Điều này có nghĩa là để
đi từ nút đầu đến nút đuôi, chúng ta chỉ có thể di chuyển ngược lại một cạnh.
Tương tự, để đi từ nút đuôi đến đầu, chúng ta chỉ cần di chuyển về phía trước
"ngoài" đuôi và quay trở lại đầu.

Khai báo một nút
----------------

Một nút trong danh sách liên kết đôi được khai báo bằng cách thêm cấu trúc list_head
thành viên vào cấu trúc dữ liệu bạn muốn có trong danh sách:

.. code-block:: c

  struct clown {
          unsigned long long shoe_size;
          const char *name;
          struct list_head node;  /* the aforementioned member */
  };

Đây có thể là một cách tiếp cận xa lạ đối với một số người, như cách giải thích cổ điển về một
danh sách liên kết là cấu trúc dữ liệu nút danh sách với các con trỏ tới nút trước và nút tiếp theo
nút danh sách cũng như dữ liệu tải trọng. Linux chọn cách tiếp cận này vì nó
cho phép mã sửa đổi danh sách chung bất kể cấu trúc dữ liệu là gì
có trong danh sách. Vì thành viên struct list_head không phải là con trỏ
nhưng là một phần của cấu trúc dữ liệu thích hợp, mẫu container_of() có thể được sử dụng bởi
việc triển khai danh sách để truy cập dữ liệu tải trọng bất kể loại của nó, trong khi
không biết thực tế loại đã nói là gì.

Khai báo và khởi tạo danh sách
---------------------------------

Sau đó, một danh sách liên kết đôi có thể được khai báo như một struct list_head khác,
và được khởi tạo bằng macro LIST_HEAD_INIT() trong quá trình gán ban đầu hoặc
với hàm INIT_LIST_HEAD() sau:

.. code-block:: c

  struct clown_car {
          int tyre_pressure[4];
          struct list_head clowns;        /* Looks like a node! */
  };

  /* ... Somewhere later in our driver ... */

  static int circus_init(struct circus_priv *circus)
  {
          struct clown_car other_car = {
                .tyre_pressure = {10, 12, 11, 9},
                .clowns = LIST_HEAD_INIT(other_car.clowns)
          };

          INIT_LIST_HEAD(&circus->car.clowns);

          return 0;
  }

Một điểm gây nhầm lẫn nữa đối với một số người có thể là bản thân danh sách này không thực sự
có kiểu riêng của nó. Khái niệm về toàn bộ danh sách liên kết và một
Thành viên struct list_head trỏ đến các mục khác trong danh sách là một và
giống nhau.

Thêm các nút vào danh sách
--------------------------

Việc thêm một nút vào danh sách liên kết được thực hiện thông qua macro list_add().

Chúng ta sẽ quay lại ví dụ về chiếc xe hề để minh họa cách các nút được thêm vào
danh sách:

.. code-block:: c

  static int circus_fill_car(struct circus_priv *circus)
  {
          struct clown_car *car = &circus->car;
          struct clown *grock;
          struct clown *dimitri;

          /* State 1 */

          grock = kzalloc(sizeof(*grock), GFP_KERNEL);
          if (!grock)
                  return -ENOMEM;
          grock->name = "Grock";
          grock->shoe_size = 1000;

          /* Note that we're adding the "node" member */
          list_add(&grock->node, &car->clowns);

          /* State 2 */

          dimitri = kzalloc(sizeof(*dimitri), GFP_KERNEL);
          if (!dimitri)
                  return -ENOMEM;
          dimitri->name = "Dimitri";
          dimitri->shoe_size = 50;

          list_add(&dimitri->node, &car->clowns);

          /* State 3 */

          return 0;
  }

Ở Trạng thái 1, danh sách chú hề của chúng tôi vẫn trống::

.------.
         v |
    .-------.  |
    ZZ0000ZZ--'
    '--------'

Sơ đồ này hiển thị nút "chú hề" số ít chỉ vào chính nó. Trong này
sơ đồ và tất cả các sơ đồ sau, chỉ hiển thị các cạnh phía trước để hỗ trợ
sự rõ ràng.

Ở Trạng thái 2, chúng tôi đã thêm Grock sau phần đầu danh sách::

.-------------------.
         v |
    .-------.     -------.  |
    ZZ0000ZZ---->ZZ0001ZZ--'
    '-------' '-------'

Sơ đồ này hiển thị nút "chú hề" trỏ vào nút mới có nhãn "Grock".
Nút Grock đang trỏ lại nút "chú hề".

Ở Trạng thái 3, chúng tôi đã thêm Dimitri vào sau người đứng đầu danh sách, dẫn đến kết quả như sau::

.-----------------------------------.
         v |
    .-------.     .--------.     -------.  |
    ZZ0000ZZ---->ZZ0001ZZ---->ZZ0002ZZ--'
    '--------' '--------' '-------'

Sơ đồ này hiển thị nút "chú hề" trỏ vào nút mới có nhãn "Dimitri",
sau đó trỏ vào nút có nhãn "Grock". Nút "Grock" vẫn trỏ
quay lại nút "chú hề".

Thay vào đó, nếu chúng tôi muốn chèn Dimitri vào cuối danh sách, chúng tôi sẽ sử dụng
danh sách_add_tail(). Mã của chúng tôi sau đó sẽ trông như thế này:

.. code-block:: c

  static int circus_fill_car(struct circus_priv *circus)
  {
          /* ... */

          list_add_tail(&dimitri->node, &car->clowns);

          /* State 3b */

          return 0;
  }

Điều này dẫn đến danh sách sau::

.-----------------------------------.
         v |
    .-------.     -------.     .--------.  |
    ZZ0000ZZ---->ZZ0001ZZ---->ZZ0002ZZ--'
    '--------' '-------' '--------'

Sơ đồ này hiển thị nút "chú hề" trỏ vào nút có nhãn "Grock",
trỏ đến nút mới có nhãn "Dimitri". Nút có nhãn "Dimitri"
trỏ lại nút "chú hề".

Duyệt qua danh sách
-------------------

Để lặp lại danh sách, chúng ta có thể lặp qua tất cả các nút trong danh sách bằng
list_for_each().

Trong ví dụ chú hề của chúng tôi, điều này dẫn đến đoạn mã hơi khó xử sau đây:

.. code-block:: c

  static unsigned long long circus_get_max_shoe_size(struct circus_priv *circus)
  {
          unsigned long long res = 0;
          struct clown *e;
          struct list_head *cur;

          list_for_each(cur, &circus->car.clowns) {
                  e = list_entry(cur, struct clown, node);
                  if (e->shoe_size > res)
                          res = e->shoe_size;
          }

          return res;
  }

Macro list_entry() sử dụng nội bộ container_of() đã nói ở trên để
truy xuất phiên bản cấu trúc dữ liệu mà ZZ0000ZZ là thành viên.

Lưu ý rằng lệnh gọi list_entry() bổ sung ở đây hơi khó xử một chút. Nó chỉ
ở đó bởi vì chúng tôi đang duyệt qua các thành viên ZZ0000ZZ, nhưng chúng tôi thực sự muốn
để lặp qua tải trọng, tức là ZZ0001ZZ chứa mỗi
cấu trúc list_head của nút. Vì lý do này, có macro thứ hai:
list_for_each_entry()

Sử dụng nó sẽ thay đổi mã của chúng tôi thành một cái gì đó như thế này:

.. code-block:: c

  static unsigned long long circus_get_max_shoe_size(struct circus_priv *circus)
  {
          unsigned long long res = 0;
          struct clown *e;

          list_for_each_entry(e, &circus->car.clowns, node) {
                  if (e->shoe_size > res)
                          res = e->shoe_size;
          }

          return res;
  }

Điều này giúp loại bỏ sự cần thiết của bước list_entry() và con trỏ vòng lặp của chúng ta bây giờ
về loại tải trọng của chúng tôi. Macro được đặt tên thành viên tương ứng
vào cấu trúc list_head của danh sách trong cấu trúc dữ liệu chú hề để nó có thể
vẫn đi theo danh sách.

Xóa các nút khỏi danh sách
----------------------------

Hàm list_del() có thể được sử dụng để xóa các mục khỏi danh sách. Nó không chỉ
xóa mục nhập đã cho khỏi danh sách, nhưng đầu độc ZZ0000ZZ của mục nhập đó và
Con trỏ ZZ0001ZZ, do đó việc sử dụng mục nhập ngoài ý muốn sau khi xóa không
không được chú ý.

Chúng ta có thể mở rộng ví dụ trước để xóa một trong các mục:

.. code-block:: c

  static int circus_fill_car(struct circus_priv *circus)
  {
          /* ... */

          list_add(&dimitri->node, &car->clowns);

          /* State 3 */

          list_del(&dimitri->node);

          /* State 4 */

          return 0;
  }

Kết quả của việc này sẽ là thế này::

.-------------------.
         v |
    .-------.     -------.  |      .--------.
    ZZ0000ZZ---->ZZ0001ZZ--'ZZ0002ZZ
    '--------' '-------' '--------'

Sơ đồ này hiển thị nút "chú hề" trỏ vào nút có nhãn "Grock",
trỏ lại nút "chú hề". Ở bên cạnh là một nút đơn độc được dán nhãn
"Dimitri", không có mũi tên chỉ vào đâu cả.

Lưu ý nút Dimitri không trỏ đến chính nó; con trỏ của nó là
cố ý đặt thành giá trị "độc" mà mã danh sách từ chối duyệt qua.

Thay vào đó, nếu chúng ta muốn khởi tạo lại nút đã bị xóa để làm cho nút đó trỏ vào chính nó
một lần nữa giống như một đầu danh sách trống, thay vào đó chúng ta có thể sử dụng list_del_init():

.. code-block:: c

  static int circus_fill_car(struct circus_priv *circus)
  {
          /* ... */

          list_add(&dimitri->node, &car->clowns);

          /* State 3 */

          list_del_init(&dimitri->node);

          /* State 4b */

          return 0;
  }

Điều này dẫn đến nút đã xóa trỏ lại chính nó ::

.-------------------.           -------.
         v ZZ0000ZZ
    .-------.     -------.  ZZ0001ZZ
    ZZ0002ZZ---->ZZ0003ZZ--' ZZ0004ZZ--'
    '--------' '-------' '--------'

Sơ đồ này hiển thị nút "chú hề" trỏ vào nút có nhãn "Grock",
trỏ lại nút "chú hề". Ở bên cạnh là một nút đơn độc được dán nhãn
"Dimitri", chỉ vào chính nó.

Di chuyển ngang trong khi loại bỏ các nút
-----------------------------------------

Xóa các mục trong khi duyệt qua danh sách sẽ gây ra vấn đề nếu chúng ta sử dụng
list_for_each() và list_for_each_entry(), vì việc xóa mục nhập hiện tại sẽ
sửa đổi con trỏ ZZ0000ZZ của nó, điều đó có nghĩa là việc truyền tải không thể chính xác
tiến tới mục danh sách tiếp theo.

Tuy nhiên, có một giải pháp cho vấn đề này: list_for_each_safe() và
list_for_each_entry_safe(). Chúng lấy một tham số bổ sung của một con trỏ để
một struct list_head để sử dụng làm nơi lưu trữ tạm thời cho mục tiếp theo trong
lặp lại, giải quyết vấn đề.

Một ví dụ về cách sử dụng nó:

.. code-block:: c

  static void circus_eject_insufficient_clowns(struct circus_priv *circus)
  {
          struct clown *e;
          struct clown *n;      /* temporary storage for safe iteration */

          list_for_each_entry_safe(e, n, &circus->car.clowns, node) {
                if (e->shoe_size < 500)
                        list_del(&e->node);
          }
  }

Quản lý bộ nhớ phù hợp (tức là giải phóng nút đã xóa trong khi đảm bảo
không có gì còn tham chiếu đến nó) trong trường hợp này được để lại như một bài tập cho người đọc.

Cắt một danh sách
-----------------

Có hai hàm trợ giúp để cắt danh sách. Cả hai đều lấy các yếu tố từ
liệt kê ZZ0000ZZ và thay thế nội dung của danh sách ZZ0001ZZ.

Hàm đầu tiên như vậy là list_cut_position(). Nó loại bỏ tất cả các mục danh sách khỏi
ZZ0000ZZ lên đến và bao gồm ZZ0001ZZ, thay vào đó đặt chúng vào ZZ0002ZZ.

Trong ví dụ này, giả sử chúng ta bắt đầu với danh sách sau::

.----------------------------------------------------------------.
         v |
    .-------.     -------.     .--------.     .------.     .--------.  |
    ZZ0000ZZ---->ZZ0001ZZ---->ZZ0002ZZ---->ZZ0003ZZ---->ZZ0004ZZ--'
    '--------' '-------' '----------' '------' '--------'

Với đoạn mã sau, mọi chú hề cho đến và bao gồm cả "Pic" đều được chuyển từ
đầu danh sách "chú hề" dẫn đến một cấu trúc list_head riêng biệt được khởi tạo tại cục bộ
biến ngăn xếp ZZ0000ZZ:

.. code-block:: c

  static void circus_retire_clowns(struct circus_priv *circus)
  {
          struct list_head retirement = LIST_HEAD_INIT(retirement);
          struct clown *grock, *dimitri, *pic, *alfredo;
          struct clown_car *car = &circus->car;

          /* ... clown initialization, list adding ... */

          list_cut_position(&retirement, &car->clowns, &pic->node);

          /* State 1 */
  }

Danh sách ZZ0000ZZ thu được sẽ là::

.----------------------.
         v |
    .-------.     .--------.  |
    ZZ0000ZZ---->ZZ0001ZZ--'
    '--------' '--------'

Trong khi đó, danh sách ZZ0000ZZ được chuyển thành như sau::

.-------------------------------------------------.
           v |
    .----------.     -------.     .--------.     .------.  |
    ZZ0000ZZ---->ZZ0001ZZ---->ZZ0002ZZ---->ZZ0003ZZ--'
    '----------' '-------' '----------' '------'

Hàm thứ hai, list_cut_Before(), cũng gần giống như vậy, ngoại trừ việc nó cắt trước
nút ZZ0000ZZ, tức là nó xóa tất cả các mục danh sách từ ZZ0001ZZ cho đến
loại trừ ZZ0002ZZ, thay vào đó đặt chúng vào ZZ0003ZZ. Ví dụ này giả định
danh sách bắt đầu ban đầu giống như ví dụ trước:

.. code-block:: c

  static void circus_retire_clowns(struct circus_priv *circus)
  {
          struct list_head retirement = LIST_HEAD_INIT(retirement);
          struct clown *grock, *dimitri, *pic, *alfredo;
          struct clown_car *car = &circus->car;

          /* ... clown initialization, list adding ... */

          list_cut_before(&retirement, &car->clowns, &pic->node);

          /* State 1b */
  }

Danh sách ZZ0000ZZ thu được sẽ là::

.---------------------------------.
         v |
    .-------.     .------.     .--------.  |
    ZZ0000ZZ---->ZZ0001ZZ---->ZZ0002ZZ--'
    '--------' '------' '----------'

Trong khi đó, danh sách ZZ0000ZZ được chuyển thành như sau::

.---------------------------------------------------.
           v |
    .----------.     -------.     .--------.  |
    ZZ0000ZZ---->ZZ0001ZZ---->ZZ0002ZZ--'
    '----------' '-------' '----------'

Cần lưu ý rằng cả hai chức năng sẽ hủy liên kết đến bất kỳ nút hiện có nào
ở đích ZZ0000ZZ.

Di chuyển các mục và danh sách một phần
---------------------------------------

Các hàm list_move() và list_move_tail() có thể được sử dụng để di chuyển một mục
từ danh sách này sang danh sách khác, bắt đầu hoặc kết thúc tương ứng.

Trong ví dụ sau, chúng tôi giả sử chúng tôi bắt đầu với hai danh sách ("chú hề" và
"vỉa hè" ở trạng thái ban đầu sau "Trạng thái 0"::

.----------------------------------------------------------------.
         v |
    .-------.     -------.     .--------.     .------.     .--------.  |
    ZZ0000ZZ---->ZZ0001ZZ---->ZZ0002ZZ---->ZZ0003ZZ---->ZZ0004ZZ--'
    '--------' '-------' '----------' '------' '--------'

.-------------------.
          v |
    .----------.     .------.  |
    ZZ0000ZZ---->ZZ0001ZZ--'
    '----------' '------'

Chúng tôi áp dụng mã ví dụ sau cho hai danh sách:

.. code-block:: c

  static void circus_clowns_exit_car(struct circus_priv *circus)
  {
          struct list_head sidewalk = LIST_HEAD_INIT(sidewalk);
          struct clown *grock, *dimitri, *pic, *alfredo, *pio;
          struct clown_car *car = &circus->car;

          /* ... clown initialization, list adding ... */

          /* State 0 */

          list_move(&pic->node, &sidewalk);

          /* State 1 */

          list_move_tail(&dimitri->node, &sidewalk);

          /* State 2 */
  }

Ở trạng thái 1, chúng ta đi đến tình huống sau::

.-------------------------------------------------------------------.
        ZZ0000ZZ
        v |
    .-------.     -------.     .--------.     .--------.  |
    ZZ0001ZZ---->ZZ0002ZZ---->ZZ0003ZZ---->ZZ0004ZZ--'
    '--------' '-------' '---------' '----------'

.------------------------------.
          v |
    .----------.     .------.     .------.  |
    ZZ0000ZZ---->ZZ0001ZZ---->ZZ0002ZZ--'
    '----------' '------' '------'

Ở Trạng thái 2, sau khi chúng tôi chuyển Dimitri đến cuối vỉa hè, tình hình
thay đổi như sau::

.------------------------------------.
        ZZ0000ZZ
        v |
    .-------.     -------.     .--------.  |
    ZZ0001ZZ---->ZZ0002ZZ---->ZZ0003ZZ--'
    '--------' '-------' '--------'

.----------------------------------------------.
          v |
    .----------.     .------.     .------.     .--------.  |
    ZZ0000ZZ---->ZZ0001ZZ---->ZZ0002ZZ---->ZZ0003ZZ--'
    '----------' '------' '------' '--------'

Miễn là đầu danh sách nguồn và đích là một phần của cùng một danh sách, chúng tôi
cũng có thể di chuyển hàng loạt một phân đoạn của danh sách đến cuối danh sách một cách hiệu quả.
danh sách. Chúng ta tiếp tục ví dụ trước bằng cách thêm list_bulk_move_tail() sau
Trạng thái 2, di chuyển Pic và Pio về cuối danh sách vỉa hè.

.. code-block:: c

  static void circus_clowns_exit_car(struct circus_priv *circus)
  {
          struct list_head sidewalk = LIST_HEAD_INIT(sidewalk);
          struct clown *grock, *dimitri, *pic, *alfredo, *pio;
          struct clown_car *car = &circus->car;

          /* ... clown initialization, list adding ... */

          /* State 0 */

          list_move(&pic->node, &sidewalk);

          /* State 1 */

          list_move_tail(&dimitri->node, &sidewalk);

          /* State 2 */

          list_bulk_move_tail(&sidewalk, &pic->node, &pio->node);

          /* State 3 */
  }

Để cho ngắn gọn, chỉ mô tả danh sách "vỉa hè" đã thay đổi ở Trạng thái 3
trong sơ đồ sau::

.----------------------------------------------.
          v |
    .----------.     .--------.     .------.     .------.  |
    ZZ0000ZZ---->ZZ0001ZZ---->ZZ0002ZZ---->ZZ0003ZZ--'
    '----------' '----------' '------' '------'

Xin lưu ý rằng list_bulk_move_tail() không thực hiện bất kỳ kiểm tra nào về việc liệu tất cả
ba tham số ZZ0000ZZ được cung cấp thực sự thuộc về cùng một
danh sách. Nếu bạn sử dụng nó ngoài những ràng buộc mà tài liệu đưa ra, thì
kết quả là vấn đề giữa bạn và việc thực hiện.

Các mục luân phiên
------------------

Thao tác ghi phổ biến trên danh sách, đặc biệt khi sử dụng chúng làm hàng đợi, là
để xoay nó. Xoay danh sách có nghĩa là các mục ở phía trước sẽ được gửi ra phía sau.

Để xoay vòng, Linux cung cấp cho chúng ta hai hàm: list_rotate_left() và
list_rotate_to_front(). Cái trước có thể được hình dung giống như một sợi xích xe đạp, lấy
mục sau ZZ0000ZZ được cung cấp và di chuyển nó đến phần đuôi,
về bản chất có nghĩa là toàn bộ danh sách, do tính chất vòng tròn của nó, xoay theo
một vị trí.

Cái sau, list_rotate_to_front(), đưa khái niệm tương tự tiến thêm một bước:
thay vì nâng cao danh sách theo một mục, nó sẽ nâng cao ZZ0000ZZ theo mục được chỉ định
lối vào là mặt trận mới.

Trong ví dụ sau, trạng thái bắt đầu của chúng ta, Trạng thái 0, như sau::

.--------------------------------------------------------------------------------.
         v |
    .-------.   -------.   .--------.   .------.   .--------.   .------. |
    ZZ0000ZZ-->ZZ0001ZZ-->ZZ0002ZZ-->ZZ0003ZZ-->ZZ0004ZZ-->ZZ0005ZZ-'
    '--------' '-------' '----------' '------' '--------' '------'

Mã ví dụ đang được sử dụng để minh họa việc xoay danh sách như sau:

.. code-block:: c

  static void circus_clowns_rotate(struct circus_priv *circus)
  {
          struct clown *grock, *dimitri, *pic, *alfredo, *pio;
          struct clown_car *car = &circus->car;

          /* ... clown initialization, list adding ... */

          /* State 0 */

          list_rotate_left(&car->clowns);

          /* State 1 */

          list_rotate_to_front(&alfredo->node, &car->clowns);

          /* State 2 */

  }

Ở trạng thái 1, chúng ta đi đến tình huống sau::

.--------------------------------------------------------------------------------.
         v |
    .-------.   .--------.   .------.   .--------.   .------.   -------. |
    ZZ0000ZZ-->ZZ0001ZZ-->ZZ0002ZZ-->ZZ0003ZZ-->ZZ0004ZZ-->ZZ0005ZZ-'
    '--------' '--------' '------' '--------' '------' '-------'

Tiếp theo, sau lệnh gọi list_rotate_to_front(), chúng ta sẽ có kết quả sau
Trạng thái 2::

.--------------------------------------------------------------------------------.
         v |
    .-------.   .--------.   .------.   -------.   .--------.   .------. |
    ZZ0000ZZ-->ZZ0001ZZ-->ZZ0002ZZ-->ZZ0003ZZ-->ZZ0004ZZ-->ZZ0005ZZ-'
    '--------' '--------' '------' '-------' '--------' '------'

Như được hy vọng hiển nhiên từ các sơ đồ, các mục ở phía trước "Alfredo"
đã được chuyển đến cuối danh sách.

Trao đổi mục
----------------

Một hoạt động phổ biến khác là hai mục cần được hoán đổi với nhau.

Để làm điều này, Linux cung cấp cho chúng ta list_swap().

Trong ví dụ sau, chúng ta có một danh sách có ba mục và hoán đổi hai trong số đó
họ. Đây là trạng thái bắt đầu của chúng tôi ở "Trạng thái 0"::

.------------------------------------------.
         v |
    .-------.   -------.   .--------.   .------. |
    ZZ0000ZZ->ZZ0001ZZ->ZZ0002ZZ->ZZ0003ZZ-'
    '--------' '-------' '----------' '------'

.. code-block:: c

  static void circus_clowns_swap(struct circus_priv *circus)
  {
          struct clown *grock, *dimitri, *pic;
          struct clown_car *car = &circus->car;

          /* ... clown initialization, list adding ... */

          /* State 0 */

          list_swap(&dimitri->node, &pic->node);

          /* State 1 */
  }

Danh sách kết quả ở Trạng thái 1 như sau::

.------------------------------------------.
         v |
    .-------.   -------.   .------.   .--------. |
    ZZ0000ZZ->ZZ0001ZZ->ZZ0002ZZ->ZZ0003ZZ-'
    '--------' '-------' '------' '----------'

Rõ ràng bằng cách so sánh các sơ đồ, các nút "Pic" và "Dimitri" có
nơi giao dịch.

Nối hai danh sách lại với nhau
------------------------------

Giả sử chúng ta có hai danh sách, trong ví dụ sau, một danh sách được biểu thị bằng phần đầu danh sách
chúng tôi gọi là "knie" và một người chúng tôi gọi là "stey". Trong một vụ mua lại rạp xiếc giả định,
hai danh sách chú hề nên được ghép lại với nhau. Sau đây là của chúng tôi
tình huống ở "Trạng thái 0"::

.------------------------------------------.
        ZZ0000ZZ
        v |
    .------.   -------.   .--------.   .------.  |
    ZZ0001ZZ->ZZ0002ZZ->ZZ0003ZZ->ZZ0004ZZ--'
    '------' '-------' '----------' '------'

.------------------------------------------.
        v |
    .------.   .--------.   .------.  |
    ZZ0000ZZ->ZZ0001ZZ->ZZ0002ZZ--'
    '------' '--------' '------'

Hàm ghép hai danh sách này lại với nhau là list_splice(). Ví dụ của chúng tôi
mã như sau:

.. code-block:: c

  static void circus_clowns_splice(void)
  {
          struct clown *grock, *dimitri, *pic, *alfredo, *pio;
          struct list_head knie = LIST_HEAD_INIT(knie);
          struct list_head stey = LIST_HEAD_INIT(stey);

          /* ... Clown allocation and initialization here ... */

          list_add_tail(&grock->node, &knie);
          list_add_tail(&dimitri->node, &knie);
          list_add_tail(&pic->node, &knie);
          list_add_tail(&alfredo->node, &stey);
          list_add_tail(&pio->node, &stey);

          /* State 0 */

          list_splice(&stey, &dimitri->node);

          /* State 1 */
  }

Lệnh gọi list_splice() ở đây sẽ thêm tất cả các mục trong ZZ0000ZZ vào danh sách
Đầu danh sách ZZ0002ZZ của ZZ0001ZZ nằm sau ZZ0003ZZ của ZZ0004ZZ. A
sơ đồ có phần đáng ngạc nhiên về "Trạng thái 1" thu được như sau::

.--------------------------------------------------------------------------------.
        ZZ0000ZZ
        v |
    .------.   -------.   .--------.   .--------.   .------.   .------.  |
    ZZ0001ZZ->ZZ0002ZZ->ZZ0003ZZ->ZZ0004ZZ->ZZ0005ZZ->ZZ0006ZZ--'
    '------' '-------' '----------' '----------' '------' '------'
                                              ^
              .------------------------------'
              |
    .------.  |
    ZZ0007ZZ--'
    '------'

Việc duyệt qua danh sách ZZ0000ZZ không còn mang lại hành vi đúng nữa. Một cuộc gọi của
list_for_each() trên ZZ0001ZZ dẫn đến vòng lặp vô hạn vì nó không bao giờ trả về
quay lại đầu danh sách ZZ0002ZZ.

Điều này là do list_splice() đã không khởi tạo lại list_head mà nó đã thực hiện
các mục từ, để lại con trỏ của nó trỏ vào danh sách hiện là một danh sách khác.

Nếu chúng ta muốn tránh tình trạng này, có thể sử dụng list_splice_init(). Nó làm
tương tự như list_splice(), ngoại trừ việc khởi tạo lại danh sách của nhà tài trợ sau
cấy ghép.

Cân nhắc đồng thời
--------------------------

Truy cập đồng thời và sửa đổi danh sách cần được bảo vệ bằng khóa
trong hầu hết các trường hợp. Ngoài ra và tốt hơn, người ta có thể sử dụng các nguyên hàm RCU cho
danh sách trong các trường hợp sử dụng chủ yếu đọc, trong đó quyền truy cập đọc vào danh sách là phổ biến nhưng
ít sửa đổi danh sách hơn. Xem Tài liệu/RCU/listRCU.rst để biết thêm
chi tiết.

Đọc thêm
---------------

* ZZ0000ZZ

Danh sách đầy đủ API
====================

.. kernel-doc:: include/linux/list.h
   :internal:

Danh sách riêng API
===================

.. kernel-doc:: include/linux/list_private.h
   :doc: Private List Primitives

.. kernel-doc:: include/linux/list_private.h
   :internal: