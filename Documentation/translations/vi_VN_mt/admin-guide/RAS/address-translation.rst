.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/RAS/address-translation.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Dịch địa chỉ
===================

x86 AMD
-------

Các hệ thống AMD dựa trên Zen bao gồm Cấu trúc dữ liệu quản lý bố cục của
bộ nhớ vật lý. Các thiết bị được gắn vào Fabric, như bộ điều khiển bộ nhớ,
I/O, v.v., có thể không có chế độ xem đầy đủ về bản đồ bộ nhớ vật lý của hệ thống.
Các thiết bị này có thể cung cấp địa chỉ vật lý, địa chỉ "chuẩn hóa" của thiết bị
khi báo cáo lỗi bộ nhớ. Địa chỉ chuẩn hóa phải được dịch sang
một địa chỉ vật lý hệ thống để kernel hoạt động trên bộ nhớ.

Thư viện dịch địa chỉ AMD (CONFIG_AMD_ATL) cung cấp bản dịch cho
trường hợp này.

Bảng chú giải các từ viết tắt được sử dụng trong dịch địa chỉ cho các hệ thống dựa trên Zen

* CCM = Người điều hành kết hợp bộ đệm
* COD = Cụm trên khuôn
* COH_ST = Trạm kết hợp
* DF = Cấu trúc dữ liệu