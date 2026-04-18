.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/ring-buffer-map.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================
Ánh xạ bộ nhớ đệm vòng Tracefs
=====================================

:Tác giả: Vincent Donnefort <vdonnefort@google.com>

Tổng quan
=========
Bản đồ bộ nhớ đệm vòng Tracefs cung cấp một phương pháp hiệu quả để truyền dữ liệu
vì không cần sao chép bộ nhớ. Ứng dụng ánh xạ bộ đệm vòng trở thành
sau đó là người tiêu dùng cho bộ đệm vòng đó, theo cách tương tự như trace_pipe.

Thiết lập ánh xạ bộ nhớ
=======================
Ánh xạ hoạt động với mmap() của giao diện trace_pipe_raw.

Trang hệ thống đầu tiên của ánh xạ chứa số liệu thống kê về bộ đệm vòng và
mô tả. Nó được gọi là trang meta. Một trong những điều quan trọng nhất
các trường của trang meta là người đọc. Nó chứa ID bộ đệm phụ có thể
được người lập bản đồ đọc một cách an toàn (xem ring-buffer-design.rst).

Trang meta được theo sau bởi tất cả các bộ đệm phụ, được sắp xếp theo ID tăng dần. Đó là
do đó dễ dàng biết người đọc bắt đầu từ đâu trong bản đồ:

.. code-block:: c

        reader_id = meta->reader->id;
        reader_offset = meta->meta_page_size + reader_id * meta->subbuf_size;

Khi ứng dụng hoàn tất với trình đọc hiện tại, nó có thể nhận một ứng dụng mới bằng cách sử dụng
trace_pipe_raw ioctl() TRACE_MMAP_IOCTL_GET_READER. ioctl này cũng cập nhật
các trường siêu trang.

Hạn chế
===========
Khi ánh xạ được đặt trên bộ đệm vòng Tracefs, không thể
hoặc thay đổi kích thước của nó (bằng cách tăng toàn bộ kích thước của bộ đệm vòng hoặc
mỗi tiểu mục). Cũng không thể sử dụng ảnh chụp nhanh và khiến mối nối bị sao chép
dữ liệu bộ đệm vòng thay vì sử dụng trao đổi không sao chép từ bộ đệm vòng.

Các trình đọc đồng thời (hoặc một ứng dụng khác ánh xạ bộ đệm vòng đó hoặc
kernel với trace_pipe) được phép nhưng không được khuyến khích. Họ sẽ tranh giành
bộ đệm vòng và đầu ra không thể đoán trước được, giống như các trình đọc đồng thời trên
trace_pipe sẽ là như vậy.

Ví dụ
=======

.. code-block:: c

        #include <fcntl.h>
        #include <stdio.h>
        #include <stdlib.h>
        #include <unistd.h>

        #include <linux/trace_mmap.h>

        #include <sys/mman.h>
        #include <sys/ioctl.h>

        #define TRACE_PIPE_RAW "/sys/kernel/tracing/per_cpu/cpu0/trace_pipe_raw"

        int main(void)
        {
                int page_size = getpagesize(), fd, reader_id;
                unsigned long meta_len, data_len;
                struct trace_buffer_meta *meta;
                void *map, *reader, *data;

                fd = open(TRACE_PIPE_RAW, O_RDONLY | O_NONBLOCK);
                if (fd < 0)
                        exit(EXIT_FAILURE);

                map = mmap(NULL, page_size, PROT_READ, MAP_SHARED, fd, 0);
                if (map == MAP_FAILED)
                        exit(EXIT_FAILURE);

                meta = (struct trace_buffer_meta *)map;
                meta_len = meta->meta_page_size;

                printf("entries:        %llu\n", meta->entries);
                printf("overrun:        %llu\n", meta->overrun);
                printf("read:           %llu\n", meta->read);
                printf("nr_subbufs:     %u\n", meta->nr_subbufs);

                data_len = meta->subbuf_size * meta->nr_subbufs;
                data = mmap(NULL, data_len, PROT_READ, MAP_SHARED, fd, meta_len);
                if (data == MAP_FAILED)
                        exit(EXIT_FAILURE);

                if (ioctl(fd, TRACE_MMAP_IOCTL_GET_READER) < 0)
                        exit(EXIT_FAILURE);

                reader_id = meta->reader.id;
                reader = data + meta->subbuf_size * reader_id;

                printf("Current reader address: %p\n", reader);

                munmap(data, data_len);
                munmap(meta, meta_len);
                close (fd);

                return 0;
        }