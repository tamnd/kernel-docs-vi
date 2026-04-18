.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/bfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Hệ thống tập tin BFS cho Linux
========================

Hệ thống tập tin BFS được hệ điều hành UnixWare SCO sử dụng cho lát /stand,
thường chứa hình ảnh hạt nhân và một vài tập tin khác cần thiết cho
quá trình khởi động.

Để truy cập phân vùng /stand trong Linux, rõ ràng bạn cần phải
biết số phân vùng và kernel phải hỗ trợ các lát đĩa UnixWare
(Tùy chọn cấu hình CONFIG_UNIXWARE_DISKLABEL). Tuy nhiên hỗ trợ BFS không
phụ thuộc vào việc có hỗ trợ nhãn đĩa UnixWare vì người ta cũng có thể gắn kết
Hệ thống tập tin BFS thông qua loopback::

# losetup /dev/loop0 đứng.img
    # mount -t bfs/dev/loop0/mnt/stand

trong đó Stand.img là tệp chứa hình ảnh của hệ thống tệp BFS.
Khi bạn sử dụng xong và đã đếm được bạn cũng cần phải giải phóng
Thiết bị /dev/loop0 bởi::

# losetup -d /dev/loop0

Bạn có thể đơn giản hóa việc gắn kết bằng cách chỉ cần gõ::

# mount -t bfs -o vòng đứng.img /mnt/stand

điều này sẽ phân bổ thiết bị loopback có sẵn đầu tiên (và tải loop.o
mô-đun hạt nhân nếu cần thiết) một cách tự động. Nếu trình điều khiển loopback không
được tải tự động, hãy đảm bảo rằng bạn đã biên dịch mô-đun và
modprobe đó đang hoạt động. Hãy coi chừng rằng umount sẽ không phân bổ
Thiết bị /dev/loopN nếu tệp /etc/mtab trên hệ thống của bạn là một liên kết tượng trưng tới
/proc/mount. Bạn sẽ cần thực hiện thủ công bằng cách sử dụng nút chuyển "-d" của
thua cuộc(8). Đọc trang losttup(8) để biết thêm thông tin.

Để tạo image BFS trong UnixWare trước tiên bạn cần tìm hiểu cái nào
lát chứa nó. Lệnh ptvtoc(1M) là bạn của bạn::

# prtvtoc /dev/rdsk/c0b0t0d0s0

(giả sử đĩa gốc của bạn nằm trên target=0, lun=0, bus=0, control=0). Sau đó bạn
hãy tìm lát cắt có thẻ "STAND", thường là lát cắt 10. Với cái này
thông tin bạn có thể sử dụng dd(1) để tạo hình ảnh BFS::

# umount /đế
    # dd if=/dev/rdsk/c0b0t0d0sa of=stand.img bs=512

Để đề phòng, bạn có thể xác minh rằng mình đã làm đúng bằng cách kiểm tra
con số kỳ diệu::

# od -Quảng cáo -tx4 đứng.img | hơn

4 byte đầu tiên phải là 0x1badface.

Nếu bạn có bất kỳ bản vá, câu hỏi hoặc đề xuất nào liên quan đến BFS này
thực hiện vui lòng liên hệ tác giả:

Tigran Aivazian <aivazian.tigran@gmail.com>