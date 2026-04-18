.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/fuse/fuse-passthrough.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==================
Truyền qua FUSE
================

Giới thiệu
============

Chuyển qua FUSE (Hệ thống tệp trong không gian người dùng) là một tính năng được thiết kế để cải thiện
hiệu suất của hệ thống tệp FUSE cho các hoạt động I/O. Thông thường, hoạt động của FUSE
liên quan đến giao tiếp giữa kernel và daemon FUSE của không gian người dùng, có thể
phải chịu chi phí chung. Truyền qua cho phép bỏ qua một số thao tác nhất định trên tệp FUSE
daemon không gian người dùng và được kernel thực thi trực tiếp trên nền tảng
"tập tin sao lưu".

Điều này đạt được nhờ trình nền FUSE đăng ký bộ mô tả tệp (chỉ vào
tệp sao lưu trên hệ thống tệp thấp hơn) bằng mô-đun hạt nhân FUSE. Hạt nhân
sau đó nhận được mã định danh (ZZ0000ZZ) cho tệp sao lưu đã đăng ký này.
Khi tệp FUSE sau đó được mở, trình nền FUSE có thể phản hồi lại
yêu cầu ZZ0001ZZ, hãy bao gồm ZZ0002ZZ này và đặt
Cờ ZZ0003ZZ. Điều này thiết lập một liên kết trực tiếp cho cụ thể
hoạt động.

Hiện tại, tính năng chuyển qua được hỗ trợ cho các hoạt động như ZZ0000ZZ/ZZ0001ZZ
(thông qua ZZ0002ZZ/ZZ0003ZZ), ZZ0004ZZ và ZZ0005ZZ.

Kích hoạt tính năng truyền qua
====================

Để sử dụng thông qua FUSE:

1. Hệ thống tập tin FUSE phải được biên dịch bằng ZZ0000ZZ
     đã bật.
  2. Daemon FUSE, trong quá trình bắt tay ZZ0001ZZ, phải thương lượng
     Khả năng ZZ0002ZZ và chỉ định mong muốn của nó
     ZZ0003ZZ.
  3. Daemon FUSE (đặc quyền) sử dụng ioctl ZZ0004ZZ
     trên bộ mô tả tệp kết nối của nó (ví dụ: ZZ0005ZZ) để đăng ký
     mô tả tập tin sao lưu và lấy ZZ0006ZZ.
  4. Khi xử lý yêu cầu ZZ0007ZZ hoặc ZZ0008ZZ cho tệp FUSE, daemon
     trả lời bằng cờ ZZ0009ZZ được đặt trong
     ZZ0010ZZ và cung cấp ZZ0011ZZ tương ứng
     trong ZZ0012ZZ.
  5. Daemon FUSE cuối cùng sẽ gọi ZZ0013ZZ với
     ZZ0014ZZ để giải phóng tham chiếu của kernel tới tệp sao lưu
     khi nó không còn cần thiết cho việc thiết lập chuyển tiếp.

Yêu cầu đặc quyền
======================

Việc thiết lập chức năng chuyển tiếp hiện yêu cầu trình nền FUSE để
sở hữu khả năng ZZ0000ZZ. Yêu cầu này xuất phát từ một số
những cân nhắc về an ninh và quản lý tài nguyên đang được tích cực
đã thảo luận và làm việc. Những lý do chính cho hạn chế này được trình bày chi tiết
bên dưới.

Kế toán tài nguyên và khả năng hiển thị
----------------------------------

Cơ chế cốt lõi của việc chuyển tiếp liên quan đến trình nền FUSE để mở một tệp
mô tả vào tệp sao lưu và đăng ký nó với mô-đun hạt nhân FUSE thông qua
ZZ0000ZZ ioctl. Ioctl này trả về ZZ0001ZZ
được liên kết với một đối tượng ZZ0002ZZ bên trong kernel, chứa một
tham chiếu đến lớp nền ZZ0003ZZ.

Một mối lo ngại đáng kể nảy sinh vì daemon FUSE có thể đóng tệp của chính nó
mô tả vào tập tin sao lưu sau khi đăng ký. Tuy nhiên, hạt nhân sẽ
vẫn giữ tham chiếu đến ZZ0000ZZ thông qua ZZ0001ZZ
đối tượng miễn là nó được liên kết với ZZ0002ZZ (hoặc sau đó, với
tệp FUSE đang mở ở chế độ chuyển tiếp).

Hành vi này dẫn đến hai vấn đề chính đối với daemon FUSE không có đặc quyền:

1. ZZ0001ZZ: Từng là FUSE
     daemon đóng bộ mô tả tập tin của nó, tập tin sao lưu mở được giữ bởi kernel
     trở nên "ẩn". Các công cụ tiêu chuẩn như ZZ0000ZZ, thường kiểm tra
     bảng mô tả tập tin quá trình, sẽ không thể xác định rằng đây
     tệp vẫn được hệ thống mở thay mặt cho hệ thống tệp FUSE. Cái này
     gây khó khăn cho quản trị viên hệ thống trong việc theo dõi việc sử dụng tài nguyên hoặc
     gỡ lỗi các vấn đề liên quan đến các tệp đang mở (ví dụ: ngăn chặn việc ngắt kết nối).

2. ZZ0003ZZ: Quá trình daemon FUSE phải tuân theo
     giới hạn tài nguyên, bao gồm số lượng mô tả tệp mở tối đa
     (ZZ0000ZZ). Nếu một daemon không có đặc quyền có thể đăng ký các tập tin sao lưu
     và sau đó đóng các FD của chính nó, nó có thể khiến kernel bị giữ lại
     số lượng tài liệu tham khảo ZZ0001ZZ mở không giới hạn mà không có những tài liệu này
     được tính vào ZZ0002ZZ của daemon. Điều này có thể dẫn đến một
     từ chối dịch vụ (DoS) bằng cách làm cạn kiệt tài nguyên tệp trên toàn hệ thống.

Yêu cầu ZZ0000ZZ đóng vai trò như một biện pháp bảo vệ chống lại những vấn đề này,
hạn chế khả năng mạnh mẽ này đối với các quy trình đáng tin cậy.

ZZ0003ZZ: ZZ0000ZZ giải quyết vấn đề tương tự này bằng cách hiển thị "các tệp cố định" của nó,
được hiển thị qua ZZ0001ZZ và được tính theo quyền của người dùng đăng ký
ZZ0002ZZ.

Vòng lặp xếp chồng và tắt hệ thống tập tin
--------------------------------------

Một mối quan tâm khác liên quan đến khả năng tạo ra các vấn đề phức tạp và có vấn đề.
kịch bản xếp chồng hệ thống tập tin nếu người dùng không có đặc quyền có thể thiết lập chuyển tiếp.
Hệ thống tệp chuyển qua FUSE có thể sử dụng tệp sao lưu nằm trong:

* Trên hệ thống tập tin ZZ0000ZZ FUSE.
  * Trên một hệ thống tập tin khác (như OverlayFS) mà bản thân nó có thể có phần trên hoặc phần
    lớp dưới là hệ thống tập tin FUSE.

Những cấu hình này có thể tạo ra các vòng lặp phụ thuộc, đặc biệt trong
tắt hệ thống tập tin hoặc ngắt kết nối các chuỗi, dẫn đến bế tắc hoặc hệ thống
sự bất ổn. Điều này về mặt khái niệm tương tự như những rủi ro liên quan đến
ZZ0000ZZ ioctl, cũng yêu cầu ZZ0001ZZ.

Để giảm thiểu điều này, tính năng chuyển tiếp FUSE đã kết hợp các kiểm tra dựa trên
độ sâu xếp chồng hệ thống tập tin (ZZ0000ZZ và ZZ0001ZZ).
Ví dụ: trong quá trình bắt tay ZZ0002ZZ, daemon FUSE có thể đàm phán
ZZ0003ZZ mà nó hỗ trợ. Khi một tập tin sao lưu được đăng ký thông qua
ZZ0004ZZ, kernel kiểm tra xem tập tin sao lưu có
độ sâu ngăn xếp hệ thống tập tin nằm trong giới hạn cho phép.

Yêu cầu ZZ0000ZZ cung cấp một lớp bảo mật bổ sung,
đảm bảo rằng chỉ những người dùng có đặc quyền mới có thể tạo ra những
sắp xếp xếp chồng.

Tình hình an ninh chung
------------------------

Là nguyên tắc chung cho các tính năng kernel mới cho phép không gian người dùng hướng dẫn
hạt nhân thực hiện các hoạt động trực tiếp thay mặt nó dựa trên sự cung cấp của người dùng
mô tả tập tin, bắt đầu với yêu cầu đặc quyền cao hơn (như
ZZ0000ZZ) là một biện pháp bảo mật phổ biến và thận trọng. Điều này cho phép
tính năng sẽ được sử dụng và thử nghiệm trong khi có những tác động bảo mật khác
được đánh giá và giải quyết.