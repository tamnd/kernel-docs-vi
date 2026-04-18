.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/firmware/introduction.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============
Giới thiệu
============

Phần sụn API cho phép mã hạt nhân yêu cầu các tệp được yêu cầu
đối với chức năng từ không gian người dùng, cách sử dụng sẽ khác nhau:

* Vi mã cho lỗi CPU
* Phần mềm trình điều khiển thiết bị, cần phải được tải vào thiết bị
  vi điều khiển
* Dữ liệu thông tin trình điều khiển thiết bị (dữ liệu hiệu chuẩn, ghi đè EEPROM),
  một số trong đó có thể hoàn toàn tùy chọn.

Các loại yêu cầu phần sụn
==========================

Có hai loại cuộc gọi:

* Đồng bộ
* Không đồng bộ

Cái nào bạn sử dụng khác nhau tùy thuộc vào yêu cầu của bạn, quy tắc chung
tuy nhiên bạn nên cố gắng sử dụng các API không đồng bộ trừ khi bạn cũng
đang sử dụng các cơ chế khởi tạo không đồng bộ sẽ không
dừng hoặc trì hoãn khởi động. Ngay cả khi tải firmware không mất nhiều thời gian
có thể xử lý phần sụn và điều này vẫn có thể trì hoãn việc khởi động hoặc khởi tạo,
vì các cơ chế như thăm dò không đồng bộ có thể giúp bổ sung trình điều khiển.
