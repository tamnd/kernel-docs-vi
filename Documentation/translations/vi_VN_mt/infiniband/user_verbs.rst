.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/infiniband/user_verbs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================
Truy cập động từ không gian người dùng
======================================

Mô-đun ib_uverbs, được xây dựng bằng cách bật CONFIG_INFINIBAND_USER_VERBS,
  cho phép truy cập trực tiếp không gian người dùng vào phần cứng IB thông qua "động từ", như
  được mô tả trong chương 11 của Đặc tả kiến trúc InfiniBand.

Để sử dụng động từ, thư viện libibverbs có sẵn từ
  ZZ0000ZZ là bắt buộc. libibverbs chứa một
  API độc lập với thiết bị để sử dụng giao diện ib_uverbs.
  libibverbs cũng yêu cầu hạt nhân phụ thuộc vào thiết bị thích hợp và
  trình điều khiển không gian người dùng cho phần cứng InfiniBand của bạn.  Ví dụ, để sử dụng
  Mellanox HCA, bạn sẽ cần mô-đun hạt nhân ib_mthca và
  Trình điều khiển không gian người dùng libmthca được cài đặt.

Giao tiếp hạt nhân-người dùng
=============================

Không gian người dùng giao tiếp với kernel để biết đường dẫn chậm, tài nguyên
  hoạt động quản lý thông qua ký tự /dev/infiniband/uverbsN
  thiết bị.  Các hoạt động đường dẫn nhanh thường được thực hiện bằng cách viết
  trực tiếp tới các thanh ghi phần cứng mmap() được đưa vào không gian người dùng, không có
  cuộc gọi hệ thống hoặc chuyển ngữ cảnh vào kernel.

Các lệnh được gửi đến kernel thông qua các lệnh ghi() trên các tệp thiết bị này.
  ABI được xác định trong driver/infiniband/include/ib_user_verbs.h.
  Cấu trúc cho các lệnh yêu cầu phản hồi từ kernel
  chứa trường 64 bit được sử dụng để truyền con trỏ tới bộ đệm đầu ra.
  Trạng thái được trả về không gian người dùng dưới dạng giá trị trả về của write()
  cuộc gọi hệ thống.

Quản lý tài nguyên
===================

Vì việc tạo và hủy tất cả tài nguyên IB được thực hiện bởi
  các lệnh được truyền qua bộ mô tả tập tin, hạt nhân có thể theo dõi
  trong đó tài nguyên được gắn vào bối cảnh không gian người dùng nhất định.  các
  Mô-đun ib_uverbs duy trì các bảng idr được sử dụng để dịch
  giữa các con trỏ kernel và các thẻ điều khiển không gian người dùng mờ đục, do đó kernel
  con trỏ không bao giờ được tiếp xúc với không gian người dùng và không gian người dùng không thể lừa
  hạt nhân đi theo một con trỏ không có thật.

Điều này cũng cho phép kernel dọn dẹp khi một tiến trình thoát ra và
  ngăn cản một tiến trình chạm vào tài nguyên của tiến trình khác.

Ghim bộ nhớ
==============

I/O không gian người dùng trực tiếp yêu cầu các vùng bộ nhớ có tiềm năng
  Các mục tiêu I/O được lưu giữ ở cùng một địa chỉ vật lý.  các
  Mô-đun ib_uverbs quản lý việc ghim và bỏ ghim các vùng bộ nhớ thông qua
  các cuộc gọi get_user_pages() và put_page().  Nó cũng giải thích cho
  lượng bộ nhớ được ghim trong pinned_vm của tiến trình và kiểm tra xem
  các quy trình không có đặc quyền không vượt quá giới hạn RLIMIT_MEMLOCK của chúng.

Các trang được ghim nhiều lần sẽ được tính mỗi lần chúng được ghim
  được ghim, do đó giá trị của pinned_vm có thể được đánh giá quá cao
  số trang được ghim bởi một tiến trình.

tập tin /dev
============

Để tự động tạo các tập tin thiết bị ký tự phù hợp với
  udev, một quy tắc như::

KERNEL=="uverbs*", NAME="infiniband/%k"

có thể được sử dụng  Điều này sẽ tạo các nút thiết bị có tên::

/dev/infiniband/uverbs0

và vân vân.  Vì các động từ trong không gian người dùng InfiniBand phải an toàn cho
  được sử dụng bởi các tiến trình không có đặc quyền, có thể hữu ích khi thêm một
  MODE hoặc GROUP phù hợp với quy tắc udev.
