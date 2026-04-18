.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/designs/jack-controls.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================
Điều khiển giắc cắm ALSA
==================

Tại sao chúng ta cần Jack kcontrols
==========================

ALSA sử dụng kcontrols để xuất các điều khiển âm thanh (chuyển đổi, âm lượng, Mux, ...)
tới không gian người dùng. Điều này có nghĩa là các ứng dụng không gian người dùng như Pulseaudio có thể
tắt tai nghe và bật loa khi không có tai nghe
cắm vào.

Mã jack ALSA cũ chỉ tạo thiết bị đầu vào cho mỗi máy đã đăng ký
jack. Các thiết bị đầu vào jack này không thể đọc được bởi các thiết bị trong không gian người dùng
chạy không phải root.

Mã giắc cắm mới tạo ra các điều khiển giắc cắm nhúng cho mỗi giắc cắm
có thể được đọc bởi bất kỳ tiến trình nào.

Điều này có thể được kết hợp với UCM để cho phép không gian người dùng định tuyến âm thanh nhiều hơn
thông minh dựa trên các sự kiện chèn hoặc loại bỏ jack.

Nội bộ Jack Kcontrol
=======================

Mỗi jack sẽ có một danh sách kcontrol để chúng ta có thể tạo kcontrol
và gắn nó vào jack, ở giai đoạn tạo jack. Chúng ta cũng có thể thêm một
kcontrol vào giắc cắm hiện có, bất cứ lúc nào khi được yêu cầu.

Những kcontrol đó sẽ được giải phóng tự động khi Jack được giải phóng.

Cách sử dụng jack kcontrols
=========================

Để duy trì khả năng tương thích, snd_jack_new() đã được sửa đổi bởi
thêm hai thông số:

ban đầu_kctl
  nếu đúng, hãy tạo kcontrol và thêm nó vào danh sách jack.
phantom_jack
  Không tạo thiết bị đầu vào cho giắc cắm ảo.

Giắc cắm HDA có thể đặt phantom_jack thành true để tạo ảo
jack và đặt init_kctl thành true để tạo kcontrol ban đầu với
đúng id.

Giắc cắm ASoC phải đặt init_kctl là sai. Tên pin sẽ là
được gán làm tên jack kcontrol.
