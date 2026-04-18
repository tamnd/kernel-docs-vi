.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/power/drivers-testing.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================================================================
Kiểm tra việc tạm dừng và tiếp tục hỗ trợ trong trình điều khiển thiết bị
=========================================================================

(C) 2007 Rafael J. Wysocki <rjw@sisk.pl>, GPL

1. Chuẩn bị hệ thống thử nghiệm
============================

Thật không may, để kiểm tra hiệu quả sự hỗ trợ cho hệ thống tạm dừng và
tiếp tục quá trình chuyển đổi trong trình điều khiển, cần phải tạm dừng và tiếp tục lại toàn bộ
hệ thống chức năng với trình điều khiển này được tải.  Hơn nữa, việc đó phải được thực hiện
nhiều lần, tốt nhất là nhiều lần liên tiếp và riêng biệt để ngủ đông
(còn gọi là tạm dừng vào đĩa hoặc STD) và tạm dừng RAM (STR), bởi vì mỗi điều này
trường hợp liên quan đến các hoạt động hơi khác nhau và các tương tác khác nhau với
BIOS của máy.

Tất nhiên, với mục đích này, hệ thống kiểm tra phải được biết là có thể tạm dừng và
tiếp tục mà không cần kiểm tra trình điều khiển.  Vì vậy, nếu có thể, trước tiên bạn nên
giải quyết tất cả các vấn đề liên quan đến tạm dừng/tiếp tục trong hệ thống kiểm tra trước khi bạn bắt đầu
đang test driver mới.  Vui lòng xem Tài liệu/power/basic-pm-debugging.rst
để biết thêm thông tin về việc gỡ lỗi chức năng tạm dừng/tiếp tục.

2. Kiểm tra trình điều khiển
=====================

Khi bạn đã giải quyết được các vấn đề liên quan đến việc tạm dừng/tiếp tục lại với hệ thống kiểm tra của mình
không có trình điều khiển mới, bạn đã sẵn sàng để kiểm tra nó:

a) Xây dựng trình điều khiển dưới dạng mô-đun, tải nó và thử các chế độ ngủ đông thử nghiệm
   (xem: Tài liệu/sức mạnh/basic-pm-debugging.rst, 1).

b) Tải trình điều khiển và cố gắng ngủ đông trong quá trình "khởi động lại", "tắt máy" và
   chế độ "nền tảng" (xem: Documentation/power/basic-pm-debugging.rst, 1).

c) Biên dịch trình điều khiển trực tiếp vào kernel và thử các chế độ kiểm tra của
   ngủ đông.

d) Cố gắng ngủ đông bằng trình điều khiển được biên dịch trực tiếp vào kernel
   ở các chế độ "khởi động lại", "tắt máy" và "nền tảng".

e) Thử các chế độ thử nghiệm đình chỉ (xem:
   Tài liệu/power/basic-pm-debugging.rst, 2).  [Theo như các bài kiểm tra STR
   có liên quan, việc trình điều khiển có được xây dựng như một phần mềm hay không không quan trọng
   mô-đun.]

f) Cố gắng tạm dừng RAM bằng công cụ s2ram khi đã tải trình điều khiển
   (xem: Documentation/power/basic-pm-debugging.rst, 2).

Mỗi thử nghiệm trên phải được lặp lại nhiều lần và các thử nghiệm STD
nên được trộn lẫn với các thử nghiệm STR.  Nếu bất kỳ điều nào trong số đó không thành công, người lái xe không thể
được coi là tạm dừng/tiếp tục an toàn.
