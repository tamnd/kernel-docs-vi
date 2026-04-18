.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/platform/acpi/cedt.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
CEDT - Bảng khám phá ban đầu CXL
====================================

Bảng khám phá ban đầu CXL được tạo bởi BIOS để mô tả bộ nhớ CXL
các vùng được cấu hình khi khởi động bởi BIOS.

CHBS
====
Cấu trúc cầu nối máy chủ CXL mô tả các cầu nối máy chủ CXL.  Ngoài việc miêu tả
thông tin đăng ký thiết bị, nó báo cáo cầu nối máy chủ cụ thể UID cho việc này
cầu chủ nhà.  Các ID cầu nối máy chủ này sẽ được tham chiếu trong các bảng khác.

Ví dụ ::

Loại bảng phụ: 00 [Cấu trúc cầu nối máy chủ CXL]
               Đặt trước: 00
                 Chiều dài: 0020
 Cầu nối máy chủ liên kết: 00000007 <- Cầu nối máy chủ _UID
  Phiên bản đặc điểm kỹ thuật: 00000001
               Đặt trước: 00000000
          Cơ sở đăng ký: 0000010370400000
        Độ dài đăng ký: 0000000000010000

CFMWS
=====
Cấu trúc Cửa sổ bộ nhớ cố định CXL mô tả vùng bộ nhớ được liên kết
với một hoặc nhiều cầu nối máy chủ CXL (như được mô tả bởi CHBS).  Ngoài ra nó
mô tả bất kỳ cấu hình xen kẽ giữa các máy chủ-cầu nối nào có thể đã được
được lập trình bởi BIOS.

Ví dụ ::

Loại bảng phụ: 01 [Cấu trúc cửa sổ bộ nhớ cố định CXL]
                 Đặt trước: 00
                   Chiều dài: 002C
                 Đặt trước: 00000000
      Địa chỉ cơ sở cửa sổ: 000000C050000000 <- Vùng bộ nhớ
              Kích thước cửa sổ: 0000003CA0000000
 Thành viên xen kẽ (2^n): 01 <- Cấu hình xen kẽ
    Số học xen kẽ: 00
                 Đặt trước: 0000
              Độ chi tiết: 00000000
             Hạn chế: 0006
                    QtgId: 0001
             Mục tiêu đầu tiên: 00000007 <- Host Bridge _UID
              Mục tiêu tiếp theo : 00000006 <- Host Bridge _UID

Trường hạn chế cho biết phạm vi SPA này có thể được sử dụng cho mục đích gì (loại bộ nhớ,
dễ thay đổi và dai dẳng, v.v.). Một hoặc nhiều bit có thể được đặt. ::

Bit[0]: Bộ nhớ CXL loại 2
  Bit[1]: Bộ nhớ CXL Loại 3
  Bit[2]: Bộ nhớ khả biến
  Bit[3]: Bộ nhớ liên tục
  Bit[4]: Cấu hình cố định (HPA không thể sử dụng lại)

INTRA xen kẽ cầu nối máy chủ (nhiều thiết bị trên một cầu nối máy chủ) là NOT
được báo cáo trong cấu trúc này và chỉ được xác định thông qua bộ giải mã thiết bị CXL
lập trình (cầu máy chủ và bộ giải mã điểm cuối).