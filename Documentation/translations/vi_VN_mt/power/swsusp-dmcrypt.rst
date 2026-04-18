.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/power/swsusp-dmcrypt.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================================
Cách sử dụng dm-crypt và swsusp cùng nhau
==========================================

Tác giả: Andreas Steinmetz <ast@domdv.de>



Một số điều kiện tiên quyết:
Bạn biết dm-crypt hoạt động như thế nào. Nếu không, hãy truy cập trang web sau:
ZZ0000ZZ
Bạn đã đọc Documentation/power/swsusp.rst và hiểu nó.
Bạn đã đọc Documentation/admin-guide/initrd.rst và biết cách hoạt động của initrd.
Bạn biết cách tạo hoặc sửa đổi tệp initrd.

Bây giờ hệ thống của bạn đã được thiết lập đúng cách, đĩa của bạn đã được mã hóa ngoại trừ
(các) thiết bị trao đổi và phân vùng khởi động có thể chứa một mini
hệ thống cho mục đích thiết lập và/hoặc giải cứu tiền điện tử. Bạn thậm chí có thể có
một initrd đã thiết lập mật mã hiện tại của bạn.

Tại thời điểm này, bạn cũng muốn mã hóa trao đổi của mình. Bạn vẫn muốn
có thể tạm dừng sử dụng swsusp. Tuy nhiên, điều này có nghĩa là bạn
phải có khả năng nhập cụm mật khẩu hoặc bạn có thể đọc
(các) khóa từ một thiết bị bên ngoài như đĩa flash pcmcia
hoặc một thanh USB trước khi tiếp tục. Vì vậy bạn cần một initrd, nó đặt
bật dm-crypt và sau đó yêu cầu swsusp tiếp tục từ mã hóa
thiết bị trao đổi.

Điều quan trọng nhất là bạn thiết lập dm-crypt theo cách như vậy
một cách mà thiết bị trao đổi mà bạn tạm dừng/tiếp tục từ đó có
luôn luôn giống nhau trong phần initrd cũng như
trong hệ thống đang chạy của bạn. Cách dễ nhất để đạt được điều này là
phải luôn thiết lập thiết bị trao đổi này trước tiên bằng dmsetup, để
nó sẽ luôn trông giống như sau::

brw------- 1 gốc gốc 254, 0 ngày 28 tháng 7 13:37 /dev/mapper/swap0

Bây giờ hãy thiết lập kernel của bạn để sử dụng /dev/mapper/swap0 làm mặc định
tiếp tục phân vùng, do đó kernel .config của bạn chứa ::

CONFIG_PM_STD_PARTITION="/dev/mapper/swap0"

Chuẩn bị bộ tải khởi động của bạn để sử dụng initrd bạn sẽ tạo hoặc
sửa đổi. Đối với lilo, cách thiết lập đơn giản nhất như sau
dòng::

hình ảnh=/boot/vmlinuz
  initrd=/boot/initrd.gz
  nhãn=linux
  chắp thêm="root=/dev/ram0 init=/linuxrc rw"

Cuối cùng, bạn cần tạo hoặc sửa đổi tệp initrd. Hãy giả sử
you create an initrd that reads the required dm-crypt setup
từ thẻ đĩa flash pcmcia. Thẻ được định dạng bằng ext2
fs nằm trên /dev/hde1 khi thẻ được lắp vào. các
thẻ chứa ít nhất thiết lập trao đổi được mã hóa trong một tệp
được đặt tên là "khóa trao đổi". /etc/fstab của initrd của bạn chứa nội dung nào đó
như sau::

/dev/hda1 /mnt ext3 ro 0 0
  không có /proc mặc định proc,noatime,nodiratime 0 0
  không có /sys sysfs mặc định,noatime,nodiratime 0 0

/dev/hda1 chứa một hệ thống nhỏ không được mã hóa để thiết lập tất cả
của các thiết bị tiền điện tử của bạn, một lần nữa bằng cách đọc thiết lập từ
đĩa flash pcmcia. Những gì tiếp theo bây giờ là /linuxrc cho
initrd cho phép bạn tiếp tục từ trao đổi được mã hóa và điều đó
tiếp tục khởi động với hệ thống mini của bạn trên /dev/hda1 nếu tiếp tục
không xảy ra::

#!/bin/sh
  PATH=/sbin:/bin:/usr/sbin:/usr/bin
  gắn kết /proc
  gắn kết /sys
  ánh xạ=0
  noresume=ZZ0000ZZ
  nếu [ "$*" != "" ]
  sau đó
    noresume=1
  fi
  dmesg -n 1
  /sbin/cardmgr -q
  cho tôi trong 1 2 3 4 5 6 7 8 9 0
  làm
    nếu [ -f /proc/ide/hde/media]
    sau đó
      ngủ quên 500000
      mount -t ext2 -o ro /dev/hde1 /mnt
      nếu [ -f /mnt/swapkey ]
      sau đó
        dmsetup tạo swap0 /mnt/swapkey > /dev/null 2>&1 && mapped=1
      fi
      số lượng /mnt
      phá vỡ
    fi
    ngủ quên 500000
  xong
  killproc /sbin/cardmgr
  dmesg -n 6
  nếu [$mapped = 1]
  sau đó
    nếu [ $noresume != 0 ]
    sau đó
      mkswap /dev/mapper/swap0 > /dev/null 2>&1
    fi
    echo 254:0 > /sys/power/sơ yếu lý lịch
    dmsetup xóa swap0
  fi
  số lượng /sys
  gắn kết /mnt
  umount /proc
  cd /mnt
  Pivot_root . mnt
  gắn kết /proc
  umount -l /mnt
  umount /proc
  thực thi chroot . /sbin/init $* < dev/console > dev/console 2>&1

Xin đừng bận tâm đến vòng lặp kỳ lạ ở trên, msh của busybox không biết
câu lệnh let. Bây giờ, điều gì đang xảy ra trong kịch bản?
Đầu tiên chúng ta phải quyết định xem chúng ta có muốn thử tiếp tục hay không.
Chúng tôi sẽ không tiếp tục nếu khởi động với "noresume" hoặc bất kỳ tham số nào
đối với init như "đơn" hoặc "khẩn cấp" làm tham số khởi động.

Sau đó, chúng ta cần thiết lập dmcrypt với dữ liệu thiết lập từ
đĩa flash pcmcia. Nếu điều này thành công, chúng ta cần thiết lập lại trao đổi
thiết bị nếu chúng tôi không muốn tiếp tục. Dòng "echo 254:0 > /sys/power/resume"
then attempts to resume from the first device mapper device.
Lưu ý rằng điều quan trọng là phải đặt thiết bị ở /sys/power/resume,
bất kể có tiếp tục hay không, nếu không việc đình chỉ sau này sẽ thất bại.
Nếu quá trình tiếp tục bắt đầu, quá trình thực thi tập lệnh sẽ kết thúc tại đây.

Nếu không, chúng tôi chỉ xóa thiết bị trao đổi được mã hóa và để nó cho
hệ thống mini trên /dev/hda1 để thiết lập toàn bộ mật mã (tùy thuộc vào
bạn sửa đổi điều này theo sở thích của bạn).

Sau đó là quy trình nổi tiếng để thay đổi thư mục gốc
hệ thống tập tin và tiếp tục khởi động từ đó. Tôi thích ngắt kết nối hơn
initrd trước khi tiếp tục khởi động nhưng bạn có thể sửa đổi
cái này.
