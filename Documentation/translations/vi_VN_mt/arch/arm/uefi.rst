.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/uefi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================================
Giao diện phần mềm mở rộng hợp nhất (UEFI)
====================================================

UEFI, Giao diện phần mềm mở rộng hợp nhất, là thông số kỹ thuật
quản lý hành vi của các giao diện phần mềm tương thích. Đó là
được duy trì bởi Diễn đàn UEFI - ZZ0000ZZ

UEFI là sự phát triển của phiên bản tiền nhiệm 'EFI', vì vậy các thuật ngữ EFI và
UEFI được sử dụng thay thế cho nhau trong tài liệu này và được liên kết
mã nguồn. Theo quy định, mọi nội dung mới đều sử dụng 'UEFI', trong khi 'EFI' đề cập đến
tới mã hoặc thông số kỹ thuật kế thừa.

Hỗ trợ UEFI trong Linux
=====================
Khởi động trên nền tảng có chương trình cơ sở tuân thủ thông số kỹ thuật UEFI
giúp kernel có thể hỗ trợ các tính năng bổ sung:

- Dịch vụ thời gian chạy UEFI
- Truy xuất thông tin cấu hình khác nhau thông qua tiêu chuẩn hóa
  giao diện của bảng cấu hình UEFI. (ACPI, SMBIOS, ...)

Để thực sự bật hỗ trợ [U]EFI, hãy bật:

- CONFIG_EFI=y
- CONFIG_EFIVAR_FS=y hoặc m

Việc triển khai phụ thuộc vào việc nhận thông tin về môi trường UEFI
trong Cây thiết bị dẹt (FDT) - vì vậy chỉ khả dụng với CONFIG_OF.

sơ khai UEFI
=========
"Sơ khai" là một tính năng mở rộng Hình ảnh/zImage thành UEFI hợp lệ
PE/COFF có thể thực thi được, bao gồm một ứng dụng tải cho phép
tải kernel trực tiếp từ shell UEFI, menu khởi động hoặc một trong các
bộ tải khởi động nhẹ như Gummiboot hoặc rEFInd.

Ảnh hạt nhân được xây dựng với hỗ trợ sơ khai vẫn là ảnh hạt nhân hợp lệ cho
khởi động trong môi trường không phải UEFI.

Hỗ trợ hạt nhân UEFI trên ARM
==========================
Hỗ trợ kernel UEFI trên kiến trúc ARM (arm và arm64) chỉ khả dụng
khi quá trình khởi động được thực hiện thông qua stub.

Khi khởi động ở chế độ UEFI, sơ khai sẽ xóa mọi nút bộ nhớ khỏi DT được cung cấp.
Thay vào đó, kernel đọc bản đồ bộ nhớ UEFI.

Sơ khai điền vào nút FDT /được chọn với (và hạt nhân quét)
các thông số sau:

================================ ================================================
Tên Loại Mô tả
================================ ================================================
linux,uefi-system-table Địa chỉ vật lý 64-bit của Bảng hệ thống UEFI.

linux,uefi-mmap-start 64-bit Địa chỉ vật lý của bản đồ bộ nhớ UEFI,
                                     được điền bởi lệnh gọi UEFI GetMemoryMap().

linux,uefi-mmap-size 32-bit Kích thước tính bằng byte của bản đồ bộ nhớ UEFI
                                     đã chỉ ra ở mục trước.

linux,uefi-mmap-desc-size 32-bit Kích thước tính bằng byte của mỗi mục trong UEFI
                                     bản đồ bộ nhớ

linux,uefi-mmap-desc-ver Phiên bản 32-bit của định dạng mô tả mmap.

kaslr-seed 64-bit Entropy được sử dụng để ngẫu nhiên hóa hình ảnh hạt nhân
                                     vị trí địa chỉ cơ sở.

bootargs Dòng lệnh hạt nhân chuỗi
================================ ================================================
