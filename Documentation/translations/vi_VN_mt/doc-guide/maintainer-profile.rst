.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/doc-guide/maintainer-profile.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Hồ sơ mục nhập của người bảo trì hệ thống con tài liệu
================================================

"Hệ thống con" tài liệu là điểm điều phối trung tâm cho
tài liệu của kernel và cơ sở hạ tầng liên quan.  Nó bao gồm
phân cấp trong Documentation/ (ngoại trừ
Documentation/devicetree), các tiện ích khác nhau dưới scripts/ và, ít nhất
đôi khi, LICENSES/.

Tuy nhiên, cần lưu ý rằng ranh giới của hệ thống con này khá
mờ hơn bình thường.  Nhiều người bảo trì hệ thống con khác muốn giữ quyền kiểm soát
của các phần của Tài liệu/ và nhiều thay đổi khác được áp dụng tự do ở đó
khi thuận tiện.  Ngoài ra, phần lớn tài liệu của kernel là
được tìm thấy trong nguồn dưới dạng nhận xét kerneldoc; đó thường là (nhưng không phải
luôn luôn) được duy trì bởi người bảo trì hệ thống con có liên quan.

Danh sách gửi thư cho tài liệu là linux-doc@vger.kernel.org.  Bản vá lỗi
nên được thực hiện dựa trên cây tài liệu tiếp theo bất cứ khi nào có thể.

Gửi phụ lục danh sách kiểm tra
-------------------------

Khi thực hiện thay đổi tài liệu, bạn thực sự nên xây dựng
tài liệu và đảm bảo rằng không có lỗi hoặc cảnh báo mới nào được phát hiện
được giới thiệu.  Tạo tài liệu HTML và xem kết quả sẽ giúp ích
để tránh những hiểu lầm khó coi về cách mọi thứ sẽ được hiển thị.

Tất cả các tài liệu mới (bao gồm cả phần bổ sung cho các tài liệu hiện có) phải
một cách lý tưởng để chứng minh đối tượng mục tiêu dự định là ai ở đâu đó trong
nhật ký thay đổi; bằng cách này, chúng tôi đảm bảo rằng tài liệu kết thúc ở đúng
nơi.  Một số loại có thể là: nhà phát triển hạt nhân (chuyên gia hoặc
người mới bắt đầu), người lập trình không gian người dùng, người dùng cuối và/hoặc quản trị viên hệ thống,
và các nhà phân phối.

Ngày chu kỳ chính
---------------

Các bản vá có thể được gửi bất cứ lúc nào, nhưng phản hồi sẽ chậm hơn bình thường trong thời gian
cửa sổ hợp nhất.  Cây tài liệu có xu hướng đóng muộn trước khi hợp nhất
cửa sổ mở ra, vì nguy cơ hồi quy từ các bản vá tài liệu là
thấp.

Xem lại nhịp
--------------

Tôi là người duy nhất duy trì hệ thống con tài liệu và tôi đang thực hiện
tôi làm việc theo thời gian riêng của mình nên thỉnh thoảng phản hồi về các bản vá sẽ bị chậm
chậm.  Tôi cố gắng luôn gửi thông báo khi một bản vá được hợp nhất (hoặc
khi tôi quyết định rằng điều đó là không thể).  Đừng ngần ngại gửi ping nếu bạn
đã không nhận được phản hồi trong vòng một tuần kể từ khi gửi bản vá.