.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/usb/persist.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _usb-persist:

Sự tồn tại của thiết bị USB trong quá trình tạm dừng hệ thống
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

:Tác giả: Alan Stern <stern@rowland.harvard.edu>
:Ngày: 2 tháng 9 năm 2006 (Cập nhật 25 tháng 2 năm 2008)


Vấn đề là gì?
====================

Theo thông số kỹ thuật của USB, khi xe buýt USB bị treo,
xe buýt phải tiếp tục cung cấp dòng điện treo (khoảng 1-5 mA).  Cái này
là để các thiết bị có thể duy trì trạng thái bên trong của chúng và các trung tâm có thể
phát hiện các sự kiện thay đổi kết nối (thiết bị đang được cắm hoặc rút phích cắm).
Thuật ngữ kỹ thuật là "phiên quyền lực".

Nếu phiên cấp nguồn của thiết bị USB bị gián đoạn thì hệ thống sẽ
được yêu cầu hoạt động như thể thiết bị đã được rút phích cắm.  Đó là một
cách tiếp cận bảo thủ; trong trường hợp máy tính không bị treo
không có cách nào để biết điều gì đã thực sự xảy ra.  Có lẽ giống nhau
thiết bị vẫn được gắn vào hoặc có thể nó đã bị xóa và một thiết bị khác
thiết bị cắm vào cổng.  Hệ thống phải giả định điều tồi tệ nhất.

Theo mặc định, Linux hoạt động theo thông số kỹ thuật.  Nếu máy chủ USB
bộ điều khiển mất nguồn khi hệ thống tạm dừng, sau đó khi hệ thống
đánh thức tất cả các thiết bị được gắn vào bộ điều khiển đó được coi là
mặc dù họ đã ngắt kết nối.  Điều này luôn luôn an toàn và nó là
việc "chính xác" cần làm.

Đối với nhiều loại thiết bị, hành vi này ít nhất không quan trọng.
Nếu kernel muốn tin rằng bàn phím USB của bạn đã bị rút phích cắm
trong khi hệ thống ở chế độ ngủ và bàn phím mới được cắm vào khi
hệ thống đã thức dậy, ai quan tâm?  Nó vẫn hoạt động như cũ khi bạn gõ vào
nó.

Thật không may, các vấn đề _có thể_ phát sinh, đặc biệt là với bộ lưu trữ lớn
thiết bị.  Hiệu ứng hoàn toàn giống như khi thiết bị thực sự có
đã được rút phích cắm trong khi hệ thống bị treo.  Nếu bạn đã có một gắn kết
hệ thống tập tin trên thiết bị, bạn sẽ không gặp may -- mọi thứ trong đó
hệ thống tập tin hiện không thể truy cập được.  Điều này đặc biệt khó chịu nếu bạn
hệ thống tập tin gốc được đặt trên thiết bị, vì hệ thống của bạn sẽ
ngay lập tức sụp đổ.

Mất điện không phải là cơ chế duy nhất đáng lo ngại.  Bất cứ điều gì
làm gián đoạn phiên cấp nguồn sẽ có tác dụng tương tự.  Ví dụ,
mặc dù dòng điện treo có thể vẫn được duy trì trong khi hệ thống
đang ngủ, trên nhiều hệ thống trong giai đoạn đầu đánh thức
chương trình cơ sở (tức là BIOS) đặt lại máy chủ USB của bo mạch chủ
bộ điều khiển.  Kết quả: tất cả các phiên cấp nguồn bị phá hủy và lặp lại
cứ như thể bạn đã rút phích cắm tất cả các thiết bị USB.  Vâng, đó là
hoàn toàn là lỗi của BIOS, nhưng điều đó chẳng có ích gì cho _bạn_ trừ khi
bạn có thể thuyết phục nhà cung cấp BIOS khắc phục sự cố (rất may mắn!).

Trên nhiều hệ thống, bộ điều khiển máy chủ USB sẽ được đặt lại sau một
đình chỉ-RAM.  Trên hầu hết tất cả các hệ thống, không có dòng điện treo
khả dụng trong thời gian ngủ đông (còn được gọi là swsusp hoặc tạm dừng vào đĩa).
Bạn có thể kiểm tra nhật ký kernel sau khi tiếp tục lại để xem liệu một trong hai thứ này có
đã xảy ra; hãy tìm dòng có nội dung "root hub bị mất nguồn hoặc đã được đặt lại".

Trong thực tế, mọi người buộc phải ngắt kết nối bất kỳ hệ thống tệp nào trên USB
thiết bị trước khi tạm dừng.  Nếu hệ thống tập tin gốc nằm trên thiết bị USB,
hệ thống không thể bị đình chỉ chút nào.  (Được rồi, nó _có thể_
bị đình chỉ -- nhưng nó sẽ gặp sự cố ngay khi thức dậy, điều này không phải
tốt hơn nhiều.)


Giải pháp là gì?
=====================

Hạt nhân bao gồm một tính năng gọi là USB-persist.  Nó cố gắng làm việc
xung quanh những vấn đề này bằng cách cho phép cấu trúc dữ liệu cốt lõi của thiết bị USB
vẫn tồn tại trong thời gian phiên điện bị gián đoạn.

Nó hoạt động như thế này.  Nếu kernel thấy rằng bộ điều khiển máy chủ USB đang
không ở trạng thái mong đợi trong quá trình tiếp tục (tức là nếu bộ điều khiển được
đặt lại hoặc bị mất điện) thì nó sẽ áp dụng kiểm tra tính bền vững
tới từng thiết bị USB bên dưới bộ điều khiển đó
thuộc tính "kiên trì" được đặt.  Nó không cố gắng khởi động lại thiết bị; đó
không thể làm việc một khi hết phiên cấp nguồn.  Thay vào đó nó phát ra USB
thiết lập lại cổng và sau đó liệt kê lại thiết bị.  (Đây chính xác là
điều tương tự cũng xảy ra bất cứ khi nào thiết bị USB được đặt lại.) Nếu
việc liệt kê lại cho thấy rằng thiết bị hiện được gắn vào cổng đó có
các mô tả tương tự như trước đây, bao gồm ID nhà cung cấp và ID sản phẩm, sau đó
kernel tiếp tục sử dụng cấu trúc thiết bị tương tự.  Trên thực tế,
kernel xử lý thiết bị như thể nó chỉ được đặt lại thay vì
đã rút phích cắm.

Điều tương tự cũng xảy ra nếu bộ điều khiển máy chủ ở trạng thái mong đợi
nhưng thiết bị USB đã được rút phích cắm rồi cắm lại hoặc nếu thiết bị USB
không thực hiện được một sơ yếu lý lịch bình thường.

Nếu hiện tại không có thiết bị nào được gắn vào cổng hoặc nếu bộ mô tả
khác với những gì kernel ghi nhớ thì cách xử lý là những gì
bạn mong đợi.  Hạt nhân phá hủy cấu trúc thiết bị cũ và
hoạt động như thể thiết bị cũ đã được rút phích cắm và thiết bị mới
cắm vào.

Kết quả cuối cùng là thiết bị USB vẫn có sẵn và sử dụng được.
Việc gắn kết hệ thống tập tin và ánh xạ bộ nhớ không bị ảnh hưởng và thế giới
bây giờ là một nơi tốt đẹp và hạnh phúc.

Lưu ý rằng tính năng "USB-persist" sẽ chỉ được áp dụng cho những
các thiết bị mà nó được kích hoạt.  Bạn có thể kích hoạt tính năng này bằng cách thực hiện
(với quyền root)::

echo 1 >/sys/bus/usb/devices/.../power/persist

trong đó "..." phải được điền bằng ID của thiết bị.  Vô hiệu hóa
tính năng này bằng cách viết 0 thay vì 1. Đối với hub, tính năng này là
được kích hoạt tự động và vĩnh viễn và tệp nguồn/kiên trì
thậm chí không tồn tại, vì vậy bạn chỉ phải lo lắng về việc thiết lập nó cho
những thiết bị thực sự quan trọng.


Đây có phải là giải pháp tốt nhất?
==========================

Có lẽ là không.  Có thể cho rằng, việc theo dõi các hệ thống tập tin được gắn kết và
ánh xạ bộ nhớ qua các lần ngắt kết nối thiết bị phải được xử lý bởi một
Trình quản lý khối logic tập trung.  Giải pháp như vậy sẽ cho phép bạn
để cắm thiết bị flash USB, tạo một ổ đĩa liên tục được liên kết
với nó, hãy rút phích cắm thiết bị flash, cắm lại sau và vẫn
có cùng một khối lượng liên tục được liên kết với thiết bị.  Như vậy
nó sẽ có tầm ảnh hưởng sâu rộng hơn USB-kiên trì.

Mặt khác, việc viết một trình quản lý khối lượng liên tục sẽ là một vấn đề lớn.
công việc và việc sử dụng nó sẽ yêu cầu đầu vào đáng kể từ người dùng.  Cái này
giải pháp nhanh hơn và dễ dàng hơn nhiều -- và nó hiện tồn tại, một gã khổng lồ
điểm có lợi cho nó!

Hơn nữa, tính năng USB-persist áp dụng cho _all_ thiết bị USB, không phải
chỉ là các thiết bị lưu trữ dung lượng lớn.  Nó có thể trở nên hữu ích như nhau đối với
các loại thiết bị khác, chẳng hạn như giao diện mạng.


WARNING: USB-kiên trì có thể nguy hiểm!!
=======================================

Khi khôi phục phiên cấp nguồn bị gián đoạn, kernel sẽ hoạt động tốt nhất
để đảm bảo thiết bị USB không bị thay đổi; tức là giống nhau
máy vẫn cắm vào cổng như trước.  Nhưng séc
không đảm bảo chính xác 100%.

Nếu bạn thay thế một thiết bị USB bằng một thiết bị khác cùng loại (cùng loại
nhà sản xuất, cùng ID, v.v.) rất có thể
kernel sẽ không phát hiện ra sự thay đổi.  Chuỗi số sê-ri và các chuỗi khác
các bộ mô tả được so sánh với các giá trị được lưu trữ của kernel, nhưng điều này
có thể không giúp ích gì vì nhà sản xuất thường xuyên bỏ qua số sê-ri
hoàn toàn trong thiết bị của họ.

Hơn nữa, hoàn toàn có thể để thiết bị USB giống hệt nhau
trong khi thay đổi phương tiện truyền thông của nó.  Nếu bạn thay thẻ nhớ flash trong một
Đầu đọc thẻ USB trong khi hệ thống ở chế độ ngủ, kernel sẽ không có
cách để biết bạn đã làm điều đó.  Hạt nhân sẽ cho rằng không có gì có
đã xảy ra và sẽ tiếp tục sử dụng các bảng phân vùng, các nút và
ánh xạ bộ nhớ cho thẻ cũ.

Nếu kernel bị lừa theo cách này, gần như chắc chắn sẽ gây ra
hỏng dữ liệu và làm hỏng hệ thống của bạn.  Bạn sẽ không có ai để đổ lỗi
nhưng chính bạn.

Đối với những thiết bị có thuộc tính tránh_reset_quirk được đặt, hãy tiếp tục
có thể thất bại vì chúng có thể biến hình sau khi thiết lập lại.

YOU HAVE BEEN WARNED!  USE TẠI YOUR OWN RISK!

Điều đó đã được nói, hầu hết thời gian sẽ không có bất kỳ rắc rối nào
không hề.  Tính năng kiên trì USB có thể cực kỳ hữu ích.  làm cho
hầu hết nó.
