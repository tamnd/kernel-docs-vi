.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/cxgb3i.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================
Trình điều khiển iSCSI Chelsio S3 cho Linux
=================================

Giới thiệu
============

Bộ điều hợp dựa trên Chelsio T3 ASIC (S310, S320, S302, S304, thẻ Mezz, v.v.
loạt sản phẩm) hỗ trợ tăng tốc iSCSI và đặt dữ liệu trực tiếp iSCSI
(DDP) trong đó phần cứng xử lý các hoạt động chạm byte tốn kém, chẳng hạn như
dưới dạng tính toán và xác minh CRC và chuyển DMA tới bộ nhớ máy chủ cuối cùng
điểm đến:

- Tạo và xác minh thông báo iSCSI PDU

Khi truyền, Chelsio S3 h/w tính toán và chèn Tiêu đề và
	  Phân loại dữ liệu vào PDU.
	  Khi nhận được, Chelsio S3 h/w tính toán và xác minh Tiêu đề và
	  Tóm tắt dữ liệu của PDU.

- Vị trí dữ liệu trực tiếp (DDP)

S3 h/w có thể đặt trực tiếp iSCSI Data-In hoặc Data-Out PDU
	  tải trọng vào bộ đệm bộ nhớ máy chủ đích cuối cùng được đăng trước dựa trên
	  trên Thẻ tác vụ khởi tạo (ITT) trong Thẻ tác vụ nhập dữ liệu hoặc mục tiêu (TTT)
	  trong PDU dữ liệu ra.

- Truyền và phục hồi PDU

Khi truyền, S3 h/w chấp nhận PDU hoàn chỉnh (tiêu đề + dữ liệu)
	  từ trình điều khiển máy chủ, tính toán và chèn các bản tóm tắt, phân tách
	  PDU thành nhiều phân đoạn TCP nếu cần thiết và truyền tất cả
	  các đoạn TCP lên dây. Nó xử lý việc truyền lại TCP nếu
	  cần thiết.

Khi nhận được, S3 h/w khôi phục iSCSI PDU bằng cách lắp ráp lại TCP
	  phân đoạn, tách tiêu đề và dữ liệu, tính toán và xác minh
	  các bản tóm tắt, sau đó chuyển tiếp tiêu đề đến máy chủ. Dữ liệu tải trọng,
	  nếu có thể sẽ được đặt trực tiếp vào máy chủ đăng trước DDP
	  bộ đệm. Nếu không, dữ liệu tải trọng cũng sẽ được gửi đến máy chủ.

Trình điều khiển cxgb3i giao tiếp với bộ khởi tạo open-iscsi và cung cấp iSCSI
tăng tốc thông qua phần cứng Chelsio bất cứ khi nào có thể.

Sử dụng Trình điều khiển cxgb3i
=======================

Cần thực hiện các bước sau để tăng tốc trình khởi tạo open-iscsi:

1. Tải driver cxgb3i: "modprobe cxgb3i"

Mô-đun cxgb3i đăng ký lớp vận chuyển mới "cxgb3i" với open-iscsi.

* trong trường hợp biên dịch lại kernel, vùng chọn cxgb3i nằm ở::

Trình điều khiển thiết bị
		Hỗ trợ thiết bị SCSI --->
			[*] Trình điều khiển cấp thấp SCSI --->
				<M> Hỗ trợ Chelsio S3xx iSCSI

2. Tạo một tệp giao diện nằm trong /etc/iscsi/ifaces/ cho phiên bản mới
   lớp vận chuyển "cxgb3i".

Nội dung của tệp phải ở định dạng sau::

iface.transport_name = cxgb3i
	iface.net_ifacename = <ethX>
	iface.ipaddress = <địa chỉ IP iscsi>

* nếu iface.ipaddress được chỉ định, <iscsi ip address> cần phải là
     giống với địa chỉ IP của ethX hoặc một địa chỉ trên cùng một mạng con. làm
     chắc chắn địa chỉ IP là duy nhất trong mạng.

3. chỉnh sửa /etc/iscsi/iscsid.conf
   Cài đặt mặc định cho MaxRecvDataSegmentLength (131072) quá lớn;
   thay thế bằng giá trị không lớn hơn 15360 (ví dụ 8192)::

node.conn[0].iscsi.MaxRecvDataSegmentLength = 8192

* Đăng nhập sẽ không thành công trong phiên bình thường nếu MaxRecvDataSegmentLength là
     quá lớn.  Một thông báo lỗi ở định dạng
     "cxgb3i: ERR! MaxRecvSegmentLength <X> quá lớn. Cần phải <= <Y>."
     sẽ được ghi vào dmesg.

4. Để hướng lưu lượng truy cập open-iscsi đi qua đường dẫn tăng tốc của cxgb3i,
   Tùy chọn "-I <iface file name>" cần được chỉ định với hầu hết các
   lệnh iscsiadm. <tên tệp iface> là tệp giao diện truyền tải được tạo
   ở bước 2.