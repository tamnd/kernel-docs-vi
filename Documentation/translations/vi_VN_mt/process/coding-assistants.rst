.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/coding-assistants.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _coding_assistants:

Trợ lý mã hóa AI
++++++++++++++++++++

Tài liệu này cung cấp hướng dẫn cho các công cụ AI và nhà phát triển sử dụng AI
hỗ trợ khi đóng góp cho nhân Linux.

Các công cụ AI giúp phát triển nhân Linux phải tuân theo tiêu chuẩn
Quá trình phát triển hạt nhân:

* Tài liệu/quy trình/phát triển-process.rst
* Tài liệu/quy trình/coding-style.rst
* Tài liệu/quy trình/gửi-patches.rst

Yêu cầu cấp phép và pháp lý
================================

Mọi đóng góp phải tuân thủ các yêu cầu cấp phép của kernel:

* Tất cả mã phải tương thích với GPL-2.0-only
* Sử dụng số nhận dạng giấy phép SPDX thích hợp
* Xem Tài liệu/quy trình/license-rules.rst để biết chi tiết

Giấy chứng nhận xuất xứ của nhà phát triển và được ký bởi nhà phát triển
=================================================

Tác nhân AI MUST NOT thêm thẻ Đã đăng xuất. Chỉ có con người mới có thể hợp pháp
chứng nhận Giấy chứng nhận xuất xứ của nhà phát triển (DCO). Người nộp đơn là con người
chịu trách nhiệm về:

* Xem lại tất cả mã do AI tạo
* Đảm bảo tuân thủ các yêu cầu cấp phép
* Thêm thẻ Signed-off-by của riêng họ để chứng nhận DCO
* Chịu trách nhiệm hoàn toàn về đóng góp

Ghi công
===========

Khi các công cụ AI đóng góp vào việc phát triển hạt nhân, việc phân bổ hợp lý
giúp theo dõi vai trò ngày càng phát triển của AI trong quá trình phát triển.
Đóng góp phải bao gồm thẻ Được hỗ trợ theo định dạng sau::

Được hỗ trợ bởi: AGENT_NAME:MODEL_VERSION [TOOL1] [TOOL2]

Ở đâu:

* ZZ0000ZZ là tên của công cụ hoặc framework AI
* ZZ0001ZZ là phiên bản model cụ thể được sử dụng
* ZZ0002ZZ là công cụ phân tích chuyên dụng tùy chọn được sử dụng
  (ví dụ: coccinelle, thưa thớt, smatch, clang-tidy)

Không nên liệt kê các công cụ phát triển cơ bản (git, gcc, make, editor).

Ví dụ::

Hỗ trợ bởi: Claude:claude-3-opus coccinelle thưa thớt