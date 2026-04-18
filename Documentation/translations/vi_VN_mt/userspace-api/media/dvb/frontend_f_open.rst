.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/frontend_f_open.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.fe

.. _frontend_f_open:

*****************************
Giao diện TV kỹ thuật số mở()
*****************************

Tên
====

fe-open - Mở thiết bị giao diện người dùng

Tóm tắt
========

.. code-block:: c

    #include <fcntl.h>

.. c:function:: int open( const char *device_name, int flags )

Đối số
=========

ZZ0000ZZ
    Thiết bị cần mở.

ZZ0000ZZ
    Mở cờ. Quyền truy cập có thể là ZZ0001ZZ hoặc ZZ0002ZZ.

Được phép mở nhiều lần với ZZ0000ZZ. Ở chế độ này, chỉ
    truy vấn và đọc ioctls được cho phép.

Chỉ cho phép mở một lần trong ZZ0000ZZ. Trong chế độ này, tất cả ioctls đều
    được phép.

Khi cờ ZZ0000ZZ được đưa ra, các cuộc gọi hệ thống có thể quay trở lại
    Mã lỗi ZZ0001ZZ khi không có dữ liệu hoặc khi thiết bị
    tài xế tạm thời bận.

Các cờ khác không có hiệu lực.

Sự miêu tả
===========

Cuộc gọi hệ thống này sẽ mở một thiết bị giao diện người dùng có tên
(ZZ0001ZZ) cho lần sử dụng tiếp theo. Thông thường lần đầu tiên
điều cần làm sau khi mở thành công là tìm ra loại giao diện người dùng
với ZZ0000ZZ.

Máy có thể mở ở chế độ chỉ đọc, chỉ cho phép theo dõi
trạng thái và số liệu thống kê của thiết bị hoặc chế độ đọc/ghi, cho phép mọi
loại sử dụng (ví dụ: thực hiện các thao tác điều chỉnh.)

Trong một hệ thống có nhiều giao diện người dùng, thường xảy ra trường hợp
nhiều thiết bị không thể mở đồng thời ở chế độ đọc/ghi. Như
miễn là thiết bị ngoại vi được mở ở chế độ đọc/ghi, open() khác
các cuộc gọi ở chế độ đọc/ghi sẽ không thành công hoặc bị chặn, tùy thuộc vào việc liệu
chế độ không chặn hoặc chặn đã được chỉ định. Một thiết bị ngoại vi đã mở
ở chế độ chặn sau này có thể được chuyển sang chế độ không chặn (và ngược lại
ngược lại) bằng cách sử dụng lệnh F_SETFL của lệnh gọi hệ thống fcntl. Đây là một
cuộc gọi hệ thống tiêu chuẩn, được ghi lại trong trang hướng dẫn Linux cho fcntl.
Khi cuộc gọi open() thành công, thiết bị sẽ sẵn sàng để sử dụng
chế độ đã chỉ định. Điều này ngụ ý rằng phần cứng tương ứng là
được cấp nguồn và các giao diện người dùng khác có thể đã bị tắt nguồn để thực hiện
điều đó có thể.

Giá trị trả về
==============

Khi thành công, ZZ0000ZZ trả về bộ mô tả tệp mới.
Nếu có lỗi, -1 được trả về và biến ZZ0001ZZ được đặt thích hợp.

Các mã lỗi có thể xảy ra là:

Khi thành công, 0 được trả về và ZZ0000ZZ được điền.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

.. tabularcolumns:: |p{2.5cm}|p{15.0cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths: 1 16

    -  - ``EPERM``
       -  The caller has no permission to access the device.

    -  - ``EBUSY``
       -  The device driver is already in use.

    -  - ``EMFILE``
       -  The process already has the maximum number of files open.

    -  - ``ENFILE``
       -  The limit on the total number of files open on the system has been
	  reached.

Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.