.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/platform/example-configurations/one-dev-per-hb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================
Một thiết bị trên mỗi cầu nối máy chủ
==========================

Hệ thống này có một ổ cắm duy nhất với hai cầu nối máy chủ CXL. Mỗi cầu chủ
có một bộ mở rộng bộ nhớ CXL duy nhất với bộ nhớ 4GB.

Những điều cần lưu ý:

* Cross-Bridge xen kẽ không được sử dụng.
* Các bộ mở rộng nằm ở hai vùng bộ nhớ riêng biệt nhưng liền kề.
* CEDT/SRAT này mô tả một nút cho mỗi thiết bị
* Các thiết bị mở rộng có cùng hiệu suất và sẽ ở cùng cấp bộ nhớ.

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
      Địa chỉ cơ sở cửa sổ: 0000001100000000
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
        Độ dài địa chỉ: 0000000100000000
             Dành riêng2: 00000000
 Cờ (được giải mã bên dưới): 0000000B
             Đã bật : 1
       Có thể cắm nóng : 1
        Không biến động: 0

Loại bảng phụ: 01 [Mối quan hệ bộ nhớ]
                Chiều dài : 28
      Tên miền lân cận: 00000002
             Dành riêng1: 0000
          Địa chỉ cơ sở: 0000001100000000
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
                        Nhập cảnh: 0080
                        Nhập cảnh : 0100
                        Nhập cảnh : 0100

Loại cấu trúc: 0001 [SLLBI]
                    Loại dữ liệu: 03 [Băng thông]
 Danh sách miền lân cận mục tiêu: 00000000
 Danh sách miền lân cận mục tiêu: 00000001
 Danh sách miền lân cận mục tiêu: 00000002
                        Đầu vào: 1200
                        Nhập cảnh : 0200
                        Nhập cảnh : 0200

ZZ0000ZZ::

Chữ ký: "SLIT" [Bảng thông tin vị trí hệ thống]
    Địa phương : 0000000000000003
  Địa phương 0 : 10 20 20
  Địa phương 1 : FF 0A FF
  Địa phương 2 : FF FF 0A

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