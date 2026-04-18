.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/map_sockmap.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. Copyright Red Hat

==================================================
BPF_MAP_TYPE_SOCKMAP và BPF_MAP_TYPE_SOCKHASH
==============================================

.. note::
   - ``BPF_MAP_TYPE_SOCKMAP`` was introduced in kernel version 4.14
   - ``BPF_MAP_TYPE_SOCKHASH`` was introduced in kernel version 4.18

Bản đồ ZZ0000ZZ và ZZ0001ZZ có thể được sử dụng để
chuyển hướng skbs giữa các ổ cắm hoặc áp dụng chính sách ở cấp ổ cắm dựa trên
kết quả của chương trình BPF (bản án) với sự trợ giúp của người trợ giúp BPF
ZZ0002ZZ, ZZ0003ZZ,
ZZ0004ZZ và ZZ0005ZZ.

ZZ0000ZZ được hỗ trợ bởi một mảng sử dụng khóa số nguyên làm
chỉ mục để tra cứu tham chiếu đến ZZ0001ZZ. Các giá trị bản đồ là ổ cắm
những người mô tả. Tương tự, ZZ0002ZZ là bản đồ BPF được hỗ trợ bằng hàm băm
giữ các tham chiếu đến ổ cắm thông qua bộ mô tả ổ cắm của chúng.

.. note::
    The value type is either __u32 or __u64; the latter (__u64) is to support
    returning socket cookies to userspace. Returning the ``struct sock *`` that
    the map holds to user-space is neither safe nor useful.

Các bản đồ này có thể có các chương trình BPF được đính kèm, cụ thể là chương trình phân tích cú pháp
và một chương trình phán quyết. Chương trình phân tích cú pháp xác định lượng dữ liệu đã được
được phân tích cú pháp và do đó cần phải xếp hàng bao nhiêu dữ liệu để đưa ra phán quyết. các
chương trình phán quyết về cơ bản là chương trình chuyển hướng và có thể trả về một phán quyết
của ZZ0000ZZ, ZZ0001ZZ hoặc ZZ0002ZZ.

Khi một socket được chèn vào một trong những bản đồ này, các lệnh gọi lại socket của nó sẽ
được thay thế và ZZ0000ZZ được gắn vào nó. Ngoài ra, điều này
ZZ0001ZZ kế thừa các chương trình được đính kèm trên bản đồ.

Một đối tượng sock có thể có trong nhiều bản đồ nhưng chỉ có thể kế thừa một bản đồ duy nhất.
chương trình phân tích hoặc phán quyết. Nếu thêm một đối tượng vớ vào bản đồ sẽ dẫn đến
khi có nhiều chương trình phân tích cú pháp, bản cập nhật sẽ trả về lỗi EBUSY.

Các chương trình được hỗ trợ để đính kèm vào các bản đồ này là:

.. code-block:: c

	struct sk_psock_progs {
		struct bpf_prog *msg_parser;
		struct bpf_prog *stream_parser;
		struct bpf_prog *stream_verdict;
		struct bpf_prog	*skb_verdict;
	};

.. note::
    Users are not allowed to attach ``stream_verdict`` and ``skb_verdict``
    programs to the same map.

Các loại đính kèm cho các chương trình bản đồ là:

- Chương trình ZZ0000ZZ - ZZ0001ZZ.
- Chương trình ZZ0002ZZ - ZZ0003ZZ.
- Chương trình ZZ0004ZZ - ZZ0005ZZ.
- Chương trình ZZ0006ZZ - ZZ0007ZZ.

Có sẵn các trình trợ giúp bổ sung để sử dụng với trình phân tích cú pháp và phán quyết
chương trình: ZZ0000ZZ và ZZ0001ZZ. Với
Các chương trình ZZ0002ZZ BPF có thể cho cơ sở hạ tầng biết có bao nhiêu
byte mà phán quyết đã cho sẽ được áp dụng. Người trợ giúp ZZ0003ZZ
xử lý một trường hợp khác trong đó chương trình BPF không thể đưa ra phán quyết về tin nhắn
cho đến khi nhận được nhiều byte hơn AND, chương trình không muốn chuyển tiếp gói
cho đến khi nó được biết là tốt.

Cuối cùng, những người trợ giúp ZZ0000ZZ và ZZ0001ZZ là
có sẵn cho các chương trình ZZ0002ZZ BPF để lấy dữ liệu và thiết lập
con trỏ bắt đầu và kết thúc tới các giá trị đã cho hoặc để thêm siêu dữ liệu vào ZZ0003ZZ.

Tất cả những người trợ giúp này sẽ được mô tả chi tiết hơn dưới đây.

Cách sử dụng
=====
Hạt nhân BPF
----------
bpf_msg_redirect_map()
^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: c

	long bpf_msg_redirect_map(struct sk_msg_buff *msg, struct bpf_map *map, u32 key, u64 flags)

Trình trợ giúp này được sử dụng trong các chương trình triển khai chính sách ở cấp độ ổ cắm. Nếu
thông báo ZZ0000ZZ được phép chuyển (tức là nếu chương trình BPF phán quyết
trả về ZZ0001ZZ), chuyển hướng nó đến ổ cắm được tham chiếu bởi ZZ0002ZZ (thuộc loại
ZZ0003ZZ) tại chỉ số ZZ0004ZZ. Cả giao diện đi vào và đi ra
có thể được sử dụng để chuyển hướng. Giá trị ZZ0005ZZ trong ZZ0006ZZ được sử dụng
để chọn đường dẫn vào nếu không thì đường dẫn ra sẽ được chọn. Đây là
cờ duy nhất được hỗ trợ bây giờ.

Trả về ZZ0000ZZ nếu thành công hoặc ZZ0001ZZ nếu có lỗi.

bpf_sk_redirect_map()
^^^^^^^^^^^^^^^^^^^^^
.. code-block:: c

    long bpf_sk_redirect_map(struct sk_buff *skb, struct bpf_map *map, u32 key u64 flags)

Chuyển hướng gói đến ổ cắm được tham chiếu bởi ZZ0000ZZ (thuộc loại
ZZ0001ZZ) tại chỉ số ZZ0002ZZ. Cả giao diện đi vào và đi ra
có thể được sử dụng để chuyển hướng. Giá trị ZZ0003ZZ trong ZZ0004ZZ được sử dụng
để chọn đường dẫn vào nếu không thì đường dẫn ra sẽ được chọn. Đây là
cờ duy nhất được hỗ trợ bây giờ.

Trả về ZZ0000ZZ nếu thành công hoặc ZZ0001ZZ nếu có lỗi.

bpf_map_lookup_elem()
^^^^^^^^^^^^^^^^^^^^^
.. code-block:: c

    void *bpf_map_lookup_elem(struct bpf_map *map, const void *key)

các mục ổ cắm loại ZZ0000ZZ có thể được truy xuất bằng cách sử dụng
Người trợ giúp ZZ0001ZZ.

bpf_sock_map_update()
^^^^^^^^^^^^^^^^^^^^^
.. code-block:: c

    long bpf_sock_map_update(struct bpf_sock_ops *skops, struct bpf_map *map, void *key, u64 flags)

Thêm mục nhập hoặc cập nhật ổ cắm tham chiếu ZZ0000ZZ. ZZ0001ZZ được sử dụng
làm giá trị mới cho mục nhập được liên kết với ZZ0002ZZ. Đối số ZZ0003ZZ có thể
là một trong những điều sau đây:

- ZZ0000ZZ: Tạo phần tử mới hoặc cập nhật phần tử hiện có.
- ZZ0001ZZ: Chỉ tạo một phần tử mới nếu nó chưa tồn tại.
- ZZ0002ZZ: Cập nhật phần tử hiện có.

Nếu ZZ0000ZZ có các chương trình BPF (trình phân tích cú pháp và phán đoán), những chương trình đó sẽ được kế thừa
bởi ổ cắm được thêm vào. Nếu ổ cắm đã được gắn vào các chương trình BPF,
điều này dẫn đến một lỗi.

Trả về 0 nếu thành công hoặc trả về lỗi âm trong trường hợp thất bại.

bpf_sock_hash_update()
^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: c

    long bpf_sock_hash_update(struct bpf_sock_ops *skops, struct bpf_map *map, void *key, u64 flags)

Thêm mục nhập hoặc cập nhật ổ cắm tham chiếu sockhash ZZ0000ZZ. ZZ0001ZZ
được sử dụng làm giá trị mới cho mục nhập được liên kết với ZZ0002ZZ.

Đối số ZZ0000ZZ có thể là một trong những đối số sau:

- ZZ0000ZZ: Tạo phần tử mới hoặc cập nhật phần tử hiện có.
- ZZ0001ZZ: Chỉ tạo một phần tử mới nếu nó chưa tồn tại.
- ZZ0002ZZ: Cập nhật phần tử hiện có.

Nếu ZZ0000ZZ có các chương trình BPF (trình phân tích cú pháp và phán đoán), những chương trình đó sẽ được kế thừa
bởi ổ cắm được thêm vào. Nếu ổ cắm đã được gắn vào các chương trình BPF,
điều này dẫn đến một lỗi.

Trả về 0 nếu thành công hoặc trả về lỗi âm trong trường hợp thất bại.

bpf_msg_redirect_hash()
^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: c

    long bpf_msg_redirect_hash(struct sk_msg_buff *msg, struct bpf_map *map, void *key, u64 flags)

Trình trợ giúp này được sử dụng trong các chương trình triển khai chính sách ở cấp độ ổ cắm. Nếu
thông báo ZZ0000ZZ được phép chuyển (tức là nếu chương trình BPF phán quyết trả về
ZZ0001ZZ), hãy chuyển hướng nó đến ổ cắm được tham chiếu bởi ZZ0002ZZ (thuộc loại
ZZ0003ZZ) sử dụng hàm băm ZZ0004ZZ. Cả lối vào và lối ra
giao diện có thể được sử dụng để chuyển hướng. Giá trị ZZ0005ZZ trong
ZZ0006ZZ được sử dụng để chọn đường dẫn vào nếu không thì đường dẫn đi ra sẽ bị
đã chọn. Đây là lá cờ duy nhất được hỗ trợ bây giờ.

Trả về ZZ0000ZZ nếu thành công hoặc ZZ0001ZZ nếu có lỗi.

bpf_sk_redirect_hash()
^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: c

    long bpf_sk_redirect_hash(struct sk_buff *skb, struct bpf_map *map, void *key, u64 flags)

Trình trợ giúp này được sử dụng trong các chương trình triển khai chính sách ở cấp độ ổ cắm skb.
Nếu sk_buff ZZ0000ZZ được phép vượt qua (tức là nếu phán quyết chương trình BPF
trả về ZZ0001ZZ), chuyển hướng nó đến ổ cắm được tham chiếu bởi ZZ0002ZZ (thuộc loại
ZZ0003ZZ) sử dụng hàm băm ZZ0004ZZ. Cả lối vào và lối ra
giao diện có thể được sử dụng để chuyển hướng. Giá trị ZZ0005ZZ trong
ZZ0006ZZ được sử dụng để chọn đường dẫn vào nếu không thì đường dẫn đi ra sẽ bị
đã chọn. Đây là lá cờ duy nhất được hỗ trợ bây giờ.

Trả về ZZ0000ZZ nếu thành công hoặc ZZ0001ZZ nếu có lỗi.

bpf_msg_apply_bytes()
^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: c

    long bpf_msg_apply_bytes(struct sk_msg_buff *msg, u32 bytes)

Đối với các chính sách ổ cắm, hãy áp dụng phán quyết của chương trình BPF cho (số) tiếp theo
của ZZ0000ZZ) của tin nhắn ZZ0001ZZ. Ví dụ: trình trợ giúp này có thể được sử dụng trong
trường hợp sau:

- Một lệnh gọi hệ thống ZZ0000ZZ hoặc ZZ0001ZZ chứa nhiều
  thông điệp logic mà chương trình BPF phải đọc và nó
  nên áp dụng bản án.
- Chương trình BPF chỉ quan tâm đến việc đọc ZZ0002ZZ đầu tiên của ZZ0003ZZ. Nếu
  message có payload lớn thì setup và gọi chương trình BPF
  lặp đi lặp lại cho tất cả các byte, mặc dù kết quả đã được biết trước, sẽ
  tạo ra chi phí không cần thiết.

Trả về 0

bpf_msg_cork_bytes()
^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: c

    long bpf_msg_cork_bytes(struct sk_msg_buff *msg, u32 bytes)

Đối với các chính sách ổ cắm, ngăn chặn việc thực thi chương trình BPF phán quyết cho
nhắn tin ZZ0000ZZ cho đến khi số lượng ZZ0001ZZ được tích lũy.

Điều này có thể được sử dụng khi người ta cần một số byte cụ thể trước khi đưa ra phán quyết
được chỉ định, ngay cả khi dữ liệu trải rộng trên nhiều ZZ0000ZZ hoặc ZZ0001ZZ
cuộc gọi.

Trả về 0

bpf_msg_pull_data()
^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: c

    long bpf_msg_pull_data(struct sk_msg_buff *msg, u32 start, u32 end, u64 flags)

Đối với chính sách ổ cắm, hãy lấy dữ liệu phi tuyến tính từ không gian người dùng cho ZZ0000ZZ và đặt
con trỏ ZZ0001ZZ và ZZ0002ZZ tới byte ZZ0003ZZ và ZZ0004ZZ
bù vào ZZ0005ZZ tương ứng.

Nếu một chương trình thuộc loại ZZ0000ZZ được chạy trên ZZ0001ZZ thì nó chỉ có thể
phân tích dữ liệu mà các con trỏ (ZZ0002ZZ, ZZ0003ZZ) đã sử dụng.
Đối với móc ZZ0004ZZ, đây có thể là phần tử danh sách phân tán đầu tiên. Nhưng đối với
các cuộc gọi dựa trên MSG_SPLICE_PAGES (ví dụ: ZZ0005ZZ), đây sẽ là
phạm vi (ZZ0006ZZ, ZZ0007ZZ) vì dữ liệu được chia sẻ với không gian người dùng và theo mặc định
mục tiêu là tránh cho phép không gian người dùng sửa đổi dữ liệu trong khi (hoặc sau)
Phán quyết của BPF đang được quyết định. Trình trợ giúp này có thể được sử dụng để lấy dữ liệu và
đặt con trỏ bắt đầu và kết thúc thành các giá trị nhất định. Dữ liệu sẽ được sao chép nếu
cần thiết (nghĩa là nếu dữ liệu không tuyến tính và nếu con trỏ bắt đầu và kết thúc không
trỏ đến cùng một đoạn).

Cuộc gọi tới trình trợ giúp này có thể làm thay đổi bộ đệm gói cơ bản.
Do đó, tại thời điểm tải, tất cả các kiểm tra về con trỏ được trình xác minh thực hiện trước đó
bị vô hiệu và phải được thực hiện lại nếu trình trợ giúp được sử dụng trong
kết hợp với truy cập gói trực tiếp.

Tất cả các giá trị cho ZZ0000ZZ được dành riêng cho việc sử dụng trong tương lai và phải được để lại ở
không.

Trả về 0 nếu thành công hoặc trả về lỗi âm trong trường hợp thất bại.

bpf_map_lookup_elem()
^^^^^^^^^^^^^^^^^^^^^

.. code-block:: c

	void *bpf_map_lookup_elem(struct bpf_map *map, const void *key)

Tra cứu mục ổ cắm trong bản đồ sockmap hoặc sockhash.

Trả về mục nhập ổ cắm được liên kết với ZZ0000ZZ hoặc NULL nếu không tìm thấy mục nhập nào.

bpf_map_update_elem()
^^^^^^^^^^^^^^^^^^^^^
.. code-block:: c

	long bpf_map_update_elem(struct bpf_map *map, const void *key, const void *value, u64 flags)

Thêm hoặc cập nhật mục ổ cắm trong sockmap hoặc sockhash.

Đối số flags có thể là một trong những đối số sau:

- BPF_ANY: Tạo phần tử mới hoặc cập nhật phần tử hiện có.
- BPF_NOEXIST: Chỉ tạo một phần tử mới nếu nó chưa tồn tại.
- BPF_EXIST: Cập nhật phần tử hiện có.

Trả về 0 nếu thành công hoặc trả về lỗi âm trong trường hợp thất bại.

bpf_map_delete_elem()
^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: c

    long bpf_map_delete_elem(struct bpf_map *map, const void *key)

Xóa một mục nhập ổ cắm khỏi sockmap hoặc sockhash.

Trả về 0 nếu thành công hoặc trả về lỗi âm trong trường hợp thất bại.

Không gian người dùng
----------
bpf_map_update_elem()
^^^^^^^^^^^^^^^^^^^^^
.. code-block:: c

	int bpf_map_update_elem(int fd, const void *key, const void *value, __u64 flags)

Các mục Sockmap có thể được thêm hoặc cập nhật bằng ZZ0000ZZ
chức năng. Tham số ZZ0001ZZ là giá trị chỉ mục của mảng sockmap. Và
Tham số ZZ0002ZZ là giá trị FD của socket đó.

Dưới mui xe, chức năng cập nhật sockmap sử dụng giá trị ổ cắm FD để
lấy ổ cắm liên quan và psock đính kèm của nó.

Đối số flags có thể là một trong những đối số sau:

- BPF_ANY: Tạo phần tử mới hoặc cập nhật phần tử hiện có.
- BPF_NOEXIST: Chỉ tạo một phần tử mới nếu nó chưa tồn tại.
- BPF_EXIST: Cập nhật phần tử hiện có.

bpf_map_lookup_elem()
^^^^^^^^^^^^^^^^^^^^^
.. code-block:: c

    int bpf_map_lookup_elem(int fd, const void *key, void *value)

Các mục Sockmap có thể được truy xuất bằng chức năng ZZ0000ZZ.

.. note::
	The entry returned is a socket cookie rather than a socket itself.

bpf_map_delete_elem()
^^^^^^^^^^^^^^^^^^^^^
.. code-block:: c

    int bpf_map_delete_elem(int fd, const void *key)

Các mục Sockmap có thể được xóa bằng ZZ0000ZZ
chức năng.

Trả về 0 nếu thành công hoặc trả về lỗi âm trong trường hợp thất bại.

Ví dụ
========

Hạt nhân BPF
----------
Bạn có thể tìm thấy một số ví dụ về việc sử dụng API sockmap trong:

-ZZ0000ZZ
-ZZ0001ZZ
-ZZ0002ZZ
-ZZ0003ZZ
-ZZ0004ZZ

Đoạn mã sau đây cho biết cách khai báo sockmap.

.. code-block:: c

	struct {
		__uint(type, BPF_MAP_TYPE_SOCKMAP);
		__uint(max_entries, 1);
		__type(key, __u32);
		__type(value, __u64);
	} sock_map_rx SEC(".maps");

Đoạn mã sau đây hiển thị một chương trình phân tích cú pháp mẫu.

.. code-block:: c

	SEC("sk_skb/stream_parser")
	int bpf_prog_parser(struct __sk_buff *skb)
	{
		return skb->len;
	}

Đoạn mã sau đây hiển thị một chương trình phán đoán đơn giản tương tác với một
sockmap để chuyển hướng lưu lượng truy cập đến một ổ cắm khác dựa trên cổng cục bộ.

.. code-block:: c

	SEC("sk_skb/stream_verdict")
	int bpf_prog_verdict(struct __sk_buff *skb)
	{
		__u32 lport = skb->local_port;
		__u32 idx = 0;

		if (lport == 10000)
			return bpf_sk_redirect_map(skb, &sock_map_rx, idx, 0);

		return SK_PASS;
	}

Đoạn mã sau đây cho biết cách khai báo bản đồ sockhash.

.. code-block:: c

	struct socket_key {
		__u32 src_ip;
		__u32 dst_ip;
		__u32 src_port;
		__u32 dst_port;
	};

	struct {
		__uint(type, BPF_MAP_TYPE_SOCKHASH);
		__uint(max_entries, 1);
		__type(key, struct socket_key);
		__type(value, __u64);
	} sock_hash_rx SEC(".maps");

Đoạn mã sau đây hiển thị một chương trình phán đoán đơn giản tương tác với một
sockhash để chuyển hướng lưu lượng truy cập đến một ổ cắm khác dựa trên hàm băm của một số
thông số skb

.. code-block:: c

	static inline
	void extract_socket_key(struct __sk_buff *skb, struct socket_key *key)
	{
		key->src_ip = skb->remote_ip4;
		key->dst_ip = skb->local_ip4;
		key->src_port = skb->remote_port >> 16;
		key->dst_port = (bpf_htonl(skb->local_port)) >> 16;
	}

	SEC("sk_skb/stream_verdict")
	int bpf_prog_verdict(struct __sk_buff *skb)
	{
		struct socket_key key;

		extract_socket_key(skb, &key);

		return bpf_sk_redirect_hash(skb, &sock_hash_rx, &key, 0);
	}

Không gian người dùng
----------
Bạn có thể tìm thấy một số ví dụ về việc sử dụng API sockmap trong:

-ZZ0000ZZ
-ZZ0001ZZ
-ZZ0002ZZ

Mẫu mã sau đây cho biết cách tạo sockmap, đính kèm trình phân tích cú pháp và
chương trình phán quyết, cũng như thêm một mục nhập ổ cắm.

.. code-block:: c

	int create_sample_sockmap(int sock, int parse_prog_fd, int verdict_prog_fd)
	{
		int index = 0;
		int map, err;

		map = bpf_map_create(BPF_MAP_TYPE_SOCKMAP, NULL, sizeof(int), sizeof(int), 1, NULL);
		if (map < 0) {
			fprintf(stderr, "Failed to create sockmap: %s\n", strerror(errno));
			return -1;
		}

		err = bpf_prog_attach(parse_prog_fd, map, BPF_SK_SKB_STREAM_PARSER, 0);
		if (err){
			fprintf(stderr, "Failed to attach_parser_prog_to_map: %s\n", strerror(errno));
			goto out;
		}

		err = bpf_prog_attach(verdict_prog_fd, map, BPF_SK_SKB_STREAM_VERDICT, 0);
		if (err){
			fprintf(stderr, "Failed to attach_verdict_prog_to_map: %s\n", strerror(errno));
			goto out;
		}

		err = bpf_map_update_elem(map, &index, &sock, BPF_NOEXIST);
		if (err) {
			fprintf(stderr, "Failed to update sockmap: %s\n", strerror(errno));
			goto out;
		}

	out:
		close(map);
		return err;
	}

Tài liệu tham khảo
===========

-ZZ0000ZZ
-ZZ0001ZZ
-ZZ0002ZZ
-ZZ0003ZZ
-ZZ0004ZZ

.. _`tools/testing/selftests/bpf/progs/test_sockmap_kern.h`: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/tools/testing/selftests/bpf/progs/test_sockmap_kern.h
.. _`tools/testing/selftests/bpf/progs/sockmap_parse_prog.c`: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/tools/testing/selftests/bpf/progs/sockmap_parse_prog.c
.. _`tools/testing/selftests/bpf/progs/sockmap_verdict_prog.c`: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/tools/testing/selftests/bpf/progs/sockmap_verdict_prog.c
.. _`tools/testing/selftests/bpf/prog_tests/sockmap_basic.c`: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/tools/testing/selftests/bpf/prog_tests/sockmap_basic.c
.. _`tools/testing/selftests/bpf/test_sockmap.c`: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/tools/testing/selftests/bpf/test_sockmap.c
.. _`tools/testing/selftests/bpf/test_maps.c`: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/tools/testing/selftests/bpf/test_maps.c
.. _`tools/testing/selftests/bpf/progs/test_sockmap_listen.c`: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/tools/testing/selftests/bpf/progs/test_sockmap_listen.c
.. _`tools/testing/selftests/bpf/progs/test_sockmap_update.c`: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/tools/testing/selftests/bpf/progs/test_sockmap_update.c