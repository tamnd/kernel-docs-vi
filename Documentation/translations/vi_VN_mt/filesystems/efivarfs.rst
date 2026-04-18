.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/efivarfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========================================
efivarfs - một hệ thống tập tin biến (U)EFI
=======================================

Hệ thống tập tin efivarfs được tạo ra để giải quyết những thiếu sót của
sử dụng các mục trong sysfs để duy trì các biến EFI. Hệ thống cũ EFI
mã biến chỉ hỗ trợ các biến có kích thước tối đa 1024 byte. Cái này
hạn chế tồn tại trong phiên bản 0.99 của thông số kỹ thuật EFI, nhưng đã
bị xóa trước khi có bất kỳ bản phát hành đầy đủ nào. Vì các biến bây giờ có thể lớn hơn
hơn một trang duy nhất, sysfs không phải là giao diện tốt nhất cho việc này.

Các biến có thể được tạo, xóa và sửa đổi bằng efivarfs
hệ thống tập tin.

efivarfs thường được gắn kết như thế này ::

mount -t efivarfs none /sys/firmware/efi/efivars

Do có nhiều lỗi phần mềm trong đó việc loại bỏ các phần mềm không chuẩn
Các biến UEFI khiến phần sụn hệ thống không thành công POST, efivarfs
các tệp không phải là biến tiêu chuẩn hóa nổi tiếng được tạo
như các tập tin bất biến.  Điều này không ngăn cản việc xóa - "chattr -i" sẽ hoạt động -
nhưng nó ngăn chặn kiểu thất bại này xảy ra
vô tình.

.. warning ::
      When a content of an UEFI variable in /sys/firmware/efi/efivars is
      displayed, for example using "hexdump", pay attention that the first
      4 bytes of the output represent the UEFI variable attributes,
      in little-endian format.

      Practically the output of each efivar is composed of:

          +-----------------------------------+
          |4_bytes_of_attributes + efivar_data|
          +-----------------------------------+

ZZ0000ZZ

- Tài liệu/admin-guide/acpi/ssdt-overlays.rst
- Tài liệu/ABI/đã xóa/sysfs-firmware-efi-vars