.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/cec/cec-ioc-adap-g-phys-addr.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: CEC

.. _CEC_ADAP_PHYS_ADDR:
.. _CEC_ADAP_G_PHYS_ADDR:
.. _CEC_ADAP_S_PHYS_ADDR:

*******************************************************
ioctls CEC_ADAP_G_PHYS_ADDR và CEC_ADAP_S_PHYS_ADDR
*******************************************************

Tên
====

CEC_ADAP_G_PHYS_ADDR, CEC_ADAP_S_PHYS_ADDR - Nhận hoặc đặt địa chỉ vật lý

Tóm tắt
========

.. c:macro:: CEC_ADAP_G_PHYS_ADDR

ZZ0000ZZ

.. c:macro:: CEC_ADAP_S_PHYS_ADDR

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ
    Con trỏ tới địa chỉ CEC.

Sự miêu tả
===========

Để truy vấn các ứng dụng địa chỉ vật lý hiện tại, hãy gọi
ZZ0000ZZ với một con trỏ tới __u16 trong đó
trình điều khiển lưu trữ địa chỉ vật lý.

Để thiết lập một địa chỉ vật lý mới, các ứng dụng sẽ lưu trữ địa chỉ vật lý trong
a __u16 và gọi ZZ0000ZZ bằng một con trỏ tới
số nguyên này. ZZ0001ZZ chỉ khả dụng nếu
ZZ0004ZZ được đặt (mã lỗi ZZ0005ZZ sẽ được trả về
ngược lại). ZZ0002ZZ chỉ có thể được gọi
bởi một bộ mô tả tập tin ở chế độ khởi tạo (xem ZZ0003ZZ), nếu không
mã lỗi ZZ0006ZZ sẽ được trả về.

Để xóa địa chỉ vật lý hiện có, hãy sử dụng ZZ0000ZZ.
Bộ điều hợp sẽ chuyển sang trạng thái chưa được định cấu hình.

Nếu các loại địa chỉ logic đã được xác định (xem ZZ0000ZZ),
thì ioctl này sẽ chặn cho đến khi tất cả
địa chỉ logic được yêu cầu đã được xác nhận. Nếu bộ mô tả tệp ở chế độ không chặn
thì nó sẽ không đợi các địa chỉ logic được xác nhận, thay vào đó nó chỉ trả về 0.

Sự kiện ZZ0000ZZ được gửi khi địa chỉ vật lý
những thay đổi.

Địa chỉ vật lý là một số 16 bit trong đó mỗi nhóm 4 bit
đại diện cho một chữ số của địa chỉ vật lý a.b.c.d trong đó nhiều nhất
4 bit có ý nghĩa đại diện cho 'a'. Thiết bị root CEC (thường là TV)
có địa chỉ 0.0.0.0. Mọi thiết bị được kết nối với đầu vào của
TV có địa chỉ a.0.0.0 (trong đó 'a' là ≥ 1), các thiết bị được kết nối với các thiết bị trong
lần lượt có địa chỉ a.b.0.0, v.v. Vì vậy, cấu trúc liên kết sâu tối đa 5 thiết bị
được hỗ trợ. Địa chỉ vật lý mà thiết bị sẽ sử dụng được lưu trữ trong
EDID của bồn rửa.

Ví dụ: EDID cho mỗi đầu vào HDMI của TV sẽ có một
địa chỉ vật lý khác nhau có dạng a.0.0.0 mà các nguồn sẽ
đọc ra và sử dụng làm địa chỉ vật lý của họ.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

ZZ0000ZZ có thể trả về như sau
mã lỗi:

ENOTTY
    Khả năng ZZ0000ZZ chưa được đặt nên ioctl này không được hỗ trợ.

EBUSY
    Một tước hiệu tệp khác ở chế độ theo dõi hoặc khởi tạo độc quyền, hoặc tước hiệu tệp
    đang ở chế độ ZZ0000ZZ.

EINVAL
    Địa chỉ vật lý không đúng định dạng.