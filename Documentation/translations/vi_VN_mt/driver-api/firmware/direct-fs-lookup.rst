.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/firmware/direct-fs-lookup.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Tra cứu hệ thống tập tin trực tiếp
========================

Tra cứu hệ thống tập tin trực tiếp là hình thức tra cứu phần sụn phổ biến nhất được thực hiện
bởi hạt nhân. Kernel tìm kiếm firmware trực tiếp trên root
hệ thống tập tin trong các đường dẫn được ghi lại trong phần 'Đường dẫn tìm kiếm chương trình cơ sở'.
Việc tra cứu hệ thống tập tin được triển khai trong fw_get_filesystem_firmware(), nó
sử dụng cơ sở tải tập tin hạt nhân lõi chung kernel_read_file_from_path().
Đường dẫn tối đa được phép là PATH_MAX - hiện tại đường dẫn này là 4096 ký tự.

Bạn nên giữ đường dẫn /lib/firmware trên hệ thống tập tin gốc của mình,
tránh có một phân vùng riêng cho họ để tránh có thể
chạy đua với việc tra cứu và tránh sử dụng cơ chế dự phòng tùy chỉnh
được ghi lại dưới đây.

Phần sụn và initramfs
----------------------

Trình điều khiển được tích hợp sẵn trong kernel phải có phần sụn tích hợp
cũng là một phần của initramfs được sử dụng để khởi động kernel nếu không thì
một cuộc đua có thể xảy ra với việc tải trình điều khiển và chưa có rootf thực sự
có sẵn. Nhồi phần sụn vào initramfs sẽ giải quyết được vấn đề chủng tộc này,
tuy nhiên hãy lưu ý rằng việc sử dụng initrd không đủ để giải quyết cùng một chủng tộc.

Có những trường hợp biện minh cho việc không muốn đưa phần mềm cơ sở vào
initramfs, chẳng hạn như xử lý các tệp chương trình cơ sở lớn cho
hệ thống con proc từ xa. Đối với những trường hợp như vậy sử dụng cơ chế dự phòng không gian người dùng
hiện là giải pháp khả thi duy nhất vì chỉ có không gian người dùng mới có thể biết chắc chắn
khi rootfs thực đã sẵn sàng và được gắn kết.
