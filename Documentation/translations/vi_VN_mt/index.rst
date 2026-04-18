.. SPDX-License-Identifier: GPL-2.0

.. include:: ../disclaimer-vi.rst

:Original: Documentation/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _linux_doc:

========================
Tài liệu hạt nhân Linux
========================

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

   Quá trình phát triển <process/development-process>
   Gửi bản vá <process/submitting-patches>
   Quy tắc ứng xử <process/code-of-conduct>
   Sổ tay bảo trì <maintainer/index>
   Tất cả tài liệu về quá trình phát triển <process/index>


Hướng dẫn sử dụng API nội bộ
====================

Hướng dẫn sử dụng dành cho các nhà phát triển làm việc để giao tiếp với phần còn lại của
hạt nhân.

.. toctree::
   :maxdepth: 1

   API cốt lõi <core-api/index>
   API trình điều khiển <driver-api/index>
   Hệ thống con <subsystem-apis>
   Khóa <locking/index>

Các công cụ và quy trình phát triển
===============================

Nhiều hướng dẫn khác với thông tin hữu ích cho tất cả các nhà phát triển kernel.

.. toctree::
   :maxdepth: 1

   Quy định cấp phép <process/license-rules>
   Viết tài liệu <doc-guide/index>
   Công cụ phát triển <dev-tools/index>
   Hướng dẫn kiểm tra <dev-tools/testing-overview>
   Hướng dẫn hack <kernel-hacking/index>
   Truy tìm <trace/index>
   tiêm lỗi <fault-injection/index>
   Livepatching <livepatch/index>
   rỉ sét <rust/index>


Tài liệu hướng tới người dùng
===========================

Các hướng dẫn sau đây được viết cho *người dùng* của kernel — dành cho những người
cố gắng làm cho nó hoạt động tối ưu trên một hệ thống và ứng dụng nhất định
các nhà phát triển đang tìm kiếm thông tin về API không gian người dùng của kernel.

.. toctree::
   :maxdepth: 1

   Quản trị <admin-guide/index>
   Xây dựng hệ thống <kbuild/index>
   Vấn đề báo cáo <admin-guide/reporting-issues.rst>
   Công cụ không gian người dùng <tools/index>
   API không gian người dùng <userspace-api/index>

Xem thêm: `Linux man pages <https://www.kernel.org/doc/man-pages/>`_,
được giữ riêng biệt với tài liệu riêng của kernel.

Tài liệu liên quan đến phần mềm
==============================
Phần sau đây chứa thông tin về những kỳ vọng của kernel liên quan đến
phần mềm nền tảng.

.. toctree::
   :maxdepth: 1

   Phần sụn <firmware-guide/index>
   Phần sụn và cây thiết bị <devicetree/index>


Tài liệu dành riêng cho kiến ​​trúc
===================================

.. toctree::
   :maxdepth: 2

   Kiến trúc CPU <arch/index>


Tài liệu khác
===================

Có một số tài liệu chưa được sắp xếp dường như không phù hợp với các phần khác
của nội dung tài liệu hoặc có thể yêu cầu một số điều chỉnh và/hoặc chuyển đổi
sang định dạng ReStructuredText hoặc đơn giản là đã quá cũ.

.. toctree::
   :maxdepth: 1

   Tài liệu chưa được sắp xếp <staging/index>


Bản dịch
============

.. toctree::
   :maxdepth: 2

   Bản dịch <translations/index>

Chỉ số và bảng
==================

* :ref:`genindex`
