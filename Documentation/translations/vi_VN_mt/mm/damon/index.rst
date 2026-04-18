.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/mm/damon/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================================================================
DAMON: Hoạt động hệ thống giám sát truy cập dữ liệu và nhận biết quyền truy cập
================================================================

DAMON là hệ thống con nhân Linux dành cho ZZ0000ZZ và ZZ0001ZZ hiệu quả.  Nó được thiết kế để

- ZZ0000ZZ (để quản lý bộ nhớ cấp DRAM),
 - ZZ0001ZZ (dành cho sản xuất trực tuyến),
 - ZZ0002ZZ (về kích thước bộ nhớ),
 - ZZ0003ZZ (để sử dụng linh hoạt) và
 - ZZ0004ZZ (dành cho hoạt động sản xuất mà không cần điều chỉnh thủ công).

.. toctree::
   :maxdepth: 2

   faq
   design
   api
   maintainer-profile

Để sử dụng và kiểm soát DAMON từ không gian người dùng, vui lòng tham khảo
quản trị ZZ0000ZZ.

Nếu bạn thích đọc và trích dẫn các bài báo học thuật hơn, vui lòng sử dụng các bài báo
từ ZZ0000ZZ và
ZZ0001ZZ.
Lưu ý rằng những điều đó bao gồm việc triển khai DAMON trong Linux v5.16 và v5.15,
tương ứng.