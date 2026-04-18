.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/keystone/knav-qmss.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================================================================================
Trình điều khiển Hệ thống con Quản lý hàng đợi Keystone Navigator của Texas Instruments
=======================================================================================

Đường dẫn mã nguồn trình điều khiển
  trình điều khiển/soc/ti/knav_qmss.c
  trình điều khiển/soc/ti/knav_qmss_acc.c

QMSS (Hệ thống phụ quản lý hàng đợi) được tìm thấy trên Keystone SOC là một trong những
hệ thống phụ phần cứng chính tạo thành xương sống của Keystone
Bộ điều hướng đa lõi. QMSS bao gồm các trình quản lý hàng đợi, cấu trúc dữ liệu đóng gói
bộ xử lý (PDSP), liên kết RAM, nhóm mô tả và cơ sở hạ tầng
Gói DMA.
Trình quản lý hàng đợi là một mô-đun phần cứng chịu trách nhiệm tăng tốc
quản lý hàng đợi gói. Các gói được xếp hàng/xóa hàng đợi bằng cách ghi hoặc
đọc địa chỉ mô tả tới một vị trí được ánh xạ bộ nhớ cụ thể. các PDSP
thực hiện các chức năng liên quan đến QMSS như tích lũy, QoS hoặc quản lý sự kiện.
Liên kết các thanh ghi RAM được sử dụng để liên kết các bộ mô tả được lưu trữ trong
bộ mô tả RAM. Bộ mô tả RAM có thể được cấu hình làm bộ nhớ trong hoặc ngoài.
Trình điều khiển QMSS quản lý các thiết lập PDSP, liên kết các vùng RAM,
quản lý nhóm hàng đợi (phân bổ, đẩy, bật và thông báo) và mô tả
quản lý hồ bơi.

Trình điều khiển knav qmss cung cấp một bộ API cho trình điều khiển để mở/đóng hàng đợi qmss,
phân bổ nhóm mô tả, ánh xạ các bộ mô tả, đẩy/bật vào hàng đợi, v.v.
chi tiết về các API có sẵn, vui lòng tham khảo include/linux/soc/ti/knav_qmss.h

Tài liệu DT có sẵn tại
Tài liệu/devicetree/binds/soc/ti/keystone-navigator-qmss.txt

Hàng đợi tích lũy QMSS sử dụng phần mềm PDSP
============================================
Kênh tích lũy hỗ trợ phần mềm QMSS PDSP có thể giám sát một đơn vị
hàng đợi hoặc nhiều hàng đợi liền kề nhau. trình điều khiển/soc/ti/knav_qmss_acc.c là
trình điều khiển có giao diện với bộ tích lũy PDSP. Điều này cấu hình
các kênh tích lũy được xác định trong DTS (ví dụ trong tài liệu DT) để giám sát
1 hoặc 32 hàng đợi trên mỗi kênh. Mô tả thêm về phần sụn có sẵn trong
Tài liệu Driver cấp thấp CPPI/QMSS (docs/CPPI_QMSS_LLD_SDS.pdf) tại

git://git.ti.com/keystone-rtos/qmss-lld.git

firmware k2_qmss_pdsp_acc48_k2_le_1_0_0_9.bin hỗ trợ tối đa 48 bộ tích lũy
các kênh. Phần sụn này có sẵn trong thư mục ti-keystone của
firmware.git tại

git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git

Để sử dụng, hãy sao chép hình ảnh chương trình cơ sở vào thư mục lib/firmware của initramfs hoặc
ubifs và cung cấp liên kết sym tới k2_qmss_pdsp_acc48_k2_le_1_0_0_9.bin
trong hệ thống tập tin và khởi động kernel. Người dùng sẽ thấy

"tệp chương trình cơ sở ks2_qmss_pdsp_acc48.bin được tải xuống cho PDSP"

trong nhật ký khởi động nếu tải chương trình cơ sở vào PDSP thành công.

Việc sử dụng hàng đợi tích lũy yêu cầu phải có hình ảnh chương trình cơ sở trong
hệ thống tập tin. Trình điều khiển không tích hợp hàng đợi vào phạm vi hàng đợi được hỗ trợ nếu
PDSP không chạy trong SoC. Cuộc gọi API không thành công nếu có hàng đợi mở
yêu cầu hàng đợi acc và PDSP không chạy. Vì vậy hãy đảm bảo sao chép firmware
vào hệ thống tập tin trước khi sử dụng các loại hàng đợi này.
