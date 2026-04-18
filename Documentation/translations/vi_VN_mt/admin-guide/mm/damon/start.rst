.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/mm/damon/start.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
Bắt đầu
=================

Tài liệu này mô tả ngắn gọn cách bạn có thể sử dụng DAMON bằng cách trình diễn nó
công cụ không gian người dùng mặc định.  Xin lưu ý rằng tài liệu này chỉ mô tả một phần
các tính năng của nó cho ngắn gọn.  Vui lòng tham khảo cách sử dụng ZZ0000ZZ của tool để biết thêm
chi tiết.


Điều kiện tiên quyết
=============

hạt nhân
------

Trước tiên bạn phải đảm bảo hệ thống của mình đang chạy trên kernel được xây dựng bằng
ZZ0000ZZ.


Công cụ không gian người dùng
---------------

Để trình diễn, chúng tôi sẽ sử dụng công cụ không gian người dùng mặc định cho DAMON,
được gọi là Toán tử DAMON (DAMO).  Nó có sẵn tại
ZZ0002ZZ Các ví dụ bên dưới giả định rằng ZZ0000ZZ đang bật
ZZ0001ZZ của bạn.  Tuy nhiên, nó không bắt buộc.

Bởi vì DAMO đang sử dụng giao diện sysfs (tham khảo ZZ0000ZZ để biết
chi tiết) của DAMON, bạn nên đảm bảo ZZ0001ZZ là
gắn kết.


Các mẫu truy cập dữ liệu ảnh chụp nhanh
=============================

Các lệnh bên dưới hiển thị kiểu truy cập bộ nhớ của một chương trình tại thời điểm
việc hành quyết. ::

$ git clone ZZ0000ZZ cd masim; làm
    $ sudo damo bắt đầu "./masim ./configs/stairs.cfg --quiet"
    $ sudo damo truy cập báo cáo
    bản đồ nhiệt: 641111111000000000000000000000000000000000000000000000000[...]33333333333333335557984444[...]7
    # min/nhiệt độ tối đa: -1.840.000.000, 370.010.000, kích thước cột: 3.925 MiB
    0 addr 86.182 Kích thước TiB 8.000 KiB truy cập 0 % tuổi 14.900 s
    1 addr 86.182 TiB kích thước 8.000 KiB truy cập 60 % tuổi 0 ns
    2 addr 86.182 Kích thước TiB 3.422 Truy cập MiB 0 % tuổi 4.100 s
    3 addr 86.182 Kích thước TiB 2.004 Truy cập MiB 95 % tuổi 2.200 s
    4 addr 86.182 Kích thước TiB 29.688 Truy cập MiB 0 % tuổi 14.100 s
    5 addr 86.182 Kích thước TiB 29.516 Truy cập MiB 0 % tuổi 16.700 s
    6 addr 86.182 Kích thước TiB 29.633 Truy cập MiB 0 % tuổi 17.900 s
    7 addr 86.182 Kích thước TiB 117.652 Truy cập MiB 0 % tuổi 18.400 s
    8 addr 126.990 Kích thước TiB 62.332 Truy cập MiB 0 % tuổi 9.500 s
    9 addr 126.990 Kích thước TiB 13.980 Truy cập MiB 0 % tuổi 5.200 s
    10 addr 126.990 Kích thước TiB 9.539 Truy cập MiB 100 % tuổi 3.700 s
    11 addr 126.990 Kích thước TiB 16.098 Truy cập MiB 0 % tuổi 6.400 s
    12 addr 127.987 Kích thước TiB 132.000 KiB truy cập 0 % tuổi 2.900 s
    tổng kích thước: 314.008 MiB
    $ sudo damo dừng lại

Lệnh đầu tiên của ví dụ trên tải xuống và xây dựng một
chương trình tạo truy cập bộ nhớ có tên ZZ0000ZZ.  Lệnh thứ hai hỏi DAMO
để khởi động chương trình thông qua lệnh đã cho và làm cho DAMON giám sát màn hình mới
quá trình bắt đầu.  Lệnh thứ ba truy xuất ảnh chụp nhanh hiện tại của
mẫu truy cập được giám sát của quy trình từ DAMON và hiển thị mẫu trong
định dạng con người có thể đọc được.

Dòng đầu tiên của đầu ra hiển thị nhiệt độ truy cập tương đối (độ nóng) của
các vùng ở định dạng hetmap một hàng.  Mỗi cột trên bản đồ nhiệt
đại diện cho các vùng có cùng kích thước trên không gian địa chỉ ảo được giám sát.  các
Vị trí của cột trên hàng và số trên cột thể hiện
vị trí tương đối và nhiệt độ truy cập của khu vực.  ZZ0000ZZ có nghĩa là
các vùng lớn chưa được ánh xạ trên không gian địa chỉ ảo.  Dòng thứ hai hiển thị
thông tin bổ sung để hiểu rõ hơn về bản đồ nhiệt.

Mỗi dòng đầu ra từ dòng thứ ba hiển thị dải địa chỉ ảo nào
(ZZ0000ZZ) của quy trình là tần suất (ZZ0001ZZ)
được truy cập trong thời gian bao lâu (ZZ0002ZZ).  Ví dụ, khu vực thứ mười một của
Kích thước ~9,5 MiB đang được truy cập thường xuyên nhất trong 3,7 giây qua.  Cuối cùng,
lệnh thứ tư dừng DAMON.

Lưu ý rằng DAMON có thể giám sát không chỉ không gian địa chỉ ảo mà còn nhiều loại
không gian địa chỉ bao gồm cả không gian địa chỉ vật lý.


Ghi lại các mẫu truy cập dữ liệu
==============================

Các lệnh bên dưới ghi lại các kiểu truy cập bộ nhớ của một chương trình và lưu lại
theo dõi kết quả vào một tập tin. ::

$ ./masim ./configs/zigzag.cfg &
    $ sudo damo record -o damon.data $(pidof masim)

Dòng lệnh chạy truy cập bộ nhớ nhân tạo
chương trình máy phát điện một lần nữa.  Máy phát điện sẽ lặp đi lặp lại
truy cập từng vùng bộ nhớ có kích thước 100 MiB.  Bạn có thể thay thế điều này
với khối lượng công việc thực tế của bạn.  Dòng cuối cùng yêu cầu ZZ0000ZZ ghi lại quyền truy cập
mẫu trong tệp ZZ0001ZZ.


Trực quan hóa các mẫu đã ghi
=============================

Bạn có thể hình dung mẫu trong bản đồ nhiệt, hiển thị vùng bộ nhớ nào
(trục x) được truy cập khi (trục y) và tần suất (số).::

Bản đồ nhiệt báo cáo $ sudo damo
    222222222222222222222222222222222222222211111111111111111111111111111111111111100
    4444444444444444444444444444444444444443444444444444444444444444444444444444443200
    4444444444444444444444444444444444444443344444444444444444444444444444444444444200
    33333333333333333333333333333333333333334455555555555555555555555555555555555555200
    3333333333333333333333333333333333334444444444444444444444444444444444444444444200
    2222222222222222222222222222222222222233555555555555555555555555555555555555555200
    00000000000000000000000000000000000000000288888888888888888888888888888888888888888400
    00000000000000000000000000000000000000000288888888888888888888888888888888888888888400
    33333333333333333333333333333333333333335555555555555555555555555555555555555555200
    888888888888888888888888888888888888888600000000000000000000000000000000000000000000
    888888888888888888888888888888888888888600000000000000000000000000000000000000000000
    33333333333333333333333333333333333333444444444444444444444444444444444444444443200
    00000000000000000000000000000000000000000288888888888888888888888888888888888888888400
    […]
    # access_frequency: 0 1 2 3 4 5 6 7 8 9
    # x-axis: không gian (139728247021568-139728453431248: 196.848 MiB)
    # y-axis: thời gian (15256597248362-15326899978162: 1 m 10,303 giây)
    # resolution: 80x40 (2,461 MiB và 1,758 giây cho mỗi ký tự)

Bạn cũng có thể hình dung sự phân bổ kích thước tập làm việc, được sắp xếp theo
kích thước.::

$ báo cáo damo sudo wss --range 0 101 10
    # <phần trăm> <wss>
    # target_id 18446632103789443072
    # avr: 107,708 MiB
      0 0 B ZZ0000ZZ
     10 95.328 MiB ZZ0001ZZ
     20 95.332 MiB ZZ0002ZZ
     30 95.340 MIB ZZ0003ZZ
     40 95.387 MIB ZZ0004ZZ
     50 95.387 MIB ZZ0005ZZ
     60 95.398 MIB ZZ0006ZZ
     70 95.398 MIB ZZ0007ZZ
     80 95.504 MIB ZZ0008ZZ
     90 190.703 MIB ZZ0009ZZ
    100 196.875 MIB ZZ0010ZZ

Sử dụng tùy chọn ZZ0000ZZ với lệnh trên, bạn có thể hiển thị cách hoạt động
kích thước cài đặt đã thay đổi theo trình tự thời gian.::

$ sudo damo report wss --range 0 101 10 --sortby time
    # <phần trăm> <wss>
    # target_id 18446632103789443072
    # avr: 107,708 MiB
      0 3.051 MiB ZZ0000ZZ
     10 190.703 MIB ZZ0001ZZ
     20 95.336 MIB ZZ0002ZZ
     30 95.328 MiB ZZ0003ZZ
     40 95.387 MIB ZZ0004ZZ
     50 95.332 MIB ZZ0005ZZ
     60 95.320 MIB ZZ0006ZZ
     70 95.398 MIB ZZ0007ZZ
     80 95.398 MIB ZZ0008ZZ
     90 95.340 MIB ZZ0009ZZ
    100 95.398 MIB ZZ0010ZZ


Quản lý bộ nhớ nhận biết mẫu truy cập dữ liệu
===========================================

Lệnh bên dưới sẽ tạo mọi vùng bộ nhớ có kích thước >=4K chưa được truy cập trong
>=60 giây trong khối lượng công việc của bạn sẽ được hoán đổi. ::

$ sudo damo bắt đầu --damos_access_rate 0 0 --damos_sz_khu vực tối đa 4K \
                      --damos_age tối đa 60 giây --damos_action trang ra \
                      --target_pid <pid khối lượng công việc của bạn>