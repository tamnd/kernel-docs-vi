.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/microchip.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================================
SoC vi mạch ARM (còn gọi là AT91)
=============================


Giới thiệu
------------
Tài liệu này cung cấp thông tin hữu ích về SoC vi mạch ARM
hiện được hỗ trợ trong Linux Mainline (bạn biết đấy, phiên bản trên kernel.org).

Điều quan trọng cần lưu ý là MPU dựa trên Microchip (trước đây là Atmel)
dòng sản phẩm có tên lịch sử là "AT91" hoặc "at91" trong toàn bộ nhân Linux
quá trình phát triển ngay cả khi tiền tố sản phẩm này đã hoàn toàn biến mất khỏi
tên sản phẩm chính thức của Microchip. Dù sao đi nữa, tập tin, thư mục, cây git,
nhánh/thẻ git và chủ đề email luôn chứa chuỗi con "at91" này.


SoC AT91
---------
Tài liệu và bảng dữ liệu chi tiết cho từng sản phẩm có sẵn trên
trang web của Microchip: ZZ0000ZZ

Hương vị:
    * SoC dựa trên ARM 920
      - at91rm9200

* Bảng dữ liệu

ZZ0000ZZ

* SoC dựa trên ARM 926
      - at91sam9260

* Bảng dữ liệu

ZZ0000ZZ

- at91sam9xe

* Bảng dữ liệu

ZZ0000ZZ

- at91sam9261

* Bảng dữ liệu

ZZ0000ZZ

- at91sam9263

* Bảng dữ liệu

ZZ0000ZZ

- at91sam9rl

* Bảng dữ liệu

ZZ0000ZZ

- tại91sam9g20

* Bảng dữ liệu

ZZ0000ZZ

- gia đình at91sam9g45
        - at91sam9g45
        - at91sam9g46
        - tại91sam9m10
        - at91sam9m11 (siêu thiết bị)

* Bảng dữ liệu

ZZ0000ZZ

- họ at91sam9x5 (hay còn gọi là "The 5 series")
        - at91sam9g15
        - at91sam9g25
        - at91sam9g35
        - at91sam9x25
        - at91sam9x35

* Datasheet (có thể coi là phủ sóng cho cả gia đình)

ZZ0000ZZ

- at91sam9n12

* Bảng dữ liệu

ZZ0000ZZ

- sam9x60

* Bảng dữ liệu

ZZ0000ZZ

* SoC dựa trên ARM Cortex-A5
      - gia đình sama5d3

- sama5d31
        - sama5d33
        - sama5d34
        - sama5d35
        - sama5d36 (siêu thiết bị)

* Bảng dữ liệu

ZZ0000ZZ

* SoC dựa trên ARM Cortex-A5 + NEON
      - gia đình sama5d4

- sama5d41
        - sama5d42
        - sama5d43
        - sama5d44 (siêu thiết bị)

* Bảng dữ liệu

ZZ0000ZZ

- gia đình sama5d2

- sama5d21
        - sama5d22
        - sama5d23
        - sama5d24
        - sama5d26
        - sama5d27 (siêu thiết bị)
        - sama5d28 (superset thiết bị + màn hình môi trường)

* Bảng dữ liệu

ZZ0000ZZ

* SoC dựa trên ARM Cortex-A7
      - gia đình sama7g5

- sama7g51
        - sama7g52
        - sama7g53
        - sama7g54 (siêu thiết bị)

* Bảng dữ liệu

Sắp ra mắt

- gia đình lan966
        - lan9662
        - lan9668

* Bảng dữ liệu

Sắp ra mắt

* MCU ARM Cortex-M7
      - gia đình sams70

- sams70j19
        - sams70j20
        - sams70j21
        - sams70n19
        - sams70n20
        - sams70n21
        - sams70q19
        - sams70q20
        - sams70q21

- gia đình samv70

- samv70j19
        - samv70j20
        - samv70n19
        - samv70n20
        - samv70q19
        - samv70q20

- gia đình samv71

- samv71j19
        - samv71j20
        - samv71j21
        - samv71n19
        - samv71n20
        - samv71n21
        - samv71q19
        - samv71q20
        - samv71q21

* Bảng dữ liệu

ZZ0000ZZ


Thông tin hạt nhân Linux
------------------------
Thư mục máy nhân Linux: Arch/arm/mach-at91
Mục nhập MAINTAINERS là: "Hỗ trợ SoC ARM/Microchip (AT91)"


Cây thiết bị cho SoC và bo mạch AT91
------------------------------------
Tất cả các SoC AT91 đều được chuyển đổi thành Cây thiết bị. Kể từ Linux 3.19, những sản phẩm này
phải sử dụng phương pháp này để khởi động nhân Linux.

Tuyên bố công việc đang tiến triển:
Các tệp Cây thiết bị và các liên kết Cây thiết bị áp dụng cho SoC và bo mạch AT91 là
được coi là "Không ổn định". Để hoàn toàn rõ ràng, mọi ràng buộc at91 đều có thể thay đổi tại
bất cứ lúc nào. Vì vậy, hãy đảm bảo sử dụng Cây nhị phân cây thiết bị và Hình ảnh hạt nhân được tạo từ
cùng một cây nguồn.
Vui lòng tham khảo tệp Tài liệu/devicetree/binds/ABI.rst để biết
định nghĩa về ràng buộc "Ổn định"/ABI.
Tuyên bố này sẽ bị AT91 MAINTAINERS xóa khi thích hợp.

Quy ước đặt tên và cách thực hành tốt nhất:

- Các tệp Nguồn cây thiết bị SoC Bao gồm các tệp được đặt tên theo tên chính thức của
  sản phẩm (ví dụ: at91sam9g20.dtsi hoặc sama5d33.dtsi).
- Tệp bao gồm nguồn cây thiết bị (.dtsi) được sử dụng để thu thập các nút chung có thể
  được chia sẻ trên các SoC hoặc bảng (ví dụ: sama5d3.dtsi hoặc at91sam9x5cm.dtsi).
  Khi thu thập các nút cho một thiết bị ngoại vi hoặc chủ đề cụ thể, mã định danh phải
  được đặt ở cuối tên file, cách nhau bằng dấu "_" (at91sam9x5_can.dtsi
  hoặc sama5d3_gmac.dtsi chẳng hạn).
- Các tệp Nguồn cây thiết bị bảng (.dts) có tiền tố là chuỗi "at91-" vì vậy
  rằng chúng có thể được xác định một cách dễ dàng. Lưu ý rằng một số tệp là ngoại lệ lịch sử
  theo quy tắc này (ví dụ: sama5d3[13456]ek.dts, usb_a9g20.dts hoặc animeo_ip.dts).
