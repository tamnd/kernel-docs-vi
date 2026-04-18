.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/graph_ds_impl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Cấu trúc dữ liệu đồ thị BPF
===========================

Tài liệu này mô tả chi tiết triển khai dữ liệu "biểu đồ" kiểu mới
các cấu trúc (linked_list, rbtree), đặc biệt tập trung vào trình xác minh
triển khai ngữ nghĩa cụ thể cho các cấu trúc dữ liệu đó.

Mặc dù không có mã xác minh cụ thể nào được đề cập trong tài liệu này, nhưng tài liệu
giả định rằng người đọc có kiến thức chung về nội bộ của trình xác minh BPF, BPF
bản đồ và viết chương trình BPF.

Lưu ý rằng mục đích của tài liệu này là mô tả trạng thái hiện tại của
các cấu trúc dữ liệu đồ thị này. ZZ0000ZZ về độ ổn định cho cả hai
ngữ nghĩa hoặc API được tạo ra hoặc ngụ ý ở đây.

.. contents::
    :local:
    :depth: 2

Giới thiệu
------------

Bản đồ BPF API trước đây là cách chính để hiển thị cấu trúc dữ liệu
có nhiều loại khác nhau để sử dụng trong các chương trình BPF. Một số cấu trúc dữ liệu phù hợp một cách tự nhiên
với bản đồ API (HASH, ARRAY), những bản đồ khác thì ít hơn. Theo đó, các chương trình
tương tác với nhóm cấu trúc dữ liệu sau có thể khó phân tích cú pháp
dành cho các lập trình viên kernel chưa có kinh nghiệm về BPF trước đó.

May mắn thay, một số hạn chế bắt buộc phải sử dụng ngữ nghĩa bản đồ BPF là
không còn phù hợp nữa. Với sự ra đời của kfuncs, kptrs và bất kỳ ngữ cảnh nào
Bộ cấp phát BPF, giờ đây có thể triển khai các cấu trúc dữ liệu BPF có API
và ngữ nghĩa phù hợp chặt chẽ hơn với những gì được tiếp xúc với phần còn lại của hạt nhân.

Hai cấu trúc dữ liệu như vậy - linked_list và rbtree - có nhiều xác minh
những chi tiết chung. Bởi vì cả hai đều có "root" ("head" cho linked_list) và
"nút", mã xác minh và tài liệu này đề cập đến chức năng chung
như "graph_api", "graph_root", "graph_node", v.v.

Trừ khi có quy định khác, các ví dụ và ngữ nghĩa bên dưới áp dụng cho cả dữ liệu biểu đồ
các cấu trúc.

API không ổn định
-----------------

Cấu trúc dữ liệu được triển khai bằng bản đồ BPF API trước đây đã sử dụng BPF
các chức năng của trình trợ giúp - hoặc các trình trợ giúp API bản đồ tiêu chuẩn như ZZ0000ZZ
hoặc người trợ giúp cụ thể trên bản đồ. Thay vào đó, cấu trúc dữ liệu biểu đồ kiểu mới sử dụng kfuncs
để xác định người trợ giúp thao tác của họ. Bởi vì không có sự đảm bảo về sự ổn định
đối với kfuncs, API và ngữ nghĩa cho các cấu trúc dữ liệu này có thể được phát triển theo
một cách phá vỡ khả năng tương thích ngược nếu cần thiết.

Các loại nút gốc và nút cho cấu trúc dữ liệu mới được xác định rõ ràng trong
Tiêu đề ZZ0000ZZ.

Khóa
-------

Các cấu trúc dữ liệu kiểu mới có tính xâm nhập và được định nghĩa tương tự như cấu trúc dữ liệu của chúng.
đối tác hạt vani:

.. code-block:: c

        struct node_data {
          long key;
          long data;
          struct bpf_rb_node node;
        };

        struct bpf_spin_lock glock;
        struct bpf_rb_root groot __contains(node_data, node);

Loại "root" cho cả linked_list và rbtree dự kiến sẽ nằm trong map_value
cũng chứa ZZ0000ZZ - trong ví dụ trên cả toàn cầu
các biến được đặt trong một sơ đồ mảng một giá trị. Người xác minh xem xét điều này
spin_lock được liên kết với ZZ0001ZZ nhờ cả hai đều ở trong
cùng một map_value và sẽ thực thi rằng khóa chính xác được giữ khi
xác minh các chương trình BPF thao tác với cây. Vì việc kiểm tra khóa này
xảy ra tại thời điểm xác minh, không có hình phạt khi chạy.

Tài liệu tham khảo không sở hữu
-------------------------------

ZZ0000ZZ

Hãy xem xét mã BPF sau:

.. code-block:: c

        struct node_data *n = bpf_obj_new(typeof(*n)); /* ACQUIRED */

        bpf_spin_lock(&lock);

        bpf_rbtree_add(&tree, n); /* PASSED */

        bpf_spin_unlock(&lock);

Từ quan điểm của người xác minh, con trỏ ZZ0000ZZ được trả về từ ZZ0001ZZ
có loại ZZ0002ZZ, với ZZ0003ZZ là
ZZ0004ZZ và ZZ0005ZZ khác 0. Bởi vì nó chứa ZZ0006ZZ,
chương trình có quyền sở hữu vòng đời của điểm (đối tượng được trỏ bởi ZZ0007ZZ).
Chương trình BPF phải chuyển quyền sở hữu trước khi thoát - thông qua
ZZ0008ZZ, ZZ0009ZZ là đối tượng hoặc bằng cách thêm nó vào ZZ0010ZZ với
ZZ0011ZZ.

(Nhận xét ZZ0000ZZ và ZZ0001ZZ trong ví dụ biểu thị các câu lệnh trong đó
tương ứng là "quyền sở hữu được mua lại" và "quyền sở hữu được chuyển giao")

Người xác minh nên làm gì với ZZ0000ZZ sau khi quyền sở hữu bị mất? Nếu
đối tượng là ZZ0001ZZ'd với ZZ0002ZZ, câu trả lời rất rõ ràng: người xác minh
nên từ chối các chương trình cố gắng truy cập ZZ0003ZZ sau ZZ0004ZZ vì
đối tượng không còn giá trị nữa. Bộ nhớ cơ bản có thể đã được sử dụng lại cho
một số phân bổ khác, chưa được ánh xạ, v.v.

Khi quyền sở hữu được chuyển cho ZZ0000ZZ thông qua ZZ0001ZZ thì câu trả lời là ít hơn
rõ ràng. Trình xác minh có thể thực thi ngữ nghĩa tương tự như đối với ZZ0002ZZ,
nhưng điều đó sẽ dẫn đến các chương trình có mẫu mã hóa phổ biến, hữu ích được
bị từ chối, ví dụ:

.. code-block:: c

        int x;
        struct node_data *n = bpf_obj_new(typeof(*n)); /* ACQUIRED */

        bpf_spin_lock(&lock);

        bpf_rbtree_add(&tree, n); /* PASSED */
        x = n->data;
        n->data = 42;

        bpf_spin_unlock(&lock);

Cả việc đọc và ghi vào ZZ0000ZZ đều sẽ bị từ chối. Người xác minh
Tuy nhiên, có thể làm tốt hơn bằng cách tận dụng hai chi tiết:

* Chỉ có thể sử dụng API cấu trúc dữ liệu đồ thị khi ZZ0000ZZ
    liên kết với gốc đồ thị được giữ

* Cả hai cấu trúc dữ liệu đồ thị đều có tính ổn định của con trỏ

* Bởi vì các nút biểu đồ được phân bổ bằng ZZ0000ZZ và
       việc thêm/xóa từ gốc liên quan đến việc thay đổi
       Trường ZZ0001ZZ của cấu trúc nút, một nút biểu đồ sẽ
       vẫn ở cùng một địa chỉ sau một trong hai thao tác.

Bởi vì ZZ0000ZZ liên quan phải được giữ bởi bất kỳ chương trình nào thêm
hoặc đang gỡ bỏ, nếu chúng ta đang ở trong phần quan trọng được giới hạn bởi khóa đó, chúng ta biết
mà không chương trình nào khác có thể thêm hoặc bớt cho đến hết phần quan trọng.
Điều này kết hợp với sự ổn định của con trỏ có nghĩa là cho đến khi phần quan trọng
kết thúc, chúng ta có thể truy cập nút biểu đồ một cách an toàn thông qua ZZ0001ZZ ngay cả sau khi nó được sử dụng
để chuyển quyền sở hữu.

Người xác minh coi tham chiếu đó là ZZ0001ZZ. trọng tài
được trả về bởi ZZ0000ZZ theo đó được coi là ZZ0002ZZ.
Cả hai thuật ngữ hiện chỉ có ý nghĩa trong ngữ cảnh của các nút biểu đồ và API.

ZZ0000ZZ

Hãy liệt kê các thuộc tính của cả hai loại tài liệu tham khảo.

ZZ0000ZZ

* Tham chiếu này kiểm soát thời gian tồn tại của con trỏ

* Quyền sở hữu pointee phải được 'giải phóng' bằng cách chuyển nó tới một số biểu đồ API
    kfunc hoặc thông qua ZZ0000ZZ, ZZ0001ZZ là điểm chính

* Nếu không được phát hành trước khi chương trình kết thúc, người xác minh coi chương trình không hợp lệ

* Truy cập vào bộ nhớ của con trỏ sẽ không bị lỗi trang

ZZ0000ZZ

* Tài liệu tham khảo này không sở hữu pointee

* Không thể sử dụng nó để thêm nút biểu đồ vào gốc biểu đồ, cũng như ZZ0000ZZ'd thông qua
       ZZ0001ZZ

* Không có sự kiểm soát rõ ràng về thời gian tồn tại, nhưng có thể suy ra thời gian tồn tại hợp lệ dựa trên
    sự tồn tại của ref không sở hữu (xem giải thích bên dưới)

* Truy cập vào bộ nhớ của con trỏ sẽ không bị lỗi trang

Từ quan điểm của người xác minh, các tài liệu tham khảo không sở hữu chỉ có thể tồn tại
giữa spin_lock và spin_unlock. Tại sao? Sau spin_unlock một chương trình khác
có thể thực hiện các thao tác tùy ý trên cấu trúc dữ liệu như xóa và ZZ0000ZZ-ing
thông qua bpf_obj_drop. Một tham chiếu không sở hữu đối với một số đoạn bộ nhớ đã bị xóa,
ZZ0001ZZ'd và được sử dụng lại qua bpf_obj_new sẽ chỉ ra một điều hoàn toàn khác.
Hoặc ký ức có thể biến mất.

Để ngăn chặn sự vi phạm logic này, tất cả các tham chiếu không sở hữu đều bị vô hiệu bởi
người xác minh sau khi phần quan trọng kết thúc. Điều này là cần thiết để đảm bảo “ý chí
không phải lỗi trang" của tài liệu tham khảo không sở hữu. Vì vậy, nếu người xác minh không
đã vô hiệu hóa một ref không sở hữu, việc truy cập nó sẽ không bị lỗi trang.

Hiện tại ZZ0000ZZ không được phép trong phần quan trọng, vì vậy
nếu có một giới thiệu không sở hữu hợp lệ, chúng tôi phải ở trong phần quan trọng và có thể
kết luận rằng bộ nhớ của người giới thiệu vẫn chưa bị mất-và- ZZ0001ZZ'd hoặc
bỏ đi và tái sử dụng.

Bất kỳ tham chiếu nào đến nút nằm trong rbtree _phải_ không sở hữu, vì
cây có quyền kiểm soát vòng đời của con trỏ. Tương tự, bất kỳ tham chiếu nào tới một nút
thứ đó không có trong rbtree _phải_ sở hữu. Điều này dẫn đến một thuộc tính tốt đẹp:
đồ thị API việc triển khai thêm / xóa không cần kiểm tra xem một nút có
đã được thêm vào (hoặc đã bị xóa), làm mô hình sở hữu
cho phép người xác minh ngăn chặn trạng thái đó hợp lệ bằng cách kiểm tra đơn giản
các loại.

Tuy nhiên, việc đặt bí danh con trỏ đặt ra một vấn đề đối với "thuộc tính đẹp" ở trên.
Hãy xem xét ví dụ sau:

.. code-block:: c

        struct node_data *n, *m, *o, *p;
        n = bpf_obj_new(typeof(*n));     /* 1 */

        bpf_spin_lock(&lock);

        bpf_rbtree_add(&tree, n);        /* 2 */
        m = bpf_rbtree_first(&tree);     /* 3 */

        o = bpf_rbtree_remove(&tree, n); /* 4 */
        p = bpf_rbtree_remove(&tree, m); /* 5 */

        bpf_spin_unlock(&lock);

        bpf_obj_drop(o);
        bpf_obj_drop(p); /* 6 */

Giả sử cây trống trước khi chương trình này chạy. Nếu chúng tôi theo dõi trạng thái của người xác minh
những thay đổi ở đây bằng cách sử dụng các con số trong các nhận xét trên:

1) n là một tài liệu tham khảo sở hữu

2) n là tham chiếu không sở hữu, nó được thêm vào cây

3) n và m là các tham chiếu không sở hữu, cả hai đều trỏ đến cùng một nút

4) o là tham chiếu sở hữu, n và m không sở hữu, tất cả đều trỏ đến cùng một nút

5) o và p đang sở hữu, n và m không sở hữu, tất cả đều trỏ đến cùng một nút

6) đã xảy ra tình trạng tự do kép, vì o và p trỏ đến cùng một nút và o là
     ZZ0000ZZ'd trong tuyên bố trước đó

Các tiểu bang 4 và 5 vi phạm "tài sản tốt đẹp" của chúng tôi, vì có những đề cập đến việc không sở hữu
một nút không có trong rbtree. Câu lệnh 5 sẽ cố gắng loại bỏ một nút
đã bị xóa do vi phạm này. Trạng thái 6 là nguy hiểm
miễn phí gấp đôi.

Ở mức tối thiểu, chúng ta nên ngăn chặn trạng thái 6 có thể xảy ra. Nếu chúng ta cũng không thể
ngăn chặn trạng thái 5 thì chúng ta phải từ bỏ "tài sản tốt" của mình và kiểm tra xem liệu
nút đã bị xóa khi chạy.

Chúng tôi ngăn chặn cả hai điều này bằng cách khái quát hóa hành vi "vô hiệu hóa các tham chiếu không sở hữu"
của ZZ0000ZZ và thực hiện việc vô hiệu hóa tương tự sau
ZZ0001ZZ. Logic ở đây là bất kỳ đồ thị API kfunc nào:

* lấy một đối số nút tùy ý

* xóa nó khỏi cấu trúc dữ liệu

* trả về tham chiếu sở hữu cho nút đã bị xóa

Có thể dẫn đến tình trạng một số tài liệu tham khảo không sở hữu khác trỏ đến cùng một điểm
nút. Vì vậy, kfuncs loại ZZ0000ZZ phải được coi là tài liệu tham khảo không sở hữu
điểm vô hiệu là tốt.
