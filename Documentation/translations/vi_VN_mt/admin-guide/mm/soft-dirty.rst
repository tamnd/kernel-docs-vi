.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/mm/soft-dirty.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================
PTE mềm-bẩn
===============

Tính năng soft-dirty có một chút trên PTE, giúp theo dõi tác vụ ở trang nào
viết vào. Để thực hiện việc theo dõi này người ta phải

1. Xóa các bit bẩn mềm khỏi PTE của nhiệm vụ.

Điều này được thực hiện bằng cách ghi "4" vào tệp ZZ0000ZZ của
     nhiệm vụ được đề cập.

2. Đợi một thời gian.

3. Đọc các bit bẩn mềm từ PTE.

Điều này được thực hiện bằng cách đọc từ ZZ0000ZZ. Bit 55 của
     qword 64-bit là loại mềm bẩn. Nếu được đặt, PTE tương ứng là
     được viết từ bước 1.


Trong nội bộ, để thực hiện việc theo dõi này, bit có thể ghi sẽ bị xóa khỏi PTE
khi bit bẩn mềm bị xóa. Vì vậy, sau đó, khi tác vụ cố gắng
sửa đổi một trang tại một số địa chỉ ảo, #PF xảy ra và bộ kernel
bit bẩn mềm trên PTE tương ứng.

Lưu ý rằng mặc dù tất cả không gian địa chỉ của tác vụ được đánh dấu là r/o sau
các bit bẩn mềm được xóa sạch, #PF-s xảy ra sau đó được xử lý nhanh chóng.
Điều này là như vậy, vì các trang vẫn được ánh xạ tới bộ nhớ vật lý, và do đó tất cả
hạt nhân thực hiện việc tìm ra sự thật này và đặt cả phần mềm có thể ghi và phần mềm
bit trên PTE.

Mặc dù trong hầu hết các trường hợp, việc theo dõi các thay đổi bộ nhớ bằng #PF-s là quá đủ
vẫn có một tình huống là chúng ta có thể mất đi những phần mềm bẩn -- một nhiệm vụ
hủy ánh xạ vùng bộ nhớ được ánh xạ trước đó và sau đó ánh xạ vùng nhớ mới một cách chính xác
cùng một nơi. Khi unmap được gọi, kernel sẽ xóa các giá trị PTE bên trong
bao gồm cả các bit bẩn mềm. Để thông báo cho ứng dụng không gian người dùng về những điều đó
đổi mới vùng bộ nhớ kernel luôn đánh dấu các vùng bộ nhớ mới (và
vùng mở rộng) như mềm bẩn.

Tính năng này được dự án khôi phục điểm kiểm tra sử dụng tích cực. bạn
có thể tìm thêm thông tin chi tiết về nó trên ZZ0000ZZ


-- Pavel Emelyanov, ngày 9 tháng 4 năm 2013
