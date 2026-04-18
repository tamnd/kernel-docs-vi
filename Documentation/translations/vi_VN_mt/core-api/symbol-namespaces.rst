.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/symbol-namespaces.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================
Không gian tên biểu tượng
=========================

Tài liệu sau đây mô tả cách sử dụng Không gian tên Biểu tượng để cấu trúc
bề mặt xuất của các ký hiệu trong kernel được xuất thông qua họ biểu tượng
Các macro EXPORT_SYMBOL().

Giới thiệu
============

Không gian tên biểu tượng đã được giới thiệu như một phương tiện để cấu trúc việc xuất
bề mặt của API trong nhân. Nó cho phép người bảo trì hệ thống con phân vùng
các ký hiệu được xuất của chúng vào các không gian tên riêng biệt. Điều đó có ích cho
mục đích tài liệu (hãy nghĩ đến không gian tên SUBSYSTEM_DEBUG) cũng như cho
hạn chế sự sẵn có của một bộ ký hiệu để sử dụng trong các phần khác của
hạt nhân. Tính đến hôm nay, các mô-đun sử dụng các ký hiệu được xuất vào không gian tên,
được yêu cầu nhập không gian tên. Nếu không thì kernel sẽ, tùy thuộc vào
cấu hình của nó, từ chối tải mô-đun hoặc cảnh báo về việc nhập bị thiếu.

Ngoài ra, có thể đặt các ký hiệu vào một không gian tên mô-đun một cách nghiêm ngặt.
giới hạn mô-đun nào được phép sử dụng các ký hiệu này.

Cách xác định không gian tên biểu tượng
===============================

Các biểu tượng có thể được xuất vào không gian tên bằng các phương pháp khác nhau. Tất cả chúng đều là
thay đổi cách EXPORT_SYMBOL và bạn bè được trang bị để tạo ksymtab
mục nhập.

Sử dụng macro EXPORT_SYMBOL
------------------------------

Ngoài các macro EXPORT_SYMBOL() và EXPORT_SYMBOL_GPL(), cho phép
xuất các ký hiệu hạt nhân sang bảng ký hiệu hạt nhân, các biến thể của chúng là
có sẵn để xuất các ký hiệu vào một không gian tên nhất định: EXPORT_SYMBOL_NS() và
EXPORT_SYMBOL_NS_GPL(). Họ lấy một đối số bổ sung: không gian tên làm
hằng số chuỗi. Lưu ý rằng chuỗi này không được chứa khoảng trắng.
Ví dụ. để xuất ký hiệu ZZ0000ZZ vào
không gian tên ZZ0001ZZ, sử dụng::

EXPORT_SYMBOL_NS(usb_stor_suspend, "USB_STORAGE");

Mục ksymtab tương ứng struct ZZ0000ZZ sẽ có thành viên
ZZ0001ZZ được đặt tương ứng. Một biểu tượng được xuất mà không có không gian tên sẽ
tham khảo ZZ0002ZZ. Không có không gian tên mặc định nếu không có không gian tên nào được xác định. ZZ0003ZZ
và kernel/module/main.c sử dụng không gian tên khi xây dựng hoặc tải mô-đun
thời gian tương ứng.

Sử dụng DEFAULT_SYMBOL_NAMESPACE xác định
-----------------------------------------

Việc xác định các không gian tên cho tất cả các ký hiệu của một hệ thống con có thể rất dài dòng và có thể
trở nên khó bảo trì. Do đó, xác định mặc định (DEFAULT_SYMBOL_NAMESPACE)
được cung cấp, nếu được đặt, nó sẽ trở thành mặc định cho tất cả EXPORT_SYMBOL()
và mở rộng macro EXPORT_SYMBOL_GPL() không chỉ định vùng tên.

Có nhiều cách để xác định định nghĩa này và nó phụ thuộc vào
hệ thống con và ưu tiên của người bảo trì, nên sử dụng cái nào. Tùy chọn đầu tiên
là xác định không gian tên mặc định trong ZZ0000ZZ của hệ thống con. Ví dụ. để
xuất tất cả các ký hiệu được xác định trong usb-common vào không gian tên USB_COMMON, thêm một
dòng như thế này vào driver/usb/common/Makefile::

ccflags-y += -DDEFAULT_SYMBOL_NAMESPACE='"USB_COMMON"'

Điều đó sẽ ảnh hưởng đến tất cả các câu lệnh EXPORT_SYMBOL() và EXPORT_SYMBOL_GPL(). A
ký hiệu được xuất với EXPORT_SYMBOL_NS() trong khi định nghĩa này hiện diện, sẽ
vẫn được xuất vào không gian tên được truyền dưới dạng đối số không gian tên
vì đối số này được ưu tiên hơn không gian tên ký hiệu mặc định.

Tùy chọn thứ hai để xác định không gian tên mặc định có trực tiếp trong quá trình biên dịch
unit làm câu lệnh tiền xử lý. Ví dụ trên sẽ đọc::

#define DEFAULT_SYMBOL_NAMESPACE "USB_COMMON"

trong đơn vị biên dịch tương ứng trước #include cho
<linux/export.h>. Thông thường, nó được đặt trước câu lệnh #include đầu tiên.

Sử dụng macro EXPORT_SYMBOL_FOR_MODULES()
-------------------------------------------

Các ký hiệu được xuất bằng macro này sẽ được đưa vào không gian tên mô-đun. Cái này
không gian tên không thể được nhập khẩu. Các bản xuất này chỉ dành cho GPL vì chúng chỉ
dành cho các module trong cây.

Macro lấy danh sách tên mô-đun được phân tách bằng dấu phẩy, chỉ cho phép những tên đó
mô-đun để truy cập biểu tượng này. Các quả cầu đuôi đơn giản được hỗ trợ.

Ví dụ::

EXPORT_SYMBOL_FOR_MODULES(preempt_notifier_inc, "kvm,kvm-*")

sẽ hạn chế việc sử dụng ký hiệu này ở các mô-đun có tên khớp với tên đã cho
các mẫu.

Cách sử dụng Biểu tượng được xuất trong Không gian tên
=========================================

Để sử dụng các ký hiệu được xuất vào không gian tên, các mô-đun hạt nhân cần
để nhập rõ ràng các không gian tên này. Nếu không thì kernel có thể từ chối
tải mô-đun. Cần có mã mô-đun để sử dụng macro MODULE_IMPORT_NS
đối với các không gian tên, nó sử dụng các ký hiệu từ đó. Ví dụ. một mô-đun sử dụng
biểu tượng usb_stor_suspend ở trên, cần nhập không gian tên USB_STORAGE
sử dụng một câu lệnh như::

MODULE_IMPORT_NS("USB_STORAGE");

Điều này sẽ tạo thẻ ZZ0000ZZ trong mô-đun cho mỗi vùng tên đã nhập.
Điều này có tác dụng phụ là các không gian tên đã nhập của mô-đun có thể bị
được kiểm tra bằng modinfo::

$ trình điều khiển modinfo/usb/storage/ums-karma.ko
	[…]
	nhập_ns: USB_STORAGE
	[…]

Đối với các mô-đun hiện đang được tải, các không gian tên đã nhập cũng có sẵn
thông qua sysfs::

$ cat /sys/module/ums_karma/import_ns
	USB_STORAGE

Nên thêm câu lệnh MODULE_IMPORT_NS() gần với mô-đun khác
định nghĩa siêu dữ liệu như MODULE_AUTHOR() hoặc MODULE_LICENSE().

Đang tải các mô-đun sử dụng Ký hiệu được đặt tên
===========================================

Tại thời điểm tải mô-đun (ví dụ ZZ0000ZZ), kernel sẽ kiểm tra từng ký hiệu
được tham chiếu từ mô-đun về tính khả dụng của nó và liệu vùng tên nó có
có thể được xuất sang đã được mô-đun nhập. Hành vi mặc định của
hạt nhân sẽ từ chối tải các mô-đun không chỉ định đủ số lần nhập.
Một lỗi sẽ được ghi lại và việc tải EINVAL sẽ không thành công. để
cho phép tải các mô-đun không thỏa mãn điều kiện tiên quyết này, cấu hình
tùy chọn có sẵn: Đặt MODULE_ALLOW_MISSING_NAMESPACE_IMPORTS=y sẽ
cho phép tải bất kể nhưng sẽ phát ra cảnh báo.

Tự động tạo câu lệnh MODULE_IMPORT_NS
==================================================

Việc nhập không gian tên bị thiếu có thể dễ dàng được phát hiện tại thời điểm xây dựng. Trên thực tế,
modpost sẽ phát ra cảnh báo nếu mô-đun sử dụng ký hiệu từ không gian tên
mà không cần nhập nó.
Các câu lệnh MODULE_IMPORT_NS() thường sẽ được thêm vào ở một vị trí xác định
(cùng với dữ liệu meta mô-đun khác). Để làm nên cuộc đời của tác giả module (và
người bảo trì hệ thống con) dễ dàng hơn, tập lệnh và mục tiêu có sẵn để sửa lỗi
hàng nhập khẩu thiếu. Việc sửa lỗi nhập bị thiếu có thể được thực hiện bằng::

$ tạo nsdeps

Một kịch bản điển hình cho các tác giả mô-đun sẽ là::

- viết mã phụ thuộc vào ký hiệu từ không gian tên không được nhập
	-ZZ0000ZZ
	- chú ý cảnh báo của modpost nói về việc nhập bị thiếu
	- chạy ZZ0001ZZ để thêm phần nhập vào đúng vị trí mã

Đối với những người bảo trì hệ thống con giới thiệu một không gian tên, các bước rất giống nhau.
Một lần nữa, ZZ0000ZZ cuối cùng sẽ thêm các phần nhập không gian tên bị thiếu cho
mô-đun trong cây::

- di chuyển hoặc thêm ký hiệu vào không gian tên (ví dụ: với EXPORT_SYMBOL_NS())
	- ZZ0000ZZ (tốt nhất là có allmodconfig để bao gồm tất cả trong kernel
	  mô-đun)
	- chú ý cảnh báo của modpost nói về việc nhập bị thiếu
	- chạy ZZ0001ZZ để thêm phần nhập vào đúng vị trí mã

Bạn cũng có thể chạy nsdeps cho các bản dựng mô-đun bên ngoài. Cách sử dụng điển hình là::

$ make -C <path_to_kernel_src> M=$PWD nsdeps

Lưu ý: nó sẽ vui vẻ tạo một câu lệnh nhập cho không gian tên mô-đun;
sẽ không hoạt động và tạo ra lỗi xây dựng và thời gian chạy.
