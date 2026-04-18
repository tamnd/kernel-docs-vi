.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.2-no-invariants-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/edac/features.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Tính năng EDAC/RAS
===================

Bản quyền (c) 2024-2025 HiSilicon Limited.

:Tác giả: Shiju Jose <shiju.jose@huawei.com>
:Giấy phép: Giấy phép Tài liệu Miễn phí GNU, Phiên bản 1.2 không có
           Các phần bất biến, Văn bản bìa trước cũng như Văn bản bìa sau.
           (được cấp phép kép theo GPL v2)

- Viết cho: 6.15

Giới thiệu
------------

Các thành phần cắm và thiết kế cao cấp của EDAC/RAS:

1. Kiểm soát chà

2. Điều khiển Kiểm tra lỗi (ECS)

3. Tính năng ACPI RAS2

4. Kiểm soát sửa chữa gói sau (PPR)

5. Kiểm soát sửa chữa tiết kiệm bộ nhớ

Thiết kế cấp cao được minh họa trong sơ đồ sau::

+-----------------------------------------------+
        ZZ0000ZZ
        ZZ0001ZZ
        ZZ0002ZZ RAS CXL và ZZ0003ZZ
        | |trình xử lý lỗi|---->| ZZ0006ZZ
        ZZ0007ZZ RAS năng động ZZ0008ZZ
        Chà ZZ0009ZZ, bộ nhớ ZZ0010ZZ
        ZZ0011ZZ RAS bộ nhớ ZZ0012ZZ điều khiển sửa chữa|         |
        | |trình xử lý lỗi|     +----|----------+ |
        ZZ0016ZZ |
        +--------------------------|----------------------+
                                   |
                                   |
   +------------------------------|---------------------------------------+
   ZZ0017ZZ điều khiển RAS Tính năng |
   ZZ0018ZZ-----------------------------+ |
   |ZZ0019ZZ Xe buýt ZZ0020ZZ
   |ZZ0021ZZ-----------------------------+ZZ0022ZZ
   |ZZ0023ZZ/sys/bus/edac/devices/<dev>/scrubX/ ZZ0024ZZ Thiết bị EDAC |ZZ0025ZZ
   |ZZ0026ZZ/sys/bus/edac/devices/<dev>/ecsX/ ZZ0027ZZ EDAC MC |ZZ0028ZZ
   |ZZ0029ZZ/sys/bus/edac/devices/<dev>/repairX ZZ0030ZZ EDAC sysfs |ZZ0031ZZ
   |ZZ0032ZZ--------------------------+ZZ0033ZZ
   ||                           EDAC|Bus ZZ0035ZZ
   |ZZ0036ZZ ZZ0037ZZ
   |ZZ0038ZZ Nhận tính năng ZZ0039ZZ
   |ZZ0040ZZ ZZ0041ZZ------+ desc +----------+ ZZ0042ZZ
   |ZZ0043ZZEDAC chà|<-----| EDAC thiết bị ZZ0045ZZ ZZ0046ZZ |
   |Trình điều khiểnZZ0047ZZ- RAS ZZ0048ZZ EDAC mem ZZ0049ZZ |
   |ZZ0050ZZ điều khiển tính năng|      | sửa chữa ZZ0052ZZ |
   |ZZ0053ZZ ZZ0054ZZ ZZ0055ZZ |
   |ZZ0056ZZEDAC ECS ZZ0057ZZ------+ ZZ0058ZZ
   ||   +----------+    Register RAS|tính năng ZZ0060ZZ
   |ZZ0061ZZ_____________ ZZ0062ZZ
   ZZ0063ZZ--------------ZZ0064ZZ--------------+ |
   ZZ0065ZZ----+ +-------ZZ0066ZZ----------+ |
   ZZ0067ZZ ZZ0068ZZ CXL trình điều khiển mem|     | Trình điều khiển máy khách ZZ0070ZZ
   ZZ0071ZZ ACPI RAS2 ZZ0072ZZ chà, ECS, ZZ0073ZZ sửa chữa bộ nhớ ZZ0074ZZ
   Trình điều khiển ZZ0075ZZ Tiết kiệm ZZ0076ZZ, PPR ZZ0077ZZ tính năng ZZ0078ZZ
   ZZ0079ZZ------+ +-------ZZ0080ZZ--------+ |
   ZZ0081ZZ ZZ0082ZZ |
   +--------ZZ0083ZZ----------------------|--------------+
            ZZ0084ZZ |
   +--------ZZ0085ZZ----------------------|--------------+
   ZZ0086ZZ--------ZZ0087ZZ-------+ |
   ZZ0088ZZ ZZ0089ZZ
   ZZ0090ZZ Nền tảng HW và Firmware ZZ0091ZZ
   ZZ0092ZZ
   +-------------------------------------------------------------- +


1. Các thành phần tính năng của EDAC - Tạo các bộ mô tả dành riêng cho tính năng. cho
   ví dụ: chà, ECS, sửa chữa bộ nhớ trong sơ đồ trên.

2. Trình điều khiển thiết bị EDAC để điều khiển các tính năng của RAS - Nhận thuộc tính của tính năng
   mô tả từ thành phần tính năng EDAC RAS và đăng ký RAS của thiết bị
   các tính năng với bus EDAC và hiển thị các thuộc tính kiểm soát tính năng thông qua
   sysfs. Ví dụ: /sys/bus/edac/devices/<dev-name>/<feature>X/

3. Bộ điều khiển tính năng động RAS - Mô-đun mẫu không gian người dùng trong rasdaemon cho
   Kiểm soát chà/sửa chữa động để phát hành việc chà/sửa chữa khi vượt quá số lượng
   các lỗi bộ nhớ đã được sửa sẽ được báo cáo trong một khoảng thời gian ngắn.

Tính năng RAS
------------
1. Xóa bộ nhớ

Tính năng xóa bộ nhớ được ghi lại trong ZZ0000ZZ.

2. Sửa chữa bộ nhớ

Các tính năng sửa chữa bộ nhớ được ghi lại trong ZZ0000ZZ.