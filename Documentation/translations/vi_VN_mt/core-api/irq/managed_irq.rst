.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/core-api/irq/managed_irq.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==============================
Ngắt được quản lý bởi mối quan hệ
===========================

Lõi IRQ cung cấp hỗ trợ quản lý các ngắt theo một quy trình cụ thể
Mối quan hệ CPU. Trong hoạt động bình thường, một ngắt được liên kết với một
đặc biệt là CPU. Nếu CPU đó được ngoại tuyến, ngắt sẽ được di chuyển sang
một CPU trực tuyến khác.

Các thiết bị có số lượng lớn vectơ ngắt có thể gây căng thẳng cho vectơ có sẵn
không gian. Ví dụ: một thiết bị NVMe có 128 hàng đợi I/O thường yêu cầu một
ngắt trên mỗi hàng đợi trên các hệ thống có ít nhất 128 CPU. Hai thiết bị như vậy
do đó yêu cầu 256 ngắt. Trên x86, không gian vectơ ngắt là
nổi tiếng là thấp, chỉ cung cấp 256 vectơ cho mỗi CPU và hạt nhân dành một lượng lớn
tập hợp con trong số này, làm giảm thêm số lượng có sẵn cho các ngắt thiết bị.
Trong thực tế đây không phải là vấn đề vì các ngắt được phân bố trên
nhiều CPU nên mỗi CPU chỉ nhận được một số lượng nhỏ vectơ.

Tuy nhiên, trong quá trình tạm dừng hệ thống, tất cả các CPU thứ cấp sẽ được chuyển sang chế độ ngoại tuyến và tất cả
các ngắt được di chuyển sang CPU duy nhất vẫn trực tuyến. Điều này có thể làm cạn kiệt
các vectơ ngắt có sẵn trên CPU đó và khiến hoạt động tạm dừng bị đình chỉ
thất bại.

Các ngắt được quản lý bằng mối quan hệ sẽ giải quyết hạn chế này. Mỗi ngắt được gán
mặt nạ ái lực CPU chỉ định bộ CPU mà trên đó ngắt có thể
được nhắm mục tiêu. Khi CPU trong mặt nạ ngoại tuyến, ngắt sẽ được chuyển sang
CPU tiếp theo trong mặt nạ. Nếu CPU cuối cùng trong mặt nạ ngoại tuyến, ngắt
bị đóng cửa. Trình điều khiển sử dụng các ngắt được quản lý bằng ái lực phải đảm bảo rằng
hàng đợi liên quan được dừng lại trước khi ngắt bị vô hiệu hóa để không
các ngắt tiếp theo được tạo ra. Khi CPU trong mặt nạ ái lực quay trở lại
trực tuyến, ngắt được kích hoạt lại.

Thực hiện
--------------

Thiết bị phải cung cấp các ngắt theo từng phiên bản, chẳng hạn như ngắt theo hàng I/O
cho các thiết bị lưu trữ như NVMe. Trình điều khiển phân bổ các vectơ ngắt bằng
cài đặt mối quan hệ bắt buộc bằng cách sử dụng struct irq_affinity. Đối với thiết bị MSI‑X, điều này
được thực hiện thông qua pci_alloc_irq_vectors_affinity() với cờ PCI_IRQ_AFFINITY
thiết lập.

Dựa trên thông tin về mối quan hệ được cung cấp, lõi IRQ cố gắng truyền bá
ngắt đều trên toàn hệ thống. Mặt nạ ái lực được tính toán trong quá trình
bước phân bổ này, nhưng phép gán IRQ cuối cùng được thực hiện khi
request_irq() được gọi.

CPU bị cô lập
-------------

Mối quan hệ của các ngắt được quản lý được xử lý hoàn toàn trong kernel và không thể
được sửa đổi từ không gian người dùng thông qua giao diện /proc. quản lý_irq
tham số phụ của tùy chọn khởi động isolcpus chỉ định mặt nạ CPU được quản lý
ngắt nên cố gắng tránh. Sự cô lập này là nỗ lực tốt nhất và duy nhất
áp dụng nếu mặt nạ ngắt được gán tự động cũng chứa CPU trực tuyến
bên ngoài mặt nạ tránh né. Nếu mặt nạ được yêu cầu chỉ chứa các CPU bị cô lập,
cài đặt không có hiệu lực.

Các CPU được liệt kê trong mặt nạ tránh vẫn là một phần của mặt nạ ái lực của ngắt.
Điều này có nghĩa là nếu tất cả các CPU không bị cô lập đều ngoại tuyến trong khi các CPU bị cô lập vẫn
trực tuyến, ngắt sẽ được gán cho một trong các CPU bị cô lập.

Các ví dụ sau đây giả sử một hệ thống có 8 CPU.

- Phiên bản QEMU được khởi động bằng "-device virtio-scsi-pci".
  Thiết bị MSI‑X hiển thị 11 ngắt: 3 ngắt "quản lý" và 8 ngắt
  "hàng đợi" bị gián đoạn. Trình điều khiển yêu cầu 8 lần ngắt hàng đợi, mỗi lần ngắt
  liên kết với chính xác một CPU. Nếu CPU đó ngoại tuyến, ngắt sẽ bị tắt
  xuống.

Giả sử ngắt 48 là một trong các ngắt hàng đợi, thông tin sau sẽ xuất hiện ::

/proc/irq/48/effect_affinity_list:7
    /proc/irq/48/smp_affinity_list:7

Điều này chỉ ra rằng ngắt chỉ được phục vụ bởi CPU7. Tắt CPU7
  không di chuyển ngắt sang CPU khác::

/proc/irq/48/effect_affinity_list:0
    /proc/irq/48/smp_affinity_list:7

Điều này có thể được xác minh thông qua giao diện debugfs
  (/sys/kernel/gỡ lỗi/irq/irqs/48). Trường dstate sẽ bao gồm
  IRQD_IRQ_DISABLED, IRQD_IRQ_MASKED và IRQD_MANAGED_SHUTDOWN.

- Một phiên bản QEMU được khởi động với "-device virtio-scsi-pci,num_queues=2"
  và dòng lệnh kernel bao gồm:
  "irqaffinity=0,1 isolcpus=miền,2-7 isolcpus=managed_irq,1-3,5-7".
  Thiết bị MSI‑X hiển thị 5 ngắt: 3 ngắt quản lý và 2 ngắt hàng đợi
  ngắt quãng. Các ngắt quản lý tuân theo cài đặt irqaffinity=. các
  ngắt hàng đợi được trải đều trên các CPU có sẵn::

/proc/irq/47/effect_affinity_list:0
    /proc/irq/47/smp_affinity_list:0-3
    /proc/irq/48/effect_affinity_list:4
    /proc/irq/48/smp_affinity_list:4-7

Hai ngắt hàng đợi được phân bổ đều. Ngắt 48 được đặt trên CPU4
  vì mặt nạ Managed_irq sẽ tránh được CPU 5–7 khi có thể.

Thay thế đối số Managed_irq bằng "isolcpus=managed_irq,1-3,4-5,7"
  kết quả là::

/proc/irq/48/effect_affinity_list:6
    /proc/irq/48/smp_affinity_list:4-7

Ngắt 48 hiện được phục vụ trên CPU6 vì hệ thống tránh CPU 4, 5 và
  7. Nếu CPU6 được ngoại tuyến, ngắt sẽ di chuyển đến một trong các thiết bị "bị cô lập"
  CPU::

/proc/irq/48/effect_affinity_list:7
    /proc/irq/48/smp_affinity_list:4-7

Ngắt sẽ bị tắt khi tất cả các CPU được liệt kê trong mặt nạ smp_affinity của nó được
  ngoại tuyến.