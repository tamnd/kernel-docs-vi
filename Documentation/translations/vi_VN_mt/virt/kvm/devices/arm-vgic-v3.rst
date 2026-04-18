.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/devices/arm-vgic-v3.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===================================================================
Bộ điều khiển ngắt chung ảo ARM v3 trở lên (VGICv3)
==============================================================


Các loại thiết bị được hỗ trợ:
  - Bộ điều khiển ngắt chung KVM_DEV_TYPE_ARM_VGIC_V3 ARM v3.0

Chỉ một phiên bản VGIC có thể được khởi tạo thông qua API này.  VGIC đã tạo
sẽ hoạt động như bộ điều khiển ngắt VM, yêu cầu các thiết bị trong không gian người dùng được mô phỏng
để đưa các ngắt vào VGIC thay vì trực tiếp vào CPU.  Nó không phải
có thể tạo cả GICv3 và GICv2 trên cùng một VM.

Tạo thiết bị GICv3 khách yêu cầu máy chủ GICv3 hoặc máy chủ GICv5 có
hỗ trợ cho FEAT_GCIE_LEGACY.


Nhóm:
  KVM_DEV_ARM_VGIC_GRP_ADDR
   Thuộc tính:

KVM_VGIC_V3_ADDR_TYPE_DIST (rw, 64-bit)
      Địa chỉ cơ sở trong không gian địa chỉ vật lý của khách của nhà phân phối GICv3
      đăng ký bản đồ. Chỉ hợp lệ cho KVM_DEV_TYPE_ARM_VGIC_V3.
      Địa chỉ này cần được căn chỉnh 64K và vùng bao phủ 64 KByte.

KVM_VGIC_V3_ADDR_TYPE_REDIST (rw, 64-bit)
      Địa chỉ cơ sở trong không gian địa chỉ vật lý của khách của GICv3
      ánh xạ đăng ký nhà phân phối lại. Có hai trang 64K cho mỗi trang
      VCPU và tất cả các trang của nhà phân phối lại đều liền kề nhau.
      Chỉ hợp lệ cho KVM_DEV_TYPE_ARM_VGIC_V3.
      Địa chỉ này cần được căn chỉnh 64K.

KVM_VGIC_V3_ADDR_TYPE_REDIST_REGION (rw, 64-bit)
      Dữ liệu thuộc tính được trỏ đến bởi kvm_device_attr.addr là giá trị __u64::

bit: ZZ0000ZZ 51 .... 16 ZZ0001ZZ11 - 0
        giá trị: Chỉ số ZZ0003ZZ cơ sở ZZ0002ZZ

- chỉ mục mã hóa chỉ mục khu vực nhà phân phối lại duy nhất
      - cờ: dành riêng để sử dụng trong tương lai, hiện tại là 0
      - trường cơ sở mã hóa các bit [51:16] của địa chỉ cơ sở vật lý của khách
        là nhà phân phối lại đầu tiên trong khu vực.
      - count mã hóa số lượng nhà phân phối lại trong khu vực. Phải là
        lớn hơn 0.

Có hai trang 64K cho mỗi nhà phân phối lại trong khu vực và
      các nhà phân phối lại được bố trí liền kề trong khu vực. Khu vực
      chứa đầy các nhà phân phối lại theo thứ tự chỉ mục. Tổng của tất cả
      trường số vùng phải lớn hơn hoặc bằng số lượng
      VCPU. Các khu vực phân phối lại phải được đăng ký theo từng bước
      thứ tự chỉ số, bắt đầu từ chỉ số 0.

Các đặc điểm của một khu vực phân phối lại cụ thể có thể được đọc
      bằng cách đặt trước trường chỉ mục trong dữ liệu attr.
      Chỉ hợp lệ cho KVM_DEV_TYPE_ARM_VGIC_V3.

Việc kết hợp các cuộc gọi với KVM_VGIC_V3_ADDR_TYPE_REDIST và
  Thuộc tính KVM_VGIC_V3_ADDR_TYPE_REDIST_REGION.

Lưu ý rằng để có được kết quả có thể lặp lại (cùng VCPU được liên kết
  với cùng một nhà phân phối lại trong quá trình lưu/khôi phục), tạo VCPU
  thứ tự, thứ tự tạo khu vực phân phối lại cũng như các thứ tự tương ứng
  các xen kẽ của VCPU và việc tạo vùng MUST được giữ nguyên.  Bất kỳ thay đổi nào trong
  việc đặt hàng có thể dẫn đến liên kết vcpu_id/redistributor khác,
  dẫn đến máy ảo không chạy được vào thời điểm khôi phục.

Lỗi:

======= ==================================================================
    -E2BIG Địa chỉ nằm ngoài phạm vi IPA có thể định địa chỉ
    -EINVAL Địa chỉ được căn chỉnh không chính xác, vùng phân phối lại không hợp lệ
             số lượng/chỉ mục, sử dụng thuộc tính khu vực phân phối lại hỗn hợp
    -EEXIST Địa chỉ đã được cấu hình
    -ENOENT Cố gắng đọc các đặc điểm của một thứ không tồn tại
             vùng phân phối lại
    -ENXIO Nhóm hoặc thuộc tính không xác định/không được hỗ trợ cho thiết bị này
             hoặc hỗ trợ phần cứng bị thiếu.
    -EFAULT Con trỏ người dùng không hợp lệ cho attr->addr.
    -EBUSY Cố gắng ghi một thanh ghi ở chế độ chỉ đọc sau
             khởi tạo
    ======= ==================================================================


KVM_DEV_ARM_VGIC_GRP_DIST_REGS, KVM_DEV_ARM_VGIC_GRP_REDIST_REGS
   Thuộc tính:

Trường attr của kvm_device_attr mã hóa hai giá trị::

bit: ZZ0000ZZ 31 .... 0 |
      giá trị: bù ZZ0001ZZ |

Tất cả các quy định của nhà phân phối là (rw, 32-bit) và kvm_device_attr.addr trỏ đến một
    Giá trị __u32.  Các thanh ghi 64-bit phải được truy cập bằng cách truy cập riêng vào
    từ thấp hơn và cao hơn.

Việc ghi vào các thanh ghi chỉ đọc sẽ bị kernel bỏ qua.

KVM_DEV_ARM_VGIC_GRP_DIST_REGS truy cập vào sổ đăng ký nhà phân phối chính.
    KVM_DEV_ARM_VGIC_GRP_REDIST_REGS truy cập vào nhà phân phối lại của CPU
    được chỉ định bởi mpidr.

Phần bù có liên quan đến "[Re]Địa chỉ cơ sở của nhà phân phối" như được xác định
    trong thông số kỹ thuật GICv3/4.  Việc lấy hoặc thiết lập một sổ đăng ký như vậy đều giống nhau
    tác dụng như đọc hoặc ghi thanh ghi trên phần cứng thực, ngoại trừ
    các thanh ghi sau: GICD_STATUSR, GICR_STATUSR, GICD_ISPENDR,
    GICR_ISPENDR0, GICD_ICPENDR và GICR_ICPENDR0.  Các thanh ghi này hoạt động
    khác nhau khi được truy cập qua giao diện này so với
    hành vi được xác định về mặt kiến trúc để cho phép phần mềm có cái nhìn đầy đủ về
    Trạng thái bên trong của VGIC.

Trường mpidr được sử dụng để chỉ định cái nào
    nhà phân phối lại được truy cập.  mpidr bị bỏ qua đối với nhà phân phối.

Mã hóa mpidr dựa trên thông tin ái lực trong
    kiến trúc được xác định MPIDR và trường được mã hóa như sau::

ZZ0000ZZ 55 .... 48 ZZ0001ZZ 39 .... 32 |
      ZZ0002ZZ Aff2 ZZ0003ZZ Aff0 |

Lưu ý rằng các trường nhà phân phối không được đánh dấu vào ngân hàng nhưng trả về cùng một giá trị
    bất kể mpidr được sử dụng để truy cập vào sổ đăng ký.

Không gian người dùng được phép ghi các trường đăng ký sau trước
    khởi tạo VGIC:

* GICD_IIDR.Bản sửa đổi
      * GICD_TYPER2.nASSGIcap

GICD_IIDR.Revision được cập nhật khi việc triển khai KVM được thay đổi trong một
    cách mà khách hoặc không gian người dùng có thể quan sát trực tiếp.  Không gian người dùng nên đọc
    GICD_IIDR từ KVM và ghi lại giá trị đã đọc để xác nhận giá trị mong đợi của nó
    hành vi được liên kết với việc triển khai KVM.  Không gian người dùng nên đặt
    GICD_IIDR trước khi thiết lập bất kỳ thanh ghi nào khác để đảm bảo kết quả mong đợi
    hành vi.


GICD_TYPER2.nASSGIcap cho phép không gian người dùng kiểm soát sự hỗ trợ của SGI
    không có trạng thái hoạt động. Khi tạo VGIC, trường sẽ đặt lại thành
    khả năng tối đa của hệ thống. Không gian người dùng dự kiến ​​sẽ đọc trường
    để xác định (các) giá trị được hỗ trợ trước khi ghi vào trường.


Các thanh ghi GICD_STATUSR và GICR_STATUSR được xác định về mặt kiến trúc như sau:
    rằng việc ghi một bit rõ ràng không có tác dụng gì, trong khi việc ghi với một bit được đặt
    xóa giá trị đó.  Để cho phép không gian người dùng tự do thiết lập các giá trị của hai giá trị này
    các thanh ghi, thiết lập các thuộc tính với độ lệch thanh ghi cho hai thanh ghi này
    các thanh ghi chỉ cần đặt các bit không dành riêng cho giá trị được ghi.


Truy cập (đọc và ghi) vào vùng đăng ký GICD_ISPENDR và
    Các thanh ghi GICR_ISPENDR0 nhận/đặt giá trị của trạng thái chờ chốt cho
    các ngắt.

Giá trị này giống hệt với giá trị được khách đọc từ ISPENDR trả về cho một
    ngắt kích hoạt cạnh, nhưng có thể khác nhau đối với các ngắt kích hoạt cấp độ.
    Đối với các ngắt được kích hoạt ở biên, khi một ngắt chuyển sang trạng thái chờ xử lý (cho dù
    do phát hiện thấy cạnh trên dòng đầu vào hoặc do khách ghi
    tới ISPENDR) trạng thái này được "chốt" và chỉ bị xóa khi
    ngắt được kích hoạt hoặc khi khách ghi vào ICPENDR. Một cấp độ
    ngắt được kích hoạt có thể đang chờ xử lý vì đầu vào mức được giữ
    cao bởi một thiết bị hoặc do khách ghi vào thanh ghi ISPENDR. Chỉ
    Việc ghi ISPENDR đã được chốt; nếu thiết bị hạ thấp mức đường truyền thì
    ngắt không còn chờ xử lý trừ khi khách cũng viết thư tới ISPENDR và
    ngược lại ghi vào ICPENDR hoặc kích hoạt ngắt không rõ ràng
    trạng thái chờ xử lý nếu mức dòng vẫn được giữ ở mức cao.  (Những
    các quy tắc được ghi lại trong mô tả thông số kỹ thuật GICv3 của ICPENDR
    và các thanh ghi ISPENDR.) Đối với một mức được kích hoạt, ngắt giá trị được truy cập
    đây là chốt được thiết lập bởi ISPENDR và bị xóa bởi ICPENDR hoặc
    kích hoạt ngắt, trong khi giá trị được trả về bởi khách đọc từ
    ISPENDR là OR logic của giá trị chốt và mức dòng đầu vào.

Quyền truy cập thô vào trạng thái chốt được cung cấp cho không gian người dùng để nó có thể lưu
    và khôi phục toàn bộ trạng thái bên trong GIC (được xác định bởi
    sự kết hợp giữa mức dòng đầu vào hiện tại và trạng thái chốt và không thể
    được suy ra hoàn toàn từ cấp độ dòng và giá trị của ISPENDR
    sổ đăng ký).

Quyền truy cập vào vùng thanh ghi GICD_ICPENDR và thanh ghi GICR_ICPENDR0 có
    Ngữ nghĩa RAZ/WI, nghĩa là các lần đọc luôn trả về 0 và các lần ghi luôn trả về 0
    bị phớt lờ.

Lỗi:

====== ==========================================================
    -ENXIO Việc lấy hoặc thiết lập thanh ghi này chưa được hỗ trợ
    -EBUSY Một hoặc nhiều VCPU đang chạy
    ====== ==========================================================


KVM_DEV_ARM_VGIC_GRP_CPU_SYSREGS
   Thuộc tính:

Trường attr của kvm_device_attr mã hóa hai giá trị::

bit: ZZ0000ZZ 31 .... 16 ZZ0001ZZ
      giá trị: ZZ0002ZZ RES ZZ0003ZZ

Trường mpidr mã hóa ID CPU dựa trên thông tin về mối quan hệ trong
    kiến trúc được xác định MPIDR và trường được mã hóa như sau::

ZZ0000ZZ 55 .... 48 ZZ0001ZZ 39 .... 32 |
      ZZ0002ZZ Aff2 ZZ0003ZZ Aff0 |

Trường instr mã hóa thanh ghi hệ thống để truy cập dựa trên các trường
    được xác định trong mã hóa tập lệnh A64 để truy cập thanh ghi hệ thống
    (RES có nghĩa là các bit được dành riêng để sử dụng trong tương lai và phải bằng 0)::

ZZ0000ZZ 13 ... 11 ZZ0001ZZ 6 ... 3 ZZ0002ZZ
      ZZ0003ZZ Op1 ZZ0004ZZ CRm ZZ0005ZZ

Tất cả các chế độ hệ thống được truy cập thông qua API này là (rw, 64-bit) và
    kvm_device_attr.addr trỏ đến giá trị __u64.

KVM_DEV_ARM_VGIC_GRP_CPU_SYSREGS truy cập các thanh ghi giao diện CPU cho
    CPU được chỉ định bởi trường mpidr.

Các thanh ghi có sẵn là:

========================================================================
    ICC_PMR_EL1
    ICC_BPR0_EL1
    ICC_AP0R0_EL1
    ICC_AP0R1_EL1 khi máy chủ thực hiện ít nhất 6 bit ưu tiên
    ICC_AP0R2_EL1 khi máy chủ thực hiện 7 bit ưu tiên
    ICC_AP0R3_EL1 khi máy chủ thực hiện 7 bit ưu tiên
    ICC_AP1R0_EL1
    ICC_AP1R1_EL1 khi máy chủ thực hiện ít nhất 6 bit ưu tiên
    ICC_AP1R2_EL1 khi máy chủ thực hiện 7 bit ưu tiên
    ICC_AP1R3_EL1 khi máy chủ thực hiện 7 bit ưu tiên
    ICC_BPR1_EL1
    ICC_CTLR_EL1
    ICC_SRE_EL1
    ICC_IGRPEN0_EL1
    ICC_IGRPEN1_EL1
    ========================================================================

Khi EL2 có sẵn cho khách, các sổ đăng ký này cũng có sẵn:

============== =========================================================
    ICH_AP0R0_EL2
    ICH_AP0R1_EL2 khi máy chủ thực hiện ít nhất 6 bit ưu tiên
    ICH_AP0R2_EL2 khi máy chủ thực hiện 7 bit ưu tiên
    ICH_AP0R3_EL2 khi máy chủ thực hiện 7 bit ưu tiên
    ICH_AP1R0_EL2
    ICH_AP1R1_EL2 khi máy chủ thực hiện ít nhất 6 bit ưu tiên
    ICH_AP1R2_EL2 khi máy chủ thực hiện 7 bit ưu tiên
    ICH_AP1R3_EL2 khi máy chủ thực hiện 7 bit ưu tiên
    ICH_HCR_EL2
    ICC_SRE_EL2
    ICH_VTR_EL2
    ICH_VMCR_EL2
    ICH_LR0_EL2
    ICH_LR1_EL2
    ICH_LR2_EL2
    ICH_LR3_EL2
    ICH_LR4_EL2
    ICH_LR5_EL2
    ICH_LR6_EL2
    ICH_LR7_EL2
    ICH_LR8_EL2
    ICH_LR9_EL2
    ICH_LR10_EL2
    ICH_LR11_EL2
    ICH_LR12_EL2
    ICH_LR13_EL2
    ICH_LR14_EL2
    ICH_LR15_EL2
    ============== =========================================================

Các thanh ghi giao diện CPU chỉ được mô tả bằng AArch64
    mã hóa.

Lỗi:

======= =======================================================
    -ENXIO Nhận hoặc thiết lập thanh ghi này không được hỗ trợ
    -EBUSY VCPU đang chạy
    -EINVAL Giá trị đăng ký hoặc mpidr không hợp lệ được cung cấp
    ======= =======================================================


KVM_DEV_ARM_VGIC_GRP_NR_IRQS
   Thuộc tính:

Một giá trị mô tả số lượng ngắt (SGI, PPI và SPI) cho
    phiên bản GIC này, nằm trong khoảng từ 64 đến 1024, với số gia là 32.

kvm_device_attr.addr trỏ đến giá trị __u32.

Lỗi:

======= ==========================================
    -EINVAL Bộ giá trị nằm ngoài phạm vi dự kiến
    -EBUSY Giá trị đã được đặt.
    ======= ==========================================


KVM_DEV_ARM_VGIC_GRP_CTRL
   Thuộc tính:

KVM_DEV_ARM_VGIC_CTRL_INIT
      yêu cầu khởi tạo VGIC, không có tham số bổ sung nào trong
      kvm_device_attr.addr. Phải được gọi sau khi tất cả các VCPU đã được tạo.
    KVM_DEV_ARM_VGIC_SAVE_PENDING_TABLES
      lưu tất cả các bit đang chờ xử lý LPI vào các bảng đang chờ xử lý RAM của khách.

KB đầu tiên của bảng đang chờ xử lý không bị thay đổi bởi thao tác này.

Lỗi:

======= ==============================================================
    -ENXIO VGIC không được cấu hình đúng theo yêu cầu trước khi gọi
             thuộc tính này
    -ENODEV không có VCPU trực tuyến
    -ENOMEM thiếu bộ nhớ khi cấp phát dữ liệu nội bộ vgic
    -EFAULT Truy cập ram khách không hợp lệ
    -EBUSY Một hoặc nhiều VCPUS đang chạy
    ======= ==============================================================


KVM_DEV_ARM_VGIC_GRP_LEVEL_INFO
   Thuộc tính:

Trường attr của kvm_device_attr mã hóa các giá trị sau::

bit: ZZ0000ZZ 31 .... 10 ZZ0001ZZ
      giá trị: Thông tin ZZ0002ZZ ZZ0003ZZ

VINTID chỉ định tập hợp IRQ nào được báo cáo.

Trường thông tin chỉ định không gian người dùng thông tin nào muốn nhận hoặc đặt
    sử dụng giao diện này.  Hiện tại chúng tôi hỗ trợ các giá trị thông tin sau:

VGIC_LEVEL_INFO_LINE_LEVEL:
	Nhận/Đặt mức đầu vào của dòng IRQ cho bộ 32 liên tục
	các ngắt được đánh số.

vINTID phải là bội số của 32.

kvm_device_attr.addr trỏ đến giá trị __u32 sẽ chứa
	bitmap trong đó bit được đặt có nghĩa là mức ngắt được xác nhận.

Bit[n] biểu thị trạng thái ngắt vINTID + n.

SGI và bất kỳ ngắt nào có ID cao hơn số lượng ngắt
    được hỗ trợ, sẽ là RAZ/WI.  LPI luôn được kích hoạt ở biên và
    do đó không được hỗ trợ bởi giao diện này.

PPI được báo cáo trên mỗi VCPU như được chỉ định trong trường mpidr và SPI là
    được báo cáo với cùng một giá trị bất kể mpidr được chỉ định.

Trường mpidr mã hóa ID CPU dựa trên thông tin về mối quan hệ trong
    kiến trúc được xác định MPIDR và trường được mã hóa như sau::

ZZ0000ZZ 55 .... 48 ZZ0001ZZ 39 .... 32 |
      ZZ0002ZZ Aff2 ZZ0003ZZ Aff0 |

Lỗi:
    ======= ==================================================
    -EINVAL vINTID không phải là bội số của 32 hoặc trường thông tin là
	     không phải VGIC_LEVEL_INFO_LINE_LEVEL
    ======= ==================================================

KVM_DEV_ARM_VGIC_GRP_MAINT_IRQ
   Thuộc tính:

Trường attr của kvm_device_attr mã hóa các giá trị sau:

bit: ZZ0000ZZ 4 .... 0 |
      giá trị: ZZ0001ZZ vINTID |

VINTID chỉ định ngắt nào được tạo khi vGIC
    phải tạo ra một ngắt bảo trì. Đây phải là PPI.