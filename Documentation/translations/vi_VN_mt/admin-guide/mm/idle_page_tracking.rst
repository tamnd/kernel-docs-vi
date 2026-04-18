.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/mm/idle_page_tracking.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Theo dõi trang nhàn rỗi
=======================

Động lực
==========

Tính năng theo dõi trang nhàn rỗi cho phép theo dõi trang bộ nhớ nào đang được
được truy cập bởi một khối lượng công việc và đang ở trạng thái rảnh. Thông tin này có thể hữu ích cho
ước tính kích thước tập công việc của khối lượng công việc, từ đó có thể được đưa vào
tài khoản khi định cấu hình các tham số khối lượng công việc, cài đặt giới hạn nhóm bộ nhớ,
hoặc quyết định nơi đặt khối lượng công việc trong cụm điện toán.

Nó được kích hoạt bởi CONFIG_IDLE_PAGE_TRACKING=y.

.. _user_api:

Người dùng API
========

API theo dõi trang nhàn rỗi được đặt tại ZZ0000ZZ.
Hiện tại, nó bao gồm tệp đọc-ghi duy nhất,
ZZ0001ZZ.

Tệp triển khai một bitmap trong đó mỗi bit tương ứng với một trang bộ nhớ. các
bitmap được biểu thị bằng một mảng các số nguyên 8 byte và trang tại PFN #i là
được ánh xạ tới bit #i%64 của phần tử mảng #i/64, thứ tự byte là gốc. Khi một chút là
được đặt, trang tương ứng sẽ không hoạt động.

Một trang được coi là không hoạt động nếu nó chưa được truy cập kể từ khi được đánh dấu là không hoạt động
(để biết thêm chi tiết về ý nghĩa thực sự của "được truy cập", hãy xem phần ZZ0000ZZ).
Để đánh dấu một trang không hoạt động, người ta phải đặt bit tương ứng với
trang bằng cách ghi vào tập tin. Một giá trị được ghi vào tệp là OR-ed với
giá trị bitmap hiện tại.

Chỉ những truy cập vào các trang bộ nhớ của người dùng mới được theo dõi. Đây là những trang được ánh xạ tới một
xử lý không gian địa chỉ, bộ đệm trang và các trang bộ đệm, trao đổi các trang bộ đệm. Đối với người khác
các loại trang (ví dụ: trang SLAB), nỗ lực đánh dấu một trang ở trạng thái không hoạt động sẽ bị bỏ qua một cách âm thầm,
và do đó những trang như vậy không bao giờ được báo cáo là không hoạt động.

Đối với các trang lớn, cờ nhàn rỗi chỉ được đặt trên trang đầu, do đó người ta phải đọc
ZZ0000ZZ để đếm chính xác các trang lớn không hoạt động.

Việc đọc hoặc ghi vào ZZ0000ZZ sẽ quay trở lại
-EINVAL nếu bạn không bắt đầu đọc/ghi trên ranh giới 8 byte hoặc
nếu kích thước đọc/ghi không phải là bội số của 8 byte. Viết cho
tệp này vượt quá PFN tối đa sẽ trả về -ENXIO.

Điều đó có nghĩa là, để ước tính số lượng trang không được sử dụng bởi một
khối lượng công việc người ta nên:

1. Đánh dấu tất cả các trang của khối lượng công việc là không hoạt động bằng cách đặt các bit tương ứng trong
    ZZ0000ZZ. Các trang có thể được tìm thấy bằng cách đọc
    ZZ0001ZZ nếu khối lượng công việc được biểu thị bằng một quy trình hoặc bằng
    lọc các trang lạ bằng ZZ0002ZZ trong trường hợp khối lượng công việc
    được đặt trong một nhóm bộ nhớ.

2. Đợi cho đến khi khối lượng công việc truy cập vào tập công việc của nó.

3. Đọc ZZ0000ZZ và đếm số bit được đặt.
    Nếu ai đó muốn bỏ qua một số loại trang nhất định, ví dụ: các trang bị khóa vì chúng
    không thể lấy lại được, họ có thể lọc chúng ra bằng cách sử dụng
    ZZ0001ZZ.

Công cụ loại trang trong thư mục tools/mm có thể được sử dụng để hỗ trợ việc này.
Nếu công cụ được chạy ban đầu với tùy chọn thích hợp, nó sẽ đánh dấu tất cả
các trang được truy vấn ở trạng thái rảnh.  Những lần chạy công cụ tiếp theo có thể hiển thị những trang nào có
cờ nhàn rỗi của họ đã bị xóa trong thời gian tạm thời.

Xem Documentation/admin-guide/mm/pagemap.rst để biết thêm thông tin về
ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ.

.. _impl_details:

Chi tiết triển khai
======================

Hạt nhân nội bộ theo dõi các truy cập vào các trang bộ nhớ của người dùng để
lấy lại các trang không được tham chiếu trước tiên trong điều kiện thiếu bộ nhớ. Một trang là
được coi là được tham chiếu nếu nó được truy cập gần đây thông qua một địa chỉ tiến trình
không gian, trong trường hợp đó một hoặc nhiều PTE được ánh xạ tới sẽ có bit Truy cập
được đặt hoặc được đánh dấu một cách rõ ràng bởi kernel (xem mark_page_accessed()). các
sau này xảy ra khi:

- quy trình không gian người dùng đọc hoặc ghi một trang bằng lệnh gọi hệ thống (ví dụ: read(2)
   hoặc viết(2))

- một trang được sử dụng để lưu trữ bộ đệm hệ thống tập tin được đọc hoặc ghi,
   bởi vì một tiến trình cần siêu dữ liệu hệ thống tập tin được lưu trữ trong đó (ví dụ: liệt kê một
   cây thư mục)

- một trang được trình điều khiển thiết bị truy cập bằng get_user_pages()

Khi một trang bẩn được ghi vào ổ đĩa hoặc ổ đĩa do việc lấy lại bộ nhớ hoặc
vượt quá giới hạn bộ nhớ bẩn, nó không được đánh dấu là tham chiếu.

Tính năng theo dõi bộ nhớ nhàn rỗi thêm cờ trang mới là cờ Nhàn rỗi. Lá cờ này
được đặt thủ công bằng cách ghi vào ZZ0001ZZ (xem phần
ZZ0000ZZ
phần) và được xóa tự động bất cứ khi nào một trang được tham chiếu như được xác định
ở trên.

Khi một trang được đánh dấu là không hoạt động, bit Truy cập phải được xóa trong tất cả các PTE.
được ánh xạ tới, nếu không chúng tôi sẽ không thể phát hiện các truy cập vào trang sắp tới
từ một không gian địa chỉ tiến trình. Để tránh sự can thiệp với người thu hồi, trong đó,
như đã lưu ý ở trên, sử dụng bit Accessed để quảng bá các trang được tham chiếu tích cực, một
thêm trang cờ được giới thiệu, cờ Trẻ. Khi bit truy cập PTE được
bị xóa do cài đặt hoặc cập nhật cờ Không hoạt động của trang, cờ Trẻ
được đặt trên trang. Người đòi lại coi cờ Young như một PTE bổ sung
Bit được truy cập và do đó sẽ coi trang đó là được tham chiếu.

Vì tính năng theo dõi bộ nhớ nhàn rỗi dựa trên logic thu hồi bộ nhớ,
nó chỉ hoạt động với các trang nằm trong danh sách LRU, các trang khác đang âm thầm
bị phớt lờ. Điều đó có nghĩa là nó sẽ bỏ qua trang bộ nhớ người dùng nếu nó bị cô lập, nhưng
vì chúng thường không có nhiều nên nó sẽ không ảnh hưởng đến tổng thể
mang lại kết quả đáng chú ý. Để không dừng quá trình quét bitmap trang nhàn rỗi,
các trang bị khóa cũng có thể bị bỏ qua.
