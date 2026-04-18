.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/devlink-resource.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==================
Tài nguyên liên kết nhà phát triển
================

ZZ0000ZZ cung cấp khả năng cho người lái xe đăng ký tài nguyên,
có thể cho phép quản trị viên xem các hạn chế của thiết bị đối với một
tài nguyên, cũng như hiện tại tài nguyên đó có bao nhiêu
đang sử dụng. Ngoài ra, các tài nguyên này có thể tùy chọn có kích thước có thể định cấu hình.
Điều này có thể cho phép quản trị viên giới hạn số lượng tài nguyên
được sử dụng.

Ví dụ: trình điều khiển ZZ0000ZZ kích hoạt ZZ0001ZZ và
ZZ0002ZZ làm tài nguyên để giới hạn số lượng mục nhập IPv4 FIB và
quy tắc cho một thiết bị nhất định.

Id tài nguyên
============

Mỗi tài nguyên được đại diện bởi một id và chứa thông tin về nó
kích thước hiện tại và các tài nguyên phụ liên quan. Để truy cập một tài nguyên phụ, bạn
chỉ định đường dẫn của tài nguyên. Ví dụ ZZ0000ZZ là id cho
tài nguyên phụ ZZ0001ZZ trong tài nguyên ZZ0002ZZ.

Tài nguyên chung
=================

Tài nguyên chung được sử dụng để mô tả các tài nguyên có thể được chia sẻ bởi nhiều người.
Trình điều khiển thiết bị và mô tả của chúng phải được thêm vào bảng sau:

.. list-table:: List of Generic Resources
   :widths: 10 90

   * - Name
     - Description
   * - ``physical_ports``
     - A limited capacity of physical ports that the switch ASIC can support

cách sử dụng ví dụ
-------------

Các tài nguyên mà trình điều khiển tiếp xúc có thể được quan sát, ví dụ:

.. code:: shell

    $devlink resource show pci/0000:03:00.0
    pci/0000:03:00.0:
      name kvd size 245760 unit entry
        resources:
          name linear size 98304 occ 0 unit entry size_min 0 size_max 147456 size_gran 128
          name hash_double size 60416 unit entry size_min 32768 size_max 180224 size_gran 128
          name hash_single size 87040 unit entry size_min 65536 size_max 212992 size_gran 128

Kích thước của một số tài nguyên có thể được thay đổi. Ví dụ:

.. code:: shell

    $devlink resource set pci/0000:03:00.0 path /kvd/hash_single size 73088
    $devlink resource set pci/0000:03:00.0 path /kvd/hash_double size 74368

Những thay đổi không được áp dụng ngay lập tức, điều này có thể được xác thực bởi 'size_new'
thuộc tính, đại diện cho sự thay đổi về kích thước đang chờ xử lý. Ví dụ:

.. code:: shell

    $devlink resource show pci/0000:03:00.0
    pci/0000:03:00.0:
      name kvd size 245760 unit entry size_valid false
      resources:
        name linear size 98304 size_new 147456 occ 0 unit entry size_min 0 size_max 147456 size_gran 128
        name hash_double size 60416 unit entry size_min 32768 size_max 180224 size_gran 128
        name hash_single size 87040 unit entry size_min 65536 size_max 212992 size_gran 128

Lưu ý rằng những thay đổi về kích thước tài nguyên có thể yêu cầu thiết bị tải lại đúng cách
có hiệu lực.

Tài nguyên cấp cổng và kết xuất đầy đủ
==================================

Ngoài tài nguyên cấp thiết bị, ZZ0000ZZ còn hỗ trợ tài nguyên cấp cổng
tài nguyên. Các tài nguyên này được liên kết với một cổng liên kết nhà phát triển cụ thể thay vì
hơn toàn bộ thiết bị.

Để liệt kê tài nguyên cho tất cả các thiết bị và cổng devlink:

.. code:: shell

    $ devlink resource show
    pci/0000:03:00.0:
      name max_local_SFs size 128 unit entry dpipe_tables none
      name max_external_SFs size 128 unit entry dpipe_tables none
    pci/0000:03:00.0/196608:
      name max_SFs size 128 unit entry dpipe_tables none
    pci/0000:03:00.0/196609:
      name max_SFs size 128 unit entry dpipe_tables none
    pci/0000:03:00.1:
      name max_local_SFs size 128 unit entry dpipe_tables none
      name max_external_SFs size 128 unit entry dpipe_tables none
    pci/0000:03:00.1/196708:
      name max_SFs size 128 unit entry dpipe_tables none
    pci/0000:03:00.1/196709:
      name max_SFs size 128 unit entry dpipe_tables none

Để hiển thị tài nguyên cho một cổng cụ thể:

.. code:: shell

    $ devlink resource show pci/0000:03:00.0/196608
    pci/0000:03:00.0/196608:
      name max_SFs size 128 unit entry dpipe_tables none

Lọc phạm vi tài nguyên
========================

Khi kết xuất tài nguyên cho tất cả các thiết bị, ZZ0000ZZ chấp nhận
tham số ZZ0001ZZ tùy chọn để hạn chế phản hồi ở cấp độ thiết bị
tài nguyên, tài nguyên cấp cổng hoặc cả hai (mặc định).

Để chỉ kết xuất tài nguyên cấp thiết bị trên tất cả các thiết bị:

.. code:: shell

    $ devlink resource show scope dev
    pci/0000:03:00.0:
      name max_local_SFs size 128 unit entry dpipe_tables none
      name max_external_SFs size 128 unit entry dpipe_tables none
    pci/0000:03:00.1:
      name max_local_SFs size 128 unit entry dpipe_tables none
      name max_external_SFs size 128 unit entry dpipe_tables none

Để chỉ kết xuất tài nguyên cấp cổng trên tất cả các thiết bị:

.. code:: shell

    $ devlink resource show scope port
    pci/0000:03:00.0/196608:
      name max_SFs size 128 unit entry dpipe_tables none
    pci/0000:03:00.0/196609:
      name max_SFs size 128 unit entry dpipe_tables none
    pci/0000:03:00.1/196708:
      name max_SFs size 128 unit entry dpipe_tables none
    pci/0000:03:00.1/196709:
      name max_SFs size 128 unit entry dpipe_tables none

Lưu ý rằng tài nguyên cấp cổng là chỉ đọc.