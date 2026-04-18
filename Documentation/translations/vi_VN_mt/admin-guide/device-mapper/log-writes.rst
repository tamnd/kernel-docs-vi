.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/log-writes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============
dm-log-ghi
==============

Mục tiêu này cần 2 thiết bị, một thiết bị chuyển tất cả IO sang bình thường và một thiết bị ghi nhật ký tất cả
của các hoạt động ghi vào.  Điều này dành cho các nhà phát triển hệ thống tập tin mong muốn
để xác minh tính toàn vẹn của siêu dữ liệu hoặc dữ liệu khi hệ thống tệp được ghi vào.
Có một log_write_entry được viết cho mọi yêu cầu WRITE và mục tiêu là
có thể lấy dữ liệu tùy ý từ không gian người dùng để chèn vào nhật ký.  Dữ liệu
trong WRITE, các yêu cầu được sao chép vào nhật ký để thực hiện việc phát lại
chính xác như nó đã xảy ra ban đầu.

Đặt hàng nhật ký
================

Chúng tôi ghi lại mọi thứ theo thứ tự hoàn thành khi chúng tôi chắc chắn rằng việc ghi không còn nữa
bộ đệm.  Điều này có nghĩa là các yêu cầu WRITE bình thường không thực sự được ghi lại cho đến khi
yêu cầu REQ_PREFLUSH tiếp theo.  Điều này nhằm giúp không gian người dùng dễ dàng phát lại hơn
nhật ký theo cách tương quan với nội dung trên đĩa chứ không phải nội dung trong bộ đệm,
để dễ dàng phát hiện việc chờ/xả không đúng cách.

Điều này hoạt động bằng cách đính kèm tất cả các yêu cầu WRITE vào danh sách sau khi quá trình ghi hoàn tất.
Khi chúng tôi thấy yêu cầu REQ_PREFLUSH, chúng tôi sẽ ghép danh sách này vào yêu cầu và một lần
yêu cầu FLUSH hoàn tất, chúng tôi ghi lại tất cả các VIẾT và sau đó là FLUSH.  Chỉ
các VIẾT đã hoàn thành, tại thời điểm REQ_PREFLUSH được phát hành, sẽ được thêm vào để
mô phỏng tình huống xấu nhất liên quan đến sự cố mất điện.  Hãy xem xét
ví dụ sau (W có nghĩa là viết, C có nghĩa là hoàn thành):

W1,W2,W3,C3,C2,Wflush,C1,Cflush

Nhật ký sẽ hiển thị như sau:

W3,W2,tuôn ra,W1....

Một lần nữa, điều này là để mô phỏng những gì thực sự có trên đĩa, điều này cho phép chúng tôi phát hiện
trường hợp mất điện tại một thời điểm cụ thể sẽ tạo ra
hệ thống tập tin không nhất quán.

Mọi yêu cầu REQ_FUA đều bỏ qua cơ chế xả này và được ghi lại ngay khi
chúng hoàn thành vì những yêu cầu đó rõ ràng sẽ bỏ qua bộ đệm của thiết bị.

Mọi yêu cầu REQ_OP_DISCARD đều được xử lý như yêu cầu WRITE.  Nếu không chúng tôi sẽ
có tất cả các yêu cầu DISCARD, sau đó là các yêu cầu WRITE và sau đó là FLUSH
yêu cầu.  Hãy xem xét ví dụ sau:

WRITE khối 1, DISCARD khối 1, FLUSH

Nếu chúng tôi ghi lại DISCARD khi nó hoàn thành, bản phát lại sẽ trông như thế này:

DISCARD 1, WRITE 1, FLUSH

đó không hẳn là những gì đã xảy ra và sẽ không bị phát hiện trong quá trình phát lại nhật ký.

Giao diện mục tiêu
==================

i) Nhà xây dựng

ghi nhật ký <dev_path> <log_dev_path>

================================================================
   dev_path Thiết bị mà tất cả IO sẽ truy cập bình thường.
   log_dev_path Thiết bị nơi các mục nhật ký được ghi vào.
   ================================================================

ii) Tình trạng

<Mục nhập #logged> <khu vực được phân bổ cao nhất>

========================================================
    Mục nhập #logged Số mục nhập được ghi lại
    lĩnh vực được phân bổ cao nhất Lĩnh vực được phân bổ cao nhất
    ========================================================

iii) Tin nhắn

đánh dấu <mô tả>

Bạn có thể sử dụng thông báo dmsetup để đặt dấu tùy ý trong nhật ký.
	Ví dụ: giả sử bạn muốn fsck một hệ thống tệp sau mỗi lần
	viết, nhưng trước tiên bạn cần phát lại tới mkfs để đảm bảo
	chúng tôi đang tìm kiếm điều gì đó hợp lý, bạn sẽ làm điều gì đó như
	cái này::

mkfs.btrfs -f /dev/mapper/log
	  nhật ký tin nhắn dmsetup 0 điểm mkfs
	  <chạy thử nghiệm>

Điều này sẽ cho phép bạn phát lại nhật ký đến nhãn mkfs và
	sau đó phát lại từ thời điểm đó khi thực hiện kiểm tra fsck trong
	khoảng thời gian mà bạn muốn.

Mỗi nhật ký đều có một dấu ở cuối có nhãn "dm-log-writes-end".

Thành phần không gian người dùng
================================

Có một công cụ không gian người dùng sẽ phát lại nhật ký cho bạn theo nhiều cách khác nhau.
Nó có thể được tìm thấy ở đây: ZZ0000ZZ

Cách sử dụng ví dụ
==================

Giả sử bạn muốn kiểm tra fsync trên hệ thống tệp của mình.  Bạn sẽ làm một cái gì đó như
cái này::

TABLE="0 $(blockdev --getsz /dev/sdb) ghi nhật ký /dev/sdb /dev/sdc"
  dmsetup tạo nhật ký --table "$TABLE"
  mkfs.btrfs -f /dev/mapper/log
  nhật ký tin nhắn dmsetup 0 điểm mkfs

gắn kết/dev/mapper/log/mnt/btrfs-test
  <một số bài kiểm tra có fsync ở cuối>
  nhật ký tin nhắn dmsetup 0 điểm fsync
  md5sum /mnt/btrfs-test/foo
  umount /mnt/btrfs-test

dmsetup xóa nhật ký
  phát lại-log --log /dev/sdc --replay /dev/sdb --end-mark fsync
  gắn kết/dev/sdb/mnt/btrfs-test
  md5sum /mnt/btrfs-test/foo
  <xác minh md5sum là chính xác>

Một tùy chọn khác là thực hiện thao tác hệ thống tệp phức tạp và xác minh tệp
  thống nhất quán trong suốt quá trình hoạt động.  Bạn có thể làm điều này với:

TABLE="0 $(blockdev --getsz /dev/sdb) ghi nhật ký /dev/sdb /dev/sdc"
  dmsetup tạo nhật ký --table "$TABLE"
  mkfs.btrfs -f /dev/mapper/log
  nhật ký tin nhắn dmsetup 0 điểm mkfs

gắn kết/dev/mapper/log/mnt/btrfs-test
  <fsstress làm bẩn fs>
  cân bằng hệ thống tập tin btrfs /mnt/btrfs-test
  umount /mnt/btrfs-test
  dmsetup xóa nhật ký

phát lại-log --log /dev/sdc --replay /dev/sdb --end-mark mkfs
  btrfsck /dev/sdb
  replay-log --log /dev/sdc --replay /dev/sdb --start-mark mkfs \
	--fsck "btrfsck /dev/sdb" --check fua

Và điều đó sẽ phát lại nhật ký cho đến khi thấy yêu cầu FUA, hãy chạy lệnh fsck
và nếu fsck vượt qua, nó sẽ phát lại FUA tiếp theo, cho đến khi hoàn thành hoặc
lệnh fsck tồn tại bất thường.
