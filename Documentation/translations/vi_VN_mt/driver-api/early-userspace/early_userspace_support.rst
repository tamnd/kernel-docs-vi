.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/early-userspace/early_userspace_support.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Hỗ trợ không gian người dùng sớm
================================

Cập nhật lần cuối: 20-12-2004 tlh


"Không gian người dùng sớm" là một tập hợp các thư viện và chương trình cung cấp
nhiều phần chức năng khác nhau đủ quan trọng để
có sẵn trong khi nhân Linux sắp xuất hiện, nhưng điều đó không cần thiết
chạy bên trong kernel.

Nó bao gồm một số thành phần cơ sở hạ tầng chính:

- gen_init_cpio, một chương trình xây dựng kho lưu trữ định dạng cpio
  chứa hình ảnh hệ thống tập tin gốc.  Kho lưu trữ này được nén và
  hình ảnh nén được liên kết vào hình ảnh hạt nhân.
- initramfs, một đoạn mã giải nén hình ảnh cpio đã nén
  giữa quá trình khởi động kernel.
- klibc, thư viện C của không gian người dùng, hiện được đóng gói riêng, nghĩa là
  được tối ưu hóa về độ chính xác và kích thước nhỏ.

Định dạng tệp cpio được initramfs sử dụng là "newc" (còn gọi là "cpio -H newc")
định dạng và được ghi lại trong tệp "buffer-format.txt".  có
hai cách để thêm hình ảnh không gian người dùng sớm: chỉ định một cpio hiện có
kho lưu trữ được sử dụng làm hình ảnh hoặc xây dựng quy trình xây dựng kernel
hình ảnh từ thông số kỹ thuật.

Phương pháp CPIO ARCHIVE
-------------------

Bạn có thể tạo một kho lưu trữ cpio chứa hình ảnh không gian người dùng ban đầu.
Kho lưu trữ cpio của bạn phải được chỉ định trong CONFIG_INITRAMFS_SOURCE và nó
sẽ được sử dụng trực tiếp.  Chỉ có thể chỉ định một tệp cpio duy nhất trong
CONFIG_INITRAMFS_SOURCE và tên thư mục và tập tin không được phép trong
kết hợp với kho lưu trữ cpio.

Phương pháp IMAGE BUILDING
---------------------

Quá trình xây dựng kernel cũng có thể xây dựng hình ảnh không gian người dùng ban đầu từ
các bộ phận nguồn thay vì cung cấp kho lưu trữ cpio.  Phương pháp này cung cấp
một cách để tạo hình ảnh bằng các tập tin gốc mặc dù hình ảnh đó đã được
được xây dựng bởi một người dùng không có đặc quyền.

Hình ảnh được chỉ định là một hoặc nhiều nguồn trong
CONFIG_INITRAMFS_SOURCE.  Nguồn có thể là thư mục hoặc tập tin -
kho lưu trữ cpio được ZZ0000ZZ cho phép khi xây dựng từ các nguồn.

Một thư mục nguồn sẽ có nó và tất cả nội dung của nó được đóng gói.  các
tên thư mục được chỉ định sẽ được ánh xạ tới '/'.  Khi đóng gói một
thư mục, dịch ID người dùng và nhóm hạn chế có thể được thực hiện.
INITRAMFS_ROOT_UID có thể được đặt thành ID người dùng cần được ánh xạ tới
người dùng gốc (0).  INITRAMFS_ROOT_GID có thể được đặt thành ID nhóm cần
được ánh xạ tới nhóm gốc (0).

Tệp nguồn phải là các chỉ thị theo định dạng được yêu cầu bởi
tiện ích usr/gen_init_cpio (chạy 'usr/gen_init_cpio -h' để lấy
định dạng tập tin).  Các chỉ thị trong tập tin sẽ được chuyển trực tiếp tới
usr/gen_init_cpio.

Khi sự kết hợp của các thư mục và tập tin được chỉ định thì
hình ảnh initramfs sẽ là tổng hợp của tất cả chúng.  Bằng cách này một người dùng
có thể tạo thư mục 'root-image' và cài đặt tất cả các tệp vào đó.
Vì người dùng không có đặc quyền không thể tạo các tệp đặc biệt cho thiết bị,
các tập tin đặc biệt có thể được liệt kê trong tập tin 'root-files'.  Cả hai 'hình ảnh gốc'
và 'tệp gốc' có thể được liệt kê trong CONFIG_INITRAMFS_SOURCE và một bản đầy đủ
Hình ảnh không gian người dùng ban đầu có thể được xây dựng bởi người dùng không có đặc quyền.

Là một lưu ý kỹ thuật, khi các thư mục và tập tin được chỉ định,
toàn bộ CONFIG_INITRAMFS_SOURCE được chuyển đến
usr/gen_initramfs.sh.  Điều này có nghĩa là CONFIG_INITRAMFS_SOURCE
thực sự có thể được hiểu là bất kỳ lập luận pháp lý nào cho
gen_initramfs.sh.  Nếu một thư mục được chỉ định làm đối số thì
nội dung được quét, dịch uid/gid được thực hiện và
Các chỉ thị của tệp usr/gen_init_cpio được xuất ra.  Nếu một tập tin là
được chỉ định làm đối số cho usr/gen_initramfs.sh thì
nội dung của tập tin được sao chép đơn giản vào đầu ra.  Tất cả đầu ra
các chỉ thị từ việc quét thư mục và sao chép nội dung tập tin được
được xử lý bởi usr/gen_init_cpio.

Xem thêm 'usr/gen_initramfs.sh -h'.

Tất cả điều này dẫn đến đâu?
=========================

Bản phân phối klibc chứa một số phần mềm cần thiết để thực hiện
không gian người dùng sớm hữu ích.  Việc phân phối klibc hiện tại là
được duy trì riêng biệt với kernel.

Bạn có thể có được những bức ảnh chụp nhanh không thường xuyên của klibc từ
ZZ0000ZZ

Đối với người dùng đang hoạt động, tốt hơn hết bạn nên sử dụng klibc git
kho lưu trữ, tại ZZ0000ZZ

Bản phân phối klibc độc lập hiện cung cấp ba thành phần,
ngoài thư viện klibc:

- ipconfig, một chương trình cấu hình giao diện mạng.  Nó có thể
  định cấu hình chúng tĩnh hoặc sử dụng DHCP để lấy thông tin
  động (còn gọi là "tự động cấu hình IP").
- nfsmount, một chương trình có thể gắn hệ thống tập tin NFS.
- kinit, loại "keo" sử dụng ipconfig và nfsmount để thay thế cái cũ
  hỗ trợ tự động cấu hình IP, gắn hệ thống tệp qua NFS và tiếp tục
  khởi động hệ thống bằng hệ thống tập tin đó làm root.

kinit được xây dựng dưới dạng nhị phân được liên kết tĩnh duy nhất để tiết kiệm không gian.

Cuối cùng, hy vọng sẽ có thêm một số chức năng kernel nữa
chuyển sang không gian người dùng sớm:

- Hầu hết tất cả init/do_mounts* (phần đầu của phần này đã có trong
  địa điểm)
- Phân tích bảng ACPI
- Chèn hệ thống con cồng kềnh không thực sự cần có trong kernel
  không gian ở đây

Nếu kinit không đáp ứng nhu cầu hiện tại của bạn và bạn có byte để ghi,
phân phối klibc bao gồm một shell nhỏ tương thích với Bourne (tro)
và một số tiện ích khác nên bạn có thể thay thế kinit và build
hình ảnh initramfs tùy chỉnh đáp ứng chính xác nhu cầu của bạn.

Nếu có thắc mắc và trợ giúp, bạn có thể đăng ký không gian người dùng sớm
danh sách gửi thư tại ZZ0000ZZ

Nó hoạt động như thế nào?
=================

Kernel hiện có 3 cách để mount hệ thống tập tin gốc:

a) tất cả các trình điều khiển thiết bị và hệ thống tập tin cần thiết được biên dịch vào kernel, không
   initrd.  init/main.c:init() sẽ gọi prepare_namespace() để gắn kết
   hệ thống tập tin gốc cuối cùng, dựa trên tùy chọn root= và init= tùy chọn để chạy
   một số nhị phân init khác được liệt kê ở cuối init/main.c:init().

b) một số trình điều khiển thiết bị và hệ thống tập tin được xây dựng dưới dạng mô-đun và được lưu trữ trong một
   initrd.  initrd phải chứa nhị phân '/linuxrc' được cho là
   tải các mô-đun trình điều khiển này.  Cũng có thể gắn root cuối cùng
   hệ thống tập tin thông qua linuxrc và sử dụng tòa nhà chọc trời Pivot_root.  initrd là
   được gắn kết và thực thi thông qua prepare_namespace().

c) sử dụng initramfs.  Cuộc gọi tới prepare_namespace() phải được bỏ qua.
   Điều này có nghĩa là hệ nhị phân phải thực hiện tất cả công việc.  Cho biết nhị phân có thể được lưu trữ
   vào initramfs thông qua sửa đổi usr/gen_init_cpio.c hoặc thông qua mới
   định dạng initrd, một kho lưu trữ cpio.  Nó phải được gọi là "/init".  Hệ nhị phân này
   có trách nhiệm thực hiện tất cả những việc prepare_namespace() sẽ làm.

Để duy trì khả năng tương thích ngược, nhị phân /init sẽ chỉ chạy nếu nó
   đến thông qua một kho lưu trữ cpio initramfs.  Nếu đây không phải là trường hợp,
   init/main.c:init() sẽ chạy prepare_namespace() để mount root cuối cùng
   và thực thi một trong các tệp nhị phân init được xác định trước.

Bryan O'Sullivan <bos@serpentine.com>
