.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/dynamic-debug-howto.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Gỡ lỗi động
+++++++++++++


Giới thiệu
============

Gỡ lỗi động cho phép bạn bật/tắt kernel một cách linh hoạt
mã in gỡ lỗi để lấy thêm thông tin kernel.

Nếu ZZ0000ZZ tồn tại, kernel của bạn có động
gỡ lỗi.  Bạn sẽ cần quyền truy cập root (Sudo su) để sử dụng tính năng này.

Gỡ lỗi động cung cấp:

* Danh mục tất cả ZZ0001ZZ trong kernel của bạn.
   ZZ0000ZZ để xem chúng.

* Ngôn ngữ lệnh/truy vấn đơn giản để thay đổi ZZ0000ZZ bằng cách chọn trên
   bất kỳ sự kết hợp nào của 0 hoặc 1 của:

- tên file nguồn
   - tên chức năng
   - số dòng (bao gồm phạm vi số dòng)
   - tên mô-đun
   - chuỗi định dạng
   - tên lớp (được biết/khai báo bởi mỗi mô-đun)

NOTE: Để thực sự có được kết quả in gỡ lỗi trên bảng điều khiển, bạn có thể
cần điều chỉnh kernel ZZ0000ZZ hoặc sử dụng ZZ0001ZZ.
Đọc về các tham số kernel này trong
Tài liệu/admin-guide/kernel-parameters.rst.

Xem hành vi gỡ lỗi động
===============================

Bạn có thể xem hành vi hiện được định cấu hình trong danh mục ZZ0000ZZ::

:#> head -n7 /proc/dynamic_debug/control
  # filename:lineno [mô-đun]định dạng cờ chức năng
  init/main.c:1179 [main]initcall_blacklist =_ "đưa initcall vào danh sách đen %s\012
  init/main.c:1218 [main]initcall_blacklist =_ "initcall %s bị liệt vào danh sách đen\012"
  init/main.c:1424 [main]run_init_process =_ " với đối số:\012"
  init/main.c:1426 [main]run_init_process =_ " %s\012"
  init/main.c:1427 [main]run_init_process =_ " với môi trường:\012"
  init/main.c:1429 [main]run_init_process =_ " %s\012"

Cột thứ 3 được phân cách bằng dấu cách hiển thị các cờ hiện tại, trước
ZZ0000ZZ để dễ dàng sử dụng với grep/cut. ZZ0001ZZ hiển thị các trang web cuộc gọi được kích hoạt.

Kiểm soát hành vi gỡ lỗi động
===================================

Hoạt động của các trang ZZ0000ZZ được kiểm soát bằng cách viết
truy vấn/lệnh vào tệp điều khiển.  Ví dụ::

# grease giao diện
  :#> bí danh ddcmd='echo $* > /proc/dynamic_debug/control'

:#> ddcmd '-p; chức năng chính của mô-đun chạy* +p'
  :#> grep =p /proc/dynamic_debug/control
  init/main.c:1424 [main]run_init_process =p " với đối số:\012"
  init/main.c:1426 [main]run_init_process =p " %s\012"
  init/main.c:1427 [main]run_init_process =p " với môi trường:\012"
  init/main.c:1429 [main]run_init_process =p " %s\012"

Thông báo lỗi chuyển đến bảng điều khiển/syslog::

:#> chế độ ddcmd foo +p
  dyndbg: từ khóa "chế độ" không xác định
  dyndbg: phân tích truy vấn không thành công
  bash: echo: lỗi ghi: Đối số không hợp lệ

Nếu debugfs cũng được bật và gắn kết, ZZ0000ZZ sẽ được
cũng nằm dưới mount-dir, điển hình là ZZ0001ZZ.

Tham chiếu ngôn ngữ lệnh
==========================

Ở cấp độ từ vựng cơ bản, lệnh là một chuỗi các từ được phân tách
bằng dấu cách hoặc tab.  Vì vậy, tất cả đều tương đương::

:#> tập tin ddcmd svcsock.c dòng 1603 +p
  :#> ddcmd "tập tin svcsock.c dòng 1603 +p"
  :#> ddcmd ' tập tin svcsock.c dòng 1603 +p '

Việc gửi lệnh được giới hạn bởi lệnh gọi hệ thống write().
Nhiều lệnh có thể được viết cùng nhau, được phân tách bằng ZZ0000ZZ hoặc ZZ0001ZZ::

:#> ddcmd "func pnpacpi_get_resources +p; func pnp_sign_mem +p"
  :#> ddcmd <<"EOC"
  func pnpacpi_get_resources +p
  func pnp_sign_mem +p
  EOC
  :#> tập tin truy vấn cat > /proc/dynamic_debug/control

Bạn cũng có thể sử dụng ký tự đại diện trong mỗi cụm từ truy vấn. Quy tắc đối sánh hỗ trợ
ZZ0000ZZ (khớp với 0 hoặc nhiều ký tự) và ZZ0001ZZ (khớp chính xác một ký tự
nhân vật). Ví dụ: bạn có thể khớp tất cả các trình điều khiển usb ::

:#> ddcmd file "drivers/usb/*" +p # "" để ngăn chặn việc mở rộng shell

Về mặt cú pháp, một lệnh là các cặp giá trị từ khóa, theo sau là một
cờ thay đổi hoặc cài đặt::

lệnh ::= match-spec* flags-spec

Lựa chọn ZZ0000ZZ của thông số kỹ thuật phù hợp từ danh mục để áp dụng
cờ-spec, tất cả các ràng buộc được AND cùng nhau.  Từ khóa vắng mặt
giống với từ khóa "*".


Đặc tả đối sánh là một từ khóa chọn thuộc tính của
địa điểm gọi được so sánh và giá trị để so sánh.  Có thể
từ khóa là:::

match-spec ::= chuỗi 'func' |
		 chuỗi 'tập tin' |
		 chuỗi 'mô-đun' |
		 chuỗi 'định dạng' |
		 chuỗi 'lớp' |
		 phạm vi dòng 'line'

phạm vi dòng ::= lineno |
		 '-'lineno |
		 lineno'-' |
		 lineno'-'lineno

lineno ::= unsigned-int

.. note::

  ``line-range`` cannot contain space, e.g.
  "1-30" is valid range but "1 - 30" is not.


Ý nghĩa của từng từ khóa là:

vui vẻ
    Chuỗi đã cho được so sánh với tên hàm
    của từng callsite.  Ví dụ::

func svc_tcp_accept
	func ZZ0000ZZ # in rfcomm, bluetooth, ping, tcp

tập tin
    Chuỗi đã cho được so sánh với chuỗi tương đối src-root
    tên đường dẫn hoặc tên cơ sở của tệp nguồn của mỗi trang gọi.
    Ví dụ::

tập tin svcsock.c
	tập tin kernel/freezer.c # ie cột 1 của tập tin điều khiển
	trình điều khiển tập tin/usb/* # all callites bên dưới nó
	tập tin inode.c:start_* # parse :tail dưới dạng func (ở trên)
	tệp inode.c:1-100 # parse :tail dưới dạng phạm vi dòng (ở trên)

mô-đun
    Chuỗi đã cho được so sánh với tên mô-đun
    của từng callsite.  Tên mô-đun là chuỗi như
    thấy trong ZZ0000ZZ, tức là không có thư mục hoặc ZZ0001ZZ
    hậu tố và với ZZ0002ZZ được đổi thành ZZ0003ZZ.  Ví dụ::

mô-đun sunrpc
	mô-đun nfsd
	mô-đun drm* # both drm, drm_kms_helper

định dạng
    Chuỗi đã cho được tìm kiếm ở định dạng gỡ lỗi động
    chuỗi.  Lưu ý rằng chuỗi không cần phải khớp với
    toàn bộ định dạng, chỉ một phần.  Khoảng trắng và những thứ khác
    các ký tự đặc biệt có thể được thoát bằng ký tự bát phân C
    thoát ký hiệu ZZ0000ZZ, ví dụ: ký tự khoảng trắng là ZZ0001ZZ.
    Ngoài ra, chuỗi có thể được đặt trong dấu ngoặc kép
    ký tự (ZZ0002ZZ) hoặc ký tự trích dẫn đơn (ZZ0003ZZ).
    Ví dụ::

định dạng svcrdma: // nhiều pr_debugs của máy chủ NFS/RDMA
	định dạng đọc trước // một số pr_debug trong bộ đệm đọc trước
	định dạng nfsd:\040SETATTR // một cách để khớp định dạng với khoảng trắng
	định dạng "nfsd: SETATTR" // một cách gọn gàng hơn để khớp định dạng với khoảng trắng
	định dạng 'nfsd: SETATTR' // một cách khác để khớp định dạng với khoảng trắng

lớp học
    Class_name đã cho được xác thực theo từng mô-đun, có thể
    đã khai báo danh sách các tên lớp đã biết.  Nếu class_name là
    được tìm thấy để khớp và điều chỉnh mô-đun, callsite & lớp
    tiến hành.  Ví dụ::

lớp DRM_UT_KMS # a DRM.debug danh mục
	lớp JUNK # silent không khớp
	// class TLD_* # ZZ0004ZZ: không có ký tự đại diện trong tên lớp

dòng
    Số dòng hoặc phạm vi số dòng đã cho được so sánh
    dựa trên số dòng của mỗi callsite ZZ0000ZZ.  Một đĩa đơn
    số dòng khớp chính xác với số dòng của trang web cuộc gọi.  A
    phạm vi số dòng khớp với bất kỳ trang web cuộc gọi nào giữa trang đầu tiên
    và bao gồm số dòng cuối cùng.  Số đầu tiên trống có nghĩa là
    dòng đầu tiên trong tệp, số dòng cuối cùng trống có nghĩa là
    số dòng cuối cùng trong tập tin.  Ví dụ::

dòng 1603 // chính xác là dòng 1603
	dòng 1600-1605 // sáu dòng từ dòng 1600 đến dòng 1605
	dòng -1605 // 1605 dòng từ dòng 1 đến dòng 1605
	dòng 1600- // tất cả các dòng từ dòng 1600 đến cuối file

Đặc tả cờ bao gồm một thao tác thay đổi được thực hiện theo sau
bởi một hoặc nhiều ký tự cờ.  Hoạt động thay đổi là một
của các nhân vật::

- xóa các cờ đã cho
  + thêm các cờ đã cho
  = đặt cờ cho các cờ đã cho

Các lá cờ là::

p kích hoạt trang gọi pr_debug().
  _ không cho phép gắn cờ.

Cờ trang trí thêm vào tiền tố tin nhắn, theo thứ tự:
  t Bao gồm ID luồng hoặc <intr>
  m Bao gồm tên mô-đun
  f Bao gồm tên hàm
  s Bao gồm tên tệp nguồn
  l Bao gồm số dòng
  d Bao gồm dấu vết cuộc gọi

Chỉ dành cho ZZ0000ZZ và ZZ0001ZZ
cờ ZZ0002ZZ có ý nghĩa, các cờ khác bị bỏ qua.

Lưu ý regrec ZZ0000ZZ khớp với thông số cờ.
Để xóa tất cả các cờ cùng một lúc, hãy sử dụng ZZ0001ZZ hoặc ZZ0002ZZ.


Thông báo gỡ lỗi trong quá trình khởi động
==================================

Để kích hoạt các thông báo gỡ lỗi cho mã lõi và các mô-đun tích hợp trong quá trình
quá trình khởi động, ngay cả trước khi tồn tại không gian người dùng và debugf, hãy sử dụng
ZZ0000ZZ hoặc ZZ0001ZZ.  QUERY theo dõi
cú pháp mô tả ở trên nhưng không được vượt quá 1023 ký tự.  của bạn
bootloader có thể áp đặt các giới hạn thấp hơn.

Các thông số ZZ0000ZZ này được xử lý ngay sau khi bảng ddebug được xử lý.
được xử lý, như một phần của Early_initcall.  Vì vậy bạn có thể kích hoạt gỡ lỗi
thông báo trong tất cả các mã chạy sau Early_initcall này thông qua boot này
tham số.

Ví dụ: trên hệ thống x86, hỗ trợ ACPI là subsys_initcall và::

dyndbg="file ec.c +p"

sẽ hiển thị các giao dịch Bộ điều khiển nhúng sớm trong quá trình thiết lập ACPI nếu
máy của bạn (thường là máy tính xách tay) có Bộ điều khiển nhúng.
Việc khởi tạo PCI (hoặc các thiết bị khác) cũng là một ứng cử viên hấp dẫn để sử dụng
tham số khởi động này cho mục đích gỡ lỗi.

Nếu mô-đun ZZ0000ZZ không được tích hợp sẵn, ZZ0001ZZ vẫn sẽ được xử lý ở
thời gian khởi động, không có hiệu lực, nhưng sẽ được xử lý lại khi mô-đun
được tải sau. Bare ZZ0002ZZ chỉ được xử lý khi khởi động.


Thông báo gỡ lỗi tại thời điểm khởi tạo mô-đun
============================================

Khi ZZ0000ZZ được gọi, modprobe sẽ quét ZZ0001ZZ để tìm
ZZ0002ZZ, tách ZZ0003ZZ và chuyển chúng vào kernel cùng với
các thông số được đưa ra trong các tệp modprobe args hoặc ZZ0004ZZ,
theo thứ tự sau:

1. thông số được cung cấp qua ZZ0000ZZ::

tùy chọn foo dyndbg=+pt
	tùy chọn foo dyndbg # defaults tới +p

2. ZZ0000ZZ như được đưa ra trong boot args, ZZ0001ZZ bị loại bỏ và chuyển::

foo.dyndbg=" func bar +p; func buz +mp"

3. lập luận với modprobe::

modprobe foo dyndbg==pmf # override cài đặt trước đó

Các truy vấn ZZ0000ZZ này được áp dụng theo thứ tự, có tiếng nói cuối cùng.
Điều này cho phép các đối số khởi động ghi đè hoặc sửa đổi các đối số đó từ ZZ0001ZZ
(hợp lý, vì 1 là toàn hệ thống, 2 là kernel hoặc boot cụ thể) và
modprobe lập luận để ghi đè cả hai.

Trong biểu mẫu ZZ0000ZZ, truy vấn phải loại trừ ZZ0001ZZ.
ZZ0002ZZ được trích xuất từ tên thông số và được áp dụng cho từng truy vấn trong
ZZ0003ZZ và chỉ cho phép 1 thông số khớp của mỗi loại.

Tùy chọn ZZ0000ZZ là tham số mô-đun "giả", có nghĩa là:

- mô-đun không cần xác định rõ ràng
- mọi mô-đun đều ngầm hiểu nó, cho dù họ có sử dụng pr_debug hay không
- nó không xuất hiện trong ZZ0000ZZ
  Để xem nó, hãy grep tệp điều khiển hoặc kiểm tra ZZ0001ZZ

Đối với hạt nhân ZZ0000ZZ, mọi cài đặt được đưa ra vào lúc khởi động (hoặc
được bật bởi cờ ZZ0001ZZ trong quá trình biên dịch) có thể bị tắt sau này thông qua
giao diện debugfs nếu các thông báo gỡ lỗi không còn cần thiết nữa ::

echo "module module_name -p" > /proc/dynamic_debug/control

Ví dụ
========

::

// kích hoạt thông báo ở dòng 1603 của file svcsock.c
  :#> ddcmd 'file svcsock.c dòng 1603 +p'

// kích hoạt tất cả các tin nhắn trong file svcsock.c
  :#> ddcmd 'tập tin svcsock.c +p'

// kích hoạt tất cả các tin nhắn trong mô-đun máy chủ NFS
  :#> ddcmd 'mô-đun nfsd +p'

// kích hoạt tất cả 12 tin nhắn trong hàm svc_process()
  :#> ddcmd 'func svc_process +p'

// vô hiệu hóa tất cả 12 thông báo trong hàm svc_process()
  :#> ddcmd 'func svc_process -p'

// bật tin nhắn cho NFS gọi READ, READLINK, READDIR và READDIR+.
  :#> ddcmd 'định dạng "nfsd: READ" +p'

// kích hoạt các tin nhắn trong các tệp có đường dẫn bao gồm chuỗi "usb"
  :#> ddcmd 'tập tin ZZ0000ZZ +p'

// kích hoạt tất cả tin nhắn
  :#> ddcmd '+p'

// thêm mô-đun, chức năng vào tất cả các tin nhắn đã bật
  :#> ddcmd '+mf'

// ví dụ về boot-args, với dòng mới và nhận xét để dễ đọc
  Dòng lệnh hạt nhân: ...
    // xem điều gì đang diễn ra trong quá trình xử lý dyndbg=value
    Dynamic_debug.verbose=3
    // kích hoạt pr_debugs trong mô-đun btrfs (có thể được tích hợp sẵn hoặc có thể tải được)
    btrfs.dyndbg="+p"
    // kích hoạt pr_debugs trong tất cả các file trong init/
    // và hàm pars_one, #cmt bị lược bỏ
    dyndbg="file init/* +p #cmt ; func pars_one +p"
    // kích hoạt pr_debugs trong 2 chức năng trong một mô-đun được tải sau
    pc87360.dyndbg="func pc87360_init_device +p; func pc87360_find +p"

Cấu hình hạt nhân
====================

Gỡ lỗi động được bật thông qua các mục cấu hình kernel ::

Danh mục CONFIG_DYNAMIC_DEBUG=y # build, kích hoạt CORE
  CONFIG_DYNAMIC_DEBUG_CORE=y Chỉ dành cho cơ khí # enable, bỏ qua danh mục

Nếu bạn không muốn bật tính năng gỡ lỗi động trên toàn cầu (tức là trong một số
hệ thống), bạn có thể đặt ZZ0000ZZ làm hỗ trợ cơ bản cho động
gỡ lỗi và thêm ZZ0001ZZ vào Makefile của bất kỳ
mô-đun mà bạn muốn gỡ lỗi động sau này.


Hạt nhân ZZ0000ZZ API
==================

Các chức năng sau đây được phân loại và có thể điều khiển được khi động
gỡ lỗi được bật::

pr_debug()
  dev_dbg()
  print_hex_dump_debug()
  print_hex_dump_bytes()

Nếu không, chúng sẽ bị tắt theo mặc định; ZZ0000ZZ hoặc
ZZ0001ZZ trong tệp nguồn sẽ kích hoạt chúng một cách thích hợp.

Nếu ZZ0000ZZ không được đặt thì ZZ0001ZZ sẽ được
chỉ là một phím tắt cho ZZ0002ZZ.

Đối với ZZ0000ZZ/ZZ0001ZZ, chuỗi định dạng là
đối số ZZ0002ZZ của nó, nếu nó là chuỗi không đổi; hoặc ZZ0003ZZ
trong trường hợp ZZ0004ZZ được xây dựng động.
