.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/vexpress.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân vexpress
======================

Các hệ thống được hỗ trợ:

* Nền tảng Express đa năng của ARM Ltd.

Tiền tố: 'vexpress'

Bảng dữ liệu:

* Phần "Mô tả phần cứng" của Tài liệu tham khảo kỹ thuật
	đối với bảng Express đa năng:

-ZZ0000ZZ

* Mục "4.4.14. Thanh ghi cấu hình hệ thống" của V2M-P1 TRM:

-ZZ0000ZZ

Tác giả: Pawel Moll

Sự miêu tả
-----------

Nền tảng Express đa năng (ZZ0000ZZ là một
hệ thống tham chiếu và tạo mẫu cho bộ xử lý ARM Ltd. Nó có thể được thiết lập
từ nhiều loại bảng khác nhau, mỗi bảng có chứa (ngoài bảng chính
chip/FPGA) một số bộ vi điều khiển chịu trách nhiệm về nền tảng
cấu hình và điều khiển. Những bộ vi điều khiển này cũng có thể giám sát
bo mạch và môi trường của nó bằng một số cảm biến bên trong và bên ngoài,
cung cấp thông tin về điện áp và dòng điện đường dây, bảng mạch
nhiệt độ và điện năng sử dụng. Một số người trong số họ còn tính toán năng lượng tiêu thụ
và cung cấp một bộ đếm sử dụng tích lũy.

Các thiết bị cấu hình được ánh xạ bộ nhớ _not_ và phải được truy cập
thông qua giao diện tùy chỉnh, được trừu tượng hóa bởi "vexpress_config" API.

Vì các thiết bị này không thể phát hiện được nên chúng phải được mô tả trong phần Thiết bị
Cây được truyền vào hạt nhân. Chi tiết về ràng buộc DT cho chúng có thể được tìm thấy
trong Tài liệu/devicetree/binds/hwmon/vexpress.txt.
