.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/virt/guest-halt-polling.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================
Khách tạm dừng bỏ phiếu
==================

Trình điều khiển cpuidle_haltpoll, với bộ điều chỉnh dừng cuộc thăm dò, cho phép
vcpus khách sẽ thăm dò ý kiến trong một khoảng thời gian nhất định trước khi
dừng lại.

Điều này mang lại những lợi ích sau cho việc bỏ phiếu phía máy chủ:

1) Cờ POLL được đặt trong khi thực hiện bỏ phiếu, cho phép
	   vCPU từ xa để tránh gửi IPI (và
	   chi phí xử lý IPI) khi thực hiện đánh thức.

2) Có thể tránh được chi phí thoát VM.

Nhược điểm của việc bỏ phiếu phía khách là việc bỏ phiếu được thực hiện
ngay cả với các tác vụ có thể chạy khác trong máy chủ.

Logic cơ bản như sau: Giá trị toàn cục, guest_halt_poll_ns,
được người dùng cấu hình, cho biết số lượng tối đa
bỏ phiếu theo thời gian được cho phép. Giá trị này được cố định.

Mỗi vcpu có một guest_halt_poll_ns có thể điều chỉnh
("mỗi CPU guest_halt_poll_ns") được điều chỉnh bằng thuật toán
để đáp lại các sự kiện (được giải thích bên dưới).

Thông số mô-đun
=================

Bộ điều tốc dừng lại có 5 tham số mô-đun có thể điều chỉnh:

1) guest_halt_poll_ns:

Lượng thời gian tối đa, tính bằng nano giây, việc bỏ phiếu đó là
thực hiện trước khi tạm dừng.

Mặc định: 200000

2) guest_halt_poll_shrink:

Hệ số phân chia được sử dụng để thu nhỏ mỗi CPU guest_halt_poll_ns khi
sự kiện đánh thức xảy ra sau guest_halt_poll_ns toàn cầu.

Mặc định: 2

3) guest_halt_poll_grow:

Hệ số nhân được sử dụng để tăng trên mỗi CPU guest_halt_poll_ns
khi sự kiện xảy ra sau mỗi CPU guest_halt_poll_ns
nhưng trước toàn cầu guest_halt_poll_ns.

Mặc định: 2

4) guest_halt_poll_grow_start:

Mỗi CPU guest_halt_poll_ns cuối cùng đạt đến 0
trong trường hợp hệ thống nhàn rỗi. Giá trị này đặt giá trị ban đầu
mỗi CPU guest_halt_poll_ns khi phát triển. Điều này có thể
được tăng từ 10000, để tránh bỏ lỡ trong lần đầu
giai đoạn tăng trưởng:

10k, 20k, 40k, ... (ví dụ giả sử guest_halt_poll_grow=2).

Mặc định: 50000

5) guest_halt_poll_allow_shrink:

Tham số Bool cho phép thu nhỏ. Đặt thành N
để tránh điều đó (mỗi CPU guest_halt_poll_ns sẽ vẫn còn
cao một khi đạt được giá trị toàn cầu guest_halt_poll_ns).

Mặc định: Có

Các tham số mô-đun có thể được đặt từ các tệp sysfs trong ::

/sys/module/haltpoll/tham số/

Ghi chú thêm
=============

- Cần cẩn thận khi đặt tham số guest_halt_poll_ns làm
  giá trị lớn có khả năng thúc đẩy mức sử dụng cpu lên 100% trên máy
  nếu không thì gần như hoàn toàn không hoạt động.
