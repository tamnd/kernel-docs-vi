.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/trace/coresight/coresight.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================================================
Coresight - Truy tìm phần cứng được hỗ trợ trên ARM
===================================================

:Tác giả: Mathieu Poirier <mathieu.poirier@linaro.org>
   :Ngày: 11 tháng 9 năm 2014

Giới thiệu
------------

Coresight là một tập hợp các công nghệ cho phép gỡ lỗi ARM
dựa trên SoC.  Nó bao gồm các giải pháp truy tìm được hỗ trợ bởi JTAG và CTNH.  Cái này
tài liệu liên quan đến cái sau.

Việc truy tìm được hỗ trợ CTNH ngày càng trở nên hữu ích khi xử lý các hệ thống
có nhiều SoC và các thành phần khác như động cơ GPU và DMA.  ARM có
đã phát triển giải pháp truy tìm CTNH được hỗ trợ bằng các thành phần khác nhau, mỗi thành phần
được thêm vào thiết kế tại thời điểm tổng hợp để phục vụ cho các nhu cầu truy tìm cụ thể.
Các thành phần thường được phân loại thành nguồn, liên kết và phần chìm và được
(thường) được phát hiện bằng bus AMBA.

"Nguồn" tạo ra một luồng nén thể hiện lệnh của bộ xử lý
đường dẫn dựa trên các kịch bản theo dõi do người dùng định cấu hình.  Từ đó dòng suối
chảy qua hệ thống coresight (thông qua bus ATB) bằng các liên kết được kết nối
nguồn phát tới (các) bồn rửa.  Bồn rửa đóng vai trò là điểm cuối của coresight
thực hiện, hoặc lưu trữ luồng nén trong bộ nhớ đệm hoặc
tạo ra một giao diện với thế giới bên ngoài nơi dữ liệu có thể được truyền tới một
máy chủ mà không sợ lấp đầy bộ nhớ đệm coresight trên bo mạch.

Ở hệ thống coresight điển hình sẽ trông như thế này::

*******************************************************************
 *************************ZZ0004ZZ***************************===||
  ******************************************************************* ||
        ^ ^ ZZ0008ZZ|
        ZZ0009ZZ * **
     0000000 ::::: 0000000 ::::: ::::: @@@@@@@ ||||||||||||
     0 CPU 0<-->: C : 0 CPU 0<-->: C : : C : @ STM @ |ZZ0010ZZ|
  ZZ0011ZZ->0000000 : T : : T :<--->@@@@@ |ZZ0012ZZ|
  ZZ0013ZZ #######<-->: Tôi : : Tôi : @@@<-ZZ0014ZZ|||||||||||
  ZZ0015ZZ # ZZ0062ZZ # ::::: ::::: @ |
  ZZ0016ZZ ##### ^ !      ^ !        .   ZZ0017ZZ||||||||
  ZZ0018ZZ->###       ZZ0066ZZ ZZ0020ZZ !      ZZ0021ZZ |ZZ0022ZZ|
  ZZ0023ZZ #        ZZ0071ZZ ZZ0025ZZ!      ZZ0026ZZ |||||||||
  ZZ0027ZZ.        ZZ0028ZZ ZZ0029ZZ!      ZZ0030ZZ ZZ0031ZZ
  ZZ0032ZZ.        ZZ0033ZZ ZZ0034ZZ!      ZZ0035ZZ |  *
  ZZ0036ZZ.        ZZ0037ZZ ZZ0038ZZ!      ZZ0039ZZ | SWD/
  ZZ0040ZZ.        ZZ0041ZZ ZZ0042ZZ!      ZZ0043ZZ | JTAG
  **********************************************************************<-|
 *************************ZZ0005ZZ******************
  *******************************************************************
   ZZ0044ZZ
   ZZ0045ZZ
  *******************************************************************
 *****************ZZ0006ZZ***************
  *******************************************************************
   ZZ0046ZZ
   ZZ0047ZZ
  *******************************************************************
 ****************ZZ0007ZZ***************
  *******************************************************************
   ZZ0048ZZ
   ZZ0049ZZ
   |   ::::::::: ==== U ====
   |-->:: CTI ::<!!                       === N ===
   |   ::::::::: !                        == N ==
   |    ^ * == E ==
   |    !  &&&&&&&&& IIIIIII == L ==
   |------>&& ETB &&<......II I =======
   |    !  &&&&&&&& II I .
   |    !                    tôi tôi .
   |    !                    Tôi REP tôi<............
   |    !                    tôi tôi
   |    !!>&&&&&&&& II I *Nguồn: ARM ltd.
   |------>& TPIU &<......II I DAP = Cổng truy cập gỡ lỗi
           &&&&&&&& IIIIIII ETM = Macrocell theo dõi được nhúng
               ;                              PTM = Chương trình theo dõi Macrocell
               ;                              CTI = Giao diện kích hoạt chéo
               * ETB = Bộ đệm dấu vết nhúng
          Để theo dõi cổng TPIU= Đơn vị giao diện cổng theo dõi
                                              SWD = Gỡ lỗi dây nối tiếp

Trong khi cấu hình mục tiêu của các thành phần được thực hiện thông qua bus APB,
tất cả dữ liệu theo dõi được thực hiện ngoài băng tần trên bus ATB.  CTM cung cấp
một cách để tổng hợp và phân phối tín hiệu giữa các thành phần CoreSight.

Khung coresight cung cấp một điểm trung tâm để trình bày, cấu hình và
quản lý các thiết bị coresight trên một nền tảng.  Việc triển khai đầu tiên này tập trung vào
chức năng theo dõi cơ bản, cho phép các thành phần như ETM/PTM, phễu,
bộ sao chép, TMC, TPIU và ETB.  Công việc trong tương lai sẽ cho phép nhiều hơn
các khối IP phức tạp như STM và CTI.


Từ viết tắt và phân loại
---------------------------

Từ viết tắt:

PTM:
    Chương trình Trace Macrocell
ETM:
    Macrocell theo dõi nhúng
STM:
    Dấu vết hệ thống Macrocell
ETB:
    Bộ đệm dấu vết nhúng
ITM:
    Thiết bị theo dõi Macrocell
TPIU:
     Đơn vị giao diện cổng theo dõi
TMC-ETR:
        Bộ điều khiển bộ nhớ theo dõi, được định cấu hình là Bộ định tuyến theo dõi nhúng
TMC-ETF:
        Bộ điều khiển bộ nhớ theo dõi, được định cấu hình là Dấu vết nhúng FIFO
CTI:
    Giao diện kích hoạt chéo

Phân loại:

Nguồn:
   ETMv3.x ETMv4, PTMv1.0, PTMv1.1, STM, STM500, ITM
Liên kết:
   Phễu, bộ sao chép (thông minh hoặc không), TMC-ETR
Bồn rửa:
   ETBv1.0, ETB1.1, TPIU, TMC-ETF
Linh tinh:
   CTI


Ràng buộc cây thiết bị
----------------------

Xem ZZ0000ZZ để biết chi tiết.

Tại thời điểm viết bài này, trình điều khiển dành cho ITM, STM và CTI không được cung cấp nhưng được cung cấp
dự kiến ​​sẽ được thêm vào khi giải pháp hoàn thiện.


Khung và thực hiện
----------------------------

Khung coresight cung cấp một điểm trung tâm để trình bày, cấu hình và
quản lý các thiết bị coresight trên một nền tảng.  Bất kỳ thiết bị tuân thủ coresight nào cũng có thể
đăng ký với khung miễn là họ sử dụng đúng API:

.. c:function:: struct coresight_device *coresight_register(struct coresight_desc *desc);
.. c:function:: void coresight_unregister(struct coresight_device *csdev);

Chức năng đăng ký đang lấy ZZ0000ZZ và
đăng ký thiết bị với khung lõi. Chức năng hủy đăng ký mất
tham chiếu đến ZZ0001ZZ có được tại thời điểm đăng ký.

Nếu mọi việc suôn sẻ trong quá trình đăng ký, các thiết bị mới sẽ
hiển thị trong /sys/bus/coresight/devices, như được hiển thị ở đây cho nền tảng TC2 ::

root:~# ls /sys/bus/coresight/devices/
    bộ sao chép 20030000.tpiu 2201c000.ptm 2203c000.etm 2203e000.etm
    20010000.etb 20040000.funnel 2201d000.ptm 2203d000.etm
    gốc:~#

Các hàm lấy ZZ0000ZZ, trông như thế này::

cấu trúc coresight_desc {
            loại enum coresight_dev_type;
            struct coresight_dev_subtype kiểu con;
            const struct coresight_ops *ops;
            cấu trúc coresight_platform_data *pdata;
            thiết bị cấu trúc *dev;
            const struct attribute_group **groups;
    };


"coresight_dev_type" xác định thiết bị là gì, tức là liên kết nguồn hoặc
chìm trong khi "coresight_dev_subtype" sẽ mô tả rõ hơn loại đó.

ZZ0000ZZ là bắt buộc và sẽ cho khung biết cách
thực hiện các thao tác cơ bản liên quan đến các thành phần, mỗi thành phần có
một tập hợp các yêu cầu khác nhau. Đối với ZZ0001ZZ đó,
ZZ0002ZZ và ZZ0003ZZ đã được
được cung cấp.

Trường tiếp theo ZZ0000ZZ được lấy bằng cách gọi
ZZ0001ZZ, như một phần của quy trình thăm dò của người lái xe và
ZZ0002ZZ lấy tham chiếu thiết bị được nhúng trong ZZ0003ZZ::

int tĩnh etm_probe(struct amba_device *adev, const struct amba_id *id)
    {
     ...
     ...
drvdata->dev = &adev->dev;
     ...
    }

Loại thiết bị cụ thể (nguồn, liên kết hoặc phần chìm) có các hoạt động chung
có thể được thực hiện trên chúng (xem ZZ0000ZZ). ZZ0001ZZ
là danh sách các mục sysfs liên quan đến hoạt động
chỉ dành riêng cho thành phần đó.  Các tùy chỉnh "xác định triển khai" là
dự kiến sẽ được truy cập và kiểm soát bằng cách sử dụng các mục đó.

Sơ đồ đặt tên thiết bị
----------------------

Các thiết bị xuất hiện trên xe buýt "coresight" được đặt tên giống như của chúng
thiết bị gốc, tức là các thiết bị thực xuất hiện trên bus AMBA hoặc bus nền tảng.
Do đó, các tên được dựa trên quy ước đặt tên lớp Phần sụn mở của Linux,
theo sau địa chỉ vật lý cơ sở của thiết bị, theo sau là thiết bị
loại. ví dụ::

root:~# ls /sys/bus/coresight/devices/
     20010000.etf 20040000.funnel 20100000.stm 22040000.etm
     22140000.etm 230c0000.funnel 23240000.etm 20030000.tpiu
     20070000.etr 20120000.replicator 220c0000.funnel
     23040000.etm 23140000.etm 23340000.etm

Tuy nhiên, với sự ra đời của hỗ trợ ACPI, tên thật của
các thiết bị hơi khó hiểu và không rõ ràng. Vì vậy, một kế hoạch đặt tên mới đã được
được giới thiệu để sử dụng tên chung hơn dựa trên loại thiết bị. các
áp dụng các quy tắc sau::

1) Các thiết bị được liên kết với CPU, được đặt tên dựa trên logic CPU
     số.

ví dụ: ETM liên kết với CPU0 được đặt tên là "etm0"

2) Tất cả các thiết bị khác đều tuân theo mẫu "<device_type_prefix>N", trong đó:

<device_type_prefix> - Tiền tố dành riêng cho loại thiết bị
	N - số thứ tự được gán dựa trên thứ tự
				  của việc thăm dò.

ví dụ: tmc_etf0, tmc_etr0, phễu0, phễu1

Do đó, với sơ đồ mới, các thiết bị có thể xuất hiện dưới dạng ::

root:~# ls /sys/bus/coresight/devices/
     etm0 etm1 etm2 etm3 etm4 etm5 phễu0
     phễu1 bộ sao chép phễu20 stm0 tmc_etf0 tmc_etr0 tpiu0

Một số ví dụ dưới đây có thể đề cập đến sơ đồ đặt tên cũ và một số
sang sơ đồ mới hơn, để xác nhận rằng những gì bạn nhìn thấy trên
hệ thống không có gì bất ngờ. Người ta phải sử dụng những “tên” như chúng xuất hiện trên
hệ thống ở những vị trí xác định.

Biểu diễn cấu trúc liên kết
---------------------------

Mỗi thành phần CoreSight có một thư mục ZZ0000ZZ sẽ chứa
liên kết đến các thành phần CoreSight khác. Điều này cho phép người dùng khám phá dấu vết
cấu trúc liên kết và đối với các hệ thống lớn hơn, hãy xác định phần chìm thích hợp nhất cho
nguồn đã cho. Thông tin kết nối cũng có thể được sử dụng để thiết lập
thiết bị CTI nào được kết nối với một thành phần nhất định. Thư mục này chứa một
Thuộc tính ZZ0001ZZ chi tiết số lượng liên kết trong thư mục.

Đối với nguồn ETM, trong trường hợp này là ZZ0000ZZ trên nền tảng Juno, một điển hình
sự sắp xếp sẽ là::

nhà phát triển linaro:~# ls - l /sys/bus/coresight/devices/etm0/connections
  <chi tiết tệp> cti_cpu0 -> ../../../23020000.cti/cti_cpu0
  <chi tiết tập tin> nr_links
  <chi tiết tệp> out:0 -> ../../../230c0000.funnel/funnel2

Theo cổng out tới ZZ0000ZZ::

nhà phát triển linaro:~# ls -l /sys/bus/coresight/devices/funnel2/connections
  <chi tiết tệp> trong:0 -> ../../../23040000.etm/etm0
  <chi tiết tệp> trong:1 -> ../../../23140000.etm/etm3
  <chi tiết tệp> trong:2 -> ../../../23240000.etm/etm4
  <chi tiết tệp> trong:3 -> ../../../23340000.etm/etm5
  <chi tiết tập tin> nr_links
  <chi tiết tệp> out:0 -> ../../../20040000.funnel/funnel0

Và một lần nữa tới ZZ0000ZZ::

nhà phát triển linaro:~# ls -l /sys/bus/coresight/devices/funnel0/connections
  <chi tiết tệp> trong:0 -> ../../../220c0000.funnel/funnel1
  <chi tiết tệp> trong:1 -> ../../../230c0000.funnel/funnel2
  <chi tiết tập tin> nr_links
  <chi tiết tệp> out:0 -> ../../../20010000.etf/tmc_etf0

Tìm chiếc bồn rửa đầu tiên ZZ0000ZZ. Điều này có thể được sử dụng để thu thập dữ liệu
như một phần chìm hoặc như một liên kết để truyền bá thêm dọc theo chuỗi ::

nhà phát triển linaro:~# ls -l /sys/bus/coresight/devices/tmc_etf0/connections
  <chi tiết tệp> cti_sys0 -> ../../../20020000.cti/cti_sys0
  <chi tiết tệp> trong:0 -> ../../../20040000.funnel/funnel0
  <chi tiết tập tin> nr_links
  <chi tiết tệp> out:0 -> ../../../20150000.funnel/funnel4

thông qua ZZ0000ZZ::

nhà phát triển linaro:~# ls -l /sys/bus/coresight/devices/funnel4/connections
  <chi tiết tệp> trong:0 -> ../../../20010000.etf/tmc_etf0
  <chi tiết tệp> trong:1 -> ../../../20140000.etf/tmc_etf1
  <chi tiết tập tin> nr_links
  <chi tiết tệp> out:0 -> ../../../20120000.replicator/replicator0

và ZZ0000ZZ::

nhà phát triển linaro:~# ls -l /sys/bus/coresight/devices/replicator0/connections
  <chi tiết tệp> trong:0 -> ../../../20150000.funnel/funnel4
  <chi tiết tập tin> nr_links
  <chi tiết tệp> out:0 -> ../../../20030000.tpiu/tpiu0
  <chi tiết tệp> out:1 -> ../../../20070000.etr/tmc_etr0

Đến điểm chìm cuối cùng trong chuỗi, ZZ0000ZZ::

nhà phát triển linaro:~# ls -l /sys/bus/coresight/devices/tmc_etr0/connections
  <chi tiết tệp> cti_sys0 -> ../../../20020000.cti/cti_sys0
  <chi tiết tệp> trong:0 -> ../../../20120000.replicator/replicator0
  <chi tiết tập tin> nr_links

Như được mô tả bên dưới, khi sử dụng sysfs, chỉ cần kích hoạt một sink và
một nguồn để theo dõi thành công. Khung này sẽ kích hoạt chính xác tất cả
liên kết trung gian theo yêu cầu.

Lưu ý: ZZ0000ZZ xuất hiện trong hai danh sách kết nối ở trên.
CTI có thể kết nối với nhiều thiết bị và được sắp xếp theo cấu trúc liên kết hình sao
thông qua CTM. Xem (Tài liệu/trace/coresight/coresight-ect.rst)
[#fourth]_ để biết thêm chi tiết.
Nhìn vào thiết bị này chúng ta thấy có 4 kết nối::

nhà phát triển linaro:~# ls -l /sys/bus/coresight/devices/cti_sys0/connections
  <chi tiết tập tin> nr_links
  <chi tiết tệp> stm0 -> ../../../20100000.stm/stm0
  <chi tiết tệp> tmc_etf0 -> ../../../20010000.etf/tmc_etf0
  <chi tiết tệp> tmc_etr0 -> ../../../20070000.etr/tmc_etr0
  <chi tiết tệp> tpiu0 -> ../../../20030000.tpiu/tpiu0


Cách sử dụng mô-đun theo dõi
-----------------------------

Có hai cách để sử dụng khung Coresight:

1. sử dụng các công cụ dòng cmd hoàn hảo.
2. tương tác trực tiếp với các thiết bị Coresight bằng giao diện sysFS.

Ưu tiên cho cái trước là sử dụng giao diện sysFS
đòi hỏi sự hiểu biết sâu sắc về Coresight HW.  Các phần sau
cung cấp chi tiết về cách sử dụng cả hai phương pháp.

Sử dụng giao diện sysFS
~~~~~~~~~~~~~~~~~~~~~~~~~

Trước khi có thể bắt đầu thu thập dấu vết, cần phải xác định được bồn chứa coresight.
Không có giới hạn về số lượng sink (cũng như nguồn) có thể được kích hoạt tại
bất kỳ thời điểm nào.  Là một hoạt động chung, tất cả các thiết bị liên quan đến bồn rửa
lớp sẽ có mục "hoạt động" trong sysfs::

root:/sys/bus/coresight/devices# ls
    bộ sao chép 20030000.tpiu 2201c000.ptm 2203c000.etm 2203e000.etm
    20010000.etb 20040000.funnel 2201d000.ptm 2203d000.etm
    root:/sys/bus/coresight/devices# ls 20010000.etb
    trạng thái Enable_sink trigger_cntr
    root:/sys/bus/coresight/devices# echo 1 > 20010000.etb/enable_sink
    root:/sys/bus/coresight/devices# cat 20010000.etb/enable_sink
    1
    root:/sys/bus/coresight/devices#

Khi khởi động, trình điều khiển etm3x hiện tại sẽ định cấu hình địa chỉ đầu tiên
bộ so sánh với "_stext" và "_etext", về cơ bản là truy tìm bất kỳ hướng dẫn nào
nằm trong phạm vi đó.  Vì vậy, việc "kích hoạt" một nguồn sẽ ngay lập tức
kích hoạt chụp dấu vết::

root:/sys/bus/coresight/devices# echo 1 > 2201c000.ptm/enable_source
    root:/sys/bus/coresight/devices# cat 2201c000.ptm/enable_source
    1
    root:/sys/bus/coresight/devices# cat 20010000.etb/status
    Độ sâu: 0x2000
    Trạng thái: 0x1
    RAM đọc ptr: 0x0
    RAM wrt ptr: 0x19d3 <------ Con trỏ ghi đang di chuyển
    Cnt kích hoạt: 0x0
    Kiểm soát: 0x1
    Trạng thái xả: 0x0
    Xóa ctrl: 0x2001
    root:/sys/bus/coresight/devices#

Việc thu thập dấu vết bị dừng theo cách tương tự::

root:/sys/bus/coresight/devices# echo 0 > 2201c000.ptm/enable_source
    root:/sys/bus/coresight/devices#

Nội dung của bộ đệm ETB có thể được lấy trực tiếp từ /dev::

root:/sys/bus/coresight/devices# dd if=/dev/20010000.etb \
    của=~/cstrace.bin
    64+0 bản ghi trong
    64+0 bản ghi đã hết
    Đã sao chép 32768 byte (33 kB), 0,00125258 giây, 26,2 MB/s
    root:/sys/bus/coresight/devices#

Tệp cstrace.bin có thể được giải nén bằng "ptm2human", DS-5 hoặc Trace32.

Sau đây là đầu ra DS-5 của một vòng lặp thử nghiệm tăng một biến lên
đến một giá trị nhất định.  Ví dụ này đơn giản nhưng cung cấp một cái nhìn thoáng qua về
vô số khả năng mà coresight mang lại.
:::::::::::::::::::::::::::::::::::::

Đã bật tính năng Theo dõi thông tin
    Hướng dẫn 106378866 0x8026B53C E52DE004 sai PUSH {lr}
    Hướng dẫn 0 0x8026B540 E24DD00C sai SUB sp,sp,#0xc
    Hướng dẫn 0 0x8026B544 E3A03000 sai MOV r3,#0
    Hướng dẫn 0 0x8026B548 E58D3004 sai STR r3,[sp,#4]
    Hướng dẫn 0 0x8026B54C E59D3004 sai LDR r3,[sp,#4]
    Hướng dẫn 0 0x8026B550 E3530004 sai CMP r3,#4
    Hướng dẫn 0 0x8026B554 E2833001 sai ADD r3,r3,#1
    Hướng dẫn 0 0x8026B558 E58D3004 sai STR r3,[sp,#4]
    Hướng dẫn 0 0x8026B55C DAFFFFFA đúng BLE {pc}-0x10 ; 0x8026b54c
    Dấu thời gian Dấu thời gian: 17106715833
    Hướng dẫn 319 0x8026B54C E59D3004 sai LDR r3,[sp,#4]
    Hướng dẫn 0 0x8026B550 E3530004 sai CMP r3,#4
    Hướng dẫn 0 0x8026B554 E2833001 sai ADD r3,r3,#1
    Hướng dẫn 0 0x8026B558 E58D3004 sai STR r3,[sp,#4]
    Hướng dẫn 0 0x8026B55C DAFFFFFA đúng BLE {pc}-0x10 ; 0x8026b54c
    Hướng dẫn 9 0x8026B54C E59D3004 sai LDR r3,[sp,#4]
    Hướng dẫn 0 0x8026B550 E3530004 sai CMP r3,#4
    Hướng dẫn 0 0x8026B554 E2833001 sai ADD r3,r3,#1
    Hướng dẫn 0 0x8026B558 E58D3004 sai STR r3,[sp,#4]
    Lệnh 0 0x8026B55C DAFFFFFA true BLE {pc}-0x10 ; 0x8026b54c
    Hướng dẫn 7 0x8026B54C E59D3004 sai LDR r3,[sp,#4]
    Hướng dẫn 0 0x8026B550 E3530004 sai CMP r3,#4
    Hướng dẫn 0 0x8026B554 E2833001 sai ADD r3,r3,#1
    Hướng dẫn 0 0x8026B558 E58D3004 sai STR r3,[sp,#4]
    Hướng dẫn 0 0x8026B55C DAFFFFFA đúng BLE {pc}-0x10 ; 0x8026b54c
    Hướng dẫn 7 0x8026B54C E59D3004 sai LDR r3,[sp,#4]
    Hướng dẫn 0 0x8026B550 E3530004 sai CMP r3,#4
    Hướng dẫn 0 0x8026B554 E2833001 sai ADD r3,r3,#1
    Hướng dẫn 0 0x8026B558 E58D3004 sai STR r3,[sp,#4]
    Hướng dẫn 0 0x8026B55C DAFFFFFA đúng BLE {pc}-0x10 ; 0x8026b54c
    Hướng dẫn 10 0x8026B54C E59D3004 sai LDR r3,[sp,#4]
    Hướng dẫn 0 0x8026B550 E3530004 sai CMP r3,#4
    Hướng dẫn 0 0x8026B554 E2833001 sai ADD r3,r3,#1
    Hướng dẫn 0 0x8026B558 E58D3004 sai STR r3,[sp,#4]
    Hướng dẫn 0 0x8026B55C DAFFFFFA đúng BLE {pc}-0x10 ; 0x8026b54c
    Hướng dẫn 6 0x8026B560 EE1D3F30 sai MRC p15,#0x0,r3,c13,c0,#1
    Hướng dẫn 0 0x8026B564 E1A0100D sai MOV r1,sp
    Hướng dẫn 0 0x8026B568 E3C12D7F sai BIC r2,r1,#0x1fc0
    Hướng dẫn 0 0x8026B56C E3C2203F sai BIC r2,r2,#0x3f
    Hướng dẫn 0 0x8026B570 E59D1004 sai LDR r1,[sp,#4]
    Hướng dẫn 0 0x8026B574 E59F0010 sai LDR r0,[pc,#16] ; [0x8026B58C] = 0x80550368
    Hướng dẫn 0 0x8026B578 E592200C sai LDR r2,[r2,#0xc]
    Hướng dẫn 0 0x8026B57C E59221D0 sai LDR r2,[r2,#0x1d0]
    Hướng dẫn 0 0x8026B580 EB07A4CF đúng BL {pc}+0x1e9344 ; 0x804548c4
    Đã bật tính năng Theo dõi thông tin
    Hướng dẫn 13570831 0x8026B584 E28DD00C sai ADD sp,sp,#0xc
    Hướng dẫn 0 0x8026B588 E8BD8000 true LDM sp!,{pc}
    Dấu thời gian Dấu thời gian: 17107041535

Sử dụng khung hoàn hảo
~~~~~~~~~~~~~~~~~~~~~~

Công cụ theo dõi Coresight được thể hiện bằng Hiệu suất của khung Perf
Sự trừu tượng của Đơn vị Giám sát (PMU).  Như vậy, khung hoàn hảo chịu trách nhiệm
kiểm soát thời điểm theo dõi được kích hoạt dựa trên thời điểm quá trình quan tâm được thực hiện
theo lịch trình.  Khi được cấu hình trong hệ thống, các PMU của Coresight sẽ được liệt kê khi
được truy vấn bởi công cụ dòng lệnh perf:

linaro@linaro-nano:~$ ./perf list pmu

Danh sách các sự kiện được xác định trước (được sử dụng trong -e):

cs_etm// [Sự kiện hạt nhân PMU]

Bất kể số lượng bộ theo dõi có sẵn trong một hệ thống (thường bằng
số lõi bộ xử lý), "cs_etm" PMU sẽ chỉ được liệt kê một lần.

Coresight PMU hoạt động giống như mọi PMU khác, tức là tên của PMU là
được cung cấp cùng với các tùy chọn cấu hình trong dấu gạch chéo lên '/' (xem
ZZ0000ZZ).

Sử dụng khung Perf nâng cao
-----------------------------

Lựa chọn bồn rửa
~~~~~~~~~~~~~~~~

Một bồn rửa thích hợp sẽ được chọn tự động để sử dụng với Perf, nhưng vì
thường sẽ có nhiều hơn một bồn rửa, tên của bồn rửa được sử dụng có thể là
được chỉ định làm tùy chọn cấu hình đặc biệt có tiền tố '@'.

Các bồn rửa có sẵn được liệt kê trong sysFS bên dưới
($SYSFS)/bus/event_source/devices/cs_etm/sinks/::

root@localhost:/sys/bus/event_source/devices/cs_etm/sinks# ls
	tmc_etf0 tmc_etr0 tpiu0

root@linaro-nano:~# perf record -e cs_etm/@tmc_etr0/u --per-thread chương trình

Thông tin thêm về ví dụ trên và ví dụ khác về cách sử dụng Coresight với
các công cụ hoàn hảo có thể được tìm thấy trong tệp "HOWTO.md" của openCSD gitHub
kho lưu trữ [#third]_.

Phân tích AutoFDO bằng các công cụ hoàn hảo
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

perf có thể được sử dụng để ghi lại và phân tích dấu vết của chương trình.

Việc thực thi có thể được ghi lại bằng cách sử dụng 'bản ghi hoàn hảo' với sự kiện cs_etm,
chỉ định tên của bồn rửa để ghi vào, ví dụ::

bản ghi hoàn hảo -e cs_etm//u --per-thread

Lệnh 'perf report' và 'perf script' có thể được sử dụng để phân tích việc thực thi,
tổng hợp lệnh và các sự kiện nhánh từ dấu vết lệnh.
'Tiêm hoàn hảo' có thể được sử dụng để thay thế dữ liệu theo dõi bằng các sự kiện tổng hợp.
Tùy chọn --itrace kiểm soát loại và tần suất của các sự kiện tổng hợp
(xem tài liệu hoàn hảo).

Lưu ý rằng hiện chỉ hỗ trợ các chương trình 64-bit - công việc tiếp theo là
cần thiết để hỗ trợ giải mã lệnh của chương trình Arm 32 bit.

Truy tìm PID
~~~~~~~~~~~~

Hạt nhân có thể được xây dựng để ghi giá trị PID vào các thanh ghi PE ContextID.
Đối với kernel chạy ở EL1, PID được lưu trữ trong CONTEXTIDR_EL1.  Một PE có thể
triển khai Tiện ích mở rộng máy chủ ảo hóa Arm (VHE), mà kernel có thể
chạy ở EL2 với tư cách là máy chủ ảo hóa; trong trường hợp này, giá trị PID được lưu trữ trong
CONTEXTIDR_EL2.

perf cung cấp các định dạng PMU lập trình cho ETM để chèn các giá trị này vào
dữ liệu theo dõi; các định dạng PMU được định nghĩa như sau:

"contextid1": Có sẵn trên cả kernel EL1 và kernel EL2.  Khi
                kernel đang chạy ở EL1, "contextid1" kích hoạt PID
                truy tìm; khi kernel đang chạy ở EL2, điều này cho phép
                truy tìm PID của các ứng dụng khách.

"contextid2": Chỉ sử dụng được khi kernel đang chạy ở EL2.  Khi nào
                đã chọn, cho phép theo dõi PID trên hạt nhân EL2.

"contextid": Sẽ là bí danh cho tùy chọn kích hoạt PID
                truy tìm.  tức là,
                contextid == contextid1, trên kernel EL1.
                contextid == contextid2, trên kernel EL2.

perf sẽ luôn kích hoạt tính năng theo dõi PID tại EL có liên quan, điều này được thực hiện bằng cách
tự động kích hoạt cấu hình "ngữ cảnh" - nhưng đối với EL2, có thể thực hiện
điều chỉnh cụ thể bằng cách sử dụng cấu hình "contextid1" và "contextid2", ví dụ: nếu một người dùng
muốn theo dõi PID cho cả máy chủ và khách, hai cấu hình "contextid1" và
"contextid2" có thể được đặt cùng lúc:

bản ghi hoàn hảo -e cs_etm/contextid1,contextid2/u -- vm


Tạo tệp bảo hiểm cho Tối ưu hóa theo hướng phản hồi: AutoFDO
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

'perf tiêm' chấp nhận tùy chọn --itrace trong trường hợp dữ liệu theo dõi được thực hiện
bị loại bỏ và thay thế bằng các sự kiện tổng hợp. ví dụ.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::

tiêm hoàn hảo --itrace --strip -i perf.data -o perf.data.new

Dưới đây là ví dụ về cách sử dụng ARM ETM cho autoFDO.  Nó yêu cầu autofdo
(ZZ0000ZZ và gcc phiên bản 5. Bong bóng
ví dụ sắp xếp là từ hướng dẫn AutoFDO (ZZ0001ZZ
:::::::::::::::::::::::::::::::::::::::::::::::

$ gcc-5 -O3 sắp xếp.c -o sắp xếp
	$ tasket -c 2 ./sort
	Mảng sắp xếp bong bóng gồm 30000 phần tử
	5910 mili giây

$ bản ghi hoàn hảo -e cs_etm//u --per-thread tasket -c 2 ./sort
	Mảng sắp xếp bong bóng gồm 30000 phần tử
	12543 mili giây
	[ bản ghi hoàn hảo: Thức dậy 35 lần để ghi dữ liệu ]
	[ bản ghi hoàn hảo: Đã chụp và ghi 69,640 MB perf.data ]

$ perf tiêm -i perf.data -o inj.data --itrace=il64 --strip
	$ create_gcov --binary=./sort --profile=inj.data --gcov=sort.gcov -gcov_version=1
	$ gcc-5 -O3 -fauto-profile=sort.gcov Sort.c -o Sort_autofdo
	$ tasket -c 2 ./sort_autofdo
	Mảng sắp xếp bong bóng gồm 30000 phần tử
	5806 mili giây

Định dạng tùy chọn cấu hình
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Các chuỗi sau có thể được cung cấp giữa // trên dòng lệnh perf để kích hoạt các tùy chọn khác nhau.
Chúng cũng được liệt kê trong thư mục /sys/bus/event_source/devices/cs_etm/format/

.. list-table::
   :header-rows: 1

   * - Option
     - Description
   * - branch_broadcast
     - Session local version of the system wide setting:
       :ref:`ETM_MODE_BB <coresight-branch-broadcast>`
   * - contextid
     - See `Tracing PID`_
   * - contextid1
     - See `Tracing PID`_
   * - contextid2
     - See `Tracing PID`_
   * - configid
     - Selection for a custom configuration. This is an implementation detail and not used directly,
       see :ref:`trace/coresight/coresight-config:Using Configurations in perf`
   * - preset
     - Override for parameters in a custom configuration, see
       :ref:`trace/coresight/coresight-config:Using Configurations in perf`
   * - sinkid
     - Hashed version of the string to select a sink, automatically set when using the @ notation.
       This is an internal implementation detail and is not used directly, see `Using perf
       framework`_.
   * - cycacc
     - Session local version of the system wide setting: :ref:`ETMv4_MODE_CYCACC
       <coresight-cycle-accurate>`
   * - retstack
     - Session local version of the system wide setting: :ref:`ETM_MODE_RETURNSTACK
       <coresight-return-stack>`
   * - timestamp
     - Controls generation and interval of timestamps.

       0 = off, 1 = minimum interval .. 15 = maximum interval.

       Values 1 - 14 use a counter that decrements every cycle to generate a
       timestamp on underflow. The reload value for the counter is 2 ^ (interval
       - 1). If the value is 1 then the reload value is 1, if the value is 11
       then the reload value is 1024 etc.

       Setting the maximum interval (15) will disable the counter generated
       timestamps, freeing the counter resource, leaving only ones emitted when
       a SYNC packet is generated. The sync interval is controlled with
       TRCSYNCPR.PERIOD which is every 4096 bytes of trace by default.

   * - cc_threshold
     - Cycle count threshold value. If nothing is provided here or the provided value is 0, then the
       default value i.e 0x100 will be used. If provided value is less than minimum cycles threshold
       value, as indicated via TRCIDR3.CCITMIN, then the minimum value will be used instead.

Cách sử dụng mô-đun STM
-------------------------

Việc sử dụng mô-đun System Trace Macrocell cũng giống như các công cụ theo dõi - cách duy nhất
sự khác biệt là khách hàng đang thực hiện việc thu thập dấu vết thay vì
hơn luồng chương trình thông qua mã.

Giống như bất kỳ thành phần CoreSight nào khác, thông tin cụ thể về bộ theo dõi STM có thể
được tìm thấy trong sysfs với nhiều thông tin hơn về mỗi mục được tìm thấy trong [#first]_::

root@genericarmv8:~# ls /sys/bus/coresight/devices/stm0
    sự kiện hệ thống con Enable_source hwevent_select port_enable
    hwevent_enable mgmt port_select traceid
    root@genericarmv8:~#

Giống như bất kỳ nguồn nào khác, bồn rửa cần được xác định và kích hoạt STM trước đó.
đang được sử dụng::

root@genericarmv8:~# echo 1 > /sys/bus/coresight/devices/tmc_etf0/enable_sink
    root@genericarmv8:~# echo 1 > /sys/bus/coresight/devices/stm0/enable_source

Từ đó các ứng dụng không gian người dùng có thể yêu cầu và sử dụng các kênh bằng cách sử dụng devfs
giao diện được cung cấp cho mục đích đó bởi STM API chung::

root@genericarmv8:~# ls -l /dev/stm0
    crw------- 1 gốc gốc 10, 61 Ngày 3 tháng 1 18:11 /dev/stm0
    root@genericarmv8:~#

Bạn có thể tìm thấy thông tin chi tiết về cách sử dụng STM API chung tại đây:
- Tài liệu/trace/stm.rst [#second]_.

Mô-đun CTI & CTM
---------------------

CTI (Giao diện kích hoạt chéo) cung cấp một bộ tín hiệu kích hoạt giữa
các CTI và thành phần riêng lẻ, đồng thời có thể truyền bá chúng giữa tất cả các CTI thông qua
các kênh trên CTM (Ma trận kích hoạt chéo).

Một tệp tài liệu riêng được cung cấp để giải thích việc sử dụng các thiết bị này.
(Tài liệu/trace/coresight/coresight-ect.rst) [#fourth]_.

Cấu hình hệ thống CoreSight
------------------------------

Các thành phần CoreSight có thể là những thiết bị phức tạp với nhiều tùy chọn lập trình.
Hơn nữa, các thành phần có thể được lập trình để tương tác với nhau trên toàn bộ hệ thống.
hệ thống hoàn chỉnh.

Trình quản lý Cấu hình Hệ thống CoreSight được cung cấp để cho phép các chương trình phức tạp này
các cấu hình được lựa chọn và sử dụng dễ dàng từ perf và sysfs.

Xem tài liệu riêng để biết thêm thông tin.
(Tài liệu/trace/coresight/coresight-config.rst) [#fifth]_.


.. [#first] Documentation/ABI/testing/sysfs-bus-coresight-devices-stm

.. [#second] Documentation/trace/stm.rst

.. [#third] https://github.com/Linaro/perf-opencsd

.. [#fourth] Documentation/trace/coresight/coresight-ect.rst

.. [#fifth] Documentation/trace/coresight/coresight-config.rst
