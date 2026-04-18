.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/pcmcia/driver.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==============
Trình điều khiển PCMCIA
=============

sysfs
-----

ID PCMCIA mới có thể được thêm vào bảng pcmcia_device_id của trình điều khiển thiết bị tại
thời gian chạy như hình dưới đây::

echo "match_flags manf_id card_id chức năng func_id device_no \
  prod_id_hash[0] prod_id_hash[1] prod_id_hash[2] prod_id_hash[3]" > \
  /sys/bus/pcmcia/drivers/{driver}/new_id

Tất cả các trường được chuyển vào dưới dạng giá trị thập lục phân (không có 0x đứng đầu).
Ý nghĩa được mô tả trong đặc tả PCMCIA, match_flags là
sự kết hợp theo chiều bit hoặc-ed từ hằng số PCMCIA_DEV_ID_MATCH_*
được định nghĩa trong include/linux/mod_devicetable.h.

Sau khi được thêm vào, quy trình thăm dò trình điều khiển sẽ được gọi cho bất kỳ thông tin nào chưa được xác nhận quyền sở hữu.
Thiết bị PCMCIA được liệt kê trong danh sách pcmcia_device_id (mới cập nhật).

Trường hợp sử dụng phổ biến là thêm thiết bị mới theo ID nhà sản xuất
và ID thẻ (tạo thành tệp manf_id và card_id trong cây thiết bị).
Đối với điều này, chỉ cần sử dụng::

echo "0x3 manf_id card_id 0 0 0 0 0 0 0" > \
    /sys/bus/pcmcia/drivers/{driver}/new_id

sau khi nạp driver.
