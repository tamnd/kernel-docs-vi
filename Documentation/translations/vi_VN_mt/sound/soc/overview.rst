.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/soc/overview.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========================
Tổng quan về lớp SoC ALSA
=======================

Mục tiêu tổng thể của dự án của lớp ALSA System on Chip (ASoC) là
cung cấp hỗ trợ ALSA tốt hơn cho các bộ xử lý hệ thống trên chip nhúng (ví dụ:
pxa2xx, au1x00, iMX, v.v.) và codec âm thanh di động.  Trước ASoC
hệ thống con có một số hỗ trợ trong kernel cho âm thanh SoC, tuy nhiên nó
có một số hạn chế: -

* Trình điều khiển Codec thường được kết hợp chặt chẽ với SoC cơ bản
    CPU. Điều này không lý tưởng và dẫn đến sự trùng lặp mã - ví dụ:
    Linux có trình điều khiển wm8731 khác nhau cho 4 nền tảng SoC khác nhau.

* Không có phương pháp tiêu chuẩn nào để báo hiệu các sự kiện âm thanh do người dùng khởi tạo (ví dụ:
    Cắm tai nghe/Mic, Phát hiện tai nghe/Mic sau khi cắm
    sự kiện). Đây là những sự kiện khá phổ biến trên các thiết bị di động và thường yêu cầu
    mã cụ thể của máy để định tuyến lại âm thanh, bật amps, v.v., sau một khoảng thời gian như vậy
    sự kiện.

* Trình điều khiển có xu hướng tăng sức mạnh cho toàn bộ codec khi phát (hoặc
    ghi âm) âm thanh. Điều này tốt cho PC nhưng có xu hướng lãng phí rất nhiều
    cấp nguồn cho các thiết bị di động. Cũng không có hỗ trợ tiết kiệm
    cấp nguồn thông qua việc thay đổi tốc độ lấy mẫu của codec, dòng điện phân cực, v.v.


Thiết kế ASoC
===========

Lớp ASoC được thiết kế để giải quyết những vấn đề này và cung cấp các tính năng sau:
tính năng: -

* Codec độc lập. Cho phép sử dụng lại trình điều khiển codec trên các nền tảng khác
    và máy móc.

* Dễ dàng thiết lập giao diện âm thanh I2S/PCM giữa codec và SoC. Mỗi SoC
    giao diện và codec đăng ký khả năng giao diện âm thanh của nó với
    lõi và sau đó được khớp và định cấu hình khi ứng dụng
    thông số phần cứng đã biết.

* Quản lý năng lượng âm thanh động (DAPM). DAPM tự động đặt codec thành
    trạng thái năng lượng tối thiểu của nó mọi lúc. Điều này bao gồm việc bật/tắt nguồn
    khối nguồn bên trong tùy thuộc vào định tuyến âm thanh codec bên trong và bất kỳ
    các luồng hoạt động.

* Giảm pop và nhấp chuột. Có thể giảm hiện tượng nhấp chuột và nhấp chuột bằng cách cấp nguồn cho
    tăng/giảm codec theo đúng trình tự (bao gồm cả việc sử dụng tắt tiếng kỹ thuật số). ASoC
    báo hiệu cho codec khi nào cần thay đổi trạng thái nguồn.

* Điều khiển riêng của máy: Cho phép máy thêm điều khiển vào card âm thanh
    (ví dụ: điều khiển âm lượng cho bộ khuếch đại loa).

Để đạt được tất cả những điều này, ASoC về cơ bản chia hệ thống âm thanh nhúng thành
nhiều trình điều khiển thành phần có thể sử dụng lại: -

* Trình điều khiển lớp codec: Trình điều khiển lớp codec độc lập với nền tảng và
    chứa các điều khiển âm thanh, khả năng giao diện âm thanh, codec DAPM
    định nghĩa và codec chức năng IO. Lớp này mở rộng tới BT, FM và MODEM
    IC nếu được yêu cầu. Trình điều khiển lớp Codec phải là mã chung có thể chạy
    trên mọi kiến trúc và máy móc.

* Trình điều khiển lớp nền tảng: Trình điều khiển lớp nền tảng bao gồm âm thanh DMA
    trình điều khiển động cơ, trình điều khiển giao diện âm thanh kỹ thuật số (DAI) (ví dụ: I2S, AC97, PCM)
    và mọi trình điều khiển âm thanh DSP cho nền tảng đó.

* Trình điều khiển lớp máy: Lớp trình điều khiển máy đóng vai trò là chất keo kết dính
    mô tả và liên kết các trình điều khiển thành phần khác với nhau để tạo thành ALSA
    "thiết bị card âm thanh". Nó xử lý mọi điều khiển cụ thể của máy và
    sự kiện âm thanh ở cấp độ máy (ví dụ: bật bộ khuếch đại khi bắt đầu phát lại).
