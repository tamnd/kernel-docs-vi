.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/cec/cec-ioc-adap-g-conn-info.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

............................
.. Copyright 2019 Google LLC
............................
.. c:namespace:: CEC

.. _CEC_ADAP_G_CONNECTOR_INFO:

*******************************
ioctl CEC_ADAP_G_CONNECTOR_INFO
*******************************

Tên
====

CEC_ADAP_G_CONNECTOR_INFO - Truy vấn thông tin đầu nối HDMI

Tóm tắt
========

.. c:macro:: CEC_ADAP_G_CONNECTOR_INFO

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ

Sự miêu tả
===========

Sử dụng ioctl này, một ứng dụng có thể tìm hiểu trình kết nối HDMI nào CEC này
thiết bị tương ứng với. Trong khi gọi ioctl này, ứng dụng sẽ
cung cấp một con trỏ tới cấu trúc cec_connector_info sẽ được điền
bởi kernel với thông tin được cung cấp bởi trình điều khiển của bộ điều hợp. ioctl này
chỉ khả dụng nếu khả năng ZZ0000ZZ được đặt.

.. tabularcolumns:: |p{1.0cm}|p{4.4cm}|p{2.5cm}|p{9.2cm}|

.. c:type:: cec_connector_info

.. flat-table:: struct cec_connector_info
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 8

    * - __u32
      - ``type``
      - The type of connector this adapter is associated with.
    * - union {
      - ``(anonymous)``
    * - ``struct cec_drm_connector_info``
      - drm
      - :ref:`cec-drm-connector-info`
    * - }
      -

.. tabularcolumns:: |p{4.4cm}|p{2.5cm}|p{10.4cm}|

.. _connector-type:

.. flat-table:: Connector types
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 8

    * .. _`CEC-CONNECTOR-TYPE-NO-CONNECTOR`:

      - ``CEC_CONNECTOR_TYPE_NO_CONNECTOR``
      - 0
      - No connector is associated with the adapter/the information is not
        provided by the driver.
    * .. _`CEC-CONNECTOR-TYPE-DRM`:

      - ``CEC_CONNECTOR_TYPE_DRM``
      - 1
      - Indicates that a DRM connector is associated with this adapter.
        Information about the connector can be found in
	:ref:`cec-drm-connector-info`.

.. tabularcolumns:: |p{4.4cm}|p{2.5cm}|p{10.4cm}|

.. c:type:: cec_drm_connector_info

.. _cec-drm-connector-info:

.. flat-table:: struct cec_drm_connector_info
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 8

    * .. _`CEC-DRM-CONNECTOR-TYPE-CARD-NO`:

      - __u32
      - ``card_no``
      - DRM card number: the number from a card's path, e.g. 0 in case of
        /dev/card0.
    * .. _`CEC-DRM-CONNECTOR-TYPE-CONNECTOR_ID`:

      - __u32
      - ``connector_id``
      - DRM connector ID.