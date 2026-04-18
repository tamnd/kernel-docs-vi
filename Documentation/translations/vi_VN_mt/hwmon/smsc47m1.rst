.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/smsc47m1.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân smsc47m1
======================

Chip được hỗ trợ:

* SMSC LPC47B27x, LPC47M112, LPC47M10x, LPC47M13x, LPC47M14x,

LPC47M15x và LPC47M192

Địa chỉ được quét: không có, địa chỉ được đọc từ không gian cấu hình Super I/O

Tiền tố: 'smsc47m1'

Bảng dữ liệu:

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

ZZ0000ZZ

* SMSC LPC47M292

Địa chỉ được quét: không có, địa chỉ được đọc từ không gian cấu hình Super I/O

Tiền tố: 'smsc47m2'

Bảng dữ liệu: Không công khai

* SMSC LPC47M997

Địa chỉ được quét: không có, địa chỉ được đọc từ không gian cấu hình Super I/O

Tiền tố: 'smsc47m1'

Bảng dữ liệu: không có



tác giả:

- Mark D. Studebaker <mdsxyz123@yahoo.com>,
     - Với sự hỗ trợ từ Bruce Allen <ballen@uwm.edu>, và anh ấy
       chương trình fan.c:

-ZZ0000ZZ

- Gabriele Gorla <gorlik@yahoo.com>,
     - Jean Delvare <jdelvare@suse.de>

Sự miêu tả
-----------

Chip Super I/O 47M1xx của Standard Microsystems Corporation (SMSC)
chứa mạch giám sát và điều khiển PWM cho hai quạt.

Các chip LPC47M15x, LPC47M192 và LPC47M292 chứa đầy đủ 'phần cứng'
khối giám sát' ngoài việc giám sát và điều khiển quạt. các
khối giám sát phần cứng không được trình điều khiển này hỗ trợ, hãy sử dụng
trình điều khiển smsc47m192 cho điều đó.

Không có tài liệu nào cho 47M997, nhưng nó có cùng một thiết bị
ID là chip 47M15x và 47M192 và có vẻ tương thích.

Tốc độ quay của quạt được báo cáo bằng RPM (số vòng quay mỗi phút). Một báo động là
được kích hoạt nếu tốc độ quay giảm xuống dưới giới hạn có thể lập trình. quạt
số đọc có thể được chia cho một bộ chia có thể lập trình (1, 2, 4 hoặc 8) để đưa ra
các bài đọc có phạm vi rộng hơn hoặc chính xác hơn. Không phải tất cả các giá trị RPM đều có thể được xác định chính xác
được đại diện, do đó một số làm tròn được thực hiện. Với số chia là 2, thấp nhất
giá trị đại diện là khoảng 2600 RPM.

Giá trị PWM là từ 0 đến 255.

Nếu cảnh báo kích hoạt, nó sẽ vẫn được kích hoạt cho đến khi phần cứng đăng ký
được đọc ít nhất một lần. Điều này có nghĩa là nguyên nhân gây ra báo động có thể
đã biến mất rồi! Lưu ý rằng trong quá trình triển khai hiện tại, tất cả
các thanh ghi phần cứng được đọc bất cứ khi nào có dữ liệu được đọc (trừ khi nó ít hơn
hơn 1,5 giây kể từ lần cập nhật cuối cùng). Điều này có nghĩa là bạn có thể dễ dàng
bỏ lỡ các báo thức chỉ một lần.

------------------------------------------------------------------

Dự án lm_sensors xin chân thành cảm ơn sự hỗ trợ của
Intel trong việc phát triển trình điều khiển này.
