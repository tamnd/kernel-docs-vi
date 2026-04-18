.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/platform/acpi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============
Bàn ACPI
============

ACPI là "Cấu hình nâng cao và giao diện nguồn", là một tiêu chuẩn
xác định cách các nền tảng và hệ điều hành quản lý nguồn điện cũng như cấu hình phần cứng máy tính.
Với mục đích của lý thuyết hoạt động này, khi đề cập đến "ACPI" chúng ta sẽ
thường đề cập đến "Bảng ACPI" - đó là cách một nền tảng (BIOS/EFI)
truyền đạt thông tin cấu hình tĩnh tới hệ điều hành.

Các bảng ACPI sau đây chứa dữ liệu hiệu suất và cấu hình ZZ0000ZZ
về thiết bị CXL.

.. toctree::
   :maxdepth: 1

   acpi/cedt.rst
   acpi/srat.rst
   acpi/hmat.rst
   acpi/slit.rst
   acpi/dsdt.rst

Bảng SRAT cũng có thể chứa nội dung cổng/bộ khởi tạo chung được dự định
để mô tả cổng chung chứ không phải thông tin về phần còn lại của đường dẫn đến
điểm cuối.

Linux sử dụng các bảng này để cấu hình tài nguyên kernel cho các thiết bị được cấu hình tĩnh
(bởi BIOS/EFI) Các thiết bị CXL, chẳng hạn như:

- Các nút NUMA
- Cấp bộ nhớ
- Khoảng cách trừu tượng NUMA
- Vùng bộ nhớ SystemRAM
- Trọng lượng nút xen kẽ có trọng số

Gỡ lỗi ACPI
==============

Lệnh ZZ0000ZZ chuyển các bảng ACPI sang định dạng nhị phân.

Lệnh ZZ0000ZZ phân tách các tệp thành định dạng mà con người có thể đọc được.

Ví dụ ZZ0000ZZ ::

[000h 0000 4] Chữ ký: "CEDT" [Bảng khám phá sớm CXL]

Các vấn đề chung
-------------
Hầu hết các lỗi được mô tả ở đây đều dẫn đến việc bộ điều khiển không thể nổi lên mặt nước.
bộ nhớ dưới dạng thiết bị DAX và/hoặc kmem.

* Danh sách mục tiêu CEDT CFMWS UID không khớp với UID CEDT CHBS.
* Danh sách mục tiêu CEDT CFMWS UID không khớp với UID cầu nối máy chủ DSDT CXL.
* Bit hạn chế CEDT CFMWS không chính xác.
* CEDT CFMWS Các vùng bộ nhớ được căn chỉnh kém.
* CEDT CFMWS Vùng bộ nhớ trải rộng trên một lỗ bộ nhớ nền tảng.
* UID CEDT CHBS không khớp với UID cầu nối máy chủ DSDT CXL.
* Phiên bản thông số kỹ thuật CEDT CHBS không chính xác.
* SRAT thiếu các vùng được mô tả trong CEDT CFMWS.

* Kết quả: không tạo được nút NUMA cho vùng hoặc
    vùng được đặt sai nút.

* HMAT thiếu dữ liệu cho các vùng được mô tả trong CEDT CFMWS.

* Kết quả: Nút NUMA bị đặt sai cấp bộ nhớ.

* SLIT có dữ liệu xấu.

* Kết quả: Rất nhiều cơ chế hoạt động trong kernel sẽ rất không hài lòng.

Tất cả những vấn đề này sẽ xuất hiện với người dùng như thể trình điều khiển không hoạt động được.
hỗ trợ CXL - trong khi thực tế tất cả chúng đều là sự thất bại của một nền tảng đối với
cấu hình các bảng ACPI một cách chính xác.