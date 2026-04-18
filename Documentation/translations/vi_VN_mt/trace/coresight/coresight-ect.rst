.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/trace/coresight/coresight-ect.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================================
Trình kích hoạt chéo nhúng CoreSight (CTI & CTM).
=================================================

:Tác giả: Mike Leach <mike.leach@linaro.org>
    : Ngày: Tháng 11 năm 2019

Mô tả phần cứng
--------------------

Giao diện kích hoạt chéo CoreSight (CTI) là một thiết bị phần cứng sử dụng
các tín hiệu phần cứng đầu vào và đầu ra riêng lẻ được gọi là bộ kích hoạt đến và đi
các thiết bị và kết nối chúng thông qua Ma trận kích hoạt chéo (CTM) với các thiết bị khác
thiết bị thông qua các kênh được đánh số để truyền bá các sự kiện giữa các thiết bị.

ví dụ.::

0000000 in_trigs :::::::
 0 C 0----------->: : +=======>(kênh CTI khác IO)
 0 P 0<-------------: :v
 0 U 0 out_trigs : : Kênh ***** :::::::
 0000000 : CTI :<==========>ZZ0000ZZ<====>: CTI :---+
 #######  in_trigs : : (id 0-3) ***** ::::::: v
 # ZZ0005ZZ #----------->: : ^ #######
 # #<-------------: : +---# ZZ0006ZZ #
 ####### out_trigs ::::::: #######

Trình điều khiển CTI cho phép lập trình CTI để gắn bộ kích hoạt vào
các kênh. Khi trình kích hoạt đầu vào hoạt động, kênh được đính kèm sẽ
trở nên năng động. Bất kỳ trình kích hoạt đầu ra nào được gắn vào kênh đó cũng sẽ
trở nên năng động. Kênh hoạt động được truyền tới các CTI khác thông qua CTM,
kích hoạt các trình kích hoạt đầu ra được kết nối ở đó, trừ khi được CTI lọc
cổng kênh.

Cũng có thể kích hoạt kênh trực tiếp bằng phần mềm hệ thống
các thanh ghi lập trình trong CTI.

CTI được hệ thống đăng ký để liên kết với CPU và/hoặc các thiết bị khác
Thiết bị CoreSight trên đường dẫn dữ liệu theo dõi. Khi các thiết bị này được kích hoạt,
CTI đính kèm cũng sẽ được kích hoạt. Theo mặc định/khi bật nguồn, CTI có
không có tệp đính kèm kích hoạt/kênh được lập trình, do đó sẽ không ảnh hưởng đến hệ thống
cho đến khi được lập trình rõ ràng.

Các kết nối kích hoạt phần cứng giữa CTI và thiết bị đang được triển khai
được xác định, trừ khi tổ hợp CPU/ETM là kiến trúc v8, trong trường hợp đó
các kết nối có bố cục tiêu chuẩn được xác định về mặt kiến trúc.

Các tín hiệu kích hoạt phần cứng cũng có thể được kết nối với các thiết bị không phải CoreSight
(ví dụ: UART) hoặc được truyền ra khỏi chip dưới dạng dòng IO phần cứng.

Tất cả các thiết bị CTI đều được liên kết với CTM. Trên nhiều hệ thống sẽ có một
CTM hiệu quả duy nhất (một CTM hoặc nhiều CTM đều được kết nối với nhau), nhưng nó
có thể các hệ thống có mạng CTI+CTM không được kết nối với nhau bằng
một CTM với nhau. Trên các hệ thống này, chỉ mục CTM được khai báo để liên kết
Các thiết bị CTI được kết nối với nhau thông qua CTM nhất định.

Các tập tin và thư mục Sysfs
---------------------------

Các thiết bị CTI xuất hiện trên bus CoreSight hiện có cùng với các thiết bị khác
Thiết bị CoreSight::

>$ ls /sys/bus/coresight/thiết bị
     cti_cpu0 cti_cpu2 cti_sys0 etm0 etm2 phễu0 bản sao0 tmc_etr0
     cti_cpu1 cti_cpu3 cti_sys1 etm1 etm3 phễu1 tmc_etf0 tpiu0

ZZ0000ZZ có tên CTI được liên kết với CPU và bất kỳ ETM nào được sử dụng bởi
cốt lõi đó. CTI ZZ0001ZZ là CTI cơ sở hạ tầng hệ thống chung
có thể được liên kết với các thiết bị CoreSight khác hoặc phần cứng hệ thống khác
có khả năng tạo hoặc sử dụng tín hiệu kích hoạt.::

>$ ls /sys/bus/coresight/devices/etm0/cti_cpu0
  kênh ctmid kích hoạt nr_trigger_cons mgmt cấp nguồn reg
  kết nối trình kích hoạt hệ thống con0 trình kích hoạt1 sự kiện

ZZ0005ZZ
   * ZZ0000ZZ: bật/tắt CTI. Đọc để xác định trạng thái hiện tại.
     Nếu điều này hiển thị là đã bật (1), nhưng ZZ0001ZZ hiển thị không được cấp nguồn (0), thì
     việc bật cho biết yêu cầu bật khi thiết bị được cấp nguồn.
   * ZZ0002ZZ : CTM được liên kết - chỉ phù hợp nếu hệ thống có nhiều CTI+CTM
     các cụm không được kết nối với nhau.
   * ZZ0003ZZ : tổng số kết nối - thư mục trigger<N>.
   * ZZ0004ZZ : Đọc để xác định xem CTI hiện có được cấp nguồn hay không.

ZZ0007ZZ
   * ZZ0000ZZ: chứa danh sách kích hoạt cho một kết nối riêng lẻ.
   * ZZ0001ZZ: Chứa giao diện lập trình chính của kênh API - CTI.
   * ZZ0002ZZ: Cung cấp quyền truy cập vào các quy định CTI có thể lập trình thô.
   * ZZ0003ZZ: thanh ghi quản lý CoreSight tiêu chuẩn.
   * ZZ0004ZZ: Liên kết tới các thiết bị ZZ0008ZZ được kết nối. Số lượng
     liên kết có thể từ 0 đến ZZ0005ZZ. Con số thực tế được đưa ra bởi ZZ0006ZZ
     trong thư mục này.


thư mục trigger<N>
~~~~~~~~~~~~~~~~~~~~~~~

Thông tin kết nối kích hoạt cá nhân. Điều này mô tả các tín hiệu kích hoạt cho
Kết nối CoreSight và không CoreSight.

Mỗi thư mục kích hoạt có một tập hợp các tham số mô tả các kích hoạt cho
sự kết nối.

* ZZ0000ZZ : tên kết nối
   * ZZ0001ZZ : các chỉ số tín hiệu kích hoạt đầu vào được sử dụng trong kết nối này.
   * ZZ0002ZZ : các loại chức năng cho tín hiệu in.
   * ZZ0003ZZ : tín hiệu kích hoạt đầu ra cho kết nối này.
   * ZZ0004ZZ : các loại chức năng cho tín hiệu out.

ví dụ::

>$ ls ./cti_cpu0/triggers0/
    in_signals in_types tên out_signals out_types
    >$ cat ./cti_cpu0/triggers0/name
    cpu0
    >$ cat ./cti_cpu0/triggers0/out_signals
    0-2
    >$ cat ./cti_cpu0/triggers0/out_types
    pe_edbgreq pe_dbgrestart pe_ctiirq
    >$ cat ./cti_cpu0/triggers0/in_signals
    0-1
    >$ cat ./cti_cpu0/triggers0/in_types
    pe_dbgkích hoạt pe_pmuirq

Nếu một kết nối không có tín hiệu trong trình kích hoạt 'vào' hoặc 'ra' thì
những thông số đó sẽ bị bỏ qua.

Thư mục kênh API
~~~~~~~~~~~~~~~~~~~~~~

Điều này cung cấp một cách dễ dàng để gắn trình kích hoạt vào các kênh mà không cần
nhiều hoạt động đăng ký được yêu cầu nếu thao tác
trực tiếp các phần tử thư mục con 'regs'.

Một số tệp cung cấp API này::

>$ ls ./cti_sys0/channels/
   chan_clear chan_inuse chan_xtrigs_out trigin_attach
   chan_free chan_pulse chan_xtrigs_reset trigin_detach
   chan_gate_disable chan_set chan_xtrigs_sel trigout_attach
   chan_gate_enable chan_xtrigs_in trig_filter_enable trigout_detach
   trigout_filtered

Hầu hết quyền truy cập vào các phần tử này có dạng::

echo <chan> [<trigger>] > /<device_path>/<opera>

trong đó <trigger> tùy chọn chỉ cần thiết cho trigXX_attach | tách ra
hoạt động.

ví dụ.::

>$ echo 0 1 > ./cti_sys0/channels/trigout_attach
   >$ echo 0 > ./cti_sys0/channels/chan_set

Gắn trigout(1) vào kênh(0), sau đó kích hoạt kênh(0) tạo ra
đặt trạng thái trên cti_sys0.trigout(1)


ZZ0000ZZ

* ZZ0000ZZ: Gắn kênh vào tín hiệu kích hoạt.
   * ZZ0001ZZ: Tách kênh khỏi tín hiệu kích hoạt.
   * ZZ0002ZZ: Đặt kênh - trạng thái đã đặt sẽ được truyền đi khắp nơi
     CTM với các thiết bị được kết nối khác.
   * ZZ0003ZZ: Xóa kênh.
   * ZZ0004ZZ: Đặt kênh cho một chu kỳ xung nhịp CoreSight.
   * ZZ0005ZZ: Thao tác ghi thiết lập cổng CTI để truyền bá
     (bật) kênh tới các thiết bị khác. Hoạt động này sử dụng một kênh
     số. Cổng CTI được bật cho tất cả các kênh theo mặc định khi bật nguồn. Đọc
     để liệt kê các kênh hiện đang được kích hoạt trên cổng.
   * ZZ0006ZZ: Ghi số kênh để tắt cổng cho điều đó
     kênh.
   * ZZ0007ZZ: Hiển thị các kênh hiện tại gắn liền với bất kỳ tín hiệu nào
   * ZZ0008ZZ: Hiển thị các kênh không có tín hiệu kèm theo.
   * ZZ0009ZZ: ghi số kênh để chọn kênh xem,
     đọc để hiển thị số kênh đã chọn.
   * ZZ0010ZZ: Đọc để hiển thị các trigger đầu vào được gắn vào
     kênh xem đã chọn.
   * ZZ0011ZZ:Đọc để hiển thị các kích hoạt đầu ra được gắn vào
     kênh xem đã chọn.
   * ZZ0012ZZ: Mặc định bật, tắt để cho phép
     tín hiệu đầu ra nguy hiểm được thiết lập.
   * ZZ0013ZZ: Kích hoạt các tín hiệu bị ngăn chặn
     được đặt nếu tính năng lọc ZZ0014ZZ được bật. Một công dụng là để ngăn ngừa
     tín hiệu ZZ0015ZZ tình cờ dừng lõi.
   * ZZ0016ZZ: Viết 1 để xóa tất cả các chương trình kênh/kích hoạt.
     Đặt lại phần cứng thiết bị về trạng thái mặc định.


Ví dụ bên dưới gắn chỉ số kích hoạt đầu vào 1 vào kênh 2 và đầu ra
kích hoạt chỉ số 6 vào cùng một kênh. Sau đó nó sẽ kiểm tra trạng thái của
kết nối kênh/kích hoạt bằng cách sử dụng các thuộc tính sysfs thích hợp.

Các cài đặt này có nghĩa là nếu kích hoạt đầu vào 1 hoặc kênh 2 hoạt động thì
trigger out 6 sẽ hoạt động. Sau đó chúng tôi kích hoạt CTI và sử dụng phần mềm
điều khiển kênh để kích hoạt kênh 2. Chúng tôi thấy kênh đang hoạt động trên
Thanh ghi ZZ0000ZZ và tín hiệu hoạt động trên ZZ0001ZZ
đăng ký. Cuối cùng việc xóa kênh sẽ loại bỏ điều này.

ví dụ.::

   .../cti_sys0/channels# echo 2 1 > trigin_attach
   .../cti_sys0/channels# echo 2 6 > trigout_attach
   .../cti_sys0/channels# cat chan_free
0-1,3
   .../cti_sys0/channels# cat chan_inuse
2
   .../cti_sys0/channels# echo 2 > chan_xtrigs_sel
   .../cti_sys0/channels# cat chan_xtrigs_trigin
1
   .../cti_sys0/channels# cat chan_xtrigs_trigout
6
   .../cti_sys0/# echo 1 > enable
   .../cti_sys0/channels# echo 2 > chan_set
   .../cti_sys0/channels# cat ../regs/choutstatus
0x4
   .../cti_sys0/channels# cat ../regs/trigoutstatus
0x40
   .../cti_sys0/channels# echo 2 > chan_clear
   .../cti_sys0/channels# cat ../regs/trigoutstatus
0x0
   .../cti_sys0/channels# cat ../regs/choutstatus
0x0