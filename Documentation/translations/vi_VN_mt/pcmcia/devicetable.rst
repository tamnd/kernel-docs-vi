.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/pcmcia/devicetable.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============
Bảng thiết bị
============

Việc kết nối thiết bị PCMCIA với trình điều khiển được thực hiện bằng cách sử dụng một hoặc nhiều
tiêu chí sau:

- ID nhà sản xuất
- ID thẻ
- chuỗi ID sản phẩm _và_ giá trị băm của các chuỗi này
- ID chức năng
- chức năng thiết bị (thực tế và giả)

Bạn nên sử dụng các trình trợ giúp trong include/pcmcia/device_id.h để tạo
các mục struct pcmcia_device_id[] khớp với thiết bị với trình điều khiển.

Nếu bạn muốn khớp chuỗi ID sản phẩm, bạn cũng cần phải chuyển crc32
băm của chuỗi vào macro, ví dụ: nếu bạn muốn khớp ID sản phẩm
chuỗi 1, bạn cần sử dụng

PCMCIA_DEVICE_PROD_ID1("some_string", 0x(hash_of_some_string)),

Nếu hàm băm không chính xác, kernel sẽ thông báo cho bạn về điều này trong "dmesg"
khi khởi tạo mô-đun và cho bạn biết hàm băm chính xác.

Bạn có thể xác định hàm băm của chuỗi ID sản phẩm bằng cách trích xuất tệp
"modalias" trong thư mục sysfs của thiết bị PCMCIA. Nó tạo ra một chuỗi
ở dạng sau:
pcmcia:m0149cC1ABf06pfn00fn00pa725B842DpbF1EFEE84pc0877B627pd00000000

Giá trị hex sau "pa" là hàm băm của chuỗi ID sản phẩm 1, sau "pb" cho
chuỗi 2, v.v.

Ngoài ra, bạn có thể sử dụng crc32hash (xem tools/pcmcia/crc32hash.c)
để xác định hàm băm crc32.  Đơn giản chỉ cần chuyển chuỗi bạn muốn đánh giá
làm đối số cho chương trình này, ví dụ:
$ tools/pcmcia/crc32hash "Tốc độ kép"
