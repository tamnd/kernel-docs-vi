.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/xsk-tx-metadata.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================
Siêu dữ liệu AF_XDP TX
==================

Tài liệu này mô tả cách kích hoạt tính năng giảm tải khi truyền gói tin
thông qua ZZ0000ZZ. Tham khảo ZZ0001ZZ về cách truy cập tương tự
siêu dữ liệu ở phía nhận.

Thiết kế chung
==============

Khoảng trống cho siêu dữ liệu được dành riêng qua ZZ0000ZZ và
Cờ ZZ0001ZZ trong ZZ0002ZZ. Siêu dữ liệu
do đó, độ dài là như nhau đối với mọi ổ cắm có chung umem.
Bố cục siêu dữ liệu là UAPI cố định, hãy tham khảo ZZ0003ZZ trong
ZZ0004ZZ. Vì vậy, nhìn chung, ZZ0005ZZ
trường ở trên phải chứa ZZ0006ZZ.

Lưu ý rằng trong quá trình triển khai ban đầu, ZZ0000ZZ
cờ không cần thiết. Các ứng dụng có thể cố gắng tạo umem
bằng cờ trước và nếu thất bại, hãy thử lại mà không có cờ.

Khoảng trống và siêu dữ liệu phải được đặt ngay trước
ZZ0000ZZ trong khung umem. Trong một khung, siêu dữ liệu
bố cục như sau::

tx_metadata_len
     / \
    +--------+----------+-----------------------------+
    Phần đệm ZZ0000ZZ ZZ0001ZZ
    +--------+----------+-----------------------------+
                                ^
                                |
                          xdp_desc->addr

Ứng dụng AF_XDP có thể yêu cầu khoảng không gian lớn hơn ZZ0000ZZ. Hạt nhân sẽ bỏ qua phần đệm (và vẫn sẽ
sử dụng ZZ0001ZZ để xác định vị trí
ZZ0002ZZ). Đối với các khung không nên mang theo
bất kỳ siêu dữ liệu nào (tức là những siêu dữ liệu không có tùy chọn ZZ0003ZZ),
khu vực siêu dữ liệu cũng bị kernel bỏ qua.

Trường cờ cho phép giảm tải cụ thể:

- ZZ0000ZZ: yêu cầu thiết bị đặt đường truyền
  dấu thời gian vào trường ZZ0001ZZ của ZZ0002ZZ.
- ZZ0003ZZ: yêu cầu thiết bị tính L4
  tổng kiểm tra. ZZ0004ZZ chỉ định độ lệch byte của nơi kiểm tra tổng
  sẽ bắt đầu và ZZ0005ZZ chỉ định độ lệch byte trong đó
  thiết bị nên lưu trữ tổng kiểm tra được tính toán.
- ZZ0006ZZ: yêu cầu thiết bị lên lịch
  gói để truyền vào một thời điểm xác định trước gọi là thời gian khởi động. các
  giá trị thời gian khởi chạy được biểu thị bằng trường ZZ0007ZZ của
  ZZ0008ZZ.

Ngoài những lá cờ trên, để kích hoạt việc giảm tải, điều đầu tiên
bộ mô tả ZZ0000ZZ của gói nên đặt ZZ0001ZZ
bit trong trường ZZ0002ZZ. Cũng lưu ý rằng trong gói nhiều bộ đệm
chỉ đoạn đầu tiên mới mang siêu dữ liệu.

Tổng kiểm tra TX phần mềm
====================

Đối với mục đích phát triển và thử nghiệm, có thể vượt qua
Cờ ZZ0000ZZ tới cuộc gọi đăng ký ZZ0001ZZ UMEM.
Trong trường hợp này, khi chạy ở chế độ ZZ0002ZZ, tổng kiểm tra TX
được tính toán trên CPU. Không kích hoạt tùy chọn này trong sản xuất vì
nó sẽ ảnh hưởng tiêu cực đến hiệu suất.

Thời gian ra mắt
===========

Giá trị của thời gian khởi chạy được yêu cầu phải dựa trên PTP của thiết bị
Đồng hồ phần cứng (PHC) để đảm bảo độ chính xác. AF_XDP có đường dẫn dữ liệu khác
so với nguyên tắc xếp hàng ETF, nguyên tắc tổ chức các gói và độ trễ
sự truyền tải của họ. Thay vào đó, AF_XDP ngay lập tức chuyển các gói tin tới
trình điều khiển thiết bị mà không sắp xếp lại thứ tự hoặc giữ chúng trước
truyền tải. Vì trình điều khiển duy trì hoạt động của FIFO và không thực hiện
sắp xếp lại gói, gói có yêu cầu thời gian khởi chạy sẽ chặn các gói khác
các gói trong cùng hàng đợi Tx cho đến khi nó được gửi đi. Vì vậy, nó được khuyến khích
để phân bổ hàng đợi riêng biệt cho việc lập kế hoạch lưu lượng dành cho
truyền tải trong tương lai.

Trong trường hợp tính năng giảm tải thời gian khởi chạy bị tắt, thiết bị
người lái xe dự kiến sẽ bỏ qua yêu cầu về thời gian khởi động. Để đúng
giải thích và hoạt động có ý nghĩa, thời gian khởi động không bao giờ được
được đặt thành giá trị lớn hơn thời gian lập trình xa nhất trong tương lai
(đường chân trời). Các thiết bị khác nhau có những giới hạn phần cứng khác nhau trên
tính năng giảm tải thời gian khởi chạy.

trình điều khiển stmmac
-------------

Đối với stmmac, các tính năng TSO và thời gian khởi chạy (TBS) loại trừ lẫn nhau cho
mỗi hàng đợi Tx riêng lẻ. Theo mặc định, trình điều khiển cấu hình Tx Queue 0 thành
hỗ trợ TSO và phần còn lại của Hàng đợi Tx để hỗ trợ TBS. Thời gian ra mắt
tính năng giảm tải phần cứng có thể được bật hoặc tắt bằng cách sử dụng tc-etf
lệnh gọi lại lệnh gọi lại ndo_setup_tc() của trình điều khiển.

Giá trị của thời gian khởi chạy được lập trình trong Chế độ bình thường nâng cao
Bộ mô tả truyền là giá trị 32 bit, trong đó 8 bit quan trọng nhất
biểu thị thời gian tính bằng giây và 24 bit còn lại biểu thị thời gian
với bước tăng 256 ns. Thời gian khởi động được lập trình được so sánh với
Thời gian PTP (bit[39:8]) và quay vòng sau 256 giây. Vì vậy,
khoảng thời gian khởi chạy cho dwmac4 và dwxlgmac2 là 128 giây trong
tương lai.

trình điều khiển igc
----------

Đối với igc, cả bốn Hàng đợi Tx đều hỗ trợ tính năng thời gian khởi chạy. Sự ra mắt
tính năng giảm tải phần cứng theo thời gian có thể được bật hoặc tắt bằng cách sử dụng
lệnh tc-etf để gọi lại lệnh gọi lại ndo_setup_tc() của trình điều khiển. Khi vào
Ở chế độ TSN, driver igc sẽ reset máy và tạo Qbv mặc định
lên lịch với thời gian chu kỳ 1 giây, với tất cả Hàng đợi Tx luôn mở.

Giá trị của thời gian khởi chạy được lập trình trong Truyền nâng cao
Bộ mô tả bối cảnh là độ lệch tương đối với thời gian bắt đầu của Qbv
cửa sổ truyền tải của hàng đợi. Cờ đầu tiên của bộ mô tả có thể là
được thiết lập để lên lịch gói cho chu kỳ Qbv tiếp theo. Vì vậy, đường chân trời
của thời điểm ra mắt i225 và i226 là thời điểm kết thúc của chu kỳ tiếp theo
của cửa sổ truyền Qbv của hàng đợi. Ví dụ, khi Qbv
thời gian chu kỳ được đặt thành 1 giây, khoảng thời gian khởi chạy
từ 1 giây đến 2 giây, tùy thuộc vào vị trí hiện tại của chu kỳ Qbv
đang chạy.

Truy vấn khả năng của thiết bị
============================

Mọi thiết bị đều xuất khả năng giảm tải của mình thông qua dòng netlink netdev.
Tham khảo tính năng bitmask của ZZ0000ZZ trong
ZZ0001ZZ.

- ZZ0000ZZ: thiết bị hỗ trợ ZZ0001ZZ
- ZZ0002ZZ: thiết bị hỗ trợ ZZ0003ZZ
- ZZ0004ZZ: thiết bị hỗ trợ ZZ0005ZZ

Xem ZZ0000ZZ về cách truy vấn thông tin này.

Ví dụ
=======

Xem ZZ0000ZZ để biết ví dụ
chương trình xử lý siêu dữ liệu TX. Xem thêm ZZ0001ZZ
để có một ví dụ đơn giản hơn.