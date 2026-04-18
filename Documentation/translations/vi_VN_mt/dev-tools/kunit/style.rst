.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/dev-tools/kunit/style.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Phong cách kiểm tra và danh pháp
================================

Để làm cho việc tìm kiếm, viết và sử dụng các bài kiểm tra KUnit trở nên đơn giản nhất có thể,
khuyến khích mạnh mẽ rằng chúng được đặt tên và viết theo hướng dẫn
bên dưới. Mặc dù có thể viết các bài kiểm thử KUnit không tuân theo các quy tắc này,
chúng có thể làm hỏng một số công cụ, có thể xung đột với các thử nghiệm khác và có thể không chạy được
tự động bằng hệ thống kiểm tra.

Bạn chỉ nên đi chệch khỏi những nguyên tắc này khi:

1. Chuyển các bài kiểm tra sang KUnit đã được biết đến với tên hiện có.
2. Viết các bài kiểm tra có thể gây ra vấn đề nghiêm trọng nếu chạy tự động. cho
   ví dụ: tạo ra kết quả dương tính hoặc âm tính giả một cách không xác định, hoặc
   mất nhiều thời gian để chạy.

Hệ thống con, bộ và thử nghiệm
=============================

Để làm cho các bài kiểm tra dễ tìm, chúng được nhóm thành các bộ và hệ thống con. một bài kiểm tra
suite là một nhóm các thử nghiệm nhằm kiểm tra một vùng liên quan của kernel. Một hệ thống con
là một tập hợp các bộ thử nghiệm để kiểm tra các phần khác nhau của hệ thống con kernel
hoặc một người lái xe.

Hệ thống con
----------

Mỗi bộ thử nghiệm phải thuộc về một hệ thống con. Một hệ thống con là một tập hợp của một
hoặc nhiều bộ kiểm tra KUnit kiểm tra cùng một trình điều khiển hoặc một phần của kernel. A
hệ thống con kiểm tra phải khớp với một mô-đun hạt nhân. Nếu mã đang được kiểm tra
không thể được biên dịch thành một mô-đun, trong nhiều trường hợp hệ thống con phải tương ứng với
một thư mục trong cây nguồn hoặc một mục trong tệp ZZ0000ZZ. Nếu
không chắc chắn, hãy tuân theo các quy ước được đặt ra bởi các cuộc kiểm tra trong các lĩnh vực tương tự.

Các hệ thống con kiểm thử phải được đặt tên theo mã đang được kiểm thử, hoặc sau mã
mô-đun (bất cứ khi nào có thể) hoặc sau thư mục hoặc tệp đang được kiểm tra. kiểm tra
các hệ thống con nên được đặt tên để tránh sự mơ hồ khi cần thiết.

Nếu tên hệ thống con thử nghiệm có nhiều thành phần thì chúng phải được phân tách bằng
dấu gạch dưới. ZZ0000ZZ bao gồm "kiểm tra" hoặc "kunit" trực tiếp trong tên hệ thống con
trừ khi chúng tôi thực sự đang thử nghiệm các thử nghiệm khác hoặc chính khung kunit. cho
ví dụ, các hệ thống con có thể được gọi là:

ZZ0000ZZ
  Khớp với tên mô-đun và hệ thống tập tin.
ZZ0001ZZ
  Khớp tên mô-đun và tên LSM.
ZZ0002ZZ
  Tên chung cho công cụ, phần nổi bật của đường dẫn ZZ0003ZZ
ZZ0004ZZ
  Có một số thành phần (ZZ0005ZZ, ZZ0006ZZ, ZZ0007ZZ, ZZ0008ZZ) được phân tách bằng
  dấu gạch dưới. Phù hợp với tên mô-đun.

Tránh đặt tên như trong ví dụ dưới đây:

ZZ0000ZZ
  Tên nên sử dụng dấu gạch dưới, không phải dấu gạch ngang, để phân tách các từ. Thích hơn
  ZZ0001ZZ.
ZZ0002ZZ
  Tên này phải sử dụng dấu gạch dưới và không có "kunit-test" làm tên
  hậu tố. ZZ0003ZZ cũng mơ hồ như một tên hệ thống con, bởi vì một số phần
  của kernel có hệ thống con ZZ0004ZZ. ZZ0005ZZ sẽ là một cái tên hay hơn.
ZZ0006ZZ
  Tên mô-đun tương ứng là ZZ0007ZZ, vì vậy hệ thống con này cũng phải
  được đặt tên là ZZ0008ZZ.

.. note::
        The KUnit API and tools do not explicitly know about subsystems. They are
        a way of categorizing test suites and naming modules which provides a
        simple, consistent way for humans to find and run tests. This may change
        in the future.

dãy phòng
------

Các thử nghiệm KUnit được nhóm thành các bộ thử nghiệm, bao gồm một lĩnh vực cụ thể của
chức năng đang được thử nghiệm. Bộ thử nghiệm có thể có sự khởi tạo và chia sẻ
mã tắt máy được chạy cho tất cả các thử nghiệm trong bộ phần mềm. Không phải tất cả các hệ thống con đều cần
được chia thành nhiều bộ thử nghiệm (ví dụ: trình điều khiển đơn giản).

Các bộ thử nghiệm được đặt tên theo hệ thống con mà chúng là một phần. Nếu một hệ thống con
chứa nhiều dãy, khu vực cụ thể đang được thử nghiệm phải được thêm vào
tên hệ thống con, cách nhau bằng dấu gạch dưới.

Trong trường hợp có nhiều loại thử nghiệm sử dụng KUnit trong một
hệ thống con (ví dụ: cả kiểm tra đơn vị và kiểm tra tích hợp), chúng phải
đưa vào các bộ riêng biệt, với loại bài kiểm tra là phần tử cuối cùng trong bộ
tên. Trừ khi thực sự có những thử nghiệm này, hãy tránh sử dụng ZZ0000ZZ, ZZ0001ZZ
hoặc tương tự trong tên bộ.

Tên bộ thử nghiệm đầy đủ (bao gồm tên hệ thống con) phải được chỉ định là
thành viên ZZ0000ZZ của cấu trúc ZZ0001ZZ và tạo thành cơ sở cho
tên mô-đun. Ví dụ: bộ thử nghiệm có thể bao gồm:

ZZ0000ZZ
  Một phần của hệ thống con ZZ0001ZZ, đang thử nghiệm khu vực ZZ0002ZZ.
ZZ0003ZZ
  Một phần của quá trình triển khai ZZ0004ZZ, thử nghiệm khu vực ZZ0005ZZ.
ZZ0006ZZ
  Một phần của hệ thống con ZZ0007ZZ, đang thử nghiệm khu vực ZZ0008ZZ.
ZZ0009ZZ
  Hệ thống con ZZ0010ZZ chỉ có một bộ phần mềm nên tên bộ phần mềm giống như
  tên hệ thống con.

Tránh đặt tên, ví dụ:

ZZ0000ZZ
  Không có lý do gì để nêu hệ thống con hai lần.
ZZ0001ZZ
  Tên bộ không rõ ràng nếu không có tên hệ thống con.
ZZ0002ZZ
  Vì chỉ có một bộ trong hệ thống con ZZ0003ZZ nên bộ này sẽ
  chỉ được gọi là ZZ0004ZZ. Đừng thêm thừa
  ZZ0005ZZ. Nó phải là một bộ thử nghiệm riêng biệt. Ví dụ, nếu
  các bài kiểm tra đơn vị được thêm vào thì bộ đó có thể được đặt tên là ZZ0006ZZ hoặc
  tương tự.

Trường hợp thử nghiệm
----------

Các thử nghiệm riêng lẻ bao gồm một chức năng duy nhất để kiểm tra một ràng buộc
đường dẫn mã, thuộc tính hoặc hàm. Trong đầu ra của bài kiểm tra, một bài kiểm tra riêng lẻ
kết quả sẽ hiển thị dưới dạng các bài kiểm tra phụ của kết quả của bộ.

Các thử nghiệm nên được đặt tên theo những gì chúng đang thử nghiệm. Đây thường là tên của
chức năng đang được kiểm tra, kèm theo mô tả về đầu vào hoặc đường dẫn mã đang được kiểm tra.
Vì các bài kiểm tra là các hàm C nên chúng phải được đặt tên và viết theo
phong cách mã hóa hạt nhân.

.. note::
        As tests are themselves functions, their names cannot conflict with
        other C identifiers in the kernel. This may require some creative
        naming. It is a good idea to make your test functions `static` to avoid
        polluting the global namespace.

Tên thử nghiệm ví dụ bao gồm:

ZZ0000ZZ
  Kiểm tra chức năng ZZ0001ZZ khi tên NULL được chuyển vào.
ZZ0002ZZ
  Kiểm tra macro ZZ0003ZZ. Nó có tiền tố ZZ0004ZZ để tránh
  xung đột tên với chính macro.


Nếu cần phải tham khảo một thử nghiệm bên ngoài bối cảnh của bộ thử nghiệm của nó,
tên ZZ0001ZZ của bài kiểm tra phải là tên bộ phần mềm theo sau là
tên kiểm tra, được phân tách bằng dấu hai chấm (tức là ZZ0000ZZ).

Kiểm tra các mục Kconfig
====================

Mọi bộ thử nghiệm phải được gắn với mục Kconfig.

Mục Kconfig này phải:

* được đặt tên là ZZ0000ZZ: trong đó <name> là tên của bài kiểm tra
  suite.
* được liệt kê cùng với các mục cấu hình cho trình điều khiển/hệ thống con đang được
  đã được thử nghiệm hoặc nằm trong [Hack hạt nhân]->[Kiểm tra và bảo hiểm hạt nhân]
* phụ thuộc vào ZZ0001ZZ.
* chỉ hiển thị nếu ZZ0002ZZ không được bật.
* có giá trị mặc định là ZZ0003ZZ.
* có mô tả ngắn gọn về KUnit trong văn bản trợ giúp.

Nếu chúng tôi không thể đáp ứng các điều kiện trên (ví dụ: bài kiểm tra không thể đáp ứng được
được xây dựng dưới dạng mô-đun), các mục nhập Kconfig dành cho kiểm tra phải ở dạng ba trạng thái.

Ví dụ: mục Kconfig có thể trông giống như:

.. code-block:: none

	config FOO_KUNIT_TEST
		tristate "KUnit test for foo" if !KUNIT_ALL_TESTS
		depends on KUNIT
		default KUNIT_ALL_TESTS
		help
		  This builds unit tests for foo.

		  For more information on KUnit and unit tests in general,
		  please refer to the KUnit documentation in Documentation/dev-tools/kunit/.

		  If unsure, say N.


Tên tệp và mô-đun kiểm tra
==========================

Các bài kiểm tra KUnit thường được biên dịch thành một mô-đun riêng biệt. Để tránh xung đột
với các mô-đun thông thường, các mô-đun KUnit phải được đặt tên theo bộ thử nghiệm,
theo sau là ZZ0000ZZ (ví dụ: nếu "foobar" là mô-đun lõi thì
"foobar_kunit" là mô-đun thử nghiệm KUnit).

Kiểm tra các tệp nguồn, cho dù được biên dịch thành một mô-đun riêng biệt hay một
ZZ0000ZZ trong một tệp nguồn khác, tốt nhất nên lưu giữ trong ZZ0001ZZ
thư mục con để không xung đột với các tệp nguồn khác (ví dụ: đối với
hoàn thành tab).

Lưu ý rằng hậu tố ZZ0000ZZ cũng đã được sử dụng trong một số
các bài kiểm tra. Hậu tố ZZ0001ZZ được ưa chuộng hơn vì nó tạo nên sự khác biệt
giữa các bài kiểm tra KUnit và không KUnit rõ ràng hơn.

Vì vậy đối với trường hợp thông thường, hãy đặt tên file chứa bộ kiểm tra
ZZ0000ZZ. Thư mục ZZ0001ZZ nên được đặt tại
cùng cấp độ với mã đang được thử nghiệm. Ví dụ, các bài kiểm tra cho
ZZ0002ZZ trực tiếp trong ZZ0003ZZ.

Nếu tên bộ chứa một số hoặc tất cả tên của cha mẹ của bài kiểm tra
thư mục, có thể nên sửa đổi tên tệp nguồn để giảm bớt
dư thừa. Ví dụ: bộ ZZ0000ZZ có thể nằm trong
Tệp ZZ0001ZZ.