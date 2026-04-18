.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/power/powercap/dtpm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================================
Khung quản lý nhiệt điện động
==============================================

Trong thế giới nhúng, sự phức tạp của SoC dẫn đến
ngày càng có nhiều điểm nóng cần được theo dõi và giảm thiểu
nói chung là để ngăn chặn nhiệt độ vượt quá
'nhiệt độ da' được quy định và hợp pháp.

Một khía cạnh khác là duy trì hiệu suất cho một nguồn năng lượng nhất định,
ví dụ như thực tế ảo nơi người dùng có thể cảm thấy chóng mặt nếu
hiệu suất bị giới hạn trong khi CPU lớn đang xử lý thứ khác. Hoặc
giảm sạc pin vì công suất tiêu hao quá cao
so với điện năng tiêu thụ của các thiết bị khác.

Không gian người dùng là nơi thích hợp nhất để hoạt động linh hoạt trên
các thiết bị khác nhau bằng cách hạn chế sức mạnh của chúng trong một ứng dụng
profile: nó có kiến thức về nền tảng.

Quản lý năng lượng nhiệt động (DTPM) là một kỹ thuật hoạt động trên
nguồn điện của thiết bị bằng cách giới hạn và/hoặc cân bằng nguồn điện giữa
các thiết bị khác nhau.

Khung DTPM cung cấp một giao diện thống nhất để hoạt động trên
nguồn điện của thiết bị.

Tổng quan
=========

Khung DTPM dựa vào khung powercap để tạo ra
các mục powercap trong thư mục sysfs và triển khai phần phụ trợ
trình điều khiển để thực hiện kết nối với thiết bị có thể quản lý nguồn.

DTPM là biểu diễn dạng cây mô tả các hạn chế về nguồn điện
được chia sẻ giữa các thiết bị chứ không phải vị trí vật lý của chúng.

Các nút của cây là một mô tả ảo tổng hợp sức mạnh
đặc điểm của các nút con và giới hạn sức mạnh của chúng.

Lá của cây là thiết bị quản lý năng lượng thực sự.

Ví dụ::

SoC
   |
   ZZ0000ZZ-- pd1 (cpu4-5)

Công suất pkg sẽ là tổng của các số công suất pd0 và pd1::

SoC (400mW - 3100mW)
   |
   ZZ0000ZZ-- pd1 (300mW - 2400mW)

Khi các nút được chèn vào cây, đặc tính sức mạnh của chúng được truyền tới nút cha::

SoC (600mW - 5900mW)
   |
   |-- gói (400mW - 3100mW)
   ZZ0001ZZ
   ZZ0002ZZ-- pd0 (100mW - 700mW)
   ZZ0003ZZ
   |    ZZ0000ZZ-- pd2 (200mW - 2800mW)

Mỗi nút có trọng số trên cơ sở 2^10 phản ánh phần trăm mức tiêu thụ điện năng của các nút anh chị em::

SoC (w=1024)
   |
   |-- pkg (w=538)
   ZZ0001ZZ
   ZZ0002ZZ-- pd0 (w=231)
   ZZ0003ZZ
   |    ZZ0000ZZ-- pd2 (w=486)

Lưu ý tổng trọng số ở cùng cấp độ bằng 1024.

Khi giới hạn công suất được áp dụng cho một nút, thì nó sẽ được phân bổ cho các nút con dựa trên trọng số của chúng. Ví dụ: nếu chúng tôi đặt giới hạn công suất là 3200mW tại nút gốc 'SoC', cây kết quả sẽ là::

SoC (w=1024) <--- power_limit = 3200mW
   |
   |-- pkg (w=538) --> power_limit = 1681mW
   ZZ0001ZZ
   ZZ0002ZZ-- pd0 (w=231) --> power_limit = 378mW
   ZZ0003ZZ
   |    ZZ0000ZZ-- pd2 (w=486) --> power_limit = 1519mW


Mô tả phẳng
----------------

Một nút gốc được tạo và nó là nút cha của tất cả các nút. Cái này
mô tả là mô tả đơn giản nhất và nó được cho là cung cấp cho người dùng
không gian một biểu diễn phẳng của tất cả các thiết bị hỗ trợ nguồn điện
giới hạn mà không có bất kỳ sự phân phối giới hạn quyền lực nào.

Mô tả phân cấp
------------------------

Các thiết bị khác nhau hỗ trợ giới hạn nguồn điện được trình bày
theo thứ bậc. Có một nút gốc, tất cả các nút trung gian đều
nhóm các nút con có thể là nút trung gian hoặc nút thực
thiết bị.

Các nút trung gian tổng hợp thông tin nguồn và cho phép
đặt giới hạn công suất dựa trên trọng lượng của các nút.

Không gian người dùng API
=========================

Như đã nêu trong phần tổng quan, khung DTPM được xây dựng dựa trên
khung powercap. Như vậy giao diện sysfs là như nhau, mời bạn tham khảo
vào tài liệu powercap để biết thêm chi tiết.

* power_uw: Điện năng tiêu thụ tức thời. Nếu nút là một
   nút trung gian thì mức tiêu thụ điện năng sẽ là tổng của tất cả
   tiêu thụ điện năng của trẻ em

* max_power_range_uw: Dải công suất tính được công suất cực đại
   trừ đi công suất tối thiểu.

* name: Tên của nút. Điều này phụ thuộc vào việc thực hiện. Thậm chí
   nếu nó không được khuyến nghị cho không gian người dùng, một số nút có thể có
   cùng tên.

* ràng buộc_X_name: Tên của ràng buộc.

* ràng buộc_X_max_power_uw: Giới hạn công suất tối đa có thể áp dụng
   đến nút.

* ràng buộc_X_power_limit_uw: Giới hạn công suất được áp dụng cho
   nút. Nếu giá trị chứa trong ràng buộc_X_max_power_uw được đặt,
   ràng buộc sẽ được loại bỏ.

* ràng buộc_X_time_window_us: Ý nghĩa của tập tin này sẽ phụ thuộc
   trên số ràng buộc.

Hạn chế
-----------

* Ràng buộc 0: Giới hạn công suất được áp dụng ngay lập tức mà không cần
   hạn chế về mặt thời gian.

Hạt nhân API
============

Tổng quan
---------

Khung DTPM không có hỗ trợ phụ trợ giới hạn năng lượng. Đó là
chung và cung cấp một bộ API để cho phép các trình điều khiển khác nhau
triển khai phần phụ trợ cho việc giới hạn năng lượng và tạo ra
cây giới hạn công suất

Nền tảng có thể cung cấp chức năng khởi tạo cho
phân bổ và liên kết các nút khác nhau của cây.

Một macro đặc biệt có vai trò khai báo một nút và phần tử tương ứng
hàm khởi tạo thông qua cấu trúc mô tả. Cái này chứa
trường cha tùy chọn cho phép kết nối các thiết bị khác nhau với một
cây đã tồn tại lúc khởi động.

Ví dụ::

cấu trúc dtpm_descr my_descr = {
		.name = "my_name",
		.init = my_init_func,
	};

DTPM_DECLARE(my_descr);

Các nút của cây DTPM được mô tả bằng cấu trúc dtpm. các
các bước để thêm một thiết bị có giới hạn nguồn điện mới được thực hiện theo ba bước:

* Phân bổ nút dtpm
 * Đặt số điện của nút dtpm
 * Đăng ký nút dtpm

Việc đăng ký nút dtpm được thực hiện bằng powercap
ôi. Về cơ bản, nó phải triển khai các lệnh gọi lại để nhận và thiết lập
sức mạnh và giới hạn.

Ngoài ra, nếu nút được chèn là nút trung gian thì
đã có sẵn một chức năng đơn giản để chèn nó làm cha mẹ tương lai.

Nếu một thiết bị có đặc tính nguồn thay đổi thì cây phải
được cập nhật với số công suất và trọng lượng mới.

Danh pháp
------------

* dtpm_alloc() : Cấp phát và khởi tạo cấu trúc dtpm

* dtpm_register() : Thêm nút dtpm vào cây

* dtpm_unregister() : Xóa nút dtpm khỏi cây

* dtpm_update_power() : Cập nhật đặc tính nguồn của nút dtpm