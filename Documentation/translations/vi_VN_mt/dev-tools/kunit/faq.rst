.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/dev-tools/kunit/faq.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
Câu hỏi thường gặp
=============================

Điều này khác với Autotest, kselftest, v.v. như thế nào?
==========================================================
KUnit là một khung thử nghiệm đơn vị. Autotest, kselftest (và một số khác) là
không.

ZZ0000ZZ được cho là
kiểm tra một đơn vị mã độc lập và do đó có tên ZZ0001ZZ. một đơn vị
kiểm tra phải là mức độ chi tiết tốt nhất của kiểm tra và phải cho phép tất cả những gì có thể
đường dẫn mã cần được kiểm tra trong mã đang được kiểm tra. Điều này chỉ có thể thực hiện được nếu
mã được kiểm tra có kích thước nhỏ và không có bất kỳ phụ thuộc bên ngoài nào bên ngoài
kiểm soát của bài kiểm tra như phần cứng.

Hiện tại không có khung thử nghiệm nào có sẵn cho kernel mà không
yêu cầu cài đặt kernel trên máy thử nghiệm hoặc trên máy ảo. Tất cả
khung kiểm tra yêu cầu các bài kiểm tra phải được viết trong không gian người dùng và chạy trên
hạt nhân đang được thử nghiệm. Điều này đúng với Autotest, kselftest và một số thứ khác,
loại bỏ bất kỳ trong số chúng khỏi việc được coi là khung thử nghiệm đơn vị.

KUnit có hỗ trợ chạy trên các kiến ​​trúc khác ngoài UML không?
===========================================================

Vâng, hầu hết.

Phần lớn là khung lõi KUnit (thứ chúng tôi sử dụng để viết bài kiểm tra)
có thể biên dịch theo bất kỳ kiến trúc nào. Nó biên dịch giống như một phần khác của
kernel và chạy khi kernel khởi động hoặc khi được xây dựng dưới dạng mô-đun, khi
mô-đun được tải.  Tuy nhiên, có cơ sở hạ tầng, như KUnit Wrapper
(ZZ0001ZZ) có thể không hỗ trợ một số kiến trúc
(xem ZZ0000ZZ).

Tóm lại, có, bạn có thể chạy KUnit trên các kiến trúc khác, nhưng nó có thể yêu cầu
làm việc nhiều hơn việc sử dụng KUnit trên UML.

Để biết thêm thông tin, xem ZZ0000ZZ.

.. _kinds-of-tests:

Sự khác biệt giữa bài kiểm tra đơn vị và các loại bài kiểm tra khác là gì?
====================================================================
Hầu hết các thử nghiệm hiện có cho nhân Linux sẽ được phân loại là tích hợp
kiểm tra hoặc kiểm tra đầu cuối.

- Kiểm thử đơn vị được cho là kiểm thử một đơn vị mã riêng biệt. một đơn vị
  thử nghiệm phải là mức độ chi tiết tốt nhất của thử nghiệm và, như vậy, cho phép tất cả
  các đường dẫn mã có thể được kiểm tra trong mã đang được kiểm tra. Điều này chỉ có thể
  nếu mã được kiểm tra nhỏ và không có bất kỳ phụ thuộc bên ngoài nào
  nằm ngoài sự kiểm soát của bài kiểm tra như phần cứng.
- Kiểm thử tích hợp kiểm tra sự tương tác giữa một tập hợp tối thiểu các thành phần,
  thường chỉ có hai hoặc ba. Ví dụ: ai đó có thể viết một phép tích phân
  kiểm tra để kiểm tra sự tương tác giữa trình điều khiển và một phần cứng hoặc để
  kiểm tra sự tương tác giữa các thư viện không gian người dùng mà kernel cung cấp và
  chính hạt nhân. Tuy nhiên, một trong những thử nghiệm này có thể sẽ không kiểm tra
  toàn bộ kernel cùng với các tương tác phần cứng và tương tác với
  không gian người dùng.
- Thử nghiệm end-to-end thường kiểm tra toàn bộ hệ thống từ góc độ của
  mã đang được thử nghiệm. Ví dụ: ai đó có thể viết một bài kiểm tra đầu cuối cho
  kernel bằng cách cài đặt cấu hình sản xuất của kernel trên sản xuất
  hardware with a production userspace and then trying to exercise some behavior
  điều đó phụ thuộc vào sự tương tác giữa phần cứng, kernel và không gian người dùng.

KUnit không hoạt động, tôi phải làm gì?
=======================================

Thật không may, có một số thứ có thể bị vỡ, nhưng sau đây là một số thứ
những điều cần thử.

1. Chạy ZZ0001ZZ với ZZ0002ZZ
   tham số. Điều này có thể hiển thị chi tiết hoặc thông báo lỗi bị ẩn bởi kunit_tool
   trình phân tích cú pháp.
2. Thay vì chạy ZZ0003ZZ, hãy thử chạy ZZ0004ZZ,
   ZZ0005ZZ và ZZ0006ZZ một cách độc lập. Điều này có thể giúp theo dõi
   xuống nơi xảy ra sự cố. (Nếu bạn cho rằng trình phân tích cú pháp có lỗi, bạn
   có thể chạy thủ công trên ZZ0007ZZ hoặc tệp có ZZ0008ZZ.)
3. Chạy trực tiếp kernel UML thường có thể phát hiện ra các vấn đề hoặc thông báo lỗi,
   ZZ0009ZZ bỏ qua. Việc này đơn giản như chạy ZZ0010ZZ
   sau khi xây dựng kernel UML (ví dụ: bằng cách sử dụng ZZ0011ZZ).
   Lưu ý rằng UML có một số yêu cầu bất thường (chẳng hạn như máy chủ có tmpfs
   đã gắn hệ thống tập tin) và đã từng gặp sự cố trong quá khứ khi được xây dựng tĩnh và
   máy chủ đã kích hoạt KASLR. (Trên các nhân máy chủ cũ hơn, bạn có thể cần chạy
   ``setarch `uname -m` -R ./vmlinuxZZ0012ZZCONFIG_KUNIT=yZZ0013ZZCONFIG_KUNIT_EXAMPLE_TEST=yZZ0014ZZkunit.py runZZ0015ZZmake ARCH=um menuconfigZZ0016ZZmake ARCH=um defconfigZZ0017ZZkunit.py runZZ0018ZZ/sys/kernel/debug/kunit/<test suite>/resultsZZ0019ZZkunit.py parse``. Để biết thêm chi tiết, xem ZZ0000ZZ.

Nếu không có thủ thuật nào ở trên giúp ích được, bạn luôn có thể gửi email mọi vấn đề tới
kunit-dev@googlegroups.com.