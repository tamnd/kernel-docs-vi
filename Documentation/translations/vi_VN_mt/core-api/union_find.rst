.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/union_find.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Tìm kiếm liên minh trong Linux
==============================


:Ngày: 21 tháng 6 năm 2024
:Tác giả: Xavier <xavier_qy@163.com>

Union-find là gì và nó được dùng để làm gì?
------------------------------------------------

Union-find là cấu trúc dữ liệu được sử dụng để xử lý việc hợp nhất và truy vấn
của các tập rời rạc. Các hoạt động chính được hỗ trợ bởi Union-find là:

Khởi tạo: Đặt lại từng phần tử thành một bộ riêng lẻ, với
		nút cha ban đầu của mỗi tập hợp trỏ đến chính nó.

Tìm: Xác định tập hợp nào thuộc về một phần tử cụ thể, thường bằng cách
		trả về một “phần tử đại diện” của tập hợp đó. Hoạt động này
		được sử dụng để kiểm tra xem hai phần tử có nằm trong cùng một tập hợp hay không.

Hợp nhất: Hợp nhất hai bộ thành một.

Là một cấu trúc dữ liệu được sử dụng để duy trì các tập hợp (nhóm), tìm kiếm liên hợp thường được sử dụng
được sử dụng để giải quyết các vấn đề liên quan đến truy vấn ngoại tuyến, kết nối động,
và lý thuyết đồ thị. Nó cũng là thành phần chính trong thuật toán Kruskal cho
tính toán cây bao trùm tối thiểu, điều này rất quan trọng trong các tình huống như
định tuyến mạng. Do đó, Union-find được tham khảo rộng rãi. Ngoài ra,
Union-find có các ứng dụng trong tính toán ký hiệu, phân bổ đăng ký,
và hơn thế nữa.

Độ phức tạp của không gian: O(n), trong đó n là số nút.

Độ phức tạp về thời gian: Sử dụng tính năng nén đường dẫn có thể làm giảm độ phức tạp về thời gian của
thao tác tìm kiếm và sử dụng kết hợp theo thứ hạng có thể làm giảm độ phức tạp về thời gian
của hoạt động công đoàn. Những tối ưu hóa này làm giảm thời gian trung bình
độ phức tạp của mỗi phép toán tìm và hợp thành O(α(n)), trong đó α(n) là
hàm Ackermann nghịch đảo. Đây có thể coi là khoảng thời gian không đổi
phức tạp cho mục đích thực tế.

Tài liệu này đề cập đến việc sử dụng triển khai tìm kiếm liên kết Linux.  Để biết thêm
thông tin về bản chất và cách thực hiện tìm kiếm liên minh, xem:

Mục Wikipedia trên Union-find
    ZZ0000ZZ

Linux triển khai tìm kiếm liên kết
-----------------------------------

Việc triển khai tìm kiếm liên kết của Linux nằm trong tệp "lib/union_find.c".
Để sử dụng nó, "#include <linux/union_find.h>".

Cấu trúc dữ liệu tìm liên kết được định nghĩa như sau ::

cấu trúc uf_node {
		struct uf_node *parent;
		thứ hạng int không dấu;
	};

Trong cấu trúc này, nút cha trỏ đến nút cha của nút hiện tại.
Trường xếp hạng đại diện cho chiều cao của cây hiện tại. Trong thời gian liên minh
hoạt động, cây có thứ hạng nhỏ hơn được gắn dưới gốc cây với
cấp bậc lớn hơn để duy trì sự cân bằng.

Đang khởi tạo tìm kiếm liên minh
--------------------------------

Bạn có thể hoàn thành việc khởi tạo bằng cách sử dụng tĩnh hoặc khởi tạo
giao diện. Khởi tạo con trỏ cha để trỏ tới chính nó và đặt thứ hạng
đến 0.
Ví dụ::

cấu trúc uf_node my_node = UF_INIT_NODE(my_node);

hoặc

uf_node_init(&my_node);

Tìm nút gốc của Union-find
--------------------------------

Hoạt động này chủ yếu được sử dụng để xác định xem hai nút có thuộc cùng một
thiết lập trong công đoàn-tìm. Nếu chúng có cùng gốc thì chúng nằm trong cùng một tập hợp.
Trong quá trình tìm kiếm, việc nén đường dẫn được thực hiện để cải thiện
hiệu quả của các hoạt động tìm kiếm tiếp theo.
Ví dụ::

int được kết nối;
	struct uf_node *root1 = uf_find(&node_1);
	struct uf_node *root2 = uf_find(&node_2);
	nếu (root1 == root2)
		được kết nối = 1;
	khác
		được kết nối = 0;

Union Two Sets trong tìm kiếm liên minh
---------------------------------------

Để hợp nhất hai bộ trong tìm kiếm hợp nhất, trước tiên bạn phải tìm các nút gốc tương ứng của chúng
và sau đó liên kết nút nhỏ hơn với nút lớn hơn dựa trên thứ hạng của nút gốc
nút.
Ví dụ::

uf_union(&node_1, &node_2);