.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/btrfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====
BTRFS
=====

Btrfs là một bản sao trên hệ thống tập tin ghi dành cho Linux nhằm mục đích triển khai nâng cao
đồng thời tập trung vào khả năng chịu lỗi, sửa chữa và quản trị dễ dàng.
Được phát triển chung bởi một số công ty, được cấp phép theo GPL và mở cho
đóng góp của bất kỳ ai.

Các tính năng chính của Btrfs bao gồm:

* Lưu trữ tệp dựa trên mức độ (kích thước tệp tối đa 2 ^ 64)
    * Đóng gói các tập tin nhỏ một cách hiệu quả về mặt không gian
    * Thư mục được lập chỉ mục hiệu quả về không gian
    * Phân bổ inode động
    * Ảnh chụp nhanh có thể ghi
    * Subvolumes (rễ hệ thống tập tin nội bộ riêng biệt)
    * Phản chiếu và phân loại cấp độ đối tượng
    * Tổng kiểm tra dữ liệu và siêu dữ liệu (có sẵn nhiều thuật toán)
    * Nén (có sẵn nhiều thuật toán)
    * Liên kết lại, chống trùng lặp
    * Chà (xác minh tổng kiểm tra trực tuyến)
    * Nhóm hạn ngạch phân cấp (hỗ trợ khối lượng phụ và ảnh chụp nhanh)
    * Tích hợp hỗ trợ nhiều thiết bị, với một số thuật toán đột kích
    * Kiểm tra hệ thống tập tin ngoại tuyến
    * Sao lưu gia tăng hiệu quả và phản chiếu FS (gửi/nhận)
    * Cắt/bỏ
    * Chống phân mảnh hệ thống tập tin trực tuyến
    * Hỗ trợ tập tin hoán đổi
    * Chế độ khoanh vùng
    * Xác minh siêu dữ liệu đọc/ghi
    * Thay đổi kích thước trực tuyến (thu nhỏ, tăng trưởng)

Để biết thêm thông tin, vui lòng tham khảo trang tài liệu hoặc wiki

ZZ0000ZZ


duy trì thông tin về các nhiệm vụ quản trị, thường xuyên được hỏi
câu hỏi, trường hợp sử dụng, tùy chọn gắn kết, nhật ký thay đổi dễ hiểu, tính năng,
trang hướng dẫn sử dụng, kho mã nguồn, danh bạ, v.v.