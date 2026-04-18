.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/platform/cdat.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================================
Bảng thuộc tính thiết bị mạch lạc (CDAT)
=========================================

CDAT cung cấp các thuộc tính chức năng và hiệu suất của các thiết bị như
như bộ tăng tốc, công tắc hoặc điểm cuối CXL.  Định dạng bảng là
tương tự như bảng ACPI. Dữ liệu CDAT có thể được phân tích cú pháp bởi BIOS khi khởi động hoặc có thể
được liệt kê trong thời gian chạy (ví dụ: sau khi cắm nóng thiết bị).

Thuật ngữ:
DPA - Địa chỉ vật lý của thiết bị, được thiết bị CXL sử dụng để biểu thị địa chỉ
nó hỗ trợ cho thiết bị đó.

DSMADHandle - Một tay cầm duy nhất của thiết bị được liên kết với phạm vi DPA
được xác định bởi bảng DSMAS.


================================================================
Cấu trúc mối quan hệ trong bộ nhớ trong phạm vi thiết bị (DSMAS)
================================================================

DSMAS chứa thông tin như DSMADHandle, DPA Base và DPA
Chiều dài.

Bảng này được Linux sử dụng cùng với Độ trễ trong phạm vi thiết bị và
Cấu trúc thông tin băng thông (DSLBIS) để xác định hiệu suất
thuộc tính của chính thiết bị CXL.

Ví dụ ::

Loại cấu trúc: 00 [DSMAS]
       Đặt trước: 00
         Chiều dài : 0018 <- 24d, kích thước kết cấu
    DSMADXử lý : 01
          Cờ : 00
       Đặt trước: 0000
       Cơ sở DPA: 0000000040000000 <- cơ sở 1GiB
     DPA Chiều dài: 0000000080000000 <- Kích thước 2GiB


=======================================================================
Cấu trúc thông tin băng thông và độ trễ trong phạm vi thiết bị (DSLBIS)
=======================================================================

Bảng này được Linux sử dụng cùng với DSMAS để xác định
thuộc tính hiệu suất của thiết bị CXL.  DSLBIS chứa độ trễ
và thông tin băng thông dựa trên kết hợp DSMADHandle.

Ví dụ ::

Loại cấu trúc: 01 [DSLBIS]
         Đặt trước: 00
           Chiều dài : 18 <- 24d, kích thước kết cấu
           Tay cầm: Tay cầm 0001 <- DSMAS
            Cờ: 00 <- Khớp trường cờ cho HMAT SLLBIS
        Kiểu dữ liệu: 00 <- Độ trễ
 Đơn vị cơ sở đầu vào: 0000000000001000 <- Trường Đơn vị cơ sở đầu vào trong HMAT SSLBIS
            Mục nhập: 010000000000 <- Byte đầu tiên được sử dụng ở đây, CXL LTC
         Đặt trước: 0000

Loại cấu trúc: 01 [DSLBIS]
         Đặt trước: 00
           Chiều dài : 18 <- 24d, kích thước kết cấu
           Tay cầm: Tay cầm 0001 <- DSMAS
            Cờ: 00 <- Khớp trường cờ cho HMAT SLLBIS
        Kiểu dữ liệu: 03 <- Băng thông
 Đơn vị cơ sở đầu vào: 0000000000001000 <- Trường Đơn vị cơ sở đầu vào trong HMAT SSLBIS
            Mục nhập: 020000000000 <- Byte đầu tiên được sử dụng ở đây, CXL BW
         Đặt trước: 0000


=======================================================================
Cấu trúc thông tin băng thông và độ trễ có phạm vi chuyển đổi (SSLBIS)
=======================================================================

SSLBIS chứa thông tin về độ trễ và băng thông của bộ chuyển mạch.

Bảng được Linux sử dụng để tính toán tọa độ hiệu suất của đường dẫn CXL
từ thiết bị đến cổng gốc nơi switch là một phần của đường dẫn.

Ví dụ ::

Loại cấu trúc: 05 [SSLBIS]
        Đặt trước: 00
          Độ dài: 20 <- 32d, độ dài bản ghi, bao gồm các mục SSLB
       Kiểu dữ liệu: 00 <- Độ trễ
        Đặt trước: 000000
 Đơn vị cơ sở đầu vào: 000000000000000001000 <- Khớp với Đơn vị cơ sở đầu vào trong HMAT SSLBIS

<- SSLB Mục 0
       ID cổng X: 0100 <- Cổng đầu tiên, 0100h đại diện cho cổng ngược dòng
       ID cổng Y: 0000 <- Cổng thứ hai, cổng xuôi dòng 0
         Độ trễ: 0100 <- Độ trễ của cổng
        Đặt trước: 0000
                                                <- SSLB Mục 1
       ID cổng X: 0100
       ID cổng Y: 0001
         Độ trễ: 0100
        Đặt trước: 0000


Loại cấu trúc: 05 [SSLBIS]
        Đặt trước: 00
          Độ dài: 18 <- 24d, độ dài bản ghi, bao gồm mục nhập SSLB
       Kiểu dữ liệu: 03 <- Băng thông
        Đặt trước: 000000
 Đơn vị cơ sở đầu vào: 000000000000000001000 <- Khớp với Đơn vị cơ sở đầu vào trong HMAT SSLBIS

<- SSLB Mục 0
       ID cổng X: 0100 <- Cổng đầu tiên, 0100h đại diện cho cổng ngược dòng
       ID cổng Y: FFFF <- Cổng thứ hai, FFFFh cho biết bất kỳ cổng nào
       Băng thông: 1200 <- Băng thông cổng
        Đặt trước: 0000

Trình điều khiển CXL sử dụng kết hợp CDAT, HMAT, SRAT và các dữ liệu khác để
tạo dữ liệu "toàn bộ hiệu suất đường dẫn" cho thiết bị CXL.