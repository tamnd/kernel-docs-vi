.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/amd-hfi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============================================================================
Giao diện phản hồi phần cứng để lập lịch Hetero Core trên nền tảng AMD
======================================================================

:Bản quyền: 2025 Advanced Micro Devices, Inc. Mọi quyền được bảo lưu.

:Tác giả: Perry Yuan <perry.yuan@amd.com>
:Tác giả: Mario Limonciello <mario.limonciello@amd.com>

Tổng quan
--------

Việc triển khai lõi không đồng nhất AMD bao gồm nhiều hơn một
lớp kiến trúc và CPU bao gồm các lõi có hiệu quả và
khả năng năng lượng: ZZ0000ZZ hướng đến hiệu suất và tiết kiệm năng lượng
ZZ0001ZZ. Vì vậy, các chiến lược quản lý năng lượng phải được thiết kế để
đáp ứng sự phức tạp được đưa ra bằng cách kết hợp các loại lõi khác nhau.
Các hệ thống không đồng nhất cũng có thể mở rộng đến nhiều hơn hai lớp kiến trúc
cũng vậy. Mục đích của cơ chế phản hồi lập kế hoạch là cung cấp
thông tin tới bộ lập lịch của hệ điều hành trong thời gian thực sao cho
bộ lập lịch có thể hướng các luồng đến lõi tối ưu.

Mục tiêu của kiến trúc không đồng nhất của AMD là đạt được lợi ích về năng lượng bằng cách
gửi các luồng nền tới các lõi dày đặc trong khi gửi mức độ ưu tiên cao
chủ đề đến lõi cổ điển. Từ góc độ hiệu suất, việc gửi
các luồng nền tới các lõi dày đặc có thể giải phóng khoảng trống năng lượng và cho phép
lõi cổ điển để phục vụ tối ưu các luồng đòi hỏi khắt khe. Hơn nữa, khu vực
bản chất tối ưu hóa của lõi dày đặc cho phép tăng số lượng
lõi vật lý. Mật độ lõi được cải thiện này sẽ có tác dụng đa luồng tích cực
tác động hiệu suất.

Trình điều khiển lõi không đồng nhất AMD
-----------------------------

Trình điều khiển ZZ0000ZZ mang đến cho hệ điều hành hiệu suất và năng lượng
dữ liệu về khả năng hiệu quả cho từng CPU trong hệ thống. Bộ lập lịch có thể sử dụng
dữ liệu xếp hạng từ trình điều khiển HFI để đưa ra quyết định sắp xếp nhiệm vụ.

Tương tác bảng phân loại và xếp hạng chủ đề
----------------------------------------------------

Việc phân loại luồng được sử dụng để chọn vào bảng xếp hạng
mô tả hiệu quả và xếp hạng hiệu suất cho mỗi phân loại.

Các luồng được phân loại trong thời gian chạy thành các lớp liệt kê. Các lớp học
đại diện cho các đặc tính hiệu suất/sức mạnh của luồng có thể được hưởng lợi từ
hành vi lập kế hoạch đặc biệt. Bảng dưới đây mô tả một ví dụ về chủ đề
phân loại và ưu tiên trong đó một luồng nhất định sẽ được lên lịch
dựa trên lớp chủ đề của nó. Phân loại luồng thời gian thực được sử dụng
bởi hệ điều hành và được sử dụng để thông báo cho bộ lập lịch về nơi
chủ đề nên được đặt.

Bảng ví dụ phân loại chủ đề
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
+----------+-------+-------------------------------+-------------+-----------+
ZZ0000ZZ Phân loại ZZ0001ZZ Ưu tiên ưu tiên ZZ0002ZZ
+----------+-------+-------------------------------+-------------+-----------+
ZZ0003ZZ Mặc định ZZ0004ZZ Cao nhất ZZ0005ZZ
+----------+-------+-------------------------------+-------------+-----------+
ZZ0006ZZ Không thể mở rộng ZZ0007ZZ ZZ0008ZZ thấp nhất
+----------+-------+-------------------------------+-------------+-----------+
ZZ0009ZZ Giới hạn I/O ZZ0010ZZ Thấp nhất ZZ0011ZZ
+----------+-------+-------------------------------+-------------+-----------+

Việc phân loại luồng được thực hiện bởi phần cứng mỗi khi tắt luồng.
Các chủ đề không đáp ứng bất kỳ tiêu chí nào được chỉ định về phần cứng sẽ được phân loại là "mặc định".

Giao diện phản hồi phần cứng AMD
--------------------------------

Giao diện phản hồi phần cứng cung cấp thông tin cho hệ điều hành
về hiệu suất và hiệu quả sử dụng năng lượng của từng CPU trong hệ thống. Mỗi
khả năng được đưa ra dưới dạng đại lượng không có đơn vị trong phạm vi [0-255]. Cao hơn
giá trị hiệu suất cho thấy khả năng hiệu suất cao hơn và cao hơn
giá trị hiệu quả cho thấy hiệu quả cao hơn. Hiệu quả và hiệu suất năng lượng
được báo cáo theo các khả năng riêng biệt trong bảng xếp hạng dựa trên bộ nhớ dùng chung.

Những khả năng này có thể thay đổi trong thời gian chạy do những thay đổi trong
điều kiện hoạt động của hệ thống hoặc tác động của các yếu tố bên ngoài.
Phần mềm quản lý nguồn có trách nhiệm phát hiện các sự kiện yêu cầu
sắp xếp lại thứ hạng hiệu suất và hiệu quả. Cập nhật bảng xảy ra
tương đối hiếm và xảy ra trong khoảng thời gian từ vài giây trở lên.

Các sự kiện sau kích hoạt cập nhật bảng:
    * Sự kiện ứng suất nhiệt
    * Tính toán im lặng
    * Tình huống pin cực thấp

Hạt nhân hoặc daemon chính sách không gian người dùng có thể sử dụng những khả năng này để sửa đổi
quyết định bố trí nhiệm vụ. Ví dụ, nếu hiệu suất hoặc năng lượng
khả năng của một bộ xử lý logic nhất định trở thành 0, đó là một dấu hiệu
mà phần cứng khuyến nghị hệ điều hành không lên lịch cho bất kỳ tác vụ nào
trên bộ xử lý đó vì lý do hiệu suất hoặc hiệu quả năng lượng tương ứng.

Chi tiết triển khai cho Linux
--------------------------------

Việc thực hiện lập lịch trình luồng bao gồm các bước sau:

1. Một luồng được sinh ra và lên lịch cho lõi lý tưởng bằng cách sử dụng mặc định
   chính sách lập kế hoạch không đồng nhất.
2. Bộ xử lý lập hồ sơ thực thi luồng và gán một giá trị liệt kê
   ID phân loại.
   Sự phân loại này được truyền tới HĐH thông qua bộ xử lý logic
   phạm vi MSR.
3. Trong ngữ cảnh luồng, hệ điều hành sẽ sử dụng
   phân loại khối lượng công việc (WL) nằm trong phạm vi bộ xử lý logic MSR.
4. Hệ điều hành kích hoạt phần cứng xóa lịch sử của nó bằng cách ghi vào MSR,
   sau khi sử dụng phân loại WL và trước khi chuyển sang luồng mới.
5. Nếu do phân loại, bảng xếp hạng và tính khả dụng của bộ xử lý,
   luồng không nằm trên bộ xử lý lý tưởng của nó, khi đó hệ điều hành sẽ xem xét
   lập lịch cho luồng trên bộ xử lý lý tưởng của nó (nếu có).

Bảng xếp hạng
-------------
Bảng xếp hạng là vùng bộ nhớ dùng chung được sử dụng để liên lạc
khả năng hoạt động và tiết kiệm năng lượng của từng CPU trong hệ thống.

Thiết kế bảng xếp hạng bao gồm thứ hạng cho từng ID APIC trong hệ thống và
xếp hạng cả về hiệu suất và hiệu quả cho từng phân loại khối lượng công việc.

.. kernel-doc:: drivers/platform/x86/amd/hfi/hfi.c
   :doc: amd_shmem_info

Cập nhật bảng xếp hạng
---------------------------
Phần sụn quản lý nguồn gây ra sự cố gián đoạn nền tảng sau khi cập nhật
bảng xếp hạng và sẵn sàng để hệ điều hành sử dụng nó. CPU nhận được
như vậy ngắt và đọc bảng xếp hạng mới từ bộ nhớ dùng chung mà bảng PCCT
đã cung cấp, thì trình điều khiển ZZ0000ZZ sẽ phân tích bảng mới để cung cấp
tiêu thụ dữ liệu cho các quyết định lập kế hoạch.