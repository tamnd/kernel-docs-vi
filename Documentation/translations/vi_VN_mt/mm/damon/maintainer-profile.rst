.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/mm/damon/maintainer-profile.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Hồ sơ đăng nhập của người bảo trì DAMON
==============================

Hệ thống con DAMON bao gồm các tệp được liệt kê trong phần 'DAMON' của
Tệp 'MAINTAINERS'.

Danh sách gửi thư cho hệ thống con là damon@lists.linux.dev và
linux-mm@kvack.org.  Các bản vá nên được thực hiện đối với ZZ0000ZZ bất cứ khi nào có thể và đăng lên
danh sách gửi thư.

Cây SCM
---------

Có nhiều cây Linux để phát triển DAMON.  Các bản vá dưới
việc phát triển hoặc thử nghiệm được người bảo trì DAMON xếp hàng đợi trong ZZ0000ZZ.
Các bản vá được xem xét đầy đủ sẽ được hệ thống con quản lý bộ nhớ xếp hàng đợi trong ZZ0001ZZ
người bảo trì.  Khi các thử nghiệm đầy đủ hơn được thực hiện, các bản vá sẽ chuyển sang
ZZ0002ZZ rồi đến
ZZ0003ZZ.  Và cuối cùng những
sẽ được hệ thống con quản lý bộ nhớ kéo vào dòng chính
người bảo trì.

Lưu ý một lần nữa các bản vá cho ZZ0000ZZ được quản lý bộ nhớ xếp hàng đợi
người bảo trì hệ thống con.  Nếu các bản vá yêu cầu một số bản vá trong ZZ0001ZZ chưa được hợp nhất trong mm-new,
hãy chắc chắn rằng yêu cầu được chỉ định rõ ràng.

Gửi phụ lục danh sách kiểm tra
-------------------------

Khi thực hiện thay đổi DAMON, bạn nên thực hiện dưới đây.

- Xây dựng các thay đổi liên quan đến đầu ra bao gồm kernel và tài liệu.
- Đảm bảo các bản dựng không có lỗi hoặc cảnh báo mới.
- Chạy và đảm bảo không có lỗi mới cho DAMON ZZ0000ZZ và
  ZZ0001ZZ.

Tiếp tục làm dưới đây và đưa ra kết quả sẽ hữu ích.

- Chạy ZZ0000ZZ bình thường
  những thay đổi.
- Đo lường tác động lên điểm chuẩn hoặc khối lượng công việc trong thế giới thực để đạt được hiệu suất
  những thay đổi.

Ngày chu kỳ chính
---------------

Các bản vá có thể được gửi bất cứ lúc nào.  Ngày chu kỳ chính của cây ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ phụ thuộc vào bộ nhớ
người duy trì hệ thống con quản lý.

Xem lại nhịp
--------------

Người bảo trì DAMON thường làm việc linh hoạt, ngoại trừ sáng sớm ở PT
(Giờ Thái Bình Dương).  Phản hồi với các bản vá đôi khi sẽ chậm.  Đừng
ngần ngại gửi ping nếu bạn không nhận được phản hồi trong vòng một tuần sau khi gửi
vá.

Công cụ gửi thư
------------

Giống như nhiều hệ thống con nhân Linux khác, DAMON sử dụng danh sách gửi thư
(damon@lists.linux.dev và linux-mm@kvack.org) là phương tiện liên lạc chính
kênh.  Có một công cụ đơn giản tên là ZZ0001ZZ (ZZ0000ZZ), dành cho những người
không quen lắm với cách giao tiếp dựa trên danh sách gửi thư.  công cụ
có thể đặc biệt hữu ích cho các thành viên cộng đồng DAMON vì nó được phát triển
và được duy trì bởi người bảo trì DAMON.  Công cụ này cũng được công bố chính thức tới
hỗ trợ DAMON và quy trình phát triển nhân Linux chung.

Nói cách khác, ZZ0000ZZ là một dịch vụ gửi thư
công cụ dành cho cộng đồng DAMON mà nhà bảo trì DAMON cam kết hỗ trợ.
Vui lòng thử và báo cáo sự cố hoặc yêu cầu tính năng cho công cụ này.
người bảo trì.

Gặp gỡ cộng đồng
----------------

Cộng đồng DAMON có chuỗi buổi gặp mặt hai tuần một lần dành cho những thành viên thích
các cuộc hội thoại đồng bộ qua thư.  Nó dành cho các cuộc thảo luận về các chủ đề cụ thể
giữa một nhóm thành viên bao gồm cả người bảo trì.  Người bảo trì chia sẻ
các khoảng thời gian có sẵn và người tham dự nên đặt trước một trong số đó ít nhất 24
vài giờ trước khung thời gian, bằng cách liên hệ với người bảo trì.

Lịch trình và trạng thái đặt chỗ có sẵn tại Google ZZ0000ZZ.
Ngoài ra còn có Google ZZ0001ZZ công khai
nơi đó có các sự kiện  Bất cứ ai cũng có thể đăng ký nó.  Người bảo trì DAMON cũng sẽ
cung cấp lời nhắc định kỳ cho danh sách gửi thư (damon@lists.linux.dev).