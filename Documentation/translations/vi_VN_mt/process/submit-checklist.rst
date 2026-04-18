.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/submit-checklist.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _submitchecklist:

============================================
Danh sách kiểm tra gửi bản vá hạt nhân Linux
============================================

Dưới đây là một số điều cơ bản mà nhà phát triển nên làm nếu họ muốn xem
việc gửi bản vá kernel được chấp nhận nhanh hơn.

Đây là tất cả những điều trên và ngoài tài liệu được cung cấp trong
ZZ0000ZZ
và những nơi khác liên quan đến việc gửi các bản vá nhân Linux.

Xem lại mã của bạn
==================

1) Nếu bạn sử dụng một tiện ích thì #include tệp xác định/khai báo
   cơ sở đó.  Đừng phụ thuộc vào các tệp tiêu đề khác kéo theo các tệp đó
   mà bạn sử dụng.

2) Kiểm tra bản vá của bạn để biết kiểu chung như chi tiết trong
   ZZ0000ZZ.

3) Tất cả các rào cản về bộ nhớ {ví dụ: ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ} đều cần có
   bình luận trong mã nguồn giải thích logic của những gì họ đang làm
   và tại sao.

Xem lại các thay đổi của Kconfig
================================

1) Bất kỳ tùy chọn ZZ0000ZZ mới hoặc được sửa đổi nào đều không làm hỏng menu cấu hình và
   mặc định tắt trừ khi chúng đáp ứng các tiêu chí ngoại lệ được ghi trong
   ZZ0001ZZ Thuộc tính menu: giá trị mặc định.

2) Tất cả các tùy chọn ZZ0000ZZ mới đều có văn bản trợ giúp.

3) Đã được xem xét cẩn thận đối với ZZ0000ZZ có liên quan
   sự kết hợp.  Điều này rất khó thực hiện đúng khi thử nghiệm --- sức mạnh trí tuệ
   được đền đáp ở đây.

Cung cấp tài liệu
=====================

1) Bao gồm ZZ0000ZZ để ghi lại các API hạt nhân toàn cầu.
   (Không bắt buộc đối với các hàm tĩnh, nhưng cũng được.)

2) Tất cả các mục ZZ0000ZZ mới được ghi lại trong ZZ0001ZZ

3) Tất cả các tham số khởi động kernel mới được ghi lại trong
   ZZ0000ZZ.

4) Tất cả các tham số mô-đun mới được ghi lại bằng ZZ0000ZZ

5) Tất cả giao diện không gian người dùng mới đều được ghi lại trong ZZ0000ZZ.
   Xem Tài liệu/admin-guide/abi.rst (hoặc ZZ0001ZZ)
   để biết thêm thông tin.
   Các bản vá thay đổi giao diện không gian người dùng phải được CCed thành
   linux-api@vger.kernel.org.

6) Nếu bất kỳ ioctl nào được bản vá thêm vào, thì hãy cập nhật
   ZZ0000ZZ.

Kiểm tra mã của bạn bằng các công cụ
====================================

1) Kiểm tra các vi phạm nhỏ bằng trình kiểm tra kiểu bản vá trước
   trình (ZZ0000ZZ).
   Bạn có thể biện minh cho tất cả các hành vi vi phạm còn tồn tại trong
   bản vá của bạn.

2) Kiểm tra sạch sẽ với thưa thớt.

3) Sử dụng ZZ0000ZZ và khắc phục mọi sự cố mà nó tìm thấy.
   Lưu ý rằng ZZ0001ZZ không chỉ ra vấn đề một cách rõ ràng,
   nhưng bất kỳ hàm nào sử dụng nhiều hơn 512 byte trên ngăn xếp đều là
   ứng cử viên cho sự thay đổi.

Xây dựng mã của bạn
===================

1) Xây dựng sạch sẽ:

a) với các tùy chọn ZZ0000ZZ hiện hành hoặc được sửa đổi ZZ0001ZZ, ZZ0002ZZ và
     ZZ0003ZZ.  Không có cảnh báo/lỗi ZZ0004ZZ, không có cảnh báo/lỗi liên kết.

b) Đạt ZZ0000ZZ, ZZ0001ZZ

c) Build thành công khi sử dụng ZZ0000ZZ

d) Mọi Tài liệu/thay đổi được xây dựng thành công mà không có cảnh báo/lỗi mới.
     Sử dụng ZZ0000ZZ hoặc ZZ0001ZZ để kiểm tra bản dựng và
     khắc phục mọi vấn đề.

2) Xây dựng trên nhiều kiến trúc CPU bằng cách sử dụng các công cụ biên dịch chéo cục bộ
   hoặc một số trang trại xây dựng khác.
   Lưu ý rằng việc kiểm tra các kiến trúc có kích thước từ khác nhau
   (32- và 64-bit) và độ bền khác nhau (lớn và nhỏ-) đều hiệu quả
   trong việc nắm bắt các vấn đề về tính di động khác nhau do các giả định sai về
   phạm vi số lượng có thể biểu thị, căn chỉnh dữ liệu hoặc độ bền, trong số
   những người khác.

3) Mã mới được thêm vào đã được biên dịch bằng ZZ0000ZZ (sử dụng
   ZZ0001ZZ).  Điều này sẽ tạo ra nhiều tiếng ồn, nhưng tốt
   để tìm các lỗi như "cảnh báo: so sánh giữa đã ký và chưa ký".

4) Nếu mã nguồn đã sửa đổi của bạn phụ thuộc hoặc sử dụng bất kỳ kernel nào
   API hoặc tính năng có liên quan đến các ký hiệu ZZ0000ZZ sau đây,
   sau đó kiểm tra nhiều bản dựng với các ký hiệu ZZ0001ZZ liên quan bị vô hiệu hóa
   và/hoặc ZZ0002ZZ (nếu tùy chọn đó có sẵn) [không phải tất cả những thứ này ở
   cùng lúc, chỉ là sự kết hợp khác nhau/ngẫu nhiên của chúng]:

ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ,
   ZZ0004ZZ, ZZ0005ZZ, ZZ0006ZZ, ZZ0007ZZ,
   ZZ0008ZZ, ZZ0009ZZ (nhưng sau này có ZZ0010ZZ).

Kiểm tra mã của bạn
===================

1) Đã được thử nghiệm với ZZ0000ZZ, ZZ0001ZZ,
   ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ,
   ZZ0005ZZ, ZZ0006ZZ,
   ZZ0007ZZ và ZZ0008ZZ tất cả
   kích hoạt đồng thời.

2) Đã được thử nghiệm xây dựng và thời gian chạy có và không có ZZ0000ZZ và
   ZZ0001ZZ

3) Tất cả các đường dẫn mã đã được thực hiện với tất cả các tính năng lockdep được bật.

4) Đã được kiểm tra bằng cách chèn ít nhất phiến và phân bổ trang
   những thất bại.  Xem ZZ0000ZZ.
   Nếu mã mới có giá trị lớn, việc bổ sung lỗi cụ thể của hệ thống con
   tiêm có thể thích hợp.

5) Đã kiểm tra thẻ gần đây nhất của linux-next để đảm bảo rằng nó vẫn
   hoạt động với tất cả các bản vá được xếp hàng đợi khác và các thay đổi khác nhau trong VM,
   VFS và các hệ thống con khác.
