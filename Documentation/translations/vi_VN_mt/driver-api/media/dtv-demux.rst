.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/dtv-demux.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Truyền hình kỹ thuật số Demux kABI
---------------------

Demux truyền hình kỹ thuật số
~~~~~~~~~~~~~~~~

Kernel Digital TV Demux kABI xác định giao diện bên trong trình điều khiển cho
đăng ký trình điều khiển phần cứng cụ thể, cấp thấp cho một phần cứng độc lập
lớp demux. Nó chỉ được những người viết trình điều khiển thiết bị TV kỹ thuật số quan tâm.
Tệp tiêu đề cho kABI này có tên ZZ0000ZZ và nằm ở
ZZ0001ZZ.

KABI demux nên được triển khai cho từng demux trong hệ thống. Đó là
được sử dụng để chọn nguồn TS của bộ giải mã và quản lý tài nguyên giải mã.
Khi máy khách demux phân bổ tài nguyên thông qua demux kABI, nó sẽ nhận được
một con trỏ tới kABI của tài nguyên đó.

Mỗi demux nhận đầu vào TS của nó từ giao diện người dùng DVB hoặc từ bộ nhớ, như
được thiết lập thông qua kABI demux này. Trong một hệ thống có nhiều hơn một giao diện người dùng, kABI
có thể được sử dụng để chọn một trong các giao diện người dùng DVB làm nguồn TS cho bộ giải mã,
trừ khi điều này được sửa trong nền tảng CTNH.

demux kABI chỉ kiểm soát các giao diện người dùng liên quan đến kết nối của chúng với
demuxes; kABI được sử dụng để đặt các tham số giao diện người dùng khác, chẳng hạn như
điều chỉnh, được xác định thông qua Digital TV Frontend kABI.

Các hàm thực hiện demux giao diện trừu tượng phải được xác định
tĩnh hoặc mô-đun riêng tư và được đăng ký vào lõi Demux cho bên ngoài
truy cập. Không cần thiết phải thực hiện mọi chức năng trong cấu trúc
ZZ0000ZZ. Ví dụ: giao diện demux có thể hỗ trợ lọc Phần,
nhưng không lọc PES. Khách hàng kABI dự kiến sẽ kiểm tra giá trị của bất kỳ
con trỏ hàm trước khi gọi hàm: giá trị ZZ0001ZZ có nghĩa là
rằng chức năng này không có sẵn.

Bất cứ khi nào các chức năng của demux API sửa đổi dữ liệu được chia sẻ,
khả năng bị mất bản cập nhật và các vấn đề về tình trạng cuộc đua sẽ xảy ra
được giải quyết, ví dụ: bằng cách bảo vệ các phần mã bằng mutexes.

Lưu ý rằng các hàm được gọi từ ngữ cảnh nửa dưới không được ngủ.
Ngay cả việc cấp phát bộ nhớ đơn giản mà không sử dụng ZZ0000ZZ cũng có thể dẫn đến
luồng hạt nhân được đặt ở chế độ ngủ nếu cần trao đổi. Ví dụ,
Hạt nhân Linux gọi các chức năng của giao diện thiết bị mạng từ một
bối cảnh nửa dưới. Do đó, nếu một hàm demux kABI được gọi từ mạng
mã thiết bị, chức năng không được ngủ.

Gọi lại Demux API
~~~~~~~~~~~~~~~~~~

API không gian nhân này bao gồm các hàm gọi lại cung cấp các
dữ liệu đến máy khách demux. Không giống như các kABI DVB khác, các chức năng này là
được cung cấp bởi khách hàng và được gọi từ mã demux.

Các con trỏ hàm của giao diện trừu tượng này không được gói gọn trong một
cấu trúc như trong các API demux khác, vì các hàm gọi lại là
được đăng ký và sử dụng độc lập với nhau. Như một ví dụ, có thể
để máy khách API cung cấp một số chức năng gọi lại để nhận TS
gói và không có lệnh gọi lại cho các gói hoặc phần PES.

Các chức năng thực hiện lệnh gọi lại API không cần phải nhập lại: khi
trình điều khiển demux gọi một trong các chức năng này, trình điều khiển không được phép
gọi lại hàm trước khi cuộc gọi ban đầu quay trở lại. Nếu một cuộc gọi lại là
được kích hoạt do gián đoạn phần cứng, nên sử dụng Linux
cơ chế nửa dưới hoặc bắt đầu một tác vụ thay vì thực hiện gọi lại
gọi hàm trực tiếp từ một ngắt phần cứng.

Cơ chế này được thực hiện bởi ZZ0000ZZ và ZZ0001ZZ
cuộc gọi lại.

Chức năng đăng ký thiết bị Demux TV kỹ thuật số và cấu trúc dữ liệu
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. kernel-doc:: include/media/dmxdev.h

Giao diện demux TV kỹ thuật số cấp cao
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. kernel-doc:: include/media/dvb_demux.h

Giao diện giải mã trình điều khiển dành riêng cho phần cứng cấp thấp bên trong trình điều khiển
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. kernel-doc:: include/media/demux.h