.. SPDX-License-Identifier: GPL-2.0 OR Linux-OpenIB

.. include:: ../../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/mellanox/mlx5/kconfig.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. include:: <isonum.txt>

==========================================
Kích hoạt tùy chọn trình điều khiển và kconfig
=======================================

:Bản quyền: ZZ0000ZZ 2023, NVIDIA CORPORATION & AFFILIATES. Mọi quyền được bảo lưu.

| Lõi mlx5 là mô-đun và hầu hết các tính năng chính của trình điều khiển lõi mlx5 có thể được chọn (biên dịch vào/ra)
| tại thời điểm xây dựng thông qua cờ Kconfig kernel.
| Các tính năng cơ bản, giảm tải rx/tx của thiết bị mạng ethernet và XDP, có sẵn với các cờ cơ bản nhất
| CONFIG_MLX5_CORE=y/m và CONFIG_MLX5_CORE_EN=y.
| Để biết danh sách các tính năng nâng cao, vui lòng xem bên dưới.

ZZ0000ZZ

|    Kích hoạt ZZ0000ZZ.
|    Điều này sẽ cung cấp khả năng thêm các đại diện của đường lên mlx5 và VF
|    các cổng tới Bridge và các quy định giảm tải cho giao thông giữa các cổng đó.
|    Hỗ trợ Vlan (chế độ trung kế và truy cập).


ZZ0000ZZ (mô-đun mlx5_core.ko)

|    Trình điều khiển có thể được kích hoạt bằng cách chọn CONFIG_MLX5_CORE=y/m trong cấu hình kernel.
|    Điều này sẽ cung cấp trình điều khiển lõi mlx5 cho mlx5 ulps để giao tiếp với (mlx5e, mlx5_ib).


ZZ0000ZZ

|    Việc chọn tùy chọn này sẽ cho phép hỗ trợ thiết bị mạng ethernet cơ bản với tất cả các giảm tải rx/tx tiêu chuẩn.
|    mlx5e là trình điều khiển ulp mlx5 cung cấp giao diện kernel netdevice, khi được chọn, mlx5e sẽ
|    được tích hợp vào mlx5_core.ko.


ZZ0000ZZ:

|    Kích hoạt ZZ0000ZZ.


ZZ0000ZZ

|    Hỗ trợ giảm tải và tăng tốc IPOIB.
|    Yêu cầu CONFIG_MLX5_CORE_EN cung cấp giao diện tăng tốc cho rdma
|    Thiết bị mạng IPoIB ulp.


ZZ0000ZZ

|    Cho phép hỗ trợ giảm tải cho hành động phân loại TC (NET_CLS_ACT).
|    Hoạt động ở cả chế độ NIC gốc và chế độ Switchdev SRIOV.
|    Các bộ phân loại dựa trên luồng, chẳng hạn như các bộ phân loại được đăng ký thông qua
|    ZZ0000ZZ, được xử lý bởi thiết bị chứ không phải bởi
|    chủ nhà. Các hành động sau đó sẽ ghi đè phân loại phù hợp
|    kết quả sau đó sẽ có ngay lập tức do giảm tải.


ZZ0000ZZ

|    Bật hỗ trợ điều khiển luồng nhận (arfs) được tăng tốc phần cứng và lọc nhiều bộ.
|    ZZ0000ZZ


ZZ0000ZZ

|    Kích hoạt ZZ0000ZZ.


ZZ0000ZZ

|    Xây dựng khả năng hỗ trợ tăng tốc giảm tải mật mã MACsec trong NIC.


ZZ0000ZZ

|    Cho phép ethtool nhận phân loại luồng mạng, cho phép người dùng xác định
|    quy tắc luồng để hướng lưu lượng truy cập vào hàng đợi rx tùy ý thông qua ethtool set/get_rxnfc API.


ZZ0000ZZ

|    Tăng tốc giảm tải mật mã TLS.


ZZ0000ZZ

|    Hỗ trợ E-Switch Ethernet SRIOV trong ConnectX NIC. E-Switch cung cấp khả năng điều khiển gói SRIOV nội bộ
|    và chuyển đổi các VF và PF được kích hoạt ở hai chế độ khả dụng:
|           1) ZZ0001ZZ.
|           2) ZZ0000ZZ.


ZZ0000ZZ

|    Xây dựng sự hỗ trợ cho dòng card mạng Innova của Mellanox Technologies.
|    Card mạng Innova bao gồm chip ConnectX và chip FPGA trên một bo mạch.
|    Nếu bạn chọn tùy chọn này, trình điều khiển mlx5_core sẽ bao gồm lõi Innova FPGA và cho phép
|    xây dựng trình điều khiển máy khách dành riêng cho sandbox.


ZZ0000ZZ (mô-đun mlx5_ib.ko)

|    Cung cấp hỗ trợ InfiniBand/RDMA và ZZ0000ZZ ở mức độ thấp.


ZZ0000ZZ

|    Hỗ trợ chuyển mạch chức năng đa vật lý Ethernet (MPFS) trong ConnectX NIC.
|    Cần có MPF khi cấu hình ZZ0000ZZ được bật để cho phép truyền
|    người dùng đã định cấu hình địa chỉ unicast MAC cho PF yêu cầu.


ZZ0000ZZ

|    Xây dựng hỗ trợ cho chức năng phụ.
|    Các chức năng phụ có trọng lượng nhẹ hơn PCI SRIOV VF. Việc chọn tùy chọn này
|    sẽ cho phép hỗ trợ tạo các thiết bị chức năng phụ.


ZZ0000ZZ

|    Xây dựng hỗ trợ cho cổng chức năng phụ trong NIC. Hàm con Mellanox
|    cổng được quản lý thông qua devlink.  Một chức năng phụ hỗ trợ RDMA, netdevice
|    và thiết bị vdpa. Nó tương tự như SRIOV VF nhưng không yêu cầu
|    Hỗ trợ SRIOV.


ZZ0000ZZ

|    Xây dựng hỗ trợ cho hệ thống lái được quản lý bằng phần mềm trong NIC.

ZZ0000ZZ

|    Xây dựng hỗ trợ cho hệ thống lái được quản lý bằng phần cứng trong NIC.

ZZ0000ZZ

|    Hỗ trợ giảm tải các quy tắc theo dõi kết nối thông qua hành động tc ct.


ZZ0000ZZ

|    Hỗ trợ giảm tải các quy tắc mẫu thông qua hành động mẫu tc.


ZZ0000ZZ

|    Thư viện hỗ trợ trình điều khiển Mellanox VDPA. Cung cấp mã đó là
|    chung cho tất cả các loại trình điều khiển VDPA. Các trình điều khiển sau đây được lên kế hoạch:
|    lưới, khối.


ZZ0000ZZ

|    Trình điều khiển mạng VDPA cho ConnectX6 và mới hơn. Cung cấp giảm tải
|    của đường dẫn dữ liệu mạng virtio sao cho các bộ mô tả được đặt trên vòng sẽ
|    được thực thi bởi phần cứng. Nó cũng hỗ trợ nhiều loại phi trạng thái
|    giảm tải tùy thuộc vào thiết bị thực tế được sử dụng và phiên bản chương trình cơ sở.


ZZ0000ZZ

|    Điều này cung cấp hỗ trợ di chuyển cho các thiết bị MLX5 sử dụng khung VFIO.


ZZ0000ZZ (Chọn nếu yêu cầu tính năng mlx5 tương ứng)

- CONFIG_MLXFW: Khi được chọn, hỗ trợ flash firmware mlx5 sẽ được bật (thông qua devlink và ethtool).
- CONFIG_PTP_1588_CLOCK: Khi được chọn, hỗ trợ ptp mlx5 sẽ được bật
- CONFIG_VXLAN: Khi được chọn, hỗ trợ mlx5 vxlan sẽ được bật.