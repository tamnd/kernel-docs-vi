.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/demux.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _dvb_demux:

#########################
Digital Thiết bị giải mã TV
#######################

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