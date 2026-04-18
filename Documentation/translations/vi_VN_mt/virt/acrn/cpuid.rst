.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/virt/acrn/cpuid.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
Các bit ACRN CPUID
===============

Một VM khách chạy trên bộ ảo hóa ACRN có thể kiểm tra một số tính năng của nó bằng cách sử dụng
CPUID.

Các chức năng cpuid của ACRN là:

chức năng: 0x40000000

trả về::

eax = 0x40000010
   ebx = 0x4e524341
   ecx = 0x4e524341
   edx = 0x4e524341

Lưu ý rằng giá trị này trong ebx, ecx và edx tương ứng với chuỗi
"ACRNACRNACRN". Giá trị trong eax tương ứng với hàm cpuid tối đa
có trong trang này và sẽ được cập nhật nếu có thêm nhiều chức năng hơn trong trang này.
tương lai.

chức năng: xác định ACRN_CPUID_FEATURES (0x40000001)

trả về::

ebx, ecx, edx
          eax = một nhóm OR'ed của (cờ 1 <<)

trong đó ZZ0000ZZ được định nghĩa như sau:

================================== ============ ====================================
ý nghĩa giá trị cờ
================================== ============ ====================================
ACRN_FEATURE_PRIVILEGED_VM 0 VM khách là VM đặc quyền
================================== ============ ====================================

chức năng: 0x40000010

trả về::

ebx, ecx, edx
          eax = (Ảo) tần số TSC tính bằng kHz.