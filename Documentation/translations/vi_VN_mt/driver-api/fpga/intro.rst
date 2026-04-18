.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/fpga/intro.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Giới thiệu
============

Hệ thống con FPGA hỗ trợ lập trình lại các GPU một cách linh hoạt theo
Linux.  Một số mục đích cốt lõi của hệ thống con FPGA là:

* Hệ thống con FPGA không phụ thuộc vào nhà cung cấp.

* Hệ thống con FPGA tách các lớp trên (giao diện không gian người dùng và
  liệt kê) từ các lớp thấp hơn biết cách lập trình cụ thể
  FPGA.

* Mã không nên được chia sẻ giữa các lớp trên và dưới.  Cái này
  nên đi mà không nói.  Nếu điều đó có vẻ cần thiết thì có lẽ
  chức năng khung có thể được thêm vào sẽ mang lại lợi ích
  người dùng khác.  Viết danh sách gửi thư linux-fpga và các nhà bảo trì và
  tìm kiếm giải pháp mở rộng khuôn khổ để tái sử dụng rộng rãi.

* Nói chung, khi thêm mã, hãy nghĩ đến tương lai.  Lập kế hoạch tái sử dụng.

Khung trong kernel được chia thành:

Người quản lý FPGA
------------

Nếu bạn đang thêm FPGA mới hoặc một phương pháp lập trình FPGA mới,
đây là hệ thống con dành cho bạn.  Trình điều khiển trình quản lý FPGA cấp thấp chứa
kiến thức về cách lập trình một thiết bị cụ thể.  Hệ thống con này
bao gồm khung trong fpga-mgr.c và các trình điều khiển cấp thấp
được đăng ký với nó.

Cầu FPGA
-----------

Cầu nối FPGA ngăn các tín hiệu giả đi ra khỏi FPGA hoặc
vùng của FPGA trong quá trình lập trình.  Họ bị vô hiệu hóa trước
chương trình bắt đầu và được kích hoạt lại sau đó.  Một cây cầu FPGA có thể
phần cứng cứng thực tế chuyển bus tới CPU hoặc phần mềm ("đóng băng")
cầu trong vải FPGA bao quanh vùng cấu hình lại một phần
của FPGA.  Hệ thống con này bao gồm fpga-bridge.c và cấp độ thấp
trình điều khiển đã được đăng ký với nó.

Vùng FPGA
-----------

Nếu bạn đang thêm giao diện mới vào khung FPGA, hãy thêm giao diện đó lên trên
của vùng FPGA.

Khung Khu vực FPGA (fpga-khu vực.c) liên kết các nhà quản lý và
bridge như các vùng có thể cấu hình lại.  Một khu vực có thể đề cập đến toàn bộ
FPGA ở trạng thái cấu hình lại toàn bộ hoặc vùng cấu hình lại một phần.

Bộ xử lý hỗ trợ Vùng FPGA của Cây thiết bị (of-fpga-khu vực.c)
lập trình lại các FPGA khi áp dụng lớp phủ cây thiết bị.
