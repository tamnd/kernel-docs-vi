.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/microcode.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================
Trình tải vi mã Linux
==========================

:Tác giả: - Fenghua Yu <fenghua.yu@intel.com>
          - Borislav Petkov <bp@suse.de>
	  - Ashok Raj <ashok.raj@intel.com>

Hạt nhân có cơ sở tải vi mã x86 được cho là
cung cấp các phương thức tải vi mã trong HĐH. Các trường hợp sử dụng tiềm năng là
cập nhật vi mã trên các nền tảng ngoài hỗ trợ Cuối đời OEM,
và cập nhật vi mã trên các hệ thống chạy lâu mà không cần khởi động lại.

Trình tải hỗ trợ ba phương thức tải:

Mã vi tải sớm
====================

Kernel có thể cập nhật microcode rất sớm trong quá trình khởi động. Đang tải
sớm vi mã có thể khắc phục các sự cố CPU trước khi chúng được phát hiện trong quá trình
thời gian khởi động hạt nhân.

Mã vi mô được lưu trữ trong tệp initrd. Trong khi khởi động, nó được đọc từ
nó và được tải vào lõi CPU.

Định dạng của hình ảnh initrd kết hợp là microcode in (không nén)
cpio theo sau là hình ảnh initrd (có thể được nén). các
trình tải phân tích hình ảnh initrd kết hợp trong khi khởi động.

Các tệp vi mã trong không gian tên cpio là:

trên Intel:
  kernel/x86/microcode/GenuineIntel.bin
trên AMD:
  kernel/x86/microcode/AuthenticAMD.bin

Trong quá trình khởi động BSP (Bộ xử lý khởi động) (trước SMP), kernel
quét tệp vi mã trong initrd. Nếu vi mã khớp với
CPU được tìm thấy, nó sẽ được áp dụng trong BSP và sau này trong tất cả các AP
(Bộ xử lý ứng dụng).

Trình tải cũng lưu vi mã phù hợp cho CPU vào bộ nhớ.
Do đó, bản vá vi mã được lưu trong bộ nhớ đệm sẽ được áp dụng khi CPU hoạt động trở lại từ một
trạng thái ngủ.

Đây là một ví dụ thô sơ về cách chuẩn bị initrd bằng microcode (đây là
thường được thực hiện tự động bởi bản phân phối, khi tạo lại
initrd, vì vậy bạn không thực sự phải tự mình làm điều đó. Nó được ghi lại
ở đây chỉ để tham khảo trong tương lai).
::

#!/bin/bash

nếu [ -z "$1" ]; sau đó
      echo "Bạn cần cung cấp file initrd"
      lối ra 1
  fi

INITRD="$1"

DSTDIR=hạt nhân/x86/vi mã
  TMPDIR=/tmp/initrd

rm -rf $TMPDIR

mkdir $TMPDIR
  cd $TMPDIR
  mkdir -p $DSTDIR

nếu [ -d /lib/firmware/AMD-ucode]; sau đó
          cat /lib/firmware/amd-ucode/microcode_amd*.bin > $DSTDIR/AuthenticAMD.bin
  fi

nếu [ -d /lib/firmware/intel-ucode ]; sau đó
          cat /lib/firmware/intel-ucode/* > $DSTDIR/GenuineIntel.bin
  fi

tìm thấy . | cpio -o -H newc >../ucode.cpio
  đĩa ..
  mv $INITRD $INITRD.orig
  cat ucode.cpio $INITRD.orig > $INITRD

rm -rf $TMPDIR


Hệ thống cần cài đặt các gói vi mã vào
/lib/firmware hoặc bạn cần sửa các đường dẫn trên nếu là của bạn
ở một nơi khác và/hoặc bạn đã tải chúng xuống trực tiếp từ bộ xử lý
trang web của nhà cung cấp.

Tải muộn
============

Bạn chỉ cần cài đặt các gói vi mã mà bản phân phối của bạn cung cấp và
chạy::

# echo 1 > /sys/devices/system/cpu/microcode/tải lại

như gốc.

Cơ chế tải tìm kiếm các đốm màu vi mã trong
/lib/firmware/{intel-ucode,amd-ucode}. Cài đặt bản phân phối mặc định
các gói đã đặt chúng ở đó.

Kể từ kernel 5.19, tính năng tải muộn không được bật theo mặc định.

Phương thức /dev/cpu/microcode đã bị xóa trong 5.19.

Tại sao tải trễ lại nguy hiểm?
==============================

Đồng bộ hóa tất cả các CPU
----------------------

Công cụ vi mã nhận bản cập nhật vi mã được chia sẻ
giữa hai luồng logic trong hệ thống SMT. Vì vậy, khi
bản cập nhật được thực thi trên một luồng SMT của lõi, anh chị em
"tự động" nhận được bản cập nhật.

Vì vi mã cũng có thể "mô phỏng" MSR, trong khi cập nhật vi mã
đang được tiến hành thì những MSR mô phỏng đó sẽ tạm thời ngừng tồn tại. Cái này
có thể dẫn đến kết quả không thể đoán trước nếu chuỗi anh chị em SMT xảy ra
đang trong quá trình truy cập vào MSR như vậy. Quan sát thông thường là
việc truy cập MSR như vậy khiến #GPs được nâng lên để báo hiệu rằng trước đó là
không có mặt.

Các MSR biến mất chỉ là một vấn đề phổ biến đang được quan sát thấy.
Bất kỳ hướng dẫn nào khác đang được vá và được thực hiện đồng thời
được thực hiện bởi anh chị em SMT khác, cũng có thể dẫn đến kết quả tương tự,
hành vi không thể đoán trước.

Để loại bỏ trường hợp này, đồng bộ hóa CPU dựa trên stop_machine() đã được thực hiện
được giới thiệu như một cách để đảm bảo rằng tất cả các CPU logic sẽ không thực thi
bất kỳ mã nào nhưng chỉ chờ trong một vòng quay, thăm dò một biến nguyên tử.

Trong khi điều này xử lý các thiết bị hoặc các ngắt bên ngoài, IPI bao gồm
Những cái LVT, chẳng hạn như CMCI, v.v., nó không thể giải quyết các ngắt đặc biệt khác
cái đó không tắt được Đó là Kiểm tra máy (#MC), Quản lý hệ thống
(#ZZ0002ZZ) và các ngắt không thể che giấu (#ZZ0003ZZ).

Kiểm tra máy
--------------

Kiểm tra máy (#MC) không thể che được. Có hai loại MCE.
MCE nghiêm trọng không thể phục hồi và MCE có thể phục hồi. Trong khi không thể phục hồi
lỗi nghiêm trọng, lỗi có thể phục hồi cũng có thể xảy ra trong bối cảnh kernel
cũng bị kernel coi là gây tử vong.

Trên một số máy Intel nhất định, MCE cũng được phát tới tất cả các luồng trong một
hệ thống. Nếu một luồng đang trong quá trình thực thi WRMSR thì MCE sẽ
được thực hiện ở cuối dòng chảy. Dù sao đi nữa, họ sẽ đợi chủ đề
thực hiện wrmsr(0x79) để gặp trong trình xử lý MCE và tắt máy
cuối cùng nếu bất kỳ luồng nào trong hệ thống không đăng ký được
Điểm hẹn MCE.

Để bị hoang tưởng và có hành vi có thể dự đoán được, hệ điều hành có thể chọn đặt
MCG_STATUS.MCIP. Vì MCE có thể là nhiều nhất trong một hệ thống, nếu một
MCE đã được báo hiệu, tình trạng trên sẽ chuyển sang thiết lập lại hệ thống
tự động. Hệ điều hành có thể tắt MCIP khi kết thúc bản cập nhật
cốt lõi.

Ngắt quản lý hệ thống
---------------------------

SMI cũng được phát tới tất cả các CPU trong nền tảng. Cập nhật vi mã
yêu cầu quyền truy cập độc quyền vào lõi trước khi ghi vào MSR 0x79. Vậy nếu
điều đó xảy ra như vậy, một luồng nằm trong luồng WRMSR và luồng thứ 2 có
SMI, luồng đó sẽ bị dừng trong lệnh đầu tiên trong SMI
người xử lý.

Vì luồng phụ bị dừng trong lệnh đầu tiên trong SMI,
có rất ít khả năng nó đang ở giữa quá trình thực thi
một hướng dẫn đang được vá. Plus OS không có cách nào ngăn chặn SMI
đang xảy ra.

Ngắt không thể che dấu
-----------------------

Khi thread0 của lõi đang thực hiện cập nhật vi mã, nếu thread1 được
bị kéo vào NMI, điều đó có thể gây ra hành vi không thể đoán trước do
lý do trên.

Hệ điều hành có thể chọn nhiều phương pháp khác nhau để tránh gặp phải tình huống này.


Vi mã có phù hợp để tải muộn không?
-------------------------------------------

Tải muộn được thực hiện khi hệ thống đã hoạt động và đang chạy đầy đủ
khối lượng công việc thực tế. Hành vi tải muộn phụ thuộc vào bản vá cơ sở
CPU trước khi nâng cấp lên bản vá mới.

Điều này đúng với CPU Intel.

Ví dụ: hãy xem xét CPU có bản vá cấp 1 và bản cập nhật là
bản vá cấp 3.

Giữa patch1 và patch3, patch2 có thể không được dùng nữa
tính năng.

Điều này là không thể chấp nhận được nếu phần mềm thậm chí còn có khả năng sử dụng tính năng đó.
Ví dụ: giả sử MSR_X không còn khả dụng sau khi cập nhật,
truy cập MSR đó sẽ gây ra lỗi #GP.

Về cơ bản không có cách nào để khai báo cập nhật vi mã mới phù hợp
để tải muộn. Đây là một trong những vấn đề gây ra muộn
tải không được bật theo mặc định.

Vi mã tích hợp
=================

Trình tải cũng hỗ trợ tải vi mã dựng sẵn được cung cấp thông qua
phương pháp chương trình cơ sở tích hợp thông thường CONFIG_EXTRA_FIRMWARE. Chỉ có 64-bit thôi
hiện được hỗ trợ.

Đây là một ví dụ::

CONFIG_EXTRA_FIRMWARE="intel-ucode/06-3a-09 amd-ucode/microcode_amd_fam15h.bin"
  CONFIG_EXTRA_FIRMWARE_DIR="/lib/chương trình cơ sở"

Về cơ bản, điều này có nghĩa là bạn có cấu trúc cây sau đây tại địa phương::

/lib/chương trình cơ sở/
  |-- amd-ucode
  ...
ZZ0000ZZ-- microcode_amd_fam15h.bin
  ...
|-- intel-ucode
  ...
ZZ0000ZZ-- 06-3a-09
  ...

để hệ thống xây dựng có thể tìm thấy các tệp đó và tích hợp chúng vào
hình ảnh hạt nhân cuối cùng. Trình tải sớm tìm thấy chúng và áp dụng chúng.

Không cần phải nói, phương pháp này không phải là phương pháp linh hoạt nhất vì nó
yêu cầu xây dựng lại kernel mỗi lần cập nhật vi mã từ CPU
nhà cung cấp có sẵn.