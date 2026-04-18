.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/mtd/spi-nor.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Khung SPI NOR
=================

Cách đề xuất bổ sung flash mới
-----------------------------------

Hầu hết các đèn flash SPI NOR đều tuân thủ JEDEC JESD216
Tiêu chuẩn Thông số có thể phát hiện được của Flash nối tiếp (SFDP). SFDP mô tả
khả năng chức năng và tính năng của các thiết bị flash nối tiếp trong một
bộ tiêu chuẩn của các bảng tham số chỉ đọc nội bộ.

Trình điều khiển SPI NOR truy vấn các bảng SFDP để xác định
các thông số và cài đặt của flash. Nếu đèn flash xác định các bảng SFDP
có thể bạn sẽ không cần mục flash nào cả, thay vào đó
dựa vào trình điều khiển flash chung để thăm dò flash chỉ dựa trên
trên dữ liệu SFDP của nó. Tất cả những gì người ta phải làm là chỉ định "jedec,spi-nor"
tương thích trong cây thiết bị.

Tuy nhiên, có những trường hợp bạn cần xác định đèn flash rõ ràng
nhập cảnh. Điều này thường xảy ra khi đèn flash có cài đặt hoặc hỗ trợ
không nằm trong các bảng SFDP (ví dụ: Bảo vệ khối) hoặc
khi đèn flash chứa dữ liệu SFDP bị sai lệch. Nếu sau này, người ta cần
triển khai các móc ZZ0000ZZ để sửa đổi SFDP
các thông số có giá trị đúng.

Yêu cầu kiểm tra tối thiểu
-----------------------------

Thực hiện tất cả các bài kiểm tra từ bên dưới và dán chúng vào phần nhận xét của cam kết
phần, sau điểm đánh dấu ZZ0000ZZ.

1) Chỉ định bộ điều khiển mà bạn đã sử dụng để kiểm tra đèn flash và chỉ định
   tần suất sử dụng đèn flash, ví dụ::

Đèn flash này được gắn trên bảng X và đã được thử nghiệm ở Y
    tần số bằng bộ điều khiển SPI Z (tương thích).

2) Kết xuất các mục nhập sysfs và in tổng kiểm tra md5/sha1/sha256 SFDP::

root@1:~# cat /sys/bus/spi/devices/spi0.0/spi-nor/partname
    sst26vf064b
    root@1:~# cat /sys/bus/spi/devices/spi0.0/spi-nor/jedec_id
    bạn trai2643
    root@1:~# cat /sys/bus/spi/devices/spi0.0/spi-nor/nhà sản xuất
    sst
    root@1:~# xxd -p /sys/bus/spi/devices/spi0.0/spi-nor/sfdp
    53464450060102ff00060110300000ff81000106000100ffbf0001180002
    0001ffffffffffffffffffffffffffffffffffd20f1ffffffff0344eb086b
    083b80bbfeffffffffff00ffffff440b0c200dd80fd810d820914824806f
    1d81ed0f773830b030b0f7ffffff29c25cfff030c080ffffffffffffffff
    ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
    ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
    ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
    ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
    ffffffffffffffffffffffffffffffffff0004fff37f0000f57f0000f9ff
    7d00f57f0000f37f0000ffffffffffffffffffffffffffffffffffffffff
    ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
    ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
    ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
    ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
    ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
    ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
    ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
    ffffbf2643ffb95ffdff30f260f332ff0a122346ff0f19320f1919ffffff
    ffffffff00669938ff05013506040232b03072428de89888a585c09faf5a
    ffff06ec060c0003080bffffffffff07ffff0202ff060300fdfd040700fc
    0300fefe0202070e
    root@1:~# sha256sum /sys/bus/spi/devices/spi0.0/spi-nor/sfdp
    428f34d0461876f189ac97f93e68a05fa6428c6650b3b7baf736a921e5898ed1 /sys/bus/spi/devices/spi0.0/spi-nor/sfdp

Vui lòng kết xuất các bảng SFDP bằng ZZ0000ZZ. Nó cho phép chúng tôi làm
   hoạt động ngược lại và chuyển đổi hexdump thành nhị phân với
   ZZ0001ZZ. Việc kết xuất dữ liệu SFDP bằng ZZ0002ZZ được chấp nhận,
   nhưng ít được mong muốn hơn.

3) Kết xuất dữ liệu gỡ lỗi::

root@1:~# cat /sys/kernel/debug/spi-nor/spi0.0/capabilities
    Hỗ trợ chế độ đọc bằng đèn flash
     1S-1S-1S
      mã lệnh 0x03
      chu kỳ chế độ 0
      chu kỳ giả 0
     1S-1S-1S (đọc nhanh)
      mã lệnh 0x0b
      chu kỳ chế độ 0
      chu kỳ giả 8
     1S-1S-2S
      mã lệnh 0x3b
      chu kỳ chế độ 0
      chu kỳ giả 8
     1S-2S-2S
      mã lệnh 0xbb
      chu kỳ chế độ 4
      chu kỳ giả 0
     1S-1S-4S
      mã lệnh 0x6b
      chu kỳ chế độ 0
      chu kỳ giả 8
     1S-4S-4S
      mã lệnh 0xeb
      chu kỳ chế độ 2
      chu kỳ giả 4
     4S-4S-4S
      mã lệnh 0x0b
      chu kỳ chế độ 2
      chu kỳ giả 4

Các chế độ chương trình trang được hỗ trợ bằng đèn flash
     1S-1S-1S
      mã lệnh 0x02

root@1:~# cat /sys/kernel/debug/spi-nor/spi0.0/params
    tên sst26vf064b
    id bạn trai 26 43 bạn trai 26 43
    kích thước 8,00 MiB
    viết cỡ 1
    kích thước trang 256
    địa chỉ nbyte 3
    cờ HAS_LOCK ZZ0000ZZ SOFT_RESET | SWP_IS_VOLATILE

các mã lệnh
     đọc 0xeb
      chu kỳ giả 6
     xóa 0x20
     chương trình 0x02
     Phần mở rộng 8D không có

giao thức
     đọc 1S-4S-4S
     viết 1S-1S-1S
     đăng ký 1S-1S-1S

lệnh xóa
     20 (4,00 KiB) [0]
     d8 (8,00 KiB) [1]
     d8 (32,0 KiB) [2]
     d8 (64,0 KiB) [3]
     c7 (8,00 MiB)

bản đồ ngành
     vùng (ở dạng hex) cờ ZZ0000ZZ
     ----------+--------------+----------
     00000000-00007fff ZZ0001ZZ
     00008000-0000ffff ZZ0002ZZ
     00010000-007effff ZZ0003ZZ
     007f0000-007f7fff ZZ0004ZZ
     007f8000-007fffff ZZ0005ZZ

4) Sử dụng ZZ0000ZZ
   và xác minh rằng các thao tác xóa, đọc và phân trang của chương trình hoạt động tốt::

root@1:~# dd if=/dev/urandom of=./spi_test bs=1M count=2
    bản ghi 2+0 trong
    2+0 hồ sơ hết
    Đã sao chép 2097152 byte (2,1 MB, 2,0 MiB), 0,848566 giây, 2,5 MB/s

root@1:~# mtd_debug xóa /dev/mtd0 0 2097152
    Đã xóa 2097152 byte khỏi địa chỉ 0x00000000 trong flash

root@1:~# mtd_debug đọc /dev/mtd0 0 2097152 spi_read
    Đã sao chép 2097152 byte từ địa chỉ 0x00000000 trong flash sang spi_read

root@1:~# hexdump spi_read
    0000000 ffff ffff ffff ffff ffff ffff ffff ffff
    *
    0200000

root@1:~# sha256sum spi_read
    4bda3a28f4ffe603c0ec1258c0034d65a1a0d35ab7bd523a834608adabf03cc5 spi_read

root@1:~# mtd_debug viết /dev/mtd0 0 2097152 spi_test
    Đã sao chép 2097152 byte từ spi_test sang địa chỉ 0x00000000 trong flash

root@1:~# mtd_debug đọc /dev/mtd0 0 2097152 spi_read
    Đã sao chép 2097152 byte từ địa chỉ 0x00000000 trong flash sang spi_read

root@1:~# sha256sum spi*
    c444216a6ba2a4a66cccd60a0dd062bce4b865dd52b200ef5e21838c4b899ac8 spi_read
    c444216a6ba2a4a66cccd60a0dd062bce4b865dd52b200ef5e21838c4b899ac8 spi_test

Nếu đèn flash bị xóa theo mặc định và lần xóa trước đó bị bỏ qua,
   chúng tôi sẽ không bắt được nó, do đó hãy kiểm tra lại việc xóa::

root@1:~# mtd_debug xóa /dev/mtd0 0 2097152
    Đã xóa 2097152 byte khỏi địa chỉ 0x00000000 trong flash

root@1:~# mtd_debug đọc /dev/mtd0 0 2097152 spi_read
    Đã sao chép 2097152 byte từ địa chỉ 0x00000000 trong flash sang spi_read

root@1:~# sha256sum spi*
    4bda3a28f4ffe603c0ec1258c0034d65a1a0d35ab7bd523a834608adabf03cc5 spi_read
    c444216a6ba2a4a66cccd60a0dd062bce4b865dd52b200ef5e21838c4b899ac8 spi_test

Kết xuất một số dữ liệu liên quan khác::

root@1:~# mtd_debug thông tin/dev/mtd0
    mtd.type = MTD_NORFLASH
    mtd.flags = MTD_CAP_NORFLASH
    mtd.size = 8388608 (8M)
    mtd.erasesize = 4096 (4K)
    mtd.writesize = 1
    mtd.oobsize = 0
    vùng = 0
