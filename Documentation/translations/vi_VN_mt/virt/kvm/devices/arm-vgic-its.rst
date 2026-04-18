.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/devices/arm-vgic-its.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================================
Dịch vụ dịch ngắt ảo ARM (ITS)
===============================================

Các loại thiết bị được hỗ trợ:
  Bộ điều khiển dịch vụ dịch ngắt quãng KVM_DEV_TYPE_ARM_VGIC_ITS ARM

ITS cho phép các ngắt MSI(-X) được đưa vào máy khách. Phần mở rộng này là
tùy chọn.  Tạo bộ điều khiển ITS ảo cũng yêu cầu máy chủ GICv3 (xem
arm-vgic-v3.txt), nhưng không phụ thuộc vào việc có bộ điều khiển ITS vật lý.

Có thể có nhiều bộ điều khiển ITS cho mỗi khách, mỗi người trong số họ phải có
một vùng MMIO riêng biệt, không chồng chéo.


Nhóm
======

KVM_DEV_ARM_VGIC_GRP_ADDR
-------------------------

Thuộc tính:
    KVM_VGIC_ITS_ADDR_TYPE (rw, 64-bit)
      Địa chỉ cơ sở trong không gian địa chỉ vật lý của khách của GICv3 ITS
      khung thanh ghi điều khiển.
      Địa chỉ này cần được căn chỉnh 64K và vùng bao phủ 128K.

Lỗi:

======= =======================================================
    -E2BIG Địa chỉ nằm ngoài phạm vi IPA có thể định địa chỉ
    -EINVAL Địa chỉ được căn chỉnh không chính xác
    -EEXIST Địa chỉ đã được cấu hình
    -EFAULT Con trỏ người dùng không hợp lệ cho attr->addr.
    -ENODEV Thuộc tính không chính xác hoặc ITS không được hỗ trợ.
    ======= =======================================================


KVM_DEV_ARM_VGIC_GRP_CTRL
-------------------------

Thuộc tính:
    KVM_DEV_ARM_VGIC_CTRL_INIT
      yêu cầu khởi tạo ITS, không có tham số bổ sung nào trong
      kvm_device_attr.addr.

KVM_DEV_ARM_ITS_CTRL_RESET
      đặt lại ITS, không có tham số bổ sung trong kvm_device_attr.addr.
      Xem phần "Trạng thái đặt lại ITS".

KVM_DEV_ARM_ITS_SAVE_TABLES
      lưu dữ liệu bảng ITS vào RAM khách, tại vị trí được cung cấp
      bởi khách trong sổ đăng ký/mục bảng tương ứng. Nên không gian người dùng
      yêu cầu một hình thức theo dõi bẩn để xác định trang nào được sửa đổi
      trong quá trình lưu, nó sẽ sử dụng bitmap ngay cả khi sử dụng bitmap khác
      cơ chế theo dõi bộ nhớ bị vCPU làm bẩn.

Bố cục của các bảng trong bộ nhớ khách xác định ABI. Các mục
      được trình bày ở định dạng endian nhỏ như được mô tả trong đoạn cuối.

KVM_DEV_ARM_ITS_RESTORE_TABLES
      khôi phục các bảng ITS từ cấu trúc bên trong RAM của khách sang ITS.

GICV3 phải được khôi phục trước ITS và tất cả các thanh ghi ITS nhưng
      GITS_CTLR phải được khôi phục trước khi khôi phục các bảng ITS.

Thanh ghi chỉ đọc GITS_IIDR cũng phải được khôi phục trước
      gọi KVM_DEV_ARM_ITS_RESTORE_TABLES là trường sửa đổi IIDR
      mã hóa bản sửa đổi ABI.

Thứ tự dự kiến khi khôi phục GICv3/ITS được mô tả trong phần
      "Trình tự khôi phục ITS".

Lỗi:

======= ===============================================================
     -ENXIO ITS không được cấu hình đúng theo yêu cầu trước khi cài đặt
             thuộc tính này
    -ENOMEM Thiếu bộ nhớ khi phân bổ dữ liệu nội bộ ITS
    -EINVAL Dữ liệu được khôi phục không nhất quán
    -EFAULT Truy cập ram khách không hợp lệ
    -EBUSY Một hoặc nhiều VCPUS đang chạy
    -EACCES ITS ảo được hỗ trợ bởi GICv4 ITS vật lý và
	     trạng thái không khả dụng nếu không có GICv4.1
    ======= ===============================================================

KVM_DEV_ARM_VGIC_GRP_ITS_REGS
-----------------------------

Thuộc tính:
      Trường attr của kvm_device_attr mã hóa phần bù của
      Thanh ghi ITS, liên quan đến địa chỉ cơ sở khung điều khiển ITS
      (ITS_cơ sở).

kvm_device_attr.addr trỏ đến giá trị __u64 bất kể chiều rộng
      của thanh ghi địa chỉ (32/64 bit). Thanh ghi 64 bit chỉ có thể
      được truy cập với độ dài đầy đủ.

Việc ghi vào các thanh ghi chỉ đọc bị kernel bỏ qua ngoại trừ:

-GITS_CREADR. Nó phải được khôi phục nếu không sẽ có lệnh trong hàng đợi
        sẽ được thực thi lại sau khi khôi phục CWRITER. GITS_CREADR phải
        được khôi phục trước khi khôi phục GITS_CTLR, điều này có khả năng kích hoạt
        ITS. Ngoài ra, nó phải được khôi phục sau GITS_CBASER kể từ khi ghi vào
        GITS_CBASER đặt lại GITS_CREADR.
      -GITS_IIDR. Trường Sửa đổi mã hóa bố cục bảng Bản sửa đổi ABI.
        Trong tương lai, chúng tôi có thể triển khai việc tiêm trực tiếp LPI ảo.
        Điều này sẽ yêu cầu nâng cấp cách bố trí bảng và sự phát triển của
        ABI. GITS_IIDR phải được khôi phục trước khi gọi
        KVM_DEV_ARM_ITS_RESTORE_TABLES.

Đối với các thanh ghi khác, việc nhận hoặc thiết lập một thanh ghi cũng tương tự
      tác dụng như đọc/ghi thanh ghi trên phần cứng thực.

Lỗi:

======= =========================================================
    -ENXIO Offset không tương ứng với bất kỳ thanh ghi được hỗ trợ nào
    -EFAULT Con trỏ người dùng không hợp lệ cho attr->addr
    -EINVAL Offset không được căn chỉnh 64-bit
    -EBUSY một hoặc nhiều VCPUS đang chạy
    ======= =========================================================

Trình tự khôi phục ITS:
---------------------

Phải tuân theo thứ tự sau khi khôi phục GIC, ITS và
Bài tập KVM_IRQFD:

a) khôi phục tất cả bộ nhớ của khách và tạo vcpus
b) khôi phục tất cả các nhà phân phối lại
c) cung cấp địa chỉ cơ sở ITS
   (KVM_DEV_ARM_VGIC_GRP_ADDR)
d) khôi phục ITS theo thứ tự sau:

1. Khôi phục GITS_CBASER
     2. Khôi phục tất cả các thanh ghi ZZ0000ZZ khác, ngoại trừ GITS_CTLR!
     3. Tải dữ liệu bảng ITS (KVM_DEV_ARM_ITS_RESTORE_TABLES)
     4. Khôi phục GITS_CTLR

e) khôi phục các bài tập KVM_IRQFD cho MSI

Sau đó vcpus có thể được bắt đầu.

Bảng ITS ABI REV0:
-------------------

Bản sửa đổi 0 của ABI chỉ hỗ trợ các tính năng của GICv3 ảo và không
 không hỗ trợ GICv4 ảo có hỗ trợ tiêm trực tiếp ảo
 ngắt cho các trình siêu giám sát lồng nhau.

Bảng thiết bị và ITT được lập chỉ mục bởi DeviceID và EventID,
 tương ứng. Bảng bộ sưu tập không được CollectionID lập chỉ mục và
 các mục trong bộ sưu tập được liệt kê không theo thứ tự cụ thể.
 Tất cả các mục là 8 byte.

Mục nhập bảng thiết bị (DTE)::

bit: ZZ0000ZZ 62 ... 49 ZZ0001ZZ 4 ... 0 |
   giá trị: ZZ0002ZZ tiếp theo Kích thước ZZ0003ZZ |

Ở đâu:

- V cho biết mục nhập có hợp lệ hay không. Nếu không, các lĩnh vực khác
   không có ý nghĩa.
 - next: bằng 0 nếu mục này là mục cuối cùng; nếu không thì nó
   tương ứng với phần bù DeviceID cho DTE tiếp theo, được giới hạn bởi
   2^14 -1.
 - ITT_addr khớp với các bit [51:8] của địa chỉ ITT (căn chỉnh 256 Byte).
 - Kích thước chỉ định số bit được hỗ trợ cho EventID,
   trừ một

Mục nhập bảng bộ sưu tập (CTE)::

bit: ZZ0000ZZ 62 .. 52 ZZ0001ZZ 15 ... 0 |
   giá trị: ZZ0002ZZ RES0 ZZ0003ZZ ICID |

Ở đâu:

- V cho biết mục nhập có hợp lệ hay không. Nếu không, các lĩnh vực khác là
   không có ý nghĩa.
 - RES0: trường dành riêng với hành vi Nên-Không-hoặc-Bảo toàn.
 - RDBase là số PE (ngữ nghĩa GICR_TYPER.Processor_Number),
 - ICID là ID bộ sưu tập

Mục dịch ngắt (ITE)::

bit: ZZ0000ZZ 47 ... 16 ZZ0001ZZ
   giá trị: ZZ0002ZZ pINTID ZZ0003ZZ

Ở đâu:

- next: bằng 0 nếu mục này là mục cuối cùng; nếu không thì nó tương ứng
   đến phần bù EventID cho ITE tiếp theo với giới hạn là 2^16 -1.
 - pINTID là ID LPI vật lý; nếu bằng 0 nghĩa là mục nhập không hợp lệ
   và các lĩnh vực khác không có ý nghĩa.
 - ICID là ID bộ sưu tập

Trạng thái đặt lại ITS:
----------------

RESET trả ITS về trạng thái giống như khi được tạo lần đầu tiên và
được khởi tạo. Khi lệnh RESET trả về, những điều sau đây là
đảm bảo:

- ITS không được kích hoạt và không hoạt động
  GITS_CTLR.Enabled = 0 .Quiescent=1
- Không có trạng thái lưu trữ nội bộ
- Không sử dụng bảng thu thập hoặc thiết bị
  GITS_BASER<n>.Hợp lệ = 0
- GITS_CBASER = 0, GITS_CREADR = 0, GITS_CWRITER = 0
- Phiên bản ABI không thay đổi và giữ nguyên một bộ khi ITS
  thiết bị đầu tiên được tạo ra.