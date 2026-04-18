.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/tc-queue-filters.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Lọc dựa trên hàng đợi TC
===========================

TC có thể được sử dụng để định hướng lưu lượng đến một tập hợp các hàng đợi hoặc
vào một hàng đợi duy nhất ở cả phía phát và phía nhận.

Về phía truyền:

1) Đạt được bộ lọc TC hướng lưu lượng truy cập đến một tập hợp hàng đợi
   sử dụng mức độ ưu tiên hành động skbedit cho lựa chọn mức độ ưu tiên Tx,
   mức độ ưu tiên ánh xạ tới một loại lưu lượng (tập hợp hàng đợi) khi
   các bộ hàng đợi được định cấu hình bằng mqprio.

2) Bộ lọc TC hướng lưu lượng truy cập đến hàng đợi truyền bằng hành động
   skbedit queue_mapping $tx_qid. Hành động skbedit queue_mapping
   đối với hàng đợi truyền chỉ được thực thi trong phần mềm và không thể
   đã giảm tải.

Tương tự như vậy, ở phía nhận, hai bộ lọc để chọn tập hợp
hàng đợi và/hoặc một hàng đợi duy nhất được hỗ trợ như sau:

1) Bộ lọc hoa TC hướng lưu lượng truy cập đến một tập hợp hàng đợi bằng cách sử dụng
   tùy chọn 'hw_tc'.
   hw_tc $TCID - Chỉ định lớp lưu lượng phần cứng để vượt qua kết quả khớp
   gói tin vào. TCID nằm trong khoảng từ 0 đến 15.

2) Bộ lọc TC có hành động skbedit queue_mapping $rx_qid chọn một
   nhận hàng đợi. Hành động skbedit queue_mapping cho hàng đợi nhận
   chỉ được hỗ trợ trong phần cứng. Nhiều bộ lọc có thể cạnh tranh trong
   phần cứng để lựa chọn hàng đợi. Trong trường hợp như vậy, phần cứng
   đường ống giải quyết xung đột dựa trên mức độ ưu tiên. Trên Intel E810
   thiết bị, bộ lọc TC hướng lưu lượng truy cập đến hàng đợi có hiệu suất cao hơn
   ưu tiên hơn bộ lọc giám đốc luồng chỉ định hàng đợi. Hàm băm
   bộ lọc có mức độ ưu tiên thấp nhất.