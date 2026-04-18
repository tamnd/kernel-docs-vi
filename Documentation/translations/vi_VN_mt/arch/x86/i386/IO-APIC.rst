.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/i386/IO-APIC.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=======
IO-APIC
=======

:Tác giả: Ingo Molnar <mingo@kernel.org>

Hầu hết (tất cả) bo mạch SMP tương thích Intel-MP đều có cái gọi là 'IO-APIC',
đó là một bộ điều khiển ngắt nâng cao. Nó cho phép chúng tôi định tuyến
ngắt phần cứng đối với nhiều CPU hoặc với các nhóm CPU. Không có
IO-APIC, các ngắt từ phần cứng sẽ chỉ được gửi đến
CPU khởi động hệ điều hành (thường là CPU#0).

Linux hỗ trợ tất cả các biến thể của bo mạch SMP tuân thủ, bao gồm cả những biến thể có
nhiều IO-APIC. Nhiều IO-APIC được sử dụng trong các máy chủ cao cấp để
phân phối thêm tải IRQ.

Có (một số ít) sự cố xảy ra ở một số bo mạch cũ hơn, những lỗi như vậy là
thường được xử lý bằng kernel. Nếu bo mạch SMP tuân thủ MP của bạn có
không khởi động Linux, trước tiên hãy tham khảo kho lưu trữ danh sách gửi thư linux-smp.

Nếu hộp của bạn khởi động tốt với IRQ IO-APIC được bật thì hộp của bạn
/proc/interrupt sẽ trông giống như thế này::

địa ngục:~> cat /proc/ngắt
             CPU0
    0: 1360293 IO-APIC-cạnh hẹn giờ
    Bàn phím cạnh 1:4 IO-APIC
    Tầng 2: 0 XT-PIC
   13: 1 XT-PIC fpu
   14: 1448 IO-APIC-edge ide0
   16: 28232 Ethernet Intel EtherExpress Pro 10/100 cấp độ IO-APIC
   17: 51304 IO-APIC cấp eth0
  NMI: 0
  ERR: 0
  chết tiệt:~>

Một số ngắt vẫn được liệt kê là 'XT PIC', nhưng đây không phải là vấn đề;
không có nguồn IRQ nào quan trọng về hiệu suất.


Trong trường hợp không thể xảy ra là bảng của bạn không tạo ra bảng mp hoạt động,
bạn có thể sử dụng tham số khởi động pirq= để 'xây dựng bằng tay' các mục IRQ. Cái này
Tuy nhiên, điều này không hề tầm thường và không thể tự động hóa được. Một mẫu /etc/lilo.conf
mục nhập::

nối thêm="pirq=15,11,10"

Các con số thực tế phụ thuộc vào hệ thống của bạn, vào thẻ PCI của bạn và vào
Vị trí khe PCI. Thông thường các khe PCI được 'xâu chuỗi' trước khi chúng được
được kết nối với thiết bị định tuyến IRQ của chipset PCI (PIRQ1-4 đến
dòng)::

,-.        ,-.        ,-.        ,-.        ,-.
     PIRQ4 ----ZZ0007ZZ-.    ,-ZZ0008ZZ-.    ,-ZZ0009ZZ-.    ,-ZZ0010ZZ--------ZZ0011ZZ
               ZZ0012ZZ \ / ZZ0013ZZ \ / ZZ0014ZZ \ / ZZ0015ZZ ZZ0016ZZ
     PIRQ3 ----ZZ0017ZZ-. ZZ0000ZZ/---ZZ0018ZZ-. ZZ0001ZZ----ZZ0019ZZ-./ZZ0002ZZ----ZZ0020ZZ--------ZZ0021ZZ
               ZZ0022ZZ /\ ZZ0023ZZ /\ ZZ0024ZZ /\ ZZ0025ZZ ZZ0026ZZ
     PIRQ1 ----ZZ0027ZZ- ZZ0003ZZ----ZZ0028ZZ- ZZ0004ZZ-' ZZ0005ZZ-' ZZ0006ZZ-'

Mỗi thẻ PCI phát ra PCI IRQ, có thể là INTA, INTB, INTC hoặc INTD::

,-.
                         INTD--ZZ0000ZZ
                               ZZ0001ZZ
                         INTC--ZZ0002ZZ
                               ZZ0003ZZ
                         INTB--ZZ0004ZZ
                               ZZ0005ZZ
                         INTA--ZZ0006ZZ
                               `-'

Các IRQ INTA-D PCI này luôn là 'cục bộ trên thẻ', ý nghĩa thực sự của chúng
phụ thuộc vào vị trí của chúng. Nếu bạn nhìn vào sơ đồ nối xích,
một thẻ trong slot4, phát hành INTA IRQ, nó sẽ kết thúc dưới dạng tín hiệu trên PIRQ4 của
chipset PCI. Hầu hết các thẻ đều phát hành INTA, điều này tạo ra sự phân phối tối ưu
giữa các dòng PIRQ. (phân phối nguồn IRQ đúng cách không phải là một
cần thiết, IRQ PCI có thể được chia sẻ theo ý muốn, nhưng nó tốt cho hiệu suất
có các ngắt không được chia sẻ). Slot5 nên được sử dụng cho card màn hình, chúng
không sử dụng các ngắt một cách bình thường, do đó chúng cũng không bị xâu chuỗi.

vì vậy nếu bạn có thẻ SCSI (IRQ11) ở Slot1, thẻ Tulip (IRQ9) ở
Slot2, thì bạn sẽ phải chỉ định dòng pirq= này::

nối thêm="pirq=11,9"

đoạn script sau đây cố gắng tìm ra dòng pirq= mặc định như vậy từ
cấu hình PCI của bạn::

echo -n pirq=; tiếng vang ZZ0000ZZ | sed 's/ /,/g'

lưu ý rằng tập lệnh này sẽ không hoạt động nếu bạn đã bỏ qua một vài vị trí hoặc nếu
board không thực hiện nối chuỗi mặc định. (hoặc IO-APIC có các chân PIRQ
được kết nối theo một cách kỳ lạ nào đó). Ví dụ. nếu trong trường hợp trên bạn có SCSI
thẻ (IRQ11) trong Khe 3 và có Khe 1 trống::

nối thêm="pirq=0,9,11"

[giá trị '0' là 'giữ chỗ' chung, dành riêng cho sản phẩm trống (hoặc phát ra không phải IRQ)
khe cắm.]

Nói chung, luôn có thể tìm ra cài đặt pirq= chính xác, chỉ cần
hoán đổi tất cả các số IRQ một cách chính xác ... tuy nhiên sẽ mất một chút thời gian. Một
dòng pirq “sai” sẽ khiến quá trình khởi động bị treo, hoặc thiết bị
sẽ không hoạt động bình thường (ví dụ: nếu nó được chèn dưới dạng mô-đun).

Nếu bạn có 2 bus PCI thì bạn có thể sử dụng tối đa 8 giá trị pirq, mặc dù như vậy
bảng có xu hướng có một cấu hình tốt.

Hãy chuẩn bị tinh thần rằng có thể bạn sẽ cần một dòng pirq lạ nào đó::

nối thêm="pirq=0,0,0,0,0,0,9,11"

Sử dụng các kỹ thuật thử và sai thông minh để tìm ra dòng pirq chính xác ...

Chúc may mắn và gửi thư tới linux-smp@vger.kernel.org hoặc
linux-kernel@vger.kernel.org nếu bạn gặp bất kỳ vấn đề nào chưa được giải quyết
bằng tài liệu này.
