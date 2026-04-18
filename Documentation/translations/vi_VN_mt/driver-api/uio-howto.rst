.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/uio-howto.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
Không gian người dùng I/O HOWTO
=======================

:Tác giả: Nhà phát triển Hans-Jürgen Koch Linux, Linutronix
:Ngày: 11-12-2006

Về tài liệu này
===================

Bản dịch
------------

Nếu bạn biết bất kỳ bản dịch nào cho tài liệu này hoặc bạn quan tâm
khi dịch nó, vui lòng gửi email cho tôi hjk@hansjkoch.de.

Lời nói đầu
-------

Đối với nhiều loại thiết bị, việc tạo trình điều khiển nhân Linux là quá mức cần thiết.
Tất cả những gì thực sự cần thiết là một cách nào đó để xử lý sự gián đoạn và cung cấp
truy cập vào không gian bộ nhớ của thiết bị. Logic điều khiển
thiết bị không nhất thiết phải nằm trong kernel, vì thiết bị
không cần phải tận dụng bất kỳ nguồn tài nguyên nào khác mà
hạt nhân cung cấp. Một loại thiết bị phổ biến như thế này là
cho các card I/O công nghiệp.

Để giải quyết tình huống này, hệ thống I/O không gian người dùng (UIO) đã được thiết kế.
Đối với các thẻ I/O công nghiệp thông thường, chỉ có một mô-đun hạt nhân rất nhỏ được
cần thiết. Phần chính của trình điều khiển sẽ chạy trong không gian người dùng. Cái này
đơn giản hóa việc phát triển và giảm nguy cơ xảy ra lỗi nghiêm trọng trong một
mô-đun hạt nhân.

Xin lưu ý rằng UIO không phải là giao diện trình điều khiển phổ quát. Các thiết bị đó
đã được xử lý tốt bởi các hệ thống con kernel khác (như mạng hoặc
serial hoặc USB) không phải là ứng cử viên cho trình điều khiển UIO. Đó là phần cứng
lý tưởng cho trình điều khiển UIO đáp ứng tất cả những điều sau:

- Thiết bị có bộ nhớ có thể được ánh xạ. Thiết bị có thể được
   được điều khiển hoàn toàn bằng cách ghi vào bộ nhớ này.

- Thiết bị thường tạo ra các ngắt.

- Thiết bị không phù hợp với một trong các hệ thống con kernel tiêu chuẩn.

Lời cảm ơn
---------------

Tôi muốn cảm ơn Thomas Gleixner và Benedikt Spranger của Linutronix,
người không chỉ viết hầu hết mã UIO mà còn giúp đỡ rất nhiều
viết HOWTO này bằng cách cung cấp cho tôi tất cả các loại thông tin cơ bản.

Nhận xét
--------

Tìm thấy điều gì đó sai trái với tài liệu này? (Hoặc có lẽ điều gì đó đúng không?) Tôi
rất muốn nghe ý kiến từ bạn Vui lòng gửi email cho tôi theo địa chỉ hjk@hansjkoch.de.

Giới thiệu về UIO
=========

Nếu bạn sử dụng UIO cho trình điều khiển thẻ của mình, đây là những gì bạn nhận được:

- chỉ có một mô-đun hạt nhân nhỏ để viết và duy trì.

- phát triển phần chính của trình điều khiển của bạn trong không gian người dùng, với tất cả
   các công cụ và thư viện bạn đã quen sử dụng.

- lỗi trong trình điều khiển của bạn sẽ không làm hỏng kernel.

- cập nhật trình điều khiển của bạn có thể diễn ra mà không cần biên dịch lại kernel.

UIO hoạt động như thế nào
-------------

Mỗi thiết bị UIO được truy cập thông qua một tệp thiết bị và một số sysfs
các tập tin thuộc tính. Tệp thiết bị sẽ được gọi là ZZ0000ZZ cho
thiết bị đầu tiên và ZZ0001ZZ, ZZ0002ZZ, v.v. cho các thiết bị tiếp theo
thiết bị.

ZZ0001ZZ được sử dụng để truy cập vào không gian địa chỉ của thẻ. Chỉ cần sử dụng
ZZ0000ZZ để truy cập vào sổ đăng ký hoặc vị trí RAM trên thẻ của bạn.

Các ngắt được xử lý bằng cách đọc từ ZZ0002ZZ. chặn
ZZ0000ZZ từ ZZ0003ZZ sẽ quay trở lại ngay sau
ngắt xảy ra. Bạn cũng có thể sử dụng ZZ0001ZZ trên
ZZ0004ZZ để chờ ngắt. Giá trị số nguyên được đọc từ
ZZ0005ZZ đại diện cho tổng số lần ngắt. Bạn có thể sử dụng cái này
số để tìm hiểu xem bạn có bỏ lỡ một số ngắt không.

Đối với một số phần cứng có nhiều nguồn ngắt bên trong,
nhưng không tách riêng mặt nạ IRQ và các thanh ghi trạng thái, có thể có
tình huống trong đó không gian người dùng không thể xác định nguồn ngắt
là nếu trình xử lý kernel vô hiệu hóa chúng bằng cách ghi vào IRQ của chip
đăng ký. Trong trường hợp như vậy, kernel phải tắt hoàn toàn IRQ
để giữ nguyên thanh ghi của chip. Bây giờ phần không gian người dùng có thể
xác định nguyên nhân ngắt nhưng không thể kích hoạt lại
ngắt quãng. Một vấn đề quan trọng khác là các chip trong đó việc kích hoạt lại các ngắt là
thao tác đọc-sửa-ghi thành trạng thái/xác nhận IRQ kết hợp
đăng ký. Điều này sẽ không phù hợp nếu một sự gián đoạn mới xảy ra đồng thời.

Để giải quyết những vấn đề này, UIO cũng triển khai hàm write(). Đó là
thường không được sử dụng và có thể bỏ qua đối với phần cứng chỉ có một
nguồn ngắt hoặc có các thanh ghi trạng thái và mặt nạ IRQ riêng biệt. Nếu bạn
tuy nhiên, cần nó, việc ghi vào ZZ0003ZZ sẽ gọi
Chức năng ZZ0000ZZ do trình điều khiển thực hiện. bạn có
để ghi giá trị 32 bit thường là 0 hoặc 1 để tắt hoặc
kích hoạt các ngắt. Nếu trình điều khiển không thực hiện
ZZ0001ZZ, ZZ0002ZZ sẽ trở lại với
ZZ0004ZZ.

Để xử lý các ngắt đúng cách, mô-đun hạt nhân tùy chỉnh của bạn có thể cung cấp
trình xử lý ngắt riêng. Nó sẽ tự động được gọi bởi chương trình tích hợp
người xử lý.

Đối với các thẻ không tạo ra ngắt nhưng cần được thăm dò, có
khả năng thiết lập bộ hẹn giờ kích hoạt trình xử lý ngắt tại
khoảng thời gian có thể cấu hình. Việc mô phỏng ngắt này được thực hiện bởi
gọi ZZ0000ZZ từ sự kiện của bộ đếm thời gian
người xử lý.

Mỗi trình điều khiển cung cấp các thuộc tính được sử dụng để đọc hoặc ghi
các biến. Các thuộc tính này có thể truy cập được thông qua các tệp sysfs. một phong tục
mô-đun trình điều khiển hạt nhân có thể thêm các thuộc tính riêng của nó vào thiết bị thuộc sở hữu của
trình điều khiển uio, nhưng chưa được thêm vào thiết bị UIO vào thời điểm này.
Điều này có thể thay đổi trong tương lai nếu nó hữu ích.

Các thuộc tính tiêu chuẩn sau được cung cấp bởi khung UIO:

- ZZ0000ZZ: Tên thiết bị của bạn. Nên sử dụng tên
   mô-đun hạt nhân của bạn cho việc này.

- ZZ0000ZZ: Chuỗi phiên bản do trình điều khiển của bạn xác định. Điều này cho phép
   phần không gian người dùng của trình điều khiển để xử lý các phiên bản khác nhau của
   mô-đun hạt nhân.

- ZZ0000ZZ: Tổng số lần ngắt được trình điều khiển xử lý kể từ khi
   lần cuối cùng nút thiết bị được đọc.

Các thuộc tính này xuất hiện trong thư mục ZZ0000ZZ.
Xin lưu ý rằng thư mục này có thể là một liên kết tượng trưng và không phải là một liên kết thực sự.
thư mục. Bất kỳ mã không gian người dùng nào truy cập vào nó đều phải có khả năng xử lý
cái này.

Mỗi thiết bị UIO có thể cung cấp một hoặc nhiều vùng bộ nhớ cho bộ nhớ
lập bản đồ. Điều này là cần thiết vì một số card I/O công nghiệp yêu cầu
truy cập vào nhiều vùng bộ nhớ PCI trong trình điều khiển.

Mỗi ánh xạ có thư mục riêng trong sysfs, ánh xạ đầu tiên xuất hiện
như ZZ0000ZZ. Ánh xạ tiếp theo tạo
thư mục ZZ0001ZZ, ZZ0002ZZ, v.v. Những thư mục này sẽ chỉ
xuất hiện nếu kích thước của ánh xạ không bằng 0.

Mỗi thư mục ZZ0000ZZ chứa bốn tệp chỉ đọc hiển thị
thuộc tính của bộ nhớ:

- ZZ0000ZZ: Mã định danh chuỗi cho ánh xạ này. Đây là tùy chọn,
   chuỗi có thể trống. Người lái xe có thể thiết lập điều này để dễ dàng hơn
   không gian người dùng để tìm ánh xạ chính xác.

- ZZ0000ZZ: Địa chỉ bộ nhớ có thể ánh xạ được.

- ZZ0000ZZ: Kích thước, tính bằng byte, của bộ nhớ được trỏ tới bởi addr.

- ZZ0002ZZ: Phần bù, tính bằng byte, phải được thêm vào con trỏ
   được ZZ0000ZZ trả về để lấy bộ nhớ thiết bị thực.
   Điều này rất quan trọng nếu bộ nhớ của thiết bị không được căn chỉnh theo trang.
   Hãy nhớ rằng các con trỏ được trả về bởi ZZ0001ZZ luôn
   đã căn chỉnh trang, vì vậy, tốt nhất là luôn thêm phần bù này.

Từ không gian người dùng, các ánh xạ khác nhau được phân biệt bằng cách điều chỉnh
tham số ZZ0001ZZ của lệnh gọi ZZ0000ZZ. Để lập bản đồ
bộ nhớ ánh xạ N, bạn phải sử dụng N lần kích thước trang làm
bù đắp::

offset = N * getpagesize();

Đôi khi có phần cứng với các vùng giống như bộ nhớ không thể
được ánh xạ bằng kỹ thuật được mô tả ở đây, nhưng vẫn có nhiều cách để
truy cập chúng từ không gian người dùng. Ví dụ phổ biến nhất là x86 ioport. Bật
hệ thống x86, không gian người dùng có thể truy cập các ioport này bằng cách sử dụng
ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ,
ZZ0003ZZ và các chức năng tương tự.

Vì các vùng ioport này không thể được ánh xạ nên chúng sẽ không xuất hiện trong
ZZ0000ZZ giống như bộ nhớ bình thường được mô tả ở trên.
Nếu không có thông tin về vùng cổng mà phần cứng cung cấp, nó
trở nên khó khăn đối với phần không gian người dùng của trình điều khiển để tìm ra phần nào
cổng thuộc về thiết bị UIO nào.

Để giải quyết tình trạng này, thư mục mới
ZZ0000ZZ đã được thêm vào. Nó chỉ tồn tại nếu người lái xe
muốn chuyển thông tin về một hoặc nhiều vùng cổng tới không gian người dùng.
Nếu đúng như vậy, các thư mục con có tên ZZ0001ZZ, ZZ0002ZZ, v.v.
bật, sẽ xuất hiện bên dưới ZZ0003ZZ.

Mỗi thư mục ZZ0000ZZ chứa bốn tệp chỉ đọc hiển thị tên,
điểm bắt đầu, kích thước và loại vùng cổng:

- ZZ0000ZZ: Mã định danh chuỗi cho vùng cổng này. Chuỗi là
   tùy chọn và có thể trống. Trình điều khiển có thể thiết lập nó để dễ dàng hơn cho
   không gian người dùng để tìm một vùng cổng nhất định.

- ZZ0000ZZ: Cảng đầu tiên của vùng này.

- ZZ0000ZZ: Số lượng cổng ở vùng này.

- ZZ0000ZZ: Một chuỗi mô tả loại cổng.

Viết mô-đun hạt nhân của riêng bạn
==============================

Hãy xem ZZ0000ZZ làm ví dụ. Sau đây
đoạn văn giải thích các phần khác nhau của tập tin này.

cấu trúc uio_info
---------------

Cấu trúc này cho khung biết chi tiết về trình điều khiển của bạn, Một số
các thành viên là bắt buộc, những thành viên khác là tùy chọn.

- ZZ0000ZZ: Bắt buộc. Tên tài xế của bạn sẽ như vậy
   xuất hiện trong sysfs. Tôi khuyên bạn nên sử dụng tên mô-đun của mình cho việc này.

- ZZ0000ZZ: Bắt buộc. Chuỗi này xuất hiện trong
   ZZ0001ZZ.

- ZZ0001ZZ: Bắt buộc nếu bạn có bộ nhớ
   có thể được ánh xạ với ZZ0000ZZ. Đối với mỗi bản đồ, bạn
   cần điền vào một trong các cấu trúc ZZ0002ZZ. Xem mô tả
   bên dưới để biết chi tiết.

- ZZ0000ZZ: Bắt buộc nếu bạn
   muốn chuyển thông tin về ioports tới không gian người dùng. Đối với mỗi cổng
   vùng bạn cần điền vào một trong các cấu trúc ZZ0001ZZ. Xem
   mô tả dưới đây để biết chi tiết.

- ZZ0000ZZ: Bắt buộc. Nếu phần cứng của bạn tạo ra một ngắt, đó là
   nhiệm vụ mô-đun của bạn để xác định số irq trong quá trình khởi tạo.
   Nếu bạn không có ngắt do phần cứng tạo ra nhưng muốn kích hoạt
   trình xử lý ngắt theo cách khác, đặt ZZ0001ZZ thành
   ZZ0002ZZ. Nếu bạn không có sự gián đoạn nào cả, bạn có thể đặt
   ZZ0003ZZ đến ZZ0004ZZ, mặc dù điều này hiếm khi có ý nghĩa.

- ZZ0001ZZ: Bắt buộc nếu bạn đã đặt ZZ0002ZZ thành
   số ngắt phần cứng. Những lá cờ đưa ra ở đây sẽ được sử dụng trong
   gọi tới ZZ0000ZZ.

-ZZ0002ZZ:
   Tùy chọn. Nếu bạn cần một chiếc ZZ0000ZZ đặc biệt
   chức năng, bạn có thể đặt nó ở đây. Nếu con trỏ này không phải là NULL,
   ZZ0001ZZ sẽ được gọi thay vì tên tích hợp sẵn.

-ZZ0001ZZ:
   Tùy chọn. Bạn có thể muốn có ZZ0000ZZ của riêng mình,
   ví dụ: để chỉ kích hoạt các ngắt khi thiết bị của bạn thực sự được sử dụng.

-ZZ0002ZZ:
   Tùy chọn. Nếu bạn xác định ZZ0000ZZ của riêng mình, bạn sẽ
   có lẽ cũng muốn có chức năng ZZ0001ZZ tùy chỉnh.

-ZZ0000ZZ:
   Tùy chọn. Nếu bạn cần có khả năng kích hoạt hoặc vô hiệu hóa các ngắt
   từ không gian người dùng bằng cách viết thư tới ZZ0001ZZ, bạn có thể triển khai điều này
   chức năng. Tham số ZZ0002ZZ sẽ là 0 để vô hiệu hóa các ngắt
   và 1 để kích hoạt chúng.

Thông thường, thiết bị của bạn sẽ có một hoặc nhiều vùng bộ nhớ có thể
ánh xạ tới không gian người dùng. Đối với mỗi khu vực, bạn phải thiết lập một
ZZ0000ZZ trong mảng ZZ0001ZZ. Đây là mô tả của
các trường của ZZ0002ZZ:

- ZZ0000ZZ: Tùy chọn. Đặt cái này để giúp xác định bộ nhớ
   vùng, nó sẽ hiển thị trong nút sysfs tương ứng.

- ZZ0001ZZ: Bắt buộc nếu sử dụng ánh xạ. Đặt cái này thành
   ZZ0002ZZ nếu bạn có bộ nhớ vật lý trên thẻ
   được ánh xạ. Sử dụng ZZ0003ZZ cho bộ nhớ logic (ví dụ: được phân bổ
   với ZZ0000ZZ chứ không phải kmalloc()). Ngoài ra còn có
   ZZ0004ZZ cho bộ nhớ ảo.

- ZZ0000ZZ: Bắt buộc nếu sử dụng ánh xạ. Điền vào
   địa chỉ của khối bộ nhớ của bạn. Địa chỉ này là địa chỉ xuất hiện trong
   sysfs.

- ZZ0000ZZ: Điền kích thước của khối bộ nhớ mà
   ZZ0001ZZ chỉ tới. Nếu ZZ0002ZZ bằng 0, việc ánh xạ được xem xét
   chưa sử dụng. Lưu ý rằng ZZ0004ZZ khởi tạo ZZ0003ZZ bằng 0 cho tất cả
   ánh xạ không sử dụng.

- ZZ0001ZZ: Nếu bạn phải truy cập vùng bộ nhớ này
   từ bên trong mô-đun hạt nhân của mình, bạn sẽ muốn ánh xạ nó bên trong bằng
   sử dụng cái gì đó như ZZ0000ZZ. Địa chỉ được trả về bởi
   chức năng này không thể được ánh xạ tới không gian người dùng, vì vậy bạn không được lưu trữ
   nó trong ZZ0002ZZ. Thay vào đó hãy sử dụng ZZ0003ZZ để ghi nhớ một
   địa chỉ.

Vui lòng không chạm vào phần tử ZZ0000ZZ của ZZ0001ZZ! Đó là
được khung UIO sử dụng để thiết lập các tệp sysfs cho ánh xạ này. Đơn giản thôi
để nó yên.

Đôi khi, thiết bị của bạn có thể có một hoặc nhiều vùng cổng không thể
được ánh xạ tới không gian người dùng. Nhưng nếu có những khả năng khác cho
không gian người dùng để truy cập vào các cổng này, việc tạo ra thông tin là điều hợp lý
về các cổng có sẵn trong sysfs. Đối với mỗi khu vực, bạn phải thiết lập
một ZZ0000ZZ trong mảng ZZ0001ZZ. Đây là mô tả của
các trường của ZZ0002ZZ:

- ZZ0000ZZ: Bắt buộc. Đặt cái này thành một trong những cái được xác định trước
   hằng số. Sử dụng ZZ0001ZZ cho các ioport được tìm thấy trong x86
   kiến trúc.

- ZZ0000ZZ: Bắt buộc nếu sử dụng vùng cổng. Điền vào
   số cảng đầu tiên của khu vực này.

- ZZ0000ZZ: Điền số cổng ở vùng này.
   Nếu ZZ0001ZZ bằng 0 thì vùng đó được coi là không sử dụng. Lưu ý rằng bạn
   ZZ0003ZZ khởi tạo ZZ0002ZZ bằng 0 cho tất cả các vùng không sử dụng.

Vui lòng không chạm vào phần tử ZZ0000ZZ của ZZ0001ZZ! Đó là
được sử dụng nội bộ bởi khung UIO để thiết lập các tệp sysfs cho việc này
khu vực. Đơn giản chỉ cần để nó một mình.

Thêm trình xử lý ngắt
---------------------------

Những gì bạn cần làm trong trình xử lý ngắt phụ thuộc vào phần cứng của bạn
và về cách bạn muốn xử lý nó. Bạn nên cố gắng duy trì số lượng
mã trong trình xử lý ngắt kernel của bạn ở mức thấp. Nếu phần cứng của bạn không yêu cầu
hành động mà ZZ0000ZZ của bạn thực hiện sau mỗi lần ngắt, thì
trình xử lý có thể trống.

Mặt khác, nếu phần cứng ZZ0000ZZ của bạn thực hiện một số hành động
sau mỗi lần ngắt, ZZ0001ZZ sẽ thực hiện điều đó trong mô-đun hạt nhân của mình. Lưu ý
rằng bạn không thể dựa vào phần không gian người dùng của trình điều khiển. của bạn
chương trình không gian người dùng có thể chấm dứt bất cứ lúc nào, có thể để lại
phần cứng ở trạng thái vẫn cần xử lý ngắt thích hợp.

Cũng có thể có những ứng dụng mà bạn muốn đọc dữ liệu từ
phần cứng tại mỗi lần ngắt và đệm nó vào một phần bộ nhớ kernel
bạn đã phân bổ cho mục đích đó. Với kỹ thuật này bạn có thể tránh được
mất dữ liệu nếu chương trình không gian người dùng của bạn bị gián đoạn.

Lưu ý về các ngắt được chia sẻ: Trình điều khiển của bạn nên hỗ trợ ngắt
chia sẻ bất cứ khi nào có thể. Có thể nếu và chỉ khi bạn
trình điều khiển có thể phát hiện xem phần cứng của bạn có kích hoạt ngắt hay không
không. Điều này thường được thực hiện bằng cách nhìn vào thanh ghi trạng thái ngắt. Nếu
trình điều khiển của bạn thấy rằng bit IRQ thực sự đã được thiết lập, nó sẽ thực hiện
hành động và trình xử lý trả về IRQ_HANDLED. Nếu người lái xe phát hiện
rằng không phải phần cứng của bạn gây ra sự gián đoạn, nó sẽ làm như vậy
không có gì và trả về IRQ_NONE, cho phép kernel gọi tiếp theo
xử lý ngắt có thể.

Nếu bạn quyết định không hỗ trợ các ngắt được chia sẻ, thẻ của bạn sẽ không hoạt động trong
máy tính không có ngắt miễn phí. Vì điều này thường xuyên xảy ra trên PC
nền tảng, bạn có thể tránh cho mình rất nhiều rắc rối bằng cách hỗ trợ ngắt
chia sẻ.

Sử dụng uio_pdrv cho các thiết bị nền tảng
-----------------------------------

Trong nhiều trường hợp, trình điều khiển UIO cho các thiết bị nền tảng có thể được xử lý theo cách
cách chung chung. Ở cùng một nơi mà bạn xác định
ZZ0000ZZ, bạn cũng chỉ cần thực hiện ngắt của mình
handler và điền vào ZZ0001ZZ của bạn. Một con trỏ tới đây
ZZ0002ZZ sau đó được sử dụng làm ZZ0003ZZ cho nền tảng của bạn
thiết bị.

Bạn cũng cần thiết lập một mảng ZZ0000ZZ chứa
địa chỉ và kích thước của ánh xạ bộ nhớ của bạn. Thông tin này được thông qua
tới trình điều khiển bằng cách sử dụng các phần tử ZZ0001ZZ và ZZ0002ZZ của
ZZ0003ZZ.

Bây giờ bạn phải đặt phần tử ZZ0000ZZ của ZZ0001ZZ
sang ZZ0002ZZ để sử dụng trình điều khiển thiết bị nền tảng UIO chung. Cái này
trình điều khiển sẽ điền vào mảng ZZ0003ZZ theo các tài nguyên được cung cấp,
và đăng ký thiết bị.

Ưu điểm của phương pháp này là bạn chỉ phải chỉnh sửa một tập tin mà bạn
dù sao cũng cần phải chỉnh sửa. Bạn không cần phải tạo thêm trình điều khiển.

Sử dụng uio_pdrv_genirq cho các thiết bị nền tảng
------------------------------------------

Đặc biệt là trong các thiết bị nhúng, bạn thường xuyên tìm thấy các chip có lỗi không rõ ràng.
chân được gắn với đường ngắt chuyên dụng của chính nó. Trong những trường hợp như vậy, nơi
bạn có thể thực sự chắc chắn rằng ngắt không được chia sẻ, chúng ta có thể thực hiện
khái niệm ZZ0000ZZ tiến thêm một bước và sử dụng ngắt chung
người xử lý. Đó là những gì ZZ0001ZZ làm.

Việc thiết lập trình điều khiển này giống như được mô tả ở trên cho
ZZ0000ZZ, ngoại trừ việc bạn không triển khai trình xử lý ngắt. các
Phần tử ZZ0001ZZ của ZZ0002ZZ phải giữ nguyên ZZ0003ZZ. các
Phần tử ZZ0004ZZ không được chứa ZZ0005ZZ.

Bạn sẽ đặt phần tử ZZ0000ZZ của ZZ0001ZZ thành
ZZ0002ZZ để sử dụng trình điều khiển này.

Trình xử lý ngắt chung của ZZ0002ZZ sẽ đơn giản vô hiệu hóa
đường ngắt sử dụng ZZ0000ZZ. Sau
thực hiện công việc của mình, không gian người dùng có thể kích hoạt lại ngắt bằng cách viết
0x00000001 vào tệp thiết bị UIO. Trình điều khiển đã thực hiện một
ZZ0001ZZ để thực hiện được điều này, bạn không được
thực hiện của riêng bạn.

Sử dụng ZZ0000ZZ không chỉ tiết kiệm được vài dòng ngắt
mã xử lý. Bạn cũng không cần biết gì về chip
các thanh ghi nội bộ để tạo phần kernel của trình điều khiển. Tất cả những gì bạn cần
cần biết số irq của chân mà chip được kết nối tới.

Khi được sử dụng trong hệ thống hỗ trợ cây thiết bị, trình điều khiển cần phải được
đã thử nghiệm với tham số mô-đun ZZ0000ZZ được đặt thành ZZ0001ZZ
chuỗi nút mà trình điều khiển có nhiệm vụ xử lý. Theo mặc định,
tên của nút (không có địa chỉ đơn vị) được hiển thị dưới dạng tên cho
Thiết bị UIO trong không gian người dùng. Để đặt tên tùy chỉnh, thuộc tính có tên
ZZ0002ZZ có thể được chỉ định trong nút DT.

Sử dụng uio_dmem_genirq cho các thiết bị nền tảng
------------------------------------------

Ngoài các phạm vi bộ nhớ được cấp phát tĩnh, chúng cũng có thể là một
mong muốn sử dụng các vùng được phân bổ động trong trình điều khiển không gian người dùng. trong
đặc biệt, có thể truy cập vào bộ nhớ có sẵn thông qua
ánh xạ dma API, có thể đặc biệt hữu ích. ZZ0000ZZ
driver cung cấp một cách để thực hiện điều này.

Trình điều khiển này được sử dụng theo cách tương tự như ZZ0000ZZ
trình điều khiển liên quan đến cấu hình và xử lý ngắt.

Đặt phần tử ZZ0000ZZ của ZZ0001ZZ thành
ZZ0002ZZ để sử dụng trình điều khiển này.

Khi sử dụng trình điều khiển này, hãy điền vào phần tử ZZ0000ZZ của
ZZ0001ZZ, thuộc loại
ZZ0002ZZ và chứa các nội dung sau
các yếu tố:

- ZZ0000ZZ: Cấu trúc tương tự như
   Dữ liệu nền tảng ZZ0001ZZ

- ZZ0000ZZ: Con trỏ tới danh sách kích thước của
   vùng bộ nhớ động được ánh xạ vào không gian người dùng.

- ZZ0000ZZ: Số phần tử trong
   Mảng ZZ0001ZZ.

Các vùng động được xác định trong dữ liệu nền tảng sẽ được thêm vào
Mảng ZZ0000ZZ sau tài nguyên thiết bị nền tảng, ngụ ý
tổng số vùng bộ nhớ tĩnh và động không thể vượt quá
ZZ0001ZZ.

Các vùng bộ nhớ động sẽ được phân bổ khi tệp thiết bị UIO,
ZZ0000ZZ được mở. Tương tự như tài nguyên bộ nhớ tĩnh, bộ nhớ
thông tin vùng cho các vùng động sau đó được hiển thị qua sysfs tại
ZZ0001ZZ. Các vùng bộ nhớ động sẽ được
được giải phóng khi đóng tệp thiết bị UIO. Khi không có tiến trình nào được giữ
tệp thiết bị được mở, địa chỉ được trả về không gian người dùng là ~0.

Viết trình điều khiển trong không gian người dùng
=============================

Khi bạn có mô-đun hạt nhân hoạt động cho phần cứng của mình, bạn có thể viết
phần không gian người dùng của trình điều khiển của bạn. Bạn không cần bất kỳ thư viện đặc biệt nào,
trình điều khiển của bạn có thể được viết bằng bất kỳ ngôn ngữ hợp lý nào, bạn có thể sử dụng
số dấu phẩy động và vân vân. Tóm lại, bạn có thể sử dụng tất cả các công cụ
và các thư viện bạn thường sử dụng để viết ứng dụng vùng người dùng.

Nhận thông tin về thiết bị UIO của bạn
-----------------------------------------

Thông tin về tất cả các thiết bị UIO có sẵn trong sysfs. Điều đầu tiên
bạn nên làm trong trình điều khiển của mình là kiểm tra ZZ0000ZZ và ZZ0001ZZ để thực hiện
chắc chắn rằng bạn đang nói chuyện với đúng thiết bị và trình điều khiển hạt nhân của nó có
phiên bản bạn mong đợi.

Bạn cũng nên đảm bảo rằng ánh xạ bộ nhớ bạn cần tồn tại và
có kích thước bạn mong đợi.

Có một công cụ tên là ZZ0000ZZ liệt kê các thiết bị UIO và chúng
thuộc tính. Nó có sẵn ở đây:

ZZ0000ZZ

Với ZZ0000ZZ, bạn có thể nhanh chóng kiểm tra xem mô-đun hạt nhân của mình đã được tải chưa và
thuộc tính nào nó xuất khẩu. Hãy xem manpage để biết chi tiết.

Mã nguồn của ZZ0000ZZ có thể dùng làm ví dụ để lấy
thông tin về thiết bị UIO. Tệp ZZ0001ZZ chứa một
rất nhiều chức năng bạn có thể sử dụng trong mã trình điều khiển không gian người dùng của mình.

bộ nhớ thiết bị mmap()
--------------------

Sau khi bạn chắc chắn rằng mình đã có đúng thiết bị với ánh xạ bộ nhớ
bạn cần, tất cả những gì bạn phải làm là gọi ZZ0000ZZ để lập bản đồ
bộ nhớ của thiết bị vào không gian người dùng.

Tham số ZZ0001ZZ của cuộc gọi ZZ0000ZZ có một đặc biệt
ý nghĩa đối với các thiết bị UIO: Nó được sử dụng để chọn ánh xạ nào cho thiết bị của bạn
thiết bị bạn muốn ánh xạ. Để ánh xạ bộ nhớ ánh xạ N, bạn phải sử dụng
N lần kích thước trang làm phần bù của bạn::

offset = N * getpagesize();

N bắt đầu từ 0, vì vậy nếu bạn chỉ có một phạm vi bộ nhớ để ánh xạ, hãy đặt
ZZ0000ZZ. Hạn chế của kỹ thuật này là bộ nhớ luôn bị
được ánh xạ bắt đầu bằng địa chỉ bắt đầu của nó.

Chờ ngắt
----------------------

Sau khi ánh xạ thành công bộ nhớ thiết bị của bạn, bạn có thể truy cập nó
giống như một mảng thông thường. Thông thường, bạn sẽ thực hiện một số khởi tạo.
Sau đó, phần cứng của bạn bắt đầu hoạt động và sẽ tạo ra một ngắt
ngay sau khi nó hoàn tất, có sẵn một số dữ liệu hoặc cần bạn
chú ý vì đã xảy ra lỗi.

ZZ0003ZZ là tệp chỉ đọc. ZZ0000ZZ sẽ luôn
chặn cho đến khi xảy ra ngắt. Chỉ có một giá trị pháp lý cho
Tham số ZZ0004ZZ của ZZ0001ZZ và đó là kích thước của một
số nguyên có dấu 32 bit (4). Bất kỳ giá trị nào khác cho ZZ0005ZZ đều gây ra
ZZ0002ZZ thất bại. Số nguyên 32 bit có dấu được đọc là
số lượng gián đoạn của thiết bị của bạn. Nếu giá trị lớn hơn giá trị một đơn vị
bạn đọc lần cuối, mọi thứ đều ổn. Nếu sự khác biệt lớn hơn
hơn một, bạn đã bỏ lỡ các ngắt.

Bạn cũng có thể sử dụng ZZ0000ZZ trên ZZ0001ZZ.

Trình điều khiển PCI UIO chung
======================

Trình điều khiển chung là mô-đun hạt nhân có tên uio_pci_generic. Nó có thể
hoạt động với mọi thiết bị tuân thủ PCI 2.3 (khoảng năm 2002) và mọi thiết bị tuân thủ
Thiết bị PCI Express. Sử dụng cái này, bạn chỉ cần viết không gian người dùng
trình điều khiển, loại bỏ nhu cầu viết mô-đun hạt nhân dành riêng cho phần cứng.

Làm cho người lái xe nhận ra thiết bị
--------------------------------------

Vì trình điều khiển không khai báo bất kỳ id thiết bị nào nên nó sẽ không được tải
tự động và sẽ không tự động liên kết với bất kỳ thiết bị nào, bạn phải
tải nó và tự phân bổ id cho trình điều khiển. Ví dụ::

modprobe uio_pci_generic
     echo "8086 10f5" > /sys/bus/pci/drivers/uio_pci_generic/new_id

Nếu đã có trình điều khiển hạt nhân dành riêng cho phần cứng cho thiết bị của bạn,
trình điều khiển chung vẫn không liên kết với nó, trong trường hợp này nếu bạn muốn
sử dụng trình điều khiển chung (tại sao bạn lại làm vậy?), bạn sẽ phải hủy liên kết theo cách thủ công
trình điều khiển phần cứng cụ thể và liên kết trình điều khiển chung, như thế này ::

echo -n 0000:00:19.0 > /sys/bus/pci/drivers/e1000e/unbind
        echo -n 0000:00:19.0 > /sys/bus/pci/drivers/uio_pci_generic/bind

Bạn có thể xác minh rằng thiết bị đã được liên kết với trình điều khiển bằng cách xem
cho nó trong sysfs, ví dụ như sau::

ls -l /sys/bus/pci/devices/0000:00:19.0/driver

Mà nếu thành công nên in::

      .../0000:00:19.0/driver -> ../../../bus/pci/drivers/uio_pci_generic

Lưu ý rằng trình điều khiển chung sẽ không liên kết với các thiết bị PCI 2.2 cũ. Nếu
liên kết thiết bị không thành công, hãy chạy lệnh sau ::

dmesg

và nhìn vào đầu ra để tìm lý do thất bại.

Những điều cần biết về uio_pci_generic
------------------------------------

Các ngắt được xử lý bằng cách sử dụng bit Vô hiệu hóa ngắt trong PCI
thanh ghi lệnh và bit trạng thái ngắt trong thanh ghi trạng thái PCI.
Tất cả các thiết bị tuân thủ PCI 2.3 (khoảng năm 2002) và tất cả các thiết bị tuân thủ PCI
Các thiết bị Express nên hỗ trợ các bit này. uio_pci_generic phát hiện
hỗ trợ này và sẽ không liên kết với các thiết bị không hỗ trợ
Ngắt Bit vô hiệu hóa trong thanh ghi lệnh.

Trên mỗi ngắt, uio_pci_generic đặt bit Vô hiệu hóa ngắt.
Điều này ngăn thiết bị tạo ra các ngắt tiếp theo cho đến khi
bit được xóa. Trình điều khiển vùng người dùng phải xóa bit này trước khi
chặn và chờ đợi nhiều ngắt hơn.

Viết trình điều khiển không gian người dùng bằng uio_pci_generic
------------------------------------------------

Trình điều khiển không gian người dùng có thể sử dụng giao diện pci sysfs hoặc thư viện libpci
gói nó, để nói chuyện với thiết bị và kích hoạt lại các ngắt bằng cách viết
tới thanh ghi lệnh.

Mã ví dụ sử dụng uio_pci_generic
----------------------------------

Dưới đây là một số mã trình điều khiển không gian người dùng mẫu sử dụng uio_pci_generic::

#include <stdlib.h>
    #include <stdio.h>
    #include <unistd.h>
    #include <sys/types.h>
    #include <sys/stat.h>
    #include <fcntl.h>
    #include <errno.h>

int chính()
    {
        int uiofd;
        cấu hình int;
        int lỗi;
        int tôi;
        icount không dấu;
        lệnh char không dấu_high;

uiofd = open("/dev/uio0", O_RDONLY);
        nếu (uiofd < 0) {
            perror("uio open:");
            trả lại lỗi;
        }
        configfd = open("/sys/class/uio/uio0/device/config", O_RDWR);
        nếu (cấu hình < 0) {
            perror("cấu hình mở:");
            trả lại lỗi;
        }

/* Đọc và lưu giá trị lệnh vào bộ đệm */
        err = pread(configfd, &command_high, 1, 5);
        nếu (err != 1) {
            perror("đọc cấu hình lệnh:");
            trả lại lỗi;
        }
        command_high &= ~0x4;

for(i = 0;; ++i) {
            /* In ra một thông báo để gỡ lỗi. */
            nếu (tôi == 0)
                fprintf(stderr, "Đã khởi động trình điều khiển kiểm tra uio.\n");
            khác
                fprintf(stderr, "Ngắt: %d\n", icount);

/***************************************/
            /* Ở đây chúng ta nhận được một ngắt từ
               thiết bị. Hãy làm điều gì đó với nó. */
            /***************************************/

/* Kích hoạt lại các ngắt. */
            err = pwrite(configfd, &command_high, 1, 5);
            nếu (err != 1) {
                perror("ghi cấu hình:");
                phá vỡ;
            }

/* Đợi ngắt tiếp theo. */
            err = đọc(uiofd, &icount, 4);
            nếu (err != 4) {
                perror("uio đã đọc:");
                phá vỡ;
            }

}
        trả lại lỗi;
    }

Trình điều khiển Hyper-V UIO chung
==========================

Trình điều khiển chung là mô-đun hạt nhân có tên uio_hv_generic. Nó
hỗ trợ các thiết bị trên Hyper-V VMBus tương tự như uio_pci_generic trên
Xe buýt PCI.

Làm cho người lái xe nhận ra thiết bị
--------------------------------------

Vì trình điều khiển không khai báo bất kỳ thiết bị nào của GUID nên nó sẽ không nhận được
được tải tự động và sẽ không tự động liên kết với bất kỳ thiết bị nào, bạn
phải tự tải nó và cấp id cho driver. Ví dụ, để sử dụng
lớp thiết bị mạng GUID::

modprobe uio_hv_generic
     echo "f8615163-df3e-46c5-913f-f2d2f965ed0e" > /sys/bus/vmbus/drivers/uio_hv_generic/new_id

Nếu đã có trình điều khiển hạt nhân dành riêng cho phần cứng cho thiết bị,
trình điều khiển chung vẫn không liên kết với nó, trong trường hợp này nếu bạn muốn
sử dụng trình điều khiển chung cho thư viện không gian người dùng, bạn sẽ phải hủy liên kết theo cách thủ công
trình điều khiển dành riêng cho phần cứng và liên kết trình điều khiển chung, sử dụng GUID dành riêng cho thiết bị
như thế này::

echo -n ed963694-e847-4b2a-85af-bc9cfc11d6f3 > /sys/bus/vmbus/drivers/hv_netvsc/unbind
          echo -n ed963694-e847-4b2a-85af-bc9cfc11d6f3 > /sys/bus/vmbus/drivers/uio_hv_generic/bind

Bạn có thể xác minh rằng thiết bị đã được liên kết với trình điều khiển bằng cách xem
cho nó trong sysfs, ví dụ như sau::

ls -l /sys/bus/vmbus/devices/ed963694-e847-4b2a-85af-bc9cfc11d6f3/driver

Mà nếu thành công nên in::

      .../ed963694-e847-4b2a-85af-bc9cfc11d6f3/driver -> ../../../bus/vmbus/drivers/uio_hv_generic

Những điều cần biết về uio_hv_generic
-----------------------------------

Trên mỗi ngắt, uio_hv_generic đặt bit Vô hiệu hóa ngắt. Cái này
ngăn chặn thiết bị tạo ra các ngắt tiếp theo cho đến khi bit đó được
đã xóa. Trình điều khiển vùng người dùng phải xóa bit này trước khi chặn và
chờ đợi nhiều gián đoạn hơn.

Khi máy chủ hủy bỏ một thiết bị, bộ mô tả tệp ngắt sẽ được đánh dấu
và mọi lần đọc bộ mô tả tệp ngắt sẽ trả về -EIO. Tương tự
đến một ổ cắm đóng hoặc thiết bị nối tiếp bị ngắt kết nối.

Vùng thiết bị vmbus được ánh xạ vào tài nguyên thiết bị uio:
    0) Bộ đệm vòng kênh: khách với máy chủ và máy chủ với khách
    1) Khách lưu trữ các trang báo hiệu ngắt
    2) Trang giám sát khách đến máy chủ
    3) Vùng đệm nhận mạng
    4) Vùng đệm gửi mạng

Nếu một kênh con được tạo theo yêu cầu lưu trữ thì uio_hv_generic
trình điều khiển thiết bị sẽ tạo tệp nhị phân sysfs cho bộ đệm vòng trên mỗi kênh.
Ví dụ::

/sys/bus/vmbus/devices/3811fe4d-0fa0-4b62-981a-74fc1084c757/channels/21/ring

Thông tin thêm
===================

-ZZ0000ZZ

-ZZ0000ZZ
