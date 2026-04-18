.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/process/debugging/media_specific_debugging_guide.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================================================
Gỡ lỗi và truy tìm trong hệ thống con phương tiện
============================================

Tài liệu này đóng vai trò là điểm khởi đầu và tra cứu thiết bị gỡ lỗi
trình điều khiển trong hệ thống con phương tiện và gỡ lỗi các trình điều khiển này khỏi không gian người dùng.

.. contents::
    :depth: 3

Lời khuyên gỡ lỗi chung
------------------------

Để được tư vấn chung, hãy xem ZZ0000ZZ.

Các phần sau đây cho bạn thấy một số công cụ có sẵn.

tham số mô-đun dev_debug
--------------------------

Mọi thiết bị video đều cung cấp tham số ZZ0000ZZ, cho phép nhận
hiểu biết sâu hơn về IOCTL trong nền.::

# cat/sys/class/video4linux/video3/tên
  rkvdec
  # echo 0xff > /sys/class/video4linux/video3/dev_debug
  # dmesg -wH
  [...] videodev: v4l2_open: video3: open (0)
  [ +0,000036] video3: VIDIOC_QUERYCAP: driver=rkvdec, card=rkvdec,
  bus=platform:rkvdec, phiên bản=0x00060900, khả năng=0x84204000,
  device_caps=0x04204000

Để có tài liệu đầy đủ, hãy xem ZZ0000ZZ

dev_dbg() / v4l2_dbg()
----------------------

Hai câu lệnh in gỡ lỗi dành riêng cho thiết bị và v4l2
hệ thống con, hãy tránh thêm chúng vào bản gửi cuối cùng của bạn trừ khi chúng có
giá trị lâu dài cho việc điều tra.

Để có cái nhìn tổng quát, vui lòng xem
ZZ0000ZZ
hướng dẫn.

- Sự khác biệt giữa cả hai?

- v4l2_dbg() sử dụng v4l2_printk() dưới mui xe, sử dụng thêm
    printk() trực tiếp, do đó nó không thể được nhắm mục tiêu bằng gỡ lỗi động
  - dev_dbg() có thể được nhắm mục tiêu bằng cách gỡ lỗi động
  - v4l2_dbg() có định dạng tiền tố cụ thể hơn cho hệ thống con phương tiện, trong khi
    dev_dbg chỉ đánh dấu tên trình điều khiển và vị trí của nhật ký

Gỡ lỗi động
-------------

Một phương pháp để cắt giảm đầu ra gỡ lỗi theo nhu cầu của bạn.

Để được tư vấn chung, hãy xem
Hướng dẫn ZZ0000ZZ.

Đây là một ví dụ cho phép tất cả pr_debug() có sẵn trong tệp::

$ bí danh ddcmd='echo $* > /proc/dynamic_debug/control'
  $ ddcmd '-p; tập tin v4l2-h264.c +p'
  $ grep =p /proc/dynamic_debug/control
   trình điều khiển/media/v4l2-core/v4l2-h264.c:372 [v4l2_h264]print_ref_list_b =p
   "ref_pic_list_b%u (cur_poc %u%c) %s"
   trình điều khiển/media/v4l2-core/v4l2-h264.c:333 [v4l2_h264]print_ref_list_p =p
   "ref_pic_list_p (cur_poc %u%c) %s\n"

Ftrace
------

Trình theo dõi hạt nhân bên trong có thể theo dõi các sự kiện, hàm tĩnh được xác định trước
cuộc gọi, v.v. Rất hữu ích để gỡ lỗi các vấn đề mà không cần thay đổi kernel và
hiểu hành vi của các hệ thống con.

Để được tư vấn chung, hãy xem
Hướng dẫn ZZ0000ZZ.

Gỡ lỗiFS
-------

Công cụ này cho phép bạn kết xuất hoặc sửa đổi các giá trị bên trong của trình điều khiển thành các tệp
trong một hệ thống tập tin tùy chỉnh.

Để được tư vấn chung, hãy xem
Hướng dẫn ZZ0000ZZ.

Hiệu suất & lựa chọn thay thế
-------------------

Công cụ đo lường các số liệu thống kê khác nhau trên hệ thống đang chạy nhằm chẩn đoán sự cố.

Để được tư vấn chung, hãy xem
Hướng dẫn ZZ0000ZZ.

Ví dụ cho các thiết bị truyền thông:

Thu thập dữ liệu thống kê cho công việc giải mã: (Ví dụ này có trên SoC RK3399
với trình điều khiển codec rkvdec sử dụng ZZ0000ZZ)::

chỉ số hoàn hảo -d python3 fluster.py chạy -d GStreamer-H.264-V4L2SL-Gst1.0 -ts
  JVT-AVC_V1-tv AUD_MW_E -j1
  ...
Thống kê bộ đếm hiệu suất cho 'python3 fluster.py run -d
  GStreamer-H.264-V4L2SL-Gst1.0 -ts JVT-AVC_V1 -tv AUD_MW_E -j1 -v':

Đồng hồ tác vụ 7794,23 msec:u CPU #    0.697 được sử dụng
               0 chuyển đổi ngữ cảnh:u #    0.000 /giây
               0 lần di chuyển CPU:u #    0.000 /giây
           11901 lỗi trang:u #    1.527 K/giây
       882671556 chu kỳ:u #    0.113 GHz (95,79%)
       711708695 hướng dẫn:u #    0.81 insn mỗi chu kỳ (95,79%)
        10581935 nhánh:u #    1.358 M/giây (15,13%)
         6871144 bỏ lỡ chi nhánh:u #   64.93% trong số tất cả các chi nhánh (95,79%)
       281716547 Tải L1-dcache:u #   36.144 M/giây (95,79%)
         9019581 L1-dcache-load-misses:u #    3.20% trong tổng số truy cập L1-dcache (95,79%)
 <không được hỗ trợ> Tải LLC:u
 <không được hỗ trợ> LLC-load-misses:u

11,180830431 giây thời gian đã trôi qua

Người dùng 1,502318000 giây
     6.377221000 giây hệ thống

Tính khả dụng của các sự kiện và số liệu tùy thuộc vào hệ thống bạn đang chạy.

Kiểm tra lỗi và phân tích hoảng loạn
-------------------------------

Các tùy chọn cấu hình hạt nhân khác nhau để tăng cường khả năng phát hiện lỗi của Linux
Hạt nhân với chi phí giảm hiệu suất.

Để được tư vấn chung, hãy xem
Hướng dẫn ZZ0000ZZ.

Xác minh trình điều khiển tuân thủ v4l2
----------------------------------------

Để xác minh rằng trình điều khiển tuân thủ v4l2 API, công cụ tuân thủ v4l2 là
được sử dụng, là một phần của ZZ0000ZZ, một bộ công cụ không gian người dùng để hoạt động
với hệ thống con truyền thông.

Để xem cấu trúc liên kết phương tiện chi tiết (và kiểm tra nó), hãy sử dụng ::

tuân thủ v4l2 -M /dev/mediaX --verbose

Bạn cũng có thể chạy kiểm tra tuân thủ đầy đủ cho tất cả các thiết bị được tham chiếu trong
cấu trúc liên kết truyền thông với::

tuân thủ v4l2 -m /dev/mediaX

Gỡ lỗi sự cố khi nhận video
---------------------------------------

Triển khai vidioc_log_status trong trình điều khiển: điều này có thể ghi lại trạng thái hiện tại
vào nhật ký hạt nhân. Nó được gọi bởi v4l2-ctl --log-status. Rất hữu ích cho
gỡ lỗi khi nhận video (TV/S-Video/HDMI/etc) do video
tín hiệu là bên ngoài (vì vậy không thể đoán trước). Ít hữu ích hơn với đầu vào cảm biến máy ảnh
vì bạn có quyền kiểm soát hoạt động của cảm biến máy ảnh.

Thông thường bạn chỉ có thể gán mặc định ::

.vidioc_log_status = v4l2_ctrl_log_status,

Nhưng bạn cũng có thể tạo lệnh gọi lại của riêng mình để tạo nhật ký trạng thái tùy chỉnh.

Bạn có thể tìm thấy một ví dụ trong trình điều khiển coban
(ZZ0000ZZ).

ZZ0000ZZ ©2024 : Cộng tác