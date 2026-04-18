.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/soc/machine.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================
Trình điều khiển máy ASoC
===================

Trình điều khiển máy (hoặc bo mạch) ASoC là mã kết dính tất cả các
trình điều khiển thành phần (ví dụ: codec, nền tảng và DAI). Nó cũng mô tả các
mối quan hệ giữa từng thành phần bao gồm đường dẫn âm thanh, GPIO,
ngắt, xung nhịp, giắc cắm và bộ điều chỉnh điện áp.

Trình điều khiển máy có thể chứa codec và mã dành riêng cho nền tảng. Nó đăng ký
hệ thống con âm thanh với hạt nhân là thiết bị nền tảng và được biểu thị bằng
cấu trúc sau: -
::

/* Máy SoC */
  cấu trúc snd_soc_card {
	char *tên;

	...

int (*probe)(struct platform_device *pdev);
	int (*remove)(struct platform_device *pdev);

/* các hàm PM trước và sau được sử dụng để thực hiện bất kỳ công việc PM nào trước và sau
	 * sau khi codec và DAI thực hiện bất kỳ công việc PM nào. */
	int (trạng thái *suspend_pre)(struct platform_device *pdev, pm_message_t);
	int (trạng thái *suspend_post)(struct platform_device *pdev, pm_message_t);
	int (*resume_pre)(struct platform_device *pdev);
	int (*resume_post)(struct platform_device *pdev);

	...

/* CPU <--> Liên kết Codec DAI */
	cấu trúc snd_soc_dai_link *dai_link;
	int num_links;

	...
  };

thăm dò()/xóa()
----------------
thăm dò/loại bỏ là tùy chọn. Thực hiện bất kỳ thăm dò máy cụ thể nào ở đây.


đình chỉ()/tiếp tục()
------------------
Trình điều khiển máy có phiên bản tạm dừng và tiếp tục trước và sau để lưu ý
của bất kỳ tác vụ âm thanh nào của máy phải được thực hiện trước hoặc sau codec, DAI
và DMA bị tạm dừng và tiếp tục lại. Không bắt buộc.


Cấu hình máy DAI
-------------------------
Cấu hình DAI của máy dán tất cả codec và CPU DAI lại với nhau. Nó có thể
cũng được sử dụng để thiết lập đồng hồ hệ thống DAI và cho mọi máy liên quan đến DAI
khởi tạo, ví dụ: bản đồ âm thanh của máy có thể được kết nối với âm thanh codec
bản đồ, các chân codec không được kết nối có thể được đặt như vậy.

struct snd_soc_dai_link được sử dụng để thiết lập từng DAI trong máy của bạn. ví dụ.
::

/* keo giao diện âm thanh kỹ thuật số corgi - kết nối codec <--> CPU */
  cấu trúc tĩnh snd_soc_dai_link corgi_dai = {
	.name = "WM8731",
	.stream_name = "WM8731",
	.cpu_dai_name = "pxa-is2-dai",
	.codec_dai_name = "wm8731-hifi",
	.platform_name = "pxa-pcm-audio",
	.codec_name = "wm8713-codec.0-001a",
	.init = corgi_wm8731_init,
	.ops = &corgi_ops,
  };

Trong cấu trúc trên, dai được đăng ký bằng tên nhưng bạn có thể chuyển
tên dai hoặc nút cây thiết bị nhưng không phải cả hai. Ngoài ra, tên được sử dụng ở đây
đối với cpu/codec/nền tảng dais phải là duy nhất trên toàn cầu.

Ngoài ra, macro ví dụ bên dưới có thể được sử dụng để đăng ký cpu, codec và
nền tảng dai::

SND_SOC_DAILINK_DEFS(wm2200_cpu_dsp,
	DAILINK_COMP_ARRAY(COMP_CPU("samsung-i2s.0")),
	DAILINK_COMP_ARRAY(COMP_CODEC("spi0.0", "wm0010-sdi1")),
	DAILINK_COMP_ARRAY(COMP_PLATFORM("samsung-i2s.0")));

struct snd_soc_card sau đó thiết lập máy với DAI của nó. ví dụ.
::

/*trình điều khiển máy âm thanh corgi */
  cấu trúc tĩnh snd_soc_card snd_soc_corgi = {
	.name = "Corgi",
	.dai_link = &corgi_dai,
	.num_links = 1,
  };

Sau đó, ZZ0000ZZ có thể được sử dụng để đăng ký
card âm thanh. Trong quá trình đăng ký, các thành phần riêng lẻ
chẳng hạn như codec, CPU và nền tảng đều được thăm dò. Nếu tất cả các thành phần này
được thăm dò thành công, card âm thanh sẽ được đăng ký.

Bản đồ công suất máy
-----------------

Trình điều khiển máy có thể tùy ý mở rộng bản đồ nguồn codec và trở thành một
bản đồ công suất âm thanh của hệ thống con âm thanh. Điều này cho phép tự động bật/tắt nguồn
của loa/bộ khuếch đại HP, v.v. Các chân Codec có thể được kết nối với giắc cắm của máy
socket trong chức năng init của máy.


Điều khiển máy
----------------

Có thể thêm các điều khiển bộ trộn âm thanh dành riêng cho máy trong chức năng init DAI.


Kiểm soát đồng hồ
-----------------

Như đã lưu ý trước đó, cấu hình đồng hồ được xử lý trong trình điều khiển máy.
Để biết chi tiết về API đồng hồ mà trình điều khiển máy có thể sử dụng cho
thiết lập, vui lòng tham khảo Tài liệu/sound/soc/clocking.rst. Tuy nhiên,
cuộc gọi lại cần được đăng ký bởi trình điều khiển CPU/Codec/Platform để định cấu hình
đồng hồ cần thiết cho hoạt động của thiết bị tương ứng.
