.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/cards/img-spdif-in.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================================
Công nghệ tưởng tượng Bộ điều khiển đầu vào SPDIF
================================================

Bộ điều khiển đầu vào Imagination Technologies SPDIF chứa các thành phần sau:
điều khiển:

* name='IEC958 Capture Mask',index=0

Điều khiển này trả về một mặt nạ hiển thị bit trạng thái IEC958 nào
có thể được đọc bằng cách sử dụng điều khiển 'IEC958 Capture Default'.

* name='IEC958 Chụp mặc định',index=0

Điều khiển này trả về các bit trạng thái chứa trong luồng SPDIF
đang được nhận. 'Mặt nạ chụp IEC958' hiển thị những bit nào có thể đọc được
từ sự kiểm soát này.

* name='SPDIF trong thu thập đa tần số',index=0
* name='SPDIF trong thu thập đa tần số',index=1
* name='SPDIF trong thu thập đa tần số',index=2
* name='SPDIF trong thu thập đa tần số',index=3

Điều khiển này được sử dụng để cố gắng thu thập tối đa bốn mẫu khác nhau
tỷ giá. Tỷ lệ hoạt động có thể đạt được bằng cách đọc 'Tần số khóa SPDIF'
kiểm soát.

Khi giá trị của điều khiển này được đặt thành {0,0,0,0}, tốc độ được cung cấp cho hw_params
sẽ xác định tỷ lệ duy nhất mà khối sẽ nắm bắt. Mặt khác, tỷ lệ được đưa ra cho
hw_params sẽ bị bỏ qua và khối sẽ cố gắng chụp từng
bốn tỷ lệ mẫu được đặt ở đây.

Nếu yêu cầu ít hơn bốn mức thì cùng một mức có thể được chỉ định nhiều hơn
một lần

* name='SPDIF ở tần số khóa',index=0

Điều khiển này trả về tốc độ chụp hiện hoạt hoặc 0 nếu khóa chưa được
có được

* name='SPDIF Trong Khóa TRK',index=0

Điều khiển này được sử dụng để sửa đổi các đặc tính loại bỏ khóa/jitter
của khối. Giá trị lớn hơn sẽ tăng phạm vi khóa nhưng giảm hiện tượng jitter
sự từ chối.

* name='SPDIF Trong Khóa Đạt Ngưỡng',index=0

Điều khiển này được sử dụng để thay đổi ngưỡng mà khóa được lấy.

* name='SPDIF Trong ngưỡng phát hành khóa',index=0

Điều khiển này được sử dụng để thay đổi ngưỡng mở khóa.
