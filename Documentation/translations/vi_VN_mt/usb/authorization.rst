.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/usb/authorization.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================================================================
Cho phép (hoặc không) các thiết bị USB của bạn kết nối với hệ thống
===================================================================

Bản quyền (C) 2007 Inaky Perez-Gonzalez <inaky@linux.intel.com> Tập đoàn Intel

Tính năng này cho phép bạn kiểm soát xem có thể sử dụng thiết bị USB (hoặc
không) trong một hệ thống. Tính năng này sẽ cho phép bạn thực hiện khóa
của các thiết bị USB, được kiểm soát hoàn toàn bởi không gian người dùng.

Hiện tại, khi thiết bị USB được kết nối, nó sẽ được cấu hình và
giao diện của nó ngay lập tức được cung cấp cho người dùng.  Với cái này
sửa đổi, chỉ khi root cho phép thiết bị được cấu hình mới
thì có thể sử dụng nó.

Cách sử dụng
============

Cho phép một thiết bị kết nối::

$ echo 1 > /sys/bus/usb/devices/DEVICE/được ủy quyền

Hủy cấp quyền cho thiết bị::

$ echo 0 > /sys/bus/usb/devices/DEVICE/được ủy quyền

Đặt các thiết bị mới được kết nối với HostX ở chế độ hủy cấp phép theo mặc định (ví dụ:
khóa lại)::

$ echo 0 > /sys/bus/usb/devices/usbX/authorized_default

Tháo khóa xuống::

$ echo 1 > /sys/bus/usb/devices/usbX/authorized_default

Theo mặc định, tất cả các thiết bị USB đều được ủy quyền.  Viết "2" vào
Thuộc tính ủy quyền_default khiến kernel được ủy quyền theo mặc định
chỉ các thiết bị được kết nối với cổng USB bên trong.


Khóa hệ thống mẫu (khập khiễng)
-------------------------------

Hãy tưởng tượng bạn muốn thực hiện khóa để chỉ các thiết bị thuộc loại XYZ
có thể được kết nối (ví dụ: đó là máy kiosk có thể nhìn thấy
Cổng USB)::

khởi động
  rc.local ->

dành cho máy chủ trong /sys/bus/usb/devices/usb*
   làm
      echo 0 > $host/ủy quyền_default
   xong

Kết nối tập lệnh với udev, dành cho các thiết bị USB mới::

nếu device_is_my_type $DEV
 sau đó
   echo 1 > $device_path/được ủy quyền
 xong


Bây giờ, device_is_my_type() là nơi chứa nước trái cây để khóa. chỉ
kiểm tra xem lớp, loại và giao thức có khớp với thứ gì đó tệ hơn không
xác minh bảo mật mà bạn có thể thực hiện (hoặc cách tốt nhất, đối với người sẵn sàng
để phá vỡ nó). Nếu bạn cần thứ gì đó an toàn, hãy sử dụng tiền điện tử và Chứng chỉ
Xác thực hoặc những thứ tương tự. Một cái gì đó đơn giản cho một khóa lưu trữ
có thể là::

chức năng device_is_my_type()
 {
   echo 1 > ủy quyền # temporarily ủy quyền cho nó
                                # ZZ0000ZZ: đảm bảo không ai có thể gắn kết được nó
   gắn DEVICENODE /mntpoint
   sum=$(md5sum /mntpoint/.signature)
   nếu [ $sum = $(cat /etc/lockdown/keysum) ]
   sau đó
        echo "Chúng tôi ổn, kết nối"
        số lượng /mntpoint
        Những thứ # Other để người khác có thể sử dụng
   khác
        echo 0 > được ủy quyền
   fi
 }


Tất nhiên, điều này thật khập khiễng, bạn sẽ muốn có một chứng chỉ thực sự
nội dung xác minh bằng PKI, do đó bạn không phụ thuộc vào bí mật chung,
v.v., nhưng bạn hiểu ý rồi đấy. Bất kỳ ai có quyền truy cập vào bộ tiện ích thiết bị
có thể giả mạo mô tả và thông tin thiết bị. Đừng tin vào điều đó. Không có gì.


Ủy quyền giao diện
-----------------------

Có một cách tiếp cận tương tự để cho phép hoặc từ chối các giao diện USB cụ thể.
Điều đó chỉ cho phép chặn một tập hợp con của thiết bị USB.

Ủy quyền cho một giao diện::

$ echo 1 > /sys/bus/usb/devices/INTERFACE/được ủy quyền

Hủy cấp phép một giao diện::

$ echo 0 > /sys/bus/usb/devices/INTERFACE/được ủy quyền

Giá trị mặc định cho giao diện mới
trên một xe buýt USB cụ thể cũng có thể được thay đổi.

Cho phép giao diện theo mặc định::

$ echo 1 > /sys/bus/usb/devices/usbX/interface_authorized_default

Từ chối giao diện theo mặc định::

$ echo 0 > /sys/bus/usb/devices/usbX/interface_authorized_default

Theo mặc định, bit giao diện_authorized_default là 1.
Vì vậy, tất cả các giao diện sẽ được ủy quyền theo mặc định.

Lưu ý:
  Nếu một giao diện không được cấp phép sẽ được cấp phép thì việc thăm dò trình điều khiển phải
  được kích hoạt thủ công bằng cách ghi INTERFACE vào /sys/bus/usb/drivers_probe

Đối với các trình điều khiển cần nhiều giao diện, tất cả các giao diện cần thiết đều phải có
được ủy quyền đầu tiên. Sau đó các trình điều khiển nên được thăm dò.
Điều này tránh tác dụng phụ.
