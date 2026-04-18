.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/dev-tools/ktap.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================================
Giao thức kiểm tra hạt nhân mọi thứ (KTAP), phiên bản 1
===================================================

TAP hoặc Giao thức kiểm tra mọi thứ là định dạng để chỉ định kết quả kiểm tra được sử dụng
bởi một số dự án. Trang web và thông số kỹ thuật của nó có tại ZZ0000ZZ này. Hạt nhân Linux chủ yếu sử dụng đầu ra TAP để thử nghiệm
kết quả. Tuy nhiên, các khung kiểm tra hạt nhân có nhu cầu đặc biệt về kết quả kiểm tra
không phù hợp với thông số kỹ thuật TAP ban đầu. Do đó, "Hạt nhân TAP"
Định dạng (KTAP) được chỉ định để mở rộng và thay đổi TAP nhằm hỗ trợ các trường hợp sử dụng này.
Thông số kỹ thuật này mô tả định dạng được chấp nhận rộng rãi của KTAP
hiện đang được sử dụng trong kernel.

Kết quả kiểm tra KTAP mô tả một loạt các kiểm tra (có thể được lồng nhau: tức là kiểm tra
có thể có các thử nghiệm phụ), mỗi thử nghiệm có thể chứa cả dữ liệu chẩn đoán -- ví dụ: nhật ký
dòng -- và kết quả cuối cùng. Cấu trúc và kết quả kiểm tra
máy có thể đọc được, trong khi dữ liệu chẩn đoán không có cấu trúc và có sẵn để
hỗ trợ gỡ lỗi của con người.

Đầu ra KTAP được xây dựng từ bốn loại đường khác nhau:

- Dòng phiên bản
- Đường quy hoạch
- Dòng kết quả test case
- Dòng chẩn đoán

Nói chung, đầu ra KTAP hợp lệ cũng phải tạo thành đầu ra TAP hợp lệ, nhưng một số
thông tin, đặc biệt là các kết quả kiểm tra lồng nhau, có thể bị mất. Cũng lưu ý rằng
có một thông số dự thảo trì trệ cho TAP14, KTAP khác với điều này trong
một vài vị trí (đặc biệt là tiêu đề "Subtest"), được mô tả ở đâu
có liên quan sau này trong tài liệu này.

Dòng phiên bản
-------------

Tất cả các kết quả có định dạng KTAP đều bắt đầu bằng "dòng phiên bản" chỉ định
phiên bản tiêu chuẩn (K)TAP mà kết quả tuân thủ.

Ví dụ:

- "KTAP phiên bản 1"
- "TAP phiên bản 13"
- "TAP phiên bản 14"

Lưu ý rằng, trong KTAP, các bài kiểm tra phụ cũng bắt đầu bằng dòng phiên bản, biểu thị
bắt đầu các kết quả kiểm tra lồng nhau. Điều này khác với TAP14, sử dụng
dòng "Subtest" riêng biệt.

Trong tương lai, "KTAP phiên bản 1" nên được sử dụng cho các thử nghiệm tuân thủ, nhưng nó
dự kiến rằng hầu hết các trình phân tích cú pháp và công cụ khác sẽ chấp nhận các phiên bản khác
được liệt kê ở đây để tương thích với các thử nghiệm và khuôn khổ hiện có.

Đường kế hoạch
----------

Kế hoạch kiểm tra cung cấp số lượng bài kiểm tra (hoặc bài kiểm tra phụ) trong đầu ra KTAP.

Các dòng kế hoạch phải tuân theo định dạng "1..N" trong đó N là số lượng bài kiểm tra hoặc bài kiểm tra phụ.
Các dòng kế hoạch nối tiếp các dòng phiên bản để cho biết số lượng các bài kiểm tra lồng nhau.

Mặc dù có những trường hợp không biết trước số lượng bài kiểm tra -- trong
trường hợp nào kế hoạch kiểm thử có thể bị bỏ qua -- chúng tôi đặc biệt khuyên bạn nên thực hiện
hiện diện ở nơi có thể.

Dòng kết quả trường hợp thử nghiệm
----------------------

Dòng kết quả trường hợp thử nghiệm cho biết trạng thái cuối cùng của thử nghiệm.
Chúng được yêu cầu và phải có định dạng:

.. code-block:: none

	<result> <number> [<description>][ # [<directive>] [<diagnostic data>]]

Kết quả có thể là "ok", cho biết trường hợp kiểm thử đã đạt,
hoặc "không ổn", cho biết trường hợp kiểm thử đã thất bại.

<number> đại diện cho số lượng bài kiểm tra đang được thực hiện. Cuộc thử nghiệm đầu tiên phải
có số 1 và số đó phải tăng thêm 1 cho mỗi lần thêm
subtest trong cùng một bài kiểm tra ở cùng cấp độ lồng nhau.

Mô tả là mô tả về bài kiểm tra, nói chung là tên của
kiểm tra và có thể là bất kỳ chuỗi ký tự nào ngoài # or a
dòng mới.  Mô tả là tùy chọn nhưng được khuyến nghị.

Chỉ thị và mọi dữ liệu chẩn đoán đều là tùy chọn. Nếu một trong hai có mặt, họ
phải theo sau dấu băm, "#".

Lệnh là một từ khóa chỉ ra một kết quả khác cho một bài kiểm tra khác
hơn là đã vượt qua và thất bại. Lệnh này là tùy chọn và bao gồm một lệnh duy nhất
từ khóa trước dữ liệu chẩn đoán. Trong trường hợp trình phân tích cú pháp gặp phải
một lệnh mà nó không hỗ trợ, nó sẽ chuyển về trạng thái "ok"/"không ổn"
kết quả.

Các chỉ thị được chấp nhận hiện nay là:

- "SKIP", cho biết thử nghiệm đã bị bỏ qua (lưu ý kết quả của trường hợp thử nghiệm
  dòng kết quả có thể là "ok" hoặc "không ok" nếu sử dụng lệnh SKIP)
- "TODO", cho biết rằng bài kiểm tra dự kiến sẽ không vượt qua vào lúc này,
  ví dụ: bởi vì tính năng mà nó đang thử nghiệm được biết là đã bị hỏng. Trong khi điều này
  lệnh được kế thừa từ TAP, việc sử dụng nó trong kernel không được khuyến khích.
- "XFAIL", cho biết rằng thử nghiệm dự kiến ​​sẽ thất bại. Điều này tương tự
  thành "TODO" ở trên và được một số thử nghiệm kselftest sử dụng.
- “TIMEOUT”, cho biết bài kiểm tra đã hết thời gian chờ (lưu ý kết quả kiểm tra
  dòng kết quả trường hợp sẽ là “không ổn” nếu sử dụng lệnh TIMEOUT)
- “ERROR”, cho biết việc thực hiện kiểm tra đã thất bại do
  lỗi cụ thể có trong dữ liệu chẩn đoán. (lưu ý kết quả của
  dòng kết quả của trường hợp kiểm thử sẽ là “không ổn” nếu sử dụng lệnh ERROR)

Dữ liệu chẩn đoán là trường văn bản thuần túy chứa mọi chi tiết bổ sung
về lý do tại sao kết quả này được tạo ra. Đây thường là thông báo lỗi cho ERROR
hoặc các thử nghiệm không thành công hoặc mô tả về các phần phụ thuộc bị thiếu cho kết quả SKIP.

Trường dữ liệu chẩn đoán là tùy chọn và các kết quả không có
chỉ thị cũng như bất kỳ dữ liệu chẩn đoán nào không cần bao gồm trường "#"
dải phân cách.

Các dòng kết quả ví dụ bao gồm::

được 1 test_case_name

Bài kiểm tra "test_case_name" đã vượt qua.

::

không ổn 1 test_case_name

Thử nghiệm "test_case_name" không thành công.

::

được 1 thử nghiệm phụ thuộc cần thiết # ZZ0000ZZ không có sẵn

"Thử nghiệm" thử nghiệm là SKIPPED với thông báo chẩn đoán "sự phụ thuộc cần thiết
không có sẵn".

::

không ổn 1 bài kiểm tra # ZZ0000ZZ 30 giây

"Thử nghiệm" đã hết thời gian chờ, với dữ liệu chẩn đoán là "30 giây".

::

được 5 kiểm tra mã trả lại # rcode=0

Thử nghiệm "kiểm tra mã trả lại" đã vượt qua, với dữ liệu chẩn đoán bổ sung “rcode=0”


Dòng chẩn đoán
----------------

Nếu các bài kiểm tra muốn xuất thêm bất kỳ thông tin nào, họ nên làm như vậy bằng cách sử dụng
"dòng chẩn đoán". Các dòng chẩn đoán là văn bản tùy chọn, dạng tự do và được
thường được sử dụng để mô tả những gì đang được thử nghiệm và bất kỳ kết quả trung gian nào trong
chi tiết hơn kết quả cuối cùng và dòng dữ liệu chẩn đoán cung cấp.

Các dòng chẩn đoán được định dạng là "# <diagnostic_description>", trong đó
mô tả có thể là bất kỳ chuỗi nào.  Dòng chẩn đoán có thể ở bất kỳ đâu trong bài kiểm tra
đầu ra. Theo quy định, các dòng chẩn đoán liên quan đến xét nghiệm nằm ngay trước
dòng kết quả kiểm tra cho bài kiểm tra đó.

Lưu ý rằng hầu hết các công cụ sẽ coi các dòng không xác định (xem bên dưới) là dòng chẩn đoán,
ngay cả khi chúng không bắt đầu bằng "#": điều này nhằm nắm bắt bất kỳ thông tin hữu ích nào khác
đầu ra kernel có thể giúp gỡ lỗi kiểm tra. Tuy nhiên nó được khuyến khích
các bài kiểm tra luôn đặt tiền tố bất kỳ đầu ra chẩn đoán nào mà chúng có bằng ký tự "#".

Dòng không xác định
-------------

Có thể có các dòng trong đầu ra KTAP không tuân theo định dạng của một trong các
bốn định dạng cho các dòng được mô tả ở trên. Tuy nhiên, điều này được cho phép, họ sẽ
không ảnh hưởng đến trạng thái của các bài kiểm tra.

Đây là điểm khác biệt quan trọng so với TAP.  Kiểm tra hạt nhân có thể in tin nhắn
vào bảng điều khiển hệ thống hoặc tệp nhật ký.  Cả hai đích đến này đều có thể chứa
tin nhắn từ kernel không liên quan hoặc hoạt động không gian người dùng hoặc kernel
thông báo từ mã không phải kiểm tra được gọi ra bởi kiểm tra.  Mã hạt nhân
được viện dẫn bởi bài kiểm tra có thể không biết rằng bài kiểm tra đang được tiến hành và
do đó không thể in thông báo dưới dạng thông báo chẩn đoán.

Kiểm tra lồng nhau
------------

Trong KTAP, các bài kiểm tra có thể được lồng vào nhau. Điều này được thực hiện bằng cách bao gồm một bài kiểm tra trong đó
xuất ra toàn bộ tập hợp các kết quả có định dạng KTAP. Điều này có thể được sử dụng để phân loại
và các bài kiểm tra liên quan đến nhóm hoặc để tách các kết quả khác nhau từ cùng một bài kiểm tra.

Kết quả của bài kiểm tra "cha mẹ" phải bao gồm tất cả các kết quả của bài kiểm tra phụ của nó,
bắt đầu với một dòng phiên bản KTAP khác và kế hoạch thử nghiệm và kết thúc với kế hoạch tổng thể
kết quả. Ví dụ: nếu một trong các bài kiểm tra phụ thất bại, bài kiểm tra gốc cũng phải
thất bại.

Ngoài ra, tất cả các dòng trong bài kiểm tra phụ phải được thụt lề. Một cấp độ
thụt lề là hai khoảng trắng: " ". Việc thụt lề phải bắt đầu ở phiên bản
dòng và phải kết thúc trước dòng kết quả của bài kiểm tra gốc.

"Dòng không xác định" không được coi là dòng trong bài kiểm tra phụ và do đó
được phép thụt lề hoặc không thụt lề.

Ví dụ về bài kiểm tra có hai bài kiểm tra phụ lồng nhau:

::

KTAP phiên bản 1
	1..1
	  KTAP phiên bản 1
	  1..2
	  được rồi 1 bài kiểm tra_1
	  không ổn 2 bài kiểm tra_2
	# example không thành công
	không ổn 1 ví dụ

Một định dạng ví dụ với nhiều cấp độ thử nghiệm lồng nhau:

::

KTAP phiên bản 1
	1..2
	  KTAP phiên bản 1
	  1..2
	    KTAP phiên bản 1
	    1..2
	    không ổn 1 bài kiểm tra_1
	    được rồi 2 bài kiểm tra_2
	  không ổn 1 bài kiểm tra_3
	  được rồi 2 bài kiểm tra_4 # ZZ0003ZZ
	không ổn 1 ví dụ_test_1
	được 2 ví dụ_test_2


Sự khác biệt chính giữa TAP và KTAP
--------------------------------------

===================================================== ========= =================
Tính năng TAP KTAP
===================================================== ========= =================
yaml và json trong thông báo chẩn đoán được, không nên dùng
Chỉ thị TODO ok không được công nhận
cho phép lồng nhau một số lượng thử nghiệm tùy ý không có
"Dòng không xác định" nằm trong danh mục "Bất cứ điều gì khác" có không
"Dòng không xác định" được phép không chính xác
===================================================== ========= =================

Đặc tả TAP14 cho phép các thử nghiệm lồng nhau, nhưng thay vì sử dụng một thử nghiệm khác
dòng phiên bản lồng nhau, sử dụng một dòng có dạng
"Subtest: <name>" trong đó <name> là tên của bài kiểm tra gốc.

Ví dụ đầu ra KTAP
--------------------
::

KTAP phiên bản 1
	1..1
	  KTAP phiên bản 1
	  1..3
	    KTAP phiên bản 1
	    1..1
	    # test_1: khởi tạo test_1
	    được rồi 1 bài kiểm tra_1
	  được 1 ví dụ_test_1
	    KTAP phiên bản 1
	    1..2
	    được 1 bài kiểm tra_1 bài kiểm tra # ZZ0004ZZ_1 đã bỏ qua
	    được rồi 2 bài kiểm tra_2
	  được 2 ví dụ_test_2
	    KTAP phiên bản 1
	    1..3
	    được rồi 1 bài kiểm tra_1
	    # test_2: FAIL
	    không ổn 2 bài kiểm tra_2
	    được 3 bài kiểm tra_3 # ZZ0007ZZ test_3 đã bỏ qua
	  không ổn 3 ví dụ_test_3
	không ổn 1 main_test

Đầu ra này xác định hệ thống phân cấp sau:

Một bài kiểm tra duy nhất có tên là "main_test", không thành công và có ba bài kiểm tra phụ:

- "example_test_1", vượt qua và có một bài kiểm tra phụ:

- "test_1", vượt qua và đưa ra thông báo chẩn đoán "test_1: khởi tạo test_1"

- "example_test_2", vượt qua và có hai bài kiểm tra phụ:

- "test_1", bị bỏ qua, kèm theo lời giải thích là "test_1 bị bỏ qua"
   - "test_2", vượt qua

- "example_test_3", không thành công và có ba bài kiểm tra phụ

- "test_1", vượt qua
   - "test_2", xuất ra dòng chẩn đoán "test_2: FAIL" và không thành công.
   - "test_3", bị bỏ qua với lời giải thích "test_3 bị bỏ qua"

Lưu ý rằng các bài kiểm tra phụ riêng lẻ có cùng tên không xung đột vì chúng
được tìm thấy trong các bài kiểm tra cha mẹ khác nhau. Đầu ra này cũng thể hiện một số ý nghĩa hợp lý
quy tắc về kết quả kiểm tra "sủi bọt": một bài kiểm tra thất bại nếu bất kỳ bài kiểm tra phụ nào của nó thất bại.
Các bài kiểm tra bị bỏ qua không ảnh hưởng đến kết quả của bài kiểm tra gốc (mặc dù nó thường
việc một bài kiểm tra bị đánh dấu là bị bỏ qua là điều hợp lý nếu _all_ các bài kiểm tra phụ của nó đã được
bỏ qua).

Xem thêm:
---------

- Thông số TAP:
  ZZ0000ZZ
- Thông số kỹ thuật TAP phiên bản 14 (trì trệ):
  ZZ0001ZZ
- Tài liệu kselftest:
  Tài liệu/dev-tools/kselftest.rst
- Tài liệu KUnit:
  Tài liệu/dev-tools/kunit/index.rst