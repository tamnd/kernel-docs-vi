.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/printk-index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============
Chỉ mục Printk
==============

Có nhiều cách để theo dõi trạng thái của hệ thống. Một điều quan trọng
nguồn thông tin là nhật ký hệ thống. Nó cung cấp rất nhiều thông tin,
bao gồm ít nhiều cảnh báo quan trọng và thông báo lỗi.

Có các công cụ giám sát lọc và thực hiện hành động dựa trên tin nhắn
đã đăng nhập.

Các thông báo kernel đang phát triển cùng với mã. Kết quả là,
các thông báo kernel cụ thể không phải là KABI và sẽ không bao giờ như vậy!

Đó là một thách thức lớn đối với việc duy trì màn hình nhật ký hệ thống. Nó đòi hỏi
biết thông báo nào đã được cập nhật trong phiên bản kernel cụ thể và tại sao.
Việc tìm kiếm những thay đổi này trong các nguồn sẽ yêu cầu các trình phân tích cú pháp không tầm thường.
Ngoài ra, nó sẽ yêu cầu kết hợp các nguồn với hạt nhân nhị phân.
không phải lúc nào cũng tầm thường. Những thay đổi khác nhau có thể được nhập lại. Hạt nhân khác nhau
các phiên bản có thể được sử dụng trên các hệ thống được giám sát khác nhau.

Đây là lúc tính năng chỉ mục printk có thể trở nên hữu ích. Nó cung cấp
một tập hợp các định dạng printk được sử dụng trên toàn bộ mã nguồn được sử dụng cho kernel
và các module trên hệ thống đang chạy. Nó có thể truy cập được trong thời gian chạy thông qua debugfs.

Chỉ mục printk giúp tìm những thay đổi trong định dạng tin nhắn. Ngoài ra nó còn giúp
để theo dõi các chuỗi trở lại nguồn kernel và cam kết liên quan.


Giao diện người dùng
==============

Chỉ mục của các định dạng printk được chia thành các tệp riêng biệt. Các tập tin là
được đặt tên theo các tệp nhị phân nơi các định dạng printk được tích hợp sẵn. Ở đó
luôn là "vmlinux" và các mô-đun tùy chọn, ví dụ::

/sys/kernel/gỡ lỗi/printk/index/vmlinux
   /sys/kernel/gỡ lỗi/printk/index/ext4
   /sys/kernel/gỡ lỗi/printk/index/scsi_mod

Lưu ý rằng chỉ các mô-đun đã tải mới được hiển thị. Đồng thời in các định dạng từ một mô-đun
có thể xuất hiện trong "vmlinux" khi mô-đun được tích hợp sẵn.

Nội dung được lấy cảm hứng từ giao diện gỡ lỗi động và trông giống như ::

$> head -1 /sys/kernel/debug/printk/index/vmlinux; shuf -n 5 vmlinux
   # <level[,flags]> tên tập tin: hàm dòng "định dạng"
   <5> block/blk-settings.c:661 disk_stack_limits "%s: Cảnh báo: Thiết bị %s bị căn chỉnh sai\n"
   <4> kernel/trace/trace.c:8296 trace_create_file "Không thể tạo mục nhập '%s' tracefs\n"
   <6> Arch/x86/kernel/hpet.c:144 _hpet_print_config "hpet: %s(%d):\n"
   <6> init/do_mounts.c:605 prepare_namespace "Đang chờ thiết bị gốc %s...\n"
   <6> driver/acpi/osl.c:1410 acpi_no_auto_serialize_setup "ACPI: tính năng tự động tuần tự hóa bị tắt\n"

, ý nghĩa là:

- :level: giá trị mức nhật ký: 0-7 cho mức độ nghiêm trọng cụ thể, -1 làm mặc định,
	'c' dưới dạng dòng liên tục không có mức nhật ký rõ ràng
   - :flags: cờ tùy chọn: hiện tại chỉ có 'c' cho KERN_CONT
   - :filename\:line: tên file nguồn và số dòng liên quan
	lệnh gọi printk(). Lưu ý rằng có nhiều hàm bao, ví dụ:
	pr_warn(), pr_warn_once(), dev_warn().
   - :function: tên hàm nơi lệnh gọi printk() được sử dụng.
   - :format: chuỗi định dạng

Thông tin bổ sung khiến việc tìm ra sự khác biệt khó hơn một chút
giữa các hạt nhân khác nhau. Đặc biệt số dòng có thể thay đổi
rất thường xuyên. Mặt khác, nó giúp ích rất nhiều trong việc xác nhận rằng
đó là cùng một chuỗi hoặc tìm cam kết chịu trách nhiệm
cho những thay đổi cuối cùng.


printk() Không phải là KABI ổn định
=============================

Một số nhà phát triển lo ngại rằng việc xuất tất cả những triển khai này
chi tiết vào không gian người dùng sẽ chuyển đổi các lệnh gọi printk() cụ thể
vào KABI.

Nhưng nó hoàn toàn ngược lại. lệnh gọi printk() phải _not_ là KABI.
Và chỉ mục printk giúp các công cụ không gian của người dùng giải quyết vấn đề này.


Trình bao bọc printk cụ thể của hệ thống con
==================================

Chỉ mục printk được tạo bằng siêu dữ liệu bổ sung được lưu trữ trong
một phần .elf dành riêng ".printk_index". Nó đạt được bằng cách sử dụng macro
các trình bao bọc thực hiện __printk_index_emit() cùng với printk() thực
gọi. Kỹ thuật tương tự cũng được sử dụng cho siêu dữ liệu được sử dụng bởi
tính năng gỡ lỗi động.

Siêu dữ liệu chỉ được lưu trữ cho một tin nhắn cụ thể khi nó được in
bằng cách sử dụng các giấy gói đặc biệt này. Nó được thực hiện cho mục đích chung
đã sử dụng lệnh gọi printk(), bao gồm, chẳng hạn như pr_warn() hoặc pr_once().

Những thay đổi bổ sung là cần thiết cho các trình bao bọc cụ thể của hệ thống con khác nhau
gọi printk() ban đầu thông qua một hàm trợ giúp chung. Những nhu cầu này
trình bao bọc riêng của họ thêm __printk_index_emit().

Cho đến nay, chỉ có một số trình bao bọc cụ thể của hệ thống con được cập nhật,
ví dụ: dev_printk(). Kết quả là, các định dạng printk từ
một số hệ thống con có thể bị thiếu trong chỉ mục printk.


Tiền tố cụ thể của hệ thống con
=========================

Macro pr_fmt() cho phép xác định tiền tố được in
trước chuỗi được tạo bởi lệnh gọi printk() liên quan.

Các trình bao bọc cụ thể của hệ thống con thường thậm chí còn phức tạp hơn
tiền tố.

Các tiền tố này có thể được lưu trữ vào siêu dữ liệu chỉ mục printk
bằng tham số tùy chọn __printk_index_emit(). Các bản gỡ lỗi
giao diện sau đó có thể hiển thị các định dạng printk bao gồm các tiền tố này.
Ví dụ: driver/acpi/osl.c chứa::

#define pr_fmt(fmt) "ACPI: OSL: " fmt

int tĩnh __init acpi_no_auto_serialize_setup(char *str)
  {
	acpi_gbl_auto_serialize_methods = FALSE;
	pr_info("Tự động tuần tự hóa đã bị tắt\n");

trả về 1;
  }

Điều này dẫn đến mục nhập chỉ mục printk sau::

<6> driver/acpi/osl.c:1410 acpi_no_auto_serialize_setup "ACPI: tính năng tự động tuần tự hóa bị tắt\n"

Nó giúp khớp các tin nhắn từ nhật ký thực với chỉ mục printk.
Sau đó, tên tệp nguồn, số dòng và tên hàm có thể
được sử dụng để khớp chuỗi với mã nguồn.