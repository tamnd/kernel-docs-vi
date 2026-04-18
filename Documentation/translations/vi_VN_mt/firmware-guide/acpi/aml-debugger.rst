.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/firmware-guide/acpi/aml-debugger.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

==================
Trình gỡ lỗi AML
==================

:Bản quyền: ZZ0000ZZ 2016, Tập đoàn Intel
:Tác giả: Lv Zheng <lv.zheng@intel.com>


Tài liệu này mô tả cách sử dụng trình gỡ lỗi AML được nhúng trong Linux
hạt nhân.

1. Xây dựng trình gỡ lỗi
=====================

Cần có các mục cấu hình kernel sau để kích hoạt AML
giao diện trình gỡ lỗi từ nhân Linux::

CONFIG_ACPI_DEBUGGER=y
   CONFIG_ACPI_DEBUGGER_USER=m

Các tiện ích không gian người dùng có thể được xây dựng từ cây nguồn kernel bằng cách sử dụng
các lệnh sau::

công cụ $ cd
   $ tạo acpi

Sau đó, tệp nhị phân của công cụ không gian người dùng thu được sẽ được đặt tại::

công cụ/sức mạnh/acpi/acpidbg

Nó có thể được cài đặt vào các thư mục hệ thống bằng cách chạy "make install" (dưới dạng
người dùng có đủ đặc quyền).

2. Khởi động giao diện trình gỡ lỗi không gian người dùng
=========================================

Sau khi khởi động kernel với trình gỡ lỗi tích hợp sẵn, trình gỡ lỗi có thể
bắt đầu bằng cách sử dụng các lệnh sau ::

# mount -t debugfs không/sys/kernel/debug
   # modprobe acpi_dbg
   # tools/nguồn/acpi/acpidbg

Điều đó tạo ra môi trường trình gỡ lỗi AML tương tác nơi bạn có thể thực thi
lệnh gỡ lỗi.

Các lệnh được ghi lại trong "ACPICA Tổng quan và tham khảo lập trình viên"
có thể được tải xuống từ

ZZ0000ZZ

Tham khảo lệnh gỡ lỗi chi tiết nằm ở Chương 12 "ACPICA
Tham chiếu trình gỡ lỗi".  Lệnh "trợ giúp" có thể được sử dụng để tham khảo nhanh.

3. Dừng giao diện gỡ lỗi không gian người dùng
========================================

Có thể đóng giao diện trình gỡ lỗi tương tác bằng cách nhấn Ctrl+C hoặc sử dụng
lệnh "thoát" hoặc "thoát".  Khi hoàn tất, hãy dỡ mô-đun bằng::

# rmmod acpi_dbg

Việc dỡ tải mô-đun có thể không thành công nếu có phiên bản acpidbg đang chạy.

4. Chạy trình gỡ lỗi trong tập lệnh
===============================

Có thể hữu ích khi chạy trình gỡ lỗi AML trong tập lệnh thử nghiệm. hỗ trợ "acpidbg"
cái này ở chế độ "lô" đặc biệt.  Ví dụ: đầu ra lệnh sau
toàn bộ không gian tên ACPI::

# acpidbg -b "không gian tên"