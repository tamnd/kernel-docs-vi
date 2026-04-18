.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/smb/cifsroot.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================================
Gắn hệ thống tập tin gốc qua SMB (cifs.ko)
===========================================

Viết năm 2019 bởi Paulo Alcantara <palcantara@suse.de>

Viết năm 2019 bởi Aurelien Aptel <aaptel@suse.com>

Tùy chọn CONFIG_CIFS_ROOT cho phép hệ thống tập tin gốc thử nghiệm
hỗ trợ qua giao thức SMB thông qua cifs.ko.

Nó giới thiệu một tùy chọn dòng lệnh kernel mới gọi là 'cifsroot='
nó sẽ báo cho kernel gắn hệ thống tập tin gốc qua
mạng bằng cách sử dụng giao thức SMB hoặc CIFS.

Để gắn kết, ngăn xếp mạng cũng sẽ cần được thiết lập bởi
sử dụng tùy chọn cấu hình 'ip='. Để biết thêm chi tiết, xem
Tài liệu/admin-guide/nfs/nfsroot.rst.

Giá đỡ gốc CIFS hiện yêu cầu sử dụng Tiện ích mở rộng SMB1+UNIX
chỉ được hỗ trợ bởi máy chủ Samba. SMB1 cũ hơn
phiên bản giao thức không được dùng nữa nhưng nó đã được mở rộng để hỗ trợ
Các tính năng của POSIX (Xem [1]). Các phần mở rộng tương đương cho phiên bản mới hơn
phiên bản được đề xuất của giao thức (SMB3) chưa được hỗ trợ đầy đủ
chưa được triển khai, điều đó có nghĩa là SMB3 không hỗ trợ một số POSIX cần thiết
các đối tượng hệ thống tập tin (ví dụ: thiết bị khối, đường ống, ổ cắm).

Do đó, root CIFS hiện tại sẽ mặc định là SMB1 nhưng phiên bản
Tuy nhiên, việc sử dụng có thể được thay đổi thông qua tùy chọn gắn kết 'vers='.  Cái này
mặc định sẽ thay đổi sau khi tiện ích mở rộng SMB3 POSIX được hoàn thiện
được thực hiện.

Cấu hình máy chủ
====================

Để bật các tiện ích mở rộng SMB1+UNIX, bạn sẽ cần đặt các tiện ích mở rộng chung này
cài đặt trong Samba smb.conf::

[toàn cầu]
    giao thức tối thiểu của máy chủ = NT1
    tiện ích mở rộng unix = có # default

Dòng lệnh hạt nhân
===================

::

root=/dev/cifs

Đây chỉ là một thiết bị ảo về cơ bản yêu cầu kernel gắn kết
hệ thống tập tin gốc thông qua giao thức SMB.

::

cifsroot=//<server-ip>/<share>[,options]

Cho phép kernel gắn hệ thống tập tin gốc thông qua SMB
nằm trong <server-ip> và <share> được chỉ định trong tùy chọn này.

Các tùy chọn gắn kết mặc định được đặt trong fs/smb/client/cifsroot.c.

máy chủ-ip
	Địa chỉ IPv4 của máy chủ.

chia sẻ
	Đường dẫn đến chia sẻ SMB (rootfs).

tùy chọn
	Tùy chọn gắn kết tùy chọn. Để biết thêm thông tin, xem mount.cifs(8).

Ví dụ
========

Xuất hệ thống tệp gốc dưới dạng chia sẻ Samba trong tệp smb.conf::

    ...
[linux]
	    đường dẫn = /path/to/rootfs
	    chỉ đọc = không
	    khách được rồi = vâng
	    buộc người dùng = root
	    nhóm lực = gốc
	    có thể duyệt được = có
	    có thể ghi được = có
	    người dùng quản trị = root
	    công khai = có
	    tạo mặt nạ = 0777
	    mặt nạ thư mục = 0777
    ...

Khởi động lại dịch vụ smb::

# systemctl khởi động lại smb

Kiểm tra nó với QEMU trên kernel được xây dựng bằng CONFIG_CIFS_ROOT và
Tùy chọn CONFIG_IP_PNP được bật::

# qemu-system-x86_64 -enable-kvm -cpu máy chủ -m 1024 \
    -kernel /path/to/linux/arch/x86/boot/bzImage -nographic \
    -append "root=/dev/cifs rw ip=dhcp cifsroot=//10.0.2.2/linux,username=foo,password=bar console=ttyS0 3"


1: ZZ0000ZZ