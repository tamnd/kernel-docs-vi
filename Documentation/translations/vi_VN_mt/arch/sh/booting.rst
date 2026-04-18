.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/sh/booting.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Khởi động DeviceTree
--------------------

Bộ tải khởi động SH tương thích với cây thiết bị được kỳ vọng sẽ cung cấp khả năng vật lý
  địa chỉ của blob cây thiết bị trong r4. Vì bộ tải khởi động kế thừa không
  đảm bảo mọi trạng thái đăng ký ban đầu cụ thể, các hạt nhân được xây dựng để
  tương tác với các bộ tải khởi động cũ phải sử dụng DTB tích hợp hoặc
  chọn tùy chọn bảng kế thừa (thứ gì đó không phải là CONFIG_SH_DEVICE_TREE)
  không sử dụng cây thiết bị. Hỗ trợ cho cái sau đang bị loại bỏ
  ủng hộ cây thiết bị.