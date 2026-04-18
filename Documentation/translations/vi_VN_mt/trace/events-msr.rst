.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/events-msr.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==================
Sự kiện theo dõi MSR
================

Nhân x86 hỗ trợ theo dõi hầu hết các truy cập MSR (Đăng ký cụ thể theo mẫu).
Để xem định nghĩa của MSR trên hệ thống Intel, vui lòng xem SDM
tại ZZ0000ZZ (Tập 3)

Điểm theo dõi có sẵn:

/sys/kernel/tracing/sự kiện/msr/

Dấu vết MSR đọc:

đọc_msr

- msr: số MSR
  - val: Giá trị ghi
  - không thành công: 1 nếu truy cập không thành công, nếu không thì 0


Dấu vết MSR viết:

viết_msr

- msr: số MSR
  - val: Giá trị ghi
  - không thành công: 1 nếu truy cập không thành công, nếu không thì 0


Theo dõi RDPMC trong kernel:

rdpmc

Dữ liệu theo dõi có thể được xử lý sau bằng tập lệnh postprocess/decode_msr.py ::

cat /sys/kernel/tracing/trace | giải mã_msr.py /usr/src/linux/include/asm/msr-index.h

để thêm tên MSR tượng trưng.

