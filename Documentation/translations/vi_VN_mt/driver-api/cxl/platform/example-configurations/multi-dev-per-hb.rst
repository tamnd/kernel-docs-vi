.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/platform/example-configurations/multi-dev-per-hb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Nhiều thiết bị trên mỗi cầu nối máy chủ
================================

Trong hệ thống ví dụ này, chúng ta sẽ có một ổ cắm duy nhất và một cầu nối máy chủ CXL.
Có hai bộ mở rộng bộ nhớ CXL với 4GB được gắn vào cầu nối máy chủ.

Những điều cần lưu ý:

* Inter-Bridge xen kẽ không được mô tả ở đây.
* Các bộ mở rộng được mô tả bằng một CEDT/CFMWS duy nhất.
* CEDT/SRAT này mô tả một nút cho cả hai thiết bị.
* Chỉ có một miền lân cận HMAT cho cả hai thiết bị.

ZZ0000ZZ::

Loại bảng phụ: 00 [Cấu trúc cầu nối máy chủ CXL]
                 Đặt trước: 00
                   Chiều dài: 0020
   Cầu nối máy chủ liên kết: 00000007
    Phiên bản đặc điểm kỹ thuật: 00000001
                 Đặt trước: 00000000
            Cơ sở đăng ký: 0000010370400000
          Độ dài đăng ký: 0000000000010000

Loại bảng phụ: 01 [Cấu trúc cửa sổ bộ nhớ cố định CXL]
                 Đặt trước: 00
                   Chiều dài: 002C
                 Đặt trước: 00000000
      Địa chỉ cơ sở cửa sổ: 0000001000000000
              Kích thước cửa sổ: 0000000200000000
 Thành viên xen kẽ (2^n): 00
    Số học xen kẽ: 00
                 Đặt trước: 0000
              Độ chi tiết: 00000000
             Hạn chế: 0006
                    QtgId: 0001
             Mục tiêu đầu tiên: 00000007

ZZ0000ZZ::

Loại bảng phụ: 01 [Mối quan hệ bộ nhớ]
                Chiều dài : 28
      Tên miền lân cận: 00000001
             Dành riêng1: 0000
          Địa chỉ cơ sở: 0000001000000000
        Độ dài địa chỉ: 0000000200000000
             Dành riêng2: 00000000
 Cờ (được giải mã bên dưới): 0000000B
             Đã bật : 1
       Có thể cắm nóng : 1
        Không biến động: 0

ZZ0000ZZ::

Loại cấu trúc: 0001 [SLLBI]
                    Loại dữ liệu: 00 [Độ trễ]
 Danh sách miền lân cận mục tiêu: 00000000
 Danh sách miền lân cận mục tiêu: 00000001
                        Nhập cảnh: 0080
                        Nhập cảnh : 0100

Loại cấu trúc: 0001 [SLLBI]
                    Loại dữ liệu: 03 [Băng thông]
 Danh sách miền lân cận mục tiêu: 00000000
 Danh sách miền lân cận mục tiêu: 00000001
                        Đầu vào: 1200
                        Nhập cảnh : 0200

ZZ0000ZZ::

Chữ ký: "SLIT" [Bảng thông tin vị trí hệ thống]
    Địa phương : 0000000000000003
  Địa phương 0 : 10 20
  Địa phương 1 : FF 0A

ZZ0000ZZ::

Phạm vi (_SB)
  {
    Thiết bị (S0D0)
    {
        Tên (_HID, "ACPI0016" /* Cầu nối máy chủ liên kết nhanh tính toán */) // _HID: ID phần cứng
        ...
Tên (_UID, 0x07) // _UID: ID duy nhất
    }
    ...
  }