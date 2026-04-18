.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/fe-type-t.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

*************
Loại giao diện người dùng
*************

Vì lý do lịch sử, các loại giao diện người dùng được đặt tên theo loại
điều chế được sử dụng trong truyền dẫn. Các loại fontend được đưa ra bởi
loại fe_type_t, được định nghĩa là:


.. c:type:: fe_type

.. tabularcolumns:: |p{6.6cm}|p{2.2cm}|p{8.5cm}|

.. flat-table:: Frontend types
    :header-rows:  1
    :stub-columns: 0
    :widths:       3 1 4


    -  .. row 1

       -  fe_type

       -  Description

       -  :ref:`DTV_DELIVERY_SYSTEM <DTV-DELIVERY-SYSTEM>` equivalent
	  type

    -  .. row 2

       -  .. _FE-QPSK:

	  ``FE_QPSK``

       -  For DVB-S standard

       -  ``SYS_DVBS``

    -  .. row 3

       -  .. _FE-QAM:

	  ``FE_QAM``

       -  For DVB-C annex A standard

       -  ``SYS_DVBC_ANNEX_A``

    -  .. row 4

       -  .. _FE-OFDM:

	  ``FE_OFDM``

       -  For DVB-T standard

       -  ``SYS_DVBT``

    -  .. row 5

       -  .. _FE-ATSC:

	  ``FE_ATSC``

       -  For ATSC standard (terrestrial) or for DVB-C Annex B (cable) used
	  in US.

       -  ``SYS_ATSC`` (terrestrial) or ``SYS_DVBC_ANNEX_B`` (cable)


Các định dạng mới hơn như DVB-S2, ISDB-T, ISDB-S và DVB-T2 không được mô tả
ở trên, vì chúng được hỗ trợ thông qua giao diện mới
ZZ0000ZZ
ioctl's, sử dụng ZZ0001ZZ
tham số.

Ngày xưa struct ZZ0000ZZ
được sử dụng để chứa trường ZZ0002ZZ để biểu thị hệ thống phân phối,
chứa đầy ZZ0003ZZ hoặc ZZ0004ZZ. Trong khi điều này
vẫn được điền để giữ khả năng tương thích ngược, việc sử dụng trường này
không được dùng nữa vì nó có thể chỉ báo cáo một hệ thống phân phối, nhưng một số
thiết bị hỗ trợ nhiều hệ thống phân phối. Vui lòng sử dụng
Thay vào đó là ZZ0001ZZ.

Trên các thiết bị hỗ trợ nhiều hệ thống phân phối, struct
ZZ0000ZZ::ZZ0003ZZ là
chứa đầy tiêu chuẩn hiện tại, như được chọn bởi lệnh gọi cuối cùng tới
ZZ0001ZZ sử dụng
Thuộc tính ZZ0002ZZ.