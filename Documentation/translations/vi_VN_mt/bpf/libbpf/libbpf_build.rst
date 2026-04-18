.. SPDX-License-Identifier: (LGPL-2.1 OR BSD-2-Clause)

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/bpf/libbpf/libbpf_build.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Xây dựng libbpf
===============

libelf và zlib là các phụ thuộc nội bộ của libbpf và do đó bắt buộc phải liên kết
chống lại và phải được cài đặt trên hệ thống để các ứng dụng hoạt động.
pkg-config được sử dụng theo mặc định để tìm lời nói dối và chương trình có tên
có thể được ghi đè bằng PKG_CONFIG.

Nếu không muốn sử dụng pkg-config khi xây dựng, nó có thể bị tắt bằng cách
cài đặt NO_PKG_CONFIG=1 khi gọi make.

Để xây dựng cả libbpf.a tĩnh và libbpf.so được chia sẻ:

.. code-block:: bash

    $ cd src
    $ make

Để chỉ xây dựng thư viện libbpf.a tĩnh trong thư mục build/ và cài đặt chúng
cùng với các tiêu đề libbpf trong thư mục dàn dựng root/:

.. code-block:: bash

    $ cd src
    $ mkdir build root
    $ BUILD_STATIC_ONLY=y OBJDIR=build DESTDIR=root make install

Để xây dựng cả libbpf.a tĩnh và libbpf.so được chia sẻ chống lại sự phỉ báng tùy chỉnh
phụ thuộc được cài đặt trong /build/root/ và cài đặt chúng cùng với libbpf
các tiêu đề trong thư mục bản dựng /build/root/:

.. code-block:: bash

    $ cd src
    $ PKG_CONFIG_PATH=/build/root/lib64/pkgconfig DESTDIR=/build/root make