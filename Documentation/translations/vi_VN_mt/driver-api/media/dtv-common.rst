.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/dtv-common.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Truyền hình kỹ thuật số Chức năng chung
---------------------------------------

Thiết bị DVB
~~~~~~~~~~~~

Các chức năng này chịu trách nhiệm xử lý các nút thiết bị DVB.

.. kernel-doc:: include/media/dvbdev.h

Bộ đệm vòng truyền hình kỹ thuật số
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Những quy trình đó thực hiện các bộ đệm vòng được sử dụng để xử lý dữ liệu truyền hình kỹ thuật số và
sao chép nó từ/đến không gian người dùng.

.. note::

  1) For performance reasons read and write routines don't check buffer sizes
     and/or number of bytes free/available. This has to be done before these
     routines are called. For example:

   .. code-block:: c

        /* write @buflen: bytes */
        free = dvb_ringbuffer_free(rbuf);
        if (free >= buflen)
                count = dvb_ringbuffer_write(rbuf, buffer, buflen);
        else
                /* do something */

        /* read min. 1000, max. @bufsize: bytes */
        avail = dvb_ringbuffer_avail(rbuf);
        if (avail >= 1000)
                count = dvb_ringbuffer_read(rbuf, buffer, min(avail, bufsize));
        else
                /* do something */

  2) If there is exactly one reader and one writer, there is no need
     to lock read or write operations.
     Two or more readers must be locked against each other.
     Flushing the buffer counts as a read operation.
     Resetting the buffer counts as a read and write operation.
     Two or more writers must be locked against each other.

.. kernel-doc:: include/media/dvb_ringbuffer.h

Bộ xử lý TV kỹ thuật số VB2
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. kernel-doc:: include/media/dvb_vb2.h