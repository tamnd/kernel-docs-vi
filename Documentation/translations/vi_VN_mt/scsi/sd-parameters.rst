.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/sd-parameters.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================================
Thông số trình điều khiển đĩa (sd) Linux SCSI
======================================

bộ đệm_type (RW)
---------------
Bật/tắt bộ đệm ghi và đọc ổ đĩa.

============================ === === === ======================
 cache_type string WCE RCD Ghi bộ đệm Đọc bộ đệm
============================ === === === ======================
 viết qua 0 0 tắt bật
 không có 0 1 tắt
 viết lại 1 0 vào trên
 viết lại, không đọc (ngớ ngẩn) 1 1 bật tắt
============================ === === === ======================

Để đặt loại bộ nhớ đệm thành "ghi lại" và lưu cài đặt này vào ổ đĩa::

# echo "ghi lại" > cache_type

Để sửa đổi chế độ bộ đệm mà không thực hiện thay đổi liên tục, hãy thêm vào trước
"tạm thời" vào chuỗi loại bộ đệm. Ví dụ.::

# echo "ghi lại tạm thời" > cache_type