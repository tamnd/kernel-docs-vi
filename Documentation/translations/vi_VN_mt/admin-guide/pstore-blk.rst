.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/pstore-blk.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

khối pstore rất tiếc/logger hoảng loạn
==============================

Giới thiệu
------------

khối pstore (pstore/blk) là một trình ghi nhật ký rất tiếc/hoảng loạn ghi nhật ký của nó vào một
chặn thiết bị và thiết bị không chặn trước khi hệ thống gặp sự cố. Bạn có thể nhận được
các tệp nhật ký này bằng cách gắn hệ thống tệp pstore như ::

mount -t pstore pstore /sys/fs/pstore


khái niệm khối pstore
---------------------

pstore/blk cung cấp phương thức cấu hình hiệu quả cho pstore/blk,
chia tất cả các cấu hình thành hai phần, cấu hình cho người dùng và
cấu hình cho driver.

Cấu hình cho người dùng xác định cách hoạt động của pstore/blk, chẳng hạn như pmsg_size,
kmsg_size, v.v. Tất cả đều hỗ trợ cả tham số Kconfig và mô-đun,
nhưng các tham số mô-đun được ưu tiên hơn Kconfig.

Cấu hình cho trình điều khiển đều là thiết bị khối và thiết bị không chặn,
chẳng hạn như tổng_kích thước của thiết bị khối và các thao tác đọc/ghi.

Cấu hình cho người dùng
-----------------------

Tất cả các cấu hình này đều hỗ trợ cả tham số Kconfig và mô-đun, nhưng
tham số mô-đun có mức độ ưu tiên hơn Kconfig.

Đây là một ví dụ cho các tham số mô-đun::

pstore_blk.blkdev=/dev/mmcblk0p7 pstore_blk.kmsg_size=64 best_effort=y

Chi tiết của từng cấu hình có thể khiến bạn quan tâm.

blkdev
~~~~~~

Thiết bị khối để sử dụng. Hầu hết thời gian, nó là một phân vùng của thiết bị khối.
Nó là cần thiết cho pstore/blk. Nó cũng được sử dụng cho thiết bị MTD.

Khi pstore/blk được xây dựng dưới dạng mô-đun, "blkdev" chấp nhận các biến thể sau:

1. /dev/<disk_name> đại diện cho số thiết bị của đĩa
#. /dev/<disk_name><decimal> thể hiện số lượng thiết bị của phân vùng - thiết bị
   số lượng đĩa cộng với số phân vùng
#. /dev/<disk_name>p<decimal> - giống như trên; biểu mẫu này được sử dụng khi đĩa
   tên của đĩa được phân vùng kết thúc bằng một chữ số.

Khi pstore/blk được tích hợp vào kernel, "blkdev" chấp nhận các biến thể sau:

#. Số thiết bị <hex_major><hex_minor> ở dạng biểu diễn thập lục phân,
   không có 0x đứng đầu, ví dụ b302.
#. PARTUUID=00112233-4455-6677-8899-AABBCCDDEEFF đại diện cho id duy nhất của
   một phân vùng nếu bảng phân vùng cung cấp nó. UUID có thể là một
   EFI/GPT UUID hoặc tham khảo phân vùng MSDOS sử dụng định dạng SSSSSSSS-PP,
   trong đó SSSSSSSS là biểu diễn hex chứa đầy 0 của 32-bit
   "Chữ ký đĩa NT" và PP là biểu diễn hex chứa đầy số 0 của
   Số phân vùng dựa trên 1.
#. PARTUUID=<UUID>/PARTNROFF=<int> để chọn một phân vùng liên quan đến một
   phân vùng có id duy nhất đã biết.
#. <major>:<minor> số chính và số thứ của thiết bị được phân tách bằng dấu hai chấm.

Nó chấp nhận các biến thể sau cho thiết bị MTD:

1. <tên thiết bị> Tên thiết bị MTD. "pstore" được khuyến khích.
#. <số thiết bị> Số thiết bị MTD.

kmsg_size
~~~~~~~~~

Kích thước khối tính bằng KB cho giao diện người dùng rất tiếc/hoảng loạn. ZZ0000ZZ là bội số của 4.
Đó là tùy chọn nếu bạn không quan tâm đến nhật ký rất tiếc/hoảng loạn.

Có nhiều phần dành cho giao diện người dùng rất tiếc/hoảng loạn tùy thuộc vào phần còn lại
space ngoại trừ các giao diện người dùng pstore khác.

pstore/blk sẽ đăng nhập từng phần oops/panic và luôn ghi đè lên
đoạn cũ nhất nếu không còn đoạn trống nào nữa.

chiều_size
~~~~~~~~~

Kích thước chunk tính bằng KB cho giao diện người dùng pmsg. ZZ0000ZZ là bội số của 4.
Đó là tùy chọn nếu bạn không quan tâm đến nhật ký pmsg.

Không giống như giao diện người dùng oops/panic, chỉ có một đoạn cho giao diện người dùng pmsg.

Pmsg là một đối tượng pstore có thể truy cập vào không gian người dùng. Ghi vào ZZ0000ZZ là
được thêm vào đoạn. Khi khởi động lại, nội dung có sẵn trong
ZZ0001ZZ.

console_size
~~~~~~~~~~~~

Kích thước khối tính bằng KB cho giao diện người dùng bảng điều khiển.  ZZ0000ZZ là bội số của 4.
Đó là tùy chọn nếu bạn không quan tâm đến nhật ký bảng điều khiển.

Tương tự như giao diện người dùng pmsg, chỉ có một đoạn dành cho giao diện người dùng console.

Tất cả nhật ký của bảng điều khiển sẽ được thêm vào đoạn này. Khi khởi động lại, nội dung là
có sẵn trong ZZ0000ZZ.

ftrace_size
~~~~~~~~~~~

Kích thước chunk tính bằng KB cho giao diện người dùng ftrace. ZZ0000ZZ là bội số của 4.
Đó là tùy chọn nếu bạn không quan tâm đến nhật ký ftrace.

Tương tự như giao diện người dùng rất tiếc, có nhiều khối cho giao diện người dùng ftrace
tùy thuộc vào số lượng bộ xử lý cpu. Mỗi kích thước khối bằng
ftrace_size / bộ vi xử lý_count.

Tất cả nhật ký của ftrace sẽ được thêm vào đoạn này. Khi khởi động lại, nội dung là
kết hợp và có sẵn trong ZZ0000ZZ.

Theo dõi chức năng liên tục có thể hữu ích để gỡ lỗi phần mềm hoặc phần cứng
liên quan bị treo. Dưới đây là một ví dụ về cách sử dụng::

# mount -t pstore pstore /sys/fs/pstore
 # mount -t debugfs debugfs /sys/kernel/debug/
 # echo 1 > /sys/kernel/debug/pstore/record_ftrace
 # reboot -f
 […]
 # mount -t pstore pstore /sys/fs/pstore
 # tail /sys/fs/pstore/ftrace-pstore-blk-0
 CPU:0 ts:5914676 c0063828 c0063b94 call_cpuidle <- cpu_startup_entry+0x1b8/0x1e0
 CPU:0 ts:5914678 c039ecdc c006385c cpuidle_enter_state <- call_cpuidle+0x44/0x48
 CPU:0 ts:5914680 c039e9a0 c039ecf0 cpuidle_enter_freeze <- cpuidle_enter_state+0x304/0x314
 CPU:0 ts:5914681 c0063870 c039ea30 sched_idle_set_state <- cpuidle_enter_state+0x44/0x314
 CPU:1 ts:5916720 c0160f59 c015ee04 kernfs_unmap_bin_file <- __kernfs_remove+0x140/0x204
 CPU:1 ts:5916721 c05ca625 c015ee0c __mutex_lock_slowpath <- __kernfs_remove+0x148/0x204
 CPU:1 ts:5916723 c05c813d c05ca630 năng suất_to <- __mutex_lock_slowpath+0x314/0x358
 CPU:1 ts:5916724 c05ca2d1 c05ca638 __ww_mutex_lock <- __mutex_lock_slowpath+0x31c/0x358

lý do tối đa
~~~~~~~~~~

Có thể kiểm soát việc giới hạn loại bãi chứa kmsg nào được lưu trữ thông qua
giá trị ZZ0000ZZ, như được xác định trong include/linux/kmsg_dump.h's
ZZ0001ZZ. Ví dụ: để lưu trữ cả Rất tiếc và Hoảng loạn,
ZZ0002ZZ phải được đặt thành 2 (KMSG_DUMP_OOPS), để chỉ lưu trữ Panics
ZZ0003ZZ phải được đặt thành 1 (KMSG_DUMP_PANIC). Đặt cái này thành 0
(KMSG_DUMP_UNDEF), có nghĩa là việc lọc lý do sẽ được kiểm soát bởi
Thông số khởi động ZZ0004ZZ: nếu không được đặt, nó sẽ là KMSG_DUMP_OOPS,
nếu không thì KMSG_DUMP_MAX.

Cấu hình cho driver
-------------------------

Trình điều khiển thiết bị sử dụng ZZ0000ZZ với
ZZ0001ZZ để đăng ký pstore/blk.

.. kernel-doc:: fs/pstore/blk.c
   :export:

Nén và tiêu đề
----------------------

Thiết bị khối đủ lớn cho dữ liệu rất tiếc không nén. Thực ra chúng tôi không
khuyên bạn nên nén dữ liệu vì pstore/blk sẽ chèn một số thông tin vào
dòng đầu tiên của dữ liệu rất tiếc/hoảng loạn. Ví dụ::

Hoảng loạn: Tổng cộng 16 lần

Điều đó có nghĩa là OOPS|Panic lần thứ 16 kể từ lần khởi động đầu tiên.
Đôi khi số lần xảy ra lỗi oops|hoảng loạn kể từ lần khởi động đầu tiên là
quan trọng để đánh giá xem hệ thống có ổn định hay không.

Dòng sau được chèn bởi hệ thống tập tin pstore. Ví dụ::

Rất tiếc#2 Phần 1

Có nghĩa là đó là OOPS lần thứ 2 trong lần khởi động cuối cùng.

Đọc dữ liệu
----------------

Dữ liệu kết xuất có thể được đọc từ hệ thống tập tin pstore. Định dạng cho những điều này
các tệp là ZZ0000ZZ dành cho giao diện người dùng rất tiếc/hoảng loạn,
ZZ0001ZZ cho giao diện người dùng pmsg, v.v.  Dấu thời gian của
tệp kết xuất ghi lại thời gian kích hoạt. Để xóa một bản ghi đã lưu khỏi khối
thiết bị, chỉ cần hủy liên kết tệp pstore tương ứng.

Những chú ý trong API đọc/ghi hoảng loạn
-----------------------------------

Nếu trong tình trạng hoảng loạn, kernel sẽ không chạy lâu hơn nữa, các tác vụ sẽ không
được lên lịch và hầu hết các tài nguyên kernel sẽ không còn hoạt động. Nó
trông giống như một chương trình đơn luồng chạy trên máy tính lõi đơn.

Các điểm sau đây cần được chú ý đặc biệt đối với các API đọc/ghi hoảng loạn:

1. ZZ0000ZZ có thể phân bổ bất kỳ bộ nhớ nào không.
   Nếu bạn cần bộ nhớ, chỉ cần phân bổ trong khi trình điều khiển khối đang khởi tạo
   thay vì chờ đợi cho đến khi hoảng loạn.
#. Phải được thăm dò, điều khiển ngắt ZZ0001ZZ.
   Không có lịch trình nhiệm vụ nữa. Trình điều khiển khối nên trì hoãn để đảm bảo việc ghi
   thành công nhưng NOT vẫn ngủ.
#. ZZ0002ZZ có thể lấy bất kỳ khóa nào không?
   Không có nhiệm vụ nào khác hoặc bất kỳ tài nguyên được chia sẻ nào; bạn được an toàn để phá vỡ tất cả
   ổ khóa.
#. Chỉ cần sử dụng CPU để chuyển.
   Không sử dụng DMA để chuyển trừ khi bạn chắc chắn rằng DMA sẽ không giữ khóa.
#. Kiểm soát đăng ký trực tiếp.
   Vui lòng kiểm soát trực tiếp các thanh ghi thay vì sử dụng tài nguyên nhân Linux.
   Thực hiện bản đồ I/O trong khi khởi tạo thay vì đợi cho đến khi xảy ra tình trạng hoảng loạn.
#. Đặt lại thiết bị khối và bộ điều khiển của bạn nếu cần thiết.
   Nếu bạn không chắc chắn về trạng thái của thiết bị khối và bộ điều khiển của mình khi
   một sự hoảng loạn xảy ra, bạn có thể an toàn dừng lại và thiết lập lại chúng.

pstore/blk hỗ trợ psblk_blkdev_info(), được định nghĩa trong
ZZ0000ZZ, để nhận thông tin về việc sử dụng thiết bị khối, chẳng hạn như
số thiết bị, số lượng khu vực và khu vực bắt đầu của toàn bộ đĩa.

khối nội bộ pstore
----------------------

Để nhà phát triển tham khảo, đây là tất cả các cấu trúc và API quan trọng:

.. kernel-doc:: fs/pstore/zone.c
   :internal:

.. kernel-doc:: include/linux/pstore_zone.h
   :internal:

.. kernel-doc:: include/linux/pstore_blk.h
   :internal: