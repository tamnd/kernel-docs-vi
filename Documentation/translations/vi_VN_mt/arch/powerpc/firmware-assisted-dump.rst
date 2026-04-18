.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/firmware-assisted-dump.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================
Kết xuất được hỗ trợ bởi phần mềm cơ sở
======================

tháng 7 năm 2011

Mục tiêu của kết xuất được hỗ trợ bởi phần sụn là cho phép kết xuất
một hệ thống bị lỗi và thực hiện việc đó từ một hệ thống được thiết lập lại hoàn toàn và
để giảm thiểu tổng thời gian trôi qua cho đến khi hệ thống hoạt động trở lại
trong sử dụng sản xuất.

- Cơ sở hạ tầng kết xuất được hỗ trợ phần sụn (FADump) nhằm thay thế
  bãi chứa hỗ trợ phyp hiện có.
- Fadump sử dụng cùng giao diện phần sụn và mô hình dự trữ bộ nhớ
  như bãi chứa hỗ trợ phyp.
- Không giống như kết xuất phyp, FADump xuất kết xuất bộ nhớ thông qua /proc/vmcore
  ở định dạng ELF giống như kdump. Điều này giúp chúng ta tái sử dụng
  cơ sở hạ tầng kdump để thu thập và lọc kết xuất.
- Không giống như kết xuất phyp, công cụ không gian người dùng không cần tham chiếu bất kỳ sysf nào
  giao diện trong khi đọc /proc/vmcore.
- Không giống như kết xuất phyp, FADump cho phép người dùng giải phóng tất cả bộ nhớ dành riêng
  để kết xuất, với một thao tác duy nhất echo 1 > /sys/kernel/fadump_release_mem.
- Sau khi được kích hoạt thông qua tham số khởi động kernel, FADump có thể
  bắt đầu/dừng thông qua giao diện /sys/kernel/fadump_registered (xem
  sysfs bên dưới) và có thể dễ dàng tích hợp với kdump
  các tập lệnh init bắt đầu/dừng dịch vụ.

So sánh với kdump hoặc các chiến lược khác, được hỗ trợ bởi phần sụn
dump mang lại một số lợi ích thiết thực và mạnh mẽ:

- Không giống như kdump, hệ thống đã được thiết lập lại và tải
   với một bản sao mới của kernel.  Đặc biệt,
   Các thiết bị PCI và I/O đã được khởi tạo lại và
   ở trạng thái sạch sẽ, nhất quán.
- Sau khi kết xuất được sao chép ra, bộ nhớ chứa kết xuất
   ngay lập tức có sẵn cho kernel đang chạy. Và do đó,
   không giống như kdump, FADump không cần khởi động lại lần thứ 2 để quay lại
   hệ thống đến cấu hình sản xuất.

Những điều trên chỉ có thể được thực hiện bằng cách phối hợp với,
và hỗ trợ từ phần sụn Power. Thủ tục là
như sau:

- Hạt nhân đầu tiên đăng ký các phần bộ nhớ với
   Phần sụn cấp nguồn để bảo quản kết xuất trong quá trình khởi tạo hệ điều hành.
   Những phần bộ nhớ đã đăng ký này được dành riêng bởi phần đầu tiên
   kernel trong quá trình khởi động sớm.

- Khi hệ thống gặp sự cố, Power firmware sẽ sao chép thông tin đã đăng ký
   vùng bộ nhớ thấp (bộ nhớ khởi động) từ vùng nguồn đến vùng đích.
   Nó cũng sẽ lưu phần cứng của PTE.

NOTE:
         Thuật ngữ 'bộ nhớ khởi động' có nghĩa là kích thước của đoạn bộ nhớ thấp
         điều đó là cần thiết để hạt nhân khởi động thành công khi
         khởi động với bộ nhớ hạn chế. Theo mặc định, bộ nhớ khởi động
         kích thước sẽ lớn hơn 5% của hệ thống RAM hoặc 256MB.
         Ngoài ra, người dùng cũng có thể chỉ định kích thước bộ nhớ khởi động
         thông qua tham số khởi động 'crashkernel=' sẽ ghi đè
         kích thước tính toán mặc định. Sử dụng tùy chọn này nếu mặc định
         kích thước bộ nhớ khởi động không đủ cho kernel thứ hai
         khởi động thành công. Đối với cú pháp của tham số Crashkernel=,
         tham khảo Tài liệu/admin-guide/kdump/kdump.rst. Nếu có
         offset được cung cấp trong tham số Crashkernel=, nó sẽ là
         bị bỏ qua vì FADump sử dụng phần bù được xác định trước để dự trữ bộ nhớ
         để bảo toàn kết xuất bộ nhớ khởi động trong trường hợp xảy ra sự cố.

- Sau khi vùng bộ nhớ thấp (bộ nhớ khởi động) đã được lưu,
   chương trình cơ sở sẽ thiết lập lại PCI và trạng thái phần cứng khác.  Nó sẽ
   ZZ0000ZZ xóa RAM. Sau đó nó sẽ khởi chạy bộ nạp khởi động, như
   bình thường.

- Kernel mới khởi động sẽ thông báo có nút mới
   (rtas/ibm,kernel-dump trên pSeries hoặc ibm,opal/dump/mpipl-boot
   trên nền tảng OPAL) trong cây thiết bị, cho biết rằng
   có sẵn dữ liệu sự cố từ lần khởi động trước. Trong thời gian
   Hệ điều hành khởi động sớm sẽ dự trữ phần bộ nhớ còn lại ở trên
   kích thước bộ nhớ khởi động khởi động hiệu quả với bộ nhớ bị hạn chế
   kích thước. Điều này sẽ đảm bảo rằng hạt nhân này (cũng được gọi là
   thành hạt nhân thứ hai hoặc hạt nhân chụp) sẽ không chạm vào bất kỳ
   của vùng bộ nhớ kết xuất.

- Công cụ không gian người dùng sẽ đọc /proc/vmcore để lấy nội dung
   bộ nhớ chứa kết xuất kernel bị hỏng trước đó trong ELF
   định dạng. Công cụ không gian người dùng có thể sao chép thông tin này vào đĩa hoặc
   mạng, nas, san, iscsi, v.v. theo ý muốn.

- Khi công cụ không gian người dùng hoàn tất việc lưu kết xuất, nó sẽ lặp lại
   '1' tới /sys/kernel/fadump_release_mem để giải phóng phần dành riêng
   bộ nhớ trở lại sử dụng chung, ngoại trừ bộ nhớ cần thiết cho
   đăng ký kết xuất được hỗ trợ bởi chương trình cơ sở tiếp theo.

ví dụ.::

# echo 1 > /sys/kernel/fadump_release_mem

Xin lưu ý rằng tính năng kết xuất được hỗ trợ bởi phần sụn
chỉ khả dụng trên các hệ thống POWER6 trở lên trên pSeries
(PowerVM) nền tảng và các hệ thống POWER9 trở lên với OP940
hoặc các phiên bản phần sụn mới hơn trên nền tảng PowerNV (OPAL).
Lưu ý rằng, phần mềm OPAL xuất nút ibm,opal/dump khi
FADump được hỗ trợ trên nền tảng PowerNV.

Trên các máy dựa trên OPAL, trước tiên hệ thống khởi động ở trạng thái không liên tục
kernel (gọi tắt là kernel petitboot) trước khi khởi động vào
bắt hạt nhân. Hạt nhân này sẽ có hạt nhân tối thiểu và/hoặc
hỗ trợ không gian người dùng để xử lý dữ liệu sự cố. Hạt nhân như vậy cần phải
bảo tồn bộ nhớ của hạt nhân bị lỗi trước đó cho lần tiếp theo
chụp kernel boot để xử lý dữ liệu sự cố này. Cấu hình hạt nhân
tùy chọn CONFIG_PRESERVE_FA_DUMP phải được kích hoạt trên kernel đó
để đảm bảo rằng dữ liệu sự cố được bảo tồn để xử lý sau này.

-- Trên các máy dựa trên OPAL (PowerNV), nếu kernel được xây dựng bằng
   CONFIG_OPAL_CORE=y, bộ nhớ OPAL tại thời điểm xảy ra sự cố cũng bị mất
   được xuất dưới dạng tệp /sys/firmware/opal/mpipl/core. Tập tin Procfs này là
   hữu ích trong việc gỡ lỗi OPAL gặp sự cố với GDB. Bộ nhớ hạt nhân
   được sử dụng để xuất tệp Procfs này có thể được phát hành bằng echo'ing
   '1' tới nút /sys/firmware/opal/mpipl/release_core.

ví dụ.
     # echo 1 > /sys/firmware/opal/mpipl/release_core

-- Hỗ trợ các đối số hạt nhân bổ sung trong Fadump
   Fadump có tính năng cho phép truyền thêm đối số kernel
   đến hạt nhân fadump. Tính năng này được thiết kế chủ yếu để vô hiệu hóa
   các chức năng kernel không cần thiết cho kernel fadump
   và để giảm dung lượng bộ nhớ trong khi thu thập kết xuất.

Lệnh thêm các tham số hạt nhân bổ sung vào Fadump:
  ví dụ:
  # echo "nr_cpus=16" > /sys/kernel/fadump/bootargs_append

Lệnh trên là đủ để thêm các đối số bổ sung vào fadump.
  Việc khởi động lại dịch vụ rõ ràng là không cần thiết.

Lệnh truy xuất các đối số Fadump bổ sung:
  ví dụ:
  # cat /sys/kernel/fadump/bootargs_append

Lưu ý: Các đối số kernel bổ sung cho fadump với HASH MMU chỉ
      được hỗ trợ nếu kích thước RMA lớn hơn 768 MB. Nếu RMA
      kích thước nhỏ hơn 768 MB, hạt nhân không xuất được
      /sys/kernel/fadump/bootargs_append nút sysfs.

Chi tiết triển khai:
-----------------------

Trong quá trình khởi động, việc kiểm tra sẽ được thực hiện để xem phần sụn có hỗ trợ không
tính năng này trên máy cụ thể đó. Nếu vậy thì
chúng tôi kiểm tra xem liệu một kết xuất đang hoạt động có đang chờ chúng tôi hay không. Nếu có
thì mọi thứ trừ kích thước bộ nhớ khởi động của RAM đều được bảo lưu trong
khởi động sớm (Xem Hình 2). Khu vực này sẽ được giải phóng sau khi chúng tôi hoàn thành
thu thập kết xuất từ tập lệnh đất của người dùng (ví dụ: tập lệnh kdump)
đang được chạy. Nếu có dữ liệu kết xuất thì
Tệp /sys/kernel/fadump_release_mem được tạo và dành riêng
bộ nhớ được giữ lại.

Nếu không có dữ liệu kết xuất đang chờ thì chỉ có bộ nhớ cần thiết để
giữ trạng thái CPU, vùng HPTE, kết xuất bộ nhớ khởi động và tiêu đề FADump là
thường được đặt trước ở mức bù lớn hơn kích thước bộ nhớ khởi động (xem Hình 1).
Vùng này được ZZ0000ZZ phát hành: vùng này sẽ được giữ vĩnh viễn
dành riêng, để nó có thể hoạt động như một nơi chứa bản sao của boot
nội dung bộ nhớ ngoài trạng thái CPU và vùng HPTE, trong trường hợp
một sự cố xảy ra.

Vì vùng bộ nhớ dành riêng này chỉ được sử dụng sau khi hệ thống gặp sự cố,
không có ích gì khi chặn đoạn bộ nhớ đáng kể này khỏi
hạt nhân sản xuất. Do đó, việc triển khai sử dụng nhân Linux
Bộ cấp phát bộ nhớ liền kề (CMA) để dự trữ bộ nhớ nếu CMA là
được cấu hình cho kernel. Với việc đặt trước CMA, bộ nhớ này sẽ được
có sẵn cho các ứng dụng sử dụng nó, trong khi kernel bị ngăn không cho
sử dụng nó. Với FADump này sẽ vẫn có thể nắm bắt được tất cả
bộ nhớ kernel và hầu hết bộ nhớ không gian người dùng ngoại trừ các trang người dùng
đã có mặt ở vùng CMA::

o Dự trữ bộ nhớ trong kernel đầu tiên

Bộ nhớ thấp Bộ nhớ trên cùng
  0 kích thước bộ nhớ khởi động ZZ0000ZZ |
  ZZ0001ZZ ZZ0002ZZ |
  V V ZZ0003ZZ V
  +----------+-----/ /---+---+----+-----------+-------+----+------+
  ZZ0004ZZ ZZ0005ZZ////ZZ0006ZZ HDR ZZ0007ZZ |
  +----------+-----/ /---+---+----+-----------+-------+----+------+
        |                   ^ ^ ^ ^ ^
        ZZ0008ZZ ZZ0009ZZ ZZ0010ZZ
        \ CPU HPTE / ZZ0011ZZ
         -------------------------------- ZZ0012ZZ
      Nội dung bộ nhớ khởi động được chuyển ZZ0013ZZ
      vào vùng dành riêng bằng firmware tại ZZ0014ZZ
      thời điểm xảy ra sự cố.                               ZZ0015ZZ
                                           Tiêu đề FADump |
                                            (khu vực meta) |
                                                          |
                                                          |
                      Siêu dữ liệu: Khu vực này chứa cấu trúc siêu dữ liệu có
                      địa chỉ được đăng ký với f/w và được truy xuất trong
                      kernel thứ hai sau sự cố, trên nền tảng hỗ trợ
                      thẻ (OPAL). Có cấu trúc như vậy với thông tin cần thiết
                      để xử lý kết xuất sự cố giúp giảm bớt quá trình chụp kết xuất.

Hình 1


o Dự trữ bộ nhớ trong kernel thứ hai sau sự cố

Bộ nhớ thấp Bộ nhớ trên cùng
  0 kích thước bộ nhớ khởi động |
  ZZ0000ZZ<------------- Khu vực bảo tồn sự cố -------------->|
  V V ZZ0001ZZ |
  +----+---+--+-----/ /---+---+----+-------+------+------+-------+
  ZZ0002ZZELFZZ0003ZZ ZZ0004ZZ////ZZ0005ZZ HDR ZZ0006ZZ |
  +----+---+--+-----/ /---+---+----+-------+------+------+-------+
       ZZ0007ZZ ZZ0008ZZ ZZ0009ZZ
       ----- ------------------------------ ---------------
         \ ZZ0010ZZ
           \ ZZ0011ZZ
             \ ZZ0012ZZ
               \ |    ----------------------------
                 \ |   /
                   \ |  /
                     \ | /
                  /proc/vmcore


+---+
        ZZ0000ZZ -> Khu vực (CPU, HPTE & Siêu dữ liệu) được đánh dấu như thế này ở trên
        +---+ số liệu không phải lúc nào cũng có mặt. Ví dụ: nền tảng OPAL
                 không có vùng CPU & HPTE trong khi vùng Siêu dữ liệu là
                 hiện không được hỗ trợ trên pSeries.

+---+
        ZZ0000ZZ -> elfcorehdr, nó được tạo trong kernel thứ hai sau sự cố.
        +---+

Lưu ý: Bộ nhớ từ 0 đến kích thước bộ nhớ khởi động được sử dụng bởi kernel thứ hai

Hình 2


Hiện tại kết xuất sẽ được sao chép từ /proc/vmcore sang một tệp mới theo
sự can thiệp của người dùng. Dữ liệu kết xuất có sẵn thông qua /proc/vmcore sẽ là
ở định dạng ELF. Do đó cơ sở hạ tầng kdump hiện có (tập lệnh kdump)
để lưu kết xuất hoạt động tốt với những sửa đổi nhỏ. Tập lệnh KDump đang bật
các bản phát hành Distro chính đã được sửa đổi để hoạt động trơn tru (không có
sự can thiệp của người dùng vào việc lưu kết xuất) khi FADump được sử dụng, thay vì
KDump, như cơ chế kết xuất.

Các công cụ để kiểm tra dump sẽ giống như công cụ
được sử dụng cho kdump.

Cách bật kết xuất được hỗ trợ bởi chương trình cơ sở (FADump):
----------------------------------------------

1. Đặt tùy chọn cấu hình CONFIG_FA_DUMP=y và xây dựng kernel.
2. Khởi động vào kernel linux với tùy chọn dòng lệnh kernel 'fadump=on'.
   Theo mặc định, bộ nhớ dành riêng FADump sẽ được khởi tạo dưới dạng vùng CMA.
   Ngoài ra, người dùng có thể khởi động kernel linux bằng 'fadump=nocma' để
   ngăn FADump sử dụng CMA.
3. Tùy chọn, người dùng cũng có thể đặt dòng lệnh kernel 'crashkernel=' kernel
   để chỉ định kích thước của bộ nhớ dự trữ cho kết xuất bộ nhớ khởi động
   bảo quản.

NOTE:
     1. Tham số 'fadump_reserve_mem=' không còn được dùng nữa. Thay vào đó
        sử dụng 'crashkernel=' để chỉ định kích thước bộ nhớ dự trữ
        để bảo quản kết xuất bộ nhớ khởi động.
     2. Nếu kết xuất được hỗ trợ bởi chương trình cơ sở không dự trữ được bộ nhớ thì nó
        sẽ chuyển sang cơ chế kdump hiện có nếu 'crashkernel='
        tùy chọn được đặt ở cmdline kernel.
     3. nếu người dùng muốn chiếm toàn bộ bộ nhớ không gian của người dùng và đồng ý với
        bộ nhớ dành riêng không có sẵn cho hệ thống sản xuất, sau đó
        Tham số kernel 'fadump=nocma' có thể được sử dụng để dự phòng
        hành vi cũ.

Tệp Sysfs/debugfs:
--------------------

Tính năng kết xuất được hỗ trợ bởi phần sụn sử dụng hệ thống tệp sysfs để lưu giữ
các tệp điều khiển và tệp gỡ lỗi để hiển thị vùng dành riêng cho bộ nhớ.

Đây là danh sách các tập tin trong kernel sysfs:

/sys/kernel/fadump_enabled
    Điều này được sử dụng để hiển thị trạng thái FADump.

- 0 = FADump bị tắt
    - 1 = FADump được bật

Giao diện này có thể được sử dụng bởi các tập lệnh init kdump để xác định xem
    FADump được kích hoạt trong kernel và hoạt động tương ứng.

/sys/kernel/fadump_registered
    Điều này cũng được sử dụng để hiển thị trạng thái đăng ký FADump
    để kiểm soát (bắt đầu/dừng) đăng ký FADump.

- 0 = FADump chưa được đăng ký.
    - 1 = FADump đã được đăng ký và sẵn sàng xử lý sự cố hệ thống.

Để đăng ký FADump echo 1 > /sys/kernel/fadump_registered và
    echo 0 > /sys/kernel/fadump_registered để hủy đăng ký và dừng
    FADump. Sau khi FADump chưa được đăng ký, hệ thống sẽ không gặp sự cố
    được xử lý và vmcore sẽ không bị bắt. Giao diện này có thể
    dễ dàng tích hợp với dịch vụ bắt đầu/dừng kdump.

/sys/kernel/fadump/mem_reserved

Điều này được sử dụng để hiển thị bộ nhớ được FADump dành riêng để lưu
   bãi chứa sự cố.

/sys/kernel/fadump_release_mem
    Tệp này chỉ khả dụng khi FADump hoạt động trong
    hạt nhân thứ hai. Điều này được sử dụng để giải phóng bộ nhớ dành riêng
    khu vực được giữ để lưu kết xuất sự cố. Để giải phóng
    bộ nhớ dành riêng echo 1 cho nó::

echo 1 > /sys/kernel/fadump_release_mem

Sau echo 1, nội dung của /sys/kernel/debug/powerpc/fadump_zone
    tập tin sẽ thay đổi để phản ánh việc đặt trước bộ nhớ mới.

Các công cụ không gian người dùng hiện có (cơ sở hạ tầng kdump) có thể dễ dàng
    được cải tiến để sử dụng giao diện này nhằm giải phóng bộ nhớ dành riêng cho
    kết xuất và tiếp tục mà không cần khởi động lại lần thứ 2.

Lưu ý: /sys/kernel/fadump_release_opalcore sysfs đã chuyển sang
      /sys/firmware/opal/mpipl/release_core

/sys/firmware/opal/mpipl/release_core

Tệp này chỉ khả dụng trên các máy dựa trên OPAL khi FADump được bật
    hoạt động trong quá trình chụp kernel. Điều này được sử dụng để giải phóng bộ nhớ
    được kernel sử dụng để xuất tệp /sys/firmware/opal/mpipl/core. Đến
    giải phóng bộ nhớ này, lặp lại '1' với nó:

echo 1 > /sys/firmware/opal/mpipl/release_core

Lưu ý: Các tệp sysfs FADump sau đây không được dùng nữa.

+------------------------------------------------+--------------------------------+
ZZ0000ZZ thay thế |
+------------------------------------------------+--------------------------------+
ZZ0001ZZ /sys/kernel/fadump/enabled |
+------------------------------------------------+--------------------------------+
ZZ0002ZZ /sys/kernel/fadump/đã đăng ký |
+------------------------------------------------+--------------------------------+
ZZ0003ZZ /sys/kernel/fadump/release_mem |
+------------------------------------------------+--------------------------------+

Đây là danh sách các tập tin trong phần gỡ lỗi powerpc:
(Giả sử các debugf được gắn trên thư mục/sys/kernel/debug.)

/sys/kernel/debug/powerpc/fadump_khu vực
    Tệp này hiển thị các vùng bộ nhớ dành riêng nếu FADump được
    được bật nếu không thì tệp này trống. Định dạng đầu ra
    là::

<khu vực>: [<start>-<end>] <reserved-size> byte, Đã kết xuất: <dump-size>

và đối với vùng DUMP kernel là:

DUMP: Src: <src-addr>, Đích: <dest-addr>, Kích thước: <size>, Đã kết xuất: # bytes

ví dụ.
    Nội dung khi FADump được đăng ký trong kernel đầu tiên::

# cat/sys/kernel/debug/powerpc/fadump_khu vực
      CPU: [0x0000006ffb0000-0x0000006fff001f] 0x40020 byte, Đã kết xuất: 0x0
      HPTE: [0x0000006fff0020-0x0000006fff101f] 0x1000 byte, Đã kết xuất: 0x0
      DUMP: [0x0000006fff1020-0x0000007fff101f] 0x10000000 byte, Đã kết xuất: 0x0

Nội dung khi FADump hoạt động trong kernel thứ hai::

# cat/sys/kernel/debug/powerpc/fadump_khu vực
      CPU: [0x0000006ffb0000-0x0000006fff001f] 0x40020 byte, Đã kết xuất: 0x40020
      HPTE: [0x0000006fff0020-0x0000006fff101f] 0x1000 byte, Đã kết xuất: 0x1000
      DUMP: [0x0000006fff1020-0x0000007fff101f] 0x10000000 byte, Đã kết xuất: 0x10000000
          : [0x00000010000000-0x0000006ffaffff] 0x5ffb0000 byte, Đã kết xuất: 0x5ffb0000


NOTE:
      Vui lòng tham khảo Tài liệu/filesystems/debugfs.rst trên
      cách gắn hệ thống tập tin debugfs.


TODO:
-----
- Cần tìm ra cách tiếp cận tốt hơn để tìm hiểu thêm
   kích thước bộ nhớ khởi động chính xác cần thiết cho kernel
   khởi động thành công khi khởi động với bộ nhớ bị hạn chế.

Tác giả: Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>

Tài liệu này dựa trên tài liệu gốc được viết cho phyp

bãi chứa được hỗ trợ bởi Linas Vepstas và Manish Ahuja.
