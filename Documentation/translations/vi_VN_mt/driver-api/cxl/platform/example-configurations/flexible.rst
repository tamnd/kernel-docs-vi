.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/platform/example-configurations/flexible.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Trình bày linh hoạt
=======================
Hệ thống này có một ổ cắm duy nhất với hai cầu nối máy chủ CXL. Mỗi cầu chủ
có hai bộ mở rộng bộ nhớ CXL với bộ nhớ 4GB (tổng cộng 32 GB).

Trên hệ thống này, người thiết kế nền tảng muốn cung cấp cho người dùng sự linh hoạt
để định cấu hình các thiết bị bộ nhớ ở nhiều nút xen kẽ hoặc nút NUMA khác nhau
cấu hình.  Vì vậy, họ cung cấp mọi sự kết hợp.

Những điều cần lưu ý:

* Sự xen kẽ Cross-Bridge được mô tả trong một CFMWS bao gồm tất cả dung lượng.
* Một CFMWS cũng được mô tả là cầu nối cho mỗi máy chủ.
* Một CFMWS cũng được mô tả cho mỗi thiết bị.
* SRAT này mô tả một nút cho mỗi CFMWS ở trên.
* HMAT mô tả hiệu suất cho từng nút trong SRAT.

ZZ0000ZZ::

Loại bảng phụ: 00 [Cấu trúc cầu nối máy chủ CXL]
                 Đặt trước: 00
                   Chiều dài: 0020
   Cầu nối máy chủ liên kết: 00000007
    Phiên bản đặc điểm kỹ thuật: 00000001
                 Đặt trước: 00000000
            Cơ sở đăng ký: 0000010370400000
          Độ dài đăng ký: 0000000000010000

Loại bảng phụ: 00 [Cấu trúc cầu nối máy chủ CXL]
                 Đặt trước: 00
                   Chiều dài: 0020
   Cầu nối máy chủ liên kết: 00000006
    Phiên bản đặc điểm kỹ thuật: 00000001
                 Đặt trước: 00000000
            Cơ sở đăng ký: 0000010380800000
          Độ dài đăng ký: 0000000000010000

Loại bảng phụ: 01 [Cấu trúc cửa sổ bộ nhớ cố định CXL]
                 Đặt trước: 00
                   Chiều dài: 002C
                 Đặt trước: 00000000
      Địa chỉ cơ sở cửa sổ: 0000001000000000
              Kích thước cửa sổ: 0000000400000000
 Thành viên xen kẽ (2^n): 01
    Số học xen kẽ: 00
                 Đặt trước: 0000
              Độ chi tiết: 00000000
             Hạn chế: 0006
                    QtgId: 0001
             Mục tiêu đầu tiên: 00000007
            Mục tiêu thứ hai: 00000006

Loại bảng phụ: 01 [Cấu trúc cửa sổ bộ nhớ cố định CXL]
                 Đặt trước: 00
                   Chiều dài: 002C
                 Đặt trước: 00000000
      Địa chỉ cơ sở cửa sổ: 0000002000000000
              Kích thước cửa sổ: 0000000200000000
 Thành viên xen kẽ (2^n): 00
    Số học xen kẽ: 00
                 Đặt trước: 0000
              Độ chi tiết: 00000000
             Hạn chế: 0006
                    QtgId: 0001
             Mục tiêu đầu tiên: 00000007

Loại bảng phụ: 01 [Cấu trúc cửa sổ bộ nhớ cố định CXL]
                 Đặt trước: 00
                   Chiều dài: 002C
                 Đặt trước: 00000000
      Địa chỉ cơ sở cửa sổ: 0000002200000000
              Kích thước cửa sổ: 0000000200000000
 Thành viên xen kẽ (2^n): 00
    Số học xen kẽ: 00
                 Đặt trước: 0000
              Độ chi tiết: 00000000
             Hạn chế: 0006
                    QtgId: 0001
             Mục tiêu đầu tiên: 00000006

Loại bảng phụ: 01 [Cấu trúc cửa sổ bộ nhớ cố định CXL]
                 Đặt trước: 00
                   Chiều dài: 002C
                 Đặt trước: 00000000
      Địa chỉ cơ sở cửa sổ: 0000003000000000
              Kích thước cửa sổ: 0000000100000000
 Thành viên xen kẽ (2^n): 00
    Số học xen kẽ: 00
                 Đặt trước: 0000
              Độ chi tiết: 00000000
             Hạn chế: 0006
                    QtgId: 0001
             Mục tiêu đầu tiên: 00000007

Loại bảng phụ: 01 [Cấu trúc cửa sổ bộ nhớ cố định CXL]
                 Đặt trước: 00
                   Chiều dài: 002C
                 Đặt trước: 00000000
      Địa chỉ cơ sở cửa sổ: 0000003100000000
              Kích thước cửa sổ: 0000000100000000
 Thành viên xen kẽ (2^n): 00
    Số học xen kẽ: 00
                 Đặt trước: 0000
              Độ chi tiết: 00000000
             Hạn chế: 0006
                    QtgId: 0001
             Mục tiêu đầu tiên: 00000007

Loại bảng phụ: 01 [Cấu trúc cửa sổ bộ nhớ cố định CXL]
                 Đặt trước: 00
                   Chiều dài: 002C
                 Đặt trước: 00000000
      Địa chỉ cơ sở cửa sổ: 0000003200000000
              Kích thước cửa sổ: 0000000100000000
 Thành viên xen kẽ (2^n): 00
    Số học xen kẽ: 00
                 Đặt trước: 0000
              Độ chi tiết: 00000000
             Hạn chế: 0006
                    QtgId: 0001
             Mục tiêu đầu tiên: 00000006

Loại bảng phụ: 01 [Cấu trúc cửa sổ bộ nhớ cố định CXL]
                 Đặt trước: 00
                   Chiều dài: 002C
                 Đặt trước: 00000000
      Địa chỉ cơ sở cửa sổ: 0000003300000000
              Kích thước cửa sổ: 0000000100000000
 Thành viên xen kẽ (2^n): 00
    Số học xen kẽ: 00
                 Đặt trước: 0000
              Độ chi tiết: 00000000
             Hạn chế: 0006
                    QtgId: 0001
             Mục tiêu đầu tiên: 00000006

ZZ0000ZZ::

Loại bảng phụ: 01 [Mối quan hệ bộ nhớ]
                Chiều dài : 28
      Tên miền lân cận: 00000001
             Dành riêng1: 0000
          Địa chỉ cơ sở: 0000001000000000
        Độ dài địa chỉ: 0000000400000000
             Dành riêng2: 00000000
 Cờ (được giải mã bên dưới): 0000000B
             Đã bật : 1
       Có thể cắm nóng : 1
        Không biến động: 0

Loại bảng phụ: 01 [Mối quan hệ bộ nhớ]
                Chiều dài : 28
      Tên miền lân cận: 00000002
             Dành riêng1: 0000
          Địa chỉ cơ sở: 0000002000000000
        Độ dài địa chỉ: 0000000200000000
             Dành riêng2: 00000000
 Cờ (được giải mã bên dưới): 0000000B
             Đã bật : 1
       Có thể cắm nóng : 1
        Không biến động: 0

Loại bảng phụ: 01 [Mối quan hệ bộ nhớ]
                Chiều dài : 28
      Tên miền lân cận: 00000003
             Dành riêng1: 0000
          Địa chỉ cơ sở: 0000002200000000
        Độ dài địa chỉ: 0000000200000000
             Dành riêng2: 00000000
 Cờ (được giải mã bên dưới): 0000000B
             Đã bật : 1
       Có thể cắm nóng : 1
        Không biến động: 0

Loại bảng phụ: 01 [Mối quan hệ bộ nhớ]
                Chiều dài : 28
      Tên miền lân cận: 00000004
             Dành riêng1: 0000
          Địa chỉ cơ sở: 0000003000000000
        Độ dài địa chỉ: 0000000100000000
             Dành riêng2: 00000000
 Cờ (được giải mã bên dưới): 0000000B
             Đã bật : 1
       Có thể cắm nóng : 1
        Không biến động: 0

Loại bảng phụ: 01 [Mối quan hệ bộ nhớ]
                Chiều dài : 28
      Tên miền lân cận: 00000005
             Dành riêng1: 0000
          Địa chỉ cơ sở: 0000003100000000
        Độ dài địa chỉ: 0000000100000000
             Dành riêng2: 00000000
 Cờ (được giải mã bên dưới): 0000000B
             Đã bật : 1
       Có thể cắm nóng : 1
        Không biến động: 0

Loại bảng phụ: 01 [Mối quan hệ bộ nhớ]
                Chiều dài : 28
      Tên miền lân cận: 00000006
             Dành riêng1: 0000
          Địa chỉ cơ sở: 0000003200000000
        Độ dài địa chỉ: 0000000100000000
             Dành riêng2: 00000000
 Cờ (được giải mã bên dưới): 0000000B
             Đã bật : 1
       Có thể cắm nóng : 1
        Không biến động: 0

Loại bảng phụ: 01 [Mối quan hệ bộ nhớ]
                Chiều dài : 28
      Tên miền lân cận: 00000007
             Dành riêng1: 0000
          Địa chỉ cơ sở: 0000003300000000
        Độ dài địa chỉ: 0000000100000000
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
 Danh sách miền lân cận mục tiêu: 00000002
 Danh sách miền lân cận mục tiêu: 00000003
 Danh sách miền lân cận mục tiêu: 00000004
 Danh sách miền lân cận mục tiêu: 00000005
 Danh sách miền lân cận mục tiêu: 00000006
 Danh sách miền lân cận mục tiêu: 00000007
                        Nhập cảnh: 0080
                        Nhập cảnh : 0100
                        Nhập cảnh : 0100
                        Nhập cảnh : 0100
                        Nhập cảnh : 0100
                        Nhập cảnh : 0100
                        Nhập cảnh : 0100
                        Nhập cảnh : 0100

Loại cấu trúc: 0001 [SLLBI]
                    Loại dữ liệu: 03 [Băng thông]
 Danh sách miền lân cận mục tiêu: 00000000
 Danh sách miền lân cận mục tiêu: 00000001
 Danh sách miền lân cận mục tiêu: 00000002
 Danh sách miền lân cận mục tiêu: 00000003
 Danh sách miền lân cận mục tiêu: 00000004
 Danh sách miền lân cận mục tiêu: 00000005
 Danh sách miền lân cận mục tiêu: 00000006
 Danh sách miền lân cận mục tiêu: 00000007
                        Đầu vào: 1200
                        Nhập cảnh : 0400
                        Nhập cảnh : 0200
                        Nhập cảnh : 0200
                        Nhập cảnh : 0100
                        Nhập cảnh : 0100
                        Nhập cảnh : 0100
                        Nhập cảnh : 0100

ZZ0000ZZ::

Chữ ký: "SLIT" [Bảng thông tin vị trí hệ thống]
    Địa phương : 0000000000000003
  Địa phương 0 : 10 20 20 20 20 20 20 20
  Địa phương 1 : FF 0A FF FF FF FF FF FF
  Địa phương 2 : FF FF 0A FF FF FF FF FF
  Địa phương 3 : FF FF FF 0A FF FF FF FF
  Địa phương 4 : FF FF FF FF 0A FF FF FF
  Địa phương 5 : FF FF FF FF FF 0A FF FF
  Địa phương 6 : FF FF FF FF FF FF 0A FF
  Địa phương 7 : FF FF FF FF FF FF FF 0A

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
Thiết bị (S0D5)
    {
        Tên (_HID, "ACPI0016" /* Cầu nối máy chủ liên kết nhanh tính toán */) // _HID: ID phần cứng
        ...
Tên (_UID, 0x06) // _UID: ID duy nhất
    }
  }