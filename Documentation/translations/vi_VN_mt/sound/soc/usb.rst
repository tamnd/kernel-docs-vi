.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/soc/usb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==================
Hỗ trợ ASoC USB
================

Tổng quan
========
Để tận dụng hỗ trợ thiết bị âm thanh USB hiện có trong ALSA,
API ASoC USB được giới thiệu để cho phép các hệ thống con trao đổi
thông tin cấu hình.

Một trường hợp sử dụng tiềm năng là hỗ trợ giảm tải âm thanh USB, đó là
việc triển khai cho phép đường dẫn được tối ưu hóa năng lượng thay thế trong âm thanh
hệ thống con để xử lý việc truyền dữ liệu âm thanh qua bus USB.  Điều này sẽ
hãy để bộ xử lý chính ở chế độ năng lượng thấp hơn trong thời gian dài hơn.  các
Sau đây là một thiết kế mẫu về cách có thể kết nối các phần ASoC và ALSA
cùng nhau đạt được điều này:

::

USB |            ASoC
                                     |  _________________________
                                     Thẻ nền tảng ZZ0000ZZ ASoC |
                                     ZZ0001ZZ_________________________|
                                     ZZ0002ZZ |
                                     |      ___V____ ____V____
                                     |     |ASoC BE | |ASoC FE |
                                     ZZ0005ZZDAI LNK ZZ0006ZZDAI LNK |
                                     ZZ0007ZZ________ZZ0008ZZ_________|
                                     |         ^ ^ ^
                                     ZZ0009ZZ ZZ0010ZZ
                                     ZZ0011ZZ
                                     |     |SoC-USB ZZ0013ZZ
     ________ ________ ZZ0014ZZ |
    ZZ0015ZZ<--->ZZ0016ZZ<------------>ZZ0017ZZ |
    ZZ0018ZZ ZZ0019ZZ<---------- |
    ZZ0020ZZ ZZ0021ZZ___ ZZ0022ZZ |
        ^ ^ ZZ0023ZZ |    ____________V_________
        ZZ0024ZZ ZZ0025ZZ ZZ0026ZZIPC |
     __ V_______________V_____ ZZ0027ZZ ZZ0028ZZ______________________|
    ZZ0029ZZ ZZ0030ZZ |              ^
    ZZ0031ZZ ZZ0032ZZ ZZ0033ZZ
                ^ ZZ0034ZZ |   ___________V___________
                ZZ0035ZZ ZZ0036ZZ->ZZ0037ZZ
     ___________V_____________ ZZ0038ZZ ZZ0039ZZ
    ZZ0040ZZ<- |
    ZZ0041ZZ |


Trình điều khiển SoC USB
==============
Cấu trúc
----------
ZZ0000ZZ

- ZZ0000ZZ: đầu danh sách cho danh sách cấu trúc SoC SND
  - ZZ0001ZZ: tham chiếu đến thành phần ASoC
  - ZZ0002ZZ: gọi lại để thông báo sự kiện kết nối
  - ZZ0003ZZ: gọi lại để tìm nạp card âm thanh USB/PCM đã chọn
    thiết bị
  - ZZ0004ZZ: dữ liệu trình điều khiển

Cấu trúc snd_soc_usb có thể được tham chiếu bằng thẻ nền tảng ASoC
thiết bị hoặc thiết bị USB (udev->dev).  Điều này được tạo bởi ASoC BE DAI
liên kết và thực thể âm thanh USB sẽ có thể truyền thông tin đến
Liên kết ASoC BE DAI sử dụng cấu trúc này.

ZZ0000ZZ

- ZZ0000ZZ: chỉ số card âm thanh liên kết với thiết bị âm thanh USB
  - ZZ0001ZZ: Chỉ số mảng chip âm thanh USB
  - ZZ0002ZZ: chụp các chỉ số thiết bị pcm liên kết với thiết bị âm thanh USB
  - ZZ0003ZZ: phát lại các chỉ mục thiết bị pcm được liên kết với thiết bị âm thanh USB
  - ZZ0004ZZ: số luồng phát lại
  - ZZ0005ZZ: số lượng luồng bắt
  - ZZ0006ZZ: đầu danh sách danh sách thiết bị âm thanh USB

Cấu trúc snd_soc_usb_device được tạo bởi trình điều khiển giảm tải âm thanh USB.
Điều này sẽ mang các tham số/giới hạn cơ bản sẽ được sử dụng để
xác định các đường dẫn giảm tải có thể có cho thiết bị âm thanh USB này.

Chức năng
---------
.. code-block:: rst

	int snd_soc_usb_find_supported_format(int card_idx,
			struct snd_pcm_hw_params *params, int direction)
..

  - ``card_idx``: the index into the USB sound chip array.
  - ``params``: Requested PCM parameters from the USB DPCM BE DAI link
  - ``direction``: capture or playback

ZZ0000ZZ đảm bảo rằng cấu hình âm thanh được yêu cầu
được yêu cầu bởi DSP bên ngoài được thiết bị USB hỗ trợ.

Trả về 0 nếu thành công và -EOPNOTSUPP nếu thất bại.

.. code-block:: rst

	int snd_soc_usb_connect(struct device *usbdev, struct snd_soc_usb_device *sdev)
..

  - ``usbdev``: the usb device that was discovered
  - ``sdev``: capabilities of the device

ZZ0000ZZ thông báo liên kết ASoC USB DCPM BE DAI của USB
phát hiện thiết bị âm thanh.  Điều này có thể được sử dụng trong BE DAI
trình điều khiển để theo dõi các thiết bị âm thanh USB có sẵn.  Điều này được dự định
được gọi bởi trình điều khiển giảm tải USB cư trú trong USB SND.

Trả về 0 nếu thành công, mã lỗi âm nếu thất bại.

.. code-block:: rst

	int snd_soc_usb_disconnect(struct device *usbdev, struct snd_soc_usb_device *sdev)
..

  - ``usbdev``: the usb device that was removed
  - ``sdev``: capabilities to free

ZZ0000ZZ thông báo liên kết ASoC USB DCPM BE DAI của USB
loại bỏ thiết bị âm thanh.  Điều này dự định được gọi bởi giảm tải USB
trình điều khiển nằm trong USB SND.

.. code-block:: rst

	void *snd_soc_usb_find_priv_data(struct device *usbdev)
..

  - ``usbdev``: the usb device to reference to find private data

ZZ0000ZZ tìm nạp dữ liệu riêng tư được lưu vào SoC USB
thiết bị.

Trả về con trỏ tới Priv_data nếu thành công, NULL nếu thất bại.

.. code-block:: rst

	int snd_soc_usb_setup_offload_jack(struct snd_soc_component *component,
					struct snd_soc_jack *jack)
..

  - ``component``: ASoC component to add the jack
  - ``jack``: jack component to populate

ZZ0000ZZ là công cụ trợ giúp để thêm điều khiển giắc âm thanh vào
card âm thanh nền tảng.  Điều này sẽ cho phép sử dụng cách đặt tên nhất quán trên
các thiết kế hỗ trợ giảm tải âm thanh USB.  Ngoài ra, điều này sẽ cho phép
jack để thông báo về những thay đổi.

Trả về 0 nếu thành công, ngược lại âm.

.. code-block:: rst

	int snd_soc_usb_update_offload_route(struct device *dev, int card, int pcm,
					     int direction, enum snd_soc_usb_kctl path,
					     long *route)
..

  - ``dev``: USB device to look up offload path mapping
  - ``card``: USB sound card index
  - ``pcm``: USB sound PCM device index
  - ``direction``: direction to fetch offload routing information
  - ``path``: kcontrol selector - pcm device or card index
  - ``route``: mapping of sound card and pcm indexes for the offload path.  This is
	       an array of two integers that will carry the card and pcm device indexes
	       in that specific order.  This can be used as the array for the kcontrol
	       output.

ZZ0001ZZ gọi một cuộc gọi lại đã đăng ký tới USB BE DAI
liên kết để lấy thông tin về các thiết bị ASoC được ánh xạ để thực thi âm thanh USB
giảm tải cho thiết bị. ZZ0000ZZ có thể là một con trỏ tới mảng đầu ra giá trị kcontrol,
mang các giá trị khi kcontrol được đọc.

Trả về 0 nếu thành công, ngược lại âm.

.. code-block:: rst

	struct snd_soc_usb *snd_soc_usb_allocate_port(struct snd_soc_component *component,
			void *data);
..

  - ``component``: DPCM BE DAI link component
  - ``data``: private data

ZZ0000ZZ phân bổ thiết bị SoC USB và điền tiêu chuẩn
các tham số được sử dụng cho các hoạt động tiếp theo.

Trả về một con trỏ tới struct soc_usb nếu thành công, âm nếu có lỗi.

.. code-block:: rst

	void snd_soc_usb_free_port(struct snd_soc_usb *usb);
..

  - ``usb``: SoC USB device to free

ZZ0000ZZ giải phóng thiết bị SoC USB.

.. code-block:: rst

	void snd_soc_usb_add_port(struct snd_soc_usb *usb);
..

  - ``usb``: SoC USB device to add

ZZ0000ZZ thêm thiết bị SoC USB được phân bổ vào khung SOC USB.
Sau khi được thêm vào, thiết bị này có thể được tham chiếu bằng các hoạt động tiếp theo.

.. code-block:: rst

	void snd_soc_usb_remove_port(struct snd_soc_usb *usb);
..

  - ``usb``: SoC USB device to remove

ZZ0000ZZ loại bỏ thiết bị SoC USB khỏi khung SoC USB.
Sau khi xóa thiết bị, mọi thao tác SOC USB sẽ không thể tham chiếu thiết bị
thiết bị đã được gỡ bỏ.

Cách đăng ký SoC USB
--------------------------
Liên kết ASoC DPCM USB BE DAI là thực thể chịu trách nhiệm phân bổ và
đăng ký thiết bị SoC USB trên liên kết thành phần.  Tương tự như vậy, nó sẽ
cũng chịu trách nhiệm giải phóng các tài nguyên được phân bổ.  Một ví dụ có thể
được hiển thị dưới đây:

.. code-block:: rst

	static int q6usb_component_probe(struct snd_soc_component *component)
	{
		...
		data->usb = snd_soc_usb_allocate_port(component, 1, &data->priv);
		if (!data->usb)
			return -ENOMEM;

		usb->connection_status_cb = q6usb_alsa_connection_cb;

		ret = snd_soc_usb_add_port(usb);
		if (ret < 0) {
			dev_err(component->dev, "failed to add usb port\n");
			goto free_usb;
		}
		...
	}

	static void q6usb_component_remove(struct snd_soc_component *component)
	{
		...
		snd_soc_usb_remove_port(data->usb);
		snd_soc_usb_free_port(data->usb);
	}

	static const struct snd_soc_component_driver q6usb_dai_component = {
		.probe = q6usb_component_probe,
		.remove = q6usb_component_remove,
		.name = "q6usb-dai-component",
		...
	};
..

Các liên kết BE DAI có thể chuyển thông tin cụ thể của nhà cung cấp như một phần của
gọi để phân bổ thiết bị SoC USB.  Điều này sẽ cho phép mọi liên kết BE DAI
các tham số hoặc cài đặt được truy cập bởi trình điều khiển giảm tải USB
cư trú tại USB SND.

Luồng kết nối thiết bị âm thanh USB
--------------------------------
Các thiết bị USB có thể được cắm nóng vào các cổng USB bất kỳ lúc nào.
Liên kết BE DAI phải biết trạng thái hiện tại của USB vật lý
cổng, tức là nếu có bất kỳ thiết bị USB nào có (các) giao diện âm thanh được kết nối.
Connection_status_cb() có thể được sử dụng để thông báo cho liên kết BE DAI về bất kỳ thay đổi nào.

Điều này được gọi bất cứ khi nào có sự kiện liên kết hoặc xóa giao diện USB SND,
sử dụng snd_soc_usb_connect() hoặc snd_soc_usb_disconnect():

.. code-block:: rst

	static void qc_usb_audio_offload_probe(struct snd_usb_audio *chip)
	{
		...
		snd_soc_usb_connect(usb_get_usb_backend(udev), sdev);
		...
	}

	static void qc_usb_audio_offload_disconnect(struct snd_usb_audio *chip)
	{
		...
		snd_soc_usb_disconnect(usb_get_usb_backend(chip->dev), dev->sdev);
		...
	}
..

Để giải thích các điều kiện trong đó trình điều khiển hoặc thiết bị tồn tại
không được đảm bảo, USB SND sẽ hiển thị snd_usb_rediscover_devices() để gửi lại
kết nối các sự kiện cho bất kỳ giao diện âm thanh USB nào được xác định.  Hãy xem xét
tình huống sau:

ZZ0000ZZ
	  | --> Các luồng âm thanh USB được phân bổ và lưu vào usb_chip[]
	  | --> Tuyên truyền sự kiện kết nối tới trình điều khiển giảm tải USB trong USB SND
	  | --> ZZ0001ZZ thoát do liên kết USB BE DAI chưa sẵn sàng

Đầu dò thành phần liên kết BE DAI
	  | --> Liên kết DAI được thăm dò và cổng SoC USB được phân bổ
	  | --> Sự kiện kết nối thiết bị âm thanh USB bị bỏ lỡ

Để đảm bảo không bỏ sót các sự kiện kết nối, ZZ0000ZZ
được thực thi khi thiết bị SoC USB được đăng ký.  Bây giờ, khi BE DAI
liên kết thăm dò thành phần xảy ra, sau đây nêu bật trình tự:

Đầu dò thành phần liên kết BE DAI
	  | --> Liên kết DAI được thăm dò và cổng SoC USB được phân bổ
	  | --> Đã thêm thiết bị SoC USB và ZZ0000ZZ chạy

ZZ0000ZZ
	  | --> Duyệt qua usb_chip[] và đối với vấn đề về mục nhập không phải NULL
	  |     ZZ0001ZZ

Trong trường hợp trình điều khiển giảm tải USB không được liên kết, trong khi USB SND đã sẵn sàng,
ZZ0000ZZ được gọi trong quá trình khởi tạo mô-đun.  Điều này cho phép
để kích hoạt đường dẫn giảm tải theo quy trình sau:

ZZ0000ZZ
	  | --> Các luồng âm thanh USB được phân bổ và lưu vào usb_chip[]
	  | --> Tuyên truyền sự kiện kết nối tới trình điều khiển giảm tải USB trong USB SND
	  | --> Trình điều khiển giảm tải USB ZZ0001ZZ đã sẵn sàng!

Đầu dò thành phần liên kết BE DAI
	  | --> Liên kết DAI được thăm dò và cổng SoC USB được phân bổ
	  | --> Không có sự kiện kết nối USB do thiếu trình điều khiển giảm tải USB

Đầu dò trình điều khiển giảm tải USB
	  | --> ZZ0000ZZ
	  | --> Gọi ZZ0001ZZ để thông báo về thiết bị

Kcontrols liên quan đến giảm tải USB
=============================
Chi tiết
-------
Các ứng dụng có thể sử dụng một bộ điều khiển k để giúp chọn âm thanh phù hợp
các thiết bị để kích hoạt tính năng giảm tải âm thanh USB.  SoC USB hiển thị get_offload_dev()
gọi lại mà thiết kế có thể sử dụng để đảm bảo rằng các chỉ số thích hợp được trả về
ứng dụng.

Thực hiện
--------------

ZZ0000ZZ

ZZ0000ZZ:

	::

0 [SM8250MTPWCD938]: sm8250 - SM8250-MTP-WCD9380-WSA8810-VA-D
						SM8250-MTP-WCD9380-WSA8810-VA-DMIC
	  1 [Seri ]: USB-Audio - Plantronics Blackwire 3225 Seri
						Plantronics Plantronics Blackwire
						3225 Seri tại usb-xhci-hcd.1.auto-1.1,
						đầy đủ sp
	  2 [C320M]: USB-Audio - Plantronics C320-M
                      Plantronics Plantronics C320-M tại usb-xhci-hcd.1.auto-1.2, tốc độ tối đa

ZZ0000ZZ:

	::

thẻ 0: SM8250MTPWCD938 [SM8250-MTP-WCD9380-WSA8810-VA-D], thiết bị 0: MultiMedia1 (*) []
	  Thiết bị phụ: 1/1
	  Thiết bị con #0: thiết bị con #0
	  thẻ 0: SM8250MTPWCD938 [SM8250-MTP-WCD9380-WSA8810-VA-D], thiết bị 1: MultiMedia2 (*) []
	  Thiết bị phụ: 1/1
	  Thiết bị con #0: thiết bị con #0
	  thẻ 1: Seri [Plantronics Blackwire 3225 Seri], thiết bị 0: Âm thanh USB [Âm thanh USB]
	  Thiết bị phụ: 1/1
	  Thiết bị con #0: thiết bị con #0
	  thẻ 2: C320M [Plantronics C320-M], thiết bị 0: USB Audio [USB Audio]
	  Thiết bị phụ: 1/1
	  Thiết bị con #0: thiết bị con #0

ZZ0000ZZ - card#1:

	::

USB Giảm tải lộ trình thẻ phát lại PCM#0 -1 (phạm vi -1->32)
	  USB Giảm tải Phát lại PCM Tuyến PCM#0 -1 (phạm vi -1->255)

ZZ0000ZZ - card#2:

	::

USB Giảm tải Thẻ phát lại Lộ trình PCM#0 0 (phạm vi -1->32)
	  USB Giảm tải Phát lại PCM Tuyến PCM#0 1 (phạm vi -1->255)

Ví dụ trên thể hiện tình huống trong đó hệ thống có một thẻ nền tảng ASoC
(card#0) và hai thiết bị âm thanh USB được kết nối (card#1 và card#2).  Khi đọc
các kcontrols có sẵn cho mỗi thiết bị âm thanh USB, danh sách kcontrols sau đây
thẻ giảm tải và chỉ mục thiết bị pcm được ánh xạ cho thiết bị USB cụ thể:

ZZ0000ZZ

ZZ0000ZZ

Kcontrol được lập chỉ mục vì thiết bị âm thanh USB có thể có
một số thiết bị PCM.  Các kcontrols ở trên được định nghĩa là:

- ZZ0000ZZ ZZ0001ZZ: Trả về âm thanh nền tảng ASoC
    chỉ mục thẻ cho đường dẫn giảm tải được ánh xạ.  Đầu ra ZZ0002ZZ (chỉ mục thẻ) biểu thị
    rằng có một đường dẫn giảm tải khả dụng cho thiết bị USB SND thông qua card#0.
    Nếu thấy ZZ0003ZZ thì nghĩa là không có đường dẫn giảm tải nào cho thiết bị USB SND.
    Kcontrol này tồn tại cho mỗi thiết bị âm thanh USB tồn tại trong hệ thống và
    dự kiến ​​sẽ lấy được trạng thái giảm tải hiện tại dựa trên giá trị đầu ra
    cho kcontrol cùng với kcontrol tuyến đường PCM.

- ZZ0000ZZ ZZ0001ZZ: Trả về âm thanh nền tảng ASoC
    Chỉ mục thiết bị PCM cho đường dẫn giảm tải được ánh xạ.  Đầu ra ZZ0002ZZ (chỉ mục thiết bị PCM)
    biểu thị rằng có một đường dẫn giảm tải khả dụng cho thiết bị USB SND thông qua
    Thiết bị PCM#0. Nếu ZZ0003ZZ được nhìn thấy thì không có đường dẫn giảm tải nào cho USB\
    Thiết bị SND.  Kcontrol này tồn tại cho mỗi thiết bị âm thanh USB tồn tại trong
    hệ thống và dự kiến ​​sẽ lấy được trạng thái giảm tải hiện tại dựa trên
    giá trị đầu ra cho kcontrol này, ngoài lộ trình thẻ kcontrol.

USB Offload Playback Route Kcontrol
-----------------------------------
Để cho phép nhà cung cấp triển khai cụ thể trên thiết bị giảm tải âm thanh
lựa chọn, lớp SoC USB hiển thị như sau:

.. code-block:: rst

	int (*update_offload_route_info)(struct snd_soc_component *component,
					 int card, int pcm, int direction,
					 enum snd_soc_usb_kctl path,
					 long *route)
..

Đây là những đặc trưng cho ZZ0000ZZ và **USB
Giảm tải PCM Route PCM#** kcontrols.

Khi người dùng thực hiện lệnh gọi tới kcontrol, lệnh gọi lại SoC USB đã đăng ký sẽ
thực hiện các lệnh gọi hàm đã đăng ký tới liên kết DPCM BE DAI.

ZZ0000ZZ

.. code-block:: rst

	static int q6usb_component_probe(struct snd_soc_component *component)
	{
	...
	usb = snd_soc_usb_allocate_port(component, 1, &data->priv);
	if (IS_ERR(usb))
		return -ENOMEM;

	usb->connection_status_cb = q6usb_alsa_connection_cb;
	usb->update_offload_route_info = q6usb_get_offload_dev;

	ret = snd_soc_usb_add_port(usb);
..

Kiểm soát âm thanh USB hiện có
---------------------------
Với việc giới thiệu hỗ trợ giảm tải USB, kcontrol giảm tải USB ở trên
sẽ được thêm vào danh sách kcontrols hiện có được xác định bởi âm thanh USB
khuôn khổ.  Các kcontrol này vẫn là các control chính được sử dụng để
sửa đổi các đặc điểm liên quan đến thiết bị âm thanh USB.

	::

Số lượng điều khiển: 9
	  ctl gõ num giá trị tên
	  0 INT 2 Chụp bản đồ kênh 0, 0 (phạm vi 0->36)
	  1 INT 2 Bản đồ kênh phát lại 0, 0 (phạm vi 0->36)
	  2 BOOL 1 Bật công tắc chụp tai nghe
	  3 INT 1 Chụp tai nghe Tập 10 (phạm vi 0->13)
	  4 BOOL 1 Bật phát lại âm phụ
	  5 INT 1 Âm lượng phát lại Sidetone 4096 (phạm vi 0->8192)
	  6 BOOL 1 Bật nút phát lại tai nghe
	  7 INT 2 Tai nghe Phát lại Âm lượng 20, 20 (phạm vi 0->24)
	  8 INT 1 USB Lộ trình thẻ phát lại giảm tải PCM#0 0 (phạm vi -1->32)
	  9 INT 1 USB Giảm tải Phát lại PCM Tuyến PCM#0 1 (phạm vi -1->255)

Vì các điều khiển thiết bị âm thanh USB được xử lý qua điểm cuối điều khiển USB, hãy sử dụng
các cơ chế hiện có trong bộ trộn USB để đặt các tham số, chẳng hạn như âm lượng.
