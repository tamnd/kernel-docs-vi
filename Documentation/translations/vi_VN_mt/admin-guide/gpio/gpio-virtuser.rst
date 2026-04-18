.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/gpio/gpio-virtuser.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Người tiêu dùng ảo GPIO
=====================

Mô-đun tiêu dùng GPIO ảo cho phép người dùng khởi tạo các thiết bị ảo
yêu cầu GPIO và sau đó kiểm soát hành vi của chúng qua các bản gỡ lỗi. ảo
thiết bị tiêu dùng có thể được khởi tạo từ cây thiết bị hoặc qua configfs.

Người tiêu dùng ảo sử dụng API GPIO đối mặt với trình điều khiển và cho phép bao phủ nó bằng
kiểm tra tự động được điều khiển bởi không gian người dùng. GPIO được yêu cầu bằng cách sử dụng
ZZ0000ZZ và do đó chúng tôi hỗ trợ nhiều GPIO cho mỗi ID trình kết nối.

Tạo người tiêu dùng GPIO
-----------------------

Mô-đun gpio-consumer đăng ký một hệ thống con configfs được gọi là
ZZ0000ZZ. Để biết chi tiết về hệ thống tập tin configfs, vui lòng tham khảo
tài liệu configfs.

Người dùng có thể tạo một hệ thống phân cấp các nhóm và mục configfs cũng như sửa đổi
giá trị của các thuộc tính được hiển thị. Sau khi người tiêu dùng được khởi tạo, hệ thống phân cấp này
sẽ được dịch sang các thuộc tính thiết bị thích hợp. Cấu trúc chung là:

ZZ0001ZZ ZZ0000ZZ

Đây là thư mục trên cùng của cây configfs gpio-consumer.

ZZ0001ZZ ZZ0000ZZ

ZZ0001ZZ ZZ0000ZZ

ZZ0001ZZ ZZ0000ZZ

Đây là thư mục đại diện cho thiết bị tiêu dùng GPIO.

Thuộc tính ZZ0000ZZ chỉ đọc hiển thị tên của thiết bị vì nó sẽ
xuất hiện trong hệ thống trên bus nền tảng. Điều này rất hữu ích cho việc định vị các
thư mục debugfs liên quan bên dưới
ZZ0001ZZ.

Thuộc tính ZZ0000ZZ cho phép kích hoạt việc tạo thiết bị thực tế
một khi nó được cấu hình đầy đủ. Các giá trị được chấp nhận là: ZZ0001ZZ để kích hoạt
thiết bị ảo và ZZ0002ZZ để vô hiệu hóa và phá bỏ nó.

Tạo bảng tra cứu GPIO
---------------------------

Người dùng có thể tạo một số nhóm configfs trong nhóm thiết bị:

ZZ0001ZZ ZZ0000ZZ

Thư mục ZZ0000ZZ đại diện cho một tra cứu GPIO duy nhất và các bản đồ giá trị của nó
đối số ZZ0001ZZ của hàm ZZ0002ZZ. Ví dụ:
ZZ0003ZZ == ZZ0004ZZ ánh xạ tới thuộc tính thiết bị ZZ0005ZZ.

Người dùng có thể chỉ định một số GPIO cho mỗi lần tra cứu. Mỗi GPIO là một thư mục con
với tên do người dùng xác định trong nhóm ZZ0000ZZ.

ZZ0001ZZ ZZ0000ZZ

ZZ0001ZZ ZZ0000ZZ

ZZ0001ZZ ZZ0000ZZ

ZZ0001ZZ ZZ0000ZZ

ZZ0001ZZ ZZ0000ZZ

ZZ0001ZZ ZZ0000ZZ

Đây là nhóm mô tả một GPIO duy nhất trong thuộc tính ZZ0000ZZ.

Đối với người tiêu dùng ảo được tạo bằng configfs, chúng tôi sử dụng bảng tra cứu máy để
nhóm này có thể được coi là ánh xạ giữa hệ thống tệp và các trường
của một mục duy nhất trong ZZ0000ZZ.

Thuộc tính ZZ0000ZZ đại diện cho tên của chip GPIO này
thuộc về hoặc tên dòng GPIO. Điều này phụ thuộc vào giá trị của ZZ0001ZZ
thuộc tính: nếu giá trị của nó >= 0 thì ZZ0002ZZ đại diện cho nhãn của
chip để tra cứu trong khi ZZ0003ZZ đại diện cho phần bù của dòng trong đó
chip. Nếu ZZ0004ZZ < 0 thì ZZ0005ZZ đại diện cho tên của dòng.

Các thuộc tính còn lại ánh xạ tới trường ZZ0000ZZ của tra cứu GPIO
struct. Hai cái đầu tiên lấy giá trị chuỗi làm đối số:

ZZ0009ZZ ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ
ZZ0010ZZ ZZ0005ZZ, ZZ0006ZZ, ZZ0007ZZ, ZZ0008ZZ

ZZ0000ZZ và ZZ0001ZZ là các thuộc tính boolean.

Kích hoạt người tiêu dùng GPIO
-------------------------

Sau khi cấu hình hoàn tất, thuộc tính ZZ0000ZZ phải được đặt thành 1 trong
để khởi tạo người tiêu dùng. Nó có thể được đặt về 0 để hủy
thiết bị ảo. Mô-đun sẽ đồng bộ chờ thiết bị mô phỏng mới
được thăm dò thành công và nếu điều này không xảy ra, việc viết thư tới ZZ0001ZZ sẽ
dẫn đến một lỗi.

Cây thiết bị
-----------

Người tiêu dùng GPIO ảo cũng có thể được xác định trong cây thiết bị. Chuỗi tương thích
phải là: ZZ0000ZZ có ít nhất một thuộc tính theo sau
mẫu GPIO được tiêu chuẩn hóa.

Một ví dụ về mã cây thiết bị xác định người tiêu dùng GPIO ảo:

.. code-block :: none

    gpio-virt-consumer {
        compatible = "gpio-virtuser";

        foo-gpios = <&gpio0 5 GPIO_ACTIVE_LOW>, <&gpio1 2 0>;
        bar-gpios = <&gpio0 6 0>;
    };

Kiểm soát người tiêu dùng GPIO ảo
----------------------------------

Sau khi kích hoạt, thiết bị sẽ xuất các thuộc tính debugfs để điều khiển GPIO
mảng cũng như từng dòng GPIO được yêu cầu riêng biệt. Hãy xem xét
thuộc tính thiết bị sau: ZZ0000ZZ.

Các nhóm thuộc tính debugfs sau sẽ được tạo:

ZZ0001ZZ ZZ0000ZZ

Đây là nhóm sẽ chứa các thuộc tính cho toàn bộ mảng GPIO.

ZZ0001ZZ ZZ0000ZZ

ZZ0001ZZ ZZ0000ZZ

Cả hai thuộc tính đều cho phép đọc và đặt mảng giá trị GPIO. Người dùng phải vượt qua
chính xác số giá trị mà mảng chứa ở dạng chuỗi
chứa các số 0 và các số biểu thị trạng thái GPIO không hoạt động và đang hoạt động
tương ứng. Trong ví dụ này: ZZ0000ZZ.

Thuộc tính ZZ0000ZZ hoạt động giống như ZZ0001ZZ nhưng kernel
sẽ thực thi lệnh gọi lại trình điều khiển GPIO trong ngữ cảnh bị gián đoạn.

ZZ0001ZZ ZZ0000ZZ

Đây là nhóm đại diện cho một GPIO duy nhất với ZZ0000ZZ là phần bù của nó
trong mảng.

ZZ0001ZZ ZZ0000ZZ

Cho phép đặt và đọc nhãn tiêu dùng của dòng GPIO.

ZZ0001ZZ ZZ0000ZZ

Cho phép thiết lập và đọc khoảng thời gian gỡ lỗi của dòng GPIO.

ZZ0001ZZ ZZ0000ZZ

ZZ0001ZZ ZZ0000ZZ

Hai thuộc tính này cho phép đặt hướng của dòng GPIO. Họ chấp nhận
"đầu vào" và "đầu ra" làm giá trị. Biến thể nguyên tử thực thi lệnh gọi lại trình điều khiển
trong bối cảnh gián đoạn.

ZZ0001ZZ ZZ0000ZZ

Nếu dòng được yêu cầu ở chế độ đầu vào, việc ghi ZZ0000ZZ vào thuộc tính này sẽ
làm cho mô-đun lắng nghe các ngắt biên trên GPIO. Viết ZZ0001ZZ vô hiệu hóa
việc giám sát. Đọc thuộc tính này trả về số lượng đăng ký hiện tại
ngắt (cả hai cạnh).

ZZ0001ZZ ZZ0000ZZ

ZZ0001ZZ ZZ0000ZZ

Cả hai thuộc tính đều cho phép đọc và đặt giá trị của các dòng GPIO được yêu cầu riêng lẻ.
Chúng chấp nhận các giá trị sau: ZZ0000ZZ và ZZ0001ZZ.