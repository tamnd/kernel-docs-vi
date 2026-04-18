.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/fddi/skfp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

==================================
Trình điều khiển SysKonnect - SKFP
==================================

ZZ0000ZZ Bản quyền 1998-2000 SysKonnect,

skfp.txt được tạo vào ngày 11 tháng 5 năm 2000

Tệp Readme cho skfp.o v2.06


.. This file contains

   (1) OVERVIEW
   (2) SUPPORTED ADAPTERS
   (3) GENERAL INFORMATION
   (4) INSTALLATION
   (5) INCLUSION OF THE ADAPTER IN SYSTEM START
   (6) TROUBLESHOOTING
   (7) FUNCTION OF THE ADAPTER LEDS
   (8) HISTORY


1. Tổng quan
============

README này giải thích cách sử dụng trình điều khiển 'skfp' cho Linux với
bộ điều hợp mạng.

Chương 2: Chứa danh sách tất cả các bộ điều hợp mạng được hỗ trợ bởi
người lái xe này.

Chương 3:
	   Cung cấp một số thông tin chung.

Chương 4: Mô tả các vấn đề thường gặp và giải pháp.

Chương 5: Hiển thị chức năng đã thay đổi của đèn LED bộ chuyển đổi.

Chương 6: Lịch sử phát triển.


2. Bộ điều hợp được hỗ trợ
==========================

Trình điều khiển mạng 'skfp' hỗ trợ các bộ điều hợp mạng sau:
Bộ điều hợp SysKonnect:

- SK-5521 (SK-NET FDDI-UP)
  - SK-5522 (SK-NET FDDI-UP DAS)
  - SK-5541 (SK-NET FDDI-FP)
  - SK-5543 (SK-NET FDDI-LP)
  - SK-5544 (SK-NET FDDI-LP DAS)
  - SK-5821 (SK-NET FDDI-UP64)
  - SK-5822 (SK-NET FDDI-UP64 DAS)
  - SK-5841 (SK-NET FDDI-FP64)
  - SK-5843 (SK-NET FDDI-LP64)
  - SK-5844 (SK-NET FDDI-LP64 DAS)

Bộ điều hợp Compaq (chưa được kiểm tra):

- Nettelligent 100 FDDI DAS Fiber SC
  - Nettelligent 100 FDDI SAS Fiber SC
  - Nettelligent 100 FDDI DAS UTP
  - Nettelligent 100 FDDI SAS UTP
  - Nettelligent 100 FDDI SAS Fiber MIC


3. Thông tin chung
======================

Từ v2.01 trở đi, trình điều khiển được tích hợp trong nguồn nhân Linux.
Do đó, việc cài đặt cũng giống như bất kỳ bộ chuyển đổi nào khác
được hỗ trợ bởi kernel.

Tham khảo hướng dẫn phân phối của bạn về việc cài đặt
của các bộ điều hợp mạng.

Làm cho cuộc sống của tôi dễ dàng hơn nhiều :-)

4. Khắc phục sự cố
==================

Nếu bạn gặp vấn đề trong quá trình cài đặt, hãy kiểm tra các mục đó:

Vấn đề:
	  Trình điều khiển không thể tìm thấy bộ chuyển đổi FDDI.

Lý do:
	  Tìm trong /proc/pci mục sau:

'Bộ điều khiển mạng FDDI: SysKonnect SK-FDDI-PCI ...'

Nếu mục này tồn tại thì bộ điều hợp FDDI đã được
	  được hệ thống tìm thấy và có thể sử dụng được.

Nếu mục này không tồn tại hoặc nếu tệp '/proc/pci'
	  không có ở đó thì có thể bạn gặp vấn đề về phần cứng hoặc PCI
	  hỗ trợ có thể không được kích hoạt trong kernel của bạn.

Bộ chuyển đổi có thể được kiểm tra bằng chương trình chẩn đoán
	  có sẵn từ trang web SysKonnect:

www.syskonnect.de

Một số máy COMPAQ gặp sự cố với PCI trong
	  Linux. Điều này được mô tả trong tài liệu 'PCI'
	  (được bao gồm trong một số bản phân phối hoặc có sẵn từ
	  www, ví dụ: tại 'www.linux.org') và không có cách giải quyết nào.

Vấn đề:
	  Bạn muốn sử dụng máy tính của mình làm bộ định tuyến giữa
	  nhiều mạng con IP (sử dụng nhiều bộ điều hợp), nhưng
	  bạn không thể kết nối với các máy tính ở các mạng con khác.

Lý do:
	  Nhân của bộ định tuyến không được cấu hình cho IP
	  chuyển tiếp hoặc có vấn đề với bảng định tuyến
	  và cấu hình cổng ở ít nhất một trong các
	  máy tính.

Nếu vấn đề của bạn không được liệt kê ở đây, vui lòng liên hệ với chúng tôi
hỗ trợ kỹ thuật để được giúp đỡ.

Bạn có thể gửi email đến: linux@syskonnect.de

Khi liên hệ với bộ phận hỗ trợ kỹ thuật của chúng tôi,
hãy đảm bảo rằng những thông tin sau đây có sẵn:

- Nhà sản xuất và Model hệ thống
- Bảng trong hệ thống của bạn
- Phân phối
- Phiên bản hạt nhân


5. Chức năng của đèn LED Adaptor
================================

Chức năng của LED trên bộ điều hợp mạng FDDI là
	đã thay đổi trong phiên bản SMT v2.82. Với phiên bản SMT mới này màu vàng
	LED hoạt động như một chỉ báo hoạt động của vòng. Một chiếc LED màu vàng đang hoạt động
	cho biết chiếc nhẫn đã bị hỏng. Hiện tại LED màu xanh lá cây trên bộ chuyển đổi
	hoạt động như một chỉ báo liên kết trong đó GREEN LED đang hoạt động chỉ ra rằng
	cổng tương ứng có kết nối vật lý.

Với các phiên bản SMT trước v2.82, chuông reo được biểu thị nếu
	LED màu vàng đã tắt trong khi (các) LED màu xanh lá cây hiển thị kết nối
	trạng thái của bộ chuyển đổi. Trong khi đổ chuông, LED màu xanh lá cây đã tắt và
	chiếc LED màu vàng đang bật.

Tất cả các triển khai chỉ ra rằng trình điều khiển không được tải nếu
	tất cả các đèn LED đều tắt.


6. Lịch sử
==========

v2.06 (20000511) (Phiên bản trong hạt nhân)
    Các tính năng mới:

- Hỗ trợ 64bit
	- giao diện pci dma mới
	- trong hạt nhân 2.3.99

v2.05 (20000217) (Phiên bản trong hạt nhân)
    Các tính năng mới:

- Những thay đổi cho kernel 2.3.45

v2.04 (20000207) (Phiên bản độc lập)
    Các tính năng mới:

- Đã thêm bộ đếm byte rx/tx

v2.03 (20000111) (Phiên bản độc lập)
    Các vấn đề đã được khắc phục:

- Đã sửa lỗi câu lệnh printk từ v2.02

v2.02 (991215) (Phiên bản độc lập)
    Các vấn đề đã được khắc phục:

- Loại bỏ đầu ra không cần thiết
	- Đã sửa đường dẫn cho "printver.sh" trong makefile

v2.01 (991122) (Phiên bản trong hạt nhân)
    Các tính năng mới:

- Tích hợp trong nguồn nhân Linux
	- Hỗ trợ I/O được ánh xạ bộ nhớ.

v2.00 (991112)
    Các tính năng mới:

- Nguồn đầy đủ được phát hành theo GPL

v1.05 (991023)
    Các vấn đề đã được khắc phục:

- Biên dịch với kernel phiên bản 2.2.13 không thành công

v1.04 (990427)
    Thay đổi:

- Bao gồm mô-đun SMT mới, thay đổi chức năng LED

Các vấn đề đã được khắc phục:

- Đồng bộ hóa trên máy SMP bị lỗi

v1.03 (990325)
    Các vấn đề đã được khắc phục:

- Định tuyến ngắt trên máy SMP có thể không chính xác

v1.02 (990310)
    Các tính năng mới:

- Đã thêm hỗ trợ cho phiên bản kernel 2.2.x
	- Bản vá hạt nhân thay vì bản sao riêng tư của các chức năng hạt nhân

v1.01 (980812)
    Các vấn đề đã được khắc phục:

Ngắt kết nối với telnet
	Kết nối telnet chậm

v1.00 beta 01 (980507)
    Các tính năng mới:

Không có.

Các vấn đề đã được khắc phục:

Không có.

Những hạn chế đã biết:

- lưu trữ tar thay vì định dạng gói tiêu chuẩn (rpm).
	- Thống kê FDDI trống.
	- chưa được thử nghiệm với hạt nhân 2.1.xx
	- tích hợp trong kernel chưa được kiểm tra
	- chưa được thử nghiệm đồng thời với bộ điều hợp FDDI từ các nhà cung cấp khác.
	- chỉ hỗ trợ bộ xử lý X86.
	- Có thể tham số SBA (Bộ cấp phát băng thông đồng bộ)
	  không được cấu hình.
	- không hoạt động trên một số máy COMPAQ. Xem cách thực hiện PCI
	  tài liệu để biết chi tiết về vấn đề này.
	- hỏng dữ liệu với các phiên bản kernel dưới 2.0.33.