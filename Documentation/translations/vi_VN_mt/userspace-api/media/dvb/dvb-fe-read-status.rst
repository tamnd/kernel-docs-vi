.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/dvb-fe-read-status.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _dvb-fe-read-status:

****************************************************
Truy vấn trạng thái và thống kê giao diện người dùng
****************************************************

Khi ZZ0000ZZ được gọi,
giao diện người dùng sẽ chạy một luồng kernel sẽ kiểm tra định kỳ
trạng thái khóa bộ điều chỉnh và cung cấp số liệu thống kê về chất lượng của
tín hiệu.

Thông tin về trạng thái khóa bộ điều chỉnh giao diện người dùng có thể được truy vấn
sử dụng ZZ0000ZZ.

Thống kê tín hiệu được cung cấp thông qua
ZZ0000ZZ.

.. note::

   Most statistics require the demodulator to be fully locked
   (e. g. with :c:type:`FE_HAS_LOCK <fe_status>` bit set). See
   :ref:`Frontend statistics indicators <frontend-stat-properties>` for
   more details.