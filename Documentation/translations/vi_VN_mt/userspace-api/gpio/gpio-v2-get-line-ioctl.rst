.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/gpio/gpio-v2-get-line-ioctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _GPIO_V2_GET_LINE_IOCTL:

**********************
GPIO_V2_GET_LINE_IOCTL
**********************

Tên
====

GPIO_V2_GET_LINE_IOCTL - Yêu cầu một hoặc nhiều dòng từ kernel.

Tóm tắt
========

.. c:macro:: GPIO_V2_GET_LINE_IOCTL

ZZ0000ZZ

Đối số
=========

ZZ0000ZZ
    Bộ mô tả tệp của thiết bị ký tự GPIO được trả về bởi ZZ0001ZZ.

ZZ0001ZZ
    ZZ0000ZZ chỉ định các dòng
    để yêu cầu và cấu hình của họ.

Sự miêu tả
===========

Nếu thành công, quy trình yêu cầu được cấp quyền truy cập độc quyền vào dòng
giá trị, ghi quyền truy cập vào cấu hình dòng và có thể nhận các sự kiện khi
các cạnh được phát hiện trên đường thẳng, tất cả đều được mô tả chi tiết hơn trong
ZZ0000ZZ.

Một số dòng có thể được yêu cầu trong yêu cầu một dòng và yêu cầu
các hoạt động được hạt nhân thực hiện trên các dòng được yêu cầu dưới dạng nguyên tử
càng tốt. ví dụ. gpio-v2-line-get-values-ioctl.rst sẽ đọc tất cả
dòng yêu cầu cùng một lúc.

Trạng thái của một đường truyền, bao gồm cả giá trị của các đường đầu ra, được đảm bảo
vẫn như được yêu cầu cho đến khi bộ mô tả tệp trả về được đóng lại. Một khi
bộ mô tả tập tin bị đóng, trạng thái của dòng sẽ không được kiểm soát từ
phối cảnh không gian người dùng và có thể trở lại trạng thái mặc định.

Yêu cầu một đường dây đã được sử dụng là một lỗi (ZZ0000ZZ).

Việc đóng ZZ0000ZZ không ảnh hưởng đến các yêu cầu đường dây hiện có.

.. _gpio-v2-get-line-config-rules:

Quy tắc cấu hình
-------------------

Đối với bất kỳ dòng được yêu cầu cụ thể nào, các quy tắc cấu hình sau sẽ được áp dụng:

Các cờ định hướng, ZZ0000ZZ và
ZZ0001ZZ, không thể kết hợp được. Nếu cả hai đều không được đặt thì
cờ duy nhất khác có thể được đặt là ZZ0002ZZ
và dòng được yêu cầu "nguyên trạng" để cho phép đọc giá trị dòng
mà không làm thay đổi cấu hình điện.

Cờ ổ đĩa, ZZ0000ZZ, yêu cầu
ZZ0001ZZ được thiết lập.
Chỉ có thể đặt một cờ ổ đĩa.
Nếu không có thiết lập nào thì đường này được coi là kéo-đẩy.

Chỉ có thể đặt một cờ thiên vị, ZZ0000ZZ, và nó
cũng yêu cầu phải đặt cờ chỉ đường.
Nếu không có cờ thiên vị nào được đặt thì cấu hình thiên vị sẽ không thay đổi.

Cờ biên, ZZ0000ZZ, yêu cầu
ZZ0001ZZ được thiết lập và có thể được kết hợp để phát hiện cả hai
và các cạnh rơi xuống.  Yêu cầu phát hiện cạnh từ một đường không hỗ trợ
đó là một lỗi (ZZ0002ZZ).

Chỉ có thể đặt một cờ đồng hồ sự kiện, ZZ0000ZZ.
Nếu không có cài đặt nào thì đồng hồ sự kiện sẽ mặc định là ZZ0001ZZ.
Cờ ZZ0002ZZ yêu cầu phần cứng hỗ trợ
và một hạt nhân với bộ ZZ0003ZZ.  Yêu cầu HTE từ một thiết bị
không hỗ trợ thì đó là lỗi (ZZ0004ZZ).

Thuộc tính ZZ0000ZZ chỉ có thể
được áp dụng cho các dòng có bộ ZZ0001ZZ. Khi được thiết lập, gỡ lỗi
áp dụng cho cả hai giá trị được trả về bởi gpio-v2-line-get-values-ioctl.rst và
các cạnh được trả về bởi gpio-v2-line-event-read.rst.  Nếu không
được hỗ trợ trực tiếp bởi phần cứng, việc gỡ lỗi được mô phỏng trong phần mềm bởi
hạt nhân.  Yêu cầu gỡ lỗi trên một dòng không hỗ trợ gỡ lỗi trong
phần cứng cũng như sự gián đoạn, theo yêu cầu của việc mô phỏng phần mềm, đều là một lỗi
(ZZ0002ZZ).

Yêu cầu cấu hình không hợp lệ là một lỗi (ZZ0000ZZ).

.. _gpio-v2-get-line-config-support:

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
Gỡ bỏ giả lập
Hướng từ chối
Giả lập ổ đĩa
Từ chối phát hiện cạnh
=============== ============

Xu hướng được coi là nỗ lực tốt nhất để cho phép không gian người dùng áp dụng điều tương tự
cấu hình cho các nền tảng hỗ trợ sai lệch nội bộ như những nền tảng yêu cầu
thiên vị bên ngoài.
Trường hợp xấu nhất là dòng nổi thay vì bị sai lệch như mong đợi.

Việc gỡ lỗi được mô phỏng bằng cách áp dụng bộ lọc cho các ngắt phần cứng trên đường truyền.
Một sự kiện cạnh được tạo sau khi phát hiện một cạnh và đường vẫn còn
ổn định trong thời kỳ suy thoái.
Dấu thời gian sự kiện tương ứng với thời điểm kết thúc giai đoạn gỡ lỗi.

Biến tần được mô phỏng bằng cách chuyển đường dây thành đầu vào khi đường dây không được phép
được chủ động điều khiển.

Phát hiện cạnh yêu cầu hỗ trợ ngắt và bị từ chối nếu điều đó không được đáp ứng
được hỗ trợ. Việc mô phỏng bằng cách bỏ phiếu vẫn có thể được thực hiện từ không gian người dùng.

Trong mọi trường hợp, cấu hình được báo cáo bởi gpio-v2-get-lineinfo-ioctl.rst
là cấu hình được yêu cầu, không phải cấu hình phần cứng kết quả.
Không gian người dùng không thể xác định xem một tính năng có được hỗ trợ trong phần cứng hay không,
được mô phỏng hoặc là nỗ lực tốt nhất.

Giá trị trả về
============

Khi thành công 0 và ZZ0000ZZ chứa
mô tả tập tin cho yêu cầu.

Về lỗi -1 và biến ZZ0000ZZ được đặt phù hợp.
Các mã lỗi phổ biến được mô tả trong error-codes.rst.