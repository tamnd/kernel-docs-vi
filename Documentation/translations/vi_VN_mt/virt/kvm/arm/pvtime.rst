.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/arm/pvtime.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Hỗ trợ thời gian ảo hóa cho arm64
======================================

Thông số kỹ thuật của cánh tay DEN0057/A xác định tiêu chuẩn cho thời gian ảo hóa song song
hỗ trợ cho khách AArch64:

ZZ0000ZZ

KVM/arm64 thực hiện phần thời gian bị đánh cắp của thông số kỹ thuật này bằng cách cung cấp
một số dịch vụ ảo hóa cuộc gọi để hỗ trợ khách ảo hóa có được
xem lượng thời gian bị đánh cắp từ việc thực hiện nó.

Hai siêu cuộc gọi tương thích SMCCC mới được xác định:

*PV_TIME_FEATURES: 0xC5000020
* PV_TIME_ST: 0xC5000021

Những thứ này chỉ khả dụng trong quy ước gọi SMC64/HVC64 như
thời gian ảo hóa không có sẵn cho khách Arm 32 bit. Sự tồn tại của
siêu cuộc gọi PV_TIME_FEATURES nên được thử nghiệm bằng cách sử dụng SMCCC 1.1
Cơ chế ARCH_FEATURES trước khi gọi nó.

PV_TIME_FEATURES

============== ======== ======================================================
    ID chức năng: (uint32) 0xC5000020
    PV_call_id: (uint32) Hàm truy vấn hỗ trợ.
                              Hiện tại chỉ có PV_TIME_ST được hỗ trợ.
    Giá trị trả về: (int64) NOT_SUPPORTED (-1) hoặc SUCCESS (0) nếu có liên quan
                              Tính năng PV-time được hỗ trợ bởi hypervisor.
    ============== ======== ======================================================

PV_TIME_ST

============== ======== ===================================================
    ID chức năng: (uint32) 0xC5000021
    Giá trị trả về: (int64) IPA của cấu trúc dữ liệu thời gian bị đánh cắp cho việc này
                              VCPU. Khi thất bại:
                              NOT_SUPPORTED (-1)
    ============== ======== ===================================================

IPA được PV_TIME_ST trả về sẽ được khách ánh xạ dưới dạng bộ nhớ bình thường
với các thuộc tính bộ nhớ đệm ghi lại bên trong và bên ngoài, ở bên trong có thể chia sẻ
miền. Tổng cộng 16 byte từ IPA được trả về được đảm bảo là
được lấp đầy một cách có ý nghĩa bởi trình ảo hóa (xem cấu trúc bên dưới).

PV_TIME_ST trả về cấu trúc cho việc gọi VCPU.

Thời gian bị đánh cắp
---------------------

Cấu trúc được chỉ ra bởi siêu lệnh PV_TIME_ST như sau:

+-------------+-------------+-------------+--------------------------+
ZZ0000ZZ Độ dài byte ZZ0001ZZ Mô tả |
+=====================================================================================================================================================
ZZ0002ZZ 4 ZZ0003ZZ Phải là 0 cho phiên bản 1.0 |
+-------------+-------------+-------------+--------------------------+
ZZ0004ZZ 4 ZZ0005ZZ Phải là 0 |
+-------------+-------------+-------------+--------------------------+
ZZ0006ZZ 8 ZZ0007ZZ Bị đánh cắp thời gian không dấu |
ZZ0008ZZ ZZ0009ZZ nano giây cho biết cách thực hiện |
ZZ0010ZZ ZZ0011ZZ dành nhiều thời gian cho chủ đề VCPU này |
ZZ0012ZZ ZZ0013ZZ đã vô tình không |
ZZ0014ZZ ZZ0015ZZ chạy trên CPU vật lý. |
+-------------+-------------+-------------+--------------------------+

Tất cả các giá trị trong cấu trúc được lưu trữ ở dạng endian nhỏ.

Cấu trúc sẽ được trình ảo hóa cập nhật trước khi lên lịch cho VCPU. Nó
sẽ hiện diện trong một vùng dành riêng của bộ nhớ bình thường được cấp cho
khách. Khách không nên cố gắng ghi vào bộ nhớ này. có một
cấu trúc theo VCPU của khách.

Nên dành một hoặc nhiều trang 64k cho mục đích
những cấu trúc này và không được sử dụng cho các mục đích khác, điều này cho phép khách lập bản đồ
vùng sử dụng 64k trang và tránh các thuộc tính xung đột với bộ nhớ khác.

Đối với giao diện không gian người dùng, hãy xem
ZZ0000ZZ.