.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/debug-objects.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================================
Cơ sở hạ tầng gỡ lỗi vòng đời đối tượng
================================================

:Tác giả: Thomas Gleixner

Giới thiệu
============

debugobjects là một cơ sở hạ tầng chung để theo dõi thời gian tồn tại của
các đối tượng kernel và xác nhận các hoạt động trên các đối tượng đó.

debugobjects rất hữu ích để kiểm tra các mẫu lỗi sau:

- Kích hoạt các đối tượng chưa được khởi tạo

- Khởi tạo các đối tượng hoạt động

- Sử dụng các đối tượng được giải phóng/bị phá hủy

debugobjects không thay đổi cấu trúc dữ liệu của đối tượng thực nên nó
có thể được biên dịch với tác động thời gian chạy tối thiểu và được kích hoạt theo yêu cầu
với tùy chọn dòng lệnh kernel.

Cách sử dụng debugobjects
=========================

Một hệ thống con kernel cần cung cấp cấu trúc dữ liệu mô tả
loại đối tượng và thêm lệnh gọi vào mã gỡ lỗi ở những nơi thích hợp. các
Cấu trúc dữ liệu để mô tả loại đối tượng cần tối thiểu tên của
kiểu đối tượng. Các chức năng tùy chọn có thể và nên được cung cấp để sửa lỗi
đã phát hiện sự cố để kernel có thể tiếp tục hoạt động và gỡ lỗi
thông tin có thể được lấy từ hệ thống trực tiếp thay vì lõi cứng
gỡ lỗi bằng bảng điều khiển nối tiếp và xếp chồng bảng ghi dấu vết từ
màn hình.

Các cuộc gọi gỡ lỗi được cung cấp bởi debugobjects là:

- debug_object_init

- debug_object_init_on_stack

- debug_object_activate

- debug_object_deactivate

- debug_object_destroy

- debug_object_free

- debug_object_assert_init

Mỗi hàm này lấy địa chỉ của đối tượng thực và một
con trỏ tới cấu trúc mô tả gỡ lỗi cụ thể của loại đối tượng.

Mỗi lỗi được phát hiện sẽ được báo cáo trong số liệu thống kê và một số lượng hạn chế
lỗi được in ra bao gồm cả dấu vết ngăn xếp đầy đủ.

Số liệu thống kê có sẵn qua /sys/kernel/debug/debug_objects/stats.
Chúng cung cấp thông tin về số lượng cảnh báo và số lượng
sửa chữa thành công cùng với thông tin về việc sử dụng nội bộ
các đối tượng theo dõi và trạng thái của nhóm đối tượng theo dõi nội bộ.

Chức năng gỡ lỗi
================

.. kernel-doc:: lib/debugobjects.c
   :functions: debug_object_init

Hàm này được gọi bất cứ khi nào hàm khởi tạo của một số thực
đối tượng được gọi.

Khi đối tượng thực đã được theo dõi bởi debugobjects, nó sẽ được kiểm tra,
liệu đối tượng có thể được khởi tạo hay không. Việc khởi tạo không được phép đối với
các đối tượng đang hoạt động và bị phá hủy. Khi các đối tượng gỡ lỗi phát hiện ra lỗi, thì
nó gọi hàm fixup_init của mô tả kiểu đối tượng
cấu trúc nếu được cung cấp bởi người gọi. Chức năng sửa lỗi có thể sửa lỗi
vấn đề trước khi việc khởi tạo thực sự của đối tượng xảy ra. Ví dụ. nó
có thể vô hiệu hóa một đối tượng đang hoạt động để tránh làm hỏng thiết bị
hệ thống con.

Khi đối tượng thực chưa được theo dõi bởi debugobjects, debugobjects
phân bổ một đối tượng theo dõi cho đối tượng thực và đặt trình theo dõi
trạng thái đối tượng thành ODEBUG_STATE_INIT. Nó xác minh rằng đối tượng không phải
trên ngăn xếp người gọi. Nếu nó nằm trong ngăn xếp người gọi thì sẽ bị giới hạn
số lượng cảnh báo bao gồm cả dấu vết ngăn xếp đầy đủ được in ra. các
mã gọi phải sử dụng debug_object_init_on_stack() và xóa
đối tượng trước khi rời khỏi hàm đã phân bổ nó. Xem phần tiếp theo.

.. kernel-doc:: lib/debugobjects.c
   :functions: debug_object_init_on_stack

Hàm này được gọi bất cứ khi nào hàm khởi tạo của một số thực
đối tượng nằm trên ngăn xếp được gọi.

Khi đối tượng thực đã được theo dõi bởi debugobjects, nó sẽ được kiểm tra,
liệu đối tượng có thể được khởi tạo hay không. Việc khởi tạo không được phép đối với
các đối tượng đang hoạt động và bị phá hủy. Khi các đối tượng gỡ lỗi phát hiện ra lỗi, thì
nó gọi hàm fixup_init của mô tả kiểu đối tượng
cấu trúc nếu được cung cấp bởi người gọi. Chức năng sửa lỗi có thể sửa lỗi
vấn đề trước khi việc khởi tạo thực sự của đối tượng xảy ra. Ví dụ. nó
có thể vô hiệu hóa một đối tượng đang hoạt động để tránh làm hỏng thiết bị
hệ thống con.

Khi đối tượng thực chưa được theo dõi bởi debugobjects debugobjects
phân bổ một đối tượng theo dõi cho đối tượng thực và đặt trình theo dõi
trạng thái đối tượng thành ODEBUG_STATE_INIT. Nó xác minh rằng đối tượng đang bật
người gọi xếp chồng lên nhau.

Một đối tượng nằm trong ngăn xếp phải được xóa khỏi trình theo dõi bằng cách
gọi debug_object_free() trước hàm phân bổ
đối tượng quay trở lại. Nếu không, chúng tôi theo dõi các đồ vật cũ.

.. kernel-doc:: lib/debugobjects.c
   :functions: debug_object_activate

Hàm này được gọi bất cứ khi nào hàm kích hoạt của một số thực
đối tượng được gọi.

Khi đối tượng thực đã được theo dõi bởi debugobjects, nó sẽ được kiểm tra,
liệu đối tượng có thể được kích hoạt hay không. Kích hoạt không được phép đối với
các đối tượng đang hoạt động và bị phá hủy. Khi các đối tượng gỡ lỗi phát hiện ra lỗi, thì
nó gọi hàm fixup_activate của mô tả loại đối tượng
cấu trúc nếu được cung cấp bởi người gọi. Chức năng sửa lỗi có thể sửa lỗi
vấn đề trước khi việc kích hoạt thực sự của đối tượng xảy ra. Ví dụ. nó có thể
hủy kích hoạt một đối tượng đang hoạt động để tránh làm hỏng hệ thống con.

Khi đối tượng thực chưa được theo dõi bởi debugobjects thì
Hàm fixup_activate được gọi nếu có. Điều này là cần thiết để
cho phép kích hoạt hợp pháp các phân bổ và khởi tạo tĩnh
đồ vật. Hàm fixup kiểm tra xem đối tượng có hợp lệ hay không và gọi
hàm debug_objects_init() để khởi tạo quá trình theo dõi này
đối tượng.

Khi kích hoạt là hợp pháp thì trạng thái của liên kết
đối tượng theo dõi được đặt thành ODEBUG_STATE_ACTIVE.


.. kernel-doc:: lib/debugobjects.c
   :functions: debug_object_deactivate

Hàm này được gọi bất cứ khi nào hàm hủy kích hoạt của một thiết bị thực
đối tượng được gọi.

Khi đối tượng thực được theo dõi bởi debugobjects, nó sẽ được kiểm tra xem liệu
đối tượng có thể bị vô hiệu hóa. Việc hủy kích hoạt không được phép đối với ứng dụng không bị theo dõi
hoặc đồ vật bị phá hủy.

Khi việc hủy kích hoạt là hợp pháp thì trạng thái của thiết bị được liên kết
đối tượng theo dõi được đặt thành ODEBUG_STATE_INACTIVE.

.. kernel-doc:: lib/debugobjects.c
   :functions: debug_object_destroy

Hàm này được gọi để đánh dấu một đối tượng bị phá hủy. Điều này rất hữu ích để
ngăn chặn việc sử dụng các đối tượng không hợp lệ vẫn có sẵn trong
bộ nhớ: các đối tượng được cấp phát tĩnh hoặc các đối tượng được giải phóng
sau này.

Khi đối tượng thực được theo dõi bởi debugobjects, nó sẽ được kiểm tra xem liệu
đối tượng có thể bị phá hủy. Việc phá hủy không được phép đối với hoạt động và
đồ vật bị phá hủy. Khi debugobjects phát hiện ra lỗi, nó sẽ gọi
hàm fixup_destroy của cấu trúc mô tả kiểu đối tượng nếu
do người gọi cung cấp. Chức năng sửa lỗi có thể khắc phục sự cố
trước khi sự phá hủy thực sự của đối tượng xảy ra. Ví dụ. nó có thể
hủy kích hoạt một đối tượng đang hoạt động để tránh làm hỏng hệ thống con.

Khi sự phá hủy là hợp pháp thì trạng thái của thiết bị liên quan
đối tượng theo dõi được đặt thành ODEBUG_STATE_DESTROYED.

.. kernel-doc:: lib/debugobjects.c
   :functions: debug_object_free

Hàm này được gọi trước khi một đối tượng được giải phóng.

Khi đối tượng thực được theo dõi bởi debugobjects, nó sẽ được kiểm tra xem liệu
đối tượng có thể được giải phóng. Miễn phí không được phép cho các đối tượng đang hoạt động. Khi nào
debugobjects phát hiện lỗi, sau đó nó gọi hàm fixup_free của
cấu trúc mô tả loại đối tượng nếu được cung cấp bởi người gọi. các
Chức năng fixup có thể khắc phục sự cố trước khi thực sự giải phóng
đối tượng xảy ra. Ví dụ. nó có thể vô hiệu hóa một đối tượng đang hoạt động để
ngăn chặn thiệt hại cho hệ thống con.

Lưu ý rằng debug_object_free sẽ xóa đối tượng khỏi trình theo dõi. sau này
việc sử dụng đối tượng được phát hiện bởi các lần kiểm tra gỡ lỗi khác.


.. kernel-doc:: lib/debugobjects.c
   :functions: debug_object_assert_init

Hàm này được gọi để xác nhận rằng một đối tượng đã được khởi tạo.

Khi đối tượng thực không được theo dõi bởi debugobjects, nó sẽ gọi
fixup_assert_init của cấu trúc mô tả loại đối tượng được cung cấp bởi
người gọi, với trạng thái đối tượng được mã hóa cứng ODEBUG_NOT_AVAILABLE. các
hàm fixup có thể khắc phục sự cố bằng cách gọi debug_object_init
và các chức năng khởi tạo cụ thể khác.

Khi đối tượng thực đã được theo dõi bởi debugobjects thì nó sẽ bị bỏ qua.

Chức năng sửa lỗi
=================

Gỡ lỗi cấu trúc mô tả loại đối tượng
---------------------------------------

.. kernel-doc:: include/linux/debugobjects.h
   :internal:

fixup_init
-----------

Hàm này được gọi từ mã gỡ lỗi bất cứ khi nào có vấn đề trong
debug_object_init được phát hiện. Hàm lấy địa chỉ của
đối tượng và trạng thái hiện được ghi lại trong trình theo dõi.

Được gọi từ debug_object_init khi trạng thái đối tượng là:

-ODEBUG_STATE_ACTIVE

Hàm trả về true khi sửa lỗi thành công, nếu không thì
sai. Giá trị trả về được sử dụng để cập nhật số liệu thống kê.

Lưu ý rằng hàm cần gọi hàm debug_object_init()
một lần nữa, sau khi hư hỏng đã được sửa chữa để giữ trạng thái
nhất quán.

sửa lỗi_kích hoạt
-----------------

Hàm này được gọi từ mã gỡ lỗi bất cứ khi nào có vấn đề trong
debug_object_activate được phát hiện.

Được gọi từ debug_object_activate khi trạng thái đối tượng là:

-ODEBUG_STATE_NOTAVAILABLE

-ODEBUG_STATE_ACTIVE

Hàm trả về true khi sửa lỗi thành công, nếu không thì
sai. Giá trị trả về được sử dụng để cập nhật số liệu thống kê.

Lưu ý rằng hàm cần gọi debug_object_activate()
hoạt động trở lại sau khi hư hỏng đã được sửa chữa để duy trì
trạng thái nhất quán.

Việc kích hoạt các đối tượng được khởi tạo tĩnh là một trường hợp đặc biệt. Khi nào
debug_object_activate() không có đối tượng được theo dõi cho địa chỉ đối tượng này
sau đó fixup_activate() được gọi với trạng thái đối tượng
ODEBUG_STATE_NOTAVAILABLE. Chức năng fixup cần kiểm tra xem
đây có phải là trường hợp hợp pháp của một đối tượng được khởi tạo tĩnh hay không. trong
trường hợp đó là nó gọi debug_object_init() và debug_object_activate()
để làm cho đối tượng được trình theo dõi biết đến và đánh dấu là đang hoạt động. Trong trường hợp này
hàm sẽ trả về false vì đây không phải là bản sửa lỗi thực sự.

fixup_destroy
--------------

Hàm này được gọi từ mã gỡ lỗi bất cứ khi nào có vấn đề trong
debug_object_destroy được phát hiện.

Được gọi từ debug_object_destroy khi trạng thái đối tượng là:

-ODEBUG_STATE_ACTIVE

Hàm trả về true khi sửa lỗi thành công, nếu không thì
sai. Giá trị trả về được sử dụng để cập nhật số liệu thống kê.

fixup_free
-----------

Hàm này được gọi từ mã gỡ lỗi bất cứ khi nào có vấn đề trong
debug_object_free được phát hiện. Hơn nữa nó có thể được gọi từ gỡ lỗi
kiểm tra kfree/vfree, khi một đối tượng hoạt động được phát hiện từ
debug_check_no_obj_freed() kiểm tra độ tỉnh táo.

Được gọi từ debug_object_free() hoặc debug_check_no_obj_freed() khi
trạng thái đối tượng là:

-ODEBUG_STATE_ACTIVE

Hàm trả về true khi sửa lỗi thành công, nếu không thì
sai. Giá trị trả về được sử dụng để cập nhật số liệu thống kê.

fixup_assert_init
-------------------

Hàm này được gọi từ mã gỡ lỗi bất cứ khi nào có vấn đề trong
debug_object_assert_init được phát hiện.

Được gọi từ debug_object_assert_init() với trạng thái được mã hóa cứng
ODEBUG_STATE_NOTAVAILABLE khi không tìm thấy đối tượng trong quá trình gỡ lỗi
xô.

Hàm trả về true khi sửa lỗi thành công, nếu không thì
sai. Giá trị trả về được sử dụng để cập nhật số liệu thống kê.

Lưu ý, hàm này phải đảm bảo debug_object_init() được gọi
trước khi quay lại.

Việc xử lý các đối tượng được khởi tạo tĩnh là một trường hợp đặc biệt. các
hàm fixup nên kiểm tra xem đây có phải là trường hợp hợp pháp của lỗi tĩnh không
đối tượng được khởi tạo hay không. Trong trường hợp này chỉ debug_object_init()
nên được gọi để làm cho đối tượng được biết đến bởi trình theo dõi. Sau đó
hàm sẽ trả về false vì đây không phải là bản sửa lỗi thực sự.

Lỗi đã biết và giả định
==========================

Không có (gõ vào gỗ).
