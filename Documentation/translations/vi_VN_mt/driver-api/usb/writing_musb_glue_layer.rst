.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/usb/writing_musb_glue_layer.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Viết lớp keo MUSB
=========================

:Tác giả: Apelete Seketeli

Giới thiệu
============

Hệ thống con Linux MUSB là một phần của hệ thống con Linux USB lớn hơn. Nó
cung cấp hỗ trợ cho Bộ điều khiển thiết bị USB được nhúng (UDC) không
sử dụng Giao diện bộ điều khiển máy chủ chung (UHCI) hoặc Bộ điều khiển máy chủ mở
Giao diện (OHCI).

Thay vào đó, UDC được nhúng này dựa trên USB On-the-Go (OTG)
đặc điểm kỹ thuật mà họ thực hiện ít nhất một phần. Silicon
thiết kế tham chiếu được sử dụng trong hầu hết các trường hợp là Multipoint USB Highspeed
Bộ điều khiển vai trò kép (MUSB HDRC) được tìm thấy trong Mentor Graphics Inventra™
thiết kế.

Là một bài tập tự học, tôi đã viết một lớp keo MUSB cho
Ingenic JZ4740 SoC, được mô phỏng theo nhiều lớp keo MUSB trong
cây nguồn hạt nhân. Lớp này có thể được tìm thấy tại
ZZ0000ZZ. Trong tài liệu này tôi sẽ đi qua
những điều cơ bản về lớp keo ZZ0001ZZ, giải thích các phần khác nhau và
những gì cần phải làm để viết lớp keo cho thiết bị của riêng bạn.

.. _musb-basics:

Khái niệm cơ bản về Linux MUSB
=================

Để bắt đầu về chủ đề này, vui lòng đọc Thông tin cơ bản về USB khi di chuyển (xem
Resources) cung cấp phần giới thiệu về hoạt động USB OTG tại
mức độ phần cứng. Một vài trang wiki của Texas Instruments và Analog
Các thiết bị cũng cung cấp cái nhìn tổng quan về cấu hình MUSB của nhân Linux,
mặc dù tập trung vào một số thiết bị cụ thể được cung cấp bởi các công ty này.
Cuối cùng là làm quen với thông số USB tại trang chủ USB
có thể hữu ích, với ví dụ thực tế được cung cấp thông qua Bài viết
Tài liệu về Trình điều khiển Thiết bị USB (một lần nữa, xem Tài nguyên).

Ngăn xếp Linux USB là một kiến trúc phân lớp trong đó bộ điều khiển MUSB
phần cứng nằm ở mức thấp nhất. Trình điều khiển bộ điều khiển MUSB tóm tắt
Phần cứng bộ điều khiển MUSB cho ngăn xếp Linux USB::

---------------
	  ZZ0000ZZ <------- trình điều khiển/usb/tiện ích
	  ZZ0001ZZ <------- trình điều khiển/usb/máy chủ
	  ZZ0002ZZ <------- trình điều khiển/usb/lõi
	  ---------------
		     ⬍
	 -----------------
	 ZZ0003ZZ <------ trình điều khiển/usb/musb/musb_gadget.c
	 ZZ0004ZZ <------ trình điều khiển/usb/musb/musb_host.c
	 ZZ0005ZZ <------ trình điều khiển/usb/musb/musb_core.c
	 -----------------
		     ⬍
      ----------------------------------
      ZZ0006ZZ
      ZZ0007ZZ <- trình điều khiển/usb/musb/jz4740.c
      ZZ0008ZZ
      ----------------------------------
		     ⬍
      ----------------------------------
      ZZ0009ZZ
      ----------------------------------

Như đã nêu ở trên, lớp keo thực chất là mã dành riêng cho nền tảng
ngồi ở giữa trình điều khiển bộ điều khiển và phần cứng bộ điều khiển.

Giống như trình điều khiển Linux USB cần phải tự đăng ký với Linux USB
hệ thống con, lớp keo MUSB trước tiên cần phải đăng ký chính nó với
Trình điều khiển bộ điều khiển MUSB. Điều này sẽ cho phép trình điều khiển bộ điều khiển biết
về thiết bị nào lớp keo hỗ trợ và chức năng nào cần gọi
khi một thiết bị được hỗ trợ được phát hiện hoặc giải phóng; hãy nhớ chúng ta đang nói chuyện
về một chip điều khiển nhúng ở đây, do đó không cần chèn hoặc gỡ bỏ tại
thời gian chạy.

Tất cả thông tin này được chuyển đến trình điều khiển bộ điều khiển MUSB thông qua
cấu trúc ZZ0000ZZ được xác định trong lớp keo là::

cấu trúc tĩnh platform_driver jz4740_driver = {
	.probe = jz4740_probe,
	.remove = jz4740_remove,
	.driver = {
	    .name = "musb-jz4740",
	},
    };

Các con trỏ hàm thăm dò và loại bỏ được gọi khi một thiết bị phù hợp
được phát hiện và tương ứng được giải phóng. Chuỗi tên mô tả
thiết bị được hỗ trợ bởi lớp keo này. Trong trường hợp hiện tại nó phù hợp với một
cấu trúc platform_device được khai báo trong ZZ0000ZZ. Lưu ý
rằng chúng tôi không sử dụng liên kết cây thiết bị ở đây.

Để tự đăng ký với trình điều khiển bộ điều khiển, lớp keo
trải qua một vài bước, về cơ bản là phân bổ phần cứng bộ điều khiển
tài nguyên và khởi tạo một vài mạch. Để làm được như vậy, cần phải
theo dõi thông tin được sử dụng trong suốt các bước này. Việc này được thực hiện
bằng cách xác định cấu trúc ZZ0000ZZ riêng tư::

cấu trúc jz4740_glue {
	thiết bị cấu trúc *dev;
	struct platform_device *musb;
	struct clk *clk;
    };


Các thành viên dev và musb đều là các biến cấu trúc thiết bị. đầu tiên
một người nắm giữ thông tin chung về thiết bị vì đó là thông tin cơ bản
cấu trúc thiết bị và cái sau chứa thông tin liên quan chặt chẽ hơn
vào hệ thống con mà thiết bị được đăng ký. Biến clk giữ nguyên
thông tin liên quan đến hoạt động của đồng hồ thiết bị.

Chúng ta cùng đi qua các bước của hàm thăm dò dẫn keo nhé
lớp để đăng ký chính nó với trình điều khiển bộ điều khiển.

.. note::

   For the sake of readability each function will be split in logical
   parts, each part being shown as if it was independent from the others.

.. code-block:: c
    :emphasize-lines: 8,12,18

    static int jz4740_probe(struct platform_device *pdev)
    {
	struct platform_device      *musb;
	struct jz4740_glue      *glue;
	struct clk                      *clk;
	int             ret;

	glue = devm_kzalloc(&pdev->dev, sizeof(*glue), GFP_KERNEL);
	if (!glue)
	    return -ENOMEM;

	musb = platform_device_alloc("musb-hdrc", PLATFORM_DEVID_AUTO);
	if (!musb) {
	    dev_err(&pdev->dev, "failed to allocate musb device\n");
	    return -ENOMEM;
	}

	clk = devm_clk_get(&pdev->dev, "udc");
	if (IS_ERR(clk)) {
	    dev_err(&pdev->dev, "failed to get clock\n");
	    ret = PTR_ERR(clk);
	    goto err_platform_device_put;
	}

	ret = clk_prepare_enable(clk);
	if (ret) {
	    dev_err(&pdev->dev, "failed to enable clock\n");
	    goto err_platform_device_put;
	}

	musb->dev.parent        = &pdev->dev;

	glue->dev           = &pdev->dev;
	glue->musb          = musb;
	glue->clk           = clk;

	return 0;

    err_platform_device_put:
	platform_device_put(musb);
	return ret;
    }

Một vài dòng đầu tiên của hàm thăm dò phân bổ và gán keo,
biến musb và clk. Cờ ZZ0002ZZ (dòng 8) cho phép
quá trình phân bổ để ngủ và chờ bộ nhớ, do đó có thể sử dụng được trong
tình trạng khóa. Cờ ZZ0003ZZ (dòng 12) cho phép
tự động phân bổ và quản lý ID thiết bị để tránh
xung đột không gian tên thiết bị với ID rõ ràng. Với ZZ0000ZZ
(dòng 18) lớp keo phân bổ đồng hồ - tiền tố ZZ0004ZZ
chỉ ra rằng ZZ0001ZZ được quản lý: nó tự động giải phóng
dữ liệu tài nguyên đồng hồ được phân bổ khi thiết bị được giải phóng -- và bật
nó.



Sau đó là các bước đăng ký:

.. code-block:: c
    :emphasize-lines: 3,5,7,9,16

    static int jz4740_probe(struct platform_device *pdev)
    {
	struct musb_hdrc_platform_data  *pdata = &jz4740_musb_platform_data;

	pdata->platform_ops     = &jz4740_musb_ops;

	platform_set_drvdata(pdev, glue);

	ret = platform_device_add_resources(musb, pdev->resource,
			    pdev->num_resources);
	if (ret) {
	    dev_err(&pdev->dev, "failed to add resources\n");
	    goto err_clk_disable;
	}

	ret = platform_device_add_data(musb, pdata, sizeof(*pdata));
	if (ret) {
	    dev_err(&pdev->dev, "failed to add platform_data\n");
	    goto err_clk_disable;
	}

	return 0;

    err_clk_disable:
	clk_disable_unprepare(clk);
    err_platform_device_put:
	platform_device_put(musb);
	return ret;
    }

Bước đầu tiên là truyền dữ liệu thiết bị do keo giữ riêng
thêm lớp vào trình điều khiển bộ điều khiển thông qua ZZ0000ZZ
(dòng 7). Tiếp theo là truyền thông tin tài nguyên thiết bị, cũng riêng tư
được giữ tại thời điểm đó, thông qua ZZ0001ZZ (dòng 9).

Cuối cùng là chuyển dữ liệu cụ thể của nền tảng tới bộ điều khiển
lái xe (dòng 16). Dữ liệu nền tảng sẽ được thảo luận trong
ZZ0000ZZ, nhưng ở đây chúng ta đang xem xét
Con trỏ hàm ZZ0001ZZ (dòng 5) trong ZZ0002ZZ
cấu trúc (dòng 3). Con trỏ hàm này cho phép bộ điều khiển MUSB
trình điều khiển để biết chức năng nào cần gọi để vận hành thiết bị::

cấu trúc const tĩnh musb_platform_ops jz4740_musb_ops = {
	.init = jz4740_musb_init,
	.exit = jz4740_musb_exit,
    };

Ở đây chúng ta có trường hợp tối thiểu chỉ có các hàm init và exit
được gọi bởi trình điều khiển bộ điều khiển khi cần thiết. Sự thật là JZ4740 MUSB
bộ điều khiển là bộ điều khiển cơ bản, thiếu một số tính năng có trong các bộ điều khiển khác
bộ điều khiển, nếu không chúng ta cũng có thể có con trỏ tới một vài bộ điều khiển khác
các chức năng như chức năng quản lý năng lượng hoặc chức năng chuyển đổi
chẳng hạn, giữa chế độ OTG và chế độ không phải OTG.

Tại thời điểm của quá trình đăng ký, trình điều khiển
thực sự gọi hàm init:

   .. code-block:: c
    :emphasize-lines: 12,14

    static int jz4740_musb_init(struct musb *musb)
    {
musb->xceiv = usb_get_phy(USB_PHY_TYPE_USB2);
	if (!musb->xceiv) {
	    pr_err("HS UDC: chưa cấu hình bộ thu phát\n");
	    trả về -ENODEV;
	}

/* Silicon không triển khai thanh ghi ConfigData.
	 * Đặt dyn_fifo để tránh đọc cấu hình EP từ phần cứng.
	 */
	musb->dyn_fifo = true;

musb->isr = jz4740_musb_interrupt;

trả về 0;
    }

Mục tiêu của ZZ0000ZZ là nắm giữ bộ thu phát
dữ liệu trình điều khiển của phần cứng bộ điều khiển MUSB và chuyển nó sang MUSB
trình điều khiển, như thường lệ. Bộ thu phát là mạch điện bên trong
phần cứng bộ điều khiển chịu trách nhiệm gửi/nhận dữ liệu USB.
Vì đây là sự triển khai lớp vật lý của mô hình OSI,
bộ thu phát còn được gọi là PHY.

Việc nắm giữ dữ liệu trình điều khiển ZZ0002ZZ được thực hiện với ZZ0003ZZ
trả về một con trỏ tới cấu trúc chứa phiên bản trình điều khiển
dữ liệu. Một số lệnh tiếp theo (dòng 12 và 14) được sử dụng như một
quirk và thiết lập xử lý IRQ tương ứng. Quirks và xử lý IRQ
sẽ được thảo luận sau trong ZZ0000ZZ và
ZZ0001ZZ\ ::

int tĩnh jz4740_musb_exit(struct musb *musb)
    {
	usb_put_phy(musb->xceiv);

trả về 0;
    }

Đóng vai trò là đối tác của init, hàm thoát sẽ giải phóng MUSB
Trình điều khiển PHY khi phần cứng bộ điều khiển sắp được phát hành.

Một lần nữa, lưu ý rằng init và exit khá đơn giản trong trường hợp này do
bộ tính năng cơ bản của phần cứng bộ điều khiển JZ4740. Khi viết một
lớp keo Musb cho phần cứng bộ điều khiển phức tạp hơn, bạn có thể cần
để đảm nhiệm việc xử lý nhiều hơn trong hai chức năng đó.

Trở về từ hàm init, trình điều khiển bộ điều khiển MUSB nhảy trở lại
vào chức năng thăm dò::

int tĩnh jz4740_probe(struct platform_device *pdev)
    {
	ret = platform_device_add(musb);
	nếu (ret) {
	    dev_err(&pdev->dev, "không đăng ký được thiết bị musb\n");
	    đi tới err_clk_disable;
	}

trả về 0;

err_clk_disable:
	clk_disable_unprepare(clk);
    err_platform_device_put:
	platform_device_put(musb);
	trở lại ret;
    }

Đây là phần cuối cùng của quá trình đăng ký thiết bị nơi keo dán
lớp thêm thiết bị phần cứng bộ điều khiển vào thiết bị nhân Linux
phân cấp: ở giai đoạn này, tất cả thông tin đã biết về thiết bị đều được
được chuyển sang ngăn xếp lõi Linux USB:

   .. code-block:: c
    :emphasize-lines: 5,6

    static int jz4740_remove(struct platform_device *pdev)
    {
cấu trúc jz4740_glue *glue = platform_get_drvdata(pdev);

platform_device_unregister(keo->musb);
	clk_disable_unprepare(keo->clk);

trả về 0;
    }

Đóng vai trò là đối tác của đầu dò, chức năng xóa sẽ hủy đăng ký
Phần cứng bộ điều khiển MUSB (dòng 5) và vô hiệu hóa đồng hồ (dòng 6),
cho phép nó được kiểm soát.

.. _musb-handling-irqs:

Xử lý IRQ
=============

Ngoài ra, thiết lập cơ bản về phần cứng của bộ điều khiển MUSB và
đăng ký, lớp keo cũng chịu trách nhiệm xử lý các IRQ:

   .. code-block:: c
    :emphasize-lines: 7,9-11,14,24

    static irqreturn_t jz4740_musb_interrupt(int irq, void *__hci)
    {
cờ dài không dấu;
	irqreturn_t retval = IRQ_NONE;
	struct musb *musb = __hci;

spin_lock_irqsave(&musb->lock, flag);

musb->int_usb = musb_readb(musb->mregs, MUSB_INTRUSB);
	musb->int_tx = musb_readw(musb->mregs, MUSB_INTRTX);
	musb->int_rx = musb_readw(musb->mregs, MUSB_INTRRX);

/*
	 * Bộ điều khiển chỉ là tiện ích, trạng thái của các bit IRQ ở chế độ máy chủ là
	 * không xác định. Che dấu chúng để đảm bảo rằng lõi trình điều khiển Musb sẽ
	 * không bao giờ thấy chúng được thiết lập
	 */
	musb->int_usb &= MUSB_INTR_SUSPEND ZZ0000ZZ
	    MUSB_INTR_RESET | MUSB_INTR_SOF;

if (musb->int_usb |ZZ0000ZZ| musb->int_rx)
	    retval = musb_interrupt(musb);

spin_unlock_irqrestore(&musb->lock, flag);

trả lại;
    }

Ở đây lớp keo chủ yếu phải đọc các thanh ghi phần cứng có liên quan
và chuyển các giá trị của chúng tới trình điều khiển bộ điều khiển sẽ xử lý
sự kiện thực tế đã kích hoạt IRQ.

Phần quan trọng của trình xử lý ngắt được bảo vệ bởi
ZZ0000ZZ và đối tác ZZ0001ZZ
các chức năng (tương ứng là dòng 7 và 24), ngăn chặn sự gián đoạn
mã xử lý được chạy bởi hai luồng khác nhau cùng một lúc.

Sau đó, các thanh ghi ngắt liên quan được đọc (dòng 9 đến 11):

- ZZ0000ZZ: cho biết ngắt USB nào hiện đang hoạt động,

- ZZ0000ZZ: cho biết ngắt nào dành cho điểm cuối TX
   hiện đang hoạt động,

- ZZ0000ZZ: cho biết ngắt nào dành cho điểm cuối TX
   hiện đang hoạt động.

Lưu ý rằng ZZ0000ZZ được sử dụng để đọc tối đa các thanh ghi 8 bit, trong khi
ZZ0001ZZ cho phép chúng ta đọc tối đa các thanh ghi 16 bit. có
các chức năng khác có thể được sử dụng tùy thuộc vào kích thước thiết bị của bạn
sổ đăng ký. Xem ZZ0002ZZ để biết thêm thông tin.

Hướng dẫn trên dòng 18 là một vấn đề khác dành riêng cho JZ4740 USB
bộ điều khiển thiết bị, điều này sẽ được thảo luận sau trong ZZ0000ZZ.

Tuy nhiên, lớp keo vẫn cần đăng ký trình xử lý IRQ. Ghi nhớ
hướng dẫn trên dòng 14 của hàm init::

int tĩnh jz4740_musb_init(struct musb *musb)
    {
	musb->isr = jz4740_musb_interrupt;

trả về 0;
    }

Lệnh này đặt một con trỏ tới hàm xử lý lớp keo IRQ,
để phần cứng bộ điều khiển gọi lại bộ xử lý khi có
IRQ đến từ phần cứng bộ điều khiển. Trình xử lý ngắt bây giờ là
được thực hiện và đăng ký.

.. _musb-dev-platform-data:

Dữ liệu nền tảng thiết bị
====================

Để viết lớp keo MUSB, bạn cần có một số dữ liệu
mô tả khả năng phần cứng của phần cứng bộ điều khiển của bạn, trong đó
được gọi là dữ liệu nền tảng.

Dữ liệu nền tảng dành riêng cho phần cứng của bạn, mặc dù nó có thể bao gồm nhiều phạm vi
nhiều loại thiết bị và thường được tìm thấy ở đâu đó trong ZZ0000ZZ
thư mục, tùy thuộc vào kiến trúc thiết bị của bạn.

Ví dụ: dữ liệu nền tảng cho JZ4740 SoC được tìm thấy trong
ZZ0000ZZ. Trong tệp ZZ0001ZZ, mỗi thiết bị của
JZ4740 SoC được mô tả thông qua một tập hợp các cấu trúc.

Đây là một phần của ZZ0000ZZ bao gồm USB
Bộ điều khiển thiết bị (UDC):

   .. code-block:: c
    :emphasize-lines: 2,7,14-17,21,22,25,26,28,29

    /* USB Device Controller */
    struct platform_device jz4740_udc_xceiv_device = {
.name = "usb_phy_gen_xceiv",
	.id = 0,
    };

tài nguyên cấu trúc tĩnh jz4740_udc_resources[] = {
	[0] = {
	    .start = JZ4740_UDC_BASE_ADDR,
	    .end = JZ4740_UDC_BASE_ADDR + 0x10000 - 1,
	    .flags = IORESOURCE_MEM,
	},
	[1] = {
	    .start = JZ4740_IRQ_UDC,
	    .end = JZ4740_IRQ_UDC,
	    .flags = IORESOURCE_IRQ,
	    .name = "mc",
	},
    };

struct platform_device jz4740_udc_device = {
	.name = "musb-jz4740",
	.id = -1,
	.dev = {
	    .dma_mask = &jz4740_udc_device.dev.coherent_dma_mask,
	    .coherent_dma_mask = DMA_BIT_MASK(32),
	},
	.num_resources = ARRAY_SIZE(jz4740_udc_resources),
	.resource = jz4740_udc_resource,
    };

Cấu trúc thiết bị nền tảng ZZ0000ZZ (dòng 2)
mô tả bộ thu phát UDC với tên và số id.

Tại thời điểm viết bài này, lưu ý rằng ZZ0000ZZ là
tên cụ thể được sử dụng cho tất cả các bộ thu phát được tích hợp sẵn
với tham chiếu USB IP hoặc tự trị và không yêu cầu bất kỳ PHY nào
lập trình. Bạn sẽ cần đặt ZZ0001ZZ trong
cấu hình kernel để sử dụng bộ thu phát tương ứng
người lái xe. Trường id có thể được đặt thành -1 (tương đương với
ZZ0002ZZ), -2 (tương đương ZZ0003ZZ) hoặc
bắt đầu bằng 0 cho thiết bị đầu tiên thuộc loại này nếu chúng tôi muốn có một id cụ thể
số.

Cấu trúc tài nguyên ZZ0000ZZ (dòng 7) xác định UDC
đăng ký địa chỉ cơ sở.

Mảng đầu tiên (dòng 9 đến 11) xác định bộ nhớ cơ sở của thanh ghi UDC
địa chỉ: điểm bắt đầu đến địa chỉ bộ nhớ thanh ghi đầu tiên, điểm kết thúc
đến địa chỉ bộ nhớ thanh ghi cuối cùng và thành viên cờ xác định
loại tài nguyên mà chúng ta đang xử lý. Vì vậy ZZ0000ZZ được sử dụng để
xác định địa chỉ bộ nhớ của thanh ghi. Mảng thứ hai (dòng 14 đến 17)
xác định địa chỉ thanh ghi UDC IRQ. Vì chỉ có một chiếc IRQ
đăng ký có sẵn cho JZ4740 UDC, điểm bắt đầu và điểm kết thúc giống nhau
địa chỉ. Cờ ZZ0001ZZ cho biết chúng ta đang xử lý IRQ
tài nguyên và tên ZZ0002ZZ trên thực tế được mã hóa cứng trong lõi MUSB trong
ra lệnh cho trình điều khiển bộ điều khiển truy xuất tài nguyên IRQ này bằng cách
truy vấn nó bằng tên của nó.

Cuối cùng là cấu trúc thiết bị nền tảng ZZ0000ZZ (dòng 21)
mô tả chính UDC.

Tên ZZ0002ZZ (dòng 22) xác định trình điều khiển MUSB được sử dụng
cho thiết bị này; hãy nhớ rằng đây thực tế là tên mà chúng tôi đã sử dụng trong
Cấu trúc trình điều khiển nền tảng ZZ0003ZZ trong ZZ0000ZZ.
Trường id (dòng 23) được đặt thành -1 (tương đương ZZ0004ZZ)
vì chúng tôi không cần id cho thiết bị: trình điều khiển bộ điều khiển MUSB đã được
đã được thiết lập để phân bổ id tự động trong ZZ0001ZZ. Trong lĩnh vực phát triển
chúng tôi quan tâm đến thông tin liên quan đến DMA tại đây. Trường ZZ0005ZZ (dòng 25)
xác định chiều rộng của mặt nạ DMA sẽ được sử dụng và
ZZ0006ZZ (dòng 26) có cùng mục đích nhưng dành cho
Ánh xạ ZZ0007ZZ DMA: trong cả hai trường hợp, chúng tôi đều sử dụng mặt nạ 32 bit.
Khi đó trường tài nguyên (dòng 29) chỉ đơn giản là một con trỏ tới tài nguyên
cấu trúc được xác định trước đó, trong khi trường ZZ0008ZZ (dòng 28) giữ nguyên
theo dõi số lượng mảng được xác định trong cấu trúc tài nguyên (trong phần này
trường hợp có hai mảng tài nguyên được xác định trước đó).

Với tổng quan nhanh về dữ liệu nền tảng UDC ở cấp độ ZZ0000ZZ này
xong, chúng ta hãy quay lại dữ liệu nền tảng cụ thể của lớp keo MUSB trong
ZZ0001ZZ:

   .. code-block:: c
    :emphasize-lines: 3,5,7-9,11

    static struct musb_hdrc_config jz4740_musb_config = {
/* Silicon không triển khai USB OTG. */
	.đa điểm = 0,
	/* Số EP tối đa được quét, trình điều khiển sẽ quyết định EP nào có thể được sử dụng. */
	.num_eps = 4,
	/* RAMbit cần thiết để định cấu hình EP từ bảng */
	.ram_bits = 9,
	.fifo_cfg = jz4740_musb_fifo_cfg,
	.fifo_cfg_size = ARRAY_SIZE(jz4740_musb_fifo_cfg),
    };

cấu trúc tĩnh musb_hdrc_platform_data jz4740_musb_platform_data = {
	.mode = MUSB_PERIPHERAL,
	.config = &jz4740_musb_config,
    };

Đầu tiên lớp keo cấu hình một số khía cạnh của trình điều khiển bộ điều khiển
hoạt động liên quan đến chi tiết phần cứng của bộ điều khiển. Việc này được thực hiện
thông qua cấu trúc ZZ0001ZZ ZZ0000ZZ.

Xác định khả năng OTG của phần cứng bộ điều khiển, đa điểm
thành viên (dòng 3) được đặt thành 0 (tương đương với sai) vì JZ4740 UDC
không tương thích với OTG. Sau đó ZZ0002ZZ (dòng 5) xác định số USB
điểm cuối của phần cứng bộ điều khiển, bao gồm điểm cuối 0: ở đây chúng ta có
3 điểm cuối + điểm cuối 0. Tiếp theo là ZZ0003ZZ (dòng 7) là chiều rộng
của bus địa chỉ RAM cho phần cứng bộ điều khiển MUSB. Cái này
thông tin cần thiết khi trình điều khiển bộ điều khiển không thể tự động
định cấu hình điểm cuối bằng cách đọc phần cứng bộ điều khiển có liên quan
sổ đăng ký. Vấn đề này sẽ được thảo luận khi chúng ta đề cập đến các vấn đề của thiết bị trong
ZZ0000ZZ. Hai trường cuối cùng (dòng 8 và 9) cũng
về các đặc điểm của thiết bị: ZZ0004ZZ trỏ đến cấu hình điểm cuối USB
bảng và ZZ0005ZZ theo dõi kích thước của số lượng
các mục trong bảng cấu hình đó. Thông tin thêm về điều đó sau trong
ZZ0001ZZ.

Sau đó cấu hình này được nhúng bên trong ZZ0001ZZ
Cấu trúc ZZ0000ZZ (dòng 11): config là một con trỏ tới
chính cấu trúc cấu hình và chế độ sẽ thông báo cho trình điều khiển bộ điều khiển
nếu phần cứng bộ điều khiển chỉ có thể được sử dụng làm ZZ0002ZZ,
Chỉ ZZ0003ZZ hoặc ZZ0004ZZ là chế độ kép.

Hãy nhớ rằng ZZ0001ZZ sau đó được sử dụng để truyền tải
thông tin dữ liệu nền tảng như chúng ta đã thấy trong hàm thăm dò trong
ZZ0000ZZ.

.. _musb-dev-quirks:

Quirks của thiết bị
=============

Hoàn thành dữ liệu nền tảng dành riêng cho thiết bị của bạn, bạn cũng có thể cần
để viết một số mã trong lớp keo để xử lý một số thiết bị cụ thể
những hạn chế. Những hiện tượng lạ này có thể do một số lỗi phần cứng hoặc đơn giản là do
kết quả của việc triển khai USB On-the-Go không đầy đủ
đặc điểm kỹ thuật.

JZ4740 UDC có những điểm kỳ quặc như vậy, một số điểm chúng tôi sẽ thảo luận ở đây
vì mục đích hiểu biết sâu sắc mặc dù những điều này có thể không được tìm thấy trong
phần cứng bộ điều khiển mà bạn đang làm việc.

Trước tiên hãy quay lại hàm init:

   .. code-block:: c
    :emphasize-lines: 12

    static int jz4740_musb_init(struct musb *musb)
    {
musb->xceiv = usb_get_phy(USB_PHY_TYPE_USB2);
	if (!musb->xceiv) {
	    pr_err("HS UDC: chưa cấu hình bộ thu phát\n");
	    trả về -ENODEV;
	}

/* Silicon không triển khai thanh ghi ConfigData.
	 * Đặt dyn_fifo để tránh đọc cấu hình EP từ phần cứng.
	 */
	musb->dyn_fifo = true;

musb->isr = jz4740_musb_interrupt;

trả về 0;
    }

Hướng dẫn trên dòng 12 giúp trình điều khiển bộ điều khiển MUSB hoạt động
thực tế là phần cứng bộ điều khiển thiếu các thanh ghi được sử dụng
cho cấu hình điểm cuối USB.

Nếu không có các thanh ghi này, trình điều khiển bộ điều khiển không thể đọc được
cấu hình điểm cuối từ phần cứng, vì vậy chúng tôi sử dụng lệnh dòng 12
để bỏ qua việc đọc cấu hình từ silicon và dựa vào
thay vào đó, bảng được mã hóa cứng mô tả cấu hình điểm cuối ::

cấu trúc const tĩnh musb_fifo_cfg jz4740_musb_fifo_cfg[] = {
	{ .hw_ep_num = 1, .style = FIFO_TX, .maxpacket = 512, },
	{ .hw_ep_num = 1, .style = FIFO_RX, .maxpacket = 512, },
	{ .hw_ep_num = 2, .style = FIFO_TX, .maxpacket = 64, },
    };

Nhìn vào bảng cấu hình ở trên, chúng ta thấy rằng mỗi endpoint đều
được mô tả bởi ba trường: ZZ0000ZZ là số điểm cuối, kiểu là
hướng của nó (ZZ0001ZZ để trình điều khiển bộ điều khiển gửi các gói
trong phần cứng bộ điều khiển hoặc ZZ0002ZZ để nhận gói từ
phần cứng) và maxpacket xác định kích thước tối đa của mỗi gói dữ liệu
có thể được truyền qua điểm cuối đó. Đọc từ bảng,
Trình điều khiển bộ điều khiển biết rằng điểm cuối 1 có thể được sử dụng để gửi và nhận
Các gói dữ liệu USB 512 byte cùng một lúc (thực tế đây là một gói vào/ra hàng loạt
điểm cuối) và điểm cuối 2 có thể được sử dụng để gửi các gói dữ liệu 64 byte
cùng một lúc (thực tế đây là điểm cuối ngắt).

Lưu ý rằng không có thông tin nào về điểm cuối 0 ở đây: đó là
được triển khai theo mặc định trong mọi thiết kế silicon, với một quy tắc được xác định trước
cấu hình theo thông số kỹ thuật USB. Để biết thêm ví dụ về
bảng cấu hình điểm cuối, xem ZZ0000ZZ.

Bây giờ chúng ta quay lại chức năng xử lý ngắt:

   .. code-block:: c
    :emphasize-lines: 18-19

    static irqreturn_t jz4740_musb_interrupt(int irq, void *__hci)
    {
cờ dài không dấu;
	irqreturn_t retval = IRQ_NONE;
	struct musb *musb = __hci;

spin_lock_irqsave(&musb->lock, flag);

musb->int_usb = musb_readb(musb->mregs, MUSB_INTRUSB);
	musb->int_tx = musb_readw(musb->mregs, MUSB_INTRTX);
	musb->int_rx = musb_readw(musb->mregs, MUSB_INTRRX);

/*
	 * Bộ điều khiển chỉ là tiện ích, trạng thái của các bit IRQ ở chế độ máy chủ là
	 * không xác định. Che dấu chúng để đảm bảo rằng lõi trình điều khiển Musb sẽ
	 * không bao giờ thấy chúng được thiết lập
	 */
	musb->int_usb &= MUSB_INTR_SUSPEND ZZ0000ZZ
	    MUSB_INTR_RESET | MUSB_INTR_SOF;

if (musb->int_usb |ZZ0000ZZ| musb->int_rx)
	    retval = musb_interrupt(musb);

spin_unlock_irqrestore(&musb->lock, flag);

trả lại;
    }

Hướng dẫn ở dòng 18 trên là cách để driver điều khiển hoạt động
xung quanh thực tế là một số bit ngắt được sử dụng cho chế độ máy chủ USB
hoạt động bị thiếu trong thanh ghi ZZ0000ZZ, do đó bị bỏ lại trong một
trạng thái phần cứng không xác định, vì phần cứng bộ điều khiển MUSB này được sử dụng trong
chỉ chế độ ngoại vi. Kết quả là lớp keo che đi những
thiếu bit để tránh gián đoạn ký sinh trùng bằng cách thực hiện AND hợp lý
hoạt động giữa giá trị được đọc từ ZZ0001ZZ và các bit
thực sự được thực hiện trong sổ đăng ký.

Đây chỉ là một số điểm kỳ quặc được tìm thấy trong thiết bị JZ4740 USB
bộ điều khiển. Một số khác được xử lý trực tiếp trong lõi MUSB kể từ
các bản sửa lỗi đủ chung chung để cung cấp khả năng xử lý vấn đề tốt hơn
cuối cùng đối với phần cứng bộ điều khiển khác.

Phần kết luận
==========

Viết một lớp keo Linux MUSB sẽ là một nhiệm vụ dễ tiếp cận hơn, vì
tài liệu này cố gắng trình bày chi tiết về bài tập này.

Bộ điều khiển thiết bị JZ4740 USB khá đơn giản, tôi hy vọng nó sẽ kết dính tốt
lớp phục vụ như một ví dụ tốt cho tâm trí tò mò. Được sử dụng với
các lớp keo MUSB hiện tại, tài liệu này sẽ cung cấp đủ
hướng dẫn để bắt đầu; nếu có điều gì vượt quá tầm kiểm soát, linux-usb
kho lưu trữ danh sách gửi thư là một nguồn tài nguyên hữu ích khác để duyệt qua.

Lời cảm ơn
================

Rất cám ơn Lars-Peter Clausen và Maarten ter Huurne đã trả lời
câu hỏi của tôi khi tôi viết lớp keo JZ4740 và để được trợ giúp
tôi sẽ nhận được mã ở trạng thái tốt.

Tôi cũng muốn cảm ơn cộng đồng Qi-Hardware nói chung vì
hướng dẫn và hỗ trợ vui vẻ.

Tài nguyên
=========

USB Trang chủ: ZZ0000ZZ

Lưu trữ danh sách gửi thư linux-usb: ZZ0000ZZ

Thông tin cơ bản về USB khi di chuyển:
ZZ0000ZZ

ZZ0000ZZ

Trang Wiki cấu hình USB của Texas Instruments:
ZZ0000ZZ
