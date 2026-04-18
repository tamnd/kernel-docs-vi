.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/meta/fbnic.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================================
Giao diện mạng máy chủ nền tảng Meta
=====================================

Phiên bản phần sụn
-----------------

fbnic có ba thành phần được lưu trữ trên flash được cung cấp trong một PLDM
hình ảnh:

1. fw - Phần sụn điều khiển được sử dụng để xem và sửa đổi cài đặt phần sụn, yêu cầu
   hành động phần sụn và truy xuất bộ đếm phần sụn bên ngoài đường dẫn dữ liệu.
   Đây là phần sụn mà fbnic_fw.c tương tác.
2. bootloader - Phần sụn xác thực tính bảo mật và kiểm soát phần sụn cơ bản
   hoạt động bao gồm tải và cập nhật chương trình cơ sở. Điều này cũng được biết đến
   như phần mềm cmrt.
3. undi - Đây là trình điều khiển UEFI dựa trên trình điều khiển Linux.

fbnic lưu trữ hai bản sao của ba thành phần này trên flash. Điều này cho phép fbnic
để tự động quay lại phiên bản chương trình cơ sở cũ hơn trong trường hợp chương trình cơ sở
không khởi động được. Thông tin phiên bản cho cả hai đều được cung cấp dưới dạng đang chạy và được lưu trữ.
Undi chỉ được cung cấp trong kho lưu trữ vì nó không hoạt động tích cực khi Linux
tài xế đảm nhận.

thông tin nhà phát triển devlink cung cấp thông tin phiên bản cho cả ba thành phần. trong
Ngoài phiên bản, hàm băm cam kết hg của bản dựng được bao gồm dưới dạng
mục nhập riêng biệt.

Cấu hình
-------------

Thông số vòng (ethtool -g / -G)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

fbnic có hai vòng gửi (máy chủ -> thiết bị) cho mỗi lần hoàn thành
(thiết bị -> máy chủ) đổ chuông. Ba vật thể vòng cùng nhau tạo thành một
"hàng đợi" được sử dụng bởi phần mềm lớp cao hơn (hàng đợi Rx hoặc Tx).

Đối với Rx, hai vòng gửi được sử dụng để chuyển các trang trống tới NIC.
Vòng 0 là Hàng đợi Trang Tiêu đề (HPQ), NIC sẽ sử dụng các trang của nó để đặt
Tiêu đề L2-L4 (hoặc khung đầy đủ nếu khung không được phân chia dữ liệu tiêu đề).
Vòng 1 là Hàng đợi trang tải trọng (PPQ) và được sử dụng cho tải trọng gói.
Vòng hoàn thành được sử dụng để nhận thông báo/siêu dữ liệu gói.
ethtool ZZ0000ZZ ringparam ánh xạ tới kích thước của vòng hoàn thành,
ZZ0001ZZ đến HPQ và ZZ0002ZZ đến PPQ.

Đối với Tx, cả hai vòng gửi có thể được sử dụng để gửi gói, việc hoàn thành
chiếc nhẫn mang thông báo cho cả hai. fbnic sử dụng một trong những bài nộp
đổ chuông đối với lưu lượng truy cập thông thường từ ngăn xếp và vòng thứ hai dành cho khung XDP.
ethtool ZZ0000ZZ ringparam kiểm soát cả kích thước của các vòng gửi
và vòng hoàn thiện.

Mỗi mục nhập trên HPQ và PPQ (ZZ0000ZZ, ZZ0001ZZ)
tương ứng với 4kB bộ nhớ được phân bổ, trong khi các mục trên phần còn lại
các vòng được tính bằng đơn vị mô tả (8B). Tỷ lệ nộp hồ sơ lý tưởng
và kích thước vòng hoàn thành sẽ phụ thuộc vào khối lượng công việc, như đối với các gói nhỏ
nhiều gói sẽ phù hợp với một trang duy nhất.

Nâng cấp chương trình cơ sở
------------------

fbnic hỗ trợ cập nhật firmware bằng hình ảnh PLDM đã ký với nhà phát triển devlink
nhấp nháy. Hình ảnh PLDM được ghi vào flash. Nhấp nháy không làm gián đoạn
hoạt động của thiết bị.

Khi khởi động máy chủ, trình điều khiển UEFI mới nhất luôn được sử dụng, không có kích hoạt rõ ràng
được yêu cầu. Cần phải kích hoạt chương trình cơ sở để chạy chương trình cơ sở điều khiển mới. cmt
chương trình cơ sở chỉ có thể được kích hoạt bằng cách cấp nguồn cho NIC.

Phóng viên sức khỏe
----------------

phóng viên fw
~~~~~~~~~~~

Phóng viên sức khỏe ZZ0000ZZ theo dõi các sự cố FW. Việc bán phá giá phóng viên sẽ
hiển thị kết xuất cốt lõi của sự cố FW gần đây nhất và nếu không có sự cố FW nào xảy ra
xảy ra kể từ chu kỳ cấp nguồn - ảnh chụp nhanh của bộ nhớ FW. Chẩn đoán cuộc gọi lại
hiển thị thời gian hoạt động của FW dựa trên tin nhắn nhịp tim nhận được gần đây nhất
(sự cố được phát hiện bằng cách kiểm tra xem thời gian hoạt động có giảm không).

phóng viên otp
~~~~~~~~~~~~

Bộ nhớ OTP ("cầu chì") được sử dụng để khởi động an toàn và chống rollback
bảo vệ. Bộ nhớ OTP được bảo vệ ECC, lỗi ECC cho biết
lỗi sản xuất hoặc bộ phận bị hư hỏng theo thời gian.

Thống kê
----------

Giao diện TX MAC
~~~~~~~~~~~~~~~~

- ZZ0000ZZ: các gói được gửi đến NIC với tập bit yêu cầu PTP nhưng được định tuyến tới BMC/FW
 - ZZ0001ZZ: các gói được định tuyến thành công đến MAC với tập bit yêu cầu PTP
 - ZZ0002ZZ: các gói được gửi đến MAC với tập bit yêu cầu PTP nhưng bị hủy do một số lỗi (ví dụ: lỗi đọc DMA)

Giao diện mở rộng TX (TEI) (TTI)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- ZZ0000ZZ: thông báo điều khiển bị rớt tại Giao diện TX Extension (TEI) do thiếu tín dụng
 - ZZ0001ZZ: các gói bị rớt tại Giao diện TX Extension (TEI) do thiếu tín dụng
 - ZZ0002ZZ: các gói bị rớt tại Giao diện TX BMC (TBI) do thiếu tín dụng

Danh sách RXB (Bộ đệm RX)
~~~~~~~~~~~~~~~~~~~~~~~

- ZZ0000ZZ: các khung có lỗi toàn vẹn (ví dụ: lỗi ECC nhiều bit) trên đầu vào RXB i
 - ZZ0001ZZ: các khung có lỗi cuối khung MAC (ví dụ: FCS bị lỗi) trên đầu vào RXB i
 - ZZ0002ZZ: các khung gặp lỗi trình phân tích cú pháp RPC
 - ZZ0003ZZ: các khung gặp phải lỗi báo hiệu (ví dụ: thiếu phần cuối/gói bắt đầu) trên đầu vào RXB i
 - ZZ0004ZZ: các khung nhận được ở đầu vào RXB i
 - ZZ0005ZZ: byte nhận được ở đầu vào RXB i

RXB (Bộ đệm RX) FIFO
~~~~~~~~~~~~~~~~~~~~

- ZZ0000ZZ: chuyển sang trạng thái drop trên nhóm RXB i
 - ZZ0001ZZ: khung hình bị rớt trên nhóm RXB i
 - ZZ0002ZZ: chuyển sang trạng thái đánh dấu ECN trên nhóm RXB i
 - ZZ0003ZZ: công suất hiện tại của nhóm RXB i

Hàng đợi RXB (Bộ đệm RX)
~~~~~~~~~~~~~~~~~~~~~~~

- ZZ0000ZZ: các khung được gửi tới đầu ra i
   - ZZ0001ZZ: byte gửi tới đầu ra i
   - ZZ0002ZZ: các khung được gửi đến đầu ra i từ góc độ bộ đệm gói nội bộ
   - ZZ0003ZZ: byte được gửi đến đầu ra i từ góc độ bộ đệm gói bên trong

RPC (Trình phân tích cú pháp Rx)
~~~~~~~~~~~~~~~

- ZZ0000ZZ: các khung chứa EtherType không xác định
 - ZZ0001ZZ: các khung chứa tiêu đề mở rộng IPv6 không xác định
 - ZZ0002ZZ: các khung chứa đoạn IPv4
 - ZZ0003ZZ: các khung chứa đoạn IPv6
 - ZZ0004ZZ: các khung có đóng gói IPv4 ESP
 - ZZ0005ZZ: các khung có đóng gói IPv6 ESP
 - ZZ0006ZZ: các khung gặp lỗi phân tích tùy chọn TCP
 - ZZ0007ZZ: các khung có tiêu đề lớn hơn vùng có thể phân tích cú pháp
 - ZZ0008ZZ: gọng kính cỡ lớn

Hàng đợi phần cứng
~~~~~~~~~~~~~~~

1. Động cơ RX DMA:

- ZZ0000ZZ: các gói có lỗi cắt ngắn MAC EOP, RPC, cắt ngắn RXB hoặc lỗi cắt ngắn khung RDE. Các lỗi này được gắn cờ trong siêu dữ liệu gói vì hỗ trợ xuyên suốt nhưng sự sụt giảm thực tế xảy ra khi đạt đến PCIE/RDE.
 - ZZ0001ZZ: gói tin bị rớt do RCQ đã đầy
 - ZZ0002ZZ: gói tin bị rớt do HPQ hoặc PPQ hết bộ đệm máy chủ

PCIe
~~~~

Trình điều khiển fbnic hiển thị số liệu thống kê hiệu suất phần cứng PCIe thông qua debugfs
(ZZ0000ZZ). Những số liệu thống kê này cung cấp cái nhìn sâu sắc về giao dịch PCIe
hành vi và các tắc nghẽn hiệu suất tiềm năng.

1. Bộ đếm giao dịch PCIe:

Các bộ đếm này theo dõi hoạt động giao dịch PCIe:
        - ZZ0000ZZ: Số lượng gói lớp giao dịch đọc đi
        - ZZ0001ZZ: DWORD được chuyển trong các giao dịch đọc đi
        - ZZ0002ZZ: Số lượng gói lớp giao dịch ghi đi
        - ZZ0003ZZ: DWORD được chuyển khi ghi ra ngoài
	  giao dịch
        - ZZ0004ZZ: Số lần hoàn thành gửi đi TLP
        - ZZ0005ZZ: DWORD được chuyển trong TLP hoàn thành gửi đi

2. Giám sát tài nguyên PCIe:

Các bộ đếm này cho biết các sự kiện cạn kiệt tài nguyên PCIe:
        - ZZ0000ZZ: Yêu cầu đọc bị loại bỏ do không có thẻ
        - ZZ0001ZZ: Yêu cầu đọc bị loại bỏ do hoàn thành
	  cạn kiệt tín dụng
        - ZZ0002ZZ: Yêu cầu đọc bị rớt do chưa đăng
	  cạn kiệt tín dụng

Lỗi độ dài XDP:
~~~~~~~~~~~~~~~~~

Đối với các chương trình XDP không hỗ trợ frag, fbnic cố gắng đảm bảo rằng MTU phù hợp
vào một bộ đệm duy nhất. Nếu nhận được một khung quá khổ và bị phân mảnh,
nó bị loại bỏ và các bộ đếm liên kết mạng sau đây được cập nhật

- ZZ0000ZZ: số lượng khung hình bị rớt do thiếu phân mảnh
     hỗ trợ trong chương trình XDP đính kèm
   - ZZ0001ZZ: tổng số gói tin nhận được lỗi trên giao diện