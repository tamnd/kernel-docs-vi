.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/huawei/hinic.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================================================================
Trình điều khiển hạt nhân Linux dành cho dòng NIC(HiNIC) thông minh của Huawei
============================================================

Tổng quan:
=========
HiNIC là card giao diện mạng dành cho Khu vực Trung tâm Dữ liệu.

Trình điều khiển hỗ trợ nhiều loại thiết bị có tốc độ liên kết (10GbE, 25GbE, 40GbE, v.v.).
Trình điều khiển cũng hỗ trợ một bộ tính năng có thể thương lượng và mở rộng.

Một số thiết bị HiNIC hỗ trợ SR-IOV. Trình điều khiển này được sử dụng cho Chức năng vật lý
(PF).

Các thiết bị HiNIC hỗ trợ vectơ ngắt MSI-X cho mỗi hàng đợi Tx/Rx và
điều chế ngắt thích ứng.

Các thiết bị HiNIC cũng hỗ trợ nhiều tính năng giảm tải khác nhau như giảm tải tổng kiểm tra,
TCP Giảm tải phân đoạn truyền (TSO), Chia tỷ lệ bên nhận (RSS) và
LRO(Giảm tải nhận lớn).


ID nhà cung cấp/ID thiết bị PCI được hỗ trợ:
===================================

19e5:1822 - HiNIC PF


Kiến trúc trình điều khiển và mã nguồn:
====================================

hinic_dev - Triển khai một thiết bị Mạng logic độc lập với
chi tiết CTNH cụ thể về các định dạng cấu trúc dữ liệu CTNH.

hinic_hwdev - Triển khai chi tiết CTNH của thiết bị và bao gồm các thành phần
để truy cập PCI NIC.

hinic_hwdev chứa các thành phần sau:
===============================================

Giao diện CTNH:
=============

Giao diện để truy cập thiết bị pci (bộ nhớ DMA và BAR PCI).
(hinic_hw_if.c, hinic_hw_if.h)

Vùng thanh ghi trạng thái cấu hình mô tả các thanh ghi CTNH trên
cấu hình và trạng thái BAR0. (hinic_hw_csr.h)

Các thành phần MGMT:
================

Hàng đợi sự kiện không đồng bộ (AEQ) - Hàng đợi sự kiện để nhận tin nhắn từ
các mô-đun MGMT trên thẻ. (hinic_hw_eqs.c, hinic_hw_eqs.h)

Các lệnh Giao diện lập trình ứng dụng (API CMD) - Giao diện gửi
Lệnh MGMT vào thẻ. (hinic_hw_api_cmd.c, hinic_hw_api_cmd.h)

Quản lý (MGMT) - kênh PF đến MGMT sử dụng API CMD để gửi MGMT
lệnh vào thẻ và nhận thông báo từ các mô-đun MGMT trên
thẻ của AEQ. Đồng thời đặt địa chỉ của IO CMDQ trong HW.
(hinic_hw_mgmt.c, hinic_hw_mgmt.h)

Các thành phần IO:
==============

Hàng đợi sự kiện hoàn thành(CEQ) - Hàng đợi sự kiện hoàn thành mô tả IO
những nhiệm vụ đã hoàn thành. (hinic_hw_eqs.c, hinic_hw_eqs.h)

Hàng đợi công việc(WQ) - Chứa bộ nhớ và các thao tác để sử dụng bởi hàng đợi CMD và
các cặp hàng đợi. WQ là Khối bộ nhớ trong một trang. Khối chứa
con trỏ tới Vùng bộ nhớ là Bộ nhớ dành cho các phần tử hàng đợi công việc (WQE).
(hinic_hw_wq.c, hinic_hw_wq.h)

Hàng đợi lệnh (CMDQ) - Hàng đợi gửi lệnh để quản lý IO và được
được sử dụng để đặt địa chỉ QP trong CTNH. Các sự kiện hoàn thành lệnh là
tích lũy trên CEQ được cấu hình để nhận các sự kiện hoàn thành CMDQ.
(hinic_hw_cmdq.c, hinic_hw_cmdq.h)

Cặp hàng đợi(QP) - Hàng đợi nhận và gửi CTNH để nhận và truyền
Dữ liệu. (hinic_hw_qp.c, hinic_hw_qp.h, hinic_hw_qp_ctxt.h)

IO - hủy/xây dựng tất cả các thành phần IO. (hinic_hw_io.c, hinic_hw_io.h)

Thiết bị CTNH:
==========

Thiết bị CTNH - hủy/xây dựng Giao diện CTNH, các thành phần MGMT trên
khởi tạo trình điều khiển và các thành phần IO trong trường hợp Giao diện
Sự kiện UP/DOWN. (hinic_hw_dev.c, hinic_hw_dev.h)


hinic_dev chứa các thành phần sau:
===============================================

Bảng ID PCI - Chứa ID nhà cung cấp/thiết bị PCI được hỗ trợ.
(hinic_pci_tbl.h)

Lệnh cổng - Gửi lệnh tới thiết bị CTNH để quản lý cổng
(MAC, Vlan, MTU, ...). (hinic_port.c, hinic_port.h)

Hàng đợi Tx - Hàng đợi Tx logic sử dụng Hàng đợi gửi CTNH để truyền.
Hàng đợi Logical Tx không phụ thuộc vào định dạng của Hàng đợi Gửi CTNH.
(hinic_tx.c, hinic_tx.h)

Hàng đợi Rx - Hàng đợi Rx logic sử dụng Hàng đợi nhận CTNH để nhận.
Hàng đợi Logical Rx không phụ thuộc vào định dạng của Hàng đợi nhận CTNH.
(hinic_rx.c, hinic_rx.h)

hinic_dev - de/xây dựng Hàng đợi Tx và Rx logic.
(hinic_main.c, hinic_dev.h)


Linh tinh
=============

Các chức năng phổ biến được sử dụng bởi CTNH và Thiết bị logic.
(hinic_common.c, hinic_common.h)


Ủng hộ
=======

Nếu xác định được sự cố với mã nguồn đã phát hành trên hạt nhân được hỗ trợ
với bộ điều hợp được hỗ trợ, hãy gửi email thông tin cụ thể liên quan đến sự cố tới
aviad.krawczyk@huawei.com.