.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/security/tpm/tpm_event_log.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Nhật ký sự kiện TPM
===================

Tài liệu này mô tả ngắn gọn nhật ký TPM là gì và nó được chuyển giao như thế nào
từ phần sụn preboot sang hệ điều hành.

Giới thiệu
============

Phần sụn preboot duy trì một bản ghi sự kiện nhận các mục mới mỗi lần
thời điểm thứ gì đó được băm vào bất kỳ thanh ghi PCR nào. Các sự kiện
được phân tách theo loại của chúng và chứa giá trị của PCR được băm
đăng ký. Thông thường, phần sụn preboot sẽ băm các thành phần thành
người thực thi sẽ được bàn giao hoặc các hành động liên quan đến việc khởi động
quá trình.

Ứng dụng chính cho việc này là chứng thực từ xa và lý do tại sao
nó rất hữu ích khi được đặt ngay trong phần đầu tiên của [1]:

"Chứng thực được sử dụng để cung cấp thông tin về trạng thái của nền tảng
tới một kẻ thách thức. Tuy nhiên, nội dung PCR rất khó diễn giải;
do đó, việc chứng thực thường hữu ích hơn khi nội dung PCR
kèm theo nhật ký đo lường. Mặc dù bản thân họ không được tin cậy,
nhật ký đo lường chứa tập hợp thông tin phong phú hơn PCR
nội dung. Nội dung PCR được sử dụng để cung cấp xác thực
nhật ký đo lường."

Nhật ký sự kiện UEFI
==============

Nhật ký sự kiện do UEFI cung cấp có một số điểm kỳ quặc.

Trước khi gọi ExitBootServices() Linux EFI stub sao chép nhật ký sự kiện vào
một bảng cấu hình tùy chỉnh được xác định bởi chính sơ khai. Thật không may,
các sự kiện được tạo bởi ExitBootServices() không có trong bảng.

Phần sụn cung cấp cái gọi là bảng cấu hình sự kiện cuối cùng để sắp xếp
ra vấn đề này. Các sự kiện được phản ánh vào bảng này sau lần đầu tiên
EFI_TCG2_PROTOCOL.GetEventLog() được gọi.

Điều này gây ra một vấn đề khác: không có gì đảm bảo rằng nó không được gọi
trước khi sơ khai Linux EFI được chạy. Vì vậy cần phải tính toán và lưu
kích thước bảng sự kiện cuối cùng trong khi sơ khai vẫn đang chạy theo tùy chỉnh
bảng cấu hình để trình điều khiển TPM sau này có thể bỏ qua các sự kiện này khi
nối hai nửa nhật ký sự kiện từ bảng cấu hình tùy chỉnh
và bảng sự kiện cuối cùng.

Tài liệu tham khảo
==========

- [1] ZZ0000ZZ
- [2] Việc nối cuối cùng được thực hiện trong driver/char/tpm/eventlog/efi.c