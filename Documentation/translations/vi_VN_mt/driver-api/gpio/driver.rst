.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/gpio/driver.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Giao diện trình điều khiển GPIO
=====================

Tài liệu này phục vụ như một hướng dẫn cho người viết trình điều khiển chip GPIO.

Mỗi trình điều khiển bộ điều khiển GPIO cần bao gồm tiêu đề sau, xác định
các cấu trúc được sử dụng để xác định trình điều khiển GPIO::

#include <linux/gpio/driver.h>


Đại diện nội bộ của GPIO
================================

Chip GPIO xử lý một hoặc nhiều dòng GPIO. Để được coi là chip GPIO,
các dòng phải tuân theo định nghĩa: Đầu vào/Đầu ra cho mục đích chung. Nếu
dòng không phải là mục đích chung, nó không phải là GPIO và không được xử lý bởi một
Chip GPIO. Trường hợp sử dụng mang tính biểu thị: một số dòng nhất định trong hệ thống có thể
được gọi là GPIO nhưng phục vụ một mục đích rất cụ thể nên không đáp ứng được tiêu chí
của một I/O có mục đích chung. Mặt khác, dòng trình điều khiển LED có thể được sử dụng làm
GPIO và do đó vẫn phải được xử lý bởi trình điều khiển chip GPIO.

Bên trong trình điều khiển GPIO, các dòng GPIO riêng lẻ được xác định bằng phần cứng của chúng
số, đôi khi còn được gọi là ZZ0000ZZ, là một số duy nhất
trong khoảng từ 0 đến n-1, n là số lượng GPIO được chip quản lý.

Số GPIO phần cứng phải trực quan đối với phần cứng, vì
ví dụ: nếu một hệ thống sử dụng bộ thanh ghi I/O được ánh xạ bộ nhớ trong đó 32 GPIO
các dòng được xử lý một bit trên mỗi dòng trong thanh ghi 32 bit, điều này có ý nghĩa
sử dụng độ lệch phần cứng 0..31 cho các giá trị này, tương ứng với các bit 0..31 trong
đăng ký.

Số này hoàn toàn là số nội bộ: số phần cứng của một chiếc GPIO cụ thể
dòng không bao giờ được hiển thị bên ngoài trình điều khiển.

Ngoài số nội bộ này, mỗi dòng GPIO cũng cần phải có toàn cầu
số trong không gian tên GPIO số nguyên để có thể sử dụng nó với GPIO cũ
giao diện. Do đó, mỗi chip phải có một số "cơ sở" (có thể được tự động
được chỉ định) và với mỗi dòng GPIO, số toàn cầu sẽ là (cơ sở + phần cứng
số). Mặc dù cách biểu diễn số nguyên được coi là không được dùng nữa nhưng nó vẫn
có nhiều người dùng và do đó cần được duy trì.

Vì vậy, ví dụ: một nền tảng có thể sử dụng số toàn cầu 32-159 cho GPIO, với
bộ điều khiển xác định 128 GPIO ở "cơ sở" là 32 ; trong khi nền tảng khác sử dụng
số toàn cầu 0..63 với một bộ điều khiển GPIO, 64-79 với loại khác
của bộ điều khiển GPIO và trên một bảng cụ thể 80-95 với FPGA. Di sản
các số không cần phải liền kề nhau; một trong những nền tảng đó cũng có thể sử dụng số
2000-2063 để xác định các dòng GPIO trong dãy thiết bị mở rộng I2C GPIO.


Trình điều khiển điều khiển: gpio_chip
=============================

Trong khung gpiolib, mỗi bộ điều khiển GPIO được đóng gói dưới dạng "struct
gpio_chip" (xem <linux/gpio/driver.h> để biết định nghĩa đầy đủ của nó) với các thành viên
chung cho mỗi bộ điều khiển thuộc loại đó, chúng phải được chỉ định bởi
mã trình điều khiển:

- phương pháp thiết lập hướng đường GPIO
 - các phương thức được sử dụng để truy cập các giá trị dòng GPIO
 - phương pháp thiết lập cấu hình điện cho dòng GPIO nhất định
 - phương thức trả về số IRQ được liên kết với một dòng GPIO nhất định
 - cờ cho biết liệu các cuộc gọi đến phương thức của nó có thể ngủ hay không
 - mảng tên dòng tùy chọn để xác định dòng
 - phương thức kết xuất debugfs tùy chọn (hiển thị thông tin trạng thái bổ sung)
 - số cơ sở tùy chọn (sẽ được tự động gán nếu bị bỏ qua)
 - nhãn tùy chọn để chẩn đoán và ánh xạ chip GPIO sử dụng dữ liệu nền tảng

Mã triển khai gpio_chip phải hỗ trợ nhiều phiên bản của
bộ điều khiển, tốt nhất là sử dụng mô hình trình điều khiển. Mã đó sẽ cấu hình từng
gpio_chip và phát hành gpiochip_add_data() hoặc devm_gpiochip_add_data(). Đang xóa
bộ điều khiển GPIO chắc hẳn rất hiếm; sử dụng gpiochip_remove() khi không thể tránh khỏi.

Thông thường, gpio_chip là một phần của cấu trúc dành riêng cho phiên bản với các trạng thái không
được hiển thị bởi các giao diện GPIO, chẳng hạn như đánh địa chỉ, quản lý nguồn, v.v.
Các chip như codec âm thanh sẽ có trạng thái phức tạp không phải GPIO.

Bất kỳ phương thức kết xuất debugfs nào thường bỏ qua các dòng chưa được
được yêu cầu. Họ có thể sử dụng gpiochip_is_requested(), trả về một trong hai
NULL hoặc nhãn được liên kết với dòng GPIO đó khi được yêu cầu.

Cân nhắc thời gian thực: trình điều khiển GPIO không nên sử dụng spinlock_t hoặc bất kỳ
các API có thể ngủ được (như thời gian chạy PM) trong quá trình triển khai gpio_chip (.get/.set
và lệnh gọi lại điều khiển hướng) nếu dự kiến ​​sẽ gọi API GPIO từ
bối cảnh nguyên tử trên các hạt nhân thời gian thực (bên trong các trình xử lý IRQ cứng và các trình xử lý tương tự
bối cảnh). Thông thường điều này không nên được yêu cầu.


Ngữ nghĩa cấp độ GPIO
--------------------

Các giá trị dòng gpip_chip .get/set[_multiple]() được gắn với boolean
khoảng trống [0, 1], mức thấp hoặc mức cao.

Các giá trị thấp và cao được xác định là mức thấp vật lý trên đường vào/ra tới
đầu nối như miếng đệm vật lý, chốt hoặc đường ray.

Thư viện GPIO có logic bên trong để xử lý các dòng hoạt động ở mức thấp, chẳng hạn như
như được biểu thị bằng dấu hiệu quá mức hoặc #name trong sơ đồ và trình điều khiển không nên
cố gắng đoán thứ hai giá trị logic của một dòng.

Cách người tiêu dùng xử lý các giá trị GPIO là thư viện hiện tại
giá trị ZZ0000ZZ cho người tiêu dùng. Một dòng là ZZ0001ZZ nếu nó là ZZ0002ZZ
giá trị là 1 và ZZ0003ZZ nếu giá trị logic của nó là 0. Nếu đảo ngược là
bắt buộc, việc này được xử lý bởi gpiolib và được định cấu hình bằng mô tả phần cứng
chẳng hạn như cây thiết bị hoặc ACPI có thể cho biết rõ ràng liệu một dòng có đang hoạt động hay không
cao hay thấp.

Vì các thiết bị điện tử thường chèn bộ biến tần làm giai đoạn dẫn động hoặc bảo vệ
bộ đệm phía trước dòng GPIO thì ngữ nghĩa này là một phần cần thiết
của mô tả phần cứng, để người tiêu dùng như trình điều khiển hạt nhân cần
đừng lo lắng về điều này và chẳng hạn có thể khẳng định dòng RESET được gắn với GPIO
ghim bằng cách đặt nó ở mức logic 1 ngay cả khi nó hoạt động vật lý ở mức thấp.


Cấu hình điện GPIO
-----------------------------

Các dòng GPIO có thể được cấu hình cho một số chế độ hoạt động điện bằng cách sử dụng
lệnh gọi lại .set_config(). Hiện tại API này hỗ trợ cài đặt:

- Ra mắt
- Chế độ một đầu (cống mở/nguồn mở)
- Kích hoạt điện trở kéo lên và kéo xuống

Các cài đặt này được mô tả dưới đây.

Lệnh gọi lại .set_config() sử dụng cùng các bộ liệt kê và cấu hình
ngữ nghĩa như các trình điều khiển pin chung. Đây không phải là sự trùng hợp ngẫu nhiên: đó là
có thể gán .set_config() cho hàm gpiochip_generic_config()
điều này sẽ dẫn đến việc pinctrl_gpio_set_config() được gọi và cuối cùng
kết thúc ở phần back-end điều khiển pin "đằng sau" bộ điều khiển GPIO, thường là
gần hơn với các chân thực tế. Bằng cách này, bộ điều khiển pin có thể quản lý bên dưới
liệt kê cấu hình GPIO.

Nếu sử dụng back-end bộ điều khiển pin, bộ điều khiển hoặc phần cứng GPIO
mô tả cần cung cấp "phạm vi GPIO" ánh xạ độ lệch dòng GPIO để ghim
các số trên bộ điều khiển chân cắm để chúng có thể tham chiếu chéo lẫn nhau một cách chính xác.


Dòng GPIO có hỗ trợ gỡ lỗi
--------------------------------

Gỡ lỗi là một cấu hình được đặt thành một chân cho biết rằng nó được kết nối với
công tắc hoặc nút cơ học hoặc tương tự có thể nảy lên. Nảy lên có nghĩa là
đường dây được kéo lên cao/thấp một cách nhanh chóng trong khoảng thời gian rất ngắn cho cơ khí
lý do. Điều này có thể dẫn đến giá trị không ổn định hoặc các lỗi liên tục xảy ra
trừ khi dòng được gỡ bỏ.

Việc tranh luận trong thực tế liên quan đến việc thiết lập bộ đếm thời gian khi có điều gì đó xảy ra.
dòng, đợi một lát rồi lấy mẫu lại dòng đó, để xem liệu nó có
vẫn có cùng giá trị (thấp hoặc cao). Điều này cũng có thể được lặp lại bởi một người thông minh
máy trạng thái, chờ đợi một đường dây ổn định. Trong cả hai trường hợp, nó đặt
một số mili giây nhất định để gỡ lỗi hoặc chỉ "bật/tắt" nếu thời gian đó
không thể cấu hình được.


Dòng GPIO có hỗ trợ nguồn/cống mở
-----------------------------------------

Cống hở (CMOS) hoặc bộ thu hở (TTL) có nghĩa là đường dây không được dẫn động tích cực
cao: thay vào đó bạn cung cấp cống/bộ thu làm đầu ra, vì vậy khi bóng bán dẫn
không mở, nó sẽ tạo ra trở kháng cao (ba trạng thái) đối với đường ray bên ngoài::


CMOS CONFIGURATION TTL CONFIGURATION

||--- ra +--- ra
     trong ----|ZZ0000ZZ/
            |ZZ0001ZZ
                ZZ0002ZZ\
               GND GND

Cấu hình này thường được sử dụng như một cách để đạt được một trong hai điều:

- Chuyển mức: đạt mức logic cao hơn mức silicon
  nơi đầu ra cư trú.

- Dây nghịch đảo-OR trên đường I/O, ví dụ như đường GPIO, giúp điều này trở nên khả thi
  để bất kỳ giai đoạn điều khiển nào trên dây chuyền được điều khiển ở mức thấp ngay cả khi có bất kỳ đầu ra nào khác
  đến cùng một đường đang đồng thời đẩy nó lên cao. Trường hợp đặc biệt này
  đang điều khiển các tuyến SCL và SDA của xe buýt I2C, theo định nghĩa là một
  bus dây HOẶC.

Cả hai trường hợp sử dụng đều yêu cầu đường dây phải được trang bị điện trở kéo lên. Cái này
điện trở sẽ làm cho đường dây có xu hướng lên mức cao trừ khi một trong các bóng bán dẫn trên
đường ray chủ động kéo nó xuống.

Mức trên đường dây sẽ cao tới mức VDD trên điện trở kéo lên,
có thể cao hơn mức được hỗ trợ bởi bóng bán dẫn, đạt được
chuyển cấp độ lên VDD cao hơn.

Các thiết bị điện tử tích hợp thường có tầng driver đầu ra dạng CMOS
"cực vật tổ" với một bóng bán dẫn N-MOS và một bóng bán dẫn P-MOS trong đó một trong số chúng điều khiển
đường dây ở mức cao và một trong số chúng điều khiển đường dây ở mức thấp. Đây được gọi là lực đẩy
đầu ra. "Cột vật tổ" trông giống như vậy ::

VDD
                      |
            OD ||--+
         +--/ ---o||     P-MOS-FET
         ZZ0000ZZ|--+
    TRONG --+ +------ ra
         ZZ0001ZZ|--+
         +--/ ----||     N-MOS-FET
            Hệ điều hành ||--+
                      |
                     GND

Tín hiệu đầu ra mong muốn (ví dụ: đến trực tiếp từ một số thanh ghi đầu ra GPIO)
đến IN. Các công tắc có tên "OD" và "OS" thường đóng, tạo ra
một mạch kéo đẩy.

Hãy xem xét các "công tắc" nhỏ có tên "OD" và "OS" để bật/tắt tính năng
Transistor P-MOS hoặc N-MOS ngay sau khi phân chia đầu vào. Như bạn có thể thấy,
một trong hai bóng bán dẫn sẽ hoàn toàn tê liệt nếu công tắc này mở. Cột vật tổ
sau đó được giảm đi một nửa và tạo ra trở kháng cao thay vì chủ động điều khiển đường dây
cao hoặc thấp tương ứng. Đó thường là cách mở được điều khiển bằng phần mềm
cống/nguồn hoạt động.

Một số phần cứng GPIO có cấu hình nguồn mở / nguồn mở. Một số là
đường dây cứng sẽ chỉ hỗ trợ cống mở hoặc nguồn mở bất kể
cái gì: chỉ có một bóng bán dẫn ở đó. Một số có thể cấu hình bằng phần mềm:
bằng cách lật một chút trong thanh ghi, đầu ra có thể được cấu hình là cống mở
hoặc nguồn mở, trong thực tế bằng cách nhấn mở các công tắc có nhãn "OD" và "OS"
in the drawing above.

Bằng cách vô hiệu hóa bóng bán dẫn P-MOS, đầu ra có thể được điều khiển giữa GND và
trở kháng cao (cống hở) và bằng cách vô hiệu hóa bóng bán dẫn N-MOS, đầu ra
có thể được điều khiển giữa VDD và trở kháng cao (nguồn mở). Trong trường hợp đầu tiên,
cần có một điện trở kéo lên trên đường ray đi để hoàn thành mạch và
trong trường hợp thứ hai, cần có điện trở kéo xuống trên đường ray.

Phần cứng hỗ trợ cống mở hoặc nguồn mở hoặc cả hai, có thể triển khai một
lệnh gọi lại đặc biệt trong gpio_chip: .set_config() có một cái chung
giá trị đóng gói pinconf cho biết có nên định cấu hình đường dây dưới dạng cống mở hay không,
nguồn mở hoặc kéo đẩy. Điều này sẽ xảy ra để đáp lại
Cờ GPIO_OPEN_DRAIN hoặc GPIO_OPEN_SOURCE được đặt trong tệp máy hoặc sắp tới
từ các mô tả phần cứng khác.

Nếu trạng thái này không thể được cấu hình trong phần cứng, tức là nếu phần cứng GPIO không
không hỗ trợ open Drain/open source trong phần cứng, thay vào đó thư viện GPIO sẽ
sử dụng thủ thuật: khi một dòng được đặt làm đầu ra, nếu dòng đó được gắn cờ là mở
thoát nước và giá trị đầu ra IN thấp, nó sẽ bị đẩy xuống mức thấp như bình thường. Nhưng
nếu giá trị đầu ra IN được đặt thành cao, thay vào đó ZZ0000ZZ sẽ được điều khiển ở mức cao,
thay vào đó nó sẽ được chuyển sang chế độ đầu vào, vì chế độ đầu vào tương đương với
trở kháng cao, do đó đạt được kiểu "mô phỏng cống mở": về mặt điện
hoạt động sẽ giống hệt nhau, ngoại trừ các trục trặc phần cứng có thể xảy ra
khi chuyển đổi chế độ của dòng.

Đối với cấu hình nguồn mở, nguyên tắc tương tự được sử dụng, thay vào đó
chủ động điều khiển đường dây ở mức thấp, nó được đặt thành đầu vào.


Dòng GPIO có hỗ trợ điện trở kéo lên/xuống
---------------------------------------------

Một dòng GPIO có thể hỗ trợ kéo lên/xuống bằng cách sử dụng lệnh gọi lại .set_config(). Cái này
có nghĩa là có sẵn một điện trở kéo lên hoặc kéo xuống ở đầu ra của
Dòng GPIO và điện trở này được điều khiển bằng phần mềm.

Trong các thiết kế rời rạc, điện trở kéo lên hoặc kéo xuống chỉ được hàn trên
bảng mạch. Đây không phải là thứ chúng tôi giải quyết hoặc mô hình hóa trong phần mềm. các
hầu hết bạn sẽ nghĩ về những dòng này là chúng rất có thể sẽ
được định cấu hình là cống mở hoặc nguồn mở (xem phần trên).

Lệnh gọi lại .set_config() chỉ có thể bật và tắt kéo lên hoặc xuống và sẽ
không có bất kỳ kiến thức ngữ nghĩa nào về điện trở được sử dụng. Nó sẽ chỉ nói
chuyển đổi một chút trong thanh ghi để bật hoặc tắt tính năng kéo lên hoặc kéo xuống.

Nếu dòng GPIO hỗ trợ chuyển hướng ở các giá trị điện trở khác nhau cho
điện trở kéo lên hoặc kéo xuống, lệnh gọi lại chip GPIO .set_config() sẽ không
đủ. Đối với những trường hợp sử dụng phức tạp này, bộ điều khiển chân và chip GPIO kết hợp
cần được triển khai, vì giao diện cấu hình chân cắm của bộ điều khiển chân cắm
hỗ trợ kiểm soát linh hoạt hơn các đặc tính điện và có thể xử lý
giá trị điện trở kéo lên hoặc kéo xuống khác nhau.


Trình điều khiển GPIO cung cấp IRQ
===========================

Theo thông lệ, trình điều khiển GPIO (chip GPIO) cũng cung cấp các ngắt,
thường được xếp tầng khỏi bộ điều khiển ngắt chính và trong một số trường hợp đặc biệt
trong trường hợp logic GPIO được kết hợp với bộ điều khiển ngắt chính của SoC.

Các phần IRQ của khối GPIO được triển khai bằng irq_chip, sử dụng
tiêu đề <linux/irq.h>. Vì vậy, trình điều khiển kết hợp này đang sử dụng hai
hệ thống đồng thời: gpio và irq.

Việc bất kỳ người tiêu dùng IRQ nào yêu cầu IRQ từ bất kỳ irqchip nào là hợp pháp ngay cả khi nó
là trình điều khiển GPIO+IRQ kết hợp. Tiền đề cơ bản là gpio_chip và
irq_chip trực giao và cung cấp các dịch vụ độc lập với nhau
khác.

gpiod_to_irq() chỉ là một hàm tiện lợi để tìm ra IRQ cho một
một số dòng GPIO nhất định và không được coi là đã được gọi trước đó
IRQ được sử dụng.

Luôn chuẩn bị phần cứng và sẵn sàng hoạt động trong các trường hợp tương ứng
lệnh gọi lại từ API GPIO và irq_chip. Đừng dựa vào gpiod_to_irq() có
được gọi đầu tiên.

Chúng ta có thể chia irqchip GPIO thành hai loại chính:

- CASCADED INTERRUPT CHIPS: điều này có nghĩa là chip GPIO có một điểm chung
  dòng đầu ra ngắt, được kích hoạt bởi bất kỳ dòng GPIO nào được kích hoạt trên đó
  chip. Dòng đầu ra ngắt sau đó sẽ được định tuyến đến ngắt chính
  bộ điều khiển tăng một cấp, trong trường hợp đơn giản nhất là hệ thống chính
  bộ điều khiển ngắt. Điều này được mô hình hóa bởi một irqchip sẽ kiểm tra các bit
  bên trong bộ điều khiển GPIO để tìm ra dòng nào kích hoạt nó. iqchip
  một phần của người lái xe cần kiểm tra sổ đăng ký để tìm ra điều này và nó
  có thể cũng sẽ cần phải thừa nhận rằng nó đang xử lý ngắt
  bằng cách xóa một số bit (đôi khi ngầm, chỉ bằng cách đọc trạng thái
  register) và thường sẽ cần thiết lập cấu hình như
  độ nhạy cạnh (cạnh tăng hoặc giảm, hoặc ngắt mức cao/thấp đối với
  ví dụ).

- HIERARCHICAL INTERRUPT CHIPS: điều này có nghĩa là mỗi dòng GPIO đều có một thiết bị chuyên dụng
  irq tới bộ điều khiển ngắt chính tăng lên một cấp. không cần thiết
  để hỏi phần cứng GPIO để tìm ra đường nào đã kích hoạt, nhưng nó
  vẫn có thể cần thiết để xác nhận sự gián đoạn và thiết lập cấu hình
  chẳng hạn như độ nhạy của cạnh.

Cân nhắc về thời gian thực: không nên sử dụng trình điều khiển GPIO tuân thủ thời gian thực
spinlock_t hoặc bất kỳ API có thể ngủ nào (như thời gian chạy PM) như một phần của irqchip của nó
thực hiện.

- spinlock_t nên được thay thế bằng raw_spinlock_t.[1]
- Nếu phải sử dụng API có thể ngủ, bạn có thể thực hiện việc này từ .irq_bus_lock()
  và các lệnh gọi lại .irq_bus_unlock(), vì đây là các lệnh gọi lại đường dẫn chậm duy nhất
  trên một irqchip. Tạo lệnh gọi lại nếu cần.[2]


Chip irqchip GPIO xếp tầng
----------------------

Các chip irqchip GPIO xếp tầng thường thuộc một trong ba loại:

- CHAINED CASCADED GPIO IRQCHIPS: đây thường là loại được nhúng trên
  một SoC. Điều này có nghĩa là có một trình xử lý luồng IRQ nhanh cho GPIO
  được gọi trong một chuỗi từ trình xử lý IRQ gốc, điển hình nhất là
  bộ điều khiển ngắt hệ thống. Điều này có nghĩa là trình xử lý irqchip GPIO sẽ
  được gọi ngay lập tức từ irqchip mẹ trong khi vẫn giữ các IRQ
  bị vô hiệu hóa. GPIO irqchip sau đó sẽ gọi một cái gì đó như thế này
  trình tự trong trình xử lý ngắt của nó::

irqreturn_t tĩnh foo_gpio_irq(int irq, void *data)
        chained_irq_enter(...);
        generic_handle_irq(...);
        chained_irq_exit(...);

Các irqchip GPIO được xâu chuỗi thường có thể NOT bật cờ .can_sleep
  struct gpio_chip, vì mọi thứ diễn ra trực tiếp trong lệnh gọi lại: không
  Có thể sử dụng lưu lượng xe buýt chậm như I2C.

Cân nhắc theo thời gian thực: Lưu ý rằng trình xử lý IRQ được xâu chuỗi sẽ không bị ép buộc
  luồng trên -RT. Kết quả là spinlock_t hoặc bất kỳ API có thể ngủ nào (như PM
  thời gian chạy) không thể được sử dụng trong trình xử lý IRQ bị xâu chuỗi.

Nếu được yêu cầu (và nếu nó không thể được chuyển đổi thành irqchip GPIO có luồng lồng nhau,
  xem bên dưới) trình xử lý IRQ có chuỗi có thể được chuyển đổi thành trình xử lý irq chung và
  bằng cách này, nó sẽ trở thành trình xử lý IRQ theo luồng trên -RT và trình xử lý IRQ cứng
  trên non-RT (ví dụ, xem [3]).

generic_handle_irq() dự kiến sẽ được gọi khi IRQ bị vô hiệu hóa,
  vì vậy lõi IRQ sẽ phàn nàn nếu nó được gọi từ trình xử lý IRQ.
  buộc vào một chủ đề. "Giả?" khóa thô có thể được sử dụng để giải quyết vấn đề này
  vấn đề::

raw_spinlock_t wa_lock;
    irqreturn_t tĩnh omap_gpio_irq_handler(int irq, void *gpiobank)
        wa_lock_flags dài không dấu;
        raw_spin_lock_irqsave(&bank->wa_lock, wa_lock_flags);
        generic_handle_irq(irq_find_mapping(bank->chip.irq.domain, bit));
        raw_spin_unlock_irqrestore(&bank->wa_lock, wa_lock_flags);

- GENERIC CHAINED GPIO IRQCHIPS: chúng giống như "CHAINED GPIO irqchips",
  nhưng trình xử lý IRQ có chuỗi không được sử dụng. Thay vào đó việc gửi IRQ GPIO là
  được thực hiện bởi trình xử lý IRQ chung được định cấu hình bằng request_irq().
  Sau đó, irqchip GPIO sẽ kết thúc việc gọi một cái gì đó giống như trình tự này trong
  trình xử lý ngắt của nó::

irqreturn_t tĩnh gpio_rcar_irq_handler(int irq, void *dev_id)
        cho mỗi GPIO IRQ được phát hiện
            generic_handle_irq(...);

Những cân nhắc về thời gian thực: loại trình xử lý này sẽ buộc phải được xử lý theo luồng trên -RT,
  và kết quả là lõi IRQ sẽ phàn nàn rằng generic_handle_irq() được gọi
  với IRQ được kích hoạt và cách giải quyết tương tự như đối với "CHAINED GPIO irqchips" có thể
  được áp dụng.

- NESTED THREADED GPIO IRQCHIPS: đây là các bộ mở rộng GPIO ngoài chip và bất kỳ bộ mở rộng nào
  irqchip GPIO khác nằm ở phía bên kia của xe buýt ngủ chẳng hạn như I2C
  hoặc SPI.

Tất nhiên những người lái xe cần lưu lượng xe buýt chậm để đọc trạng thái IRQ và
  tương tự, lưu lượng truy cập có thể gây ra các IRQ khác sẽ xảy ra, không thể
  được xử lý trong trình xử lý IRQ nhanh chóng với IRQ bị tắt. Thay vào đó chúng cần sinh sản
  một luồng và sau đó che dấu dòng IRQ gốc cho đến khi xử lý được ngắt
  bởi người lái xe. Đặc điểm nổi bật của trình điều khiển này là gọi một cái gì đó như
  cái này trong trình xử lý ngắt của nó ::

irqreturn_t tĩnh foo_gpio_irq(int irq, void *data)
        ...
xử lý_nested_irq(irq);

Đặc điểm nổi bật của irqchip GPIO có luồng là chúng đặt .can_sleep
  gắn cờ trên struct gpio_chip thành true, cho biết chip này có thể ngủ
  khi truy cập GPIO.

Những loại irqchip này vốn có khả năng chịu đựng thời gian thực vì chúng
  đã được thiết lập để xử lý bối cảnh ngủ.


Người trợ giúp cơ sở hạ tầng cho irqchip GPIO
----------------------------------------

Để giúp xử lý việc thiết lập và quản lý các irqchip GPIO và
các cuộc gọi lại phân bổ tài nguyên và irqdomain liên quan. Chúng được kích hoạt
bằng cách chọn biểu tượng Kconfig GPIOLIB_IRQCHIP. Nếu biểu tượng
IRQ_DOMAIN_HIERARCHY cũng được chọn, những người trợ giúp theo cấp bậc cũng sẽ được
được cung cấp. Một phần lớn mã nguồn sẽ được quản lý bởi gpiolib,
theo giả định rằng các ngắt của bạn được ánh xạ 1-1 tới
Chỉ số dòng GPIO:

.. csv-table::
    :header: GPIO line offset, Hardware IRQ

    0,0
    1,1
    2,2
    ...,...
    ngpio-1, ngpio-1


Nếu một số dòng GPIO không có IRQ tương ứng, bitmask valid_mask
và cờ need_valid_mask trong gpio_irq_chip có thể được sử dụng để che giấu một số
các dòng không hợp lệ để liên kết với IRQ.

Cách ưa thích để thiết lập người trợ giúp là điền vào
struct gpio_irq_chip bên trong struct gpio_chip trước khi thêm gpio_chip.
Nếu bạn làm điều này, irq_chip bổ sung sẽ được gpiolib thiết lập tại
đồng thời với việc thiết lập phần còn lại của chức năng GPIO. Sau đây
là một ví dụ điển hình về trình xử lý ngắt xếp tầng theo chuỗi sử dụng
gpio_irq_chip. Lưu ý cách hoạt động của mặt nạ/vạch mặt (hoặc tắt/bật)
gọi vào mã gpiolib cốt lõi:

.. code-block:: c

  /* Typical state container */
  struct my_gpio {
      struct gpio_chip gc;
  };

  static void my_gpio_mask_irq(struct irq_data *d)
  {
      struct gpio_chip *gc = irq_data_get_irq_chip_data(d);
      irq_hw_number_t hwirq = irqd_to_hwirq(d);

      /*
       * Perform any necessary action to mask the interrupt,
       * and then call into the core code to synchronise the
       * state.
       */

      gpiochip_disable_irq(gc, hwirq);
  }

  static void my_gpio_unmask_irq(struct irq_data *d)
  {
      struct gpio_chip *gc = irq_data_get_irq_chip_data(d);
      irq_hw_number_t hwirq = irqd_to_hwirq(d);

      gpiochip_enable_irq(gc, hwirq);

      /*
       * Perform any necessary action to unmask the interrupt,
       * after having called into the core code to synchronise
       * the state.
       */
  }

  /*
   * Statically populate the irqchip. Note that it is made const
   * (further indicated by the IRQCHIP_IMMUTABLE flag), and that
   * the GPIOCHIP_IRQ_RESOURCE_HELPER macro adds some extra
   * callbacks to the structure.
   */
  static const struct irq_chip my_gpio_irq_chip = {
      .name		= "my_gpio_irq",
      .irq_ack		= my_gpio_ack_irq,
      .irq_mask		= my_gpio_mask_irq,
      .irq_unmask	= my_gpio_unmask_irq,
      .irq_set_type	= my_gpio_set_irq_type,
      .flags		= IRQCHIP_IMMUTABLE,
      /* Provide the gpio resource callbacks */
      GPIOCHIP_IRQ_RESOURCE_HELPERS,
  };

  int irq; /* from platform etc */
  struct my_gpio *g;
  struct gpio_irq_chip *girq;

  /* Get a pointer to the gpio_irq_chip */
  girq = &g->gc.irq;
  gpio_irq_chip_set_chip(girq, &my_gpio_irq_chip);
  girq->parent_handler = ftgpio_gpio_irq_handler;
  girq->num_parents = 1;
  girq->parents = devm_kcalloc(dev, 1, sizeof(*girq->parents),
                               GFP_KERNEL);
  if (!girq->parents)
      return -ENOMEM;
  girq->default_type = IRQ_TYPE_NONE;
  girq->handler = handle_bad_irq;
  girq->parents[0] = irq;

  return devm_gpiochip_add_data(dev, &g->gc, g);

Trình trợ giúp cũng hỗ trợ sử dụng các ngắt theo luồng. Sau đó bạn chỉ cần yêu cầu
ngắt riêng biệt và đi với nó:

.. code-block:: c

  /* Typical state container */
  struct my_gpio {
      struct gpio_chip gc;
  };

  static void my_gpio_mask_irq(struct irq_data *d)
  {
      struct gpio_chip *gc = irq_data_get_irq_chip_data(d);
      irq_hw_number_t hwirq = irqd_to_hwirq(d);

      /*
       * Perform any necessary action to mask the interrupt,
       * and then call into the core code to synchronise the
       * state.
       */

      gpiochip_disable_irq(gc, hwirq);
  }

  static void my_gpio_unmask_irq(struct irq_data *d)
  {
      struct gpio_chip *gc = irq_data_get_irq_chip_data(d);
      irq_hw_number_t hwirq = irqd_to_hwirq(d);

      gpiochip_enable_irq(gc, hwirq);

      /*
       * Perform any necessary action to unmask the interrupt,
       * after having called into the core code to synchronise
       * the state.
       */
  }

  /*
   * Statically populate the irqchip. Note that it is made const
   * (further indicated by the IRQCHIP_IMMUTABLE flag), and that
   * the GPIOCHIP_IRQ_RESOURCE_HELPER macro adds some extra
   * callbacks to the structure.
   */
  static const struct irq_chip my_gpio_irq_chip = {
      .name		= "my_gpio_irq",
      .irq_ack		= my_gpio_ack_irq,
      .irq_mask		= my_gpio_mask_irq,
      .irq_unmask	= my_gpio_unmask_irq,
      .irq_set_type	= my_gpio_set_irq_type,
      .flags		= IRQCHIP_IMMUTABLE,
      /* Provide the gpio resource callbacks */
      GPIOCHIP_IRQ_RESOURCE_HELPERS,
  };

  int irq; /* from platform etc */
  struct my_gpio *g;
  struct gpio_irq_chip *girq;

  ret = devm_request_threaded_irq(dev, irq, NULL, irq_thread_fn,
                                  IRQF_ONESHOT, "my-chip", g);
  if (ret < 0)
      return ret;

  /* Get a pointer to the gpio_irq_chip */
  girq = &g->gc.irq;
  gpio_irq_chip_set_chip(girq, &my_gpio_irq_chip);
  /* This will let us handle the parent IRQ in the driver */
  girq->parent_handler = NULL;
  girq->num_parents = 0;
  girq->parents = NULL;
  girq->default_type = IRQ_TYPE_NONE;
  girq->handler = handle_bad_irq;

  return devm_gpiochip_add_data(dev, &g->gc, g);

Trình trợ giúp cũng hỗ trợ sử dụng bộ điều khiển ngắt phân cấp.
Trong trường hợp này, thiết lập thông thường sẽ như thế này:

.. code-block:: c

  /* Typical state container with dynamic irqchip */
  struct my_gpio {
      struct gpio_chip gc;
      struct fwnode_handle *fwnode;
  };

  static void my_gpio_mask_irq(struct irq_data *d)
  {
      struct gpio_chip *gc = irq_data_get_irq_chip_data(d);
      irq_hw_number_t hwirq = irqd_to_hwirq(d);

      /*
       * Perform any necessary action to mask the interrupt,
       * and then call into the core code to synchronise the
       * state.
       */

      gpiochip_disable_irq(gc, hwirq);
      irq_mask_mask_parent(d);
  }

  static void my_gpio_unmask_irq(struct irq_data *d)
  {
      struct gpio_chip *gc = irq_data_get_irq_chip_data(d);
      irq_hw_number_t hwirq = irqd_to_hwirq(d);

      gpiochip_enable_irq(gc, hwirq);

      /*
       * Perform any necessary action to unmask the interrupt,
       * after having called into the core code to synchronise
       * the state.
       */

      irq_mask_unmask_parent(d);
  }

  /*
   * Statically populate the irqchip. Note that it is made const
   * (further indicated by the IRQCHIP_IMMUTABLE flag), and that
   * the GPIOCHIP_IRQ_RESOURCE_HELPER macro adds some extra
   * callbacks to the structure.
   */
  static const struct irq_chip my_gpio_irq_chip = {
      .name		= "my_gpio_irq",
      .irq_ack		= my_gpio_ack_irq,
      .irq_mask		= my_gpio_mask_irq,
      .irq_unmask	= my_gpio_unmask_irq,
      .irq_set_type	= my_gpio_set_irq_type,
      .flags		= IRQCHIP_IMMUTABLE,
      /* Provide the gpio resource callbacks */
      GPIOCHIP_IRQ_RESOURCE_HELPERS,
  };

  struct my_gpio *g;
  struct gpio_irq_chip *girq;

  /* Get a pointer to the gpio_irq_chip */
  girq = &g->gc.irq;
  gpio_irq_chip_set_chip(girq, &my_gpio_irq_chip);
  girq->default_type = IRQ_TYPE_NONE;
  girq->handler = handle_bad_irq;
  girq->fwnode = g->fwnode;
  girq->parent_domain = parent;
  girq->child_to_parent_hwirq = my_gpio_child_to_parent_hwirq;

  return devm_gpiochip_add_data(dev, &g->gc, g);

Như bạn có thể thấy khá giống nhau, nhưng bạn không cung cấp trình xử lý cha cho
IRQ, thay vào đó là irqdomain gốc, một fwnode cho phần cứng và
một hàm .child_to_parent_hwirq() có mục đích tra cứu
irq phần cứng gốc từ irq phần cứng con (tức là chip gpio này).
Như thường lệ, bạn nên xem các ví dụ trong cây hạt nhân để được tư vấn
về cách tìm các mảnh cần thiết.

Nếu có nhu cầu loại trừ một số dòng GPIO nhất định khỏi miền IRQ được xử lý bởi
những người trợ giúp này, chúng ta có thể đặt .irq.need_valid_mask của gpiochip trước
devm_gpiochip_add_data() hoặc gpiochip_add_data() được gọi. Điều này phân bổ một
.irq.valid_mask với số bit được đặt bằng số dòng GPIO trong chip, mỗi dòng
bit đại diện cho dòng 0..n-1. Trình điều khiển có thể loại trừ các dòng GPIO bằng cách xóa bit
từ mặt nạ này. Mặt nạ có thể được điền vào hàm gọi lại init_valid_mask()
đó là một phần của cấu trúc gpio_irq_chip.

Để sử dụng trợ giúp, vui lòng lưu ý những điều sau:

- Đảm bảo chỉ định tất cả các thành viên có liên quan của struct gpio_chip để
  irqchip có thể khởi tạo. Ví dụ. .dev và .can_sleep sẽ được thiết lập
  đúng cách.

- Trên danh nghĩa, đặt gpio_irq_chip.handler thành hand_bad_irq. Sau đó, nếu irqchip của bạn
  được xếp tầng, hãy đặt trình xử lý thành Handle_level_irq() và/hoặc Handle_edge_irq()
  trong cuộc gọi lại irqchip .set_type() tùy thuộc vào bộ điều khiển của bạn
  hỗ trợ và những gì được yêu cầu bởi người tiêu dùng.


Khóa sử dụng IRQ
-----------------

Vì GPIO và irq_chip trực giao nên chúng ta có thể xảy ra xung đột giữa các
trường hợp sử dụng. Ví dụ: dòng GPIO được sử dụng cho IRQ phải là dòng đầu vào,
việc kích hoạt các ngắt trên đầu ra GPIO là vô nghĩa.

Nếu có sự cạnh tranh bên trong hệ thống con bên nào đang sử dụng
tài nguyên (một dòng GPIO nhất định và đăng ký chẳng hạn) nó cần từ chối
một số hoạt động nhất định và theo dõi việc sử dụng bên trong hệ thống con gpiolib.

GPIO đầu vào có thể được sử dụng làm tín hiệu IRQ. Khi điều này xảy ra, một trình điều khiển được yêu cầu
để đánh dấu GPIO đang được sử dụng làm IRQ::

int gpiochip_lock_as_irq(struct gpio_chip *chip, unsigned int offset)

Điều này sẽ ngăn việc sử dụng các API GPIO không liên quan đến IRQ cho đến khi khóa GPIO IRQ
được phát hành::

void gpiochip_unlock_as_irq(struct gpio_chip *chip, unsigned int offset)

Khi triển khai irqchip bên trong trình điều khiển GPIO, hai chức năng này sẽ
thường được gọi trong các lệnh gọi lại .startup() và .shutdown() từ
irqchip.

Khi sử dụng trình trợ giúp gpiolib irqchip, các cuộc gọi lại này sẽ tự động được thực hiện
được giao.


Vô hiệu hóa và kích hoạt IRQ
---------------------------

Trong một số trường hợp sử dụng (ngoài lề), trình điều khiển có thể đang sử dụng dòng GPIO làm đầu vào cho IRQ,
nhưng thỉnh thoảng chuyển dòng đó sang đầu ra điều khiển và sau đó quay lại
một đầu vào bị gián đoạn một lần nữa. Điều này xảy ra trên những thứ như CEC (Consumer
Điều khiển điện tử).

Khi GPIO được sử dụng làm tín hiệu IRQ thì gpiolib cũng cần biết liệu
IRQ được bật hoặc tắt. Để thông báo cho gpiolib về điều này,
trình điều khiển irqchip nên gọi::

void gpiochip_disable_irq(struct gpio_chip *chip, unsigned int offset)

Điều này cho phép các trình điều khiển điều khiển GPIO làm đầu ra trong khi IRQ là
bị vô hiệu hóa. Khi IRQ được bật lại, trình điều khiển sẽ gọi::

void gpiochip_enable_irq(struct gpio_chip *chip, unsigned int offset)

Khi triển khai irqchip bên trong trình điều khiển GPIO, hai chức năng này sẽ
thường được gọi trong các lệnh gọi lại .irq_disable() và .irq_enable() từ
irqchip.

Khi IRQCHIP_IMMUTABLE không được irqchip quảng cáo, các lệnh gọi lại này
được tự động gán. Hành vi này không được dùng nữa và đang được áp dụng
sẽ bị loại bỏ khỏi kernel.


Tuân thủ thời gian thực cho chip GPIO IRQ
---------------------------------------

Bất kỳ nhà cung cấp irqchip nào cũng cần được điều chỉnh cẩn thận để hỗ trợ Thời gian thực
quyền ưu tiên. Điều mong muốn là tất cả các irqchip trong hệ thống con GPIO đều giữ được điều này
trong tâm trí và thực hiện kiểm tra thích hợp để đảm bảo chúng hoạt động theo thời gian thực.

Vì vậy, hãy chú ý đến những cân nhắc về thời gian thực ở trên trong tài liệu.

Sau đây là danh sách kiểm tra cần tuân theo khi chuẩn bị trình điều khiển cho thời gian thực
tuân thủ:

- đảm bảo spinlock_t không được sử dụng như một phần triển khai irq_chip
- đảm bảo rằng các API có thể ngủ không được sử dụng như một phần triển khai irq_chip
  Nếu phải sử dụng các API có thể ngủ, chúng có thể được thực hiện từ .irq_bus_lock()
  và các lệnh gọi lại .irq_bus_unlock()
- Các irqchip GPIO được xâu chuỗi: đảm bảo spinlock_t hoặc bất kỳ API có thể ngủ nào không được sử dụng
  từ bộ xử lý IRQ bị xích
- Các irqchip GPIO được xâu chuỗi chung: quan tâm đến các lệnh gọi generic_handle_irq() và
  áp dụng cách giải quyết tương ứng
- Irqchip GPIO được xâu chuỗi: loại bỏ trình xử lý IRQ bị xâu chuỗi và sử dụng irq chung
  xử lý nếu có thể
- regmap_mmio: có thể tắt khóa nội bộ trong regmap bằng cách cài đặt
  .disable_locking và xử lý việc khóa trong trình điều khiển GPIO
- Kiểm tra trình điều khiển của bạn bằng các trường hợp kiểm tra thời gian thực trong kernel thích hợp cho cả hai
  IRQ cấp và cạnh

* [1] ZZ0000ZZ
* [2] ZZ0001ZZ
* [3] ZZ0002ZZ


Yêu cầu chân GPIO tự sở hữu
===============================

Đôi khi sẽ rất hữu ích khi cho phép trình điều khiển chip GPIO yêu cầu GPIO của riêng nó
mô tả thông qua gpiolib API. Trình điều khiển GPIO có thể sử dụng như sau
chức năng yêu cầu và mô tả miễn phí::

cấu trúc gpio_desc *gpiochip_request_own_desc(struct gpio_desc *desc,
                                              u16 hwnum,
                                              const char *nhãn,
                                              cờ enum gpiod_flags)

void gpiochip_free_own_desc(struct gpio_desc *desc)

Bộ mô tả được yêu cầu với gpiochip_request_own_desc() phải được phát hành cùng với
gpiochip_free_own_desc().

Các chức năng này phải được sử dụng cẩn thận vì chúng không ảnh hưởng đến việc sử dụng mô-đun
đếm. Không sử dụng các chức năng để yêu cầu bộ mô tả gpio không thuộc sở hữu của
gọi tài xế.
