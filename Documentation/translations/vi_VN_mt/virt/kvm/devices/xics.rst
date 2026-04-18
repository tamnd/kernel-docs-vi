.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/devices/xics.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Bộ điều khiển ngắt XICS
===========================

Loại thiết bị được hỗ trợ: KVM_DEV_TYPE_XICS

Nhóm:
  1. KVM_DEV_XICS_GRP_SOURCES
       Thuộc tính:

Một cho mỗi nguồn ngắt, được lập chỉ mục theo số nguồn.
  2. KVM_DEV_XICS_GRP_CTRL
       Thuộc tính:

2.1 KVM_DEV_XICS_NR_SERVERS (chỉ ghi)

Kvm_device_attr.addr trỏ đến giá trị __u32 là số lượng
  số máy chủ bị gián đoạn (tức là id vcpu cao nhất có thể cộng với một).

Lỗi:

======= ==============================================
    -EINVAL Giá trị lớn hơn KVM_MAX_VCPU_IDS.
    -EFAULT Con trỏ người dùng không hợp lệ cho attr->addr.
    -EBUSY Một vcpu đã được kết nối với thiết bị.
    ======= ==============================================

Thiết bị này mô phỏng XICS (Bộ điều khiển ngắt eXternal
Thông số kỹ thuật) được xác định trong PAPR.  XICS có một bộ ngắt
nguồn, mỗi nguồn được xác định bằng một số nguồn 20 bit và một tập hợp các
Các thực thể Trình bày Kiểm soát Ngắt (ICP), còn được gọi là "máy chủ",
mỗi liên kết với một CPU ảo.

Các thực thể ICP được tạo bằng cách kích hoạt KVM_CAP_IRQ_ARCH
khả năng cho từng vcpu, chỉ định KVM_CAP_IRQ_XICS trong args[0] và
số máy chủ ngắt (tức là số vcpu từ XICS's
quan điểm) trong args[1] của cấu trúc kvm_enable_cap.  Mỗi ICP có
64 bit trạng thái có thể được đọc và ghi bằng cách sử dụng
KVM_GET_ONE_REG và KVM_SET_ONE_REG ioctls trên vcpu.  64 bit
từ trạng thái có các trường bit sau, bắt đầu từ
phần cuối có ý nghĩa ít nhất của từ:

* Chưa sử dụng, 16 bit

* Ưu tiên ngắt đang chờ xử lý, 8 bit
  Số 0 là mức ưu tiên cao nhất, 255 nghĩa là không có ngắt nào đang chờ xử lý.

* Ưu tiên IPI (ngắt liên bộ xử lý) đang chờ xử lý, 8 bit
  Số 0 là mức ưu tiên cao nhất, 255 nghĩa là không có IPI nào đang chờ xử lý.

* Số nguồn ngắt đang chờ xử lý, 24 bit
  0 nghĩa là không có ngắt nào đang chờ xử lý, 2 nghĩa là IPI đang chờ xử lý

* Ưu tiên bộ xử lý hiện tại, 8 bit
  Zero là mức ưu tiên cao nhất, nghĩa là không thể ngắt
  được phân phối và 255 là mức ưu tiên thấp nhất.

Mỗi nguồn có 64 bit trạng thái có thể được đọc và ghi bằng cách sử dụng
các ioctls KVM_GET_DEVICE_ATTR và KVM_SET_DEVICE_ATTR, chỉ định
Nhóm thuộc tính KVM_DEV_XICS_GRP_SOURCES, với số thuộc tính là
số nguồn ngắt.  Từ trạng thái 64 bit có như sau
bitfield, bắt đầu từ phần cuối có ý nghĩa ít nhất của từ:

* Đích (số máy chủ), 32 bit

Điều này chỉ định nơi ngắt sẽ được gửi và
  số máy chủ ngắt được chỉ định cho vcpu đích.

* Ưu tiên, 8 bit

Đây là mức ưu tiên được chỉ định cho nguồn ngắt này, trong đó 0 là
  mức ưu tiên cao nhất và 255 là mức thấp nhất.  Một sự gián đoạn với một
  mức độ ưu tiên 255 sẽ không bao giờ được chuyển giao.

* Cờ nhạy mức, 1 bit

Bit này là 1 đối với nguồn ngắt nhạy cảm với mức hoặc 0 đối với
  nhạy cảm với cạnh (hoặc MSI).

* Cờ bịt mặt, 1 bit

Bit này được đặt thành 1 nếu ngắt bị che (không thể gửi
  bất kể mức độ ưu tiên của nó), ví dụ như bởi ibm,int-off RTAS
  gọi hoặc 0 nếu nó không bị che.

* Cờ chờ xử lý, 1 bit

Bit này là 1 nếu nguồn có ngắt đang chờ xử lý, nếu không thì là 0.

Chỉ có thể tạo một phiên bản XICS cho mỗi VM.