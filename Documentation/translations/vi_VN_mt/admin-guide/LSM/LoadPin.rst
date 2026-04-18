.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/LSM/LoadPin.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=======
TảiPin
=======

LoadPin là Mô-đun bảo mật Linux đảm bảo tất cả các tệp được tải trong kernel
(mô-đun, chương trình cơ sở, v.v.) đều bắt nguồn từ cùng một hệ thống tệp, với
kỳ vọng rằng hệ thống tập tin như vậy được hỗ trợ bởi một thiết bị chỉ đọc
chẳng hạn như dm-verity hoặc CDROM. Điều này cho phép các hệ thống đã được xác minh
và/hoặc hệ thống tập tin không thể thay đổi để thực thi việc tải mô-đun và chương trình cơ sở
hạn chế mà không cần phải ký các tập tin riêng lẻ.

LSM có thể được lựa chọn tại thời điểm xây dựng với ZZ0000ZZ và
có thể được điều khiển khi khởi động bằng tùy chọn dòng lệnh kernel
"ZZ0001ZZ". Theo mặc định, nó được bật nhưng có thể bị tắt tại
khởi động ("ZZ0002ZZ").

LoadPin bắt đầu ghim khi thấy tệp đầu tiên được tải. Nếu
chặn thiết bị sao lưu hệ thống tập tin không ở chế độ chỉ đọc, sysctl là
được tạo để chuyển đổi ghim: ZZ0000ZZ. (Có
một hệ thống tập tin có thể thay đổi có nghĩa là việc ghim cũng có thể thay đổi được, nhưng có
sysctl cho phép kiểm tra dễ dàng trên các hệ thống có hệ thống tệp có thể thay đổi.)

Cũng có thể loại trừ các loại tệp cụ thể khỏi LoadPin bằng kernel
tùy chọn dòng lệnh "ZZ0000ZZ". Theo mặc định, tất cả các tập tin đều
được bao gồm, nhưng chúng có thể được loại trừ bằng cách sử dụng tùy chọn dòng lệnh kernel như
là "ZZ0001ZZ". Điều này cho phép sử dụng
các cơ chế khác nhau như ZZ0002ZZ và
ZZ0003ZZ để xác minh mô-đun hạt nhân và hình ảnh hạt nhân trong khi
vẫn sử dụng LoadPin để bảo vệ tính toàn vẹn của các tệp tải kernel khác. các
danh sách đầy đủ các loại tệp hợp lệ có thể được tìm thấy trong ZZ0004ZZ
được xác định trong ZZ0005ZZ.
