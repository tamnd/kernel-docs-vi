.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/free_page_reporting.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Báo cáo trang miễn phí
=======================

Báo cáo trang miễn phí là API mà thiết bị có thể đăng ký để nhận
danh sách các trang hiện không được hệ thống sử dụng. Điều này hữu ích trong
trường hợp ảo hóa trong đó khách có thể sử dụng dữ liệu này để
thông báo cho bộ ảo hóa rằng nó không còn sử dụng một số trang nhất định trong bộ nhớ.

Để người lái xe, thường là người lái khinh khí cầu, sử dụng chức năng này
nó sẽ phân bổ và khởi tạo cấu trúc page_reporting_dev_info. các
trường trong cấu trúc mà nó sẽ điền là hàm "báo cáo"
con trỏ được sử dụng để xử lý danh sách phân tán. Nó cũng phải đảm bảo rằng nó có thể
xử lý các mục nhập danh sách phân tán có giá trị ít nhất PAGE_REPORTING_CAPACITY cho mỗi
gọi hàm. Cuộc gọi đến page_reporting_register sẽ đăng ký
giao diện trang báo cáo với khung báo cáo giả sử không có khung nào khác
trang báo cáo thiết bị đã được đăng ký.

Sau khi đăng ký, trang báo cáo API sẽ bắt đầu báo cáo các đợt
trang cho trình điều khiển. API sẽ bắt đầu báo cáo các trang sau 2 giây
giao diện đã được đăng ký và sẽ tiếp tục như vậy sau 2 giây
trang có thứ tự đủ cao sẽ được giải phóng.

Các trang được báo cáo sẽ được lưu trữ trong danh sách phân tán được chuyển đến báo cáo
hàm với mục nhập cuối cùng có bit kết thúc được đặt trong mục nhập nent - 1.
Trong khi các trang đang được xử lý bằng chức năng báo cáo, chúng sẽ không được
có thể truy cập được đối với người cấp phát. Khi chức năng báo cáo đã được hoàn thành
các trang sẽ được trả về khu vực trống mà chúng được lấy từ đó.

Trước khi xóa trình điều khiển đang sử dụng trang miễn phí báo cáo nó
cần phải gọi page_reporting_unregister để có
Cấu trúc page_reporting_dev_info hiện đang được trang miễn phí sử dụng
báo cáo bị loại bỏ. Việc làm này sẽ ngăn không cho các báo cáo tiếp theo được thực hiện
được phát hành thông qua giao diện. Nếu một trình điều khiển khác hoặc trình điều khiển tương tự là
đã đăng ký thì nó có thể tiếp tục ở nơi trình điều khiển trước đó đã
còn lại về mặt báo cáo các trang miễn phí.

Alexander Duyck, ngày 04 tháng 12 năm 2019
