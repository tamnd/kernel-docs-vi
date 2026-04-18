.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/soundwire/stream.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Luồng âm thanh trong SoundWire
==============================

Luồng âm thanh là kết nối logic hoặc ảo được tạo giữa

(1) (Các) bộ nhớ đệm hệ thống và (các) Codec

(2) (Các) bộ nhớ đệm và Codec DSP

(3) FIFO và (các) Codec

(4) (Các) Codec và (các) Codec

thường được điều khiển bởi kênh DMA(s) thông qua liên kết dữ liệu. Một
luồng âm thanh chứa một hoặc nhiều kênh dữ liệu. Tất cả các kênh trong
luồng phải có cùng tốc độ mẫu và cùng cỡ mẫu.

Giả sử luồng có hai kênh (Trái & Phải) được mở bằng SoundWire
giao diện. Dưới đây là một số cách thể hiện luồng trong SoundWire.

Truyền mẫu trong bộ nhớ (Bộ nhớ hệ thống, bộ nhớ DSP hoặc FIFO)::

-------------------------
	ZZ0000ZZ R ZZ0001ZZ R ZZ0002ZZ R |
	-------------------------

Ví dụ 1: Dòng âm thanh nổi có kênh L và R được kết xuất từ Master sang
Nô lệ. Cả Master và Slave đều sử dụng một cổng. ::

+--------------+ Tín hiệu đồng hồ +--------------+
	ZZ0000ZZ
	ZZ0001ZZ ZZ0002ZZ
	ZZ0003ZZ ZZ0004ZZ
	Tín hiệu dữ liệu ZZ0005ZZ ZZ0006ZZ
	ZZ0007ZZ
	Hướng dữ liệu ZZ0008ZZ ZZ0009ZZ
	+--------------+ +--------------> +--------------+


Ví dụ 2: Luồng âm thanh nổi có kênh L và R được thu từ Slave sang
Thầy ơi. Cả Master và Slave đều sử dụng một cổng. ::


+--------------+ Tín hiệu đồng hồ +--------------+
	ZZ0000ZZ
	ZZ0001ZZ ZZ0002ZZ
	ZZ0003ZZ ZZ0004ZZ
	Tín hiệu dữ liệu ZZ0005ZZ ZZ0006ZZ
	ZZ0007ZZ
	Hướng dữ liệu ZZ0008ZZ ZZ0009ZZ
	+--------------+ <--------------+ +---------------+


Ví dụ 3: Luồng âm thanh nổi có kênh L và R được hiển thị bởi Master. Mỗi
của kênh L và R được nhận bởi hai Slave khác nhau. Thầy và cả hai
Nô lệ đang sử dụng một cổng. ::

+--------------+ Tín hiệu đồng hồ +--------------+
	ZZ0000ZZ
	Giao diện ZZ0001ZZ ZZ0002ZZ |
	ZZ0003ZZ ZZ0004ZZ 1 |
	ZZ0005ZZ ZZ0006ZZ |
	ZZ0007ZZ
	ZZ0008ZZ ZZ0009ZZ Hướng dữ liệu ZZ0010ZZ
	+--------------+ ZZ0011ZZ +-----------------> +--------------+
	                    ZZ0012ZZ
	                    ZZ0013ZZ
	                    ZZ0014ZZ +--------------+
	                    ZZ0015ZZ Nô Lệ |
	                    Giao diện ZZ0016ZZ |
	                    ZZ0017ZZ 2 |
	                    ZZ0018ZZ |
	                    +---------------------------> ZZ0019ZZ
	                                                   ZZ0020ZZ
	                                                   +--------------+

Ví dụ 4: Dòng âm thanh nổi với kênh L và R được hiển thị bởi
Thầy ơi. Cả hai kênh L và R đều được nhận bởi hai kênh khác nhau
Nô lệ. Master và cả Slave đều đang sử dụng xử lý cổng đơn
L + R. Mỗi thiết bị Slave xử lý dữ liệu L + R cục bộ, thường
dựa trên cấu hình tĩnh hoặc hướng động và có thể điều khiển
một hoặc nhiều loa. ::

+--------------+ Tín hiệu đồng hồ +--------------+
	ZZ0000ZZ
	Giao diện ZZ0001ZZ ZZ0002ZZ |
	ZZ0003ZZ ZZ0004ZZ 1 |
	ZZ0005ZZ ZZ0006ZZ |
	ZZ0007ZZ
	ZZ0008ZZ ZZ0009ZZ Hướng dữ liệu ZZ0010ZZ
	+--------------+ ZZ0011ZZ +-----------------> +--------------+
	                    ZZ0012ZZ
	                    ZZ0013ZZ
	                    ZZ0014ZZ +--------------+
	                    ZZ0015ZZ Nô Lệ |
	                    Giao diện ZZ0016ZZ |
	                    ZZ0017ZZ 2 |
	                    ZZ0018ZZ |
	                    +---------------------------> ZZ0019ZZ
	                                                   ZZ0020ZZ
	                                                   +--------------+

Ví dụ 5: Dòng âm thanh nổi với kênh L và R được hiển thị bằng hai kênh khác nhau
Các cổng của Master và chỉ được nhận bởi một Port of the Slave duy nhất
giao diện. ::

+-------------------+
	ZZ0000ZZ
	|     +--------------+ +-------+
	ZZ0001ZZ |ZZ0002ZZ |
	Cổng dữ liệu ZZ0003ZZ |ZZ0004ZZ |
	ZZ0005ZZ 1 ZZ0006ZZ |
	Kênh ZZ0007ZZ L |ZZ0008ZZ +------+----+ |
	ZZ0009ZZ (Dữ liệu) |ZZ0010ZZ Kênh L + R |ZZ0011ZZ |
	ZZ0012ZZ +---+--------> |ZZ0013ZZ |
	ZZ0014ZZ ZZ0015ZZZZ0016ZZ |
	ZZ0017ZZ |ZZ0018ZZ |
	ZZ0019ZZ |ZZ0020ZZ +----------+ |
	Cổng dữ liệu ZZ0021ZZ ZZ0022ZZ |
	ZZ0023ZZ 2 |ZZ0024ZZ Nô Lệ |
	Kênh ZZ0025ZZ R | Giao diện ZZ0026ZZ |
	ZZ0027ZZ (Dữ liệu) |ZZ0028ZZ 1 |
	ZZ0029ZZ L + R |
	ZZ0030ZZ (Dữ liệu) |
	+-------------------+ ZZ0031ZZ
							   +----------------+

Ví dụ 6: Dòng âm thanh nổi với kênh L và R được hiển thị bởi 2 Master, mỗi Master
hiển thị một kênh và được nhận bởi hai Slave khác nhau, mỗi Slave
nhận một kênh Cả Master và cả Slave đều sử dụng một cổng. ::

+--------------+ Tín hiệu đồng hồ +--------------+
	ZZ0000ZZ
	ZZ0001ZZ ZZ0002ZZ
	ZZ0003ZZ ZZ0004ZZ
	Tín hiệu dữ liệu ZZ0005ZZ ZZ0006ZZ
	ZZ0007ZZ
	Hướng dữ liệu ZZ0008ZZ ZZ0009ZZ
	+--------------+ +--------------> +--------------+

+--------------+ Tín hiệu đồng hồ +--------------+
	ZZ0000ZZ
	ZZ0001ZZ ZZ0002ZZ
	ZZ0003ZZ ZZ0004ZZ
	Tín hiệu dữ liệu ZZ0005ZZ ZZ0006ZZ
	ZZ0007ZZ
	Hướng dữ liệu ZZ0008ZZ ZZ0009ZZ
	+--------------+ +--------------> +--------------+

Ví dụ 7: Stereo Stream kênh L và R được render bằng 2
Bậc thầy, mỗi kênh hiển thị cả hai kênh. Mỗi Slave nhận được L + R. Điều này
là ứng dụng tương tự như Ví dụ 4 nhưng với Slave được đặt trên
liên kết riêng biệt. ::

+--------------+ Tín hiệu đồng hồ +--------------+
	ZZ0000ZZ
	ZZ0001ZZ ZZ0002ZZ
	ZZ0003ZZ ZZ0004ZZ
	Tín hiệu dữ liệu ZZ0005ZZ ZZ0006ZZ
	ZZ0007ZZ
	Hướng dữ liệu ZZ0008ZZ ZZ0009ZZ
	+--------------+ +--------------> +--------------+

+--------------+ Tín hiệu đồng hồ +--------------+
	ZZ0000ZZ
	ZZ0001ZZ ZZ0002ZZ
	ZZ0003ZZ ZZ0004ZZ
	Tín hiệu dữ liệu ZZ0005ZZ ZZ0006ZZ
	ZZ0007ZZ
	Hướng dữ liệu ZZ0008ZZ ZZ0009ZZ
	+--------------+ +--------------> +--------------+

Ví dụ 8: Luồng 4 kênh được hiển thị bởi 2 Master, mỗi Master hiển thị một
2 kênh. Mỗi Slave nhận được 2 kênh. ::

+--------------+ Tín hiệu đồng hồ +--------------+
	ZZ0000ZZ
	ZZ0001ZZ ZZ0002ZZ
	ZZ0003ZZ ZZ0004ZZ
	Tín hiệu dữ liệu ZZ0005ZZ ZZ0006ZZ
	ZZ0007ZZ
	Hướng dữ liệu ZZ0008ZZ ZZ0009ZZ
	+--------------+ +--------------> +--------------+

+--------------+ Tín hiệu đồng hồ +--------------+
	ZZ0000ZZ
	ZZ0001ZZ ZZ0002ZZ
	ZZ0003ZZ ZZ0004ZZ
	Tín hiệu dữ liệu ZZ0005ZZ ZZ0006ZZ
	ZZ0007ZZ
	Hướng dữ liệu ZZ0008ZZ ZZ0009ZZ
	+--------------+ +--------------> +--------------+

Lưu ý1: Trong trường hợp đa liên kết như trên, để khóa, người ta sẽ thu được một toàn cục
lock và sau đó tiếp tục khóa các phiên bản bus. Tuy nhiên, trong trường hợp này người gọi
framework(ASoC DPCM) đảm bảo rằng các hoạt động truyền phát trên thẻ là
luôn được tuần tự hóa. Vì vậy, không có điều kiện chủng tộc và do đó không cần
khóa toàn cầu.

Lưu ý2: Thiết bị Slave có thể được cấu hình để nhận tất cả các kênh
được truyền trên một liên kết cho một Luồng nhất định (Ví dụ 4) hoặc chỉ một tập hợp con
của dữ liệu (Ví dụ 3). Cấu hình của thiết bị Slave không
được xử lý bởi hệ thống con SoundWire API, nhưng thay vào đó bởi
snd_soc_dai_set_tdm_slot() API. Nền tảng hoặc trình điều khiển máy sẽ
thường cấu hình khe cắm nào được sử dụng. Ví dụ 4,
tất cả các Thiết bị sẽ sử dụng cùng một khe cắm, trong khi đối với Ví dụ 3, Slave
Device1 sẽ sử dụng ví dụ: Khe 0 và khe thiết bị Slave2 1.

Lưu ý3: Nhiều cổng Sink có thể trích xuất cùng một thông tin cho
cùng một bitSlots trong khung SoundWire, tuy nhiên có nhiều cổng Nguồn
sẽ được cấu hình với các cấu hình bitSlot khác nhau. Đây là
giới hạn tương tự như với cách sử dụng I2S/PCM TDM.

Luồng quản lý luồng SoundWire
================================

Định nghĩa luồng
------------------

(1) Luồng hiện tại: Đây được phân loại là luồng mà hoạt động trên đó có
      được thực hiện như chuẩn bị, kích hoạt, vô hiệu hóa, hủy chuẩn bị, v.v.

(2) Luồng đang hoạt động: Đây được phân loại là luồng đã hoạt động
      trên Bus khác với luồng hiện tại. Có thể có nhiều luồng hoạt động
      trên xe buýt.

SoundWire Bus quản lý các hoạt động truyền phát cho mỗi luồng nhận được
được kết xuất/chụp trên SoundWire Bus. Phần này giải thích hoạt động của Bus
được thực hiện cho từng luồng được phân bổ/giải phóng trên Bus. Sau đây là
trạng thái luồng được Bus duy trì cho mỗi luồng âm thanh.


Trạng thái luồng SoundWire
-----------------------

Dưới đây hiển thị trạng thái luồng SoundWire và sơ đồ chuyển đổi trạng thái. ::

+----------+ +-------------+ +----------+ +----------+
	ZZ0000ZZ CONFIGURED +---->ZZ0001ZZ ENABLED |
	ZZ0002ZZ ZZ0003ZZ ZZ0004ZZ ZZ0005ZZ
	+----------+ +-------------+ +---+--+---+ +------+------+
	                                         ^ ^ ^
				                 ZZ0006ZZ |
				               __ZZ0007ZZ___________ |
				              ZZ0008ZZ |
	                                      v |  v
	         +----------+ +------+------+ +-+---+------+
	         ZZ0009ZZ<----------+ DEPREPARED ZZ0010ZZ
	         ZZ0011ZZ ZZ0012ZZ ZZ0013ZZ
	         +----------+ +-------------+ +----------+

NOTE: Chuyển đổi trạng thái giữa ZZ0000ZZ và
ZZ0001ZZ chỉ có liên quan khi cờ INFO_PAUSE được bật
được hỗ trợ ở cấp độ ALSA/ASoC. Tương tự như vậy sự chuyển đổi giữa
ZZ0002ZZ và ZZ0003ZZ phụ thuộc vào
Cờ INFO_RESUME.

NOTE2: Khung thực hiện kiểm tra chuyển đổi trạng thái cơ bản, nhưng
không ví dụ kiểm tra xem quá trình chuyển đổi từ DISABLED sang ENABLED có hợp lệ không
trên một nền tảng cụ thể. Những thử nghiệm như vậy cần được bổ sung tại ALSA/ASoC
cấp độ.

Luồng hoạt động trạng thái
-----------------------

Phần bên dưới giải thích các hoạt động được thực hiện bởi Bus trên (các) Master và
(Các) nô lệ là một phần của quá trình chuyển đổi trạng thái luồng.

SDW_STREAM_ALLOCATED
~~~~~~~~~~~~~~~~~~~~

Trạng thái phân bổ cho luồng. Đây là trạng thái đầu vào
của dòng chảy. Các thao tác được thực hiện trước khi vào trạng thái này:

(1) Thời gian chạy luồng được phân bổ cho luồng. Luồng này
      thời gian chạy được sử dụng làm tài liệu tham khảo cho tất cả các hoạt động được thực hiện
      trên luồng.

(2) Các tài nguyên cần thiết để lưu giữ thông tin thời gian chạy luồng là
      được phân bổ và khởi tạo. Điều này chứa tất cả các thông tin liên quan đến luồng
      chẳng hạn như loại luồng (PCM/PDM) và các tham số, Master và Slave
      giao diện liên quan đến luồng, trạng thái luồng, v.v.

Sau khi tất cả các thao tác trên thành công, trạng thái luồng được đặt thành
ZZ0000ZZ.

Bus triển khai bên dưới API để phân bổ luồng cần được gọi một lần
mỗi luồng. Từ khung ASoC DPCM, trạng thái luồng này có thể được liên kết với
Hoạt động .startup().

.. code-block:: c

  int sdw_alloc_stream(char * stream_name, enum sdw_stream_type type);

Lõi SoundWire cung cấp chức năng trợ giúp sdw_startup_stream(),
thường được gọi trong lệnh gọi lại dailink .startup(), thực hiện
phân bổ luồng và đặt con trỏ luồng cho tất cả DAI
được kết nối với một luồng.

SDW_STREAM_CONFIGURED
~~~~~~~~~~~~~~~~~~~~~

Trạng thái cấu hình của luồng. Các thao tác thực hiện trước khi vào
trạng thái này:

(1) Tài nguyên được phân bổ cho thông tin luồng trong SDW_STREAM_ALLOCATED
      trạng thái được cập nhật ở đây. Điều này bao gồm các tham số luồng, (các) Master
      và thông tin thời gian chạy của (các) Nô lệ được liên kết với luồng hiện tại.

(2) Tất cả (các) Master và Slave được liên kết với luồng hiện tại đều cung cấp
      thông tin cổng tới Bus bao gồm số cổng được phân bổ bởi
      (Các) Chính và (các) Phụ cho luồng hiện tại và mặt nạ kênh của chúng.

Sau khi tất cả các thao tác trên thành công, trạng thái luồng được đặt thành
ZZ0000ZZ.

Bus triển khai các API bên dưới cho trạng thái CONFIG cần được gọi bởi
(các) Master và Slave tương ứng được liên kết với luồng. Các API này có thể
chỉ được gọi một lần bởi (các) Master và (các) Slave tương ứng. Từ ASoC DPCM
framework, trạng thái luồng này được liên kết với hoạt động .hw_params().

.. code-block:: c

  int sdw_stream_add_master(struct sdw_bus * bus,
		struct sdw_stream_config * stream_config,
		const struct sdw_ports_config * ports_config,
		struct sdw_stream_runtime * stream);

  int sdw_stream_add_slave(struct sdw_slave * slave,
		struct sdw_stream_config * stream_config,
		const struct sdw_ports_config * ports_config,
		struct sdw_stream_runtime * stream);


SDW_STREAM_PREPARED
~~~~~~~~~~~~~~~~~~~

Chuẩn bị trạng thái luồng. Các thao tác được thực hiện trước khi vào trạng thái này:

(0) Bước 1 và 2 được bỏ qua trong trường hợp vận hành tiếp tục,
      nơi băng thông bus được biết đến.

(1) Các thông số bus như băng thông, hình dạng khung, tần số xung nhịp,
      được tính toán dựa trên luồng hiện tại cũng như đã hoạt động
      (các) luồng trên Xe buýt. Cần phải tính toán lại để phù hợp với hiện tại
      phát trực tuyến trên xe buýt.

(2) Các tham số truyền tải và cổng của tất cả (các) cổng Chính và (các) cổng Phụ là
      được tính toán cho luồng hiện tại cũng như đã hoạt động dựa trên khung
      hình dạng và tần số đồng hồ được tính toán ở bước 1.

(3) Các tham số truyền tải và Bus tính toán được lập trình trong Master(s) và
      (Các) thanh ghi nô lệ. Việc lập trình các thanh ghi ngân hàng được thực hiện trên
      ngân hàng thay thế (ngân hàng hiện không được sử dụng). (Các) cổng được kích hoạt cho
      (các) luồng đã hoạt động trên ngân hàng thay thế (ngân hàng hiện không được sử dụng).
      Điều này được thực hiện để không làm gián đoạn (các) luồng đang hoạt động.

(4) Sau khi tất cả các giá trị được lập trình, Bus sẽ bắt đầu chuyển sang chế độ thay thế
      ngân hàng nơi tất cả các giá trị mới được lập trình sẽ có hiệu lực.

(5) Cổng của (các) Master và Slave cho luồng hiện tại được chuẩn bị bởi
      lập trình thanh ghi prepareCtrl.

Sau khi tất cả các thao tác trên thành công, trạng thái luồng được đặt thành
ZZ0000ZZ.

Bus thực hiện bên dưới API cho trạng thái PREPARE cần được gọi
một lần trên mỗi luồng. Từ khung ASoC DPCM, trạng thái luồng này được liên kết
đến hoạt động .prepare(). Vì các hoạt động .trigger() có thể không
làm theo .prepare(), chuyển đổi trực tiếp từ
Cho phép từ ZZ0000ZZ đến ZZ0001ZZ.

.. code-block:: c

  int sdw_prepare_stream(struct sdw_stream_runtime * stream);


SDW_STREAM_ENABLED
~~~~~~~~~~~~~~~~~~

Bật trạng thái luồng. (Các) cổng dữ liệu được bật khi vào trạng thái này.
Các thao tác được thực hiện trước khi vào trạng thái này:

(1) Tất cả các giá trị được tính toán ở trạng thái SDW_STREAM_PREPARED đều được lập trình
      ở ngân hàng thay thế (ngân hàng hiện không được sử dụng). Nó bao gồm việc lập trình
      (các) luồng đang hoạt động.

(2) Tất cả (các) cổng Chính và (các) cổng Phụ cho luồng hiện tại là
      được kích hoạt trên ngân hàng thay thế (ngân hàng hiện không được sử dụng) bằng cách lập trình
      Đăng ký ChannelEn.

(3) Sau khi tất cả các giá trị được lập trình, Bus sẽ bắt đầu chuyển sang chế độ thay thế
      ngân hàng nơi tất cả các giá trị mới được lập trình sẽ có hiệu lực và (các) cổng
      được liên kết với luồng hiện tại được bật.

Sau khi tất cả các thao tác trên thành công, trạng thái luồng được đặt thành
ZZ0000ZZ.

Bus triển khai bên dưới API cho trạng thái ENABLE cần được gọi một lần mỗi lần
suối. Từ khung ASoC DPCM, trạng thái luồng này được liên kết với
.trigger() bắt đầu hoạt động.

.. code-block:: c

  int sdw_enable_stream(struct sdw_stream_runtime * stream);

SDW_STREAM_DISABLED
~~~~~~~~~~~~~~~~~~~

Vô hiệu hóa trạng thái của luồng. (Các) cổng dữ liệu bị vô hiệu hóa khi thoát khỏi trạng thái này.
Các thao tác được thực hiện trước khi vào trạng thái này:

(1) Tất cả (các) cổng Chính và (các) cổng Phụ cho luồng hiện tại là
      bị vô hiệu hóa trên ngân hàng thay thế (ngân hàng hiện không được sử dụng) bằng cách lập trình
      Đăng ký ChannelEn.

(2) Tất cả cấu hình hiện tại của Bus và (các) luồng hoạt động đều được lập trình
      vào ngân hàng thay thế (ngân hàng hiện chưa được sử dụng).

(3) Sau khi tất cả các giá trị được lập trình, Bus sẽ bắt đầu chuyển sang chế độ thay thế
      ngân hàng nơi tất cả các giá trị mới được lập trình sẽ có hiệu lực và (các) cổng được liên kết
      với luồng hiện tại bị vô hiệu hóa.

Sau khi tất cả các thao tác trên thành công, trạng thái luồng được đặt thành
ZZ0000ZZ.

Bus triển khai bên dưới API cho trạng thái DISABLED cần được gọi một lần
mỗi luồng. Từ khung ASoC DPCM, trạng thái luồng này được liên kết với
.trigger() dừng hoạt động.

Khi cờ INFO_PAUSE được hỗ trợ, việc chuyển đổi trực tiếp sang
ZZ0000ZZ được cho phép.

Đối với các hoạt động tiếp tục trong đó ASoC sẽ sử dụng lệnh gọi lại .prepare(),
luồng có thể chuyển từ ZZ0000ZZ sang
ZZ0001ZZ, với tất cả các cài đặt cần thiết đã được khôi phục nhưng
mà không cập nhật băng thông và phân bổ bit.

.. code-block:: c

  int sdw_disable_stream(struct sdw_stream_runtime * stream);


SDW_STREAM_DEPREPARED
~~~~~~~~~~~~~~~~~~~~~

Hủy chuẩn bị trạng thái của luồng. Các thao tác được thực hiện trước khi vào đây
tiểu bang:

(1) Tất cả (các) cổng của (các) Chính và (các) Phụ cho luồng hiện tại là
      được chuẩn bị lại bằng cách lập trình thanh ghi prepareCtrl.

(2) Băng thông tải trọng của luồng hiện tại giảm từ tổng băng thông
      yêu cầu băng thông của bus và các thông số mới được tính toán và
      được áp dụng bằng cách thực hiện chuyển đổi ngân hàng, v.v.

Sau khi tất cả các thao tác trên thành công, trạng thái luồng được đặt thành
ZZ0000ZZ.

Bus thực hiện bên dưới API cho trạng thái DEPREPARED cần được gọi
một lần trên mỗi luồng. ALSA/ASoC không có khái niệm 'không chuẩn bị' và
việc ánh xạ từ trạng thái luồng này sang hoạt động ALSA/ASoC có thể
triển khai cụ thể.

Khi cờ INFO_PAUSE được hỗ trợ, trạng thái luồng được liên kết với
thao tác .hw_free() - luồng không bị hủy trên
TRIGGER_STOP.

Các triển khai khác có thể chuyển sang ZZ0000ZZ
trạng thái trên TRIGGER_STOP, nếu họ yêu cầu chuyển đổi qua
Trạng thái ZZ0001ZZ.

.. code-block:: c

  int sdw_deprepare_stream(struct sdw_stream_runtime * stream);


SDW_STREAM_RELEASED
~~~~~~~~~~~~~~~~~~~

Phát hành trạng thái của luồng. Các thao tác được thực hiện trước khi vào trạng thái này:

(1) Giải phóng tài nguyên cổng cho tất cả (các) cổng Chính và (các) cổng Phụ
      liên kết với luồng hiện tại.

(2) Giải phóng các tài nguyên thời gian chạy Chính và Phụ được liên kết với
      luồng hiện tại.

(3) Giải phóng tài nguyên thời gian chạy luồng được liên kết với luồng hiện tại.

Sau khi tất cả các thao tác trên thành công, trạng thái luồng được đặt thành
ZZ0000ZZ.

Bus triển khai các API bên dưới cho trạng thái RELEASE cần được gọi bởi
tất cả (các) Master và Slave được liên kết với luồng. Từ ASoC DPCM
framework, trạng thái luồng này được liên kết với hoạt động .hw_free().

.. code-block:: c

  int sdw_stream_remove_master(struct sdw_bus * bus,
		struct sdw_stream_runtime * stream);
  int sdw_stream_remove_slave(struct sdw_slave * slave,
		struct sdw_stream_runtime * stream);


Thao tác .shutdown() ASoC DPCM gọi bên dưới Bus API để giải phóng
luồng được chỉ định như một phần của trạng thái ALLOCATED.

Trong .shutdown() cấu trúc dữ liệu duy trì trạng thái luồng được giải phóng.

.. code-block:: c

  void sdw_release_stream(struct sdw_stream_runtime * stream);

Lõi SoundWire cung cấp chức năng trợ giúp sdw_shutdown_stream(),
thường được gọi trong lệnh gọi lại dailink .shutdown(), thao tác này sẽ xóa
con trỏ luồng cho tất cả DAIS được kết nối với luồng và giải phóng
bộ nhớ được phân bổ cho luồng.

Không được hỗ trợ
=============

1. Không thể sử dụng một cổng duy nhất có nhiều kênh được hỗ trợ giữa hai cổng
   luồng hoặc qua luồng. Ví dụ: không thể sử dụng cổng có 4 kênh
   để xử lý 2 luồng âm thanh nổi độc lập mặc dù về mặt lý thuyết là có thể
   trong SoundWire.
