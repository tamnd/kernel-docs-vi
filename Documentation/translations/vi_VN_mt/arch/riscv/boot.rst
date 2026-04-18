.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/riscv/boot.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================================
Các yêu cầu và ràng buộc khởi động hạt nhân RISC-V
===============================================

:Tác giả: Alexandre Ghiti <alexghiti@rivosinc.com>
:Ngày: 23 tháng 5 năm 2023

Tài liệu này mô tả những gì hạt nhân RISC-V mong đợi từ bộ tải khởi động và
chương trình cơ sở và cả những ràng buộc mà bất kỳ nhà phát triển nào cũng phải lưu ý khi
chạm vào quá trình khởi động sớm. Vì mục đích của tài liệu này,
ZZ0000ZZ đề cập đến bất kỳ mã nào chạy trước ảo cuối cùng
bản đồ được thiết lập.

Yêu cầu và ràng buộc tiền hạt nhân
=======================================

Hạt nhân RISC-V yêu cầu các bộ tải khởi động và chương trình cơ sở nền tảng sau:

Đăng ký trạng thái
--------------

Hạt nhân RISC-V mong đợi:

* ZZ0000ZZ để chứa phần cứng của lõi hiện tại.
  * ZZ0001ZZ để chứa địa chỉ của cây thiết bị trong bộ nhớ.

Trạng thái CSR
---------

Hạt nhân RISC-V mong đợi:

* ZZ0000ZZ: MMU, nếu có, phải bị tắt.

Bộ nhớ dành riêng cho chương trình cơ sở thường trú
-------------------------------------

Hạt nhân RISC-V không được ánh xạ bất kỳ bộ nhớ thường trú nào hoặc bộ nhớ được bảo vệ bằng
PMP, trong ánh xạ trực tiếp, do đó phần sụn phải đánh dấu chính xác các vùng đó
theo thông số kỹ thuật của cây thiết bị và/hoặc thông số UEFI.

Vị trí hạt nhân
---------------

Hạt nhân RISC-V dự kiến sẽ được đặt ở ranh giới PMD (2 MB được căn chỉnh cho rv64
và 4 MB được căn chỉnh cho rv32). Lưu ý rằng sơ khai EFI sẽ di chuyển vật lý
kernel nếu không phải như vậy.

Mô tả phần cứng
--------------------

Phần sụn có thể chuyển bảng thiết bị hoặc bảng ACPI sang hạt nhân RISC-V.

Cây thiết bị được truyền trực tiếp tới kernel từ giai đoạn trước
bằng cách sử dụng thanh ghi ZZ0000ZZ hoặc khi khởi động bằng UEFI, nó có thể được chuyển bằng cách sử dụng
Bảng cấu hình EFI.

Các bảng ACPI được chuyển tới kernel bằng bảng cấu hình EFI. trong
trong trường hợp này, một cây thiết bị nhỏ vẫn được tạo bởi sơ khai EFI. Vui lòng tham khảo
Phần "EFI sơ khai và cây thiết bị" bên dưới để biết chi tiết về cây thiết bị này.

Mục nhập hạt nhân
------------

Trên hệ thống SMP, có 2 phương thức để vào kernel:

- ZZ0000ZZ: firmware giải phóng tất cả các hart trong kernel, một hart
  trúng xổ số và thực thi mã khởi động sớm trong khi những con hươu khác đang
  đậu chờ quá trình khởi tạo kết thúc. Phương pháp này chủ yếu được sử dụng để
  hỗ trợ các phần mềm cũ hơn mà không có phần mở rộng SBI HSM và hạt nhân RISC-V ở chế độ M.
- ZZ0001ZZ: phần sụn chỉ phát hành một hart sẽ thực thi
  giai đoạn khởi tạo và sau đó sẽ bắt đầu tất cả các trái tim khác bằng SBI HSM
  phần mở rộng. Phương pháp khởi động theo thứ tự là phương pháp khởi động ưa thích cho
  khởi động kernel RISC-V vì nó có thể hỗ trợ hotplug CPU và kexec.

UEFI
----

Bản đồ bộ nhớ UEFI
~~~~~~~~~~~~~~~

Khi khởi động bằng UEFI, kernel RISC-V sẽ chỉ sử dụng bản đồ bộ nhớ EFI để
điền vào bộ nhớ hệ thống.

Phần sụn UEFI phải phân tích các nút con của cây thiết bị ZZ0000ZZ
nút và tuân theo đặc tả của cây thiết bị để chuyển đổi các thuộc tính của
các nút con đó (ZZ0001ZZ và ZZ0002ZZ) thành EFI tương đương chính xác của chúng
(tham khảo phần "3.5.4 /bộ nhớ dự trữ và UEFI" của cây thiết bị
đặc điểm kỹ thuật v0.4-rc1).

RISCV_EFI_BOOT_PROTOCOL
~~~~~~~~~~~~~~~~~~~~~~~

Khi khởi động bằng UEFI, sơ khai EFI yêu cầu hartid khởi động để vượt qua
nó vào kernel RISC-V trong ZZ0000ZZ. Sơ khai EFI truy xuất hartid khởi động bằng cách sử dụng
một trong các phương pháp sau:

-ZZ0000ZZ (ZZ0002ZZ).
- Nút phụ cây thiết bị ZZ0001ZZ (ZZ0003ZZ).

Bất kỳ chương trình cơ sở mới nào cũng phải triển khai ZZ0000ZZ làm cây thiết bị
cách tiếp cận dựa trên hiện không còn được dùng nữa.

Yêu cầu và ràng buộc khởi động sớm
=======================================

Quá trình khởi động sớm của kernel RISC-V hoạt động theo các ràng buộc sau:

Sơ khai và cây thiết bị EFI
-----------------------

Khi khởi động bằng UEFI, cây thiết bị được EFI bổ sung (hoặc tạo)
stub có cùng tham số với arm64 được mô tả ở đoạn
"Hỗ trợ kernel UEFI trên ARM" trong Tài liệu/arch/arm/uefi.rst.

Cài đặt bản đồ ảo
----------------------------

Việc cài đặt ánh xạ ảo được thực hiện theo 2 bước trong kernel RISC-V:

1. ZZ0000ZZ cài đặt ánh xạ kernel tạm thời trong ZZ0001ZZ
   cho phép khám phá bộ nhớ hệ thống. Chỉ văn bản/dữ liệu kernel được ánh xạ
   vào thời điểm này. Khi thiết lập ánh xạ này, không thể thực hiện phân bổ
   (vì bộ nhớ hệ thống chưa được xác định), nên bảng trang ZZ0002ZZ là
   được phân bổ tĩnh (chỉ sử dụng một bảng cho mỗi cấp độ).

2. ZZ0000ZZ tạo ánh xạ kernel cuối cùng trong ZZ0001ZZ
   và tận dụng bộ nhớ hệ thống được phát hiện để tạo tuyến tính
   lập bản đồ. Khi thiết lập ánh xạ này, kernel có thể cấp phát bộ nhớ nhưng
   không thể truy cập trực tiếp vào nó (vì chưa có ánh xạ trực tiếp), vì vậy
   nó sử dụng ánh xạ tạm thời trong vùng fixmap để có thể truy cập
   các cấp độ bảng trang mới được phân bổ.

Để ZZ0000ZZ và ZZ0001ZZ có thể chuyển đổi chính xác
địa chỉ ánh xạ trực tiếp tới địa chỉ vật lý, họ cần biết điểm bắt đầu của
DRAM. Điều này xảy ra sau bước 1, ngay trước khi bước 2 cài đặt trực tiếp
ánh xạ (xem hàm ZZ0002ZZ trong Arch/riscv/mm/init.c). Bất kỳ cách sử dụng nào của
các macro đó trước khi cài đặt ánh xạ ảo cuối cùng phải được cẩn thận
đã kiểm tra.

Ánh xạ cây thiết bị qua fixmap
-----------------------------

Vì mảng ZZ0000ZZ được khởi tạo với các địa chỉ ảo được thiết lập
bởi ZZ0001ZZ và được sử dụng với ánh xạ được thiết lập bởi
ZZ0002ZZ, hạt nhân RISC-V sử dụng vùng bản đồ cố định để ánh xạ
devicetree. Điều này đảm bảo rằng cây thiết bị vẫn có thể truy cập được bằng cả ảo
ánh xạ.

Thực thi trước MMU
-----------------

Một vài đoạn mã cần phải chạy trước khi ánh xạ ảo đầu tiên được thực hiện
được thành lập. Đây là bản cài đặt bản đồ ảo đầu tiên,
vá các lựa chọn thay thế ban đầu và phân tích cú pháp sớm của dòng lệnh kernel.
Mã đó phải được biên dịch rất cẩn thận như:

- ZZ0000ZZ: Điều này cần thiết cho các hạt nhân có thể định vị lại sử dụng ZZ0001ZZ,
  vì nếu không, mọi quyền truy cập vào biểu tượng chung sẽ đi qua GOT.
  hầu như chỉ được di dời.
- ZZ0002ZZ: Mọi quyền truy cập vào biểu tượng chung phải liên quan đến PC
  tránh bất kỳ sự di dời nào xảy ra trước khi MMU được thiết lập.
- Thiết bị đo ZZ0003ZZ cũng phải được tắt (bao gồm KASAN, ftrace và
  những người khác).

Vì việc sử dụng ký hiệu từ một đơn vị biên dịch khác đòi hỏi đơn vị này phải được
được biên soạn bằng những cờ đó, chúng tôi khuyên bạn không nên sử dụng các cờ bên ngoài càng nhiều càng tốt.
biểu tượng.