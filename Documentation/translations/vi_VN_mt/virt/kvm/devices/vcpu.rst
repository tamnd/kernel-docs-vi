.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/devices/vcpu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================
Giao diện vcpu chung
======================

"Thiết bị" cpu ảo cũng chấp nhận ioctls KVM_SET_DEVICE_ATTR,
KVM_GET_DEVICE_ATTR và KVM_HAS_DEVICE_ATTR. Giao diện sử dụng cùng một cấu trúc
kvm_device_attr như các thiết bị khác, nhưng nhắm mục tiêu các cài đặt và điều khiển trên toàn VCPU.

Các nhóm và thuộc tính trên mỗi CPU ảo, nếu có, đều có kiến ​​trúc cụ thể.

1. GROUP: KVM_ARM_VCPU_PMU_V3_CTRL
==================================

:Kiến trúc: ARM64

1.1. ATTRIBUTE: KVM_ARM_VCPU_PMU_V3_IRQ
---------------------------------------

:Thông số: trong kvm_device_attr.addr, địa chỉ cho ngắt tràn PMU là một
	     con trỏ tới một int

Trả về:

======= ==============================================================
	 -EBUSY Ngắt tràn PMU đã được đặt
	 -EFAULT Lỗi đọc số ngắt
	 -ENXIO PMUv3 không được hỗ trợ hoặc ngắt tràn không được đặt
		  khi cố gắng để có được nó
	 -ENODEV KVM_ARM_VCPU_PMU_V3 tính năng bị thiếu trong VCPU
	 -EINVAL Số ngắt tràn PMU không hợp lệ được cung cấp hoặc
		  cố gắng đặt số IRQ mà không sử dụng kernel trong
		  irqchip.
	 ======= ==============================================================

Giá trị mô tả ngắt tràn PMUv3 (Bộ giám sát hiệu suất v3)
số cho vcpu này. Ngắt này có thể là PPI hoặc SPI, nhưng ngắt
loại phải giống nhau cho mỗi vcpu. Là PPI, số ngắt giống nhau đối với
tất cả vcpus, trong khi với SPI, nó phải là một số riêng cho mỗi vcpu. cho
Khách dựa trên GICv5, phải sử dụng PPI (23) có kiến trúc.

1.2 ATTRIBUTE: KVM_ARM_VCPU_PMU_V3_INIT
---------------------------------------

:Thông số: không có thông số bổ sung trong kvm_device_attr.addr

Trả về:

======= ===========================================================
	 -EEXIST Số ngắt đã được sử dụng
	 -ENODEV PMUv3 không được hỗ trợ hoặc GIC không được khởi tạo
	 -ENXIO PMUv3 không được hỗ trợ, thiếu tính năng VCPU hoặc bị gián đoạn
		  số chưa được đặt (chỉ dành cho khách không phải GICv5)
	 -EBUSY PMUv3 đã được khởi tạo
	 ======= ===========================================================

Yêu cầu khởi tạo PMUv3.  Nếu sử dụng PMUv3 với kernel trong
triển khai GIC ảo, việc này phải được thực hiện sau khi khởi tạo trong kernel
irqchip.

1.3 ATTRIBUTE: KVM_ARM_VCPU_PMU_V3_FILTER
-----------------------------------------

:Thông số: trong kvm_device_attr.addr địa chỉ của bộ lọc sự kiện PMU là
             con trỏ tới cấu trúc kvm_pmu_event_filter

:Trả về:

======= ===========================================================
	 -ENODEV PMUv3 không được hỗ trợ hoặc GIC không được khởi tạo
	 -ENXIO PMUv3 không được cấu hình đúng hoặc irqchip trong kernel không
	 	  được cấu hình theo yêu cầu trước khi gọi thuộc tính này
	 -EBUSY PMUv3 đã được khởi tạo hoặc VCPU đã chạy
	 -EINVAL Phạm vi bộ lọc không hợp lệ
	 ======= ===========================================================

Yêu cầu cài đặt bộ lọc sự kiện PMU được mô tả như sau::

cấu trúc kvm_pmu_event_filter {
	    __u16 base_event;
	    __u16 không có gì mới;

#define KVM_PMU_EVENT_ALLOW 0
    #define KVM_PMU_EVENT_DENY 1

__u8 hành động;
	    __u8 đệm[3];
    };

Phạm vi bộ lọc được xác định là phạm vi [@base_event, @base_event + @nevents),
cùng với @action (KVM_PMU_EVENT_ALLOW hoặc KVM_PMU_EVENT_DENY). các
phạm vi được đăng ký đầu tiên xác định chính sách chung (ALLOW toàn cầu nếu phạm vi đầu tiên
@action là DENY, DENY toàn cầu nếu @action đầu tiên là ALLOW). Nhiều phạm vi
có thể được lập trình và phải vừa với không gian sự kiện được xác định bởi PMU
kiến trúc (10 bit trên ARMv8.0, 16 bit từ ARMv8.1 trở đi).

Lưu ý: "Hủy" bộ lọc bằng cách đăng ký hành động ngược lại cho cùng một bộ lọc
phạm vi không thay đổi hành động mặc định. Ví dụ: cài đặt ALLOW
bộ lọc cho phạm vi sự kiện [0:10) làm bộ lọc đầu tiên và sau đó áp dụng DENY
hành động cho cùng một phạm vi sẽ khiến toàn bộ phạm vi bị vô hiệu hóa.

Hạn chế: Sự kiện 0 (SW_INCR) không bao giờ được lọc vì nó không tính
sự kiện phần cứng Sự kiện lọc 0x1E (CHAIN) cũng không có tác dụng gì vì nó
nói đúng ra đây không phải là một sự kiện. Có thể lọc bộ đếm chu kỳ
sử dụng sự kiện 0x11 (CPU_CYCLES).

1.4 ATTRIBUTE: KVM_ARM_VCPU_PMU_V3_SET_PMU
------------------------------------------

:Thông số: trong kvm_device_attr.addr địa chỉ của int đại diện cho PMU
             định danh.

:Trả về:

======= =========================================================
	 -EBUSY PMUv3 đã được khởi tạo, VCPU đã chạy hoặc
                  một bộ lọc sự kiện đã được thiết lập
	 -EFAULT Lỗi truy cập mã định danh PMU
	 -ENXIO PMU không tìm thấy
	 -ENODEV PMUv3 không được hỗ trợ hoặc GIC không được khởi tạo
	 -ENOMEM Không thể phân bổ bộ nhớ
	 ======= =========================================================

Yêu cầu VCPU sử dụng phần cứng PMU được chỉ định khi tạo sự kiện khách
nhằm mục đích mô phỏng PMU. Mã định danh PMU có thể được đọc từ "loại"
tệp cho phiên bản PMU mong muốn trong /sys/devices (hoặc, tương đương,
/sys/bus/even_source). Thuộc tính này đặc biệt hữu ích trên các dữ liệu không đồng nhất
các hệ thống có ít nhất hai PMU CPU trên hệ thống. PMU đã được thiết lập
đối với một VCPU sẽ được tất cả các VCPU khác sử dụng. Không thể đặt PMU
nếu bộ lọc sự kiện PMU đã có sẵn.

Lưu ý rằng KVM sẽ không thực hiện bất kỳ nỗ lực nào để chạy VCPU trên CPU vật lý
được liên kết với PMU được chỉ định bởi thuộc tính này. Điều này hoàn toàn được để lại cho
không gian người dùng. Tuy nhiên, việc cố gắng chạy VCPU trên CPU vật lý không được hỗ trợ
bởi PMU sẽ thất bại và KVM_RUN sẽ quay trở lại với
exit_reason = KVM_EXIT_FAIL_ENTRY và điền cấu trúc failed_entry bằng cách cài đặt
trường hardare_entry_failure_reason thành KVM_EXIT_FAIL_ENTRY_CPU_UNSUPPORTED và
trường cpu vào id bộ xử lý.

1.5 ATTRIBUTE: KVM_ARM_VCPU_PMU_V3_SET_NR_COUNTERS
--------------------------------------------------

:Thông số: trong kvm_device_attr.addr địa chỉ của một int không dấu
	     đại diện cho giá trị tối đa được lấy bởi PMCR_EL0.N

:Trả về:

======= =========================================================
	 -EBUSY PMUv3 đã được khởi tạo, VCPU đã chạy hoặc
                  một bộ lọc sự kiện đã được thiết lập
	 -EFAULT Lỗi truy cập giá trị được trỏ tới bởi addr
	 -ENODEV PMUv3 không được hỗ trợ hoặc GIC không được khởi tạo
	 -EINVAL Không có PMUv3 nào được chọn rõ ràng hoặc giá trị N trong số đó
	 	  phạm vi
	 ======= =========================================================

Đặt số lượng bộ đếm sự kiện được triển khai trong PMU ảo. Cái này
yêu cầu PMU phải được chọn rõ ràng thông qua
KVM_ARM_VCPU_PMU_V3_SET_PMU và sẽ thất bại khi không có PMU nào được
được chọn rõ ràng hoặc số lượng bộ đếm nằm ngoài phạm vi cho
đã chọn PMU. Việc chọn PMU mới sẽ hủy tác dụng của cài đặt này
thuộc tính.

2. GROUP: KVM_ARM_VCPU_TIMER_CTRL
=================================

:Kiến trúc: ARM64

2.1. ATTRIBUTES: KVM_ARM_VCPU_TIMER_IRQ_{VTIMER,PTIMER,HVTIMER,HPTIMER}
-----------------------------------------------------------------------

:Thông số: trong kvm_device_attr.addr địa chỉ cho ngắt hẹn giờ là một
	     con trỏ tới một int

Trả về:

======= ====================================
	 -EINVAL Số ngắt hẹn giờ không hợp lệ
	 -EBUSY Một hoặc nhiều VCPU đã chạy
	 ======= ====================================

Một giá trị mô tả số ngắt của bộ định thời được kiến trúc khi được kết nối với một
GIC ảo trong kernel.  Đây phải là PPI (16 <= intid < 32).  Thiết lập
thuộc tính ghi đè các giá trị mặc định (xem bên dưới).

=============================================================================
KVM_ARM_VCPU_TIMER_IRQ_VTIMER Intid bộ hẹn giờ ảo EL1 (mặc định: 27)
KVM_ARM_VCPU_TIMER_IRQ_PTIMER Intid bộ đếm thời gian vật lý EL1 (mặc định: 30)
KVM_ARM_VCPU_TIMER_IRQ_HVTIMER Intid bộ hẹn giờ ảo EL2 (mặc định: 28)
KVM_ARM_VCPU_TIMER_IRQ_HPTIMER Intid bộ đếm thời gian vật lý EL2 (mặc định: 26)
=============================================================================

Việc đặt cùng một PPI cho các bộ hẹn giờ khác nhau sẽ ngăn các VCPU chạy.
Đặt số ngắt trên VCPU sẽ định cấu hình tất cả các VCPU được tạo tại đó
thời gian để sử dụng số được cung cấp cho một bộ đếm thời gian nhất định, ghi đè bất kỳ số nào trước đó
các giá trị được cấu hình trên các VCPU khác.  Không gian người dùng nên cấu hình ngắt
trên ít nhất một VCPU sau khi tạo tất cả VCPU và trước khi chạy bất kỳ
VCPU.

.. _kvm_arm_vcpu_pvtime_ctrl:

3. GROUP: KVM_ARM_VCPU_PVTIME_CTRL
==================================

:Kiến trúc: ARM64

3.1 ATTRIBUTE: KVM_ARM_VCPU_PVTIME_IPA
--------------------------------------

:Thông số: địa chỉ cơ sở 64-bit

Trả về:

======= ==========================================
	 -ENXIO Thời gian bị đánh cắp không được triển khai
	 -EEXIST Địa chỉ cơ sở đã được đặt cho VCPU này
	 -EINVAL Địa chỉ cơ sở không được căn chỉnh 64 byte
	 ======= ==========================================

Chỉ định địa chỉ cơ sở của cấu trúc thời gian bị đánh cắp cho VCPU này. các
địa chỉ cơ sở phải được căn chỉnh 64 byte và tồn tại trong bộ nhớ khách hợp lệ
khu vực. Xem Tài liệu/virt/kvm/arm/pvtime.rst để biết thêm thông tin
bao gồm cả cách bố trí cấu trúc thời gian bị đánh cắp.

4. GROUP: KVM_VCPU_TSC_CTRL
===========================

:Kiến trúc: x86

4.1 ATTRIBUTE: KVM_VCPU_TSC_OFFSET

:Thông số: Độ lệch TSC không dấu 64-bit

Trả về:

======= ==========================================
	 -EFAULT Lỗi đọc/ghi nội dung được cung cấp
		 địa chỉ tham số.
	 -ENXIO Thuộc tính không được hỗ trợ
	 ======= ==========================================

Chỉ định độ lệch TSC của khách so với TSC của máy chủ. của khách
TSC sau đó được suy ra theo phương trình sau:

guest_tsc = máy chủ_tsc + KVM_VCPU_TSC_OFFSET

Thuộc tính này hữu ích để điều chỉnh TSC của khách khi di chuyển trực tiếp,
để TSC đếm thời gian VM bị tạm dừng. các
sau đây mô tả một thuật toán có thể sử dụng cho mục đích này.

Từ quy trình VMM nguồn:

1. Gọi KVM_GET_CLOCK ioctl để ghi lại máy chủ TSC (tsc_src),
   kvmclock nano giây (guest_src) và máy chủ CLOCK_REALTIME nano giây
   (máy chủ_src).

2. Đọc thuộc tính KVM_VCPU_TSC_OFFSET cho mọi vCPU để ghi lại
   phần bù TSC của khách (ofs_src[i]).

3. Gọi KVM_GET_TSC_KHZ ioctl để ghi lại tần số của
   TSC của khách (tần số).

Từ quy trình VMM đích:

4. Gọi KVM_SET_CLOCK ioctl, cung cấp nano giây nguồn từ
   kvmclock (guest_src) và CLOCK_REALTIME (host_src) tương ứng
   lĩnh vực.  Đảm bảo rằng cờ KVM_CLOCK_REALTIME được đặt trong cài đặt được cung cấp
   cấu trúc.

KVM sẽ nâng cao kvmclock của VM để tính thời gian đã trôi qua kể từ
   ghi lại các giá trị đồng hồ.  Lưu ý rằng điều này sẽ gây ra vấn đề trong
   khách (ví dụ: hết thời gian chờ) trừ khi CLOCK_REALTIME được đồng bộ hóa
   giữa nguồn và đích, và thời gian trôi qua khá ngắn
   giữa nguồn tạm dừng máy ảo và đích thực thi
   bước 4-7.

5. Gọi KVM_GET_CLOCK ioctl để ghi lại máy chủ TSC (tsc_dest) và
   kvmclock nano giây (guest_dest).

6. Điều chỉnh độ lệch TSC khách cho mỗi vCPU để chiếm (1) thời gian
   đã trôi qua kể từ trạng thái ghi và (2) sự khác biệt về TSC giữa
   máy nguồn và máy đích:

ofs_dst[i] = ofs_src[i] -
     (khách_src - guest_dest) * tần số +
     (tsc_src - tsc_dest)

("ofs[i] + tsc - guest * freq" là giá trị TSC của khách tương ứng với
   thời gian bằng 0 trong kvmclock.  Công thức trên đảm bảo rằng
   ở đích cũng như ở nguồn).

7. Viết thuộc tính KVM_VCPU_TSC_OFFSET cho mọi vCPU bằng
   giá trị tương ứng thu được ở bước trước.