.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/security/tpm/tpm_ftpm_tee.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================================================
Phần mềm điều khiển TPM
=============================================

Tài liệu này mô tả chương trình cơ sở Mô-đun nền tảng đáng tin cậy (fTPM)
trình điều khiển thiết bị.

Giới thiệu
============

Trình điều khiển này là một bản nâng cấp cho chương trình cơ sở được triển khai trong TrustZone của ARM
môi trường. Trình điều khiển cho phép các chương trình tương tác với TPM trong cùng một
cách họ tương tác với phần cứng TPM.

Thiết kế
======

Trình điều khiển hoạt động như một lớp mỏng truyền lệnh đến và đi từ TPM
được thực hiện trong phần sụn. Bản thân trình điều khiển không chứa nhiều logic và
được sử dụng giống như một đường ống câm giữa phần sụn và kernel/không gian người dùng.

Bản thân phần sụn dựa trên bài viết sau:
ZZ0000ZZ

Khi trình điều khiển được tải, nó sẽ hiển thị các thiết bị ký tự ZZ0000ZZ
không gian người dùng sẽ cho phép không gian người dùng giao tiếp với phần sụn TPM
thông qua thiết bị này.
