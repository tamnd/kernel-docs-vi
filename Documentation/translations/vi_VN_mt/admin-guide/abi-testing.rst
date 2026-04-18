.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/abi-testing.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Ký hiệu thử nghiệm ABI
======================

Giao diện tài liệu được coi là ổn định,
vì quá trình phát triển chính của giao diện này đã được hoàn thành.

Giao diện có thể được thay đổi để thêm các tính năng mới, nhưng
giao diện hiện tại sẽ không bị hỏng khi làm điều này, trừ khi nghiêm trọng
lỗi hoặc vấn đề bảo mật được tìm thấy trong đó.

Các chương trình không gian người dùng có thể bắt đầu dựa vào các giao diện này, nhưng chúng phải
lưu ý những thay đổi có thể xảy ra trước khi các giao diện này chuyển sang
được đánh dấu là ổn định.

Các chương trình sử dụng các giao diện này được khuyến khích bổ sung thêm
đặt tên cho mô tả của các giao diện này, sao cho kernel
nhà phát triển có thể dễ dàng thông báo cho họ nếu có bất kỳ thay đổi nào xảy ra.

.. kernel-abi:: testing
   :no-files: