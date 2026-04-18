.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/bpf_licensing.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==============
Giấy phép BPF
=============

Lý lịch
==========

* BPF cổ điển đã được cấp phép BSD

"BPF" ban đầu được giới thiệu là Bộ lọc gói BSD trong
ZZ0000ZZ Lệnh tương ứng
được thiết lập và việc triển khai nó đến từ BSD với giấy phép BSD. Bản gốc đó
tập lệnh hiện được gọi là "BPF cổ điển".

Tuy nhiên, tập lệnh là một đặc tả cho sự tương tác giữa ngôn ngữ máy,
tương tự như một ngôn ngữ lập trình.  Nó không phải là một mã. Vì vậy,
việc áp dụng giấy phép BSD có thể gây hiểu lầm trong một bối cảnh nhất định, vì
tập lệnh có thể không được bảo vệ bản quyền.

* Tập lệnh eBPF (BPF mở rộng) tiếp tục là BSD

Vào năm 2014, tập lệnh BPF cổ điển đã được mở rộng đáng kể. Chúng tôi
thường gọi tập lệnh này là eBPF để phân biệt nó với cBPF.
Tập lệnh eBPF vẫn được cấp phép BSD.

Triển khai eBPF
=======================

Việc sử dụng tập lệnh eBPF yêu cầu triển khai mã trong cả không gian kernel
và không gian người dùng.

Trong hạt nhân Linux
---------------

Việc triển khai tham chiếu của trình thông dịch eBPF và các tính năng kịp thời khác nhau
trình biên dịch là một phần của Linux và được cấp phép GPLv2. Việc thực hiện
Các chức năng trợ giúp eBPF cũng được cấp phép GPLv2. Phiên dịch, JIT, người trợ giúp,
và trình xác minh được gọi là thời gian chạy eBPF.

Trong không gian người dùng
-------------

Ngoài ra còn có các triển khai thời gian chạy eBPF (trình thông dịch, JIT, trình trợ giúp
chức năng) dưới
Apache2 (ZZ0000ZZ
MIT (ZZ0001ZZ và
BSD (ZZ0002ZZ

trong CTNH
-----

CTNH có thể chọn thực thi lệnh eBPF nguyên bản và cung cấp thời gian chạy eBPF
trong CTNH hoặc thông qua việc sử dụng chương trình cơ sở triển khai có giấy phép độc quyền.

Trong các hệ điều hành khác
--------------------------

Các triển khai hạt nhân hoặc không gian người dùng khác của tập lệnh eBPF và thời gian chạy
có thể có giấy phép độc quyền.

Sử dụng các chương trình BPF trong nhân Linux
======================================

Hạt nhân Linux (trong khi là GPLv2) cho phép liên kết các mô-đun hạt nhân độc quyền
theo các quy tắc sau:
Tài liệu/quy trình/license-rules.rst

Khi một mô-đun hạt nhân được tải, hạt nhân linux sẽ kiểm tra xem nó hoạt động như thế nào
có ý định sử dụng. Nếu bất kỳ chức năng nào được đánh dấu là "Chỉ GPL", thì chức năng tương ứng
mô-đun hoặc chương trình phải có giấy phép tương thích GPL.

Tải chương trình BPF vào nhân Linux cũng tương tự như tải kernel
mô-đun. BPF được tải trong thời gian chạy và không được liên kết tĩnh với Linux
hạt nhân. Việc tải chương trình BPF tuân theo các quy tắc kiểm tra giấy phép tương tự như kernel
mô-đun. Các chương trình BPF có thể là độc quyền nếu chúng không sử dụng "GPL only" BPF
các chức năng trợ giúp.

Hơn nữa, một số loại chương trình BPF - Mô-đun bảo mật Linux (LSM) và TCP
Kiểm soát tắc nghẽn (struct_ops), kể từ tháng 8 năm 2021 - bắt buộc phải là GPL
tương thích ngay cả khi họ không sử dụng trực tiếp các chức năng trợ giúp "GPL". các
bước đăng ký mô-đun kiểm soát tắc nghẽn LSM và TCP của Linux
kernel được thực hiện thông qua các hàm kernel EXPORT_SYMBOL_GPL. Theo nghĩa đó LSM
và struct_ops Các chương trình BPF đang ngầm gọi các hàm "chỉ GPL".
Hạn chế tương tự áp dụng cho các chương trình BPF gọi hàm kernel
trực tiếp qua giao diện không ổn định còn được gọi là "kfunc".

Đóng gói các chương trình BPF với các ứng dụng không gian người dùng
====================================================

Nói chung, các ứng dụng được cấp phép độc quyền và các chương trình BPF được cấp phép GPL
được viết cho nhân Linux trong cùng một gói có thể cùng tồn tại vì chúng
các tiến trình thực thi riêng biệt. Điều này áp dụng cho cả chương trình cBPF và eBPF.
