.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/net.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _net:

############################
Digital Mạng truyền hình API
############################

Thiết bị mạng TV kỹ thuật số điều khiển việc ánh xạ các gói dữ liệu là một phần
của luồng truyền tải được ánh xạ vào giao diện mạng ảo,
hiển thị thông qua ngăn xếp giao thức mạng Linux tiêu chuẩn.

Hiện tại, hai cách đóng gói được hỗ trợ:

-ZZ0000ZZ

-ZZ0000ZZ

Để tạo giao diện mạng ảo Linux, một ứng dụng
cần cho Kernel biết PID là gì và cách đóng gói
các loại có mặt trên luồng vận chuyển. Điều này được thực hiện thông qua
Nút thiết bị ZZ0000ZZ. Dữ liệu sẽ có sẵn thông qua
giao diện mạng ZZ0001ZZ ảo và sẽ được điều khiển/định tuyến thông qua
các công cụ ip tiêu chuẩn (như ip, tuyến đường, netstat, ifconfig, v.v.).

Các kiểu dữ liệu và định nghĩa ioctl được xác định thông qua ZZ0000ZZ
tiêu đề.


.. _net_fcalls:

Mạng truyền hình kỹ thuật số Chức năng Cuộc gọi
#############################

.. toctree::
    :maxdepth: 1

    net-types
    net-add-if
    net-remove-if
    net-get-if