.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/earlyprintk.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============
Bản in sớm
=============

Mini-HOWTO để sử dụng tùy chọn khởi động Earlyprintk=dbgp với
USB2 Khóa cổng gỡ lỗi và cáp gỡ lỗi trên hệ thống x86.

Bạn cần hai máy tính, tiện ích đặc biệt 'USB debug key' và
hai cáp USB, được kết nối như thế này::

[máy chủ/đích] <-------> [Khóa gỡ lỗi USB] <-------> [máy khách/bảng điều khiển]

Yêu cầu phần cứng
=====================

a) Hệ thống máy chủ/đích cần có khả năng cổng gỡ lỗi USB.

Bạn có thể kiểm tra khả năng này bằng cách xem bit 'Cổng gỡ lỗi' trong
     đầu ra lspci -vvv::

# lspci -vvv
       ...
00:1d.7 Bộ điều khiển USB: Intel Corporation 82801H (Dòng ICH8) USB2 EHCI Bộ điều khiển #1 (rev 03) (prog-if 20 [EHCI])
               Hệ thống con: Lenovo ThinkPad T61
               Điều khiển: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
               Trạng thái: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
               Độ trễ: 0
               Ngắt: chân D được định tuyến tới IRQ 19
               Vùng 0: Bộ nhớ ở fe227000 (32-bit, không thể tìm nạp trước) [size=1K]
               Khả năng: [50] Quản lý nguồn phiên bản 2
                       Cờ: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                       Trạng thái: D0 PME-Enable- DSel=0 DScale=0 PME+
               Khả năng: [58] Cổng gỡ lỗi: BAR=1 offset=00a0
                            ^^ ^^^ ^^ ^^ ^^ <======================= [ HERE ]
               Trình điều khiển hạt nhân đang sử dụng: ehci_hcd
               Mô-đun hạt nhân: ehci-hcd
       ...

     .. note::
       If your system does not list a debug port capability then you probably
       won't be able to use the USB debug key.

b) Bạn cũng cần có cáp/khóa gỡ lỗi NetChip USB:

ZZ0000ZZ

Đây là đầu nối nhỏ bằng nhựa màu xanh lam có hai đầu nối USB;
     nó lấy năng lượng từ các kết nối USB của nó.

c) Bạn cần hệ thống máy khách/bảng điều khiển thứ hai có cổng USB 2.0 tốc độ cao.

d) Thiết bị NetChip phải được cắm trực tiếp vào mạng vật lý
     cổng gỡ lỗi trên hệ thống "máy chủ/đích". Bạn không thể sử dụng trung tâm USB trong
     giữa cổng gỡ lỗi vật lý và hệ thống "máy chủ/đích".

Bộ điều khiển gỡ lỗi EHCI được liên kết với USB vật lý cụ thể
     cổng và thiết bị NetChip sẽ chỉ hoạt động như một bản in sớm
     thiết bị ở cổng này.  Bộ điều khiển máy chủ EHCI được điều khiển bằng điện
     được nối dây sao cho bộ điều khiển gỡ lỗi EHCI được nối với
     cổng vật lý đầu tiên và không có cách nào để thay đổi điều này thông qua phần mềm.
     Bạn có thể tìm thấy cổng vật lý thông qua thử nghiệm bằng cách thử
     từng cổng vật lý trên hệ thống và khởi động lại.  Hoặc bạn có thể thử
     và sử dụng lsusb hoặc xem các thông báo thông tin kernel được phát ra bởi
     ngăn xếp usb khi bạn cắm thiết bị usb vào các cổng khác nhau trên
     hệ thống "máy chủ/đích".

Một số nhà cung cấp phần cứng không hiển thị cổng gỡ lỗi usb bằng
     đầu nối vật lý và nếu bạn tìm thấy một thiết bị như vậy hãy gửi khiếu nại
     cho nhà cung cấp phần cứng, vì không có lý do gì để không kết nối
     cổng này thành một trong các cổng có thể truy cập vật lý.

e) Điều quan trọng cần lưu ý là nhiều phiên bản của NetChip
     thiết bị yêu cầu hệ thống "máy khách/bảng điều khiển" được cắm vào
     phía bên phải của thiết bị (với logo sản phẩm hướng lên trên và
     có thể đọc được từ trái sang phải).  Lý do là vì điện áp 5V
     Nguồn điện chỉ được lấy từ một phía của thiết bị và nó
     phải là bên không được khởi động lại.

Yêu cầu phần mềm
=====================

a) Trên hệ thống máy chủ/đích:

Bạn cần kích hoạt tùy chọn cấu hình kernel sau::

CONFIG_EARLY_PRINTK_DBGP=y

Và bạn cần thêm dòng lệnh khởi động: "earlyprintk=dbgp".

    .. note::
      If you are using Grub, append it to the 'kernel' line in
      /etc/grub.conf.  If you are using Grub2 on a BIOS firmware system,
      append it to the 'linux' line in /boot/grub2/grub.cfg. If you are
      using Grub2 on an EFI firmware system, append it to the 'linux'
      or 'linuxefi' line in /boot/grub2/grub.cfg or
      /boot/efi/EFI/<distro>/grub.cfg.

Trên các hệ thống có nhiều bộ điều khiển gỡ lỗi EHCI, bạn phải
    chỉ định số bộ điều khiển gỡ lỗi EHCI chính xác.  Việc đặt hàng
    xuất phát từ việc liệt kê bus PCI của bộ điều khiển EHCI.  các
    mặc định không có đối số số là "0" hoặc gỡ lỗi EHCI đầu tiên
    bộ điều khiển.  Để sử dụng bộ điều khiển gỡ lỗi EHCI thứ hai, bạn sẽ
    sử dụng dòng lệnh: "earlyprintk=dbgp1"

    .. note::
      normally earlyprintk console gets turned off once the
      regular console is alive - use "earlyprintk=dbgp,keep" to keep
      this channel open beyond early bootup. This can be useful for
      debugging crashes under Xorg, etc.

b) Trên hệ thống client/console:

Bạn nên kích hoạt tùy chọn cấu hình kernel sau::

CONFIG_USB_SERIAL_DEBUG=y

Trong lần khởi động tiếp theo với kernel đã sửa đổi, bạn nên
    nhận (các) thiết bị/dev/ttyUSBx.

Bây giờ kênh thông báo kernel này đã sẵn sàng để sử dụng: start
    trình mô phỏng thiết bị đầu cuối yêu thích của bạn (minicom, v.v.) và thiết lập
    tùy ý sử dụng /dev/ttyUSB0 - hoặc sử dụng 'cat /dev/ttyUSBx' thô để
    xem đầu ra thô.

c) Trên các hệ thống dựa trên Nvidia Southbridge: kernel sẽ cố gắng thăm dò
     và tìm ra cổng nào có thiết bị gỡ lỗi được kết nối.

Kiểm tra
========

Bạn có thể kiểm tra đầu ra bằng cách sử dụng Earlyprintk=dbgp,keep và Provoking
thông điệp kernel trên hệ thống máy chủ/đích. Bạn có thể kích động một điều vô hại
thông báo kernel chẳng hạn bằng cách thực hiện ::

echo h > /proc/sysrq-trigger

Trên hệ thống máy chủ/đích, bạn sẽ thấy dòng trợ giúp này ở đầu ra "dmesg"::

SysRq : HELP : loglevel(0-9) reBoot Crashdump chấm dứt-tất cả-tác vụ(E) bộ nhớ-full-oom-kill(F) kill-all-tasks(I) saK show-backtrace-all-active-cpus(L) show-memory-usage(M) nice-all-RT-tasks(N) powerOff show-registers(P) show-all-timers(Q) unRaw Sync show-task-states(T) Ngắt kết nối show-blocked-tasks(W) dump-ftrace-buffer(Z)

Trên hệ thống máy khách/bảng điều khiển, hãy thực hiện::

con mèo /dev/ttyUSB0

Và bạn sẽ thấy dòng trợ giúp ở trên được hiển thị ngay sau khi bạn
kích động nó trên hệ thống máy chủ.

Nếu nó không hoạt động thì vui lòng hỏi về nó trên linux-kernel@vger.kernel.org
danh sách gửi thư hoặc liên hệ với người bảo trì x86.