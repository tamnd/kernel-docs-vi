.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/firmware/fw_search_path.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Đường dẫn tìm kiếm phần sụn
=====================

Các đường dẫn tìm kiếm sau đây được sử dụng để tìm kiếm chương trình cơ sở trên thiết bị của bạn
hệ thống tập tin gốc.

* fw_path_para - tham số mô-đun - mặc định trống nên thông số này bị bỏ qua
* /lib/firmware/cập nhật/UTS_RELEASE/
* /lib/firmware/cập nhật/
* /lib/firmware/UTS_RELEASE/
* /lib/chương trình cơ sở/

Tham số mô-đun ''path'' có thể được chuyển đến mô-đun firmware_class
để kích hoạt fw_path_para tùy chỉnh tùy chọn đầu tiên. Đường dẫn tùy chỉnh có thể
chỉ dài tối đa 256 ký tự. Tham số kernel được truyền sẽ là:

* 'firmware_class.path=$CUSTOMIZED_PATH'

Có một cách khác để tùy chỉnh đường dẫn trong thời gian chạy sau khi khởi động, bạn
có thể sử dụng tập tin:

* /sys/module/firmware_class/tham số/đường dẫn

Bạn sẽ lặp lại trong đó đường dẫn tùy chỉnh của bạn và phần sụn được yêu cầu sẽ được tìm kiếm
đầu tiên là ở đó. Xin lưu ý rằng các ký tự dòng mới sẽ được tính đến
và có thể không tạo ra tác dụng như mong muốn. Chẳng hạn, bạn có thể muốn sử dụng:

echo -n /path/to/script > /sys/module/firmware_class/parameters/path

để đảm bảo rằng tập lệnh của bạn đang được sử dụng.
