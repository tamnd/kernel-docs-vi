.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/mips/ingenic-tcu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================================
Phần cứng Bộ định thời/bộ đếm SoCs Ingenic JZ47xx
====================================================

Bộ hẹn giờ/bộ đếm (TCU) trong SoC JZ47xx của Ingenic là một bộ đa chức năng
khối phần cứng. Nó có tới tám kênh, có thể được sử dụng như
bộ đếm, bộ hẹn giờ hoặc PWM.

- JZ4725B, JZ4750, JZ4755 chỉ có sáu kênh TCU. Tất cả các SoC khác
  có tám kênh.

- JZ4725B giới thiệu một kênh riêng, được gọi là Bộ đếm thời gian hệ điều hành
  (OST). Nó là một bộ đếm thời gian lập trình được 32-bit. Trên JZ4760B trở lên, nó là
  64-bit.

- Mỗi kênh TCU có đồng hồ riêng, có thể được điều chỉnh lại thành ba
  các đồng hồ khác nhau (pclk, ext, rtc), kiểm soát và tăng tốc lại, thông qua thanh ghi TCSR của chúng.

- Khối phần cứng cơ quan giám sát và OST cũng có thanh ghi TCSR tương tự
      định dạng trong không gian đăng ký của họ.
    - Các thanh ghi TCU được sử dụng để cổng/gỡ cổng cũng có thể cổng/gỡ cổng cơ quan giám sát và
      Đồng hồ OST.

- Mỗi kênh TCU hoạt động ở một trong hai chế độ:

- chế độ TCU1: các kênh không thể hoạt động ở chế độ ngủ nhưng dễ dàng hơn
      hoạt động.
    - chế độ TCU2: các kênh có thể hoạt động ở chế độ ngủ, nhưng thao tác hơi chậm
      phức tạp hơn so với các kênh TCU1.

- Chế độ của mỗi kênh TCU phụ thuộc vào SoC được sử dụng:

- Trên các SoC cũ nhất (lên đến JZ4740), tất cả tám kênh đều hoạt động ở
      Chế độ TCU1.
    - Trên JZ4725B, kênh 5 hoạt động là TCU2, các kênh còn lại hoạt động là TCU1.
    - Trên các SoC mới nhất (JZ4750 trở lên), các kênh 1-2 hoạt động dưới dạng TCU2,
      những người khác hoạt động như TCU1.

- Mỗi kênh có thể tạo ra một ngắt. Một số kênh chia sẻ một ngắt
  dòng, một số thì không và điều này thay đổi giữa các phiên bản SoC:

- trên các SoC cũ hơn (JZ4740 trở xuống), kênh 0 và kênh 1 có
      đường ngắt riêng; kênh 2-7 chia sẻ dòng ngắt cuối cùng.
    - Trên JZ4725B, kênh 0 có ngắt riêng; kênh 1-5 chia sẻ một
      đường ngắt; OST sử dụng dòng ngắt cuối cùng.
    - trên các SoC mới hơn (JZ4750 trở lên), kênh 5 có ngắt riêng;
      các kênh 0-4 và (nếu tám kênh) 6-7 đều dùng chung một đường ngắt;
      OST sử dụng dòng ngắt cuối cùng.

Thực hiện
==============

Các chức năng của phần cứng TCU được trải rộng trên nhiều trình điều khiển:

============ =====
trình điều khiển đồng hồ/clk/ingenic/tcu.c
ngắt trình điều khiển/irqchip/irq-ingenic-tcu.c
trình điều khiển hẹn giờ/clocksource/ingenic-timer.c
Trình điều khiển OST/clocksource/ingenic-ost.c
Trình điều khiển PWM/pwm/pwm-jz4740.c
trình điều khiển cơ quan giám sát/cơ quan giám sát/jz4740_wdt.c
============ =====

Bởi vì các chức năng khác nhau của TCU thuộc về các trình điều khiển khác nhau
và các khung có thể được kiểm soát từ cùng một thanh ghi, tất cả những thứ này
trình điều khiển truy cập vào sổ đăng ký của họ thông qua cùng một sơ đồ quy trình.

Để biết thêm thông tin về liên kết cây thiết bị của trình điều khiển TCU,
hãy xem Tài liệu/devicetree/binds/timer/ingenic,tcu.yaml.