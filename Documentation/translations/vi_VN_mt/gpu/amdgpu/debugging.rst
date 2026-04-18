.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/gpu/amdgpu/debugging.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
 Gỡ lỗi GPU
=================

Tùy chọn gỡ lỗi chung
=========================

Phần DebugFS cung cấp tài liệu về một số file để hỗ trợ việc gỡ lỗi
sự cố trên GPU.


Gỡ lỗi GPUVM
===============

Để hỗ trợ gỡ lỗi các vấn đề liên quan đến bộ nhớ ảo GPU, trình điều khiển hỗ trợ
số lượng tham số mô-đun tùy chọn:

ZZ0000ZZ - Nếu không phải 0, hãy dừng bộ điều khiển bộ nhớ GPU do lỗi trang GPU.

ZZ0000ZZ - Nếu không phải 0, hãy sử dụng CPU để cập nhật các bảng trang GPU thay vì
GPU.


Giải mã lỗi trang GPUVM
===========================

Nếu bạn thấy lỗi trang GPU trong nhật ký kernel, bạn có thể giải mã nó thành hình
biết điều gì đang xảy ra trong ứng dụng của bạn.  Một lỗi trang trong kernel của bạn
nhật ký có thể trông giống như thế này:

::

[gfxhub0] lỗi trang không thử lại (src_id:0 ring:24 vmid:3 pasid:32777, đối với quy trình glxinfo pid 2424 thread glxinfo:cs0 pid 2425)
   trong trang bắt đầu tại địa chỉ 0x0000800102800000 từ ứng dụng khách IH 0x1b (UTCL2)
 VM_L2_PROTECTION_FAULT_STATUS:0x00301030
 	ID khách hàng UTCL2 bị lỗi: TCP (0x8)
 	MORE_FAULTS: 0x0
 	WALKER_ERROR: 0x0
 	PERMISSION_FAULTS: 0x3
 	MAPPING_ERROR: 0x0
 	RW: 0x0

Đầu tiên bạn có trung tâm bộ nhớ, gfxhub và mmhub.  gfxhub là bộ nhớ
hub được sử dụng cho đồ họa, điện toán và sdma trên một số chip.  mmhub là
trung tâm bộ nhớ được sử dụng cho đa phương tiện và sdma trên một số chip.

Tiếp theo bạn có vmid và pasid.  Nếu vmid bằng 0 thì lỗi này có thể xảy ra
do trình điều khiển kernel hoặc phần sụn gây ra.  Nếu vmid khác 0 thì thông thường là
một lỗi trong ứng dụng của người dùng.  Pasid được sử dụng để liên kết vmid với hệ thống
id quá trình  Nếu quá trình đang hoạt động khi lỗi xảy ra, quá trình
thông tin sẽ được in ra.

Tiếp theo là địa chỉ ảo GPU gây ra lỗi.

ID khách hàng cho biết khối GPU đã gây ra lỗi.
Một số ID khách hàng phổ biến:

- CB/DB: Phần phụ trợ màu sắc/độ sâu của ống đồ họa
- CPF: Giao diện bộ xử lý lệnh
- CPC: Tính toán bộ xử lý lệnh
- CPG: Đồ họa bộ xử lý lệnh
- TCP/SQC/SQG: Trình đổ bóng
- SDMA: Động cơ SDMA
- VCN: Công cụ mã hóa/giải mã video
- JPEG: Động cơ JPEG

PERMISSION_FAULTS mô tả những lỗi đã gặp phải:

- bit 0: PTE không hợp lệ
- bit 1: bit đọc PTE chưa được đặt
- bit 2: bit ghi PTE chưa được đặt
- bit 3: bit thực thi PTE chưa được đặt

Cuối cùng, RW, cho biết quyền truy cập là đọc (0) hay ghi (1).

Trong ví dụ trên, trình đổ bóng (id khách hàng = TCP) đã tạo ra lệnh đọc (RW = 0x0) tới
một trang không hợp lệ (PERMISSION_FAULTS = 0x3) tại địa chỉ ảo GPU
0x0000800102800000.  Sau đó, người dùng có thể kiểm tra mã và tài nguyên đổ bóng của họ
trạng thái mô tả để xác định nguyên nhân gây ra lỗi trang GPU.

UMR
===

ZZ0000ZZ là mục đích chung
Công cụ chẩn đoán và gỡ lỗi GPU.  Xin vui lòng xem ừm
ZZ0001ZZ để biết thêm thông tin
về khả năng của nó.

Gỡ lỗi độ sáng đèn nền
==============================
Độ sáng đèn nền mặc định được dự định sẽ được đặt thông qua chính sách được quảng cáo
bởi phần sụn.  Phần sụn thường sẽ cung cấp các giá trị mặc định khác nhau cho AC hoặc DC.
Hơn nữa, một số phần mềm vùng người dùng sẽ tiết kiệm độ sáng đèn nền trong khi
lần khởi động trước đó và cố gắng khôi phục nó.

Một số chương trình cơ sở cũng hỗ trợ một tính năng gọi là "Đường cong đèn nền tùy chỉnh"
trong đó giá trị đầu vào cho độ sáng được ánh xạ dọc theo nội suy tuyến tính
đường cong của các giá trị độ sáng phù hợp hơn với đặc điểm hiển thị.

Trong trường hợp có vấn đề xảy ra với đèn nền, có sự kiện dấu vết
có thể được kích hoạt khi khởi động để ghi lại mọi yêu cầu thay đổi độ sáng.
Điều này có thể giúp cô lập vấn đề ở đâu. Để kích hoạt sự kiện theo dõi, hãy thêm
dòng lệnh kernel như sau:

tp_printk trace_event=amdgpu_dm:amdgpu_dm_brightness:mod:amdgpu trace_buf_size=1M
