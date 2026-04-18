.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/map_cgroup_storage.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright (C) 2020 Google LLC.

==============================
BPF_MAP_TYPE_CGROUP_STORAGE
==============================

Loại bản đồ ZZ0000ZZ đại diện cho một bản đồ có kích thước cố định cục bộ
lưu trữ. Nó chỉ khả dụng với ZZ0001ZZ và các chương trình
gắn vào cgroups; các chương trình được cung cấp bởi cùng một Kconfig. các
bộ nhớ được xác định bởi cgroup mà chương trình được đính kèm.

Bản đồ cung cấp bộ nhớ cục bộ tại nhóm mà chương trình BPF được đính kèm
đến. Nó cung cấp quyền truy cập nhanh hơn và đơn giản hơn so với hàm băm mục đích chung
bảng, thực hiện tra cứu bảng băm và yêu cầu người dùng theo dõi trực tiếp
cgroup của riêng họ.

Tài liệu này mô tả cách sử dụng và ngữ nghĩa của
Loại bản đồ ZZ0000ZZ. Một số hành vi của nó đã được thay đổi trong
Linux 5.9 và tài liệu này sẽ mô tả sự khác biệt.

Cách sử dụng
============

Bản đồ sử dụng khóa loại ZZ0000ZZ hoặc
ZZ0001ZZ, được khai báo trong ZZ0002ZZ::

cấu trúc bpf_cgroup_storage_key {
            __u64 cgroup_inode_id;
            __u32 đính kèm_type;
    };

ZZ0000ZZ là id inode của thư mục cgroup.
ZZ0001ZZ là loại đính kèm của chương trình.

Linux 5.9 đã thêm hỗ trợ cho loại ZZ0000ZZ làm loại khóa.
Khi loại khóa này được sử dụng thì tất cả các loại đính kèm của nhóm cụ thể và
bản đồ sẽ chia sẻ cùng một bộ nhớ. Mặt khác, nếu loại là
ZZ0001ZZ, sau đó là các chương trình thuộc các loại đính kèm khác nhau
bị cô lập và xem các kho lưu trữ khác nhau.

Để truy cập bộ nhớ trong một chương trình, hãy sử dụng ZZ0000ZZ::

void *bpf_get_local_storage(void *map, cờ u64)

ZZ0000ZZ được dành riêng để sử dụng trong tương lai và phải bằng 0.

Không có sự đồng bộ ngầm. Kho lưu trữ của ZZ0000ZZ
có thể được truy cập bởi nhiều chương trình trên các CPU khác nhau và người dùng nên
tự mình đảm nhiệm việc đồng bộ hóa. Cơ sở hạ tầng bpf cung cấp
ZZ0001ZZ để đồng bộ hóa việc lưu trữ. Xem
ZZ0002ZZ.

Ví dụ
========

Cách sử dụng với loại khóa là ZZ0000ZZ::

#include <bpf/bpf.h>

cấu trúc {
            __uint(loại, BPF_MAP_TYPE_CGROUP_STORAGE);
            __type(key, struct bpf_cgroup_storage_key);
            __type(giá trị, __u32);
    } cgroup_storage SEC(".maps");

chương trình int(struct __sk_buff *skb)
    {
            __u32 *ptr = bpf_get_local_storage(&cgroup_storage, 0);
            __sync_fetch_and_add(ptr, 1);

trả về 0;
    }

Bản đồ truy cập không gian người dùng được khai báo ở trên::

#include <linux/bpf.h>
    #include <linux/libbpf.h>

__u32 map_lookup(struct bpf_map *map, __u64 cgrp, loại enum bpf_attach_type)
    {
            cấu trúc bpf_cgroup_storage_key = {
                    .cgroup_inode_id = cgrp,
                    .đính kèm_type = loại,
            };
            giá trị __u32;
            bpf_map_lookup_elem(bpf_map__fd(map), &key, &value);
            // bỏ qua việc kiểm tra lỗi
            giá trị trả về;
    }

Ngoài ra, chỉ sử dụng ZZ0000ZZ làm loại khóa ::

#include <bpf/bpf.h>

cấu trúc {
            __uint(loại, BPF_MAP_TYPE_CGROUP_STORAGE);
            __type(khóa, __u64);
            __type(giá trị, __u32);
    } cgroup_storage SEC(".maps");

chương trình int(struct __sk_buff *skb)
    {
            __u32 *ptr = bpf_get_local_storage(&cgroup_storage, 0);
            __sync_fetch_and_add(ptr, 1);

trả về 0;
    }

Và không gian người dùng::

#include <linux/bpf.h>
    #include <linux/libbpf.h>

__u32 map_lookup(struct bpf_map *map, __u64 cgrp, loại enum bpf_attach_type)
    {
            giá trị __u32;
            bpf_map_lookup_elem(bpf_map__fd(map), &cgrp, &value);
            // bỏ qua việc kiểm tra lỗi
            giá trị trả về;
    }

Ngữ nghĩa
=========

ZZ0000ZZ là một biến thể của loại bản đồ này. Cái này
mỗi biến thể CPU sẽ có các vùng bộ nhớ khác nhau cho mỗi CPU cho mỗi biến thể
lưu trữ. Vùng không thuộc CPU sẽ có cùng vùng bộ nhớ cho mỗi bộ lưu trữ.

Trước Linux 5.9, thời gian tồn tại của bộ lưu trữ chính xác là trên mỗi tệp đính kèm và
đối với một bản đồ ZZ0000ZZ, có thể tải tối đa một chương trình
đó sử dụng bản đồ. Một chương trình có thể được gắn vào nhiều nhóm hoặc có
nhiều loại tệp đính kèm và mỗi tệp đính kèm sẽ tạo ra một bộ lưu trữ bằng 0 mới. các
lưu trữ được giải phóng khi tách ra.

Có sự liên kết một-một giữa bản đồ của từng loại (per-CPU và
non-per-CPU) và chương trình BPF trong thời gian xác minh tải. Kết quả là,
mỗi bản đồ chỉ có thể được sử dụng bởi một chương trình BPF và mỗi chương trình BPF chỉ có thể sử dụng
một bản đồ lưu trữ của mỗi loại. Vì bản đồ chỉ có thể được sử dụng bởi một BPF
chương trình, việc chia sẻ dung lượng lưu trữ của nhóm này với các chương trình BPF khác đã được
không thể được.

Kể từ Linux 5.9, nhiều chương trình có thể chia sẻ bộ nhớ. Khi một chương trình được
được gắn vào một nhóm, kernel sẽ chỉ tạo một bộ lưu trữ mới nếu bản đồ
chưa chứa mục nhập cho cặp loại cgroup và đính kèm, nếu không
bộ lưu trữ cũ được sử dụng lại cho tệp đính kèm mới. Nếu bản đồ được đính kèm
được chia sẻ thì loại đính kèm sẽ bị bỏ qua trong quá trình so sánh. Bộ nhớ được giải phóng
chỉ khi bản đồ hoặc nhóm được đính kèm được giải phóng. tách ra
sẽ không trực tiếp giải phóng bộ nhớ, nhưng nó có thể gây ra sự tham chiếu đến bản đồ
để đạt đến mức 0 và gián tiếp giải phóng tất cả dung lượng lưu trữ trên bản đồ.

Bản đồ không được liên kết với bất kỳ chương trình BPF nào, do đó có thể chia sẻ.
Tuy nhiên, chương trình BPF vẫn chỉ có thể liên kết với một bản đồ của mỗi loại
(theo CPU và không theo CPU). Một chương trình BPF không thể sử dụng nhiều hơn một
ZZ0000ZZ hoặc nhiều hơn một
ZZ0001ZZ.

Trong tất cả các phiên bản, không gian người dùng có thể sử dụng các tham số đính kèm của cgroup và
đính kèm cặp loại trong ZZ0000ZZ làm chìa khóa cho bản đồ BPF
API để đọc hoặc cập nhật bộ nhớ cho một tệp đính kèm nhất định. Dành cho Linux 5.9
đính kèm loại kho lưu trữ chia sẻ, chỉ có giá trị đầu tiên trong struct, cgroup inode
id, được sử dụng trong quá trình so sánh, vì vậy không gian người dùng có thể chỉ định ZZ0001ZZ
trực tiếp.

Việc lưu trữ bị ràng buộc tại thời điểm đính kèm. Ngay cả khi chương trình được gắn liền với cha mẹ
và kích hoạt ở con, bộ nhớ vẫn thuộc về cha mẹ.

Không gian người dùng không thể tạo mục nhập mới trên bản đồ hoặc xóa mục nhập hiện có.
Chạy thử chương trình luôn sử dụng bộ nhớ tạm thời.