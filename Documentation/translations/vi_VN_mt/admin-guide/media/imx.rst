.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/imx.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển quay video i.MX
================================

Giới thiệu
------------

Freescale i.MX5/6 chứa Bộ xử lý hình ảnh (IPU),
xử lý luồng khung hình đến và đi từ các thiết bị chụp và
các thiết bị hiển thị.

Để chụp ảnh, IPU chứa các tiểu đơn vị bên trong sau:

- Bộ điều khiển hình ảnh DMA (IDMAC)
- Giao diện nối tiếp máy ảnh (CSI)
- Bộ chuyển đổi hình ảnh (IC)
- Bộ điều khiển cảm biến Multi-FIFO (SMFC)
- Công cụ quay hình ảnh (IRT)
- Khối khử xen kẽ hoặc kết hợp video (VDIC)

IDMAC là bộ điều khiển DMA để truyền khung hình ảnh đến và đi từ
trí nhớ. Có nhiều kênh DMA chuyên dụng khác nhau cho cả quay video và
hiển thị các đường dẫn. Trong quá trình truyền tải, IDMAC cũng có khả năng di chuyển theo chiều dọc
lật hình ảnh, chuyển khối 8x8 (xem mô tả IRT), thành phần pixel
sắp xếp lại (ví dụ UYVY đến YUYV) trong cùng một không gian màu và
đóng gói <--> chuyển đổi phẳng. IDMAC cũng có thể thực hiện một thao tác đơn giản
khử xen kẽ bằng cách đan xen các dòng chẵn và lẻ trong quá trình chuyển
(không có bù chuyển động yêu cầu VDIC).

CSI là thiết bị chụp phụ trợ có giao diện trực tiếp với
cảm biến camera trên các xe buýt Parallel, BT.656/1120 và MIPI CSI-2.

IC xử lý việc chuyển đổi không gian màu, thay đổi kích thước (thu nhỏ và
nâng cấp), lật ngang và thao tác xoay 90/270 độ.

Có ba "nhiệm vụ" độc lập trong IC có thể thực hiện
chuyển đổi đồng thời: mã hóa tiền xử lý, kính ngắm tiền xử lý,
và xử lý hậu kỳ. Trong mỗi nhiệm vụ, chuyển đổi được chia thành ba
phần: phần thu nhỏ, phần chính (tăng kích thước, lật, không gian màu
chuyển đổi và kết hợp mặt phẳng đồ họa) và phần xoay.

IPU chia sẻ thời gian hoạt động của tác vụ IC. Độ chi tiết của lát cắt thời gian
là một cụm tám pixel trong phần thu nhỏ, một dòng hình ảnh
trong phần xử lý chính, một khung hình trong phần xoay.

SMFC bao gồm bốn FIFO độc lập mà mỗi FIFO có thể chuyển
ghi lại các khung hình từ cảm biến trực tiếp vào bộ nhớ đồng thời thông qua bốn
Các kênh IDMAC.

IRT thực hiện các thao tác xoay hình ảnh 90 và 270 độ. các
thao tác xoay được thực hiện trên các khối pixel 8x8 cùng một lúc. Cái này
hoạt động được hỗ trợ bởi IDMAC xử lý việc chuyển khối 8x8
cùng với việc sắp xếp lại các khối, phối hợp với lật dọc.

VDIC xử lý việc chuyển đổi video xen kẽ sang video lũy tiến, với
hỗ trợ các chế độ bù chuyển động khác nhau (thấp, trung bình và cao
chuyển động). Các khung đầu ra đã được khử xen kẽ từ VDIC có thể được gửi đến
Nhiệm vụ kính ngắm tiền xử lý IC để chuyển đổi thêm. VDIC cũng
chứa Bộ kết hợp kết hợp hai mặt phẳng hình ảnh, với tính năng trộn alpha
và phím màu.

Ngoài các tiểu đơn vị bên trong IPU, còn có hai đơn vị
bên ngoài IPU cũng tham gia quay video trên i.MX:

- Bộ thu MIPI CSI-2 dành cho cảm biến máy ảnh với bus MIPI CSI-2
  giao diện. Đây là lõi Synopsys DesignWare.
- Hai bộ ghép kênh video để lựa chọn trong số nhiều đầu vào cảm biến
  để gửi tới CSI.

Để biết thêm thông tin, hãy tham khảo các phiên bản mới nhất của tài liệu tham khảo i.MX5/6
hướng dẫn sử dụng [#f1]_ và [#f2]_.


Đặc trưng
---------

Một số tính năng của trình điều khiển này bao gồm:

- Nhiều đường ống khác nhau có thể được cấu hình thông qua bộ điều khiển phương tiện API,
  tương ứng với các đường dẫn quay video phần cứng được hỗ trợ trong
  i.MX.

- Hỗ trợ các giao diện song song, BT.565 và MIPI CSI-2.

- Các luồng độc lập đồng thời, bằng cách định cấu hình các đường ống thành nhiều luồng
  giao diện quay video sử dụng các thực thể độc lập.

- Chia tỷ lệ, chuyển đổi không gian màu, lật ngang và dọc, và
  xoay hình ảnh thông qua các subdev nhiệm vụ IC.

- Hỗ trợ nhiều định dạng pixel (RGB, YUV đóng gói và phẳng, một phần
  phẳng YUV).

- Subdev VDIC hỗ trợ khử xen kẽ bù chuyển động, với ba
  Chế độ bù chuyển động: chuyển động thấp, trung bình và cao. Đường ống được
  được xác định cho phép gửi khung tới nhà phát triển con VDIC trực tiếp từ
  CSI. Ngoài ra còn có hỗ trợ trong tương lai để gửi khung tới
  VDIC từ bộ đệm bộ nhớ thông qua thiết bị đầu ra/mem2mem.

- Bao gồm Trình theo dõi khoảng thời gian khung (FIM) có thể điều chỉnh đồng bộ hóa dọc
  vấn đề với bộ giải mã video ADV718x.


Cấu trúc liên kết
-----------------

Phần sau đây hiển thị các cấu trúc liên kết phương tiện cho i.MX6Q SabreSD và
i.MX6Q SabreAuto. Tham khảo các sơ đồ này trong phần mô tả thực thể
trong phần tiếp theo.

Cấu trúc liên kết i.MX5/6 có thể khác với video IPUv3 CSI
bộ ghép kênh, nhưng cấu trúc liên kết IPUv3 nội bộ ở phía dưới từ đó
là chung cho tất cả các nền tảng i.MX5/6. Ví dụ: SabreSD, với
Cảm biến MIPI CSI-2 OV5640, yêu cầu bộ thu i.MX6 MIPI CSI-2. Nhưng
SabreAuto chỉ có bộ giải mã ADV7180 trên bus bt.656 song song và
do đó không yêu cầu bộ thu MIPI CSI-2 nên nó bị thiếu trong
đồ thị của nó.

.. _imx6q_topology_graph:

.. kernel-figure:: imx6q-sabresd.dot
    :alt:   Diagram of the i.MX6Q SabreSD media pipeline topology
    :align: center

    Media pipeline graph on i.MX6Q SabreSD

.. kernel-figure:: imx6q-sabreauto.dot
    :alt:   Diagram of the i.MX6Q SabreAuto media pipeline topology
    :align: center

    Media pipeline graph on i.MX6Q SabreAuto

Thực thể
--------

imx6-mipi-csi2
--------------

Đây là thực thể máy thu MIPI CSI-2. Nó có một miếng đệm chìm để nhận
luồng MIPI CSI-2 (thường là từ cảm biến máy ảnh MIPI CSI-2). Nó có
bốn miếng đệm nguồn, tương ứng với bốn miếng đệm ảo MIPI CSI-2 được giải mã
đầu ra kênh. Nhiều miếng đệm nguồn có thể được kích hoạt độc lập
truyền phát từ nhiều kênh ảo.

Thực thể này thực sự bao gồm hai khối con. Một là MIPI CSI-2
cốt lõi. Đây là lõi Synopsys Designware MIPI CSI-2. Khối phụ khác
là "miếng đệm từ CSI-2 đến IPU". Miếng đệm hoạt động như một bộ tách kênh của
bốn luồng kênh ảo, cung cấp bốn bus song song riêng biệt
chứa mỗi kênh ảo được định tuyến tới CSI hoặc video
bộ ghép kênh như được mô tả dưới đây.

Trên i.MX6 solo/dual-lite, tất cả bốn bus kênh ảo đều được định tuyến tới
hai bộ ghép kênh video. Cả CSI0 và CSI1 đều có thể nhận bất kỳ thiết bị ảo nào
kênh được chọn bởi bộ ghép kênh video.

Trên i.MX6 Quad, kênh ảo 0 được định tuyến tới IPU1-CSI0 (sau khi chọn
bằng mux video), các kênh ảo 1 và 2 được nối cứng với IPU1-CSI1
và IPU2-CSI0 tương ứng và kênh ảo 3 được định tuyến tới
IPU2-CSI1 (một lần nữa được chọn bởi mux video).

ipuX_csiY_mux
-------------

Đây là những bộ ghép kênh video. Họ có hai hoặc nhiều miếng đệm bồn rửa để
chọn từ các cảm biến máy ảnh có giao diện song song hoặc từ
Các kênh ảo MIPI CSI-2 từ thực thể imx6-mipi-csi2. Họ có một
bảng nguồn duy nhất định tuyến đến CSI (thực thể ipuX_csiY).

Trên i.MX6 solo/dual-lite, có hai thực thể mux video. Một người ngồi
phía trước IPU1-CSI0 để chọn giữa cảm biến song song và bất kỳ cảm biến nào
bốn kênh ảo MIPI CSI-2 (tổng cộng năm miếng đệm chìm). các
mux khác nằm ở phía trước IPU1-CSI1 và lại có năm miếng đệm chìm để
chọn giữa một cảm biến song song và bất kỳ cảm biến nào trong số bốn cảm biến ảo MIPI CSI-2
các kênh.

Trên i.MX6 Quad, có hai thực thể mux video. Một người ngồi trước
IPU1-CSI0 để chọn giữa cảm biến song song và MIPI CSI-2 ảo
kênh 0 (hai miếng đệm chìm). Mux khác nằm ở phía trước IPU2-CSI1 để
chọn giữa cảm biến song song và kênh ảo MIPI CSI-2 3 (hai
miếng đệm bồn rửa).

ipuX_csiY
---------

Đây là các thực thể CSI. Họ có một miếng đệm chìm duy nhất nhận được từ
một kênh video hoặc từ kênh ảo MIPI CSI-2 như được mô tả
ở trên.

Thực thể này có hai nguồn đệm. Nguồn pad đầu tiên có thể liên kết trực tiếp
tới thực thể ipuX_vdic hoặc thực thể ipuX_ic_prp, sử dụng liên kết phần cứng
không yêu cầu chuyển bộ nhớ đệm IDMAC.

Khi bảng nguồn trực tiếp được định tuyến đến thực thể ipuX_ic_prp, các khung
từ CSI có thể được xử lý bằng một hoặc cả hai bộ xử lý trước IC
nhiệm vụ.

Khi bảng nguồn trực tiếp được định tuyến đến thực thể ipuX_vdic, VDIC
sẽ thực hiện khử xen kẽ bù chuyển động bằng chế độ "chuyển động cao"
(xem mô tả về thực thể ipuX_vdic).

Bảng nguồn thứ hai gửi các khung hình video trực tiếp đến bộ nhớ đệm
thông qua kênh SMFC và kênh IDMAC, bỏ qua quá trình xử lý trước IC. Cái này
bảng nguồn được định tuyến đến nút thiết bị chụp, với tên nút là
định dạng "chụp ipuX_csiY".

Lưu ý rằng vì bảng nguồn IDMAC sử dụng kênh IDMAC nên
việc sắp xếp lại các pixel trong cùng một không gian màu có thể được thực hiện bởi
Kênh IDMAC. Ví dụ: nếu tấm lót bồn rửa CSI đang nhận trong UYVY
đặt hàng, thiết bị chụp được liên kết với bảng nguồn IDMAC có thể chụp
theo thứ tự YUYV. Ngoài ra, nếu tấm lót bồn rửa CSI đang nhận được YUV được đóng gói
định dạng, thiết bị chụp có thể chụp định dạng YUV phẳng như
YUV420.

Kênh IDMAC tại bảng nguồn IDMAC cũng hỗ trợ các
đan xen mà không bù chuyển động, được kích hoạt nếu nguồn
loại trường của phần đệm là tuần tự trên cùng hoặc dưới cùng và
loại trường giao diện chụp được yêu cầu được đặt thành xen kẽ (t-b, b-t,
hoặc xen kẽ không đủ tiêu chuẩn). Giao diện chụp sẽ thực thi tương tự
thứ tự trường làm thứ tự trường bảng nguồn (interlaced-bt nếu bảng nguồn
là seq-bt, interlaced-tb nếu phần đệm nguồn là seq-tb).

Đối với các sự kiện do ipuX_csiY tạo ra, hãy xem ref:ZZ0000ZZ.

Cắt xén trong ipuX_csiY
-----------------------

CSI hỗ trợ cắt các khung cảm biến thô đến. Đây là
được triển khai trong các thực thể ipuX_csiY tại sink pad, bằng cách sử dụng
lựa chọn cắt xén subdev API.

CSI cũng hỗ trợ thu nhỏ tỷ lệ chia đôi cố định một cách độc lập trong
chiều rộng và chiều cao. Điều này được triển khai trong các thực thể ipuX_csiY tại
bảng chìm, sử dụng subdev lựa chọn soạn thảo API.

Hình chữ nhật đầu ra ở bảng nguồn ipuX_csiY giống như
hình chữ nhật soạn thư ở miếng đệm bồn rửa. Vì vậy, hình chữ nhật pad nguồn
không thể thương lượng được, nó phải được đặt bằng cách sử dụng lựa chọn soạn thư
API ở bảng chìm (nếu muốn giảm tỷ lệ /2, nếu không thì bảng nguồn
hình chữ nhật bằng với hình chữ nhật đến).

Để đưa ra một ví dụ về cắt xén và /2 thu nhỏ, thao tác này sẽ cắt một
Khung đầu vào 1280x960 thành 640x480, sau đó giảm tỷ lệ /2 ở cả hai
kích thước thành 320x240 (giả sử ipu1_csi0 được liên kết với ipu1_csi0_mux):

.. code-block:: none

   media-ctl -V "'ipu1_csi0_mux':2[fmt:UYVY2X8/1280x960]"
   media-ctl -V "'ipu1_csi0':0[crop:(0,0)/640x480]"
   media-ctl -V "'ipu1_csi0':0[compose:(0,0)/320x240]"

Bỏ qua khung hình trong ipuX_csiY
---------------------------------

CSI hỗ trợ giảm tốc độ khung hình bằng cách bỏ qua khung hình. khung
tốc độ giảm dần được chỉ định bằng cách đặt khoảng thời gian khung hình ở
miếng đệm chìm và nguồn. Thực thể ipuX_csiY sau đó áp dụng điều tốt nhất
cài đặt bỏ qua khung hình thành CSI để đạt được tốc độ khung hình mong muốn
tại bảng nguồn.

Ví dụ sau đây giảm khung 60 Hz đến giả định
giảm một nửa ở bảng nguồn đầu ra IDMAC:

.. code-block:: none

   media-ctl -V "'ipu1_csi0':0[fmt:UYVY2X8/640x480@1/60]"
   media-ctl -V "'ipu1_csi0':2[fmt:UYVY2X8/640x480@1/30]"

Giám sát khoảng thời gian khung trong ipuX_csiY
-----------------------------------------------

Xem giới thiệu:ZZ0000ZZ.

ipuX_vdic
---------

VDIC thực hiện khử xen kẽ bù chuyển động, với ba
Chế độ bù chuyển động: chuyển động thấp, trung bình và cao. Chế độ này là
được chỉ định bằng điều khiển menu V4L2_CID_DEINTERLACING_MODE. VDIC
có hai miếng đệm chìm và một miếng nguồn duy nhất.

Tấm đệm trực tiếp nhận được từ tấm đệm trực tiếp ipuX_csiY. Với cái này
link VDIC chỉ có thể hoạt động ở chế độ chuyển động cao.

Khi miếng đệm chìm IDMAC được kích hoạt, nó sẽ nhận được từ đầu ra
hoặc nút thiết bị mem2mem. Với đường dẫn này, VDIC cũng có thể hoạt động
ở chế độ thấp và trung bình, vì các chế độ này yêu cầu nhận
khung hình từ bộ nhớ đệm. Lưu ý rằng thiết bị đầu ra hoặc mem2mem
chưa được triển khai nên bảng chìm này hiện không có liên kết.

Bộ đệm nguồn định tuyến tới thực thể tiền xử lý IC ipuX_ic_prp.

ipuX_ic_prp
-----------

Đây là thực thể tiền xử lý IC. Nó hoạt động như một bộ định tuyến, định tuyến
dữ liệu từ bảng chìm của nó đến một hoặc cả hai bảng nguồn của nó.

Thực thể này có một tấm đệm chìm duy nhất. Tấm đệm chìm có thể nhận được từ
ipuX_csiY pad trực tiếp hoặc từ ipuX_vdic.

Thực thể này có hai nguồn đệm. Một đường dẫn nguồn pad đến
thực thể nhiệm vụ mã hóa tiền xử lý (ipuX_ic_prpenc), phần còn lại cho
thực thể tác vụ kính ngắm tiền xử lý (ipuX_ic_prpvf). Cả hai miếng nguồn
có thể được kích hoạt cùng lúc nếu tấm lót bồn rửa đang nhận từ
ipuX_csiY. Chỉ phần đệm nguồn cho thực thể tác vụ kính ngắm tiền xử lý
có thể được kích hoạt nếu sink pad đang nhận từ ipuX_vdic (khung
từ VDIC chỉ có thể được xử lý bằng tác vụ kính ngắm tiền xử lý).

ipuX_ic_prpenc
--------------

Đây là thực thể mã hóa tiền xử lý IC. Nó có một bồn rửa duy nhất
pad từ ipuX_ic_prp và một pad nguồn duy nhất. Pad nguồn là
được định tuyến đến nút thiết bị chụp, với tên nút có định dạng
"chụp ipuX_ic_prpenc".

Thực thể này thực hiện các hoạt động tác vụ mã hóa tiền xử lý IC:
chuyển đổi không gian màu, thay đổi kích thước (thu nhỏ và nâng cấp),
lật ngang và dọc và xoay 90/270 độ. Lật
và xoay được cung cấp thông qua các điều khiển V4L2 tiêu chuẩn.

Giống như nguồn ipuX_csiY IDMAC, thực thể này cũng hỗ trợ các
khử xen kẽ mà không bù chuyển động và sắp xếp lại pixel.

ipuX_ic_prpvf
-------------

Đây là thực thể kính ngắm tiền xử lý IC. Nó có một bồn rửa duy nhất
pad từ ipuX_ic_prp và một pad nguồn duy nhất. Bảng nguồn được định tuyến
đến nút thiết bị chụp, với tên nút có định dạng
"chụp ipuX_ic_prpvf".

Thực thể này hoạt động giống hệt với ipuX_ic_prpenc, với cùng một
thay đổi kích thước và các thao tác CSC cũng như điều khiển lật/xoay. Nó sẽ nhận được
và xử lý các khung không xen kẽ từ ipuX_vdic nếu ipuX_ic_prp là
nhận từ ipuX_vdic.

Giống như nguồn ipuX_csiY IDMAC, thực thể này hỗ trợ các
đan xen mà không bù chuyển động. Tuy nhiên, lưu ý rằng nếu
ipuX_vdic được bao gồm trong đường dẫn (ipuX_ic_prp đang nhận từ
ipuX_vdic), không thể sử dụng đan xen trong ipuX_ic_prpvf,
vì ipuX_vdic đã tiến hành khử xen kẽ (với
bù chuyển động) và do đó đầu ra loại trường từ
ipuX_vdic chỉ có thể là không (tiến bộ).

Chụp đường ống
-----------------

Phần sau đây mô tả các trường hợp sử dụng khác nhau được hỗ trợ bởi quy trình.

Các liên kết được hiển thị không bao gồm cảm biến phụ trợ, mux video hoặc mipi
liên kết máy thu csi-2. Điều này phụ thuộc vào loại giao diện cảm biến
(song song hoặc mipi csi-2). Vì vậy, các đường ống này bắt đầu bằng:

cảm biến -> ipuX_csiY_mux -> ...

cho các cảm biến song song, hoặc:

cảm biến -> imx6-mipi-csi2 -> (ipuX_csiY_mux) -> ...

cho cảm biến mipi csi-2. Bộ thu imx6-mipi-csi2 có thể cần định tuyến
tới mux video (ipuX_csiY_mux) trước khi gửi tới CSI, tùy thuộc vào
trên kênh ảo mipi csi-2, do đó ipuX_csiY_mux được hiển thị trong
dấu ngoặc đơn.

Quay video chưa được xử lý:
---------------------------

Gửi khung hình trực tiếp từ cảm biến đến nút giao diện thiết bị máy ảnh, với
không có chuyển đổi, thông qua bảng nguồn ipuX_csiY IDMAC:

-> ipuX_csiY:2 -> chụp ipuX_csiY

Chuyển đổi trực tiếp IC:
------------------------

Đường dẫn này sử dụng thực thể mã hóa tiền xử lý để định tuyến các khung trực tiếp
từ CSI đến IC, để thực hiện mở rộng độ phân giải lên tới 1024x1024,
CSC, lật và xoay hình ảnh:

-> ipuX_csiY:1 -> 0:ipuX_ic_prp:1 -> 0:ipuX_ic_prpenc:1 -> chụp ipuX_ic_prpenc

Khử xen kẽ bù chuyển động:
--------------------------------

Đường dẫn này định tuyến các khung từ vùng đệm trực tiếp CSI đến thực thể VDIC để
hỗ trợ khử xen kẽ bù chuyển động (chỉ ở chế độ chuyển động cao),
tỷ lệ lên tới 1024x1024, CSC, lật và xoay:

-> ipuX_csiY:1 -> 0:ipuX_vdic:2 -> 0:ipuX_ic_prp:2 -> 0:ipuX_ic_prpvf:1 -> chụp ipuX_ic_prpvf


Ghi chú sử dụng
---------------

Để hỗ trợ cấu hình và tương thích ngược với V4L2
các ứng dụng chỉ truy cập điều khiển từ các nút thiết bị video,
giao diện thiết bị chụp kế thừa các điều khiển từ các thực thể đang hoạt động
trong quy trình hiện tại, do đó, các điều khiển có thể được truy cập trực tiếp
từ subdev hoặc từ giao diện thiết bị chụp đang hoạt động. cho
ví dụ: các điều khiển FIM có sẵn từ ipuX_csiY
subdevs hoặc từ thiết bị chụp đang hoạt động.

Sau đây là những ghi chú sử dụng cụ thể cho tài liệu tham khảo Sabre*
bảng:


i.MX6Q SabreLite với OV5642 và OV5640
---------------------------------------

Nền tảng này yêu cầu mô-đun OmniVision OV5642 có kết nối song song
giao diện máy ảnh và mô-đun OV5640 với MIPI CSI-2
giao diện. Cả hai mô-đun đều có sẵn từ Thiết bị ranh giới:

-ZZ0000ZZ
-ZZ0001ZZ

Lưu ý rằng nếu chỉ có một mô-đun máy ảnh thì cảm biến còn lại
nút có thể bị vô hiệu hóa trong cây thiết bị.

Mô-đun OV5642 được kết nối với đầu vào bus song song trên i.MX
trộn video nội bộ sang IPU1 CSI0. Đó là bus i2c kết nối với bus i2c 2.

Mô-đun MIPI CSI-2 OV5640 được kết nối với MIPI CSI-2 bên trong i.MX
máy thu và bốn đầu ra kênh ảo từ máy thu là
được định tuyến như sau: vc0 đến mux IPU1 CSI0, vc1 trực tiếp đến IPU1 CSI1,
vc2 trực tiếp tới IPU2 CSI0 và vc3 tới mux IPU2 CSI1. OV5640 là
cũng được kết nối với i2c bus 2 trên SabreLite, do đó OV5642 và
OV5640 không được chia sẻ cùng một địa chỉ nô lệ i2c.

Ví dụ cơ bản sau đây định cấu hình quay video chưa được xử lý
đường ống cho cả hai cảm biến. OV5642 được định tuyến tới ipu1_csi0 và
OV5640, truyền trên kênh ảo MIPI CSI-2 1 (là
imx6-mipi-csi2 pad 2), được định tuyến tới ipu1_csi1. Cả hai cảm biến đều
được định cấu hình để xuất ra 640x480 và OV5642 xuất ra YUYV2X8,
OV5640 UYVY2X8:

.. code-block:: none

   # Setup links for OV5642
   media-ctl -l "'ov5642 1-0042':0 -> 'ipu1_csi0_mux':1[1]"
   media-ctl -l "'ipu1_csi0_mux':2 -> 'ipu1_csi0':0[1]"
   media-ctl -l "'ipu1_csi0':2 -> 'ipu1_csi0 capture':0[1]"
   # Setup links for OV5640
   media-ctl -l "'ov5640 1-0040':0 -> 'imx6-mipi-csi2':0[1]"
   media-ctl -l "'imx6-mipi-csi2':2 -> 'ipu1_csi1':0[1]"
   media-ctl -l "'ipu1_csi1':2 -> 'ipu1_csi1 capture':0[1]"
   # Configure pads for OV5642 pipeline
   media-ctl -V "'ov5642 1-0042':0 [fmt:YUYV2X8/640x480 field:none]"
   media-ctl -V "'ipu1_csi0_mux':2 [fmt:YUYV2X8/640x480 field:none]"
   media-ctl -V "'ipu1_csi0':2 [fmt:AYUV32/640x480 field:none]"
   # Configure pads for OV5640 pipeline
   media-ctl -V "'ov5640 1-0040':0 [fmt:UYVY2X8/640x480 field:none]"
   media-ctl -V "'imx6-mipi-csi2':2 [fmt:UYVY2X8/640x480 field:none]"
   media-ctl -V "'ipu1_csi1':2 [fmt:AYUV32/640x480 field:none]"

Sau đó, quá trình truyền phát có thể bắt đầu độc lập trên các nút thiết bị chụp
"chụp ipu1_csi0" và "chụp ipu1_csi1". Công cụ v4l2-ctl có thể
được sử dụng để chọn bất kỳ định dạng pixel YUV nào được hỗ trợ trên thiết bị chụp
các nút, bao gồm cả mặt phẳng.

i.MX6Q SabreAuto với bộ giải mã ADV7180
---------------------------------------

Trên i.MX6Q SabreAuto, bộ giải mã ADV7180 SD tích hợp được kết nối với
đầu vào bus song song trên mux video nội bộ tới IPU1 CSI0.

Ví dụ sau định cấu hình đường dẫn để chụp từ ADV7180
bộ giải mã video, giả sử tín hiệu đầu vào NTSC 720x480, sử dụng đơn giản
đan xen (không chuyển đổi và không bù chuyển động). Adv7180
phải xuất ra các trường tuần tự hoặc xen kẽ (loại trường 'seq-bt' cho
NTSC hoặc 'thay thế'):

.. code-block:: none

   # Setup links
   media-ctl -l "'adv7180 3-0021':0 -> 'ipu1_csi0_mux':1[1]"
   media-ctl -l "'ipu1_csi0_mux':2 -> 'ipu1_csi0':0[1]"
   media-ctl -l "'ipu1_csi0':2 -> 'ipu1_csi0 capture':0[1]"
   # Configure pads
   media-ctl -V "'adv7180 3-0021':0 [fmt:UYVY2X8/720x480 field:seq-bt]"
   media-ctl -V "'ipu1_csi0_mux':2 [fmt:UYVY2X8/720x480]"
   media-ctl -V "'ipu1_csi0':2 [fmt:AYUV32/720x480]"
   # Configure "ipu1_csi0 capture" interface (assumed at /dev/video4)
   v4l2-ctl -d4 --set-fmt-video=field=interlaced_bt

Sau đó, quá trình phát trực tuyến có thể bắt đầu trên /dev/video4. Công cụ v4l2-ctl cũng có thể
được sử dụng để chọn bất kỳ định dạng pixel YUV nào được hỗ trợ trên /dev/video4.

Ví dụ này định cấu hình đường dẫn để chụp từ ADV7180
bộ giải mã video, giả sử tín hiệu đầu vào PAL 720x576, với Chuyển động
Bồi thường de-interlacing. Adv7180 phải xuất ra tuần tự hoặc
các trường xen kẽ (loại trường 'seq-tb' cho PAL hoặc 'thay thế').

.. code-block:: none

   # Setup links
   media-ctl -l "'adv7180 3-0021':0 -> 'ipu1_csi0_mux':1[1]"
   media-ctl -l "'ipu1_csi0_mux':2 -> 'ipu1_csi0':0[1]"
   media-ctl -l "'ipu1_csi0':1 -> 'ipu1_vdic':0[1]"
   media-ctl -l "'ipu1_vdic':2 -> 'ipu1_ic_prp':0[1]"
   media-ctl -l "'ipu1_ic_prp':2 -> 'ipu1_ic_prpvf':0[1]"
   media-ctl -l "'ipu1_ic_prpvf':1 -> 'ipu1_ic_prpvf capture':0[1]"
   # Configure pads
   media-ctl -V "'adv7180 3-0021':0 [fmt:UYVY2X8/720x576 field:seq-tb]"
   media-ctl -V "'ipu1_csi0_mux':2 [fmt:UYVY2X8/720x576]"
   media-ctl -V "'ipu1_csi0':1 [fmt:AYUV32/720x576]"
   media-ctl -V "'ipu1_vdic':2 [fmt:AYUV32/720x576 field:none]"
   media-ctl -V "'ipu1_ic_prp':2 [fmt:AYUV32/720x576 field:none]"
   media-ctl -V "'ipu1_ic_prpvf':1 [fmt:AYUV32/720x576 field:none]"
   # Configure "ipu1_ic_prpvf capture" interface (assumed at /dev/video2)
   v4l2-ctl -d2 --set-fmt-video=field=none

Sau đó, quá trình phát trực tuyến có thể bắt đầu vào /dev/video2. Công cụ v4l2-ctl cũng có thể
được sử dụng để chọn bất kỳ định dạng pixel YUV nào được hỗ trợ trên /dev/video2.

Nền tảng này chấp nhận đầu vào tương tự Video tổng hợp cho ADV7180 trên
Ain1 (đầu nối J42).

i.MX6DL SabreAuto với bộ giải mã ADV7180
----------------------------------------

Trên i.MX6DL SabreAuto, bộ giải mã ADV7180 SD tích hợp được kết nối với
đầu vào bus song song trên mux video nội bộ tới IPU1 CSI0.

Ví dụ sau định cấu hình đường dẫn để chụp từ ADV7180
bộ giải mã video, giả sử tín hiệu đầu vào NTSC 720x480, sử dụng đơn giản
đan xen (không chuyển đổi và không bù chuyển động). Adv7180
phải xuất ra các trường tuần tự hoặc xen kẽ (loại trường 'seq-bt' cho
NTSC hoặc 'thay thế'):

.. code-block:: none

   # Setup links
   media-ctl -l "'adv7180 4-0021':0 -> 'ipu1_csi0_mux':4[1]"
   media-ctl -l "'ipu1_csi0_mux':5 -> 'ipu1_csi0':0[1]"
   media-ctl -l "'ipu1_csi0':2 -> 'ipu1_csi0 capture':0[1]"
   # Configure pads
   media-ctl -V "'adv7180 4-0021':0 [fmt:UYVY2X8/720x480 field:seq-bt]"
   media-ctl -V "'ipu1_csi0_mux':5 [fmt:UYVY2X8/720x480]"
   media-ctl -V "'ipu1_csi0':2 [fmt:AYUV32/720x480]"
   # Configure "ipu1_csi0 capture" interface (assumed at /dev/video0)
   v4l2-ctl -d0 --set-fmt-video=field=interlaced_bt

Sau đó, quá trình phát trực tuyến có thể bắt đầu vào /dev/video0. Công cụ v4l2-ctl cũng có thể
được sử dụng để chọn bất kỳ định dạng pixel YUV nào được hỗ trợ trên /dev/video0.

Ví dụ này định cấu hình đường dẫn để chụp từ ADV7180
bộ giải mã video, giả sử tín hiệu đầu vào PAL 720x576, với Chuyển động
Bồi thường de-interlacing. Adv7180 phải xuất ra tuần tự hoặc
các trường xen kẽ (loại trường 'seq-tb' cho PAL hoặc 'thay thế').

.. code-block:: none

   # Setup links
   media-ctl -l "'adv7180 4-0021':0 -> 'ipu1_csi0_mux':4[1]"
   media-ctl -l "'ipu1_csi0_mux':5 -> 'ipu1_csi0':0[1]"
   media-ctl -l "'ipu1_csi0':1 -> 'ipu1_vdic':0[1]"
   media-ctl -l "'ipu1_vdic':2 -> 'ipu1_ic_prp':0[1]"
   media-ctl -l "'ipu1_ic_prp':2 -> 'ipu1_ic_prpvf':0[1]"
   media-ctl -l "'ipu1_ic_prpvf':1 -> 'ipu1_ic_prpvf capture':0[1]"
   # Configure pads
   media-ctl -V "'adv7180 4-0021':0 [fmt:UYVY2X8/720x576 field:seq-tb]"
   media-ctl -V "'ipu1_csi0_mux':5 [fmt:UYVY2X8/720x576]"
   media-ctl -V "'ipu1_csi0':1 [fmt:AYUV32/720x576]"
   media-ctl -V "'ipu1_vdic':2 [fmt:AYUV32/720x576 field:none]"
   media-ctl -V "'ipu1_ic_prp':2 [fmt:AYUV32/720x576 field:none]"
   media-ctl -V "'ipu1_ic_prpvf':1 [fmt:AYUV32/720x576 field:none]"
   # Configure "ipu1_ic_prpvf capture" interface (assumed at /dev/video2)
   v4l2-ctl -d2 --set-fmt-video=field=none

Sau đó, quá trình phát trực tuyến có thể bắt đầu vào /dev/video2. Công cụ v4l2-ctl cũng có thể
được sử dụng để chọn bất kỳ định dạng pixel YUV nào được hỗ trợ trên /dev/video2.

Nền tảng này chấp nhận đầu vào tương tự Video tổng hợp cho ADV7180 trên
Ain1 (đầu nối J42).

i.MX6Q SabreSD với MIPI CSI-2 OV5640
-------------------------------------

Tương tự như i.MX6Q SabreLite, i.MX6Q SabreSD hỗ trợ song song
giao diện mô-đun OV5642 trên IPU1 CSI0 và MIPI CSI-2 OV5640
mô-đun. OV5642 kết nối với i2c bus 1 và OV5640 với i2c bus 2.

Cây thiết bị cho SabreSD bao gồm các đồ thị OF cho cả mạng song song
OV5642 và MIPI CSI-2 OV5640, nhưng tại thời điểm viết bài này chỉ có MIPI
CSI-2 OV5640 đã được thử nghiệm nên nút OV5642 hiện bị vô hiệu hóa.
Mô-đun OV5640 kết nối với đầu nối MIPI J5. Mã sản phẩm NXP
đối với mô-đun OV5640 kết nối với bo mạch SabreSD là H120729.

Ví dụ sau đây định cấu hình quy trình quay video chưa được xử lý để
chụp từ OV5640, truyền trên kênh ảo MIPI CSI-2 0:

.. code-block:: none

   # Setup links
   media-ctl -l "'ov5640 1-003c':0 -> 'imx6-mipi-csi2':0[1]"
   media-ctl -l "'imx6-mipi-csi2':1 -> 'ipu1_csi0_mux':0[1]"
   media-ctl -l "'ipu1_csi0_mux':2 -> 'ipu1_csi0':0[1]"
   media-ctl -l "'ipu1_csi0':2 -> 'ipu1_csi0 capture':0[1]"
   # Configure pads
   media-ctl -V "'ov5640 1-003c':0 [fmt:UYVY2X8/640x480]"
   media-ctl -V "'imx6-mipi-csi2':1 [fmt:UYVY2X8/640x480]"
   media-ctl -V "'ipu1_csi0_mux':0 [fmt:UYVY2X8/640x480]"
   media-ctl -V "'ipu1_csi0':0 [fmt:AYUV32/640x480]"

Sau đó, quá trình truyền phát có thể bắt đầu trên nút "ipu1_csi0 capture". v4l2-ctl
công cụ này có thể được sử dụng để chọn bất kỳ định dạng pixel nào được hỗ trợ khi chụp
nút thiết bị.

Để xác định nút /dev/video tương ứng với cái gì
"chụp ipu1_csi0":

.. code-block:: none

   media-ctl -e "ipu1_csi0 capture"
   /dev/video0

/dev/video0 là phần tử phát trực tuyến trong trường hợp này.

Bắt đầu truyền phát qua v4l2-ctl:

.. code-block:: none

   v4l2-ctl --stream-mmap -d /dev/video0

Bắt đầu truyền phát qua Gstreamer và gửi nội dung tới màn hình:

.. code-block:: none

   gst-launch-1.0 v4l2src device=/dev/video0 ! kmssink

Ví dụ sau định cấu hình quy trình chuyển đổi trực tiếp để nắm bắt
từ OV5640, truyền trên kênh ảo MIPI CSI-2 0. Nó cũng
hiển thị chuyển đổi không gian màu và chia tỷ lệ ở đầu ra IC.

.. code-block:: none

   # Setup links
   media-ctl -l "'ov5640 1-003c':0 -> 'imx6-mipi-csi2':0[1]"
   media-ctl -l "'imx6-mipi-csi2':1 -> 'ipu1_csi0_mux':0[1]"
   media-ctl -l "'ipu1_csi0_mux':2 -> 'ipu1_csi0':0[1]"
   media-ctl -l "'ipu1_csi0':1 -> 'ipu1_ic_prp':0[1]"
   media-ctl -l "'ipu1_ic_prp':1 -> 'ipu1_ic_prpenc':0[1]"
   media-ctl -l "'ipu1_ic_prpenc':1 -> 'ipu1_ic_prpenc capture':0[1]"
   # Configure pads
   media-ctl -V "'ov5640 1-003c':0 [fmt:UYVY2X8/640x480]"
   media-ctl -V "'imx6-mipi-csi2':1 [fmt:UYVY2X8/640x480]"
   media-ctl -V "'ipu1_csi0_mux':2 [fmt:UYVY2X8/640x480]"
   media-ctl -V "'ipu1_csi0':1 [fmt:AYUV32/640x480]"
   media-ctl -V "'ipu1_ic_prp':1 [fmt:AYUV32/640x480]"
   media-ctl -V "'ipu1_ic_prpenc':1 [fmt:ARGB8888_1X32/800x600]"
   # Set a format at the capture interface
   v4l2-ctl -d /dev/video1 --set-fmt-video=pixelformat=RGB3

Sau đó, quá trình truyền phát có thể bắt đầu trên nút "ipu1_ic_prpenc capture".

Để xác định nút /dev/video tương ứng với cái gì
"chụp ipu1_ic_prpenc":

.. code-block:: none

   media-ctl -e "ipu1_ic_prpenc capture"
   /dev/video1


/dev/video1 là phần tử phát trực tuyến trong trường hợp này.

Bắt đầu truyền phát qua v4l2-ctl:

.. code-block:: none

   v4l2-ctl --stream-mmap -d /dev/video1

Bắt đầu truyền phát qua Gstreamer và gửi nội dung tới màn hình:

.. code-block:: none

   gst-launch-1.0 v4l2src device=/dev/video1 ! kmssink

Sự cố đã biết
-------------

1. Khi sử dụng điều khiển xoay 90 hoặc 270 độ ở độ phân giải chụp
   gần giới hạn bộ thay đổi IC là 1024x1024 và kết hợp với mặt phẳng
   định dạng pixel (YUV420, YUV422p), việc chụp khung hình thường sẽ không thành công với
   không có ngắt cuối khung từ kênh IDMAC. Để làm việc xung quanh
   này, hãy sử dụng độ phân giải thấp hơn và/hoặc các định dạng đóng gói (YUYV, RGB3, v.v.)
   khi cần 90 hoặc 270 vòng quay.


Danh sách tập tin
-----------------

trình điều khiển/dàn dựng/media/imx/
bao gồm/media/imx.h
bao gồm/linux/imx-media.h

Tài liệu tham khảo
------------------

.. [#f1] http://www.nxp.com/assets/documents/data/en/reference-manuals/IMX6DQRM.pdf
.. [#f2] http://www.nxp.com/assets/documents/data/en/reference-manuals/IMX6SDLRM.pdf


tác giả
-------

- Steve Longerbeam <steve_longerbeam@mentor.com>
- Philipp Zabel <kernel@pengutronix.de>
- Vua Russell <linux@armlinux.org.uk>

Bản quyền (C) 2012-2017 Mentor Graphics Inc.