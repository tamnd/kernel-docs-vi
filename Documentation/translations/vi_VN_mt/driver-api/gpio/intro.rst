.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/gpio/intro.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============
Giới thiệu
============


Giao diện GPIO
===============

Các tài liệu trong thư mục này cung cấp hướng dẫn chi tiết về cách truy cập
GPIO trong trình điều khiển và cách viết trình điều khiển cho thiết bị cung cấp GPIO
chính nó.


GPIO là gì?
===============

"Đầu vào/đầu ra mục đích chung" (GPIO) là một thiết bị được điều khiển bằng phần mềm linh hoạt
tín hiệu số. Chúng được cung cấp từ nhiều loại chip và quen thuộc
cho các nhà phát triển Linux làm việc với phần cứng nhúng và tùy chỉnh. Mỗi GPIO
đại diện cho một bit được kết nối với một chốt cụ thể hoặc "quả bóng" trên Ball Grid Array
(BGA) gói. Sơ đồ bảng hiển thị phần cứng bên ngoài nào kết nối với
GPIO nào. Trình điều khiển có thể được viết một cách tổng quát để mã thiết lập bảng
chuyển dữ liệu cấu hình pin như vậy cho trình điều khiển.

Bộ xử lý hệ thống trên chip (SOC) phụ thuộc rất nhiều vào GPIO. Trong một số trường hợp, mọi
pin không chuyên dụng có thể được cấu hình là GPIO; và hầu hết các chip đều có ít nhất
vài chục người trong số họ. Các thiết bị logic lập trình được (như FPGA) có thể dễ dàng
cung cấp GPIO; chip đa chức năng như bộ quản lý nguồn và bộ giải mã âm thanh
thường có một vài chân như vậy để giúp giải quyết tình trạng khan hiếm pin trên SOC; và có
cũng có chip "GPIO Expander" kết nối bằng bus nối tiếp I2C hoặc SPI.
Hầu hết các cầu nam PC đều có vài chục chân có khả năng GPIO (chỉ có BIOS
phần sụn biết cách chúng được sử dụng).

Khả năng chính xác của GPIO khác nhau giữa các hệ thống. Các tùy chọn phổ biến:

- Giá trị đầu ra có thể ghi được (cao=1, thấp=0). Một số chip cũng có
    các tùy chọn về cách điều khiển giá trị đó, ví dụ như chỉ có một
    giá trị có thể được điều khiển, hỗ trợ "wire-OR" và các sơ đồ tương tự cho
    giá trị khác (đặc biệt là tín hiệu "cống mở").

- Giá trị đầu vào cũng có thể đọc được (1, 0). Một số chip hỗ trợ đọc lại
    số chân được định cấu hình là "đầu ra", rất hữu ích trong "dây-HOẶC" như vậy
    trường hợp (để hỗ trợ tín hiệu hai chiều). Bộ điều khiển GPIO có thể có
    logic khử trục trặc/gỡ lỗi đầu vào, đôi khi bằng các điều khiển phần mềm.

- Đầu vào thường có thể được sử dụng làm tín hiệu IRQ, thường được kích hoạt cạnh nhưng
    đôi khi mức độ được kích hoạt. Các IRQ như vậy có thể được cấu hình dưới dạng hệ thống
    sự kiện đánh thức, để đánh thức hệ thống từ trạng thái năng lượng thấp.

- Thông thường, GPIO sẽ có thể được cấu hình làm đầu vào hoặc đầu ra nếu cần
    bởi các bảng sản phẩm khác nhau; những hướng duy nhất tồn tại quá.

- Hầu hết các GPIO có thể được truy cập khi đang giữ các khóa spin, nhưng những GPIO được truy cập
    thông qua một xe buýt nối tiếp thường không thể. Một số hệ thống hỗ trợ cả hai loại.

Trên một bảng nhất định, mỗi GPIO được sử dụng cho một mục đích cụ thể như giám sát
Chèn/tháo thẻ MMC/SD, phát hiện trạng thái chống ghi thẻ, lái xe
một LED, định cấu hình bộ thu phát, đập bit vào bus nối tiếp, chọc vào phần cứng
cơ quan giám sát, cảm nhận một công tắc, v.v.


Thuộc tính GPIO phổ biến
======================

Các thuộc tính này được đáp ứng thông qua tất cả các tài liệu khác của giao diện GPIO
và việc hiểu chúng sẽ rất hữu ích, đặc biệt nếu bạn cần xác định GPIO
ánh xạ.

Hoạt động-Cao và Hoạt động-Thấp
--------------------------
Điều tự nhiên khi cho rằng GPIO đang "hoạt động" khi tín hiệu đầu ra của nó là 1
("cao") và không hoạt động khi ở mức 0 ("thấp"). Tuy nhiên trong thực tế tín hiệu của
GPIO có thể bị đảo ngược trước khi đến đích hoặc thiết bị có thể quyết định
có những quy ước khác nhau về ý nghĩa của "hoạt động". Những quyết định như vậy nên
minh bạch đối với trình điều khiển thiết bị, do đó có thể định nghĩa GPIO là
ở mức hoạt động cao ("1" có nghĩa là "hoạt động", mặc định) hoặc hoạt động ở mức thấp ("0"
có nghĩa là "hoạt động") để người lái xe chỉ cần lo lắng về tín hiệu logic và
không phải về những gì xảy ra ở cấp độ dòng.

Cống mở và nguồn mở
--------------------------
Đôi khi tín hiệu chia sẻ cần sử dụng "cống hở" (nơi chỉ có tín hiệu thấp
mức tín hiệu thực sự được điều khiển) hoặc "nguồn mở" (trong đó chỉ có mức tín hiệu cao
điều khiển) báo hiệu. Thuật ngữ đó áp dụng cho bóng bán dẫn CMOS; "bộ sưu tập mở" là
được sử dụng cho TTL. Điện trở kéo lên hoặc kéo xuống gây ra mức tín hiệu cao hoặc thấp.
Điều này đôi khi được gọi là "wire-AND"; hay thực tế hơn, từ tiêu cực
phối cảnh logic (low=true) thì đây là "dây-HOẶC".

Một ví dụ phổ biến về tín hiệu thoát mở là đường IRQ hoạt động ở mức thấp được chia sẻ.
Ngoài ra, tín hiệu bus dữ liệu hai chiều đôi khi sử dụng tín hiệu cống mở.

Một số bộ điều khiển GPIO hỗ trợ trực tiếp đầu ra nguồn mở và cống mở; nhiều
đừng. Khi bạn cần tín hiệu thoát nước mở nhưng phần cứng của bạn không trực tiếp
hỗ trợ nó, có một thành ngữ phổ biến mà bạn có thể sử dụng để mô phỏng nó với bất kỳ mã pin GPIO nào
có thể được sử dụng làm đầu vào hoặc đầu ra:

ZZ0001ZZ: ZZ0000ZZ ... điều này điều khiển tín hiệu và
 ghi đè pullup.

ZZ0001ZZ: ZZ0000ZZ ... điều này sẽ tắt đầu ra, vì vậy
 pullup (hoặc một số thiết bị khác) điều khiển tín hiệu.

Logic tương tự có thể được áp dụng để mô phỏng tín hiệu nguồn mở, bằng cách điều khiển
tín hiệu cao và định cấu hình GPIO làm đầu vào ở mức thấp. Cống mở/mở này
mô phỏng nguồn có thể được xử lý một cách minh bạch bằng khung GPIO.

Nếu bạn đang "điều khiển" tín hiệu ở mức cao nhưng gpiod_get_value(gpio) lại báo ở mức thấp
giá trị (sau khi thời gian tăng thích hợp trôi qua), bạn biết một số thành phần khác là
đẩy tín hiệu chia sẻ xuống mức thấp. Đó không hẳn là một lỗi. Là một điểm chung
ví dụ: đó là cách kéo dài đồng hồ I2C: một nô lệ cần đồng hồ chậm hơn
trì hoãn cạnh tăng của SCK và I2C master điều chỉnh tốc độ tín hiệu của nó
tương ứng.
