.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/gpio/gpio-get-linehandle-ioctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _GPIO_GET_LINEHANDLE_IOCTL:

*************************
GPIO_GET_LINEHANDLE_IOCTL
*************************

.. warning::
    This ioctl is part of chardev_v1.rst and is obsoleted by
    gpio-v2-get-line-ioctl.rst.

Tên
====

GPIO_GET_LINEHANDLE_IOCTL - Yêu cầu một hoặc nhiều dòng từ kernel.

Tóm tắt
========

.. c:macro:: GPIO_GET_LINEHANDLE_IOCTL

ZZ0000ZZ

Đối số
=========

ZZ0000ZZ
    Bộ mô tả tệp của thiết bị ký tự GPIO được trả về bởi ZZ0001ZZ.

ZZ0001ZZ
    ZZ0000ZZ chỉ định các dòng tới
    yêu cầu và cấu hình của họ.

Sự miêu tả
===========

Yêu cầu một hoặc nhiều dòng từ kernel.

Mặc dù có thể yêu cầu nhiều dòng nhưng cấu hình tương tự sẽ áp dụng cho tất cả
dòng trong yêu cầu.

Nếu thành công, quy trình yêu cầu được cấp quyền truy cập độc quyền vào dòng
giá trị và quyền truy cập ghi vào cấu hình dòng.

Trạng thái của một đường truyền, bao gồm cả giá trị của các đường đầu ra, được đảm bảo
vẫn như được yêu cầu cho đến khi bộ mô tả tệp trả về được đóng lại. Một khi
bộ mô tả tập tin bị đóng, trạng thái của dòng sẽ không được kiểm soát từ
phối cảnh không gian người dùng và có thể trở lại trạng thái mặc định.

Yêu cầu một đường dây đã được sử dụng là một lỗi (ZZ0000ZZ).

Việc đóng ZZ0000ZZ không ảnh hưởng đến các bộ điều khiển dòng hiện có.

.. _gpio-get-linehandle-config-rules:

Quy tắc cấu hình
-------------------

Các quy tắc cấu hình sau đây được áp dụng:

Các cờ định hướng, ZZ0000ZZ và
ZZ0001ZZ, không thể kết hợp được. Nếu cả hai đều không được thiết lập thì
chỉ có cờ khác có thể được đặt là ZZ0002ZZ và
dòng được yêu cầu "nguyên trạng" để cho phép đọc giá trị dòng mà không thay đổi
cấu hình điện.

Cờ ổ đĩa, ZZ0000ZZ, yêu cầu
ZZ0001ZZ được thiết lập.
Chỉ có thể đặt một cờ ổ đĩa.
Nếu không có thiết lập nào thì đường này được coi là kéo-đẩy.

Chỉ có thể đặt một cờ thiên vị, ZZ0000ZZ, và
nó cũng yêu cầu phải đặt cờ chỉ đường.
Nếu không có cờ thiên vị nào được đặt thì cấu hình thiên vị sẽ không thay đổi.

Yêu cầu cấu hình không hợp lệ là một lỗi (ZZ0000ZZ).


.. _gpio-get-linehandle-config-support:

Hỗ trợ cấu hình
---------------------

Trường hợp cấu hình được yêu cầu không được hỗ trợ trực tiếp bởi cơ sở
phần cứng và trình điều khiển, kernel áp dụng một trong các cách tiếp cận sau:

- từ chối yêu cầu
 - mô phỏng tính năng trong phần mềm
 - coi tính năng này là nỗ lực tốt nhất

Cách tiếp cận được áp dụng tùy thuộc vào việc tính năng này có thể được mô phỏng hợp lý hay không
trong phần mềm và tác động lên phần cứng cũng như không gian người dùng nếu tính năng này không được
được hỗ trợ.
Cách tiếp cận được áp dụng cho từng tính năng như sau:

=============== ============
Cách tiếp cận tính năng
=============== ============
Nỗ lực hết mình
Hướng từ chối
Giả lập ổ đĩa
=============== ============

Xu hướng được coi là nỗ lực tốt nhất để cho phép không gian người dùng áp dụng điều tương tự
cấu hình cho các nền tảng hỗ trợ sai lệch nội bộ như những nền tảng yêu cầu
thiên vị bên ngoài.
Trường hợp xấu nhất là dòng nổi thay vì bị sai lệch như mong đợi.

Biến tần được mô phỏng bằng cách chuyển đường dây thành đầu vào khi đường dây không được phép
được điều khiển.

Trong mọi trường hợp, cấu hình được báo cáo bởi gpio-get-lineinfo-ioctl.rst
là cấu hình được yêu cầu, không phải cấu hình phần cứng kết quả.
Không gian người dùng không thể xác định xem một tính năng có được hỗ trợ trong phần cứng hay không,
được mô phỏng hoặc là nỗ lực tốt nhất.

Giá trị trả về
============

Khi thành công 0 và ZZ0000ZZ chứa
mô tả tập tin cho yêu cầu.

Về lỗi -1 và biến ZZ0000ZZ được đặt phù hợp.
Các mã lỗi phổ biến được mô tả trong error-codes.rst.