.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/rust/arch-support.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Hỗ trợ vòm
============

Hiện tại, trình biên dịch Rust (ZZ0000ZZ) sử dụng LLVM để tạo mã,
điều này giới hạn các kiến trúc được hỗ trợ có thể được nhắm mục tiêu. Ngoài ra,
hỗ trợ xây dựng kernel với LLVM/Clang khác nhau (vui lòng xem
Tài liệu/kbuild/llvm.rst). Sự hỗ trợ này là cần thiết cho ZZ0001ZZ
sử dụng ZZ0002ZZ.

Dưới đây là bản tóm tắt chung về các kiến ​​trúc hiện đang hoạt động. Mức độ của
hỗ trợ tương ứng với các giá trị ZZ0000ZZ trong tệp ZZ0001ZZ.

============== ===================================================================
Kiến trúc Mức độ hỗ trợ Ràng buộc
============== ===================================================================
ZZ0000ZZ Chỉ duy trì ARMv7 Little Endian.
ZZ0001ZZ Chỉ duy trì Little Endian.
ZZ0002ZZ được duy trì \-
ZZ0003ZZ Chỉ duy trì ZZ0004ZZ và LLVM/Clang.
ZZ0005ZZ được duy trì \-
ZZ0006ZZ Chỉ duy trì ZZ0007ZZ.
============== ===================================================================
