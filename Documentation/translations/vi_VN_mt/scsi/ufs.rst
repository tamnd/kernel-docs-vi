.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/ufs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========================
Bộ nhớ flash phổ dụng
=======================


.. Contents

   1. Overview
   2. UFS Architecture Overview
     2.1 Application Layer
     2.2 UFS Transport Protocol (UTP) layer
     2.3 UFS Interconnect (UIC) Layer
   3. UFSHCD Overview
     3.1 UFS controller initialization
     3.2 UTP Transfer requests
     3.3 UFS error handling
     3.4 SCSI Error handling
   4. BSG Support
   5. UFS Reference Clock Frequency configuration


1. Tổng quan
===========

Universal Flash Storage (UFS) là thông số lưu trữ dành cho thiết bị flash.
Nó nhằm mục đích cung cấp một giao diện lưu trữ phổ quát cho cả
lưu trữ dựa trên bộ nhớ flash nhúng và di động trong thiết bị di động
các thiết bị như điện thoại thông minh và máy tính bảng. đặc điểm kỹ thuật
được xác định bởi Hiệp hội Công nghệ Nhà nước Rắn JEDEC. UFS dựa trên
trên tiêu chuẩn lớp vật lý MIPI M-PHY. UFS sử dụng MIPI M-PHY làm
lớp vật lý và MIPI Unipro làm lớp liên kết.

Mục tiêu chính của UFS là cung cấp:

* Tối ưu hóa hiệu suất:

Đối với UFS phiên bản 1.0 và 1.1, hiệu suất mục tiêu như sau:

- Hỗ trợ Gear1 là bắt buộc (tốc độ A: 1248Mbps, tốc độ B: 1457,6Mbps)
   - Hỗ trợ cho Gear2 là tùy chọn (tốc độ A: 2496Mbps, tốc độ B: 2915.2Mbps)

Phiên bản tương lai của tiêu chuẩn,

- Gear3 (tốc độ A: 4992Mbps, tốc độ B: 5830,4Mbps)

* Tiêu thụ điện năng thấp
 * IOP ngẫu nhiên cao và độ trễ thấp


2. Tổng quan về kiến ​​trúc UFS
============================

UFS có kiến trúc truyền thông phân lớp dựa trên SCSI
Mô hình kiến trúc SAM-5.

Kiến trúc truyền thông UFS bao gồm các lớp sau.

2.1 Lớp ứng dụng
---------------------

Lớp Ứng dụng bao gồm lớp tập lệnh UFS (UCS),
  Trình quản lý tác vụ và Trình quản lý thiết bị. Giao diện UFS được thiết kế để
  giao thức bất khả tri, tuy nhiên SCSI đã được chọn làm đường cơ sở
  giao thức cho phiên bản 1.0 và 1.1 của lớp giao thức UFS.

UFS hỗ trợ một tập hợp con các lệnh SCSI được xác định bởi SPC-4 và SBC-3.

*UCS:
     Nó xử lý các lệnh SCSI được hỗ trợ bởi đặc tả UFS.
  * Trình quản lý tác vụ:
     Nó xử lý các chức năng quản lý tác vụ được xác định bởi
     UFS dùng để kiểm soát hàng đợi lệnh.
  * Trình quản lý thiết bị:
     Nó xử lý các hoạt động ở cấp độ thiết bị và
     các thao tác cấu hình. Hoạt động ở cấp độ thiết bị chủ yếu liên quan đến
     các hoạt động và lệnh quản lý nguồn điện của thiết bị để kết nối
     các lớp. Cấu hình cấp thiết bị liên quan đến việc xử lý truy vấn
     các yêu cầu được sử dụng để sửa đổi và truy xuất cấu hình
     thông tin của thiết bị.

2.2 Lớp giao thức truyền tải UFS (UTP)
--------------------------------------

Lớp UTP cung cấp các dịch vụ cho
  các lớp cao hơn thông qua Điểm truy cập dịch vụ. UTP định nghĩa 3
  điểm truy cập dịch vụ cho các lớp cao hơn.

* UDM_SAP: Điểm truy cập dịch vụ quản lý thiết bị được hiển thị cho thiết bị
    người quản lý các hoạt động cấp thiết bị. Các hoạt động cấp thiết bị này
    được thực hiện thông qua các yêu cầu truy vấn.
  * UTP_CMD_SAP: Điểm truy cập dịch vụ lệnh được hiển thị lệnh UFS
    đặt lớp (UCS) để truyền lệnh.
  * UTP_TM_SAP: Điểm truy cập dịch vụ quản lý tác vụ được tiếp xúc với tác vụ
    người quản lý để vận chuyển các chức năng quản lý tác vụ.

UTP truyền tin nhắn thông qua đơn vị thông tin giao thức UFS (UPIU).

2.3 Lớp kết nối UFS (UIC)
--------------------------------

UIC là lớp thấp nhất của kiến ​​trúc phân lớp UFS. Nó xử lý
  kết nối giữa máy chủ UFS và thiết bị UFS. UIC bao gồm
  MIPI UniPro và MIPI M-PHY. UIC cung cấp 2 điểm truy cập dịch vụ
  đến lớp trên:

* UIC_SAP: Để vận chuyển UPIU giữa máy chủ UFS và thiết bị UFS.
  * UIO_SAP: Để ra lệnh cho các lớp Unipro.


3. Tổng quan về UFSHCD
==================

Trình điều khiển bộ điều khiển máy chủ UFS dựa trên Linux SCSI Framework.
UFSHCD là trình điều khiển thiết bị cấp thấp hoạt động như một giao diện giữa
bộ điều khiển máy chủ UFS lớp giữa và UFS dựa trên PCIe.

Việc triển khai UFSHCD hiện tại hỗ trợ các chức năng sau:

3.1 Khởi tạo bộ điều khiển UFS
---------------------------------

Mô-đun khởi tạo đưa bộ điều khiển máy chủ UFS về trạng thái hoạt động
  và chuẩn bị cho bộ điều khiển chuyển lệnh/phản hồi giữa
  Thiết bị UFSHCD và UFS.

3.2 Yêu cầu chuyển UTP
-------------------------

Mô-đun xử lý yêu cầu truyền của UFSHCD nhận lệnh SCSI
  từ Lớp giữa SCSI, hình thành UPIU và cấp UPIU cho Máy chủ UFS
  bộ điều khiển. Ngoài ra, mô-đun giải mã các phản hồi nhận được từ UFS
  bộ điều khiển máy chủ ở dạng UPIU và liên kết với Lớp trung gian SCSI
  về trạng thái của lệnh.

3.3 Xử lý lỗi UFS
----------------------

Mô-đun xử lý lỗi xử lý lỗi nghiêm trọng của Bộ điều khiển máy chủ,
  Lỗi nghiêm trọng của thiết bị và lỗi liên quan đến lớp kết nối UIC.

3.4 SCSI Xử lý lỗi
-----------------------

Điều này được thực hiện thông qua các thói quen xử lý lỗi UFSHCD SCSI đã đăng ký
  với Lớp giữa SCSI. Ví dụ về một số lệnh xử lý lỗi
  các vấn đề của Lớp giữa SCSI là tác vụ Hủy bỏ, đặt lại LUN và đặt lại máy chủ.
  UFSHCD Các thói quen thực hiện các tác vụ này đã được đăng ký với
  SCSI Lớp giữa đến .eh_abort_handler, .eh_device_reset_handler và
  .eh_host_reset_handler.

Trong phiên bản UFSHCD này, Yêu cầu truy vấn và quản lý nguồn
chức năng không được thực hiện.

4. Hỗ trợ BSG
==============

Trình điều khiển vận chuyển này hỗ trợ trao đổi các đơn vị thông tin giao thức UFS
(UPIU) với thiết bị UFS. Thông thường, không gian người dùng sẽ phân bổ
struct ufs_bsg_request và struct ufs_bsg_reply (xem ufs_bsg.h) dưới dạng
request_upiu và reply_upiu tương ứng.  Việc điền vào các UPIU đó sẽ
được thực hiện theo thông số JEDEC UFS2.1 đoạn 10.7.
ZZ0000ZZ: Trình điều khiển không thực hiện xác nhận đầu vào nào nữa và gửi
UPIU vào thiết bị như hiện tại.  Mở thiết bị bsg trong/dev/ufs-bsg và
gửi SG_IO với sg_io_v4 thích hợp::

io_hdr_v4.guard = 'Q';
	io_hdr_v4.protocol = BSG_PROTOCOL_SCSI;
	io_hdr_v4.subprotocol = BSG_SUB_PROTOCOL_SCSI_TRANSPORT;
	io_hdr_v4.response = (__u64)reply_upiu;
	io_hdr_v4.max_response_len = reply_len;
	io_hdr_v4.request_len = request_len;
	io_hdr_v4.request = (__u64)request_upiu;
	nếu (dir == SG_DXFER_TO_DEV) {
		io_hdr_v4.dout_xfer_len = (uint32_t)byte_cnt;
		io_hdr_v4.dout_xferp = (uintptr_t)(__u64)buff;
	} khác {
		io_hdr_v4.din_xfer_len = (uint32_t)byte_cnt;
		io_hdr_v4.din_xferp = (uintptr_t)(__u64)buff;
	}

Nếu bạn muốn đọc hoặc viết một bộ mô tả, hãy sử dụng xferp thích hợp của
sg_io_v4.

Công cụ không gian người dùng tương tác với điểm cuối ufs-bsg và sử dụng nó
Giao thức dựa trên UPIU có sẵn tại:

ZZ0000ZZ

Để biết thêm thông tin chi tiết về công cụ và hỗ trợ của nó
các tính năng, vui lòng xem README của công cụ.

Thông số kỹ thuật của UFS có thể được tìm thấy tại:

- UFS - ZZ0000ZZ
- UFSHCI - ZZ0001ZZ

5. Cấu hình tần số đồng hồ tham chiếu UFS
==============================================

Devicetree có thể định nghĩa đồng hồ có tên "ref_clk" trong nút điều khiển UFS
để chỉ định tần số xung nhịp tham chiếu dự định cho bộ lưu trữ UFS
các bộ phận. Hệ thống dựa trên ACPI có thể chỉ định tần số bằng ACPI
Thuộc tính Dữ liệu dành riêng cho thiết bị có tên là "ref-clk-freq". Theo cả hai cách, giá trị
được hiểu là tần số tính bằng Hz và phải khớp với một trong các giá trị được đưa ra trong
đặc điểm kỹ thuật UFS. Hệ thống con UFS sẽ cố gắng đọc giá trị khi
thực hiện khởi tạo bộ điều khiển chung. Nếu giá trị có sẵn, UFS
hệ thống con sẽ đảm bảo thuộc tính bRefClkFreq của thiết bị lưu trữ UFS là
thiết lập cho phù hợp và sẽ sửa đổi nó nếu có sự không phù hợp.