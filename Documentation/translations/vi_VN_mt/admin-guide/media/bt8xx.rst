.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/bt8xx.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================
Làm cách nào để thẻ bt8xx hoạt động
==================================

tác giả:
	 Richard Walker,
	 Jamie Honan,
	 Michael Hunold,
	 Manu Abraham,
	 Uwe Bugla,
	 Michael Krufky

Thông tin chung
-------------------

Loại thẻ này có bt878a là giao diện PCI và yêu cầu bttv
trình điều khiển để truy cập bus i2c và các chân gpio của chipset bt8xx.

Vui lòng xem Tài liệu/admin-guide/media/bttv-cardlist.rst để biết thông tin đầy đủ
danh sách các Thẻ dựa trên cầu Conexant Bt8xx PCI được hỗ trợ bởi
Hạt nhân Linux.

Để có thể biên dịch kernel, cần có một số tùy chọn cấu hình
đã bật::

./scripts/config -e PCI
    ./scripts/config -e INPUT
    ./scripts/config -m I2C
    ./scripts/config -m MEDIA_SUPPORT
    ./scripts/config -e MEDIA_PCI_SUPPORT
    ./scripts/config -e MEDIA_ANALOG_TV_SUPPORT
    ./scripts/config -e MEDIA_DIGITAL_TV_SUPPORT
    ./scripts/config -e MEDIA_RADIO_SUPPORT
    ./scripts/config -e RC_CORE
    ./scripts/config -m VIDEO_BT848
    ./scripts/config -m DVB_BT8XX

Nếu bạn muốn tự động hỗ trợ tất cả các biến thể có thể có của Bt8xx
thẻ, bạn cũng nên làm::

./scripts/config -e MEDIA_SUBDRV_AUTOSELECT

.. note::

   Please use the following options with care as deselection of drivers which
   are in fact necessary may result in DVB devices that cannot be tuned due
   to lack of driver support.

Nếu mục tiêu của bạn chỉ là hỗ trợ một hội đồng cụ thể, thay vào đó, bạn có thể:
vô hiệu hóa MEDIA_SUBDRV_AUTOSELECT và chọn trình điều khiển lối vào theo cách thủ công
được yêu cầu bởi hội đồng quản trị của bạn. Với điều đó, bạn có thể tiết kiệm một số RAM.

Bạn có thể làm điều đó bằng cách gọi make xconfig/qconfig/menuconfig và xem
các tùy chọn trên các tùy chọn menu đó (chỉ được bật nếu
ZZ0000ZZ bị vô hiệu hóa:

#) ZZ0000ZZ => ZZ0001ZZ => ZZ0002ZZ
#) ZZ0003ZZ => ZZ0004ZZ => ZZ0005ZZ

Sau đó, trên mỗi menu ở trên, vui lòng chọn thẻ cụ thể của bạn
mô-đun giao diện người dùng và bộ điều chỉnh.


Đang tải mô-đun
---------------

Trường hợp thông thường: Nếu trình điều khiển bttv phát hiện thẻ DVB dựa trên bt8xx, tất cả
các mô-đun frontend và backend sẽ được tải tự động.

Ngoại lệ là:

- Thẻ TV cũ không có EEPROM, chia sẻ ID hệ thống con PCI chung;
- Thẻ TwinHan DST cũ hoặc bản sao có hoặc không có khe cắm CA và không
  chứa Eeprom.

Trong các trường hợp sau, ghi đè tính năng phát hiện loại PCI cho bttv và
đối với trình điều khiển dvb-bt8xx bằng cách chuyển các tham số modprobe có thể cần thiết.

Chạy TwinHan và bản sao
~~~~~~~~~~~~~~~~~~~~~~~~~~

Như được hiển thị tại Tài liệu/admin-guide/media/bttv-cardlist.rst, TwinHan và
bản sao sử dụng tham số modprobe ZZ0000ZZ. Vì vậy, để thực hiện đúng
phát hiện nó đối với các thiết bị không có EEPROM, bạn nên sử dụng ::

$ modprobe thẻ bttv=113
	$ modprobe dst

Các tham số hữu ích cho mức độ chi tiết và gỡ lỗi mô-đun dst ::

tiết = 0: tin nhắn bị tắt
		1: chỉ hiển thị thông báo lỗi
		2: thông báo được hiển thị
		3: các thông báo hữu ích khác được hiển thị
		4: cài đặt gỡ lỗi
	dst_addons=0: thẻ chỉ là thẻ miễn phí (FTA)
		0x20: thẻ có khe truy cập có điều kiện cho các kênh được mã hóa
	dst_algo=0: (mặc định) Thuật toán điều chỉnh phần mềm
	         1: Thuật toán điều chỉnh phần cứng


Các giá trị được tự động phát hiện được xác định bởi "chuỗi phản hồi" của thẻ.

Trong nhật ký của bạn, hãy xem f. ví dụ: dst_get_device_id: Nhận dạng [DSTMCI].

Để báo cáo lỗi, vui lòng gửi nhật ký đầy đủ có kích hoạt chi tiết=4.
Vui lòng xem thêm Tài liệu/admin-guide/media/ci.rst.

Chạy nhiều thẻ
~~~~~~~~~~~~~~~~~~~~~~

Xem Tài liệu/admin-guide/media/bttv-cardlist.rst để biết danh sách đầy đủ
ID thẻ. Một số ví dụ:

============================= ===
	ID tên thương hiệu
	============================= ===
	Đỉnh cao PCTV Thứ bảy 94
	Tinh Vân Điện Tử Digi TV 104
	pcHDTV HD-2000 tivi 112
	Twinhan DST và bản sao 113
	Avermedia AverTV DVB-T 77: 123
	Avermedia AverTV DVB-T 761 124
	DViCO FusionHDTV DVB-T Lite 128
	DViCO FusionHDTV 5 Lite 135
	============================= ===

.. note::

   When you have multiple cards, the order of the card ID should
   match the order where they're detected by the system. Please notice
   that removing/inserting other PCI cards may change the detection
   order.

Ví dụ::

$ modprobe thẻ bttv=113 thẻ=135

Trong trường hợp có thêm vấn đề xin vui lòng đăng ký và gửi câu hỏi đến
danh sách gửi thư: linux-media@vger.kernel.org.

Thăm dò các thẻ có ID hệ thống con PCI bị hỏng
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Có một số thẻ TwinHan có EEPROM đã bị hỏng trong một số trường hợp.
lý do. Các thẻ không có ID hệ thống con PCI chính xác.
Tuy nhiên, vẫn có thể buộc thăm dò thẻ bằng ::

$ echo 109e 0878 $subvendor $subdevice > \
		/sys/bus/pci/drivers/bt878/new_id

Hai số đó là::

109e: PCI_VENDOR_ID_BROOKTREE
	0878: PCI_DEVICE_ID_BROOKTREE_878