.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/gpu/amdgpu/driver-core.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
 Cơ sở hạ tầng trình điều khiển cốt lõi
============================

Cấu trúc phần cứng GPU
======================

Mỗi ASIC là một tập hợp các khối phần cứng.  Chúng tôi gọi chúng là
"IP" (Khối sở hữu trí tuệ).  Mỗi IP đóng gói một số
chức năng. IP được phiên bản và cũng có thể được trộn lẫn và kết hợp.
Ví dụ: bạn có thể có hai ASIC khác nhau, cả hai đều có IP Hệ thống DMA (SDMA) 5.x.
Driver được sắp xếp theo IP.  Có thành phần driver để xử lý
việc khởi tạo và hoạt động của mỗi IP.  Ngoài ra còn có một đống
các IP nhỏ hơn không thực sự cần nhiều nếu có sự tương tác của trình điều khiển.
Những thứ đó cuối cùng sẽ bị gộp vào những thứ phổ biến trong các tệp soc.
Các tệp soc (ví dụ: vi.c, soc15.c nv.c) chứa mã cho các khía cạnh của
chính SoC chứ không phải các IP cụ thể.  Ví dụ: những thứ như GPU đặt lại
và chức năng truy cập đăng ký phụ thuộc vào SoC.

APU không chỉ chứa CPU và GPU mà còn chứa tất cả
nội dung nền tảng (âm thanh, usb, gpio, v.v.).  Ngoài ra, rất nhiều
các thành phần được chia sẻ giữa CPU, nền tảng và GPU (ví dụ:
SMU, PSP, v.v.).  Các thành phần cụ thể (CPU, GPU, v.v.) thường có
giao diện của chúng để tương tác với các thành phần chung đó.  Đối với những thứ
như S0i3 cần có rất nhiều sự phối hợp trên tất cả
các thành phần, nhưng điều đó có lẽ hơi vượt quá phạm vi của điều này
phần.

Đối với GPU, chúng tôi có các IP chính sau:

GMC (Bộ điều khiển bộ nhớ đồ họa)
    Đây là IP chuyên dụng trên các chip pre-vega cũ hơn, nhưng kể từ đó
    trở nên phi tập trung hơn một chút trên các chip thuần chay và mới hơn.  Bây giờ họ
    có các trung tâm bộ nhớ dành riêng cho các IP hoặc nhóm IP cụ thể.  Chúng tôi
    Tuy nhiên, vẫn coi nó như một thành phần duy nhất trong trình điều khiển vì
    mô hình lập trình vẫn khá giống nhau.  Đây là cách
    các IP khác nhau trên GPU nhận bộ nhớ (VRAM hoặc bộ nhớ hệ thống).
    Nó cũng cung cấp hỗ trợ cho mỗi tiến trình địa chỉ ảo GPU
    không gian.

IH (Trình xử lý ngắt)
    Đây là bộ điều khiển ngắt trên GPU.  Tất cả nguồn cấp dữ liệu IP
    các ngắt của chúng vào IP này và nó tổng hợp chúng thành một tập hợp
    bộ đệm vòng mà trình điều khiển có thể phân tích cú pháp để xử lý các ngắt từ
    IP khác nhau.

PSP (Bộ xử lý bảo mật nền tảng)
    Điều này xử lý chính sách bảo mật cho SoC và thực thi các lệnh đáng tin cậy
    các ứng dụng, đồng thời xác nhận và tải phần mềm cơ sở cho các khối khác.

SMU (Đơn vị quản lý hệ thống)
    Đây là bộ vi điều khiển quản lý năng lượng.  Nó quản lý toàn bộ
    SoC.  Trình điều khiển tương tác với nó để kiểm soát việc quản lý năng lượng
    các tính năng như đồng hồ, điện áp, đường ray điện, v.v.

DCN (Bộ điều khiển hiển thị tiếp theo)
    Đây là bộ điều khiển hiển thị.  Nó xử lý phần cứng hiển thị.
    Nó được mô tả chi tiết hơn trong ZZ0000ZZ.

SDMA (Hệ thống DMA)
    Đây là động cơ DMA đa năng.  Trình điều khiển hạt nhân sử dụng nó cho
    nhiều thứ khác nhau bao gồm phân trang và cập nhật bảng trang GPU.  Nó cũng
    được tiếp xúc với không gian người dùng để trình điều khiển chế độ người dùng sử dụng (OpenGL, Vulkan,
    v.v.)

GC (Đồ họa và tính toán)
    Đây là công cụ đồ họa và tính toán, tức là khối
    bao gồm các đường dẫn 3D và các khối đổ bóng.  Đây là điều
    khối lớn nhất trên GPU.  Đường ống 3D có rất nhiều khối con.  trong
    Ngoài ra, nó còn chứa các bộ vi điều khiển CP (ME, PFP, CE,
    MEC) và bộ vi điều khiển RLC.  Nó được tiếp xúc với không gian người dùng cho chế độ người dùng
    trình điều khiển (OpenGL, Vulkan, OpenCL, v.v.). Thêm chi tiết trong ZZ0000ZZ.

VCN (Lõi video tiếp theo)
    Đây là công cụ đa phương tiện.  Nó xử lý mã hóa video và hình ảnh và
    giải mã.  Nó được hiển thị trong không gian người dùng dành cho trình điều khiển chế độ người dùng (VA-API,
    OpenMAX, v.v.)

Điều quan trọng cần lưu ý là các khối này có thể tương tác với nhau. các
hình ảnh dưới đây minh họa một số thành phần và mối liên hệ giữa chúng:

.. kernel-figure:: amd_overview_block.svg

Trong sơ đồ, các khối liên quan đến bộ nhớ được hiển thị bằng màu xanh lá cây. Chú ý cụ thể nhé
IP có hình vuông màu xanh lục tượng trưng cho một khối phần cứng nhỏ có tên là 'hub',
chịu trách nhiệm giao tiếp với bộ nhớ. Tất cả các trung tâm bộ nhớ được kết nối
trong UMC, sau đó được kết nối với các khối bộ nhớ. Như một lưu ý,
các thiết bị tiền thuần chay có một khối dành riêng cho Bộ điều khiển bộ nhớ đồ họa
(GMC), được thay thế bằng UMC và các trung tâm trong kiến trúc mới. Trong trình điều khiển
mã, bạn có thể xác định thành phần này bằng cách tìm trung tâm hậu tố, ví dụ:
ví dụ: gfxhub, dchub, mmhub, vmhub, v.v. Hãy nhớ rằng thành phần
tương tác với khối bộ nhớ có thể khác nhau giữa các kiến trúc. Ví dụ,
trên Navi và phiên bản mới hơn, GC và SDMA đều được gắn vào GCHUB; trên phiên bản tiền Navi, SDMA
đi qua MMHUB; VCN, JPEG và VPE đi qua MMHUB; DCN đi qua
DCHUB.

Có một số biện pháp bảo vệ đối với một số thành phần bộ nhớ nhất định và PSP đóng vai trò
vai trò thiết yếu trong lĩnh vực này. Khi một phần sụn cụ thể được tải vào bộ nhớ,
PSP thực hiện các bước để đảm bảo nó có chữ ký hợp lệ. Nó cũng lưu trữ firmware
hình ảnh trong vùng bộ nhớ được bảo vệ có tên là Vùng bộ nhớ tin cậy (TMR), do đó hệ điều hành hoặc
trình điều khiển không thể làm hỏng chúng khi chạy. Một công dụng khác của PSP là hỗ trợ Trusted
Ứng dụng (TA), về cơ bản là các ứng dụng nhỏ chạy trên
bộ xử lý đáng tin cậy và xử lý một hoạt động đáng tin cậy (ví dụ: HDCP). PSP cũng vậy
được sử dụng cho bộ nhớ được mã hóa để bảo vệ nội dung thông qua Vùng bộ nhớ đáng tin cậy (TMZ).

Một IP quan trọng khác là SMU. Nó xử lý việc phân phối thiết lập lại, cũng như
quản lý đồng hồ, nhiệt và năng lượng cho tất cả IP trên SoC. SMU cũng giúp
cân bằng hiệu suất và điện năng tiêu thụ.

.. _pipes-and-queues-description:

Hành vi tổng thể của GFX, Điện toán và SDMA
=======================================

.. note:: For simplicity, whenever the term block is used in this section, it
   means GFX, Compute, and SDMA.

GFX, Điện toán và SDMA có chung một hình thức hoạt động có thể được trừu tượng hóa
để tạo điều kiện cho sự hiểu biết về hành vi của các khối này. Xem hình
dưới đây minh họa các thành phần chung của các khối này:

.. kernel-figure:: pipe_and_queue_abstraction.svg

Ở phần trung tâm của hình này, bạn có thể thấy hai thành phần phần cứng, một được gọi là
ZZ0000ZZ và một loại khác có tên ZZ0001ZZ; điều quan trọng là phải làm nổi bật rằng Hàng đợi
phải được liên kết với một Pipe và ngược lại. Mỗi IP phần cứng cụ thể có thể có
một số lượng Ống khác nhau và do đó, một số Hàng đợi khác nhau; cho
ví dụ: GFX 11 có hai Ống và hai Hàng đợi trên mỗi Ống cho giao diện người dùng GFX.

Ống là phần cứng xử lý các hướng dẫn có sẵn trong Hàng đợi;
nói cách khác, nó là một luồng thực thi các thao tác được chèn vào Hàng đợi.
Một đặc điểm quan trọng của Pipes là chúng chỉ có thể thực thi một Hàng đợi tại
một thời gian; bất kể phần cứng có nhiều Hàng đợi trong Ống hay không, nó chỉ chạy
một hàng đợi cho mỗi ống.

Các đường ống có cơ chế hoán đổi giữa các hàng đợi ở cấp độ phần cứng.
Tuy nhiên, họ chỉ sử dụng Hàng đợi được coi là được ánh xạ. Ống có thể
chuyển đổi giữa các hàng đợi dựa trên bất kỳ thông tin đầu vào nào sau đây:

1. Luồng lệnh;
2. Từng gói một;
3. Phần cứng khác yêu cầu thay đổi (ví dụ: MES).

Hàng đợi trong Ống được xác định bởi Bộ mô tả hàng đợi phần cứng (HQD).
Liên kết với khái niệm HQD, chúng ta có Bộ mô tả hàng đợi bộ nhớ (MQD),
chịu trách nhiệm lưu trữ thông tin về trạng thái của từng
Hàng đợi có sẵn trong bộ nhớ. Trạng thái của hàng đợi chứa thông tin như
làm địa chỉ ảo GPU của chính hàng đợi, khu vực lưu, chuông cửa, v.v.
MQD cũng lưu trữ các thanh ghi HQD, rất quan trọng để kích hoạt hoặc
vô hiệu hóa một hàng đợi nhất định.  Phần mềm lập kế hoạch (ví dụ: MES) chịu trách nhiệm
để tải HQD từ MQD và ngược lại.

Quá trình chuyển đổi hàng đợi cũng có thể xảy ra với phần sụn yêu cầu
quyền ưu tiên hoặc hủy ánh xạ của Hàng đợi. Phần sụn chờ bit HQD_ACTIVE
để chuyển sang mức thấp trước khi lưu trạng thái vào MQD. Để tạo nên sự khác biệt
Hàng đợi bắt đầu hoạt động, phần sụn sẽ sao chép trạng thái MQD vào các thanh ghi HQD
và tải bất kỳ trạng thái bổ sung nào. Cuối cùng, nó đặt bit HQD_ACTIVE lên cao thành
cho biết hàng đợi đang hoạt động.  Sau đó, Pipe sẽ thực hiện công việc từ hoạt động
Hàng đợi.

Cấu trúc trình điều khiển
================

Nói chung, trình điều khiển có danh sách tất cả các IP trên một địa chỉ cụ thể
SoC và những thứ như init/fini/tạm dừng/tiếp tục, ít nhiều chỉ
duyệt danh sách và xử lý từng IP.

Một số cấu trúc hữu ích:

KIQ (Hàng đợi giao diện hạt nhân)
    Đây là hàng đợi điều khiển được trình điều khiển hạt nhân sử dụng để quản lý các gfx khác
    và tính toán hàng đợi trên GFX/công cụ tính toán.  Bạn có thể sử dụng nó để
    ánh xạ/hủy ánh xạ các hàng đợi bổ sung, v.v. Điều này được thay thế bằng MES trên
    GFX 11 và phần cứng mới hơn.

IB (Bộ đệm gián tiếp)
    Một bộ đệm lệnh cho một công cụ cụ thể.  Thay vì viết
    lệnh trực tiếp vào hàng đợi, bạn có thể viết các lệnh vào một
    phần bộ nhớ rồi đặt một con trỏ tới bộ nhớ vào hàng đợi.
    Phần cứng sau đó sẽ đi theo con trỏ và thực hiện các lệnh trong
    bộ nhớ, sau đó quay trở lại các lệnh còn lại trong vòng.

.. _amdgpu_memory_domains:

Miền bộ nhớ
==============

.. kernel-doc:: include/uapi/drm/amdgpu_drm.h
   :doc: memory domains

Đối tượng đệm
==============

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_object.c
   :doc: amdgpu_object

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_object.c
   :internal:

Chia sẻ bộ đệm PRIME
====================

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_dma_buf.c
   :doc: PRIME Buffer Sharing

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_dma_buf.c
   :internal:

Trình thông báo MMU
============

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_hmm.c
   :doc: MMU Notifier

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_hmm.c
   :internal:

Bộ nhớ ảo AMDGPU
=====================

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c
   :doc: GPUVM

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_vm.c
   :internal:

Xử lý ngắt
==================

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_irq.c
   :doc: Interrupt Handling

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_irq.c
   :internal:

Khối IP
=========

.. kernel-doc:: drivers/gpu/drm/amd/include/amd_shared.h
   :doc: IP Blocks

.. kernel-doc:: drivers/gpu/drm/amd/include/amd_shared.h
   :identifiers: amd_ip_block_type amd_ip_funcs DC_FEATURE_MASK DC_DEBUG_MASK
