.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/cellular/qualcomm/rmnet.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Trình điều khiển Rmnet
======================

1. Giới thiệu
===============

Trình điều khiển rmnet được sử dụng để hỗ trợ Ghép kênh và tổng hợp
Giao thức (MAP). Giao thức này được sử dụng bởi tất cả các chipset gần đây sử dụng Qualcomm
Các modem của Technologies, Inc.

Trình điều khiển này có thể được sử dụng để đăng ký vào bất kỳ thiết bị mạng vật lý nào trong
Chế độIP. Vận chuyển vật lý bao gồm USB, HSIC, bộ tăng tốc PCIe và IP.

Ghép kênh cho phép tạo ra các thiết bị mạng logic (thiết bị rmnet) để
xử lý nhiều mạng dữ liệu riêng tư (PDN) như internet mặc định, chia sẻ kết nối,
dịch vụ nhắn tin đa phương tiện (MMS) hoặc hệ thống con phương tiện IP (IMS). Phần cứng gửi
các gói có tiêu đề MAP tới rmnet. Dựa trên id bộ ghép kênh, rmnet
định tuyến đến PDN thích hợp sau khi xóa tiêu đề MAP.

Việc tổng hợp là cần thiết để đạt được tốc độ dữ liệu cao. Điều này liên quan đến phần cứng
gửi một loạt các khung MAP tổng hợp. trình điều khiển rmnet sẽ tổng hợp lại
các khung MAP này và gửi chúng đến các PDN thích hợp.

2. Định dạng gói
================

Một. Gói MAP v1 (dữ liệu / điều khiển)
---------------------------------

Các trường tiêu đề MAP có định dạng endian lớn.

Định dạng gói::

Bit 0 1 2-7 8-15 16-31
  Chức năng Lệnh / Dữ liệu dành riêng Pad Bộ ghép kênh ID Chiều dài tải trọng

Bit 32-x
  Chức năng byte thô

Giá trị bit Lệnh (1)/Dữ liệu (0) là để cho biết gói có phải là lệnh MAP hay không
hoặc gói dữ liệu. Gói lệnh được sử dụng để điều khiển luồng mức vận chuyển. dữ liệu
các gói là các gói IP tiêu chuẩn.

Các bit dành riêng phải bằng 0 khi gửi và bỏ qua khi nhận.

Phần đệm là số byte được thêm vào tải trọng để
đảm bảo căn chỉnh 4 byte.

ID bộ ghép kênh dùng để chỉ ra PDN dữ liệu nào phải được gửi.

Độ dài tải trọng bao gồm chiều dài phần đệm nhưng không bao gồm tiêu đề MAP
chiều dài.

b. Gói bản đồ v4 (dữ liệu/điều khiển)
---------------------------------

Các trường tiêu đề MAP có định dạng endian lớn.

Định dạng gói::

Bit 0 1 2-7 8-15 16-31
  Chức năng Lệnh / Dữ liệu dành riêng Pad Bộ ghép kênh ID Chiều dài tải trọng

Bit 32-(x-33) (x-32)-x
  Chức năng Tiêu đề giảm tải byte thô Kiểm tra tổng

Giá trị bit Lệnh (1)/Dữ liệu (0) là để cho biết gói có phải là lệnh MAP hay không
hoặc gói dữ liệu. Gói lệnh được sử dụng để điều khiển luồng mức vận chuyển. dữ liệu
các gói là các gói IP tiêu chuẩn.

Các bit dành riêng phải bằng 0 khi gửi và bỏ qua khi nhận.

Phần đệm là số byte được thêm vào tải trọng để
đảm bảo căn chỉnh 4 byte.

ID bộ ghép kênh dùng để chỉ ra PDN dữ liệu nào phải được gửi.

Độ dài tải trọng bao gồm chiều dài phần đệm nhưng không bao gồm tiêu đề MAP
chiều dài.

Tiêu đề giảm tải tổng kiểm tra, có thông tin về quá trình xử lý tổng kiểm tra được thực hiện
bởi các trường tiêu đề giảm tải phần cứng.Checksum có định dạng endian lớn.

Định dạng gói::

Bit 0-14 15 16-31
  Hàm dành riêng Giá trị bù bắt đầu tổng kiểm tra hợp lệ

Bit 31-47 48-64
  Hàm Độ dài tổng kiểm tra Giá trị tổng kiểm tra

Các bit dành riêng phải bằng 0 khi gửi và bỏ qua khi nhận.

Bit hợp lệ cho biết liệu tổng kiểm tra một phần có được tính toán và hợp lệ hay không.
Đặt thành 1, nếu nó hợp lệ. Đặt thành 0 nếu không.

Phần đệm là số byte được thêm vào tải trọng để
đảm bảo căn chỉnh 4 byte.

Độ lệch bắt đầu tổng kiểm tra, Cho biết độ lệch tính bằng byte tính từ đầu của
Tiêu đề IP, từ đó modem tính tổng kiểm tra.

Độ dài tổng kiểm tra là Độ dài tính bằng byte bắt đầu từ CKSUM_START_OFFSET,
qua đó tổng kiểm tra được tính toán.

Giá trị tổng kiểm tra, cho biết tổng kiểm tra được tính toán.

c. Gói MAP v5 (dữ liệu / điều khiển)
---------------------------------

Các trường tiêu đề MAP có định dạng endian lớn.

Định dạng gói::

Bit 0 1 2-7 8-15 16-31
  Chức năng Lệnh / Dữ liệu Tiêu đề tiếp theo Pad Bộ ghép kênh ID Chiều dài tải trọng

Bit 32-x
  Chức năng byte thô

Giá trị bit Lệnh (1)/Dữ liệu (0) là để cho biết gói có phải là lệnh MAP hay không
hoặc gói dữ liệu. Gói lệnh được sử dụng để điều khiển luồng mức vận chuyển. dữ liệu
các gói là các gói IP tiêu chuẩn.

Tiêu đề tiếp theo được sử dụng để cho biết sự hiện diện của tiêu đề khác, hiện tại là
giới hạn ở tiêu đề tổng kiểm tra.

Phần đệm là số byte được thêm vào tải trọng để
đảm bảo căn chỉnh 4 byte.

ID bộ ghép kênh dùng để chỉ ra PDN dữ liệu nào phải được gửi.

Độ dài tải trọng bao gồm chiều dài phần đệm nhưng không bao gồm tiêu đề MAP
chiều dài.

d. Tiêu đề giảm tải tổng kiểm tra v5
-----------------------------

Các trường tiêu đề giảm tải tổng kiểm tra có định dạng endian lớn.

Định dạng gói::

Bit 0 - 6 7 8-15 16-31
  Chức năng Loại tiêu đề Tiếp theo Tổng kiểm tra tiêu đề hợp lệ Đã đặt trước

Loại tiêu đề là để chỉ ra loại tiêu đề, loại tiêu đề này thường được đặt thành CHECKSUM

Các loại tiêu đề

= =================
0 Đã đặt trước
1 Đã đặt trước
2 tiêu đề tổng kiểm tra
= =================

Tổng kiểm tra hợp lệ là để cho biết liệu tổng kiểm tra tiêu đề có hợp lệ hay không. Giá trị của 1
ngụ ý rằng tổng kiểm tra được tính trên gói này và hợp lệ, giá trị là 0
chỉ ra rằng tổng kiểm tra gói được tính toán là không hợp lệ.

Các bit dành riêng phải bằng 0 khi gửi và bỏ qua khi nhận.

đ. Gói MAP v1/v5 (lệnh cụ thể)
--------------------------------------

Định dạng gói::

Bit 0 1 2-7 8 - 15 16 - 31
    Chức năng Lệnh dành riêng Bộ ghép kênh ID Độ dài tải trọng
    Bit 32 - 39 40 - 45 46 - 47 48 - 63
    Chức năng Tên lệnh Dự trữ Loại lệnh Dự trữ
    Bit 64 - 95
    ID giao dịch chức năng
    Bit 96 - 127
    Dữ liệu lệnh chức năng

Lệnh 1 biểu thị việc vô hiệu hóa luồng trong khi lệnh 2 đang kích hoạt luồng

Các loại lệnh

= ==============================================
0 cho yêu cầu lệnh MAP
1 là xác nhận việc nhận lệnh
2 là dành cho các lệnh không được hỗ trợ
3 là lỗi trong quá trình xử lý lệnh
= ==============================================

f. Tổng hợp
--------------

Tập hợp là nhiều gói MAP (có thể là dữ liệu hoặc lệnh) được gửi tới
rmnet trong một skb tuyến tính duy nhất. rmnet sẽ xử lý cá nhân
các gói và lệnh ACK MAP hoặc gửi gói IP đến
ngăn xếp mạng khi cần thiết

Định dạng gói::

Tiêu đề MAP|IP Packet|Phần đệm tùy chọn|MAP header|IP Gói|Phần đệm tùy chọn....

Tiêu đề MAP|IP Packet|Phần đệm tùy chọn|MAP header|Gói lệnh|Phần đệm tùy chọn...

3. Cấu hình không gian người dùng
==========================

Cấu hình không gian người dùng rmnet được thực hiện thông qua netlink bằng iproute2
ZZ0000ZZ

Trình điều khiển sử dụng rtnl_link_ops để liên lạc.