.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arc/arc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Nhân Linux cho bộ xử lý ARC
*******************************

Các nguồn thông tin khác
############################

Dưới đây là một số tài nguyên có thể tìm thêm thông tin về
Bộ xử lý ARC và các dự án nguồn mở có liên quan.

- ZZ0000ZZ - Cổng cộng đồng mã nguồn mở trên ARC.
  Nơi tốt để bắt đầu tìm các dự án FOSS có liên quan, các bản phát hành chuỗi công cụ,
  các mục tin tức và nhiều hơn nữa.

- ZZ0000ZZ -
  Trang chủ cho tất cả các hoạt động phát triển liên quan đến các dự án nguồn mở cho
  Bộ xử lý ARC. Một số dự án là nhánh của các dự án thượng nguồn khác nhau,
  nơi "công việc đang tiến hành" được lưu trữ trước khi gửi đến các dự án thượng nguồn.
  Các dự án khác được Synopsys phát triển và cung cấp cho cộng đồng
  dưới dạng nguồn mở để sử dụng trên Bộ xử lý ARC.

- ZZ0000ZZ -
  vị trí, với quyền truy cập vào một số tài liệu IP (ZZ0001ZZ)
  và phiên bản miễn phí của một số công cụ thương mại (ZZ0002ZZ và
  ZZ0003ZZ).
  Tuy nhiên, xin lưu ý rằng cần phải đăng ký để truy cập cả tài liệu và
  các công cụ.

Lưu ý quan trọng về cấu hình bộ xử lý ARC
################################################

Bộ xử lý ARC có cấu hình cao và một số tùy chọn có thể cấu hình
được hỗ trợ trong Linux. Một số tùy chọn minh bạch đối với phần mềm
(tức là hình học bộ đệm, một số có thể được phát hiện trong thời gian chạy và được định cấu hình
và được sử dụng phù hợp, trong khi một số cần phải được chọn hoặc định cấu hình rõ ràng
trong tiện ích cấu hình của kernel (AKA "make menuconfig").

Tuy nhiên, không phải tất cả các tùy chọn có thể định cấu hình đều được hỗ trợ khi bộ xử lý ARC
là chạy Linux. Nhóm thiết kế SoC nên tham khảo "Phụ lục E:
Cấu hình cho ARC Linux" trong Sách dữ liệu ARC HS để biết cấu hình
hướng dẫn.

Làm theo các nguyên tắc này và chọn các tùy chọn cấu hình hợp lệ
việc trả trước là rất quan trọng để giúp ngăn chặn bất kỳ vấn đề không mong muốn nào trong quá trình
SoC mang lại và phát triển phần mềm nói chung.

Xây dựng nhân Linux cho bộ xử lý ARC
############################################

Quá trình xây dựng kernel cho bộ xử lý ARC cũng giống như bất kỳ bộ xử lý nào khác
kiến trúc và có thể được thực hiện theo 2 cách:

- Biên dịch chéo: quá trình biên dịch cho các mục tiêu ARC trong quá trình phát triển
  máy chủ có kiến trúc bộ xử lý khác (thường là x86_64/AMD64).
- Biên dịch gốc: quá trình biên dịch cho ARC trên nền tảng ARC
  (board phần cứng hoặc trình mô phỏng như QEMU) với môi trường phát triển hoàn chỉnh
  (Chuỗi công cụ GNU, dtc, make, v.v.) được cài đặt trên nền tảng.

Trong cả hai trường hợp, cần có chuỗi công cụ GNU cập nhật cho ARC cho máy chủ.
Synopsys cung cấp các bản phát hành chuỗi công cụ dựng sẵn có thể được sử dụng cho mục đích này,
có sẵn từ:

- Bản phát hành chuỗi công cụ Synopsys GNU:
  ZZ0000ZZ

- Bộ sưu tập trình biên dịch nhân Linux:
  ZZ0000ZZ

- Bộ sưu tập toolchain của Bootlin: ZZ0000ZZ

Sau khi chuỗi công cụ được cài đặt vào hệ thống, hãy đảm bảo thư mục "bin" của nó
được thêm vào biến môi trường ZZ0000ZZ của bạn. Sau đó đặt ZZ0001ZZ &
ZZ0002ZZ (hoặc bất cứ thứ gì khớp với tiền tố chuỗi công cụ ARC đã cài đặt)
và sau đó như thường lệ ZZ0003ZZ.

Điều này sẽ tạo ra tệp "vmlinux" trong thư mục gốc của cây nguồn kernel
có thể sử dụng để tải trên hệ thống đích thông qua JTAG.
Nếu bạn cần có được một hình ảnh có thể sử dụng được với bộ tải khởi động U-Boot,
loại ZZ0000ZZ và ZZ0001ZZ sẽ được sản xuất tại ZZ0002ZZ
thư mục.