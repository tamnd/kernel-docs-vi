.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.2-no-invariants-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/edac/memory_repair.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Kiểm soát sửa chữa bộ nhớ EDAC
==============================

Bản quyền (c) 2024-2025 HiSilicon Limited.

:Tác giả: Shiju Jose <shiju.jose@huawei.com>
:Giấy phép: Giấy phép Tài liệu Miễn phí GNU, Phiên bản 1.2 không có
           Các phần bất biến, Văn bản bìa trước cũng như Văn bản bìa sau.
           (được cấp phép kép theo GPL v2)
:Người đánh giá gốc:

- Viết cho: 6.15

Giới thiệu
------------

Một số thiết bị bộ nhớ hỗ trợ các hoạt động sửa chữa để giải quyết các vấn đề trong
phương tiện bộ nhớ. Sửa chữa gói sau (PPR) và tiết kiệm bộ nhớ là những ví dụ về
những tính năng như vậy.

Sửa chữa gói sau (PPR)
~~~~~~~~~~~~~~~~~~~~~~~~~

Post Package Repair là một hoạt động bảo trì yêu cầu bộ nhớ
thiết bị để thực hiện thao tác sửa chữa trên phương tiện truyền thông của nó. Đó là khả năng tự chữa lành ký ức
tính năng khắc phục vị trí bộ nhớ bị lỗi bằng cách thay thế nó bằng một hàng dự phòng
trong thiết bị DRAM.

Ví dụ: thiết bị bộ nhớ CXL có các thành phần DRAM hỗ trợ PPR
các tính năng thực hiện các hoạt động bảo trì. Các thành phần DRAM hỗ trợ những
các loại chức năng PPR:

- PPR cứng, để sửa chữa hàng vĩnh viễn và
 - PPR mềm, để sửa chữa hàng tạm thời.

PPR mềm nhanh hơn nhiều so với PPR cứng, nhưng việc sửa chữa bị mất sau khi mất điện
chu kỳ.

Dữ liệu có thể không được giữ lại và các yêu cầu bộ nhớ có thể không chính xác
được xử lý trong quá trình sửa chữa. Trong trường hợp đó, hoạt động sửa chữa phải
không được thực thi trong thời gian chạy.

Ví dụ: đối với các thiết bị bộ nhớ CXL, hãy xem phần thông số CXL rev 3.1 [1]_
8.2.9.7.1.1 Hoạt động bảo trì PPR, 8.2.9.7.1.2 Hoạt động bảo trì sPPR
và 8.2.9.7.1.3 Hoạt động bảo trì hPPR để biết thêm chi tiết.

Tiết kiệm bộ nhớ
~~~~~~~~~~~~~~

Tiết kiệm bộ nhớ là một chức năng sửa chữa thay thế một phần bộ nhớ bằng
một phần bộ nhớ chức năng ở mức độ chi tiết cụ thể. Bộ nhớ
tiết kiệm có mức độ chi tiết tiết kiệm bộ đệm/hàng/ngân hàng/xếp hạng. Ví dụ, trong
chế độ tiết kiệm bộ nhớ xếp hạng, một xếp hạng bộ nhớ đóng vai trò dự phòng cho các cấp bậc khác trên
cùng một kênh trong trường hợp chúng bị lỗi.

Thứ hạng dự phòng được giữ để dự trữ và không được sử dụng làm bộ nhớ hoạt động cho đến khi
một lỗi được chỉ báo, với tổng dung lượng dự trữ bị trừ đi
bộ nhớ sẵn có trong hệ thống.

Sau khi vượt qua ngưỡng lỗi trong hệ thống được bảo vệ bằng tính năng tiết kiệm bộ nhớ,
nội dung của thứ hạng DIMM không đạt sẽ được sao chép sang thứ hạng dự phòng. các
thứ hạng không đạt sau đó sẽ bị ngoại tuyến và thứ hạng dự phòng được đặt trực tuyến để sử dụng làm
bộ nhớ hoạt động thay cho thứ hạng bị lỗi.

Ví dụ: thiết bị bộ nhớ CXL có thể hỗ trợ nhiều lớp con khác nhau để tiết kiệm
hoạt động khác nhau tùy theo phạm vi của việc tiết kiệm được thực hiện.

Lớp con tiết kiệm bộ đệm đề cập đến một hành động tiết kiệm có thể thay thế toàn bộ
cacheline. Tiết kiệm hàng được cung cấp như một giải pháp thay thế cho các chức năng tiết kiệm hàng PPR
và phạm vi của nó là một hàng DDR. Tiết kiệm ngân hàng cho phép toàn bộ ngân hàng
được thay thế. Tiết kiệm thứ hạng được định nghĩa là một hoạt động trong đó toàn bộ DDR
cấp bậc được thay thế.

Xem thông số CXL 3.1 [1]_ phần 8.2.9.7.1.4 Bảo trì tiết kiệm bộ nhớ
Hoạt động để biết thêm chi tiết.

.. [1] https://computeexpresslink.org/cxl-specification/

Các trường hợp sử dụng kiểm soát tính năng sửa chữa bộ nhớ chung
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Các tính năng PPR mềm, PPR cứng và tiết kiệm bộ nhớ đều có chung khả năng kiểm soát
   thuộc tính. Do đó, cần có một hệ thống chung, được tiêu chuẩn hóa.
   kiểm soát sửa chữa được hiển thị trong không gian người dùng và được quản trị viên sử dụng,
   kịch bản và công cụ.

2. Khi thiết bị CXL phát hiện lỗi trong thành phần bộ nhớ, nó sẽ thông báo cho
   chủ yếu cần một hoạt động bảo trì sửa chữa bằng cách sử dụng một sự kiện
   ghi lại nơi đặt cờ "cần bảo trì". Bản ghi sự kiện
   chỉ định địa chỉ vật lý của thiết bị (DPA) và các thuộc tính của bộ nhớ
   điều đó cần phải sửa chữa. Kernel báo cáo chung CXL tương ứng
   media hoặc sự kiện theo dõi DRAM tới không gian người dùng và các công cụ không gian người dùng (ví dụ:
   rasdaemon) bắt đầu hoạt động bảo trì sửa chữa để đáp ứng
   yêu cầu thiết bị bằng cách sử dụng điều khiển sửa chữa sysfs.

3. Các công cụ không gian người dùng, chẳng hạn như rasdaemon, yêu cầu thao tác sửa chữa trên bộ nhớ
   khu vực khi bảo trì cần đặt cờ hoặc lỗi bộ nhớ chưa được sửa hoặc
   lỗi bộ nhớ đã sửa vượt quá giá trị ngưỡng sẽ được báo cáo hoặc
   vượt quá cờ ngưỡng lỗi đã sửa được đặt cho bộ nhớ đó.

4. Có thể có nhiều phiên bản PPR/lưu trữ trên mỗi thiết bị bộ nhớ.

5. Người lái xe phải đảm bảo rằng việc sửa chữa trực tiếp là an toàn. Trong các hệ thống nơi bộ nhớ
   các chức năng ánh xạ có thể thay đổi giữa các lần khởi động, một cách tiếp cận vấn đề này là ghi nhật ký
   lỗi bộ nhớ được nhìn thấy trên lần khởi động này để kiểm tra việc sửa chữa bộ nhớ trực tiếp
   yêu cầu.

Hệ thống tập tin
---------------

Các thuộc tính điều khiển của phiên bản sửa chữa bộ nhớ đã đăng ký có thể là
được truy cập trong /sys/bus/edac/devices/<dev-name>/mem_repairX/

sysfs
-----

Các tập tin Sysfs được ghi lại trong
ZZ0000ZZ.

Ví dụ
--------

Việc sử dụng sửa chữa bộ nhớ có dạng như trong ví dụ này:

1. Tiết kiệm bộ nhớ CXL

Tiết kiệm bộ nhớ được định nghĩa là một chức năng sửa chữa thay thế một phần
bộ nhớ với một phần bộ nhớ chức năng ở cùng DPA đó. Lớp con
đối với hoạt động này, việc tiết kiệm dòng bộ đệm/hàng/ngân hàng/xếp hạng sẽ khác nhau về
phạm vi tiết kiệm được thực hiện.

Các hoạt động bảo trì tiết kiệm bộ nhớ có thể được hỗ trợ bởi các thiết bị CXL
triển khai giao thức CXL.mem. Một hoạt động bảo trì tiết kiệm yêu cầu
Thiết bị CXL để thực hiện thao tác sửa chữa trên phương tiện của nó. Ví dụ: CXL
thiết bị có các thành phần DRAM hỗ trợ tính năng tiết kiệm bộ nhớ có thể
thực hiện các hoạt động bảo trì tiết kiệm.

2. Sửa chữa gói bài mềm bộ nhớ CXL (sPPR)

Các hoạt động bảo trì Sửa chữa sau gói (PPR) có thể được CXL hỗ trợ
các thiết bị triển khai giao thức CXL.mem. Hoạt động bảo trì PPR
yêu cầu thiết bị CXL thực hiện thao tác sửa chữa trên phương tiện của nó.
Ví dụ: thiết bị CXL có các thành phần DRAM hỗ trợ các tính năng PPR
có thể thực hiện các hoạt động Bảo trì PPR. PPR mềm (sPPR) là tạm thời
sửa chữa hàng. Soft PPR có thể nhanh hơn nhưng sửa chữa bị mất nguồn
chu kỳ.

Các tệp Sysfs để sửa chữa bộ nhớ được ghi lại trong
ZZ0000ZZ