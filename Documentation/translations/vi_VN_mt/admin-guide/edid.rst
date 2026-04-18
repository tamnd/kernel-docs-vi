.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/edid.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====
EDID
====

Ngày xưa khi các thông số đồ họa được cấu hình rõ ràng
trong một tệp có tên xorg.conf, thậm chí phần cứng bị hỏng cũng có thể được quản lý.

Ngày nay, với sự ra đời của Kernel Mode Setting, bo mạch đồ họa
hoạt động chính xác vì tất cả các thành phần đều tuân theo các tiêu chuẩn -
hoặc máy tính không sử dụng được do màn hình vẫn tối sau
khởi động hoặc nó hiển thị sai khu vực. Các trường hợp xảy ra là:

- Bo mạch đồ họa không nhận màn hình.
- Bo mạch đồ họa không thể phát hiện bất kỳ dữ liệu EDID nào.
- Bo mạch đồ họa chuyển tiếp dữ liệu EDID tới trình điều khiển không chính xác.
- Màn hình không gửi hoặc gửi dữ liệu EDID không có thật.
- KVM gửi dữ liệu EDID của chính nó thay vì truy vấn màn hình được kết nối.

Việc thêm tham số kernel "nomodeset" sẽ giúp ích trong hầu hết các trường hợp, nhưng gây ra
những hạn chế sau này.

Để khắc phục những tình huống như vậy, mục cấu hình kernel
CONFIG_DRM_LOAD_EDID_FIRMWARE đã được giới thiệu. Nó cho phép cung cấp một
Tập dữ liệu EDID được chuẩn bị hoặc sửa riêng lẻ trong /lib/firmware
thư mục từ nơi nó được tải thông qua giao diện phần sụn.