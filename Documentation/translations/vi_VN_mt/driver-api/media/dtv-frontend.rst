.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/dtv-frontend.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Giao diện truyền hình kỹ thuật số kABI
------------------------

Giao diện truyền hình kỹ thuật số
~~~~~~~~~~~~~~~~~~~

Giao diện truyền hình kỹ thuật số kABI xác định giao diện trình điều khiển bên trong cho
đăng ký trình điều khiển phần cứng cụ thể, cấp thấp cho một phần cứng độc lập
lớp giao diện người dùng. Nó chỉ được những người viết trình điều khiển thiết bị TV kỹ thuật số quan tâm.
Tệp tiêu đề cho API này có tên ZZ0000ZZ và nằm ở
ZZ0001ZZ.

Trình điều khiển giải điều chế
^^^^^^^^^^^^^^^^^^

Trình điều khiển bộ giải mã có nhiệm vụ giao tiếp với phần giải mã của
phần cứng. Trình điều khiển như vậy nên triển khai ZZ0000ZZ,
cho biết loại tiêu chuẩn truyền hình kỹ thuật số nào được hỗ trợ và chỉ ra một
loạt chức năng cho phép lõi DVB điều khiển phần cứng thông qua
mã dưới ZZ0001ZZ.

Một ví dụ điển hình về cấu trúc như vậy trong trình điều khiển ZZ0000ZZ là::

cấu trúc tĩnh dvb_frontend_ops foo_ops = {
		.delsys = {SYS_DVBT, SYS_DVBT2, SYS_DVBC_ANNEX_A },
		.thông tin = {
			.name = "trình điều khiển foo DVB-T/T2/C",
			.caps = FE_CAN_FEC_1_2 |
				FE_CAN_FEC_2_3 |
				FE_CAN_FEC_3_4 |
				FE_CAN_FEC_5_6 |
				FE_CAN_FEC_7_8 |
				FE_CAN_FEC_AUTO |
				FE_CAN_QPSK |
				FE_CAN_QAM_16 |
				FE_CAN_QAM_32 |
				FE_CAN_QAM_64 |
				FE_CAN_QAM_128 |
				FE_CAN_QAM_256 |
				FE_CAN_QAM_AUTO |
				FE_CAN_TRANSMISSION_MODE_AUTO |
				FE_CAN_GUARD_INTERVAL_AUTO |
				FE_CAN_HIERARCHY_AUTO |
				FE_CAN_MUTE_TS |
				FE_CAN_2G_MODULATION,
			.tần số_min = 42000000, /* Hz */
			.tần số_max = 1002000000, /* Hz */
			.symbol_rate_min = 870000,
			.symbol_rate_max = 11700000
		},
		.init = foo_init,
		.sleep = foo_sleep,
		.release = foo_release,
		.set_frontend = foo_set_frontend,
		.get_frontend = foo_get_frontend,
		.read_status = foo_get_status_and_stats,
		.tune = foo_tune,
		.i2c_gate_ctrl = foo_i2c_gate_ctrl,
		.get_frontend_algo = foo_get_algo,
	};

Một ví dụ điển hình về cấu trúc như vậy trong trình điều khiển ZZ0000ZZ được sử dụng trên
Việc thu sóng truyền hình vệ tinh là::

cấu trúc const tĩnh dvb_frontend_ops bar_ops = {
		.delsys = { SYS_DVBS, SYS_DVBS2 },
		.thông tin = {
			.name = "Bộ giải mã thanh DVB-S/S2",
			.tần số_min = 500000, /* KHz */
			.tần số_max = 2500000, /* KHz */
			.tần số_bước = 0,
			.symbol_rate_min = 1000000,
			.symbol_rate_max = 45000000,
			.symbol_rate_tolerance = 500,
			.caps = FE_CAN_INVERSION_AUTO |
				FE_CAN_FEC_AUTO |
				FE_CAN_QPSK,
		},
		.init = bar_init,
		.sleep = bar_sleep,
		.release = bar_release,
		.set_frontend = bar_set_frontend,
		.get_frontend = bar_get_frontend,
		.read_status = thanh_get_status_and_stats,
		.i2c_gate_ctrl = bar_i2c_gate_ctrl,
		.get_frontend_algo = bar_get_algo,
		.tune = bar_tune,

/* Dành riêng cho vệ tinh */
		.diseqc_send_master_cmd = bar_send_diseqc_msg,
		.diseqc_send_burst = bar_send_burst,
		.set_tone = bar_set_tone,
		.set_điện áp = bar_set_điện áp,
	};

.. note::

   #) For satellite digital TV standards (DVB-S, DVB-S2, ISDB-S), the
      frequencies are specified in kHz, while, for terrestrial and cable
      standards, they're specified in Hz. Due to that, if the same frontend
      supports both types, you'll need to have two separate
      :c:type:`dvb_frontend_ops` structures, one for each standard.
   #) The ``.i2c_gate_ctrl`` field is present only when the hardware has
      allows controlling an I2C gate (either directly of via some GPIO pin),
      in order to remove the tuner from the I2C bus after a channel is
      tuned.
   #) All new drivers should implement the
      :ref:`DVBv5 statistics <dvbv5_stats>` via ``.read_status``.
      Yet, there are a number of callbacks meant to get statistics for
      signal strength, S/N and UCB. Those are there to provide backward
      compatibility with legacy applications that don't support the DVBv5
      API. Implementing those callbacks are optional. Those callbacks may be
      removed in the future, after we have all existing drivers supporting
      DVBv5 stats.
   #) Other callbacks are required for satellite TV standards, in order to
      control LNBf and DiSEqC: ``.diseqc_send_master_cmd``,
      ``.diseqc_send_burst``, ``.set_tone``, ``.set_voltage``.

.. |delta|   unicode:: U+00394

ZZ0001ZZ có một luồng nhân
chịu trách nhiệm điều chỉnh thiết bị. Nó hỗ trợ nhiều thuật toán để
phát hiện một kênh, như được xác định tại enum ZZ0000ZZ.

Thuật toán được sử dụng được lấy thông qua ZZ0000ZZ. Nếu người lái xe
không điền vào trường của nó tại struct dvb_frontend_ops, nó sẽ mặc định là
ZZ0001ZZ, nghĩa là lõi dvb sẽ thực hiện ngoằn ngoèo khi điều chỉnh,
đ. g. trước tiên nó sẽ thử sử dụng tần số trung tâm được chỉ định ZZ0002ZZ,
sau đó, nó sẽ thực hiện ZZ0003ZZ + ZZ0007ZZ, ZZ0004ZZ - ZZ0008ZZ, ZZ0005ZZ + 2 x ZZ0009ZZ,
ZZ0006ZZ - 2 x ZZ0010ZZ, v.v.

Nếu phần cứng bên trong có một loại thuật toán ngoằn ngoèo nào đó, bạn nên
xác định hàm ZZ0000ZZ sẽ trả về ZZ0001ZZ.

.. note::

   The core frontend support also supports
   a third type (``DVBFE_ALGO_CUSTOM``), in order to allow the driver to
   define its own hardware-assisted algorithm. Very few hardware need to
   use it nowadays. Using ``DVBFE_ALGO_CUSTOM`` require to provide other
   function callbacks at struct dvb_frontend_ops.

Gắn trình điều khiển lối vào vào trình điều khiển cầu
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Trước khi sử dụng lõi giao diện TV kỹ thuật số, trình điều khiển cầu nối phải đính kèm
bản demo giao diện người dùng, bộ điều chỉnh và các thiết bị SEC và gọi
ZZ0000ZZ,
để đăng ký giao diện người dùng mới tại hệ thống con. Tại thiết bị
tách/gỡ bỏ, người lái cầu nên gọi
ZZ0001ZZ tới
xóa giao diện người dùng khỏi lõi và sau đó là ZZ0002ZZ
để giải phóng bộ nhớ được phân bổ bởi trình điều khiển giao diện người dùng.

Trình điều khiển cũng nên gọi ZZ0000ZZ như một phần của
trình xử lý của họ cho ZZ0001ZZ.\ ZZ0004ZZ và
ZZ0002ZZ như
một phần của trình xử lý ZZ0003ZZ.\ ZZ0005ZZ.

Một số hàm tùy chọn khác được cung cấp để xử lý một số trường hợp đặc biệt.

.. _dvbv5_stats:

Số liệu thống kê về giao diện truyền hình kỹ thuật số
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Giới thiệu
^^^^^^^^^^^^

Giao diện truyền hình kỹ thuật số cung cấp nhiều loại
ZZ0000ZZ nhằm giúp điều chỉnh thiết bị
và đo lường chất lượng dịch vụ.

Đối với mỗi phép đo thống kê, người lái xe nên đặt loại thang đo được sử dụng,
hoặc ZZ0000ZZ nếu số liệu thống kê không có sẵn trên một
thời gian. Lái xe cũng nên cung cấp số liệu thống kê cho từng loại.
đó thường là 1 đối với hầu hết các tiêu chuẩn video [#f2]_.

Trình điều khiển nên khởi tạo từng bộ đếm thống kê với độ dài và
mở rộng quy mô ở mã init của nó. Ví dụ: nếu giao diện người dùng cung cấp tín hiệu
sức mạnh, nó phải có, trên mã init của nó::

struct dtv_frontend_properties *c = &state->fe.dtv_property_cache;

c->sức mạnh.len = 1;
	c-> Strength.stat[0].scale = FE_SCALE_NOT_AVAILABLE;

Và khi số liệu thống kê được cập nhật, hãy đặt tỷ lệ::

c-> Strength.stat[0].scale = FE_SCALE_DECIBEL;
	c-> Strength.stat[0].uvalue = sức mạnh;

.. [#f2] For ISDB-T, it may provide both a global statistics and a per-layer
   set of statistics. On such cases, len should be equal to 4. The first
   value corresponds to the global stat; the other ones to each layer, e. g.:

   - c->cnr.stat[0] for global S/N carrier ratio,
   - c->cnr.stat[1] for Layer A S/N carrier ratio,
   - c->cnr.stat[2] for layer B S/N carrier ratio,
   - c->cnr.stat[3] for layer C S/N carrier ratio.

.. note:: Please prefer to use ``FE_SCALE_DECIBEL`` instead of
   ``FE_SCALE_RELATIVE`` for signal strength and CNR measurements.

Nhóm thống kê
^^^^^^^^^^^^^^^^^^^^

Có một số nhóm thống kê hiện được hỗ trợ:

Cường độ tín hiệu (ZZ0000ZZ)
  - Đo mức cường độ tín hiệu ở phần analog của bộ chỉnh tần hoặc
    demo.

- Thường thu được từ mức tăng được áp dụng cho bộ điều chỉnh và/hoặc giao diện người dùng
    để phát hiện người vận chuyển. Khi không phát hiện được sóng mang, độ lợi là
    ở giá trị tối đa (vì vậy, cường độ ở mức tối thiểu).

- Vì mức tăng được hiển thị thông qua bộ thanh ghi điều chỉnh mức tăng,
    thông thường, số liệu thống kê này luôn có sẵn [#f3]_.

- Người lái xe nên cố gắng cung cấp nó mọi lúc, vì những số liệu thống kê này
    có thể được sử dụng khi điều chỉnh vị trí ăng-ten và kiểm tra sự cố
    ở hệ thống cáp.

  .. [#f3] On a few devices, the gain keeps floating if there is no carrier.
     On such devices, strength report should check first if carrier is
     detected at the tuner (``FE_HAS_CARRIER``, see :c:type:`fe_status`),
     and otherwise return the lowest possible value.

Tỷ lệ tín hiệu sóng mang trên nhiễu (ZZ0000ZZ)
  - Tỷ lệ tín hiệu trên nhiễu của sóng mang chính.

- Đo tín hiệu đến nhiễu phụ thuộc vào thiết bị. Trên một số phần cứng, nó là
    có sẵn khi sóng mang chính được phát hiện. Trên những phần cứng đó, CNR
    phép đo thường đến từ bộ điều chỉnh (ví dụ: sau ZZ0001ZZ,
    xem ZZ0000ZZ).

Trên các thiết bị khác, nó yêu cầu giải mã FEC bên trong,
    vì giao diện người dùng đo lường nó một cách gián tiếp từ các tham số khác (ví dụ: sau
    ZZ0001ZZ, xem ZZ0000ZZ).

Việc có sẵn nó sau FEC bên trong là phổ biến hơn.

Số bit sau FEC (ZZ0000ZZ và ZZ0001ZZ)
  - Bộ đếm đó đo số bit và lỗi bit sau
    sửa lỗi chuyển tiếp (FEC) trên khối mã hóa bên trong
    (sau Viterbi, LDPC hoặc mã bên trong khác).

- Do tính chất nên những thống kê đó phụ thuộc vào khóa mã hóa đầy đủ
    (ví dụ: sau ZZ0001ZZ hoặc sau ZZ0002ZZ,
    xem ZZ0000ZZ).

Số bit trước FEC (ZZ0000ZZ và ZZ0001ZZ)
  - Bộ đếm đó đo số bit và số bit lỗi trước đó
    sửa lỗi chuyển tiếp (FEC) trên khối mã hóa bên trong
    (trước Viterbi, LDPC hoặc mã bên trong khác).

- Không phải tất cả các giao diện người dùng đều cung cấp loại thống kê này.

- Do tính chất của nó, những thống kê đó phụ thuộc vào khóa mã hóa bên trong (ví dụ:
    sau ZZ0001ZZ, xem ZZ0000ZZ).

Số khối (ZZ0000ZZ và ZZ0001ZZ)
  - Bộ đếm đó đo số khối và lỗi khối sau
    sửa lỗi chuyển tiếp (FEC) trên khối mã hóa bên trong
    (trước Viterbi, LDPC hoặc mã bên trong khác).

- Do tính chất nên những thống kê đó phụ thuộc vào khóa mã hóa đầy đủ
    (ví dụ: sau ZZ0001ZZ hoặc sau
    ZZ0002ZZ, xem ZZ0000ZZ).

.. note:: All counters should be monotonically increased as they're
   collected from the hardware.

Một ví dụ điển hình về logic xử lý trạng thái và số liệu thống kê là::

int tĩnh foo_get_status_and_stats(struct dvb_frontend *fe)
	{
		struct foo_state *state = fe->demodulator_priv;
		struct dtv_frontend_properties *c = &fe->dtv_property_cache;

int rc;
		enum fe_status *trạng thái;

/* Cả trạng thái và sức mạnh luôn có sẵn */
		rc = foo_read_status(fe, &status);
		nếu (rc < 0)
			trả lại rc;

rc = foo_read_ Strength(fe);
		nếu (rc < 0)
			trả lại rc;

/* Kiểm tra xem CNR có sẵn không */
		if (!(fe->trạng thái & FE_HAS_CARRIER))
			trả về 0;

rc = foo_read_cnr(fe);
		nếu (rc < 0)
			trả lại rc;

/* Kiểm tra xem có sẵn số liệu thống kê trước BER không */
		if (!(fe->trạng thái & FE_HAS_VITERBI))
			trả về 0;

rc = foo_get_pre_ber(fe);
		nếu (rc < 0)
			trả lại rc;

/* Kiểm tra xem có sẵn số liệu thống kê sau BER không */
		if (!(fe->trạng thái & FE_HAS_SYNC))
			trả về 0;

rc = foo_get_post_ber(fe);
		nếu (rc < 0)
			trả lại rc;
	}

cấu trúc const tĩnh dvb_frontend_ops ops = {
		/* ... */
		.read_status = foo_get_status_and_stats,
	};

Thu thập số liệu thống kê
^^^^^^^^^^^^^^^^^^^^^

Trên hầu hết tất cả phần cứng giao diện người dùng, số bit và byte được lưu trữ bởi
phần cứng sau một khoảng thời gian nhất định hoặc sau tổng số bit/khối
bộ đếm đạt đến một giá trị nhất định (thường có thể lập trình được), ví dụ: trên
cứ sau 1000 ms hoặc sau khi nhận được 1.000.000 bit.

Vì vậy, nếu bạn đọc sổ đăng ký quá sớm, bạn sẽ kết thúc bằng cách đọc tương tự
giá trị như trong lần đọc trước, khiến giá trị đơn điệu trở thành
tăng quá thường xuyên.

Người lái xe nên có trách nhiệm tránh đọc quá thường xuyên. Đó
có thể được thực hiện bằng hai cách tiếp cận:

nếu trình điều khiển có bit cho biết khi nào dữ liệu được thu thập sẵn sàng
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Người lái xe nên kiểm tra những thông tin đó trước khi đưa ra số liệu thống kê.

Bạn có thể tìm thấy một ví dụ về hành vi như vậy tại đoạn mã này (được điều chỉnh
từ logic của trình điều khiển mb86a20s)::

int tĩnh foo_get_pre_ber(struct dvb_frontend *fe)
	{
		struct foo_state *state = fe->demodulator_priv;
		struct dtv_frontend_properties *c = &fe->dtv_property_cache;
		int rc, bit_error;

/* Kiểm tra xem các biện pháp BER đã có sẵn chưa */
		rc = foo_read_u8(trạng thái, 0x54);
		nếu (rc < 0)
			trả lại rc;

nếu (!rc)
			trả về 0;

/* Đọc số bit lỗi */
		bit_error = foo_read_u32(trạng thái, 0x55);
		nếu (bit_error < 0)
			trả về bit_error;

/* Đọc tổng số bit */
		rc = foo_read_u32(trạng thái, 0x51);
		nếu (rc < 0)
			trả lại rc;

c->pre_bit_error.stat[0].scale = FE_SCALE_COUNTER;
		c->pre_bit_error.stat[0].uvalue += bit_error;
		c->pre_bit_count.stat[0].scale = FE_SCALE_COUNTER;
		c->pre_bit_count.stat[0].uvalue += rc;

trả về 0;
	}

Nếu trình điều khiển không cung cấp số liệu thống kê có sẵn, bit kiểm tra
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tuy nhiên, một số thiết bị có thể không cung cấp cách kiểm tra xem số liệu thống kê có
có sẵn (hoặc cách kiểm tra chưa rõ). Họ thậm chí có thể không cung cấp
một cách để đọc trực tiếp tổng số bit hoặc khối.

Trên các thiết bị đó, trình điều khiển cần đảm bảo rằng nó sẽ không đọc từ
thanh ghi quá thường xuyên và/hoặc ước tính tổng số bit/khối.

Trên những trình điều khiển như vậy, quy trình điển hình để lấy số liệu thống kê sẽ như thế nào
(được chuyển thể từ logic của trình điều khiển dib8000)::

cấu trúc foo_state {
		/* ... */

per_jiffies_stats dài không dấu;
	}

int tĩnh foo_get_pre_ber(struct dvb_frontend *fe)
	{
		struct foo_state *state = fe->demodulator_priv;
		struct dtv_frontend_properties *c = &fe->dtv_property_cache;
		int rc, bit_error;
		bit u64;

/* Kiểm tra xem thời gian thống kê đã trôi qua chưa */
		if (!time_after(jiffies, state->per_jiffies_stats))
			trả về 0;

/* Chỉ số tiếp theo sẽ được thu thập sau 1000 ms */
		trạng thái->per_jiffies_stats = jiffies + msecs_to_jiffies(1000);

/* Đọc số bit lỗi */
		bit_error = foo_read_u32(trạng thái, 0x55);
		nếu (bit_error < 0)
			trả về bit_error;

/*
		 * Trên giao diện cụ thể này, không có đăng ký nào
		 * sẽ cung cấp số bit trên mỗi mẫu 1000ms. Vì vậy,
		 * một số hàm sẽ tính toán nó dựa trên thuộc tính DTV
		 */
		bit = get_number_of_bits_per_1000ms(fe);

c->pre_bit_error.stat[0].scale = FE_SCALE_COUNTER;
		c->pre_bit_error.stat[0].uvalue += bit_error;
		c->pre_bit_count.stat[0].scale = FE_SCALE_COUNTER;
		c->pre_bit_count.stat[0].uvalue += bit;

trả về 0;
	}

Xin lưu ý rằng, trong cả hai trường hợp, chúng tôi đang lấy số liệu thống kê bằng cách sử dụng
Gọi lại ZZ0000ZZ ZZ0001ZZ. Lý do là thế
lõi giao diện người dùng sẽ tự động gọi chức năng này theo định kỳ
(thông thường, 3 lần mỗi giây, khi giao diện người dùng bị khóa).

Điều đó đảm bảo rằng chúng tôi sẽ không bỏ lỡ việc thu thập bộ đếm và tăng
số liệu thống kê đơn điệu vào đúng thời điểm.

Các chức năng và loại giao diện truyền hình kỹ thuật số
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. kernel-doc:: include/media/dvb_frontend.h