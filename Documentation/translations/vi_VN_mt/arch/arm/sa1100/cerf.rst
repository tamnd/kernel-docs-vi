.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/sa1100/cerf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================
CerfBoard/khối lập phương
==============

ZZ0001ZZ

Intrinsyc CerfBoard là máy tính dựa trên StrongARM 1110 trên bo mạch
có kích thước khoảng 2" vuông. Nó bao gồm một cổng Ethernet
bộ điều khiển, cổng nối tiếp tương thích RS232, cổng chức năng USB và
một khe cắm CompactFlash+ ở mặt sau. Hình ảnh có thể được tìm thấy tại
Trang web Intrinsyc, ZZ0000ZZ

Tài liệu này mô tả sự hỗ trợ trong nhân Linux cho
Intrinsyc CerfBoard.

Được hỗ trợ trong phiên bản này
=========================

- Khe cắm CompactFlash+ (chọn PCMCIA trong Cài đặt chung và bất kỳ tùy chọn nào
     điều đó có thể được yêu cầu)
   - Bộ điều khiển Ethernet Crystal CS8900 trên bo mạch (hỗ trợ Cerf CS8900A trong
     Thiết bị mạng)
   - Cổng nối tiếp với bảng điều khiển nối tiếp (được mã hóa cứng thành 38400 8N1)

Để đưa hạt nhân này vào Cerf của bạn, bạn cần có một máy chủ chạy
cả BOOTP và TFTP. Hướng dẫn chi tiết nên có kèm theo của bạn
bộ đánh giá về cách sử dụng bootloader. Chuỗi lệnh này
sẽ đủ::

tạo ARCH=arm CROSS_COMPILE=arm-linux-cerfcube_defconfig
   tạo ARCH=arm CROSS_COMPILE=arm-linux- zImage
   tạo ARCH=arm CROSS_COMPILE=arm-linux- mô-đun
   cp Arch/arm/boot/zImage <thư mục TFTP>

support@intrinsyc.com
