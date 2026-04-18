.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/staging/speculation.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============
suy đoán
===========

Tài liệu này giải thích những tác động tiềm tàng của việc đầu cơ và mức độ không mong muốn
các hiệu ứng có thể được giảm thiểu một cách linh hoạt bằng cách sử dụng các API phổ biến.

------------------------------------------------------------------------------

Để cải thiện hiệu suất và giảm thiểu độ trễ trung bình, nhiều CPU hiện đại
sử dụng các kỹ thuật thực hiện suy đoán như dự đoán nhánh, thực hiện
công việc có thể bị loại bỏ ở giai đoạn sau.

Thông thường việc thực hiện suy đoán không thể được quan sát từ trạng thái kiến trúc,
chẳng hạn như nội dung của các thanh ghi. Tuy nhiên, trong một số trường hợp có thể
quan sát tác động của nó lên trạng thái vi kiến trúc, chẳng hạn như sự hiện diện hoặc
thiếu dữ liệu trong bộ nhớ đệm. Trạng thái như vậy có thể hình thành các kênh phụ có thể
được quan sát để trích xuất thông tin bí mật.

Ví dụ, với sự có mặt của dự đoán nhánh, có thể có các giới hạn
kiểm tra bị bỏ qua bởi mã được thực thi theo suy đoán. Hãy xem xét
đoạn mã sau::

int Load_array(int *mảng, chỉ mục int không dấu)
	{
		nếu (chỉ mục >= MAX_ARRAY_ELEMS)
			trả về 0;
		khác
			trả về mảng[chỉ mục];
	}

Cái nào, trên arm64, có thể được biên dịch thành chuỗi lắp ráp, chẳng hạn như ::

CMP <chỉ mục>, #ZZ0001ZZ
	B.LT ít hơn
	MOV <trở về>, #0
	RET
  ít hơn:
	LDR <giá trị trả về>, [<mảng>, <chỉ mục>]
	RET

Có thể CPU dự đoán sai nhánh có điều kiện và
tải theo suy đoán mảng [chỉ mục], ngay cả khi chỉ mục> = MAX_ARRAY_ELEMS. Cái này
giá trị sau đó sẽ bị loại bỏ, nhưng tải suy đoán có thể ảnh hưởng
trạng thái vi kiến trúc mà sau đó có thể được đo lường.

Các trình tự phức tạp hơn liên quan đến nhiều truy cập bộ nhớ phụ thuộc có thể
dẫn đến thông tin nhạy cảm bị rò rỉ. Hãy xem xét những điều sau đây
mã, xây dựng dựa trên ví dụ trước::

int Load_depend_arrays(int *arr1, int *arr2, chỉ mục int)
	{
		int val1, val2,

val1 = Load_array(arr1, chỉ mục);
		val2 = Load_array(arr2, val1);

trả về val2;
	}

Theo suy đoán, lệnh gọi đầu tiên tới Load_array() có thể trả về giá trị
của một địa chỉ ngoài giới hạn, trong khi cuộc gọi thứ hai sẽ ảnh hưởng
trạng thái vi kiến trúc phụ thuộc vào giá trị này. Điều này có thể cung cấp một
đọc tùy ý nguyên thủy.

Giảm thiểu các kênh đầu cơ
====================================

Hạt nhân cung cấp API chung để đảm bảo rằng việc kiểm tra giới hạn được thực hiện
được tôn trọng ngay cả dưới sự suy đoán. Kiến trúc bị ảnh hưởng bởi
các kênh phụ dựa trên đầu cơ dự kiến sẽ thực hiện những điều này
nguyên thủy.

Trình trợ giúp array_index_nospec() trong <linux/nospec.h> có thể được sử dụng để
ngăn chặn thông tin bị rò rỉ qua các kênh bên.

Cuộc gọi tới array_index_nospec(index, size) trả về một chỉ mục đã được làm sạch
giá trị được giới hạn ở [0, size) ngay cả khi suy đoán cpu
điều kiện.

Điều này có thể được sử dụng để bảo vệ ví dụ Load_array() trước đó::

int Load_array(int *mảng, chỉ mục int không dấu)
	{
		nếu (chỉ mục >= MAX_ARRAY_ELEMS)
			trả về 0;
		khác {
			chỉ mục = mảng_index_nospec(chỉ mục, MAX_ARRAY_ELEMS);
			trả về mảng[chỉ mục];
		}
	}
