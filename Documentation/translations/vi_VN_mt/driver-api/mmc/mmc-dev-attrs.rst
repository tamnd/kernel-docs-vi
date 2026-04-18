.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/mmc/mmc-dev-attrs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================
Thuộc tính thiết bị chặn SD và MMC
=====================================

Các thuộc tính này được xác định cho các thiết bị khối được liên kết với
Thiết bị SD hoặc MMC.

Các thuộc tính sau đây là đọc/ghi.

============================================================
	Force_ro Thực thi quyền truy cập chỉ đọc ngay cả khi khóa chuyển đổi bảo vệ ghi bị tắt.
	============================================================

Thuộc tính thiết bị SD và MMC
============================

Tất cả các thuộc tính là chỉ đọc.

==========================================================================
	Đăng ký nhận dạng thẻ cid
	Đăng ký dữ liệu cụ thể của thẻ csd
	scr Đăng ký cấu hình thẻ SD (chỉ SD)
	ngày Ngày sản xuất (từ Đăng ký CID)
	fwrev Bản sửa đổi chương trình cơ sở/sản phẩm (từ Đăng ký CID)
				(Chỉ SD và MMCv1)
	hwrev Bản sửa đổi phần cứng/sản phẩm (từ Đăng ký CID)
				(Chỉ SD và MMCv1)
	ID nhà sản xuất manfid (từ Đăng ký CID)
	tên Tên sản phẩm (từ Đăng ký CID)
	oemid OEM/ID ứng dụng (từ Đăng ký CID)
	prv Bản sửa đổi sản phẩm (từ Đăng ký CID)
				(Chỉ SD và MMCv4)
	nối tiếp Số sê-ri sản phẩm (từ Đăng ký CID)
	eras_size Xóa kích thước nhóm
	ưa thích_erase_size Kích thước xóa ưa thích
	raw_rpmb_size_mult Kích thước phân vùng RPMB
	rel_sectors Số lượng khu vực ghi đáng tin cậy
	ocr Đăng ký điều kiện hoạt động
	Đăng ký giai đoạn trình điều khiển dsr
	cmdq_en Đã bật hàng đợi lệnh:

1 => đã bật, 0 => chưa bật
	==========================================================================

Lưu ý về Kích thước Xóa và Kích thước Xóa Ưu tiên:

"erase_size" là kích thước tối thiểu, tính bằng byte, của một lần xóa
	hoạt động.  Đối với MMC, "erase_size" là kích thước nhóm xóa
	được thẻ báo cáo.  Lưu ý rằng "erase_size" không áp dụng
	để cắt hoặc đảm bảo các hoạt động cắt ở nơi có kích thước tối thiểu
	luôn có một cung 512 byte.  Đối với SD, "erase_size" là 512
	nếu thẻ có địa chỉ khối, ngược lại là 0.

Thẻ SD/MMC có thể xóa một vùng rộng tùy ý lên tới và
	bao gồm cả thẻ.  Khi xóa một vùng rộng lớn, nó có thể
	nên làm điều đó theo từng phần nhỏ hơn vì ba lý do:

1. Một lệnh xóa sẽ bật tất cả các I/O khác
		thẻ chờ nhé.  Đây không phải là vấn đề nếu toàn bộ thẻ
		đang bị xóa, nhưng việc xóa một phân vùng sẽ tạo ra
		I/O cho một phân vùng khác trên cùng một thẻ, hãy đợi
		thời gian xóa - có thể là một vài
		phút.
	     2. Có thể thông báo cho người dùng về tiến trình xóa.
	     3. Thời gian chờ xóa trở nên quá lớn để có thể
		hữu ích.  Vì thời gian chờ xóa có chứa lề
		được nhân với kích thước của vùng xóa,
		giá trị cuối cùng có thể là vài phút đối với số lượng lớn
		các khu vực.

"erase_size" không phải là đơn vị hiệu quả nhất để xóa
	(đặc biệt đối với SD vì nó chỉ là một khu vực),
	do đó "preferred_erase_size" cung cấp một đoạn tốt
	kích thước để xóa các khu vực lớn.

Đối với MMC, "preferred_erase_size" là dung lượng cao
	xóa kích thước nếu thẻ chỉ định một kích thước, nếu không thì đó là
	tùy theo dung lượng của thẻ.

Đối với SD, "preferred_erase_size" là đơn vị phân bổ
	kích thước được chỉ định bởi thẻ.

"preferred_erase_size" tính bằng byte.

Lưu ý về raw_rpmb_size_mult:

"raw_rpmb_size_mult" là bội số của khối 128kB.

Kích thước RPMB tính bằng byte được tính bằng phương trình sau:

Kích thước phân vùng RPMB = 128kB x raw_rpmb_size_mult
