.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/xtensa/mmu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================================
Trình tự khởi tạo MMUv3
=============================

Mã trong macro khởi tạo_mmu thiết lập ánh xạ bộ nhớ MMUv3
giống hệt với ánh xạ bộ nhớ cố định MMUv2. Tùy thuộc vào
Ký hiệu CONFIG_INITIALIZE_XTENSA_MMU_INSIDE_VMLINUX mã này là
nằm ở các địa chỉ mà nó được liên kết (ký hiệu không xác định) hoặc không
(ký hiệu được xác định), vì vậy nó cần độc lập với vị trí.

Mã này có các giả định sau:

- Đoạn mã này chỉ chạy trên MMU v3.
  - TLB đang ở trạng thái reset.
  - ITLBCFG và DTLBCFG bằng 0 (trạng thái đặt lại).
  - RASID là 0x04030201 (trạng thái đặt lại).
  - PS.RING bằng 0 (trạng thái đặt lại).
  - LITBASE bằng 0 (trạng thái đặt lại, chữ tương đối với PC); bắt buộc phải là PIC.

Quá trình thiết lập TLB tiến hành theo các bước sau.

Huyền thoại:

- VA = địa chỉ ảo (hai phần trên của nó);
    - PA = địa chỉ vật lý (hai phần trên của nó);
    - pc = phạm vi vật lý chứa mã này;

Sau bước 2, chúng ta chuyển đến địa chỉ ảo trong phạm vi 0x40000000..0x5fffffff
hoặc 0x00000000..0x1fffffff, tùy thuộc vào việc kernel đã được tải bên dưới hay chưa
0x40000000 trở lên. Địa chỉ đó tương ứng với lệnh tiếp theo để thực thi
trong mã này. Sau bước 4, chúng tôi chuyển đến địa chỉ dự định (được liên kết) của mã này.
Lược đồ bên dưới giả định rằng kernel được tải dưới 0x40000000.

====== ===== ===== ===== ===== ====== ===== =====
 - Bước0 Bước1 Bước2 Bước3 Bước4 Bước5

VA PA PA PA PA VA PA PA
 ====== ===== ===== ===== ===== ====== ===== =====
 E0..FF -> E0 -> E0 -> E0 F0..FF -> F0 -> F0
 C0..DF -> C0 -> C0 -> C0 E0..EF -> F0 -> F0
 A0..BF -> A0 -> A0 -> A0 D8..DF -> 00 -> 00
 80..9F -> 80 -> 80 -> 80 D0..D7 -> 00 -> 00
 60..7F -> 60 -> 60 -> 60
 40..5F -> 40 -> máy tính -> máy tính 40..5F -> máy tính
 20..3F -> 20 -> 20 -> 20
 00..1F -> 00 -> 00 -> 00
 ====== ===== ===== ===== ===== ====== ===== =====

Vị trí mặc định của thiết bị ngoại vi IO là trên 0xf0000000. Điều này có thể được thay đổi
sử dụng thuộc tính "phạm vi" trong nút bus đơn giản của cây thiết bị. Xem cây thiết bị
Đặc tả, phần 4.5 để biết chi tiết về cú pháp và ngữ nghĩa của
các nút xe buýt đơn giản. Những hạn chế sau đây được áp dụng:

1. Chỉ các nút xe buýt đơn giản cấp cao nhất mới được xem xét

2. Chỉ xem xét một nút bus đơn giản (đầu tiên)

3. Thuộc tính "phạm vi" trống không được hỗ trợ

4. Chỉ bộ ba đầu tiên trong thuộc tính "phạm vi" mới được xem xét

5. Giá trị địa chỉ bus gốc được làm tròn xuống ranh giới 256 MB gần nhất

6. Vùng IO bao gồm toàn bộ phân đoạn 256 MB của địa chỉ xe buýt gốc; cái
   Trường độ dài bộ ba "phạm vi" bị bỏ qua


Bố cục không gian địa chỉ MMUv3.
============================

Bố cục tương thích MMUv2 mặc định::

Ký hiệu VADDR Kích thước
  +-------------------+
  ZZ0000ZZ 0x00000000 TASK_SIZE
  +-------------------+ 0x40000000
  +-------------------+
  ZZ0001ZZ XCHAL_PAGE_TABLE_VADDR 0x80000000 XCHAL_PAGE_TABLE_SIZE
  +-------------------+
  ZZ0002ZZ KASAN_SHADOW_START 0x80400000 KASAN_SHADOW_SIZE
  +-------------------+ 0x8e400000
  +-------------------+
  ZZ0003ZZ VMALLOC_START 0xc0000000 128MB - 64KB
  +-------------------+ VMALLOC_END
  +-------------------+
  ZZ0004ZZ TLBTEMP_BASE_1 0xc8000000 DCACHE_WAY_SIZE
  ZZ0005ZZ
  +-------------------+
  ZZ0006ZZ TLBTEMP_BASE_2 DCACHE_WAY_SIZE
  ZZ0007ZZ
  +-------------------+
  +-------------------+
  ZZ0008ZZ PKMAP_BASE PTRS_PER_PTE *
  ZZ0009ZZ DCACHE_N_COLORS *
  ZZ0010ZZ PAGE_SIZE
  ZZ0011ZZ (4MB * DCACHE_N_COLORS)
  +-------------------+
  ZZ0012ZZ FIXADDR_START KM_TYPE_NR *
  ZZ0013ZZ NR_CPUS *
  ZZ0014ZZ DCACHE_N_COLORS *
  ZZ0015ZZ PAGE_SIZE
  +-------------------+ FIXADDR_TOP 0xcffff000
  +-------------------+
  ZZ0016ZZ XCHAL_KSEG_CACHED_VADDR 0xd0000000 128MB
  +-------------------+
  ZZ0017ZZ XCHAL_KSEG_BYPASS_VADDR 0xd8000000 128MB
  +-------------------+
  ZZ0018ZZ XCHAL_KIO_CACHED_VADDR 0xe0000000 256MB
  +-------------------+
  ZZ0019ZZ XCHAL_KIO_BYPASS_VADDR 0xf0000000 256MB
  +-------------------+


256 MB được lưu vào bộ nhớ đệm + 256 MB bố cục không được lưu vào bộ đệm::

Ký hiệu VADDR Kích thước
  +-------------------+
  ZZ0000ZZ 0x00000000 TASK_SIZE
  +-------------------+ 0x40000000
  +-------------------+
  ZZ0001ZZ XCHAL_PAGE_TABLE_VADDR 0x80000000 XCHAL_PAGE_TABLE_SIZE
  +-------------------+
  ZZ0002ZZ KASAN_SHADOW_START 0x80400000 KASAN_SHADOW_SIZE
  +-------------------+ 0x8e400000
  +-------------------+
  ZZ0003ZZ VMALLOC_START 0xa0000000 128MB - 64KB
  +-------------------+ VMALLOC_END
  +-------------------+
  ZZ0004ZZ TLBTEMP_BASE_1 0xa8000000 DCACHE_WAY_SIZE
  ZZ0005ZZ
  +-------------------+
  ZZ0006ZZ TLBTEMP_BASE_2 DCACHE_WAY_SIZE
  ZZ0007ZZ
  +-------------------+
  +-------------------+
  ZZ0008ZZ PKMAP_BASE PTRS_PER_PTE *
  ZZ0009ZZ DCACHE_N_COLORS *
  ZZ0010ZZ PAGE_SIZE
  ZZ0011ZZ (4MB * DCACHE_N_COLORS)
  +-------------------+
  ZZ0012ZZ FIXADDR_START KM_TYPE_NR *
  ZZ0013ZZ NR_CPUS *
  ZZ0014ZZ DCACHE_N_COLORS *
  ZZ0015ZZ PAGE_SIZE
  +-------------------+ FIXADDR_TOP 0xaffff000
  +-------------------+
  ZZ0016ZZ XCHAL_KSEG_CACHED_VADDR 0xb0000000 256MB
  +-------------------+
  ZZ0017ZZ XCHAL_KSEG_BYPASS_VADDR 0xc0000000 256MB
  +-------------------+
  +-------------------+
  ZZ0018ZZ XCHAL_KIO_CACHED_VADDR 0xe0000000 256MB
  +-------------------+
  ZZ0019ZZ XCHAL_KIO_BYPASS_VADDR 0xf0000000 256MB
  +-------------------+


512 MB được lưu vào bộ nhớ đệm + 512 MB bố cục không được lưu vào bộ đệm::

Ký hiệu VADDR Kích thước
  +-------------------+
  ZZ0000ZZ 0x00000000 TASK_SIZE
  +-------------------+ 0x40000000
  +-------------------+
  ZZ0001ZZ XCHAL_PAGE_TABLE_VADDR 0x80000000 XCHAL_PAGE_TABLE_SIZE
  +-------------------+
  ZZ0002ZZ KASAN_SHADOW_START 0x80400000 KASAN_SHADOW_SIZE
  +-------------------+ 0x8e400000
  +-------------------+
  ZZ0003ZZ VMALLOC_START 0x90000000 128MB - 64KB
  +-------------------+ VMALLOC_END
  +-------------------+
  ZZ0004ZZ TLBTEMP_BASE_1 0x98000000 DCACHE_WAY_SIZE
  ZZ0005ZZ
  +-------------------+
  ZZ0006ZZ TLBTEMP_BASE_2 DCACHE_WAY_SIZE
  ZZ0007ZZ
  +-------------------+
  +-------------------+
  ZZ0008ZZ PKMAP_BASE PTRS_PER_PTE *
  ZZ0009ZZ DCACHE_N_COLORS *
  ZZ0010ZZ PAGE_SIZE
  ZZ0011ZZ (4MB * DCACHE_N_COLORS)
  +-------------------+
  ZZ0012ZZ FIXADDR_START KM_TYPE_NR *
  ZZ0013ZZ NR_CPUS *
  ZZ0014ZZ DCACHE_N_COLORS *
  ZZ0015ZZ PAGE_SIZE
  +-------------------+ FIXADDR_TOP 0x9ffff000
  +-------------------+
  ZZ0016ZZ XCHAL_KSEG_CACHED_VADDR 0xa0000000 512MB
  +-------------------+
  ZZ0017ZZ XCHAL_KSEG_BYPASS_VADDR 0xc0000000 512MB
  +-------------------+
  ZZ0018ZZ XCHAL_KIO_CACHED_VADDR 0xe0000000 256MB
  +-------------------+
  ZZ0019ZZ XCHAL_KIO_BYPASS_VADDR 0xf0000000 256MB
  +-------------------+
