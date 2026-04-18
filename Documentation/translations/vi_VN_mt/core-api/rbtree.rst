.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/rbtree.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Cây đỏ đen (rbtree) trong Linux
====================================


:Ngày: 18 tháng 1 năm 2007
:Tác giả: Rob Landley <rob@landley.net>

Cây đỏ đen là gì và chúng dùng để làm gì?
------------------------------------------------

Cây đỏ đen là một loại cây tìm kiếm nhị phân tự cân bằng, được sử dụng để
lưu trữ các cặp dữ liệu khóa/giá trị có thể sắp xếp.  Điều này khác với cây cơ số (mà
được sử dụng để lưu trữ hiệu quả các mảng thưa thớt và do đó sử dụng các chỉ mục số nguyên dài
để chèn/truy cập/xóa các nút) và bảng băm (không được sắp xếp thành
có thể dễ dàng duyệt theo thứ tự và phải được điều chỉnh theo kích thước và kích thước cụ thể
hàm băm trong đó rbtrees chia tỷ lệ lưu trữ các khóa tùy ý một cách duyên dáng).

Cây đỏ đen tương tự như cây AVL nhưng cung cấp khả năng giới hạn thời gian thực nhanh hơn
hiệu suất trong trường hợp xấu nhất để chèn và xóa (nhiều nhất là hai phép quay và
ba vòng quay tương ứng để cân bằng cây), với tốc độ chậm hơn một chút
(nhưng vẫn còn O(log n)) thời gian tra cứu.

Để trích dẫn Tin tức hàng tuần của Linux:

Có một số cây đỏ đen được sử dụng trong kernel.
    Thời hạn và bộ lập lịch I/O CFQ sử dụng rbtrees để
    theo dõi yêu cầu; trình điều khiển gói CD/DVD cũng làm như vậy.
    Mã hẹn giờ có độ phân giải cao sử dụng rbtree để sắp xếp các
    yêu cầu hẹn giờ.  Hệ thống tập tin ext3 theo dõi các mục nhập thư mục trong một
    cây đỏ đen.  Vùng bộ nhớ ảo (VMA) được theo dõi bằng màu đỏ-đen
    cây, cũng như các bộ mô tả tệp epoll, khóa mật mã và mạng
    các gói trong bộ lập lịch "nhóm mã thông báo phân cấp".

Tài liệu này đề cập đến việc sử dụng triển khai rbtree của Linux.  Để biết thêm
thông tin về bản chất và cách thực hiện Cây Đỏ Đen, xem:

Bài viết tin tức hàng tuần của Linux về cây đỏ đen
    ZZ0000ZZ

Mục Wikipedia về cây đỏ đen
    ZZ0000ZZ

Linux triển khai cây đỏ đen
---------------------------------------

Việc triển khai rbtree của Linux nằm trong tệp "lib/rbtree.c".  Để sử dụng nó,
"#include <linux/rbtree.h>".

Việc triển khai rbtree của Linux được tối ưu hóa về tốc độ và do đó có một
ít lớp gián tiếp hơn (và vị trí bộ đệm tốt hơn) so với truyền thống
việc triển khai cây.  Thay vì sử dụng con trỏ để phân tách rb_node và dữ liệu
cấu trúc, mỗi phiên bản của struct rb_node được nhúng trong cấu trúc dữ liệu
nó tổ chức.  Và thay vì sử dụng con trỏ hàm gọi lại so sánh,
người dùng phải viết các hàm tìm kiếm và chèn cây của riêng họ
gọi các hàm rbtree được cung cấp.  Việc khóa cũng được tùy thuộc vào
người sử dụng mã rbtree.

Tạo một rbtree mới
---------------------

Các nút dữ liệu trong cây rbtree là các cấu trúc chứa thành viên struct rb_node::

cấu trúc mytype {
  	nút cấu trúc rb_node;
  	char *chuỗi phím;
  };

Khi xử lý một con trỏ tới struct rb_node được nhúng, dữ liệu chứa
cấu trúc có thể được truy cập bằng macro container_of() tiêu chuẩn.  Ngoài ra,
các thành viên riêng lẻ có thể được truy cập trực tiếp thông qua rb_entry(node, type, member).

Ở gốc của mỗi rbtree là cấu trúc rb_root, được khởi tạo là
trống qua:

cấu trúc rb_root mytree = RB_ROOT;

Tìm kiếm một giá trị trong rbtree
----------------------------------

Viết một hàm tìm kiếm cho cây của bạn khá đơn giản: bắt đầu từ
root, so sánh từng giá trị và theo nhánh trái hoặc nhánh phải nếu cần.

Ví dụ::

cấu trúc mytype *my_search(struct rb_root *root, chuỗi char *)
  {
  	struct rb_node *node = root->rb_node;

trong khi (nút) {
  		struct mytype *data = container_of(node, struct mytype, node);
		kết quả int;

kết quả = strcmp(chuỗi, dữ liệu->chuỗi khóa);

nếu (kết quả < 0)
  			nút = nút->rb_left;
		ngược lại nếu (kết quả > 0)
  			nút = nút->rb_right;
		khác
  			trả về dữ liệu;
	}
	trả lại NULL;
  }

Chèn dữ liệu vào rbtree
-----------------------------

Việc chèn dữ liệu vào cây trước tiên bao gồm việc tìm kiếm vị trí để chèn dữ liệu.
nút mới, sau đó chèn nút đó và cân bằng lại ("đổi màu") cho cây.

Tìm kiếm để chèn khác với tìm kiếm trước đó bằng cách tìm
vị trí của con trỏ để ghép nút mới.  Nút mới cũng
cần một liên kết đến nút cha của nó cho mục đích tái cân bằng.

Ví dụ::

int my_insert(struct rb_root *root, struct mytype *data)
  {
  	cấu trúc rb_node **new = &(root->rb_node), *parent = NULL;

/* Tìm ra vị trí đặt nút mới */
  	trong khi (*mới) {
  		struct mytype *this = container_of(*new, struct mytype, node);
  		int result = strcmp(data->keystring, this->keystring);

cha mẹ = *mới;
  		nếu (kết quả < 0)
  			mới = &((*mới)->rb_left);
  		ngược lại nếu (kết quả > 0)
  			mới = &((*mới)->rb_right);
  		khác
  			trả lại FALSE;
  	}

/* Thêm nút mới và cây cân bằng lại. */
  	rb_link_node(&data->node, cha, new);
  	rb_insert_color(&data->node, root);

trả lại TRUE;
  }

Xóa hoặc thay thế dữ liệu hiện có trong rbtree
------------------------------------------------

Để xóa một nút hiện có khỏi cây, hãy gọi ::

void rb_erase(struct rb_node *victim, struct rb_root *tree);

Ví dụ::

struct mytype *data = mysearch(&mytree, "walrus");

nếu (dữ liệu) {
  	rb_erase(&data->node, &mytree);
  	myfree(dữ liệu);
  }

Để thay thế một nút hiện có trong cây bằng một nút mới có cùng khóa, hãy gọi ::

void rb_replace_node(struct rb_node *old, struct rb_node *new,
  			cấu trúc rb_root *cây);

Việc thay thế một nút theo cách này sẽ không sắp xếp lại cây: Nếu nút mới không sắp xếp lại
có cùng khóa với nút cũ thì rbtree có thể sẽ bị hỏng.

Lặp lại các phần tử được lưu trữ trong rbtree (theo thứ tự sắp xếp)
-------------------------------------------------------------------

Bốn hàm được cung cấp để lặp qua nội dung của rbtree trong
thứ tự sắp xếp.  Chúng hoạt động trên các cây tùy ý và không cần phải
được sửa đổi hoặc bọc (trừ mục đích khóa)::

cấu trúc rb_node *rb_first(struct rb_root *tree);
  cấu trúc rb_node *rb_last(struct rb_root *tree);
  cấu trúc rb_node *rb_next(struct rb_node *node);
  cấu trúc rb_node *rb_prev(struct rb_node *node);

Để bắt đầu lặp lại, hãy gọi rb_first() hoặc rb_last() bằng con trỏ tới gốc
của cây, nó sẽ trả về một con trỏ tới cấu trúc nút có trong
phần tử đầu tiên hoặc cuối cùng của cây.  Để tiếp tục, hãy tìm nạp phần tiếp theo hoặc trước đó
nút bằng cách gọi rb_next() hoặc rb_prev() trên nút hiện tại.  Điều này sẽ trở lại
NULL khi không còn nút nào nữa.

Các hàm lặp trả về một con trỏ tới cấu trúc rb_node được nhúng, từ
cấu trúc dữ liệu chứa có thể được truy cập bằng container_of()
vĩ mô và các thành viên riêng lẻ có thể được truy cập trực tiếp thông qua
rb_entry(nút, loại, thành viên).

Ví dụ::

cấu trúc rb_node *nút;
  cho (nút = rb_first(&mytree); nút; nút = rb_next(nút))
	printk("key=%s\n", rb_entry(node, struct mytype, node)->keystring);

Rbtree được lưu trong bộ nhớ đệm
--------------------------------

Tính toán nút ngoài cùng bên trái (nhỏ nhất) là một nhiệm vụ khá phổ biến đối với hệ nhị phân
cây tìm kiếm, chẳng hạn như để duyệt hoặc người dùng dựa vào cụ thể
trật tự logic của riêng mình. Để đạt được mục đích này, người dùng có thể sử dụng 'struct rb_root_cached'
để tối ưu hóa các lệnh gọi O(logN) rb_first() nhằm tránh tìm nạp con trỏ đơn giản
lặp lại cây có khả năng tốn kém. Điều này được thực hiện trong thời gian chạy không đáng kể
chi phí bảo trì; mặc dù dung lượng bộ nhớ lớn hơn.

Tương tự như cấu trúc rb_root, rbtrees được lưu trong bộ nhớ đệm được khởi tạo là
trống qua::

cấu trúc rb_root_cached mytree = RB_ROOT_CACHED;

Rbtree được lưu trong bộ nhớ đệm chỉ đơn giản là một rb_root thông thường có thêm một con trỏ để lưu vào bộ nhớ đệm
nút ngoài cùng bên trái. Điều này cho phép rb_root_cached tồn tại ở bất cứ nơi nào rb_root tồn tại,
cho phép hỗ trợ các cây tăng cường cũng như chỉ một số cây bổ sung
giao diện::

cấu trúc rb_node *rb_first_cached(struct rb_root_cached *tree);
  void rb_insert_color_cached(struct rb_node ZZ0001ZZ, bool);
  void rb_erase_cached(struct rb_node ZZ0002ZZ);

Cả hai cuộc gọi chèn và xóa đều có bản sao tương ứng của chúng
cây cối::

void rb_insert_augmented_cached(struct rb_node ZZ0000ZZ,
				  bool, struct rb_augment_callbacks *);
  void rb_erase_augmented_cached(struct rb_node ZZ0001ZZ,
				 cấu trúc rb_augment_callbacks *);


Hỗ trợ cho rbtrees tăng cường
-----------------------------

Rbtree tăng cường là một rbtree với "một số" dữ liệu bổ sung được lưu trữ trong
mỗi nút, trong đó dữ liệu bổ sung cho nút N phải là hàm của
nội dung của tất cả các nút trong cây con có gốc tại N. Dữ liệu này có thể
được sử dụng để tăng thêm một số chức năng mới cho rbtree. cây tăng cường
là một tính năng tùy chọn được xây dựng dựa trên cơ sở hạ tầng rbtree cơ bản.
Người dùng rbtree muốn có tính năng này sẽ phải gọi phần mở rộng
các chức năng với lệnh gọi lại tăng cường do người dùng cung cấp khi chèn
và xóa các nút.

Các tệp C thực hiện thao tác rbtree tăng cường phải bao gồm
<linux/rbtree_augmented.h> thay vì <linux/rbtree.h>. Lưu ý rằng
linux/rbtree_augmented.h tiết lộ một số chi tiết triển khai rbtree
bạn không cần phải dựa vào; vui lòng tuân theo các API đã được ghi lại
ở đó và không bao gồm <linux/rbtree_augmented.h> từ các tệp tiêu đề
để giảm thiểu khả năng người dùng của bạn vô tình dựa vào
chi tiết thực hiện như vậy.

Khi chèn, người dùng phải cập nhật thông tin bổ sung trên đường dẫn
dẫn đến nút được chèn, sau đó gọi rb_link_node() như bình thường và
rb_augment_inserted() thay vì lệnh gọi rb_insert_color() thông thường.
Nếu rb_augment_inserted() cân bằng lại rbtree, nó sẽ gọi lại vào
chức năng do người dùng cung cấp để cập nhật thông tin bổ sung trên
cây con bị ảnh hưởng.

Khi xóa một nút, người dùng phải gọi rb_erase_augmented() thay vì
rb_erase(). rb_erase_augmented() gọi lại các hàm do người dùng cung cấp
để cập nhật thông tin bổ sung về các cây con bị ảnh hưởng.

Trong cả hai trường hợp, lệnh gọi lại được cung cấp thông qua struct rb_augment_callbacks.
3 cuộc gọi lại phải được xác định:

- Lệnh gọi lại lan truyền, cập nhật giá trị gia tăng cho một giá trị nhất định
  nút và tổ tiên của nó, tới một điểm dừng nhất định (hoặc NULL để cập nhật
  đến tận gốc).

- Lệnh gọi lại sao chép, sao chép giá trị tăng thêm cho một cây con nhất định
  tới gốc cây con mới được gán.

- Lệnh gọi lại xoay cây, sao chép giá trị tăng thêm cho một giá trị nhất định
  cây con tới gốc cây con mới được gán AND tính toán lại phần mở rộng
  thông tin về gốc cây con cũ.

Mã được biên dịch cho rb_erase_augmented() có thể nằm trong dòng truyền bá và
sao chép các cuộc gọi lại, dẫn đến một hàm lớn, do đó, mỗi rbtree tăng cường
người dùng nên có một trang gọi rb_erase_augmented() duy nhất để hạn chế
kích thước mã được biên dịch.


Sử dụng mẫu
^^^^^^^^^^^^

Cây khoảng là một ví dụ về cây rb tăng cường. Tham khảo -
"Giới thiệu về thuật toán" của Cormen, Leiserson, Rivest và Stein.
Thông tin chi tiết hơn về cây khoảng:

Rbtree cổ điển có một khóa duy nhất và nó không thể được sử dụng trực tiếp để lưu trữ
phạm vi khoảng thời gian như [lo:hi] và tra cứu nhanh bất kỳ sự trùng lặp nào với một khoảng thời gian mới
lo:hi hoặc để tìm xem có kết quả khớp chính xác nào cho lo:hi mới hay không.

Tuy nhiên, rbtree có thể được tăng cường để lưu trữ các khoảng thời gian như vậy trong một cấu trúc có cấu trúc.
cách giúp bạn có thể thực hiện tra cứu hiệu quả và đối sánh chính xác.

"Thông tin bổ sung" này được lưu trữ trong mỗi nút là hi
(max_hi) trong số tất cả các nút là con cháu của nó. Cái này
thông tin có thể được duy trì tại mỗi nút chỉ bằng cách nhìn vào nút
và những đứa con trực tiếp của nó. Và điều này sẽ được sử dụng trong tra cứu O(log n)
cho kết quả phù hợp thấp nhất (địa chỉ bắt đầu thấp nhất trong số tất cả các kết quả phù hợp có thể)
với một cái gì đó như::

cấu trúc interval_tree_node *
  interval_tree_first_match(struct rb_root *root,
			    bắt đầu dài không dấu, kéo dài không dấu)
  {
	cấu trúc interval_tree_node *nút;

nếu (!root->rb_node)
		trả lại NULL;
	nút = rb_entry(root->rb_node, struct interval_tree_node, rb);

trong khi (đúng) {
		if (node->rb.rb_left) {
			cấu trúc interval_tree_node *trái =
				rb_entry(nút->rb.rb_left,
					 cấu trúc interval_tree_node, rb);
			if (left->__subtree_last >= bắt đầu) {
				/*
				 * Một số nút ở cây con bên trái thỏa mãn Cond2.
				 * Lặp lại để tìm nút N ngoài cùng bên trái.
				 * Nếu cũng thỏa mãn Cond1 thì đó là kết quả phù hợp
				 * chúng tôi đang tìm kiếm. Nếu không thì không có
				 * khoảng thời gian khớp như các nút ở bên phải của N
				 * cũng không thể thỏa mãn Cond1.
				 */
				nút = trái;
				Tiếp tục;
			}
		}
		if (nút->bắt đầu <= cuối cùng) { /* Cond1 */
			if (nút->cuối >= bắt đầu) /* Cond2 */
				nút trả về;	/* nút khớp ngoài cùng bên trái */
			if (node->rb.rb_right) {
				nút = rb_entry(node->rb.rb_right,
					cấu trúc interval_tree_node, rb);
				if (nút->__subtree_last >= bắt đầu)
					tiếp tục;
			}
		}
		trả lại NULL;	/* Không khớp */
	}
  }

Việc chèn/xóa được xác định bằng cách sử dụng các lệnh gọi lại tăng cường sau::

nội tuyến tĩnh không dấu dài
  tính_subtree_last(struct interval_tree_node *nút)
  {
	unsigned long max = node->last, subtree_last;
	if (node->rb.rb_left) {
		cây con_last = rb_entry(node->rb.rb_left,
			cấu trúc interval_tree_node, rb)->__subtree_last;
		nếu (tối đa < cây con_last)
			max = cây con_last;
	}
	if (node->rb.rb_right) {
		cây con_last = rb_entry(node->rb.rb_right,
			cấu trúc interval_tree_node, rb)->__subtree_last;
		nếu (tối đa < cây con_last)
			max = cây con_last;
	}
	trả lại tối đa;
  }

tĩnh void Augment_propagate (struct rb_node *rb, struct rb_node *stop)
  {
	while (rb != dừng lại) {
		cấu trúc interval_tree_node *nút =
			rb_entry(rb, struct interval_tree_node, rb);
		cây con_last dài không dấu = tính_subtree_last(nút);
		if (nút->__subtree_last == subtree_last)
			phá vỡ;
		nút->__subtree_last = cây con_last;
		rb = rb_parent(&node->rb);
	}
  }

tĩnh void Augment_copy(struct rb_node *rb_old, struct rb_node *rb_new)
  {
	cấu trúc interval_tree_node *cũ =
		rb_entry(rb_old, struct interval_tree_node, rb);
	cấu trúc interval_tree_node *mới =
		rb_entry(rb_new, struct interval_tree_node, rb);

mới->__subtree_last = cũ->__subtree_last;
  }

tĩnh void Augment_rotate(struct rb_node *rb_old, struct rb_node *rb_new)
  {
	cấu trúc interval_tree_node *cũ =
		rb_entry(rb_old, struct interval_tree_node, rb);
	cấu trúc interval_tree_node *mới =
		rb_entry(rb_new, struct interval_tree_node, rb);

mới->__subtree_last = cũ->__subtree_last;
	old->__subtree_last = tính_subtree_last(cũ);
  }

cấu trúc const tĩnh rb_augment_callbacks Augment_callbacks = {
	tăng cường_propagate, tăng cường_copy, tăng cường_rotate
  };

void interval_tree_insert(struct interval_tree_node *nút,
			    cấu trúc rb_root *root)
  {
	cấu trúc rb_node **link = &root->rb_node, *rb_parent = NULL;
	bắt đầu dài không dấu = nút->bắt đầu, cuối cùng = nút->cuối cùng;
	struct interval_tree_node *parent;

trong khi (*liên kết) {
		rb_parent = *liên kết;
		parent = rb_entry(rb_parent, struct interval_tree_node, rb);
		if (cha mẹ->__subtree_last < cuối cùng)
			cha mẹ->__subtree_last = cuối cùng;
		if (bắt đầu < cha mẹ-> bắt đầu)
			liên kết = &parent->rb.rb_left;
		khác
			liên kết = &parent->rb.rb_right;
	}

nút->__subtree_last = cuối cùng;
	rb_link_node(&node->rb, rb_parent, liên kết);
	rb_insert_augmented(&node->rb, root, &augment_callbacks);
  }

void interval_tree_remove(struct interval_tree_node *node,
			    cấu trúc rb_root *root)
  {
	rb_erase_augmented(&node->rb, root, &augment_callbacks);
  }
