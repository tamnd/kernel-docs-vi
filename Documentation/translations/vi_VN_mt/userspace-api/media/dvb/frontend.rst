.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/frontend.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _dvb_frontend:

########################
Digital Giao diện người dùng TV API
#######################

Giao diện truyền hình kỹ thuật số API được thiết kế để hỗ trợ ba nhóm phân phối
Hệ thống: Mặt đất, cáp và vệ tinh. Hiện tại, sau đây
hệ thống phân phối được hỗ trợ:

- Hệ thống trên mặt đất: DVB-T, DVB-T2, ATSC, ATSC M/H, ISDB-T, DVB-H,
   DTMB, CMMB

- Hệ thống cáp: DVB-C Phụ lục A/C, ClearQAM (DVB-C Phụ lục B)

- Hệ thống vệ tinh: DVB-S, DVB-S2, DVB Turbo, ISDB-S, DSS

Giao diện TV Kỹ thuật số điều khiển một số thiết bị phụ bao gồm:

- Bộ chỉnh

- Bộ giải mã truyền hình kỹ thuật số

- Bộ khuếch đại tiếng ồn thấp (LNA)

- Điều khiển thiết bị vệ tinh (SEC) [#f1]_.

Giao diện người dùng có thể được truy cập thông qua ZZ0000ZZ.
Các kiểu dữ liệu và định nghĩa ioctl có thể được truy cập bằng cách bao gồm
ZZ0001ZZ trong ứng dụng của bạn.

.. note::

   Transmission via the internet (DVB-IP) and MMT (MPEG Media Transport)
   is not yet handled by this API but a future extension is possible.

.. [#f1]

   On Satellite systems, the API support for the Satellite Equipment
   Control (SEC) allows to power control and to send/receive signals to
   control the antenna subsystem, selecting the polarization and choosing
   the Intermediate Frequency IF) of the Low Noise Block Converter Feed
   Horn (LNBf). It supports the DiSEqC and V-SEC protocols. The DiSEqC
   (digital SEC) specification is available at
   `Eutelsat <http://www.eutelsat.com/satellites/4_5_5.html>`__.


.. toctree::
    :maxdepth: 1

    query-dvb-frontend-info
    dvb-fe-read-status
    dvbproperty
    frontend_fcalls