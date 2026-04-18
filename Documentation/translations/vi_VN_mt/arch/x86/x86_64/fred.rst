.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/x86_64/fred.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================================
Trả hàng và phân phối sự kiện linh hoạt (FRED)
==============================================

Tổng quan
=========

Kiến trúc FRED xác định các chuyển đổi mới đơn giản thay đổi
mức độ đặc quyền (chuyển tiếp vòng). Kiến trúc FRED là
được thiết kế với mục tiêu sau:

1) Cải thiện hiệu suất tổng thể và thời gian phản hồi bằng cách thay thế sự kiện
   phân phối thông qua bảng mô tả ngắt (sự kiện IDT
   phân phối) và trả về sự kiện bằng lệnh IRET với mức thấp hơn
   chuyển đổi độ trễ.

2) Cải thiện độ bền của phần mềm bằng cách đảm bảo rằng việc phân phối sự kiện
   thiết lập bối cảnh giám sát đầy đủ và sự kiện đó quay trở lại
   thiết lập bối cảnh người dùng đầy đủ.

Các chuyển tiếp mới được xác định bởi kiến trúc FRED là sự kiện FRED
giao hàng và để trở về từ các sự kiện, hai hướng dẫn trả lại FRED.
Việc phân phối sự kiện FRED có thể thực hiện chuyển đổi từ vòng 3 sang vòng 0, nhưng
nó cũng được sử dụng để chuyển các sự kiện tới vòng 0. Một FRED
lệnh (ERETU) thực hiện quay trở lại từ vòng 0 đến vòng 3, trong khi
khác (ERETS) quay trở lại khi vẫn ở vòng 0. Nói chung, FRED
phân phối sự kiện và hướng dẫn trả lại FRED là các chuyển đổi FRED.

Ngoài những chuyển đổi này, kiến trúc FRED còn xác định một giao diện mới
lệnh (LKGS) để quản lý trạng thái của thanh ghi phân đoạn GS.
Lệnh LKGS có thể được sử dụng bởi các hệ điều hành 64-bit
không sử dụng chuyển tiếp FRED mới.

Hơn nữa, kiến trúc FRED dễ dàng mở rộng cho CPU trong tương lai
kiến trúc.

Gửi sự kiện dựa trên phần mềm
================================

FRED hoạt động khác với IDT về cách xử lý sự kiện. Thay vào đó
gửi trực tiếp một sự kiện tới người xử lý nó dựa trên sự kiện đó
vector, FRED yêu cầu phần mềm gửi một sự kiện tới trình xử lý của nó
dựa trên cả loại sự kiện và vectơ. Vì vậy, một công văn sự kiện
framework phải được triển khai để tạo điều kiện thuận lợi cho người xử lý sự kiện
quá trình gửi đi. Khung điều phối sự kiện FRED nắm quyền kiểm soát
sau khi một sự kiện được gửi và sử dụng công văn hai cấp.

Việc điều phối cấp độ đầu tiên dựa trên loại sự kiện và cấp độ thứ hai
việc gửi đi dựa trên vector sự kiện.

Bối cảnh giám sát/người dùng đầy đủ
===================================

Phân phối sự kiện FRED lưu và khôi phục toàn bộ người giám sát/người dùng
bối cảnh khi phân phối và trả lại sự kiện. Vì vậy nó tránh được vấn đề
trạng thái nhất thời do %cr2 và/hoặc %dr6 và không còn cần thiết nữa
để xử lý tất cả các trường hợp góc xấu do trạng thái nhập cảnh chưa hoàn thiện gây ra.

FRED cho phép bỏ chặn NMI rõ ràng với hướng dẫn trả lại sự kiện mới
ERETS/ERETU, tránh tình trạng lộn xộn do IRET gây ra một cách vô điều kiện
bỏ chặn NMI, ví dụ: khi có ngoại lệ xảy ra trong quá trình xử lý NMI.

FRED luôn khôi phục toàn bộ giá trị của %rsp, do đó ESPFIX không còn
cần thiết khi FRED được kích hoạt.

LKGS
====

LKGS hoạt động giống như lệnh MOV tới GS ngoại trừ việc nó tải
địa chỉ cơ sở vào IA32_KERNEL_GS_BASE MSR thay vì GS
bộ nhớ đệm mô tả của phân đoạn. Với LKGS, nó sẽ tránh được
làm việc với kernel GS, tức là một hệ điều hành luôn có thể hoạt động
với địa chỉ cơ sở GS của chính nó.

Bởi vì việc phân phối sự kiện FRED từ vòng 3 và ERETU đều hoán đổi giá trị
của địa chỉ cơ sở GS và địa chỉ của IA32_KERNEL_GS_BASE MSR, cộng thêm
việc giới thiệu lệnh LKGS, lệnh SWAPGS là không
cần thiết lâu hơn khi FRED được bật, do đó không được phép (#UD).

Cấp độ ngăn xếp
===============

4 cấp độ ngăn xếp 0~3 được giới thiệu để thay thế IST không tái nhập cho
xử lý sự kiện và mỗi cấp độ ngăn xếp phải được cấu hình để sử dụng một
ngăn xếp chuyên dụng.

Mức ngăn xếp hiện tại có thể không thay đổi hoặc tăng cao hơn trên FRED
giao hàng sự kiện. Nếu không thay đổi, CPU tiếp tục sử dụng sự kiện hiện tại
ngăn xếp. Nếu cao hơn, CPU chuyển sang ngăn xếp sự kiện mới được chỉ định bởi
MSR của cấp độ ngăn xếp mới, tức là MSR_IA32_FRED_RSP[123].

Chỉ thực hiện lệnh trả về FRED ERET[US] mới có thể hạ thấp
mức ngăn xếp hiện tại, khiến CPU chuyển trở lại ngăn xếp cũ
bật trước khi phân phối sự kiện trước đó đã nâng cấp cấp độ ngăn xếp.