.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/ioctl/ioctl-decoding.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================
Giải mã số ma thuật IOCTL
=================================

Để giải mã mã hex IOCTL:

Hầu hết các kiến trúc đều sử dụng định dạng chung này, nhưng hãy kiểm tra
bao gồm/ARCH/ioctl.h để biết thông tin cụ thể, ví dụ: máy tính điện
sử dụng 3 bit để mã hóa đọc/ghi và 13 bit cho kích thước.

====== =====================================
 ý nghĩa bit
 ====== =====================================
 31-30 00 - không có tham số: sử dụng macro _IO
	10 - đọc: _IOR
	01 - viết: _IOW
	11 - đọc/ghi: _IOWR

kích thước 29-16 của đối số

Ký tự ascii 15-8 được cho là
	duy nhất cho mỗi người lái xe

Hàm 7-0 #
 ====== =====================================


Vì vậy, ví dụ 0x82187201 là giá trị đọc có độ dài arg là 0x218,
ký tự 'r' chức năng 1. Việc cắt nguồn cho thấy đây là ::

#define VFAT_IOCTL_READDIR_BOTH _IOR('r', 1, struct dirent [2])
