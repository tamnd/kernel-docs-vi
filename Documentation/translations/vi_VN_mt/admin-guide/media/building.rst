.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/building.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================================
Xây dựng hỗ trợ cho thiết bị đa phương tiện
===========================================

Bước đầu tiên là tải xuống mã nguồn của Kernel thông qua
tệp nguồn dành riêng cho phân phối hoặc thông qua cây git chính của Kernel\ [1]_.

Tuy nhiên, xin lưu ý rằng, nếu:

- bạn là người dũng cảm và muốn thử nghiệm những điều mới mẻ;
- nếu bạn muốn báo cáo lỗi;
- nếu bạn đang phát triển các bản vá mới

bạn nên sử dụng nhánh ZZ0000ZZ của cây phát triển phương tiện chính:

ZZ0000ZZ

Trong trường hợp này, bạn có thể tìm thấy một số thông tin hữu ích tại
ZZ0000ZZ:

ZZ0000ZZ

.. [1] The upstream Linux Kernel development tree is located at

       https://git.kernel.org/pub/scm/li  nux/kernel/git/torvalds/linux.git/

Cấu hình hạt nhân Linux
============================

Bạn có thể truy cập menu các tùy chọn xây dựng hạt nhân với::

$ tạo cấu hình menu

Sau đó, chọn tất cả các tùy chọn mong muốn và thoát khỏi nó, lưu cấu hình.

Cấu hình được thay đổi sẽ có ở file ZZ0000ZZ. Nó sẽ
trông giống như::

    ...
# ZZ0000ZZ chưa được đặt
    # ZZ0001ZZ chưa được đặt
    CONFIG_MEDIA_SUPPORT=m
    CONFIG_MEDIA_SUPPORT_FILTER=y
    ...

Hệ thống con phương tiện được điều khiển bởi các tùy chọn cấu hình menu đó::

Trình điều khiển thiết bị --->
	<M> Hỗ trợ bộ điều khiển từ xa --->
	[ ] HDMI CEC RC tích hợp
	[ ] Kích hoạt tính năng hỗ trợ chèn lỗi CEC
	[*] Trình điều khiển HDMI CEC --->
	<*> Hỗ trợ đa phương tiện --->

Tùy chọn ZZ0000ZZ cho phép hỗ trợ cốt lõi cho
bộ điều khiển từ xa\ [2]_.

Tùy chọn ZZ0000ZZ cho phép tích hợp HDMI CEC
với Linux, cho phép nhận dữ liệu qua HDMI CEC như được sản xuất
bằng bộ điều khiển từ xa được kết nối trực tiếp với máy.

Tùy chọn ZZ0000ZZ cho phép chọn nền tảng và trình điều khiển USB
nhận và/hoặc truyền mã CEC qua giao diện HDMI\ [3]_.

Tùy chọn cuối cùng (ZZ0000ZZ) cho phép hỗ trợ máy ảnh,
công cụ lấy âm thanh/video và TV.

Hỗ trợ hệ thống con phương tiện có thể được xây dựng cùng với hệ thống chính
Hạt nhân hoặc dưới dạng mô-đun. Đối với hầu hết các trường hợp sử dụng, nên có nó
được xây dựng dưới dạng mô-đun.

.. note::

   Instead of using a menu, the Kernel provides a script with allows
   enabling configuration options directly. To enable media support
   and remote controller support using Kernel modules, you could use::

	$ scripts/config -m RC_CORE
	$ scripts/config -m MEDIA_SUPPORT

.. [2] ``Remote Controller support`` should also be enabled if you
       want to use some TV card drivers that may depend on the remote
       controller core support.

.. [3] Please notice that the DRM subsystem also have drivers for GPUs
       that use the media HDMI CEC support.

       Those GPU-specific drivers are selected via the ``Graphics support``
       menu, under ``Device Drivers``.

       When a GPU driver supports HDMI CEC, it will automatically
       enable the CEC core support at the media subsystem.

Phụ thuộc phương tiện
------------------

Cần lưu ý rằng việc kích hoạt những điều trên từ một cấu hình sạch là
thường là không đủ. Hệ thống con phương tiện phụ thuộc vào một số Linux khác
hỗ trợ cốt lõi để làm việc.

Ví dụ: hầu hết các thiết bị đa phương tiện đều sử dụng bus truyền thông nối tiếp trong
để nói chuyện với một số thiết bị ngoại vi. Xe buýt như vậy được gọi là I²C
(Mạch tích hợp liên ngành). Để có thể xây dựng được sự hỗ trợ
đối với phần cứng như vậy, hỗ trợ bus I2C phải được bật thông qua
thực đơn hoặc với::

./scripts/config -m I2C

Một ví dụ khác: lõi điều khiển từ xa yêu cầu hỗ trợ cho
thiết bị đầu vào, có thể được bật bằng::

./scripts/config -m INPUT

Chức năng cốt lõi khác cũng có thể cần thiết (như hỗ trợ PCI và/hoặc USB),
tùy thuộc vào (các) trình điều khiển cụ thể mà bạn muốn kích hoạt.

Kích hoạt hỗ trợ bộ điều khiển từ xa
----------------------------------

Menu điều khiển từ xa cho phép chọn trình điều khiển cho các thiết bị cụ thể.
Menu của nó trông như thế này::

--- Hỗ trợ điều khiển từ xa
         <M> Biên dịch các mô-đun sơ đồ bàn phím của Bộ điều khiển từ xa
         [*] Giao diện người dùng LIRC
         [*] Hỗ trợ các chương trình eBPF gắn liền với thiết bị lirc
         [*] Bộ giải mã điều khiển từ xa --->
         [*] Thiết bị điều khiển từ xa --->

Tùy chọn ZZ0000ZZ tạo bản đồ chính cho
một số bộ điều khiển từ xa phổ biến

Tùy chọn ZZ0000ZZ bổ sung thêm chức năng nâng cao khi sử dụng
Chương trình ZZ0001ZZ, bằng cách kích hoạt API cho phép không gian người dùng nhận dữ liệu thô
từ các bộ điều khiển từ xa.

Tùy chọn ZZ0000ZZ cho phép
việc sử dụng các chương trình đặc biệt (được gọi là eBPF) cho phép các ứng dụng
để thêm chức năng giải mã bộ điều khiển từ xa bổ sung vào Nhân Linux.

Tùy chọn ZZ0000ZZ cho phép chọn
các giao thức sẽ được hạt nhân Linux công nhận. Ngoại trừ nếu bạn
muốn tắt một số bộ giải mã cụ thể, bạn nên giữ lại tất cả
tùy chọn phụ được kích hoạt.

ZZ0000ZZ cho phép bạn chọn trình điều khiển
điều đó sẽ cần thiết để hỗ trợ thiết bị của bạn.

Cấu hình tương tự cũng có thể được đặt thông qua ZZ0000ZZ
kịch bản. Vì vậy, ví dụ, để hỗ trợ bộ điều khiển từ xa ITE
trình điều khiển (được tìm thấy trên Intel NUC và trên một số máy tính để bàn ASUS x86), bạn có thể thực hiện ::

$ script/config -e INPUT
	$ script/config -e ACPI
	$ script/config -e MODULES
	$ script/config -m RC_CORE
	$ script/config -e RC_DEVICES
	$ script/config -e RC_DECODERS
	$ script/config -m IR_RC5_DECODER
	$ script/config -m IR_ITE_CIR

Kích hoạt HDMI CEC Hỗ trợ
-------------------------

Hỗ trợ HDMI CEC được đặt tự động khi trình điều khiển yêu cầu. Vì vậy,
tất cả những gì bạn cần làm là kích hoạt hỗ trợ cho card đồ họa
cần nó hoặc bằng một trong các trình điều khiển HDMI hiện có.

Trình điều khiển dành riêng cho HDMI có sẵn tại ZZ0000ZZ
thực đơn\ [4]_::

--- Trình điều khiển HDMI CEC
	< > Trình điều khiển ChromeOS EC CEC
	< > Trình điều khiển Amlogic Meson AO CEC
	< > Trình điều khiển Amlogic Meson G12A AO CEC
	< > Trình điều khiển CEC dựa trên GPIO chung
	< > Trình điều khiển Samsung S5P CEC
	< > STMicroelectronics Trình điều khiển STiH4xx HDMI CEC
	< > Trình điều khiển STMicroelectronics STM32 HDMI CEC
	< > Trình điều khiển Tegra HDMI CEC
	< > Trình điều khiển SECO Bo mạch HDMI CEC
	[ ] Hỗ trợ bo mạch SECO IR RC5
	< > Xung 8 HDMI CEC
	< > RainShadow Tech HDMI CEC

.. [4] The above contents is just an example. The actual options for
       HDMI devices depends on the system's architecture and may vary
       on new Kernels.

Kích hoạt hỗ trợ phương tiện
----------------------

Menu Media có nhiều tùy chọn hơn menu điều khiển từ xa.
Sau khi chọn, bạn sẽ thấy các tùy chọn sau::

--- Hỗ trợ truyền thông
	[ ] Lọc trình điều khiển phương tiện
	[*] Tự động chọn trình điều khiển phụ trợ
	    Các loại thiết bị đa phương tiện --->
	    Hỗ trợ cốt lõi truyền thông --->
	    Tùy chọn Video4Linux --->
	    Tùy chọn bộ điều khiển phương tiện --->
	    Tùy chọn TV kỹ thuật số --->
	    Tùy chọn HDMI CEC --->
	    Trình điều khiển phương tiện --->
	    Trình điều khiển phụ trợ phương tiện --->

Ngoại trừ trường hợp bạn biết chính xác mình đang làm gì hoặc nếu bạn muốn xây dựng
trình điều khiển cho nền tảng SoC, bạn nên giữ nguyên
Tùy chọn ZZ0000ZZ được bật vì nó sẽ tự động chọn
các trình điều khiển phụ trợ I²C cần thiết.

Hiện tại có hai cách để chọn trình điều khiển thiết bị đa phương tiện, như được mô tả
bên dưới.

Thực đơn ZZ0000ZZ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Menu này nhằm mục đích dễ dàng thiết lập cho phần cứng PC và Laptop. Nó hoạt động
bằng cách cho phép người dùng chỉ định loại trình điều khiển phương tiện mong muốn,
với các tùy chọn đó::

[ ] Máy ảnh và công cụ lấy video
	[ ] Truyền hình analog
	[ ] Truyền hình kỹ thuật số
	[ ] Máy thu/phát đài AM/FM
	[ ] Đài phát thanh được xác định bằng phần mềm
	[ ] Thiết bị dành riêng cho nền tảng
	[ ] Trình điều khiển thử nghiệm

Vì vậy, nếu bạn chỉ muốn thêm hỗ trợ cho máy ảnh hoặc trình thu thập video,
chỉ chọn tùy chọn đầu tiên. Nhiều lựa chọn được cho phép.

Khi các tùy chọn trên menu này được chọn, hệ thống tòa nhà sẽ
tự động chọn các trình điều khiển cốt lõi cần thiết để hỗ trợ các lựa chọn
chức năng.

.. note::

   Most TV cards are hybrid: they support both Analog TV and Digital TV.

   If you have an hybrid card, you may need to enable both ``Analog TV``
   and ``Digital TV`` at the menu.

Khi sử dụng tùy chọn này, các giá trị mặc định cho lõi hỗ trợ phương tiện
chức năng thường đủ tốt để cung cấp chức năng cơ bản
cho người lái xe. Tuy nhiên, bạn có thể kích hoạt thủ công một số tính năng bổ sung mong muốn (tùy chọn)
chức năng bằng cách sử dụng các cài đặt theo từng mục sau đây
Menu phụ ZZ0000ZZ::

Hỗ trợ cốt lõi truyền thông --->
	    Tùy chọn Video4Linux --->
	    Tùy chọn bộ điều khiển phương tiện --->
	    Tùy chọn TV kỹ thuật số --->
	    Tùy chọn HDMI CEC --->

Sau khi bạn chọn các bộ lọc mong muốn, các trình điều khiển phù hợp với bộ lọc sẽ
tiêu chí sẽ có sẵn trong menu phụ ZZ0000ZZ.

Menu ZZ0000ZZ không lọc
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Nếu bạn tắt menu ZZ0000ZZ, tất cả các trình điều khiển đều có sẵn
đối với hệ thống của bạn có sự phụ thuộc được đáp ứng sẽ được hiển thị ở
Thực đơn ZZ0001ZZ.

Tuy nhiên, xin lưu ý rằng trước tiên bạn phải đảm bảo rằng
Menu ZZ0000ZZ có tất cả các chức năng cốt lõi của trình điều khiển của bạn
sẽ cần, nếu không trình điều khiển thiết bị tương ứng sẽ không được hiển thị.

Ví dụ
-------

Để kích hoạt hỗ trợ mô-đun cho một trong các bảng được liệt kê trên
ZZ0000ZZ, với các mô-đun lõi phương tiện mô-đun,
Tệp ZZ0001ZZ phải chứa các dòng đó ::

CONFIG_MODULES=y
    CONFIG_USB=y
    CONFIG_I2C=y
    CONFIG_INPUT=y
    CONFIG_RC_CORE=m
    CONFIG_MEDIA_SUPPORT=m
    CONFIG_MEDIA_SUPPORT_FILTER=y
    CONFIG_MEDIA_ANALOG_TV_SUPPORT=y
    CONFIG_MEDIA_DIGITAL_TV_SUPPORT=y
    CONFIG_MEDIA_USB_SUPPORT=y
    CONFIG_VIDEO_CX231XX=y
    CONFIG_VIDEO_CX231XX_DVB=y

Xây dựng và cài đặt Kernel mới
====================================

Khi tệp ZZ0000ZZ có mọi thứ cần thiết, tất cả những gì cần thiết để xây dựng
là chạy lệnh ZZ0001ZZ ::

$ kiếm được

Và sau đó cài đặt Kernel mới và các mô-đun của nó ::

$ sudo tạo module_install
    $ sudo thực hiện cài đặt

Chỉ xây dựng các trình điều khiển phương tiện và lõi mới
============================================

Chạy hạt nhân phát triển mới từ cây phát triển thường có rủi ro,
bởi vì nó có thể có những thay đổi mang tính thử nghiệm và có thể có lỗi. Vì vậy, có
một số cách để xây dựng các trình điều khiển mới, sử dụng các cây thay thế.

Có ZZ0000ZZ, có chứa
trình điều khiển mới hơn có nghĩa là được biên dịch dựa trên Hạt nhân ổn định.

Các nhà phát triển LinuxTV chịu trách nhiệm duy trì phương tiện truyền thông
hệ thống con cũng duy trì một cây backport, chỉ với các trình điều khiển phương tiện
cập nhật hàng ngày từ kernel mới nhất. Cây như vậy có sẵn tại:

ZZ0000ZZ

Cần lưu ý rằng, mặc dù việc sử dụng công cụ này tương đối an toàn.
Cây ZZ0000ZZ nhằm mục đích thử nghiệm, không có bảo đảm nào về điều đó
nó sẽ hoạt động (hoặc thậm chí xây dựng) trên một hạt nhân ngẫu nhiên. Cây này được duy trì
sử dụng nguyên tắc "nỗ lực hết sức" vì thời gian cho phép chúng tôi khắc phục các vấn đề ở đó.

Nếu bạn nhận thấy bất cứ điều gì sai trên đó, vui lòng gửi các bản vá tại
Danh sách gửi thư của hệ thống con phương tiện Linux: media@vger.kernel.org. làm ơn
thêm ZZ0000ZZ vào chủ đề email nếu bạn gửi email mới
bản vá cho media-build.

Trước khi sử dụng, bạn nên chạy::

$ ./xây dựng

.. note::

    1) you may need to run it twice if the ``media-build`` tree gets
       updated;
    2) you may need to do a ``make distclean`` if you had built it
       in the past for a different Kernel version than the one you're
       currently using;
    3) by default, it will use the same config options for media as
       the ones defined on the Kernel you're running.

Để chọn các trình điều khiển khác nhau hoặc các tùy chọn cấu hình khác nhau,
sử dụng::

$ tạo cấu hình menu

Sau đó, bạn có thể xây dựng và cài đặt trình điều khiển mới::

$ thực hiện && sudo thực hiện cài đặt

Điều này sẽ ghi đè các trình điều khiển phương tiện trước đó mà Kernel của bạn đã có
sử dụng.