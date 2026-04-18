.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/gpu/amdgpu/display/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _amdgpu-display-core:

======================================
drm/amd/display - Lõi hiển thị (DC)
======================================

Công cụ hiển thị AMD được chia sẻ một phần với các hệ điều hành khác; vì điều này
lý do, Trình điều khiển lõi hiển thị của chúng tôi được chia thành hai phần:

#. ZZ0000ZZ chứa các thành phần không xác định được hệ điều hành. Những điều như
   lập trình phần cứng và quản lý tài nguyên được xử lý ở đây.
#. ZZ0001ZZ chứa các thành phần phụ thuộc vào hệ điều hành. Móc vào
   trình điều khiển cơ sở amdgpu và DRM được triển khai tại đây. Ví dụ, bạn có thể kiểm tra
   thư mục hiển thị/amdgpu_dm/.

------------------
Xác thực mã DC
------------------

Việc duy trì cùng một cơ sở mã trên nhiều hệ điều hành đòi hỏi rất nhiều
nỗ lực đồng bộ hóa giữa các kho lưu trữ và xác thực toàn diện. trong
Trong trường hợp DC, chúng tôi duy trì một cây để tập trung mã từ các phần khác nhau. Việc chia sẻ
kho lưu trữ có các thử nghiệm tích hợp với nhóm CI Linux nội bộ của chúng tôi và chúng tôi chạy một
bộ thử nghiệm IGT toàn diện trong các GPU/APU AMD khác nhau (chủ yếu là các dGPU gần đây
và APU). CI của chúng tôi cũng kiểm tra quá trình biên dịch ARM64/32, PPC64/32 và x86_64/32
với DCN được bật và tắt.

Khi chúng tôi cập nhật một tính năng mới hoặc một số bản vá, chúng tôi sẽ đóng gói chúng trong một bộ bản vá có
tiền tố ZZ0001ZZ, được tạo dựa trên phiên bản mới nhất
ZZ0000ZZ. Tất cả
các bản vá đó thuộc phiên bản DC được thử nghiệm như sau:

* Đảm bảo rằng mọi bản vá được biên dịch và toàn bộ chuỗi đều vượt qua bộ IGT của chúng tôi
  kiểm tra trong phần cứng khác nhau.
* Chuẩn bị một nhánh có các bản vá đó cho nhóm xác thực của chúng tôi. Nếu có một
  lỗi, nhà phát triển sẽ gỡ lỗi nhanh nhất có thể; thông thường, một đường chia đôi đơn giản
  trong chuỗi là đủ để chỉ ra một thay đổi xấu và hai hành động có thể xảy ra
  nổi lên: khắc phục sự cố hoặc bỏ bản vá. Nếu nó không phải là một sửa chữa dễ dàng, điều xấu
  bản vá bị loại bỏ.
* Cuối cùng, các nhà phát triển đợi vài ngày để nhận phản hồi của cộng đồng trước khi chúng tôi hợp nhất
  loạt bài này.

Cần nhấn mạnh rằng giai đoạn thử nghiệm là giai đoạn chúng tôi thực hiện cực kỳ nghiêm túc.
một cách nghiêm túc và chúng tôi không bao giờ hợp nhất bất kỳ thứ gì không đạt yêu cầu xác thực của chúng tôi. Theo sau một
tổng quan về bộ thử nghiệm của chúng tôi:

#. Kiểm tra thủ công
    * Nhiều phích cắm nóng với DP và HDMI.
    * Kiểm tra căng thẳng với nhiều thay đổi cấu hình hiển thị thông qua giao diện người dùng.
    * Xác thực hành vi VRR.
    * Kiểm tra PSR.
    * Xác thực MPO khi phát video.
    * Kiểm tra nhiều hơn hai màn hình được kết nối cùng một lúc.
    * Kiểm tra tạm dừng/tiếp tục.
    * Xác thực FPO.
    * Kiểm tra MST.
#. Kiểm tra tự động
    * IGT thử nghiệm trong trang trại có GPU và APU hỗ trợ DCN và DCE.
    * Xác thực biên dịch với GCC và Clang mới nhất từ ​​bản phân phối LTS.
    * Biên dịch chéo cho PowerPC 64/32, ARM 64/32 và x86 32.

Về mặt thiết lập kiểm tra cho CI và kiểm tra thủ công, chúng tôi thường sử dụng:

#. Ubuntu LTS mới nhất.
#. Về không gian người dùng, chúng tôi chỉ sử dụng các thành phần nguồn mở được cập nhật đầy đủ
   được cung cấp bởi người quản lý gói phân phối chính thức.
#. Về IGT, chúng tôi sử dụng mã mới nhất từ ​​thượng nguồn.
#. Hầu hết các thử nghiệm thủ công đều được thực hiện trong Gnome nhưng chúng tôi cũng sử dụng KDE.

Lưu ý rằng ai đó trong nhóm thử nghiệm của chúng tôi sẽ luôn trả lời thư xin việc
với báo cáo thử nghiệm.

--------------
Thông tin DC
--------------

Ống hiển thị chịu trách nhiệm "quét" khung hình được hiển thị từ
Bộ nhớ GPU (còn gọi là VRAM, FrameBuffer, v.v.) cho màn hình. Nói cách khác,
nó sẽ:

#. Đọc thông tin khung từ bộ nhớ;
#. Thực hiện chuyển đổi cần thiết;
#. Gửi dữ liệu pixel đến các thiết bị chìm.

Nếu bạn muốn tìm hiểu thêm về chi tiết tài xế của chúng tôi, hãy xem phần bên dưới
mục lục:

.. toctree::

   display-manager.rst
   dcn-overview.rst
   dcn-blocks.rst
   programming-model-dcn.rst
   mpo-overview.rst
   dc-debug.rst
   display-contributing.rst
   dc-glossary.rst
