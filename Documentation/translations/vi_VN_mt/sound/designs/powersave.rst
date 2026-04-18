.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/designs/powersave.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Lưu ý về Chế độ tiết kiệm năng lượng
====================================

Trình điều khiển âm thanh AC97 và HD có chế độ tiết kiệm năng lượng tự động.
Tính năng này được kích hoạt thông qua Kconfig ZZ0000ZZ
và tùy chọn ZZ0001ZZ tương ứng.

Với tính năng tự động tiết kiệm năng lượng, trình điều khiển sẽ tắt nguồn codec
thích hợp khi không cần thực hiện thao tác nào.  Khi không có ứng dụng nào sử dụng
thiết bị và/hoặc không có vòng lặp tương tự nào được đặt, việc tắt nguồn sẽ được thực hiện
thực hiện đầy đủ hoặc một phần.  Nó sẽ tiết kiệm được một lượng điện năng tiêu thụ nhất định, do đó
tốt cho máy tính xách tay (ngay cả cho máy tính để bàn).

Thời gian chờ để tắt nguồn tự động có thể được chỉ định thông qua ZZ0000ZZ
tùy chọn mô-đun của mô-đun snd-ac97-codec và snd-hda-intel.  Chỉ định
giá trị thời gian chờ tính bằng giây.  0 có nghĩa là tắt tính năng tự động
tiết kiệm điện.  Giá trị mặc định của thời gian chờ được đưa ra thông qua
ZZ0001ZZ và
Tùy chọn Kconfig ZZ0002ZZ.  Đặt cái này thành 1
(giá trị tối thiểu) không được khuyến nghị vì nhiều ứng dụng cố gắng
mở lại thiết bị thường xuyên.  10 sẽ là một lựa chọn tốt cho bình thường
hoạt động.

Tùy chọn ZZ0000ZZ được xuất dưới dạng có thể ghi.  Điều này có nghĩa là bạn có thể
điều chỉnh giá trị thông qua sysfs một cách nhanh chóng.  Ví dụ, để bật
chế độ tiết kiệm năng lượng tự động trong 10 giây, ghi vào
ZZ0001ZZ (thường là root):
::

# echo 10 > /sys/module/snd_ac97_codec/parameters/power_save


Lưu ý rằng bạn có thể nghe thấy tiếng click/bốp khi thay đổi nguồn điện.
trạng thái.  Ngoài ra, thường phải mất một thời gian nhất định để thức dậy từ
tắt nguồn về trạng thái hoạt động.  Những lỗi này thường khó khắc phục, vì vậy
không báo cáo thêm báo cáo lỗi trừ khi bạn có bản vá sửa lỗi ;-)

Đối với giao diện âm thanh HD, có một tùy chọn mô-đun khác,
power_save_controller.  Điều này sẽ bật/tắt chế độ tiết kiệm năng lượng của
phía điều khiển.  Bật tính năng này có thể giảm thêm một chút năng lượng
tiêu thụ điện năng nhưng có thể dẫn đến thời gian đánh thức lâu hơn và tiếng ồn khi nhấp chuột.
Hãy thử tắt nó đi khi bạn gặp phải tình trạng như vậy quá thường xuyên.
