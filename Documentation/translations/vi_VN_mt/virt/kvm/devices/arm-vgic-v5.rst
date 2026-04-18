.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/devices/arm-vgic-v5.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================================================
Bộ điều khiển ngắt chung ảo ARM v5 (VGICv5)
====================================================


Các loại thiết bị được hỗ trợ:
  - Bộ điều khiển ngắt chung KVM_DEV_TYPE_ARM_VGIC_V5 ARM v5.0

Chỉ một phiên bản VGIC có thể được khởi tạo thông qua API này.  VGIC đã tạo
sẽ hoạt động như bộ điều khiển ngắt VM, yêu cầu các thiết bị trong không gian người dùng được mô phỏng
để đưa các ngắt vào VGIC thay vì trực tiếp vào CPU.

Việc tạo thiết bị GICv5 khách cần có máy chủ lưu trữ GICv5.  VGICv5 hiện tại
thiết bị chỉ hỗ trợ các ngắt PPI.  Chúng có thể được tiêm từ mô phỏng
các thiết bị trong kernel (chẳng hạn như Arch Hẹn giờ hoặc PMU) hoặc thông qua KVM_IRQ_LINE
ioctl.

Nhóm:
  KVM_DEV_ARM_VGIC_GRP_CTRL
   Thuộc tính:

KVM_DEV_ARM_VGIC_CTRL_INIT
      yêu cầu khởi tạo VGIC, không có tham số bổ sung nào trong
      kvm_device_attr.addr. Phải được gọi sau khi tất cả các VCPU đã được tạo.

KVM_DEV_ARM_VGIC_USERPSPACE_PPI
      yêu cầu mặt nạ của PPI có thể điều khiển theo không gian người dùng. Chỉ một tập hợp con của PPI có thể
      được điều khiển trực tiếp từ không gian người dùng bằng GICv5 và mặt nạ được trả về
      thông báo cho người dùng không gian nào được phép lái xe qua KVM_IRQ_LINE.

Không gian người dùng phải phân bổ và trỏ tới __u64[2] dữ liệu trong
      kvm_device_attr.addr. Khi cuộc gọi này quay trở lại, bộ nhớ được cung cấp sẽ
      được gắn với mặt nạ PPI của không gian người dùng. __u64 phía dưới chứa mặt nạ
      đối với 64 PPIS thấp hơn, 64 còn lại nằm ở __u64 thứ hai.

Đây là thuộc tính chỉ đọc và không thể đặt. Những nỗ lực để thiết lập nó là
      bị từ chối.

Lỗi:

======= ==============================================================
    -ENXIO VGIC không được cấu hình đúng theo yêu cầu trước khi gọi
             thuộc tính này
    -ENODEV không có VCPU trực tuyến
    -ENOMEM thiếu bộ nhớ khi cấp phát dữ liệu nội bộ vgic
    -EFAULT Truy cập ram khách không hợp lệ
    -EBUSY Một hoặc nhiều VCPUS đang chạy
    ======= ==============================================================