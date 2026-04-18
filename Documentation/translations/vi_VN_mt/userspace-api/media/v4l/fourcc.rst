.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/fourcc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

Hướng dẫn về định dạng pixel 4CC của Video4Linux
============================================

Nguyên tắc dành cho mã Video4Linux 4CC được xác định bằng v4l2_fourcc() là
quy định trong tài liệu này. Ký tự đầu tiên xác định bản chất của
định dạng pixel, độ nén và không gian màu. Việc giải nghĩa của
ba ký tự còn lại phụ thuộc vào ký tự đầu tiên.

4CC hiện tại có thể không tuân theo những nguyên tắc này.

Bayer thô
---------

Các ký tự đầu tiên sau đây được sử dụng bởi các định dạng bayer thô:

- B: bayer thô, không nén
- b: bayer thô, nén DPCM
- a: Luật A nén
-u: u-luật nén

Ký tự thứ 2: thứ tự pixel

-B: BGGR
-G: GBRG
- g: GRBG
-R: RGGB

Ký tự thứ 3: số bit trên mỗi pixel không nén 0--9, A--

Ký tự thứ 4: số bit được nén trên mỗi pixel 0--9, A--