.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/amazon/ena.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================================================================
Trình điều khiển nhân Linux dành cho dòng Bộ điều hợp mạng đàn hồi (ENA)
============================================================

Tổng quan
========

ENA là giao diện mạng được thiết kế để tận dụng tốt CPU hiện đại
các tính năng và kiến trúc hệ thống.

Thiết bị ENA có giao diện quản lý nhẹ với
tập hợp tối thiểu các thanh ghi ánh xạ bộ nhớ và tập lệnh có thể mở rộng
thông qua Hàng đợi quản trị.

Trình điều khiển hỗ trợ nhiều loại thiết bị ENA, không phụ thuộc vào tốc độ liên kết
(tức là, trình điều khiển tương tự được sử dụng cho 10GbE, 25GbE, 40GbE, v.v.) và có
một bộ tính năng được đàm phán và mở rộng.

Một số thiết bị ENA hỗ trợ SR-IOV. Trình điều khiển này được sử dụng cho cả
SR-IOV Các thiết bị chức năng vật lý (PF) và chức năng ảo (VF).

Thiết bị ENA cho phép lưu lượng truy cập mạng tốc độ cao và chi phí thấp
xử lý bằng cách cung cấp nhiều cặp hàng đợi Tx/Rx (số lượng tối đa
được thiết bị quảng cáo thông qua Hàng đợi quản trị), MSI-X chuyên dụng
vectơ ngắt trên mỗi cặp hàng đợi Tx/Rx, kiểm duyệt ngắt thích ứng,
và vị trí dữ liệu được tối ưu hóa bộ đệm CPU.

Trình điều khiển ENA hỗ trợ các tính năng giảm tải TCP/IP tiêu chuẩn công nghiệp như
giảm tải tổng kiểm tra. Chia tỷ lệ bên nhận (RSS) được hỗ trợ cho đa lõi
nhân rộng.

Trình điều khiển ENA và các thiết bị tương ứng của nó triển khai sức khỏe
các cơ chế giám sát như cơ quan giám sát, cho phép thiết bị và trình điều khiển
để khôi phục một cách minh bạch đối với ứng dụng, cũng như
nhật ký gỡ lỗi.

Một số thiết bị ENA hỗ trợ chế độ làm việc có tên Độ trễ thấp
Hàng đợi (LLQ), giúp tiết kiệm thêm vài micro giây.

Cấu trúc thư mục mã nguồn ENA
===================================

=============================================================================
ena_com.[ch] Lớp giao tiếp quản lý. Lớp này là
                    chịu trách nhiệm quản lý toàn bộ hoạt động quản lý
                    (quản trị viên) giao tiếp giữa thiết bị và
                    người lái xe.
ena_eth_com.[ch] Đường dẫn dữ liệu Tx/Rx.
ena_admin_defs.h Định nghĩa giao diện quản lý ENA.
ena_eth_io_defs.h Định nghĩa giao diện đường dẫn dữ liệu ENA.
ena_common_defs.h Các định nghĩa phổ biến cho lớp ena_com.
ena_regs_defs.h Định nghĩa của các thanh ghi ENA PCI được ánh xạ bộ nhớ (MMIO).
ena_netdev.[ch] Trình điều khiển hạt nhân Linux chính.
lệnh gọi lại ena_ethtool.c ethtool.
ena_xdp.[ch] Các tệp XDP
ena_pci_id_tbl.h ID thiết bị được hỗ trợ.
ena_phc.[ch] Cơ sở hạ tầng đồng hồ phần cứng PTP (xem ZZ0000ZZ để biết thêm thông tin)
ena_devlink.[ch] tập tin liên kết phát triển.
ena_debugfs.[ch] tập tin debugfs.
=============================================================================

Giao diện quản lý:
=====================

Giao diện quản lý ENA được hiển thị bằng:

- Không gian cấu hình PCIe
- Đăng ký thiết bị
- Hàng đợi quản trị viên (AQ) và Hàng đợi hoàn thành của quản trị viên (ACQ)
- Hàng đợi thông báo sự kiện không đồng bộ (AENQ)

Thiết bị ENA Thanh ghi MMIO chỉ được truy cập trong quá trình điều khiển
khởi tạo và không được sử dụng trong quá trình thiết bị bình thường tiếp theo
hoạt động.

AQ được sử dụng để gửi các lệnh quản lý và
kết quả/phản hồi được báo cáo không đồng bộ thông qua ACQ.

ENA giới thiệu một tập hợp nhỏ các lệnh quản lý có chỗ cho
phần mở rộng dành riêng cho nhà cung cấp. Hầu hết các hoạt động quản lý đều
được đóng khung trong lệnh tính năng Nhận/Đặt chung.

Các lệnh hàng đợi quản trị viên sau được hỗ trợ:

- Tạo hàng đợi gửi I/O
- Tạo hàng đợi hoàn thành I/O
- Phá hủy hàng đợi đệ trình I/O
- Phá hủy hàng đợi hoàn thành I/O
- Nhận tính năng
- Đặt tính năng
- Cấu hình AENQ
- Nhận số liệu thống kê

Tham khảo ena_admin_defs.h để biết danh sách Tính năng Nhận/Đặt được hỗ trợ
tài sản.

Hàng đợi thông báo sự kiện không đồng bộ (AENQ) là hàng đợi một chiều
hàng đợi được thiết bị ENA sử dụng để gửi tới các sự kiện trình điều khiển không thể
được báo cáo bằng ACQ. Các sự kiện AENQ được chia thành các nhóm. Mỗi
nhóm có thể có nhiều hội chứng, như hình dưới đây

Các sự kiện là:

=====================================
Hội chứng nhóm
=====================================
Thay đổi trạng thái liên kết ZZ0000ZZ
Lỗi nghiêm trọng ZZ0001ZZ
Thông báo Đình chỉ giao thông
Thông báo Tiếp tục lưu lượng truy cập
Giữ-Alive ZZ0002ZZ
=====================================

ACQ và AENQ có chung vectơ MSI-X.

Keep-Alive là một cơ chế đặc biệt cho phép theo dõi tình trạng của thiết bị.
Sự kiện Keep-Alive được thiết bị phân phối mỗi giây.
Trình điều khiển duy trì một trình xử lý cơ quan giám sát (WD) để ghi lại trạng thái hiện tại và
số liệu thống kê. Nếu các sự kiện duy trì không được phân phối như mong đợi thì WD sẽ đặt lại
thiết bị và trình điều khiển.

Giao diện đường dẫn dữ liệu
===================

Các hoạt động I/O dựa trên Hàng đợi gửi Tx và Rx (Tx SQ và Rx
SQ tương ứng). Mỗi SQ có một hàng đợi hoàn thành (CQ) được liên kết
với nó.

Các SQ và CQ được triển khai dưới dạng các vòng mô tả trong các vùng liền kề nhau.
bộ nhớ vật lý.

Trình điều khiển ENA hỗ trợ hai chế độ Vận hành hàng đợi cho Tx SQ:

-ZZ0000ZZ
  Trong chế độ này, Tx SQ nằm trong bộ nhớ của máy chủ. ENA
  thiết bị tìm nạp bộ mô tả ENA Tx và dữ liệu gói từ máy chủ
  trí nhớ.

-ZZ0000ZZ
  Trong chế độ này trình điều khiển đẩy bộ mô tả truyền và
  96 byte đầu tiên của gói trực tiếp vào bộ nhớ thiết bị ENA
  không gian. Phần còn lại của tải trọng gói được tìm nạp bởi
  thiết bị. Đối với chế độ vận hành này, người lái sử dụng PCI chuyên dụng
  bộ nhớ thiết bị BAR, được ánh xạ với khả năng kết hợp ghi.

ZZ0000ZZ không phải tất cả các thiết bị ENA đều hỗ trợ LLQ và tính năng này đang được thương lượng
  với thiết bị khi khởi tạo. Nếu thiết bị ENA không
  hỗ trợ chế độ LLQ, trình điều khiển sẽ quay trở lại chế độ thông thường.

Rx SQ chỉ hỗ trợ chế độ thông thường.

Trình điều khiển hỗ trợ nhiều hàng đợi cho cả Tx và Rx. Điều này có nhiều
lợi ích:

- Giảm sự tranh chấp CPU/luồng/quy trình trên giao diện Ethernet nhất định.
- Giảm tỷ lệ bỏ lỡ bộ đệm khi hoàn thành, đặc biệt đối với dữ liệu
  các dòng bộ đệm chứa cấu trúc sk_buff.
- Tăng tính song song ở cấp độ quy trình khi xử lý các gói nhận được.
- Tăng tốc độ truy cập bộ đệm dữ liệu bằng cách điều khiển quá trình xử lý kernel của
  các gói đến CPU, nơi luồng ứng dụng tiêu thụ
  gói đang chạy.
- Trong phần cứng ngắt chuyển hướng.

Chế độ ngắt
===============

Trình điều khiển chỉ định một vectơ MSI-X cho mỗi cặp hàng đợi (cho cả Tx
và hướng Rx). Trình điều khiển gán một vectơ MSI-X chuyên dụng bổ sung
để quản lý (đối với ACQ và AENQ).

Đăng ký ngắt quản lý được thực hiện khi nhân Linux
thăm dò bộ chuyển đổi và nó sẽ bị hủy đăng ký khi bộ chuyển đổi được kết nối
bị loại bỏ. Đăng ký ngắt hàng đợi I/O được thực hiện khi Linux
giao diện của bộ điều hợp được mở và nó được hủy đăng ký khi
giao diện đã đóng.

Ngắt quản lý được đặt tên::

ena-mgmnt@pci:<Miền PCI:bus:slot.function>

và với mỗi cặp hàng đợi, một ngắt được đặt tên::

<tên giao diện>-Tx-Rx-<chỉ mục hàng đợi>

Thiết bị ENA hoạt động ở chế độ tự động che dấu và tự động xóa ngắt
chế độ. Nghĩa là, khi MSI-X được gửi đến máy chủ, bit Nguyên nhân của nó được
tự động bị xóa và ngắt được che dấu. Sự gián đoạn là
bị trình điều khiển vạch mặt sau khi quá trình xử lý NAPI hoàn tất.

Kiểm duyệt ngắt
====================

Trình điều khiển và thiết bị ENA có thể hoạt động ở chế độ ngắt thông thường hoặc ngắt thích ứng
chế độ điều độ.

ZZ0004ZZ trình điều khiển hướng dẫn thiết bị trì hoãn gián đoạn
đăng theo giá trị độ trễ ngắt tĩnh. Độ trễ gián đoạn
giá trị có thể được cấu hình thông qua ZZ0002ZZ. ZZ0003ZZ sau đây
các thông số được driver hỗ trợ: ZZ0000ZZ, ZZ0001ZZ

Chế độ điều tiết ZZ0000ZZ, giá trị độ trễ ngắt là
được trình điều khiển cập nhật một cách linh hoạt và điều chỉnh mỗi chu kỳ NAPI
theo tính chất giao thông.

Sự kết hợp thích ứng có thể được bật/tắt thông qua ZZ0001ZZ
Thông số ZZ0000ZZ.

Thông tin thêm về Kiểm duyệt ngắt thích ứng (DIM) có thể được tìm thấy trong
Tài liệu/mạng/net_dim.rst

.. _`RX copybreak`:

Bản sao RX
============

rx_copybreak được khởi tạo theo mặc định thành ENA_DEFAULT_RX_COPYBREAK
và có thể được cấu hình bằng lệnh ETHTOOL_STUNABLE của
SIOCETHTOOL ioctl.

Tùy chọn này kiểm soát độ dài gói tối đa mà RX
bộ mô tả mà nó được nhận sẽ được tái chế. Khi một gói nhỏ hơn
hơn số byte RX copybreak được nhận, nó sẽ được sao chép vào bộ nhớ mới
đệm và bộ mô tả RX được trả về HW.

.. _`PHC`:

Đồng hồ phần cứng PTP (PHC)
========================
.. _`ptp-userspace-api`: https://docs.kernel.org/driver-api/ptp.html#ptp-hardware-clock-user-space-api
.. _`testptp`: https://elixir.bootlin.com/linux/latest/source/tools/testing/selftests/ptp/testptp.c

Trình điều khiển ENA Linux hỗ trợ đồng hồ phần cứng PTP cung cấp tham chiếu dấu thời gian để đạt được độ phân giải nano giây.

ZZ0000ZZ

PHC phụ thuộc vào mô-đun PTP, mô-đun này cần được tải dưới dạng mô-đun hoặc được biên dịch vào kernel.

Xác minh xem có mô-đun PTP hay không:

.. code-block:: shell

  grep -w '^CONFIG_PTP_1588_CLOCK=[ym]' /boot/config-`uname -r`

- Nếu không có đầu ra nào được cung cấp, trình điều khiển ENA không thể tải được với sự hỗ trợ PHC.

ZZ0000ZZ

Tính năng này mặc định bị tắt, để bật tính năng này thì driver ENA
có thể được tải theo cách sau:

- liên kết nhà phát triển:

.. code-block:: shell

  sudo devlink dev param set pci/<domain:bus:slot.function> name enable_phc value true cmode driverinit
  sudo devlink dev reload pci/<domain:bus:slot.function>
  # for example:
  sudo devlink dev param set pci/0000:00:06.0 name enable_phc value true cmode driverinit
  sudo devlink dev reload pci/0000:00:06.0

Tất cả các nguồn đồng hồ PTP có sẵn có thể được theo dõi tại đây:

.. code-block:: shell

  ls /sys/class/ptp

Có thể xác minh khả năng và hỗ trợ của PHC bằng ethtool:

.. code-block:: shell

  ethtool -T <interface>

ZZ0000ZZ

Để truy xuất dấu thời gian PHC, hãy sử dụng ZZ0000ZZ, ví dụ sử dụng ZZ0001ZZ:

.. code-block:: shell

  testptp -d /dev/ptp$(ethtool -T <interface> | awk '/PTP Hardware Clock:/ {print $NF}') -k 1

PHC nhận được yêu cầu về thời gian phải nằm trong giới hạn hợp lý,
tránh sử dụng quá mức để đảm bảo hiệu suất và hiệu quả tối ưu.
Thiết bị ENA hạn chế tần suất yêu cầu thời gian nhận PHC ở mức tối đa
trong số 125 yêu cầu mỗi giây. Nếu vượt quá giới hạn này, yêu cầu thời gian nhận
sẽ thất bại, dẫn đến sự gia tăng trong thống kê phc_err_ts.

ZZ0000ZZ

PHC có thể được theo dõi bằng debugfs (nếu được gắn):

.. code-block:: shell

  sudo cat /sys/kernel/debug/<domain:bus:slot.function>/phc_stats

  # for example:
  sudo cat /sys/kernel/debug/0000:00:06.0/phc_stats

Lỗi PHC phải duy trì ở mức dưới 1% trong tổng số tất cả các yêu cầu PHC để duy trì mức độ chính xác và độ tin cậy mong muốn

=============================================================================
ZZ0000ZZ | Số dấu thời gian được truy xuất thành công (dưới thời gian chờ hết hạn).
ZZ0001ZZ | Số dấu thời gian được truy xuất đã hết hạn (trên thời gian chờ hết hạn).
ZZ0002ZZ | Số lần thử thời gian nhận bị bỏ qua (trong thời gian chặn).
ZZ0003ZZ | Số lần thử lấy thời gian không thành công do lỗi thiết bị (chuyển sang trạng thái chặn).
ZZ0004ZZ | Số lần thử lấy thời gian không thành công do lỗi dấu thời gian (chuyển sang trạng thái khối),
                    | Điều này xảy ra nếu trình điều khiển vượt quá giới hạn yêu cầu hoặc thiết bị nhận được dấu thời gian không hợp lệ.
=============================================================================

Thời gian chờ PHC:

=============================================================================
ZZ0000ZZ | Thời gian tối đa để truy xuất dấu thời gian hợp lệ, vượt qua ngưỡng này sẽ không thành công
                    | yêu cầu thời gian nhận và chặn các yêu cầu mới cho đến khi hết thời gian chờ.
ZZ0001ZZ | Thời gian chặn bắt đầu khi yêu cầu thời gian nhận hết hạn hoặc không thành công,
                    | tất cả các yêu cầu về thời gian nhận trong thời gian chặn sẽ bị bỏ qua.
=============================================================================

Thống kê
==========

Người dùng có thể lấy số liệu thống kê về trình điều khiển và thiết bị ENA bằng ZZ0000ZZ.
Người lái xe có thể thu thập số liệu thống kê thường xuyên hoặc mở rộng (bao gồm cả
số liệu thống kê mỗi hàng đợi) từ thiết bị.

Ngoài ra, trình điều khiển sẽ ghi số liệu thống kê vào nhật ký hệ thống khi thiết lập lại thiết bị.

Trên các loại phiên bản được hỗ trợ, số liệu thống kê cũng sẽ bao gồm
Dữ liệu ENA Express (các trường có tiền tố ZZ0000ZZ). Để hoàn thiện
tài liệu về dữ liệu ENA Express tham khảo
ZZ0001ZZ

MTU
===

Trình điều khiển hỗ trợ MTU lớn tùy ý với mức tối đa là
đàm phán với thiết bị. Trình điều khiển cấu hình MTU bằng cách sử dụng
Lệnh SetFeature (thuộc tính ENA_ADMIN_MTU). Người dùng có thể thay đổi MTU
thông qua ZZ0000ZZ và các công cụ kế thừa tương tự.

Giảm tải không quốc tịch
==================

Trình điều khiển ENA hỗ trợ:

- Giảm tải tổng kiểm tra tiêu đề IPv4
- TCP/UDP qua giảm tải tổng kiểm tra IPv4/IPv6

RSS
===

- Thiết bị ENA hỗ trợ RSS cho phép lưu lượng Rx linh hoạt
  lái.
- Hỗ trợ các hàm băm Toeplitz và CRC32.
- Có thể cấu hình các kết hợp khác nhau của các trường L2/L3/L4 thành
  đầu vào cho hàm băm.
- Trình điều khiển định cấu hình cài đặt RSS bằng lệnh AQ SetFeature
  (ENA_ADMIN_RSS_HASH_FUNCTION, ENA_ADMIN_RSS_HASH_INPUT và
  Thuộc tính ENA_ADMIN_RSS_INDIRECTION_TABLE_CONFIG).
- Nếu cờ NETIF_F_RXHASH được đặt, kết quả 32 bit của hàm băm
  chức năng được phân phối trong bộ mô tả Rx CQ được thiết lập trong gói nhận được
  SKB.
- Người dùng có thể cung cấp khóa băm, hàm băm và định cấu hình
  bảng hướng dẫn thông qua ZZ0000ZZ.

DEVLINK SUPPORT
===============
.. _`devlink`: https://www.kernel.org/doc/html/latest/networking/devlink/index.html

ZZ0000ZZ hỗ trợ tải lại driver và bắt đầu đàm phán lại với thiết bị ENA

.. code-block:: shell

  sudo devlink dev reload pci/<domain:bus:slot.function>
  # for example:
  sudo devlink dev reload pci/0000:00:06.0

DATA PATH
=========

Tx
--

ZZ0000ZZ được gọi bởi ngăn xếp. Chức năng này thực hiện như sau:

- Bộ đệm dữ liệu bản đồ (ZZ0001ZZ và các đoạn).
- Điền ZZ0002ZZ cho bộ đệm đẩy (nếu trình điều khiển và thiết bị
  ở chế độ đẩy).
- Chuẩn bị buf ENA cho các mảnh còn lại.
- Phân bổ ID yêu cầu mới từ vòng ZZ0003ZZ trống. yêu cầu
  ID là chỉ mục của gói trong thông tin Tx. Điều này được sử dụng cho
  các lần hoàn thành Tx không theo thứ tự.
- Thêm gói vào vị trí thích hợp trong vòng Tx.
- Gọi ZZ0000ZZ, lớp giao tiếp ENA chuyển đổi
  các bộ mô tả ZZ0004ZZ đến ENA (và thêm các bộ mô tả meta ENA như
  cần thiết).

* Chức năng này cũng sao chép bộ mô tả ENA và bộ đệm đẩy
    vào không gian bộ nhớ Thiết bị (nếu ở chế độ đẩy).

- Ghi chuông cửa vào thiết bị ENA.
- Khi thiết bị ENA gửi xong gói tin, quá trình hoàn tất
  ngắt được nâng lên.
- Bộ xử lý ngắt lập lịch trình NAPI.
- Hàm ZZ0000ZZ được gọi. Chức năng này xử lý các
  mô tả hoàn thành được tạo bởi ENA, với một
  mô tả hoàn thành cho mỗi gói hoàn thành.

* ZZ0000ZZ được lấy từ bộ mô tả hoàn thành. ZZ0001ZZ của
    gói được truy xuất thông qua ZZ0002ZZ. Bộ đệm dữ liệu được
    chưa được ánh xạ và ZZ0003ZZ được trả về vòng ZZ0004ZZ trống.
  * Chức năng dừng khi mô tả hoàn thành được hoàn thành hoặc
    ngân sách đã đạt được.

Rx
--

- Khi nhận được gói từ thiết bị ENA.
- Bộ xử lý ngắt lập lịch trình NAPI.
- Hàm ZZ0000ZZ được gọi. Hàm này gọi
  ZZ0001ZZ, một hàm lớp giao tiếp ENA, trả về
  số lượng bộ mô tả được sử dụng cho gói mới và bằng 0 nếu
  không có gói mới được tìm thấy.
- ZZ0002ZZ kiểm tra độ dài gói tin:

* Nếu gói nhỏ (len < rx_copybreak), trình điều khiển sẽ phân bổ
    SKB cho gói mới và sao chép tải trọng gói vào
    Bộ đệm dữ liệu SKB.

- Bằng cách này, bộ đệm dữ liệu gốc không được chuyển vào ngăn xếp
      và được tái sử dụng cho các gói Rx trong tương lai.

* Nếu không thì hàm này sẽ hủy ánh xạ bộ đệm Rx, thiết lập bộ đệm đầu tiên
    bộ mô tả là phần tuyến tính của ZZ0000ZZ và các bộ mô tả khác là phần
    Những mảnh vỡ của ZZ0001ZZ.

- SKB mới được cập nhật các thông tin cần thiết (giao thức,
  tổng kiểm tra hw xác minh kết quả, v.v.), sau đó được chuyển đến mạng
  ngăn xếp, sử dụng chức năng giao diện NAPI ZZ0000ZZ.

Bộ đệm RX động (DRB)
------------------------

Mỗi bộ mô tả RX trong vòng RX là một trang bộ nhớ duy nhất (có dung lượng 4KB).
hoặc dài 16KB tùy thuộc vào cấu hình của hệ thống).
Để giảm việc phân bổ bộ nhớ cần thiết khi xử lý tốc độ cao của các
các gói, trình điều khiển sẽ cố gắng sử dụng lại không gian của bộ mô tả RX còn lại nếu có thêm
hơn 2KB của trang này vẫn chưa được sử dụng.

Một ví dụ đơn giản về cơ chế này là chuỗi sự kiện sau:

::

1. Trình điều khiển phân bổ bộ đệm RX có kích thước trang và chuyển nó đến phần cứng
                +----------------------+
                ZZ0000ZZ
                +----------------------+

2. Nhận được gói 300Bytes trên bộ đệm này

3. Trình điều khiển tăng số lượng ref trên trang này và trả lại cho
           CTNH dưới dạng bộ đệm RX có kích thước 4KB - 300Bytes = 3796 Byte
               +----+---------+
               Bộ đệm RX byte ZZ0000ZZ3796 |
               +----+---------+

Cơ chế này không được sử dụng khi chương trình XDP được tải hoặc khi
Gói RX nhỏ hơn byte rx_copybreak (trong trường hợp đó gói được
được sao chép từ bộ đệm RX vào phần tuyến tính của skb mới được phân bổ
đối với nó và bộ đệm RX vẫn giữ nguyên kích thước, xem ZZ0000ZZ).