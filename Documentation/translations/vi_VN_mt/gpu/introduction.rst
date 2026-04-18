.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/introduction.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============
Giới thiệu
============

Lớp DRM của Linux chứa mã nhằm hỗ trợ các nhu cầu của
các thiết bị đồ họa phức tạp, thường chứa các đường ống có thể lập trình tốt
phù hợp với khả năng tăng tốc đồ họa 3D. Trình điều khiển đồ họa trong kernel có thể
sử dụng các chức năng DRM để thực hiện các tác vụ như quản lý bộ nhớ,
xử lý ngắt và DMA dễ dàng hơn, đồng thời cung cấp giao diện thống nhất cho
ứng dụng.

Lưu ý về các phiên bản: hướng dẫn này bao gồm các tính năng có trong cây DRM,
bao gồm trình quản lý bộ nhớ TTM, cấu hình đầu ra và cài đặt chế độ,
và nội bộ vblank mới, bên cạnh tất cả các tính năng thông thường
được tìm thấy trong hạt nhân hiện tại.

[Thêm sơ đồ ngăn xếp DRM điển hình vào đây]

Nguyên tắc về phong cách
================

Để nhất quán, tài liệu này sử dụng tiếng Anh Mỹ. Chữ viết tắt
được viết hoàn toàn bằng chữ hoa, ví dụ: DRM, KMS, IOCTL, CRTC, v.v.
trên. Để hỗ trợ việc đọc, tài liệu tận dụng tối đa đánh dấu
ký tự kerneldoc cung cấp: @parameter cho các tham số hàm,
@member dành cho các thành viên cấu trúc (trong cùng một cấu trúc), &struct cấu trúc để
cấu trúc tham chiếu và hàm() cho hàm. Tất cả đều được tự động
siêu liên kết nếu kerneldoc cho các đối tượng được tham chiếu tồn tại. Khi tham khảo
các mục trong hàm vtables (và các thành viên cấu trúc nói chung) vui lòng sử dụng
&vtable_name.vfunc. Thật không may, điều này vẫn chưa mang lại một liên kết trực tiếp tới
thành viên, chỉ có cấu trúc.

Ngoại trừ các trường hợp đặc biệt (để tách các biến thể bị khóa khỏi các biến thể đã mở khóa)
yêu cầu khóa đối với các hàm không được ghi lại trong kerneldoc.
Thay vào đó, nên kiểm tra khóa trong thời gian chạy bằng cách sử dụng ví dụ:
ZZ0000ZZ. Vì việc bỏ qua sẽ dễ dàng hơn nhiều
tài liệu hơn tiếng ồn thời gian chạy, điều này mang lại nhiều giá trị hơn. Và trên hết
việc kiểm tra thời gian chạy cần phải được cập nhật khi quy tắc khóa thay đổi,
tăng khả năng chúng đúng. Trong tài liệu
các quy tắc khóa cần được giải thích trong các cấu trúc có liên quan: Hoặc
trong phần bình luận về khóa giải thích những gì nó bảo vệ hoặc các trường dữ liệu
cần lưu ý về khóa nào bảo vệ chúng hoặc cả hai.

Các hàm có giá trị trả về không phải\ZZ0000ZZ phải có một phần
được gọi là "Trả về" giải thích các giá trị trả về dự kiến theo các cách khác nhau
trường hợp và ý nghĩa của chúng. Hiện tại không có sự đồng thuận liệu điều đó
tên phần có nên viết hoa hay không và liệu nó có kết thúc không
trong dấu hai chấm hay không. Đi theo phong cách tập tin cục bộ. Phần chung khác
tên là "Ghi chú" với thông tin cho các trường hợp góc nguy hiểm hoặc khó khăn,
và "FIXME" nơi giao diện có thể được dọn dẹp.

Cũng đọc ZZ0000ZZ.

Yêu cầu về tài liệu cho kAPI
-----------------------------------

Tất cả các API hạt nhân được xuất sang các mô-đun khác phải được ghi lại, bao gồm cả
cơ sở hạ tầng và ít nhất một phần giới thiệu ngắn giải thích tổng thể
các khái niệm. Tài liệu nên được đưa vào chính mã dưới dạng nhận xét kerneldoc
bao nhiêu thì hợp lý bấy nhiêu.

Đừng ghi chép một cách mù quáng mọi thứ mà chỉ ghi lại những gì liên quan đến người lái xe
tác giả: Các chức năng bên trong của drm.ko và các chức năng tĩnh chắc chắn không nên
có nhận xét kerneldoc chính thức. Sử dụng bình luận C bình thường nếu bạn cảm thấy thích một bình luận
được bảo hành. Bạn có thể sử dụng cú pháp kerneldoc trong bình luận, nhưng không được
bắt đầu bằng dấu /** kerneldoc. Tương tự với cấu trúc dữ liệu, chú thích
bất cứ điều gì hoàn toàn riêng tư với các nhận xét ZZ0000ZZ theo
hướng dẫn tài liệu.

Bắt đầu
===============

Rất hoan nghênh các nhà phát triển quan tâm đến việc trợ giúp hệ thống con DRM.
Thông thường mọi người sẽ gửi các bản vá lỗi cho nhiều vấn đề khác nhau được báo cáo bởi
bản vá kiểm tra hoặc thưa thớt. Chúng tôi hoan nghênh những đóng góp như vậy.

Bất cứ ai muốn nâng cao nó lên một tầm cao mới có thể tìm thấy danh sách các công việc lao công trên
ZZ0000ZZ.

Quy trình đóng góp
====================

Hầu hết hệ thống con DRM hoạt động giống như bất kỳ hệ thống con hạt nhân nào khác, hãy xem ZZ0000ZZ để biết mọi thứ hoạt động như thế nào.
Ở đây chúng tôi chỉ ghi lại một số đặc điểm của hệ thống con GPU.

Thời hạn hợp nhất tính năng
-----------------------

Tất cả công việc tính năng phải nằm trong cây linux-next trước bản phát hành -rc6 của
chu kỳ phát hành hiện tại, nếu không chúng phải bị hoãn lại và không thể đạt được chu kỳ tiếp theo
cửa sổ hợp nhất. Tất cả các bản vá phải có trong cây drm-next muộn nhất -rc7,
nhưng nếu nhánh của bạn không có trong linux-next thì điều này chắc chắn đã xảy ra bởi -rc6
rồi.

Sau thời điểm đó chỉ sửa lỗi (như sau khi cửa sổ hợp nhất ngược dòng đã đóng
với bản phát hành -rc1) đều được cho phép. Không có nền tảng mới nào kích hoạt hoặc trình điều khiển mới
được phép.

Điều này có nghĩa là sẽ có khoảng thời gian ngừng hoạt động trong khoảng một tháng khi tính năng này hoạt động
không thể sáp nhập được. Cách được đề xuất để giải quyết vấn đề đó là có cây -next
nó luôn mở, nhưng hãy đảm bảo không đưa nó vào linux-next trong quá trình
thời kỳ mất điện. Ví dụ, drm-misc hoạt động như thế.

Quy tắc ứng xử
---------------

Là một dự án freedesktop.org, dri-devel và cộng đồng DRM tuân theo
Giao ước cộng tác viên, được tìm thấy tại: ZZ0000ZZ

Hãy cư xử một cách tôn trọng và văn minh khi
tương tác với các thành viên cộng đồng trên danh sách gửi thư, IRC hoặc lỗi
máy theo dõi. Cộng đồng đại diện cho toàn bộ dự án và lạm dụng
hoặc hành vi bắt nạt không được dự án chấp nhận.

Trình điều khiển DRM đơn giản để sử dụng làm ví dụ
=====================================

Hệ thống con DRM chứa rất nhiều chức năng trợ giúp để dễ dàng viết trình điều khiển cho
thiết bị đồ họa đơn giản. Ví dụ: thư mục ZZ0000ZZ có
bộ trình điều khiển đủ đơn giản để triển khai trong một tệp nguồn duy nhất.
Trình điều khiển DRM nhỏ bé là ví dụ điển hình để hiểu trình điều khiển DRM trông như thế nào
thích. Vì chỉ có vài trăm dòng mã nên chúng khá dễ đọc.

Tài liệu tham khảo bên ngoài
===================

Việc đào sâu vào hệ thống con nhân Linux lần đầu tiên có thể là một điều quá sức
kinh nghiệm, người ta cần phải làm quen với tất cả các khái niệm và tìm hiểu về
nội bộ của hệ thống con, trong số các chi tiết khác.

Để thu hẹp đường cong học tập, phần này chứa danh sách các bài thuyết trình
và các tài liệu có thể được sử dụng để tìm hiểu về DRM/KMS và đồ họa nói chung.

Có nhiều lý do khác nhau khiến ai đó có thể muốn truy cập vào DRM: chuyển một
trình điều khiển fbdev hiện có, viết trình điều khiển DRM cho phần cứng mới, sửa các lỗi
có thể gặp phải khi làm việc trên ngăn xếp không gian người dùng đồ họa, v.v. Vì lý do này,
tài liệu học tập đề cập đến nhiều khía cạnh của hệ thống đồ họa Linux. Từ một
tổng quan về ngăn xếp hạt nhân và không gian người dùng cho các chủ đề rất cụ thể.

Danh sách được sắp xếp theo trình tự thời gian đảo ngược để cập nhật thông tin mới nhất
chất liệu ở trên cùng. Nhưng tất cả chúng đều chứa thông tin hữu ích và có thể
có giá trị để xem lại tài liệu cũ hơn để hiểu lý do căn bản và bối cảnh
trong đó các thay đổi đối với hệ thống con DRM đã được thực hiện.

Hội nghị tọa đàm
----------------

* ZZ0000ZZ - Paul Kocialkowski (2020)
* ZZ0001ZZ - Simon Ser (2020)
* ZZ0002ZZ - Simona Vetter (2019)
* ZZ0003ZZ - Maxime Ripard (2017)
* ZZ0004ZZ - Simona Vetter (2016)
* ZZ0005ZZ - Laurent Pinchart (2015)
* ZZ0006ZZ - Simona Vetter (2015)
* ZZ0007ZZ - Laurent Pinchart (2013)

Slide và bài viết
-------------------

* ZZ0000ZZ - Thomas Zimmermann (2023)
* ZZ0001ZZ - Thomas Zimmermann (2023)
* ZZ0002ZZ - Bootlin (2022)
* ZZ0003ZZ - STMicroelectronics (2021)
* ZZ0004ZZ - Nathan Gauër (2017)
* ZZ0005ZZ - Simona Vetter (2015)
* ZZ0006ZZ - Simona Vetter (2015)
* ZZ0007ZZ - Boris Brezillon (2014)
* ZZ0008ZZ - Iago Toral (2014)
* ZZ0009ZZ - Jasper St. Pierre (2012)
