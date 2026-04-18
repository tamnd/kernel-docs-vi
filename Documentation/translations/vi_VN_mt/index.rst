.. SPDX-License-Identifier: GPL-2.0

.. include:: ../disclaimer-vi.rst

:Original: Documentation/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _linux_doc:

=================================
Tài liệu hạt nhân Linux
==============================

Đây là cấp cao nhất của cây tài liệu của kernel.  hạt nhân
tài liệu, giống như bản thân hạt nhân, là một công việc đang được hoàn thiện;
điều đó đặc biệt đúng khi chúng tôi làm việc để tích hợp nhiều
các tài liệu thành một tổng thể mạch lạc.  Xin lưu ý rằng những cải tiến đối với
tài liệu đều được chào đón; tham gia danh sách linux-doc tại vger.kernel.org nếu
bạn muốn giúp đỡ.

Làm việc với cộng đồng phát triển
======================================

Các hướng dẫn cần thiết để tương tác với sự phát triển của kernel
cộng đồng và đưa công việc của bạn đi ngược dòng.

.. toctree::
   :maxdepth: 1

   Development process <process/development-process>
   Submitting patches <process/submitting-patches>
   Code of conduct <process/code-of-conduct>
   Maintainer handbook <maintainer/index>
   All development-process docs <process/index>


Hướng dẫn sử dụng API nội bộ
====================

Hướng dẫn sử dụng dành cho các nhà phát triển làm việc để giao tiếp với phần còn lại của
hạt nhân.

.. toctree::
   :maxdepth: 1

   Core API <core-api/index>
   Driver APIs <driver-api/index>
   Subsystems <subsystem-apis>
   Locking <locking/index>

Các công cụ và quy trình phát triển
===============================

Nhiều hướng dẫn khác với thông tin hữu ích cho tất cả các nhà phát triển kernel.

.. toctree::
   :maxdepth: 1

   Licensing rules <process/license-rules>
   Writing documentation <doc-guide/index>
   Development tools <dev-tools/index>
   Testing guide <dev-tools/testing-overview>
   Hacking guide <kernel-hacking/index>
   Tracing <trace/index>
   Fault injection <fault-injection/index>
   Livepatching <livepatch/index>
   Rust <rust/index>


Tài liệu hướng tới người dùng
===========================

Các hướng dẫn sau đây được viết cho *người dùng* của kernel — dành cho những người
cố gắng làm cho nó hoạt động tối ưu trên một hệ thống và ứng dụng nhất định
các nhà phát triển đang tìm kiếm thông tin về API không gian người dùng của kernel.

.. toctree::
   :maxdepth: 1

   Administration <admin-guide/index>
   Build system <kbuild/index>
   Reporting issues <admin-guide/reporting-issues.rst>
   Userspace tools <tools/index>
   Userspace API <userspace-api/index>

Xem thêm: `Linux man pages <https://www.kernel.org/doc/man-pages/>`_,
được giữ riêng biệt với tài liệu riêng của kernel.

Tài liệu liên quan đến phần mềm
==============================
Phần sau đây chứa thông tin về những kỳ vọng của kernel liên quan đến
phần mềm nền tảng.

.. toctree::
   :maxdepth: 1

   Firmware <firmware-guide/index>
   Firmware and Devicetree <devicetree/index>


Tài liệu dành riêng cho kiến ​​trúc
===================================

.. toctree::
   :maxdepth: 2

   CPU architectures <arch/index>


Tài liệu khác
===================

Có một số tài liệu chưa được sắp xếp dường như không phù hợp với các phần khác
của nội dung tài liệu hoặc có thể yêu cầu một số điều chỉnh và/hoặc chuyển đổi
sang định dạng ReStructuredText hoặc đơn giản là đã quá cũ.

.. toctree::
   :maxdepth: 1

   Unsorted documentation <staging/index>


Bản dịch
============

.. toctree::
   :maxdepth: 2

   Translations <translations/index>

Chỉ số và bảng
==================

* :ref:`genindex`