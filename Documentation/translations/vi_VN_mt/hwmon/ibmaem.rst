.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/ibmaem.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân ibmaem
====================

Người lái xe này nói chuyện với Giám đốc Hệ thống IBM Giám đốc Năng lượng Tích cực, được biết đến
từ nay trở đi là AEM.

Các hệ thống được hỗ trợ:

* Bất kỳ máy chủ IBM System X nào gần đây có hỗ trợ AEM.

Điều này bao gồm x3350, x3550, x3650, x3655, x3755, x3850 M2,
    x3950 M2 và một số lưỡi HC10/HS2x/LS2x/QS2x nhất định.

Giao diện máy chủ IPMI
    trình điều khiển ("ipmi-si") cần được tải để trình điều khiển này thực hiện bất kỳ tác vụ nào.

Tiền tố: 'ibmaem'

Bảng dữ liệu: Không có sẵn

Tác giả: Darrick J. Wong

Sự miêu tả
-----------

Trình điều khiển này triển khai hỗ trợ đọc cảm biến cho đồng hồ đo năng lượng và công suất
có sẵn trên nhiều phần cứng IBM System X khác nhau thông qua BMC.  Tất cả các ngân hàng cảm biến
sẽ được xuất dưới dạng thiết bị nền tảng; driver này có thể nói chuyện với cả v1 và v2
giao diện.  Trình điều khiển này hoàn toàn tách biệt với trình điều khiển ibmpex cũ hơn.

Giao diện v1 AEM có một bộ tính năng đơn giản để giám sát việc sử dụng năng lượng.  Ở đó
là một sổ đăng ký hiển thị ước tính mức tiêu thụ năng lượng thô kể từ
lần thiết lập lại BMC gần đây nhất và cảm biến công suất trả về mức sử dụng năng lượng trung bình trong một thời gian
khoảng thời gian có thể cấu hình.

Giao diện v2 AEM phức tạp hơn một chút, có thể hiển thị phạm vi rộng hơn
phạm vi thanh ghi sử dụng năng lượng và năng lượng, giới hạn nguồn do AEM đặt
phần mềm và cảm biến nhiệt độ.

Tính năng đặc biệt
----------------

Giá trị "power_cap" hiển thị giới hạn nguồn hệ thống hiện tại do AEM đặt
phần mềm.  Hiện không hỗ trợ cài đặt giới hạn nguồn từ máy chủ.
