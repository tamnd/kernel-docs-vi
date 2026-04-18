.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/quota.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
Hệ thống con hạn ngạch
===============

Hệ thống con hạn ngạch cho phép quản trị viên hệ thống đặt giới hạn về không gian đã sử dụng và
số lượng inode được sử dụng (inode là cấu trúc hệ thống tập tin được liên kết với
mỗi tệp hoặc thư mục) cho người dùng và/hoặc nhóm. Đối với cả không gian và số được sử dụng
số inode được sử dụng thực tế có hai giới hạn. Cái đầu tiên được gọi là softlimit
và giới hạn cứng thứ hai.  Người dùng không bao giờ có thể vượt quá giới hạn cứng cho bất kỳ
tài nguyên (trừ khi anh ta có khả năng CAP_SYS_RESOURCE). Người dùng được phép vượt quá
softlimit nhưng chỉ trong một khoảng thời gian giới hạn. Thời kỳ này được gọi là “ân sủng
thời gian" hoặc "thời gian ân hạn". Khi hết thời gian gia hạn, người dùng không thể phân bổ
nhiều không gian/inodes hơn cho đến khi anh ta giải phóng đủ chúng để đạt được dưới giới hạn mềm.

Giới hạn hạn ngạch (và lượng thời gian gia hạn) được đặt độc lập cho từng
hệ thống tập tin.

Để biết thêm chi tiết về thiết kế hạn ngạch, hãy xem tài liệu trong gói công cụ hạn ngạch
(ZZ0000ZZ

Giao diện netlink hạn ngạch
=======================
Khi người dùng vượt quá giới hạn mềm, hết thời gian gia hạn hoặc đạt đến giới hạn cứng,
hệ thống con hạn ngạch theo truyền thống đã in một tin nhắn đến thiết bị đầu cuối kiểm soát của
quá trình gây ra sự dư thừa. Phương pháp này có nhược điểm là
khi người dùng đang sử dụng máy tính để bàn đồ họa, anh ta thường không thể nhìn thấy thông báo.
Vì vậy, giao diện liên kết mạng hạn ngạch đã được thiết kế để truyền thông tin về
các sự kiện trên vào không gian người dùng. Ở đó chúng có thể bị bắt bởi một ứng dụng
và xử lý cho phù hợp.

Giao diện sử dụng khung liên kết mạng chung (xem
ZZ0000ZZ và ZZ0001ZZ cho
biết thêm chi tiết về lớp này). Tên của giao diện netlink chung hạn ngạch
là "VFS_DQUOT". Định nghĩa các hằng số bên dưới có trong <linux/quota.h>.  Kể từ khi
giao thức liên kết mạng hạn ngạch không nhận biết được vùng tên, các thông báo liên kết mạng hạn ngạch được
chỉ được gửi trong không gian tên mạng ban đầu.

Hiện tại, giao diện chỉ hỗ trợ một loại tin nhắn QUOTA_NL_C_WARNING.
Lệnh này được sử dụng để gửi thông báo về bất kỳ điều nào được đề cập ở trên
sự kiện. Mỗi tin nhắn có sáu thuộc tính. Đây là (loại đối số là
trong ngoặc đơn):

QUOTA_NL_A_QTYPE (u32)
	  - loại hạn ngạch bị vượt quá (một trong USRQUOTA, GRPQUOTA)
        QUOTA_NL_A_EXCESS_ID (u64)
	  - UID/GID (tùy thuộc vào loại hạn ngạch) của người dùng/nhóm có giới hạn
	    đang bị vượt quá.
        QUOTA_NL_A_CAUSED_ID (u64)
	  - UID của người dùng gây ra sự kiện
        QUOTA_NL_A_WARNING (u32)
	  - loại giới hạn nào bị vượt quá:

QUOTA_NL_IHARDWARN
		    giới hạn cứng inode
		QUOTA_NL_ISOFTLONGWARN
		    giới hạn mềm inode bị vượt quá lâu hơn
		    hơn thời gian ân hạn đã cho
		QUOTA_NL_ISOFTWARN
		    giới hạn mềm inode
		QUOTA_NL_BHARDWARN
		    giới hạn không gian (khối) cứng
		QUOTA_NL_BSOFTLONGWARN
		    vượt quá giới hạn mềm không gian (khối)
		    dài hơn thời gian ân hạn đã cho.
		QUOTA_NL_BSOFTWARN
		    không gian (khối) giới hạn mềm

- bốn cảnh báo cũng được xác định cho sự kiện khi người dùng dừng
	    vượt quá giới hạn nào đó:

QUOTA_NL_IHARDBELOW
		    giới hạn cứng inode
		QUOTA_NL_ISOFTBELOW
		    giới hạn mềm inode
		QUOTA_NL_BHARDBELOW
		    giới hạn không gian (khối) cứng
		QUOTA_NL_BSOFTBELOW
		    không gian (khối) giới hạn mềm

QUOTA_NL_A_DEV_MAJOR (u32)
	  - số lượng chính của thiết bị có hệ thống tập tin bị ảnh hưởng
        QUOTA_NL_A_DEV_MINOR (u32)
	  - số lượng nhỏ thiết bị có hệ thống tập tin bị ảnh hưởng