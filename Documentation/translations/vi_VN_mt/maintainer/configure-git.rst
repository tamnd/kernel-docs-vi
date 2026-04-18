.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/maintainer/configure-git.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Định cấu hình Git
=================

Chương này mô tả cấu hình git cấp độ người bảo trì.

Các nhánh được gắn thẻ được sử dụng trong các yêu cầu kéo (xem
Tài liệu/người bảo trì/pull-requests.rst) phải được ký với
nhà phát triển khóa GPG công khai. Thẻ đã ký có thể được tạo bằng cách chuyển
ZZ0000ZZ đến ZZ0001ZZ. Tuy nhiên, vì bạn sẽ sử dụng ZZ0004ZZ tương tự
key cho dự án, bạn có thể đặt nó trong cấu hình và sử dụng ZZ0002ZZ
cờ. Để đặt ZZ0003ZZ mặc định, hãy sử dụng ::

git config user.signingkey "tên khóa"

Ngoài ra, hãy chỉnh sửa tệp ZZ0000ZZ hoặc ZZ0001ZZ của bạn bằng tay::

[người dùng]
		tên = Nhà phát triển Jane
		email = jd@domain.org
		khóa ký = jd@domain.org

Bạn có thể cần yêu cầu ZZ0000ZZ sử dụng ZZ0001ZZ::

[gpg]
		chương trình = /path/to/gpg2

Bạn cũng có thể muốn cho ZZ0000ZZ biết nên sử dụng ZZ0001ZZ nào (thêm vào shell của bạn
tập tin RC)::

xuất GPG_TTY=$(tty)
