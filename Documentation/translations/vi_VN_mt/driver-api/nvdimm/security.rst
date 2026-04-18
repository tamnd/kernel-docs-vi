.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/nvdimm/security.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================
Bảo mật NVDIMM
===============

1. Giới thiệu
---------------

Với việc giới thiệu Phương pháp dành riêng cho thiết bị Intel (DSM) v1.8
đặc tả [1], DSM bảo mật được giới thiệu. Thông số kỹ thuật đã thêm vào như sau
DSM bảo mật: "lấy trạng thái bảo mật", "đặt cụm mật khẩu", "tắt cụm mật khẩu",
"mở khóa thiết bị", "đóng băng khóa", "xóa an toàn" và "ghi đè". Bảo mật_ops
Cấu trúc dữ liệu đã được thêm vào struct dimm để hỗ trợ bảo mật
các hoạt động và API chung được đưa ra để cho phép các hoạt động trung lập của nhà cung cấp.

2. Giao diện hệ thống
------------------
Thuộc tính sysfs "bảo mật" được cung cấp trong thư mục nvdimm sysfs. cho
ví dụ:
/sys/devices/LNXSYSTM:00/LNXSYBUS:00/ACPI0012:00/ndbus0/nmem0/security

Thuộc tính "show" của thuộc tính đó sẽ hiển thị trạng thái bảo mật cho
chiếc DIMM đó. Các trạng thái sau đây có sẵn: bị vô hiệu hóa, đã mở khóa, bị khóa,
bị đóng băng và ghi đè. Nếu bảo mật không được hỗ trợ, thuộc tính sysfs
sẽ không được nhìn thấy.

Thuộc tính "store" nhận một số lệnh khi nó được ghi vào
để hỗ trợ một số chức năng bảo mật:
cập nhật <old_keyid> <new_keyid> - bật hoặc cập nhật cụm mật khẩu.
tắt <keyid> - tắt bảo mật đã bật và xóa khóa.
đóng băng - đóng băng thay đổi trạng thái bảo mật.
xóa <keyid> - xóa khóa mã hóa người dùng hiện có.
ghi đè <keyid> - xóa toàn bộ nvdimm.
master_update <keyid> <new_keyid> - bật hoặc cập nhật cụm mật khẩu chính.
master_erase <keyid> - xóa khóa mã hóa người dùng hiện có.

3. Quản lý khóa
-----------------

Khóa được liên kết với tải trọng bằng id DIMM. Ví dụ:
# cat /sys/devices/LNXSYSTM:00/LNXSYBUS:00/ACPI0012:00/ndbus0/nmem0/nfit/id
8089-a2-1740-00000133
Id DIMM sẽ được cung cấp cùng với trọng tải chính (cụm mật khẩu) để
hạt nhân.

Các khóa bảo mật được quản lý trên cơ sở một khóa duy nhất cho mỗi DIMM. các
"cụm mật khẩu" chính dự kiến ​​sẽ dài 32byte. Cái này tương tự với ATA
đặc tả bảo mật [2]. Một khóa ban đầu được lấy thông qua request_key()
kernel API gọi trong khi mở khóa nvdimm. Người sử dụng có trách nhiệm đảm bảo rằng
tất cả các khóa đều nằm trong khóa người dùng kernel để mở khóa.

Khóa mã hóa nvdimm có định dạng enc32 có định dạng mô tả là:
nvdimm:<bus-provider-cụ thể-unique-id>

Xem tệp ZZ0000ZZ để tạo
khóa mã hóa có định dạng enc32. Việc sử dụng TPM với khóa đáng tin cậy chính là
được ưu tiên để niêm phong các khóa được mã hóa.

4. Mở khóa
------------
Khi các DIMM đang được liệt kê bởi kernel, kernel sẽ cố gắng
lấy khóa từ khóa của người dùng kernel. Đây là lần duy nhất
DIMM bị khóa có thể được mở khóa. Sau khi được mở khóa, DIMM sẽ vẫn được mở khóa
cho đến khi khởi động lại. Thông thường, một thực thể (tức là tập lệnh shell) sẽ đưa vào tất cả các
các khóa mã hóa có liên quan vào khóa người dùng kernel trong giai đoạn initramfs.
Điều này cung cấp chức năng mở khóa quyền truy cập vào tất cả các khóa liên quan có chứa
cụm mật khẩu cho nvdimm tương ứng.  Người ta cũng khuyến cáo rằng
các khóa được đưa vào trước khi libnvdimm được modprobe tải.

5. Cập nhật
---------
Khi thực hiện cập nhật, dự kiến khóa hiện tại sẽ bị xóa khỏi
người dùng kernel nhập khóa và nhập lại dưới dạng khóa (cũ) khác. Nó không liên quan
mô tả khóa của khóa cũ là gì vì chúng ta chỉ quan tâm đến
keyid khi thực hiện thao tác cập nhật. Người ta cũng mong đợi rằng khóa mới
được đưa vào định dạng mô tả được mô tả ở phần trước trong phần này
tài liệu.  Lệnh cập nhật được ghi vào thuộc tính sysfs sẽ có
định dạng:
cập nhật <keyid cũ> <id khóa mới>

Nếu không có keyid cũ do kích hoạt bảo mật thì số 0 sẽ là
đã đi vào.

6. Đóng băng
---------
Thao tác đóng băng không yêu cầu bất kỳ phím nào. Cấu hình bảo mật có thể
bị đóng băng bởi người dùng có quyền root.

7. Vô hiệu hóa
----------
Định dạng lệnh vô hiệu hóa bảo mật là:
vô hiệu hóa <keyid>

Một khóa có tải trọng cụm mật khẩu hiện tại được gắn với nvdimm phải là
trong khóa người dùng kernel.

8. Xóa an toàn
---------------
Định dạng lệnh để thực hiện xóa an toàn là:
xóa <keyid>

Một khóa có tải trọng cụm mật khẩu hiện tại được gắn với nvdimm phải là
trong khóa người dùng kernel.

9. Ghi đè
------------
Định dạng lệnh để thực hiện ghi đè là:
ghi đè <keyid>

Việc ghi đè có thể được thực hiện mà không cần chìa khóa nếu tính năng bảo mật không được bật. Một khóa nối tiếp
số 0 có thể được chuyển vào để biểu thị không có khóa.

Thuộc tính "bảo mật" của sysfs có thể được thăm dò để chờ ghi đè hoàn tất.
Ghi đè có thể kéo dài hàng chục phút hoặc hơn tùy thuộc vào kích thước nvdimm.

Khóa được mã hóa với cụm mật khẩu người dùng hiện tại được gắn với nvdimm
nên được đưa vào và keyid của nó phải được chuyển qua sysfs.

10. Cập nhật tổng thể
-----------------
Định dạng lệnh để thực hiện cập nhật chính là:
cập nhật <keyid cũ> <id khóa mới>

Cơ chế hoạt động của bản cập nhật chính giống hệt với bản cập nhật ngoại trừ
khóa cụm mật khẩu chính được chuyển đến kernel. Khóa cụm mật khẩu chính
chỉ là một khóa mã hóa khác.

Lệnh này chỉ khả dụng khi bảo mật bị tắt.

11. Xóa tổng thể
----------------
Định dạng lệnh để thực hiện xóa tổng thể là:
master_erase <keyid hiện tại>

Lệnh này có cơ chế hoạt động tương tự như lệnh eras ngoại trừ lệnh master
khóa cụm mật khẩu được chuyển đến kernel. Khóa cụm mật khẩu chính chỉ là
một khóa mã hóa khác.

Lệnh này chỉ khả dụng khi bảo mật chính được bật, được biểu thị
bởi trạng thái bảo mật mở rộng.

[1]: ZZ0000ZZ

[2]: ZZ0000ZZ
