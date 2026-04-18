.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. raw:: latex

	\renewcommand\thesection*
	\renewcommand\thesubsection*

.. _process_index:

=================================================
Làm việc với cộng đồng phát triển kernel
=============================================

Vì vậy, bạn muốn trở thành một nhà phát triển nhân Linux?  Chào mừng!  Trong khi có rất nhiều
Để tìm hiểu về kernel theo nghĩa kỹ thuật, điều quan trọng là
để tìm hiểu về cách cộng đồng của chúng tôi hoạt động.  Đọc những tài liệu này sẽ làm
bạn sẽ dễ dàng hợp nhất các thay đổi của mình với mức tối thiểu là
rắc rối.

Giới thiệu về cách phát triển kernel
-----------------------------------------------

Đọc những tài liệu này trước: sự hiểu biết về tài liệu ở đây sẽ dễ dàng hơn
sự gia nhập của bạn vào cộng đồng hạt nhân.

.. toctree::
   :maxdepth: 1

   howto
   development-process
   submitting-patches
   submit-checklist

Công cụ và hướng dẫn kỹ thuật dành cho nhà phát triển kernel
------------------------------------------------

Đây là bộ sưu tập tài liệu mà các nhà phát triển kernel phải quen thuộc
với.

.. toctree::
   :maxdepth: 1

   changes
   programming-language
   coding-style
   maintainer-pgp-guide
   email-clients
   applying-patches
   backporting
   adding-syscalls
   volatile-considered-harmful
   botching-up-ioctls

Hướng dẫn chính sách và tuyên bố của nhà phát triển
--------------------------------------

Đây là những quy tắc mà chúng tôi cố gắng tuân thủ trong cộng đồng hạt nhân (và
xa hơn).

.. toctree::
   :maxdepth: 1

   license-rules
   code-of-conduct
   code-of-conduct-interpretation
   contribution-maturity-model
   kernel-enforcement-statement
   kernel-driver-statement
   stable-api-nonsense
   stable-kernel-rules
   management-style
   researcher-guidelines
   generated-content
   coding-assistants
   conclave

Xử lý lỗi
-----------------

Lỗi là một thực tế của cuộc sống; điều quan trọng là chúng ta xử lý chúng đúng cách. các
các tài liệu dưới đây cung cấp lời khuyên chung về cách gỡ lỗi và mô tả
các chính sách xung quanh việc xử lý một số loại lỗi đặc biệt:
hồi quy và các vấn đề bảo mật.

.. toctree::
   :maxdepth: 1

   debugging/index
   handling-regressions
   security-bugs
   cve
   embargoed-hardware-issues

Thông tin người bảo trì
----------------------

Làm thế nào để tìm thấy những người sẽ chấp nhận các bản vá lỗi của bạn.

.. toctree::
   :maxdepth: 1

   maintainer-handbooks
   maintainers

Vật liệu khác
--------------

Dưới đây là một số hướng dẫn khác dành cho cộng đồng được nhiều người quan tâm nhất
nhà phát triển:

.. toctree::
   :maxdepth: 1

   kernel-docs
   deprecated
