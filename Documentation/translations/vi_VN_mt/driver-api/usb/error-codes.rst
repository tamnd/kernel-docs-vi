.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/usb/error-codes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _usb-error-codes:

Mã lỗi USB
~~~~~~~~~~~~~~~

:Sửa đổi: 2004-Tháng 10-21

Đây là tài liệu (hy vọng) tất cả các mã lỗi có thể xảy ra (và
cách giải thích của họ) có thể được trả về từ usbcore.

Một số trong số chúng được trả về bởi Trình điều khiển Bộ điều khiển Máy chủ (HCD),
trình điều khiển thiết bị chỉ nhìn thấy qua usbcore.  Theo quy định, tất cả các HCD phải
hoạt động giống nhau ngoại trừ các hành vi phụ thuộc vào tốc độ truyền tải và
cách một số lỗi nhất định được báo cáo.


Mã lỗi được trả về bởi ZZ0000ZZ
================================================

Không dành riêng cho USB:


===================================================================
0 Việc gửi URB đã diễn ra tốt đẹp

ZZ0000ZZ không có bộ nhớ để phân bổ cấu trúc bên trong
===================================================================

USB dành riêng cho:

====================================================================================
ZZ0000ZZ URB đã hoạt động.

ZZ0000ZZ-thiết bị hoặc bus USB được chỉ định không tồn tại

Giao diện hoặc điểm cuối được chỉ định ZZ0000ZZ không tồn tại hoặc
			không được kích hoạt

Trình điều khiển bộ điều khiển máy chủ ZZ0000ZZ không hỗ trợ xếp hàng
			loại đô thị này.  (coi như lỗi của bộ điều khiển máy chủ.)

ZZ0000ZZ a) Loại truyền không hợp lệ được chỉ định (hoặc không được hỗ trợ)
			b) Khoảng thời gian chuyển định kỳ không hợp lệ hoặc không được hỗ trợ
			c) ISO: đã cố gắng thay đổi khoảng thời gian truyền
			d) ISO: ZZ0001ZZ là < 0
			e) các trường hợp khác

ZZ0000ZZ ISO: ZZ0001ZZ chưa được chỉ định và tất cả
			các khung mà URB đã được lên lịch sẵn rồi
			đã hết hạn.

ZZ0000ZZ Trình điều khiển bộ điều khiển máy chủ không thể lập lịch cho nhiều ISO như vậy
			khung.

ZZ0000ZZ Loại ống được chỉ định trong URB không khớp với
			loại thực tế của điểm cuối.

ZZ0000ZZ (a) kích thước gói tối đa của điểm cuối bằng 0; nó không thể sử dụng được
			    trong cài đặt thay thế giao diện hiện tại.
			(b) Gói ISO lớn hơn gói tối đa điểm cuối.
			(c) độ dài truyền dữ liệu được yêu cầu không hợp lệ: âm
			    hoặc quá lớn đối với bộ điều khiển máy chủ.

ZZ0000ZZ Giá trị wLength trong gói thiết lập của URB điều khiển có
			không khớp với transfer_buffer_length của URB.

ZZ0000ZZ Yêu cầu này sẽ vượt quá băng thông USB dành riêng
			để chuyển định kỳ (ngắt, đẳng thời).

ZZ0000ZZ Bộ điều khiển thiết bị hoặc máy chủ đã bị tắt do
			một số vấn đề không thể giải quyết được.

Việc gửi ZZ0000ZZ không thành công vì ZZ0001ZZ đã được đặt.

ZZ0000ZZ URB đã bị từ chối vì thiết bị bị treo.

ZZ0000ZZ Điều khiển URB không chứa gói Thiết lập.
====================================================================================

Mã lỗi được trả về bởi ZZ0000ZZ hoặc trong ZZ0001ZZ (đối với ISO)
=======================================================================================

Trình điều khiển thiết bị USB chỉ có thể kiểm tra các giá trị trạng thái đô thị trong trình xử lý hoàn thành.
Điều này là do nếu không sẽ có một cuộc chạy đua giữa việc cập nhật HCD
các giá trị này trên một CPU và trình điều khiển thiết bị sẽ kiểm tra chúng trên một CPU khác.

Fact_length của một lần chuyển có thể dương ngay cả khi xảy ra lỗi
báo cáo.  Đó là vì việc truyền tải thường liên quan đến nhiều gói tin, do đó
một hoặc nhiều gói có thể kết thúc trước khi một lỗi dừng I/O điểm cuối tiếp theo.

Đối với các URB đẳng thời, giá trị trạng thái urb khác 0 chỉ khi URB là
bị hủy liên kết, thiết bị bị xóa, bộ điều khiển máy chủ bị tắt hoặc toàn bộ
độ dài được truyền nhỏ hơn độ dài được yêu cầu và
Cờ ZZ0000ZZ được đặt.  Trình xử lý hoàn thành cho URB đẳng thời
chỉ nên thấy ZZ0001ZZ được đặt thành 0, ZZ0002ZZ, ZZ0003ZZ,
ZZ0004ZZ, hoặc ZZ0005ZZ. Các trường trạng thái mô tả khung riêng lẻ
có thể báo cáo nhiều mã trạng thái hơn.


====================================================================================
0 Quá trình chuyển hoàn tất thành công

ZZ0001ZZ URB đã được hủy liên kết đồng bộ bởi
				ZZ0000ZZ

ZZ0000ZZ URB vẫn đang chờ xử lý, chưa có kết quả
				(Nghĩa là, nếu trình điều khiển thấy điều này thì đó là lỗi.)

ZZ0000ZZ [#f1]_, [#f2]_ a) lỗi bit
				b) không nhận được gói phản hồi nào trong vòng
				   quy định thời gian quay xe buýt
				c) lỗi USB không xác định

ZZ0000ZZ [#f1]_, [#f2]_ a) CRC không khớp
				b) không nhận được gói phản hồi nào trong vòng
				   quy định thời gian quay xe buýt
				c) lỗi USB không xác định

Lưu ý rằng phần cứng bộ điều khiển thường làm
				không phân biệt trường hợp a), b), c) nên
				người lái xe không thể biết liệu có
				lỗi giao thức, không phản hồi (thường
				do ngắt kết nối thiết bị) hoặc một số nguyên nhân khác
				lỗi.

ZZ0000ZZ [#f2]_ Không nhận được gói phản hồi nào trong
				thời gian quay đầu xe buýt theo quy định.  Lỗi này
				thay vào đó có thể được báo cáo là
				ZZ0001ZZ hoặc ZZ0002ZZ.

ZZ0000ZZ Chức năng tin nhắn USB đồng bộ sử dụng mã này
				để cho biết thời gian chờ đã hết trước khi chuyển
				đã hoàn thành và không có lỗi nào khác được báo cáo
				bởi HC.

ZZ0001ZZ [#f2]_ Điểm cuối bị đình trệ.  Đối với các điểm cuối không kiểm soát,
				đặt lại trạng thái này với
				ZZ0000ZZ.

ZZ0000ZZ Trong quá trình truyền IN, bộ điều khiển máy chủ
				đã nhận được dữ liệu từ điểm cuối nhanh hơn nó
				có thể được ghi vào bộ nhớ hệ thống

ZZ0000ZZ Trong quá trình truyền OUT, bộ điều khiển máy chủ
				không thể truy xuất dữ liệu từ bộ nhớ hệ thống nhanh
				đủ để theo kịp tốc độ dữ liệu USB

ZZ0000ZZ [#f1]_ Lượng dữ liệu được điểm cuối trả về là
				lớn hơn kích thước gói tối đa của
				điểm cuối hoặc kích thước bộ đệm còn lại.
				"Lảm nhảm".

ZZ0000ZZ Dữ liệu đọc từ điểm cuối không được điền
				bộ đệm được chỉ định và ZZ0001ZZ
				được đặt trong ZZ0002ZZ.

Thiết bị ZZ0000ZZ đã bị xóa.  Thường xảy ra trước một vụ nổ
				về các lỗi khác, vì trình điều khiển trung tâm không
				phát hiện các sự kiện loại bỏ thiết bị ngay lập tức.

Chuyển ZZ0000ZZ ISO chỉ hoàn thành một phần
				(chỉ được đặt trong ZZ0001ZZ,
				không phải ZZ0002ZZ)

ZZ0000ZZ ISO thật điên rồ, nếu điều này xảy ra: Đăng xuất và
				về nhà

ZZ0001ZZ URB đã bị hủy liên kết không đồng bộ bởi
				ZZ0000ZZ

ZZ0000ZZ Bộ điều khiển thiết bị hoặc máy chủ đã được
				bị vô hiệu hóa do một số vấn đề không thể
				được giải quyết xung quanh, chẳng hạn như vật lý
				ngắt kết nối.
====================================================================================


.. [#f1]

   Error codes like ``-EPROTO``, ``-EILSEQ`` and ``-EOVERFLOW`` normally
   indicate hardware problems such as bad devices (including firmware)
   or cables.

.. [#f2]

   This is also one of several codes that different kinds of host
   controller use to indicate a transfer has failed because of device
   disconnect.  In the interval before the hub driver starts disconnect
   processing, devices may receive such fault reports for every request.



Mã lỗi được trả về bởi hàm usbcore
=========================================

.. note:: expect also other submit and transfer status codes

ZZ0000ZZ:

==============================================================
Lỗi ZZ0000ZZ khi đăng ký driver mới
==============================================================

ZZ0002ZZ,
ZZ0000ZZ,
ZZ0001ZZ:

==========================================================================
ZZ0000ZZ Hết thời gian chờ trước khi quá trình chuyển hoàn tất.
==========================================================================
