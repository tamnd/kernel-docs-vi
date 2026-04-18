.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm64/ptdump.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================
Kết xuất bảng trang hạt nhân
======================

ptdump là một giao diện debugfs cung cấp kết xuất chi tiết của
bảng trang hạt nhân. Nó cung cấp một cái nhìn tổng quan toàn diện về kernel
bố trí bộ nhớ ảo cũng như các thuộc tính liên quan đến
các vùng khác nhau ở định dạng mà con người có thể đọc được. Nó rất hữu ích để đổ
bảng trang kernel để xác minh quyền và loại bộ nhớ. Kiểm tra
các mục và quyền của bảng trang giúp xác định khả năng bảo mật
các lỗ hổng như ánh xạ với quyền truy cập quá dễ dãi hoặc
bảo vệ bộ nhớ không đúng cách.

Bộ cắm nóng bộ nhớ cho phép mở rộng hoặc thu hẹp động các dữ liệu có sẵn
bộ nhớ mà không cần phải khởi động lại hệ thống. Để duy trì tính nhất quán
và tính toàn vẹn của cấu trúc dữ liệu quản lý bộ nhớ, arm64 sử dụng
của semaphore ZZ0000ZZ ở chế độ ghi. Ngoài ra, trong
chế độ đọc, ZZ0001ZZ hỗ trợ triển khai hiệu quả
ZZ0002ZZ và ZZ0003ZZ. Những điều này bảo vệ
ngoại tuyến bộ nhớ đang được truy cập bằng mã ptdump.

Để kết xuất các bảng trang kernel, hãy kích hoạt tính năng sau
cấu hình và gắn kết debugfs::

CONFIG_PTDUMP_DEBUGFS=y

mount -t debugfs nodev/sys/kernel/debug
 mèo /sys/kernel/debug/kernel_page_tables

Về phân tích đầu ra của ZZ0000ZZ
người ta có thể lấy được thông tin về dải địa chỉ ảo của mục nhập,
theo sau là kích thước của vùng bộ nhớ được đề cập trong mục này,
cấu trúc phân cấp của các bảng trang và cuối cùng là các thuộc tính
liên kết với mỗi trang. Các thuộc tính trang cung cấp thông tin về
quyền truy cập, khả năng thực thi, loại ánh xạ như lá
cấp PTE hoặc cấp khối PGD, PMD và PUD và trạng thái truy cập của một trang
trong bộ nhớ hạt nhân. Việc đánh giá các thuộc tính này có thể hỗ trợ
hiểu cách bố trí bộ nhớ, kiểu truy cập và bảo mật
đặc điểm của các trang kernel.

Ví dụ về bố cục bộ nhớ ảo hạt nhân::

thuộc tính kích thước địa chỉ bắt đầu của địa chỉ cuối
 +-------------------------------------------------------------------------------------------------------+
 ZZ0000ZZ
 ZZ0001ZZ
 ZZ0002ZZ
 ZZ0003ZZ
 ZZ0004ZZ
 ZZ0005ZZ
 +-------------------------------------------------------------------------------------------------------+
 ZZ0006ZZ
 ZZ0007ZZ
 ZZ0008ZZ
 ZZ0009ZZ
 ZZ0010ZZ
 +-------------------------------------------------------------------------------------------------------+
 ZZ0011ZZ
 ZZ0012ZZ
 ZZ0013ZZ
 ZZ0014ZZ
 ZZ0015ZZ
 ZZ0016ZZ
 +-------------------------------------------------------------------------------------------------------+
 ZZ0017ZZ
 ZZ0018ZZ
 ZZ0019ZZ
 ZZ0020ZZ
 ZZ0021ZZ
 ZZ0022ZZ
 +-------------------------------------------------------------------------------------------------------+
 ZZ0023ZZ
 ZZ0024ZZ
 ZZ0025ZZ
 ZZ0026ZZ
 ZZ0027ZZ
 +-------------------------------------------------------------------------------------------------------+
 ZZ0028ZZ
 ZZ0029ZZ
 ZZ0030ZZ
 ZZ0031ZZ
 ZZ0032ZZ
 ZZ0033ZZ
 +-------------------------------------------------------------------------------------------------------+

Đầu ra ZZ0000ZZ::

0xfff0000001c00000-0xfff0000080000000 2020M PTE RW NX SHD AF UXN MEM/NORMAL-TAGGED
 0xfff0000080000000-0xfff0000800000000 30G PMD
 0xfff0000800000000-0xfff0000800700000 7M PTE RW NX SHD AF UXN MEM/NORMAL-TAGGED
 0xfff0000800700000-0xfff0000800710000 64K PTE ro NX SHD AF UXN MEM/NORMAL-TAGGED
 0xfff0000800710000-0xfff0000880000000 2089920K PTE RW NX SHD AF UXN MEM/NORMAL-TAGGED
 0xfff0000880000000-0xfff0040000000000 4062G PMD
 0xfff0040000000000-0xffff8000000000000 3964T PGD
