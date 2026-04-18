.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/designs/control-names.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Tên điều khiển ALSA tiêu chuẩn
==============================

Tài liệu này mô tả tên tiêu chuẩn của bộ điều khiển máy trộn.

Cú pháp chuẩn
---------------
Cú pháp: [LOCATION] SOURCE [CHANNEL] [DIRECTION] FUNCTION


DIRECTION
~~~~~~~~~
=================================
<không có gì> cả hai hướng
Phát lại một hướng
Chụp một hướng
Bỏ qua Phát lại một hướng
Bỏ qua Chụp một hướng
=================================

FUNCTION
~~~~~~~~
=============================================
Công tắc bật/tắt
Bộ khuếch đại âm lượng
Kiểm soát tuyến đường, phần cứng cụ thể
=============================================

CHANNEL
~~~~~~~
===================================================================
<nothing> kênh độc lập hoặc áp dụng cho tất cả các kênh
Các kênh trái/phải phía trước
Âm thanh vòm phía sau bên trái/phải trong âm thanh vòm 4.0/5.1
Các kênh CLFE C/LFE
Kênh trung tâm trung tâm
Kênh LFE LFE
Bên trái/phải cho âm thanh vòm 7.1
===================================================================

LOCATION (Vị trí vật lý của nguồn)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
====================================
Vị trí phía trước phía trước
Vị trí phía sau phía sau
Gắn trên trạm nối
nội bộ nội bộ
====================================

SOURCE
~~~~~~
=========================================================================
Bậc thầy
Thạc sĩ Mono
Bậc thầy phần cứng
Loa loa bên trong
Loa Bass loa LFE bên trong
Tai nghe
Dòng ra
Máy phát tiếng bíp
Điện thoại
Đầu vào điện thoại
Đầu ra điện thoại
tổng hợp
FM
Micrô
Tai nghe Phần mic mic của jack tai nghe kết hợp - 4 chân
			tai nghe + mic
Tai nghe Mic phần mic của một trong hai/hoặc - tai nghe hoặc mic 3 chân
Chỉ đầu vào dòng, sử dụng "Line Out" cho đầu ra
đĩa CD
Video
Thu phóng video
phụ trợ
PCM
Chảo PCM
Quay lại
Vòng lặp tương tự D/A -> Vòng lặp A/D
Phát lại vòng lặp kỹ thuật số -> chụp vòng lặp -
			không có đường dẫn tương tự
Đơn sắc
Đầu ra đơn âm
đa
ADC
làn sóng
Âm nhạc
I2S
IEC958
HDMI
Chỉ đầu ra SPDIF
SPDIF Trong
Kỹ thuật số trong
HDMI/DP hoặc HDMI hoặc DisplayPort
=========================================================================

Ngoại lệ (không được dùng nữa)
------------------------------

=================================================================
[Analog|Kỹ thuật số] Nguồn thu
[Analog|Digital] Công tắc chụp hay còn gọi là công tắc khuếch đại đầu vào
[Tương tự|Kỹ thuật số] Âm lượng thu âm hay còn gọi là âm lượng khuếch đại đầu vào
[Analog|Digital] Công tắc phát lại hay còn gọi là công tắc khuếch đại đầu ra
[Analog|Kỹ thuật số] Âm lượng phát lại hay còn gọi là âm lượng tăng đầu ra
Điều khiển giai điệu - Chuyển đổi
Kiểm soát giai điệu - Bass
Kiểm soát giai điệu - Treble
Điều khiển 3D - Chuyển đổi
Điều khiển 3D - Trung tâm
Điều khiển 3D - Độ sâu
Điều khiển 3D - Rộng
Điều khiển 3D - Không gian
Điều khiển 3D - Cấp độ
Tăng cường micrô [(?dB)]
=================================================================

Giao diện PCM
-------------

===============================================================
Nguồn đồng hồ mẫu { "Word", "Internal", "AutoSync" }
Trạng thái đồng bộ hóa đồng hồ { "Khóa", "Đồng bộ hóa", "Không khóa" }
Tốc độ bên ngoài Tốc độ chụp bên ngoài
Tốc độ chụp Tốc độ chụp được lấy từ nguồn bên ngoài
===============================================================

Giao diện IEC958 (S/PDIF)
-------------------------

============================================== ==========================================
IEC958 […] [Playback|Capture] Bật/tắt giao diện IEC958
IEC958 […] [Phát lại|Chụp] Điều khiển âm lượng kỹ thuật số âm lượng
IEC958 […] [Phát lại|Chụp] Giá trị mặc định hoặc toàn cầu - đọc/ghi
IEC958 […] [Playback|Capture] Mặt nạ dành cho người tiêu dùng và chuyên nghiệp
IEC958 […] [Playback|Capture] Mặt nạ tiêu dùng Con Mask
IEC958 […] [Playback|Capture] Mặt nạ chuyên nghiệp Pro Mask
IEC958 […] [Phát lại|Chụp] PCM Truyền phát cài đặt được gán cho luồng PCM
IEC958 Mã phụ Q [Phát lại|Chụp] Các bit mã phụ Q mặc định

IEC958 Lời mở đầu [Phát lại|Chụp] Các từ mở đầu liên tục mặc định (4*16bit)
============================================== ==========================================
