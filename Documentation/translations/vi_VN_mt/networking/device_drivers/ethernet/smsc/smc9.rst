.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/smsc/smc9.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================
Trình điều khiển SMC 9xxxx
================

Bản sửa đổi 0.12

5/3/96

Bản quyền 1996 Erik Stahlman

Được phát hành theo các điều khoản của Giấy phép Công cộng GNU.

Tệp này chứa các hướng dẫn và cảnh báo dành cho trình điều khiển SMC9xxx của tôi.  bạn
không nên sử dụng driver mà không đọc file này.

Những điều cần lưu ý khi cài đặt:

1. Trình điều khiển phải hoạt động trên tất cả các hạt nhân từ 1.2.13 đến 1.3.71.
     (Bản vá kernel được cung cấp cho 1.3.71)

2. Nếu bạn đưa phần này vào kernel, bạn có thể cần thay đổi một số
     các tùy chọn, chẳng hạn như để buộc IRQ.


3. Để biên dịch dưới dạng mô-đun, hãy chạy 'make'.
      Make sẽ cung cấp cho bạn các tùy chọn thích hợp để hỗ trợ kernel khác nhau.

4. Đang tải trình điều khiển dưới dạng mô-đun::

sử dụng: insmod smc9194.o
	thông số tùy chọn:
		io=xxxx : địa chỉ cơ sở của bạn
		irq=xx : irq của bạn
		ifport=x : 0 cho bất kỳ giá trị mặc định nào
				1 cho cặp xoắn
				2 cho AUI (hoặc BNC trên một số thẻ)

Làm thế nào để có được phiên bản mới nhất?

FTP:
	ftp://fenris.campus.vt.edu/smc9/smc9-12.tar.gz
	ftp://sfbox.vt.edu/filebox/F/fenris/smc9/smc9-12.tar.gz


Liên hệ với tôi:
    erik@mail.vt.edu