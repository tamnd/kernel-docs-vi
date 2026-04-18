.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/s390/s390-pv-boot.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=========================================
s390 (IBM Z) Boot/IPL của máy ảo được bảo vệ
======================================

Bản tóm tắt
-------
Bộ nhớ của Máy ảo được bảo vệ (PVM) không thể truy cập được
I/O hoặc bộ ảo hóa. Trong những trường hợp mà hypervisor cần
truy cập vào bộ nhớ của PVM, bộ nhớ đó phải ở chế độ có thể truy cập được.
Bộ nhớ mà hypervisor có thể truy cập sẽ được mã hóa. Xem
Documentation/virt/kvm/s390/s390-pv.rst để biết chi tiết."

Trên IPL (khởi động), một bộ tải khởi động văn bản gốc nhỏ được khởi động, cung cấp
thông tin về các thành phần được mã hóa và siêu dữ liệu cần thiết để
KVM để giải mã máy ảo được bảo vệ.

Dựa trên dữ liệu này, KVM sẽ công bố máy ảo được bảo vệ
tới Ultravisor (UV) và hướng dẫn nó bảo vệ bộ nhớ của
PVM, giải mã các thành phần và xác minh danh sách dữ liệu và địa chỉ
băm, để đảm bảo tính toàn vẹn. Sau đó KVM có thể chạy PVM thông qua
Lệnh SIE mà tia UV sẽ chặn và thực thi trên KVM
thay mặt.

Vì hình ảnh khách giống như một hình ảnh hạt nhân mờ đục thực hiện
tự chuyển sang chế độ PV, người dùng có thể tải khách được mã hóa
các tệp thực thi và dữ liệu thông qua mọi phương thức có sẵn (mạng, dasd, scsi,
direct kernel, ...) mà không cần thay đổi quá trình khởi động.


Diag308
-------
Lệnh chẩn đoán này là cơ chế cơ bản để xử lý IPL và
các hoạt động liên quan cho máy ảo. VM có thể thiết lập và truy xuất
Khối thông tin IPL, chỉ định phương thức/thiết bị IPL và
yêu cầu đặt lại bộ nhớ VM và hệ thống con cũng như IPL.

Đối với PVM, khái niệm này đã được mở rộng với các mã phụ mới:

Mã phụ 8: Đặt Khối thông tin IPL loại 5 (khối thông tin
cho PVM)
Subcode 9: Lưu khối đã lưu vào bộ nhớ khách
Mã con 10: Chuyển sang chế độ ảo hóa được bảo vệ

Trường thông số cụ thể của thiết bị tải PV mới chỉ định tất cả dữ liệu
điều đó là cần thiết để chuyển sang chế độ PV.

* Nguồn gốc tiêu đề PV
* Độ dài tiêu đề PV
* Danh sách các thành phần bao gồm
   * Tiền tố tinh chỉnh AES-XTS
   * Xuất xứ
   * Kích thước

Tiêu đề PV chứa các khóa và giá trị băm mà UV sẽ sử dụng để
giải mã và xác minh PV, cũng như các cờ điều khiển và PSW khởi động.

Ví dụ, các thành phần là hạt nhân được mã hóa, các tham số hạt nhân
và initrd. Các thành phần được giải mã bằng tia cực tím.

Sau lần nhập dữ liệu được mã hóa lần đầu, tất cả các trang được xác định sẽ
chứa nội dung của khách. Tất cả các trang không được chỉ định sẽ bắt đầu dưới dạng
không có trang nào trong lần truy cập đầu tiên.


Khi chạy ở chế độ ảo hóa được bảo vệ, một số mã con sẽ dẫn đến
ngoại lệ hoặc trả lại mã lỗi.

Mã phụ 4 và 7, chỉ định các hoạt động không xóa khách
bộ nhớ, sẽ dẫn đến các ngoại lệ đặc điểm kỹ thuật. Điều này là do
UV sẽ xóa tất cả bộ nhớ khi xóa VM an toàn và do đó
không cho phép mã phụ IPL không xóa.

Các mã con 8, 9, 10 sẽ dẫn đến các ngoại lệ về thông số kỹ thuật.
Chỉ có thể chuyển IPL sang chế độ được bảo vệ bằng cách đi đường vòng vào chế độ không
chế độ được bảo vệ.

Phím
----
Mỗi CEC sẽ có một khóa chung duy nhất để cho phép công cụ xây dựng
hình ảnh được mã hóa.
Xem ZZ0000ZZ
cho dụng cụ.