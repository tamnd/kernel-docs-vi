.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/map_hash.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. Copyright (C) 2022 Red Hat, Inc.
.. Copyright (C) 2022-2023 Isovalent, Inc.

====================================================
BPF_MAP_TYPE_HASH, với các biến thể PERCPU và LRU
===============================================

.. note::
   - ``BPF_MAP_TYPE_HASH`` was introduced in kernel version 3.19
   - ``BPF_MAP_TYPE_PERCPU_HASH`` was introduced in version 4.6
   - Both ``BPF_MAP_TYPE_LRU_HASH`` and ``BPF_MAP_TYPE_LRU_PERCPU_HASH``
     were introduced in version 4.10

ZZ0000ZZ và ZZ0001ZZ cung cấp chung
mục đích lưu trữ bản đồ băm. Cả khóa và giá trị đều có thể là cấu trúc,
cho phép các khóa và giá trị tổng hợp.

Hạt nhân chịu trách nhiệm phân bổ và giải phóng các cặp khóa/giá trị,
đến giới hạn max_entries mà bạn chỉ định. Bản đồ băm sử dụng phân bổ trước
của các phần tử bảng băm theo mặc định. Cờ ZZ0000ZZ có thể
được sử dụng để vô hiệu hóa việc phân bổ trước khi nó quá tốn bộ nhớ.

ZZ0000ZZ cung cấp một khe giá trị riêng cho mỗi
CPU. Các giá trị trên mỗi CPU được lưu trữ nội bộ trong một mảng.

ZZ0000ZZ và ZZ0001ZZ
các biến thể thêm ngữ nghĩa LRU vào bảng băm tương ứng của chúng. Hàm băm LRU
sẽ tự động loại bỏ các mục ít được sử dụng gần đây nhất khi hàm băm
bàn đạt công suất. Hàm băm LRU duy trì danh sách LRU nội bộ
được sử dụng để chọn các phần tử để trục xuất. Danh sách LRU nội bộ này là
được chia sẻ giữa các CPU nhưng có thể yêu cầu một danh sách CPU LRU với
cờ ZZ0002ZZ khi gọi ZZ0003ZZ.  các
bảng sau phác thảo các thuộc tính của bản đồ LRU tùy thuộc vào a
loại bản đồ và các cờ được sử dụng để tạo bản đồ.

========================================================================================
Cờ ZZ0000ZZ ZZ0001ZZ
========================================================================================
ZZ0002ZZ Per-CPU LRU, bản đồ toàn cầu Per-CPU LRU, bản đồ mỗi CPU
ZZ0003ZZ Global LRU, bản đồ toàn cầu Global LRU, bản đồ mỗi CPU
========================================================================================

Cách sử dụng
=====

Hạt nhân BPF
----------

bpf_map_update_elem()
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: c

   long bpf_map_update_elem(struct bpf_map *map, const void *key, const void *value, u64 flags)

Các mục băm có thể được thêm hoặc cập nhật bằng ZZ0000ZZ
người giúp đỡ. Trình trợ giúp này thay thế các phần tử hiện có một cách nguyên tử. ZZ0001ZZ
tham số có thể được sử dụng để kiểm soát hành vi cập nhật:

- ZZ0000ZZ sẽ tạo một phần tử mới hoặc cập nhật phần tử hiện có
- ZZ0001ZZ sẽ chỉ tạo một phần tử mới nếu chưa có phần tử đó
  tồn tại
- ZZ0002ZZ sẽ cập nhật phần tử hiện có

ZZ0000ZZ trả về 0 nếu thành công hoặc có lỗi âm trong
trường hợp thất bại.

bpf_map_lookup_elem()
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: c

   void *bpf_map_lookup_elem(struct bpf_map *map, const void *key)

Các mục băm có thể được truy xuất bằng ZZ0000ZZ
người giúp đỡ. Trình trợ giúp này trả về một con trỏ tới giá trị được liên kết với
ZZ0001ZZ hoặc ZZ0002ZZ nếu không tìm thấy mục nào.

bpf_map_delete_elem()
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: c

   long bpf_map_delete_elem(struct bpf_map *map, const void *key)

Các mục băm có thể bị xóa bằng ZZ0000ZZ
người giúp đỡ. Người trợ giúp này sẽ trả về 0 nếu thành công hoặc có lỗi tiêu cực trong trường hợp
của sự thất bại.

Mỗi hàm băm CPU
--------------

Dành cho ZZ0000ZZ và ZZ0001ZZ
người trợ giúp ZZ0002ZZ và ZZ0003ZZ
tự động truy cập vào khe băm cho CPU hiện tại.

bpf_map_lookup_percpu_elem()
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: c

   void *bpf_map_lookup_percpu_elem(struct bpf_map *map, const void *key, u32 cpu)

Trình trợ giúp ZZ0000ZZ có thể được sử dụng để tra cứu
giá trị trong vùng băm cho một CPU cụ thể. Trả về giá trị liên quan đến
ZZ0001ZZ trên ZZ0002ZZ hoặc ZZ0003ZZ nếu không tìm thấy mục nào hoặc ZZ0004ZZ là
không hợp lệ.

Đồng thời
-----------

Các giá trị được lưu trữ trong ZZ0000ZZ có thể được truy cập đồng thời bởi
chương trình chạy trên các CPU khác nhau.  Kể từ phiên bản Kernel 5.1, BPF
cơ sở hạ tầng cung cấp ZZ0001ZZ để đồng bộ hóa quyền truy cập.
Xem ZZ0002ZZ.

Không gian người dùng
---------

bpf_map_get_next_key()
~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: c

   int bpf_map_get_next_key(int fd, const void *cur_key, void *next_key)

Trong không gian người dùng, có thể lặp qua các khóa của hàm băm bằng cách sử dụng
chức năng ZZ0000ZZ của libbpf. Khóa đầu tiên có thể được lấy bằng
gọi ZZ0001ZZ với ZZ0002ZZ được đặt thành
ZZ0003ZZ. Các cuộc gọi tiếp theo sẽ lấy khóa tiếp theo theo sau
khóa hiện tại. ZZ0004ZZ trả về 0 nếu thành công, -ENOENT nếu
cur_key là khóa cuối cùng trong hàm băm hoặc có lỗi âm trong trường hợp
thất bại.

Lưu ý rằng nếu ZZ0000ZZ bị xóa thì ZZ0001ZZ
thay vào đó sẽ trả về khóa ZZ0003ZZ trong bảng băm
không mong muốn. Nên sử dụng tra cứu theo đợt nếu có
được xóa khóa xen kẽ với ZZ0002ZZ.

Ví dụ
========

Vui lòng xem thư mục ZZ0000ZZ để biết chức năng
ví dụ.  Đoạn mã bên dưới minh họa cách sử dụng API.

Ví dụ này cho thấy cách khai báo Hash LRU bằng khóa cấu trúc và
giá trị cấu trúc

.. code-block:: c

    #include <linux/bpf.h>
    #include <bpf/bpf_helpers.h>

    struct key {
        __u32 srcip;
    };

    struct value {
        __u64 packets;
        __u64 bytes;
    };

    struct {
            __uint(type, BPF_MAP_TYPE_LRU_HASH);
            __uint(max_entries, 32);
            __type(key, struct key);
            __type(value, struct value);
    } packet_stats SEC(".maps");

Ví dụ này cho thấy cách tạo hoặc cập nhật giá trị băm bằng cách sử dụng nguyên tử
hướng dẫn:

.. code-block:: c

    static void update_stats(__u32 srcip, int bytes)
    {
            struct key key = {
                    .srcip = srcip,
            };
            struct value *value = bpf_map_lookup_elem(&packet_stats, &key);

            if (value) {
                    __sync_fetch_and_add(&value->packets, 1);
                    __sync_fetch_and_add(&value->bytes, bytes);
            } else {
                    struct value newval = { 1, bytes };

                    bpf_map_update_elem(&packet_stats, &key, &newval, BPF_NOEXIST);
            }
    }

Không gian người dùng đi qua các phần tử bản đồ từ bản đồ được khai báo ở trên:

.. code-block:: c

    #include <bpf/libbpf.h>
    #include <bpf/bpf.h>

    static void walk_hash_elements(int map_fd)
    {
            struct key *cur_key = NULL;
            struct key next_key;
            struct value value;
            int err;

            for (;;) {
                    err = bpf_map_get_next_key(map_fd, cur_key, &next_key);
                    if (err)
                            break;

                    bpf_map_lookup_elem(map_fd, &next_key, &value);

                    // Use key and value here

                    cur_key = &next_key;
            }
    }

Nội bộ
=========

Phần này của tài liệu nhắm đến các nhà phát triển Linux và mô tả
các khía cạnh của việc triển khai bản đồ không được coi là ABI ổn định. các
các chi tiết sau đây có thể thay đổi trong các phiên bản kernel trong tương lai.

ZZ0000ZZ và các biến thể
--------------------------------------

Việc cập nhật các phần tử trong bản đồ LRU có thể kích hoạt hành vi trục xuất khi dung lượng
của bản đồ đã đạt được. Có nhiều bước khác nhau mà thuật toán cập nhật
những nỗ lực nhằm thực thi thuộc tính LRU có tác động ngày càng tăng lên
các CPU khác có liên quan đến các lần thử hoạt động sau:

- Cố gắng sử dụng trạng thái cục bộ CPU cho các hoạt động hàng loạt
- Cố gắng tìm nạp các nút miễn phí ZZ0000ZZ từ danh sách toàn cầu
- Cố gắng kéo bất kỳ nút nào khỏi danh sách chung và xóa nó khỏi hashmap
- Cố gắng kéo bất kỳ nút nào khỏi danh sách của bất kỳ CPU nào và xóa nó khỏi hashmap

Số nút được mượn từ danh sách toàn cầu trong một đợt, ZZ0000ZZ,
phụ thuộc vào kích thước của bản đồ. Kích thước lô lớn hơn làm giảm sự tranh chấp khóa, nhưng
cũng có thể làm cạn kiệt cấu trúc toàn cầu. Giá trị được tính tại map init tới
tránh cạn kiệt, bằng cách giới hạn tổng lượng dự trữ của tất cả các CPU ở một nửa bản đồ
kích thước. Với tối thiểu một yếu tố và ngân sách tối đa là 128 tại một thời điểm.

Thuật toán này được mô tả trực quan trong sơ đồ sau. Xem
mô tả trong cam kết 3a08c2fd7634 ("bpf: Danh sách LRU") để có giải thích đầy đủ về
các thao tác tương ứng:

.. kernel-figure::  map_lru_hash_update.dot
   :alt:    Diagram outlining the LRU eviction steps taken during map update.

   LRU hash eviction during map update for ``BPF_MAP_TYPE_LRU_HASH`` and
   variants. See the dot file source for kernel function name code references.

Cập nhật bản đồ bắt đầu từ hình bầu dục ở trên cùng bên phải "bắt đầu ZZ0000ZZ"
và tiến dần qua biểu đồ về phía dưới nơi kết quả có thể là
cập nhật thành công hoặc thất bại với nhiều mã lỗi khác nhau. Chìa khóa trong
phía trên bên phải cung cấp các chỉ báo về khóa nào có thể liên quan đến các hoạt động cụ thể
hoạt động. Điều này nhằm mục đích gợi ý trực quan để lý luận về cách bản đồ
tranh chấp có thể ảnh hưởng đến hoạt động cập nhật, mặc dù loại bản đồ và cờ có thể
tác động đến sự tranh chấp thực tế trên các khóa đó, dựa trên logic được mô tả trong
bảng trên. Ví dụ: nếu bản đồ được tạo bằng loại
ZZ0001ZZ và cờ ZZ0002ZZ rồi tất cả bản đồ
thuộc tính sẽ là trên mỗi CPU.