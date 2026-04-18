.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/misc-devices/c2port.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

=================
Hỗ trợ cổng C2
===============

(C) Bản quyền 2007 Rodolfo Giometti <giometti@enneenne.com>

Chương trình này là phần mềm miễn phí; bạn có thể phân phối lại nó và/hoặc sửa đổi
nó theo các điều khoản của Giấy phép Công cộng GNU được xuất bản bởi
Tổ chức Phần mềm Tự do; phiên bản 2 của Giấy phép, hoặc
(theo lựa chọn của bạn) bất kỳ phiên bản mới hơn.

Chương trình này được phân phối với hy vọng rằng nó sẽ hữu ích,
nhưng WITHOUT ANY WARRANTY; thậm chí không có sự bảo đảm ngụ ý của
MERCHANTABILITY hoặc FITNESS FOR A PARTICULAR PURPOSE.  Xem
Giấy phép Công cộng GNU để biết thêm chi tiết.



Tổng quan
--------

Driver này triển khai hỗ trợ Linux của Silicon Labs (Silabs)
Giao diện C2 được sử dụng để lập trình trong hệ thống của bộ điều khiển vi mô.

Bằng cách sử dụng trình điều khiển này, bạn có thể lập trình lại đèn flash trong hệ thống mà không cần EC2
hoặc bộ chuyển đổi gỡ lỗi EC3. Giải pháp này cũng hữu ích trong các hệ thống
nơi bộ điều khiển vi mô được kết nối thông qua các chân GPIO đặc biệt.

Tài liệu tham khảo
----------

Các tham chiếu chính của Giao diện C2 có tại (ZZ0000ZZ
Trang web Phòng thí nghiệm Silicon], xem:

- AN127: Lập trình FLASH qua giao diện C2 tại
  Tài liệu ZZ0000ZZ/TechnicalDocs/an127.pdf

- Đặc điểm kỹ thuật C2 tại
  ZZ0000ZZ

tuy nhiên nó thực hiện giao thức truyền thông nối tiếp hai dây (bit
banging) được thiết kế để cho phép lập trình, gỡ lỗi và
thử nghiệm quét ranh giới trên các thiết bị Silicon Labs có số lượng pin thấp. Hiện tại
mã này chỉ hỗ trợ lập trình flash nhưng các tiện ích mở rộng rất dễ sử dụng
thêm vào.

Sử dụng trình điều khiển
----------------

Khi trình điều khiển được tải, bạn có thể sử dụng hỗ trợ sysfs để tải C2port
thông tin hoặc đọc/ghi flash trong hệ thống::

# ls /sys/class/c2port/c2port0/
  truy cập flash_block_size flash_erase rev_id
  dev_id flash_blocks_num flash_size hệ thống con/
  sự kiện thiết lập lại flash_access flash_data

Ban đầu, quyền truy cập C2port bị vô hiệu hóa do phần cứng của bạn có thể có
những dòng như vậy được ghép kênh với các thiết bị khác để có quyền truy cập vào
C2port, bạn cần lệnh ::

# echo 1 > /sys/class/c2port/c2port0/access

sau đó bạn nên đọc ID thiết bị và ID sửa đổi của
bộ điều khiển vi mô được kết nối::

# cat/sys/class/c2port/c2port0/dev_id
  8
  # cat /sys/class/c2port/c2port0/rev_id
  1

Tuy nhiên, vì lý do bảo mật, quyền truy cập flash trong hệ thống không
chưa được bật, để làm như vậy bạn cần có lệnh ::

# echo 1 > /sys/class/c2port/c2port0/flash_access

Sau đó bạn có thể đọc toàn bộ flash::

# cat /sys/class/c2port/c2port0/flash_data > hình ảnh

xóa nó đi::

# echo 1 > /sys/class/c2port/c2port0/flash_erase

và viết nó::

Hình ảnh # cat > /sys/class/c2port/c2port0/flash_data

sau khi viết xong bạn phải reset lại máy để thực thi đoạn code mới ::

# echo 1 > /sys/class/c2port/c2port0/đặt lại