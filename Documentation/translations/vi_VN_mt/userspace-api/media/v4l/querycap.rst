.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/querycap.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _querycap:

**********************
Khả năng truy vấn
*********************

Vì V4L2 bao gồm nhiều loại thiết bị nên không phải tất cả các khía cạnh của API
đều được áp dụng như nhau cho tất cả các loại thiết bị. Hơn nữa các thiết bị của
cùng loại có khả năng khác nhau và đặc điểm kỹ thuật này cho phép
lược bỏ một số phần phức tạp và ít quan trọng hơn của API.

ZZ0000ZZ ioctl có sẵn cho
kiểm tra xem thiết bị hạt nhân có tương thích với thông số kỹ thuật này hay không và
truy vấn ZZ0001ZZ và ZZ0002ZZ
được hỗ trợ bởi thiết bị.

Bắt đầu với phiên bản kernel 3.1, ZZ0000ZZ
sẽ trả về phiên bản V4L2 API được trình điều khiển sử dụng, nói chung
phù hợp với phiên bản Kernel. Không có nhu cầu sử dụng
ZZ0001ZZ để kiểm tra xem một ioctl cụ thể
được hỗ trợ, lõi V4L2 hiện trả về ZZ0002ZZ nếu trình điều khiển không
cung cấp hỗ trợ cho ioctl.

Các tính năng khác có thể được truy vấn bằng cách gọi ioctl tương ứng, ví dụ:
ví dụ ZZ0000ZZ để tìm hiểu về
số lượng, chủng loại và tên các đầu nối video trên thiết bị. Mặc dù
sự trừu tượng hóa là mục tiêu chính của API này,
ZZ0001ZZ ioctl cũng cho phép trình điều khiển
các ứng dụng cụ thể để xác định trình điều khiển một cách đáng tin cậy.

Tất cả trình điều khiển V4L2 phải hỗ trợ ZZ0000ZZ.
Các ứng dụng phải luôn gọi ioctl này sau khi mở thiết bị.