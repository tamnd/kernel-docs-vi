.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/devices/arm-vgic.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================================================
Bộ điều khiển ngắt chung ảo ARM v2 (VGIC)
==================================================

Các loại thiết bị được hỗ trợ:

- Bộ điều khiển ngắt chung KVM_DEV_TYPE_ARM_VGIC_V2 ARM v2.0

Chỉ một phiên bản VGIC có thể được khởi tạo thông qua API này hoặc
di sản KVM_CREATE_IRQCHIP API.  VGIC được tạo sẽ đóng vai trò là ngắt VM
bộ điều khiển, yêu cầu các thiết bị trong không gian người dùng được mô phỏng để đưa các ngắt vào
VGIC thay vì trực tiếp vào CPU.

Việc triển khai GICv3 với sự hỗ trợ tương thích phần cứng cho phép tạo một
khách GICv2 thông qua giao diện này.  Để biết thông tin về cách tạo khách GICv3
thiết bị và thiết bị ITS khách, xem arm-vgic-v3.txt.  Không thể
tạo cả thiết bị GICv3 và GICv2 trên cùng một VM.


Nhóm:
  KVM_DEV_ARM_VGIC_GRP_ADDR
   Thuộc tính:

KVM_VGIC_V2_ADDR_TYPE_DIST (rw, 64-bit)
      Địa chỉ cơ sở trong không gian địa chỉ vật lý của khách của nhà phân phối GIC
      đăng ký bản đồ. Chỉ hợp lệ cho KVM_DEV_TYPE_ARM_VGIC_V2.
      Địa chỉ này cần được căn chỉnh 4K và vùng có kích thước 4 KByte.

KVM_VGIC_V2_ADDR_TYPE_CPU (rw, 64-bit)
      Địa chỉ cơ sở trong không gian địa chỉ vật lý của khách của CPU ảo GIC
      ánh xạ đăng ký giao diện. Chỉ hợp lệ cho KVM_DEV_TYPE_ARM_VGIC_V2.
      Địa chỉ này cần được căn chỉnh 4K và vùng có kích thước 8 KByte.

Lỗi:

======= ==================================================================
    -E2BIG Địa chỉ nằm ngoài phạm vi IPA có thể định địa chỉ
    -EINVAL Địa chỉ được căn chỉnh không chính xác
    -EEXIST Địa chỉ đã được cấu hình
    -ENXIO Nhóm hoặc thuộc tính không xác định/không được hỗ trợ cho thiết bị này
             hoặc hỗ trợ phần cứng bị thiếu.
    -EFAULT Con trỏ người dùng không hợp lệ cho attr->addr.
    ======= ==================================================================

KVM_DEV_ARM_VGIC_GRP_DIST_REGS
   Thuộc tính:

Trường attr của kvm_device_attr mã hóa hai giá trị::

bit: ZZ0000ZZ 39 .. 32 ZZ0001ZZ
      giá trị: ZZ0002ZZ vcpu_index ZZ0003ZZ

Tất cả các quy định của nhà phân phối là (rw, 32-bit)

Phần bù có liên quan đến "Địa chỉ cơ sở của nhà phân phối" như được xác định trong
    Thông số GICv2.  Việc lấy hoặc thiết lập một sổ đăng ký như vậy có tác dụng tương tự như
    đọc hoặc ghi thanh ghi trên phần cứng thực tế từ CPU có
    chỉ mục được chỉ định với trường vcpu_index.  Lưu ý rằng hầu hết nhà phân phối
    các trường không được đánh dấu vào ngân hàng nhưng trả về cùng một giá trị bất kể
    vcpu_index dùng để truy cập vào thanh ghi.

GICD_IIDR.Revision được cập nhật khi triển khai KVM của một phiên bản mô phỏng
    GICv2 được thay đổi theo cách mà khách hoặc không gian người dùng có thể quan sát trực tiếp.
    Vùng người dùng nên đọc GICD_IIDR từ KVM và ghi lại giá trị đã đọc vào
    xác nhận hành vi dự kiến của nó phù hợp với việc triển khai KVM.
    Không gian người dùng nên đặt GICD_IIDR trước khi đặt bất kỳ thanh ghi nào khác (cả hai
    KVM_DEV_ARM_VGIC_GRP_DIST_REGS và KVM_DEV_ARM_VGIC_GRP_CPU_REGS) để đảm bảo
    hành vi mong đợi. Trừ khi GICD_IIDR đã được đặt từ không gian người dùng, hãy ghi
    đến các thanh ghi nhóm ngắt (GICD_IGROUPR) đều bị bỏ qua.

Lỗi:

======= ==========================================================
    -ENXIO Việc lấy hoặc thiết lập thanh ghi này chưa được hỗ trợ
    -EBUSY Một hoặc nhiều VCPU đang chạy
    -EINVAL Cung cấp vcpu_index không hợp lệ
    ======= ==========================================================

KVM_DEV_ARM_VGIC_GRP_CPU_REGS
   Thuộc tính:

Trường attr của kvm_device_attr mã hóa hai giá trị::

bit: ZZ0000ZZ 39 .. 32 ZZ0001ZZ
      giá trị: ZZ0002ZZ vcpu_index ZZ0003ZZ

Tất cả các quy định giao diện CPU là (rw, 32-bit)

Phần bù chỉ định phần bù từ "địa chỉ cơ sở giao diện CPU" là
    được xác định trong thông số kỹ thuật GICv2.  Việc lấy hoặc thiết lập một sổ đăng ký như vậy có
    tác dụng tương tự như đọc hoặc ghi thanh ghi trên phần cứng thực tế.

Các thanh ghi ưu tiên hoạt động APRn được xác định khi triển khai, vì vậy chúng tôi đặt
    định dạng cố định để chúng tôi triển khai phù hợp với mô hình "GICv2
    triển khai mà không có phần mở rộng bảo mật" mà chúng tôi trình bày cho
    khách.  Giao diện này luôn hiển thị bốn thanh ghi APR[0-3] mô tả
    tối đa có thể là 128 cấp độ ưu tiên.  Ngữ nghĩa của sổ đăng ký
    cho biết liệu có bất kỳ ngắt nào ở mức ưu tiên nhất định đang ở trạng thái hoạt động hay không
    trạng thái bằng cách thiết lập bit tương ứng.

Do đó, mức ưu tiên X có một hoặc nhiều ngắt hoạt động khi và chỉ khi:

APRn[X mod 32] == 0b1, trong đó n = X / 32

Các bit dành cho mức độ ưu tiên không xác định là RAZ/WI.

Lưu ý rằng điều này khác với quan điểm của CPU về APR trên phần cứng trong đó
    GIC không có phần mở rộng bảo mật sẽ hiển thị nhóm 0 và nhóm 1 đang hoạt động
    mức độ ưu tiên trong các nhóm đăng ký riêng biệt, trong khi chúng tôi hiển thị chế độ xem kết hợp
    tương tự như GICH_APR của GICv2.

Vì lý do lịch sử và để cung cấp khả năng tương thích ABI với không gian người dùng, chúng tôi
    xuất thanh ghi GICC_PMR theo định dạng GICH_VMCR.VMPriMask
    trường trong 5 bit thấp hơn của một từ, nghĩa là không gian người dùng phải luôn
    sử dụng 5 bit thấp hơn để liên lạc với thiết bị KVM và phải dịch chuyển
    giá trị còn lại 3 vị trí để có được mức mặt nạ ưu tiên thực tế.

Lỗi:

======= ==========================================================
    -ENXIO Việc lấy hoặc thiết lập thanh ghi này chưa được hỗ trợ
    -EBUSY Một hoặc nhiều VCPU đang chạy
    -EINVAL Cung cấp vcpu_index không hợp lệ
    ======= ==========================================================

KVM_DEV_ARM_VGIC_GRP_NR_IRQS
   Thuộc tính:

Một giá trị mô tả số lượng ngắt (SGI, PPI và SPI) cho
    phiên bản GIC này, nằm trong khoảng từ 64 đến 1024, với số gia là 32.

Lỗi:

======= ==================================================================
    -EINVAL Bộ giá trị nằm ngoài phạm vi dự kiến
    -EBUSY Giá trị đã được đặt hoặc GIC đã được khởi tạo
             với các giá trị mặc định.
    ======= ==================================================================

KVM_DEV_ARM_VGIC_GRP_CTRL
   Thuộc tính:

KVM_DEV_ARM_VGIC_CTRL_INIT
      yêu cầu khởi tạo VGIC hoặc ITS, không có tham số bổ sung
      trong kvm_device_attr.addr.

Lỗi:

======= ===============================================================
    -ENXIO VGIC không được cấu hình đúng theo yêu cầu trước khi gọi
             thuộc tính này
    -ENODEV không có VCPU trực tuyến
    -ENOMEM thiếu bộ nhớ khi cấp phát dữ liệu nội bộ vgic
    ======= ===============================================================