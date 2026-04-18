.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/console.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Trình điều khiển bảng điều khiển
================================

Nhân Linux có 2 loại trình điều khiển bảng điều khiển chung.  Loại đầu tiên là
được kernel gán cho tất cả các bảng điều khiển ảo trong quá trình khởi động.
Loại này sẽ được gọi là 'trình điều khiển hệ thống' và chỉ cho phép một trình điều khiển hệ thống
tồn tại. Tuy nhiên, trình điều khiển hệ thống vẫn tồn tại dai dẳng và không bao giờ có thể tải xuống được
nó có thể trở nên không hoạt động.

Loại thứ hai phải được tải và dỡ tải một cách rõ ràng. Điều này sẽ được gọi
'trình điều khiển mô-đun' bằng tài liệu này. Nhiều trình điều khiển mô-đun có thể cùng tồn tại ở
bất kỳ lúc nào khi mỗi trình điều khiển chia sẻ bảng điều khiển với các trình điều khiển khác bao gồm
trình điều khiển hệ thống. Tuy nhiên, trình điều khiển mô-đun không thể chiếm quyền điều khiển bảng điều khiển
hiện đang bị chiếm giữ bởi một trình điều khiển mô-đun khác. (Ngoại lệ: Trình điều khiển
gọi do_take_over_console() sẽ thành công trong việc tiếp quản bất kể loại nào
của trình điều khiển đang chiếm giữ bảng điều khiển.) Họ chỉ có thể tiếp quản bảng điều khiển
bị chiếm bởi trình điều khiển hệ thống. Tương tự như vậy, nếu trình điều khiển mô-đun là
được phát hành bởi bảng điều khiển, trình điều khiển hệ thống sẽ đảm nhận.

Trình điều khiển mô-đun, theo quan điểm của người lập trình, phải gọi ::

do_take_over_console() - tải và liên kết trình điều khiển với lớp bảng điều khiển
	 Give_up_console() - dỡ bỏ trình điều khiển; nó sẽ chỉ hoạt động nếu trình điều khiển
			     hoàn toàn không bị ràng buộc

Trong các hạt nhân mới hơn, những thứ sau đây cũng có sẵn::

do_register_con_driver()
	 do_unregister_con_driver()

Nếu sysfs được bật, nội dung của /sys/class/vtconsole có thể
đã kiểm tra. Điều này hiển thị các chương trình phụ trợ của bảng điều khiển hiện được đăng ký bởi
hệ thống được đặt tên vtcon<n> trong đó <n> là số nguyên từ 0 đến 15.
Như vậy::

ls/sys/class/vtconsole
       .  ..vtcon0 vtcon1

Mỗi thư mục trong /sys/class/vtconsole có 3 file::

ls/sys/class/vtconsole/vtcon0
     .  .. sự kiện liên kết tên

Những tập tin này có ý nghĩa gì?

1. liên kết - đây là tệp đọc/ghi. Nó hiển thị trạng thái của trình điều khiển nếu
        đọc hoặc thực hiện liên kết hoặc hủy liên kết trình điều khiển với bảng điều khiển ảo
        khi được viết vào. Các giá trị có thể là:

0
	  - có nghĩa là trình điều khiển không bị ràng buộc và nếu bị lặp lại, hãy ra lệnh cho trình điều khiển
	    cởi trói

1
	  - có nghĩa là trình điều khiển bị ràng buộc và nếu bị dội lại, hãy ra lệnh cho trình điều khiển
	    ràng buộc

2. tên - tập tin chỉ đọc. Hiển thị tên của trình điều khiển ở định dạng này::

mèo /sys/class/vtconsole/vtcon0/name
	  (S) VGA+

'(S)' là viết tắt của trình điều khiển hệ thống (S), nghĩa là nó không thể trực tiếp
	      được lệnh ràng buộc hoặc hủy ràng buộc

'VGA+' là tên của trình điều khiển

mèo /sys/class/vtconsole/vtcon1/name
	  (M) thiết bị đệm khung

Trong trường hợp này, '(M)' là viết tắt của trình điều khiển hình mô-đun (M), trình điều khiển có thể được
	      được lệnh trực tiếp để ràng buộc hoặc hủy liên kết.

3. uevent - bỏ qua tập tin này

Khi hủy liên kết, trình điều khiển mô-đun sẽ được tách ra trước tiên, sau đó là hệ thống
người lái xe tiếp quản các bảng điều khiển mà người lái xe bỏ trống. Mặt khác, sự ràng buộc
tay, sẽ liên kết trình điều khiển với các bảng điều khiển hiện đang bị chiếm giữ bởi một
trình điều khiển hệ thống.

NOTE1:
  Liên kết và hủy liên kết phải được chọn trong Kconfig. Nó ở dưới::

Trình điều khiển thiết bị ->
	Thiết bị nhân vật ->
		Hỗ trợ liên kết và hủy liên kết trình điều khiển bảng điều khiển

NOTE2:
  Nếu bất kỳ bảng điều khiển ảo nào ở chế độ KD_GRAPHICS thì liên kết hoặc
  việc gỡ bỏ ràng buộc sẽ không thành công. Một ví dụ về ứng dụng thiết lập
  bảng điều khiển cho KD_GRAPHICS là X.

Tính năng này hữu ích như thế nào? Điều này rất hữu ích cho trình điều khiển console
nhà phát triển. Bằng cách hủy liên kết trình điều khiển khỏi lớp bảng điều khiển, người ta có thể dỡ bỏ
trình điều khiển, thực hiện thay đổi, biên dịch lại, tải lại và khởi động lại trình điều khiển mà không cần bất kỳ nhu cầu nào
để khởi động lại kernel. Đối với người dùng thông thường có thể muốn chuyển từ
bộ đệm khung sang bảng điều khiển VGA và ngược lại, tính năng này cũng làm cho
điều này có thể. (NOTE NOTE NOTE: Vui lòng đọc fbcon.txt trong Tài liệu/fb
để biết thêm chi tiết.)

Ghi chú dành cho nhà phát triển
===============================

do_take_over_console() hiện được chia thành::

do_register_con_driver()
     do_bind_con_driver() - chức năng riêng tư

Give_up_console() là trình bao bọc cho do_unregister_con_driver() và trình điều khiển phải
hoàn toàn không bị ràng buộc để cuộc gọi này thành công. con_is_bound() sẽ kiểm tra xem
trình điều khiển có bị ràng buộc hay không.

Hướng dẫn dành cho người viết trình điều khiển bảng điều khiển
==============================================================

Để liên kết và hủy liên kết khỏi bảng điều khiển hoạt động bình thường,
trình điều khiển bảng điều khiển phải tuân theo các nguyên tắc sau:

1. Tất cả các trình điều khiển, ngoại trừ trình điều khiển hệ thống, phải gọi do_register_con_driver()
   hoặc do_take_over_console(). do_register_con_driver() sẽ chỉ thêm trình điều khiển
   vào danh sách nội bộ của bảng điều khiển. Nó sẽ không chiếm lấy
   bảng điều khiển. do_take_over_console(), như tên gọi của nó, cũng sẽ tiếp quản (hoặc
   liên kết với) bảng điều khiển.

2. Tất cả tài nguyên được phân bổ trong con->con_init() phải được giải phóng trong
   con->con_deinit().

3. Tất cả tài nguyên được phân bổ trong con->con_startup() phải được giải phóng khi
   trình điều khiển đã bị ràng buộc trước đó sẽ trở nên không bị ràng buộc.  Lớp giao diện điều khiển
   không có lệnh gọi bổ sung tới con->con_startup() nên điều này tùy thuộc vào
   lái xe để kiểm tra xem khi nào việc phát hành các tài nguyên này là hợp pháp. Đang gọi
   con_is_bound() trong con->con_deinit() sẽ hữu ích.  Nếu cuộc gọi trở lại
   false() thì việc giải phóng tài nguyên là an toàn.  Sự cân bằng này phải được
   được đảm bảo vì con->con_startup() có thể được gọi lại khi có yêu cầu
   khởi động lại trình điều khiển vào bảng điều khiển sẽ đến.

4. Khi thoát khỏi trình điều khiển, hãy đảm bảo rằng trình điều khiển hoàn toàn không bị ràng buộc. Nếu
   điều kiện được thỏa mãn thì trình điều khiển phải gọi do_unregister_con_driver()
   hoặc Give_up_console().

5. do_unregister_con_driver() cũng có thể được gọi với các điều kiện khiến nó
   trình điều khiển không thể đáp ứng các yêu cầu của bảng điều khiển.  Điều này có thể xảy ra
   với bảng điều khiển bộ đệm khung đột nhiên mất tất cả trình điều khiển.

Loại trình điều khiển bảng điều khiển hiện tại vẫn hoạt động chính xác nhưng bị ràng buộc
và việc bỏ ràng buộc chúng có thể gây ra vấn đề. Với các bản sửa lỗi tối thiểu, các trình điều khiển này có thể
được thực hiện để hoạt động chính xác.

Antonino Daplas <adaplas@pol.net>