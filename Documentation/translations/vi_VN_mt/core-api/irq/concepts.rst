.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/core-api/irq/concepts.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
IRQ là gì?
===============

IRQ là một yêu cầu ngắt từ một thiết bị. Hiện tại, họ có thể đến
trên một chốt hoặc trên một gói. Một số thiết bị có thể được kết nối với
cùng một pin do đó chia sẻ IRQ. Chẳng hạn như trên xe buýt PCI cũ: Tất cả các thiết bị
thường chia sẻ 4 làn/chân. Lưu ý rằng mỗi thiết bị có thể yêu cầu một
ngắt quãng trên mỗi làn đường.

Số IRQ là số nhận dạng hạt nhân được sử dụng để nói về phần cứng
nguồn ngắt. Thông thường, đây là một chỉ mục trong irq_desc toàn cầu
mảng hoặc cây thưa_irqs. Nhưng ngoại trừ linux/interrupt.h
thực hiện, các chi tiết là kiến trúc cụ thể.

Số IRQ là bảng liệt kê các nguồn ngắt có thể có trên một
máy. Thông thường, những gì được liệt kê là số lượng chân đầu vào trên
tất cả các bộ điều khiển ngắt trong hệ thống. Trong trường hợp ISA,
những gì được liệt kê là 8 chân đầu vào trên mỗi trong số hai chân i8259
bộ điều khiển ngắt.

Kiến trúc có thể gán ý nghĩa bổ sung cho các số IRQ và
được khuyến khích trong trường hợp có bất kỳ cấu hình thủ công nào
của phần cứng liên quan. IRQ ISA là một ví dụ điển hình về
gán loại ý nghĩa bổ sung này.
