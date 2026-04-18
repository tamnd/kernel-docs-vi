.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/associativity.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Khả năng kết hợp tài nguyên NUMA
================================

Tính kết hợp đại diện cho việc nhóm các tài nguyên nền tảng khác nhau thành
các lĩnh vực có hiệu suất trung bình tương tự nhau so với các nguồn lực bên ngoài
của miền đó. Các tập hợp con tài nguyên của một miền nhất định thể hiện tốt hơn
hiệu suất tương đối với nhau hơn so với các tập hợp con tài nguyên khác
được biểu diễn như là thành viên của một miền nhóm con. Hiệu suất này
đặc tính được trình bày dưới dạng khoảng cách nút NUMA trong nhân Linux.
Từ góc độ nền tảng, các nhóm này còn được gọi là miền.

Giao diện PAPR hiện hỗ trợ các cách khác nhau để truyền đạt các tài nguyên này
nhóm chi tiết vào hệ điều hành. Chúng được gọi là Mẫu 0, Mẫu 1 và Mẫu 2
nhóm liên kết. Biểu mẫu 0 là định dạng cũ nhất và hiện được coi là không dùng nữa.

Hypervisor cho biết loại/hình thức kết hợp được sử dụng thông qua "thuộc tính ibm,architecture-vec-5".
Bit 0 của byte 5 trong thuộc tính "ibm,architecture-vec-5" cho biết cách sử dụng Biểu mẫu 0 hoặc Biểu mẫu 1.
Giá trị 1 biểu thị việc sử dụng tính kết hợp của Mẫu 1. Đối với tính kết hợp của Mẫu 2
bit 2 của byte 5 trong thuộc tính "ibm,architecture-vec-5" được sử dụng.

Mẫu 0
------
Tính kết hợp của Mẫu 0 chỉ hỗ trợ hai khoảng cách NUMA (LOCAL và REMOTE).

Mẫu 1
------
Với Mẫu 1 là sự kết hợp của ibm,điểm tham chiếu kết hợp và ibm,tính kết hợp
Thuộc tính cây thiết bị được sử dụng để xác định khoảng cách NUMA giữa các nhóm/miền tài nguyên.

Thuộc tính “ibm,associativity” chứa danh sách một hoặc nhiều số (domainID)
đại diện cho các miền nhóm nền tảng của tài nguyên.

Thuộc tính “ibm,associativity-reference-points” chứa danh sách một hoặc nhiều số
(chỉ mục ID miền) đại diện cho thứ tự dựa trên 1 trong danh sách kết hợp.
Danh sách các chỉ mục domainID thể hiện sự phân cấp ngày càng tăng của nhóm tài nguyên.

ví dụ:
{ chỉ mục ID miền chính, chỉ mục ID miền phụ, chỉ mục ID miền thứ ba.. }

Nhân Linux sử dụng ID miền ở chỉ mục ID miền chính làm id nút NUMA.
Nhân Linux tính toán khoảng cách NUMA giữa hai miền bằng cách so sánh đệ quy
nếu chúng thuộc cùng một tên miền cấp cao hơn. Đối với sự không phù hợp ở mọi mức cao hơn
cấp độ của nhóm tài nguyên, kernel sẽ nhân đôi khoảng cách NUMA giữa
so sánh các miền

Mẫu 2
-------
Định dạng kết hợp Mẫu 2 thêm các thuộc tính cây thiết bị riêng biệt biểu thị khoảng cách nút NUMA
từ đó làm cho việc tính toán khoảng cách nút trở nên linh hoạt. Mẫu 2 cũng cho phép sơ cấp linh hoạt
đánh số miền. Với tính toán khoảng cách numa hiện đã được tách khỏi giá trị chỉ mục trong
Thuộc tính "ibm,associativity-reference-point", Mẫu 2 cho phép một số lượng lớn tên miền chính
id ở cùng một chỉ mục ID miền đại diện cho các nhóm tài nguyên có hiệu suất/độ trễ khác nhau
đặc điểm.

Hypervisor cho biết việc sử dụng tính kết hợp FORM2 bằng cách sử dụng bit 2 của byte 5 trong
Thuộc tính "ibm,architecture-vec-5".

Thuộc tính "ibm,numa-lookup-index-table" chứa danh sách một hoặc nhiều số đại diện cho
các ID miền có trong hệ thống. Phần bù của ID miền trong thuộc tính này là
được sử dụng làm chỉ mục trong khi tính toán thông tin khoảng cách numa thông qua "ibm, bảng khoảng cách numa".

prop-encoded-array: Số N của các domainID được mã hóa như với Encode-int, theo sau là
N domainID được mã hóa như với Encode-int

Ví dụ:
"ibm,numa-tra cứu-chỉ mục-bảng" = {4, 0, 8, 250, 252}. Phần bù của domainID 8 (2) được sử dụng khi
tính toán khoảng cách của miền 8 với các miền khác có trong hệ thống. Đối với phần còn lại của
tài liệu này, phần bù này sẽ được gọi là phần bù khoảng cách tên miền.

Thuộc tính "ibm,numa-distance-table" chứa danh sách một hoặc nhiều số đại diện cho NUMA
khoảng cách giữa các nhóm/miền tài nguyên có trong hệ thống.

prop-encoded-array: Số N của các giá trị khoảng cách được mã hóa như với Encode-int, theo sau là
N giá trị khoảng cách được mã hóa như với byte mã hóa. Giá trị khoảng cách tối đa chúng tôi có thể mã hóa là 255.
Số N phải bằng bình phương của m trong đó m là số lượng ID miền trong
bảng tra cứu-chỉ mục.

Ví dụ:
ibm,numa-lookup-index-table = <3 0 8 40>;
ibm,numa-distace-table = <9>, /bits/ 8 < 10 20 80 20 10 160 80 160 10>;

::

| 0 8 40
	--|----------
	  |
	0 | 10 20 80
	  |
	8 | 20 10 160
	  |
	40| 80 160 10

Thuộc tính "ibm,sociativity" có thể có cho các tài nguyên trong nút 0, 8 và 40

{ 3, 6, 7, 0 }
{ 3, 6, 9, 8 }
{ 3, 6, 7, 40}

Với "ibm,điểm tham chiếu kết hợp" { 0x3 }

"ibm,lookup-index-table" giúp biểu diễn ma trận khoảng cách một cách nhỏ gọn.
Vì ID miền có thể thưa thớt nên ma trận khoảng cách cũng có thể thưa thớt một cách hiệu quả.
Với "ibm,lookup-index-table" chúng ta có thể có được một biểu diễn nhỏ gọn của
thông tin khoảng cách.
