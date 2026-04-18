.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/google/gve.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===================================================================
Trình điều khiển hạt nhân Linux cho Computing Engine Virtual Ethernet (gve):
==============================================================

Phần cứng được hỗ trợ
===================
Trình điều khiển GVE liên kết với một id thiết bị PCI duy nhất được sử dụng bởi máy ảo
Thiết bị Ethernet được tìm thấy trong một số máy ảo Công cụ tính toán.

+--------------+----------+----------+
ZZ0006ZZ Giá trị ZZ0007ZZ
+=========================================+
ZZ0008ZZ ZZ0000ZZ ZZ0009ZZ
+--------------+----------+----------+
ZZ0010ZZ ZZ0001ZZ ZZ0011ZZ
+--------------+----------+----------+
ZZ0012ZZ ZZ0002ZZ ZZ0013ZZ
+--------------+----------+----------+
ZZ0014ZZ ZZ0003ZZ ZZ0015ZZ
+--------------+----------+----------+
ZZ0016ZZ ZZ0004ZZ ZZ0017ZZ
+--------------+----------+----------+
ZZ0018ZZ ZZ0005ZZ ZZ0019ZZ
+--------------+----------+----------+

Thanh PCI
========
Thiết bị gVNIC PCI hiển thị ba bộ nhớ 32-bit BARS:
- Bar0 - Thanh ghi trạng thái và cấu hình thiết bị.
- Bảng vectơ Bar1 - MSI-X
- Chuông cửa Bar2 - IRQ, RX và TX

Tương tác thiết bị
===================
Trình điều khiển tương tác với thiết bị theo các cách sau:
 - Sổ đăng ký
    - Một khối thanh ghi MMIO
    - Xem gve_register.h để biết thêm chi tiết
 - Hàng đợi quản trị
    - Xem mô tả bên dưới
 - Đặt lại
    - Bất cứ lúc nào thiết bị có thể được thiết lập lại
 - Ngắt
    - Xem các ngắt được hỗ trợ bên dưới
 - Hàng đợi truyền và nhận
    - Xem mô tả bên dưới

Định dạng mô tả
------------------
GVE hỗ trợ hai định dạng mô tả: GQI và DQO. Hai định dạng này có
mô tả hoàn toàn khác nhau, sẽ được mô tả dưới đây.

Chế độ địa chỉ
------------------
GVE hỗ trợ hai chế độ địa chỉ: QPL và RDA.
Chế độ QPL ("danh sách trang hàng đợi") truyền dữ liệu thông qua một tập hợp
các trang đã đăng ký trước.

Đối với chế độ RDA ("địa chỉ DMA thô"), tập hợp các trang là động.
Do đó, bộ đệm gói có thể ở bất kỳ đâu trong bộ nhớ khách.

Đăng ký
---------
Tất cả các thanh ghi là MMIO.

Các thanh ghi được sử dụng để khởi tạo và cấu hình thiết bị cũng như
truy vấn trạng thái thiết bị để đáp ứng với các ngắt quản lý.

Độ bền
----------
- Các tin nhắn và sổ đăng ký trong Hàng đợi Quản trị đều là Big Endian.
- Bộ mô tả GQI và thanh ghi đường dẫn dữ liệu là Big Endian.
- Bộ mô tả DQO và thanh ghi đường dẫn dữ liệu là Little Endian.

Hàng đợi quản trị (AQ)
----------------
Hàng đợi quản trị là khối bộ nhớ PAGE_SIZE, được coi là một mảng AQ
các lệnh, được trình điều khiển sử dụng để ra lệnh cho thiết bị và thiết lập
tài nguyên. Trình điều khiển và thiết bị duy trì số lượng lệnh
đã được đệ trình và thực hiện. Để ra lệnh AQ, người lái xe phải thực hiện
sau đây (với khóa thích hợp):

1) Sao chép các lệnh mới vào các vị trí có sẵn tiếp theo trong mảng AQ
2) Tăng bộ đếm của nó bằng số lệnh mới
3) Ghi bộ đếm vào thanh ghi GVE_ADMIN_QUEUE_DOORBELL
4) Thăm dò thanh ghi ADMIN_QUEUE_EVENT_COUNTER cho đến khi nó bằng
    giá trị được ghi vào chuông cửa hoặc cho đến khi hết thời gian chờ.

Thiết bị sẽ cập nhật trường trạng thái trong mỗi lệnh AQ được báo cáo là
được thực thi thông qua thanh ghi ADMIN_QUEUE_EVENT_COUNTER.

Đặt lại thiết bị
-------------
Thiết lập lại thiết bị được kích hoạt bằng cách ghi 0x0 vào thanh ghi AQ PFN.
Điều này khiến thiết bị giải phóng tất cả tài nguyên được phân bổ bởi
trình điều khiển, bao gồm cả AQ.

Ngắt
----------
Các ngắt sau được hỗ trợ bởi trình điều khiển:

Ngắt quản lý
~~~~~~~~~~~~~~~~~~~~
Thiết bị sử dụng ngắt quản lý để báo cho người lái xe biết
nhìn vào sổ đăng ký GVE_DEVICE_STATUS.

Trình xử lý cho irq quản lý chỉ cần xếp hàng nhiệm vụ dịch vụ vào
hàng đợi công việc để kiểm tra sổ đăng ký và xác nhận irq.

Khối thông báo ngắt
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Các ngắt khối thông báo được sử dụng để báo cho người lái xe thăm dò ý kiến
hàng đợi liên quan đến ngắt đó.

Trình xử lý các irq này lên lịch napi cho khối đó chạy
và thăm dò các hàng đợi.

Hàng đợi giao thông GQI
------------------
Hàng đợi GQI bao gồm một vòng mô tả và một bộ đệm và được gán cho một
khối thông báo.

Các vòng mô tả là bộ đệm vòng lũy thừa hai kích thước bao gồm
mô tả có kích thước cố định. Họ nâng cao con trỏ theo đầu bằng cách sử dụng __be32
chuông cửa nằm ở Bar2. Các con trỏ đuôi được nâng cao bằng cách tiêu thụ
mô tả theo thứ tự và cập nhật bộ đếm __be32. Cả chuông cửa
và bộ đếm tràn về 0.

Bộ đệm của mỗi hàng đợi phải được đăng ký trước với thiết bị dưới dạng
danh sách trang xếp hàng và dữ liệu gói chỉ có thể được đưa vào các trang đó.

truyền
~~~~~~~~
gve ánh xạ các bộ đệm để truyền các vòng vào FIFO và sao chép các gói
vào FIFO trước khi gửi chúng tới NIC.

Nhận được
~~~~~~~
Bộ đệm cho các vòng nhận được đặt vào một vòng dữ liệu giống nhau
chiều dài khi vòng mô tả và con trỏ đầu và đuôi tiến lên
những chiếc nhẫn với nhau.

Hàng đợi giao thông DQO
------------------
- Mỗi hàng đợi TX và RX được gán một khối thông báo.

- Hàng đợi bộ đệm TX và RX gửi mô tả đến thiết bị, sử dụng MMIO
  chuông cửa để thông báo cho thiết bị về bộ mô tả mới.

- Hàng đợi hoàn thành RX và TX, nhận các bộ mô tả từ thiết bị, sử dụng
  "thế hệ bit" để biết khi nào bộ mô tả được thiết bị điền vào. các
  trình điều khiển khởi tạo tất cả các bit bằng "thế hệ hiện tại". Thiết bị sẽ
  điền các mô tả nhận được với "thế hệ tiếp theo" được đảo ngược
  từ thế hệ hiện tại. Khi chiếc nhẫn quấn lại, thế hệ hiện tại/tiếp theo
  được hoán đổi.

- Trách nhiệm của người lái xe là đảm bảo hoàn thành RX và TX
  hàng đợi không bị tràn. Điều này có thể được thực hiện bằng cách hạn chế số lượng
  mô tả được đăng lên HW.

- Gói TX có thẻ hoàn thành 16 bit và bộ đệm RX có 16 bit
  đệm_id. Những thứ này sẽ được trả về khi hoàn thành TX và hàng đợi RX
  tương ứng để cho trình điều khiển biết gói/bộ đệm nào đã được hoàn thành.

truyền
~~~~~~~~
Bộ đệm của gói được ánh xạ DMA để thiết bị truy cập trước khi truyền.
Sau khi gói được truyền thành công, bộ đệm sẽ không được ánh xạ.

Nhận được
~~~~~~~
Trình điều khiển đăng các bộ đệm có kích thước cố định vào CTNH trên hàng đợi bộ đệm RX. Gói
nhận được trên hàng đợi RX liên quan có thể trải rộng trên nhiều bộ mô tả.