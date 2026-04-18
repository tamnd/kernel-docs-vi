.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/devlink-linecard.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===================
Thẻ dòng Devlink
=================

Lý lịch
==========

Cơ chế ZZ0000ZZ được nhắm mục tiêu để thao túng
thẻ dòng đóng vai trò là mô-đun PHY có thể tháo rời để chuyển đổi mô-đun
hệ thống. Các hoạt động sau đây được cung cấp:

* Nhận danh sách các loại thẻ dòng được hỗ trợ.
  * Cung cấp một khe cắm với loại thẻ dòng cụ thể.
  * Nhận và theo dõi trạng thái thẻ dòng và sự thay đổi của nó.

Thẻ dòng theo loại có thể chứa một hoặc nhiều hộp số
để chuyển các làn đường với tốc độ nhất định sang nhiều cổng có làn đường
có tốc độ khác nhau. Thẻ dòng đảm bảo ánh xạ N:M giữa
mô-đun chuyển đổi ASIC và các cổng vật lý ở bảng mặt trước.

Tổng quan
========

Mỗi đối tượng liên kết thẻ dòng được tạo bởi trình điều khiển thiết bị,
theo các khe cắm thẻ dòng vật lý có sẵn trên thiết bị.

Tương tự như cáp chia, nơi thiết bị có thể không có đường
phát hiện hình dạng cáp bộ chia, thiết bị
có thể không có cách nào để phát hiện loại thẻ dòng. Đối với các thiết bị đó,
khái niệm cung cấp được giới thiệu. Nó cho phép người dùng:

* Cung cấp khe cắm thẻ dòng với loại thẻ dòng nhất định

- Trình điều khiển thiết bị sẽ hướng dẫn ASIC chuẩn bị tất cả
      nguồn lực tương ứng. Trình điều khiển thiết bị sẽ
      tạo tất cả các phiên bản, cụ thể là cổng devlink và netdevices
      nằm trên thẻ dòng, theo loại thẻ dòng
  * Thao tác với các thực thể thẻ dòng ngay cả khi không có thẻ dòng
    được kết nối vật lý hoặc được cấp nguồn
  * Thiết lập cáp chia cổng trên các cổng line card

- Giống như trên các cổng thông thường, người dùng có thể cung cấp bộ chia
      cáp thuộc một loại nhất định mà không cần phải
      được kết nối vật lý với cổng
  * Cấu hình cổng devlink và netdevices

Nhà mạng Netdevice được quyết định như sau:

* Thẻ dòng không được lắp hoặc tắt nguồn

- Người vận chuyển luôn bị down
  * Card Line được lắp vào và cấp nguồn

- Nhà mạng được quyết định như đối với thiết bị mạng cổng thông thường

Trạng thái thẻ dòng
===============

Cơ chế ZZ0000ZZ hỗ trợ các trạng thái thẻ dòng sau:

* ZZ0000ZZ: Card dòng không được cung cấp trên khe cắm.
  * ZZ0001ZZ: Khe cắm thẻ dòng hiện không được cung cấp.
  * ZZ0002ZZ: Khe cắm thẻ Line hiện đang trong quá trình cung cấp
    với một loại thẻ dòng.
  * ZZ0003ZZ: Việc cung cấp không thành công.
  * ZZ0004ZZ: Khe cắm thẻ Line được cung cấp một loại.
  * ZZ0005ZZ: Card Line đã được cấp nguồn và hoạt động.

Sơ đồ sau đây cung cấp cái nhìn tổng quan chung về ZZ0000ZZ
chuyển đổi trạng thái::

+-----------------+
                                          ZZ0000ZZ
       +----------------------------------> không được cung cấp |
       ZZ0001ZZ |
       ZZ0002ZZ-------^--------+
       ZZ0003ZZ |
       ZZ0004ZZ |
       ZZ0005ZZ--------+
       ZZ0006ZZ |
       Cung cấp ZZ0007ZZ |
       ZZ0008ZZ |
       ZZ0009ZZ-------------+
       ZZ0010ZZ
       |                 +-----------------------------+
       ZZ0011ZZ |
       |    +-------------v-------------+ +-------------v-------------+ +-----------------+
       ZZ0012ZZ ZZ0013ZZ ----> |
       +------ cung cấp_failed ZZ0014ZZ đã cung cấp ZZ0015ZZ đang hoạt động |
       ZZ0016ZZ ZZ0017ZZ <---- |
       ZZ0018ZZ-------------+ +--------------------------+
       ZZ0019ZZ |
       ZZ0020ZZ |
       ZZ0021ZZ +-------------v-------------+
       ZZ0022ZZ ZZ0023ZZ
       ZZ0024ZZ ZZ0025ZZ
       ZZ0026ZZ ZZ0027ZZ
       ZZ0028ZZ +-------------|-------------+
       ZZ0029ZZ |
       |                 +-----------------------------+
       ZZ0030ZZ
       +-----------------------------------------------+


Cách sử dụng ví dụ
=============

.. code:: shell

    $ devlink lc show [ DEV [ lc LC_INDEX ] ]
    $ devlink lc set DEV lc LC_INDEX [ { type LC_TYPE | notype } ]

    # Show current line card configuration and status for all slots:
    $ devlink lc

    # Set slot 8 to be provisioned with type "16x100G":
    $ devlink lc set pci/0000:01:00.0 lc 8 type 16x100G

    # Set slot 8 to be unprovisioned:
    $ devlink lc set pci/0000:01:00.0 lc 8 notype