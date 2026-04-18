.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/power/regulator/design.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================
Ghi chú thiết kế bộ điều chỉnh API
==================================

Tài liệu này cung cấp một cái nhìn tổng quan ngắn gọn, có cấu trúc một phần về một số
trong số những cân nhắc về thiết kế ảnh hưởng đến thiết kế bộ điều chỉnh API.

Sự an toàn
------

- Lỗi trong cấu hình bộ điều chỉnh có thể gây hậu quả rất nghiêm trọng
   cho hệ thống, có thể bao gồm cả hư hỏng phần cứng lâu dài.
 - Không thể tự động xác định cấu hình nguồn
   của hệ thống - các biến thể tương đương với phần mềm của cùng một con chip có thể
   có các yêu cầu về năng lượng khác nhau và không phải tất cả các thành phần đều có nguồn điện
   các yêu cầu được hiển thị cho phần mềm.

.. note::

     The API should make no changes to the hardware state unless it has
     specific knowledge that these changes are safe to perform on this
     particular system.

Trường hợp sử dụng của người tiêu dùng
------------------

- Phần lớn các thiết bị trong hệ thống sẽ không có
   yêu cầu thực hiện bất kỳ cấu hình thời gian chạy nào vượt quá khả năng của họ
   có thể bật hoặc tắt nó.

- Nhiều bộ nguồn trong hệ thống sẽ được chia sẻ giữa nhiều bộ nguồn
   người tiêu dùng khác nhau.

.. note::

     The consumer API should be structured so that these use cases are
     very easy to handle and so that consumers will work with shared
     supplies without any additional effort.
