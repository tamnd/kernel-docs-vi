.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/platform/acpi/srat.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================================
SRAT - Bảng quan hệ tài nguyên tĩnh
=====================================

Bảng quan hệ tài nguyên hệ thống/tĩnh mô tả tài nguyên (CPU, Bộ nhớ)
mối quan hệ với "Miền lân cận". Bảng này là tùy chọn về mặt kỹ thuật, nhưng đối với
thông tin hiệu suất (xem "HMAT") được linux liệt kê thì phải
hiện tại.

Có sự phối hợp cẩn thận giữa các bảng CEDT và SRAT cũng như cách thức hoạt động của các nút NUMA
được tạo ra.  Nếu mọi thứ không giống như bạn mong đợi - hãy kiểm tra Bộ nhớ SRAT
Các mục nhập mối quan hệ và CEDT CFMWS để xác định nền tảng của bạn thực sự là gì
hỗ trợ về mặt cấu trúc liên kết linh hoạt.

SRAT có thể gán tĩnh các phần của phạm vi CFMWS SPA cho một phạm vi cụ thể
các miền lân cận.  Xem việc tạo linux numa để biết thêm thông tin về cách
điều này thể hiện trong cấu trúc liên kết NUMA.

Miền lân cận
================
Miền lân cận là ROUGHLY tương đương với "Nút NUMA" - mặc dù là 1-1
bản đồ không được đảm bảo.  Có những tình huống trong đó "Miền lân cận 4" có thể
ví dụ: ánh xạ tới "NUMA Node 3".  (Xem "Tạo nút NUMA")

Mối quan hệ trí nhớ
===============
Nói chung, nếu máy chủ thực hiện bất kỳ số lượng kết cấu CXL nào (bộ giải mã)
lập trình trong BIOS - cần phải có mục nhập SRAT cho bộ nhớ đó.

Ví dụ ::

Loại bảng phụ: 01 [Mối quan hệ bộ nhớ]
                Chiều dài : 28
      Miền lân cận: 00000001 <- NUMA Nút 1
             Dành riêng1: 0000
          Địa chỉ cơ sở: 000000C050000000 <- Vùng bộ nhớ vật lý
        Độ dài địa chỉ: 0000003CA0000000
             Dành riêng2: 00000000
 Cờ (được giải mã bên dưới): 0000000B
              Đã bật : 1
        Có thể cắm nóng : 1
         Không biến động: 0


Mối quan hệ cổng chung
=====================
Bảng phụ Mối quan hệ cổng chung cung cấp sự liên kết giữa một vùng lân cận
miền và bộ điều khiển thiết bị đại diện cho Cổng chung, chẳng hạn như máy chủ CXL
cầu. Với sự liên kết, số độ trễ và băng thông có thể được truy xuất
từ SRAT cho đường dẫn giữa CPU(s) (bộ khởi tạo) và Cổng chung.
Điều này được sử dụng để xây dựng tọa độ hiệu suất cho CXL DEVICES được cắm nóng,
không thể liệt kê được khi khởi động bằng phần mềm nền tảng.

Ví dụ ::

Loại bảng phụ: 06 [Affinity cổng chung]
                Chiều dài: 20<- 32d, chiều dài bàn
              Đặt trước: 00
    Loại tay cầm thiết bị: 00 <- 0 - ACPI, 1 - PCI
      Tên miền lân cận: 00000001
         Tay cầm thiết bị: ACPI0016:01
                 Cờ: 00000001 <- Bit 0 (Đã bật)
              Đặt trước: 00000000

Miền lân cận được khớp với Mục tiêu ZZ0000ZZ SSLBI
Danh sách miền lân cận để biết số lượng độ trễ hoặc băng thông liên quan. Những cái đó
số hiệu suất được gắn với cầu nối máy chủ CXL thông qua Tay cầm thiết bị.
Trình điều khiển sử dụng liên kết để lấy hiệu suất của Cổng chung
các số cho toàn bộ phép tính tọa độ truy cập đường dẫn CXL.