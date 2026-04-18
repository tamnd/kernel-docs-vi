.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/x86_64/machinecheck.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================================================================
Các tham số sysfs có thể định cấu hình cho mã kiểm tra máy x86-64
===============================================================

Kiểm tra máy báo cáo tình trạng lỗi phần cứng nội bộ được phát hiện
bởi CPU. Các lỗi không được sửa thường gây ra việc kiểm tra máy
(thường gây hoảng loạn), những cái đã sửa sẽ gây ra mục nhập nhật ký kiểm tra máy.

Việc kiểm tra bằng máy được tổ chức tại các ngân hàng (thường gắn liền với
một hệ thống con phần cứng) và các sự kiện phụ trong ngân hàng. Ý nghĩa chính xác
của các ngân hàng và sự kiện phụ là CPU cụ thể.

mcelog biết cách giải mã chúng.

Khi bạn thấy thông báo "Đã ghi lỗi kiểm tra máy" trong hệ thống
log thì mcelog sẽ chạy để thu thập và giải mã các mục kiểm tra máy
từ/dev/mcelog. Thông thường mcelog nên được chạy thường xuyên từ cronjob.

Mỗi CPU có một thư mục trong /sys/devices/system/machinecheck/machinecheckN
(Số N = CPU).

Thư mục chứa một số mục có thể cấu hình. Xem
Documentation/ABI/testing/sysfs-mce để biết thêm chi tiết.

Các mục nhập tài liệu TBD cho cấu hình ngắt ngưỡng AMD

Để biết thêm chi tiết về kiến trúc kiểm tra máy x86
xem hướng dẫn sử dụng kiến trúc Intel và AMD từ trang web dành cho nhà phát triển của họ.

Để biết thêm chi tiết về kiến trúc
xem ZZ0000ZZ