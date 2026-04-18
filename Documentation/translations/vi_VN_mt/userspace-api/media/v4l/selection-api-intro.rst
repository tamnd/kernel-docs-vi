.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/selection-api-intro.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

************
Giới thiệu
************

Một số thiết bị quay video có thể lấy mẫu một phần phụ của hình ảnh và
thu nhỏ hoặc phóng to nó thành một hình ảnh có kích thước tùy ý. Tiếp theo, các thiết bị
có thể chèn hình ảnh vào một hình ảnh lớn hơn. Một số thiết bị đầu ra video có thể cắt
một phần của hình ảnh đầu vào, phóng to hoặc thu nhỏ nó và chèn nó vào một vị trí
đường quét tùy ý và offset ngang thành tín hiệu video. Chúng tôi gọi
những khả năng cắt xén, chia tỷ lệ và sáng tác.

Trên thiết bị video ZZ0000ZZ, nguồn là tín hiệu video và
mục tiêu cắt xén xác định diện tích thực tế được lấy mẫu. Bồn rửa là một
hình ảnh được lưu trữ trong bộ nhớ đệm. Vùng soạn thảo xác định phần nào
của bộ đệm thực sự được ghi vào bởi phần cứng.

Trên thiết bị video ZZ0000ZZ, nguồn là hình ảnh trong bộ nhớ đệm,
và mục tiêu cắt xén là một phần của hình ảnh được hiển thị trên màn hình.
Bồn rửa là màn hình hiển thị hoặc màn hình đồ họa. Ứng dụng có thể
chọn phần hiển thị nơi hình ảnh sẽ được hiển thị. Kích thước
và vị trí của cửa sổ như vậy được kiểm soát bởi mục tiêu soạn thư.

Hình chữ nhật cho tất cả các mục tiêu cắt xén và soạn thảo được xác định ngay cả khi
thiết bị không hỗ trợ cắt xén cũng như soạn thảo. Kích thước của chúng và
vị trí sẽ được cố định trong trường hợp như vậy. Nếu thiết bị không hỗ trợ
chia tỷ lệ thì các hình chữ nhật cắt xén và soạn thảo có cùng kích thước.