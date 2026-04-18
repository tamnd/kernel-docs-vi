.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/memory-hotplug.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _memory_hotplug:

================
Cắm nóng bộ nhớ
================

Trình thông báo sự kiện cắm nóng bộ nhớ
=======================================

Các sự kiện cắm nóng được gửi đến hàng đợi thông báo.

Trình thông báo bộ nhớ
----------------------

Có sáu loại thông báo được xác định trong ZZ0000ZZ:

MEM_GOING_ONLINE
  Được tạo trước khi có bộ nhớ mới để có thể
  chuẩn bị các hệ thống con để xử lý bộ nhớ. Trình cấp phát trang vẫn không thể
  để phân bổ từ bộ nhớ mới.

MEM_CANCEL_ONLINE
  Được tạo nếu MEM_GOING_ONLINE bị lỗi.

MEM_ONLINE
  Được tạo khi bộ nhớ đã trực tuyến thành công. Cuộc gọi lại có thể
  phân bổ các trang từ bộ nhớ mới.

MEM_GOING_OFFLINE
  Được tạo để bắt đầu quá trình ngoại tuyến bộ nhớ. Phân bổ là không
  có thể sử dụng bộ nhớ lâu hơn nhưng một số bộ nhớ sẽ bị ngoại tuyến
  vẫn đang được sử dụng. Cuộc gọi lại có thể được sử dụng để giải phóng bộ nhớ đã biết cho một
  hệ thống con từ khối bộ nhớ được chỉ định.

MEM_CANCEL_OFFLINE
  Được tạo nếu MEM_GOING_OFFLINE bị lỗi. Bộ nhớ có sẵn trở lại từ
  khối bộ nhớ mà chúng tôi đã cố gắng ngoại tuyến.

MEM_OFFLINE
  Được tạo sau khi bộ nhớ ngoại tuyến hoàn tất.

Một thói quen gọi lại có thể được đăng ký bằng cách gọi::

hotplug_memory_notifier(callback_func, mức độ ưu tiên)

Các hàm gọi lại có giá trị ưu tiên cao hơn được gọi trước khi gọi lại
hàm có giá trị thấp hơn.

Hàm gọi lại phải có nguyên mẫu sau::

int gọi lại_func(
    struct notifier_block *self, unsigned long action, void *arg);

Đối số đầu tiên của hàm gọi lại (self) là một con trỏ tới khối
của chuỗi thông báo trỏ đến chính chức năng gọi lại.
Đối số thứ hai (hành động) là một trong các loại sự kiện được mô tả ở trên.
Đối số thứ ba (arg) truyền một con trỏ của struct Memory_notify::

cấu trúc bộ nhớ_notify {
		start_pfn dài không dấu;
		nr_page dài không dấu;
	}

- start_pfn là start_pfn của bộ nhớ trực tuyến/ngoại tuyến.
- nr_pages là các trang # of của bộ nhớ trực tuyến/ngoại tuyến.

Có thể nhận được thông báo cho MEM_CANCEL_ONLINE mà không cần thông báo
đối với MEM_GOING_ONLINE, và điều tương tự cũng áp dụng cho MEM_CANCEL_OFFLINE và
MEM_GOING_OFFLINE.
Điều này có thể xảy ra khi người tiêu dùng thất bại, nghĩa là chúng tôi phá vỡ chuỗi cuộc gọi và chúng tôi
ngừng gọi cho những người tiêu dùng còn lại của người thông báo.
Điều quan trọng là người dùng Memory_notify không đưa ra giả định nào và nhận được
sẵn sàng xử lý những trường hợp như vậy.

Thói quen gọi lại sẽ trả về một trong các giá trị
NOTIFY_DONE, NOTIFY_OK, NOTIFY_BAD, NOTIFY_STOP
được định nghĩa trong ZZ0000ZZ

NOTIFY_DONE và NOTIFY_OK không ảnh hưởng đến quá trình xử lý tiếp theo.

NOTIFY_BAD được sử dụng để đáp ứng với MEM_GOING_ONLINE, MEM_GOING_OFFLINE,
Hành động MEM_ONLINE hoặc MEM_OFFLINE để hủy việc cắm nóng. Nó dừng lại
xử lý thêm hàng đợi thông báo.

NOTIFY_STOP dừng xử lý thêm hàng đợi thông báo.

Trình thông báo nút Numa
------------------------

Có sáu loại thông báo được xác định trong ZZ0000ZZ:

NODE_ADDING_FIRST_MEMORY
 Được tạo trước khi bộ nhớ có sẵn cho nút này lần đầu tiên.

NODE_CANCEL_ADDING_FIRST_MEMORY
 Được tạo nếu NODE_ADDING_FIRST_MEMORY bị lỗi.

NODE_ADDED_FIRST_MEMORY
 Được tạo khi bộ nhớ có sẵn cho nút này lần đầu tiên.

NODE_REMOVING_LAST_MEMORY
 Được tạo khi bộ nhớ cuối cùng còn trống cho nút này sắp ngoại tuyến.

NODE_CANCEL_REMOVING_LAST_MEMORY
 Được tạo khi NODE_CANCEL_REMOVING_LAST_MEMORY bị lỗi.

NODE_REMOVED_LAST_MEMORY
 Được tạo khi bộ nhớ cuối cùng có sẵn cho nút này đã ngoại tuyến.

Một thói quen gọi lại có thể được đăng ký bằng cách gọi::

hotplug_node_notifier(callback_func, mức độ ưu tiên)

Các hàm gọi lại có giá trị ưu tiên cao hơn được gọi trước khi gọi lại
hàm có giá trị thấp hơn.

Hàm gọi lại phải có nguyên mẫu sau::

int gọi lại_func(

struct notifier_block *self, unsigned long action, void *arg);

Đối số đầu tiên của hàm gọi lại (self) là một con trỏ tới khối
của chuỗi thông báo trỏ đến chính chức năng gọi lại.
Đối số thứ hai (hành động) là một trong các loại sự kiện được mô tả ở trên.
Đối số thứ ba (arg) truyền một con trỏ của struct node_notify::

cấu trúc nút_notify {
                int nid;
        }

- nid là nút chúng ta đang thêm hoặc xóa bộ nhớ.

Có thể nhận thông báo về NODE_CANCEL_ADDING_FIRST_MEMORY mà không cần
đã được thông báo về NODE_ADDING_FIRST_MEMORY và điều tương tự cũng áp dụng cho
NODE_CANCEL_REMOVING_LAST_MEMORY và NODE_REMOVING_LAST_MEMORY.
Điều này có thể xảy ra khi người tiêu dùng thất bại, nghĩa là chúng tôi phá vỡ chuỗi cuộc gọi và chúng tôi
ngừng gọi cho những người tiêu dùng còn lại của người thông báo.
Điều quan trọng là người dùng node_notify không đưa ra giả định nào và nhận được
sẵn sàng xử lý những trường hợp như vậy.

Thói quen gọi lại sẽ trả về một trong các giá trị
NOTIFY_DONE, NOTIFY_OK, NOTIFY_BAD, NOTIFY_STOP
được định nghĩa trong ZZ0000ZZ

NOTIFY_DONE và NOTIFY_OK không ảnh hưởng đến quá trình xử lý tiếp theo.

NOTIFY_BAD được sử dụng làm phản hồi cho NODE_ADDING_FIRST_MEMORY,
NODE_REMOVING_LAST_MEMORY, NODE_ADDED_FIRST_MEMORY hoặc
Hành động NODE_REMOVED_LAST_MEMORY để hủy việc cắm nóng.
Nó dừng xử lý thêm hàng đợi thông báo.

NOTIFY_STOP dừng xử lý thêm hàng đợi thông báo.

Xin lưu ý rằng chúng tôi không nên thất bại đối với NODE_ADDED_FIRST_MEMORY /
NODE_REMOVED_FIRST_MEMORY, vì mã Memory_hotplug không thể khôi phục tại thời điểm đó
điểm nữa.

Khóa bên trong
=================

Khi thêm/xóa bộ nhớ sử dụng các thiết bị khối bộ nhớ (tức là RAM thông thường),
device_hotplug_lock phải được giữ ở:

- đồng bộ hóa theo yêu cầu trực tuyến/ngoại tuyến (ví dụ: qua sysfs). Bằng cách này, trí nhớ
  người dùng chỉ có thể truy cập các thiết bị chặn (thuộc tính .online/.state)
  không gian sau khi bộ nhớ đã được thêm đầy đủ. Và khi loại bỏ bộ nhớ, chúng tôi
  biết không có ai ở khu vực quan trọng.
- đồng bộ hóa với hotplug CPU và tương tự (ví dụ: có liên quan đến ACPI và PPC)

Đặc biệt, có thể tránh được tình trạng đảo ngược khóa khi sử dụng
device_hotplug_lock khi thêm bộ nhớ và dung lượng người dùng cố gắng trực tuyến
bộ nhớ nhanh hơn dự kiến:

- device_online() đầu tiên sẽ lấy device_lock(), tiếp theo là
  mem_hotplug_lock
- add_memory_resource() trước tiên sẽ lấy mem_hotplug_lock, sau đó là
  device_lock() (trong khi tạo thiết bị, trong bus_add_device()).

Vì thiết bị hiển thị với không gian người dùng trước khi sử dụng device_lock(), điều này
có thể dẫn đến đảo ngược khóa.

việc trực tuyến/ngoại tuyến bộ nhớ phải được thực hiện thông qua device_online()/
device_offline() - để đảm bảo nó được đồng bộ hóa đúng cách với các hành động
thông qua sysfs. Nên giữ device_hotplug_lock (ví dụ: bảo vệ online_type)

Khi thêm/xóa/trực tuyến/ngoại tuyến bộ nhớ hoặc thêm/xóa bộ nhớ
bộ nhớ thiết bị/không đồng nhất, chúng ta phải luôn giữ mem_hotplug_lock trong
chế độ ghi để nối tiếp các hotplug bộ nhớ (ví dụ: truy cập vào toàn cầu/vùng
biến).

Ngoài ra, mem_hotplug_lock (ngược lại với device_hotplug_lock) trong read
chế độ cho phép get_online_mems/put_online_mems khá hiệu quả
triển khai, do đó mã truy cập bộ nhớ có thể bảo vệ khỏi bộ nhớ đó
biến mất.
