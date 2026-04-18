.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/gpu/amdgpu/debugfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================
Gỡ lỗi AMDGPUFS
================

Trình điều khiển amdgpu cung cấp một số tệp debugfs để hỗ trợ việc gỡ lỗi
các vấn đề trong trình điều khiển.  Những thứ này thường được tìm thấy ở
/sys/kernel/debug/dri/<num>.

Tệp gỡ lỗiFS
=============

amdgpu_benchmark
----------------

Chạy điểm chuẩn bằng công cụ DMA mà trình điều khiển sử dụng để phân trang bộ nhớ GPU.
Viết một số vào tập tin để chạy thử nghiệm.  Kết quả được ghi vào
nhật ký hạt nhân.  VRAM nằm trên bộ nhớ thiết bị (dGPU) hoặc khắc (APU) và GTT
(Bảng dịch đồ họa) là bộ nhớ hệ thống mà GPU có thể truy cập được.
Các bài kiểm tra sau đây có sẵn:

- 1: thử nghiệm đơn giản, VRAM đến GTT và GTT đến VRAM
- 2: kiểm tra đơn giản, VRAM đến VRAM
- 3: GTT đến VRAM, quét kích thước bộ đệm, lũy thừa 2
- 4: VRAM đến GTT, quét kích thước bộ đệm, lũy thừa 2
- 5: VRAM đến VRAM, quét kích thước bộ đệm, lũy thừa 2
- 6: GTT đến VRAM, quét kích thước bộ đệm, kích thước hiển thị phổ biến
- 7: VRAM đến GTT, quét kích thước bộ đệm, kích thước hiển thị phổ biến
- 8: VRAM đến VRAM, quét kích thước bộ đệm, kích thước hiển thị phổ biến

amdgpu_test_ib
--------------

Đọc tệp này để chạy thử nghiệm IB (Bộ đệm gián tiếp) đơn giản trên tất cả kernel được quản lý
nhẫn.  IB là bộ đệm lệnh thường được tạo bởi các ứng dụng không gian người dùng
được gửi tới kernel để thực thi trên một công cụ GPU cụ thể.
Điều này chỉ chạy các bài kiểm tra IB đơn giản có trong kernel.  Những thử nghiệm này
là công cụ cụ thể và xác minh rằng việc gửi IB hoạt động.

amdgpu_discovery
----------------

Cung cấp quyền truy cập thô vào mã nhị phân khám phá IP do GPU cung cấp.  Đọc cái này
tập tin để truy cập vào tệp nhị phân thô.  Điều này rất hữu ích cho việc xác minh nội dung của
bảng khám phá IP.  Đó là con chip cụ thể.

amdgpu_vbios
------------

Cung cấp quyền truy cập thô vào hình ảnh nhị phân ROM từ GPU.  Đọc tập tin này để
truy cập nhị phân thô.  Điều này rất hữu ích cho việc xác minh nội dung của
video BIOS ROM.  Đó là bảng cụ thể.

amdgpu_evict_gtt
----------------

Xóa tất cả bộ đệm khỏi nhóm bộ nhớ GTT.  Đọc tập tin này để loại bỏ tất cả
bộ đệm từ nhóm này.

amdgpu_evict_vram
-----------------

Xóa tất cả bộ đệm khỏi nhóm bộ nhớ VRAM.  Đọc tập tin này để loại bỏ tất cả
bộ đệm từ nhóm này.

amdgpu_gpu_recover
------------------

Kích hoạt thiết lập lại GPU.  Đọc tệp này để kích hoạt thiết lập lại toàn bộ GPU.
Tất cả công việc hiện đang chạy trên GPU sẽ bị mất.

amdgpu_ring_<tên>
------------------

Cung cấp quyền truy cập đọc vào bộ đệm vòng được quản lý kernel cho mỗi vòng <name>.
Đây là những hữu ích cho việc gỡ lỗi các vấn đề trên một vòng cụ thể.  Bộ đệm vòng
là cách CPU gửi lệnh đến GPU.  CPU ghi lệnh vào
đệm và sau đó yêu cầu công cụ GPU xử lý nó.  Đây là nhị phân thô
nội dung của bộ đệm vòng.  Sử dụng công cụ như UMR để giải mã những chiếc nhẫn thành người
dạng có thể đọc được.

amdgpu_mqd_<tên>
-----------------

Cung cấp quyền truy cập đọc vào MQD (Bộ mô tả hàng đợi bộ nhớ) được quản lý kernel cho
ring <name> được quản lý bởi trình điều khiển kernel.  MQD xác định các tính năng của vòng
và được sử dụng để lưu trữ trạng thái của vòng khi nó không được kết nối với phần cứng.
Trình điều khiển ghi các tính năng vòng và siêu dữ liệu được yêu cầu (địa chỉ GPU của
chính vòng và các bộ đệm liên quan) sang MQD và phần sụn sử dụng MQD
để điền vào phần cứng khi vòng được ánh xạ tới một khe phần cứng.  Chỉ
có sẵn trên các động cơ sử dụng MQD.  Điều này cung cấp quyền truy cập vào MQD thô
nhị phân.

amdgpu_error_<tên>
-------------------

Cung cấp giao diện để đặt mã lỗi trên hàng rào dma được liên kết với
gọi <tên>.  Mã lỗi được chỉ định sẽ được truyền tới tất cả các hàng rào liên quan
với chiếc nhẫn.  Sử dụng điều này để đưa lỗi hàng rào vào vòng.

amdgpu_pm_info
--------------

Cung cấp thông tin có thể đọc được của con người về các tính năng quản lý năng lượng
và trạng thái của GPU.  Điều này bao gồm đồng hồ GFX hiện tại, đồng hồ bộ nhớ,
điện áp, công suất SoC trung bình, nhiệt độ, tải GFX, Tải bộ nhớ, SMU
mặt nạ tính năng, trạng thái nguồn VCN, tính năng đồng hồ và cổng nguồn.

amdgpu_firmware_info
--------------------

Liệt kê các phiên bản chương trình cơ sở cho tất cả các chương trình cơ sở được GPU sử dụng.  Chỉ
các mục có phiên bản khác 0 là hợp lệ.  Nếu phiên bản là 0, phần sụn
không hợp lệ cho GPU.

amdgpu_fence_info
-----------------

Hiển thị số thứ tự hàng rào được tín hiệu và phát ra cuối cùng cho mỗi
vòng quản lý trình điều khiển hạt nhân.  Hàng rào được liên kết với bài nộp
đến động cơ.  Hàng rào phát ra đã được đưa lên võ đài
và hàng rào được báo hiệu đã được báo hiệu bởi GPU.  Nhẫn với một
giá trị hàng rào phát ra lớn hơn có công việc nổi bật vẫn đang được thực hiện
được xử lý bởi động cơ sở hữu vòng đó.  Khi phát ra và
giá trị hàng rào được báo hiệu bằng nhau, vòng ở trạng thái rảnh.

amdgpu_gem_info
---------------

Liệt kê tất cả các PID sử dụng bộ đệm GPU và GPU mà chúng có
được phân bổ.  Phần này liệt kê kích thước bộ đệm, nhóm (VRAM, GTT, v.v.) và bộ đệm
thuộc tính (yêu cầu quyền truy cập CPU, thuộc tính bộ đệm CPU, v.v.).

amdgpu_vm_info
--------------

Liệt kê tất cả các PID sử dụng bộ đệm GPU và GPU mà chúng có
được phân bổ cũng như trạng thái của các bộ đệm đó liên quan đến quá trình đó'
Không gian địa chỉ ảo GPU (ví dụ: bị đuổi, không hoạt động, không hợp lệ, v.v.).

amdgpu_sa_info
--------------

In ra tất cả các phân bổ phụ (sa) bởi người quản lý phân bổ phụ trong
trình điều khiển hạt nhân.  In địa chỉ, kích thước và thông tin hàng rào GPU được liên kết
với mỗi phân bổ phụ.  Các phân bổ phụ được sử dụng nội bộ trong
trình điều khiển hạt nhân cho nhiều thứ khác nhau.

amdgpu_<pool>_mm
----------------

In thông tin TTM về nhóm bộ nhớ <pool>.

amdgpu_vram
-----------

Cung cấp quyền truy cập trực tiếp vào VRAM.  Được sử dụng bởi các công cụ như UMR để kiểm tra
các đối tượng trong VRAM.

amdgpu_iomem
------------

Cung cấp quyền truy cập trực tiếp vào bộ nhớ GTT.  Được sử dụng bởi các công cụ như UMR để kiểm tra
Bộ nhớ GTT.

amdgpu_regs_*
-------------

Cung cấp quyền truy cập trực tiếp vào các khẩu độ đăng ký khác nhau trên GPU.  đã qua sử dụng
bằng các công cụ như UMR để truy cập các thanh ghi GPU.

amdgpu_regs2
------------

Cung cấp giao diện IOCTL được UMR sử dụng để tương tác với các thanh ghi GPU.


amdgpu_sensors
--------------

Cung cấp giao diện để truy vấn số liệu công suất GPU (nhiệt độ, trung bình
quyền lực, v.v.).  Được sử dụng bởi các công cụ như UMR để truy vấn số liệu năng lượng của GPU.


amdgpu_gca_config
-----------------

Cung cấp giao diện để truy vấn chi tiết GPU (Cấu hình đồ họa/Mảng tính toán,
Cấu hình PCI, họ GPU, v.v.).  Được sử dụng bởi các công cụ như UMR để truy vấn chi tiết GPU.

amdgpu_wave
-----------

Được sử dụng để truy vấn thông tin sóng GFX/tính toán từ phần cứng.  Được sử dụng bởi các công cụ
như UMR để truy vấn thông tin sóng GFX/tính toán.

amdgpu_gpr
----------

Được sử dụng để truy vấn thông tin GFX/tính toán GPR (Đăng ký mục đích chung) từ
phần cứng.  Được sử dụng bởi các công cụ như UMR để truy vấn GPR khi gỡ lỗi trình đổ bóng.

amdgpu_gprwave
--------------

Cung cấp giao diện IOCTL được UMR sử dụng để tương tác với các sóng đổ bóng.

amdgpu_fw_attestation
---------------------

Cung cấp giao diện để đọc lại các bản ghi chứng thực chương trình cơ sở.
