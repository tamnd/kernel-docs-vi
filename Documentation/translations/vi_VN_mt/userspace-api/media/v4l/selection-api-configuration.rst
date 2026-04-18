.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/selection-api-configuration.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

*************
Cấu hình
*************

Các ứng dụng có thể sử dụng ZZ0000ZZ để
chọn một vùng trong tín hiệu video hoặc bộ đệm và truy vấn mặc định
cài đặt và giới hạn phần cứng.

Phần cứng video có thể có nhiều cách cắt, biên soạn và chia tỷ lệ khác nhau
những hạn chế. Nó chỉ có thể tăng hoặc giảm tỷ lệ, chỉ hỗ trợ tỷ lệ rời rạc
các yếu tố hoặc có khả năng mở rộng quy mô khác nhau theo chiều ngang và
các hướng dọc. Ngoài ra, nó có thể không hỗ trợ mở rộng quy mô. Đồng thời
thời gian cắt xén/sáng tác các hình chữ nhật có thể phải được căn chỉnh và cả hai
nguồn và bồn rửa có thể có giới hạn kích thước trên và dưới tùy ý.
Vì vậy, như thường lệ, người lái xe phải điều chỉnh tốc độ được yêu cầu
tham số và trả về giá trị thực tế đã chọn. Một ứng dụng có thể
kiểm soát hành vi làm tròn bằng cách sử dụng
ZZ0000ZZ.


Cấu hình quay video
==============================

Xem hình ZZ0000ZZ để biết ví dụ về lựa chọn
mục tiêu có sẵn cho thiết bị quay video. Đó là khuyến khích để
cấu hình các mục tiêu cắt xén trước cho các mục tiêu soạn thảo.

Phạm vi tọa độ của góc trên cùng bên trái, chiều rộng và chiều cao của
các khu vực có thể được lấy mẫu được cung cấp bởi ZZ0000ZZ
mục tiêu. Các nhà phát triển trình điều khiển nên đặt trên cùng/bên trái
góc tại vị trí ZZ0001ZZ. Tọa độ của hình chữ nhật được thể hiện
tính bằng pixel.

Góc trên cùng bên trái, chiều rộng và chiều cao của hình chữ nhật nguồn, tức là
khu vực thực sự được lấy mẫu, được đưa ra bởi mục tiêu ZZ0000ZZ.
Nó sử dụng cùng hệ tọa độ với ZZ0001ZZ. các
diện tích canh tác đang hoạt động phải nằm hoàn toàn trong ranh giới đánh bắt.
Người lái xe có thể điều chỉnh thêm kích thước và/hoặc vị trí được yêu cầu
theo giới hạn phần cứng.

Mỗi thiết bị chụp có một hình chữ nhật nguồn mặc định, được cung cấp bởi
Mục tiêu ZZ0000ZZ. Hình chữ nhật này sẽ bao gồm những gì
người viết trình điều khiển xem xét bức tranh hoàn chỉnh. Người lái xe phải thiết lập
hoạt động cắt hình chữ nhật thành mặc định khi trình điều khiển được tải lần đầu tiên,
nhưng không phải sau này.

Các mục tiêu soạn thảo đề cập đến bộ nhớ đệm. Giới hạn của việc sáng tác
tọa độ thu được bằng cách sử dụng ZZ0001ZZ. Tất cả
tọa độ được thể hiện bằng pixel. Góc trên/trái của hình chữ nhật
phải được đặt ở vị trí ZZ0002ZZ. Chiều rộng và chiều cao bằng nhau
kích thước hình ảnh được đặt bởi ZZ0000ZZ.

Phần bộ đệm mà phần cứng chèn hình ảnh vào đó là
được điều khiển bởi mục tiêu ZZ0001ZZ. Hình chữ nhật
tọa độ cũng được thể hiện trong cùng hệ tọa độ với
giới hạn hình chữ nhật. Hình chữ nhật soạn thảo phải nằm hoàn toàn bên trong
giới hạn hình chữ nhật. Người lái xe phải điều chỉnh hình chữ nhật soạn thảo cho phù hợp
tới các giới hạn giới hạn. Hơn nữa, người lái xe có thể thực hiện các chức năng khác
điều chỉnh theo giới hạn phần cứng. Ứng dụng có thể
kiểm soát hành vi làm tròn bằng cách sử dụng
ZZ0000ZZ.

Đối với các thiết bị chụp, hình chữ nhật soạn thảo mặc định được truy vấn bằng cách sử dụng
ZZ0000ZZ. Nó thường bằng giới hạn
hình chữ nhật.

Phần bộ đệm được phần cứng sửa đổi được cung cấp bởi
ZZ0000ZZ. Nó chứa tất cả các pixel được xác định bằng cách sử dụng
ZZ0001ZZ cộng với tất cả dữ liệu đệm được sửa đổi bởi phần cứng
trong quá trình chèn. Tất cả các pixel bên ngoài hình chữ nhật này ZZ0002ZZ
được thay đổi bởi phần cứng. Nội dung của các pixel nằm bên trong
vùng đệm nhưng vùng hoạt động bên ngoài không được xác định. Ứng dụng có thể
sử dụng các hình chữ nhật được đệm và hoạt động để phát hiện vị trí của các pixel rác
được định vị và loại bỏ chúng nếu cần thiết.


Cấu hình đầu ra video
=============================

Đối với các mục tiêu và ioctls của thiết bị đầu ra được sử dụng tương tự như video
vụ bắt giữ. Hình chữ nhật ZZ0000ZZ đề cập đến việc chèn một
hình ảnh thành tín hiệu video. Các hình chữ nhật cắt xén đề cập đến một bộ nhớ
bộ đệm. Nên cấu hình các mục tiêu soạn thảo trước đó để
các mục tiêu cắt xén.

Các mục tiêu cắt xén đề cập đến bộ nhớ đệm chứa hình ảnh
để chèn vào tín hiệu video hoặc màn hình đồ họa. Các giới hạn của
tọa độ cắt xén thu được bằng ZZ0001ZZ.
Tất cả tọa độ được thể hiện bằng pixel. Góc trên/trái luôn là
điểm ZZ0002ZZ. Chiều rộng và chiều cao bằng với kích thước hình ảnh
được chỉ định bằng ZZ0000ZZ ioctl.

Góc trên cùng bên trái, chiều rộng và chiều cao của hình chữ nhật nguồn, tức là
khu vực mà ngày hình ảnh được xử lý bởi phần cứng, được đưa ra
bởi ZZ0000ZZ. Tọa độ của nó được thể hiện trong
cùng hệ tọa độ với hình chữ nhật giới hạn. Vùng cắt xén đang hoạt động
phải nằm hoàn toàn trong ranh giới cây trồng và người lái xe có thể
điều chỉnh thêm kích thước và/hoặc vị trí được yêu cầu theo phần cứng
những hạn chế.

Đối với các thiết bị đầu ra, hình chữ nhật cắt xén mặc định được truy vấn bằng cách sử dụng
ZZ0000ZZ. Nó thường bằng giới hạn
hình chữ nhật.

Phần của tín hiệu video hoặc màn hình đồ họa chứa hình ảnh
được chèn bởi phần cứng được điều khiển bởi ZZ0000ZZ
mục tiêu. Tọa độ của hình chữ nhật được thể hiện bằng pixel. các
hình chữ nhật soạn thảo phải nằm hoàn toàn bên trong hình chữ nhật giới hạn. các
người lái xe phải điều chỉnh khu vực cho phù hợp với giới hạn giới hạn. Hơn nữa,
trình điều khiển có thể thực hiện các điều chỉnh khác tùy theo giới hạn của phần cứng.

Thiết bị có hình chữ nhật soạn thảo mặc định, được cung cấp bởi
Mục tiêu ZZ0000ZZ. Hình chữ nhật này sẽ bao gồm những gì
người viết trình điều khiển xem xét bức tranh hoàn chỉnh. Nó được khuyến khích cho
các nhà phát triển trình điều khiển đặt góc trên/trái ở vị trí ZZ0001ZZ.
Trình điều khiển sẽ đặt hình chữ nhật soạn thảo đang hoạt động thành hình chữ nhật mặc định khi
trình điều khiển được tải lần đầu tiên.

Các thiết bị có thể giới thiệu nội dung bổ sung cho tín hiệu video ngoài
một hình ảnh từ bộ nhớ đệm. Nó bao gồm các đường viền xung quanh một hình ảnh.
Tuy nhiên, vùng đệm như vậy là tính năng phụ thuộc vào trình điều khiển không được bao phủ bởi
tài liệu này. Các nhà phát triển trình điều khiển được khuyến khích giữ hình chữ nhật có đệm
tương đương với hoạt động. Mục tiêu đệm được truy cập bởi
Mã định danh ZZ0000ZZ. Nó phải chứa tất cả các pixel
từ mục tiêu ZZ0001ZZ.


Kiểm soát tỷ lệ
===============

Một ứng dụng có thể phát hiện xem việc chia tỷ lệ có được thực hiện hay không bằng cách so sánh chiều rộng
và chiều cao của hình chữ nhật thu được bằng ZZ0000ZZ và
Mục tiêu ZZ0001ZZ. Nếu những điều này không bằng nhau thì
việc chia tỷ lệ được áp dụng. Ứng dụng có thể tính toán tỷ lệ chia tỷ lệ bằng cách sử dụng
những giá trị này.