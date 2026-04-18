.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/i2c/fault-codes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Mã lỗi I2C/SMBUS
=====================

Đây là bản tóm tắt các quy ước quan trọng nhất khi sử dụng lỗi.
mã trong ngăn xếp I2C/SMBus.


“Lỗi” không phải lúc nào cũng là “Lỗi”
----------------------------------
Không phải tất cả các báo cáo lỗi đều ám chỉ lỗi; “lỗi trang” hẳn là một điều quen thuộc
ví dụ.  Phần mềm thường thử lại các hoạt động bình thường sau khi tạm thời
lỗi.  Có thể có những kế hoạch phục hồi phức tạp hơn phù hợp trong
một số trường hợp, chẳng hạn như khởi tạo lại (và có thể đặt lại).  Sau đó như vậy
recovery, được kích hoạt bởi một báo cáo lỗi, không có lỗi.

Theo cách tương tự, đôi khi mã "lỗi" chỉ báo cáo một mã được xác định
kết quả cho một hoạt động ... nó không chỉ ra rằng có gì đó không ổn
chẳng qua là kết quả không nằm trên “con đường vàng” mà thôi.

Tóm lại, mã trình điều khiển I2C của bạn có thể cần biết các mã này để
để trả lời chính xác.  Mã khác có thể cần phải dựa vào báo cáo mã YOUR
mã lỗi phù hợp để nó có thể (lần lượt) hoạt động chính xác.


Mã lỗi I2C và SMBus
-------------------------
Chúng được trả về dưới dạng số âm từ hầu hết các cuộc gọi, bằng 0 hoặc
một số số dương cho thấy sự trở lại không có lỗi.  cụ thể
số liên kết với các ký hiệu này khác nhau giữa các kiến trúc,
mặc dù hầu hết các hệ thống Linux đều sử dụng cách đánh số <asm-generic/errno*.h>.

Lưu ý rằng các mô tả ở đây không đầy đủ.  Có những thứ khác
các mã có thể được trả lại và các trường hợp khác mà các mã này sẽ
được trả lại.  Tuy nhiên, người lái xe không nên trả lại các mã khác cho những mã này.
trường hợp (trừ khi phần cứng không cung cấp báo cáo lỗi duy nhất).

Ngoài ra, các mã được trả về bằng phương pháp thăm dò bộ điều hợp tuân theo các quy tắc được
cụ thể cho bus chủ của chúng (chẳng hạn như PCI hoặc bus nền tảng).


EAFNOSUPPORT
	Được trả về bởi bộ điều hợp I2C không hỗ trợ địa chỉ 10 bit khi
	họ được yêu cầu sử dụng một địa chỉ như vậy.

EAGAIN
	Được bộ điều hợp I2C trả về khi chúng mất trọng tài trong bản gốc
	chế độ truyền: một số chủ khác đang truyền khác
	dữ liệu cùng một lúc.

Cũng được trả về khi cố gắng gọi một thao tác I2C trong một
	bối cảnh nguyên tử, khi một số tác vụ đã sử dụng bus I2C đó
	để thực hiện một số thao tác khác.

EBADMSG
	Được trả về bởi logic SMBus khi byte Mã lỗi gói không hợp lệ
	được nhận.  Mã này là CRC bao gồm tất cả các byte trong
	giao dịch và được gửi trước khi STOP kết thúc.  Cái này
	lỗi chỉ được báo cáo trên các giao dịch đã đọc; nô lệ SMBus
	có thể có cách để báo cáo sự không khớp của PEC khi ghi từ
	chủ nhà.  Lưu ý rằng ngay cả khi PEC đang được sử dụng, bạn cũng không nên dựa vào
	trên đây là cách duy nhất để phát hiện việc truyền dữ liệu không chính xác.

EBUSY
	Được bộ điều hợp SMBus trả về khi xe buýt bận lâu hơn
	hơn mức cho phép.  Điều này thường chỉ ra một số thiết bị (có thể
	Bộ điều hợp SMBus) cần khôi phục một số lỗi (chẳng hạn như đặt lại),
	hoặc đã thử thiết lập lại nhưng không thành công.

EINVAL
	Lỗi khá mơ hồ này có nghĩa là một tham số không hợp lệ đã được
	được phát hiện trước khi bất kỳ thao tác I/O nào được bắt đầu.  Sử dụng nhiều hơn
	mã lỗi cụ thể khi bạn có thể.

EIO
	Lỗi khá mơ hồ này có nghĩa là đã xảy ra lỗi khi
	thực hiện một thao tác I/O.  Sử dụng một lỗi cụ thể hơn
	mã khi bạn có thể.

ENODEV
	Được trả về bằng phương thức thăm dò trình điều khiển().  Cái này nhiều hơn một chút
	cụ thể hơn ENXIO, ngụ ý rằng vấn đề không nằm ở
	địa chỉ, nhưng với thiết bị được tìm thấy ở đó.  Đầu dò trình điều khiển
	có thể xác minh thiết bị trả về phản hồi ZZ0000ZZ và
	trả lại cái này khi thích hợp.  (Lõi driver sẽ cảnh báo
	về các lỗi đầu dò ngoài ENXIO và ENODEV.)

ENOMEM
	Được trả về bởi bất kỳ thành phần nào không thể phân bổ bộ nhớ khi
	nó cần phải làm như vậy.

ENXIO
	Được bộ điều hợp I2C trả về để chỉ ra rằng pha địa chỉ
	chuyển khoản không nhận được ACK.  Mặc dù nó có thể chỉ có nghĩa là
	một thiết bị I2C tạm thời không phản hồi, thường thì nó
	có nghĩa là không có gì nghe ở địa chỉ đó.

Được trả về bởi các phương thức driver thăm dò() để chỉ ra rằng chúng
	không tìm thấy thiết bị nào để liên kết.  (ENODEV cũng có thể được sử dụng.)

EOPNOTSUPP
	Được bộ chuyển đổi trả về khi được yêu cầu thực hiện một thao tác
	rằng nó không hoặc không thể hỗ trợ.

Ví dụ: điều này sẽ được trả về khi một bộ chuyển đổi
	không hỗ trợ chuyển khối SMBus được yêu cầu thực thi
	một.  Trong trường hợp đó, người lái xe đưa ra yêu cầu đó phải
	đã xác minh rằng chức năng đã được hỗ trợ trước đó
	đã thực hiện yêu cầu chuyển khối đó.

Tương tự, nếu bộ điều hợp I2C không thể thực thi tất cả I2C hợp pháp
	tin nhắn, nó sẽ trả về thông tin này khi được yêu cầu thực hiện một
	giao dịch thì không thể.  (Những hạn chế này không thể được nhìn thấy trong
	mặt nạ chức năng của bộ điều hợp, vì giả định là
	rằng nếu bộ chuyển đổi hỗ trợ I2C thì nó hỗ trợ tất cả I2C.)

EPROTO
	Được trả về khi nô lệ không tuân theo I2C có liên quan
	hoặc thông số kỹ thuật giao thức SMBus (hoặc dành riêng cho chip).  một
	trường hợp này là khi độ dài của phản hồi dữ liệu khối SMBus
	(từ nô lệ SMBus) nằm ngoài phạm vi 1-32 byte.

ESHUTDOWN
	Được trả về khi yêu cầu chuyển bằng bộ chuyển đổi
	đã bị đình chỉ.

ETIMEDOUT
	Điều này được trình điều khiển trả về khi một thao tác mất quá nhiều thời gian
	thời gian và đã bị hủy bỏ trước khi nó hoàn thành.

Bộ điều hợp SMBus có thể trả lại nó khi một thao tác mất nhiều thời gian hơn
	thời gian hơn mức cho phép của đặc tả SMBus; ví dụ,
	khi một nô lệ kéo dài đồng hồ quá xa.  I2C không có cái đó
	hết thời gian chờ, nhưng việc bộ điều hợp I2C áp đặt một số
	giới hạn tùy ý (dài hơn nhiều so với SMBus!).
