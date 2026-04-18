.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/process/debugging/gdb-kernel-debugging.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. highlight:: none

Gỡ lỗi kernel và mô-đun qua gdb
====================================

Trình gỡ lỗi hạt nhân kgdb, các trình ảo hóa như phần cứng dựa trên QEMU hoặc JTAG
giao diện cho phép gỡ lỗi nhân Linux và các mô-đun của nó trong thời gian chạy
sử dụng gdb. Gdb đi kèm với giao diện tập lệnh mạnh mẽ cho python. các
kernel cung cấp một tập hợp các tập lệnh trợ giúp có thể đơn giản hóa
các bước gỡ lỗi kernel. Đây là hướng dẫn ngắn về cách kích hoạt và sử dụng
họ. Nó tập trung vào các máy ảo QEMU/KVM làm mục tiêu, nhưng các ví dụ có thể
cũng được chuyển sang các nhánh gdb khác.


Yêu cầu
------------

- gdb 7.2+ (được khuyến nghị: 7.4+) đã bật hỗ trợ python (thường đúng
  để phân phối)


Cài đặt
-------

- Tạo máy Linux ảo cho QEMU/KVM (xem www.linux-kvm.org và
  www.qemu.org để biết thêm chi tiết). Để phát triển chéo,
  ZZ0000ZZ lưu giữ một nhóm hình ảnh máy và
  chuỗi công cụ có thể hữu ích để bắt đầu.

- Xây dựng kernel với CONFIG_GDB_SCRIPTS được kích hoạt nhưng để lại
  CONFIG_DEBUG_INFO_REDUCED tắt. Nếu kiến trúc của bạn hỗ trợ
  CONFIG_FRAME_POINTER, hãy tiếp tục kích hoạt nó.

- Cài kernel đó vào máy khách, tắt KASLR nếu cần bằng cách thêm
  "nokaslr" vào dòng lệnh kernel.
  Ngoài ra, QEMU cho phép khởi động kernel trực tiếp bằng -kernel,
  -append, -initrd chuyển đổi dòng lệnh. Điều này thường chỉ hữu ích nếu
  bạn không phụ thuộc vào các mô-đun. Xem tài liệu QEMU để biết thêm chi tiết về
  chế độ này. Trong trường hợp này, bạn nên xây dựng kernel bằng
  CONFIG_RANDOMIZE_BASE bị vô hiệu hóa nếu kiến trúc hỗ trợ KASLR.

- Xây dựng các tập lệnh gdb (bắt buộc trên kernel v5.1 trở lên)::

tạo script_gdb

- Kích hoạt sơ khai gdb của QEMU/KVM

- tại thời điểm khởi động VM bằng cách thêm "-s" vào dòng lệnh QEMU

hoặc

- trong thời gian chạy bằng cách phát hành "gdbserver" từ màn hình QEMU
      bảng điều khiển

- cd /path/to/linux-build

- Khởi động gdb: gdb vmlinux

Lưu ý: Một số bản phân phối có thể hạn chế tự động tải tập lệnh gdb ở mức an toàn đã biết
  thư mục. Trong trường hợp gdb báo cáo từ chối tải vmlinux-gdb.py, hãy thêm ::

add-auto-load-safe-path /path/to/linux-build

đến ~/.gdbinit. Xem trợ giúp của gdb để biết thêm chi tiết.

- Đính kèm vào máy khách đã boot::

(gdb) mục tiêu từ xa: 1234


Ví dụ về cách sử dụng trình trợ giúp gdb do Linux cung cấp
----------------------------------------------------------

- Tải ký hiệu module (và kernel chính)::

(gdb) ký hiệu lx
    đang tải vmlinux
    quét các mô-đun trong/home/user/linux/build
    đang tải @ 0xffffffffa0020000: /home/user/linux/build/net/netfilter/xt_tcpudp.ko
    đang tải @ 0xffffffffa0016000: /home/user/linux/build/net/netfilter/xt_pkttype.ko
    đang tải @ 0xffffffffa0002000: /home/user/linux/build/net/netfilter/xt_limit.ko
    đang tải @0xffffffffa00ca000: /home/user/linux/build/net/packet/af_packet.ko
    đang tải @ 0xffffffffa003c000: /home/user/linux/build/fs/fuse/fuse.ko
    ...
đang tải @ 0xffffffffa0000000: /home/user/linux/build/drivers/ata/ata_generic.ko

- Đặt điểm dừng trên một số chức năng mô-đun chưa được tải, ví dụ::

(gdb) b btrfs_init_sysfs
    Chức năng "btrfs_init_sysfs" không được xác định.
    Tạo điểm dừng đang chờ xử lý khi tải thư viện được chia sẻ trong tương lai? (y hoặc [n]) y
    Điểm dừng 1 (btrfs_init_sysfs) đang chờ xử lý.

- Tiếp tục mục tiêu::

(gdb) c

- Tải mô-đun vào mục tiêu và xem các biểu tượng đang được tải
  điểm dừng nhấn::

đang tải @ 0xffffffffa0034000: /home/user/linux/build/lib/libcrc32c.ko
    đang tải @ 0xffffffffa0050000: /home/user/linux/build/lib/lzo/lzo_compress.ko
    đang tải @ 0xffffffffa006e000: /home/user/linux/build/lib/zlib_deflate/zlib_deflate.ko
    đang tải @ 0xffffffffa01b1000: /home/user/linux/build/fs/btrfs/btrfs.ko

Điểm dừng 1, btrfs_init_sysfs () tại /home/user/linux/fs/btrfs/sysfs.c:36
    36 btrfs_kset = kset_create_and_add("btrfs", NULL, fs_kobj);

- Kết xuất bộ đệm nhật ký của kernel đích::

(gdb) lx-dmesg
    [ 0,000000] Đang khởi tạo bộ xử lý con cgroup subsys
    [ 0,000000] Đang khởi tạo cpu hệ thống con cgroup
    [ 0,000000] Phiên bản Linux 3.8.0-rc4-dbg+ (...
    [ 0,000000] Dòng lệnh: root=/dev/sda2 Resume=/dev/sda1 vga=0x314
    [ 0,000000] e820: Bản đồ RAM vật lý do BIOS cung cấp:
    [ 0,000000] BIOS-e820: [mem 0x0000000000000000-0x0000000000009fbff] có thể sử dụng được
    [ 0,000000] BIOS-e820: [mem 0x000000000009fc00-0x0000000000009ffff] được bảo lưu
    ....

- Kiểm tra các trường của cấu trúc tác vụ hiện tại (chỉ hỗ trợ bởi x86 và arm64)::

(gdb) p $lx_current().pid
    $1 = 4998
    (gdb) p $lx_current().comm
    $2 = "modprobe\000\000\000\000\000\000\000"

- Sử dụng chức năng trên mỗi CPU cho dòng điện CPU hiện tại hoặc được chỉ định::

(gdb) p $lx_per_cpu(runqueues).nr_running
    $3 = 1
    (gdb) p $lx_per_cpu(runqueues, 2).nr_running
    $4 = 0

- Tìm hiểu về giờ bằng cách sử dụng trình trợ giúp container_of::

(gdb) đặt $leftmost = $lx_per_cpu(hrtimer_bases).clock_base[0].active.rb_root.rb_leftmost
    (gdb) p *$container_of($leftmost, "struct hrtimer", "node")
    $5 = {
      nút = {
        nút = {
          __rb_parent_color = 18446612686384860673,
          rb_right = 0xffff888231da8b00,
          rb_left = 0x0
        },
        hết hạn = 1228461000000
      },
      _softexpires = 1228461000000,
      hàm = 0xffffffff8137ab20<tick_nohz_handler>,
      cơ sở = 0xffff888231d9b4c0,
      trạng thái = 1 '\001',
      is_rel = 0 '\000',
      is_soft = 0 '\000',
      is_hard = 1 '\001'
    }


Danh sách lệnh và chức năng
------------------------------

Số lượng lệnh và chức năng tiện lợi có thể phát triển theo thời gian,
đây chỉ là ảnh chụp nhanh của phiên bản đầu tiên::

(gdb) phù hợp với lx
 hàm lx_current -- Trả về tác vụ hiện tại
 hàm lx_module -- Tìm mô-đun theo tên và trả về biến mô-đun
 hàm lx_per_cpu -- Trả về biến trên mỗi CPU
 function lx_task_by_pid - Tìm tác vụ Linux bằng PID và trả về biến task_struct
 hàm lx_thread_info - Tính toán thread_info Linux từ biến tác vụ
 lx-dmesg -- In bộ đệm nhật ký nhân Linux
 lx-lsmod - Liệt kê các mô-đun hiện được tải
 lx-symbols -- (Re-)tải các ký hiệu của nhân Linux và các mô-đun hiện được tải

Bạn có thể nhận trợ giúp chi tiết thông qua "trợ giúp <tên lệnh>" cho các lệnh và "trợ giúp
function <function-name>" để có các chức năng tiện lợi.

Gỡ lỗi tập lệnh GDB
---------------------

GDB không kích hoạt backtrace Python đầy đủ, điều này có thể giúp gỡ lỗi GDB
kịch bản khó khăn hơn mức cần thiết. Phần sau đây sẽ cho phép in một
dấu vết đầy đủ của môi trường python::

(gdb) đặt ngăn xếp in python đầy đủ
