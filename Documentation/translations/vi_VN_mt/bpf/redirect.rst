.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/redirect.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. Copyright (C) 2022 Red Hat, Inc.

========
Chuyển hướng
========
XDP_REDIRECT
############
Bản đồ được hỗ trợ
--------------

XDP_REDIRECT hoạt động với các loại bản đồ sau:

-ZZ0000ZZ
-ZZ0001ZZ
-ZZ0002ZZ
-ZZ0003ZZ

Để biết thêm thông tin về các bản đồ này, vui lòng xem tài liệu bản đồ cụ thể.

Quá trình
-------

.. kernel-doc:: net/core/filter.c
   :doc: xdp redirect

.. note::
    Not all drivers support transmitting frames after a redirect, and for
    those that do, not all of them support non-linear frames. Non-linear xdp
    bufs/frames are bufs/frames that contain more than one fragment.

Gỡ lỗi gói tin bị rớt
----------------------
Có thể gỡ lỗi việc giảm gói im lặng cho XDP_REDIRECT bằng cách sử dụng:

- bpf_trace
- perf_record

bpf_trace
^^^^^^^^^
Lệnh bpftrace sau đây có thể được sử dụng để chụp và đếm tất cả các điểm theo dõi XDP:

.. code-block:: none

    sudo bpftrace -e 'tracepoint:xdp:* { @cnt[probe] = count(); }'
    Attaching 12 probes...
    ^C

    @cnt[tracepoint:xdp:mem_connect]: 18
    @cnt[tracepoint:xdp:mem_disconnect]: 18
    @cnt[tracepoint:xdp:xdp_exception]: 19605
    @cnt[tracepoint:xdp:xdp_devmap_xmit]: 1393604
    @cnt[tracepoint:xdp:xdp_redirect]: 22292200

.. note::
    The various xdp tracepoints can be found in ``source/include/trace/events/xdp.h``

Lệnh bpftrace sau đây có thể được sử dụng để trích xuất ZZ0000ZZ được trả về dưới dạng
một phần của tham số lỗi:

.. code-block:: none

    sudo bpftrace -e \
    'tracepoint:xdp:xdp_redirect*_err {@redir_errno[-args->err] = count();}
    tracepoint:xdp:xdp_devmap_xmit {@devmap_errno[-args->err] = count();}'

bản ghi hoàn hảo
^^^^^^^^^^^
Công cụ hoàn hảo cũng hỗ trợ ghi lại các dấu vết:

.. code-block:: none

    perf record -a -e xdp:xdp_redirect_err \
        -e xdp:xdp_redirect_map_err \
        -e xdp:xdp_exception \
        -e xdp:xdp_devmap_xmit

Tài liệu tham khảo
===========

-ZZ0000ZZ