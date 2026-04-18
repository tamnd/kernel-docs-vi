.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/6pack.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================
Giao thức 6 gói
==============

Đây là 6pack-mini-HOWTO, được viết bởi

Andreas Konsgen DG3KQ

:Internet: ajk@comnets.uni-bremen.de
:AMPR-net: dg3kq@db0pra.ampr.org
:AX.25: dg3kq@db0ach.#nrw.deu.eu

Cập nhật lần cuối: ngày 7 tháng 4 năm 1998

1. 6pack là gì và KISS có ưu điểm gì?
======================================================

6pack là giao thức truyền tải để trao đổi dữ liệu giữa PC và
TNC qua đường dây nối tiếp. Nó có thể được sử dụng thay thế cho KISS.

6pack có hai ưu điểm chính:

- PC được trao toàn quyền điều khiển radio
  kênh. Dữ liệu điều khiển đặc biệt được trao đổi giữa PC và TNC để
  mà PC biết bất kỳ lúc nào nếu TNC đang nhận dữ liệu, nếu TNC
  đã xảy ra lỗi chạy quá hoặc tràn bộ đệm, nếu PTT bị
  thiết lập và như vậy. Dữ liệu kiểm soát này được xử lý ở mức ưu tiên cao hơn
  dữ liệu thông thường, do đó luồng dữ liệu có thể bị gián đoạn bất cứ lúc nào để đưa ra lệnh
  sự kiện quan trọng. Điều này giúp cải thiện khả năng truy cập kênh và thời gian
  thuật toán vì mọi thứ đều được tính toán trong PC. Nó thậm chí có thể
  để thử nghiệm thứ gì đó hoàn toàn khác với CSMA đã biết và
  Phương pháp truy cập kênh DAMA.
  Loại điều khiển thời gian thực này đặc biệt quan trọng để cung cấp một số
  Các TNC được kết nối với nhau và PC bằng chuỗi nối tiếp
  (tuy nhiên, tính năng này chưa được trình điều khiển Linux 6pack hỗ trợ).

- Mỗi gói được truyền qua đường nối tiếp được cung cấp một tổng kiểm tra,
  nên rất dễ phát hiện các lỗi do sự cố trên đường nối tiếp.
  Các gói đã nhận bị hỏng sẽ không được chuyển đến lớp AX.25.
  Các gói bị hỏng mà TNC nhận được từ PC sẽ không được truyền đi.

Thông tin chi tiết hơn về 6pack được mô tả trong tệp 6pack.ps nằm ở
trong thư mục doc của gói tiện ích AX.25.

2. Ai đã phát triển giao thức 6pack?
========================================

Giao thức 6pack được phát triển bởi Ekki Plicht DF4OR, Henning Rech
DF9IC và Gunter Jost DK7WJ. Trình điều khiển cho 6 múi, được viết bởi Gunter Jost và
Matthias Welwarsky DG2FEF, đi kèm với phiên bản PC của FlexNet.
Họ cũng đã viết một chương trình cơ sở cho các TNC để thực hiện cơ chế 6 múi
giao thức (xem phần 4 bên dưới).

3. Tôi có thể lấy phiên bản 6pack mới nhất cho LinuX ở đâu?
=========================================================

Hiện tại, nội dung 6pack có thể được lấy thông qua ftp ẩn danh từ
db0bm.automation.fh-aachen.de. Trong thư mục /incoming/dg3kq,
có một tập tin tên là 6pack.tgz.

4. Chuẩn bị TNC cho hoạt động 6 gói
========================================

Để có thể sử dụng 6pack, cần có phần sụn đặc biệt cho TNC. EPROM
của TNC mới mua không chứa 6pack, vì vậy bạn sẽ phải
hãy tự mình lập trình EPROM. Tệp hình ảnh cho EPROM 6 gói phải là
có sẵn trên bất kỳ hộp radio gói nào có thể tìm thấy PC/FlexNet. Tên của
tập tin là 6pack.bin. File này được giữ bản quyền và duy trì bởi FlexNet
đội. Nó có thể được sử dụng theo các điều khoản của giấy phép đi kèm
với PC/FlexNet. Vui lòng không hỏi tôi về nội dung bên trong của tập tin này vì tôi
không biết gì về nó Tôi đã sử dụng mô tả bằng văn bản về 6pack
giao thức để lập trình trình điều khiển Linux.

TNC chứa EPROM 64kByte, nửa dưới được sử dụng cho
phần sụn/KISS. Nửa trên trống hoặc đôi khi
được lập trình bằng phần mềm có tên TAPR. Trong trường hợp sau, TNC
được cung cấp kèm theo công tắc DIP để bạn có thể dễ dàng thay đổi giữa
hai hệ thống. Khi lập trình EPROM mới, một trong các hệ thống sẽ được thay thế
bằng 6 gói. Rất hữu ích khi thay thế TAPR vì phần mềm này hiếm khi được sử dụng
thời nay. Nếu TNC của bạn không được trang bị công tắc nêu trên, bạn
có thể tự xây dựng một cái để chuyển qua mã pin địa chỉ cao nhất
của EPROM giữa cấp độ HIGH và LOW. Sau khi lắp EPROM mới vào
và chuyển sang 6pack, cấp nguồn cho TNC để thử nghiệm lần đầu. Kết nối
và trạng thái LED sẽ sáng trong khoảng một giây nếu chương trình cơ sở khởi chạy
TNC một cách chính xác.

5. Xây dựng và cài đặt driver 6pack
===========================================

Trình điều khiển đã được thử nghiệm với phiên bản kernel 2.1.90. Sử dụng với cũ hơn
hạt nhân có thể dẫn đến lỗi biên dịch vì giao diện của hạt nhân
chức năng đã được thay đổi trong hạt nhân 2.1.8x.

Cách bật hỗ trợ 6pack:
-----------------------------

- Trong chương trình cấu hình kernel linux, chọn mức độ trưởng thành của mã
  menu tùy chọn và bật lời nhắc về trình điều khiển phát triển.

- Chọn menu hỗ trợ radio nghiệp dư và bật 6pack cổng nối tiếp
  người lái xe.

- Biên dịch và cài đặt kernel và các module.

Để sử dụng trình điều khiển, chương trình kissattach được cung cấp cùng với các tiện ích AX.25
phải được sửa đổi.

- Tạo một cd vào thư mục chứa nguồn kissattach. Chỉnh sửa
  tập tin kissattach.c. Ở trên cùng, chèn các dòng sau::

#ifndef N_6PACK
    #define N_6PACK (N_AX25+1)
    #endif

Sau đó tìm dòng:

đĩa int = N_AX25;

và thay thế N_AX25 bằng N_6PACK.

- Biên dịch lại kissattach. Đổi tên nó thành spatach để tránh nhầm lẫn.

Cài đặt trình điều khiển:
----------------------

- Tập insmod 6 múi. Nhìn vào tệp /var/log/messages của bạn để kiểm tra xem
  mô-đun đã in thông báo khởi tạo của nó.

- Thực hiện một thao tác spattach như khi bạn khởi chạy kissattach khi khởi động cổng KISS.
  Kiểm tra xem kernel có in thông báo '6pack: TNC Found' hay không.

- Từ đây, mọi thứ sẽ hoạt động như thể bạn đang thiết lập cổng KISS.
  Sự khác biệt duy nhất là thiết bị mạng đại diện cho
  cổng 6pack được gọi là sp thay vì sl hoặc ax. Vì vậy, sp0 sẽ là
  cổng 6pack đầu tiên.

Driver dù đã test trên nhiều nền tảng nhưng mình vẫn khai báo
ALPHA. HÃY LÀ CAREFUL! Đồng bộ hóa đĩa của bạn trước khi cài đặt mô-đun 6pack
và bắn tung tóe. Hãy chú ý nếu máy tính của bạn hoạt động kỳ lạ. phần đọc
6 của tập tin này về các vấn đề đã biết.

Lưu ý rằng đèn LED kết nối và trạng thái của TNC được điều khiển theo cách
khác với khi TNC được sử dụng với PC/FlexNet. Khi sử dụng
FlexNet, kết nối LED được bật nếu có kết nối; trạng thái LED là
bật nếu có dữ liệu trong bộ đệm của công cụ AX.25 của PC phải được
được truyền đi. Trong Linux, lớp 6pack nằm ngoài lớp AX.25,
vì vậy trình điều khiển 6pack không biết gì về kết nối hoặc dữ liệu
vẫn chưa được truyền đi. Vì vậy đèn LED được điều khiển
vì chúng đang ở chế độ KISS: Kết nối LED được bật nếu dữ liệu được truyền
từ PC đến TNC qua đường nối tiếp, trạng thái LED nếu dữ liệu là
gửi tới PC.

6. Các vấn đề đã biết
=================

Khi kiểm tra trình điều khiển với hạt nhân 2.0.3x và
hoạt động với tốc độ dữ liệu trên kênh vô tuyến từ 9600 Baud trở lên,
trên một số hệ thống nhất định, trình điều khiển đôi khi in thông báo '6pack:
tổng kiểm tra sai', nguyên nhân là do mất dữ liệu nếu trạm kia gửi hai
hoặc nhiều gói tiếp theo. Tôi đã được thông báo rằng điều này là do một vấn đề
với trình điều khiển nối tiếp của hạt nhân 2.0.3x. Tôi vẫn chưa biết liệu có vấn đề gì không
vẫn tồn tại với nhân 2.1.x, vì tôi nghe nói rằng trình điều khiển nối tiếp
mã đã được thay đổi với 2.1.x.

Khi tắt giao diện sp bằng ifconfig, kernel sẽ gặp sự cố nếu
vẫn còn một kết nối AX.25 còn lại có kết nối IP
đang chạy, ngay cả khi kết nối IP đó đã bị đóng. Vấn đề không
xảy ra khi có kết nối AX.25 trống vẫn đang chạy. Tôi không biết liệu
đây là sự cố của trình điều khiển 6pack hoặc lỗi khác trong kernel.

Trình điều khiển đã được thử nghiệm dưới dạng mô-đun, chưa phải là trình điều khiển tích hợp trong kernel.

Giao thức 6pack hỗ trợ nối chuỗi các TNC trong vòng mã thông báo, tức là
được kết nối với một cổng nối tiếp của PC. Tính năng này không được triển khai
và ít nhất là vào lúc này tôi sẽ không thể làm được điều đó vì tôi không có
cơ hội xây dựng chuỗi xích TNC và thử nghiệm nó.

Một số nhận xét trong mã nguồn không chính xác. Họ bị bỏ lại từ
trình điều khiển SLIP/KISS, từ đó trình điều khiển 6pack đã được tạo ra.
Tôi chưa sửa đổi hoặc xóa chúng -- xin lỗi! Bản thân mã cần
một số làm sạch và tối ưu hóa. Điều này sẽ được thực hiện trong bản phát hành sau.

Nếu bạn gặp lỗi hoặc nếu bạn có câu hỏi hoặc gợi ý liên quan đến
lái xe, vui lòng gửi thư cho tôi bằng cách sử dụng các địa chỉ được cung cấp ở đầu
tập tin này.

Chúc vui vẻ!

Andreas