.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/sym53c500_cs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
Trình điều khiển sym53c500_cs
=============================

Trình điều khiển sym53c500_cs có nguồn gốc là một tiện ích bổ sung cho pcmcia-cs của David Hinds
gói và được viết bởi Tom Corner (tcorner@via.at).  Việc viết lại là
đã quá hạn từ lâu và phiên bản hiện tại giải quyết các vấn đề sau:

(1) những thay đổi lớn về kernel giữa 2.4 và 2.6.
	(2) không còn hỗ trợ PCMCIA bên ngoài kernel.

Tất cả mã USE_BIOS đã bị lấy cắp.  Nó chưa bao giờ được sử dụng và có thể
dù sao cũng không có tác dụng.  Mã USE_DMA cũng không còn nữa.  Cảm ơn rất nhiều
tới YOKOTA Hiroshi (trình điều khiển nsp_cs) và David Hinds (trình điều khiển qlogic_cs) cho
những đoạn mã mà tôi đã vô tình điều chỉnh cho công việc này.  Cũng xin cảm ơn
Christoph Hellwig vì sự hướng dẫn kiên nhẫn của anh ấy trong khi tôi vấp ngã.

Chip Symbios Logic 53c500 được sử dụng trong phiên bản "mới hơn" (khoảng năm 1997)
của bộ điều khiển New Media Bus Toaster PCMCIA SCSI.  Có lẽ có
các sản phẩm khác dùng chip này nhưng mình chưa bao giờ để mắt tới (chứ đừng nói là tay)
trên một.

Qua nhiều năm, đã có một số lượt tải xuống pcmcia-cs
phiên bản của trình điều khiển này và tôi đoán nó có tác dụng với những người dùng đó.  Nó hoạt động
cho Tom Corner, và nó hiệu quả với tôi.  Số dặm của bạn có thể sẽ thay đổi.

Bob Tracy (rct@frus.com)