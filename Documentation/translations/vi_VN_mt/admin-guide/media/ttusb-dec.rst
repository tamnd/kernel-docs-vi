.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/ttusb-dec.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển TechnoTrend/Hauppauge DEC USB
==============================================

Trạng thái trình điều khiển
---------------------------

Được hỗ trợ:

-DEC2000-t
	- DEC2450-t
	- DEC3000-s
	- Truyền phát video
	- Truyền phát âm thanh
	- Bộ lọc phần
	- Chuyển đổi kênh
	- Trình tải chương trình cơ sở cắm nóng

Việc cần làm:

- Thông tin trạng thái bộ chỉnh
	- Giao diện mạng DVB
	- Truyền phát video trên PC->DEC
	- Hỗ trợ Conax cho 2450-t

Lấy phần sụn
--------------------
Để tải xuống chương trình cơ sở, sử dụng các lệnh sau:

.. code-block:: none

	scripts/get_dvb_firmware dec2000t
	scripts/get_dvb_firmware dec2540t
	scripts/get_dvb_firmware dec3000s


Đang tải chương trình cơ sở Hotplug
-----------------------------------

Vì hạt nhân 2.6, phần sụn được tải tại thời điểm mô-đun trình điều khiển
được tải.

Sao chép ba tệp đã tải xuống ở trên vào /usr/lib/hotplug/firmware hoặc
thư mục /lib/firmware (tùy thuộc vào cấu hình của hotplug firmware).