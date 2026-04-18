.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/dev-tools/gpio-sloppy-logic-analyzer.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================================
Máy phân tích logic cẩu thả dựa trên Linux Kernel GPIO
======================================================

:Tác giả: Wolfram Sang

Giới thiệu
============

Tài liệu này mô tả ngắn gọn cách chạy GPIO cẩu thả trong kernel
máy phân tích logic chạy trên CPU bị cô lập.

Bộ phân tích logic cẩu thả sẽ sử dụng một vài dòng GPIO ở chế độ đầu vào trên một
hệ thống lấy mẫu nhanh chóng các dòng kỹ thuật số này, nếu Nyquist
tiêu chí được đáp ứng, dẫn đến nhật ký chuỗi thời gian có dạng sóng gần đúng khi chúng
xuất hiện trên những dòng này. Một cách để sử dụng nó là phân tích lưu lượng truy cập bên ngoài
được kết nối với các đường GPIO này bằng dây dẫn (tức là đầu dò kỹ thuật số), hoạt động như một
máy phân tích logic thông thường

Một tính năng khác là rình mò các thiết bị ngoại vi trên chip nếu các ô I/O của chúng
các thiết bị ngoại vi có thể được sử dụng ở chế độ đầu vào GPIO cùng lúc với khi chúng đang được sử dụng.
được sử dụng làm đầu vào hoặc đầu ra cho thiết bị ngoại vi. Điều đó có nghĩa là bạn có thể ví dụ: rình mò
Lưu lượng I2C không cần nối dây (nếu phần cứng của bạn hỗ trợ). Trong ghim
hệ thống con điều khiển các bộ điều khiển chân như vậy được gọi là "không nghiêm ngặt": một chân nhất định
có thể được sử dụng với một thiết bị ngoại vi nhất định và làm dòng đầu vào GPIO cùng một lúc
thời gian.

Lưu ý rằng đây là máy phân tích cuối cùng có thể bị ảnh hưởng bởi độ trễ,
đường dẫn mã không xác định và các ngắt không thể che giấu. Nó được gọi là 'cẩu thả'
vì một lý do. Tuy nhiên, ví dụ: phát triển từ xa, có thể sẽ hữu ích khi có được một
xem đầu tiên và hỗ trợ gỡ lỗi thêm.

Cài đặt
=======

Kernel của bạn phải được kích hoạt CONFIG_DEBUG_FS và CONFIG_CPUSETS. Lý tưởng nhất là bạn
môi trường thời gian chạy không sử dụng cpuset, sau đó cách ly CPU
cốt lõi là dễ nhất. Nếu bạn thực sự cần cpuset, hãy kiểm tra tập lệnh trợ giúp đó để biết
bộ phân tích logic cẩu thả không can thiệp vào các cài đặt khác của bạn.

Cho kernel biết GPIO nào được sử dụng làm đầu dò. Đối với hệ thống dựa trên Cây thiết bị,
bạn cần sử dụng các ràng buộc sau. Bởi vì những ràng buộc này chỉ dành cho
gỡ lỗi, không có lược đồ chính thức ::

máy phân tích i2c {
            tương thích = "gpio-sloppy-logic-phân tích";
            thăm dò-gpios = <&gpio6 21 GPIO_OPEN_DRAIN>, <&gpio6 4 GPIO_OPEN_DRAIN>;
            tên thăm dò = "SCL", "SDA";
    };

Lưu ý rằng bạn phải cung cấp tên cho mỗi GPIO được chỉ định. Hiện nay một
tối đa 8 đầu dò được hỗ trợ. 32 khả năng có thể xảy ra nhưng không phải
đã triển khai chưa.

Cách sử dụng
============

Bộ phân tích logic có thể được cấu hình thông qua các tệp trong debugfs. Tuy nhiên, nó là
thực sự khuyên bạn không nên sử dụng chúng trực tiếp mà nên sử dụng tập lệnh
ZZ0000ZZ. Ngoài việc kiểm tra thêm thông số
rộng rãi, nó sẽ cô lập lõi CPU để bạn có ít nhất
nhiễu loạn trong khi đo.

Tập lệnh có tùy chọn trợ giúp giải thích các tham số. Đối với DT trên
đoạn mã phân tích bus I2C ở tần số 400kHz trên bo mạch Renesas Salvator-XS,
các cài đặt sau được sử dụng: CPU bị cô lập sẽ là CPU1 vì nó lớn
lõi trong thiết lập big.LITTLE. Vì CPU1 là mặc định nên chúng ta không cần
tham số. Tốc độ xe buýt là 400kHz. Vì vậy, định lý lấy mẫu nói rằng chúng ta cần phải
mẫu ít nhất ở 800kHz. Tuy nhiên, các cạnh giảm của cả hai tín hiệu trong I2C
điều kiện bắt đầu xảy ra nhanh hơn, vì vậy chúng tôi cần tần suất lấy mẫu cao hơn, ví dụ:
ZZ0000ZZ cho 1,5 MHz. Ngoài ra, chúng tôi không muốn lấy mẫu ngay mà hãy đợi
cho một điều kiện bắt đầu trên một xe buýt nhàn rỗi. Vì vậy, chúng ta cần kích hoạt một cú rơi
cạnh trên SDA trong khi SCL vẫn ở mức cao, tức là ZZ0001ZZ. Cuối cùng là thời lượng, hãy
chúng tôi giả sử 15ms ở đây dẫn đến tham số ZZ0002ZZ. Vì vậy,
hoàn toàn::

gpio-sloppy-logic-phân tích -s 1500000 -t 1H+2F -d 15000

Lưu ý rằng quy trình sẽ đưa bạn trở lại lời nhắc nhưng quy trình phụ sẽ
vẫn đang lấy mẫu ở chế độ nền. Trừ khi việc này kết thúc, bạn sẽ không tìm thấy
tệp kết quả trong thư mục hiện tại hoặc được chỉ định. Với ví dụ trên, chúng ta
sau đó sẽ cần kích hoạt giao tiếp I2C::

i2c detect -y -r <số xe buýt của bạn>

Kết quả là một tệp .sr được sử dụng với PulseView hoặc sigrok-cli miễn phí
Dự án ZZ0000ZZ. Nó là một tệp zip cũng chứa dữ liệu mẫu nhị phân
có thể được sử dụng bởi phần mềm khác. Tên file là bộ phân tích logic
tên phiên bản cộng với dấu thời gian kể từ kỷ nguyên.

.. _sigrok: https://sigrok.org/