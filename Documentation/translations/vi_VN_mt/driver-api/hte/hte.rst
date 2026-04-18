.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/hte/hte.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================================
Công cụ đánh dấu thời gian phần cứng Linux (HTE)
================================================

:Tác giả: Dipen Patel

Giới thiệu
------------

Một số thiết bị có công cụ đánh dấu thời gian phần cứng tích hợp có thể
giám sát các bộ tín hiệu hệ thống, đường truyền, xe buýt, v.v... trong thời gian thực để biết trạng thái
thay đổi; khi phát hiện sự thay đổi, họ có thể tự động lưu dấu thời gian tại
thời điểm xảy ra. Chức năng như vậy có thể giúp đạt được độ chính xác tốt hơn
trong việc lấy dấu thời gian hơn là sử dụng các phần mềm tương ứng, tức là ktime và
bạn bè.

Tài liệu này mô tả API có thể được sử dụng bằng cách đánh dấu thời gian phần cứng
nhà cung cấp động cơ và trình điều khiển người tiêu dùng muốn sử dụng dấu thời gian phần cứng
khung động cơ (HTE). Cả người tiêu dùng và nhà cung cấp đều phải bao gồm
ZZ0000ZZ.

API khung HTE dành cho nhà cung cấp
----------------------------------------

.. kernel-doc:: drivers/hte/hte.c
   :functions: devm_hte_register_chip hte_push_ts_ns

API khung HTE dành cho người tiêu dùng
----------------------------------------

.. kernel-doc:: drivers/hte/hte.c
   :functions: hte_init_line_attr hte_ts_get hte_ts_put devm_hte_request_ts_ns hte_request_ts_ns hte_enable_ts hte_disable_ts of_hte_req_count hte_get_clk_src_info

Cấu trúc công cộng khung HTE
-----------------------------------
.. kernel-doc:: include/linux/hte.h

Thông tin thêm về dữ liệu dấu thời gian HTE
-------------------------------------------
ZZ0000ZZ được sử dụng để truyền chi tiết dấu thời gian giữa
người tiêu dùng và nhà cung cấp. Nó thể hiện dữ liệu dấu thời gian tính bằng nano giây trong
u64. Một ví dụ về vòng đời dữ liệu dấu thời gian điển hình cho dòng GPIO là
như sau::

- Theo dõi sự thay đổi dòng GPIO.
 - Phát hiện sự thay đổi trạng thái trên dòng GPIO.
 - Chuyển đổi dấu thời gian tính bằng nano giây.
 - Lưu trữ mức thô GPIO trong biến raw_level nếu nhà cung cấp có biến đó
 khả năng phần cứng.
 - Đẩy đối tượng hte_ts_data này vào hệ thống con HTE.
 - Hệ thống con HTE tăng bộ đếm thứ tự và gọi lệnh gọi lại do người tiêu dùng cung cấp.
 Dựa trên giá trị trả về cuộc gọi lại, lõi HTE gọi cuộc gọi lại thứ cấp trong
 bối cảnh chủ đề.

Thuộc tính gỡ lỗi hệ thống con HTE
----------------------------------
Hệ thống con HTE tạo các thuộc tính debugfs tại ZZ0000ZZ.
Nó cũng tạo ra các thuộc tính debugfs liên quan đến dòng/tín hiệu tại
ZZ0001ZZ. Lưu ý rằng những
thuộc tính chỉ đọc.

ZZ0001ZZ
		Tổng số thực thể được yêu cầu từ nhà cung cấp nhất định,
		trong đó thực thể được nhà cung cấp chỉ định và có thể đại diện
		đường dây, GPIO, tín hiệu chip, xe buýt, v.v...
                Thuộc tính sẽ có sẵn tại
		ZZ0000ZZ.

ZZ0001ZZ
		Tổng số thực thể được nhà cung cấp hỗ trợ.
                Thuộc tính sẽ có sẵn tại
		ZZ0000ZZ.

ZZ0001ZZ
		Dấu thời gian bị xóa cho một dòng nhất định.
                Thuộc tính sẽ có sẵn tại
		ZZ0000ZZ.