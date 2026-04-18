.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/scsi-generic.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Trình điều khiển chung SCSI (sg)
================================

20020126

Giới thiệu
============
Driver SCSI Generic (sg) là một trong 4 thiết bị SCSI “cao cấp”
trình điều khiển cùng với sd, st và sr (đĩa, băng và CD-ROM tương ứng). Sg
mang tính tổng quát hơn (nhưng ở mức độ thấp hơn) so với các anh chị em của nó và có xu hướng
được sử dụng trên các thiết bị SCSI không phù hợp với các danh mục đã được bảo trì.
Vì vậy sg được sử dụng cho máy quét, ghi CD và đọc đĩa CD âm thanh kỹ thuật số
trong số những thứ khác.

Thay vì ghi lại giao diện của trình điều khiển ở đây, thông tin phiên bản
được cung cấp cùng với các con trỏ (tức là URL) nơi tìm tài liệu
và các ví dụ.


Các phiên bản chính của trình điều khiển sg
===============================
Có ba phiên bản chính của sg được tìm thấy trong nhân Linux (lk):
      - sg phiên bản 1 (bản gốc) từ năm 1992 đến đầu năm 1999 (lk 2.2.5).
	Nó dựa trên cấu trúc giao diện sg_header.
      - sg phiên bản 2 từ lk 2.2.6 trong dòng 2.2. Nó dựa trên
	một phiên bản mở rộng của cấu trúc giao diện sg_header.
      - sg phiên bản 3 được tìm thấy trong dòng lk 2.4 (và dòng lk 2.5).
	Nó bổ sung thêm cấu trúc giao diện sg_io_hdr.


Tài liệu lái xe SG
=======================
Tài liệu mới nhất của trình điều khiển sg được lưu giữ tại

-ZZ0000ZZ

Phần này mô tả trình điều khiển sg phiên bản 3 được tìm thấy trong dòng lk 2.4.

Tài liệu (phiên bản lớn) cho trình điều khiển sg phiên bản 2 được tìm thấy trong
Dòng lk 2.2 có thể được tìm thấy tại

-ZZ0000ZZ

Tài liệu gốc cho trình điều khiển sg (trước lk 2.2.6) có thể là
được tìm thấy trong kho lưu trữ LDP tại

-ZZ0000ZZ

Mô tả tổng quát hơn về hệ thống con Linux SCSI trong đó sg là một
một phần có thể được tìm thấy tại ZZ0000ZZ.


Mã ví dụ và tiện ích
==========================
Có hai gói tiện ích sg:

========================================================================
    sg3_utils cho trình điều khiển sg phiên bản 3 được tìm thấy trong lk 2.4
    sg_utils cho trình điều khiển sg phiên bản 2 (và bản gốc) được tìm thấy trong lk 2.2
                và trước đó
    ========================================================================

Cả hai gói sẽ hoạt động trong dòng lk 2.4. Tuy nhiên, sg3_utils cung cấp nhiều hơn
khả năng. Chúng có thể được tìm thấy tại: ZZ0000ZZ và
freecode.com

Một cách tiếp cận khác là xem xét các ứng dụng sử dụng trình điều khiển sg.
Chúng bao gồm cdrecord, cdparanoia, SANE và cdrdao.


Ánh xạ các phiên bản nhân Linux sang các phiên bản trình điều khiển sg
======================================================
Dưới đây là danh sách các nhân Linux dòng 2.4 đã có phiên bản mới
của tài xế sg:

- lk 2.4.0 : sg phiên bản 3.1.17
     - lk 2.4.7 : sg phiên bản 3.1.19
     - lk 2.4.10 : sg phiên bản 3.1.20 [#]_
     - lk 2.4.17 : sg phiên bản 3.1.22

.. [#] There were 3 changes to sg version 3.1.20 by third parties in the
       next six Linux kernel versions.

Để tham khảo, đây là danh sách các nhân Linux trong dòng 2.2 đã có
phiên bản mới của trình điều khiển sg:

- lk 2.2.0 : phiên bản sg gốc [không có số phiên bản]
     - lk 2.2.6 : sg phiên bản 2.1.31
     - lk 2.2.8 : sg phiên bản 2.1.32
     - lk 2.2.10 : sg phiên bản 2.1.34 [SG_GET_VERSION_NUM ioctl xuất hiện lần đầu]
     - lk 2.2.14 : sg phiên bản 2.1.36
     - lk 2.2.16 : sg phiên bản 2.1.38
     - lk 2.2.17 : sg phiên bản 2.1.39
     - lk 2.2.20 : sg phiên bản 2.1.40

Chuỗi phát triển lk 2.5 hiện có phiên bản sg 3.5.23
có chức năng tương đương với phiên bản sg 3.1.22 được tìm thấy trong lk 2.4.17.


Douglas Gilbert

26 tháng 1 năm 2002

dgilbert@interlog.com