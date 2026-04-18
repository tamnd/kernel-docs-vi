.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/allocation/dax.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============
Thiết bị DAX
============
Dung lượng CXL được hiển thị dưới dạng thiết bị DAX có thể được truy cập trực tiếp qua mmap.
Người dùng có thể muốn sử dụng cơ chế giao diện này để viết vùng người dùng của riêng họ
Bộ cấp phát CXL hoặc tới các vùng bộ nhớ được chia sẻ hoặc liên tục được quản lý trên nhiều
chủ nhà.

Nếu dung lượng được chia sẻ giữa các máy chủ hoặc việc xả liên tục, thích hợp
phải sử dụng các cơ chế trừ khi khu vực đó hỗ trợ Snoop Back-Invalidate.

Lưu ý rằng ánh xạ phải được căn chỉnh (kích thước và chân đế) với đế của thiết bị dax
căn chỉnh, thường là 2MB - nhưng có thể được định cấu hình lớn hơn.

::

#include <stdio.h>
  #include <stdlib.h>
  #include <stdint.h>
  #include <sys/mman.h>
  #include <fcntl.h>
  #include <unistd.h>

#define DEVICE_PATH "/dev/dax0.0" // Thay thế đường dẫn thiết bị DAX
  #define DEVICE_SIZE (4ULL * 1024 * 1024 * 1024) // 4GB

int chính() {
      int fd;
      void* mapped_addr;

/* Mở thiết bị DAX */
      fd = mở(DEVICE_PATH, O_RDWR);
      nếu (fd < 0) {
          lỗi ("mở");
          trả về -1;
      }

/* Ánh xạ thiết bị vào bộ nhớ */
      mapped_addr = mmap(NULL, DEVICE_SIZE, PROT_READ | PROT_WRITE,
                         MAP_SHARED, fd, 0);
      nếu (mapped_addr == MAP_FAILED) {
          lỗi ("mmap");
          đóng(fd);
          trả về -1;
      }

printf("Địa chỉ đã ánh xạ: %p\n", mapped_addr);

/* Bây giờ bạn có thể truy cập thiết bị thông qua địa chỉ được ánh xạ */
      uint64_t* ptr = (uint64_t*)mapped_addr;
      *ptr = 0x1234567890abcdef; // Ghi giá trị vào thiết bị
      printf("Giá trị tại địa chỉ %p: 0x%016llx\n", ptr, *ptr);

/*Dọn dẹp*/
      munmap(mapped_addr, DEVICE_SIZE);
      đóng(fd);
      trả về 0;
  }