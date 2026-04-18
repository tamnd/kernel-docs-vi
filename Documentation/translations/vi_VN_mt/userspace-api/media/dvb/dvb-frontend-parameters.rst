.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/dvb-frontend-parameters.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:type:: dvb_frontend_parameters

*******************
thông số giao diện người dùng
*******************

Loại tham số được truyền tới thiết bị giao diện người dùng để điều chỉnh tùy thuộc vào
về loại phần cứng bạn đang sử dụng.

Cấu trúc ZZ0001ZZ sử dụng một liên kết với các đặc tính cụ thể
các tham số trên mỗi hệ thống. Tuy nhiên, vì các hệ thống phân phối mới hơn đòi hỏi nhiều
dữ liệu, kích thước cấu trúc không đủ để vừa và chỉ mở rộng
size sẽ phá vỡ các ứng dụng hiện có. Vì vậy, những thông số đó đã
được thay thế bằng việc sử dụng
ZZ0000ZZ
của ioctl. API mới đủ linh hoạt để thêm các thông số mới vào
hệ thống phân phối hiện có và bổ sung các hệ thống phân phối mới hơn.

Vì vậy, các ứng dụng mới hơn nên sử dụng
ZZ0000ZZ
thay vào đó, để có thể hỗ trợ Phân phối hệ thống mới hơn như
DVB-S2, DVB-T2, DVB-C2, ISDB, v.v.

Tất cả các loại tham số được kết hợp như một sự kết hợp trong
Cấu trúc ZZ0000ZZ:


.. code-block:: c

    struct dvb_frontend_parameters {
	uint32_t frequency;     /* (absolute) frequency in Hz for QAM/OFDM */
		    /* intermediate frequency in kHz for QPSK */
	fe_spectral_inversion_t inversion;
	union {
	    struct dvb_qpsk_parameters qpsk;
	    struct dvb_qam_parameters  qam;
	    struct dvb_ofdm_parameters ofdm;
	    struct dvb_vsb_parameters  vsb;
	} u;
    };

Trong trường hợp QPSK có giao diện người dùng, trường ZZ0000ZZ chỉ định
tần số trung gian, tức là phần bù được thêm vào một cách hiệu quả
tần số dao động cục bộ (LOF) của LNB. Trung gian
tần số phải được xác định theo đơn vị kHz. Dành cho QAM và OFDM
giao diện ZZ0001ZZ chỉ định tần số tuyệt đối và
được tính bằng Hz.


.. c:type:: dvb_qpsk_parameters

Thông số QPSK
===============

Đối với giao diện vệ tinh QPSK, bạn phải sử dụng ZZ0000ZZ
cấu trúc:


.. code-block:: c

     struct dvb_qpsk_parameters {
	 uint32_t        symbol_rate;  /* symbol rate in Symbols per second */
	 fe_code_rate_t  fec_inner;    /* forward error correction (see above) */
     };


.. c:type:: dvb_qam_parameters

Thông số QAM
==============

đối với giao diện cáp QAM, bạn sử dụng cấu trúc ZZ0000ZZ:


.. code-block:: c

     struct dvb_qam_parameters {
	 uint32_t         symbol_rate; /* symbol rate in Symbols per second */
	 fe_code_rate_t   fec_inner;   /* forward error correction (see above) */
	 fe_modulation_t  modulation;  /* modulation type (see above) */
     };


.. c:type:: dvb_vsb_parameters

Thông số VSB
==============

Giao diện ATSC được hỗ trợ bởi cấu trúc ZZ0000ZZ:


.. code-block:: c

    struct dvb_vsb_parameters {
	fe_modulation_t modulation; /* modulation type (see above) */
    };


.. c:type:: dvb_ofdm_parameters

Thông số OFDM
===============

Giao diện DVB-T được hỗ trợ bởi cấu trúc ZZ0000ZZ:


.. code-block:: c

     struct dvb_ofdm_parameters {
	 fe_bandwidth_t      bandwidth;
	 fe_code_rate_t      code_rate_HP;  /* high priority stream code rate */
	 fe_code_rate_t      code_rate_LP;  /* low priority stream code rate */
	 fe_modulation_t     constellation; /* modulation type (see above) */
	 fe_transmit_mode_t  transmission_mode;
	 fe_guard_interval_t guard_interval;
	 fe_hierarchy_t      hierarchy_information;
     };