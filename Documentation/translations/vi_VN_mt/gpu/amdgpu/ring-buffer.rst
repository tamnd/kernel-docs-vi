.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/gpu/amdgpu/ring-buffer.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==============
 Bộ đệm vòng
=============

Để xử lý giao tiếp giữa không gian người dùng và không gian kernel, GPU AMD sử dụng
thiết kế bộ đệm vòng để cấp nguồn cho động cơ (GFX, Tính toán, SDMA, UVD, VCE, VCN, VPE,
v.v.). Xem hình bên dưới minh họa cách hoạt động của giao tiếp này:

.. kernel-figure:: ring_buffers.svg

Bộ đệm vòng trong amdgpu hoạt động như một mô hình nhà sản xuất-người tiêu dùng, trong đó không gian người dùng
đóng vai trò là nhà sản xuất, liên tục lấp đầy bộ đệm vòng bằng các lệnh GPU để
được thực thi. Trong khi đó, GPU lấy thông tin từ vòng, phân tích
nó và phân phối tập lệnh cụ thể giữa các thiết bị khác nhau.
khối amdgpu.

Lưu ý từ sơ đồ rằng vòng có Con trỏ đọc (rptr), con trỏ này
cho biết nơi động cơ hiện đang đọc các gói từ vòng và
Con trỏ ghi (wptr), cho biết có bao nhiêu gói phần mềm đã được thêm vào
chiếc nhẫn. Khi rptr và wptr bằng nhau, vòng ở trạng thái rảnh. Khi phần mềm
thêm các gói vào vòng, nó cập nhật wptr, điều này khiến động cơ khởi động
tìm nạp và xử lý gói tin. Khi công cụ xử lý các gói, rptr sẽ nhận được
cập nhật cho đến khi rptr bắt kịp wptr và chúng lại bằng nhau.

Thông thường, bộ đệm vòng trong trình điều khiển có kích thước giới hạn (tìm kiếm lần xuất hiện
của ZZ0000ZZ). Một trong những lý do cho kích thước bộ đệm vòng nhỏ là
CP (Bộ xử lý lệnh) đó có khả năng đi theo các địa chỉ được chèn vào
nhẫn; điều này được minh họa trong hình ảnh bằng cách tham chiếu đến IB (gián tiếp
Bộ đệm). IB cung cấp cho không gian người dùng khả năng có một vùng trong bộ nhớ
CP có thể đọc và cung cấp phần cứng bằng các hướng dẫn bổ sung.

Tất cả các ASIC trước GFX11 đều sử dụng cái được gọi là hàng đợi kernel, có nghĩa là
vòng được phân bổ trong không gian kernel và có một số hạn chế, chẳng hạn như không
có thể là ZZ0000ZZ. GFX11
và hàng đợi kernel hỗ trợ mới hơn, nhưng cũng cung cấp một cơ chế mới có tên
ZZ0001ZZ, nơi hàng đợi được chuyển đến không gian người dùng
và có thể được ánh xạ và không được ánh xạ thông qua bộ lập lịch. Trong thực tế, cả hai hàng đợi
chèn các lệnh GPU do không gian người dùng tạo từ các công việc khác nhau vào yêu cầu
vòng thành phần.

Thực thi cách ly
=================

.. note:: After reading this section, you might want to check the
   :ref:`Process Isolation<amdgpu-process-isolation>` page for more details.

Trước khi kiểm tra cơ chế Thực thi cách ly trong bối cảnh bộ đệm vòng, nó
rất hữu ích khi thảo luận ngắn gọn về cách thực hiện các hướng dẫn từ bộ đệm vòng
được xử lý trong đường ống đồ họa. Hãy mở rộng chủ đề này bằng cách kiểm tra
sơ đồ bên dưới minh họa đường dẫn đồ họa:

.. kernel-figure:: gfx_pipeline_seq.svg

Về mặt hướng dẫn thực thi, đường ống GFX tuân theo trình tự:
Xuất Shader (SX), Geometry Engine (GE), Quá trình hoặc đầu vào Shader (SPI), Quét
Bộ chuyển đổi (SC), Trình biên dịch nguyên thủy (PA) và thao tác bộ đệm (có thể
khác nhau giữa các ASIC). Một cách phổ biến khác để mô tả quy trình là sử dụng Pixel
Shader (PS), raster và Vertex Shader (VS) để tượng trưng cho hai giai đoạn đổ bóng.
Bây giờ, với quy trình này, hãy giả sử rằng Công việc B gây ra sự cố treo,
nhưng hướng dẫn của Job C có thể đã được thực thi, khiến các nhà phát triển phải
xác định không chính xác Công việc C là công việc có vấn đề. Vấn đề này có thể được
giảm nhẹ ở nhiều cấp độ; sơ đồ dưới đây minh họa cách giảm thiểu
một phần của vấn đề này:

.. kernel-figure:: no_enforce_isolation.svg

Lưu ý từ sơ đồ rằng không có sự đảm bảo về trật tự hoặc sự phân chia rõ ràng
giữa các hướng dẫn, điều này hầu như không phải là vấn đề và cũng tốt
cho hiệu suất. Hơn nữa, hãy chú ý một số vòng tròn giữa các công việc trong sơ đồ
đại diện cho ZZ0000ZZ được sử dụng để tránh công việc chồng chéo trong vòng. Tại
ở cuối hàng rào, quá trình xóa bộ đệm xảy ra, đảm bảo rằng khi công việc tiếp theo
bắt đầu, nó bắt đầu ở trạng thái sạch sẽ và nếu có vấn đề phát sinh, nhà phát triển có thể
xác định chính xác hơn quá trình có vấn đề.

Để tăng mức độ cách ly giữa các công việc, có tính năng "Thực thi
Phương pháp cách ly" được mô tả trong hình dưới đây:

.. kernel-figure:: enforce_isolation.svg

Như được hiển thị trong sơ đồ, việc thực thi cách ly giới thiệu thứ tự giữa
các bài gửi, vì quyền truy cập vào GFX/Compute được tuần tự hóa, hãy coi nó như
quy trình đơn lẻ ở chế độ thời gian cho gfx/compute. Lưu ý rằng cách tiếp cận này có một
tác động hiệu suất đáng kể, vì nó chỉ cho phép một công việc gửi lệnh tại
một thời gian. Tuy nhiên, tùy chọn này có thể giúp xác định công việc gây ra sự cố.
Mặc dù việc thực thi cách ly giúp cải thiện tình hình nhưng nó không giải quyết được hoàn toàn
vấn đề xác định chính xác những công việc tồi tệ, vì sự cô lập có thể che giấu
vấn đề. Tóm lại, việc xác định công việc nào gây ra sự cố có thể không chính xác,
nhưng việc thực thi cách ly có thể giúp gỡ lỗi.

Hoạt động vòng
===============

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_ring.c
   :internal:

