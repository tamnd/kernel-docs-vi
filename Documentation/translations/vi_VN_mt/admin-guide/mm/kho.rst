.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/mm/kho.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Cách sử dụng bàn giao Kexec
===========================

Kexec HandOver (KHO) là cơ chế cho phép Linux bảo toàn bộ nhớ
các vùng có thể chứa các trạng thái hệ thống được tuần tự hóa trên kexec.

Tài liệu này hy vọng bạn đã làm quen với cơ sở KHO
ZZ0000ZZ. Nếu bạn chưa đọc
họ chưa, hãy làm như vậy ngay bây giờ.

Điều kiện tiên quyết
====================

KHO khả dụng khi kernel được biên dịch bằng ZZ0000ZZ
đặt thành y. Mỗi nhà sản xuất KHO có thể có tùy chọn cấu hình riêng mà bạn
cần kích hoạt nếu bạn muốn duy trì trạng thái tương ứng của chúng trên toàn bộ
kexec.

Để sử dụng KHO, vui lòng khởi động kernel bằng dòng lệnh ZZ0000ZZ
tham số. Bạn có thể sử dụng tham số ZZ0001ZZ để xác định kích thước của
các vùng xước. Ví dụ ZZ0002ZZ sẽ dành một
Vùng cào bộ nhớ thấp 16 MiB, vùng cào toàn cầu 512 MiB và 256 MiB
trên mỗi vùng khởi động của nút NUMA khi khởi động.

Thực hiện kexec KHO
===================

Để thực hiện kexec KHO, hãy tải trọng tải mục tiêu và kexec vào đó. Nó
điều quan trọng là bạn sử dụng tham số ZZ0000ZZ để sử dụng trong kernel
trình tải tệp kexec, vì công cụ kexec không gian người dùng hiện không có
hỗ trợ KHO với trình tải tệp dựa trên không gian người dùng ::

# kexec -l /path/to/bzImage --initrd /path/to/initrd -s
  # kexec-e

Kernel mới sẽ khởi động và chứa một số trạng thái của kernel trước đó.

Ví dụ: nếu bạn đã sử dụng tham số dòng lệnh ZZ0000ZZ để tạo
dự trữ bộ nhớ sớm, hạt nhân mới sẽ có bộ nhớ đó tại thời điểm
cùng địa chỉ vật lý với kernel cũ.

giao diện debugfs
==================

Các giao diện debugfs này khả dụng khi kernel được biên dịch bằng
Đã bật ZZ0000ZZ.

Hiện tại KHO tạo các giao diện gỡ lỗi sau. Chú ý rằng những
giao diện có thể thay đổi trong tương lai. Chúng sẽ được chuyển tới sysfs sau khi KHO được
ổn định.

ZZ0000ZZ
    Hạt nhân hiển thị đốm màu cây thiết bị dẹt mang nó
    trạng thái KHO hiện tại trong tệp này. Công cụ không gian người dùng Kexec có thể sử dụng cái này
    làm tệp đầu vào cho hình ảnh tải trọng KHO.

ZZ0000ZZ
    Độ dài của các vùng xước KHO, tiếp giáp về mặt vật lý
    vùng bộ nhớ sẽ luôn có sẵn cho kexec trong tương lai
    phân bổ. Công cụ không gian người dùng Kexec có thể sử dụng tệp này để xác định
    nơi nó nên đặt hình ảnh tải trọng của nó.

ZZ0000ZZ
    Vị trí vật lý của vùng xước KHO. Công cụ không gian người dùng Kexec
    có thể sử dụng tệp này cùng với Scratch_phys để xác định vị trí
    nó sẽ đặt hình ảnh tải trọng của nó.

ZZ0000ZZ
    Các nhà sản xuất KHO có thể đăng ký FDT của riêng họ hoặc một blob nhị phân khác theo
    thư mục này.

ZZ0000ZZ
    Khi kernel được khởi động bằng Kexec HandOver (KHO),
    cây trạng thái mang siêu dữ liệu về trước đó
    trạng thái của kernel trong tệp này ở định dạng phẳng
    cây thiết bị. Tập tin này có thể biến mất khi tất cả người tiêu dùng của
    việc giải thích siêu dữ liệu của họ đã hoàn tất.

ZZ0000ZZ
    Tương tự như ZZ0001ZZ, nhưng chứa các đốm màu FDT phụ
    của các nhà sản xuất KHO được truyền từ kernel cũ.