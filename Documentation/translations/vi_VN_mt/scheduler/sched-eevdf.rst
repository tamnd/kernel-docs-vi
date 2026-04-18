.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scheduler/sched-eevdf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
Bộ lập lịch EEVDF
=================

"Thời hạn ảo đủ điều kiện sớm nhất đầu tiên" (EEVDF) lần đầu tiên được giới thiệu
trong một ấn phẩm khoa học năm 1995 [1]. Nhân Linux bắt đầu
chuyển sang EEVDF trong phiên bản 6.6 (dưới dạng tùy chọn mới vào năm 2024), chuyển
tránh xa Bộ lập lịch hoàn toàn công bằng (CFS) trước đó để chuyển sang một phiên bản
của EEVDF do Peter Zijlstra đề xuất vào năm 2023 [2-4]. Thêm thông tin
về CFS có thể được tìm thấy trong
Tài liệu/lịch trình/sched-design-CFS.rst.

Tương tự như CFS, EEVDF nhằm mục đích phân phối thời gian CPU một cách bình đẳng cho tất cả
các tác vụ có thể chạy được với cùng mức độ ưu tiên. Để làm như vậy, nó chỉ định một lần chạy ảo
thời gian cho mỗi nhiệm vụ, tạo ra giá trị "độ trễ" có thể được sử dụng để xác định
liệu một tác vụ có nhận được phần thời gian CPU hợp lý hay không. Bằng cách này, một nhiệm vụ
với độ trễ dương thì CPU nợ thời gian, trong khi độ trễ âm có nghĩa là nhiệm vụ
đã vượt quá phần của nó. EEVDF chọn các tác vụ có độ trễ lớn hơn hoặc bằng
0 và tính toán thời hạn ảo (VD) cho mỗi nhiệm vụ, chọn nhiệm vụ
với VD sớm nhất sẽ được thực hiện tiếp theo. Điều quan trọng cần lưu ý là điều này
cho phép các tác vụ nhạy cảm với độ trễ với khoảng thời gian ngắn hơn được ưu tiên,
giúp ích cho khả năng phản hồi của họ.

Đang có những cuộc thảo luận về cách quản lý độ trễ, đặc biệt là khi ngủ
nhiệm vụ; nhưng tại thời điểm viết bài EEVDF sử dụng cơ chế "phân rã" dựa trên
về thời gian chạy ảo (VRT). Điều này ngăn chặn các tác vụ khai thác hệ thống
bằng cách ngủ trong thời gian ngắn để thiết lập lại độ trễ tiêu cực của chúng: khi một tác vụ ở chế độ ngủ, nó
vẫn ở trong hàng đợi đang chạy nhưng được đánh dấu là "deferred dequeue", cho phép nó
độ trễ để phân rã trên VRT. Do đó, các tác vụ ngủ lâu cuối cùng cũng có độ trễ
đặt lại. Cuối cùng, các nhiệm vụ có thể ưu tiên các nhiệm vụ khác nếu VD của chúng sớm hơn và các nhiệm vụ
có thể yêu cầu các khoảng thời gian cụ thể bằng lệnh gọi hệ thống sched_setattr() mới,
điều này tạo điều kiện thuận lợi hơn nữa cho công việc của các ứng dụng nhạy cảm với độ trễ.

REFERENCES
==========

[1] ZZ0000ZZ

[2] ZZ0000ZZ

[3] ZZ0000ZZ

[4] ZZ0000ZZ
