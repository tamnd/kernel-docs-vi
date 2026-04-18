.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/amd-debugging.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Gỡ lỗi hệ thống AMD Zen
+++++++++++++++++++++++++

Giới thiệu
============

Tài liệu này mô tả các kỹ thuật hữu ích để gỡ lỗi các vấn đề với
Hệ thống Zen AMD.  Nó được thiết kế để sử dụng bởi các nhà phát triển và người dùng kỹ thuật
để giúp xác định và giải quyết vấn đề.

S3 vs s2idle
============

Trên các hệ thống AMD, không thể hỗ trợ đồng thời hệ thống treo cho RAM (S3)
và tạm dừng ở chế độ không hoạt động (s2idle).  Để xác nhận chế độ nào hệ thống của bạn hỗ trợ bạn
có thể nhìn vào ZZ0000ZZ.  Nếu nó hiển thị ZZ0001ZZ thì
ZZ0003ZZ được hỗ trợ.  Nếu nó hiển thị ZZ0002ZZ thì ZZ0004ZZ là
được hỗ trợ.

Trên các hệ thống hỗ trợ ZZ0000ZZ, phần sụn sẽ được sử dụng để đưa tất cả phần cứng vào
trạng thái năng lượng thấp thích hợp.

Trên các hệ thống hỗ trợ ZZ0000ZZ, kernel sẽ chịu trách nhiệm chuyển đổi các thiết bị
sang trạng thái năng lượng thấp thích hợp. Khi tất cả các thiết bị ở mức thấp thích hợp
trạng thái nguồn, phần cứng sẽ chuyển sang trạng thái ngủ phần cứng.

Sau chu kỳ tạm dừng, bạn có thể biết lượng thời gian đã dành cho chế độ ngủ phần cứng
trạng thái bằng cách nhìn vào ZZ0000ZZ.

Sơ đồ này giải thích cách hoạt động của luồng tạm dừng AMD s2idle.

.. kernel-figure:: suspend.svg

Sơ đồ này giải thích cách hoạt động của luồng tiếp tục AMD s2idle.

.. kernel-figure:: resume.svg

công cụ gỡ lỗi s2idle
=====================

Vì có rất nhiều nơi có thể xảy ra sự cố nên một công cụ gỡ lỗi đã được cung cấp.
được tạo ra tại
ZZ0000ZZ
có thể giúp kiểm tra các vấn đề thường gặp và đưa ra đề xuất.

Nếu bạn gặp vấn đề về s2idle, tốt nhất bạn nên bắt đầu với vấn đề này và làm theo hướng dẫn
từ những phát hiện của nó.  Nếu bạn tiếp tục gặp sự cố, hãy khắc phục lỗi với
báo cáo được tạo từ tập lệnh này tới
ZZ0000ZZ.

Đánh thức s2idle giả từ IRQ
===================================

Các lần đánh thức giả thường sẽ có IRQ được đặt thành ZZ0000ZZ.
Điều này có thể được so khớp với ZZ0001ZZ để xác định thiết bị nào đã đánh thức hệ thống.

Nếu điều này không đủ để khắc phục sự cố thì các tệp sysfs sau
có thể được đặt để tăng thêm mức độ chi tiết cho quá trình đánh thức: ::

# echo 1 | sudo tee /sys/power/pm_debug_messages
  # echo 1 | sudo tee /sys/power/pm_print_times

Sau khi thực hiện những thay đổi đó, kernel sẽ hiển thị các thông báo có thể
được truy trở lại mã vòng lặp kernel s2idle cũng như hiển thị bất kỳ hoạt động nào
Nguồn GPIO khi thức dậy.

Nếu việc đánh thức là do ACPI SCI gây ra, việc gỡ lỗi ACPI bổ sung có thể là
cần thiết.  Các lệnh này có thể kích hoạt dữ liệu theo dõi bổ sung: ::

Kích hoạt # echo | Sudo tee /sys/module/acpi/parameter/trace_state
  # echo 1 | sudo tee /sys/module/acpi/parameters/aml_debug_output
  # echo 0x0800000f | sudo tee /sys/module/acpi/parameters/debug_level
  # echo 0xffff0000 | Sudo tee /sys/module/acpi/parameter/debug_layer

Đánh thức s2idle giả từ GPIO
===================================

Nếu GPIO hoạt động khi đánh thức hệ thống thì lý tưởng nhất là bạn nên xem xét
sơ đồ để xác định nó được liên kết với thiết bị nào. Nếu sơ đồ
không có sẵn, một chiến thuật khác là xem mục nhập ACPI _EVT()
để xác định thiết bị nào được thông báo khi GPIO đó hoạt động.

Để có một ví dụ giả định, giả sử GPIO 59 đã đánh thức hệ thống.  bạn có thể
nhìn vào SSDT để xác định thiết bị nào được thông báo khi GPIO 59 hoạt động.

Đầu tiên chuyển đổi số GPIO thành hex. ::

$ python3 -c "print(hex(59))"
  0x3b

Tiếp theo xác định bảng ACPI nào có mục nhập ZZ0000ZZ. Ví dụ: ::

$ sudo grep EVT /sys/firmware/acpi/tables/SSDT*
  grep: /sys/firmware/acpi/tables/SSDT27: tệp nhị phân khớp

Giải mã bảng này::

$ sudo cp /sys/firmware/acpi/tables/SSDT27 .
  $ sudo iasl -d SSDT27

Sau đó nhìn vào bảng và tìm mục nhập phù hợp cho GPIO 0x3b. ::

Trường hợp (0x3B)
  {
      M000 (0x393B)
      M460 (" Thông báo (\\_SB.PCI0.GP17.XHC1, 0x02)\n", Không, Không, Không, Không, Không, Không)
      Thông báo (\_SB.PCI0.GP17.XHC1, 0x02) // Đánh thức thiết bị
  }

Bạn có thể thấy trong trường hợp này thiết bị ZZ0000ZZ được thông báo
khi GPIO 59 hoạt động. Rõ ràng đây là bộ điều khiển XHCI, nhưng để thực hiện
bước xa hơn bạn có thể tìm ra bộ điều khiển XHCI nào bằng cách khớp nó với
ACPI.::

$ grep "PCI0.GP17.XHC1" /sys/bus/acpi/devices/*/path
  /sys/bus/acpi/devices/device:2d/path:\_SB_.PCI0.GP17.XHC1
  /sys/bus/acpi/devices/device:2e/path:\_SB_.PCI0.GP17.XHC1.RHUB
  /sys/bus/acpi/devices/device:2f/path:\_SB_.PCI0.GP17.XHC1.RHUB.PRT1
  /sys/bus/acpi/devices/device:30/path:\_SB_.PCI0.GP17.XHC1.RHUB.PRT1.CAM0
  /sys/bus/acpi/devices/device:31/path:\_SB_.PCI0.GP17.XHC1.RHUB.PRT1.CAM1
  /sys/bus/acpi/devices/device:32/path:\_SB_.PCI0.GP17.XHC1.RHUB.PRT2
  /sys/bus/acpi/devices/LNXPOWER:0d/path:\_SB_.PCI0.GP17.XHC1.PWRS

Ở đây bạn có thể thấy nó khớp với ZZ0000ZZ. Nhìn vào ZZ0001ZZ
để xác định thiết bị PCI thực sự là gì. ::

$ ls -l /sys/bus/acpi/devices/device:2d/physical_node
  lrwxrwxrwx 1 root root 0 12 tháng 2 13:22 /sys/bus/acpi/devices/device:2d/physical_node -> ../../../../../pci0000:00/0000:00:08.1/0000:c2:00.4

Vậy là bạn đã hiểu: thiết bị PCI được liên kết với quá trình đánh thức GPIO này là ZZ0000ZZ.

Tập lệnh ZZ0000ZZ sẽ ghi lại hầu hết các tạo phẩm này cho bạn.

thông báo gỡ lỗi PM s2idle
========================

Trong quá trình s2idle trên hệ thống AMD, trình điều khiển ACPI LPS0 chịu trách nhiệm
để kiểm tra tất cả các ràng buộc uPEP.  Việc không thực hiện được các ràng buộc uPEP không ngăn cản được
mục nhập s0i3.  Điều này có nghĩa là nếu một số ràng buộc không được đáp ứng, có thể
kernel có thể cố gắng vào s2idle ngay cả khi có một số vấn đề đã biết.

Để kích hoạt gỡ lỗi PM, hãy chỉ định kernel ZZ0000ZZ
tùy chọn dòng lệnh khi khởi động hoặc ghi vào ZZ0001ZZ.
Các ràng buộc chưa được đáp ứng sẽ được hiển thị trong nhật ký kernel và có thể
được xem bằng các công cụ ghi nhật ký xử lý bộ đệm vòng nhân như ZZ0002ZZ hoặc
ZZ0003ZZ."

Nếu hệ thống bị treo khi vào/ra trước khi các thông báo này bị xóa, một
Chiến thuật gỡ lỗi hữu ích là hủy liên kết trình điều khiển ZZ0000ZZ để ngăn chặn
thông báo tới nền tảng để bắt đầu nhập s0i3.  Điều này sẽ dừng việc
hệ thống không bị treo khi vào hoặc thoát và cho phép bạn xem tất cả các lỗi không thành công
những hạn chế. ::

cd /sys/bus/platform/drivers/amd_pmc
  ls ZZ0000ZZ sudo tee hủy liên kết

Sau khi thực hiện việc này, hãy chạy chu trình tạm dừng và tìm kiếm cụ thể các lỗi xung quanh: ::

ACPI: LPI: Không đáp ứng được ràng buộc; trạng thái nguồn tối thiểu:%s trạng thái nguồn hiện tại:%s

Các ví dụ lịch sử về vấn đề s2idle
====================================

Để giúp hiểu các loại sự cố có thể xảy ra và cách gỡ lỗi,
đây là một số ví dụ lịch sử về các vấn đề s2idle đã được giải quyết.

Cốt lõi ngoại tuyến
--------------
Một người dùng cuối đã báo cáo rằng việc lấy lõi ngoại tuyến sẽ ngăn hệ thống
từ việc nhập đúng s0i3.  Điều này đã được gỡ lỗi bằng các công cụ AMD nội bộ
để nắm bắt và hiển thị luồng số liệu từ phần cứng cho biết những gì đã thay đổi
khi lõi đã ngoại tuyến.  Người ta xác định rằng phần cứng không nhận được
thông báo các lõi ngoại tuyến ở trạng thái sâu nhất và do đó nó đã ngăn chặn
CPU đi vào trạng thái sâu nhất. Sự cố đã được sửa lỗi thành thiếu
lệnh đưa lõi vào C3 khi ngoại tuyến.

ZZ0000ZZ

Tham nhũng sau khi tiếp tục
-----------------------
Một vấn đề lớn xảy ra với Rembrandt là có đồ họa
tham nhũng sau khi tiếp tục.  Điều này xảy ra do sự điều chỉnh sai của PSP
và trách nhiệm của người lái xe.  PSP sẽ lưu và khôi phục DMCUB, nhưng
trình điều khiển cho rằng cần thiết lập lại DMCUB khi tiếp tục.
Đây thực ra cũng là một sự sai lệch đối với silicon trước đây, nhưng không phải vậy.
quan sát thấy.

ZZ0000ZZ

Back to Back đình chỉ không thành công
--------------------------
Khi sử dụng nguồn đánh thức kích hoạt IRQ đánh thức, một lỗi trong
Trình điều khiển pinctrl-amd có thể ghi lại trạng thái sai của IRQ và ngăn chặn
hệ thống sẽ trở lại chế độ ngủ bình thường.

ZZ0000ZZ

Đánh thức dựa trên bộ đếm thời gian giả sau 5 phút
-------------------------------------------
Tuy nhiên, HPET đang được sử dụng để lập trình nguồn đánh thức cho hệ thống
điều này đã gây ra sự thức tỉnh giả sau 5 phút.  Báo thức chính xác để sử dụng
là báo động ACPI.

ZZ0000ZZ

Đĩa biến mất sau khi tiếp tục
----------------------------
Sau khi tiếp tục từ s2idle, đĩa NVME sẽ biến mất.  Điều này là do
BIOS không chỉ định thuộc tính _DSD StorageD3Enable.  Điều này khiến NVME
trình điều khiển không đưa đĩa vào trạng thái dự kiến khi tạm dừng và bị lỗi
trên sơ yếu lý lịch.

ZZ0000ZZ

IRQ1 giả
-------------
Một số nền tảng Renoir, Lucienne, Cezanne và Barcelo có
lỗi phần sụn nền tảng trong đó IRQ1 được kích hoạt trong quá trình tiếp tục s0i3.

Điều này đã được sửa trong phần sụn nền tảng, nhưng một số hệ thống thì không.
nhận thêm bất kỳ bản cập nhật chương trình cơ sở nền tảng nào.

ZZ0000ZZ

Hết thời gian chờ phần cứng
----------------
Phần cứng thực hiện nhiều hành động bên cạnh việc chấp nhận các giá trị từ
trình điều khiển amd-pmc.  Vì đường truyền thông với phần cứng là một hộp thư,
có thể nó không phản hồi đủ nhanh.
Sự cố này được biểu hiện là không thể tạm dừng: ::

CH: dpm_run_callback(): acpi_subsys_suspend_noirq+0x0/0x50 trả về -110
  amd_pmc AMDI0005:00: PM: không thể tạm dừng noirq: lỗi -110

Vấn đề về thời gian được xác định bằng cách so sánh các giá trị của mặt nạ nhàn rỗi.

ZZ0000ZZ

Không thể đạt đến trạng thái ngủ phần cứng khi bật bảng điều khiển
--------------------------------------------------
Trên một số hệ thống Strix, người ta quan sát thấy một số bảng nhất định chặn hệ thống khỏi
chuyển sang trạng thái ngủ phần cứng nếu bảng điều khiển bên trong được bật trong suốt chuỗi.

Mặc dù bảng điều khiển đã bị tắt trong quá trình tạm dừng nhưng nó vẫn gặp vấn đề về thời gian
trong đó một sự gián đoạn khiến phần cứng màn hình thức dậy và chặn nguồn điện thấp
nhập cảnh của nhà nước.

ZZ0000ZZ

Vấn đề tiêu thụ năng lượng trong thời gian chạy
================================

Mức tiêu thụ điện năng trong thời gian chạy bị ảnh hưởng bởi nhiều yếu tố, bao gồm nhưng không
giới hạn ở cấu hình của Quản lý năng lượng trạng thái hoạt động PCIe (ASPM),
độ sáng màn hình, chính sách EPP của CPU và quản lý năng lượng
của các thiết bị.

ASPM
----
Để có mức tiêu thụ điện năng tốt nhất trong thời gian chạy, ASPM phải được lập trình như dự định
bởi BIOS từ nhà cung cấp phần cứng.  Để thực hiện điều này, nhân Linux
nên được biên dịch với ZZ0000ZZ được đặt thành ZZ0001ZZ và
Không nên sửa đổi tệp sysfs ZZ0002ZZ.

Đáng chú ý nhất là nếu L1.2 không được cấu hình đúng cách cho bất kỳ thiết bị nào, SoC sẽ
sẽ không thể vào trạng thái nhàn rỗi sâu nhất.

Chính sách EPP
----------
Tệp sysfs ZZ0000ZZ có thể được sử dụng để đặt độ lệch
về hiệu quả hoặc hiệu suất cho CPU.  Điều này có mối quan hệ trực tiếp đến
thời lượng pin khi thiên về hiệu suất hơn.


Thông báo gỡ lỗi BIOS
===================

Hầu hết các máy OEM không có UART nối tiếp để xuất kernel hoặc BIOS
thông báo gỡ lỗi. Tuy nhiên, thông báo gỡ lỗi BIOS rất hữu ích để hiểu
cả lỗi BIOS và lỗi với trình điều khiển nhân Linux gọi BIOS AML.

Vì BIOS trên hầu hết các hệ thống OEM AMD đều dựa trên AMD tham chiếu BIOS,
cơ sở hạ tầng được sử dụng để xuất thông báo gỡ lỗi thường giống nhau
như AMD tham chiếu BIOS.

Phân tích cú pháp thủ công
----------------
Nói chung có một phương pháp ACPI ZZ0000ZZ mà các đường dẫn khác nhau của AML
sẽ gọi để phát ra một thông báo tới nhật ký nối tiếp BIOS. Phương pháp này mất
7 đối số, với đối số đầu tiên là một chuỗi và phần còn lại là tùy chọn
số nguyên::

Phương thức (M460, 7, được tuần tự hóa)

Dưới đây là ví dụ về chuỗi mà BIOS AML có thể gọi ra bằng ZZ0000ZZ::

M460 (" Địa chỉ OEM-ASL-PCIe (0x%X)._REG (%d %d) PCSA = %d\n", DADR, Arg0, Arg1, PCSA, Zero, Zero)

Thông thường khi được thực thi, phương thức ZZ0000ZZ sẽ điền thêm
đối số vào chuỗi.  Để nhận được những tin nhắn này từ Linux
kernel một hook đã được thêm vào ACPICA có thể bắt được ZZ0002ZZ
được gửi tới ZZ0001ZZ và in chúng vào bộ đệm vòng hạt nhân.
Ví dụ: thông báo sau có thể được phát vào bộ đệm vòng kernel ::

extrace-0174 ex_trace_args : " Địa chỉ OEM-ASL-PCIe (0x%X)._REG (%d %d) PCSA = %d\n", ec106000, 2, 1, 1, 0, 0

Để nhận được những tin nhắn này, bạn cần biên dịch bằng ZZ0000ZZ
rồi bật các tham số theo dõi ACPICA sau đây.
Điều này có thể được thực hiện trên dòng lệnh kernel hoặc trong thời gian chạy:

* ZZ0000ZZ
* ZZ0001ZZ

NOTE: Chúng có thể rất ồn khi khởi động. Nếu bạn bật các thông số này
lệnh kernel, vui lòng xem xét việc bật ZZ0000ZZ
lên kích thước lớn hơn chẳng hạn như 17 để tránh mất thông báo khởi động sớm.

Phân tích cú pháp được hỗ trợ bởi công cụ
---------------------
Như đã đề cập ở trên, việc phân tích cú pháp bằng tay có thể tẻ nhạt, đặc biệt với rất nhiều
tin nhắn.  Để trợ giúp việc này, một công cụ đã được tạo ra tại
ZZ0000ZZ
để giúp phân tích các tin nhắn.

Sự cố khởi động lại ngẫu nhiên
====================

Khi xảy ra khởi động lại ngẫu nhiên, lý do cấp cao cho việc khởi động lại sẽ được lưu trữ
trong một sổ đăng ký sẽ tồn tại ở lần khởi động tiếp theo.

Có 6 loại lý do cho việc khởi động lại:
 * Phần mềm gây ra
 * Chuyển đổi trạng thái nguồn
 * Pin cảm ứng
 * Phần cứng gây ra
 * Đặt lại từ xa
 * Sự kiện CPU nội bộ

.. csv-table::
   :header: "Bit", "Type", "Reason"
   :align: left

   "0",  "Pin",      "thermal pin BP_THERMTRIP_L was tripped"
   "1",  "Pin",      "power button was pressed for 4 seconds"
   "2",  "Pin",      "shutdown pin was tripped"
   "4",  "Remote",   "remote ASF power off command was received"
   "9",  "Internal", "internal CPU thermal limit was tripped"
   "16", "Pin",      "system reset pin BP_SYS_RST_L was tripped"
   "17", "Software", "software issued PCI reset"
   "18", "Software", "software wrote 0x4 to reset control register 0xCF9"
   "19", "Software", "software wrote 0x6 to reset control register 0xCF9"
   "20", "Software", "software wrote 0xE to reset control register 0xCF9"
   "21", "ACPI-state", "ACPI power state transition occurred"
   "22", "Pin",      "keyboard reset pin KB_RST_L was tripped"
   "23", "Internal", "internal CPU shutdown event occurred"
   "24", "Hardware", "system failed to boot before failed boot timer expired"
   "25", "Hardware", "hardware watchdog timer expired"
   "26", "Remote",   "remote ASF reset command was received"
   "27", "Internal", "an uncorrected error caused a data fabric sync flood event"
   "29", "Internal", "FCH and MP1 failed warm reset handshake"
   "30", "Internal", "a parity error occurred"
   "31", "Internal", "a software sync flood event occurred"

Thông tin này được kernel đọc khi khởi động và in vào
nhật ký hệ thống. Khi xảy ra khởi động lại ngẫu nhiên, thông báo này có thể hữu ích
để xác định thành phần tiếp theo cần gỡ lỗi.