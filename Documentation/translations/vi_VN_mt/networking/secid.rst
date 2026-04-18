.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/secid.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
LSM/SeLinux bí mật
=================

cấu trúc dòng chảy:

Thành viên secid trong cấu trúc luồng được sử dụng trong LSM (ví dụ SELinux) để biểu thị
nhãn của dòng chảy. Nhãn này của luồng hiện đang được sử dụng để chọn
khớp với (các) xfrm được gắn nhãn.

Nếu đây là luồng đi, nhãn được lấy từ ổ cắm, nếu có, hoặc
gói đến luồng này đang được tạo dưới dạng phản hồi (ví dụ: tcp
đặt lại, timewait ack, v.v.). Cũng có thể hình dung rằng nhãn có thể là
bắt nguồn từ các nguồn khác như bối cảnh quy trình, thiết bị, v.v., đặc biệt
trường hợp, nếu có thể thích hợp.

Nếu đây là luồng vào, nhãn được lấy từ bảo mật IPSec
các liên kết, nếu có, được sử dụng bởi gói.