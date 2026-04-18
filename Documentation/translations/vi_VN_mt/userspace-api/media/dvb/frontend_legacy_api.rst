.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/frontend_legacy_api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _frontend_legacy_types:

Các kiểu dữ liệu kế thừa của Frontend
==========================


.. toctree::
    :maxdepth: 1

    fe-type-t
    fe-bandwidth-t
    dvb-frontend-parameters
    dvb-frontend-event


.. _frontend_legacy_fcalls:

Lệnh gọi hàm kế thừa Frontend
==============================

Các chức năng này được xác định tại DVB phiên bản 3. Phần hỗ trợ được giữ trong
kernel chỉ do vấn đề tương thích. Cách sử dụng của họ mạnh mẽ không
đề nghị


.. toctree::
    :maxdepth: 1

    fe-read-ber
    fe-read-snr
    fe-read-signal-strength
    fe-read-uncorrected-blocks
    fe-set-frontend
    fe-get-frontend
    fe-get-event
    fe-dishnetwork-send-legacy-cmd