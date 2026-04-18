.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/devices/xive.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================================================
Công cụ ảo hóa ngắt eXternal POWER9 (XIVE Gen1)
===========================================================

Các loại thiết bị được hỗ trợ:
  - Bộ điều khiển ngắt KVM_DEV_TYPE_XIVE POWER9 XIVE thế hệ 1

Thiết bị này hoạt động như một bộ điều khiển ngắt VM. Nó cung cấp KVM
giao diện để cấu hình các nguồn ngắt của máy ảo trong phần cơ bản
Bộ điều khiển ngắt POWER9 XIVE.

Chỉ có một phiên bản XIVE có thể được khởi tạo. Một thiết bị XIVE khách
yêu cầu máy chủ POWER9 và hệ điều hành khách phải hỗ trợ
Chế độ ngắt khai thác gốc XIVE. Nếu không, nó sẽ chạy bằng cách sử dụng
chế độ ngắt kế thừa, được gọi là XICS (POWER7/8).

* Bản đồ thiết bị

Thiết bị KVM hiển thị các phạm vi MMIO khác nhau của XIVE HW
  cần thiết cho việc quản lý ngắt. Những thứ này được tiếp xúc với
  khách trong VMAs được trang bị trình xử lý lỗi VM tùy chỉnh.

1. Khu vực quản lý ngắt luồng (TIMA)

Mỗi luồng có bối cảnh Quản lý ngắt luồng được liên kết
  bao gồm một tập hợp các thanh ghi. Những thanh ghi này cho phép luồng
  xử lý việc quản lý mức độ ưu tiên và xác nhận ngắt. nhất
  quan trọng là:

- Bộ đệm chờ ngắt (IPB)
      - Ưu tiên bộ xử lý hiện tại (CPPR)
      - Đăng ký nguồn thông báo (NSR)

Họ được tiếp xúc với phần mềm ở bốn trang khác nhau, mỗi trang đề xuất
  một chế độ xem với một đặc quyền khác. Trang đầu tiên dành cho
  bối cảnh luồng vật lý và bối cảnh thứ hai cho trình ảo hóa. Chỉ có
  thứ ba (hệ điều hành) và thứ tư (cấp độ người dùng) được tiếp xúc với
  khách.

2. Bộ đệm trạng thái sự kiện (ESB)

Mỗi nguồn được liên kết với Bộ đệm trạng thái sự kiện (ESB) với
  hoặc một cặp trang chẵn/lẻ cung cấp các lệnh để
  quản lý nguồn: kích hoạt, tới EOI, tắt nguồn cho
  ví dụ.

3. Truyền qua thiết bị

Khi một thiết bị được truyền qua máy khách, nguồn
  các ngắt đến từ bộ điều khiển CTNH khác (PHB4) và ESB
  các trang được hiển thị cho khách sẽ thích ứng với sự thay đổi này.

Những người trợ giúp passthru_irq, kvmppc_xive_set_mapped() và
  kvmppc_xive_clr_mapped() được gọi khi có irq CTNH của thiết bị
  được ánh xạ vào hoặc không được ánh xạ từ không gian số IRQ của khách. KVM
  thiết bị mở rộng những trợ giúp này để xóa các trang ESB của khách IRQ
  số được ánh xạ và sau đó cho phép trình xử lý lỗi VM phục hồi lại.
  Trình xử lý sẽ chèn trang ESB tương ứng với HW
  ngắt của thiết bị đang được truyền qua hoặc IPI ESB ban đầu
  trang nếu thiết bị đã được gỡ bỏ.

Ánh xạ lại ESB hoàn toàn minh bạch đối với khách và hệ điều hành
  trình điều khiển thiết bị. Tất cả việc xử lý được thực hiện trong VFIO trở lên
  người trợ giúp trong KVM-PPC.

* Nhóm:

1. KVM_DEV_XIVE_GRP_CTRL
     Cung cấp các điều khiển toàn cầu trên thiết bị

Thuộc tính:
    1.1 KVM_DEV_XIVE_RESET (chỉ ghi)
    Đặt lại cấu hình bộ điều khiển ngắt cho nguồn và sự kiện
    hàng đợi. Được sử dụng bởi kexec và kdump.

Lỗi: không có

1.2 KVM_DEV_XIVE_EQ_SYNC (chỉ ghi)
    Đồng bộ hóa tất cả các nguồn và hàng đợi và đánh dấu các trang EQ bị bẩn. Cái này
    để đảm bảo rằng trạng thái bộ nhớ nhất quán được ghi lại khi
    di chuyển VM.

Lỗi: không có

1.3 KVM_DEV_XIVE_NR_SERVERS (chỉ ghi)
    Kvm_device_attr.addr trỏ đến giá trị __u32 là số lượng
    số máy chủ bị gián đoạn (tức là id vcpu cao nhất có thể cộng với một).

Lỗi:

======= ==============================================
      -EINVAL Giá trị lớn hơn KVM_MAX_VCPU_IDS.
      -EFAULT Con trỏ người dùng không hợp lệ cho attr->addr.
      -EBUSY Một vCPU đã được kết nối với thiết bị.
      ======= ==============================================

2. KVM_DEV_XIVE_GRP_SOURCE (chỉ ghi)
     Khởi tạo một nguồn mới trong thiết bị XIVE và che giấu nó.

Thuộc tính:
    Số nguồn ngắt (64-bit)

Kvm_device_attr.addr trỏ đến giá trị __u64::

bit: ZZ0000ZZ 1 |   0
    giá trị: Mức ZZ0001ZZ | kiểu

- loại: 0:MSI 1:LSI
  - cấp độ: cấp độ xác nhận trong trường hợp LSI.

Lỗi:

======= ==============================================
    -E2BIG Số nguồn ngắt nằm ngoài phạm vi
    -ENOMEM Không thể tạo khối nguồn mới
    -EFAULT Con trỏ người dùng không hợp lệ cho attr->addr.
    -ENXIO Không thể phân bổ ngắt CTNH cơ bản
    ======= ==============================================

3. KVM_DEV_XIVE_GRP_SOURCE_CONFIG (chỉ ghi)
     Định cấu hình nhắm mục tiêu nguồn

Thuộc tính:
    Số nguồn ngắt (64-bit)

Kvm_device_attr.addr trỏ đến giá trị __u64::

bit: ZZ0000ZZ 32 ZZ0001ZZ 2 .. 0
    giá trị: Ưu tiên mặt nạ ZZ0002ZZ ZZ0003ZZ

- mức độ ưu tiên: mức ưu tiên ngắt 0-7
  - máy chủ: Số CPU được chọn để xử lý ngắt
  - mặt nạ: cờ mặt nạ (không sử dụng)
  - eisn: Số nguồn ngắt hiệu quả

Lỗi:

======= =============================================================
    -ENOENT Số nguồn không xác định
    -EINVAL Số nguồn không được khởi tạo
    -EINVAL Ưu tiên không hợp lệ
    -EINVAL Số CPU không hợp lệ.
    -EFAULT Con trỏ người dùng không hợp lệ cho attr->addr.
    -ENXIO Hàng đợi sự kiện CPU không được định cấu hình hoặc cấu hình của
	     ngắt CTNH cơ bản không thành công
    -EBUSY Không có CPU để phục vụ ngắt
    ======= =============================================================

4. KVM_DEV_XIVE_GRP_EQ_CONFIG (đọc-ghi)
     Định cấu hình hàng đợi sự kiện của CPU

Thuộc tính:
    Mã định danh mô tả EQ (64-bit)

Mã định danh mô tả EQ là một bộ (máy chủ, mức độ ưu tiên)::

bit: ZZ0000ZZ 31 .. 3 |  2 .. 0
    giá trị: máy chủ ZZ0001ZZ | sự ưu tiên

Kvm_device_attr.addr trỏ tới::

cấu trúc kvm_ppc_xive_eq {
	__u32 cờ;
	__u32 qshift;
	__u64 qaddr;
	__u32 qtoggle;
	__u32 qindex;
	__u8 pad[40];
    };

- flags: cờ xếp hàng
      KVM_XIVE_EQ_ALWAYS_NOTIFY (bắt buộc)
	buộc thông báo mà không sử dụng cơ chế hợp nhất
	được cung cấp bởi ESB XIVE END.
  - qshift: kích thước hàng đợi (lũy thừa 2)
  - qaddr: địa chỉ thực của hàng đợi
  - qtoggle: bit chuyển đổi hàng đợi hiện tại
  - qindex: chỉ mục hàng đợi hiện tại
  - pad: dành riêng cho việc sử dụng sau này

Lỗi:

======= =============================================
    -ENOENT Số CPU không hợp lệ
    -EINVAL Ưu tiên không hợp lệ
    -EINVAL Cờ không hợp lệ
    -EINVAL Kích thước hàng đợi không hợp lệ
    -EINVAL Địa chỉ hàng đợi không hợp lệ
    -EFAULT Con trỏ người dùng không hợp lệ cho attr->addr.
    -EIO Cấu hình của CTNH cơ bản không thành công
    ======= =============================================

5. KVM_DEV_XIVE_GRP_SOURCE_SYNC (chỉ ghi)
     Đồng bộ hóa nguồn để xóa thông báo sự kiện

Thuộc tính:
    Số nguồn ngắt (64-bit)

Lỗi:

======= ================================
    -ENOENT Số nguồn không xác định
    -EINVAL Số nguồn không được khởi tạo
    ======= ================================

* Trạng thái VCPU

IC XIVE duy trì trạng thái ngắt VP trong cấu trúc bên trong
  được gọi là NVT. Khi VP không được gửi đi trên bộ xử lý CTNH
  luồng, cấu trúc này có thể được HW cập nhật nếu VP là mục tiêu
  của một thông báo sự kiện.

Điều quan trọng đối với việc di chuyển là lấy IPB được lưu trong bộ nhớ đệm từ NVT
  vì nó tổng hợp mức độ ưu tiên của các ngắt đang chờ xử lý. Chúng tôi
  nắm bắt thêm một chút để báo cáo thông tin gỡ lỗi.

KVM_REG_PPC_VP_STATE (2 * 64bit)::

bit: ZZ0000ZZ 31 .... 0 |
    giá trị: ZZ0001ZZ TIMA word1 |
    bit: ZZ0002ZZ
    giá trị: ZZ0003ZZ

* Di cư:

Lưu trạng thái của máy ảo bằng chế độ khai thác gốc XIVE
  phải tuân theo một trình tự cụ thể. Khi VM bị dừng:

1. Che giấu tất cả các nguồn (PQ=01) để ngăn chặn dòng sự kiện.

2. Đồng bộ hóa thiết bị XIVE với bộ điều khiển KVM KVM_DEV_XIVE_EQ_SYNC để
  xóa mọi thông báo sự kiện trên chuyến bay và ổn định EQ. Tại
  giai đoạn này, các trang EQ được đánh dấu bẩn để đảm bảo chúng
  được chuyển theo trình tự di chuyển.

3. Nắm bắt trạng thái nhắm mục tiêu nguồn, cấu hình EQ
  và trạng thái của các thanh ghi bối cảnh ngắt luồng.

Khôi phục cũng tương tự:

1. Khôi phục cấu hình EQ. Vì việc nhắm mục tiêu phụ thuộc vào nó.
  2. Khôi phục nhắm mục tiêu
  3. Khôi phục bối cảnh ngắt luồng
  4. Khôi phục trạng thái nguồn
  5. Để vCPU chạy