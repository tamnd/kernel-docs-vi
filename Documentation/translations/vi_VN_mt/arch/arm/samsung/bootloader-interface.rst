.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/samsung/bootloader-interface.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================================================
Giao diện giữa kernel và bộ tải khởi động trên bo mạch Exynos
===============================================================

Tác giả: Krzysztof Kozlowski

Ngày: 6 tháng 6 năm 2015

Tài liệu cố gắng mô tả giao diện hiện đang được sử dụng giữa nhân Linux
và bộ tải khởi động trên bo mạch dựa trên Samsung Exynos. Đây không phải là một định nghĩa
của giao diện mà là một mô tả về trạng thái hiện tại, một tham chiếu
chỉ nhằm mục đích thông tin.

Trong tài liệu "bộ tải khởi động" có nghĩa là bất kỳ từ nào sau đây: U-boot, độc quyền
SBOOT hoặc bất kỳ chương trình cơ sở nào khác dành cho ARMv7 và ARMv8 khởi tạo bo mạch trước đó
thực thi hạt nhân.


1. Chế độ không bảo mật

Địa chỉ: sysram_ns_base_addr

============================================================ =====================
Mục Đích của Giá Trị Bù Trừ
============================================================ =====================
0x08 exynos_cpu_resume_ns, mcpm_entry_point Hệ thống tạm dừng
0x0c 0x00000bad (Magic cookie) Hệ thống tạm dừng
0x1c exynos4_secondary_startup Khởi động CPU thứ cấp
0x1c + 4*cpu exynos4_secondary_startup (Exynos4412) Khởi động thứ cấp CPU
0x20 0xfcba0d10 (Bánh quy ma thuật) AFTR
0x24 exynos_cpu_resume_ns AFTR
0x28 + 4*cpu 0x8 (Bánh quy ma thuật, Exynos3250) AFTR
0x28 0x0 hoặc giá trị cuối cùng trong quá trình tiếp tục (Exynos542x) Hệ thống tạm dừng
============================================================ =====================


2. Chế độ bảo mật

Địa chỉ: sysram_base_addr

============================================================ =====================
Mục Đích của Giá Trị Bù Trừ
============================================================ =====================
0x00 exynos4_secondary_startup Khởi động CPU thứ cấp
0x04 exynos4_secondary_startup (Exynos542x) Khởi động thứ cấp CPU
4*cpu exynos4_secondary_startup (Exynos4412) Khởi động thứ cấp CPU
0x20 exynos_cpu_resume (Exynos4210 r1.0) AFTR
0x24 0xfcba0d10 (Bánh quy ma thuật, Exynos4210 r1.0) AFTR
============================================================ =====================

Địa chỉ: pmu_base_addr

============================================================ =====================
Mục Đích của Giá Trị Bù Trừ
============================================================ =====================
0x0800 exynos_cpu_resume AFTR, tạm dừng
0x0800 mcpm_entry_point (Exynos542x với MCPM) AFTR, tạm dừng
0x0804 0xfcba0d10 (Bánh quy ma thuật) AFTR
0x0804 0x00000bad (Cookie ma thuật) Hệ thống tạm dừng
0x0814 exynos4_secondary_startup (Exynos4210 r1.1) Khởi động thứ cấp CPU
0x0818 0xfcba0d10 (Bánh quy ma thuật, Exynos4210 r1.1) AFTR
0x081C exynos_cpu_resume (Exynos4210 r1.1) AFTR
============================================================ =====================

3. Khác (bất kể chế độ an toàn/không bảo mật)

Địa chỉ: pmu_base_addr

============== ================================ ===================================
Mục Đích của Giá Trị Bù Trừ
============== ================================ ===================================
0x0908 Chỉ báo khởi động CPU thứ cấp khác 0
                                              trên Exynos3250 và Exynos542x
============== ================================ ===================================


4. Bảng thuật ngữ

AFTR - ARM Off Top Running, chế độ năng lượng thấp, lõi Cortex và nhiều thứ khác
các mô-đun được cấp nguồn, ngoại trừ các mô-đun TOP
MCPM - Quản lý năng lượng đa cụm
