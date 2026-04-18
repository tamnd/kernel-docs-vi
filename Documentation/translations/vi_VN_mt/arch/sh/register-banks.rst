.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/sh/register-banks.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================================
Lưu ý về việc sử dụng ngân hàng đăng ký trong kernel
====================================================

Giới thiệu
------------

Các dòng SH-3 và SH-4 CPU theo truyền thống bao gồm một thanh ghi một phần
ngân hàng (được chọn bởi SR.RB, chỉ r0 ... r7 được ngân hàng), trong khi các họ khác
có thể có nhiều tính năng ngân hàng hơn hoặc đơn giản là không có khả năng nào như vậy.

Ngân hàng SR.RB
---------------

Trong trường hợp của loại hình ngân hàng này, các sổ đăng ký ngân hàng được ánh xạ trực tiếp tới
r0 ... r7 nếu SR.RB được đặt thành ngân hàng mà chúng tôi quan tâm, nếu không thì ldc/stc
vẫn có thể được sử dụng để tham chiếu các thanh ghi ngân hàng (như r0_bank ... r7_bank)
khi ở trong bối cảnh của một ngân hàng khác. Nhà phát triển phải giữ giá trị SR.RB
cần lưu ý khi viết mã sử dụng các thanh ghi được xếp thành dãy này, rõ ràng là
lý do. Không gian người dùng cũng không thể truy cập vào các giá trị của ngân hàng1, vì vậy những giá trị này có thể
được sử dụng khá hiệu quả như các thanh ghi đầu của kernel.

Hiện tại kernel sử dụng một số thanh ghi này.

- r0_bank, r1_bank (được tham chiếu là k0 và k1, dùng để cào
	  đăng ký khi thực hiện xử lý ngoại lệ).

- r2_bank (dùng để theo dõi mã EXPEVT/INTEVT)

- Được sử dụng bởi do_IRQ() và bạn bè để thực hiện ánh xạ irq dựa trên
		  của phần bù của bảng nhảy ngoại lệ ngắt

- r6_bank (mặt nạ ngắt toàn cầu)

- Trình xử lý ngắt SR.IMASK sử dụng điều này để thiết lập
		  mức độ ưu tiên ngắt (được sử dụng bởi local_irq_enable())

- r7_bank (hiện tại)