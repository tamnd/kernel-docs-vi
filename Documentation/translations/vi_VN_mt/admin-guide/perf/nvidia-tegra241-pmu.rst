.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/perf/nvidia-tegra241-pmu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================================================================
Bộ giám sát hiệu suất Uncore NVIDIA Tegra241 SoC (PMU)
============================================================

NVIDIA Tegra241 SoC bao gồm nhiều PMU hệ thống khác nhau để đo hiệu suất chính
các số liệu như băng thông bộ nhớ, độ trễ và mức sử dụng:

* Vải kết hợp có thể mở rộng (SCF)
* NVLink-C2C0
* NVLink-C2C1
*Liên kết CNV
* PCIE

Trình điều khiển PMU
----------

Các PMU trong tài liệu này dựa trên Kiến trúc ARM CoreSight PMU như
được mô tả trong tài liệu: ARM IHI 0091. Vì đây là kiến trúc tiêu chuẩn nên
Các PMU được quản lý bởi một trình điều khiển chung "arm-cs-arch-pmu". Trình điều khiển này mô tả
các sự kiện và cấu hình có sẵn của từng PMU trong sysfs. Xin vui lòng xem
các phần bên dưới để nhận đường dẫn sysfs của mỗi PMU. Giống như các trình điều khiển PMU không lõi khác,
trình điều khiển cung cấp thuộc tính sysfs "cpumask" để hiển thị id CPU được sử dụng để xử lý
sự kiện PMU. Ngoài ra còn có thuộc tính sysfs "liên kết_cpus", chứa một
danh sách các CPU được liên kết với phiên bản PMU.

.. _SCF_PMU_Section:

SCF PMU
-------

SCF PMU giám sát các sự kiện bộ đệm cấp hệ thống, lưu lượng truy cập CPU và
thứ tự mạnh mẽ (SO) PCIE ghi lưu lượng truy cập vào bộ nhớ cục bộ/từ xa. Xin vui lòng xem
ZZ0000ZZ để biết thêm thông tin về PMU
phủ sóng giao thông.

Các sự kiện và tùy chọn cấu hình của thiết bị PMU này được mô tả trong sysfs,
xem /sys/bus/event_source/devices/nvidia_scf_pmu_<socket-id>.

Cách sử dụng ví dụ:

* Đếm id sự kiện 0x0 trong socket 0::

chỉ số hoàn hảo -a -e nvidia_scf_pmu_0/event=0x0/

* Đếm id sự kiện 0x0 trong socket 1::

chỉ số hoàn hảo -a -e nvidia_scf_pmu_1/event=0x0/

NVLink-C2C0 PMU
--------------------

NVLink-C2C0 PMU giám sát lưu lượng truy cập đến từ GPU/CPU được kết nối với
Kết nối NVLink-C2C (Chip-2-Chip). Loại lưu lượng truy cập được ghi lại bởi PMU này
thay đổi tùy thuộc vào cấu hình chip:

* NVIDIA Grace Hopper Superchip: Hopper GPU được kết nối với Grace SoC.

Trong cấu hình này, PMU ghi lại lưu lượng truy cập GPU ATS đã dịch hoặc EGM từ GPU.

* NVIDIA Grace CPU Superchip: hai SoC Grace CPU được kết nối.

Trong cấu hình này, PMU ghi lại việc đọc và ghi theo thứ tự thoải mái (RO) từ
  Thiết bị PCIE của SoC từ xa.

Vui lòng xem ZZ0000ZZ để biết thêm thông tin về
vùng phủ sóng giao thông PMU.

Các sự kiện và tùy chọn cấu hình của thiết bị PMU này được mô tả trong sysfs,
xem /sys/bus/event_source/devices/nvidia_nvlink_c2c0_pmu_<socket-id>.

Cách sử dụng ví dụ:

* Đếm id sự kiện 0x0 từ GPU/CPU được kết nối với ổ cắm 0::

chỉ số hoàn hảo -a -e nvidia_nvlink_c2c0_pmu_0/event=0x0/

* Đếm id sự kiện 0x0 từ GPU/CPU được kết nối với ổ cắm 1::

chỉ số hoàn hảo -a -e nvidia_nvlink_c2c0_pmu_1/event=0x0/

* Đếm id sự kiện 0x0 từ GPU/CPU được kết nối với ổ cắm 2::

chỉ số hoàn hảo -a -e nvidia_nvlink_c2c0_pmu_2/event=0x0/

* Đếm id sự kiện 0x0 từ GPU/CPU được kết nối với ổ cắm 3::

chỉ số hoàn hảo -a -e nvidia_nvlink_c2c0_pmu_3/event=0x0/

NVLink-C2C có hai cổng có thể được kết nối với một GPU (chiếm cả hai cổng)
cổng) hoặc hai GPU (một GPU trên mỗi cổng). Người dùng có thể sử dụng bitmap "cổng"
tham số để chọn (các) cổng để giám sát. Mỗi bit đại diện cho số cổng,
ví dụ: "port=0x1" tương ứng với cổng 0 và "port=0x3" tương ứng với cổng 0 và 1.
PMU sẽ giám sát cả hai cổng theo mặc định nếu không được chỉ định.

Ví dụ về lọc cổng:

* Đếm id sự kiện 0x0 từ GPU được kết nối với socket 0 trên cổng 0::

chỉ số hoàn hảo -a -e nvidia_nvlink_c2c0_pmu_0/event=0x0,port=0x1/

* Đếm id sự kiện 0x0 từ GPU được kết nối với socket 0 trên cổng 0 và cổng 1::

chỉ số hoàn hảo -a -e nvidia_nvlink_c2c0_pmu_0/event=0x0,port=0x3/

NVLink-C2C1 PMU
-------------------

NVLink-C2C1 PMU giám sát lưu lượng truy cập đến từ GPU được kết nối với
Kết nối NVLink-C2C (Chip-2-Chip). PMU này chụp GPU chưa được dịch
lưu lượng truy cập, trái ngược với NvLink-C2C0 PMU ghi lại lưu lượng dịch ATS.
Vui lòng xem ZZ0000ZZ để biết thêm thông tin về
vùng phủ sóng giao thông PMU.

Các sự kiện và tùy chọn cấu hình của thiết bị PMU này được mô tả trong sysfs,
xem /sys/bus/event_source/devices/nvidia_nvlink_c2c1_pmu_<socket-id>.

Cách sử dụng ví dụ:

* Đếm id sự kiện 0x0 từ GPU được kết nối với ổ cắm 0::

chỉ số hoàn hảo -a -e nvidia_nvlink_c2c1_pmu_0/event=0x0/

* Đếm id sự kiện 0x0 từ GPU được kết nối với ổ cắm 1::

chỉ số hoàn hảo -a -e nvidia_nvlink_c2c1_pmu_1/event=0x0/

* Đếm id sự kiện 0x0 từ GPU được kết nối với ổ cắm 2::

chỉ số hoàn hảo -a -e nvidia_nvlink_c2c1_pmu_2/event=0x0/

* Đếm id sự kiện 0x0 từ GPU được kết nối với ổ cắm 3::

chỉ số hoàn hảo -a -e nvidia_nvlink_c2c1_pmu_3/event=0x0/

NVLink-C2C có hai cổng có thể được kết nối với một GPU (chiếm cả hai cổng)
cổng) hoặc hai GPU (một GPU trên mỗi cổng). Người dùng có thể sử dụng bitmap "cổng"
tham số để chọn (các) cổng để giám sát. Mỗi bit đại diện cho số cổng,
ví dụ: "port=0x1" tương ứng với cổng 0 và "port=0x3" tương ứng với cổng 0 và 1.
PMU sẽ giám sát cả hai cổng theo mặc định nếu không được chỉ định.

Ví dụ về lọc cổng:

* Đếm id sự kiện 0x0 từ GPU được kết nối với socket 0 trên cổng 0::

chỉ số hoàn hảo -a -e nvidia_nvlink_c2c1_pmu_0/event=0x0,port=0x1/

* Đếm id sự kiện 0x0 từ GPU được kết nối với socket 0 trên cổng 0 và cổng 1::

chỉ số hoàn hảo -a -e nvidia_nvlink_c2c1_pmu_0/event=0x0,port=0x3/

CNVLink PMU
---------------

CNVLink PMU giám sát lưu lượng truy cập từ thiết bị GPU và PCIE trên ổ cắm từ xa
tới bộ nhớ cục bộ. Đối với lưu lượng truy cập PCIE, PMU này ghi lại việc đọc và sắp xếp thứ tự thoải mái
(RO) ghi lưu lượng. Vui lòng xem ZZ0000ZZ
để biết thêm thông tin về phạm vi phủ sóng giao thông PMU.

Các sự kiện và tùy chọn cấu hình của thiết bị PMU này được mô tả trong sysfs,
xem /sys/bus/event_source/devices/nvidia_cnvlink_pmu_<socket-id>.

Mỗi ổ cắm SoC có thể được kết nối với một hoặc nhiều ổ cắm thông qua CNVLink. Người dùng có thể
sử dụng tham số bitmap "rem_socket" để chọn (các) ổ cắm từ xa cần giám sát.
Mỗi bit đại diện cho số ổ cắm, ví dụ: "rem_socket=0xE" tương ứng với
ổ cắm 1 đến 3. PMU sẽ giám sát tất cả các ổ cắm từ xa theo mặc định nếu không
được chỉ định.
/sys/bus/event_source/devices/nvidia_cnvlink_pmu_<socket-id>/format/rem_socket
hiển thị các bit hợp lệ có thể được đặt trong tham số "rem_socket".

PMU không thể phân biệt được bộ khởi tạo lưu lượng truy cập từ xa, do đó nó không
cung cấp bộ lọc để chọn nguồn lưu lượng để theo dõi. Nó báo kết hợp
lưu lượng truy cập từ các thiết bị GPU và PCIE từ xa.

Cách sử dụng ví dụ:

* Đếm id sự kiện 0x0 cho lưu lượng truy cập từ ổ cắm từ xa 1, 2 và 3 đến ổ cắm 0::

chỉ số hoàn hảo -a -e nvidia_cnvlink_pmu_0/event=0x0,rem_socket=0xE/

* Đếm id sự kiện 0x0 cho lưu lượng truy cập từ ổ cắm từ xa 0, 2 và 3 đến ổ cắm 1::

chỉ số hoàn hảo -a -e nvidia_cnvlink_pmu_1/event=0x0,rem_socket=0xD/

* Đếm id sự kiện 0x0 cho lưu lượng truy cập từ ổ cắm từ xa 0, 1 và 3 đến ổ cắm 2::

chỉ số hoàn hảo -a -e nvidia_cnvlink_pmu_2/event=0x0,rem_socket=0xB/

* Đếm id sự kiện 0x0 cho lưu lượng truy cập từ ổ cắm từ xa 0, 1 và 2 đến ổ cắm 3::

chỉ số hoàn hảo -a -e nvidia_cnvlink_pmu_3/event=0x0,rem_socket=0x7/


PCIE PMU
------------

PCIE PMU giám sát tất cả lưu lượng đọc/ghi từ các cổng gốc PCIE tới
bộ nhớ cục bộ/từ xa. Vui lòng xem ZZ0000ZZ
để biết thêm thông tin về phạm vi phủ sóng giao thông PMU.

Các sự kiện và tùy chọn cấu hình của thiết bị PMU này được mô tả trong sysfs,
xem /sys/bus/event_source/devices/nvidia_pcie_pmu_<socket-id>.

Mỗi ổ cắm SoC có thể hỗ trợ nhiều cổng gốc. Người dùng có thể sử dụng
Tham số bitmap "root_port" để chọn (các) cổng cần giám sát, tức là.
"root_port=0xF" tương ứng với cổng gốc 0 đến 3. PMU sẽ giám sát tất cả gốc
cổng theo mặc định nếu không được chỉ định.
/sys/bus/event_source/devices/nvidia_pcie_pmu_<socket-id>/format/root_port
hiển thị các bit hợp lệ có thể được đặt trong tham số "root_port".

Cách sử dụng ví dụ:

* Đếm id sự kiện 0x0 từ cổng gốc 0 và 1 của socket 0::

chỉ số hoàn hảo -a -e nvidia_pcie_pmu_0/event=0x0,root_port=0x3/

* Đếm id sự kiện 0x0 từ cổng gốc 0 và 1 của socket 1::

chỉ số hoàn hảo -a -e nvidia_pcie_pmu_1/event=0x0,root_port=0x3/

.. _NVIDIA_Uncore_PMU_Traffic_Coverage_Section:

Bảo hiểm giao thông
----------------

Phạm vi phủ sóng lưu lượng PMU có thể thay đổi tùy thuộc vào cấu hình chip:

* ZZ0000ZZ: Hopper GPU được kết nối với Grace SoC.

Cấu hình ví dụ với hai Grace SoC::

*******************************ZZ0002ZZ******************************
   * SOCKET-A * * SOCKET-B *
   * * * *
   * ::::::::: * * :::::::: *
   * : PCIE : * * : PCIE : *
   * ::::::::: * * :::::::: *
   * ZZ0004ZZ *
   * ZZ0005ZZ *
   * ::::::: ::::::::: * * ::::::::: ::::::: *
   * : : : : * * : : : : *
   * : GPU :<--NVLink-->: Grace :<---CNVLink--->: Grace :<--NVLink-->: GPU : *
   * : : C2C : SoC : * * : SoC : C2C : : *
   * ::::::: ::::::::: * * ::::::::: ::::::: *
   * ZZ0006ZZ * * ZZ0007ZZ *
   * ZZ0008ZZ * * ZZ0009ZZ *
   * &&&&&&&&&&&&&&&* * &&&&&&&&&&&&&&&*
   * & GMEM & & CMEM & * * & CMEM & & GMEM & *
   * &&&&&&&&&&&&&&&* * &&&&&&&&&&&&&&&*
   * * * *
   *******************************ZZ0003ZZ******************************

GMEM = Bộ nhớ GPU (ví dụ: HBM)
   CMEM = Bộ nhớ CPU (ví dụ: LPDDR5X)

|
  | Bảng sau chứa phạm vi lưu lượng truy cập của Grace SoC PMU trong socket-A:

  ::

+--------------+-------+----------+----------+------+----------+----------+
   Nguồn ZZ0000ZZ |
   + +-------+----------+-------------+------+----------+----------+
   ZZ0001ZZ ZZ0002ZZGPU Không-ATSZZ0003ZZ Ổ cắm-B ZZ0004ZZ
   ZZ0005ZZPCI R/W|Translated,|Đã dịch ZZ0007ZZ CPU/PCIE1ZZ0008ZZ
   ZZ0009ZZ ZZ0010ZZ ZZ0011ZZ ZZ0012ZZ
   +===============+========+===============================================================================================================================
   ZZ0013ZZ PCIE |NVLink-C2C0|NVLink-C2C1ZZ0015ZZ SCF PMU ZZ0016ZZ
   ZZ0017ZZ PMU ZZ0018ZZPMU ZZ0019ZZ ZZ0020ZZ
   +--------------+-------+----------+----------+------+----------+----------+
   ZZ0021ZZ PCIE |    N/A    |NVLink-C2C1ZZ0023ZZ SCF PMU ZZ0024ZZ
   ZZ0025ZZ PMU ZZ0026ZZPMU ZZ0027ZZ ZZ0028ZZ
   +--------------+-------+----------+----------+------+----------+----------+
   ZZ0029ZZ PCIE |NVLink-C2C0|NVLink-C2C1ZZ0031ZZ ZZ0032ZZ
   ZZ0033ZZ PMU ZZ0034ZZPMU ZZ0035ZZ Không áp dụng ZZ0036ZZ
   ZZ0037ZZ ZZ0038ZZ ZZ0039ZZ ZZ0040ZZ
   +--------------+-------+----------+----------+------+----------+----------+
   ZZ0041ZZ PCIE |NVLink-C2C0|NVLink-C2C1ZZ0043ZZ ZZ0044ZZ
   ZZ0045ZZ PMU ZZ0046ZZPMU ZZ0047ZZ Không áp dụng ZZ0048ZZ
   +--------------+-------+----------+----------+------+----------+----------+

Lưu lượng PCIE1 thể hiện việc ghi theo thứ tự mạnh mẽ (SO).
   Lưu lượng PCIE2 đại diện cho việc đọc và ghi theo thứ tự thoải mái (RO).

* ZZ0000ZZ: hai SoC Grace CPU được kết nối.

Cấu hình ví dụ với hai Grace SoC::

****************ZZ0002ZZ***************
   * SOCKET-A * * SOCKET-B *
   * * * *
   * ::::::::: * * :::::::: *
   * : PCIE : * * : PCIE : *
   * ::::::::: * * :::::::: *
   * ZZ0004ZZ *
   * ZZ0005ZZ *
   * ::::::::: * * ::::::::: *
   * : : * * : : *
   * : Grace :<--------NVLink------->: Grace : *
   * : SoC : * C2C * : SoC : *
   * ::::::::: * * ::::::::: *
   * ZZ0006ZZ *
   * ZZ0007ZZ *
   * &&&&&&&&* * &&&&&&&& *
   * & CMEM & * * & CMEM & *
   * &&&&&&&&* * &&&&&&&& *
   * * * *
   ****************ZZ0003ZZ***************

GMEM = Bộ nhớ GPU (ví dụ: HBM)
   CMEM = Bộ nhớ CPU (ví dụ: LPDDR5X)

|
  | Bảng sau chứa phạm vi lưu lượng truy cập của Grace SoC PMU trong socket-A:

  ::

+--------+----------+---------+----------+-------------+
   Nguồn ZZ0000ZZ |
   + +----------+----------+----------+-------------+
   ZZ0001ZZ ZZ0002ZZ Ổ cắm-B ZZ0003ZZ
   ZZ0004ZZ PCI R/W ZZ0005ZZ CPU/PCIE1ZZ0006ZZ
   ZZ0007ZZ ZZ0008ZZ ZZ0009ZZ
   +==================+========================================================+
   ZZ0010ZZ PCIE PMU ZZ0011ZZ SCF PMU ZZ0012ZZ
   ZZ0013ZZ ZZ0014ZZ ZZ0015ZZ
   +--------+----------+---------+----------+-------------+
   ZZ0016ZZ ZZ0017ZZ ZZ0018ZZ
   ZZ0019ZZ PCIE PMU ZZ0020ZZ Không áp dụng ZZ0021ZZ
   ZZ0022ZZ ZZ0023ZZ ZZ0024ZZ
   +--------+----------+---------+----------+-------------+

Lưu lượng PCIE1 thể hiện việc ghi theo thứ tự mạnh mẽ (SO).
   Lưu lượng PCIE2 đại diện cho việc đọc và ghi theo thứ tự thoải mái (RO).
