.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/secid.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

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