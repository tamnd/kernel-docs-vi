.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/gpio/gpio-sim.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Cấu hình mô phỏng GPIO
=======================

Cấu hình GPIO Simulator (gpio-sim) cung cấp cách tạo GPIO mô phỏng
chip cho mục đích thử nghiệm. Các dòng được hiển thị bởi các chip này có thể được truy cập
sử dụng giao diện thiết bị ký tự GPIO tiêu chuẩn cũng như thao tác
sử dụng thuộc tính sysfs.

Tạo chip mô phỏng
------------------------

Mô-đun gpio-sim đăng ký một hệ thống con configfs có tên ZZ0000ZZ. cho
chi tiết về hệ thống tập tin configfs, vui lòng tham khảo tài liệu configfs.

Người dùng có thể tạo một hệ thống phân cấp các nhóm và mục configfs cũng như sửa đổi
giá trị của các thuộc tính được hiển thị. Sau khi chip được khởi tạo, hệ thống phân cấp này
sẽ được dịch sang các thuộc tính thiết bị thích hợp. Cấu trúc chung là:

ZZ0001ZZ ZZ0000ZZ

Đây là thư mục trên cùng của cây configfs gpio-sim.

ZZ0001ZZ ZZ0000ZZ

ZZ0001ZZ ZZ0000ZZ

ZZ0001ZZ ZZ0000ZZ

Đây là thư mục đại diện cho thiết bị nền tảng GPIO. ZZ0000ZZ
thuộc tính chỉ đọc và cho phép không gian người dùng đọc thiết bị nền tảng
tên (ví dụ: ZZ0001ZZ). Thuộc tính ZZ0002ZZ cho phép kích hoạt
việc tạo thiết bị thực sự sau khi nó được cấu hình đầy đủ. Các giá trị được chấp nhận
là: ZZ0003ZZ để kích hoạt thiết bị mô phỏng và ZZ0004ZZ để vô hiệu hóa và xé bỏ
nó xuống.

ZZ0001ZZ ZZ0000ZZ

ZZ0001ZZ ZZ0000ZZ

ZZ0001ZZ ZZ0000ZZ

Nhóm này đại diện cho một nhóm GPIO dưới thiết bị nền tảng hàng đầu. các
Thuộc tính ZZ0000ZZ là chỉ đọc và cho phép không gian người dùng đọc
tên thiết bị của thiết bị ngân hàng. Thuộc tính ZZ0001ZZ cho phép chỉ định
số lượng dòng tiếp xúc của ngân hàng này.

ZZ0001ZZ ZZ0000ZZ

ZZ0001ZZ ZZ0000ZZ

ZZ0001ZZ ZZ0000ZZ

Nhóm này đại diện cho một dòng duy nhất tại offset Y. Thuộc tính ZZ0000ZZ
cho biết liệu đường dây có thể được sử dụng làm GPIO hay không. Thuộc tính ZZ0001ZZ cho phép
để đặt tên dòng như được biểu thị bằng thuộc tính 'gpio-line-names'.

ZZ0001ZZ ZZ0000ZZ

ZZ0001ZZ ZZ0000ZZ

ZZ0001ZZ ZZ0000ZZ

Mục này làm cho mô-đun gpio-sim chiếm giữ đường liên kết. ZZ0000ZZ
thuộc tính chỉ định tên người tiêu dùng trong kernel sẽ sử dụng. ZZ0001ZZ
thuộc tính chỉ định hướng hog và phải là một trong: ZZ0002ZZ,
ZZ0003ZZ và ZZ0004ZZ.

Bên trong mỗi thư mục ngân hàng có một tập hợp các thuộc tính có thể được sử dụng để
cấu hình chip mới. Ngoài ra, người dùng có thể thư mục con ZZ0000ZZ
bên trong thư mục của chip cho phép chuyển cấu hình bổ sung cho
những dòng cụ thể. Tên của các thư mục con đó phải có dạng:
ZZ0001ZZ (ví dụ ZZ0002ZZ, ZZ0003ZZ, v.v.) như tên sẽ là
được mô-đun sử dụng để gán cấu hình cho dòng cụ thể ở độ lệch nhất định.

Sau khi cấu hình hoàn tất, thuộc tính ZZ0000ZZ phải được đặt thành 1 trong
để khởi tạo chip. Nó có thể được đặt về 0 để hủy mô phỏng
chip. Mô-đun sẽ đồng bộ chờ thiết bị mô phỏng mới hoạt động
đã thăm dò thành công và nếu điều này không xảy ra, việc viết thư tới ZZ0001ZZ sẽ
dẫn đến một lỗi.

Các chip GPIO mô phỏng cũng có thể được xác định trong cây thiết bị. Chuỗi tương thích
phải là: ZZ0000ZZ. Các thuộc tính được hỗ trợ là:

ZZ0000ZZ-nhãn chip

Các thuộc tính GPIO tiêu chuẩn khác (như ZZ0000ZZ, ZZ0001ZZ hoặc
ZZ0002ZZ) cũng được hỗ trợ. Vui lòng tham khảo tài liệu GPIO để biết
chi tiết.

Một ví dụ về mã cây thiết bị xác định trình mô phỏng GPIO:

.. code-block :: none

    gpio-sim {
        compatible = "gpio-simulator";

        bank0 {
            gpio-controller;
            #gpio-cells = <2>;
            ngpios = <16>;
            gpio-sim,label = "dt-bank0";
            gpio-line-names = "", "sim-foo", "", "sim-bar";
        };

        bank1 {
            gpio-controller;
            #gpio-cells = <2>;
            ngpios = <8>;
            gpio-sim,label = "dt-bank1";

            line3 {
                gpio-hog;
                gpios = <3 0>;
                output-high;
                line-name = "sim-hog-from-dt";
            };
        };
    };

Thao tác mô phỏng đường nét
----------------------------

Mỗi chip GPIO mô phỏng tạo ra một nhóm sysfs riêng trong thiết bị của nó
thư mục cho mỗi dòng tiếp xúc
(ví dụ: ZZ0000ZZ). Tên của mỗi nhóm
có dạng: ZZ0001ZZ trong đó X là phần bù của dòng. Bên trong mỗi
nhóm có hai thuộc tính:

ZZ0000ZZ - cho phép đọc và thiết lập cài đặt kéo mô phỏng hiện tại cho
               mỗi dòng, khi viết giá trị phải là một trong: ZZ0001ZZ,
               ZZ0002ZZ

ZZ0000ZZ - cho phép đọc giá trị hiện tại của dòng có thể
                khác với lực kéo nếu đường được dẫn động từ
                không gian người dùng