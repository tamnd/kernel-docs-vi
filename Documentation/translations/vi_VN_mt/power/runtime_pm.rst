.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/power/runtime_pm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================================
Khung quản lý năng lượng thời gian chạy cho thiết bị I/O
==================================================

(C) 2009-2011 Rafael J. Wysocki <rjw@sisk.pl>, Novell Inc.

(C) 2010 Alan Stern <stern@rowland.harvard.edu>

(C) Tập đoàn Intel 2014, Rafael J. Wysocki <rafael.j.wysocki@intel.com>

1. Giới thiệu
===============

Hỗ trợ quản lý năng lượng thời gian chạy (PM thời gian chạy) của thiết bị I/O được cung cấp
ở cấp độ lõi quản lý năng lượng (lõi PM) bằng cách:

* Hàng công việc quản lý nguồn pm_wq trong đó các loại xe buýt và trình điều khiển thiết bị có thể
  đặt các hạng mục công việc liên quan đến PM của họ.  Chúng tôi thực sự khuyên bạn nên sử dụng pm_wq
  được sử dụng để xếp hàng tất cả các mục công việc liên quan đến thời gian chạy PM, vì điều này cho phép
  chúng được đồng bộ hóa với các quá trình chuyển đổi nguồn trên toàn hệ thống (tạm dừng ở RAM,
  ngủ đông và tiếp tục từ trạng thái ngủ của hệ thống).  pm_wq được khai báo trong
  include/linux/pm_runtime.h và được xác định trong kernel/power/main.c.

* Một số trường PM thời gian chạy trong thành phần 'power' của 'struct device' (mà
  thuộc loại 'struct dev_pm_info', được định nghĩa trong include/linux/pm.h) có thể
  được sử dụng để đồng bộ hóa các hoạt động PM thời gian chạy với nhau.

* Ba lệnh gọi lại PM thời gian chạy thiết bị trong 'struct dev_pm_ops' (được xác định trong
  bao gồm/linux/pm.h).

* Một tập hợp các hàm trợ giúp được xác định trong driver/base/power/runtime.c có thể
  được sử dụng để thực hiện các hoạt động PM thời gian chạy theo cách mà
  việc đồng bộ hóa giữa chúng được đảm nhiệm bởi lõi PM.  Các loại xe buýt và
  trình điều khiển thiết bị được khuyến khích sử dụng các chức năng này.

Lệnh gọi lại PM thời gian chạy có trong 'struct dev_pm_ops', PM thời gian chạy thiết bị
các trường 'struct dev_pm_info' và các hàm trợ giúp cốt lõi được cung cấp cho
thời gian chạy PM được mô tả dưới đây.

2. Cuộc gọi lại PM trong thời gian chạy thiết bị
==============================

Có ba lệnh gọi lại PM thời gian chạy thiết bị được xác định trong 'struct dev_pm_ops'::

cấu trúc dev_pm_ops {
	...
int (*runtime_suspend)(struct device *dev);
	int (*runtime_resume)(struct device *dev);
	int (*runtime_idle)(struct device *dev);
	...
  };

Các lệnh gọi lại ->runtime_suspend(), ->runtime_resume() và ->runtime_idle()
được thực thi bởi lõi PM cho hệ thống con của thiết bị có thể là một trong hai
sau đây:

1. Miền PM của thiết bị, nếu đối tượng miền PM của thiết bị là dev->pm_domain,
     đang có mặt.

2. Loại thiết bị của thiết bị, nếu có cả dev->type và dev->type->pm.

3. Lớp thiết bị của thiết bị, nếu cả dev->class và dev->class->pm đều
     hiện tại.

4. Loại bus của thiết bị, nếu có cả dev->bus và dev->bus->pm.

Nếu hệ thống con được chọn bằng cách áp dụng các quy tắc trên không cung cấp thông tin liên quan
gọi lại, lõi PM sẽ gọi lệnh gọi lại trình điều khiển tương ứng được lưu trữ trong
dev->driver->pm trực tiếp (nếu có).

Lõi PM luôn kiểm tra xem nên sử dụng lệnh gọi lại nào theo thứ tự nêu trên, do đó
Thứ tự ưu tiên của các cuộc gọi lại từ cao đến thấp là: Tên miền PM, loại thiết bị, lớp
và loại xe buýt.  Hơn nữa, cái có mức độ ưu tiên cao sẽ luôn được ưu tiên hơn
một mức độ ưu tiên thấp.  Miền PM, loại bus, loại thiết bị và lệnh gọi lại lớp
được gọi là lệnh gọi lại cấp hệ thống con trong phần tiếp theo.

Theo mặc định, các lệnh gọi lại luôn được gọi trong ngữ cảnh tiến trình với các ngắt
đã bật.  Tuy nhiên, hàm trợ giúp pm_runtime_irq_safe() có thể được sử dụng để thông báo
lõi PM rằng việc chạy ->runtime_suspend(), ->runtime_resume() là an toàn
và ->runtime_idle() gọi lại cho thiết bị đã cho trong bối cảnh nguyên tử với
ngắt bị vô hiệu hóa.  Điều này ngụ ý rằng các thủ tục gọi lại được đề cập phải
không chặn hoặc ngủ, nhưng điều đó cũng có nghĩa là chức năng trợ giúp đồng bộ
được liệt kê ở cuối Phần 4 có thể được sử dụng cho thiết bị đó trong phạm vi ngắt
handler hoặc nói chung trong bối cảnh nguyên tử.

Lệnh gọi lại tạm dừng cấp hệ thống con, nếu có, là _hoàn toàn_ _có trách nhiệm_
để xử lý việc tạm dừng thiết bị một cách thích hợp, có thể, nhưng không cần thiết
bao gồm việc thực thi lệnh gọi lại ->runtime_suspend() của chính trình điều khiển thiết bị (từ
Quan điểm của PM core là không cần thiết phải triển khai ->runtime_suspend()
gọi lại trong trình điều khiển thiết bị miễn là lệnh gọi lại tạm dừng ở cấp hệ thống con
biết phải làm gì để xử lý thiết bị).

* Sau khi gọi lại tạm dừng ở cấp hệ thống con (hoặc trình điều khiển tạm dừng gọi lại,
    nếu được gọi trực tiếp) đã hoàn tất thành công cho thiết bị đã cho, PM
    core coi thiết bị là bị treo, điều này không có nghĩa là thiết bị đã bị treo.
    đưa vào trạng thái năng lượng thấp.  Tuy nhiên, nó được cho là có nghĩa là
    thiết bị sẽ không xử lý dữ liệu và sẽ không liên lạc với (các) CPU và
    RAM cho đến khi lệnh gọi lại tiếp tục thích hợp được thực thi cho nó.  Thời gian chạy
    Trạng thái PM của thiết bị sau khi thực hiện thành công cuộc gọi lại tạm dừng là
    'bị đình chỉ'.

* Nếu cuộc gọi lại tạm dừng trả về -EBUSY hoặc -EAGAIN, PM thời gian chạy của thiết bị
    trạng thái vẫn 'hoạt động', có nghĩa là thiết bị _phải_ được sạc đầy đủ
    hoạt động sau đó.

* Nếu cuộc gọi lại tạm dừng trả về mã lỗi khác với -EBUSY và
    -EAGAIN, lõi PM coi đây là lỗi nghiêm trọng và sẽ từ chối chạy
    các chức năng trợ giúp được mô tả trong Phần 4 cho thiết bị cho đến khi trạng thái của thiết bị
    được đặt trực tiếp thành 'hoạt động' hoặc 'bị treo' (lõi PM cung cấp
    chức năng trợ giúp đặc biệt cho mục đích này).

Đặc biệt, nếu trình điều khiển yêu cầu khả năng đánh thức từ xa (tức là phần cứng
cơ chế cho phép thiết bị yêu cầu thay đổi trạng thái nguồn, chẳng hạn như
PCI PME) để hoạt động bình thường và device_can_wakeup() trả về 'false' cho
thiết bị, thì ->runtime_suspend() sẽ trả về -EBUSY.  Mặt khác, nếu
device_can_wakeup() trả về 'true' cho thiết bị và thiết bị được đưa vào
trạng thái năng lượng thấp trong quá trình thực hiện cuộc gọi lại tạm dừng, dự kiến
tính năng đánh thức từ xa đó sẽ được kích hoạt cho thiết bị.  Nói chung, đánh thức từ xa
phải được bật cho tất cả các thiết bị đầu vào được đặt ở trạng thái năng lượng thấp trong thời gian chạy.

Lệnh gọi lại tiếp tục ở cấp hệ thống con, nếu có, là ZZ0000ZZ dành cho
xử lý sơ yếu lý lịch của thiết bị một cách thích hợp, có thể, nhưng không cần thiết
bao gồm việc thực thi lệnh gọi lại ->runtime_resume() của chính trình điều khiển thiết bị (từ
Quan điểm của PM core là không cần thiết phải triển khai ->runtime_resume()
gọi lại trong trình điều khiển thiết bị miễn là lệnh gọi lại tiếp tục ở cấp hệ thống con biết
phải làm gì để xử lý thiết bị).

* Khi hệ thống con tiếp tục gọi lại (hoặc trình điều khiển tiếp tục gọi lại, nếu
    được gọi trực tiếp) đã hoàn tất thành công, lõi PM sẽ liên quan đến thiết bị
    hoạt động đầy đủ, có nghĩa là thiết bị _phải_ có khả năng hoàn thành
    Các thao tác I/O khi cần thiết.  Khi đó trạng thái PM thời gian chạy của thiết bị là
    'hoạt động'.

* Nếu lệnh gọi lại tiếp tục trả về mã lỗi, lõi PM coi đây là một lỗi
    lỗi nghiêm trọng và sẽ từ chối chạy các chức năng trợ giúp được mô tả trong Phần
    4 cho thiết bị, cho đến khi trạng thái của thiết bị được đặt trực tiếp thành 'hoạt động' hoặc
    'bị treo' (bằng các chức năng trợ giúp đặc biệt được cung cấp bởi lõi PM
    cho mục đích này).

Cuộc gọi lại nhàn rỗi (một cấp độ hệ thống con, nếu có hoặc một trình điều khiển) là
được thực thi bởi lõi PM bất cứ khi nào thiết bị có vẻ không hoạt động, tức là
được biểu thị tới lõi PM bằng hai bộ đếm, bộ đếm mức sử dụng của thiết bị và
bộ đếm con 'hoạt động' của thiết bị.

* Nếu bất kỳ bộ đếm nào trong số này bị giảm bằng cách sử dụng chức năng trợ giúp do
    lõi PM và hóa ra nó bằng 0, bộ đếm còn lại là
    đã kiểm tra.  Nếu bộ đếm đó cũng bằng 0, lõi PM sẽ thực thi
    gọi lại nhàn rỗi với thiết bị làm đối số.

Hành động được thực hiện bởi lệnh gọi lại nhàn rỗi hoàn toàn phụ thuộc vào hệ thống con
(hoặc trình điều khiển) được đề cập, nhưng hành động dự kiến và được khuyến nghị là kiểm tra
liệu thiết bị có thể bị treo hay không (tức là nếu tất cả các điều kiện cần thiết để
việc tạm dừng thiết bị được thỏa mãn) và xếp hàng yêu cầu tạm dừng cho
thiết bị trong trường hợp đó.  Nếu không có lệnh gọi lại nhàn rỗi hoặc nếu lệnh gọi lại trả về
0 thì lõi PM sẽ cố gắng thực hiện tạm dừng thời gian chạy của thiết bị,
cũng tôn trọng các thiết bị được định cấu hình để tự động gửi.  Về bản chất điều này có nghĩa là một
gọi tới pm_runtime_autosuspend(). Để ngăn chặn điều này (ví dụ: nếu lệnh gọi lại
thường trình đã bắt đầu tạm dừng bị trì hoãn), thường trình đó phải trả về giá trị khác 0
giá trị.  Mã trả về lỗi âm bị lõi PM bỏ qua.

Các chức năng trợ giúp do lõi PM cung cấp, được mô tả trong Phần 4, đảm bảo
rằng các ràng buộc sau đây được đáp ứng đối với lệnh gọi lại PM thời gian chạy cho
một thiết bị:

(1) Các cuộc gọi lại loại trừ lẫn nhau (ví dụ: bị cấm thực thi
    ->runtime_suspend() song song với ->runtime_resume() hoặc với cái khác
    phiên bản ->runtime_suspend() cho cùng một thiết bị) ngoại trừ
    ->runtime_suspend() hoặc ->runtime_resume() có thể được thực thi song song với
    ->runtime_idle() (mặc dù ->runtime_idle() sẽ không được khởi động trong khi bất kỳ
    trong số các lệnh gọi lại khác đang được thực thi cho cùng một thiết bị).

(2) ->runtime_idle() và ->runtime_suspend() chỉ có thể được thực thi cho 'hoạt động'
    thiết bị (tức là lõi PM sẽ chỉ thực thi ->runtime_idle() hoặc
    ->runtime_suspend() đối với các thiết bị có trạng thái PM thời gian chạy là
    'hoạt động').

(3) ->runtime_idle() và ->runtime_suspend() chỉ có thể được thực thi cho một thiết bị
    bộ đếm sử dụng của nó bằng 0 _và_ hoặc bộ đếm của
    phần tử con 'hoạt động' bằng 0 hoặc 'power.ignore_children'
    cờ trong đó được thiết lập.

(4) ->runtime_resume() chỉ có thể được thực thi đối với các thiết bị 'bị treo' (tức là
    Lõi PM sẽ chỉ thực thi ->runtime_resume() cho các thiết bị trong thời gian chạy
    trạng thái PM là 'bị đình chỉ').

Ngoài ra, các chức năng trợ giúp do lõi PM cung cấp tuân theo các điều sau:
quy tắc:

* Nếu ->runtime_suspend() sắp được thực thi hoặc có yêu cầu đang chờ xử lý
    để thực thi nó, ->runtime_idle() sẽ không được thực thi cho cùng một thiết bị.

* Yêu cầu thực hiện hoặc lên lịch thực hiện ->runtime_suspend()
    sẽ hủy mọi yêu cầu đang chờ xử lý để thực thi ->runtime_idle() cho cùng một yêu cầu
    thiết bị.

* Nếu ->runtime_resume() sắp được thực thi hoặc có yêu cầu đang chờ xử lý
    để thực thi nó, các lệnh gọi lại khác sẽ không được thực thi cho cùng một thiết bị.

* Yêu cầu thực thi ->runtime_resume() sẽ hủy mọi yêu cầu đang chờ xử lý hoặc
    yêu cầu được lên lịch để thực hiện các lệnh gọi lại khác cho cùng một thiết bị,
    ngoại trừ việc tự động treo theo lịch trình.

3. Trường thiết bị PM thời gian chạy
===========================

Các trường PM thời gian chạy thiết bị sau đây có trong 'struct dev_pm_info', dưới dạng
được định nghĩa trong include/linux/pm.h:

ZZ0000ZZ
    - bộ đếm thời gian được sử dụng để lập lịch trình (bị trì hoãn) các yêu cầu tạm dừng và tự động tạm dừng

ZZ0000ZZ
    - thời gian hết hạn của bộ đếm thời gian, tính bằng giây lát (nếu giá trị này khác 0 thì
      bộ hẹn giờ đang chạy và sẽ hết hạn vào thời điểm đó, nếu không bộ hẹn giờ sẽ không hoạt động.
      đang chạy)

ZZ0000ZZ
    - cấu trúc công việc được sử dụng để xếp hàng các yêu cầu (tức là các mục công việc trong pm_wq)

ZZ0000ZZ
    - hàng chờ được sử dụng nếu bất kỳ chức năng trợ giúp nào cần đợi chức năng khác
      một để hoàn thành

ZZ0000ZZ
    - khóa được sử dụng để đồng bộ hóa

ZZ0000ZZ
    - bộ đếm sử dụng của thiết bị

ZZ0000ZZ
    - số lượng trẻ em 'hoạt động' của thiết bị

ZZ0000ZZ
    - nếu được đặt, giá trị của child_count sẽ bị bỏ qua (nhưng vẫn được cập nhật)

ZZ0000ZZ
    - được sử dụng để vô hiệu hóa các chức năng trợ giúp (chúng hoạt động bình thường nếu đây là
      bằng 0); giá trị ban đầu của nó là 1 (tức là thời gian chạy PM là
      ban đầu bị vô hiệu hóa đối với tất cả các thiết bị)

ZZ0000ZZ
    - nếu được đặt thì sẽ xảy ra lỗi nghiêm trọng (một trong các lệnh gọi lại trả về mã lỗi
      như được mô tả trong Phần 2), do đó các hàm trợ giúp sẽ không hoạt động cho đến khi
      cờ này bị xóa; đây là mã lỗi được trả về do lỗi
      gọi lại

ZZ0000ZZ
    - nếu được đặt, ->runtime_idle() đang được thực thi

ZZ0000ZZ
    - nếu được đặt, sẽ có một yêu cầu đang chờ xử lý (tức là một mục công việc được xếp hàng vào pm_wq)

ZZ0000ZZ
    - loại yêu cầu đang chờ xử lý (hợp lệ nếu request_pending được đặt)

ZZ0000ZZ
    - đặt nếu ->runtime_resume() sắp được chạy trong khi ->runtime_suspend() thì
      đang được thực thi cho thiết bị đó và việc chờ đợi
      tạm dừng để hoàn thành; có nghĩa là "bắt đầu sơ yếu lý lịch ngay khi bạn bị đình chỉ"

ZZ0000ZZ
    - trạng thái PM thời gian chạy của thiết bị; giá trị ban đầu của trường này là
      RPM_SUSPENDED, có nghĩa là mỗi thiết bị ban đầu được xem xét bởi
      Lõi PM bị 'treo', bất kể trạng thái phần cứng thực của nó

ZZ0000ZZ
    - trạng thái PM thời gian chạy cuối cùng của thiết bị được ghi lại trước khi tắt thời gian chạy
      PM cho nó (ban đầu không hợp lệ và khi vô hiệu hóa là 0)

ZZ0000ZZ
    - nếu được đặt, cho biết rằng không gian người dùng đã cho phép trình điều khiển thiết bị
      quản lý nguồn điện của thiết bị trong thời gian chạy thông qua /sys/devices/.../power/control
      ZZ0001ZZ nó chỉ có thể được sửa đổi với sự trợ giúp của
      Các hàm trợ giúp pm_runtime_allow() và pm_runtime_forbid()

ZZ0000ZZ
    - chỉ ra rằng thiết bị không sử dụng lệnh gọi lại PM thời gian chạy (xem
      Mục 8); nó chỉ có thể được sửa đổi bởi pm_runtime_no_callbacks()
      chức năng trợ giúp

ZZ0000ZZ
    - chỉ ra rằng lệnh gọi lại ->runtime_suspend() và ->runtime_resume()
      sẽ được gọi khi khóa spinlock được giữ và các ngắt bị vô hiệu hóa

ZZ0000ZZ
    - cho biết trình điều khiển của thiết bị hỗ trợ tính năng tự động treo bị trì hoãn (xem
      Mục 9); nó chỉ có thể được sửa đổi bởi
      Các hàm trợ giúp pm_runtime{_dont__use_autosuspend()

ZZ0000ZZ
    - chỉ ra rằng lõi PM sẽ cố gắng thực hiện quá trình tự động treo
      khi hết giờ thay vì tạm dừng thông thường

ZZ0000ZZ
    - thời gian trễ (tính bằng mili giây) được sử dụng để tự động treo

ZZ0000ZZ
    - thời gian (trong nháy mắt) khi trình trợ giúp pm_runtime_mark_last_busy()
      chức năng được gọi lần cuối cho thiết bị này; được sử dụng trong tính toán không hoạt động
      thời gian để tự động treo

Tất cả các trường trên đều là thành viên của thành viên 'power' của 'struct device'.

4. Chức năng trợ giúp thiết bị PM thời gian chạy
=====================================

Các hàm trợ giúp PM thời gian chạy sau đây được xác định trong
driver/base/power/runtime.c và bao gồm/linux/pm_runtime.h:

ZZ0000ZZ
    - khởi tạo các trường PM thời gian chạy thiết bị trong 'struct dev_pm_info'

ZZ0000ZZ
    - đảm bảo rằng PM thời gian chạy của thiết bị sẽ bị tắt sau
      xóa thiết bị khỏi hệ thống phân cấp thiết bị

ZZ0000ZZ
    - thực hiện cuộc gọi lại nhàn rỗi ở cấp hệ thống con cho thiết bị; trả về một
      mã lỗi về lỗi, trong đó -EINPROGRESS có nghĩa là ->runtime_idle() là
      đã được thực thi; nếu không có cuộc gọi lại hoặc cuộc gọi lại trả về 0
      sau đó chạy pm_runtime_autosuspend(dev) và trả về kết quả của nó

ZZ0000ZZ
    - thực hiện lệnh gọi lại tạm dừng cấp hệ thống con cho thiết bị; trả về 0 trên
      thành công, 1 nếu trạng thái PM thời gian chạy của thiết bị đã 'bị treo' hoặc
      mã lỗi khi thất bại, trong đó -EAGAIN hoặc -EBUSY có nghĩa là an toàn khi thử
      tạm dừng thiết bị một lần nữa trong tương lai và -EACCES có nghĩa là
      'power.disable_deep' khác 0

ZZ0000ZZ
    - giống như pm_runtime_suspend() ngoại trừ việc gọi tới
      pm_runtime_mark_last_busy() được tạo và tự động tạm dừng được lên lịch cho
      thời điểm thích hợp và 0 được trả về

ZZ0000ZZ
    - thực hiện gọi lại tiếp tục ở cấp hệ thống con cho thiết bị; trả về 0 trên
      thành công, 1 nếu trạng thái PM thời gian chạy của thiết bị đã 'hoạt động' (cũng như nếu
      'power.disable_deep' khác 0 nhưng trạng thái là 'hoạt động' khi nó
      thay đổi từ 0 thành 1) hoặc mã lỗi khi lỗi, trong đó -EAGAIN có nghĩa là có thể
      an toàn khi cố gắng tiếp tục lại thiết bị trong tương lai, nhưng
      'power.runtime_error' cần được kiểm tra bổ sung và -EACCES có nghĩa là
      rằng cuộc gọi lại không thể thực hiện được vì 'power.disable_deep' là
      khác với 0

ZZ0000ZZ
    - chạy pm_runtime_resume(dev) và nếu thành công, hãy tăng kích thước của thiết bị
      bộ đếm sử dụng; trả về 0 nếu thành công (cho dù thiết bị có
      trạng thái PM thời gian chạy đã 'hoạt động') hoặc mã lỗi từ
      pm_runtime_resume() không thành công.

ZZ0000ZZ
    - gửi yêu cầu thực hiện lệnh gọi lại nhàn rỗi ở cấp hệ thống con cho
      thiết bị (yêu cầu được thể hiện bằng một mục công việc trong pm_wq); trả về 0 trên
      thành công hoặc mã lỗi nếu yêu cầu chưa được xếp hàng

ZZ0000ZZ
    - Gọi pm_runtime_mark_last_busy() và lên lịch thực hiện
      gọi lại tạm dừng cấp hệ thống con cho thiết bị khi độ trễ tự động tạm dừng
      hết hạn

ZZ0000ZZ
    - lên lịch thực hiện lệnh gọi lại tạm dừng ở cấp hệ thống con cho
      thiết bị trong tương lai, trong đó 'độ trễ' là thời gian chờ đợi trước khi xếp hàng
      tạm dừng mục công việc trong pm_wq, tính bằng mili giây (nếu 'độ trễ' bằng 0, công việc
      mục được xếp hàng ngay lập tức); trả về 0 nếu thành công, 1 nếu PM của thiết bị
      trạng thái thời gian chạy đã bị 'tạm dừng' hoặc mã lỗi nếu yêu cầu
      chưa được lên lịch (hoặc xếp hàng nếu 'độ trễ' là 0); nếu việc thực hiện
      ->runtime_suspend() đã được lên lịch và chưa hết hạn, phiên bản mới
      giá trị 'độ trễ' sẽ được sử dụng làm thời gian chờ đợi

ZZ0000ZZ
    - gửi yêu cầu thực hiện lệnh gọi lại tiếp tục ở cấp hệ thống con cho
      thiết bị (yêu cầu được thể hiện bằng một mục công việc trong pm_wq); trả về 0 trên
      thành công, 1 nếu trạng thái PM thời gian chạy của thiết bị đã 'hoạt động' hoặc
      mã lỗi nếu yêu cầu chưa được xếp hàng

ZZ0000ZZ
    - tăng bộ đếm sử dụng của thiết bị

ZZ0000ZZ
    - tăng bộ đếm mức sử dụng của thiết bị, chạy pm_request_resume(dev) và
      trả về kết quả của nó

ZZ0000ZZ
    - tăng bộ đếm mức sử dụng của thiết bị, chạy pm_runtime_resume(dev) và
      trả về kết quả của nó;
      lưu ý rằng nó không loại bỏ bộ đếm sử dụng của thiết bị khi có lỗi, vì vậy
      hãy cân nhắc sử dụng pm_runtime_resume_and_get() thay vì nó, đặc biệt
      nếu giá trị trả về của nó được người gọi kiểm tra, vì điều này có thể
      dẫn đến mã sạch hơn.

ZZ0000ZZ
    - trả về -EINVAL nếu 'power.disable_deep' khác 0; ngược lại, nếu
      trạng thái PM thời gian chạy là RPM_ACTIVE và bộ đếm mức sử dụng PM thời gian chạy là
      khác không, tăng bộ đếm và trả về 1; nếu không thì trả về 0 mà không có
      thay đổi bộ đếm

ZZ0000ZZ
    - trả về -EINVAL nếu 'power.disable_deep' khác 0; ngược lại, nếu
      trạng thái PM thời gian chạy là RPM_ACTIVE, tăng bộ đếm và
      trả về 1; nếu không thì trả về 0 mà không thay đổi bộ đếm

ZZ0000ZZ
    - giảm bộ đếm sử dụng của thiết bị

ZZ0000ZZ
    - giảm bộ đếm sử dụng của thiết bị; nếu kết quả là 0 thì chạy
      pm_request_idle(dev) và trả về kết quả của nó

ZZ0000ZZ
    - đặt trường power.last_busy theo thời gian hiện tại và giảm giá trị
      bộ đếm sử dụng của thiết bị; nếu kết quả là 0 thì chạy
      pm_request_autosuspend(dev) và trả về kết quả của nó

ZZ0000ZZ
    - giảm bộ đếm sử dụng của thiết bị; nếu kết quả là 0 thì chạy
      pm_request_autosuspend(dev) và trả về kết quả của nó

ZZ0000ZZ
    - giảm bộ đếm sử dụng của thiết bị; nếu kết quả là 0 thì chạy
      pm_runtime_idle(dev) và trả về kết quả của nó

ZZ0000ZZ
    - giảm bộ đếm sử dụng của thiết bị; nếu kết quả là 0 thì chạy
      pm_runtime_suspend(dev) và trả về kết quả của nó

ZZ0000ZZ
    - đặt trường power.last_busy theo thời gian hiện tại và giảm giá trị
      bộ đếm sử dụng của thiết bị; nếu kết quả là 0 thì chạy
      pm_runtime_autosuspend(dev) và trả về kết quả của nó

ZZ0000ZZ
    - giảm trường 'power.disable_deep' của thiết bị; nếu trường đó bằng nhau
      về 0, các hàm trợ giúp PM thời gian chạy có thể thực thi ở cấp hệ thống con
      cuộc gọi lại được mô tả trong Phần 2 cho thiết bị

ZZ0000ZZ
    - tăng trường 'power.disable_deep' của thiết bị (nếu giá trị của trường đó
      trường trước đó bằng 0, điều này ngăn PM thời gian chạy ở cấp hệ thống con
      cuộc gọi lại không được chạy cho thiết bị), hãy đảm bảo rằng tất cả
      Các hoạt động PM thời gian chạy đang chờ xử lý trên thiết bị đã được hoàn thành hoặc
      bị hủy bỏ; trả về 1 nếu có một yêu cầu tiếp tục đang chờ xử lý và nó đã được
      cần thiết để thực thi lệnh gọi lại tiếp tục ở cấp hệ thống con cho thiết bị
      để đáp ứng yêu cầu đó, nếu không thì trả về 0

ZZ0000ZZ
    - kiểm tra xem có yêu cầu tiếp tục nào đang chờ xử lý cho thiết bị không và tiếp tục lại yêu cầu đó
      (đồng bộ) trong trường hợp đó, hãy hủy mọi yêu cầu PM thời gian chạy đang chờ xử lý khác
      liên quan đến nó và chờ đợi tất cả các hoạt động PM thời gian chạy trên đó đang diễn ra
      hoàn thành

ZZ0000ZZ
    - đặt/bỏ đặt cờ power.ignore_children của thiết bị

ZZ0000ZZ
    - xóa cờ 'power.runtime_error' của thiết bị, đặt thời gian chạy của thiết bị
      Trạng thái PM thành 'hoạt động' và cập nhật bộ đếm 'hoạt động' của cha mẹ nó
      trẻ em nếu thích hợp (nó chỉ hợp lệ khi sử dụng chức năng này nếu
      'power.runtime_error' được đặt hoặc 'power.disable_deep' lớn hơn
      không); nó sẽ bị lỗi và trả về mã lỗi nếu thiết bị có thiết bị gốc
      không hoạt động và cờ 'power.ignore_children' chưa được đặt

ZZ0000ZZ
    - xóa cờ 'power.runtime_error' của thiết bị, đặt thời gian chạy của thiết bị
      Trạng thái PM thành 'bị treo' và cập nhật bộ đếm 'hoạt động' của cha mẹ nó
      trẻ em nếu thích hợp (nó chỉ hợp lệ khi sử dụng chức năng này nếu
      'power.runtime_error' được đặt hoặc 'power.disable_deep' lớn hơn
      không)

ZZ0000ZZ
    - trả về true nếu trạng thái PM thời gian chạy của thiết bị là 'hoạt động' hoặc
      Trường 'power.disable_deep' không bằng 0 hoặc ngược lại là sai

ZZ0000ZZ
    - trả về true nếu trạng thái PM thời gian chạy của thiết bị là 'bị treo' và
      Trường 'power.disable_deep' bằng 0 hoặc sai nếu không

ZZ0000ZZ
    - trả về true nếu trạng thái PM thời gian chạy của thiết bị là 'bị treo'

ZZ0000ZZ
    - đặt cờ power.no_callbacks cho thiết bị và xóa thời gian chạy
      Thuộc tính PM từ /sys/devices/.../power (hoặc ngăn không cho chúng bị
      được thêm vào khi thiết bị được đăng ký)

ZZ0000ZZ
    - đặt cờ power.irq_safe cho thiết bị, gây ra lỗi thời gian chạy-PM
      cuộc gọi lại được gọi khi bị ngắt

ZZ0000ZZ
    - trả về true nếu cờ power.irq_safe được đặt cho thiết bị, gây ra
      các lệnh gọi lại thời gian chạy-PM sẽ được gọi khi tắt các ngắt

ZZ0000ZZ
    - đặt trường power.last_busy theo thời gian hiện tại

ZZ0000ZZ
    - đặt cờ power.use_autosuspend, cho phép trì hoãn tự động tạm dừng; gọi
      pm_runtime_get_sync nếu cờ trước đó đã bị xóa và
      power.autosuspend_delay là số âm

ZZ0000ZZ
    - xóa cờ power.use_autosuspend, vô hiệu hóa độ trễ tự động treo;
      giảm bộ đếm sử dụng của thiết bị nếu cờ đã được đặt trước đó và
      power.autosuspend_delay là số âm; gọi pm_runtime_idle

ZZ0000ZZ
    - đặt giá trị power.autosuspend_delay thành 'delay' (được biểu thị bằng
      mili giây); nếu 'độ trễ' là số âm thì thời gian tạm dừng thời gian chạy là
      ngăn chặn; nếu power.use_autosuspend được đặt, pm_runtime_get_sync có thể
      được gọi hoặc bộ đếm mức sử dụng của thiết bị có thể bị giảm và
      pm_runtime_idle được gọi tùy thuộc vào việc có power.autosuspend_delay hay không
      thay đổi thành hoặc từ giá trị âm; nếu power.use_autosuspend rõ ràng,
      pm_runtime_idle được gọi

ZZ0000ZZ
    - tính thời gian khi khoảng thời gian trì hoãn tự động tạm dừng hiện tại sẽ hết hạn,
      dựa trên power.last_busy và power.autosuspend_delay; nếu thời gian trễ
      là 1000 ms hoặc lớn hơn thì thời gian hết hạn được làm tròn đến
      giây gần nhất; trả về 0 nếu thời gian trễ đã hết hoặc
      power.use_autosuspend chưa được đặt, nếu không sẽ trả về thời gian hết hạn
      trong nháy mắt

Việc thực thi các hàm trợ giúp sau từ ngữ cảnh ngắt là an toàn:

- pm_request_idle()
- pm_request_autosuspend()
- pm_schedule_suspend()
- pm_request_resume()
- pm_runtime_get_noresume()
- pm_runtime_get()
- pm_runtime_put_noidle()
- pm_runtime_put()
- pm_runtime_put_autosuspend()
- __pm_runtime_put_autosuspend()
- pm_runtime_enable()
- pm_suspend_ignore_children()
- pm_runtime_set_active()
- pm_runtime_set_suspends()
- pm_runtime_suspends()
- pm_runtime_mark_last_busy()
- pm_runtime_autosuspend_expiration()

Nếu pm_runtime_irq_safe() đã được gọi cho một thiết bị thì trình trợ giúp sau
các hàm cũng có thể được sử dụng trong ngữ cảnh ngắt:

- pm_runtime_idle()
- pm_runtime_suspend()
- pm_runtime_autosuspend()
- pm_runtime_resume()
- pm_runtime_get_sync()
- pm_runtime_put_sync()
- pm_runtime_put_sync_suspend()
- pm_runtime_put_sync_autosuspend()

5. Khởi tạo PM thời gian chạy, thăm dò và xóa thiết bị
========================================================

Ban đầu, PM thời gian chạy bị tắt đối với tất cả các thiết bị, điều đó có nghĩa là
phần lớn các hàm trợ giúp PM thời gian chạy được mô tả trong Phần 4 sẽ trả về
-EAGAIN cho đến khi pm_runtime_enable() được gọi cho thiết bị.

Ngoài ra, trạng thái PM thời gian chạy ban đầu của tất cả các thiết bị là
'bị treo', nhưng nó không cần phản ánh trạng thái vật lý thực tế của thiết bị.
Do đó, nếu thiết bị ban đầu hoạt động (tức là nó có thể xử lý I/O), thì
trạng thái PM thời gian chạy phải được thay đổi thành 'hoạt động', với sự trợ giúp của
pm_runtime_set_active(), trước khi pm_runtime_enable() được gọi cho thiết bị.

Tuy nhiên, nếu thiết bị có thiết bị gốc và PM thời gian chạy của thiết bị gốc được bật,
gọi pm_runtime_set_active() cho thiết bị sẽ ảnh hưởng đến thiết bị gốc, trừ khi
cờ 'power.ignore_children' của cha mẹ được đặt.  Cụ thể, trong trường hợp đó
cha mẹ sẽ không thể tạm dừng trong thời gian chạy bằng cách sử dụng trình trợ giúp của lõi PM
hoạt động, miễn là trạng thái của trẻ là 'hoạt động', ngay cả khi
thời gian chạy PM vẫn bị tắt (tức là pm_runtime_enable() chưa được gọi
đứa trẻ nào hoặc pm_runtime_disable() đã được gọi cho nó).  Vì lý do này,
khi pm_runtime_set_active() đã được gọi cho thiết bị, pm_runtime_enable()
cũng nên được gọi cho nó càng sớm càng tốt hoặc PM thời gian chạy của nó
trạng thái nên được thay đổi trở lại thành 'bị treo' với sự trợ giúp của
pm_runtime_set_suspends().

Nếu trạng thái PM thời gian chạy ban đầu mặc định của thiết bị (tức là 'bị treo')
phản ánh trạng thái thực tế của thiết bị, loại xe buýt hoặc trình điều khiển của thiết bị
->cuộc gọi lại thăm dò() có thể sẽ cần phải đánh thức nó bằng một trong các lõi PM
các hàm trợ giúp được mô tả trong Phần 4. Trong trường hợp đó, pm_runtime_resume()
nên được sử dụng.  Tất nhiên, với mục đích này, PM thời gian chạy của thiết bị phải là
được bật trước đó bằng cách gọi pm_runtime_enable().

Lưu ý, nếu thiết bị có thể thực hiện các lệnh gọi pm_runtime trong quá trình thăm dò (chẳng hạn như
nếu nó được đăng ký với một hệ thống con có thể gọi lại) thì
cuộc gọi pm_runtime_get_sync() được ghép nối với cuộc gọi pm_runtime_put() sẽ là
thích hợp để đảm bảo rằng thiết bị không được đưa trở lại trạng thái ngủ trong thời gian
thăm dò. Điều này có thể xảy ra với các hệ thống như lớp thiết bị mạng.

Có thể nên tạm dừng thiết bị sau khi ->probe() kết thúc.
Do đó, lõi trình điều khiển sử dụng pm_request_idle() không đồng bộ để gửi
yêu cầu thực hiện cuộc gọi lại nhàn rỗi ở cấp hệ thống con cho thiết bị tại đó
thời gian.  Trình điều khiển sử dụng tính năng tự động tạm dừng thời gian chạy có thể muốn
cập nhật dấu bận cuối cùng trước khi quay lại từ ->probe().

Hơn nữa, lõi trình điều khiển ngăn chặn các cuộc gọi lại PM thời gian chạy chạy đua với xe buýt
gọi lại trình thông báo trong __device_release_driver(), điều này là cần thiết vì
trình thông báo được một số hệ thống con sử dụng để thực hiện các hoạt động ảnh hưởng đến
chức năng PM thời gian chạy.  Nó làm như vậy bằng cách gọi pm_runtime_get_sync() trước
driver_sysfs_remove() và thông báo BUS_NOTIFY_UNBIND_DRIVER.  Cái này
tiếp tục lại thiết bị nếu nó ở trạng thái treo và ngăn không cho thiết bị
bị đình chỉ một lần nữa trong khi những thói quen đó đang được thực thi.

Cho phép các loại xe buýt và tài xế đưa thiết bị vào trạng thái treo bằng cách
gọi pm_runtime_suspend() từ quy trình ->remove() của họ, lõi trình điều khiển
thực thi pm_runtime_put_sync() sau khi chạy BUS_NOTIFY_UNBIND_DRIVER
thông báo trong __device_release_driver().  Điều này đòi hỏi các loại xe buýt và
trình điều khiển để thực hiện cuộc gọi lại ->remove() của họ tránh các cuộc đua trực tiếp với PM thời gian chạy,
mà còn cho phép linh hoạt hơn trong việc xử lý các thiết bị trong quá trình
loại bỏ các trình điều khiển của họ.

Trình điều khiển trong cuộc gọi lại ->remove() sẽ hoàn tác các thay đổi PM thời gian chạy đã thực hiện
trong -> thăm dò(). Thông thường điều này có nghĩa là gọi pm_runtime_disable(),
pm_runtime_dont_use_autosuspend() v.v.

Không gian người dùng có thể ngăn chặn trình điều khiển của thiết bị quản lý nguồn một cách hiệu quả
nó trong thời gian chạy bằng cách thay đổi giá trị của /sys/devices/.../power/control
thuộc tính "bật", khiến cho pm_runtime_forbid() được gọi.  Về nguyên tắc,
Người lái xe cũng có thể sử dụng cơ chế này để tắt hệ thống một cách hiệu quả.
quản lý năng lượng thời gian chạy của thiết bị cho đến khi không gian người dùng bật thiết bị.
Cụ thể, trong quá trình khởi tạo trình điều khiển có thể đảm bảo rằng thời gian chạy PM
trạng thái của thiết bị là 'hoạt động' và gọi pm_runtime_forbid().  Nó nên như vậy
Tuy nhiên, lưu ý rằng nếu không gian người dùng đã cố ý thay đổi
giá trị của /sys/devices/.../power/control thành "auto" để cho phép trình điều khiển cấp nguồn
quản lý thiết bị trong thời gian chạy, trình điều khiển có thể nhầm lẫn thiết bị bằng cách sử dụng
pm_runtime_forbid() theo cách này.

6. Thời gian chạy PM và chế độ ngủ của hệ thống
==============================

Thời gian chạy PM và chế độ ngủ của hệ thống (tức là hệ thống tạm dừng và ngủ đông, còn được gọi là
như tạm dừng với RAM và tạm dừng vào đĩa) tương tác với nhau trong một vài
cách.  Nếu một thiết bị đang hoạt động khi chế độ ngủ của hệ thống bắt đầu thì mọi thứ đều được
đơn giản.  Nhưng điều gì sẽ xảy ra nếu thiết bị đã bị treo?

Thiết bị có thể có các cài đặt đánh thức khác nhau cho thời gian chạy PM và chế độ ngủ của hệ thống.
Ví dụ: đánh thức từ xa có thể được bật để tạm dừng thời gian chạy nhưng không được phép
đối với chế độ ngủ của hệ thống (device_may_wakeup(dev) trả về 'false').  Khi điều này xảy ra,
lệnh gọi lại đình chỉ hệ thống cấp hệ thống con chịu trách nhiệm thay đổi
cài đặt đánh thức của thiết bị (có thể để hệ thống của trình điều khiển thiết bị xử lý việc đó
đình chỉ thói quen).  Có thể cần phải tiếp tục lại thiết bị và tạm dừng lại
để làm như vậy.  Điều tương tự cũng đúng nếu người lái sử dụng các mức công suất khác nhau
hoặc các cài đặt khác cho chế độ tạm dừng thời gian chạy và chế độ ngủ của hệ thống.

Trong quá trình khôi phục hệ thống, cách tiếp cận đơn giản nhất là đưa tất cả các thiết bị trở lại trạng thái đầy đủ
quyền lực, ngay cả khi họ đã bị đình chỉ trước khi hệ thống tạm dừng bắt đầu.  Ở đó
có một số lý do cho việc này, bao gồm:

* Thiết bị có thể cần phải chuyển đổi mức năng lượng, cài đặt đánh thức, v.v.

* Các sự kiện đánh thức từ xa có thể đã bị mất trong phần sụn.

* Trẻ em của thiết bị có thể cần thiết bị hoạt động hết công suất để
    để tiếp tục lại chính mình.

* Ý tưởng của người lái xe về trạng thái thiết bị có thể không giống với ý tưởng của thiết bị
    trạng thái vật lý.  Điều này có thể xảy ra trong quá trình tiếp tục từ chế độ ngủ đông.

* Có thể cần phải thiết lập lại thiết bị.

* Mặc dù thiết bị đã bị treo, nhưng nếu bộ đếm sử dụng của nó > 0 thì hầu hết
    dù sao thì có khả năng nó sẽ cần một bản lý lịch thời gian chạy trong tương lai gần.

Nếu thiết bị đã bị treo trước khi quá trình tạm dừng hệ thống bắt đầu và nó
được đưa trở lại toàn bộ sức mạnh trong quá trình tiếp tục, thì trạng thái PM thời gian chạy của nó sẽ có
được cập nhật để phản ánh trạng thái ngủ thực tế sau hệ thống.  Cách để làm
đây là:

- pm_runtime_disable(dev);
	 - pm_runtime_set_active(dev);
	 - pm_runtime_enable(dev);

Lõi PM luôn tăng bộ đếm mức sử dụng thời gian chạy trước khi gọi
->suspend() gọi lại và giảm nó sau khi gọi lại ->resume().
Do đó việc tắt tạm thời PM thời gian chạy như thế này sẽ không gây ra bất kỳ thời gian chạy nào
đình chỉ các nỗ lực để bị mất vĩnh viễn.  Nếu số lượng sử dụng về 0
sau sự trở lại của lệnh gọi lại ->resume(), lệnh gọi lại ->runtime_idle()
sẽ được gọi như bình thường.

Tuy nhiên, trên một số hệ thống, chế độ ngủ của hệ thống không được nhập thông qua chương trình cơ sở chung
hoặc hoạt động phần cứng.  Thay vào đó, tất cả các thành phần phần cứng được đưa vào nguồn điện năng thấp.
được phát biểu trực tiếp bởi kernel một cách phối hợp.  Sau đó, hệ thống ngủ
trạng thái tuân theo một cách hiệu quả từ các trạng thái mà các thành phần phần cứng kết thúc
và hệ thống được đánh thức khỏi trạng thái đó do ngắt phần cứng hoặc tương tự
cơ chế hoàn toàn dưới sự kiểm soát của kernel.  Kết quả là hạt nhân không bao giờ
trao quyền kiểm soát và trạng thái của tất cả các thiết bị trong quá trình tiếp tục được chính xác
được biết đến với nó.  Nếu đúng như vậy và không có tình huống nào được liệt kê ở trên có tác dụng
địa điểm (đặc biệt, nếu hệ thống không thức dậy sau chế độ ngủ đông), nó có thể
sẽ hiệu quả hơn khi để lại các thiết bị đã bị treo trước hệ thống
đình chỉ bắt đầu ở trạng thái đình chỉ.

Để đạt được mục đích này, lõi PM cung cấp một cơ chế cho phép phối hợp giữa
các cấp độ khác nhau của hệ thống phân cấp thiết bị.  Cụ thể, nếu một hệ thống tạm dừng .prepare()
gọi lại trả về một số dương cho một thiết bị, cho biết lõi PM
rằng thiết bị dường như bị tạm dừng thời gian chạy và trạng thái của nó vẫn ổn, vì vậy nó
có thể được để lại trong thời gian tạm dừng thời gian chạy với điều kiện là tất cả các hậu duệ của nó cũng
còn lại trong thời gian tạm dừng thời gian chạy.  Nếu điều đó xảy ra, lõi PM sẽ không thực thi bất kỳ
hệ thống tạm dừng và tiếp tục gọi lại cho tất cả các thiết bị đó, ngoại trừ
Lệnh gọi lại .complete(), sau đó hoàn toàn chịu trách nhiệm xử lý thiết bị
sao cho phù hợp.  Điều này chỉ áp dụng cho các quá trình chuyển đổi tạm dừng hệ thống không
liên quan đến chế độ ngủ đông (xem Documentation/driver-api/pm/devices.rst để biết thêm
thông tin).

Lõi PM cố gắng hết sức để giảm khả năng xảy ra điều kiện chạy đua giữa
lệnh gọi lại PM thời gian chạy và hệ thống tạm dừng/tiếp tục (và ngủ đông) bằng cách mang theo
ra các thao tác sau:

* Trong quá trình tạm dừng hệ thống, pm_runtime_get_noresume() được gọi cho mọi thiết bị
    ngay trước khi thực hiện lệnh gọi lại .prepare() ở cấp hệ thống con cho nó và
    pm_runtime_barrier() được gọi cho mọi thiết bị ngay trước khi thực thi
    gọi lại .suspend() cấp hệ thống con cho nó.  Bên cạnh đó, Thủ tướng
    core vô hiệu hóa PM thời gian chạy cho mọi thiết bị ngay trước khi thực thi
    gọi lại .suspend_late() cấp hệ thống con cho nó.

* Trong quá trình khôi phục hệ thống, pm_runtime_enable() và pm_runtime_put() được yêu cầu
    mọi thiết bị ngay sau khi thực thi .resume_early() ở cấp hệ thống con
    gọi lại và ngay sau khi thực hiện lệnh gọi lại .complete() ở cấp hệ thống con
    tương ứng cho nó.

7. Lệnh gọi lại hệ thống con chung
==============================

Các hệ thống con có thể muốn bảo tồn không gian mã bằng cách sử dụng tập hợp sức mạnh chung
các cuộc gọi lại quản lý được cung cấp bởi lõi PM, được xác định trong
trình điều khiển/cơ sở/sức mạnh/generic_ops.c:

ZZ0000ZZ
    - gọi lệnh gọi lại ->runtime_suspend() do trình điều khiển này cung cấp
      thiết bị và trả về kết quả của nó hoặc trả về 0 nếu không được xác định

ZZ0000ZZ
    - gọi lệnh gọi lại ->runtime_resume() do trình điều khiển này cung cấp
      thiết bị và trả về kết quả của nó hoặc trả về 0 nếu không được xác định

ZZ0000ZZ
    - nếu thiết bị chưa bị treo trong thời gian chạy, hãy gọi ->suspend()
      gọi lại do trình điều khiển của nó cung cấp và trả về kết quả hoặc trả về 0 nếu không
      được xác định

ZZ0000ZZ
    - nếu pm_runtime_suspends(dev) trả về "false", hãy gọi ->suspend_noirq()
      gọi lại do trình điều khiển của thiết bị cung cấp và trả về kết quả của nó hoặc trả về
      0 nếu không được xác định

ZZ0000ZZ
    - gọi lệnh gọi lại ->resume() do trình điều khiển của thiết bị này cung cấp và,
      nếu thành công, hãy thay đổi trạng thái PM thời gian chạy của thiết bị thành 'hoạt động'

ZZ0000ZZ
    - gọi lệnh gọi lại ->resume_noirq() do trình điều khiển của thiết bị này cung cấp

ZZ0000ZZ
    - nếu thiết bị không bị treo trong thời gian chạy, hãy gọi ->freeze()
      gọi lại do trình điều khiển của nó cung cấp và trả về kết quả hoặc trả về 0 nếu không
      được xác định

ZZ0000ZZ
    - nếu pm_runtime_suspends(dev) trả về "false", hãy gọi ->freeze_noirq()
      gọi lại do trình điều khiển của thiết bị cung cấp và trả về kết quả của nó hoặc trả về
      0 nếu không được xác định

ZZ0000ZZ
    - nếu thiết bị không bị treo trong thời gian chạy, hãy gọi ->tan băng()
      gọi lại do trình điều khiển của nó cung cấp và trả về kết quả hoặc trả về 0 nếu không
      được xác định

ZZ0000ZZ
    - nếu pm_runtime_suspends(dev) trả về "false", hãy gọi ->thaw_noirq()
      gọi lại do trình điều khiển của thiết bị cung cấp và trả về kết quả của nó hoặc trả về
      0 nếu không được xác định

ZZ0000ZZ
    - nếu thiết bị không bị treo trong thời gian chạy, hãy gọi ->poweroff()
      gọi lại do trình điều khiển của nó cung cấp và trả về kết quả hoặc trả về 0 nếu không
      được xác định

ZZ0000ZZ
    - nếu pm_runtime_suspends(dev) trả về "false", hãy chạy ->poweroff_noirq()
      gọi lại do trình điều khiển của thiết bị cung cấp và trả về kết quả của nó hoặc trả về
      0 nếu không được xác định

ZZ0000ZZ
    - gọi lệnh gọi lại ->restore() do trình điều khiển của thiết bị này cung cấp và,
      nếu thành công, hãy thay đổi trạng thái PM thời gian chạy của thiết bị thành 'hoạt động'

ZZ0000ZZ
    - gọi lệnh gọi lại ->restore_noirq() do trình điều khiển của thiết bị cung cấp

Các chức năng này là các giá trị mặc định được lõi PM sử dụng nếu hệ thống con không
cung cấp lệnh gọi lại của riêng nó cho ->runtime_idle(), ->runtime_suspend(),
->runtime_resume(), ->suspend(), ->suspend_noirq(), ->resume(),
->resume_noirq(), ->freeze(), ->freeze_noirq(), ->thaw(), ->thaw_noirq(),
->poweroff(), ->poweroff_noirq(), ->restore(), ->restore_noirq() trong
cấu trúc dev_pm_ops cấp hệ thống con.

Trình điều khiển thiết bị muốn sử dụng chức năng tương tự như hệ thống tạm dừng, đóng băng,
tắt nguồn và tạm dừng gọi lại thời gian chạy, và tương tự đối với hệ thống tiếp tục, tan băng,
khôi phục và tiếp tục thời gian chạy, có thể đạt được hành vi tương tự với sự trợ giúp của
DEFINE_RUNTIME_DEV_PM_OPS() được xác định trong include/linux/pm_runtime.h (có thể cài đặt
đối số cuối cùng cho NULL).

8. Thiết bị "Không gọi lại"
========================

Một số "thiết bị" chỉ là thiết bị phụ logic của cha mẹ chúng và không thể
tự mình quản lý năng lượng.  (Ví dụ nguyên mẫu là giao diện USB. Toàn bộ
Các thiết bị USB có thể chuyển sang chế độ năng lượng thấp hoặc gửi yêu cầu đánh thức, nhưng cũng không
có thể áp dụng cho các giao diện riêng lẻ.) Trình điều khiển cho các thiết bị này không có
nhu cầu gọi lại PM thời gian chạy; nếu lệnh gọi lại tồn tại, ->runtime_suspend()
và ->runtime_resume() sẽ luôn trả về 0 mà không cần làm gì khác và
->runtime_idle() sẽ luôn gọi pm_runtime_suspend().

Các hệ thống con có thể thông báo cho lõi PM về các thiết bị này bằng cách gọi
pm_runtime_no_callbacks().  Điều này nên được thực hiện sau khi cấu trúc thiết bị được
được khởi tạo và trước khi nó được đăng ký (mặc dù sau khi đăng ký thiết bị
cũng được).  Quy trình này sẽ đặt cờ power.no_callbacks của thiết bị và
ngăn chặn việc tạo các thuộc tính PM sysfs thời gian chạy không gỡ lỗi.

Khi power.no_callbacks được đặt, lõi PM sẽ không gọi
->runtime_idle(), ->runtime_suspend() hoặc ->runtime_resume() gọi lại.
Thay vào đó, nó sẽ cho rằng việc tạm dừng và tiếp tục luôn thành công và việc nhàn rỗi đó
thiết bị nên bị đình chỉ.

Do đó, lõi PM sẽ không bao giờ thông báo trực tiếp cho hệ thống con của thiết bị
hoặc trình điều khiển về những thay đổi về nguồn điện trong thời gian chạy.  Thay vào đó, trình điều khiển của thiết bị
phụ huynh phải chịu trách nhiệm thông báo cho người điều khiển thiết bị khi
trạng thái sức mạnh của cha mẹ thay đổi.

Lưu ý rằng, trong một số trường hợp, hệ thống con/trình điều khiển có thể không muốn gọi
pm_runtime_no_callbacks() cho thiết bị của họ. Điều này có thể là do một tập hợp con của
lệnh gọi lại PM thời gian chạy cần được triển khai, PM phụ thuộc vào nền tảng
miền có thể được gắn vào thiết bị hoặc thiết bị được quản lý nguồn
thông qua liên kết thiết bị của nhà cung cấp. Vì những lý do này và để tránh mã soạn sẵn
trong các hệ thống con/trình điều khiển, lõi PM cho phép các cuộc gọi lại PM thời gian chạy được thực hiện
chưa được chỉ định. Chính xác hơn, nếu con trỏ gọi lại là NULL, lõi PM sẽ hoạt động
như thể có một cuộc gọi lại và nó trả về 0.

9. Tự động tạm dừng hoặc tạm dừng tự động bị trì hoãn
=================================================

Việc thay đổi trạng thái nguồn của thiết bị không phải là miễn phí; nó đòi hỏi cả thời gian và năng lượng.
Chỉ nên đặt thiết bị ở trạng thái năng lượng thấp khi có lý do nào đó để
nghĩ rằng nó sẽ vẫn ở trạng thái đó trong một thời gian đáng kể.  Một heuristic phổ biến
nói rằng một thiết bị không được sử dụng trong một thời gian có khả năng vẫn còn
chưa sử dụng; theo lời khuyên này, người lái xe không nên để thiết bị bị treo
trong thời gian chạy cho đến khi chúng không hoạt động trong một khoảng thời gian tối thiểu.  Ngay cả khi
heuristic cuối cùng không tối ưu, nó vẫn sẽ ngăn các thiết bị
"nảy" quá nhanh giữa trạng thái năng lượng thấp và trạng thái năng lượng đầy đủ.

Thuật ngữ "autosuspend" là một tàn tích lịch sử.  Nó không có nghĩa là
thiết bị sẽ tự động bị treo (hệ thống con hoặc trình điều khiển vẫn phải gọi
các thói quen PM thích hợp); đúng hơn, điều đó có nghĩa là việc tạm dừng thời gian chạy sẽ
tự động bị trì hoãn cho đến khi hết thời gian không hoạt động mong muốn.

Tình trạng không hoạt động được xác định dựa trên trường power.last_busy. Chiều dài mong muốn
của thời gian không hoạt động là một vấn đề của chính sách.  Các hệ thống con có thể đặt độ dài này
ban đầu bằng cách gọi pm_runtime_set_autosuspend_delay(), nhưng sau khi gọi thiết bị
đăng ký độ dài phải được kiểm soát bởi không gian người dùng, sử dụng
Thuộc tính /sys/devices/.../power/autosuspend_delay_ms.

Để sử dụng tính năng tự động treo, hệ thống con hoặc trình điều khiển phải gọi
pm_runtime_use_autosuspend() (tốt nhất là trước khi đăng ký thiết bị) và
sau đó họ nên sử dụng các chức năng trợ giúp ZZ0000ZZ khác nhau
thay vì các đối tác không tự động gửi::

Thay vì: pm_runtime_suspend hãy sử dụng: pm_runtime_autosuspend;
	Thay vì: pm_schedule_suspend hãy sử dụng: pm_request_autosuspend;
	Thay vì: pm_runtime_put hãy sử dụng: pm_runtime_put_autosuspend;
	Thay vì: pm_runtime_put_sync hãy sử dụng: pm_runtime_put_sync_autosuspend.

Trình điều khiển cũng có thể tiếp tục sử dụng các chức năng trợ giúp không tự động treo; họ
sẽ hoạt động bình thường, điều đó có nghĩa là đôi khi tính đến độ trễ tự động tạm dừng
tài khoản (xem pm_runtime_idle). Các biến thể tự động treo của các chức năng cũng
gọi pm_runtime_mark_last_busy().

Trong một số trường hợp, trình điều khiển hoặc hệ thống con có thể muốn ngăn thiết bị
khỏi việc tự động tạm dừng ngay lập tức, mặc dù bộ đếm mức sử dụng bằng 0 và
thời gian trì hoãn tự động treo đã hết.  Nếu lệnh gọi lại ->runtime_suspend()
trả về -EAGAIN hoặc -EBUSY và nếu thời gian hết hạn trì hoãn tự động gửi tiếp theo là
trong tương lai (như thường lệ nếu lệnh gọi lại được gọi
pm_runtime_mark_last_busy()), lõi PM sẽ tự động lên lịch lại
tự động treo.  Cuộc gọi lại ->runtime_suspend() không thể thực hiện việc lên lịch lại này
chính nó vì không có yêu cầu tạm dừng dưới bất kỳ hình thức nào được chấp nhận trong khi thiết bị đang hoạt động
tạm dừng (tức là trong khi lệnh gọi lại đang chạy).

Việc triển khai rất phù hợp để sử dụng không đồng bộ trong bối cảnh ngắt.
Tuy nhiên, việc sử dụng như vậy chắc chắn sẽ liên quan đến các cuộc đua, vì lõi PM không thể
đồng bộ hóa lệnh gọi lại ->runtime_suspend() khi có yêu cầu I/O xuất hiện.
Việc đồng bộ hóa này phải được trình điều khiển xử lý bằng cách sử dụng khóa riêng của nó.
Dưới đây là một ví dụ về mã giả dạng sơ đồ::

foo_read_or_write(struct foo_priv *foo, void *data)
	{
		lock(&foo->private_lock);
		add_request_to_io_queue(foo, data);
		nếu (foo->num_pending_requests++ == 0)
			pm_runtime_get(&foo->dev);
		if (!foo->is_suspends)
			foo_process_next_request(foo);
		mở khóa(&foo->private_lock);
	}

foo_io_completion(struct foo_priv *foo, void *req)
	{
		lock(&foo->private_lock);
		nếu (--foo->num_pending_requests == 0)
			pm_runtime_put_autosuspend(&foo->dev);
		khác
			foo_process_next_request(foo);
		mở khóa(&foo->private_lock);
		/* Gửi lại kết quả req cho người dùng ... */
	}

int foo_runtime_suspend(thiết bị cấu trúc *dev)
	{
		struct foo_priv foo = container_of(dev, ...);
		int ret = 0;

lock(&foo->private_lock);
		if (foo->num_pending_requests > 0) {
			ret = -EBUSY;
		} khác {
			/* ... tạm dừng thiết bị ... */
			foo->is_suspends = 1;
		}
		mở khóa(&foo->private_lock);
		trở lại ret;
	}

int foo_runtime_resume(thiết bị cấu trúc *dev)
	{
		struct foo_priv foo = container_of(dev, ...);

lock(&foo->private_lock);
		/* ... tiếp tục thiết bị ... */
		foo->is_suspends = 0;
		pm_runtime_mark_last_busy(&foo->dev);
		nếu (foo->num_pending_requests > 0)
			foo_process_next_request(foo);
		mở khóa(&foo->private_lock);
		trả về 0;
	}

Điểm quan trọng là sau khi foo_io_completion() yêu cầu tự động gửi,
lệnh gọi lại foo_runtime_suspend() có thể chạy đua với foo_read_or_write().
Do đó foo_runtime_suspend() phải kiểm tra xem có bất kỳ I/O nào đang chờ xử lý không
yêu cầu (trong khi giữ khóa riêng) trước khi cho phép tạm dừng
tiến hành.

Ngoài ra, trường power.autosuspend_delay có thể được thay đổi theo không gian người dùng tại
bất cứ lúc nào.  Nếu người lái xe quan tâm đến điều này, nó có thể gọi
pm_runtime_autosuspend_expiration() từ bên trong ->runtime_suspend()
gọi lại trong khi giữ khóa riêng của nó.  Nếu hàm trả về giá trị khác 0
value thì độ trễ vẫn chưa hết và lệnh gọi lại sẽ trả về
-EAGAIN.
