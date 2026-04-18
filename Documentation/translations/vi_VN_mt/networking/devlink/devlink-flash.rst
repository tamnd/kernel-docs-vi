.. SPDX-License-Identifier: (GPL-2.0-only OR BSD-2-Clause)

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/devlink-flash.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _devlink_flash:

==============
Flash liên kết nhà phát triển
=============

ZZ0000ZZ API cho phép cập nhật chương trình cơ sở của thiết bị. Nó thay thế
cơ chế ZZ0001ZZ cũ hơn và không yêu cầu thực hiện bất kỳ
khóa mạng trong kernel để thực hiện cập nhật flash. Ví dụ sử dụng::

$ devlink dev flash pci/0000:05:00.0 tập tin flash-boot.bin

Lưu ý rằng tên tệp là đường dẫn liên quan đến đường dẫn tải chương trình cơ sở
(thường là ZZ0000ZZ). Trình điều khiển có thể gửi cập nhật trạng thái để thông báo
không gian người dùng về tiến trình của hoạt động cập nhật.

Mặt nạ ghi đè
==============

Lệnh ZZ0000ZZ cho phép tùy chọn chỉ định mặt nạ biểu thị
cách thiết bị xử lý các phần phụ của thành phần flash khi cập nhật.
Mặt nạ này cho biết tập hợp các phần được phép ghi đè.

.. list-table:: List of overwrite mask bits
   :widths: 5 95

   * - Name
     - Description
   * - ``DEVLINK_FLASH_OVERWRITE_SETTINGS``
     - Indicates that the device should overwrite settings in the components
       being updated with the settings found in the provided image.
   * - ``DEVLINK_FLASH_OVERWRITE_IDENTIFIERS``
     - Indicates that the device should overwrite identifiers in the
       components being updated with the identifiers found in the provided
       image. This includes MAC addresses, serial IDs, and similar device
       identifiers.

Nhiều bit ghi đè có thể được kết hợp và yêu cầu cùng nhau. Nếu không có bit
được cung cấp, dự kiến thiết bị chỉ cập nhật các tệp nhị phân chương trình cơ sở
trong các thành phần đang được cập nhật. Các cài đặt và số nhận dạng dự kiến sẽ được
được bảo tồn trong suốt bản cập nhật. Một thiết bị có thể không hỗ trợ mọi sự kết hợp và
trình điều khiển cho thiết bị đó phải từ chối bất kỳ sự kết hợp nào không thể
được thực hiện một cách trung thực.

Đang tải chương trình cơ sở
================

Các thiết bị yêu cầu phần sụn để hoạt động thường lưu trữ nó ở dạng không ổn định.
bộ nhớ trên bảng, ví dụ: nhấp nháy. Một số thiết bị chỉ lưu trữ phần mềm cơ bản trên
bo mạch và trình điều khiển tải phần còn lại từ đĩa trong quá trình thăm dò.
ZZ0000ZZ cho phép người dùng truy vấn thông tin phần sụn (đã tải
thành phần và phiên bản).

Trong các trường hợp khác, thiết bị có thể vừa lưu trữ hình ảnh trên bảng, tải từ
đĩa hoặc tự động flash một hình ảnh mới từ đĩa. ZZ0001ZZ
tham số devlink có thể được sử dụng để kiểm soát hành vi này
(ZZ0000ZZ).

Các tập tin chương trình cơ sở trên đĩa thường được lưu trữ trong ZZ0000ZZ.

Quản lý phiên bản phần sụn
===========================

Trình điều khiển dự kiến ​​sẽ triển khai ZZ0000ZZ và ZZ0001ZZ
chức năng, cùng nhau cho phép triển khai độc lập với nhà cung cấp
cơ sở cập nhật chương trình cơ sở tự động.

ZZ0000ZZ tiết lộ tên ZZ0001ZZ và ba nhóm phiên bản
(ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ).

Thuộc tính ZZ0000ZZ và nhóm ZZ0001ZZ xác định thiết bị cụ thể
thiết kế, ví dụ: để tra cứu các bản cập nhật chương trình cơ sở hiện hành. Đây là lý do tại sao
ZZ0002ZZ không phải là một phần của phiên bản ZZ0003ZZ (mặc dù nó
đã được sửa) - Các phiên bản ZZ0004ZZ phải xác định thiết kế chứ không phải một
thiết bị.

Phiên bản firmware ZZ0000ZZ và ZZ0001ZZ xác định firmware đang chạy
trên thiết bị và chương trình cơ sở sẽ được kích hoạt sau khi khởi động lại hoặc thiết bị
đặt lại.

Tác nhân cập nhật chương trình cơ sở được cho là có thể thực hiện theo cách đơn giản này
thuật toán cập nhật nội dung chương trình cơ sở, bất kể nhà cung cấp thiết bị:

.. code-block:: sh

  # Get unique HW design identifier
  $hw_id = devlink-dev-info['fixed']

  # Find out which FW flash we want to use for this NIC
  $want_flash_vers = some-db-backed.lookup($hw_id, 'flash')

  # Update flash if necessary
  if $want_flash_vers != devlink-dev-info['stored']:
      $file = some-db-backed.download($hw_id, 'flash')
      devlink-dev-flash($file)

  # Find out the expected overall firmware versions
  $want_fw_vers = some-db-backed.lookup($hw_id, 'all')

  # Update on-disk file if necessary
  if $want_fw_vers != devlink-dev-info['running']:
      $file = some-db-backed.download($hw_id, 'disk')
      write($file, '/lib/firmware/')

  # Try device reset, if available
  if $want_fw_vers != devlink-dev-info['running']:
     devlink-reset()

  # Reboot, if reset wasn't enough
  if $want_fw_vers != devlink-dev-info['running']:
     reboot()

Lưu ý rằng mỗi tham chiếu đến ZZ0000ZZ trong mã giả này
dự kiến ​​sẽ lấy thông tin cập nhật từ kernel.

Để thuận tiện cho việc xác định các tập tin phần sụn, một số nhà cung cấp thêm
Thông tin ZZ0000ZZ cho các phiên bản phần sụn. Phiên bản meta này bao gồm
nhiều phiên bản cho mỗi thành phần và có thể được sử dụng, ví dụ: trong tên tập tin phần sụn
(tất cả các phiên bản thành phần có thể khá dài.)