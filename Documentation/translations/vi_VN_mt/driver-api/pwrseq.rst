.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/pwrseq.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright 2024 Linaro Ltd.

======================
Trình tự công suất API
====================

:Tác giả: Bartosz Golaszewski

Giới thiệu
============

Khung này được thiết kế để trừu tượng hóa các chuỗi tăng sức mạnh phức tạp
được chia sẻ giữa nhiều thiết bị logic trong nhân Linux.

Mục đích là cho phép người tiêu dùng có được bộ xử lý trình tự nguồn điện
được cung cấp bởi nhà cung cấp chuỗi năng lượng và ủy quyền yêu cầu thực tế và
kiểm soát các tài nguyên cơ bản cũng như cho phép nhà cung cấp
giảm thiểu mọi xung đột tiềm ẩn giữa nhiều người dùng ở hậu trường.

Thuật ngữ
--------

Trình tự nguồn API sử dụng một số thuật ngữ dành riêng cho hệ thống con:

Đơn vị

Một đơn vị là một đoạn riêng biệt của chuỗi năng lượng. Ví dụ, một đơn vị có thể
    kích hoạt một bộ điều chỉnh, một bộ điều chỉnh khác có thể kích hoạt GPIO cụ thể. Đơn vị có thể
    xác định các phụ thuộc dưới dạng các đơn vị khác phải được kích hoạt trước
    bản thân nó có thể như vậy.

Mục tiêu

Mục tiêu là một tập hợp các đơn vị (bao gồm đơn vị "cuối cùng" và
    phụ thuộc) mà người tiêu dùng chọn theo tên của nó khi yêu cầu xử lý
    tới bộ sắp xếp năng lượng. Thông qua hệ thống phụ thuộc, nhiều mục tiêu có thể
    chia sẻ các phần giống nhau của chuỗi lũy thừa nhưng bỏ qua các phần không có
    không liên quan.

Bộ mô tả

Một tay cầm được lõi pwrseq chuyển tới mọi người tiêu dùng đóng vai trò là
    điểm vào lớp nhà cung cấp. Nó đảm bảo sự gắn kết giữa các
    người dùng và giữ cho việc đếm tham chiếu nhất quán.

Giao diện người tiêu dùng
==================

API dành cho người tiêu dùng hướng tới sự đơn giản nhất có thể. Người lái xe quan tâm
nhận được một bộ mô tả từ trình sắp xếp nguồn nên gọi pwrseq_get() và
chỉ định tên của mục tiêu mà nó muốn tiếp cận theo trình tự sau khi gọi
pwrseq_power_up(). Bộ mô tả có thể được giải phóng bằng cách gọi pwrseq_put() và
người tiêu dùng có thể yêu cầu tắt nguồn của mục tiêu bằng
pwrseq_power_off(). Lưu ý rằng không có gì đảm bảo rằng pwrseq_power_off()
sẽ có bất kỳ ảnh hưởng nào vì có thể có nhiều người dùng các tài nguyên cơ bản
người có thể giữ cho họ hoạt động.

Giao diện nhà cung cấp
==================

Phải thừa nhận rằng nhà cung cấp API gần như không đơn giản như nhà cung cấp dành cho
người tiêu dùng nhưng bù lại nó có tính linh hoạt.

Mỗi nhà cung cấp có thể chia trình tự bật nguồn thành các phần riêng biệt một cách hợp lý
(đơn vị) và xác định sự phụ thuộc của chúng. Sau đó, họ có thể tiết lộ các mục tiêu được đặt tên
người tiêu dùng có thể sử dụng làm điểm cuối cùng trong chuỗi mà họ muốn tiếp cận.

Để đạt được mục đích đó, các nhà cung cấp điền vào một tập hợp các cấu trúc cấu hình và
đăng ký với hệ thống con pwrseq bằng cách gọi pwrseq_device_register().

Kết nối người tiêu dùng năng động
-------------------------

Sự khác biệt chính giữa pwrseq và các nhà cung cấp nhân Linux khác là
cơ chế kết nối năng động giữa người tiêu dùng và nhà cung cấp. Mỗi chuỗi sức mạnh
trình điều khiển nhà cung cấp phải triển khai lệnh gọi lại ZZ0000ZZ và chuyển nó tới pwrseq
core khi đăng ký với các hệ thống con.

Khi máy khách yêu cầu một trình xử lý trình sắp xếp thứ tự, lõi sẽ gọi lệnh gọi lại này để
mọi nhà cung cấp đã đăng ký và để họ linh hoạt tìm hiểu xem liệu nhà cung cấp được đề xuất có
thiết bị khách hàng thực sự là người tiêu dùng của nó. Ví dụ: nếu nhà cung cấp liên kết với
nút cây thiết bị đại diện cho đơn vị quản lý năng lượng của chipset và
trình điều khiển của người tiêu dùng điều khiển một trong các mô-đun của nó, trình điều khiển của nhà cung cấp có thể phân tích cú pháp
các thuộc tính cung cấp bộ điều chỉnh có liên quan trong cây thiết bị và xem liệu chúng có dẫn từ
PMU tới người tiêu dùng.

Tham khảo API
=============

.. kernel-doc:: include/linux/pwrseq/provider.h
   :internal:

.. kernel-doc:: drivers/power/sequencing/core.c
   :export: