.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/xtensa/booting.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
Truyền tham số khởi động cho kernel
========================================

Các tham số khởi động được biểu diễn dưới dạng danh sách TLV trong bộ nhớ. Xin vui lòng xem
Arch/xtensa/include/asm/bootparam.h để biết định nghĩa về cấu trúc bp_tag và
hằng số giá trị thẻ. Mục đầu tiên trong danh sách phải có loại BP_TAG_FIRST, cuối cùng
mục nhập phải có loại BP_TAG_LAST. Địa chỉ của mục danh sách đầu tiên là
được chuyển đến kernel trong thanh ghi a2. Loại địa chỉ phụ thuộc vào loại MMU:

- Đối với các cấu hình không có MMU, có bảo vệ vùng hoặc có MPU,
  địa chỉ phải là địa chỉ vật lý.
- Đối với các cấu hình có bản dịch vùng MMU hoặc với MMUv3 và CONFIG_MMU=n
  the address must be a valid address in the current mapping. Hạt nhân sẽ
  không tự thay đổi ánh xạ.
- Đối với cấu hình có MMUv2, địa chỉ phải là địa chỉ ảo trong
  ánh xạ ảo mặc định (0xd0000000..0xffffffff).
- Đối với các cấu hình có MMUv3 và CONFIG_MMU=y, địa chỉ có thể là
  địa chỉ ảo hoặc vật lý. Trong cả hai trường hợp, nó phải nằm trong giá trị mặc định
  bản đồ ảo. Nó được coi là vật lý nếu nó nằm trong phạm vi
  địa chỉ vật lý được bao phủ bởi ánh xạ KSEG mặc định (XCHAL_KSEG_PADDR..
  XCHAL_KSEG_PADDR + XCHAL_KSEG_SIZE), nếu không nó được coi là ảo.
