.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/huawei/hinic3.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============================================================================================
Trình điều khiển nhân Linux dành cho dòng Trình điều khiển Thiết bị Ethernet Huawei (hinic3)
============================================================================================

Tổng quan
=========

Hinic3 là card giao diện mạng (NIC) dành cho Trung tâm dữ liệu. Nó hỗ trợ
một loạt các thiết bị có tốc độ liên kết (10GE, 25GE, 100GE, v.v.). hinic3
thiết bị có thể có nhiều dạng vật lý: LOM (Lan trên bo mạch chủ) NIC,
Tiêu chuẩn PCIe NIC, OCP (Dự án tính toán mở) NIC, v.v.

Trình điều khiển hinic3 hỗ trợ các tính năng sau:
- Giảm tải tổng kiểm tra IPv4/IPv6 TCP/UDP
- TSO (Giảm tải phân đoạn TCP), LRO (Giảm tải nhận lớn)
- RSS (Nhận tỷ lệ bên)
- Cấu hình tổng hợp ngắt MSI-X và thích ứng ngắt.
- SR-IOV (Ảo hóa I/O gốc đơn).

Nội dung
========

- ID nhà cung cấp/ID thiết bị PCI được hỗ trợ
- Cấu trúc mã nguồn của Driver Hinic3
- Giao diện quản lý

ID nhà cung cấp/ID thiết bị PCI được hỗ trợ
===========================================

19e5:0222 - hinic3 PF/PPF
19e5:375F - hinic3 VF

Prime Physical Function (PPF) chịu trách nhiệm quản lý
toàn bộ thẻ NIC. Ví dụ: đồng bộ hóa đồng hồ giữa NIC và
chủ nhà. Bất kỳ PF nào cũng có thể đóng vai trò là PPF. PPF được chọn động.

Cấu trúc mã nguồn của Driver Hinic3
======================================

=============================================================================
hinic3_pci_id_tbl.h ID thiết bị được hỗ trợ
hinic3_hw_intf.h Giao diện giữa CTNH và trình điều khiển
hinic3_queue_common.[ch] Cấu trúc và phương thức chung cho hàng đợi NIC
hinic3_common.[ch] Đóng gói các hoạt động bộ nhớ trong Linux
hinic3_csr.h Đăng ký định nghĩa trong BAR
hinic3_hwif.[ch] Giao diện cho BAR
hinic3_eqs.[ch] Giao diện cho AEQ và CEQ
hinic3_mbox.[ch] Giao diện hộp thư
hinic3_mgmt.[ch] Giao diện quản lý dựa trên hộp thư và AEQ
hinic3_wq.[ch] Cấu trúc và giao diện dữ liệu hàng đợi công việc
hinic3_cmdq.[ch] Hàng đợi lệnh được sử dụng để gửi lệnh lên CTNH
hinic3_hwdev.[ch] trừu tượng hóa các cấu trúc và phương thức CTNH
hinic3_lld.[ch] Lớp thích ứng trình điều khiển phụ trợ
hinic3_hw_comm.[ch] Giao diện vận hành CTNH thông dụng
hinic3_mgmt_interface.h Giao diện giữa firmware và driver
hinic3_hw_cfg.[ch] Giao diện cấu hình CTNH
hinic3_irq.c Yêu cầu ngắt
hinic3_netdev_ops.c Các hoạt động được đăng ký vào ngăn xếp nhân Linux
hinic3_nic_dev.h Tóm tắt cấu trúc và phương thức NIC
hinic3_main.c Trình điều khiển hạt nhân Linux chính
hinic3_nic_cfg.[ch] Cấu hình dịch vụ NIC
hinic3_nic_io.[ch] Giao diện mặt phẳng quản lý cho TX và RX
hinic3_rss.[ch] Giao diện cho việc chia tỷ lệ bên nhận (RSS)
hinic3_rx.[ch] Giao diện truyền
hinic3_tx.[ch] Giao diện nhận
hinic3_ethtool.c Giao diện cho các hoạt động ethtool (ops)
hinic3_filter.c Giao diện địa chỉ MAC
=============================================================================

Giao diện quản lý
====================

Hàng đợi sự kiện không đồng bộ (AEQ)
------------------------------------

AEQ nhận các sự kiện có mức độ ưu tiên cao từ CTNH qua hàng đợi bộ mô tả.
Mỗi bộ mô tả có kích thước cố định là 64 byte. AEQ có thể nhận được yêu cầu hoặc
sự kiện không mong muốn. Mỗi thiết bị, VF hoặc PF, có thể có tối đa 4 AEQ.
Mỗi AEQ đều được liên kết với một IRQ chuyên dụng. AEQ có thể nhận được nhiều loại
của các sự kiện, nhưng trong thực tế trình điều khiển hinic3 bỏ qua tất cả các sự kiện ngoại trừ
2 sự kiện liên quan đến hộp thư.

Hộp thư
-------

Hộp thư là một cơ chế giao tiếp giữa trình điều khiển hinic3 và HW.
Mỗi thiết bị có một hộp thư độc lập. Lái xe có thể sử dụng hộp thư để gửi
yêu cầu tới quản lý. Trình điều khiển nhận được tin nhắn hộp thư, chẳng hạn như phản hồi
theo yêu cầu, qua AEQ (sử dụng sự kiện HINIC3_AEQ_FOR_MBOX). Do
kích thước giới hạn của thanh ghi dữ liệu hộp thư, tin nhắn hộp thư sẽ được gửi
theo từng đoạn.

Mọi thiết bị đều có thể sử dụng hộp thư của mình để gửi yêu cầu lên chương trình cơ sở. Hộp thư
cũng có thể được sử dụng để gửi yêu cầu và phản hồi giữa PF và VF của nó.

Hàng đợi sự kiện hoàn thành (CEQ)
---------------------------------

Việc triển khai CEQ cũng giống như AEQ. Nó nhận được sự kiện hoàn thành
từ CTNH qua bộ mô tả kích thước cố định là 32 bit. Mọi thiết bị đều có thể có tối đa
đến 32 CEQ. Mỗi CEQ đều có một IRQ chuyên dụng. CEQ chỉ nhận lời mời
các sự kiện phản hồi các yêu cầu từ người lái xe. CEQ có thể nhận được
nhiều loại sự kiện, nhưng trong thực tế trình điều khiển hinic3 bỏ qua tất cả
các sự kiện ngoại trừ HINIC3_CMDQ thể hiện sự hoàn thành trước đó
đã đăng lệnh trên cmdq.

Hàng đợi lệnh (cmdq)
--------------------

Mỗi cmdq đều có một hàng đợi công việc chuyên dụng để đăng các lệnh.
Các lệnh trên hàng đợi công việc là bộ mô tả kích thước cố định có kích thước 64 byte.
Việc hoàn thành một lệnh sẽ được biểu thị bằng cách sử dụng các bit ctrl trong
bộ mô tả mang lệnh. Thông báo hoàn thành lệnh
cũng sẽ được cung cấp thông qua sự kiện trên CEQ. Mỗi thiết bị có 4 hàng đợi lệnh
được khởi tạo dưới dạng một tập hợp (được gọi là cmdqs), mỗi tập hợp có kiểu riêng.
Trình điều khiển Hinic3 chỉ sử dụng loại HINIC3_CMDQ_SYNC.

Hàng đợi công việc(WQ)
----------------------

Hàng đợi công việc là các mảng logic có kích thước cố định WQE. Mảng có thể trải rộng
trên nhiều trang không liền kề bằng bảng hướng dẫn. Hàng đợi công việc là
được sử dụng bởi hàng đợi I/O và hàng đợi lệnh.

ID chức năng chung
------------------

Mọi chức năng, PF hoặc VF, đều có mã nhận dạng thứ tự duy nhất trong thiết bị.
Nhiều lệnh quản lý (mbox hoặc cmdq) chứa ID này để HW có thể áp dụng
lệnh có hiệu lực cho đúng chức năng.

PF được phép gửi các lệnh quản lý tới VF cấp dưới bằng cách chỉ định
ID VF. VF phải cung cấp ID riêng của mình. Việc chống giả mạo trong CTNH sẽ gây ra
lệnh từ VF không thành công nếu nó chứa ID sai.
