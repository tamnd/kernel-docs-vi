.. SPDX-License-Identifier: (GPL-2.0 OR BSD-2-Clause)

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/prog_sk_lookup.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
Chương trình sk_lookup BPF
==========================

Loại chương trình BPF sk_lookup (ZZ0000ZZ) giới thiệu khả năng lập trình
vào việc tra cứu socket được thực hiện bởi lớp vận chuyển khi một gói được
giao tại địa phương.

Khi gọi chương trình BPF sk_lookup có thể chọn một ổ cắm sẽ nhận
gói đến bằng cách gọi hàm trợ giúp ZZ0000ZZ BPF.

Móc dành cho điểm gắn chung (ZZ0000ZZ) tồn tại cho cả TCP và UDP.

Động lực
==========

Loại chương trình BPF sk_lookup đã được giới thiệu để giải quyết các tình huống thiết lập trong đó
việc liên kết các ổ cắm với một địa chỉ bằng lệnh gọi ổ cắm ZZ0000ZZ là không thực tế, chẳng hạn như
như:

1. nhận kết nối trên một loạt địa chỉ IP, ví dụ: 192.0.2.0/24, khi
   không thể liên kết với địa chỉ ký tự đại diện ZZ0000ZZ do có cổng
   xung đột,
2. nhận kết nối trên tất cả hoặc một loạt các cổng, tức là sử dụng proxy L7
   trường hợp.

Những thiết lập như vậy sẽ yêu cầu tạo và tạo một ổ cắm ZZ0000ZZ cho mỗi ổ cắm.
Địa chỉ/cổng IP trong phạm vi, dẫn đến tiêu tốn tài nguyên và tiềm năng
độ trễ tăng đột biến trong quá trình tra cứu ổ cắm.

Tệp đính kèm
==========

Chương trình BPF sk_lookup có thể được gắn vào không gian tên mạng với
Tòa nhà cao tầng ZZ0000ZZ sử dụng loại đính kèm ZZ0001ZZ và một
netns FD dưới dạng tệp đính kèm ZZ0002ZZ.

Nhiều chương trình có thể được gắn vào một không gian tên mạng. Các chương trình sẽ được
được gọi theo thứ tự như chúng được đính kèm.

móc
=====

Các chương trình sk_lookup BPF đính kèm sẽ chạy bất cứ khi nào lớp vận chuyển cần
tìm ổ cắm đang nghe (TCP) hoặc ổ cắm chưa được kết nối (UDP) cho gói đến.

Lưu lượng truy cập đến các ổ cắm đã thiết lập (TCP) và được kết nối (UDP) được phân phối
như thường lệ mà không kích hoạt hook BPF sk_lookup.

Các chương trình BPF đính kèm phải trả về với ZZ0000ZZ hoặc ZZ0001ZZ
mã phán quyết. Đối với các loại chương trình BPF khác là bộ lọc mạng,
ZZ0002ZZ biểu thị rằng việc tra cứu ổ cắm sẽ tiếp tục diễn ra bình thường
tra cứu dựa trên bảng băm, trong khi ZZ0003ZZ làm cho lớp vận chuyển loại bỏ
gói.

Chương trình sk_lookup BPF cũng có thể chọn ổ cắm để nhận gói bằng cách
gọi người trợ giúp ZZ0000ZZ BPF. Thông thường, chương trình sẽ tra cứu một socket
trong các ổ cắm giữ bản đồ, chẳng hạn như ZZ0001ZZ hoặc ZZ0002ZZ, và chuyển một
Trình trợ giúp ZZ0003ZZ sang ZZ0004ZZ để ghi lại
lựa chọn. Việc chọn ổ cắm chỉ có hiệu lực nếu chương trình đã kết thúc
với mã ZZ0005ZZ.

Khi nhiều chương trình được đính kèm, kết quả cuối cùng được xác định từ kết quả trả về
mã của tất cả các chương trình theo các quy tắc sau:

1. Nếu bất kỳ chương trình nào trả về ZZ0000ZZ và chọn một ổ cắm hợp lệ, ổ cắm đó sẽ
   được sử dụng như là kết quả của việc tra cứu ổ cắm.
2. Nếu có nhiều chương trình trả về ZZ0001ZZ và chọn một ổ cắm, chương trình cuối cùng
   lựa chọn có hiệu lực.
3. Nếu bất kỳ chương trình nào trả về ZZ0002ZZ và không có chương trình nào trả về ZZ0003ZZ và
   đã chọn ổ cắm, việc tra cứu ổ cắm không thành công.
4. Nếu tất cả các chương trình đều trả về ZZ0004ZZ và không có chương trình nào chọn ổ cắm,
   việc tra cứu socket vẫn tiếp tục.

API
===

Trong ngữ cảnh của nó, một phiên bản của chương trình ZZ0000ZZ, BPF sk_lookup
nhận thông tin về gói đã kích hoạt tra cứu ổ cắm. Cụ thể là:

* Phiên bản IP (ZZ0000ZZ hoặc ZZ0001ZZ),
* Mã định danh giao thức L4 (ZZ0002ZZ hoặc ZZ0003ZZ),
* địa chỉ IP nguồn và đích,
* Cổng L4 nguồn và đích,
* ổ cắm đã được chọn với ZZ0004ZZ.

Tham khảo khai báo ZZ0000ZZ trong người dùng ZZ0001ZZ API
tiêu đề và phần trang man ZZ0003ZZ
cho ZZ0002ZZ để biết chi tiết.

Ví dụ
=======

Xem ZZ0000ZZ để tham khảo
thực hiện.