.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/perf/nvidia-tegra410-pmu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================================================================
Bộ giám sát hiệu suất Uncore NVIDIA Tegra410 SoC (PMU)
===========================================================================

NVIDIA Tegra410 SoC bao gồm nhiều PMU hệ thống khác nhau để đo hiệu suất chính
các số liệu như băng thông bộ nhớ, độ trễ và mức sử dụng:

* Vải kết hợp thống nhất (UCF)
* PCIE
* PCIE-TGT
* Độ trễ của bộ nhớ CPU (CMEM)
* NVLink-C2C
* NV-CLink
* NV-DLink

Trình điều khiển PMU
--------------------

Trình điều khiển PMU mô tả các sự kiện và cấu hình có sẵn của mỗi PMU trong
sysfs. Vui lòng xem các phần bên dưới để biết đường dẫn sysfs của từng PMU. thích
trình điều khiển PMU không lõi khác, trình điều khiển cung cấp thuộc tính sysfs "cpumask" để hiển thị
id CPU được sử dụng để xử lý sự kiện PMU. Ngoài ra còn có "liên kết_cpus"
Thuộc tính sysfs, chứa danh sách các CPU được liên kết với phiên bản PMU.

UCF PMU
-------

Cấu trúc kết hợp thống nhất (UCF) trong NVIDIA Tegra410 SoC đóng vai trò như một
bộ đệm được phân phối, cấp độ cuối cùng cho Bộ nhớ CPU và Bộ nhớ CXL và bộ đệm nhất quán
kết nối hỗ trợ sự gắn kết phần cứng trên nhiều bộ nhớ đệm mạch lạc
đại lý, bao gồm:

* Cụm CPU
  * GPU
  * Bộ điều khiển đặt hàng PCIe (OCU)
  * Những người yêu cầu kết hợp IO khác

Các sự kiện và tùy chọn cấu hình của thiết bị PMU này được mô tả trong sysfs,
xem /sys/bus/event_source/devices/nvidia_ucf_pmu_<socket-id>.

Một số sự kiện có sẵn trong PMU này có thể được sử dụng để đo băng thông và
sử dụng:

*slc_access_rd: đếm số lượng yêu cầu đọc tới SLC.
  *slc_access_wr: đếm số lượng yêu cầu ghi vào SLC.
  * slc_bytes_rd: đếm số byte được truyền bởi slc_access_rd.
  * slc_bytes_wr: đếm số byte được truyền bởi slc_access_wr.
  * mem_access_rd: đếm số lượng yêu cầu đọc vào bộ nhớ cục bộ hoặc từ xa.
  * mem_access_wr: đếm số lượng yêu cầu ghi vào bộ nhớ cục bộ hoặc từ xa.
  * mem_bytes_rd: đếm số byte được mem_access_rd truyền.
  * mem_bytes_wr: đếm số byte được mem_access_wr truyền.
  * chu kỳ: đếm số chu kỳ UCF.

Băng thông trung bình được tính như sau:

AVG_SLC_READ_BANDWIDTH_IN_GBPS = SLC_BYTES_RD / ELAPSED_TIME_IN_NS
   AVG_SLC_WRITE_BANDWIDTH_IN_GBPS = SLC_BYTES_WR / ELAPSED_TIME_IN_NS
   AVG_MEM_READ_BANDWIDTH_IN_GBPS = MEM_BYTES_RD / ELAPSED_TIME_IN_NS
   AVG_MEM_WRITE_BANDWIDTH_IN_GBPS = MEM_BYTES_WR / ELAPSED_TIME_IN_NS

Tỷ lệ yêu cầu trung bình được tính như sau:

AVG_SLC_READ_REQUEST_RATE = SLC_ACCESS_RD / CYCLES
   AVG_SLC_WRITE_REQUEST_RATE = SLC_ACCESS_WR / CYCLES
   AVG_MEM_READ_REQUEST_RATE = MEM_ACCESS_RD / CYCLES
   AVG_MEM_WRITE_REQUEST_RATE = MEM_ACCESS_WR / CYCLES

Bạn có thể tìm thêm thông tin chi tiết về những sự kiện khác có sẵn trong Tegra410 SoC
hướng dẫn tham khảo kỹ thuật.

Các sự kiện có thể được lọc dựa trên nguồn hoặc đích. Bộ lọc nguồn
cho biết bộ khởi tạo lưu lượng đến SLC, ví dụ: CPU cục bộ, thiết bị không phải CPU hoặc
ổ cắm từ xa. Bộ lọc đích chỉ định loại bộ nhớ đích,
ví dụ: bộ nhớ hệ thống cục bộ (CMEM), bộ nhớ GPU cục bộ (GMEM) hoặc bộ nhớ từ xa. các
Phân loại cục bộ/từ xa của bộ lọc đích dựa trên nhà
ổ cắm của địa chỉ, không phải nơi dữ liệu thực sự cư trú. Có sẵn
bộ lọc được mô tả trong
/sys/bus/event_source/devices/nvidia_ucf_pmu_<socket-id>/format/.

Danh sách bộ lọc sự kiện UCF PMU:

* Lọc nguồn:

* src_loc_cpu: nếu được đặt, hãy đếm các sự kiện từ CPU cục bộ
  * src_loc_noncpu: nếu được đặt, hãy đếm các sự kiện từ thiết bị cục bộ không phải CPU
  * src_rem: nếu được đặt, đếm các sự kiện từ các thiết bị CPU, GPU, PCIE của ổ cắm từ xa

* Bộ lọc đích:

* dst_loc_cmem: nếu được đặt, sẽ đếm các sự kiện vào địa chỉ bộ nhớ hệ thống cục bộ (CMEM)
  * dst_loc_gmem: nếu được đặt, hãy đếm các sự kiện vào địa chỉ bộ nhớ GPU (GMEM) cục bộ
  * dst_loc_other: nếu được đặt, hãy đếm các sự kiện vào địa chỉ bộ nhớ CXL cục bộ
  * dst_rem: nếu được đặt, đếm các sự kiện tới địa chỉ bộ nhớ CPU, GPU và CXL của ổ cắm từ xa

Nếu nguồn không được chỉ định, PMU sẽ đếm các sự kiện từ tất cả các nguồn. Nếu
đích không được chỉ định, PMU sẽ tính các sự kiện cho tất cả các đích.

Cách sử dụng ví dụ:

* Đếm id sự kiện 0x0 trong socket 0 từ tất cả các nguồn và tới tất cả các đích::

chỉ số hoàn hảo -a -e nvidia_ucf_pmu_0/event=0x0/

* Đếm id sự kiện 0x0 trong socket 0 với bộ lọc nguồn = CPU cục bộ và đích
  bộ lọc = bộ nhớ hệ thống cục bộ (CMEM)::

chỉ số hoàn hảo -a -e nvidia_ucf_pmu_0/event=0x0,src_loc_cpu=0x1,dst_loc_cmem=0x1/

* Đếm id sự kiện 0x0 trong ổ cắm 1 với bộ lọc nguồn = thiết bị cục bộ không phải CPU và
  bộ lọc đích = bộ nhớ từ xa::

chỉ số hoàn hảo -a -e nvidia_ucf_pmu_1/event=0x0,src_loc_noncpu=0x1,dst_rem=0x1/

PCIE PMU
--------

PMU này nằm trong cấu trúc SOC kết nối tổ hợp gốc PCIE (RC) và
hệ thống con bộ nhớ. Nó giám sát tất cả lưu lượng đọc/ghi từ (các) cổng gốc
hoặc một BDF cụ thể trong PCIE RC vào bộ nhớ cục bộ hoặc từ xa. Có một PMU mỗi
PCIE RC trong SoC. Mỗi RC có thể có tối đa 16 làn đường được chia thành
lên đến 8 cổng gốc. Lưu lượng từ mỗi cổng gốc có thể được lọc bằng RP hoặc
Bộ lọc BDF. Ví dụ: chỉ định "src_rp_mask=0xFF" có nghĩa là bộ đếm PMU sẽ
nắm bắt lưu lượng truy cập từ tất cả các RP. Vui lòng xem bên dưới để biết thêm chi tiết.

Các sự kiện và tùy chọn cấu hình của thiết bị PMU này được mô tả trong sysfs,
xem /sys/bus/event_source/devices/nvidia_pcie_pmu_<socket-id>_rc_<pcie-rc-id>.

Các sự kiện trong PMU này có thể được sử dụng để đo băng thông, mức sử dụng và
độ trễ:

*rd_req: đếm số lượng yêu cầu đọc của thiết bị PCIE.
  * wr_req: đếm số lượng yêu cầu ghi của thiết bị PCIE.
  *rd_bytes: đếm số byte được truyền bởi rd_req.
  * wr_bytes: đếm số byte được truyền bởi wr_req.
  * rd_cum_outs: đếm số rd_req còn tồn đọng trong mỗi chu kỳ.
  * chu kỳ: đếm chu kỳ xung nhịp của vải SOC được kết nối với giao diện PCIE.

Băng thông trung bình được tính như sau:

AVG_RD_BANDWIDTH_IN_GBPS = RD_BYTES / ELAPSED_TIME_IN_NS
   AVG_WR_BANDWIDTH_IN_GBPS = WR_BYTES / ELAPSED_TIME_IN_NS

Tỷ lệ yêu cầu trung bình được tính như sau:

AVG_RD_REQUEST_RATE = RD_REQ / CYCLES
   AVG_WR_REQUEST_RATE = WR_REQ / CYCLES


Độ trễ trung bình được tính như sau:

FREQ_IN_GHZ = CYCLES / ELAPSED_TIME_IN_NS
   AVG_LATENCY_IN_CYCLES = RD_CUM_OUTS / RD_REQ
   AVERAGE_LATENCY_IN_NS = AVG_LATENCY_IN_CYCLES / FREQ_IN_GHZ

Các sự kiện PMU có thể được lọc dựa trên nguồn và đích lưu lượng truy cập.
Bộ lọc nguồn cho biết các thiết bị PCIE sẽ được giám sát. các
bộ lọc đích chỉ định loại bộ nhớ đích, ví dụ: hệ thống cục bộ
bộ nhớ (CMEM), bộ nhớ GPU cục bộ (GMEM) hoặc bộ nhớ từ xa. Địa phương/từ xa
việc phân loại bộ lọc đích dựa trên ổ cắm chính của
địa chỉ chứ không phải nơi dữ liệu thực sự cư trú. Những bộ lọc này có thể được tìm thấy trong
/sys/bus/event_source/devices/nvidia_pcie_pmu_<socket-id>_rc_<pcie-rc-id>/format/.

Danh sách các bộ lọc sự kiện:

* Lọc nguồn:

* src_rp_mask: bitmask của cổng gốc sẽ được giám sát. Mỗi bit trong này
    bitmask đại diện cho chỉ số RP trong RC. Nếu bit được đặt, tất cả các thiết bị trong
    RP liên quan sẽ được theo dõi. Ví dụ: "src_rp_mask=0xF" sẽ giám sát
    thiết bị ở cổng gốc 0 đến 3.
  * src_bdf: BDF sẽ được theo dõi. Đây là giá trị 16 bit
    theo công thức: (bus << 8) + (thiết bị << 3) + (chức năng). Ví dụ,
    giá trị của BDF 27:01.1 là 0x2781.
  * src_bdf_en: bật bộ lọc BDF. Nếu điều này được đặt, giá trị bộ lọc BDF trong
    "src_bdf" được sử dụng để lọc lưu lượng.

Lưu ý rằng các bộ lọc Root-Port và BDF loại trừ lẫn nhau và PMU trong
  mỗi RC chỉ có thể có một bộ lọc BDF cho toàn bộ bộ đếm. Nếu bộ lọc BDF
  được bật, giá trị bộ lọc BDF sẽ được áp dụng cho tất cả các sự kiện.

* Bộ lọc đích:

* dst_loc_cmem: nếu được đặt, sẽ đếm các sự kiện vào địa chỉ bộ nhớ hệ thống cục bộ (CMEM)
  * dst_loc_gmem: nếu được đặt, hãy đếm các sự kiện vào địa chỉ bộ nhớ GPU (GMEM) cục bộ
  * dst_loc_pcie_p2p: nếu được đặt, hãy đếm các sự kiện vào địa chỉ ngang hàng PCIE cục bộ
  * dst_loc_pcie_cxl: nếu được đặt, hãy đếm các sự kiện vào địa chỉ bộ nhớ CXL cục bộ
  * dst_rem: nếu được đặt, đếm các sự kiện vào địa chỉ bộ nhớ từ xa

Nếu bộ lọc nguồn không được chỉ định, PMU sẽ đếm các sự kiện từ tất cả các nguồn gốc
cổng. Nếu bộ lọc đích không được chỉ định, PMU sẽ đếm các sự kiện
tới mọi điểm đến.

Cách sử dụng ví dụ:

* Đếm id sự kiện 0x0 từ cổng gốc 0 của PCIE RC-0 trên ổ cắm 0 nhắm mục tiêu tất cả
  điểm đến::

chỉ số hoàn hảo -a -e nvidia_pcie_pmu_0_rc_0/event=0x0,src_rp_mask=0x1/

* Đếm id sự kiện 0x1 từ cổng gốc 0 và 1 của PCIE RC-1 trên socket 0 và
  chỉ nhắm mục tiêu CMEM cục bộ của ổ cắm 0::

chỉ số hoàn hảo -a -e nvidia_pcie_pmu_0_rc_1/event=0x1,src_rp_mask=0x3,dst_loc_cmem=0x1/

* Đếm id sự kiện 0x2 từ cổng gốc 0 của PCIE RC-2 trên ổ cắm 1 nhắm mục tiêu tất cả
  điểm đến::

chỉ số hoàn hảo -a -e nvidia_pcie_pmu_1_rc_2/event=0x2,src_rp_mask=0x1/

* Đếm id sự kiện 0x3 từ cổng gốc 0 và 1 của PCIE RC-3 trên socket 1 và
  chỉ nhắm mục tiêu CMEM cục bộ của ổ cắm 1::

chỉ số hoàn hảo -a -e nvidia_pcie_pmu_1_rc_3/event=0x3,src_rp_mask=0x3,dst_loc_cmem=0x1/

* Đếm id sự kiện 0x4 từ BDF 01:01.0 của PCIE RC-4 trên ổ cắm 0 nhắm mục tiêu tất cả
  điểm đến::

chỉ số hoàn hảo -a -e nvidia_pcie_pmu_0_rc_4/event=0x4,src_bdf=0x0180,src_bdf_en=0x1/

.. _NVIDIA_T410_PCIE_PMU_RC_Mapping_Section:

Ánh xạ số phân đoạn lspci RC# to
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Việc ánh xạ số phân đoạn lspci RC# to có thể không hề đơn giản; do đó có một chiếc NVIDIA mới
Thanh ghi Khả năng cụ thể của nhà cung cấp được chỉ định (DVSEC) được thêm vào không gian cấu hình PCIE
cho mỗi RP. DVSEC này có id nhà cung cấp "10de" và id DVSEC là "0x4". Thanh ghi DVSEC
chứa thông tin sau để ánh xạ các thiết bị PCIE trong RP trở lại RC# của nó:

- Bus# (byte 0xc): số bus được báo cáo bởi đầu ra lspci
  - Segment# (byte 0xd): số đoạn được báo cáo bởi đầu ra lspci
  - RP# (byte 0xe): số cổng được báo cáo bởi thuộc tính LnkCap từ lspci cho thiết bị có khả năng Root Port
  - RC# (byte 0xf): số phức gốc liên kết với RP
  - Socket# (byte 0x10): số socket liên kết với RP

Tập lệnh mẫu để ánh xạ lspci BDF tới RC# and socket#::

#!/bin/bash
  trong khi đọc bdf còn lại; làm
    dvsec4_reg=$(lspci -vv -s $bdf | awk '
      /Nhà cung cấp được chỉ định cụ thể: Nhà cung cấp=10de ID=0004/ {
        match($0, /\[([0-9a-fA-F]+)/, arr);
        in "0x" mảng[1];
        lối ra
      }
    ')
    nếu [ -n "$dvsec4_reg" ]; sau đó
      bus=$(setpci -s $bdf $(printf '0x%x' $((${dvsec4_reg} + 0xc))).b)
      Segment=$(setpci -s $bdf $(printf '0x%x' $((${dvsec4_reg} + 0xd))).b)
      rp=$(setpci -s $bdf $(printf '0x%x' $((${dvsec4_reg} + 0xe))).b)
      rc=$(setpci -s $bdf $(printf '0x%x' $((${dvsec4_reg} + 0xf))).b)
      socket=$(setpci -s $bdf $(printf '0x%x' $((${dvsec4_reg} + 0x10))).b)
      echo "$bdf: Bus=$bus, Segment=$segment, RP=$rp, RC=$rc, Socket=$socket"
    fi
  xong < <(lspci -d 10de:)

Đầu ra ví dụ::

0001:00:00.0: Bus=00, Phân đoạn=01, RP=00, RC=00, Ổ cắm=00
  0002:80:00.0: Bus=80, Phân đoạn=02, RP=01, RC=01, Ổ cắm=00
  0002:a0:00.0: Bus=a0, Phân đoạn=02, RP=02, RC=01, Ổ cắm=00
  0002:c0:00.0: Bus=c0, Phân đoạn=02, RP=03, RC=01, Ổ cắm=00
  0002:e0:00.0: Bus=e0, Phân đoạn=02, RP=04, RC=01, Ổ cắm=00
  0003:00:00.0: Bus=00, Phân đoạn=03, RP=00, RC=02, Ổ cắm=00
  0004:00:00.0: Bus=00, Đoạn=04, RP=00, RC=03, Ổ cắm=00
  0005:00:00.0: Bus=00, Phân đoạn=05, RP=00, RC=04, Ổ cắm=00
  0005:40:00.0: Bus=40, Đoạn=05, RP=01, RC=04, Ổ cắm=00
  0005:c0:00.0: Bus=c0, Phân đoạn=05, RP=02, RC=04, Ổ cắm=00
  0006:00:00.0: Bus=00, Phân đoạn=06, RP=00, RC=05, Ổ cắm=00
  0009:00:00.0: Bus=00, Phân đoạn=09, RP=00, RC=00, Ổ cắm=01
  000a:80:00.0: Bus=80, Phân đoạn=0a, RP=01, RC=01, Ổ cắm=01
  000a:a0:00.0: Bus=a0, Phân đoạn=0a, RP=02, RC=01, Ổ cắm=01
  000a:e0:00.0: Bus=e0, Phân đoạn=0a, RP=03, RC=01, Ổ cắm=01
  000b:00:00.0: Bus=00, Phân đoạn=0b, RP=00, RC=02, Ổ cắm=01
  000c:00:00.0: Bus=00, Phân đoạn=0c, RP=00, RC=03, Ổ cắm=01
  000d:00:00.0: Bus=00, Phân đoạn=0d, RP=00, RC=04, Ổ cắm=01
  000d:40:00.0: Bus=40, Đoạn=0d, RP=01, RC=04, Ổ cắm=01
  000d:c0:00.0: Bus=c0, Phân đoạn=0d, RP=02, RC=04, Ổ cắm=01
  000e:00:00.0: Bus=00, Đoạn=0e, RP=00, RC=05, Ổ cắm=01

PCIE-TGT PMU
------------

PMU này nằm trong cấu trúc SOC kết nối tổ hợp gốc PCIE (RC) và
hệ thống con bộ nhớ. Nó giám sát lưu lượng truy cập nhắm mục tiêu trong phạm vi PCIE BAR và CXL HDM.
Có một PCIE-TGT PMU trên mỗi PCIE RC trong SoC. Mỗi RC trong Tegra410 SoC có thể
có tối đa 16 làn đường có thể được chia thành tối đa 8 cổng gốc (RP). PMU
cung cấp bộ lọc RP để đếm lưu lượng truy cập PCIE BAR đến mỗi RP và bộ lọc địa chỉ tới
đếm quyền truy cập vào các phạm vi PCIE BAR hoặc CXL HDM. Các chi tiết của bộ lọc được
được mô tả trong các phần sau.

Ánh xạ số phân đoạn lspci RC# to tương tự như PCIE PMU. Xin vui lòng xem
ZZ0000ZZ để biết thêm thông tin.

Các sự kiện và tùy chọn cấu hình của thiết bị PMU này có sẵn trong sysfs,
xem /sys/bus/event_source/devices/nvidia_pcie_tgt_pmu_<socket-id>_rc_<pcie-rc-id>.

Các sự kiện trong PMU này có thể được sử dụng để đo băng thông và mức sử dụng:

*rd_req: đếm số lượng yêu cầu đọc tới PCIE.
  * wr_req: đếm số lượng yêu cầu ghi vào PCIE.
  *rd_bytes: đếm số byte được truyền bởi rd_req.
  * wr_bytes: đếm số byte được truyền bởi wr_req.
  * chu kỳ: đếm chu kỳ xung nhịp của vải SOC được kết nối với giao diện PCIE.

Băng thông trung bình được tính như sau:

AVG_RD_BANDWIDTH_IN_GBPS = RD_BYTES / ELAPSED_TIME_IN_NS
   AVG_WR_BANDWIDTH_IN_GBPS = WR_BYTES / ELAPSED_TIME_IN_NS

Tỷ lệ yêu cầu trung bình được tính như sau:

AVG_RD_REQUEST_RATE = RD_REQ / CYCLES
   AVG_WR_REQUEST_RATE = WR_REQ / CYCLES

Các sự kiện PMU có thể được lọc dựa trên cổng đích hoặc cổng đích
phạm vi địa chỉ. Lọc dựa trên RP chỉ khả dụng cho lưu lượng truy cập PCIE BAR.
Bộ lọc địa chỉ hoạt động cho cả hai phạm vi PCIE BAR và CXL HDM. Các bộ lọc này có thể
được tìm thấy trong sysfs, xem
/sys/bus/event_source/devices/nvidia_pcie_tgt_pmu_<socket-id>_rc_<pcie-rc-id>/format/.

Cài đặt bộ lọc đích:

* dst_rp_mask: bitmask để chọn (các) cổng gốc để giám sát. Ví dụ. "dst_rp_mask=0xFF"
  tương ứng với tất cả các cổng gốc (từ 0 đến 7) trong PCIE RC. Lưu ý rằng bộ lọc này
  chỉ khả dụng cho lưu lượng truy cập PCIE BAR.
* dst_addr_base: Địa chỉ cơ sở bộ lọc BAR hoặc CXL HDM.
* dst_addr_mask: Mặt nạ địa chỉ bộ lọc BAR hoặc CXL HDM.
* dst_addr_en: bật bộ lọc phạm vi địa chỉ BAR hoặc CXL HDM. Nếu điều này được thiết lập,
  dải địa chỉ được chỉ định bởi "dst_addr_base" và "dst_addr_mask" sẽ được sử dụng để lọc
  địa chỉ lưu lượng truy cập PCIE BAR và CXL HDM. PMU sử dụng so sánh sau
  để xác định xem địa chỉ đích lưu lượng có nằm trong phạm vi bộ lọc hay không::

(addr của txn & dst_addr_mask) == (dst_addr_base & dst_addr_mask)

Nếu so sánh thành công thì sự kiện sẽ được tính.

Nếu bộ lọc đích không được chỉ định, bộ lọc RP sẽ được cấu hình theo mặc định
để đếm lưu lượng truy cập PCIE BAR đến tất cả các cổng gốc.

Cách sử dụng ví dụ:

* Đếm id sự kiện 0x0 vào cổng gốc 0 và 1 của PCIE RC-0 trên socket 0::

chỉ số hoàn hảo -a -e nvidia_pcie_tgt_pmu_0_rc_0/event=0x0,dst_rp_mask=0x3/

* Đếm id sự kiện 0x1 để truy cập vào dải địa chỉ PCIE BAR hoặc CXL HDM
  0x10000 đến 0x100FF trên ổ cắm 0 PCIE RC-1::

chỉ số hoàn hảo -a -e nvidia_pcie_tgt_pmu_0_rc_1/event=0x1,dst_addr_base=0x10000,dst_addr_mask=0xFFF00,dst_addr_en=0x1/

Độ trễ bộ nhớ CPU (CMEM) PMU
-----------------------------

PMU này giám sát các sự kiện độ trễ của các yêu cầu đọc bộ nhớ từ rìa của
Vải kết hợp thống nhất (UCF) đến CPU DRAM cục bộ:

* Bộ đếm RD_REQ: đếm số yêu cầu đọc (32B mỗi yêu cầu).
  * Bộ đếm RD_CUM_OUTS: bộ đếm yêu cầu chưa thanh toán tích lũy, theo dõi
    yêu cầu đọc đang diễn ra bao nhiêu chu kỳ.
  * Bộ đếm CYCLES: đếm số chu kỳ đã trôi qua.

Độ trễ trung bình được tính như sau:

FREQ_IN_GHZ = CYCLES / ELAPSED_TIME_IN_NS
   AVG_LATENCY_IN_CYCLES = RD_CUM_OUTS / RD_REQ
   AVERAGE_LATENCY_IN_NS = AVG_LATENCY_IN_CYCLES / FREQ_IN_GHZ

Các sự kiện và tùy chọn cấu hình của thiết bị PMU này được mô tả trong sysfs,
xem /sys/bus/event_source/devices/nvidia_cmem_latency_pmu_<socket-id>.

Ví dụ sử dụng::

chỉ số hoàn hảo -a -e '{nvidia_cmem_latency_pmu_0/rd_req/,nvidia_cmem_latency_pmu_0/rd_cum_outs/,nvidia_cmem_latency_pmu_0/cycles/}'

NVLink-C2C PMU
--------------

PMU này giám sát các sự kiện độ trễ của các yêu cầu đọc/ghi bộ nhớ đi qua
giao diện NVIDIA Chip-to-Chip (C2C). Sự kiện băng thông không có sẵn
trong PMU này, không giống như C2C PMU trong Grace (Tegra241 SoC).

Các sự kiện và tùy chọn cấu hình của thiết bị PMU này có sẵn trong sysfs,
xem /sys/bus/event_source/devices/nvidia_nvlink_c2c_pmu_<socket-id>.

Danh sách các sự kiện:

* IN_RD_CUM_OUTS: tích lũy yêu cầu chưa xử lý (theo chu kỳ) của các yêu cầu đọc đến.
  * IN_RD_REQ: số lượng yêu cầu đọc đến.
  * IN_WR_CUM_OUTS: tích lũy yêu cầu chưa xử lý (theo chu kỳ) của các yêu cầu ghi đến.
  * IN_WR_REQ: số lượng yêu cầu ghi vào.
  * OUT_RD_CUM_OUTS: tích lũy yêu cầu chưa xử lý (theo chu kỳ) của các yêu cầu đọc đi.
  * OUT_RD_REQ: số lượng yêu cầu đọc đi.
  * OUT_WR_CUM_OUTS: tích lũy yêu cầu chưa xử lý (theo chu kỳ) của các yêu cầu ghi gửi đi.
  * OUT_WR_REQ: số lượng yêu cầu ghi gửi đi.
  * CYCLES: Đếm chu kỳ giao diện NVLink-C2C.

Các sự kiện đến sẽ đếm số lần đọc/ghi từ thiết bị từ xa tới SoC.
Các sự kiện gửi đi sẽ đếm số lần đọc/ghi từ SoC tới thiết bị từ xa.

Các sysfs /sys/bus/event_source/devices/nvidia_nvlink_c2c_pmu_<socket-id>/peer
chứa thông tin về thiết bị được kết nối.

Khi giao diện C2C được kết nối với (các) GPU, người dùng có thể sử dụng
Tham số "gpu_mask" để lọc lưu lượng truy cập đến/từ (các) GPU cụ thể. Mỗi bit đại diện cho GPU
chỉ mục, ví dụ: "gpu_mask=0x1" tương ứng với GPU 0 và "gpu_mask=0x3" tương ứng với GPU 0 và 1.
PMU sẽ giám sát tất cả các GPU theo mặc định nếu không được chỉ định.

Khi được kết nối với một SoC khác, chỉ có các sự kiện đọc mới khả dụng.

Các sự kiện có thể được sử dụng để tính toán độ trễ trung bình của các yêu cầu đọc/ghi::

C2C_FREQ_IN_GHZ = CYCLES / ELAPSED_TIME_IN_NS

IN_RD_AVG_LATENCY_IN_CYCLES = IN_RD_CUM_OUTS / IN_RD_REQ
   IN_RD_AVG_LATENCY_IN_NS = IN_RD_AVG_LATENCY_IN_CYCLES / C2C_FREQ_IN_GHZ

IN_WR_AVG_LATENCY_IN_CYCLES = IN_WR_CUM_OUTS / IN_WR_REQ
   IN_WR_AVG_LATENCY_IN_NS = IN_WR_AVG_LATENCY_IN_CYCLES / C2C_FREQ_IN_GHZ

OUT_RD_AVG_LATENCY_IN_CYCLES = OUT_RD_CUM_OUTS / OUT_RD_REQ
   OUT_RD_AVG_LATENCY_IN_NS = OUT_RD_AVG_LATENCY_IN_CYCLES / C2C_FREQ_IN_GHZ

OUT_WR_AVG_LATENCY_IN_CYCLES = OUT_WR_CUM_OUTS / OUT_WR_REQ
   OUT_WR_AVG_LATENCY_IN_NS = OUT_WR_AVG_LATENCY_IN_CYCLES / C2C_FREQ_IN_GHZ

Cách sử dụng ví dụ:

* Đếm lưu lượng truy cập đến từ tất cả các GPU được kết nối qua NVLink-C2C::

chỉ số hoàn hảo -a -e nvidia_nvlink_c2c_pmu_0/in_rd_req/

* Đếm lưu lượng truy cập đến từ GPU 0 được kết nối qua NVLink-C2C::

chỉ số hoàn hảo -a -e nvidia_nvlink_c2c_pmu_0/in_rd_cum_outs,gpu_mask=0x1/

* Đếm lưu lượng truy cập đến từ GPU 1 được kết nối qua NVLink-C2C::

chỉ số hoàn hảo -a -e nvidia_nvlink_c2c_pmu_0/in_rd_cum_outs,gpu_mask=0x2/

* Đếm lưu lượng gửi đi tới tất cả các GPU được kết nối qua NVLink-C2C::

chỉ số hoàn hảo -a -e nvidia_nvlink_c2c_pmu_0/out_rd_req/

* Đếm lưu lượng đi tới GPU 0 được kết nối qua NVLink-C2C::

chỉ số hoàn hảo -a -e nvidia_nvlink_c2c_pmu_0/out_rd_cum_outs,gpu_mask=0x1/

* Đếm lưu lượng đi đến GPU 1 được kết nối qua NVLink-C2C::

chỉ số hoàn hảo -a -e nvidia_nvlink_c2c_pmu_0/out_rd_cum_outs,gpu_mask=0x2/

NV-CLink PMU
------------

PMU này theo dõi các sự kiện độ trễ của các yêu cầu đọc bộ nhớ đi qua
giao diện NV-CLINK. Các sự kiện băng thông không có sẵn trong PMU này.
Trong Tegra410 SoC, giao diện NV-CLink được sử dụng để kết nối với Tegra410 khác
SoC và PMU này chỉ tính lưu lượng đọc.

Các sự kiện và tùy chọn cấu hình của thiết bị PMU này có sẵn trong sysfs,
xem /sys/bus/event_source/devices/nvidia_nvclink_pmu_<socket-id>.

Danh sách các sự kiện:

* IN_RD_CUM_OUTS: tích lũy yêu cầu chưa xử lý (theo chu kỳ) của các yêu cầu đọc đến.
  * IN_RD_REQ: số lượng yêu cầu đọc đến.
  * OUT_RD_CUM_OUTS: tích lũy yêu cầu chưa xử lý (theo chu kỳ) của các yêu cầu đọc đi.
  * OUT_RD_REQ: số lượng yêu cầu đọc đi.
  * CYCLES: Đếm chu kỳ giao diện NV-CLINK.

Các sự kiện đến sẽ đếm số lần đọc từ thiết bị từ xa đến SoC.
Các sự kiện gửi đi sẽ đếm số lần đọc từ SoC tới thiết bị từ xa.

Các sự kiện có thể được sử dụng để tính toán độ trễ trung bình của các yêu cầu đọc::

CLINK_FREQ_IN_GHZ = CYCLES / ELAPSED_TIME_IN_NS

IN_RD_AVG_LATENCY_IN_CYCLES = IN_RD_CUM_OUTS / IN_RD_REQ
   IN_RD_AVG_LATENCY_IN_NS = IN_RD_AVG_LATENCY_IN_CYCLES / CLINK_FREQ_IN_GHZ

OUT_RD_AVG_LATENCY_IN_CYCLES = OUT_RD_CUM_OUTS / OUT_RD_REQ
   OUT_RD_AVG_LATENCY_IN_NS = OUT_RD_AVG_LATENCY_IN_CYCLES / CLINK_FREQ_IN_GHZ

Cách sử dụng ví dụ:

* Đếm lưu lượng đọc đến từ SoC từ xa được kết nối qua NV-CLINK::

chỉ số hoàn hảo -a -e nvidia_nvclink_pmu_0/in_rd_req/

* Đếm lưu lượng đọc đi tới SoC từ xa được kết nối qua NV-CLINK::

chỉ số hoàn hảo -a -e nvidia_nvclink_pmu_0/out_rd_req/

NV-DLink PMU
------------

PMU này theo dõi các sự kiện độ trễ của các yêu cầu đọc bộ nhớ đi qua
giao diện NV-DLINK.  Các sự kiện băng thông không có sẵn trong PMU này.
Trong Tegra410 SoC, PMU này chỉ tính lưu lượng đọc bộ nhớ CXL.

Các sự kiện và tùy chọn cấu hình của thiết bị PMU này có sẵn trong sysfs,
xem /sys/bus/event_source/devices/nvidia_nvdlink_pmu_<socket-id>.

Danh sách các sự kiện:

* IN_RD_CUM_OUTS: tích lũy các yêu cầu đọc chưa xử lý (theo chu kỳ) vào bộ nhớ CXL.
  * IN_RD_REQ: số lượng yêu cầu đọc vào bộ nhớ CXL.
  * CYCLES: Đếm chu kỳ giao diện NV-DLINK.

Các sự kiện có thể được sử dụng để tính toán độ trễ trung bình của các yêu cầu đọc::

DLINK_FREQ_IN_GHZ = CYCLES / ELAPSED_TIME_IN_NS

IN_RD_AVG_LATENCY_IN_CYCLES = IN_RD_CUM_OUTS / IN_RD_REQ
   IN_RD_AVG_LATENCY_IN_NS = IN_RD_AVG_LATENCY_IN_CYCLES / DLINK_FREQ_IN_GHZ

Cách sử dụng ví dụ:

* Đếm các sự kiện đã đọc vào bộ nhớ CXL::

chỉ số hoàn hảo -a -e '{nvidia_nvdlink_pmu_0/in_rd_req/,nvidia_nvdlink_pmu_0/in_rd_cum_outs/}'
