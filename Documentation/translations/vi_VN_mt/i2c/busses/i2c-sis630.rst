.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/i2c/busses/i2c-sis630.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Trình điều khiển hạt nhân i2c-sis630
========================

Bộ điều hợp được hỗ trợ:
  * Tập đoàn Hệ thống Tích hợp Silicon (SiS)
	Chipset 630 (Bảng dữ liệu: có tại ZZ0000ZZ
	730 chipset
	964 chipset
  * Có thể có các chipset SiS khác?

tác giả:
        - Alexander Malysh <amalysh@web.de>
	- Amaury Decrême <amaury.decreme@gmail.com> - Hỗ trợ SiS964

Thông số mô-đun
-----------------

=============================================================================
Force = [1|0] Buộc kích hoạt SIS630. DANGEROUS!
                        Điều này có thể thú vị đối với các chipset không được đặt tên
                        ở trên để kiểm tra xem nó có hoạt động với chipset của bạn không,
                        nhưng DANGEROUS!

high_clock = [1|0] Buộc đặt Đồng hồ chính của máy chủ thành 56KHz (mặc định,
			BIOS của bạn sử dụng những gì). DANGEROUS! Điều này sẽ có một chút
			nhanh hơn nhưng đóng băng một số hệ thống (tức là Máy tính xách tay của tôi).
			Chỉ chip SIS630/730.
=============================================================================


Sự miêu tả
-----------

Trình điều khiển duy nhất SMBus này được biết là hoạt động trên các bo mạch chủ có cấu hình trên
chipset được đặt tên.

Nếu bạn thấy một cái gì đó như thế này ::

00:00.0 Cầu nối máy chủ: Hệ thống tích hợp Silicon [SiS] 630 Host (rev 31)
  00:01.0 Cầu ISA: Hệ thống tích hợp silicon [SiS] 85C503/5513

hoặc như thế này::

00:00.0 Cầu nối máy chủ: Hệ thống tích hợp Silicon [SiS] 730 Host (rev 02)
  00:01.0 Cầu ISA: Hệ thống tích hợp silicon [SiS] 85C503/5513

hoặc như thế này::

00:00.0 Cầu chủ: Hệ thống tích hợp Silicon [SiS] 760/M760 Host (rev 02)
  00:02.0 Cầu ISA: Hệ thống tích hợp silicon [SiS] SiS964 [MuTIOL Media IO]
							Bộ điều khiển LPC (rev 36)

trong đầu ra ZZ0000ZZ của bạn, thì trình điều khiển này dành cho chipset của bạn.

Cảm ơn
---------
Philip Edelbrock <phil@netroedge.com>
- thử nghiệm hỗ trợ SiS730
Mark M. Hoffman <mhoffman@lightlink.com>
- sửa lỗi

Gửi tới bất kỳ ai khác mà tôi đã quên ở đây;), cảm ơn!
