.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/gfs2/uevents.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==================
sự kiện và GFS2
================

Trong suốt thời gian sử dụng của giá treo GFS2, một số sự kiện sẽ được tạo ra.
Tài liệu này giải thích các sự kiện là gì và chúng được sử dụng như thế nào
cho (bởi gfs_controld trong gfs2-utils).

Danh sách các sự kiện GFS2
======================

1. ADD
------

Sự kiện ADD xảy ra tại thời điểm gắn kết. Nó sẽ luôn là người đầu tiên
sự kiện được tạo bởi hệ thống tập tin mới được tạo. Nếu gắn kết
thành công, sự kiện ONLINE sẽ diễn ra sau đó.  Nếu không thành công
sau đó sẽ có sự kiện REMOVE.

Sự kiện ADD có hai biến môi trường: SPECTATOR=[0|1]
và RDONLY=[0|1] chỉ định trạng thái của người xem (một mount chỉ đọc
không có tạp chí nào được chỉ định) và trạng thái chỉ đọc (có tạp chí được chỉ định)
của hệ thống tập tin tương ứng.

2. ONLINE
---------

Sự kiện ONLINE được tạo sau khi gắn hoặc gắn lại thành công. Nó
có các biến môi trường giống như sự kiện ADD. ONLINE
uevent, cùng với hai biến môi trường dành cho khán giả và
RDONLY là một phần bổ sung tương đối gần đây (2.6.32-rc+) và sẽ không
được tạo ra bởi các hạt nhân cũ hơn.

3. CHANGE
---------

Sự kiện CHANGE được sử dụng ở hai nơi. Một là khi báo cáo
gắn thành công hệ thống tập tin vào nút đầu tiên (FIRSTMOUNT=Done).
Điều này được sử dụng như một tín hiệu bởi gfs_controld rằng điều đó sẽ ổn đối với những người khác
các nút trong cụm để gắn kết hệ thống tập tin.

Sự kiện CHANGE khác được sử dụng để thông báo về việc hoàn thành
phục hồi nhật ký cho một trong các nhật ký của hệ thống tập tin. Nó có
hai biến môi trường, JID= chỉ định id tạp chí
vừa được khôi phục và RECOVERY=[Done|Failed] để biểu thị
thành công (hoặc nói cách khác) của hoạt động. Những sự kiện này được tạo ra
đối với mọi nhật ký được khôi phục, cho dù đó là trong quá trình gắn kết ban đầu
quá trình hoặc do kết quả của việc gfs_controld yêu cầu một tạp chí cụ thể
recovery thông qua tệp /sys/fs/gfs2/<fsname>/lock_module/recovery.

Bởi vì sự kiện CHANGE đã được sử dụng (trong các phiên bản đầu tiên của gfs_controld)
không kiểm tra các biến môi trường để khám phá trạng thái, chúng tôi
không thể thêm bất kỳ chức năng nào nữa vào nó mà không gặp rủi ro
ai đó đang sử dụng phiên bản cũ hơn của các công cụ người dùng và vi phạm
cụm. Vì lý do này, sự kiện ONLINE đã được sử dụng khi thêm một
sự kiện quan trọng để gắn kết hoặc gắn lại thành công.

4. OFFLINE
----------

Sự kiện OFFLINE chỉ được tạo do lỗi hệ thống tập tin và được sử dụng
như một phần của cơ chế "rút tiền". Hiện tại điều này không cung cấp bất kỳ
thông tin về lỗi là gì, đó là điều cần phải
được cố định.

5. REMOVE
---------

Sự kiện REMOVE được tạo khi kết thúc quá trình gắn kết không thành công
hoặc ở cuối một số lượng của hệ thống tập tin. Tất cả các sự kiện REMOVE sẽ
trước đó có ít nhất một sự kiện ADD cho cùng một hệ thống tệp,
và không giống như các sự kiện khác được tạo tự động bởi kernel
hệ thống con kobject.


Thông tin chung cho tất cả các sự kiện GFS2 (biến môi trường sự kiện)
=====================================================================

1. LOCKTABLE=
--------------

LOCKTABLE là một chuỗi, được cung cấp trong lệnh mount
dòng (locktable=) hoặc qua fstab. Nó được sử dụng làm nhãn hệ thống tập tin
cũng như cung cấp thông tin để gắn kết lock_dlm
có khả năng tham gia vào cụm.

2. LOCKPROTO=
-------------

LOCKPROTO là một chuỗi và giá trị của nó phụ thuộc vào những gì được đặt
trên dòng lệnh mount hoặc thông qua fstab. Nó sẽ là một trong hai
lock_nolock hoặc lock_dlm. Trong tương lai các nhà quản lý khóa khác
có thể được hỗ trợ.

3. JOURNALID=
-------------

Nếu một tạp chí được hệ thống tập tin sử dụng (các tạp chí không
được chỉ định cho thú cưỡi khán giả) thì điều này sẽ mang lại
id tạp chí số trong tất cả các sự kiện GFS2.

4. UUID=
--------

Với các phiên bản gần đây của gfs2-utils, mkfs.gfs2 ghi UUID
vào siêu khối hệ thống tập tin. Nếu nó tồn tại, điều này sẽ
được bao gồm trong mọi sự kiện liên quan đến hệ thống tập tin.


