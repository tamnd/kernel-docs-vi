.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/leds/leds-class-multicolor.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
Xử lý LED nhiều màu trong Linux
========================================

Sự miêu tả
===========
Lớp nhiều màu nhóm các đèn LED đơn sắc và cho phép điều khiển hai
các khía cạnh của màu kết hợp cuối cùng: màu sắc và độ sáng. Cái trước là
được điều khiển thông qua tệp mảng multi_intensity và tệp sau được điều khiển
thông qua tập tin độ sáng.

Kiểm soát lớp nhiều màu
========================
Lớp nhiều màu trình bày các tệp nhóm các màu dưới dạng chỉ mục trong một
mảng.  Các tệp này là con dưới nút cha LED được tạo bởi
khung led_class.  Khung led_class được ghi lại trong led-class.rst
trong thư mục tài liệu này.

Mỗi LED màu sẽ được lập chỉ mục trong các tệp ZZ0000ZZ. Thứ tự của
màu sắc sẽ tùy ý. Có thể đọc tệp ZZ0001ZZ để xác định
tên màu thành giá trị được lập chỉ mục.

Tệp ZZ0000ZZ là một mảng chứa danh sách chuỗi các màu như
chúng được xác định trong mỗi tệp mảng ZZ0001ZZ.

ZZ0000ZZ là một mảng có thể được đọc hoặc ghi cho
cường độ màu riêng biệt.  Tất cả các phần tử trong mảng này phải được viết bằng
để cập nhật cường độ màu LED.

Ví dụ về bố cục thư mục
========================
.. code-block:: console

    root:/sys/class/leds/multicolor:status# ls -lR
    -rw-r--r--    1 root     root          4096 Oct 19 16:16 brightness
    -r--r--r--    1 root     root          4096 Oct 19 16:16 max_brightness
    -r--r--r--    1 root     root          4096 Oct 19 16:16 multi_index
    -rw-r--r--    1 root     root          4096 Oct 19 16:16 multi_intensity

..

Kiểm soát độ sáng lớp nhiều màu
===================================
Mức độ sáng cho mỗi LED được tính dựa trên màu LED
cài đặt cường độ chia cho cài đặt độ sáng tối đa chung nhân với
độ sáng được yêu cầu.

ZZ0000ZZ

Ví dụ:
Trước tiên, người dùng ghi tệp multi_intensity với các mức độ sáng
đối với mỗi LED cần thiết để đạt được đầu ra màu nhất định từ
nhóm LED nhiều màu.

.. code-block:: console

    # cat /sys/class/leds/multicolor:status/multi_index
    green blue red

    # echo 43 226 138 > /sys/class/leds/multicolor:status/multi_intensity

    red -
    	intensity = 138
    	max_brightness = 255
    green -
    	intensity = 43
    	max_brightness = 255
    blue -
    	intensity = 226
    	max_brightness = 255

..

Người dùng có thể kiểm soát độ sáng của nhóm LED nhiều màu đó bằng cách viết
kiểm soát 'độ sáng' toàn cầu.  Giả sử max_brightness là 255 người dùng
có thể muốn làm mờ nhóm màu LED xuống một nửa.  Người dùng sẽ viết một giá trị
128 vào tệp độ sáng chung thì các giá trị được ghi cho mỗi LED sẽ là
được điều chỉnh dựa trên giá trị này.

.. code-block:: console

    # cat /sys/class/leds/multicolor:status/max_brightness
    255
    # echo 128 > /sys/class/leds/multicolor:status/brightness

..

.. code-block:: none

    adjusted_red_value = 128 * 138/255 = 69
    adjusted_green_value = 128 * 43/255 = 21
    adjusted_blue_value = 128 * 226/255 = 113

..

Đọc tệp độ sáng chung sẽ trả về giá trị độ sáng hiện tại của
nhóm màu LED.

.. code-block:: console

    # cat /sys/class/leds/multicolor:status/brightness
    128

..