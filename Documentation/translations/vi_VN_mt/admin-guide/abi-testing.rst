.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/abi-testing.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Ký hiệu thử nghiệm ABI
===================

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