.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/gpio/using-gpio.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Sử dụng dòng GPIO trong Linux
=========================

Nhân Linux tồn tại để trừu tượng hóa và trình bày phần cứng cho người dùng. Dòng GPIO
như vậy thường không phải là sự trừu tượng mà người dùng phải đối mặt. Điều hiển nhiên nhất, tự nhiên nhất
và cách ưa thích để sử dụng các dòng GPIO là để các trình điều khiển phần cứng kernel xử lý
với họ.

Đối với các ví dụ về trình điều khiển chung hiện có cũng sẽ tốt
ví dụ cho bất kỳ trình điều khiển kernel nào khác mà bạn muốn tạo, hãy tham khảo
Tài liệu/driver-api/gpio/drivers-on-gpio.rst

Đối với bất kỳ loại hệ thống sản xuất hàng loạt nào bạn muốn hỗ trợ, chẳng hạn như máy chủ,
máy tính xách tay, điện thoại, máy tính bảng, bộ định tuyến và bất kỳ hàng hóa tiêu dùng, văn phòng hoặc kinh doanh nào
sử dụng trình điều khiển kernel thích hợp là điều tối quan trọng. Gửi mã của bạn để đưa vào
trong nhân Linux ngược dòng khi bạn cảm thấy nó đủ trưởng thành và bạn sẽ nhận được
giúp tinh chỉnh nó, xem Tài liệu/quy trình/gửi-patches.rst.

Trong Linux dòng GPIO cũng có không gian người dùng ABI.

Không gian người dùng ABI được thiết kế để triển khai một lần. Ví dụ là nguyên mẫu,
dây chuyền nhà máy, dự án cộng đồng của nhà sản xuất, mẫu xưởng, công cụ sản xuất,
tự động hóa công nghiệp, trường hợp sử dụng loại PLC, bộ điều khiển cửa, tóm lại là một phần
các thiết bị chuyên dụng không sản xuất được theo số lượng, đòi hỏi
người vận hành phải có kiến thức sâu sắc về thiết bị và biết về
giao diện phần mềm-phần cứng được thiết lập. Họ không nên có sự phù hợp tự nhiên
cho bất kỳ hệ thống con kernel hiện có nào và không phù hợp với hệ điều hành,
vì không thể tái sử dụng hoặc đủ trừu tượng hoặc liên quan đến nhiều thứ không
chính sách liên quan đến phần cứng máy tính.

Các ứng dụng có lý do chính đáng để sử dụng hệ thống con I/O công nghiệp (IIO)
từ không gian người dùng có thể sẽ phù hợp để sử dụng các dòng GPIO từ không gian người dùng làm
tốt.

Trong mọi trường hợp, không được lạm dụng không gian người dùng GPIO ABI để đi tắt.
bất kỳ dự án phát triển sản phẩm nào. Nếu bạn sử dụng nó để tạo mẫu thì đừng
sản xuất nguyên mẫu: viết lại nó bằng trình điều khiển hạt nhân thích hợp. Đừng theo
trong mọi trường hợp, hãy triển khai bất kỳ sản phẩm thống nhất nào sử dụng GPIO từ không gian người dùng.

Không gian người dùng ABI là một thiết bị ký tự cho mỗi đơn vị phần cứng GPIO (chip GPIO).
Các thiết bị này sẽ xuất hiện trên hệ thống dưới dạng ZZ0000ZZ thông qua
ZZ0001ZZ. Ví dụ về cách sử dụng trực tiếp không gian người dùng ABI có thể là
được tìm thấy trong thư mục con ZZ0002ZZ của cây nhân.

Đối với các ứng dụng có cấu trúc và được quản lý, chúng tôi khuyên bạn nên sử dụng
thư viện libgpiod_. Điều này cung cấp sự trừu tượng của trình trợ giúp, tiện ích dòng lệnh
và phân xử cho nhiều người tiêu dùng đồng thời trên cùng một chip GPIO.

.. _libgpiod: https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/
