.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/k8temp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân k8temp
====================

Chip được hỗ trợ:

* CPU AMD Athlon64/FX hoặc Opteron

Tiền tố: 'k8temp'

Địa chỉ được quét: không gian PCI

Bảng dữ liệu: ZZ0000ZZ

Tác giả: Rudolf Marek

Liên hệ: Rudolf Marek <r.marek@assembler.cz>

Sự miêu tả
-----------

Trình điều khiển này cho phép đọc (các) cảm biến nhiệt độ được nhúng bên trong AMD K8
CPU gia đình (Athlon64/FX, Opteron). Tài liệu chính thức nói rằng nó hoạt động
từ bản sửa đổi F của lõi K8, nhưng trên thực tế nó dường như được triển khai cho tất cả
các phiên bản của K8 ngoại trừ hai phiên bản đầu tiên (SH-B0 và SH-B3).

Xin lưu ý rằng bạn sẽ cần ít nhất lm-sensors 2.10.1 để có không gian người dùng phù hợp
hỗ trợ.

Có thể có tới bốn cảm biến nhiệt độ bên trong một chiếc CPU. Người lái xe
sẽ tự động phát hiện các cảm biến và sẽ chỉ hiển thị nhiệt độ từ
cảm biến được thực hiện.

Ánh xạ của các tệp /sys như sau:

====================================================
nhiệt độ temp1_input của Core 0 và "place" 0
nhiệt độ temp2_input của Core 0 và "place" 1
nhiệt độ temp3_input của Core 1 và "place" 0
nhiệt độ temp4_input của Core 1 và "place" 1
====================================================

Nhiệt độ được đo bằng độ C và độ phân giải đo là
1 độ C. Dự kiến CPU trong tương lai sẽ có độ phân giải tốt hơn. các
nhiệt độ được cập nhật mỗi giây một lần. Nhiệt độ hợp lệ là từ -49 đến
206 độ C.

Nhiệt độ được gọi là TCaseMax đã được chỉ định cho các bộ xử lý lên đến phiên bản E.
Nhiệt độ này được xác định là nhiệt độ giữa bộ tản nhiệt và CPU
trường hợp này, do đó nhiệt độ bên trong CPU do trình điều khiển này cung cấp có thể cao hơn.
Không có cách nào dễ dàng để đo nhiệt độ tương quan
với nhiệt độ TCaseMax.

Đối với các phiên bản mới hơn của CPU (rev F, socket AM2), có một phương pháp toán học
nhiệt độ được tính toán gọi là TControl, phải thấp hơn TControlMax.

Mối quan hệ như sau:

temp1_input - TjOffset*2 < TControlMax,

TjOffset chưa được trình điều khiển xuất ra, TControlMax thường
70 độ C. Nguyên tắc ngón tay cái -> Nhiệt độ CPU không nên vượt qua
60 độ C quá nhiều.
