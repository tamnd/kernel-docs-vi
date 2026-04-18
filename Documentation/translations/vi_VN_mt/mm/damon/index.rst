.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/mm/damon/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

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