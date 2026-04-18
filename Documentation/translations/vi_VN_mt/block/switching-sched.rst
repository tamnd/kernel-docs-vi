.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/block/switching-sched.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================
Chuyển đổi lịch trình
=====================

Mỗi hàng đợi io có một tập hợp các bộ điều chỉnh lịch trình io được liên kết với nó. Những cái này
điều chỉnh kiểm soát cách hoạt động của bộ lập lịch io. Bạn có thể tìm thấy những mục này
trong::

/sys/block/<thiết bị>/queue/iosched

giả sử rằng bạn đã gắn sysfs trên/sys. Nếu bạn chưa gắn sysfs,
bạn có thể làm như vậy bằng cách gõ::

# mount không có /sys -t sysfs

Có thể thay đổi bộ lập lịch IO cho một thiết bị khối nhất định trên
bay để chọn một trong các bộ lập lịch mq-deadline, none, bfq hoặc kyber -
có thể cải thiện thông lượng của thiết bị đó.

Để đặt lịch trình cụ thể, chỉ cần thực hiện việc này::

echo SCHEDNAME > /sys/block/DEV/queue/lịch trình

trong đó SCHEDNAME là tên của bộ lập lịch IO được xác định và DEV là
tên thiết bị (hda, hdb, sga hoặc bất cứ tên nào bạn có).

Danh sách các bộ lập lịch được xác định có thể được tìm thấy bằng cách thực hiện
a "cat /sys/block/DEV/queue/scheduler" - danh sách các tên hợp lệ
sẽ được hiển thị, với bộ lập lịch hiện được chọn trong ngoặc::

# cat/sys/block/sda/queue/lịch trình
  [mq-hạn chót] kyber bfq không có
  # echo không có >/sys/block/sda/queue/scheduler
  # cat/sys/block/sda/queue/lịch trình
  [không có] mq-thời hạn kyber bfq
