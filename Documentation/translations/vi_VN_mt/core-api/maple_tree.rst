.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/maple_tree.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========
Cây phong
===========

:Tác giả: Liam R. Howlett

Tổng quan
========

Maple Tree là kiểu dữ liệu B-Tree được tối ưu hóa để lưu trữ
phạm vi không chồng chéo, bao gồm phạm vi kích thước 1. Cây được thiết kế để
sử dụng đơn giản và không yêu cầu phương pháp tìm kiếm bằng văn bản của người dùng.  Nó
hỗ trợ lặp lại một loạt các mục và đi tới mục trước hoặc mục tiếp theo
entry theo cách hiệu quả với bộ nhớ đệm.  Cây cũng có thể được đưa vào RCU-safe
chế độ hoạt động cho phép đọc và viết đồng thời.  Nhà văn phải
đồng bộ hóa trên một khóa, có thể là khóa quay mặc định hoặc người dùng có thể đặt
khóa sang một khóa bên ngoài thuộc loại khác.

Maple Tree duy trì một lượng nhỏ bộ nhớ và được thiết kế để sử dụng
bộ nhớ đệm của bộ xử lý hiện đại một cách hiệu quả.  Phần lớn người dùng sẽ có thể
sử dụng API bình thường.  Một ZZ0000ZZ tồn tại cho những trường hợp phức tạp hơn
kịch bản.  Công dụng quan trọng nhất của Maple Tree là theo dõi
vùng nhớ ảo.

Cây phong có thể lưu trữ các giá trị giữa ZZ0001ZZ và ZZ0002ZZ.  cây phong
Cây dự trữ các giá trị với hai bit dưới cùng được đặt thành '10' dưới 4096
(tức là 2, 6, 10.. 4094) để sử dụng nội bộ.  Nếu các mục có thể sử dụng dành riêng
các mục thì người dùng có thể chuyển đổi các mục bằng cách sử dụng xa_mk_value() và chuyển đổi
chúng trở lại bằng cách gọi xa_to_value().  Nếu người dùng có nhu cầu sử dụng một tài khoản dành riêng
giá trị thì người dùng có thể chuyển đổi giá trị khi sử dụng
ZZ0000ZZ, nhưng bị chặn bởi API bình thường.

Cây phong cũng có thể được cấu hình để hỗ trợ tìm kiếm khoảng trống của một
kích thước (hoặc lớn hơn).

Việc phân bổ trước các nút cũng được hỗ trợ bằng cách sử dụng
ZZ0000ZZ.  Điều này hữu ích cho những người dùng phải đảm bảo
vận hành cửa hàng thành công trong thời gian nhất định
đoạn mã khi cấp phát không thể thực hiện được.  Việc phân bổ các nút là
tương đối nhỏ khoảng 256 byte.

.. _maple-tree-normal-api:

API bình thường
==========

Bắt đầu bằng cách khởi tạo một cây phong, với DEFINE_MTREE() cho tĩnh
cây phong được phân bổ hoặc mt_init() cho những cây được phân bổ động.  A
cây phong mới được khởi tạo chứa con trỏ ZZ0000ZZ cho phạm vi ZZ0001ZZ
-ZZ0002ZZ.  Hiện tại có hai loại cây phong được hỗ trợ:
cây cấp phát và cây thông thường.  Cây thông thường có độ phân nhánh cao hơn
yếu tố cho các nút nội bộ.  Cây phân bổ có hệ số phân nhánh thấp hơn
nhưng cho phép người dùng tìm kiếm khoảng trống có kích thước nhất định hoặc lớn hơn từ một trong hai
ZZ0003ZZ trở lên hoặc ZZ0004ZZ xuống.  Cây phân bổ có thể được sử dụng bởi
chuyển cờ ZZ0005ZZ khi khởi tạo cây.

Sau đó, bạn có thể đặt mục nhập bằng mtree_store() hoặc mtree_store_range().
mtree_store() sẽ ghi đè bất kỳ mục nhập nào bằng mục nhập mới và trả về 0 trên
thành công hoặc mã lỗi khác.  mtree_store_range() hoạt động theo cách tương tự
nhưng có một phạm vi.  mtree_load() được sử dụng để truy xuất mục được lưu trữ tại một
chỉ số đã cho.  Bạn có thể sử dụng mtree_erase() để xóa toàn bộ phạm vi chỉ bằng
biết một giá trị trong phạm vi đó hoặc gọi mtree_store() với mục nhập là
NULL có thể được sử dụng để xóa một phần hoặc nhiều phạm vi cùng một lúc.

Nếu bạn chỉ muốn lưu trữ một mục mới vào một phạm vi (hoặc chỉ mục) nếu phạm vi đó là
hiện tại là ZZ0000ZZ, bạn có thể sử dụng mtree_insert_range() hoặc mtree_insert()
trả về -EEXIST nếu phạm vi không trống.

Bạn có thể tìm kiếm mục nhập từ chỉ mục trở lên bằng cách sử dụng mt_find().

Bạn có thể đi từng mục trong một phạm vi bằng cách gọi mt_for_each().  Bạn phải
cung cấp một biến tạm thời để lưu trữ một con trỏ.  Nếu bạn muốn đi bộ từng
phần tử của cây thì ZZ0001ZZ và ZZ0002ZZ có thể được sử dụng làm phạm vi.  Nếu
người gọi sẽ giữ khóa trong suốt thời gian đi bộ thì đúng như vậy
đáng xem mas_for_each() API trong ZZ0000ZZ
phần.

Đôi khi cần phải đảm bảo lệnh gọi tiếp theo để lưu trữ vào cây phong
không phân bổ bộ nhớ, vui lòng xem ZZ0000ZZ để biết trường hợp sử dụng này.

Bạn có thể sử dụng mtree_dup() để nhân bản toàn bộ cây phong. Nó còn hơn thế nữa
cách hiệu quả hơn là chèn từng phần tử vào một cây mới.

Cuối cùng, bạn có thể xóa tất cả các mục từ cây phong bằng cách gọi
mtree_destroy().  Nếu các mục trong cây phong là con trỏ, bạn có thể muốn giải phóng
các mục đầu tiên.

Phân bổ nút
----------------

Việc phân bổ được xử lý bằng mã cây nội bộ.  Xem
ZZ0000ZZ cho các tùy chọn khác.

Khóa
-------

Bạn không phải lo lắng về việc khóa.  Xem ZZ0000ZZ
cho các lựa chọn khác.

Maple Tree sử dụng RCU và một spinlock bên trong để đồng bộ hóa quyền truy cập:

Thực hiện khóa đọc RCU:
 * mtree_load()
 * mt_find()
 * mt_for_each()
 * mt_next()
 * mt_prev()

Đưa ma_lock vào nội bộ:
 * mtree_store()
 * mtree_store_range()
 * mtree_insert()
 * mtree_insert_range()
 * mtree_erase()
 * mtree_dup()
 * mtree_destroy()
 * mt_set_in_rcu()
 * mt_clear_in_rcu()

Nếu bạn muốn tận dụng khóa bên trong để bảo vệ dữ liệu
cấu trúc mà bạn đang lưu trữ trong Maple Tree, bạn có thể gọi mtree_lock()
trước khi gọi mtree_load(), sau đó lấy số lượng tham chiếu trên đối tượng bạn
đã tìm thấy trước khi gọi mtree_unlock().  Điều này sẽ ngăn cản các cửa hàng
loại bỏ đối tượng khỏi cây giữa việc tìm kiếm đối tượng và
tăng số tiền hoàn lại.  Bạn cũng có thể sử dụng RCU để tránh hội thảo
bộ nhớ được giải phóng, nhưng một lời giải thích về điều đó nằm ngoài phạm vi của điều này
tài liệu.

.. _maple-tree-advanced-api:

API nâng cao
============

API tiên tiến mang đến sự linh hoạt hơn và hiệu suất tốt hơn ở
chi phí cho một giao diện khó sử dụng hơn và có ít biện pháp bảo vệ hơn.
Bạn phải tự bảo quản khóa của mình khi sử dụng API nâng cao.
Bạn có thể sử dụng ma_lock, RCU hoặc khóa ngoài để bảo vệ.
Bạn có thể kết hợp các thao tác nâng cao và thông thường trên cùng một mảng, miễn là
vì khóa tương thích.  ZZ0000ZZ được triển khai
xét về API tiên tiến.

API nâng cao dựa trên ma_state, đây là nơi 'mas'
tiền tố bắt nguồn.  Cấu trúc ma_state theo dõi các hoạt động của cây để thực hiện
cuộc sống dễ dàng hơn cho cả người dùng cây bên trong và bên ngoài.

Việc khởi tạo cây phong cũng giống như trong ZZ0000ZZ.
Xin vui lòng xem ở trên.

Trạng thái phong phú theo dõi phạm vi bắt đầu và kết thúc trong mas->index và
mas-> cuối cùng, tương ứng.

mas_walk() sẽ dẫn cây đến vị trí của mas->index và đặt
mas->index và mas->last theo phạm vi cho mục nhập.

Bạn có thể đặt mục bằng mas_store().  mas_store() sẽ ghi đè bất kỳ mục nào
với mục nhập mới và trả về mục nhập hiện có đầu tiên bị ghi đè.
Phạm vi được chuyển vào với tư cách là thành viên của trạng thái phong: chỉ mục và cuối cùng.

Bạn có thể sử dụng mas_erase() để xóa toàn bộ phạm vi bằng cách đặt chỉ mục và
cuối cùng của trạng thái phong đến phạm vi mong muốn để xóa.  Điều này sẽ xóa
phạm vi đầu tiên được tìm thấy trong phạm vi đó, đặt chỉ mục trạng thái phong
và cuối cùng là phạm vi đã bị xóa và trả lại mục nhập đã tồn tại
tại vị trí đó.

Bạn có thể đi từng mục trong một phạm vi bằng cách sử dụng mas_for_each().  Nếu bạn muốn
để duyệt từng phần tử của cây thì ZZ0000ZZ và ZZ0001ZZ có thể được sử dụng làm
phạm vi.  Nếu khóa cần được tháo định kỳ, hãy xem khóa
phần mas_pause().

Việc sử dụng trạng thái phong phú cho phép mas_next() và mas_prev() hoạt động như thể
cây là một danh sách liên kết.  Với hệ số phân nhánh cao như vậy, tỷ lệ khấu hao
hình phạt hiệu suất được giảm bớt bằng cách tối ưu hóa bộ đệm.  mas_next() sẽ
trả về mục tiếp theo xảy ra sau mục nhập tại chỉ mục.  mas_prev()
sẽ trả về mục nhập trước đó xảy ra trước mục nhập tại chỉ mục.

mas_find() sẽ tìm mục đầu tiên tồn tại ở chỉ mục hoặc cao hơn trên
cuộc gọi đầu tiên và mục tiếp theo từ mọi cuộc gọi tiếp theo.

mas_find_rev() sẽ tìm mục đầu tiên tồn tại bằng hoặc thấp hơn mục cuối cùng trên
cuộc gọi đầu tiên và mục nhập trước đó của mọi cuộc gọi tiếp theo.

Nếu người dùng cần nhường khóa trong khi thao tác thì trạng thái phong
phải được tạm dừng bằng mas_pause().

Có một số giao diện bổ sung được cung cấp khi sử dụng cây phân bổ.
Nếu bạn muốn tìm kiếm khoảng trống trong một phạm vi, thì mas_empty_area()
hoặc mas_empty_area_rev() có thể được sử dụng.  mas_empty_area() tìm kiếm khoảng trống
bắt đầu từ chỉ số thấp nhất cho đến mức tối đa của phạm vi.
mas_empty_area_rev() tìm kiếm khoảng trống bắt đầu từ chỉ số cao nhất đã cho
và tiếp tục đi xuống giới hạn dưới của phạm vi.

.. _maple-tree-advanced-alloc:

Nút phân bổ nâng cao
-------------------------

Việc phân bổ thường được xử lý nội bộ trên cây, tuy nhiên nếu việc phân bổ
cần xảy ra trước khi quá trình ghi xảy ra thì việc gọi mas_expected_entries() sẽ
phân bổ số lượng nút cần thiết trong trường hợp xấu nhất để chèn số lượng nút được cung cấp
phạm vi.  Điều này cũng khiến cây chuyển sang chế độ chèn hàng loạt.  Một lần
quá trình chèn hoàn tất, gọi mas_destroy() ở trạng thái phong sẽ giải phóng
phân bổ chưa sử dụng.

.. _maple-tree-advanced-locks:

Khóa nâng cao
----------------

Cây phong sử dụng khóa xoay theo mặc định, nhưng có thể sử dụng khóa bên ngoài để
cập nhật cây là tốt.  Để sử dụng khóa ngoài, cây phải được khởi tạo
với ZZ0000ZZ, việc này thường được thực hiện với
MTREE_INIT_EXT() #define, lấy khóa bên ngoài làm đối số.

Chức năng và cấu trúc
========================

.. kernel-doc:: include/linux/maple_tree.h
.. kernel-doc:: lib/maple_tree.c