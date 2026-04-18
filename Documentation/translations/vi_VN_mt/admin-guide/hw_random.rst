.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/hw_random.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Trình tạo số ngẫu nhiên phần cứng
====================================

Giới thiệu
============

Khung hw_random là phần mềm sử dụng
tính năng phần cứng đặc biệt trên CPU hoặc bo mạch chủ của bạn,
Trình tạo số ngẫu nhiên (RNG).  Phần mềm có hai phần:
lõi cung cấp thiết bị ký tự /dev/hwrng và của nó
hỗ trợ sysfs, cùng với trình điều khiển dành riêng cho phần cứng hỗ trợ
vào lõi đó.

Để sử dụng hiệu quả nhất các cơ chế này, bạn
cũng nên tải phần mềm hỗ trợ.  Tải xuống
phiên bản mới nhất của gói "rng-tools" từ:

ZZ0000ZZ

Những công cụ đó sử dụng /dev/hwrng để lấp đầy nhóm entropy của kernel,
được sử dụng nội bộ và xuất khẩu bởi /dev/urandom và
/dev/các tệp đặc biệt ngẫu nhiên.

Lý thuyết hoạt động
===================

CHARACTER DEVICE.  Sử dụng tiêu chuẩn open()
và các cuộc gọi hệ thống read(), bạn có thể đọc dữ liệu ngẫu nhiên từ
thiết bị RNG phần cứng.  Dữ liệu này là NOT CHECKED bởi bất kỳ ai
các bài kiểm tra thể lực và có khả năng là giả mạo (nếu
phần cứng bị lỗi hoặc bị giả mạo).  Dữ liệu chỉ
đầu ra nếu cờ "có dữ liệu" phần cứng được đặt, tuy nhiên
một người có ý thức về bảo mật sẽ thực hiện các bài kiểm tra sức khỏe trên
dữ liệu trước khi cho rằng nó thực sự ngẫu nhiên.

Gói rng-tools sử dụng các thử nghiệm như vậy trong "rngd" và cho phép bạn
chạy chúng bằng tay với tiện ích "rngtest".

/dev/hwrng là thiết bị char lớn 10, thứ 183.

CLASS DEVICE.  Có một nút /sys/class/misc/hw_random với
hai thuộc tính duy nhất, "rng_available" và "rng_current".  các
Thuộc tính "rng_available" liệt kê các trình điều khiển dành riêng cho phần cứng
có sẵn, trong khi "rng_current" liệt kê cái hiện có
được kết nối với/dev/hwrng.  Nếu hệ thống của bạn có nhiều hơn một
RNG có sẵn, bạn có thể thay đổi tên được sử dụng bằng cách viết tên từ
danh sách trong "rng_available" thành "rng_current".

================================================================================


Trình điều khiển phần cứng cho Bộ tạo số ngẫu nhiên Intel/AMD/VIA (RNG)
	- Copyright 2000,2001 Jeff Garzik <jgarzik@pobox.com>
	- Bản quyền 2000,2001 Philipp Rumpf <prumpf@mandrakesoft.com>


Giới thiệu về phần cứng Intel RNG, từ bảng dữ liệu trung tâm chương trình cơ sở
===============================================================================

Trung tâm chương trình cơ sở tích hợp Trình tạo số ngẫu nhiên (RNG)
sử dụng nhiễu nhiệt được tạo ra từ lượng tử ngẫu nhiên vốn có
tính chất cơ học của silic. Khi không tạo ngẫu nhiên mới
bit, mạch RNG sẽ chuyển sang trạng thái năng lượng thấp. Intel sẽ
cung cấp trình điều khiển phần mềm nhị phân để cung cấp phần mềm của bên thứ ba
truy cập vào RNG của chúng tôi để sử dụng làm tính năng bảo mật. Vào lúc này,
RNG chỉ được sử dụng với hệ thống ở trạng thái hiện tại của hệ điều hành.

Ghi chú của Trình điều khiển Intel RNG
======================================

FIXME: thăm dò ủng hộ(2)

.. note::

	request_mem_region was removed, for three reasons:

	1) Only one RNG is supported by this driver;
	2) The location used by the RNG is a fixed location in
	   MMIO-addressable memory;
	3) users with properly working BIOS e820 handling will always
	   have the region in which the RNG is located reserved, so
	   request_mem_region calls always fail for proper setups.
	   However, for people who use mem=XX, BIOS e820 information is
	   **not** in /proc/iomem, and request_mem_region(RNG_ADDR) can
	   succeed.

Chi tiết tài xế
===============

Dựa trên:
	Bảng dữ liệu Trung tâm chương trình cơ sở Intel 82802AB/82802AC (FWH)
	Tháng 5 năm 1999 Số đơn hàng: 290658-002 R

Trung tâm phần mềm Intel 82802:
	Trình tạo số ngẫu nhiên
	Tài liệu tham khảo dành cho lập trình viên
	Tháng 12 năm 1999 Số đơn hàng: 298029-001 R

Trình điều khiển tạo số ngẫu nhiên Intel 82802 Firmware HUB
	Bản quyền (c) 2000 Matt Sottek <msottek@quiknet.com>

Đặc biệt cảm ơn Matt Sottek.  Tôi đã làm "ruột", anh ấy
đã thực hiện "bộ não" và tất cả các thử nghiệm.
