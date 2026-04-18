.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/dmx-fopen.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: DTV.dmx

.. _dmx_fopen:

==========================
Mở demux TV kỹ thuật số()
==========================

Tên
----

Mở demux TV kỹ thuật số()

Tóm tắt
--------

.. c:function:: int open(const char *deviceName, int flags)

Đối số
---------

ZZ0000ZZ
  Tên thiết bị demux TV kỹ thuật số cụ thể.

ZZ0000ZZ
  Một chút HOẶC của các cờ sau:

.. tabularcolumns:: |p{2.5cm}|p{15.0cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths: 1 16

    -
       - ``O_RDONLY``
       - read-only access

    -
       - ``O_RDWR``
       - read/write access

    -
       - ``O_NONBLOCK``
       - open in non-blocking mode
         (blocking mode is the default)

Sự miêu tả
-----------

Cuộc gọi hệ thống này, được sử dụng với tên thiết bị là ZZ0000ZZ,
phân bổ một bộ lọc mới và trả về một bộ điều khiển có thể được sử dụng cho
kiểm soát tiếp theo của bộ lọc đó. Cuộc gọi này phải được thực hiện cho mỗi
bộ lọc sẽ được sử dụng, tức là mọi bộ mô tả tệp được trả về đều là tham chiếu đến
một bộ lọc duy nhất. ZZ0001ZZ là một thiết bị logic được sử dụng
để truy xuất Luồng truyền tải để ghi video kỹ thuật số. Khi nào
đọc từ thiết bị này một luồng truyền tải chứa các gói từ
tất cả các bộ lọc PES được đặt trong thiết bị demux tương ứng
(ZZ0002ZZ) có đầu ra được đặt thành ZZ0003ZZ.
Luồng truyền tải đã ghi sẽ được phát lại bằng cách ghi vào thiết bị này.

Tầm quan trọng của chế độ chặn hoặc không chặn được mô tả trong
tài liệu cho các chức năng có sự khác biệt. Nó không
ảnh hưởng đến ngữ nghĩa của chính cuộc gọi ZZ0000ZZ. Một thiết bị đã mở
ở chế độ chặn sau này có thể được chuyển sang chế độ không chặn (và ngược lại)
bằng cách sử dụng lệnh ZZ0001ZZ của lệnh gọi hệ thống fcntl.

Giá trị trả về
------------

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

.. tabularcolumns:: |p{2.5cm}|p{15.0cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths: 1 16

    -  -  ``EMFILE``
       -  "Too many open files", i.e. no more filters available.

Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.