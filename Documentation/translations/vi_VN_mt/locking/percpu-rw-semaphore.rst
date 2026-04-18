.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/locking/percpu-rw-semaphore.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Các ngữ nghĩa Percpu rw
=======================

Percpu rw semaphores là một thiết kế semaphore đọc-ghi mới
được tối ưu hóa để khóa để đọc.

Vấn đề với các ẩn dụ đọc-ghi truyền thống là khi nhiều
lõi lấy khóa để đọc, dòng bộ đệm chứa semaphore
đang nảy giữa các bộ đệm L1 của lõi, gây ra hiệu suất
sự xuống cấp.

Khóa để đọc rất nhanh, nó sử dụng RCU và tránh mọi nguyên tử
hướng dẫn trong đường dẫn khóa và mở khóa. Mặt khác, khóa cho
việc viết rất tốn kém, nó gọi sync_rcu() có thể mất
hàng trăm mili giây.

Khóa được khai báo bằng loại "struct percpu_rw_semaphore".
Khóa được khởi tạo với percpu_init_rwsem, nó trả về 0 nếu thành công
và -ENOMEM khi phân bổ thất bại.
Khóa phải được giải phóng bằng percpu_free_rwsem để tránh rò rỉ bộ nhớ.

Khóa bị khóa để đọc với percpu_down_read, percpu_up_read và
để viết bằng percpu_down_write, percpu_up_write.

Ý tưởng sử dụng RCU để tối ưu hóa khóa rw đã được giới thiệu bởi
Eric Dumazet <eric.dumazet@gmail.com>.
Mã được viết bởi Mikulas Patocka <mpatocka@redhat.com>
