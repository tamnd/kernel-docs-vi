.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/fib_trie.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
Ghi chú triển khai LC-trie
============================

Các loại nút
----------
lá
	Một nút cuối có dữ liệu. Cái này có một bản sao của khóa liên quan, cùng với
	với 'hlist' với các mục trong bảng định tuyến được sắp xếp theo độ dài tiền tố.
	Xem struct leaf và struct leaf_info.

nút trie hoặc tnode
	Một nút bên trong chứa một mảng các con trỏ con (lá hoặc nút t),
	được lập chỉ mục thông qua một tập hợp con của khóa. Xem Nén mức.

Giải thích một số khái niệm
------------------------
Bit (tnode)
	Số bit trong đoạn khóa được sử dụng để lập chỉ mục vào
	mảng con - "chỉ mục con". Xem Nén mức.

Pos (tnode)
	Vị trí (trong khóa) của đoạn khóa được sử dụng để lập chỉ mục vào
	mảng con. Xem Nén đường dẫn.

Nén đường dẫn/bit bị bỏ qua
	Bất kỳ nút nào đã cho đều được liên kết đến từ mảng con của phần tử mẹ của nó, bằng cách sử dụng
	một đoạn của khóa được chỉ định bởi "pos" và "bit" của cha mẹ
	Trong một số trường hợp nhất định, "pos" riêng của tnode này sẽ không được áp dụng ngay lập tức.
	liền kề với cha mẹ (pos+bits), nhưng sẽ có một số bit
	trong khóa bị bỏ qua vì chúng đại diện cho một đường dẫn duy nhất không có
	những sai lệch. Những "bit bị bỏ qua" này tạo thành Nén đường dẫn.
	Lưu ý rằng thuật toán tìm kiếm sẽ đơn giản bỏ qua các bit này khi
	tìm kiếm, do đó cần phải lưu các khóa trong các lá để
	xác minh rằng chúng thực sự khớp với khóa mà chúng tôi đang tìm kiếm.

Mức nén/mảng con
	tri được giữ cân bằng khi di chuyển, trong những điều kiện nhất định,
	con của một đứa trẻ đầy đủ (xem "full_children") lên một cấp độ, do đó
	thay vì cây nhị phân thuần túy, mỗi nút bên trong ("tnode") có thể
	chứa một mảng lớn các liên kết tùy ý tới một số trẻ em.
	Ngược lại, một tnode có mảng con gần như trống (xem Empty_children)
	có thể bị "giảm một nửa", khiến một số con của nó bị chuyển xuống một cấp,
	để tránh mảng con ngày càng tăng.

trống_con
	số lượng vị trí trong mảng con của một nút nhất định
	NULL.

đầy đủ_trẻ em
	số lượng nút con của một nút nhất định không bị nén đường dẫn.
	(nói cách khác, họ không phải là NULL hoặc rời đi và "pos" của họ bằng nhau
	tới "pos"+"bit" của tnode này).

(Từ "đầy đủ" ở đây được dùng với nghĩa "hoàn chỉnh" hơn là
	trái ngược với "trống", điều này có thể hơi khó hiểu.)

Bình luận
---------

Chúng tôi đã cố gắng giữ cấu trúc mã gần với fib_hash nhất có thể
có thể cho phép xác minh và giúp đánh giá.

fib_find_node()
	Một khởi đầu tốt để hiểu mã này. Chức năng này thực hiện một
	tra cứu thử đơn giản.

fib_insert_node()
	Chèn một nút lá mới vào tri. Điều này phức tạp hơn một chút so với
	fib_find_node(). Chèn một nút mới có nghĩa là chúng ta có thể phải chạy
	thuật toán nén mức trên một phần của tri.

trie_leaf_remove()
	Tra cứu một khóa, xóa nó và chạy thuật toán nén mức.

trie_rebalance()
	Chức năng chính của trie động sau bất kỳ thay đổi nào trong trie
	nó được chạy để tối ưu hóa và tổ chức lại. Nó sẽ đi bộ thử lên trên
	về phía gốc từ một tnode nhất định, thực hiện thay đổi kích thước() ở mỗi bước
	để thực hiện nén mức.

thay đổi kích thước()
	Phân tích một tnode và tối ưu hóa kích thước mảng con bằng cách tăng cường
	hoặc thu nhỏ nó nhiều lần cho đến khi nó đáp ứng được tiêu chí tối ưu
	nén cấp độ. Phần này bám sát bài báo gốc khá chặt chẽ
	và có thể có một số chỗ để thử nghiệm ở đây.

thổi phồng()
	Nhân đôi kích thước của mảng con trong một tnode. Được sử dụng bởi thay đổi kích thước().

một nửa()
	Giảm một nửa kích thước của mảng con trong một tnode - nghịch đảo của
	thổi phồng(). Được sử dụng bởi thay đổi kích thước();

fn_trie_insert(), fn_trie_delete(), fn_trie_select_default()
	Các chức năng thao tác tuyến đường. Nên tuân thủ khá chặt chẽ với
	các hàm tương ứng trong fib_hash.

fn_trie_flush()
	Thao tác này sẽ thực hiện toàn bộ trie (sử dụng nextleaf()) và tìm kiếm các khoảng trống
	những chiếc lá cần phải loại bỏ.

fn_trie_dump()
	Loại bỏ bảng định tuyến được sắp xếp theo độ dài tiền tố. Điều này có phần
	chậm hơn hàm fib_hash tương ứng, vì chúng ta phải thực hiện
	toàn bộ lần thử cho mỗi độ dài tiền tố. Để so sánh, fib_hash được tổ chức
	dưới dạng một "vùng"/băm cho mỗi độ dài tiền tố.

Khóa
-------

fib_lock được sử dụng cho khóa RW giống như cách được thực hiện trong fib_hash.
Tuy nhiên, các chức năng có phần tách biệt đối với các chức năng khóa khác có thể có.
kịch bản. Có thể hình dung được là có thể chạy trie_rebalance thông qua RCU
để tránh read_lock trong hàm fn_trie_lookup().

Cơ chế tra cứu chính
---------------------
fn_trie_lookup() là chức năng tra cứu chính.

Việc tra cứu ở dạng đơn giản nhất giống như fib_find_node(). Chúng tôi đi xuống
thử, phân đoạn khóa theo phân đoạn khóa, cho đến khi chúng ta tìm thấy một chiếc lá. check_leaf() thì có
fib_semantic_match trong danh sách tiền tố được sắp xếp của lá.

Nếu chúng tôi tìm thấy một kết quả phù hợp, chúng tôi đã hoàn thành.

Nếu chúng tôi không tìm thấy kết quả khớp, chúng tôi sẽ chuyển sang chế độ khớp tiền tố. Độ dài tiền tố,
bắt đầu bằng độ dài khóa, được giảm từng bước một,
và chúng tôi quay ngược trở lên trong quá trình cố gắng tìm kết quả phù hợp dài nhất
tiền tố. Mục tiêu luôn là đạt được một chiếc lá và nhận được kết quả tích cực từ
cơ chế fib_semantic_match.

Bên trong mỗi tnode, việc tìm kiếm tiền tố phù hợp dài nhất bao gồm việc tìm kiếm
thông qua mảng con, cắt bỏ (về 0) số "1" có ý nghĩa nhỏ nhất của
chỉ mục con cho đến khi chúng tôi tìm thấy kết quả khớp hoặc chỉ mục con không có gì ngoài
số không.

Tại thời điểm này, chúng tôi quay lại (t->stats.backtrack++) bộ ba, tiếp tục
cắt bỏ một phần khóa để tìm tiền tố phù hợp dài nhất.

Tại thời điểm này, chúng tôi sẽ liên tục hạ xuống các thử nghiệm phụ để tìm kiếm sự trùng khớp và ở đó
có sẵn một số tính năng tối ưu hóa có thể cung cấp cho chúng tôi những "lối tắt" để tránh
đi vào ngõ cụt. Tìm phần "HL_OPTIMIZE" trong mã.

Để giảm bớt mọi nghi ngờ về tính đúng đắn của quá trình lựa chọn tuyến đường,
một hoạt động liên kết mạng mới đã được thêm vào. Hãy tìm NETLINK_FIB_LOOKUP,
cấp cho người dùng quyền truy cập vào fib_lookup().