.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/arm/fw-pseudo-registers.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================================
Giao diện giả đăng ký phần sụn ARM
=======================================

KVM xử lý các dịch vụ hypercall theo yêu cầu của khách hàng. Siêu cuộc gọi mới
các dịch vụ thường xuyên được cung cấp bởi thông số kỹ thuật ARM hoặc KVM (như
dịch vụ của nhà cung cấp) nếu chúng có ý nghĩa từ quan điểm ảo hóa.

Điều này có nghĩa là khách khởi động trên hai phiên bản KVM khác nhau có thể quan sát
hai bản sửa đổi "chương trình cơ sở" khác nhau. Điều này có thể gây ra vấn đề nếu một vị khách nhất định
được gắn với một phiên bản cụ thể của dịch vụ hypercall hoặc nếu quá trình di chuyển
khiến một phiên bản khác bất ngờ bị lộ ra ngoài mà người ta không ngờ tới
khách.

Để khắc phục tình trạng này, KVM đưa ra một bộ "chương trình cơ sở
thanh ghi giả" có thể được thao tác bằng GET/SET_ONE_REG
giao diện. Các thanh ghi này có thể được lưu/khôi phục bởi không gian người dùng và được đặt
đến một giá trị thuận tiện theo yêu cầu.

Các thanh ghi sau đây được xác định:

*KVM_REG_ARM_PSCI_VERSION:

KVM triển khai PSCI (Giao diện phối hợp trạng thái nguồn)
  đặc điểm kỹ thuật để cung cấp các dịch vụ như bật/tắt CPU, đặt lại
  và tắt nguồn cho khách.

- Chỉ hợp lệ nếu vcpu có bộ tính năng KVM_ARM_VCPU_PSCI_0_2
    (và do đó đã được khởi tạo)
  - Trả về phiên bản PSCI hiện tại trên GET_ONE_REG (mặc định là
    phiên bản PSCI cao nhất do KVM triển khai và tương thích với v0.2)
  - Cho phép mọi phiên bản PSCI do KVM triển khai và tương thích với
    v0.2 được cài đặt với SET_ONE_REG
  - Ảnh hưởng đến toàn bộ VM (ngay cả khi chế độ xem đăng ký là trên mỗi vcpu)

*KVM_REG_ARM_SMCCC_ARCH_WORKAROUND_1:
    Giữ trạng thái hỗ trợ chương trình cơ sở để giảm thiểu CVE-2017-5715, như
    được KVM cung cấp cho khách thông qua cuộc gọi HVC. Cách giải quyết được mô tả
    dưới SMCCC_ARCH_WORKAROUND_1 trong [1].

Các giá trị được chấp nhận là:

KVM_REG_ARM_SMCCC_ARCH_WORKAROUND_1_NOT_AVAIL:
      KVM không cung cấp
      hỗ trợ phần sụn cho cách giải quyết. Tình trạng giảm nhẹ đối với
      khách chưa biết.
    KVM_REG_ARM_SMCCC_ARCH_WORKAROUND_1_AVAIL:
      Cách giải quyết cuộc gọi HVC là
      có sẵn cho khách và được yêu cầu để giảm thiểu.
    KVM_REG_ARM_SMCCC_ARCH_WORKAROUND_1_NOT_REQUIRED:
      Cách giải quyết cuộc gọi HVC
      có sẵn cho khách nhưng không cần thiết trên VCPU này.

*KVM_REG_ARM_SMCCC_ARCH_WORKAROUND_2:
    Giữ trạng thái hỗ trợ chương trình cơ sở để giảm thiểu CVE-2018-3639, như
    được KVM cung cấp cho khách thông qua cuộc gọi HVC. Cách giải quyết được mô tả
    dưới SMCCC_ARCH_WORKAROUND_2 trong [1]_.

Các giá trị được chấp nhận là:

KVM_REG_ARM_SMCCC_ARCH_WORKAROUND_2_NOT_AVAIL:
      Một cách giải quyết không
      có sẵn. KVM không cung cấp phần mềm hỗ trợ cho giải pháp khắc phục.
    KVM_REG_ARM_SMCCC_ARCH_WORKAROUND_2_UNKNOWN:
      Trạng thái giải pháp là
      không rõ. KVM không cung cấp phần mềm hỗ trợ cho giải pháp khắc phục.
    KVM_REG_ARM_SMCCC_ARCH_WORKAROUND_2_AVAIL:
      Cách giải quyết đã có sẵn,
      và có thể bị vCPU vô hiệu hóa. Nếu
      KVM_REG_ARM_SMCCC_ARCH_WORKAROUND_2_ENABLED được thiết lập, nó hoạt động trong
      vCPU này.
    KVM_REG_ARM_SMCCC_ARCH_WORKAROUND_2_NOT_REQUIRED:
      Giải pháp thay thế luôn hoạt động trên vCPU này hoặc không cần thiết.


Thanh ghi chương trình cơ sở tính năng Bitmap
---------------------------------

Ngược lại với các thanh ghi trên, các thanh ghi sau đây thể hiện
dịch vụ hypercall dưới dạng feature-bitmap tới không gian người dùng. Cái này
bitmap được dịch sang các dịch vụ có sẵn cho khách.
Có một sổ đăng ký được xác định cho mỗi chủ sở hữu cuộc gọi dịch vụ và có thể được truy cập thông qua
Giao diện GET/SET_ONE_REG.

Theo mặc định, các thanh ghi này được đặt với giới hạn trên của các tính năng
được hỗ trợ. Bằng cách này, không gian người dùng có thể khám phá tất cả những gì có thể sử dụng được
dịch vụ hypercall qua GET_ONE_REG. Không gian người dùng có thể ghi lại
bitmap mong muốn trở lại thông qua SET_ONE_REG. Các tính năng dành cho sổ đăng ký
không bị ảnh hưởng, có thể vì không gian người dùng không biết về chúng, sẽ
được tiếp xúc với khách.

Lưu ý rằng KVM sẽ không cho phép không gian người dùng định cấu hình các thanh ghi
nữa sau khi bất kỳ vCPU nào đã chạy ít nhất một lần. Thay vào đó, nó sẽ
trả về -EBUSY.

Thanh ghi bitmap phần sụn giả như sau:

*KVM_REG_ARM_STD_BMAP:
    Kiểm soát bitmap của Cuộc gọi dịch vụ bảo mật tiêu chuẩn ARM.

Các bit sau được chấp nhận:

Bit-0: KVM_REG_ARM_STD_BIT_TRNG_V1_0:
      Bit đại diện cho các dịch vụ được cung cấp theo phiên bản 1.0 của ARM True Random
      Thông số kỹ thuật của Trình tạo số (TRNG), ARM DEN0098.

*KVM_REG_ARM_STD_HYP_BMAP:
    Kiểm soát bitmap của Cuộc gọi dịch vụ ảo hóa tiêu chuẩn ARM.

Các bit sau được chấp nhận:

Bit-0: KVM_REG_ARM_STD_HYP_BIT_PV_TIME:
      Bit đại diện cho dịch vụ Thời gian ảo hóa được biểu thị bằng
      ARM DEN0057A.

*KVM_REG_ARM_VENDOR_HYP_BMAP:
    Kiểm soát bitmap của Cuộc gọi dịch vụ Hypervisor cụ thể của Nhà cung cấp [0-63].

Các bit sau được chấp nhận:

Bit-0: KVM_REG_ARM_VENDOR_HYP_BIT_FUNC_FEAT
      Bit đại diện cho ARM_SMCCC_VENDOR_HYP_KVM_FEATURES_FUNC_ID
      và id hàm ARM_SMCCC_VENDOR_HYP_CALL_UID_FUNC_ID.

Bit-1: KVM_REG_ARM_VENDOR_HYP_BIT_PTP:
      Bit này đại diện cho dịch vụ Giao thức thời gian chính xác KVM.

*KVM_REG_ARM_VENDOR_HYP_BMAP_2:
    Kiểm soát bitmap của Cuộc gọi dịch vụ Hypervisor cụ thể của Nhà cung cấp [64-127].

Các bit sau được chấp nhận:

Bit-0: KVM_REG_ARM_VENDOR_HYP_BIT_DISCOVER_IMPL_VER
      Điều này đại diện cho ARM_SMCCC_VENDOR_HYP_KVM_DISCOVER_IMPL_VER_FUNC_ID
      chức năng-id. Điều này được đặt lại về 0.

Bit-1: KVM_REG_ARM_VENDOR_HYP_BIT_DISCOVER_IMPL_CPUS
      Điều này đại diện cho ARM_SMCCC_VENDOR_HYP_KVM_DISCOVER_IMPL_CPUS_FUNC_ID
      chức năng-id. Điều này được đặt lại về 0.

Lỗi:

======= ==================================================================
    -ENOENT Đã truy cập đăng ký không xác định.
    -EBUSY Cố gắng 'ghi' vào sổ đăng ký sau khi VM khởi động.
    -EINVAL Bitmap không hợp lệ được ghi vào sổ đăng ký.
    ======= ==================================================================

.. [1] https://developer.arm.com/-/media/developer/pdf/ARM_DEN_0070A_Firmware_interfaces_for_mitigating_CVE-2017-5715.pdf