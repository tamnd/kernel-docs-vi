.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/demux.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _dvb_demux:

###########################
Digital Thiết bị giải mã TV
###########################

Thiết bị demux TV kỹ thuật số điều khiển các bộ lọc MPEG-TS cho
truyền hình kỹ thuật số. Nếu trình điều khiển và phần cứng hỗ trợ, những bộ lọc đó sẽ
được thực hiện ở phần cứng. Mặt khác, Kernel cung cấp một phần mềm
thi đua.

Nó có thể được truy cập thông qua ZZ0000ZZ. Các kiểu dữ liệu và
định nghĩa ioctl có thể được truy cập bằng cách đưa ZZ0001ZZ vào
ứng dụng của bạn.


.. toctree::
    :maxdepth: 1

    dmx_types
    dmx_fcalls