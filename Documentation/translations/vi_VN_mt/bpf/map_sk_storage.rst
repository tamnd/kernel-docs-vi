.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/map_sk_storage.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright (C) 2022 Red Hat, Inc.

==========================
BPF_MAP_TYPE_SK_STORAGE
==========================

.. note::
   - ``BPF_MAP_TYPE_SK_STORAGE`` was introduced in kernel version 5.2

ZZ0000ZZ được sử dụng để cung cấp bộ lưu trữ cục bộ trên ổ cắm cho BPF
các chương trình. Bản đồ loại ZZ0001ZZ khai báo loại lưu trữ
được cung cấp và đóng vai trò là tay cầm để truy cập socket-local
lưu trữ. Các giá trị cho bản đồ loại ZZ0002ZZ được lưu trữ
cục bộ với mỗi ổ cắm thay vì với bản đồ. Hạt nhân chịu trách nhiệm
phân bổ bộ nhớ cho ổ cắm khi được yêu cầu và giải phóng bộ nhớ khi
bản đồ hoặc ổ cắm sẽ bị xóa.

.. note::
  - The key type must be ``int`` and ``max_entries`` must be set to ``0``.
  - The ``BPF_F_NO_PREALLOC`` flag must be used when creating a map for
    socket-local storage.

Cách sử dụng
============

Hạt nhân BPF
------------

bpf_sk_storage_get()
~~~~~~~~~~~~~~~~~~~~

.. code-block:: c

   void *bpf_sk_storage_get(struct bpf_map *map, void *sk, void *value, u64 flags)

Bộ nhớ cục bộ của ổ cắm cho ZZ0000ZZ có thể được truy xuất từ ổ cắm ZZ0001ZZ bằng cách sử dụng
Người trợ giúp ZZ0002ZZ. Nếu ZZ0003ZZ
cờ được sử dụng thì ZZ0004ZZ sẽ tạo bộ lưu trữ cho ZZ0005ZZ
nếu nó chưa tồn tại. ZZ0006ZZ có thể được sử dụng cùng với
ZZ0007ZZ để khởi tạo giá trị lưu trữ, nếu không
nó sẽ được khởi tạo bằng 0. Trả về con trỏ tới bộ lưu trữ nếu thành công hoặc
ZZ0008ZZ trong trường hợp thất bại.

.. note::
   - ``sk`` is a kernel ``struct sock`` pointer for LSM or tracing programs.
   - ``sk`` is a ``struct bpf_sock`` pointer for other program types.

bpf_sk_storage_delete()
~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: c

   long bpf_sk_storage_delete(struct bpf_map *map, void *sk)

Có thể xóa bộ nhớ cục bộ của ổ cắm cho ZZ0000ZZ khỏi ổ cắm ZZ0001ZZ bằng cách sử dụng
Người trợ giúp ZZ0002ZZ. Trả về ZZ0003ZZ khi thành công hoặc âm
lỗi trong trường hợp thất bại.

Không gian người dùng
---------------------

bpf_map_update_elem()
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: c

   int bpf_map_update_elem(int map_fd, const void *key, const void *value, __u64 flags)

Bộ lưu trữ cục bộ ổ cắm cho bản đồ ZZ0000ZZ có thể được thêm hoặc cập nhật cục bộ vào
socket bằng hàm libbpf ZZ0001ZZ. Ổ cắm là
được xác định bởi ZZ0007ZZ ZZ0002ZZ được lưu trữ trong con trỏ ZZ0003ZZ. Con trỏ
ZZ0004ZZ có dữ liệu cần được thêm hoặc cập nhật vào ổ cắm ZZ0005ZZ. Loại
và kích thước của ZZ0006ZZ phải giống với loại giá trị của bản đồ
định nghĩa.

Tham số ZZ0000ZZ có thể được sử dụng để kiểm soát hành vi cập nhật:

- ZZ0000ZZ sẽ tạo bộ nhớ cho ZZ0008ZZ ZZ0001ZZ hoặc cập nhật bộ nhớ hiện có.
- ZZ0002ZZ sẽ chỉ tạo bộ nhớ cho ZZ0009ZZ ZZ0003ZZ nếu không
  đã tồn tại, nếu không cuộc gọi sẽ thất bại với ZZ0004ZZ.
- ZZ0005ZZ sẽ cập nhật bộ nhớ hiện có cho ZZ0010ZZ ZZ0006ZZ nếu đã có
  tồn tại, nếu không cuộc gọi sẽ thất bại với ZZ0007ZZ.

Trả về ZZ0000ZZ nếu thành công hoặc trả về lỗi âm trong trường hợp thất bại.

bpf_map_lookup_elem()
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: c

   int bpf_map_lookup_elem(int map_fd, const void *key, void *value)

Bộ lưu trữ cục bộ trên ổ cắm cho bản đồ ZZ0000ZZ có thể được truy xuất từ ổ cắm bằng cách sử dụng
hàm libbpf ZZ0001ZZ. Bộ nhớ được lấy từ
ổ cắm được xác định bởi ZZ0005ZZ ZZ0002ZZ được lưu trong con trỏ
ZZ0003ZZ. Trả về ZZ0004ZZ nếu thành công hoặc trả về lỗi âm trong trường hợp thất bại.

bpf_map_delete_elem()
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: c

   int bpf_map_delete_elem(int map_fd, const void *key)

Bộ nhớ cục bộ của ổ cắm cho bản đồ ZZ0000ZZ có thể bị xóa khỏi ổ cắm bằng cách sử dụng
Chức năng libbpf ZZ0001ZZ. Bộ nhớ sẽ bị xóa khỏi
ổ cắm được xác định bởi ZZ0005ZZ ZZ0002ZZ được lưu trữ trong con trỏ ZZ0003ZZ. Trả lại
ZZ0004ZZ thành công hoặc lỗi tiêu cực trong trường hợp thất bại.

Ví dụ
========

Hạt nhân BPF
------------

Đoạn mã này cho biết cách khai báo bộ nhớ cục bộ trong ổ cắm trong chương trình BPF:

.. code-block:: c

    struct {
            __uint(type, BPF_MAP_TYPE_SK_STORAGE);
            __uint(map_flags, BPF_F_NO_PREALLOC);
            __type(key, int);
            __type(value, struct my_storage);
    } socket_storage SEC(".maps");

Đoạn mã này cho biết cách truy xuất bộ nhớ cục bộ trong ổ cắm trong chương trình BPF:

.. code-block:: c

    SEC("sockops")
    int _sockops(struct bpf_sock_ops *ctx)
    {
            struct my_storage *storage;
            struct bpf_sock *sk;

            sk = ctx->sk;
            if (!sk)
                    return 1;

            storage = bpf_sk_storage_get(&socket_storage, sk, 0,
                                         BPF_LOCAL_STORAGE_GET_F_CREATE);
            if (!storage)
                    return 1;

            /* Use 'storage' here */

            return 1;
    }


Vui lòng xem thư mục ZZ0000ZZ để biết chức năng
ví dụ.

Tài liệu tham khảo
==================

ZZ0000ZZ