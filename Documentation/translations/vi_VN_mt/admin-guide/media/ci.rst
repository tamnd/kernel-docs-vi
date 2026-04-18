.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/ci.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Giao diện truy cập có điều kiện của TV kỹ thuật số
=======================================


.. note::

   This documentation is outdated.

Tài liệu này mô tả cách sử dụng CI API cấp cao như
theo Linux DVB API. Đây không phải là tài liệu dành cho,
CI API cấp thấp hiện có.

.. note::

   For the Twinhan/Twinhan clones, the dst_ca module handles the CI
   hardware handling. This module is loaded automatically if a CI
   (Common Interface, that holds the CAM (Conditional Access Module)
   is detected.

ca_zap
~~~~~~

Cần có một ứng dụng không gian người dùng, như ZZ0000ZZ để xử lý các dữ liệu được mã hóa
Luồng MPEG-TS.

Ứng dụng userland ZZ0000ZZ chịu trách nhiệm gửi
giải mã thông tin liên quan đến Mô-đun truy cập có điều kiện (CAM).

Ứng dụng này hiện yêu cầu những điều sau để hoạt động bình thường.

a) Dò kênh hợp lệ bằng szap.

ví dụ: $ szap -cchannels.conf -r "TMC" -x

b) một kênh.conf chứa PMT PID hợp lệ

ví dụ: TMC:11996:h:0:27500:278:512:650:321

ở đây 278 là PMT PID hợp lệ. các giá trị còn lại là
  những cái tương tự mà szap sử dụng.

c) sau khi chạy szap, bạn phải chạy ca_zap, để
   bộ giải mã hoạt động,

ví dụ: $ ca_zapchannels.conf "TMC"

d) Hy vọng bạn sẽ thích kênh đã đăng ký yêu thích của mình như cách bạn làm với
   thẻ FTA.

.. note::

  Currently ca_zap, and dst_test, both are meant for demonstration
  purposes only, they can become full fledged applications if necessary.


Thẻ thuộc danh mục này
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Hiện tại các lá bài thuộc loại này là Twinhan và
bản sao, những thẻ này có sẵn dưới dạng VVMER, Tomato, Hercules, Orange và
vân vân.

Các mô-đun CI được hỗ trợ
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Hỗ trợ mô-đun CI phần lớn phụ thuộc vào phần sụn trên thẻ
Một số thẻ hỗ trợ hầu hết tất cả các mô-đun CI có sẵn. có
không thể làm được gì nhiều để tạo thêm các mô-đun CI
làm việc với những thẻ này.

Các mô-đun đã được thử nghiệm bởi trình điều khiển này hiện nay là

(1) Irdeto 1 và 2 từ SCM
(2) Viaccess từ SCM
(3) Máy quay rồng