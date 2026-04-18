.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/locks.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================
Ghi chú phát hành khóa tệp
==========================

Andy Walker <andy@lysaker.kvaerner.no>

12 tháng 5 năm 1997


1. Có gì mới?
==============

1.1 Thi Đua Bẻ Đàn
--------------------------

Mô phỏng đàn cũ (2) trong kernel đã được đổi chỗ cho BSD thích hợp
hỗ trợ đàn (2) tương thích trong loạt hạt nhân 1.3.x. Với
phát hành loạt kernel 2.1.x, hỗ trợ cho mô phỏng cũ đã
đã được loại bỏ hoàn toàn nên chúng ta không cần phải mang theo hành lý này
mãi mãi.

Điều này sẽ không gây ra vấn đề gì cho bất kỳ ai vì mọi người sử dụng
Kernel 2.1.x nên cập nhật thư viện C của họ lên phiên bản phù hợp
dù sao đi nữa (xem tệp "Tài liệu/quy trình/changes.rst".)

1.2 Cho phép khóa hỗn hợp lần nữa
---------------------------

1.2.1 Sự cố điển hình - Sendmail
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Bởi vì sendmail không thể sử dụng mô phỏng Flock() cũ nên nhiều sendmail
cài đặt sử dụng fcntl() thay vì đàn(). Điều này đúng với Slackware 3.0
chẳng hạn. Điều này đã gây ra một số vấn đề khó phát hiện khác nếu việc gửi thư được thực hiện
được cấu hình để xây dựng lại tệp bí danh. Sendmail đã cố khóa aliases.dir
tệp có fcntl() cùng lúc với các quy trình GDBM đã cố gắng khóa tệp này
tập tin với đàn(). Với các hạt nhân trước 1.3.96, điều này có thể dẫn đến bế tắc,
theo thời gian hoặc do tải thư quá nặng, cuối cùng sẽ khiến kernel
để khóa vững chắc các tiến trình bị bế tắc.


1.2.2 Giải pháp
^^^^^^^^^^^^^^^^^^
Giải pháp tôi đã chọn, sau nhiều thử nghiệm và thảo luận,
là làm cho các ổ khóa fcntl() và fcntl() không biết lẫn nhau. Cả hai đều có thể
tồn tại và không cái nào sẽ có bất kỳ ảnh hưởng nào đến cái kia.

Tôi muốn hai kiểu khóa có thể hợp tác với nhau nhưng có quá nhiều kiểu khóa.
tình trạng chạy đua và bế tắc mà giải pháp hiện tại là giải pháp duy nhất
một điều thực tế. Nó đặt chúng ta vào vị trí tương tự như SunOS chẳng hạn
4.1.x và một số Unice thương mại khác. Hệ điều hành duy nhất hỗ trợ
đàn hợp tác()/fcntl() là những nhóm mô phỏng đàn chiên() bằng cách sử dụng
fcntl(), với tất cả các vấn đề tiềm ẩn.


1.3 Khóa bắt buộc dưới dạng tùy chọn gắn kết
---------------------------------------

Khóa bắt buộc trước phiên bản này là một tùy chọn cấu hình chung
điều đó hợp lệ cho tất cả các hệ thống tập tin được gắn kết.  Điều này có một số tính chất vốn có
nguy hiểm, trong đó ít nhất là khả năng đóng băng máy chủ NFS bằng cách
yêu cầu nó đọc một tập tin đã tồn tại khóa bắt buộc.

Tùy chọn như vậy đã bị loại bỏ trong Kernel v5.14.