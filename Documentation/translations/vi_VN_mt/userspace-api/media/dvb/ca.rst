.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/ca.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _dvb_ca:

######################
Digital TV CA Thiết bị
####################

Thiết bị Digital TV CA điều khiển phần cứng truy cập có điều kiện. Nó
có thể được truy cập thông qua ZZ0000ZZ. Các kiểu dữ liệu và ioctl
các định nghĩa có thể được truy cập bằng cách đưa ZZ0001ZZ vào
ứng dụng.

.. note::

   There are three ioctls at this API that aren't documented:
   :ref:`CA_GET_MSG`, :ref:`CA_SEND_MSG` and :ref:`CA_SET_DESCR`.
   Documentation for them are welcome.

.. toctree::
    :maxdepth: 1

    ca_data_types
    ca_function_calls
    ca_high_level