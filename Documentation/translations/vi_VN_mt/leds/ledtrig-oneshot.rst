.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/leds/ledtrig-oneshot.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================
Kích hoạt LED một lần
====================

Đây là trình kích hoạt LED hữu ích để báo hiệu cho người dùng về một sự kiện khi có
không có điểm bẫy rõ ràng để đặt cài đặt bật và tắt đèn led tiêu chuẩn.  Sử dụng cái này
trigger, ứng dụng chỉ cần báo hiệu trigger khi một sự kiện đã xảy ra.
xảy ra thì trình kích hoạt sẽ bật LED rồi tắt nó trong một khoảng thời gian.
khoảng thời gian quy định.

Trình kích hoạt này có nghĩa là có thể sử dụng được cho cả các sự kiện lẻ tẻ và dày đặc.  trong
trong trường hợp đầu tiên, trình kích hoạt sẽ tạo ra một lần nhấp nháy được điều khiển rõ ràng cho mỗi lần
sự kiện, trong khi ở sự kiện sau, nó tiếp tục nhấp nháy với tốc độ không đổi, để báo hiệu
rằng các sự kiện đang đến liên tục.

LED one-shot chỉ ở trạng thái không đổi khi không có sự kiện nào.  Một
Thuộc tính "đảo ngược" bổ sung chỉ định xem LED có phải tắt (bình thường) hay không
bật (đảo ngược) khi không được trang bị lại.

Trình kích hoạt có thể được kích hoạt từ không gian người dùng trên các thiết bị lớp led như được hiển thị
dưới đây::

echo oneshot > kích hoạt

Điều này thêm các thuộc tính sysfs vào LED được ghi lại trong:
Tài liệu/ABI/testing/sysfs-class-led-trigger-oneshot

Trường hợp sử dụng ví dụ: thiết bị mạng, khởi tạo::

echo oneshot > kích hoạt # set kích hoạt cho đèn led này
  echo 33 > delay_on # blink ở 1 / (33 + 33) Hz khi lưu lượng truy cập liên tục
  echo 33 > delay_off

giao diện đi lên::

echo 1 > đảo ngược đèn led # set như bình thường, bật đèn led lên

gói đã nhận/truyền::

echo 1 > shot # led bắt đầu nhấp nháy, bỏ qua nếu đã nhấp nháy

giao diện bị hỏng::

echo 0 > đảo ngược đèn led # set ở trạng thái tắt bình thường, tắt đèn led
