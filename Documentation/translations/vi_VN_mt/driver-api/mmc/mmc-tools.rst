.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/mmc/mmc-tools.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================
Giới thiệu công cụ MMC
======================

Có một công cụ kiểm tra MMC được gọi là mmc-utils, được duy trì bởi Ulf Hansson,
bạn có thể tìm thấy nó ở kho git công khai bên dưới:

ZZ0000ZZ

Chức năng
=========

Các công cụ mmc-utils có thể thực hiện những việc sau:

- In và phân tích dữ liệu extcsd.
 - Xác định trạng thái bảo vệ ghi eMMC.
 - Đặt trạng thái bảo vệ ghi eMMC.
 - Đặt kích thước khu vực dữ liệu eMMC thành 4KB bằng cách tắt mô phỏng.
 - Tạo phân vùng mục đích chung.
 - Kích hoạt khu vực người dùng nâng cao.
 - Cho phép độ tin cậy ghi trên mỗi phân vùng.
 - In phản hồi ra STATUS_SEND (CMD13).
 - Kích hoạt phân vùng khởi động.
 - Đặt điều kiện Boot Bus.
 - Kích hoạt tính năng eMMC BKOPS.
 - Kích hoạt vĩnh viễn tính năng Đặt lại H/W eMMC.
 - Vô hiệu hóa vĩnh viễn tính năng Đặt lại H/W eMMC.
 - Gửi lệnh Vệ sinh.
 - Khóa xác thực chương trình cho thiết bị.
 - Giá trị bộ đếm cho thiết bị vòng/phút sẽ được đọc ra thiết bị xuất chuẩn.
 - Đọc từ thiết bị vòng/phút tới đầu ra.
 - Ghi vào thiết bị vòng/phút từ tập tin dữ liệu.
 - Kích hoạt tính năng bộ đệm eMMC.
 - Tắt tính năng bộ đệm eMMC.
 - In và phân tích dữ liệu CID.
 - In và phân tích dữ liệu CSD.
 - In và phân tích dữ liệu SCR.
