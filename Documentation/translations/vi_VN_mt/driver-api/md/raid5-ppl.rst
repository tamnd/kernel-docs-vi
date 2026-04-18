.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/md/raid5-ppl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================
Nhật ký chẵn lẻ một phần
==================

Nhật ký chẵn lẻ một phần (PPL) là một tính năng có sẵn cho mảng RAID5. vấn đề
được giải quyết bởi PPL là sau khi tắt máy không đúng cách, tính chẵn lẻ của một sọc cụ thể
có thể trở nên không nhất quán với dữ liệu trên các đĩa thành viên khác. Nếu mảng cũng
ở trạng thái xuống cấp, không có cách nào để tính toán lại tính chẵn lẻ, bởi vì một trong
đĩa bị thiếu. Điều này có thể dẫn đến hỏng dữ liệu thầm lặng khi xây dựng lại hệ thống.
mảng hoặc sử dụng nó đều bị xuống cấp - dữ liệu được tính từ tính chẵn lẻ cho các khối mảng
chưa được chạm tới bởi yêu cầu ghi trong quá trình tắt máy không sạch có thể
có thể không chính xác. Tình trạng như vậy được gọi là Lỗ ghi RAID5. Bởi vì
điều này, md theo mặc định không cho phép bắt đầu một mảng xuống cấp bẩn.

Tính chẵn lẻ một phần cho thao tác ghi là XOR của các khối dữ liệu sọc không
được sửa đổi bởi bài viết này. Nó chỉ đủ dữ liệu cần thiết để phục hồi từ
viết lỗ. XOR tính chẵn lẻ một phần với các khối được sửa đổi sẽ tạo ra tính chẵn lẻ cho
sọc, nhất quán với trạng thái của nó trước thao tác ghi, bất kể
đoạn viết nào đã hoàn thành. Nếu một trong các đĩa dữ liệu chưa được sửa đổi của
sọc này bị thiếu, tính chẵn lẻ được cập nhật này có thể được sử dụng để khôi phục nó
nội dung. Việc khôi phục PPL cũng được thực hiện khi bắt đầu một mảng sau một
tắt máy không sạch và tất cả các đĩa đều có sẵn, loại bỏ nhu cầu đồng bộ lại
mảng. Vì lý do này, việc sử dụng bitmap có mục đích ghi và PPL cùng nhau là không
được hỗ trợ.

Khi xử lý yêu cầu ghi PPL ghi một phần chẵn lẻ trước dữ liệu mới và
tính chẵn lẻ được gửi tới đĩa. PPL là nhật ký phân tán - nó được lưu trữ trên
các ổ đĩa thành viên mảng trong vùng siêu dữ liệu, trên ổ đĩa chẵn lẻ của một ổ đĩa cụ thể
sọc.  Nó không yêu cầu một ổ ghi nhật ký chuyên dụng. Hiệu suất ghi là
giảm tới 30%-40% nhưng nó tăng theo số lượng ổ đĩa trong mảng
và ổ ghi nhật ký không trở thành nút thắt cổ chai hoặc một điểm dừng duy nhất
thất bại.

Không giống như raid5-cache, giải pháp khác trong md để đóng lỗ ghi, PPL là
không phải là một cuốn nhật ký thực sự. Nó không bảo vệ khỏi bị mất dữ liệu trên chuyến bay, chỉ khỏi
tham nhũng dữ liệu im lặng. Nếu một đĩa sọc bẩn bị mất, không thể khôi phục PPL
được thực hiện cho dải này (tính chẵn lẻ không được cập nhật). Vì vậy có thể có
dữ liệu tùy ý trong phần ghi của sọc nếu đĩa đó bị mất. Trong đó
trường hợp hành vi tương tự như trong raid5 đơn giản.

PPL có sẵn cho siêu dữ liệu md phiên bản 1 và bên ngoài (cụ thể là IMSM)
mảng siêu dữ liệu. Nó có thể được kích hoạt bằng tùy chọn mdadm --consistency-policy=ppl.

Có giới hạn tối đa 64 đĩa trong mảng cho PPL. Nó cho phép
giữ cấu trúc dữ liệu và thực hiện đơn giản. Mảng RAID5 có rất nhiều đĩa
không có khả năng xảy ra do nguy cơ hỏng nhiều đĩa cao. Hạn chế như vậy
không nên là một hạn chế trong cuộc sống thực.
