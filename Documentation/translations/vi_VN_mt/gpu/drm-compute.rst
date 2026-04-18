.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/drm-compute.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================================
Khối lượng công việc và điện toán chạy dài
==========================================

Khối lượng công việc chạy dài (tính toán) là khối lượng công việc sẽ không hoàn thành trong 10
giây. (Thời gian để người dùng chờ trước khi chạm vào nút nguồn).
Điều này có nghĩa là cần sử dụng các kỹ thuật khác để quản lý khối lượng công việc đó,
không thể sử dụng hàng rào.

Một số phần cứng có thể lên lịch các công việc điện toán và không có cách nào để thực hiện trước chúng, hoặc
trí nhớ của họ bị hoán đổi khỏi họ. Hoặc đơn giản họ muốn khối lượng công việc của mình
không được ưu tiên hoặc hoán đổi chút nào.

Điều này có nghĩa là nó khác với những gì được mô tả trong driver-api/dma-buf.rst.

Giống như các công việc tính toán thông thường, dma-fence hoàn toàn không được sử dụng. Trong trường hợp này,
thậm chí không để ép quyền ưu tiên. Trình điều khiển chỉ đơn giản là buộc phải hủy ánh xạ BO
từ không gian địa chỉ của công việc tính toán dài được hủy liên kết ngay lập tức, thậm chí không
chờ đợi khối lượng công việc hoàn thành. Hiệu quả điều này chấm dứt khối lượng công việc
khi không có phần cứng hỗ trợ để phục hồi.

Vì đây là điều không mong muốn nên cần phải có biện pháp giảm thiểu để ngăn chặn khối lượng công việc
khỏi bị chấm dứt. Có một số cách tiếp cận khả thi, tất cả đều có
ưu điểm và nhược điểm.

Cách tiếp cận đầu tiên bạn có thể thử là ghim tất cả các vùng đệm được điện toán sử dụng.
Điều này đảm bảo rằng công việc sẽ diễn ra không bị gián đoạn, nhưng cũng cho phép rất nhiều
tấn công từ chối dịch vụ bằng cách ghim càng nhiều bộ nhớ càng tốt, chiếm dụng
tất cả bộ nhớ GPU và có thể là một lượng lớn bộ nhớ CPU.

Cách tiếp cận thứ hai sẽ hoạt động tốt hơn một chút là thêm tùy chọn
không bị trục xuất khi tạo công việc mới (bất kỳ loại nào). Nếu tất cả không gian người dùng chọn tham gia
đối với cờ này, nó sẽ ngăn không cho không gian người dùng hợp tác bị buộc phải chấm dứt
các công việc tính toán cũ hơn để bắt đầu một công việc mới.

Nếu không có sẵn chức năng ưu tiên công việc và lỗi trang có thể phục hồi thì đó là
chỉ có cách tiếp cận mới có thể. Vì vậy, ngay cả với những điều đó, bạn muốn có một cách riêng để
kiểm soát tài nguyên. Cách làm tiêu chuẩn của kernel là cgroups.

Điều này tạo ra tùy chọn thứ ba, sử dụng cgroups để ngăn chặn việc trục xuất. Cả GPU và
bộ nhớ CPU do trình điều khiển phân bổ sẽ được tính vào nhóm chính xác và
việc trục xuất sẽ được thông báo cho cgroup. Điều này cho phép GPU được phân vùng
thành các nhóm, điều đó sẽ cho phép các công việc chạy cạnh nhau mà không cần
sự can thiệp.

Giao diện của nhóm sẽ tương tự như bộ nhớ CPU hiện tại
giao diện, với ngữ nghĩa tương tự cho mức tối thiểu/thấp/cao/tối đa, nếu việc trục xuất có thể
được làm cho cgroup nhận thức được.

Điều cần lưu ý là mỗi vùng bộ nhớ (ví dụ: bộ nhớ xếp kề)
phải có sổ kế toán riêng.

Khóa được đặt thành id vùng do trình điều khiển đặt, ví dụ: "tile0".
Đối với giá trị của $card, chúng tôi sử dụng drmGetUnique().
