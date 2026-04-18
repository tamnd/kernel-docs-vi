.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/input/notifier.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Trình thông báo bàn phím
=================

Người ta có thể sử dụng register_keyboard_notifier để được gọi lại trên bàn phím
sự kiện (xem hàm kbd_keycode() để biết chi tiết).  Cấu trúc được thông qua là
keyboard_notifier_param (xem <linux/keyboard.h>):

- 'vc' luôn cung cấp VC áp dụng cho sự kiện bàn phím;
- 'xuống' là 1 đối với sự kiện nhấn phím, 0 đối với nhả phím;
- 'shift' là trạng thái sửa đổi hiện tại, chỉ số bit mặt nạ là KG_*;
- 'ledstate' là trạng thái LED hiện tại;
- 'giá trị' phụ thuộc vào loại sự kiện.

- Sự kiện KBD_KEYCODE luôn được gửi trước các sự kiện khác, giá trị là keycode.
- Các sự kiện KBD_UNBOUND_KEYCODE được gửi nếu mã khóa không bị ràng buộc với một keysym.
  giá trị là mã khóa.
- Các sự kiện KBD_UNICODE được gửi nếu mã khóa -> bản dịch keysym tạo ra một
  ký tự unicode. giá trị là giá trị unicode.
- Các sự kiện KBD_KEYSYM được gửi nếu mã khóa -> bản dịch keysym tạo ra một
  ký tự không phải unicode. giá trị là keyym.
- Các sự kiện KBD_POST_KEYSYM được gửi sau khi xử lý các keysym không unicode.
  Điều đó cho phép người ta kiểm tra các đèn LED thu được chẳng hạn.

Đối với từng loại sự kiện ngoại trừ loại sự kiện cuối cùng, lệnh gọi lại có thể trả về NOTIFY_STOP trong
để "ăn" sự kiện: vòng lặp thông báo bị dừng và sự kiện bàn phím được
bị rơi.

Trong đoạn mã C thô, chúng ta có::

kbd_keycode(mã khóa) {
	...
params.value = mã khóa;
	if (notifier_call_chain(KBD_KEYCODE,&params) == NOTIFY_STOP)
	    || !ràng buộc) {
		notifier_call_chain(KBD_UNBOUND_KEYCODE,&params);
		trở lại;
	}

nếu (unicode) {
		param.value = unicode;
		if (notifier_call_chain(KBD_UNICODE,&params) == NOTIFY_STOP)
			trở lại;
		phát ra unicode;
		trở lại;
	}

params.value = keyym;
	if (notifier_call_chain(KBD_KEYSYM,&params) == NOTIFY_STOP)
		trở lại;
	áp dụng keysym;
	notifier_call_chain(KBD_POST_KEYSYM,&params);
    }

.. note:: This notifier is usually called from interrupt context.
