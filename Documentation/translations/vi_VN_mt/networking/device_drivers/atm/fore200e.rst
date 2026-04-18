.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/atm/fore200e.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================================
Trình điều khiển FORE Hệ thống PCA-200E/SBA-200E ATM NIC
=============================================

Trình điều khiển này bổ sung hỗ trợ cho bộ điều hợp ATM FORE Systems 200E-series
sang hệ điều hành Linux. Nó dựa trên trình điều khiển PCA-200E trước đó
được viết bởi Uwe Dannowski.

Trình điều khiển đồng thời hỗ trợ bộ điều hợp PCA-200E và SBA-200E trên
i386, alpha (chưa được kiểm tra), powerpc, sparc và sparc64.

Mục đích là cho phép sử dụng các mẫu bộ điều hợp FORE khác nhau tại
cùng lúc, bởi các máy chủ có nhiều giao diện bus (chẳng hạn như PCI+SBUS,
hoặc PCI+EISA).

Hiện chỉ có các thiết bị PCI và SBUS được trình điều khiển hỗ trợ, nhưng hỗ trợ
đối với các giao diện bus khác như EISA thì không quá khó để thêm vào.


Thông báo bản quyền phần sụn
-------------------------

Vui lòng đọc file fore200e_firmware_copyright hiện tại
trong thư mục linux/drivers/atm để biết chi tiết và hạn chế.


Cập nhật chương trình cơ sở
----------------

Trình điều khiển dòng FORE Systems 200E được cung cấp cùng với dữ liệu chương trình cơ sở
được tải lên bộ điều hợp ATM vào lúc khởi động hệ thống hoặc lúc tải mô-đun.
Hình ảnh chương trình cơ sở được cung cấp sẽ hoạt động với tất cả các bộ điều hợp.

Tuy nhiên, nếu bạn gặp sự cố (chương trình cơ sở không khởi động hoặc trình điều khiển
không thể đọc dữ liệu PROM), bạn có thể cân nhắc thử phần mềm khác
phiên bản. Hình ảnh chương trình cơ sở nhị phân thay thế có thể được tìm thấy ở đâu đó trên
ForeThought CD-ROM được FORE Systems cung cấp cùng với bộ chuyển đổi của bạn.

Bạn cũng có thể lấy hình ảnh chương trình cơ sở mới nhất từ Hệ thống FORE tại
ZZ0000ZZ Đăng ký TACTics trực tuyến và truy cập
trang 'cập nhật phần mềm'. Các chương trình cơ sở nhị phân là một phần của
các bản phân phối phần mềm ForThought khác nhau.

Lưu ý rằng có các phiên bản khác nhau của phần sụn PCA-200E, tùy thuộc vào
về độ bền của kiến trúc máy chủ. Người lái xe được vận chuyển với
cả hình ảnh phần sụn PCA cuối nhỏ và lớn.

Tên và vị trí của hình ảnh chương trình cơ sở mới có thể được đặt ở kernel
thời gian cấu hình:

1. Sao chép các tệp nhị phân phần sụn mới (có hậu tố .bin, .bin1 hoặc .bin2)
   vào một số thư mục, chẳng hạn như linux/drivers/atm.

2. Cấu hình lại kernel của bạn để đặt tên và vị trí phần sụn mới.
   Tên đường dẫn dự kiến ​​là tuyệt đối hoặc liên quan đến thư mục driver/atm.

3. Xây dựng lại và cài đặt lại kernel hoặc mô-đun của bạn.


Nhận xét
--------

Phản hồi được chào đón. Vui lòng gửi câu chuyện thành công/báo cáo lỗi/
bản vá/cải tiến/nhận xét/ngọn lửa tới <lizzi@cnam.fr>.