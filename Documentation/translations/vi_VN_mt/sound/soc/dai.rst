.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/soc/dai.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================================
Giao diện âm thanh kỹ thuật số ASoC (DAI)
==================================

ASoC hiện hỗ trợ ba Giao diện âm thanh kỹ thuật số chính (DAI) được tìm thấy trên
Bộ điều khiển SoC và CODEC âm thanh di động hiện nay, cụ thể là AC97, I2S và PCM.


AC97
====

AC97 là giao diện năm dây thường thấy trên nhiều card âm thanh PC. Đó là
hiện nay cũng phổ biến trên nhiều thiết bị di động. Chiếc DAI này có dòng và thời gian RESET
ghép dữ liệu của nó trên các dòng SDATA_OUT (phát lại) và SDATA_IN (chụp).
Đồng hồ bit (BCLK) luôn được điều khiển bởi CODEC (thường là 12,288 MHz) và
frame (FRAME) (thường là 48kHz) luôn được điều khiển bởi bộ điều khiển. Mỗi AC97
khung dài 21uS và được chia thành 13 khe thời gian.

Thông số kỹ thuật AC97 có thể được tìm thấy tại:
ZZ0000ZZ


I2S
===

I2S là DAI 4 dây phổ biến được sử dụng trong HiFi, STB và các thiết bị di động. Tx và
Đường Rx được sử dụng để truyền âm thanh, trong khi đồng hồ bit (BCLK) và
đồng hồ trái/phải (LRC) đồng bộ hóa liên kết. I2S linh hoạt ở chỗ
bộ điều khiển hoặc CODEC có thể điều khiển (chính) các dòng đồng hồ BCLK và LRC. Đồng hồ bit
thường thay đổi tùy thuộc vào tốc độ mẫu và đồng hồ hệ thống chính
(SYSCLK). LRCLK giống như tốc độ mẫu. Một số thiết bị hỗ trợ riêng
ADC và DAC LRCLK, điều này cho phép chụp và phát lại đồng thời ở
tốc độ lấy mẫu khác nhau.

I2S có một số chế độ hoạt động khác nhau: -

I2S
  MSB được truyền trên cạnh xuống của BCLK đầu tiên sau LRC
  chuyển tiếp.

Căn trái
  MSB được truyền trên quá trình chuyển đổi của LRC.

Căn phải
  MSB được truyền BCLK cỡ mẫu trước khi chuyển đổi LRC.

PCM
===

PCM là một giao diện 4 dây khác, rất giống với I2S, có thể hỗ trợ nhiều hơn
giao thức linh hoạt. Nó có các dòng bit clock (BCLK) và sync (SYNC) được sử dụng
để đồng bộ hóa liên kết trong khi các đường Tx và Rx được sử dụng để truyền và
nhận dữ liệu âm thanh. Đồng hồ bit thường thay đổi tùy theo tốc độ mẫu
trong khi đồng bộ hóa chạy ở tốc độ mẫu. PCM cũng hỗ trợ Phân chia thời gian
Ghép kênh (TDM) trong đó một số thiết bị có thể sử dụng bus đồng thời (điều này
đôi khi được gọi là chế độ mạng).

Các chế độ hoạt động phổ biến của PCM: -

Chế độ A
  MSB được truyền trên cạnh xuống của BCLK đầu tiên sau FRAME/SYNC.

Chế độ B
  MSB được truyền trên cạnh lên của FRAME/SYNC.
