.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/ubifs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================
Hệ thống tập tin UBI
====================

Giới thiệu
============

Hệ thống tệp UBIFS là viết tắt của Hệ thống tệp UBI. UBI là viết tắt của "Chưa sắp xếp
Chặn hình ảnh". UBIFS là một hệ thống tập tin flash, có nghĩa là nó được thiết kế
để làm việc với các thiết bị flash. Điều quan trọng cần hiểu là UBIFS
hoàn toàn khác với bất kỳ hệ thống tệp truyền thống nào trong Linux, như
Ext2, XFS, JFS, v.v. UBIFS đại diện cho một lớp hệ thống tệp riêng biệt
hoạt động với các thiết bị MTD, không chặn các thiết bị. Linux khác
hệ thống tập tin của lớp này là JFFS2.

Để rõ ràng hơn, đây là một so sánh nhỏ về các thiết bị MTD và
chặn các thiết bị.

1 Các thiết bị MTD đại diện cho các thiết bị flash và chúng bao gồm các khối xóa của
  kích thước khá lớn, thường khoảng 128KiB. Thiết bị khối bao gồm
  khối nhỏ, thường là 512 byte.
2 thiết bị MTD hỗ trợ 3 thao tác chính - đọc từ một số offset trong một
  khối xóa, ghi vào phần bù nào đó trong khối xóa và xóa toàn bộ
  deleteblock. Chặn thiết bị hỗ trợ 2 thao tác chính - đọc toàn bộ
  chặn và viết cả một khối.
3 Toàn bộ khối xóa phải được xóa trước khi có thể
  viết lại nội dung của nó. Các khối có thể được viết lại.
4 Khối xóa bị mòn sau một số chu kỳ xóa -
  thường là 100K-1G cho đèn flash SLC NAND và NOR và 1K-10K cho MLC
  NAND nhấp nháy. Các khối không có đặc tính hao mòn.
5 Khối xóa có thể trở nên hỏng (chỉ trên đèn flash NAND) và phần mềm sẽ
  đối phó với điều này Việc chặn trên ổ cứng thường không trở nên xấu,
  bởi vì phần cứng có cơ chế thay thế các khối xấu, ít nhất là trong
  đĩa LBA hiện đại.

Khá rõ ràng tại sao UBIFS lại rất khác so với truyền thống
hệ thống tập tin.

UBIFS hoạt động trên UBI. UBI là một lớp phần mềm riêng biệt có thể
được tìm thấy trong trình điều khiển/mtd/ubi. UBI về cơ bản là một công cụ quản lý âm lượng và
lớp san lấp mặt bằng. Nó cung cấp cái gọi là khối lượng UBI cao hơn
mức độ trừu tượng hơn thiết bị MTD. Mô hình lập trình của thiết bị UBI
rất giống với các thiết bị MTD - chúng vẫn bao gồm các khối xóa lớn,
chúng có các thao tác đọc/ghi/xóa, nhưng các thiết bị UBI không có
những hạn chế như hao mòn và khối xấu (mục 4 và 5 trong danh sách trên).

Theo một nghĩa nào đó, UBIFS là thế hệ tiếp theo của hệ thống tệp JFFS2, nhưng nó là
rất khác và không tương thích với JFFS2. Sau đây là những nội dung chính
sự khác biệt.

* JFFS2 hoạt động trên các thiết bị MTD, UBIFS phụ thuộc vào UBI và hoạt động trên
  đầu các tập UBI.
* JFFS2 không có chỉ mục trên phương tiện và phải xây dựng nó trong khi cài đặt,
  yêu cầu quét toàn bộ phương tiện. UBIFS duy trì chỉ mục FS
  thông tin trên phương tiện flash và không yêu cầu quét toàn bộ phương tiện,
  vì vậy nó gắn kết nhanh hơn nhiều lần so với JFFS2.
* JFFS2 là hệ thống tệp ghi qua, trong khi UBIFS hỗ trợ ghi lại,
  điều này làm cho UBIFS ghi nhanh hơn nhiều.

Tương tự như JFFS2, UBIFS hỗ trợ nén nhanh chóng, giúp
có thể chứa khá nhiều dữ liệu vào flash.

Tương tự như JFFS2, UBIFS có khả năng chịu được việc khởi động lại và cắt điện không sạch sẽ.
Nó không cần những thứ như fsck.ext2. UBIFS tự động phát lại
nhật ký và phục hồi sau các sự cố, đảm bảo rằng dữ liệu đang bật
các cấu trúc là nhất quán.

UBIFS chia tỷ lệ logarit (hầu hết các cấu trúc dữ liệu mà nó sử dụng là
cây), do đó thời gian gắn kết và mức tiêu thụ bộ nhớ không phụ thuộc tuyến tính
về kích thước đèn flash, như trong trường hợp JFFS2. Điều này là do UBIFS
duy trì chỉ số FS trên phương tiện flash. Tuy nhiên, UBIFS phụ thuộc vào
UBI, chia tỷ lệ tuyến tính. Vì vậy, tổng thể ngăn xếp UBI/UBIFS có tỷ lệ tuyến tính.
Tuy nhiên, UBI/UBIFS có quy mô tốt hơn đáng kể so với JFFS2.

Các tác giả của UBIFS tin rằng có thể phát triển UBI2
cũng sẽ mở rộng theo logarit. UBI2 sẽ hỗ trợ API tương tự như UBI,
nhưng nó sẽ không tương thích nhị phân với UBI. Vì vậy UBIFS sẽ không cần phải
đã thay đổi để sử dụng UBI2


Tùy chọn gắn kết
================

(*) == mặc định.

==================== ============================================================
Bulk_read đọc thêm một lần để tận dụng flash
			phương tiện đọc nhanh hơn theo tuần tự
no_bulk_read (*) không đọc hàng loạt
no_chk_data_crc (*) bỏ qua việc kiểm tra CRC trên các nút dữ liệu để
			cải thiện hiệu suất đọc. Chỉ sử dụng tùy chọn này
			nếu phương tiện flash có độ tin cậy cao. hiệu ứng
			của tùy chọn này là nội dung bị hỏng
			của một tập tin có thể không được chú ý.
chk_data_crc đừng bỏ qua việc kiểm tra CRC trên các nút dữ liệu
compr=none ghi đè máy nén mặc định và đặt thành "không"
compr=lzo ghi đè máy nén mặc định và đặt thành "lzo"
compr=zlib ghi đè máy nén mặc định và đặt thành "zlib"
auth_key= chỉ định khóa được sử dụng để xác thực hệ thống tệp.
			Việc chuyển tùy chọn này khiến việc xác thực trở thành bắt buộc.
			Khóa được thông qua phải có trong khóa hạt nhân
			và phải thuộc loại 'đăng nhập'
auth_hash_name= Thuật toán băm được sử dụng để xác thực. Dùng cho
			cả việc băm và tạo HMAC. Giá trị điển hình
			bao gồm "sha256" hoặc "sha512"
==================== ============================================================


Hướng dẫn sử dụng nhanh
========================

Ổ đĩa UBI cần gắn kết được chỉ định bằng cú pháp "ubiX_Y" hoặc "ubiX:NAME",
trong đó "X" là số thiết bị UBI, "Y" là số ổ đĩa UBI và "NAME" là
Tên tập UBI.

Gắn âm lượng 0 trên thiết bị UBI 0 vào /mnt/ubifs::

$ mount -t ubifs ubi0_0 /mnt/ubifs

Gắn âm lượng "rootfs" của thiết bị UBI 0 vào /mnt/ubifs ("rootfs" là âm lượng
tên)::

$ mount -t ubifs ubi0:rootfs /mnt/ubifs

Sau đây là ví dụ về các đối số khởi động kernel để đính kèm mtd0
vào UBI và gắn ổ đĩa "rootfs":
ubi.mtd=0 root=ubi0:rootfs rootfstype=ubifs

Tài liệu tham khảo
==================

Tài liệu UBIFS và FAQ/HOWTO tại trang web MTD:

-ZZ0000ZZ
-ZZ0001ZZ