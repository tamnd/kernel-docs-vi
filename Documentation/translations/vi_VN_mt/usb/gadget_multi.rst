.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/usb/gadget_multi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================
Tiện ích tổng hợp đa chức năng
=================================

Tổng quan
========

Tiện ích tổng hợp đa chức năng (hoặc g_multi) là một tiện ích tổng hợp
sử dụng rộng rãi khung tổng hợp để cung cấp
một... tiện ích đa chức năng.

Trong cấu hình tiêu chuẩn, nó cung cấp một cấu hình USB duy nhất
với RNDIS[1] (đó là Ethernet), USB CDC[2] ACM (đó là nối tiếp) và
USB Chức năng lưu trữ lớn.

Chức năng CDC ECM (Ethernet) có thể được bật thông qua tùy chọn Kconfig
và RNDIS có thể được tắt.  Nếu cả hai đều được bật, tiện ích sẽ
có hai cấu hình -- một với RNDIS và một với CDC ECM[3].

Xin lưu ý rằng nếu bạn sử dụng cấu hình không chuẩn (tức là kích hoạt
CDC ECM), bạn có thể cần thay đổi ID nhà cung cấp và/hoặc ID sản phẩm.

Trình điều khiển máy chủ
============

Để sử dụng tiện ích này, người ta cần làm cho nó hoạt động ở phía máy chủ --
không có điều đó thì không có hy vọng đạt được bất cứ điều gì với tiện ích này.
Như người ta có thể mong đợi, những việc người ta cần làm rất nhiều từ hệ thống này sang hệ thống khác.

Trình điều khiển máy chủ Linux
------------------

Vì tiện ích sử dụng khung tổng hợp tiêu chuẩn và xuất hiện như vậy
đối với máy chủ Linux, nó không cần bất kỳ trình điều khiển bổ sung nào trên máy chủ Linux
bên.  Tất cả các chức năng được xử lý bởi các trình điều khiển tương ứng được phát triển
cho họ.

Điều này cũng đúng với hai thiết lập cấu hình với RNDIS
cấu hình là cái đầu tiên.  Máy chủ Linux sẽ sử dụng cái thứ hai
cấu hình với CDC ECM sẽ hoạt động tốt hơn trong Linux.

Trình điều khiển máy chủ Windows
--------------------

Để tiện ích hoạt động trong Windows, phải đáp ứng hai điều kiện:

Đang phát hiện dưới dạng tiện ích tổng hợp
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Trước hết, Windows cần phát hiện tiện ích dưới dạng hỗn hợp USB
tiện ích mà bản thân nó có một số điều kiện [4].  Nếu họ gặp nhau,
Windows cho phép USB Generic Parent Driver[5] xử lý thiết bị, sau đó
cố gắng khớp các trình điều khiển cho từng giao diện riêng lẻ (đại loại là không
đi vào quá nhiều chi tiết).

Tin tốt là: bạn không phải lo lắng về hầu hết các vấn đề
điều kiện!

Điều duy nhất cần lo lắng là thiết bị này phải có một
cấu hình sao cho tiện ích kép RNDIS và CDC ECM sẽ không hoạt động trừ khi bạn
tạo một INF thích hợp -- và tất nhiên, nếu bạn gửi nó!

Cài đặt driver cho từng chức năng
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Một điều phức tạp hơn là tạo trình điều khiển cài đặt Windows cho mỗi
chức năng cá nhân.

Đối với bộ lưu trữ dung lượng lớn, điều đó không quan trọng vì Windows phát hiện ra đó là một giao diện
triển khai lớp Lưu trữ lớn USB và chọn trình điều khiển thích hợp.

Mọi thứ khó khăn hơn với RDNIS và CDC ACM.

RNDIS
.....

Để làm cho Windows chọn trình điều khiển RNDIS cho chức năng đầu tiên trong
tiện ích này, người ta cần sử dụng tệp [[file:linux.inf]] được cung cấp cùng với tiện ích này
tài liệu.  Nó "gắn" driver RNDIS của Window vào giao diện đầu tiên
của tiện ích.

Xin lưu ý rằng trong khi thử nghiệm, chúng tôi đã gặp phải một số vấn đề[6] khi
RNDIS không phải là giao diện đầu tiên.  Bạn không cần phải lo lắng về điều đó
trừ khi bạn đang cố gắng phát triển tiện ích của riêng mình, trong trường hợp đó hãy xem
ra khỏi lỗi này.

CDC ACM
.......

Tương tự, [[file:linux-cdc-acm.inf]] được cung cấp cho CDC ACM.

Tùy chỉnh tiện ích
......................

Nếu bạn có ý định hack tiện ích g_multi, hãy lưu ý rằng hãy sắp xếp lại
các chức năng rõ ràng sẽ thay đổi số giao diện cho mỗi
chức năng.  Kết quả là INF sẽ không hoạt động vì chúng có
số giao diện được mã hóa cứng trong đó (không khó để thay đổi những số đó
mặc dù [7]).

Điều này cũng có nghĩa là sau khi thử nghiệm với g_multi và thay đổi
các chức năng được cung cấp nên thay đổi nhà cung cấp và/hoặc ID sản phẩm của tiện ích
vì vậy sẽ không có xung đột với các tiện ích tùy chỉnh khác hoặc
tiện ích ban đầu.

Không tuân thủ có thể gây tổn thương não sau nhiều giờ thắc mắc tại sao
mọi thứ không hoạt động như dự định trước khi nhận ra Windows đã lưu vào bộ nhớ đệm
một số thông tin về trình điều khiển (việc thay đổi cổng USB đôi khi có thể giúp ích thêm
bạn có thể thử sử dụng USBDeview[8] để xóa thiết bị ảo).

Thử nghiệm INF
...........

Các file INF được cung cấp đã được thử nghiệm trên Windows XP SP3, Windows Vista
và Windows 7, tất cả các phiên bản 32-bit.  Nó sẽ hoạt động trên các phiên bản 64-bit
cũng vậy.  Rất có thể nó sẽ không hoạt động trên Windows trước Windows XP
SP2.

Các hệ thống khác
-------------

Tại thời điểm này, trình điều khiển cho bất kỳ hệ thống nào khác vẫn chưa được thử nghiệm.
Biết cách MacOS dựa trên BSD và BSD là Mã nguồn mở
tin rằng nó sẽ (đọc: "Tôi không biết liệu nó có hoạt động không")
ngoài hộp.

Đối với những hệ thống kỳ lạ hơn, tôi thậm chí còn ít điều để nói hơn...

Mọi thử nghiệm và trình điều khiển ZZ0000ZZ ZZ0001ZZ!

tác giả
=======

Tài liệu này được viết bởi Michal Nazarewicz
([[mailto:mina86@mina86.com]]).  Các tập tin INF đã bị hack bằng
sự hỗ trợ của Marek Szyprowski ([[mailto:m.szyprowski@samsung.com]]) và
Xiaofan Chen ([[mailto:xiaofanc@gmail.com]]) dựa trên MS RNDIS
template[9], tệp CDC ACM INF của Microchip và của David Brownell
([[mailto:dbronell@users.sourceforge.net]]) các tệp INF gốc.

Chú thích cuối trang
=========

[1] Đặc tả giao diện trình điều khiển mạng từ xa,
[[ZZ0000ZZ

[2] Mô hình điều khiển trừu tượng lớp thiết bị truyền thông, thông số kỹ thuật cho việc này
và các lớp USB khác có thể được tìm thấy tại
[[ZZ0000ZZ

[3] Mô hình điều khiển Ethernet CDC.

[4] [[ZZ0000ZZ

[5] [[ZZ0000ZZ

[6] Nói một cách hay ho khác, Windows không phản hồi được
bất kỳ đầu vào nào của người dùng.

[7] Bạn có thể tìm thấy [[ZZ0000ZZ
hữu ích.

[8] ZZ0000ZZ

[9] [[ZZ0000ZZ
