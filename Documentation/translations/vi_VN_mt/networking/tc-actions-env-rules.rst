.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/tc-actions-env-rules.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================
Hành động TC - Quy tắc môi trường
================================


Các quy tắc "môi trường" dành cho tác giả của bất kỳ hành động tc mới nào là:

1) Nếu bạn ăn trộm hoặc mượn bất kỳ gói nào, bạn sẽ phân nhánh
   từ con đường chính nghĩa và bạn sẽ nhân bản.

Ví dụ: nếu hành động của bạn xếp hàng một gói để xử lý sau,
   hoặc cố ý phân nhánh bằng cách chuyển hướng gói tin, thì bạn cần phải
   nhân bản gói tin.

2) Nếu bạn trộn bất kỳ gói nào, bạn sẽ gọi pskb_expand_head trong trường hợp này
   ai đó đang tham khảo skb. Sau đó bạn "sở hữu" skb.

3) Việc đánh rơi các gói tin bạn không sở hữu là điều không nên. Bạn chỉ cần quay lại
   TC_ACT_SHOT cho người gọi và họ sẽ bỏ nó.

Các quy tắc "môi trường" dành cho người gọi hành động (qdiscs, v.v.) là:

#) Bạn có trách nhiệm giải phóng bất cứ thứ gì được trả lại như
   TC_ACT_SHOT/STOLEN/QUEUED. Nếu không có TC_ACT_SHOT/STOLEN/QUEUED nào được
   được trả về thì tất cả đều tuyệt vời và bạn không cần phải làm gì cả.

Đăng lên netdev nếu có điều gì đó không rõ ràng.