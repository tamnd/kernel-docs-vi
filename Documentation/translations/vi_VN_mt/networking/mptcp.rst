.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/mptcp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Đa đường TCP (MPTCP)
=======================

Giới thiệu
============

Multipath TCP hoặc MPTCP là phần mở rộng của TCP tiêu chuẩn và được mô tả trong
ZZ0000ZZ. Nó cho phép một
thiết bị sử dụng nhiều giao diện cùng một lúc để gửi và nhận TCP
các gói qua một kết nối MPTCP. MPTCP có thể tổng hợp băng thông của
nhiều giao diện hoặc thích giao diện có độ trễ thấp nhất. Nó cũng cho phép một
chuyển đổi dự phòng nếu một đường dẫn bị hỏng và lưu lượng truy cập được đưa lại liền mạch trên đường dẫn khác
những con đường.

Để biết thêm chi tiết về Multipath TCP trong nhân Linux, vui lòng xem
trang web chính thức: ZZ0000ZZ.


Trường hợp sử dụng
==================

Nhờ MPTCP, có thể sử dụng nhiều đường dẫn song song hoặc đồng thời
mang lại những trường hợp sử dụng mới so với TCP:

- Chuyển giao liền mạch: chuyển từ đường này sang đường khác mà vẫn bảo toàn
  kết nối được thiết lập, ví dụ: được sử dụng trong các trường hợp sử dụng tính di động, như trên
  điện thoại thông minh.
- Lựa chọn mạng tốt nhất: sử dụng đường dẫn có sẵn "tốt nhất" tùy thuộc vào một số
  điều kiện, ví dụ: độ trễ, tổn thất, chi phí, băng thông, v.v.
- Tập hợp mạng: sử dụng nhiều đường dẫn cùng lúc để có hiệu suất cao hơn
  thông lượng, ví dụ: kết hợp mạng cố định và mạng di động để gửi file nhanh hơn.


Khái niệm
=========

Về mặt kỹ thuật, khi một ổ cắm mới được tạo bằng giao thức ZZ0000ZZ
(dành riêng cho Linux), ZZ0003ZZ (hoặc ZZ0004ZZ) được tạo. ZZ0005ZZ này bao gồm
kết nối TCP thông thường được sử dụng để truyền dữ liệu qua một giao diện.
ZZ0006ZZ bổ sung có thể được thương lượng sau giữa các máy chủ. Đối với điều khiển từ xa
máy chủ có thể phát hiện việc sử dụng MPTCP, một trường mới được thêm vào TCP
Trường ZZ0007ZZ của TCP ZZ0008ZZ cơ bản. Trường này chứa, trong số
những thứ khác, tùy chọn ZZ0001ZZ yêu cầu máy chủ khác sử dụng MPTCP nếu
nó được hỗ trợ. Nếu máy chủ từ xa hoặc bất kỳ hộp trung gian nào ở giữa không hỗ trợ
nó, gói ZZ0002ZZ được trả về sẽ không chứa các tùy chọn MPTCP trong TCP
Trường ZZ0009ZZ. Trong trường hợp đó, kết nối sẽ bị "hạ cấp" xuống TCP đơn giản,
và nó sẽ tiếp tục với một con đường duy nhất.

Hành vi này được thực hiện nhờ hai thành phần bên trong: trình quản lý đường dẫn và
bộ lập lịch gói.

Trình quản lý đường dẫn
-----------------------

Trình quản lý đường dẫn chịu trách nhiệm về ZZ0002ZZ, từ việc tạo đến xóa, đồng thời
thông báo địa chỉ. Thông thường, phía khách hàng sẽ khởi tạo các luồng con,
và phía máy chủ thông báo địa chỉ bổ sung thông qua ZZ0000ZZ và
Tùy chọn ZZ0001ZZ.

Trình quản lý đường dẫn được điều khiển bởi núm sysctl ZZ0000ZZ --
xem mptcp-sysctl.rst. Có hai loại: loại trong kernel (ZZ0001ZZ) trong đó
các quy tắc tương tự được áp dụng cho tất cả các kết nối (xem: ZZ0002ZZ); và
không gian người dùng một (ZZ0003ZZ), được điều khiển bởi daemon không gian người dùng (tức là ZZ0004ZZ), nơi có thể áp dụng các quy tắc khác nhau cho mỗi không gian người dùng
kết nối. Trình quản lý đường dẫn có thể được điều khiển thông qua Netlink API; nhìn thấy
../netlink/specs/mptcp_pm.rst.

Để có thể sử dụng nhiều địa chỉ IP trên một máy chủ để tạo nhiều ZZ0001ZZ
(đường dẫn), trình quản lý đường dẫn MPTCP trong kernel mặc định cần biết IP nào
địa chỉ có thể được sử dụng Điều này có thể được cấu hình với ZZ0000ZZ cho
ví dụ.

Lập lịch gói
----------------

Bộ lập lịch gói có trách nhiệm chọn ZZ0000ZZ nào có sẵn để
sử dụng để gửi gói dữ liệu tiếp theo. Nó có thể quyết định tối đa hóa việc sử dụng
băng thông sẵn có, chỉ để chọn đường dẫn có độ trễ thấp hơn hoặc bất kỳ đường dẫn nào khác
chính sách tùy thuộc vào cấu hình.

Bộ lập lịch gói được điều khiển bằng núm hệ thống ZZ0000ZZ --
xem mptcp-sysctl.rst.


Ổ cắm API
===========

Tạo ổ cắm MPTCP
----------------------

Trên Linux, MPTCP có thể được sử dụng bằng cách chọn MPTCP thay vì TCP khi tạo
ZZ0000ZZ:

.. code-block:: C

    int sd = socket(AF_INET(6), SOCK_STREAM, IPPROTO_MPTCP);

Lưu ý rằng ZZ0000ZZ được định nghĩa là ZZ0001ZZ.

Nếu MPTCP không được hỗ trợ, ZZ0000ZZ sẽ được đặt thành:

- ZZ0000ZZ: (ZZ0004ZZ): MPTCP không có sẵn, trên kernel < 5.6.
- ZZ0001ZZ (ZZ0005ZZ): MPTCP chưa được biên dịch,
  trên hạt nhân >= v5.6.
- ZZ0002ZZ (ZZ0006ZZ): MPTCP đã bị vô hiệu hóa khi sử dụng
  Núm xoay hệ thống ZZ0003ZZ; xem mptcp-sysctl.rst.

MPTCP sau đó được chọn tham gia: các ứng dụng cần yêu cầu nó một cách rõ ràng. Lưu ý rằng
các ứng dụng có thể bị buộc phải sử dụng MPTCP với các kỹ thuật khác nhau, ví dụ:
ZZ0000ZZ (xem ZZ0001ZZ), eBPF (xem ZZ0002ZZ), SystemTAP,
ZZ0003ZZ (ZZ0004ZZ), v.v.

Việc chuyển sang ZZ0000ZZ thay vì ZZ0001ZZ sẽ như sau
minh bạch nhất có thể cho các ứng dụng không gian người dùng.

Tùy chọn ổ cắm
--------------

MPTCP hỗ trợ hầu hết các tùy chọn ổ cắm do TCP xử lý. Có thể ít hơn
các tùy chọn chung không được hỗ trợ, nhưng đóng góp đều được hoan nghênh.

Nói chung, cùng một giá trị được truyền tới tất cả các luồng con, bao gồm cả các luồng con
được tạo sau các lệnh gọi tới ZZ0000ZZ. eBPF có thể được sử dụng để thiết lập các
giá trị trên mỗi luồng con.

Có một số tùy chọn ổ cắm cụ thể MPTCP ở cấp độ ZZ0000ZZ (284) để
truy xuất thông tin. Chúng lấp đầy bộ đệm ZZ0001ZZ của hệ thống ZZ0002ZZ
gọi:

- ZZ0000ZZ: Sử dụng ZZ0001ZZ.
- ZZ0002ZZ: Sử dụng ZZ0003ZZ, theo sau là một mảng
  ZZ0004ZZ.
- ZZ0005ZZ: Sử dụng ZZ0006ZZ, theo sau là một
  mảng ZZ0007ZZ.
- ZZ0008ZZ: Sử dụng ZZ0009ZZ, với một con trỏ tới một
  mảng ZZ0010ZZ (bao gồm cả
  ZZ0011ZZ) và một con trỏ tới một mảng
  ZZ0012ZZ, tiếp theo là nội dung của ZZ0013ZZ.

Lưu ý rằng ở cấp độ TCP, tùy chọn ổ cắm ZZ0000ZZ có thể được sử dụng để biết
nếu MPTCP hiện đang được sử dụng: giá trị sẽ được đặt thành 1 nếu có.


Lựa chọn thiết kế
=================

Một loại ổ cắm mới đã được thêm cho MPTCP dành cho ổ cắm hướng về không gian người dùng. các
kernel chịu trách nhiệm tạo các ổ cắm dòng con: chúng là các ổ cắm TCP trong đó
hành vi được sửa đổi bằng TCP-ULP.

Ổ cắm nghe MPTCP sẽ tạo ổ cắm ZZ0000ZZ TCP "đơn giản" nếu
yêu cầu kết nối từ máy khách không yêu cầu MPTCP, làm cho hiệu suất
tác động tối thiểu khi MPTCP được bật theo mặc định.