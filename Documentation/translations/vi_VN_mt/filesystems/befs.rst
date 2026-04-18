.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/befs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Hệ thống tập tin BeOS cho Linux
=========================

Tài liệu được cập nhật lần cuối: ngày 6 tháng 12 năm 2001

Cảnh báo
=======
Hãy chắc chắn rằng bạn hiểu rằng đây là phần mềm alpha.  Điều này có nghĩa là
việc triển khai chưa hoàn thiện và chưa được kiểm tra tốt.

TÔI DISCLAIM ALL RESPONSIBILITY FOR ANY POSSIBLE BAD EFFECTS CỦA THIS CODE!

Giấy phép
=======
Phần mềm này được cấp phép theo Giấy phép Công cộng GNU.
Xem tệp COPYING để biết nội dung đầy đủ của giấy phép.
Hoặc website GNU: <ZZ0000ZZ

Tác giả
======
Phần lớn nhất của mã được viết bởi Will Dyson <will_dyson@pobox.com>
Anh ấy đã nghiên cứu mã từ ngày 13 tháng 8 năm 2001. Xem nhật ký thay đổi để biết
chi tiết.

Tác giả gốc: Makoto Kato <m_kato@ga2.so-net.ne.jp>

Mã ban đầu của anh ấy vẫn có thể được tìm thấy tại:
<ZZ0000ZZ

Có ai biết địa chỉ email hiện tại của Makoto không? Anh ấy không
trả lời theo địa chỉ nêu trên...

Hệ thống tập tin này không có người bảo trì.

Trình điều khiển này là gì?
====================
Mô-đun này triển khai hệ thống tệp gốc của BeOS ZZ0000ZZ
dành cho hạt nhân linux 2.4.1 trở lên. Hiện nay nó là một chỉ đọc
thực hiện.

Đó là cái nào, BFS hay BEFS?
=========================
Be, Inc cho biết, "BeOS Filesystem có tên chính thức là BFS, không phải BeFS".
Nhưng Hệ thống tập tin khởi động Unixware cũng được gọi là bfs. Và họ đã ở trong
hạt nhân. Do xung đột về cách đặt tên này nên trên Linux, BeOS
hệ thống tập tin được gọi là befs.

Cách cài đặt
==============
bước 1. Cài đặt bản vá BeFS vào cây mã nguồn của linux.

Áp dụng tệp vá cho cây nguồn kernel của bạn.
Giả sử rằng nguồn kernel của bạn nằm trong /foo/bar/linux và patchfile
được gọi là patch-befs-xxx, bạn sẽ làm như sau:

cd /foo/bar/linux
	vá -p1 </path/to/patch-befs-xxx

nếu bước vá không thành công (tức là có nhiều phần bị từ chối), bạn có thể thử
hãy tự mình tìm ra (điều này không khó) hoặc gửi thư cho người bảo trì
(Will Dyson <will_dyson@pobox.com>) để được trợ giúp.

bước 2. Cấu hình và tạo kernel

Nhân linux có nhiều tùy chọn về thời gian biên dịch. Hầu hết chúng đều vượt quá
phạm vi của tài liệu này. Mình gợi ý tài liệu Kernel-HOWTO là một tướng hay
tài liệu tham khảo về chủ đề này. ZZ0000ZZ

Tuy nhiên, để sử dụng mô-đun BeFS, bạn phải kích hoạt nó tại thời điểm định cấu hình::

cd /foo/bar/linux
	tạo menuconfig (hoặc xconfig)

Mô-đun BeFS không phải là một phần tiêu chuẩn của nhân linux, vì vậy trước tiên bạn phải
bật hỗ trợ cho mã thử nghiệm trong menu "Mức độ trưởng thành của mã".

Sau đó, trong menu "Hệ thống tập tin" sẽ có một tùy chọn có tên "BeFS
hệ thống tập tin (thử nghiệm)", hoặc đại loại như thế. Kích hoạt tùy chọn đó
(có thể biến nó thành một mô-đun cũng được).

Lưu cấu hình kernel của bạn và sau đó xây dựng kernel của bạn.

bước 3. Cài đặt

Xem cách sử dụng kernel <ZZ0000ZZ để biết
hướng dẫn về bước quan trọng này.

Sử dụng BFS
=========
Để sử dụng hệ thống tệp BeOS, hãy sử dụng loại hệ thống tệp 'befs'.

bán tại::

mount -t befs/dev/fd0/beos

Tùy chọn gắn kết
=============

==============================================================================
uid=nnn Tất cả các tệp trong phân vùng sẽ thuộc sở hữu của id người dùng nnn.
gid=nnn Tất cả các tập tin trong phân vùng sẽ nằm trong nhóm nnn.
iocharset=xxx Sử dụng xxx làm tên của bảng dịch NLS.
debug Trình điều khiển sẽ xuất thông tin gỡ lỗi vào nhật ký hệ thống.
==============================================================================

Cách nhận phiên bản mới nhất
=========================

Phiên bản mới nhất hiện có tại:
<ZZ0000ZZ

Bất kỳ lỗi nào được biết đến?
===============
Tính đến ngày 20 tháng 1 năm 2002:

Không có

Cảm ơn đặc biệt
==============
Dominic Giampalo ... Viết "Thiết kế hệ thống tập tin thực tế với hệ thống tập tin Be"

Hiroyuki Yamada ... Thử nghiệm LinuxPPC.


