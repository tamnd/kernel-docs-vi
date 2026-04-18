.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/mei/iamt.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Công nghệ quản lý hoạt động Intel(R) (Intel AMT)
=================================================

Công dụng nổi bật của Giao diện Intel ME là để giao tiếp với Intel(R)
Công nghệ quản lý hoạt động (Intel AMT) được triển khai trong chương trình cơ sở chạy trên
Intel ME.

Intel AMT cung cấp khả năng quản lý máy chủ từ xa ngoài băng tần (OOB)
ngay cả khi hệ điều hành chạy trên bộ xử lý chủ bị hỏng hoặc
đang trong trạng thái ngủ.

Một số ví dụ về cách sử dụng Intel AMT là:
   - Giám sát trạng thái phần cứng và các thành phần nền tảng
   - Tắt/bật nguồn từ xa (hữu ích cho điện toán xanh hoặc CNTT qua đêm
     bảo trì)
   - Cập nhật hệ điều hành
   - Lưu trữ thông tin nền tảng hữu ích như tài sản phần mềm
   - Phần cứng tích hợp KVM
   - Cách ly mạng có chọn lọc dựa trên luồng giao thức Ethernet và IP
     về các chính sách do bảng điều khiển quản lý từ xa đặt ra
   - Chuyển hướng thiết bị IDE từ bảng điều khiển quản lý từ xa

Giao tiếp Intel AMT (OOB) dựa trên SOAP (không dùng nữa
bắt đầu từ Phiên bản 6.0) qua giao thức HTTP/S hoặc WS-Quản lý qua
HTTP/S được nhận từ ứng dụng bảng điều khiển quản lý từ xa.

Để biết thêm thông tin về Intel AMT:
ZZ0000ZZ


Ứng dụng Intel AMT
----------------------

1) Dịch vụ quản lý cục bộ của Intel (Intel LMS)

Các ứng dụng chạy cục bộ trên nền tảng giao tiếp với Intel AMT Release
       2.0 trở lên giống như cách các ứng dụng mạng thực hiện thông qua SOAP
       trên HTTP (không được dùng nữa kể từ Phiên bản 6.0) hoặc với WS-Quản lý trên
       SOAP trên HTTP. Điều này có nghĩa là một số tính năng của Intel AMT có thể được truy cập từ một
       ứng dụng cục bộ sử dụng cùng giao diện mạng với ứng dụng từ xa
       giao tiếp với Intel AMT qua mạng.

Khi một ứng dụng cục bộ gửi tin nhắn đến máy chủ Intel AMT cục bộ
       tên, Intel LMS, lắng nghe lưu lượng truy cập hướng đến tên máy chủ,
       chặn tin nhắn và định tuyến nó đến Intel MEI.
       Để biết thêm thông tin:
       ZZ0000ZZ
       Trong phần "Giới thiệu về Intel AMT" => "Truy cập cục bộ"

Để tải xuống Intel LMS:
       ZZ0000ZZ

Intel LMS mở kết nối bằng trình điều khiển Intel MEI tới Intel LMS
       tính năng phần sụn sử dụng GUID được xác định và sau đó giao tiếp với tính năng này
       sử dụng giao thức có tên là Giao thức chuyển tiếp cổng Intel AMT (giao thức Intel APF).
       Giao thức được sử dụng để duy trì nhiều phiên với Intel AMT từ một
       ứng dụng duy nhất.

Xem thông số kỹ thuật giao thức trong Bộ phát triển phần mềm Intel AMT (SDK)
       ZZ0000ZZ
       Trong "Tài nguyên SDK" => "Cổng Intel(R) vPro(TM) (MPS)"
       => "Thông tin dành cho nhà phát triển cổng Intel(R) vPro(TM)"
       => "Mô tả Giao thức chuyển tiếp cổng Intel AMT (APF)"

2) Cấu hình từ xa Intel AMT bằng Tác nhân cục bộ

Tác nhân cục bộ cho phép nhân viên CNTT đặt cấu hình ngay lập tức cho Intel AMT
       mà không cần cài đặt thêm dữ liệu để kích hoạt thiết lập. Điều khiển từ xa
       quá trình cấu hình có thể liên quan đến cấu hình từ xa do ISV phát triển
       tác nhân chạy trên máy chủ.
       Để biết thêm thông tin:
       ZZ0000ZZ
       Trong phần "Thiết lập và cấu hình của Intel AMT" =>
       "SDK Công cụ hỗ trợ thiết lập và cấu hình" =>
       "Sử dụng mẫu đại lý địa phương"

Cơ quan giám sát tình trạng hệ điều hành Intel AMT
--------------------------------------------------

Cơ quan giám sát Intel AMT là cơ quan giám sát Tình trạng hệ điều hành (Hang/Crash).
Bất cứ khi nào hệ điều hành bị treo hoặc gặp sự cố, Intel AMT sẽ gửi một sự kiện
cho bất kỳ người đăng ký tham gia sự kiện này. Cơ chế này có nghĩa là
CNTT biết khi nào một nền tảng gặp sự cố ngay cả khi máy chủ gặp sự cố nghiêm trọng.

Cơ quan giám sát Intel AMT bao gồm hai phần:
    1) Tính năng phần mềm - nhận nhịp tim
       và gửi một sự kiện khi nhịp tim ngừng đập.
    2) Trình điều khiển cơ quan giám sát Intel MEI iAMT - kết nối với tính năng cơ quan giám sát,
       cấu hình cơ quan giám sát và gửi nhịp tim.

Trình điều khiển MEI của Intel iAMT watchdog sử dụng kernel watchdog API để cấu hình
Cơ quan giám sát Intel AMT và gửi nhịp tim tới nó. Thời gian chờ mặc định của
cơ quan giám sát là 120 giây.

Nếu Intel AMT không được kích hoạt trong chương trình cơ sở thì ứng dụng cơ quan giám sát sẽ không liệt kê
trên xe buýt khách và các thiết bị giám sát của tôi sẽ không bị lộ.

---
linux-mei@linux.intel.com