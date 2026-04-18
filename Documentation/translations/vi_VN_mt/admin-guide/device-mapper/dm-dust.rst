.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/dm-dust.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

dm-bụi
=======

Mục tiêu này mô phỏng hành vi của các thành phần xấu một cách tùy ý
vị trí và khả năng cho phép mô phỏng các lỗi
vào một thời điểm tùy ý.

Mục tiêu này hoạt động tương tự như mục tiêu tuyến tính.  Tại một thời điểm nhất định,
người dùng có thể gửi tin nhắn đến mục tiêu để bắt đầu không đọc được
yêu cầu trên các khối cụ thể (để mô phỏng hành vi của ổ cứng
ổ đĩa có thành phần xấu).

Khi hành vi lỗi được kích hoạt (tức là: khi đầu ra của
"trạng thái dmsetup" hiển thị "fail_read_on_bad_block"), số lần đọc khối
trong "danh sách khối xấu" sẽ không thành công với EIO ("Lỗi đầu vào/đầu ra").

Việc ghi các khối vào "danh sách khối xấu sẽ dẫn đến kết quả như sau:

1. Xóa khối khỏi "danh sách khối xấu".
2. Hoàn tất việc viết thành công.

Điều này mô phỏng hành vi "ánh xạ lại khu vực" của một ổ đĩa bị lỗi
các lĩnh vực.

Thông thường, một ổ đĩa gặp phải các thành phần xấu rất có thể sẽ
gặp phải nhiều thành phần xấu hơn, tại một thời điểm hoặc địa điểm không xác định.
Với dm-dust, người dùng có thể sử dụng "addbadblock" và "removebadblock"
thông báo để thêm các khối xấu tùy ý tại các vị trí mới và
các thông báo "bật" và "tắt" để điều chỉnh trạng thái xem
"khối xấu" được định cấu hình sẽ bị coi là xấu hoặc bị bỏ qua.
Điều này cho phép ghi trước dữ liệu thử nghiệm và siêu dữ liệu trước khi
mô phỏng một sự kiện "thất bại" khi các thành phần xấu bắt đầu xuất hiện.

Tham số bảng
----------------
<device_path> <offset> <blksz>

Các thông số bắt buộc:
    <device_path>:
        Đường dẫn đến thiết bị khối.

<bù đắp>:
        Bù đắp cho vùng dữ liệu từ đầu device_path

<blksz>:
        Kích thước khối tính bằng byte

(tối thiểu 512, tối đa 1073741824, phải là lũy thừa của 2)

Hướng dẫn sử dụng
------------------

Đầu tiên, tìm kích thước (theo cung 512 byte) của thiết bị sẽ được sử dụng ::

$ sudo blockdev --getsz /dev/vdb1
        33552384

Tạo thiết bị dm-dust:
(Đối với thiết bị có kích thước khối 512 byte)

::

$ sudo dmsetup tạo dust1 --table '0 33552384 bụi /dev/vdb1 0 512'

(Đối với thiết bị có kích thước khối 4096 byte)

::

$ sudo dmsetup tạo dust1 --table '0 33552384 bụi /dev/vdb1 0 4096'

Kiểm tra trạng thái của hành vi đọc ("bỏ qua" cho biết rằng tất cả I/O
sẽ được chuyển qua thiết bị cơ bản; "dài dòng" chỉ ra rằng
Các bổ sung, loại bỏ và ánh xạ lại khối xấu sẽ được ghi lại bằng lời nói)::

$ sudo dmsetup trạng thái bụi1
        0 33552384 bụi 252:17 bỏ qua dài dòng

$ sudo dd if=/dev/mapper/dust1 of=/dev/null bs=512 count=128 iflag=direct
        128+0 bản ghi trong
        128+0 hồ sơ hết

$ sudo dd if=/dev/zero of=/dev/mapper/dust1 bs=512 count=128 oflag=direct
        128+0 bản ghi trong
        128+0 hồ sơ hết

Thêm và loại bỏ các khối xấu
------------------------------

Bất cứ lúc nào (ví dụ: liệu thiết bị có mô phỏng "khối xấu" hay không
được bật hoặc tắt), các khối xấu có thể được thêm vào hoặc xóa khỏi
thiết bị thông qua thông báo "addbadblock" và "removebadblock"::

$ sudo dmsetup tin nhắn dust1 0 addbadblock 60
        kernel: device-mapper: dust: badblock được thêm vào khối 60

$ sudo dmsetup tin nhắn dust1 0 addbadblock 67
        kernel: device-mapper: dust: badblock được thêm vào khối 67

$ sudo dmsetup tin nhắn dust1 0 addbadblock 72
        kernel: device-mapper: dust: badblock được thêm vào ở khối 72

Các khối xấu này sẽ được lưu trữ trong "danh sách khối xấu".
Khi thiết bị ở chế độ "bỏ qua", việc đọc và ghi sẽ thành công::

$ sudo dmsetup trạng thái bụi1
        0 33552384 bụi 252:17 bỏ qua

Kích hoạt lỗi đọc khối
----------------------------

Để kích hoạt hành vi "không đọc được trên khối xấu", hãy gửi thông báo "bật"::

$ sudo dmsetup tin nhắn dust1 0 kích hoạt
        kernel: device-mapper: dust: cho phép đọc lỗi trên các thành phần xấu

$ sudo dmsetup trạng thái bụi1
        0 33552384 bụi 252:17 failed_read_on_bad_block

Với thiết bị ở chế độ "không đọc được trên khối xấu", cố gắng đọc một
khối sẽ gặp "Lỗi đầu vào/đầu ra"::

$ sudo dd if=/dev/mapper/dust1 of=/dev/null bs=512 count=1 Skip=67 iflag=direct
        dd: lỗi đọc '/dev/mapper/dust1': Lỗi đầu vào/đầu ra
        Bản ghi 0+0 trong
        0+0 ghi lại
        Đã sao chép 0 byte, 0,00040651 giây, 0,0 kB/s

...and writing to the bad blocks will remove the blocks from the list,
do đó mô phỏng hành vi "remap" của ổ đĩa cứng::

$ sudo dd if=/dev/zero of=/dev/mapper/dust1 bs=512 count=128 oflag=direct
        128+0 bản ghi trong
        128+0 hồ sơ hết

kernel: device-mapper: dust: khối 60 bị xóa khỏi danh sách badblocklist bằng cách ghi
        kernel: device-mapper: dust: khối 67 bị xóa khỏi danh sách badblocklist bằng cách ghi
        kernel: device-mapper: dust: khối 72 bị xóa khỏi danh sách badblocklist bằng cách ghi
        kernel: device-mapper: dust: khối 87 bị xóa khỏi danh sách badblocklist bằng cách ghi

Xử lý lỗi thêm/xóa khối xấu
-----------------------------------

Cố gắng thêm một khối xấu đã tồn tại trong danh sách sẽ
dẫn đến lỗi "Đối số không hợp lệ" cũng như thông báo hữu ích::

$ sudo dmsetup tin nhắn dust1 0 addbadblock 88
        trình ánh xạ thiết bị: thông báo ioctl trên dust1 không thành công: Đối số không hợp lệ
        kernel: device-mapper: dust: block 88 đã có trong badblocklist

Cố gắng loại bỏ một khối xấu không tồn tại trong danh sách sẽ
dẫn đến lỗi "Đối số không hợp lệ" cũng như thông báo hữu ích::

$ sudo dmsetup tin nhắn dust1 0 Removebadblock 87
        trình ánh xạ thiết bị: thông báo ioctl trên dust1 không thành công: Đối số không hợp lệ
        kernel: device-mapper: dust: không tìm thấy khối 87 trong danh sách xấu

Đếm số lượng bad block trong danh sách bad block
-------------------------------------------------------

Để đếm số khối xấu được cấu hình trong thiết bị, hãy chạy lệnh
lệnh thông báo sau::

$ sudo dmsetup tin nhắn dust1 0 countbadblocks

Một thông báo sẽ in với số lượng khối xấu hiện tại
được cấu hình trên thiết bị::

countbadblocks: tìm thấy 895 badblocks

Truy vấn các khối xấu cụ thể
--------------------------------

Để tìm hiểu xem một khối cụ thể có nằm trong danh sách khối xấu hay không, hãy chạy lệnh
lệnh thông báo sau::

$ sudo dmsetup tin nhắn dust1 0 queryblock 72

Thông báo sau sẽ được in nếu khối nằm trong danh sách::

dust_query_block: khối 72 được tìm thấy trong danh sách xấu

Thông báo sau sẽ được in nếu khối không có trong danh sách::

dust_query_block: không tìm thấy khối 72 trong danh sách badblocklist

Lệnh thông báo "queryblock" sẽ hoạt động ở cả chế độ "đã bật"
và chế độ "vô hiệu hóa", cho phép xác minh xem một khối có
sẽ bị coi là "xấu" mà không cần phải cấp I/O cho thiết bị,
hoặc phải "kích hoạt" mô phỏng khối xấu.

Xóa danh sách chặn xấu
---------------------------

Để xóa danh sách khối xấu (không cần phải chạy riêng lẻ
lệnh thông báo "removebadblock" cho mọi khối), hãy chạy
lệnh thông báo sau::

$ sudo dmsetup tin nhắn dust1 0 clearbadblocks

Sau khi xóa danh sách chặn xấu, thông báo sau sẽ xuất hiện::

dust_clear_badblocks: badblocks đã được xóa

Nếu không có khối xấu nào cần xóa, thông báo sau sẽ
xuất hiện::

dust_clear_badblocks: không tìm thấy badblocks

Liệt kê danh sách chặn xấu
--------------------------

Để liệt kê tất cả các khối xấu trong danh sách khối xấu (sử dụng thiết bị mẫu
với khối 1 và 2 trong danh sách khối xấu), hãy chạy thông báo sau
lệnh::

$ sudo dmsetup tin nhắn dust1 0 listbadblocks
        1
        2

Nếu không có khối xấu nào trong danh sách khối xấu, lệnh sẽ
thực thi mà không có đầu ra::

$ sudo dmsetup tin nhắn dust1 0 listbadblocks

Danh sách lệnh tin nhắn
-----------------------

Dưới đây là danh sách các tin nhắn có thể được gửi đến thiết bị bụi:

Thao tác trên các khối (yêu cầu đối số <blknum>)::

addbadblock <blknum>
        khối truy vấn <blknum>
        gỡ bỏ chặn <blknum>

...where <blknum> is a block number within range of the device
(tương ứng với kích thước khối của thiết bị.)

Các lệnh thông báo đối số đơn::

đếm số khối
        Clearbadblocks
        danh sách badblocks
        vô hiệu hóa
        kích hoạt
        yên tĩnh

Xóa thiết bị
--------------

Khi hoàn tất, hãy tháo thiết bị bằng lệnh "dmsetup Remove" ::

$ sudo dmsetup loại bỏ bụi1

Chế độ im lặng
--------------

Khi chạy thử với nhiều khối xấu, có thể nên tránh
ghi nhật ký quá mức (từ các khối xấu được thêm vào, xóa hoặc "ánh xạ lại").
Điều này có thể được thực hiện bằng cách bật "chế độ im lặng" qua thông báo sau::

$ sudo dmsetup tin nhắn dust1 0 yên tĩnh

Điều này sẽ ngăn chặn các thông điệp tường trình thêm/xóa/xóa bằng cách ghi
hoạt động.  Ghi nhật ký tin nhắn từ "countbadblocks" hoặc "queryblock"
lệnh thông báo vẫn sẽ in ở chế độ im lặng.

Có thể xem trạng thái của chế độ im lặng bằng cách chạy "dmsetup status"::

$ sudo dmsetup trạng thái bụi1
        0 33552384 bụi 252:17 failed_read_on_bad_block yên tĩnh

Để tắt chế độ im lặng, hãy gửi lại tin nhắn "im lặng"::

$ sudo dmsetup tin nhắn dust1 0 yên tĩnh

$ sudo dmsetup trạng thái bụi1
        0 33552384 bụi 252:17 failed_read_on_bad_block dài dòng

(Sự hiện diện của "tiết tiết" biểu thị việc ghi nhật ký bình thường.)

"Tại sao không...?"
-------------------

scsi_debug có chế độ "lỗi trung bình" có thể không đọc được trên một
khu vực được chỉ định (khu vực 0x1234, được mã hóa cứng trong mã nguồn), nhưng
nó sử dụng RAM để lưu trữ liên tục, điều này làm giảm đáng kể
kích thước thiết bị tiềm năng.

dm-flakey không thành công tất cả I/O từ tất cả các vị trí khối tại một thời điểm được chỉ định
tần số chứ không phải một thời điểm nhất định.

Khi ổ đĩa cứng xuất hiện một khu vực xấu, hãy đọc khu vực đó
thiết bị bị lỗi, thường dẫn đến mã lỗi EIO
("Lỗi I/O") hoặc ENODATA ("Không có dữ liệu").  Tuy nhiên, một văn bản cho
lĩnh vực này có thể thành công và dẫn đến lĩnh vực này trở nên dễ đọc
sau khi bộ điều khiển thiết bị không còn gặp lỗi khi đọc
ngành (hoặc sau khi tái phân bổ ngành).  Tuy nhiên, có thể có
là các thành phần xấu xảy ra trên thiết bị trong tương lai, theo một cách khác,
vị trí không thể đoán trước.

Mục tiêu này tìm cách cung cấp một thiết bị có thể thể hiện hành vi
của một khu vực xấu tại một vị trí khu vực đã biết, tại một thời điểm đã biết, dựa trên
trên một thiết bị lưu trữ lớn (ít nhất hàng chục gigabyte, không chiếm
bộ nhớ hệ thống).
