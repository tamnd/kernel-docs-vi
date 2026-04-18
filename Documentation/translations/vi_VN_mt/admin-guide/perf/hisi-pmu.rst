.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/perf/hisi-pmu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================================================
Đơn vị giám sát hiệu suất uncore của HiSilicon SoC (PMU)
===========================================================

Chip HiSilicon SoC bao gồm nhiều PMU thiết bị hệ thống độc lập khác nhau
chẳng hạn như bộ đệm L3 (L3C), Hydra Home Agent (HHA) và DDRC. Các PMU này được
độc lập và có logic phần cứng để thu thập số liệu thống kê và hiệu suất
thông tin.

HiSilicon SoC đóng gói nhiều khuôn CPU và IO. Mỗi cụm CPU
(CCL) được tạo thành từ 4 lõi cpu chia sẻ một bộ đệm L3; mỗi khuôn CPU là
được gọi là cụm Super CPU (SCCL) và được tạo thành từ 6 CCL. Mỗi SCCL có
hai HHA (0 - 1) và bốn DDRC (0 - 3), tương ứng.

Trình điều khiển PMU không lõi của HiSilicon SoC
-------------------------------

Mỗi thiết bị PMU có các thanh ghi riêng để đếm sự kiện, điều khiển và
ngắt và trình điều khiển PMU sẽ đăng ký trình điều khiển PMU hoàn hảo như L3C,
HHA và DDRC, v.v. Các sự kiện và tùy chọn cấu hình có sẵn sẽ
được mô tả trong sysfs, xem::

/sys/bus/event_source/devices/hisi_sccl{X></l3c{Y}/hha{Y}/ddrc{Y}>

Lệnh "danh sách hoàn hảo" sẽ liệt kê các sự kiện có sẵn từ sysfs.

Mỗi L3C, HHA và DDRC được đăng ký dưới dạng PMU riêng biệt với sự hoàn hảo. PMU
tên sẽ xuất hiện trong danh sách sự kiện dưới dạng hisi_sccl<sccl-id>_module<index-id>.
trong đó "sccl-id" là mã định danh của SCCL và "index-id" là chỉ mục của
mô-đun.

ví dụ. hisi_sccl3_l3c0/rd_hit_cpipe là sự kiện READ_HIT_CPIPE của L3C chỉ số #0 trong
SCCL ID #3.

ví dụ. hisi_sccl1_hha0/rx_Operations là sự kiện RX_OPERATIONS của HHA chỉ số #0 trong
SCCL ID #1.

Trình điều khiển cũng cung cấp thuộc tính sysfs "cpumask", hiển thị lõi CPU
ID được sử dụng để đếm sự kiện PMU chưa được xử lý. Thuộc tính sysfs "liên kết_cpus" là
cũng được cung cấp để hiển thị các CPU được liên kết với PMU này. "cpumask" biểu thị
CPU sẽ mở các sự kiện, thường là gợi ý cho các công cụ trong không gian người dùng như perf.
Nó chỉ chứa một CPU được liên kết từ "liên kết_cpus".

Ví dụ sử dụng perf::

Danh sách $# perf
  hisi_sccl3_l3c0/rd_hit_cpipe/ [sự kiện kernel PMU]
  ------------------------------------------
  hisi_sccl3_l3c0/wr_hit_cpipe/ [sự kiện kernel PMU]
  ------------------------------------------
  hisi_sccl1_l3c0/rd_hit_cpipe/ [sự kiện kernel PMU]
  ------------------------------------------
  hisi_sccl1_l3c0/wr_hit_cpipe/ [sự kiện kernel PMU]
  ------------------------------------------

$# perf stat -a -e hisi_sccl3_l3c0/rd_hit_cpipe/ ngủ 5
  $# perf stat -a -e hisi_sccl3_l3c0/config=0x02/ ngủ 5

Đối với HiSilicon uncore PMU v2 có mã định danh là 0x30, cấu trúc liên kết giống nhau
như PMU v1, nhưng một số chức năng mới được thêm vào phần cứng.

1. L3C PMU hỗ trợ lọc theo lõi/luồng trong cụm có thể
được chỉ định dưới dạng bitmap::

$# perf stat -a -e hisi_sccl3_l3c0/config=0x02,tt_core=0x3/ ngủ 5

Điều này sẽ chỉ tính các hoạt động từ lõi/luồng 0 và 1 trong cụm này.

Người dùng không nên sử dụng tt_core_deprecated để chỉ định lọc lõi/luồng.
Tùy chọn này được cung cấp để tương thích ngược và chỉ hỗ trợ 8bit
có thể không bao gồm tất cả việc chia sẻ lõi/luồng L3C.

2. Tracetag cho phép người dùng chọn chỉ đếm đọc, viết hoặc nguyên tử
hoạt động thông qua tham số tt_req trong perf. Giá trị mặc định tính tất cả
hoạt động. tt_req là 3bits, 3'b100 thể hiện thao tác đọc, 3'b101
đại diện cho các hoạt động ghi, 3'b110 đại diện cho các hoạt động lưu trữ nguyên tử và
3'b111 đại diện cho các hoạt động không lưu trữ nguyên tử, các giá trị khác được bảo lưu ::

$# perf stat -a -e hisi_sccl3_l3c0/config=0x02,tt_req=0x4/ ngủ 5

Điều này sẽ chỉ tính các hoạt động đọc trong cụm này.

3. Datasrc cho phép người dùng kiểm tra dữ liệu đến từ đâu. Đó là 5 bit.
Một số mã quan trọng như sau:

- 5'b00001: xuất phát từ L3C trong khuôn này;
- 5'b01000: xuất phát từ L3C trong khuôn chéo;
- 5'b01001: xuất phát từ L3C nằm trong ổ cắm khác;
- 5'b01110: xuất phát từ DDR cục bộ;
- 5'b01111: xuất phát từ khuôn chéo DDR;
- 5'b10000: xuất phát từ ổ cắm chéo DDR;

v.v., điều chủ yếu là hữu ích khi biết rằng nguồn dữ liệu gần nhất với CPU
lõi. Nếu datasrc_cfg được sử dụng trong nhiều chip thì datasrc_skt sẽ là
được cấu hình trong lệnh hoàn hảo ::

Chỉ số $# perf -a -e hisi_sccl3_l3c0/config=0xb9,datasrc_cfg=0xE/,
  hisi_sccl3_l3c0/config=0xb9,datasrc_cfg=0xF/ ngủ 5

4. Một số SoC HiSilicon đóng gói nhiều khuôn CPU và IO. Mỗi khuôn CPU
chứa một số Cụm tính toán (CCL). Các khuôn I/O được gọi là Super I/O
cụm (SICL) chứa nhiều cụm I/O (ICL). Mỗi CCL/ICL trong
SoC có một ID duy nhất. Mỗi ID là 11 bit, bao gồm SCCL-ID 6 bit và 5 bit
CCL/ICL-ID. Đối với khuôn I/O, ICL-ID được theo sau bởi:

- 5'b00000: I/O_MGMT_ICL;
- 5'b00001: Network_ICL;
- 5'b00011: HAC_ICL;
- 5'b10000: PCIe_ICL;

5. uring_channel: Sự kiện UC PMU 0x47~0x59 hỗ trợ lọc theo yêu cầu tx
kênh đang hoạt động. Đó là 2 bit. Một số mã quan trọng như sau:

- 2'b11: đếm các sự kiện gửi tới kênh uring_ext (MATA);
- 2'b01: giống 2'b11;
- 2'b10: đếm các sự kiện gửi đến kênh uring (không phải MATA);
- 2'b00: giá trị mặc định, đếm các sự kiện được gửi tới cả uring và
  kênh uring_ext;

6. ch: NoC PMU hỗ trợ lọc số lượng sự kiện của giao dịch nhất định
kênh với tùy chọn này. Các kênh được hỗ trợ hiện tại như sau:

- 3'b010: Yêu cầu kênh
- 3'b100: Kênh rình mò
- 3'b110: Kênh phản hồi
- 3'b111: Kênh dữ liệu

7. tt_en: NoC PMU chỉ hỗ trợ tính các giao dịch đã đặt tracetag
nếu tùy chọn này được đặt. Xem danh sách thứ 2 để biết thêm thông tin về tracetag.

Đối với HiSilicon uncore PMU v3 có mã định danh là 0x40, một số PMU không lõi là
được chia thành nhiều phần để theo dõi chi tiết hơn, mỗi phần có
sở hữu PMU chuyên dụng và tất cả các PMU như vậy cùng nhau đảm nhiệm công việc giám sát các sự kiện
trên thiết bị uncore cụ thể. Các PMU như vậy được mô tả trong sysfs với định dạng tên
thay đổi một chút::

/sys/bus/event_source/devices/hisi_sccl{X__<l3c{Y} _{Z}/ddrc{Y} _{Z}/noc{Y__{Z}>

Z là id phụ, biểu thị các PMU khác nhau cho một phần thiết bị phần cứng.

Việc sử dụng hầu hết các PMU với các id phụ khác nhau đều giống nhau. Đặc biệt, L3C PMU
cung cấp tùy chọn ZZ0000ZZ để cho phép khám phá số liệu thống kê chi tiết hơn nữa
của L3C PMU.  Trình điều khiển L3C PMU sử dụng điều đó làm gợi ý chấm dứt khi phân phối
lệnh hoàn hảo cho phần cứng:

- ext=0: Mặc định, có thể dùng với tên sự kiện.
- ext=1 và ext=2: Phải được sử dụng với mã sự kiện, tên sự kiện không được hỗ trợ.

Một ví dụ về lệnh hoàn hảo có thể là::

$# perf stat -a -e hisi_sccl0_l3c1_0/rd_spipe/ ngủ 5

hoặc::

$# perf stat -a -e hisi_sccl0_l3c1_0/event=0x1,ext=1/ ngủ 5

Như trên, ZZ0000ZZ định vị PMU của Super CPU CLuster 0, L3 cache 1
ống0.

Lệnh đầu tiên định vị phần đầu tiên của L3C vì ZZ0000ZZ được ngụ ý bởi
mặc định. Lệnh thứ hai thực hiện việc đếm trên một phần khác của L3C với
sự kiện ZZ0001ZZ.

Người dùng có thể định cấu hình ID để đếm dữ liệu đến từ CCL/ICL cụ thể bằng cách cài đặt
srcid_cmd & srcid_msk và dữ liệu được xác định cho CCL/ICL cụ thể bằng cách cài đặt
tgtid_cmd & tgtid_msk. Một bit được đặt trong srcid_msk/tgtid_msk có nghĩa là PMU sẽ không
kiểm tra bit khi khớp với srcid_cmd/tgtid_cmd.

Nếu tất cả các tùy chọn này bị tắt, nó có thể hoạt động theo giá trị mặc định
không phân biệt điều kiện lọc và thông tin ID và sẽ trả về
tổng giá trị bộ đếm trong bộ đếm PMU.

Trình điều khiển hiện tại không hỗ trợ lấy mẫu. Vì vậy "bản ghi hoàn hảo" không được hỗ trợ.
Ngoài ra, việc đính kèm vào một tác vụ cũng không được hỗ trợ vì tất cả các sự kiện đều không có cốt lõi.

Lưu ý: Vui lòng liên hệ với nhà bảo trì để biết danh sách đầy đủ các sự kiện được hỗ trợ cho
các thiết bị PMU trong SoC và thông tin của nó nếu cần.
