.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/via686a.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân via686a
=================================

Chip được hỗ trợ:

* Qua VT82C686A, VT82C686B Màn hình phần cứng tích hợp Southbridge

Tiền tố: 'via686a'

Địa chỉ được quét: ISA trong địa chỉ được mã hóa khoảng trắng PCI

Bảng dữ liệu: Theo yêu cầu thông qua biểu mẫu web (ZZ0000ZZ

tác giả:
	- Kyösti Mälkki <kmalkki@cc.hut.fi>,
	- Mark D. Studebaker <mdsxyz123@yahoo.com>
	- Bob Dougherty <bobd@stanford.edu>
	- (Một số dữ liệu hệ số chuyển đổi được đóng góp bởi
	- Jonathan Teh Soon Yew <j.teh@iname.com>
	- và Alex van Kaam <darkside@chello.nl>.)

Thông số mô-đun
-----------------

====================================================================================
Force_addr=0xaddr Đặt địa chỉ cơ sở I/O. Hữu ích cho các bảng
			không đặt địa chỉ trong BIOS. Hãy tìm BIOS
			nâng cấp trước khi dùng đến điều này. Không làm một
			lực PCI; via686a vẫn phải có trong lspci.
			Đừng sử dụng điều này trừ khi người lái xe phàn nàn rằng
			địa chỉ cơ sở không được thiết lập.
			Ví dụ: 'modprobe via686a Force_addr=0x6000'
====================================================================================

Sự miêu tả
-----------

Driver không phân biệt được chip và báo
tất cả đều là 686A.

Cầu nam Via 686a có chức năng giám sát phần cứng tích hợp.
Nó cũng có bus I2C, nhưng trình điều khiển này chỉ hỗ trợ màn hình phần cứng.
Để biết trình điều khiển xe buýt I2C, hãy xem <file:Documentation/i2c/busses/i2c-viapro.rst>

Via 686a thực hiện ba cảm biến nhiệt độ, hai tốc độ quay của quạt
cảm biến, năm cảm biến điện áp và báo động.

Nhiệt độ được đo bằng độ C. Báo động được kích hoạt một lần
khi giới hạn tắt máy quá nhiệt bị vượt qua; nó lại được kích hoạt
ngay khi nó giảm xuống dưới giá trị trễ.

Tốc độ quay của quạt được báo cáo bằng RPM (số vòng quay mỗi phút). Một báo động là
được kích hoạt nếu tốc độ quay giảm xuống dưới giới hạn có thể lập trình. quạt
số đọc có thể được chia cho một bộ chia có thể lập trình (1, 2, 4 hoặc 8) để đưa ra
các bài đọc có phạm vi rộng hơn hoặc chính xác hơn. Không phải tất cả các giá trị RPM đều có thể được xác định chính xác
được đại diện, do đó một số làm tròn được thực hiện. Với số chia là 2, thấp nhất
giá trị đại diện là khoảng 2600 RPM.

Cảm biến điện áp (còn được gọi là cảm biến IN) báo cáo giá trị của chúng bằng vôn.
Cảnh báo sẽ được kích hoạt nếu điện áp vượt quá mức tối thiểu có thể lập trình
hoặc giới hạn tối đa. Điện áp được điều chỉnh nội bộ, do đó mỗi kênh điện áp
có độ phân giải và phạm vi khác nhau.

Nếu cảnh báo kích hoạt, nó sẽ vẫn được kích hoạt cho đến khi phần cứng đăng ký
được đọc ít nhất một lần. Điều này có nghĩa là nguyên nhân gây ra báo động có thể
đã biến mất rồi! Lưu ý rằng trong quá trình triển khai hiện tại, tất cả
các thanh ghi phần cứng được đọc bất cứ khi nào có dữ liệu được đọc (trừ khi nó ít hơn
hơn 1,5 giây kể từ lần cập nhật cuối cùng). Điều này có nghĩa là bạn có thể dễ dàng
bỏ lỡ các báo thức chỉ một lần.

Trình điều khiển chỉ cập nhật giá trị của nó sau mỗi 1,5 giây; đọc nó thường xuyên hơn
sẽ không gây hại gì nhưng sẽ trả về giá trị 'cũ'.

Sự cố đã biết
-------------

Trình điều khiển này xử lý các cảm biến được tích hợp trong một số cầu phía nam VIA. Đó là
có thể một nhà sản xuất bo mạch chủ đã sử dụng chip VT82C686A/B như một phần của
thiết kế sản phẩm nhưng không quan tâm đến các tính năng giám sát phần cứng của nó,
trong trường hợp đó, đầu vào cảm biến sẽ không được nối dây. Đây là trường hợp của
bo mạch chủ Asus K7V, A7V và A7V133, chỉ kể tên một vài trong số chúng.
Vì vậy, nếu bạn cần tham số Force_addr và kết thúc bằng các giá trị
dường như không có ý nghĩa gì, đừng tìm đâu xa: chip của bạn chỉ đơn giản là
không có dây để giám sát phần cứng.
