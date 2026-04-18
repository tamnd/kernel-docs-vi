.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/infiniband/tag_matching.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================
Logic khớp thẻ
==================

Tiêu chuẩn MPI xác định một bộ quy tắc, được gọi là khớp thẻ, để khớp
hoạt động gửi nguồn đến đích nhận.  Các thông số sau đây phải
khớp với các tham số nguồn và đích sau:

* Người giao tiếp
* Thẻ người dùng - thẻ đại diện có thể được người nhận chỉ định
* Thứ hạng nguồn – xe hoang dã có thể được người nhận chỉ định
* Xếp hạng đích – hoang dã

Các quy tắc đặt hàng yêu cầu rằng khi có nhiều hơn một cặp gửi và nhận
phong bì thư có thể trùng nhau, cặp bao gồm phong bì được gửi sớm nhất
và lần gửi nhận sớm nhất là cặp phải được sử dụng để đáp ứng
thao tác khớp. Tuy nhiên, điều này không có nghĩa là thẻ được sử dụng trong
thứ tự chúng được tạo, ví dụ: thẻ được tạo sau này có thể được sử dụng, nếu
không thể sử dụng các thẻ trước đó để đáp ứng các quy tắc so khớp.

Khi một tin nhắn được gửi từ người gửi đến người nhận, quá trình giao tiếp
thư viện có thể cố gắng xử lý thao tác sau hoặc trước
nhận được phù hợp tương ứng được đăng.  Nếu một nhận được phù hợp được đăng,
đây là một tin nhắn được mong đợi, nếu không nó được gọi là một tin nhắn không mong đợi.
Việc triển khai thường xuyên sử dụng các sơ đồ kết hợp khác nhau cho hai
trường hợp phù hợp khác nhau.

Để giảm dung lượng bộ nhớ thư viện MPI, việc triển khai MPI thường sử dụng
hai giao thức khác nhau cho mục đích này:

1. Giao thức Eager - tin nhắn hoàn chỉnh được gửi khi quá trình gửi được thực hiện
được người gửi xử lý. Một lần gửi hoàn thành được nhận trong send_cq
thông báo rằng bộ đệm có thể được sử dụng lại.

2. Giao thức Rendezvous - người gửi gửi tiêu đề khớp với thẻ,
và có lẽ là một phần dữ liệu khi thông báo lần đầu cho người nhận. Khi
bộ đệm tương ứng được đăng lên, người phản hồi sẽ sử dụng thông tin từ
tiêu đề để bắt đầu thao tác RDMA READ trực tiếp vào bộ đệm phù hợp.
Cần phải nhận được thông báo vây để bộ đệm được sử dụng lại.

Triển khai đối sánh thẻ
===========================

Có hai loại đối tượng phù hợp được sử dụng, danh sách nhận đã đăng và đối tượng
danh sách tin nhắn bất ngờ. Các bài đăng ứng dụng nhận bộ đệm thông qua các cuộc gọi
tới MPI nhận các thói quen trong danh sách nhận đã đăng và bài đăng gửi tin nhắn
bằng cách sử dụng thói quen gửi MPI. Người đứng đầu danh sách nhận đã đăng có thể là
được duy trì bởi phần cứng, còn phần mềm dự kiến sẽ nằm sau danh sách này.

Khi quá trình gửi được bắt đầu và đến bên nhận, nếu không có
nhận được đăng trước cho tin nhắn đến này, nó sẽ được chuyển đến phần mềm và
được đưa vào danh sách tin nhắn không mong muốn. Nếu không trận đấu sẽ được xử lý,
bao gồm cả việc xử lý điểm hẹn, nếu thích hợp, cung cấp dữ liệu tới
bộ đệm nhận được chỉ định. Điều này cho phép chồng chéo thẻ MPI bên nhận
phù hợp với tính toán.

Khi một tin nhắn nhận được được đăng, thư viện giao tiếp trước tiên sẽ kiểm tra
danh sách tin nhắn không mong muốn của phần mềm để nhận được kết quả phù hợp. Nếu một trận đấu là
được tìm thấy, dữ liệu sẽ được gửi đến bộ đệm của người dùng, sử dụng phần mềm được điều khiển
giao thức. Việc triển khai UCX sử dụng giao thức háo hức hoặc giao thức điểm hẹn,
tùy thuộc vào kích thước dữ liệu. Nếu không tìm thấy kết quả phù hợp, toàn bộ nhận được đăng trước
danh sách được duy trì bởi phần cứng và có không gian để thêm một danh sách nữa
nhận được đăng trước vào danh sách này, nhận được này sẽ được chuyển đến phần cứng.
Phần mềm dự kiến sẽ ẩn danh sách này, giúp xử lý hủy MPI
hoạt động. Ngoài ra, do phần cứng và phần mềm dự kiến sẽ không
được đồng bộ hóa chặt chẽ đối với hoạt động khớp thẻ, bóng này
danh sách được sử dụng để phát hiện trường hợp nhận được đăng trước được chuyển đến
phần cứng, vì thông báo không mong muốn phù hợp đang được truyền từ phần cứng
vào phần mềm.
