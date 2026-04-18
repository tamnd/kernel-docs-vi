.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/x86_64/uefi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================================
Lưu ý chung về hỗ trợ [U]EFI x86_64
=====================================

Danh pháp EFI và UEFI được sử dụng thay thế cho nhau trong tài liệu này.

Mặc dù các công cụ bên dưới _không_ cần thiết cho việc xây dựng kernel,
hỗ trợ bootloader cần thiết và các công cụ liên quan cho nền tảng x86_64
với phần sụn EFI và thông số kỹ thuật được liệt kê bên dưới.

1. Đặc điểm kỹ thuật UEFI: ZZ0000ZZ

2. Việc khởi động kernel Linux trên nền tảng UEFI x86_64 có thể là
   được thực hiện bằng cách sử dụng <Documentation/admin-guide/efi-stub.rst> hoặc sử dụng
   bộ nạp khởi động riêng biệt.

3. Nền tảng x86_64 với phần mềm EFI/UEFI.

Cơ học
---------

Tham khảo <Documentation/admin-guide/efi-stub.rst> để tìm hiểu cách sử dụng sơ khai EFI.

Dưới đây là hướng dẫn thiết lập EFI chung trên nền tảng x86_64,
bất kể bạn sử dụng sơ khai EFI hay bộ tải khởi động riêng.

- Build kernel với cấu hình như sau::

CONFIG_FB_EFI=y
	CONFIG_FRAMEBUFFER_CONSOLE=y

Nếu các dịch vụ thời gian chạy EFI được mong đợi, cấu hình sau sẽ
  được chọn::

CONFIG_EFI=y
	CONFIG_EFIVAR_FS=y hoặc m # optional

- Tạo phân vùng VFAT trên đĩa bằng cờ Hệ thống EFI
    Bạn có thể thực hiện việc này với fdisk bằng các lệnh sau:

1. g - khởi tạo bảng phân vùng GPT
        2. n - tạo phân vùng mới
        3. t - thay đổi loại phân vùng thành "EFI System" (số 1)
        4. w - viết và lưu các thay đổi

Sau đó, khởi tạo hệ thống tệp VFAT bằng cách chạy mkfs::

mkfs.fat /dev/<your-partition>

- Copy file boot vào phân vùng VFAT:
    Nếu bạn sử dụng phương thức sơ khai EFI, kernel cũng hoạt động như một tệp thực thi EFI.

Bạn chỉ có thể sao chép bzImage vào đường dẫn EFI/boot/bootx64.efi trên phân vùng
    để nó tự động khởi động, hãy xem trang <Documentation/admin-guide/efi-stub.rst>
    để biết hướng dẫn bổ sung về việc chuyển các tham số kernel và initramfs.

Nếu bạn sử dụng bộ tải khởi động tùy chỉnh, hãy tham khảo tài liệu liên quan để được trợ giúp về phần này.

- Nếu một số hoặc tất cả dịch vụ thời gian chạy EFI không hoạt động, bạn có thể thử làm theo
  tham số dòng lệnh kernel để tắt một số hoặc tất cả thời gian chạy EFI
  dịch vụ.

noefi
		tắt tất cả các dịch vụ thời gian chạy EFI
	khởi động lại_type=k
		tắt dịch vụ thời gian chạy khởi động lại EFI

- Nếu bản đồ bộ nhớ EFI có các mục bổ sung không có trong bản đồ E820,
  bạn có thể bao gồm các mục đó trong bản đồ bộ nhớ hạt nhân có sẵn
  RAM vật lý bằng cách sử dụng tham số dòng lệnh kernel sau.

add_efi_memmap
		bao gồm bản đồ bộ nhớ EFI của RAM vật lý có sẵn