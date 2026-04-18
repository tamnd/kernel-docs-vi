.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/dev-tools/kmemleak.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình phát hiện rò rỉ bộ nhớ hạt nhân
===========================

Kmemleak cung cấp cách phát hiện rò rỉ bộ nhớ kernel có thể xảy ra trong
tương tự như ZZ0001ZZ,
với sự khác biệt là các đối tượng mồ côi không được giải phóng mà chỉ
được báo cáo qua /sys/kernel/debug/kmemleak. Một phương pháp tương tự được sử dụng bởi
Công cụ Valgrind (ZZ0000ZZ) để phát hiện rò rỉ bộ nhớ trong
các ứng dụng không gian người dùng.

Cách sử dụng
-----

CONFIG_DEBUG_KMEMLEAK trong "Kernel hack" phải được bật. Một hạt nhân
luồng quét bộ nhớ cứ sau 10 phút (theo mặc định) và in
số lượng đối tượng không được tham chiếu mới được tìm thấy. Nếu ZZ0000ZZ chưa có
gắn kết, gắn kết với::

# mount -t debugfs nodev /sys/kernel/debug/

Để hiển thị chi tiết về tất cả các rò rỉ bộ nhớ được quét có thể xảy ra::

# cat/sys/kernel/gỡ lỗi/kmemleak

Để kích hoạt quét bộ nhớ trung gian::

Quét # echo > /sys/kernel/debug/kmemleak

Để xóa danh sách tất cả các rò rỉ bộ nhớ hiện tại có thể xảy ra::

Xóa # echo > /sys/kernel/debug/kmemleak

Những rò rỉ mới sau đó sẽ xuất hiện khi đọc ZZ0000ZZ
một lần nữa.

Lưu ý rằng các đối tượng mồ côi được liệt kê theo thứ tự chúng được phân bổ
và một đối tượng ở đầu danh sách có thể gây ra các đối tượng khác tiếp theo
đối tượng được báo cáo là trẻ mồ côi.

Các tham số quét bộ nhớ có thể được sửa đổi trong thời gian chạy bằng cách ghi vào
Tệp ZZ0000ZZ. Các thông số sau được hỗ trợ:

- tắt
    vô hiệu hóa kmemleak (không thể đảo ngược)
- ngăn xếp=bật
    bật tính năng quét ngăn xếp tác vụ (mặc định)
- ngăn xếp=tắt
    vô hiệu hóa việc quét ngăn xếp nhiệm vụ
- quét=bật
    bắt đầu chuỗi quét bộ nhớ tự động (mặc định)
- quét=tắt
    dừng luồng quét bộ nhớ tự động
- quét=<giây>
    đặt khoảng thời gian quét bộ nhớ tự động tính bằng giây
    (mặc định 600, 0 để dừng quét tự động)
- quét
    kích hoạt quét bộ nhớ
- rõ ràng
    danh sách rõ ràng các nghi phạm rò rỉ bộ nhớ hiện tại, được thực hiện bởi
    đánh dấu tất cả các đối tượng không được tham chiếu được báo cáo hiện tại màu xám,
    hoặc giải phóng tất cả các đối tượng kmemleak nếu kmemleak đã bị vô hiệu hóa.
- đổ=<addr>
    kết xuất thông tin về đối tượng được tìm thấy tại <addr>

Kmemleak cũng có thể bị vô hiệu hóa khi khởi động bằng cách bật ZZ0000ZZ
dòng lệnh hạt nhân.

Bộ nhớ có thể được cấp phát hoặc giải phóng trước khi kmemleak được khởi tạo và
những hành động này được lưu trữ trong bộ đệm nhật ký sớm. Kích thước của bộ đệm này
được cấu hình thông qua tùy chọn CONFIG_DEBUG_KMEMLEAK_MEM_POOL_SIZE.

Nếu CONFIG_DEBUG_KMEMLEAK_DEFAULT_OFF được bật, kmemleak sẽ
bị tắt theo mặc định. Truyền ZZ0000ZZ bằng lệnh kernel
dòng kích hoạt chức năng.

Nếu bạn gặp phải các lỗi như "Lỗi khi ghi vào thiết bị xuất chuẩn" hoặc "write_loop:
Đối số không hợp lệ", hãy đảm bảo kmemleak được bật đúng cách.

Thuật toán cơ bản
---------------

Việc phân bổ bộ nhớ thông qua ZZ0000ZZ, ZZ0001ZZ,
ZZ0002ZZ và
bạn bè được theo dõi và các con trỏ, cùng với bổ sung
thông tin như kích thước và dấu vết ngăn xếp, được lưu trữ trong rbtree.
Các lệnh gọi hàm giải phóng tương ứng được theo dõi và các con trỏ
bị xóa khỏi cấu trúc dữ liệu kmemleak.

Một khối bộ nhớ được phân bổ được coi là mồ côi nếu không có con trỏ tới nó
địa chỉ bắt đầu hoặc đến bất kỳ vị trí nào trong khối có thể được tìm thấy bởi
quét bộ nhớ (bao gồm cả các thanh ghi đã lưu). Điều này có nghĩa là có
có thể không có cách nào để kernel chuyển địa chỉ của phần được phân bổ
khối thành chức năng giải phóng và do đó khối được coi là một
rò rỉ bộ nhớ.

Các bước thuật toán quét:

1. đánh dấu tất cả các đối tượng là màu trắng (các đối tượng màu trắng còn lại sau này sẽ được
     được coi là mồ côi)
  2. quét bộ nhớ bắt đầu từ phần dữ liệu và ngăn xếp, kiểm tra
     các giá trị so với các địa chỉ được lưu trữ trong rbtree. Nếu
     một con trỏ tới một đối tượng màu trắng được tìm thấy, đối tượng đó sẽ được thêm vào
     danh sách màu xám
  3. quét các đối tượng màu xám để tìm địa chỉ phù hợp (một số đối tượng màu trắng
     có thể chuyển sang màu xám và được thêm vào cuối danh sách màu xám) cho đến khi
     bộ màu xám đã hoàn thành
  4. Các đối tượng màu trắng còn lại được coi là mồ côi và được báo cáo qua
     /sys/kernel/gỡ lỗi/kmemleak

Một số khối bộ nhớ được cấp phát có con trỏ được lưu trữ trong kernel
cấu trúc dữ liệu nội bộ và chúng không thể được phát hiện là trẻ mồ côi. Đến
tránh điều này, kmemleak cũng có thể lưu trữ số lượng giá trị trỏ đến một
địa chỉ bên trong dải địa chỉ khối cần tìm để
khối không được coi là rò rỉ. Một ví dụ là __vmalloc().

Kiểm tra các phần cụ thể với kmemleak
---------------------------------------

Khi khởi động lần đầu, trang đầu ra /sys/kernel/debug/kmemleak của bạn có thể là
khá rộng rãi. Đây cũng có thể là trường hợp nếu bạn có mã rất lỗi
khi thực hiện phát triển. Để giải quyết những tình huống này, bạn có thể sử dụng
Lệnh 'clear' để xóa tất cả các đối tượng không được tham chiếu được báo cáo khỏi
/sys/kernel/debug/kmemleak đầu ra. Bằng cách đưa ra 'quét' sau khi 'xóa'
bạn có thể tìm thấy các đối tượng mới không được tham chiếu; điều này sẽ giúp ích cho việc kiểm tra
các phần mã cụ thể.

Để kiểm tra một phần quan trọng theo yêu cầu bằng kmemleak sạch, hãy làm::

Xóa # echo > /sys/kernel/debug/kmemleak
  ... test your kernel or modules ...
Quét # echo > /sys/kernel/debug/kmemleak

Sau đó, như thường lệ, bạn sẽ nhận được báo cáo của mình với::

# cat/sys/kernel/gỡ lỗi/kmemleak

Giải phóng các đối tượng nội bộ kmemleak
---------------------------------

Để cho phép truy cập vào các rò rỉ bộ nhớ được phát hiện trước đó sau khi kmemleak bị rò rỉ
bị người dùng vô hiệu hóa hoặc do lỗi nghiêm trọng, các đối tượng kmemleak nội bộ
sẽ không được giải phóng khi kmemleak bị vô hiệu hóa và những đối tượng đó có thể chiếm
một phần lớn bộ nhớ vật lý.

Trong trường hợp này, bạn có thể lấy lại bộ nhớ bằng::

Xóa # echo > /sys/kernel/debug/kmemleak

Kmemleak API
------------

Xem tiêu đề include/linux/kmemleak.h để biết nguyên mẫu hàm.

- ZZ0000ZZ - khởi tạo kmemleak
- ZZ0001ZZ - thông báo về việc phân bổ khối bộ nhớ
- ZZ0002ZZ - thông báo về việc phân bổ khối bộ nhớ percpu
- ZZ0003ZZ - thông báo về việc cấp phát bộ nhớ vmalloc()
- ZZ0004ZZ - thông báo giải phóng khối bộ nhớ
- ZZ0005ZZ - thông báo giải phóng một phần khối bộ nhớ
- ZZ0006ZZ - thông báo về việc giải phóng khối bộ nhớ percpu
- ZZ0007ZZ - cập nhật dấu vết ngăn xếp phân bổ đối tượng
- ZZ0008ZZ - đánh dấu một vật thể không bị rò rỉ
- ZZ0009ZZ - đánh dấu một đối tượng là rò rỉ thoáng qua
- ZZ0010ZZ - không quét hoặc báo cáo đối tượng là rò rỉ
- ZZ0011ZZ - thêm vùng quét bên trong khối bộ nhớ
- ZZ0012ZZ - không quét khối bộ nhớ
- ZZ0013ZZ - xóa giá trị cũ trong biến con trỏ
- ZZ0014ZZ - dưới dạng kmemleak_alloc nhưng kiểm tra tính đệ quy
- ZZ0015ZZ - dưới dạng kmemleak_free nhưng kiểm tra tính đệ quy

Các hàm sau lấy địa chỉ vật lý làm con trỏ đối tượng
và chỉ thực hiện hành động tương ứng nếu địa chỉ có mức thấp
lập bản đồ:

-ZZ0000ZZ
-ZZ0001ZZ
-ZZ0002ZZ

Xử lý kết quả dương tính/âm tính giả
--------------------------------------

Các kết quả âm tính giả là rò rỉ bộ nhớ thực (đối tượng mồ côi) nhưng không phải
được kmemleak báo cáo vì các giá trị được tìm thấy trong quá trình quét bộ nhớ
chỉ vào những đồ vật như vậy. Để giảm số lượng âm tính giả, kmemleak
cung cấp kmemleak_ignore, kmemleak_scan_area, kmemleak_no_scan và
các hàm kmemleak_erase (xem ở trên). Các ngăn xếp nhiệm vụ cũng làm tăng
số lượng âm tính giả và tính năng quét chúng không được bật theo mặc định.

Kết quả dương tính giả là các đối tượng được báo cáo sai là rò rỉ bộ nhớ
(mồ côi). Đối với các đối tượng được biết là không bị rò rỉ, kmemleak cung cấp
hàm kmemleak_not_leak. kmeleak_ignore cũng có thể được sử dụng nếu
khối bộ nhớ được biết là không chứa các con trỏ khác và nó sẽ không
được quét lâu hơn.

Một số rò rỉ được báo cáo chỉ là nhất thời, đặc biệt là trên SMP
hệ thống, do các con trỏ được lưu trữ tạm thời trong các thanh ghi CPU hoặc
ngăn xếp. Kmemleak định nghĩa MSECS_MIN_AGE (mặc định là 1000) đại diện cho
tuổi tối thiểu của một đối tượng được báo cáo là rò rỉ bộ nhớ.

Hạn chế và nhược điểm
-------------------------

Hạn chế chính là giảm hiệu suất phân bổ bộ nhớ và
giải phóng. Để tránh các hình phạt khác, việc quét bộ nhớ chỉ được thực hiện
khi tệp /sys/kernel/debug/kmemleak được đọc. Dù sao thì công cụ này cũng
dành cho mục đích gỡ lỗi trong đó hiệu suất có thể không phải là
yêu cầu quan trọng nhất.

Để giữ cho thuật toán đơn giản, kmemleak quét các giá trị trỏ đến bất kỳ
địa chỉ bên trong phạm vi địa chỉ của một khối. Điều này có thể dẫn tới sự gia tăng
số lượng âm tính giả. Tuy nhiên, có khả năng rò rỉ bộ nhớ thực
cuối cùng sẽ trở nên hữu hình.

Một nguồn âm tính giả khác là dữ liệu được lưu trữ ở dạng không phải con trỏ
các giá trị. Trong phiên bản tương lai, kmemleak chỉ có thể quét con trỏ
thành viên trong cơ cấu được phân công. Tính năng này sẽ giải quyết được nhiều
các trường hợp âm tính giả được mô tả ở trên.

Công cụ này có thể báo cáo kết quả dương tính giả. Đây là những trường hợp được phân bổ
khối không cần phải được giải phóng (một số trường hợp trong hàm init_call),
con trỏ được tính bằng các phương thức khác ngoài container_of thông thường
macro hoặc con trỏ được lưu trữ ở vị trí không được kmemleak quét.

Phân bổ trang và ioremap không được theo dõi.

Kiểm tra bằng kmemleak-test
--------------------------

Để kiểm tra xem bạn đã thiết lập xong để sử dụng kmemleak chưa, bạn có thể sử dụng kmemleak-test
module, một mô-đun cố tình làm rò rỉ bộ nhớ. Đặt CONFIG_SAMPLE_KMEMLEAK
làm mô-đun (không thể sử dụng nó làm mô-đun tích hợp) và khởi động kernel bằng kmemleak
đã bật. Tải mô-đun và thực hiện quét bằng::

Kiểm tra rò rỉ km # modprobe
        Quét # echo > /sys/kernel/debug/kmemleak

Lưu ý rằng bạn có thể không nhận được kết quả ngay lập tức hoặc trong lần quét đầu tiên. Khi nào
kmemleak nhận được kết quả, nó sẽ ghi lại ZZ0000ZZ. Sau đó đọc file để xem rồi::

# cat/sys/kernel/gỡ lỗi/kmemleak
        đối tượng không được tham chiếu 0xffff89862ca702e8 (kích thước 32):
          comm "modprobe", pid 2088, jiffies 4294680594 (tuổi 375.486)
          kết xuất hex (32 byte đầu tiên):
            6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b kkkkkkkkkkkkkk
            6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5 kkkkkkkkkkkkk.
          quay lại:
            [<00000000e0a73ec7>] 0xffffffffc01d2036
            [<000000000c5d2a46>] do_one_initcall+0x41/0x1df
            [<0000000046db7e0a>] do_init_module+0x55/0x200
            [<00000000542b9814>] tải_module+0x203c/0x2480
            [<00000000c2850256>] __do_sys_finit_module+0xba/0xe0
            [<000000006564e7ef>] do_syscall_64+0x43/0x110
            [<000000007c873fa6>] entry_SYSCALL_64_after_hwframe+0x44/0xa9
        ...

Việc tháo mô-đun bằng ZZ0000ZZ cũng sẽ kích hoạt một số
kết quả kmleak.
