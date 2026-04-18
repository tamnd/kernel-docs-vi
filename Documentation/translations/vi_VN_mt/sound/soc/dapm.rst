.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/soc/dapm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================================================
Quản lý năng lượng âm thanh động cho thiết bị di động
===================================================

Sự miêu tả
===========

Quản lý năng lượng âm thanh động (DAPM) được thiết kế để cho phép di động
Các thiết bị Linux sử dụng lượng điện năng tối thiểu trong âm thanh
hệ thống con mọi lúc. Nó độc lập với sức mạnh hạt nhân khác
khuôn khổ quản lý và do đó có thể dễ dàng cùng tồn tại với chúng.

DAPM cũng hoàn toàn trong suốt đối với tất cả các ứng dụng không gian người dùng như
tất cả việc chuyển đổi nguồn được thực hiện trong lõi ASoC. Không có thay đổi mã hoặc
biên dịch lại là cần thiết cho các ứng dụng không gian người dùng. DAPM tạo ra sức mạnh
quyết định chuyển đổi dựa trên bất kỳ luồng âm thanh nào (thu/phát lại)
cài đặt hoạt động và bộ trộn âm thanh trong thiết bị.

DAPM dựa trên hai yếu tố cơ bản, được gọi là widget và tuyến đường:

* ZZ0000ZZ là mọi bộ phận của phần cứng âm thanh có thể được kích hoạt bởi
   phần mềm khi sử dụng và tắt để tiết kiệm điện năng khi không sử dụng
 * ZZ0001ZZ là sự kết nối giữa các vật dụng tồn tại khi âm thanh
   có thể chảy từ tiện ích này sang tiện ích khác

Tất cả các quyết định chuyển đổi nguồn DAPM được thực hiện tự động bằng cách tham khảo ý kiến của
đồ thị định tuyến âm thanh. Biểu đồ này dành riêng cho từng card âm thanh và các nhịp
toàn bộ card âm thanh, vì vậy một số tuyến DAPM kết nối hai vật dụng thuộc về
các thành phần khác nhau (ví dụ: chân LINE OUT của CODEC và chân đầu vào của
một bộ khuếch đại).

Đồ thị của card âm thanh STM32MP1-DK1 được hiển thị trong hình:

.. kernel-figure:: dapm-graph.svg
    :alt:   Example DAPM graph
    :align: center

Bạn cũng có thể tạo biểu đồ tương thích cho card âm thanh của mình bằng cách sử dụng
Tiện ích ZZ0000ZZ.

Miền năng lượng DAPM
==================

Có 4 miền quyền lực trong DAPM:

Miền thiên vị Codec
      VREF, VMID (codec lõi và nguồn âm thanh)

Thường được kiểm soát ở đầu dò/xóa codec và tạm dừng/tiếp tục, mặc dù
      có thể được đặt vào thời điểm phát trực tuyến nếu không cần nguồn điện cho âm phụ, v.v.

Nền tảng/Miền máy
      đầu vào và đầu ra được kết nối vật lý

Nền tảng/máy và hành động của người dùng có cụ thể không, được định cấu hình bởi
      trình điều khiển máy và phản hồi các sự kiện không đồng bộ, ví dụ như khi HP
      được chèn vào

Miền đường dẫn
      đường dẫn tín hiệu hệ thống con âm thanh

Tự động đặt khi người dùng thay đổi cài đặt bộ trộn và mux.
      ví dụ. máy trộn alsamixer, máy trộn alsamixer.

Truyền phát miền
      DAC và ADC.

Được bật và tắt khi bắt đầu phát lại/ghi luồng và
      lần lượt dừng lại. ví dụ. aplay, arecord.


Widget DAPM
============

Các tiện ích âm thanh DAPM thuộc một số loại:

Máy trộn
	Trộn một số tín hiệu tương tự thành một tín hiệu tương tự duy nhất.
Mux
	Một công tắc tương tự chỉ xuất ra một trong nhiều đầu vào.
PGA
	Bộ khuếch đại khuếch đại có thể lập trình hoặc tiện ích suy giảm.
ADC
	Bộ chuyển đổi tương tự sang kỹ thuật số
DAC
	Bộ chuyển đổi kỹ thuật số sang analog
Chuyển đổi
	Một công tắc analog
đầu vào
	Chân đầu vào codec
đầu ra
	Chân đầu ra codec
Tai nghe
	Tai nghe (và giắc cắm tùy chọn)
Micrô
	Mic (và Jack tùy chọn)
dòng
	Đầu vào / đầu ra dòng (và Jack tùy chọn)
Loa
	Loa
cung cấp
	Tiện ích cung cấp nguồn hoặc đồng hồ được sử dụng bởi các tiện ích khác.
Bộ điều chỉnh
	Bộ điều chỉnh bên ngoài cung cấp năng lượng cho các thành phần âm thanh.
Đồng hồ
	Đồng hồ bên ngoài cung cấp đồng hồ cho các thành phần âm thanh.
AIF TRONG
	Đầu vào giao diện âm thanh (với mặt nạ khe TDM).
AIF OUT
	Đầu ra giao diện âm thanh (với mặt nạ khe TDM).
Siggen
	Máy phát tín hiệu.
DAI TRONG
	Đầu vào giao diện âm thanh kỹ thuật số.
DAI OUT
	Đầu ra giao diện âm thanh kỹ thuật số.
Liên kết DAI
	DAI Liên kết giữa hai cấu trúc DAI
trước
	Tiện ích PRE đặc biệt (thực thi trước tất cả các tiện ích khác)
bài đăng
	Tiện ích POST đặc biệt (thực thi sau tất cả các tiện ích khác)
Bộ đệm
	Bộ đệm dữ liệu âm thanh liên widget trong DSP.
Người lập lịch trình
	Bộ lập lịch nội bộ DSP lên lịch xử lý thành phần/đường ống
	làm việc.
Hiệu ứng
	Widget thực hiện hiệu ứng xử lý âm thanh.
SRC
	Bộ chuyển đổi tốc độ mẫu trong DSP hoặc CODEC
ASRC
	Bộ chuyển đổi tốc độ mẫu không đồng bộ trong DSP hoặc CODEC
Bộ mã hóa
	Tiện ích mã hóa dữ liệu âm thanh từ một định dạng (thường là PCM) sang định dạng khác
	thường là định dạng nén hơn.
Bộ giải mã
	Widget giải mã dữ liệu âm thanh từ định dạng nén sang định dạng
	định dạng không nén như PCM.


(Widget được xác định trong include/sound/soc-dapm.h)

Các widget có thể được thêm vào card âm thanh bằng bất kỳ loại trình điều khiển thành phần nào.
Có các macro tiện lợi được xác định trong soc-dapm.h có thể được sử dụng để nhanh chóng
xây dựng danh sách widget của codec và widget DAPM của máy.

Hầu hết các vật dụng đều có tên, thanh ghi, dịch chuyển và đảo ngược. Một số vật dụng có thêm
tham số cho tên luồng và điều khiển k.


Truyền phát các tiện ích tên miền
---------------------

Tiện ích luồng liên quan đến miền công suất luồng và chỉ bao gồm ADC
(bộ chuyển đổi analog sang kỹ thuật số), DAC (bộ chuyển đổi kỹ thuật số sang analog),
AIF TRONG và AIF OUT.

Các tiện ích luồng có định dạng sau:
::

SND_SOC_DAPM_DAC(tên, tên luồng, reg, shift, invert),
  SND_SOC_DAPM_AIF_IN(tên, luồng, vị trí, reg, shift, đảo ngược)

NOTE: tên luồng phải khớp với tên luồng tương ứng trong codec của bạn
snd_soc_dai_driver.

ví dụ. phát trực tuyến các tiện ích để phát lại và ghi HiFi
::

SND_SOC_DAPM_DAC("HiFi DAC", "Phát lại HiFi", REG, 3, 1),
  SND_SOC_DAPM_ADC("HiFi ADC", "Chụp HiFi", REG, 2, 1),

ví dụ. phát trực tuyến các tiện ích dành cho AIF
::

SND_SOC_DAPM_AIF_IN("AIF1RX", "Phát lại AIF1", 0, SND_SOC_NOPM, 0, 0),
  SND_SOC_DAPM_AIF_OUT("AIF1TX", "Chụp AIF1", 0, SND_SOC_NOPM, 0, 0),


Tiện ích tên miền đường dẫn
-------------------

Các tiện ích miền đường dẫn có khả năng kiểm soát hoặc ảnh hưởng đến tín hiệu âm thanh hoặc
đường dẫn âm thanh trong hệ thống con âm thanh. Chúng có dạng sau:
::

SND_SOC_DAPM_PGA(tên, reg, shift, đảo ngược, điều khiển, num_controls)

Bất kỳ kcontrols tiện ích nào cũng có thể được đặt bằng cách sử dụng các điều khiển và thành viên num_controls.

ví dụ. Tiện ích trộn (kcontrols được khai báo đầu tiên)
::

/* Bộ trộn đầu ra */
  hằng số tĩnh snd_kcontrol_new_t wm8731_output_mixer_controls[] = {
  SOC_DAPM_SINGLE("Công tắc bỏ qua dòng", WM8731_APANA, 3, 1, 0),
  SOC_DAPM_SINGLE("Công tắc âm thanh bên Mic", WM8731_APANA, 5, 1, 0),
  SOC_DAPM_SINGLE("Công tắc phát lại HiFi", WM8731_APANA, 4, 1, 0),
  };

SND_SOC_DAPM_MIXER("Bộ trộn đầu ra", WM8731_PWR, 4, 1, wm8731_output_mixer_controls,
	ARRAY_SIZE(wm8731_output_mixer_controls)),

Nếu bạn không muốn các phần tử bộ trộn có tiền tố là tên của tiện ích bộ trộn,
bạn có thể sử dụng SND_SOC_DAPM_MIXER_NAMED_CTL thay thế. các thông số đều giống nhau
đối với SND_SOC_DAPM_MIXER.


Widget miền máy
----------------------

Các widget của máy khác với các widget codec ở chỗ chúng không có
bit thanh ghi codec liên kết với chúng. Một widget máy được gán cho mỗi
thành phần âm thanh máy (không phải codec hoặc DSP) có thể độc lập
được cấp nguồn. ví dụ.

* Loa khuếch đại
* Xu hướng micrô
* Đầu nối Jack

Một widget máy có thể có một cuộc gọi lại tùy chọn.

ví dụ. Tiện ích đầu nối giắc cắm cho Mic bên ngoài cho phép Mic Bias
khi Mic được cắm vào::

int tĩnh Spitz_mic_bias(struct snd_soc_dapm_widget* w, int sự kiện)
  {
	gpio_set_value(SPITZ_GPIO_MIC_BIAS, SND_SOC_DAPM_EVENT_ON(sự kiện));
	trả về 0;
  }

SND_SOC_DAPM_MIC("Jack Mic", Spitz_mic_bias),


Tên miền Codec (BIAS)
-------------------

Miền năng lượng thiên vị codec không có widget và được xử lý bởi codec DAPM
xử lý sự kiện. Trình xử lý này được gọi khi trạng thái nguồn codec được thay đổi.
tới bất kỳ sự kiện luồng nào hoặc bởi các sự kiện PM hạt nhân.


Widget ảo
---------------

Đôi khi các tiện ích tồn tại trong codec hoặc biểu đồ âm thanh máy không có bất kỳ tiện ích nào.
điều khiển công suất mềm tương ứng. Trong trường hợp này cần phải tạo
một tiện ích ảo - một tiện ích không có bit điều khiển, ví dụ:
::

SND_SOC_DAPM_MIXER("Bộ trộn AC97", SND_SOC_NOPM, 0, 0, NULL, 0),

Điều này có thể được sử dụng để hợp nhất hai đường dẫn tín hiệu với nhau trong phần mềm.

Đăng ký điều khiển DAPM
=========================

Trong nhiều trường hợp, các tiện ích DAPM được triển khai tĩnh trong mảng ZZ0000ZZ trong trình điều khiển codec và chỉ đơn giản là
được khai báo thông qua các trường ZZ0001ZZ và ZZ0002ZZ của
ZZ0003ZZ.

Tương tự, các tuyến kết nối chúng được triển khai tĩnh trong mảng ZZ0000ZZ và được khai báo thông qua
Các trường ZZ0001ZZ và ZZ0002ZZ có cùng cấu trúc.

Với những khai báo trên, việc đăng ký lái xe sẽ được thực hiện
điền chúng::

cấu trúc const tĩnh snd_soc_dapm_widget wm2000_dapm_widgets[] = {
  	SND_SOC_DAPM_OUTPUT("SPKN"),
  	SND_SOC_DAPM_OUTPUT("SPKP"),
  	...
  };

/* Đích, Đường dẫn, Nguồn */
  const tĩnh struct snd_soc_dapm_route wm2000_audio_map[] = {
  	{ "SPKN", NULL, "Động cơ ANC" },
  	{ "SPKP", NULL, "Động cơ ANC" },
	...
  };

  static const struct snd_soc_component_driver soc_component_dev_wm2000 = {
	...
  	.dapm_widgets		= wm2000_dapm_widgets,
  	.num_dapm_widgets	= ARRAY_SIZE(wm2000_dapm_widgets),
  	.dapm_routes            = wm2000_audio_map,
  	.num_dapm_routes        = ARRAY_SIZE(wm2000_audio_map),
	...
  };

Trong những trường hợp phức tạp hơn, danh sách các tiện ích và/hoặc tuyến đường DAPM chỉ có thể
đã biết tại thời điểm thăm dò. Điều này xảy ra ví dụ khi một trình điều khiển hỗ trợ
các mô hình khác nhau có một tập hợp các tính năng khác nhau. Trong những trường hợp đó
các widget và mảng tuyến đường riêng biệt triển khai các tính năng dành riêng cho từng trường hợp
có thể được đăng ký theo chương trình bằng cách gọi snd_soc_dapm_new_controls()
và snd_soc_dapm_add_routes().


Kết nối tiện ích Codec/DSP
=================================

Các widget được kết nối với nhau trong codec, nền tảng và máy bằng cách
đường dẫn âm thanh (được gọi là kết nối). Mỗi kết nối phải được xác định trong
để tạo biểu đồ của tất cả các đường dẫn âm thanh giữa các vật dụng.

Điều này dễ dàng nhất với sơ đồ codec hoặc DSP (và sơ đồ của máy
hệ thống âm thanh), vì nó yêu cầu nối các vật dụng lại với nhau thông qua tín hiệu âm thanh của chúng
những con đường.

Ví dụ: bộ trộn đầu ra WM8731 (wm8731.c) có 3 đầu vào (nguồn):

1. Đầu vào bỏ qua dòng
2. DAC (Phát HiFi)
3. Đầu vào âm thanh phụ của Mic

Mỗi đầu vào trong ví dụ này có một kcontrol liên kết với nó (được xác định trong
ví dụ ở trên) và được kết nối với bộ trộn đầu ra thông qua kcontrol của nó
tên. Bây giờ chúng ta có thể kết nối tiện ích đích (tín hiệu âm thanh wrt) với nó
các widget nguồn.  ::

/* Bộ trộn đầu ra */
	{"Bộ trộn đầu ra", "Công tắc bỏ qua dòng", "Đầu vào dòng"},
	{"Bộ trộn đầu ra", "Công tắc phát lại HiFi", "DAC"},
	{"Bộ trộn đầu ra", "Chuyển đổi âm thanh bên micrô", "Độ lệch micrô"},

Vì vậy, chúng tôi có:

* Tiện ích đích <=== Tên đường dẫn <=== Tiện ích nguồn hoặc
* Chìm, Đường dẫn, Nguồn hoặc
* ZZ0000ZZ được kết nối với ZZ0001ZZ thông qua ZZ0002ZZ.

Khi không có tên đường dẫn kết nối các tiện ích (ví dụ: kết nối trực tiếp), chúng tôi
chuyển NULL cho tên đường dẫn.

Các kết nối được tạo bằng lệnh gọi tới::

snd_soc_dapm_connect_input(codec, sink, path, source);

Cuối cùng, snd_soc_dapm_new_widgets() phải được gọi sau tất cả các widget và
kết nối đã được đăng ký với lõi. Điều này làm cho lõi
quét codec và máy để trạng thái DAPM bên trong khớp với
trạng thái vật lý của máy.


Kết nối Widget máy
-------------------------------
Các kết nối widget của máy được tạo theo cách tương tự như các kết nối codec và
kết nối trực tiếp các chân codec với các vật dụng ở cấp độ máy.

ví dụ. kết nối các chân codec của loa với loa bên trong.
::

/* loa ngoài được kết nối với các chân codec LOUT2, ROUT2 */
	{"Ext Spk", NULL , "ROUT2"},
	{"Ext Spk", NULL , "LOUT2"},

Điều này cho phép DAPM bật và tắt các chân được kết nối (và đang sử dụng)
và các chân tương ứng là NC.


Tiện ích điểm cuối
================
Điểm cuối là điểm bắt đầu hoặc điểm kết thúc (widget) của tín hiệu âm thanh trong
máy và bao gồm codec. ví dụ.

* Giắc cắm tai nghe
* Loa nội bộ
* Mic bên trong
* Giắc cắm mic
* Chân Codec

Điểm cuối được thêm vào biểu đồ DAPM để có thể xác định mức sử dụng của chúng trong
để tiết kiệm điện. ví dụ. Các chân codec NC sẽ được chuyển đổi OFF, không được kết nối
giắc cắm cũng có thể được chuyển đổi OFF.


Sự kiện tiện ích DAPM
==================

Các widget cần triển khai một hành vi phức tạp hơn những gì DAPM có thể làm
có thể đặt "trình xử lý sự kiện" tùy chỉnh bằng cách đặt con trỏ hàm. Một ví dụ
là nguồn điện cần kích hoạt GPIO::

int tĩnh sof_es8316_loa_power_event(struct snd_soc_dapm_widget *w,
  					  struct snd_kcontrol *kcontrol, sự kiện int)
  {
  	nếu (SND_SOC_DAPM_EVENT_ON(sự kiện))
  		gpiod_set_value_cansleep(gpio_pa, true);
  	khác
  		gpiod_set_value_cansleep(gpio_pa, false);

trả về 0;
  }

cấu trúc const tĩnh snd_soc_dapm_widget st_widgets[] = {
  	...
SND_SOC_DAPM_SUPPLY("Công suất loa", SND_SOC_NOPM, 0, 0,
  			    sof_es8316_loa_power_event,
  			    SND_SOC_DAPM_PRE_PMD | SND_SOC_DAPM_POST_PMU),
  };

Xem soc-dapm.h để biết tất cả các tiện ích khác hỗ trợ sự kiện.


Các loại sự kiện
-----------

Các loại sự kiện sau được hỗ trợ bởi các tiện ích sự kiện::

/*các loại sự kiện dapm */
  #define SND_SOC_DAPM_PRE_PMU 0x1 /* trước khi bật nguồn tiện ích */
  #define SND_SOC_DAPM_POST_PMU 0x2 /* sau khi bật nguồn tiện ích */
  #define SND_SOC_DAPM_PRE_PMD 0x4 /* trước khi tắt nguồn tiện ích */
  #define SND_SOC_DAPM_POST_PMD 0x8 /* sau khi tắt nguồn tiện ích */
  #define SND_SOC_DAPM_PRE_REG 0x10 /* trước khi thiết lập đường dẫn âm thanh */
  #define SND_SOC_DAPM_POST_REG 0x20 /* sau khi thiết lập đường dẫn âm thanh */
  #define SND_SOC_DAPM_WILL_PMU 0x40 /* được gọi khi bắt đầu chuỗi */
  #define SND_SOC_DAPM_WILL_PMD 0x80 /* được gọi khi bắt đầu chuỗi */
  #define SND_SOC_DAPM_PRE_POST_PMD (SND_SOC_DAPM_PRE_PMD | SND_SOC_DAPM_POST_PMD)
  #define SND_SOC_DAPM_PRE_POST_PMU (SND_SOC_DAPM_PRE_PMU | SND_SOC_DAPM_POST_PMU)
