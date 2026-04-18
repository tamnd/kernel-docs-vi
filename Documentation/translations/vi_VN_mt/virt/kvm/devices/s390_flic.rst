.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/devices/s390_flic.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
FLIC (bộ điều khiển ngắt động)
====================================

FLIC xử lý các ngắt nổi (không phải trên mỗi CPU), tức là I/O, dịch vụ và một số
kiểm tra máy bị gián đoạn. Tất cả các ngắt được lưu trữ trong danh sách mỗi vm
đang chờ ngắt. FLIC thực hiện các thao tác trên danh sách này.

Chỉ có một phiên bản FLIC có thể được khởi tạo.

FLIC cung cấp hỗ trợ cho
- thêm các ngắt (KVM_DEV_FLIC_ENQUEUE)
- kiểm tra các ngắt hiện đang chờ xử lý (KVM_FLIC_GET_ALL_IRQS)
- thanh lọc tất cả các ngắt nổi đang chờ xử lý (KVM_DEV_FLIC_CLEAR_IRQS)
- thanh lọc một ngắt I/O nổi đang chờ xử lý (KVM_DEV_FLIC_CLEAR_IO_IRQ)
- bật/tắt các lỗi trang không đồng bộ trong suốt của khách
- đăng ký và sửa đổi các nguồn ngắt bộ điều hợp (KVM_DEV_FLIC_ADAPTER_*)
- sửa đổi trạng thái chế độ AIS (ngăn chặn bộ chuyển đổi) (KVM_DEV_FLIC_AISM)
- ngắt bộ chuyển đổi trên một bộ chuyển đổi được chỉ định (KVM_DEV_FLIC_AIRQ_INJECT)
- nhận/đặt tất cả các trạng thái chế độ AIS (KVM_DEV_FLIC_AISM_ALL)

Nhóm:
  KVM_DEV_FLIC_ENQUEUE
    Chuyển một bộ đệm và độ dài vào kernel sau đó được đưa vào
    danh sách các ngắt đang chờ xử lý.
    attr->addr chứa con trỏ tới bộ đệm và attr->attr chứa
    chiều dài của bộ đệm.
    Định dạng của cấu trúc dữ liệu kvm_s390_irq khi được sao chép từ không gian người dùng
    được định nghĩa trong usr/include/linux/kvm.h.

KVM_DEV_FLIC_GET_ALL_IRQS
    Sao chép tất cả các ngắt động vào bộ đệm do không gian người dùng cung cấp.
    Khi bộ đệm quá nhỏ, nó trả về -ENOMEM, đây là dấu hiệu
    để không gian người dùng thử lại với bộ đệm lớn hơn.

-ENOBUFS được trả về khi việc phân bổ bộ đệm không gian hạt nhân đã hoàn tất
    thất bại.

-EFAULT được trả về khi sao chép dữ liệu vào không gian người dùng không thành công.
    Tất cả các ngắt vẫn đang chờ xử lý, tức là không bị xóa khỏi danh sách
    hiện đang chờ ngắt.
    attr->addr chứa địa chỉ không gian người dùng của bộ đệm mà tất cả
    dữ liệu ngắt sẽ được sao chép.
    attr->attr chứa kích thước của bộ đệm tính bằng byte.

KVM_DEV_FLIC_CLEAR_IRQS
    Chỉ cần xóa tất cả các thành phần khỏi danh sách thả nổi hiện đang chờ xử lý
    ngắt quãng.  Không có ngắt nào được đưa vào khách.

KVM_DEV_FLIC_CLEAR_IO_IRQ
    Xóa một (nếu có) ngắt I/O cho kênh con được xác định bởi
    từ nhận dạng hệ thống con được truyền qua bộ đệm được chỉ định bởi
    attr->addr (địa chỉ) và attr->attr (độ dài).

KVM_DEV_FLIC_APF_ENABLE
    Cho phép lỗi trang không đồng bộ cho khách. Vì vậy, trong trường hợp có lỗi trang lớn
    máy chủ được phép xử lý sự không đồng bộ này và tiếp tục là khách.

-EINVAL được trả về khi được gọi trên FLIC của máy ảo ucontrol.

KVM_DEV_FLIC_APF_DISABLE_WAIT
    Vô hiệu hóa lỗi trang không đồng bộ cho khách và đợi cho đến khi đang chờ xử lý
    lỗi trang không đồng bộ được thực hiện. Điều này là cần thiết để kích hoạt một ngắt hoàn thành
    cho mỗi lần ngắt init trước khi di chuyển danh sách ngắt.

-EINVAL được trả về khi được gọi trên FLIC của máy ảo ucontrol.

KVM_DEV_FLIC_ADAPTER_REGISTER
    Đăng ký nguồn ngắt bộ điều hợp I/O. Cần một kvm_s390_io_adapter
    mô tả bộ chuyển đổi để đăng ký::

cấu trúc kvm_s390_io_adapter {
		__u32 id;
		__u8 isc;
		__u8 có thể đeo mặt nạ;
		__u8 trao đổi;
		__u8 cờ;
	};

id chứa id duy nhất cho bộ điều hợp, là lớp con gián đoạn I/O
   để sử dụng, có thể che được liệu bộ điều hợp này có thể bị che hay không (tắt ngắt),
   hoán đổi xem các chỉ báo có cần được hoán đổi byte hay không và các cờ chứa
   các đặc điểm khác của bộ chuyển đổi.

Các giá trị hiện được xác định cho 'cờ' là:

- KVM_S390_ADAPTER_SUPPRESSIBLE: bộ chuyển đổi tuân theo AIS
     cơ sở (bộ điều hợp-ngắt-ngắt). Cờ này chỉ có hiệu lực nếu
     khả năng AIS được kích hoạt.

Giá trị cờ không xác định sẽ bị bỏ qua.


KVM_DEV_FLIC_ADAPTER_MODIFY
    Sửa đổi các thuộc tính của nguồn ngắt bộ điều hợp I/O hiện có. Mất
    kvm_s390_io_adapter_req chỉ định bộ điều hợp và thao tác::

cấu trúc kvm_s390_io_adapter_req {
		__u32 id;
		__u8 loại;
		__u8 mặt nạ;
		__u16 pad0;
		__u64 địa chỉ;
	};

id chỉ định bộ điều hợp và gõ thao tác. Các hoạt động được hỗ trợ
    là:

KVM_S390_IO_ADAPTER_MASK
      che hoặc vạch mặt bộ chuyển đổi, như được chỉ định trong mặt nạ

KVM_S390_IO_ADAPTER_MAP
      Điều này bây giờ là không hoạt động. Việc lập bản đồ hoàn toàn được thực hiện bằng tuyến đường irq.
    KVM_S390_IO_ADAPTER_UNMAP
      Điều này bây giờ là không hoạt động. Việc lập bản đồ hoàn toàn được thực hiện bằng tuyến đường irq.

KVM_DEV_FLIC_AISM
    sửa đổi chế độ ngăn chặn gián đoạn bộ điều hợp cho một isc nhất định nếu
    Khả năng AIS được kích hoạt. Lấy kvm_s390_ais_req mô tả::

cấu trúc kvm_s390_ais_req {
		__u8 isc;
		Chế độ __u16;
	};

isc chứa lớp con ngắt I/O đích, chế độ mục tiêu
    chế độ ngăn chặn gián đoạn bộ điều hợp. Các chế độ sau đây được
    hiện được hỗ trợ:

- KVM_S390_AIS_MODE_ALL: Chế độ gián đoạn ALL, tức là tiêm airq
      luôn được cho phép;
    - KVM_S390_AIS_MODE_SINGLE: Chế độ gián đoạn SINGLE, tức là airq
      chỉ được phép tiêm một lần và bộ điều hợp sau sẽ bị gián đoạn
      sẽ bị chặn cho đến khi chế độ được đặt lại thành ALL-Interruptions
      hoặc chế độ gián đoạn SINGLE.

KVM_DEV_FLIC_AIRQ_INJECT
    Đưa các ngắt bộ điều hợp vào một bộ điều hợp được chỉ định.
    attr->attr chứa id duy nhất cho bộ điều hợp, cho phép
    kiểm tra và hành động dành riêng cho bộ điều hợp.
    Đối với các bộ điều hợp tuân theo AIS, hãy xử lý việc ngăn chặn tiêm airq cho
    một isc theo chế độ ngăn chặn gián đoạn bộ điều hợp theo điều kiện
    rằng khả năng AIS đã được bật.

KVM_DEV_FLIC_AISM_ALL
    Nhận hoặc đặt chế độ ngăn chặn gián đoạn bộ điều hợp cho tất cả ISC. Mất
    một kvm_s390_ais_all mô tả::

cấu trúc kvm_s390_ais_all {
	       __u8 simm; /* Mặt nạ chế độ gián đoạn đơn */
	       __u8 nimm; /* Mặt nạ chế độ không gián đoạn *
	};

simm chứa mặt nạ Chế độ ngắt đơn cho tất cả các ISC, nimm chứa
    Mặt nạ chế độ không gián đoạn cho tất cả ISC. Mỗi bit trong simm và nimm đều tương ứng
    đến ISC (MSB0 bit 0 đến ISC 0, v.v.). Sự kết hợp giữa simm bit và
    bit nimm trình bày chế độ AIS cho ISC.

KVM_DEV_FLIC_AISM_ALL được biểu thị bằng KVM_CAP_S390_AIS_MIGRATION.

Lưu ý: Ioctls của thiết bị KVM_SET_DEVICE_ATTR/KVM_GET_DEVICE_ATTR được thực thi trên
FLIC với nhóm hoặc thuộc tính không xác định sẽ đưa ra mã lỗi EINVAL (thay vì
ENXIO, như được chỉ định trong tài liệu API). Không thể kết luận được
rằng thao tác FLIC không khả dụng dựa trên mã lỗi do
nỗ lực sử dụng.

.. note:: The KVM_DEV_FLIC_CLEAR_IO_IRQ ioctl will return EINVAL in case a
	  zero schid is specified.