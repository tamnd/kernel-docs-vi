.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/s390/s390-diag.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
S390 DIAGNOSE gọi KVM
=============================

KVM trên s390 hỗ trợ lệnh gọi DIAGNOSE để thực hiện siêu cuộc gọi, cho cả
siêu cuộc gọi gốc và cho các siêu cuộc gọi được chọn được tìm thấy trên s390 khác
siêu giám sát.

Lưu ý rằng các bit được đánh số theo quy ước s390 thông thường (quan trọng nhất
chút bên trái).


Nhận xét chung
---------------

Các cuộc gọi DIAGNOSE của khách sẽ gây ra sự chặn bắt buộc. Điều này ngụ ý
tất cả các cuộc gọi DIAGNOSE được hỗ trợ cần phải được xử lý bởi KVM hoặc
không gian người dùng.

Tất cả các cuộc gọi DIAGNOSE được KVM hỗ trợ đều sử dụng định dạng RS-a ::

--------------------------------------
  ZZ0000ZZ R1 ZZ0001ZZ B2 ZZ0002ZZ
  --------------------------------------
  0 8 12 16 20 31

Địa chỉ toán hạng thứ hai (thu được bằng phép tính cơ sở/độ dịch chuyển)
không được sử dụng để đánh địa chỉ dữ liệu. Thay vào đó, các bit 48-63 của địa chỉ này chỉ định
mã chức năng và các bit 0-47 bị bỏ qua.

Mã chức năng DIAGNOSE được hỗ trợ khác nhau tùy theo không gian người dùng được sử dụng. cho
Mã chức năng DIAGNOSE không dành riêng cho KVM, vui lòng tham khảo
tài liệu dành cho các trình ảo hóa s390 xác định chúng.


Mã hàm DIAGNOSE “X'500” - Hàm KVM
----------------------------------------------

Nếu mã chức năng chỉ định 0x500, các chức năng khác nhau dành riêng cho KVM
được thực hiện, bao gồm cả các chức năng virtio.

Thanh ghi chung 1 chứa mã chức năng con. Các chức năng phụ được hỗ trợ
phụ thuộc vào không gian người dùng của KVM. Về các chức năng con virtio, nói chung
không gian người dùng cung cấp s390-virtio (mã phụ 0-2) hoặc virtio-ccw
(mã phụ 3).

Sau khi hoàn thành lệnh DIAGNOSE, thanh ghi chung 2 chứa
mã trả về của hàm, là mã trả về hoặc mã phụ
giá trị cụ thể.

Nếu chức năng con đã chỉ định không được hỗ trợ, ngoại lệ SPECIFICATION
sẽ được kích hoạt.

Mã phụ 0 - thông báo s390-virtio và bản in bảng điều khiển sớm
    Được xử lý bởi không gian người dùng.

Mã con 1 - đặt lại s390-virtio
    Được xử lý bởi không gian người dùng.

Mã con 2 - trạng thái đặt s390-virtio
    Được xử lý bởi không gian người dùng.

Mã con 3 - thông báo virtio-ccw
    Được xử lý bởi không gian người dùng hoặc KVM (trường hợp ioeventfd).

Thanh ghi chung 2 chứa từ nhận dạng kênh con biểu thị
    kênh con của thiết bị proxy virtio-ccw sẽ được thông báo.

Sổ đăng ký chung 3 chứa số lượng người có thẩm quyền được thông báo.

Thanh ghi chung 4 chứa mã định danh 64 bit cho việc sử dụng KVM (
    cookie kvm_io_bus). Nếu thanh ghi chung 4 không chứa giá trị hợp lệ
    định danh, nó bị bỏ qua.

Sau khi hoàn thành cuộc gọi DIAGNOSE, thanh ghi chung 2 có thể chứa
    mã định danh 64bit (trong trường hợp cookie kvm_io_bus) hoặc số âm
    giá trị lỗi, nếu xảy ra lỗi nội bộ.

Xem thêm tiêu chuẩn tài năng để thảo luận về siêu cuộc gọi này.

Mã con 4 - giới hạn lưu trữ
    Được xử lý bởi không gian người dùng.

Sau khi hoàn thành cuộc gọi DIAGNOSE, thanh ghi chung 2 sẽ
    chứa giới hạn lưu trữ: địa chỉ vật lý tối đa có thể
    được sử dụng để lưu trữ trong suốt vòng đời của VM.

Giới hạn lưu trữ không cho biết dung lượng lưu trữ hiện có thể sử dụng được, nó có thể
    bao gồm các lỗ, kho dự phòng và các khu vực dành riêng cho các phương tiện khác, chẳng hạn như
    như các thiết bị cắm nóng bộ nhớ hoặc virtio-mem. Các giao diện khác để phát hiện
    bộ nhớ thực sự có thể sử dụng được, chẳng hạn như SCLP, phải được sử dụng cùng với
    chức năng phụ này.

Lưu ý rằng giới hạn lưu trữ có thể lớn hơn nhưng không bao giờ nhỏ hơn giới hạn lưu trữ
    địa chỉ lưu trữ tối đa được chỉ định bởi SCLP thông qua "bộ nhớ tối đa
    tăng" và "kích thước tăng".


Mã hàm DIAGNOSE 'X'501 - Điểm dừng KVM
----------------------------------------------

Nếu mã chức năng chỉ định 0x501, các chức năng điểm dừng có thể được thực hiện.
Mã chức năng này được xử lý bởi không gian người dùng.

Mã chức năng chẩn đoán này không có chức năng phụ và không sử dụng tham số.


Mã hàm DIAGNOSE 'X'9C - Năng suất lát cắt thời gian tự nguyện
---------------------------------------------------------

Thanh ghi chung 1 chứa địa chỉ CPU đích.

Trong máy khách của bộ ảo hóa như LPAR, KVM hoặc z/VM sử dụng CPU máy chủ dùng chung,
DIAGNOSE với mã chức năng 0x9c có thể cải thiện hiệu suất hệ thống bằng cách
mang lại máy chủ CPU mà CPU khách đang chạy được chỉ định
tới một khách khác CPU, tốt nhất là CPU logic chứa thông tin được chỉ định
mục tiêu CPU.


Chuyển tiếp DIAG 'X'9C
+++++++++++++++++++++

Khách có thể gửi DIAGNOSE 0x9c để đạt được một mục tiêu nhất định
vcpu khác. Một ví dụ là một khách Linux cố gắng nhượng bộ vcpu
hiện đang giữ một spinlock nhưng không chạy.

Tuy nhiên, trên máy chủ, CPU thực hỗ trợ vcpu có thể không được hỗ trợ.
đang chạy.
Chuyển tiếp DIAGNOSE 0x9c ban đầu được khách gửi để nhường cho
CPU hỗ trợ hy vọng sẽ gây ra CPU đó và do đó sau đó
vcpu của khách, sẽ được lên lịch.


diag9c_forwarding_hz
    Tham số kernel KVM cho phép chỉ định số lượng DIAGNOSE tối đa
    Chuyển tiếp 0x9c mỗi giây nhằm mục đích tránh DIAGNOSE 0x9c
    cơn bão chuyển tiếp.
    Giá trị 0 sẽ tắt chuyển tiếp.