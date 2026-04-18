.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/i2c/i2c-address-translators.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========================
Trình dịch địa chỉ I2C
=======================

Tác giả: Luca Ceresoli <luca@lucaceresoli.net>
Tác giả: Tomi Valkeinen <tomi.valkeinen@ideasonboard.com>

Sự miêu tả
-----------

Trình dịch địa chỉ I2C (ATR) là một thiết bị có cha mẹ phụ thuộc I2C
cổng ("ngược dòng") và các cổng con chính N I2C ("hạ lưu") và
chuyển tiếp các giao dịch từ ngược dòng đến cổng hạ lưu thích hợp
với một địa chỉ nô lệ đã được sửa đổi. Địa chỉ được sử dụng trên xe buýt mẹ là
được gọi là "bí danh" và (có khả năng) khác với tên vật lý
địa chỉ nô lệ của xe buýt con. Việc dịch địa chỉ được thực hiện bởi
phần cứng.

ATR trông tương tự như i2c-mux ngoại trừ:
 - địa chỉ trên xe buýt phụ huynh và xe buýt con có thể khác nhau
 - thông thường không cần chọn cổng con; bí danh được sử dụng trên
   xe buýt mẹ ngụ ý nó

Chức năng ATR có thể được cung cấp bởi một con chip có nhiều tính năng khác.
Kernel i2c-atr cung cấp trình trợ giúp để triển khai ATR trong trình điều khiển.

ATR tạo bộ chuyển đổi "con" I2C mới trên mỗi xe buýt con. Thêm
các thiết bị trên xe buýt con sẽ gọi mã trình điều khiển để chọn
một bí danh có sẵn. Duy trì một nhóm bí danh có sẵn thích hợp
và việc chọn một thiết bị cho mỗi thiết bị mới tùy thuộc vào người triển khai trình điều khiển. các
ATR duy trì một bảng bí danh hiện được gán và sử dụng nó để sửa đổi
tất cả các giao dịch I2C đều hướng đến các thiết bị trên xe buýt con.

Một ví dụ điển hình sau đây.

Cấu trúc liên kết::

Nô lệ X @ 0x10
              .------.   |
  .------.     ZZ0001ZZ---+---- B
  ZZ0002ZZ--A--ZZ0003ZZ
  ZZ0000ZZ------' |
                      Nô lệ Y @ 0x10

Bảng bí danh:

A, B và C là ba bus I2C vật lý, độc lập về điện với
lẫn nhau. ATR nhận các giao dịch được khởi tạo trên bus A và
truyền chúng trên bus B hoặc bus C hoặc không có gì tùy thuộc vào địa chỉ thiết bị
trong giao dịch và dựa trên bảng bí danh.

Bảng bí danh:

.. table::

   ===============   =====
   Client            Alias
   ===============   =====
   X (bus B, 0x10)   0x20
   Y (bus C, 0x10)   0x30
   ===============   =====

Giao dịch:

- Trình điều khiển Slave X yêu cầu giao dịch (trên bộ điều hợp B), địa chỉ nô lệ 0x10
 - Trình điều khiển ATR tìm thấy nô lệ X đang ở trên bus B và có bí danh 0x20, viết lại
   tin nhắn có địa chỉ 0x20, chuyển tiếp tới bộ điều hợp A
 - Giao dịch I2C vật lý trên bus A, địa chỉ nô lệ 0x20
 - Chip ATR phát hiện giao dịch trên địa chỉ 0x20, tìm thấy nó trong bảng,
   truyền bá giao dịch trên bus B với địa chỉ được dịch thành 0x10,
   giữ đồng hồ kéo dài trên xe buýt A chờ trả lời
 - Chip Slave X (trên bus B) phát hiện giao dịch tại vật lý của chính nó
   địa chỉ 0x10 và trả lời bình thường
 - Chip ATR dừng kéo dài đồng hồ và chuyển tiếp phản hồi trên bus A,
   với địa chỉ được dịch về 0x20
 - Trình điều khiển ATR nhận trả lời, viết lại tin nhắn có địa chỉ 0x10
   như ban đầu họ
 - Trình điều khiển Slave X lấy lại tin nhắn[], với câu trả lời và địa chỉ 0x10

Cách sử dụng:

1. Trong trình điều khiển (thường là trong chức năng thăm dò) thêm ATR bằng cách
    gọi i2c_atr_new() chuyển các lệnh gọi lại đính kèm/tách
 2. Khi cuộc gọi lại đính kèm được gọi, hãy chọn một bí danh thích hợp,
    cấu hình nó trong chip và trả về bí danh đã chọn trong
    tham số bí danh_id
 3. Khi cuộc gọi lại tách ra được gọi, hãy giải cấu hình bí danh khỏi
    chip và đặt bí danh trở lại nhóm để sử dụng sau

I2C ATR hàm và cấu trúc dữ liệu
-------------------------------------

.. kernel-doc:: include/linux/i2c-atr.h