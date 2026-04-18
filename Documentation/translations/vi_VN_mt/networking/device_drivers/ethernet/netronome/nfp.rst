.. SPDX-License-Identifier: (GPL-2.0-only OR BSD-2-Clause)

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/netronome/nfp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

===============================================
Trình điều khiển hạt nhân của Bộ xử lý luồng mạng (NFP)
===========================================

:Bản quyền: ZZ0000ZZ 2019, Netronome Systems, Inc.
:Bản quyền: ZZ0001ZZ 2022, Corigine, Inc.

Nội dung
========

-ZZ0000ZZ
-ZZ0001ZZ
-ZZ0002ZZ
-ZZ0003ZZ
-ZZ0004ZZ

Tổng quan
========

Trình điều khiển này hỗ trợ dòng Bộ xử lý luồng mạng của Netronome và Corigine
các thiết bị, bao gồm các mẫu NFP3800, NFP4000, NFP5000 và NFP6000,
cũng được kết hợp trong dòng Agilio SmartNIC của công ty. SR-IOV
Các chức năng vật lý và ảo cho các thiết bị này đều được trình điều khiển hỗ trợ.

Lấy phần mềm cơ sở
==================

Các thiết bị NFP3800, NFP4000 và NFP6000 yêu cầu chương trình cơ sở dành riêng cho ứng dụng
để hoạt động. Phần sụn ứng dụng có thể được đặt trên hệ thống tệp máy chủ
hoặc trong flash của thiết bị (nếu được phần mềm quản lý hỗ trợ).

Các tệp chương trình cơ sở trên hệ thống tệp máy chủ chứa loại thẻ (chuỗi ZZ0000ZZ), phương tiện
config, v.v. Chúng nên được đặt trong thư mục ZZ0001ZZ để
tải chương trình cơ sở từ hệ thống tập tin máy chủ.

Phần sụn cho hoạt động NIC cơ bản có sẵn ở phiên bản ngược dòng
Kho lưu trữ ZZ0000ZZ.

Bạn có thể tải xuống danh sách chương trình cơ sở đầy đủ hơn từ
ZZ0000ZZ.

Phần sụn trong NVRAM
-----------------

Các phiên bản firmware quản lý gần đây hỗ trợ tải ứng dụng
firmware từ flash khi trình điều khiển máy chủ được thăm dò. Đang tải firmware
cấu hình chính sách có thể được sử dụng để định cấu hình tính năng này một cách thích hợp.

Devlink hoặc ethtool có thể dùng để cập nhật firmware ứng dụng trên thiết bị
flash bằng cách cung cấp tệp ZZ0000ZZ thích hợp cho thiết bị tương ứng
lệnh. Người dùng cần chú ý ghi đúng hình ảnh chương trình cơ sở cho
cấu hình thẻ và phương tiện để flash.

Dung lượng lưu trữ sẵn có trong flash tùy thuộc vào thẻ được sử dụng.

Xử lý nhiều dự án
------------------------------

Phần cứng NFP hoàn toàn có thể lập trình được do đó có thể có nhiều lựa chọn khác nhau
hình ảnh phần sụn nhắm mục tiêu các ứng dụng khác nhau.

Khi sử dụng chương trình cơ sở ứng dụng từ máy chủ, chúng tôi khuyên bạn nên đặt
các tập tin phần sụn thực tế trong các thư mục con có tên ứng dụng trong
ZZ0000ZZ và liên kết các tệp mong muốn, ví dụ::

$ cây /lib/firmware/netronome/
    /lib/firmware/netronome/
    ├── bpf
    │   ├── nic_AMDA0081-0001_1x40.nffw
    │   └── nic_AMDA0081-0001_4x10.nffw
    ├── hoa
    │   ├── nic_AMDA0081-0001_1x40.nffw
    │   └── nic_AMDA0081-0001_4x10.nffw
    ├── không sao đâu
    │   ├── nic_AMDA0081-0001_1x40.nffw
    │   └── nic_AMDA0081-0001_4x10.nffw
    ├── nic_AMDA0081-0001_1x40.nffw -> bpf/nic_AMDA0081-0001_1x40.nffw
    └── nic_AMDA0081-0001_4x10.nffw -> bpf/nic_AMDA0081-0001_4x10.nffw

3 thư mục, 8 tập tin

Bạn có thể cần sử dụng hard thay vì các liên kết tượng trưng trên các bản phân phối
sử dụng lệnh ZZ0000ZZ cũ thay vì ZZ0001ZZ (ví dụ: Ubuntu).

Sau khi thay đổi tập tin chương trình cơ sở, bạn có thể cần tạo lại initramfs
hình ảnh. Initramfs chứa các trình điều khiển và tập tin chương trình cơ sở mà hệ thống của bạn có thể
cần khởi động. Tham khảo tài liệu về bản phân phối của bạn để tìm
cách cập nhật initramfs. Dấu hiệu tốt về initramfs cũ
hệ thống đang tải sai trình điều khiển hoặc chương trình cơ sở khi khởi động, nhưng khi tải trình điều khiển
sau đó tải lại thủ công, mọi thứ đều hoạt động chính xác.

Chọn phần sụn cho mỗi thiết bị
-----------------------------

Thông thường nhất là tất cả các thẻ trên hệ thống đều sử dụng cùng một loại chương trình cơ sở.
Nếu bạn muốn tải một hình ảnh chương trình cơ sở cụ thể cho một thẻ cụ thể, bạn
có thể sử dụng địa chỉ bus PCI hoặc số sê-ri. Người lái xe sẽ
in những tập tin nó đang tìm kiếm khi nhận ra thiết bị NFP::

nfp: Tìm file firmware theo thứ tự ưu tiên:
    nfp: netronome/serial-00-12-34-aa-bb-cc-10-ff.nffw: không tìm thấy
    nfp: netronome/pci-0000:02:00.0.nffw: không tìm thấy
    nfp: netronome/nic_AMDA0081-0001_1x40.nffw: đã tìm thấy, đang tải...

Trong trường hợp này nếu tệp (hoặc liên kết) có tên ZZ0002ZZ
hoặc ZZ0003ZZ có mặt trong ZZ0000ZZ này
tập tin chương trình cơ sở sẽ được ưu tiên hơn các tập tin ZZ0001ZZ.

Lưu ý rằng các tệp ZZ0000ZZ và ZZ0001ZZ được tự động đưa vào ZZ0002ZZ
trong initramfs, bạn sẽ phải tham khảo tài liệu về các công cụ thích hợp
để tìm hiểu làm thế nào để bao gồm chúng.

Phiên bản phần mềm đang chạy
------------------------

Phiên bản phần sụn được tải cho giao diện <netdev> cụ thể,
(ví dụ: enp4s0) hoặc cổng <netdev port> của giao diện (ví dụ: enp4s0np0) có thể
được hiển thị bằng lệnh ethtool ::

$ ethtool -i <netdev>

Chính sách tải chương trình cơ sở
-----------------------

Chính sách tải firmware được kiểm soát thông qua ba tham số HWinfo
được lưu trữ dưới dạng cặp giá trị khóa trong flash của thiết bị:

app_fw_from_flash
    Xác định phần sụn nào sẽ được ưu tiên, 'Disk' (0), 'Flash' (1) hoặc
    chương trình cơ sở 'Ưu tiên' (2). Khi chọn 'Ưu tiên', việc quản lý
    phần sụn đưa ra quyết định phần sụn nào sẽ được tải bằng cách so sánh
    phiên bản của chương trình cơ sở flash và chương trình cơ sở do máy chủ cung cấp.
    Biến này có thể định cấu hình bằng cách sử dụng 'fw_load_policy'
    tham số liên kết nhà phát triển.

abi_drv_reset
    Xác định xem trình điều khiển có nên thiết lập lại chương trình cơ sở hay không khi
    trình điều khiển đã được thăm dò, 'Disk' (0) nếu tìm thấy chương trình cơ sở trên đĩa,
    Đặt lại 'Luôn luôn' (1) hoặc đặt lại 'Không bao giờ' (2). Lưu ý rằng thiết bị luôn
    đặt lại khi dỡ bỏ trình điều khiển nếu chương trình cơ sở được tải khi trình điều khiển được thăm dò.
    Biến này có thể được định cấu hình bằng cách sử dụng 'reset_dev_on_drv_probe'
    tham số liên kết nhà phát triển.

abi_drv_load_ifc
    Xác định danh sách các thiết bị PF được phép tải FW trên thiết bị.
    Biến này hiện không thể cấu hình được bởi người dùng.

Thông tin liên kết nhà phát triển
============

Lệnh devlink info hiển thị các phiên bản firmware đang chạy và lưu trữ
trên thiết bị, số serial và thông tin bo mạch.

Ví dụ về lệnh thông tin Devlink (thay thế địa chỉ PCI)::

$ devlink thông tin nhà phát triển pci/0000:03:00.0
    pci/0000:03:00.0:
      tài xế nfp
      số sê-ri CSAAMDA2001-1003000111
      phiên bản:
          đã sửa:
            board.id AMDA2001-1003
            board.rev 01
            board.sản xuất CSA
            board.model mozart
          đang chạy:
            fw.mgmt 22.10.0-rc3
            fw.cpld 0x1000003
            fw.app nic-22.09.0
            chip.init AMDA-2001-1003 1003000111
          được lưu trữ:
            fw.bundle_id bspbundle_1003000111
            fw.mgmt 22.10.0-rc3
            fw.cpld 0x0
            chip.init AMDA-2001-1003 1003000111

Định cấu hình thiết bị
================

Phần này giải thích cách sử dụng Agilio SmartNIC chạy chương trình cơ sở NIC cơ bản.

Cấu hình tốc độ liên kết giao diện
------------------------------
Các bước sau đây giải thích cách thay đổi giữa chế độ 10G và chế độ 25G trên
Thẻ Agilio CX 2x25GbE. Việc thay đổi tốc độ cổng phải được thực hiện theo thứ tự,
cổng 0 (p0) phải được đặt thành 10G trước khi cổng 1 (p1) có thể được đặt thành 10G.

Xuống (các) giao diện tương ứng::

$ ip link đặt dev <netdev port 0> down
  $ ip link set dev <netdev port 1> down

Đặt tốc độ liên kết giao diện thành 10G::

$ ethtool -s <netdev port 0> tốc độ 10000
  $ ethtool -s <netdev port 1> tốc độ 10000

Đặt tốc độ liên kết giao diện thành 25G::

$ ethtool -s <netdev port 0> tốc độ 25000
  $ ethtool -s <netdev port 1> tốc độ 25000

Tải lại trình điều khiển để các thay đổi có hiệu lực::

$ rmmod nfp; modprobe nfp

Cấu hình giao diện Đơn vị truyền tối đa (MTU)
---------------------------------------------------

Giao diện MTU có thể được thiết lập tạm thời bằng iproute2, ip link hoặc
công cụ ifconfig. Lưu ý rằng thay đổi này sẽ không tiếp tục. Thiết lập điều này thông qua
Trình quản lý mạng hoặc công cụ cấu hình hệ điều hành thích hợp khác là
được khuyến nghị vì có thể thực hiện các thay đổi đối với MTU bằng Trình quản lý mạng để
vẫn tồn tại.

Đặt giao diện MTU thành 9000 byte::

$ ip link set dev <netdev port > mtu 9000

Người dùng hoặc lớp điều phối có trách nhiệm thiết lập
giá trị MTU thích hợp khi xử lý các khung lớn hoặc sử dụng đường hầm. cho
Ví dụ: nếu các gói được gửi từ VM được đóng gói trên thẻ và
đi ra một cổng vật lý thì MTU của VF phải được đặt ở mức thấp hơn
của cổng vật lý để tính toán các byte bổ sung được thêm vào bởi
tiêu đề bổ sung. Nếu thiết lập dự kiến sẽ thấy lưu lượng truy cập dự phòng giữa
SmartNIC và kernel thì người dùng cũng phải đảm bảo rằng PF MTU
được thiết lập thích hợp để tránh những sự sụt giảm không mong muốn trên đường dẫn này.

Định cấu hình chế độ Sửa lỗi chuyển tiếp (FEC)
----------------------------------------------

Agilio SmartNIC hỗ trợ cấu hình chế độ FEC, ví dụ: Tự động, Firecode Base-R,
Chế độ ReedSolomon và Tắt. Có thể đặt chế độ FEC của mỗi cổng vật lý
độc lập sử dụng ethtool. Các chế độ FEC được hỗ trợ cho giao diện có thể
được xem bằng cách sử dụng::

$ ethtool <netdev>

Có thể xem chế độ FEC được cấu hình hiện tại bằng cách sử dụng ::

$ ethtool --show-fec <netdev>

Để buộc chế độ FEC cho một cổng cụ thể, phải tắt tính năng tự động đàm phán
(xem phần ZZ0000ZZ). Một ví dụ về cách đặt chế độ FEC
của Reed-Solomon là::

$ ethtool --set-fec <netdev> mã hóa rs

Tự động đàm phán
----------------

Để thay đổi cài đặt tự động đàm phán, trước tiên liên kết phải được đặt xuống. Sau khi
liên kết không hoạt động, bạn có thể bật hoặc tắt tính năng tự động đàm phán bằng cách sử dụng::

ethtool -s <netdev> autoneg <on|off>

Thống kê
==========

Số liệu thống kê thiết bị sau có sẵn thông qua giao diện ZZ0000ZZ:

.. flat-table:: NFP device statistics
   :header-rows: 1
   :widths: 3 1 11

   * - Name
     - ID
     - Meaning

   * - dev_rx_discards
     - 1
     - Packet can be discarded on the RX path for one of the following reasons:

        * The NIC is not in promisc mode, and the destination MAC address
          doesn't match the interfaces' MAC address.
        * The received packet is larger than the max buffer size on the host.
          I.e. it exceeds the Layer 3 MRU.
        * There is no freelist descriptor available on the host for the packet.
          It is likely that the NIC couldn't cache one in time.
        * A BPF program discarded the packet.
        * The datapath drop action was executed.
        * The MAC discarded the packet due to lack of ingress buffer space
          on the NIC.

   * - dev_rx_errors
     - 2
     - A packet can be counted (and dropped) as RX error for the following
       reasons:

       * A problem with the VEB lookup (only when SR-IOV is used).
       * A physical layer problem that causes Ethernet errors, like FCS or
         alignment errors. The cause is usually faulty cables or SFPs.

   * - dev_rx_bytes
     - 3
     - Total number of bytes received.

   * - dev_rx_uc_bytes
     - 4
     - Unicast bytes received.

   * - dev_rx_mc_bytes
     - 5
     - Multicast bytes received.

   * - dev_rx_bc_bytes
     - 6
     - Broadcast bytes received.

   * - dev_rx_pkts
     - 7
     - Total number of packets received.

   * - dev_rx_mc_pkts
     - 8
     - Multicast packets received.

   * - dev_rx_bc_pkts
     - 9
     - Broadcast packets received.

   * - dev_tx_discards
     - 10
     - A packet can be discarded in the TX direction if the MAC is
       being flow controlled and the NIC runs out of TX queue space.

   * - dev_tx_errors
     - 11
     - A packet can be counted as TX error (and dropped) for one for the
       following reasons:

       * The packet is an LSO segment, but the Layer 3 or Layer 4 offset
         could not be determined. Therefore LSO could not continue.
       * An invalid packet descriptor was received over PCIe.
       * The packet Layer 3 length exceeds the device MTU.
       * An error on the MAC/physical layer. Usually due to faulty cables or
         SFPs.
       * A CTM buffer could not be allocated.
       * The packet offset was incorrect and could not be fixed by the NIC.

   * - dev_tx_bytes
     - 12
     - Total number of bytes transmitted.

   * - dev_tx_uc_bytes
     - 13
     - Unicast bytes transmitted.

   * - dev_tx_mc_bytes
     - 14
     - Multicast bytes transmitted.

   * - dev_tx_bc_bytes
     - 15
     - Broadcast bytes transmitted.

   * - dev_tx_pkts
     - 16
     - Total number of packets transmitted.

   * - dev_tx_mc_pkts
     - 17
     - Multicast packets transmitted.

   * - dev_tx_bc_pkts
     - 18
     - Broadcast packets transmitted.

Lưu ý rằng số liệu thống kê mà người lái xe chưa biết sẽ được hiển thị dưới dạng
ZZ0000ZZ, trong đó ZZ0001ZZ đề cập đến cột thứ hai
ở trên.