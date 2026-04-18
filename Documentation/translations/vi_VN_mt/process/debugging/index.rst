.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/process/debugging/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================================
Lời khuyên gỡ lỗi dành cho nhà phát triển Linux Kernel
======================================================

hướng dẫn chung
--------------

.. toctree::
   :maxdepth: 1

   driver_development_debugging_guide
   gdb-kernel-debugging
   kgdb
   userspace_debugging_guide

hướng dẫn cụ thể về hệ thống con
-------------------------

.. toctree::
   :maxdepth: 1

   media_specific_debugging_guide

Lời khuyên gỡ lỗi chung
========================

Tùy thuộc vào vấn đề, có sẵn một bộ công cụ khác nhau để theo dõi
vấn đề hoặc thậm chí để nhận ra liệu có một vấn đề ngay từ đầu.

Bước đầu tiên bạn phải tìm ra loại vấn đề bạn muốn gỡ lỗi.
Tùy thuộc vào câu trả lời, phương pháp và lựa chọn công cụ của bạn có thể khác nhau.

Tôi có cần gỡ lỗi với quyền truy cập hạn chế không?
---------------------------------------

Bạn có quyền truy cập hạn chế vào máy hoặc bạn không thể ngừng hoạt động
hành quyết?

Trong trường hợp này khả năng gỡ lỗi của bạn phụ thuộc vào sự hỗ trợ gỡ lỗi tích hợp của
cung cấp hạt nhân phân phối.
ZZ0000ZZ cung cấp thông tin tóm tắt
tổng quan về một loạt các công cụ gỡ lỗi có thể có trong tình huống đó. bạn có thể
kiểm tra khả năng của kernel của bạn, trong hầu hết các trường hợp, bằng cách xem tệp cấu hình
trong thư mục /boot.

Tôi có quyền truy cập root vào hệ thống không?
------------------------------------

Bạn có thể dễ dàng thay thế mô-đun được đề cập hoặc cài đặt mô-đun mới không?
hạt nhân?

Trong trường hợp đó, phạm vi công cụ có sẵn của bạn lớn hơn rất nhiều, bạn có thể tìm thấy
công cụ trong ZZ0000ZZ.

Thời gian có phải là một yếu tố?
-------------------

Điều quan trọng là phải hiểu liệu vấn đề bạn muốn gỡ lỗi có biểu hiện hay không
một cách nhất quán (tức là với một tập hợp đầu vào bạn luôn nhận được giống nhau, không chính xác
đầu ra) hoặc không nhất quán. Nếu nó biểu hiện không nhất quán, một thời điểm nào đó
yếu tố có thể đang diễn ra. Nếu việc chèn độ trễ vào mã sẽ làm thay đổi
thì rất có thể thời gian là một yếu tố.

Khi thời gian làm thay đổi kết quả thực thi mã bằng một thao tác đơn giản
printk() cho mục đích gỡ lỗi có thể không hoạt động, một giải pháp thay thế tương tự là sử dụng
trace_printk() , ghi nhật ký các thông báo gỡ lỗi vào tệp theo dõi thay vì
nhật ký hạt nhân.

ZZ0000ZZ ©2024 : Cộng tác