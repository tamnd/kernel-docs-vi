.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/firmware-guide/acpi/apei/einj.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================
APEI Lỗi phun
====================

EINJ cung cấp cơ chế tiêm lỗi phần cứng. Nó rất hữu ích
để gỡ lỗi và kiểm tra các tính năng APEI và RAS nói chung.

Trước tiên, bạn cần kiểm tra xem BIOS của bạn có hỗ trợ EINJ hay không. Để làm điều đó, hãy nhìn
để biết các thông báo khởi động sớm tương tự như thông báo này::

ACPI: EINJ 0x000000007370A000 000150 (v01 INTEL 00000001 INTL 00000001)

điều này cho thấy BIOS đang hiển thị bảng EINJ - đó là
cơ chế mà qua đó việc tiêm được thực hiện.

Ngoài ra, hãy tìm trong /sys/firmware/acpi/tables để tìm tệp "EINJ",
đó là một đại diện khác nhau của cùng một điều.

Điều đó không nhất thiết có nghĩa là EINJ không được hỗ trợ nếu những điều trên
không tồn tại: trước khi bạn từ bỏ, hãy vào thiết lập BIOS để xem BIOS có
có một tùy chọn để kích hoạt tính năng chèn lỗi. Hãy tìm thứ gọi là WHEA
hoặc tương tự. Thông thường, bạn cần bật tùy chọn hỗ trợ ACPI5 trước đó, trong
để xem chức năng APEI,EINJ,... được hỗ trợ và hiển thị bởi
menu BIOS.

Để sử dụng EINJ, hãy đảm bảo các tùy chọn sau được bật trong kernel của bạn
cấu hình::

CONFIG_DEBUG_FS
  CONFIG_ACPI_APEI
  CONFIG_ACPI_APEI_EINJ

...and to (optionally) enable CXL protocol error injection set::

  CONFIG_ACPI_APEI_EINJ_CXL

Giao diện người dùng EINJ nằm trong <debugfs mount point>/apei/einj.

Các tập tin sau thuộc về nó:

- có sẵn_error_type

Tệp này hiển thị loại lỗi nào được hỗ trợ:

========================================================
  Loại lỗi Giá trị Lỗi Mô tả
  ========================================================
  Bộ xử lý 0x00000001 có thể sửa được
  Bộ xử lý 0x00000002 Không thể sửa được, không gây tử vong
  Bộ xử lý 0x00000004 Không thể sửa chữa gây tử vong
  Bộ nhớ 0x00000008 có thể sửa được
  Bộ nhớ 0x00000010 Không thể sửa được, không gây tử vong
  0x00000020 Bộ nhớ không thể sửa được gây tử vong
  0x00000040 PCI Express có thể sửa được
  0x00000080 PCI Express Không thể sửa được, không gây tử vong
  0x00000100 PCI Express Không thể sửa chữa gây tử vong
  Nền tảng 0x00000200 có thể sửa được
  Nền tảng 0x00000400 Không thể sửa được, không gây tử vong
  Nền tảng 0x00000800 Không thể sửa chữa gây tử vong
  Lỗi bộ xử lý V2_0x00000001 EINJV2
  Lỗi bộ nhớ V2_0x00000002 EINJV2
  Lỗi nhanh V2_0x00000004 EINJV2 PCI Express
  ========================================================

Định dạng của nội dung tập tin như trên, ngoại trừ hiện tại chỉ có
  các loại lỗi có sẵn.

- lỗi_type

Đặt giá trị của loại lỗi được đưa vào. Các loại lỗi có thể xảy ra
  được xác định trong tệp available_error_type ở trên.

- error_inject

Viết bất kỳ số nguyên nào vào tệp này để kích hoạt việc chèn lỗi. làm
  chắc chắn bạn đã chỉ định tất cả các tham số lỗi cần thiết, tức là điều này
  write phải là bước cuối cùng khi chèn lỗi.

- cờ

Có mặt cho phiên bản kernel 3.13 trở lên. Dùng để chỉ rõ cái nào
  của thông số{1..4} là hợp lệ và phải được chương trình cơ sở sử dụng trong
  tiêm. Giá trị là mặt nạ bit như được chỉ định trong thông số ACPI5.0 cho
  Cấu trúc dữ liệu SET_ERROR_TYPE_WITH_ADDRESS:

Bit 0
      Trường APIC của bộ xử lý hợp lệ (xem thông số 3 bên dưới).
    Bit 1
      Địa chỉ bộ nhớ và mặt nạ hợp lệ (param1 và param2).
    Bit 2
      PCIe (seg,bus,dev,fn) hợp lệ (xem thông số 4 bên dưới).
    Bit 3
      Cấu trúc mở rộng EINJv2 hợp lệ

Nếu được đặt thành 0, hành vi kế thừa sẽ được bắt chước trong đó loại
  phép tiêm chỉ định một tập hợp bit và param1 được ghép kênh.

- thông số1

Tệp này được sử dụng để đặt giá trị tham số lỗi đầu tiên. Tác dụng của nó
  phụ thuộc vào loại lỗi được chỉ định trong error_type. Ví dụ, nếu
  loại lỗi là loại liên quan đến bộ nhớ, param1 phải hợp lệ
  địa chỉ bộ nhớ vật lý. [Trừ khi "cờ" được đặt - xem ở trên]

- param2

Sử dụng tương tự như param1 ở trên. Ví dụ: nếu loại lỗi là về bộ nhớ
  loại liên quan thì param2 phải là mặt nạ địa chỉ bộ nhớ vật lý.
  Linux yêu cầu độ chi tiết của trang hoặc hẹp hơn, chẳng hạn như 0xfffffffffffff000.

- param3

Được sử dụng khi bit 0x1 được đặt trong "cờ" để chỉ định id APIC

- param4
  Được sử dụng khi bit 0x4 được đặt trong "cờ" để chỉ định thiết bị PCIe mục tiêu

- không kích hoạt

Cơ chế chèn lỗi là một quá trình gồm hai bước. Đầu tiên tiêm
  lỗi, sau đó thực hiện một số hành động để kích hoạt lỗi đó. Cài đặt "nottrigger"
  thành 1 bỏ qua giai đoạn kích hoạt, ZZ0000ZZ cho phép người dùng gây ra
  lỗi trong một số ngữ cảnh khác bằng cách truy cập đơn giản vào CPU, bộ nhớ
  vị trí hoặc thiết bị là mục tiêu của việc chèn lỗi. liệu
  điều này thực sự hoạt động phụ thuộc vào hoạt động thực sự của BIOS
  bao gồm trong giai đoạn kích hoạt.

- thành phần_id0 .. thành phần_idN, thành phần_syndrome0 .. thành phần_syndromeN

Các tệp này được sử dụng để đặt trường "Mảng thành phần"
  của Cấu trúc mở rộng EINJv2. Mỗi cái chứa 128-bit
  giá trị hex. Chỉ viết một dòng mới cho bất kỳ tệp nào trong số này
  đặt một giá trị không hợp lệ (tất cả những cái).

Các loại lỗi CXL được hỗ trợ từ ACPI 6.5 trở đi (được cung cấp cổng CXL
có mặt). Giao diện người dùng EINJ cho các loại lỗi CXL có tại
<điểm gắn kết debugfs>/cxl. Các tập tin sau thuộc về nó:

- einj_types:

Cung cấp chức năng tương tự như available_error_types ở trên, nhưng
  đối với các loại lỗi CXL

- $dport_dev/einj_inject:

Đưa loại lỗi CXL vào cổng CXL được đại diện bởi $dport_dev,
  trong đó $dport_dev là tên của cổng CXL (thường là tên thiết bị PCIe).
  Việc tiêm lỗi nhắm mục tiêu cổng CXL 2.0+ có thể sử dụng giao diện cũ
  trong <điểm gắn kết gỡ lỗi>/apei/einj, trong khi chèn cổng CXL 1.1/1.0
  phải sử dụng tập tin này.


Các phiên bản BIOS dựa trên thông số kỹ thuật ACPI 4.0 có các tùy chọn hạn chế
trong việc kiểm soát nơi các lỗi được đưa vào. BIOS của bạn có thể hỗ trợ
tiện ích mở rộng (được bật bằng tham số mô-đun param_extension=1 hoặc boot
dòng lệnh einj.param_extension=1). Điều này cho phép địa chỉ và mặt nạ
để việc tiêm bộ nhớ được chỉ định bởi các tệp param1 và param2 trong
apei/einj.

Các phiên bản BIOS dựa trên thông số kỹ thuật ACPI 5.0 có nhiều quyền kiểm soát hơn
mục tiêu tiêm. Đối với các lỗi liên quan đến bộ xử lý (loại 0x1, 0x2
và 0x4), bạn có thể đặt cờ thành 0x3 (param3 cho bit 0 và param1 và
param2 cho bit 1) để bạn có thêm thông tin bổ sung vào lỗi
chữ ký đang được tiêm vào. Dữ liệu thực tế được truyền là::

bộ nhớ_địa chỉ = param1;
	bộ nhớ_address_range = param2;
	apicid = param3;
	pcie_sbdf = param4;

Đối với lỗi bộ nhớ (loại 0x8, 0x10 và 0x20), địa chỉ được đặt bằng cách sử dụng
param1 với mặt nạ trong param2 (0x0 tương đương với tất cả các mặt nạ). Dành cho PCI
lỗi thể hiện (loại 0x40, 0x80 và 0x100) phân đoạn, bus, thiết bị và
hàm được chỉ định bằng param1::

31 24 23 16 15 11 10 8 7 0
	+--------------------------------------------------- +
	Chức năng ZZ0000ZZ bus ZZ0001ZZ ZZ0002ZZ
	+--------------------------------------------------- +

Dù sao thì bạn cũng hiểu rồi, nếu có nghi ngờ, hãy xem mã
trong trình điều khiển/acpi/apei/einj.c.

ACPI 5.0 BIOS cũng có thể cho phép chèn các lỗi cụ thể của nhà cung cấp.
Trong trường hợp này, một tệp có tên nhà cung cấp sẽ chứa thông tin nhận dạng
từ BIOS, hy vọng sẽ cho phép ứng dụng muốn sử dụng
tiện ích mở rộng dành riêng cho nhà cung cấp để cho biết rằng họ đang chạy trên BIOS
hỗ trợ nó. Tất cả tiện ích mở rộng của nhà cung cấp đều có bit 0x80000000 được đặt trong
lỗi_type. Tệp nhà cung cấp_flags kiểm soát việc giải thích param1
và param2 (1 = PROCESSOR, 2 = MEMORY, 4 = PCI). Xem nhà cung cấp BIOS của bạn
tài liệu để biết chi tiết (và mong đợi những thay đổi đối với API này nếu nhà cung cấp
khả năng sáng tạo trong việc sử dụng tính năng này vượt xa sự mong đợi của chúng tôi).


Một ví dụ về lỗi tiêm::

# cd/sys/kernel/debug/apei/einj
  # cat có sẵn_error_type # See những lỗi nào có thể được đưa vào
  Bộ xử lý 0x00000002 Không thể sửa được, không gây tử vong
  Bộ nhớ 0x00000008 có thể sửa được
  Bộ nhớ 0x00000010 Không thể sửa được, không gây tử vong
  # echo 0x12345000 > param1 Địa chỉ bộ nhớ # Set để tiêm
  # echo 0xfffffffffffffff000 > param2 # Mask - bất cứ nơi nào trong trang này
  # echo 0x8 > error_type # Choose lỗi bộ nhớ có thể sửa được
  # echo 1 > error_inject # Inject ngay bây giờ

Ví dụ về lỗi tiêm EINJv2::

# cd/sys/kernel/debug/apei/einj
  # cat có sẵn_error_type # See những lỗi nào có thể được đưa vào
  Bộ xử lý 0x00000002 Không thể sửa được, không gây tử vong
  Bộ nhớ 0x00000008 có thể sửa được
  Bộ nhớ 0x00000010 Không thể sửa được, không gây tử vong
  Lỗi bộ xử lý V2_0x00000001 EINJV2
  Lỗi bộ nhớ V2_0x00000002 EINJV2

# echo 0x12345000 > param1 Địa chỉ bộ nhớ # Set để tiêm
  # echo 0xfffffffffffffff000 > param2 # Range - bất cứ nơi nào trong trang này
  # echo 0x1 > thành phần_id0 ID thiết bị # First
  # echo 0x4 > hội chứng lỗi thành phần_# First
  # echo 0x2 > thành phần_id1 ID thiết bị # Second
  # echo 0x4 > hội chứng lỗi thành phần_# Second
  # echo '' > thành phần_id2 # Mark id2 không hợp lệ để chấm dứt danh sách
  # echo V2_0x2 > error_type Lỗi bộ nhớ # Choose EINJv2
  # echo 0xa > cờ # set cờ để biểu thị EINJv2
  # echo 1 > error_inject # Inject ngay bây giờ

Bạn sẽ thấy một cái gì đó như thế này trong dmesg::

[22715.830801] Cầu nối EDAC MC3: HANDLING MCE MEMORY ERROR
  [22715.834759] EDAC sbridge MC3: CPU 0: Sự kiện kiểm tra máy: 0 Ngân hàng 7: 8c00004000010090
  [22715.834759] Cầu nối EDAC MC3: TSC 0
  [22715.834759] Cầu nối EDAC MC3: ADDR 12345000 EDAC cầu nối MC3: MISC 144780c86
  [22715.834759] Cầu nối EDAC MC3: PROCESSOR 0:306e7 TIME 1422553404 SOCKET 0 APIC 0
  [22716.616173] EDAC MC3: Lỗi đọc bộ nhớ 1 CE trên CPU_SrcID#0_Channel#0_DIMM#0 (kênh:0 khe:0 trang:0x12345 offset:0x0 hạt:32 hội chứng:0x0 - khu vực:DRAM err_code:0001:0090 socket:0 kênh_mask:1 xếp hạng:0)

Ví dụ về việc chèn lỗi CXL với $dport_dev=0000:e0:01.1::

# cd /sys/kernel/debug/cxl/
    # ls
    0000:e0:01.1 0000:0c:00.0
    # cat einj_types # See những lỗi nào có thể được đưa vào
	Giao thức 0x00008000 CXL.mem có thể sửa được
	0x00010000 CXL.mem Giao thức Không thể sửa được, không gây tử vong
	0x00020000 CXL.mem Giao thức Không thể sửa chữa gây tử vong
    # cd 0000:e0:01.1 # Navigate để chuyển sang tiêm vào
    # echo 0x8000 > lỗi einj_inject # Inject

Những lưu ý đặc biệt khi tiêm vào vỏ SGX:

Có thể có tùy chọn thiết lập BIOS riêng để kích hoạt tính năng chèn SGX.

Quá trình tiêm bao gồm việc thiết lập một số bộ điều khiển bộ nhớ đặc biệt
trình kích hoạt sẽ gây ra lỗi trong lần ghi tiếp theo vào mục tiêu
địa chỉ. Nhưng h/w ngăn chặn mọi phần mềm bên ngoài vùng SGX
truy cập các trang kèm theo (thậm chí cả chế độ BIOS SMM).

Trình tự sau đây có thể được sử dụng:
  1) Xác định địa chỉ vật lý của trang kèm theo
  2) Sử dụng chế độ "notrigger=1" để tiêm (điều này sẽ thiết lập
     địa chỉ tiêm, nhưng sẽ không thực sự tiêm)
  3) Vào khu vực
  4) Lưu trữ dữ liệu vào địa chỉ ảo khớp với địa chỉ vật lý từ bước 1
  5) Thực thi CLFLUSH cho địa chỉ ảo đó
  6) Độ trễ quay trong 250ms
  7) Đọc từ địa chỉ ảo. Điều này sẽ gây ra lỗi

Để biết thêm thông tin về EINJ, vui lòng tham khảo thông số kỹ thuật của ACPI
phiên bản 4.0, phần 17.5 và ACPI 5.0, phần 18.6.