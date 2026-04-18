.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/soc/dpcm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

============
PCM năng động
===========

Sự miêu tả
===========

PCM động cho phép thiết bị ALSA PCM định tuyến kỹ thuật số âm thanh PCM của nó tới
các điểm cuối kỹ thuật số khác nhau trong thời gian chạy luồng PCM. ví dụ. PCM0 có thể định tuyến
âm thanh kỹ thuật số sang I2S DAI0, I2S DAI1 hoặc PDM DAI2. Điều này hữu ích cho SoC DSP
trình điều khiển hiển thị một số PCM ALSA và có thể định tuyến tới nhiều DAI.

Định tuyến thời gian chạy DPCM được xác định bởi cài đặt bộ trộn ALSA trong cùng một
cách tín hiệu tương tự được định tuyến trong trình điều khiển codec ASoC. DPCM sử dụng DAPM
biểu đồ biểu thị đường dẫn âm thanh bên trong DSP và sử dụng cài đặt bộ trộn để
xác định đường dẫn được sử dụng bởi mỗi ALSA PCM.

DPCM sử dụng lại tất cả các codec, nền tảng và trình điều khiển DAI thành phần hiện có mà không cần
bất kỳ sửa đổi nào.


Hệ thống âm thanh điện thoại với DSP dựa trên SoC
-------------------------------------

Hãy xem xét hệ thống con âm thanh điện thoại sau đây. Điều này sẽ được sử dụng trong này
tài liệu cho tất cả các ví dụ: -
::

ZZ0000ZZ SoC DSP ZZ0001ZZ Thiết bị âm thanh |
  
*************
  PCM0 <--------------> * * <----DAI0-----> Tai nghe Codec
                      * *
  PCM1 <--------------> * * <----DAI1-----> Loa Codec
                      * DSP *
  PCM2 <--------------> * * <----DAI2-----> MODEM
                      * *
  PCM3 <--------------> * * <----DAI3-----> BT
                      * *
                      * * <----DAI4------> DMIC
                      * *
                      * * <----DAI5------> FM
                      *************

Sơ đồ này cho thấy một hệ thống con âm thanh điện thoại thông minh đơn giản. Nó hỗ trợ Bluetooth,
Đài FM kỹ thuật số, Loa, Giắc cắm tai nghe, micrô kỹ thuật số và thiết bị di động
modem. Card âm thanh này hiển thị 4 thiết bị DSP mặt trước (FE) ALSA PCM và
hỗ trợ 6 DAI mặt sau (BE). Mỗi FE PCM có thể định tuyến dữ liệu âm thanh kỹ thuật số tới bất kỳ
của BE DAI. Các thiết bị FE PCM cũng có thể định tuyến âm thanh đến nhiều hơn 1 BE DAI.



Ví dụ - DPCM Chuyển phát lại từ DAI0 sang DAI1
---------------------------------------------------

Âm thanh đang được phát tới Tai nghe. Một lúc sau người dùng tháo tai nghe ra
và âm thanh tiếp tục phát trên loa.

Phát lại trên PCM0 tới Tai nghe sẽ như sau:-
::

*************
  PCM0 <==============> * * <====DAI0=====> Tai nghe Codec
                      * *
  PCM1 <--------------> * * <----DAI1-----> Loa Codec
                      * DSP *
  PCM2 <--------------> * * <----DAI2-----> MODEM
                      * *
  PCM3 <--------------> * * <----DAI3-----> BT
                      * *
                      * * <----DAI4------> DMIC
                      * *
                      * * <----DAI5------> FM
                      *************

Người dùng đã tháo tai nghe ra khỏi giắc cắm nên bây giờ phải sử dụng loa:-
::

*************
  PCM0 <=============> * * <----DAI0------> Tai nghe Codec
                      * *
  PCM1 <--------------> * * <====DAI1=====> Loa Codec
                      * DSP *
  PCM2 <--------------> * * <----DAI2-----> MODEM
                      * *
  PCM3 <--------------> * * <----DAI3-----> BT
                      * *
                      * * <----DAI4------> DMIC
                      * *
                      * * <----DAI5------> FM
                      *************

Trình điều khiển âm thanh xử lý việc này như sau: -

1. Driver máy nhận sự kiện tháo Jack.

2. Trình điều khiển máy HOẶC âm thanh HAL vô hiệu hóa đường dẫn Tai nghe.

3. DPCM chạy các hoạt động kích hoạt PCM (dừng), hw_free(), tắt máy() trên DAI0
   dành cho tai nghe vì đường dẫn hiện đã bị tắt.

4. Trình điều khiển máy hoặc âm thanh HAL kích hoạt đường dẫn loa.

5. DPCM chạy các hoạt động PCM cho startup(), hw_params(), prepare() và
   trigger(start) cho Loa DAI1 vì đường dẫn được bật.

Trong ví dụ này, trình điều khiển máy hoặc âm thanh vùng người dùng HAL có thể thay đổi định tuyến
và sau đó DPCM sẽ đảm nhiệm việc quản lý các hoạt động DAI PCM để mang lại
liên kết lên hoặc xuống. Quá trình phát lại âm thanh không dừng lại trong quá trình chuyển đổi này.



Trình điều khiển máy DPCM
===================

Driver máy ASoC kích hoạt DPCM tương tự như driver máy thông thường
ngoại trừ việc chúng tôi cũng phải: -

1. Xác định liên kết FE và BE DAI.

2. Xác định mọi hoạt động FE/BE PCM.

3. Xác định kết nối biểu đồ widget.


Liên kết FE và BE DAI
-------------------
::

ZZ0000ZZ SoC DSP ZZ0001ZZ Thiết bị âm thanh |
  
*************
  PCM0 <--------------> * * <----DAI0-----> Tai nghe Codec
                      * *
  PCM1 <--------------> * * <----DAI1-----> Loa Codec
                      * DSP *
  PCM2 <--------------> * * <----DAI2-----> MODEM
                      * *
  PCM3 <--------------> * * <----DAI3-----> BT
                      * *
                      * * <----DAI4------> DMIC
                      * *
                      * * <----DAI5------> FM
                      *************

Đối với ví dụ trên, chúng ta phải xác định 4 liên kết FE DAI và 6 liên kết BE DAI. các
Liên kết FE DAI được định nghĩa như sau: -
::

SND_SOC_DAILINK_DEFS(pcm0,
	DAILINK_COMP_ARRAY(COMP_CPU("Pin hệ thống")),
	DAILINK_COMP_ARRAY(COMP_DUMMY()),
	DAILINK_COMP_ARRAY(COMP_PLATFORM("dsp-audio")));

cấu trúc tĩnh snd_soc_dai_link machine_dais[] = {
	{
		.name = "Hệ thống PCM0",
		.stream_name = "Phát lại hệ thống",
		SND_SOC_DAILINK_REG(pcm0),
		.động = 1,
		.trigger = {SND_SOC_DPCM_TRIGGER_POST, SND_SOC_DPCM_TRIGGER_POST},
	},
	.....< other FE and BE DAI links here >
  };

Liên kết FE DAI này khá giống với liên kết DAI thông thường ngoại trừ việc chúng tôi cũng
đặt liên kết DAI thành DPCM FE với ZZ0000ZZ.
Ngoài ra còn có một tùy chọn để chỉ định thứ tự của lệnh gọi kích hoạt cho
mỗi FE. Điều này cho phép lõi ASoC kích hoạt DSP trước hoặc sau lõi kia
các thành phần (vì một số DSP có yêu cầu cao đối với việc đặt hàng DAI/DSP
trình tự bắt đầu và kết thúc).

FE DAI ở trên đặt codec và mã DAI thành các thiết bị giả vì BE là
động và sẽ thay đổi tùy thuộc vào cấu hình thời gian chạy.

BE DAI được cấu hình như sau: -
::

SND_SOC_DAILINK_DEFS(tai nghe,
	DAILINK_COMP_ARRAY(COMP_CPU("ssp-dai.0")),
	DAILINK_COMP_ARRAY(COMP_CODEC("rt5640.0-001c", "rt5640-aif1")));

cấu trúc tĩnh snd_soc_dai_link machine_dais[] = {
	.....< FE DAI links here >
{
		.name = "Tai nghe Codec",
		SND_SOC_DAILINK_REG(tai nghe),
		.no_pcm = 1,
		.ignore_suspend = 1,
		.ignore_pmdown_time = 1,
		.be_hw_params_fixup = hswult_ssp0_fixup,
		.ops = &haswell_ops,
	},
	.....< other BE DAI links here >
  };

Liên kết BE DAI này kết nối DAI0 với codec (trong trường hợp này là RT5460 AIF1). Nó đặt
cờ ZZ0000ZZ để đánh dấu nó có BE.

BE cũng đặt cờ để bỏ qua thời gian tạm dừng và ngừng hoạt động của PM. Điều này cho phép
BE hoạt động ở chế độ không có máy chủ trong đó máy chủ CPU không truyền dữ liệu
giống như một cuộc gọi điện thoại BT :-
::

*************
  PCM0 <--------------> * * <----DAI0-----> Tai nghe Codec
                      * *
  PCM1 <--------------> * * <----DAI1-----> Loa Codec
                      * DSP *
  PCM2 <--------------> * * <====DAI2=====> MODEM
                      * *
  PCM3 <--------------> * * <====DAI3=====> BT
                      * *
                      * * <----DAI4------> DMIC
                      * *
                      * * <----DAI5------> FM
                      *************

Điều này cho phép máy chủ CPU ngủ trong khi DSP, MODEM DAI và BT DAI đang ở trạng thái ngủ.
vẫn đang hoạt động.

Liên kết BE DAI cũng có thể đặt codec thành thiết bị giả nếu codec là một thiết bị
được quản lý bên ngoài.

Tương tự, BE DAI cũng có thể đặt cpu giả DAI nếu CPU DAI được quản lý bởi
Phần mềm DSP.


Hoạt động FE/BE PCM
--------------------

BE ở trên cũng xuất một số hoạt động PCM và lệnh gọi lại ZZ0000ZZ. bản sửa lỗi
lệnh gọi lại được trình điều khiển máy sử dụng để (tái) cấu hình DAI dựa trên
Thông số FE hw. tức là DSP có thể thực hiện SRC hoặc ASRC từ FE đến BE.

ví dụ. DSP chuyển đổi tất cả các thông số hw FE để chạy ở tốc độ cố định 48k, 16bit, âm thanh nổi cho
DAI0. Điều này có nghĩa là tất cả FE hw_params phải được sửa trong trình điều khiển máy để
DAI0 để DAI chạy ở cấu hình mong muốn bất kể FE
cấu hình.
::

int tĩnh dai0_fixup(struct snd_soc_pcm_runtime *rtd,
			cấu trúc snd_pcm_hw_params *params)
  {
	struct snd_interval *rate = hw_param_interval(params,
			SNDRV_PCM_HW_PARAM_RATE);
	struct snd_interval *channels = hw_param_interval(params,
						SNDRV_PCM_HW_PARAM_CHANNELS);

/* DSP sẽ chuyển đổi tốc độ FE thành 48k, âm thanh nổi */
	tỷ lệ->tối thiểu = tỷ lệ->tối đa = 48000;
	kênh->min = kênh->max = 2;

/* đặt DAI0 thành 16 bit */
	params_set_format(params, SNDRV_PCM_FORMAT_S16_LE);
	trả về 0;
  }

Hoạt động PCM khác cũng giống như đối với các liên kết DAI thông thường. Sử dụng khi cần thiết.


Kết nối biểu đồ widget
------------------------

Các liên kết BE DAI thường sẽ được kết nối với biểu đồ tại thời điểm khởi tạo
bởi lõi ASoC DAPM. Tuy nhiên, nếu codec BE hoặc BE DAI là giả thì điều này
phải được đặt rõ ràng trong trình điều khiển: -
::

/* BE cho tai nghe codec - DAI0 là giả và được quản lý bởi DSP FW */
  {"DAI0 CODEC IN", NULL, "AIF1 Capture"},
  {"Phát lại AIF1", NULL, "DAI0 CODEC OUT"},


Viết trình điều khiển DPCM DSP
=========================

Trình điều khiển DPCM DSP trông giống như trình điều khiển ASoC lớp nền tảng tiêu chuẩn
kết hợp với các phần tử từ trình điều khiển lớp codec. Trình điều khiển nền tảng DSP phải
thực hiện :-

1. Giao diện người dùng PCM DAI - tức là struct snd_soc_dai_driver.

2. Biểu đồ DAPM hiển thị định tuyến âm thanh DSP từ FE DAI đến BE.

3. Các tiện ích DAPM từ biểu đồ DSP.

4. Bộ trộn để tăng lợi nhuận, định tuyến, v.v.

5. Cấu hình DMA.

6. Vật dụng BE AIF.

Mục 6 rất quan trọng để định tuyến âm thanh bên ngoài DSP. AIF cần phải có
được xác định cho từng BE và từng hướng luồng. ví dụ: đối với BE DAI0 ở trên, chúng tôi sẽ
có :-
::

SND_SOC_DAPM_AIF_IN("DAI0 RX", NULL, 0, SND_SOC_NOPM, 0, 0),
  SND_SOC_DAPM_AIF_OUT("DAI0 TX", NULL, 0, SND_SOC_NOPM, 0, 0),

BE AIF được sử dụng để kết nối biểu đồ DSP với các biểu đồ khác
trình điều khiển thành phần (ví dụ: biểu đồ codec).


Luồng PCM không có máy chủ
====================

Luồng PCM không có máy chủ là luồng không được định tuyến qua máy chủ CPU. Một
ví dụ về điều này là một cuộc gọi điện thoại từ thiết bị cầm tay đến modem.
::

*************
  PCM0 <--------------> * * <----DAI0-----> Tai nghe Codec
                      * *
  PCM1 <--------------> * * <====DAI1=====> Loa/Mic Codec
                      * DSP *
  PCM2 <--------------> * * <====DAI2=====> MODEM
                      * *
  PCM3 <--------------> * * <----DAI3-----> BT
                      * *
                      * * <----DAI4------> DMIC
                      * *
                      * * <----DAI5------> FM
                      *************

Trong trường hợp này, dữ liệu PCM được định tuyến qua DSP. Máy chủ CPU trong trường hợp sử dụng này
chỉ được sử dụng để điều khiển và có thể ngủ trong thời gian chạy luồng.

Máy chủ có thể kiểm soát liên kết không có máy chủ bằng cách: -

1. Định cấu hình liên kết theo kiểu liên kết CODEC <-> CODEC. Trong trường hợp này liên kết
    được bật hoặc tắt bởi trạng thái của biểu đồ DAPM. Điều này thường có nghĩa
    có một bộ điều khiển bộ trộn có thể được sử dụng để kết nối hoặc ngắt kết nối đường dẫn
    giữa cả hai DAI.

2. FE không có máy chủ. FE này có kết nối ảo với các liên kết BE DAI trên DAPM
    đồ thị. Việc điều khiển sau đó được FE thực hiện như các hoạt động PCM thông thường.
    Phương pháp này cho phép kiểm soát nhiều hơn các liên kết DAI, nhưng đòi hỏi nhiều hơn
    mã không gian người dùng để kiểm soát liên kết. Nên sử dụng CODEC<->CODEC
    trừ khi CTNH của bạn cần trình tự chi tiết hơn về các hoạt động PCM.


Liên kết CODEC <-> CODEC
--------------------

Liên kết DAI này được bật khi DAPM phát hiện đường dẫn hợp lệ trong biểu đồ DAPM.
Trình điều khiển máy đặt một số tham số bổ sung cho liên kết DAI, tức là.
::

cấu trúc const tĩnh snd_soc_pcm_stream dai_params = {
	.format = SNDRV_PCM_FMTBIT_S32_LE,
	.rate_min = 8000,
	.rate_max = 8000,
	.channels_min = 2,
	.channels_max = 2,
  };

cấu trúc tĩnh snd_soc_dai_link dais[] = {
	< ... thêm các liên kết DAI ở trên ... >
	{
		.name = "MODEM",
		.stream_name = "MODEM",
		.cpu_dai_name = "dai2",
		.codec_dai_name = "modem-aif1",
		.codec_name = "modem",
		.dai_fmt = SND_SOC_DAIFMT_I2S | SND_SOC_DAIFMT_NB_NF
				| SND_SOC_DAIFMT_CBP_CFP,
		.c2c_params = &dai_params,
		.num_c2c_params = 1,
	}
	< ... thêm liên kết DAI tại đây ... >

Các tham số này được sử dụng để định cấu hình DAI hw_params() khi DAPM phát hiện một
đường dẫn hợp lệ và sau đó gọi các hoạt động PCM để bắt đầu liên kết. DAPM cũng sẽ
gọi các thao tác PCM thích hợp để vô hiệu hóa DAI khi không có đường dẫn
còn hiệu lực.


FE không có máy chủ
-----------

(Các) liên kết DAI được kích hoạt bởi FE không đọc hoặc ghi bất kỳ dữ liệu PCM nào.
Điều này có nghĩa là tạo một FE mới được kết nối bằng đường dẫn ảo tới cả hai
Liên kết DAI. Các liên kết DAI sẽ được bắt đầu khi FE PCM được khởi động và dừng
khi FE PCM bị dừng. Lưu ý rằng FE PCM không thể đọc hoặc ghi dữ liệu trong
cấu hình này.
