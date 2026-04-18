.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/devicetree/dynamic-resolution-notes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============================================
Ghi chú của Trình giải quyết động Devicetree
============================================

Tài liệu này mô tả việc triển khai trong kernel
Trình phân giải DeviceTree, nằm trong driver/of/resolver.c

Cách trình phân giải hoạt động
------------------------------

Trình phân giải được đưa ra dưới dạng đầu vào là một cây tùy ý được biên dịch bằng
tùy chọn dtc thích hợp và có thẻ /plugin/. Điều này tạo ra
các nút __fixups__ & __local_fixups__ thích hợp.

Theo trình tự, trình phân giải hoạt động theo các bước sau:

1. Lấy giá trị phân nhánh cây thiết bị tối đa từ cây trực tiếp + 1.
2. Điều chỉnh tất cả các nhánh cục bộ của cây để giải quyết theo lượng đó.
3. Sử dụng thông tin nút __local__fixups__ điều chỉnh tất cả các tham chiếu cục bộ
   với số tiền như nhau.
4. Đối với mỗi thuộc tính trong nút __fixups__, hãy xác định vị trí nút mà nó tham chiếu
   trong cây sống. Đây là nhãn được sử dụng để gắn thẻ nút.
5. Lấy lại phần đích của bản sửa lỗi.
6. Đối với mỗi bản sửa lỗi trong thuộc tính, hãy xác định vị trí nút:property:offset
   và thay thế nó bằng giá trị phandle.