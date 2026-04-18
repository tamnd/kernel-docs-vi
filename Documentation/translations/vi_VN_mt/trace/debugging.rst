.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/debugging.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================
Sử dụng công cụ theo dõi để gỡ lỗi
==================================

Bản quyền 2024 Google LLC.

:Tác giả: Steven Rostedt <rostedt@goodmis.org>
:Giấy phép: Giấy phép Tài liệu Miễn phí GNU, Phiên bản 1.2
          (được cấp phép kép theo GPL v2)

- Viết cho: 6.12

Giới thiệu
------------
Cơ sở hạ tầng theo dõi có thể rất hữu ích cho việc gỡ lỗi Linux
hạt nhân. Tài liệu này là nơi bổ sung thêm các phương pháp sử dụng công cụ theo dõi khác nhau
để gỡ lỗi.

Trước tiên, hãy đảm bảo rằng hệ thống tệp tracefs được gắn kết::

$ sudo mount -t tracefs tracefs/sys/kernel/tracing


Sử dụng trace_printk()
----------------------

trace_printk() là một tiện ích rất nhẹ có thể được sử dụng trong mọi ngữ cảnh
bên trong kernel, ngoại trừ phần "noinstr". Nó có thể được sử dụng
trong bối cảnh bình thường, softirq, ngắt và thậm chí NMI. Dữ liệu theo dõi là
được ghi vào bộ đệm vòng theo dõi theo cách không khóa. Để làm cho nó thậm chí
trọng lượng nhẹ hơn, khi có thể, nó sẽ chỉ ghi con trỏ theo định dạng
chuỗi và lưu các đối số thô vào bộ đệm. Định dạng và
các đối số sẽ được xử lý sau khi đọc bộ đệm vòng. Bằng cách này
chuyển đổi định dạng trace_printk() không được thực hiện trong đường dẫn nóng, trong đó
dấu vết đang được ghi lại.

trace_printk() chỉ nhằm mục đích gỡ lỗi và không bao giờ được thêm vào
một hệ thống con của hạt nhân. Nếu bạn cần gỡ lỗi dấu vết, hãy thêm sự kiện theo dõi
thay vào đó. Nếu tìm thấy trace_printk() trong kernel, thao tác sau sẽ
xuất hiện trong dmesg::

*************************************************************
  ZZ0000ZZ
  ZZ0001ZZ
  ZZ0002ZZ
  ZZ0003ZZ
  ZZ0004ZZ
  ZZ0005ZZ
  ZZ0006ZZ
  ZZ0007ZZ
  ZZ0008ZZ
  ZZ0009ZZ
  ZZ0010ZZ
  *************************************************************

Gỡ lỗi sự cố kernel
------------------------
Có nhiều phương pháp khác nhau để thu được trạng thái của hệ thống khi một kernel
sự cố xảy ra. Điều này có thể là từ thông báo rất tiếc trong printk, hoặc người ta có thể
sử dụng kexec/kdump. Nhưng những điều này chỉ cho thấy những gì đã xảy ra vào thời điểm xảy ra vụ tai nạn.
Nó có thể rất hữu ích trong việc biết điều gì đã xảy ra cho đến thời điểm xảy ra vụ tai nạn.
Bộ đệm vòng theo dõi, theo mặc định, là bộ đệm tròn sẽ
ghi đè các sự kiện cũ hơn bằng những sự kiện mới hơn. Khi xảy ra sự cố, nội dung của
bộ đệm vòng sẽ là tất cả các sự kiện dẫn đến sự cố.

Có một số tham số dòng lệnh kernel có thể được sử dụng để trợ giúp
cái này. Đầu tiên là "ftrace_dump_on_oops". Điều này sẽ đổ vòng truy tìm
đệm khi có lỗi xảy ra với bảng điều khiển. Điều này có thể hữu ích nếu bảng điều khiển
đang được ghi lại ở đâu đó. Nếu sử dụng bảng điều khiển nối tiếp, có thể nên thận trọng
đảm bảo bộ đệm vòng tương đối nhỏ, nếu không việc bán phá giá
bộ đệm vòng có thể mất vài phút đến vài giờ để hoàn thành. Đây là một ví dụ
của dòng lệnh kernel::

ftrace_dump_on_oops trace_buf_size=50K

Lưu ý, bộ đệm theo dõi được tạo thành từ mỗi bộ đệm CPU trong đó mỗi bộ đệm này
bộ đệm được chia thành các bộ đệm phụ theo mặc định là PAGE_SIZE. các
Tùy chọn trace_buf_size ở trên đặt mỗi bộ đệm trên mỗi CPU thành 50K,
vì vậy, trên một máy có 8 CPU, tổng số đó thực sự là 400K.

Bộ đệm liên tục trên giày
-------------------------------
Nếu bộ nhớ hệ thống cho phép, bộ đệm vòng theo dõi có thể được chỉ định tại
một vị trí cụ thể trong bộ nhớ. Nếu vị trí trên ủng và
bộ nhớ không bị sửa đổi, bộ đệm theo dõi có thể được lấy từ
khởi động sau. Có hai cách để dự trữ bộ nhớ cho việc sử dụng vòng
bộ đệm.

Cách đáng tin cậy hơn (trên x86) là dự trữ bộ nhớ bằng kernel "memmap"
tùy chọn dòng lệnh và sau đó sử dụng bộ nhớ đó cho trace_instance. Cái này
đòi hỏi một chút kiến thức về cách bố trí bộ nhớ vật lý của hệ thống. các
Ưu điểm của việc sử dụng phương pháp này là bộ nhớ dành cho bộ đệm vòng sẽ
luôn như vậy::

memmap==12M$0x284500000 trace_instance=boot_map@0x284500000:12M

Bản ghi nhớ ở trên dự trữ 12 megabyte bộ nhớ ở bộ nhớ vật lý
vị trí 0x284500000. Sau đó tùy chọn trace_instance sẽ tạo dấu vết
ví dụ "boot_map" tại cùng một vị trí với cùng dung lượng bộ nhớ
dành riêng. Khi bộ đệm vòng được chia thành các bộ đệm CPU, 12
megabyte sẽ được chia đều cho các CPU đó. Nếu bạn có 8 CPU,
mỗi bộ đệm vòng CPU sẽ có kích thước 1,5 megabyte. Lưu ý, điều đó cũng
bao gồm dữ liệu meta, do đó dung lượng bộ nhớ thực sự được sử dụng bởi bộ đệm vòng
sẽ nhỏ hơn một chút.

Một cách khác chung chung hơn nhưng kém hiệu quả hơn để phân bổ ánh xạ bộ đệm vòng
lúc khởi động có tùy chọn "reserve_mem" ::

dự trữ_mem=12M:4096:trace trace_instance=boot_map@trace

Tùy chọn dự trữ_mem ở trên sẽ tìm thấy 12 megabyte có sẵn tại
khởi động và căn chỉnh nó theo 4096 byte. Nó sẽ gắn nhãn bộ nhớ này là "dấu vết"
có thể được sử dụng bởi các tùy chọn dòng lệnh sau này.

Tùy chọn trace_instance tạo một phiên bản "boot_map" và sẽ sử dụng
bộ nhớ được dành riêng bởi Reserve_mem được gắn nhãn là "dấu vết". Phương pháp này là
chung chung hơn nhưng có thể không đáng tin cậy. Do KASLR, bộ nhớ được dành riêng
bởi Reserve_mem có thể không được đặt ở cùng một vị trí. Nếu điều này xảy ra,
khi đó bộ đệm vòng sẽ không còn từ lần khởi động trước đó và sẽ được đặt lại.

Đôi khi, bằng cách sử dụng căn chỉnh lớn hơn, nó có thể ngăn KASLR di chuyển mọi thứ
xung quanh theo cách nó sẽ di chuyển vị trí của Reserve_mem. Bởi
bằng cách căn chỉnh lớn hơn, bạn có thể thấy bộ đệm nhiều hơn
phù hợp với nơi nó được đặt::

dự trữ_mem=12M:0x2000000:trace trace_instance=boot_map@trace

Khi khởi động, bộ nhớ dành riêng cho bộ đệm vòng được xác thực. Nó sẽ đi
thông qua một loạt các thử nghiệm để đảm bảo rằng bộ đệm vòng chứa hợp lệ
dữ liệu. Nếu đúng như vậy thì nó sẽ thiết lập nó để có thể đọc được từ
ví dụ. Nếu nó thất bại trong bất kỳ thử nghiệm nào, nó sẽ xóa toàn bộ bộ đệm vòng
và khởi tạo nó như mới.

Bố cục của bộ nhớ được ánh xạ này có thể không nhất quán từ kernel này sang kernel khác.
kernel, do đó chỉ có cùng một kernel được đảm bảo hoạt động nếu ánh xạ
được bảo tồn. Chuyển sang phiên bản kernel khác có thể tìm thấy một phiên bản khác
bố cục và đánh dấu bộ đệm là không hợp lệ.

Lưu ý: Cả địa chỉ và kích thước được ánh xạ phải được căn chỉnh theo trang cho kiến ​​trúc.

Sử dụng trace_printk() trong phiên bản khởi động
------------------------------------------------
Theo mặc định, nội dung của trace_printk() được đưa vào truy tìm cấp cao nhất
ví dụ. Nhưng trường hợp này không bao giờ được bảo tồn trên các bốt. Để có
nội dung trace_printk() và một số dấu vết nội bộ khác sẽ được chuyển đến phần được bảo tồn
bộ đệm (như ngăn xếp kết xuất), hoặc đặt phiên bản thành trace_printk()
đích từ dòng lệnh kernel hoặc thiết lập nó sau khi khởi động thông qua
tùy chọn trace_printk_dest.

Sau khi khởi động::

echo 1 > /sys/kernel/tracing/instances/boot_map/options/trace_printk_dest

Từ dòng lệnh kernel ::

dự trữ_mem=12M:4096:trace trace_instance=boot_map^traceprintk^traceoff@trace

Nếu cài đặt nó từ dòng lệnh kernel, bạn cũng nên
tắt tính năng theo dõi bằng cờ "theo dõi" và bật tính năng theo dõi sau khi khởi động.
Nếu không, dấu vết từ lần khởi động gần đây nhất sẽ bị trộn lẫn với dấu vết
từ lần khởi động trước và có thể gây khó hiểu khi đọc.

Sử dụng phiên bản sao lưu để giữ dữ liệu khởi động trước đó
-----------------------------------------------------------

Cũng có thể ghi lại dữ liệu theo dõi lúc khởi động hệ thống bằng cách chỉ định
các sự kiện với bộ đệm vòng liên tục, nhưng trong trường hợp này dữ liệu trước
việc khởi động lại sẽ bị mất trước khi có thể đọc được. Vấn đề này có thể được giải quyết bằng một
trường hợp dự phòng. Từ dòng lệnh kernel ::

dự trữ_mem=12M:4096:trace trace_instance=boot_map@trace,sched,irq trace_instance=backup=boot_map

Khi khởi động, dữ liệu trước đó trong "boot_map" sẽ được sao chép vào "bản sao lưu"
instance và các sự kiện "scheduled:ZZ0000ZZ" cho lần khởi động hiện tại được theo dõi
trong "boot_map". Do đó người dùng có thể đọc dữ liệu khởi động trước đó từ bản "sao lưu"
trường hợp mà không dừng dấu vết.

Lưu ý rằng phiên bản "sao lưu" này ở chế độ chỉ đọc và sẽ tự động bị xóa
nếu bạn xóa dữ liệu theo dõi hoặc đọc tất cả dữ liệu theo dõi từ "trace_pipe"
hoặc tệp "trace_pipe_raw".
