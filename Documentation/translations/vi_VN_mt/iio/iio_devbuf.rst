.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/iio/iio_devbuf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================================
Bộ đệm thiết bị IIO công nghiệp
=============================

1. Tổng quan
===========

Lõi I/O công nghiệp cung cấp một cách để thu thập dữ liệu liên tục dựa trên
nguồn kích hoạt. Nhiều kênh dữ liệu có thể được đọc cùng một lúc từ
Nút thiết bị ký tự ZZ0000ZZ, do đó giảm tải CPU.

Các thiết bị có hỗ trợ bộ đệm có thêm một thư mục con trong
Hệ thống phân cấp thư mục ZZ0000ZZ, được gọi là bộ đệmY, trong đó
Y mặc định là 0, đối với các thiết bị có một bộ đệm.

2. Thuộc tính bộ đệm
====================

Bộ đệm IIO có thư mục thuộc tính liên quan bên dưới
ZZ0000ZZ. Các thuộc tính được mô tả dưới đây.

ZZ0000ZZ
----------

Thuộc tính Đọc/Ghi cho biết tổng số mẫu dữ liệu (dung lượng)
có thể được lưu trữ bởi bộ đệm.

ZZ0000ZZ
----------

Thuộc tính Đọc/Ghi bắt đầu/dừng chụp bộ đệm. Tập tin này nên
được viết cuối cùng, sau độ dài và lựa chọn các phần tử quét. Viết số khác 0
giá trị có thể dẫn đến lỗi, chẳng hạn như EINVAL, ví dụ: nếu một giá trị không được hỗ trợ
sự kết hợp của các kênh được đưa ra.

ZZ0000ZZ
-------------

Đọc/Ghi thuộc tính số nguyên dương xác định số lần quét tối đa
các yếu tố cần chờ đợi.

Cuộc thăm dò sẽ chặn cho đến khi đạt đến hình mờ.

Việc chặn đọc sẽ đợi cho đến khi đạt mức tối thiểu giữa số lượng đọc được yêu cầu hoặc
hình mờ thấp có sẵn.

Đọc không chặn sẽ lấy các mẫu có sẵn từ bộ đệm ngay cả khi
có ít mẫu hơn mức hình mờ. Điều này cho phép ứng dụng
chặn cuộc thăm dò với thời gian chờ và đọc các mẫu có sẵn sau khi hết thời gian chờ
hết hạn và do đó có sự đảm bảo độ trễ tối đa.

Dữ liệu có sẵn
--------------

Thuộc tính chỉ đọc cho biết byte dữ liệu có sẵn trong bộ đệm. trong
trong trường hợp bộ đệm đầu ra, điều này cho biết lượng không gian trống có sẵn cho
ghi dữ liệu vào. Trong trường hợp bộ đệm đầu vào, điều này cho biết lượng dữ liệu
có sẵn để đọc.

Quét các phần tử
-------------

Thông tin meta liên quan đến dữ liệu kênh được đặt trong bộ đệm được gọi là
một phần tử quét Các thuộc tính của phần tử quét được trình bày dưới đây.

ZZ0000ZZ

Thuộc tính Đọc/Ghi được sử dụng để kích hoạt một kênh. Nếu và chỉ nếu giá trị của nó
khác 0 thì quá trình chụp được kích hoạt sẽ chứa các mẫu dữ liệu cho việc này
kênh.

ZZ0000ZZ

Thuộc tính số nguyên không dấu chỉ đọc xác định vị trí của kênh trong
bộ đệm. Lưu ý những điều này không phụ thuộc vào những gì được kích hoạt và có thể không
tiếp giáp. Do đó, để không gian người dùng thiết lập bố cục đầy đủ, chúng phải được sử dụng
kết hợp với tất cả các thuộc tính _en để thiết lập kênh nào hiện diện,
và các thuộc tính _type có liên quan để thiết lập định dạng lưu trữ dữ liệu.

ZZ0000ZZ

Thuộc tính chỉ đọc chứa mô tả lưu trữ dữ liệu thành phần quét
trong bộ đệm và do đó nó được đọc từ không gian người dùng. định dạng
là [be|le]:[s|u]bit/storagebits[Xrepeat][>>shift], trong đó:

- ZZ0000ZZ hoặc ZZ0001ZZ chỉ định endian lớn hoặc nhỏ.
- ZZ0002ZZ hoặc ZZ0003ZZ chỉ định có dấu (bù 2) hay không dấu.
- ZZ0004ZZ là số bit dữ liệu hợp lệ.
- ZZ0005ZZ là số bit (sau phần đệm) mà nó chiếm trong
  bộ đệm.
- ZZ0006ZZ chỉ định số lần lặp lại bit/bit lưu trữ. Khi
  phần tử lặp lại là 0 hoặc 1 thì giá trị lặp lại sẽ bị bỏ qua.
- ZZ0007ZZ nếu được chỉ định, là ca cần được áp dụng trước
  che giấu các bit không sử dụng.

Ví dụ: trình điều khiển cho gia tốc kế 3 trục có độ phân giải 12 bit trong đó
dữ liệu được lưu trữ trong hai thanh ghi 8 bit như sau ::

7 6 5 4 3 2 1 0
        +---+---+---+---+---+---+---+---+
        ZZ0000ZZD2 ZZ0001ZZD0 ZZ0002ZZ X ZZ0003ZZ X | (LOW byte, địa chỉ 0x06)
        +---+---+---+---+---+---+---+---+

7 6 5 4 3 2 1 0
        +---+---+---+---+---+---+---+---+
        ZZ0000ZZD10ZZ0001ZZD8 ZZ0002ZZD6 ZZ0003ZZD4 | (HIGH byte, địa chỉ 0x07)
        +---+---+---+---+---+---+---+---+

sẽ có loại phần tử quét sau cho mỗi trục:

.. code-block:: bash

        $ cat /sys/bus/iio/devices/iio:device0/buffer0/in_accel_y_type
        le:s12/16>>4

Ứng dụng không gian người dùng sẽ diễn giải các mẫu dữ liệu được đọc từ bộ đệm dưới dạng
Dữ liệu có chữ ký endian nhỏ hai byte, cần dịch chuyển sang phải 4 bit trước
che giấu 12 bit dữ liệu hợp lệ.

Điều đáng nói nữa là dữ liệu trong bộ đệm sẽ được tự nhiên
được căn chỉnh, do đó ứng dụng vùng người dùng phải xử lý vùng đệm tương ứng.

Lấy ví dụ: một trình điều khiển có bốn kênh có mô tả sau:
- kênh0: chỉ số: 0, gõ: be:u16/16>>0
- kênh1: chỉ mục: 1, loại: be:u32/32>>0
- kênh2: chỉ mục: 2, loại: be:u32/32>>0
- kênh3: chỉ mục: 3, loại: be:u64/64>>0

Nếu tất cả các kênh được bật, dữ liệu sẽ được căn chỉnh trong bộ đệm như sau::

0-1 2 3 4-7 8-11 12 13 14 15 16-23 -> số byte bộ đệm
        +------+---+---+-----+------+---+---+---+---+------+
        ZZ0000ZZPADZZ0001ZZCHN_1ZZ0002ZZPADZZ0003ZZPADZZ0004ZZCHN_3|  -> nội dung đệm
        +------+---+---+-----+------+---+---+---+---+------+

Nếu chỉ bật kênh0 và kênh3, dữ liệu sẽ được căn chỉnh theo
đệm như sau::

0-1 2 3 4 5 6 7 8-15 -> số byte đệm
        +------+---+---+---+---+---+---+------+
        ZZ0000ZZPADZZ0001ZZPADZZ0002ZZPADZZ0003ZZCHN_3|  -> nội dung đệm
        +------+---+---+---+---+---+---+------+

Thông thường, dữ liệu được đệm được tìm thấy ở định dạng thô (không được chia tỷ lệ và không có phần bù
được áp dụng), tuy nhiên có những trường hợp góc trong đó dữ liệu được đệm có thể được tìm thấy
ở dạng đã được xử lý. Xin lưu ý rằng những trường hợp góc này không được giải quyết bởi
tài liệu này.

Vui lòng xem Documentation/ABI/testing/sysfs-bus-iio để biết thông tin đầy đủ
mô tả các thuộc tính.