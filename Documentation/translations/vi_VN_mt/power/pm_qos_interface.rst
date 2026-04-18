.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/power/pm_qos_interface.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==================================
Giao diện chất lượng dịch vụ của PM
===============================

Giao diện này cung cấp kernel và giao diện chế độ người dùng để đăng ký
kỳ vọng về hiệu suất của trình điều khiển, hệ thống con và ứng dụng không gian người dùng trên
một trong các tham số.

Có sẵn hai khung PM QoS khác nhau:
 * QoS độ trễ CPU.
 * Khung PM QoS trên mỗi thiết bị cung cấp API để quản lý
   hạn chế về độ trễ trên mỗi thiết bị và cờ PM QoS.

Đơn vị độ trễ được sử dụng trong khung PM QoS là micro giây (usec).


1. Khung QoS PM
===================

Danh sách toàn cầu các yêu cầu QoS độ trễ CPU được duy trì cùng với danh sách tổng hợp
(hiệu quả) giá trị mục tiêu.  Giá trị mục tiêu tổng hợp được cập nhật với những thay đổi
vào danh sách yêu cầu hoặc các thành phần của danh sách.  Đối với QoS độ trễ CPU,
giá trị mục tiêu tổng hợp chỉ đơn giản là giá trị tối thiểu của các giá trị yêu cầu được giữ trong danh sách
các phần tử.

Lưu ý: giá trị mục tiêu tổng hợp được triển khai dưới dạng biến nguyên tử sao cho
đọc giá trị tổng hợp không yêu cầu bất kỳ cơ chế khóa nào.

Từ không gian kernel, việc sử dụng giao diện này rất đơn giản:

void cpu_latency_qos_add_request(xử lý, target_value):
  Sẽ chèn một phần tử vào danh sách QoS độ trễ CPU với giá trị mục tiêu.
  Khi thay đổi danh sách này, mục tiêu mới sẽ được tính toán lại và mọi thông tin đã đăng ký
  trình thông báo chỉ được gọi nếu giá trị đích bây giờ khác.
  Khách hàng của PM QoS cần lưu lại tay cầm được trả về để sử dụng trong tương lai
  Chức năng PM QoS API.

void cpu_latency_qos_update_request(xử lý, new_target_value):
  Sẽ cập nhật phần tử danh sách được trỏ bởi phần điều khiển với mục tiêu mới
  giá trị và tính toán lại mục tiêu tổng hợp mới, gọi cây thông báo
  nếu mục tiêu thay đổi.

void cpu_latency_qos_remove_request(xử lý):
  Sẽ loại bỏ phần tử.  Sau khi xóa nó sẽ cập nhật mục tiêu tổng hợp
  và gọi cây thông báo nếu mục tiêu bị thay đổi do
  loại bỏ yêu cầu.

int cpu_latency_qos_limit():
  Trả về giá trị tổng hợp cho QoS độ trễ CPU.

int cpu_latency_qos_request_active(xử lý):
  Trả về nếu yêu cầu vẫn còn hoạt động, tức là nó chưa bị xóa khỏi
  Danh sách QoS độ trễ CPU.


Từ không gian người dùng:

Cơ sở hạ tầng hiển thị hai nút thiết bị riêng biệt, /dev/cpu_dma_latency cho
QoS độ trễ CPU và /dev/cpu_wakeup_latency để đánh thức hệ thống CPU
QoS độ trễ.

Chỉ các tiến trình mới có thể đăng ký yêu cầu PM QoS.  Để cung cấp cho tự động
dọn dẹp một tiến trình, giao diện yêu cầu tiến trình đó đăng ký
yêu cầu tham số như sau.

Để đăng ký mục tiêu PM QoS mặc định cho QoS độ trễ CPU, quy trình phải
mở /dev/cpu_dma_latency.  Để đăng ký giới hạn QoS đánh thức hệ thống CPU,
quá trình phải mở /dev/cpu_wakeup_latency.

Miễn là nút thiết bị được giữ mở thì quá trình đó có đăng ký
yêu cầu về tham số.

Để thay đổi giá trị đích được yêu cầu, quy trình cần ghi giá trị s32 vào
nút thiết bị mở.  Ngoài ra, nó có thể viết một chuỗi hex cho giá trị
sử dụng định dạng dài 10 char, ví dụ: "0x12345678".

Để xóa yêu cầu chế độ người dùng cho giá trị mục tiêu, chỉ cần đóng thiết bị
nút.


2. Khung cờ và độ trễ PM QoS trên mỗi thiết bị
================================================

Đối với mỗi thiết bị, có ba danh sách yêu cầu PM QoS. Hai trong số đó là
được duy trì cùng với các mục tiêu tổng hợp về độ trễ tiếp tục và hoạt động
dung sai độ trễ trạng thái (tính bằng micro giây) và mức thứ ba dành cho cờ PM QoS.
Các giá trị được cập nhật để đáp ứng với những thay đổi của danh sách yêu cầu.

Các giá trị mục tiêu của độ trễ tiếp tục và dung sai độ trễ trạng thái hoạt động là
chỉ đơn giản là giá trị yêu cầu tối thiểu được giữ trong các thành phần danh sách tham số.
Giá trị tổng hợp của cờ PM QoS là tập hợp (bitwise OR) của tất cả các thành phần danh sách'
các giá trị.  Cờ PM QoS của một thiết bị hiện được xác định: PM_QOS_FLAG_NO_POWER_OFF.

Lưu ý: Các giá trị mục tiêu tổng hợp được triển khai theo cách mà việc đọc
giá trị tổng hợp không yêu cầu bất kỳ cơ chế khóa nào.


Từ chế độ kernel, việc sử dụng giao diện này như sau:

int dev_pm_qos_add_request(thiết bị, tay cầm, loại, giá trị):
  Sẽ chèn một phần tử vào danh sách cho thiết bị được xác định đó bằng
  giá trị mục tiêu.  Khi thay đổi danh sách này, mục tiêu mới sẽ được tính toán lại và mọi
  thông báo đã đăng ký chỉ được gọi nếu giá trị đích bây giờ khác.
  Khách hàng của dev_pm_qos cần lưu lại mã điều khiển để sử dụng sau này ở các ứng dụng khác
  hàm dev_pm_qos API.

int dev_pm_qos_update_request(xử lý, new_value):
  Sẽ cập nhật phần tử danh sách được trỏ bởi phần điều khiển với mục tiêu mới
  giá trị và tính toán lại mục tiêu tổng hợp mới, gọi thông báo
  cây nếu mục tiêu thay đổi.

int dev_pm_qos_remove_request(xử lý):
  Sẽ loại bỏ phần tử.  Sau khi xóa nó sẽ cập nhật mục tiêu tổng hợp
  và gọi cây thông báo nếu mục tiêu bị thay đổi do
  loại bỏ yêu cầu.

s32 dev_pm_qos_read_value(thiết bị, loại):
  Trả về giá trị tổng hợp cho danh sách ràng buộc của một thiết bị nhất định.

enum pm_qos_flags_status dev_pm_qos_flags(thiết bị, mặt nạ)
  Kiểm tra cờ PM QoS của thiết bị nhất định dựa trên mặt nạ cờ đã cho.
  Ý nghĩa của các giá trị trả về như sau:

PM_QOS_FLAGS_ALL:
		Tất cả các cờ từ mặt nạ được đặt
	PM_QOS_FLAGS_SOME:
		Một số cờ từ mặt nạ được đặt
	PM_QOS_FLAGS_NONE:
		Không có cờ nào từ mặt nạ được đặt
	PM_QOS_FLAGS_UNDEFINED:
		Cấu trúc PM QoS của thiết bị chưa được khởi tạo
		hoặc danh sách yêu cầu trống.

int dev_pm_qos_add_ancestor_request(dev, xử lý, loại, giá trị)
  Thêm yêu cầu PM QoS cho tổ tiên trực tiếp đầu tiên của thiết bị nhất định có
  Cờ power.ignore_children chưa được đặt (đối với các yêu cầu DEV_PM_QOS_RESUME_LATENCY)
  hoặc con trỏ gọi lại power.set_latency_tolerance của nó không phải là NULL (đối với
  yêu cầu DEV_PM_QOS_LATENCY_TOLERANCE).

int dev_pm_qos_expose_latency_limit(thiết bị, giá trị)
  Thêm yêu cầu vào danh sách PM QoS của thiết bị về các hạn chế về độ trễ tiếp tục và
  tạo thuộc tính sysfs pm_qos_resume_latency_us dưới sức mạnh của thiết bị
  thư mục cho phép không gian người dùng thao tác yêu cầu đó.

void dev_pm_qos_hide_latency_limit(thiết bị)
  Bỏ yêu cầu được thêm bởi dev_pm_qos_expose_latency_limit() khỏi thiết bị
  Danh sách PM QoS về các hạn chế về độ trễ tiếp tục và xóa thuộc tính sysfs
  pm_qos_resume_latency_us từ thư mục nguồn của thiết bị.

int dev_pm_qos_expose_flags(thiết bị, giá trị)
  Thêm yêu cầu vào danh sách cờ PM QoS của thiết bị và tạo thuộc tính sysfs
  pm_qos_no_power_off trong thư mục nguồn của thiết bị cho phép người dùng có không gian để
  thay đổi giá trị của cờ PM_QOS_FLAG_NO_POWER_OFF.

void dev_pm_qos_hide_flags(thiết bị)
  Bỏ yêu cầu được thêm bởi dev_pm_qos_expose_flags() khỏi PM QoS của thiết bị
  danh sách các cờ và xóa thuộc tính sysfs pm_qos_no_power_off khỏi thiết bị
  thư mục quyền lực.

Cơ chế thông báo:

Khung PM QoS trên mỗi thiết bị có cây thông báo trên mỗi thiết bị.

int dev_pm_qos_add_notifier(thiết bị, trình thông báo, loại):
  Thêm chức năng gọi lại thông báo cho thiết bị khi có yêu cầu cụ thể
  loại.

Cuộc gọi lại được gọi khi giá trị tổng hợp của các ràng buộc thiết bị
  danh sách được thay đổi.

int dev_pm_qos_remove_notifier(thiết bị, trình thông báo, loại):
  Loại bỏ chức năng gọi lại thông báo cho thiết bị.


Dung sai độ trễ trạng thái hoạt động
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Loại PM QoS của thiết bị này được sử dụng để hỗ trợ các hệ thống trong đó phần cứng có thể chuyển đổi
sang các chế độ vận hành tiết kiệm năng lượng một cách nhanh chóng.  Trong các hệ thống đó, nếu hoạt động
chế độ được chọn bởi phần cứng cố gắng tiết kiệm năng lượng một cách quá mức,
nó có thể khiến phần mềm nhìn thấy độ trễ quá mức, khiến phần mềm bị bỏ lỡ
các yêu cầu giao thức nhất định hoặc khung mục tiêu hoặc tốc độ mẫu, v.v.

Nếu có sẵn cơ chế kiểm soát dung sai độ trễ cho một thiết bị nhất định
đối với phần mềm, lệnh gọi lại .set_latency_tolerance trong dev_pm_info của thiết bị đó
cấu trúc nên được dân cư.  Các thói quen được chỉ ra bởi nó là nên thực hiện
bất cứ điều gì cần thiết để chuyển giá trị yêu cầu hiệu quả sang
phần cứng.

Bất cứ khi nào dung sai độ trễ hiệu dụng của thiết bị thay đổi,
Lệnh gọi lại .set_latency_tolerance() sẽ được thực thi và giá trị hiệu dụng sẽ
được chuyển đến nó.  Nếu giá trị đó là âm, có nghĩa là danh sách
yêu cầu về dung sai độ trễ cho thiết bị trống, dự kiến sẽ gọi lại
để chuyển cơ chế kiểm soát dung sai độ trễ phần cứng cơ bản sang cơ chế
chế độ tự trị nếu có.  Nếu giá trị đó lần lượt là PM_QOS_LATENCY_ANY và
phần cứng hỗ trợ cài đặt "không yêu cầu" đặc biệt, lệnh gọi lại là
dự kiến sẽ sử dụng nó.  Điều đó cho phép phần mềm ngăn phần cứng khỏi
tự động cập nhật khả năng chịu độ trễ của thiết bị để đáp ứng với nguồn điện của thiết bị
thay đổi trạng thái (ví dụ: trong quá trình chuyển đổi từ D3cold sang D0), thường có thể
được thực hiện ở chế độ kiểm soát dung sai độ trễ tự động.

Nếu thiết bị có .set_latency_tolerance(), thuộc tính sysfs
pm_qos_latency_tolerance_us sẽ có trong thư mục nguồn của thiết bị.
Sau đó, không gian người dùng có thể sử dụng thuộc tính đó để chỉ định dung sai độ trễ của nó
yêu cầu đối với thiết bị, nếu có.  Viết "bất kỳ" vào nó có nghĩa là "không có yêu cầu,
nhưng đừng để phần cứng kiểm soát dung sai độ trễ" và ghi "tự động" vào nó
cho phép phần cứng được chuyển sang chế độ tự động nếu không có chế độ nào khác
yêu cầu từ phía kernel trong danh sách của thiết bị.

Mã hạt nhân có thể sử dụng các chức năng được mô tả ở trên cùng với
DEV_PM_QOS_LATENCY_TOLERANCE loại PM QoS của thiết bị để thêm, xóa và cập nhật
yêu cầu về khả năng chịu độ trễ cho thiết bị.
