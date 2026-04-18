.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/usb/ohci.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====
OHCI
====

23-08-2002

Trình điều khiển "ohci-hcd" là Trình điều khiển bộ điều khiển máy chủ USB (HCD) có nguồn gốc
từ trình điều khiển "usb-ohci" từ dòng hạt nhân 2.4.  Mã "usb-ohci"
được viết chủ yếu bởi Roman Weissgaerber <weissg@vienna.at> nhưng với
đóng góp từ nhiều người khác (đọc tiêu đề bản quyền/cấp phép của nó).

Nó hỗ trợ "Giao diện điều khiển máy chủ mở" (OHCI), tiêu chuẩn hóa
giao thức thanh ghi phần cứng được sử dụng để giao tiếp với bộ điều khiển máy chủ USB 1.1.  Như
so với "Giao diện bộ điều khiển máy chủ chung" (UHCI) trước đó từ
Intel, nó đẩy nhiều trí thông minh hơn vào phần cứng.  Bộ điều khiển USB 1.1
từ các nhà cung cấp khác ngoài Intel và VIA thường sử dụng OHCI.

Những thay đổi kể từ kernel 2.4 bao gồm

- độ bền được cải thiện; sửa lỗi; và ít chi phí hơn
	- hỗ trợ các API usbcore được cập nhật và đơn giản hóa
	- chuyển giao ngắt có thể lớn hơn và có thể được xếp hàng đợi
	- ít mã hơn, bằng cách sử dụng khung "hcd" cấp cao hơn
	- hỗ trợ một số triển khai PCI không phải OHCI
	- ... thêm

Trình điều khiển "ohci-hcd" xử lý tất cả các kiểu truyền USB 1.1.  Chuyển nhượng tất cả
các loại có thể được xếp hàng đợi.  Điều đó cũng đúng trong "usb-ohci", ngoại trừ ngắt
chuyển khoản.  Trước đây, việc sử dụng các khoảng thời gian của một khung có nguy cơ mất dữ liệu do
chi phí cao trong quá trình xử lý IRQ.  Khi các chuyển giao ngắt được xếp hàng đợi, chúng
rủi ro có thể được giảm thiểu bằng cách đảm bảo phần cứng luôn được chuyển sang
hoạt động trong khi hệ điều hành đang tiến hành xử lý IRQ có liên quan.

- David Brownell
  <dbronell@users.sourceforge.net>
