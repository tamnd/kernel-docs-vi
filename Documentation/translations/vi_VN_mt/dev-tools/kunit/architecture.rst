.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/dev-tools/kunit/architecture.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================
Kiến trúc KUnit
==================

Kiến trúc KUnit được chia thành hai phần:

-ZZ0000ZZ
-ZZ0001ZZ

Khung kiểm tra trong hạt nhân
===========================

Thư viện kiểm tra kernel hỗ trợ các bài kiểm tra KUnit được viết bằng C bằng cách sử dụng
KUnit. Các bài kiểm tra KUnit này là mã hạt nhân. KUnit thực hiện như sau
nhiệm vụ:

- Tổ chức kiểm tra
- Báo cáo kết quả kiểm tra
- Cung cấp tiện ích kiểm tra

Trường hợp thử nghiệm
----------

Trường hợp thử nghiệm là đơn vị cơ bản trong KUnit. Các trường hợp kiểm thử KUnit được tổ chức
thành dãy phòng. Trường hợp kiểm thử KUnit là một hàm có chữ ký kiểu
ZZ0000ZZ. Các chức năng trường hợp thử nghiệm này được gói trong một
cấu trúc được gọi là struct kunit_case.

.. note:
	``generate_params`` is optional for non-parameterized tests.

Mỗi trường hợp kiểm thử KUnit nhận được một đối tượng ngữ cảnh ZZ0000ZZ theo dõi một
chạy thử nghiệm. Các macro xác nhận KUnit và các tiện ích KUnit khác sử dụng
Đối tượng bối cảnh ZZ0001ZZ. Là một ngoại lệ, có hai trường:

- ZZ0000ZZ: Các chức năng cài đặt có thể sử dụng nó để lưu trữ kết quả xét nghiệm tùy ý
  dữ liệu người dùng.

- ZZ0000ZZ: Chứa giá trị tham số có thể
  được lấy ra trong các thử nghiệm tham số hóa.

Bộ thử nghiệm
-----------

Bộ KUnit bao gồm một tập hợp các trường hợp thử nghiệm. Bộ KUnit
được đại diện bởi ZZ0000ZZ. Ví dụ:

.. code-block:: c

	static struct kunit_case example_test_cases[] = {
		KUNIT_CASE(example_test_foo),
		KUNIT_CASE(example_test_bar),
		KUNIT_CASE(example_test_baz),
		{}
	};

	static struct kunit_suite example_test_suite = {
		.name = "example",
		.init = example_test_init,
		.exit = example_test_exit,
		.test_cases = example_test_cases,
	};
	kunit_test_suite(example_test_suite);

Trong ví dụ trên, bộ thử nghiệm ZZ0000ZZ, chạy
trường hợp thử nghiệm ZZ0001ZZ, ZZ0002ZZ và
ZZ0003ZZ. Trước khi chạy thử nghiệm, ZZ0004ZZ
được gọi và sau khi chạy thử nghiệm, ZZ0005ZZ được gọi.
ZZ0006ZZ đăng ký bộ thử nghiệm
với khung kiểm tra KUnit.

Người thi hành
--------

Trình thực thi KUnit có thể liệt kê và chạy các bài kiểm tra KUnit tích hợp khi khởi động.
Các bộ thử nghiệm được lưu trữ trong phần liên kết
được gọi là ZZ0000ZZ. Để biết mã, hãy xem macro ZZ0001ZZ
định nghĩa trong
ZZ0004ZZ.
Phần liên kết bao gồm một mảng các con trỏ tới
ZZ0002ZZ và được tạo bởi ZZ0003ZZ
vĩ mô. Trình thực thi KUnit lặp lại mảng phần liên kết để
chạy tất cả các bài kiểm tra được biên dịch vào kernel.

.. kernel-figure:: kunit_suitememorydiagram.svg
	:alt:	KUnit Suite Memory

	KUnit Suite Memory Diagram

On the kernel boot, the KUnit executor uses the start and end addresses
của phần này để lặp lại và chạy tất cả các bài kiểm tra. Đối với việc thực hiện các
người thi hành, xem
ZZ0002ZZ.
Khi được xây dựng dưới dạng mô-đun, macro ZZ0000ZZ xác định một
Hàm ZZ0001ZZ, chạy tất cả các bài kiểm tra trong quá trình biên dịch
unit thay vì sử dụng người thi hành.

Trong các bài kiểm tra KUnit, một số loại lỗi không ảnh hưởng đến các bài kiểm tra khác
hoặc các phần của kernel, mỗi trường hợp KUnit sẽ thực thi trong một luồng riêng biệt
bối cảnh. Xem chức năng ZZ0000ZZ trong
ZZ0001ZZ.

Macro xác nhận
----------------

Kiểm thử KUnit xác minh trạng thái bằng cách sử dụng kỳ vọng/xác nhận.
Tất cả các kỳ vọng/xác nhận được định dạng là:
ZZ0000ZZ

- ZZ0000ZZ xác định xem séc là một xác nhận hay một
  mong đợi.
  Trong trường hợp xảy ra lỗi, quy trình thử nghiệm sẽ khác nhau như sau:

- Đối với những kỳ vọng, bài kiểm tra được đánh dấu là không đạt và lỗi được ghi lại.

- Mặt khác, các xác nhận không thành công sẽ dẫn đến trường hợp kiểm thử bị
	  chấm dứt ngay lập tức.

- Khẳng định gọi hàm:
		  ZZ0000ZZ.

- ZZ0000ZZ gọi hàm:
		  ZZ0001ZZ.

- ZZ0000ZZ gọi hàm:
		  ZZ0001ZZ
		  và chấm dứt bối cảnh chủ đề đặc biệt.

- ZZ0000ZZ biểu thị séc có các tùy chọn: ZZ0001ZZ (tài sản được cung cấp
  có giá trị boolean "true"), ZZ0002ZZ (hai thuộc tính được cung cấp là
  bằng nhau), ZZ0003ZZ (con trỏ được cung cấp không rỗng và không
  chứa giá trị "err").

- ZZ0000ZZ in thông báo tùy chỉnh khi bị lỗi.

Báo cáo kết quả kiểm tra
---------------------
KUnit in kết quả kiểm tra ở định dạng KTAP. KTAP dựa trên TAP14, xem
Tài liệu/dev-tools/ktap.rst.
KTAP hoạt động với KUnit và Kselftest. Trình thực thi KUnit in kết quả KTAP thành
dmesg và debugfs (nếu được định cấu hình).

Kiểm tra tham số
-------------------

Mỗi bài kiểm tra tham số KUnit được liên kết với một tập hợp các
các thông số. Thử nghiệm được gọi nhiều lần, một lần cho mỗi tham số
giá trị và tham số được lưu trữ trong trường ZZ0000ZZ.
Trường hợp thử nghiệm bao gồm macro KUNIT_CASE_PARAM() chấp nhận một
chức năng máy phát điện. Hàm tạo được truyền tham số trước đó
và trả về tham số tiếp theo. Nó cũng bao gồm một macro để tạo
các trình tạo trường hợp phổ biến dựa trên mảng.

kunit_tool (Khai thác kiểm tra dòng lệnh)
======================================

ZZ0000ZZ là tập lệnh Python, được tìm thấy trong ZZ0001ZZ. Nó
được sử dụng để định cấu hình, xây dựng, thực thi, phân tích kết quả kiểm tra và chạy tất cả
các lệnh trước đó theo đúng thứ tự (tức là định cấu hình, xây dựng, thực thi và phân tích cú pháp).
Bạn có hai tùy chọn để chạy thử nghiệm KUnit: hoặc xây dựng kernel bằng KUnit
được bật và phân tích kết quả theo cách thủ công (xem
Documentation/dev-tools/kunit/run_manual.rst) hoặc sử dụng ZZ0002ZZ
(xem Tài liệu/dev-tools/kunit/run_wrapper.rst).

- Lệnh ZZ0000ZZ tạo kernel ZZ0001ZZ từ một
  Tệp ZZ0002ZZ (và mọi tùy chọn dành riêng cho kiến ​​trúc).
  Các tập lệnh Python có sẵn trong thư mục ZZ0003ZZ
  (ví dụ: ZZ0004ZZ) chứa
  các tùy chọn cấu hình bổ sung cho các kiến trúc cụ thể.
  Nó phân tích cả tệp ZZ0005ZZ và ZZ0006ZZ hiện có
  để đảm bảo rằng ZZ0007ZZ là siêu bộ của ZZ0008ZZ.
  Nếu không, nó sẽ kết hợp cả hai và chạy ZZ0009ZZ để tạo lại
  tệp ZZ0010ZZ. Sau đó nó sẽ kiểm tra xem liệu ZZ0011ZZ đã trở thành superset hay chưa.
  Điều này xác minh rằng tất cả các phụ thuộc Kconfig được chỉ định chính xác trong
  tập tin ZZ0012ZZ. Tập lệnh ZZ0013ZZ chứa mã để phân tích cú pháp
  Kconfig. Mã chạy ZZ0014ZZ là một phần của
  Tập lệnh ZZ0015ZZ. Bạn có thể gọi lệnh này thông qua:
  ZZ0016ZZ và
  tạo tệp ZZ0017ZZ.
- ZZ0018ZZ chạy ZZ0019ZZ trên cây kernel với các tùy chọn bắt buộc
  (phụ thuộc vào kiến trúc và một số tùy chọn, ví dụ: build_dir)
  và báo cáo bất kỳ lỗi nào.
  Để xây dựng hạt nhân KUnit từ ZZ0020ZZ hiện tại, bạn có thể sử dụng
  Đối số ZZ0021ZZ: ZZ0022ZZ.
- Lệnh ZZ0023ZZ thực thi trực tiếp các kết quả kernel (sử dụng
  Cấu hình Linux ở chế độ người dùng) hoặc thông qua trình mô phỏng như
  như QEMU. Nó đọc kết quả từ nhật ký bằng cách sử dụng tiêu chuẩn
  đầu ra (thiết bị xuất chuẩn) và chuyển chúng tới ZZ0024ZZ để được phân tích cú pháp.
  Nếu bạn đã xây dựng hạt nhân với các bài kiểm tra KUnit tích hợp sẵn,
  bạn có thể chạy kernel và hiển thị kết quả kiểm tra với ZZ0025ZZ
  đối số: ZZ0026ZZ.
- ZZ0027ZZ trích xuất đầu ra KTAP từ nhật ký kernel, phân tích cú pháp
  kết quả kiểm tra và in một bản tóm tắt. Đối với các thử nghiệm thất bại, bất kỳ
  đầu ra chẩn đoán sẽ được bao gồm.