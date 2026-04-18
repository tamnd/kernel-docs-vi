.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/advansys.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================
Ghi chú của Trình điều khiển AdvanSys
=====================================

AdvanSys (Advanced System Products, Inc.) sản xuất các sản phẩm sau
Dựa trên RISC, Bus-Mastering, nhanh (10 Mhz) và siêu hẹp (20 Mhz)
(truyền 8 bit) Bộ điều hợp máy chủ SCSI cho ISA, EISA, VL và PCI
xe buýt và dựa trên RISC, Bus-Mastering, Ultra (20 Mhz) Wide (16-bit
transfer) Bộ điều hợp máy chủ SCSI cho bus PCI.

Số lượng CDB bên dưới cho biết số lượng SCSI CDB (Lệnh
Khối mô tả) các yêu cầu có thể được lưu trữ trong chip RISC
bộ nhớ đệm và bo mạch LRAM. CDB là một lệnh SCSI duy nhất. Người lái xe
quy trình phát hiện sẽ hiển thị số lượng CDB có sẵn cho mỗi
bộ chuyển đổi được phát hiện. Số lượng CDB được trình điều khiển sử dụng có thể là
được hạ xuống trong BIOS bằng cách thay đổi cài đặt bộ điều hợp 'Kích thước hàng đợi máy chủ'.

Sản phẩm máy tính xách tay:
  - ABP-480 - Bus-Master CardBus (16 CDB)

Sản phẩm kết nối:
   - ABP510/5150 - Bus-Master ISA (240 CDB)
   - ABP5140 - Bus-Master ISA PnP (16 CDB)
   - ABP5142 - Bus-Master ISA PnP với đĩa mềm (16 CDB)
   - ABP902/3902 - Bus-Master PCI (16 CDB)
   - ABP3905 - Bus-Master PCI (16 CDB)
   - ABP915 - Bus-Master PCI (16 CDB)
   - ABP920 - Bus-Master PCI (16 CDB)
   - ABP3922 - Bus-Master PCI (16 CDB)
   - ABP3925 - Bus-Master PCI (16 CDB)
   - ABP930 - Bus-Master PCI (16 CDB)
   - ABP930U - Bus-Master PCI Ultra (16 CDB)
   - ABP930UA - Bus-Master PCI Ultra (16 CDB)
   - ABP960 - Bus-Master PCI MAC/PC (16 CDB)
   - ABP960U - Bus-Master PCI MAC/PC Ultra (16 CDB)

Sản phẩm kênh đơn:
   - ABP542 - Bus-Master ISA có đĩa mềm (240 CDB)
   - ABP742 - Bus-Master EISA (240 CDB)
   - ABP842 - Bus-Master VL (240 CDB)
   - ABP940 - Bus-Master PCI (240 CDB)
   - ABP940U - Bus-Master PCI Ultra (240 CDB)
   - ABP940UA/3940UA - Bus-Master PCI Ultra (240 CDB)
   - ABP970 - Bus-Master PCI MAC/PC (240 CDB)
   - ABP970U - Bus-Master PCI MAC/PC Ultra (240 CDB)
   - ABP3960UA - Bus-Master PCI MAC/PC Ultra (240 CDB)
   - ABP940UW/3940UW - Bus-Master PCI Siêu rộng (253 CDB)
   - ABP970UW - Bus-Master PCI MAC/PC Siêu rộng (253 CDB)
   - ABP3940U2W - Bus-Master PCI LVD/Ultra2-Wide (253 CDB)

Sản phẩm đa kênh:
   - ABP752 - Bus-Master kênh đôi EISA (240 CDB mỗi kênh)
   - ABP852 - Bus-Master VL kênh đôi (240 CDB mỗi kênh)
   - ABP950 - Bus-Master kênh đôi PCI (240 CDB mỗi kênh)
   - ABP950UW - Bus-Master kênh đôi PCI siêu rộng (253 CDB mỗi kênh)
   - ABP980 - Bus-Master bốn kênh PCI (240 CDB mỗi kênh)
   - ABP980U - Bus-Master bốn kênh PCI Ultra (240 CDB mỗi kênh)
   - ABP980UA/3980UA - Bus-Master bốn kênh PCI Ultra (16 CDB mỗi kênh.)
   - ABP3950U2W - Bus-Master PCI LVD/Ultra2-Wide và Ultra-Wide (253 CDB)
   - ABP3950U3W - Bus-Master PCI Dual LVD2/Ultra3-Wide (253 CDB)

Tùy chọn thời gian biên dịch trình điều khiển và gỡ lỗi
=======================================================

Các hằng số sau có thể được xác định trong tệp nguồn.

1. ADVANSYS_ASSERT - Kích hoạt xác nhận trình điều khiển (Def: Đã bật)

Việc bật tùy chọn này sẽ thêm các câu lệnh logic xác nhận vào
   người lái xe. Nếu xác nhận không thành công, một thông báo sẽ được hiển thị cho
   bảng điều khiển, nhưng hệ thống sẽ tiếp tục hoạt động. bất kỳ
   những khẳng định gặp phải phải được báo cáo cho người đó
   chịu trách nhiệm về người lái xe. Các câu khẳng định có thể chủ động
   phát hiện các vấn đề với trình điều khiển và tạo điều kiện khắc phục những vấn đề này
   vấn đề. Việc kích hoạt xác nhận sẽ thêm một chi phí nhỏ vào
   thực hiện của người lái xe.

2. ADVANSYS_DEBUG - Bật gỡ lỗi trình điều khiển (Def: Đã tắt)

Việc bật tùy chọn này sẽ thêm các chức năng theo dõi vào trình điều khiển và
   khả năng thiết lập mức độ theo dõi trình điều khiển khi khởi động.  Tùy chọn này là
   rất hữu ích cho việc gỡ lỗi trình điều khiển, nhưng nó sẽ làm tăng thêm kích thước
   của hình ảnh thực thi trình điều khiển và thêm chi phí cho việc thực thi
   người lái xe.

Số lượng đầu ra gỡ lỗi có thể được kiểm soát bằng toàn cầu
   biến 'asc_dbglvl'. Con số càng cao thì sản lượng càng nhiều. Bởi
   mặc định mức gỡ lỗi là 0.

Nếu trình điều khiển được tải khi khởi động và Tùy chọn trình điều khiển LILO
   được bao gồm trong hệ thống, mức độ gỡ lỗi có thể được thay đổi bằng cách
   chỉ định Cổng I/O thứ 5 (ASC_NUM_IOPORT_PROBE + 1). các
   ba chữ số hex đầu tiên của Cổng I/O giả phải được đặt thành
   'deb' và chữ số hex thứ tư chỉ định mức gỡ lỗi: 0 - F.
   Dòng lệnh sau sẽ tìm bộ điều hợp ở 0x330
   và đặt mức gỡ lỗi thành 2::

linux advansys=0x330,0,0,0,0xdeb2

Nếu trình điều khiển được xây dựng dưới dạng mô-đun có thể tải thì biến này có thể được
   được xác định khi trình điều khiển được tải. Lệnh insmod sau
   sẽ đặt mức gỡ lỗi thành một::

insmod advansys.o asc_dbglvl=1

Gỡ lỗi cấp độ tin nhắn:


==== ====================
      Chỉ có 0 lỗi
      1 Truy tìm cấp cao
      Theo dõi chi tiết 2-N
      ==== ====================

Để bật đầu ra gỡ lỗi cho bảng điều khiển, vui lòng đảm bảo rằng:

Một. Ghi nhật ký hệ thống và kernel được bật (syslogd, klogd đang chạy).
   b. Thông báo hạt nhân được chuyển đến đầu ra của bàn điều khiển. Kiểm tra
      /etc/syslog.conf cho một mục tương tự như sau::

kern.* /dev/console

c. klogd được bắt đầu với tham số -c thích hợp
      (ví dụ: klogd -c 8)

Điều này sẽ khiến thông báo printk() được hiển thị trên
   bảng điều khiển hiện tại. Tham khảo trang man klogd(8) và syslogd(8)
   để biết chi tiết.

Ngoài ra, bạn có thể bật printk() để điều khiển bằng cái này
   chương trình. Tuy nhiên, đây không phải là cách 'chính thức' để thực hiện việc này.

Đầu ra gỡ lỗi được ghi vào /var/log/messages.

   ::

chính()
     {
             syscall(103, 7, 0, 0);
     }

Tăng LOG_BUF_LEN trong kernel/printk.c thành một cái gì đó như
   40960 cho phép thêm nhiều thông báo gỡ lỗi được lưu vào bộ đệm trong kernel
   và được ghi vào bảng điều khiển hoặc tệp nhật ký.

3. ADVANSYS_STATS - Kích hoạt thống kê (Def: Đã bật)

Bật tùy chọn này sẽ thêm tính năng thu thập và hiển thị số liệu thống kê
   thông qua /proc tới trình điều khiển. Thông tin rất hữu ích cho
   giám sát hiệu suất của trình điều khiển và thiết bị. Nó sẽ thêm vào
   kích thước của hình ảnh thực thi trình điều khiển và thêm chi phí nhỏ vào
   việc thực hiện của người lái xe.

Số liệu thống kê được duy trì trên cơ sở mỗi bộ chuyển đổi. Nhập tài xế
   số lượng cuộc gọi điểm và số lượng kích thước chuyển được duy trì.
   Thống kê chỉ có sẵn cho các hạt nhân lớn hơn hoặc bằng
   lên v1.3.0 với hệ thống tệp CONFIG_PROC_FS (/proc) được định cấu hình.

Các tệp bộ điều hợp AdvanSys SCSI có định dạng tên đường dẫn sau::

/proc/scsi/advansys/{0,1,2,3,...}

Thông tin này có thể được hiển thị với cat. Ví dụ::

mèo /proc/scsi/advansys/0

Khi ADVANSYS_STATS không được xác định thì chỉ có các tệp AdvanSys /proc
   chứa thông tin cấu hình bộ điều hợp và thiết bị.

Tùy chọn trình điều khiển LILO
==============================

Nếu init/main.c được sửa đổi như được mô tả trong 'Hướng dẫn thêm
phần Trình điều khiển AdvanSys cho Linux' (B.4.) ở trên, trình điều khiển sẽ
nhận ra dòng lệnh 'advansys' LILO và tùy chọn /etc/lilo.conf.
Tùy chọn này có thể được sử dụng để vô hiệu hóa việc quét cổng I/O hoặc để hạn chế
quét tới 1 - 4 cổng I/O. Bất kể cài đặt tùy chọn EISA và
Bảng PCI vẫn sẽ được tìm kiếm và phát hiện. Tùy chọn này chỉ
ảnh hưởng đến việc tìm kiếm bảng ISA và VL.

Ví dụ:
  1. Loại bỏ việc quét cổng I/O:

khởi động::

linux advansys=

hoặc::

khởi động: linux advansys=0x0

2. Giới hạn việc quét cổng I/O ở một cổng I/O:

khởi động::

linux advansys=0x110

3. Giới hạn việc quét cổng I/O ở bốn cổng I/O:

khởi động::

linux advansys=0x110,0x210,0x230,0x330

Đối với mô-đun có thể tải, có thể đạt được hiệu quả tương tự bằng cách cài đặt
biến 'asc_iopflag' và mảng 'asc_ioport' khi tải
người lái xe, ví dụ::

insmod advansys.o asc_iopflag=1 asc_ioport=0x110,0x330

Nếu ADVANSYS_DEBUG được xác định là thứ 5 (ASC_NUM_IOPORT_PROBE + 1)
Cổng I/O có thể được thêm vào để chỉ định mức độ gỡ lỗi của trình điều khiển. tham khảo
phần 'Tùy chọn thời gian biên dịch trình điều khiển và gỡ lỗi' ở trên để biết
thêm thông tin.

Tín dụng (Thứ tự thời gian)
=============================

Bob Frey <bfrey@turbolinux.com.cn> đã viết trình điều khiển AdvanSys SCSI
và duy trì nó lên tới 3,3F. Anh tiếp tục trả lời câu hỏi
và giúp duy trì trình điều khiển.

Nathan Hartwell <mage@cdc3.cdc.net> đã cung cấp hướng dẫn và
cơ sở cho những thay đổi Linux v1.3.X được bao gồm trong
phát hành 1.2.

Thomas E Zerucha <zerucha@shell.portal.com> đã chỉ ra một lỗi
trong advansys_biosparam() đã được sửa trong bản phát hành 1.3.

Erik Ratcliffe <erik@caldera.com> đã thực hiện thử nghiệm
Trình điều khiển AdvanSys trong các bản phát hành Caldera.

Rik van Riel <H.H.vanRiel@fys.ruu.nl> đã cung cấp bản vá cho
AscWaitTixISRDone() mà anh thấy cần thiết để thực hiện
trình điều khiển hoạt động với đĩa SCSI-1.

Mark Moran <mmoran@mmoran.com> đã giúp thử nghiệm Ultra-Wide
support in the 3.1A driver.

Doug Gilbert <dgilbert@interlog.com> đã thực hiện các thay đổi và
đề xuất cải thiện trình điều khiển và thực hiện rất nhiều thử nghiệm.

Ken Mort <ken@mort.net> đã báo cáo lỗi biên dịch DEBUG đã được sửa
trong 3,2K.

Tom Rini <trini@kernel.crashing.org> đã cung cấp CONFIG_ISA
vá và hỗ trợ bảng mạch rộng và hẹp PowerPC.

Philip Blundell <philb@gnu.org> đã cung cấp
bản vá advansys_interrupts_enabled.

Dave Jones <dave@denial.force9.co.uk> đã báo cáo trình biên dịch
cảnh báo được tạo khi CONFIG_PROC_FS không được xác định trong
trình điều khiển 3,2M.

Jerry Quinn <jlquinn@us.ibm.com> đã sửa lỗi hỗ trợ PowerPC (endian
vấn đề) cho thẻ rộng.

Bryan Henderson <bryanh@giraffe-data.com> đã giúp gỡ lỗi thu hẹp
xử lý lỗi thẻ.

Manuel Veloso <veloso@pobox.com> đã làm việc chăm chỉ trên PowerPC hẹp
hỗ trợ bảng và sửa lỗi trong AscGetEEPConfig().

Arnaldo Carvalho de Melo <acme@conectiva.com.br> đã thực hiện
thay đổi save_flags/restore_flags.

Andy Kellner <Akellner@connectcom.net> tiếp tục về Advansys SCSI
phát triển trình điều khiển cho ConnectCom (Phiên bản > 3.3F).

Ken Witherow đã thử nghiệm rộng rãi trong quá trình phát triển phiên bản 3.4.