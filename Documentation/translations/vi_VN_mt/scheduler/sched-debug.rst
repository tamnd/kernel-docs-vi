.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scheduler/sched-debug.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===================
Gỡ lỗi lập lịch
=================

Khởi động kernel có bật debugfs sẽ cấp quyền truy cập vào
các tệp gỡ lỗi cụ thể của bộ lập lịch trong /sys/kernel/debug/sched. Một số
những tập tin đó được mô tả dưới đây.

số_cân bằng
==============

Thư mục ZZ0000ZZ dùng để chứa các file để điều khiển NUMA
tính năng cân bằng.  Nếu chi phí hệ thống của tính năng này quá
cao thì tỷ lệ các mẫu hạt nhân tìm lỗi gợi ý NUMA có thể là
được kiểm soát bởi các tập tin ZZ0001ZZ.


scan_ Period_min_ms, scan_delay_ms, scan_ Period_max_ms, scan_size_mb
-------------------------------------------------------------------

Tự động cân bằng NUMA quét không gian địa chỉ của tác vụ và hủy ánh xạ các trang tới
phát hiện xem các trang có được đặt đúng vị trí hay không hoặc dữ liệu có nên được di chuyển sang một
nút bộ nhớ cục bộ nơi tác vụ đang chạy.  Mỗi tác vụ "quét trễ"
quét số trang "kích thước quét" tiếp theo trong không gian địa chỉ của nó. Khi
đến hết không gian địa chỉ, máy quét sẽ khởi động lại từ đầu.

Kết hợp lại, "độ trễ quét" và "kích thước quét" xác định tốc độ quét.
Khi "độ trễ quét" giảm, tốc độ quét sẽ tăng lên.  Độ trễ quét và
do đó tốc độ quét của mọi tác vụ có tính thích ứng và phụ thuộc vào lịch sử
hành vi. Nếu các trang được đặt đúng cách thì độ trễ quét sẽ tăng lên,
nếu không độ trễ quét sẽ giảm.  "Kích thước quét" không thích ứng nhưng
"kích thước quét càng cao", tốc độ quét càng cao.

Tốc độ quét cao hơn sẽ phát sinh chi phí hệ thống cao hơn do lỗi trang phải được xử lý.
bị mắc kẹt và có khả năng dữ liệu phải được di chuyển. Tuy nhiên, mức quét càng cao
thì bộ nhớ tác vụ được di chuyển sang nút cục bộ càng nhanh nếu
mô hình khối lượng công việc thay đổi và giảm thiểu tác động đến hiệu suất do điều khiển từ xa
truy cập bộ nhớ. Những tập tin này kiểm soát ngưỡng độ trễ quét và
số lượng trang được quét.

ZZ0000ZZ là thời gian tối thiểu tính bằng mili giây để quét một
nhiệm vụ bộ nhớ ảo. Nó kiểm soát hiệu quả việc quét tối đa
giá cho từng nhiệm vụ.

ZZ0000ZZ là "độ trễ quét" bắt đầu được sử dụng cho một tác vụ khi nó
ban đầu là nĩa.

ZZ0000ZZ là thời gian tối đa tính bằng mili giây để quét một
nhiệm vụ bộ nhớ ảo. Nó kiểm soát hiệu quả việc quét tối thiểu
giá cho từng nhiệm vụ.

ZZ0000ZZ là số trang có dung lượng megabyte được quét
một lần quét nhất định.
