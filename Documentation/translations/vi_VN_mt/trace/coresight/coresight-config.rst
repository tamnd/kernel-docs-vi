.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/trace/coresight/coresight-config.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================================
Trình quản lý cấu hình hệ thống CoreSight
=========================================

:Tác giả: Mike Leach <mike.leach@linaro.org>
    :Ngày: Tháng 10 năm 2020

Giới thiệu
============

Trình quản lý cấu hình hệ thống CoreSight là API cho phép
lập trình hệ thống CoreSight với các cấu hình được xác định trước
sau đó có thể dễ dàng kích hoạt từ sysfs hoặc perf.

Nhiều thành phần CoreSight có thể được lập trình theo những cách phức tạp - đặc biệt là ETM.
Ngoài ra, các thành phần có thể tương tác trên toàn hệ thống CoreSight, thường thông qua
các thành phần kích hoạt chéo như CTI và CTM. Các cài đặt hệ thống này có thể
được xác định và kích hoạt dưới dạng cấu hình được đặt tên.


Khái niệm cơ bản
==============

Phần này giới thiệu các khái niệm cơ bản về cấu hình hệ thống CoreSight.


Đặc trưng
--------

Tính năng là một tập hợp lập trình được đặt tên cho thiết bị CoreSight. Lập trình
phụ thuộc vào thiết bị và có thể được xác định theo các giá trị thanh ghi tuyệt đối,
việc sử dụng tài nguyên và giá trị tham số.

Tính năng này được xác định bằng cách sử dụng một bộ mô tả. Bộ mô tả này được sử dụng để tải lên
một thiết bị phù hợp, khi tính năng này được tải vào hệ thống hoặc khi
Thiết bị CoreSight được đăng ký với trình quản lý cấu hình.

Quá trình tải bao gồm việc diễn giải bộ mô tả thành một tập hợp các thanh ghi
truy cập trong trình điều khiển - việc sử dụng tài nguyên và mô tả tham số
được dịch sang các truy cập đăng ký thích hợp. Cách hiểu này làm cho nó dễ dàng
và hiệu quả để tính năng này được lập trình trên thiết bị khi được yêu cầu.

Tính năng này sẽ không hoạt động trên thiết bị cho đến khi tính năng này được bật và
bản thân thiết bị đã được kích hoạt. Khi thiết bị được kích hoạt thì các tính năng được kích hoạt
sẽ được lập trình vào phần cứng của thiết bị.

Một tính năng được kích hoạt như một phần của cấu hình được kích hoạt trên hệ thống.


Giá trị tham số
~~~~~~~~~~~~~~~

Giá trị tham số là giá trị được đặt tên có thể được người dùng đặt trước
tính năng đang được kích hoạt có thể điều chỉnh hành vi của hoạt động được lập trình
bởi tính năng.

Ví dụ: đây có thể là giá trị đếm trong thao tác được lập trình lặp lại
ở một tỷ lệ nhất định. Khi tính năng này được bật thì giá trị hiện tại của
tham số được sử dụng trong việc lập trình thiết bị.

Bộ mô tả tính năng xác định giá trị mặc định cho tham số, được sử dụng
nếu người dùng không cung cấp giá trị mới.

Người dùng có thể cập nhật các giá trị tham số bằng configfs API cho CoreSight
hệ thống - được mô tả dưới đây.

Giá trị hiện tại của tham số được tải vào thiết bị khi tính năng
được kích hoạt trên thiết bị đó.


Cấu hình
--------------

Cấu hình xác định một tập hợp các tính năng sẽ được sử dụng trong dấu vết
phiên nơi cấu hình được chọn. Đối với bất kỳ phiên theo dõi nào chỉ có một
cấu hình có thể được lựa chọn

Các tính năng được xác định có thể có trên bất kỳ loại thiết bị nào được đăng ký
để hỗ trợ cấu hình hệ thống. Một cấu hình có thể chọn các tính năng được
được bật trên một loại thiết bị - tức là mọi ETMv4 hoặc các thiết bị cụ thể, ví dụ: một
CTI cụ thể trên hệ thống.

Giống như đối tượng địa lý, bộ mô tả được sử dụng để xác định cấu hình.
Điều này sẽ xác định các tính năng phải được kích hoạt như một phần của cấu hình
cũng như mọi giá trị đặt trước có thể được sử dụng để ghi đè tham số mặc định
các giá trị.


Giá trị đặt trước
~~~~~~~~~~~~~

Các giá trị đặt trước là các bộ giá trị tham số có thể lựa chọn dễ dàng cho các tính năng
mà cấu hình sử dụng. Số lượng giá trị trong một bộ đặt trước, bằng
tổng giá trị tham số trong các tính năng được cấu hình sử dụng.

ví dụ. một cấu hình bao gồm 3 tính năng, một có 2 tham số, một có
một tham số duy nhất và tham số khác không có tham số. Một bộ cài sẵn duy nhất sẽ
do đó có 3 giá trị.

Các cài đặt trước được xác định tùy chọn theo cấu hình, có thể xác định tối đa 15.
Nếu không có cài đặt trước nào được chọn thì các giá trị tham số được xác định trong tính năng
đều được sử dụng bình thường.


Hoạt động
~~~~~~~~~

Các bước sau đây diễn ra trong hoạt động của một cấu hình.

1) Trong ví dụ này, cấu hình là 'autofdo', có
   tính năng liên quan 'nhấp nháy' hoạt động trên Thiết bị ETMv4 CoreSight.

2) Cấu hình được kích hoạt. Ví dụ: 'perf' có thể chọn
   cấu hình như một phần của dòng lệnh của nó ::

bản ghi hoàn hảo -e cs_etm/autofdo/ myapp

sẽ kích hoạt cấu hình 'autofdo'.

3) sự hoàn hảo bắt đầu theo dõi trên hệ thống. Vì mỗi ETMv4 mà perf sử dụng cho
   theo dõi được bật, trình quản lý cấu hình sẽ kiểm tra xem ETMv4 có
   có một tính năng liên quan đến cấu hình hiện đang hoạt động.
   Trong trường hợp này, 'nhấp nháy' được bật và lập trình vào ETMv4.

4) Khi ETMv4 bị vô hiệu hóa, mọi thanh ghi được đánh dấu là cần phải được
   đã lưu sẽ được đọc lại.

5) Vào cuối phiên hoàn thiện, cấu hình sẽ bị tắt.


Xem cấu hình và tính năng
===================================

Tập hợp các cấu hình và tính năng hiện được tải vào
hệ thống có thể được xem bằng configfs API.

Gắn configfs như bình thường và hệ thống con 'cs-syscfg' sẽ xuất hiện ::

$ ls /cấu hình
    chính sách stp cs-syscfg

Thư mục này có hai thư mục con::

$ cd cs-syscfg/
    $ ls
    tính năng cấu hình

Hệ thống có cấu hình 'autofdo' được tích hợp sẵn. Nó có thể được xem là
sau::

cấu hình $ cd/
    $ ls
    tự động làm
    $ cd autofdo/
    $ ls
    mô tả tính năng_refs cài đặt trước1 cài đặt trước3 cài đặt trước5 cài đặt trước7 cài đặt trước9
    bật cài đặt trước cài sẵn2 cài đặt sẵn4 cài đặt sẵn6 cài đặt trước8
    $ mô tả con mèo
    Thiết lập ETM bằng cách nhấp nháy cho autofdo
    $ tính năng mèo_refs
    vuốt ve

Mỗi giá trị đặt trước được khai báo đều có thư mục con 'preset<n>' được khai báo. Các giá trị cho
cài đặt trước có thể được kiểm tra::

$ cat cài sẵn1/giá trị
    nhấp nháy.window = 0x1388 nhấp nháy.thời gian = 0x2
    $ cat cài sẵn2/giá trị
    nhấp nháy.window = 0x1388 nhấp nháy.thời gian = 0x4

Các tệp 'bật' và 'đặt trước' cho phép kiểm soát cấu hình khi
sử dụng CoreSight với sysfs.

Các tính năng được tham chiếu bởi cấu hình có thể được kiểm tra trong các tính năng
thư mục::

$ cd ../../features/strobing/
    $ ls
    mô tả khớp với thông số nr_params
    $ mô tả con mèo
    Tạo các cửa sổ chụp dấu vết định kỳ.
    tham số 'cửa sổ': một số chu kỳ CPU (W)
    tham số 'giai đoạn': bật theo dõi cho chu kỳ W mỗi chu kỳ x chu kỳ W
    $ trận đấu mèo
    SRC_ETMV4
    $ mèo nr_params
    2

Di chuyển tới thư mục params để kiểm tra và điều chỉnh thông số::

thông số cd
    $ ls
    cửa sổ thời kỳ
    $ cd kỳ
    $ ls
    giá trị
    giá trị $ con mèo
    0x2710
    # echo 15000 > giá trị
    Giá trị # cat
    0x3a98

Các tham số được điều chỉnh theo cách này được phản ánh trong tất cả các phiên bản thiết bị có
đã tải tính năng này.


Sử dụng Cấu hình trong Perf
============================

Các cấu hình được tải vào quản lý cấu hình CoreSight là
cũng được khai báo trong cơ sở hạ tầng sự kiện perf 'cs_etm' để họ có thể
được chọn khi chạy dấu vết trong perf::

$ ls /sys/thiết bị/cs_etm
    sự kiện cpu0 cpu2 nr_addr_filters sự kiện hệ thống con nguồn
    định dạng cpu1 cpu3 perf_event_mux_interval_ms loại chìm

Thư mục chính ở đây là 'sự kiện' - một thư mục hoàn hảo chung cho phép
lựa chọn trên dòng lệnh perf. Giống như các mục chìm, điều này cung cấp
một hàm băm của tên cấu hình.

Mục nhập trong thư mục 'sự kiện' sử dụng các perfs được tích hợp sẵn trong trình tạo cú pháp
để thay thế cú pháp cho tên khi đánh giá lệnh::

$ ls sự kiện/
    tự động làm
    $ sự kiện mèo/autofdo
    configid=0xa7c3dddd

Cấu hình 'autofdo' có thể được chọn trên dòng lệnh perf ::

$ bản ghi hoàn hảo -e cs_etm/autofdo/u --per-thread <application>

Cũng có thể chọn cài đặt trước để ghi đè các giá trị tham số hiện tại::

$ bản ghi hoàn hảo -e cs_etm/autofdo,preset=1/u --per-thread <application>

Khi các cấu hình được chọn theo cách này thì bộ theo dõi được sử dụng sẽ là
được chọn tự động.

Sử dụng Cấu hình trong sysfs
=============================

Coresight có thể được kiểm soát bằng sysfs. Khi cái này được sử dụng thì một cấu hình
có thể được kích hoạt cho các thiết bị được sử dụng trong phiên sysfs.

Trong cấu hình có các tệp 'bật' và 'đặt trước'.

Để kích hoạt cấu hình để sử dụng với sysfs::

cấu hình $ cd/autofdo
    $ echo 1 > bật

Sau đó, điều này sẽ sử dụng bất kỳ giá trị tham số mặc định nào trong các tính năng - có thể
được điều chỉnh như mô tả ở trên.

Để sử dụng bộ giá trị tham số cài sẵn<n>::

$ echo 3 > đặt trước

Điều này sẽ chọn cài đặt trước3 cho cấu hình.
Các giá trị hợp lệ cho giá trị đặt trước là 0 - để bỏ chọn giá trị đặt trước và bất kỳ giá trị nào của
<n> nơi có thư mục con<n> cài sẵn.

Lưu ý rằng cấu hình sysfs đang hoạt động là tham số chung, do đó
chỉ một cấu hình duy nhất có thể hoạt động cho sysfs bất kỳ lúc nào.
Cố gắng kích hoạt cấu hình thứ hai sẽ dẫn đến lỗi.
Ngoài ra, việc cố gắng vô hiệu hóa cấu hình trong khi đang sử dụng sẽ
cũng gây ra lỗi.

Việc sử dụng cấu hình hoạt động của sysfs độc lập với cấu hình
được sử dụng trong sự hoàn hảo.


Tạo và tải cấu hình tùy chỉnh
==========================================

Các cấu hình và/hoặc tính năng tùy chỉnh có thể được tải động vào
hệ thống bằng cách sử dụng một mô-đun có thể tải được.

Ví dụ về cấu hình tùy chỉnh được tìm thấy trong ./samples/coresight.

Điều này tạo ra một cấu hình mới sử dụng cấu hình sẵn có
tính năng nhấp nháy, nhưng cung cấp một bộ cài đặt trước khác.

Khi mô-đun được tải, cấu hình sẽ xuất hiện trong configfs
hệ thống tập tin và có thể lựa chọn theo cách tương tự như cấu hình tích hợp
được mô tả ở trên.

Cấu hình có thể sử dụng các tính năng được tải trước đó. Hệ thống sẽ đảm bảo
rằng không thể dỡ bỏ một tính năng hiện đang được sử dụng, bằng cách
thực thi lệnh dỡ hàng trái ngược hoàn toàn với lệnh xếp hàng.