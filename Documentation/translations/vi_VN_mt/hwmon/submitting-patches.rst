.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/submitting-patches.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Cách để bản vá của bạn được chấp nhận vào hệ thống con Hwmon
=======================================================

Văn bản này là tập hợp các gợi ý dành cho những người viết các bản vá lỗi hoặc
trình điều khiển cho hệ thống con hwmon. Làm theo những gợi ý này sẽ giúp ích rất nhiều
tăng cơ hội thay đổi của bạn được chấp nhận.


1. Chung
----------

* Có lẽ không cần thiết phải nhắc đến nhưng xin mời các bạn đọc và làm theo:

- Tài liệu/quy trình/submit-checklist.rst
    - Tài liệu/quy trình/gửi-patches.rst
    - Tài liệu/quy trình/coding-style.rst

* Vui lòng chạy bản vá của bạn thông qua 'checkpatch --strict'. Không nên có
  lỗi, không có cảnh báo và rất ít nếu có thông báo kiểm tra. Nếu có bất kỳ
  tin nhắn, xin vui lòng chuẩn bị để giải thích.

* Vui lòng sử dụng kiểu bình luận nhiều dòng tiêu chuẩn. Không trộn lẫn C và C++
  nhận xét kiểu trong một trình điều khiển duy nhất (ngoại trừ giấy phép SPDX
  định danh).

* Nếu bản vá của bạn tạo ra lỗi bản vá, cảnh báo hoặc thông báo kiểm tra,
  vui lòng tránh những lời giải thích như "Tôi thích phong cách viết mã đó hơn".
  Hãy nhớ rằng mỗi tin nhắn không cần thiết sẽ giúp che giấu một vấn đề thực sự,
  và phong cách mã hóa nhất quán giúp người khác dễ hiểu hơn
  và xem lại mã.

* Vui lòng kiểm tra kỹ bản vá của bạn. Chúng tôi không phải là nhóm thử nghiệm của bạn.
  Đôi khi một bản vá không thể hoặc không thể kiểm tra hoàn toàn vì thiếu
  phần cứng. Trong những trường hợp như vậy, bạn nên xây dựng thử mã trên ít nhất một
  kiến trúc. Nếu việc kiểm tra thời gian chạy không đạt được, nó phải được viết
  rõ ràng bên dưới tiêu đề bản vá.

* Nếu bản vá (hoặc trình điều khiển) của bạn bị ảnh hưởng bởi các tùy chọn cấu hình như
  CONFIG_SMP, hãy đảm bảo nó biên dịch cho tất cả các biến thể cấu hình.


2. Thêm chức năng cho trình điều khiển hiện có
-------------------------------------------

* Đảm bảo tài liệu trong Documentation/hwmon/<driver_name>.rst là tối đa
  ngày.

* Đảm bảo thông tin trong Kconfig được cập nhật.

* Nếu chức năng bổ sung yêu cầu dọn dẹp hoặc thay đổi cấu trúc, hãy tách
  bản vá của bạn thành phần dọn dẹp và phần bổ sung thực tế. Điều này làm cho nó dễ dàng hơn
  để xem xét các thay đổi của bạn và chia đôi mọi vấn đề phát sinh.

* Không bao giờ kết hợp các bản sửa lỗi, dọn dẹp và cải tiến chức năng trong một bản vá.


3. Trình điều khiển mới
--------------

* Chạy (các) tệp bản vá hoặc trình điều khiển của bạn thông qua bản vá không có nghĩa là nó
  định dạng sạch sẽ. Nếu không chắc chắn về định dạng trong trình điều khiển mới của bạn, hãy chạy nó
  thông qua Lindent. Lindent không hoàn hảo và bạn có thể phải thực hiện một số sửa đổi nhỏ
  dọn dẹp, nhưng đó là một khởi đầu tốt.

* Hãy cân nhắc việc thêm chính bạn vào MAINTAINERS.

* Ghi lại trình điều khiển trong Documentation/hwmon/<driver_name>.rst.

* Thêm driver vào Kconfig và Makefile theo thứ tự bảng chữ cái.

* Đảm bảo rằng tất cả các phần phụ thuộc đều được liệt kê trong Kconfig.

* Vui lòng liệt kê các tập tin theo thứ tự bảng chữ cái.

* Vui lòng căn chỉnh các dòng tiếp theo với '(' ở dòng trước.

* Tránh chuyển tiếp các tờ khai nếu có thể. Sắp xếp lại mã nếu cần thiết.

* Tránh macro để tạo các nhóm thuộc tính cảm biến. Nó không chỉ gây nhầm lẫn
  bản vá lỗi mà còn khiến việc xem lại mã trở nên khó khăn hơn.

* Tránh tính toán trong macro và các hàm do macro tạo. Trong khi các macro như vậy
  có thể lưu một dòng hoặc hơn trong nguồn, nó làm xáo trộn mã và tạo mã
  xem xét khó khăn hơn. Nó cũng có thể dẫn đến mã phức tạp hơn
  hơn mức cần thiết. Các macro như vậy cũng có thể đánh giá các đối số của chúng nhiều lần.
  Điều này dẫn đến các điều kiện đua tranh Thời gian kiểm tra đến Thời gian sử dụng (TOCTOU) khi
  truy cập dữ liệu được chia sẻ mà không cần khóa, ví dụ như khi tính toán các giá trị trong
  sysfs hiển thị các chức năng. Thay vào đó, hãy sử dụng các hàm nội tuyến hoặc chỉ các hàm thông thường.

* Giới hạn số lượng thông điệp tường trình kernel. Nói chung, người lái xe của bạn không nên
  tạo ra một thông báo lỗi chỉ vì một thao tác thời gian chạy không thành công. Báo cáo
  thay vào đó sẽ xảy ra lỗi đối với không gian người dùng bằng cách sử dụng mã lỗi thích hợp. Hãy ghi nhớ
  các thông báo nhật ký lỗi kernel đó không chỉ điền vào nhật ký kernel mà còn
  được in đồng bộ, rất có thể bị vô hiệu hóa ngắt, thường là nối tiếp
  bảng điều khiển. Ghi nhật ký quá mức có thể ảnh hưởng nghiêm trọng đến hiệu suất hệ thống.

* Sử dụng các hàm devres bất cứ khi nào có thể để phân bổ tài nguyên. Vì lý do căn bản
  và các chức năng được hỗ trợ, vui lòng xem Tài liệu/driver-api/driver-model/devres.rst.
  Nếu một hàm không được nhà phát triển hỗ trợ, hãy cân nhắc sử dụng devm_add_action().

* Nếu trình điều khiển có chức năng phát hiện, hãy đảm bảo nó ở chế độ im lặng. Thông báo gỡ lỗi
  và các thông báo được in sau khi phát hiện thành công đều được chấp nhận, nhưng nó
  không được in các thông báo như "Không tìm thấy/hỗ trợ Chip XXX".

Hãy nhớ rằng chức năng phát hiện sẽ chạy cho tất cả các trình điều khiển hỗ trợ
  địa chỉ nếu một con chip được phát hiện trên địa chỉ đó. Những tin nhắn không cần thiết sẽ chỉ
  làm ô nhiễm nhật ký kernel và không cung cấp bất kỳ giá trị nào.

* Cung cấp chức năng phát hiện khi và chỉ khi chip có thể được phát hiện một cách đáng tin cậy.

* Chỉ các địa chỉ I2C sau mới được thăm dò: 0x18-0x1f, 0x28-0x2f,
  0x48-0x4f, 0x58, 0x5c, 0x73 và 0x77. Thăm dò các địa chỉ khác một cách mạnh mẽ
  nản lòng vì nó được biết là gây rắc rối với I2C khác (không phải hwmon)
  chip. Nếu chip của bạn tồn tại ở một địa chỉ không thể thăm dò được thì
  thiết bị sẽ phải được khởi tạo một cách rõ ràng (điều này luôn tốt hơn
  dù sao đi nữa.)

* Tránh ghi vào các thanh ghi chip trong chức năng phát hiện. Nếu bạn phải viết,
  chỉ làm điều đó sau khi bạn đã thu thập đủ dữ liệu để chắc chắn rằng
  việc phát hiện sẽ thành công.

Hãy nhớ rằng con chip có thể không giống như những gì trình điều khiển của bạn tin tưởng và
  việc ghi vào nó có thể gây ra cấu hình sai.

* Đảm bảo không có điều kiện chạy đua nào trong chức năng thăm dò. Cụ thể,
  Khởi tạo hoàn toàn chip và trình điều khiển của bạn trước, sau đó đăng ký với
  hệ thống con hwmon.

* Sử dụng devm_hwmon_device_register_with_info() hoặc nếu trình điều khiển của bạn cần xóa
  hwmon_device_register_with_info() để đăng ký trình điều khiển của bạn với
  hệ thống con hwmon. Hãy thử sử dụng devm_add_action() thay vì chức năng xóa nếu
  có thể. Không sử dụng bất kỳ chức năng đăng ký nào không được dùng nữa.

* Trình điều khiển của bạn phải có thể xây dựng được dưới dạng mô-đun. Nếu không, hãy chuẩn bị sẵn sàng
  giải thích tại sao nó phải được tích hợp vào kernel.

* Không cung cấp hỗ trợ cho các thuộc tính sysfs không được dùng nữa.

* Không tạo thuộc tính không chuẩn trừ khi thực sự cần thiết. Nếu bạn phải sử dụng
  thuộc tính không chuẩn hoặc bạn tin là có, hãy thảo luận về nó trong danh sách gửi thư
  đầu tiên. Dù là trường hợp nào, hãy đưa ra lời giải thích chi tiết tại sao bạn cần
  (các) thuộc tính không chuẩn.
  Các thuộc tính tiêu chuẩn được chỉ định trong Documentation/hwmon/sysfs-interface.rst.

* Khi quyết định hỗ trợ thuộc tính sysfs nào, hãy xem cấu hình của chip
  khả năng. Mặc dù chúng tôi không mong đợi tài xế của bạn hỗ trợ mọi thứ
  chip có thể cung cấp, ít nhất nó phải hỗ trợ tất cả các giới hạn và cảnh báo.

* Cuối cùng nhưng không kém phần quan trọng, vui lòng kiểm tra xem trình điều khiển cho chip của bạn đã tồn tại chưa
  trước khi bắt đầu viết trình điều khiển mới. Đặc biệt đối với cảm biến nhiệt độ,
  chip mới thường là biến thể của chip đã phát hành trước đó. Trong một số trường hợp,
  một con chip mới có lẽ đã được dán nhãn lại.
