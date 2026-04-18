.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/RAS/error-decoding.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Giải mã lỗi
==============

x86
---

Việc giải mã lỗi trên hệ thống AMD nên được thực hiện bằng công cụ rasdaemon:
ZZ0000ZZ

Trong khi daemon đang chạy, nó sẽ tự động ghi lại và giải mã
lỗi. Nếu không, người ta vẫn có thể giải mã các lỗi đó bằng cách cung cấp
thông tin phần cứng từ lỗi::

$ rasdaemon -p --status <STATUS> --ipid <IPID> --smca

Ngoài ra, người dùng có thể chuyển họ và mô hình cụ thể để giải mã lỗi
chuỗi::

$ rasdaemon -p --status <STATUS> --ipid <IPID> --smca --family <CPU Family> --model <CPU Model> --bank <BANK_NUM>