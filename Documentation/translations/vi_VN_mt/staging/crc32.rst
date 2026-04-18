.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/staging/crc32.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Hướng dẫn ngắn gọn về tính toán CRC
====================================

CRC là số dư chia dài.  Bạn thêm CRC vào tin nhắn,
và toàn bộ nội dung (tin nhắn+CRC) là bội số của giá trị đã cho
Đa thức CRC.  Để kiểm tra CRC, bạn có thể kiểm tra xem
CRC khớp với giá trị được tính toán lại, ZZ0000ZZ bạn có thể kiểm tra xem
phần còn lại được tính toán trên tin nhắn+CRC là 0. Cách tiếp cận sau này
được sử dụng bởi rất nhiều triển khai phần cứng và đó là lý do tại sao rất nhiều
các giao thức đặt cờ kết thúc khung sau CRC.

Thực ra đây là cùng một phép chia dài mà bạn đã học ở trường, ngoại trừ:

- Chúng ta đang làm việc ở dạng nhị phân nên các chữ số chỉ là 0 và 1, và
- Khi chia đa thức không có lũy thừa.  Thay vì thêm và
  trừ đi, chúng ta chỉ xor.  Vì vậy, chúng ta có xu hướng hơi cẩu thả trong việc
  sự khác biệt giữa cộng và trừ.

Giống như mọi phép chia, số dư luôn nhỏ hơn số chia.
Để tạo ra CRC 32 bit, số chia thực sự là đa thức CRC 33 bit.
Vì nó dài 33 bit nên bit 32 luôn được đặt, do đó thông thường
CRC được viết ở dạng hex với bit quan trọng nhất bị bỏ qua.  (Nếu bạn
quen thuộc với định dạng dấu phẩy động IEEE 754, đó là ý tưởng tương tự.)

Lưu ý rằng CRC được tính toán trên một chuỗi ZZ0000ZZ, vì vậy bạn có
để quyết định độ bền của các bit trong mỗi byte.  Để có được
các thuộc tính phát hiện lỗi tốt nhất, điều này phải tương ứng với
thứ tự chúng thực sự được gửi đi.  Ví dụ: nối tiếp RS-232 tiêu chuẩn là
endian nhỏ; bit quan trọng nhất (đôi khi được sử dụng cho tính chẵn lẻ)
được gửi cuối cùng.  Và khi thêm từ CRC vào tin nhắn, bạn nên
làm điều đó theo đúng thứ tự, phù hợp với độ bền.

Giống như phép chia thông thường, bạn thực hiện mỗi lần một chữ số (bit).
Mỗi bước chia bạn lấy thêm một chữ số (bit) của số bị chia
và nối nó vào phần còn lại hiện tại.  Sau đó bạn tìm hiểu
bội số thích hợp của số chia để trừ để lấy số dư
trở lại phạm vi.  Trong hệ nhị phân, điều này thật dễ dàng - nó phải là 0 hoặc 1,
và để hủy XOR, nó chỉ là bản sao của bit 32 còn lại.

Khi tính toán CRC, chúng ta không quan tâm đến thương số, vì vậy chúng ta có thể
vứt bỏ bit thương, nhưng trừ đi bội số thích hợp của
đa thức từ phần còn lại và chúng ta quay lại nơi chúng ta bắt đầu,
sẵn sàng xử lý bit tiếp theo.

CRC lớn hơn được viết theo cách này sẽ được mã hóa như sau:

for (i = 0; i < input_bits; i++) {
		bội số = số dư & 0x80000000? CRCPOLY : 0;
		phần dư = (phần dư << 1 | next_input_bit()) ^ bội số;
	}

Lưu ý làm thế nào để có được bit 32 của phần còn lại được dịch chuyển, chúng ta xem xét
ở bit 31 của phần còn lại ZZ0000ZZ dịch chuyển nó.

Nhưng cũng hãy chú ý cách chúng ta chuyển các bit next_input_bit() sang
phần còn lại không thực sự ảnh hưởng đến bất kỳ việc ra quyết định nào cho đến khi
32 bit sau.  Vì vậy, 32 chu kỳ đầu tiên của bộ phim này khá nhàm chán.
Ngoài ra, để thêm CRC vào tin nhắn, chúng ta cần một lỗ dài 32 bit cho nó tại
cuối cùng, vì vậy chúng ta phải thêm 32 chu kỳ bổ sung chuyển về số 0 ở
cuối mỗi tin nhắn.

Những chi tiết này dẫn đến một thủ thuật tiêu chuẩn: sắp xếp lại việc hợp nhất trong
next_input_bit() cho đến thời điểm cần thiết.  Sau đó 32 chu kỳ đầu tiên
có thể được tính toán trước và hợp nhất trong 32 bit 0 cuối cùng để nhường chỗ
đối với CRC có thể được bỏ qua hoàn toàn.  Điều này thay đổi mã thành::

for (i = 0; i < input_bits; i++) {
		phần còn lại ^= next_input_bit() << 31;
		bội số = (số dư & 0x80000000)? CRCPOLY : 0;
		phần dư = (phần dư << 1) ^ bội số;
	}

Với sự tối ưu hóa này, mã little-endian đặc biệt đơn giản::

for (i = 0; i < input_bits; i++) {
		phần còn lại ^= next_input_bit();
		bội số = (số dư & 1)? CRCPOLY : 0;
		phần dư = (phần dư >> 1) ^ bội số;
	}

Hệ số có ý nghĩa nhất của đa thức còn lại được lưu trữ
trong bit có ý nghĩa nhỏ nhất của biến "phần dư" nhị phân.
Các chi tiết khác về tuổi thọ đã bị ẩn trong CRCPOLY (phải
được đảo ngược bit) và next_input_bit().

Miễn là next_input_bit trả về các bit theo thứ tự hợp lý, chúng tôi sẽ không
ZZ0000ZZ để đợi đến thời điểm cuối cùng có thể để hợp nhất các bit bổ sung.
Chúng ta có thể thực hiện 8 bit mỗi lần thay vì 1 bit mỗi lần::

for (i = 0; i < input_bytes; i++) {
		phần còn lại ^= next_input_byte() << 24;
		vì (j = 0; j < 8; j++) {
			bội số = (số dư & 0x80000000)? CRCPOLY : 0;
			phần dư = (phần dư << 1) ^ bội số;
		}
	}

Hoặc ở dạng endian nhỏ::

for (i = 0; i < input_bytes; i++) {
		phần còn lại ^= next_input_byte();
		vì (j = 0; j < 8; j++) {
			bội số = (số dư & 1)? CRCPOLY : 0;
			phần dư = (phần dư >> 1) ^ bội số;
		}
	}

Nếu đầu vào là bội số của 32 bit, bạn thậm chí có thể XOR ở dạng 32 bit
từng từ một và tăng số vòng lặp bên trong lên 32.

Bạn cũng có thể trộn và kết hợp hai kiểu vòng lặp, ví dụ như thực hiện
phần lớn byte tin nhắn tại một thời điểm và thêm xử lý từng bit một
cho bất kỳ byte phân số nào ở cuối.

Để giảm số nhánh có điều kiện, phần mềm thường sử dụng
phương pháp bảng theo từng byte, được phổ biến bởi Dilip V. Sarwate,
"Tính toán kiểm tra dự phòng theo chu kỳ thông qua tra cứu bảng", Comm. ACM
v.31 số 8 (tháng 8 năm 1988) tr. 1008-1013.

Ở đây, thay vì chỉ dịch chuyển một phần còn lại để quyết định
theo đúng bội số cần trừ, chúng ta có thể dịch chuyển từng byte một.
Điều này tạo ra phần dư trung gian 40 bit (chứ không phải 33 bit),
và bội số chính xác của đa thức cần trừ được tìm thấy bằng cách sử dụng
một bảng tra cứu 256 mục được lập chỉ mục theo 8 bit cao.

(Các mục trong bảng chỉ đơn giản là CRC-32 của các tin nhắn một byte đã cho.)

Khi không gian hạn chế hơn, có thể sử dụng các bảng nhỏ hơn, ví dụ: hai
Các dịch chuyển 4 bit theo sau là tra cứu trong bảng 16 mục.

Sẽ không thực tế khi xử lý nhiều hơn 8 bit cùng một lúc bằng cách sử dụng tính năng này
kỹ thuật, vì các bảng lớn hơn 256 mục sử dụng quá nhiều bộ nhớ và,
quan trọng hơn là có quá nhiều bộ đệm L1.

Để có hiệu suất phần mềm cao hơn, có thể sử dụng kỹ thuật "cắt".
Xem "Thế hệ CRC có chỉ số octan cao với thuật toán Intel Slicing-by-8",
ftp://download.intel.com/technology/comms/perfnet/download/slicing-by-8.pdf

Điều này không làm thay đổi số lần tra cứu bảng nhưng lại tăng
sự song song.  Với thuật toán Sarwate cổ điển, mỗi lần tra cứu bảng
phải được hoàn thành trước khi tính chỉ số của phần tiếp theo.

Kỹ thuật "cắt 2" sẽ dịch chuyển 16 bit còn lại cùng một lúc,
tạo ra phần dư trung gian 48 bit.  Thay vì làm một việc duy nhất
tra cứu trong bảng mục nhập 65536, hai byte cao được tra cứu trong
hai bảng 256 mục khác nhau.  Mỗi cái chứa phần còn lại cần thiết
để hủy bỏ byte tương ứng.  Các bảng khác nhau vì
đa thức cần hủy là khác nhau.  Người ta có các hệ số khác 0 từ
x^32 đến x^39, trong khi cái còn lại đi từ x^40 đến x^47.

Vì các bộ xử lý hiện đại có thể xử lý nhiều hoạt động bộ nhớ song song, điều này
chỉ mất nhiều thời gian hơn một lần tra cứu một bảng và do đó thực hiện gần như
nhanh gấp đôi thuật toán Sarwate cơ bản.

Điều này có thể được mở rộng thành "cắt 4" bằng cách sử dụng 4 bảng 256 mục nhập.
Mỗi bước, 32 bit dữ liệu được tìm nạp, XOR với CRC và kết quả
chia thành từng byte và tra cứu trong bảng.  Vì sự dịch chuyển 32 bit
để lại các bit bậc thấp của phần dư trung gian bằng 0,
CRC cuối cùng chỉ đơn giản là XOR của 4 bảng tra cứu.

Nhưng điều này vẫn buộc phải thực hiện tuần tự: nhóm bảng thứ hai
việc tra cứu không thể bắt đầu cho đến khi việc tra cứu bảng 4 nhóm trước đó có tất cả
đã được hoàn thành.  Do đó, bộ phận tải/lưu trữ của bộ xử lý đôi khi không hoạt động.

Để tận dụng tối đa bộ xử lý, "cắt theo 8" thực hiện 8 lần tra cứu
song song.  Mỗi bước, CRC 32 bit được dịch chuyển 64 bit và XORed
với 64 bit dữ liệu đầu vào.  Điều quan trọng cần lưu ý là 4 trong số
8 byte đó chỉ đơn giản là bản sao của dữ liệu đầu vào; họ không phụ thuộc
trên CRC trước đó.  Do đó, việc tra cứu 4 bảng đó có thể bắt đầu
ngay lập tức mà không cần đợi đến lần lặp trước đó.

Bằng cách luôn có 4 tải trong chuyến bay, bộ xử lý siêu vô hướng hiện đại có thể
luôn bận rộn và tận dụng tối đa bộ đệm L1 của nó.

Hai chi tiết khác về việc triển khai CRC trong thế giới thực:

Thông thường, việc thêm các bit 0 vào một thông báo đã là bội số
của một đa thức sẽ tạo ra bội số lớn hơn của đa thức đó.  Như vậy,
CRC cơ bản sẽ không phát hiện các bit 0 (hoặc byte) được nối thêm.  Để kích hoạt
một CRC để phát hiện tình trạng này, thông thường phải đảo ngược CRC trước đó
nối thêm nó.  Điều này làm cho phần còn lại của tin nhắn+crc không xuất hiện
bằng 0, nhưng có một số giá trị cố định khác 0.  (CRC của phép đảo ngược
mẫu, 0xffffffff.)

Vấn đề tương tự cũng xảy ra với các bit 0 được thêm vào trước thông báo và
giải pháp tương tự được sử dụng.  Thay vì bắt đầu tính toán CRC với
số dư bằng 0, số dư ban đầu của tất cả số 1 được sử dụng.  Miễn là
bạn bắt đầu giải mã theo cách tương tự, nó không tạo ra sự khác biệt.
